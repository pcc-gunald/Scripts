/*************************************************
Payer All Residents Mapping

-----------------------SCOPE--------------------------
-- This script pulls Payer Information from the ar_lib_payers table for mapping by the Admin Implementater. 
-- Payer Details can be found on the front end at
Facility Level > Admin > Setup > Billing Setup > Payers
EMC > Standards > Financial Mangement > Billing Setup > Payers


--------------------INSTRUCTIONS------------------------
Fill the following fields and then paste the output to Payers tab of the excel file found at 
\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_Scripts\EI_SCRIPTS\Pre_EI Scripts\Template Files\Payer Census Codes Room Rate Type Mapping Template.xlsx

If you are doing a multi-fac project create a separate Payer tab named uniquely for each facility

1. @srcFacID - source facility id 
2. @dstFacID - destination facility id
3. @srcServer - connection string for the source production DB 
4. @dstServer - connection string for the source destination DB (example: '[pccsql-use2-prod-w28-cli0007.874bf44c721a.database.windows.net].us_swc_multi')


**************************************************/

DECLARE @srcFacID VARCHAR(100)		=	'20' --example : 1
		,@dstFacID VARCHAR(100)		=	'15' --example : 2
		,@srcServer VARCHAR(500)	=	'[pccsql-use2-prod-w26-cli0028.d9c23db323d7.database.windows.net].us_hhi_multi' --example: '[pccsql-use2-prod-w19-cli0012.3055e0bc69f6.database.windows.net].us_elvt_multi'
		,@dstServer VARCHAR(500)	=	'[pccsql-use2-prod-w20-cli0009.3055e0bc69f6.database.windows.net].us_tranq_multi' --example: '[pccsql-use2-prod-w28-cli0007.874bf44c721a.database.windows.net].us_swc_multi'
		,@SQL VARCHAR(max)

-------------DO NOT CHANGE ANYTHING BELOW THIS LINE--------------
SET @SQL = '

drop table if exists ##temp_payers_1, ##temp_payers_2

