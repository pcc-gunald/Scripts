/*
Update query as follows:
-- test destination test org...usei26 in this case
-- update case and facs too
-- update from & join to point to test source org
*/

select 'usei1015',name,b.short_desc as health_type,fac_id,prov,month(getdate()),year(getdate()),
'12','N','EICase007858SERET',fac_id,address1,address2,city
from [pccsql-use2-prod-w19-cli0006.3055e0bc69f6.database.windows.net].[us_seret_multi].dbo.facility a --src prod or test
join [pccsql-use2-prod-w19-cli0006.3055e0bc69f6.database.windows.net].[us_seret_multi].dbo.regions b on a.regional_id = b.regional_id
where fac_id in (2)

/*
Execute and paste the above results in spreadsheet then import into dsh
*/



