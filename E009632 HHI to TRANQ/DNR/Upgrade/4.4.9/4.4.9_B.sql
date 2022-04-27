SET NOCOUNT ON
GO

SET DEADLOCK_PRIORITY HIGH
GO


insert into upload_tracking (script, timestamp, upload) values ('UPLOAD_START',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/01 CORE-97822 DDL update change set tables.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

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
	[revision_by] [varchar](60) NOT NULL,--:PHI=N:Desc:Who last revised the changeset
	[revision_date] [datetime] NOT NULL,--:PHI=N:Desc:Last revision date of the changeset
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

print 'B_Upload/01_DDL/01 CORE-97822 DDL update change set tables.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/01 CORE-97822 DDL update change set tables.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/02 CORE-97822 DDL sproc_sprt_order_list.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

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
	nurse_pharm_notes VARCHAR(512),
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
	nurse_pharm_notes VARCHAR(512),
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
	nurse_pharm_notes,
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
		o.nurse_pharm_notes,
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
	nurse_pharm_notes,
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
		temp.nurse_pharm_notes,
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
		o.physician_id,
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
		qi.no_of_refills,
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
		LEFT JOIN wesreference.dbo.pho_std_route_of_admin roa ON roa.route_of_admin_id = o.route_of_admin
		LEFT JOIN pho_phys_order_quantity_info qi ON qi.phys_order_id = o.phys_order_id
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

print 'B_Upload/01_DDL/02 CORE-97822 DDL sproc_sprt_order_list.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/02 CORE-97822 DDL sproc_sprt_order_list.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/03 CORE-98710 - DDL - sproc_sprt_order_list.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

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

print 'B_Upload/01_DDL/03 CORE-98710 - DDL - sproc_sprt_order_list.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/03 CORE-98710 - DDL - sproc_sprt_order_list.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-97948 - DDL - update ar_lib_statement_export_template__exportScheduleType_CHECK.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

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
--  Description :     Update ar_lib_statement_export_template__exportScheduleType_CHECK constraint
--                    
--=============================================================================
IF EXISTS (select 1 from information_schema.check_constraints
                           where constraint_name = 'ar_lib_statement_export_template__exportScheduleType_CHECK'
                           and constraint_schema = 'dbo'
						   and CHECK_CLAUSE <> '([export_schedule_type]>=(0) AND [export_schedule_type]<=(5))')
BEGIN
	ALTER TABLE [dbo].[ar_lib_statement_export_template] drop CONSTRAINT ar_lib_statement_export_template__exportScheduleType_CHECK;
END

IF NOT EXISTS (select 1 from information_schema.check_constraints
                           where constraint_name = 'ar_lib_statement_export_template__exportScheduleType_CHECK'
                           and constraint_schema = 'dbo')
BEGIN
	ALTER TABLE [dbo].[ar_lib_statement_export_template]  WITH CHECK ADD  CONSTRAINT [ar_lib_statement_export_template__exportScheduleType_CHECK] CHECK  (([export_schedule_type]>=(0) AND [export_schedule_type]<=(5)))
END

GO

print 'B_Upload/01_DDL/CORE-97948 - DDL - update ar_lib_statement_export_template__exportScheduleType_CHECK.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-97948 - DDL - update ar_lib_statement_export_template__exportScheduleType_CHECK.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-98179-Delete_unused_columns_in_branded_library_configuration.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

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
--  Issue:			  CORE-98179
--  Written By:		  Jeff Shepherd
--  Script Type:      DDL
--  Target DB Type:   Client
--  Target Database:  BOTH
--  Re-Runable:       Yes
--  Description :     Delete (now) unused columns in branded_library_configuration since feature is now in production 
--                    and feature flag no longer used
--                    
--=============================================================================
IF EXISTS (select 1 from information_schema.REFERENTIAL_CONSTRAINTS WHERE constraint_name = 'branded_library_configuration__libraryType_FK')
BEGIN
	ALTER TABLE [dbo].[branded_library_configuration] DROP CONSTRAINT branded_library_configuration__libraryType_FK
END

IF EXISTS (select 1 from information_schema.COLUMNS WHERE table_name = 'branded_library_configuration' and column_name = 'library_type')
BEGIN
    ALTER TABLE [dbo].[branded_library_configuration] DROP COLUMN library_type
END

IF EXISTS (select 1 from information_schema.COLUMNS WHERE table_name = 'branded_library_configuration' and column_name = 'included_content')
BEGIN
    ALTER TABLE [dbo].[branded_library_configuration] DROP COLUMN included_content
END

IF EXISTS (select 1 from information_schema.COLUMNS WHERE table_name = 'branded_library_configuration' and column_name = 'type_display_name')
BEGIN
    ALTER TABLE [dbo].[branded_library_configuration] DROP COLUMN type_display_name
END

IF EXISTS (select 1 from information_schema.COLUMNS WHERE table_name = 'branded_library_configuration' and column_name = 'content_general_overview')
BEGIN
    ALTER TABLE [dbo].[branded_library_configuration] DROP COLUMN content_general_overview
END

IF EXISTS (select 1 from information_schema.REFERENTIAL_CONSTRAINTS WHERE constraint_name = 'branded_library_configuration__countryId_FK')
BEGIN
	ALTER TABLE [dbo].[branded_library_configuration] DROP CONSTRAINT branded_library_configuration__countryId_FK
END

IF EXISTS (select 1 from information_schema.COLUMNS WHERE table_name = 'branded_library_configuration' and column_name = 'country_id')
BEGIN
    ALTER TABLE [dbo].[branded_library_configuration] DROP COLUMN country_id
END

GO

print 'B_Upload/01_DDL/CORE-98179-Delete_unused_columns_in_branded_library_configuration.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-98179-Delete_unused_columns_in_branded_library_configuration.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-98315-DDL_createTable_as_std_assessment_cms_template_hidden.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

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
-- Jira #: CORE-98315
--
-- Written By: Anthony Yuan, Yevgen Voroshylov
-- Reviewed By:
--
-- Script Type: DDL
-- Target DB Type: CLIENT
-- Target ENVIRONMENT: ALL
--
--
-- Re-Runnable: YES
--
-- Description of Script: Create table as_std_assessment_cms_template_replace
--
--
-- Special Instruction: None
--
-- =================================================================================


IF NOT EXISTS (
	SELECT *
	FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'as_std_assessment_cms_template_replace'
)
BEGIN
	CREATE TABLE [dbo].[as_std_assessment_cms_template_replace]( --:PHI=N:Desc: Define which standard assessments to replaced
	    [cms_template_id] [varchar](40) NOT NULL, --:PHI=N:Desc: Business ID of CMS Template defining the replacement setting
		[system_type_id] [smallint] NOT NULL, --:PHI=N:Desc: System Type ID of standard assessments to be replaced. System Type ID is defined in as_system_assessment in wesreference DB
		CONSTRAINT as_std_assessment_cms_template_replace__cmsTemplateId_systemTypeId_PK_CL_IX PRIMARY KEY ([cms_template_id], [system_type_id])
	)
END
	
-- drop index if it has been created by earlier version of the sql script
DROP INDEX IF EXISTS [as_std_assessment_cms_template_replace__cmsTemplateId_IX] ON [dbo].[as_std_assessment_cms_template_replace]
DROP INDEX IF EXISTS [as_std_assessment_cms_template_mapping__cmsTemplateId_IX] ON [dbo].[as_std_assessment_cms_template_mapping]


GO

print 'B_Upload/01_DDL/CORE-98315-DDL_createTable_as_std_assessment_cms_template_hidden.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-98315-DDL_createTable_as_std_assessment_cms_template_hidden.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-98811 - 1 - DDL - add uuid to cp_std_library.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

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
--  Jira #:             CORE-98811
--  
--  Written By:         Richard Liu
--  
--  Script Type:        DDL 
--  Target DB Type:     CLIENT
--  Target Database:    BOTH
--  
--  Re-Runnable:        YES

--  Description:		Column to hold UUIDs to sync data with CMS
--
--  Special Instruction: None    

--===============================================================================================================================================

if not exists ( select 1 from sys.columns c where c.object_id = OBJECT_ID('cp_std_library') and c.name = 'library_uuid' )
begin
	alter table cp_std_library add library_uuid varchar(36) null --:PHI=N:Desc:Care Plan Library UUID for CMS data sync
end

GO

print 'B_Upload/01_DDL/CORE-98811 - 1 - DDL - add uuid to cp_std_library.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-98811 - 1 - DDL - add uuid to cp_std_library.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-98884-DDL-add-column-to-adt_message-table.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

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
--  Issue:			  CORE-98884
--  Written By:		  Gordon Hyatt
--  Script Type:      DDL
--  Target DB Type:   Client
--  Target Database:  BOTH
--  Re-Runable:       Yes
--  Description :     Update adt_message table to add new nullable adt_message_xml column
--                    
--=============================================================================

if not exists(select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME='adt_message' and COLUMN_NAME='adt_message_xml')
begin
	alter table adt_message add adt_message_xml varchar(max) null
end

GO




GO

print 'B_Upload/01_DDL/CORE-98884-DDL-add-column-to-adt_message-table.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-98884-DDL-add-column-to-adt_message-table.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-96872-DML-add-wet-signature-report.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

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
=========================================================================================================================
Jira #: CORE-98324

Created By:     Patrick Campbell

Modified By:

Script Type:        DML

Target DB Type:     CLIENT

Target ENVIRONMENT: BOTH

Re-Runnable:        YES

Description:        Script to insert a new Wet Signature for Printed Prescription report into the Reports tab

=========================================================================================================================

*/
BEGIN
    IF NOT EXISTS(SELECT 1 FROM [reporting].[rpt_report] WHERE report_id = 7009)
    BEGIN
        INSERT INTO [reporting].[rpt_report]
            (
                 report_id,
                 title,
                 long_description,
                 help_text,
                 url
            )
        VALUES
            (
                7009
               , 'Printed Prescription for Wet Signature'
               , 'This is a report specifically created for Canadian facilities. You can select which active ${cli_client} orders you want printed onto the official prescription paper.'
               , ''
               , '/reporting/setup/runtime/printedprescriptionforwetsignature.xhtml?action=setupReport&report_id=-97&ESOLreportType=orders&ESOLaction=run&ESOLreportCatalogId=-2');
    END
END
BEGIN
    IF EXISTS(SELECT 1 FROM [reporting].[rpt_report] WHERE report_id = 7009) AND
       NOT EXISTS(SELECT 1 FROM [reporting].[rpt_report_module_sub_module_mapping] WHERE report_id = 7009)
    BEGIN
        INSERT INTO [reporting].[rpt_report_module_sub_module_mapping]
        VALUES (7009, 14);
    END
END

BEGIN
    IF NOT EXISTS(SELECT * FROM prp_report WHERE report_id = -97)
    BEGIN
        insert into prp_report (
            report_id,
            ref_report_id,
            p1_header_id,
            footer_id,
            created_by,
            created_date,
            revision_by,
            revision_date,
            deleted,
            deleted_by,
            deleted_date,
            overwrite_footer_run_time, overwrite_footer_options_run_time)
        values (
            -97,
            -5,
            null,
            null,
            'template',
            getdate(),
            'template',
            GETDATE(),
            'N',
            'template',
            null,
            null,
            null);
    END
END

BEGIN
    IF NOT EXISTS(SELECT * FROM prp_rm_report WHERE report_id = -97)
    BEGIN
        insert into prp_rm_report (
           report_id,
           report_name,
           display_name,
           report_desc,
           fac_id,
           reg_id,
           state_code,
           report_status,
           report_level,
           custom_report_id,
           is_system,
           sequence,
           setup_url,
           run_url,
           created_by,
           created_date,
           revision_by,
           revision_date,
           deleted,
           deleted_by,
           deleted_date,
           js_report_uri,
           schedulable,
           parent_report_id
        )
        VALUES
        (
           -97,
           'Printed Prescription for Wet Signature',
           'Printed Prescription for Wet Signature',
           'Printed Prescription for Wet Signature',
           -1,
           null,
           null,
           'P',
           'F',
           -97,
           1,
           17.5,
           '/reporting/setup/runtime/printedprescriptionforwetsignature.xhtml?action=setupReport&report_id=-97',
           '/reporting/setup/runtime/printedprescriptionforwetsignature.xhtml?action=runReport&report_id=-97',
           '_system_',
           getdate(),
           '_system_',
           getdate(),
           'N',
           null,
           null,
           null,
           0,
           null
        );
    END
END

BEGIN
    IF NOT EXISTS(SELECT * FROM prp_rm_report_catalog WHERE report_catalog_id = -97)
    BEGIN
        insert into prp_rm_report_catalog (report_catalog_id, report_id, catalog_id, sequence, is_system, overwrite,
                                           action_type, created_by, created_date, deleted)
        values (-97, -97, -2, 17.5, 1, 0, 'setup', '_system', getdate(), 'N');
    END
END

BEGIN
    IF NOT EXISTS(SELECT * FROM prp_rm_report_security WHERE report_security_id = -97)
    BEGIN
        insert into prp_rm_report_security(report_security_id, report_id, module_id, func_id, created_by,
                                           created_date, deleted)
        values (-97, -97, 2, 5070.4, 'template', getdate(), 'N');
    END
END

BEGIN
    IF NOT EXISTS(SELECT * FROM prp_ref_report WHERE ref_report_id = -97)
    BEGIN
        insert into prp_ref_report
        (
            ref_report_id,
            report_name,
            file_name,
            description,
            ref_report_status,
            setup_url,
            run_url,
            catalog_id,
            report_level,
            store_proc_name
        )
        values
        (
            -97,
            'Printed Prescription for Wet Signature',
            'wet_signature_prescription_form',
            'Printed Prescription for Wet Signature',
            'V',
            '/reporting/setup/runtime/orderreports.xhtml?action=setupReport',
            '/reporting/setup/runtime/orderreports.xhtml?action=runReport',
             -2,
             'F',
            'dbo.sproc_prp_get_pho_phys_wet_signature_orders'
        );
    END
END

BEGIN
    IF NOT EXISTS(SELECT * FROM prp_ref_report_filter WHERE ref_report_filter_id = -41100)
    BEGIN
        insert into prp_ref_report_filter
            (
             ref_report_filter_id,
             ref_report_id,
             ref_column_id
            )
        values
           (
            -41100,
            -97,
            -146
           );
    END
END

BEGIN
    IF NOT EXISTS(SELECT * FROM prp_report_filter WHERE report_filter_id = -41100)
    BEGIN
        insert into prp_report_filter
        (
             report_filter_id,
             report_id,
             ref_report_filter_id,
             filter_value,
             run_time_option,
             created_by,
             created_date,
             revision_by,
             revision_date,
             deleted,
             deleted_by,
             deleted_date
        )
        VALUES
        (
             -41100,
             -97,
             -41100,
             null,
             1,
             'template',
             getdate(),
             'template',
             getdate(),
             'N',
             'template',
              getdate()
         );
    END
END

GO

print 'B_Upload/02_DML/CORE-96872-DML-add-wet-signature-report.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-96872-DML-add-wet-signature-report.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-97956- DML - Updating the sequence and making the output columns dynamic for users.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

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
-- Where tested:         pccsql-use2-nprd-dvsh-cli0001.bbd2b72cba43.database.windows.net (DEV_hcr_bip25982 database )
--
--Updating the columns for the CDN mgmnt req
--
-- =================================================================================


	        UPDATE prp_ref_report_column
			SET overwrite_design_time=1
			WHERE ref_column_id IN (-13,-55,-77)
			and ref_report_id=-1007 ----  -10100 -10085




			UPDATE prp_report_column
			SET overwrite_run_time=1,
			 output_sequence=case when ref_report_column_id =-10085 THEN 4.2 ELSE 4.1 END
			WHERE report_id=-1007 AND ref_report_column_id in (-10103,-10085)






		

GO

print 'B_Upload/02_DML/CORE-97956- DML - Updating the sequence and making the output columns dynamic for users.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-97956- DML - Updating the sequence and making the output columns dynamic for users.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-97956- DML - Updating the sequence for intial column and making same across the org.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

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
-- Where tested:         pccsql-use2-nprd-dvsh-cli0001.bbd2b72cba43.database.windows.net (DEV_hcr_bip25982 database )
--
--Updating the columns for the CDN mgmnt req
--
-- =================================================================================



			UPDATE prp_report_column
			SET overwrite_run_time=1
			WHERE report_id=-1007 AND ref_report_column_id =-10100
			AND report_column_id=-10060






		

GO

print 'B_Upload/02_DML/CORE-97956- DML - Updating the sequence for intial column and making same across the org.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-97956- DML - Updating the sequence for intial column and making same across the org.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-98068-Update_facility_type_for_electronic_prescription.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

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




-- CORE-98068
-- Written By:          Alap Dhruva
-- Reviewed By:
--
-- Script Type:
-- Target DB Type:       CLIENT
-- Target ENVIRONMENT:   CDN
--
--
-- Re-Runnable:          YES
--
-- Where tested:         pccsql-use2-nprd-dvsh-cli0004.bbd2b72cba43.database.windows.net (DEV_CA_Strikeforce_kcity_12142021 database )
--
--Updating the column facility_type to null from USAR to get electronic prescription report appear in security roles
--
-- =================================================================================


BEGIN
    IF EXISTS (select * from sec_function where func_id =  '5070.45')
BEGIN
    update sec_function
    set facility_type = null
    where func_id =  '5070.45'
END
END








GO

print 'B_Upload/02_DML/CORE-98068-Update_facility_type_for_electronic_prescription.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-98068-Update_facility_type_for_electronic_prescription.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-98201-Update-SecurityFunction-for-PRTH.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

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
-- CORE-98201
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
--   delete security functions '13280.0'
--
--   URL: http://vmusnpdvshsg01/delete?funcIds=%2713280.0%27&scriptType=D&issueKey=CORE-98201&moduleId=13&_hardDelete=on
--
-- Special Instruction: Can be run prior to upload of code
--
--=======================================================================================================================

DECLARE @NOW datetime
DECLARE @deletedBy varchar(70)

SET @NOW = GETDATE()
SET @deletedBy = 'CORE-98201'

BEGIN TRAN

BEGIN TRY

	UPDATE sec_function SET deleted = 'Y', deleted_by = @deletedBy, deleted_date = @NOW WHERE func_id IN ('13280.0')

	DELETE FROM sec_role_function WHERE func_id IN ('13280.0')

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN

	DECLARE @err NVARCHAR(3000)
	SET @err = 'Error deleting security functions for ' + @deletedBy + ': ' + ERROR_MESSAGE()
	RAISERROR(@err, 16, 1)
END CATCH

IF @@TRANCOUNT > 0
	COMMIT TRAN


--=======================================================================================================================
-- CORE-98201
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
--     * 13240.8: Predictive Return to Hospital
--
--   URL: http://vmusnpdvshsg01/create?scriptType=I&issueKey=CORE-98201&moduleId=13&functionUpdates%5B1%5D.funcId=13240.8&functionUpdates%5B1%5D.parentId=13240.0&functionUpdates%5B1%5D.sequenceNo=13240.8&functionUpdates%5B1%5D.description=Predictive+Return+to+Hospital&functionUpdates%5B1%5D.environment=USAR&functionUpdates%5B1%5D.accessType=YN&functionUpdates%5B1%5D.accessLevel=0&functionUpdates%5B1%5D.accessCopyFromFuncId=&functionUpdates%5B1%5D.accessCopyFromDefault=0&functionUpdates%5B1%5D.systemRoleAccess%5B%271728%27%5D=-999&functionUpdates%5B1%5D.systemRoleAccess%5B%271729%27%5D=-999&functionUpdates%5B1%5D.systemRoleAccess%5B%271808%27%5D=-999&functionUpdates%5B1%5D.systemRoleAccess%5B%271809%27%5D=-999
--
-- Special Instruction: Can be run prior to upload of code
--
--=======================================================================================================================

-- CONSTANTS
SET @NOW = GETDATE()

-- SPECS
DECLARE @moduleId int, @createdBy varchar(70)

-- TEMP TABLE
DECLARE @sec_function__ins TABLE (func_id varchar(10), deleted char(1), created_by varchar(60), created_date datetime, module_id int, [type] varchar(8), description varchar(70), parent_function varchar(1), sequence_no float, facility_type varchar(5)
	PRIMARY KEY (func_id))
DECLARE @sec_role_function__ins TABLE (role_id int, func_id varchar(10), created_by varchar(60), created_date datetime, revision_by varchar(60), revision_date datetime, access_level int,
	PRIMARY KEY (role_id, func_id))


SET @moduleId = 13
SET @createdBy = 'CORE-98201'


--========================================================================================================
-- 13240.8: Predictive Return to Hospital
--========================================================================================================

-- (1) Prepare @sec_function__ins ===========================================================
INSERT INTO @sec_function__ins (func_id, deleted, created_by, created_date, module_id, [type], description, parent_function, sequence_no, facility_type)
	VALUES ('13240.8', 'N', @createdBy, @NOW, @moduleId, 'YN', 'Predictive Return to Hospital', 'N', 13240.8, 'USAR')


-- (2) Prepare @sec_role_function__ins ======================================================

-- (2a) Add new function to all appropriate roles ------------------------------
INSERT INTO @sec_role_function__ins (role_id, func_id, created_by, created_date, revision_by, revision_date, access_level)
	SELECT DISTINCT role_id, '13240.8', @createdBy, @NOW, NULL, NULL, 0 FROM sec_role r
	WHERE @moduleId = 10 -- new functions in the "All" module are applicable to every role
		OR (module_id = @moduleId AND description <> 'Collections Setup (system)' AND description <> 'Collections User (system)')
		OR (module_id = 0 AND EXISTS (SELECT 1 FROM sec_role_function rf INNER JOIN sec_function f ON rf.func_id = f.func_id WHERE f.module_id = @moduleId AND rf.role_id = r.role_id))


-- (2c) Default Permissions: Set System Roles ----------------------------------
UPDATE @sec_role_function__ins SET access_level = 4 WHERE func_id = '13240.8' AND role_id IN (SELECT role_id FROM sec_role WHERE system_field = 'Y' AND description IN ('Performance Insights (system)'))



--========================================================================================================
-- Apply changes
--========================================================================================================
BEGIN TRAN

BEGIN TRY

	DELETE FROM sec_function WHERE func_id IN ('13240.8')
	DELETE FROM sec_role_function WHERE func_id IN ('13240.8')

	INSERT INTO sec_function (func_id, deleted, created_by, created_date, module_id, [type], description, parent_function, sequence_no, facility_type)
		SELECT func_id, deleted, created_by, created_date, module_id, [type], description, parent_function, sequence_no, facility_type FROM @sec_function__ins

	INSERT INTO sec_role_function (role_id, func_id, created_by, created_date, revision_by, revision_date, access_level)
		SELECT role_id, func_id, created_by, created_date, revision_by, revision_date, access_level FROM @sec_role_function__ins

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN

	SET @err = 'Error creating security functions for ' + @createdBy + ': ' + ERROR_MESSAGE()
	RAISERROR(@err, 16, 1)
END CATCH

IF @@TRANCOUNT > 0
	COMMIT TRAN


GO

print 'B_Upload/02_DML/CORE-98201-Update-SecurityFunction-for-PRTH.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-98201-Update-SecurityFunction-for-PRTH.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-98314_DML_Inserting_records_for_already_imported_cms_templates.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

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




-- CORE-98314	
-- Written By:   Yevgen Voroshylov
-- Reviewed By:
--
-- Script Type:          
-- Target DB Type:       CLIENT
-- Target ENVIRONMENT:   BOTH
--
--
-- Re-Runnable:          YES
--
-- Where tested:         local docker dev environment
--
--
-- =================================================================================

IF NOT EXISTS 
(
	SELECT * FROM dbo.as_std_assessment_cms_template_replace 
	WHERE cms_template_id = 'b66aac6b-0914-4c4e-8e2f-9bc4b2e4efbf'
	AND system_type_id = 264 
)
INSERT INTO as_std_assessment_cms_template_replace(cms_template_id, system_type_id)
VALUES('b66aac6b-0914-4c4e-8e2f-9bc4b2e4efbf', 264)	


IF NOT EXISTS 
(
	SELECT * FROM dbo.as_std_assessment_cms_template_replace 
	WHERE cms_template_id = '54f30f93-9d6f-41c5-be04-afb3af5dcf2e'
	AND system_type_id = 283 
)
INSERT INTO as_std_assessment_cms_template_replace(cms_template_id, system_type_id)
VALUES('54f30f93-9d6f-41c5-be04-afb3af5dcf2e', 283)	


IF NOT EXISTS 
(
	SELECT * FROM dbo.as_std_assessment_cms_template_replace 
	WHERE cms_template_id = 'f1787f8e-9c3f-48a4-91cf-35ab399b1955'
	AND system_type_id = 167 
)
INSERT INTO as_std_assessment_cms_template_replace(cms_template_id, system_type_id)
VALUES('f1787f8e-9c3f-48a4-91cf-35ab399b1955', 167)	


IF NOT EXISTS 
(
	SELECT * FROM dbo.as_std_assessment_cms_template_replace 
	WHERE cms_template_id = '7dbd2d85-799c-4b2a-9439-a178930c0df5'
	AND system_type_id = 259 
)
INSERT INTO as_std_assessment_cms_template_replace(cms_template_id, system_type_id)
VALUES('7dbd2d85-799c-4b2a-9439-a178930c0df5', 259)	


IF NOT EXISTS 
(
	SELECT * FROM dbo.as_std_assessment_cms_template_replace 
	WHERE cms_template_id = '1ced38c2-c5fc-44aa-b641-eb6c0bedeb95'
	AND system_type_id = 159 
)
INSERT INTO as_std_assessment_cms_template_replace(cms_template_id, system_type_id)
VALUES('1ced38c2-c5fc-44aa-b641-eb6c0bedeb95', 159)	



GO

print 'B_Upload/02_DML/CORE-98314_DML_Inserting_records_for_already_imported_cms_templates.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-98314_DML_Inserting_records_for_already_imported_cms_templates.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-98811 - 2 - DML - add uuid to cp_std_library.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

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
--  Jira #:             CORE-98811
--  
--  Written By:         Richard Liu
--  
--  Script Type:        DML 
--  Target DB Type:     CLIENT
--  Target Database:    BOTH
--  
--  Re-Runnable:        YES

--  Description:		Column to hold UUIDs to sync data with CMS
--
--  Special Instruction: None    

--===============================================================================================================================================

UPDATE cp_std_library SET library_uuid = '92909ea3-8b32-492e-91a4-d46027552dea' WHERE brand_id = 1 and brand_care_plan_library_key = 'CCL01';
UPDATE cp_std_library SET library_uuid = '45fd0799-730b-40c4-998d-e345091e5d8c' WHERE brand_id = 5 and brand_care_plan_library_key = 'CACCL01';


GO

print 'B_Upload/02_DML/CORE-98811 - 2 - DML - add uuid to cp_std_library.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-98811 - 2 - DML - add uuid to cp_std_library.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-99023_DML_Inserting_records_for_imported_cms_templates.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

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




-- CORE-99023	
-- Written By:   Yevgen Voroshylov
-- Reviewed By:
--
-- Script Type:          
-- Target DB Type:       CLIENT
-- Target ENVIRONMENT:   BOTH
--
--
-- Re-Runnable:          YES
--
-- Where tested:         local docker dev environment
--
--
-- =================================================================================

IF NOT EXISTS 
(
	SELECT * FROM dbo.as_std_assessment_cms_template_replace 
	WHERE cms_template_id = 'ae0b741d-1d74-4a68-8e9d-b097645de92d'
	AND system_type_id = 119 
)
INSERT INTO as_std_assessment_cms_template_replace(cms_template_id, system_type_id)
VALUES('ae0b741d-1d74-4a68-8e9d-b097645de92d', 119)	


IF NOT EXISTS 
(
	SELECT * FROM dbo.as_std_assessment_cms_template_replace 
	WHERE cms_template_id = 'acf7b4c1-3620-4942-9d3f-f63f875b7020'
	AND system_type_id = 262 
)
INSERT INTO as_std_assessment_cms_template_replace(cms_template_id, system_type_id)
VALUES('acf7b4c1-3620-4942-9d3f-f63f875b7020', 262)	


IF NOT EXISTS 
(
	SELECT * FROM dbo.as_std_assessment_cms_template_replace 
	WHERE cms_template_id = 'b8649544-8124-4e7a-b3b7-fa714d5a361e'
	AND system_type_id = 117 
)
INSERT INTO as_std_assessment_cms_template_replace(cms_template_id, system_type_id)
VALUES('b8649544-8124-4e7a-b3b7-fa714d5a361e', 117)	


IF NOT EXISTS 
(
	SELECT * FROM dbo.as_std_assessment_cms_template_replace 
	WHERE cms_template_id = '916dfbf4-e978-4a6d-9afa-87368a9d39bf'
	AND system_type_id = 118 
)
INSERT INTO as_std_assessment_cms_template_replace(cms_template_id, system_type_id)
VALUES('916dfbf4-e978-4a6d-9afa-87368a9d39bf', 118)	


IF NOT EXISTS 
(
	SELECT * FROM dbo.as_std_assessment_cms_template_replace 
	WHERE cms_template_id = 'c9156390-d506-46c6-8bfa-9c8d75498a6b'
	AND system_type_id = 290 
)
INSERT INTO as_std_assessment_cms_template_replace(cms_template_id, system_type_id)
VALUES('c9156390-d506-46c6-8bfa-9c8d75498a6b', 290)	


IF NOT EXISTS 
(
	SELECT * FROM dbo.as_std_assessment_cms_template_replace 
	WHERE cms_template_id = '921ede4c-0bf8-48a4-b1ee-0bc38f06d7e1'
	AND system_type_id = 157 
)
INSERT INTO as_std_assessment_cms_template_replace(cms_template_id, system_type_id)
VALUES('921ede4c-0bf8-48a4-b1ee-0bc38f06d7e1', 157)


GO

print 'B_Upload/02_DML/CORE-99023_DML_Inserting_records_for_imported_cms_templates.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-99023_DML_Inserting_records_for_imported_cms_templates.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/US_Only/CORE-75519-DML-Update_showHipps_field_in_ub_rule_to_Y_for_pdpm_payers.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

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


-- *****************************************************************************
-- Jira: CORE-75519
--
--
-- Written By:      Shino Johnson
-- 
-- Script Type:     DML
-- Target DB Type:  Client Database
-- Target Database: US
--
-- Re-Runable:      Yes
--
-- Description of Script Function:
--     Update showHipps field in ub_rule to Y for pdpm payers
--
-- Special Instruction: None
-- ****************************************************************************
DECLARE @vPdpmStartDate DATETIME
DECLARE @vCount INTEGER

SET @vPdpmStartDate = '2019-10-01 00:00:00.000'

BEGIN
	SELECT @vCount = COUNT(*)
	FROM FACILITY
	WHERE DELETED <> 'Y'
		AND FAC_ID <> 9001;

	IF @vCount > 1
	BEGIN
		UPDATE ub
		SET ub.show_hipps_on_0022_flag = 1
			,revision_by = 'CORE-75519'
			,revision_date = GETDATE()
		FROM ar_lib_ub_rule AS ub
		INNER JOIN ar_lib_date_range adr ON ub.eff_date_range_id = adr.eff_date_range_id
			AND adr.deleted = 'N'
			AND adr.pdpm_flag = 'Y'
			AND ub.show_hipps_on_0022_flag = 0
			AND adr.eff_date_from >= @vPdpmStartDate;
	END
	ELSE
	BEGIN
		UPDATE ub
		SET ub.show_hipps_on_0022_flag = 1
			,ub.revision_by = 'CORE-75519'
			,ub.revision_date = GETDATE()
		FROM ar_lib_ub_rule ub
		INNER JOIN ar_lib_date_range adr ON ub.eff_date_range_id = adr.eff_date_range_id
		INNER JOIN ar_date_range ar ON adr.eff_date_from = ar.eff_date_from
			AND adr.payer_id = ar.payer_id
			AND ar.pdpm_flag = 'Y'
			AND adr.deleted = 'N'
			AND ar.deleted = 'N'
			AND ar.eff_date_from >= @vPdpmStartDate
			AND ub.show_hipps_on_0022_flag = 0;
	END
END


GO

print 'B_Upload/02_DML/US_Only/CORE-75519-DML-Update_showHipps_field_in_ub_rule_to_Y_for_pdpm_payers.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/US_Only/CORE-75519-DML-Update_showHipps_field_in_ub_rule_to_Y_for_pdpm_payers.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/03_InSequence/CORE-97975-01-DDL-AddLocationStatusTable.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

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
-- Jira #:               CORE-54504 - 01 -  LLM-2 -  Add location status table, Add location status id to facility
--
-- Written By:           Matthew Koval
--
-- Script Type:          DDL
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
--   Add location_status table
--   Add location_status_id to facility
-- 
-- Special Instruction:
-- =================================================================================

--Create the location_status table if it does not already exist
IF NOT EXISTS (SELECT 1 FROM information_schema.tables
               WHERE table_name = 'location_status'
               AND table_schema = 'dbo')
BEGIN
CREATE TABLE [dbo].[location_status]
(
    [location_status_id] SMALLINT NOT NULL,
    [code] NVARCHAR(30) NOT NULL,
    [description] NVARCHAR(60) NOT NULL
     
    CONSTRAINT [location_status__locationStatusId_PK_CL_IX] PRIMARY KEY ([location_status_id])  -- by default primary key is clustered, if specified NONCLUSTERED then use _PK_IX suffix instead
)
END

-- Insert Column, if not already present
IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_schema = 'dbo'
                    AND table_name = 'facility'
                    AND column_name='location_status_id')
