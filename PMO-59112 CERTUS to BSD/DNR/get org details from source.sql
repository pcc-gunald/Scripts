/*
Update query as follows:
-- test destination test org...usei26 in this case
-- update case and facs too
-- update from & join to point to test source org
*/

select 'usei1173',name,b.short_desc as health_type,fac_id,prov,month(getdate()),year(getdate()),
'12','N','EICase5911212',fac_id,address1,address2,city
from [pccsql-use2-prod-w30-cli0021.cbafa2b80e84.database.windows.net].[us_certus_multi].dbo.facility a --src prod or test
join [pccsql-use2-prod-w30-cli0021.cbafa2b80e84.database.windows.net].[us_certus_multi].dbo.regions b on a.regional_id = b.regional_id
where fac_id in (12)

/*
Execute and paste the above results in spreadsheet then import into dsh
*/