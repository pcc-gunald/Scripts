SET NOCOUNT ON
GO

SET DEADLOCK_PRIORITY HIGH
GO


insert into upload_tracking (script, timestamp, upload) values ('UPLOAD_START',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-95781 - DML - Added New Report Id Enterprise Infection Prevention Report.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

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
-- Jira #:               CORE-95781
--
-- Written By:           Sujal Patel
--
-- Script Type:          DML
-- Target DB Type:       CLIENT 
-- Target ENVIRONMENT:   BOTH  
--
--
-- Re-Runable:           YES 
 
--
-- Staging Recommendations/Warnings: none
--
-- Description of Script Function: New Report Id for Enterprise Infection Prevention Report
--
-- Special Instruction: none
--
--
-- =================================================================================

IF NOT EXISTS (SELECT 1 FROM [reporting].[rpt_sub_module] WHERE sub_module_id = 14)
BEGIN
	INSERT INTO [reporting].[rpt_sub_module] 
		VALUES (14, 'Infection Control');
END

IF NOT EXISTS (SELECT 1 FROM [reporting].[rpt_module_sub_module_mapping] WHERE module_sub_module_mapping_id = 33)
BEGIN
	INSERT INTO [reporting].[rpt_module_sub_module_mapping]
		VALUES (33, 2, 14);
END

IF NOT EXISTS (SELECT 1 FROM [reporting].[rpt_report] WHERE report_id = 2300)
BEGIN
    INSERT INTO [reporting].[rpt_report](report_id, title, long_description, help_text, url)
		VALUES (2300, 'Enterprise Infection Prevention Report',
		'Lists all infection cases for all or selected ${fac_facilities}.    You can see infection cases in a CSV format by date range, infection and ${cli_client} status.',
		'',
		'/enterprisereporting/setup.xhtml?reportId=2300');
END
IF NOT EXISTS (SELECT 1 FROM [reporting].[rpt_report_module_sub_module_mapping] WHERE report_id = 2300 AND module_sub_module_mapping_id = 33)
BEGIN
	INSERT INTO [reporting].[rpt_report_module_sub_module_mapping] 
		VALUES (2300, 33);
END        
 
GO

GO

print 'A_PreUpload/CORE-95781 - DML - Added New Report Id Enterprise Infection Prevention Report.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-95781 - DML - Added New Report Id Enterprise Infection Prevention Report.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-95985 - DDL - Add is_created_from_auto_writeoff column to the ar_transactions_payment table.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

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



-- CORE-95985	
-- Written By:          Justin Pitters
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
-- Description:          Add column to ar_transactions_payment to identify which charges were created as part of the auto-writeoff process.
--
-- =================================================================================

IF EXISTS (SELECT 1 FROM information_schema.tables
           WHERE table_name = 'ar_transactions_payment'
           AND table_schema = 'dbo')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME='is_created_from_auto_writeoff' AND TABLE_NAME='ar_transactions_payment' )
    BEGIN
        ALTER TABLE ar_transactions_payment
        ADD is_created_from_auto_writeoff BIT NULL --:PHI=N:Desc:Holds the bit value determining whether the charge was created from auto-writeoffs
    END
END

GO

print 'A_PreUpload/CORE-95985 - DDL - Add is_created_from_auto_writeoff column to the ar_transactions_payment table.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-95985 - DDL - Add is_created_from_auto_writeoff column to the ar_transactions_payment table.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-96222- DDL - Adding columns to the table and adding additional condition.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

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



-- CORE-96222	
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
--Adding column to azure_data_archive_pipeline_storage_file_name for tracking delete mismatch and a condition 
--
-- =================================================================================



             
		IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME='is_unmatched_file_moved' AND TABLE_NAME='azure_data_archive_pipeline_storage_file_name' )
		BEGIN
		ALTER TABLE azure_data_archive_pipeline_storage_file_name
		ADD is_unmatched_file_moved BIT NOT NULL CONSTRAINT [azure_data_archive_pipeline_storage_file_name__isUnmatchedFileMoved_DFLT] DEFAULT(0)--:PHI=N:Desc:Holds the bit value for the mismatch file moved or not
		END

		
		IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME='is_unmatched_file_deleted' AND TABLE_NAME='azure_data_archive_pipeline_storage_file_name')
		BEGIN
		ALTER TABLE azure_data_archive_pipeline_storage_file_name
		ADD is_unmatched_file_deleted BIT NOT NULL  CONSTRAINT [azure_data_archive_pipeline_storage_file_name__isUnmatchedFileDeleted_DFLT] DEFAULT(0) --:PHI=N:Desc:Holds the bit value for delete mismatch of the file
		END

		IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME='is_file_table_deleted_rows_mismatch' AND TABLE_NAME='azure_data_archive_pipeline_storage_file_name')
		BEGIN
		ALTER TABLE azure_data_archive_pipeline_storage_file_name
		ADD is_file_table_deleted_rows_mismatch BIT NOT NULL  CONSTRAINT [azure_data_archive_pipeline_storage_file_name__isFileTableDeletedRowsMisMatch_DFLT] DEFAULT(0) --:PHI=N:Desc:Holds the bit value for  mismatch of the deleted rows from table
		END





GO

print 'A_PreUpload/CORE-96222- DDL - Adding columns to the table and adding additional condition.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-96222- DDL - Adding columns to the table and adding additional condition.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-96343 - DDL - Add updating_module column into census_item table.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

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
-- Jira #:               CORE-96343
--
-- Written By:           Sherry Lyu
-- Reviewed By:          
--
-- Script Type:          DDL
-- Target DB Type:       CLIENT
-- Target ENVIRONMENT:   BOTH
--
-- Re-Runable:           YES
-- Where tested:     	 DEV_US_Burrito_Squad_abhow & DEV_CA_Burrito_Squad_acc        

-- Staging Recommendations/Warnings:
--
-- Description of Script Function:
--   Add new column: updating_module into census_item table
-- =================================================================================

IF EXISTS (SELECT 1 FROM information_schema.tables
           WHERE table_name = 'census_item'
           AND table_schema = 'dbo')
BEGIN
      IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                     WHERE table_name = 'census_item'
                     AND column_name = 'updating_module'
                     AND table_schema = 'dbo')
      BEGIN
            ALTER TABLE dbo.census_item
            ADD updating_module TINYINT NULL--:PHI=N:Desc:To protect census record type C for updates
      END
END

GO

print 'A_PreUpload/CORE-96343 - DDL - Add updating_module column into census_item table.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-96343 - DDL - Add updating_module column into census_item table.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-96586 - DDL - Add Hospital MRN Column to ar_configuration.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

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
-- Jira #:               CORE-96586 
--                       (Parent: CORE-95938: Add an identifier mapping for Hospital MRN)
--
-- Written By:           Ian Stoodley (stoodi)
--
-- Script Type:          DDL
-- Target DB Type:       CLIENT
-- Target ENVIRONMENT:   BOTH
--
-- Re-Runable:           YES
--
-- Where tested:         Team Dev Database: DEV_US_Galaxy_abhow & DEV_CA_Evinco_acc
--
-- Staging Recommendations/Warnings: 
--
-- Description of Script Function:
--	Create new table column hospital_mrn for both ar_configuration and ar_configuration_audit
--     Allows null values
-- =================================================================================

IF EXISTS (SELECT 1 FROM information_schema.tables
	WHERE table_name = 'ar_configuration'
	AND table_schema = 'dbo')
	
	BEGIN
	
	IF NOT EXISTS (SELECT 1 FROM information_schema.columns
		WHERE table_name = 'ar_configuration'
		AND column_name = 'hospital_mrn'
		AND table_schema = 'dbo')

		BEGIN

			ALTER TABLE dbo.ar_configuration
			ADD hospital_mrn INT NULL --:PHI=N:Desc: Identifier to map Hospital MRN to General Config
			    
		END
	END

GO

IF EXISTS (SELECT 1 FROM information_schema.tables
	WHERE table_name = 'ar_configuration_audit'
	AND table_schema = 'dbo')
	
	BEGIN
	
	IF NOT EXISTS (SELECT 1 FROM information_schema.columns
		WHERE table_name = 'ar_configuration_audit'
		AND column_name = 'hospital_mrn'
		AND table_schema = 'dbo')

		BEGIN

			ALTER TABLE dbo.ar_configuration_audit
			ADD hospital_mrn INT NULL --:PHI=N:Desc: Audit for identifier to map Hospital MRN to General Config   
			    
		END
	END

GO

GO

print 'A_PreUpload/CORE-96586 - DDL - Add Hospital MRN Column to ar_configuration.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-96586 - DDL - Add Hospital MRN Column to ar_configuration.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-96590 - DDL - sproc_sprt_order_list.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

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
--
--  Script Type: user defined store procedure
--  Target DB Type:  Client
--  Target Database:  Both
--
--  Re-Runable:  Yes
--
--  Description :  Return a list of Physician Orders and other dependent data such as schedules.
--
--	Params:			
--			@facUUIdCSV
--			@clientId
--			@facilityDateTime
--			@orderCategoryIdsCSV
--			@orderStatusCSV
--			@clientStatus
--			@changesetTypesCSV
--			@changesetStatusesCSV
--			@changesetSourceId
--			@physOrderId
--			@pageSize
--			@pageNumber
--			@sortByColumn
--			@sortByOrder
--			@includeOrders
--			@includeSchedules
--			@includeChangesets
--			@debug          - Debug param, 'Y' or 'N'
--			@status_code    - SP execution flag, 0 for success.
--			@status_text    - SP error text if error occurs.
--
-- Change History:
--   Date			Jira				Team		Author				Comment
-- -----------------------------------------------------------------------------------------------------------------------------------
--   09/28/2021     SPRT-740			Coda	    Elias Ghanem  		Created.
-- =========================================================================================================================

IF EXISTS (SELECT *
               FROM
                   dbo.sysobjects
               WHERE
                   id = object_id(N'[dbo].[sproc_sprt_order_list]')
                   AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].[sproc_sprt_order_list]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sproc_sprt_order_list]			@facUUIdCSV               varchar(MAX),-- Required: CSV list of fac uuids to filter on
														@clientId				INT,-- Optional: client Id to filter on
                                                        @facilityDateTime       DATETIME,-- Required: facility date time
                                                        @orderCategoryIdsCSV	VARCHAR(100),-- Required CSV list of categegory ids to filter n
                                                        @orderStatusCSV         VARCHAR(100),-- Required: CSV list of order status ids to filter on
                                                        @clientStatus 			INT,-- Required: flag to filter on client status: -1: ALL, 0: Discharged, 1:Current(not discharged)
														@changesetTypesCSV		VARCHAR(100),-- Optional: changeset types to filter on and return
														@changesetStatusesCSV	VARCHAR(100),-- Optional: changeset statuses to filter on and return
														@changesetSourceId		INT,-- Optional: changeset sourece to filter on
                                                        @physOrderId 			INT,-- Optional: physOrderId to filter on
                                                        @pageSize 				INT,-- Required: number of phys orders per page
                                                        @pageNumber 			INT,-- Required: page number	
                                                        @sortByColumn 			VARCHAR(100),-- Required: column to sort on.
                                                        @sortByOrder  			VARCHAR(10),-- Required sort order
														@includeOrders 			INT,-- Required: flag to indicate whether orders data is returned or not: 1: orders summary, 2:orders details, 0:orders data not to be returned
														@includeSchedules 		INT,-- Required: flag to indicate whether schedules data is returned or not: 1: schedules summary, 2:schedules details, 0:schedules data not to be returned
														@includeChangesets 		INT,-- Required: flag to indicate whether changeset data is returned or not: 1: changeset summary, 2:changeset details, 0:changeset data not to be returned
														@debug              	CHAR(1)  = 'N',-- Required: flag to indicate whether to print debug data or not
														@status_code        	INT  = 0 OUT,
                                                        @status_text        	VARCHAR(3000) OUT



/***********************************************************************************************

Purpose:
This procedure provides data shown on Resident' Order Chart
This procedure does not use VIEW_PHO_PHYS_ORDER

*************************************************************************************************/

AS
BEGIN TRY
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

DECLARE @step                       			int,
		@step_label								varchar(100),
        @error_code                 			int

SET @step = 0
SET @step_label = 'Starting...'
SET @error_code = 0

/*
DECLARE @facIds TABLE
(
	fac_id int  not null
)
*/

DECLARE @orderCategoryIds TABLE
(
	order_category_id INT  NOT NULL
)

DECLARE @orderStatus TABLE
(
	status INT NOT NULL
)

DECLARE @changesetTypes TABLE
(
	changeset_type_id INT NOT NULL
)

DECLARE @changesetStatuses TABLE
(
	status_id INT NOT NULL
)