BEGIN
	ALTER TABLE facility
	ADD location_status_id SMALLINT NULL
END


GO

print 'B_Upload/03_InSequence/CORE-97975-01-DDL-AddLocationStatusTable.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/03_InSequence/CORE-97975-01-DDL-AddLocationStatusTable.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/03_InSequence/CORE-97975-02-DML-LocationStatusEntriesAndUpdateNullLocationStatusIdsOnFacility.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

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
-- Jira #:               CORE-54504 - 02 - LLM-2 -  add location status entries, update location status on facility table when null
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
--   Add location status records to location status
--   Add location_status_id to facility
-- 
-- Special Instruction:
-- =================================================================================

--DML insert location_status records
IF EXISTS (SELECT 1 FROM information_schema.tables
               WHERE table_name = 'location_status'
               AND table_schema = 'dbo') AND NOT EXISTS (SELECT 1 FROM location_status WHERE code = 'SETUP')
BEGIN
	INSERT INTO location_status(location_status_id, code, description)
	VALUES (1, 'SETUP', 'Setup')
END

IF EXISTS (SELECT 1 FROM information_schema.tables
               WHERE table_name = 'location_status'
               AND table_schema = 'dbo') AND NOT EXISTS (SELECT 1 FROM location_status WHERE code = 'PREVIEW')
