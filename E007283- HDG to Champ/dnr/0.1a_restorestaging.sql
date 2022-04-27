-- connect to con src
SELECT @@SERVERNAME, @@VERSION
USE [master]
DROP DATABASE [pcc_staging_db007283];




-- new from template
RESTORE DATABASE [pcc_staging_db007283] 
FROM  URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/template/FULL_us_template_pccsingle_tmpltOH.bak'


--truncate table  [pcc_staging_db007283].[dbo].MergeLog
use [pcc_staging_db007283]
delete  
--select * 
from [pcc_staging_db007283].[dbo].MergeLog
--order by msgTime desc
--  50sec

/*

*/


use msdb
exec [sp_help_jobsteplog] @job_name = 'EI_Prepare_Staging__007283' ----------job name


