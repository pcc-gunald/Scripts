SET NOCOUNT ON
GO

SET DEADLOCK_PRIORITY HIGH
GO


insert into upload_tracking (script, timestamp, upload) values ('UPLOAD_START',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/01 - CORE-100150 - DDL - sproc_sprt_order_list.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

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
CREATE PROCEDURE [dbo].[sproc_sprt_order_list]			@facUUIdCSV             VARCHAR(MAX),-- Required: CSV list of fac uuids to filter on
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



AS
BEGIN TRY
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

DECLARE @step                       			int,
		@step_label								varchar(100),
        @error_code                 			int,
		@num_records							int

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
	controlled_substance_code 	VARCHAR(50),

    order_type_id INT,
	physician_id INT,
	alter_med_src INT,
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
	nurse_pharm_notes VARCHAR(512),
	related_generic VARCHAR(250),
	communication_method INT,
	prescription VARCHAR(50),
	disp_package_identifier VARCHAR(50),
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
	controlled_substance_code VARCHAR(50),
	facility_time datetime,
	IsDischargeEnabled  BIT,

    order_type_id INT,
	physician_id INT,
	alter_med_src INT,
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
	nurse_pharm_notes VARCHAR(512),
	related_generic VARCHAR(250),
	communication_method INT,
	prescription VARCHAR(50),
	disp_package_identifier VARCHAR(50),
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

    order_type_id,
	physician_id,
	alter_med_src,
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
	nurse_pharm_notes,
	related_generic,
	communication_method,
	prescription,
	disp_package_identifier,
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
	    o.order_type_id,
		o.physician_id,
		o.alter_med_src,
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
		o.nurse_pharm_notes,
		o.related_generic,
		o.communication_method,
		o.prescription,
		o.disp_package_identifier,
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
    order_type_id,
	physician_id,
	alter_med_src,
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
	nurse_pharm_notes,
	related_generic,
	communication_method,
	prescription,
	disp_package_identifier,
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
	    temp.order_type_id,
		temp.physician_id,
		temp.alter_med_src,
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
		temp.nurse_pharm_notes,
		temp.related_generic,
		temp.communication_method,
		temp.prescription,
		temp.disp_package_identifier,
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
select @num_records = count(1) from #orders_data
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
	o.resident_last_name,
	o.created_date,
	o.revision_date
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
		o.order_type_id,
        ot.description AS order_type_desc,
		o.physician_id,
		s.identifier_npi,
		c.first_name AS physician_first_name,
		c.last_name AS physician_last_name,
		c.title AS physician_title,
		o.order_category_id,
		o.communication_method,
		o.order_date,
		o.start_date,
		o.end_date,
		o.directions,
		o.nurse_pharm_notes,
		o.route_of_admin,
		roa.pcc_route_of_admin AS route_of_admin_desc,
		o.order_status,
		o.description,
		o.form,
		o.drug_strength,
		o.drug_strength_uom,
		o.prescription,
		o.disp_package_identifier,
		qi.no_of_refills,
		lib.pho_ext_lib_id,
		lib.pho_ext_lib_med_id,
		lib.pho_ext_lib_med_ddid,
		lib.pho_ext_lib_generic_id,
		lib.pho_ext_lib_generic_desc,
		lib.ext_lib_rxnorm_id,
		o.resident_first_name,
		o.resident_last_name,
		o.controlled_substance_code,
		o.alter_med_src,
		o.pharmacy_id,
		ext_facs.name AS pharmacy_name,
		o.created_by,
		o.created_date,
		o.revision_by,
		o.revision_date
		FROM #orders_data o
		INNER JOIN @facInfo f ON f.fac_id = o.fac_id
		LEFT JOIN wesreference.dbo.pho_std_route_of_admin roa ON roa.route_of_admin_id = o.route_of_admin
		LEFT JOIN pho_phys_order_quantity_info qi ON qi.phys_order_id = o.phys_order_id
		LEFT JOIN contact c ON c.contact_id = o.physician_id
		LEFT JOIN staff s ON s.contact_id = c.contact_id AND (s.fac_id = o.fac_id OR s.fac_id = -1)
		LEFT JOIN pho_order_ext_lib_med_ref lib ON lib.phys_order_id = o.phys_order_id
		LEFT JOIN emc_ext_facilities ext_facs ON ext_facs.ext_fac_id = o.pharmacy_id
        LEFT JOIN pho_order_type ot ON ot.order_type_id = o.order_type_id
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
		ps.schedule_id,
		ps.start_time,
		ps.end_time,
		ps.std_shift_id,
		ps.remove_time,
		ps.remove_duration,
		ps.nurse_action_notes,
        ssr.low_value,
        ssr.high_value,
        ssr.dose AS sliding_scale_dose,
        ssr.directions AS sliding_scale_directions
		FROM #orders_data o
		INNER JOIN PHO_ORDER_SCHEDULE os ON os.phys_order_id = o.phys_order_id
		INNER JOIN PHO_SCHEDULE ps ON ps.order_schedule_id = os.order_schedule_id
		INNER JOIN pho_schedule_type sched_type ON sched_type.schedule_type_id = os.schedule_type
		INNER JOIN pho_std_administered_by admined_by ON admined_by.administered_by_id = os.administered_by_id
		INNER JOIN pho_schedule_end_date_type sched_end_date_type ON sched_end_date_type.schedule_end_date_type_id = os.schedule_end_date_type_id
		LEFT JOIN pho_schedule_duration_type sched_duration_type ON sched_duration_type.schedule_duration_type_id = os.schedule_duration_type_id
        LEFT JOIN pho_order_sliding_scale_range ssr ON ssr.order_schedule_id = os.order_schedule_id
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
	cs.changeset_source_id,
	csstat.status_id
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
		cs.changeset_source_id,
		cs.changeset_data,
		cs.resulting_phys_order_id,
		cs.aggregate_changeset_id,
		cs.created_by,
		cs.created_date,		
		csstat.status_id,
		csstat.status_source,
		csstat.status_reason,
		csstat.notes,
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
SET @step = @step + 1	
SET @step_label = 'Return total record number'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text

select @num_records as total_record_number

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

print 'A_PreUpload/01 - CORE-100150 - DDL - sproc_sprt_order_list.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/01 - CORE-100150 - DDL - sproc_sprt_order_list.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-100157 - 01 - DML -  delete sec_function record from pcc_global_primary_key.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

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
-- CORE-100157
--
-- Written By:       delete sec_function record from pcc_global_primary_key
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
--   after discuss with Carlos, we decided to delete sec_function record 
--   from pcc_global_primary_key since sec_function doesn't use  pcc_global_primary_key table
--=======================================================================================================================

if  exists( select 1
	from pcc_global_primary_key where table_name='sec_function')
begin
	delete from pcc_global_primary_key  where table_name='sec_function'
end 

GO

print 'A_PreUpload/CORE-100157 - 01 - DML -  delete sec_function record from pcc_global_primary_key.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-100157 - 01 - DML -  delete sec_function record from pcc_global_primary_key.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-100157 - 02 - DML - Add security function for displaying private balances - Admin.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

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
-- CORE-100157
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
--     * 1020.006: View Outstanding Balance in Resident Search
--
--   URL: http://vmusnpdvshsg01/create?scriptType=I&issueKey=CORE-100157&moduleId=1&functionUpdates%5B1%5D.funcId=1020.006&functionUpdates%5B1%5D.parentId=1020.0&functionUpdates%5B1%5D.sequenceNo=1020.006&functionUpdates%5B1%5D.description=View+Outstanding+Balance+in+Resident+Search&functionUpdates%5B1%5D.environment=&functionUpdates%5B1%5D.accessType=YN&functionUpdates%5B1%5D.accessLevel=0&functionUpdates%5B1%5D.accessCopyFromFuncId=&functionUpdates%5B1%5D.accessCopyFromDefault=0&functionUpdates%5B1%5D.systemRoleAccess%5B%271%27%5D=4&functionUpdates%5B1%5D.systemRoleAccess%5B%273%27%5D=4&functionUpdates%5B1%5D.systemRoleAccess%5B%275%27%5D=4&functionUpdates%5B1%5D.systemRoleAccess%5B%271515%27%5D=-999&functionUpdates%5B1%5D.systemRoleAccess%5B%271000%27%5D=-999&functionUpdates%5B1%5D.systemRoleAcce
--        ss%5B%271714%27%5D=4&functionUpdates%5B1%5D.systemRoleAccess%5B%271715%27%5D=4&functionUpdates%5B1%5D.systemRoleAccess%5B%271795%27%5D=4&functionUpdates%5B1%5D.systemRoleAccess%5B%271807%27%5D=-999
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
SET @createdBy = 'CORE-100157'


--========================================================================================================
-- 1020.006: View Outstanding Balance in Resident Search
--========================================================================================================

-- (1) Prepare @sec_function__ins ===========================================================
INSERT INTO @sec_function__ins (func_id, deleted, created_by, created_date, module_id, [type], description, parent_function, sequence_no, facility_type)
	VALUES ('1020.006', 'N', @createdBy, @NOW, @moduleId, 'YN', 'View Outstanding Balance in Resident Search', 'N', 1020.006, NULL)


-- (2) Prepare @sec_role_function__ins ======================================================

-- (2a) Add new function to all appropriate roles ------------------------------
INSERT INTO @sec_role_function__ins (role_id, func_id, created_by, created_date, revision_by, revision_date, access_level)
	SELECT DISTINCT role_id, '1020.006', @createdBy, @NOW, NULL, NULL, 0 FROM sec_role r
	WHERE @moduleId = 10 -- new functions in the "All" module are applicable to every role
		OR (module_id = @moduleId AND description <> 'Collections Setup (system)' AND description <> 'Collections User (system)')
		OR (module_id = 0 AND EXISTS (SELECT 1 FROM sec_role_function rf INNER JOIN sec_function f ON rf.func_id = f.func_id WHERE f.module_id = @moduleId AND rf.role_id = r.role_id))




-- (2c) Default Permissions: Set System Roles ----------------------------------
UPDATE @sec_role_function__ins SET access_level = 4 WHERE func_id = '1020.006' AND role_id IN (SELECT role_id FROM sec_role WHERE system_field = 'Y' AND description IN ('Admin Setup Role (system)', 'AL/IL Billing Security Role (system)', 'AL/IL Billing User (system)', 'AL/IL Billing Setup Role (system)', 'Admin Role (system)', 'Admin Security Role (system)'))



--========================================================================================================
-- Apply changes
--========================================================================================================
BEGIN TRAN

BEGIN TRY

	DELETE FROM sec_function WHERE func_id IN ('1020.006')
	DELETE FROM sec_role_function WHERE func_id IN ('1020.006')

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

print 'A_PreUpload/CORE-100157 - 02 - DML - Add security function for displaying private balances - Admin.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-100157 - 02 - DML - Add security function for displaying private balances - Admin.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-100157 - 03 - DML - Add security function for displaying private balances - Clinical.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

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
-- CORE-100157
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
--     * 5010.006: View Outstanding Balance in Resident Search
--
--   URL: http://vmusnpdvshsg01/create?scriptType=I&issueKey=CORE-100157&moduleId=2&functionUpdates%5B1%5D.funcId=5010.006&functionUpdates%5B1%5D.parentId=5010.0&functionUpdates%5B1%5D.sequenceNo=5010.006&functionUpdates%5B1%5D.description=View+Outstanding+Balance+in+Resident+Search&functionUpdates%5B1%5D.environment=&functionUpdates%5B1%5D.accessType=YN&functionUpdates%5B1%5D.accessLevel=0&functionUpdates%5B1%5D.accessCopyFromFuncId=&functionUpdates%5B1%5D.accessCopyFromDefault=0&functionUpdates%5B1%5D.systemRoleAccess%5B%274%27%5D=-999&functionUpdates%5B1%5D.systemRoleAccess%5B%272%27%5D=-999&functionUpdates%5B1%5D.systemRoleAccess%5B%271716%27%5D=-999&functionUpdates%5B1%5D.systemRoleAccess%5B%271717%27%5D=-999
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
SET @moduleId = 2
SET @createdBy = 'CORE-100157'
--========================================================================================================
-- 5010.006: View Outstanding Balance in Resident Search
--========================================================================================================
-- (1) Prepare @sec_function__ins ===========================================================
INSERT INTO @sec_function__ins (func_id, deleted, created_by, created_date, module_id, [type], description, parent_function, sequence_no, facility_type)
    VALUES ('5010.006', 'N', @createdBy, @NOW, @moduleId, 'YN', 'View Outstanding Balance in Resident Search', 'N', 5010.006, NULL)
-- (2) Prepare @sec_role_function__ins ======================================================
-- (2a) Add new function to all appropriate roles ------------------------------
INSERT INTO @sec_role_function__ins (role_id, func_id, created_by, created_date, revision_by, revision_date, access_level)
    SELECT DISTINCT role_id, '5010.006', @createdBy, @NOW, NULL, NULL, 0 FROM sec_role r
    WHERE @moduleId = 10 -- new functions in the "All" module are applicable to every role
        OR (module_id = @moduleId AND description <> 'Collections Setup (system)' AND description <> 'Collections User (system)')
        OR (module_id = 0 AND EXISTS (SELECT 1 FROM sec_role_function rf INNER JOIN sec_function f ON rf.func_id = f.func_id WHERE f.module_id = @moduleId AND rf.role_id = r.role_id))
--========================================================================================================
-- Apply changes
--========================================================================================================
BEGIN TRAN
BEGIN TRY
    DELETE FROM sec_function WHERE func_id IN ('5010.006')
    DELETE FROM sec_role_function WHERE func_id IN ('5010.006')
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

print 'A_PreUpload/CORE-100157 - 03 - DML - Add security function for displaying private balances - Clinical.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-100157 - 03 - DML - Add security function for displaying private balances - Clinical.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-100338-DDL-ar_cash_data_integrity_error_detail-Add-unapplied_cash_total-column.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

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


-- CORE-99214	
-- Written By:           Shawn Song
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
--                       unapplied cash total amount on checking transaction payment amount
--                       
-- =================================================================================

IF EXISTS (SELECT 1 FROM information_schema.tables
           WHERE table_name = 'ar_cash_data_integrity_error_detail'
           AND table_schema = 'dbo')
BEGIN
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME='unapplied_cash_total' AND TABLE_NAME='ar_cash_data_integrity_error_detail' )
    BEGIN
        ALTER TABLE ar_cash_data_integrity_error_detail
        ADD unapplied_cash_total MONEY NULL --:PHI=N:Desc:unapplied cash total amount on checking cash amount vs payment amount
    END
