/*

This script is to provide Admin Implementers a mapping template compare common_code items between source and destination, since only the ones used are brought over.

Please send the execution results to Admin Implementers in the email of internal test DB release

Please update the parameters as commented

For multi-facilities projects, since we use the same root case#, please use it as the case number and the script should be able to pick up all common_code mapping table that includes this number

*/

DECLARE @SQL VARCHAR(MAX)
DECLARE @SQLMAPPING VARCHAR(MAX)
DECLARE @SQLDISTINCT VARCHAR(500)
DECLARE @SrcServer VARCHAR(500)
DECLARE	@DstServer VARCHAR(500)
DECLARE @CaseNumber VARCHAR(100)
DECLARE @TableName VARCHAR(500)


set @CaseNumber = 'EICase007858'--use the root case number, keep the 'EICase'
set @SrcServer = '[pccsql-use2-prod-ssv-tscon06.b4ea653240a9.database.windows.net].[test_usei639]'----change src server & db name
set @DstServer = '[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].[test_usei1015]'----change dst server & db name


IF OBJECT_ID('tempdb..#tempmapping') IS NOT NULL 
DROP TABLE #tempmapping

IF OBJECT_ID('tempdb..#tempmappingdistinct') IS NOT NULL 
DROP TABLE #tempmappingdistinct

create table #tempmapping (
src_id bigint,
dst_id bigint
)

create table #tempmappingdistinct (
src_id bigint,
dst_id bigint
)

--DECLARE MyCursor CURSOR FOR
--select TABLE_NAME from INFORMATION_SCHEMA.TABLES
--where TABLE_NAME LIKE '%'+@CaseNumber+'%COMMON_CODE'

