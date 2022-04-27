--If sec user preimport --> Resident Identifier, Contact
--If NO sec user preimport --> Security Roles

--Check if there was any error on Source to Staging

select * from [vmuspassvtscon3.pccprod.local].pcc_staging_db59277.dbo.mergelog
where msg like '%mergeerror%' and module <> 'Pre Merge Script Src'


select * from [[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net]].pcc_staging_db59277.dbo.mergelog
where msg like '%mergeerror%' and module <> 'Pre Merge Script Src'

-- Source to Staging (Run on Staging DB)

DECLARE @first_module varchar(max) = 'Security Roles'

SELECT	(select max(msgtime) from [[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net]].pcc_staging_db59277.dbo.mergelog) Staging_StartTime,
		(select min(msgtime) from [[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net]].pcc_staging_db59277.dbo.mergelog)	Staging_EndTime,
		CAST(DATEDIFF(minute, (select min(msgtime) from [[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net]].pcc_staging_db59277.dbo.mergelog),(select max(msgtime) from [[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net]].pcc_staging_db59277.dbo.mergelog)) as varchar) + ' minutes' AS Staging_RunTime,
		convert(varchar,(select max(msgtime) from [[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net]].pcc_staging_db59277.dbo.mergelog),21) + ' to ' + convert(varchar,(select min(msgtime) from [[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net]].pcc_staging_db59277.dbo.mergelog),21) as Staging_EnhancedTime

-- Offline Inserts (Run on Destination DB)

--select * from  [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.stagingmergelog order by rno

select top(1) rno,ModuleName , msgtime into #t0 
from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.StagingMergeLog 
where runid = (select max(runid) from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.StagingMergeLog ) order by 1

set identity_insert #t0 on

insert into #t0 (rno,ModuleName , msgtime) 
select top(1) rno,ModuleName , msgtime  
from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.StagingMergeLog 
where runid = (select max(runid) from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.StagingMergeLog ) and 
modulename =  (select modulename from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.StagingMergeLog where 
rno = (SELECT min(rno-1) FROM [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.stagingmergelog 
WHERE modulename = 'Resident Identifier, Contact' 
AND rno >= (SELECT min(rno) - 1 FROM [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.stagingmergelog 
WHERE modulename = 'Phys Orders' and runid = (select max(runid) FROM [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.stagingmergelog )))) order by 1

set identity_insert #t0 off

select	MIN(msgtime) as Offline_StartTime, 
		MAX(msgtime) as Offline_EndTime,
		CASE
			WHEN DATEDIFF(MINUTE, MIN(msgtime), MAX(msgtime)) = 0
				THEN cast(DATEDIFF(second, MIN(msgtime), MAX(msgtime)) as varchar) + ' seconds'
			WHEN DATEDIFF(MINUTE, MIN(msgtime), MAX(msgtime)) > 0
				THEN cast(DATEDIFF(MINUTE, MIN(msgtime), MAX(msgtime)) as varchar) + ' minutes'
			END AS OfflineInsertMins, 
		convert(varchar,MIN(msgtime),21) + ' to ' + convert(varchar,MAX(msgtime),21) as Offline_EnhancedUpdate
from #t0
DROP table #t0

-- Online Inserts (Run on Destination DB)

--select * from  [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.stagingmergelog order by rno

SELECT	CAST(SrcFacId as varchar) + ' to ' + CAST(DstFacId as varchar) as facility, 
		t.StartTime Online_StartTime,
		t.EndTime Online_EndTime,
		REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,t.[TotalRows]),1), '.00','') as RowsInserted,
		CAST(t.runtime as varchar) + ' minutes' as Online_RunTime,
		convert(varchar,t.StartTime,21) + ' to ' + convert(varchar,t.EndTime,21) Online_EnhancedTime
FROM [vmuspassvtsjob1.pccprod.local].DS_Merge_Master.dbo.LoadEIMaster_Automation
OUTER APPLY
(
    SELECT
        DATEDIFF(MINUTE, MIN(msgtime), MAX(msgtime)) AS [RunTime]
        ,SUM(rowsinserted) AS [TotalRows]
		,MIN(msgtime) as StartTime
		,MAX(msgtime) as EndTime 
    FROM [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.StagingMergeLog
    WHERE msg LIKE CONCAT('% Multi_Fac_Id=', DstFacId, CHAR(13), CHAR(10), '%')
        OR msg LIKE CONCAT('% Multi_Fac_Id=', DstFacId)
) AS t
WHERE PMO_Group_Id in (SELECT pmo_group_id FROM [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_PMO_Groups WHERE PMONumber = '59277')


--To update the smarsheet for Kathleen - storage and %

--Running on Destination Production
--Connect to [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net]

--Once you have the staging DB generated with log shrank, please provide the size of staging DB on the same Smartsheet and check the size of the staging DB against the result of the 
--following query (can be executed on any DB in the instance of your destination DB). If the size of staging DB will make DiskFreePercentage go below 10 (percent) please let me know and 
--I’ll contact Saas Ops. Please note in current query it shows the current free percentage and we’ll need to estimate the new percentage.

--The calculation for projected DiskFreePercentage after Data Copy will be: (FreeSpaceInGB - sizeOfStagingDB *2)/TotalSpaceInGB *100

--Running on Destination PROD @ [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net]

--SELECT DISTINCT dovs.logical_volume_name AS LogicalName,
--dovs.volume_mount_point AS Drive,
--CONVERT(INT,dovs.available_bytes/1024.0/1024.0/1024.0) AS FreeSpaceInGB,
--CONVERT(INT,dovs.total_bytes/1024.0/1024.0/1024.0) AS TotalSpaceInGB,
--cast(CONVERT(decimal(10,2),CONVERT(float,dovs.available_bytes)/dovs.total_bytes*100.0) as varchar) + '%' as DiskFreePercentage
--FROM sys.master_files mf
--CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.FILE_ID) dovs
--WHERE volume_mount_point like '%Data%'
--ORDER BY FreeSpaceInGB ASC

select CONVERT(decimal(10,2),avg((reserved_storage_mb - storage_space_used_mb)/reserved_storage_mb * 100.0)) as storage_percentage_free, 
--CONVERT(INT,avg(storage_space_used_mb) / 1024) as storage_used_GB, 
CONVERT(INT,avg(reserved_storage_mb - storage_space_used_mb)) / 1024 as storage_free_GB, 
CONVERT(INT,avg(reserved_storage_mb) / 1024) as reserved_storage_GB
from (select * from master.sys.server_resource_stats 
where start_time > dateadd(minute , -10, getutcdate())) t
------------------------------------------------------------------------------------

select 
'Amount of Storage in Prod: storage_percentage_free: ' + cast(CONVERT(decimal(10,2),avg((reserved_storage_mb - storage_space_used_mb)/reserved_storage_mb * 100.0)) as varchar(20)) + 
'%, storage_free: ' + cast(CONVERT(INT,avg(reserved_storage_mb - storage_space_used_mb)) / 1024  as varchar(20)) + 
'GB, reserved_storage:' + cast(CONVERT(INT,avg(reserved_storage_mb) / 1024)  as varchar(20)) + 'GB'
from (select * from master.sys.server_resource_stats 
where start_time > dateadd(minute , -10, getutcdate())) t
