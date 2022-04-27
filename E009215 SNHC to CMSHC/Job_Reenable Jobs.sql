
/*
--------------------------------------------------------------------------------------------------------------------

--		To be executed in [vmuspassvjob001.pccprod.local].dba_admin and here only

--		Please note that this is not the production org instances

*/

/*
--------------------------------------------------------------------------------------------------------------------
--		2. Job Enable, to be done on the next day during business hours after go-live
*/


exec [dbo].[sproc_EnableDisable_POC_EMAR] 'CMSHC','1990564',1 --dst org, NS Case #
exec [dbo].[sproc_EnableDisable_DBMaintenanceJobs] 'CMSHC','1990564',1,NULL,NULL --dst org, NS Case #


/*
DBA - Maintenance - Update Stats
DBA - Maintenance - Update Stats job has been enabled for org -CMSHC. 

 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\gunald(1990564)', '' ,'POC and EMAR Backup','CMSHC','1990564') 
Select name from [pccsql-use2-prod-w21-cli0002.f352397924df.database.windows.net].msdb.dbo.sysjobs where name in ('DBA - Maintenance - Update Stats') 
EXEC [pccsql-use2-prod-w21-cli0002.f352397924df.database.windows.net].msdb.dbo.sp_update_job  @job_name = N'DBA - Maintenance - Update Stats', @enabled = 1 ;
Select name from [pccsql-use2-prod-w21-cli0002.f352397924df.database.windows.net].msdb.dbo.sysjobs where name in ('DBA - Maintenance - Indexes') 
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\gunald(1990564)', 'DBA - Maintenance - Update Stats job has been enabled for org -CMSHC. ' ,'Indexes and Statistics','CMSHC','1990564') 

Completion time: 2022-02-18T03:08:28.3008054-05:00


*/