BEGIN
	INSERT INTO location_status(location_status_id, code, description)
	VALUES (2, 'PREVIEW', 'Preview')
END

IF EXISTS (SELECT 1 FROM information_schema.tables
               WHERE table_name = 'location_status'
               AND table_schema = 'dbo') AND NOT EXISTS (SELECT 1 FROM location_status WHERE code = 'LIVE')
BEGIN
	INSERT INTO location_status(location_status_id, code, description)
	VALUES (3, 'LIVE', 'Live')
END

IF EXISTS (SELECT 1 FROM information_schema.tables
               WHERE table_name = 'location_status'
               AND table_schema = 'dbo') AND NOT EXISTS (SELECT 1 FROM location_status WHERE code = 'SCHEDULED CHANGE')
BEGIN
	INSERT INTO location_status(location_status_id, code, description)
	VALUES (4, 'SCHEDULED CHANGE', 'Scheduled Change')
END

IF EXISTS (SELECT 1 FROM information_schema.tables
               WHERE table_name = 'location_status'
               AND table_schema = 'dbo') AND NOT EXISTS (SELECT 1 FROM location_status WHERE code = 'READ ONLY')
BEGIN
	INSERT INTO location_status(location_status_id, code, description)
	VALUES (5, 'READ ONLY', 'Read-Only')
