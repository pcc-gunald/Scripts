-- connect to con src
SELECT @@SERVERNAME, @@VERSION
USE [master]
DROP DATABASE [pcc_staging_db008679];




-- new from template
RESTORE DATABASE pcc_staging_db008679 
FROM  URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/template/FULL_us_template_pccsingle_tmpltOH.bak'


--truncate table  pcc_staging_db008679.[dbo].MergeLog
use pcc_staging_db008679
delete  
--select * 
from pcc_staging_db008679.[dbo].MergeLog
--order by msgTime desc
--  50sec

/*

*/