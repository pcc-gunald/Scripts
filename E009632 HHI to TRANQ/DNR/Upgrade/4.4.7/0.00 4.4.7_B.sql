

SET NOCOUNT ON
GO

SET DEADLOCK_PRIORITY HIGH
GO


insert into upload_tracking (script, timestamp, upload) values ('UPLOAD_START',getdate(),'4.4.7_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-93852-DDL- Adding_a_column_to_the_table__prp_chart_generated_log.sql',getdate(),'4.4.7_06_CLIENT_B_Upload_US.sql')

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


-- CORE-93852	
-- Written By:          Yevgen Voroshylov
-- Reviewed By:
--
-- Script Type:          
-- Target DB Type:       CLIENT
-- Target ENVIRONMENT:   BOTH
--
--
-- Re-Runnable:          YES
--
-- Where tested:          local docker environment, a client db
--
-- =================================================================================

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES
           WHERE TABLE_NAME='prp_chart_generated_log')
BEGIN

	IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
		WHERE COLUMN_NAME='user_facility_country'
			AND TABLE_NAME='prp_chart_generated_log')

				BEGIN							   

					ALTER TABLE prp_chart_generated_log
					ADD user_facility_country varchar(10) NULL --:PHI=N:Desc: country of the base facility for the user who runs the clinical chart report
				END
END




GO

print 'B_Upload/01_DDL/CORE-93852-DDL- Adding_a_column_to_the_table__prp_chart_generated_log.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-93852-DDL- Adding_a_column_to_the_table__prp_chart_generated_log.sql',getdate(),'4.4.7_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-94012 Add rescreened_at timestamp.sql',getdate(),'4.4.7_06_CLIENT_B_Upload_US.sql')

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
--  Jira #: CORE-94012
--
--  Written By: Rhys Thomas
--  Reviewed By:
--
--  Script Type: DDL
--  Target DB Type: CLIENT
--  Target ENVIRONMENT: BOTH
--
--  Re-Runable: YES
--
--  Description of Script Function:
--  add a msc_rescreening_time_utc DATETIME column required for the  pho_phys_order_dose_check_warning table
--  allows message to be null so that msc_rescreening_time_utc may still be set
--  Special Instruction: None
-- =========================================================================================================================

-- changes to the [pho_phys_order_dose_check_warning] table

-- IF NOT EXISTS (
-- 		SELECT 1
-- 		FROM INFORMATION_SCHEMA.COLUMNS
-- 		WHERE TABLE_NAME = 'pho_phys_order_dose_check_warning'
-- 			AND COLUMN_NAME = 'msc_rescreening_time_utc'
-- 		)

BEGIN
ALTER TABLE [dbo].[pho_phys_order_dose_check_warning]
    ADD msc_rescreening_time_utc DATETIME --:PHI=N:Desc: Timestamp of when a DIB4 order was re-screened using new MSC API. Warnings created by MSC API will not need this timestamp

ALTER TABLE [dbo].[pho_phys_order_dose_check_warning] ALTER COLUMN message VARCHAR(4000) NULL
END



GO

GO

print 'B_Upload/01_DDL/CORE-94012 Add rescreened_at timestamp.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-94012 Add rescreened_at timestamp.sql',getdate(),'4.4.7_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-95216- DDL- Adding columns to the table  azure_data_archive_pipeline_controller.sql',getdate(),'4.4.7_06_CLIENT_B_Upload_US.sql')

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


-- CORE-95216	
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
--, inserting
--As part of the pho_Schedule_details acrhiving process adding columns 
--
-- =================================================================================

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES
           WHERE TABLE_NAME='azure_data_Archive_pipeline_controller')
