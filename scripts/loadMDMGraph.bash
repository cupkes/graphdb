#!/bin/bash -e
#
# Script for managing Neo4j Backup Files
###########################################
echo "neo4j home is $NEO4J_HOME\n"
CMD = "$NEO4J_HOME/bin/neo4j-shell -file"
echo "LOADING DATA PROVIDERS\n"
$CMD /opt/neo4j/stage/DataSource/LoadDataProviders.cql
echo "LOADING DATA ENTITIES\n"
$CMD /opt/neo4j/stage/DataSource/LoadDataEntitiess.cql
echo "LOADING DATA ENTITY ATTRIBUTES\n"
$CMD /opt/neo4j/stage/DataSource/LoadDataEntityAttributes.cql
echo "LOADING DATA PROVIDER - ENTITY RELS\n"
$CMD /opt/neo4j/stage/DataSource/ProviderEntityRels.cql
echo "LOADING DATA ENTITY - ATTRIBUTE RELS\n"
$CMD /opt/neo4j/stage/DataSource/LoadEntityAttributeRels.cql