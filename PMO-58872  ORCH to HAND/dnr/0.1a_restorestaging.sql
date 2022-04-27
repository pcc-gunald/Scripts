-- connect to con src
SELECT @@SERVERNAME, @@VERSION
USE [master]
DROP DATABASE [pcc_staging_db58872];




-- new from template
RESTORE DATABASE pcc_staging_db58872 
FROM  URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/template/FULL_us_template_pccsingle_tmpltOH.bak'


--truncate table  pcc_staging_db58872.[dbo].MergeLog
use pcc_staging_db58872
delete  
--select * 
from pcc_staging_db58872.[dbo].MergeLog
--order by msgTime desc
--  50sec

/*

*/

select * from pcc_db_version
order by 3 desc