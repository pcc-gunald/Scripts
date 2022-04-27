--Running on Destination Production
--Connect to [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net]

sp_updatestats

/* Go Live Results



*/

--> Enable DB Maintainance Jobs

--Connect to [vmuspassvjob001.pccprod.local].dba_admin	
EXEC [dbo].[sproc_EnableDisable_POC_EMAR] 'PGHC','1991232',1
EXEC [dbo].[sproc_EnableDisable_DBMaintenanceJobs] 'PGHC','1991232',1,NULL, NULL

/*
 
 
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\chaudas(1991232)', '' ,'POC and EMAR Backup','PGHC','1991232') 

Completion time: 2022-03-02T11:15:33.7487303-05:00



Select name from [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].msdb.dbo.sysjobs where name in ('DBA - Maintenance - Update Stats') 
EXEC [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].msdb.dbo.sp_update_job  @job_name = N'DBA - Maintenance - Update Stats', @enabled = 1 ;
Select name from [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].msdb.dbo.sysjobs where name in ('DBA - Maintenance - Indexes') 
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\chaudas(1991232)', 'DBA - Maintenance - Update Stats job has been enabled for org -PGHC. ' ,'Indexes and Statistics','PGHC','1991232') 

Completion time: 2022-03-02T11:15:56.9967287-05:00


*/