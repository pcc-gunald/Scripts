
/*
--------------------------------------------------------------------------------------------------------------------

--		To be executed in [vmuspassvjob001.pccprod.local].dba_admin and here only

--		Please note that this is not the production org instances

*/



/*
--------------------------------------------------------------------------------------------------------------------
--		1. Job Disable, to be done on the date before the go-live (only execute this)
*/

exec [dbo].[sproc_EnableDisable_POC_EMAR] 'swc',' 1978679',0 --dst org, NS Case #
exec [dbo].[sproc_EnableDisable_DBMaintenanceJobs] 'swc',' 1978679',0,'2021-12-06 15:00:00','2021-12-06 23:00:00'
--dst org, NS Case #. go-live start and end date/time




/*
--------------------------------------------------------------------------------------------------------------------
--		2. Job Enable, to be done on the next day during business hours after go-live
*/


exec [dbo].[sproc_EnableDisable_POC_EMAR] 'swc',' 1978679',1 --dst org, NS Case #
exec [dbo].[sproc_EnableDisable_DBMaintenanceJobs] 'swc',' 1978679',1,NULL,NULL --dst org, NS Case #



-- 1. msg
 
 
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\srivar( 1978679)', '' ,'POC and EMAR Backup','swc','1978679') 
Select msdb.dbo.agent_datetime(js.next_run_date, js.next_run_time) 
From [pccsql-use2-prod-w28-cli0007.874bf44c721a.database.windows.net].msdb.dbo.sysjobs as jb
Inner Join [pccsql-use2-prod-w28-cli0007.874bf44c721a.database.windows.net].msdb.dbo.sysjobschedules as js on js.job_id = jb.job_id
Inner Join [pccsql-use2-prod-w28-cli0007.874bf44c721a.database.windows.net].msdb.dbo.sysschedules as sc on js.schedule_id = sc.schedule_id
where jb.name in ('DBA - Maintenance - Update Stats') and jb.enabled=1
Select msdb.dbo.agent_datetime(js.next_run_date, js.next_run_time) 
From [pccsql-use2-prod-w28-cli0007.874bf44c721a.database.windows.net].msdb.dbo.sysjobs as jb
Inner Join [pccsql-use2-prod-w28-cli0007.874bf44c721a.database.windows.net].msdb.dbo.sysjobschedules as js on js.job_id = jb.job_id
Inner Join [pccsql-use2-prod-w28-cli0007.874bf44c721a.database.windows.net].msdb.dbo.sysschedules as sc on js.schedule_id = sc.schedule_id
where jb.name in ('DBA - Maintenance - Indexes') and jb.enabled=1
 INSERT INTO [vmuspassvjob001.pccprod.local].[dba_admin].dbo.dba_task_audit (audit_date, username,audit_text,scheduler,org_code,case_number) 
					VALUES (getdate(),'PCCPROD\srivar( 1978679)', 'No Action Taken' ,'Index and Statistics','swc',' 1978679') 

Completion time: 2021-12-06T10:45:51.4950119-05:00
