using periodic commit 10000 load csv from 'file:///opt/neo4j/stage/DataSource/Group.csv' as line Fieldterminator '^'  Create (g:Group {GroupAlias: line[0], GroupAliasDisplayName: line[1]});
create index on :Group(GroupAlias);
MATCH (g:Group) set g :SASGroup;
