
/*
-- Can execute on any server linked with TS job server
-- Will backup both logs to pcc_temp_storage DB on TS job server
-- 
*/



exec [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[sproc_facacq_automation_job_log_backup] 
@pmo_group_id	= '1778'	------ PMO Group ID

,@if_overwrite	= 'Y'		------'Y' or 'N', default to 'Y'
							------'Y' - existing table with same name will be dropped
							------'N' - a new table is always created with yyyymmddhhmmss added to file name

,@if_golive		= 'N'		------'Y' or 'N', default to 'N'
							------'Y' - 'golive' will be added to table name
							------'N' - no addtional text added


/*
--Sample output of execution with default naming convention:
select * from [vmuspassvtsjob1.pccprod.local].pcc_temp_storage.dbo._bkp_PMO59112_job_log_staging_to_destination with (nolock)
select * from [vmuspassvtsjob1.pccprod.local].pcc_temp_storage.dbo._bkp_PMO59112_job_log_source_to_staging with (nolock)n
*/



