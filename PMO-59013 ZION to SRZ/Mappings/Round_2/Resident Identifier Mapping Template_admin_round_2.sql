/*

This script is to provide Admin Implementers a mapping template compare id_type items between source and destination, since only the ones used are brought over.

Please send the execution results to Admin Implementers in the email of internal test DB release

Please update the parameters as commented

For multi-facilities projects, since we use the same root case#, please use it as the case number and the script should be able to pick up all id_type mapping table that includes this number

*/

DECLARE @SQL VARCHAR(MAX)
DECLARE @SQLMAPPING VARCHAR(MAX)
DECLARE @SQLDISTINCT VARCHAR(500)
DECLARE @SrcServer VARCHAR(500)
DECLARE	@DstServer VARCHAR(500)
DECLARE @CaseNumber VARCHAR(100)
DECLARE @TableName VARCHAR(500)


set @CaseNumber = 'EICase59013'--use the root case number, keep the 'EICase'
set @SrcServer = '[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058'----change src server & db name
set @DstServer = '[pccsql-use2-prod-ssv-tscon11.b4ea653240a9.database.windows.net].test_usei1122'----change dst server & db name


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
--where TABLE_NAME LIKE '%'+@CaseNumber+'%id_type'

EXEC ('DECLARE MyCursor CURSOR FOR
select TABLE_NAME from '+ @DstServer + '.INFORMATION_SCHEMA.TABLES
where TABLE_NAME LIKE ''%'+ @CaseNumber +'%id_type''
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
isnull(SRC_id_type_id,'''') as		srcIdTypeId
,isnull(src_Fac_Id,'''') as		srcFacId
,isnull(Src_Reg,'''') as		srcReg
,isnull(SRC_Prov,'''') as		srcProv
,SRC_show_on_Admin_Record as					srcShowOnAdminRecord
,SRC_show_on_Invoice
,SRC_show_on_Resident_Entry
,SRC_required_on_Entry
,SRC_format as				srcformat
,SRC_description as				srcFieldName
,'''' as						map_dst_typeid
,DST_description as				dstFieldName
,DST_show_on_Admin_Record as					dstDataType
,DST_format as				dsdtformat
,DST_show_on_Admin_Record
,DST_show_on_Invoice
,DST_show_on_Resident_Entry
,DST_required_on_Entry
,isnull(dst_Reg,'''') as		dstReg
,isnull(dst_Prov,'''') as		dstProv
,isnull(DST_Fac_Id,'''') as		dstFacId
,isnull(DST_id_type_id,'''') as		dstIdTypeId
,								If_Merged

from (

select
		cast(src.id_type_id as varchar(100)) as					''SRC_id_type_id''
		,cast(src.fac_id as varchar(100)) as					''SRC_Fac_Id''
		,CASE
			WHEN regs.short_desc is not NULL 
				THEN regs.short_desc
			ELSE cast(src.reg_id as varchar(100))
		END as													''SRC_Reg''
		,src.state_code as										''SRC_Prov''
		,src.description as										''SRC_description''
		,src.format as											''SRC_format''
		,src.show_on_a_r as										''SRC_show_on_Admin_Record''
		,src.show_on_invoice as									''SRC_show_on_Invoice''
		,src.show_on_new as										''SRC_show_on_Resident_Entry''
		,src.required_on_new as									''SRC_required_on_Entry''
		,dst.description as										''DST_description''
		,dst.show_on_a_r as										''DST_show_on_Admin_Record''
		,dst.show_on_invoice as									''DST_show_on_Invoice''
		,dst.show_on_new as										''DST_show_on_Resident_Entry''
		,dst.required_on_new as									''DST_required_on_Entry''
		,dst.format as									''DST_format''
		,CASE
			WHEN regd.short_desc is not NULL 
				THEN regd.short_desc
			ELSE cast(dst.reg_id as varchar(100))
		END as													''DST_Reg''
		,dst.state_code as										''DST_Prov''
		,dst.fac_id as											''DST_Fac_Id''
		,cast(dst.id_type_id as varchar(100)) as					''DST_id_type_id''
		,CASE
			WHEN dst.created_by like ''%' + @CaseNumber + '%'' 
				THEN ''N''
			WHEN dst.created_by not like ''%' + @CaseNumber + '%'' 
				THEN ''Y''
			ELSE dst.created_by
		END as													''If_Merged''
--select *
from '+ @SrcServer +'.dbo.id_type src with (nolock)
join #tempmappingdistinct map with (nolock) on src.id_type_id = map.src_id
join '+ @DstServer +'.dbo.id_type dst with (nolock) on dst.id_type_id = map.dst_id
left join '+ @SrcServer +'.dbo.regions regs on regs.regional_id = src.reg_id
left join '+ @DstServer +'.dbo.regions regd on regd.regional_id = dst.reg_id
where src.deleted <> ''Y''


UNION

select
		NULL as								''SRC_id_type_id''
		,NULL as								''SRC_Fac_Id''
		,NULL as								''SRC_Reg''
		,NULL as								''SRC_Prov''
		,'''' as								''SRC_description''
		,'''' as								''SRC_format''
		,'''' as								''SRC_show_on_Admin_Record''
		,'''' as									''SRC_show_on_Invoice''
		,'''' as										''SRC_show_on_Resident_Entry''
		,'''' as									''SRC_required_on_Entry''
		,dst.description as						''DST_description''
		,dst.show_on_a_r as						''DST_show_on_Admin_Record''
		,dst.show_on_invoice as									''DST_show_on_Invoice''
		,dst.show_on_new as										''DST_show_on_Resident_Entry''
		,dst.required_on_new as									''DST_required_on_Entry''
		,dst.format as					''DST_format''
		,CASE
			WHEN regd.short_desc is not NULL 
				THEN regd.short_desc
			ELSE cast(dst.reg_id as varchar(100))
		END as									''DST_Reg''
		,dst.state_code as						''DST_Prov''
		,dst.fac_id as							''DST_Fac_Id''
		,cast(dst.id_type_id as varchar(100)) as	''DST_id_type_id''
		,''As_is'' as							''If_Merged''	
--select *
from '+ @DstServer +'.dbo.id_type dst with (nolock)
left join '+ @DstServer +'.dbo.regions regd on regd.regional_id = dst.reg_id
where dst.deleted <> ''Y''
and dst.id_type_id not in (select dst_id from #tempmappingdistinct with (nolock))


) a

--where dst_fac_id <> -1


order by DST_description, SRC_description
'
--PRINT @SQL
EXEC (@SQL)



