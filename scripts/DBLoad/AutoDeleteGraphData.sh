#!/bin/bash -e
#!/usr/bin/env NEO4J_HOME
#
# Script for deleting entire Graph
###########################################
#exec 1> >(logger -s -t $(basename $0)) 2>&1
NEO4J_HOME="/opt/neo4j/neo4j-enterprise-2.3.3"
CMD="$NEO4J_HOME/bin/neo4j-shell -file"
# deleting all nodes and indexes
$CMD /opt/neo4j/stage/DataSource/delete.cql
echo "waiting for cluster to synchronize"
sleep 2m