END

IF EXISTS (SELECT 1 FROM information_schema.tables
               WHERE table_name = 'location_status'
               AND table_schema = 'dbo') AND NOT EXISTS (SELECT 1 FROM location_status WHERE code = 'MAINTENANCE MODE')
BEGIN
	INSERT INTO location_status(location_status_id, code, description)
	VALUES (6, 'MAINTENANCE MODE', 'Maintenance Mode')
END

IF EXISTS (SELECT 1 FROM information_schema.tables
               WHERE table_name = 'location_status'
               AND table_schema = 'dbo') AND NOT EXISTS (SELECT 1 FROM location_status WHERE code = 'INACTIVE')
BEGIN
	INSERT INTO location_status(location_status_id, code, description)
	VALUES (7, 'INACTIVE', 'Inactive')
END

IF EXISTS (SELECT 1 FROM information_schema.tables
               WHERE table_name = 'location_status'
               AND table_schema = 'dbo') AND NOT EXISTS (SELECT 1 FROM location_status WHERE code = 'ARCHIVED')
BEGIN
	INSERT INTO location_status(location_status_id, code, description)
	VALUES (8, 'ARCHIVED', 'Archived')
END


-- Update null column values, if column is present
IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_schema = 'dbo'
                    AND table_name = 'facility'
                    AND column_name='location_status_id')
