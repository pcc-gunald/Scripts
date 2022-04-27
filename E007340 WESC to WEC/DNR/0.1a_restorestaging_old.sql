-- connect to src
USE [master]

drop database if exists [pcc_staging_db007340] 
--waitfor delay '00:01:00'

-- new from template
RESTORE DATABASE [pcc_staging_db007340] 
FROM  URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/template/FULL_us_template_pccsingle_tmpltOH.bak'


delete  
--select * 
from [pcc_staging_db007340].[dbo].MergeLog
--order by msgTime desc

/*
(6961 rows affected)

Completion time: 2021-08-05T10:32:23.6093807-04:00
*/