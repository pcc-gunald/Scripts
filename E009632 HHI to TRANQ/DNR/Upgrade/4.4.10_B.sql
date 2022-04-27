SET NOCOUNT ON
GO

SET DEADLOCK_PRIORITY HIGH
GO


insert into upload_tracking (script, timestamp, upload) values ('UPLOAD_START',getdate(),'4.4.10_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-100175-add-view_sc_user_resident_access.sql',getdate(),'4.4.10_06_CLIENT_B_Upload_US.sql')

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
-- CORE-100175:      Create a View to be used to getting users' resident access
--
-- Written By:       Jonathan Tecson
-- Reviewed By:
-- Script Type:      DDL
-- Target DB Type:   Client
-- Target Database:  Both
--
-- Re-Runnable:      YES
--
-- Staging Recommendations/Warnings: None
--

if exists (select 1 from sysobjects where name = 'view_sc_user_resident_access')
  drop view dbo.view_sc_user_resident_access
GO

create view [dbo].[view_sc_user_resident_access] as

with temp AS
(
SELECT	su.userid,
		su.long_username AS [name],
		caseManager.access_level AS caseManagerAccess,
		caseProvider.access_level AS caseProviderAccess,
		ext_fac_id AS externalFacilityAccess,
		staff_id AS staffAccess,
		su.admin_user_type, suf.facility_id AS facilityId,
		1 AS hasResidentRestrictionAccess,
		STUFF((SELECT ',' + iam_role_name FROM dbo.sec_user_iam_roles sur WHERE sur.userid = su.userid FOR XML PATH('')), 1, 1, '') AS roles
FROM dbo.sec_user su
LEFT JOIN (select max(rf.access_level) AS access_level, ur.userid
           from dbo.sec_role_function rf
           inner join dbo.sec_user_role ur on ur.role_id = rf.role_id
           where rf.func_id in ('1015.1', '5005.1')
		   group by ur.userid
		  ) caseManager ON caseManager.userid = su.userid
LEFT JOIN (select max(rf.access_level) AS access_level, ur.userid
           from dbo.sec_role_function rf
           inner join dbo.sec_user_role ur on ur.role_id = rf.role_id
           where rf.func_id in ('1015.2', '5005.2')
		   group by ur.userid
		   ) caseProvider ON caseProvider.userid = su.userid
LEFT JOIN dbo.sec_user_facility suf ON suf.userid = su.userid AND su.admin_user_type IS NULL
INNER JOIN dbo.sec_user_iam_roles sur ON sur.userid = su.userid
WHERE ( su.VALID_UNTIL_DATE IS NULL OR su.VALID_UNTIL_DATE >= CONVERT (date, GETDATE()) )
AND su.[enabled] = 'Y' AND su.api_only_user = 'N'
GROUP BY su.userid, su.long_username,
ext_fac_id, staff_id, caseManager.access_level, caseProvider.access_level,
su.admin_user_type, suf.facility_id
)
--1. Case Manager Access
SELECT usr.userid, usr.name, usr.facilityId, clients.client_id AS clientId, usr.hasResidentRestrictionAccess, usr.roles
FROM dbo.clients
INNER JOIN temp usr ON usr.userid = clients.case_manager_id
WHERE usr.caseManagerAccess > 0 AND clients.fac_id <> 9001 AND clients.deleted = 'N' AND clients.fac_id = usr.facilityId
UNION
--2. Case Provider Access
SELECT usr.userid, usr.name, usr.facilityId, clients.client_id AS clientId, usr.hasResidentRestrictionAccess, usr.roles
FROM dbo.client_staff
INNER JOIN dbo.clients ON clients.client_id = client_staff.client_id AND clients.deleted = 'N'
INNER JOIN dbo.staff ON staff.contact_id = client_staff.staff_id
AND staff.fac_id = (
	CASE
		WHEN dbo.fn_medprof_isMedProfConfigurationEnabled() = 1
		THEN -1
		ELSE client_staff.fac_id
	END
	) AND staff.deleted = 'N'
