--After Refresh and Before Go-Live

--> Disable DB Maintainance Jobs

--Connect to [vmuspassvjob001.pccprod.local].dba_admin	
EXEC [vmuspassvjob001.pccprod.local].dba_admin.[dbo].[sproc_EnableDisable_POC_EMAR] 'usei23','1995478',0 
(No column name)
 

(1 row affected)
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'linksvracct(1995478)', '' ,'POC and EMAR Backup','usei23','1995478') 

Completion time: 2022-02-15T17:56:47.6839774-05:00

EXEC [vmuspassvjob001.pccprod.local].dba_admin.[dbo].[sproc_EnableDisable_DBMaintenanceJobs] 'usei23','1995478',0,'2022-02-15 22:00:00.000','2022-02-16 08:00:00.000'

(No column name)
2022-02-20 21:00:00.000
(No column name)
(No column name)
No Action Taken
Select msdb.dbo.agent_datetime(js.next_run_date, js.next_run_time) 
From [pccsql-use2-prod-w25-cli0021.2d62ac5c7640.database.windows.net].msdb.dbo.sysjobs as jb
Inner Join [pccsql-use2-prod-w25-cli0021.2d62ac5c7640.database.windows.net].msdb.dbo.sysjobschedules as js on js.job_id = jb.job_id
Inner Join [pccsql-use2-prod-w25-cli0021.2d62ac5c7640.database.windows.net].msdb.dbo.sysschedules as sc on js.schedule_id = sc.schedule_id
where jb.name in ('DBA - Maintenance - Update Stats') and jb.enabled=1

(1 row affected)
Select msdb.dbo.agent_datetime(js.next_run_date, js.next_run_time) 
From [pccsql-use2-prod-w25-cli0021.2d62ac5c7640.database.windows.net].msdb.dbo.sysjobs as jb
Inner Join [pccsql-use2-prod-w25-cli0021.2d62ac5c7640.database.windows.net].msdb.dbo.sysjobschedules as js on js.job_id = jb.job_id
Inner Join [pccsql-use2-prod-w25-cli0021.2d62ac5c7640.database.windows.net].msdb.dbo.sysschedules as sc on js.schedule_id = sc.schedule_id
where jb.name in ('DBA - Maintenance - Indexes') and jb.enabled=1
SELECT @nextrun_date=msdb.dbo.agent_datetime(js.next_run_date, js.next_run_time) 
From [pccsql-use2-prod-w25-cli0021.2d62ac5c7640.database.windows.net].msdb.dbo.sysjobs as jb
Inner Join [pccsql-use2-prod-w25-cli0021.2d62ac5c7640.database.windows.net].msdb.dbo.sysjobschedules as js on js.job_id = jb.job_id
Inner Join [pccsql-use2-prod-w25-cli0021.2d62ac5c7640.database.windows.net].msdb.dbo.sysschedules as sc on js.schedule_id = sc.schedule_id
where jb.name in ('DBA - Maintenance - Update Stats') and jb.enabled=1

(0 rows affected)

(1 row affected)
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'linksvracct(1995478)', 'No Action Taken' ,'Index and Statistics','usei23','1995478') 

Completion time: 2022-02-15T17:58:00.3668710-05:00

/*
 
*/


--> Uncomment the OMNI script (if OMNI integration to be re-enabled) in the 7 PostMergeScriptDestination_PostScriptsMerged script

DECLARE @return_value INT
,@vRequestId INT
,@restoretime DATETIME = getdate() --as of when we want the restore to be done
,@client_database_name NVARCHAR(50) = 'us_fve_multi' --Name of the DB we want to restore
,@client_server_name NVARCHAR(100)  = 'pccsql-use2-prod-w30-cli0001.cbafa2b4e84.database.windows.net' --Instance name from where we want the resore
,@destination_server NVARCHAR(100) = 'pccsql-use2-prod-ssv-tscon06.b4ea653240a9.database.windows.net' --Destination Instance name where we want the restore to happen
,@destination_database_name NVARCHAR(100) = 'test_usei1188' --Name of the destination DB
,@Created_by NVARCHAR(50) = 'signhp' --Username of the user logging the restore job
,@statusout NVARCHAR(100)
,@statusmessageout NVARCHAR(100)

EXEC @return_value = [vmuspassvjob001.pccprod.local].[azure_restore].[dbo].[create_restore_request] @source_instance = @client_server_name
,@source_Database_name = @client_database_name
,@destination_instance = @destination_server
,@destination_database_name = @destination_database_name
,@point_in_time = @restoretime
,@requestor = @Created_by
,@requestid = @vRequestId OUTPUT
 
select RequestId = @vRequestId;

declare @statusout char(1), @statusmessageout varchar(2000)
exec [vmuspassvjob001.pccprod.local].[azure_restore].[dbo].[check_status] @requestid =383597 , --ID of the job you just created
@status=@statusout output , @status_message=@statusmessageout output
select @statusout,@statusmessageout

/*


*/

--Sec PreImport (if applicable)
--Go to DS Helper