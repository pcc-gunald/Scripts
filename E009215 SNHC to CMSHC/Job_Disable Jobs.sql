
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
EXEC [dbo].[sproc_EnableDisable_POC_EMAR] 'CMSHC','1990564',0 
EXEC [dbo].[sproc_EnableDisable_DBMaintenanceJobs] 'CMSHC','1990564',0,'2022-02-17 00:23:00','2022-02-18 00:04:00'

--dst org, NS Case #. go-live start and end date/time

/* 

 
   
 
 
 
 
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\gunald(1990564)', '' ,'POC and EMAR Backup','CMSHC','1990564') 
Select msdb.dbo.agent_datetime(js.next_run_date, js.next_run_time) 
From [pccsql-use2-prod-w21-cli0002.f352397924df.database.windows.net].msdb.dbo.sysjobs as jb
Inner Join [pccsql-use2-prod-w21-cli0002.f352397924df.database.windows.net].msdb.dbo.sysjobschedules as js on js.job_id = jb.job_id
Inner Join [pccsql-use2-prod-w21-cli0002.f352397924df.database.windows.net].msdb.dbo.sysschedules as sc on js.schedule_id = sc.schedule_id
where jb.name in ('DBA - Maintenance - Update Stats') and jb.enabled=1
Select msdb.dbo.agent_datetime(js.next_run_date, js.next_run_time) 
From [pccsql-use2-prod-w21-cli0002.f352397924df.database.windows.net].msdb.dbo.sysjobs as jb
Inner Join [pccsql-use2-prod-w21-cli0002.f352397924df.database.windows.net].msdb.dbo.sysjobschedules as js on js.job_id = jb.job_id
Inner Join [pccsql-use2-prod-w21-cli0002.f352397924df.database.windows.net].msdb.dbo.sysschedules as sc on js.schedule_id = sc.schedule_id
where jb.name in ('DBA - Maintenance - Indexes') and jb.enabled=1
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\gunald(1990564)', 'No Action Taken' ,'Index and Statistics','CMSHC','1990564') 

Completion time: 2022-02-17T10:08:04.3389856-05:00




*/