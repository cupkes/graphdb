#!/bin/bash -e
#
# Script for unit testing variable assignments
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

echo "value of LOGTAG is $LOGTAG"
echo "value of NEOHOME is $NEOHOME"
echo "value of NEOBASE is $NEOBASE"
echo "value of NEOBAK is $NEOBAK"
echo "value of NEOSUPP is $NEOSUPP"
echo "value of NEOBIN is $NEOBIN"
echo "value of NEOETC is $NEOETC"
echo "value of CONF_FILE is $CONF_FILE"
echo "value of SAMBA_FILE is $SAMBA_FILE"
echo "value of SAMBA_SCRIPT is $SAMBA_SCRIPT"
echo "value of FIREWALL_SCRIPT is $FIREWALL_SCRIPT"
echo "value of NEO4J_PROP_FILE is $NEO4J_PROP_FILE"
echo "value of NEO4J_SRV_PROP_FILE is $NEO4J_SRV_PROP_FILE"
echo "value of NEO4J_WRAP_FILE is $NEO4J_WRAP_FILE"
echo "value of SUPPORT_TGZ_FILE is $SUPPORT_TGZ_FILE"
echo "value of NEO4J_SERVER_TGZ is $NEO4J_SERVER_TGZ"
echo "value of SUPPORT_SCRIPT is $SUPPORT_SCRIPT"
echo "value of MONITOR_SCRIPT is $MONITOR_SCRIPT"
echo "value of BACKUP_SCRIPT is $BACKUP_SCRIPT"
echo "value of ADMIN_EMAIL is $ADMIN_EMAIL"
echo "value of AIDE_ENTRY is $AIDE_ENTRY"
echo "value of NODE1_HN is $NODE1_HN"
echo "value of NODE1_IP is $NODE1_IP"
echo "value of NODE2_HN is $NODE2_HN"
echo "value of NODE2_IP is $NODE2_IP"
echo "value of NODE3_HN is $NODE3_HN"
echo "value of NODE3_IP is $NODE3_IP"
echo "value of THISH is THISH"
echo "value of THISIP is $THISIP"
echo "value of THISNUM is $THISNUM"