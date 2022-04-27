--After Refresh and Before Go-Live

--> Disable DB Maintainance Jobs

--Connect to [vmuspassvjob001.pccprod.local].dba_admin	
EXEC [dbo].[sproc_EnableDisable_POC_EMAR] 'PGHC','1991232',0 
EXEC [dbo].[sproc_EnableDisable_DBMaintenanceJobs] 'PGHC','1991232',0,'2022-03-01 12:00:00','2022-03-02 04:00:00'

/*
 
 
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\chaudas(1991232)', '' ,'POC and EMAR Backup','PGHC','1991232') 

Completion time: 2022-02-28T08:31:45.5022988-05:00

Select msdb.dbo.agent_datetime(js.next_run_date, js.next_run_time) 
From [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].msdb.dbo.sysjobs as jb
Inner Join [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].msdb.dbo.sysjobschedules as js on js.job_id = jb.job_id
Inner Join [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].msdb.dbo.sysschedules as sc on js.schedule_id = sc.schedule_id
where jb.name in ('DBA - Maintenance - Update Stats') and jb.enabled=1
Select msdb.dbo.agent_datetime(js.next_run_date, js.next_run_time) 
From [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].msdb.dbo.sysjobs as jb
Inner Join [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].msdb.dbo.sysjobschedules as js on js.job_id = jb.job_id
Inner Join [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].msdb.dbo.sysschedules as sc on js.schedule_id = sc.schedule_id
where jb.name in ('DBA - Maintenance - Indexes') and jb.enabled=1
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\chaudas(1991232)', 'No Action Taken' ,'Index and Statistics','PGHC','1991232') 

Completion time: 2022-02-28T08:32:18.5109685-05:00



*/

--> Replace [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214 with [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi
--> Replace [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net] with [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net]
--> Replace test_usei1214 with us_pghc_multi

--> Update LoadEIMaster_Automation

UPDATE [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_Automation
SET  Dstorgcode = 'PGHC',DstOrgCodeProd = 'PGHC', stagingcompleted = 0, ProdRun  = '1'
--select * from [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_Automation
WHERE PMO_Number = '59277'

--> Uncomment the OMNI script (if OMNI integration to be re-enabled) in the 7 PostMergeScriptDestination_PostScriptsMerged script

DECLARE @return_value INT
,@vRequestId INT
,@restoretime DATETIME = getdate() --as of when we want the restore to be done
,@client_database_name NVARCHAR(50) = 'us_sava_multi' --Name of the DB we want to restore
,@client_server_name NVARCHAR(100)  = '[vmuspassvtscon3.pccprod.local]PROD1' --Instance name from where we want the resore
,@destination_server NVARCHAR(100) = '[vmuspassvtscon3.pccprod.local]' --Destination Instance name where we want the restore to happen
,@destination_database_name NVARCHAR(100) = 'test_usei3sava1' --Name of the destination DB
,@Created_by NVARCHAR(50) = 'chaudas' --Username of the user logging the restore job
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
exec [vmuspassvjob001.pccprod.local].[azure_restore].[dbo].[check_status] @requestid =???? , --ID of the job you just created
@status=@statusout output , @status_message=@statusmessageout output
select @statusout,@statusmessageout

/*


*/

--[vmuspassvtscon3.pccprod.local]PROD1

USE [master] 
GO 
ALTER DATABASE test_usei3sava1 MODIFY FILE ( NAME = N'????????', SIZE = 513GB ) 
GO

/*


*/

--restore staging

--Run on [USTMPLT\PRODTEMPLATE]
BACKUP DATABASE us_template_pccsingle_tmpltTX TO 
	URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/full_us_template_pccsingle_tmpltTX_59277.bak' 
WITH compression,
ENCRYPTION (ALGORITHM = AES_256, SERVER CERTIFICATE = backup_certificate), 
STATS = 5 ,COPY_ONLY, CHECKSUM

/*




*/

--Run on Source server - [vmuspassvtscon3.pccprod.local]

USE [master] 

IF EXISTS(select * from sys.databases where name='pcc_staging_db59277')
DROP DATABASE pcc_staging_db59277

RESTORE DATABASE pcc_staging_db59277 
	FROM URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/full_us_template_pccsingle_tmpltTX_59277.bak'

/*


*/

--Sec PreImport (if applicable)
--Go to DS Helper