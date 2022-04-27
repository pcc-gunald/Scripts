
-- connect to con src
SELECT @@SERVERNAME, @@VERSION
USE [master]
DROP DATABASE [pcc_staging_db010189];




-- new from template
RESTORE DATABASE pcc_staging_db010189
FROM  URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/template/FULL_us_template_pccsingle_tmpltOH.bak'


--truncate table  pcc_staging_db010189.[dbo].MergeLog
use pcc_staging_db010189

truncate table  pcc_staging_db010189.[dbo].MergeLog

