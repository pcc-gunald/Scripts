/*************************************************
Action Codes // Status Codes Mapping

-----------------------SCOPE--------------------------
-This script pulls Action Codes and Status Codes from the census_codes table for mapping by the Admin Implementater. 
-Status Codes and Action Codes can be found on the front end at either
Facility Level > Admin > Setup > Organization Setup > Pick Lists > Census Codes
EMC > Standards > Financial Management > General Setup > Pick Lists > Census Codes

--------------------INSTRUCTIONS------------------------
Fill the following fields and then paste the first output to the ActionCodes tab and the second output to the StatusCodes tab of excel file found at 
\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_Scripts\EI_SCRIPTS\Pre_EI Scripts\Template Files\Payer Census Codes Room Rate Type Mapping Template.xlsx

1. @srcFacIDs - comma separated string of facility ids from source
2. @dstFacIDs -comma separated string of facility ids from destination
3. @srcServer - connection string for the source production DB 
4. @dstServer - connection string for the source destination DB (example: '[pccsql-use2-prod-w28-cli0007.874bf44c721a.database.windows.net].us_swc_multi')


**************************************************/

DECLARE @srcFacIDs VARCHAR(100)		=	'20,21' --example : 1
		,@dstFacIDs VARCHAR(100)	=	'15,16' --example : 2
		,@srcServer VARCHAR(500)	=	'[pccsql-use2-prod-w26-cli0028.d9c23db323d7.database.windows.net].us_hhi_multi' --example: '[pccsql-use2-prod-w19-cli0012.3055e0bc69f6.database.windows.net].us_elvt_multi'
		,@dstServer VARCHAR(500)	=	'[pccsql-use2-prod-w20-cli0009.3055e0bc69f6.database.windows.net].us_tranq_multi' --example: '[pccsql-use2-prod-w28-cli0007.874bf44c721a.database.windows.net].us_swc_multi'
		,@SQL VARCHAR(MAX)

-------------DO NOT CHANGE ANYTHING BELOW THIS LINE--------------

set @SQL = '

---------------------
--Action Codes
---------------------
--src
drop table if exists #tempSrcActCodes, #tempDstActCodes
select long_desc as src_long_desc, short_desc as src_short_desc, item_id as src_item_id 
,rn = row_number() over(order by short_desc)
into #tempSrcActCodes
from '+@srcServer+'.dbo.census_codes with (nolock)
where (fac_id in (-1,'+@srcFacIDs+')  --src fac_id
	or reg_id in (select regional_id from '+@srcServer+'.dbo.facility with (nolock) 
		where fac_id in ('+@srcFacIDs+') and regional_id is not null)) --src fac_id
AND deleted = ''N''
AND table_code = ''ACT''
AND item_id in  
		((SELECT isnull(action_code_id,-1) FROM '+@srcServer+'.[dbo].census_item with (nolock) 
		WHERE fac_id in ('+@srcFacIDs+') AND DELETED = ''N'')  --src fac_id
		UNION 
		(SELECT isnull(STATUS_CODE_ID,-1) FROM '+@srcServer+'.[dbo].census_item with (nolock) 
		WHERE fac_id in ('+@srcFacIDs+') AND DELETED = ''N'')) --src fac_id
order by 2

--dst
select item_id as dst_item_id, short_desc as dst_short_desc, long_desc as dst_long_desc 
,rn = row_number() over(order by short_desc)
into #tempDstActCodes
from '+@dstServer+'.dbo.census_codes with (nolock)
where (fac_id in (-1,'+@dstFacIDs+') --dst fac_id
	or reg_id in (select regional_id from '+@dstServer+'.dbo.facility with (nolock) 
		where fac_id in ('+@dstFacIDs+') and regional_id is not null)  --dst fac_id
	or state_code in (select prov from '+@dstServer+'.dbo.facility with (nolock) 
		where fac_id in ('+@dstFacIDs+') and prov is not null)  --dst fac_id
    )
AND deleted = ''N''
AND table_code = ''ACT''
order by 2

select a.src_long_desc, a.src_short_desc, a.src_item_id,'''',b.dst_item_id, b.dst_short_desc, b.dst_long_desc from #tempSrcActCodes a
full outer join #tempDstActCodes b on b.rn=a.rn
order by  b.dst_short_desc

---------------------
--Status Codes
---------------------
--src
drop table if exists #tempSrcStatusCodes, #tempDstStatusCodes

select long_desc as src_long_desc, short_desc as src_short_desc, item_id as src_item_id 
,rn = row_number() over(order by short_desc)
into #tempSrcStatusCodes
from '+@srcServer+'.dbo.census_codes with (nolock)
where (fac_id in (-1,'+@srcFacIDs+') --src fac_id
	or reg_id in (select regional_id from '+@srcServer+'.dbo.facility with (nolock) 
		where fac_id in ('+@srcFacIDs+') and regional_id is not null))--src fac_id
AND deleted = ''N''
AND table_code = ''SC''
AND item_id in  
		((SELECT isnull(action_code_id,-1) FROM '+@srcServer+'.[dbo].census_item with (nolock) 
		WHERE fac_id in ('+@srcFacIDs+') AND DELETED = ''N'')  --src fac_id
		UNION 
		(SELECT isnull(STATUS_CODE_ID,-1) FROM '+@srcServer+'.[dbo].census_item with (nolock) 
		WHERE fac_id in ('+@srcFacIDs+') AND DELETED = ''N'')) --src fac_id
order by 2

--dst
select item_id as dst_item_id, short_desc as dst_short_desc, long_desc as dst_long_desc 
,rn = row_number() over(order by short_desc)
into #tempDstStatusCodes
from '+@dstServer+'.dbo.census_codes with (nolock)
where (fac_id in (-1,'+@dstFacIDs+') --dst fac_id
	or reg_id in (select regional_id from '+@dstServer+'.dbo.facility with (nolock) 
		where fac_id in ('+@dstFacIDs+') and regional_id is not null)  --dst fac_id
	or state_code in (select prov from '+@dstServer+'.dbo.facility with (nolock) 
		where fac_id in ('+@dstFacIDs+') and regional_id is not null)  --dst fac_id
    )
AND deleted = ''N''
AND table_code = ''SC''
order by 2


select a.src_long_desc, a.src_short_desc, a.src_item_id,'''',b.dst_item_id, b.dst_short_desc, b.dst_long_desc from #tempSrcStatusCodes a
full outer join #tempDstStatusCodes b on b.rn=a.rn
order by  b.dst_short_desc'

EXEC(@SQL)