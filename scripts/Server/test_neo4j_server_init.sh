#!/bin/bash -e
#
# Script for initializing NEO4J Server Config
# This script must be run as the neo4j user
# and must be run as super user
#################################################

#------------------------------------------------ 
# Script variables
#------------------------------------------------
# create a standard logging tag for all log entries
LOGTAG=NEO4J_SUPPORT
# specify the neo4j directory tree
NEOHOME="/opt/neo4j/neo4j-enterprise-2.3.3"
NEOBASE="/opt/neo4j"
NEOSUPP="/opt/neo4j_support"
NEOBIN="$NEOSUPP/bin"
NEOETC="$NEOSUPP/etc"
NEOBAK="$NEOBASE/backup"
NEOCONF="$NEOHOME/conf"
#NEOBASE="/db/neo4j"
#NEOBIN="/db/neo4j_support/bin""
#NEOETC="/db/neo4j_support/etc"
#NEOBAK="/db/neo4j/backup"
# pointers to all support files included in the support tarball
CONF_FILE=neo4j_support.conf
# samba files
SAMBA_FILE=neoj4_smb.conf
SAMBA_SCRIPT=samba_config.sh
# firewall files
FIREWALL_SCRIPT=firewall_config.sh
# neo4j cluster configuration files
NEO4J_WRAP_FILE=neo4j-wrapper.config
NEO4J_PROP_FILE=neo4j.properties
NEO4J_SRV_PROP_FILE=neo4j-server.properties
# support tarballs
SUPPORT_TGZ_FILE=neo4j_support.tar.gz
NEO4J_SERVER_TGZ=neo4j-enterprise-2.3.3-unix.tar.gz
# monitoring, backup and diagnostics scripts
SUPPORT_SCRIPT=neojf_support_diags.sh
MONITOR_SCRIPT=neo4j_monitor.sh
BACKUP_SCRIPT=neo4j_backup_routine.sh
# provide address for monitoring and security emails
# this can be one or more adddresses, separated by commas
ADMIN_EMAIL=dongyang@microsoft.com
# provide the crontab entry for the intrusion detection module
AIDE_ENTRY="0 1 * * * /usr/sbin/aide --check"
# detail the hostnames and ip addresses of all nodes in the cluster
NODE1_HN=3DM-Graph04
NODE2_HN=3DM-Graph05
NODE3_HN=3DM-Graph06
NODE1_IP=10.1.0.11
NODE2_IP=10.1.0.12
NODE3_IP=10.1.0.13
# the node details of the script destination
THISH=$NODE1_HN
THISIP=$NODE1_IP
THISNUM=1
#------------------------------------------------
# End script variables
#------------------------------------------------


#------------------------------------------------
# Create Neo4j directory structures
#------------------------------------------------

echo "Creating Neo4j home and support directories"
cd /
mkdir -p $NEOETC && chmod 755 $NEOETC
mkdir -p $NEOBIN && chmod 755 $NEOBIN
mkdir -p $NEOBAK && chmod 755 $NEOBAK
#
logger -p local0.notice -t $LOGTAG "neo4j home and support directories created"
echo "creating directories complete"
#------------------------------------------------
# Update current user (Neo4j) .bash_profile
#------------------------------------------------

# make sure the neo4j home directory exists

if [ ! -d /home/neo4j ]; then
	echo "cannot locate neo4j home directory"
	exit 1
fi

#
# update the profile script to include essential path values
# and helpful aliases and shell configurations
#
echo "updating bash_profile script"

cp ~/.bash_profile ~/.bash_profile.bak

cat << ENDOC >> ~/.bash_profile
# NEO4J SUPPORT MODIFICATION
if [ -d "/opt/neo4j" ] ; then
	PATH=$PATH:opt/neo4j
fi
if [ -d "/opt/neo4j_support/bin" ] ; then
	PATH=$PATH:/opt/neo4j_support/bin
fi
if [ -d "/opt/neo4j_support/etc" ] ; then
	PATH=$PATH:/opt/neo4j_support/etc
fi
if [ -d "/opt/neo4j/backup" ] ; then
	export NEO4J_BACKUP=/opt/neo4j/backup
fi
if [ -d "/opt/neo4j/neo4j-enterprise-2.3.3" ] ; then
	export NEO4J_HOME=/opt/neo4j/neo4j-enterprise-2.3.3
fi
set -o noclobber
unset MAILCHECK
export LANG=C
export PATH
alias df='df -h'
alias rm='rm -i'
alias h='history | tail'
alias neo='cd /opt/neo4j'
# END NEO4J SUPPORT MODIFICATION
ENDOC

logger -p local0.notice -t $LOGTAG "user $USER profile updated"

echo "updating .bash_profile complete"

#------------------------------------------------
# Populate Neo4j directories with Neo4j files
#------------------------------------------------

# return to the neo4j home directory

cd ~

# execute the updated bash profile script

source .bash_profile

#
# Now that the neo4j server and support directory structures
# are created we can deploy the support configuration files and scripts
#

# uncompress the neo4j support tarball

echo "opening support tarball"

tar -zxvf $SUPPORT_TGZ_FILE -C $NEOBASE && logger -p local0.notice -t $LOGTAG "support files loaded"

# copying support files to proper directories

echo "copying files to folders"

