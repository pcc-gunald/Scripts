SELECT long_desc AS src_long_desc , short_desc AS src_short_desc , item_id AS src_item_id , IDENTITY(INT, 0, 1) AS rownum
INTO #src_actions FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.census_codes WITH (NOLOCK)
WHERE (fac_id IN (-1,183) OR 
		reg_id IN (SELECT regional_id FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.facility WITH (NOLOCK) WHERE fac_id IN (183) AND regional_id IS NOT NULL))
	AND deleted = 'N'
	AND table_code = 'ACT'
	AND item_id IN ((SELECT isnull(action_code_id, - 1) FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.census_item WITH (NOLOCK) WHERE fac_id IN (183) AND DELETED = 'N') UNION (SELECT isnull(STATUS_CODE_ID, - 1) FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.census_item WITH (NOLOCK) WHERE fac_id IN (183) AND DELETED = 'N'))
ORDER BY long_desc

SELECT item_id AS dst_item_id , short_desc AS dst_short_desc , long_desc AS dst_long_desc , IDENTITY(INT, 0, 1) AS rownum
INTO #dst_actions FROM [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi.dbo.census_codes WITH (NOLOCK) 
WHERE (fac_id IN (-1,173)
		OR reg_id IN (SELECT regional_id FROM [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi.dbo.facility WITH (NOLOCK) WHERE fac_id IN (173) AND regional_id IS NOT NULL))
	AND deleted = 'N'
	AND table_code = 'ACT'
ORDER BY long_desc

SELECT src_long_desc , src_short_desc , src_item_id , '' AS Map_dstItemID , dst_item_id , dst_short_desc , dst_long_desc
FROM #src_actions AS src FULL JOIN #dst_actions AS dst ON src.rownum = dst.rownum
ORDER BY ISNULL(src.rownum, 99999), dst.rownum