using periodic commit 10000 load csv from 'file:///opt/neo4j/stage/DataSource/PK_Groups.csv' as line Fieldterminator '^'  MERGE (g:Group {GroupAlias: line[0]})
ON MATCH set g :ADGroup, g.GroupName=line[2]
ON CREATE set g :ADGroup, g.GroupAliasDisplayName=line[1], g.GroupName=line[2];
create index on :ADGroup(GroupAlias);