INNER JOIN temp usr ON usr.facilityId = clients.fac_id
WHERE usr.caseProviderAccess > 0 AND client_staff.deleted = 'N' AND staff.on_staff = 'N' AND staff.userid = usr.userid
AND clients.fac_id <> 9001
UNION
--3. External Facility Access
SELECT usr.userid, usr.name, usr.facilityId, clients.client_id AS clientId, usr.hasResidentRestrictionAccess, usr.roles
FROM dbo.client_ext_facilities extFac
INNER JOIN dbo.clients ON clients.client_id = extFac.client_id and clients.deleted = 'N'
INNER JOIN temp usr ON usr.facilityId = clients.fac_id
WHERE usr.externalFacilityAccess > 0 AND extFac.ext_fac_id = usr.externalFacilityAccess AND clients.fac_id <> 9001
UNION
--4. Staff Access
SELECT usr.userid, usr.name, usr.facilityId, clients.client_id AS clientId, usr.hasResidentRestrictionAccess, usr.roles
FROM dbo.client_staff
INNER JOIN dbo.clients ON clients.client_id = client_staff.client_id AND clients.deleted = 'N'
INNER JOIN temp usr ON usr.facilityId = client_staff.fac_id
WHERE client_staff.staff_id = usr.staffAccess AND client_staff.deleted = 'N' AND client_staff.fac_id <> 9001
--5. Users with specific facility access
UNION
SELECT usr.userid, usr.name, usr.facilityId, clients.client_id AS clientId, usr.hasResidentRestrictionAccess, usr.roles
FROM dbo.clients
INNER JOIN temp usr ON usr.facilityId = clients.fac_id
	AND ISNULL(usr.caseManagerAccess, 0) =  0 AND ISNULL(usr.caseProviderAccess, 0) = 0
	AND ISNULL(usr.externalFacilityAccess, -1) < 0 AND ISNULL(usr.staffAccess, 0) = 0
WHERE clients.deleted='N'

GO




GO

print 'B_Upload/01_DDL/CORE-100175-add-view_sc_user_resident_access.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-100175-add-view_sc_user_resident_access.sql',getdate(),'4.4.10_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-100195 - DDL - Create claim_generation_error table.sql',getdate(),'4.4.10_06_CLIENT_B_Upload_US.sql')

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
-- Jira #:               CORE-100195 Create ar_claim_generation_error table
--
-- Written By:           Jimmy Zhang
--
-- Script Type:          DDL
-- Target DB Type:       CLIENT
-- Target ENVIRONMENT:   BOTH
--
-- Re-Runable:           YES
--
-- Where tested:	DEV_US_CodeGames_agrd_1638162607 in pccsql-use2-nprd-dvsh-cli0004.bbd2b72cba43.database.windows.net
--
-- Staging Recommendations/Warnings: None
--
-- Description of Script Function: Create ar_claim_generation_error table
--
-- Special Instruction:
-- =================================================================================
IF NOT EXISTS (SELECT 1 FROM information_schema.tables
               WHERE table_name = 'ar_claim_generation_error'
               AND table_schema = 'dbo')
BEGIN
    create table [dbo].[ar_claim_generation_error]
    (
        process_uuid uniqueidentifier not null,		--:PHI=N:Desc: claim generation process uuid
        fac_id int not null,				--:PHI=N:Desc: facility id
        payer_ids varchar(512) not null,		--:PHI=N:Desc: comma seporated payer ids
        no_of_clients int not null,			--:PHI=N:Desc: no of clients that are faild during claim generation
        created_by varchar(60) not null,		--:PHI=N:Desc: user name that creates the error record
        created_date datetime not null			--:PHI=N:Desc: date and time this error is created
        CONSTRAINT [ar_claim_generation_error__processUuid_PK_CL_IX] PRIMARY KEY ([process_uuid])
    )
END

IF NOT  EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_name= 'ar_claim_generation_error__facId_FK')
BEGIN
	ALTER TABLE ar_claim_generation_error
	ADD CONSTRAINT ar_claim_generation_error__facId_FK
	FOREIGN KEY (fac_id) REFERENCES facility(fac_id)
	ON DELETE CASCADE
END
GO



GO

print 'B_Upload/01_DDL/CORE-100195 - DDL - Create claim_generation_error table.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-100195 - DDL - Create claim_generation_error table.sql',getdate(),'4.4.10_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-99198-update-facility_medical_attestation-add-mandate-qty-disp-ctrl-medication.sql',getdate(),'4.4.10_06_CLIENT_B_Upload_US.sql')

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
--  Issue:			  CORE-99198
--  Written By:		  Jarek Zawojski
--  Script Type:      DDL
--  Target DB Type:   Client
--  Target Database:  BOTH
--  Re-Runable:       Yes
--  Description :     Update facility_medical_attestation table,add new column mandate_qty_disp_ctrl_medication
--                    update trigger to prevent updates to new column
--=============================================================================

