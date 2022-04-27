
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
EXEC [dbo].[sproc_EnableDisable_POC_EMAR] 'SRZ','1984435',0 
EXEC [dbo].[sproc_EnableDisable_DBMaintenanceJobs] 'SRZ','1984435',0,'2022-01-10 17:00:00','2022-01-11 03:00:00'

--dst org, NS Case #. go-live start and end date/time

/* 

 
   
 
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\gunald(1984435)', '' ,'POC and EMAR Backup','SRZ','1984435') 
Select msdb.dbo.agent_datetime(js.next_run_date, js.next_run_time) 
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
					VALUES (getdate(),'PCCPROD\gunald(1984435)', 'No Action Taken' ,'Index and Statistics','SRZ','1984435') 

Completion time: 2022-01-10T09:59:49.4996225-05:00




*/