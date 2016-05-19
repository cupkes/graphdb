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
NEO4j_SERVER_TGZ=neo4j-enterprise-2.3.3-unix.tar.gz
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
NODE1_HN=3DM-Graph01
NODE2_HN=3DM-Graph02
NODE3_HN=3DM-Graph03
NODE1_IP=10.1.0.7
NODE2_IP=10.1.0.6
NODE3_IP=10.1.0.10
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

echo "Creating Neo4j home and support directories\n"
cd /
mkdir -p $NEOETC && chmod 755 $NEOETC
mkdir -p $NEOBIN && chmod 755 $NEOBIN
mkdir -p $NEOBAK && chmod 755 $NEOBAK
#
logger -p local0.notice -t $LOGTAG "neo4j home and support directories created"

#------------------------------------------------
# Update current user (Neo4j) .bash_profile
#------------------------------------------------

# make sure the neo4j home directory exists

if [ ! -d /home/neo4j ]; then
	echo "cannot locate neo4j home directory\n"
	exit 1
fi

#
# update the profile script to include essential path values
# and helpful aliases and shell configurations
#
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

tar -zxvf $SUPPORT_TGZ_FILE -C $NEOBASE && logger -p local0.notice -t $LOGTAG "support files loaded"

# copying support files to proper directories

cp $CONF_FILE $NEOETC/$CONF_FILE
cp $DIAG_FILE $NEOBIN/$DIAG_FILE
cp $SAMBA_FILE $NEOETC/$SAMBA_FILE
cp $NEO4J_PROP_FILE $NEOETC/$NEO4J_PROP_FILE
cp $NEO4J_SRV_PROP_FILE $NEOETC/$NEO4J_SRV_PROP_FILE
cp $NEO4J_WRAP_FILE $NEOETC/$NEO4J_WRAP_FILE
cp $MONITOR_SCRIPT $NEOETC/$MONITOR_SCRIPT

logger -p local0.notice -t $LOGTAG "support files deployed"

# uncompress neo4j enterprise server tarball

tar -zxvf $NEO4j_SERVER_TGZ $NEOBASE && logger -p local0.notice -t $LOGTAG "Neo4j Enterprise Server files deployed"

# backup existing configuration files and copy over provided configuration files

if [ -d $NEOHOME ]; then
	cd $NEOHOME
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
	echo "cannot locate neo4j home directory\n"
	echo "manual configuration of neo4j cluster is required\n"
	
	logger -p local0.notice -t $LOGTAG "unable to deploy neo4j ccluster configuration files"
fi

#------------------------------------------------
# Install intrusion detection package
#------------------------------------------------

# check to see if the aide package is already installed