SELECT src.description AS srcDescription
	,src.payer_id AS srcPayerID
	,src_payer_type
	,src_payer_code
	,src_payer_code2
	,src_Care_Level_Template
	,'''' as Map_dstPayerID
	,dst.description AS dstDescription
	,dst.payer_id AS dstPayerID
	,dst_payer_type
	,dst_payer_code
	,dst_payer_code2
	,dst_Care_Level_Template INTO ##temp_payers_1
FROM 
	(SELECT row_number() OVER (ORDER BY ar_lib_payers.description) AS rNo
		,ar_lib_payers.fac_id
		,ar_lib_payers.payer_id
		,ar_lib_payers.description
		,ar_lib_payers.payer_type src_payer_type
		,isnull(ar_lib_payers.payer_code, '''') AS src_payer_code
		,isnull(ar_lib_payers.payer_code2, '''') AS src_payer_code2
		,isnull(d.template_name, '''') AS src_Care_Level_Template
	FROM ' + @srcServer + '.dbo.ar_lib_payers with (nolock) 
	LEFT JOIN ' + @srcServer + '.dbo.AR_PAYER_CARE_LEVEL c with (nolock) ON c.payer_id = ar_lib_payers.payer_id
	LEFT JOIN ' + @srcServer + '.dbo.AR_LIB_CARE_LEVEL_TEMPLATE d with (nolock) ON c.CARE_LEVEL_TEMPLATE_ID = d.CARE_LEVEL_TEMPLATE_ID
	WHERE ar_lib_payers.deleted = ''N''
		AND ar_lib_payers.payer_id IN (SELECT DISTINCT primary_payer_id FROM ' + @srcServer + '.dbo.census_item with (nolock) WHERE fac_id in (' + @srcFacID + ') )
		AND ((ar_lib_payers.fac_id in (' + @srcFacID + ')  OR ar_lib_payers.fac_id = -1)
			OR (ar_lib_payers.reg_id IN (SELECT distinct regional_id FROM ' + @srcServer + '.dbo.facility with (nolock) WHERE fac_id in (' + @srcFacID + 
		') ) AND ar_lib_payers.state_code IS NULL)
			OR (ar_lib_payers.state_code IN (SELECT distinct prov FROM ' + @srcServer + '.dbo.facility with (nolock) WHERE fac_id in (' + @srcFacID + ') )
				AND (ar_lib_payers.reg_id IN (SELECT distinct regional_id FROM ' + @srcServer + '.dbo.facility with (nolock) WHERE fac_id in (' + @srcFacID + ') ) 
					OR ar_lib_payers.reg_id IS NULL
					OR ar_lib_payers.reg_id = - 1)
				)
			)
	) src
LEFT JOIN 
	(SELECT row_number() OVER (ORDER BY ar_lib_payers.description) AS rNo
		,ar_lib_payers.fac_id
		,ar_lib_payers.payer_id
		,ar_lib_payers.description
		,ar_lib_payers.payer_type dst_payer_type
		,isnull(ar_lib_payers.payer_code, '''') AS dst_payer_code
		,isnull(ar_lib_payers.payer_code2, '''') AS dst_payer_code2
		,isnull(d.template_name, '''') AS dst_Care_Level_Template
	FROM ' + @dstServer + '.dbo.ar_lib_payers with (nolock)
	LEFT JOIN ' + @dstServer + '.dbo.AR_PAYER_CARE_LEVEL c with (nolock) ON c.payer_id = ar_lib_payers.payer_id
	LEFT JOIN ' + @dstServer + '.dbo.AR_LIB_CARE_LEVEL_TEMPLATE d  with (nolock) ON c.CARE_LEVEL_TEMPLATE_ID = d.CARE_LEVEL_TEMPLATE_ID
	WHERE	ar_lib_payers.deleted = ''N''
			AND ar_lib_payers.pri_sec_payer <> ''S''
			AND	(	(ar_lib_payers.fac_id in (' + @dstFacID + ')  OR ar_lib_payers.fac_id = - 1)
					OR (ar_lib_payers.reg_id IN (SELECT DISTINCT regional_id FROM ' + @dstServer + '.dbo.facility with (nolock) WHERE fac_id in (' + @dstFacID + ') ) AND ar_lib_payers.state_code IS NULL)
					OR (ar_lib_payers.state_code IN (SELECT DISTINCT prov FROM ' + @dstServer + '.dbo.facility with (nolock) WHERE fac_id in (' + @dstFacID + ') ) 
						AND (ar_lib_payers.reg_id IN (SELECT DISTINCT regional_id FROM ' + @dstServer + '.dbo.facility with (nolock) WHERE fac_id in (' + @dstFacID + 
		') ) 
							OR ar_lib_payers.reg_id IS NULL 
							OR ar_lib_payers.reg_id = - 1))
				)
	) dst ON src.rNo = dst.rNo

'
--PRINT @SQL
EXEC(@SQL)


SET @SQL = '

SELECT src.description AS srcDescription
	,src.payer_id AS srcPayerID
	,src_payer_type
	,src_payer_code
	,src_payer_code2
	,src_Care_Level_Template
	,'''' as Map_dstPayerID
	,dst.description AS dstDescription
	,dst.payer_id AS dstPayerID
	,dst_payer_type
	,dst_payer_code
	,dst_payer_code2
	,dst_Care_Level_Template INTO ##temp_payers_2
FROM 
	(SELECT row_number() OVER (ORDER BY ar_lib_payers.description) AS rNo
		,ar_lib_payers.fac_id
		,ar_lib_payers.payer_id
		,ar_lib_payers.description
		,ar_lib_payers.payer_type as src_payer_type
		,isnull(ar_lib_payers.payer_code, '''') AS src_payer_code
		,isnull(ar_lib_payers.payer_code2, '''') AS src_payer_code2
		,isnull(d.template_name, '''') AS src_Care_Level_Template
	FROM ' + @srcServer + '.dbo.ar_lib_payers with (nolock)
	LEFT JOIN ' + @srcServer + '.dbo.AR_PAYER_CARE_LEVEL c with (nolock) ON c.payer_id = ar_lib_payers.payer_id
	LEFT JOIN ' + @srcServer + '.dbo.AR_LIB_CARE_LEVEL_TEMPLATE d with (nolock) ON c.CARE_LEVEL_TEMPLATE_ID = d.CARE_LEVEL_TEMPLATE_ID
	WHERE ar_lib_payers.deleted = ''N'' 
		AND ar_lib_payers.payer_id IN (SELECT DISTINCT primary_payer_id FROM ' + @srcServer + '.dbo.census_item	with (nolock) WHERE fac_id in (' + @srcFacID + ') )
		AND (	(ar_lib_payers.fac_id in (' + @srcFacID + ')  OR ar_lib_payers.fac_id = - 1)
				OR (ar_lib_payers.reg_id IN (SELECT DISTINCT regional_id	FROM ' + @srcServer + '.dbo.facility with (nolock) WHERE fac_id in (' + @srcFacID + ') ) AND ar_lib_payers.state_code IS NULL)
				OR (ar_lib_payers.state_code IN (SELECT DISTINCT prov FROM ' + @srcServer + '.dbo.facility with (nolock) WHERE fac_id in (' + @srcFacID + ') ) 
					AND (ar_lib_payers.reg_id IN (SELECT DISTINCT regional_id FROM ' + @srcServer + '.dbo.facility with (nolock) WHERE fac_id in (' + @srcFacID + 
		') ) 
						OR ar_lib_payers.reg_id IS NULL
						OR ar_lib_payers.reg_id = - 1)
					)
			)
	) src

RIGHT JOIN 
	(SELECT row_number() OVER (ORDER BY ar_lib_payers.description) AS rNo
		,ar_lib_payers.fac_id
		,ar_lib_payers.payer_id
		,ar_lib_payers.description
		,ar_lib_payers.payer_type as dst_payer_type
		,isnull(ar_lib_payers.payer_code, '''') AS dst_payer_code
		,isnull(ar_lib_payers.payer_code2, '''') AS dst_payer_code2
		,isnull(d.template_name, '''') AS dst_Care_Level_Template
	FROM ' + @dstServer + '.dbo.ar_lib_payers with (nolock)
	LEFT JOIN ' + @dstServer + '.dbo.AR_PAYER_CARE_LEVEL c with (nolock) ON c.payer_id = ar_lib_payers.payer_id
	LEFT JOIN ' + @dstServer + '.dbo.AR_LIB_CARE_LEVEL_TEMPLATE d with (nolock) ON c.CARE_LEVEL_TEMPLATE_ID = d.CARE_LEVEL_TEMPLATE_ID

WHERE	ar_lib_payers.deleted = ''N''
			AND ar_lib_payers.pri_sec_payer <> ''S''
			AND (	(ar_lib_payers.fac_id in (' + @dstFacID + ')  OR ar_lib_payers.fac_id = - 1)
					OR (ar_lib_payers.reg_id IN (SELECT DISTINCT regional_id FROM ' + @dstServer + '.dbo.facility with (nolock) WHERE fac_id in (' + @dstFacID + ') )
						AND ar_lib_payers.state_code IS NULL)
					OR (ar_lib_payers.state_code IN (SELECT DISTINCT prov FROM ' + @dstServer + '.dbo.facility with (nolock) WHERE fac_id in (' + @dstFacID + ') )
						AND ( ar_lib_payers.reg_id IN (SELECT DISTINCT regional_id	FROM ' + @dstServer + '.dbo.facility with (nolock) WHERE fac_id in (' + @dstFacID + ') )
							OR ar_lib_payers.reg_id IS NULL
							OR ar_lib_payers.reg_id = - 1
							)
						)
				)
	) dst ON src.rNo = dst.rNo 
	
SELECT * FROM(
SELECT * FROM ##temp_payers_1
union
SELECT * FROM ##temp_payers_2) a
ORDER BY ISNULL(srcDescription, ''zzzzzzzzzzzzzzzzz'')
'
--PRINT @SQL
EXEC (@SQL)

