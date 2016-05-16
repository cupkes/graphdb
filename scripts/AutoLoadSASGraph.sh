#!/bin/bash -e
#!/usr/bin/env NEO4J_HOME
#
# Script for loading SAS Graph
###########################################
#exec 1> >(logger -s -t $(basename $0)) 2>&1
NEO4J_HOME="/opt/neo4j/neo4j-enterprise-2.3.3"
CMD="$NEO4J_HOME/bin/neo4j-shell -file"
# LOADING ADAccounts
$CMD /opt/neo4j/stage/DataSource/LoadADAccounts.cql
# LOADING Accounts
$CMD /opt/neo4j/stage/DataSource/LoadAccounts.cql
# LOADING Groups
$CMD /opt/neo4j/stage/DataSource/LoadGroups.cql
# LOADING ADGroups
$CMD /opt/neo4j/stage/DataSource/LoadADGroups.cql
# LOADING Servers
$CMD /opt/neo4j/stage/DataSource/LoadServers.cql
# LOADING Silos
$CMD /opt/neo4j/stage/DataSource/LoadSilos.cql
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