AIDETEST=(yum list installed aide |& grep Error | awk '{ print $1 }' | sed s/://) 

# install the aide package if it is missing

if [ $AIDETEST == "Error" ]
then
    echo "AIDE not installed, installing" && logger -p local0.notice -t $LOGTAG "installing AIDE"
	yum install -y aide
else
    echo "AIDE already installed"
fi

# update the crontab mailto configuration with the admin email

sed -i s/root/$ADMIN_EMAIL/ /etc/crontab

# initialize the aide package and get the service started

aide --init

logger -p local0.notice -t $LOGTAG "AIDE initialized"

# navigate to the aide library directory
# the aide service creates a new database
# so we rename the new database to the default

cd /var/lib/aide
mv aide.db.new.gz aide.db.gz

# according to the manual, we need to invoke the check & update routines
# and then switch to the newly created database

aide --check
aide --update

rm aide.db.gz

mv aide.db.new.gz aide.db.gz

# now we update the crontab with an entry for the aide package

crontab -e

cat $AIDE_ENTRY >> /etc/crontab

logger -p local0.notice -t $LOGTAG "crontab updated with AIDE entry"


#------------------------------------------------
# Set Neo4j Server specific os configurations
#------------------------------------------------

#
# we need to update some server configuration files
# in order for the neo4j cluster to function properly
#

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

# A restart is required for the settings to take effect.
# After the above procedure, the neo4j user will have a limit of 40 000 simultaneous open files.
# If you continue experiencing exceptions on Too many open files or Could not stat() directory,
# you may have to raise the limit further.

echo "required server configuration changes complete.\n"
echo "System must be restarted before changes take affect\n"

#------------------------------------------------
# Install a jdk
#------------------------------------------------

# 
# The neo4j cluser requires at minimum a java 6 jdk to be installed
#

# determine if the java 8 openjdk is installed.
# We should improve this script by checking for multiple releases (6,7,8)
# and multiple vendors (openjdk, Oracle).

JDKTEST=(yum list installed java-1.8.0-openjdk |& grep Error | awk '{ print $1 }' | sed s/://) 

# if there is no jdk installed, install the openjdk 1.8.0 package

if [ $JDKTEST == "Error" ]
then
    echo "JDK not installed, installing" && logger -p local0.notice -t $LOGTAG "installing JDK"
	yum install -y java-1.8.0-openjdk
else
    echo "JDK already installed"
fi

#------------------------------------------------
# Update network information
#------------------------------------------------

#
# Although most of our configuration details use ip addresses,
# we add nodes to host file so we can reference
# all nodes in the cluster by their actual hostnames
#

cat << ENDOC >> /etc/hosts
# NEO4J SUPPORT MODIFICATION
$NODE1_IP	$NODE1_HN
$NODE2_IP	$NODE2_HN
$NODE3_IP	$NODE3_HN
# END NEO4J SUPPORT MODIFICATION
ENDOC

logger -p local0.notice -t $LOGTAG "/etc/hosts modified"

#------------------------------------------------
# Install and configure auditing
#------------------------------------------------

#
# To ensure we meet the standard security certification guidelines,
# we need to make sure auditing is installed and running rules
# based on the considered requirements (stig, capp, nipsom, etc...).
# 

# check to see if auditing is installed and install if it is missing

AUDITTEST=(yum list installed audit |& grep Error | awk '{ print $1 }' | sed s/://) 

if [ $AUDITTEST == "Error" ]
then
    echo "AUDIT not installed, installing" && logger -p local0.notice -t $LOGTAG "installing AUDIT"
	yum install -y audit
else
    echo "audit already installed"
fi

# set audit rules -- here I use stig because it's thorough



auditctl -R /usr/share/doc/audit-version/stig.rules
if [ $? -eq 0 ]; then
	echo "audit rules loaded"
	logger -p local0.notice -t $LOGTAG "auditing rules loaded and auditing started"
else
	echo "unable to reload audit daemon with new rules\n"
	echo "please execute auditctl -R and provide valid rules file\n"
	logger -p local0.notice -t $LOGTAG "erro loading audit rules"
fi


# optionally you can copy the specific rules file to the default:
#
# cp /etc/audit/audit.rules /etc/audit/audit.rules_backup
# cp /usr/share/doc/audit-version/stig.rules /etc/audit/audit.rules
#
# or nipsom.rules
# or capp.rules
# or lspp.rules

#------------------------------------------------
# Setup and configure samba
#------------------------------------------------

#
# Next we need to setup samba so we can load files from windows
# without the need for ssh or ftp.
#

# call samba config script

cd $NEOBIN
chmod +x $SAMBA_SCRIPT
./$SAMBA_SCRIPT
RETVAL=$?
if [ $RETVAL -ne 0 ]; then
	echo "samba script failed at exit $RETVAL\n"
	exit 1
else
	echo "samba script successful\n"
fi


#------------------------------------------------
# Configure IPTABLES
#------------------------------------------------

#
# Although the Azure virtual switches control most of our network security
# we want to ensure that no local firewall rules prevent
# our neo4j cluser or other services (i.e. samba) from operating normally
#

# call the firewall configuration script

cd $NEOBIN
chmod +x $FIREWALL_SCRIPT
./FIREWALL_SCRIPT
RETVAL=$?
if [ $RETVAL -ne 0 ]; then
	echo "firewall script failed at exit $RETVAL\n"
	exit 1
else
	echo "firewall script successful\n"
fi


#------------------------------------------------
# Configure backup scheduler
#------------------------------------------------

#
# we have a neo4j-specific backup script that defines
# a weekly backup with incremental backups between weekly fulls.
# Since the cluser will be batch-loaded, this backup script
# will be copied to the neo4j_support/bin directory
# but will not be copied to /etc/cron.daily
#

cp $BACKUP_SCRIPT $NEOBIN/$BACKUP_SCRIPT
echo "backup script copied to $NEOBIN\n"
echo "to schedule backup routine copy  $BACKUP_SCRIPT to /etc/cron.daily"

#------------------------------------------------
# Deploy monitoring script
#------------------------------------------------

#
# A neo4j monitoring script already has a routine for monitoring
# the space available in the neo4j/backup directory
# Other monitoring routines should be added to the script.
# 

cp $MONITOR_SCRIPT /etc/cron.daily/$MONITOR_SCRIPT && chmod +x /etc/cron.daily/$MONITOR_SCRIPT

logger -p local0.notice -t $LOGTAG "file : $MONITOR_SCRIPT added to cron.daily"


#------------------------------------------------
# Deploy and execute diagnostics script
#------------------------------------------------

#
# The support diagnostics script will be copied to the neo4j_support/bin directory.
# This script is used to provide the support team with a full set
# of diagnostic information for use with troubleshooting production issues.
#

cp $SUPPORT_SCRIPT $NEOBIN/$SUPPORT_SCRIPT && chmod +x $NEOBIN/$SUPPORT_SCRIPT

#------------------------------------------------
# Ensure proper ownership of directories and files
#------------------------------------------------

#
# After creating and deploying all files and directories
# we want to make sure that we have the appropriate
# user and group ownership defined
#
chown -R neo4j:neo4j $NEOBASE
chown -R neo4j:neo4j $NEOSUPP

logger -p local0.notice -t $LOGTAG "neo4j file and directory ownership changed"







