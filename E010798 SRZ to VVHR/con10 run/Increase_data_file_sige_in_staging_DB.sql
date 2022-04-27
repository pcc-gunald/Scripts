USE [master]
GO

ALTER DATABASE pcc_staging_db010798 --DB name
MODIFY FILE ( 
NAME = N'us_template_pccsingle_data' --DB file logical name
, SIZE = 1600GB --Size to increase to
)
GO


