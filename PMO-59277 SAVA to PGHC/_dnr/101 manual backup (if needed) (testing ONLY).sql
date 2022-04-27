ALTER DATABASE test_usei1214 SET RECOVERY SIMPLE

USE test_usei1214

DBCC SHRINKFILE (2,0,TRUNCATEONLY)

ALTER DATABASE test_usei1214 SET RECOVERY FULL

BACKUP DATABASE test_usei1214 TO DISK = 'R_DSTBCKPLOCATION\FULL_destination_test_usei1214_??date??.bak'
WITH COMPRESSION ,CHECKSUM ,stats = 10

/* Latest Test Results



*/