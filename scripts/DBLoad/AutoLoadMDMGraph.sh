#!/bin/bash -e
#!/usr/bin/env NEO4J_HOME
#
# Script for loading MDM Graph
###########################################
#exec 1> >(logger -s -t $(basename $0)) 2>&1
NEO4J_HOME="/opt/neo4j/neo4j-enterprise-2.3.3"
CMD="$NEO4J_HOME/bin/neo4j-shell -file"
# LOADING DATA PROVIDERS
$CMD /opt/neo4j/stage/DataSource/LoadDataProviders.cql
# LOADING DATA ENTITIES
$CMD /opt/neo4j/stage/DataSource/LoadDataEntities.cql
# LOADING DATA ENTITY ATTRIBUTES
$CMD /opt/neo4j/stage/DataSource/LoadDataEntityAttributes.cql
# LOADING DATA PROVIDER - ENTITY RELS
$CMD /opt/neo4j/stage/DataSourcea/LoadProviderEntityRels.cql
# LOADING DATA ENTITY - ATTRIBUTE RELS
$CMD /opt/neo4j/stage/DataSource/LoadEntityAttributeRels.cql

