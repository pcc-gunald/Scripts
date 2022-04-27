SET NOCOUNT ON
GO

SET DEADLOCK_PRIORITY HIGH
GO


insert into upload_tracking (script, timestamp, upload) values ('UPLOAD_START',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-95191 - DDL - Create mapping table between sound physician org and facility.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

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


--=============================================================================
--  Issue:			  CORE-95191
--  Written By:		  Angela Yue
--  Script Type:      DDL
--  Target DB Type:   Client
--  Target Database:  BOTH
--  Re-Runnable:       Yes
--  Description :     Creates facility_telehealth_org and facility_telehealth_org_mapping tables
--
--=============================================================================

IF EXISTS (SELECT 1 FROM [information_schema].[tables]
           WHERE table_name = 'facility_telehealth_org_mapping'
             AND table_schema = 'dbo')
    BEGIN
        DROP TABLE [dbo].facility_telehealth_org_mapping;
    END

IF EXISTS (SELECT 1 FROM [information_schema].[tables]
           WHERE table_name = 'facility_telehealth_org'
             AND table_schema = 'dbo')
    BEGIN
        DROP TABLE [dbo].facility_telehealth_org;
    END

CREATE TABLE facility_telehealth_org (		--:PHI:N:Desc:telehealth org details
     telehealth_org_id int NOT NULL,	 --:PHI:N:Desc:telehealth org_id
     telehealth_org_name varchar(400) NOT NULL,	--:PHI:N:Desc:telehealth org name
     created_by_user_id int NOT NULL,	--:PHI:N:Desc:Who created the record
     created_date datetime NOT NULL,		--:PHI:N:Desc:When the record is created
     revision_by_user_id int NULL,  --:PHI:N:Desc:Who updated the record
     revision_date datetime NULL,   --:PHI:N:Desc:When the record is updated
     status_code int NOT NULL,  --:PHI:N:Desc:telehealth org status

     CONSTRAINT [facility_telehealth_org__telehealthOrgId_PK_CL_IX] PRIMARY KEY ([telehealth_org_id])
)

CREATE TABLE facility_telehealth_org_mapping (		--:PHI:N:Desc:mapping between facility and telehealth org
     fac_id int NOT NULL,	--:PHI:N:Desc:pcc fac_id
     telehealth_org_id int NOT NULL,	 --:PHI:N:Desc:telehealth org_id
     CONSTRAINT [facility_telehealth_org_mapping__facId_telehealthOrgId_PK_CL_IX] PRIMARY KEY ([fac_id], [telehealth_org_id])
)

alter table facility_telehealth_org_mapping
    add CONSTRAINT facility_telehealth_org_mapping__facId_FK FOREIGN KEY (fac_id)
        REFERENCES dbo.facility(fac_id)
        ON DELETE CASCADE

alter table facility_telehealth_org_mapping
    add CONSTRAINT facility_telehealth_org_mapping__telehealthOrgId_FK FOREIGN KEY (telehealth_org_id)
        REFERENCES dbo.facility_telehealth_org(telehealth_org_id)
        ON DELETE CASCADE

GO

print 'A_PreUpload/CORE-95191 - DDL - Create mapping table between sound physician org and facility.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-95191 - DDL - Create mapping table between sound physician org and facility.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-95192 - DDL - Create mapping table between sound physician user and pcc user.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

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


--=============================================================================
--  Issue:			  CORE-95192
--  Written By:		  Nisarg Chokshi
--  Script Type:      DDL
--  Target DB Type:   Client
--  Target Database:  BOTH
--  Re-Runnable:       Yes
--  Description :     Creates user_telehealth_staff and user_telehealth_staff_mapping tables
--
--=============================================================================

IF EXISTS (SELECT 1 FROM [information_schema].[tables]
           WHERE table_name = 'user_telehealth_staff_mapping'
             AND table_schema = 'dbo')
BEGIN
    DROP TABLE [dbo].user_telehealth_staff_mapping;
END

IF EXISTS (SELECT 1 FROM [information_schema].[tables]
           WHERE table_name = 'user_telehealth_staff'
             AND table_schema = 'dbo')
BEGIN
    DROP TABLE [dbo].user_telehealth_staff;
END

CREATE TABLE user_telehealth_staff (		--:PHI:N:Desc:telehealth user details
   telehealth_user_id int NOT NULL,	 --:PHI:N:Desc:telehealth userid
   email varchar(400) NOT NULL,	--:PHI:N:Desc:user email
   created_by varchar(400) NOT NULL,	--:PHI:N:Desc:Who created the record
   created_date datetime NOT NULL,		--:PHI:N:Desc:When the record is created
   revision_by varchar(400) NULL,  --:PHI:N:Desc:Who updated the record
   revision_date datetime NULL,   --:PHI:N:Desc:When the record is updated
   is_active bit NOT NULL,  --:PHI:N:Desc:telehealth user status

   CONSTRAINT [user_telehealth_staff__telehealthUserId_PK_CL_IX] PRIMARY KEY ([telehealth_user_id])
)

CREATE TABLE user_telehealth_staff_mapping (		--:PHI:N:Desc:mapping between pcc user and telehealth user
   userid int NOT NULL,	--:PHI:N:Desc:pcc userid
   telehealth_user_id int NOT NULL,	 --:PHI:N:Desc:telehealth userid
   CONSTRAINT [user_telehealth_staff_mapping__userId_telehealthUserId_PK_CL_IX] PRIMARY KEY ([userid], [telehealth_user_id])
)

ALTER TABLE user_telehealth_staff_mapping
    ADD CONSTRAINT user_telehealth_staff_mapping__userId_FK FOREIGN KEY (userid)
        REFERENCES dbo.sec_user(userid)
        ON DELETE CASCADE

ALTER TABLE user_telehealth_staff_mapping
    ADD CONSTRAINT user_telehealth_staff_mapping__telehealthUserId_FK FOREIGN KEY (telehealth_user_id)
        REFERENCES dbo.user_telehealth_staff(telehealth_user_id)
        ON DELETE CASCADE

GO

print 'A_PreUpload/CORE-95192 - DDL - Create mapping table between sound physician user and pcc user.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-95192 - DDL - Create mapping table between sound physician user and pcc user.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97372-DDL - Add Columns for CDN med management.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

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


--=============================================================================
--  Issue:			  CORE-97372
--  Written By:		  Ramin Shojaei
--  Script Type:      DDL
--  Target DB Type:   Client
--  Target Database:  BOTH
--  Re-Runable:       Yes
--  Description :     Add Tables/Columns that are specific to CDN Med Management EPrescribing workflow
--
--=============================================================================
IF NOT EXISTS (select 1 from information_schema.COLUMNS
	WHERE TABLE_SCHEMA = 'dbo'
	AND TABLE_NAME = 'pho_phys_order_esignature_contact_snapshot'
	AND COLUMN_NAME = 'registration_code')
BEGIN
	ALTER TABLE [dbo].[pho_phys_order_esignature_contact_snapshot]
	ADD [registration_code] VARCHAR(30) null -- :PHI=N: Prescriber Registration Code. Applies to CDN only
END

IF NOT EXISTS (select 1 from information_schema.TABLES
	WHERE TABLE_SCHEMA = 'dbo'
	AND TABLE_NAME = 'pho_phys_order_esignature_order_snapshot_CDN')
BEGIN
	CREATE TABLE [dbo].pho_phys_order_esignature_order_snapshot_CDN (
		phys_order_id INT --:PHI=N: Physician order id
		, quantity_attestation VARCHAR(2800) NOT NULL-- :PHI=N: Facility Quantity Attestation at the time of signing order

		CONSTRAINT pho_phys_order_esignature_order_snapshot_CDN__physOrderId_PK_CL_IX PRIMARY KEY (phys_order_id)
		CONSTRAINT pho_phys_order_esignature_order_snapshot_CDN__physOrderId_FK FOREIGN KEY (phys_order_id) REFERENCES dbo.pho_phys_order(phys_order_id)
	)
END

GO

print 'A_PreUpload/CORE-97372-DDL - Add Columns for CDN med management.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97372-DDL - Add Columns for CDN med management.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97602-DDL-create-table-facility_medical_attestation.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

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
-- Jira #:				CORE-97602
--
-- Written By:			Jarek Zawojski
-- Reviewed By:
--
-- Script Type:			DDL
-- Target DB Type:		CLIENT
-- Target ENVIRONMENT:	ALL
--
--
-- Re-Runnable:			YES
--
-- Description of Script:	Create table facility_medical_attestation
--                          Restrict values on active column to 1 and null
--                          There can be just one active record per facility
--                          Add a trigger to prevent deleting records
--                          Add a trigger to prevent updates other than active from 1 to null
--
-- Special Instruction: None
--
-- =================================================================================
IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'facility_medical_attestation'
		)
BEGIN

    CREATE TABLE [dbo].[facility_medical_attestation](
        [facility_medical_attestation_id] [int] NOT NULL IDENTITY (1,1),                   --:PHI=N:Desc: record ID
        [fac_id] [int] NOT NULL,                              --:PHI=N:Desc: facility ID
        [non_ctrl_medication_value] [varchar](2800) NOT NULL, --:PHI=N:Desc: non controlled medication attestation text
        [ctrl_medication_value] [varchar](2800) NOT NULL,     --:PHI=N:Desc: controlled medication attestation text
        [created_by] [varchar](60) NOT NULL,                  --:PHI=N:Desc: audit field username
        [created_date] [datetime] NOT NULL,                   --:PHI=N:Desc: audit field timestamp
        [active] [bit] NOT NULL,                              --:PHI=N:Desc: marks record as active
        CONSTRAINT [facility_medical_attestation__Id_PK_CL_IX] PRIMARY KEY ([facility_medical_attestation_id]),
        CONSTRAINT [facility_medical_attestation__facId_FK]
            FOREIGN KEY([fac_id]) REFERENCES [dbo].[facility]([fac_id]));

    CREATE UNIQUE INDEX [facility_medical_attestation__facId_active_CLU]
    ON [dbo].[facility_medical_attestation] ([fac_id], [active]) where [active] = 1
END;
GO

CREATE OR ALTER TRIGGER [dbo].[tp_facility_medical_attestation_del]
     ON [dbo].[facility_medical_attestation]
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR('Deleting from facility_medical_attestation table not allowed.', 16, 10);
    ROLLBACK;
END;

GO

CREATE OR ALTER TRIGGER [dbo].[tp_facility_medical_attestation_upd]
    ON [dbo].[facility_medical_attestation]
    AFTER UPDATE
    AS
BEGIN
    IF NOT EXISTS(
        SELECT null
        FROM Deleted as del
        WHERE del.active = 1
              AND EXISTS (
                  SELECT del.fac_id,
                         del.ctrl_medication_value,
                         del.non_ctrl_medication_value,
                         del.created_by,
                         del.created_date
                  INTERSECT
                  SELECT ins.fac_id,
                         ins.ctrl_medication_value,
                         ins.non_ctrl_medication_value,
                         ins.created_by,
                         ins.created_date
                  FROM Inserted as ins
                  WHERE ins.facility_medical_attestation_id = del.facility_medical_attestation_id
            )

        )
    BEGIN
        RAISERROR('Updating only allowed on [active] from 1 to 0.', 16, 10);
        ROLLBACK;
    END
END;


GO

print 'A_PreUpload/CORE-97602-DDL-create-table-facility_medical_attestation.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97602-DDL-create-table-facility_medical_attestation.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97774 - DDL - create-table-pho_phys_order_attestation.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

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
-- Jira #:				CORE-97774
--
-- Written By:			Hoa Nguyen
-- Reviewed By:
--
-- Script Type:			DDL
-- Target DB Type:		CLIENT
-- Target ENVIRONMENT:	ALL
--
--
-- Re-Runnable:			YES
--
-- Description of Script:	Create table pho_phys_order_attestation
--
-- Special Instruction: None
--
-- =================================================================================


IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'pho_phys_order_attestation' AND table_schema = 'dbo'
)
BEGIN
    DROP TABLE [dbo].[pho_phys_order_attestation]
END
GO

BEGIN
CREATE TABLE [dbo].[pho_phys_order_attestation] (
    [phys_order_id] [int] NOT NULL,							--:PHI=N:Desc: the order id
    [facility_medical_attestation_id] [int] NOT NULL,		--:PHI=N:Desc: facility's attestation configuration id
    [is_controlled_medication] [bit] NOT NULL,              --:PHI=N:Desc: the attestation is used for a controlled medication
    [created_date] [datetime] NOT NULL,						--:PHI=N:Desc: audit field timestamp
    CONSTRAINT [pho_phys_order_attestation__physOrderId_PK] PRIMARY KEY ([phys_order_id]),
	CONSTRAINT [pho_phys_order_attestation__physOrderId_FK] FOREIGN KEY([phys_order_id]) REFERENCES [dbo].[pho_phys_order]([phys_order_id]),
	CONSTRAINT [pho_phys_order_attestation__facilityMedicalAttestationId_FK] FOREIGN KEY([facility_medical_attestation_id]) REFERENCES [dbo].[facility_medical_attestation]([facility_medical_attestation_id])
);

CREATE NONCLUSTERED INDEX [facility_medical_attestation__facilityMedicalAttestationId_IX] ON [dbo].[pho_phys_order_attestation] ([facility_medical_attestation_id])

END
GO

CREATE OR ALTER TRIGGER [dbo].[tp_pho_phys_order_attestation_upd]
    ON [dbo].[pho_phys_order_attestation]
