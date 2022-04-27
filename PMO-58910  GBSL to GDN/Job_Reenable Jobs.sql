
/*
--------------------------------------------------------------------------------------------------------------------

--		To be executed in [vmuspassvjob001.pccprod.local].dba_admin and here only

--		Please note that this is not the production org instances

*/

/*
--------------------------------------------------------------------------------------------------------------------
--		2. Job Enable, to be done on the next day during business hours after go-live
*/


exec [dbo].[sproc_EnableDisable_POC_EMAR] 'GDN','1979348',1 --dst org, NS Case #
exec [dbo].[sproc_EnableDisable_DBMaintenanceJobs] 'GDN','1979348',1,NULL,NULL --dst org, NS Case #


/*
DBA - Maintenance - Update Stats
DBA - Maintenance - Update Stats job has been enabled for org -GDN.  

  


 
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\gunald(1979348)', '' ,'POC and EMAR Backup','GDN','1979348') 
Select name from [pccsql-use2-prod-w25-cli0021.2d62ac5c7643.database.windows.net].msdb.dbo.sysjobs where name in ('DBA - Maintenance - Update Stats') 
EXEC [pccsql-use2-prod-w25-cli0021.2d62ac5c7643.database.windows.net].msdb.dbo.sp_update_job  @job_name = N'DBA - Maintenance - Update Stats', @enabled = 1 ;
Select name from [pccsql-use2-prod-w25-cli0021.2d62ac5c7643.database.windows.net].msdb.dbo.sysjobs where name in ('DBA - Maintenance - Indexes') 
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\gunald(1979348)', 'DBA - Maintenance - Update Stats job has been enabled for org -GDN. ' ,'Indexes and Statistics','GDN','1979348') 

Completion time: 2021-12-20T23:15:01.8832242-05:00

*/