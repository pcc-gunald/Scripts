--Run on DEST server after the process has been run.

DECLARE @SQL VARCHAR(MAX)
DECLARE @SQLMAPPING NVARCHAR(MAX)
DECLARE @SQLDISTINCT VARCHAR(500)
DECLARE @SrcServer VARCHAR(500)
DECLARE	@DstServer VARCHAR(500)
DECLARE @CaseNumber VARCHAR(100)
DECLARE @TableName VARCHAR(500)
DECLARE @ProcessTableName VARCHAR(500)
DECLARE @vStagingDBName VARCHAR(125)
declare @statement VARCHAR(MAX)


--Variables to change
set @vStagingDBName ='[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].pcc_staging_db009632'  --Staging DB on DST server
set @CaseNumber = 'EICASE009632'--use the root case number, keep the 'EICase'
set @SrcServer = '[pccsql-use2-prod-ssv-tscon06.b4ea653240a9.database.windows.net].test_usei435'----change src server & db name
set @DstServer = '[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei666'----change dst server & db name
set @ProcessTableName = 'cp_std_library'

select 'Care Plans' as MODULE,@ProcessTableName as TABLENAME

IF OBJECT_ID('tempdb..#tempmapping') IS NOT NULL 
DROP TABLE #tempmapping

IF OBJECT_ID('tempdb..#tempmappingdistinct') IS NOT NULL 
DROP TABLE #tempmappingdistinct

create table #tempmapping (
src_id bigint,
dst_id bigint,
corporate CHAR(1),
MappingTableName varchar (100)
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
where TABLE_NAME LIKE ''%'+ @CaseNumber +'%'+@ProcessTableName+'''
')


OPEN MyCursor 
FETCH NEXT FROM MyCursor INTO @TableName
WHILE(@@Fetch_Status = 0)

BEGIN



SET @SQLMAPPING = 'insert into #tempmapping (src_id, dst_id, corporate, MappingTableName) select src_id, dst_id, corporate,'''+@TableName+'''   from ' + @DstServer + '.dbo.' + @TableName

PRINT @SQLMAPPING
EXEC (@SQLMAPPING)

FETCH NEXT FROM MyCursor INTO @TableName
END
CLOSE MyCursor
DEALLOCATE MyCursor

select src_id, dst_id, corporate as Merged, MappingTableName from #tempmapping
order by 1,3,4



/*
select * from [dbo].[mergeJoinsMaster]
where TableName = 'cp_std_library'
order by 1
select * from @vStagingDBName+[dbo].[mergeTablesMaster]
where TableName = 'cp_std_library'
order by 1
*/



SET @SQLMAPPING ='select * from '+@vStagingDBName+'.[dbo].[mergeTablesMaster]
where TableName = '''+@ProcessTableName+''' order by 1' 

print @SQLMAPPING
EXEC sp_executesql @SQLMAPPING

set @SQLMAPPING = 'select a.SRC_ID, src.description as SRC_description, src.fac_id as SRC_Fac_ID,src.reg_id as SRC_reg_id,src.state_code as SRC_state_code,
					      a.dst_id, dst.description as DST_description, dst.fac_id as DST_Fac_ID,dst.reg_id as DST_reg_id,dst.state_code as DST_state_code, a.corporate as Merged , MappingTableName as MappingTable
from #tempmapping as a
				   join '+@SrcServer+'.dbo.'+@ProcessTableName+' as src on src.library_id=a.src_id
				   join '+@DstServer+'.dbo.'+@ProcessTableName+' as dst on dst.library_id=a.dst_id
				   order by 2,11'

print @SQLMAPPING

EXEC sp_executesql @SQLMAPPING

set @SQLMAPPING = 'select description, count(*) as count from '+@DstServer+'.dbo.'+@ProcessTableName+'  as a
where library_id in (select dst_id from #tempmapping)
group by description
'

print @SQLMAPPING

EXEC sp_executesql @SQLMAPPING

-----------------------




--Select * from cp_std_need_cat
set @ProcessTableName = 'cp_std_need_cat'

select 'Care Plans' as MODULE,@ProcessTableName as TABLENAME

IF OBJECT_ID('tempdb..#tempmapping5') IS NOT NULL 
DROP TABLE #tempmapping5

IF OBJECT_ID('tempdb..#tempmappingdistinct5') IS NOT NULL 
DROP TABLE #tempmappingdistinct5

create table #tempmapping5 (
src_id bigint,
dst_id bigint,
corporate CHAR(1),
MappingTableName varchar (100)
)

create table #tempmappingdistinct5 (
src_id bigint,
dst_id bigint
)

--DECLARE MyCursor CURSOR FOR
--select TABLE_NAME from INFORMATION_SCHEMA.TABLES
--where TABLE_NAME LIKE '%'+@CaseNumber+'%COMMON_CODE'

EXEC ('DECLARE MyCursor CURSOR FOR
select TABLE_NAME from '+ @DstServer + '.INFORMATION_SCHEMA.TABLES
where TABLE_NAME LIKE ''%'+ @CaseNumber +'%'+@ProcessTableName+'''
')


