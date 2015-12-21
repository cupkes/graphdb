#!/bin/bash -e
#
# Script for monitoring
##################################################
MAILER='mail'
RECPIPIENTS="osmisworkbench@calibresys.com"
BAK="/opt/backup/neo4j"
THRESHOLD=80
SPACEUSED=$(df -k $NEOBAK | awk 'NR!=1{ print $5 }')
USED=$(cat $SPACEUSED | sed 's/[^0-9]*//g' )
LOGTAG=NEO4J_SUPPORT
BODY="Warning, you have used $SPACEUSED of available storage in your Neo4j backup location!"
SUBJECT="Monitor Notice"
logger -p local0.notice -t $LOGTAG "$SPACEUSED of available space in backup directory used"

if (( $SPACEUSED > $THRESHOLD ))
then
( cat $BODY | $MAILER -s "$SUBJECT" "$RECIPIENTS" );
fi

#################
#  put your customer script here
#################