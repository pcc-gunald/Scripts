DECLARE @srcFacID VARCHAR(100)
	,@dstFacID VARCHAR(100)
	,@srcServer VARCHAR(500)
	,@dstServer VARCHAR(500)
	,@SQL VARCHAR(max)
	,@dischargedate  VARCHAR(MAX);

BEGIN
	SET @srcFacID = 1
	SET @dstFacID = 13
	SET @srcServer = '[pccsql-use2-prod-w23-cli0020.4ccb146400ac.database.windows.net].[us_acac]'
	SET @dstServer = '[pccsql-use2-prod-w20-cli0018.3055e0bc69f6.database.windows.net].[us_khg_multi]'
	SET @dischargedate = '''2021-10-21'''

	SET @SQL = 'SELECT * FROM ('
	SET @SQL = @SQL + '

SELECT src.description AS srcDescription
	,src.payer_id AS srcPayerID
	,src_payer_type
	,src_payer_code
	,src_payer_code2
	,src_Care_Level_Template
	,space(0) as Map_dstPayerID
	,dst.description AS dstDescription
	,dst.payer_id AS dstPayerID
	,dst_payer_type
	,dst_payer_code
	,dst_payer_code2
	,dst_Care_Level_Template
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
	
	and ar_lib_payers.payer_id IN (
		SELECT primary_payer_id
		FROM ' + @srcServer + '.dbo.census_item
		WHERE client_id IN (
				SELECT client_id
				FROM ' + @srcServer + '.dbo.clients
				WHERE fac_id IN (' + @srcFacID + ') 
					AND (
						discharge_date IS NULL
						OR  discharge_date >= CONVERT(DATETIME,' + @dischargedate + ', 120)
						)
					AND admission_Date IS NOT NULL
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


UNION


SELECT src.description AS srcDescription
	,src.payer_id AS srcPayerID
	,src_payer_type
	,src_payer_code
	,src_payer_code2
	,src_Care_Level_Template
	,space(0) as Map_dstPayerID
	,dst.description AS dstDescription
	,dst.payer_id AS dstPayerID
	,dst_payer_type
	,dst_payer_code
	,dst_payer_code2
	,dst_Care_Level_Template
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



	and ar_lib_payers.payer_id IN (
		SELECT primary_payer_id
		FROM ' + @srcServer + '.dbo.census_item
		WHERE client_id IN (
				SELECT client_id
				FROM ' + @srcServer + '.dbo.clients
				WHERE fac_id IN (' + @srcFacID + ') 
					AND (
						discharge_date IS NULL
							OR  discharge_date >= CONVERT(DATETIME,' + @dischargedate + ', 120)
						)
					AND admission_Date IS NOT NULL
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
	
	
	) tmp
ORDER BY ISNULL(srcDescription, ''zzzzzzzzzzzzzzzzz'')'

	--print @SQL
	EXEC (@SQL);
END

