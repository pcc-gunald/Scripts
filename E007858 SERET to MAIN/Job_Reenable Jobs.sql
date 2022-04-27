
/*
--------------------------------------------------------------------------------------------------------------------

--		To be executed in [vmuspassvjob001.pccprod.local].dba_admin and here only

--		Please note that this is not the production org instances

*/

/*
--------------------------------------------------------------------------------------------------------------------
--		2. Job Enable, to be done on the next day during business hours after go-live
*/


exec [dbo].[sproc_EnableDisable_POC_EMAR] 'MAIN','1991291',1 --dst org, NS Case #
exec [dbo].[sproc_EnableDisable_DBMaintenanceJobs] 'MAIN','1991291',1,NULL,NULL --dst org, NS Case #


/*
DBA - Maintenance - Update Stats
DBA - Maintenance - Update Stats job has been enabled for org -MAIN. 

  


 
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\gunald(1991291)', '' ,'POC and EMAR Backup','MAIN','1991291') 
Select name from [pccsql-use2-prod-w25-cli0022.2d62ac5c7643.database.windows.net].msdb.dbo.sysjobs where name in ('DBA - Maintenance - Update Stats') 
EXEC [pccsql-use2-prod-w25-cli0022.2d62ac5c7643.database.windows.net].msdb.dbo.sp_update_job  @job_name = N'DBA - Maintenance - Update Stats', @enabled = 1 ;
Select name from [pccsql-use2-prod-w25-cli0022.2d62ac5c7643.database.windows.net].msdb.dbo.sysjobs where name in ('DBA - Maintenance - Indexes') 
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\gunald(1991291)', 'DBA - Maintenance - Update Stats job has been enabled for org -MAIN. ' ,'Indexes and Statistics','MAIN','1991291') 

Completion time: 2022-01-27T17:45:37.5086990-05:00

*/