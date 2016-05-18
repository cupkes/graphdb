#!/bin/bash -e
#!/usr/bin/env NEO4J_HOME
#
# Script for initializing graph
###########################################
# redirect stdout and stderr to logger
exec 1> >(logger -s -t $(basename $0)) 2>&1
# delete existing graph data
./opt/neo4j_support/etc/AutoDeleteGraphData.sh
# load MDM graph
./opt/neo4j_support/etc/AutoLoadMDMGraph.sh
# load SAS graph
./opt/neo4j_support/etc/AutoLoadSASGraph.sh

