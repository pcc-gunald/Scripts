

SET NOCOUNT ON
GO

SET DEADLOCK_PRIORITY HIGH
GO


insert into upload_tracking (script, timestamp, upload) values ('UPLOAD_START',getdate(),'4.4.7_06_CLIENT_F_EnterpriseReporting_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('F_EnterpriseReporting_Upload/1_DDL/CORE-94734  -01- DDL - Addition of cr_client_immunization notes column to Immunization Fact tables.sql',getdate(),'4.4.7_06_CLIENT_F_EnterpriseReporting_Upload_US.sql')

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


-- ======================================================================================
-- CORE-94734 Addition of cr_client_immunization notes column to Immunization Fact tables
--
-- Written By:           Maureen Arellano 
-- Reviewed By:          
--
-- Script Type:          DDL
-- Target DB Type:       CLIENT 
-- Target ENVIRONMENT:   BOTH
--
--
-- Re-Runnable:           YES
--
-- Staging Recommendations/Warnings:
--
-- Description of Script Function:  Addition of notes column to pdl_fact_Immunization 
--				
-- Special Instruction:

-- =======================================================================================
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'reporting' AND TABLE_NAME = 'pdl_fact_Immunization')
BEGIN	
	IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'notes' AND TABLE_NAME = 'pdl_fact_Immunization' AND TABLE_SCHEMA = 'reporting')
	BEGIN
		ALTER TABLE reporting.pdl_fact_Immunization
		ADD [notes] [varchar](150) NULL				--:PHI=N:Desc: notes for immunization
	END	
END
GO

GO

print 'F_EnterpriseReporting_Upload/1_DDL/CORE-94734  -01- DDL - Addition of cr_client_immunization notes column to Immunization Fact tables.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('F_EnterpriseReporting_Upload/1_DDL/CORE-94734  -01- DDL - Addition of cr_client_immunization notes column to Immunization Fact tables.sql',getdate(),'4.4.7_06_CLIENT_F_EnterpriseReporting_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('F_EnterpriseReporting_Upload/1_DDL/CORE-94734  -02- DDL - Addition of cr_client_immunization notes column to Immunization Fact tables.sql',getdate(),'4.4.7_06_CLIENT_F_EnterpriseReporting_Upload_US.sql')

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


-- ======================================================================================
-- CORE-94734 Addition of cr_client_immunization notes column to Immunization Fact tables
--
-- Written By:           Maureen Arellano 
-- Reviewed By:          
--
-- Script Type:          DDL
-- Target DB Type:       CLIENT
-- Target ENVIRONMENT:   BOTH
--
--
-- Re-Runnable:           YES
--
-- Staging Recommendations/Warnings:  
--
-- Description of Script Function:  Addition of notes column to pdl_fact_Immunization_staging
--				
-- Special Instruction:

-- =========================================================================================
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'reporting' AND TABLE_NAME = 'pdl_fact_Immunization_staging')
BEGIN	
	IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'notes' AND TABLE_NAME = 'pdl_fact_Immunization_staging' AND TABLE_SCHEMA = 'reporting')
	BEGIN
		ALTER TABLE reporting.pdl_fact_Immunization_staging
		ADD [notes] [varchar](150) NULL				--:PHI=N:Desc: notes for immunization
	END	
END
GO

GO

print 'F_EnterpriseReporting_Upload/1_DDL/CORE-94734  -02- DDL - Addition of cr_client_immunization notes column to Immunization Fact tables.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('F_EnterpriseReporting_Upload/1_DDL/CORE-94734  -02- DDL - Addition of cr_client_immunization notes column to Immunization Fact tables.sql',getdate(),'4.4.7_06_CLIENT_F_EnterpriseReporting_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('F_EnterpriseReporting_Upload/1_DDL/CORE-94734  -03- DDL - Addition of cr_client_immunization notes column to Immunization Fact tables.sql',getdate(),'4.4.7_06_CLIENT_F_EnterpriseReporting_Upload_US.sql')

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


-- ============================================================================================================== 
-- CORE-31384:    Update Immunization fact view ldl_view_fact_Immunization with addition of new columns
--
-- Written By:			Maria Fradkin, Mike Levine
-- Reviewed By:			 
-- 
-- Script Type:         DDL 
-- Target DB Type:      Client
-- Target ENVIRONMENT:  BOTH
-- 
-- Re-Runable     : YES 
-- 
-- Description of Script :  Update ldl_view_fact_Immunization view in the logical layer on top of pdl_fact_Immunization
--  
-- Special Instruction:

-- Revision History:
-- Date					User			Description
-- 2018, October 26		Maria Fradkin	CORE-22701 Initial version
-- 2019, January 18		Mike Levine		CORE-31384 Update Immunization fact view ldl_view_fact_Immunization with addition of new columns
-- 2019, April 11		Ritch Moore		CORE-39021 Add additional columns
-- 2019, December 3		Ritch Moore		CORE-57812 Add cvx_code_id column

-- ================================================================================================================
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_SCHEMA = 'reporting' AND TABLE_NAME='ldl_view_fact_Immunization')
BEGIN
	DROP VIEW [reporting].ldl_view_fact_Immunization;
END
GO

CREATE VIEW reporting.ldl_view_fact_Immunization
AS
SELECT 	
		[std_immunization_id],
		[fac_id],
		[client_id],
		[bed_id]  as [current_bed_id],
		[immun_date_id],
		[immun_date],
		[consent_code_id],
		[consent_date],
--		[consent_date_id],
		[administered_by_id],
		[body_location_id],
		[unit_of_measure_id] ,
		[result_code_id],
		[reason_code_id] ,
		[route_of_admin_id],
		[administered_id],
		[dose_amount] ,
		[consent_by] ,
		[manufacturer_id] ,
		[expiration_date],
		[lot_number],
		[induration], 
		[step_id],
		[strikeout_date],
		[strikeout_user_id],
		[education_provided_date], 
		[education_provided_by],
		[fact_immunization_id],
		[immunization_id],
		[related_immunization_id],
		[cvx_code_id],
		[notes]
FROM [reporting].[pdl_fact_Immunization];
GO

GO

print 'F_EnterpriseReporting_Upload/1_DDL/CORE-94734  -03- DDL - Addition of cr_client_immunization notes column to Immunization Fact tables.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('F_EnterpriseReporting_Upload/1_DDL/CORE-94734  -03- DDL - Addition of cr_client_immunization notes column to Immunization Fact tables.sql',getdate(),'4.4.7_06_CLIENT_F_EnterpriseReporting_Upload_US.sql')

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.7_06_CLIENT_F_EnterpriseReporting_Upload_US.sql')

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
values ('4.4.7_F', 'upload_history')


GO

print '..\Update db version.sql --****SCRIPT DONE****'

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.7_06_CLIENT_F_EnterpriseReporting_Upload_US.sql')

GO

insert into upload_tracking (script,timestamp,upload) values ('UPLOAD END',getdate(),'4.4.7_06_CLIENT_F_EnterpriseReporting_Upload_US.sql')