DECLARE @facInfo TABLE
(
	fac_id INT,
	fac_uuid UNIQUEIDENTIFIER,
	facility_time datetime,
	IsDischargeEnabled  BIT
)

CREATE TABLE #orders_data
  ( 
	phys_order_id             	INT, 
	fac_id                    	INT, 
	client_id                 	INT, 
	order_verified            	VARCHAR(1),
	order_status				INT,
	active_flag               	CHAR(1), 
	draft                     	BIT, 
	hold_date                 	DATETIME, 
	hold_date_end             	DATETIME, 
	end_date                  	DATETIME, 
	discontinued_date         	DATETIME, 
	order_category_id         	INT, 
	controlled_substance_code 	INT,
	
	physician_id INT,
	pharmacy_id INT,
	route_of_admin INT,
	created_by VARCHAR(60),
	created_date DATETIME,
	revision_by VARCHAR(60),
	revision_date DATETIME,
	start_date DATETIME,
	strength VARCHAR(30),
	form VARCHAR(50),
	description VARCHAR(500),
	directions VARCHAR(1000),
	related_generic VARCHAR(250),
	communication_method INT,
	prescription VARCHAR(50),
	order_date DATETIME,
	completed_date DATETIME,
	origin_id INT,
	drug_strength VARCHAR(100),
	drug_strength_uom VARCHAR(10),
	drug_name VARCHAR(500),
	order_class_id INT,
	resident_last_name varchar(50),
	resident_first_name varchar(50)	 
  ) ;

CREATE TABLE #tempresult 
  ( 
	phys_order_id             INT, 
	fac_id                    INT, 
	client_id                 INT, 
	order_verified            VARCHAR(1), 
	active_flag               CHAR(1), 
	draft                     BIT, 
	hold_date                 DATETIME, 
	hold_date_end             DATETIME, 
	end_date                  DATETIME, 
	discontinued_date         DATETIME, 
	order_category_id         INT, 
	controlled_substance_code INT,
	facility_time datetime,
	IsDischargeEnabled  BIT,
	
	physician_id INT,
	pharmacy_id INT,
	route_of_admin INT,
	created_by VARCHAR(60),
	created_date DATETIME,
	revision_by VARCHAR(60),
	revision_date DATETIME,
	start_date DATETIME,
	strength VARCHAR(30),
	form VARCHAR(50),
	description VARCHAR(500),
	directions VARCHAR(1000),
	related_generic VARCHAR(250),
	communication_method INT,
	prescription VARCHAR(50),
	order_date DATETIME,
	completed_date DATETIME,
	origin_id INT,
	drug_strength VARCHAR(100),
	drug_strength_uom VARCHAR(10),
	drug_name VARCHAR(500),
	order_class_id INT,
	resident_last_name varchar(50),
	resident_first_name varchar(50)
  ) ;
CREATE CLUSTERED INDEX _tempresult_order_id ON #tempresult( phys_order_id );  

CREATE TABLE #vpos
	(
	phys_order_id int NOT NULL,
	fac_id int NOT NULL,
	order_status int NOT NULL,
	order_relationship int NULL,
	status_reason int NULL
	)

SET @step = @step + 1	
SET @step_label = 'Parse CSV parameters into table vairables'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
	
--INSERT INTO @facIds (fac_id)
--SELECT f.fac_id FROM facility f INNER JOIN dbo.Split(@facUUIdCSV, ',') uuids ON uuids.items = f.fac_uuid
INSERT INTO @facInfo
	(fac_id,
	fac_uuid,
	facility_time,
	IsDischargeEnabled
	)
	SELECT f.fac_id,
	f.fac_uuid,
	dbo.fn_facility_getCurrentTime(f.fac_id),
	CASE WHEN cp.value = 'Y' THEN 1 ELSE 0 END
	FROM facility f
	INNER JOIN dbo.Split(@facUUIdCSV, ',') uuids ON uuids.items = f.fac_uuid
	LEFT JOIN configuration_parameter cp ON cp.fac_id = f.fac_id AND cp.name='discharge_order_enable'


INSERT INTO @orderCategoryIds (order_category_id)
SELECT * FROM dbo.Split(@orderCategoryIdsCSV, ',')	
DELETE FROM @orderCategoryIds where order_category_id=1 or order_category_id=3030

INSERT INTO @orderStatus (status)
SELECT * FROM dbo.Split(@orderStatusCSV, ',');

INSERT INTO @changesetTypes (changeset_type_id)
SELECT * FROM dbo.Split(@changesetTypesCSV, ',');

INSERT INTO @changesetStatuses (status_id)
SELECT * FROM dbo.Split(@changesetStatusesCSV, ',');

	
SET @step = @step + 1	
SET @step_label = 'Check for required parameters...'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
IF NOT EXISTS(SELECT 1 FROM @facInfo)
BEGIN
	raiserror ('facUUIdCSV is required. At least one facUUId must be provided.', 16, 1)
END
IF NOT EXISTS(SELECT 1 FROM @orderCategoryIds)
BEGIN
	raiserror ('orderCategoryIdsCSV is required. At least one orderCategoryId must be provided.', 16, 1)
END
IF NOT EXISTS(SELECT 1 FROM @orderStatus)
BEGIN
	raiserror ('orderStatusCSV is required. At least one orderStatus must be provided.', 16, 1)
END	
IF @facilityDateTime IS NULL
BEGIN
	raiserror ('facilityDateTime is required.', 16, 1)
END
IF @clientStatus IS NULL OR @clientStatus NOT IN (-1, 0, 1)
BEGIN
	raiserror ('clientStatus is required. Allowed values are: -1, 0, 1.', 16, 1)
END	
IF @pageSize IS NULL OR @pageSize <= 0
BEGIN
	raiserror ('pageSize is required and should be a positive number.', 16, 1)
END	
IF @pageNumber IS NULL or @pageNumber <= 0
BEGIN
	raiserror ('pageNumber is required and should be a positive number.', 16, 1)
END	
IF @sortByColumn IS NULL
BEGIN
	raiserror ('sortByColumn is required.', 16, 1)
END	
IF @sortByOrder IS NULL
BEGIN
	raiserror ('sortByOrder is required.', 16, 1)
END
IF (( EXISTS(SELECT 1 FROM @changesetTypes) OR EXISTS(SELECT 1 FROM @changesetStatuses)) AND
	(NOT EXISTS(SELECT 1 FROM @changesetTypes) OR NOT EXISTS(SELECT 1 FROM @changesetStatuses)))
BEGIN
	raiserror ('changesetTypesCSV and changesetStatusesCSV should be both set or both empty', 16, 1)
END
IF @changesetSourceId IS NOT NULL AND (NOT EXISTS(SELECT 1 FROM @changesetTypes) OR NOT EXISTS(SELECT 1 FROM @changesetStatuses))
BEGIN
	raiserror ('If changesetSourceId is set, both changesetTypesCSV and changesetStatusesCSV should be set', 16, 1)
END
IF @includeOrders IS NULL OR @includeOrders NOT IN (0, 1, 2)
BEGIN
	raiserror ('includeOrders is required. Allowed values are: 0, 1, 2', 16, 1)
END	
IF @includeSchedules IS NULL OR @includeSchedules NOT IN (0, 1, 2)
BEGIN
	raiserror ('includeSchedules is required. Allowed values are: 0, 1, 2', 16, 1)
END
IF @includeChangesets IS NULL OR @includeSchedules NOT IN (0, 1, 2)
BEGIN
	raiserror ('includeChangesets is required. Allowed values are: 0, 1, 2', 16, 1)
END
IF @includeChangesets IN (1, 2) AND (NOT EXISTS(SELECT 1 FROM @changesetTypes) OR NOT EXISTS(SELECT 1 FROM @changesetStatuses))
BEGIN
	raiserror ('If includeChangesets value is 1 or 2, both changesetTypesCSV and changesetStatusesCSV should be set', 16, 1)
END
		
/*
SET @step = @step + 1
SET @step_label = 'Prepare facility info'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
INSERT INTO @facInfo	
	(fac_id,
	facility_time,
	IsDischargeEnabled
	)
	SELECT f.fac_id, 
	dbo.fn_facility_getCurrentTime(f.fac_id),
	CASE WHEN cp.value = 'Y' THEN 1 ELSE 0 END
	FROM @facIds f	
	LEFT JOIN configuration_parameter cp ON cp.fac_id = f.fac_id AND cp.name='discharge_order_enable'
*/	
	
SET @step = @step + 1
SET @step_label = 'Insert into #tempresult'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text

INSERT INTO #tempresult
	( 
	phys_order_id, 
	fac_id, 
	client_id, 
	order_verified, 
	active_flag, 
	draft, 
	hold_date, 
	hold_date_end, 
	end_date, 
	discontinued_date, 
	order_category_id, 
	controlled_substance_code,
	facility_time,
	IsDischargeEnabled,
	
	physician_id,
	pharmacy_id,
	route_of_admin,
	created_by,
	created_date,
	revision_by,
	revision_date,
	start_date,
	strength,
	form,
	description,
	directions,
	related_generic,
	communication_method,
	prescription,
	order_date,
	completed_date,
	origin_id,
	drug_strength,
	drug_strength_uom,
	drug_name,
	order_class_id,
	resident_last_name,
	resident_first_name
	)
	SELECT
		o.phys_order_id, 
		o.fac_id, 
		o.client_id, 
		o.order_verified, 
		o.active_flag, 
		o.draft, 
		o.hold_date, 
		o.hold_date_end, 
		o.end_date, 
		o.discontinued_date, 
		o.order_category_id, 
		o.controlled_substance_code,
		fi.facility_time,
		fi.IsDischargeEnabled,
		o.physician_id,
		o.pharmacy_id,
		o.route_of_admin,
		o.created_by,
		o.created_date,
		o.revision_by,
		o.revision_date,
		o.start_date,
		o.strength,
		o.form,
		o.description,
		o.directions,
		o.related_generic,
		o.communication_method,
		o.prescription,
		o.order_date,
		o.completed_date,
		o.origin_id,
		o.drug_strength,
		o.drug_strength_uom,
		o.drug_name,
		o.order_class_id,
		m.last_name,
		m.first_name
	FROM pho_phys_order o
	--INNER JOIN @facIds f ON f.fac_id = o.fac_id
	INNER JOIN @facInfo fi ON fi.fac_id = o.fac_id
	INNER JOIN @orderCategoryIds cat ON cat.order_category_id = o.order_category_id
	INNER JOIN clients c ON c.client_id = o.client_id
	INNER JOIN mpi m ON m.mpi_id = c.mpi_id
	WHERE (@physOrderId IS NULL OR o.phys_order_id = @physOrderId) AND ISNULL(o.active_flag, 'Y') = 'Y'
	AND (@clientId IS NULL OR o.client_id = @clientId)
	AND (@clientStatus = -1 OR (@clientStatus = 1 AND (c.discharge_date IS NULL OR c.discharge_date > @facilityDateTime)) OR (@clientStatus = 0 AND c.discharge_date <= @facilityDateTime))

SET @step = @step + 1	
SET @step_label = 'Applying changeset filtering if needed'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text

IF EXISTS(SELECT 1 FROM @changesetTypes) OR EXISTS (SELECT 1 FROM @changesetStatuses) OR @changesetSourceId IS NOT NULL
	BEGIN
	MERGE #tempresult AS TARGET
	USING (select o.phys_order_id
	FROM #tempresult o	
	INNER JOIN pho_phys_order_changeset cs ON cs.phys_order_id = o.phys_order_id
	INNER JOIN @changesetTypes cst ON cst.changeset_type_id = cs.changeset_type_id
	INNER JOIN changeset_status csstat ON csstat.changeset_status_id = cs.current_status_id
	INNER JOIN @changesetStatuses csstats ON csstats.status_id = csstat.status_id
	WHERE @changesetSourceId IS NULL OR cs.changeset_source_id = @changesetSourceId
	) AS SOURCE
	ON (TARGET.phys_order_id = SOURCE.phys_order_id) 
	WHEN NOT MATCHED BY SOURCE 
	THEN DELETE; 
END

SET @step = @step + 1	
SET @step_label = 'Calculating orders statuses'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
insert into #vpos
exec sproc_sprt_pho_getOrderStatus  @debug,@status_code out,@status_text out


