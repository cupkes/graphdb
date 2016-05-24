USING PERIODIC COMMIT 10000 LOAD CSV from 'file:///opt/neo4j/stage/DataSource/PK_Accounts.csv' as line Fieldterminator '^'  Create (a:ADAccount {AccountAlias: line[0], AccountAliasDisplayName: line[1], AccountEmail: line[2], AccountType: line[3]});
create index on :ADAccount(AccountAlias);