BEGIN
	UPDATE facility
	SET location_status_id = 
	CASE 
		WHEN inactive = 'Y'
		THEN 7 --'Inactive'
		WHEN deleted = 'Y'
		THEN 8 --'Archive' 
		ELSE 3 --'Live'
	END 
	WHERE location_status_id IS NULL;
END


GO

print 'B_Upload/03_InSequence/CORE-97975-02-DML-LocationStatusEntriesAndUpdateNullLocationStatusIdsOnFacility.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/03_InSequence/CORE-97975-02-DML-LocationStatusEntriesAndUpdateNullLocationStatusIdsOnFacility.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/03_InSequence/CORE-97975-03-DDL-SetConstraintsOnFacilityTableLocationStatusId.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

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
-- Jira #:               CORE-54504 - 05 - LLM-2 - Update location status id on facility to be not nullable,
--												   Update location status id on facility to default it
--
-- Written By:           Matthew Koval
--
-- Script Type:          DDL
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
--   Make location status Id not nullable, and default to setup
-- 
-- Special Instruction:
-- =================================================================================

--If column exists, add foreign key constraint
IF NOT EXISTS (SELECT 1 FROM sysobjects
 WHERE name = 'facility__locationStatusId_FK')
 AND EXISTS (SELECT 1 FROM information_schema.columns
 WHERE table_name = 'facility'
 AND column_name = 'location_status_id'
 AND table_schema = 'dbo')
