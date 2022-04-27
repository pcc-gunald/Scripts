-- connect to con src
SELECT @@SERVERNAME, @@VERSION
USE [master]
DROP DATABASE [pcc_staging_db58899];




-- new from template
RESTORE DATABASE [pcc_staging_db58899] 
FROM  URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/template/FULL_us_template_pccsingle_tmpltOH.bak'


--truncate table  [pcc_staging_db58899].[dbo].MergeLog
use [pcc_staging_db58899]
delete  
--select * 
from [pcc_staging_db58899].[dbo].MergeLog
--order by msgTime desc
--  50sec

/*

*/