SET @step = @step + 1	
SET @step_label = 'Insert into #orders_data'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
INSERT INTO #orders_data
	( 
	phys_order_id, 
	fac_id, 
	client_id, 
	order_verified,
	order_status,
	active_flag, 
	draft, 
	hold_date, 
	hold_date_end, 
	end_date, 
	discontinued_date, 
	order_category_id, 
	controlled_substance_code,
	physician_id,
	pharmacy_id,
	route_of_admin,
	created_by,
	created_date,
	revision_by,
	revision_date,
	start_date,
	strength,
	form,
	description,
	directions,
	related_generic,
	communication_method,
	prescription,
	order_date,
	completed_date,
	origin_id,
	drug_strength,
	drug_strength_uom,
	drug_name,
	order_class_id,
	resident_last_name,
	resident_first_name
	)
	SELECT
		temp.phys_order_id, 
		temp.fac_id, 
		temp.client_id, 
		temp.order_verified,
		vpos.order_status,
		temp.active_flag, 
		temp.draft, 
		temp.hold_date, 
		temp.hold_date_end, 
		temp.end_date, 
		temp.discontinued_date, 
		temp.order_category_id, 
		temp.controlled_substance_code,
		temp.physician_id,
		temp.pharmacy_id,
		temp.route_of_admin,
		temp.created_by,
		temp.created_date,
		temp.revision_by,
		temp.revision_date,
		temp.start_date,
		temp.strength,
		temp.form,
		temp.description,
		temp.directions,
		temp.related_generic,
		temp.communication_method,
		temp.prescription,
		temp.order_date,
		temp.completed_date,
		temp.origin_id,
		temp.drug_strength,
		temp.drug_strength_uom,
		temp.drug_name,
		temp.order_class_id,
		temp.resident_last_name,
		temp.resident_first_name
	FROM @orderStatus stat
	INNER JOIN #vpos vpos ON vpos.order_status = stat.status
	INNER JOIN #tempresult temp ON temp.phys_order_id = vpos.phys_order_id	


SET @step = @step + 1
SET @step_label = 'Apply pagination'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
IF @sortByOrder='desc'
BEGIN
	;WITH TMP AS
	(
		SELECT ROW_NUMBER() OVER(ORDER BY
									 CASE
										WHEN @sortByColumn = 'fac_id' THEN CONVERT(VARCHAR(50), o.fac_id)
										WHEN @sortByColumn = 'description' THEN o.description
										WHEN @sortByColumn = 'client_id' THEN CONVERT(VARCHAR(50), o.resident_first_name)
										ELSE CONVERT(VARCHAR(50), o.phys_order_id)
									END
									DESC,
									CASE
										WHEN @sortByColumn = 'client_id' THEN CONVERT(VARCHAR(50), o.resident_last_name)
										ELSE CONVERT(VARCHAR(50), o.phys_order_id)
									END
									DESC,
									o.phys_order_id DESC) AS rn FROM #orders_data o
	)
	DELETE FROM TMP WHERE @pageSize > 0 AND (rn <= (@pageSize * (@pageNumber-1)) OR rn > (@pageSize * @pageNumber))
END
ELSE
BEGIN
	;WITH TMP AS
	(
		SELECT ROW_NUMBER() OVER(ORDER BY
										CASE
										WHEN @sortByColumn = 'fac_id' THEN CONVERT(varchar(50), o.fac_id)
										WHEN @sortByColumn = 'description' THEN o.description										
										WHEN @sortByColumn = 'client_id' THEN CONVERT(VARCHAR(50), o.resident_first_name)
										ELSE CONVERT(VARCHAR(50), o.phys_order_id)
									END
									ASC,
									CASE
										WHEN @sortByColumn = 'client_id' THEN CONVERT(VARCHAR(50), o.resident_last_name)
										ELSE CONVERT(VARCHAR(50), o.phys_order_id)
									END
									ASC,
									o.phys_order_id DESC) AS rn FROM #orders_data o
	)
	DELETE FROM TMP WHERE @pageSize > 0 AND (rn <= (@pageSize * (@pageNumber-1)) OR rn > (@pageSize * @pageNumber))

END


    /****************************************
    return final result
    ****************************************/
SET @step = @step + 1	
SET @step_label = 'Return final results...'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text

SET @step = @step + 1	
SET @step_label = 'Return orders'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
IF @includeOrders = 1
BEGIN
	SELECT
	o.phys_order_id,
	o.fac_id,
	f.fac_uuid,
	o.client_id,
	o.order_status,
	o.description,
	lib.pho_ext_lib_id,
	lib.pho_ext_lib_med_id,
	lib.pho_ext_lib_med_ddid,
	o.resident_first_name,
	o.resident_last_name	
	FROM #orders_data o
	INNER JOIN @facInfo f ON f.fac_id = o.fac_id
	LEFT JOIN pho_order_ext_lib_med_ref lib ON lib.phys_order_id = o.phys_order_id
	ORDER BY o.fac_id, o.phys_order_id ASC
END
ELSE
BEGIN
	IF @includeOrders = 2
	BEGIN
		SELECT
		o.phys_order_id,
		o.fac_id,
		f.fac_uuid,
		o.client_id,
		o.physician_id,
		c.first_name AS physician_first_name,
		c.last_name AS physician_last_name,
		c.title AS physician_title,
		o.order_category_id,
		o.communication_method,
		o.route_of_admin,
		roa.pcc_route_of_admin AS route_of_admin_desc,
		o.order_status,
		o.description,
		lib.pho_ext_lib_id,
		lib.pho_ext_lib_med_id,
		lib.pho_ext_lib_med_ddid,
		lib.pho_ext_lib_generic_id,
		lib.pho_ext_lib_generic_desc,
		lib.ext_lib_rxnorm_id,
		o.resident_first_name,
		o.resident_last_name,
		o.created_by,
		o.created_date,
		o.revision_by,
		o.revision_date
		FROM #orders_data o
		INNER JOIN @facInfo f ON f.fac_id = o.fac_id
		INNER JOIN wesreference.dbo.pho_std_route_of_admin roa ON roa.route_of_admin_id = o.route_of_admin
		LEFT JOIN contact c ON c.contact_id = o.physician_id		
		LEFT JOIN pho_order_ext_lib_med_ref lib ON lib.phys_order_id = o.phys_order_id
		ORDER BY o.fac_id, o.phys_order_id ASC
	END
	ELSE
		SELECT 'ORDER DATA NOT REQUESTED'
END

SET @step = @step + 1	
SET @step_label = 'Return schedules'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
IF @includeSchedules = 1
BEGIN
	SELECT
	o.phys_order_id,
	s.order_schedule_id,
	s.schedule_directions
	FROM #orders_data o
	INNER JOIN PHO_ORDER_SCHEDULE s ON s.phys_order_id = o.phys_order_id
	WHERE s.deleted = 'N'
	ORDER BY o.fac_id, o.phys_order_id, s.order_schedule_id
END
ELSE
BEGIN
	IF @includeSchedules = 2	
	BEGIN	
		SELECT
		os.phys_order_id,
		os.order_schedule_id,
		os.schedule_template,
		os.dose_value,
		os.dose_uom_id,
		os.alternate_dose_value,
		os.dose_low,
		os.quantity_per_dose,
		os.quantity_uom_id,
		os.need_location_of_admin,
		os.sliding_scale_id,
		os.apply_to,
		os.apply_remove_flag,
		os.std_freq_id,
		os.schedule_type,
		sched_type.description AS schedule_type_desc,
		os.repeat_week,
		os.mon,
		os.tues,
		os.wed,
		os.thurs,
		os.fri,
		os.sat,
		os.sun,
		os.xxdays,
		os.xxmonths,
		os.xxhours,
		os.date_of_month,
		os.date_start,
		os.date_stop,
		os.days_on,
		os.days_off,
		os.pho_std_time_id,
		os.related_diagnosis,
		os.indications_for_use,
		os.additional_directions,
		os.administered_by_id,
		admined_by.description AS administered_by_desc,
		os.schedule_start_date,
		os.schedule_end_date,
		os.schedule_end_date_type_id,
		sched_end_date_type.name AS schedule_end_date_type_name,
		os.schedule_duration,
		os.schedule_duration_type_id,
		sched_duration_type.name AS schedule_duration_type_name,
		os.schedule_dose_duration,
		os.prn_admin,
		os.prn_admin_value,
		os.prn_admin_units,
		os.schedule_directions,
		os.created_by,
		os.created_date,
		os.revision_by,
		os.revision_date,		
		--os.std_freq_time_label,
		--os.until_finished,
		--os.order_type_id,
		--os.extended_end_date,
		--os.extended_count,
		--os.prescriber_schedule_start_date,		
		ps.order_schedule_id,
		ps.schedule_id,
		ps.start_time,
		ps.end_time,
		ps.std_shift_id,
		ps.remove_time,
		ps.remove_duration,
		ps.nurse_action_notes
		FROM #orders_data o
		INNER JOIN PHO_ORDER_SCHEDULE os ON os.phys_order_id = o.phys_order_id
		INNER JOIN PHO_SCHEDULE ps ON ps.order_schedule_id = os.order_schedule_id
		INNER JOIN pho_schedule_type sched_type ON sched_type.schedule_type_id = os.schedule_type
		INNER JOIN pho_std_administered_by admined_by ON admined_by.administered_by_id = os.administered_by_id
		INNER JOIN pho_schedule_end_date_type sched_end_date_type ON sched_end_date_type.schedule_end_date_type_id = os.schedule_end_date_type_id
		LEFT JOIN pho_schedule_duration_type sched_duration_type ON sched_duration_type.schedule_duration_type_id = os.schedule_duration_type_id
		WHERE os.deleted = 'N' and ps.deleted = 'N'
		ORDER BY o.fac_id, o.phys_order_id, os.order_schedule_id		
	END
	ELSE
		SELECT 'SCHEDULES DATA NOT REQUESTED'
END

SET @step = @step + 1	
SET @step_label = 'Return changeset'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
IF @includeChangesets = 1
BEGIN
	SELECT
	o.phys_order_id,
	cs.phys_order_changeset_id,
	cs.changeset_type_id,
	cs.current_status_id,
	cs.changeset_source_id
	FROM #orders_data o
	INNER JOIN pho_phys_order_changeset cs ON cs.phys_order_id = o.phys_order_id
	INNER JOIN @changesetTypes cst ON cst.changeset_type_id = cs.changeset_type_id
	INNER JOIN changeset_status csstat ON csstat.changeset_status_id = cs.current_status_id
	INNER JOIN @changesetStatuses csstats ON csstats.status_id = csstat.status_id
	WHERE @changesetSourceId IS NULL OR cs.changeset_source_id = @changesetSourceId	
END
ELSE
BEGIN
	IF @includeChangesets = 2
	BEGIN
		SELECT
		o.phys_order_id,
		cs.phys_order_changeset_id,
		cs.changeset_type_id,
		cs.current_status_id,
		cs.changeset_source_id,
		cs.changeset_data,
		cs.resulting_phys_order_id,
		cs.aggregate_changeset_id,
		csstat.status_source,
		csstat.status_by,
		csstat.status_date
		FROM #orders_data o
		INNER JOIN pho_phys_order_changeset cs ON cs.phys_order_id = o.phys_order_id
		INNER JOIN @changesetTypes cst ON cst.changeset_type_id = cs.changeset_type_id
		INNER JOIN changeset_status csstat ON csstat.changeset_status_id = cs.current_status_id
		INNER JOIN @changesetStatuses csstats ON csstats.status_id = csstat.status_id
		WHERE @changesetSourceId IS NULL OR cs.changeset_source_id = @changesetSourceId	
	END
	ELSE
		SELECT 'CHANGESET DATA NOT REQUESTED'
END

    SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' Done'
    IF @debug='Y'
        PRINT @status_text
    SET @status_code = 0
    GOTO PgmSuccess
END TRY
--error trapping
BEGIN CATCH
    --SELECT @error_code = @@error, @status_text = 'Error at step:'+convert(varchar(3),@step)+', '+ERROR_MESSAGE()
	SELECT @error_code = @@error, @status_text = 'Error at step:' + convert(varchar(3),@step) + ' <' + @step_label + '>, '+ERROR_MESSAGE()

    SET @status_code = 1

    GOTO PgmAbend

END CATCH

--program success return
PgmSuccess:

IF @status_code = 0
BEGIN
    IF @debug='Y' PRINT 'Successfull execution of stored procedure'
    RETURN @status_code
END

--program failure return
PgmAbend:

--IF @debug='Y' PRINT 'Stored procedure failure in step:'+ convert(varchar(3),@step) + '   ' + convert(varchar(26),getdate())
IF @debug='Y' PRINT 'Stored procedure failure in step:'+ convert(varchar(3),@step) + ' <' + @step_label + '>   ' + convert(varchar(26),getdate())
    IF @debug='Y' PRINT 'Error code: '+convert(varchar(3),@error_code) + '; Error description:    ' +@status_text
    RETURN @status_code

GO
GRANT EXECUTE ON sproc_sprt_order_list TO public
GO


GO

