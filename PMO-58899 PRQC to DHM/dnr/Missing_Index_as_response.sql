/*
DROP as_response__assessResponseId_PK_IX
Missing Index Details from SQLQuery125.sql - pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net.pcc_staging_db58899 (gunald@pointclickcarecloud.com (601))
The Query Processor estimates that implementing the following index could improve the query cost by 33.4476%.
*/

/*
USE [test_usei740]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [dbo].[as_response] ([assess_response_id])
INCLUDE ([item_value],[acknowledged],[created_date],[position_desc],[revision_date],[revision_by],[long_username])
GO
*/
