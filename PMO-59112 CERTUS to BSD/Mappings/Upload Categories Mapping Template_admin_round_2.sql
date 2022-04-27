/*

This script is to provide Admin Implementers a mapping template compare upload_categories items between source and destination, since only the ones used are brought over.

Please send the execution results to Admin Implementers in the email of internal test DB release

Please update the parameters as commented

For multi-facilities projects, since we use the same root case#, please use it as the case number and the script should be able to pick up all upload_categories mapping table that includes this number

*/

DECLARE @SQL VARCHAR(MAX)
DECLARE @SQLMAPPING VARCHAR(MAX)
DECLARE @SQLDISTINCT VARCHAR(500)
DECLARE @SrcServer VARCHAR(500)
DECLARE	@DstServer VARCHAR(500)
DECLARE @CaseNumber VARCHAR(100)
DECLARE @TableName VARCHAR(500)


set @CaseNumber = 'EICase59112'--use the root case number, keep the 'EICase'
set @SrcServer = '[pccsql-use2-prod-ssv-tscon11.b4ea653240a9.database.windows.net].[test_usei1066]'----change src server & db name
set @DstServer = '[pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].[test_usei35]'----change dst server & db name


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
--where TABLE_NAME LIKE '%'+@CaseNumber+'%upload_categories'

EXEC ('DECLARE MyCursor CURSOR FOR
select TABLE_NAME from '+ @DstServer + '.INFORMATION_SCHEMA.TABLES
where TABLE_NAME LIKE ''%'+ @CaseNumber +'%upload_categories''
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
isnull(SRC_Cat_Id,'''') as		srcCatId
,isnull(src_Fac_Id,'''') as		srcFacId
,isnull(Src_Reg,'''') as		srcReg
,isnull(SRC_Prov,'''') as		srcProv
,isnull(SRC_System_Cat,'''') as srcSysCat
,SRC_Admin as					srcAdmin
,SRC_Clinical as				srcClinical
,SRC_IRM as						srcIRM
,SRC_CRM as						srcCRM
,SRC_Cat_Desc as				srcCatDesc
,'''' as						map_dst_catid
,DST_Cat_Desc as				dstCatDesc
,DST_Admin as					dstAdmin
,DST_Clinical as				dsdtClinical
,DST_IRM as						dstIRM
,DST_CRM as						dstCRM
,isnull(dst_Reg,'''') as		dstReg
,isnull(dst_Prov,'''') as		dstProv
,isnull(DST_System_Cat,'''') as dstSysCat
,isnull(DST_Fac_Id,'''') as		dstFacId
,isnull(DST_Cat_Id,'''') as		dstCatId
,								If_Merged

from (

select
		cast(src.std_cat_id as varchar(100)) as					''SRC_System_Cat''
		,cast(src.Cat_Id as varchar(100)) as					''SRC_Cat_Id''
		,cast(src.fac_id as varchar(100)) as					''SRC_Fac_Id''
		,CASE
			WHEN regs.short_desc is not NULL 
				THEN regs.short_desc
			ELSE cast(src.reg_id as varchar(100))
		END as													''SRC_Reg''
		,src.state_code as										''SRC_Prov''
		,src.Cat_Desc as										''SRC_Cat_Desc''
		,src.admin_flag as										''SRC_Admin''
		,src.clinical_flag as									''SRC_Clinical''
		,src.irm_flag as										''SRC_IRM''
		,src.crm_flag as										''SRC_CRM''
		,dst.Cat_Desc as										''DST_Cat_Desc''
		,dst.admin_flag as										''DST_Admin''
		,dst.clinical_flag as									''DST_Clinical''
		,dst.irm_flag as										''DST_IRM''
		,dst.crm_flag as										''DST_CRM''
		,CASE
			WHEN regd.short_desc is not NULL 
				THEN regd.short_desc
			ELSE cast(dst.reg_id as varchar(100))
		END as													''DST_Reg''
		,dst.state_code as										''DST_Prov''
		,dst.fac_id as											''DST_Fac_Id''
		,cast(dst.Cat_Id as varchar(100)) as					''DST_Cat_Id''
		,cast(dst.std_cat_id as varchar(100)) as				''DST_System_Cat''
		,CASE
			WHEN dst.created_by like ''%' + @CaseNumber + '%'' 
				THEN ''N''
			WHEN dst.created_by not like ''%' + @CaseNumber + '%'' 
				THEN ''Y''
			ELSE dst.created_by
		END as													''If_Merged''
--select *
from '+ @SrcServer +'.dbo.upload_categories src with (nolock)
join #tempmappingdistinct map with (nolock) on src.Cat_Id = map.src_id
join '+ @DstServer +'.dbo.upload_categories dst with (nolock) on dst.Cat_Id = map.dst_id
left join '+ @SrcServer +'.dbo.regions regs on regs.regional_id = src.reg_id
left join '+ @DstServer +'.dbo.regions regd on regd.regional_id = dst.reg_id
where src.deleted <> ''Y''


UNION

select
		'''' as									''SRC_System_Cat''
		,NULL as								''SRC_Cat_Id''
		,NULL as								''SRC_Fac_Id''
		,NULL as								''SRC_Reg''
		,NULL as								''SRC_Prov''
		,'''' as								''SRC_Cat_Desc''
		,'''' as								''SRC_Admin''
		,'''' as								''SRC_Clinical''
		,'''' as								''SRC_IRM''
		,'''' as								''SRC_CRM''
		,dst.Cat_Desc as						''DST_Cat_Desc''
		,dst.admin_flag as						''DST_Admin''
		,dst.clinical_flag as					''DST_Clinical''
		,dst.irm_flag as						''DST_IRM''
		,dst.crm_flag as						''DST_CRM''
		,CASE
			WHEN regd.short_desc is not NULL 
				THEN regd.short_desc
			ELSE cast(dst.reg_id as varchar(100))
		END as									''DST_Reg''
		,dst.state_code as						''DST_Prov''
		,dst.fac_id as							''DST_Fac_Id''
		,cast(dst.Cat_Id as varchar(100)) as	''DST_Cat_Id''
		,cast(dst.std_cat_id as varchar(100)) as''Dst_System_Flag''
		,''As_is'' as							''If_Merged''	
--select *
from '+ @DstServer +'.dbo.upload_categories dst with (nolock)
left join '+ @DstServer +'.dbo.regions regd on regd.regional_id = dst.reg_id
where dst.deleted <> ''Y''
and dst.cat_code <> ''E''
and dst.Cat_Id not in (select dst_id from #tempmappingdistinct with (nolock))


) a

--where dst_fac_id <> -1


order by DST_Cat_Desc, SRC_Cat_Desc
'
--PRINT @SQL
EXEC (@SQL)



