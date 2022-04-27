

SET NOCOUNT ON
GO

SET DEADLOCK_PRIORITY HIGH
GO


insert into upload_tracking (script, timestamp, upload) values ('UPLOAD_START',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/3_Functions/reporting.bdl_fn_ImmunizationRate.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

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
***************************************************************************** 
CORE-30607: Build a function for Immunization Rate(Reporting group) 

Written By: Maria Fradkin
Reviewed By: 

Description: 
This table function generates a data set for Immunization Rate report

Target DB Type: Client Database 
Target ENVIRONMENT: BOTH 
Re-Runable: YES 

-- ------sample script---------
	DECLARE @facility dbo.TableOfInt; 
	DECLARE @Immunization dbo.TwoColumnsOfIntTableType; 
	DECLARE @ClientStatus dbo.TableOfInt; 
	DECLARE @Consent dbo.TableOfInt; 
		
	INSERT @Facility(id)
	SELECT  TRY_CAST(a.items AS INT)
	FROM dbo.split('1,2,3', @vseparator)  a;
    
	INSERT @Immunization(col1, col2)
	SELECT  TRY_CAST(a.items AS INT) , 1
	FROM dbo.split('5', ',')  a;
	--add step2 for TB
	INSERT @Immunization(col1, col2)
	SELECT a.col1, 2 as col2
	FROM @Immunization a
	WHERE a.col1 = 5;

	INSERT @ClientStatus(id)
	SELECT  TRY_CAST(a.items AS INT)
	FROM dbo.split('0', @vseparator)  a;

	INSERT @Consent(id)
	SELECT consent_code_id 
	FROM reporting.pdl_dim_ConsentStatusCode a
	WHERE consent_code_id < 4 -- all but not "missing" and "strike out" 
	UNION ALL
    SELECT TRY_CAST(a.items AS INT)
	FROM  dbo.split(null, @vseparator) a;	-- add special cases

	SELECT * 
	FROM reporting.bdl_fn_ImmunizationRate( 
		@Facility ,
		@Immunization,
		@ClientStatus ,
		@Consent,
		@vimmu_start_date_id,
		@vimmu_end_date_id,
		1, 2, 3, 4, 5, 6
		)f;
/***********************************************************************************
Revision History:
2019-03-06	Ritch Moore		CORE-34562	Add additional grouping fields and Manufacturer fix
2019-03-28	Ritch Moore		CORE-38047	Revised resident filtering
2019-04-11	Ritch Moore		CORE-39056	Use ldl view not pdl table
2019-12-09	Amro Saada		CORE-57616	Add cvx code and description columns to the output
***********************************************************************************/
*/
IF OBJECT_ID(N'reporting.bdl_fn_ImmunizationRate') IS NOT NULL 
	DROP FUNCTION reporting.bdl_fn_ImmunizationRate;
GO

CREATE FUNCTION reporting.bdl_fn_ImmunizationRate(
	@facility dbo.TableOfInt READONLY,
	@Immunization dbo.TwoColumnsOfIntTableType READONLY,
	@ClientStatus dbo.TableOfInt READONLY,
	@Consent dbo.TableOfInt READONLY,
	@immu_start_date_id INT,
	@immu_end_date_id INT,
	@start_date datetime,
	@end_date datetime,
	@group_lvl1 int,
	@group_lvl2 int,
	@group_lvl3 int,
	@group_lvl4 int,
	@group_lvl5 int,
	@group_lvl6 int
	)
RETURNS @immunizationRate TABLE
    (
        col1            VARCHAR(254),
        col2            VARCHAR(254),
        col3            VARCHAR(254),
        col4            VARCHAR(254),
        col5            VARCHAR(254),
        col6            VARCHAR(254),
        fac_id          INT,
        Facility        VARCHAR(375),
        Unit            VARCHAR(35),
        std_immunization_id INT,
        Immunization    VARCHAR(55),
        Step            VARCHAR(10),
        [Consent Type]  VARCHAR(40),
        reason_code_id  INT,
        Reason          VARCHAR(254),
        result_code_id  INT,
        Results         VARCHAR(30),
        client_id       INT,
        Resident        VARCHAR(135),
        consent_code_id INT,
        [Consent Date]  DATETIME,
        [Consent Confirmed By]      VARCHAR(60),
        [Education Provided To Resident/Family] VARCHAR(5),
        [Administration Date]       DATETIME,
        [Administered By]           VARCHAR(50),
        [Route of Administration]   VARCHAR(100),
        [Dose Amount] NUMERIC(18,5),
        [Uom] VARCHAR(20),
        [Location Given]      VARCHAR(254),
        [Manufacturer's Name] VARCHAR(50),
        [Substance Expiration Date] SMALLDATETIME,
        [Lot Number]          VARCHAR(10),
        [Induration]          FLOAT,
        [Struck Out By]       VARCHAR(50),
        [Strike Out Date]     SMALLDATETIME,
        fact_immunization_id  BIGINT,
        immunization_id       INT,
        [cvx_code]            INT,
        [cvx_description]     VARCHAR(200),
        Notes                 VARCHAR(150)
        )
AS
  BEGIN

    DECLARE @covid19ImmunizationId INT;
	SET @covid19ImmunizationId = ISNULL((SELECT std_immunization_id FROM cr_std_immunization WHERE description = 'SARS-COV-2 (COVID-19)' AND system_flag = 'Y' AND deleted = 'N'), -1);

    INSERT INTO @immunizationRate
   	SELECT 
		fac_grp.col1, 
		fac_grp.col2, 
		fac_grp.col3, 
		fac_grp.col4, 
		fac_grp.col5, 
		fac_grp.col6,
		facility.fac_id,
		facility.facility_name AS Facility ,
		bed.unit_desc AS Unit ,
		f.std_immunization_id,
		immunization.description AS Immunization,
		CASE
		    WHEN f.std_immunization_id = 5 THEN '(Step ' + CAST(f.step_id AS char(1)) + ')'
		    WHEN f.std_immunization_id = @covid19ImmunizationId THEN '(Dose ' + CAST(f.step_id AS char(1)) + ')'
		    ELSE ''
		END AS Step,
		consent.description AS [Consent Type],
		f.reason_code_id,
		reason.description AS Reason,
		f.result_code_id,
		result.description AS Results,
		--detail info
		cl.client_id,
		cl.last_name + ', ' + cl.first_name + ' (' + cl.client_id_number + ')'  as Resident,
		f.consent_code_id,
		f.consent_date AS [Consent Date],
		f.consent_by AS [Consent Confirmed By],
		CASE WHEN f.education_provided_date IS NOT NULL THEN 'Yes' ELSE 'No' END AS [Education Provided To Resident/Family],
		f.immun_date AS [Administration Date],
		userDim.long_username AS [Administered By],
		routeDim.description as [Route of Administration],
		f.dose_amount AS [Dose Amount],
		uom.description AS [Uom],
		body.item_description AS [Location Given],
		m.manufacturer_name AS [Manufacturer's Name],
		f.expiration_date AS [Substance Expiration Date],
		f.lot_number AS [Lot Number],
		f.induration AS [Induration],
		userSt.long_username AS [Struck Out By],
		f.strikeout_date AS [Strike Out Date],
		--infra
		f.fact_immunization_id,
		f.immunization_id,
		cv.code AS [cvx_code],
		cv.short_description AS [cvx_description],
		f.notes
	FROM  reporting.ldl_view_fact_Immunization f
	--filters
	INNER JOIN @facility fac
		ON fac.id = f.fac_id
	INNER JOIN @Immunization i
		ON i.col1 = f.std_immunization_id AND i.col2 = f.step_id
	INNER JOIN reporting.ldl_view_dim_Client cl 
		ON f.client_id = cl.client_id
	INNER JOIN @Consent cons
		ON cons.id = f.consent_code_id
	--dims
	LEFT JOIN reporting.ldl_fn_dim_FacilityCode(@group_lvl1, @group_lvl2, @group_lvl3, @group_lvl4, @group_lvl5, @group_lvl6) fac_grp
		ON 	fac_grp.fac_id = f.fac_id
	INNER JOIN reporting.ldl_view_dim_Facility facility
		ON f.fac_id = facility.fac_id
	LEFT JOIN reporting.ldl_view_dim_BedLocation bed
		ON f.current_bed_id = bed.bed_id
	INNER JOIN reporting.ldl_view_dim_Immunization immunization
		ON f.std_immunization_id = immunization.std_immunization_id
	INNER JOIN reporting.ldl_view_dim_ConsentStatusCode consent
		ON f.consent_code_id = consent.consent_code_id 
	INNER JOIN reporting.ldl_view_dim_ReasonStatusCode reason
		ON  f.reason_code_id = reason.reason_code_id
	INNER JOIN reporting.ldl_view_dim_ResultStatusCode result
		ON f.result_code_id = result.result_code_id
	INNER JOIN reporting.ldl_view_dim_User userDim
		ON f.administered_by_id = userDim.userid
	INNER JOIN reporting.ldl_view_dim_RouteOfAdmin routeDim
		ON f.route_of_admin_id = routeDim.route_of_admin_id
	LEFT JOIN reporting.ldl_view_dim_BodyLocation body
		ON f.body_location_id = body.body_location_id
	INNER JOIN reporting.ldl_view_dim_Manufacturer m
		ON f.manufacturer_id = m.manufacturer_id 
	INNER JOIN reporting.ldl_view_dim_User userSt
		ON f.strikeout_user_id = userSt.userid
	INNER JOIN reporting.ldl_view_dim_CvxCode cv
		ON f.cvx_code_id = cv.cvx_code_id
	INNER JOIN reporting.ldl_view_dim_UnitOfMeasure uom
		ON f.unit_of_measure_id = uom.uom_id
	WHERE (f.immun_date_id BETWEEN @immu_start_date_id AND @immu_end_date_id OR f.immun_date_id = 19000101) AND
	(
	((EXISTS (SELECT 1 FROM @ClientStatus WHERE id = 0)) and cl.discharge_date between @start_date and @end_date) 
	or
	((EXISTS (SELECT 1 FROM @ClientStatus WHERE id = 1)) and (cl.discharge_date is null or cl.discharge_date > @end_date) and cl.admission_date <= @end_date)
	)

    RETURN;
END
GO

GRANT SELECT ON reporting.bdl_fn_ImmunizationRate TO PUBLIC;
GO


GO

print 'G_EnterpriseReporting_Branch/3_Functions/reporting.bdl_fn_ImmunizationRate.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/3_Functions/reporting.bdl_fn_ImmunizationRate.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/3_Functions/reporting.bdl_fn_ImmunizationRate_MissingRecords.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

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
***************************************************************************** 
CORE-30607: Build a function for Immunization Rate(Reporting group) 

Written By: Maria Fradkin
Reviewed By: 

Description: 
This table function generates a data set for Immunization Rate report missing records

Target DB Type: Client Database 
Target ENVIRONMENT: BOTH 
Re-Runable: YES 

-- ------sample script---------
	DECLARE @vimmu_start_date_id INT = 20190101; 
	DECLARE @vimmu_end_date_id INT = 20190131; 
	DECLARE @vseparator CHAR(1) = ',';
	DECLARE @facility dbo.TableOfInt; 
	DECLARE @Immunization dbo.TwoColumnsOfIntTableType; 
	DECLARE @ClientStatus dbo.TableOfInt; 
	DECLARE @Consent dbo.TableOfInt; 
		
	INSERT @Facility(id)
	SELECT  TRY_CAST(a.items AS INT)
	FROM dbo.split('1,2,3', @vseparator)  a;
    
	INSERT @Immunization(col1, col2)
	SELECT  TRY_CAST(a.items AS INT) , 1
	FROM dbo.split('5', ',')  a;
	--add step2 for TB
	INSERT @Immunization(col1, col2)
	SELECT a.col1, 2 as col2
	FROM @Immunization a
	WHERE a.col1 = 5;

	INSERT @ClientStatus(id)
	SELECT  TRY_CAST(a.items AS INT)
	FROM dbo.split('0', @vseparator)  a;

	INSERT @Consent(id)
	SELECT consent_code_id 
	FROM reporting.pdl_dim_ConsentStatusCode a
	WHERE consent_code_id < 4 -- all but not "missing" and "strike out" 
	UNION ALL
    SELECT TRY_CAST(a.items AS INT)
	FROM  dbo.split(null, @vseparator) a;	-- add special cases

	SELECT * 
	FROM reporting.bdl_fn_ImmunizationRate_MissingRecords( 
		@Facility ,
		@Immunization,
		@ClientStatus ,
		@Consent,
		@vimmu_start_date_id,
		@vimmu_end_date_id,
		1, 2, 3, 4, 5, 6
		)f;

/***********************************************************************************
Revision History:
2019-03-06	Ritch Moore		CORE-34562	Add additional grouping fields and Manufacturer fix
2019-03-28	Ritch Moore		CORE-38047	Revised resident filtering
2019-04-11	Ritch Moore		CORE-39056	Use ldl view not pdl table
***********************************************************************************/
*/
IF OBJECT_ID(N'reporting.bdl_fn_ImmunizationRate_MissingRecords') IS NOT NULL 
	DROP FUNCTION reporting.bdl_fn_ImmunizationRate_MissingRecords;
GO

CREATE FUNCTION reporting.bdl_fn_ImmunizationRate_MissingRecords(
	@facility dbo.TableOfInt READONLY,
	@Immunization dbo.TwoColumnsOfIntTableType READONLY,
	@ClientStatus dbo.TableOfInt READONLY,
	@Consent dbo.TableOfInt READONLY,
	@immu_start_date_id INT,
	@immu_end_date_id INT,
	@start_date datetime,
	@end_date datetime,
	@group_lvl1 int,
	@group_lvl2 int,
	@group_lvl3 int,
	@group_lvl4 int,
	@group_lvl5 int,
	@group_lvl6 int
	)
RETURNS @missingRecords TABLE
    (
        col1            VARCHAR(254),
        col2            VARCHAR(254),
        col3            VARCHAR(254),
        col4            VARCHAR(254),
        col5            VARCHAR(254),
        col6            VARCHAR(254),
        fac_id          INT,
        Facility        VARCHAR(375),
        Unit            VARCHAR(35),
        std_immunization_id INT,
        Immunization    VARCHAR(55),
        Step            VARCHAR(10),
        [Consent Type]  VARCHAR(40),
        reason_code_id  INT,
        Reason          VARCHAR(254),
        result_code_id  INT,
        Results         VARCHAR(30),
        client_id       INT,
        Resident        VARCHAR(135),
        consent_code_id INT,
        [Consent Date]  DATETIME,
        [Consent Confirmed By]      VARCHAR(60),
        [Education Provided To Resident/Family] VARCHAR(5),
        [Administration Date]       DATETIME,
        [Administered By]           VARCHAR(50),
        [Route of Administration]   VARCHAR(100),
        [Dose Amount] NUMERIC(18,5),
        [Uom] VARCHAR(20),
        [Location Given]      VARCHAR(254),
        [Manufacturer's Name] VARCHAR(50),
        [Substance Expiration Date] SMALLDATETIME,
        [Lot Number]          VARCHAR(10),
        [Induration]          FLOAT,
        [Struck Out By]       VARCHAR(50),
        [Strike Out Date]     SMALLDATETIME,
        fact_immunization_id  BIGINT,
        immunization_id       INT,
        Notes                 VARCHAR(150)
    )
AS

BEGIN

DECLARE @covid19ImmunizationId INT;
SET @covid19ImmunizationId = ISNULL((SELECT std_immunization_id FROM cr_std_immunization WHERE description = 'SARS-COV-2 (COVID-19)' AND system_flag = 'Y' AND deleted = 'N'), -1);
	
WITH cte_exist AS (
	SELECT 
		im.client_id, 
		im.std_immunization_id,
		im.immunization_id,
		im.related_immunization_id
	FROM reporting.ldl_view_fact_Immunization im 
	--filters
	INNER JOIN @facility fac
		ON fac.id = im.fac_id
	INNER JOIN @Immunization i
		ON i.col1 = im.std_immunization_id AND i.col2 = im.step_id
	INNER JOIN reporting.ldl_view_dim_Client cl 
		ON im.client_id = cl.client_id
	INNER JOIN @Consent cons
		ON cons.id = im.consent_code_id
	WHERE 
		im.immun_date_id BETWEEN @immu_start_date_id AND @immu_end_date_id AND consent_code_id < 5 AND
		(
		((EXISTS (SELECT 1 FROM @ClientStatus WHERE id = 0)) and cl.discharge_date between @start_date and @end_date) 
		or
		((EXISTS (SELECT 1 FROM @ClientStatus WHERE id = 1)) and (cl.discharge_date is null or cl.discharge_date > @end_date) and cl.admission_date <= @end_date)
		)
	),
cte_missing AS (
	SELECT 
		--FK columns
		pfi.std_immunization_id,
		pfi.fac_id,
		pfi.client_id,
		pfi.current_bed_id,
		pfi.step_id AS step_id,
		--infra
		MAX(pfi.fact_immunization_id) AS fact_immunization_id,
		MAX(pfi.immunization_id) AS immunization_id
	FROM reporting.ldl_view_fact_Immunization pfi
	INNER JOIN @facility f
		ON f.id = pfi.fac_id
	INNER JOIN @Immunization i
		ON i.col1 = pfi.std_immunization_id AND i.col2 = pfi.step_id
	INNER JOIN reporting.ldl_view_dim_Client cl 
		ON pfi.client_id = cl.client_id  
	INNER JOIN @Consent cons
		ON cons.id = pfi.consent_code_id
	LEFT JOIN cte_exist immExists
		ON 
			immExists.client_id = pfi.client_id AND
			immExists.std_immunization_id = pfi.std_immunization_id        
	WHERE 
		pfi.immun_date_id NOT BETWEEN @immu_start_date_id AND @immu_end_date_id AND 
		pfi.immun_date_id <> 19000101 AND pfi.consent_code_id <= 5 AND immExists.client_id IS NULL AND
		(
		((EXISTS (SELECT 1 FROM @ClientStatus WHERE id = 0)) and cl.discharge_date between @start_date and @end_date) 
		or
		((EXISTS (SELECT 1 FROM @ClientStatus WHERE id = 1)) and (cl.discharge_date is null or cl.discharge_date > @end_date) and cl.admission_date <= @end_date)
		)
	GROUP BY pfi.std_immunization_id, pfi.fac_id, pfi.client_id, pfi.current_bed_id, pfi.step_id	
),
cte_first_steps AS (
	SELECT
		--FK columns
		pfi.std_immunization_id,
		pfi.fac_id,
		pfi.client_id,
		pfi.current_bed_id,
		pfi.step_id,
		--infra
		pfi.fact_immunization_id AS fact_immunization_id,
		pfi.immunization_id AS immunization_id
	FROM reporting.ldl_view_fact_Immunization pfi
	INNER JOIN cte_exist e
		ON pfi.immunization_id = e.related_immunization_id
	WHERE 
		pfi.immun_date_id NOT BETWEEN @immu_start_date_id AND @immu_end_date_id AND 
		pfi.immun_date_id <> 19000101 AND
		pfi.step_id = 1 AND
		EXISTS(SELECT 1 FROM @Immunization i WHERE i.col1 = pfi.std_immunization_id AND i.col2 = 2)
),
cte_second_steps AS (
	SELECT
		--FK columns
		pfi.std_immunization_id,
		pfi.fac_id,
		pfi.client_id,
		pfi.current_bed_id,
		pfi.step_id,
		--infra
		pfi.fact_immunization_id AS fact_immunization_id,
		pfi.immunization_id AS immunization_id
	FROM reporting.ldl_view_fact_Immunization pfi
	INNER JOIN cte_exist e
		ON pfi.related_immunization_id = e.immunization_id
	WHERE 
		pfi.immun_date_id NOT BETWEEN @immu_start_date_id AND @immu_end_date_id AND 
		pfi.immun_date_id <> 19000101 AND
		pfi.step_id = 2 AND
		EXISTS(SELECT 1 FROM @Immunization i WHERE i.col1 = pfi.std_immunization_id AND i.col2 = 2)
),
cte_all_missing AS (
	SELECT 
		std_immunization_id,
		fac_id,
		client_id,
		current_bed_id,
		step_id,
		fact_immunization_id AS fact_immunization_id,
		immunization_id AS immunization_id
	FROM cte_missing
	UNION ALL 
	SELECT
		std_immunization_id,
		fac_id,
		client_id,
		current_bed_id,
		step_id,
		fact_immunization_id AS fact_immunization_id,
		immunization_id AS immunization_id
	FROM cte_first_steps
	UNION ALL 
	SELECT 
		std_immunization_id,
		fac_id,
		client_id,
		current_bed_id,
		step_id,
		fact_immunization_id AS fact_immunization_id,
		immunization_id AS immunization_id
	FROM cte_second_steps
),
cte_fact AS (
	SELECT 
		--FK columns
		pfi.std_immunization_id,
		pfi.fac_id,
		pfi.client_id,
		pfi.current_bed_id as bed_id,
		19000101 AS immun_date_id ,
		CAST(5 AS INT) AS consent_code_id,
		CAST(-1 AS INT) AS administered_by_id,
		CAST(-1 AS INT) AS body_location_id,
		CAST(-1 AS INT) AS unit_of_measure_id,
		CAST(-1 AS INT) AS result_code_id,
		CAST(-1 AS INT) AS reason_code_id,
		CAST(-1 AS INT) AS route_of_admin_id,
		pfi.step_id AS step_id,
		CAST(-1 AS INT) AS manufacturer_id,
		CAST(NULL AS DATE) AS education_date_id,
		--lbls
		CAST(NULL AS DATE) AS immun_date,
		CAST(NULL AS DATE)  AS consent_date,
		CAST(0 AS INT) AS dose_amount,
		CAST(NULL AS VARCHAR(20)) AS Uom,
		CAST(NULL AS VARCHAR(50)) AS consent_by,
		CAST(NULL AS VARCHAR(50)) AS lot_number,
		CAST(NULL AS VARCHAR(50)) AS induration,
		CAST(NULL AS VARCHAR(50)) AS strike_out_user,
		CAST(NULL AS VARCHAR(50)) AS education_by,
		CAST(NULL AS SMALLDATETIME) AS expiration_date,
		CAST(NULL AS SMALLDATETIME) AS strikeout_date,
		CAST(-1 AS INT) AS strikeout_user_id,
		--infra
		pfi.fact_immunization_id AS fact_immunization_id,
		pfi.immunization_id AS immunization_id,
		CAST(NULL AS VARCHAR(150)) AS notes
	FROM cte_all_missing pfi
)

INSERT INTO @missingRecords
SELECT
	fac_grp.col1, 
	fac_grp.col2, 
	fac_grp.col3, 
	fac_grp.col4, 
	fac_grp.col5, 
	fac_grp.col6,
	facility.fac_id,
	facility.facility_name AS Facility ,
	bed.unit_desc AS Unit ,
	f.std_immunization_id,
	immunization.description AS Immunization,
	CASE
	    WHEN f.std_immunization_id = 5 THEN '(Step ' + CAST(f.step_id AS char(1)) + ')'
	    WHEN f.std_immunization_id = @covid19ImmunizationId THEN '(Dose ' + CAST(f.step_id AS char(1)) + ')'
	    ELSE ''
	END AS Step,
	consent.description AS [Consent Type],
	f.reason_code_id,
	reason.description AS Reason,
	f.result_code_id,
	result.description AS Results,
	--detail info
	cl.client_id,
	cl.last_name + ', ' + cl.first_name + ' (' + cl.client_id_number + ')'  as Resident,
	f.consent_code_id,
	f.consent_date AS [Consent Date],
	f.consent_by AS [Consent Confirmed By],
	CASE WHEN f.education_date_id IS NOT NULL THEN 'Yes' ELSE 'No' END AS [Education Provided To Resident/Family],
	f.immun_date AS [Administration Date],
	userDim.long_username AS [Administered By],
	routeDim.description as [Route of Administration],
	f.dose_amount AS [Dose Amount],
	uom.description AS [Uom],
	body.item_description AS [Location Given],
	m.manufacturer_name AS [Manufacturer's Name],
	f.expiration_date AS [Substance Expiration Date],
	f.lot_number AS [Lot Number],
	f.induration AS [Induration],
	userSt.long_username AS [Struck Out By],
	f.strikeout_date AS [Strike Out Date],
	--infra
	f.fact_immunization_id,
	f.immunization_id,
	f.notes
FROM cte_fact f
LEFT JOIN reporting.ldl_fn_dim_FacilityCode(@group_lvl1, @group_lvl2, @group_lvl3, @group_lvl4, @group_lvl5, @group_lvl6) fac_grp
	ON 	fac_grp.fac_id = f.fac_id
INNER JOIN reporting.ldl_view_dim_Client cl 
	ON f.client_id = cl.client_id
INNER JOIN reporting.ldl_view_dim_Facility facility
	ON f.fac_id = facility.fac_id
LEFT JOIN reporting.ldl_view_dim_BedLocation bed
	ON f.bed_id = bed.bed_id
INNER JOIN reporting.ldl_view_dim_Immunization immunization
	ON f.std_immunization_id = immunization.std_immunization_id
INNER JOIN reporting.ldl_view_dim_ConsentStatusCode consent
	ON f.consent_code_id = consent.consent_code_id 
INNER JOIN reporting.ldl_view_dim_ReasonStatusCode reason
	ON  f.reason_code_id = reason.reason_code_id
INNER JOIN reporting.ldl_view_dim_ResultStatusCode result
	ON f.result_code_id = result.result_code_id
LEFT JOIN reporting.ldl_view_dim_User userDim
	ON f.administered_by_id = userDim.userid
INNER JOIN reporting.ldl_view_dim_RouteOfAdmin routeDim
	ON f.route_of_admin_id = routeDim.route_of_admin_id
LEFT JOIN reporting.ldl_view_dim_BodyLocation body
	ON f.body_location_id = body.body_location_id
INNER JOIN reporting.ldl_view_dim_Manufacturer m
	ON f.manufacturer_id = m.manufacturer_id 
INNER JOIN reporting.ldl_view_dim_User userSt
	ON f.strikeout_user_id = userSt.userid
INNER JOIN reporting.ldl_view_dim_UnitOfMeasure uom
	ON f.unit_of_measure_id = uom.uom_id
WHERE EXISTS (SELECT 1 FROM @Consent WHERE id = 5) --append missing		
;

RETURN
END
GO

GRANT SELECT ON reporting.bdl_fn_ImmunizationRate_MissingRecords TO PUBLIC;
GO


GO

print 'G_EnterpriseReporting_Branch/3_Functions/reporting.bdl_fn_ImmunizationRate_MissingRecords.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/3_Functions/reporting.bdl_fn_ImmunizationRate_MissingRecords.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/4_Views/ERP054_ldl_view_fact_Immunization.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

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

print 'G_EnterpriseReporting_Branch/4_Views/ERP054_ldl_view_fact_Immunization.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/4_Views/ERP054_ldl_view_fact_Immunization.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.bdl_sproc_ActionSummary2.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

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
-- CORE-34476        :  Script to create [bdl_sproc_ActionSummary] Procedure in Client Database
--						-- 
-- Written By:          Amro Saada
-- Reviewed By:         
-- 
-- Script Type:         DDL 
-- Target DB Type:      Client Database
-- Target ENVIRONMENT:  BOTH 
-- 
-- 
-- Re-Runable:          YES 
-- 
-- Description of Script : Create bdl_sproc_ActionSummary2 Procedure 
-- 
-- Special Instruction: 
-- 
-- =================================================================================
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.ROUTINES
				 WHERE ROUTINE_SCHEMA = 'reporting' AND ROUTINE_NAME = 'bdl_sproc_ActionSummary2' AND ROUTINE_TYPE = 'PROCEDURE' ) 
BEGIN
	DROP PROCEDURE [reporting].[bdl_sproc_ActionSummary2];
END

GO

CREATE PROCEDURE [reporting].[bdl_sproc_ActionSummary2]
 @fac_ids					varchar(max)       -- Comma separated facility id's
,@output_format				char(3)            -- csv/pdf
,@start_date				datetime
,@end_date					datetime
,@hrchy_lvl1				int  = NULL 	   -- Hierarchy level1
,@hrchy_lvl2				int  = NULL 	   -- Hierarchy level2
,@hrchy_lvl3				int  = NULL 	   -- Hierarchy level3
,@hrchy_lvl4				int  = NULL        -- Hierarchy level4
,@hrchy_lvl5				int  = NULL 	   -- Hierarchy level5 
,@hrchy_lvl6				int  = NULL        -- Hierarchy level6
,@summary_detail_options    tinyint = 2        -- 0 for Summary, 1 for detail, and 2 for Detail and Summary
,@summary_by                tinyint = 0        -- 0 for Action Code, and 1 for Payer by Action Code
,@action_code				varchar(max)       -- Comma separated action code id's (-1) for all
,@report_by					tinyint	           -- 0 for Payer, and 1 for Payer Type
,@report_by_ids				varchar(max)	   -- Comma separated values, (-1) for all
,@insurance_ids				varchar(max)	   -- Comma separated values, (-1) for all, NULL for "Clear All" - do not show
,@select_by					tinyint = 0        -- 0 for Effective date, and 1 for Created date
,@sort_by                   tinyint = 0        -- 0 for Created date, 1 for Effective date, 2 for Location, 3 for Resident, and 4 for Payer
,@unit                      varchar(max)	   -- Comma separated values, (-1) for all
,@floor						varchar(max)	   -- Comma separated values, (-1) for all
,@group_by_unit				bit = 0            -- 1 for group by unit
,@show_tofrom_desc          bit = 0 
,@show_tofrom_type			bit = 0 
,@show_comments				bit = 0 
,@show_diagnosis            bit = 0
,@execution_user_login      varchar(60) = ''

--/************************************************************************
--Revision History:
--2020-03-09  Amro Saada	CORE-64443	 Performance Enhancement
 
--Sample Execution Script:
--EXEC [reporting].[bdl_sproc_ActionSummary2]
-- @fac_ids	= '1'				  -- Comma separated facility id's
--,@output_format  = 'pdf'		  -- csv/pdf
--,@start_date = '2019-01-01'				
--,@end_date   = '2019-01-31'	
--,@hrchy_lvl1 = NULL			  -- Hierarchy level1
--,@hrchy_lvl2 = NULL			  -- Hierarchy level2
--,@hrchy_lvl3 = NULL			  -- Hierarchy level3
--,@hrchy_lvl4 = NULL			  -- Hierarchy level4
--,@hrchy_lvl5 = NULL			  -- Hierarchy level5 
--,@hrchy_lvl6 = NULL			  -- Hierarchy level6
--,@summary_detail_options = 2    -- 0 for Summary, 1 for detail, and 2 for Detail and Summary
--,@summary_by  = 0               -- 0 for Action Code, and 1 for Payer by Action Code
--,@action_code = '1,2,3,4,6,8,9,10,37,45,46,377,850,1336'  -- Comma separated action code id's 
--,@report_by = 0				  -- 0 for Payer, and 1 for Payer Type
--,@report_by_ids = '-1'		  -- Comma separated values, (-1) for all
--,@insurance_ids = '-1'		  -- Comma separated values, (-1) for all
--,@select_by = 0				  -- 0 for Effective date, and 1 for Created date
--,@sort_by  = 0                  -- 0 for Created date, 1 for Effective date, 2 for Location, 3 for Resident, and 4 for Payer
--,@unit  = '-1'                  -- Comma separated values, (-1) for all
--,@floor = '-1'		          -- Comma separated values, (-1) for all
--,@group_by_unit = 0		      -- 1 for group by unit
--,@show_tofrom_desc = 0 
--,@show_tofrom_type = 0 
--,@show_comments	 = 0 
--,@show_diagnosis   = 0
--,@execution_user_login = 'PCC-saadaa'

--**********************************************************************************/

AS
BEGIN 

SET NOCOUNT ON;

DECLARE
		 @vfac_ids					varchar(max) 
		,@voutput_format			char(3)                     
		,@vstart_date		        datetime
		,@vend_date		            datetime
		,@vhrchy_lvl1				int  
		,@vhrchy_lvl2				int 
		,@vhrchy_lvl3				int 
		,@vhrchy_lvl4				int
		,@vhrchy_lvl5				int
		,@vhrchy_lvl6				int
		,@vaction_code				varchar(max)         
		,@vreport_by				tinyint	            
		,@vreport_by_ids			varchar(max)
		,@vinsurance_ids			varchar(max)
		,@vselect_by				tinyint         
		,@vsort_by                  tinyint         
		,@vunit                     varchar(max)	    
		,@vfloor					varchar(max)	   
		,@vgroup_by_unit			bit             
		,@vshow_tofrom_desc         bit 
		,@vshow_tofrom_type			bit 
		,@vshow_comments	        bit
		,@vshow_diagnosis	        bit
		,@vdelim					char(1)
		,@vsummary_detail_options   tinyint
		,@vsummary_by               tinyint

		,@vShowInsurance            bit;

DECLARE @summary TABLE(fac_id int, payer_id int, insurance_id int, action_code_id int, total int); 
CREATE TABLE #facility(fac_id int PRIMARY KEY);
CREATE TABLE #actioncode(action_code_id int PRIMARY KEY);
CREATE TABLE #payer(payer_id int PRIMARY KEY);
CREATE TABLE #payer_type(payer_type varchar(20) PRIMARY KEY);
CREATE TABLE #insurance(insurance_id int PRIMARY KEY);
CREATE TABLE #unit(unit_id int PRIMARY KEY);
CREATE TABLE #floor(floor_id int PRIMARY KEY);
CREATE TABLE #census(census_id int, fac_id int, pri_loc int, loc int, pri_payer int, payer int, payer_address_id INT, insurance_id INT, action_type bit, status_code_id int, action_code_id int);
CREATE CLUSTERED INDEX [census__censusId_CL] ON #census (census_id);

SET @vfac_ids       = @fac_ids;					 
SET @voutput_format = @output_format;			                     
SET @vstart_date    = @start_date;		        
SET @vend_date	    = DATEADD(DD,1,@end_date);	
SET @vhrchy_lvl1    = @hrchy_lvl1;
SET @vhrchy_lvl2    = @hrchy_lvl2;
SET @vhrchy_lvl3    = @hrchy_lvl3;
SET @vhrchy_lvl4    = @hrchy_lvl4;
SET @vhrchy_lvl5    = @hrchy_lvl5;
SET @vhrchy_lvl6    = @hrchy_lvl6;            
SET @vaction_code   = @action_code;				         
SET @vreport_by	    = @report_by;		          
SET @vreport_by_ids	= @report_by_ids;
SET @vinsurance_ids = IIF(RTRIM(@insurance_ids) = '', NULL, @insurance_ids);
SET @vselect_by		= @select_by;			      
SET @vsort_by       = @sort_by ;                 
SET @vunit          = @unit;                   
SET @vfloor			= @floor;			   
SET @vgroup_by_unit	= @group_by_unit;		             
SET @vshow_tofrom_desc = @show_tofrom_desc;        
SET @vshow_tofrom_type = @show_tofrom_type;		 
SET @vshow_comments	   = @show_comments;      
SET @vshow_diagnosis   = @show_diagnosis;
SET @vdelim	 = ',';
SET @vsummary_detail_options = @summary_detail_options;
SET @vsummary_by  = @summary_by;

SET @vShowInsurance = IIF(@vinsurance_ids IS NULL, 0, 1);


INSERT INTO #facility
SELECT items FROM dbo.split(@vfac_ids, @vdelim);


INSERT INTO #actioncode
SELECT items FROM dbo.split(@vaction_code, @vdelim);


IF @vreport_by = 0 AND @vreport_by_ids <> '-1'
BEGIN
	INSERT INTO #payer
	SELECT items FROM dbo.split(@vreport_by_ids, @vdelim);
END

IF @vreport_by = 1 AND @vreport_by_ids <> '-1'
BEGIN
	INSERT INTO #payer_type
	SELECT [payer_type_desc] FROM [reporting].[ldl_view_dim_ArLibPayerType] WHERE payer_type_id IN (SELECT items FROM dbo.split(@vreport_by_ids, @vdelim));
END

IF @vShowInsurance = 1 AND @vinsurance_ids <> '-1'
BEGIN
	INSERT INTO #insurance
	SELECT items FROM dbo.split(@vinsurance_ids, @vdelim);
END

IF @vunit <> '-1'
BEGIN
	INSERT INTO #unit
	SELECT items FROM dbo.split(@vunit, @vdelim);
END

IF @vfloor <> '-1'
BEGIN
	INSERT INTO #floor
	SELECT items FROM dbo.split(@vfloor, @vdelim);
END

IF @vselect_by = 0 
BEGIN

INSERT INTO #census(census_id,fac_id,loc,payer,action_type,status_code_id, action_code_id)
SELECT  
        ci.census_id 
	   ,ci.fac_id
	   ,ci.bed_id
	   ,ci.primary_payer_id  
       ,CASE WHEN cac.action_type IN ('Internal Transfer','Return from Leave') THEN 1 ELSE 0 END AS action_type     
       ,ci.status_code_id 
	   ,ci.action_code_id    
FROM   [reporting].[ldl_view_fact_CensusItem] AS ci 
	   INNER JOIN [reporting].[ldl_view_dim_Client] c
		   ON ci.client_id  = c.client_id
	   INNER JOIN #actioncode ac
		  ON ac.action_code_id = ci.action_code_id
	   INNER JOIN #facility f
			ON f.fac_id = c.fac_id
       INNER JOIN [reporting].[ldl_view_dim_CensusActionCode] cac 
			ON ci.action_code_id = cac.action_code_id
	   LEFT JOIN [reporting].[ldl_view_dim_ArLibPayer] libpayer 
              ON ci.primary_payer_id = libpayer.payer_id 
WHERE     (@vselect_by = 0 AND ci.effective_date >= @vstart_date AND ci.effective_date < @vend_date)
	  AND (libpayer.payer_type IS NULL OR libpayer.payer_type <> 'Outpatient' ) 
      AND ( ci.record_type IS NULL OR ci.record_type = 'C' );

END
ELSE
BEGIN

INSERT INTO #census(census_id,fac_id,loc,payer,action_type,status_code_id, action_code_id)
SELECT  
        ci.census_id 
	   ,ci.fac_id
	   ,ci.bed_id
	   ,ci.primary_payer_id  
       ,CASE WHEN cac.action_type IN ('Internal Transfer','Return from Leave') THEN 1 ELSE 0 END AS action_type     
       ,ci.status_code_id 
	   ,ci.action_code_id    
FROM   [reporting].[ldl_view_fact_CensusItem] AS ci 
	   INNER JOIN [reporting].[ldl_view_dim_Client] c
		   ON ci.client_id  = c.client_id
	   INNER JOIN #facility f
			ON f.fac_id = c.fac_id
	   INNER JOIN #actioncode ac
		  ON ac.action_code_id = ci.action_code_id
       INNER JOIN [reporting].[ldl_view_dim_CensusActionCode] cac 
			ON ci.action_code_id = cac.action_code_id
	   LEFT JOIN [reporting].[ldl_view_dim_ArLibPayer] libpayer 
              ON ci.primary_payer_id = libpayer.payer_id 
WHERE     (@vselect_by = 1 AND ci.created_date >= @vstart_date AND ci.created_date < @vend_date)
	  AND (libpayer.payer_type IS NULL OR libpayer.payer_type <> 'Outpatient' ) 
      AND ( ci.record_type IS NULL OR ci.record_type = 'C' );
END

;WITH cte_pre_census
AS
( SELECT ci.census_id
        ,ci.client_id
		,ci.bed_id 
        ,ci.primary_payer_id  
        ,ROW_NUMBER() OVER (PARTITION BY ci.client_id ORDER BY ci.effective_date ) AS sequence_number
      FROM [reporting].[ldl_view_fact_CensusItem] AS ci
	  INNER JOIN [reporting].[ldl_view_dim_Client] c
		   ON ci.client_id  = c.client_id
	   INNER JOIN #facility f
			ON f.fac_id = c.fac_id
	  INNER JOIN (
	  SELECT DISTINCT ci.client_id FROM #census c 
	  INNER JOIN [reporting].[ldl_view_fact_CensusItem] AS ci  
		ON ci.census_id = c.census_id
	  WHERE ci.status_code_id = 17 OR c.action_type = 1) dci
           ON dci.client_id = ci.client_id
	  WHERE (ci.record_type IS NULL OR ci.record_type = 'C') 
)
UPDATE c SET 
	 pri_loc = CASE WHEN c.action_type = 1 THEN C2.bed_id END 
	,loc = CASE WHEN c.status_code_id = 17 THEN c2.bed_id ELSE loc END
	,pri_payer = CASE WHEN c.action_type = 1 THEN c2.primary_payer_id END
FROM #census c
INNER JOIN cte_pre_census c1
	ON c.census_id = c1.census_id
INNER JOIN cte_pre_census c2
	ON c1.client_id = c2.client_id AND c2.sequence_number = c1.sequence_number - 1;


WITH cte_stopbilling_payer
AS(
	SELECT dci.client_id
		,dci.effective_date
		,ci.primary_payer_id
		,ROW_NUMBER() OVER (PARTITION BY dci.client_id, dci.effective_date ORDER BY ci.effective_date DESC) AS row_num
	FROM [reporting].[ldl_view_fact_CensusItem] AS ci
	INNER JOIN [reporting].[ldl_view_dim_Client] c
		ON ci.client_id = c.client_id
	INNER JOIN #facility f
		ON f.fac_id = c.fac_id
	INNER JOIN (
			SELECT ci.client_id
				,ci.effective_date
			FROM #census c
			INNER JOIN [reporting].[ldl_view_fact_CensusItem] AS ci
				ON ci.census_id = c.census_id
			INNER JOIN [reporting].[ldl_view_dim_Client] cl
				ON ci.client_id = cl.client_id
			WHERE ci.status_code_id = 17
		) dci
		ON dci.client_id = ci.client_id
	WHERE (ci.record_type IS NULL OR ci.record_type = 'R')
		AND ci.primary_payer_id IS NOT NULL
		AND ci.effective_date < DATEADD(DD, DATEDIFF(DD, 0, dci.effective_date), 1) 
)
UPDATE c SET 
	  payer = CASE WHEN c.status_code_id = 17 THEN sb.primary_payer_id ELSE payer END
FROM #census c
INNER JOIN [reporting].[ldl_view_fact_CensusItem] AS ci 
	ON c.census_id = ci.census_id
INNER JOIN [reporting].[ldl_view_dim_Client] cl
	ON ci.client_id  = cl.client_id
INNER JOIN cte_stopbilling_payer sb
	ON ci.client_id = sb.client_id AND ci.effective_date = sb.effective_date AND sb.row_num = 1;

--Add outpatient residents census

IF @vselect_by = 0 
BEGIN
INSERT INTO #census(census_id,fac_id,payer,action_code_id)
SELECT  
        ci.census_id 
	   ,ci.fac_id
	   ,ci.primary_payer_id  
       ,CASE ci.outpatient_status WHEN 'A' THEN '-1' ELSE '0' END AS action_code_id    
FROM   [reporting].[ldl_view_fact_CensusItem] AS ci
	   INNER JOIN [reporting].[ldl_view_dim_Client] c
		   ON ci.client_id  = c.client_id
	   INNER JOIN #facility f
			ON ci.fac_id = f.fac_id
	   LEFT JOIN [reporting].[ldl_view_dim_ArLibPayer] libpayer 
              ON ci.primary_payer_id  = libpayer.payer_id 
	   LEFT JOIN #payer p
		      ON p.payer_id = libpayer.payer_id
	   LEFT JOIN #payer_type pt
			  ON pt.payer_type = libpayer.payer_type
WHERE (@vselect_by = 0 AND ci.effective_date >= @vstart_date AND ci.effective_date < @vend_date)		
	  AND libpayer.payer_type = 'Outpatient' AND ci.outpatient_status IS NOT NULL
      AND ( ci.record_type IS NULL OR ci.record_type = 'C' ) 
	  AND (  
	         (@vreport_by_ids = '-1')
			   OR 
			 (@vreport_by = 0 AND p.payer_id = libpayer.payer_id) 
			   OR 
			 (@vreport_by = 1 AND pt.payer_type = libpayer.payer_type)
		  );
END
ELSE
BEGIN
INSERT INTO #census(census_id,fac_id,payer,action_code_id)
SELECT  
        ci.census_id 
	   ,ci.fac_id
	   ,ci.primary_payer_id  
       ,CASE ci.outpatient_status WHEN 'A' THEN '-1' ELSE '0' END AS action_code_id    
FROM   [reporting].[ldl_view_fact_CensusItem] AS ci
	   INNER JOIN [reporting].[ldl_view_dim_Client] c
		   ON ci.client_id  = c.client_id
	   INNER JOIN #facility f
			ON ci.fac_id = f.fac_id
	   LEFT JOIN [reporting].[ldl_view_dim_ArLibPayer] libpayer 
              ON ci.primary_payer_id  = libpayer.payer_id 
	   LEFT JOIN #payer p
		      ON p.payer_id = libpayer.payer_id
	   LEFT JOIN #payer_type pt
			  ON pt.payer_type = libpayer.payer_type
WHERE (@vselect_by = 1 AND ci.created_date >= @vstart_date AND ci.created_date < @vend_date)
	  AND libpayer.payer_type = 'Outpatient' AND ci.outpatient_status IS NOT NULL
      AND ( ci.record_type IS NULL OR ci.record_type = 'C' ) 
	  AND (  
	         (@vreport_by_ids = '-1')
			   OR 
			 (@vreport_by = 0 AND p.payer_id = libpayer.payer_id) 
			   OR 
			 (@vreport_by = 1 AND pt.payer_type = libpayer.payer_type)
		  );
END


IF @vShowInsurance = 1
BEGIN
	-- client setup insurance
	UPDATE c
	SET insurance_id = ins.insurance_id
		, payer_address_id = ins.payer_address_id
	FROM #census c
		JOIN reporting.ldl_view_fact_CensusItem AS ci
			ON ci.census_id = c.census_id
		JOIN reporting.ldl_view_fact_Insurance ins
			ON ins.fac_id = c.fac_id
				AND ins.client_id = ci.client_id
				AND ins.payer_id = c.payer
				AND ins.date_id = CAST(FORMAT(ci.effective_date, 'yyyyMMdd') AS int);

	-- payer default insurance
	UPDATE c
	SET insurance_id = ia.insurance_id
		, payer_address_id = p.default_address_id
	FROM #census c
		JOIN reporting.ldl_view_fact_CensusItem AS ci
			ON ci.census_id = c.census_id
		JOIN reporting.ldl_view_dim_Payer p
			ON p.payer_id = c.payer
				AND p.default_address_id IS NOT NULL
		JOIN reporting.ldl_view_dim_InsuranceAddress ia
			ON ia.address_id = p.default_address_id
				AND ia.effective_date <= ci.effective_date
				AND (ia.ineffective_date IS NULL OR ia.ineffective_date > ci.effective_date)
	WHERE c.insurance_id IS NULL;
END

-- apply filter
IF (@vunit <> '-1' OR @vfloor <> '-1' OR @vreport_by_ids <> '-1' OR (@vShowInsurance = 1 AND @vinsurance_ids <> '-1'))
BEGIN

	WITH cte_loc_payer_filter AS (
		SELECT ci.census_id
		FROM #census ci
			LEFT JOIN [reporting].[ldl_view_dim_BedLocation] bl
				ON ci.loc = bl.bed_id
			LEFT JOIN #unit ut
				ON ut.unit_id = bl.unit_id
			LEFT JOIN #floor fl
				ON fl.floor_id = bl.floor_id
			LEFT JOIN [reporting].[ldl_view_dim_ArLibPayer] libpayer
				ON ci.payer = libpayer.payer_id
			LEFT JOIN #payer p
				ON p.payer_id = libpayer.payer_id
			LEFT JOIN #payer_type pt
				ON pt.payer_type = libpayer.payer_type
			LEFT JOIN #insurance ins
				ON ins.insurance_id = ci.insurance_id
		WHERE (@vunit = '-1' OR ut.unit_id IS NOT NULL OR libpayer.payer_type = 'Outpatient')
			AND (@vfloor = '-1' OR fl.floor_id IS NOT NULL OR libpayer.payer_type = 'Outpatient')
			AND (@vreport_by_ids = '-1' 
					OR (@vreport_by = 0 AND p.payer_id IS NOT NULL)
					OR (@vreport_by = 1 AND pt.payer_type IS NOT NULL)
				)
			AND (@vShowInsurance = 0 OR @vinsurance_ids = '-1' OR ins.insurance_id IS NOT NULL)
	)
	DELETE c
	FROM #census c
		LEFT JOIN cte_loc_payer_filter flt
			ON flt.census_id = c.census_id
	WHERE flt.census_id IS NULL;

END


IF EXISTS (SELECT 1 FROM #census)
BEGIN

	IF @voutput_format = 'pdf' AND @vsummary_detail_options IN (0,2)
	BEGIN
		INSERT INTO @summary
		SELECT  fac_id
			   ,CASE @vsummary_by WHEN 1 THEN payer END AS payer_id
			   ,CASE @vsummary_by WHEN 1 THEN insurance_id END AS insurance_id
			   ,action_code_id
			   ,COUNT(*) AS total
		FROM #census
		GROUP BY fac_id
			, CASE @vsummary_by WHEN 1 THEN payer END
			, CASE @vsummary_by WHEN 1 THEN insurance_id END
			, action_code_id;
	END

IF @voutput_format = 'csv'	-- Show CSV
BEGIN

WITH CsvDetails_CTE AS (
SELECT 
	    CASE WHEN @vhrchy_lvl1 IS NOT NULL THEN h.col1 END AS lvl1
	   ,CASE WHEN @vhrchy_lvl2 IS NOT NULL THEN h.col2 END AS lvl2
	   ,CASE WHEN @vhrchy_lvl3 IS NOT NULL THEN h.col3 END AS lvl3
	   ,CASE WHEN @vhrchy_lvl4 IS NOT NULL THEN h.col4 END AS lvl4
	   ,CASE WHEN @vhrchy_lvl5 IS NOT NULL THEN h.col5 END AS lvl5
	   ,CASE WHEN @vhrchy_lvl6 IS NOT NULL THEN h.col6 END AS lvl6
	   ,fac.facility_code
	   ,fac.facility_name
       ,c.first_name 
       ,c.last_name 
       ,c.client_id_number 
       ,CASE WHEN cs.action_code_id > 0 THEN cac.action_code WHEN cs.action_code_id = -1 THEN 'OA' ELSE  'OD' END AS action_code
	   ,CASE WHEN cs.action_code_id > 0 THEN cac.action_desc WHEN cs.action_code_id = -1 THEN 'Outpatient Admission' ELSE  'Outpatient Discharge' END  AS action_desc
	   ,ds.item_description AS [discharge_status]
	   ,bl1.room_desc + '-' + bl1.bed_desc AS [prior_location]
       ,bl.room_desc + '-' + bl.bed_desc AS [location] 
	   ,CAST (ci.effective_date AS date) AS effective_date
	   ,FORMAT(ci.effective_date, 'hh:mm tt') AS effective_time
	   ,libpayer1.[payer_desc] AS [prior_payer]
	   ,libpayer.[payer_desc]  AS payer 
	   ,bl.unit_desc AS unit
	   ,CAST(DATEADD(HH,fac.time_zone, ci.created_date) AS date) AS created_date
	   ,FORMAT(DATEADD(HH,fac.time_zone, ci.created_date) , 'hh:mm tt') AS created_time
	   ,CASE @vshow_tofrom_desc WHEN 1 THEN ToFrmLoc.[description] END AS to_from_location
	   ,CASE @vshow_tofrom_type WHEN 1 THEN ToFrm.[description] END AS to_from_type	    	 	       
	   ,CASE @vshow_comments    WHEN 1 THEN ci.comments END AS comments
	   ,cd.diagnosis_id
       ,cs.insurance_id
	   ,cs.payer_address_id
	   ,row_num = RANK() OVER (PARTITION BY c.client_id, cd.diag_classification_id, cd.rank_id ORDER BY cd.onset_date DESC)
FROM #census cs
    INNER JOIN [reporting].[ldl_view_fact_CensusItem] AS ci
		ON  ci.census_id = cs.census_id
    INNER JOIN [reporting].[ldl_view_dim_facility] fac
		ON ci.fac_id = fac.fac_id
	LEFT JOIN [reporting].[ldl_view_dim_CensusActionCode] cac 
		ON ci.action_code_id = cac.action_code_id
	LEFT JOIN [reporting].[ldl_fn_dim_FacilityCode](@vhrchy_lvl1,@vhrchy_lvl2,@vhrchy_lvl3,@vhrchy_lvl4,@vhrchy_lvl5,@vhrchy_lvl6) h
	    ON fac.fac_id = h.fac_id 
    LEFT JOIN [reporting].[ldl_view_dim_Client] c
		ON ci.client_id = c.client_id 
	LEFT JOIN [reporting].[ldl_view_dim_ToFromType] ToFrm 
		ON ci.tofromtype_id = ToFrm.tofromtype_id 
	LEFT JOIN [reporting].[ldl_view_dim_ToFromLocation] ToFrmLoc 
	    ON ci.tofromlocation_id = ToFrmLoc.tofromlocation_id   
	LEFT JOIN [reporting].[ldl_view_dim_ArLibPayer] libpayer 
        ON cs.payer = libpayer.payer_id 
    LEFT JOIN [reporting].[ldl_view_dim_ArLibPayer] libpayer1 
        ON cs.pri_payer = libpayer1.payer_id
    LEFT JOIN [reporting].[ldl_view_dim_BedLocation] bl
        ON  cs.loc = bl.bed_id 
    LEFT JOIN [reporting].[ldl_view_dim_BedLocation] bl1
        ON cs.pri_loc = bl1.bed_id 
	LEFT JOIN [reporting].[ldl_view_dim_DischargeStatus] ds
		ON ds.item_id = ci.discharge_status        
	LEFT JOIN reporting.ldl_view_dim_ArConfiguration ac
		ON ac.fac_id = ci.fac_id
	LEFT JOIN [reporting].[ldl_view_fact_ClientDiagnosis] cd
        ON @vshow_diagnosis = 1
		    AND cd.client_id = ci.client_id
			AND cd.fac_id = ac.fac_id
			AND cd.rank_id = ac.diag_principal
			AND (cd.onset_date < ci.ineffective_date OR ci.ineffective_date IS NULL)
			AND (cd.resolved_date >= ci.effective_date OR cd.resolved_date IS NULL)
			AND cd.struck_out = 0
)
SELECT d.lvl1
	, d.lvl2
	, d.lvl3
	, d.lvl4
	, d.lvl5
	, d.lvl6
	, d.facility_code
	, d.facility_name
	, d.first_name 
	, d.last_name 
	, d.client_id_number 
	, d.action_code
	, d.action_desc
	, d.[discharge_status]
	, d.[prior_location]
	, d.[location] 
	, d.effective_date
	, d.effective_time
	, d.[prior_payer]
	, d.payer 
	, d.unit
	, d.created_date
	, d.created_time
	, d.to_from_location
	, d.to_from_type	    	 	       
	, d.comments
	, diagnosis_code = dc.icd9_code
	, diagnosis = dc.icd9_full_desc
	, insurance_company = i.[description]
	, i.insurance_id
	, insurance_addr_address1        = ia.address1
	, insurance_addr_address2        = ia.address2
	, insurance_addr_city            = ia.city
	, insurance_addr_county          = county.[name]
	, insurance_addr_prov_state      = ia.prov_state
	, insurance_addr_country         = country.item_description
	, insurance_addr_postal_zip_code = ia.postal_zip_code
FROM CsvDetails_CTE d
	LEFT JOIN [reporting].[ldl_view_dim_DiagnosisCode] dc
		ON dc.diagnosis_id = d.diagnosis_id
	LEFT JOIN reporting.ldl_view_dim_Insurance i
		ON i.insurance_id = d.insurance_id
	LEFT JOIN reporting.ldl_view_dim_InsuranceAddress ia
		ON ia.insurance_id = d.insurance_id
			AND ia.address_id = d.payer_address_id
	LEFT JOIN common_code country
		ON country.item_id = ia.country_id
			AND country.deleted = 'N'
	LEFT JOIN county county
		ON county.county_id = ia.county_id
WHERE d.row_num = 1
ORDER BY d.lvl1, d.lvl2, d.lvl3, d.lvl4, d.lvl5, d.lvl6
	, d.facility_code, d.facility_name, d.action_code, d.first_name, d.last_name, d.effective_date;

END	
ELSE IF @voutput_format = 'pdf' AND @vsummary_detail_options = 1 --Show PDF Detail only option
BEGIN

WITH PdfDetails_CTE AS (
	SELECT 
		fac.fac_id
		,fac.facility_name
		,CASE WHEN cs.action_code_id > 0 THEN cac.action_code WHEN cs.action_code_id = -1 THEN 'OA' ELSE 'OD' END AS action_code
		,ds.item_description AS [discharge_status]
		,c.last_name  
		,c.first_name 
		,c.client_id_number 
		,bl1.room_desc + '-' + bl1.bed_desc AS [prior_location]
		,bl.room_desc + '-' + bl.bed_desc AS [location] 
		,CAST (ci.effective_date AS date) AS effective_date
		,FORMAT(ci.effective_date, 'hh:mm tt') AS effective_time
		,libpayer1.[payer_desc] AS [prior_payer]
		,libpayer.[payer_desc]  AS payer 
		,bl.unit_desc AS unit
		,CAST(DATEADD(HH,fac.time_zone, ci.created_date) AS date) AS created_date
		,FORMAT(DATEADD(HH,fac.time_zone, ci.created_date) , 'hh:mm tt') AS created_time
		,CASE @vshow_tofrom_desc WHEN 1 THEN ToFrmLoc.[description] END AS to_from_location
		,CASE @vshow_tofrom_type WHEN 1 THEN ToFrm.[description] END AS to_from_type	    	 	       
		,CASE @vshow_comments    WHEN 1 THEN ci.comments END AS comments
		,NULL AS summary_payer
		,NULL AS summary_insurance
		,NULL AS summary_action
		,NULL AS summary_total
		,CASE WHEN cs.census_id > 1 THEN 1 END AS section
		,cd.diagnosis_id
		,c.client_id
		,payer_id = cs.payer
		,cs.insurance_id
		,row_num = RANK() OVER (PARTITION BY c.client_id, cd.diag_classification_id, cd.rank_id ORDER BY cd.onset_date DESC)
	FROM #facility f
		JOIN [reporting].[ldl_view_dim_facility] fac
			ON f.fac_id =  fac.fac_id
		JOIN #census cs
			ON fac.fac_id = cs.fac_id
		LEFT JOIN [reporting].[ldl_view_fact_CensusItem] AS ci
			 ON  ci.census_id = cs.census_id
		LEFT JOIN [reporting].[ldl_view_dim_CensusActionCode] cac 
			ON cs.action_code_id = cac.action_code_id
		LEFT JOIN [reporting].[ldl_view_dim_Client] c
			ON ci.client_id = c.client_id 
		LEFT JOIN [reporting].[ldl_view_dim_ToFromType] ToFrm 
			ON ci.tofromtype_id = ToFrm.tofromtype_id 
		LEFT JOIN [reporting].[ldl_view_dim_ToFromLocation] ToFrmLoc 
			ON ci.tofromlocation_id = ToFrmLoc.tofromlocation_id   
		LEFT JOIN [reporting].[ldl_view_dim_ArLibPayer] libpayer 
			ON cs.payer = libpayer.payer_id 
		LEFT JOIN [reporting].[ldl_view_dim_ArLibPayer] libpayer1 
			ON cs.pri_payer = libpayer1.payer_id
		LEFT JOIN [reporting].[ldl_view_dim_BedLocation] bl
			ON  cs.loc = bl.bed_id 
		LEFT JOIN [reporting].[ldl_view_dim_BedLocation] bl1
			ON cs.pri_loc = bl1.bed_id
		LEFT JOIN [reporting].[ldl_view_dim_DischargeStatus] ds
			ON ds.item_id = ci.discharge_status  
		LEFT JOIN reporting.ldl_view_dim_ArConfiguration ac
			ON ac.fac_id = ci.fac_id
		LEFT JOIN [reporting].[ldl_view_fact_ClientDiagnosis] cd
			ON @vshow_diagnosis = 1
				AND cd.client_id = ci.client_id
				AND cd.fac_id = ac.fac_id
				AND cd.rank_id = ac.diag_principal
				AND (cd.onset_date < ci.ineffective_date OR ci.ineffective_date IS NULL)
				AND (cd.resolved_date >= ci.effective_date OR cd.resolved_date IS NULL)
				AND cd.struck_out = 0
)
SELECT 
	  d.fac_id
	, d.facility_name
	, d.action_code
	, d.[discharge_status]
	, d.last_name  
	, d.first_name 
	, d.client_id_number 
	, d.[prior_location]
	, d.[location] 
	, d.effective_date
	, d.effective_time
	, d.[prior_payer]
	, d.payer 
	, d.unit
	, d.created_date
	, d.created_time
	, d.to_from_location
	, d.to_from_type	    	 	       
	, d.comments
	, d.summary_payer
	, d.summary_insurance
	, d.summary_action
	, d.summary_total
	, d.section
	, diagnosis_code = dc.icd9_code
	, insurance_company = i.[description]
FROM PdfDetails_CTE d
	LEFT JOIN [reporting].[ldl_view_dim_DiagnosisCode] dc
		ON @vshow_diagnosis = 1
			AND dc.diagnosis_id = d.diagnosis_id
	LEFT JOIN reporting.ldl_view_dim_Insurance i
		ON i.insurance_id = d.insurance_id
WHERE d.row_num = 1
ORDER BY d.facility_name
	,CASE @vgroup_by_unit WHEN 0 THEN d.action_code ELSE d.unit END
	,CASE @vsort_by WHEN 0 THEN d.created_date END
	,CASE @vsort_by WHEN 1 THEN d.effective_date END
	,CASE @vsort_by WHEN 2 THEN d.[location] END
	,CASE @vsort_by WHEN 4 THEN d.payer END
	,d.last_name, d.first_name, d.client_id_number
	,CASE WHEN @vsort_by > 1 THEN d.effective_date END;

END

ELSE IF @voutput_format = 'pdf' AND @vsummary_detail_options = 0 --Show PDF Summary option
BEGIN

	SELECT        
			fac.fac_id
		   ,fac.facility_name
		   ,NULL AS action_code
		   ,NULL AS last_name  
		   ,NULL AS first_name 
		   ,NULL AS client_id_number 
		   ,NULL AS [prior_location]
		   ,NULL AS [location] 
		   ,NULL AS effective_date
		   ,NULL AS effective_time
		   ,NULL AS [prior_payer]
		   ,NULL AS payer 
		   ,NULL AS unit
		   ,NULL AS created_date
		   ,NULL AS created_time
		   ,NULL AS to_from_location
		   ,NULL AS to_from_type	    	 	       
		   ,NULL AS comments
		   ,CASE WHEN @vsummary_by = 1 THEN libpayer.payer_desc END AS summary_payer
		   ,CASE WHEN @vsummary_by = 1 THEN ins.[description] END AS summary_insurance
		   ,CASE 
				 WHEN s.action_code_id > 0  THEN '[' + cac.action_code + '] - ' + cac.action_desc
				 WHEN s.action_code_id = -1 THEN '[OA] - Outpatient Admission'
				 ELSE '[OD] - Outpatient Discharge' 
			END AS summary_action
		   ,s.total AS summary_total
		   ,CASE WHEN s.total >= 1 THEN 2 END AS section
	FROM #facility f
		INNER JOIN [reporting].[ldl_view_dim_facility] fac
			ON f.fac_id = fac.fac_id
		LEFT JOIN @summary s
			ON s.fac_id = fac.fac_id
		LEFT JOIN [reporting].[ldl_view_dim_CensusActionCode] cac 
			ON s.action_code_id = cac.action_code_id
		LEFT JOIN [reporting].[ldl_view_dim_ArLibPayer] libpayer
			ON s.payer_id = libpayer.payer_id
		LEFT JOIN reporting.ldl_view_dim_Insurance ins
			ON ins.insurance_id = s.insurance_id
	ORDER BY fac.facility_name, summary_payer, summary_insurance, summary_action;

END	 

ELSE IF @voutput_format = 'pdf' AND @vsummary_detail_options = 2 --Show PDF Summary and Details option
BEGIN

WITH PdfDetails_CTE AS
(
SELECT 
        fac.fac_id
       ,CASE WHEN cs.action_code_id > 0 THEN cac.action_code WHEN cs.action_code_id = -1 THEN 'OA' ELSE 'OD' END AS action_code
	   ,ds.item_description AS [discharge_status]
	   ,c.last_name  
       ,c.first_name 
       ,c.client_id_number 
	   ,bl1.room_desc + '-' + bl1.bed_desc AS [prior_location]
       ,bl.room_desc + '-' + bl.bed_desc AS [location] 
	   ,ci.effective_date 
	   ,libpayer1.[payer_desc] AS [prior_payer]
	   ,libpayer.[payer_desc]  AS payer 
	   ,bl.unit_desc AS unit
	   ,DATEADD(HH,fac.time_zone, ci.created_date)  AS created_date
	   ,CASE @vshow_tofrom_desc WHEN 1 THEN ToFrmLoc.[description] END AS to_from_location
	   ,CASE @vshow_tofrom_type WHEN 1 THEN ToFrm.[description] END AS to_from_type	    	 	       
	   ,CASE @vshow_comments    WHEN 1 THEN ci.comments END AS comments
	   ,NULL AS summary_payer
	   ,NULL AS summary_insurance
	   ,NULL AS summary_action
	   ,NULL AS summary_total
       ,1    AS section
       ,cd.diagnosis_id
	   ,c.client_id
       ,payer_id = cs.payer
	   ,cs.insurance_id
       ,row_num = RANK() OVER (PARTITION BY c.client_id, cd.diag_classification_id, cd.rank_id ORDER BY cd.onset_date DESC)
FROM #census cs
	INNER JOIN [reporting].[ldl_view_dim_facility] fac
		ON cs.fac_id = fac.fac_id
    INNER JOIN [reporting].[ldl_view_fact_CensusItem] AS ci
		ON  ci.census_id = cs.census_id
	LEFT JOIN [reporting].[ldl_view_dim_CensusActionCode] cac 
		ON cs.action_code_id = cac.action_code_id
    LEFT JOIN [reporting].[ldl_view_dim_Client] c
		ON ci.client_id = c.client_id 
	LEFT JOIN [reporting].[ldl_view_dim_ToFromType] ToFrm 
		ON ci.tofromtype_id = ToFrm.tofromtype_id 
	LEFT JOIN [reporting].[ldl_view_dim_ToFromLocation] ToFrmLoc 
	    ON ci.tofromlocation_id = ToFrmLoc.tofromlocation_id   
	LEFT JOIN [reporting].[ldl_view_dim_ArLibPayer] libpayer 
        ON cs.payer = libpayer.payer_id 
    LEFT JOIN [reporting].[ldl_view_dim_ArLibPayer] libpayer1 
        ON cs.pri_payer = libpayer1.payer_id
    LEFT JOIN [reporting].[ldl_view_dim_BedLocation] bl
        ON  cs.loc = bl.bed_id 
    LEFT JOIN [reporting].[ldl_view_dim_BedLocation] bl1
        ON cs.pri_loc = bl1.bed_id
	LEFT JOIN [reporting].[ldl_view_dim_DischargeStatus] ds
		ON ds.item_id = ci.discharge_status 
	LEFT JOIN reporting.ldl_view_dim_ArConfiguration ac
		ON ac.fac_id = ci.fac_id
	LEFT JOIN [reporting].[ldl_view_fact_ClientDiagnosis] cd
		ON @vshow_diagnosis = 1
			AND cd.client_id = ci.client_id
			AND cd.fac_id = ac.fac_id
			AND cd.rank_id = ac.diag_principal
			AND (cd.onset_date < ci.ineffective_date OR ci.ineffective_date IS NULL)
			AND (cd.resolved_date >= ci.effective_date OR cd.resolved_date IS NULL)
			AND cd.struck_out = 0
),
PdfDetailsWithDiagnosisAndInsurance_CTE AS (
	SELECT d.fac_id
       , d.action_code
	   , d.[discharge_status]
	   , d.last_name  
       , d.first_name 
       , d.client_id_number 
	   , d.[prior_location]
       , d.[location] 
	   , d.effective_date 
	   , d.[prior_payer]
	   , d.payer 
	   , d.unit
	   , d.created_date
	   , d.to_from_location
	   , d.to_from_type	    	 	       
	   , d.comments
	   , d.summary_payer
	   , d.summary_insurance
	   , d.summary_action
	   , d.summary_total
       , d.section
       , d.diagnosis_id
	   , d.client_id
       , d.payer_id
	   , diagnosis_code = dc.icd9_code
	   , insurance_company = i.[description]
	FROM PdfDetails_CTE d
	LEFT JOIN [reporting].[ldl_view_dim_DiagnosisCode] dc
		ON @vshow_diagnosis = 1
			AND dc.diagnosis_id = d.diagnosis_id
	LEFT JOIN reporting.ldl_view_dim_Insurance i
		ON i.insurance_id = d.insurance_id
WHERE d.row_num = 1
),
PdfSummary_CTE AS (
SELECT 
	    s.fac_id
       ,NULL AS action_code
	   ,NULL AS discharge_status
       ,NULL AS last_name  
       ,NULL AS first_name 
       ,NULL AS client_id_number 
	   ,NULL AS [prior_location]
       ,NULL AS [location] 
	   ,NULL AS effective_date
	   ,NULL AS [prior_payer]
	   ,NULL AS payer 
	   ,NULL AS unit
	   ,NULL AS created_date
	   ,NULL AS to_from_location
	   ,NULL AS to_from_type	    	 	       
	   ,NULL AS comments
	   ,CASE WHEN @vsummary_by = 1 THEN libpayer.payer_desc END AS summary_payer
	   ,CASE WHEN @vsummary_by = 1 THEN ins.[description] END AS summary_insurance
	   ,CASE 
			WHEN s.action_code_id > 0  THEN '[' + cac.action_code + '] - ' + cac.action_desc
			WHEN s.action_code_id = -1 THEN '[OA] - Outpatient Admission'
			ELSE '[OD] - Outpatient Discharge' 
		END AS summary_action
	   ,s.total AS summary_total
	   ,2    AS section
       ,diagnosis_id = NULL
	   ,client_id = NULL
	   ,payer_id = NULL
	   ,diagnosis_code = NULL
	   ,insurance_company = NULL
FROM  @summary s
	LEFT JOIN [reporting].[ldl_view_dim_CensusActionCode] cac 
		ON s.action_code_id = cac.action_code_id
	LEFT JOIN [reporting].[ldl_view_dim_ArLibPayer] libpayer 
        ON s.payer_id = libpayer.payer_id
	LEFT JOIN reporting.ldl_view_dim_Insurance ins
		ON ins.insurance_id = s.insurance_id
),
PdfDetailsAndSummary_CTE AS (
	SELECT 
		 pd.fac_id
       , pd.action_code
	   , pd.discharge_status
       , pd.last_name  
       , pd.first_name 
       , pd.client_id_number 
	   , pd.[prior_location]
       , pd.[location] 
	   , pd.effective_date
	   , pd.[prior_payer]
	   , pd.payer 
	   , pd.unit
	   , pd.created_date
	   , pd.to_from_location
	   , pd.to_from_type	    	 	       
	   , pd.comments
	   , pd.summary_payer
	   , pd.summary_insurance
	   , pd.summary_action
	   , pd.summary_total
	   , pd.section
       , pd.diagnosis_id
	   , pd.client_id
	   , pd.payer_id
	   , pd.diagnosis_code
	   , pd.insurance_company 
	FROM PdfDetailsWithDiagnosisAndInsurance_CTE pd
	UNION ALL
	SELECT 
		 ps.fac_id
       , ps.action_code
	   , ps.discharge_status
       , ps.last_name  
       , ps.first_name 
       , ps.client_id_number 
	   , ps.[prior_location]
       , ps.[location] 
	   , ps.effective_date
	   , ps.[prior_payer]
	   , ps.payer 
	   , ps.unit
	   , ps.created_date
	   , ps.to_from_location
	   , ps.to_from_type	    	 	       
	   , ps.comments
	   , ps.summary_payer
	   , ps.summary_insurance
	   , ps.summary_action
	   , ps.summary_total
	   , ps.section
       , ps.diagnosis_id
	   , ps.client_id
	   , ps.payer_id
	   , ps.diagnosis_code
	   , ps.insurance_company 
	FROM PdfSummary_CTE ps
)
SELECT 
         fac.fac_id
	   , fac.facility_name
       , ds.action_code
	   , ds.discharge_status
       , ds.last_name  
       , ds.first_name 
       , ds.client_id_number 
	   , ds.prior_location
       , ds.[location] 
	   , CAST( ds.effective_date AS DATE) AS effective_date
	   , FORMAT( ds.effective_date, 'hh:mm tt') AS effective_time
	   , ds.prior_payer 
	   , ds.payer 
	   , ds.unit
	   , CAST(ds.created_date AS DATE) AS created_date
	   , FORMAT(ds.created_date , 'hh:mm tt') AS created_time
	   , ds.to_from_location
	   , ds.to_from_type	    	 	       
	   , ds.comments
	   , ds.summary_payer
	   , ds.summary_insurance
	   , ds.summary_action
	   , ds.summary_total
	   , ds.section
	   , ds.diagnosis_code
	   , ds.insurance_company
FROM #facility f
	INNER JOIN [reporting].[ldl_view_dim_facility] fac
		ON f.fac_id = fac.fac_id
    LEFT JOIN PdfDetailsAndSummary_CTE ds
		ON fac.fac_id = ds.fac_id
ORDER BY  fac.facility_name,section
         ,CASE @vgroup_by_unit WHEN 0 THEN ds.action_code ELSE ds.unit END
		 ,CASE @vsort_by WHEN 0 THEN ds.created_date END
		 ,CASE @vsort_by WHEN 1 THEN ds.effective_date END
		 ,CASE @vsort_by WHEN 2 THEN ds.[location] END
         ,CASE @vsort_by WHEN 4 THEN payer END
		 ,ds.last_name, ds.first_name, ds.client_id_number
		 ,CASE WHEN @vsort_by > 1 THEN  ds.effective_date END 
         ,ds.summary_payer
         ,ds.summary_insurance
		 ,ds.summary_action;

END	
   
END
ELSE IF @voutput_format = 'csv'
BEGIN
SELECT 
	    NULL AS lvl1
	   ,NULL AS lvl2
	   ,NULL AS lvl3
	   ,NULL AS lvl4
	   ,NULL AS lvl5
	   ,NULL AS lvl6
	   ,NULL AS facility_code
	   ,NULL AS facility_name
       ,NULL AS first_name 
       ,NULL AS last_name 
       ,NULL AS client_id_number 
       ,NULL AS action_code 
	   ,NULL AS action_desc
	   ,NULL AS discharge_status
	   ,NULL AS prior_location 
       ,NULL AS [location] 
	   ,NULL AS effective_date
	   ,NULL AS effective_time
	   ,NULL AS prior_payer 
	   ,NULL AS  payer 
	   ,NULL AS unit
	   ,NULL AS created_date
	   ,NULL AS created_time
	   ,NULL AS to_from_location
	   ,NULL AS to_from_type	    	 	       
	   ,NULL AS comments;
END
ELSE IF @voutput_format = 'pdf' 
BEGIN
SELECT 
        fac.fac_id
	   ,fac.facility_name
       ,NULL AS action_code
	   ,NULL AS discharge_status
       ,NULL AS last_name  
       ,NULL AS first_name 
       ,NULL AS client_id_number 
	   ,NULL AS [prior_location]
       ,NULL AS [location] 
	   ,NULL AS effective_date
	   ,NULL AS effective_time
	   ,NULL AS [prior_payer]
	   ,NULL AS payer 
	   ,NULL AS unit
	   ,NULL AS created_date
	   ,NULL AS created_time
	   ,NULL AS to_from_location
	   ,NULL AS to_from_type	    	 	       
	   ,NULL AS comments
	   ,NULL AS summary_payer
	   ,NULL AS summary_insurance
	   ,NULL AS summary_action
	   ,NULL AS summary_total
	   ,NULL AS section
FROM #facility f
LEFT JOIN [reporting].[ldl_view_dim_facility] fac
		ON f.fac_id =  fac.fac_id;
END
END
GO

GRANT EXECUTE ON reporting.bdl_sproc_ActionSummary2 TO PUBLIC;

GO


GO

print 'G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.bdl_sproc_ActionSummary2.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.bdl_sproc_ActionSummary2.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.bdl_sproc_Immunizationclient_rawdata.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

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


/*-- ================================================================================= 
-- CORE-32371       : Update reporting.bdl_sproc_ImmunizationClient_rawdata with addition of new columns
--
-- Written By:          Rolly Sanchez, Mike Levine
-- Reviewed By:
--
-- Script Type:         DML
-- Target DB Type:      Client
-- Target ENVIRONMENT:  BOTH
-- 
-- Re-Runable:          YES
--
-- Description of Script : Create stored procedure to retrieve immunization client raw data
--							This SP is called multiple times by enterprise immunization report
--							filtering happened here
--
-- Special Instruction:
--
--	Revision History:
--	Date                User            JIRA          Description
--	2018                Rolly Sanchez   CORE-22599    Initial version for immunization report enterprise reporting
--	2019, February 4    Mike Levine     CORE-32371    Update sproc with addition of new columns
--  2021, October 5     Nooshin Hayeri  CORE-93920    Add 'Notes' column
-- 
-- ================================================================================= */
if exists (select * from sys.procedures where name = 'bdl_sproc_ImmunizationClient_rawdata')
begin
	drop procedure reporting.bdl_sproc_ImmunizationClient_rawdata
end
go

CREATE PROCEDURE reporting.bdl_sproc_ImmunizationClient_rawdata
	  @fac_id varchar(max),
	  @immu_id varchar(300),
	  @immu_status int, 
	  @consent_status varchar(50),
	  @client_status varchar(10),
	  @immu_start_date datetime,
	  @immu_end_date datetime,
	  @group_lvl1 int,
	  @group_lvl2 int,
	  @group_lvl3 int,
	  @group_lvl4 int,
	  @group_lvl5 int,
	  @group_lvl6 int,
	  @groupBy_Fac tinyint,
	  @hrchy_ids varchar(100),
	  @username varchar(254),
	  @client_ids varchar(max) = NULL,
	  @status_code int out,
	  @status_text varchar(3000) out,
	  @debug_me CHAR(1) = 'N'

/****************************************************************************************************  
--SAMPLE EXECUTION SCRIPT  
  
declare @stext varchar(3000), @scode int
exec reporting.bdl_sproc_ImmunizationClient_rawdata
	@debug_me = 'N'
	,  @fac_id = '1,4'
	, @immu_id = '30,2,5'
	, @immu_status = -1 -- 1 -- 0 -- run 3 tests with each of the statuses
--	, @include_wo_immu = 0
	, @consent_status = '1,2,3,6'
	, @client_status = '0'
	, @immu_start_date = '01/01/2006' -- '01/01/2016' -- run 2 tests with each of the dates
	, @immu_end_date = '12/01/2018' --'2/28/2019'
	, @group_lvl1 = 1
	, @group_lvl2 = null
	, @group_lvl3 = null
	, @group_lvl4 = null
	, @group_lvl5 = null
	, @group_lvl6 = null
	, @groupBy_Fac = 0
	, @hrchy_ids = null
	, @username = 'pcc-levinm'
	, @client_ids = '1, 2' or null
	, @status_code = @scode output
	, @status_text = @stext output
	
select @scode, @stext

*****************************************************************************************************/  
AS
BEGIN

SET NOCOUNT ON;

BEGIN TRY

declare @vfac_id varchar(max)
declare @vimmu_id varchar(300)
declare @vimmu_status int
declare @vconsent_status varchar(50)
declare @vclient_status varchar(50)
declare @vimmu_start_date int
declare @vimmu_end_date int
declare @vgroup_lvl1 int
declare @vgroup_lvl2 int
declare @vgroup_lvl3 int
declare @vgroup_lvl4 int
declare @vgroup_lvl5 int
declare @vgroup_lvl6 int
declare @vgroupBy_Fac tinyint
declare @vlvl_id1 int
declare @vlvl_id2 int
declare @vlvl_id3 int
declare @vlvl_id4 int
declare @vlvl_id5 int
declare @vlvl_id6 int
declare @vhrchy_ids varchar(100)
declare @vgrp_lvl int
declare @vusername varchar(254)
declare @vclient_ids varchar(max)
declare @vfac_ids varchar(max)
declare @vseparator char(1) = ','
declare @sars_cov_2_immunization_id int

DECLARE @lvl TABLE (id int IDENTITY, lvl_id int);

-- parameter sniffing
select @vfac_id = @fac_id
	, @vimmu_id = @immu_id
	, @vimmu_status = @immu_status
	, @vconsent_status = @consent_status
	, @vclient_status = @client_status
	, @vimmu_start_date = FORMAT(@immu_start_date,'yyyyMMdd')
	, @vimmu_end_date = FORMAT(@immu_end_date,'yyyyMMdd')
	, @vgroup_lvl1 = @group_lvl1
	, @vgroup_lvl2 = @group_lvl2
	, @vgroup_lvl3 = @group_lvl3
	, @vgroup_lvl4 = @group_lvl4
	, @vgroup_lvl5 = @group_lvl5
	, @vgroup_lvl6 = @group_lvl6
	, @vgroupBy_Fac = @groupBy_Fac
	, @vhrchy_ids = @hrchy_ids
	, @vusername = @username
	, @vclient_ids = @client_ids
	, @status_code = 0
	, @status_text = ''
--   , @vfac_id = @fac_id -- duplicate

SET @sars_cov_2_immunization_id = ISNULL((SELECT std_immunization_id FROM cr_std_immunization WHERE description = 'SARS-COV-2 (COVID-19)' AND system_flag = 'Y' AND deleted = 'N'), -1)


INSERT INTO @lvl
SELECT items FROM dbo.split(@vhrchy_ids, @vseparator);

SELECT  @vgrp_lvl  = ISNULL(MAX(id),0) + 1  FROM @lvl;
SELECT  @vlvl_id1 = lvl_id FROM @lvl WHERE id = 1;
SELECT  @vlvl_id2 = lvl_id FROM @lvl WHERE id = 2;
SELECT  @vlvl_id3 = lvl_id FROM @lvl WHERE id = 3;
SELECT  @vlvl_id4 = lvl_id FROM @lvl WHERE id = 4;
SELECT  @vlvl_id5 = lvl_id FROM @lvl WHERE id = 5;
SELECT  @vlvl_id6 = lvl_id FROM @lvl WHERE id = 6;

if @vgroupBy_Fac = 1
	begin
		set @vgrp_lvl = 7
	end

-- get all the clients the user can access to
DECLARE @accessableClients table(
	client_id int
);

IF @vclient_ids IS NOT NULL
	INSERT INTO @accessableClients
	SELECT * FROM dbo.Split(@vclient_ids, @vseparator);

-- get all facility that user has access to
Select  @vfac_ids = fac_id	From  dbo.fn_prp_get_facility_access_list_delim(@vfac_id,@vusername)

-- split all parameters
; with split_fac
as (
	select items as fac_id from dbo.split(@vfac_id,@vseparator)
	)
, fac_withuser_access
as (
	select items as fac_id from dbo.split(@vfac_ids,@vseparator)
	)
, split_immunization
as (
	select items as std_immunization_id from dbo.split(@vimmu_id,@vseparator)
	)
, 	split_consent_status
 as (
	select items as consent_code_id from dbo.split(@vconsent_status,@vseparator)
	)
--build group level base on user selection
-- limit by selection and user access
, group_level
as (
	select * from reporting.ldl_fn_dim_FacilityCode (@vgroup_lvl1,@vgroup_lvl2,@vgroup_lvl3,@vgroup_lvl4,@vgroup_lvl5,@vgroup_lvl6) fac_grp
		where exists (select 1 from split_fac f inner join fac_withuser_access fa on f.fac_id = fa.fac_id where f.fac_id = fac_grp.fac_id)
	)
-- flag administered immunization/ distinct record per immunization
, filtered_data
as (
select gl.col1
	 , gl.id1
	 , case when @vgroup_lvl2 is null then null else gl.col2 end col2
	 , case when @vgroup_lvl2 is null then null else gl.id2  end id2
	 , case when @vgroup_lvl3 is null then null else gl.col3 end col3
	 , case when @vgroup_lvl3 is null then null else gl.id3  end id3
	 , case when @vgroup_lvl4 is null then null else gl.col4 end col4
	 , case when @vgroup_lvl4 is null then null else gl.id4  end id4
	 , case when @vgroup_lvl5 is null then null else gl.col5 end col5
	 , case when @vgroup_lvl5 is null then null else gl.id5  end id5
	 , case when @vgroup_lvl6 is null then null else gl.col6 end col6
	 , case when @vgroup_lvl6 is null then null else gl.id6  end id6
	 , fac.facility_name
	 , std_imm.description as immunization_description
	 , bedloc.unit_desc
	 , bedloc.bed_desc
	 , bedloc.floor_desc
	 , bedloc.room_desc
	 , pfi.client_id
	 , fac.fac_id
	 , pfi.std_immunization_id
	 , cl.last_name
	 , cl.first_name
	 , cl.client_id_number
	 , cl.sex
	 , case when cl.discharge_date is null then '0' else '1' end as client_status
	 , cl.admission_date
	 , cl.discharge_date
	 , consent.description as consent_status
	 , pfi.consent_by
	 , pfi.consent_date

-- ml: Change administered_id to be sourced from reporting.ldl_view_dim_ResultStatusCode
--	 , case when pfi.administered_id = 1 then 'Administered' else 'Not Administered' end immunization_status
	 , case when result_sc_adm.result_status = 1 then 'Administered' else 'Not Administered' end immunization_status

	 , pfi.immun_date
	 , sec_user.long_username as administered_by
	 , roa.description as route_of_admin
	 , pfi.dose_amount
	 , uom.description uom
	 , result_sc.description as result_description
	 , reason_sc.description as reason
	 , bodyloc.item_description as body_location

-- ml: Change administered to administered_id in all references and to be sourced from reporting.ldl_view_dim_ResultStatusCode
--	 , pfi.administered_id
	 , result_sc_adm.result_status as administered_id
	 , manufacturer.manufacturer_name
	 , CASE
			WHEN pfi.std_immunization_id = 5 THEN '(Step ' + CAST(pfi.step_id AS char(1)) + ')'
		    WHEN pfi.std_immunization_id = @sars_cov_2_immunization_id THEN '(Dose ' + CAST(pfi.step_id AS char(1)) + ')'
			ELSE ''
		END AS step
     , pfi.lot_number
     , cvx.code AS cvx_code
     , cvx.short_description AS cvx_short_description
     , pfi.notes

	 , row_number() over (partition by pfi.fac_id, pfi.std_immunization_id, pfi.client_id order by pfi.administered_id desc) rnum
from reporting.ldl_view_fact_Immunization pfi
	inner join reporting.ldl_view_dim_Immunization std_imm
		on pfi.std_immunization_id = std_imm.std_immunization_id
	inner join reporting.ldl_view_dim_Facility fac
		on pfi.fac_id = fac.fac_id
	inner join reporting.ldl_view_dim_Client cl
		on cl.client_id = pfi.client_id
	inner join reporting.ldl_view_dim_ConsentStatusCode consent
		on pfi.consent_code_id = consent.consent_code_id
	inner join reporting.ldl_view_dim_UnitOfMeasure uom
		on pfi.unit_of_measure_id = uom.uom_id

-- ml: add second join to ResultStatusCode for administered_id
	inner join reporting.ldl_view_dim_ResultStatusCode result_sc_adm
		on pfi.administered_id = result_sc_adm.result_code_id

	inner join reporting.ldl_view_dim_ResultStatusCode result_sc
		on pfi.result_code_id = result_sc.result_code_id
	inner join reporting.ldl_view_dim_ReasonStatusCode reason_sc
		on pfi.reason_code_id = reason_sc.reason_code_id
	inner join reporting.ldl_view_dim_RouteOfAdmin roa
		on pfi.route_of_admin_id  = roa.route_of_admin_id
	inner join split_fac sfac
		on sfac.fac_id = fac.fac_id
	left join group_level gl
		on gl.fac_id = fac.fac_id
	inner join split_immunization sstd_imm
		on std_imm.std_immunization_id = sstd_imm.std_immunization_id
	inner join split_consent_status sconsent
		on sconsent.consent_code_id = consent.consent_code_id
	INNER JOIN reporting.ldl_view_dim_Manufacturer manufacturer
		ON pfi.manufacturer_id = manufacturer.manufacturer_id

	left outer join reporting.ldl_view_dim_User sec_user
		on sec_user.userid = pfi.administered_by_id
	left outer join reporting.ldl_view_dim_BodyLocation bodyloc
		on pfi.body_location_id = bodyloc.body_location_id
	left outer join reporting.ldl_view_dim_BedLocation bedloc
		on bedloc.bed_id = pfi.current_bed_id
	LEFT JOIN reporting.ldl_view_dim_CvxCode cvx
	    on pfi.cvx_code_id = cvx.cvx_code_id

-- ml: Change administered_id to be sourced from reporting.ldl_view_dim_ResultStatusCode
-- where (@vimmu_status = -1 or pfi.administered = @vimmu_status)
where     (@vimmu_status = -1 or result_sc_adm.result_status = @vimmu_status)
      and (@vclient_status = '-1' or (case when cl.discharge_date is null then '0' else '1' end) = @vclient_status)
      and (
            (pfi.immun_date_id>= @vimmu_start_date and pfi.immun_date_id <= @vimmu_end_date)
              or
            (pfi.immun_date_id = 19000101)
          )
	and (@vlvl_id1 IS NULL OR gl.id1 = @vlvl_id1)
	and (@vlvl_id2 IS NULL OR gl.id2 = @vlvl_id2)
	and (@vlvl_id3 IS NULL OR gl.id3 = @vlvl_id3)
	and (@vlvl_id4 IS NULL OR gl.id4 = @vlvl_id4)
	and (@vlvl_id5 IS NULL OR gl.id5 = @vlvl_id5)
	and (@vlvl_id6 IS NULL OR gl.id6 = @vlvl_id6)
	and (@vclient_ids IS NULL OR cl.client_id IN (SELECT client_id FROM @accessableClients))
)
, outrange
as (select pfi.client_id,  pfi.std_immunization_id, pfi.fac_id, max(pfi.current_bed_id) current_bed_id -- only 1 current bed id per client
		from reporting.ldl_view_fact_Immunization pfi
			inner join split_immunization sstd_imm
				on pfi.std_immunization_id = sstd_imm.std_immunization_id
			inner join split_fac sfac
				on sfac.fac_id = pfi.fac_id
			inner join split_consent_status sconsent
				on sconsent.consent_code_id = pfi.consent_code_id
			inner join reporting.ldl_view_dim_Client cl
				on cl.client_id = pfi.client_id

-- ml: Add join to ResultStatusCode for administered_id
			inner join reporting.ldl_view_dim_ResultStatusCode result_sc_adm
				on pfi.administered_id = result_sc_adm.result_code_id

-- ml: Change administered_id to be sourced from reporting.ldl_view_dim_ResultStatusCode
--	where pfi.administered_id = 1
	where result_sc_adm.result_status = 1
			and (pfi.immun_date_id not between @vimmu_start_date and @vimmu_end_date )
			and pfi.immun_date_id <> 19000101
			and (@vclient_status = '-1'
				or ((case when cl.discharge_date is null then '0' else '1' end) = @vclient_status)
				)
 			and (@vimmu_status = -1 or  @vimmu_status = 0)
			and not exists (select 1 from reporting.ldl_view_fact_Immunization vfi
									where vfi.client_id = pfi.client_id and vfi.std_immunization_id = pfi.std_immunization_id
										and vfi.fac_id = pfi.fac_id
										and vfi.immun_date_id between @vimmu_start_date and @vimmu_end_date
							)
	group by pfi.client_id,  pfi.std_immunization_id, pfi.fac_id
)
-- administered but outside the date range
, administered_outside_range
as (
select   gl.col1
	 , gl.id1
	 , case when @vgroup_lvl2 is null then null else gl.col2 end col2
	 , case when @vgroup_lvl2 is null then null else gl.id2  end id2
	 , case when @vgroup_lvl3 is null then null else gl.col3 end col3
	 , case when @vgroup_lvl3 is null then null else gl.id3  end id3
	 , case when @vgroup_lvl4 is null then null else gl.col4 end col4
	 , case when @vgroup_lvl4 is null then null else gl.id4  end id4
	 , case when @vgroup_lvl5 is null then null else gl.col5 end col5
	 , case when @vgroup_lvl5 is null then null else gl.id5  end id5
	 , case when @vgroup_lvl6 is null then null else gl.col6 end col6
	 , case when @vgroup_lvl6 is null then null else gl.id6  end id6
	 , fac.facility_name
	 , std_imm.description as immunization_description
	 , bedloc.unit_desc
	 , bedloc.bed_desc
	 , bedloc.floor_desc
	 , bedloc.room_desc
	 , pfi.client_id
	 , fac.fac_id
	 , pfi.std_immunization_id
	 , cl.last_name
	 , cl.first_name
	 , cl.client_id_number
	 , cl.sex
	 , case when cl.discharge_date is null then '0' else '1' end as client_status
	 , cl.admission_date
	 , cl.discharge_date
	 , null as consent_status
	 , null as consent_by
	 , null as consent_date
	 , 'Not Administered' as immunization_status
	 , null as immun_date
	 , null as administered_by
	 , null as route_of_admin
	 , null as dose_amount
	 , null as uom
	 , null as result_description
	 , null as reason
	 , null as body_location
	 , '0' as administered_id
	 , null as manufacturer_name
	 , null as step
     , null as lot_number
     , null as cvx_code
     , null as cvx_short_description
     , null as notes
	 ,1 rnum
	from outrange pfi
		inner join reporting.ldl_view_dim_Immunization std_imm
			on pfi.std_immunization_id = std_imm.std_immunization_id
		inner join reporting.ldl_view_dim_Facility fac
			on pfi.fac_id = fac.fac_id
		inner join reporting.ldl_view_dim_Client cl
			on cl.client_id = pfi.client_id
		left join group_level gl
			on gl.fac_id = fac.fac_id
		left outer join reporting.ldl_view_dim_BedLocation bedloc
			on bedloc.bed_id = pfi.current_bed_id
where
	 (@vlvl_id1 IS NULL OR gl.id1 = @vlvl_id1)
	and (@vlvl_id2 IS NULL OR gl.id2 = @vlvl_id2)
	and (@vlvl_id3 IS NULL OR gl.id3 = @vlvl_id3)
	and (@vlvl_id4 IS NULL OR gl.id4 = @vlvl_id4)
	and (@vlvl_id5 IS NULL OR gl.id5 = @vlvl_id5)
	and (@vlvl_id6 IS NULL OR gl.id6 = @vlvl_id6)
	and (@vclient_ids IS NULL OR cl.client_id IN (SELECT client_id FROM @accessableClients))
	)
	select col1, id1
	 , col2, id2
	 , col3, id3
	 , col4, id4
	 , col5, id5
	 , col6, id6
	 , facility_name
	 , immunization_description
	 , unit_desc
	 , bed_desc
	 , floor_desc
	 , room_desc
	 , client_id
	 , fac_id
	 , std_immunization_id
	 , last_name
	 , first_name
	 , client_id_number
	 , sex
	 , client_status
	 , admission_date
	 , discharge_date
	 , consent_status
	 , consent_by
	 , consent_date
	 , immunization_status
	 , immun_date
	 , administered_by
	 , route_of_admin
	 , dose_amount
	 , uom
	 , result_description
	 , reason
	 , body_location
	 , administered_id
	 , manufacturer_name
	 , step
	 , lot_number
	 , cvx_code
	 , cvx_short_description
     , notes
	 , rnum
	 , 0 as status_code
	 , '' as status_text
 from filtered_data

	union all

	select col1, id1
	 , col2, id2
	 , col3, id3
	 , col4, id4
	 , col5, id5
	 , col6, id6
	 , facility_name
	 , immunization_description
	 , unit_desc
	 , bed_desc
	 , floor_desc
	 , room_desc
	 , client_id
	 , fac_id
	 , std_immunization_id
	 , last_name
	 , first_name
	 , client_id_number
	 , sex
	 , client_status
	 , admission_date
	 , discharge_date
	 , consent_status
	 , consent_by
	 , consent_date
	 , immunization_status
	 , immun_date
	 , administered_by
	 , route_of_admin
	 , dose_amount
	 , uom
	 , result_description
	 , reason
	 , body_location
	 , administered_id
	 , manufacturer_name
	 , step
	 , lot_number
	 , cvx_code
     , cvx_short_description
     , notes
	 , rnum
	 , 0 as status_code
	 , '' as status_text
 from administered_outside_range

END TRY

BEGIN CATCH

 SELECT @status_text =
                   Rtrim(LEFT('Stored Procedure failed with Error Code : '
                              + Cast(Error_number() AS VARCHAR(10))
                              + ', Line Number : '
                              + Cast(Error_line() AS VARCHAR(10))
                              + ', Description : ' + Error_message(), 3000)
                   )
		, @status_code = 1

if @debug_me = 'Y' print @status_text
	select null as col1
	 , null as id1
	 , null as col2
	 , null as id2
	 , null as col3
	 , null as id3
	 , null as col4
	 , null as id4
	 , null as col5
	 , null as id5
	 , null as col6
	 , null as id6
	 , null as facility_name
	 , null as immunization_description
	 , null as unit_desc
	 , null as bed_desc
	 , null as floor_desc
	 , null as room_desc
	 , null as client_id
	 , null as fac_id
	 , null as std_immunization_id
	 , null as last_name
	 , null as first_name
	 , null as client_id_number
	 , null as sex
	 , null as client_status
	 , null as admission_date
	 , null as discharge_date
	 , null as consent_status
	 , null as consent_by
	 , null as consent_date
	 , null as immunization_status
	 , null as immun_date
	 , null as administered_by
	 , null as route_of_admin
	 , null as dose_amount
	 , null as uom
	 , null as result_description
	 , null as reason
	 , null as body_location
	 , null as administered_id
	 , null as manufacturer_name
	 , null as step
	 , null as lot_number
     , null as cvx_code
     , null as cvx_short_description
     , null as notes
	 , null as rnum
	 , @status_code as status_code
	 , @status_text as status_text

END CATCH

RETURN  
END
go

grant execute on reporting.bdl_sproc_ImmunizationClient_rawdata to public
go


GO

print 'G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.bdl_sproc_Immunizationclient_rawdata.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.bdl_sproc_Immunizationclient_rawdata.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.bdl_sproc_ImmunizationclientDetail_Facility.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

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


/*-- ================================================================================= 
-- CORE-32393:          Update reporting.bdl_sproc_ImmunizationclienDetail_Facility  
--
-- Written By:          Rolly Sanchez, Mike Levine
-- Reviewed By:         
-- 
-- Script Type:         DDL
-- Target DB Type:      Client
-- Target ENVIRONMENT:  BOTH  
-- 
-- Re-Runable:          YES 
-- 
-- Description of Script : Create stored procedure to retrieve immunization datail and summary for CSV output
-- 
-- Special Instruction: depends on  reporting.bdl_sproc_ImmunizationclienDetail_Facility for data source

-- Revision History:
-- October 2, 2018		 R. Sanchez		CORE-22599	Initial creation
-- February 5, 2019		 Mike Levine	CORE-32393  Update reporting.bdl_sproc_ImmunizationclienDetail_Facility  

-- ================================================================================= */
if exists (select * from sys.procedures where name = 'bdl_sproc_ImmunizationClientDetail_Facility')
begin
	drop procedure reporting.bdl_sproc_ImmunizationClientDetail_Facility
end
go

CREATE PROCEDURE reporting.bdl_sproc_ImmunizationClientDetail_Facility
	  @fac_id varchar(max),
	  @immu_id varchar(300),
	  @immu_status int, 
	  @consent_status varchar(50),
	  @client_status varchar(10),
	  @immu_start_date datetime,
	  @immu_end_date datetime,
	  @group_lvl1 int,
	  @group_lvl2 int,
	  @group_lvl3 int,
	  @group_lvl4 int,
	  @group_lvl5 int,
	  @group_lvl6 int,
	  @groupBy_Fac tinyint,
	  @hrchy_ids varchar(100),
	  @offset int = 1,
	  @limit int = 100,
	  @username varchar(254),
	  @status_code int out,
	  @status_text varchar(3000) out,
	  @debug_me CHAR(1) = 'N'
  
/****************************************************************************************************  
--SAMPLE EXECUTION SCRIPT  
  
declare @stext varchar(3000), @scode int
exec reporting.bdl_sproc_ImmunizationClientDetail_Facility 
	  @debug_me = 'N'
	, @fac_id = '-1'
	, @immu_id = '1,2,3,4,5,6,7,8,9,30,60'
	, @immu_status = -1
--	, @include_wo_immu = 0
	, @consent_status = '1,2'
	, @client_status = '0'
	, @immu_start_date = '01/01/2006'
	, @immu_end_date = '12/01/2018'
	, @group_lvl1 = 1
	, @group_lvl2 = null
	, @group_lvl3 = null
	, @group_lvl4 = null
	, @group_lvl5 = null
	, @group_lvl6 = null
	, @groupBy_Fac = 0
	, @hrchy_ids = null
	, @offset = 0
	, @limit = 100
	, @username = 'pcc-levinm'
	, @status_code = @scode output
	, @status_text = @stext output

select @scode, @stext
*****************************************************************************************************/  
AS
BEGIN

SET NOCOUNT ON;

BEGIN TRY

declare @vfac_id varchar(max)
declare @vimmu_id varchar(300)
declare @vimmu_status int
declare @vconsent_status varchar(50)
declare @vclient_status varchar(50)
declare @vimmu_start_date datetime
declare @vimmu_end_date datetime
declare @vgroup_lvl1 int
declare @vgroup_lvl2 int
declare @vgroup_lvl3 int
declare @vgroup_lvl4 int
declare @vgroup_lvl5 int
declare @vgroup_lvl6 int
declare @vgroupBy_Fac tinyint
declare @vlvl_id1 int
declare @vlvl_id2 int
declare @vlvl_id3 int
declare @vlvl_id4 int
declare @vlvl_id5 int
declare @vlvl_id6 int
declare @vhrchy_ids varchar(100)
declare @vgrp_lvl int
declare @voffset int
declare @vlimit int
declare @vusername varchar(254)
Declare @precision tinyint = 2
declare @stat_code int = 0
declare @stat_text varchar(3000) = ''

declare @vseparator char(1) = ','

Create Table #enterprise_immunization_rawdata 
													(
														col1 varchar(254), id1 int, col2 varchar(254), id2 int, col3 varchar(254), id3 int, col4 varchar(254), id4 int, col5 varchar(254), id5 int, col6 varchar(254), id6 int
												  , facility_name varchar(100), immunization_description varchar(100), unit_desc varchar(100), bed_desc varchar(100),floor_desc varchar(100),room_desc varchar(100)
												  , client_id int, fac_id int, std_immunization_id int, last_name varchar(200), first_name varchar(200), client_id_number varchar(100), sex char(1)
												  , client_status bit, admission_date datetime, discharge_date datetime, consent_status varchar(100), consent_by varchar(200), consent_date datetime, immunization_status varchar(100)
												  , immun_date datetime, administered_by varchar(200), route_of_admin varchar(100), dose_amount decimal(15,8), uom varchar(100), result_description varchar(100)
												  , reason varchar(200), body_location varchar(254), administered_id int, manufacturer_name varchar(50), step varchar(15)
												  , lot_number varchar(10), cvx_code int, cvx_short_description varchar(200), notes varchar(150), rnum int, status_code int, status_text varchar(3000)
													 );

-- parameter sniffing
select @vfac_id = @fac_id
	, @vimmu_id = @immu_id
	, @vimmu_status = @immu_status
	, @vconsent_status = @consent_status
	, @vclient_status = @client_status
	, @vimmu_start_date = @immu_start_date
	, @vimmu_end_date = @immu_end_date
	, @vgroup_lvl1 = @group_lvl1
	, @vgroup_lvl2 = @group_lvl2
	, @vgroup_lvl3 = @group_lvl3
	, @vgroup_lvl4 = @group_lvl4
	, @vgroup_lvl5 = @group_lvl5
	, @vgroup_lvl6 = @group_lvl6
	, @vgroupBy_Fac = @groupBy_Fac
	, @vhrchy_ids = @hrchy_ids
	, @vusername = @username
	, @voffset = @offset
	, @vlimit = @limit

	insert into #enterprise_immunization_rawdata
	exec reporting.bdl_sproc_ImmunizationClient_rawdata
    @fac_id = @vfac_id,
	  @immu_id = @vimmu_id,
	  @immu_status = @vimmu_status, 
	  @consent_status = @vconsent_status,
	  @client_status = @vclient_status,
	  @immu_start_date = @vimmu_start_date,
	  @immu_end_date = @vimmu_end_date,
	  @group_lvl1 = @vgroup_lvl1,
	  @group_lvl2 = @vgroup_lvl2,
	  @group_lvl3 = @vgroup_lvl3,
	  @group_lvl4 = @vgroup_lvl4,
	  @group_lvl5 = @vgroup_lvl5,
	  @group_lvl6 = @vgroup_lvl6,
	  @groupBy_Fac  = @vgroupBy_Fac,
	  @hrchy_ids = @vhrchy_ids,
	  @username = @vusername,
	  @status_code = @stat_code,
	  @status_text = @stat_text,
	  @debug_me  = @debug_me

if @debug_me = 'Y' select 'raw_data' as raw_data, * from #enterprise_immunization_rawdata

;with filtered_data
as (select * from #enterprise_immunization_rawdata
	where rnum = 1
	)
, ttl_unit
	as (select col1, id1
			 , col2, id2 
			 , col3, id3 
			 , col4, id4 
			 , col5, id5 
			 , col6, id6 
			 , fac_id
			 , facility_name
			 , unit_desc
			, null as immunization_description
			, count(*) ttl_client
			, sum(administered_id) as ttl_administered
			, sum(case when administered_id = 0 then 1 else 0 end) as ttl_notadministered
		from filtered_data
		group by col1,  id1, col2, id2 , col3, id3, col4, id4, col5, id5, col6, id6, fac_id, facility_name, unit_desc
		)
, ttl_administered
	as (select col1, id1
			 , col2, id2 
			 , col3, id3 
			 , col4, id4 
			 , col5, id5 
			 , col6, id6 
			 , fac_id
			 , facility_name
			 , unit_desc
			 , immunization_description
			, count(*) ttl_client
			, sum(administered_id) as ttl_administered
			, sum(case when administered_id = 0 then 1 else 0 end) as ttl_notadministered
		from filtered_data
		group by col1,  id1, col2, id2 , col3, id3, col4, id4, col5, id5, col6, id6 , fac_id, facility_name, unit_desc, immunization_description
		)
	   select *
			 , round(convert(float,ttl_administered)/ convert(float,ttl_client) * 100, @precision) as percent_administered
			 , round(convert(float,ttl_notadministered)/ convert(float,ttl_client) * 100, @precision) as percent_notadministered
			 , null as client_id
			 , null as std_immunization_id
			 , null as resident_name
			 , null as consent_status
			 , null as consent_by
			 , null as consent_date
			 , null as immunization_status
			 , null as immun_date
			 , null as administered_by
			 , null as route_of_admin
			 , null as amount_administered_id
			 , null as result_description
			 , null as reason
			 , null as body_location
			 , null as administered
			 , null as rnum
			 , convert(bit,1)    as rollup_flag 
	  from ttl_unit

	 union all

	 select *
			 , round(convert(float,ttl_administered)/ convert(float,ttl_client) * 100, @precision) as percent_administered
			 , round(convert(float,ttl_notadministered)/ convert(float,ttl_client) * 100, @precision) as percent_notadministered
			 , null as client_id
			 , null as std_immunization_id
			 , null as resident_name
			 , null as consent_status
			 , null as consent_by
			 , null as consent_date
			 , null as immunization_status
			 , null as immun_date
			 , null as administered_by
			 , null as route_of_admin
			 , null as amount_administered
			 , null as result_description
			 , null as reason
			 , null as body_location
			 , null as administered
			 , null as rnum
			 , convert(bit,1)    as rollup_flag 
	  from ttl_administered
	  
	  union all

	  select  col1, id1
			, col2, id2
			, col3, id3
			, col4, id4
			, col5, id5
			, col6, id6
			, fac_id
			, facility_name,unit_desc, immunization_description
			, null as ttl_client
			, null as ttl_administered
			, null as ttl_notadministered
			, null as percent_administered
			, null as percent_notadministered
			, client_id
			, std_immunization_id
			, last_name + ', ' + first_name + ' (' +client_id_number + ')'  as resident_name
			, consent_status
			, consent_by
			, consent_date
			, immunization_status
			, immun_date
			, administered_by
			, route_of_admin
			, convert(varchar(20),dose_amount) + ' ' + uom as amount_administered
			, result_description
			, reason
			, body_location
			, case when administered_id = '0' then 'No' else 'Yes' end as administered
			, rnum
			, convert(bit,null ) as rollup_flag 
	   from #enterprise_immunization_rawdata
		 order by col1, col2, col3, col4, col5, col6, facility_name,unit_desc, immunization_description
								, ttl_client desc, ttl_administered desc , ttl_notadministered desc
								, resident_name	, immun_date desc, consent_date desc
			offset @voffset rows
			fetch next @vlimit rows only
END TRY

BEGIN CATCH

 SELECT @status_code = 1, @status_text = 
                   Rtrim(LEFT('Stored Procedure failed with Error Code : ' 
                              + Cast(Error_number() AS VARCHAR(10)) 
                              + ', Line Number : ' 
                              + Cast(Error_line() AS VARCHAR(10)) 
                              + ', Description : ' + Error_message(), 3000) 
                   ) 


if @debug_me = 'Y' print @status_text

	select   null as  col1
			,null as  id1
			,null as  col2
			,null as  id2
			,null as  col3
			,null as  id3
			,null as  col4
			,null as  id4
			,null as  col5
			,null as  id5
			,null as  col6
			,null as  id6
			,null as  fac_id
			,null as  facility_name
			,null as  unit_desc
			,null as  immunization_description
			,null as  ttl_client
			,null as  ttl_administered
			,null as  ttl_notadministered
			,null as  percent_administered
			,null as  percent_notadministered
			,null as  client_id
			,null as  std_immunization_id
			,null as  resident_name
			,null as  consent_status
			,null as  consent_by
			,null as  consent_date
			,null as  immunization_status
			,null as  immun_date
			,null as  administered_by
			,null as  route_of_admin
			,null as  amount_administered
			,null as  result_description
			,null as  reason
			,null as  body_location
			,null as  administered
			,null as  rnum
			, NULL as rollup_flag
END CATCH

RETURN  
END
go

grant execute on reporting.bdl_sproc_ImmunizationClientDetail_Facility to public
go


GO

print 'G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.bdl_sproc_ImmunizationclientDetail_Facility.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.bdl_sproc_ImmunizationclientDetail_Facility.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.bdl_sproc_ImmunizationclientSummary.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

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


/*-- ================================================================================= 
-- CORE-33155          :   Update sproc for Immunization rate report
--
-- Written By:          Rolly Sanchez, Mike Levine
-- Reviewed By:
--
-- Script Type:         DDL
-- Target DB Type:      Client
-- Target ENVIRONMENT:  BOTH
-- 
-- Re-Runable:          YES 
-- 
-- Description of Script : Create stored procedure to retrieve immunization client summary 
-- 
-- Special Instruction: 
-- 
--	Revision History:
--	Date                User            JIRA          Description
--	2018                Rolly Sanchez   CORE-22599    Initial version for immunization report enterprise reporting
--	2019, February 5    Mike Levine     CORE-32371    Update sproc as part of Immunization rate report changes

-- ================================================================================= */
if exists (select * from sys.procedures where name = 'bdl_sproc_ImmunizationClientSummary')
begin
	drop procedure reporting.bdl_sproc_ImmunizationClientSummary
end
go

CREATE PROCEDURE reporting.bdl_sproc_ImmunizationClientSummary
    @fac_id varchar(max),
	  @immu_id varchar(300),
	  @immu_status int, 
	  @consent_status varchar(50),
	  @client_status varchar(10),
	  @immu_start_date datetime,
	  @immu_end_date datetime,
	  @group_lvl1 int,
	  @group_lvl2 int,
	  @group_lvl3 int,
	  @group_lvl4 int,
	  @group_lvl5 int,
	  @group_lvl6 int,
	  @groupBy_Fac tinyint,
	  @hrchy_ids varchar(100),
	  @username  varchar(254),
	  @status_code int output,
	  @status_text varchar(3000) output,
	  @debug_me CHAR(1) = 'N'

  
/****************************************************************************************************  
--SAMPLE EXECUTION SCRIPT  
  
declare @stext varchar(3000), @scode int

exec [reporting].[bdl_sproc_ImmunizationClientSummary] 
	@debug_me = 'N'
	, @fac_id = '1,4'
	, @immu_id = '30,2'
	, @immu_status = -1
	, @consent_status = '1,2'
	, @client_status = '0'
	, @immu_start_date = '01/01/2006'
	, @immu_end_date = '12/01/2018'
	, @group_lvl1 = 1
	, @group_lvl2 = null
	, @group_lvl3 = null
	, @group_lvl4 = null
	, @group_lvl5 = null
	, @group_lvl6 = null
	, @groupBy_Fac = 0
	, @hrchy_ids = null
	, @username = 'levinm'
	, @status_code = @scode output
	, @status_text = @stext output

select @scode, @stext
*****************************************************************************************************/  
AS
BEGIN

SET NOCOUNT ON;

BEGIN TRY

declare @vfac_id varchar(max)
declare @vimmu_id varchar(300)
declare @vimmu_status int
declare @vconsent_status varchar(50)
declare @vclient_status varchar(50)
declare @vimmu_start_date datetime
declare @vimmu_end_date datetime
declare @vgroup_lvl1 int
declare @vgroup_lvl2 int
declare @vgroup_lvl3 int
declare @vgroup_lvl4 int
declare @vgroup_lvl5 int
declare @vgroup_lvl6 int
declare @vgroupBy_Fac tinyint
declare @vlvl_id1 int
declare @vlvl_id2 int
declare @vlvl_id3 int
declare @vlvl_id4 int
declare @vlvl_id5 int
declare @vlvl_id6 int
declare @vhrchy_ids varchar(100)
declare @vgrp_lvl int
declare @vusername varchar(254)
Declare @precision tinyint = 2
declare @stat_code int = 0
declare @stat_text varchar(3000) = ''

declare @vseparator char(1) = ','

-- parameter sniffing
select @vfac_id = @fac_id
	, @vimmu_id = @immu_id
	, @vimmu_status = @immu_status
	, @vconsent_status = @consent_status
	, @vclient_status = @client_status
	, @vimmu_start_date = @immu_start_date
	, @vimmu_end_date =  @immu_end_date
	, @vgroup_lvl1 = @group_lvl1
	, @vgroup_lvl2 = @group_lvl2
	, @vgroup_lvl3 = @group_lvl3
	, @vgroup_lvl4 = @group_lvl4
	, @vgroup_lvl5 = @group_lvl5
	, @vgroup_lvl6 = @group_lvl6
	, @vgroupBy_Fac = @groupBy_Fac
	, @vhrchy_ids = @hrchy_ids
	, @vusername = @username
	
DECLARE @lvl TABLE (id int IDENTITY, lvl_id int);

Create Table #enterprise_immunization_rawdata (col1 varchar(254), id1 int, col2 varchar(254), id2 int, col3 varchar(254), id3 int, col4 varchar(254), id4 int, col5 varchar(254), id5 int, col6 varchar(254), id6 int
												  , facility_name varchar(100), immunization_description varchar(100), unit_desc varchar(100), bed_desc varchar(100),floor_desc varchar(100),room_desc varchar(100)
												  , client_id int, fac_id int, std_immunization_id int, last_name varchar(200), first_name varchar(200), client_id_number varchar(100), sex char(1)
												  ,client_status bit, admission_date datetime, discharge_date datetime, consent_status varchar(100), consent_by varchar(200), consent_date datetime, immunization_status varchar(100)
												  , immun_date datetime, administered_by varchar(200), route_of_admin varchar(100), dose_amount decimal(15,8), uom varchar(100), result_description varchar(100)
												  , reason varchar(200), body_location varchar(254), administered_id int, manufacturer_name varchar(50), step varchar(15)
												  , lot_number varchar(10), cvx_code int, cvx_short_description varchar(200), notes varchar(150), rnum int, status_code int, status_text varchar(3000) );

INSERT INTO @lvl
SELECT items FROM dbo.split(@vhrchy_ids, @vseparator);

SELECT  @vgrp_lvl  = ISNULL(MAX(id),0) + 1  FROM @lvl;
SELECT  @vlvl_id1 = lvl_id FROM @lvl WHERE id = 1;
SELECT  @vlvl_id2 = lvl_id FROM @lvl WHERE id = 2;
SELECT  @vlvl_id3 = lvl_id FROM @lvl WHERE id = 3;
SELECT  @vlvl_id4 = lvl_id FROM @lvl WHERE id = 4;
SELECT  @vlvl_id5 = lvl_id FROM @lvl WHERE id = 5;
SELECT  @vlvl_id6 = lvl_id FROM @lvl WHERE id = 6;

select @vgroup_lvl2 = IIF(@vgrp_lvl < 2, null, @vgroup_lvl2) 
, @vgroup_lvl3 = IIF(@vgrp_lvl < 3, null, @vgroup_lvl3) 
, @vgroup_lvl4 = IIF(@vgrp_lvl < 4, null, @vgroup_lvl4) 
, @vgroup_lvl5 = IIF(@vgrp_lvl < 5, null, @vgroup_lvl5) 
, @vgroup_lvl6 = IIF(@vgrp_lvl < 6, null, @vgroup_lvl6) 

	insert into #enterprise_immunization_rawdata
	exec reporting.bdl_sproc_ImmunizationClient_rawdata
    @fac_id = @vfac_id,
	  @immu_id = @vimmu_id,
	  @immu_status = @vimmu_status, 
	  @consent_status = @vconsent_status,
	  @client_status = @vclient_status,
	  @immu_start_date = @vimmu_start_date,
	  @immu_end_date = @vimmu_end_date,
	  @group_lvl1 = @vgroup_lvl1,
	  @group_lvl2 = @vgroup_lvl2,
	  @group_lvl3 = @vgroup_lvl3,
	  @group_lvl4 = @vgroup_lvl4,
	  @group_lvl5 = @vgroup_lvl5,
	  @group_lvl6 = @vgroup_lvl6,
	  @groupBy_Fac  = @vgroupBy_Fac,
	  @hrchy_ids = @vhrchy_ids,
	  @username = @vusername,
	  @status_code = @stat_code out,
	  @status_text = @stat_text out,
	  @debug_me  = @debug_me

if @debug_me = 'Y' select 'raw_data' as raw_data, * from #enterprise_immunization_rawdata

if @vgroupBy_Fac = 1
	begin 
		set @vgrp_lvl = 7
	end

;with 
 filtered_data
as (select * from #enterprise_immunization_rawdata
	where rnum = 1
	)
-- calculate totals
, sub_totals
as ( select id1, col1, id2, col2, id3, col3, id4, col4, id5, col5, id6, col6
	, (case when @vgrp_lvl < 7 then 'Unspecified' else facility_name end) as facility_name
	, (case when @vgrp_lvl < 7 then -1 else fac_id end) as  fac_id
	, count(*) ttl_client, sum(administered_id) as ttl_administered, sum((case when administered_id = 0 then 1 else 0 end)) as ttl_notadministered
	from filtered_data
	group by id1, col1, id2, col2, id3, col3, id4, col4, id5, col5, id6, col6
	, (case when @vgrp_lvl < 7 then 'Unspecified' else facility_name end) 
	, (case when @vgrp_lvl < 7 then -1 else fac_id end) 
	)
-- returning final result
select ttl.col1
	, ttl.id1
	, ttl.col2
	, ttl.id2
	, ttl.col3
	, ttl.id3
	, ttl.col4
	, ttl.id4
	, ttl.col5
	, ttl.id5 
	, ttl.col6
	, ttl.id6 
	, case when ttl.fac_id = -1 then null else  ttl.fac_id end fac_id
	, case when ttl.facility_name = 'Unspecified' then null else ttl.facility_name end as facility_name
	, null as unit_desc
	, null as immunization_description
	, ttl.ttl_client
	, isnull(ttl.ttl_administered,0) as ttl_administered
	, isnull(ttl.ttl_notadministered,0) as ttl_notadministered
	, round(convert(float,ttl_administered)/ convert(float,ttl_client) * 100, @precision) as percent_administered
	, round(convert(float,ttl_notadministered)/ convert(float,ttl_client) * 100, @precision) as percent_notadministered
	from sub_totals ttl
	order by ttl.col1
		, ttl.col2
		, ttl.col3
		, ttl.col4
		, ttl.col5
		, ttl.col6
		, ttl.facility_name
END TRY

BEGIN CATCH

 SELECT @status_text = 
                   Rtrim(LEFT('Stored Procedure failed with Error Code : ' 
                              + Cast(Error_number() AS VARCHAR(10)) 
                              + ', Line Number : ' 
                              + Cast(Error_line() AS VARCHAR(10)) 
                              + ', Description : ' + Error_message(), 3000) 
                   ) 

if @debug_me = 'Y' print @status_text

	select NULL as col1
	 , NULL as id1
	 , NULL as col2
	 , NULL as id2
	 , NULL as col3
	 , NULL as id3
	 , NULL as col4
	 , NULL as id4
	 , NULL as col5
	 , NULL as id5
	 , NULL as col6
	 , NULL as id6
	 , NULL as facility_name
	 , NULL as unit_desc
	 , NULL as immunization_description
	 , NULL as ttl_client
	 , NULL as ttl_administered
	 , NULL as ttl_notadministered
	 , null as percent_administered
	 , null as percent_notadministered
END CATCH

RETURN  
END
go

grant execute on reporting.bdl_sproc_ImmunizationClientSummary to public
go


GO

print 'G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.bdl_sproc_ImmunizationclientSummary.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.bdl_sproc_ImmunizationclientSummary.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.bdl_sproc_ImmunizationclientSummary_csv.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

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


/*-- ================================================================================= 
-- CORE-33165:          Update sproc for immunization rate reporting
--
-- Written By:          Rolly Sanchez, Mike Levine
-- Reviewed By:
--
-- Script Type:         DDL
-- Target DB Type:      Client
-- Target ENVIRONMENT:  BOTH
-- 
-- Re-Runable:          YES 
-- 
-- Description of Script : Create stored procedure to retrieve immunization detail and summary for CSV output
-- 
-- Special Instruction: depends on  reporting.bdl_sproc_ImmunizationClient_rawdata for data source
-- 
--	Revision History:
--	Date                User            JIRA          Description
--	2018, October 2     Rolly Sanchez   CORE-22599    Initial version for immunization report enterprise reporting
--	2019, February 4    Mike Levine     CORE-33165    Update sproc for immunization rate reporting

-- ================================================================================= */
if exists (select * from sys.procedures where name = 'bdl_sproc_ImmunizationClientSummary_CSV')
begin
	drop procedure reporting.bdl_sproc_ImmunizationClientSummary_CSV
end
go

CREATE PROCEDURE reporting.bdl_sproc_ImmunizationClientSummary_CSV
	  @fac_id varchar(max),
	  @immu_id varchar(300),
	  @immu_status int, 
	  @consent_status varchar(50),
	  @client_status varchar(10),
	  @immu_start_date datetime,
	  @immu_end_date datetime,
	  @group_lvl1 int,
	  @group_lvl2 int,
	  @group_lvl3 int,
	  @group_lvl4 int,
	  @group_lvl5 int,
	  @group_lvl6 int,
	  @groupBy_Fac tinyint,
	  @hrchy_ids varchar(100),
	  @username varchar(254),
	  @client_ids varchar(max) = NULL,
	  @status_code int out,
	  @status_text varchar(3000) out,
	  @debug_me CHAR(1) = 'N'
	    
/****************************************************************************************************  
--SAMPLE EXECUTION SCRIPT
  
declare @stext varchar(3000), @scode int
exec reporting.bdl_sproc_ImmunizationClientSummary_CSV 
	@debug_me = 'N'
	,  @fac_id = '-1'
	, @immu_id = '1,2,3,4,5,6,7,8,9,30,60'
	, @immu_status = -1
	, @include_wo_immu = 0
	, @consent_status = '1,2'
	, @client_status = '0'
	, @immu_start_date = '01/01/2006'
	, @immu_end_date = '12/01/2018'
	, @group_lvl1 = 1
	, @group_lvl2 = null
	, @group_lvl3 = null
	, @group_lvl4 = null
	, @group_lvl5 = null
	, @group_lvl6 = null
	, @groupBy_Fac = 0
	, @hrchy_ids = null
	, @username = 'pcc-sanchr'
	, @client_ids = '1, 2' or null
	, @status_code = @scode output
	, @status_text = @stext output

select @scode, @stext
*****************************************************************************************************/  
AS
BEGIN

SET NOCOUNT ON;

BEGIN TRY

declare @vfac_id varchar(max)
declare @vimmu_id varchar(300)
declare @vimmu_status int
declare @vconsent_status varchar(50)
declare @vclient_status varchar(10)
declare @vimmu_start_date datetime
declare @vimmu_end_date datetime
declare @vgroup_lvl1 int
declare @vgroup_lvl2 int
declare @vgroup_lvl3 int
declare @vgroup_lvl4 int
declare @vgroup_lvl5 int
declare @vgroup_lvl6 int
declare @vgroupBy_Fac tinyint
declare @vlvl_id1 int
declare @vlvl_id2 int
declare @vlvl_id3 int
declare @vlvl_id4 int
declare @vlvl_id5 int
declare @vlvl_id6 int
declare @vhrchy_ids varchar(100)
declare @vgrp_lvl int
declare @vusername varchar(254)
declare @vclient_ids varchar(max)
Declare @precision tinyint = 2
declare @stat_code int = 0
declare @stat_text varchar(3000) = ''

declare @vseparator char(1) = ','

Create Table #enterprise_immunization_rawdata (col1 varchar(254), id1 int, col2 varchar(254), id2 int, col3 varchar(254), id3 int, col4 varchar(254), id4 int, col5 varchar(254), id5 int, col6 varchar(254), id6 int
												  , facility_name varchar(100), immunization_description varchar(100), unit_desc varchar(100), bed_desc varchar(100),floor_desc varchar(100),room_desc varchar(100)
												  , client_id int, fac_id int, std_immunization_id int, last_name varchar(200), first_name varchar(200), client_id_number varchar(100), sex char(1)
												  ,client_status bit, admission_date datetime, discharge_date datetime, consent_status varchar(100), consent_by varchar(200), consent_date datetime, immunization_status varchar(100)
												  , immun_date datetime, administered_by varchar(200), route_of_admin varchar(100), dose_amount decimal(15,8), uom varchar(100), result_description varchar(100)
												  , reason varchar(200), body_location varchar(254), administered_id int, manufacturer_name varchar(50), step varchar(15)
												  , lot_number varchar(10), cvx_code int, cvx_short_description varchar(200), notes varchar(150), rnum int, status_code int, status_text varchar(3000) );

-- parameter sniffing
select @vfac_id = @fac_id
	, @vimmu_id = @immu_id
	, @vimmu_status = @immu_status
	, @vconsent_status = @consent_status
	, @vclient_status = @client_status
	, @vimmu_start_date = @immu_start_date
	, @vimmu_end_date = @immu_end_date
	, @vgroup_lvl1 = @group_lvl1
	, @vgroup_lvl2 = @group_lvl2
	, @vgroup_lvl3 = @group_lvl3
	, @vgroup_lvl4 = @group_lvl4
	, @vgroup_lvl5 = @group_lvl5
	, @vgroup_lvl6 = @group_lvl6
	, @vgroupBy_Fac = @groupBy_Fac
	, @vhrchy_ids = @hrchy_ids
	, @vusername = @username
	, @vclient_ids = @client_ids

	insert into #enterprise_immunization_rawdata
	exec reporting.bdl_sproc_ImmunizationClient_rawdata
    @fac_id = @vfac_id,
	  @immu_id = @vimmu_id,
	  @immu_status = @vimmu_status,
	  @consent_status = @vconsent_status,
	  @client_status = @vclient_status,
	  @immu_start_date = @vimmu_start_date,
	  @immu_end_date = @vimmu_end_date,
	  @group_lvl1 = @vgroup_lvl1,
	  @group_lvl2 = @vgroup_lvl2,
	  @group_lvl3 = @vgroup_lvl3,
	  @group_lvl4 = @vgroup_lvl4,
	  @group_lvl5 = @vgroup_lvl5,
	  @group_lvl6 = @vgroup_lvl6,
	  @groupBy_Fac  = @vgroupBy_Fac,
	  @hrchy_ids = @vhrchy_ids,
	  @username = @vusername,
	  @client_ids = @vclient_ids,
	  @status_code = @stat_code,
	  @status_text = @stat_text,
	  @debug_me  = @debug_me

if @debug_me = 'Y' select 'raw_data' as raw_data, * from #enterprise_immunization_rawdata

;with filtered_data
as (select * from #enterprise_immunization_rawdata
	where rnum = 1
	)
, ttl_col1
	as (select col1, id1
			, null as col2, null as id2
			, null as col3, null as id3
			, null as col4, null as id4
			, null as col5, null as id5
			, null as col6, null as id6
			, null as facility_name
			, null as unit_desc
			, null as immunization_description
			, count(*) ttl_client
			, sum(administered_id) as ttl_administered
			, sum((case when administered_id = 0 then 1 else 0 end)) as ttl_notadministered
		from filtered_data
		group by col1,  id1
	 )
, ttl_col2
	as (select col1, id1
			 , col2, id2
			, null as col3, null as id3
			, null as col4, null as id4
			, null as col5, null as id5
			, null as col6, null as id6
			, null as facility_name
			, null as unit_desc
			, null as immunization_description
			, count(*) ttl_client
			, sum(administered_id) as ttl_administered
			, sum((case when administered_id = 0 then 1 else 0 end)) as ttl_notadministered
		from filtered_data
		group by col1,  id1, col2, id2
		)
, ttl_col3
	as (select col1, id1
			 , col2, id2
			 , col3, id3
			, null as col4, null as id4
			, null as col5, null as id5
			, null as col6, null as id6
			, null as facility_name
			, null as unit_desc
			, null as immunization_description
			, count(*) ttl_client
			, sum(administered_id) as ttl_administered
			, sum((case when administered_id = 0 then 1 else 0 end)) as ttl_notadministered
		from filtered_data
		group by col1,  id1, col2, id2 , col3, id3
		)
, ttl_col4
	as (select col1, id1
			 , col2, id2
			 , col3, id3
			 , col4, id4
			, null as col5, null as id5
			, null as col6, null as id6
			, null as facility_name
			, null as unit_desc
			, null as immunization_description
			, count(*) ttl_client
			, sum(administered_id) as ttl_administered
			, sum((case when administered_id = 0 then 1 else 0 end)) as ttl_notadministered
		from filtered_data
		group by col1,  id1, col2, id2 , col3, id3, col4, id4
		)
, ttl_col5
	as (select col1, id1
			 , col2, id2
			 , col3, id3
			 , col4, id4
			 , col5, id5
			, null as col6, null as id6
			, null as facility_name
			, null as unit_desc
			, null as immunization_description
			, count(*) ttl_client
			, sum(administered_id) as ttl_administered
			, sum((case when administered_id = 0 then 1 else 0 end)) as ttl_notadministered
		from filtered_data
		group by col1,  id1, col2, id2 , col3, id3, col4, id4, col5, id5
		)
, ttl_col6
	as (select col1, id1
			 , col2, id2
			 , col3, id3
			 , col4, id4
			 , col5, id5
			 , col6, id6
			 , null as facility_name
			, null as unit_desc
			, null as immunization_description
			, count(*) ttl_client
			, sum(administered_id) as ttl_administered
			, sum((case when administered_id = 0 then 1 else 0 end)) as ttl_notadministered
		from filtered_data
		group by col1,  id1, col2, id2 , col3, id3, col4, id4, col5, id5, col6, id6
		)
, ttl_fac
	as (select col1, id1
			 , col2, id2
			 , col3, id3
			 , col4, id4
			 , col5, id5
			 , col6, id6
			 , fac_id
			 , facility_name
			, null as unit_desc
			, null as immunization_description
			, count(*) ttl_client
			, sum(administered_id) as ttl_administered
			, sum((case when administered_id = 0 then 1 else 0 end)) as ttl_notadministered
		from filtered_data
		group by col1,  id1, col2, id2 , col3, id3, col4, id4, col5, id5, col6, id6,fac_id, facility_name
		)
, ttl_unit
	as (select col1, id1
			 , col2, id2
			 , col3, id3
			 , col4, id4
			 , col5, id5
			 , col6, id6
			 , fac_id
			 , facility_name
			 , unit_desc
			, null as immunization_description
			, count(*) ttl_client
			, sum(administered_id) as ttl_administered
			, sum((case when administered_id = 0 then 1 else 0 end)) as ttl_notadministered
		from filtered_data
		group by col1,  id1, col2, id2 , col3, id3, col4, id4, col5, id5, col6, id6,fac_id, facility_name, unit_desc
		)
, ttl_administered
	as (select col1, id1
			 , col2, id2
			 , col3, id3
			 , col4, id4
			 , col5, id5
			 , col6, id6
			 , fac_id
			 , facility_name
			 , unit_desc
			 , immunization_description
			, count(*) ttl_client
			, sum(administered_id) as ttl_administered
			, sum((case when administered_id = 0 then 1 else 0 end)) as ttl_notadministered
		from filtered_data
		group by col1,  id1, col2, id2 , col3, id3, col4, id4, col5, id5, col6, id6, fac_id, facility_name, unit_desc, immunization_description
		)
, combined_group
as (select	  col1	, id1, col2	, id2, col3	, id3, col4	, id4, col5	, id5, col6	, id6
			, ttl_client, ttl_administered, ttl_notadministered
			 , round(convert(float,ttl_administered)/ convert(float,ttl_client) * 100,@precision) as percent_administered
			 , round(convert(float,ttl_notadministered)/ convert(float,ttl_client) * 100,@precision) as percent_notadministered
	  from ttl_col1
	 union all
	 select col1	, id1, col2	, id2, col3	, id3, col4	, id4, col5	, id5, col6	, id6
			, ttl_client, ttl_administered, ttl_notadministered
			 , round(convert(float,ttl_administered)/ convert(float,ttl_client) * 100,@precision) as percent_administered
			 , round(convert(float,ttl_notadministered)/ convert(float,ttl_client) * 100,@precision) as percent_notadministered
	  from ttl_col2
	 union all
	 select col1	, id1, col2	, id2, col3	, id3, col4	, id4, col5	, id5, col6	, id6
			, ttl_client, ttl_administered, ttl_notadministered
			 , round(convert(float,ttl_administered)/ convert(float,ttl_client) * 100,@precision) as percent_administered
			 , round(convert(float,ttl_notadministered)/ convert(float,ttl_client) * 100,@precision) as percent_notadministered
	  from ttl_col3
	 union all
	 select col1	, id1, col2	, id2, col3	, id3, col4	, id4, col5	, id5, col6	, id6
			, ttl_client, ttl_administered, ttl_notadministered
			 , round(convert(float,ttl_administered)/ convert(float,ttl_client) * 100,@precision) as percent_administered
			 , round(convert(float,ttl_notadministered)/ convert(float,ttl_client) * 100,@precision) as percent_notadministered
	  from ttl_col4
	 union all
	 select col1	, id1, col2	, id2, col3	, id3, col4	, id4, col5	, id5, col6	, id6
			, ttl_client, ttl_administered, ttl_notadministered
			 , round(convert(float,ttl_administered)/ convert(float,ttl_client) * 100,@precision) as percent_administered
			 , round(convert(float,ttl_notadministered)/ convert(float,ttl_client) * 100,@precision) as percent_notadministered
	  from ttl_col5
	 union all
	 select col1	, id1, col2	, id2, col3	, id3, col4	, id4, col5	, id5, col6	, id6
			, ttl_client, ttl_administered, ttl_notadministered
			 , round(convert(float,ttl_administered)/ convert(float,ttl_client) * 100,@precision) as percent_administered
			 , round(convert(float,ttl_notadministered)/ convert(float,ttl_client) * 100,@precision) as percent_notadministered
	  from ttl_col6
)
, distinct_grouping
	as ( select distinct col1, id1, col2, id2, col3, id3, col4, id4, col5, id5, col6, id6,
				 ttl_client, ttl_administered, ttl_notadministered, percent_administered,percent_notadministered
		from combined_group
	)
, combined_alldata
	as (
	 select col1
			 , id1
			 , col2
			 , id2
			 , col3
			 , id3
			 , col4
			 , id4
			 , col5
			 , id5
			 , col6
			 , id6
			 , null as facility_name
			 , null as unit_desc
			 , null as immunization_description
			 , ttl_client
			 , ttl_administered
			 , ttl_notadministered
			 , percent_administered
			 , percent_notadministered
			 , null as client_id
			 , null as fac_id
			 , null as std_immunization_id
			 , null as resident_name
			 , null as client_id_number
			 , null as consent_status
			 , null as consent_by
			 , null as consent_date
			 , null as immunization_status
			 , null as immun_date
			 , null as administered_by
			 , null as route_of_admin
			 , null as amount_administered
			 , null as result_description
			 , null as reason
			 , null as body_location
			 , null as administered_id
			 , null as manufacturer_name
			 , null as step
			 , null as lot_number
			 , null as cvx_code
			 , null as cvx_short_description
			 , null as notes
			 , null as rnum
	  from distinct_grouping
	 union all
	 select col1	, id1, col2	, id2, col3	, id3, col4	, id4, col5	, id5, col6	, id6
			, facility_name,unit_desc, immunization_description
			, ttl_client, ttl_administered, ttl_notadministered
			 , round(convert(float,ttl_administered)/ convert(float,ttl_client) * 100,@precision) as percent_administered
			 , round(convert(float,ttl_notadministered)/ convert(float,ttl_client) * 100,@precision) as percent_notadministered
			 , null as client_id
			 , fac_id
			 , null as std_immunization_id
			 , null as resident_name
			 , null as client_id_number
			 , null as consent_status
			 , null as consent_by
			 , null as consent_date
			 , null as immunization_status
			 , null as immun_date
			 , null as administered_by
			 , null as route_of_admin
			 , null as amount_administered
			 , null as result_description
			 , null as reason
			 , null as body_location
			 , null as administered_id
			 , null as manufacturer_name
			 , null as step
			 , null as lot_number
			 , null as cvx_code
			 , null as cvx_short_description
			 , null as notes
			 , null as rnum
	  from ttl_fac
	 union all
	 select col1	, id1, col2	, id2, col3	, id3, col4	, id4, col5	, id5, col6	, id6
			, facility_name,unit_desc, immunization_description
			, ttl_client, ttl_administered, ttl_notadministered
			 , round(convert(float,ttl_administered)/ convert(float,ttl_client) * 100,@precision) as percent_administered
			 , round(convert(float,ttl_notadministered)/ convert(float,ttl_client) * 100,@precision) as percent_notadministered
			 , null as client_id
			 , fac_id
			 , null as std_immunization_id
			 , null as resident_name
			 , null as client_id_number
			 , null as consent_status
			 , null as consent_by
			 , null as consent_date
			 , null as immunization_status
			 , null as immun_date
			 , null as administered_by
			 , null as route_of_admin
			 , null as amount_administered
			 , null as result_description
			 , null as reason
			 , null as body_location
			 , null as administered_id
			 , null as manufacturer_name
			 , null as step
			 , null as lot_number
			 , null as cvx_code
			 , null as cvx_short_description
			 , null as notes
			 , null as rnum
	  from ttl_unit
	 union all
	 select col1	, id1, col2	, id2, col3	, id3, col4	, id4, col5	, id5, col6	, id6
			, facility_name,unit_desc, immunization_description
			, ttl_client, ttl_administered, ttl_notadministered
			 , round(convert(float,ttl_administered)/ convert(float,ttl_client) * 100,@precision) as percent_administered
			 , round(convert(float,ttl_notadministered)/ convert(float,ttl_client) * 100,@precision) as percent_notadministered
			 , null as client_id
			 , fac_id
			 , null as std_immunization_id
			 , null as resident_name
			 , null as client_id_number
			 , null as consent_status
			 , null as consent_by
			 , null as consent_date
			 , null as immunization_status
			 , null as immun_date
			 , null as administered_by
			 , null as route_of_admin
			 , null as amount_administered
			 , null as result_description
			 , null as reason
			 , null as body_location
			 , null as administered_id
			 , null as manufacturer_name
			 , null as step
			 , null as lot_number
			 , null as cvx_code
			 , null as cvx_short_description
			 , null as notes
			 , null as rnum
	  from ttl_administered

	  union all
	  select  col1	, id1, col2	, id2, col3	, id3, col4	, id4, col5	, id5, col6	, id6
			, facility_name,unit_desc, immunization_description
			, null as ttl_client
			, null as ttl_administered
			, null as ttl_notadministered
			, null as percent_administered
			, null as percent_notadministered
			, client_id
			, fac_id
			, std_immunization_id
			, last_name + ', ' + first_name as resident_name
			, client_id_number
			, consent_status
			, consent_by
			, consent_date
			, immunization_status
			, immun_date
			, administered_by
			, route_of_admin
			, convert(varchar(20),dose_amount) + ' ' + uom as amount_administered
			, result_description
			, reason
			, body_location
			, case when administered_id = '0' then 'No' else 'Yes' end as administered_id
			, manufacturer_name
			, step
			, lot_number
			, cvx_code
			, cvx_short_description
			, notes
			, rnum
	   from #enterprise_immunization_rawdata
)

-- returning final result
select
	col1, id1
	, col2, id2
	, col3, id3
	, col4, id4
	, col5, id5
	, col6, id6
	, fac_id
	, facility_name
	, unit_desc
	, immunization_description
	, ttl_client
	, ttl_administered
	, ttl_notadministered
	, percent_administered
	, percent_notadministered
	, client_id
	, std_immunization_id
	, resident_name + ' (' + client_id_number + ')' as resident_name
	, consent_status
	, consent_by
	, consent_date
	, immunization_status
	, immun_date
	, administered_by
	, route_of_admin
	, amount_administered
	, result_description
	, reason
	, body_location
	, administered_id AS administered
	, manufacturer_name as [Manufacturer's Name]
	, step as Step
	, lot_number
	, cvx_code
	, cvx_short_description
	, notes
	, rnum
 from combined_alldata
	order by col1, col2, col3, col4, col5, col6, facility_name,unit_desc, immunization_description
			, ttl_client desc, ttl_administered desc , ttl_notadministered desc
			, resident_name	, immun_date desc, consent_date desc

END TRY

BEGIN CATCH

 SELECT @status_code = 1
	, @status_text = Rtrim(LEFT('Stored Procedure failed with Error Code : '
                              + Cast(Error_number() AS VARCHAR(10))
                              + ', Line Number : '
                              + Cast(Error_line() AS VARCHAR(10))
                              + ', Description : ' + Error_message(), 3000)
						  )

if @debug_me = 'Y' print @status_text

	select  null as col1
	 , null as id1
	 , null as col2
	 , null as id2
	 , null as col3
	 , null as id3
	 , null as col4
	 , null as id4
	 , null as col5
	 , null as id5
	 , null as col6
	 , null as id6
	 , null as fac_id
	 , null as facility_name
	 , null as unit_desc
	 , null as immunization_description
	 , null as ttl_client
	 , null as ttl_administered
	 , null as ttl_notadministered
	 , null as percent_administered
	 , null as percent_notadministered
	 , null as client_id
	 , null as std_immunization_id
	 , null as resident_name
	 , null as consent_status
	 , null as consent_by
	 , null as consent_date
	 , null as immunization_status
	 , null as immun_date
	 , null as administered_by
	 , null as route_of_admin
	 , null as amount_administered
	 , null as result_description
	 , null as reason
	 , null as body_location
	 , null as administered
	 , null as [Manufacturer's Name]
	 , null as Step
	 , null as lot_number
	 , null as cvx_code
	 , null as cvx_short_description
	 , null as notes
	 , null as rnum
END CATCH

RETURN
END
go

grant execute on reporting.bdl_sproc_ImmunizationClientSummary_CSV to public
go


GO

print 'G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.bdl_sproc_ImmunizationclientSummary_csv.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.bdl_sproc_ImmunizationclientSummary_csv.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.bdl_sproc_ImmunizationRate.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

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


/*-- ================================================================================= 
-- CORE-30607       :   Enterprise Immunization Rates Report 
--						-- 

-- Written By:          Maria Fradkin
-- Reviewed By:         
-- 
-- Script Type:         DML 
-- Target DB Type:      Client
-- Target ENVIRONMENT:  BOTH  
-- 
-- 
-- Re-Runable:          YES 
-- 
-- Description of Script : Create stored procedure to retrieve immunization client raw data 
-- 
-- Special Instruction: 
--none
-- ------sample script---------
DECLARE @vclient_id TableOfInt;
 
EXEC [reporting].[bdl_sproc_ImmunizationRate]
@fac_id = '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,30,32,33,34,35,36,37,39,40,41,42,43,44,45,46,47,52',
@client_id = @vclient_id,
@immu_id ='1,2,3,4,5,6,7,8,9,11,30,32,51,80,90,91,102,122',
@consent_status = '6,5',	--	5 - for missing, 6 - for strike out, null - when nothing is selected
@client_status ='0,1',	    --	0 - discharged, 1 - current 
@immu_start_date ='2020-01-01',
@immu_end_date = '2020-01-31',
@group_lvl1 =1,
@group_lvl2 =12,
@group_lvl3 =23,
@group_lvl4 =NULL,
@group_lvl5 =NULL,
@group_lvl6 =NULL,
@status_code =NULL,
@status_text =NULL;

/***********************************************************************************
Revision History:
2019-03-13	Ritch Moore		CORE-34562	Update consent type table load
2019-04-01	Ritch Moore		CORE-38047	Revised resident filtering
2019-04-11	Ritch Moore		CORE-39056	Use ldl dim view not pdl dim table
2019-12-09	Amro Saada		CORE-57616	Add cvx code and description columns to the output
2020-01-08	Amro Saada		CORE-59689	Apply sorting to procedure output
2020-01-28	Amro Saada		CORE-60406	Add client filter
***********************************************************************************/
--======================================================================================================================*/
IF EXISTS (SELECT * FROM SYS.PROCEDURES WHERE NAME = 'bdl_sproc_ImmunizationRate')
BEGIN
	DROP PROCEDURE reporting.bdl_sproc_ImmunizationRate
END
GO

CREATE PROCEDURE reporting.bdl_sproc_ImmunizationRate
	 
	  @fac_id varchar(max),
	  @client_id TableOfInt READONLY,
	  @immu_id varchar(300),
	  @consent_status varchar(50),	--	5 - for missing, 6 - for strike out, null - default
	  @client_status varchar(10),	--	0 - discharged, 1 - current 
	  @immu_start_date datetime,
	  @immu_end_date datetime,
	  @group_lvl1 int,
	  @group_lvl2 int,
	  @group_lvl3 int,
	  @group_lvl4 int,
	  @group_lvl5 int,
	  @group_lvl6 int,
	  @status_code int out,
	  @status_text varchar(3000) OUT
AS      
BEGIN
SET NOCOUNT ON;
BEGIN TRY

IF (SELECT COUNT(*) FROM @client_id) > 0
BEGIN
	
	DECLARE @vimmu_start_date_id INT = FORMAT(@immu_start_date,'yyyyMMdd'); 
	DECLARE @vimmu_end_date_id INT = FORMAT(@immu_end_date,'yyyyMMdd');
	DECLARE @vImmuStartDate datetime = convert(datetime, convert(varchar(10),@immu_start_date, 101) + ' 00:00:00'); 
	DECLARE @vImmuEndDate datetime = convert(datetime, convert(varchar(10),@immu_end_date, 101) + ' 23:59:59'); 
	DECLARE @vseparator CHAR(1) = ',';
	DECLARE @facility dbo.TableOfInt; 
	DECLARE @Immunization dbo.TwoColumnsOfIntTableType;
	DECLARE @ClientStatus dbo.TableOfInt; 
	DECLARE @Consent dbo.TableOfInt; 
	DECLARE @vall_clients bit = 0;
	DECLARE @covid19ImmunizationId INT;

	SET @covid19ImmunizationId = ISNULL((SELECT std_immunization_id FROM cr_std_immunization WHERE description = 'SARS-COV-2 (COVID-19)' AND system_flag = 'Y' AND deleted = 'N'), -1);

	IF (SELECT COUNT(*) FROM @client_id) = 1
	BEGIN
		IF (SELECT id FROM @client_id) = -1
		BEGIN
			SET @vall_clients = 1;
		END		
	END

	INSERT @Facility(id)
	SELECT  TRY_CAST(a.items AS INT)
	FROM dbo.split(@fac_id, @vseparator)  a;
    
	INSERT @Immunization(col1, col2)
	SELECT  TRY_CAST(a.items AS INT) , 1
	FROM dbo.split(@immu_id, @vseparator)  a;
	--add step2 for TB
	INSERT @Immunization(col1, col2)
	SELECT a.col1, 2 as col2
	FROM @Immunization a
	WHERE a.col1 = 5;

	--add step2 for COVID-19
	INSERT @Immunization(col1, col2)
	SELECT a.col1, 2 as col2
	FROM @Immunization a
	WHERE a.col1 = @covid19ImmunizationId;

	INSERT @ClientStatus(id)
	SELECT  TRY_CAST(a.items AS INT)
	FROM dbo.split(@client_status, @vseparator)  a;

	INSERT @Consent(id)
	SELECT consent_code_id 
	FROM reporting.ldl_view_dim_ConsentStatusCode a
	WHERE consent_code_id < 5 -- all but not "missing" and "strike out" 
	UNION ALL
    SELECT TRY_CAST(a.items AS INT)
	FROM  dbo.split(@consent_status, @vseparator) a;	-- add special cases

	SELECT 
		col1, 
		col2, 
		col3, 
		col4, 
		col5, 
		col6,
		Facility ,
		Unit ,
		Immunization,
		Step,
		[Consent Type],
		Reason,
		Results,
		--detail info
		Resident,
		[Consent Date],
		[Consent Confirmed By],
		[Education Provided To Resident/Family],
		[Administration Date],
		[Administered By],
		[Route of Administration],
		CONVERT(VARCHAR(20), [Dose Amount]) + ' ' + Uom as [Amount Administered],
		[Location Given],
		[Manufacturer's Name],
		[Substance Expiration Date],
		[Lot Number],
		[Induration],
		[Struck Out By],
		[Strike Out Date],
		[cvx_code] AS [CVX Code],
		[cvx_description] AS [Description],
		Notes
	FROM reporting.bdl_fn_ImmunizationRate( 
		@Facility ,
		@Immunization,
		@ClientStatus ,
		@Consent,
		@vimmu_start_date_id,
		@vimmu_end_date_id,
		@vImmuStartDate,
		@vImmuEndDate,
		@group_lvl1, @group_lvl2, @group_lvl3, @group_lvl4, @group_lvl5, @group_lvl6
		)f
	LEFT JOIN @client_id c
		ON f.client_id = c.id
	WHERE (@vall_clients = 1 OR f.client_id = c.id)
	UNION ALL
	SELECT 
		col1, 
		col2, 
		col3, 
		col4, 
		col5, 
		col6,
		Facility ,
		Unit ,
		Immunization,
		Step,
		[Consent Type],
		Reason,
		Results,
		--detail info
		Resident,
		[Consent Date],
		[Consent Confirmed By],
		[Education Provided To Resident/Family],
		[Administration Date],
		[Administered By],
		[Route of Administration],
		CONVERT(VARCHAR(20), [Dose Amount]) + ' ' + Uom as [Amount Administered],
		[Location Given],
		[Manufacturer's Name],
		[Substance Expiration Date],
		[Lot Number],
		[Induration],
		[Struck Out By],
		[Strike Out Date],
		NULL,
		NULL,
		Notes
	FROM reporting.bdl_fn_ImmunizationRate_MissingRecords( 
		@Facility ,
		@Immunization,
		@ClientStatus ,
		@Consent,
		@vimmu_start_date_id,
		@vimmu_end_date_id,
		@vImmuStartDate,
		@vImmuEndDate,
		@group_lvl1, @group_lvl2, @group_lvl3, @group_lvl4, @group_lvl5, @group_lvl6
		)f
	LEFT JOIN @client_id c
		ON f.client_id = c.id
	WHERE EXISTS (SELECT 1 FROM @Consent WHERE id = 5) --append missing
	AND (@vall_clients = 1 OR f.client_id = c.id)
    ORDER BY col1,col2,col3,col4,col5,col6,Facility,Unit,Immunization,[Consent Type];
END
ELSE 
BEGIN
SELECT 
		NULL AS col1, 
		NULL AS col2, 
		NULL AS col3, 
		NULL AS col4, 
		NULL AS col5, 
		NULL AS col6,
		NULL AS Facility ,
		NULL AS Unit ,
		NULL AS Immunization,
		NULL AS Step,
		NULL AS [Consent Type],
		NULL AS Reason,
		NULL AS Results,
		--detail info
		NULL AS Resident,
		NULL AS [Consent Date],
		NULL AS [Consent Confirmed By],
		NULL AS [Education Provided To Resident/Family],
		NULL AS [Administration Date],
		NULL AS [Administered By],
		NULL AS [Route of Administration],
		NULL AS [Amount Administered],
		NULL AS [Location Given],
		NULL AS [Manufacturer's Name],
		NULL AS [Substance Expiration Date],
		NULL AS [Lot Number],
		NULL AS [Induration],
		NULL AS [Struck Out By],
		NULL AS [Strike Out Date],
		NULL AS [cvx_code],
		NULL AS [cvx_description],
		NULL AS Notes
END
END TRY
BEGIN CATCH

	SELECT 
		NULL AS col1, 
		NULL AS col2, 
		NULL AS col3, 
		NULL AS col4, 
		NULL AS col5, 
		NULL AS col6,
		NULL AS Facility ,
		NULL AS Unit ,
		NULL AS Immunization,
		NULL AS Step,
		NULL AS [Consent Type],
		NULL AS Reason,
		NULL AS Results,
		--detail info
		NULL AS Resident,
		NULL AS [Consent Date],
		NULL AS [Consent Confirmed By],
		NULL AS [Education Provided To Resident/Family],
		NULL AS [Administration Date],
		NULL AS [Administered By],
		NULL AS [Route of Administration],
		NULL AS [Amount Administered],
		NULL AS [Location Given],
		NULL AS [Manufacturer's Name],
		NULL AS [Substance Expiration Date],
		NULL AS [Lot Number],
		NULL AS [Induration],
		NULL AS [Struck Out By],
		NULL AS [Strike Out Date],
		NULL AS [cvx_code],
		NULL AS [cvx_description],
		NULL AS Notes
	SELECT 
		@status_text = RTRIM(LEFT('Stored Procedure failed with Error Code : ' 
                              + CAST(ERROR_NUMBER() AS VARCHAR(10)) 
                              + ', Line Number : ' 
                              + CAST(ERROR_LINE() AS VARCHAR(10)) 
                              + ', Description : ' + ERROR_MESSAGE(), 3000) 
                   ),
		 @status_code = 1;

	SELECT @status_code as status_code, @status_text as status_text;
END CATCH;
END;
GO

GRANT EXECUTE ON reporting.bdl_sproc_ImmunizationRate TO PUBLIC
GO


GO

print 'G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.bdl_sproc_ImmunizationRate.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.bdl_sproc_ImmunizationRate.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.bdl_sproc_ImmunizationRateSummary.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

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


/*-- ================================================================================= 
-- CORE-34562      :   Enterprise Immunization Rates Summary Report 
--						-- 

-- Written By:          Ritch Moore
-- Reviewed By:         
-- 
-- Script Type:         DDL 
-- Target DB Type:      Client
-- Target ENVIRONMENT:  BOTH  
-- 
-- 
-- Re-Runable:          YES 
-- 
-- Description of Script : Create stored procedure to retrieve immunization client raw data with rates
-- 
-- Special Instruction: 
--none
-- ------sample script---------

exec reporting.bdl_sproc_ImmunizationRateSummary
	 
	  @fac_id = '1,2,3,4,5',
	  @immu_id ='1,2,3,4,5',
	  @consent_status = '4',	--	5 - for missing, 6 - for strike out, null - when nothing is selected
	  @client_status ='1',	--	0 - current, 1 - discharged 
	  @immu_start_date ='2017/01/01',
	  @immu_end_date = '2019/12/31',
	  @group_lvl1 =1,
	  @group_lvl2 =2,
	  @group_lvl3 =3,
	  @group_lvl4 =4,
	  @group_lvl5 =5,
	  @group_lvl6 =6,
	  @debug_me = 'N',
	  @status_code = Null,
	  @status_text = Null

/***********************************************************************************
Revision History:
2019-04-01	Ritch Moore		CORE-38047	Revised resident filtering
2019-04-11	Ritch Moore		CORE-39056	Use ldl dim view not pdl dim table
***********************************************************************************/
*/
--======================================================================================================================*/
IF EXISTS (SELECT * FROM SYS.PROCEDURES WHERE NAME = 'bdl_sproc_ImmunizationRateSummary')
BEGIN
	DROP PROCEDURE reporting.bdl_sproc_ImmunizationRateSummary
END
GO

CREATE PROCEDURE reporting.bdl_sproc_ImmunizationRateSummary
	 
	  @fac_id varchar(max),
	  @immu_id varchar(300),
	  @consent_status varchar(50),	--	5 - for missing, 6 - for strike out, null - default
	  @client_status varchar(10),	--	0 - current, 1 - discharged 
	  @immu_start_date datetime,
	  @immu_end_date datetime,
	  @group_lvl1 int,
	  @group_lvl2 int,
	  @group_lvl3 int,
	  @group_lvl4 int,
	  @group_lvl5 int,
	  @group_lvl6 int,
	  @debug_me char(1) = 'N',
	  @status_code int out,
	  @status_text varchar(3000) OUT
AS      
BEGIN
SET NOCOUNT ON;
BEGIN TRY
	DECLARE @vseparator CHAR(1) = ',';
	DECLARE @facility dbo.TableOfInt; 
	DECLARE @Immunization dbo.TwoColumnsOfIntTableType;
	DECLARE @ClientStatus dbo.TableOfInt; 
	DECLARE @Consent dbo.TableOfInt;
	----Local Variables
	DECLARE @vFacId varchar(max);
	DECLARE @vImmuId varchar(300);
	DECLARE @vConsentStatus varchar(50);
	DECLARE @vClientStatus varchar(10);
	DECLARE @vImmuStartDateID INT = FORMAT(@immu_start_date,'yyyyMMdd'); 
	DECLARE @vImmuEndDateID INT = FORMAT(@immu_end_date,'yyyyMMdd'); 
	DECLARE @vImmuStartDate datetime = convert(datetime, convert(varchar(10),@immu_start_date, 101) + ' 00:00:00'); 
	DECLARE @vImmuEndDate datetime = convert(datetime, convert(varchar(10),@immu_end_date, 101) + ' 23:59:59');
	DECLARE @vGroupLvl1 int;
	DECLARE @vGroupLvl2 int;
	DECLARE @vGroupLvl3 int;
	DECLARE @vGroupLvl4 int;
	DECLARE @vGroupLvl5 int;
	DECLARE @vGroupLvl6 int;
	DECLARE @vDebugMe char(1); 
	-----Statistics Variables 
	Declare  @vgs_program_name varchar(200)
			,@vgs_start_time datetime
			,@vgsStepStartTime datetime
			,@vgsStepEndTime datetime
			,@vStep int

	SET @vFacId = @fac_id;
	SET @vImmuId = @immu_id;
	SET @vConsentStatus = @consent_status;
	SET @vClientStatus = @client_status;
	SET @vGroupLvl1 = @group_lvl1;
	SET @vGroupLvl2 = @group_lvl2;
	SET @vGroupLvl3 = @group_lvl3;
	SET @vGroupLvl4 = @group_lvl4;
	SET @vGroupLvl5 = @group_lvl5;
	SET @vGroupLvl6 = @group_lvl6;
	SET @vDebugMe = @debug_me;
	SET @vgs_program_name  = Object_name(@@ProcID); 
	SET @vgs_start_time = GETDATE();

	Create table #immrate 
	(
		col1 varchar (254), 
		col2 varchar (254), 
		col3 varchar (254), 
		col4 varchar (254), 
		col5 varchar (254), 
		col6 varchar (254),
		fac_id int,
		Facility varchar (375),
		Unit varchar (35),
		Std_immunization_id int,
		fact_immunization_id int,
		Immunization varchar (55),
		Step varchar (100),
		[Consent Type] varchar (40),
		reason_code_id int,
		Reason varchar (254),
		result_code_id int,
		Results varchar (30),
		Client_id int,
		Resident varchar (150),
		consent_id int,
		[Consent Date] datetime,
		[Consent Confirmed By] varchar (50),
		[Education Provided To Resident/Family] varchar (5),
		[Administration Date] datetime,
		[Administered By] varchar (50),
		[Route of Administration] varchar (100),
		[Dose Amount] numeric (18,5),
		[Uom] varchar(20),
		[Location Given] varchar (254),
		[Manufacturer's Name] varchar (50),
		[Substance Expiration Date] datetime,
		[Lot Number] varchar (10),
		[Induration] float,
		[Struck Out By] varchar (50),
		[Strike Out Date] datetime,
		Notes varchar (150)
	);

	DECLARE @stats AS table
	(
		fac_id int,
		std_immunization_id int,
		consent_id int,
		reason_code_id int,
		result_code_id int,
		[Immunization Count] float,
		[Consent Count] float,
		[Reason Count] float,
		[Result Count] float
	);
	
	select @vStep = 10
	set @vgsStepStartTime = GETDATE()
	if @vDebugMe='Y' Print 'STEP ' +  convert(varchar(20), @vStep)  + ' Loading Filter Tables  ' +  convert(varchar(26),getdate(),109)

    DECLARE @covid19ImmunizationId INT;
    SET @covid19ImmunizationId = ISNULL((SELECT std_immunization_id FROM cr_std_immunization WHERE description = 'SARS-COV-2 (COVID-19)' AND system_flag = 'Y' AND deleted = 'N'), -1);

	INSERT @Facility(id)
	SELECT  TRY_CAST(a.items AS INT)
	FROM dbo.split(@vFacId, @vseparator)  a;
    
	INSERT @Immunization(col1, col2)
	SELECT  TRY_CAST(a.items AS INT) , 1
	FROM dbo.split(@vImmuId, @vseparator)  a;
	--add step2 for TB
	INSERT @Immunization(col1, col2)
	SELECT a.col1, 2 as col2
	FROM @Immunization a
	WHERE a.col1 = 5;

    --add step2 for COVID-19
	INSERT @Immunization(col1, col2)
	SELECT a.col1, 2 as col2
	FROM @Immunization a
	WHERE a.col1 = @covid19ImmunizationId;

	INSERT @ClientStatus(id)
	SELECT  TRY_CAST(a.items AS INT)
	FROM dbo.split(@vClientStatus, @vseparator)  a;

	INSERT @Consent(id)
	SELECT consent_code_id 
	FROM reporting.ldl_view_dim_ConsentStatusCode a
	WHERE consent_code_id < 5 -- all but not "missing" and "strike out" 
	UNION ALL
    SELECT TRY_CAST(a.items AS INT)
	FROM  dbo.split(@vConsentStatus, @vseparator) a;	-- add special cases

	set @vgsStepEndTime=GETDATE();
	if @vDebugMe='Y' Print 'STEP ' +  convert(varchar(20), @vStep)  + ' complete: '+ltrim(rtrim(str(DATEDIFF(ms,@vgsStepStartTime,@vgsStepEndTime))))+ ' ms'

	select @vStep = 20
	set @vgsStepStartTime = GETDATE()
	if @vDebugMe='Y' Print 'STEP ' +  convert(varchar(20), @vStep)  + ' Loading Immunization Data  ' +  convert(varchar(26),getdate(),109)

	insert into #immrate (col1, col2, col3, col4, col5, col6, fac_id, Facility,Unit, Std_immunization_id, fact_immunization_id, Immunization, Step,
		[Consent Type], reason_code_id, Reason, result_code_id, Results, Client_id, Resident, consent_id, [Consent Date], [Consent Confirmed By],
		[Education Provided To Resident/Family], [Administration Date], [Administered By], [Route of Administration], [Dose Amount], [Uom],
		[Location Given], [Manufacturer's Name], [Substance Expiration Date], [Lot Number], [Induration], [Struck Out By], [Strike Out Date], Notes)
	SELECT 
		col1, 
		col2, 
		col3, 
		col4, 
		col5, 
		col6,
		fac_id,
		Facility ,
		Unit ,
		std_immunization_id,
		fact_immunization_id,
		Immunization,
		Step,
		[Consent Type],
		reason_code_id,
		Reason,
		result_code_id,
		Results,
		--detail info
		client_id,
		Resident,
		consent_code_id,
		[Consent Date],
		[Consent Confirmed By],
		[Education Provided To Resident/Family],
		[Administration Date],
		[Administered By],
		[Route of Administration],
		[Dose Amount],
		[Uom],
		[Location Given],
		[Manufacturer's Name],
		[Substance Expiration Date],
		[Lot Number],
		[Induration],
		[Struck Out By],
		[Strike Out Date],
		Notes
	FROM reporting.bdl_fn_ImmunizationRate( 
		@Facility ,
		@Immunization,
		@ClientStatus ,
		@Consent,
		@vImmuStartDateID,
		@vImmuEndDateID,
		@vImmuStartDate,
		@vImmuEndDate,
		@vGroupLvl1, @vGroupLvl2, @vGroupLvl3, @vGroupLvl4, @vGroupLvl5, @vGroupLvl6
		)f
	UNION ALL
	SELECT 
		col1, 
		col2, 
		col3, 
		col4, 
		col5, 
		col6,
		fac_id,
		Facility ,
		Unit ,
		std_immunization_id,
		fact_immunization_id,
		Immunization,
		Step,
		[Consent Type],
		reason_code_id,
		Reason,
		result_code_id,
		Results,
		--detail info
		client_id,
		Resident,
		consent_code_id,
		[Consent Date],
		[Consent Confirmed By],
		[Education Provided To Resident/Family],
		[Administration Date],
		[Administered By],
		[Route of Administration],
		[Dose Amount],
		[Uom],
		[Location Given],
		[Manufacturer's Name],
		[Substance Expiration Date],
		[Lot Number],
		[Induration],
		[Struck Out By],
		[Strike Out Date],
		Notes
	FROM reporting.bdl_fn_ImmunizationRate_MissingRecords( 
		@Facility ,
		@Immunization,
		@ClientStatus ,
		@Consent,
		@vImmuStartDateID,
		@vImmuEndDateID,
		@vImmuStartDate,
		@vImmuEndDate,
		@vGroupLvl1, @vGroupLvl2, @vGroupLvl3, @vGroupLvl4, @vGroupLvl5, @vGroupLvl6
		)f
	WHERE EXISTS (SELECT 1 FROM @Consent WHERE id = 5) --append missing			

	set @vgsStepEndTime=GETDATE();
	if @vDebugMe='Y' Print 'STEP ' +  convert(varchar(20), @vStep)  + ' complete: '+ltrim(rtrim(str(DATEDIFF(ms,@vgsStepStartTime,@vgsStepEndTime))))+ ' ms'

	select @vStep = 30
	set @vgsStepStartTime = GETDATE()
	if @vDebugMe='Y' Print 'STEP ' +  convert(varchar(20), @vStep)  + ' Calculating Rates  ' +  convert(varchar(26),getdate(),109)

	insert into @stats 
	select distinct fac_id, isnull(std_immunization_id,0), isnull(consent_id,0), isnull(reason_code_id,0), isnull(result_code_id,0), 0, 0, 0, 0 from #immrate

	--calculating counts
	update sts set sts.[Immunization Count]  = totals.ttl
	from @stats sts
	inner join
		(
		select cls.fac_id, cls.std_immunization_id, COUNT(cls.fact_immunization_id) ttl
		from #immrate cls --where cls.consent_id < 5
		group by cls.fac_id, cls.std_immunization_id
		) totals on sts.fac_id = totals.fac_id and sts.std_immunization_id = totals.std_immunization_id

	update sts set sts.[Consent Count]  = totals.ttl
	from @stats sts
	inner join
		(
		select cls.fac_id, cls.std_immunization_id, cls.consent_id, COUNT(cls.fact_immunization_id) ttl
		from #immrate cls 
		group by cls.fac_id, cls.std_immunization_id, cls.consent_id
		) totals on sts.fac_id = totals.fac_id and sts.std_immunization_id = totals.std_immunization_id and sts.consent_id = totals.consent_id

	update sts set sts.[Reason Count] = totals.ttl
	from @stats sts
	inner join
		(
		select cls.fac_id, cls.std_immunization_id, cls.consent_id, cls.reason_code_id, COUNT(cls.fact_immunization_id) ttl
		from #immrate cls where cls.reason_code_id <> -1
		group by cls.fac_id, cls.std_immunization_id, cls.consent_id, cls.reason_code_id
		) totals on sts.fac_id = totals.fac_id and sts.std_immunization_id = totals.std_immunization_id and sts.consent_id = totals.consent_id
		 and sts.reason_code_id = totals.reason_code_id

	update sts set sts.[Result Count] = totals.ttl
	from @stats sts
	inner join
		(
		select cls.fac_id, cls.std_immunization_id, cls.consent_id, cls.result_code_id, COUNT(cls.fact_immunization_id) ttl
		from #immrate cls where cls.result_code_id <> -1
		group by cls.fac_id, cls.std_immunization_id, cls.consent_id, cls.result_code_id
		) totals on sts.fac_id = totals.fac_id and sts.std_immunization_id = totals.std_immunization_id and sts.consent_id = totals.consent_id
		 and sts.result_code_id = totals.result_code_id

	set @vgsStepEndTime=GETDATE();
	if @vDebugMe='Y' Print 'STEP ' +  convert(varchar(20), @vStep)  + ' complete: '+ltrim(rtrim(str(DATEDIFF(ms,@vgsStepStartTime,@vgsStepEndTime))))+ ' ms'

	select @vStep = 40
	set @vgsStepStartTime = GETDATE()
	if @vDebugMe='Y' Print 'STEP ' +  convert(varchar(20), @vStep)  + ' Final Select  ' +  convert(varchar(26),getdate(),109)

	SELECT 
		imm.col1, 
		imm.col2, 
		imm.col3, 
		imm.col4, 
		imm.col5, 
		imm.col6,
		imm.Facility ,
		imm.Unit ,
		imm.Immunization,
		imm.Step,
		Case when sts.consent_id = 1 then 'Consented Not Administered' 
		else imm.[Consent Type] end as [Consent Type] ,
		round((sts.[Consent Count]/sts.[Immunization Count]) * 100,0) as [Consent Type %],
		sts.[Consent Count] as [Consent Type Count],
		imm.[Reason],
		Case when sts.[Reason Count] = 0 
			then Null else round((sts.[Reason Count]/sts.[Consent Count]) * 100,0) end as [Reason %],
		Case when sts.[Reason Count] = 0 then Null else sts.[Reason Count] end as [Reason Count] ,
		imm.Results,
		Case when sts.[Result Count] = 0 
			then Null else round((sts.[Result Count]/sts.[Consent Count]) * 100,0) end as [Results %],
		Case when sts.[Result Count] = 0 then Null else sts.[Result Count] end as [Results Count],
		--detail info
		imm.Resident,
		imm.[Consent Date],
		imm.[Consent Confirmed By],
		imm.[Education Provided To Resident/Family],
		imm.[Administration Date],
		imm.[Administered By],
		imm.[Route of Administration],
		CONVERT(VARCHAR(20), imm.[Dose Amount]) + ' ' + imm.Uom as [Amount Administered],
		imm.[Uom],
		imm.[Location Given],
		imm.[Manufacturer's Name],
		imm.[Substance Expiration Date],
		imm.[Lot Number],
		imm.[Induration],
		imm.[Struck Out By],
		Case when imm.consent_id = 6 or imm.[Strike Out Date] is not null then imm.Reason else '' end as [Strike Out Reason],
		imm.[Strike Out Date],
		imm.Notes
	FROM  #immrate imm
	inner join @stats sts on imm.fac_id = sts.fac_id and imm.std_immunization_id = sts.std_immunization_id and imm.consent_id = sts.consent_id
		and imm.result_code_id = sts.result_code_id and imm.reason_code_id = sts.reason_code_id
	order by imm.col1, imm.col2, imm.col3, imm.col4, imm.col5, imm.col6, imm.Facility, imm.Immunization, imm.[Consent Type], imm.Reason, 
		imm.Results, imm.resident, imm.step, imm.[Administration Date]

	set @vgsStepEndTime=GETDATE();
	if @vDebugMe='Y' Print 'STEP ' +  convert(varchar(20), @vStep)  + ' complete: '+ltrim(rtrim(str(DATEDIFF(ms,@vgsStepStartTime,@vgsStepEndTime))))+ ' ms'
	if @vDebugMe='Y' Print 'Successful execution of stored procedure ' + Object_name(@@ProcID) + ' completed in '+ltrim(rtrim(str(DATEDIFF(ms,@vgs_start_time,@vgsStepEndTime))))+ ' ms'

END TRY
BEGIN CATCH

	SELECT 
		NULL AS col1, 
		NULL AS col2, 
		NULL AS col3, 
		NULL AS col4, 
		NULL AS col5, 
		NULL AS col6,
		NULL AS Facility ,
		NULL AS Unit ,
		NULL AS Immunization,
		NULL AS Step,
		NULL AS [Consent Type],
		NULL AS [Consent Type %],
		NULL AS [Consent Type Count],
		NULL AS Reason,
		NULL AS [Reason %],
		NULL AS [ReasonCount],
		NULL AS Results,
		NULL AS [Results %],
		NULL AS [Results Count],
		--detail info
		NULL AS Resident,
		NULL AS [Consent Date],
		NULL AS [Consent Confirmed By],
		NULL AS [Education Provided To Resident/Family],
		NULL AS [Administration Date],
		NULL AS [Administered By],
		NULL AS [Route of Administration],
		NULL AS [Amount Administered],
		NULL AS [Location Given],
		NULL AS [Manufacturer's Name],
		NULL AS [Substance Expiration Date],
		NULL AS [Lot Number],
		NULL AS [Induration],
		NULL AS [Struck Out By],
		NULL AS [Strike Out Reason],
		NULL AS [Strike Out Date],
		NULL AS Notes

	SELECT 
		@status_text = RTRIM(LEFT('Stored Procedure failed with Error Code : ' 
                              + CAST(ERROR_NUMBER() AS VARCHAR(10)) 
                              + ', Line Number : ' 
                              + CAST(ERROR_LINE() AS VARCHAR(10)) 
                              + ', Description : ' + ERROR_MESSAGE(), 3000) 
                   ),
		 @status_code = 1;

	SELECT @status_code as status_code, @status_text as status_text;
END CATCH;
END;
GO

GRANT EXECUTE ON reporting.bdl_sproc_ImmunizationRateSummary TO PUBLIC
GO


GO

print 'G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.bdl_sproc_ImmunizationRateSummary.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.bdl_sproc_ImmunizationRateSummary.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_etl_FactImmunization_extClientLocationDelta.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

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


/*-- ======================================================================================== 
-- CORE-39639    Add cte_imm to remove duplicates in immunization_extract
--
-- Written By:          Maria Fradkin, Mike Levine
-- Reviewed By:
--
-- Script Type:         DDL
-- Target DB Type:      Client
-- Target ENVIRONMENT:  BOTH
--
-- 
-- Re-Runable:          YES
--
-- Description of Script : Extract Client Location changes for Immunization fact
--
-- Special Instruction:
--
-- Sample script:
--DECALRE @loop bit
--EXEC  reporting.sproc_etl_FactImmunization_extClientLocationDelta @start_commit_ts = 0, @end_commit_ts = 10, @batch = 10, @loop =  @loop OUTPUT;
--
--	Revision History:
--	Date                User            JIRA          Description
--	2018, October 26    Maria Fradkin   CORE-22705    Initial script to create sproc_etl_FactImmunization_extClientLocationDelta Procedure
--	2019, April 18      Mike Levine     CORE-39639    Add cte_imm to remove duplicates in immunization_extract
--  2019, December 6	Ritch Moore		CORE-57812	  Add cvx_code_id column
--
--======================================================================================================================*/
IF EXISTS(SELECT 1 FROM sys.procedures WHERE name = 'sproc_etl_FactImmunization_extClientLocationDelta')
BEGIN
	DROP PROCEDURE reporting.sproc_etl_FactImmunization_extClientLocationDelta  
END
GO

IF EXISTS(SELECT 1 FROM sys.procedures WHERE name = 'sproc_etl_FactImmunization_extClientLocationDelta')
BEGIN
	DROP PROCEDURE reporting.sproc_etl_FactImmunization_extClientLocationDelta  
END
GO

CREATE  PROCEDURE reporting.sproc_etl_FactImmunization_extClientLocationDelta
	@start_commit_ts bigint,
	@end_commit_ts bigint,
	@batch int, 
	@loop bit = 0 OUTPUT  

AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE 
		@v_start_commit_ts bigint = @start_commit_ts,
		@v_end_commit_ts bigint = @end_commit_ts,
		@last_commit_ts bigint = @start_commit_ts - 1;

	DECLARE @TB_2step TABLE(std_immunization_id INT NOT NULL);
	
	INSERT @TB_2step(std_immunization_id) VALUES (5);
	
	SET @loop = 1;

	WITH cte_client AS (
	
		SELECT TOP (@batch) a.client_id, a.fac_id, a.bed_id
		FROM reporting.pdl_lkp_ClientLocation a
		INNER JOIN reporting.ldl_fn_chg_LkpClientLocation(@last_commit_ts) c	
			ON c.client_id = a.client_id
		LEFT JOIN reporting.pdl_fact_immunization d
			ON d.client_id = a.client_id
		WHERE c.sys_change_version BETWEEN  @v_start_commit_ts AND @v_end_commit_ts AND d.client_id IS NULL
	),
	cte_records AS (
		SELECT
			b.std_immunization_id,
			a.fac_id,
			a.client_id,
			a.bed_id,
			CAST(FORMAT(COALESCE(c.immun_date, c.consent_date, c.created_date, 0),'yyyyMMdd') AS int) AS immun_date_id, 
			c.immun_date,
			CASE WHEN c.immunization_id IS NULL THEN 'U' ELSE ISNULL(c.consent, '') END AS consent,
			c.consent_date,
			ISNULL(c.administered_by_id, -1) AS administered_by_id,
			ISNULL(c.body_location_id, -1) AS body_location_id,
			ISNULL(c.unit_of_measure_id, -1) AS unit_of_measure_id,
			ISNULL(c.results, '') AS results,
			ISNULL(c.reason, '') AS reason,
			NULL AS reason_code_id,
			ISNULL(c.route_of_admin_id, -1) AS  route_of_admin_id,
			CASE WHEN c.immun_date IS NOT NULL THEN 'A' ELSE '0' END  AS administered,
			c.dose_amount AS dose_amount,
			ISNULL(c.consent_by, '') AS consent_by,
			ISNULL(c.immunization_id, -1) AS  immunization_id,
			ISNULL(c.manufacturer_id, -1) AS manufacturer_id,
			c.expiration_date AS expiration_date,
			ISNULL(c.lot_number, '') AS lot_number,
			c.induration AS induration,
			ISNULL(c.step, 1) AS step_id,
			NULL AS strikeout_date,
			-1 as strikeout_user_id,
			ed.provided_date AS education_provided_date,
			ed.provided_by AS education_provided_by,
			ISNULL(c.related_immunization_id, -1) AS related_immunization_id,
			ISNULL(c.cvx_code_id, -9999) AS cvx_code_id,
			ISNULL(c.notes, '') AS notes
		FROM cte_client a
		CROSS JOIN reporting.ldl_view_dim_Immunization b
		LEFT JOIN dbo.cr_client_immunization c
			ON a.client_id = c.client_id AND b.std_immunization_id=c.std_immunization_id AND c.deleted = 'N' AND c.struck_out = 0 
		LEFT JOIN dbo.cr_immunization_education ed
			ON c.immunization_id = ed.immunization_id
	),
	cte_missing_step2 AS(
		SELECT
			a.std_immunization_id,
			a.fac_id,
			a.client_id,
			a.bed_id,
			a.immun_date_id, 
			c.immun_date,
			'U' AS consent,
			NULL AS consent_date,
			ISNULL(c.administered_by_id, -1) AS administered_by_id,
			ISNULL(c.body_location_id, -1) AS body_location_id,
			ISNULL(c.unit_of_measure_id, -1) AS unit_of_measure_id,
			ISNULL(c.results, '') AS results,
			ISNULL(c.reason, '') AS reason,
			NULL AS reason_code_id,
			ISNULL(c.route_of_admin_id, -1) AS  route_of_admin_id,
			'0' AS administered,
			c.dose_amount AS dose_amount,
			ISNULL(c.consent_by, '') AS consent_by,
			ISNULL(c.immunization_id, -1) AS  immunization_id,
			ISNULL(c.manufacturer_id, -1) AS manufacturer_id,
			c.expiration_date AS expiration_date,
			ISNULL(c.lot_number, '') AS lot_number,
			c.induration AS induration,
			2 AS step_id,
			NULL AS strikeout_date,
			-1 as strikeout_user_id,
			NULL AS education_provided_date,
			NULL AS education_provided_by,
			ISNULL(a.immunization_id, -1) AS related_immunization_id,
			ISNULL(c.cvx_code_id, -9999) AS cvx_code_id,
			ISNULL(c.notes, '') AS notes
		FROM cte_records a
		LEFT JOIN dbo.cr_client_immunization c
			ON 
				a.client_id = c.client_id AND 
				a.std_immunization_id=c.std_immunization_id AND 
				c.deleted = 'N' AND 
				c.struck_out = 0 AND 
				c.related_immunization_id = a.immunization_id AND 
				c.step = 2
		WHERE a.step_id = 1 AND c.immunization_id IS NULL AND EXISTS(SELECT 1 FROM @TB_2step t WHERE t.std_immunization_id = a.std_immunization_id)
	),
	 cte_imm AS (
		SELECT 
				immunization_id
			, strikeout_date
			, strikeout_reason_id
			, sec_user_audit_id
			, ROW_NUMBER() OVER (PARTITION BY immunization_id ORDER BY strikeout_date DESC) AS rn
		FROM dbo.immunization_strikeout
	),
	cte_struck_outs AS (	
		SELECT
			b.std_immunization_id,
			a.fac_id,
			a.client_id,
			a.bed_id,
			CAST(FORMAT(COALESCE(st.strikeout_date, 0),'yyyyMMdd') AS int) AS immun_date_id, 
			c.immun_date,
			'S' AS consent,
			c.consent_date,
			ISNULL(c.administered_by_id, -1) AS administered_by_id,
			ISNULL(c.body_location_id, -1) AS body_location_id,
			ISNULL(c.unit_of_measure_id, -1) AS unit_of_measure_id,
			ISNULL(c.results, '') AS results,
			CAST(st.strikeout_reason_id AS varchar(10)) AS reason,
			NULL AS reason_code_id,
			ISNULL(c.route_of_admin_id, -1) AS  route_of_admin_id,
			'0' AS administered,
			c.dose_amount AS dose_amount,
			ISNULL(c.consent_by, '') AS consent_by,
			ISNULL(c.immunization_id, -1) AS  immunization_id,
			ISNULL(c.manufacturer_id, -1) AS manufacturer_id,
			c.expiration_date AS expiration_date,
			ISNULL(c.lot_number, '') AS lot_number,
			c.induration AS induration,
			ISNULL(c.step, 1) AS step_id,
			st.strikeout_date AS strikeout_date,
			u.userid AS strikeout_user_id,
			ed.provided_date AS education_provided_date,
			ed.provided_by AS education_provided_by,
			ISNULL(c.related_immunization_id, -1) AS related_immunization_id,
			ISNULL(c.cvx_code_id, -9999) AS cvx_code_id,
			ISNULL(c.notes, '') AS notes
		FROM cte_client a
		CROSS JOIN reporting.ldl_view_dim_Immunization b
		INNER JOIN dbo.cr_client_immunization c
			ON a.client_id = c.client_id AND b.std_immunization_id=c.std_immunization_id AND c.deleted = 'N' AND c.struck_out = 1
		INNER JOIN (SELECT immunization_id, strikeout_date, strikeout_reason_id, sec_user_audit_id 
								FROM cte_imm WHERE rn = 1) AS st
			ON c.immunization_id = st.immunization_id
		LEFT JOIN dbo.cr_immunization_education ed
			ON c.immunization_id = ed.immunization_id
		LEFT JOIN dbo.cp_sec_user_audit u
			ON st.sec_user_audit_id = u.cp_sec_user_audit_id
	)
	INSERT INTO reporting.pdl_fact_Immunization_staging WITH(TABLOCK)(
		std_immunization_id,
		fac_id,
		client_id,
		bed_id,
		immun_date_id,
		immun_date,
		consent,
		consent_date,
		administered_by_id,
		body_location_id,
		unit_of_measure_id,
		results,
		reason,
		reason_code_id,
		route_of_admin_id,
		administered,
		dose_amount,
		consent_by,
		immunization_id,
		manufacturer_id,
		expiration_date,
		lot_number,
		induration,
		step_id,
		strikeout_date,
		strikeout_user_id,
		education_provided_date,
		education_provided_by,
		related_immunization_id,
		cvx_code_id,
		notes
	)
	SELECT
		std_immunization_id,
		fac_id,
		client_id,
		bed_id,
		immun_date_id,
		immun_date,
		consent,
		consent_date,
		administered_by_id,
		body_location_id,
		unit_of_measure_id,
		results,
		reason,
		reason_code_id,
		route_of_admin_id,
		administered,
		dose_amount,
		consent_by,
		immunization_id,
		manufacturer_id,
		expiration_date,
		lot_number,
		induration,
		step_id,
		strikeout_date,
		strikeout_user_id,
		education_provided_date,
		education_provided_by,
		related_immunization_id,
		cvx_code_id,
		notes
	FROM cte_records
	UNION ALL	--adding missing second steps
	SELECT
		std_immunization_id,
		fac_id,
		client_id,
		bed_id,
		immun_date_id,
		immun_date,
		consent,
		consent_date,
		administered_by_id,
		body_location_id,
		unit_of_measure_id,
		results,
		reason,
		reason_code_id,
		route_of_admin_id,
		administered,
		dose_amount,
		consent_by,
		immunization_id,
		manufacturer_id,
		expiration_date,
		lot_number,
		induration,
		step_id,
		strikeout_date,
		strikeout_user_id,
		education_provided_date,
		education_provided_by,
		related_immunization_id,
		cvx_code_id,
		notes
	FROM cte_missing_step2
	UNION ALL -- adding struck outs
	SELECT
		std_immunization_id,
		fac_id,
		client_id,
		bed_id,
		immun_date_id,
		immun_date,
		consent,
		consent_date,
		administered_by_id,
		body_location_id,
		unit_of_measure_id,
		results,
		reason,
		reason_code_id,
		route_of_admin_id,
		administered,
		dose_amount,
		consent_by,
		immunization_id,
		manufacturer_id,
		expiration_date,
		lot_number,
		induration,
		step_id,
		strikeout_date,
		strikeout_user_id,
		education_provided_date,
		education_provided_by,
		related_immunization_id,
		cvx_code_id,
		notes
	FROM cte_struck_outs;

	IF	@@ROWCOUNT = 0 
	BEGIN
		SELECT @loop = 0;
	END;

RETURN;
END
GO

GRANT EXEC ON reporting.sproc_etl_FactImmunization_extClientLocationDelta to public
GO


GO

print 'G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_etl_FactImmunization_extClientLocationDelta.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_etl_FactImmunization_extClientLocationDelta.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_etl_FactImmunization_extCrClientImmunizationDelta.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

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


/*-- ======================================================================================== 
-- CORE-39639    Add cte_imm to remove duplicates in immunization_extract
--
-- Written By:          Maria Fradkin, Mike Levine
-- Reviewed By:
--
-- Script Type:         DDL
-- Target DB Type:      Client
-- Target ENVIRONMENT:  BOTH
--
-- Re-Runable:          YES
--
-- Description of Script : Extract dbo.Cr_Client_Immunization changes for Immunization fact
--
-- Special Instruction:
--
--	Revision History:
--	Date                User            JIRA          Description
--	2018, October 26    Maria Fradkin   CORE-22705    Initial script to create sproc_etl_FactImmunization_extClientLocationDelta
--	2019, April 18      Mike Levine     CORE-39639    Add cte_imm to remove duplicates in immunization_extract
--  2019, December 6	Ritch Moore		CORE-57812	  Add cvx_code_id column
--
--======================================================================================================================*/
IF EXISTS(SELECT 1 FROM sys.procedures WHERE name = 'sproc_etl_FactImmunization_extCrClientImmunizationDelta')
BEGIN
	DROP PROCEDURE reporting.sproc_etl_FactImmunization_extCrClientImmunizationDelta  
END
GO

IF EXISTS(SELECT 1 FROM sys.procedures WHERE name = 'sproc_etl_FactImmunization_extCrClientImmunizationDelta')
BEGIN
	DROP PROCEDURE reporting.sproc_etl_FactImmunization_extCrClientImmunizationDelta  
END
GO

CREATE  PROCEDURE reporting.sproc_etl_FactImmunization_extCrClientImmunizationDelta
	@start_commit_ts bigint,
	@end_commit_ts bigint,
	@last_commit_ts bigint

AS
BEGIN
	DECLARE 
		@v_start_commit_ts bigint = @start_commit_ts,
		@v_end_commit_ts bigint = @end_commit_ts;

	DECLARE @TB_2step TABLE(std_immunization_id INT NOT NULL);
	
	INSERT @TB_2step(std_immunization_id) VALUES (5);

	INSERT INTO reporting.pdl_fact_Immunization_staging WITH(TABLOCK)(
		std_immunization_id,
		fac_id,
		client_id,
		bed_id,
		immun_date_id,
		immun_date,
		consent,
		consent_date,
		administered_by_id,
		body_location_id,
		unit_of_measure_id,
		results,
		reason,
		reason_code_id,
		route_of_admin_id,
		administered,
		dose_amount,
		consent_by,
		immunization_id,
		manufacturer_id,
		expiration_date,
		lot_number,
		induration,
		step_id,
		strikeout_date,
		strikeout_user_id,
		education_provided_date,
		education_provided_by,
		related_immunization_id,
		to_delete, 
		rn,
		cvx_code_id,
		notes
	)
	SELECT 
		c.std_immunization_id,
		a.fac_id,
		a.client_id,
		a.bed_id,
		CAST(FORMAT(COALESCE(c.immun_date, c.consent_date, c.created_date, 0),'yyyyMMdd') AS int) AS immun_date_id, 
		c.immun_date,
		CASE WHEN  c.immunization_id IS NULL THEN 'U' ELSE ISNULL(c.consent, '') END AS consent,
		consent_date,
		ISNULL(c.administered_by_id, -1) AS administered_by_id,
		ISNULL(c.body_location_id, -1) AS body_location_id,
		ISNULL(c.unit_of_measure_id, -1) AS unit_of_measure_id,
		ISNULL(c.results, '') AS results,
		ISNULL(c.reason, '') AS reason,
		NULL AS reason_code_id,
		ISNULL(c.route_of_admin_id, -1) AS  route_of_admin_id,
		CASE WHEN c.immun_date IS NOT NULL THEN 'A' ELSE '0' END  AS administered,
		c.dose_amount AS dose_amount,
		ISNULL(c.consent_by, '') AS consent_by,
		ISNULL(c.immunization_id, -1) AS  immunization_id,
		ISNULL(c.manufacturer_id, -1) AS manufacturer_id,
		c.expiration_date AS expiration_date,
		ISNULL(c.lot_number, '') AS lot_number,
		c.induration AS induration,
		ISNULL(c.step, 1) AS step_id,
		NULL AS strikeout_date,
		-1 as strikeout_user_id,
		ed.provided_date AS education_provided_date,
		ed.provided_by AS education_provided_by,
		ISNULL(c.related_immunization_id, -1) AS related_immunization_id,
		0 to_delete, 
		0 rn,
		ISNULL(c.cvx_code_id, -9999) AS cvx_code_id,
		ISNULL(c.notes, '') AS notes
	FROM reporting.ldl_fn_chg_CrClientImmunization(@last_commit_ts)  b
	INNER JOIN dbo.cr_client_immunization c
		ON c.immunization_id = b.immunization_id
	INNER JOIN  reporting.pdl_lkp_ClientLocation a
		ON a.client_id = c.client_id
	LEFT JOIN dbo.cr_immunization_education ed
		ON c.immunization_id = ed.immunization_id
	WHERE 
		b.sys_change_version BETWEEN  @v_start_commit_ts AND @v_end_commit_ts AND 
		c.deleted = 'N' AND 
		c.struck_out = 0
	UNION ALL -- add a record for each client X std_immunization if everything has been "struck out" from the fact
	SELECT
		c.std_immunization_id,
		a.fac_id,
		a.client_id,
		a.bed_id,
		19000101 AS immun_date_id, 
		NULL AS immun_date,
		'U' AS consent,
		NULL AS consent_date,
		-1 AS administered_by_id,
		-1 AS body_location_id,
		-1 AS unit_of_measure_id,
		'' AS results,
		'' AS reason,
		NULL AS reason_code_id,
		-1 AS  route_of_admin_id,
		'O' AS administered,
		NULL dose_amount,
		'' AS consent_by,
		-1 AS  immunization_id,
		-1 AS manufacturer_id,
		NULL AS expiration_date,
		'' AS lot_number,
		NULL AS induration,
		1 AS step_id,
		NULL AS strikeout_date,
		-1 as strikeout_user_id,
		NULL AS education_provided_date,
		NULL AS education_provided_by,
		-1 AS related_immunization_id,
		1 to_delete, 
		1 rn,
		-9999 cvx_code_id,
		'' AS notes
	FROM reporting.ldl_fn_chg_CrClientImmunization(@last_commit_ts)  b
	INNER JOIN dbo.cr_client_immunization c
		ON c.immunization_id = b.immunization_id
	INNER JOIN  reporting.pdl_lkp_ClientLocation a
		ON a.client_id = c.client_id
	LEFT JOIN dbo.cr_client_immunization c_good
		ON
			c.client_id = c_good.client_id AND
			c.std_immunization_id = c_good.std_immunization_id AND
			c_good.deleted = 'N' AND
			c_good.struck_out = 0 AND
			ISNULL(c_good.step, 1) = 1
	WHERE 
		b.sys_change_version BETWEEN  @v_start_commit_ts AND @v_end_commit_ts AND 
		c.deleted = 'N' AND 
		c.struck_out = 1 AND 
		c_good.immunization_id IS NULL 
	GROUP BY c.std_immunization_id,	a.fac_id, a.client_id, a.bed_id;

WITH cte_imm
AS
	(SELECT 
			immunization_id
		, strikeout_date
		, strikeout_reason_id
		, sec_user_audit_id
		, ROW_NUMBER() OVER (PARTITION BY immunization_id ORDER BY strikeout_date DESC) AS rn
	FROM dbo.immunization_strikeout
	)
	INSERT INTO reporting.pdl_fact_Immunization_staging WITH(TABLOCK)(
		std_immunization_id,
		fac_id,
		client_id,
		bed_id,
		immun_date_id,
		immun_date,
		consent,
		consent_date,
		administered_by_id,
		body_location_id,
		unit_of_measure_id,
		results,
		reason,
		reason_code_id,
		route_of_admin_id,
		administered,
		dose_amount,
		consent_by,
		immunization_id,
		manufacturer_id,
		expiration_date,
		lot_number,
		induration,
		step_id,
		strikeout_date,
		strikeout_user_id,
		education_provided_date,
		education_provided_by,
		related_immunization_id,
		to_delete, 
		rn,
		cvx_code_id,
		notes
	)
	--add missing second steps
	SELECT
		a.std_immunization_id,
		a.fac_id,
		a.client_id,
		a.bed_id,
		a.immun_date_id, 
		c.immun_date,
		'U' AS consent,
		NULL AS consent_date,
		ISNULL(c.administered_by_id, -1) AS administered_by_id,
		ISNULL(c.body_location_id, -1) AS body_location_id,
		ISNULL(c.unit_of_measure_id, -1) AS unit_of_measure_id,
		ISNULL(c.results, '') AS results,
		ISNULL(c.reason, '') AS reason,
		NULL AS reason_code_id,
		ISNULL(c.route_of_admin_id, -1) AS  route_of_admin_id,
		'0' AS administered,
		c.dose_amount AS dose_amount,
		ISNULL(c.consent_by, '') AS consent_by,
		ISNULL(c.immunization_id, -1) AS  immunization_id,
		ISNULL(c.manufacturer_id, -1) AS manufacturer_id,
		c.expiration_date AS expiration_date,
		ISNULL(c.lot_number, '') AS lot_number,
		c.induration AS induration,
		2 AS step_id,
		NULL AS strikeout_date,
		-1 as strikeout_user_id,
		NULL AS education_provided_date,
		NULL AS education_provided_by,
		ISNULL(a.immunization_id, -1) AS related_immunization_id,
		0 to_delete, 
		0 rn,
		ISNULL(c.cvx_code_id, -9999) AS cvx_code_id,
		ISNULL(c.notes, '') AS notes
	FROM reporting.pdl_fact_Immunization_staging a
	LEFT JOIN dbo.cr_client_immunization c
		ON 
			a.client_id = c.client_id AND 
			a.std_immunization_id=c.std_immunization_id AND 
			c.deleted = 'N' AND 
			c.struck_out = 0 AND 
			c.related_immunization_id = a.immunization_id AND 
			c.step = 2
	WHERE 
		a.step_id = 1 AND 
		c.immunization_id IS NULL AND 
		EXISTS(SELECT 1 FROM @TB_2step t WHERE t.std_immunization_id = a.std_immunization_id)

	UNION ALL -- adding struck outs
	SELECT
		c.std_immunization_id,
		a.fac_id,
		a.client_id,
		a.bed_id,
		CAST(FORMAT(COALESCE(st.strikeout_date, 0),'yyyyMMdd') AS int) AS immun_date_id, 
		c.immun_date,
		'S' AS consent,
		consent_date,
		ISNULL(c.administered_by_id, -1) AS administered_by_id,
		ISNULL(c.body_location_id, -1) AS body_location_id,
		ISNULL(c.unit_of_measure_id, -1) AS unit_of_measure_id,
		ISNULL(c.results, '') AS results,
		ISNULL(CAST(st.strikeout_reason_id AS varchar(10)), '')  AS reason,
		NULL AS reason_code_id,
		ISNULL(c.route_of_admin_id, -1) AS  route_of_admin_id,
		'0'  AS administered,
		c.dose_amount AS dose_amount,
		ISNULL(c.consent_by, '') AS consent_by,
		ISNULL(c.immunization_id, -1) AS  immunization_id,
		ISNULL(c.manufacturer_id, -1) AS manufacturer_id,
		c.expiration_date AS expiration_date,
		ISNULL(c.lot_number, '') AS lot_number,
		c.induration AS induration,
		ISNULL(c.step, 1) AS step_id,
		st.strikeout_date AS strikeout_date,
		u.userid AS strikeout_user_id,
		ed.provided_date AS education_provided_date,
		ed.provided_by AS education_provided_by,
		ISNULL(c.related_immunization_id, -1) AS related_immunization_id,
		0 to_delete, 
		0 rn,
		ISNULL(c.cvx_code_id, -9999) AS cvx_code_id,
		ISNULL(c.notes, '') AS notes
	FROM reporting.ldl_fn_chg_CrClientImmunization(@last_commit_ts)  b
	INNER JOIN dbo.cr_client_immunization c
		ON c.immunization_id = b.immunization_id
	INNER JOIN  reporting.pdl_lkp_ClientLocation a
		ON a.client_id = c.client_id
	LEFT JOIN dbo.cr_immunization_education ed
		ON c.immunization_id = ed.immunization_id
	INNER JOIN (SELECT immunization_id, strikeout_date, strikeout_reason_id, sec_user_audit_id 
							FROM cte_imm WHERE rn = 1) AS st
		ON c.immunization_id = st.immunization_id
	LEFT JOIN dbo.cp_sec_user_audit u
		ON st.sec_user_audit_id = u.cp_sec_user_audit_id
	WHERE 
		b.sys_change_version BETWEEN  @v_start_commit_ts AND @v_end_commit_ts AND 
		c.deleted = 'N' AND 
		c.struck_out = 1;
	
	INSERT INTO reporting.pdl_fact_Immunization_staging WITH(TABLOCK)(
		std_immunization_id,
		fac_id,
		client_id,
		bed_id,
		immun_date_id,
		immun_date,
		consent,
		consent_date,
		administered_by_id,
		body_location_id,
		unit_of_measure_id,
		results,
		reason,
		reason_code_id,
		route_of_admin_id,
		administered,
		dose_amount,
		consent_by,
		immunization_id,
		manufacturer_id,
		expiration_date,
		lot_number,
		induration,
		step_id,
		strikeout_date,
		strikeout_user_id,
		education_provided_date,
		education_provided_by,
		related_immunization_id,
		to_delete, 
		rn,
		cvx_code_id,
		notes
	)
	--add struck out 2d steps as missing second steps (where no 1st step is modified)
	SELECT
		c.std_immunization_id,
		c.fac_id,
		c.client_id,
		c.bed_id,
		c.immun_date_id, 
		NULL AS immun_date,
		'U' AS consent,
		NULL AS consent_date,
		-1 AS administered_by_id,
		-1 AS body_location_id,
		-1 AS unit_of_measure_id,
		'' AS results,
		'' AS reason,
		NULL AS reason_code_id,
		-1 AS  route_of_admin_id,
		'O' AS administered,
		NULL dose_amount,
		'' AS consent_by,
		-1 AS  immunization_id,
		-1 AS manufacturer_id,
		NULL AS expiration_date,
		'' AS lot_number,
		NULL AS induration,
		2 AS step_id,
		NULL AS strikeout_date,
		-1 as strikeout_user_id,
		NULL AS education_provided_date,
		NULL AS education_provided_by,
		ISNULL(c.related_immunization_id, -1) AS related_immunization_id,
		0 to_delete, 
		0 rn,
		ISNULL(c.cvx_code_id, -9999) AS cvx_code_id,
		ISNULL(c.notes, '') AS notes
	FROM reporting.pdl_fact_Immunization_staging c
	LEFT JOIN reporting.pdl_fact_Immunization_staging a
		ON c.related_immunization_id = a.immunization_id  
	WHERE 
		c.consent = 'S' AND 
		c.step_id = 2 AND 
		a.immunization_id IS NULL AND 
		EXISTS(SELECT 1 FROM @TB_2step t WHERE t.std_immunization_id = c.std_immunization_id);

END
GO

GRANT EXEC ON reporting.sproc_etl_FactImmunization_extCrClientImmunizationDelta to public
GO


GO

print 'G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_etl_FactImmunization_extCrClientImmunizationDelta.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_etl_FactImmunization_extCrClientImmunizationDelta.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_etl_FactImmunization_extCrStdImmunizationDelta.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

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


/*-- ======================================================================================== 
-- CORE-39639:          Add cte_imm to remove duplicates in immunization_extract
--
-- Written By:          Maria Fradkin, Mike Levine
-- Reviewed By:
--
-- Script Type:         DDL
-- Target DB Type:      Client
-- Target ENVIRONMENT:  BOTH  
--
-- Re-Runable:          YES
--
-- Description of Script : Extract dbo.Cr_Std_Immunization changes for Immunization fact
--
-- Special Instruction:
--
-- Sample script:
--DECALRE @last_id int 100 = 0,  @loop bit = 0
			EXEC reporting.sproc_etl_FactImmunization_extCrStdImmunizationDelta 
				@start_commit_ts = 0, 
				@end_commit_ts = 10, 
				@last_commit_ts = 10,  
				@first_id = 1, 
				@last_id = @last_id OUTPUT,
				@loop =  @loop OUTPUT; 
--
--	Revision History:
--	Date                User            JIRA          Description
--	2018, October 26    Maria Fradkin   CORE-22705    Initial script to create sproc_etl_FactImmunization_extCrStdImmunizationDelta
--	2019, April 18      Mike Levine     CORE-39639    Add cte_imm to remove duplicates in immunization_extract
--
--======================================================================================================================*/
IF EXISTS(SELECT 1 FROM sys.procedures WHERE name = 'sproc_etl_FactImmunization_extCrStdImmunizationDelta')
BEGIN
	DROP PROCEDURE reporting.sproc_etl_FactImmunization_extCrStdImmunizationDelta  
END
GO

IF EXISTS(SELECT 1 FROM sys.procedures WHERE name = 'sproc_etl_FactImmunization_extCrStdImmunizationDelta')
BEGIN
	DROP PROCEDURE reporting.sproc_etl_FactImmunization_extCrStdImmunizationDelta  
END
GO

CREATE  PROCEDURE reporting.sproc_etl_FactImmunization_extCrStdImmunizationDelta
	@start_commit_ts bigint,
	@end_commit_ts bigint,
	@last_commit_ts bigint,
	@first_id int, 
	@last_id int OUTPUT,
	@loop bit = 0 OUTPUT  

AS
BEGIN
	DECLARE 
		@v_start_commit_ts bigint = @start_commit_ts,
		@v_end_commit_ts bigint = @end_commit_ts,
		@v_first_id int = @first_id, 
		@v_last_id int = @last_id;

	DECLARE @TB_2step TABLE(std_immunization_id INT NOT NULL);
	
	INSERT @TB_2step(std_immunization_id) VALUES (5);

	SET @loop = 1;
	IF NOT EXISTS (SELECT 1 FROM reporting.ldl_fn_chg_CrStdImmunization(@last_commit_ts) WHERE sys_change_version BETWEEN  @v_start_commit_ts AND @v_end_commit_ts AND SYS_CHANGE_OPERATION = 'I')
	BEGIN
		SET @loop = 0;
		RETURN;
	END; 

	WITH cte_records AS (
		SELECT
			b.std_immunization_id,
			a.fac_id,
			a.client_id,
			a.bed_id,
			CAST(FORMAT(COALESCE(c.immun_date, c.consent_date, c.created_date, 0),'yyyyMMdd') AS int) AS immun_date_id, 
			c.immun_date,
			CASE WHEN  c.immunization_id IS NULL THEN 'U' ELSE ISNULL(c.consent, '') END AS consent,
			consent_date,
			ISNULL(c.administered_by_id, -1) AS administered_by_id,
			ISNULL(c.body_location_id, -1) AS body_location_id,
			ISNULL(c.unit_of_measure_id, -1) AS unit_of_measure_id,
			ISNULL(c.results, '') AS results,
			ISNULL(c.reason, '') AS reason,
			NULL AS reason_code_id,
			ISNULL(c.route_of_admin_id, -1) AS  route_of_admin_id,
			CASE WHEN c.immun_date IS NOT NULL THEN 'A' ELSE 'O' END  AS administered,
			c.dose_amount AS dose_amount,
			ISNULL(c.consent_by, '') AS consent_by,
			ISNULL(c.immunization_id, -1) AS  immunization_id,
			ISNULL(c.manufacturer_id, -1) AS manufacturer_id,
			c.expiration_date AS expiration_date,
			ISNULL(c.lot_number, '') AS lot_number,
			c.induration AS induration,
			ISNULL(c.step, 1) AS step_id,
			NULL AS strikeout_date,
			-1 as strikeout_user_id,
			ed.provided_date AS education_provided_date,
			ISNULL(ed.provided_by, '') AS education_provided_by,
			ISNULL(c.related_immunization_id, -1) AS related_immunization_id,
			ISNULL(c.notes, '') AS notes
		FROM  reporting.pdl_lkp_ClientLocation a
		CROSS JOIN reporting.ldl_fn_chg_CrStdImmunization(@last_commit_ts)  b
		LEFT JOIN dbo.cr_client_immunization c
			ON a.client_id = c.client_id and b.std_immunization_id=c.std_immunization_id and  c.deleted = 'N' and c.struck_out = 0 -- exclude struck out or deleted immunization records
		LEFT JOIN dbo.cr_immunization_education ed
			ON c.immunization_id = ed.immunization_id
		WHERE 
			a.client_id > @v_first_id AND a.client_id <= @v_last_id AND
			b.sys_change_version BETWEEN  @v_start_commit_ts AND @v_end_commit_ts AND b.SYS_CHANGE_OPERATION = 'I'  -- we only care about the inserts
	),
	cte_missing_step2 AS(		
		SELECT
			a.std_immunization_id,
			a.fac_id,
			a.client_id,
			a.bed_id,
			a.immun_date_id, 
			c.immun_date,
			'U' AS consent,
			NULL AS consent_date,
			ISNULL(c.administered_by_id, -1) AS administered_by_id,
			ISNULL(c.body_location_id, -1) AS body_location_id,
			ISNULL(c.unit_of_measure_id, -1) AS unit_of_measure_id,
			ISNULL(c.results, '') AS results,
			ISNULL(c.reason, '') AS reason,
			NULL AS reason_code_id,
			ISNULL(c.route_of_admin_id, -1) AS  route_of_admin_id,
			'0' administered,
			c.dose_amount AS dose_amount,
			ISNULL(c.consent_by, '') AS consent_by,
			ISNULL(c.immunization_id, -1) AS  immunization_id,
			ISNULL(c.manufacturer_id, -1) AS manufacturer_id,
			c.expiration_date AS expiration_date,
			ISNULL(c.lot_number, '') AS lot_number,
			c.induration AS induration,
			2 AS step_id,
			NULL AS strikeout_date,
			-1 as strikeout_user_id,
			NULL AS education_provided_date,
			NULL AS education_provided_by,
			ISNULL(a.immunization_id, -1) AS related_immunization_id,
			ISNULL(c.notes, '') AS notes
		FROM cte_records a
		LEFT JOIN dbo.cr_client_immunization c
			ON 
				a.client_id = c.client_id AND 
				a.std_immunization_id=c.std_immunization_id AND 
				c.deleted = 'N' AND 
				c.struck_out = 0 AND 
				c.related_immunization_id = a.immunization_id AND 
				c.step = 2
		WHERE a.step_id = 1 AND c.immunization_id IS NULL AND EXISTS(SELECT 1 FROM @TB_2step t WHERE t.std_immunization_id = a.std_immunization_id)
	),
	cte_imm AS (
		SELECT 
				immunization_id
			, strikeout_date
			, strikeout_reason_id
			, sec_user_audit_id
			, ROW_NUMBER() OVER (PARTITION BY immunization_id ORDER BY strikeout_date DESC) AS rn
		FROM dbo.immunization_strikeout
	),
	cte_struck_outs AS (	
		SELECT
			b.std_immunization_id,
			a.fac_id,
			a.client_id,
			a.bed_id,
			CAST(FORMAT(COALESCE(st.strikeout_date, 0),'yyyyMMdd') AS int) AS immun_date_id, 
			c.immun_date,
			'S' AS consent,
			consent_date,
			ISNULL(c.administered_by_id, -1) AS administered_by_id,
			ISNULL(c.body_location_id, -1) AS body_location_id,
			ISNULL(c.unit_of_measure_id, -1) AS unit_of_measure_id,
			ISNULL(c.results, '') AS results,
			CAST(st.strikeout_reason_id AS varchar(10))  AS reason,
			NULL AS reason_code_id,
			ISNULL(c.route_of_admin_id, -1) AS  route_of_admin_id,
			'0' AS administered,
			c.dose_amount AS dose_amount,
			ISNULL(c.consent_by, '') AS consent_by,
			ISNULL(c.immunization_id, -1) AS  immunization_id,
			ISNULL(c.manufacturer_id, -1) AS manufacturer_id,
			c.expiration_date AS expiration_date,
			ISNULL(c.lot_number, '') AS lot_number,
			c.induration AS induration,
			ISNULL(c.step, 1) AS step_id,
			st.strikeout_date AS strikeout_date,
			u.userid AS strikeout_user_id,
			ed.provided_date AS education_provided_date,
			ed.provided_by AS education_provided_by,
			ISNULL(c.related_immunization_id, -1) AS related_immunization_id,
			ISNULL(c.notes, '') AS notes
		FROM reporting.pdl_lkp_ClientLocation a
		CROSS JOIN reporting.ldl_fn_chg_CrStdImmunization(@last_commit_ts)  b
		INNER JOIN dbo.cr_client_immunization c
			ON a.client_id = c.client_id AND b.std_immunization_id=c.std_immunization_id AND c.deleted = 'N' AND c.struck_out = 1
		INNER JOIN (SELECT immunization_id, strikeout_date, strikeout_reason_id, sec_user_audit_id 
								FROM cte_imm WHERE rn = 1) AS st
			ON c.immunization_id = st.immunization_id
		LEFT JOIN dbo.cr_immunization_education ed
			ON c.immunization_id = ed.immunization_id
		LEFT JOIN dbo.cp_sec_user_audit u
			ON st.sec_user_audit_id = u.cp_sec_user_audit_id
		WHERE 
			a.client_id > @v_first_id AND a.client_id <= @v_last_id AND
			b.sys_change_version BETWEEN  @v_start_commit_ts AND @v_end_commit_ts AND b.SYS_CHANGE_OPERATION = 'I'
	)
	INSERT INTO reporting.pdl_fact_Immunization_staging WITH(TABLOCK)(
		std_immunization_id,
		fac_id,
		client_id,
		bed_id,
		immun_date_id,
		immun_date,
		consent,
		consent_date,
		administered_by_id,
		body_location_id,
		unit_of_measure_id,
		results,
		reason,
		reason_code_id,
		route_of_admin_id,
		administered,
		dose_amount,
		consent_by,
		immunization_id,
		manufacturer_id,
		expiration_date,
		lot_number,
		induration,
		step_id,
		strikeout_date,
		strikeout_user_id,
		education_provided_date,
		education_provided_by,
		related_immunization_id,
		notes
	)
	SELECT
		std_immunization_id,
		fac_id,
		client_id,
		bed_id,
		immun_date_id,
		immun_date,
		consent,
		consent_date,
		administered_by_id,
		body_location_id,
		unit_of_measure_id,
		results,
		reason,
		reason_code_id,
		route_of_admin_id,
		administered,
		dose_amount,
		consent_by,
		immunization_id,
		manufacturer_id,
		expiration_date,
		lot_number,
		induration,
		step_id,
		strikeout_date,
		strikeout_user_id,
		education_provided_date,
		education_provided_by,
		related_immunization_id,
		notes
	FROM cte_records
	UNION ALL	--adding missing second steps
	SELECT
		std_immunization_id,
		fac_id,
		client_id,
		bed_id,
		immun_date_id,
		immun_date,
		consent,
		consent_date,
		administered_by_id,
		body_location_id,
		unit_of_measure_id,
		results,
		reason,
		reason_code_id,
		route_of_admin_id,
		administered,
		dose_amount,
		consent_by,
		immunization_id,
		manufacturer_id,
		expiration_date,
		lot_number,
		induration,
		step_id,
		strikeout_date,
		strikeout_user_id,
		education_provided_date,
		education_provided_by,
		related_immunization_id,
		notes
	FROM cte_missing_step2
	UNION ALL -- adding struck outs
	SELECT
		std_immunization_id,
		fac_id,
		client_id,
		bed_id,
		immun_date_id,
		immun_date,
		consent,
		consent_date,
		administered_by_id,
		body_location_id,
		unit_of_measure_id,
		results,
		reason,
		reason_code_id,
		route_of_admin_id,
		administered,
		dose_amount,
		consent_by,
		immunization_id,
		manufacturer_id,
		expiration_date,
		lot_number,
		induration,
		step_id,
		strikeout_date,
		strikeout_user_id,
		education_provided_date,
		education_provided_by,
		related_immunization_id,
		notes
	FROM cte_struck_outs;	

	IF	@@ROWCOUNT = 0 
	BEGIN
		SET @last_id = ISNULL((SELECT MIN(client_id) FROM reporting.pdl_lkp_ClientLocation WHERE client_id > @v_last_id) - 1, @v_last_id)
		IF(@last_id = @v_last_id)
		BEGIN
			SELECT @loop = 0;
		END;
	END;

END
GO

GRANT EXEC ON reporting.sproc_etl_FactImmunization_extCrStdImmunizationDelta to public
GO



GO

print 'G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_etl_FactImmunization_extCrStdImmunizationDelta.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_etl_FactImmunization_extCrStdImmunizationDelta.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_etl_FactImmunization_extract.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

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
-- CORE-39639:          Add cte_imm to remove duplicates in immunization_extract
--
-- Written By:          Maria Fradkin, Mike Levine
-- Reviewed By:
--
-- Script Type:         DDL
-- Target DB Type:      Client
-- Target ENVIRONMENT:  BOTH
--
-- Re-Runable:          YES
--
-- Description of Script :  Modify sproc_etl_FactImmunization_extract for initial load
--
-- Special Instruction:
--
--	Revision History:
--	Date                User            JIRA          Description
--	2018, October 26    Maria Fradkin   CORE-22701    Initial script
--	2019, February 7    Mike Levine     CORE-31767    Update sproc_etl_FactImmunization_extract
--	2019, April 18      Mike Levine     CORE-39639    Add cte_imm to remove duplicates in immunization_extract
--  2019, December 3	Ritch Moore		CORE-57812	  Add cvx_code_id column
--
-- ================================================================================================================
IF EXISTS(SELECT 1 FROM sys.procedures WHERE name = 'sproc_extract_FactImmunization')
  BEGIN
    DROP PROCEDURE reporting.sproc_extract_FactImmunization  
  END
GO

IF EXISTS(SELECT 1 FROM sys.procedures WHERE name = 'sproc_etl_FactImmunization_extract')
  BEGIN
    DROP PROCEDURE reporting.sproc_etl_FactImmunization_extract  
  END
GO

CREATE  PROCEDURE reporting.sproc_etl_FactImmunization_extract 
	@first_id int, 
	@last_id int,
	@loop bit = 0 OUTPUT  
AS
BEGIN

	SET NOCOUNT ON;

	SET @loop = 1;

-- Actual records and missing step 1
WITH cte_imm
AS
	(SELECT 
			immunization_id
		, strikeout_date
		, strikeout_reason_id
		, sec_user_audit_id
		, ROW_NUMBER() OVER (PARTITION BY immunization_id ORDER BY strikeout_date DESC) AS rn
	FROM dbo.immunization_strikeout
	)
, cte_adm_missing_step1
AS (
	SELECT
		b.std_immunization_id,
		a.fac_id,
		a.client_id,
		a.bed_id,
		CAST(FORMAT(COALESCE(c.immun_date, c.consent_date, c.created_date, 0),'yyyyMMdd') AS int) AS immun_date_id,
		c.immun_date, 
		CASE WHEN  c.immunization_id IS NULL THEN 'U' ELSE ISNULL(c.consent, '') END AS consent,
		c.consent_date,
		ISNULL(c.administered_by_id, -1) AS administered_by_id,
		ISNULL(c.body_location_id, -1) AS body_location_id,
		ISNULL(c.unit_of_measure_id, -1) AS unit_of_measure_id,
		ISNULL(c.results, '') AS results,
		ISNULL(c.reason, '') AS reason,
		ISNULL(c.route_of_admin_id, -1) AS  route_of_admin_id,
		CASE WHEN c.immun_date IS NOT NULL THEN 'A' ELSE 'O' END  AS administered,
		c.dose_amount AS dose_amount,
		ISNULL(consent_by, '') AS consent_by,
		ISNULL(c.manufacturer_id, -1) AS manufacturer_id,
		c.expiration_date,
		ISNULL(c.lot_number, '') AS lot_number,
		c.induration,
		ISNULL(c.step, 1) AS step_id,
		NULL AS strikeout_date,
		-1 AS strikeout_user_id,
		e.provided_date AS education_provided_date,
		e.provided_by AS education_provided_by,
		ISNULL(c.immunization_id, -1) AS  immunization_id,
		ISNULL(c.related_immunization_id, -1) AS related_immunization_id,
		ISNULL(c.cvx_code_id, -9999) AS cvx_code_id,
		ISNULL(c.notes, '') AS notes
	FROM reporting.pdl_lkp_ClientLocation a
		CROSS JOIN reporting.ldl_view_dim_Immunization b
		LEFT OUTER JOIN dbo.cr_client_immunization c
			ON    a.client_id = c.client_id 
				AND b.std_immunization_id = c.std_immunization_id
				AND c.deleted = 'N' -- exclude deleted
				AND c.struck_out = 0 -- exclude strikeouts
		LEFT OUTER JOIN [dbo].[cr_immunization_education] e
			ON c.immunization_id = e.immunization_id
		WHERE a.client_id > @first_id AND  a.client_id <= @last_id

	UNION ALL

	SELECT -- add strikeouts
		b.std_immunization_id,
		a.fac_id,
		a.client_id,
		a.bed_id,
		CAST(FORMAT(COALESCE(s.strikeout_date, 0),'yyyyMMdd') AS int) AS immun_date_id,
		c.immun_date,
		'S' AS consent,
		c.consent_date,
		ISNULL(c.administered_by_id, -1) AS administered_by_id,
		ISNULL(c.body_location_id, -1) AS body_location_id,
		ISNULL(c.unit_of_measure_id, -1) AS unit_of_measure_id,
		ISNULL(c.results, '') AS results,
		CASE WHEN s.immunization_id IS NOT NULL THEN CAST(s.strikeout_reason_id AS VARCHAR(10)) ELSE ISNULL(c.reason, '') END AS reason,
		ISNULL(c.route_of_admin_id, -1) AS  route_of_admin_id,
		'O' AS administered,
		c.dose_amount AS dose_amount,
		'' AS consent_by,
		ISNULL(c.manufacturer_id, -1) AS manufacturer_id,
		c.expiration_date,
		ISNULL(c.lot_number, '') AS lot_number,
		c.induration,
		ISNULL(c.step, 1) AS step_id,
		s.strikeout_date,
		ISNULL(u.userid, -1) AS strikeout_user_id,
		e.provided_date AS education_provided_date,
		e.provided_by AS education_provided_by,
		ISNULL(c.immunization_id, -1) AS  immunization_id,
		ISNULL(c.related_immunization_id, -1) AS related_immunization_id,
		ISNULL(c.cvx_code_id, -9999) AS cvx_code_id,
		ISNULL(c.notes, '') AS notes
	FROM reporting.pdl_lkp_ClientLocation a
		CROSS JOIN reporting.ldl_view_dim_Immunization b
		INNER JOIN dbo.cr_client_immunization c
			ON    a.client_id = c.client_id 
				AND b.std_immunization_id = c.std_immunization_id
				AND c.deleted = 'N'
				AND c.struck_out = 1
		INNER JOIN (SELECT immunization_id, strikeout_date, strikeout_reason_id, sec_user_audit_id 
								FROM cte_imm WHERE rn = 1) AS s
			ON c.immunization_id = s.immunization_id
		LEFT OUTER JOIN dbo.cp_sec_user_audit u
			ON s.sec_user_audit_id = u.cp_sec_user_audit_id
		LEFT OUTER JOIN [dbo].[cr_immunization_education] e
			ON c.immunization_id = e.immunization_id
		WHERE a.client_id > @first_id AND  a.client_id <= @last_id
	)
-- Adding step 2 fakes
, cte_missing_step2 -- fake step 2 for administered step 1 not having step 2
AS ( 
	SELECT mc1.client_id, mc1.std_immunization_id, mc1.fac_id
		, mc1.immunization_id
		,	CAST(FORMAT(COALESCE(mc1.immun_date, mc1.consent_date, mc1.created_date, 0),'yyyyMMdd') AS int) AS immun_date_id
		, mc1.immun_date, mc1.cvx_code_id
	FROM dbo.cr_client_immunization mc1
		LEFT OUTER JOIN dbo.cr_client_immunization mc2
			ON mc1.immunization_id = mc2.related_immunization_id AND mc2.step = 2 AND mc2.deleted = 'N' AND mc2.struck_out = 0
	WHERE		(mc1.std_immunization_id = 5 AND mc1.step = 1 AND mc1.deleted = 'N' AND mc1.struck_out = 0)
			AND (mc2.immunization_id IS NULL)
			AND (mc1.client_id > @first_id AND mc1.client_id <= @last_id)

	UNION ALL

	SELECT mc3.client_id, mc3.std_immunization_id, mc3.fac_id -- fake step 2 for missing step 1
		, mc3.immunization_id
		, mc3.immun_date_id
		, mc3.immun_date
		, mc3.cvx_code_id
	FROM cte_adm_missing_step1 mc3
	WHERE		(mc3.std_immunization_id = 5 AND mc3.step_id = 1 AND mc3.immunization_id = -1)
)
, cte_missing_step2_extended
AS (
	SELECT
		mc1.std_immunization_id,
		mc1.fac_id,
		mc1.client_id,
		ISNULL(ml.bed_id, -1) AS bed_id,
		mc1.immun_date_id,
		mc1.immun_date,
		'U' AS consent, -- "Immunization Record Does Not Exist"
		NULL  AS consent_date,
		-1 AS administered_by_id,
		-1 AS body_location_id,
		-1 AS unit_of_measure_id,
		'' AS results,
		'' AS reason,
		-1 AS  route_of_admin_id,
		'O' AS administered,
		NULL AS dose_amount,
		'' AS consent_by,
		-1 AS manufacturer_id,
		NULL  AS expiration_date,
		'' AS lot_number,
		NULL AS induration,
		2 AS step_id,
		NULL AS strikeout_date,
		-1 AS strikeout_user_id,
		NULL AS education_provided_date,
		NULL AS education_provided_by,
		-1 AS immunization_id,
		mc1.immunization_id AS related_immunization_id,
		mc1.cvx_code_id,
		'' AS notes
	FROM cte_missing_step2 mc1
		INNER JOIN reporting.pdl_lkp_ClientLocation ml
			ON mc1.client_id = ml.client_id -- client_id is PK in pdl_lkp_ClientLocation
	)
	INSERT INTO reporting.pdl_fact_Immunization_staging WITH(TABLOCK)
	(
		std_immunization_id,
		fac_id,
		client_id,
		bed_id,
		immun_date_id,
		immun_date,
		consent,
		consent_date,
		administered_by_id,
		body_location_id,
		unit_of_measure_id,
		results,
		reason,
		route_of_admin_id,
		administered,
		dose_amount,
		consent_by,
		manufacturer_id,
		expiration_date,
		lot_number,
		induration,
		step_id,
		strikeout_date,
		strikeout_user_id,
		education_provided_date,
		education_provided_by,
		immunization_id,
		related_immunization_id,
		cvx_code_id,
		notes
	)
SELECT *
FROM cte_adm_missing_step1

UNION ALL

SELECT *
FROM cte_missing_step2_extended

-- --------
	IF	@@ROWCOUNT = 0 
		AND NOT EXISTS
			(
				SELECT 1 
				FROM reporting.pdl_lkp_ClientLocation a	
					CROSS JOIN reporting.ldl_view_dim_Immunization b
				WHERE a.client_id > @last_id
			)
	BEGIN
		SELECT @loop = 0;
	END;

RETURN;
END
GO

GRANT EXEC ON reporting.sproc_etl_FactImmunization_extract to public
GO


GO

print 'G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_etl_FactImmunization_extract.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_etl_FactImmunization_extract.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_etl_FactImmunization_load.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

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


/*-- ======================================================================================== 
-- CORE-39658 Add update of fact table record with new client_id

-- Reviewed By:
-- Written By:          Maria Fradkin, Mike Levine
--
-- Script Type:         DDL
-- Target DB Type:      Client
-- Target ENVIRONMENT:  BOTH
--
-- Re-Runable:          YES
--
-- Description of Script : Load Immunization data
--
-- Special Instruction:
--
-- Sample script: EXEC  reporting.sproc_etl_FactImmunization_load @etl_job_run_id = 0;
--
--	Revision History:
--	Date                User            JIRA          Description
--	2018, October 26    Maria Fradkin   CORE-22701    Initial script to create sproc_etl_FactImmunization_load Procedure
--	2019, April 18      Mike Levine     CORE-39658    Add update of fact table record with new client_id when immunization is reassigned with another client_id
--  2019, December 3	Ritch Moore		CORE-57812	  Add cvx_code_id column
--  2020, March 12		Hemanth B		CORE-64451	  Update Immunization delta stored proc to record number of rows affected

--======================================================================================================================*/
IF EXISTS(SELECT 1 FROM sys.procedures WHERE name = 'sproc_etl_FactImmunization_load')
BEGIN
	DROP PROCEDURE reporting.sproc_etl_FactImmunization_load  
END
GO

CREATE  PROCEDURE reporting.sproc_etl_FactImmunization_load
	@etl_job_run_id bigint,
	@is_delta BIT = 0
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @rows_affected INT = 0;
	--delete "fake" for those incoming "good" records
	DELETE  t
	FROM reporting.pdl_fact_Immunization t
	INNER JOIN reporting.pdl_fact_Immunization_staging s
		ON t.std_immunization_id = s.std_immunization_id AND t.client_id = s.client_id AND t.step_id = s.step_id
	WHERE t.immunization_id = -1 AND s.immunization_id <> -1 AND t.step_id = 1 AND s.consent_code_id <> 6;
	
	SET	@rows_affected = @@ROWCOUNT;
	--delete "fake" step 2s for those incoming "good" step 2s records
	DELETE  t
	FROM reporting.pdl_fact_Immunization t
	INNER JOIN reporting.pdl_fact_Immunization_staging s
		ON t.std_immunization_id = s.std_immunization_id AND t.client_id = s.client_id AND t.step_id = s.step_id AND s.related_immunization_id = t.related_immunization_id
	WHERE t.immunization_id = -1 AND s.immunization_id <> -1 AND t.step_id = 2 AND s.consent_code_id <> 6;
	
	SET	@rows_affected += @@ROWCOUNT;
	--delete orphaned "fake" step 2s
	DELETE  t
	FROM reporting.pdl_fact_Immunization t
	INNER JOIN reporting.pdl_fact_Immunization_staging s
		ON t.std_immunization_id = s.std_immunization_id AND t.client_id = s.client_id AND t.step_id = s.step_id 
	WHERE t.immunization_id = -1 AND t.related_immunization_id = -1 AND t.step_id = 2 AND  s.related_immunization_id <> -1 AND s.consent_code_id <> 6;

	SET	@rows_affected += @@ROWCOUNT;
	--fixing merge for 1st step of TB two steps when new related_immunization_id is changing
	UPDATE t
	SET t.related_immunization_id = s.related_immunization_id
	FROM reporting.pdl_fact_Immunization_staging s
	INNER JOIN reporting.pdl_fact_Immunization t
		ON t.std_immunization_id= s.std_immunization_id AND t.client_id = s.client_id AND t.immunization_id = s.immunization_id AND t.step_id = s.step_id 
	WHERE s.step_id = 1 AND t.related_immunization_id <> s.related_immunization_id;

	-- Update client_id if immunization_id was re-associated with another client
	UPDATE f
	SET f.client_id = s.client_id
	FROM reporting.pdl_fact_Immunization_staging s
		JOIN reporting.pdl_fact_Immunization f
				ON  s.std_immunization_id				= f.std_immunization_id 
				AND s.immunization_id						= f.immunization_id 
				AND s.related_immunization_id		= f.related_immunization_id 
				AND s.step_id										= f.step_id
	WHERE 	s.immunization_id <> -1
			AND f.immunization_id <> -1
			AND f.client_id				<> s.client_id;

	--main merge
	MERGE INTO reporting.pdl_fact_Immunization t
	USING reporting.pdl_fact_Immunization_staging s
		ON (t.std_immunization_id= s.std_immunization_id AND t.client_id = s.client_id AND t.immunization_id = s.immunization_id AND t.related_immunization_id = s.related_immunization_id AND t.step_id = s.step_id)
	WHEN MATCHED AND s.to_delete = 1 THEN 
		DELETE 
	WHEN MATCHED THEN   
		UPDATE SET
			t.std_immunization_id = s.std_immunization_id,
			t.fac_id = s.fac_id,
			t.client_id = s.client_id,
			t.bed_id = s.bed_id,
			t.immun_date_id = s.immun_date_id,
			t.immun_date = s.immun_date,
			t.consent_code_id = s.consent_code_id,
			t.consent_date = s.consent_date,
			t.administered_by_id = s.administered_by_id,
			t.body_location_id = s.body_location_id,
			t.unit_of_measure_id = s.unit_of_measure_id,
			t.result_code_id = s.result_code_id,
			t.reason_code_id = s.reason_code_id,
			t.route_of_admin_id = s.route_of_admin_id,
			t.administered_id = s.administered_id,
			t.dose_amount = s.dose_amount,
			t.consent_by = s.consent_by,
			t.manufacturer_id = s.manufacturer_id,
			t.expiration_date = s.expiration_date,
			t.lot_number = s.lot_number,
			t.induration = s.induration,
			t.step_id = s.step_id,
			t.strikeout_date = s.strikeout_date,
			t.strikeout_user_id = s.strikeout_user_id,
			t.education_provided_date = s.education_provided_date,
			t.education_provided_by = s.education_provided_by,
			t.immunization_id = s.immunization_id,
			t.related_immunization_id = s.related_immunization_id,
			t.etl_created_date = getdate(),
			t.etl_created_by_job_run_id = @etl_job_run_id,
			t.cvx_code_id = s.cvx_code_id,
			t.notes = s.notes
	WHEN NOT MATCHED THEN  
		INSERT(
			std_immunization_id,
			fac_id,
			client_id,
			bed_id,
			immun_date_id,
			immun_date,
			consent_code_id,
			consent_date,
			administered_by_id,
			body_location_id,
			unit_of_measure_id,
			result_code_id,
			reason_code_id,
			route_of_admin_id,
			administered_id,
			dose_amount,
			consent_by,
			manufacturer_id,
			expiration_date,
			lot_number,
			induration,
			step_id,
			strikeout_date,
			strikeout_user_id,
			education_provided_date,
			education_provided_by,
			immunization_id,
			related_immunization_id,
			etl_created_date,
			etl_created_by_job_run_id,
			cvx_code_id,
			notes
		)
		VALUES (		
			s.std_immunization_id,
			s.fac_id,
			s.client_id,
			s.bed_id,
			s.immun_date_id,
			s.immun_date,
			s.consent_code_id,
			s.consent_date,
			s.administered_by_id,
			s.body_location_id,
			s.unit_of_measure_id,
			s.result_code_id,
			s.reason_code_id,
			s.route_of_admin_id,
			s.administered_id,
			s.dose_amount,
			s.consent_by,
			s.manufacturer_id,
			s.expiration_date,
			s.lot_number,
			s.induration,
			s.step_id,
			s.strikeout_date,
			s.strikeout_user_id,
			s.education_provided_date,
			s.education_provided_by,
			s.immunization_id,
			s.related_immunization_id,
			GETDATE(),
			@etl_job_run_id,
			s.cvx_code_id,
			s.notes
	);
	SET	@rows_affected += @@ROWCOUNT;

	--we need to keep one record for each client X std_immunization if everything has been "deleted" from the fact
	INSERT INTO reporting.pdl_fact_Immunization(
		std_immunization_id,
		fac_id,
		client_id,
		bed_id,
		immun_date_id,
		immun_date,
		consent_code_id,
		consent_date,
		administered_by_id,
		body_location_id,
		unit_of_measure_id,
		result_code_id,
		reason_code_id,
		route_of_admin_id,
		administered_id,
		dose_amount,
		consent_by,
		manufacturer_id,
		expiration_date,
		lot_number,
		induration,
		step_id,
		strikeout_date,
		strikeout_user_id,
		education_provided_date,
		education_provided_by,
		immunization_id,
		related_immunization_id,
		etl_created_date,
		etl_created_by_job_run_id,
		cvx_code_id,
		notes
	)
	SELECT 
		s.std_immunization_id,
		s.fac_id,
		s.client_id,
		s.bed_id,
		s.immun_date_id,
		s.immun_date,
		s.consent_code_id,
		s.consent_date,
		s.administered_by_id,
		s.body_location_id,
		s.unit_of_measure_id,
		s.result_code_id,
		s.reason_code_id,
		s.route_of_admin_id,
		s.administered_id,
		s.dose_amount,
		s.consent_by,
		s.manufacturer_id,
		s.expiration_date,
		s.lot_number,
		s.induration,
		s.step_id,
		s.strikeout_date,
		s.strikeout_user_id,
		s.education_provided_date,
		s.education_provided_by,
		-1 AS immunization_id,
		-1 AS related_immunization_id,
		GETDATE(),
		@etl_job_run_id,
		s.cvx_code_id,
		s.notes
	FROM reporting.pdl_fact_Immunization_staging s
	LEFT JOIN reporting.pdl_fact_Immunization t
		ON s.client_id = t.client_id AND s.std_immunization_id = t.std_immunization_id
	WHERE s.to_delete = 1 AND s.rn = 1 AND t.client_id IS NULL;	
	SET	@rows_affected += @@ROWCOUNT;

	/*Updating actual row count*/
	IF @is_delta = 1
	BEGIN
		EXEC [reporting].sproc_etl_UpdateDeltaJobRowCount	@etl_delta_run_id = @etl_job_run_id,
															@row_count = @rows_affected;
	END
RETURN;
END
GO

GRANT EXEC ON reporting.sproc_etl_FactImmunization_load to public
GO


GO

print 'G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_etl_FactImmunization_load.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_etl_FactImmunization_load.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_etl_FactImmunization_validation.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

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
-- CORE-42197  Revise the process for monitoring ETL data consistency, to export JSON ready data
--
-- Written By:           Mike Levine
-- Reviewed By:          
--
-- Script Type:          DDL
-- Target DB Type:       CLIENT
-- Target ENVIRONMENT:   BOTH
--
--
-- Re-Runable:           YES
--
-- Staging Recommendations/Warnings:
--
-- Description of Script Function:  Test query/sproc for Immunization subject area
--    
-- Special Instruction: fake missing records, available in DM fact table, are filtered out for the purpose of comparison with the source transaction table
-- 
-- Sample execution script:
--      DECLARE @error_time  DATETIME, @error_server_name VARCHAR(128), @error_db_name VARCHAR(128), @error_subject_area_name VARCHAR(200), @error_source_table_name VARCHAR(128)
--      , @error_destination_table_name VARCHAR(128), @error_row_count_to_validate BIGINT, @error_failed_total_row_count INT, @error_failed_key_row_count INT
--      , @error_failed_non_key_row_count INT, @error_last_successful_etl DATETIME, @error_24hr_etl_runs_count INT, @validation_is_success BIT, @validation_message VARCHAR(8000) 
--     EXEC reporting.sproc_etl_FactImmunization_validation @etl_validation_run_id = 1190507, @debug = 'Y', @is_success = @validation_is_success OUTPUT, @error_message_out = @validation_message OUTPUT
--        , @server_name = @error_server_name OUTPUT, @db_name = @error_db_name  OUTPUT, @subject_area_name = @error_subject_area_name  OUTPUT, @source_table_name = @error_source_table_name OUTPUT
--        , @destination_table_name = @error_destination_table_name OUTPUT, @row_count_to_validate = @error_row_count_to_validate OUTPUT, @failed_total_row_count = @error_failed_total_row_count OUTPUT
--        , @failed_key_row_count =  @error_failed_key_row_count OUTPUT, @failed_non_key_row_count = @error_failed_non_key_row_count OUTPUT
--        , @last_successful_etl = @error_last_successful_etl OUTPUT, @24hr_etl_runs_count = @error_24hr_etl_runs_count OUTPUT;
--
-- Revision History:
-- Date					User          Description
-- 2019, April 19		Mike Levine   CORE-36996  Initial version of immunization test query improvement
-- 2019, May 16			Mike Levine   CORE-40973  Create stored procedure to evaluate immunization data consistency
-- 2019, May 29			Mike Levine   CORE-42197  Revise the process for monitoring ETL data consistency, to export JSON ready data
-- 2019, October 8		Ritch Moore   CORE-53206  Split message logging into 2 logs, event message and validation
-- 2019, November 14	Ritch Moore   CORE-55732  Add missing column checks, to cover all columns
-- 2019, December 4		Ritch Moore   CORE-57812  Add cvx_code_id column
-- =================================================================================
DROP PROCEDURE IF EXISTS reporting.sproc_etl_FactImmunization_validation;
GO

CREATE PROCEDURE reporting.sproc_etl_FactImmunization_validation	
    @etl_validation_run_id    BIGINT		 = Null
  , @is_success               BIT            =  1 OUTPUT
  , @error_message_out        VARCHAR(8000)  = '' OUTPUT
  , @debug                    CHAR(1)        = 'N'      -- N: result message written to event log, Y: result message displayed for debugging, A: automation result of 1 returned for success and 0 for failure
-- FOR OUTPUT: declare parameters for JSON formatting
  , @server_name              VARCHAR(128)   = '' OUTPUT
  , @db_name                  VARCHAR(128)   = ''   OUTPUT
  , @subject_area_name        VARCHAR(200)   = ''   OUTPUT
  , @source_table_name        VARCHAR(128)   = ''   OUTPUT
  , @destination_table_name   VARCHAR(128)   = ''   OUTPUT
  , @row_count_to_validate    BIGINT         = 0 OUTPUT
  , @failed_total_row_count   INT            = 0 OUTPUT
  , @failed_key_row_count     INT            = 0 OUTPUT
  , @failed_non_key_row_count INT            = 0 OUTPUT
  , @last_successful_etl      DATETIME       = '' OUTPUT
  , @24hr_etl_runs_count      INT            = 0 OUTPUT
AS

BEGIN
  SET NOCOUNT ON;

  BEGIN TRY

  DROP TABLE IF EXISTS #SourceOLTPFact;
  DROP TABLE IF EXISTS #SourceOLTPClientLocation;
  DROP TABLE IF EXISTS #TargetDMFact;

  DECLARE 
      @date                         DATETIME      = GETDATE()
    , @cntSourceOLTPClientLocation  BIGINT        = 0
    , @cntSourceOLTPFact            BIGINT        = 0
    , @cntTargetDMFact              BIGINT        = 0
    , @cntSrcToTrgKeyDifference     INT           = 0
    , @cntSrcToTrgNonKeyDifference  INT           = 0
    , @validation_error_message     VARCHAR(8000) = ''
    , @system_user                  NVARCHAR(256) = SUSER_NAME()
    , @bntEtlLastRunId              BIGINT
    , @dtEtlLastRunTime             DATETIME
    , @bntEtlLastRunCommit          BIGINT

	IF @etl_validation_run_id IS NULL
		SET @etl_validation_run_id = NEXT VALUE FOR reporting.validation_job_run_id;

-- FOR OUTPUT: Define parameters for JSON formatting
  SELECT
    @server_name                  = @@SERVERNAME 
  , @db_name                      = DB_NAME()
  , @subject_area_name            = 'Immunization'      
  , @source_table_name            = 'dbo.cr_client_immunization'
  , @destination_table_name       = 'reporting.pdl_fact_Immunization';

-- -----------
  -- 0. Get end timestamp for the latest etl data load
  ;WITH cte_run_id
  AS (
  SELECT etl_delta_run_id AS etl_run_id, end_timestamp, end_commit_ts
  FROM reporting.etl_delta_run
  WHERE etl_id = 3 AND process_status = 'Finished'

  UNION ALL

  SELECT initial_load_run_id AS etl_run_id, end_date AS end_timestamp, 1 AS end_commit_ts
  FROM reporting.etl_initial_load_run
  WHERE etl_id = 3 AND process_status = 'Finished'
  )
  , cte_max_run_id
  AS (
  SELECT etl_run_id, end_timestamp, end_commit_ts, ROW_NUMBER() OVER(ORDER BY etl_run_id DESC) AS rn
  FROM cte_run_id
  )
  SELECT @bntEtlLastRunId = etl_run_id, @dtEtlLastRunTime = end_timestamp, @bntEtlLastRunCommit = end_commit_ts
  FROM cte_max_run_id
  WHERE rn = 1;

-- Log latest etl_run to etl_validation_log
  SET @is_success = 1;
  SET @validation_error_message = 'Immunization validation: Latest etl run id to be validated is ' + CONVERT(VARCHAR, @bntEtlLastRunId) + ' with run time of ' + CONVERT(VARCHAR, @dtEtlLastRunTime) + '.';
  
  EXEC [reporting].[sproc_etl_addValidationLog] @vetl_run_id = @etl_validation_run_id, @vmessage = @validation_error_message, @vis_success = @is_success, @vrun_user = @system_user, @vetl_id = 3;

-- FOR OUTPUT: Set latest etl run time
  SET @last_successful_etl = @dtEtlLastRunTime;

-- FOR OUTPUT: Get number of successful delta runs in the last 24 hours
  DECLARE @dtValidationStart DATETIME = GETDATE();

  SELECT @24hr_etl_runs_count = COUNT(*)
  FROM reporting.etl_delta_run
  WHERE etl_id = 3 
    AND process_status = 'Finished'
    AND end_timestamp >= DATEADD(day, -1, @dtValidationStart);

-- --------
-- 1. LOAD #SourceOLTPClientLocation
  SELECT client_id, fac_id, bed_id, census_id
  INTO #SourceOLTPClientLocation
  FROM reporting.pdl_lkp_ClientLocation
  WHERE change_id <= @bntEtlLastRunCommit  OR change_id IS NULL;

  SELECT @cntSourceOLTPClientLocation = COUNT(*) FROM #SourceOLTPClientLocation;

-- Log into etl_validation_log
  SET @validation_error_message = 'Immunization validation: Record count for table reporting.pdl_lkp_ClientLocation is ' + CONVERT(VARCHAR, @cntSourceOLTPClientLocation) + '.';
  EXEC [reporting].[sproc_etl_addValidationLog] @vetl_run_id = @etl_validation_run_id, @vmessage = @validation_error_message, @vis_success = @is_success, @vrun_user = @system_user, @vetl_id = 3;

  IF @debug = 'Y'
    SELECT 'Record count for table reporting.pdl_lkp_ClientLocation is ' + CONVERT(VARCHAR, @cntSourceOLTPClientLocation) + '.';

-- --------
-- 2. LOAD #SourceOLTPFact - from source transaction data
  SELECT c.client_id, c.std_immunization_id, c.immunization_id, c.related_immunization_id, c.step
    , c.consent_date, ISNULL(c.notes, '') AS notes
    , ISNULL(c.lot_number, '') AS lot_number, ISNULL(c.administered_by_id, -1) AS administered_by_id, ISNULL(c.body_location_id, -1) AS body_location_id
    , c.fac_id, c.struck_out, ISNULL(c.route_of_admin_id, -1) AS route_of_admin_id, ISNULL(c.unit_of_measure_id, -1) AS unit_of_measure_id
    , ISNULL(c.manufacturer_id, -1) AS manufacturer_id, ISNULL(consent_by, '') AS consent_by, c.dose_amount, ISNULL(c.induration,-1) AS induration
	, ISNULL(c.expiration_date,'1/1/1900') AS expiration_date, ISNULL(c.immun_date,'1/1/1900') AS immun_date
	, CASE WHEN  c.immunization_id IS NULL THEN 'U' WHEN strk.strikeout_date IS NOT NULL THEN 'S' ELSE ISNULL(d.short_description, '') END AS consent 
	, CASE WHEN tb.std_immunization_id IS NOT NULL AND c.immun_date IS NOT NULL AND c.results = '' THEN 'R' ELSE c.results END AS results
	, CASE WHEN strk.immunization_id IS NOT NULL THEN strkres.short_description ELSE ISNULL(res.short_description,'') END AS reason
	, ISNULL(edu.provided_date,'1/1/1900') AS education_provided_date, edu.provided_by AS education_provided_by
	, strk.strikeout_date, ISNULL(u.userid, -1) AS strikeout_user_id, ISNULL(c.cvx_code_id, -9999) AS cvx_code_id
  INTO #SourceOLTPFact
  FROM dbo.cr_client_immunization c
  LEFT JOIN dbo.cr_immunization_education edu ON c.immunization_id = edu.immunization_id
  LEFT JOIN dbo.immunization_strikeout strk ON c.immunization_id = strk.immunization_id
  LEFT OUTER JOIN dbo.cp_sec_user_audit u ON strk.sec_user_audit_id = u.cp_sec_user_audit_id
  LEFT JOIN reporting.ldl_view_dim_ConsentStatusCode d ON  d.short_description = c.consent AND 
      d.admin_status = CASE WHEN c.immun_date IS NOT NULL THEN 1 ELSE 0 END
  LEFT JOIN reporting.ldl_view_dim_Immunization tb ON c.std_immunization_id = tb.std_immunization_id AND tb.[description] LIKE 'TB%'
  LEFT JOIN reporting.ldl_view_dim_ReasonStatusCode res
    ON res.short_description = c.reason
  LEFT JOIN reporting.ldl_view_dim_ReasonStatusCode strkres
    ON strkres.reason_code_id = strk.strikeout_reason_id 
  WHERE 1 = 1
    AND c.deleted = 'N'
    AND c.client_id IN (SELECT client_id FROM #SourceOLTPClientLocation)
    AND COALESCE(c.revision_date, c.created_date) <= @dtEtlLastRunTime;

  SELECT @cntSourceOLTPFact = COUNT(*) FROM #SourceOLTPFact;

-- Log into etl_validation_log
  SET @is_success = 1;
  SET @validation_error_message = 'Immunization validation: Record count for source OLTP table dbo.cr_client_immunization is ' + CONVERT(VARCHAR, @cntSourceOLTPFact) + '.';
  EXEC [reporting].[sproc_etl_addValidationLog] @vetl_run_id = @etl_validation_run_id, @vmessage = @validation_error_message, @vis_success = @is_success, @vrun_user = @system_user, @vetl_id = 3;

  IF @debug = 'Y'
    SELECT 'Record count for source OLTP table dbo.cr_client_immunization is ' + CONVERT(VARCHAR, @cntSourceOLTPFact) + '.';

-- --------
-- 3. LOAD #TargetDMFact - from target fact table
  SELECT f.client_id, f.std_immunization_id, f.immunization_id, f.related_immunization_id, f.step_id
    , f.consent_date, f.notes, f.lot_number, f.administered_by_id, f.body_location_id
    , f.fac_id, CASE WHEN f.strikeout_date IS NULL THEN 0 ELSE 1 END AS struck_out, f.route_of_admin_id, f.unit_of_measure_id, f.manufacturer_id
	, f.consent_by, f.dose_amount, ISNULL(f.induration,-1) AS induration, ISNULL(f.expiration_date,'1/1/1900') AS expiration_date
	, ISNULL(f.immun_date,'1/1/1900') AS immun_date, csc.short_description AS consent, rsc.short_description AS results
	, res.short_description AS reason, ISNULL(f.education_provided_date,'1/1/1900') AS education_provided_date, f.education_provided_by
	, ISNULL(f.strikeout_date,'1/1/1900') AS strikeout_date, ISNULL(f.strikeout_user_id,-1) AS strikeout_user_id, f.cvx_code_id
  INTO #TargetDMFact
  FROM reporting.pdl_fact_Immunization f
  INNER JOIN reporting.ldl_view_dim_ConsentStatusCode csc ON f.consent_code_id = csc.consent_code_id
  INNER JOIN reporting.ldl_view_dim_ResultStatusCode rsc ON f.result_code_id = rsc.result_code_id
  INNER JOIN reporting.ldl_view_dim_ReasonStatusCode res ON f.reason_code_id = res.reason_code_id
  WHERE f.immunization_id <> -1; -- removing fakes

  SELECT @cntTargetDMFact = COUNT(*) FROM #TargetDMFact;

-- Update flag @is_success and @validation_error_message
  IF ISNULL(@cntSourceOLTPFact, 0) = ISNULL(@cntTargetDMFact, 0)
    BEGIN
     SET @is_success = 1
     SET @validation_error_message = 'Immunization validation: Record count for target DM table reporting.pdl_fact_Immunization (without fake records) is ' + CONVERT(VARCHAR, @cntTargetDMFact) + ' and matches source OLTP table count.'
    END
  ELSE
    BEGIN
     SET @is_success = 0
     SET @validation_error_message = 'Immunization validation: Record count for target DM table reporting.pdl_fact_Immunization (without fake records) is ' + CONVERT(VARCHAR, @cntTargetDMFact) + ' and does NOT match source OLTP table count.'
    END

-- Log into etl_validation_log
 EXEC [reporting].[sproc_etl_addValidationLog] @vetl_run_id = @etl_validation_run_id, @vmessage = @validation_error_message, @vis_success = @is_success, @vrun_user = @system_user, @vetl_id = 3;

   IF @debug = 'Y'
    SELECT 'Record count for target DM table reporting.pdl_fact_Immunization (without fake records) is ' + CONVERT(VARCHAR, @cntTargetDMFact) + '.'

-- ------------------
-- 4. Check diffrences between key columns in source and target tables
/*
SELECT s.client_id, s.std_immunization_id, s.immunization_id, s.related_immunization_id, s.step
  , t.client_id AS target_client_id, t.std_immunization_id AS target_std_immunization_id, t.immunization_id AS target_immunization_id, t.related_immunization_id, t.step_id
*/
  SELECT @cntSrcToTrgKeyDifference = COUNT(*) 
  FROM
  (SELECT client_id, std_immunization_id, immunization_id, related_immunization_id, step
  FROM #SourceOLTPFact) s
    FULL OUTER JOIN
  (SELECT client_id, std_immunization_id, immunization_id, related_immunization_id, step_id
  FROM #TargetDMFact) t
    ON s.client_id = t.client_id and s.std_immunization_id = t.std_immunization_id AND s.immunization_id = t.immunization_id AND ISNULL(s.related_immunization_id, -1) = t.related_immunization_id AND ISNULL(s.step, 1) = t.step_id
  WHERE s.client_id IS NULL OR t.client_id IS NULL;

  IF @cntSrcToTrgKeyDifference = 0
    BEGIN
     SET @is_success = 1
     SET @validation_error_message = 'Immunization validation: There are no differences between key columns in source and target tables.'
    END
  ELSE
    BEGIN
     SET @is_success = 0
     SET @validation_error_message = 'Immunization validation: There are ' + CONVERT(VARCHAR, @cntSrcToTrgKeyDifference) + ' records with differences between key columns in source and target tables.'
    END

-- Log into etl_validation_log
  EXEC [reporting].[sproc_etl_addValidationLog] @vetl_run_id = @etl_validation_run_id, @vmessage = @validation_error_message, @vis_success = @is_success, @vrun_user = @system_user, @vetl_id = 3;

   IF @debug = 'Y'
    SELECT 'Record count for differences between key columns in source and target tables is ' + CONVERT(VARCHAR, @cntSrcToTrgKeyDifference) + '.'

-- ---------------
-- 5. Check diffrences between major non-key columns in source and target tables
/*
SELECT s.client_id, s.std_immunization_id, s.immunization_id, s.related_immunization_id, s.step
  , s.consent_date, s.notes, s.lot_number, s.administered_by_id, s.body_location_id, s.fac_id, s.struck_out, s.route_of_admin_id, s.unit_of_measure_id, s.manufacturer_id
  , t.client_id AS target_client_id, t.std_immunization_id AS target_std_immunization_id, t.immunization_id AS target_immunization_id, t.related_immunization_id, t.step_id
  , t.consent_date, t.notes, t.lot_number, t.administered_by_id, t.body_location_id, t.fac_id, t.struck_out, t.route_of_admin_id, t.unit_of_measure_id, t.manufacturer_id
*/
  SELECT @cntSrcToTrgNonKeyDifference = COUNT(*) 
  FROM
  (SELECT client_id, std_immunization_id, immunization_id, related_immunization_id, step
    , consent_date, notes, lot_number, administered_by_id, body_location_id, fac_id, struck_out, route_of_admin_id, unit_of_measure_id, manufacturer_id
	, consent_by, dose_amount, induration, expiration_date, immun_date, consent, results, reason
	, education_provided_date, education_provided_by, strikeout_date, strikeout_user_id, cvx_code_id
  FROM #SourceOLTPFact) s
    FULL OUTER JOIN
  (SELECT client_id, std_immunization_id, immunization_id, related_immunization_id, step_id
    , consent_date, notes, lot_number, administered_by_id, body_location_id, fac_id, struck_out, route_of_admin_id, unit_of_measure_id, manufacturer_id
	, consent_by, dose_amount, induration, expiration_date, immun_date, consent, results, reason
	, education_provided_date, education_provided_by, strikeout_date, strikeout_user_id, cvx_code_id
  FROM #TargetDMFact) t
    ON s.client_id = t.client_id and s.std_immunization_id = t.std_immunization_id AND s.immunization_id = t.immunization_id AND ISNULL(s.related_immunization_id, -1) = t.related_immunization_id AND ISNULL(s.step, 1) = t.step_id
  WHERE 1 = 1 
    AND (s.consent_date <> t.consent_date
          OR
        s.notes <> t.notes
          OR
        s.lot_number <> t.lot_number
          OR
        s.administered_by_id <> t.administered_by_id
          OR
        s.body_location_id <> t.body_location_id
          OR
        s.fac_id <> t.fac_id
          OR
        s.struck_out <> t.struck_out
          OR
        s.route_of_admin_id <> t.route_of_admin_id
          OR
        s.unit_of_measure_id <> t.unit_of_measure_id
          OR
        s.manufacturer_id <> t.manufacturer_id
		  OR
        s.consent_by <> t.consent_by
		  OR
        s.dose_amount <> t.dose_amount
		  OR
        s.induration <> t.induration
		  OR
        s.expiration_date <> t.expiration_date
		  OR
        s.immun_date <> t.immun_date
		  OR
        s.consent <> t.consent
		  OR
        s.results <> t.results
		  OR
        s.reason <> t.reason
		  OR
        s.education_provided_date <> t.education_provided_date
		  OR
        s.education_provided_by <> t.education_provided_by
		  OR
        s.strikeout_date <> t.strikeout_date
		  OR
        s.strikeout_user_id <> t.strikeout_user_id
		  OR
        s.cvx_code_id <> t.cvx_code_id	
        );

  IF @cntSrcToTrgNonKeyDifference = 0
    BEGIN
     SET @is_success = 1
     SET @validation_error_message = 'Immunization validation: There are no differences between non-key columns in source and target tables.'
    END
  ELSE
    BEGIN
     SET @is_success = 0
     SET @validation_error_message = 'Immunization validation: There are ' + CONVERT(VARCHAR, @cntSrcToTrgNonKeyDifference) + ' records with differences between non-key columns in source and target tables.'
    END

-- Log into etl_validation_log
  EXEC [reporting].[sproc_etl_addValidationLog] @vetl_run_id = @etl_validation_run_id, @vmessage = @validation_error_message, @vis_success = @is_success, @vrun_user = @system_user, @vetl_id = 3;

   IF @debug = 'Y'
    SELECT 'Record count for differences between non-key columns in source and target tables is ' + CONVERT(VARCHAR, @cntSrcToTrgNonKeyDifference) + '.'

-- --------------
-- 6. RESULTS Logging

  IF ISNULL(@cntSourceOLTPFact, 0) = ISNULL(@cntTargetDMFact, 0) AND @cntSrcToTrgKeyDifference = 0 AND @cntSrcToTrgNonKeyDifference = 0 
    SELECT 
        @validation_error_message = 'Immunization validation: SUCCESS.'
      , @is_success = 1
    ELSE 
    SELECT 
        @validation_error_message = 'Immunization validation: FAILED. ' + 
          CASE
            WHEN ISNULL(@cntSourceOLTPFact, 0) > ISNULL(@cntTargetDMFact, 0)
              THEN CONVERT(VARCHAR, ISNULL(@cntSourceOLTPFact, 0) - ISNULL(@cntTargetDMFact, 0)) + ' record(s) not loaded from source OLTP to DM fact table.'
            WHEN ISNULL(@cntSourceOLTPFact, 0) < ISNULL(@cntTargetDMFact, 0) 
              THEN 'DM fact table has ' + CONVERT(VARCHAR, ISNULL(@cntTargetDMFact, 0) - ISNULL(@cntSourceOLTPFact, 0)) + ' record(s) more than source OLTP table.' 
            ELSE ''
          END +
          CASE WHEN ISNULL(@cntSrcToTrgKeyDifference, 0) <> 0 THEN ' There are ' + CONVERT(VARCHAR, @cntSrcToTrgKeyDifference) + ' records with differences between key columns in source and target tables.' ELSE '' END +
          CASE WHEN ISNULL(@cntSrcToTrgNonKeyDifference, 0) <> 0 THEN ' There are ' + CONVERT(VARCHAR, @cntSrcToTrgNonKeyDifference) + ' records with differences between non-key columns in source and target tables.' ELSE '' END
      , @is_success = 0;

  IF @debug = 'N'
    EXEC [reporting].[sproc_etl_addValidationLog] @vetl_run_id = @etl_validation_run_id, @vmessage = @validation_error_message, @vis_success = @is_success, @vrun_user = @system_user, @vetl_id = 3;

  IF @debug = 'A'
    BEGIN
      EXEC [reporting].[sproc_etl_addValidationLog] @vetl_run_id = @etl_validation_run_id, @vmessage = @validation_error_message, @vis_success = @is_success, @vrun_user = @system_user, @vetl_id = 3;
      SELECT @is_success;
    END

  IF @debug = 'Y'
    BEGIN
      EXEC [reporting].[sproc_etl_addValidationLog] @vetl_run_id = @etl_validation_run_id, @vmessage = @validation_error_message, @vis_success = @is_success, @vrun_user = @system_user, @vetl_id = 3;
      SELECT @validation_error_message;
    END

-- FOR OUTPUT: row counts and validation message
    SELECT 
        @row_count_to_validate = @cntSourceOLTPFact
      ,  @failed_total_row_count = ABS( ISNULL(@cntSourceOLTPFact, 0) - ISNULL(@cntTargetDMFact, 0) )
      , @failed_key_row_count  = ISNULL(@cntSrcToTrgKeyDifference, 0)
      , @failed_non_key_row_count  = ISNULL(@cntSrcToTrgNonKeyDifference, 0);

    SET @error_message_out = @validation_error_message;

  END TRY

  BEGIN CATCH
    SET @validation_error_message  = 'Immunization validation: Error ' + CAST(ERROR_NUMBER() AS NVARCHAR(20)) + ' in procedure ' + ISNULL(ERROR_PROCEDURE(), '') + ' on line ' + CAST(ERROR_LINE() AS NVARCHAR(20)) + ' - ' + ERROR_MESSAGE();
    SET @is_success = 0;

    EXEC [reporting].[sproc_etl_addValidationLog] @vetl_run_id = @etl_validation_run_id, @vmessage = @validation_error_message, @vis_success = @is_success, @vrun_user = @system_user, @vetl_id = 3;

    SET @error_message_out = @validation_error_message;

  END CATCH

  SET NOCOUNT OFF;
END
GO

GRANT EXEC ON reporting.sproc_etl_FactImmunization_validation TO PUBLIC;
GO


GO

print 'G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_etl_FactImmunization_validation.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_etl_FactImmunization_validation.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

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
values ('4.4.7_G', 'upload_history')


GO

print '..\Update db version.sql --****SCRIPT DONE****'

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

GO

insert into upload_tracking (script,timestamp,upload) values ('UPLOAD END',getdate(),'4.4.7_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')