BEGIN

				               IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
							   WHERE COLUMN_NAME='is_external_source_exists'
							   AND TABLE_NAME='azure_data_Archive_pipeline_controller')

							   BEGIN							   

							   ALTER TABLE azure_data_Archive_pipeline_controller
							   ADD is_external_source_exists BIT --- PHI:N Desc- Internal to the archiving for the external source

							   END

							

				               IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
							   WHERE COLUMN_NAME='is_view_exists'
							   AND TABLE_NAME='azure_data_Archive_pipeline_controller')

							   BEGIN
				   
				   	  
							   ALTER TABLE azure_data_Archive_pipeline_controller
							   ADD is_view_exists BIT --- PHI:N Desc- Internal to the archiving for checking the view


							   END

							   
				               IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
							   WHERE COLUMN_NAME='view_name'
							   AND TABLE_NAME='azure_data_Archive_pipeline_controller')

							   BEGIN
				   
				   	  
							   ALTER TABLE azure_data_Archive_pipeline_controller
							   ADD view_name VARCHAR(250) --- PHI:N Desc- Internal to the archiving for existing view name


							   END

							   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
							   WHERE COLUMN_NAME='view_columns'
							   AND TABLE_NAME='azure_data_Archive_pipeline_controller')

							   BEGIN
				   
				   	  
							   ALTER TABLE azure_data_Archive_pipeline_controller
							   ADD view_columns VARCHAR(3000) --- PHI:N Desc- Internal to the archiving for existing view name


							   END

			              


END




GO

print 'B_Upload/01_DDL/CORE-95216- DDL- Adding columns to the table  azure_data_archive_pipeline_controller.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-95216- DDL- Adding columns to the table  azure_data_archive_pipeline_controller.sql',getdate(),'4.4.7_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-95428-DDL-rename_msc_rescreening_time_column.sql',getdate(),'4.4.7_06_CLIENT_B_Upload_US.sql')

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


/*
==============================================================================
CORE-95428

Written By:       Patrick Campbell

Script Type:      DDL
Target DB Type:   Client
Target Database:  BOTH
Re-Runnable:      YES

Description :     Renaming msc_rescreening_time_utc to msc_rescreening_time
==============================================================================
*/


IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name='pho_phys_order_dose_check_warning' AND column_name = 'msc_rescreening_time_utc')
BEGIN
    EXEC sp_rename 'dbo.pho_phys_order_dose_check_warning.msc_rescreening_time_utc', 'msc_rescreening_time', 'COLUMN'
END

GO

print 'B_Upload/01_DDL/CORE-95428-DDL-rename_msc_rescreening_time_column.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-95428-DDL-rename_msc_rescreening_time_column.sql',getdate(),'4.4.7_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-95609- DDL - Create the new table for the pipeline schedule.sql',getdate(),'4.4.7_06_CLIENT_B_Upload_US.sql')

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





-- CORE-95609	
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

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='azure_data_archive_pipeline_adf_schedule')

BEGIN

CREATE TABLE azure_data_archive_pipeline_adf_schedule --:PHI=N:Desc:For storing the schedule information of the archival process.
(
schedule_id SMALLINT IDENTITY(1,1) NOT NULL,--:PHI=N:Desc:used as unique incremental id
[description] VARCHAR(50) NOT NULL,--:PHI=N:Desc:description of the schedule
days_schedule SMALLINT NOT NULL,--:PHI=N:Desc:days for the schedule
is_active BIT NOT NULL--:PHI=N:Desc:whether the schedule active is not

  CONSTRAINT [azure_data_archive_pipeline_adf_schedule_scheduleId_PK_CL_IX] PRIMARY KEY CLUSTERED 
(
   [schedule_id] ASC
),

)
ALTER TABLE [dbo].[azure_data_archive_pipeline_adf_schedule]   ADD  CONSTRAINT [azure_data_archive_pipeline_adf_schedule__isActive_DFLT] DEFAULT(0) FOR is_active

END


GO

