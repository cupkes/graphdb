#!/bin/bash -e
#
# Script for removing Neo4j server mods
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
# Remove Neo4j directory structures
#------------------------------------------------

echo "Removing Neo4j home and support directories\n"
cd /
rm -r $NEOBASE

if [ $? -ne 0 ]; then
	echo "Could not remove neo4j directories and files\n"
	exit 1
else
	echo "Neo4j directories and files removed"
	logger -p local0.notice -t $LOGTAG "neo4j home and support directories removed"
fi

#------------------------------------------------
# Revert shell profile
#------------------------------------------------

cp ~/.bash_profile.bak ~/.bash_profile
logger -p local0.notice -t $LOGTAG "neo4j home and support directories removed"

#------------------------------------------------
# Uninstall packages
#------------------------------------------------

yum remove -y aide
if [ $? -eq 0 ]; then
	echo "aide package removed\n" && logger -p local0.notice -t $LOGTAG "aide package removed"
else
	echo "error removing aide package\n"
	exit 2
fi

yum remove -y java-1.8.0-openjdk
if [ $? -eq 0 ]; then
	echo "openjdk-1.8.0 package removed\n" && logger -p local0.notice -t $LOGTAG "jdk package removed"
else
	echo "error removing jdk package\n"
	exit 3
fi
systemctl stop smb.service
if [ $? -ne 0 ]; then
	echo "error stopping Samba service\n"
	logger -p local0.notice -t $LOGTAG "error stopping Samba service"
	exit 3
else
	echo "stopped Samba service\n"
	logger -p local0.notice -t $LOGTAG "stopped Samba service"
	
fi

systemctl disable smb.service
if [ $? -ne 0 ]; then
	echo "error disabling Samba service\n"
	logger -p local0.notice -t $LOGTAG "error disabled Samba service"
	exit 3
else
	echo "disabled Samba service\n"
	logger -p local0.notice -t $LOGTAG "disabled Samba service"
	
fi

yum remove -y samba
if [ $? -eq 0 ]; then
	echo "samba package removed\n" && logger -p local0.notice -t $LOGTAG "samba package removed"
else
	echo "error removing jdk package\n"
	exit 4
fi

logger -p local0.notice -t $LOGTAG "neo4j clean script completed"