END

GO

print 'A_PreUpload/CORE-100338-DDL-ar_cash_data_integrity_error_detail-Add-unapplied_cash_total-column.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-100338-DDL-ar_cash_data_integrity_error_detail-Add-unapplied_cash_total-column.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-94344 - DDL - sproc_pho_list_getEnhancedOrder.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

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


 -- ===============================================================================================================================
 -- ---------------
 -- Deprecated
 --	---------------
 -- 
 -- Purpose: The purpose of this procedure is to load a phys order with all it's schedule information
 --
 -- Target ENVIRONMENT: BOTH 
 --
 --  Special Instructions: 
 --
 --	Params:
 --			
 --			@physOrderId    - phys order id
 --			@facId			- Facility Id 
 --			@includeAdministrativeOrder - Flag to include Administrative Orders, 'Y' or 'N'
 --			@includeSupplyInfo - Flag to include Supply Info, 'Y' or 'N'
 --			@debug          - Debug param, 'Y' or 'N'
 --			@status_code    - SP execution flag, 0 for success.
 --			@status_text    - SP error text if error occurs.
 --
 -- Change History:
 --   Author			Date		Comment
 -- ------------------------------------------------------------------------------------------------------------------------------- 
 --	  Joel Pelletier    08/11/2011	Created.
 --   Alireza Mandegar	10/15/2012	Updated due to PCC-33677 and Replaced the usage of fn_pho_getOrderStatus with sproc_pho_getOrderStatus
 --									Also modified the file maintenance box to be in sql comment format rather than java format
 --									and added the Change History section to it to keep track of changes.
 --  Alireza Mandegar	 11/12/2012	Added pho_ext_lib_generic_desc/id for PCC-34329
 --  Alireza Mandegar	 11/22/2012	Added schedule_sliding_scale_id due to PCC-30715
 --  Alireza Mandegar	 11/29/2012	Added schedule_dose_duration due to PCC-32538
 --  Feng Xia			 12/15/2012	Added xxMonths
 --  Alireza Mandegar	 12/20/2012	Added apply_remove_flag due to PCC-32537
 --  Alireza Mandegar	 01/25/2013	Added remove_time due to PCC-32537
 --  Alireza Mandegar	 01/31/2013	Added remove_duration due to PCC-32537
 --  Aarti Malhotra      09/24/2013  Added pho_ext_lib_rxnorm for PCC-47251 (main JIRA PCC-46704)
 --  Mustafa Behrainwala 04/28/2014  Added table to handle Therapeutic Interchange sliding scale PCC-52492 
 --  Mustafa Behrainwala 07/31/2014  Added Linked Set Id and Description for PCC-59209
 --	 Mustafa Behrainwala 10/29/2015	 Added order_class_id
 --  Willie Wong		 05/11/2016	 Added schedule_directions for dietary orders for PCC-94151
 --	 Nooshin Hayeri		 06/29/2016	Added snapshot_schedule_start_date for PCC-96359
 --  Melvin Parinas      07/16/2016  Removed snapshot_schedule_start_date and replaced with earliest_prescriber_start_date date PCC-96359
 --  Melvin Parinas      07/25/2016  Added prescriber_schedule_start_date due to PCC-98059	
 --	 Devika Bapat		 02/24/2017	Added 2 optional parameters to include administrative orders and supply info PCC-108894
 --	 Mustafa Behrainwala 10/12/2018 Modified due to CORE-23367 to add dose_low for dose ranging.
 --	 Elias Ghanem 		 12/21/2018 	Added last_pharmacy_end_date due to CORE-28433.
 --  Mustafa Behrainwala 01/29/2019 Modified due to CORE-29190 return behavior lookup
 --  Elias Ghanem 		 01/29/2019 Added schedule_revision_date due to CORE-85435
 --  Sree Naghasundharam 11/18/2021 This Stored Procedure 'sproc_pho_list_getEnhancedOrder' is herebry deprecated(CORE-97119).
 --									New stored procedure 'sproc_pho_list_getEnhancedOrder_v2' created to remove 'mmdb' references.
 --									Any further changes to 'sproc_pho_list_getEnhancedOrder' should also be made in the new stored procedure.
 --  Elias Ghanem 		 01/26/2022 use temp table to enhance performance CORE-94344
 -- ===============================================================================================================================

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sproc_pho_list_getEnhancedOrder]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [dbo].[sproc_pho_list_getEnhancedOrder]
GO

create 
proc sproc_pho_list_getEnhancedOrder
(
	@physOrderId	int,
	@facId			int,
	@includeAdministrativeOrder	char(1) = 'N',
	@includeSupplyInfo char(1) = 'N',
	@debug char(1)  = 'N',
	@status_code int out, 
	@status_text varchar(3000) out
)
as 
begin

SET NOCOUNT ON

DECLARE @step			int,
		@error_code		int

	   

BEGIN TRY

    -- PCC-33677
    ----Localize input Variables
    DECLARE  @vFacId int
            ,@vClientId int
            ,@vPhysOrderId int
            ,@vDateTime datetime
			,@vOrderCategory int
        
    -- Set the local variables
    select 
        @vFacId         = @facId 
       ,@vClientId      = null 
	   ,@vPhysOrderId   = @physOrderId
       ,@vDateTime      = dbo.fn_facility_getCurrentTime(@facId)
	   ,@status_code 	= 0
        
    -- Table variable to store the result of sproc_pho_getOrderStatus
    declare @TMP_PhoOrderStatus table (phys_order_id    int
                                    ,fac_id             int
                                    ,order_status       smallint
                                    ,order_relationship int
                                    ,status_reason      varchar(75));
    
	set @vOrderCategory = (select order_category_id from pho_phys_order where phys_order_id=@vPhysOrderId)
	
	-- Check exist in pho_phys_order table, struck out order does not has record in pho_phys_order table, if not exit, there is no need to execute sproc_pho_getOrderStatus
	if @vOrderCategory > 0
	begin
		-- Fill the table variable
		insert into @TMP_PhoOrderStatus
		exec sproc_pho_getOrderStatus 
				@facId          = @vFacId
				,@clientId      = @vClientId
				,@physOrderId   = @vPhysOrderId
				,@date          = @vDateTime
				,@debug         = 'N'
				,@status_code   = @status_code
				,@status_text   = @status_text
	end

	if @debug = 'Y'  select * From @TMP_PhoOrderStatus

	if isnull(@status_code,0) <> 0
		  begin
				set @status_text = 'sproc_pho_getOrderStatus returned the following error: ' + isnull(@status_text,'')
				Raiserror( @status_text, 11, 1 );
		  end

	
	if(@debug='Y') begin Print 'BEGIN STEP select enhanced phys order	' + ' ' + convert(varchar(26),getdate(),109) end

SELECT 
o.phys_order_id
, o.order_type_id
, o.physician_id
, o.pharmacy_id
, o.fac_id
, o.client_id
, o.drug_code
, o.created_by
, o.created_date
, o.revision_by
, o.revision_date
, o.reorder
, o.date_ordered
, o.start_date
, o.end_date
, o.strength
, o.form
, o.route_of_admin
, o.diagnoses
, o.description
, o.directions
, o.related_generic
, o.supplementary_notes
, o.communication_method
, o.diet_type
, diettype.item_description AS diet_type_description
, o.diet_texture
, diettexture.item_description AS diet_texture_description
, o.stat
, o.packaging
, o.disc_with_pharm
, o.quantity_to_administer
, o.std_order_id
, o.discontinued_date
, o.fluid_consistency
, fluidcon.item_description AS fluid_consistency_description
, o.diet_supplement
, dietsup.item_description AS diet_supplement_description
, o.hold_date
, o.nurse_admin_notes
, o.nurse_pharm_notes
, o.delivery_notes
, o.delivery_type
, o.self_admin
, o.administered_by_id
, o.prn_flag
, o.label_name
, o.reorder_count
, o.last_reorder_date
, o.quantity_received
, o.tran_id
, o.prescription
, o.start_date_type
, o.end_date_type
, o.end_date_duration_type
, o.end_date_duration
, o.schedule_dose_duration -- PCC-32538
, o.alter_med_src
, o.alter_med_src_name
, o.sent_date
, vpos.order_status
, o.status_change_by
, o.status_change_date
, o.hold_physician_id
, o.discontinue_physician_id
, o.pharm_nurse_notes
, o.first_admin
, o.drug_manufacturer
, o.drug_class_number
, o.resume_physician_id
, o.event_driven_flag
, o.auto_fill_flag
, o.controlled_substance_code
, o.related_phys_order_id
, o.relationship
, o.auto_created_flag
, o.active_flag
, o.new_supply_flag
, o.resume_date
, o.last_received_date
, o.orig_phys_order_id
, o.disp_package_identifier
, o.hold_date_end
, o.vendor_phys_order_id
, o.order_date
, o.sliding_scale_id
, o.order_verified
, o.dispense_as_written
, o.next_refill_date
, o.do_not_fill
, o.cur_supply_id
, o.first_documented
, o.substitution_indicator
, o.reassessment_required
, o.completed_date
, o.completed_by
, o.verify_copied_order
, o.original_route_of_admin
, o.indications_for_use
, o.draft
, o.origin_id
, o.order_category_id
, o.order_revision_date
, o.order_revision_by
, o.drug_strength
, o.drug_strength_uom
, o.drug_name
, o.is_new_order
, o.order_schedule_id
, o.start_date as schedule_start_date
, o.end_date as schedule_end_date
, o.last_pharmacy_end_date
, o.physician_name_in_msg
, s.schedule_id
, s.schedule_type
, s.pho_std_time_id
, s.xxdays as xx_days
, s.sun
, s.mon
, s.tues as tue
, s.wed
, s.thurs as thu
, s.fri
, s.sat
, s.days_on
, s.days_off
, s.std_freq_id
, s.dose AS dose_value
, s.dose_low
, s.alternate_dose
, s.start_time
, s.end_time
, s.nurse_action_notes
, s.date_start
, s.date_stop
, s.repeat_week
, s.apply_to
, s.prn_admin
, s.prn_admin_value
, s.prn_admin_units
, s.std_freq_time_label
, s.until_finished
, s.quantity_uom_id
, s.dose_uom_id
, case 
       -- diet orders do not populate the view_pho_schedule need to get directly from the pho_order_schedule table
       when  s.schedule_directions is null and o.order_category_id = 3031 then o.schedule_directions 
       else s.schedule_directions
