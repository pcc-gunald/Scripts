CREATE NONCLUSTERED INDEX [idx_EICase588991as_assessment]
ON [dbo].[EICase588991as_assessment] ([corporate])
INCLUDE ([src_id],[dst_id])
GO

USE [pcc_staging_db58899]
GO
CREATE NONCLUSTERED INDEX idx_EICase588991as_assessment_src_id_corporate
ON [dbo].[EICase588991as_assessment] ([src_id],[corporate])

--DROP INDEX idx_EICase588991as_assessment_src_id_corporate ON [EICase588991as_assessment]

--DROP INDEX [idx_EICase588991as_assessment] ON [EICase588991as_assessment]