print 'B_Upload/01_DDL/CORE-95609- DDL - Create the new table for the pipeline schedule.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-95609- DDL - Create the new table for the pipeline schedule.sql',getdate(),'4.4.7_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-89650- DML- Insert data into country_dst_dates table.sql',getdate(),'4.4.7_06_CLIENT_B_Upload_US.sql')

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
-- Jira #:               CORE-89650
--
-- Written By:           Rajiv Roy

-- Script Type:          DML
-- Target DB Type:       CLIENT
-- Target ENVIRONMENT:   BOTH
--
--
-- Re-Runable:           YES
--
-- Where tested:         
--
-- Staging Recommendations/Warnings:
--
-- Description of Script Function:
-- Insert data into country_dst_dates table
--
-- Special Instruction:
--
-- =================================================================================

DECLARE @country_id INT

-- Server time/Canada
SET @country_id = 101
IF EXISTS (SELECT 1 FROM common_code WHERE item_id = @country_id and item_code = 'cntry')
BEGIN
	IF NOT EXISTS (SELECT 1 FROM country_dst_dates WHERE country_id = @country_id and year = 2017)
	BEGIN
		INSERT INTO country_dst_dates VALUES (@country_id,2017,'2017-03-12 02:00:00','2017-11-05 02:00:00');
	END
	IF NOT EXISTS (SELECT 1 FROM country_dst_dates WHERE country_id = @country_id and year = 2018)
	BEGIN
		INSERT INTO country_dst_dates VALUES (@country_id,2018,'2018-03-11 02:00:00','2018-11-04 02:00:00');
	END
	IF NOT EXISTS (SELECT 1 FROM country_dst_dates WHERE country_id = @country_id and year = 2019)
	BEGIN
		INSERT INTO country_dst_dates VALUES (@country_id,2019,'2019-03-10 02:00:00','2019-11-03 02:00:00');
	END
	IF NOT EXISTS (SELECT 1 FROM country_dst_dates WHERE country_id = @country_id and year = 2020)
	BEGIN
		INSERT INTO country_dst_dates VALUES (@country_id,2020,'2020-03-08 02:00:00','2020-11-01 02:00:00');
	END
	IF NOT EXISTS (SELECT 1 FROM country_dst_dates WHERE country_id = @country_id and year = 2021)
	BEGIN
		INSERT INTO country_dst_dates VALUES (@country_id,2021,'2021-03-14 02:00:00','2021-11-07 02:00:00');
	END
	IF NOT EXISTS (SELECT 1 FROM country_dst_dates WHERE country_id = @country_id and year = 2022)
	BEGIN
		INSERT INTO country_dst_dates VALUES (@country_id,2022,'2022-03-13 02:00:00','2022-11-06 02:00:00');
	END
	IF NOT EXISTS (SELECT 1 FROM country_dst_dates WHERE country_id = @country_id and year = 2023)
	BEGIN
		INSERT INTO country_dst_dates VALUES (@country_id,2023,'2023-03-12 02:00:00','2023-11-05 02:00:00');
	END
	IF NOT EXISTS (SELECT 1 FROM country_dst_dates WHERE country_id = @country_id and year = 2024)
	BEGIN
		INSERT INTO country_dst_dates VALUES (@country_id,2024,'2024-03-10 02:00:00','2024-11-03 02:00:00');
	END
	IF NOT EXISTS (SELECT 1 FROM country_dst_dates WHERE country_id = @country_id and year = 2025)
	BEGIN
		INSERT INTO country_dst_dates VALUES (@country_id,2025,'2025-03-09 02:00:00','2025-11-02 02:00:00');
	END
	IF NOT EXISTS (SELECT 1 FROM country_dst_dates WHERE country_id = @country_id and year = 2026)
	BEGIN
		INSERT INTO country_dst_dates VALUES (@country_id,2026,'2026-03-08 02:00:00','2026-11-01 02:00:00');
	END
END

