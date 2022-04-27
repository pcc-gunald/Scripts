--on server vmuspatmpcli01.pccprod.local
backup database us_template_pccsingle_SLtmpltNE to 
url='https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/full_us_template_pccsingle_SLtmpltNE_JAN_31.bak'
		with compression,
		encryption
 		(
		ALGORITHM = AES_256,
		SERVER CERTIFICATE = backup_certificate_new
		),
 		STATS=20, COPY_ONLY, CHECKSUM

/*
--1 min
Warning: The certificate used for encrypting the database encryption key has not been backed up. You should immediately back up the certificate and the private key associated with the certificate. If the certificate ever becomes unavailable or if you must restore or attach the database on another server, you must have backups of both the certificate and the private key or you will not be able to open the database.
20 percent processed.
40 percent processed.
60 percent processed.
80 percent processed.
Processed 99080 pages for database 'us_template_pccsingle_SLtmpltNE', file 'us_template_pccsingle_data' on file 1.
Processed 6512 pages for database 'us_template_pccsingle_SLtmpltNE', file 'reporting' on file 1.
100 percent processed.
Processed 6 pages for database 'us_template_pccsingle_SLtmpltNE', file 'us_template_pccsingle_log' on file 1.
BACKUP DATABASE successfully processed 105598 pages in 5.534 seconds (149.075 MB/sec).

Completion time: 2022-01-31T11:43:57.8988600-05:00
*/



--on source test server
IF EXISTS(select * from sys.databases where name='pcc_staging_db_58508')
		  DROP DATABASE pcc_staging_db_58508
 
		  USE [master]
		  RESTORE DATABASE pcc_staging_db_58508 FROM  
		  url='https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/full_us_template_pccsingle_SLtmpltNE_JAN_31.bak'


/*
--1 min
Commands completed successfully.

Completion time: 2022-01-31T11:48:23.2968111-05:00

*/
