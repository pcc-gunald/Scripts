
/*
--------------------------------------------------------------------------------------------------------------------

--		To be executed in [vmuspassvjob001.pccprod.local].dba_admin and here only

--		Please note that this is not the production org instances

*/

/*
--------------------------------------------------------------------------------------------------------------------
--		2. Job Enable, to be done on the next day during business hours after go-live
*/


exec [dbo].[sproc_EnableDisable_POC_EMAR] 'TRANQ','1999808',1 --dst org, NS Case #
exec [dbo].[sproc_EnableDisable_DBMaintenanceJobs] 'TRANQ','1999808',1,NULL,NULL --dst org, NS Case #


/*
DBA - Maintenance - Update Stats
DBA - Maintenance - Update Stats job has been enabled for org -BSD. DBA - Maintenance - Indexes job has been enabled for org -BSD.  

 
 
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\morcea(1994995)', '' ,'POC and EMAR Backup','MLMGMT','1994995') 
Select name from [pccsql-use2-prod-w26-cli0001.d9c23db323d7.database.windows.net].msdb.dbo.sysjobs where name in ('DBA - Maintenance - Update Stats') 
EXEC [pccsql-use2-prod-w26-cli0001.d9c23db323d7.database.windows.net].msdb.dbo.sp_update_job  @job_name = N'DBA - Maintenance - Update Stats', @enabled = 1 ;
Select name from [pccsql-use2-prod-w26-cli0001.d9c23db323d7.database.windows.net].msdb.dbo.sysjobs where name in ('DBA - Maintenance - Indexes') 
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\morcea(1994995)', 'DBA - Maintenance - Update Stats job has been enabled for org -MLMGMT. ' ,'Indexes and Statistics','MLMGMT','1994995') 

Completion time: 2022-03-04T06:51:08.2414705-05:00

*/