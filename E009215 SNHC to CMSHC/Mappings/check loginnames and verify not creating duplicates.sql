-- update src, dst and fac_id for all queries
-- update suffix in line 14

/*
Step 1 - Store the usernames you plan to create in dest
*/
drop table if exists #temp_dupusers

SELECT src.fac_id AS 'srcFacID'
	,src.long_username AS 'srcUsername'
	,src.loginname AS 'srcLoginname'
	,dst.long_username AS 'dstUsername'
	,dst.loginname AS 'dstLoginname'
	,left(dst.loginname, 60-len('SNHC'))  + 'SNHC' AS 'dstNewLoginname'  -- update suffix to be used...org code, number, or whatever else the client has decided
INTO #temp_dupusers
FROM [pccsql-use2-prod-w21-cli0001.f352397924df.database.windows.net].[us_snhc_multi].dbo.sec_user src -- update src server & org
JOIN [pccsql-use2-prod-w21-cli0002.f352397924df.database.windows.net].[us_cmshc_multi].dbo.sec_user dst ON src.loginname = dst.loginname -- update dst server & org
	AND src.long_username <> dst.long_username
	AND src.fac_id IN (48,53,72,87,88) -- update fac_ids


/*
Step 2 - Determine if there are already those loginnames in dest
- if any rows are returned by this query, repeat Step 1 with a different suffix 
- repeat until this query doesn't return any users
*/
select 'CREATING THE FOLLOWING DUPLICATES...CHOOSE A NEW SUFFIX','','',''
union
select
	src.srcUsername
	,src.srcLoginname
	,dst.long_username AS 'dstUsername'
	,dst.loginname AS 'dstLoginname'
from #temp_dupusers src
JOIN [pccsql-use2-prod-w21-cli0002.f352397924df.database.windows.net].[us_cmshc_multi].dbo.sec_user dst ON src.dstNewLoginname = dst.loginname -- update dst server & org
order by 2

/*
Step 3 - Once you've found a suffix that doesn't create duplicates, execute this and copy the results into a new spreadsheet on your local machine
*/

SELECT src.fac_id AS 'Fac ID in SNHC' -- update field name
	,src.long_username AS 'long_username in SNHC' -- update field name
	,src.loginname AS 'loginname in SNHC' -- update field name
	,left(src.loginname, 60 - len('SNHC')) + 'SNHC' AS 'new loginname in CMSHC' -- update field name
FROM [pccsql-use2-prod-w21-cli0001.f352397924df.database.windows.net].[us_snhc_multi].dbo.sec_user src -- update src server & db
JOIN [pccsql-use2-prod-w21-cli0002.f352397924df.database.windows.net].[us_cmshc_multi].dbo.sec_user dst ON src.loginname = dst.loginname -- update dst server & db
	AND src.long_username <> dst.long_username
	AND src.fac_id IN (48,53,72,87,88) -- update fac ids


