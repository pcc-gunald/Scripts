
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
EXEC [dbo].[sproc_EnableDisable_POC_EMAR] 'ASHC','1998662',0 
EXEC [dbo].[sproc_EnableDisable_DBMaintenanceJobs] 'ASHC','1998662',0,'2022-03-15 23:00:00','2022-03-16 00:04:00'

--dst org, NS Case #. go-live start and end date/time

/* 

   
 
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\gunald(1998662)', '' ,'POC and EMAR Backup','ASHC','1998662') 
Select msdb.dbo.agent_datetime(js.next_run_date, js.next_run_time) 
From [pccsql-use2-prod-w22-cli0013.4c4638f8e26f.database.windows.net].msdb.dbo.sysjobs as jb
Inner Join [pccsql-use2-prod-w22-cli0013.4c4638f8e26f.database.windows.net].msdb.dbo.sysjobschedules as js on js.job_id = jb.job_id
Inner Join [pccsql-use2-prod-w22-cli0013.4c4638f8e26f.database.windows.net].msdb.dbo.sysschedules as sc on js.schedule_id = sc.schedule_id
where jb.name in ('DBA - Maintenance - Update Stats') and jb.enabled=1
Select msdb.dbo.agent_datetime(js.next_run_date, js.next_run_time) 
From [pccsql-use2-prod-w22-cli0013.4c4638f8e26f.database.windows.net].msdb.dbo.sysjobs as jb
Inner Join [pccsql-use2-prod-w22-cli0013.4c4638f8e26f.database.windows.net].msdb.dbo.sysjobschedules as js on js.job_id = jb.job_id
Inner Join [pccsql-use2-prod-w22-cli0013.4c4638f8e26f.database.windows.net].msdb.dbo.sysschedules as sc on js.schedule_id = sc.schedule_id
where jb.name in ('DBA - Maintenance - Indexes') and jb.enabled=1
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\gunald(1998662)', 'No Action Taken' ,'Index and Statistics','ASHC','1998662') 

Completion time: 2022-03-15T10:51:45.0611438-04:00



*/