end as schedule_directions
, o.order_directions as order_directions
, s.schedule_template
, s.xxMonths
, s.date_of_month
, s.std_shift_id
, s.schedule_sliding_scale_id
, s.apply_remove_flag
, s.remove_time
, s.remove_duration
, s.behavior_lookback
, o.schedule_revision_date
, c.first_name AS physician_first_name
, c.last_name AS physician_last_name
, c.title + ' ' + c.first_name + ' ' + c.last_name AS physician_fullname
, cb.long_username AS created_by_long
, rb.long_username AS revision_by_long
, poua.edited_by_audit_id
, poua.edited_date
, poua.created_by_audit_id
, edituser.long_username AS edited_by_long
, edituser.position_description AS edited_by_position
, edituser.designation_desc AS edited_by_designation
, createuser.long_username AS created_by_audit_long
, createuser.position_description AS created_by_position
, createuser.designation_desc AS created_by_designation
, poua.confirmed_by_audit_id
, poua.confirmed_date
, confuser.long_username AS confirmed_by_long
, confuser.position_description AS confirmed_by_position
, confuser.designation_desc AS confirmed_by_designation
, lib.pho_ext_lib_id
, lib.pho_ext_lib_med_id
, lib.pho_ext_lib_med_ddid
, lib.pho_ext_lib_generic_id
, lib.pho_ext_lib_generic_desc
, lib.ext_lib_rxnorm_id
, o.min_start_date
, o.max_end_date
, o.emergency_pharmacy_flag
, o.need_location_of_admin
, so.advanced_directive as order_advanced_directive
, poad.advanced_dir_status
, pspo.advanced_directive as advanced_directive
, signuser.long_username as signed_by_long
, ppos.signature_date
, o.extended_end_date
, o.extended_count
, custmed.cust_med_id
, ti.orig_phys_order_id as original_ti_phys_order_id
, lsi.linked_set_id as linked_set_id
, ls.set_description as linked_set_description
, nctrlsc.new_controlled_substance_code as new_controlled_substance_code
, esign.marked_to_sign_user_id
, case when marked_to_sign_user_id is not null then dbo.fn_get_username(marked_to_sign_user_id) else null end as marked_to_sign_user_longname
, esign.marked_to_sign_date
, esign.marked_to_sign_contact_id
, esign.marked_to_sign_authentication_type_id
, esign.marked_to_sign_source_type_id
, rstype.description as marked_to_sign_source_type_description
, esign.sign_user_id
, case when sign_user_id is not null then dbo.fn_get_username(sign_user_id) else null end as sign_user_longname
, esign.sign_date
, esign.sign_contact_id
, esign.sign_authentication_type_id
, atype.description as sign_authentication_type_description
, esign.sign_source_type_id
, stype.description as sign_source_type_description
, popr.reason_binary_code
, clinrev.reviewed_date
, clinrev.phys_order_id as review_order_id
, clinrev.reviewed_by
, oq.quantity as prescription_quantity
, oq.unit_of_measure as prescription_quantity_uom
, oq.no_of_refills as prescription_no_of_refills
, o.order_class_id
, o.prescriber_schedule_start_date as earliest_prescriber_start_date
, o.prescriber_schedule_start_date
, o.linked_order_id
, o.linked_reason_id
into #temp
FROM
	view_pho_phys_order o
	LEFT JOIN @TMP_PhoOrderStatus vpos
		ON o.phys_order_id = vpos.phys_order_id
	LEFT JOIN view_pho_schedule s
		ON o.order_schedule_id = s.order_schedule_id AND o.phys_order_id = s.phys_order_id
		AND s.deleted = 'N'
	LEFT JOIN COMMON_CODE diettype
        ON @vOrderCategory=3031 and o.diet_type = diettype.item_id and diettype.item_code = 'phodyt' -- only need for diet order
    LEFT JOIN COMMON_CODE diettexture
        ON @vOrderCategory=3031 and o.diet_texture = diettexture.item_id and diettexture.item_code = 'phodtx' -- only need for diet order
    LEFT JOIN COMMON_CODE dietsup
        ON @vOrderCategory=3032 and o.diet_supplement = dietsup.item_id and dietsup.item_code = 'phosup' -- only need for diet supplement order
    LEFT JOIN COMMON_CODE fluidcon
    	ON @vOrderCategory=3031 and o.fluid_consistency = fluidcon.item_id and fluidcon.item_code = 'phocst' -- only need for diet order
	LEFT JOIN contact c
		ON c.contact_id = o.physician_id
	LEFT JOIN sec_user cb
		ON cb.loginname = o.created_by
	LEFT JOIN sec_user rb
		ON rb.loginname = o.revision_by
	LEFT JOIN pho_phys_order_useraudit poua
		ON poua.phys_order_id = o.phys_order_id
	LEFT JOIN cp_sec_user_audit createuser
	  ON createuser.cp_sec_user_audit_id = poua.created_by_audit_id
	LEFT JOIN cp_sec_user_audit edituser
	  ON edituser.cp_sec_user_audit_id = poua.edited_by_audit_id
	LEFT JOIN cp_sec_user_audit confuser
	  ON confuser.cp_sec_user_audit_id = poua.confirmed_by_audit_id
	LEFT JOIN pho_order_ext_lib_med_ref lib
	  ON @vOrderCategory=3022 and lib.phys_order_id = o.phys_order_id -- only need for pharmacy order
	LEFT JOIN pho_phys_order_std_order templateorder
	  ON @vOrderCategory=3029 and templateorder.phys_order_id = o.phys_order_id -- only need for other category order
	LEFT JOIN  pho_std_order so 
	  ON @vOrderCategory=3029 and templateorder.std_order_id = so.std_order_id -- only need for other category order
	LEFT JOIN pho_std_phys_order pspo
	  ON @vOrderCategory=3029 and o.std_order_id = pspo.std_phys_order_id -- only need for other category order
	LEFT JOIN pho_phys_order_advanced_directive poad
	  ON @vOrderCategory=3029 and o.phys_order_id = poad.phys_order_id -- only need for other category order
	LEFT JOIN pho_phys_order_sign ppos
	  ON o.phys_order_id = ppos.phys_order_id
	LEFT JOIN cp_sec_user_audit signuser
	  ON signuser.cp_sec_user_audit_id = ppos.cp_sec_user_audit_id
	LEFT JOIN pho_phys_order_cust_med custmed
	  ON @vOrderCategory=3022 and custmed.phys_order_id = o.phys_order_id -- only need for pharmacy order
	LEFT JOIN pho_phys_order_ti ti
	  ON ti.phys_order_id = o.phys_order_id
	LEFT JOIN pho_linked_set_item lsi
	  ON lsi.phys_order_id = o.phys_order_id
	LEFT JOIN pho_linked_set ls on ls.linked_set_id = lsi.linked_set_id
	LEFT JOIN pho_phys_order_new_ctrlsubstancecode nctrlsc ON @vOrderCategory=3022 and nctrlsc.phys_order_id=o.phys_order_id -- only need for pharmacy order
	LEFT JOIN pho_phys_order_esignature esign  ON o.phys_order_id = esign.phys_order_id
	LEFT JOIN order_sign_source_type stype ON esign.sign_source_type_id = stype.source_type_id
	LEFT JOIN order_sign_source_type rstype ON esign.marked_to_sign_source_type_id = rstype.source_type_id
	LEFT JOIN order_sign_authentication_type atype ON esign.sign_authentication_type_id = atype.authentication_type_id
	LEFT JOIN pho_order_pending_reason popr ON popr.phys_order_id = o.phys_order_id
    LEFT JOIN pho_order_clinical_review clinrev ON clinrev.phys_order_id=o.phys_order_id 
    LEFT JOIN pho_phys_order_quantity_info oq on @vOrderCategory=3022 and oq.phys_order_id=o.phys_order_id -- only need for pharmacy order

WHERE
	o.phys_order_id = @physOrderId


SELECT
t.phys_order_id
, t.order_type_id
, t.physician_id
, t.pharmacy_id
, t.fac_id
, t.std_freq_id
, t.client_id
, t.drug_code
, t.created_by
, t.created_date
, t.revision_by
, t.revision_date
, t.reorder
, t.date_ordered
, t.start_date
, t.end_date
, t.strength
, t.form
, t.route_of_admin
, t.diagnoses
, t.description
, t.directions
, t.related_generic
, t.supplementary_notes
, t.communication_method
, t.diet_type
, t.diet_type_description
, t.diet_texture
, t.diet_texture_description
, t.stat
, t.packaging
, t.disc_with_pharm
, t.quantity_to_administer
, t.std_order_id
, t.discontinued_date
, t.fluid_consistency
, t.fluid_consistency_description
, t.diet_supplement
, t.diet_supplement_description
, t.hold_date
, t.nurse_admin_notes
, t.nurse_pharm_notes
, t.delivery_notes
, t.delivery_type
, t.self_admin
, t.administered_by_id
, t.prn_flag
, t.label_name
, t.reorder_count
, t.last_reorder_date
, t.quantity_received
, t.tran_id
, t.prescription
, t.start_date_type
, t.end_date_type
, t.end_date_duration_type
, t.end_date_duration
, t.schedule_dose_duration -- PCC-32538
, t.alter_med_src
, t.alter_med_src_name
, t.sent_date
, t.order_status
, t.status_change_by
, t.status_change_date
, t.hold_physician_id
, t.discontinue_physician_id
, t.pharm_nurse_notes
, t.first_admin
, t.drug_manufacturer
, t.drug_class_number
, t.resume_physician_id
, t.event_driven_flag
, t.auto_fill_flag
, t.controlled_substance_code
, t.related_phys_order_id
, t.relationship
, t.auto_created_flag
, t.active_flag
, t.new_supply_flag
, t.resume_date
, t.last_received_date
, t.orig_phys_order_id
, t.disp_package_identifier
, t.hold_date_end
, t.vendor_phys_order_id
, t.order_date
, t.sliding_scale_id
, t.order_verified
, t.dispense_as_written
, t.next_refill_date
, t.do_not_fill
, t.cur_supply_id
, t.first_documented
, t.substitution_indicator
, t.reassessment_required
, t.completed_date
, t.completed_by
, t.verify_copied_order
, t.original_route_of_admin
, t.indications_for_use
, t.draft
, t.origin_id
, t.order_category_id
, t.order_revision_date
, t.order_revision_by
, t.drug_strength
, t.drug_strength_uom
, t.drug_name
, t.is_new_order
, t.order_schedule_id
, t.schedule_start_date
, t.schedule_end_date
, t.last_pharmacy_end_date
, t.physician_name_in_msg
, t.schedule_id
, t.schedule_type
, t.pho_std_time_id
, t.xx_days
, t.sun
, t.mon
, t.tue
, t.wed
, t.thu
, t.fri
, t.sat
, t.days_on
, t.days_off
, t.dose_value
, t.dose_low
, t.alternate_dose
, t.start_time
, t.end_time
, t.nurse_action_notes
, t.date_start
, t.date_stop
, t.repeat_week
, t.apply_to
, t.prn_admin
, t.prn_admin_value
, t.prn_admin_units
, t.std_freq_time_label
, t.until_finished
, t.quantity_uom_id
, t.dose_uom_id
, t.schedule_directions
, t.order_directions
, t.schedule_template
, t.xxMonths
, t.date_of_month
, t.std_shift_id
, t.schedule_sliding_scale_id
, t.apply_remove_flag
, t.remove_time
, t.remove_duration
, t.behavior_lookback
, t.schedule_revision_date
, v.vital
, p.prompt_id
, p.value_type
, p.description as prompt_description
, p.long_description
, p.notes
, p.no_of_values
, p.current_value2
, p.current_value
, p.specify_initial_value
, p.value_data_type
, p.prompt_frequency_type
, p.prompt_frequency
, p.value_date
, pt.short_desc
, t.physician_first_name
, t.physician_last_name
, t.physician_fullname
, t.created_by_long
, t.revision_by_long
, t.edited_by_audit_id
, t.edited_date
, t.created_by_audit_id
, t.edited_by_long
, t.edited_by_position
, t.edited_by_designation
, t.created_by_audit_long
, t.created_by_position
, t.created_by_designation
, t.confirmed_by_audit_id
, t.confirmed_date
, t.confirmed_by_long
, t.confirmed_by_position
, t.confirmed_by_designation
, t.pho_ext_lib_id
, t.pho_ext_lib_med_id
, t.pho_ext_lib_med_ddid
, t.pho_ext_lib_generic_id
, t.pho_ext_lib_generic_desc
, t.ext_lib_rxnorm_id
, t.min_start_date
, t.max_end_date
, t.emergency_pharmacy_flag
, t.need_location_of_admin
, t.order_advanced_directive
, t.advanced_dir_status
, t.advanced_directive
, t.signed_by_long
, t.signature_date
, t.extended_end_date
, t.extended_count
, t.cust_med_id
, t.original_ti_phys_order_id
, t.linked_set_id
, t.linked_set_description
, t.new_controlled_substance_code
, t.marked_to_sign_user_id
, t.marked_to_sign_user_longname
, t.marked_to_sign_date
, t.marked_to_sign_contact_id
, t.marked_to_sign_authentication_type_id
, t.marked_to_sign_source_type_id
, t.marked_to_sign_source_type_description
, t.sign_user_id
, t.sign_user_longname
, t.sign_date
, t.sign_contact_id
, t.sign_authentication_type_id
, t.sign_authentication_type_description
, t.sign_source_type_id
, t.sign_source_type_description
, t.reason_binary_code
, t.reviewed_date
, t.review_order_id
, t.reviewed_by
, t.prescription_quantity
, t.prescription_quantity_uom
, t.prescription_no_of_refills
, t.order_class_id
, t.earliest_prescriber_start_date
, t.prescriber_schedule_start_date
, t.linked_order_id
, t.linked_reason_id
, poa.facility_medical_attestation_id
from
#temp t
LEFT JOIN pho_order_related_prompt p
ON t.schedule_id = p.schedule_id and p.deleted ='N'
LEFT JOIN pho_order_related_value_type pt
ON p.value_type = pt.type_id
LEFT JOIN pho_schedule_vitals v
ON t.schedule_id = v.schedule_id and v.deleted = 'N'
LEFT JOIN pho_phys_order_attestation poa ON @vOrderCategory=3022 and poa.phys_order_id = t.phys_order_id -- only need for pharmacy order
ORDER BY t.order_schedule_id, t.schedule_id


