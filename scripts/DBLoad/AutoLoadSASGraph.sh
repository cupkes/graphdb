#!/bin/bash -e
#!/usr/bin/env NEO4J_HOME
#
# Script for loading SAS Graph
# This script is intended to be called
# by a master script.
###########################################
# This script uses the neo4j shell utility
# and .cql files to invoke the LOAD CSV
# functionality built into Neo4j.
# To inspect the cypher being used in each
# step of the load process, review each
# named .cql file.  I used separate .cql
# files for each stage to avoid confusion
# regarding which query was associated with
# which step and to make the debugging process
# easier.
###########################################
#exec 1> >(logger -s -t $(basename $0)) 2>&1

# specify the neo4j home and load utility
NEO4J_HOME="/opt/neo4j/neo4j-enterprise-2.3.3"
CMD="$NEO4J_HOME/bin/neo4j-shell -file"
#---------------------------------------------------------
# We begin by loading nodes.
# 1.  Accounts originating from the SAS applicaiton
# 2.  ADAccounts orginiating from Active Directory
#---------------------------------------------------------
# LOADING ADAccounts
$CMD /opt/neo4j/stage/DataSource/LoadADAccounts.cql
sleep 90 # waiting for indexes to build
# LOADING Accounts - Merge
# Accounts are not guaranteed to be a subset of ADAccounts
$CMD /opt/neo4j/stage/DataSource/LoadAccounts.cql
sleep 90 # waiting for indexes to build
#---------------------------------------------------------
# Still loading nodes.
# 3.  Groups originating from the SAS application
# 4.  ADGroups originating from Active Directory
#---------------------------------------------------------
# LOADING Groups
$CMD /opt/neo4j/stage/DataSource/LoadGroups.cql
sleep 90 # waiting for indexes to build
# LOADING ADGroups - Merge
# Groups should be a subset of ADGroups
$CMD /opt/neo4j/stage/DataSource/LoadADGroups.cql
sleep 90 # waiting for indexes to build
#---------------------------------------------------------
# Still loading nodes.
# 4.  Servers orginating from Active Directory
# 5.  Silos originating from SAS
#--------------------------------------------------------- 
# LOADING Servers
$CMD /opt/neo4j/stage/DataSource/LoadServers.cql
sleep 60 # waiting for indexes to build
# LOADING Silos
$CMD /opt/neo4j/stage/DataSource/LoadSilos.cql
sleep 60 # waiting for indexes to build
#---------------------------------------------------------
# Next we load the relationships
# 1.  Account member of Group
# 2.  Group member of Group
# 3.  Silo member of Group
# 4.  ADAccount member of Silo
# 5.  Account to Account relationships
# 6.  Group local admin of Server
#---------------------------------------------------------
# LOADING Group - Account Rels
$CMD /opt/neo4j/stage/DataSource/LoadADGroupAccountRels.cql
# LOADING Group - Group Rels
$CMD /opt/neo4j/stage/DataSource/LoadGroupGroupRels.cql
# LOADING Silo - Group Rels
$CMD /opt/neo4j/stage/DataSource/LoadSiloGroupRels.cql
# LOADING ADAccount - Silo Rels
$CMD /opt/neo4j/stage/DataSource/LoadADAccountSiloRels.cql
# LOADING Account - Account Rels
$CMD /opt/neo4j/stage/DataSource/LoadAccountAccountRels.cql
# LOADING Group - Server Rels
$CMD /opt/neo4j/stage/DataSource/LoadGroupServerRels.cql