print 'A_PreUpload/CORE-96590 - DDL - sproc_sprt_order_list.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-96590 - DDL - sproc_sprt_order_list.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-96784- DDL - Add column to the controller table for the checksum.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

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


-- CORE-96784	
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
--As part of the pho_Schedule_details acrhiving process making changes to the store the checksum column value file table
--
-- =================================================================================


----Handling the changes for the table azure_data_Archive_pipeline_controller

IF NOT  EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='azure_data_Archive_pipeline_controller'
AND COLUMN_NAME='check_sum_columns')

BEGIN
ALTER TABLE azure_data_Archive_pipeline_controller
ADD check_sum_columns VARCHAR(2000)---PHI:N Desc:  checksum columns to be part of the checksum value for the table 
END




IF NOT  EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='azure_data_Archive_pipeline_controller'
AND COLUMN_NAME='check_sum_column_filter')

BEGIN
ALTER TABLE azure_data_Archive_pipeline_controller
ADD check_sum_column_filter VARCHAR(200)---PHI:N Desc:column to be used for the filter while using the checksum
END


IF NOT  EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='azure_data_Archive_pipeline_controller'
AND COLUMN_NAME='check_sum_unique_id_column')

BEGIN
ALTER TABLE azure_data_Archive_pipeline_controller
ADD check_sum_unique_id_column VARCHAR(100)---PHI:N Desc:column to be used for the filter while using the checksum
END

GO

print 'A_PreUpload/CORE-96784- DDL - Add column to the controller table for the checksum.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-96784- DDL - Add column to the controller table for the checksum.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-96784- DDL - Add columns and Drop the column from the debug table.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

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




-- CORE-96784	
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
--As part of the pho_Schedule_details acrhiving process making required changes to the azure_data_archive_pipeline_steps_debug
--
-- =================================================================================


----Handling the changes for the table azure_data_archive_pipeline_steps_debug


IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='azure_data_archive_pipeline_steps_debug'
AND COLUMN_NAME='azure_file_id')

BEGIN
ALTER TABLE azure_data_archive_pipeline_steps_debug
ADD azure_file_id INT---PHI:N Desc: Holds the file id for the storage files
END



IF EXISTS (SELECT  1 from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
where TABLE_NAME='azure_data_archive_pipeline_steps_debug'
AND constraint_name='azure_data_archive_pipeline_steps_debug__pipelineLastActionCode_FK')
BEGIN 

ALTER TABLE azure_data_archive_pipeline_steps_debug
DROP CONSTRAINT  azure_data_archive_pipeline_steps_debug__pipelineLastActionCode_FK;
END

IF EXISTS (SELECT  1 from INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='azure_data_archive_pipeline_steps_debug'
AND COLUMN_NAME='action_code')
BEGIN 
ALTER TABLE azure_data_archive_pipeline_steps_debug
DROP COLUMN action_code
END

GO

print 'A_PreUpload/CORE-96784- DDL - Add columns and Drop the column from the debug table.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-96784- DDL - Add columns and Drop the column from the debug table.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-96784- DDL - Add columns and Drop the column from the storage file table.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

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


-- CORE-96784	
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
--As part of the pho_Schedule_details acrhiving process making changes to the storage file table
--
-- =================================================================================


----Handling the changes for the table azure_data_archive_pipeline_storage_file_name

IF NOT  EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='azure_data_archive_pipeline_storage_file_name'
AND COLUMN_NAME='pipeline_audit_id')

BEGIN
ALTER TABLE azure_data_archive_pipeline_storage_file_name
ADD pipeline_audit_id INT---PHI:N Desc: Audit id for the pipeline by each executioin 
END






IF NOT  EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='azure_data_archive_pipeline_storage_file_name'
AND COLUMN_NAME='master_file_id')

BEGIN
ALTER TABLE azure_data_archive_pipeline_storage_file_name
ADD master_file_id INT---PHI:N Desc: Master file to the master file for the merged files 
END


IF NOT  EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='azure_data_archive_pipeline_storage_file_name'
AND COLUMN_NAME='is_partial_delete')

BEGIN
ALTER TABLE azure_data_archive_pipeline_storage_file_name
ADD  is_partial_delete BIT ---PHI:N Desc: Bit value to check on partial delete of data 

END

IF NOT EXISTS (SELECT 1 FROM SYS.OBJECTS WHERE TYPE_DESC =  'DEFAULT_CONSTRAINT' AND name='azure_data_archive_pipeline_storage_file_name__isPartialDelete_DFLT')
BEGIN
ALTER TABLE [dbo].[azure_data_archive_pipeline_storage_file_name]   ADD  CONSTRAINT [azure_data_archive_pipeline_storage_file_name__isPartialDelete_DFLT] DEFAULT(0) FOR is_partial_delete
END



IF NOT  EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='azure_data_archive_pipeline_storage_file_name'
AND COLUMN_NAME='partial_delete_count')

BEGIN
ALTER TABLE azure_data_archive_pipeline_storage_file_name
ADD  partial_delete_count INT --PHI:N Desc: Row counts for the partial delete of data 
END


IF NOT EXISTS (SELECT 1 FROM SYS.OBJECTS WHERE TYPE_DESC =  'DEFAULT_CONSTRAINT' AND name='azure_data_archive_pipeline_storage_file_name__partialDeleteCount_DFLT')
BEGIN
ALTER TABLE [dbo].[azure_data_archive_pipeline_storage_file_name]   ADD  CONSTRAINT [azure_data_archive_pipeline_storage_file_name__partialDeleteCount_DFLT] DEFAULT(0) FOR partial_delete_count
END



IF NOT  EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='azure_data_archive_pipeline_storage_file_name'
AND COLUMN_NAME='is_merged')

BEGIN
ALTER TABLE azure_data_archive_pipeline_storage_file_name
ADD is_merged BIT--PHI:N Desc: Bit to check whether the staging files merged or not 
END


IF NOT EXISTS (SELECT 1 FROM SYS.OBJECTS WHERE TYPE_DESC =  'DEFAULT_CONSTRAINT' AND name='azure_data_archive_pipeline_storage_file_name__isMerged_DFLT')
BEGIN
ALTER TABLE [dbo].[azure_data_archive_pipeline_storage_file_name]   ADD  CONSTRAINT [azure_data_archive_pipeline_storage_file_name__isMerged_DFLT] DEFAULT(0) FOR is_merged
END


IF NOT  EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='azure_data_archive_pipeline_storage_file_name'
AND COLUMN_NAME='is_ready_delete')

BEGIN
ALTER TABLE azure_data_archive_pipeline_storage_file_name
ADD is_ready_delete BIT --PHI:N Desc: Bit to check whether the data from the file is ready to delete or not 
END

IF NOT EXISTS (SELECT 1 FROM SYS.OBJECTS WHERE TYPE_DESC =  'DEFAULT_CONSTRAINT' AND name='azure_data_archive_pipeline_storage_file_name__isReadyDelete_DFLT')
BEGIN
ALTER TABLE [dbo].[azure_data_archive_pipeline_storage_file_name]   ADD  CONSTRAINT [azure_data_archive_pipeline_storage_file_name__isReadyDelete_DFLT] DEFAULT(0) FOR is_ready_delete
END

IF NOT  EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='azure_data_archive_pipeline_storage_file_name'
AND COLUMN_NAME='merge_fail')

BEGIN
ALTER TABLE azure_data_archive_pipeline_storage_file_name
ADD merge_fail BIT  --PHI:N Desc: Bit to check whether the data from the file is merge is success or not
END


IF NOT EXISTS (SELECT 1 FROM SYS.OBJECTS WHERE TYPE_DESC =  'DEFAULT_CONSTRAINT' AND name='azure_data_archive_pipeline_storage_file_name__mergeFail_DFLT')
BEGIN
ALTER TABLE [dbo].[azure_data_archive_pipeline_storage_file_name]   ADD  CONSTRAINT [azure_data_archive_pipeline_storage_file_name__mergeFail_DFLT] DEFAULT(0) FOR merge_fail
END




GO

print 'A_PreUpload/CORE-96784- DDL - Add columns and Drop the column from the storage file table.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-96784- DDL - Add columns and Drop the column from the storage file table.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-96784- DDL - Create the new tables for handling the file merging process.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

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




-- CORE-96784	
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
--As part of the pho_Schedule_details acrhiving process adding table for the merging the file to master 
--
-- =================================================================================
----Creating the master table for the merged files

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='azure_data_archive_pipeline_storage_file_master')

BEGIN

CREATE TABLE [dbo].[azure_data_archive_pipeline_storage_file_master]--:PHI=N:Desc:The master table for the final merged file

(
	master_file_id INT IDENTITY(1,1) NOT NULL,--:PHI=N:Desc:The master file id identity value
	pipeline_audit_id INT NOT NULL,--:PHI=N:Desc:The pipeline audit id by execution
	detail_id INT NOT NULL,--:PHI=N:Desc:The detail if for the file
	azure_file_name VARCHAR(150) NOT NULL,--:PHI=N:Desc:The file name for the master file
	is_utilized BIT NOT NULL,--:PHI=N:Desc:The bit that confirms whether the file has beentotally used or not

	
	  CONSTRAINT [azure_data_archive_pipeline_storage_file_master_mastreFileId_PK_CL_IX] PRIMARY KEY CLUSTERED 
(
   master_file_id
)
)  

IF NOT EXISTS (SELECT 1 FROM SYS.OBJECTS WHERE TYPE_DESC =  'DEFAULT_CONSTRAINT' AND name='azure_data_archive_pipeline_storage_file_master__isUtilized_DFLT')
BEGIN
ALTER TABLE [dbo].[azure_data_archive_pipeline_storage_file_master]   ADD  CONSTRAINT [azure_data_archive_pipeline_storage_file_master__isUtilized_DFLT] DEFAULT(0) FOR is_utilized
END

END

----Creating the merget activity table for the merged files


IF NOT EXISTS  (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='azure_data_archive_pipeline_merge_activity_audit')
BEGIN


CREATE TABLE dbo.azure_data_archive_pipeline_merge_activity_audit --:PHI=N:Desc:The merged activity table for the final merged file
(  activity_audit_id INT IDENTITY(1, 1) NOT NULL,  --:PHI=N:Desc: Internal   Unique id for the activity  
   master_file_id INT NOT NULL,--- --:PHI=N:Desc: Master file id that was used to merge  
   log_path VARCHAR(1000) NOT NULL, --:PHI=N:Desc: The merge activity log file path  
   rows_copied VARCHAR(50) NOT NULL,  --:PHI=N:Desc: Internal total number of rows copied to the parquet files
   rows_read VARCHAR(50) NOT  NULL,  --:PHI=N:Desc: Internal total number of rows read to the parquet files
   files_read int NOT NULL,  --:PHI=N:Desc: Internal total rows read by the ADF pipeline
   no_parallel_copies int NULL,  --:PHI=N:Desc: Internal  parralelism by ADF
   merge_duration_in_secs VARCHAR(30) NULL,  --:PHI=N:Desc: Internal  duration for the copy in secs
   merge_start_time VARCHAR(50) NULL,  --:PHI=N:Desc: Internal  the time when the copy started
   merge_queuing_duration_in_secs VARCHAR(50) NULL,  --:PHI=N:Desc: Internal  time spend by adf pipeline in qeue
   merge_transfer_duration_in_secs VARCHAR(50) NULL,  --:PHI=N:Desc: Internal transfer duration by adf
 
  CONSTRAINT [azure_data_archive_pipeline_merge_activity_audit_AuditId_PK_CL_IX] PRIMARY KEY CLUSTERED 
(
   activity_audit_id ASC
),
CONSTRAINT [azure_data_archive_pipeline_merge_activity_audit__masteFileId_FK] FOREIGN KEY (master_file_id) REFERENCES azure_data_archive_pipeline_storage_file_master (master_file_id)


)


END



GO

