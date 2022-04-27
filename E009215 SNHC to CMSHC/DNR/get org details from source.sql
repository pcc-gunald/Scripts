/*
Update query as follows:
-- test destination test org...usei26 in this case
-- update case and facs too
-- update from & join to point to test source org
*/

select 'usei41',name,b.short_desc as health_type,fac_id,prov,month(getdate()),year(getdate()),
'12','N','EICase009215',fac_id,address1,address2,city
from [pccsql-use2-prod-w21-cli0001.f352397924df.database.windows.net].[us_snhc_multi].dbo.facility a --src prod or test
join [pccsql-use2-prod-w21-cli0001.f352397924df.database.windows.net].[us_snhc_multi].dbo.regions b on a.regional_id = b.regional_id
where fac_id in (48,53,72,87,88)

/*
Execute and paste the above results in spreadsheet then import into dsh
*/

--Whispering Oak Place (snhc-48)->86
--Garden View Place (snhc-53)->87
--Apple Creek Place (snhc-72)->88
--Arbor Garden Place (snhc-87)->89
--Harmony Place (snhc-88)->90