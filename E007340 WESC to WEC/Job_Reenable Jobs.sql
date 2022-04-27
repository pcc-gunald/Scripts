
/*
--------------------------------------------------------------------------------------------------------------------

--		To be executed in [vmuspassvjob001.pccprod.local].dba_admin and here only

--		Please note that this is not the production org instances

*/

/*
--------------------------------------------------------------------------------------------------------------------
--		2. Job Enable, to be done on the next day during business hours after go-live
*/


exec [dbo].[sproc_EnableDisable_POC_EMAR] 'WEC','1993311',1 --dst org, NS Case #
exec [dbo].[sproc_EnableDisable_DBMaintenanceJobs] 'WEC','1993311',1,NULL,NULL --dst org, NS Case #


/* 
 
  
 
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\morcea(1993311)', '' ,'POC and EMAR Backup','WEC','1993311') 
Select name from [pccsql-use2-prod-w30-cli0015.cbafa2b80e84.database.windows.net].msdb.dbo.sysjobs where name in ('DBA - Maintenance - Update Stats') 
EXEC [pccsql-use2-prod-w30-cli0015.cbafa2b80e84.database.windows.net].msdb.dbo.sp_update_job  @job_name = N'DBA - Maintenance - Update Stats', @enabled = 1 ;
Select name from [pccsql-use2-prod-w30-cli0015.cbafa2b80e84.database.windows.net].msdb.dbo.sysjobs where name in ('DBA - Maintenance - Indexes') 
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\morcea(1993311)', 'DBA - Maintenance - Update Stats job has been enabled for org -WEC. ' ,'Indexes and Statistics','WEC','1993311') 

Completion time: 2022-02-08T07:31:21.9722534-05:00




*/