--Run on [vmuspatmpcli01.pccprod.local]

BACKUP DATABASE us_template_pccsingle_tmpltTX TO 
	URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/full_us_template_pccsingle_tmpltTX_59277_Feb28.bak' 
WITH compression,
ENCRYPTION (ALGORITHM = AES_256, SERVER CERTIFICATE = backup_certificate_new), 
STATS = 5 ,COPY_ONLY, CHECKSUM

/* Latest Test Results



*/

/* Go-live Results



*/

--Run on Source server - [vmuspassvtscon3.pccprod.local]

USE [master] 

IF EXISTS(select * from sys.databases where name='pcc_staging_db59277')
DROP DATABASE pcc_staging_db59277

RESTORE DATABASE pcc_staging_db59277 FROM URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/full_us_template_pccsingle_tmpltTX_59277_Feb28.bak'


RESTORE DATABASE pcc_staging_db59277 FROM URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/full_us_template_pccsingle_tmpltTX_59277_Feb28.bak' WITH RECOVERY, 
MOVE 'us_template_pccsingle_data' TO 'E:\Data\59277_us_template_pccsingle_data.MDF', 
MOVE 'reporting' TO 'E:\Data\59277_us_template_pccsingle_reporting.ndf', 
MOVE 'us_template_pccsingle_log' TO 'E:\Data\59277_us_template_pccsingle_log.LDF'

Alter table common_code
Add dept_temp_id int NULL--both src and stg


/* Latest Test Results



*/

/* Go-live Results
Processed 98280 pages for database 'pcc_staging_db59277', file 'us_template_pccsingle_data' on file 1.
Processed 6504 pages for database 'pcc_staging_db59277', file 'reporting' on file 1.
Processed 6 pages for database 'pcc_staging_db59277', file 'us_template_pccsingle_log' on file 1.
RESTORE DATABASE successfully processed 104790 pages in 65.199 seconds (12.556 MB/sec).

Completion time: 2022-02-28T09:03:49.6292180-05:00



*/