INSTEAD OF UPDATE AS
BEGIN
    RAISERROR('Updating pho_phys_order_attestation table not allowed.', 18, 0);
    ROLLBACK;
END

GO

print 'A_PreUpload/CORE-97774 - DDL - create-table-pho_phys_order_attestation.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97774 - DDL - create-table-pho_phys_order_attestation.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97894 - DML - update search carequality security function name.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

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
-- Reviewed By:          
-- Author:               Willie Wong
--
-- Script Type:          DML
-- Target DB Type:       CLIENTDB
-- Target ENVIRONMENT:   US and CDN
--
--
-- Re-Runable:           YES
--
--
-- Special Instruction:  
-- Comments: 			 CORE-97894 update search carequality security function name
--
-- =================================================================================

update sec_function set description = 'PointClickCare Connect', revision_by='CORE-97894', revision_date = GETDATE()
  where func_id in ('1018.0','5012.0') and description = 'Search Carequality';

GO

print 'A_PreUpload/CORE-97894 - DML - update search carequality security function name.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97894 - DML - update search carequality security function name.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97899 - DML - update care quality search security function name.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

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
-- Reviewed By:          
-- Author:               Willie Wong
--
-- Script Type:          DML
-- Target DB Type:       CLIENTDB
-- Target ENVIRONMENT:   US and CDN
--
--
-- Re-Runable:           YES
--
--
-- Special Instruction:  
-- Comments: 			 CORE-97899 update crm carequality search security function name
--
-- =================================================================================

 update sec_function set description = 'PointClickCare Connect', revision_by='CORE-97899',revision_date = GETDATE()
  where func_id in ('14010.0') and description = 'Care Quality Search';

GO

print 'A_PreUpload/CORE-97899 - DML - update care quality search security function name.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97899 - DML - update care quality search security function name.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97948 - DDL - Create AR Lib Statement Export Template Calendar table.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

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


--=============================================================================
--  Issue:			  CORE-97948
--  Written By:		  Min Li
--  Script Type:      DDL
--  Target DB Type:   Client
--  Target Database:  BOTH
--  Re-Runable:       Yes
--  Description :     Creates ar_lib_statement_export_template_calendar table
--                    
--=============================================================================



IF EXISTS (SELECT 1 FROM [information_schema].[tables]
                     WHERE table_name = 'ar_lib_statement_export_template_calendar'
                     AND table_schema = 'dbo')
BEGIN
	DROP TABLE [dbo].ar_lib_statement_export_template_calendar;
END

CREATE TABLE ar_lib_statement_export_template_calendar (			--:PHI:N:Desc:the calendar for statement export template
	calendar_id bigint identity(1,1) NOT NULL,	--:PHI:N:Desc:Primary key for a statement export template calendar
	template_id int NOT NULL,							--:PHI:N:Desc:Which template this calendar belongs to
	schedule_date date NOT NULL,						--:PHI:N:Desc:the date for calendar
	created_by varchar(60) NOT NULL,				    --:PHI:N:Desc:Who created the record
	created_date datetime NOT NULL						--:PHI:N:Desc:When the record is created
)
--------- Foreign key
alter table ar_lib_statement_export_template_calendar add CONSTRAINT ar_lib_statement_export_template_calendar_templateId_FK FOREIGN KEY (template_id) 
	REFERENCES dbo.ar_lib_statement_export_template(template_id)
	ON DELETE CASCADE

CREATE INDEX ar_lib_statement_export_template_calendar_templateId_FK_IX ON ar_lib_statement_export_template_calendar (template_id)

CREATE INDEX ar_lib_statement_export_template_calendar_templateId_scheduleDate_IX ON ar_lib_statement_export_template_calendar (template_id, schedule_date)




GO

print 'A_PreUpload/CORE-97948 - DDL - Create AR Lib Statement Export Template Calendar table.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97948 - DDL - Create AR Lib Statement Export Template Calendar table.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97956- DDL - Added a column for to display in report output metadata change.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

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





-- CORE-97956	
-- Written By:          Dominic Christie
-- Reviewed By:
--
-- Script Type:          
-- Target DB Type:       CLIENT
-- Target ENVIRONMENT:   BOTH
--
--
-- Re-Runnable:          YES
--
-- Where tested:          pccsql-use2-nprd-trm-cli0009.bbd2b72cba43.database.windows.net ( MUS_gss_full_bip26207 database )
--
--As part of the pho_Schedule_details acrhiving process adding table for the schedule to handle different schedules
--
-- =================================================================================


IF NOT EXISTS (select 1 from prp_report_column
where ref_report_column_id =-10103 
AND report_id =-1007)
BEGIN
INSERT INTO prp_report_column
VALUES (-51003,-1007,-10103,1,11,0,NULL,'template',GETDATE(),'template',GETDATE(),'N',NULL,NULL)

END

GO

print 'A_PreUpload/CORE-97956- DDL - Added a column for to display in report output metadata change.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97956- DDL - Added a column for to display in report output metadata change.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97989 - DDL - ar_cash_data_integrity_error_detail - new applied_payment_total column.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

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


-- CORE-97989	
-- Written By:           Naomi Martel
-- Reviewed By:
--
-- Script Type:          
-- Target DB Type:       CLIENT
-- Target ENVIRONMENT:   BOTH
--
--
-- Re-Runnable:          YES
--
-- Where tested:              
-- Description:          Add column to ar_cash_data_integrity_error_detail to store
--                       applied payment total amount not matching to cash transaction amount
--
-- =================================================================================

IF EXISTS (SELECT 1 FROM information_schema.tables
           WHERE table_name = 'ar_cash_data_integrity_error_detail'
           AND table_schema = 'dbo')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME='applied_payment_total' AND TABLE_NAME='ar_cash_data_integrity_error_detail' )
    BEGIN
        ALTER TABLE ar_cash_data_integrity_error_detail
        ADD applied_payment_total MONEY NULL --:PHI=N:Desc:Applied Payment total amount not matching to cash transaction amount
    END
END

GO

print 'A_PreUpload/CORE-97989 - DDL - ar_cash_data_integrity_error_detail - new applied_payment_total column.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97989 - DDL - ar_cash_data_integrity_error_detail - new applied_payment_total column.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97989 - DML - data integrity - transactions not matching applied payment.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

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
-- Reviewed By:          
-- Author:               Naomi Martel
--
-- Script Type:          DML
-- Target DB Type:       CLIENTDB
-- Target ENVIRONMENT:   US and CDN
--
--
-- Re-Runable:           YES
--
--
-- Special Instruction:  
-- Comments: 			 CORE-97989 Add new validation type for cash transactions not matching applied payment history
--
-- =================================================================================
IF NOT EXISTS (SELECT 1 FROM ar_cash_data_integrity_validation_type WHERE validation_type_id=2)
BEGIN
insert into ar_cash_data_integrity_validation_type (validation_type_id, name)
values (2, 'cash_transaction_match_applied_payment_history_check');
END

GO

GO

print 'A_PreUpload/CORE-97989 - DML - data integrity - transactions not matching applied payment.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97989 - DML - data integrity - transactions not matching applied payment.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-98229 - DML - Remove questions from LTCF Discharge.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

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


--=============================================================================
--  Issue:            CORE-98229 Remove questions from LTCF Discharge
--  Written By:       Afzal Bhojani
--  Script Type:      DML
--                      
--  Target DB Type:   ClientDB
--  Target Database:  All 
--
--  Tested:			  DEV_CA_Scorpion_Squad_kcity on pccsql-use2-nprd-dvsh-cli0003.bbd2b72cba43.database.windows.net
--  Re-Runable:       Yes
--                      
--  Description:      Reverts changes made by CORE-94032, CORE-93901, and CORE-94068.
--					  The status_Y column is for routine discharge, covers last 3 days
--					  The status_Q column is for routine discharge tracking only
--=============================================================================


UPDATE 
	as_std_question
SET
	status_Y = 'X',
	status_Q = 'X'
WHERE
	std_assess_id = 23
	and 
		(
			question_key like 'A7%'		
			or 
			question_key = 'A12'
			or 
			question_key in ('AD2', 'AD3', 'B2', 'B5', 'B5a', 'B5b')
		)
	and (status_Y <> 'X' or status_Q <> 'X');


GO

print 'A_PreUpload/CORE-98229 - DML - Remove questions from LTCF Discharge.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-98229 - DML - Remove questions from LTCF Discharge.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-98793 - DDL - Add default constraint for hospital_stay_waiver column in pa_enconter_event_detail table.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

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
-- Jira #:				CORE-98793
--
-- Written By:			Sherry Lyu
-- Reviewed By:
--
-- Script Type:			DDL
-- Target DB Type:		CLIENT
-- Target ENVIRONMENT:	ALL
--
--
-- Re-Runnable:			YES
--
-- Description of Script:	Add default constraint for hospital_stay_waiver column in pa_enconter_event_detail table
--
-- Special Instruction: None
--
-- =================================================================================
IF EXISTS(SELECT OBJECT_NAME(OBJECT_ID) AS NameofConstraint,SCHEMA_NAME(schema_id) AS SchemaName,OBJECT_NAME(parent_object_id) AS TableName
				,type_desc AS ConstraintType
    FROM sys.objects
    WHERE type_desc LIKE '%CONSTRAINT'
        AND OBJECT_NAME(OBJECT_ID)='pa_encounter_event_detail__hospital_stay_waiver_DFLT')
BEGIN;
	ALTER TABLE [dbo].[pa_encounter_event_detail] DROP CONSTRAINT [pa_encounter_event_detail__hospital_stay_waiver_DFLT];
END;

IF EXISTS(SELECT OBJECT_NAME(OBJECT_ID) AS NameofConstraint,SCHEMA_NAME(schema_id) AS SchemaName,OBJECT_NAME(parent_object_id) AS TableName
				,type_desc AS ConstraintType
    FROM sys.objects
    WHERE type_desc LIKE '%CONSTRAINT'
        AND OBJECT_NAME(OBJECT_ID)='pa_encounter_event_detail__hospitalStayWaiver_DFLT')
BEGIN;
	ALTER TABLE [dbo].[pa_encounter_event_detail] DROP CONSTRAINT [pa_encounter_event_detail__hospitalStayWaiver_DFLT];
END;

IF NOT EXISTS(SELECT OBJECT_NAME(OBJECT_ID) AS NameofConstraint,SCHEMA_NAME(schema_id) AS SchemaName,OBJECT_NAME(parent_object_id) AS TableName
				,type_desc AS ConstraintType
    FROM sys.objects
    WHERE type_desc LIKE '%CONSTRAINT'
        AND OBJECT_NAME(OBJECT_ID)='pa_encounter_event_detail__hospitalStayWaiver_DFLT')
BEGIN;
	ALTER TABLE [dbo].[pa_encounter_event_detail]  
    ADD CONSTRAINT [pa_encounter_event_detail__hospitalStayWaiver_DFLT]  
    DEFAULT 0 FOR [hospital_stay_waiver];  
END;

GO

print 'A_PreUpload/CORE-98793 - DDL - Add default constraint for hospital_stay_waiver column in pa_enconter_event_detail table.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-98793 - DDL - Add default constraint for hospital_stay_waiver column in pa_enconter_event_detail table.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-99022-fix_question_key_lengths.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

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
-- Reviewed By:          
-- Author:               Jeff Shepherd
--
-- Script Type:          DML
-- Target DB Type:       CLIENTDB
-- Target ENVIRONMENT:   US and CDN
--
--
-- Re-Runnable:           YES
--
--
-- Special Instruction:  
-- Comments: 			 CORE-99022 update question key lengths for certain text fields
--
-- =================================================================================

UPDATE as_std_question SET length =500 WHERE question_key IN ( 
'b904583f-24cd-4a6e-9f36-6316b4cc2f7f',
'4c13f765-c3f9-4436-b158-8216cefbe040',
'6e28c4fd-54b9-4572-9c95-b933c4760623', 
'198e8ac3-1902-4535-9de9-22537773ccd9',
'5e5e8de7-f687-46d8-9cec-166614bc30c6', 
'7d6a7676-c76d-4bcb-8cfe-7e0f91002bb6',
'011e3379-e905-4f04-b39e-c3cdf472270d',
'50fed56a-352d-4fe7-b522-ef950149b8db', 
'cf043474-e2cf-4425-a5c0-1586bfded20b',
'b455daf3-a205-4f4d-9a4f-423cfa080a3e', 
'b3e94e81-0979-4048-97d3-1aca895cba4c',
'dadd5482-36da-4d01-b6f0-4c380ebc15c5', 
'95a3e032-3190-48dd-84b0-75909fb83d98', 
'e6fba394-ea2a-4800-a941-1b0efb92e746',
'cf23389b-041d-41cd-82fd-6a5357acbdaa', 
'4d36c098-bff6-478b-bd46-d83659b73e54',
'8c359a47-2652-48f7-a39b-1be1c365b13d'
)


GO

