#!/bin/bash -e
#
# Script for initializing logging
##################################################
cd /
mkdir -p /opt/neo4j_support/etc
mkdir -p /opt/neo4j_support/bin
chmod 777 /opt/neo4j_support/etc/
chmod 777 /opt/neo4j_support/bin/
mkdir -p /var/log/neo4j_support/
chmod 777 /var/log/neo4j_support/
touch /var/log/neo4j_support/init.log
cat <<ENDOC >>/etc/syslog.conf
# BEGIN NEO4J SUPPORT MODIFICATION
local5.debug	/var/log/neo4j_support/init.log
# END NEO4J SUPPORT MODIFICATION
ENDOC
svcadm refresh system/system-log
# introduce wait code for refresh process
sleep 10
logger -p local5.debug stratatron
LOG =g$(grep NEO4J /var/log/neo4j_support/init.log/strata_logs)
LOGENTRY=${$LOG:?"Expected log entry missing."}
LOGVALUE=$(awk '{print $10} $LOGENTRY')
if [ $LOGVALUE == "NEO4J" ]
then
	echo "logging initialized"
else
	echo "error initializing logging"
fi
