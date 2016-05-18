#!/bin/bash -e
#!/usr/bin/env NEO4J_HOME
#
# Script for managing Neo4j Backup Files
###########################################
NEO4J_HOME="/opt/neo4j/neo4j-enterprise-2.3.3"
CMD="$NEO4J_HOME/bin/neo4j-shell -file"
echo "LOADING DATA PROVIDERS\n"
$CMD /opt/neo4j/stage/DataSource/LoadDataProviders.cql
echo "LOADING DATA ENTITIES\n"
$CMD /opt/neo4j/stage/DataSource/LoadDataEntities.cql
echo "LOADING DATA ENTITY ATTRIBUTES\n"
$CMD /opt/neo4j/stage/DataSource/LoadDataEntityAttributes.cql
echo "LOADING DATA PROVIDER - ENTITY RELS\n"
$CMD /opt/neo4j/stage/DataSourcea/LoadProviderEntityRels.cql
echo "LOADING DATA ENTITY - ATTRIBUTE RELS\n"
$CMD /opt/neo4j/stage/DataSource/LoadEntityAttributeRels.cql

