SELECT long_description src_long_Description, short_description src_short_Description, rate_type_id srcRateTypeID, IDENTITY(INT, 0, 1) rownum
INTO #src_room_rate FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.ar_lib_rate_type WITH (NOLOCK)
WHERE deleted = 'N' AND rate_type_id IN (SELECT rate_type_id FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.room_date_range WITH (NOLOCK) WHERE room_id IN (SELECT room_id FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.room WITH (NOLOCK) WHERE fac_id IN (183)))
ORDER BY 1,2

SELECT long_description dst_long_Description, short_description dst_short_Description, rate_type_id dstRateTypeID, IDENTITY(INT, 0, 1) rownum
INTO #dst_room_rate FROM [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi.dbo.ar_lib_rate_type WITH (NOLOCK)
WHERE deleted = 'N' and (fac_id in (-1,173) or reg_id = 1)
ORDER BY 1,2

SELECT src_long_Description, src_short_Description, srcRateTypeID , '' AS Map_dstRateTypeID , dst_long_Description , dst_short_Description , dstRateTypeID
FROM #src_room_rate AS src FULL JOIN #dst_room_rate AS dst ON src.rownum = dst.rownum
ORDER BY ISNULL(src.rownum, 99999), dst.rownum