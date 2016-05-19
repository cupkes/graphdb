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


#------------------------------------------------
# Install intrusion detection package
#------------------------------------------------

# check to see if the aide package is already installed

echo "checking for aide install"

echo "value of AIDETEST should be Error"



AIDETEST=$(yum list installed aide |& grep Error | awk '{ print $1 }' | sed s/://) 

# install the aide package if it is missing

echo "testing value of AIDETEST variable"

if [ $AIDETEST == "Error" ]
then
    echo "AIDE not installed, installing" && logger -p local0.notice -t $LOGTAG "installing AIDE"
	yum install -y aide
else
    echo "AIDE already installed"
fi

# update the crontab mailto configuration with the admin email


echo "updating /etc/crontab"
sed -i 's/root/$ADMIN_EMAIL/' /etc/crontab

# initialize the aide package and get the service started
echo "calling aide --init"
aide --init

logger -p local0.notice -t $LOGTAG "AIDE initialized"

# navigate to the aide library directory
# the aide service creates a new database
# so we rename the new database to the default
echo "changing to /var/lib/aide folder"
cd /var/lib/aide

echo "renaming aide.db.new.gz to aide.db.gz"
mv aide.db.new.gz aide.db.gz

# according to the manual, we need to invoke the check & update routines
# and then switch to the newly created database
echo "executing aide --check"
aide --check
echo "executing aide --update"
aide --update

echo "removing aide.db.gz"

rm aide.db.gz

echo "renaming aide.db.new.gz to aide.db.gz"

mv aide.db.new.gz aide.db.gz

# now we update the crontab with an entry for the aide package
echo "executing crontab -e"
crontab -e

echo "adding AIDE_ENTRY value to /etc/crontab"
echo $AIDE_ENTRY >> /etc/crontab

logger -p local0.notice -t $LOGTAG "crontab updated with AIDE entry"