-- select administrative orders
if @includeAdministrativeOrder='Y'
	select vpao.admin_created_date,
	vpao.admin_order_verified,
	vpao.order_related_id,
	vpao.phys_order_id,
	vpao.standard_phys_order_id,
	vpao.created_by,
	vpao.created_date,
	vpao.revision_by,
	vpao.revision_date,
	vpao.deleted_by,
	vpao.deleted_date,
	vpao.deleted,
	vpao.fac_id,
	vpao.order_relationship_id,
	vpao.admin_communication_method,
	vpao.admin_effective_date,
	vpao.admin_ineffective_date,
	vpao.admin_physician_id,
	vpao.admin_reason,
	vpao.admin_noted_by,
	vpao.admin_physician_first_name,
	vpao.admin_physician_last_name,
	vpao.strikeout_by,
	vpao.strikeout_date,
	vpao.strikeout_reason_code,
	vpao.strikeout_reason_description,
	vpao.strikeout_by_long,
	vpao.admin_order_id,
	vpao.admin_origin_id,
	secuser.long_username 'created_by_long' , secuser.designation_desc as created_by_designation, ccc.item_description as created_by_position
	,csua.long_username confirmed_by_username, csua.position_description as confirmed_by_position, csua.designation_desc as confirmed_by_designation, ua.confirmed_date as confirmed_date
	FROM view_pho_administrative_order vpao
	left join SEC_USER secuser on secuser.loginname = vpao.created_by
	left join common_code ccc on ccc.item_id = secuser.position_id
	left join pho_admin_order_useraudit ua ON ua.admin_order_id = vpao.admin_order_id
	left join cp_sec_user_audit csua on csua.cp_sec_user_audit_id = ua.confirmed_by_audit_id
	WHERE vpao.standard_phys_order_id = @physOrderId
	ORDER BY vpao.revision_date  DESC

IF @includeSupplyInfo='Y'
BEGIN
	DECLARE @integratedPharmacies TABLE
    (
        pharmacy_id int not null
    )
	INSERT INTO @integratedPharmacies (pharmacy_id)
	select distinct extFacId from (
		SELECT mp.ext_fac_id as extFacId
			FROM message_profile mp WITH (NOLOCK)
			INNER JOIN lib_message_profile lmp WITH (NOLOCK)
				ON lmp.message_profile_id = mp.message_profile_id
			       AND lmp.deleted = 'N' and lmp.is_enabled='Y'
			WHERE mp.is_enabled = 'Y' and mp.is_integrated_pharmacy='Y'
			AND mp.fac_id = @facId
			AND mp.message_protocol_id = 12
			GROUP BY mp.ext_fac_id
		UNION
		SELECT distinct mi.internal_id as extFacId
			FROM map_identifier mi WITH (NOLOCK)
			INNER JOIN lib_message_profile libmp WITH (NOLOCK)
			ON libmp.vendor_code = mi.vendor_code
			AND libmp.deleted = 'N'
			INNER JOIN message_profile mp WITH (NOLOCK)
			ON libmp.message_profile_id = mp.message_profile_id
			WHERE mi.map_type_id = 3 and mp.fac_id = @facId and  mi.fac_id = @facId
	) a where extFacId is not null

select pos.phys_order_id,
        pos.order_supply_id,
        pos.description as supply_description,
        pos.directions as supply_directions,
        pos.date_dispensed as date_dispensed,
        pos.last_received_date as supply_received_date,
        pos.med_src_type_id as supply_med_src_type_id,
        pos.pharmacy_id as supply_pharmacy_id,
        eef.name as supply_pharmacy_name,
        pos.reordering as supply_reordering,
        pos.status AS supply_status,
        pos.new_supply_flag as supply_new_supply_flag,
        pos.last_reorder_date as supply_last_reorder_date,
        pos.disp_code as supply_disp_code,
        pos.pharm_nurse_notes as pharm_nurse_notes,
        pos.nurse_pharm_notes as nurse_pharm_notes,
        pos.disp_package_identifier as supply_disp_package_identifier,
        pos.controlled_substance_code as supply_controlled_substance_code,
        pos.prescription as supply_prescription,
        pos.do_not_fill as supply_do_not_fill,
        pos.inventory_on_hand as inventory_on_hand,
        pos.next_refill_date as next_refill_date,
        psd.pharmacy_order_id as pharmacy_order_id,
        CASE  WHEN ip.pharmacy_id IS NULL THEN 'N' ELSE 'Y' END 'integrated_pharmacy',
        pos.active as supply_active,
        mmdb.dbo.fn_pho_getImageFilenameByNDC(pos.drug_code) as imageFileName, 
        pos.drug_code as drug_code
    FROM pho_order_supply pos
        
        LEFT JOIN emc_ext_facilities eef ON eef.ext_fac_id = pos.pharmacy_id
        left join pho_supply_dispense psd on psd.order_supply_id = pos.order_supply_id and psd.deleted='N'
        LEFT JOIN @integratedPharmacies ip
                    ON ip.pharmacy_id = pos.pharmacy_id
    WHERE (pos.active = 'Y' or pos.active = 'N') AND pos.deleted = 'N' and pos.phys_order_id = @physOrderId
    ORDER BY pos.created_date DESC
END

	if(@debug='Y') begin Print 'END STEP select enhanced phys order		' + ' ' + convert(varchar(26),getdate(),109) end

END TRY
 
--error trapping
BEGIN CATCH

SELECT @error_code = @@error
	 , @status_text = ERROR_MESSAGE()
 
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
IF @debug='Y' PRINT 'Stored procedure failure in step:'+ convert(varchar(3),@step) + '	' + convert(varchar(26),getdate())
IF @debug='Y' PRINT 'Error code: '+convert(varchar(3),@step) + '; Error description:	' +@status_text
RETURN @status_code

END
GO

GRANT EXECUTE ON sproc_pho_list_getEnhancedOrder TO PUBLIC
GO



GO

print 'A_PreUpload/CORE-94344 - DDL - sproc_pho_list_getEnhancedOrder.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-94344 - DDL - sproc_pho_list_getEnhancedOrder.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-94344 - DDL - sproc_pho_list_getEnhancedOrder_v2.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

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


 -- ===============================================================================================================================
 -- 
 -- Purpose: The purpose of this procedure is to load a phys order with all it's schedule information.
 --			 Please note that this stored procedure is a copy of 'sproc_pho_list_getEnhancedOrder' but has all MMDB references removed.
 --
 --
 -- Target ENVIRONMENT: BOTH 
 --
 --  Special Instructions: 
 --
 --	Params:
 --			
 --			@physOrderId    - phys order id
 --			@facId			- Facility Id 
 --			@includeAdministrativeOrder - Flag to include Administrative Orders, 'Y' or 'N'
 --			@includeSupplyInfo - Flag to include Supply Info, 'Y' or 'N'
 --			@debug          - Debug param, 'Y' or 'N'
 --			@status_code    - SP execution flag, 0 for success.
 --			@status_text    - SP error text if error occurs.
 --
 -- Change History:
 --   Author			Date		Comment
 -- ------------------------------------------------------------------------------------------------------------------------------- 
 --	  Joel Pelletier    08/11/2011	Created.
 --   Alireza Mandegar	10/15/2012	Updated due to PCC-33677 and Replaced the usage of fn_pho_getOrderStatus with sproc_pho_getOrderStatus
 --									Also modified the file maintenance box to be in sql comment format rather than java format
 --									and added the Change History section to it to keep track of changes.
 --  Alireza Mandegar	 11/12/2012	Added pho_ext_lib_generic_desc/id for PCC-34329
 --  Alireza Mandegar	 11/22/2012	Added schedule_sliding_scale_id due to PCC-30715
 --  Alireza Mandegar	 11/29/2012	Added schedule_dose_duration due to PCC-32538
 --  Feng Xia			 12/15/2012	Added xxMonths
 --  Alireza Mandegar	 12/20/2012	Added apply_remove_flag due to PCC-32537
 --  Alireza Mandegar	 01/25/2013	Added remove_time due to PCC-32537
 --  Alireza Mandegar	 01/31/2013	Added remove_duration due to PCC-32537
 --  Aarti Malhotra      09/24/2013  Added pho_ext_lib_rxnorm for PCC-47251 (main JIRA PCC-46704)
 --  Mustafa Behrainwala 04/28/2014  Added table to handle Therapeutic Interchange sliding scale PCC-52492 
 --  Mustafa Behrainwala 07/31/2014  Added Linked Set Id and Description for PCC-59209
 --	 Mustafa Behrainwala 10/29/2015	 Added order_class_id
 --  Willie Wong		 05/11/2016	 Added schedule_directions for dietary orders for PCC-94151
 --	 Nooshin Hayeri		 06/29/2016	Added snapshot_schedule_start_date for PCC-96359
 --  Melvin Parinas      07/16/2016  Removed snapshot_schedule_start_date and replaced with earliest_prescriber_start_date date PCC-96359
 --  Melvin Parinas      07/25/2016  Added prescriber_schedule_start_date due to PCC-98059	
 --	 Devika Bapat		 02/24/2017	Added 2 optional parameters to include administrative orders and supply info PCC-108894
 --	 Mustafa Behrainwala 10/12/2018 Modified due to CORE-23367 to add dose_low for dose ranging.
 --	 Elias Ghanem 		 12/21/2018 	Added last_pharmacy_end_date due to CORE-28433.
 --  Mustafa Behrainwala 01/29/2019 Modified due to CORE-29190 return behavior lookup
 --  Elias Ghanem 		 01/29/2019 Added schedule_revision_date due to CORE-85435
 --  Sree Naghasundharam 11/18/2021 Created this new stored procedure 'sproc_pho_list_getEnhancedOrder_v2' and Removed MMDB references (CORE-97119)
 --  Elias Ghanem 		 01/26/2022 use temp table to enhance performance CORE-94344
 -- ===============================================================================================================================

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sproc_pho_list_getEnhancedOrder_v2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [dbo].[sproc_pho_list_getEnhancedOrder_v2]
GO