print 'A_PreUpload/CORE-99022-fix_question_key_lengths.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-99022-fix_question_key_lengths.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/US_Only/CORE-92067 - DML - Update ICD for MDS3.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

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
-- Jira #: 
--    CORE-92067 - DML - Update ICD for MDS3
--
--    Story:    CORE-92067 MDS 3.0: ICD-10 2022 Mapping to Section I
--    Dev Task: CORE-98023 Dev add icd links
--
-- Written By:          Colin Collins
-- Reviewed By:         Scorpion Squad developers
-- 
-- Script Type:         DML
-- Target DB Type:      Client
-- Target ENVIRONMENT:  US
-- Re-Runable:          YES 
-- 
-- Where tested:        pccsql-use2-nprd-dvsh-cli0003.bbd2b72cba43.database.windows.net, DEV_US_Scorpion_Squad_abhow
-- 
-- Staging Recommendations/Warnings:
-- 
-- Description of Script Function: 
--   Updates [diagnosis_codes].[mds3_question_key] which is used to autofill Section I
--   on MDS 3.0 assessments.  
--   Dev execution time: one second.
--   This is similar to CORE-74243.
--                                                                      
-- Special Instruction:         
--    none 
-- ================================================================================= 
-- USE [DEV_US_Scorpion_Squad_abhow]  -- when testing in dev


DECLARE
   @revisionBy       varchar(60) = 'CORE-92067'
  ,@revisionDate     datetime    = getdate()
  ,@diag_lib_id_US   int         = 4004           
  ,@SystemFlagY      char(1)     = 'Y'
  ,@USID_100         int         = 100
  
  ,@I0100    [varchar](16)  = 'I0100'   
  ,@I0200    [varchar](16)  = 'I0200'   
  ,@I0400    [varchar](16)  = 'I0400'   
  ,@I0500    [varchar](16)  = 'I0500'   
  ,@I0900    [varchar](16)  = 'I0900'   
  ,@I1100    [varchar](16)  = 'I1100'   
  ,@I2000    [varchar](16)  = 'I2000'   
  ,@I2300    [varchar](16)  = 'I2300'   
  ,@I3400    [varchar](16)  = 'I3400'   
  ,@I3700    [varchar](16)  = 'I3700'   
  ,@I4500    [varchar](16)  = 'I4500'   
  ,@I4800    [varchar](16)  = 'I4800'   
  ,@I5000    [varchar](16)  = 'I5000'   
  ,@I5100    [varchar](16)  = 'I5100'   
  ,@I5500    [varchar](16)  = 'I5500'   
  ,@I5700    [varchar](16)  = 'I5700'   
  ,@I5800    [varchar](16)  = 'I5800'   
  ,@I5900    [varchar](16)  = 'I5900'   
  ,@I59050   [varchar](16)  = 'I59050'   
  ,@I5950    [varchar](16)  = 'I5950'   
  ,@I6200    [varchar](16)  = 'I6200'   
  ,@I6500    [varchar](16)  = 'I6500'   
  ,@I8000    [varchar](16)  = 'I8000'   
;

DECLARE @ICD_INPUT TABLE (
     [icd9_code]                   [varchar](15)     NOT NULL
    ,[mds3_question_key]           [varchar](16)         NULL
    ,[NTA_Item]                    [varchar](16)         NULL
    ,PRIMARY KEY ( [icd9_code] ASC )
) 
;

INSERT INTO @ICD_INPUT (
 [icd9_code]  ,[mds3_question_key] ,[NTA_Item]  ) VALUES
 ('A21.2'     ,@I2000  ,NULL   ) 