EXEC ('DECLARE MyCursor CURSOR FOR
select TABLE_NAME from '+ @DstServer + '.INFORMATION_SCHEMA.TABLES
where TABLE_NAME LIKE ''%'+ @CaseNumber +'%COMMON_CODE''
')


OPEN MyCursor 
FETCH NEXT FROM MyCursor INTO @TableName
WHILE(@@Fetch_Status = 0)

BEGIN

SET @SQLMAPPING = 'insert into #tempmapping (src_id, dst_id) select src_id, dst_id from ' + @DstServer + '.dbo.' + @TableName

--PRINT @SQLMAPPING
EXEC (@SQLMAPPING)

FETCH NEXT FROM MyCursor INTO @TableName
END
CLOSE MyCursor
DEALLOCATE MyCursor


SET @SQLDISTINCT = 'insert into #tempmappingdistinct select distinct src_id, dst_id from #tempmapping'

--PRINT @SQLDISTINCT
EXEC (@SQLDISTINCT)

--select * from #tempmapping
--select * from #tempmappingdistinct


SET @SQL = '
select ROW_NUMBER() OVER (order by Pick_List_Name, DST_Item_Description, SRC_Item_Description) as id,* from 
(select distinct
item_code,
Pick_List_Name
--,src_System_Flag
,isnull(SRC_Item_Id,'''') as src_Item_Id
,isnull(src_Fac_Id,'''') as src_Fac_Id
,isnull(Src_Reg,'''') as Src_Reg
,isnull(Src_Prov,'''') as Src_Prov
,src_Item_Description
,'''' as Map_DstItemId
,dst_Item_Description
,isnull(dst_Prov,'''') as dst_Prov
,isnull(dst_Reg,'''') as dst_Reg
,dst_Fac_Id
,isnull(DST_Item_Id,'''') as ''dst_Item_Id''
--,dst_System_Flag
,If_Merged

from (

select
		src.item_code as item_code
		,CASE 
			WHEN src.item_code = ''citize'' THEN ''Citizenship''
			WHEN src.item_code = ''relat'' THEN ''Contact Relationships''
			WHEN src.item_code = ''respo'' THEN ''Contact Types''
			WHEN src.item_code = ''dept'' THEN ''Departments''
			WHEN src.item_code = ''educa'' THEN ''Education''
			WHEN src.item_code = ''ethnic'' THEN ''Ethnicity''
			WHEN src.item_code = ''phofac'' THEN ''External Facility Types''
			WHEN src.item_code = ''lang'' THEN ''Languages''
			WHEN src.item_code = ''marit'' THEN ''Marital Status''
			WHEN src.item_code = ''profe'' THEN ''Medical Professional Types''
			WHEN src.item_code = ''prefi'' THEN ''Prefix''
			WHEN src.item_code = ''proctp'' THEN ''Professional Contact Types''
			WHEN src.item_code = ''prorel'' THEN ''Professional Relations''
			WHEN src.item_code = ''race'' THEN ''Race''
			WHEN src.item_code = ''relig'' THEN ''Religions''
			WHEN src.item_code = ''posit'' THEN ''Staff Positions''
			WHEN src.item_code = ''suffix'' THEN ''Suffix''
			WHEN src.item_code = ''admit'' THEN ''To/From Type''
			WHEN src.item_code = ''rtype'' THEN ''Room Types''
			ELSE src.item_code
		END
		as ''Pick_List_Name''
		,src.system_flag as ''SRC_System_Flag''
		,cast(src.item_id as varchar(100)) as ''SRC_Item_Id''
		,cast(src.fac_id as varchar(100)) as ''Src_Fac_Id''
		,regs.short_desc as ''Src_Reg''
		,src.state_code as ''Src_Prov''
		,src.item_description as ''SRC_Item_Description''
		,dst.item_description as ''DST_Item_Description''
		,dst.state_code as ''Dst_Prov''
		,regd.short_desc as ''Dst_Reg''
		,dst.fac_id as ''Dst_Fac_Id''
		,cast(dst.item_id as varchar(100)) as ''DST_Item_Id''
		,dst.system_flag as ''Dst_System_Flag''
		,CASE
			WHEN dst.created_by like ''%' + @CaseNumber + '%'' THEN ''N''
			WHEN dst.created_by not like ''%' + @CaseNumber + '%'' THEN ''Y''
			ELSE dst.created_by
		END as ''If_Merged''
--select *
from '+ @SrcServer +'.dbo.common_code src with (nolock)
join #tempmappingdistinct map with (nolock) on src.item_id = map.src_id
join '+ @DstServer +'.dbo.common_code dst with (nolock) on dst.item_id = map.dst_id
left join '+ @SrcServer +'.dbo.regions regs on regs.regional_id = src.reg_id
left join '+ @DstServer +'.dbo.regions regd on regd.regional_id = dst.reg_id
where src.item_code in
(
''admit'',''citize'',''relat'',''respo'',''dept'',''educa'',''ethnic'',''phofac''
,''lang'',''marit'',''profe'',''prefi'',''proctp'',''prorel'',''race'',''relig''
,''posit'',''suffix'',''rtype''
)
and src.deleted <> ''Y''


UNION

select
		dst.item_code as item_code
		,CASE 
			WHEN dst.item_code = ''citize'' THEN ''Citizenship''
			WHEN dst.item_code = ''relat'' THEN ''Contact Relationships''
			WHEN dst.item_code = ''respo'' THEN ''Contact Types''
			WHEN dst.item_code = ''dept'' THEN ''Departments''
			WHEN dst.item_code = ''educa'' THEN ''Education''
			WHEN dst.item_code = ''ethnic'' THEN ''Ethnicity''
			WHEN dst.item_code = ''phofac'' THEN ''External Facility Types''
			WHEN dst.item_code = ''lang'' THEN ''Languages''
			WHEN dst.item_code = ''marit'' THEN ''Marital Status''
			WHEN dst.item_code = ''profe'' THEN ''Medical Professional Types''
			WHEN dst.item_code = ''prefi'' THEN ''Prefix''
			WHEN dst.item_code = ''proctp'' THEN ''Professional Contact Types''
			WHEN dst.item_code = ''prorel'' THEN ''Professional Relations''
			WHEN dst.item_code = ''race'' THEN ''Race''
			WHEN dst.item_code = ''relig'' THEN ''Religions''
			WHEN dst.item_code = ''posit'' THEN ''Staff Positions''
			WHEN dst.item_code = ''suffix'' THEN ''Suffix''
			WHEN dst.item_code = ''admit'' THEN ''To/From Type''
			WHEN dst.item_code = ''rtype'' THEN ''Room Types''
			ELSE dst.item_code
		END
		as ''Pick_List_Name''
		,'''' as ''SRC_System_Flag''
		,NULL as ''SRC_Item_Id''
		,NULL as ''Src_Fac_Id''
		,NULL as ''Src_Reg''
		,NULL as ''Src_Prov''
		,'''' as ''SRC_Item_Description''
		,dst.item_description as ''DST_Item_Description''
		,dst.state_code as ''Dst_Prov''
		,regd.short_desc as ''Dst_Reg''
		,dst.fac_id as ''Dst_Fac_Id''
		,cast(dst.item_id as varchar(100)) as ''DST_Item_Id''
		,dst.system_flag as ''Dst_System_Flag''
		,''As_is'' as ''If_Merged''	
--select *
from '+ @DstServer +'.dbo.common_code dst with (nolock)
left join '+ @DstServer +'.dbo.regions regd on regd.regional_id = dst.reg_id
where dst.item_code in
(
''admit'',''citize'',''relat'',''respo'',''dept'',''educa'',''ethnic'',''phofac''
,''lang'',''marit'',''profe'',''prefi'',''proctp'',''prorel'',''race'',''relig''
,''posit'',''suffix'',''rtype''
)
and dst.deleted <> ''Y''
and dst.item_id not in (select dst_id from #tempmappingdistinct with (nolock))


) a

--where dst_fac_id <> -1


) as t
order by Pick_List_Name, DST_Item_Description, SRC_Item_Description
'
--PRINT @SQL
EXEC (@SQL)