if not exists(select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME='facility_medical_attestation' and COLUMN_NAME='mandate_qty_disp_ctrl_medication')
begin
ALTER TABLE facility_medical_attestation
    ADD mandate_qty_disp_ctrl_medication BIT
    CONSTRAINT [facility_medical_attestation__mandateQtyDispCtrlMedication_DFLT] DEFAULT (0) NOT NULL; --:PHI=N:Desc: mandate quantity and dispense setting
end
GO

--default constraint was added without a name before - rename it if exists
begin
    declare @Command  varchar(1000)
    declare @constrintName varchar(1000)

    if exists(
            SELECT 1
            FROM   sys.objects obj_table
                       JOIN sys.objects obj_Constraint
                            ON obj_table.object_id = obj_Constraint.parent_object_id
                       JOIN sys.sysconstraints constraints
                            ON constraints.constid = obj_Constraint.object_id
                       JOIN sys.columns columns
                            ON columns.object_id = obj_table.object_id
                                AND columns.column_id = constraints.colid
            WHERE obj_table.NAME='facility_medical_attestation'
              and columns.NAME = 'mandate_qty_disp_ctrl_medication'
              and obj_Constraint.NAME != 'facility_medical_attestation__mandateQtyDispCtrlMedication_DFLT'
              and obj_Constraint.type = 'D'
        )
    begin
        SELECT @constrintName = obj_Constraint.NAME
        FROM   sys.objects obj_table
                   JOIN sys.objects obj_Constraint
                        ON obj_table.object_id = obj_Constraint.parent_object_id
                   JOIN sys.sysconstraints constraints
        ON constraints.constid = obj_Constraint.object_id
            JOIN sys.columns columns
            ON columns.object_id = obj_table.object_id
            AND columns.column_id = constraints.colid
        WHERE obj_table.NAME='facility_medical_attestation'
          and columns.NAME = 'mandate_qty_disp_ctrl_medication'
          and obj_Constraint.NAME != 'facility_medical_attestation__mandateQtyDispCtrlMedication_DFLT'
          and obj_Constraint.type = 'D'

            --print 'Constraint name  = ' + @constrintName

        set @Command = 'ALTER TABLE facility_medical_attestation drop constraint ' + @constrintName
            --print @Command
            execute (@Command)

        --add constraint with new name
        ALTER TABLE facility_medical_attestation ADD CONSTRAINT facility_medical_attestation__mandateQtyDispCtrlMedication_DFLT DEFAULT(0) FOR mandate_qty_disp_ctrl_medication
    end
end


GO

print 'B_Upload/01_DDL/CORE-99198-update-facility_medical_attestation-add-mandate-qty-disp-ctrl-medication.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-99198-update-facility_medical_attestation-add-mandate-qty-disp-ctrl-medication.sql',getdate(),'4.4.10_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-99218-add-med-mgmt-collumns-to-pho_phys_order_esignature_order_snapshot_CDN.sql',getdate(),'4.4.10_06_CLIENT_B_Upload_US.sql')

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
--  Issue:			  CORE-99218, CORE-99067
--  Written By:		  Jarek Zawojski
--  Script Type:      DDL
--  Target DB Type:   Client
--  Target Database:  BOTH
--  Re-Runable:       Yes
--  Description :     Update pho_phys_order_esignature_order_snapshot_CDN table to add new columns:
--                     - quantity_prescribed
--                     - unit_of_measure
--                     - dispense_interval
--                     - total_authorized_quantity
--=============================================================================

if not exists(select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME='pho_phys_order_esignature_order_snapshot_CDN' and COLUMN_NAME='quantity_prescribed')
begin
ALTER TABLE pho_phys_order_esignature_order_snapshot_CDN
    ADD quantity_prescribed VARCHAR(31) NULL, --:PHI=N:Desc: quantity prescribed
        unit_of_measure VARCHAR(20) NULL, --:PHI=N:Desc: unit of measure
        dispense_interval INT NULL,--:PHI=N:Desc: drug dispense interval
        total_authorized_quantity VARCHAR(31) NULL; --:PHI=N:Desc: total authorized quantity for dispensing
end

