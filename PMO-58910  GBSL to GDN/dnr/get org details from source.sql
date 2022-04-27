/*
Update query as follows:
-- test destination test org...usei26 in this case
-- update case and facs too
-- update from & join to point to test source org
*/

select 'usei968',name,b.short_desc as health_type,fac_id,prov,month(getdate()),year(getdate()),
'12','N','EICase58516CHP',fac_id,address1,address2,city
from [pccsql-use2-prod-w24-cli0026.ce22455c967a.database.windows.net].us_chp_multi.dbo.facility a --src prod or test
join [pccsql-use2-prod-w24-cli0026.ce22455c967a.database.windows.net].us_chp_multi.dbo.regions b on a.regional_id = b.regional_id
where fac_id in (5, 11, 18, 19, 20, 21, 22, 26, 27, 28)

/*
Execute and paste the above results in spreadsheet then import into dsh
*/