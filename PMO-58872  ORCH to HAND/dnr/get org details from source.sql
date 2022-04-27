/*
Update query as follows:
-- test destination test org...usei26 in this case
-- update case and facs too
-- update from & join to point to test source org
*/

select 'usei587',name,b.short_desc as health_type,fac_id,prov,month(getdate()),year(getdate()),
'12','N','EICase58872',fac_id,address1,address2,city
from [pccsql-use2-prod-w27-cli0023.851c37dfbe45.database.windows.net].[us_orch_multi].dbo.facility a --src prod or test
join [pccsql-use2-prod-w27-cli0023.851c37dfbe45.database.windows.net].[us_orch_multi].dbo.regions b on a.regional_id = b.regional_id
where fac_id in (6)

/*
Execute and paste the above results in spreadsheet then import into dsh
*/