create 
proc sproc_pho_list_getEnhancedOrder_v2
(
	@physOrderId	int,
	@facId			int,
	@includeAdministrativeOrder	char(1) = 'N',
	@includeSupplyInfo char(1) = 'N',
	@debug char(1)  = 'N',
	@status_code int out, 
	@status_text varchar(3000) out
)
as 
begin

SET NOCOUNT ON

DECLARE @step			int,
		@error_code		int

	   

BEGIN TRY

    -- PCC-33677
    ----Localize input Variables
    DECLARE  @vFacId int
            ,@vClientId int
            ,@vPhysOrderId int
            ,@vDateTime datetime
			,@vOrderCategory int
        
    -- Set the local variables
    select 
        @vFacId         = @facId 
       ,@vClientId      = null 
	   ,@vPhysOrderId   = @physOrderId
       ,@vDateTime      = dbo.fn_facility_getCurrentTime(@facId)
	   ,@status_code 	= 0
        
    -- Table variable to store the result of sproc_pho_getOrderStatus
    declare @TMP_PhoOrderStatus table (phys_order_id    int
                                    ,fac_id             int
                                    ,order_status       smallint
                                    ,order_relationship int
                                    ,status_reason      varchar(75));
    
	set @vOrderCategory = (select order_category_id from pho_phys_order where phys_order_id=@vPhysOrderId)
	
	-- Check exist in pho_phys_order table, struck out order does not has record in pho_phys_order table, if not exit, there is no need to execute sproc_pho_getOrderStatus
	if @vOrderCategory > 0
	begin
		-- Fill the table variable
		insert into @TMP_PhoOrderStatus
		exec sproc_pho_getOrderStatus 
				@facId          = @vFacId
				,@clientId      = @vClientId
				,@physOrderId   = @vPhysOrderId
				,@date          = @vDateTime
				,@debug         = 'N'
				,@status_code   = @status_code
				,@status_text   = @status_text
	end

	if @debug = 'Y'  select * From @TMP_PhoOrderStatus

	if isnull(@status_code,0) <> 0
		  begin
				set @status_text = 'sproc_pho_getOrderStatus returned the following error: ' + isnull(@status_text,'')
				Raiserror( @status_text, 11, 1 );
		  end

	
	if(@debug='Y') begin Print 'BEGIN STEP select enhanced phys order	' + ' ' + convert(varchar(26),getdate(),109) end

SELECT 
o.phys_order_id
, o.order_type_id
, o.physician_id
, o.pharmacy_id
, o.fac_id
, o.client_id
, o.drug_code
, o.created_by
, o.created_date
, o.revision_by
, o.revision_date
, o.reorder
, o.date_ordered
, o.start_date
, o.end_date
, o.strength
, o.form
, o.route_of_admin
, o.diagnoses
, o.description
, o.directions
, o.related_generic
, o.supplementary_notes
, o.communication_method
, o.diet_type
, diettype.item_description AS diet_type_description
, o.diet_texture
, diettexture.item_description AS diet_texture_description
, o.stat
, o.packaging
, o.disc_with_pharm
, o.quantity_to_administer
, o.std_order_id
, o.discontinued_date
, o.fluid_consistency
, fluidcon.item_description AS fluid_consistency_description
, o.diet_supplement
, dietsup.item_description AS diet_supplement_description
, o.hold_date
, o.nurse_admin_notes
, o.nurse_pharm_notes
, o.delivery_notes
, o.delivery_type
, o.self_admin
, o.administered_by_id
, o.prn_flag
, o.label_name
, o.reorder_count
, o.last_reorder_date
, o.quantity_received
, o.tran_id
, o.prescription
, o.start_date_type
, o.end_date_type
, o.end_date_duration_type
, o.end_date_duration
, o.schedule_dose_duration -- PCC-32538
, o.alter_med_src
, o.alter_med_src_name
, o.sent_date
, vpos.order_status
, o.status_change_by
, o.status_change_date
, o.hold_physician_id
, o.discontinue_physician_id
, o.pharm_nurse_notes
, o.first_admin
, o.drug_manufacturer
, o.drug_class_number
, o.resume_physician_id
, o.event_driven_flag
, o.auto_fill_flag
, o.controlled_substance_code
, o.related_phys_order_id
, o.relationship
, o.auto_created_flag
, o.active_flag
, o.new_supply_flag
, o.resume_date
, o.last_received_date
, o.orig_phys_order_id
, o.disp_package_identifier
, o.hold_date_end
, o.vendor_phys_order_id
, o.order_date
, o.sliding_scale_id
, o.order_verified
, o.dispense_as_written
, o.next_refill_date
, o.do_not_fill
, o.cur_supply_id
, o.first_documented
, o.substitution_indicator
, o.reassessment_required
, o.completed_date
, o.completed_by
, o.verify_copied_order
, o.original_route_of_admin
, o.indications_for_use
, o.draft
, o.origin_id
, o.order_category_id
, o.order_revision_date
, o.order_revision_by
, o.drug_strength
, o.drug_strength_uom
, o.drug_name
, o.is_new_order
, o.order_schedule_id
, o.start_date as schedule_start_date
, o.end_date as schedule_end_date
, o.last_pharmacy_end_date
, o.physician_name_in_msg
, s.schedule_id
, s.schedule_type
, s.pho_std_time_id
, s.xxdays as xx_days
, s.sun
, s.mon
, s.tues as tue
, s.wed
, s.thurs as thu
, s.fri
, s.sat
, s.days_on
, s.days_off
, s.std_freq_id
, s.dose AS dose_value
, s.dose_low
, s.alternate_dose
, s.start_time
, s.end_time
, s.nurse_action_notes
, s.date_start
, s.date_stop
, s.repeat_week
, s.apply_to
, s.prn_admin
, s.prn_admin_value
, s.prn_admin_units
, s.std_freq_time_label
, s.until_finished
, s.quantity_uom_id
, s.dose_uom_id
, case 
       -- diet orders do not populate the view_pho_schedule need to get directly from the pho_order_schedule table
       when  s.schedule_directions is null and o.order_category_id = 3031 then o.schedule_directions 
       else s.schedule_directions
end as schedule_directions
, o.order_directions as order_directions
, s.schedule_template
, s.xxMonths
, s.date_of_month
, s.std_shift_id
, s.schedule_sliding_scale_id
, s.apply_remove_flag
, s.remove_time
, s.remove_duration
, s.behavior_lookback
, o.schedule_revision_date
, c.first_name AS physician_first_name
, c.last_name AS physician_last_name
, c.title + ' ' + c.first_name + ' ' + c.last_name AS physician_fullname
, cb.long_username AS created_by_long
, rb.long_username AS revision_by_long
, poua.edited_by_audit_id
, poua.edited_date
, poua.created_by_audit_id
, edituser.long_username AS edited_by_long
, edituser.position_description AS edited_by_position
, edituser.designation_desc AS edited_by_designation
, createuser.long_username AS created_by_audit_long
, createuser.position_description AS created_by_position
, createuser.designation_desc AS created_by_designation
, poua.confirmed_by_audit_id
, poua.confirmed_date
, confuser.long_username AS confirmed_by_long
, confuser.position_description AS confirmed_by_position
, confuser.designation_desc AS confirmed_by_designation
, lib.pho_ext_lib_id
, lib.pho_ext_lib_med_id
, lib.pho_ext_lib_med_ddid
, lib.pho_ext_lib_generic_id
, lib.pho_ext_lib_generic_desc
, lib.ext_lib_rxnorm_id
, o.min_start_date
, o.max_end_date
, o.emergency_pharmacy_flag
, o.need_location_of_admin
, so.advanced_directive as order_advanced_directive
, poad.advanced_dir_status
, pspo.advanced_directive as advanced_directive
, signuser.long_username as signed_by_long
, ppos.signature_date
, o.extended_end_date
, o.extended_count
, custmed.cust_med_id
, ti.orig_phys_order_id as original_ti_phys_order_id
, lsi.linked_set_id as linked_set_id
, ls.set_description as linked_set_description
, nctrlsc.new_controlled_substance_code as new_controlled_substance_code
, esign.marked_to_sign_user_id
, case when marked_to_sign_user_id is not null then dbo.fn_get_username(marked_to_sign_user_id) else null end as marked_to_sign_user_longname
, esign.marked_to_sign_date
, esign.marked_to_sign_contact_id
, esign.marked_to_sign_authentication_type_id
, esign.marked_to_sign_source_type_id
, rstype.description as marked_to_sign_source_type_description
, esign.sign_user_id
, case when sign_user_id is not null then dbo.fn_get_username(sign_user_id) else null end as sign_user_longname
, esign.sign_date
, esign.sign_contact_id
, esign.sign_authentication_type_id
, atype.description as sign_authentication_type_description
, esign.sign_source_type_id
, stype.description as sign_source_type_description
, popr.reason_binary_code
, clinrev.reviewed_date
, clinrev.phys_order_id as review_order_id
, clinrev.reviewed_by
, oq.quantity as prescription_quantity
, oq.unit_of_measure as prescription_quantity_uom
, oq.no_of_refills as prescription_no_of_refills
, o.order_class_id
, o.prescriber_schedule_start_date as earliest_prescriber_start_date
, o.prescriber_schedule_start_date
, o.linked_order_id
, o.linked_reason_id
into #temp
FROM
	view_pho_phys_order o
	LEFT JOIN @TMP_PhoOrderStatus vpos
		ON o.phys_order_id = vpos.phys_order_id
	LEFT JOIN view_pho_schedule s
		ON o.order_schedule_id = s.order_schedule_id AND o.phys_order_id = s.phys_order_id
		AND s.deleted = 'N'
	LEFT JOIN COMMON_CODE diettype
        ON @vOrderCategory=3031 and o.diet_type = diettype.item_id and diettype.item_code = 'phodyt' -- only need for diet order
    LEFT JOIN COMMON_CODE diettexture
        ON @vOrderCategory=3031 and o.diet_texture = diettexture.item_id and diettexture.item_code = 'phodtx' -- only need for diet order
    LEFT JOIN COMMON_CODE dietsup
        ON @vOrderCategory=3032 and o.diet_supplement = dietsup.item_id and dietsup.item_code = 'phosup' -- only need for diet supplement order
    LEFT JOIN COMMON_CODE fluidcon
    	ON @vOrderCategory=3031 and o.fluid_consistency = fluidcon.item_id and fluidcon.item_code = 'phocst' -- only need for diet order
	LEFT JOIN contact c
		ON c.contact_id = o.physician_id
	LEFT JOIN sec_user cb
		ON cb.loginname = o.created_by
	LEFT JOIN sec_user rb
		ON rb.loginname = o.revision_by
	LEFT JOIN pho_phys_order_useraudit poua
		ON poua.phys_order_id = o.phys_order_id
	LEFT JOIN cp_sec_user_audit createuser
	  ON createuser.cp_sec_user_audit_id = poua.created_by_audit_id
	LEFT JOIN cp_sec_user_audit edituser
	  ON edituser.cp_sec_user_audit_id = poua.edited_by_audit_id
	LEFT JOIN cp_sec_user_audit confuser
	  ON confuser.cp_sec_user_audit_id = poua.confirmed_by_audit_id
	LEFT JOIN pho_order_ext_lib_med_ref lib
	  ON @vOrderCategory=3022 and lib.phys_order_id = o.phys_order_id -- only need for pharmacy order
	LEFT JOIN pho_phys_order_std_order templateorder
	  ON @vOrderCategory=3029 and templateorder.phys_order_id = o.phys_order_id -- only need for other category order
	LEFT JOIN  pho_std_order so 
	  ON @vOrderCategory=3029 and templateorder.std_order_id = so.std_order_id -- only need for other category order
	LEFT JOIN pho_std_phys_order pspo
	  ON @vOrderCategory=3029 and o.std_order_id = pspo.std_phys_order_id -- only need for other category order
	LEFT JOIN pho_phys_order_advanced_directive poad
	  ON @vOrderCategory=3029 and o.phys_order_id = poad.phys_order_id -- only need for other category order
	LEFT JOIN pho_phys_order_sign ppos
	  ON o.phys_order_id = ppos.phys_order_id
	LEFT JOIN cp_sec_user_audit signuser
	  ON signuser.cp_sec_user_audit_id = ppos.cp_sec_user_audit_id
	LEFT JOIN pho_phys_order_cust_med custmed
	  ON @vOrderCategory=3022 and custmed.phys_order_id = o.phys_order_id -- only need for pharmacy order
	LEFT JOIN pho_phys_order_ti ti
	  ON ti.phys_order_id = o.phys_order_id
	LEFT JOIN pho_linked_set_item lsi
	  ON lsi.phys_order_id = o.phys_order_id
	LEFT JOIN pho_linked_set ls on ls.linked_set_id = lsi.linked_set_id
	LEFT JOIN pho_phys_order_new_ctrlsubstancecode nctrlsc ON @vOrderCategory=3022 and nctrlsc.phys_order_id=o.phys_order_id -- only need for pharmacy order
	LEFT JOIN pho_phys_order_esignature esign  ON o.phys_order_id = esign.phys_order_id
	LEFT JOIN order_sign_source_type stype ON esign.sign_source_type_id = stype.source_type_id
	LEFT JOIN order_sign_source_type rstype ON esign.marked_to_sign_source_type_id = rstype.source_type_id
	LEFT JOIN order_sign_authentication_type atype ON esign.sign_authentication_type_id = atype.authentication_type_id
	LEFT JOIN pho_order_pending_reason popr ON popr.phys_order_id = o.phys_order_id
    LEFT JOIN pho_order_clinical_review clinrev ON clinrev.phys_order_id=o.phys_order_id 
    LEFT JOIN pho_phys_order_quantity_info oq on @vOrderCategory=3022 and oq.phys_order_id=o.phys_order_id -- only need for pharmacy order

