SET NOCOUNT ON
GO

SET DEADLOCK_PRIORITY HIGH
GO


insert into upload_tracking (script, timestamp, upload) values ('UPLOAD_START',getdate(),'4.4.8_06_CLIENT_D_PostUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('D_PostUpload/CORE-97632 - DDL - update index on ar_transactions.sql',getdate(),'4.4.8_06_CLIENT_D_PostUpload_US.sql')

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
-- Jira #:               CORE-97632
--
-- Written By:           Daniel Chen
-- Reviewed By:          Jimmy Zhang
--
-- Script Type:          DDL
-- Target DB Type:       CLIENT
-- Target ENVIRONMENT:   BOTH
-- Re-Runable:           YES
--
-- Where tested:         dev db
--
-- Staging Recommendations/Warnings:
--
-- Description of Script Function: update ar_transactions index by add eff_schedule_id to including
--
-- Special Instruction:
-- =================================================================================
IF NOT EXISTS(SELECT 1 FROM SYS.indexes WHERE NAME='ar_transactions__clientId_distributionTxId_reversingTxId_deleted_invoiceId_payerId_effDate_txDate_txType_INC_flds_IX')
BEGIN
    DECLARE @cmd nvarchar(max) 
    DECLARE @is_enterprise_edition bit = dbo.dbms_is_enterprise_edition()

    set @cmd='CREATE NONCLUSTERED INDEX ar_transactions__clientId_distributionTxId_reversingTxId_deleted_invoiceId_payerId_effDate_txDate_txType_INC_flds_IX
        ON dbo.ar_transactions
        (
          client_id ,
          distribution_tx_id ,
          reversing_tx_id,
          deleted,
          invoice_id,
          payer_id,
          effective_date,
          transaction_date,
          transaction_type		  
        )
        INCLUDE
        (
         transaction_id,
         amount,
         days_amount, 
         auto_generated, 
         care_level, 
         parent_tx_type, 
         trial_invoice_id,
         eff_schedule_id
        ) ';

    if (@is_enterprise_edition = 1) 
    begin 
        set @cmd = @cmd + ' WITH (DATA_COMPRESSION = PAGE, ONLINE=ON)' 
    end

    exec sp_executesql @cmd 
END

IF EXISTS(SELECT 1 FROM SYS.indexes WHERE NAME='ar_transactions__clientId_distributionTxId_reversingTxId_deleted_invoiceId_payerId_effectiveDate_txDate_txType_INC_flds_IX')
BEGIN
  DROP INDEX ar_transactions__clientId_distributionTxId_reversingTxId_deleted_invoiceId_payerId_effectiveDate_txDate_txType_INC_flds_IX ON dbo.ar_transactions
END
GO


GO

print 'D_PostUpload/CORE-97632 - DDL - update index on ar_transactions.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('D_PostUpload/CORE-97632 - DDL - update index on ar_transactions.sql',getdate(),'4.4.8_06_CLIENT_D_PostUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('D_PostUpload/Synchronize Med Controlled Substance Codes.sql',getdate(),'4.4.8_06_CLIENT_D_PostUpload_US.sql')

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

print 'D_PostUpload/Synchronize Med Controlled Substance Codes.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('D_PostUpload/Synchronize Med Controlled Substance Codes.sql',getdate(),'4.4.8_06_CLIENT_D_PostUpload_US.sql')

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.8_06_CLIENT_D_PostUpload_US.sql')

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
values ('4.4.8_D', 'upload_history')


GO

print '..\Update db version.sql --****SCRIPT DONE****'

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.8_06_CLIENT_D_PostUpload_US.sql')

GO

insert into upload_tracking (script,timestamp,upload) values ('UPLOAD END',getdate(),'4.4.8_06_CLIENT_D_PostUpload_US.sql')