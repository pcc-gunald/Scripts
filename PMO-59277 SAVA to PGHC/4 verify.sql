IF OBJECT_ID(N'tempdb..#new') IS NOT NULL
BEGIN DROP TABLE #new END 
GO

IF OBJECT_ID(N'tempdb..#orig') IS NOT NULL
BEGIN DROP TABLE #orig END 
GO


--ON SRC
SELECT t.name AS table_name, i.rows 
into #orig
--select *
FROM [[vmuspassvtscon3.pccprod.local]].pcc_staging_db59277.sys.tables AS t with (nolock)
INNER JOIN [[vmuspassvtscon3.pccprod.local]].pcc_staging_db59277.sys.sysindexes AS i with (nolock) ON t.object_id = i.id AND i.indid < 2
where i.rows > 0 and t.name not like 'if_us%' and t.name not like 'case%'
order by 2 desc  

--ON DST
SELECT t.name AS table_name, i.rows 
into #new
--select *
FROM [[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net]].pcc_staging_db59277.sys.tables AS t with (nolock)
INNER JOIN [[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net]].pcc_staging_db59277.sys.sysindexes AS i with (nolock) ON t.object_id = i.id AND i.indid < 2
where i.rows > 0 and t.name not like 'if_us%' and t.name not like 'case%'
order by 2 desc  

------TABLES HAVE DATA IN BOTH WITH DIFFERENT ROW COUNTS
select a.*,b.*
--into pcc_temp_storage.test_usei701o.tables_withDiscrepancies
from #orig a inner join #new b
on a.table_name = b.table_name
where a.rows <> b.rows
--and a.table_name not like  '%gl_%'
--and a.table_name not like '%ar_%' 
--and a.table_name not like '%ap_%' 
--and a.table_name not like '%cp_prn%' 
--and a.table_name not like '%cp_qshift%' 
--and a.table_name not like '%ta_%' 
--and  a.table_name not like '%as_%'
--and  a.table_name not like '%pho_%'
--and  a.table_name not like '%diag_%'
--and  a.table_name not like '%cp_%'
--and  a.table_name  like '%_audit%'
--and  a.table_name  like '%_fac%'
order by 1

------TABLES HAVE DATA IN SRC BUT NOT IN DST------
select * from #orig
where table_name not in (select table_name from #new)

------TABLES HAVE DATA IN DST BUT NOT IN SRC------
select * from #new
where table_name not in (select table_name from #orig)

/* Latest Test Results



*/

/* Go Live Results



*/