print 'A_PreUpload/CORE-96784- DDL - Create the new tables for handling the file merging process.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-96784- DDL - Create the new tables for handling the file merging process.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97065 -01- DML-Add new security function to Edit HIPPS on CensusRates for Non PPS payers.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

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
-- CORE-97065
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
--     * 1028.0: Manual Edit of HIPPS on Census/Rates for Non-PPS payers
--
--   URL: http://vmusnpdvshsg01/create?scriptType=I&issueKey=CORE-97065&moduleId=1&functionUpdates%5B1%5D.funcId=1028.0&functionUpdates%5B1%5D.parentId=1028.0&functionUpdates%5B1%5D.sequenceNo=1020.98&functionUpdates%5B1%5D.description=Manual+Edit+of+HIPPS+on+Census%2FRates+for+Non-PPS+payers&functionUpdates%5B1%5D.environment=USAR&functionUpdates%5B1%5D.accessType=YN&functionUpdates%5B1%5D.accessLevel=C&functionUpdates%5B1%5D.accessCopyFromFuncId=1027.0&functionUpdates%5B1%5D.accessCopyFromDefault=0&functionUpdates%5B1%5D.systemRoleAccess%5B%271%27%5D=-999&functionUpdates%5B1%5D.systemRoleAccess%5B%273%27%5D=-999&functionUpdates%5B1%5D.systemRoleAccess%5B%275%27%5D=-999&functionUpdates%5B1%5D.systemRoleAccess%5B%271515%27%5D=-999&functionUpdates%5B1%5D.systemRoleAccess%5B%271000%27%5D=-999&function
--        Updates%5B1%5D.systemRoleAccess%5B%271714%27%5D=-999&functionUpdates%5B1%5D.systemRoleAccess%5B%271715%27%5D=-999&functionUpdates%5B1%5D.systemRoleAccess%5B%271795%27%5D=-999&functionUpdates%5B1%5D.systemRoleAccess%5B%271807%27%5D=-999
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
SET @createdBy = 'CORE-97065'

--========================================================================================================
-- 1028.0: Manual Edit of HIPPS on Census/Rates for Non-PPS payers
--========================================================================================================

-- (1) Prepare @sec_function__ins ===========================================================
INSERT INTO @sec_function__ins (func_id, deleted, created_by, created_date, module_id, [type], description, parent_function, sequence_no, facility_type)
    VALUES ('1028.0', 'N', @createdBy, @NOW, @moduleId, 'YN', 'Manual Edit of HIPPS on Census/Rates for Non-PPS payers', 'Y', 1020.98, 'USAR')
	
-- (2) Prepare @sec_role_function__ins ======================================================
-- (2a) Add new function to all appropriate roles ------------------------------
INSERT INTO @sec_role_function__ins (role_id, func_id, created_by, created_date, revision_by, revision_date, access_level)
    SELECT DISTINCT role_id, '1028.0', @createdBy, @NOW, NULL, NULL, 0 FROM sec_role r
    WHERE @moduleId = 10 -- new functions in the "All" module are applicable to every role
        OR (module_id = @moduleId AND description <> 'Collections Setup (system)' AND description <> 'Collections User (system)')
        OR (module_id = 0 AND EXISTS (SELECT 1 FROM sec_role_function rf INNER JOIN sec_function f ON rf.func_id = f.func_id WHERE f.module_id = @moduleId AND rf.role_id = r.role_id))
		
-- (2b) Default Permissions: Copy from another function ------------------------
UPDATE f
    SET access_level = CASE WHEN src.access_level >= 0 THEN src.access_level ELSE 0 END
FROM @sec_role_function__ins f
    INNER JOIN sec_role_function src ON f.role_id = src.role_id
WHERE f.func_id = '1028.0' AND src.func_id = '1027.0'


--========================================================================================================
-- Apply changes
--========================================================================================================
BEGIN TRAN
BEGIN TRY
    DELETE FROM sec_function WHERE func_id IN ('1028.0')
    DELETE FROM sec_role_function WHERE func_id IN ('1028.0')
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

print 'A_PreUpload/CORE-97065 -01- DML-Add new security function to Edit HIPPS on CensusRates for Non PPS payers.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97065 -01- DML-Add new security function to Edit HIPPS on CensusRates for Non PPS payers.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97065 -02- DML-Update description of Edit HIPPS security function.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

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
-- CORE-97065
--
-- Written By:       Shino Johnson
--
-- Script Type:      DML
-- Target DB Type:   Client
-- Target Database:  Both
--
-- Re-Runnable:      YES
--  Description :    Update the description of existing security function 'Manual Edit of HIPPS on Census/Rates'
--					 to 'Manual Edit of HIPPS on Census/Rates for PPS payers'
--
-- Staging Recommendations/Warnings: None
--
--
--=======================================================================================================================

-- CONSTANTS
DECLARE @NOW datetime
SET @NOW = GETDATE()

DECLARE @revisionBy varchar(70)
SET @revisionBy = 'CORE-97065'

UPDATE sec_function
	SET description = 'Manual Edit of HIPPS on Census/Rates for PPS payers', revision_by = @revisionBy, revision_date = @NOW
	WHERE func_id = '1027.0'
		AND module_id = 1;


GO

print 'A_PreUpload/CORE-97065 -02- DML-Update description of Edit HIPPS security function.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97065 -02- DML-Update description of Edit HIPPS security function.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97107 - DDL - fn_standardixe_metadata_for_code - helper funciton for matadata capture',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

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
-- Author:               Ravi Venkataraman
--
-- Script Type:          DDL
-- Target DB Type:       CLIENTDB
-- Target ENVIRONMENT:   US and CDN
--
--
-- Re-Runable:           YES
--
-- Special Instruction:
-- Comments:             CORE-96810 - Function to standardize metadata code
--                             for triggers, stored procedures, views and functions,
--                            This funciton takes the body of the object defined above
--                            and produces a standard version.
--                             It ignores the following:
--                             case (upper or lower)
--                             use of "[" and "]" will be ignored.
--                             spaces
--                             usage of "create or alter" vs "create"
--                             blank lines, tabs or carraiage returns
--                       Note: the replace must be applied in the proper order.
--
-- Created On: Nov 11, 2021
-- =================================================================================
--
-- ------------------------------------------------------
-- ------------------------------------------------------


drop function if exists metadata.fn_standardize_metadata_code;
go

CREATE FUNCTION metadata.fn_standardize_metadata_code(@text   varchar(max))
RETURNS varchar(max)
AS
BEGIN
    RETURN replace (
             replace(
               replace(
                 replace(
                   replace(
                     replace(
                       replace(lower(@text), ' ', ''),
                       '[', ''),
	                 ']', ''),
                   char(10), ''),    -- newline
                 char(9), ''),       -- tab
               char(13), ''),        -- carriage return
             'createoralter','create'); -- This must be the last replace
                                        -- so as to avoid the case where
					-- newlines, spaces, tabs or square brackets 
					-- are somehow interoduced between 
					-- create and the name of the object.

END

GO

GRANT execute on metadata.fn_standardize_metadata_code to public;
go

	      
	          



GO

print 'A_PreUpload/CORE-97107 - DDL - fn_standardixe_metadata_for_code - helper funciton for matadata capture -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97107 - DDL - fn_standardixe_metadata_for_code - helper funciton for matadata capture',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97107 - DDL - metadata_for_routine modified to compute hash value differently',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

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
-- Author:               Ravi Venkataraman
--
-- Script Type:          DDL
-- Target DB Type:       CLIENTDB
-- Target ENVIRONMENT:   US and CDN
--
-- Re-Runable:           YES
--
-- Special Instruction:  
-- Comments: 			 CORE-81867  Function metadata_for_metadata_for_routine
--                                   This gets the detailed metadata for routines 
--									 (Stored procedures and functions)
--
--           Nov 11, 2021:           CORE-97107:
--                                   Changed the way the hash value
--                                   is calculated to account for differences caused by
--                                   spaces, tabs, newlines, carriage returs,
--                                   "create or alter" instead of "Create"
--                                   and '[' and ']'
--
-- =================================================================================
--

if exists (
			Select 1
			from   sys.objects
			where  object_id = object_id('metadata.metadata_for_routine')
			  and  type in (N'FN', N'IF', N'TF', N'FS', N'FT')
		   )
begin
		drop function metadata.metadata_for_routine;
end
go

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE function metadata.metadata_for_routine
(
	@obj_name    varchar(200) = ''
)
RETURNS TABLE AS

RETURN

	select  
			routine_name  as obj_name,
			'routine' as obj_type,
			routine_type as parent_object_name,
  			routine_schema + '.' + routine_name + ',' +
			CONVERT(varchar(max), 
					HASHBYTES('SHA2_256',
				              metadata.fn_standardize_metadata_code(routine_definition)
				             ), 
				    2) as data
	from	information_schema.routines 
	where   routine_body <> 'EXTERNAL'
	  and    (@obj_name = routine_name or @obj_name = '')

GO

grant select on metadata.metadata_for_routine to public
go




GO

print 'A_PreUpload/CORE-97107 - DDL - metadata_for_routine modified to compute hash value differently -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97107 - DDL - metadata_for_routine modified to compute hash value differently',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97107 - DDL - metadata_for_trigger - modified to compute hash value differently',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

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
-- Author:               Ravi Venkataraman
--
-- Script Type:          DDL
-- Target DB Type:       CLIENTDB
-- Target ENVIRONMENT:   US and CDN
--
-- Re-Runable:           YES
--
-- Special Instruction:  
-- Comments: 			 CORE-81867  Function metadata_for_metadata_for_trigger
--                                   This gets the detailed metadata for triggers
--           Nov 11, 2021:           CORE-97107:
--                                   Changed the way the hash value
--                                   is calculated to account for differences caused by
--                                   spaces, tabs, newlines, carriage returs,
--                                   "create or alter" instead of "Create"
--                                   and '[' and ']'
--
-- =================================================================================
--

if exists (
			Select 1
			from   sys.objects
			where  object_id = object_id('metadata.metadata_for_trigger')
			  and  type in (N'FN', N'IF', N'TF', N'FS', N'FT')
		   )
begin
		drop function metadata.metadata_for_trigger;
end
go


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE function [metadata].[metadata_for_trigger]
(
	@obj_name    varchar(200) = ''
)
RETURNS TABLE AS

RETURN	
    select 
            trg.name  as obj_name,
            'trigger' as obj_type,
            object_name(trg.parent_id) as parent_object_name,
            CONVERT(varchar(max), 
                    hashbytes('SHA2_256', 
                              metadata.fn_standardize_metadata_code(mod.definition)
                             ),
  					2)	as data
    from    sys.triggers trg
    join    sys.sql_modules mod
      on    mod.object_id = trg.object_id
    where   trg.parent_id <> 0 
      and   metadata.is_temporary_object(object_name(trg.parent_id)) = 0
      and   (@obj_name = trg.name or @obj_name = '')
;


GO



grant select on metadata.metadata_for_trigger to public
go

-- -----------------------------------------------------------





GO

print 'A_PreUpload/CORE-97107 - DDL - metadata_for_trigger - modified to compute hash value differently -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97107 - DDL - metadata_for_trigger - modified to compute hash value differently',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97107 - DDL - metadata_for_view - modified to compute hash value differently',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

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
-- Author:               Ravi Venkataraman
--
-- Script Type:          DDL
-- Target DB Type:       CLIENTDB
-- Target ENVIRONMENT:   US and CDN
--
--
-- Re-Runable:           YES
--
--
-- Special Instruction:  
-- Comments: 			 CORE-81867  Function metadata_for_metadata_for_view
--                                   This gets the detailed metadata for routines 
--									 (Stored procedures and functions)
--           Nov 11, 2021:           CORE-97107:
--                                   Changed the way the hash value
--                                   is calculated to account for differences caused by
--                                   spaces, tabs, newlines, carriage returs,
--                                   "create or alter" instead of "Create"
--                                   and '[' and ']'
--
-- =================================================================================
--

if exists (
			Select 1
			from   sys.objects
			where  object_id = object_id('metadata.metadata_for_view')
			  and  type in (N'FN', N'IF', N'TF', N'FS', N'FT')
		   )
begin
		drop function metadata.metadata_for_view;
end
go

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE function [metadata].[metadata_for_view]
(
	@obj_name    varchar(200) = ''
)
RETURNS TABLE AS

RETURN
	select  
			table_name  as obj_name,
			'view' as obj_type,
			'view' as parent_object_name,
  			table_schema + '.' + table_name + ',' +
			CONVERT(varchar(max), 
			        HASHBYTES('SHA2_256', 
			                  metadata.fn_standardize_metadata_code(view_definition)
			                 ), 
			        2) as data
	from	information_schema.views 
	where   (@obj_name = table_name or @obj_name = '')


GO

grant select on metadata.metadata_for_view to public
go






GO

print 'A_PreUpload/CORE-97107 - DDL - metadata_for_view - modified to compute hash value differently -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97107 - DDL - metadata_for_view - modified to compute hash value differently',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97108 - DDL - update change set tables.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

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
CORE-95378        Revisiting Change Set DB Design. Needed for Sparta
 
Written By:       Elias Ghanem
 
Script Type:      DDL
Target DB Type:   Client
Target Database:  BOTH
Re-Runable:       YES
 
Description :     Create change set tables
Re-creates tables : drops if exists and creates brand new tables and related objects
==============================================================================
*/

--DROP TABLES
IF EXISTS (SELECT * FROM sys.tables WHERE NAME = 'changeset_status')
BEGIN
	DROP TABLE [dbo].[changeset_status]
END

