
/*
--------------------------------------------------------------------------------------------------------------------

--		To be executed in [vmuspassvjob001.pccprod.local].dba_admin and here only

--		Please note that this is not the production org instances

*/

/*
--------------------------------------------------------------------------------------------------------------------
--		2. Job Enable, to be done on the next day during business hours after go-live
*/


exec [dbo].[sproc_EnableDisable_POC_EMAR] 'ASHC','1998662',1 --dst org, NS Case #
exec [dbo].[sproc_EnableDisable_DBMaintenanceJobs] 'ASHC','1998662',1,NULL,NULL --dst org, NS Case #


/* 
DBA - Maintenance - Update Stats job has been enabled for org -ASHC. 
  
 
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\gunald(1998662)', '' ,'POC and EMAR Backup','ASHC','1998662') 
Select name from [pccsql-use2-prod-w22-cli0013.4c4638f8e26f.database.windows.net].msdb.dbo.sysjobs where name in ('DBA - Maintenance - Update Stats') 
EXEC [pccsql-use2-prod-w22-cli0013.4c4638f8e26f.database.windows.net].msdb.dbo.sp_update_job  @job_name = N'DBA - Maintenance - Update Stats', @enabled = 1 ;
Select name from [pccsql-use2-prod-w22-cli0013.4c4638f8e26f.database.windows.net].msdb.dbo.sysjobs where name in ('DBA - Maintenance - Indexes') 
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\gunald(1998662)', 'DBA - Maintenance - Update Stats job has been enabled for org -ASHC. ' ,'Indexes and Statistics','ASHC','1998662') 

Completion time: 2022-03-16T04:03:31.6689457-04:00



*/