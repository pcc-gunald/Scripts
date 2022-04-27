----Script for backup to blob storage

--Server Connect [vmuspatmpcli01]

Select * from pcc_db_version order by 3 desc

backup database us_template_pccsingle_tmpltMO
to url='https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/full_us_template_pccsingle_tmpltMO_TSFacAcq_March29.bak'
with compression,
encryption
 (
ALGORITHM = AES_256,
SERVER CERTIFICATE = backup_certificate_new
),
 STATS=20, COPY_ONLY, CHECKSUM
 --GO


-----------------Restore from blob storage
--Restore is from the URL path and with no need to define disk location,  .mdf or .ldf files while restorin to Managed Instance
USE [master]
DROP DATABASE IF EXISTS pcc_staging_db010798 
GO


USE [master]
RESTORE DATABASE pcc_staging_db010798 
FROM  URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/full_us_template_pccsingle_tmpltMO_TSFacAcq_March29.bak'

--select * from pcc_staging_db010798.dbo.pcc_db_version order by 3 desc

select top 1 *, 'SourceProductionVersion' as SourceProductionVersion from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.dbo.pcc_db_version order by 3 desc
select top 1 *, 'SourceTestVersion' as SourceTestVersion from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei984.dbo.pcc_db_version order by 3 desc
select top 1 *, 'StagingVersion' as StagingVersion from pcc_staging_db010798.dbo.pcc_db_version order by 3 desc
select top 1 *, 'DestinationProductionVersion' as DestinationProductionVersion from [pccsql-use2-prod-w20-cli0017.3055e0bc69f6.database.windows.net].test_usei23.dbo.pcc_db_version order by 3 desc
select top 1 *, 'DestinationTestVersion' as DestinationTestVersion from [pccsql-use2-prod-w20-cli0017.3055e0bc69f6.database.windows.net].test_usei23.dbo.pcc_db_version order by 3 desc

 



/*
Test




*/




/*
Go live




*/