IF EXISTS (SELECT * FROM sys.tables WHERE NAME = 'pho_phys_order_changeset')
BEGIN
	DROP TABLE [dbo].[pho_phys_order_changeset]
END

--CREATE pho_phys_order_changeset TABLE
CREATE TABLE [dbo].[pho_phys_order_changeset](--:PHI=N:Desc:Holds all changeset requests sent by the pharmacy or performed by the wellness director
	[changeset_id] [bigint] IDENTITY NOT NULL,--:PHI=N:Desc:Id of the changeset row
	[message_id] [varchar](60) NULL,--:PHI=N:Desc:Id of the related PIMS message that led to the creation of this row. This field is not a foreign key to another table
	[phys_order_id] [int] NULL,--:PHI=N:Desc:Id of the order that this change set targets
	[changeset_type_id] [int] NOT NULL,--:PHI=N:Desc:Type of the change requested. This field is not a foreign to another table. Allowed values are:(1, new order), (2, update to an order), (3, discontinue of an order)
	[changeset_source_id] [int] NOT NULL,--:PHI=N:Desc:Indicates the source of the changeset (pharmacy or WDW). This field is not a foreign key to another table. Allowed vlaues are: (1,pharmacy), (2,WDW), (3,Orders Service)
	[changeset_data] [varchar](8000) NOT NULL,--:PHI=Y:Contains the changeset to be applied to the order. May contain resident information, medication name...
	[resulting_phys_order_id] [int] NULL,--:PHI=N:Desc:In case the changeset results in the creation of new order, this field holds the Id of this new order
	[current_status_id] [bigint] NULL,--:PHI=N:Desc:Holds the Id of the current status in changeset_status table. This field is not a physical foreign key but act as a logical foreign key to changeset_status table
	[aggregate_changeset_id] [bigint] NULL,--:PHI=N:Desc:When multiple changest rows are agregated, this field holds the Id for the resulting changeset
	[created_by] [varchar](60) NOT NULL,--:PHI=N:Desc:Who created the changeset
	[created_date] [datetime] NOT NULL,--:PHI=N:Desc:Created date of the changeset
	CONSTRAINT [pho_phys_order_changeset__physOrderChangesetId_PK_CL_IX] PRIMARY KEY ([changeset_id]),
	CONSTRAINT [pho_phys_order_changeset__changeset_type_id_CHK] CHECK (changeset_type_id IN (1, 2, 3)),
	CONSTRAINT [pho_phys_order_changeset__changeset_source_id_CHK] CHECK (changeset_source_id IN (1, 2, 3))
)

--CREATE changeset_status TABLE
CREATE TABLE [dbo].[changeset_status](--:PHI=N:Desc:A detail table for pho_phys_order_changeset. It hold all the statuses of the changeset records
	[changeset_status_id] [bigint] IDENTITY NOT NULL,--:PHI=N:Desc:Id of the changeset_status row
	[changeset_id] [bigint] NULL,--:PHI=N:Desc:Holds the Id of the parent pho_phys_order_changeset row
	[status_id] [int] NOT NULL,--:PHI=N:Desc:Holds the satatus Id. This field is not a foreign key to another table. Allowed values are: (1, New), (2, Confirmed), (3,Declined), (4,Reviewed)
	[status_source] [int] NOT NULL,--:PHI=N:Desc:Represents the entity that moved the changeset to this status. This field is not a foreign key to another table. Allowed values are: (1,pharmacy), (2,WDW), (3,Orders Service)
	[status_reason] [varchar](100) NULL,--:PHI=N:Desc:Reason for this status
	[notes] [varchar](250) NULL,--:PHI=N:Desc:Notes relative to the status
	[status_by] [varchar](60) NOT NULL,--:PHI=N:Desc:Who created the status
	[status_date] [datetime] NOT NULL,--:PHI=N:Desc:Created date of the status
	CONSTRAINT [changeset_status__ChangesetStatusId_PK_CL_IX] PRIMARY KEY ([changeset_status_id]),
	CONSTRAINT [changeset_status__status_id_CHK] CHECK (status_id IN (1, 2, 3, 4)),
	CONSTRAINT [changeset_status__status_source_CHK] CHECK (status_id IN (1, 2, 3))
)

--CREATE FOREIGN KEYS AND INDEXES
IF EXISTS (SELECT * FROM sys.tables WHERE NAME = 'pho_phys_order_changeset') AND EXISTS (SELECT * FROM sys.tables WHERE NAME = 'changeset_status')
BEGIN
	ALTER TABLE [dbo].[changeset_status] ADD CONSTRAINT [changeset_status__changeset_id__FK] FOREIGN KEY([changeset_id])
	REFERENCES [dbo].[pho_phys_order_changeset] ([changeset_id])
	
	CREATE NONCLUSTERED INDEX [changeset_status__changesetId_FK_IX]
	ON [dbo].[changeset_status] ([changeset_id]);
		
	ALTER TABLE [dbo].[pho_phys_order_changeset] ADD CONSTRAINT [pho_phys_order_changeset__aggregate_changeset_id__FK] FOREIGN KEY([aggregate_changeset_id])
	REFERENCES [dbo].[pho_phys_order_changeset] ([changeset_id])
	
	ALTER TABLE [dbo].[pho_phys_order_changeset] ADD CONSTRAINT [pho_phys_order_changeset__phys_order_id__FK] FOREIGN KEY([phys_order_id])
	REFERENCES [dbo].[pho_phys_order] ([phys_order_id])
	
	ALTER TABLE [dbo].[pho_phys_order_changeset] ADD CONSTRAINT [pho_phys_order_changeset__resulting_phys_order_id__FK] FOREIGN KEY([resulting_phys_order_id])
	REFERENCES [dbo].[pho_phys_order] ([phys_order_id])
	
	CREATE NONCLUSTERED INDEX [pho_phys_order_changeset__aggregate_changeset_id_FK_IX]
	ON [dbo].[pho_phys_order_changeset] ([aggregate_changeset_id]);
	
	CREATE NONCLUSTERED INDEX [pho_phys_order_changeset__current_status_id_id_FK_IX]
	ON [dbo].[pho_phys_order_changeset] ([current_status_id]);
	
END

GO

print 'A_PreUpload/CORE-97108 - DDL - update change set tables.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97108 - DDL - update change set tables.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97108 - DDL - update sproc_sprt_order_list.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

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
--
--  Script Type: user defined store procedure
--  Target DB Type:  Client
--  Target Database:  Both
--
--  Re-Runable:  Yes
--
--  Description :  Return a list of Physician Orders and other dependent data such as schedules.
--
--	Params:			
--			@facUUIdCSV
--			@clientId
--			@facilityDateTime
--			@orderCategoryIdsCSV
--			@orderStatusCSV
--			@clientStatus
--			@changesetTypesCSV
--			@changesetStatusesCSV
--			@changesetSourceId
--			@physOrderId
--			@pageSize
--			@pageNumber
--			@sortByColumn
--			@sortByOrder
--			@includeOrders
--			@includeSchedules
--			@includeChangesets
--			@debug          - Debug param, 'Y' or 'N'
--			@status_code    - SP execution flag, 0 for success.
--			@status_text    - SP error text if error occurs.
--
-- Change History:
--   Date			Jira				Team		Author				Comment
-- -----------------------------------------------------------------------------------------------------------------------------------
--   09/28/2021     SPRT-740			Coda	    Elias Ghanem  		Created.
-- =========================================================================================================================

IF EXISTS (SELECT *
               FROM
                   dbo.sysobjects
               WHERE
                   id = object_id(N'[dbo].[sproc_sprt_order_list]')
                   AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].[sproc_sprt_order_list]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sproc_sprt_order_list]			@facUUIdCSV               varchar(MAX),-- Required: CSV list of fac uuids to filter on
														@clientId				INT,-- Optional: client Id to filter on
                                                        @facilityDateTime       DATETIME,-- Required: facility date time
                                                        @orderCategoryIdsCSV	VARCHAR(100),-- Required CSV list of categegory ids to filter n
                                                        @orderStatusCSV         VARCHAR(100),-- Required: CSV list of order status ids to filter on
                                                        @clientStatus 			INT,-- Required: flag to filter on client status: -1: ALL, 0: Discharged, 1:Current(not discharged)
														@changesetTypesCSV		VARCHAR(100),-- Optional: changeset types to filter on and return
														@changesetStatusesCSV	VARCHAR(100),-- Optional: changeset statuses to filter on and return
														@changesetSourceId		INT,-- Optional: changeset sourece to filter on
                                                        @physOrderId 			INT,-- Optional: physOrderId to filter on
                                                        @pageSize 				INT,-- Required: number of phys orders per page
                                                        @pageNumber 			INT,-- Required: page number	
                                                        @sortByColumn 			VARCHAR(100),-- Required: column to sort on.
                                                        @sortByOrder  			VARCHAR(10),-- Required sort order
														@includeOrders 			INT,-- Required: flag to indicate whether orders data is returned or not: 1: orders summary, 2:orders details, 0:orders data not to be returned
														@includeSchedules 		INT,-- Required: flag to indicate whether schedules data is returned or not: 1: schedules summary, 2:schedules details, 0:schedules data not to be returned
														@includeChangesets 		INT,-- Required: flag to indicate whether changeset data is returned or not: 1: changeset summary, 2:changeset details, 0:changeset data not to be returned
														@debug              	CHAR(1)  = 'N',-- Required: flag to indicate whether to print debug data or not
														@status_code        	INT  = 0 OUT,
                                                        @status_text        	VARCHAR(3000) OUT



/***********************************************************************************************

Purpose:
This procedure provides data shown on Resident' Order Chart
This procedure does not use VIEW_PHO_PHYS_ORDER

*************************************************************************************************/

AS
BEGIN TRY
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

DECLARE @step                       			int,
		@step_label								varchar(100),
        @error_code                 			int

SET @step = 0
SET @step_label = 'Starting...'
SET @error_code = 0

/*
DECLARE @facIds TABLE
(
	fac_id int  not null
)
*/

DECLARE @orderCategoryIds TABLE
(
	order_category_id INT  NOT NULL
)

DECLARE @orderStatus TABLE
(
	status INT NOT NULL
)

DECLARE @changesetTypes TABLE
(
	changeset_type_id INT NOT NULL
)

DECLARE @changesetStatuses TABLE
(
	status_id INT NOT NULL
)

DECLARE @facInfo TABLE
(
	fac_id INT,
	fac_uuid UNIQUEIDENTIFIER,
	facility_time datetime,
	IsDischargeEnabled  BIT
)

CREATE TABLE #orders_data
  ( 
	phys_order_id             	INT, 
	fac_id                    	INT, 
	client_id                 	INT, 
	order_verified            	VARCHAR(1),
	order_status				INT,
	active_flag               	CHAR(1), 
	draft                     	BIT, 
	hold_date                 	DATETIME, 
	hold_date_end             	DATETIME, 
	end_date                  	DATETIME, 
	discontinued_date         	DATETIME, 
	order_category_id         	INT, 
	controlled_substance_code 	INT,
	
	physician_id INT,
	pharmacy_id INT,
	route_of_admin INT,
	created_by VARCHAR(60),
	created_date DATETIME,
	revision_by VARCHAR(60),
	revision_date DATETIME,
	start_date DATETIME,
	strength VARCHAR(30),
	form VARCHAR(50),
	description VARCHAR(500),
	directions VARCHAR(1000),
	related_generic VARCHAR(250),
	communication_method INT,
	prescription VARCHAR(50),
	order_date DATETIME,
	completed_date DATETIME,
	origin_id INT,
	drug_strength VARCHAR(100),
	drug_strength_uom VARCHAR(10),
	drug_name VARCHAR(500),
	order_class_id INT,
	resident_last_name varchar(50),
	resident_first_name varchar(50)	 
  ) ;

CREATE TABLE #tempresult 
  ( 
	phys_order_id             INT, 
	fac_id                    INT, 
	client_id                 INT, 
	order_verified            VARCHAR(1), 
	active_flag               CHAR(1), 
	draft                     BIT, 
	hold_date                 DATETIME, 
	hold_date_end             DATETIME, 
	end_date                  DATETIME, 
	discontinued_date         DATETIME, 
	order_category_id         INT, 
	controlled_substance_code INT,
	facility_time datetime,
	IsDischargeEnabled  BIT,
	
	physician_id INT,
	pharmacy_id INT,
	route_of_admin INT,
	created_by VARCHAR(60),
	created_date DATETIME,
	revision_by VARCHAR(60),
	revision_date DATETIME,
	start_date DATETIME,
	strength VARCHAR(30),
	form VARCHAR(50),
	description VARCHAR(500),
	directions VARCHAR(1000),
	related_generic VARCHAR(250),
	communication_method INT,
	prescription VARCHAR(50),
	order_date DATETIME,
	completed_date DATETIME,
	origin_id INT,
	drug_strength VARCHAR(100),
	drug_strength_uom VARCHAR(10),
	drug_name VARCHAR(500),
	order_class_id INT,
	resident_last_name varchar(50),
	resident_first_name varchar(50)
  ) ;
