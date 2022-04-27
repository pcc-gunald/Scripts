SET QUOTED_IDENTIFIER ON
DROP TABLE IF EXISTS #Temp_order
SELECT src.std_order_id,src.template_description,NEW_template_description=CONCAT(src.template_description,'__')
INTO #Temp_order
FROM dbo.pho_std_order src
JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1062.dbo.pho_std_order dst ON src.template_description = dst.template_description
WHERE src.fac_id IN (
		- 1
		,2
		)
	AND (
		src.STATUS <> dst.STATUS
		OR dst.fac_id <> - 1
		)
AND EXISTS (SELECT 1 FROM dbo.pho_std_order  A WHERE A.template_description=CONCAT(src.template_description,'_')
AND A.for_mobile=src.for_mobile
)
ORDER BY CONCAT(src.template_description,'_')


UPDATE B
SET template_description=NEW_template_description
FROM #Temp_order  A
INNER JOIN  dbo.pho_std_order B ON B.std_order_id=A.std_order_id
;
