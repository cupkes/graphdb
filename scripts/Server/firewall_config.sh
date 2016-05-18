#!/bin/bash -e
#
#
# Script updating firewall
###########################################
LOGTAG="NEO4J_SUPPORT"
NEOHOME="/opt/neo4j"
NEOBIN="/opt/neo4j_support/bin"
NEOETC="/opt/neo4j_support/etc"
NEOBAK="/opt/neo4j/backup"
logger -p local0.notice -t $LOGTAG "modifying iptables"

# open http and https ports
firewall-cmd --permanent --add-port=7474/tcp
if [ $? -eq 0 ]; then
		echo "firewall operation error"
		logger -p local0.notice -t $LOGTAG "error modifying iptables"
		exit 1
fi
firewall-cmd --permanent --add-port=7473/tcp
if [ $? -eq 0 ]; then
		echo "firewall operation error"
		logger -p local0.notice -t $LOGTAG "error modifying iptables"
		exit 2
# open cluster management ports
firewall-cmd --permanent --add-port=5001/tcp
if [ $? -eq 0 ]; then
		echo "firewall operation error"
		logger -p local0.notice -t $LOGTAG "error modifying iptables"
		exit 3
fi
firewall-cmd --permanent --add-port=6001/tcp
if [ $? -eq 0 ]; then
		echo "firewall operation error"
		logger -p local0.notice -t $LOGTAG "error modifying iptables"
		exit 4
fi
# open Samba ports
firewall-cmd --permanent --add-port=137/udp
if [ $? -eq 0 ]; then
		echo "firewall operation error"
		logger -p local0.notice -t $LOGTAG "error modifying iptables"
		exit 5
fi
firewall-cmd --permanent --add-port=138/udp
if [ $? -eq 0 ]; then
		echo "firewall operation error"
		logger -p local0.notice -t $LOGTAG "error modifying iptables"
		exit 6
fi
firewall-cmd --permanent --add-port=139/tcp
if [ $? -eq 0 ]; then
		echo "firewall operation error"
		logger -p local0.notice -t $LOGTAG "error modifying iptables"
		exit 7
fi
firewall-cmd --permanent --add-port=445/tcp
if [ $? -eq 0 ]; then
		echo "firewall operation error"
		logger -p local0.notice -t $LOGTAG "error modifying iptables"
		exit 8
fi
echo "ports opened: "
firewall-cmd --list-ports

logger -p local0.notice -t $LOGTAG "opened tcp ports for neo4j"