WHERE
	o.phys_order_id = @physOrderId


SELECT
t.phys_order_id
, t.order_type_id
, t.physician_id
, t.pharmacy_id
, t.fac_id
, t.std_freq_id
, t.client_id
, t.drug_code
, t.created_by
, t.created_date
, t.revision_by
, t.revision_date
, t.reorder
, t.date_ordered
, t.start_date
, t.end_date
, t.strength
, t.form
, t.route_of_admin
, t.diagnoses
, t.description
, t.directions
, t.related_generic
, t.supplementary_notes
, t.communication_method
, t.diet_type
, t.diet_type_description
, t.diet_texture
, t.diet_texture_description
, t.stat
, t.packaging
, t.disc_with_pharm
, t.quantity_to_administer
, t.std_order_id
, t.discontinued_date
, t.fluid_consistency
, t.fluid_consistency_description
, t.diet_supplement
, t.diet_supplement_description
, t.hold_date
, t.nurse_admin_notes
, t.nurse_pharm_notes
, t.delivery_notes
, t.delivery_type
, t.self_admin
, t.administered_by_id
, t.prn_flag
, t.label_name
, t.reorder_count
, t.last_reorder_date
, t.quantity_received
, t.tran_id
, t.prescription
, t.start_date_type
, t.end_date_type
, t.end_date_duration_type
, t.end_date_duration
, t.schedule_dose_duration -- PCC-32538
, t.alter_med_src
, t.alter_med_src_name
, t.sent_date
, t.order_status
, t.status_change_by
, t.status_change_date
, t.hold_physician_id
, t.discontinue_physician_id
, t.pharm_nurse_notes
, t.first_admin
, t.drug_manufacturer
, t.drug_class_number
, t.resume_physician_id
, t.event_driven_flag
, t.auto_fill_flag
, t.controlled_substance_code
, t.related_phys_order_id
, t.relationship
, t.auto_created_flag
, t.active_flag
, t.new_supply_flag
, t.resume_date
, t.last_received_date
, t.orig_phys_order_id
, t.disp_package_identifier
, t.hold_date_end
, t.vendor_phys_order_id
, t.order_date
, t.sliding_scale_id
, t.order_verified
, t.dispense_as_written
, t.next_refill_date
, t.do_not_fill
, t.cur_supply_id
, t.first_documented
, t.substitution_indicator
, t.reassessment_required
, t.completed_date
, t.completed_by
, t.verify_copied_order
, t.original_route_of_admin
, t.indications_for_use
, t.draft
, t.origin_id
, t.order_category_id
, t.order_revision_date
, t.order_revision_by
, t.drug_strength
, t.drug_strength_uom
, t.drug_name
, t.is_new_order
, t.order_schedule_id
, t.schedule_start_date
, t.schedule_end_date
, t.last_pharmacy_end_date
, t.physician_name_in_msg
, t.schedule_id
, t.schedule_type
, t.pho_std_time_id
, t.xx_days
, t.sun
, t.mon
, t.tue
, t.wed
, t.thu
, t.fri
, t.sat
, t.days_on
, t.days_off
, t.dose_value
, t.dose_low
, t.alternate_dose
, t.start_time
, t.end_time
, t.nurse_action_notes
, t.date_start
, t.date_stop
, t.repeat_week
, t.apply_to
, t.prn_admin
, t.prn_admin_value
, t.prn_admin_units
, t.std_freq_time_label
, t.until_finished
, t.quantity_uom_id
, t.dose_uom_id
, t.schedule_directions
, t.order_directions
, t.schedule_template
, t.xxMonths
, t.date_of_month
, t.std_shift_id
, t.schedule_sliding_scale_id
, t.apply_remove_flag
, t.remove_time
, t.remove_duration
, t.behavior_lookback
, t.schedule_revision_date
, v.vital
, p.prompt_id
, p.value_type
, p.description as prompt_description
, p.long_description
, p.notes
, p.no_of_values
, p.current_value2
, p.current_value
, p.specify_initial_value
, p.value_data_type
, p.prompt_frequency_type
, p.prompt_frequency
, p.value_date
, pt.short_desc
, t.physician_first_name
, t.physician_last_name
, t.physician_fullname
, t.created_by_long
, t.revision_by_long
, t.edited_by_audit_id
, t.edited_date
, t.created_by_audit_id
, t.edited_by_long
, t.edited_by_position
, t.edited_by_designation
, t.created_by_audit_long
, t.created_by_position
, t.created_by_designation
, t.confirmed_by_audit_id
, t.confirmed_date
, t.confirmed_by_long
, t.confirmed_by_position
, t.confirmed_by_designation
, t.pho_ext_lib_id
, t.pho_ext_lib_med_id
, t.pho_ext_lib_med_ddid
, t.pho_ext_lib_generic_id
, t.pho_ext_lib_generic_desc
, t.ext_lib_rxnorm_id
, t.min_start_date
, t.max_end_date
, t.emergency_pharmacy_flag
, t.need_location_of_admin
, t.order_advanced_directive
, t.advanced_dir_status
, t.advanced_directive
, t.signed_by_long
, t.signature_date
, t.extended_end_date
, t.extended_count
, t.cust_med_id
, t.original_ti_phys_order_id
, t.linked_set_id
, t.linked_set_description
, t.new_controlled_substance_code
, t.marked_to_sign_user_id
, t.marked_to_sign_user_longname
, t.marked_to_sign_date
, t.marked_to_sign_contact_id
, t.marked_to_sign_authentication_type_id
, t.marked_to_sign_source_type_id
, t.marked_to_sign_source_type_description
, t.sign_user_id
, t.sign_user_longname
, t.sign_date
, t.sign_contact_id
, t.sign_authentication_type_id
, t.sign_authentication_type_description
, t.sign_source_type_id
, t.sign_source_type_description
, t.reason_binary_code
, t.reviewed_date
, t.review_order_id
, t.reviewed_by
, t.prescription_quantity
, t.prescription_quantity_uom
, t.prescription_no_of_refills
, t.order_class_id
, t.earliest_prescriber_start_date
, t.prescriber_schedule_start_date
, t.linked_order_id
, t.linked_reason_id
, poa.facility_medical_attestation_id
from
#temp t
LEFT JOIN pho_order_related_prompt p
ON t.schedule_id = p.schedule_id and p.deleted ='N'
LEFT JOIN pho_order_related_value_type pt
ON p.value_type = pt.type_id
LEFT JOIN pho_schedule_vitals v
ON t.schedule_id = v.schedule_id and v.deleted = 'N'
LEFT JOIN pho_phys_order_attestation poa ON @vOrderCategory=3022 and poa.phys_order_id = t.phys_order_id -- only need for pharmacy order
ORDER BY t.order_schedule_id, t.schedule_id


-- select administrative orders
if @includeAdministrativeOrder='Y'
	select vpao.admin_created_date,
	vpao.admin_order_verified,
	vpao.order_related_id,
	vpao.phys_order_id,
	vpao.standard_phys_order_id,
	vpao.created_by,
	vpao.created_date,
	vpao.revision_by,
	vpao.revision_date,
	vpao.deleted_by,
	vpao.deleted_date,
	vpao.deleted,
	vpao.fac_id,
	vpao.order_relationship_id,
	vpao.admin_communication_method,
	vpao.admin_effective_date,
	vpao.admin_ineffective_date,
	vpao.admin_physician_id,
	vpao.admin_reason,
	vpao.admin_noted_by,
	vpao.admin_physician_first_name,
	vpao.admin_physician_last_name,
	vpao.strikeout_by,
	vpao.strikeout_date,
	vpao.strikeout_reason_code,
	vpao.strikeout_reason_description,
	vpao.strikeout_by_long,
	vpao.admin_order_id,
	vpao.admin_origin_id,
	secuser.long_username 'created_by_long' , secuser.designation_desc as created_by_designation, ccc.item_description as created_by_position
	,csua.long_username confirmed_by_username, csua.position_description as confirmed_by_position, csua.designation_desc as confirmed_by_designation, ua.confirmed_date as confirmed_date
	FROM view_pho_administrative_order vpao
	left join SEC_USER secuser on secuser.loginname = vpao.created_by
	left join common_code ccc on ccc.item_id = secuser.position_id
	left join pho_admin_order_useraudit ua ON ua.admin_order_id = vpao.admin_order_id
	left join cp_sec_user_audit csua on csua.cp_sec_user_audit_id = ua.confirmed_by_audit_id
	WHERE vpao.standard_phys_order_id = @physOrderId
	ORDER BY vpao.revision_date  DESC

IF @includeSupplyInfo='Y'
BEGIN
	DECLARE @integratedPharmacies TABLE
    (
        pharmacy_id int not null
    )
	INSERT INTO @integratedPharmacies (pharmacy_id)
	select distinct extFacId from (
		SELECT mp.ext_fac_id as extFacId
			FROM message_profile mp WITH (NOLOCK)
			INNER JOIN lib_message_profile lmp WITH (NOLOCK)
				ON lmp.message_profile_id = mp.message_profile_id
			       AND lmp.deleted = 'N' and lmp.is_enabled='Y'
			WHERE mp.is_enabled = 'Y' and mp.is_integrated_pharmacy='Y'
			AND mp.fac_id = @facId
			AND mp.message_protocol_id = 12
			GROUP BY mp.ext_fac_id
		UNION
		SELECT distinct mi.internal_id as extFacId
			FROM map_identifier mi WITH (NOLOCK)
			INNER JOIN lib_message_profile libmp WITH (NOLOCK)
			ON libmp.vendor_code = mi.vendor_code
			AND libmp.deleted = 'N'
			INNER JOIN message_profile mp WITH (NOLOCK)
			ON libmp.message_profile_id = mp.message_profile_id
			WHERE mi.map_type_id = 3 and mp.fac_id = @facId and  mi.fac_id = @facId
	) a where extFacId is not null

select pos.phys_order_id,
        pos.order_supply_id,
        pos.description as supply_description,
        pos.directions as supply_directions,
        pos.date_dispensed as date_dispensed,
        pos.last_received_date as supply_received_date,
        pos.med_src_type_id as supply_med_src_type_id,
        pos.pharmacy_id as supply_pharmacy_id,
        eef.name as supply_pharmacy_name,
        pos.reordering as supply_reordering,
        pos.status AS supply_status,
        pos.new_supply_flag as supply_new_supply_flag,
        pos.last_reorder_date as supply_last_reorder_date,
        pos.disp_code as supply_disp_code,
        pos.pharm_nurse_notes as pharm_nurse_notes,
        pos.nurse_pharm_notes as nurse_pharm_notes,
        pos.disp_package_identifier as supply_disp_package_identifier,
        pos.controlled_substance_code as supply_controlled_substance_code,
        pos.prescription as supply_prescription,
        pos.do_not_fill as supply_do_not_fill,
        pos.inventory_on_hand as inventory_on_hand,
        pos.next_refill_date as next_refill_date,
        psd.pharmacy_order_id as pharmacy_order_id,
        CASE  WHEN ip.pharmacy_id IS NULL THEN 'N' ELSE 'Y' END 'integrated_pharmacy',
        pos.active as supply_active,
        '' as imageFileName, 
        pos.drug_code as drug_code
    FROM pho_order_supply pos
        
        LEFT JOIN emc_ext_facilities eef ON eef.ext_fac_id = pos.pharmacy_id
        left join pho_supply_dispense psd on psd.order_supply_id = pos.order_supply_id and psd.deleted='N'
        LEFT JOIN @integratedPharmacies ip
                    ON ip.pharmacy_id = pos.pharmacy_id
    WHERE (pos.active = 'Y' or pos.active = 'N') AND pos.deleted = 'N' and pos.phys_order_id = @physOrderId
    ORDER BY pos.created_date DESC
