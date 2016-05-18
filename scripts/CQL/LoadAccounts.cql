using periodic commit 100 load csv from 'file:///opt/neo4j/stage/DataSource/Account.csv' as line Fieldterminator '^'  Merge (a:ADAccount {AccountAlias: line[0], AccountAliasDisplayName: line[1]})
on MATCH set a :Account, a.AccountFullName=line[2], a.AccountEmail=line[3]
on CREATE set a :Account, a.AccountFullName=line[2];
CREATE INDEX on :Account(AccountAlias);