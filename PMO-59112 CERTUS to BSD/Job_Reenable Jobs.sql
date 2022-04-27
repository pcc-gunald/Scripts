
/*
--------------------------------------------------------------------------------------------------------------------

--		To be executed in [vmuspassvjob001.pccprod.local].dba_admin and here only

--		Please note that this is not the production org instances

*/

/*
--------------------------------------------------------------------------------------------------------------------
--		2. Job Enable, to be done on the next day during business hours after go-live
*/


exec [dbo].[sproc_EnableDisable_POC_EMAR] 'BSD','1989164',1 --dst org, NS Case #
exec [dbo].[sproc_EnableDisable_DBMaintenanceJobs] 'BSD','1989164',1,NULL,NULL --dst org, NS Case #


/*
DBA - Maintenance - Update Stats
DBA - Maintenance - Update Stats job has been enabled for org -BSD. 
  

 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\gunald(1989164)', '' ,'POC and EMAR Backup','BSD','1989164') 
Select name from [pccsql-use2-prod-w22-cli0005.4c4638f8e26f.database.windows.net].msdb.dbo.sysjobs where name in ('DBA - Maintenance - Update Stats') 
EXEC [pccsql-use2-prod-w22-cli0005.4c4638f8e26f.database.windows.net].msdb.dbo.sp_update_job  @job_name = N'DBA - Maintenance - Update Stats', @enabled = 1 ;
Select name from [pccsql-use2-prod-w22-cli0005.4c4638f8e26f.database.windows.net].msdb.dbo.sysjobs where name in ('DBA - Maintenance - Indexes') 
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\gunald(1989164)', 'DBA - Maintenance - Update Stats job has been enabled for org -BSD. ' ,'Indexes and Statistics','BSD','1989164') 

Completion time: 2022-02-08T04:13:42.0685372-05:00


*/