END

	if(@debug='Y') begin Print 'END STEP select enhanced phys order		' + ' ' + convert(varchar(26),getdate(),109) end

END TRY
 
--error trapping
BEGIN CATCH

SELECT @error_code = @@error
	 , @status_text = ERROR_MESSAGE()
 
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
IF @debug='Y' PRINT 'Stored procedure failure in step:'+ convert(varchar(3),@step) + '	' + convert(varchar(26),getdate())
IF @debug='Y' PRINT 'Error code: '+convert(varchar(3),@step) + '; Error description:	' +@status_text
RETURN @status_code

END
GO

GRANT EXECUTE ON sproc_pho_list_getEnhancedOrder_v2 TO PUBLIC
GO



GO

print 'A_PreUpload/CORE-94344 - DDL - sproc_pho_list_getEnhancedOrder_v2.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-94344 - DDL - sproc_pho_list_getEnhancedOrder_v2.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-98962-update-wet-sig-report.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

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


--=====================================================================================================
--  Jira Issue #: 			CORE-98962
--  Written By:				Patrick Campbell
--  Script Type:			DML
--  Target DB Type:			Client
--  Target Environment:		BOTH
--  Re-Runnable:				Yes
--  Description :			Updat run_url in prp_rm_report and insert column into prp_report_column
--=====================================================================================================
BEGIN
    IF EXISTS(SELECT * FROM prp_rm_report WHERE report_id = -97)
        BEGIN
            UPDATE prp_rm_report SET run_url = '/clinical/pho/showorders.xhtml?action=runWetSignatureOrders&ESOLelemname=selectedOrders' WHERE report_id = -97;
        END
END

BEGIN
    IF NOT EXISTS(SELECT * FROM prp_report_column WHERE report_id = -97)
        BEGIN
            INSERT INTO prp_report_column values (-10120, -97, -10281, 1, 12, 0, null, 'template', getdate(), 'template', getdate(), 'N', null, null)
        END
END

BEGIN
    IF EXISTS(SELECT * FROM prp_rm_report WHERE report_id = -97)
    BEGIN
        UPDATE sec_function SET facility_type = null WHERE func_id = '5070.4';
    END
END

GO

print 'A_PreUpload/CORE-98962-update-wet-sig-report.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-98962-update-wet-sig-report.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-99020 - DML - AddTemplateLocationStatus.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

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
-- Jira #:               CORE-97975 04 DML - AddTemplateLocationStatus.sql
--
-- Written By:           Matthew Koval
--
-- Script Type:          DML
-- Target DB Type:       CLIENT
-- Target ENVIRONMENT:   BOTH
--
-- Re-Runable:           YES
--
-- Where tested:        
--
-- Staging Recommendations/Warnings:
--
-- Description of Script Function:
--   Add location status for template DBs
-- 
-- Special Instruction:
--   Runs after the 
-- =================================================================================
--DML insert template location_status
IF EXISTS (SELECT 1 FROM information_schema.tables
               WHERE table_name = 'location_status'
               AND table_schema = 'dbo') AND NOT EXISTS (SELECT 1 FROM location_status WHERE code = 'TEMPLATE')
BEGIN
	INSERT INTO location_status(location_status_id, code, description)
	VALUES (9, 'TEMPLATE', 'Template')
END

GO

print 'A_PreUpload/CORE-99020 - DML - AddTemplateLocationStatus.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-99020 - DML - AddTemplateLocationStatus.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-99214-DML-CashTransactionsNotMatchingPaymentAndUnapplied.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

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
-- Author:               Shawn Song
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
-- Comments: 			 CORE-99214 Add new validation type for cash transactions 
--							not matching applied payment + unapplied cash
--
-- =================================================================================

IF NOT EXISTS (SELECT 1 FROM ar_cash_data_integrity_validation_type WHERE validation_type_id=3)
BEGIN
	INSERT INTO ar_cash_data_integrity_validation_type (validation_type_id, name)
		VALUES (3, 'cash_match_applied_payment_with_unapplied_cash_check')
END

GO

print 'A_PreUpload/CORE-99214-DML-CashTransactionsNotMatchingPaymentAndUnapplied.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-99214-DML-CashTransactionsNotMatchingPaymentAndUnapplied.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-99306 - DML - Add LTCF questions.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

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
--  Issue:            CORE-99306 Add questions for LTCF Discharge and Delete
--  Written By:       Afzal Bhojani
--  Script Type:      DML
--                      
--  Target DB Type:   ClientDB
--  Target Database:  All 
--
--  Tested:			  DEV_CA_Scorpion_Squad_kcity on pccsql-use2-nprd-dvsh-cli0003.bbd2b72cba43.database.windows.net
--  Re-Runable:       Yes
--                      
--  Description:      Adds missing questions to the LTCF Discharge and Delete assessments.
--					  The status_Y column is for routine discharge, covers last 3 days
--					  The status_Q column is for routine discharge tracking only
--=============================================================================

-- common questions between discharge and discharge tracking
UPDATE 
	as_std_question
SET
	status_Y = 'M',
	status_Q = 'M'
WHERE
	std_assess_id = 23
	and 
		(
			question_key like 'A7%'	
			or 
			question_key in ('AD2', 'AD3', 'B2', 'B5', 'B5a', 'B5b')
		)
	and (status_Y <> 'M' or status_Q <> 'M');
	
-- only discharge regular needs AD1
UPDATE 
	as_std_question
SET
	status_Y = 'M'
WHERE
	std_assess_id = 23
	and question_key = 'AD1'
	and status_Y <> 'M';



GO

print 'A_PreUpload/CORE-99306 - DML - Add LTCF questions.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-99306 - DML - Add LTCF questions.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-99388 - DML - Update Security Functions - Acknowledge Drug Interaction and Allergy Alerts - for Canada.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

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


--=====================================================================================================
--  Jira Issue #: 			CORE-99388 ; CORE-100831
--  Written By:				Sree Naghasundharam (naghas)
--  Script Type:			DML
--  Target DB Type:			Client
--  Target Environment:		BOTH
--  Re-Runable:				Yes
--  Description :			Update facility_type of the below two functions in sec_function table 
--							such that both functions are available for both US and Canadian Facilties.
--							1) 'Acknowledge Severe Drug Allergy Alerts' with func_id = '5891.90'
--							2) 'Acknowledge Severe Drug Interaction Alerts' with func_id = '5891.91'
-- 
-- Revision History:
-- 23 Feb 2022	naghas	CORE-100831	Moved the SQL script file from UPLOAD folder to Pre-Upload folder
--=====================================================================================================

UPDATE sec_function
SET facility_type = null, revision_by = 'CORE-99388', revision_date = GETDATE()
WHERE func_id in ('5891.90', '5891.91')


GO

print 'A_PreUpload/CORE-99388 - DML - Update Security Functions - Acknowledge Drug Interaction and Allergy Alerts - for Canada.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-99388 - DML - Update Security Functions - Acknowledge Drug Interaction and Allergy Alerts - for Canada.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-99562- DML - Insert SMS Authentication Type.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

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
-- Reviewed By: Dominic Christie
-- Author: Ashok Gurudayal
--
-- Script Type:          DML
-- Target DB Type:       CLIENTDB
-- Target ENVIRONMENT:   US and CDN
--
--
-- Re-Runable:           YES
--
-- Special Instruction:
-- Comments:             CORE-99562 INSERT SMS Authentication Type
-- =================================================================================
--
-- ------------------------------------------------------
-- ------------------------------------------------------


IF NOT EXISTS (SELECT 1 FROM order_sign_authentication_type WHERE description='SMS')
BEGIN
INSERT INTO order_sign_authentication_type
SELECT 7,'SMS'
END


GO

print 'A_PreUpload/CORE-99562- DML - Insert SMS Authentication Type.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-99562- DML - Insert SMS Authentication Type.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-99586-01-DML-UpdateLocationStatusEntryCodes.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

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
-- Jira #:               CORE-99586 - 01 Update location status code entries
--
-- Written By:           Matthew Koval
--
-- Script Type:          DML
-- Target DB Type:       CLIENT
-- Target ENVIRONMENT:   BOTH
--
-- Re-Runable:           YES
--
-- Where tested:        
--
-- Staging Recommendations/Warnings:
--
-- Description of Script Function:
--   Update location status codes to be underscored, instead of space separated.
-- 
-- Special Instruction:
-- =================================================================================

--DML insert location_status records
IF EXISTS (SELECT 1 FROM information_schema.tables
               WHERE table_name = 'location_status'
               AND table_schema = 'dbo') AND EXISTS (SELECT 1 FROM location_status WHERE code = 'SCHEDULED CHANGE' AND location_status_id = 4)
BEGIN
	UPDATE location_status 
	SET code = 'SCHEDULED_CHANGE'
	WHERE location_status_id = 4
END

IF EXISTS (SELECT 1 FROM information_schema.tables
               WHERE table_name = 'location_status'
               AND table_schema = 'dbo') AND EXISTS (SELECT 1 FROM location_status WHERE code = 'READ ONLY' AND location_status_id = 5)
BEGIN
	UPDATE location_status 
	SET code = 'READ_ONLY'
	WHERE location_status_id = 5
END

IF EXISTS (SELECT 1 FROM information_schema.tables
               WHERE table_name = 'location_status'
               AND table_schema = 'dbo') AND EXISTS (SELECT 1 FROM location_status WHERE code = 'MAINTENANCE MODE' AND location_status_id = 6)
BEGIN
	UPDATE location_status 
	SET code = 'MAINTENANCE_MODE'
	WHERE location_status_id = 6
END





GO

print 'A_PreUpload/CORE-99586-01-DML-UpdateLocationStatusEntryCodes.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-99586-01-DML-UpdateLocationStatusEntryCodes.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-99643 - DDL - Update Foreign Key reference.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

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


/*****************************************************************************************************
--  Issue:			  CORE-99643
--  Written By:		  Sheharyar Ikram
--  Script Type:      DDL
--  Target DB Type:   Client
--  Target Database:  BOTH
--  Re-Runable:       Yes
--  Description :     Update FK reference to correct table for to allow order strike out to go
--                    through for CDN Med Management EPrescribing workflow.
*****************************************************************************************************/
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
	WHERE TABLE_NAME = 'pho_phys_order_esignature_order_snapshot_CDN'
	AND CONSTRAINT_NAME = 'pho_phys_order_esignature_order_snapshot_CDN__physOrderId_FK')
BEGIN
	ALTER TABLE dbo.pho_phys_order_esignature_order_snapshot_CDN
		DROP CONSTRAINT pho_phys_order_esignature_order_snapshot_CDN__physOrderId_FK;
	ALTER TABLE dbo.pho_phys_order_esignature_order_snapshot_CDN
		ADD CONSTRAINT pho_phys_order_esignature_order_snapshot_CDN__physOrderId_FK FOREIGN KEY (phys_order_id) REFERENCES dbo.pho_phys_order_esignature (phys_order_id);
END

GO

print 'A_PreUpload/CORE-99643 - DDL - Update Foreign Key reference.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-99643 - DDL - Update Foreign Key reference.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-99647 - dml - remove branded_library_configuration global pk.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

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
--  Issue:            CORE-99647
--  Written By:       Richard Liu
--  Script Type:      DML
--  Target DB Type:   client
--  Target Database:  both
--  Re-Runable:       Yes
--  Description :     remove branded_library_configuration relevant record from pcc_global_primary_key table
--=============================================================================
delete from pcc_global_primary_key where table_name = 'branded_library_configuration';

GO

