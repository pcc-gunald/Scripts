


/*--	Check log via script, run on the instance where the job is on:				--*/

use msdb
exec [sp_help_jobsteplog] @job_name = 'EI_Prepare_Staging__9999992' ----------job name




/*-- Disable job via script, run on the instance where the job is on:				--*/
use msdb
EXEC msdb.dbo.sp_update_job @job_name='EI_Prepare_Staging__9999992' ----------job name
							, @enabled = 0




/*--	Delete job via script, run on the instance where the job is on:				--*/
/*--	Please note the log will be removed when job is deleted, if not backed up	--*/
use msdb
EXEC msdb.dbo.sp_delete_job  @job_name='EI_Prepare_Staging__9999992' ----------job name


