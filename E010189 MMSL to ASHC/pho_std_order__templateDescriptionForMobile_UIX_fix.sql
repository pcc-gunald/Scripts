SET QUOTED_IDENTIFIER ON
DROP TABLE IF EXISTS #Temp_order
SELECT src.std_order_id,src.template_description,NEW_template_description=CONCAT(src.template_description,'_')
INTO #Temp_order
FROM dbo.pho_std_order src
JOIN [pccsql-use2-prod-w22-cli0013.4c4638f8e26f.database.windows.net].[us_ashc_multi].dbo.pho_std_order dst ON src.template_description = dst.template_description
WHERE src.fac_id IN (
		- 1
		,11
		)
	--AND (
	--	src.STATUS <> dst.STATUS
	--	OR dst.fac_id <> - 1
	--	)
--AND EXISTS (SELECT 1 FROM dbo.pho_std_order  A WHERE A.template_description=CONCAT(src.template_description,'_')
--AND A.for_mobile=src.for_mobile
--)
ORDER BY CONCAT(src.template_description,'_')


UPDATE B
SET template_description=NEW_template_description
FROM #Temp_order  A
INNER JOIN  dbo.pho_std_order B ON B.std_order_id=A.std_order_id
;

select *
FROM #Temp_order  A
INNER JOIN  dbo.pho_std_order B ON B.std_order_id=A.std_order_id
where b.template_description in('May have alcohol once a week_','Fleet Enema')

select * from dbo.pho_std_order 

Divalproex Sodium (Depakote) 500mg PO TID_

select * from pho_std_order
where template_description in('May have alcohol once a week_','Fleet Enema')

select * from [pccsql-use2-prod-w26-cli0006.d9c23db323d7.database.windows.net].[us_mmsl_multi].dbo.pho_std_order
where template_description in('May have alcohol once a week','Fleet Enema')