,('A22.1'     ,@I2000  ,NULL   ) 
,('A42.0'     ,@I2000  ,NULL   ) 
,('A43.0'     ,@I2000  ,NULL   ) 
,('A52.05'    ,@I4500  ,NULL   ) 
,('A52.06'    ,@I0400  ,NULL   ) 
,('A69.8'     ,@I2000  ,NULL   ) 
,('A81.00'    ,@I4800  ,NULL   ) 
,('A81.01'    ,@I4800  ,NULL   ) 
,('A81.09'    ,@I4800  ,NULL   ) 
,('B37.1'     ,@I2000  ,@I8000 ) 
,('B38.0'     ,@I2000  ,NULL   ) 
,('B38.1'     ,@I2000  ,NULL   ) 
,('B38.2'     ,@I2000  ,NULL   ) 
,('B39.0'     ,@I2000  ,NULL   ) 
,('B39.1'     ,@I2000  ,NULL   ) 
,('B39.2'     ,@I2000  ,NULL   ) 
,('B44.0'     ,@I2000  ,@I8000 ) 
,('B44.1'     ,@I2000  ,@I8000 ) 
,('B44.81'    ,@I6200  ,@I8000 ) 
,('B58.3'     ,@I2000  ,@I8000 ) 
,('B59'       ,@I2000  ,@I8000 ) 
,('C56.3'     ,@I0100  ,NULL   ) 
,('C79.63'    ,@I0100  ,NULL   ) 
,('C84.7A'    ,@I0100  ,NULL   ) 
,('D55.21'    ,@I0200  ,NULL   ) 
,('D55.29'    ,@I0200  ,NULL   ) 
,('E89.0'     ,@I3400  ,NULL   ) 
,('F06.31'    ,@I5800  ,NULL   ) 
,('F06.32'    ,@I5800  ,NULL   ) 
,('F06.33'    ,@I5900  ,NULL   ) 
,('F06.34'    ,@I5900  ,NULL   ) 
,('F10.150'   ,@I5950  ,NULL   ) 
,('F10.151'   ,@I5950  ,NULL   ) 
,('F10.159'   ,@I5950  ,NULL   ) 
,('F10.180'   ,@I5700  ,NULL   ) 
,('F10.250'   ,@I5950  ,NULL   ) 
,('F10.251'   ,@I5950  ,NULL   ) 
,('F10.259'   ,@I5950  ,NULL   ) 
,('F10.280'   ,@I5700  ,NULL   ) 
,('F10.950'   ,@I5950  ,NULL   ) 
,('F10.951'   ,@I5950  ,NULL   ) 
,('F10.959'   ,@I5950  ,NULL   ) 
,('F10.980'   ,@I5700  ,NULL   ) 
,('F11.150'   ,@I5950  ,NULL   ) 
,('F11.151'   ,@I5950  ,NULL   ) 
,('F11.159'   ,@I5950  ,NULL   ) 
,('F11.250'   ,@I5950  ,NULL   ) 
,('F11.251'   ,@I5950  ,NULL   ) 
,('F11.259'   ,@I5950  ,NULL   ) 
,('F11.950'   ,@I5950  ,NULL   ) 
,('F11.951'   ,@I5950  ,NULL   ) 
,('F11.959'   ,@I5950  ,NULL   ) 
,('F12.150'   ,@I5950  ,NULL   ) 
,('F12.151'   ,@I5950  ,NULL   ) 
,('F12.159'   ,@I5950  ,NULL   ) 
,('F12.180'   ,@I5700  ,NULL   ) 
,('F12.250'   ,@I5950  ,NULL   ) 
,('F12.251'   ,@I5950  ,NULL   ) 
,('F12.259'   ,@I5950  ,NULL   ) 
,('F12.280'   ,@I5700  ,NULL   ) 
,('F12.950'   ,@I5950  ,NULL   ) 
,('F12.951'   ,@I5950  ,NULL   ) 
,('F12.959'   ,@I5950  ,NULL   ) 
,('F12.980'   ,@I5700  ,NULL   ) 
,('F13.150'   ,@I5950  ,NULL   ) 
,('F13.151'   ,@I5950  ,NULL   ) 
,('F13.159'   ,@I5950  ,NULL   ) 
,('F13.180'   ,@I5700  ,NULL   ) 
,('F13.250'   ,@I5950  ,NULL   ) 
,('F13.251'   ,@I5950  ,NULL   ) 
,('F13.259'   ,@I5950  ,NULL   ) 
,('F13.280'   ,@I5700  ,NULL   ) 
,('F13.950'   ,@I5950  ,NULL   ) 
,('F13.951'   ,@I5950  ,NULL   ) 
,('F13.959'   ,@I5950  ,NULL   ) 
,('F13.980'   ,@I5700  ,NULL   ) 
,('F14.150'   ,@I5950  ,NULL   ) 
,('F14.151'   ,@I5950  ,NULL   ) 
,('F14.159'   ,@I5950  ,NULL   ) 
,('F14.180'   ,@I5700  ,NULL   ) 
,('F14.251'   ,@I5950  ,NULL   ) 
,('F14.259'   ,@I5950  ,NULL   ) 
,('F14.280'   ,@I5700  ,NULL   ) 
,('F14.950'   ,@I5950  ,NULL   ) 
,('F14.951'   ,@I5950  ,NULL   ) 
,('F14.959'   ,@I5950  ,NULL   ) 
,('F14.980'   ,@I5700  ,NULL   ) 
,('F15.150'   ,@I5950  ,NULL   ) 
,('F15.151'   ,@I5950  ,NULL   ) 
,('F15.159'   ,@I5950  ,NULL   ) 
,('F15.180'   ,@I5700  ,NULL   ) 
,('F15.250'   ,@I5950  ,NULL   ) 
,('F15.251'   ,@I5950  ,NULL   ) 
,('F15.259'   ,@I5950  ,NULL   ) 
,('F15.280'   ,@I5700  ,NULL   ) 
,('F15.950'   ,@I5950  ,NULL   ) 
,('F15.951'   ,@I5950  ,NULL   ) 
,('F15.959'   ,@I5900  ,NULL   ) 
,('F15.980'   ,@I5700  ,NULL   ) 
,('F16.151'   ,@I5950  ,NULL   ) 
,('F16.159'   ,@I5950  ,NULL   ) 
,('F16.180'   ,@I5700  ,NULL   ) 
,('F16.250'   ,@I5950  ,NULL   ) 
,('F16.251'   ,@I5950  ,NULL   ) 
,('F16.259'   ,@I5950  ,NULL   ) 
,('F16.280'   ,@I5700  ,NULL   ) 
,('F16.950'   ,@I5950  ,NULL   ) 
,('F16.951'   ,@I5950  ,NULL   ) 
,('F16.959'   ,@I5950  ,NULL   ) 
,('F16.980'   ,@I5700  ,NULL   ) 
,('F18.150'   ,@I5950  ,NULL   ) 
,('F18.151'   ,@I5950  ,NULL   ) 
,('F18.159'   ,@I5950  ,NULL   ) 
,('F18.180'   ,@I5700  ,NULL   ) 
,('F18.250'   ,@I5950  ,NULL   ) 
,('F18.251'   ,@I5950  ,NULL   ) 
,('F18.259'   ,@I5950  ,NULL   ) 
,('F18.280'   ,@I5700  ,NULL   ) 
,('F18.950'   ,@I5950  ,NULL   ) 
,('F18.951'   ,@I5950  ,NULL   ) 
,('F18.959'   ,@I5950  ,NULL   ) 
,('F18.980'   ,@I5700  ,NULL   ) 
,('F19.150'   ,@I5950  ,NULL   ) 
,('F19.151'   ,@I5950  ,NULL   ) 
,('F19.159'   ,@I5950  ,NULL   ) 
,('F19.180'   ,@I5700  ,NULL   ) 
,('F19.250'   ,@I5950  ,NULL   ) 
,('F19.251'   ,@I5950  ,NULL   ) 
,('F19.259'   ,@I5950  ,NULL   ) 
,('F19.280'   ,@I5700  ,NULL   ) 
,('F19.950'   ,@I5950  ,NULL   ) 
,('F19.951'   ,@I5950  ,NULL   ) 
,('F19.959'   ,@I5950  ,NULL   ) 
,('F19.980'   ,@I5700  ,NULL   ) 
,('F32.A'     ,@I5800  ,NULL   ) 
,('I60.00'    ,@I4500  ,NULL   ) 
,('I60.01'    ,@I4500  ,NULL   ) 
,('I60.02'    ,@I4500  ,NULL   ) 
,('I60.10'    ,@I4500  ,NULL   ) 
,('I60.11'    ,@I4500  ,NULL   ) 
,('I60.12'    ,@I4500  ,NULL   ) 
,('I60.30'    ,@I4500  ,NULL   ) 
,('I60.31'    ,@I4500  ,NULL   ) 
,('I60.32'    ,@I4500  ,NULL   ) 
,('I60.4'     ,@I4500  ,NULL   ) 
,('I60.50'    ,@I4500  ,NULL   ) 
,('I60.51'    ,@I4500  ,NULL   ) 
,('I60.52'    ,@I4500  ,NULL   ) 
,('I60.6'     ,@I4500  ,NULL   ) 
,('I60.7'     ,@I4500  ,NULL   ) 
,('I60.8'     ,@I4500  ,NULL   ) 
,('I60.9'     ,@I4500  ,NULL   ) 
,('I61.0'     ,@I4500  ,NULL   ) 
,('I61.1'     ,@I4500  ,NULL   ) 
,('I61.2'     ,@I4500  ,NULL   ) 
,('I61.3'     ,@I4500  ,NULL   ) 
,('I61.4'     ,@I4500  ,NULL   ) 
,('I61.5'     ,@I4500  ,NULL   ) 
,('I61.6'     ,@I4500  ,NULL   ) 
,('I61.8'     ,@I4500  ,NULL   ) 
,('I61.9'     ,@I4500  ,NULL   ) 
,('I62.00'    ,@I4500  ,NULL   ) 
,('I62.01'    ,@I4500  ,NULL   ) 
,('I62.02'    ,@I4500  ,NULL   ) 
,('I62.03'    ,@I4500  ,NULL   ) 
,('I62.1'     ,@I4500  ,NULL   ) 
,('I62.9'     ,@I4500  ,NULL   ) 
,('I80.00'    ,@I0500  ,NULL   ) 
,('I80.01'    ,@I0500  ,NULL   ) 
,('I80.02'    ,@I0500  ,NULL   ) 
,('I80.03'    ,@I0500  ,NULL   ) 
,('I80.10'    ,@I0500  ,NULL   ) 
,('I80.11'    ,@I0500  ,NULL   ) 
,('I80.12'    ,@I0500  ,NULL   ) 
,('I80.13'    ,@I0500  ,NULL   ) 
,('I80.201'   ,@I0500  ,NULL   ) 
,('I80.202'   ,@I0500  ,NULL   ) 
,('I80.203'   ,@I0500  ,NULL   ) 
,('I80.209'   ,@I0500  ,NULL   ) 
,('I80.211'   ,@I0500  ,NULL   ) 
,('I80.212'   ,@I0500  ,NULL   ) 
,('I80.213'   ,@I0500  ,NULL   ) 
,('I80.219'   ,@I0500  ,NULL   ) 
,('I80.221'   ,@I0500  ,NULL   ) 
,('I80.222'   ,@I0500  ,NULL   ) 
,('I80.223'   ,@I0500  ,NULL   ) 
,('I80.229'   ,@I0500  ,NULL   ) 
,('I80.231'   ,@I0500  ,NULL   ) 
,('I80.232'   ,@I0500  ,NULL   ) 
,('I80.233'   ,@I0500  ,NULL   ) 
,('I80.239'   ,@I0500  ,NULL   ) 
,('I80.291'   ,@I0500  ,NULL   ) 
,('I80.292'   ,@I0500  ,NULL   ) 
,('I80.293'   ,@I0500  ,NULL   ) 
,('I80.299'   ,@I0500  ,NULL   ) 
,('I80.3'     ,@I0500  ,NULL   ) 
,('I80.8'     ,@I0500  ,NULL   ) 
,('I80.9'     ,@I0500  ,NULL   ) 
,('J12.82'    ,@I2000  ,NULL   ) 
,('J47.0'     ,@I6200  ,@I8000 ) 
,('J47.1'     ,@I6200  ,@I8000 ) 
,('J47.9'     ,@I6200  ,@I8000 ) 
,('J66.8'     ,@I6200  ,NULL   ) 
,('J69.0'     ,@I2000  ,NULL   ) 
,('J69.1'     ,@I2000  ,NULL   ) 
,('J69.8'     ,@I2000  ,NULL   ) 
,('J70.0'     ,@I6200  ,@I8000 ) 
,('J70.1'     ,@I6200  ,@I8000 ) 
,('J70.2'     ,@I6200  ,@I8000 ) 
,('J70.3'     ,@I6200  ,@I8000 ) 
,('J70.4'     ,@I6200  ,@I8000 ) 
,('J70.5'     ,@I6200  ,@I8000 ) 
,('J70.8'     ,@I6200  ,@I8000 ) 
,('J70.9'     ,@I6200  ,@I8000 ) 
,('J81.1'     ,@I6200  ,NULL   ) 
,('J84.01'    ,@I6200  ,@I8000 ) 
,('J84.02'    ,@I6200  ,@I8000 ) 
,('J84.03'    ,@I6200  ,@I8000 ) 
,('J84.09'    ,@I6200  ,@I8000 ) 
,('J84.10'    ,@I6200  ,@I8000 ) 
,('J84.112'   ,@I6200  ,@I8000 ) 
,('J84.113'   ,@I6200  ,@I8000 ) 
,('J84.114'   ,@I6200  ,@I8000 ) 
,('J84.115'   ,@I6200  ,@I8000 ) 
,('J84.117'   ,@I2000  ,@I8000 ) 
,('J84.170'   ,@I6200  ,NULL   ) 
,('J84.178'   ,@I2000  ,NULL   ) 
,('J84.81'    ,@I6200  ,@I8000 ) 
,('J84.82'    ,@I6200  ,@I8000 ) 
,('J84.83'    ,@I6200  ,@I8000 ) 
,('J84.841'   ,@I6200  ,@I8000 ) 
,('J84.842'   ,@I6200  ,@I8000 ) 
,('J84.843'   ,@I6200  ,@I8000 ) 
,('J84.848'   ,@I6200  ,@I8000 ) 
,('J84.89'    ,@I6200  ,@I8000 ) 
,('J84.9'     ,@I6200  ,@I8000 ) 
,('J99'       ,@I6200  ,@I8000 ) 
,('M32.13'    ,@I6200  ,@I8000 ) 
,('M33.01'    ,@I6200  ,@I8000 ) 
,('M33.11'    ,@I6200  ,@I8000 ) 
,('M33.21'    ,@I6200  ,@I8000 ) 
,('M33.91'    ,@I6200  ,@I8000 ) 
,('M34.81'    ,@I6200  ,@I8000 ) 
,('M35.02'    ,@I6200  ,@I8000 ) 
,('M35.05'    ,@I3700  ,NULL   ) 
,('M45.A0'    ,@I3700  ,NULL   ) 
,('M45.A1'    ,@I3700  ,NULL   ) 
,('M45.A2'    ,@I3700  ,NULL   ) 
,('M45.A3'    ,@I3700  ,NULL   ) 
,('M45.A4'    ,@I3700  ,NULL   ) 
,('M45.A5'    ,@I3700  ,NULL   ) 
,('M45.A6'    ,@I3700  ,NULL   ) 
,('M45.A7'    ,@I3700  ,NULL   ) 
,('M45.A8'    ,@I3700  ,NULL   ) 
,('M45.AB'    ,@I3700  ,NULL   ) 
,('M47.10'    ,@I3700  ,NULL   ) 
,('M47.11'    ,@I3700  ,NULL   ) 
,('M47.12'    ,@I3700  ,NULL   ) 
,('M47.13'    ,@I3700  ,NULL   ) 
,('M47.14'    ,@I3700  ,NULL   ) 
,('M47.15'    ,@I3700  ,NULL   ) 
,('M47.16'    ,@I3700  ,NULL   ) 
,('M47.20'    ,@I3700  ,NULL   ) 
,('M47.21'    ,@I3700  ,NULL   ) 
,('M47.22'    ,@I3700  ,NULL   ) 
,('M47.23'    ,@I3700  ,NULL   ) 
,('M47.24'    ,@I3700  ,NULL   ) 
,('M47.25'    ,@I3700  ,NULL   ) 
,('M47.26'    ,@I3700  ,NULL   ) 
,('M47.27'    ,@I3700  ,NULL   ) 
,('M47.28'    ,@I3700  ,NULL   ) 
,('M47.811'   ,@I3700  ,NULL   ) 
,('M47.812'   ,@I3700  ,NULL   ) 
,('M47.813'   ,@I3700  ,NULL   ) 
,('M47.814'   ,@I3700  ,NULL   ) 
,('M47.815'   ,@I3700  ,NULL   ) 
,('M47.816'   ,@I3700  ,NULL   ) 
,('M47.817'   ,@I3700  ,NULL   ) 
,('M47.818'   ,@I3700  ,NULL   ) 
,('M47.819'   ,@I3700  ,NULL   ) 
,('M47.891'   ,@I3700  ,NULL   ) 
,('M47.892'   ,@I3700  ,NULL   ) 
,('M47.893'   ,@I3700  ,NULL   ) 
,('M47.894'   ,@I3700  ,NULL   ) 
,('M47.895'   ,@I3700  ,NULL   ) 
,('M47.896'   ,@I3700  ,NULL   ) 
,('M47.897'   ,@I3700  ,NULL   ) 
,('M47.898'   ,@I3700  ,NULL   ) 
,('M47.899'   ,@I3700  ,NULL   ) 
,('M47.9'     ,@I3700  ,NULL   ) 
,('N30.00'    ,@I2300  ,NULL   ) 
,('N30.01'    ,@I2300  ,NULL   ) 
,('N30.10'    ,@I2300  ,NULL   ) 
,('N30.11'    ,@I2300  ,NULL   ) 
,('N30.20'    ,@I2300  ,NULL   ) 
,('N30.21'    ,@I2300  ,NULL   ) 
,('N30.30'    ,@I2300  ,NULL   ) 
,('N30.31'    ,@I2300  ,NULL   ) 
,('N30.40'    ,@I2300  ,NULL   ) 
,('N30.41'    ,@I2300  ,NULL   ) 
,('N30.80'    ,@I2300  ,NULL   ) 
,('N30.81'    ,@I2300  ,NULL   ) 
,('N30.90'    ,@I2300  ,NULL   ) 
,('N30.91'    ,@I2300  ,NULL   ) 
,('P78.81'    ,@I1100  ,NULL   ) 
,('Q12.0'     ,@I6500  ,NULL   ) 
,('R53.2'     ,@I5100  ,NULL   ) 
,('S06.1X0A'  ,@I5500  ,NULL   ) 
,('S06.1X0D'  ,@I5500  ,NULL   ) 
,('S06.1X0S'  ,@I5500  ,NULL   ) 
,('S06.1X1A'  ,@I5500  ,NULL   ) 
,('S06.1X1D'  ,@I5500  ,NULL   ) 
,('S06.1X1S'  ,@I5500  ,NULL   ) 
,('S06.1X2A'  ,@I5500  ,NULL   ) 
,('S06.1X2D'  ,@I5500  ,NULL   ) 
,('S06.1X2S'  ,@I5500  ,NULL   ) 
,('S06.1X3A'  ,@I5500  ,NULL   ) 
,('S06.1X3D'  ,@I5500  ,NULL   ) 
,('S06.1X3S'  ,@I5500  ,NULL   ) 
,('S06.1X4A'  ,@I5500  ,NULL   ) 
,('S06.1X4D'  ,@I5500  ,NULL   ) 
,('S06.1X4S'  ,@I5500  ,NULL   ) 
,('S06.1X5A'  ,@I5500  ,NULL   ) 
,('S06.1X5D'  ,@I5500  ,NULL   ) 
,('S06.1X5S'  ,@I5500  ,NULL   ) 
,('S06.1X6A'  ,@I5500  ,NULL   ) 
,('S06.1X6D'  ,@I5500  ,NULL   ) 
,('S06.1X6S'  ,@I5500  ,NULL   ) 
,('S06.1X8A'  ,@I5500  ,NULL   ) 
,('S06.1X9A'  ,@I5500  ,NULL   ) 
,('S06.1X9D'  ,@I5500  ,NULL   ) 
,('S06.1X9S'  ,@I5500  ,NULL   ) 
,('S06.310A'  ,@I5500  ,NULL   ) 
,('S06.310D'  ,@I5500  ,NULL   ) 
,('S06.310S'  ,@I5500  ,NULL   ) 
,('S06.311A'  ,@I5500  ,NULL   ) 
,('S06.311D'  ,@I5500  ,NULL   ) 
,('S06.311S'  ,@I5500  ,NULL   ) 
,('S06.312A'  ,@I5500  ,NULL   ) 
,('S06.312D'  ,@I5500  ,NULL   ) 
,('S06.312S'  ,@I5500  ,NULL   ) 
,('S06.313A'  ,@I5500  ,NULL   ) 
,('S06.313D'  ,@I5500  ,NULL   ) 
,('S06.313S'  ,@I5500  ,NULL   ) 
,('S06.314A'  ,@I5500  ,NULL   ) 
,('S06.314D'  ,@I5500  ,NULL   ) 
,('S06.314S'  ,@I5500  ,NULL   ) 
,('S06.315A'  ,@I5500  ,NULL   ) 
,('S06.315D'  ,@I5500  ,NULL   ) 
,('S06.315S'  ,@I5500  ,NULL   ) 
,('S06.316A'  ,@I5500  ,NULL   ) 
,('S06.316D'  ,@I5500  ,NULL   ) 
,('S06.316S'  ,@I5500  ,NULL   ) 
,('S06.317A'  ,@I5500  ,NULL   ) 
,('S06.318A'  ,@I5500  ,NULL   ) 
,('S06.319A'  ,@I5500  ,NULL   ) 
,('S06.319D'  ,@I5500  ,NULL   ) 
,('S06.319S'  ,@I5500  ,NULL   ) 
,('S06.320A'  ,@I5500  ,NULL   ) 
,('S06.320D'  ,@I5500  ,NULL   ) 
,('S06.320S'  ,@I5500  ,NULL   ) 
,('S06.321A'  ,@I5500  ,NULL   ) 
,('S06.321D'  ,@I5500  ,NULL   ) 
,('S06.321S'  ,@I5500  ,NULL   ) 
,('S06.322A'  ,@I5500  ,NULL   ) 
,('S06.322D'  ,@I5500  ,NULL   ) 
,('S06.322S'  ,@I5500  ,NULL   ) 
,('S06.323A'  ,@I5500  ,NULL   ) 
,('S06.323D'  ,@I5500  ,NULL   ) 
,('S06.323S'  ,@I5500  ,NULL   ) 
,('S06.324A'  ,@I5500  ,NULL   ) 
,('S06.324D'  ,@I5500  ,NULL   ) 
,('S06.324S'  ,@I5500  ,NULL   ) 
,('S06.325A'  ,@I5500  ,NULL   ) 
,('S06.325D'  ,@I5500  ,NULL   ) 
,('S06.325S'  ,@I5500  ,NULL   ) 
,('S06.326A'  ,@I5500  ,NULL   ) 
,('S06.326D'  ,@I5500  ,NULL   ) 
,('S06.326S'  ,@I5500  ,NULL   ) 
,('S06.327A'  ,@I5500  ,NULL   ) 
,('S06.328A'  ,@I5500  ,NULL   ) 
,('S06.329A'  ,@I5500  ,NULL   ) 
,('S06.329D'  ,@I5500  ,NULL   ) 
,('S06.329S'  ,@I5500  ,NULL   ) 
,('S06.330A'  ,@I5500  ,NULL   ) 
,('S06.330D'  ,@I5500  ,NULL   ) 
,('S06.330S'  ,@I5500  ,NULL   ) 
,('S06.331A'  ,@I5500  ,NULL   ) 
,('S06.331D'  ,@I5500  ,NULL   ) 
,('S06.331S'  ,@I5500  ,NULL   ) 
,('S06.332A'  ,@I5500  ,NULL   ) 
,('S06.332D'  ,@I5500  ,NULL   ) 
,('S06.332S'  ,@I5500  ,NULL   ) 
,('S06.333A'  ,@I5500  ,NULL   ) 
,('S06.333D'  ,@I5500  ,NULL   ) 
,('S06.333S'  ,@I5500  ,NULL   ) 
,('S06.334A'  ,@I5500  ,NULL   ) 
,('S06.334D'  ,@I5500  ,NULL   ) 
,('S06.334S'  ,@I5500  ,NULL   ) 
,('S06.335A'  ,@I5500  ,NULL   ) 
,('S06.335D'  ,@I5500  ,NULL   ) 
,('S06.335S'  ,@I5500  ,NULL   ) 
,('S06.336A'  ,@I5500  ,NULL   ) 
,('S06.336D'  ,@I5500  ,NULL   ) 
,('S06.336S'  ,@I5500  ,NULL   ) 
,('S06.337A'  ,@I5500  ,NULL   ) 
,('S06.338A'  ,@I5500  ,NULL   ) 
,('S06.339A'  ,@I5500  ,NULL   ) 
,('S06.339D'  ,@I5500  ,NULL   ) 
,('S06.339S'  ,@I5500  ,NULL   ) 
,('S06.340A'  ,@I5500  ,NULL   ) 
,('S06.340D'  ,@I5500  ,NULL   ) 
,('S06.340S'  ,@I5500  ,NULL   ) 
,('S06.341A'  ,@I5500  ,NULL   ) 
,('S06.341D'  ,@I5500  ,NULL   ) 
,('S06.341S'  ,@I5500  ,NULL   ) 
,('S06.342A'  ,@I5500  ,NULL   ) 
,('S06.342D'  ,@I5500  ,NULL   ) 
,('S06.342S'  ,@I5500  ,NULL   ) 
,('S06.343A'  ,@I5500  ,NULL   ) 
,('S06.343D'  ,@I5500  ,NULL   ) 
,('S06.343S'  ,@I5500  ,NULL   ) 
,('S06.344A'  ,@I5500  ,NULL   ) 
,('S06.344D'  ,@I5500  ,NULL   ) 
,('S06.344S'  ,@I5500  ,NULL   ) 
,('S06.345A'  ,@I5500  ,NULL   ) 
,('S06.345D'  ,@I5500  ,NULL   ) 
,('S06.345S'  ,@I5500  ,NULL   ) 
,('S06.346A'  ,@I5500  ,NULL   ) 
,('S06.346D'  ,@I5500  ,NULL   ) 
,('S06.346S'  ,@I5500  ,NULL   ) 
,('S06.348A'  ,@I5500  ,NULL   ) 
,('S06.349A'  ,@I5500  ,NULL   ) 
,('S06.349D'  ,@I5500  ,NULL   ) 
,('S06.349S'  ,@I5500  ,NULL   ) 
,('S06.350A'  ,@I5500  ,NULL   ) 
,('S06.350D'  ,@I5500  ,NULL   ) 
,('S06.350S'  ,@I5500  ,NULL   ) 
,('S06.351A'  ,@I5500  ,NULL   ) 
,('S06.351D'  ,@I5500  ,NULL   ) 
,('S06.351S'  ,@I5500  ,NULL   ) 
,('S06.352A'  ,@I5500  ,NULL   ) 
,('S06.352D'  ,@I5500  ,NULL   ) 
,('S06.352S'  ,@I5500  ,NULL   ) 
,('S06.353A'  ,@I5500  ,NULL   ) 
,('S06.353D'  ,@I5500  ,NULL   ) 
,('S06.353S'  ,@I5500  ,NULL   ) 
,('S06.354A'  ,@I5500  ,NULL   ) 
,('S06.354D'  ,@I5500  ,NULL   ) 
,('S06.354S'  ,@I5500  ,NULL   ) 
,('S06.355A'  ,@I5500  ,NULL   ) 
,('S06.355D'  ,@I5500  ,NULL   ) 
,('S06.355S'  ,@I5500  ,NULL   ) 
,('S06.356A'  ,@I5500  ,NULL   ) 
,('S06.356D'  ,@I5500  ,NULL   ) 
,('S06.356S'  ,@I5500  ,NULL   ) 
,('S06.358A'  ,@I5500  ,NULL   ) 
,('S06.359A'  ,@I5500  ,NULL   ) 
,('S06.359D'  ,@I5500  ,NULL   ) 
,('S06.359S'  ,@I5500  ,NULL   ) 
,('S06.360A'  ,@I5500  ,NULL   ) 
,('S06.360D'  ,@I5500  ,NULL   ) 
,('S06.360S'  ,@I5500  ,NULL   ) 
,('S06.361A'  ,@I5500  ,NULL   ) 
,('S06.361D'  ,@I5500  ,NULL   ) 
,('S06.361S'  ,@I5500  ,NULL   ) 
,('S06.362A'  ,@I5500  ,NULL   ) 
,('S06.362D'  ,@I5500  ,NULL   ) 
,('S06.362S'  ,@I5500  ,NULL   ) 
,('S06.363A'  ,@I5500  ,NULL   ) 
,('S06.363D'  ,@I5500  ,NULL   ) 
,('S06.363S'  ,@I5500  ,NULL   ) 
,('S06.364A'  ,@I5500  ,NULL   ) 
,('S06.364D'  ,@I5500  ,NULL   ) 
,('S06.364S'  ,@I5500  ,NULL   ) 
,('S06.365A'  ,@I5500  ,NULL   ) 
,('S06.365D'  ,@I5500  ,NULL   ) 
,('S06.365S'  ,@I5500  ,NULL   ) 
,('S06.366A'  ,@I5500  ,NULL   ) 
,('S06.366D'  ,@I5500  ,NULL   ) 
,('S06.366S'  ,@I5500  ,NULL   ) 
,('S06.368A'  ,@I5500  ,NULL   ) 
,('S06.369A'  ,@I5500  ,NULL   ) 
,('S06.369D'  ,@I5500  ,NULL   ) 
,('S06.369S'  ,@I5500  ,NULL   ) 
,('S06.370A'  ,@I5500  ,NULL   ) 
,('S06.370D'  ,@I5500  ,NULL   ) 
,('S06.370S'  ,@I5500  ,NULL   ) 
,('S06.371A'  ,@I5500  ,NULL   ) 
,('S06.371D'  ,@I5500  ,NULL   ) 
,('S06.371S'  ,@I5500  ,NULL   ) 
,('S06.372A'  ,@I5500  ,NULL   ) 
,('S06.372D'  ,@I5500  ,NULL   ) 
,('S06.372S'  ,@I5500  ,NULL   ) 
,('S06.373A'  ,@I5500  ,NULL   ) 
,('S06.373D'  ,@I5500  ,NULL   ) 
,('S06.373S'  ,@I5500  ,NULL   ) 
,('S06.374A'  ,@I5500  ,NULL   ) 
,('S06.374D'  ,@I5500  ,NULL   ) 
,('S06.374S'  ,@I5500  ,NULL   ) 
,('S06.375A'  ,@I5500  ,NULL   ) 
,('S06.375D'  ,@I5500  ,NULL   ) 
,('S06.375S'  ,@I5500  ,NULL   ) 
,('S06.376A'  ,@I5500  ,NULL   ) 
,('S06.376D'  ,@I5500  ,NULL   ) 
,('S06.376S'  ,@I5500  ,NULL   ) 
,('S06.377A'  ,@I5500  ,NULL   ) 
,('S06.378A'  ,@I5500  ,NULL   ) 
,('S06.379A'  ,@I5500  ,NULL   ) 
,('S06.379D'  ,@I5500  ,NULL   ) 
,('S06.379S'  ,@I5500  ,NULL   ) 
,('S06.380A'  ,@I5500  ,NULL   ) 
,('S06.380D'  ,@I5500  ,NULL   ) 
,('S06.380S'  ,@I5500  ,NULL   ) 
,('S06.381A'  ,@I5500  ,NULL   ) 
,('S06.381D'  ,@I5500  ,NULL   ) 
,('S06.381S'  ,@I5500  ,NULL   ) 
,('S06.382A'  ,@I5500  ,NULL   ) 
,('S06.382D'  ,@I5500  ,NULL   ) 
,('S06.382S'  ,@I5500  ,NULL   ) 
,('S06.383A'  ,@I5500  ,NULL   ) 
,('S06.383D'  ,@I5500  ,NULL   ) 
,('S06.383S'  ,@I5500  ,NULL   ) 
,('S06.384A'  ,@I5500  ,NULL   ) 
,('S06.384D'  ,@I5500  ,NULL   ) 
,('S06.384S'  ,@I5500  ,NULL   ) 
,('S06.385A'  ,@I5500  ,NULL   ) 
,('S06.385D'  ,@I5500  ,NULL   ) 
,('S06.385S'  ,@I5500  ,NULL   ) 
,('S06.386A'  ,@I5500  ,NULL   ) 
,('S06.386D'  ,@I5500  ,NULL   ) 
,('S06.386S'  ,@I5500  ,NULL   ) 
,('S06.387A'  ,@I5500  ,NULL   ) 
,('S06.388A'  ,@I5500  ,NULL   ) 
,('S06.389A'  ,@I5500  ,NULL   ) 
,('S06.389D'  ,@I5500  ,NULL   ) 
,('S06.389S'  ,@I5500  ,NULL   ) 
,('S06.4X0A'  ,@I5500  ,NULL   ) 
,('S06.4X0D'  ,@I5500  ,NULL   ) 
,('S06.4X0S'  ,@I5500  ,NULL   ) 
,('S06.4X1A'  ,@I5500  ,NULL   ) 
,('S06.4X1D'  ,@I5500  ,NULL   ) 
,('S06.4X1S'  ,@I5500  ,NULL   ) 
,('S06.4X2A'  ,@I5500  ,NULL   ) 
,('S06.4X2D'  ,@I5500  ,NULL   ) 
,('S06.4X2S'  ,@I5500  ,NULL   ) 
,('S06.4X3A'  ,@I5500  ,NULL   ) 
,('S06.4X3D'  ,@I5500  ,NULL   ) 
,('S06.4X3S'  ,@I5500  ,NULL   ) 
,('S06.4X4A'  ,@I5500  ,NULL   ) 
,('S06.4X4D'  ,@I5500  ,NULL   ) 
,('S06.4X4S'  ,@I5500  ,NULL   ) 
,('S06.4X5A'  ,@I5500  ,NULL   ) 
,('S06.4X5D'  ,@I5500  ,NULL   ) 
,('S06.4X5S'  ,@I5500  ,NULL   ) 
,('S06.4X6A'  ,@I5500  ,NULL   ) 
,('S06.4X6D'  ,@I5500  ,NULL   ) 
,('S06.4X6S'  ,@I5500  ,NULL   ) 
,('S06.4X7A'  ,@I5500  ,NULL   ) 
,('S06.4X8A'  ,@I5500  ,NULL   ) 
,('S06.4X9A'  ,@I5500  ,NULL   ) 
,('S06.4X9D'  ,@I5500  ,NULL   ) 
,('S06.4X9S'  ,@I5500  ,NULL   ) 
,('S06.5X0A'  ,@I5500  ,NULL   ) 
,('S06.5X0D'  ,@I5500  ,NULL   ) 
,('S06.5X0S'  ,@I5500  ,NULL   ) 
,('S06.5X1A'  ,@I5500  ,NULL   ) 
,('S06.5X1D'  ,@I5500  ,NULL   ) 
,('S06.5X1S'  ,@I5500  ,NULL   ) 
,('S06.5X2A'  ,@I5500  ,NULL   ) 
,('S06.5X2D'  ,@I5500  ,NULL   ) 
,('S06.5X2S'  ,@I5500  ,NULL   ) 
,('S06.5X3A'  ,@I5500  ,NULL   ) 
,('S06.5X3D'  ,@I5500  ,NULL   ) 
,('S06.5X3S'  ,@I5500  ,NULL   ) 
,('S06.5X4A'  ,@I5500  ,NULL   ) 
,('S06.5X4D'  ,@I5500  ,NULL   ) 
,('S06.5X4S'  ,@I5500  ,NULL   ) 
,('S06.5X5A'  ,@I5500  ,NULL   ) 
,('S06.5X5D'  ,@I5500  ,NULL   ) 
,('S06.5X5S'  ,@I5500  ,NULL   ) 
,('S06.5X6A'  ,@I5500  ,NULL   ) 
,('S06.5X6D'  ,@I5500  ,NULL   ) 
,('S06.5X6S'  ,@I5500  ,NULL   ) 
,('S06.5X8A'  ,@I5500  ,NULL   ) 
,('S06.5X9A'  ,@I5500  ,NULL   ) 
,('S06.5X9D'  ,@I5500  ,NULL   ) 
,('S06.5X9S'  ,@I5500  ,NULL   ) 
,('S06.6X0A'  ,@I5500  ,NULL   ) 
,('S06.6X0D'  ,@I5500  ,NULL   ) 
,('S06.6X0S'  ,@I5500  ,NULL   ) 
,('S06.6X1A'  ,@I5500  ,NULL   ) 
,('S06.6X1D'  ,@I5500  ,NULL   ) 
,('S06.6X1S'  ,@I5500  ,NULL   ) 
,('S06.6X2A'  ,@I5500  ,NULL   ) 
,('S06.6X2D'  ,@I5500  ,NULL   ) 
,('S06.6X2S'  ,@I5500  ,NULL   ) 
,('S06.6X3A'  ,@I5500  ,NULL   ) 
,('S06.6X3D'  ,@I5500  ,NULL   ) 
,('S06.6X3S'  ,@I5500  ,NULL   ) 
,('S06.6X4A'  ,@I5500  ,NULL   ) 
,('S06.6X4D'  ,@I5500  ,NULL   ) 
,('S06.6X4S'  ,@I5500  ,NULL   ) 
,('S06.6X5A'  ,@I5500  ,NULL   ) 
,('S06.6X5D'  ,@I5500  ,NULL   ) 
,('S06.6X5S'  ,@I5500  ,NULL   ) 
,('S06.6X6A'  ,@I5500  ,NULL   ) 
,('S06.6X6D'  ,@I5500  ,NULL   ) 
,('S06.6X6S'  ,@I5500  ,NULL   ) 
,('S06.6X8A'  ,@I5500  ,NULL   ) 
,('S06.6X9A'  ,@I5500  ,NULL   ) 
,('S06.6X9D'  ,@I5500  ,NULL   ) 
,('S06.6X9S'  ,@I5500  ,NULL   ) 
,('S06.810A'  ,@I5500  ,NULL   ) 
,('S06.810D'  ,@I5500  ,NULL   ) 
,('S06.810S'  ,@I5500  ,NULL   ) 
,('S06.811A'  ,@I5500  ,NULL   ) 
,('S06.811D'  ,@I5500  ,NULL   ) 
,('S06.811S'  ,@I5500  ,NULL   ) 
,('S06.812A'  ,@I5500  ,NULL   ) 
,('S06.812D'  ,@I5500  ,NULL   ) 
,('S06.812S'  ,@I5500  ,NULL   ) 
,('S06.813A'  ,@I5500  ,NULL   ) 
,('S06.813D'  ,@I5500  ,NULL   ) 
,('S06.813S'  ,@I5500  ,NULL   ) 
,('S06.814A'  ,@I5500  ,NULL   ) 
,('S06.814D'  ,@I5500  ,NULL   ) 
,('S06.814S'  ,@I5500  ,NULL   ) 
,('S06.815A'  ,@I5500  ,NULL   ) 
,('S06.815D'  ,@I5500  ,NULL   ) 
,('S06.815S'  ,@I5500  ,NULL   ) 
,('S06.816A'  ,@I5500  ,NULL   ) 
,('S06.816D'  ,@I5500  ,NULL   ) 
,('S06.816S'  ,@I5500  ,NULL   ) 
,('S06.817A'  ,@I5500  ,NULL   ) 
,('S06.818A'  ,@I5500  ,NULL   ) 
,('S06.819A'  ,@I5500  ,NULL   ) 
,('S06.819D'  ,@I5500  ,NULL   ) 
,('S06.819S'  ,@I5500  ,NULL   ) 
,('S06.820A'  ,@I5500  ,NULL   ) 
,('S06.820D'  ,@I5500  ,NULL   ) 
,('S06.820S'  ,@I5500  ,NULL   ) 
,('S06.821A'  ,@I5500  ,NULL   ) 
,('S06.821D'  ,@I5500  ,NULL   ) 
,('S06.821S'  ,@I5500  ,NULL   ) 
,('S06.822A'  ,@I5500  ,NULL   ) 
,('S06.822D'  ,@I5500  ,NULL   ) 
,('S06.822S'  ,@I5500  ,NULL   ) 
,('S06.823A'  ,@I5500  ,NULL   ) 
,('S06.823D'  ,@I5500  ,NULL   ) 
,('S06.823S'  ,@I5500  ,NULL   ) 
,('S06.824A'  ,@I5500  ,NULL   ) 
,('S06.824D'  ,@I5500  ,NULL   ) 
,('S06.824S'  ,@I5500  ,NULL   ) 
,('S06.825A'  ,@I5500  ,NULL   ) 
,('S06.825D'  ,@I5500  ,NULL   ) 
,('S06.825S'  ,@I5500  ,NULL   ) 
,('S06.826A'  ,@I5500  ,NULL   ) 
,('S06.826D'  ,@I5500  ,NULL   ) 
,('S06.826S'  ,@I5500  ,NULL   ) 
,('S06.827A'  ,@I5500  ,NULL   ) 
,('S06.828A'  ,@I5500  ,NULL   ) 
,('S06.829A'  ,@I5500  ,NULL   ) 
,('S06.829D'  ,@I5500  ,NULL   ) 
,('S06.829S'  ,@I5500  ,NULL   ) 
,('S06.890A'  ,@I5500  ,NULL   ) 
,('S06.890D'  ,@I5500  ,NULL   ) 
,('S06.890S'  ,@I5500  ,NULL   ) 
,('S06.891A'  ,@I5500  ,NULL   ) 
,('S06.891D'  ,@I5500  ,NULL   ) 
,('S06.891S'  ,@I5500  ,NULL   ) 
,('S06.892A'  ,@I5500  ,NULL   ) 
,('S06.892D'  ,@I5500  ,NULL   ) 
,('S06.892S'  ,@I5500  ,NULL   ) 
,('S06.893A'  ,@I5500  ,NULL   ) 
,('S06.893D'  ,@I5500  ,NULL   ) 
,('S06.893S'  ,@I5500  ,NULL   ) 
,('S06.894A'  ,@I5500  ,NULL   ) 
,('S06.894D'  ,@I5500  ,NULL   ) 
,('S06.894S'  ,@I5500  ,NULL   ) 
,('S06.895A'  ,@I5500  ,NULL   ) 
,('S06.895D'  ,@I5500  ,NULL   ) 
,('S06.895S'  ,@I5500  ,NULL   ) 
,('S06.896A'  ,@I5500  ,NULL   ) 
,('S06.896D'  ,@I5500  ,NULL   ) 
,('S06.896S'  ,@I5500  ,NULL   ) 
,('S06.897A'  ,@I5500  ,NULL   ) 
,('S06.898A'  ,@I5500  ,NULL   ) 
,('S06.899A'  ,@I5500  ,NULL   ) 
,('S06.899D'  ,@I5500  ,NULL   ) 
,('S06.899S'  ,@I5500  ,NULL   ) 
,('S06.9X0A'  ,@I5500  ,NULL   ) 
,('S06.9X0D'  ,@I5500  ,NULL   ) 
,('S06.9X0S'  ,@I5500  ,NULL   ) 
,('S06.9X1A'  ,@I5500  ,NULL   ) 
,('S06.9X1D'  ,@I5500  ,NULL   ) 
,('S06.9X1S'  ,@I5500  ,NULL   ) 
,('S06.9X2A'  ,@I5500  ,NULL   ) 
,('S06.9X2D'  ,@I5500  ,NULL   ) 
,('S06.9X2S'  ,@I5500  ,NULL   ) 
,('S06.9X3A'  ,@I5500  ,NULL   ) 
,('S06.9X3D'  ,@I5500  ,NULL   ) 
,('S06.9X3S'  ,@I5500  ,NULL   ) 
,('S06.9X4A'  ,@I5500  ,NULL   ) 
,('S06.9X4D'  ,@I5500  ,NULL   ) 
,('S06.9X4S'  ,@I5500  ,NULL   ) 
,('S06.9X5A'  ,@I5500  ,NULL   ) 
,('S06.9X5D'  ,@I5500  ,NULL   ) 
,('S06.9X5S'  ,@I5500  ,NULL   ) 
,('S06.9X6A'  ,@I5500  ,NULL   ) 
,('S06.9X6D'  ,@I5500  ,NULL   ) 
,('S06.9X6S'  ,@I5500  ,NULL   ) 
,('S06.9X7A'  ,@I5500  ,NULL   ) 
,('S06.9X8A'  ,@I5500  ,NULL   ) 
,('S06.9X9A'  ,@I5500  ,NULL   ) 
,('S06.9X9D'  ,@I5500  ,NULL   ) 
,('S06.9X9S'  ,@I5500  ,NULL   ) 
,('S06.A0XA'  ,@I5500  ,NULL   ) 
,('S06.A0XD'  ,@I5500  ,NULL   ) 
,('S06.A0XS'  ,@I5500  ,NULL   ) 
,('S06.A1XA'  ,@I5500  ,NULL   ) 
,('S06.A1XD'  ,@I5500  ,NULL   ) 
,('S06.A1XS'  ,@I5500  ,NULL   ) 
,('S14.101S'  ,@I5100  ,NULL   ) 
,('S14.102S'  ,@I5100  ,NULL   ) 
,('S14.103S'  ,@I5100  ,NULL   ) 
,('S14.104S'  ,@I5100  ,NULL   ) 
,('S14.105S'  ,@I5100  ,NULL   ) 
,('S14.106S'  ,@I5100  ,NULL   ) 
,('S14.107S'  ,@I5100  ,NULL   ) 
,('S14.108S'  ,@I5100  ,NULL   ) 
,('S14.109S'  ,@I5100  ,NULL   ) 
,('S14.111S'  ,@I5100  ,NULL   ) 
,('S14.112S'  ,@I5100  ,NULL   ) 
,('S14.113S'  ,@I5100  ,NULL   ) 
,('S14.114S'  ,@I5100  ,NULL   ) 
,('S14.115S'  ,@I5100  ,NULL   ) 
,('S14.116S'  ,@I5100  ,NULL   ) 
,('S14.117S'  ,@I5100  ,NULL   ) 
,('S14.118S'  ,@I5100  ,NULL   ) 
,('S14.119S'  ,@I5100  ,NULL   ) 
,('S14.121S'  ,@I5000  ,NULL   ) 
,('S14.122S'  ,@I5000  ,NULL   ) 
,('S14.123S'  ,@I5000  ,NULL   ) 
,('S14.124S'  ,@I5000  ,NULL   ) 
,('S14.125S'  ,@I5000  ,NULL   ) 
,('S14.126S'  ,@I5000  ,NULL   ) 
,('S14.127S'  ,@I5000  ,NULL   ) 
,('S14.128S'  ,@I5000  ,NULL   ) 
,('S14.129S'  ,@I5000  ,NULL   ) 
,('S14.131S'  ,@I5000  ,NULL   ) 
,('S14.132S'  ,@I5000  ,NULL   ) 
,('S14.133S'  ,@I5000  ,NULL   ) 
,('S14.134S'  ,@I5000  ,NULL   ) 
,('S14.135S'  ,@I5000  ,NULL   ) 
,('S14.136S'  ,@I5000  ,NULL   ) 
,('S14.137S'  ,@I5000  ,NULL   ) 
,('S14.138S'  ,@I5000  ,NULL   ) 
,('S14.139S'  ,@I5000  ,NULL   ) 
,('S14.141S'  ,@I5000  ,NULL   ) 
,('S14.142S'  ,@I5000  ,NULL   ) 
,('S14.143S'  ,@I5000  ,NULL   ) 
,('S14.144S'  ,@I5000  ,NULL   ) 
,('S14.145S'  ,@I5000  ,NULL   ) 
,('S14.146S'  ,@I5000  ,NULL   ) 
,('S14.147S'  ,@I5000  ,NULL   ) 
,('S14.148S'  ,@I5000  ,NULL   ) 
,('S14.149S'  ,@I5000  ,NULL   ) 
,('S14.151S'  ,@I5000  ,NULL   ) 
,('S14.152S'  ,@I5000  ,NULL   ) 
,('S14.153S'  ,@I5000  ,NULL   ) 
,('S14.154S'  ,@I5000  ,NULL   ) 
,('S14.155S'  ,@I5000  ,NULL   ) 
,('S14.156S'  ,@I5000  ,NULL   ) 
,('S14.157S'  ,@I5000  ,NULL   ) 
,('S14.158S'  ,@I5000  ,NULL   ) 
,('S14.159S'  ,@I5000  ,NULL   ) 
,('T82.858A'  ,@I0900  ,@I8000 ) 
,('T82.858D'  ,@I0900  ,@I8000 ) 
,('T82.858S'  ,@I0900  ,NULL   ) 
,('T82.868A'  ,@I0500  ,@I8000 ) 
,('T82.868D'  ,@I0500  ,@I8000 ) 
,('T82.868S'  ,@I0500  ,NULL   ) 
,('T80.0XXA'  ,NULL    ,NULL   ) 
,('T80.0XXD'  ,NULL    ,NULL   ) 
,('T80.0XXS'  ,NULL    ,NULL   ) 