cp $CONF_FILE $NEOETC/$CONF_FILE
cp $DIAG_FILE $NEOBIN/$DIAG_FILE
cp $SAMBA_FILE $NEOETC/$SAMBA_FILE
cp $NEO4J_PROP_FILE $NEOETC/$NEO4J_PROP_FILE
cp $NEO4J_SRV_PROP_FILE $NEOETC/$NEO4J_SRV_PROP_FILE
cp $NEO4J_WRAP_FILE $NEOETC/$NEO4J_WRAP_FILE
cp $MONITOR_SCRIPT $NEOETC/$MONITOR_SCRIPT

logger -p local0.notice -t $LOGTAG "support files deployed"

echo "files copied"

# uncompress neo4j enterprise server tarball

echo "opening neo4j enterprise tarball"

tar -zxvf $NEO4J_SERVER_TGZ $NEOBASE && logger -p local0.notice -t $LOGTAG "Neo4j Enterprise Server files deployed"

# backup existing configuration files and copy over provided configuration files

echo "copying config files to NEOHOME/conf"
if [ -d $NEOCONF ]; then
	cd $NEOCONF
	mv $NEO4J_PROP_FILE $NEO4J_PROP_FILE.bak && cp $NEOETC/$NEO4J_PROP_FILE $NEO4J_PROP_FILE
	mv $NEO4J_SRV_PROP_FILE $NEO4J_SRV_PROP_FILE.bak && cp $NEOETC/$NEO4J_SRV_PROP_FILE $NEO4J_SRV_PROP_FILE
	mv $NEO4J_WRAP_FILE $NEO4J_WRAP_FILE.bak && cp $NEOETC/$NEO4J_WRAP_FILE $NEO4J_WRAP_FILE
	
	logger -p local0.notice -t $LOGTAG "neo4j cluster configuration files deployed"
	
	# update server properties file with cluster configuration details
	
	sed -i 's/xthis_server_num/$THISNUM/g' $NEO4J_PROP_FILE
	sed -i 's/xsrv1ip/$NODE1_IP/g' $NEO4J_PROP_FILE
	sed -i 's/xsrv2ip/$NODE2_IP/g' $NEO4J_PROP_FILE
	sed -i 's/xsrv3ip/$NODE3_IP/g' $NEO4J_PROP_FILE
	sed -i 's/xthis_server_ip/$THISIP/g' $NEO4J_PROP_FILE
	
	
	logger -p local0.notice -t $LOGTAG "neo4j cluster configuration updated"
else
	echo "cannot locate neo4j home directory"
	echo "manual configuration of neo4j cluster is required"
	
	logger -p local0.notice -t $LOGTAG "unable to deploy neo4j cluster configuration files"
fi

echo "config file copy complete"

#------------------------------------------------
# Set Neo4j Server specific os configurations
#------------------------------------------------

#
# we need to update some server configuration files
# in order for the neo4j cluster to function properly
#

echo "modifying limits and pam.d/su files"

cat << ENDOC >> /etc/security/limits.conf
# NEO4J SUPPORT MODIFICATION
neo4j   soft    nofile  40000
neo4j   hard    nofile  40000
# END NEO4J SUPPORT MODIFICATION
ENDOC

logger -p local0.notice -t $LOGTAG "limits.conf modified"

cat << ENDOC >> /etc/pam.d/su
# NEO4J SUPPORT MODIFICATION
session    required   pam_limits.so
# END NEO4J SUPPORT MODIFICATION
ENDOC

logger -p local0.notice -t $LOGTAG "pam.d/su modified"

echo "modification of limits.conf and pam.d/su complete"
# A restart is required for the settings to take effect.
# After the above procedure, the neo4j user will have a limit of 40 000 simultaneous open files.
# If you continue experiencing exceptions on Too many open files or Could not stat() directory,
# you may have to raise the limit further.

echo "required server configuration changes complete."
echo "System must be restarted before changes take affect"

#------------------------------------------------
# Install a jdk
#------------------------------------------------

# 
# The neo4j cluser requires at minimum a java 6 jdk to be installed
#

# determine if the java 8 openjdk is installed.
# We should improve this script by checking for multiple releases (6,7,8)
# and multiple vendors (openjdk, Oracle).

echo "installing jdk1.8.0"
JDKTEST=$(yum list installed java-1.8.0-openjdk |& grep Error | awk '{ print $1 }' | sed s/://) 

# if there is no jdk installed, install the openjdk 1.8.0 package

if [ $JDKTEST == "Error" ]
then
    echo "JDK not installed, installing" && logger -p local0.notice -t $LOGTAG "installing JDK"
	yum install -y java-1.8.0-openjdk
else
    echo "JDK already installed"
fi

echo "jdk install complete"

#------------------------------------------------
# Update network information
#------------------------------------------------

#
# Although most of our configuration details use ip addresses,
# we add nodes to host file so we can reference
# all nodes in the cluster by their actual hostnames
#
echo "updating hosts file"

cat << ENDOC >> /etc/hosts
# NEO4J SUPPORT MODIFICATION
$NODE1_IP	$NODE1_HN
$NODE2_IP	$NODE2_HN
$NODE3_IP	$NODE3_HN
# END NEO4J SUPPORT MODIFICATION
ENDOC

logger -p local0.notice -t $LOGTAG "/etc/hosts modified"


echo "hosts file update complete"
#------------------------------------------------
# Ensure proper ownership of directories and files
#------------------------------------------------

#
# After creating and deploying all files and directories
# we want to make sure that we have the appropriate
# user and group ownership defined
#
echo "changing file and folder ownnership"

chown -R neo4j:neo4j $NEOBASE
chown -R neo4j:neo4j $NEOSUPP

logger -p local0.notice -t $LOGTAG "neo4j file and directory ownership changed"

echo "test script complete"