--to fix existing fields in QA
if exists(select 1 from INFORMATION_SCHEMA.COLUMNS
          where TABLE_NAME='pho_phys_order_esignature_order_snapshot_CDN'
                and COLUMN_NAME='quantity_prescribed'
                and DATA_TYPE = 'int')
begin
    ALTER TABLE dbo.pho_phys_order_esignature_order_snapshot_CDN
    ALTER COLUMN quantity_prescribed VARCHAR(31) NULL;
end

if exists(select 1 from INFORMATION_SCHEMA.COLUMNS
          where TABLE_NAME='pho_phys_order_esignature_order_snapshot_CDN'
                and COLUMN_NAME='total_authorized_quantity'
                and DATA_TYPE = 'int')
begin
    ALTER TABLE dbo.pho_phys_order_esignature_order_snapshot_CDN
    ALTER COLUMN total_authorized_quantity VARCHAR(31) NULL;
end

GO


GO

print 'B_Upload/01_DDL/CORE-99218-add-med-mgmt-collumns-to-pho_phys_order_esignature_order_snapshot_CDN.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-99218-add-med-mgmt-collumns-to-pho_phys_order_esignature_order_snapshot_CDN.sql',getdate(),'4.4.10_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-99218-add-med-mgmt-collumns-to-pho_phys_order_quantity_info.sql',getdate(),'4.4.10_06_CLIENT_B_Upload_US.sql')

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
--  Issue:			  CORE-99218
--  Written By:		  Jarek Zawojski
--  Script Type:      DDL
--  Target DB Type:   Client
--  Target Database:  BOTH
--  Re-Runable:       Yes
--  Description :     Update pho_phys_order_quantity_info table to add new columns:
--                     - dispense_interval
--                     - total_authorized_quantity
--=============================================================================

if not exists(select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME='pho_phys_order_quantity_info' and COLUMN_NAME='dispense_interval')
begin
    ALTER TABLE dbo.pho_phys_order_quantity_info
        ADD dispense_interval INT NULL, --:PHI=N:Desc: drug dispense interval
            total_authorized_quantity VARCHAR(31) NULL; --:PHI=N:Desc: total authorized quantity for dispensing
end

--to fix existing fields in QA
if exists(select 1 from INFORMATION_SCHEMA.COLUMNS
          where TABLE_NAME='pho_phys_order_quantity_info'
                and COLUMN_NAME='total_authorized_quantity'
                and DATA_TYPE = 'int')
begin
    ALTER TABLE dbo.pho_phys_order_quantity_info
    ALTER COLUMN total_authorized_quantity VARCHAR(31) NULL;
end

GO


GO

print 'B_Upload/01_DDL/CORE-99218-add-med-mgmt-collumns-to-pho_phys_order_quantity_info.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-99218-add-med-mgmt-collumns-to-pho_phys_order_quantity_info.sql',getdate(),'4.4.10_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-99962-DML-New-Security-function-review-stmt-schedule-fac-module.sql',getdate(),'4.4.10_06_CLIENT_B_Upload_US.sql')

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
-- CORE-99962
--
-- Written By:       Security Script Generator Version 1.0.1
--
-- Script Type:      DML
-- Target DB Type:   Client
-- Target Database:  Both     (NOTE TO DEVELOPERS: DO NOT CHANGE!)
--
-- Re-Runnable:      YES
--
-- Staging Recommendations/Warnings: None
--
-- Description of Script Function:
--   Insert new security functions for...
--     * 1070.04515: Review Statement Schedules
--
--   URL: http://vmusnpdvshsg01/create?scriptType=I&issueKey=CORE-99962&moduleId=1&functionUpdates%5B1%5D.funcId=1070.04515&functionUpdates%5B1%5D.parentId=1070.0&functionUpdates%5B1%5D.sequenceNo=1070.04515&functionUpdates%5B1%5D.description=Review+Statement+Schedules&functionUpdates%5B1%5D.environment=USAR&functionUpdates%5B1%5D.accessType=YN&functionUpdates%5B1%5D.accessLevel=0&functionUpdates%5B1%5D.accessCopyFromFuncId=&functionUpdates%5B1%5D.accessCopyFromDefault=0&functionUpdates%5B1%5D.systemRoleAccess%5B%271%27%5D=-999&functionUpdates%5B1%5D.systemRoleAccess%5B%273%27%5D=-999&functionUpdates%5B1%5D.systemRoleAccess%5B%275%27%5D=-999&functionUpdates%5B1%5D.systemRoleAccess%5B%271515%27%5D=-999&functionUpdates%5B1%5D.systemRoleAccess%5B%271000%27%5D=-999&functionUpdates%5B1%5D.systemRoleAcces
--        s%5B%271714%27%5D=-999&functionUpdates%5B1%5D.systemRoleAccess%5B%271715%27%5D=-999&functionUpdates%5B1%5D.systemRoleAccess%5B%271795%27%5D=-999&functionUpdates%5B1%5D.systemRoleAccess%5B%271807%27%5D=-999
--
-- Special Instruction: Can be run prior to upload of code
--
--=======================================================================================================================
-- CONSTANTS
DECLARE @NOW datetime
SET @NOW = GETDATE()
-- SPECS
DECLARE @moduleId int, @createdBy varchar(70)
-- TEMP TABLE
DECLARE @sec_function__ins TABLE (func_id varchar(10), deleted char(1), created_by varchar(60), created_date datetime, module_id int, [type] varchar(8), description varchar(70), parent_function varchar(1), sequence_no float, facility_type varchar(5)
    PRIMARY KEY (func_id))
