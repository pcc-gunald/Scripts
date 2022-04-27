/*************************************************
R1 Admin - Room Rate Type Mapping

-----------------------SCOPE--------------------------
-This script pulls Room Rate Types from the ar_lib_rate_type table for mapping by the admin implementer
-Room Rate Types can be found on the front end at either
Facility Level > Admin > Setup > Billing Setup > Room Rate Types
EMC > Standards > Financial Management > Billing Setup > Room Rate Types

--------------------INSTRUCTIONS------------------------

Fill the following fields and then paste the output to the RoomRateType tab of excel file found at 
\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_Scripts\EI_SCRIPTS\Pre_EI Scripts\Template Files\Payer Census Codes Room Rate Type Mapping Template.xlsx

1. @srcFacIDs - comma separated string of facility ids from source
2. @dstFacIDs - comma separated string of facility ids from destination
3  @regIDsto - comma separated string of region ids 
4. @srcServer -connection string for the source production DB 
5. @dstServer - connection string for the source destination DB 

**************************************************/

DECLARE @srcFacIDs VARCHAR(100)		=	'1,2,5' -- example: '1,2,3'
		,@dstFacIDs VARCHAR(100)	=	'192,193,194' --example: '1,2,3'
		,@regIDs VARCHAR(100)       =   '1,2' --example: '1,2'
		,@srcServer VARCHAR(500)	=	'[pccsql-use2-prod-w24-cli0019.ce22455c967a.database.windows.net].[us_prqc_multi]' --example: '[pccsql-use2-prod-w19-cli0012.3055e0bc69f6.database.windows.net].us_elvt_multi'
		,@dstServer VARCHAR(500)	=	'[pccsql-use2-prod-w22-cli0007.4c4638f8e26f.database.windows.net].[us_dhm_multi]' --example: '[pccsql-use2-prod-w28-cli0007.874bf44c721a.database.windows.net].us_swc_multi'
		,@SQL VARCHAR(MAX)

set @SQL = 

'SELECT long_description src_long_Description, short_description src_short_Description, rate_type_id srcRateTypeID, IDENTITY(INT, 0, 1) rownum
INTO #src_room_rate FROM '+@srcServer+'.dbo.ar_lib_rate_type WITH (NOLOCK)
WHERE deleted = ''N'' AND rate_type_id IN (SELECT rate_type_id FROM '+@srcServer+'.dbo.room_date_range WITH (NOLOCK) WHERE room_id IN (SELECT room_id FROM '+@srcServer+'.dbo.room WITH (NOLOCK) WHERE fac_id IN ('+@srcFacIDs+')))
ORDER BY 1,2

SELECT long_description dst_long_Description, short_description dst_short_Description, rate_type_id dstRateTypeID, IDENTITY(INT, 0, 1) rownum
INTO #dst_room_rate FROM '+@dstServer+'.dbo.ar_lib_rate_type WITH (NOLOCK)
WHERE deleted = ''N'' and (fac_id in (-1,'+@dstFacIDs+') or reg_id in('+@regIDs+'))
ORDER BY 1,2

SELECT src_long_Description, src_short_Description, srcRateTypeID , '''' AS Map_dstRateTypeID , dst_long_Description , dst_short_Description , dstRateTypeID
FROM #src_room_rate AS src FULL JOIN #dst_room_rate AS dst ON src.rownum = dst.rownum
ORDER BY ISNULL(src.rownum, 99999), dst.rownum'

exec(@SQL)