OPEN MyCursor 
FETCH NEXT FROM MyCursor INTO @TableName
WHILE(@@Fetch_Status = 0)

BEGIN



SET @SQLMAPPING = 'insert into #tempmapping5 (src_id, dst_id, corporate, MappingTableName) select src_id, dst_id, corporate,'''+@TableName+'''   from ' + @DstServer + '.dbo.' + @TableName

PRINT @SQLMAPPING
EXEC (@SQLMAPPING)

FETCH NEXT FROM MyCursor INTO @TableName
END
CLOSE MyCursor
DEALLOCATE MyCursor

select src_id, dst_id, corporate as Merged, MappingTableName from #tempmapping5
order by 1,3,4



/*
select * from [dbo].[mergeJoinsMaster]
where TableName = 'cp_std_library'
order by 1
select * from @vStagingDBName+[dbo].[mergeTablesMaster]
where TableName = 'cp_std_library'
order by 1
*/



SET @SQLMAPPING ='select * from '+@vStagingDBName+'.[dbo].[mergeTablesMaster]
where TableName = '''+@ProcessTableName+''' order by 1' 

print @SQLMAPPING
EXEC sp_executesql @SQLMAPPING

set @SQLMAPPING = 'select a.SRC_ID, src.description as SRC_description, src.fac_id as SRC_Fac_ID,src.reg_id as SRC_reg_id,src.state_code as SRC_state_code,
					      a.dst_id, dst.description as DST_description, dst.fac_id as DST_Fac_ID,dst.reg_id as DST_reg_id,dst.state_code as DST_state_code, a.corporate as Merged , MappingTableName as MappingTable
from #tempmapping5 as a
				   join '+@SrcServer+'.dbo.'+@ProcessTableName+' as src on src.need_cat_id=a.src_id
				   join '+@DstServer+'.dbo.'+@ProcessTableName+' as dst on dst.need_cat_id=a.dst_id
				   order by 2,11'

print @SQLMAPPING

EXEC sp_executesql @SQLMAPPING

set @SQLMAPPING = 'select description, count(*) as count from '+@DstServer+'.dbo.'+@ProcessTableName+'  as a
where need_cat_id in (select dst_id from #tempmapping5)
group by description'

print @SQLMAPPING

EXEC sp_executesql @SQLMAPPING
----------------------------------------------------------------



--Select * from cp_std_etiologies
set @ProcessTableName = 'cp_std_etiologies'

select 'Care Plans' as MODULE,@ProcessTableName as TABLENAME

IF OBJECT_ID('tempdb..#tempmapping1') IS NOT NULL 
DROP TABLE #tempmapping1

IF OBJECT_ID('tempdb..#tempmappingdistinct1') IS NOT NULL 
DROP TABLE #tempmappingdistinct1

create table #tempmapping1 (
src_id bigint,
dst_id bigint,
corporate CHAR(1),
MappingTableName varchar (100)
)

create table #tempmappingdistinct1 (
src_id bigint,
dst_id bigint
)

--DECLARE MyCursor CURSOR FOR
--select TABLE_NAME from INFORMATION_SCHEMA.TABLES
--where TABLE_NAME LIKE '%'+@CaseNumber+'%COMMON_CODE'

EXEC ('DECLARE MyCursor CURSOR FOR
select TABLE_NAME from '+ @DstServer + '.INFORMATION_SCHEMA.TABLES
where TABLE_NAME LIKE ''%'+ @CaseNumber +'%'+@ProcessTableName+'''
')


