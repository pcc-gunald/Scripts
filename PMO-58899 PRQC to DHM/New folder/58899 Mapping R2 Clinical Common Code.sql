/*************************************************
R2 Clinical - Common Code Mapping

-----------------------SCOPE--------------------------
Each of the sections of the Clinical Common Code mapping are related to a specific item_code in the common_code table. There are 12 item_code - picklists that are included that can each be found in the front end at:

phocst - Fluid Consistency:
phodtx - Diet Texture:
phodyt - Diet Type:
phosup - Diet Supplement:
EMC > Standards > Care Mangement > Physician Orders > Pick Lists
Facility LeveL > Care Services > Setup > Orders > Pick Lists

dclas - Diagnosis Classification
drank - Diagnosis Rank:
EMC > Standards > Care Mangement > Diagnosis > Diagnosis Rank / Diagnosis Classification
Facility LeveL > Care Services > Setup > Diagnosis > Diagnosis Rank / Diagnosis Classification

phorad - Route of Administration:
????????

phorec - Administration Record Types:
????????????

phowvc - Weights And Vitals:
wvscal - Weight Scale Types:
Facility LeveL > Care Services > Setup > Weights & Vitals > Pick Lists 

strke - Documentation Strike Out:
EMC > Standards > Care Mangement > Progress Notes > Progress Note Strike Out Pick List
Facility LeveL > Care Services > Setup > General Configuration > Strike Out Pick List

cpclo - Reasons for Care Plan Closure:
Facility LeveL > Care Services > Setup > Service Plan / Care Plan > Pick Lists > Reasons for Service Plan Closure / Reasons for Care Plan Closure

--------------------INSTRUCTIONS------------------------
Fill the following fields and then paste the output to the PMOxxxxx_clinical_commmon_code tab of the excel file found at 
\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_Scripts\EI_SCRIPTS\Pre_EI Scripts\MappingTemplate Files\PMOXYZ_CommonCodeClinicalPicklistMappings_R2.xlsx
and replace the PMOxxxxx with your PMO/Engagement Number

1. @CaseNumber - String to identify EICase mapping tables from your datacopy, this should be the common part of the case number in 
	LoadEIMaster_Automation.CaseNo without the part that identifies each facility. For example if your Case Numbers are 5851601 and 5851602
	then we would set @CaseNumber to 'EICase58516'.
2. @srcServer - connection string for the source test DB 
3. @dstServer - connection string for the destination test DB


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
			WHEN src.item_code = ''cpclo'' THEN ''Reasons for Care Plan Closure''
			WHEN src.item_code = ''dclas'' THEN ''Diagnosis Classification''
			WHEN src.item_code = ''drank'' THEN ''Diagnosis Rank''
			WHEN src.item_code = ''phocst'' THEN ''Fluid Consistency''
			WHEN src.item_code = ''phodtx'' THEN ''Diet Texture''
			WHEN src.item_code = ''phodyt'' THEN ''Diet Type''
			WHEN src.item_code = ''phorad'' THEN ''Route of Administration''
			WHEN src.item_code = ''phorec'' THEN ''Administration Record Types''
			WHEN src.item_code = ''phosup'' THEN ''Diet Supplement''
			WHEN src.item_code = ''phowvc'' THEN ''Weights And Vitals''
			WHEN src.item_code = ''strke'' THEN ''Documentation Strike Out''
			WHEN src.item_code = ''wvscal'' THEN ''Weight Scale Types''
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
''cpclo'',''dclas'',''drank'',''phocst'',''phodtx'',''phodyt'',''phorad'',''phorec'',''phosup'',''phowvc'',''strke'',''wvscal''

)
and src.deleted <> ''Y''


UNION

select
		dst.item_code as item_code
		,CASE 
			WHEN dst.item_code = ''cpclo'' THEN ''Reasons for Care Plan Closure''
			WHEN dst.item_code = ''dclas'' THEN ''Diagnosis Classification''
			WHEN dst.item_code = ''drank'' THEN ''Diagnosis Rank''
			WHEN dst.item_code = ''phocst'' THEN ''Fluid Consistency''
			WHEN dst.item_code = ''phodtx'' THEN ''Diet Texture''
			WHEN dst.item_code = ''phodyt'' THEN ''Diet Type''
			WHEN dst.item_code = ''phorad'' THEN ''Route of Administration''
			WHEN dst.item_code = ''phorec'' THEN ''Administration Record Types''
			WHEN dst.item_code = ''phosup'' THEN ''Diet Supplement''
			WHEN dst.item_code = ''phowvc'' THEN ''Weights And Vitals''
			WHEN dst.item_code = ''strke'' THEN ''Documentation Strike Out''
			WHEN dst.item_code = ''wvscal'' THEN ''Weight Scale Types''
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
''cpclo'',''dclas'',''drank'',''phocst'',''phodtx'',''phodyt'',''phorad'',''phorec'',''phosup'',''phowvc'',''strke'',''wvscal''
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