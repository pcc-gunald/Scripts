-- connect to src
USE [master]
drop database pcc_staging_db59013

-- new from template
RESTORE DATABASE [pcc_staging_db59013] 
FROM  URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/template/FULL_us_template_pccsingle_tmpltOH.bak'


delete  
--select * 
from [pcc_staging_db59013].[dbo].MergeLog
--order by msgTime desc

/*
(8717 rows affected)

Completion time: 2021-12-20T16:21:42.4984474-05:00
(8717 rows affected)

Completion time: 2021-12-20T19:32:32.3340083-05:00


*/

EI_Prepare_Destination__59013_d1