print 'A_PreUpload/CORE-99647 - dml - remove branded_library_configuration global pk.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-99647 - dml - remove branded_library_configuration global pk.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-99795 - DDL - Create new column and new table secure conversations.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

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
--  Issue:			  CORE-95795
--  Written By:		  Giovanny Tellez
--  Script Type:      DDL
--  Target DB Type:   Client
--  Target Database:  BOTH
--  Re-Runnable:       Yes
--  Description :     It creates column that indicate if a group is ready to use secure conversations
--					  It creates table with the detailed validations information
--
--=============================================================================

IF NOT EXISTS (SELECT 1 FROM [information_schema].[columns] 
			WHERE table_name = 'sec_conversation_group' 
			AND table_schema = 'dbo' AND column_name = 'ready_v2')
    BEGIN
		ALTER TABLE [dbo].sec_conversation_group
		ADD ready_v2 BIT NOT NULL CONSTRAINT [sec_conversation_group__readyV2_DFLT] DEFAULT (0);	--:PHI:N:Desc:It will reflect that all members in a group will be ready to use secure conversations version 2 app.
    END
	

-- =======================================
IF NOT EXISTS (SELECT 1 FROM [information_schema].[tables]
           WHERE table_name = 'sec_conversation_validation_v2'
             AND table_schema = 'dbo')
    BEGIN
		CREATE TABLE sec_conversation_validation_v2 (		--:PHI:N:Desc:Store information that determinates if a group is valide to use version 2 in secure conversations.
			 validation_id int IDENTITY (1,1) NOT NULL,--:PHI:N:Desc:primary key
			 group_type tinyInt NOT NULL,	   --:PHI:N:Desc:type of group. There are three types of groups: Value 1: is a Resident Centric group. Value 2: is a general group, Value 3: is a cross facility group.
			 iam_role_name VARCHAR(255) NOT NULL, --:PHI:N:Desc:This is the role name 
			 status tinyInt NOT NULL,	   --:PHI:N:Desc:Status of the validation Value 0: group is set properly, Value 1: group has insufficient permission
			 CONSTRAINT [sec_conversation_validation_v2__validationId_PK_CL_IX] PRIMARY KEY (validation_id),
			 CONSTRAINT [sec_conversation_validation_v2__groupType_iamRoleName_status_UQ_IX] UNIQUE (group_type,iam_role_name, status)
		);

		
		ALTER TABLE sec_conversation_validation_v2			
			ADD CONSTRAINT sec_conversation_validation_v2__groupType_CHK CHECK (group_type IN (1, 2, 3));						
		ALTER TABLE sec_conversation_validation_v2			
			ADD CONSTRAINT sec_conversation_validation_v2__status_CHK CHECK (status IN (0, 1));
			
				
		CREATE NONCLUSTERED INDEX [sec_conversation_validation_v2__groupType_iamRoleName_IX] ON [dbo].[sec_conversation_validation_v2]
		(
			[group_type], [iam_role_name]
		);		
    END

GO

print 'A_PreUpload/CORE-99795 - DDL - Create new column and new table secure conversations.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-99795 - DDL - Create new column and new table secure conversations.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/US_Only/CORE-99655-DML-ClientDB_Update_PDPM_Calc_V20003.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

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
-- Jira #:               CORE-99655
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
-- Description of Script Function: Update PDPM Calc Version code to 2.0003 if 
--     ARD On/After Oct. 1, 2020
--									
-- =================================================================================
DECLARE @revisionDate datetime = getdate()
	  , @revisionBy varchar(10) = 'CORE-99655'
;
DECLARE @QuestionResponse as TABLE
(
   ItemValue varchar(2000) not null
);

IF EXISTS (Select 1 FROM information_schema.columns WHERE table_name = 'as_response')
BEGIN
	INSERT INTO @QuestionResponse (ItemValue)
	VALUES ('2.0000'), 
		   ('2.0001'),
		   ('2.0002')
		   ;

	UPDATE r
	  SET r.item_value = '2.0003'
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

print 'A_PreUpload/US_Only/CORE-99655-DML-ClientDB_Update_PDPM_Calc_V20003.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/US_Only/CORE-99655-DML-ClientDB_Update_PDPM_Calc_V20003.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/US_Only/CORE-99856 DML Rhode-Island-CMI-Update.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

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
-- CORE-99856 DML Rhode-Island-CMI-Update.sql
--
-- JIRA: 
--    Story:  CORE-99856  MDS 3.0: Rhode Island CMI values updated Oct 1, 2021
--    Task:   CORE-100065 DEV MDS 3 add RI Rhode Island RUG CMI values 2021
--
-- Written By:  Colin Collins
-- Reviewed By: Scorpion Squad
-- 
-- Script Type:        DML
-- Target DB Type:     Client
-- Target ENVIRONMENT: US ONLY 
-- Re-Runable:         YES 
-- 
-- Where tested:         pccsql-use2-nprd-dvsh-cli0003.bbd2b72cba43.database.windows.net,1433
--                       use DEV_US_Scorpion_Squad_abhow
--
-- Description of Script Function: 
--   Create a copy of the latest Rhode Island Medicaid RUG-IV 48 Grouper 
--   and then update the case mix indeces.  Set the current model to be ineffective 10/1/2021.
--
-- Special Instruction:    
-- 
-- ================================================================================= 

DECLARE
     @debugBit                 bit = 0
    ,@std_assess_id            int = 11

	 	 -- Paramaters that are usually differernt in the from and to versions
    ,@param_short_old               varchar(5)   = 'Ri'
    ,@param_short_new               varchar(5)   = 'RI'
    ,@param_effective_date_new      datetime     = '2021-10-01 00:00:00.000'  
    ,@param_ineffective_date_new    datetime     = null     
    ,@param_ineffective_date_old    datetime     = '2021-09-30 23:59:59.997'

     -- Paramaters that are usually the same, but might be differernt in the from and to versions
    ,@Param_long_desc           varchar(100)   = 'RI - RUG-IV- 48 Group - V1.04'
    ,@param_rug_logic_code      varchar(15)    = '1.0448' 
    ,@param_rug_model_num       varchar(5)     = '48'
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
  @codeUpdates TABLE (
     jiraOrder    int          Not null
    ,UiOrder      int          Not null
    ,[code]       [varchar](5) NOT NULL
    ,[cmi]        [float]      NOT NULL
    ,PRIMARY KEY CLUSTERED ( [UiOrder] ASC )
)
;


If (@debugBit = 1) Print 'Step 1  Fix up pcc_global_primary_key ' + convert(varchar(30), getdate(), 121);
DELETE FROM [dbo].[pcc_global_primary_key]
WHERE table_name IN ('as_std_rug_model', 'as_std_rug_cat', 'as_std_rug_code')
;

If (@debugBit = 1) Print 'Step 2 Load @codeUpdates table. ' + convert(varchar(30), getdate(), 121);

insert into @codeUpdates values
 (  1 ,38 ,'BA1' ,0.637 )        ,( 17 , 1 ,'ES3' ,4.983 )        ,( 33 ,17 ,'LE2' ,1.743 ) 
,(  2 ,37 ,'BA2' ,0.696 )        ,( 18 ,16 ,'HB1' ,1.321 )        ,( 34 ,48 ,'PA1' ,0.487 ) 
,(  3 ,36 ,'BB1' ,0.901 )        ,( 19 ,15 ,'HB2' ,1.679 )        ,( 35 ,47 ,'PA2' ,0.530 ) 
,(  4 ,35 ,'BB2' ,0.974 )        ,( 20 ,14 ,'HC1' ,1.332 )        ,( 36 ,46 ,'PB1' ,0.704 ) 
,(  5 ,34 ,'CA1' ,0.704 )        ,( 21 ,13 ,'HC2' ,1.700 )        ,( 37 ,45 ,'PB2' ,0.758 ) 
,(  6 ,33 ,'CA2' ,0.790 )        ,( 22 ,12 ,'HD1' ,1.440 )        ,( 38 ,44 ,'PC1' ,0.920 ) 
,(  7 ,32 ,'CB1' ,0.920 )        ,( 23 ,11 ,'HD2' ,1.830 )        ,( 39 ,43 ,'PC2' ,0.986 ) 
,(  8 ,31 ,'CB2' ,1.028 )        ,( 24 ,10 ,'HE1' ,1.591 )        ,( 40 ,42 ,'PD1' ,1.148 ) 
,(  9 ,30 ,'CC1' ,1.039 )        ,( 25 , 9 ,'HE2' ,2.036 )        ,( 41 ,41 ,'PD2' ,1.245 ) 
,( 10 ,29 ,'CC2' ,1.169 )        ,( 26 ,24 ,'LB1' ,1.028 )        ,( 42 ,40 ,'PE1' ,1.267 ) 
,( 11 ,28 ,'CD1' ,1.245 )        ,( 27 ,23 ,'LB2' ,1.310 )        ,( 43 ,39 ,'PE2' ,1.353 ) 
,( 12 ,27 ,'CD2' ,1.397 )        ,( 28 ,22 ,'LC1' ,1.105 )        ,( 44 , 8 ,'RAA' ,0.887 ) 
,( 13 ,26 ,'CE1' ,1.353 )        ,( 29 ,21 ,'LC2' ,1.408 )        ,( 45 , 7 ,'RAB' ,1.191 ) 
,( 14 ,25 ,'CE2' ,1.505 )        ,( 30 ,20 ,'LD1' ,1.310 )        ,( 46 , 6 ,'RAC' ,1.472 ) 
,( 15 , 3 ,'ES1' ,2.403 )        ,( 31 ,19 ,'LD2' ,1.668 )        ,( 47 , 5 ,'RAD' ,1.710 ) 
,( 16 , 2 ,'ES2' ,4.983 )        ,( 32 ,18 ,'LE1' ,1.364 )        ,( 48 , 4 ,'RAE' ,1.787 ) 
;


If (@debugBit = 1) Print 'Step 3  Deleting work from prior run ' + convert(varchar(30), getdate(), 121);

SELECT @local_model_id_prev = model_id
FROM [dbo].[as_std_rug_model] with(nolock)
WHERE std_assess_id    = @std_assess_id
  AND short_desc       = @param_short_new
  AND rug_version      = @Param_rug_version
  AND rug_model_num    = @param_rug_model_num
  AND effective_date   = @param_effective_date_new
;
IF (@local_model_id_prev is not null)
BEGIN
        If (@debugBit = 1) Print 'Step 3  Doing deletes';

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
FROM [dbo].[as_std_rug_model] with(nolock)
WHERE std_assess_id = @std_assess_id
  AND short_desc    = @param_short_old     
  AND rug_version   = @Param_rug_version    
  AND rug_model_num = @param_rug_model_num  
  and (ineffective_date is null or ineffective_date = @param_ineffective_date_old)  -- note that if this is a rerun, then ineffective data will not be null
;                                                 
                                                  
SELECT @local_cat_count = COUNT(*)                      
FROM [dbo].[as_std_rug_cat]  with(nolock)
WHERE model_id = @local_model_id_old               
;

SELECT @local_code_count = COUNT(*)
FROM       [dbo].[as_std_rug_cat]  cat   with(nolock)
INNER JOIN [dbo].[as_std_rug_code] code  with(nolock)     ON code.cat_id = cat.cat_id
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
      ,code.deleted       ,code.code          ,code.description   ,COALESCE(up.cmi, 0.0) 
      ,code.weight        ,code.adl_score     ,code.score2        ,code.score3
      ,catNew.cat_id      ,@param_effective_date_new    ,code.sequence
    FROM       [dbo].[as_std_rug_code] code
    INNER JOIN [dbo].[as_std_rug_cat]  catOld           ON  catOld.model_id = @local_model_id_old     AND catOld.cat_id    = code.cat_id       
    INNER JOIN [dbo].[as_std_rug_cat]  catNew           ON  catNew.model_id = @local_model_id_new     AND catNew.sequence  = catOld.sequence
    left  join @codeUpdates            up               on  up.code = code.code
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

print 'A_PreUpload/US_Only/CORE-99856 DML Rhode-Island-CMI-Update.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/US_Only/CORE-99856 DML Rhode-Island-CMI-Update.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

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
values ('4.4.10_A', 'upload_history')


GO

print '..\Update db version.sql --****SCRIPT DONE****'

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking (script,timestamp,upload) values ('UPLOAD END',getdate(),'4.4.10_06_CLIENT_A_PreUpload_US.sql')