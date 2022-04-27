SET NOCOUNT ON
GO

SET DEADLOCK_PRIORITY HIGH
GO


insert into upload_tracking (script, timestamp, upload) values ('UPLOAD_START',getdate(),'4.4.9_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.bdl_sproc_EnterpriseCaseMix.sql',getdate(),'4.4.9_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

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
-- CORE-71125       :   Enterprise Case Mix Report
--						--

-- Written By:          Jay Vaghela
-- Reviewed By:
--
-- Script Type:         DML
-- Target DB Type:      Client
-- Target ENVIRONMENT:  BOTH
--
--
-- Re-Runable:          YES
--
-- Description of Script : Create stored procedure to retrieve Enterprise Case Mix report raw data
--
-- Special Instruction:
--none
--------sample script---------


DECLARE @vclient_id TableOfInt;
DECLARE @vunit_id  TableOfInt;
DECLARE @vfloor_id TableOfInt;
DECLARE @vfac_id TableOfInt;
DECLARE @vpayer_id TableOfInt;
DECLARE @vpayer_type_id TableOfInt;

insert into @vclient_id values(-1);
insert into @vunit_id values(-1);
insert into @vfloor_id values(-1);
insert into @vfac_id values(-1);
insert into @vpayer_id values(-1);
insert into @vpayer_type_id values(-1);

exec reporting.bdl_sproc_EnterpriseCaseMix
	  @group_lvl1 = 2,
	  @group_lvl2 = 4,
	  @group_lvl3 = null,
	  @group_lvl4 = null,
	  @group_lvl5 = null,
	  @group_lvl6 = null,
	  @fac_id = @vfac_id,
	  @client_id = @vclient_id,
	  @unit_id = @vunit_id ,
	  @floor_id = @vfloor_id,
	  @payer_id = @vpayer_id,
      @payer_type_id = @vpayer_type_id,
	  @current_residents_as_of = '2020-06-23',
	  @std_assess_id = 11,
	  @mds_assess_with_ard_during_from = '2020-06-01',
	  @mds_assess_with_ard_during_to = '2020-06-22',
	  @add_extension_period bit = 0,
	  @include_assessment_based_on= 1,
	  @include_rug = 1,
	  @case_mix = 'STATE'
	  @include_assessment_status bit = 0,
	  @pps_assessments = 0,
	  @include_residents_based_on_payer_as_of = 'C',
	  @exclude_residents_with_status_of = '',
	  @debug_me = 'N',
	  @status_code = Null,
	  @status_text = Null


/***********************************************************************************
Revision History:
2020-06-22	Jay Vaghela		CORE-71125	ERP: Enterprise Case Mix - Run report for all active residents with MDS 3.0 assessments

***********************************************************************************/
--======================================================================================================================*/

IF EXISTS (SELECT * FROM SYS.PROCEDURES WHERE NAME = 'bdl_sproc_EnterpriseCaseMix')
BEGIN
	DROP PROCEDURE reporting.bdl_sproc_EnterpriseCaseMix
END
GO

CREATE PROCEDURE reporting.bdl_sproc_EnterpriseCaseMix

	  @group_lvl1 int,
	  @group_lvl2 int,
	  @group_lvl3 int,
	  @group_lvl4 int,
	  @group_lvl5 int,
	  @group_lvl6 int,
	  @fac_id TableOfInt READONLY,
	  @client_id TableOfInt READONLY,
	  @unit_id TableOfInt READONLY,
	  @floor_id TableOfInt READONLY,
	  @payer_id TableOfInt READONLY,
      @payer_type_id TableOfInt READONLY,
	  @current_residents_as_of datetime,
	  @std_assess_id int,
	  @mds_assess_with_ard_during_from datetime,
	  @mds_assess_with_ard_during_to datetime,
	  @add_extension_period bit = 0,
	  @include_assessment_based_on int = 0,
	  @include_rug bit = 0,
	  @case_mix varchar(7) = 'STATE',
	  @include_assessment_status bit = 0,
	  @pps_assessments int,
	  @include_residents_based_on_payer_as_of char,
	  @exclude_residents_with_status_of varchar(15),
	  @debug_me char(1) = 'N',
	  @status_code int = 0 OUT,
	  @status_text varchar(3000) = '' OUT
AS
BEGIN
	SET NOCOUNT ON;
BEGIN TRY

    DECLARE @vall_clients bit = 0;
    DECLARE @vall_floors bit = 0;
    DECLARE @vall_units bit = 0;
    DECLARE @vall_facilities bit = 0;
    DECLARE @vall_payers bit = 0;
    DECLARE @vall_payer_types bit = 0;
    DECLARE @vcurrent_residents_as_of datetime = convert(datetime, convert(varchar(10),@current_residents_as_of, 101) + ' 23:59:59');
	DECLARE @vmds_assess_with_ard_during_from datetime = convert(datetime, convert(varchar(10),@mds_assess_with_ard_during_from, 101) + ' 00:00:00');
	DECLARE @vmds_assess_with_ard_during_to datetime = convert(datetime, convert(varchar(10),@mds_assess_with_ard_during_to, 101) + ' 23:59:59');
    DECLARE @vextended_date datetime = DATEADD(DAY, 13, @vmds_assess_with_ard_during_to);
	DECLARE @vignoreExcludeResidentsWithStatusOf bit =0;

		IF (SELECT COUNT(*) FROM @client_id) = 1
        BEGIN
            IF (SELECT id FROM @client_id) = -1
                BEGIN
                    SET @vall_clients = 1;
                END
        END

	IF (SELECT COUNT(*) FROM @floor_id) = 1
	BEGIN
		IF (SELECT id FROM @floor_id) = -1
		BEGIN
			SET @vall_floors = 1;
		END
	END

	IF (SELECT COUNT(*) FROM @fac_id) = 1
	BEGIN
		IF (SELECT id FROM @fac_id) = -1
		BEGIN
			SET @vall_facilities = 1;
		END
	END

	IF (SELECT COUNT(*) FROM @unit_id) = 1
	BEGIN
		IF (SELECT id FROM @unit_id) = -1
		BEGIN
			SET @vall_units = 1;
		END
	END

    IF (SELECT COUNT(*) FROM @payer_id) = 1
    BEGIN
        IF (SELECT id FROM @payer_id) = -1
            BEGIN
                SET @vall_payers = 1;
            END
    END

    IF (SELECT COUNT(*) FROM @payer_type_id) = 1
    BEGIN
        IF (SELECT id FROM @payer_type_id) = -1
            BEGIN
                SET @vall_payer_types = 1;
            END
    END

    IF ISNULL(@exclude_residents_with_status_of, '') = ''
	BEGIN
		SET @vignoreExcludeResidentsWithStatusOf =1;
	END

	CREATE TABLE #AssessDate (
        assess_id int,
        assess_date datetime,
        client_id int,
        fac_id int
	);

	CREATE TABLE #LeaveTypes  (status_type VARCHAR(1))
	INSERT INTO #LeaveTypes(status_type) SELECT value FROM pcc__csvToTableOfStrings(@exclude_residents_with_status_of)
    if @debug_me='Y' select * from #LeaveTypes

	insert into #AssessDate
	select a.assess_id, a.assess_date, a.client_id, a.fac_id
		from reporting.ldl_view_fact_Assessment  a
		left join reporting.ldl_view_fact_extAssessment factExtAsmt_2 on factExtAsmt_2.assess_id=a.assess_id
        left join reporting.ldl_view_dim_AssessmentStatusCode asmtStatus on asmtStatus.assess_status_code_id=a.assess_status_code_id
			 where
			 (@vall_clients = 1 OR a.client_id  in (select id from @client_id))
			--AND a.assess_type_code <> 'XX'
			AND a.std_assess_id = @std_assess_id
			AND asmtStatus.status_description NOT IN ('Inactivated', 'Completed', 'Incomplete')
			AND (@vall_facilities = 1 OR a.fac_id in (select id from @fac_id))
			AND factExtAsmt_2.locked_date <> '1900-01-01 00:00:00.000'
			AND 1 = ( CASE
			            WHEN @case_mix='STATE' and factExtAsmt_2.cmi_state IS NOT NULL then 1
			            WHEN @case_mix='FEDERAL' and factExtAsmt_2.cmi_fed IS NOT NULL then 1
		                ELSE 0
		            END)
		    AND (@std_assess_id = 11 OR ((@std_assess_id = 10 OR @std_assess_id = 13) AND factExtAsmt_2.include_cmi_state_flag = 'Y'))
			AND a.assess_date <= @vmds_assess_with_ard_during_to
			AND a.assess_date >= @vmds_assess_with_ard_during_from

        if @debug_me='Y' select * from #AssessDate

    CREATE TABLE #AssessDateWithExtension (
                                 assess_date datetime,
                                 client_id int,
    );

    insert into #AssessDateWithExtension
    select a.assess_date, a.client_id
    from reporting.ldl_view_fact_Assessment  a
             left join reporting.ldl_view_fact_extAssessment factExtAsmt_2 on factExtAsmt_2.assess_id=a.assess_id
             left join reporting.ldl_view_dim_AssessmentStatusCode asmtStatus on asmtStatus.assess_status_code_id=a.assess_status_code_id
    where
        (@vall_clients = 1 OR a.client_id  in (select id from @client_id))
      AND a.std_assess_id = @std_assess_id
      AND asmtStatus.status_description NOT IN ('Inactivated', 'Completed', 'Incomplete')
      AND (@vall_facilities = 1 OR a.fac_id in (select id from @fac_id))
      AND factExtAsmt_2.locked_date <> '1900-01-01 00:00:00.000'
      AND 1 = ( CASE
                    WHEN @case_mix='STATE' and factExtAsmt_2.cmi_state IS NOT NULL then 1
                    WHEN @case_mix='FEDERAL' and factExtAsmt_2.cmi_fed IS NOT NULL then 1
                    ELSE 0
        END)
      AND (@std_assess_id = 11 OR ((@std_assess_id = 10 OR @std_assess_id = 13) AND factExtAsmt_2.include_cmi_state_flag = 'Y'))
      AND a.assess_date <= @vextended_date
      AND a.assess_date >= @vmds_assess_with_ard_during_to

    if @debug_me='Y' select * from #AssessDateWithExtension

