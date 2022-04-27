
/*
--------------------------------------------------------------------------------------------------------------------

--		To be executed in [vmuspassvjob001.pccprod.local].dba_admin and here only

--		Please note that this is not the production org instances

*/



/*
--------------------------------------------------------------------------------------------------------------------
--		1. Job Disable, to be done on the date before the go-live
*/

--Connect to [vmuspassvjob001.pccprod.local].dba_admin	
EXEC [dbo].[sproc_EnableDisable_POC_EMAR] 'TRANQ','1999808',0 
EXEC [dbo].[sproc_EnableDisable_DBMaintenanceJobs] 'TRANQ','1999808',0,'2022-04-06 18:00:00','2022-04-07 00:00:00'

--dst org, NS Case #. go-live start and end date/time

/* 

(No column name)


(No column name)
2021-08-01 21:00:00.000

(No column name)
2021-07-31 00:00:00.000

(No column name)
No Action Taken


 
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\morcea(1999808)', '' ,'POC and EMAR Backup','TRANQ','1999808') 
Select msdb.dbo.agent_datetime(js.next_run_date, js.next_run_time) 
From [pccsql-use2-prod-w20-cli0009.3055e0bc69f6.database.windows.net].msdb.dbo.sysjobs as jb
Inner Join [pccsql-use2-prod-w20-cli0009.3055e0bc69f6.database.windows.net].msdb.dbo.sysjobschedules as js on js.job_id = jb.job_id
Inner Join [pccsql-use2-prod-w20-cli0009.3055e0bc69f6.database.windows.net].msdb.dbo.sysschedules as sc on js.schedule_id = sc.schedule_id
where jb.name in ('DBA - Maintenance - Update Stats') and jb.enabled=1
Select msdb.dbo.agent_datetime(js.next_run_date, js.next_run_time) 
From [pccsql-use2-prod-w20-cli0009.3055e0bc69f6.database.windows.net].msdb.dbo.sysjobs as jb
Inner Join [pccsql-use2-prod-w20-cli0009.3055e0bc69f6.database.windows.net].msdb.dbo.sysjobschedules as js on js.job_id = jb.job_id
Inner Join [pccsql-use2-prod-w20-cli0009.3055e0bc69f6.database.windows.net].msdb.dbo.sysschedules as sc on js.schedule_id = sc.schedule_id
where jb.name in ('DBA - Maintenance - Indexes') and jb.enabled=1
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\morcea(1999808)', 'No Action Taken' ,'Index and Statistics','TRANQ','1999808') 

Completion time: 2022-04-05T15:49:28.8839589-04:00





*/