CREATE CLUSTERED INDEX _tempresult_order_id ON #tempresult( phys_order_id );  

CREATE TABLE #vpos
	(
	phys_order_id int NOT NULL,
	fac_id int NOT NULL,
	order_status int NOT NULL,
	order_relationship int NULL,
	status_reason int NULL
	)

SET @step = @step + 1	
SET @step_label = 'Parse CSV parameters into table vairables'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
	
--INSERT INTO @facIds (fac_id)
--SELECT f.fac_id FROM facility f INNER JOIN dbo.Split(@facUUIdCSV, ',') uuids ON uuids.items = f.fac_uuid
INSERT INTO @facInfo
	(fac_id,
	fac_uuid,
	facility_time,
	IsDischargeEnabled
	)
	SELECT f.fac_id,
	f.fac_uuid,
	dbo.fn_facility_getCurrentTime(f.fac_id),
	CASE WHEN cp.value = 'Y' THEN 1 ELSE 0 END
	FROM facility f
	INNER JOIN dbo.Split(@facUUIdCSV, ',') uuids ON uuids.items = f.fac_uuid
	LEFT JOIN configuration_parameter cp ON cp.fac_id = f.fac_id AND cp.name='discharge_order_enable'


INSERT INTO @orderCategoryIds (order_category_id)
SELECT * FROM dbo.Split(@orderCategoryIdsCSV, ',')	
DELETE FROM @orderCategoryIds where order_category_id=1 or order_category_id=3030

INSERT INTO @orderStatus (status)
SELECT * FROM dbo.Split(@orderStatusCSV, ',');

INSERT INTO @changesetTypes (changeset_type_id)
SELECT * FROM dbo.Split(@changesetTypesCSV, ',');

INSERT INTO @changesetStatuses (status_id)
SELECT * FROM dbo.Split(@changesetStatusesCSV, ',');

	
SET @step = @step + 1	
SET @step_label = 'Check for required parameters...'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
IF NOT EXISTS(SELECT 1 FROM @facInfo)
BEGIN
	raiserror ('facUUIdCSV is required. At least one facUUId must be provided.', 16, 1)
END
IF NOT EXISTS(SELECT 1 FROM @orderCategoryIds)
BEGIN
	raiserror ('orderCategoryIdsCSV is required. At least one orderCategoryId must be provided.', 16, 1)
END
IF NOT EXISTS(SELECT 1 FROM @orderStatus)
BEGIN
	raiserror ('orderStatusCSV is required. At least one orderStatus must be provided.', 16, 1)
END	
IF @facilityDateTime IS NULL
BEGIN
	raiserror ('facilityDateTime is required.', 16, 1)
END
IF @clientStatus IS NULL OR @clientStatus NOT IN (-1, 0, 1)
BEGIN
	raiserror ('clientStatus is required. Allowed values are: -1, 0, 1.', 16, 1)
END	
IF @pageSize IS NULL OR @pageSize <= 0
BEGIN
	raiserror ('pageSize is required and should be a positive number.', 16, 1)
END	
IF @pageNumber IS NULL or @pageNumber <= 0
BEGIN
	raiserror ('pageNumber is required and should be a positive number.', 16, 1)
END	
IF @sortByColumn IS NULL
BEGIN
	raiserror ('sortByColumn is required.', 16, 1)
END	
IF @sortByOrder IS NULL
BEGIN
	raiserror ('sortByOrder is required.', 16, 1)
END
IF (( EXISTS(SELECT 1 FROM @changesetTypes) OR EXISTS(SELECT 1 FROM @changesetStatuses)) AND
	(NOT EXISTS(SELECT 1 FROM @changesetTypes) OR NOT EXISTS(SELECT 1 FROM @changesetStatuses)))
BEGIN
	raiserror ('changesetTypesCSV and changesetStatusesCSV should be both set or both empty', 16, 1)
END
IF @changesetSourceId IS NOT NULL AND (NOT EXISTS(SELECT 1 FROM @changesetTypes) OR NOT EXISTS(SELECT 1 FROM @changesetStatuses))
BEGIN
	raiserror ('If changesetSourceId is set, both changesetTypesCSV and changesetStatusesCSV should be set', 16, 1)
END
IF @includeOrders IS NULL OR @includeOrders NOT IN (0, 1, 2)
BEGIN
	raiserror ('includeOrders is required. Allowed values are: 0, 1, 2', 16, 1)
END	
IF @includeSchedules IS NULL OR @includeSchedules NOT IN (0, 1, 2)
BEGIN
	raiserror ('includeSchedules is required. Allowed values are: 0, 1, 2', 16, 1)
END
IF @includeChangesets IS NULL OR @includeSchedules NOT IN (0, 1, 2)
BEGIN
	raiserror ('includeChangesets is required. Allowed values are: 0, 1, 2', 16, 1)
END
IF @includeChangesets IN (1, 2) AND (NOT EXISTS(SELECT 1 FROM @changesetTypes) OR NOT EXISTS(SELECT 1 FROM @changesetStatuses))
BEGIN
	raiserror ('If includeChangesets value is 1 or 2, both changesetTypesCSV and changesetStatusesCSV should be set', 16, 1)
END
		
/*
SET @step = @step + 1
SET @step_label = 'Prepare facility info'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
INSERT INTO @facInfo	
	(fac_id,
	facility_time,
	IsDischargeEnabled
	)
	SELECT f.fac_id, 
	dbo.fn_facility_getCurrentTime(f.fac_id),
	CASE WHEN cp.value = 'Y' THEN 1 ELSE 0 END
	FROM @facIds f	
	LEFT JOIN configuration_parameter cp ON cp.fac_id = f.fac_id AND cp.name='discharge_order_enable'
*/	
	
SET @step = @step + 1
SET @step_label = 'Insert into #tempresult'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text

INSERT INTO #tempresult
	( 
	phys_order_id, 
	fac_id, 
	client_id, 
	order_verified, 
	active_flag, 
	draft, 
	hold_date, 
	hold_date_end, 
	end_date, 
	discontinued_date, 
	order_category_id, 
	controlled_substance_code,
	facility_time,
	IsDischargeEnabled,
	
	physician_id,
	pharmacy_id,
	route_of_admin,
	created_by,
	created_date,
	revision_by,
	revision_date,
	start_date,
	strength,
	form,
	description,
	directions,
	related_generic,
	communication_method,
	prescription,
	order_date,
	completed_date,
	origin_id,
	drug_strength,
	drug_strength_uom,
	drug_name,
	order_class_id,
	resident_last_name,
	resident_first_name
	)
	SELECT
		o.phys_order_id, 
		o.fac_id, 
		o.client_id, 
		o.order_verified, 
		o.active_flag, 
		o.draft, 
		o.hold_date, 
		o.hold_date_end, 
		o.end_date, 
		o.discontinued_date, 
		o.order_category_id, 
		o.controlled_substance_code,
		fi.facility_time,
		fi.IsDischargeEnabled,
		o.physician_id,
		o.pharmacy_id,
		o.route_of_admin,
		o.created_by,
		o.created_date,
		o.revision_by,
		o.revision_date,
		o.start_date,
		o.strength,
		o.form,
		o.description,
		o.directions,
		o.related_generic,
		o.communication_method,
		o.prescription,
		o.order_date,
		o.completed_date,
		o.origin_id,
		o.drug_strength,
		o.drug_strength_uom,
		o.drug_name,
		o.order_class_id,
		m.last_name,
		m.first_name
	FROM pho_phys_order o
	--INNER JOIN @facIds f ON f.fac_id = o.fac_id
	INNER JOIN @facInfo fi ON fi.fac_id = o.fac_id
	INNER JOIN @orderCategoryIds cat ON cat.order_category_id = o.order_category_id
	INNER JOIN clients c ON c.client_id = o.client_id
	INNER JOIN mpi m ON m.mpi_id = c.mpi_id
	WHERE (@physOrderId IS NULL OR o.phys_order_id = @physOrderId) AND ISNULL(o.active_flag, 'Y') = 'Y'
	AND (@clientId IS NULL OR o.client_id = @clientId)
	AND (@clientStatus = -1 OR (@clientStatus = 1 AND (c.discharge_date IS NULL OR c.discharge_date > @facilityDateTime)) OR (@clientStatus = 0 AND c.discharge_date <= @facilityDateTime))

SET @step = @step + 1	
SET @step_label = 'Applying changeset filtering if needed'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text

IF EXISTS(SELECT 1 FROM @changesetTypes) OR EXISTS (SELECT 1 FROM @changesetStatuses) OR @changesetSourceId IS NOT NULL
	BEGIN
	MERGE #tempresult AS TARGET
	USING (select o.phys_order_id
	FROM #tempresult o	
	INNER JOIN pho_phys_order_changeset cs ON cs.phys_order_id = o.phys_order_id
	INNER JOIN @changesetTypes cst ON cst.changeset_type_id = cs.changeset_type_id
	INNER JOIN changeset_status csstat ON csstat.changeset_status_id = cs.current_status_id
	INNER JOIN @changesetStatuses csstats ON csstats.status_id = csstat.status_id
	WHERE @changesetSourceId IS NULL OR cs.changeset_source_id = @changesetSourceId
	) AS SOURCE
	ON (TARGET.phys_order_id = SOURCE.phys_order_id) 
	WHEN NOT MATCHED BY SOURCE 
	THEN DELETE; 
END

SET @step = @step + 1	
SET @step_label = 'Calculating orders statuses'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
insert into #vpos
exec sproc_sprt_pho_getOrderStatus  @debug,@status_code out,@status_text out


SET @step = @step + 1	
SET @step_label = 'Insert into #orders_data'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
INSERT INTO #orders_data
	( 
	phys_order_id, 
	fac_id, 
	client_id, 
	order_verified,
	order_status,
	active_flag, 
	draft, 
	hold_date, 
	hold_date_end, 
	end_date, 
	discontinued_date, 
	order_category_id, 
	controlled_substance_code,
	physician_id,
	pharmacy_id,
	route_of_admin,
	created_by,
	created_date,
	revision_by,
	revision_date,
	start_date,
	strength,
	form,
	description,
	directions,
	related_generic,
	communication_method,
	prescription,
	order_date,
	completed_date,
	origin_id,
	drug_strength,
	drug_strength_uom,
	drug_name,
	order_class_id,
	resident_last_name,
	resident_first_name
	)
	SELECT
		temp.phys_order_id, 
		temp.fac_id, 
		temp.client_id, 
		temp.order_verified,
		vpos.order_status,
		temp.active_flag, 
		temp.draft, 
		temp.hold_date, 
		temp.hold_date_end, 
		temp.end_date, 
		temp.discontinued_date, 
		temp.order_category_id, 
		temp.controlled_substance_code,
		temp.physician_id,
		temp.pharmacy_id,
		temp.route_of_admin,
		temp.created_by,
		temp.created_date,
		temp.revision_by,
		temp.revision_date,
		temp.start_date,
		temp.strength,
		temp.form,
		temp.description,
		temp.directions,
		temp.related_generic,
		temp.communication_method,
		temp.prescription,
		temp.order_date,
		temp.completed_date,
		temp.origin_id,
		temp.drug_strength,
		temp.drug_strength_uom,
		temp.drug_name,
		temp.order_class_id,
		temp.resident_last_name,
		temp.resident_first_name
	FROM @orderStatus stat
	INNER JOIN #vpos vpos ON vpos.order_status = stat.status
	INNER JOIN #tempresult temp ON temp.phys_order_id = vpos.phys_order_id	


SET @step = @step + 1
SET @step_label = 'Apply pagination'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
IF @sortByOrder='desc'
BEGIN
	;WITH TMP AS
	(
		SELECT ROW_NUMBER() OVER(ORDER BY
									 CASE
										WHEN @sortByColumn = 'fac_id' THEN CONVERT(VARCHAR(50), o.fac_id)
										WHEN @sortByColumn = 'description' THEN o.description
										WHEN @sortByColumn = 'client_id' THEN CONVERT(VARCHAR(50), o.resident_first_name)
										ELSE CONVERT(VARCHAR(50), o.phys_order_id)
									END
									DESC,
									CASE
										WHEN @sortByColumn = 'client_id' THEN CONVERT(VARCHAR(50), o.resident_last_name)
										ELSE CONVERT(VARCHAR(50), o.phys_order_id)
									END
									DESC,
									o.phys_order_id DESC) AS rn FROM #orders_data o
	)
	DELETE FROM TMP WHERE @pageSize > 0 AND (rn <= (@pageSize * (@pageNumber-1)) OR rn > (@pageSize * @pageNumber))
