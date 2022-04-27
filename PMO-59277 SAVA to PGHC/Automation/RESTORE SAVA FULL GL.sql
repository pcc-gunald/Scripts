RESTORE DATABASE [test_usei3sava1]
FROM URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/backups/aguspaw29cli01/us_sava_multi/Full/20220227/Full_us_sava_multi_20220227_01_of_12.bak'
	,URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/backups/aguspaw29cli01/us_sava_multi/Full/20220227/Full_us_sava_multi_20220227_02_of_12.bak'
	,URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/backups/aguspaw29cli01/us_sava_multi/Full/20220227/Full_us_sava_multi_20220227_03_of_12.bak'
	,URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/backups/aguspaw29cli01/us_sava_multi/Full/20220227/Full_us_sava_multi_20220227_04_of_12.bak'
	,URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/backups/aguspaw29cli01/us_sava_multi/Full/20220227/Full_us_sava_multi_20220227_05_of_12.bak'
	,URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/backups/aguspaw29cli01/us_sava_multi/Full/20220227/Full_us_sava_multi_20220227_06_of_12.bak'
	,URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/backups/aguspaw29cli01/us_sava_multi/Full/20220227/Full_us_sava_multi_20220227_07_of_12.bak'
	,URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/backups/aguspaw29cli01/us_sava_multi/Full/20220227/Full_us_sava_multi_20220227_08_of_12.bak'
	,URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/backups/aguspaw29cli01/us_sava_multi/Full/20220227/Full_us_sava_multi_20220227_09_of_12.bak'
	,URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/backups/aguspaw29cli01/us_sava_multi/Full/20220227/Full_us_sava_multi_20220227_10_of_12.bak'
	,URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/backups/aguspaw29cli01/us_sava_multi/Full/20220227/Full_us_sava_multi_20220227_11_of_12.bak'
	,URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/backups/aguspaw29cli01/us_sava_multi/Full/20220227/Full_us_sava_multi_20220227_12_of_12.bak' WITH NORECOVERY
	,MOVE 'us_sava_multi_data' TO 'E:\Data\59277183_us_sava_multi_data.mdf'
	,MOVE 'us_sava_multi_data_2' TO 'E:\Data\59277183_us_sava_multi_data_2.ndf'
	,MOVE 'us_sava_multi_data_2_3' TO 'E:\Data\59277183_us_sava_multi_data_2_3.ndf'
	,MOVE 'reporting' TO 'E:\Data\59277183_reporting.ndf'
	,MOVE 'us_sava_multi_log' TO 'E:\Data\59277183_us_sava_multi_log.ldf'


	/*
	Processed 132950312 pages for database 'test_usei3sava1', file 'us_sava_multi_data' on file 1.
Processed 338081600 pages for database 'test_usei3sava1', file 'us_sava_multi_data_2' on file 1.
Processed 461428272 pages for database 'test_usei3sava1', file 'us_sava_multi_data_2_3' on file 1.
Processed 25393104 pages for database 'test_usei3sava1', file 'reporting' on file 1.
Processed 53971267 pages for database 'test_usei3sava1', file 'us_sava_multi_log' on file 1.
RESTORE DATABASE successfully processed 1011824555 pages in 42717.686 seconds (185.049 MB/sec).

Completion time: 2022-02-28T22:34:47.3479470-05:00


	*/