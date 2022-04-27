/*************************************************
R2 Admin - Resident Identifier Mapping

-----------------------SCOPE--------------------------
Each of the sections of the Admin Pick List mapping are related to a specific item_code in the common_code table. There are 19 item_code - picklists that are included:

These picklists can be found on the front end at
EMC > Standards > Financial Mangement > General Setup > Resident Identifiers
Facility Level > Billing > Setup > Organization Setup > Pick Lists


--------------------INSTRUCTIONS------------------------
Fill the following fields and then paste the output to the ResidentIdentfier tab of the excel file found at 
\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_Scripts\EI_SCRIPTS\Pre_EI Scripts\MappingTemplate Files\PMOXYZ_AdminMapping_R2.xlsx

1. @CaseNumber - String to identify EICase mapping tables from your datacopy, this should be the common part of the case number in 
	LoadEIMaster_Automation.CaseNo without the part that identifies each facility. For example if your Case Numbers are 5851601 and 5851602
	then we would set @CaseNumber to 'EICase58516'.
3. @srcServer - connection string for the source test DB 
4. @dstServer - connection string for the destination test DB


**************************************************/

DECLARE @SQL VARCHAR(MAX)
DECLARE @SQLMAPPING VARCHAR(MAX)
DECLARE @SQLDISTINCT VARCHAR(500)
DECLARE @SrcServer VARCHAR(500)
DECLARE	@DstServer VARCHAR(500)
DECLARE @CaseNumber VARCHAR(100)
DECLARE @TableName VARCHAR(500)


set @CaseNumber = 'EICase58899'-- example 'EICase58876' (make sure the case_number_root is unique for multi part projects) 
set @SrcServer = '[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].[test_usei1029]' --example: '[pccsql-use2-prod-ssv-tscon06.b4ea653240a9.database.windows.net].test_usei435'
set @DstServer = '[pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].[test_usei41]' --example: '[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei425'


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