/*
-- to view what will be modified

-- these updates are standard entries for fac_id = -1
select 
   d.diagnosis_id          ,D.icd9_code             ,d.diag_lib_id           ,d.fac_id                
  ,d.[mds3_question_key]   ,t.mds3_question_key     ,d.revision_by           ,d.revision_date         
  ,d.system_flag           ,d.deleted               ,d.specificity           
from   [dbo].[diagnosis_codes]   d
inner join @ICD_INPUT            t  on d.diag_lib_id = @diag_lib_id_US and d.icd9_code = t.icd9_code 
where d.system_flag = @SystemFlagY
  and d.deleted = 'N'
  and  (   d.mds3_question_key <> t.mds3_question_key 
       or (d.mds3_question_key is     null AND t.mds3_question_key IS NOT NULL) 
       or (d.mds3_question_key is NOT null AND t.mds3_question_key IS     NULL) )
  and d.fac_id = -1
;

-- these updates are for extra entries for particular facilities
select 
   d.diagnosis_id          ,D.icd9_code             ,d.diag_lib_id           ,d.fac_id                
  ,f.country_id            ,f.fac_id
  ,d.[mds3_question_key]   ,t.mds3_question_key     ,d.revision_by           ,d.revision_date         
  ,d.system_flag           ,d.deleted               ,d.specificity         
from   [dbo].[diagnosis_codes]   d
inner join @ICD_INPUT            t  on d.diag_lib_id = @diag_lib_id_US and d.icd9_code = t.icd9_code 
inner join dbo.facility          f  on f.fac_id = d.fac_id
where d.system_flag = @SystemFlagY
  and d.deleted = 'N'
  and (   d.mds3_question_key <> t.mds3_question_key 
       or (d.mds3_question_key is     null AND t.mds3_question_key IS NOT NULL) 
       or (d.mds3_question_key is NOT null AND t.mds3_question_key IS     NULL) )
  and (f.country_id = @USID or f.country_id is null)
;
*/

