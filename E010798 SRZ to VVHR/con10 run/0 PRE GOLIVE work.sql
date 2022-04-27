--After Refresh and Before Go-Live

--> Disable DB Maintainance Jobs

Select * from [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit where case_number='2003290'

--Connect to [vmuspassvjob001.pccprod.local].dba_admin	
EXEC [vmuspassvjob001.pccprod.local].dba_admin.[dbo].[sproc_EnableDisable_POC_EMAR] 'VVHR ','2003290',0 
 
 --(No column name)

 

EXEC [vmuspassvjob001.pccprod.local].dba_admin.[dbo].[sproc_EnableDisable_DBMaintenanceJobs] 'VVHR','2003290',0,'2022-04-13 06:00:00.000','2022-04-14 08:00:00.000'
/*
(No column name)
2022-04-17 21:00:00.000
(No column name
(No column name)
No Action Taken)

Select msdb.dbo.agent_datetime(js.next_run_date, js.next_run_time) 
From [pccsql-use2-prod-w20-cli0017.3055e0bc69f6.database.windows.net].msdb.dbo.sysjobs as jb
Inner Join [pccsql-use2-prod-w20-cli0017.3055e0bc69f6.database.windows.net].msdb.dbo.sysjobschedules as js on js.job_id = jb.job_id
Inner Join [pccsql-use2-prod-w20-cli0017.3055e0bc69f6.database.windows.net].msdb.dbo.sysschedules as sc on js.schedule_id = sc.schedule_id
where jb.name in ('DBA - Maintenance - Update Stats') and jb.enabled=1

(1 row affected)
Select msdb.dbo.agent_datetime(js.next_run_date, js.next_run_time) 
From [pccsql-use2-prod-w20-cli0017.3055e0bc69f6.database.windows.net].msdb.dbo.sysjobs as jb
Inner Join [pccsql-use2-prod-w20-cli0017.3055e0bc69f6.database.windows.net].msdb.dbo.sysjobschedules as js on js.job_id = jb.job_id
Inner Join [pccsql-use2-prod-w20-cli0017.3055e0bc69f6.database.windows.net].msdb.dbo.sysschedules as sc on js.schedule_id = sc.schedule_id
where jb.name in ('DBA - Maintenance - Indexes') and jb.enabled=1
SELECT @nextrun_date=msdb.dbo.agent_datetime(js.next_run_date, js.next_run_time) 
From [pccsql-use2-prod-w20-cli0017.3055e0bc69f6.database.windows.net].msdb.dbo.sysjobs as jb
Inner Join [pccsql-use2-prod-w20-cli0017.3055e0bc69f6.database.windows.net].msdb.dbo.sysjobschedules as js on js.job_id = jb.job_id
Inner Join [pccsql-use2-prod-w20-cli0017.3055e0bc69f6.database.windows.net].msdb.dbo.sysschedules as sc on js.schedule_id = sc.schedule_id
where jb.name in ('DBA - Maintenance - Update Stats') and jb.enabled=1

(0 rows affected)

(1 row affected)
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'linksvracct(2003290)', 'No Action Taken' ,'Index and Statistics','VVHR','2003290') 

Completion time: 2022-04-12T23:26:15.3813280-04:00
*/