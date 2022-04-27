
/*
--------------------------------------------------------------------------------------------------------------------

--		To be executed in [vmuspassvjob001.pccprod.local].dba_admin and here only

--		Please note that this is not the production org instances

*/

/*
--------------------------------------------------------------------------------------------------------------------
--		2. Job Enable, to be done on the next day during business hours after go-live
*/


exec [dbo].[sproc_EnableDisable_POC_EMAR] 'MEA','1995870',1 --dst org, NS Case #
exec [dbo].[sproc_EnableDisable_DBMaintenanceJobs] 'MEA','1995870',1,NULL,NULL --dst org, NS Case #


/* 
DBA - Maintenance - Update Stats job has been enabled for org -MEA. 
  
  INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\gunald(1995870)', '' ,'POC and EMAR Backup','MEA','1995870') 
Select name from [pccsql-use2-prod-w19-cli0003.3055e0bc69f6.database.windows.net].msdb.dbo.sysjobs where name in ('DBA - Maintenance - Update Stats') 
EXEC [pccsql-use2-prod-w19-cli0003.3055e0bc69f6.database.windows.net].msdb.dbo.sp_update_job  @job_name = N'DBA - Maintenance - Update Stats', @enabled = 1 ;
Select name from [pccsql-use2-prod-w19-cli0003.3055e0bc69f6.database.windows.net].msdb.dbo.sysjobs where name in ('DBA - Maintenance - Indexes') 
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\gunald(1995870)', 'DBA - Maintenance - Update Stats job has been enabled for org -MEA. ' ,'Indexes and Statistics','MEA','1995870') 

Completion time: 2022-03-15T04:09:19.2061100-04:00


*/