-- USA
SET @country_id = 100
IF EXISTS (SELECT 1 FROM common_code WHERE item_id = @country_id and item_code = 'cntry')
BEGIN
	IF NOT EXISTS (SELECT 1 FROM country_dst_dates WHERE country_id = @country_id and year = 2017)
	BEGIN
		INSERT INTO country_dst_dates VALUES (@country_id,2017,'2017-03-12 02:00:00','2017-11-05 02:00:00');
	END
	IF NOT EXISTS (SELECT 1 FROM country_dst_dates WHERE country_id = @country_id and year = 2018)
	BEGIN
		INSERT INTO country_dst_dates VALUES (@country_id,2018,'2018-03-11 02:00:00','2018-11-04 02:00:00');
	END
	IF NOT EXISTS (SELECT 1 FROM country_dst_dates WHERE country_id = @country_id and year = 2019)
	BEGIN
		INSERT INTO country_dst_dates VALUES (@country_id,2019,'2019-03-10 02:00:00','2019-11-03 02:00:00');
	END
	IF NOT EXISTS (SELECT 1 FROM country_dst_dates WHERE country_id = @country_id and year = 2020)
	BEGIN
		INSERT INTO country_dst_dates VALUES (@country_id,2020,'2020-03-08 02:00:00','2020-11-01 02:00:00');
	END
	IF NOT EXISTS (SELECT 1 FROM country_dst_dates WHERE country_id = @country_id and year = 2021)
	BEGIN
		INSERT INTO country_dst_dates VALUES (@country_id,2021,'2021-03-14 02:00:00','2021-11-07 02:00:00');
	END
	IF NOT EXISTS (SELECT 1 FROM country_dst_dates WHERE country_id = @country_id and year = 2022)
	BEGIN
		INSERT INTO country_dst_dates VALUES (@country_id,2022,'2022-03-13 02:00:00','2022-11-06 02:00:00');
	END
	IF NOT EXISTS (SELECT 1 FROM country_dst_dates WHERE country_id = @country_id and year = 2023)
	BEGIN
		INSERT INTO country_dst_dates VALUES (@country_id,2023,'2023-03-12 02:00:00','2023-11-05 02:00:00');
	END
	IF NOT EXISTS (SELECT 1 FROM country_dst_dates WHERE country_id = @country_id and year = 2024)
	BEGIN
		INSERT INTO country_dst_dates VALUES (@country_id,2024,'2024-03-10 02:00:00','2024-11-03 02:00:00');
	END
	IF NOT EXISTS (SELECT 1 FROM country_dst_dates WHERE country_id = @country_id and year = 2025)
	BEGIN
		INSERT INTO country_dst_dates VALUES (@country_id,2025,'2025-03-09 02:00:00','2025-11-02 02:00:00');
	END
	IF NOT EXISTS (SELECT 1 FROM country_dst_dates WHERE country_id = @country_id and year = 2026)
	BEGIN
		INSERT INTO country_dst_dates VALUES (@country_id,2026,'2026-03-08 02:00:00','2026-11-01 02:00:00');
	END
END