OPEN MyCursor 
FETCH NEXT FROM MyCursor INTO @TableName
WHILE(@@Fetch_Status = 0)

BEGIN



SET @SQLMAPPING = 'insert into #tempmapping1 (src_id, dst_id, corporate, MappingTableName) select src_id, dst_id, corporate,'''+@TableName+'''   from ' + @DstServer + '.dbo.' + @TableName

PRINT @SQLMAPPING
EXEC (@SQLMAPPING)

FETCH NEXT FROM MyCursor INTO @TableName
END
CLOSE MyCursor
DEALLOCATE MyCursor

select src_id, dst_id, corporate as Merged, MappingTableName from #tempmapping1
order by 1,3,4

--select * from eicase00963220cp_std_library

/*
select * from [dbo].[mergeJoinsMaster]
where TableName = 'cp_std_library'
order by 1
select * from @vStagingDBName+[dbo].[mergeTablesMaster]
where TableName = 'cp_std_library'
order by 1
*/



SET @SQLMAPPING ='select * from '+@vStagingDBName+'.[dbo].[mergeTablesMaster]
where TableName = '''+@ProcessTableName+''' order by 1' 

print @SQLMAPPING
EXEC sp_executesql @SQLMAPPING

set @SQLMAPPING = 'select a.SRC_ID, src.text1 as SRC_description, src.fac_id as SRC_Fac_ID,src.reg_id as SRC_reg_id,src.state_code as SRC_state_code,
					      a.dst_id, dst.text1 as DST_description, dst.fac_id as DST_Fac_ID,dst.reg_id as DST_reg_id,dst.state_code as DST_state_code, a.corporate as Merged , MappingTableName as MappingTable
from #tempmapping1 as a
				   join '+@SrcServer+'.dbo.'+@ProcessTableName+' as src on src.std_etiologies_id=a.src_id
				   join '+@DstServer+'.dbo.'+@ProcessTableName+' as dst on dst.std_etiologies_id=a.dst_id
				   order by 2,11'

print @SQLMAPPING

EXEC sp_executesql @SQLMAPPING

set @SQLMAPPING = 'select text1, count(*) as count from '+@DstServer+'.dbo.'+@ProcessTableName+'  as a
where std_etiologies_id in (select dst_id from #tempmapping1)
group by text1'

print @SQLMAPPING

EXEC sp_executesql @SQLMAPPING

--------------------------

-----------------------

--Select * from cp_std_goal
set @ProcessTableName = 'cp_std_goal'

select 'Care Plans' as MODULE,@ProcessTableName as TABLENAME

IF OBJECT_ID('tempdb..#tempmapping2') IS NOT NULL 
DROP TABLE #tempmapping2

IF OBJECT_ID('tempdb..#tempmappingdistinct2') IS NOT NULL 
DROP TABLE #tempmappingdistinct2

create table #tempmapping2 (
src_id bigint,
dst_id bigint,
corporate CHAR(1),
MappingTableName varchar (100)
)

create table #tempmappingdistinct2 (
src_id bigint,
dst_id bigint
)

--DECLARE MyCursor CURSOR FOR
--select TABLE_NAME from INFORMATION_SCHEMA.TABLES
--where TABLE_NAME LIKE '%'+@CaseNumber+'%COMMON_CODE'

EXEC ('DECLARE MyCursor CURSOR FOR
select TABLE_NAME from '+ @DstServer + '.INFORMATION_SCHEMA.TABLES
where TABLE_NAME LIKE ''%'+ @CaseNumber +'%'+@ProcessTableName+'''
')


OPEN MyCursor 
FETCH NEXT FROM MyCursor INTO @TableName
WHILE(@@Fetch_Status = 0)

BEGIN



