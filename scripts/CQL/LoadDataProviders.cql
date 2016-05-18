LOAD CSV from 'file:///opt/neo4j/stage/DataSource/DataProvider.csv' as line Fieldterminator '^'  Create (p:DataProvider {DataProviderAlias: line[0]});
create index on :DataProvider(DataProviderAlias);