-- UK
SET @country_id = 5172
IF EXISTS (SELECT 1 FROM common_code WHERE item_id = @country_id and item_code = 'cntry')
	BEGIN
	IF NOT EXISTS (SELECT 1 FROM country_dst_dates WHERE country_id = @country_id and year = 2017)
	BEGIN
		INSERT INTO country_dst_dates VALUES (@country_id,2017,'2017-03-26 01:00:00','2017-10-29 02:00:00');
	END
	IF NOT EXISTS (SELECT 1 FROM country_dst_dates WHERE country_id = @country_id and year = 2018)
	BEGIN
		INSERT INTO country_dst_dates VALUES (@country_id,2018,'2018-03-25 01:00:00','2018-10-28 02:00:00');
	END
	IF NOT EXISTS (SELECT 1 FROM country_dst_dates WHERE country_id = @country_id and year = 2019)
	BEGIN
		INSERT INTO country_dst_dates VALUES (@country_id,2019,'2019-03-31 01:00:00','2019-10-27 02:00:00');
	END
	IF NOT EXISTS (SELECT 1 FROM country_dst_dates WHERE country_id = @country_id and year = 2020)
	BEGIN
		INSERT INTO country_dst_dates VALUES (@country_id,2020,'2020-03-29 01:00:00','2020-10-25 02:00:00');
	END
	IF NOT EXISTS (SELECT 1 FROM country_dst_dates WHERE country_id = @country_id and year = 2021)
	BEGIN
		INSERT INTO country_dst_dates VALUES (@country_id,2021,'2021-03-28 01:00:00','2021-10-31 02:00:00');
	END
	IF NOT EXISTS (SELECT 1 FROM country_dst_dates WHERE country_id = @country_id and year = 2022)
	BEGIN
		INSERT INTO country_dst_dates VALUES (@country_id,2022,'2022-03-27 01:00:00','2022-10-30 02:00:00');
	END
	IF NOT EXISTS (SELECT 1 FROM country_dst_dates WHERE country_id = @country_id and year = 2023)
	BEGIN
		INSERT INTO country_dst_dates VALUES (@country_id,2023,'2023-03-26 01:00:00','2023-10-29 02:00:00');
	END
	IF NOT EXISTS (SELECT 1 FROM country_dst_dates WHERE country_id = @country_id and year = 2024)
	BEGIN
		INSERT INTO country_dst_dates VALUES (@country_id,2024,'2024-03-31 01:00:00','2024-10-27 02:00:00');
	END
	IF NOT EXISTS (SELECT 1 FROM country_dst_dates WHERE country_id = @country_id and year = 2025)
	BEGIN
		INSERT INTO country_dst_dates VALUES (@country_id,2025,'2025-03-30 01:00:00','2025-10-26 02:00:00');
	END
	IF NOT EXISTS (SELECT 1 FROM country_dst_dates WHERE country_id = @country_id and year = 2026)
	BEGIN
		INSERT INTO country_dst_dates VALUES (@country_id,2026,'2026-03-29 01:00:00','2026-10-25 02:00:00');
	END
END



GO

print 'B_Upload/02_DML/CORE-89650- DML- Insert data into country_dst_dates table.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-89650- DML- Insert data into country_dst_dates table.sql',getdate(),'4.4.7_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-95216- DML- Updating the value of the column is_retrieval_exists.sql',getdate(),'4.4.7_06_CLIENT_B_Upload_US.sql')

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




-- CORE-95216	
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
--As part of the pho_Schedule_details acrhiving process updating the value of the column
--
-- =================================================================================

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME='is_view_exists'
AND TABLE_NAME='azure_data_Archive_pipeline_controller')

BEGIN						      	  

				   
UPDATE azure_data_Archive_pipeline_controller
SET  is_view_exists =1
WHERE controller_id=1

END

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME='view_name'
AND TABLE_NAME='azure_data_Archive_pipeline_controller')

BEGIN						      	  

				   
UPDATE azure_data_Archive_pipeline_controller
SET  view_name ='view_pho_schedule_details_aging'
WHERE controller_id=1

END



IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME='view_columns'
AND TABLE_NAME='azure_data_Archive_pipeline_controller')

BEGIN						      	  

				   
UPDATE azure_data_Archive_pipeline_controller
SET  view_columns =' [pho_schedule_detail_id]
					  ,[pho_schedule_id]
					  ,[created_by] COLLATE DATABASE_DEFAULT
					  ,[created_date]
					  ,[revision_by] COLLATE DATABASE_DEFAULT
					  ,[revision_date] 
					  ,[deleted] COLLATE DATABASE_DEFAULT
					  ,[deleted_by] COLLATE DATABASE_DEFAULT
					  ,[deleted_date]
					  ,[perform_by] COLLATE DATABASE_DEFAULT
					  ,[perform_date]
					  ,[chart_code] COLLATE DATABASE_DEFAULT
					  ,[strike_out_id]
					  ,[followup_result] COLLATE DATABASE_DEFAULT
					  ,[schedule_date]
					  ,[dose] COLLATE DATABASE_DEFAULT
					  ,[modified_quantity] COLLATE DATABASE_DEFAULT
					  ,[perform_initials] COLLATE DATABASE_DEFAULT
					  ,[followup_by] COLLATE DATABASE_DEFAULT
					  ,[followup_date]
					  ,[followup_initials] COLLATE DATABASE_DEFAULT
					  ,[followup_pn_id]
					  ,[schedule_date_end]
					  ,[detail_supply_id]
					  ,[effective_date]
					  ,[followup_effective_date] '