SELECT
		fac_grp.col1 as col1,
		fac_grp.col2 as col2,
		fac_grp.col3 as col3,
		fac_grp.col4 as col4,
		fac_grp.col5 as col5,
		fac_grp.col6 as col6,
		facility.facility_name as Facility,
        ISNULL(bedLocation.UNIT_DESC, '-') as Unit,
        concat(client.last_name, ', ' , client.first_name, ' (',client.client_id_number,')') as Resident,
		concat(bedLocation.room_desc, ' - ' , bedLocation.bed_desc) as Location,
		format(factAsmt.assess_date,'MM/dd/yyyy') as [Assess Date], -- ARD Date
		format(factExtAsmt.effective_cmi_date,'MM/dd/yyyy') as [Effective Date],
		format(factExtAsmt.completed_date,'MM/dd/yyyy') as [Z0500B Date],
        rugcode.rug_model_code as [CMI State Code],

		case when factAsmt.assess_type_code = 'XX' then 'Inactivation of ' + next_assess_reason
				else assess_reason
		end as Description,

		CASE WHEN @case_mix='STATE' then
			factExtAsmt.cmi_code_state
		ELSE
			factExtAsmt.cmi_code_fed
		END
		AS RUG,

		CASE WHEN @case_mix='STATE' then
			factExtAsmt.cmi_state
		ELSE
			factExtAsmt.cmi_fed
		END
		AS CMI,

		CASE WHEN @include_rug=1 THEN
			CASE WHEN @case_mix='STATE' then
				factExtAsmt.score2
			ELSE
				factExtAsmt.temp_cmi_code_fed
			END
		END AS [Optional Rug],

		CASE WHEN @include_rug=1 THEN
			CASE WHEN @case_mix='STATE' then
				factExtAsmt.doublescore1
			ELSE
				factExtAsmt.temp_cmi_fed
			END
		END AS [Optional CMI],

        CASE WHEN @include_assessment_status=1 THEN
            asmtStatus.status_description
        END AS [Status]

FROM reporting.ldl_view_fact_extAssessment factExtAsmt
LEFT JOIN reporting.ldl_view_dim_User sec_user on factExtAsmt.revision_by = sec_user.loginname
LEFT JOIN reporting.ldl_view_fact_Assessment factAsmt on factAsmt.assess_id = factExtAsmt.assess_id
LEFT JOIN reporting.ldl_view_dim_Client client ON factAsmt.client_id = client.client_id
left join reporting.ldl_view_dim_AssessmentType asmtType ON factAsmt.std_assess_id = asmtType.std_assess_id AND factAsmt.assess_type_code = asmtType.assess_type_code
left join reporting.ldl_view_fact_CensusItem censusItem  ON client.CURRENT_CENSUS_ID = censusItem.census_id
left join reporting.ldl_view_fact_CensusItem rate_item  ON client.current_rate_id = rate_item.census_id
LEFT JOIN reporting.ldl_view_fact_CensusItem curpayer_id ON client.client_id = curpayer_id.client_id --Done
left join reporting.ldl_view_dim_BedLocation bedLocation ON censusItem.fac_id = bedLocation.fac_id AND factAsmt.BED_ID = bedLocation.BED_ID
left join reporting.ldl_view_dim_AssessmentBatch batch ON factExtAsmt.batch_id = batch.batch_id
left join reporting.ldl_view_dim_RugCode rugcode
    ON rugcode.code = ( CASE
                            WHEN @case_mix='STATE' then factExtAsmt.cmi_code_state
			                ELSE factExtAsmt.cmi_code_fed
		            END)
left join reporting.ldl_view_dim_ArLibPayer curpayer_type ON curpayer_id.primary_payer_id = curpayer_type.payer_id
left join reporting.ldl_view_dim_ArLibPayerType system_payer_type ON curpayer_type.payer_type = system_payer_type.payer_type_desc
left join reporting.ldl_view_fact_extAssessmentPdpm assessmentPdpm ON factExtAsmt.assess_id = assessmentPdpm.assess_id
left join reporting.ldl_view_dim_Facility facility ON facility.fac_id=factAsmt.fac_id
left join reporting.ldl_view_dim_AssessmentStatusCode asmtStatus on asmtStatus.assess_status_code_id= factAsmt.assess_status_code_id
left join #AssessDate assessDate on factAsmt.assess_id = assessDate.assess_id
cross apply ( select assess_reason_description_mod + ' '
					from  reporting.ldl_view_br_AssessmentReason b
						inner join reporting.ldl_view_dim_AssessmentReason r
							on b.assess_reason_id = r.assess_reason_id
					where factAsmt.fact_assess_id = b.fact_assess_id
						order by question_key for xml path('')
					) as resxml(assess_reason)

	cross apply ( select assess_reason_description_mod + ' '
					from  reporting.ldl_view_br_AssessmentReason b
						inner join reporting.ldl_view_dim_AssessmentReason r
							on b.assess_reason_id = r.assess_reason_id
						inner join reporting.ldl_view_fact_Assessment res_fac_assess
						on res_fac_assess.assess_id = factAsmt.incorrect_assess_id

					where res_fac_assess.fact_assess_id = b.fact_assess_id
						order by question_key for xml path('')
					) as nextresxml(next_assess_reason)
INNER JOIN reporting.ldl_fn_dim_FacilityCode(@group_lvl1, @group_lvl2, @group_lvl3, @group_lvl4, @group_lvl5, @group_lvl6) fac_grp
		ON 	fac_grp.fac_id = factAsmt.fac_id