SET @SQLMAPPING = 'insert into #tempmapping2 (src_id, dst_id, corporate, MappingTableName) select src_id, dst_id, corporate,'''+@TableName+'''   from ' + @DstServer + '.dbo.' + @TableName

PRINT @SQLMAPPING
EXEC (@SQLMAPPING)

FETCH NEXT FROM MyCursor INTO @TableName
END
CLOSE MyCursor
DEALLOCATE MyCursor

select src_id, dst_id, corporate as Merged, MappingTableName from #tempmapping2
order by 1,3,4



/*
select * from [dbo].[mergeJoinsMaster]
where TableName = 'cp_std_library'
order by 1
select * from @vStagingDBName+[dbo].[mergeTablesMaster]
where TableName = 'cp_std_library'
order by 1
*/



SET @SQLMAPPING ='select * from '+@vStagingDBName+'.[dbo].[mergeTablesMaster]
where TableName = '''+@ProcessTableName+''' order by 1' 

print @SQLMAPPING
EXEC sp_executesql @SQLMAPPING

set @SQLMAPPING = 'select a.SRC_ID, src.text1 as SRC_description, src.fac_id as SRC_Fac_ID,src.reg_id as SRC_reg_id,src.state_code as SRC_state_code,
					      a.dst_id, dst.text1 as DST_description, dst.fac_id as DST_Fac_ID,dst.reg_id as DST_reg_id,dst.state_code as DST_state_code, a.corporate as Merged , MappingTableName as MappingTable
from #tempmapping2 as a
				   join '+@SrcServer+'.dbo.'+@ProcessTableName+' as src on src.std_goal_id=a.src_id
				   join '+@DstServer+'.dbo.'+@ProcessTableName+' as dst on dst.std_goal_id=a.dst_id
				   order by 2,11'

print @SQLMAPPING

EXEC sp_executesql @SQLMAPPING

set @SQLMAPPING = 'select text1, count(*) as count from '+@DstServer+'.dbo.'+@ProcessTableName+'  as a
where std_goal_id in (select dst_id from #tempmapping2)
group by text1'

print @SQLMAPPING

EXEC sp_executesql @SQLMAPPING
----------------------------------------------------------------


-----------------------

-----------------------

--Select * from cp_std_need
set @ProcessTableName = 'cp_std_need'

select 'Care Plans' as MODULE,@ProcessTableName as TABLENAME

IF OBJECT_ID('tempdb..#tempmapping3') IS NOT NULL 
DROP TABLE #tempmapping3

IF OBJECT_ID('tempdb..#tempmappingdistinct3') IS NOT NULL 
DROP TABLE #tempmappingdistinct3

create table #tempmapping3 (
src_id bigint,
dst_id bigint,
corporate CHAR(1),
MappingTableName varchar (100)
)

create table #tempmappingdistinct3 (
src_id bigint,
dst_id bigint
)

--DECLARE MyCursor CURSOR FOR
--select TABLE_NAME from INFORMATION_SCHEMA.TABLES
--where TABLE_NAME LIKE '%'+@CaseNumber+'%COMMON_CODE'

EXEC ('DECLARE MyCursor CURSOR FOR
select TABLE_NAME from '+ @DstServer + '.INFORMATION_SCHEMA.TABLES
where TABLE_NAME LIKE ''%'+ @CaseNumber +'%'+@ProcessTableName+'''
')


OPEN MyCursor 
FETCH NEXT FROM MyCursor INTO @TableName
WHILE(@@Fetch_Status = 0)

BEGIN



