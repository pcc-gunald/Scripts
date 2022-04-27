SELECT 'usei1214' AS OrgCode --dest test orgcode
	,Name
	--,b.short_desc AS health_type
	,a.health_type AS health_type
	,fac_id
	,prov
	,month(getdate()) AS 'AR Month'
	,year(getdate()) AS 'AR Year'
	,'12' AS 'Fiscal Year End'
	,'N' AS Use1099 -- dont change
	,'59277183' --case number
	,fac_id
	,address1
	,address2
	,city
FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.facility a
--JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.regions b ON a.regional_id = b.regional_id
WHERE fac_id IN (183) -- src facid