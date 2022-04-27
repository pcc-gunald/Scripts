SET NOCOUNT ON
GO

SET DEADLOCK_PRIORITY HIGH
GO


insert into upload_tracking (script, timestamp, upload) values ('UPLOAD_START',getdate(),'4.4.9.3_06_CLIENT_C_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('C_Branch/04_StoredProcedures/sproc_prp_rl_rent_roll_report3.sql',getdate(),'4.4.9.3_06_CLIENT_C_Branch_US.sql')

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
===================================================================================================== 
PCC-54915:             Script to create [sproc_prp_rl_rent_roll_report3] Procedure  in Client Database

Written By:            Dominic Christie
Reviewed By:         
 
PCC-96830:             Migrate Stored Procedures
Revision By:           Thomas Kim
Reviewed By:    

Script Type:           DDL 
Target DB Type:        Client Database
Target ENVIRONMENT:    BOTH
 
Re-Runable:            YES
 
Description of Script: Display rent charges for beds in all rooms.
 
Special Instruction:  
=====================================================================================================
*/

IF EXISTS ( SELECT   ROUTINE_SCHEMA, ROUTINE_NAME, ROUTINE_TYPE 
				FROM INFORMATION_SCHEMA.ROUTINES
				WHERE ROUTINE_SCHEMA = 'dbo' and ROUTINE_NAME = 'sproc_prp_rl_rent_roll_report3' and ROUTINE_TYPE = 'PROCEDURE' ) 
BEGIN
	DROP PROCEDURE dbo.sproc_prp_rl_rent_roll_report3
END
GO

CREATE Procedure dbo.sproc_prp_rl_rent_roll_report3  
	  @fac_id INT
	, @room_status VARCHAR(2500)
	, @show_empty_companion_beds BIT
	, @show_occupied_companion_beds BIT
	, @living_unit_id INT
	, @effective_date DATETIME
	, @execution_user_login VARCHAR(60)
	, @enforce_max_weight_flag BIT
	, @order_by INT = 0					-- 0(default) - by room, 1 - by last name, 2 - by first name
	, @report_format_type VARCHAR(3)	-- pdf or csv
	, @emc_flag BIT = 0
	, @rows_returned INT OUT
	, @debug_me CHAR(1) = 'N'
	, @status_code INT  OUT
	, @status_text VARCHAR(3000) OUT
  
/****************************************************************************************************  
--SAMPLE EXECUTION SCRIPT  
  
DECLARE @rows_ret int, @statuscode int, @statustext VARCHAR(3000);
EXEC dbo.sproc_prp_rl_rent_roll_report3
	@fac_id = 1,
	@room_status = '-1',
	@show_empty_companion_beds = 1,
	@show_occupied_companion_beds = 1,
	@living_unit_id = -1,
	@effective_date = '2020-07-30',
	@execution_user_login = 'pcc-parras',	-- use your pcc login here or script won't return any results
	@enforce_max_weight_flag = 1,
	@order_by = 0,							-- 0(default) - by room, 1 - by last name, 2 - by first name
	@report_format_type = 'pdf',			-- if not pdf, then csv
	@emc_flag = 0,
	@rows_returned = 0,
	@debug_me = 'Y',
	@status_code = null,
	@status_text = null;
SELECT @rows_ret, @statuscode int, @statustext;
*****************************************************************************************************/  

AS
BEGIN

SET NOCOUNT ON;  

--DECLARE Standard local variables required for any store proc  
DECLARE @vStep INT  
	,@vErr VARCHAR(MAX)  
	,@vRowCount INT  
	,@vLivingUnitID INT  
	,@vEffectiveDate DATETIME = CONVERT(DATE, @effective_date)	 -- truncate time
	,@vFirstDay DATETIME  
	,@vEndOfMonth DATETIME  
	,@vRoomStatus VARCHAR(2500)   
	,@vTotalDaysInMonth INT
	,@Today DATETIME = CONVERT(DATE, GETDATE())
	;
----Local Variables  
DECLARE @vFacId int  
	,@vReportId int  
	,@vCHARNewLine  CHAR(2)  
	,@vdelim CHAR(1)  
	,@visemc BIT  
	,@vselected_parameters VARCHAR(4000)
	,@vDefaultPayerID INT
	,@vDefaultEmptyBedScheduleID INT
	,@vZeroWeightRateId INT
	,@vDefaultSecurityDepositPayerId INT
;  
  
DECLARE @vFacIDs VARCHAR(max);
DECLARE @PRP_FacList as table(FacId int);
DECLARE @vFacWarningMsg VARCHAR(max);
DECLARE @vOrderBy INT = @order_by;
  
-----Governor and Statistics Variables   
DECLARE
	 @vgs_program_name VARCHAR(200) = Object_name(@@ProcID)  ---Current Store Proc Name  
	,@vgs_executiON_user VARCHAR(60)  
	,@vgs_fill_END_time DATETIME  
	,@vGeneric_statuscode int   
	,@vGeneric_statustext VARCHAR(3000)  
	,@vgsStepStartTime DATETIME  
	,@vgsTotalStartTime DATETIME  
	,@vgsFacID VARCHAR(max)		
	,@vgsParamName1 VARCHAR(12) 
	,@vgsParamValue1 VARCHAR(2500) 
	,@vgsParamName2 VARCHAR(19) 
	,@vgsParamValue2 VARCHAR(254) 
	,@vgsParamName3 VARCHAR(25)
	,@vgsParamValue3 VARCHAR(17)
	;

DECLARE 
	  @exclStatusType       CHAR (1)    = 'V'
	, @exclActionDischarge  VARCHAR(10) = 'Discharge'
	, @exclActionDeath		VARCHAR(10) = 'Death'
	;

BEGIN TRY

	SET @vStep = 1;
	SET @vgsStepStartTime = GETDATE();
	SET @vgsTotalStartTime = @vgsStepStartTime;
	IF @debug_me='Y'
	BEGIN
		IF @vgs_program_name IS NULL
			SET @vgs_program_name = 'SprocCodeTest'

		PRINT 'Executing store proc :  ' + @vgs_program_name  + CONVERT(VARCHAR(26), @vgsStepStartTime, 109);
		PRINT 'STEP ' + CONVERT(VARCHAR(20), @vStep) 
			+ ' Set vars and Getting Parameter Details for Statistics Logging and Report Selection Header :  ' + @vgs_program_name  + CONVERT(VARCHAR(26), @vgsStepStartTime, 109);
	END

	IF (@fac_id IS NULL  
		OR @execution_user_login IS NULL
		OR @living_unit_id IS NULL
		OR @effective_date IS NULL
		OR @room_status IS NULL
		)
	BEGIN
		SET @vErr = 'One or more of the following input parameters is invalid... '  
			+ ' @fac_id=' + isNULL(CONVERT(VARCHAR(10),@fac_id),'NULL/empty')  
			+ ', @execution_user_login=' + isNULL(@execution_user_login,'NULL/empty')  
			+ ', @living_unit_id=' + isNULL(CONVERT(VARCHAR(10),@living_unit_id),'NULL/empty')  
			+ ', @effective_date=' + isNULL(CONVERT(VARCHAR(26),@effective_date,109),'NULL/empty')  
			+ ', @room_status=' + isNULL(@room_status,'NULL/empty');
  
		RAISERROR (@vErr -- Message text  
					,11 -- Severity (RAISERROR with severity 11-19 will cause executiON to jump to the CATCH block)  
					,1 -- State  
			);  
	END  
  
	--SET Standard variables
	SET @status_code = 0;   ---- Status Code 0 = Success, 1 = Exception  
	SET @status_text = NULL;  
	SET @rows_returned = 0;  
	SET @vgs_execution_user = @execution_user_login; 
	SET @vdelim = ','
	SET @vCHARNewLine  = CHAR(13) + CHAR(10); 

	----Parameter Sniffing - use local variables when they are used in a where clause  
	SET @vFacID = @fac_id;
	SET @vLivingUnitID = @living_unit_id;  
	SET @vRoomStatus = @room_status;
	SET @vFirstDay = DATEADD(DAY, 1, EOMONTH(@vEffectiveDate, -1));
	SET @vEndOfMonth = DATEADD(DAY, 1, EOMONTH(@vEffectiveDate));
	SET @vEndOfMonth = DATEADD(SECOND, -1, @vEndOfMonth);

	SET @vTotalDaysInMonth = DAY(EOMONTH(@vEffectiveDate));
	-- set all the parameter name for statistics logging and for the Report Selection Header

	IF (@debug_me = 'Y')
		SELECT '@vEndOfMonth', @vEndOfMonth;

	SET @vgsParamName1  = 'Status';
	SET @vgsParamValue1 = IIF(@vRoomStatus = '-1', 'All', @vRoomStatus);

	SELECT @vgsParamName2 = term_room + ' Type'	
	FROM [dbo].fn_prp_get_terminology(@vFacID, @emc_flag) 
	WHERE fac_id=@vFacID 

	SELECT @vgsParamName3 = 'Show Companion ' + term_beds
	FROM [dbo].fn_prp_get_terminology(@vFacID, @emc_flag) 
	WHERE fac_id = @vFacID;

	SET @vgsParamValue3 =	CASE
								WHEN @show_empty_companion_beds = 1 AND @show_occupied_companion_beds = 1 
									THEN 'All'
								WHEN @show_empty_companion_beds = 1 OR @show_occupied_companion_beds = 1 
									THEN IIF(@show_empty_companion_beds = 1, 'Empty', 'Occupied')
								ELSE 'None'
							END;

	--Get default private payer for the facility
	SET @vDefaultPayerID = (
		SELECT TOP(1) default_payer_id
		FROM ar_configuration
		WHERE (fac_id = @fac_Id	OR fac_id = -1)
			AND default_payer_id IS NOT NULL
	);

	IF @debug_me = 'Y'
		SELECT '@vDefaultPayerID', @vDefaultPayerID

	SET @vDefaultSecurityDepositPayerId = (
		SELECT TOP(1) default_security_deposit_payer_id
		FROM ar_configuration
		WHERE (fac_id = @fac_Id	OR fac_id = -1)
			AND default_security_deposit_payer_id IS NOT NULL
	);
	IF @vLivingUnitID=-1
		SELECT @vgsParamValue2 = 'All';
	ELSE 
		SELECT @vgsParamValue2 = item_Description
		FROM common_code
		WHERE item_code='rtype'
			AND deleted='N'
			AND item_id=@vLivingUnitID

	SELECT @vselected_parameters = '    ' + @vgsParamName2 + ': ' + @vgsParamValue2 
		+ '    ' + @vgsParamName1 + ': ' +  @vgsParamValue1
		+ '    ' + @vgsParamName3 + ': ' +  @vgsParamValue3

	IF @debug_me='Y'
	BEGIN
		PRINT 'selected_parameters:' + @vselected_parameters;
		PRINT 'STEP ' +  CONVERT(VARCHAR(20), @vStep) + ' complete: '+ltrim(rtrim(str(DATEDIFF(ms, @vgsStepStartTime, GETDATE()))))+ ' ms';
	END;


	SET @vStep = 2; 
	SET @vgsStepStartTime = GETDATE();
	IF @debug_me='Y' 
		PRINT 'STEP ' + CONVERT(VARCHAR(20), @vStep)
			+ ' Getting user access fac list '  + @vgs_program_name  + CONVERT(VARCHAR(26), @vgsStepStartTime, 109);
  
	 SELECT  @vFacIds = fac_id, @vFacWarningMsg = msg
	 FROM  dbo.fn_prp_get_facility_access_list_delim(@fac_id,@vgs_execution_user); ---filter the fac list with user access  

	 IF @debug_me='Y'
		PRINT 'STEP ' + CONVERT(VARCHAR(20), @vStep)
			+ ' Facilities returned=[' + isNULL(@vFacIds,'NULL') + '] Facility access warning message=[' + isNULL(@vFacWarningMsg,'') + '] ' + CONVERT(VARCHAR(26),getdate(),109);
  
	 --facilities warnings  
	 IF @vFacWarningMsg is NOT NULL --- NOT NULL means restricted facilities access warning message  
	 BEGIN  
	  SET @status_code = 2; ----Set it to warning status  
	  SET @status_text = isNULL(@status_text,'') + @vFacWarningMsg;  
	 END   
  
	--fill facids into @PRP_FacList   
	 SELECT  @vFacId = Cast(items as int)
	 FROM dbo.Split(@vFacIds,@vDelim);  ----ONly ONe FacId is expected at a time

	 IF @@ROWCOUNT = 0  ---- only if there is any FacCount proceed further  
	 BEGIN  
	  IF @status_code = 0 
		SET @status_code = 3; --Set it to error status  
	  RAISERROR( @status_text,11,1);  
	 END   
  
	if @debug_me='Y' Print 'STEP ' +  CONVERT(VARCHAR(20), @vStep)  + ' complete: ' + LTRIM(RTRIM(STR(DATEDIFF(ms, @vgsStepStartTime, GETDATE()))))+ ' ms';
  
  
	SET @vStep = 3;
	SET @vgsStepStartTime = GETDATE();
	IF @debug_me='Y'
		PRINT 'STEP ' + CONVERT(VARCHAR(20), @vStep)
			+ ' Creating Temp Tables and Table Variables Required for The Proc '  + @vgs_program_name  + CONVERT(VARCHAR(26), @vgsStepStartTime, 109);

	DECLARE @room_sum_for_jrxml TABLE
		(room_id					INT
		,total_market_rate			MONEY
		,total_actual_rate			MONEY
		,total_discount				MONEY
		,total_deposit_received		MONEY
		,bed_count					INT
		,total_occupied_weight		FLOAT
		);

	DECLARE @availableOccupiedDays TABLE (
		  bed_id         INT
		, occupied_days  INT
		, available_days INT
	);

	CREATE TABLE #RentRollData
		(fac_id INT  
		,room_id INT  
		,bed_id INT
		,client_id INT
		,room_desc VARCHAR(60)  
		,bed_desc VARCHAR(30)  
		,room_type  VARCHAR(250)  
		,sq_footage INT  
		,market_rate  MONEY
		,actual_rate  MONEY
		,room_rate VARCHAR(50)   
		,rate_type_id INT
		,weight float
		,primary_payer_name VARCHAR(50)
		,discount MONEY
		,deposit_required BIT
		,deposit_amount MONEY
		,deposit_received MONEY  
		,lease_start_date DATETIME   
		,lease_end_date DATETIME 
		,estimated_move_out DATETIME
		,occupied_days INT DEFAULT(0)
		,vacant_days INT DEFAULT(0)
		,bed_status  VARCHAR(250) 
		,bed_status_id CHAR(1) DEFAULT(0) 
		,room_status  VARCHAR(250)
		,bed_count INT 
		,inactive_no_show BIT
		,inactive_Days SMALLINT
		-----------These Columns are added to facilitate the summary calculation in JRXML
		,is_unit_occupied INT  
		,is_bed_occupied INT 
		,occupied_market_rate MONEY
		,occupied_actual_rate MONEY
		,occupied_discount MONEY
		,occupied_sq_footage  INT
		,occupied_bed_id INT
		,occupied_room_id INT
		,total_deposit_required  MONEY  
		,Status_type VARCHAR(150)
		,is_bed_addnl_bed BIT 
		,is_bed_addnl_row_UPT BIT
		,is_rv_weight_1  CHAR(1)   DEFAULT(0) 
		,is_market_rate BIT
		,is_companion BIT
		,anniversary_date DATETIME
		,is_incomplete_census BIT
		);  
  
	IF @debug_me='Y'
		PRINT 'STEP ' +  CONVERT(VARCHAR(20), @vStep)  + ' complete: '+ltrim(rtrim(str(DATEDIFF(ms, @vgsStepStartTime, GETDATE()))))+ ' ms';
  
  
	SET @vStep = 4;
	SET @vgsStepStartTime = GETDATE();
	IF @debug_me='Y' 
		PRINT 'STEP ' + CONVERT(VARCHAR(20), @vStep)
			+ ' Getting Default Rates and Dates for Rooms '  + @vgs_program_name  + CONVERT(VARCHAR(26), @vgsStepStartTime, 109);

	--Get standard schedule ID

	SELECT @vDefaultEmptyBedScheduleID = (
		SELECT TOP 1 alrs.schedule_id 
		FROM dbo.ar_lib_rate_schedule alrs WITH (NOLOCK)
			JOIN ar_rate_schedule ars WITH (NOLOCK)
				ON ars.schedule_id = alrs.schedule_id
					AND ars.fac_id = @vFacID
			JOIN ar_rate_status arss WITH (NOLOCK)
				ON arss.payer_id = @vDefaultPayerID
					AND arss.fac_id = ars.fac_id
					AND arss.schedule_id = ars.schedule_id
		WHERE alrs.deleted = 'N' 
			AND ((alrs.reg_id IS NULL AND (alrs.fac_id = '-1' OR alrs.fac_id = @vFacID)) OR (alrs.reg_id IS NOT NULL))
			AND alrs.description LIKE 'Standard%' 
		ORDER BY alrs.schedule_id
	);

	IF @vDefaultEmptyBedScheduleID IS NULL
	BEGIN
		SELECT @vDefaultEmptyBedScheduleID = (
			SELECT TOP 1 alrs.schedule_id 
			FROM dbo.ar_lib_rate_schedule alrs WITH (NOLOCK)
				JOIN ar_rate_schedule ars WITH (NOLOCK)
					ON ars.schedule_id = alrs.schedule_id
						AND ars.fac_id = @vFacID
				JOIN ar_rate_status arss WITH (NOLOCK)
					ON arss.payer_id = @vDefaultPayerID
						AND arss.fac_id = ars.fac_id
						AND arss.schedule_id = ars.schedule_id
			WHERE alrs.deleted = 'N' 
				AND ((alrs.reg_id IS NULL AND (alrs.fac_id = '-1' OR alrs.fac_id = @vFacID)) OR (alrs.reg_id IS NOT NULL))
			ORDER BY alrs.schedule_id
			);
	END;

	IF @debug_me = 'Y'
		SELECT '@vDefaultEmptyBedScheduleID', @vDefaultEmptyBedScheduleID;

	SELECT TOP (1) @vZeroWeightRateId = r.rate_type_Id
	FROM ar_rate_type_category c
		JOIN  ar_lib_rate_type l
			ON l.category_id = c.category_id
				AND l.deleted = 'N'
		JOIN ar_rate_type r
			ON r.rate_type_id = l.rate_type_id
				AND r.fac_id = @vFacId
	WHERE c.weight = 0
		AND c.deleted = 'N'
	ORDER BY r.rate_type_Id
	;

	IF @debug_me = 'Y'
		SELECT '@vZeroWeightRateId', @vZeroWeightRateId;

	IF @debug_me = 'Y'
		PRINT 'STEP ' + CONVERT(VARCHAR(20), @vStep)  + ' complete: '+ltrim(rtrim(str(DATEDIFF(ms, @vgsStepStartTime, GETDATE()))))+ ' ms ';


	SET @vStep = 5;
	SET @vgsStepStartTime = GETDATE();
	IF @debug_me='Y'
		PRINT 'STEP ' + CONVERT(VARCHAR(20), @vStep) 
			+ ' Handling the Inactive Beds '  + @vgs_program_name  + CONVERT(VARCHAR(26),GETDATE(),109);

	SELECT bed_id
		, inactive_days = DATEDIFF(dd, IIF(@vFirstDay > startdate, @vFirstDay, startdate), IIF(enddate IS NULL OR enddate > @vEffectiveDate , @vEffectiveDate, enddate)) + 1
	INTO #InactiveBeds
	FROM dbo.bed_state WITH (NOLOCK)
	WHERE deleted = 'N'
		AND startdate <= @vEffectiveDate
		AND (enddate IS NULL OR enddate > @vFirstDay)
		AND fac_id = @vFacID
	;

	SELECT bed_id
		, inactive_days = SUM(inactive_days)
	INTO #InactiveBedDays
	FROM #InactiveBeds
	GROUP BY bed_id
	;

	IF @debug_me = 'Y'
		PRINT 'STEP ' + CONVERT(VARCHAR(20), @vStep)  + ' complete: '+ltrim(rtrim(str(DATEDIFF(ms, @vgsStepStartTime, GETDATE()))))+ ' ms ';


	SET @vStep = 6;
	SET @vgsStepStartTime = GETDATE();
	IF @debug_me='Y' 
		PRINT 'STEP ' + CONVERT(VARCHAR(20), @vStep) 
			+ ' Getting the Details for OCCUPIED Beds/Clients Rate '  + @vgs_program_name  + CONVERT(VARCHAR(26), @vgsStepStartTime, 109);

	SELECT room.fac_id
		, room.room_id
		, room.room_desc
		, bed.bed_id
		, bed.bed_Desc
		, roomtype.item_description
		, room.square_footage
		, rdr.deposit_required
		, rdr.deposit_amount
		, rdr.rate_type_id
		, total_deposit_required = IIF(rdr.deposit_required = 0, NULL, rdr.deposit_amount)
		, ib.inactive_days
	INTO #RoomBed
	FROM dbo.room WITH (NOLOCK)
		JOIN dbo.bed WITH (NOLOCK)
			ON bed.room_id = room.room_id
				AND bed.fac_id = room.fac_id
				AND bed.deleted = 'N'
				AND (bed.retired_date IS NULL OR bed.retired_date > @vEffectiveDate)
		JOIN dbo.room_date_range rdr WITH (NOLOCK)
			ON rdr.room_id = room.room_id
				AND rdr.deleted = 'N'
				AND rdr.effective_Date <= @vEffectiveDate
				AND (rdr.ineffective_date IS NULL OR rdr.ineffective_Date >= @vEffectiveDate)
		LEFT JOIN dbo.common_code roomtype WITH (NOLOCK)
			ON rdr.accommodation_id = roomtype.item_id
				AND roomtype.deleted='N'
				AND item_code = 'rtype'
		LEFT JOIN #InactiveBedDays ib
			ON ib.bed_id = bed.bed_id
				AND ib.inactive_days >= @vTotalDaysInMonth
	WHERE (@vLivingUnitID = -1 OR roomtype.item_id = @vLivingUnitID) --either ALL or specIFic
		AND room.fac_id = @vFacID
		AND room.deleted = 'N'
		AND ib.bed_id IS NULL
	;

	IF (@debug_me = 'Y')
		SELECT '#RoomBed', * 
		FROM #RoomBed
		ORDER BY room_id, bed_id;

	SELECT crpair.client_id
		, crpair.c_census_id
		, r_census_id = IIF(c.incomplete = 'Y', NULL, crpair.r_census_id)
		, c.status_code_id
		, c.action_code_id
		, c.bed_id
		, status_type = statusCode.action_type
		, actCode.action_type
		, r.actual_accomm_id
		, r.eff_schedule_id
		, c.primary_payer_id
		, primary_payer_name = lpay.description
		, ars.schedule_id
		, r.rugs_code
		, r.alternate_care_level
		, c_effective_date = c.effective_date
		, c_ineffective_date = c.ineffective_date
		, c.incomplete
	    , r_effective_date = r.effective_date
	INTO #CensusDetails
	FROM dbo.fn_census_flattenedFacilitySummary(@vFacID, @vEndOfMonth) crpair
		JOIN census_item c WITH (NOLOCK)
			ON c.census_id = crpair.c_census_id
				AND c.status_code_id NOT IN (-1, 17)
				AND c.effective_date <= @vEndOfMonth
				AND c.deleted = 'N'
		JOIN census_codes statusCode WITH (NOLOCK)
			ON statusCode.item_id = c.status_code_id 
				AND statusCode.deleted = 'N'
				AND statusCode.action_type <> @exclStatusType
		JOIN census_codes actCode WITH (NOLOCK)
			ON actCode.item_id = c.action_code_id 
				AND actCode.deleted = 'N'
				AND (actCode.action_type IS NULL OR actCode.action_type NOT IN (@exclActionDischarge, @exclActionDeath))
		LEFT JOIN census_item r WITH (NOLOCK)
			ON r.census_id = crpair.r_census_id
				AND r.deleted = 'N'
		LEFT JOIN ar_lib_payers lpay WITH (NOLOCK)
			ON lpay.payer_id = c.primary_payer_id
				AND lpay.deleted = 'N'
		LEFT JOIN dbo.ar_rate_status ars WITH (NOLOCK)
			ON ars.status_id = c.status_code_id
				AND ars.fac_id = c.fac_id
				AND ars.payer_id = c.primary_payer_id
	WHERE crpair.stop_billing_flag = 0
	;

	IF (@debug_me = 'Y')
		SELECT '#CensusDetails', * 
		FROM #CensusDetails
		ORDER BY client_id, c_census_id, bed_id;

	SELECT flat.client_id
		, flat.c_census_id
		, flat.r_census_id
		, flat.status_code_id
		, flat.action_code_id
		, flat.status_type
		, flat.action_type
		, flat.bed_id
		, flat.actual_accomm_id
		, flat.eff_schedule_id
		, flat.primary_payer_id
		, flat.primary_payer_name
		, flat.schedule_id
		, flat.rugs_code
		, flat.alternate_care_level
		, flat.c_effective_date
		, flat.c_ineffective_date
		, is_secondary_bed = 0
		, flat.incomplete
	    , flat.r_effective_date
	INTO #CensusPrimarySecondaryBeds
	FROM #CensusDetails flat
	UNION ALL
	SELECT flat.client_id
		, flat.c_census_id
		, flat.r_census_id
		, flat.status_code_id
		, flat.action_code_id
		, flat.status_type
		, flat.action_type
		, secc.bed_id
		, secr.actual_accomm_id
		, secr.eff_schedule_id
		, flat.primary_payer_id
		, flat.primary_payer_name
		, flat.schedule_id
		, flat.rugs_code
		, flat.alternate_care_level
		, flat.c_effective_date
		, flat.c_ineffective_date
		, is_secondary_bed = 1
		, flat.incomplete
	    , flat.r_effective_date
	FROM #CensusDetails flat
		JOIN census_item_secondary_bed secc WITH (NOLOCK)
			ON secc.census_id = flat.c_census_id
		LEFT JOIN census_item_secondary_rate secr WITH (NOLOCK)
			ON secr.census_id = flat.r_census_id
	;

	SELECT psbed.client_id
		, psbed.c_census_id
		, psbed.r_census_id
		, psbed.c_effective_date
		, psbed.c_ineffective_date
		, psbed.status_type
		, psbed.action_type
		, psbed.actual_accomm_id
		, psbed.eff_schedule_id
		, psbed.is_secondary_bed
		, psbed.primary_payer_id
		, psbed.primary_payer_name
		, psbed.schedule_id
		, psbed.rugs_code
		, psbed.alternate_care_level
		, psbed.bed_id
		, bed.room_id
		, rtc.weight
		, lrt.rate_type_id
		, rate_type_description = lrt.long_description
		, bed_row_num = ROW_NUMBER() OVER (PARTITION BY psbed.bed_id ORDER BY psbed.c_effective_date DESC) -- latest client in count, others ignored
		, psbed.incomplete
	    , psbed.r_effective_date
	INTO #CensusBedWeightFiltered
	FROM #CensusPrimarySecondaryBeds psbed
		JOIN #RoomBed bed
			ON bed.bed_id = psbed.bed_id
		LEFT JOIN ar_lib_rate_type lrt WITH (NOLOCK)
			ON lrt.rate_type_id = psbed.actual_accomm_id
				AND lrt.deleted = 'N' 
				AND lrt.version_flag = 1
		LEFT JOIN ar_rate_type_category rtc WITH (NOLOCK)
			ON rtc.category_id = lrt.category_id
				AND rtc.deleted = 'N'
	;

	SELECT cbed.bed_id
		, monthly_reimb_rate = 
			dbo.fn_ar_getCensusMonthlyPayRate
				( cbed.r_census_id
				, cbed.eff_schedule_id
				, cbed.rugs_code
				, cbed.alternate_care_level
				, cbed.is_secondary_bed
				)
		, monthly_pay_rate = 
			CASE
			WHEN effrs.is_market_rate = 1 THEN 
				Round(( effrs.percentage_of_market_rates * mr.monthly_rate ) / 100, 2)
			ELSE
				dbo.fn_ar_getCensusMonthlyRate
					( cbed.r_census_id
					, cbed.eff_schedule_id
					, cbed.rugs_code
					, cbed.alternate_care_level
					, cbed.is_secondary_bed
					)
			END
		, daily_reimb_rate = 
			dbo.fn_ar_getCensusDailyPayRate
				( cbed.r_census_id
				, cbed.eff_schedule_id
				, cbed.rugs_code
				, cbed.alternate_care_level
				, cbed.is_secondary_bed
				)
		, daily_pay_rate = 
			CASE
			WHEN effrs.is_market_rate = 1 THEN 
				Round(( effrs.percentage_of_market_rates * mr.daily_rate ) / 100, 2)
			ELSE
				dbo.fn_ar_getCensusDailyRate
					( cbed.r_census_id
					, cbed.eff_schedule_id
					, cbed.rugs_code
					, cbed.alternate_care_level
					, cbed.is_secondary_bed
					)
			END
		, cbed.client_id
		, rate_type = cbed.rate_type_description
		, rate_type_id = cbed.rate_type_id
		, is_market_rate = ISNULL(effrs.is_market_rate, 0)
		, cbed.eff_schedule_id
	INTO #CensusRateAmount
	FROM #CensusBedWeightFiltered cbed
		LEFT JOIN ar_eff_rate_schedule effrs WITH (NOLOCK)
			ON effrs.eff_schedule_id = cbed.eff_schedule_id
				AND effrs.schedule_id = cbed.schedule_id
				AND effrs.fac_id = @vFacID
				AND effrs.is_market_rate = 1
	    LEFT JOIN ar_date_range effdr WITH (NOLOCK)
	        ON effrs.eff_date_range_id = effdr.eff_date_range_id
		LEFT JOIN ar_market_rates mr WITH (NOLOCK)
		    ON mr.room_id = cbed.room_id
		        AND mr.rate_type_id = effrs.market_rate_type_id
		        AND mr.deleted = 'N'
		LEFT JOIN ar_date_range_market_rates mrd WITH (NOLOCK)
		    ON mrd.eff_date_range_id = mr.eff_date_range_id
		        AND mrd.fac_id = effrs.fac_id
		        AND mrd.deleted = 'N'
		        AND mrd.applied = 1
		        AND mrd.eff_date_from <= COALESCE(effdr.eff_date_from, cbed.r_effective_date)
		        AND (mrd.eff_date_to IS NULL
		                OR COALESCE(effdr.eff_date_from, cbed.r_effective_date) <= mrd.eff_date_to)
	WHERE cbed.r_census_id IS NOT NULL
		AND cbed.bed_row_num = 1
        AND (mr.eff_date_range_id is null or mrd.eff_date_range_id = mr.eff_date_range_id);
	;

	SELECT cbed.status_type
		, cbed.action_type
		, a.rate_type_id
		, a.rate_type room_rate
		, market_rate =	COALESCE(a.monthly_pay_rate  , a.daily_pay_rate * @vTotalDaysInMonth  , a.monthly_reimb_rate, a.daily_reimb_rate * @vTotalDaysInMonth)
		, actual_rate =	COALESCE(a.monthly_reimb_rate, a.daily_reimb_rate * @vTotalDaysInMonth, a.monthly_pay_rate  , a.daily_pay_rate * @vTotalDaysInMonth)
		, cbed.bed_id
		, cbed.room_id
		, cbed.weight
		, cbed.primary_payer_name
		, cbed.client_id
		, a.is_market_rate
		, bed_row_num = ROW_NUMBER() OVER (PARTITION BY cbed.bed_id ORDER BY cbed.c_effective_date DESC) -- latest client in count, others ignored
	INTO #ActualAndMarketRates
	FROM #CensusBedWeightFiltered cbed
		LEFT JOIN #CensusRateAmount a
			ON a.client_id = cbed.client_id
				AND a.bed_id = cbed.bed_id
	;

	SELECT DISTINCT client_id
	INTO #Clients
	FROM #CensusDetails
	;

	SELECT tr.client_id
		, deposit_received = SUM(tr.amount)
	INTO #DepositReceived
	FROM #Clients cl
		JOIN dbo.ar_transactions tr WITH (NOLOCK)
			ON tr.client_id = cl.client_id
				AND tr.payer_id = @vDefaultSecurityDepositPayerId
				AND tr.fac_id = @vFacId
				AND tr.transaction_type = 'C'
				AND tr.is_posted = 1
				AND tr.deleted = 'N'
	GROUP BY tr.client_id
	;

	SELECT a.client_id
		, rla.lease_start_date
		, rla.lease_end_date
		, rla.anniversary_date
		, lease_row_num = ROW_NUMBER() OVER (PARTITION BY a.client_id ORDER BY rla.lease_start_date desc)
	INTO #RentrollLeaseAgreement
	FROM #Clients a
		JOIN dbo.rentroll_lease_agreement rla WITH (NOLOCK)
			ON rla.client_id = a.client_id
				AND rla.lease_start_date <= @vEffectiveDate 
		JOIN  dbo.rentroll_agreement_type agrtype WITH (NOLOCK)
			ON agrtype.agreement_type_id = rla.agreement_type_id 
				AND agrtype.agreement_type IN ('lease','Rent') 
				AND agrtype.active = 1
	;

	INSERT INTO #RentRollData
		( fac_id
		, room_id
		, room_desc
		, bed_id
		, bed_desc
		, client_id
		, room_type
		, sq_footage
		, market_rate
		, actual_rate
		, room_rate
		, rate_type_id
		, weight
		, primary_payer_name
		, discount
		, deposit_required
		, deposit_amount
		, deposit_received
		, bed_status_id
		, is_bed_occupied
		, occupied_market_rate
		, occupied_actual_rate
		, occupied_discount
		, occupied_sq_footage
		, occupied_bed_id
		, occupied_room_id
		, total_deposit_required
		, status_type
		, lease_start_date
		, lease_end_date
		, inactive_no_show
		, inactive_Days
		, is_bed_addnl_bed
		, is_market_rate
		, is_companion
		, anniversary_date
		, is_incomplete_census
		)
	SELECT @vFacId
		, roombed.room_id
		, roombed.room_desc
		, roombed.bed_id
		, roombed.bed_Desc
		, rate.client_id
		, roombed.item_description
		, roombed.square_footage
		, rate.market_rate
		, rate.actual_rate
		, room_rate = IIF(rate.bed_id IS NULL OR rate.client_id IS NULL, censusbed.rate_type_description, rate.room_rate)
		, rate_type_id = COALESCE(rate.rate_type_id, roombed.rate_type_id)
		, weight = rate.weight
		, rate.primary_payer_name
		, discount = rate.market_rate - rate.actual_rate
		, roombed.deposit_required
		, deposit_amount = IIF(roombed.deposit_required = 0, NULL, IIF(rate.bed_id IS NULL, NULL, roombed.deposit_amount * rate.weight))
		, deposit_received = dr.deposit_received * (-1) ----as per the logic for transaction
		, bed_status_id = CASE
			WHEN rate.bed_id IS NULL THEN IIF(ISNULL(roombed.inactive_days, 0) > 0, 5, 4)
			ELSE
				CASE
					WHEN rate.status_type=@exclStatusType THEN 4
					WHEN ((rate.action_type = 'Room Reserve' AND rate.status_type <> @exclStatusType) OR rate.status_type = 'N' ) THEN 2
					ELSE 1
				END
			END
		, is_bed_occupied = CASE WHEN rate.bed_id IS NULL THEN 0 ELSE 1 END
		, occupied_market_rate = rate.market_rate
		, occupied_actual_rate = rate.actual_rate
		, occupied_discount = rate.market_rate - rate.actual_rate
		, occupied_sq_footage = CASE WHEN rate.bed_id IS NULL THEN NULL ELSE roombed.square_footage END
		, occupied_bed_id = rate.bed_id
		, occupied_room_id = rate.room_id
		, total_deposit_required = IIF(roombed.deposit_required = 0, NULL, roombed.deposit_amount)
		, rate.action_type
		, lease_start_date
		, lease_end_date
		, inactive_no_show = IIF(roombed.inactive_days IS NOT NULL AND roombed.inactive_days > 0, 1, 0)
		, roombed.inactive_days
		, is_bed_addnl_bed = ISNULL(censusbed.is_secondary_bed, 0)
		, rate.is_market_rate
		, is_companion = IIF(rate.weight = 0 AND rate.bed_id IS NOT NULL, 1, NULL)
		, rla.anniversary_date
		, is_incomplete_census = IIF(censusbed.incomplete = 'Y', 1, 0)
	FROM #RoomBed roombed
		LEFT JOIN #ActualAndMarketRates rate
			ON rate.bed_id = roombed.bed_id
				AND rate.bed_row_num = 1
		LEFT JOIN #CensusBedWeightFiltered censusbed
			ON censusbed.bed_id = roombed.bed_id
				AND censusbed.bed_row_num = 1
		LEFT JOIN #RentrollLeaseAgreement rla
			ON rla.client_id = rate.client_id 
				AND lease_row_num = 1
		LEFT JOIN #DepositReceived dr
			ON dr.client_id = rate.client_id
				AND ISNULL(censusbed.is_secondary_bed, 0) = 0
	;

	IF @debug_me='Y'
		SELECT '#RentRollData1', * 
		FROM #RentRollData
		ORDER BY room_id, bed_id, client_id;

	IF @debug_me='Y'
		PRINT 'STEP ' +  CONVERT(VARCHAR(20), @vStep)  + ' (OCCUPIED) complete: '+ltrim(rtrim(str(DATEDIFF(ms, @vgsStepStartTime, GETDATE()))))+ ' ms';


	SET @vStep = 7;
	SET @vgsStepStartTime = GETDATE();
	IF @debug_me='Y' 
		PRINT 'STEP ' + CONVERT(VARCHAR(20), @vStep) 
			+ ' Getting the Details for EMPTY Beds'  + @vgs_program_name  + CONVERT(VARCHAR(26), @vgsStepStartTime, 109);

	SELECT s.schedule_id
		, s.eff_date_range_id
		, s.fac_id
		, s.eff_schedule_id
		, s.rate_type_id
		, s.is_manual_rate
		, s.is_manual_pay_rate
		, care_level_code = cti.care_level_code
		, s.is_custom_rate
		, alt.is_alt
		, s.is_market_rate
		, care_level_template_id = cti.care_level_template_id
		, s.rate_template_id
		, adr.eff_date_from
		, s.pay_rate_template_id
		, s.rate_template_pct
		, s.pay_rate_template_pct
	INTO #ScheduleDetails
	FROM ar_eff_rate_schedule s
		JOIN ar_date_range adr
			ON adr.eff_date_range_id = s.eff_date_range_id
				AND adr.fac_id = s.fac_id
				AND adr.deleted = 'N'
				AND adr.eff_date_from <= @vEffectiveDate
				AND (adr.eff_date_to >= @vEffectiveDate OR adr.eff_date_to IS NULL)
				AND adr.payer_id = @vDefaultPayerID
		CROSS JOIN (
				SELECT 0 AS is_alt
				UNION ALL
				SELECT 1
			) alt
		LEFT JOIN dbo.ar_lib_care_level_template_item cti WITH (NOLOCK)
			ON ((alt.is_alt = 1 AND adr.alt_care_level_template_id = cti.care_level_template_id)
					OR (alt.is_alt = 0 AND adr.care_level_template_id = cti.care_level_template_id))
				AND cti.effective_date <= adr.eff_date_from
				AND (cti.ineffective_date >= adr.eff_date_from OR cti.ineffective_date IS NULL)
				AND cti.deleted = 'N'
	WHERE s.schedule_id = @vDefaultEmptyBedScheduleID
	;

	SELECT aers.schedule_id
		, aers.eff_date_range_id
		, aers.fac_id
		, aers.eff_schedule_id
		, aers.rate_type_id
		, amr.room_id
		, monthly_rate = ROUND(( aers.percentage_of_market_rates * amr.monthly_rate ) / 100, 2)
		, daily_rate = ROUND(( aers.percentage_of_market_rates * amr.daily_rate ) / 100, 2)
	INTO #MarketRates
	FROM ar_eff_rate_schedule aers
		JOIN dbo.ar_market_rates amr
			ON aers.is_market_rate = 1
				AND amr.eff_date_range_id = aers.market_date_range_id
				AND amr.deleted = 'N'
				AND amr.rate_type_id = aers.market_rate_type_id
		JOIN ar_date_range_market_rates adrmr
			ON adrmr.eff_date_range_id = aers.market_date_range_id
				AND adrmr.fac_id = aers.fac_id
				AND adrmr.deleted = 'N'
				AND adrmr.eff_date_from <= @vEffectiveDate
				AND (adrmr.eff_date_to >= @vEffectiveDate OR adrmr.eff_date_to IS NULL)
				AND adrmr.applied = 1
	WHERE aers.fac_id = @vFacId
		AND aers.is_market_rate = 1
		AND aers.schedule_id = @vDefaultEmptyBedScheduleID
	;

	SELECT s.schedule_id
		, s.eff_date_range_id
		, s.fac_id
		, s.eff_schedule_id
		, s.rate_type_id
		, r.monthly_rate
		, r.daily_rate
		, sequence_no = cti.sequence_no
		, care_level_id = cti.care_level_id
	INTO #ManualRates
	FROM #ScheduleDetails s
		JOIN dbo.ar_rate_detail r WITH (NOLOCK) -- Manual rate.
			ON r.eff_schedule_id = s.eff_schedule_id
				AND(s.is_manual_rate = 1 OR s.is_manual_pay_rate = 1)
				AND s.is_alt = 0
				AND (r.care_level = s.care_level_code OR s.is_custom_rate = 1)
				AND r.fac_id = @vFacId
		LEFT JOIN ar_eff_rate_schedule ers
			ON ers.eff_schedule_id = r.eff_schedule_id
		LEFT JOIN ar_date_range adr
			ON adr.eff_date_range_id = ers.eff_date_range_id
				AND adr.deleted = 'N'
		LEFT JOIN ar_lib_care_level_template_item cti
			ON cti.care_level_template_id = adr.care_level_template_id
				AND cti.care_level_code = r.care_level
				AND cti.deleted = 'N'
	WHERE s.fac_id = @vFacId
		AND s.is_manual_rate = 1
	;

	SELECT t.rate_template_id,
		   t.care_level_template_id,
		   i.effective_date,
		   i.ineffective_date,
		   c.care_level_id,
		   c.care_level_code,
		   c.sequence_no as care_level_sequence_no,
		   r.daily_rate,
		   r.monthly_rate
	INTO #RateTemplate
	FROM ar_lib_rate_template t
		JOIN ar_lib_care_level_template ct 
			ON t.care_level_template_id = ct.care_level_template_id
		JOIN ar_lib_rate_template_info i 
			ON t.rate_template_id = i.rate_template_id
				AND i.is_accepted = 1
		JOIN ar_lib_care_level_template_item c 
			ON t.care_level_template_id = c.care_level_template_id
				AND i.effective_date >= c.effective_date 
				AND (i.effective_date <= c.ineffective_date OR c.ineffective_date IS NULL)
		LEFT JOIN ar_lib_rate_template_rate r 
			ON r.rate_template_info_id = i.rate_template_info_id
				AND r.care_level_id = c.care_level_id
	;

	SELECT s.schedule_id
		, s.eff_date_range_id
		, s.fac_id
		, s.eff_schedule_id
		, s.rate_type_id
		, monthly_rate = rt.monthly_rate * (s.rate_template_pct / 100)
		, daily_rate = rt.daily_rate * (s.rate_template_pct / 100)
		, s.is_alt
		, rt.care_level_sequence_no
		, rt.care_level_id
	INTO #TemplateRates
	FROM #ScheduleDetails s
		-- JOIN to templates to get the rate if we are not using a manual rate.
		LEFT JOIN #RateTemplate rt -- Standard template
			ON s.rate_template_id = rt.rate_template_id
				AND s.care_level_template_id = rt.care_level_template_id
				AND s.care_level_code = rt.care_level_code
				AND s.eff_date_from >= rt.effective_date
				AND (s.eff_date_from < rt.ineffective_date OR rt.ineffective_date is NULL)
		LEFT JOIN #RateTemplate pt -- Reimbursement Template
			ON 	s.pay_rate_template_id = pt.rate_template_id
				AND s.is_manual_pay_rate = 0
				AND s.care_level_template_id = pt.care_level_template_id
				AND s.care_level_code = pt.care_level_code
				AND s.eff_date_from >= pt.effective_date
				AND (s.eff_date_from < pt.ineffective_date OR pt.ineffective_date is NULL)
	WHERE s.fac_id = @vFacId
		AND s.is_manual_rate = 0
		AND s.is_market_rate = 0
	;

	SELECT mkt.schedule_id
		, mkt.eff_date_range_id
		, mkt.fac_id
		, mkt.eff_schedule_id
		, mkt.rate_type_id
		, mkt.room_id
		, mkt.monthly_rate
		, mkt.daily_rate
	INTO #AllRateTypes
	FROM #MarketRates mkt
	UNION
	SELECT m.schedule_id
		, m.eff_date_range_id
		, m.fac_id
		, m.eff_schedule_id
		, m.rate_type_id
		, room_id = NULL
		, m.monthly_rate
		, m.daily_rate
	FROM #ManualRates m
	UNION
	SELECT t.schedule_id
		, t.eff_date_range_id
		, t.fac_id
		, t.eff_schedule_id
		, t.rate_type_id
		, room_id = NULL
		, t.monthly_rate
		, t.daily_rate
	FROM #TemplateRates t
	;

	SELECT room_id
		, beds_count = COUNT(*)
	INTO #RoomCapacity
	FROM #RentRollData
	GROUP BY room_id
	;

	SELECT room_id
		, clients_count = COUNT(*)
	INTO #ClientInRoomCount
	FROM #RentRollData
	WHERE is_bed_occupied = 1 
		AND is_incomplete_census = 0
	GROUP BY room_id
	;

	SELECT 
		c.room_id
		, c.clients_count
		, r.beds_count
	INTO #PartiallyOccupiedRoom
	FROM #ClientInRoomCount c
	JOIN #RoomCapacity r
		ON r.room_id = c.room_id
			AND c.clients_count < r.beds_count
	;

	SELECT rc.room_id
	INTO #FullyAvailableRooms
	FROM #RoomCapacity rc
	LEFT JOIN #ClientInRoomCount c
		ON c.room_id = rc.room_id
	WHERE c.room_id IS NULL
	;

	SELECT 
		o.room_id
		, o.bed_id
		, o.is_incomplete_census
	INTO #FullyAvailableRoomBeds
	FROM #RentRollData o
	JOIN #FullyAvailableRooms f
		ON f.room_id = o.room_id
	;

	SELECT DISTINCT 
		rdr.room_id
		, rdr.rate_type_id
		, artc.weight
	INTO #DefaultRoomRateForEmptyBeds
	FROM #RentRollData o
		JOIN dbo.room_date_range rdr
			ON rdr.room_id = o.room_id
				AND rdr.deleted = 'N'
				AND rdr.effective_Date <= @vEffectiveDate
				AND (rdr.ineffective_date IS NULL OR rdr.ineffective_Date >= @vEffectiveDate)
		JOIN ar_lib_rate_type alrt
			ON alrt.rate_type_id = rdr.rate_type_id
				AND alrt.deleted = 'N'
		JOIN ar_rate_type_category artc
			ON artc.category_id = alrt.category_id
				AND artc.deleted = 'N'
	WHERE is_bed_occupied = 0
		OR is_incomplete_census = 1
	;

	SELECT
		rb.room_id 
		, rb.bed_Id
		, cumulative_weight = ROW_NUMBER() OVER (PARTITION BY rb.room_id ORDER BY IIF(rb.is_incomplete_census = 1, 1, 0) DESC, rb.bed_id) * d.weight
	INTO #CumulativeWeightForEmptyRoomBeds
	FROM #FullyAvailableRoomBeds rb
		JOIN #DefaultRoomRateForEmptyBeds d
			ON d.room_id = rb.room_id
	;

	SELECT
		c.room_id 
		, c.bed_Id
		, rate_type_id = Iif(c.cumulative_weight <= 1, d.rate_type_id, NULL)
		, weight = iif(c.cumulative_weight <= 1, d.weight, 0)
		, companion_flag = IIF(c.cumulative_weight > 1, 1, 0)
	INTO #EmptyRoomBedsRateTypes
	FROM #FullyAvailableRoomBeds a
		JOIN #CumulativeWeightForEmptyRoomBeds c
			ON c.room_id = a.room_id
				AND a.bed_id = c.bed_id
		JOIN #DefaultRoomRateForEmptyBeds d
			ON d.room_id = c.room_id
	;

	SELECT 
		room_id
		, weight_sum = SUM(weight)
	INTO #PartiallyOccupiedWeightSum
	FROM #RentRollData
	WHERE weight IS NOT NULL
	GROUP BY room_id
	;

	SELECT 
		s.room_id
		, r.beds_count
		, r.clients_count
		, occupied_weight_sum = s.weight_sum
		, remaining_weight = (1 - s.weight_sum)
	INTO #PartiallyOccupiedWeight
	FROM #PartiallyOccupiedWeightSum s
		JOIN #PartiallyOccupiedRoom r
			ON r.room_id = s.room_id
	;

	SELECT 
		w.room_id
		, category_weight = artc.weight
		, has_remainder = 
			CASE
				WHEN w.remaining_weight = 0 OR artc.weight = 0 THEN 0
				ELSE IIF(CAST(w.remaining_weight AS DECIMAL(5,2)) % CAST(artc.weight AS DECIMAL(5,2)) <= 0.02, 0, 1)
			END
		, beds_covered_by_rate_weight = 
			CASE
				WHEN w.remaining_weight = 0 OR artc.weight = 0 THEN 0
				ELSE CAST(IIF(w.remaining_weight / artc.weight > (w.beds_count - w.clients_count), w.beds_count - w.clients_count, w.remaining_weight / artc.weight) AS INT)
			END
		, art.rate_type_id
		, w.remaining_weight
	INTO #PartiallyOccupiedRateWeightAssignment
	FROM #PartiallyOccupiedWeight w
		JOIN ar_rate_type_category artc 
			ON artc.weight <= w.remaining_weight
				AND artc.deleted = 'N'
		JOIN ar_lib_rate_type alrt
			ON alrt.category_id = artc.category_id
				AND alrt.deleted = 'N'
		JOIN ar_rate_type art
			ON art.rate_type_id = alrt.rate_type_id
				AND art.fac_id = @vFacId
	UNION ALL
	SELECT
		w.room_id
		, 0
		, 0
		, 0
		, NULL
		, w.remaining_weight
	FROM #PartiallyOccupiedWeight w
	;

	SELECT 
		room_id
		, category_weight
		, beds_covered_by_rate_weight
		, rate_type_id
		, rate_type_rank = RANK() OVER (PARTITION BY room_id ORDER BY beds_covered_by_rate_weight DESC, category_weight DESC)
	INTO #PartiallyOccupiedWeightPriority
	FROM #PartiallyOccupiedRateWeightAssignment
	;

	SELECT 
		p.room_id
		, f.bed_id
		, p.category_weight
		, p.beds_covered_by_rate_weight
		, p.rate_type_id
		, empty_bed_rank = DENSE_RANK() OVER (PARTITION BY r.room_id ORDER BY IIF(f.is_incomplete_census = 1, 1, 0) DESC, f.bed_id)
	INTO #PartiallyOccupiedEmptyBedOrder
	FROM #PartiallyOccupiedRoom r
		JOIN #PartiallyOccupiedWeightPriority p
			ON p.room_id = r.room_id
				AND rate_type_rank = 1
		JOIN #RentRollData f
			ON f.room_id = r.room_id
				AND (f.is_bed_occupied = 0 OR f.is_incomplete_census = 1)
	;

	SELECT 
		r.room_id
		, r.bed_id
		, rate_type_id = IIF(r.empty_bed_rank <= r.beds_covered_by_rate_weight, r.rate_type_id, NULL)
		, weight = IIF(r.empty_bed_rank <= r.beds_covered_by_rate_weight, r.category_weight, 0)
		, companion_flag = IIF(r.empty_bed_rank <= r.beds_covered_by_rate_weight, 0, 1)
	INTO #PartiallyOccupiedRoomBedWeights
	FROM #PartiallyOccupiedEmptyBedOrder r
	;

	SELECT 
		e.room_id
		, e.bed_id
		, e.rate_type_id
		, e.weight
		, e.companion_flag
	INTO #EmptyBedRateTypes
	FROM #EmptyRoomBedsRateTypes e
	UNION
	SELECT 
		po.room_id
		, po.bed_id
		, po.rate_type_id
		, po.weight
		, po.companion_flag
	FROM #PartiallyOccupiedRoomBedWeights po
	;

	SELECT DISTINCT
		e.room_id
		, e.bed_id
		, rate_type_id = COALESCE(r.rate_type_id, @vZeroWeightRateId)
		, e.weight
		, e.companion_flag
	INTO #EmptyBedCompanionRateTypes
	FROM #EmptyBedRateTypes e
		LEFT JOIN ar_rate_type_category c
			ON c.weight = e.weight
				AND c.deleted = 'N'
		LEFT JOIN ar_lib_rate_type lib
			ON lib.category_id = c.category_id
				AND lib.deleted = 'N'	
		LEFT JOIN ar_rate_type r
			ON r.rate_type_id = lib.rate_type_id
				AND r.fac_id = @vFacId
	WHERE e.weight = 0
	;

	SELECT 
		e.room_id
		, e.bed_id
		, e.rate_type_id
		, e.weight
		, e.companion_flag
	INTO #EmptyBedAllRateTypes
	FROM #EmptyBedRateTypes e
	WHERE e.weight <> 0
	UNION
	SELECT 
		c.room_id
		, c.bed_id
		, c.rate_type_id
		, c.weight
		, c.companion_flag
	FROM #EmptyBedCompanionRateTypes c
	;

	SELECT m.schedule_id
		, m.eff_date_range_id
		, m.fac_id
		, m.eff_schedule_id
		, m.rate_type_id
		, o.room_id
		, o.bed_id
		, m.monthly_rate
		, m.daily_rate
	INTO #MarketRatesForEmptyBeds
	FROM #EmptyBedAllRateTypes o
		JOIN #MarketRates m
			ON m.rate_type_id = o.rate_type_id
				AND m.room_id = o.room_id
	;

	SELECT m.schedule_id
		, m.eff_date_range_id
		, m.fac_id
		, m.eff_schedule_id
		, m.rate_type_id
		, o.room_id
		, o.bed_id
		, m.monthly_rate
		, m.daily_rate
		, room_care_level_row_num = ROW_NUMBER() OVER(PARTITION BY o.room_id, o.bed_id ORDER BY IIF(m.monthly_rate IS NULL AND m.daily_rate IS NULL, 0, 1) DESC, m.sequence_no, m.care_level_id, m.rate_type_id)
	INTO #ManualRatesForEmptyBedsPrioritized
	FROM #EmptyBedAllRateTypes o
		JOIN #ManualRates m
			ON m.rate_type_id = o.rate_type_id
	;

	SELECT 
		mr.room_id
		, mr.bed_id
		, mr.monthly_rate
		, mr.daily_rate
		, mr.rate_type_id
	INTO #ManualRatesForEmptyBeds
	FROM #ManualRatesForEmptyBedsPrioritized mr
	WHERE mr.room_care_level_row_num = 1
	;

	SELECT t.schedule_id
		, t.eff_date_range_id
		, t.fac_id
		, t.eff_schedule_id
		, t.rate_type_id
		, o.room_id
		, t.monthly_rate
		, t.daily_rate
		, t.is_alt
		, room_care_level_row_num = ROW_NUMBER() OVER(PARTITION BY o.room_id ORDER BY t.is_alt, t.care_level_sequence_no, t.care_level_id)
	INTO #TemplateRatesForEmptyRooms
	FROM #EmptyBedAllRateTypes o
		JOIN #TemplateRates t
			ON t.rate_type_id = o.rate_type_id
	;

	SELECT t.schedule_id
		, t.eff_date_range_id
		, t.fac_id
		, t.eff_schedule_id
		, t.rate_type_id
		, o.room_id
		, o.bed_id
		, t.monthly_rate
		, t.daily_rate
		, t.is_alt
	INTO #TemplateRateForEmptyRoomBeds
	FROM #EmptyBedAllRateTypes o
		JOIN #TemplateRatesForEmptyRooms t
			ON t.room_id = o.room_id
				AND t.room_care_level_row_num = 1
	;

	SELECT
		o.room_id
		, o.bed_id   
		, market_rate = COALESCE(mr.monthly_rate, mkt.monthly_rate, t.monthly_rate, @vTotalDaysInMonth * COALESCE(mr.daily_rate, mkt.daily_rate, t.daily_rate))
		, o.rate_type_id 
		, o.weight
		, room_bed_row_num = ROW_NUMBER() OVER(PARTITION BY o.room_id, o.bed_id ORDER BY IIF((COALESCE(mr.monthly_rate, mkt.monthly_rate, t.monthly_rate, @vTotalDaysInMonth * COALESCE(mr.daily_rate, mkt.daily_rate, t.daily_rate))) IS NULL, 0, 1) DESC)
	INTO #EmptyBedsFinalPrioritized
	FROM #EmptyBedAllRateTypes o
		LEFT JOIN #ManualRatesForEmptyBeds mr
			ON mr.bed_id = o.bed_id
				AND mr.rate_type_id = o.rate_type_id
		LEFT JOIN #MarketRatesForEmptyBeds mkt
			ON mkt.bed_id = o.bed_id
				AND mkt.rate_type_id = o.rate_type_id
		LEFT JOIN #TemplateRateForEmptyRoomBeds t
			ON t.bed_id = o.bed_id
				AND t.rate_type_id = o.rate_type_id
	;

	SELECT
		e.room_id
		, e.bed_id
		, e.market_rate
		, rate_type_id = COALESCE(ebr.rate_type_id, e.rate_type_id)
		, is_companion = CONVERT(BIT, IIF(e.weight = 0, 1, 0))
		, e.weight
	INTO #EmptyBedsWithCompanion
	FROM #EmptyBedsFinalPrioritized e
		LEFT JOIN #EmptyBedAllRateTypes ebr
			ON ebr.bed_id = e.bed_id
				AND ebr.rate_type_id = e.rate_type_id
	WHERE e.room_bed_row_num = 1
	;

	UPDATE rrd
	SET
		market_rate = IIF(rrd.is_incomplete_census = 0, e.market_rate, NULL)
		, rate_type_id = e.rate_type_id
		, room_rate = IIF(rrd.is_incomplete_census = 0, alrt.long_description, NULL)
		, is_companion = e.is_companion
		, weight = e.weight
		, deposit_amount = IIF(rrd.deposit_required = 1, e.weight * rrd.total_deposit_required, NULL)
	FROM #RentRollData rrd
		JOIN #EmptyBedsWithCompanion e
			ON e.bed_id = rrd.bed_id
		LEFT JOIN ar_lib_rate_type alrt
			ON alrt.rate_type_id = e.rate_type_id
				AND alrt.deleted = 'N'
	WHERE rrd.is_bed_occupied = 0
		OR is_incomplete_census = 1;

	IF @debug_me='Y'
		select '#RentRollData2', * 
		from #RentRollData
		order by room_id, bed_id

	IF @debug_me='Y' PRINT 'STEP ' +  CONVERT(VARCHAR(20), @vStep)  + ' (EMPTY) complete: '+ltrim(rtrim(str(DATEDIFF(ms, @vgsStepStartTime, GETDATE()))))+ ' ms';


	SET @vStep = 8;
	SET @vgsStepStartTime = GETDATE();
	IF @debug_me='Y' 
		PRINT 'STEP ' + CONVERT(VARCHAR(20), @vStep) 
			+ ' Preparing SUM for Jrxml and Internal Calculation '  + @vgs_program_name  + CONVERT(VARCHAR(26), @vgsStepStartTime, 109) ;

	INSERT INTO @room_sum_for_jrxml 
		( room_id
		, total_market_rate
		, total_actual_rate
		, total_discount
		, total_deposit_received
		, bed_count
		)
	SELECT room_id
		, total_market_rate = SUM(market_rate)
		, total_actual_rate = SUM(actual_rate)
		, total_discount = SUM(discount)
		, total_deposit_received = SUM(deposit_received)
		, bed_count = SUM(is_bed_occupied)
	FROM #RentRollData rrd
	WHERE (rrd.is_bed_occupied = 0 AND (@show_empty_companion_beds = 1 OR ISNULL(rrd.is_companion, 0) = 0))
		OR (rrd.is_bed_occupied = 1 AND (@show_occupied_companion_beds = 1 OR ISNULL(rrd.is_companion, 0) = 0))
	GROUP BY room_id;

	WITH OccupiedRoomWeights AS (
		SELECT j.room_id
			, weight = ISNULL(SUM(rrd.weight), 0)
		FROM @room_sum_for_jrxml j
			JOIN #RentRollData rrd
				ON rrd.room_id = j.room_id
		WHERE is_bed_occupied = 1
		GROUP BY j.room_id
	)
	UPDATE j
	SET total_occupied_weight = ISNULL(o.weight, 0)
	FROM @room_sum_for_jrxml j
	JOIN OccupiedRoomWeights o
		ON o.room_id = j.room_id;

	IF @debug_me='Y' Print 'STEP ' +  CONVERT(VARCHAR(20), @vStep)  + ' complete: '+ltrim(rtrim(str(DATEDIFF(ms, @vgsStepStartTime, GETDATE()))))+ ' ms';
 
	IF (@debug_me='Y'  or @debug_me='weight')
		SELECT '@room_sum_for_jrxml',* FROM @room_sum_for_jrxml;


	SET @vStep = 9;
	SET @vgsStepStartTime = GETDATE();
	IF @debug_me='Y' 
		PRINT 'STEP ' + CONVERT(VARCHAR(20), @vStep) 
			+ ' Handling the Future Dated Move Out Dates and the Bed Status based on the Dates for Client '  + @vgs_program_name  + CONVERT(VARCHAR(26), @vgsStepStartTime, 109);

	UPDATE rent
	SET estimated_move_out = COALESCE(cl.discharge_date, cl.estimated_discharge_date)
		, bed_status_id = IIF(rent.bed_status_id IN (1, 2) AND (cl.discharge_date IS NOT NULL OR cl.estimated_discharge_date IS NOT NULL), 3, rent.bed_status_id)
	FROM #RentRollData rent 
		JOIN clients cl WITH (NOLOCK)
			ON cl.client_id = rent.client_id
				AND cl.deleted = 'N'
	;

	IF @debug_me='Y' 
		PRINT 'STEP ' +  CONVERT(VARCHAR(20), @vStep)  + ' complete: '+ltrim(rtrim(str(DATEDIFF(ms, @vgsStepStartTime, GETDATE()))))+ ' ms';


	SET @vStep = 10;
	SET @vgsStepStartTime = GETDATE();
	IF @debug_me='Y' 
		PRINT 'STEP ' + CONVERT(VARCHAR(20), @vStep) 
			+ ' Setting Occupied/Available Days for each bed '  + @vgs_program_name + ' ' + CONVERT(VARCHAR(26), @vgsStepStartTime, 109);

	IF NOT (@report_format_type = 'pdf' AND @emc_flag = 1)
	BEGIN
		INSERT INTO @availableOccupiedDays
		EXEC sproc_prp_rl_rent_roll_report_occ_avail 
				  @vFacId
				, @vFirstDay
				, @debug_me
				, @status_code
				, @status_text;

		UPDATE rrd
		SET occupied_days = IIF(aod.occupied_days IS NULL AND aod.available_days IS NULL, 0, aod.occupied_days)
			, vacant_days = IIF(aod.occupied_days IS NULL AND aod.available_days IS NULL, @vTotalDaysInMonth, aod.available_days)
		FROM #RentRollData rrd
			LEFT JOIN @availableOccupiedDays aod
				ON aod.bed_id = rrd.bed_id
	END

	IF @debug_me='Y' 
		PRINT 'STEP ' +  CONVERT(VARCHAR(20), @vStep)  + ' complete: '+ltrim(rtrim(str(DATEDIFF(ms, @vgsStepStartTime, GETDATE()))))+ ' ms';


	SET @vStep = 11;
	SET @vgsStepStartTime = GETDATE();
	IF @debug_me='Y' 
		PRINT 'STEP ' + CONVERT(VARCHAR(20), @vStep) 
			+ ' Deriving the Bed Staus based on Weight and Move out Dates '  + @vgs_program_name  + CONVERT(VARCHAR(26), @vgsStepStartTime, 109);

	UPDATE r
	SET is_rv_weight_1 = 
		CASE 
			WHEN r.room_id = rj.room_id AND rj.total_occupied_weight > 0.98 AND bed_status_id = 4 THEN 1 
			ELSE is_rv_weight_1 
		END
	FROM #RentRollData r 
		INNER JOIN @room_sum_for_jrxml rj 
			ON rj.room_id=r.room_id;

	IF (@enforce_max_weight_flag = 1)
	BEGIN
		UPDATE r
		----this bit column is used to calculate the the Rented and Vacant occupied days that emerged as the Rented and Vacant due to weight 1
		SET bed_status_id = IIF(r.room_id = rj.room_id AND rj.total_occupied_weight > 0.98 AND rj.bed_count > 0 AND bed_status_id = 4, 2, bed_status_id)
		FROM #RentRollData r 
			INNER JOIN @room_sum_for_jrxml rj 
				ON rj.room_id = r.room_id
		WHERE r.is_bed_occupied = 0
		;
	END

	if @debug_me='Y' Print 'STEP ' +  CONVERT(VARCHAR(20), @vStep)  + ' complete: '+ltrim(rtrim(str(DATEDIFF(ms, @vgsStepStartTime, GETDATE()))))+ ' ms';
 
	IF (@debug_me='Y'  OR @debug_me='rate')---using rate to debug only the ouput for rate related data
		SELECT 'bed status #RentRollData',* 
		FROM #RentRollData
		ORDER BY room_id, bed_id;


	SET @vStep = 12;
	SET @vgsStepStartTime = GETDATE();
	IF @debug_me='Y' 
		PRINT 'STEP ' + CONVERT(VARCHAR(20), @vStep) 
			+ ' Deriving Status For the Bed '  + @vgs_program_name  + CONVERT(VARCHAR(26), @vgsStepStartTime, 109);

	----No room and Bed Status are stored in table hence these section updates the room status on the fly based on the various combination of the bed status
	---Again the Bed Status are also calculated on the fly...

	UPDATE rrd
	SET room_status = 
		CASE
			WHEN countid = 2 THEN 
				CASE dco.bed_status_id
					WHEN 12 THEN 'Fully Occupied'
					WHEN 13 THEN 'Occupied with planned move out'
					WHEN 14 THEN 'Partially Occupied'
					WHEN 15 THEN 'Fully Occupied'
					WHEN 23 THEN 'Occupied with planned move out'
					WHEN 24 THEN 'Partially Occupied'
					WHEN 25 THEN 'Fully Rented & Vacant'
					WHEN 34 THEN 'Partially Occupied with planned move out'
					WHEN 35 THEN 'Occupied with planned move out'
					WHEN 45 THEN 'Fully Available'
				END
			WHEN countid = 1 THEN 
				CASE rrd.bed_status_id
					WHEN 1 THEN 'Fully Occupied'
					WHEN 2 THEN 'Fully Rented & Vacant'
					WHEN 3 THEN 'Occupied with planned move out'
					WHEN 4 THEN 'Fully Available'
					WHEN 5 THEN 'Fully Inactive'
				END
			ELSE
				CASE
					WHEN CHARINDEX('4', dco.bed_status_id) > 0 THEN 
						CASE 
							WHEN CHARINDEX('3', dco.bed_status_id)>0 THEN 'Partially Occupied with planned move out'
							ELSE 'Partially Occupied'
						END
					ELSE 
						CASE 
							WHEN CHARINDEX('3', dco.bed_status_id)>0 THEN 'Occupied with planned move out'
							ELSE 'Fully Occupied'
						END
				END
		END
	FROM #RentRollData rrd 
		INNER JOIN (
				SELECT count(DISTINCT bed_status_id )countid,room_id 
				FROM #RentRollData 
				GROUP BY room_id
			) co
			ON co.room_id=rrd.room_id
		INNER JOIN (
				SELECT room_id
					, REPLACE(ISNULL([1],'')+ISNULL([2],'')+ISNULL([3],'')+ISNULL([4],'')+ISNULL([5],''),' ', '' ) AS bed_status_id
				FROM (
						SELECT room_id
							, bed_status_id
						FROM #RentRollData
					) ps
					PIVOT (MAX(bed_status_id) FOR bed_status_id in ([1],[2],[3],[4],[5])) AS pvt
			) dco
			ON dco.room_id = rrd.room_id
	;

	IF @debug_me='Y' Print 'STEP ' +  CONVERT(VARCHAR(20), @vStep)  + ' complete: '+ltrim(rtrim(str(DATEDIFF(ms, @vgsStepStartTime, GETDATE()))))+ ' ms';


	IF (@debug_me='Y'  OR @debug_me='rate')---using rate to debug only the ouput for rate related data
		SELECT 'rooms status #RentRollData',* 
		FROM #RentRollData
		ORDER BY room_id, bed_id;


	SELECT @rows_returned = Count(*) 
	FROM #RentRollData 
	WHERE (@vRoomStatus='-1' OR room_status=@vRoomStatus);

	IF @rows_returned < 1 AND @emc_flag = 0
	BEGIN
		SELECT NULL fac_id
			,NULL fac_name
			,NULL fac_code
			,NULL room_id 
			,NULL room_desc
			,NULL unit_desc
			,NULL floor_desc
			,NULL room_desc_original
			,NULL bed_id
			,NULL bed_desc
			,NULL client_id
			,NULL client_name
			,NULL first_name
			,NULL last_name
			,NULL client_id_number
			,NULL sex
			,NULL primary_payer_name
			,NULL room_type
			,NULL sq_footage   
			,NULL market_rate 
			,NULL actual_rate  
			,NULL room_rate   
			,NULL discount
			,NULL deposit_required   
			,NULL deposit_received   
			,NULL lease_start
			,NULL lease_end
			,NULL resident_status
			,NULL move_in   
			,NULL estimated_move_out
			,NULL stay_days
			,NULL bed_status 
			,NULL room_status  
			,NULL is_unit_occupied
			,NULL occupied_bed_id
			,NULL occupied_room_id
			,NULL occupied_market_rate
			,NULL occupied_actual_rate
			,NULL occupied_discount
			,NULL occupied_sq_footage
			,NULL total_deposit_required   
			,NULL total_deposit_received   
			,NULL total_market_rate 
			,NULL total_actual_rate 
			,NULL total_discount 
			,NULL inactive_bed_status
			,NULL occupied_days
			,NULL vacant_days
			,NULL is_bed_addnl_bed
			,NULL potential_occupancy
			,NULL row_num
			,NULL ordering_row_num
			,0 status_code  
			,NULL status_text 
			,@vselected_parameters as selected_parameters
			,@effective_date effective_date;
	END
	ELSE
	BEGIN;

		SET @vStep = 13;
		SET @vgsStepStartTime = GETDATE();
		IF @debug_me='Y' 
			PRINT 'STEP ' + CONVERT(VARCHAR(20), @vStep) 
				+ ' Vacant / Move In details For the Bed '  + @vgs_program_name  + CONVERT(VARCHAR(26), @vgsStepStartTime, 109);

		WITH BedsByRoom_CTE AS (
			SELECT room_id
				, potential_occupancy = COUNT(*) 
			FROM bed 
			WHERE deleted = 'N'
				AND (retired_date IS NULL OR retired_date > @vEffectiveDate)
			GROUP BY room_id
		),
		FinalOutput_CTE AS (
			SELECT rd.fac_id
				, rd.room_id
				, rd.bed_id
				, rd.bed_desc
				, rd.client_id
				, rd.room_type
				, rd.sq_footage
				, rd.market_rate
				, rd.actual_rate
				, rd.room_rate
				, rd.discount
				, deposit_required = rd.deposit_amount
				, rd.deposit_received
				, rd.lease_start_date lease_start
				, rd.lease_end_date lease_end
				, rd.estimated_move_out
				, rd.occupied_days
				, rd.vacant_days
				, rd.room_status
				, is_unit_occupied = IIF(rj.bed_count = 0, 0, 1)
				, rd.occupied_bed_id
				, rd.occupied_room_id
				, rd.occupied_market_rate
				, rd.occupied_actual_rate
				, rd.occupied_discount
				, rd.occupied_sq_footage
				, total_deposit_required = rd.total_deposit_required
				, total_deposit_received = rj.total_deposit_received
				, rj.total_market_rate
				, rj.total_actual_rate
				, total_discount = IIF(rj.bed_count = 0, NULL, rj.total_discount)
				, status_code = 0
				, status_text = NULL
				, selected_parameters = @vselected_parameters
				, rd.bed_status_id
				, rd.inactive_Days
				, rd.weight
				, rd.primary_payer_name
				, rd.is_bed_addnl_bed
				, bedsByRoom.potential_occupancy
				, is_companion = ISNULL(rd.is_companion, 0)
				, rd.is_bed_occupied
				, rd.anniversary_date
			FROM #RentRollData rd 
				JOIN @room_sum_for_jrxml rj
					ON rj.room_id = rd.room_id
				LEFT JOIN BedsByRoom_CTE bedsByRoom
					ON bedsByRoom.room_id = rd.room_id
			WHERE (@vRoomStatus = '-1' OR rd.room_status = @vRoomStatus)
				AND rd.inactive_no_show = 0
		),
		OccupiedRooms_CTE AS (
			SELECT DISTINCT 
				  room_id
				, bed_id
				, lease_start
				, lease_end
			FROM FinalOutput_CTE
			WHERE weight > 0.98
				AND bed_status_id IN (1, 3)
		)
		SELECT 
			  f.fac_id
			, facility.name AS fac_name
			, facility.facility_code AS fac_code
			, f.room_id
			, room_desc = unit.unit_desc + '-' + flr.floor_desc + '-' + room.room_desc
			, unit.unit_desc
			, flr.floor_desc
			, room_desc_original = room.room_desc
			, f.bed_id
			, f.bed_desc 
			, f.client_id
			, client_name = 
				CASE 
					WHEN @vOrderBy = 0 AND COALESCE(m.last_name, m.first_name, cl.client_id_number, '') = '' THEN 'None'
					WHEN @vOrderBy <> 0 AND COALESCE(m.last_name, m.first_name, cl.client_id_number, '') = '' THEN ''
					ELSE ltrim(rtrim(isNULL(m.last_name,''))) + ', ' + ltrim(rtrim(isNULL(m.first_name,''))) + ' (' + ltrim(rtrim(isNULL(cl.client_id_number,'')))+ ')'
				END
			, m.first_name
			, m.last_name
			, cl.client_id_number
			, m.sex
			, f.primary_payer_name
			, f.room_type
			, f.sq_footage   
			, f.market_rate  
			, f.actual_rate
			, f.room_rate   
			, f.discount
			, f.deposit_required   
			, f.deposit_received
			, lease_start   = COALESCE(occ.lease_start  , f.lease_start)
			, lease_end     = COALESCE(occ.lease_end    , f.lease_end)
			, resident_status = IIF(f.client_id IS NULL, NULL, 'Active')
			, move_in       = cl.admission_date
			, f.estimated_move_out
			, stay_days     = IIF(cl.admission_date <= @Today, DATEDIFF(dd, cl.admission_date, @Today) + 1, NULL)
			, f.occupied_days
			, f.vacant_days
			, bed_status = 
				CASE f.bed_status_id
					WHEN 1 THEN 'Occupied'
					WHEN 2 THEN 'Rented & Vacant' 
					WHEN 3 THEN 'Occupied with planned move out' 
					WHEN 4 THEN 'Available' 
					WHEN 5 THEN 'Inactive' 
				END
			, f.room_status
			, f.is_unit_occupied
			, f.occupied_bed_id
			, f.occupied_room_id
			, f.occupied_market_rate
			, f.occupied_actual_rate
			, f.occupied_discount
			, f.occupied_sq_footage
			, f.total_deposit_required
			, f.total_deposit_received
			, f.total_market_rate
			, f.total_actual_rate
			, f.total_discount
			, inactive_bed_Status = IIF(f.bed_status_id = 5, 1, 0)
			, f.is_bed_addnl_bed
			, f.potential_occupancy
			, f.status_code
			, f.status_text  
			, f.selected_parameters
			, effective_date = @vEffectiveDate
			, f.is_companion
			, f.anniversary_date
			, row_num = DENSE_RANK() OVER (ORDER BY unit.unit_desc, flr.floor_desc, room.room_desc)
		INTO #RentRollResult
		FROM FinalOutput_CTE f
			LEFT JOIN OccupiedRooms_CTE occ
				ON occ.room_id = f.room_id 
					AND occ.bed_id = f.bed_id 
					AND f.bed_status_id = 2
			JOIN dbo.room room WITH (NOLOCK) 
				ON f.room_id = room.room_id
					AND room.deleted = 'N'
			JOIN dbo.[floor] flr WITH (NOLOCK) 
				ON room.floor_id = flr.floor_id
					AND flr.deleted = 'N'
			JOIN dbo.unit unit WITH (NOLOCK) 
				ON room.unit_id = unit.unit_id
					AND unit.deleted = 'N'
			LEFT JOIN dbo.clients cl WITH (NOLOCK)
				ON cl.client_id = f.client_id 
					AND cl.fac_id = f.fac_id
					AND cl.deleted = 'N'
			LEFT JOIN dbo.mpi m WITH (NOLOCK) 
				ON m.mpi_id = cl.mpi_id
					AND m.deleted = 'N'
			JOIN facility ON facility.fac_id = f.fac_id
		WHERE (f.is_bed_occupied = 0 AND (@show_empty_companion_beds = 1 OR f.is_companion = 0))
			OR (f.is_bed_occupied = 1 AND (@show_occupied_companion_beds = 1 OR f.is_companion = 0))
		;

		IF @debug_me='Y'
			PRINT 'STEP ' +  CONVERT(VARCHAR(20), @vStep)  + ' complete: '+ltrim(rtrim(str(DATEDIFF(ms, @vgsStepStartTime, GETDATE()))))+ ' ms';


		SET @vStep = 14;
		SET @vgsStepStartTime = GETDATE();
		IF @debug_me='Y' 
			PRINT 'STEP ' + CONVERT(VARCHAR(20), @vStep) 
				+ ' Ordering Result '  + @vgs_program_name  + CONVERT(VARCHAR(26), @vgsStepStartTime, 109);

		IF @vOrderBy = 1		-- last name
			WITH RowNum_CTE AS (
				SELECT *
					, ordering_row_num = DENSE_RANK() OVER (ORDER BY last_name, first_name, client_id_number, unit_desc, floor_desc, room_desc, bed_desc)
				FROM #RentRollResult 
			)
			SELECT *
			FROM RowNum_CTE
			ORDER BY ordering_row_num, unit_desc, floor_desc, room_desc, bed_desc
			;
		ELSE IF @vOrderBy = 2	-- first name
			WITH RowNum_CTE AS (
				SELECT *
					, ordering_row_num = DENSE_RANK() OVER (ORDER BY first_name, last_name, client_id_number, unit_desc, floor_desc, room_desc, bed_desc)
				FROM #RentRollResult
			)
			SELECT *
			FROM RowNum_CTE
			ORDER BY ordering_row_num, unit_desc, floor_desc, room_desc, bed_desc
			;
		ELSE					-- @vOrderBy = 0	-- room
			WITH RowNum_CTE AS (
				SELECT *
					, ordering_row_num = DENSE_RANK() OVER (ORDER BY unit_desc, floor_desc, room_desc)
				FROM #RentRollResult
			)
			SELECT *
			FROM RowNum_CTE
			ORDER BY ordering_row_num, bed_desc, room_type, client_name
			;

		IF @debug_me='Y'
			PRINT 'STEP ' +  CONVERT(VARCHAR(20), @vStep)  + ' complete: '+ltrim(rtrim(str(DATEDIFF(ms, @vgsStepStartTime, GETDATE()))))+ ' ms';

	END

	IF @debug_me='Y' Print 'Total execution time: ' + LTRIM(RTRIM(STR(DATEDIFF(ms, @vgsTotalStartTime, GETDATE()))))+ ' ms';

END TRY
  
BEGIN CATCH  
	SET @Status_Code = IIF(@status_code = 0, 1, 2);  --- convert 3 to 2

	IF @status_code = 1  
		SELECT @status_text = rtrim( LEFT( 'Stored Procedure failed WITH Error Code : ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) +  ', Line Number : ' + CAST(ERROR_LINE() AS VARCHAR(10)) + ', Description : ' +  ERROR_MESSAGE(), 3000 ) );

	IF @emc_flag = 0
	BEGIN
		SELECT NULL fac_id
   			,NULL fac_name
   			,NULL fac_code
   			,NULL room_id 
   			,NULL room_desc   
   			,NULL unit_desc
   			,NULL floor_desc
   			,NULL room_desc_original
   			,NULL bed_id
   			,NULL bed_desc
   			,NULL client_id
   			,NULL client_name
   			,NULL first_name
   			,NULL last_name
   			,NULL client_id_number
   			,NULL sex
   			,NULL primary_payer_name
   			,NULL room_type
   			,NULL sq_footage   
   			,NULL market_rate 
   			,NULL actual_rate  
   			,NULL room_rate   
   			,NULL discount
   			,NULL deposit_required   
   			,NULL deposit_received   
   			,NULL lease_start 
   			,NULL lease_end
			,NULL resident_status
   			,NULL move_in 
   			,NULL estimated_move_out
   			,NULL stay_days
   			,NULL bed_status  
   			,NULL room_status 
   			,NULL is_unit_occupied
   			,NULL occupied_bed_id
   			,NULL occupied_room_id
   			,NULL occupied_market_rate
   			,NULL occupied_actual_rate
   			,NULL occupied_discount
   			,NULL occupied_sq_footage
   			,NULL total_deposit_required   
   			,NULL total_deposit_received   
   			,NULL total_market_rate 
   			,NULL total_actual_rate 
   			,NULL total_discount 
   			,NULL inactive_bed_status
   			,NULL occupied_days
   			,NULL vacant_days
   			,@status_code status_code  
   			,@status_text status_text   
   			,@vselected_parameters selected_parameters
   			,NULL effective_date
   			,NULL is_companion
   			,NULL anniversary_date
   			,NULL row_num
   			,NULL ordering_row_num;
	END
  
	IF @debug_me='Y'
	BEGIN
		Print 'Stored procedure failure in step: '+ convert(varchar(3),@vStep) + '     ' + convert(varchar(26), getdate());
		Print 'Error code: '+convert(varchar(3),@vStep) + '; Error description:      ' + @Status_Text;
	END
END CATCH  

IF OBJECT_ID('tempdb..#RentRollData') IS NOT NULL
BEGIN
	DROP TABLE #RentRollData;
END

IF OBJECT_ID('tempdb..#RentRollResult') IS NOT NULL
BEGIN
	DROP TABLE #RentRollResult;
END

RETURN;

END


GO
GRANT EXECUTE ON sproc_prp_rl_rent_roll_report3 TO PUBLIC
GO


GO

print 'C_Branch/04_StoredProcedures/sproc_prp_rl_rent_roll_report3.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('C_Branch/04_StoredProcedures/sproc_prp_rl_rent_roll_report3.sql',getdate(),'4.4.9.3_06_CLIENT_C_Branch_US.sql')

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.9.3_06_CLIENT_C_Branch_US.sql')

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
values ('4.4.9.3_C', 'upload_history')


GO

print '..\Update db version.sql --****SCRIPT DONE****'

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.9.3_06_CLIENT_C_Branch_US.sql')

GO

insert into upload_tracking (script,timestamp,upload) values ('UPLOAD END',getdate(),'4.4.9.3_06_CLIENT_C_Branch_US.sql')