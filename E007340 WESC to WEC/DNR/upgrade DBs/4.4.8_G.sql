SET NOCOUNT ON
GO

SET DEADLOCK_PRIORITY HIGH
GO


insert into upload_tracking (script, timestamp, upload) values ('UPLOAD_START',getdate(),'4.4.8_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_etl_FactPDPMRevenue_Extract_Delta.sql',getdate(),'4.4.8_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

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

insert into upload_tracking(script,timestamp,upload) values ('G_EnterpriseReporting_Branch/5_StoredProcedures/reporting.sproc_etl_FactPDPMRevenue_Extract_Delta.sql',getdate(),'4.4.8_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.8_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

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
values ('4.4.8_G', 'upload_history')


GO

print '..\Update db version.sql --****SCRIPT DONE****'

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.8_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')

GO

insert into upload_tracking (script,timestamp,upload) values ('UPLOAD END',getdate(),'4.4.8_06_CLIENT_G_EnterpriseReporting_Branch_US.sql')