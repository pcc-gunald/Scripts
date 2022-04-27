
/*
--------------------------------------------------------------------------------------------------------------------

--		To be executed in [vmuspassvjob001.pccprod.local].dba_admin and here only

--		Please note that this is not the production org instances

*/

/*
--------------------------------------------------------------------------------------------------------------------
--		2. Job Enable, to be done on the next day during business hours after go-live
*/


exec [dbo].[sproc_EnableDisable_POC_EMAR] 'VIEW','2003522',1 --dst org, NS Case #
exec [dbo].[sproc_EnableDisable_DBMaintenanceJobs] 'VIEW','2003522',1,NULL,NULL --dst org, NS Case #


/* 
DBA - Maintenance - Update Stats job has been enabled for org -VIEW. 
 
  INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\gunald(2003522)', '' ,'POC and EMAR Backup','VIEW','2003522') 
Select name from [pccsql-use2-prod-w27-cli0027.851c37dfbe45.database.windows.net].msdb.dbo.sysjobs where name in ('DBA - Maintenance - Update Stats') 
EXEC [pccsql-use2-prod-w27-cli0027.851c37dfbe45.database.windows.net].msdb.dbo.sp_update_job  @job_name = N'DBA - Maintenance - Update Stats', @enabled = 1 ;
Select name from [pccsql-use2-prod-w27-cli0027.851c37dfbe45.database.windows.net].msdb.dbo.sysjobs where name in ('DBA - Maintenance - Indexes') 
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\gunald(2003522)', 'DBA - Maintenance - Update Stats job has been enabled for org -VIEW. ' ,'Indexes and Statistics','VIEW','2003522') 

Completion time: 2022-04-14T02:04:18.6630445-04:00


*/