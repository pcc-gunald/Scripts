
/*
--------------------------------------------------------------------------------------------------------------------

--		To be executed in [vmuspassvjob001.pccprod.local].dba_admin and here only

--		Please note that this is not the production org instances

*/

/*
--------------------------------------------------------------------------------------------------------------------
--		2. Job Enable, to be done on the next day during business hours after go-live
*/


exec [dbo].[sproc_EnableDisable_POC_EMAR] 'ELCC','1994569',1 --dst org, NS Case #
exec [dbo].[sproc_EnableDisable_DBMaintenanceJobs] 'ELCC','1994569',1,NULL,NULL --dst org, NS Case #


/* 
 DBA - Maintenance - Update Stats job has been enabled for org -ELCC. 
  
 
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\gunald(1994569)', '' ,'POC and EMAR Backup','ELCC','1994569') 
Select name from [pccsql-use2-prod-w20-cli0007.3055e0bc69f6.database.windows.net].msdb.dbo.sysjobs where name in ('DBA - Maintenance - Update Stats') 
EXEC [pccsql-use2-prod-w20-cli0007.3055e0bc69f6.database.windows.net].msdb.dbo.sp_update_job  @job_name = N'DBA - Maintenance - Update Stats', @enabled = 1 ;
Select name from [pccsql-use2-prod-w20-cli0007.3055e0bc69f6.database.windows.net].msdb.dbo.sysjobs where name in ('DBA - Maintenance - Indexes') 
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\gunald(1994569)', 'DBA - Maintenance - Update Stats job has been enabled for org -ELCC. ' ,'Indexes and Statistics','ELCC','1994569') 

Completion time: 2022-03-02T21:52:16.1403461-05:00




*/