BEGIN
 ALTER TABLE facility
 ADD CONSTRAINT facility__locationStatusId_FK
 FOREIGN KEY ([location_status_id])
 REFERENCES [location_status] ( [location_status_id] )
END

--Default to setup / under configuration
IF NOT EXISTS (SELECT 1 FROM sysobjects
               WHERE name = 'facility__locationStatusId_DFLT')
BEGIN
      ALTER TABLE dbo.facility
      ADD CONSTRAINT facility__locationStatusId_DFLT
      DEFAULT 1 FOR location_status_id-- 1 is 'Setup'
END


-- Set location status id to not nullable.
IF EXISTS (SELECT 1 FROM information_schema.columns
	WHERE table_schema = 'dbo'
	AND table_name = 'facility'
	AND column_name='location_status_id'
	AND IS_NULLABLE = 'YES')
BEGIN
	ALTER TABLE dbo.facility 
	ALTER COLUMN location_status_id SMALLINT NOT NULL
END


GO

print 'B_Upload/03_InSequence/CORE-97975-03-DDL-SetConstraintsOnFacilityTableLocationStatusId.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/03_InSequence/CORE-97975-03-DDL-SetConstraintsOnFacilityTableLocationStatusId.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

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
values ('4.4.9_B', 'upload_history')


GO

print '..\Update db version.sql --****SCRIPT DONE****'

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking (script,timestamp,upload) values ('UPLOAD END',getdate(),'4.4.9_06_CLIENT_B_Upload_US.sql')