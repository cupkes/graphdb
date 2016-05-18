LOAD CSV from 'file:///opt/neo4j/stage/DataSource/DataEntity.csv' as line Fieldterminator '^'  Create (e:DataEntity {DataEntityAlias: line[0]});
create index on :DataEntity(DataEntityAlias);