SET @SQLMAPPING = 'insert into #tempmapping3 (src_id, dst_id, corporate, MappingTableName) select src_id, dst_id, corporate,'''+@TableName+'''   from ' + @DstServer + '.dbo.' + @TableName

PRINT @SQLMAPPING
EXEC (@SQLMAPPING)

FETCH NEXT FROM MyCursor INTO @TableName
END
CLOSE MyCursor
DEALLOCATE MyCursor

select src_id, dst_id, corporate as Merged, MappingTableName from #tempmapping3
order by 1,3,4



/*
select * from [dbo].[mergeJoinsMaster]
where TableName = 'cp_std_library'
order by 1
select * from @vStagingDBName+[dbo].[mergeTablesMaster]
where TableName = 'cp_std_library'
order by 1
*/



SET @SQLMAPPING ='select * from '+@vStagingDBName+'.[dbo].[mergeTablesMaster]
where TableName = '''+@ProcessTableName+''' order by 1' 

print @SQLMAPPING
EXEC sp_executesql @SQLMAPPING

set @SQLMAPPING = 'select a.SRC_ID, src.text1 as SRC_description, src.fac_id as SRC_Fac_ID,src.reg_id as SRC_reg_id,src.state_code as SRC_state_code,
					      a.dst_id, dst.text1 as DST_description, dst.fac_id as DST_Fac_ID,dst.reg_id as DST_reg_id,dst.state_code as DST_state_code, a.corporate as Merged , MappingTableName as MappingTable
from #tempmapping3 as a
				   join '+@SrcServer+'.dbo.'+@ProcessTableName+' as src on src.std_need_id=a.src_id
				   join '+@DstServer+'.dbo.'+@ProcessTableName+' as dst on dst.std_need_id=a.dst_id
				   order by 2,11'

print @SQLMAPPING

EXEC sp_executesql @SQLMAPPING

set @SQLMAPPING = 'select text1, count(*) as count from '+@DstServer+'.dbo.'+@ProcessTableName+'  as a
where std_need_id in (select dst_id from #tempmapping3)
group by text1'

print @SQLMAPPING

EXEC sp_executesql @SQLMAPPING
----------------------------------------------------------------

--Select * from cp_std_intervention
set @ProcessTableName = 'cp_std_intervention'

select 'Care Plans' as MODULE,@ProcessTableName as TABLENAME

IF OBJECT_ID('tempdb..#tempmapping4') IS NOT NULL 
DROP TABLE #tempmapping4

IF OBJECT_ID('tempdb..#tempmappingdistinct4') IS NOT NULL 
DROP TABLE #tempmappingdistinct4

create table #tempmapping4 (
src_id bigint,
dst_id bigint,
corporate CHAR(1),
MappingTableName varchar (100)
)

create table #tempmappingdistinct4 (
src_id bigint,
dst_id bigint
)

--DECLARE MyCursor CURSOR FOR
--select TABLE_NAME from INFORMATION_SCHEMA.TABLES
--where TABLE_NAME LIKE '%'+@CaseNumber+'%COMMON_CODE'

EXEC ('DECLARE MyCursor CURSOR FOR
select TABLE_NAME from '+ @DstServer + '.INFORMATION_SCHEMA.TABLES
where TABLE_NAME LIKE ''%'+ @CaseNumber +'%'+@ProcessTableName+'''
')


OPEN MyCursor 
FETCH NEXT FROM MyCursor INTO @TableName
WHILE(@@Fetch_Status = 0)

BEGIN



SET @SQLMAPPING = 'insert into #tempmapping4 (src_id, dst_id, corporate, MappingTableName) select src_id, dst_id, corporate,'''+@TableName+'''   from ' + @DstServer + '.dbo.' + @TableName

PRINT @SQLMAPPING
EXEC (@SQLMAPPING)

FETCH NEXT FROM MyCursor INTO @TableName
END
CLOSE MyCursor
DEALLOCATE MyCursor

select src_id, dst_id, corporate as Merged, MappingTableName from #tempmapping4
order by 1,3,4



/*
select * from [dbo].[mergeJoinsMaster]
where TableName = 'cp_std_library'
order by 1
select * from @vStagingDBName+[dbo].[mergeTablesMaster]
where TableName = 'cp_std_library'
order by 1
*/



SET @SQLMAPPING ='select * from '+@vStagingDBName+'.[dbo].[mergeTablesMaster]
where TableName = '''+@ProcessTableName+''' order by 1' 

print @SQLMAPPING
EXEC sp_executesql @SQLMAPPING

set @SQLMAPPING = 'select a.SRC_ID, src.text1 as SRC_description, src.fac_id as SRC_Fac_ID,src.reg_id as SRC_reg_id,src.state_code as SRC_state_code,
					      a.dst_id, dst.text1 as DST_description, dst.fac_id as DST_Fac_ID,dst.reg_id as DST_reg_id,dst.state_code as DST_state_code, a.corporate as Merged , MappingTableName as MappingTable
from #tempmapping4 as a
				   join '+@SrcServer+'.dbo.'+@ProcessTableName+' as src on src.std_intervention_id=a.src_id
				   join '+@DstServer+'.dbo.'+@ProcessTableName+' as dst on dst.std_intervention_id=a.dst_id
				   order by 2,11'

print @SQLMAPPING

EXEC sp_executesql @SQLMAPPING

set @SQLMAPPING = 'select text1, count(*) as count from '+@DstServer+'.dbo.'+@ProcessTableName+'  as a
where std_intervention_id in (select dst_id from #tempmapping4)
group by text1'

print @SQLMAPPING

EXEC sp_executesql @SQLMAPPING
----------------------------------------------------------------

