
/*
--------------------------------------------------------------------------------------------------------------------

--		To be executed in [vmuspassvjob001.pccprod.local].dba_admin and here only

--		Please note that this is not the production org instances

*/

/*
--------------------------------------------------------------------------------------------------------------------
--		2. Job Enable, to be done on the next day during business hours after go-live
*/


exec [dbo].[sproc_EnableDisable_POC_EMAR] 'CCHH','1993371',1 --dst org, NS Case #
exec [dbo].[sproc_EnableDisable_DBMaintenanceJobs] 'CCHH','1993371',1,NULL,NULL --dst org, NS Case #


/* 
 DBA - Maintenance - Update Stats job has been enabled for org -CCHH. 
  
 
 
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\gunald(1993371)', '' ,'POC and EMAR Backup','CCHH','1993371') 
Select name from [pccsql-use2-prod-w22-cli0021.4c4638f8e26f.database.windows.net].msdb.dbo.sysjobs where name in ('DBA - Maintenance - Update Stats') 
EXEC [pccsql-use2-prod-w22-cli0021.4c4638f8e26f.database.windows.net].msdb.dbo.sp_update_job  @job_name = N'DBA - Maintenance - Update Stats', @enabled = 1 ;
Select name from [pccsql-use2-prod-w22-cli0021.4c4638f8e26f.database.windows.net].msdb.dbo.sysjobs where name in ('DBA - Maintenance - Indexes') 
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\gunald(1993371)', 'DBA - Maintenance - Update Stats job has been enabled for org -CCHH. ' ,'Indexes and Statistics','CCHH','1993371') 

Completion time: 2022-03-03T01:36:12.7054445-05:00



*/