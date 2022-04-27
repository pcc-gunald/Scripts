
--> Enable DB Maintainance Jobs

--Connect to [vmuspassvjob001.pccprod.local].dba_admin	


EXEC [vmuspassvjob001.pccprod.local].dba_admin.[dbo].[sproc_EnableDisable_POC_EMAR] 'usei23','1979408',1 

 (No column name)

 
(1 row affected)
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'linksvracct(1979408)', '' ,'POC and EMAR Backup','usei23','1979408') 

Completion time: 2021-11-40T14:19:01.1739708-05:00


EXEC [vmuspassvjob001.pccprod.local].dba_admin.[dbo].[sproc_EnableDisable_DBMaintenanceJobs] 'usei23','1979408',1,NULL, NULL

/*
name
DBA - Maintenance - Update Stats

name

(No column name)
DBA - Maintenance - Update Stats job has been enabled for org -usei23. 

Select name from [pccsql-use2-prod-w30-cli0002.cbafa2b4e84.database.windows.net].msdb.dbo.sysjobs where name in ('DBA - Maintenance - Update Stats') 

(1 row affected)
Select name from [pccsql-use2-prod-w30-cli0002.cbafa2b4e84.database.windows.net].msdb.dbo.sysjobs where name in ('DBA - Maintenance - Indexes') 
EXEC [pccsql-use2-prod-w30-cli0002.cbafa2b4e84.database.windows.net].msdb.dbo.sp_update_job  @job_name = N'DBA - Maintenance - Update Stats', @enabled = 1 ;

(0 rows affected)

(1 row affected)
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'linksvracct(1979408)', 'DBA - Maintenance - Update Stats job has been enabled for org -usei23. ' ,'Indexes and Statistics','usei23','1979408') 

Completion time: 2021-11-40T14:19:40.1739409-05:00

*/