where ((factExtAsmt.LOCKED_DATE <> '1900-01-01 00:00:00.000' AND  (client.DISCHARGE_DATE > @vcurrent_residents_as_of OR client.DISCHARGE_DATE IS NULL)
    AND factAsmt.assess_date <= (CASE
                              WHEN @add_extension_period = 1 then @vextended_date
                              WHEN @add_extension_period = 0 then @vmds_assess_with_ard_during_to
        END)
    AND factAsmt.assess_date >= @vmds_assess_with_ard_during_from
	and factAsmt.STD_ASSESS_ID = @std_assess_id
	AND rugcode.std_assess_id = @std_assess_id
	AND factAsmt.CLIENT_ID <> -9999
	and curpayer_id.record_type <> 'C'
	AND (@std_assess_id = 10 OR @std_assess_id = 13 -- no rug filter for ME MDS-RCA and ME MDS-ALS
	    OR (@std_assess_id = 11
            AND factAsmt.STD_ASSESS_ID = rugcode.STD_ASSESS_ID
            AND rugcode.rug_model_code = ( CASE
                                                WHEN @case_mix='STATE' then factExtAsmt.cmi_set_state
                                                ELSE factExtAsmt.cmi_set_fed
                                        END)
            AND ((factExtAsmt.assess_ref_date >= rugcode.effective_date
                    AND (factExtAsmt.assess_ref_date < rugcode.ineffective_date or rugcode.ineffective_date is null))
                    OR (rugcode.ineffective_date is null and rugcode.effective_date is null))))
	AND curpayer_id.effective_date =
		(select max(ci98.effective_date) from reporting.ldl_view_fact_CensusItem ci98 where ci98.client_id = client.client_id
			AND ci98.record_type <> 'C'

			AND (ci98.effective_date <= case when @include_residents_based_on_payer_as_of ='C' then @vcurrent_residents_as_of else  factAsmt.assess_date end
					AND (ci98.ineffective_date > case when @include_residents_based_on_payer_as_of ='C' then @vcurrent_residents_as_of else  factAsmt.assess_date end
							or ci98.ineffective_date is null)
				)
		)

    --Include Assessments Based On and Add Extension Filter start
    AND ((@include_assessment_based_on = 0
                and ((@add_extension_period = 0 and (factAsmt.assess_date = (select max(assess_date) from #AssessDate where client_id = factAsmt.client_id)))
                    OR (@add_extension_period = 1 and (
                        ( exists (select 1 from #AssessDate where client_id = factAsmt.client_id)
                                and (factAsmt.assess_date =  (select MAX(assess_date) from #AssessDate where client_id = factAsmt.client_id)) )
                            OR (not exists (select 1 from #AssessDate where client_id = factAsmt.client_id)
                                and (factAsmt.assess_date =  (select MIN(assess_date) from #AssessDateWithExtension where client_id = factAsmt.client_id)))))))
            OR ((@include_assessment_based_on = 1
                AND ((@add_extension_period = 0 and (factAsmt.assess_date <= (select max(assess_date) from #AssessDate where client_id = factAsmt.client_id)))
                    OR (@add_extension_period = 1 and (
                        ( exists (select 1 from #AssessDate where client_id = factAsmt.client_id)
                                and (factAsmt.assess_date <= (select MAX(assess_date) from #AssessDate where client_id = factAsmt.client_id))  )
                        OR (not exists  (select 1 from #AssessDate where client_id = factAsmt.client_id)
                            and (factAsmt.assess_date <=  (select MIN(assess_date) from #AssessDateWithExtension where client_id = factAsmt.client_id)))))))))
    --Include Assessments Based On and Add Extension Filter end

    AND (@vall_payers = 1 or curpayer_id.primary_payer_id  IN (select id from @payer_id))
    AND (@vall_payer_types = 1 or system_payer_type.payer_type_id in (select id from @payer_type_id))

    AND factAsmt.assess_id in (
        select max(asmt_jsp.assess_id)
        from reporting.ldl_view_fact_Assessment asmt_jsp
            left join reporting.ldl_view_fact_extAssessment factExtAsmt_2 on factExtAsmt_2.assess_id=asmt_jsp.assess_id
            left join reporting.ldl_view_dim_AssessmentStatusCode asmtStatus on asmtStatus.assess_status_code_id=asmt_jsp.assess_status_code_id
         where asmt_jsp.client_id = factAsmt.client_id
		AND asmt_jsp.assess_type_code not in ('XX', 'NT')
        AND asmt_jsp.assess_date = factAsmt.assess_date
        AND asmtStatus.status_description NOT IN ('Inactivated', 'Completed', 'Incomplete')
        AND asmt_jsp.std_assess_id = @std_assess_id
        AND (@vall_facilities = 1 OR asmt_jsp.fac_id in (select id from @fac_id))
        and factExtAsmt_2.locked_date <> '1900-01-01 00:00:00.000'
        AND (@std_assess_id = 11 OR ((@std_assess_id = 10 OR @std_assess_id = 13) AND factExtAsmt_2.include_cmi_state_flag = 'Y'))
        and asmt_jsp.assess_date <= (CASE
                                        WHEN @add_extension_period = 1 then @vextended_date
                                        WHEN @add_extension_period = 0 then @vmds_assess_with_ard_during_to
                                        END)
        and asmt_jsp.assess_date >= @vmds_assess_with_ard_during_from )

    AND (@pps_assessments = 0 or (@pps_assessments = 1
            and not exists (select 1 from reporting.ldl_view_fact_Response factRes where factRes.assess_id = factAsmt.assess_id and factRes.question_key = 'A0310A' and factRes.item_value= '99'))
        or (@pps_assessments = 2
            and not exists (select 1 from reporting.ldl_view_fact_Response factRes where factRes.assess_id = factAsmt.assess_id and factRes.question_key = 'A0310B' and factRes.item_value in ('01','02','03','04','05','06','07'))))
    AND (rugcode.deleted <> 'Y' or rugcode.deleted IS NULL)
    AND curpayer_type.payer_type <> 'Outpatient'
    AND curpayer_id.primary_payer_id IN (select payer_id from reporting.ldl_view_dim_ArLibPayer libpayer where libpayer.payer_type IS NULL
        OR libpayer.payer_type <> 'Outpatient')
    ))
    AND (
            (
                (
                (@vall_facilities = 1 OR factAsmt.fac_id in (select id from @fac_id))
                AND (factExtAsmt.REG_ID IS NULL OR factExtAsmt.REG_ID = -1)
                )
            OR factAsmt.FAC_ID = -1 OR factExtAsmt.REG_ID = 1
            )
            AND (@vall_clients = 1 OR factAsmt.client_id  in (select id from @client_id))
            AND (@vall_floors = 1 OR factAsmt.BED_ID = -1 OR bedLocation.floor_id  in (select id from @floor_id))
            AND (@vall_units = 1 OR factAsmt.BED_ID = -1 OR bedLocation.unit_id in (select id from @unit_id))
            AND (@vall_facilities = 1 OR factAsmt.fac_id in (select id from @fac_id))
            AND (@vignoreExcludeResidentsWithStatusOf= 1
                OR factAsmt.client_id not in
                    (select c99.client_id from  reporting.ldl_view_dim_Client c99, reporting.ldl_view_fact_CensusItem ci99, reporting.ldl_view_dim_CensusStatusCode cc99
					inner join #LeaveTypes l on cc99.status_type = l.status_type
                        where ci99.status_code_id = cc99.status_code_id
                        and ci99.record_type = 'C'
                        and ci99.client_id = c99.client_id
                        and (@vall_facilities = 1 OR c99.fac_id in (select id from @fac_id))
                        and ci99.effective_date = (
                            select max(ci98.effective_date)
                            from reporting.ldl_view_dim_Client c98, reporting.ldl_view_fact_CensusItem ci98
                            where ci98.record_type = 'C'
                            and ci98.client_id = c98.client_id
                            and ci98.effective_date < @vcurrent_residents_as_of
                            and ci98.client_id = c99.client_id
                        )
                    ))
    )
		IF OBJECT_ID('tempdb..#AssessDate') IS NOT NULL
		BEGIN
			DROP TABLE #AssessDate
		END

        IF OBJECT_ID('tempdb..#AssessDateWithExtension') IS NOT NULL
        BEGIN
            DROP TABLE #AssessDateWithExtension
        END

		IF OBJECT_ID('tempdb..#LeaveTypes') IS NOT NULL
		BEGIN
			DROP TABLE #LeaveTypes
		END
	;


END TRY
BEGIN CATCH
	SELECT
		@status_text = RTRIM(LEFT('Stored Procedure failed with Error Code : '
                              + CAST(ERROR_NUMBER() AS VARCHAR(10))
                              + ', Line Number : '
                              + CAST(ERROR_LINE() AS VARCHAR(10))
                              + ', Description : ' + ERROR_MESSAGE(), 3000)
                   ),
		 @status_code = 1;

    if @debug_me = 'Y' print @status_text

	SELECT @status_code as status_code, @status_text as status_text;
END CATCH;
END;

GO
GRANT EXECUTE ON reporting.bdl_sproc_EnterpriseCaseMix TO PUBLIC
GO

GO

print 'G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.bdl_sproc_EnterpriseCaseMix.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.bdl_sproc_EnterpriseCaseMix.sql',getdate(),'4.4.9_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_etl_FactPDPMRevenue_Extract.sql',getdate(),'4.4.9_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

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
-- CORE-46108       :   script to create [reporting].[sproc_etl_FactPDPMRevenue_Extract] Procedure  
--						-- 

-- Written By:          Kavita Sunku, Sherry Xu
-- Reviewed By:         
-- 
-- Script Type:         DDL 
-- Target DB Type:      Client
-- Target ENVIRONMENT:  BOTH  
-- 
-- 
-- Re-Runable:          YES 
-- 
-- Description of Script : Extract records from ar_rates and insert records into the PDPM Fact Revenue table (Initial load)
-- 
-- Special Instruction: 
--			
-- Revision History:
--  Date                User				JIRA          Description
--  11 July, 2019	    Kavita Sunku		CORE-46108    Updated the logic and split to 2 stored procs
--  15 July, 2019	    Kavita Sunku		CORE-46108	  Modified logging
--  20 Aug, 2019	    Sherry Xu    		CORE-43551	  Changed eff_date_from to eff_date_to 
--  22 Aug, 2019        Sherry Xu			CORE-49626    Added function socre columns
--  27 Aug, 2019        Sherry Xu			CORE-49870    Added logic for deleted assessments and census records
--  11 Nov, 2019		Vitaliy Panfilov	CORE-50332	  Added depression_flag
--  14 Nov, 2019		Sherry Xu			CORE-55683	  Added nursing_category and restorative_nursing_range
--  21 May, 2020		Sherry Xu			CORE-69856	  Updated the locality logic
--  16 Apr, 2021		Sherry Xu			CORE-88130	  Updated the locality logic to use date_id
--  14 Jul, 2021        Sherry Xu			CORE-92468    Added rate without ard and PDPM payer filter
-- ===================================================================================================================== */

IF EXISTS(SELECT 1 FROM sys.procedures WHERE [name] = 'sproc_etl_FactPDPMRevenue_Extract')
BEGIN
	DROP PROCEDURE [reporting].[sproc_etl_FactPDPMRevenue_Extract];
END
GO

CREATE PROCEDURE [reporting].[sproc_etl_FactPDPMRevenue_Extract] 
	  @first_id int, 
	  @last_id int,
	  @etl_job_run_id BIGINT,
	  @etl_batch_run_id BIGINT,
	  @initial_load_flag BIT,
	  @debug_me CHAR(1) = 'N' 

AS

/****************************************************************************************************  
--SAMPLE EXECUTION SCRIPT
To Run Independently please run below script:

truncate table reporting.pdl_fact_pdpm_revenue_staging;
truncate table reporting.pdl_fact_pdpm_revenue_staging2;
delete from reporting.pdl_fact_pdpm_revenue;

exec reporting.sproc_etl_FactPDPMRevenue_Extract 1, 9999, -728, 1, 0, 'Y';

--Check the data post execution
select * from reporting.pdl_fact_pdpm_revenue_staging;
select * from reporting.pdl_fact_pdpm_revenue_staging2;
select * from reporting.pdl_fact_pdpm_revenue;

*****************************************************************************************************/  

BEGIN 
	SET NOCOUNT ON;
	
	BEGIN TRY
		
		--declare constant variables	
		declare @system_user varchar(200) = suser_name();
		declare @vetl_job_run_id bigint = @etl_job_run_id;
		declare @vfirst_id int = @first_id;
		declare @vlast_id int = @last_id;
		declare @message_log varchar(2000) = '';
		declare @etl_job_status_msg varchar(2000) = ''
		declare @record_count int
		declare @proc_name varchar(100)
		declare @start_time datetime2
		declare @end_time datetime2
		declare @vinitial_load_flag BIT = @initial_load_flag 
		declare @vetl_batch_run_id bigint = @etl_batch_run_id;
		
		if @debug_me = 'Y'
		BEGIN
			set @message_log = 'PDPM Revenue information from ar_rates initial load extract process starting...'
			print @message_log
			
		END

		SET @start_time = SYSUTCDATETIME();

		IF EXISTS (select table_name from information_schema.tables
						where table_name = 'pdl_fact_pdpm_revenue_staging' and table_schema = 'reporting')
		BEGIN
		
			TRUNCATE TABLE reporting.pdl_fact_pdpm_revenue_staging;

			;WITH effectivePeriod
			AS (
				SELECT CASE WHEN eff_date_to IS NULL
							THEN 1
							WHEN eff_date_from = eff_date_to
							then 1
							ELSE DATEDIFF(day, eff_date_from, eff_date_to) + 1
							END AS effectiveDays, *
				FROM dbo.ar_rates
				WHERE reimb_rate_type = 'PDPM_RATE'
				AND eff_date_to > DATEADD(YEAR, -2, GETDATE())				--logic for only extracting 2 years worth of data from source
				)
			,rates
			AS (
				SELECT TOP ( SELECT MAX(effectiveDays) + 1 FROM effectivePeriod ) dayCount = ROW_NUMBER() OVER (ORDER BY [object_id])
				FROM sys.all_columns
				ORDER BY [object_id]
				)
				
			INSERT INTO reporting.pdl_fact_pdpm_revenue_staging (
			   date_id
			   , fac_id
			   , client_id
			   , census_id
			   , eff_date_from
			   , eff_date_to
			   , pps_assess_id
			   , assess_ref_date
			   , assess_type
			   , hipps
			   , is_urban
			   , effective_date
			   , dayCount
			   , medicare_days
			   , vpd_days
			   , daily_pay_rate
			   , pt_cmi
			   , ot_cmi
			   , slp_cmi
			   , nta_cmi
			   , nursing_cmi
			   , clinical_category
			   , slp_group
			   , pt_ot_group
			   , nta_group
			   , nursing_group
			   , nta_rate
			   , pt_rate
			   , ot_rate
			   , slp_rate
			   , ncm_rate
			   , nursing_rate
			   , nutrition
			   , slp_cognitive_level
			   , payer_type_id
				,pt_ot_function_score
				,slp_bims_score
				,nta_function_score
				,nursing_function_score
				,diagnosis_id
				,depression_flag
				,nursing_category
				,restorative_nursing_range)
			SELECT DATEADD(day, (dayCount - 1), e.eff_date_from) date_id
				,ce.fac_id
				,e.client_id
				,e.census_id
				,e.eff_date_from
				,e.eff_date_to
				,pps_assess_id
				,convert(date, asmt.assess_ref_date)
				,asmt.assess_type_code
				,c.hipps_code
				,pl.is_urban
				,ce.effective_date
				,dayCount
				,medicare_days
				,vpd_days
				,daily_pay_rate
				,pt_cmi
				,ot_cmi
				,slp_cmi
				,nta_cmi
				,nursing_cmi
				,CASE WHEN clinical_category IS NULL THEN 'NA'
						ELSE clinical_category
					END clinical_category
				,CASE WHEN slp_group IS NULL THEN 'NA'
						ELSE slp_group
					END slp_group
				,CASE WHEN pt_ot_group IS NULL THEN 'NA'
						ELSE pt_ot_group
					END pt_ot_group
				,CASE WHEN nta_group IS NULL THEN 'NA'
						ELSE nta_group
					END nta_group
				,CASE WHEN nursing_group IS NULL THEN 'NA'
						ELSE nursing_group
					END nursing_group
				,CASE WHEN nta_rate IS NULL THEN 0
					ELSE nta_rate
					END nta_rate
				,CASE WHEN pt_rate IS NULL THEN 0
						ELSE pt_rate
					END pt_rate
				,CASE WHEN ot_rate IS NULL THEN 0
						ELSE ot_rate
					END ot_rate
				,CASE WHEN slp_rate IS NULL THEN 0
						ELSE slp_rate
					END slp_rate
				,CASE WHEN ncm_rate IS NULL THEN 0
						ELSE ncm_rate
					END ncm_rate
				,CASE WHEN nursing_rate IS NULL THEN 0
						ELSE nursing_rate
					END nursing_rate
				,CASE WHEN a.mech_alt_diet_flag = 1 and a.swallowing_dis_flag = 0 THEN 'diet'
					  WHEN a.mech_alt_diet_flag = 0 and a.swallowing_dis_flag = 1 THEN 'swall'
					  WHEN a.mech_alt_diet_flag = 1 and a.swallowing_dis_flag = 1 THEN 'both'
					  WHEN a.mech_alt_diet_flag = 0 and a.swallowing_dis_flag = 0 THEN 'neither'
						ELSE 'NA'
					END nutrition
				,CASE WHEN slp_cognitive_level = 'MILDLY_IMPAIRED'
						THEN 'Mildly Impaired'
						WHEN slp_cognitive_level = 'COGNITIVELY_INTACT'
							THEN 'Cognitively Intact'
						WHEN slp_cognitive_level = 'MODERATELY_IMPAIRED'
							THEN 'Moderately Impaired'
						WHEN slp_cognitive_level = 'SEVERELY_IMPAIRED'
							THEN 'Severely Impaired'
						WHEN slp_cognitive_level IS NULL
							THEN 'NA'
						ELSE slp_cognitive_level
					END slp_cognitive_level
				,pt.payer_type_id
				,pt_ot_function_score
				,slp_bims_score
				,nta_function_score
				,nursing_function_score
				,d.diagnosis_id
				,a.depression_flag
				,reporting.ldl_fn_PDPMGroup(REPLACE(a.nursing_category, '_', ' '))
				,a.conditions_services_present
			FROM rates
			CROSS JOIN effectivePeriod AS e
			LEFT JOIN dbo.census_item_assessment_info c ON e.census_id = c.census_id
			LEFT JOIN dbo.as_assessment_pdpm a ON c.pps_assess_id = a.assess_id
			LEFT JOIN (select assess_id, assess_ref_date, assess_type_code 
						from dbo.as_assessment
						where std_assess_id = 11 and status <> 'Inactivated' and deleted = 'N'
						)asmt ON a.assess_id = asmt.assess_id
			LEFT JOIN [dbo].[as_response] r on c.pps_assess_id = r.assess_id and r.question_key = 'I0020B'
			LEFT JOIN [dbo].[diagnosis_codes] d on r.item_value = d.icd9_code 
						and diag_lib_id = (SELECT item_id FROM dbo.common_code cc WHERE item_code = 'diaglb' AND short_description = 'ICD-10-CM')
						and d.system_flag = 'Y' and d.state_code is null
						and (d.ineffective_date IS NULL OR d.ineffective_date > assess_ref_date)
						and d.effective_date <= assess_ref_date
						and d.deleted = 'N'
			INNER JOIN (select * from dbo.census_item where deleted = 'N') ce ON e.census_id = ce.census_id
			INNER JOIN ar_date_range dr on ce.primary_date_range_id = dr.eff_date_range_id and ce.deleted = 'N' and dr.pdpm_flag = 'Y'
			INNER JOIN dbo.ar_configuration_pdpm_locality acpl ON ce.fac_id = acpl.fac_id
						AND (DATEADD(day, (dayCount - 1), e.eff_date_from) >= acpl.eff_date_from 
							and (DATEADD(day, (dayCount - 1), e.eff_date_from) <= acpl.eff_date_to or acpl.eff_date_to is null))
			INNER JOIN WESREFERENCE.dbo.pdpm_locality pl on acpl.pdpm_locality_id = pl.pdpm_locality_id
			INNER JOIN reporting.ldl_view_dim_ArLibPayer p on ce.primary_payer_id = p.payer_id
			INNER JOIN reporting.ldl_view_dim_ArLibPayerType pt on p.payer_type = pt.payer_type_desc
			WHERE rates.dayCount <= e.effectiveDays
						and ce.fac_id >= @vfirst_id and ce.fac_id <= @vlast_id
			
			select @record_count = @@ROWCOUNT

			/*Filter records that have NULL in NOT NULL columns*/
			INSERT INTO reporting.pdl_fact_pdpm_revenue_exception (
					date_id				
					,fac_id				
					,client_id				
					,payer_type_id			
					,assess_id				
					,assess_ref_date		
					,assess_type			
					,pt_rate				
					,ot_rate				
					,slp_rate				
					,nta_rate				
					,nursing_rate			
					,ncm_rate				
					,is_urban				
					,census_id				
					,daily_rate	
					,etl_created_date
					,etl_created_job_run_id
					,etl_revision_date
					,etl_revision_job_run_id)
			SELECT convert(int, convert(datetime, date_id))
					,fac_id				
					,client_id				
					,payer_type_id			
					,pps_assess_id				
					,assess_ref_date		
					,assess_type			
					,pt_rate				
					,ot_rate				
					,slp_rate				
					,nta_rate				
					,nursing_rate			
					,ncm_rate				
					,is_urban				
					,census_id				
					,daily_pay_rate			
					,@start_time		
					,@etl_job_run_id
					,@start_time		
					,@etl_job_run_id
			FROM reporting.pdl_fact_pdpm_revenue_staging
			WHERE 
				daily_pay_rate IS NULL
				OR is_urban IS NULL

		END

		SET @end_time = SYSUTCDATETIME();

		if @debug_me = 'Y'
		begin
			SET @message_log = 'PDPM Revenue information from ar_rates initial load extract process ending. Read ' + convert(varchar(10), @record_count) + ' number of records for fac_id between ' + convert(varchar(10), @vfirst_id) + ' and ' + convert(varchar(10), @vlast_id) 
			print @message_log
		end

		SET @proc_name = OBJECT_NAME(@@PROCID)

		-- Log etl audit record
		EXEC reporting.sproc_etl_auditMessageEventLog @etl_job_run_id    = @etl_job_run_id
		,											  @etl_batch_run_id  = @vetl_batch_run_id
		,                                             @task_name         = @proc_name
		,                                             @table_name        = 'pdl_fact_pdpm_revenue_staging'
		,                                             @task_start_time   = @start_time
		,                                             @task_end_time     = @end_time
		,                                             @rows_inserted     = @record_count
		,											  @initial_load_flag = @vinitial_load_flag;

		END TRY

		BEGIN CATCH

			SET @etl_job_status_msg = ERROR_PROCEDURE()
			SET @etl_job_status_msg = isnull(@etl_job_status_msg, '[sproc_etl_FactPDPMRevenue_Extract Procedure') + '-' + ERROR_MESSAGE()

			exec reporting.sproc_etl_addMessageEventLog @etl_job_run_id, @etl_job_status_msg, 1, @system_user

			if @debug_me = 'Y'
			print @etl_job_status_msg

			raiserror(@etl_job_status_msg, 16, 1)

		END CATCH		

RETURN  
END
GO

GRANT EXEC ON reporting.sproc_etl_FactPDPMRevenue_Extract TO PUBLIC
GO


GO

print 'G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_etl_FactPDPMRevenue_Extract.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_etl_FactPDPMRevenue_Extract.sql',getdate(),'4.4.9_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_etl_FactPDPMRevenue_Extract_Delta.sql',getdate(),'4.4.9_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

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
-- CORE-43551: Extract delta data for PDPM revenue fact table 
--
-- Written By:          Sherry Xu
--  
-- Script Type:         DDL 
-- Target DB Type:      Client
-- Target ENVIRONMENT:  BOTH  
-- Re-Runable:          YES 
-- Description of Script: 
-- Create procedure to support etl delta load on PDPM revenue fact table 
--======================================================================================================================

IF EXISTS (SELECT 1 FROM sys.procedures WHERE NAME = 'sproc_etl_FactPDPMRevenue_Extract_Delta')
BEGIN
	DROP PROCEDURE reporting.sproc_etl_FactPDPMRevenue_Extract_Delta
END 
GO

CREATE PROCEDURE [reporting].[sproc_etl_FactPDPMRevenue_Extract_Delta] 
	  @etl_job_run_id BIGINT,
	  @initial_load_flag BIT,
	  @debug_me CHAR(1) = 'N',
	  @CT_PREVIOUS_VERSION BIGINT,
	  @CT_CURRENT_VERSION BIGINT 

AS

/****************************************************************************************************  
--SAMPLE EXECUTION SCRIPT
exec reporting.sproc_etl_FactPDPMRevenue_Extract_Delta -728, 0, 'Y', 4973899, 5000000;
select * from reporting.pdl_fact_pdpm_revenue_delta_staging;
select * from reporting.pdl_fact_pdpm_revenue_delta_staging1;
select * from reporting.pdl_fact_pdpm_revenue_delta_staging2;
select * from reporting.pdl_fact_pdpm_revenue_delta_staging3;
*****************************************************************************************************/  

BEGIN 
	SET NOCOUNT ON;
	
	BEGIN TRY
		
		--declare constant variables	
		declare @system_user varchar(200) = suser_name();
		declare @vetl_job_run_id bigint = @etl_job_run_id;
		declare @message_log varchar(2000) = '';
		declare @etl_job_status_msg varchar(2000) = ''
		declare @record_count int
		declare @proc_name varchar(100)
		declare @etl_batch_run_id BIGINT = 0
		declare @start_time datetime2
		declare @end_time datetime2
		declare @vinitial_load_flag BIT = @initial_load_flag 
		declare @vetl_batch_run_id bigint = @etl_batch_run_id;
		DECLARE @last_commit_ts BIGINT = @CT_PREVIOUS_VERSION-1;
		
		if @debug_me = 'Y'
		BEGIN
			set @message_log = 'PDPM Revenue information from ar_rates delta load extract process starting...'
			print @message_log
			
		END

		BEGIN

			TRUNCATE TABLE reporting.pdl_fact_pdpm_revenue_delta_staging;
			TRUNCATE TABLE reporting.pdl_fact_pdpm_revenue_delta_staging1;
			TRUNCATE TABLE reporting.pdl_fact_pdpm_revenue_delta_staging2;
			TRUNCATE TABLE reporting.pdl_fact_pdpm_revenue_delta_staging3;

			SET @start_time = SYSUTCDATETIME();

			INSERT INTO reporting.pdl_fact_pdpm_revenue_delta_staging1 (
			   client_id
			   , eff_date_from
			   , additional_location_flag
			   , sys_change_version
			   , sys_change_operation)
			SELECT client_id, eff_date_from, additional_location_flag, sys_change_version,sys_change_operation
			FROM reporting.ldl_fn_chg_ArRates(@last_commit_ts)
			WHERE sys_change_version BETWEEN @CT_PREVIOUS_VERSION AND @CT_CURRENT_VERSION

			select @record_count = @@ROWCOUNT
			SET @proc_name = OBJECT_NAME(@@PROCID)
			SET @end_time = SYSUTCDATETIME()

			if @debug_me = 'Y'
			begin
				SET @message_log = 'PDPM Revenue extract process read ' + convert(varchar(10), @record_count) + ' number of deletion and update records from ar_rates'
				print @message_log
			end

			-- Log etl audit record
			EXEC reporting.sproc_etl_auditMessageEventLog @etl_job_run_id    = @etl_job_run_id
			,											  @etl_batch_run_id  = @vetl_batch_run_id
			,                                             @task_name         = @proc_name
			,                                             @table_name        = 'pdl_fact_pdpm_revenue_delta_staging1'
			,                                             @task_start_time   = @start_time
			,                                             @task_end_time     = @end_time
			,                                             @rows_inserted     = @record_count
			,											  @initial_load_flag = @vinitial_load_flag;

			SET @start_time = SYSUTCDATETIME();

			INSERT INTO reporting.pdl_fact_pdpm_revenue_delta_staging2 (
			   assess_id
			   , sys_change_version
			   , sys_change_operation)
			SELECT assess_id, sys_change_version,sys_change_operation
			FROM reporting.ldl_fn_chg_AsAssessmentPdpm(@last_commit_ts)
			WHERE sys_change_version BETWEEN @CT_PREVIOUS_VERSION AND @CT_CURRENT_VERSION AND sys_change_operation in ('U', 'D')
			union
			SELECT assess_id, sys_change_version,sys_change_operation
			FROM reporting.ldl_fn_chg_Assessment(@last_commit_ts)
			WHERE sys_change_version BETWEEN @CT_PREVIOUS_VERSION AND @CT_CURRENT_VERSION AND sys_change_operation in ('U')
				AND (CHANGE_TRACKING_IS_COLUMN_IN_MASK(COLUMNPROPERTY(OBJECT_ID('dbo.as_assessment'), 'assess_ref_date', 'ColumnId'), SYS_CHANGE_COLUMNS) = 1
				OR CHANGE_TRACKING_IS_COLUMN_IN_MASK(COLUMNPROPERTY(OBJECT_ID('dbo.as_assessment'), 'assess_type_code', 'ColumnId'), SYS_CHANGE_COLUMNS) = 1
				OR CHANGE_TRACKING_IS_COLUMN_IN_MASK(COLUMNPROPERTY(OBJECT_ID('dbo.as_assessment'), 'status', 'ColumnId'), SYS_CHANGE_COLUMNS) = 1
				OR CHANGE_TRACKING_IS_COLUMN_IN_MASK(COLUMNPROPERTY(OBJECT_ID('dbo.as_assessment'), 'deleted', 'ColumnId'), SYS_CHANGE_COLUMNS) = 1)

			select @record_count = @@ROWCOUNT
			SET @end_time = SYSUTCDATETIME()

			if @debug_me = 'Y'
			begin
				SET @message_log = 'PDPM Revenue extract process read ' + convert(varchar(10), @record_count) + ' number of deletion and update records from as_assessment and as_assessment_pdpm'
				print @message_log
			end

			-- Log etl audit record
			EXEC reporting.sproc_etl_auditMessageEventLog @etl_job_run_id    = @etl_job_run_id
			,											  @etl_batch_run_id  = @vetl_batch_run_id
			,                                             @task_name         = @proc_name
			,                                             @table_name        = 'pdl_fact_pdpm_revenue_delta_staging2'
			,                                             @task_start_time   = @start_time
			,                                             @task_end_time     = @end_time
			,                                             @rows_inserted     = @record_count
			,											  @initial_load_flag = @vinitial_load_flag;

			SET @start_time = SYSUTCDATETIME();

			INSERT INTO reporting.pdl_fact_pdpm_revenue_delta_staging3 (
			   census_id
			   , sys_change_version
			   , sys_change_operation)
			SELECT census_id, sys_change_version,sys_change_operation
			FROM reporting.ldl_fn_chg_CensusItemAssessmentInfo(@last_commit_ts)
			WHERE sys_change_version BETWEEN @CT_PREVIOUS_VERSION AND @CT_CURRENT_VERSION AND sys_change_operation in ('U', 'D')
			union
			SELECT census_id, sys_change_version,sys_change_operation
			FROM reporting.ldl_fn_chg_CensusItem(@last_commit_ts)
			WHERE sys_change_version BETWEEN @CT_PREVIOUS_VERSION AND @CT_CURRENT_VERSION AND sys_change_operation in ('U')
				AND (CHANGE_TRACKING_IS_COLUMN_IN_MASK(COLUMNPROPERTY(OBJECT_ID('dbo.census_item'), 'fac_id', 'ColumnId'), SYS_CHANGE_COLUMNS) = 1
				OR CHANGE_TRACKING_IS_COLUMN_IN_MASK(COLUMNPROPERTY(OBJECT_ID('dbo.census_item'), 'effective_date', 'ColumnId'), SYS_CHANGE_COLUMNS) = 1
				OR CHANGE_TRACKING_IS_COLUMN_IN_MASK(COLUMNPROPERTY(OBJECT_ID('dbo.census_item'), 'deleted', 'ColumnId'), SYS_CHANGE_COLUMNS) = 1)
			union
			SELECT census_id, sys_change_version,sys_change_operation
			FROM reporting.ldl_fn_chg_ArDateRange(@last_commit_ts) dr
			join dbo.census_item cen on dr.eff_date_range_id = cen.primary_date_range_id
			WHERE sys_change_version BETWEEN @CT_PREVIOUS_VERSION AND @CT_CURRENT_VERSION AND sys_change_operation in ('U', 'D')
		

			select @record_count = @@ROWCOUNT
			SET @end_time = SYSUTCDATETIME()

			if @debug_me = 'Y'
			begin
				SET @message_log = 'PDPM Revenue extract process read ' + convert(varchar(10), @record_count) + ' number of deletion and update records from census_item and census_item_assessment_info'
				print @message_log
			end

			-- Log etl audit record
			EXEC reporting.sproc_etl_auditMessageEventLog @etl_job_run_id    = @etl_job_run_id
			,											  @etl_batch_run_id  = @vetl_batch_run_id
			,                                             @task_name         = @proc_name
			,                                             @table_name        = 'pdl_fact_pdpm_revenue_delta_staging3'
			,                                             @task_start_time   = @start_time
			,                                             @task_end_time     = @end_time
			,                                             @rows_inserted     = @record_count
			,											  @initial_load_flag = @vinitial_load_flag;

			SET @start_time = SYSUTCDATETIME();

			;WITH rateChanges
			AS
			(
			SELECT client_id, eff_date_from, additional_location_flag
			FROM reporting.pdl_fact_pdpm_revenue_delta_staging1 s1
			WHERE sys_change_operation in ('U', 'I')
			union
			SELECT client_id, eff_date_from, additional_location_flag
			FROM reporting.pdl_fact_pdpm_revenue_delta_staging2 s2 
			inner join dbo.census_item_assessment_info c1 on c1.pps_assess_id = s2.assess_id and sys_change_operation = 'U'
			inner join dbo.ar_rates r1 on c1.census_id = r1.census_id
			WHERE client_id is not null and eff_date_from is not null
			union
			SELECT client_id, eff_date_from, additional_location_flag
			FROM reporting.pdl_fact_pdpm_revenue_delta_staging3 s3
			inner join dbo.ar_rates r2 on s3.census_id = r2.census_id and sys_change_operation = 'U'
			WHERE client_id is not null and eff_date_from is not null
			)
			,effectivePeriod
			AS (
				SELECT CASE WHEN eff_date_to IS NULL
							THEN 1
							WHEN a.eff_date_from = eff_date_to
							then 1
							ELSE DATEDIFF(day, a.eff_date_from, eff_date_to) + 1
							END AS effectiveDays, 
							c.client_id as changed_client_id, c.eff_date_from as changed_eff_date_from, a.*
				FROM rateChanges c inner join dbo.ar_rates a on c.client_id = a.client_id and c.eff_date_from = a.eff_date_from
					and c.additional_location_flag = a.additional_location_flag
				WHERE reimb_rate_type = 'PDPM_RATE'
				AND a.eff_date_to > DATEADD(YEAR, -2, GETDATE())				--logic for only update 2 years worth of data from source
				)
			,rates
			AS (
				SELECT TOP (SELECT isnull(MAX(effectiveDays),0) + 1 FROM effectivePeriod) dayCount = ROW_NUMBER() OVER (ORDER BY [object_id])
				FROM sys.all_columns
				ORDER BY [object_id]
				)
			INSERT INTO reporting.pdl_fact_pdpm_revenue_delta_staging (
			   date_id
			   , fac_id
			   , client_id
			   , census_id
			   , eff_date_from
			   , eff_date_to
			   , pps_assess_id
			   , assess_ref_date
			   , assess_type
			   , hipps
			   , is_urban
			   , effective_date
			   , dayCount
			   , medicare_days
			   , vpd_days
			   , daily_pay_rate
			   , pt_cmi
			   , ot_cmi
			   , slp_cmi
			   , nta_cmi
			   , nursing_cmi
			   , clinical_category
			   , slp_group
			   , pt_ot_group
			   , nta_group
			   , nursing_group
			   , nta_rate
			   , pt_rate
			   , ot_rate
			   , slp_rate
			   , ncm_rate
			   , nursing_rate
			   , nutrition
			   , slp_cognitive_level
			   , payer_type_id
			   , pt_ot_function_score
			   , slp_bims_score
			   , nta_function_score
			   , nursing_function_score
			   , diagnosis_id
			   , depression_flag
				,nursing_category
				,restorative_nursing_range)
			SELECT DATEADD(day, (dayCount - 1), e.eff_date_from) date_id
				,ce.fac_id
				,e.client_id
				,e.census_id
				,e.eff_date_from
				,e.eff_date_to
				,pps_assess_id
				,convert(date, asmt.assess_ref_date)
				,asmt.assess_type_code
				,c.hipps_code
				,pl.is_urban
				,ce.effective_date
				,dayCount
				,medicare_days
				,vpd_days
				,daily_pay_rate
				,pt_cmi
				,ot_cmi
				,slp_cmi
				,nta_cmi
				,nursing_cmi
				,CASE WHEN clinical_category IS NULL THEN 'NA'
						ELSE clinical_category
					END clinical_category
				,CASE WHEN slp_group IS NULL THEN 'NA'
						ELSE slp_group
					END slp_group
				,CASE WHEN pt_ot_group IS NULL THEN 'NA'
						ELSE pt_ot_group
					END pt_ot_group
				,CASE WHEN nta_group IS NULL THEN 'NA'
						ELSE nta_group
					END nta_group
				,CASE WHEN nursing_group IS NULL THEN 'NA'
						ELSE nursing_group
					END nursing_group
				,CASE WHEN nta_rate IS NULL THEN 0
					ELSE nta_rate
					END nta_rate
				,CASE WHEN pt_rate IS NULL THEN 0
						ELSE pt_rate
					END pt_rate
				,CASE WHEN ot_rate IS NULL THEN 0
						ELSE ot_rate
					END ot_rate
				,CASE WHEN slp_rate IS NULL THEN 0
						ELSE slp_rate
					END slp_rate
				,CASE WHEN ncm_rate IS NULL THEN 0
						ELSE ncm_rate
					END ncm_rate
				,CASE WHEN nursing_rate IS NULL THEN 0
						ELSE nursing_rate
					END nursing_rate
				,CASE WHEN a.mech_alt_diet_flag = 1 and a.swallowing_dis_flag = 0 THEN 'diet'
					  WHEN a.mech_alt_diet_flag = 0 and a.swallowing_dis_flag = 1 THEN 'swall'
					  WHEN a.mech_alt_diet_flag = 1 and a.swallowing_dis_flag = 1 THEN 'both'
					  WHEN a.mech_alt_diet_flag = 0 and a.swallowing_dis_flag = 0 THEN 'neither'
						ELSE 'NA'
					END nutrition
				,CASE WHEN slp_cognitive_level = 'MILDLY_IMPAIRED'
						THEN 'Mildly Impaired'
						WHEN slp_cognitive_level = 'COGNITIVELY_INTACT'
							THEN 'Cognitively Intact'
						WHEN slp_cognitive_level = 'MODERATELY_IMPAIRED'
							THEN 'Moderately Impaired'
						WHEN slp_cognitive_level = 'SEVERELY_IMPAIRED'
							THEN 'Severely Impaired'
						WHEN slp_cognitive_level IS NULL
							THEN 'NA'
						ELSE slp_cognitive_level
					END slp_cognitive_level
				,pt.payer_type_id
			    ,pt_ot_function_score
			    ,slp_bims_score
			    ,nta_function_score
			    ,nursing_function_score
				,diagnosis_id
				,a.depression_flag
				,reporting.ldl_fn_PDPMGroup(REPLACE(a.nursing_category, '_', ' '))
				,a.conditions_services_present
			FROM rates
			CROSS JOIN effectivePeriod AS e
			LEFT JOIN dbo.census_item_assessment_info c ON e.census_id = c.census_id
			LEFT JOIN dbo.as_assessment_pdpm a ON c.pps_assess_id = a.assess_id
			LEFT JOIN (select assess_id, assess_ref_date, assess_type_code 
						from dbo.as_assessment
						where std_assess_id = 11 and status <> 'Inactivated' and deleted = 'N'
						)asmt ON a.assess_id = asmt.assess_id
			LEFT JOIN [dbo].[as_response] r on c.pps_assess_id = r.assess_id and r.question_key = 'I0020B'
			LEFT JOIN [dbo].[diagnosis_codes] d on r.item_value = d.icd9_code 
						and diag_lib_id = (SELECT item_id FROM dbo.common_code cc WHERE item_code = 'diaglb' AND short_description = 'ICD-10-CM')
						and d.system_flag = 'Y' and d.state_code is null
						and (d.ineffective_date IS NULL OR d.ineffective_date > assess_ref_date)
						and d.effective_date <= assess_ref_date
						and d.deleted = 'N'
			INNER JOIN (select * from dbo.census_item where deleted = 'N') ce ON e.census_id = ce.census_id
			INNER JOIN ar_date_range dr on ce.primary_date_range_id = dr.eff_date_range_id and ce.deleted = 'N' and dr.pdpm_flag = 'Y'
			INNER JOIN dbo.ar_configuration_pdpm_locality acpl ON ce.fac_id = acpl.fac_id
						AND (DATEADD(day, (dayCount - 1), e.eff_date_from) >= acpl.eff_date_from 
							and (DATEADD(day, (dayCount - 1), e.eff_date_from) <= acpl.eff_date_to or acpl.eff_date_to is null))
			INNER JOIN WESREFERENCE.dbo.pdpm_locality pl on acpl.pdpm_locality_id = pl.pdpm_locality_id
			INNER JOIN reporting.ldl_view_dim_ArLibPayer p on ce.primary_payer_id = p.payer_id
			INNER JOIN reporting.ldl_view_dim_ArLibPayerType pt on p.payer_type = pt.payer_type_desc
			WHERE rates.dayCount <= e.effectiveDays
			
			select @record_count = @@ROWCOUNT
			SET @end_time = SYSUTCDATETIME()

			-- Log etl audit record
			EXEC reporting.sproc_etl_auditMessageEventLog @etl_job_run_id    = @etl_job_run_id
			,											  @etl_batch_run_id  = @vetl_batch_run_id
			,                                             @task_name         = @proc_name
			,                                             @table_name        = 'pdl_fact_pdpm_revenue_delta_staging'
			,                                             @task_start_time   = @start_time
			,                                             @task_end_time     = @end_time
			,                                             @rows_inserted     = @record_count
			,											  @initial_load_flag = @vinitial_load_flag;

			SET @start_time = SYSUTCDATETIME();

			/*Filter records that have NULL in NOT NULL columns*/
			INSERT INTO reporting.pdl_fact_pdpm_revenue_exception (
					date_id				
					,fac_id				
					,client_id				
					,payer_type_id			
					,assess_id				
					,assess_ref_date		
					,assess_type			
					,pt_rate				
					,ot_rate				
					,slp_rate				
					,nta_rate				
					,nursing_rate			
					,ncm_rate				
					,is_urban				
					,census_id				
					,daily_rate	
					,etl_created_date
					,etl_created_job_run_id
					,etl_revision_date
					,etl_revision_job_run_id)
			SELECT convert(int, convert(datetime, date_id))
					,fac_id				
					,client_id				
					,payer_type_id			
					,pps_assess_id				
					,assess_ref_date		
					,assess_type			
					,pt_rate				
					,ot_rate				
					,slp_rate				
					,nta_rate				
					,nursing_rate			
					,ncm_rate				
					,is_urban				
					,census_id				
					,daily_pay_rate			
					,@start_time		
					,@etl_job_run_id
					,@start_time		
					,@etl_job_run_id
			FROM reporting.pdl_fact_pdpm_revenue_delta_staging
			WHERE 
				daily_pay_rate IS NULL
				OR is_urban IS NULL

		END

		select @record_count = @@ROWCOUNT
		SET @end_time = SYSUTCDATETIME()

		if @debug_me = 'Y'
		begin
			SET @message_log = 'PDPM Revenue information from ar_rates delta load extract process ending. Read ' + convert(varchar(10), @record_count) + ' number of insertion records'
			print @message_log
		end

		-- Log etl audit record
		EXEC reporting.sproc_etl_auditMessageEventLog @etl_job_run_id    = @etl_job_run_id
		,											  @etl_batch_run_id  = @vetl_batch_run_id
		,                                             @task_name         = @proc_name
		,                                             @table_name        = 'pdl_fact_pdpm_revenue_exception'
		,                                             @task_start_time   = @start_time
		,                                             @task_end_time     = @end_time
		,                                             @rows_inserted     = @record_count
		,											  @initial_load_flag = @vinitial_load_flag;

		END TRY

		BEGIN CATCH

			SET @etl_job_status_msg = ERROR_PROCEDURE()
			SET @etl_job_status_msg = isnull(@etl_job_status_msg, '[sproc_etl_FactPDPMRevenue_Extract_Delta Procedure') + '-' + ERROR_MESSAGE()

			exec reporting.sproc_etl_addMessageEventLog @etl_job_run_id, @etl_job_status_msg, 1, @system_user

			if @debug_me = 'Y'
			print @etl_job_status_msg

			raiserror(@etl_job_status_msg, 16, 1)

		END CATCH		

RETURN  
END

GO
GRANT EXEC ON reporting.sproc_etl_FactPDPMRevenue_Extract_Delta TO PUBLIC

GO

GO

print 'G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_etl_FactPDPMRevenue_Extract_Delta.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_etl_FactPDPMRevenue_Extract_Delta.sql',getdate(),'4.4.9_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_ipc_list_getClientsInfo.sql',getdate(),'4.4.9_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

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
-- CORE-97923        :  Script to create [sproc_ipc_list_getClientsInfo] Procedure in Client Database
--						-- 
-- Written By:          Amro Saada
-- Reviewed By:         
-- 
-- Script Type:         DDL 
-- Target DB Type:      Client Database
-- Target Environment:  BOTH 
-- 
-- 
-- Re-Runable:          YES 
-- 
-- Description of Script : Create sproc_ipc_list_getClientsInfo Procedure 
-- 
-- Special Instruction: 
-- 
-- =================================================================================

CREATE OR ALTER PROCEDURE [reporting].[sproc_ipc_list_getClientsInfo]
 @fac_ids   				varchar(max)
,@client_ids                varchar(max) = NULL
,@client_status				char(1)  = 'A'
,@discharge_from			datetime = NULL
,@discharge_to				datetime = NULL
,@output_columns_list		varchar(2000) = ''
,@debug_me					char(1) = 'N'
,@fac_names                 nvarchar(max)       OUT
,@status_code				int = 0				OUT  
,@status_text				varchar(3000) = ''	OUT

--/*****************************************************************************************
--Sample Execution Script:
--DECLARE @fac_names nvarchar(max),@status_code int, @status_text varchar(3000);
--EXEC [reporting].[sproc_ipc_list_getClientsInfo]
-- @fac_ids = '1,2,3,4,5'		
--,@client_ids  = NULL
--,@client_status = 'C'       -- A for all, C for current, N for new, D for discharge, O for outpatient
--,@discharge_from = NULL
--,@discharge_to = NULL
--,@output_columns_list = 'client_id_number,medical_record_number,admission_date,discharge_date,deceased_date,client_status,payer_type,outpatient_status,mpi_id,first_name,last_name,birth_date,gender,unit_id,unit_desc,room_id,room_desc'
--,@debug_me = 'N'
--,@fac_names = @fac_names     OUTPUT
--,@status_code = @status_code OUTPUT
--,@status_text = @status_text OUTPUT;
--SELECT @fac_names AS facility_names,@status_code status_code,@status_text AS status_text;
--******************************************************************************************/

AS

BEGIN 

SET NOCOUNT ON;

DECLARE 
	 @vfac_ids				varchar(max)
	,@vclient_ids           varchar(max)
	,@vstatus_code			int
	,@vstatus_text_ins		varchar(3000)
	,@vstatus_code_ins		int
	,@vfacility_count       int
	,@vclient_count         int
	,@vclient_status		char(1)
	,@vdischarge_from		datetime
	,@vdischarge_to			datetime
	,@vdistcharge_date_flag bit = 0
	,@vid_type_id           int
	,@voutput_columns_list  varchar(2000)
	,@vdebug_me				char(1)
	,@SQLString				nvarchar(max)
    ,@vid_type_id_count		int
	,@vinc_client_id_number			bit = 0
	,@vinc_medical_record_number    bit = 0
	,@vinc_admission_date			bit = 0
	,@vinc_discharge_date			bit = 0
	,@vinc_deceased_date			bit = 0
	,@vinc_client_status			bit = 0
	,@vinc_outpatient_status		bit = 0
	,@vinc_payer_type   			bit = 0
	,@vinc_mpi_id					bit = 0
	,@vinc_first_name				bit = 0
	,@vinc_last_name				bit = 0
	,@vinc_birth_date				bit = 0
	,@vinc_gender					bit = 0
	,@vinc_unit_id					bit = 0
	,@vinc_unit_desc				bit = 0
	,@vinc_room_id					bit = 0
	,@vinc_room_desc				bit = 0;

CREATE TABLE #facility (fac_id int PRIMARY KEY);		
CREATE TABLE #client (client_id int PRIMARY KEY);
CREATE TABLE #id_type (fac_id int PRIMARY KEY,id_type_id int);
DECLARE @output_columns TABLE (column_name varchar(100));

BEGIN TRY

SET @vfac_ids = @fac_ids;
SET @vclient_ids = @client_ids;
SET @vclient_status = @client_status;
SET @vdischarge_from = @discharge_from;		
SET @vdischarge_to = @discharge_to;
SET @voutput_columns_list = @output_columns_list;
SET @vdebug_me = @debug_me;

IF LEN(LTRIM(ISNULL(@vfac_ids,''))) = 0
BEGIN
	DECLARE @error_msg varchar(200);
	SET @error_msg = 'Facility id''s is a mandatory parameter';
	RAISERROR (@error_msg, 16, 1);
END

IF @vdischarge_from IS NOT NULL AND @vdischarge_to IS NOT NULL
BEGIN
	SET @vdistcharge_date_flag = 1;
END
INSERT INTO #facility
SELECT LTRIM(value) FROM STRING_SPLIT(@vfac_ids,',');

IF LEN(LTRIM(ISNULL(@vclient_ids,''))) > 0
BEGIN
INSERT INTO #client
SELECT LTRIM(value) FROM STRING_SPLIT(@vclient_ids,',');
END

IF LEN(LTRIM(ISNULL(@voutput_columns_list,''))) > 0
BEGIN
INSERT INTO @output_columns
SELECT LTRIM(value) FROM STRING_SPLIT(@voutput_columns_list,',');
END

SELECT @vfacility_count = COUNT(*) FROM #facility;

SELECT @vclient_count = COUNT(*) FROM #client;

INSERT INTO #id_type
SELECT f.fac_id, ISNULL(ac.hc_no_id, -2) AS id_type_id
FROM #facility f
INNER JOIN [dbo].[ar_configuration] ac
ON f.fac_id = ac.fac_id AND ac.deleted = 'N'
ORDER BY f.fac_id;

SELECT @vid_type_id_count = COUNT(DISTINCT id_type_id) FROM #id_type;

IF (@vid_type_id_count = 1)
BEGIN
	SET @vid_type_id = (SELECT TOP 1 id_type_id FROM #id_type);
END

IF @vdebug_me = 'Y' 
BEGIN 
	SELECT * FROM @output_columns;
	SELECT * FROM #id_type;
END

IF EXISTS(SELECT 1 FROM @output_columns WHERE column_name = 'client_id_number') SET @vinc_client_id_number = 1;
IF EXISTS(SELECT 1 FROM @output_columns WHERE column_name = 'medical_record_number') SET @vinc_medical_record_number = 1;
IF EXISTS(SELECT 1 FROM @output_columns WHERE column_name = 'admission_date') SET @vinc_admission_date = 1;
IF EXISTS(SELECT 1 FROM @output_columns WHERE column_name = 'discharge_date') SET @vinc_discharge_date = 1;
IF EXISTS(SELECT 1 FROM @output_columns WHERE column_name = 'deceased_date') SET @vinc_deceased_date = 1;
IF EXISTS(SELECT 1 FROM @output_columns WHERE column_name = 'client_status') SET @vinc_client_status = 1;
IF EXISTS(SELECT 1 FROM @output_columns WHERE column_name = 'outpatient_status') SET @vinc_outpatient_status = 1;
IF EXISTS(SELECT 1 FROM @output_columns WHERE column_name = 'payer_type') SET @vinc_payer_type = 1;
IF EXISTS(SELECT 1 FROM @output_columns WHERE column_name = 'mpi_id') SET @vinc_mpi_id = 1;
IF EXISTS(SELECT 1 FROM @output_columns WHERE column_name = 'first_name') SET @vinc_first_name = 1;
IF EXISTS(SELECT 1 FROM @output_columns WHERE column_name = 'last_name') SET @vinc_last_name = 1;
IF EXISTS(SELECT 1 FROM @output_columns WHERE column_name = 'birth_date') SET @vinc_birth_date = 1;
IF EXISTS(SELECT 1 FROM @output_columns WHERE column_name = 'gender') SET @vinc_gender = 1;
IF EXISTS(SELECT 1 FROM @output_columns WHERE column_name = 'unit_id') SET @vinc_unit_id = 1;
IF EXISTS(SELECT 1 FROM @output_columns WHERE column_name = 'unit_desc') SET @vinc_unit_desc = 1;
IF EXISTS(SELECT 1 FROM @output_columns WHERE column_name = 'room_id') SET @vinc_room_id = 1;
IF EXISTS(SELECT 1 FROM @output_columns WHERE column_name = 'room_desc') SET @vinc_room_desc = 1;

--Append SELECT clause 
SET @SQLString = 'SELECT c.fac_id,c.client_id';
IF (@vinc_client_id_number = 1) SET  @SQLString += ',c.client_id_number';
IF (@vinc_medical_record_number = 1) 
BEGIN
IF @vid_type_id < 0
BEGIN
	SET @SQLString += ',NULL AS medical_record_number';
END 
ELSE
BEGIN
	SET @SQLString += ',ids.[description] AS medical_record_number';
END
END 
IF (@vinc_admission_date = 1) SET @SQLString +=',c.admission_date';
IF (@vinc_discharge_date = 1) SET @SQLString +=',c.discharge_date';
IF (@vinc_deceased_date = 1) SET @SQLString +=',m.deceased_date';
IF (@vinc_client_status = 1)
BEGIN
	SET @SQLString += ',CASE WHEN c.current_census_id IS NULL THEN ''N'' 
WHEN (c.discharge_date IS NOT NULL) OR (ci.outpatient_status = ''I'') THEN ''D'' 
WHEN c.admission_date IS NULL OR m.deceased_date IS NOT NULL THEN '''' 
ELSE ''C'' END AS client_status';
END 
IF (@vinc_outpatient_status = 1) SET @SQLString +=',ci.outpatient_status';
IF (@vinc_payer_type = 1) SET @SQLString +=',lb.payer_type';
IF (@vinc_mpi_id = 1) SET @SQLString += ',m.mpi_id';
IF (@vinc_first_name = 1) SET @SQLString += ',m.first_name';
IF (@vinc_last_name = 1) SET @SQLString += ',m.last_name';
IF (@vinc_birth_date = 1) SET @SQLString += ',m.date_of_birth AS birth_date';
IF (@vinc_gender = 1) SET @SQLString += ',m.sex AS gender';
IF (@vinc_unit_id = 1) SET @SQLString += ',u.unit_id';
IF (@vinc_unit_desc = 1) SET @SQLString += ',u.unit_desc';
IF (@vinc_room_id = 1) SET @SQLString += ',r.room_id';
IF (@vinc_room_desc = 1) SET @SQLString += ',r.room_desc';

--Append FROM clause 
SET @SQLString += ' FROM [dbo].[clients] c WITH(NOLOCK)
INNER JOIN #facility f ON c.fac_id = f.fac_id AND c.deleted = ''N''';
IF (@vclient_count > 0 ) SET @SQLString += ' INNER JOIN #client ct ON c.client_id = ct.client_id';
IF (@vinc_client_status = 1 OR @vclient_status = 'C' OR @vinc_mpi_id = 1 OR @vinc_first_name = 1 OR @vinc_last_name = 1 OR @vinc_birth_date = 1 OR @vinc_gender = 1 OR @vinc_deceased_date = 1) 
BEGIN
	SET @SQLString += ' LEFT OUTER JOIN [dbo].[mpi] m WITH(NOLOCK) ON c.mpi_id = m.mpi_id AND m.deleted = ''N''';
END
IF (@vinc_medical_record_number = 1 AND (@vid_type_id IS NULL OR @vid_type_id > 0)) 
BEGIN
IF @vid_type_id_count = 1
BEGIN
SET @SQLString += ' LEFT OUTER JOIN [dbo].[client_ids] ids WITH (NOLOCK) 
ON ids.client_id = c.client_id AND f.fac_id = ids.fac_id AND ids.deleted = ''N'' AND ids.id_type_id = @vid_type_id';
END
ELSE
BEGIN
SET @SQLString += ' LEFT OUTER JOIN (
SELECT ids.fac_id,ids.client_id,description
FROM [dbo].[client_ids] ids WITH (NOLOCK) 
INNER JOIN #id_type it ON ids.fac_id = it.fac_id 
AND ids.id_type_id = it.id_type_id AND ids.deleted = ''N'') ids
ON ids.client_id = c.client_id AND f.fac_id = ids.fac_id';
END
END
IF (@vclient_status IN('C','D') OR @vinc_client_status = 1 OR @vinc_unit_id = 1 OR @vinc_unit_desc = 1 OR @vinc_room_id = 1 OR @vinc_room_desc = 1) 
BEGIN
SET @SQLString += ' LEFT OUTER JOIN [dbo].[census_item] ci WITH(NOLOCK) ON c.client_id = ci.client_id AND c.current_census_id = ci.census_id 
AND f.fac_id = ci.fac_id AND ci.deleted = ''N''';
END
IF(@vinc_unit_id = 1 OR @vinc_unit_desc = 1 OR @vinc_room_id = 1 OR @vinc_room_desc = 1)
BEGIN
	SET @SQLString += ' LEFT OUTER JOIN [dbo].[bed] b WITH(NOLOCK) 
ON ci.fac_id = b.fac_id AND ci.bed_id = b.bed_id AND b.deleted = ''N'' 
LEFT OUTER JOIN [dbo].[room] r WITH(NOLOCK) ON b.fac_id = r.fac_id AND b.room_id = r.room_id 
LEFT OUTER JOIN [dbo].[unit] u WITH(NOLOCK) ON r.fac_id = u.fac_id AND r.unit_id = u.unit_id AND u.deleted = ''N''';
END
IF (@vclient_status = 'O' OR @vclient_status = 'D' OR @vinc_payer_type = 1 )
BEGIN
SET @SQLString += ' LEFT JOIN [dbo].[census_item] ri WITH(NOLOCK) ON c.current_rate_id = ri.census_id AND 
c.client_id = ri.client_id AND f.fac_id = ri.fac_id
LEFT JOIN [dbo].[ar_lib_payers] lb WITH(NOLOCK) ON ri.primary_payer_id = lb.payer_id AND lb.deleted = ''N''';
END

--Append WHERE clause 
IF (@vclient_status <> 'A') SET @SQLString += ' WHERE';
IF (@vclient_status = 'O')  SET @SQLString += ' lb.payer_type = ''Outpatient''';
IF (@vclient_status = 'N')  SET @SQLString += ' c.current_census_id IS NULL';
IF (@vclient_status = 'C') 
BEGIN
	SET @SQLString += ' c.admission_date IS NOT NULL AND c.discharge_date IS NULL 
AND c.current_census_id IS NOT NULL AND m.deceased_date IS NULL AND (ci.outpatient_status IS NULL OR ci.outpatient_status = ''A'') ';
END
IF (@vclient_status = 'D' AND @vdistcharge_date_flag = 0) SET @SQLString += ' c.discharge_date IS NOT NULL AND (lb.payer_type IS NULL OR lb.payer_type <> ''Outpatient'')';
IF (@vclient_status = 'D' AND @vdistcharge_date_flag = 1)
BEGIN
	SET @SQLString += ' (c.discharge_date IS NOT NULL AND (lb.payer_type IS NULL OR lb.payer_type <> ''Outpatient'') AND c.discharge_date >= @vdischarge_from AND c.discharge_date <= @vdischarge_to)';
END

--Append ORDER BY clause
IF @vfacility_count > 1
BEGIN
	SET @SQLString += ' ORDER BY c.fac_id;';
END

IF @vdebug_me = 'Y' 
BEGIN 
	SELECT @vid_type_id AS id_type_id,@vid_type_id_count AS id_type_id_count,@vdischarge_from AS discharge_from, @vdischarge_to AS discharge_to, @SQLString AS SQLString;
END

EXECUTE sp_executesql @SQLString 
,N'@vid_type_id int,@vdischarge_from datetime,@vdischarge_to datetime'
,@vid_type_id = @vid_type_id ,@vdischarge_from = @vdischarge_from, @vdischarge_to = @vdischarge_to;

SET @fac_names = 
(
SELECT f.fac_id AS id, f.[name] AS fn 
FROM [dbo].[facility] f WITH(NOLOCK)
INNER JOIN #facility ft
	ON f.fac_id = ft.fac_id
FOR JSON AUTO
);

SET @status_code = 0;
SET @status_text = '';

END TRY
BEGIN CATCH
	SET @status_code = 1;
	SET @status_text = ERROR_MESSAGE();
END CATCH
END
GO
GRANT EXECUTE ON [reporting].[sproc_ipc_list_getClientsInfo] TO PUBLIC;
GO


GO

print 'G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_ipc_list_getClientsInfo.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_ipc_list_getClientsInfo.sql',getdate(),'4.4.9_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_pho_list_getPatientDays.sql',getdate(),'4.4.9_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

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


-- ===================================================================================================================
-- CORE-73541      :    Script to create [sproc_pho_list_getPatientDays] Procedure in Client Database
--						--
-- Written By:          Bartosz Zak
-- Reviewed By:
--
-- Script Type:         DDL
-- Target DB Type:      Client Database
-- Target ENVIRONMENT:  BOTH
--
-- Re-Runnable:         YES
--
-- Description of Script : Create [sproc_pho_list_getPatientDays] Procedure
--
-- Special Instruction:
--
-- Sample Execution Script:
--
-- DECLARE @fac_ids TABLEOFINT
-- DECLARE @start_date DATETIME = '2020-01-01'
-- DECLARE @end_date DATETIME = '2020-07-01'
-- DECLARE @is_monthly bit = 0
-- INSERT INTO @fac_ids SELECT * FROM SPLIT ('1, 2, 3, 4, 5', ',')
-- EXEC reporting.sproc_pho_list_getPatientDays @fac_ids, @start_date, @end_date, @is_monthly  
-- =================================================================================================================

CREATE OR ALTER PROCEDURE [reporting].[sproc_pho_list_getPatientDays]
    @fac_ids TABLEOFINT READONLY    -- -1 NOT ACCEPTED, ALWAYS BE EXPLICIT WITH THE FAC IDs
  , @start_date DATETIME
  , @end_date DATETIME              -- MUST BE < NOW TO GET ACTUAL DAYS, NOT PREDICTED DAYS
  , @is_monthly bit = 0
AS
BEGIN

    SET NOCOUNT ON;
	
	DECLARE 
		@vis_monthly bit;

SET @vis_monthly = @is_monthly;

IF @vis_monthly = 0 
BEGIN
    WITH CR AS (
        SELECT fac_id,
               client_id,
               IIF(effective_date < @start_date, @start_date, effective_date) AS fromDate,
               IIF(ineffective_date > @end_date, @end_date, ineffective_date) AS toDate
        FROM reporting.ldl_view_fact_CensusRate WITH (NOLOCK)
        WHERE census_id <> -1
          AND is_secondary_bed = 0
          AND effective_date < @end_date
          AND ineffective_date > @start_date
          AND fac_id IN (SELECT id FROM @fac_ids)
    )

    SELECT fac_id,
           DATEDIFF(DAY, @start_date, @end_date) AS day_count,
           COUNT(DISTINCT client_id)             AS patient_count,
           SUM(DATEDIFF(DAY, fromDate, toDate))  AS patient_days
    FROM CR
    GROUP BY fac_id;
END
ELSE
BEGIN

DECLARE @fac_dates TABLE(fac_id int, [start_date] datetime, end_date datetime);

INSERT INTO @fac_dates
SELECT f.id, d.[start_date],d.[end_date]
FROM (
SELECT 
	 CASE WHEN @start_date >= firstdayofmonth THEN @start_date 
		ELSE firstdayofmonth END AS [start_date]
	,CASE WHEN @end_date <= lastdayofmonth THEN @end_date 
		ELSE DATEADD(DD,daysInMonth,firstdayofmonth) END AS end_date
FROM [reporting].[ldl_view_dim_Date]
WHERE fulldatetime >= @start_date AND fulldatetime < @end_date
GROUP BY lastdayofmonth, firstdayofmonth,daysInMonth) d
CROSS JOIN @fac_ids f
ORDER BY id,[start_date];

    WITH cte_count AS (
        SELECT c.fac_id,
               c.client_id,
			   f.start_date,
			   f.end_date,
			   DATEDIFF(DD,f.[start_date],f.end_date) AS day_count,
			   DATEDIFF(DD,(CASE WHEN c.effective_date < f.[start_date] THEN f.[start_date] 
			   ELSE c.effective_date END),
               (CASE WHEN c.ineffective_date > f.end_date THEN f.end_date
			         WHEN c.ineffective_date < f.[start_date] THEN f.[start_date]
					 ELSE c.ineffective_date END)) AS patient_days
        FROM [reporting].[ldl_view_fact_CensusRate] c WITH (NOLOCK)
		INNER JOIN @fac_dates f
			ON f.fac_id = c.fac_id
        WHERE c.census_id <> -1
          AND c.is_secondary_bed = 0
          AND c.effective_date < f.end_date
          AND c.ineffective_date > f.[start_date]

    )
    SELECT 
		 fac_id
		,MONTH(start_date) AS [month]
		,YEAR(start_date) AS [year]
		,day_count
		,COUNT(DISTINCT client_id) AS patient_count
		,SUM(patient_days) AS patient_days
    FROM cte_count
    GROUP BY fac_id,day_count,[start_date]
	ORDER BY fac_id, [start_date];
END

END

GO
GRANT EXECUTE ON [reporting].sproc_pho_list_getPatientDays TO PUBLIC;
GO


GO

print 'G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_pho_list_getPatientDays.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_pho_list_getPatientDays.sql',getdate(),'4.4.9_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.9_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

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
values ('4.4.9_G', 'upload_history')


GO

print '..\Update db version.sql --****SCRIPT DONE****'

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.9_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

GO

insert into upload_tracking (script,timestamp,upload) values ('UPLOAD END',getdate(),'4.4.9_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')