SET NOCOUNT ON
GO

SET DEADLOCK_PRIORITY HIGH
GO


insert into upload_tracking (script, timestamp, upload) values ('UPLOAD_START',getdate(),'4.4.8_06_CLIENT_J_Operational_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('J_Operational_Upload/1_DDL/CORE-97224- DDL - Creating backup records -ar_item_date_range- table-ar_item_type-table.sql',getdate(),'4.4.8_06_CLIENT_J_Operational_Upload_US.sql')

GO

SET ANSI_NULLS ON
GO
SET ARITHABORT ON
GO
SET ANSI_WARNINGS ON
GO
SET ANSI_PADDING ON
GO
SET CONCAT_NULL_YIELDS_NULL ON
GO
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_NULL_DFLT_ON ON
GO

SET QUOTED_IDENTIFIER ON
GO


--=======================================================================================================================
-- Jira#: CORE-97224
--  Written By: Lily Yin
--  Script Type: DDL 
--  Target DB Type: CLIENT
--  Target ENVIRONMENT: BOTH US AND CDN
-- 
--  Re-Runable: No
--            
--  Description of Script Function: 
--  Create new bak up table [operational].[ar_item_types_backup_OA18] and [operational].[ar_item_date_range_backup_OA18] to backup records updated in ar_item_types and ar_item_date_range tables; 
--  These 2 back up tables are created for OA-18
--  Backup tables will be kept until we manually remove the table
--  Records 60 days and over 60 days will be deleted from this table when OA-18 stored procedure operational.sproc_UpdateCCStandardAmounts is run every time
--  Special Instruction: None
-- =========================================================================================================================

DROP TABLE  if exists [operational].[ar_item_types_backup_OA18]



DROP TABLE  if exists [operational].[ar_item_date_range_backup_OA18]

	
	CREATE TABLE [operational].[ar_item_types_backup_OA18] (
	[item_type_id] int null
	,[fac_id] int null
	,[created_by] varchar (100) null
	,[created_date] datetime null
	,[revision_by] varchar (60) null
	,[revision_date] datetime null
	,[payer_code2] varchar (10) null
	,[backup_by] varchar (40) null
	,[backup_date] datetime
	)


	CREATE TABLE [operational].[ar_item_date_range_backup_OA18] (
	[item_type_id] int null
	,[effective_date] datetime null
	--,[effectivedate_new] datetime null
	,[ineffective_date] datetime null
	--,[ineffectivedate_new] datetime null
	,[amount] money null
	--,[amount_new] money null
	,[value_code] int null
	,[fee_schedule_amount] money null
	,[fac_id] int null
	,[markup_percentage] decimal (5,2) null
	,[backup_by] varchar (40) null
	,[backup_date] datetime
	)		




GO

print 'J_Operational_Upload/1_DDL/CORE-97224- DDL - Creating backup records -ar_item_date_range- table-ar_item_type-table.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('J_Operational_Upload/1_DDL/CORE-97224- DDL - Creating backup records -ar_item_date_range- table-ar_item_type-table.sql',getdate(),'4.4.8_06_CLIENT_J_Operational_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('J_Operational_Upload/1_DDL/CORE97429_DDL_Drop_DataCopy_Tables.sql',getdate(),'4.4.8_06_CLIENT_J_Operational_Upload_US.sql')

GO

SET ANSI_NULLS ON
GO
SET ARITHABORT ON
GO
SET ANSI_WARNINGS ON
GO
SET ANSI_PADDING ON
GO
SET CONCAT_NULL_YIELDS_NULL ON
GO
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_NULL_DFLT_ON ON
GO

SET QUOTED_IDENTIFIER ON
GO



--===============================================================================================================================================
--  Jira #:             CORE-97428
--  
--  Written By:         Jaspreet Singh
--  Updated By:			Nigel Liang

--  Script Type:        DDL 
--  Target DB Type:     CLIENT
--  Target Database:    BOTH
--  
--  Re-Runnable:        YES
--  Description:		Drop existing tables used
--
--  Special Instruction: None    
--===============================================================================================================================================
IF EXISTS (
		SELECT *
		FROM [dbo].sysobjects
		WHERE id = object_id(N'[dbo].[mergeTables]')
			AND OBJECTPROPERTY(id, N'IsUserTable') = 1
		)
	DROP TABLE [dbo].[mergeTables]

IF EXISTS (
		SELECT *
		FROM dbo.sysobjects
		WHERE id = object_id(N'[dbo].[mergeJoins]')
			AND OBJECTPROPERTY(id, N'IsUserTable') = 1
		)
	DROP TABLE [dbo].[mergeJoins]

IF EXISTS (
		SELECT *
		FROM dbo.sysobjects
		WHERE id = object_id(N'[dbo].[mergeTriggers]')
			AND OBJECTPROPERTY(id, N'IsUserTable') = 1
		)
	DROP TABLE [dbo].[mergeTriggers]

IF EXISTS (
		SELECT *
		FROM [dbo].sysobjects
		WHERE id = object_id(N'[dbo].[mergeTablesMaster]')
			AND OBJECTPROPERTY(id, N'IsUserTable') = 1
		)
	DROP TABLE [dbo].[mergeTablesMaster]

IF EXISTS (
		SELECT *
		FROM dbo.sysobjects
		WHERE id = object_id(N'[dbo].[mergeJoinsMaster]')
			AND OBJECTPROPERTY(id, N'IsUserTable') = 1
		)
	DROP TABLE [dbo].[mergeJoinsMaster]

IF EXISTS (
		SELECT *
		FROM [dbo].sysobjects
		WHERE id = object_id(N'[dbo].[MergeCurrentMod]')
			AND OBJECTPROPERTY(id, N'IsUserTable') = 1
		)
	DROP TABLE [dbo].[MergeCurrentMod]

IF EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_NAME = 'ListOfDeferTables'
		)
BEGIN
	DROP TABLE [dbo].[ListOfDeferTables]
END

IF EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_NAME = 'listoftables'
		)
BEGIN
	DROP TABLE [dbo].[listoftables]
END

IF EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_NAME = '_EITriggers'
		)
BEGIN
	DROP TABLE [dbo].[_EITriggers]
END

IF EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_NAME = '_CleanEITable'
		)
BEGIN
	DROP TABLE [dbo].[_CleanEITable]
END

IF EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_NAME = '_EIFK'
		)
BEGIN
	DROP TABLE [dbo].[_EIFK]
END



GO

print 'J_Operational_Upload/1_DDL/CORE97429_DDL_Drop_DataCopy_Tables.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('J_Operational_Upload/1_DDL/CORE97429_DDL_Drop_DataCopy_Tables.sql',getdate(),'4.4.8_06_CLIENT_J_Operational_Upload_US.sql')

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.8_06_CLIENT_J_Operational_Upload_US.sql')

GO
SET ANSI_NULLS ON
GO
SET ARITHABORT ON
GO
SET ANSI_WARNINGS ON
GO
SET ANSI_PADDING ON
GO
SET CONCAT_NULL_YIELDS_NULL ON
GO
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_NULL_DFLT_ON ON
GO

SET QUOTED_IDENTIFIER ON
GO


insert into pcc_db_version (db_version_code, db_upload_by)
values ('4.4.8_J', 'upload_history')


GO

print '..\Update db version.sql --****SCRIPT DONE****'

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.8_06_CLIENT_J_Operational_Upload_US.sql')

GO

insert into upload_tracking (script,timestamp,upload) values ('UPLOAD END',getdate(),'4.4.8_06_CLIENT_J_Operational_Upload_US.sql')