-- these updates are standard entries for fac_id = -1
update d set 
  [mds3_question_key] = t.mds3_question_key
 ,revision_by         = @revisionBy
 ,revision_date       = @revisionDate 
from   [dbo].[diagnosis_codes]   d
inner join @ICD_INPUT            t  on d.diag_lib_id = @diag_lib_id_US and d.icd9_code = t.icd9_code
where d.system_flag = @SystemFlagY
  and d.deleted = 'N'
  and d.fac_id = -1
  and (   d.mds3_question_key <> t.mds3_question_key 
       or (d.mds3_question_key is     null AND t.mds3_question_key IS NOT NULL) 
       or (d.mds3_question_key is NOT null AND t.mds3_question_key IS     NULL) )
;

-- these updates are for extra entries for particular facilities
update d set 
  [mds3_question_key] = t.mds3_question_key
 ,revision_by         = @revisionBy
 ,revision_date       = @revisionDate 
from   [dbo].[diagnosis_codes]   d
inner join @ICD_INPUT            t  on d.diag_lib_id = @diag_lib_id_US and d.icd9_code = t.icd9_code 
inner join dbo.facility          f  on f.fac_id = d.fac_id
where d.system_flag = @SystemFlagY
  and d.deleted = 'N'
  and (f.country_id = @USID_100 or f.country_id is null)
  and (   d.mds3_question_key <> t.mds3_question_key 
       or (d.mds3_question_key is     null AND t.mds3_question_key IS NOT NULL) 
       or (d.mds3_question_key is NOT null AND t.mds3_question_key IS     NULL) )
