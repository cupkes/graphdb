#!/bin/bash -e
#
# Script for support initialization
##################################################
LOGTAG=NEO4J_SUPPORT
NEOBIN="/opt/neo4j_support/bin"
NEOETC="/opt/neo4j_support/etc"
NEOBAK="/opt/backup/neo4j"
INIT_SCRIPT=neo4j_backup_init.sh
MON_SCRIPT=neo4j_monitor.sh
CONF_FILE=neo4j_support.conf
###########################################################
# leverage existing cron directories to determine frequency
# i.e. cron.daily, cron.weekly, etc...
############################################################
CRON_DEST="/etc/cron.daily"
cd $HOME
mkdir -p $NEOETC && chmod 777 $NEOETC
mkdir -p $NEOBIN && chmod 777 $NEOBIN
#
logger -p local0.notice -t $LOGTAG "support directories created"
#
# ensure environment variable set for the neo4j backup directory
#
export NEO4J_BACKUP=$NEOBAK
export PATH=$NEOBIN:$NEOETC:$PATH
#
# copy backup init script
cp $INIT_SCRIPT $NEOBIN && chmod +x $NEOBIN/$INIT_SCRIPT
# 
# copy backup init script to cron folder
cp $NEOBIN/$INIT_SCRIPT $CRON_DEST
logger -p local0.notice -t $LOGTAG "added backup script to CRON schedule"
#
# copy neo4j support config files
cp $CONF_FILE $NEOETC
#
# copy neo4j monitor script to cron folder
cp $MON_SCRIPT $CRON_DEST
#
# edit .profile for current user
cat <<ENDOC >> ~/.profile
# NEO4J SUPPORT MODIFICATION
if [ -d "/opt/neo4j_support/bin/" ] ; then
	PATH=/opt/neo4j_support/bin:\$PATH
fi
if [ -d "/opt/neo4j_support/etc" ] ; then
	PATH=/opt/neo4j_support/etc:\$PATH
fi
if [ -d "/opt/neo4j/backup" ] ; then
	export NEO4J_BACKUP=/opt/neo4j/backup
fi
# END NEO4J SUPPORT MODIFICATION
ENDOC
logger -p local0.notice -t $LOGTAG "user $USER profile updated"