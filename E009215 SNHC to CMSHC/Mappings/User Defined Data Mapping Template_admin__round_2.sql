/*

This script is to provide Admin Implementers a mapping template compare user_field_types items between source and destination, since only the ones used are brought over.

Please send the execution results to Admin Implementers in the email of internal test DB release

Please update the parameters as commented

For multi-facilities projects, since we use the same root case#, please use it as the case number and the script should be able to pick up all user_field_types mapping table that includes this number

*/

DECLARE @SQL VARCHAR(MAX)
DECLARE @SQLMAPPING VARCHAR(MAX)
DECLARE @SQLDISTINCT VARCHAR(500)
DECLARE @SrcServer VARCHAR(500)
DECLARE	@DstServer VARCHAR(500)
DECLARE @CaseNumber VARCHAR(100)
DECLARE @TableName VARCHAR(500)


set @CaseNumber = 'EICase009215'--use the root case number, keep the 'EICase'
set @SrcServer = '[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].[test_usei1029]'----change src server & db name
set @DstServer = '[pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].[test_usei41]'----change dst server & db name


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
--where TABLE_NAME LIKE '%'+@CaseNumber+'%user_field_types'

EXEC ('DECLARE MyCursor CURSOR FOR
select TABLE_NAME from '+ @DstServer + '.INFORMATION_SCHEMA.TABLES
where TABLE_NAME LIKE ''%'+ @CaseNumber +'%user_field_types''
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
select distinct 
isnull(SRC_field_type_id,'''') as		srcFieldTypeId
,isnull(src_Fac_Id,'''') as		srcFacId
,isnull(Src_Reg,'''') as		srcReg
,isnull(SRC_Prov,'''') as		srcProv
,SRC_Data_Type as					srcDataType
,CASE WHEN SRC_Length = 0 THEN ''''
ELSE SRC_length END as				srcLength
,SRC_field_name as				srcFieldName
,'''' as						map_dst_typeid
,DST_field_name as				dstFieldName
,DST_Data_Type as					dstDataType
,CASE WHEN dst_Length = 0 THEN ''''
WHEN dst_Length = ''-1'' THEN ''''
ELSE dst_Length END as				dstLength
,isnull(dst_Reg,'''') as		dstReg
,isnull(dst_Prov,'''') as		dstProv
,isnull(DST_Fac_Id,'''') as		dstFacId
,isnull(DST_field_type_id,'''') as		dstFieldTypeId
,								If_Merged

from (

select
		cast(src.field_type_id as varchar(100)) as					''SRC_field_type_id''
		,cast(src.fac_id as varchar(100)) as					''SRC_Fac_Id''
		,CASE
			WHEN regs.short_desc is not NULL 
				THEN regs.short_desc
			ELSE cast(src.reg_id as varchar(100))
		END as													''SRC_Reg''
		,src.state_code as										''SRC_Prov''
		,src.field_name as										''SRC_field_name''
		,src.field_data_type as										''SRC_Data_Type''
		,cast(src.field_length as varchar(100))					''SRC_Length''
		,dst.field_name as										''DST_field_name''
		,dst.field_data_type as										''DST_Data_Type''
		,cast(dst.field_length as varchar(100)) as									''DST_Length''
		,CASE
			WHEN regd.short_desc is not NULL 
				THEN regd.short_desc
			ELSE cast(dst.reg_id as varchar(100))
		END as													''DST_Reg''
		,dst.state_code as										''DST_Prov''
		,dst.fac_id as											''DST_Fac_Id''
		,cast(dst.field_type_id as varchar(100)) as					''DST_field_type_id''
		,CASE
			WHEN dst.created_by like ''%' + @CaseNumber + '%'' 
				THEN ''N''
			WHEN dst.created_by not like ''%' + @CaseNumber + '%'' 
				THEN ''Y''
			ELSE dst.created_by
		END as													''If_Merged''
--select *
from '+ @SrcServer +'.dbo.user_field_types src with (nolock)
join #tempmappingdistinct map with (nolock) on src.field_type_id = map.src_id
join '+ @DstServer +'.dbo.user_field_types dst with (nolock) on dst.field_type_id = map.dst_id
left join '+ @SrcServer +'.dbo.regions regs on regs.regional_id = src.reg_id
left join '+ @DstServer +'.dbo.regions regd on regd.regional_id = dst.reg_id
where src.deleted <> ''Y''


UNION

select
		NULL as								''SRC_field_type_id''
		,NULL as								''SRC_Fac_Id''
		,NULL as								''SRC_Reg''
		,NULL as								''SRC_Prov''
		,'''' as								''SRC_field_name''
		,'''' as								''SRC_Data_Type''
		,'''' as								''SRC_Length''
		,dst.field_name as						''DST_field_name''
		,dst.field_data_type as						''DST_Data_Type''
		,cast(dst.field_length as varchar(100))				''DST_Length''	
		,CASE
			WHEN regd.short_desc is not NULL 
				THEN regd.short_desc
			ELSE cast(dst.reg_id as varchar(100))
		END as									''DST_Reg''
		,dst.state_code as						''DST_Prov''
		,dst.fac_id as							''DST_Fac_Id''
		,cast(dst.field_type_id as varchar(100)) as	''DST_field_type_id''
		,''As_is'' as							''If_Merged''	
--select *
from '+ @DstServer +'.dbo.user_field_types dst with (nolock)
left join '+ @DstServer +'.dbo.regions regd on regd.regional_id = dst.reg_id
where dst.deleted <> ''Y''
and dst.field_type_id not in (select dst_id from #tempmappingdistinct with (nolock))


) a

--where dst_fac_id <> -1


order by DST_field_name, SRC_field_name
'
--PRINT @SQL
EXEC (@SQL)



