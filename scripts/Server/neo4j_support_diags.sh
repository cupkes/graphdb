#!/bin/bash
#
# script for creating Neo4j Support Diagnostics
###########################################################
# variable declaration and assignment
###########################################################
HOSTN=$(hostname)
NEOCONF="../conf"
NEOEXE="./neo4j"
NOE4J_HOME=$($NEOEXE info | grep NEO4J_HOME | awk '{ print $2 }')
NEO4J_PORT=$($NEOEXE info | grep NEO4J_SERVER_PORT | awk '{ print $2 }')
NEO4J_PID=$($NEOEXE info | grep pid | awk '{ print $7 }')
NEO4J_SRV_PROPS=$NEOCONF/neo4j-server.properties
NEO4J_PROPS=$NEOCONF/neo4j.properties
NEO4J_WRAP=$NEOCONF/neo4j-wrapper.conf
NEO4J_DIAG_FILE=NEO4J-DIAGS-$HOSTN.info
DB_DIR=$(cat $NEO4J_SRV_PROPS | grep 'org.neo4j.server.database.location' | cut -d = -f 2)
XML_LOGGING=$(cat $NEO4J_SRV_PROPS | grep 'org.neo4j.server.http.log.enabled' | cut -d = -f 2)
MSG_LOG=DB_DIR/messages.log
TARBALL=NEO4J_DIAGNOSTICS.tar
###########################################################
# report generation
###########################################################
touch $RSFREPORT
echo "Diagnostics Report file for host : $HOSTN\n" >> $RSFREPORT
echo "------Neo4j info------------------------\n" >> $RSFREPORT
$NEOEXE info >> $REPORT
echo "----------------------------------------\n" >> $RSFREPORT
echo "pinging Neo4j Server: \n" >> $RSFREPORT
ping localhost:$NEO4J_PORT >> $RSFREPORT
echo "----------------------------------------\n" >> $RSFREPORT
echo "checking Neo4j Server process info: \n" >> $RSFREPORT
ps -p $NEO4J_PID >> $RSFREPORT
echo "----------------------------------------\n" >> $RSFREPORT
echo "------Neo4j Configuration Files---------\n" >> $RSFREPORT
echo "----------------------------------------\n" >> $RSFREPORT
echo "------noe4j.properties------------------\n" >> $RSFREPORT
cat $NEOCONF/neo4j.properties >> $RSFREPORT
echo "----------------------------------------\n" >> $RSFREPORT
echo "------noe4j-wrapper.conf----------------\n" >> $RSFREPORT
cat $NEOCONF/neo4j-wrapper.conf >> $RSFREPORT
echo "----------------------------------------\n" >> $RSFREPORT
echo "------neo4j-server.properties-----------\n"
cat $NEOCONF/neo4j-server.properties >> $RSFREPORT
echo "----------------------------------------\n" >> $RSFREPORT
echo "------Neo4j Database Directory Listing--\n" >> $RSFREPORT
ls -l $DB_DIR >> $RSFREPORT
echo "----------------------------------------\n" >> $RSFREPORT
echo "------Server Info-----------------------\n" >> $RSFREPORT
echo "----------------------------------------\n" >> $RSFREPORT
echo "------Top Processes---------------------\n" >> $RSFREPORT
top -l 1 -o cpu -stats pid,command,cpu,time,threads,vsize >> $RSFREPORT
echo "----------------------------------------\n" >> $RSFREPORT
echo "------Host Virtual Memory Stats---------\n" >> $RSFREPORT
vmstat -s >> $RSFREPORT
echo "----------------------------------------\n" >> $RSFREPORT
echo "------IO Stats--------------------------\n" >> $RSFREPORT
iostat -p sda >> $RSFREPORT
echo "----------------------------------------\n" >> $RSFREPORT
echo "------Disk Free Space-------------------\n" >> $RSFREPORT
df -h >> $RSFREPORT
echo "----------------------------------------\n" >> $RSFREPORT
echo "------Network Info----------------------\n" >> $RSFREPORT
echo "----------------------------------------\n" >> $RSFREPORT
echo "------HOST File Config------------------\n" >> $RSFREPORT
cat /etc/hosts >> $RSFREPORT
echo "----------------------------------------\n" >> $RSFREPORT
echo "------Network Interface Config----------\n" >> $RSFREPORT
ifconfig -a >> $RSFREPORT
echo "----------------------------------------\n" >> $RSFREPORT
echo "------Network Stats---------------------\n" >> $RSFREPORT
netstat >> $RSFREPORT
echo "----------------------------------------\n" >> $RSFREPORT
echo "------end report-------\n" >> $RSFREPORT
###########################################################
# diagnostics tarball generation
###########################################################
tar -cvf $TARBALL $RSFREPORT $MSG_LOG