DECLARE @sec_role_function__ins TABLE (role_id int, func_id varchar(10), created_by varchar(60), created_date datetime, revision_by varchar(60), revision_date datetime, access_level int,
    PRIMARY KEY (role_id, func_id))
SET @moduleId = 1
SET @createdBy = 'CORE-99962'
--========================================================================================================
-- 1070.04515: Review Statement Schedules
--========================================================================================================
-- (1) Prepare @sec_function__ins ===========================================================
INSERT INTO @sec_function__ins (func_id, deleted, created_by, created_date, module_id, [type], description, parent_function, sequence_no, facility_type)
    VALUES ('1070.04515', 'N', @createdBy, @NOW, @moduleId, 'YN', 'Review Statement Schedules', 'N', 1070.04515, 'USAR')
-- (2) Prepare @sec_role_function__ins ======================================================
-- (2a) Add new function to all appropriate roles ------------------------------
INSERT INTO @sec_role_function__ins (role_id, func_id, created_by, created_date, revision_by, revision_date, access_level)
    SELECT DISTINCT role_id, '1070.04515', @createdBy, @NOW, NULL, NULL, 0 FROM sec_role r
    WHERE @moduleId = 10 -- new functions in the "All" module are applicable to every role
        OR (module_id = @moduleId AND description <> 'Collections Setup (system)' AND description <> 'Collections User (system)')
        OR (module_id = 0 AND EXISTS (SELECT 1 FROM sec_role_function rf INNER JOIN sec_function f ON rf.func_id = f.func_id WHERE f.module_id = @moduleId AND rf.role_id = r.role_id))
--========================================================================================================
-- Apply changes
--========================================================================================================
BEGIN TRAN
BEGIN TRY
    DELETE FROM sec_function WHERE func_id IN ('1070.04515')
    DELETE FROM sec_role_function WHERE func_id IN ('1070.04515')
    INSERT INTO sec_function (func_id, deleted, created_by, created_date, module_id, [type], description, parent_function, sequence_no, facility_type)
        SELECT func_id, deleted, created_by, created_date, module_id, [type], description, parent_function, sequence_no, facility_type FROM @sec_function__ins
    INSERT INTO sec_role_function (role_id, func_id, created_by, created_date, revision_by, revision_date, access_level)
        SELECT role_id, func_id, created_by, created_date, revision_by, revision_date, access_level FROM @sec_role_function__ins
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN
    DECLARE @err NVARCHAR(3000)
    SET @err = 'Error creating security functions for ' + @createdBy + ': ' + ERROR_MESSAGE()
    RAISERROR(@err, 16, 1)
END CATCH
IF @@TRANCOUNT > 0
    COMMIT TRAN

GO

print 'B_Upload/02_DML/CORE-99962-DML-New-Security-function-review-stmt-schedule-fac-module.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-99962-DML-New-Security-function-review-stmt-schedule-fac-module.sql',getdate(),'4.4.10_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.10_06_CLIENT_B_Upload_US.sql')

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
values ('4.4.10_B', 'upload_history')


GO

print '..\Update db version.sql --****SCRIPT DONE****'

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.10_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking (script,timestamp,upload) values ('UPLOAD END',getdate(),'4.4.10_06_CLIENT_B_Upload_US.sql')