;


GO

print 'A_PreUpload/US_Only/CORE-92067 - DML - Update ICD for MDS3.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/US_Only/CORE-92067 - DML - Update ICD for MDS3.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/US_Only/CORE-98119 - DML - fix IL SLP print.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

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


--=============================================================================
--  Issue:            CORE-98119
--  Written By:       Richard Liu
--  Script Type:      DML
--  Target DB Type:   client
--  Target Database:  US only
--  Re-Runable:       Yes
--  Description :     fix IL SLP assessment title.
--=============================================================================


DECLARE
@description_v2 varchar(500) = 'Illinois SLP Significant Change in Condition Notification for MCO Enrollees - V 2',
@std_assess_id_v2 int,
@question_key_1 varchar(500) = 'Cust_B_7',
@question_key_2 varchar(500) = 'Cust_B_17',
@title_1 varchar(500) = '<b>FUNCTIONAL STATUS</b>',
@title_2 varchar(500) = '<b>WOUND</b>';

select @std_assess_id_v2 = std_assess_id from as_std_assessment where description = @description_v2;

update as_std_question set title = @title_1 where std_assess_id = @std_assess_id_v2 and question_key = @question_key_1;
update as_std_question set title = @title_2 where std_assess_id = @std_assess_id_v2 and question_key = @question_key_2;

GO

print 'A_PreUpload/US_Only/CORE-98119 - DML - fix IL SLP print.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/US_Only/CORE-98119 - DML - fix IL SLP print.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/US_Only/CORE-98306 DML Washington-CMI-Update.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

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
-- CORE-98306 DML Washington-CMI-Update.sql
--
-- JIRA: 
--    Story:  CORE-98306 The State of Washington Case Mix is Incorrect for all Washington facilities effective 10/1/21.
--    Task:   CORE-98969 DEV MDS 3 RUG WA Washington add CMI values 2021
--
-- Written By:  Colin Collins
-- Reviewed By: Scorpion Squad
-- 
-- Script Type:        DML
-- Target DB Type:     Client
-- Target ENVIRONMENT: US ONLY 
-- Re-Runable:    YES 
-- 
-- Where tested:         pccsql-use2-nprd-dvsh-cli0003.bbd2b72cba43.database.windows.net,1433
--                       use DEV_US_Scorpion_Squad_abhow
--
-- Description of Script Function: 
--   Create a copy of the latest Washinton Medicaid RUG-IV 57 Grouper 
--   and then update the case mix indeces.  Set the current model to be ineffective 10/1/2021.
--
--   There are two basic flows when creating a model set (model, categories, and codes).
--   1. A new model is needed.  In this case, the new/to short_desc is different from the old/from short_desc.  
--      Usually nothing is done to the old/from model.
--   2. A model is being modified, perhaps with new cmi values.  In this case, the new/to short_desc 
--      is the same as the old/from short_desc but there are new effective dates.  
--      Usually an ineffective date is added to the old/from model.
--   
--   For Washingtom here we are doing the second type.
--
--   In the source spreadsheet, there are two columns with CMI scores: BABB_120 and BABB_087. 
--   They are the same except for these RUGs: BC1, PA1, PA2, PB1, PB2. The BABB_087 values are 
--   closer to the values from last year so BABB_087 is used below for the new values.  
--   This was confirmed by Product during grooming.
--
-- Special Instruction:    
-- 
-- ================================================================================= 

DECLARE
     @debugBit                 bit = 0
    ,@std_assess_id            int = 11
	,@int_2021                 int = 2021

     -- Paramaters that are usually differernt in the from and to versions
    ,@param_short_old               varchar(5)   = 'WA2'
    ,@param_short_new               varchar(5)   = 'WA2'
    ,@param_effective_date_new      datetime     = '2021-10-01 00:00:00.000'  
    ,@param_ineffective_date_new    datetime     = null     
    ,@param_ineffective_date_old    datetime     = '2021-09-30 23:59:59.997'

     -- Paramaters that are usually the same, but might be differernt in the from and to versions
    ,@Param_long_desc           varchar(100)   = 'WA - RUG-IV- 57 Group - V1.04'
    ,@param_rug_logic_code      varchar(15)    = '1.0457' 
    ,@param_rug_model_num       varchar(5)     = '57'
    ,@Param_rug_version         int            = 4

     -- local variables that are calculated based on data
    ,@local_model_id_old        int  = null  -- the model we are going to copy from
    ,@local_cat_count           int  = null
    ,@local_code_count          int  = null
    ,@local_model_id_prev       int  = null  -- for a rerun, the previous new model that will be deleted
    ,@local_model_id_new        int  = null  -- the new model being created
    ,@local_cat_id_new          int  = null 
    ,@local_rug_code_id_new     int  = null 
;

declare 
  @tempRug  table (
   effective          int              not null                                           
  ,RUG_Code_Ordered   [varchar](15)    not null                                           
  ,Ordr               int              not null                     
  ,RUGCode            [varchar](5)     not null                                  
  ,RUGDescription     [varchar](500)   not null                                           
  ,ADL                [varchar](50)    not null                              
  ,BABB_120           [float]          not null
  ,BABB_087           [float]          not null
  ,PRIMARY KEY CLUSTERED (effective, RUGCode ASC )
  )
;


If (@debugBit = 1) Print 'Step 1  Fix up pcc_global_primary_key ' + convert(varchar(30), getdate(), 121);

DELETE FROM [dbo].[pcc_global_primary_key]
WHERE table_name IN ('as_std_rug_model', 'as_std_rug_cat', 'as_std_rug_code')
;

If (@debugBit = 1) Print 'Step 2 Load @tempRug table. ' + convert(varchar(30), getdate(), 121);

