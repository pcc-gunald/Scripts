SET NOCOUNT ON
GO

SET DEADLOCK_PRIORITY HIGH
GO


insert into upload_tracking (script, timestamp, upload) values ('UPLOAD_START',getdate(),'4.4.10_06_CLIENT_D_PostUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('D_PostUpload/Always Synchronize Med Controlled Substance Codes.sql',getdate(),'4.4.10_06_CLIENT_D_PostUpload_US.sql')

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


-- =================================================================================
-- Jira #:               PCC-63328
--
-- Written By:			 Alireza Mandegar      
-- Reviewed By:			 
--
-- Script Type:          DML
-- Target DB Type:       CLIENT
-- Target ENVIRONMENT:   BOTH
--
--
-- Re-Runable:           YES 
--
--             
--
-- Staging Recommendations/Warnings: None
--
-- Description of Script Function:
--	Runs the stored proc to synch the orders controlled substance codes with the MMDB.
--
--
-- Special Instruction:	 This script needs to executed on all client DBs every time MMDB update happens
--                       Ideally it should be part of the default template for B&I master script
--
-- Revision History:
-- 2021-07-28        CORE-91761   Henry Jin      added raiserror to throw error when executing the store proc fails
-- =================================================================================

DECLARE	@return_value int,
		@status_code int,
		@status_text varchar(3000)

EXEC	@return_value = [dbo].[sproc_pho_synch_controlledSubstanceCode]
		@debug = N'N',
		@status_code = @status_code OUTPUT,
		@status_text = @status_text OUTPUT

IF @status_code <> 0 
	RAISERROR(@status_text, 16, @status_code);

GO

print 'D_PostUpload/Always Synchronize Med Controlled Substance Codes.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('D_PostUpload/Always Synchronize Med Controlled Substance Codes.sql',getdate(),'4.4.10_06_CLIENT_D_PostUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('D_PostUpload/CORE-100178 - Create Indexes on FKs in pho_admin_strikeout and pn_progress_note.sql',getdate(),'4.4.10_06_CLIENT_D_PostUpload_US.sql')

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


-- =================================================================================
-- JIRA: CORE-100178
-- Author: Carlos Raul Valenca
--
-- Script Type:          DDL (Dynamic SQL)
-- Target DB Type:       CLIENTDB
-- Target ENVIRONMENT:   US and CDN
--
--
-- Re-Runable:           YES
--
-- Special Instruction:
-- Comments:             Script will create missing indexes for FKs
-- =================================================================================


IF NOT EXISTS(select 1 from sys.indexes where name = 'pho_admin_strikeout__witnessById_FK_IX')
begin

    declare @cmd nvarchar(max) 
    DECLARE @is_enterprise_edition bit = dbo.dbms_is_enterprise_edition()

    set @cmd='CREATE NONCLUSTERED INDEX 
				pho_admin_strikeout__witnessById_FK_IX 
				ON [dbo].[pho_admin_strikeout]
				(
				witness_by_id
				)';

    if (@is_enterprise_edition = 1) 
    begin 
        set @cmd = @cmd + ' WITH (ONLINE=ON)' 
    end

    exec sp_executesql @cmd 
	
end
go

IF NOT EXISTS(select 1 from sys.indexes where name = 'pn_progress_note__createdByUserid_FK_IX')
begin

    declare @cmd nvarchar(max) 
    DECLARE @is_enterprise_edition bit = dbo.dbms_is_enterprise_edition()

    set @cmd='CREATE NONCLUSTERED INDEX 
				pn_progress_note__createdByUserid_FK_IX 
				ON [dbo].[pn_progress_note]
				(
				created_by_userid
				)';

    if (@is_enterprise_edition = 1) 
    begin 
        set @cmd = @cmd + ' WITH (ONLINE=ON)' 
    end

    exec sp_executesql @cmd 
	
end
go

IF NOT EXISTS(select 1 from sys.indexes where name = 'pn_progress_note__signedByUserid_FK_IX')
begin
    declare @cmd nvarchar(max) 
    DECLARE @is_enterprise_edition bit = dbo.dbms_is_enterprise_edition()

    set @cmd='CREATE NONCLUSTERED INDEX 
				pn_progress_note__signedByUserid_FK_IX 
				ON [dbo].[pn_progress_note]
				(
				signed_by_userid
				)';

    if (@is_enterprise_edition = 1) 
    begin 
        set @cmd = @cmd + ' WITH (ONLINE=ON)' 
    end

    exec sp_executesql @cmd 
	
end
go



GO

print 'D_PostUpload/CORE-100178 - Create Indexes on FKs in pho_admin_strikeout and pn_progress_note.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('D_PostUpload/CORE-100178 - Create Indexes on FKs in pho_admin_strikeout and pn_progress_note.sql',getdate(),'4.4.10_06_CLIENT_D_PostUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('D_PostUpload/CORE-89822-DDL-create-index-on-census_item.sql',getdate(),'4.4.10_06_CLIENT_D_PostUpload_US.sql')

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


-- =========================================================================================================================
-- Jira #:               CORE-89822
--
-- Written By:           Sanjay Patel (patelsan)
--  
-- Script Type:          DDL
-- Target DB Type:       CLIENT
-- Target ENVIRONMENT:   BOTH
--              
-- Re-Runable:           Yes
--
-- Description :         Create non-clustered index on census_item table on columns deleted, bed_id, effective_date, 
--                       and ineffective_date. Include column client_id. 						
--
-- =========================================================================================================================

IF NOT EXISTS (SELECT 1 FROM sysindexes
				WHERE name = 'census_item__deleted_bedId_effectiveDate_ineffectiveDate_INC_clientId')
BEGIN

	declare @cmd nvarchar(max)
    DECLARE @is_enterprise_edition bit = dbo.dbms_is_enterprise_edition()
	
	set @cmd= 'CREATE NONCLUSTERED INDEX [census_item__deleted_bedId_effectiveDate_ineffectiveDate_INC_clientId]
 	ON [dbo].[census_item] ([deleted],[bed_id],[effective_date],[ineffective_date])
 	INCLUDE ([client_id])';
	
	if (@is_enterprise_edition = 1)
    begin 
        set @cmd = @cmd + ' WITH (ONLINE=ON)' 
    end
	
	exec sp_executesql @cmd
END

GO

print 'D_PostUpload/CORE-89822-DDL-create-index-on-census_item.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('D_PostUpload/CORE-89822-DDL-create-index-on-census_item.sql',getdate(),'4.4.10_06_CLIENT_D_PostUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('D_PostUpload/CORE-95672-DDL-Create_index_on_diagnosis_codes_table.sql',getdate(),'4.4.10_06_CLIENT_D_PostUpload_US.sql')

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


-- =========================================================================================================================
-- Jira #:              CORE-95672
--
-- Written By:          Brian Young
--  
-- Script Type:         DDL
-- Target DB Type:      CLIENT
-- Target ENVIRONMENT:  BOTH
--              
-- Re-Runable:          Yes
--
-- Description :        Create non-clustered index on Diagnosis_Codes table on columns diag_lib_id and system_flag. 
--						Include column fac_id. 
--
-- =========================================================================================================================


IF EXISTS (SELECT 1 FROM sysindexes
				WHERE name = 'diagnosis_codes__diagLibId_systemFlag_IX')
BEGIN
	DROP INDEX [diagnosis_codes__diagLibId_systemFlag_IX] ON [dbo].[diagnosis_codes];
END


IF NOT EXISTS (SELECT 1 FROM sysindexes
				WHERE name = 'diagnosis_codes__diagLibId_systemFlag_INC_facId_IX')
BEGIN
	DECLARE @cmd nvarchar(max)
    DECLARE @is_enterprise_edition bit = dbo.dbms_is_enterprise_edition()
	
	SET @cmd= 'CREATE NONCLUSTERED INDEX [diagnosis_codes__diagLibId_systemFlag_INC_facId_IX] 
			ON [dbo].[diagnosis_codes] ([diag_lib_id] ASC, [system_flag] ASC)
			INCLUDE ([fac_id])';
	
	IF(@is_enterprise_edition = 1)
    BEGIN 
        SET @cmd = @cmd + ' WITH (ONLINE=ON)' 
    END
	
	EXEC sp_executesql @cmd
END

GO

print 'D_PostUpload/CORE-95672-DDL-Create_index_on_diagnosis_codes_table.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('D_PostUpload/CORE-95672-DDL-Create_index_on_diagnosis_codes_table.sql',getdate(),'4.4.10_06_CLIENT_D_PostUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('D_PostUpload/CORE-99719 - DDL - Create Index in pn_progress_note.sql',getdate(),'4.4.10_06_CLIENT_D_PostUpload_US.sql')

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


-- ==============================================================================
-- CORE-99719        Progress Note
--
-- Written By:       Angela Yue
--
-- Script Type:      DDL
-- Target DB Type:   CLIENT
-- Target Database:  BOTH
-- Re-Runable:       YES
--
-- Description :     Add index for template_id and fac_id in pn_progress_note
-- ==============================================================================

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name='pn_progress_note__templateId_INC_facId_IX' AND object_id = OBJECT_ID('dbo.pn_progress_note'))
BEGIN
    declare @cmd nvarchar(max)
    DECLARE @is_enterprise_edition bit = dbo.dbms_is_enterprise_edition()

    set @cmd = 'CREATE NONCLUSTERED INDEX [pn_progress_note__templateId_INC_facId_IX] ON [dbo].[pn_progress_note]
	(
		[template_id] ASC
	)
	INCLUDE([fac_id])';

    if (@is_enterprise_edition = 1)
    begin
        set @cmd = @cmd + ' WITH (ONLINE=ON)'
    end

    exec sp_executesql @cmd
END

GO

print 'D_PostUpload/CORE-99719 - DDL - Create Index in pn_progress_note.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('D_PostUpload/CORE-99719 - DDL - Create Index in pn_progress_note.sql',getdate(),'4.4.10_06_CLIENT_D_PostUpload_US.sql')

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.10_06_CLIENT_D_PostUpload_US.sql')

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
values ('4.4.10_D', 'upload_history')


GO

print '..\Update db version.sql --****SCRIPT DONE****'

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.10_06_CLIENT_D_PostUpload_US.sql')

GO

insert into upload_tracking (script,timestamp,upload) values ('UPLOAD END',getdate(),'4.4.10_06_CLIENT_D_PostUpload_US.sql')