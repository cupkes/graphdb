LOAD CSV from 'file:///opt/neo4j/stage/DataSource/DataEntityAttribute.csv' as line Fieldterminator '^'  Create (a:DataEntityAttribute {DataEntityAttributeAlias: line[0], Description: line[1]});
create index on :DataEntityAttribute(DataEntityAttributeAlias);