insert into @tempRug values 
    (@int_2021 , '1-RUC' , 1 ,'RUC' ,'Rehabilitation Ultra High'                         ,'11 to 16'  ,3.71  ,3.71
 ) ,(@int_2021 , '2-RUB' , 2 ,'RUB' ,'Rehabilitation Ultra High'                         ,' 6 to 10'  ,3.763 ,3.763
 ) ,(@int_2021 , '3-RUA' , 3 ,'RUA' ,'Rehabilitation Ultra High'                         ,' 0 to  5'  ,2.39  ,2.39
 ) ,(@int_2021 , '4-RVC' , 4 ,'RVC' ,'Rehabilitation Very High'                          ,'11 to 16'  ,3.812 ,3.812
 ) ,(@int_2021 , '5-RVB' , 5 ,'RVB' ,'Rehabilitation Very High'                          ,' 6 to 10'  ,2.777 ,2.777
 ) ,(@int_2021 , '6-RVA' , 6 ,'RVA' ,'Rehabilitation Very High'                          ,' 0 to  5'  ,2.774 ,2.774
 ) ,(@int_2021 , '7-RHC' , 7 ,'RHC' ,'Rehabilitation High'                               ,'11 to 16'  ,3.7   ,3.7
 ) ,(@int_2021 , '8-RHB' , 8 ,'RHB' ,'Rehabilitation High'                               ,' 6 to 10'  ,2.82  ,2.82
 ) ,(@int_2021 , '9-RHA' , 9 ,'RHA' ,'Rehabilitation High'                               ,' 0 to  5'  ,2.222 ,2.222
 ) ,(@int_2021 ,'10-RMC' ,10 ,'RMC' ,'Rehabilitation Medium'                             ,'11 to 16'  ,3.538 ,3.538
 ) ,(@int_2021 ,'11-RMB' ,11 ,'RMB' ,'Rehabilitation Medium'                             ,' 6 to 10'  ,3.285 ,3.285
 ) ,(@int_2021 ,'12-RMA' ,12 ,'RMA' ,'Rehabilitation Medium'                             ,' 0 to  5'  ,2.079 ,2.079
 ) ,(@int_2021 ,'13-RLB' ,13 ,'RLB' ,'Rehabilitation Low'                                ,'11 to 16'  ,3.585 ,3.585
 ) ,(@int_2021 ,'14-RLA' ,14 ,'RLA' ,'Rehabilitation Low'                                ,' 0 to 10'  ,1.859 ,1.859
 ) ,(@int_2021 ,'15-ES3' ,15 ,'ES3' ,'Extensive Services Level 3'                        ,' 2 to 16'  ,5.395 ,5.395
 ) ,(@int_2021 ,'16-ES2' ,16 ,'ES2' ,'Extensive Services Level 2'                        ,' 2 to 16'  ,4.021 ,4.021
 ) ,(@int_2021 ,'17-ES1' ,17 ,'ES1' ,'Extensive Services Level 1'                        ,' 2 to 16'  ,4.099 ,4.099
 ) ,(@int_2021 ,'18-HE2' ,18 ,'HE2' ,'Special Care High with Depression'                 ,'15 to 16'  ,4.14  ,4.14
 ) ,(@int_2021 ,'19-HE1' ,19 ,'HE1' ,'Special Care High with No Depression'              ,'15 to 16'  ,3.154 ,3.154
 ) ,(@int_2021 ,'20-HD2' ,20 ,'HD2' ,'Special Care High with Depression'                 ,'11 to 14'  ,3.599 ,3.599
 ) ,(@int_2021 ,'21-HD1' ,21 ,'HD1' ,'Special Care High with No Depression'              ,'11 to 14'  ,2.908 ,2.908
 ) ,(@int_2021 ,'22-HC2' ,22 ,'HC2' ,'Special Care High with Depression'                 ,' 6 to 10'  ,3.463 ,3.463
 ) ,(@int_2021 ,'23-HC1' ,23 ,'HC1' ,'Special Care High with No Depression'              ,' 6 to 10'  ,2.662 ,2.662
 ) ,(@int_2021 ,'24-HB2' ,24 ,'HB2' ,'Special Care High with Depression'                 ,' 2 to  5'  ,3.286 ,3.286
 ) ,(@int_2021 ,'25-HB1' ,25 ,'HB1' ,'Special Care High with No Depression'              ,' 2 to  5'  ,2.735 ,2.735
 ) ,(@int_2021 ,'26-LE2' ,26 ,'LE2' ,'Special Care Low with Depression'                  ,'15 to 16'  ,3.7   ,3.7
 ) ,(@int_2021 ,'27-LE1' ,27 ,'LE1' ,'Special Care Low with No Depression'               ,'15 to 16'  ,2.829 ,2.829
 ) ,(@int_2021 ,'28-LD2' ,28 ,'LD2' ,'Special Care Low with Depression'                  ,'11 to 14'  ,3.347 ,3.347
 ) ,(@int_2021 ,'29-LD1' ,29 ,'LD1' ,'Special Care Low with No Depression'               ,'11 to 14'  ,2.618 ,2.618
 ) ,(@int_2021 ,'30-LC2' ,30 ,'LC2' ,'Special Care Low with Depression'                  ,' 6 to 10'  ,2.755 ,2.755
 ) ,(@int_2021 ,'31-LC1' ,31 ,'LC1' ,'Special Care Low with No Depression'               ,' 6 to 10'  ,2.318 ,2.318
 ) ,(@int_2021 ,'32-LB2' ,32 ,'LB2' ,'Special Care Low with Depression'                  ,' 2 to  5'  ,2.978 ,2.978
 ) ,(@int_2021 ,'33-LB1' ,33 ,'LB1' ,'Special Care Low with No Depression'               ,' 2 to  5'  ,2.191 ,2.191
 ) ,(@int_2021 ,'34-CE2' ,34 ,'CE2' ,'Clinically Complex with Depression'                ,'15 to 16'  ,3.075 ,3.075
 ) ,(@int_2021 ,'35-CE1' ,35 ,'CE1' ,'Clinically Complex with No Depression'             ,'15 to 16'  ,2.684 ,2.684
 ) ,(@int_2021 ,'36-CD2' ,36 ,'CD2' ,'Clinically Complex with Depression'                ,'11 to 14'  ,2.73  ,2.73
 ) ,(@int_2021 ,'37-CD1' ,37 ,'CD1' ,'Clinically Complex with No Depression'             ,'11 to 14'  ,2.601 ,2.601
 ) ,(@int_2021 ,'38-CC2' ,38 ,'CC2' ,'Clinically Complex with Depression'                ,' 6 to 10'  ,2.294 ,2.294
 ) ,(@int_2021 ,'39-CC1' ,39 ,'CC1' ,'Clinically Complex with No Depression'             ,' 6 to 10'  ,2.146 ,2.146
 ) ,(@int_2021 ,'40-CB2' ,40 ,'CB2' ,'Clinically Complex with Depression'                ,' 2 to  5'  ,2.093 ,2.093
 ) ,(@int_2021 ,'41-CB1' ,41 ,'CB1' ,'Clinically Complex with No Depression'             ,' 2 to  5'  ,1.84  ,1.84
 ) ,(@int_2021 ,'42-CA2' ,42 ,'CA2' ,'Clinically Complex with Depression'                ,' 0 to  1'  ,1.672 ,1.672
 ) ,(@int_2021 ,'43-CA1' ,43 ,'CA1' ,'Clinically Complex with No Depression'             ,' 0 to  1'  ,1.453 ,1.453
 ) ,(@int_2021 ,'44-BB2' ,44 ,'BB2' ,'Behavioral/Cognitive with Restorative Nursing'     ,' 2 to  5'  ,2.063 ,2.063
 ) ,(@int_2021 ,'45-BB1' ,45 ,'BB1' ,'Behavioral/Cognitive with No Restorative Nursing'  ,' 2 to  5'  ,1.949 ,1.949
 ) ,(@int_2021 ,'46-BA2' ,46 ,'BA2' ,'Behavioral/Cognitive with Restorative Nursing'     ,' 0 to  1'  ,1.537 ,1.537
 ) ,(@int_2021 ,'47-BA1' ,47 ,'BA1' ,'Behavioral/Cognitive with No Restorative Nursing'  ,' 0 to  1'  ,1.453 ,1.453
 ) ,(@int_2021 ,'48-PE2' ,48 ,'PE2' ,'Reduced Physical Function with Rest. Nursing'      ,'15 to 16'  ,2.554 ,2.554
 ) ,(@int_2021 ,'49-PE1' ,49 ,'PE1' ,'Reduced Physical Function with No Rest. Nursing'   ,'15 to 16'  ,2.422 ,2.422
 ) ,(@int_2021 ,'50-PD2' ,50 ,'PD2' ,'Reduced Physical Function with Rest. Nursing'      ,'11 to 14'  ,2.424 ,2.424
 ) ,(@int_2021 ,'51-PD1' ,51 ,'PD1' ,'Reduced Physical Function with No Rest. Nursing'   ,'11 to 14'  ,2.226 ,2.226
 ) ,(@int_2021 ,'52-PC2' ,52 ,'PC2' ,'Reduced Physical Function with Rest. Nursing'      ,' 6 to 10'  ,1.956 ,1.956
 ) ,(@int_2021 ,'53-PC1' ,53 ,'PC1' ,'Reduced Physical Function with No Rest. Nursing'   ,' 6 to 10'  ,1.862 ,1.862
 ) ,(@int_2021 ,'54-PB2' ,54 ,'PB2' ,'Reduced Physical Function with Rest. Nursing'      ,' 2 to  5'  ,1.598 ,1.39
 ) ,(@int_2021 ,'55-PB1' ,55 ,'PB1' ,'Reduced Physical Function with No Rest. Nursing'   ,' 2 to  5'  ,1.425 ,1.24
 ) ,(@int_2021 ,'56-PA2' ,56 ,'PA2' ,'Reduced Physical Function with Rest. Nursing'      ,' 0 to  1'  ,1.161 ,1.01
 ) ,(@int_2021 ,'57-PA1' ,57 ,'PA1' ,'Reduced Physical Function with No Rest. Nursing'   ,' 0 to  1'  ,1     ,0.87
 ) ,(@int_2021 ,'58-BC1' ,58 ,'BC1' ,'Default'                                           ,''          ,1.000 ,0.870
 )
;


If (@debugBit = 1) Print 'Step 3  Deleting work from prior run ' + convert(varchar(30), getdate(), 121);

SELECT @local_model_id_prev = model_id
FROM [dbo].[as_std_rug_model]
WHERE std_assess_id    = @std_assess_id
  AND short_desc       = @param_short_new
  AND rug_version      = @Param_rug_version
  AND rug_model_num    = @param_rug_model_num
  AND effective_date   = @param_effective_date_new
;
IF (@local_model_id_prev is not null)
BEGIN
        DELETE code
        FROM       [dbo].[as_std_rug_cat]   cat
        INNER JOIN [dbo].[as_std_rug_code]  code   ON code.cat_id = cat.cat_id
        WHERE cat.model_id = @local_model_id_prev
        ;

        DELETE FROM [dbo].[as_std_rug_cat]
        WHERE model_id = @local_model_id_prev
        ;

        DELETE FROM [dbo].[as_std_rug_model]
        WHERE model_id = @local_model_id_prev
        ;
end

If (@debugBit = 1) Print 'Step 4 Gather info about mode, rug, and code. ' + convert(varchar(30), getdate(), 121);

SELECT @local_model_id_old = model_id
FROM [dbo].[as_std_rug_model]
WHERE std_assess_id = @std_assess_id
  AND short_desc    = @param_short_old     
  AND rug_version   = @Param_rug_version    
  AND rug_model_num = @param_rug_model_num  
  and (ineffective_date is null or ineffective_date = @param_ineffective_date_old)  -- note that if this is a rerun, then ineffective data will not be null
;                                                 
                                                  
SELECT @local_cat_count = COUNT(*)                      
FROM [dbo].[as_std_rug_cat]                       
WHERE model_id = @local_model_id_old               
;

SELECT @local_code_count = COUNT(*)
FROM       [dbo].[as_std_rug_cat]  cat
INNER JOIN [dbo].[as_std_rug_code] code     ON code.cat_id = cat.cat_id
WHERE cat.model_id = @local_model_id_old              
;

If (@debugBit = 1) Print 'Step 5   [get_next_primary_key] ' + convert(varchar(30), getdate(), 121);

EXEC [dbo].[get_next_primary_key] 'as_std_rug_model', 'model_id',    @local_model_id_new     OUTPUT, 1;
EXEC [dbo].[get_next_primary_key] 'as_std_rug_cat',   'cat_id',      @local_cat_id_new       OUTPUT, @local_cat_count;
EXEC [dbo].[get_next_primary_key] 'as_std_rug_code',  'rug_code_id', @local_rug_code_id_new  OUTPUT, @local_code_count;

BEGIN TRY
    BEGIN TRANSACTION;

    If (@debugBit = 1) Print 'Step 6   as_std_rug_model ' + convert(varchar(30), getdate(), 121);
    INSERT INTO [dbo].[as_std_rug_model] (
           model_id                     ,deleted                      ,short_desc                   ,long_desc                    ,std_assess_id      
          ,rug_version                  ,rug_logic_code               ,rug_model_num                ,effective_date               ,ineffective_date   
    )
    SELECT
           @local_model_id_new          ,'N'                          ,@param_short_new             ,@Param_long_desc             ,std_assess_id             
          ,rug_version                  ,@param_rug_logic_code        ,rug_model_num                ,@param_effective_date_new    ,@param_ineffective_date_new
    FROM [dbo].[as_std_rug_model]
    WHERE model_id = @local_model_id_old               
    ;

    If (@debugBit = 1) Print 'Step 7   as_std_rug_cat ' + convert(varchar(30), getdate(), 121);
    INSERT INTO [dbo].[as_std_rug_cat] (
        cat_id             
       ,deleted            ,description        ,model_id           
       ,cmi_hi             ,sequence           ,revision_date      
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY sequence) + @local_cat_id_new - 1
       ,deleted            ,description        ,@local_model_id_new          
       ,cmi_hi             ,sequence           ,@param_effective_date_new      
    FROM [dbo].[as_std_rug_cat]
    WHERE model_id = @local_model_id_old     
    ORDER BY sequence
    ;

    If (@debugBit = 1) Print 'Step 8   as_std_rug_code ' + convert(varchar(30), getdate(), 121);
    INSERT INTO [dbo].[as_std_rug_code] (
       rug_code_id        
      ,deleted            ,code               ,description        ,cmi
      ,weight             ,adl_score          ,score2             ,score3             
      ,cat_id             ,revision_date      ,sequence
    )
    SELECT
       ROW_NUMBER() OVER (ORDER BY code.sequence) + @local_rug_code_id_new - 1
      ,code.deleted       ,code.code          ,code.description   ,COALESCE(up.BABB_087, 0.0) 
      ,code.weight        ,code.adl_score     ,code.score2        ,code.score3
      ,catNew.cat_id      ,@param_effective_date_new    ,code.sequence
    FROM       [dbo].[as_std_rug_code] code
    INNER JOIN [dbo].[as_std_rug_cat]  catOld           ON  catOld.model_id = @local_model_id_old     AND catOld.cat_id    = code.cat_id       
    INNER JOIN [dbo].[as_std_rug_cat]  catNew           ON  catNew.model_id = @local_model_id_new     AND catNew.sequence  = catOld.sequence
    left  join @tempRug                up               on  up.RUGCode = code.code  and up.effective = @int_2021
    ;

    If (@debugBit = 1) Print 'Step 9   update old ' + convert(varchar(30), getdate(), 121);
    update [dbo].[as_std_rug_model] set
      ineffective_date = @param_ineffective_date_old
    WHERE model_id = @local_model_id_old               
    ;

    If (@debugBit = 1) Print 'Step 10   COMMIT TRANSACTION ' + convert(varchar(30), getdate(), 121);
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF (@@TRANCOUNT > 0)
        ROLLBACK TRANSACTION;
END CATCH;


GO

print 'A_PreUpload/US_Only/CORE-98306 DML Washington-CMI-Update.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/US_Only/CORE-98306 DML Washington-CMI-Update.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/US_Only/CORE-98690-DML-ClientDB_Update_PDPM_Calc_V20002.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

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
-- Jira #:               CORE-98690
--
-- Written By:           Brian Young
-- Reviewed By:          
--
-- Script Type:          DML
-- Target DB Type:       ClientDB
-- Target ENVIRONMENT:   US Only
-- Tested:               pccsql-use2-nprd-dvsh-cli0003.bbd2b72cba43.database.windows.net
-- Re-Runable:           YES
--
--
-- Description of Script Function: Update PDPM Calc Version code to 1.0008 if 
--     ARD On/After Oct. 1, 2020
--									
-- =================================================================================
DECLARE   @revisionDate datetime = getdate()
		, @revisionBy varchar(10) = 'CORE-98690'
;
DECLARE @QuestionResponse as TABLE
(
   ItemValue varchar(2000) not null
);

IF EXISTS (Select 1 FROM information_schema.columns WHERE table_name = 'as_response')
BEGIN
	INSERT INTO @QuestionResponse (ItemValue)
	VALUES ('2.0000'), 
		   ('2.0001');


	UPDATE r
	  SET r.item_value = '2.0002'
	    , r.revision_date = @revisionDate
		, r.revision_by = @revisionBy
	FROM as_assessment a 
	JOIN as_response r on a.assess_id=r.assess_id and r.question_key='Z0100B' 
	JOIN @QuestionResponse t on r.item_value=t.ItemValue
	WHERE a.std_assess_id = 11
	  and a.assess_date > '2021-09-30'
	  and a.status in ('Export Ready','In Progress')  
	;
END

GO

print 'A_PreUpload/US_Only/CORE-98690-DML-ClientDB_Update_PDPM_Calc_V20002.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/US_Only/CORE-98690-DML-ClientDB_Update_PDPM_Calc_V20002.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

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
values ('4.4.9_A', 'upload_history')


GO

print '..\Update db version.sql --****SCRIPT DONE****'

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking (script,timestamp,upload) values ('UPLOAD END',getdate(),'4.4.9_06_CLIENT_A_PreUpload_US.sql')