END
ELSE
BEGIN
	;WITH TMP AS
	(
		SELECT ROW_NUMBER() OVER(ORDER BY
										CASE
										WHEN @sortByColumn = 'fac_id' THEN CONVERT(varchar(50), o.fac_id)
										WHEN @sortByColumn = 'description' THEN o.description										
										WHEN @sortByColumn = 'client_id' THEN CONVERT(VARCHAR(50), o.resident_first_name)
										ELSE CONVERT(VARCHAR(50), o.phys_order_id)
									END
									ASC,
									CASE
										WHEN @sortByColumn = 'client_id' THEN CONVERT(VARCHAR(50), o.resident_last_name)
										ELSE CONVERT(VARCHAR(50), o.phys_order_id)
									END
									ASC,
									o.phys_order_id DESC) AS rn FROM #orders_data o
	)
	DELETE FROM TMP WHERE @pageSize > 0 AND (rn <= (@pageSize * (@pageNumber-1)) OR rn > (@pageSize * @pageNumber))

END


    /****************************************
    return final result
    ****************************************/
SET @step = @step + 1	
SET @step_label = 'Return final results...'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text

SET @step = @step + 1	
SET @step_label = 'Return orders'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
IF @includeOrders = 1
BEGIN
	SELECT
	o.phys_order_id,
	o.fac_id,
	f.fac_uuid,
	o.client_id,
	o.order_status,
	o.description,
	lib.pho_ext_lib_id,
	lib.pho_ext_lib_med_id,
	lib.pho_ext_lib_med_ddid,
	o.resident_first_name,
	o.resident_last_name	
	FROM #orders_data o
	INNER JOIN @facInfo f ON f.fac_id = o.fac_id
	LEFT JOIN pho_order_ext_lib_med_ref lib ON lib.phys_order_id = o.phys_order_id
	ORDER BY o.fac_id, o.phys_order_id ASC
END
ELSE
BEGIN
	IF @includeOrders = 2
	BEGIN
		SELECT
		o.phys_order_id,
		o.fac_id,
		f.fac_uuid,
		o.client_id,
		o.physician_id,
		c.first_name AS physician_first_name,
		c.last_name AS physician_last_name,
		c.title AS physician_title,
		o.order_category_id,
		o.communication_method,
		o.route_of_admin,
		roa.pcc_route_of_admin AS route_of_admin_desc,
		o.order_status,
		o.description,
		lib.pho_ext_lib_id,
		lib.pho_ext_lib_med_id,
		lib.pho_ext_lib_med_ddid,
		lib.pho_ext_lib_generic_id,
		lib.pho_ext_lib_generic_desc,
		lib.ext_lib_rxnorm_id,
		o.resident_first_name,
		o.resident_last_name,
		o.created_by,
		o.created_date,
		o.revision_by,
		o.revision_date
		FROM #orders_data o
		INNER JOIN @facInfo f ON f.fac_id = o.fac_id
		INNER JOIN wesreference.dbo.pho_std_route_of_admin roa ON roa.route_of_admin_id = o.route_of_admin
		LEFT JOIN contact c ON c.contact_id = o.physician_id		
		LEFT JOIN pho_order_ext_lib_med_ref lib ON lib.phys_order_id = o.phys_order_id
		ORDER BY o.fac_id, o.phys_order_id ASC
	END
	ELSE
		SELECT 'ORDER DATA NOT REQUESTED'
END

SET @step = @step + 1	
SET @step_label = 'Return schedules'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
IF @includeSchedules = 1
BEGIN
	SELECT
	o.phys_order_id,
	s.order_schedule_id,
	s.schedule_directions
	FROM #orders_data o
	INNER JOIN PHO_ORDER_SCHEDULE s ON s.phys_order_id = o.phys_order_id
	WHERE s.deleted = 'N'
	ORDER BY o.fac_id, o.phys_order_id, s.order_schedule_id
END
ELSE
BEGIN
	IF @includeSchedules = 2	
	BEGIN	
		SELECT
		os.phys_order_id,
		os.order_schedule_id,
		os.schedule_template,
		os.dose_value,
		os.dose_uom_id,
		os.alternate_dose_value,
		os.dose_low,
		os.quantity_per_dose,
		os.quantity_uom_id,
		os.need_location_of_admin,
		os.sliding_scale_id,
		os.apply_to,
		os.apply_remove_flag,
		os.std_freq_id,
		os.schedule_type,
		sched_type.description AS schedule_type_desc,
		os.repeat_week,
		os.mon,
		os.tues,
		os.wed,
		os.thurs,
		os.fri,
		os.sat,
		os.sun,
		os.xxdays,
		os.xxmonths,
		os.xxhours,
		os.date_of_month,
		os.date_start,
		os.date_stop,
		os.days_on,
		os.days_off,
		os.pho_std_time_id,
		os.related_diagnosis,
		os.indications_for_use,
		os.additional_directions,
		os.administered_by_id,
		admined_by.description AS administered_by_desc,
		os.schedule_start_date,
		os.schedule_end_date,
		os.schedule_end_date_type_id,
		sched_end_date_type.name AS schedule_end_date_type_name,
		os.schedule_duration,
		os.schedule_duration_type_id,
		sched_duration_type.name AS schedule_duration_type_name,
		os.schedule_dose_duration,
		os.prn_admin,
		os.prn_admin_value,
		os.prn_admin_units,
		os.schedule_directions,
		os.created_by,
		os.created_date,
		os.revision_by,
		os.revision_date,		
		--os.std_freq_time_label,
		--os.until_finished,
		--os.order_type_id,
		--os.extended_end_date,
		--os.extended_count,
		--os.prescriber_schedule_start_date,		
		ps.order_schedule_id,
		ps.schedule_id,
		ps.start_time,
		ps.end_time,
		ps.std_shift_id,
		ps.remove_time,
		ps.remove_duration,
		ps.nurse_action_notes
		FROM #orders_data o
		INNER JOIN PHO_ORDER_SCHEDULE os ON os.phys_order_id = o.phys_order_id
		INNER JOIN PHO_SCHEDULE ps ON ps.order_schedule_id = os.order_schedule_id
		INNER JOIN pho_schedule_type sched_type ON sched_type.schedule_type_id = os.schedule_type
		INNER JOIN pho_std_administered_by admined_by ON admined_by.administered_by_id = os.administered_by_id
		INNER JOIN pho_schedule_end_date_type sched_end_date_type ON sched_end_date_type.schedule_end_date_type_id = os.schedule_end_date_type_id
		LEFT JOIN pho_schedule_duration_type sched_duration_type ON sched_duration_type.schedule_duration_type_id = os.schedule_duration_type_id
		WHERE os.deleted = 'N' and ps.deleted = 'N'
		ORDER BY o.fac_id, o.phys_order_id, os.order_schedule_id		
	END
	ELSE
		SELECT 'SCHEDULES DATA NOT REQUESTED'
END

SET @step = @step + 1	
SET @step_label = 'Return changeset'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
IF @includeChangesets = 1
BEGIN
	SELECT
	o.phys_order_id,
	cs.changeset_id,
	cs.changeset_type_id,
	cs.current_status_id,
	cs.changeset_source_id
	FROM #orders_data o
	INNER JOIN pho_phys_order_changeset cs ON cs.phys_order_id = o.phys_order_id
	INNER JOIN @changesetTypes cst ON cst.changeset_type_id = cs.changeset_type_id
	INNER JOIN changeset_status csstat ON csstat.changeset_status_id = cs.current_status_id
	INNER JOIN @changesetStatuses csstats ON csstats.status_id = csstat.status_id
	WHERE @changesetSourceId IS NULL OR cs.changeset_source_id = @changesetSourceId	
END
ELSE
BEGIN
	IF @includeChangesets = 2
	BEGIN
		SELECT
		o.phys_order_id,
		cs.changeset_id,
		cs.changeset_type_id,
		cs.current_status_id,
		cs.changeset_source_id,
		cs.changeset_data,
		cs.resulting_phys_order_id,
		cs.aggregate_changeset_id,
		csstat.status_source,
		csstat.status_by,
		csstat.status_date
		FROM #orders_data o
		INNER JOIN pho_phys_order_changeset cs ON cs.phys_order_id = o.phys_order_id
		INNER JOIN @changesetTypes cst ON cst.changeset_type_id = cs.changeset_type_id
		INNER JOIN changeset_status csstat ON csstat.changeset_status_id = cs.current_status_id
		INNER JOIN @changesetStatuses csstats ON csstats.status_id = csstat.status_id
		WHERE @changesetSourceId IS NULL OR cs.changeset_source_id = @changesetSourceId	
	END
	ELSE
		SELECT 'CHANGESET DATA NOT REQUESTED'
END

    SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' Done'
    IF @debug='Y'
        PRINT @status_text
    SET @status_code = 0
    GOTO PgmSuccess
END TRY
--error trapping
BEGIN CATCH
    --SELECT @error_code = @@error, @status_text = 'Error at step:'+convert(varchar(3),@step)+', '+ERROR_MESSAGE()
	SELECT @error_code = @@error, @status_text = 'Error at step:' + convert(varchar(3),@step) + ' <' + @step_label + '>, '+ERROR_MESSAGE()

    SET @status_code = 1

    GOTO PgmAbend

END CATCH

--program success return
PgmSuccess:

IF @status_code = 0
BEGIN
    IF @debug='Y' PRINT 'Successfull execution of stored procedure'
    RETURN @status_code
END

--program failure return
PgmAbend:

--IF @debug='Y' PRINT 'Stored procedure failure in step:'+ convert(varchar(3),@step) + '   ' + convert(varchar(26),getdate())
IF @debug='Y' PRINT 'Stored procedure failure in step:'+ convert(varchar(3),@step) + ' <' + @step_label + '>   ' + convert(varchar(26),getdate())
    IF @debug='Y' PRINT 'Error code: '+convert(varchar(3),@error_code) + '; Error description:    ' +@status_text
    RETURN @status_code

GO
GRANT EXECUTE ON sproc_sprt_order_list TO public
GO


GO

print 'A_PreUpload/CORE-97108 - DDL - update sproc_sprt_order_list.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97108 - DDL - update sproc_sprt_order_list.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97188- DDL - Add column to the debug table and add a table for log.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

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




-- CORE-97188	
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
--As part of the pho_Schedule_details acrhiving process making required changes to the azure_data_archive_pipeline_steps_debug
--
-- =================================================================================


----Handling the changes for the table azure_data_archive_pipeline_steps_debug


IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='azure_data_archive_pipeline_steps_debug'
AND COLUMN_NAME='pipeline_audit_id')

BEGIN
ALTER TABLE azure_data_archive_pipeline_steps_debug
ADD pipeline_audit_id INT---PHI:N Desc: Holds the audit id for eache execution
END


IF NOT EXISTS  (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='azure_data_archive_pipeline_merge_log_dump')
BEGIN


----Creating the merger log activity table for the merged files
CREATE TABLE azure_data_archive_pipeline_merge_log_dump
(
dump_id INT IDENTITY (1,1) NOT NULL,  --:PHI=N:Desc: Internal   Unique id for the logging items 
master_file_id INT NOT NULL, --:PHI=N:Desc: The master file for which the log exists
time_logged	DATETIME NOT NULL, --:PHI=N:Desc: Time when it was logged
detail_id SMALLINT NOT NULL, --:PHI=N:Desc: The detail id for the each controller 
pipeline_audit_id INT NOT NULL, --:PHI=N:Desc: The pipeline audit id for each execution
[level]	VARCHAR(15) NOT NULL , --:PHI=N:Desc: What is the level of the logging
operation_name	VARCHAR(25)NOT NULL, --:PHI=N:Desc: Operation type for the logging
operation_item	VARCHAR(200) NOT NULL, --:PHI=N:Desc:Items on which the operation was performed
[message]VARCHAR(5000) NOT NULL, --:PHI=N:Desc: Message for the logging process
	  CONSTRAINT [azure_data_archive_pipeline_merge_log_dump_dumpId_PK_CL_IX] PRIMARY KEY CLUSTERED 
(
   dump_id
)
)

END




GO

print 'A_PreUpload/CORE-97188- DDL - Add column to the debug table and add a table for log.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97188- DDL - Add column to the debug table and add a table for log.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

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
values ('4.4.8_A', 'upload_history')


GO

print '..\Update db version.sql --****SCRIPT DONE****'

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking (script,timestamp,upload) values ('UPLOAD END',getdate(),'4.4.8_06_CLIENT_A_PreUpload_US.sql')