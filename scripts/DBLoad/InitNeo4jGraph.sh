#!/bin/bash -e
#!/usr/bin/env NEO4J_HOME
#
# Script for initializing graph
###########################################
#
# This script calls three other scripts
# 1.  AutoDeleteGraphData.sh which basically
#	  deletes all nodes and relationships and
#	  drops all indexes.
# 2.  AutoLoadMDMGraph.sh which loads all
#     Metadata Management nodes and their
#     relationships.
# 3.  AutoLoadSASGraph.sh which loads all
#     nodes and relationships for the
#	  SAS Application.
#
###########################################	  
# redirect stdout and stderr to logger
exec 1> >(logger -s -t $(basename $0)) 2>&1
# delete existing graph data
./opt/neo4j_support/etc/AutoDeleteGraphData.sh
# load MDM graph
./opt/neo4j_support/etc/AutoLoadMDMGraph.sh
# load SAS graph
./opt/neo4j_support/etc/AutoLoadSASGraph.sh

