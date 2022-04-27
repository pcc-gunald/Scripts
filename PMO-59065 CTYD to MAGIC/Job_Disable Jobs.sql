
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
EXEC [dbo].[sproc_EnableDisable_POC_EMAR] 'MAGIC','1989436',0 
EXEC [dbo].[sproc_EnableDisable_DBMaintenanceJobs] 'MAGIC','1989436',0,'2022-02-01 00:02:00','2022-02-02 00:03:00'

--dst org, NS Case #. go-live start and end date/time

/* 

 
   
 
 
 
 
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\gunald(1989436)', '' ,'POC and EMAR Backup','MAGIC','1989436') 
Select msdb.dbo.agent_datetime(js.next_run_date, js.next_run_time) 
From [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].msdb.dbo.sysjobs as jb
Inner Join [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].msdb.dbo.sysjobschedules as js on js.job_id = jb.job_id
Inner Join [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].msdb.dbo.sysschedules as sc on js.schedule_id = sc.schedule_id
where jb.name in ('DBA - Maintenance - Update Stats') and jb.enabled=1
SELECT @nextrun_date=msdb.dbo.agent_datetime(js.next_run_date, js.next_run_time) 
From [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].msdb.dbo.sysjobs as jb
Inner Join [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].msdb.dbo.sysjobschedules as js on js.job_id = jb.job_id
Inner Join [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].msdb.dbo.sysschedules as sc on js.schedule_id = sc.schedule_id
where jb.name in ('DBA - Maintenance - Update Stats') and jb.enabled=1
Select msdb.dbo.agent_datetime(js.next_run_date, js.next_run_time) 
From [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].msdb.dbo.sysjobs as jb
Inner Join [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].msdb.dbo.sysjobschedules as js on js.job_id = jb.job_id
Inner Join [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].msdb.dbo.sysschedules as sc on js.schedule_id = sc.schedule_id
where jb.name in ('DBA - Maintenance - Indexes') and jb.enabled=1
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\gunald(1989436)', 'No Action Taken' ,'Index and Statistics','MAGIC','1989436') 

Completion time: 2022-01-31T10:17:43.3593893-05:00




*/