WHERE controller_id=1

END



GO

print 'B_Upload/02_DML/CORE-95216- DML- Updating the value of the column is_retrieval_exists.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-95216- DML- Updating the value of the column is_retrieval_exists.sql',getdate(),'4.4.7_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-95609- DML - Add data to the table for the pipeline schedule.sql',getdate(),'4.4.7_06_CLIENT_B_Upload_US.sql')

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




-- CORE-95609	
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
--As part of the pho_Schedule_details acrhiving process adding data for the table azure_data_archive_pipeline_adf_schedule for the schedule 
--
-- =================================================================================

IF NOT EXISTS (SELECT 1 FROM azure_data_archive_pipeline_adf_schedule WHERE description='Daily' AND days_schedule=1)

BEGIN

INSERT INTO azure_data_archive_pipeline_adf_schedule
VALUES
(
'Daily',
1,
1
)
END


IF NOT EXISTS (SELECT 1 FROM azure_data_archive_pipeline_adf_schedule WHERE description='Weekly' AND days_schedule=7)

BEGIN

INSERT INTO azure_data_archive_pipeline_adf_schedule
VALUES
(
'Weekly',
7,
1
)
END

IF NOT EXISTS (SELECT 1 FROM azure_data_archive_pipeline_adf_schedule WHERE description='Every 14 Days' AND days_schedule=14)

BEGIN

INSERT INTO azure_data_archive_pipeline_adf_schedule
VALUES
(
'Every 14 Days',
14,
1
)
END

IF NOT EXISTS (SELECT 1 FROM azure_data_archive_pipeline_adf_schedule WHERE description='Bi-Monthly' AND days_schedule=15)

BEGIN

INSERT INTO azure_data_archive_pipeline_adf_schedule
VALUES
(
'Bi-Monthly',
15,
1
)
END

IF NOT EXISTS (SELECT 1 FROM azure_data_archive_pipeline_adf_schedule WHERE description='Monthly' AND days_schedule=30)

BEGIN

INSERT INTO azure_data_archive_pipeline_adf_schedule
VALUES
(
'Monthly',
30,
1
)
END

IF NOT EXISTS (SELECT 1 FROM azure_data_archive_pipeline_adf_schedule WHERE description='Fixed_Days' AND days_schedule=10)

BEGIN

INSERT INTO azure_data_archive_pipeline_adf_schedule
VALUES
(
'Fixed_Days',
10,
1
)
END


IF NOT EXISTS (SELECT 1 FROM azure_data_archive_pipeline_adf_schedule WHERE description='Fixed_Days' AND days_schedule=2)

BEGIN

INSERT INTO azure_data_archive_pipeline_adf_schedule
VALUES
(
'Fixed_Days',
2,
1
)
END



GO

print 'B_Upload/02_DML/CORE-95609- DML - Add data to the table for the pipeline schedule.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-95609- DML - Add data to the table for the pipeline schedule.sql',getdate(),'4.4.7_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.7_06_CLIENT_B_Upload_US.sql')

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
values ('4.4.7_B', 'upload_history')


GO

print '..\Update db version.sql --****SCRIPT DONE****'

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.7_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking (script,timestamp,upload) values ('UPLOAD END',getdate(),'4.4.7_06_CLIENT_B_Upload_US.sql')