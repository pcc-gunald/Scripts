SET NOCOUNT ON
GO

SET DEADLOCK_PRIORITY HIGH
GO


insert into upload_tracking (script, timestamp, upload) values ('UPLOAD_START',getdate(),'4.4.9_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_CopyClinicalConfiguration.sql',getdate(),'4.4.9_06_CLIENT_K_Operational_Branch_US.sql')

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


IF EXISTS (
		SELECT *
		FROM dbo.sysobjects
		WHERE id = object_id(N'[operational].[sproc_CopyClinicalConfiguration]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [operational].[sproc_CopyClinicalConfiguration]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [operational].[sproc_CopyClinicalConfiguration] @srcSvrName VARCHAR(100)
	,@srcDBName VARCHAR(100)
	,@srcFacID INT
	,@dstFacID INT
	,@CaseNo VARCHAR(50)
	,@ModuletoCopy VARCHAR(100)
	,@DebugMe CHAR(1) = 'N'
	,@status_code INT OUT
	,@status_text VARCHAR(3000) OUT
AS
SET NOCOUNT ON

DECLARE @error_code INT
DECLARE @srcFacIDStr VARCHAR(10)
DECLARE @dstFacIDStr VARCHAR(10)

DECLARE @sql_update NVARCHAR(max)
DECLARE @sql_insert NVARCHAR(max)
DECLARE @sql_POC_timeout NVARCHAR(max)
DECLARE @sql_cp_signature_page_text NVARCHAR(max)


BEGIN TRY

SET @srcFacIDStr = CONVERT(VARCHAR(10), @srcFacID)
SET @dstFacIDStr = CONVERT(VARCHAR(10), @dstFacID)
SET @status_code = 0 ---- Status Code 0 = Success, 1 = Exception

--INSERT THE MODULES TO COPY -- insert ALL for complete copy----------------------------------------------------------------------
	
	--[noformat]
	DROP TABLE IF EXISTS #tmpModulesCopy
		CREATE TABLE #tmpModulesCopy (moduleID VARCHAR(10));

	INSERT INTO #tmpModulesCopy
	SELECT *
	FROM string_split(@ModuletoCopy, ',')

	DROP TABLE IF EXISTS #tmpConfigNamesCopy
		CREATE TABLE #tmpConfigNamesCopy (ConfigName VARCHAR(500))  --[/noformat]

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('C1')
			) --General Configuration = C1
		INSERT INTO #tmpConfigNamesCopy
		SELECT *
		FROM string_split('phys_visit_admit_interval_2,phys_visit_admit_period_2,shiftreport_show_wv,shiftreport_show_immun,facepain_use_cartoon,task_manager_module,task_manager_module_revision_by,task_manager_module_revision_date,allow_edit_saved_notes,allow_deletion_or_strike_out,enable_potential_medicare_res,phys_visit_settings,enable_einteract_alerts_enterpise,einteract_hospital_portal_enabled,enable_einteract_hospital_portal_revised_by,enable_einteract_hospital_portal_revised_date,enable_einteract_alerts,enable_einteract_alerts_revised_by,enable_einteract_alerts_revised_date,enable_einteract_qi_tools,enable_einteract_qi_tools_by,enable_einteract_qi_tools_date,care_program_module,care_program_module_revision_by,care_program_module_revision_date,enable_einteract_tranform_form,enable_einteract_tranform_form_revised_by,enable_einteract_tranform_form_revised_date,phys_visit_predate_admis,kardex_term,term_assessment,term_fcs,term_gol,term_intrvntn,term_tsk', ',')

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('C2')
			) --Care Plan Configuration  = C2
	BEGIN
		INSERT INTO #tmpConfigNamesCopy
		SELECT *
		FROM string_split(
				'care_plan_report_include_special_instructions,care_plan_kardex_include_special_instructions,second_title,second_state_facid,second_medicaid_prov,second_medicare_prov,cp_review_date_default,cp_allow_blank_cprep,cp_allow_blank_flowrep,cp_allow_target_goal,GOAL_TEXT,care_plan_type,cp_allow_page_num,cp_sign_lines,flow_sign_lines,cp_report_allergies_on_all_pages,cp_report_diagnoses_on_all_pages,fs_rpt_dob_display,cp_last_rev_date_display,cp_report_punch_hole,cp_report_include_print_date,flowsheet_report_include_print_date,cp_break_after_focus_cprep,cp_include_photo_cprep,cp_include_photo_flowrep,cp_inter_postion_man,cp_incomplete_items,cp_prompt_pn_on_change,cp_allow_init_date_for_focus,cp_allow_init_date_for_goal,cp_allow_init_date_for_interv,cp_allow_created_date_for_focus,cp_allow_created_date_for_goal,cp_allow_created_date_for_interv,cp_allow_created_by_for_focus,cp_allow_created_by_for_goal,cp_allow_created_by_for_interv,cp_allow_rev_date_for_focus,cp_allow_rev_date_for_goal,cp_allow_rev_date_for_interv,cp_allow_rev_by_for_focus,cp_allow_rev_by_for_goal,cp_allow_rev_by_for_interv,cp_view_num_triggered_items,cp_auto_close_cp,care_plan_types_show_or_hide'
				, ',')

		SET @sql_cp_signature_page_text = N'IF EXISTS (
		SELECT 1
		FROM [' + @srcSvrName + '].[' + @srcDBName + '].dbo.prp_report_configuration_parameter WITH (NOLOCK)
		WHERE fac_id = ' + @srcFacIDStr + '
			AND NAME = ''cp_signature_page_text''
			AND effective_date = (
				SELECT max(effective_date)
				FROM [' + @srcSvrName + '].[' + @srcDBName + '].dbo.prp_report_configuration_parameter WITH (NOLOCK)
				WHERE fac_id = ' + @srcFacIDStr + '
					AND NAME = ''cp_signature_page_text''
				)
		)
		BEGIN
			if exists (select 1 from prp_report_configuration_parameter WITH (NOLOCK) where fac_id = ' + @dstFacIDStr + ' and name = ''cp_signature_page_text'' and ineffective_date is null)
			begin
				update prp_report_configuration_parameter 
				set ineffective_date = getdate()
				where fac_id = ' + @dstFacIDStr + 
			' and name = ''cp_signature_page_text'' and ineffective_date is null
			END

			INSERT INTO prp_report_configuration_parameter (
				fac_id
				,NAME
				,value
				,effective_date
				,created_by
				)
			SELECT ' + @dstFacIDStr + ' AS fac_id
				,NAME
				,value
				,getdate() AS effective_date
				,''' + @CaseNo + ''' AS created_by
			FROM [' + @srcSvrName + '].[' + @srcDBName + '].dbo.prp_report_configuration_parameter WITH (NOLOCK)
			WHERE fac_id = ' + @srcFacIDStr + '
				AND NAME = ''cp_signature_page_text''
				AND effective_date = (
					SELECT max(effective_date)
					FROM [' + @srcSvrName + '].[' + @srcDBName + '].dbo.prp_report_configuration_parameter WITH (NOLOCK)
					WHERE fac_id = ' + @srcFacIDStr + '
						AND NAME = ''cp_signature_page_text''
					)
		END'

		--PRINT @sql_cp_signature_page_text
		EXEC sp_executesql @sql_cp_signature_page_text
	END

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('C3')
			) --Task Configuration = C3
		INSERT INTO #tmpConfigNamesCopy
		SELECT *
		FROM string_split('second_title,second_state_facid,second_medicaid_prov,second_medicare_prov,task_on_cp,show_task_on_cp,task_on_flowsheet,task_on_res_cp,task_on_res_krdx_rpt,task_position', ',')

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('C4')
			) --Diagnosis Configuration = C4
		INSERT INTO #tmpConfigNamesCopy
		SELECT *
		FROM string_split('diag_find_view_default,allow_future_date_diagnosis,diag_lib_default,diag_lib_code_colour,diag_lib_mandatory_rank,allow_incomplete_diag_codes,diag_defaultEffDate,show_specificity_on_client,diag_default_prim,diag_default_ther,diag_enforce,diag_chart_to_sheet,therapy_to_chart,diag_auto_create_ds,diagnosis_sheet,diag_display_classification,diag_display_confidentiality,enable_diagnosis_clinical_category,diag_inbound_diagnosis_rank,diag_display_rank,enable_icd10_conversion,enable_inbound_diagnosis,inbound_medical_diagnosis_allowed,inbound_therapy_diagnosis_allowed,diag_inbound_strikeout_resolve', ',')

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('C6')
			) --Risk Management Configuration = C6
		INSERT INTO #tmpConfigNamesCopy
		SELECT *
		FROM string_split('second_title,second_state_facid,second_medicaid_prov,second_medicare_prov,show_post_incident_injury,risk_privacy_confidentiality_statement,allow_lock_detail_injury_factor,lock_entire_incident_upon_first_signature', ',')

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('C7')
			) --POC General Configuration = C7
	BEGIN
		INSERT INTO #tmpConfigNamesCopy
		SELECT *
		FROM string_split('second_title,second_state_facid,second_medicaid_prov,second_medicare_prov,poc_readmission_autocreate,poc_timeout,poc_readmission_threshold,fuq_options,fuq_options_for_mds_g,poc_lateEntry,disable_task_doc,disable_intr_doc,next_shift_threshold,pcc_schedule_timerange,enable_res_nab,disable_keyboard,generate_past_sd,poc_cur_shift_not_allow_doc_in_future,poc_cur_shift_not_allow_doc_in_future_min,complex_alert_shift_day_included,complex_alert_shift_evening_included,complex_alert_shift_night_included,complex_alert_shift_day_start,complex_alert_shift_day_end,complex_alert_shift_evening_start,complex_alert_shift_evening_end,complex_alert_shift_night_start,complex_alert_shift_night_end,short_code_resident_refused,short_code_resident_not_available,short_code_not_applicable,poc_advanced_reporting,poc_adv_report_npo_short_code,poc_adv_report_tube_short_code', ',')

		SET @sql_POC_timeout = N'UPDATE facility SET poc_timeout = (SELECT poc_timeout FROM [' + @srcSvrName + '].[' + @srcDBName + '].dbo.facility WITH (NOLOCK) WHERE fac_id = ' + @srcFacIDStr + ' ) WHERE fac_id = ' + @dstFacIDStr

		--PRINT @sql_POC_timeout
		EXEC sp_executesql @sql_POC_timeout
	END

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('C8')
			) --Physician Orders Configuration = C8, after "enable_medication_review_report_version" are new list
		INSERT INTO #tmpConfigNamesCopy
		SELECT *
		FROM string_split(				'def_med_searchOpt,pho_is_using_new_phys_order_form,overdue_grace_period_on_emar,enable_dose_check,enable_emar_assignments,second_title,second_state_facid,second_medicaid_prov,second_medicare_prov,pho_pop_drug_code,pho_enable_edo,pho_config_active_lib,pho_def_med_lib_view,show_pmar_order_date,pho_config_show_dates,pho_config_show_photo,pho_show_time_code,pho_mar_show_time_desc,pho_show_schedtype,pho_config_show_form,pho_show_admin_time,pho_config_show_diag,pho_number_of_orders_per_page_blank_admrep,pho_print_labels_on_blank_admrep_allowed,pho_print_labels_lines,pho_config_header,show_pmar_nurse_admin_notes,show_pmar_diet,show_pmar_allergies,show_pmar_adv_directives,show_pmar_med_conditions,show_pmar_footer_only_on_last,pho_allow_blank_admrep,pho_allow_blank_consrep,pho_phys_sig_conrep,pho_phys_sig_attestation,pho_cons_show_time_desc,pho_pharmreq_show_time_desc,pho_pharmreq_show_mar_start_date,pho_hold_code_admrep,pho_show_ordertype_consrep,pho_show_discmes_consrep,pho_show_restcol_consrep,pho_show_incstartdate_consrep,pho_routine_drug_refill_consrep,pho_dur_between_review,pho_dur_units,pho_tel_order_print_on_save,pho_require_duration_hold_order,pho_manual_locking,pho_allow_blank_medreviewrep,pho_phys_sig_medreviewrep,pho_show_ordertype_medreviewrep,pho_show_timedesc_medreviewrep,pho_show_discmes_medreviewrep,pho_show_restcol_medreviewrep,pho_show_incstartdate_medreviewrep,pho_routine_drug_refill_medreviewrep,pho_pmar_show_unscheduled_other,show_on_pharmacy_form,mandatory_on_pharmacy_form,show_on_pharmacy_order,show_on_diet_form,mandatory_on_diet_form,show_on_diet_order,show_on_diet1_form,mandatory_on_diet1_form,show_on_diet1_order,show_on_diet2_form,mandatory_on_diet2_form,show_on_diet2_order,show_on_diet3_form,mandatory_on_diet3_form,show_on_diet3_order,show_on_lab_form,mandatory_on_lab_form,show_on_lab_order,show_on_diag_form,mandatory_on_diag_form,show_on_diag_order,show_on_other_form,mandatory_on_other_form,show_on_other_order,pho_rx_scannable,pho_rx_mask,lock_ext_lib_fields,pho_draft_order_field_locking,dc_orders_require_reason,dc_orders_require_order_noted_by,pho_dc_orders_require_communication_method,pho_phys_order_verification,pho_duration_to_show_dc_orders_on_chart,pho_allow_reordering_of_orders_on_hold,pho_show_unverified_orders_on_admin_record,pho_allow_days_before_next_refill,pho_use_allow_days_before_next_refill,pho_use_wait_minimum_days_after_last_order,pho_wait_minimum_days_after_last_order,pho_freq_type,pho_save_mode,pho_schedule_details,pho_integration,pho_term_for_advanced_directive,pho_integration_type,enable_emar,pho_override_schedules,pho_override_directions,enable_quick_entry,enable_ext_lib,check_duplicates,check_interactions,show_generics,pho_stdtimes_setup,pho_stdfreq_to_stdtimes_mapping_setup,pho_alt_med_showonorderform,pho_alt_med_autorecvorders,pho_alt_med_reqpharmconfonreorder,pho_alt_med_showondrb,pho_alt_med_allowchgonreorder,pho_alt_med_defaultpharmonreorder,pho_alt_med_notpharmacysuppliedOrder,show_ebox_on_emar,pho_barcode_exp,pho_rcv_link,pho_rx_link,pho_rx_on_reorder,pharmacy_order_review_required,pho_autopopulated_directions_editable,pho_switch_supply_from_scan_discrepancy,enable_autoreceiving,enable_autoreceiving_by,enable_autoreceiving_date,enable_barcode_scanning,enable_barcode_scanning_by,enable_barcode_scanning_date,enable_inline_emar_receiving,enable_inline_emar_receiving_by,enable_inline_emar_receiving_date,enable_order_readback,enable_order_readback_by,enable_order_readback_date,pho_interaction_level_of_severity_minor,pho_interaction_level_of_severity_moderate,pho_interaction_level_of_severity_severe,default_pain_scale_for_prn_only,enable_medication_review_report_version,order_sign_enable,order_sign_enable_by,order_sign_enable_date,dea_setup_enabled_by,dea_setup_enabled_date,enable_dea_setup,default_communication_method_enabled_by,default_communication_method,default_communication_method_enabled_date,enable_one_signature,enable_one_signature_enabled_by,enable_one_signature_enabled_date,enable_pharmacy_requisition_report_version,enable_tele_verbal_report_version,pho_duplicate_tv_order_form,require_res_ssn,require_res_ssn_modified_date,require_res_ssn_modified_by,default_pain_scale_for_routine_date,default_pain_scale_for_routine_by,default_pain_scale_for_routine,default_pain_scale_for_prn_only_date,default_pain_scale_for_prn_only_by,enable_clinical_review_date,enable_clinical_review_author,enable_clinical_review,drug_interaction_enabled_date,drug_interaction_enabled_by,enable_drug_interaction,black_box_enabled_date,black_box_enabled_by,enable_black_box,dose_check_enabled_date,dose_check_enabled_by,drug_image_enabled_date,drug_image_enabled_by,enable_drug_image,drug_information_sheet_enabled_by,drug_information_sheet_enabled_date,enable_drug_information_sheet,drug_allergy_enabled_date,drug_allergy_enabled_by,enable_drug_allergy_check,enable_emar_pi_orders_date,enable_emar_pi_orders_by,enable_emar_pi_orders,enable_mmit_formulary_check,enable_mmit_formulary_check_by,enable_mmit_formulary_check_date,range_dosing_enabled,range_dosing_enabled_by,range_dosing_enabled_date,enable_resident_barcode_scanning,enable_resident_barcode_scanning_by,enable_resident_barcode_scanning_date,pharmacy_initiated_order_require_ifu,pharmacy_initiated_order_require_ifu_enabled_by,pharmacy_initiated_order_require_ifu_enabled_date,enable_complex_updates_on_fi,enable_complex_updates_on_fi_by,enable_complex_updates_on_fi_date,enable_indication_for_use_simple_update_for_pharmacy_order,enable_indication_for_use_simple_update_for_pharmacy_order_by,enable_indication_for_use_simple_update_for_pharmacy_order_date,enable_indication_for_use_simple_updates_on_pi,enable_indication_for_use_simple_updates_on_pi_by,enable_indication_for_use_simple_updates_on_pi_date', ',')

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('C9')
			) --Weights & Vitals Configuration = C9
		INSERT INTO #tmpConfigNamesCopy
		SELECT *
		FROM string_split('second_title,second_state_facid,second_medicaid_prov,second_medicare_prov,wv_hideabw,wv_hidebmi,wv_hidegoalw,abw_calc_type,bmi_min_val,bmi_max_val,wv_grace_day,bs_unit_of_measure', ',')

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('C10')
			) --MDS Warnings = C10
		INSERT INTO #tmpConfigNamesCopy
		SELECT *
		FROM string_split('second_title,second_state_facid,second_medicaid_prov,second_medicare_prov,as_mds_warnings_on_flag,as_mds_sig_change_on_flag,as_mds_j2a_warning_on_flag,as_mds_r2b_ard_warning_on_flag,as_mds_r2b_r2b92_warning_on_flag,as_mds_e_before_b1_warning_on_flag,as_mds_cpydiag_warning_on_flag,as_mds_r2b_signsect_warning_on_flag,as_mds_t2_warning_on_flag,as_mds_vb2_vb4_7days_warning_on_flag,as_mds_a7_warning_on_flag', ',')

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('C11')
			) --EMAR Configuration = C11
		INSERT INTO #tmpConfigNamesCopy
		SELECT *
		FROM string_split('emar_keyboard_enabled,due_now_grace_period_on_emar,pho_populate_pn_auto,pho_prn_admin_pn_required,show_directions_on_emar,show_form_on_emar,show_time_code_on_emar,show_time_desc_on_emar,show_schedule_type_on_emar,show_use_last_recorded_value,show_record_new_entry,show_by_pass,overdue_grace_period_on_emar,pho_duration_to_show_dc_orders_on_emar,pho_duration_to_show_dc_orders_on_emar_eom', ',')

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('C12')
			) --Evaluation Configuration = C12
		INSERT INTO #tmpConfigNamesCopy
		SELECT *
		FROM string_split('show_uda_assessment_due_in,uda_esignature,kardex_print_format,rca_kardex_diet_info,enable_assessment_mapping_tool,sl_wants_mds_override', ',')

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('C13')
			) --Terminology Configuration = C13
		INSERT INTO #tmpConfigNamesCopy
		SELECT *
		FROM string_split('kardex_term,term_assessment,term_fcs,term_gol,term_intrvntn,term_tsk', ',')

	--UPDATE existing value
	SET @sql_update = N'UPDATE dst
SET dst.value = src.value
FROM configuration_parameter dst WITH (NOLOCK) 
INNER JOIN [' + @srcSvrName + '].[' + @srcDBName + '].dbo.configuration_parameter src WITH (NOLOCK) ON src.NAME = dst.NAME
WHERE src.fac_id = ' + @srcFacIDStr + ' 
	AND dst.fac_id = ' + @dstFacIDStr + ' 
	AND src.NAME IN (
		SELECT ConfigName
		FROM #tmpConfigNamesCopy
		)'

	--PRINT @sql_update
	EXEC sp_executesql @sql_update

	--PRINT 'UPDATE configuration_parameter  -  ' + cast(@@ROWCOUNT AS NVARCHAR(20))
	--INSERT new value configuration_parameter  
	SET @sql_insert = N'INSERT INTO configuration_parameter   
SELECT ' + @dstFacIDStr + ' AS fac_id
	,src.NAME
	,src.value
FROM [' + @srcSvrName + '].[' + @srcDBName + '].dbo.configuration_parameter src WITH (NOLOCK)
WHERE src.fac_id = ' + @srcFacIDStr + ' 
	AND src.NAME NOT IN (
		SELECT NAME
		FROM configuration_parameter WITH (NOLOCK) --dest db
		WHERE fac_id = ' + @dstFacIDStr + '
		)
	AND src.NAME IN (
		SELECT ConfigName
		FROM #tmpConfigNamesCopy
		)'

	--PRINT @sql_insert
	EXEC sp_executesql @sql_insert

	--PRINT 'INSERT configuration_parameter  -  ' + cast(@@ROWCOUNT AS NVARCHAR(20))
	--select @status_code --as status_code
	SELECT @dstFacID
		,0

	GOTO PgmSuccess
END TRY

BEGIN CATCH
	SELECT @error_code = @@error
		,@status_text = ERROR_MESSAGE()

	SELECT @status_code = 1

	SELECT @dstFacID AS fac_id
		,1 AS flag

	GOTO PgmAbend
END CATCH

--program success return
PgmSuccess:

IF @status_code = 0
BEGIN
	IF @DebugMe = 'Y'
		PRINT 'Successfully copy configuration set up for fac_id: ' + @dstFacIDStr + '    ' + convert(VARCHAR(26), getdate(), 109)

	RETURN 0
END

--program failure return
PgmAbend:

BEGIN
	IF @DebugMe = 'Y'
		PRINT 'failed to copy configuration set up for fac_id: ' + convert(VARCHAR(10), @dstFacID) + '    ' + convert(VARCHAR(26), getdate(), 109)

	IF @DebugMe = 'Y'
		PRINT 'Error code: ' + convert(VARCHAR(10), @error_code) + '; Error description:   ' + @status_text

	--SELECT 'Error occurred: ' + @status_text AS sp_error_msg
	RETURN - 100
END
GO

GO

print 'K_Operational_Branch/5_StoredProcedures/sproc_CopyClinicalConfiguration.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_CopyClinicalConfiguration.sql',getdate(),'4.4.9_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_CopyClinicalConfigurationValidation.sql',getdate(),'4.4.9_06_CLIENT_K_Operational_Branch_US.sql')

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


IF EXISTS (
		SELECT *
		FROM dbo.sysobjects
		WHERE id = object_id(N'[operational].[sproc_CopyClinicalConfigurationValidation]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [operational].[sproc_CopyClinicalConfigurationValidation]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [operational].[sproc_CopyClinicalConfigurationValidation] @srcSvrName VARCHAR(100)
	,@srcDBName VARCHAR(100)
	,@srcFacID INT
	,@dstFacIDs VARCHAR(255)
	,@CaseNo VARCHAR(50)
	,@ModuletoCopy VARCHAR(100)
	,@DebugMe CHAR(1) = 'N' --set it as 'Y' if need to indicate whether the copy is done successfully or not
	,@status_code INT OUT
	,@status_text VARCHAR(3000) OUT
AS
SET NOCOUNT ON

DECLARE @error_code INT
DECLARE @error_msg VARCHAR(max)
DECLARE @sql_HealthType NVARCHAR(max)
DECLARE @srcFacIDStr VARCHAR(10)
DECLARE @srcHealthType VARCHAR(25)
DECLARE @request_fac INT
DECLARE @valid_fac INT
DECLARE @InvalidFacIDs_Resident AS VARCHAR(max)
DECLARE @InvalidFacIDs_HealthType AS VARCHAR(max)

BEGIN TRY

SET @srcFacIDStr = CONVERT(VARCHAR(10), @srcFacID)
SET @srcHealthType = ''
SET @sql_HealthType = N'select @HealthType=health_type from [' + @srcSvrName + '].[' + @srcDBName + '].dbo.facility WITH (NOLOCK) where fac_id=' + @srcFacIDStr

EXEC sp_executesql @sql_HealthType
	,N'@HealthType varchar(25) out'
	,@srcHealthType OUT

SET @status_code = 0 ---- Status Code 0 = Success, 1 = Exception

--since configuration_parameter_history table capture all the changes, no need to back up configuration_parameter table.
	/*
IF OBJECT_ID(N'pcc_temp_storage.._bkp_configuration_parameter_' + @CaseNo, N'U') IS NOT NULL
	EXEC ('DROP TABLE pcc_temp_storage.dbo._bkp_configuration_parameter_' + @CaseNo)

EXEC ('SELECT * INTO pcc_temp_storage.dbo._bkp_configuration_parameter_' + @CaseNo + ' FROM configuration_parameter')
*/

--[noformat]
	DROP TABLE IF EXISTS #facility		

	DROP TABLE IF EXISTS #copy_result  --[/noformat]
		CREATE TABLE #copy_result (
			fac_id INT
			,flag INT
			)

	--get facilities which has the same healty type as source facility and do not have any resident
	SELECT fac_id
		,name AS facility
		,row_number() OVER (
			ORDER BY fac_id
			) AS rown
	INTO #facility
	FROM facility WITH (NOLOCK)
	WHERE fac_id IN (
			SELECT [value]
			FROM string_split(@dstFacIDs, ',')
			)
		AND fac_id NOT IN (
			SELECT DISTINCT fac_id
			FROM clients WITH (NOLOCK)
			WHERE fac_id IN (
					SELECT [value]
					FROM string_split(@dstFacIDs, ',')
					)
			)
		AND health_type = @srcHealthType

	SELECT @request_fac = count(*)
	FROM (
		SELECT [value]
		FROM string_split(@dstFacIDs, ',')
		) AS tb

	SELECT @valid_fac = count(*)
	FROM #facility

	IF @request_fac = @valid_fac
	BEGIN
		DECLARE @FailedFacIDs AS VARCHAR(max)
		DECLARE @fcount INT
		DECLARE @n INT

		SET @n = 1

		SELECT @fcount = count(*)
		FROM #facility

		WHILE @n <= @fcount
		BEGIN
			DECLARE @dstFacID INT

			SELECT @dstFacID = fac_id
			FROM #facility
			WHERE rown = @n

			--if @DebugMe='Y' Print 'Begin copy fac_id: ' + convert(varchar(3),@dstFacID) + '   ' + convert(varchar(26),getdate(),109)
			INSERT INTO #copy_result
			EXECUTE operational.sproc_CopyClinicalConfiguration @srcSvrName
				,@srcDBName
				,@srcFacID
				,@dstFacID
				,@CaseNo
				,@ModuletoCopy
				,@DebugMe = 'N'
				,@status_code = NULL
				,@status_text = NULL

			--if @DebugMe='Y' Print 'Successfully copy fac_id: ' + convert(varchar(3),@dstFacID) + '   ' + convert(varchar(26),getdate(),109)
			SET @n = @n + 1
		END

		IF EXISTS (
				SELECT 1
				FROM #facility
				WHERE fac_id NOT IN (
						SELECT fac_id
						FROM #copy_result
						WHERE flag = 0
						)
				)
		BEGIN
			SELECT @FailedFacIDs = Coalesce(@FailedFacIDs + ', ', '') + cast(fac_id AS VARCHAR(10))
			FROM #facility
			WHERE fac_id NOT IN (
					SELECT fac_id
					FROM #copy_result
					WHERE flag = 0
					)

			SELECT @error_msg = 'Stored procedure failed when copied fac_id: ' + @FailedFacIDs + '    ' + convert(VARCHAR(26), getdate(), 109)

			RAISERROR (
					@error_msg
					,16
					,1
					)
				--set @status_code=2
		END
				--select @FailedFacIDs
	END
	ELSE
	BEGIN
		SELECT @InvalidFacIDs_Resident = Coalesce(@InvalidFacIDs_Resident + ',', '') + cast(c.fac_id AS VARCHAR(25))
		FROM (
			SELECT DISTINCT fac_id
			FROM clients WITH (NOLOCK)
			WHERE fac_id IN (
					SELECT [value]
					FROM string_split(@dstFacIDs, ',')
					)
			) AS c

		SELECT @InvalidFacIDs_Healthtype = Coalesce(@InvalidFacIDs_Healthtype + ',', '') + cast(f.fac_id AS VARCHAR(25))
		FROM (
			SELECT DISTINCT fac_id
			FROM facility WITH (NOLOCK)
			WHERE fac_id IN (
					SELECT [value]
					FROM string_split(@dstFacIDs, ',')
					)
				AND health_type <> @srcHealthType
			) AS f

		SELECT @error_msg = CASE 
				WHEN @InvalidFacIDs_Resident IS NOT NULL
					AND @InvalidFacIDs_Healthtype IS NULL
					THEN 'Following facilities have residents: ' + @InvalidFacIDs_Resident + '. No clinical configuration is copied for any required facilities.  Please submit valid facilities.  ' + convert(VARCHAR(26), getdate(), 109)
				WHEN @InvalidFacIDs_Resident IS NULL
					AND @InvalidFacIDs_Healthtype IS NOT NULL
					THEN 'The health types of following facilities are different from the source facility: ' + @InvalidFacIDs_HealthType + '. No clinical configuration is copied for any required facilities.  Please submit valid facilities.  ' + convert(VARCHAR(26), getdate(), 109)
				ELSE 'Following facilities have residents: ' + @InvalidFacIDs_Resident + '. And the health types of following facilities are different from the source facility: ' + @InvalidFacIDs_HealthType + '. No clinical configuration is copied for any required facilities. Please submit valid facilities. ' + convert(VARCHAR(26), getdate(), 109)
				END

		RAISERROR (
				@error_msg
				,16
				,1
				)
	END

	GOTO PgmSuccess
END TRY

BEGIN CATCH
	SELECT @error_code = @@error
		,@status_text = ERROR_MESSAGE()

	SELECT @status_code = 1

	GOTO PgmAbend
END CATCH

--program success return
PgmSuccess:

IF @status_code = 0
BEGIN
	IF @DebugMe = 'Y'
		PRINT 'Successfully copied all facilities'

	SELECT 'Stored procedure executed successfully.' AS sp_msg

	RETURN 0
END

--program failure return
PgmAbend:

BEGIN
	--if @DebugMe='Y' Print 'Stored procedure failed when copied fac_id: '+ @FailedFacIDs + '    ' + convert(varchar(26),getdate(),109)
	IF @DebugMe = 'Y'
		PRINT 'Error code: ' + convert(VARCHAR(10), @error_code) + '; Error description:   ' + @status_text

	SELECT 'Error occurred: ' + @status_text AS sp_error_msg

	RETURN - 100
END
GO

GO

print 'K_Operational_Branch/5_StoredProcedures/sproc_CopyClinicalConfigurationValidation.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_CopyClinicalConfigurationValidation.sql',getdate(),'4.4.9_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_Facility_Extract.sql',getdate(),'4.4.9_06_CLIENT_K_Operational_Branch_US.sql')

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




if exists(select 1 from sys.procedures where name = 'sproc_facility_extract')
begin
	drop procedure operational.sproc_facility_extract
end
GO




/****** Object:  StoredProcedure [operational].[sproc_facility_extract]    Script Date: 1/12/2022 2:14:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- author:    lily yin
-- create date: 20220107
-- description:      this sproc will return facility extract
-- env:  CDN and US
-- Ticket #: CORE-99100
-- =============================================
CREATE PROC [operational].[sproc_facility_extract] (
	@orgcode varchar(50),
	@facid varchar(1000),
	@debugMe CHAR(1) = 'N'
	)
AS

BEGIN

	set nocount on; 




	IF @DebugMe = 'Y'
			print 'facility extract'

	drop table if exists #facId

	if @facid<>'ALL'
		begin

			select value into #facId from string_split(@facId, ',')
		
			select distinct @orgcode as PccOrgCode,
			f.fac_id as PccFacilityId,
			f.facility_code as FacilityCode,
			f.name as FacilityName,
			f.health_type as LineOfBusiness,
			f.address1 + ' ' +f.address2 as Address,
			f.city as City,
			f.prov as State,
			f.pc as ZipCode,
			@orgCode+(SELECT RIGHT('0000'+CAST(f.fac_id AS VARCHAR(4)),4)) as SendingFacilityIdExternal,
			ac.identifier_npi as NPI,
			ar.provider_taxonomy_code as ProviderTaxonomyCode
			from facility f
			inner join ar_configuration ac on f.fac_id=ac.fac_id and f.deleted='N' and f.inactive is null and f.inactive_date is null and ac.deleted='N'
			inner join ar_submitter  ar on ar.fac_id=f.fac_id 
			where f.fac_id in (select value from #facId) and ar.provider_taxonomy_code is not null and ar.provider_taxonomy_code<>''

		END
		
	else
		begin
			select distinct @orgcode as PccOrgCode,
			f.fac_id as PccFacilityId,
			f.facility_code as FacilityCode,
			f.name as FacilityName,
			f.health_type as LineOfBusiness,
			f.address1 + ' ' +f.address2 as Address,
			f.city as City,
			f.prov as State,
			f.pc as ZipCode,
			@orgCode+(SELECT RIGHT('0000'+CAST(f.fac_id AS VARCHAR(4)),4)) as SendingFacilityIdExternal,
			ac.identifier_npi as NPI,
			ar.provider_taxonomy_code as ProviderTaxonomyCode
			from facility f
			inner join ar_configuration ac on f.fac_id=ac.fac_id and f.deleted='N' and f.inactive is null and f.inactive_date is null and ac.deleted='N'
			inner join ar_submitter  ar on ar.fac_id=f.fac_id 
			where f.fac_id in (select fac_id from facility where deleted='N' and inactive is null and inactive_date is null) 
			and ar.provider_taxonomy_code is not null and ar.provider_taxonomy_code<>''

		end

end
GO







GO

print 'K_Operational_Branch/5_StoredProcedures/sproc_Facility_Extract.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_Facility_Extract.sql',getdate(),'4.4.9_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_SecurityUsersReport.sql',getdate(),'4.4.9_06_CLIENT_K_Operational_Branch_US.sql')

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


-- For OA-115
IF EXISTS (
		SELECT 1
		FROM dbo.sysobjects
		WHERE id = object_id(N'[operational].[sproc_SecurityUsersReport]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [operational].[sproc_SecurityUsersReport]
GO

CREATE PROCEDURE [operational].[sproc_SecurityUsersReport] (
	@fac_list VARCHAR(MAX)
	,@login_filter INT
	)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @status_text VARCHAR(3000) = 'Stored procedure executed successfully.'
	DECLARE @FacIDs AS VARCHAR(MAX) = ''

	BEGIN TRY
		--============================ Selected facs to table =================================
		DROP TABLE IF EXISTS #FacSelected
			SELECT fac_id
			INTO #FacSelected
			FROM facility f WITH (NOLOCK)
			INNER JOIN (
				SELECT [value]
				FROM string_split(@fac_list, ',')
				) fl ON f.fac_id = fl.[value]
			WHERE f.deleted = 'N'

		SELECT @FacIDs = @FacIDs + ',' + CAST(fac_id AS VARCHAR)
		FROM #FacSelected

		--============================ Users' facility access =================================
		-- All fac access for non enterprise user with access to given facilities
		DROP TABLE IF EXISTS #user_access
			SELECT suf.userid
				,CAST(suf.facility_id AS VARCHAR) AS fac_id
				,CASE 
					WHEN ISNULL(RTRIM(LTRIM(f.facility_code)), '') = ''
						THEN '-'
					ELSE f.facility_code
					END AS facility_code
			INTO #user_access
			FROM sec_user_facility suf WITH (NOLOCK)
			INNER JOIN sec_user u WITH (NOLOCK) ON suf.userid = u.userid
				AND u.[enabled] = 'Y'
				AND ISNULL(u.admin_user_type, '') <> 'E'
			INNER JOIN facility f WITH (NOLOCK) ON suf.facility_id = f.fac_id
			WHERE suf.userid IN (
					SELECT DISTINCT userid
					FROM sec_user_facility a WITH (NOLOCK)
					INNER JOIN #FacSelected b ON a.facility_id = b.fac_id
					)

		-- Combine with enterprise users
		DROP TABLE IF EXISTS #user_facs
			SELECT DISTINCT u.userid
				,STUFF((
						SELECT ',' + fac_id
						FROM #user_access ufa
						WHERE u.userid = ufa.userid
						FOR XML PATH('')
						), 1, 1, '') AS [Facility Access]
				,STUFF((
						SELECT ',' + facility_code
						FROM #user_access ufc
						WHERE u.userid = ufc.userid
						FOR XML PATH('')
						), 1, 1, '') AS [Facility Code]
			INTO #user_facs
			FROM #user_access u
			
			UNION
			
			SELECT userid
				,'Enterprise'
				,'Enterprise'
			FROM sec_user WITH (NOLOCK)
			WHERE [enabled] = 'Y'
				AND admin_user_type = 'E'
				AND ISNULL(enterprise_user, 'N') <> 'Y'

		--================================= Users' tiger text ===================================
		DROP TABLE IF EXISTS #user_tiger_text
			SELECT u.userid
				,CAST(ft.fac_id AS VARCHAR) AS fac_id
			INTO #user_tiger_text
			FROM #user_facs u
			INNER JOIN sec_user_tigertext t WITH (NOLOCK) ON u.userid = t.[user_id]
			INNER JOIN sec_user_facility_tigertext ft WITH (NOLOCK) ON u.userid = ft.[user_id]
			WHERE t.use_automated_account = 0
			ORDER BY ft.fac_id

		--============================= Users' link to staff ==================================
		DROP TABLE IF EXISTS #user_staff_link
			SELECT u.userid
				,c.first_name + ' ' + c.last_name + ' (' + CAST(s.fac_id AS VARCHAR) + '-' + CASE 
					WHEN s.on_staff = 'Y'
						THEN 'Admin Staff'
					ELSE 'Medical Professional'
					END + ')' AS [Staff]
			INTO #user_staff_link
			FROM #user_facs u
			INNER JOIN staff s WITH (NOLOCK) ON u.userid = s.userid
				AND s.deleted = 'N'
			INNER JOIN contact c WITH (NOLOCK) ON s.contact_id = c.contact_id
				AND c.deleted = 'N'
			ORDER BY [Staff]

		--============================= Users' security roles ==================================
		DROP TABLE IF EXISTS #user_roles
			SELECT sur.userid
				,r.[description] AS [SecRole]
			INTO #user_roles
			FROM SEC_USER_ROLE sur WITH (NOLOCK)
			INNER JOIN #user_facs uf ON sur.userid = uf.userid
			INNER JOIN SEC_ROLE r WITH (NOLOCK) ON sur.ROLE_ID = r.ROLE_ID
			ORDER BY r.[description]

		--=================================== Main query ========================================
		SELECT DISTINCT STUFF(@FacIDs, 1, 1, '') AS [Selected Fac ID]
			,u.fac_id AS [Default Fac ID]
			,f.[name] AS [Default Facility Name]
			,uf.[Facility Access]
			,u.long_username AS [Long UserName]
			,u.loginname AS [Login Name]
			,ISNULL(CONVERT(VARCHAR(10), u.last_login_date, 121), '') AS [Last Login]
			,CASE 
				WHEN ISNULL(u.passwd_check, 0) = 0
					THEN ''
				ELSE 'Y'
				END AS [Has Password]
			,ISNULL(CONVERT(VARCHAR(10), u.passwd_expiry_date, 121), '') AS [Password Expiry Date]
			,CASE 
				WHEN ISNULL(u.pin_check, 0) = 0
					THEN ''
				ELSE 'Y'
				END AS [Has PIN]
			,ISNULL(CONVERT(VARCHAR(10), u.pin_expiry_date, 121), '') AS [PIN Expiry Date]
			,ISNULL(CONVERT(VARCHAR(10), u.VALID_UNTIL_DATE, 121), '') AS [Valid Until Date]
			,ISNULL(u.designation_desc, '') AS [Designation]
			,ISNULL(u.initials, '') AS [Init]
			,CASE 
				WHEN u.position_id = - 1
					OR ccd.item_id IS NULL
					THEN ''
				ELSE ccd.item_description
				END AS [Department]
			,CASE 
				WHEN u.position_id = - 1
					OR ccp.item_id IS NULL
					THEN ''
				ELSE ccp.item_description
				END AS [Position]
			,ISNULL(c.first_name + ' ' + c.last_name, '') AS [Medical Professional]
			,CASE 
				WHEN u.ext_fac_id = - 1
					THEN ''
				ELSE ISNULL(e.[name], '')
				END AS [External Facility]
			,CASE 
				WHEN u.admin_user_type = 'E'
					THEN 'Y'
				ELSE 'N'
				END AS [Ent. User]
			,ISNULL(u.remote_user, 'N') AS [Rmt User]
			,ISNULL(STUFF((
						SELECT ',' + tt.fac_id + '_Y'
						FROM #user_tiger_text tt
						WHERE u.userid = tt.userid
						FOR XML PATH('')
						), 1, 1, ''), '') AS [Mbl TT]
			,CASE 
				WHEN p.userid IS NULL
					THEN 'N'
				ELSE 'Y'
				END AS [2nd Fctr Card]
			,ISNULL(STUFF((
						SELECT ',' + [Staff]
						FROM #user_staff_link s
						WHERE u.userid = s.userid
						FOR XML PATH('')
						), 1, 1, ''), '') AS [Staff Linked to User]
			,ISNULL(STUFF((
						SELECT ',' + [SecRole]
						FROM #user_roles r
						WHERE u.userid = r.userid
						FOR XML PATH('')
						), 1, 1, ''), '') AS [Roles]
			,ISNULL(u.email, '') AS [Contact eMail Address]
			,uf.[Facility Code]
			,u.userid AS [UserID]
			,ISNULL(u.comment, '') AS [Comments]
		FROM sec_user u WITH (NOLOCK)
		INNER JOIN #user_facs uf ON u.userid = uf.userid
		LEFT JOIN facility f WITH (NOLOCK) ON u.fac_id = f.fac_id
		LEFT JOIN department_position dp WITH (NOLOCK) ON u.position_id = dp.position_id
			AND u.fac_id = dp.fac_id
		LEFT JOIN common_code ccd WITH (NOLOCK) ON dp.department_id = ccd.item_id
			AND ccd.item_code = 'dept'
		LEFT JOIN common_code ccp WITH (NOLOCK) ON u.position_id = ccp.item_id
			AND ccp.item_code = 'posit'
		LEFT JOIN contact c WITH (NOLOCK) ON u.staff_id = c.contact_id
			AND c.deleted = 'N'
		LEFT JOIN emc_ext_facilities e WITH (NOLOCK) ON u.ext_fac_id = e.ext_fac_id
			AND e.deleted = 'N'
		LEFT JOIN sec_user_physical_id p WITH (NOLOCK) ON u.userid = p.userid
		WHERE u.enabled = 'Y'
			AND NOT (
				u.enterprise_user = 'Y'
				AND u.admin_user_type = 'E'
				)
			AND u.loginname <> '_api_ipc_adf'
			AND (
				(
					@login_filter = 1
					AND u.last_login_date >= DATEADD(dd, - 7, GETDATE())
					)
				OR (
					@login_filter = 2
					AND u.last_login_date >= DATEADD(dd, - 30, GETDATE())
					)
				OR (
					@login_filter = 3
					AND u.last_login_date >= DATEADD(dd, - 90, GETDATE())
					)
				OR (
					@login_filter = 4
					AND u.last_login_date < DATEADD(dd, - 90, GETDATE())
					)
				OR @login_filter = 5
				)
		ORDER BY [Default Fac ID]
			,[Long UserName]
			,[Login Name]

		SELECT @status_text AS sp_msg

		RETURN 0
	END TRY

	BEGIN CATCH
		SET @status_text = 'Stored procedure failed with error: ' + Error_Message()

		SELECT @status_text AS sp_error_msg

		RETURN - 100
	END CATCH
END


GO

print 'K_Operational_Branch/5_StoredProcedures/sproc_SecurityUsersReport.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_SecurityUsersReport.sql',getdate(),'4.4.9_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/US_Only/CORE_94220_sproc_MDSExtractSP_core.sql',getdate(),'4.4.9_06_CLIENT_K_Operational_Branch_US.sql')

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



IF EXISTS (SELECT * FROM DBO.SYSOBJECTS
            WHERE ID = OBJECT_ID(N'operational.sproc_mdsextractsp')
            AND OBJECTPROPERTY(ID, N'ISPROCEDURE') = 1)
BEGIN
	DROP PROCEDURE [operational].[sproc_MDSExtractSP];
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- author:    Ketki Kumra
-- create date: 2021-04-29
-- description: this sproc willcreate MDS Extract
-- =============================================

CREATE PROCEDURE [operational].[sproc_MDSExtractSP]
							  @_param_org_code VARCHAR(10),
							  @assess_date_from datetime,
							  @assess_date_to datetime,
							  @CaseNumber VARCHAR(20),
							  @fac_ids VARCHAR(250),
							  @MDSStatus VARCHAR(250),
							  @DebugMe char(1)  = 'N'
							  --@STATUS_TEXT VARCHAR(3000) OUT --IT CAN BE ACCESSED IN JAVA AFTER SQL EXECUTION FOR ERROR CHECK
							

AS
BEGIN TRY 

SET NOCOUNT ON
DECLARE @USE_LAST_RUN_TIME VARCHAR(20),
		@MAXBATCHID INT, @ROWCOUNT INT,
		@INCOMPLETEEXTRACT VARCHAR(20),
		@Include_MDS2_Batches VARCHAR(20),
		@PROCESS_NAME VARCHAR(50),
		@PackageName VARCHAR(50),
		@prodTestIndicator VARCHAR(2),
		@USE_LAST_RUN_TIME_INP VARCHAR(10),
		@ERROR_MSG NVARCHAR(MAX) = NULL,
		@CONFIGPARAM INT, 
		@STEP INT,
        @ERROR_CODE INT,
		@STATUS_TEXT VARCHAR(3000),
		@LogCaseNumber VARCHAR(20),
		@RunID INT = 0
 
--set local variables

--select @rows_affected = 0


--SET @_param_org_code = 'ushd1013'
--SET @assess_date_from = '2019-01-01'
--SET @assess_date_to = '2019-01-30'
--SET @CaseNumber = '1580240123'
--SET @fac_ids = '1,2'
--SET @MDSStatus = '''Accepted'',''Modified'',''Exported'',''Export Ready'',''Completed'''
SET @Include_MDS2_Batches  = 'N'
SET @PackageName = ''
SET @prodTestIndicator = 'P'
SET @USE_LAST_RUN_TIME_INP = 'N'
set @incompleteExtract = 'N'
SET @USE_LAST_RUN_TIME = @USE_LAST_RUN_TIME_INP 
SET @PROCESS_NAME = ''



 
SELECT @FAC_IDS = NULL WHERE @FAC_IDS = 'NULL' OR @FAC_IDS = ''
--SELECT @MDSSTATUS
DECLARE @FAC_IDS_LIST TABLE(FAC_IDS VARCHAR(250))
INSERT INTO @FAC_IDS_LIST
SELECT * FROM DBO.SPLIT(REPLACE(@FAC_IDS,'''',''),',')

SELECT @MDSSTATUS = NULL WHERE @MDSSTATUS = 'NULL' OR @MDSSTATUS = ''
DECLARE @MDSSTATUS_LIST TABLE (MDSSTATUS VARCHAR(250)) 
INSERT INTO @MDSSTATUS_LIST
SELECT * FROM 	DBO.SPLIT(REPLACE(@MDSSTATUS,'''',''),',')

		SELECT @CONFIGPARAM = COUNT(*)
		FROM (
		SELECT A.*,B.*
		FROM @FAC_IDS_LIST A LEFT  JOIN
		[DBO].[CONFIGURATION_PARAMETER] B WITH (NOLOCK) ON A.FAC_IDS = B.FAC_ID
		AND B.NAME = 'MDS3_SECOND_STATE_FACID'
			)t
		WHERE [VALUE] IS NULL OR LEN([VALUE]) <= 0

			IF (@CONFIGPARAM > 0)
			BEGIN
				SELECT @ERROR_MSG = 'ONE OF FACILITY MISSING MDS CONFIG VALUE!'

				RAISERROR (
						@ERROR_MSG
						,16
						,1
						)

				RETURN;
			END

			IF(DATEDIFF(M,@assess_date_from,@assess_date_to) > 24)
			BEGIN
				SELECT @ERROR_MSG = 'DATE RANGE IS GREATER THAN 24 MONTHS!'

				RAISERROR (
						@ERROR_MSG
						,16
						,1
						)

				RETURN;
			END

			SELECT @LogCaseNumber = CaseNumber
			FROM [operational].[OA26_MDSExtract_JobLog] WITH (NOLOCK)
			WHERE [StartTime] IS NOT NULL and [EndTime] IS NULL and [Extract_Comp] IN ('N')

			IF (LEN(@LogCaseNumber) > 0)
			BEGIN
				SELECT @ERROR_MSG = 'THE MDS EXTRACT FOR OTHER CASE IS ALREADY RUNNING. PLEASE TRY AGAIN LATER!'

				RAISERROR (
						@ERROR_MSG
						,16
						,1
						)

				RETURN;
			END


--SELECT @ASSESS_DATE_FROM,@ASSESS_DATE_TO,@FAC_IDS

--Step 1
--Create Assessment Batches
  if @DebugMe='Y' Print 'BEGIN STEP 1 Create Assessment Batches' + '   ' + convert(varchar(26),getdate(),109)

TRUNCATE TABLE [operational].[OA26_MDSExtract_TmpXML]

INSERT INTO [operational].[OA26_MDSExtract_JobLog]
           ([CaseNumber],[FacID],[StartTime],[Extract_Comp])
     VALUES
           (@CaseNumber,@fac_ids,GETDATE(),'N')
SELECT @RunID = @@IDENTITY


IF (OBJECT_ID('tempdb..#AS_BATCH_ASSESS', 'U') IS NOT NULL)
BEGIN
       DROP TABLE #AS_BATCH_ASSESS
END

IF @INCOMPLETEEXTRACT = 'N'
BEGIN
	CREATE TABLE #AS_BATCH_ASSESS (ASSESS_ID INT, FAC_ID INT, STD_ASSESS_ID INT, BATCH_ID INT)

	INSERT INTO #AS_BATCH_ASSESS
	SELECT ASSESS_ID, F.FAC_ID, ASSESSMENTS.STD_ASSESS_ID, DENSE_RANK() OVER (ORDER BY F.FAC_ID, ASSESSMENTS.STD_ASSESS_ID) AS BATCH_ID
	FROM AS_ASSESSMENT ASSESSMENTS WITH (NOLOCK)
	INNER JOIN FACILITY F WITH (NOLOCK)
	ON ASSESSMENTS.FAC_ID = F.FAC_ID
			AND F.HEALTH_TYPE = 'SNF'
			AND F.DELETED = 'N' AND (F.FAC_ID IN (SELECT FAC_IDS FROM @FAC_IDS_LIST) OR @FAC_IDS IS NULL)
			AND (F.IS_LIVE IS NULL OR F.IS_LIVE = 'Y')
			AND (F.INACTIVE IS NULL OR F.INACTIVE = 'N' OR (F.INACTIVE = 'Y' AND F.INACTIVE_DATE >= @ASSESS_DATE_FROM  ))
			AND F.FAC_ID IN (SELECT FAC_ID FROM CONFIGURATION_PARAMETER WITH (NOLOCK) WHERE NAME = 'MDS3_SECOND_STATE_FACID' AND LEN(VALUE) > 0)
			AND (ASSESSMENTS.STD_ASSESS_ID IN (11)) 
			AND (ASSESSMENTS.STATUS IN (SELECT MDSSTATUS FROM @MDSSTATUS_LIST) OR @MDSSTATUS IS NULL)
			AND ASSESSMENTS.DELETED ='N'
			AND (ASSESSMENTS.ASSESS_DATE BETWEEN @ASSESS_DATE_FROM  AND @ASSESS_DATE_TO )
		
			

	--SELECT DISTINCT BATCH_ID, FAC_ID, STD_ASSESS_ID
	--FROM #AS_BATCH_ASSESS

	SET @ROWCOUNT = @@ROWCOUNT

	IF @ROWCOUNT > 0
	BEGIN
		EXEC [DBO].GET_NEXT_PRIMARY_KEY 'AS_BATCH_EXTRACT','BATCH_ID',@MAXBATCHID OUTPUT , @ROWCOUNT

		INSERT INTO AS_BATCH_EXTRACT(BATCH_ID, FAC_ID, STD_ASSESS_ID, REVISION_BY, REVISION_DATE)
		SELECT DISTINCT BATCH_ID+ @MAXBATCHID -1, FAC_ID, STD_ASSESS_ID, @CASENUMBER, GETDATE()
		FROM #AS_BATCH_ASSESS

		
		INSERT INTO AS_BATCH_ASSESS_EXTRACT(ASSESS_ID, BATCH_ID, FAC_ID)
		SELECT ASSESS_ID, BATCH_ID+ @MAXBATCHID -1, FAC_ID
		FROM #AS_BATCH_ASSESS

		--IF @USE_LAST_RUN_TIME = 'Y' INSERT INTO DBO.EXTRACT_MDS_RUNTIME SELECT GETDATE()
	END
END

--Testing
--SELECT * FROM AS_BATCH_EXTRACT
--SELECT * FROM AS_BATCH_ASSESS_EXTRACT


--Step2
--Get Batches
 if @DebugMe='Y' Print 'BEGIN STEP 2 Get Batches' + '   ' + convert(varchar(26),getdate(),109)

IF @INCOMPLETEEXTRACT = 'N'
BEGIN
	
	IF (OBJECT_ID('tempdb..#DYN_BATCH', 'U') IS NOT NULL)
	BEGIN
		   DROP TABLE #DYN_BATCH
	END
	CREATE TABLE #DYN_BATCH (ID INT NOT NULL IDENTITY(1, 1),BATCH_ID INT,FACILITY_CODE VARCHAR(30), FAC_ID INT, FILEDATE VARCHAR(50))

	INSERT INTO #DYN_BATCH
	SELECT ISNULL(B.BATCH_ID,0) AS BATCH_ID, F.FACILITY_CODE, F.FAC_ID, 
	CONVERT(VARCHAR(30),ISNULL(B.REVISION_DATE,GETDATE()),112) + '_' + REPLACE(CONVERT(VARCHAR(10),ISNULL(B.REVISION_DATE,GETDATE()),108),':','') AS FILEDATE
	FROM FACILITY F WITH (NOLOCK) LEFT JOIN AS_BATCH_EXTRACT B WITH (NOLOCK)
	ON F.FAC_ID = B.FAC_ID AND EXTRACT_COMPLETE = 'N' AND B.STD_ASSESS_ID = 11 AND B.REVISION_BY = @CASENUMBER
	WHERE F.HEALTH_TYPE = 'SNF' AND F.DELETED = 'N' 
	AND (F.IS_LIVE IS NULL OR F.IS_LIVE = 'Y')
	AND (F.INACTIVE IS NULL OR F.INACTIVE = 'N' OR (F.INACTIVE = 'Y' AND F.INACTIVE_DATE >= @ASSESS_DATE_FROM ))
	AND F.FAC_ID IN (SELECT FAC_ID FROM CONFIGURATION_PARAMETER WITH (NOLOCK) WHERE NAME = 'MDS3_SECOND_STATE_FACID' AND LEN(VALUE) > 0)
	AND (F.FAC_ID IN (SELECT FAC_IDS FROM @FAC_IDS_LIST) OR @FAC_IDS IS NULL)
END
ELSE
BEGIN
	SELECT ISNULL(B.BATCH_ID,0) AS BATCH_ID, F.FACILITY_CODE, F.FAC_ID, CONVERT(VARCHAR(30),ISNULL(B.REVISION_DATE,GETDATE()),112) + '_' + REPLACE(CONVERT(VARCHAR(10),ISNULL(B.REVISION_DATE,GETDATE()),108),':','') AS FILEDATE
	FROM FACILITY F WITH (NOLOCK)
	INNER JOIN AS_BATCH_EXTRACT B  WITH (NOLOCK)
	ON F.FAC_ID = B.FAC_ID AND EXTRACT_COMPLETE = 'N' AND B.STD_ASSESS_ID = 11 AND B.REVISION_BY = @PROCESS_NAME
END

--Testing
--SELECT * 
--FROM #DYN_BATCH

DECLARE @_DYN_BATCH_ID INT
DECLARE @DYN_BATCH_CURSOR INT
DECLARE @_DYN_BATCH_COUNT INT
DECLARE @BATCH_FACID VARCHAR(20)
DECLARE @BATCHFILEDATE VARCHAR(50)

SET @DYN_BATCH_CURSOR = 1

SELECT @_DYN_BATCH_COUNT = COUNT(*) FROM #DYN_BATCH


WHILE @DYN_BATCH_CURSOR <= @_DYN_BATCH_COUNT
BEGIN


		
			SELECT @_DYN_BATCH_ID = BATCH_ID, @BATCH_FACID = FAC_ID, @BATCHFILEDATE = FILEDATE FROM #DYN_BATCH WHERE ID = @DYN_BATCH_CURSOR

--IN THE LOOP
--GET COUNT -- Testing
			--SELECT COUNT(*) AS NUM 
			--FROM AS_BATCH_ASSESS_EXTRACT
			--WHERE BATCH_ID =  @_DYN_BATCH_ID

--GET ASSESSMENTS
			DECLARE @_DYN_COUNT INT
			DECLARE @CURSOREASSESSID INT
			DECLARE @_DYN_ASSESS_ID INT


			SET @CURSOREASSESSID = 1

			IF (OBJECT_ID('tempdb..#DYN_BATCH_ASSESS', 'U') IS NOT NULL)
				BEGIN
					   DROP TABLE #DYN_BATCH_ASSESS
				END

			CREATE TABLE #DYN_BATCH_ASSESS (ID INT NOT NULL IDENTITY(1, 1),ASSESS_ID INT)

			INSERT INTO #DYN_BATCH_ASSESS (ASSESS_ID)
			SELECT ASSESS_ID FROM AS_BATCH_ASSESS_EXTRACT WITH (NOLOCK)
			WHERE BATCH_ID =  @_DYN_BATCH_ID
			UNION 
			SELECT 0

			SELECT @_DYN_COUNT = COUNT(*) FROM #DYN_BATCH_ASSESS







--Step3
--GET XML
-- LOOP THROUGH ALL ASSESSMENTS AND JUST DO INSERT IN _TEMPXML UNTILL ALL ASSESSMENTS FINISH FOR THAT BATCH
 if @DebugMe='Y' Print 'BEGIN STEP 3 LOOP THROUGH ALL ASSESSMENTS AND JUST DO INSERT IN _TEMPXML UNTILL ALL ASSESSMENTS FINISH FOR THAT BATCH' + '   ' + convert(varchar(26),getdate(),109)
WHILE @CURSOREASSESSID <= @_DYN_COUNT
BEGIN
		

			SELECT @_DYN_ASSESS_ID = ASSESS_ID  FROM #DYN_BATCH_ASSESS WHERE ID = @CURSOREASSESSID
	

		IF @_DYN_ASSESS_ID > 0
		BEGIN
			INSERT INTO [operational].[OA26_MDSExtract_TmpXML](ASSESS_ID,MDS_XML)
			EXEC SPROC_MDS_LIST_GENERATEMDS3EXPORTXML @ASSESSID=@_DYN_ASSESS_ID, @BATCHID= @_DYN_BATCH_ID , @FACID= @BATCH_FACID , @PRODTESTINDICATOR = @PRODTESTINDICATOR, @STATUS_TEXT = ''
		END
		ELSE
		BEGIN	
			INSERT INTO [operational].[OA26_MDSExtract_TmpXML] (MDS_XML,FACID,FILEDATE)
			SELECT 
			(SELECT F.FAC_ID AS PCCFACID, F.FACILITY_CODE AS PCCFACCODE, A.VALUE AS FACSUBID, F.NAME AS FACNAME,
			F.PROV AS FACSTATE, @_DYN_COUNT AS RECORDCOUNT
			FROM FACILITY F WITH (NOLOCK)
			LEFT JOIN CONFIGURATION_PARAMETER A WITH (NOLOCK) ON F.FAC_ID = A.FAC_ID AND A.NAME = 'MDS3_SECOND_STATE_FACID' AND LEN(VALUE) > 0
			WHERE F.FAC_ID = @BATCH_FACID
			FOR XML PATH ('ASSESSMENT')),@BATCH_FACID,@BATCHFILEDATE
		END

	
		
		SET @CURSOREASSESSID = @CURSOREASSESSID + 1 
 
END

						UPDATE A
						SET [FACID] = C.FAC_ID,
							[FILEDATE] = C.FILEDATE
						FROM [operational].[OA26_MDSExtract_TmpXML] A INNER JOIN
							 AS_BATCH_ASSESS_EXTRACT B ON A.ASSESS_ID = B.ASSESS_ID INNER JOIN
							 #DYN_BATCH C ON B.BATCH_ID = C.BATCH_ID

						UPDATE AS_BATCH_EXTRACT
						SET EXTRACT_COMPLETE = 'Y', REVISION_DATE = GETDATE()
						FROM AS_BATCH_EXTRACT 
						WHERE EXTRACT_COMPLETE = 'N'
						AND BATCH_ID = @_DYN_BATCH_ID

	SET  @DYN_BATCH_CURSOR = @DYN_BATCH_CURSOR + 1
END

		UPDATE [operational].[OA26_MDSExtract_JobLog]
		SET EndTime = GETDATE(),
		    [Extract_Comp] = 'Y'
		WHERE CaseNumber = @CaseNumber
		AND [Extract_Comp] = 'N'
		AND RunID = @RunID

UPDATE [operational].[OA26_MDSExtract_TmpXML]
SET [MDS_String] = CONVERT(VARCHAR(max), [MDS_XML], 1)

SELECT * 
--INTO PCC_TEMP_STORAGE.[DBO].[MDSEXTRACTSP_TEMPXML_JIRA_OA26]
FROM  [operational].[OA26_MDSExtract_TmpXML] WITH (NOLOCK)
--where ASSESS_ID is null

END TRY

 
--error trapping
BEGIN CATCH
 
		UPDATE [operational].[OA26_MDSExtract_JobLog]
		SET EndTime = GETDATE(),
		    [Extract_Comp] = 'F'
		WHERE CaseNumber = @CaseNumber
		AND [Extract_Comp] = 'N'
		AND RunID = @RunID

		UPDATE AS_BATCH_EXTRACT
		SET EXTRACT_COMPLETE = 'Y', REVISION_DATE = GETDATE()
		WHERE EXTRACT_COMPLETE = 'N' and revision_by = @CaseNumber

	select @ERROR_MSG as sp_error_msg
		return -100

 
    
 
END CATCH
 
--PROGRAM SUCCESS RETURN
PGMSUCCESS:
BEGIN
    select 'SUCCESSFUL EXECUTION OF STORED PROCEDURE' as sp_msg
    RETURN
END

 
GO


GO

print 'K_Operational_Branch/5_StoredProcedures/US_Only/CORE_94220_sproc_MDSExtractSP_core.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/US_Only/CORE_94220_sproc_MDSExtractSP_core.sql',getdate(),'4.4.9_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/US_Only/sproc_CreateFacility.sql',getdate(),'4.4.9_06_CLIENT_K_Operational_Branch_US.sql')

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
--	Jira #:									CORE-92956
--	
--
--	Written By:							Jaspreet Singh Bhogal
--
--	Script Type:							DML
--	Target DB Type:					CLIENT
--	Target ENVIRONMENT:		BOTH
--	Re-Runable:						YES
-- OA Jira #:								OA-54
--	Purpose:								This stored procedure is used to create new facility in destination database.

e.g.

DECLARE	@return_value int

EXEC	@return_value = [operational].[sproc_CreateFacility]
		@orgid = 1504965856,
		@healthtype = N'SNF',
		@name = N'Test Facility10',
		@facilitycode = N'0120',
		@state = N'OH',
		@ARMonth = 6,
		@ARYear = 2021,
		@FiscalYearEND = 3,
		@Use1099 = NULL,
		@Creator = N'PS1001',
		@add1 = N'5570 Explorer',
		@add2 = N'Drive',
		@city = N'Mississauga',
		@pc = N'T1P K0L',
		@tel = N'111-111-1111',
		@netsuiteID = 123456789,
		@EmailRecipients = N'jaspreet.s@pointclickcare.com',
		@FacilityCreator = N'Jaspreet Singh Bhogal',
		@first_run = 'N',
		@TSServerName = N'[vmuspassvtsjob1.pccprod.local].[ds_tasks].[dbo].[TS_global_organization_master]',
		@SessionInstanceServerName = N'[pccsql-use2-prod-ssv-clg0001.b4ea653240a9.database.windows.net].[pcc_org_master].[dbo].[pcc_session_instances]',
		@DebugMe = N'Y'

SELECT	'Return Value' = @return_value

*/
IF EXISTS (
		SELECT 1
		FROM dbo.sysobjects
		WHERE id = object_id(N'[operational].[sproc_CreateFacility]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
BEGIN
	DROP PROCEDURE [operational].[sproc_CreateFacility]
END
GO

CREATE PROCEDURE [operational].[sproc_CreateFacility] @orgid INTEGER
	,@healthtype VARCHAR(15)
	,@name VARCHAR(100)
	,@facilitycode VARCHAR(30)
	,@state VARCHAR(2)
	,@ARMonth INTEGER
	,@ARYear INTEGER
	,@FiscalYearEND INTEGER
	,@Use1099 CHAR(1)
	,@Creator VARCHAR(15)
	,@add1 VARCHAR(35)
	,@add2 VARCHAR(35)
	,@city VARCHAR(15)
	,@pc VARCHAR(15)
	,@tel VARCHAR(35)
	,@netsuiteID INT -- added by RYAN - Case 694329 -- 11/24/2015
	,@EmailRecipients VARCHAR(MAX)
	,@FacilityCreator VARCHAR(50)
	,@first_run CHAR(1) = 'N'
	,@TSServerName VARCHAR(350)
	,@SessionInstanceServerName VARCHAR(350)
	,@DebugMe CHAR(1) = 'N'
AS
/*
DECLARE @orgid INTEGER
	,@healthtype VARCHAR(15)
	,@name VARCHAR(100)
	,@facilitycode VARCHAR(30)
	,@state VARCHAR(2)
	,@ARMonth INTEGER
	,@ARYear INTEGER
	,@FiscalYearEND INTEGER
	,@Use1099 CHAR(1)
	,@Creator VARCHAR(15)
	,@add1 VARCHAR(35)
	,@add2 VARCHAR(35)
	,@city VARCHAR(15)
	,@pc VARCHAR(15)
	,@tel VARCHAR(35)
	,@netsuiteID INT -- added by RYAN - Case 694329 -- 11/24/2015
	,@EmailRecipients VARCHAR(MAX)
	,@FacilityCreator VARCHAR(50)
	,@first_run CHAR(1) = 'N'
	,@TSServerName VARCHAR(350)
	,@SessionInstanceServerName VARCHAR(350)
	,@DebugMe CHAR(1) = 'N'

SELECT @orgid = 1504967964
	,@healthtype = N'SNF'
	,@name = N'Test Facility1'
	,@facilitycode = N'0120'
	,@state = N'OH'
	,@ARMonth = 6
	,@ARYear = 2021
	,@FiscalYearEND = 3
	,@Use1099 = NULL
	,@Creator = N'PS1001'
	,@add1 = N'5570 Explorer'
	,@add2 = N'Drive'
	,@city = N'Mississauga'
	,@pc = N'T1P K0L'
	,@tel = N'111-111-1111'
	,@netsuiteID = 123456789
	,@EmailRecipients = N'jaspreet.s@pointclickcare.com'
	,@FacilityCreator = N'Jaspreet Singh Bhogal'
	,@first_run = 'N'
	,@TSServerName = N'[vmuspassvtsjob1.pccprod.local].[ds_tasks].[dbo].[TS_global_organization_master]'
	,@SessionInstanceServerName = N'[pccsql-use2-prod-ssv-clg0001.b4ea653240a9.database.windows.net].[pcc_org_master].[dbo].[pcc_session_instances]'
	,@DebugMe = N'N'
	*/
BEGIN
	SET XACT_ABORT
		,NOCOUNT ON;

	DECLARE @NewDB CHAR(1)
		,@FacIdDest INTEGER
		,@regid INTEGER
		,@FacExist INT
		,@factype VARCHAR(4)
		,@MaxID INT
		,@country INT
		,@SourceFac INT
		,@GLAPYear INT
		,@GLAPYear1 INT
		,@GLAPYear2 INT
		,@GLAPYear3 INT
		,@GLAPYear4 INT
		,@rowcount INT
		,@MaxSetupID INT
		,@MaxSetupParamID INT
		--added for v2.6.0
		,@MaxcalendarID INT
		,@template_server VARCHAR(50)
		,@template_db VARCHAR(50)
		,@ARStartDate DATETIME
		,@timezone INTEGER
		,@orgcode VARCHAR(20)
		,@status_code INT
		,@status_text VARCHAR(3000) = 'Success'
		,@Environment VARCHAR(50)
		,@sqlstring NVARCHAR(max)
	----Dorado and Ability variables
	DECLARE --@OrgId INT
		@WesMessageDatabase VARCHAR(50)
		,@endpoint_url VARCHAR(128)
		,@importFTPLocation VARCHAR(255)
		,@email VARCHAR(400)
		,@ErrorNumber INT
		,@multiFacility BIT = 1 -- 0 Single Facility, 1 Multi Facility
		--,@facId INT
		,@sessionServerName VARCHAR(100)
		,@sessionDatabaseName VARCHAR(100)
		,@created_by VARCHAR(60)
		-- ,@created_date DATETIME
		,@parameter_value VARCHAR(256)
		,@message_profile_id INT
		,@step INT

	SET @NewDB = 'N'
	SET @FacIdDest = NULL

	IF (
			(@state IS NOT NULL)
			AND (@state <> '')
			)
	BEGIN
		IF NOT EXISTS (
				SELECT 1
				FROM [prov_state]
				WHERE prov_code = @state
				)
		BEGIN
			SELECT 'State code is not valid' AS sp_error_msg

			RETURN - 100;
		END
	END
	ELSE
	BEGIN
		SELECT 'State code should not be empty' AS sp_error_msg

		RETURN - 100;
	END

	IF (
			@state IS NOT NULL
			OR @state <> ''
			)
	BEGIN
		SET @sqlstring = 'SELECT @template_server = ServerName
			,@template_db = DatabaseName
		FROM ' + @TSServerName + '
		WHERE OrgCode = ''tmplt' + @state + ''''

		EXEC Sp_executesql @sqlstring
			,N'@template_server VARCHAR(128) OUTPUT, @template_db VARCHAR(128) OUTPUT'
			,@template_server = @template_server OUTPUT
			,@template_db = @template_db OUTPUT
			----SELECT @template_server
			----	,@template_db
	END

	IF ISNULL(@ARMonth, 0) = 0
	BEGIN
		SET @ARMonth = MONTH(GETDATE())
	END

	IF NOT (
			(
				@ARMonth >= 1
				AND @ARMonth <= 12
				)
			)
	BEGIN
		SELECT 'AR month should be between 1 - 12' AS sp_error_msg

		RETURN - 100;
	END

	IF IsNumeric(@ARYear) = 0
	BEGIN
		SET @ARYear = YEAR(GETDATE())
	END
	ELSE
	BEGIN
		IF @ARYear < 1900
		BEGIN
			SELECT 'ARYear Should be greater than 1900' AS sp_error_msg

			RETURN - 100;
		END
	END

	SET @ARStartDate = CONVERT(VARCHAR, @ARYear) + REPLICATE('0', 2 - LEN(CONVERT(VARCHAR, @ARMonth))) + CONVERT(VARCHAR, @ARMonth) + '01'

	IF ISNULL(@GLAPYear, 0) = 0
	BEGIN
		SET @GLAPYear = @ARYear - 1
		SET @GLAPYear1 = @GLAPYear
		SET @GLAPYear2 = @GLAPYear + 1
		SET @GLAPYear3 = @GLAPYear + 2
		SET @GLAPYear4 = @GLAPYear + 3
	END

	IF (
			(@FiscalYearEND = '')
			OR (isnumeric(@FiscalYearEND) = 0)
			)
	BEGIN
		SET @FiscalYearEND = 12
	END

	IF NOT (
			(
				@FiscalYearEND >= 1
				AND @FiscalYearEND <= 12
				)
			)
	BEGIN
		SELECT 'Fiscal year should be between 1 - 12' AS sp_error_msg

		RETURN - 100;
	END

	IF (@Use1099 IS NULL)
	BEGIN
		SET @Use1099 = 'Y'
	END

	IF (
			@Creator IS NULL
			OR @Creator = ''
			)
	BEGIN
		SELECT 'Please provide value of facility creator.' AS sp_error_msg

		RETURN - 100;
	END

	IF @facilitycode IS NULL
		SET @facilitycode = ''
	SET @factype = 'USAR'
	SET @SourceFac = (
			SELECT min(fac_id)
			FROM dbo.facility WITH (NOLOCK)
			WHERE deleted = 'N'
				AND fac_id <> 9001
			)

	IF (
			(@netsuiteID IS NULL)
			AND (@netsuiteID = '')
			)
	BEGIN
		SELECT 'NetSuite Id should have value.' AS sp_error_msg

		RETURN - 100;
	END

	IF @add1 IS NULL
		SET @add1 = ''

	IF @add2 IS NULL
		SET @add2 = ''

	IF @city IS NULL
		SET @city = ''

	IF @pc IS NULL
		SET @pc = ''

	IF (
			@add1 IS NOT NULL
			OR @add1 <> ''
			)
	BEGIN
		IF (len(@add1) > 35)
			-- facility
		BEGIN
			SELECT 'Address1 length should be upto 35 characters only.' AS sp_error_msg

			RETURN - 100;
		END
	END

	IF (
			@add2 IS NOT NULL
			OR @add2 <> ''
			)
	BEGIN
		IF (len(@add2) > 35)
		BEGIN
			SELECT 'Address2 length should be upto 35 characters only.' AS sp_error_msg

			RETURN - 100;
		END
	END

	IF (
			@city IS NOT NULL
			OR @city <> ''
			)
	BEGIN
		IF (len(@city) > 35)
		BEGIN
			SELECT 'City length should be upto 50 characters only.' AS sp_error_msg

			RETURN - 100;
		END
	END

	IF (
			@pc IS NOT NULL
			OR @pc <> ''
			)
	BEGIN
		IF (len(@pc) > 15)
		BEGIN
			SELECT 'Postal code length should be upto 15 characters only.' AS sp_error_msg

			RETURN - 100;
		END
	END

	IF (
			@tel IS NOT NULL
			OR @tel <> ''
			)
	BEGIN
		IF (len(@tel) > 12)
		BEGIN
			SELECT 'Telephone should be in correct format.' AS sp_error_msg

			RETURN - 100;
		END
	END

	-- Script to get timezone base on state code
	IF (
			@state IS NOT NULL
			OR @state <> ''
			)
	BEGIN
		SET @timezone = CASE 
				WHEN @state = 'HI'
					THEN - 6
				WHEN @state = 'WA'
					OR @state = 'OR'
					OR @state = 'NV'
					OR @state = 'CA'
					OR @state = 'AK'
					THEN - 3
				WHEN @state = 'MT'
					OR @state = 'ID'
					OR @state = 'WY'
					OR @state = 'UT'
					OR @state = 'CO'
					OR @state = 'NM'
					OR @state = 'AZ'
					THEN '-2'
				WHEN @state = 'ND'
					OR @state = 'SD'
					OR @state = 'NE'
					OR @state = 'KS'
					OR @state = 'OK'
					OR @state = 'TX'
					OR @state = 'MN'
					OR @state = 'IA'
					OR @state = 'MO'
					OR @state = 'AR'
					OR @state = 'LA'
					OR @state = 'WI'
					OR @state = 'IL'
					OR @state = 'TN'
					OR @state = 'MS'
					OR @state = 'AL'
					THEN '-1'
				WHEN @state = 'MI'
					OR @state = 'IN'
					OR @state = 'OH'
					OR @state = 'KY'
					OR @state = 'WV'
					OR @state = 'GA'
					OR @state = 'FL'
					OR @state = 'SC'
					OR @state = 'NC'
					OR @state = 'VA'
					OR @state = 'PA'
					OR @state = 'NY'
					OR @state = 'VT'
					OR @state = 'NH'
					OR @state = 'ME'
					OR @state = 'MA'
					OR @state = 'RI'
					OR @state = 'CT'
					OR @state = 'NJ'
					OR @state = 'DE'
					OR @state = 'MD'
					OR @state = 'DC'
					THEN '0'
				ELSE ''
				END
	END

	SET @Country = 100
	SET @FacExist = 0

	IF RTRIM(@healthtype) = 'GLHO'
		SET @FacIdDest = 9999
	ELSE
	BEGIN
		IF (
				SELECT COUNT(1)
				FROM [dbo].facility
				WHERE fac_id != 9001
					AND deleted = 'N'
				) = 1 -- modified by Ryan due to Case 1617989 - 02/14/2020
			--IF (SELECT COUNT(1) FROM [dbo].facility where fac_id != 9001) = 1  -- old line
		BEGIN
			IF EXISTS (
					SELECT 1
					FROM [dbo].facility
					WHERE (created_by LIKE '%wescom%')
						AND fac_id != 9001
						AND deleted = 'N'
					) -- modified by Ryan due to Case 1617989 - 02/14/2020
				AND (
					-- Added by Jaspreet due to removal of disable login
					(
						SELECT DISTINCT fac.location_status_id
						FROM dbo.facility fac WITH (NOLOCK)
						WHERE fac_id != 9001
							AND deleted = 'N'
						) = (
						SELECT location_status_id
						FROM dbo.location_status WITH (NOLOCK)
						WHERE code = 'TEMPLATE'
						)
					)
			BEGIN
				SET @newDb = 'Y'
			END
		END

		IF (
				@newDb = 'Y'
				AND @healthtype <> 'SNF'
				AND @first_run = 'Y'
				)
		BEGIN
			SELECT 'Please update input file to have SNF as the first record.' AS sp_error_msg

			RETURN - 100;
		END

		IF @newDb = 'Y'
			SELECT @FacIdDest = MIN(fac_id)
			FROM [dbo].facility
	END

	/*V1.2*/
	--PRINT 'STEP #2'
	IF @FacIdDest IS NULL
	BEGIN
		PRINT ' **** New Facility '

		SELECT @FacIdDest = max(fac_id)
		FROM [dbo].facility
		WHERE fac_id < 9000

		SET @FacIdDest = ISNULL(@FacIdDest, 0) + 1
	END

	SELECT @regid = MIN(regional_id)
	FROM [dbo].regions
	WHERE short_desc = @healthtype

	SET @sqlstring = ''
	SET @sqlstring = 'SELECT @OrgCode = OrgCode
		,@Environment = Environment
		FROM ' + @TSServerName + '
		WHERE OrgId = ''' + CAST(@OrgId AS VARCHAR) + ''''

	EXEC Sp_executesql @sqlstring
		,N'@OrgCode varchar(20) OUTPUT, @Environment varchar(50) OUTPUT'
		,@OrgCode = @OrgCode OUTPUT
		,@Environment = @Environment OUTPUT

	----SELECT Environment = @Environment
	----	,OrgCode = @OrgCode
	/*Validations*/
	IF EXISTS (
			SELECT 1
			FROM [dbo].facility
			WHERE RTRIM(name) = RTRIM(@name)
				AND RTRIM(address1) = RTRIM(@add1)
				AND RTRIM(health_type) = RTRIM(@healthtype)
				AND RTRIM(created_by) = RTRIM(@Creator)
				AND deleted = 'N'
			)
		OR EXISTS (
			SELECT 1
			FROM facility
			WHERE fac_id <> 1
				AND fac_id = @FacIdDest
			)
	BEGIN
		SELECT '** ERROR: Facility "' + @name + '" already exists (orgid:' + CONVERT(VARCHAR, @orgid) + ')' AS sp_error_msg

		RETURN - 100;---- Last -100
	END

	------ELSE
	BEGIN TRY
		BEGIN TRANSACTION

		BEGIN
			IF (
					(@FacIdDest = 2)
					OR (
						(
							SELECT count(1)
							FROM [dbo].facility
							WHERE fac_id != @FacIdDest
								AND deleted = 'N'
								AND fac_id < 9000
							) = 1
						)
					)
			BEGIN
				--only for 2nd facility-do not want to change existing scoping in an existing multi DB
				UPDATE module
				SET deleted = 'N'
				WHERE module_id = 5
					AND deleted = 'Y'

				UPDATE ar_common_code
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE ar_insurance_addresses
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE ar_item_category
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1 --corporate scoping does not work unless regid is null

				UPDATE ar_lib_accounts
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE ar_lib_care_level_template
				SET fac_id = - 1
					,reg_id = NULL
				WHERE reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE ar_lib_charge_codes
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE ar_lib_fee_schedule
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE ar_lib_insurance_companies
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE ar_lib_payers
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE ar_lib_rate_schedule
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE ar_lib_rate_type
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE ar_lib_schedule_template
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE ar_lib_submitter
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE as_assessment
				SET fac_id = - 1
					,reg_id = NULL
				WHERE client_id = - 9999
					AND fac_id <> - 1
					AND deleted = 'N'
					AND reg_id IS NULL

				UPDATE as_assessment_section
				SET fac_id = - 1
				WHERE assess_id IN (
						SELECT assess_id
						FROM as_assessment
						WHERE client_id = - 9999
							AND fac_id <> - 1
							AND deleted = 'N'
							AND reg_id IS NULL
						)

				UPDATE as_std_assessment
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				--update 	as_std_pick_list				set fac_id = -1 where fac_id <> -1
				UPDATE as_std_trigger
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cp_consistency_rule
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cp_fst_type
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE as_std_assess_schedule
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1 -- added by Ryan - case 383795 - discussed with Rina Sept. 18, 2013

				UPDATE cp_interv_groups
				SET fac_id = - 1

				UPDATE cp_kardex_categories
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cp_lbr_category
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cp_lbr_library
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cp_std_etiologies
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cp_std_frequency
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cp_std_goal
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cp_std_intervention
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cp_std_library
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cp_std_need
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cp_std_need_cat
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cp_std_question
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cp_std_schedule
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cp_std_shift
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cp_std_task_library
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cr_std_alert
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cr_std_immunization
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE crm_codes
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE diagnosis_codes
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE gl_account_groups
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND fac_id <> - 1

				UPDATE common_code
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE gl_common_code
				SET fac_id = - 1
				WHERE deleted = 'N'
					AND fac_id <> - 1

				UPDATE gl_report_accounts
				SET fac_id = - 1
				WHERE fac_id <> - 1

				UPDATE gl_reports
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE id_type
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE inc_std_pick_list_item
				SET fac_id = - 1
					,reg_id = NULL
				WHERE reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE pho_administration_record
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE pho_body_location
				SET fac_id = - 1
				WHERE deleted = 'N'
					AND fac_id <> - 1

				UPDATE pho_order_type
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE pho_std_phys_order
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				---------- updated by RYAN, as requested by Kelly Cherchio -- 02/05/2021
				UPDATE emc_ext_facilities
				SET fac_id = - 1
					,revision_by = @Creator
					,revision_date = getdate()
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				------------ updated by RYAN, as requested by Kelly Cherchio -- 03/01/2021
				IF EXISTS (
						SELECT 1
						FROM facility_audit
						WHERE fac_id = 1
							AND name = 'ALF Template Database'
						)
					AND @healthtype = 'ALF'
				BEGIN
					UPDATE evt_std_event_type
					SET fac_id = - 1
						,revision_by = @Creator
						,revision_date = getdate()
					WHERE deleted = 0
						AND retired = 0
						AND reg_id IS NULL
						AND state_code IS NULL
						AND fac_id <> - 1
				END

				---------- 
				UPDATE pho_std_time
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE pho_std_time_details
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND fac_id <> - 1

				UPDATE pn_template
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE pn_type
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE prot_std_protocol_config
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND fac_id <> - 1

				UPDATE prov_state
				SET fac_id = - 1
				WHERE deleted = 'N'
					AND fac_id <> - 1

				UPDATE qa_category
				SET fac_id = - 1
					,reg_id = NULL
				WHERE reg_id IS NULL
					AND fac_id <> - 1

				UPDATE qa_indicator
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND fac_id <> - 1

				UPDATE user_field_types
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE wv_std_vitals
				SET fac_id = - 1
				WHERE fac_id <> - 1

				UPDATE upload_categories
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1 --corporate scoping does not work unless regid is null

				UPDATE census_codes
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1 --corporate scoping does not work unless regid is null

				UPDATE ar_rate_type_category
				SET fac_id = - 1
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1 --corporate scoping does not work unless regid is null

				UPDATE ta_item_type
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE sec_role
				SET fac_id = - 1
					,reg_id = NULL
				WHERE reg_id IS NULL
					AND fac_id <> - 1

				UPDATE ap_lib_vendors
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE ap_vendor_groups
				SET fac_id = - 1
				WHERE deleted = 'N'
					AND fac_id <> - 1

				UPDATE gl_lib_accounts
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				--------------------------------------------------
				-- added by RYAN - 12/03/2020
				-- email from Product -- IPC & Facility Acquisition Process -- Tuesday, November 24, 2020 10:06 AM
				-- there are two parts to this update - this is for the EMC insert - the second part is below only for the new fac
				INSERT INTO branded_library_feature_configuration (
					fac_id
					,brand_id
					,name
					,value
					,enabled_by
					,enabled_date
					,disabled_by
					,disabled_date
					,created_by
					,created_date
					,revision_by
					,revision_date
					,sequence
					)
				SELECT - 1
					,lib.brand_id
					,'enable_cp_partner_feature_emc'
					,f.value
					,@Creator
					,GETDATE()
					,NULL
					,NULL
					,@Creator
					,GETDATE()
					,@Creator
					,GETDATE()
					,con.sequence
				FROM branded_library_configuration lib WITH (NOLOCK)
				JOIN branded_library_tier_configuration con WITH (NOLOCK) ON lib.brand_id = con.brand_id
				JOIN branded_library_feature_configuration f WITH (NOLOCK) ON con.brand_id = f.brand_id
				WHERE NOT EXISTS (
						SELECT name
						FROM branded_library_feature_configuration WITH (NOLOCK)
						WHERE name = 'enable_cp_partner_feature_emc'
						)
					AND lib.brand_name = 'PCC Infection Control solution'
					AND lib.deleted = 'N'
					AND f.name = 'enable_cp_partner_feature'
					AND f.fac_id = @SourceFac

				-------------------------------------------------- 
				IF (
						SELECT count(*)
						FROM configuration_parameter
						WHERE NAME IN (
								'enable_cs_default_quick_link_icon'
								,'enable_cs_quick_link'
								,'enable_cs_quick_link_icon_desc'
								,'enable_cs_quick_link_url'
								)
							AND fac_id = - 1
						) = 0
				BEGIN
					UPDATE configuration_parameter
					SET fac_id = - 1
					WHERE NAME IN (
							'enable_cs_default_quick_link_icon'
							,'enable_cs_quick_link'
							,'enable_cs_quick_link_icon_desc'
							,'enable_cs_quick_link_url'
							)
						AND fac_id <> - 1
				END
						--print 'Second facility cororate scoping complete'
			END

			SELECT @facexist = fac_id
			FROM [dbo].facility
			WHERE fac_id = @FacIdDest

			IF @Facexist = 0
			BEGIN
				--changed on nov/18/2010 add field use_protocol_flag = 'Y'
				INSERT INTO [dbo].facility (
					fac_id
					,deleted
					,created_by
					,created_date
					,org_id
					,[name]
					,facility_code
					,Prov
					,country_id
					,time_zone
					,timeout_minutes
					,facility_type
					,health_type
					,adjust_for_dst
					,regional_id
					,address1
					,address2
					,city
					,pc
					,use_protocol_flag
					)
				VALUES (
					@FacIdDest
					,'N'
					,@Creator
					,getDate()
					,@orgid
					,@name
					,@facilitycode
					,@state
					,100
					,@timezone
					,60
					,@factype
					,@healthtype
					,'Y'
					,@regid
					,''
					,''
					,''
					,''
					,'Y'
					)

				INSERT INTO department_position
				SELECT position_id
					,department_id
					,@Creator
					,getdate()
					,@Creator
					,getdate()
					,@FacIdDest
				FROM department_position
				WHERE fac_id = @SourceFac

				IF (object_id('tempdb..#facility_cc_VALUES', 'U') IS NOT NULL)
				BEGIN
					DROP TABLE #facility_cc_VALUES
				END

				SELECT @MaxID = MAX(facility_cc_value_id) + 1
				FROM [dbo].facility_cc_VALUES

				SET @Maxid = ISNULL(@Maxid, 1)

				SELECT identity(INT, 1, 1) facility_cc_value_id
					,@FacIdDest fac_id
					,facility_cc_id facility_cc_id
					,NULL facility_cc_SELECT_item_id
					,NULL cc_value
					,@Creator created_by
					,getdate() created_date
					,@creator revision_by
					,getdate() revision_date
					,deleted
					,deleted_by
					,deleted_date
				INTO #facility_cc_VALUES
				FROM facility_cc_VALUES
				WHERE fac_id = @sourcefac

				INSERT INTO [dbo].facility_cc_VALUES (
					facility_cc_value_id
					,fac_id
					,facility_cc_id
					,facility_cc_SELECT_item_id
					,cc_value
					,created_by
					,created_date
					,revision_by
					,revision_date
					,deleted
					,deleted_by
					,deleted_date
					)
				SELECT @Maxid + facility_cc_value_id
					,fac_id
					,facility_cc_id
					,facility_cc_SELECT_item_id
					,cc_value
					,created_by
					,created_date
					,revision_by
					,revision_date
					,deleted
					,deleted_by
					,deleted_date
				FROM #facility_cc_VALUES

				DROP TABLE #facility_cc_VALUES

				INSERT INTO [dbo].general_config (
					fac_id
					,deleted
					,created_by
					,created_date
					,late_entry_period
					,blank_pn_on24hr
					,blank_pn_onshIFt
					,country_id
					)
				VALUES (
					@FacIdDest
					,'N'
					,@Creator
					,getDate()
					,24
					,'Y'
					,'Y'
					,100
					)

				INSERT INTO [dbo].as_hcfa672 (
					report_id
					,report_date
					,fac_id
					,F99
					,F98
					,F97
					,F96
					,F95
					,F94
					,F93
					,F92
					,F91
					,F90
					,F89
					,F88
					,F87
					,F86
					,F85
					,F84
					,F83
					,F82
					,F81
					,F80
					,F79
					,F78
					,F77
					,F76
					,F75
					,F148
					,F147
					,F146
					,F145
					,F144
					,F143
					,F142
					,F141
					,F140
					,F139
					,F138
					,F137
					,F136
					,F135
					,F134
					,F133
					,F132
					,F131
					,F130
					,F129
					,F128
					,F127
					,F126
					,F125
					,F124
					,F123
					,F122
					,F121
					,F120
					,F119
					,F118
					,F117
					,F116
					,F115
					,F114
					,F113
					,F112
					,F111
					,F110
					,F109
					,F108
					,F107
					,F106
					,F105
					,F104
					,F103
					,F102
					,F101
					,F100
					)
				SELECT @FacIdDest
					,getDate()
					,@FacIdDest
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL

				INSERT INTO [dbo].as_configuration (
					fac_id
					,medicare_prov_no
					,medicaid_prov_no
					,state_facility_id
					,contact_name
					,contact_phone
					,contact_phone_ext
					,agent_tax_id
					,agent_name
					,agent_address1
					,agent_address2
					,agent_city
					,agent_prov_state
					,agent_postal_zip
					,agent_contact_name
					,agent_phone
					,agent_phone_ext
					,cmi_SET_fed
					,cmi_SET_state
					,calc_type_fed
					,calc_type_state
					,default_mds_id
					,default_cmi_id
					,cmi_factor
					,dsh
					)
				SELECT @FacIdDest
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,agent_tax_id
					,agent_name
					,agent_address1
					,agent_address2
					,agent_city
					,agent_prov_state
					,agent_postal_zip
					,agent_contact_name
					,agent_phone
					,agent_phone_ext
					,cmi_SET_fed
					,cmi_SET_state
					,calc_type_fed
					,calc_type_state
					,default_mds_id
					,default_cmi_id
					,cmi_factor
					,dsh
				FROM [dbo].as_configuration
				WHERE fac_id = @SourceFac

				----changed on nov/18/2010
				INSERT INTO [dbo].ar_configuration (
					fac_id
					,deleted
					,created_by
					,created_date
					,posting_year
					,posting_month
					,contact_type_id
					,next_batch_number
					,next_cash_receipt_number
					,physician
					,census_revision_window
					,rate_revision_window
					,beds_as_number
					,hc_no_id
					,ssn_id
					,nsf_ref_account_id
					,medicaid_id
					,medicare_id
					,next_eft_number
					,ar_start_date
					,unit_of_measure
					,allow_outpatient
					,term_client
					,show_facility
					,show_client
					,diag_principal
					,diag_admission
					,bill_unk_care_level
					,census_time_format
					,census_past_months
					,auto_create_census
					,use_gl_ext
					,show_cash_receipt_type_summary
					,ub_facility_type
					,aging_bucket_count
					,medicare_no_pay_flag
					,anc_post_date_flag
					,adj_post_date_flag
					,cash_receipt_comment_flag
					,batch_report_comment_flag
					,allow_future_census_flag
					,days_before_closing_month
					,transaction_check_flag
					,recurring_charges_by_day_start_date ---- added by Jaspreet - 01/06/2022
					)
				VALUES (
					@FacIdDest
					,'N'
					,@Creator
					,GETDATE()
					,@ARYear
					,@ARMonth
					,'9040'
					,1
					,1
					,9022
					,999
					,999
					,CASE 
						WHEN @healthtype = 'ALF'
							THEN 'A'
						ELSE 'N'
						END -- added by RYAN - 04/13/2020 - as requested by PMO team - default is N unless it's an ALF building
					,6
					,5
					,- 1
					,4
					,3
					,1
					,@ARStartDate
					,'I'
					,'N'
					,'Resident'
					,'Y'
					,'Y'
					,1047
					,9399
					,'N'
					,'Military'
					,6
					,'N'
					,'N'
					,'Y'
					,'2'
					,'24'
					,'Y'
					,'N'
					,'N'
					,'Y'
					,'Y'
					,'Y'
					,0
					,'Y' ---- added by RYAN - 04/14/2020
					,@ARStartDate ---- added by Jaspreet - 01/06/2022
					)

				BEGIN
					IF NOT EXISTS (
							SELECT 1
							FROM ar_configuration
							WHERE fac_id = - 1
							)
						INSERT INTO [dbo].ar_configuration (
							fac_id
							,deleted
							,created_by
							,created_date
							,revision_by
							,revision_date
							,posting_year
							,posting_month
							)
						VALUES (
							- 1
							,'N'
							,@Creator
							,getdate()
							,@Creator
							,getdate()
							,- 1
							,- 1
							)
				END

				IF NOT EXISTS (
						SELECT 1
						FROM edi_format
						WHERE fac_id = @FacIdDest
							AND specification_type_id = 15
							AND specification_id = 36
							AND deleted = 'N'
						)
				BEGIN
					SET @MaxSetupID = NULL

					DELETE
					FROM pcc_global_primary_key
					WHERE table_name = 'edi_format'
						AND key_column_name = 'format_id';

					SELECT @MaxSetupID = coalesce(max(format_id), 0)
					FROM dbo.edi_format WITH (NOLOCK)

					SET @MaxSetupID = @MaxSetupID + 1

					----EXEC [dbo].get_next_primary_key 'edi_format'
					----	,'format_id'
					----	,@MaxSetupID OUTPUT
					----	,1
					--add on Jun 27th by case 199439 
					INSERT edi_format (
						format_id
						,created_by
						,created_date
						,revision_by
						,revision_date
						,deleted
						,deleted_by
						,deleted_date
						,fac_id
						,specification_type_id
						,specification_id
						,description
						,option1
						,option2
						,option3
						,sequence_no
						)
					SELECT @MaxSetupID
						,@Creator
						,getdate()
						,NULL
						,NULL
						,'N'
						,NULL
						,NULL
						,@FacIdDest
						,15
						,36
						,'Adjustment Batch Import'
						,NULL
						,NULL
						,NULL
						,1
				END

				-------------------------------------
				--add on March 24th, 2016 by case 368411 
				-- to insert for facility
				IF NOT EXISTS (
						SELECT 1
						FROM edi_format
						WHERE fac_id = @FacIdDest
							AND specification_type_id = 11
							AND specification_id = 32
							AND deleted = 'N'
						)
				BEGIN
					SET @MaxSetupID = NULL

					DELETE
					FROM pcc_global_primary_key
					WHERE table_name = 'edi_format'
						AND key_column_name = 'format_id';

					SELECT @MaxSetupID = coalesce(max(format_id), 0)
					FROM dbo.edi_format WITH (NOLOCK)

					SET @MaxSetupID = @MaxSetupID + 1

					----EXEC [dbo].get_next_primary_key 'edi_format'
					----	,'format_id'
					----	,@MaxSetupID OUTPUT
					----	,1
					--add on Jun 27th by case 199439 
					INSERT edi_format (
						format_id
						,created_by
						,created_date
						,revision_by
						,revision_date
						,deleted
						,deleted_by
						,deleted_date
						,fac_id
						,specification_type_id
						,specification_id
						,description
						,option1
						,option2
						,option3
						,sequence_no
						)
					SELECT @MaxSetupID
						,@Creator
						,getdate()
						,NULL
						,NULL
						,'N'
						,NULL
						,NULL
						,@FacIdDest
						,11
						,32
						,'Export Collections Accounts'
						,NULL
						,NULL
						,NULL
						,1
				END

				------------
				--add on March 24th, 2016 by case 368411 
				-- to insert for corporate
				IF NOT EXISTS (
						SELECT 1
						FROM edi_format
						WHERE fac_id = - 1
							AND specification_type_id = 11
							AND specification_id = 32
							AND deleted = 'N'
						)
				BEGIN
					SET @MaxSetupID = NULL

					DELETE
					FROM pcc_global_primary_key
					WHERE table_name = 'edi_format'
						AND key_column_name = 'format_id';

					SELECT @MaxSetupID = coalesce(max(format_id), 0)
					FROM dbo.edi_format WITH (NOLOCK)

					SET @MaxSetupID = @MaxSetupID + 1

					----EXEC [dbo].get_next_primary_key 'edi_format'
					----	,'format_id'
					----	,@MaxSetupID OUTPUT
					----	,1
					--add on Jun 27th by case 199439 
					INSERT edi_format (
						format_id
						,created_by
						,created_date
						,revision_by
						,revision_date
						,deleted
						,deleted_by
						,deleted_date
						,fac_id
						,specification_type_id
						,specification_id
						,description
						,option1
						,option2
						,option3
						,sequence_no
						)
					SELECT @MaxSetupID
						,@Creator
						,getdate()
						,NULL
						,NULL
						,'N'
						,NULL
						,NULL
						,- 1
						,11
						,32
						,'Export Collections Accounts'
						,NULL
						,NULL
						,NULL
						,1
				END

				---------------------------------------------
				INSERT INTO [dbo].ta_configuration (
					fac_id
					,deleted
					,created_by
					,created_date
					,posting_month
					,posting_year
					,cash_box_account_id
					,next_deposit_number
					,next_withdrawal_number
					,next_interest_number
					,next_ar_payment_number
					,default_account_id
					,default_std_account_id
					,CONTACT_TYPE_ID
					,allow_cash_split
					,interest_item_type
					)
				VALUES (
					@FacIdDest
					,'N'
					,@Creator
					,GETDATE()
					,CASE 
						WHEN @ARMonth = 1
							THEN 12
						ELSE @ARMonth - 1
						END
					,CASE 
						WHEN @ARMonth = 1
							THEN @ARYear - 1
						ELSE @ARYear
						END
					,NULL
					,1
					,1
					,1
					,1
					,NULL
					,NULL
					,NULL
					,'N' -- Modified BY: Jaspreet Singh, Date - 10/10/2019, Reason - Netsuite case# 1528398, Original Value was 'Y'
					,NULL
					)

				SELECT identity(INT, 1, 1) AS account_id
					,@FacIdDest fac_id
					,deleted
					,@Creator created_by
					,GETDATE() created_date
					,@Creator revision_by
					,GETDATE() revision_date
					,description
					,current_balance
					,last_statement_balance
					,last_statement_date
					,cash_box_reference
					,normal_balance
					,account_code
					,DELETED_BY
					,DELETED_DATE
				INTO #ta_control_account
				FROM ta_control_account
				WHERE fac_id = @SourceFac

				SET @Rowcount = @@rowcount

				--select *
				--from ta_control_account
				IF @Rowcount > 0
				BEGIN
					SET @MaxSetupID = NULL

					DELETE
					FROM pcc_global_primary_key
					WHERE table_name = 'ta_control_account'
						AND key_column_name = 'account_id';

					SELECT @MaxSetupID = coalesce(max(account_id), 0)
					FROM dbo.ta_control_account WITH (NOLOCK)

					----EXEC [dbo].get_next_primary_key 'ta_control_account'
					----	,'account_id'
					----	,@MaxSetupID OUTPUT
					----	,@Rowcount
					IF EXISTS (
							SELECT *
							FROM INFORMATION_SCHEMA.columns
							WHERE table_name = 'ta_control_account'
								AND COLUMN_NAME = 'account_number'
							) --this column was added for 3.7.14 release
					BEGIN
						INSERT INTO dbo.ta_control_account (
							account_id
							,fac_id
							,deleted
							,created_by
							,created_date
							,revision_by
							,revision_date
							,description
							,current_balance
							,last_statement_balance
							,last_statement_date
							,cash_box_reference
							,normal_balance
							,account_code
							,deleted_by
							,deleted_date
							,account_number
							)
						SELECT account_id + @MaxSetupID
							,fac_id
							,deleted
							,created_by
							,created_date
							,revision_by
							,revision_date
							,description
							,current_balance
							,last_statement_balance
							,last_statement_date
							,cash_box_reference
							,normal_balance
							,account_code
							,DELETED_BY
							,DELETED_DATE
							,'Control_Account_' + CONVERT(VARCHAR, account_id + @MaxSetupID)
						FROM #ta_control_account
					END
					ELSE
					BEGIN
						INSERT INTO dbo.ta_control_account (
							account_id
							,fac_id
							,deleted
							,created_by
							,created_date
							,revision_by
							,revision_date
							,description
							,current_balance
							,last_statement_balance
							,last_statement_date
							,cash_box_reference
							,normal_balance
							,account_code
							,DELETED_BY
							,DELETED_DATE
							)
						SELECT account_id + @MaxSetupID
							,fac_id
							,deleted
							,created_by
							,created_date
							,revision_by
							,revision_date
							,description
							,current_balance
							,last_statement_balance
							,last_statement_date
							,cash_box_reference
							,normal_balance
							,account_code
							,DELETED_BY
							,DELETED_DATE
						FROM #ta_control_account
					END
				END

				DROP TABLE #ta_control_account

				SELECT identity(INT, 1, 1) AS income_source_id
					,@FacIdDest fac_id
					,deleted
					,@Creator created_by
					,GETDATE() created_date
					,@Creator revision_by
					,GETDATE() revision_date
					,description
					,DELETED_BY
					,DELETED_DATE
				INTO #ta_income_source
				FROM ta_income_source
				WHERE fac_id = @SourceFac

				SET @Rowcount = @@rowcount

				IF @Rowcount > 0
				BEGIN
					SET @MaxSetupID = NULL

					DELETE
					FROM pcc_global_primary_key
					WHERE table_name = 'ta_income_source'
						AND key_column_name = 'income_source_id';

					SELECT @MaxSetupID = coalesce(max(income_source_id), 0)
					FROM dbo.ta_income_source WITH (NOLOCK)

					----EXEC [dbo].get_next_primary_key 'ta_income_source'
					----	,'income_source_id'
					----	,@MaxSetupID OUTPUT
					----	,@Rowcount
					INSERT INTO dbo.ta_income_source (
						income_source_id
						,fac_id
						,deleted
						,created_by
						,created_date
						,revision_by
						,revision_date
						,description
						,DELETED_BY
						,DELETED_DATE
						)
					SELECT income_source_id + @MaxSetupID
						,fac_id
						,deleted
						,created_by
						,created_date
						,revision_by
						,revision_date
						,description
						,DELETED_BY
						,DELETED_DATE
					FROM #ta_income_source
				END

				DROP TABLE #ta_income_source

				--
				SELECT identity(INT, 1, 1) AS std_account_id
					,@FacIdDest fac_id
					,deleted
					,@Creator created_by
					,GETDATE() created_date
					,@Creator revision_by
					,GETDATE() revision_date
					,description
					,max_balance
					,min_balance
					,std_account_code
					,DELETED_BY
					,DELETED_DATE
				INTO #ta_std_account
				FROM ta_std_account
				WHERE fac_id = @SourceFac

				SET @Rowcount = @@rowcount

				IF @Rowcount > 0
				BEGIN
					SET @MaxSetupID = NULL

					DELETE
					FROM pcc_global_primary_key
					WHERE table_name = 'ta_std_account'
						AND key_column_name = 'std_account_id';

					SELECT @MaxSetupID = coalesce(max(std_account_id), 0)
					FROM dbo.ta_std_account WITH (NOLOCK)

					----EXEC [dbo].get_next_primary_key 'ta_std_account'
					----	,'std_account_id'
					----	,@MaxSetupID OUTPUT
					----	,@Rowcount
					IF EXISTS (
							SELECT *
							FROM INFORMATION_SCHEMA.columns
							WHERE table_name = 'ta_std_account'
								AND COLUMN_NAME = 'res_account_number'
							) --this column was added for 3.7.14 release
					BEGIN
						INSERT INTO dbo.ta_std_account (
							std_account_id
							,fac_id
							,deleted
							,created_by
							,created_date
							,revision_by
							,revision_date
							,description
							,max_balance
							,min_balance
							,std_account_code
							,DELETED_BY
							,DELETED_DATE
							,res_account_number
							)
						SELECT std_account_id + @MaxSetupID
							,fac_id
							,deleted
							,created_by
							,created_date
							,revision_by
							,revision_date
							,description
							,max_balance
							,min_balance
							,std_account_code
							,DELETED_BY
							,DELETED_DATE
							,'Resident_Account_' + CONVERT(VARCHAR, std_account_id + @MaxSetupID)
						FROM #ta_std_account
					END
					ELSE
					BEGIN
						INSERT INTO dbo.ta_std_account (
							std_account_id
							,fac_id
							,deleted
							,created_by
							,created_date
							,revision_by
							,revision_date
							,description
							,max_balance
							,min_balance
							,std_account_code
							,DELETED_BY
							,DELETED_DATE
							)
						SELECT std_account_id + @MaxSetupID
							,fac_id
							,deleted
							,created_by
							,created_date
							,revision_by
							,revision_date
							,description
							,max_balance
							,min_balance
							,std_account_code
							,DELETED_BY
							,DELETED_DATE
						FROM #ta_std_account
					END
				END

				DROP TABLE #ta_std_account

				--TA_configuration add on 2010-11-25 case:163591
				--==========================================================
				DECLARE @contact_type_id INT
					,@interest_type_id INT
					,@Acc_control_id INT
					,@Acc_resident_id INT
					,@Acc_cash_box_id INT

				SET @contact_type_id = (
						SELECT TOP 1 item_id
						FROM common_code
						WHERE short_description = 'ARG'
							AND item_code = 'respo'
							AND deleted = 'N'
							AND (
								fac_id = - 1
								OR fac_id = @FacIdDest
								)
						)
				SET @interest_type_id = (
						SELECT TOP 1 item_type_id
						FROM dbo.ta_item_type
						WHERE description = 'Interest'
							AND (
								fac_id = - 1
								OR fac_id = @FacIdDest
								)
						)
				SET @Acc_control_id = (
						SELECT TOP 1 account_id
						FROM dbo.ta_control_account
						WHERE description = 'Bank'
							AND (
								fac_id = - 1
								OR fac_id = @FacIdDest
								)
						)
				SET @Acc_resident_id = (
						SELECT TOP 1 std_account_id
						FROM dbo.ta_std_account
						WHERE description = 'Resident Trust'
							AND std_account_code = 'Res'
							AND (
								fac_id = - 1
								OR fac_id = @FacIdDest
								)
						)
				SET @Acc_cash_box_id = (
						SELECT TOP 1 account_id
						FROM dbo.ta_control_account
						WHERE description = 'Trust Petty Cash'
							AND (
								fac_id = - 1
								OR fac_id = @FacIdDest
								)
						)

				UPDATE ta_configuration
				SET cash_box_account_id = @Acc_cash_box_id
					,default_account_id = @Acc_control_id
					,default_std_account_id = @Acc_resident_id
					,CONTACT_TYPE_ID = @contact_type_id
					,interest_item_type = @interest_type_id
				WHERE fac_id = @FacIdDest

				--==========================================================
				--==========================================================
				--
				INSERT INTO [dbo].gl_configuration (
					fac_id
					,deleted
					,created_by
					,created_date
					,deleted_by
					,deleted_date
					,revision_by
					,revision_date
					,current_fiscal_year
					,posting_to_previous_years_flag
					,def_ret_earnings_act_id
					,auto_post_ap
					,auto_post_ap_noncash
					,auto_post_ar
					,auto_post_ar_noncash
					,post_to_control_flag
					,auto_post_ap_reversals
					,imported_fac_id
					,check_rec_YN
					,/*bank_rec_YN,*/ append_facility_code
					,corp_bank_rec_YN
					)
				SELECT @FacIdDest
					,'N'
					,@Creator
					,GETDATE()
					,NULL
					,NULL
					,NULL
					,NULL
					,@GLAPYear
					,posting_to_previous_years_flag
					,def_ret_earnings_act_id
					,auto_post_ap
					,auto_post_ap_noncash
					,auto_post_ar
					,auto_post_ar_noncash
					,post_to_control_flag
					,auto_post_ap_reversals
					,@FacIdDest
					,check_rec_YN
					,/*corp_bank_rec_YN,*/ append_facility_code
					,corp_bank_rec_YN
				FROM [dbo].gl_configuration
				WHERE fac_id = @SourceFac

				INSERT INTO [dbo].glap_config
				SELECT @FacIdDest
					,deleted
					,@Creator
					,getdate()
					,NULL
					,NULL
					,NULL
					,NULL
					,@orgid
					,@name
					,@FiscalYearEND
					,fiscal_periods
					,warning_date_range
					,currency
					,@Use1099
				FROM [dbo].glap_config
				WHERE fac_id = @SourceFac

				SELECT identity(INT, 1, 1) AS setup_id
					,@FacIdDest AS fac_id
					,reg_id
					,group_id
					,@Creator AS created_by
					,getdate() AS created_date
					,NULL AS revision_by
					,NULL AS revision_date
					,'N' AS deleted
					,NULL AS deleted_by
					,NULL AS deleted_date
					,setup_name
					,setup_note
					,default_flag
				INTO #TSetup
				FROM [dbo].rpt_config_setup
				WHERE fac_id = @SourceFac

				SET @Rowcount = @@rowcount

				IF @Rowcount > 0
				BEGIN
					SET @MaxSetupID = NULL

					DELETE
					FROM pcc_global_primary_key
					WHERE table_name = 'rpt_config_setup'
						AND key_column_name = 'setup_id';

					SELECT @MaxSetupID = coalesce(max(setup_id), 0)
					FROM dbo.rpt_config_setup WITH (NOLOCK)

					----EXEC [dbo].get_next_primary_key 'rpt_config_setup'
					----	,'setup_id'
					----	,@MaxSetupID OUTPUT
					----	,@rowcount
					INSERT INTO [dbo].rpt_config_setup (
						setup_id
						,fac_id
						,reg_id
						,group_id
						,created_by
						,created_date
						,revision_by
						,revision_date
						,deleted
						,deleted_by
						,deleted_date
						,setup_name
						,setup_note
						,default_flag
						)
					SELECT setup_id + @MaxSetupID
						,fac_id
						,reg_id
						,group_id
						,created_by
						,created_date
						,revision_by
						,revision_date
						,deleted
						,deleted_by
						,deleted_date
						,setup_name
						,setup_note
						,default_flag
					FROM #TSetup
				END

				SELECT identity(INT, 1, 1) AS setup_param_id
					,setup_id = (
						SELECT setup_id
						FROM rpt_config_setup
						WHERE fac_id = @FacIdDest
						)
					,group_param_id
					,param_label
					,param_value
					,param_order
				INTO #TSetupParam
				FROM rpt_config_setup_param
				WHERE setup_id IN (
						SELECT setup_id
						FROM #TSetup
						WHERE fac_id = @SourceFac
						)

				SET @Rowcount = @@rowcount

				IF @Rowcount > 0
				BEGIN
					SET @MaxSetupParamID = NULL

					DELETE
					FROM pcc_global_primary_key
					WHERE table_name = 'rpt_config_setup_param'
						AND key_column_name = 'setup_param_id';

					SELECT @MaxSetupParamID = coalesce(max(setup_param_id), 0)
					FROM dbo.rpt_config_setup_param WITH (NOLOCK)

					----EXEC get_next_primary_key 'rpt_config_setup_param'
					----	,'setup_param_id'
					----	,@MaxSetupParamID OUTPUT
					----	,@rowcount
					INSERT INTO rpt_config_setup_param (
						setup_param_id
						,setup_id
						,group_param_id
						,param_label
						,param_value
						,param_order
						)
					SELECT setup_param_id + @MaxSetupParamID
						,setup_id
						,group_param_id
						,param_label
						,param_value
						,param_order
					FROM #TSetupParam
				END

				DROP TABLE #TSetup

				DROP TABLE #TSetupParam

				--select * from adt_census_configuration
				INSERT INTO adt_census_configuration
				VALUES (
					@FacIdDest
					,'Y'
					,getdate()
					,@Creator
					,'N'
					,'N'
					,@Creator
					,getdate()
					,NULL
					,NULL
					,'N'
					,NULL
					,NULL
					)
			END

			--drop table #tsetup drop table #TSetupParam
			--==================================================================================================
			--Facilities 1 AND 2 UPDATE statements
			--================================================================================================
			IF @Facexist <> 0
			BEGIN
				--changed on nov/18/2010 add fiels use_protocol_flag = 'Y'
				UPDATE facility
				SET deleted = 'N'
					,created_by = @Creator
					,created_date = getdate()
					,revision_by = @Creator
					,revision_date = getdate()
					,org_id = @orgid
					,[name] = @name
					,facility_code = @facilitycode
					,prov = @state
					,health_type = @healthtype
					,facility_type = @factype
					,regional_id = @regid
					,use_protocol_flag = 'Y'
					,time_zone = @timezone --added time_zone on 2014-04-28
				WHERE fac_id = @FacIdDest

				UPDATE ar_configuration
				SET created_date = getDate()
					,revision_by = NULL
					,revision_date = NULL
					,posting_month = @ARMonth
					,posting_year = @ARYear
					,ar_start_date = @ARStartDate
					,recurring_charges_by_day_start_date = @ARStartDate ---- added by Jaspreet - 01/06/2022
					,unit_of_measure = 'I'
					,statement_message = NULL
				WHERE fac_id = @FacIdDest

				UPDATE ta_configuration
				SET created_date = getDate()
					,revision_by = NULL
					,revision_date = NULL
					,cash_box_account_id = NULL
					,default_account_id = NULL
					,default_std_account_id = NULL
					,CONTACT_TYPE_ID = NULL
					,interest_item_type = NULL
					,posting_month = CASE 
						WHEN @ARMonth = 1
							THEN 12
						ELSE @ARMonth - 1
						END
					,posting_year = CASE 
						WHEN @ARMonth = 1
							THEN @ARYear - 1
						ELSE @ARYear
						END
				WHERE fac_id = @FacIdDest

				UPDATE gl_configuration
				SET current_fiscal_year = @GLAPYear
				WHERE fac_id = @FacIdDest

				UPDATE glap_config
				SET org_id = @orgid
					,fiscal_year_end_month = @FiscalYearEnd
					,[name] = @name
					,use_1099 = @Use1099
				WHERE fac_id = @FacIdDest
			END

			--===================================================================================
			--End existing facility updates
			--===================================================================================
			DELETE
			FROM [dbo].glap_fiscal_calendar_periods
			WHERE fac_id = @FacIdDest

			DELETE
			FROM [dbo].glap_fiscal_calendar
			WHERE fac_id = @FacIdDest

			--==================================================================
			SET @FacExist = 0

			SELECT @facexist = fac_id
			FROM glap_fiscal_calendar
			WHERE fac_id = @FacIdDest

			IF @Facexist = 0
			BEGIN
				CREATE TABLE #T_glap_years (
					rowID INT identity(1, 1)
					,Fyear VARCHAR(6)
					,Ctype VARCHAR(2)
					)

				INSERT INTO #T_glap_years (
					Fyear
					,Ctype
					)
				VALUES (
					@GLAPYEAR1
					,'GL'
					)

				INSERT INTO #T_glap_years (
					Fyear
					,Ctype
					)
				VALUES (
					@GLAPYEAR2
					,'GL'
					)

				INSERT INTO #T_glap_years (
					Fyear
					,Ctype
					)
				VALUES (
					@GLAPYEAR3
					,'GL'
					)

				INSERT INTO #T_glap_years (
					Fyear
					,Ctype
					)
				VALUES (
					@GLAPYEAR4
					,'GL'
					)

				INSERT INTO #T_glap_years (
					Fyear
					,Ctype
					)
				VALUES (
					@GLAPYEAR1
					,'AP'
					)

				INSERT INTO #T_glap_years (
					Fyear
					,Ctype
					)
				VALUES (
					@GLAPYEAR2
					,'AP'
					)

				INSERT INTO #T_glap_years (
					Fyear
					,Ctype
					)
				VALUES (
					@GLAPYEAR3
					,'AP'
					)

				INSERT INTO #T_glap_years (
					Fyear
					,Ctype
					)
				VALUES (
					@GLAPYEAR4
					,'AP'
					)

				SELECT *
				INTO #tYear
				FROM #T_glap_years

				SET @Rowcount = @@rowcount

				IF @Rowcount > 0
				BEGIN
					SET @MaxcalendarID = NULL

					DELETE
					FROM pcc_global_primary_key
					WHERE table_name = 'glap_fiscal_calendar'
						AND key_column_name = 'fiscal_calendar_id';

					SELECT @MaxcalendarID = coalesce(max(fiscal_calendar_id), 0)
					FROM dbo.glap_fiscal_calendar WITH (NOLOCK)

					----EXEC get_next_primary_key 'glap_fiscal_calendar'
					----	,'fiscal_calendar_id'
					----	,@MaxcalendarID OUTPUT
					----	,@rowcount
					INSERT INTO glap_fiscal_calendar (
						fac_id
						,fiscal_year
						,deleted
						,created_by
						,created_date
						,adjustment_periods
						,closing_periods
						,active
						,fiscal_calendar_id
						,calendar_type
						)
					SELECT @FacIdDest
						,Fyear
						,'N'
						,@Creator
						,getDate()
						,'Open'
						,'Open'
						,'Y'
						,@MaxcalendarID + rowID
						,Ctype
					FROM #tYear

					DROP TABLE #tYear
				END

				DROP TABLE #T_glap_years
			END

			--==============================================================
			SET @FacExist = 0

			SELECT @facexist = fac_id
			FROM glap_fiscal_calendar_periods
			WHERE fac_id = @FacIdDest

			IF @Facexist = 0
			BEGIN
				DECLARE @ENDMonth INT
					,@StartYear INT
					,@NumberofYear INT
					,@FacID INT
				DECLARE @StartDate DATETIME
					,@ENDDate DATETIME
					,@StartMonth INT
					,@Period INT
					,@YearCounter INT
					,@CurrentYear INT
					,@CurrentMonth INT
					,@CreatedBy VARCHAR(25)

				SET @ENDMonth = @FiscalYearEND
				SET @StartYear = @GLAPYear1
				SET @NumberofYear = 3
				SET @Period = 1
				SET @YearCounter = 1
				SET @FacID = @FacIdDest
				SET @CreatedBy = @Creator
				SET @CurrentYear = @GLAPYear1 --drives fiscal year

				CREATE TABLE #FiscalPeriods (
					FiscalYear INT
					,Period INT
					,StartPeriod DATETIME
					,ENDPeriod DATETIME
					,FacID INT
					)

				IF @ENDMonth = 12
					SET @CurrentMonth = 1
				ELSE
					SET @CurrentMonth = @ENDMonth + 1

				IF @ENDMonth = 12
					SET @StartYear = @GLAPYear1
				ELSE
					SET @StartYear = @GLAPYear2

				WHILE @Period <= 12
					AND @YearCounter <= @NumberofYear
				BEGIN
					SET @StartDate = cast(@CurrentMonth AS VARCHAR) + '/01/' + cast(@CurrentYear AS VARCHAR)
					SET @ENDDate = dateadd(d, - 1, dateadd(m, 1, @Startdate))

					INSERT INTO #FiscalPeriods
					VALUES (
						@StartYear
						,@Period
						,@StartDate
						,@ENDDate
						,@FacID
						)

					SET @Period = @Period + 1
					SET @CurrentMonth = @CurrentMonth + 1

					IF @CurrentMonth = 13
					BEGIN
						SET @CurrentMonth = 1
						SET @CurrentYear = @CurrentYear + 1
					END

					IF @Period = 13
					BEGIN
						SET @YearCounter = @YearCounter + 1
						SET @Period = 1
						SET @StartYear = @StartYear + 1
					END
				END
			END

			BEGIN
				INSERT INTO glap_fiscal_calendar_periods (
					fac_id
					,fiscal_period
					,deleted
					,created_by
					,created_date
					,deleted_by
					,deleted_date
					,revision_by
					,revision_date
					,STATUS
					,start_period
					,end_period
					,fiscal_calendar_id
					)
				SELECT @facid
					,Period
					,'N'
					,@CreatedBy
					,getdate()
					,NULL
					,NULL
					,NULL
					,NULL
					,'Open'
					,Startperiod
					,EndPeriod
					,gl.fiscal_calendar_id
				FROM #FiscalPeriods
				JOIN glap_fiscal_calendar gl ON #FiscalPeriods.facid = gl.fac_id
				WHERE gl.fac_id = @FacID
					AND #FiscalPeriods.FiscalYear IN (
						SELECT fiscal_year
						FROM glap_fiscal_calendar
						WHERE fiscal_year = @GLAPYear1
							AND calendar_type = 'GL'
						)
					AND calendar_type = 'GL'
					AND #FiscalPeriods.FiscalYear = @GLAPYear1
					AND gl.fiscal_year = @GLAPYear1

				INSERT INTO glap_fiscal_calendar_periods (
					fac_id
					,fiscal_period
					,deleted
					,created_by
					,created_date
					,deleted_by
					,deleted_date
					,revision_by
					,revision_date
					,STATUS
					,start_period
					,end_period
					,fiscal_calendar_id
					)
				SELECT @facid
					,Period
					,'N'
					,@CreatedBy
					,getdate()
					,NULL
					,NULL
					,NULL
					,NULL
					,'Open'
					,Startperiod
					,EndPeriod
					,gl.fiscal_calendar_id
				FROM #FiscalPeriods
				JOIN glap_fiscal_calendar gl ON #FiscalPeriods.facid = gl.fac_id
				WHERE gl.fac_id = @FacID
					AND #FiscalPeriods.FiscalYear IN (
						SELECT fiscal_year
						FROM glap_fiscal_calendar
						WHERE fiscal_year = @GLAPYear2
							AND calendar_type = 'GL'
						)
					AND calendar_type = 'GL'
					AND #FiscalPeriods.FiscalYear = @GLAPYear2
					AND gl.fiscal_year = @GLAPYear2

				INSERT INTO glap_fiscal_calendar_periods (
					fac_id
					,fiscal_period
					,deleted
					,created_by
					,created_date
					,deleted_by
					,deleted_date
					,revision_by
					,revision_date
					,STATUS
					,start_period
					,end_period
					,fiscal_calendar_id
					)
				SELECT @facid
					,Period
					,'N'
					,@CreatedBy
					,getdate()
					,NULL
					,NULL
					,NULL
					,NULL
					,'Open'
					,Startperiod
					,EndPeriod
					,gl.fiscal_calendar_id
				FROM #FiscalPeriods
				JOIN glap_fiscal_calendar gl ON #FiscalPeriods.facid = gl.fac_id
				WHERE gl.fac_id = @FacID
					AND #FiscalPeriods.FiscalYear IN (
						SELECT fiscal_year
						FROM glap_fiscal_calendar
						WHERE fiscal_year = @GLAPYear3
							AND calendar_type = 'GL'
						)
					AND calendar_type = 'GL'
					AND #FiscalPeriods.FiscalYear = @GLAPYear3
					AND gl.fiscal_year = @GLAPYear3

				INSERT INTO glap_fiscal_calendar_periods (
					fac_id
					,fiscal_period
					,deleted
					,created_by
					,created_date
					,deleted_by
					,deleted_date
					,revision_by
					,revision_date
					,STATUS
					,start_period
					,end_period
					,fiscal_calendar_id
					)
				SELECT @facid
					,Period
					,'N'
					,@CreatedBy
					,getdate()
					,NULL
					,NULL
					,NULL
					,NULL
					,'Open'
					,Startperiod
					,EndPeriod
					,gl.fiscal_calendar_id
				FROM #FiscalPeriods
				JOIN glap_fiscal_calendar gl ON #FiscalPeriods.facid = gl.fac_id
				WHERE gl.fac_id = @FacID
					AND #FiscalPeriods.FiscalYear IN (
						SELECT fiscal_year
						FROM glap_fiscal_calendar
						WHERE fiscal_year = @GLAPYear4
							AND calendar_type = 'GL'
						)
					AND calendar_type = 'GL'
					AND #FiscalPeriods.FiscalYear = @GLAPYear4
					AND gl.fiscal_year = @GLAPYear4

				INSERT INTO glap_fiscal_calendar_periods (
					fac_id
					,fiscal_period
					,deleted
					,created_by
					,created_date
					,deleted_by
					,deleted_date
					,revision_by
					,revision_date
					,STATUS
					,start_period
					,end_period
					,fiscal_calendar_id
					)
				SELECT @facid
					,Period
					,'N'
					,@CreatedBy
					,getdate()
					,NULL
					,NULL
					,NULL
					,NULL
					,'Open'
					,Startperiod
					,EndPeriod
					,gl.fiscal_calendar_id
				FROM #FiscalPeriods
				JOIN glap_fiscal_calendar gl ON #FiscalPeriods.facid = gl.fac_id
				WHERE gl.fac_id = @FacID
					AND #FiscalPeriods.FiscalYear IN (
						SELECT fiscal_year
						FROM glap_fiscal_calendar
						WHERE fiscal_year = @GLAPYear1
							AND calendar_type = 'AP'
						)
					AND calendar_type = 'AP'
					AND #FiscalPeriods.FiscalYear = @GLAPYear1
					AND gl.fiscal_year = @GLAPYear1

				INSERT INTO glap_fiscal_calendar_periods (
					fac_id
					,fiscal_period
					,deleted
					,created_by
					,created_date
					,deleted_by
					,deleted_date
					,revision_by
					,revision_date
					,STATUS
					,start_period
					,end_period
					,fiscal_calendar_id
					)
				SELECT @facid
					,Period
					,'N'
					,@CreatedBy
					,getdate()
					,NULL
					,NULL
					,NULL
					,NULL
					,'Open'
					,Startperiod
					,EndPeriod
					,gl.fiscal_calendar_id
				FROM #FiscalPeriods
				JOIN glap_fiscal_calendar gl ON #FiscalPeriods.facid = gl.fac_id
				WHERE gl.fac_id = @FacID
					AND #FiscalPeriods.FiscalYear IN (
						SELECT fiscal_year
						FROM glap_fiscal_calendar
						WHERE fiscal_year = @GLAPYear2
							AND calendar_type = 'AP'
						)
					AND calendar_type = 'AP'
					AND #FiscalPeriods.FiscalYear = @GLAPYear2
					AND gl.fiscal_year = @GLAPYear2

				INSERT INTO glap_fiscal_calendar_periods (
					fac_id
					,fiscal_period
					,deleted
					,created_by
					,created_date
					,deleted_by
					,deleted_date
					,revision_by
					,revision_date
					,STATUS
					,start_period
					,end_period
					,fiscal_calendar_id
					)
				SELECT @facid
					,Period
					,'N'
					,@CreatedBy
					,getdate()
					,NULL
					,NULL
					,NULL
					,NULL
					,'Open'
					,Startperiod
					,EndPeriod
					,gl.fiscal_calendar_id
				FROM #FiscalPeriods
				JOIN glap_fiscal_calendar gl ON #FiscalPeriods.facid = gl.fac_id
				WHERE gl.fac_id = @FacID
					AND #FiscalPeriods.FiscalYear IN (
						SELECT fiscal_year
						FROM glap_fiscal_calendar
						WHERE fiscal_year = @GLAPYear3
							AND calendar_type = 'AP'
						)
					AND calendar_type = 'AP'
					AND #FiscalPeriods.FiscalYear = @GLAPYear3
					AND gl.fiscal_year = @GLAPYear3

				INSERT INTO glap_fiscal_calendar_periods (
					fac_id
					,fiscal_period
					,deleted
					,created_by
					,created_date
					,deleted_by
					,deleted_date
					,revision_by
					,revision_date
					,STATUS
					,start_period
					,end_period
					,fiscal_calendar_id
					)
				SELECT @facid
					,Period
					,'N'
					,@CreatedBy
					,getdate()
					,NULL
					,NULL
					,NULL
					,NULL
					,'Open'
					,Startperiod
					,EndPeriod
					,gl.fiscal_calendar_id
				FROM #FiscalPeriods
				JOIN glap_fiscal_calendar gl ON #FiscalPeriods.facid = gl.fac_id
				WHERE gl.fac_id = @FacID
					AND #FiscalPeriods.FiscalYear IN (
						SELECT fiscal_year
						FROM glap_fiscal_calendar
						WHERE fiscal_year = @GLAPYear4
							AND calendar_type = 'AP'
						)
					AND calendar_type = 'AP'
					AND #FiscalPeriods.FiscalYear = @GLAPYear4
					AND gl.fiscal_year = @GLAPYear4

				DELETE
				FROM glap_fiscal_calendar
				WHERE fiscal_calendar_id NOT IN (
						SELECT fiscal_calendar_id
						FROM glap_fiscal_calendar_periods
						)
					AND fac_id = @facID

				UPDATE gl_configuration
				SET current_fiscal_year = (
						SELECT MIN(fiscal_year)
						FROM glap_fiscal_calendar
						WHERE fac_id = @FacIdDest
						)
				WHERE fac_id = @FacIdDest

				DROP TABLE #FiscalPeriods
			END

			--as_std_profile_consistency
			--==================================================================================
			SET @FacExist = 0

			SELECT @facexist = fac_id
			FROM as_std_profile_consistency
			WHERE fac_id = @FacIdDest

			IF @Facexist = 0
			BEGIN
				DECLARE @source_fac_id INT
					,@source_reg_id INT
					,@destination_fac_id INT
					,@start_table_id INT
					,@min_source_id INT
					,@min_destination_id INT
					,@max_source_id INT
					,@max_destination_id INT
					,@src_row_count INT
					,@dest_row_count INT

				--**************************SET parameters below*********************
				SELECT @source_fac_id = @SourceFac

				SELECT @destination_fac_id = @FacIdDest

				--**************************SET parameters above*********************
				CREATE TABLE #copy_as_std_profile_consistency (
					row_id INT IDENTITY
					,src_id INT
					,dst_id INT
					)

				INSERT INTO #copy_as_std_profile_consistency (src_id)
				SELECT std_profile_consistency_id
				FROM as_std_profile_consistency
				WHERE fac_id = @source_fac_id
					AND deleted = 'N'
				ORDER BY std_profile_consistency_id

				SELECT @src_row_count = count(*)
				FROM as_std_profile_consistency
				WHERE fac_id = @source_fac_id
					AND deleted = 'N'

				IF ISNULL(@src_row_count, 0) > 0
				BEGIN
					DECLARE @a_NextasstdprofileconsistencyKey INT

					SET @a_NextasstdprofileconsistencyKey = NULL

					DELETE
					FROM pcc_global_primary_key
					WHERE table_name = 'as_std_profile_consistency'
						AND key_column_name = 'std_profile_consistency_id';

					SELECT @a_NextasstdprofileconsistencyKey = coalesce(max(std_profile_consistency_id), 0)
					FROM dbo.as_std_profile_consistency WITH (NOLOCK)

					----EXECUTE get_next_primary_key 'as_std_profile_consistency'
					----	,'std_profile_consistency_id'
					----	,@a_NextasstdprofileconsistencyKey OUTPUT
					----	,@src_row_count
					SET @start_table_id = @a_NextasstdprofileconsistencyKey

					UPDATE #copy_as_std_profile_consistency
					SET dst_id = @start_table_id + row_id

					----+ (row_id - 1) 
					---- Commented By: Jaspeet Singh
					---- Date: 2021-07-21
					---- Reason: Because begin tran not wotj ith pcc_global_primary_key sp
					INSERT INTO as_std_profile_consistency (
						std_profile_consistency_id
						,std_assess_id
						,question_key
						,class_name
						,change_field
						,compare_field
						,id_type_id
						,enabled
						,fac_id
						,reg_id
						,deleted
						,deleted_by
						,deleted_date
						,profile_description
						)
					SELECT b.dst_id
						,std_assess_id
						,question_key
						,class_name
						,change_field
						,compare_field
						,id_type_id
						,enabled
						,@destination_fac_id
						,reg_id
						,'N'
						,NULL
						,NULL
						,profile_description
					FROM as_std_profile_consistency a
						,#copy_as_std_profile_consistency b
					WHERE a.deleted = 'N'
						AND a.fac_id = @source_fac_id
						AND a.std_profile_consistency_id = b.src_id
				END

				DROP TABLE #copy_as_std_profile_consistency
			END

			/* changed from above as per Shaojing Pan */
			INSERT INTO dbo.cp_std_intervention_fac (
				fac_id
				,std_intervention_id
				)
			SELECT @FacIdDest
				,std_intervention_id
			FROM cp_std_intervention
			WHERE (
					(
						fac_id IN (
							- 1
							,@FacIdDest
							)
						AND Reg_id IS NULL
						AND state_code IS NULL
						)
					OR (
						Reg_id = @regid
						AND state_code IS NULL
						)
					OR (
						Reg_id = @regid
						AND state_code = @state
						)
					)
				AND NOT EXISTS (
					SELECT 1
					FROM cp_std_intervention_fac cp
					WHERE fac_id = @FacIdDest
						AND cp.std_intervention_id = cp_std_intervention.std_intervention_id
					)
				AND deleted = 'N'

			INSERT INTO dbo.cp_std_freq_fac (
				fac_id
				,std_freq_id
				)
			SELECT @FacIdDest
				,std_freq_id
			FROM cp_std_frequency
			WHERE (
					(
						fac_id IN (
							- 1
							,@FacIdDest
							)
						AND Reg_id IS NULL
						AND state_code IS NULL
						)
					OR (
						Reg_id = @regid
						AND state_code IS NULL
						)
					OR (
						Reg_id = @regid
						AND state_code = @state
						)
					)
				AND NOT EXISTS (
					SELECT 1
					FROM cp_std_freq_fac cf
					WHERE fac_id = @FacIdDest
						AND cf.std_freq_id = cp_std_frequency.std_freq_id
					)
				AND deleted = 'N'

			INSERT INTO dbo.cp_std_fuq_fac (
				fac_id
				,question_id
				)
			SELECT @FacIdDest
				,std_question_id
			FROM cp_std_question
			WHERE (
					(
						fac_id IN (
							- 1
							,@FacIdDest
							)
						AND Reg_id IS NULL
						AND state_code IS NULL
						)
					OR (
						Reg_id = @regid
						AND state_code IS NULL
						)
					OR (
						Reg_id = @regid
						AND state_code = @state
						)
					)
				AND NOT EXISTS (
					SELECT 1
					FROM cp_std_fuq_fac cq
					WHERE fac_id = @FacIdDest
						AND cq.question_id = cp_std_question.std_question_id
					)
				AND deleted = 'N'

			INSERT INTO dbo.cp_std_shift_fac (
				fac_id
				,std_shift_id
				)
			SELECT @FacIdDest
				,std_shift_id
			FROM cp_std_shift
			WHERE (
					(
						fac_id IN (
							- 1
							,@FacIdDest
							)
						AND Reg_id IS NULL
						AND state_code IS NULL
						)
					OR (
						Reg_id = @regid
						AND state_code IS NULL
						)
					OR (
						Reg_id = @regid
						AND state_code = @state
						)
					)
				AND NOT EXISTS (
					SELECT 1
					FROM cp_std_shift_fac cs
					WHERE fac_id = @FacIdDest
						AND cs.std_shift_id = cp_std_shift.std_shift_id
					)
				AND deleted = 'N'

			/* end - changed from above as per Shaojing Pan */
			--=====================================================================================
			----State specific updates:  Arizona (AZ)
			--=====================================================================================
			IF @state = 'AZ'
			BEGIN
				--========================================
				--clear AZ FROM prov_state_options column
				--========================================
				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, ',AZ', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE '%,AZ%'
					--added Oct 16 as per Joel
					AND section_code <> 'T'

				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, 'AZ,', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE '%AZ,%'
					--added Oct 16 as per Joel
					AND section_code <> 'T'

				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, 'AZ', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE 'AZ'
					--added Oct 16 as per Joel
					AND section_code <> 'T'

				--========================================
				--AZ uses RUG III 97 version of quarterly
				--========================================
				UPDATE as_std_question
				SET prov_state_options = prov_state_options + ',AZ'
				WHERE std_assess_id = 1
					AND (
						question_key IN (
							'B3a'
							,'B3b'
							,'B3c'
							,'B3d'
							,'B3e'
							,'G1aB'
							,'G1bB'
							,'G1cB'
							,'G1dB'
							,'G1eB'
							,'G1fB'
							,'G1gB'
							,'G1hB'
							,'G1iB'
							,'G1jB'
							,'G3a'
							,'G3b'
							,'G7'
							,'H2c'
							,'I1a'
							,'I1ee'
							,'I1ff'
							,'I1m'
							,'I1r'
							,'I1rr'
							,'I1s'
							,'I1t'
							,'I1v'
							,'I1w'
							,'I1z'
							,'I2a'
							,'I2b'
							,'I2c'
							,'I2d'
							,'I2e'
							,'I2f'
							,'I2g'
							,'I2h'
							,'I2i'
							,'I2k'
							,'I2l'
							,'J1a'
							,'J1b'
							,'J1d'
							,'J1e'
							,'J1g'
							,'J1h'
							,'J1j'
							,'J1k'
							,'J1l'
							,'J1n'
							,'J1o'
							,'K1a'
							,'K1b'
							,'K1d'
							,'K2a'
							,'K2b'
							,'K5a'
							,'K6a'
							,'K6b'
							,'M4a'
							,'M4b'
							,'M4c'
							,'M4d'
							,'M4e'
							,'M4f'
							,'M4g'
							,'M4h'
							,'M5a'
							,'M5b'
							,'M5c'
							,'M5d'
							,'M5e'
							,'M5f'
							,'M5g'
							,'M5h'
							,'M5i'
							,'M5j'
							,'M6a'
							,'M6b'
							,'M6c'
							,'M6d'
							,'M6e'
							,'M6f'
							,'M6g'
							,'O3'
							,'P1aa'
							,'P1ab'
							,'P1ac'
							,'P1ad'
							,'P1ae'
							,'P1af'
							,'P1ag'
							,'P1ah'
							,'P1ai'
							,'P1aj'
							,'P1ak'
							,'P1al'
							,'P1am'
							,'P1an'
							,'P1ao'
							,'P1ap'
							,'P1aq'
							,'P1ar'
							,'P1as'
							,'P1baA'
							,'P1baB'
							,'P1bbA'
							,'P1bbB'
							,'P1bcA'
							,'P1bcB'
							,'P1bdA'
							,'P1bdB'
							,'P1beA'
							,'P1beB'
							,'P3a'
							,'P3b'
							,'P3c'
							,'P3d'
							,'P3e'
							,'P3f'
							,'P3g'
							,'P3h'
							,'P3i'
							,'P3j'
							,'P3k'
							,'P7'
							,'P8'
							,'T1aA'
							,'T1aB'
							,'T1b'
							,'T1c'
							,'T1d'
							,'T2a'
							,'T2b'
							,'T2c'
							,'T2d'
							,'T2e'
							,'T3MDCR'
							,'T3STATE'
							)
						)
					--added Oct 16 as per Joel
					AND section_code <> 'T'

				UPDATE as_std_question
				SET prov_state_options = 'AZ'
				WHERE std_assess_id = 1
					AND section_code = 'S(AZ)'
					--added Oct 16 as per Joel
					AND section_code <> 'T'
			END

			--==================================================================================================
			--State specific updates: Florida(FL)
			--==================================================================================================
			IF @State = 'FL'
			BEGIN
				--=======================
				-- Update group title for SFL1
				--=======================
				UPDATE as_std_question_group
				SET group_title = 'Facility FRAES number.'
				WHERE std_assess_id = 1
					AND std_question_no = 'S1'
					AND section_code = 'S(FL)'

				--============================
				-- Show section S on all types of mds
				--============================
				UPDATE as_std_question
				SET STATUS_A = 'A'
					,STATUS_AM = 'A'
					,STATUS_AO = 'A'
					,STATUS_D = 'A'
					,STATUS_O = 'A'
					,STATUS_OM = 'A'
					,status_om_mpaf = 'A'
					,STATUS_OO = 'A'
					,STATUS_Q = 'A'
					,STATUS_QM = 'A'
					,status_qm_mpaf = 'A'
					,STATUS_QO = 'A'
					,STATUS_R = 'A'
					,STATUS_X = 'A'
					,STATUS_Y = 'A'
					,STATUS_YM = 'A'
					,STATUS_YO = 'A'
					,required = 'N'
					,range = 'Text,sp'
				WHERE std_assess_id = 1
					AND section_code = 'S(FL)'

				--================================
				-- update to use RUGs 97
				--clear FL from prov_state_options column
				--================================
				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, ',FL', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE '%,FL%'

				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, 'FL,', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE '%FL,%'

				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, 'FL', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE 'FL'

				--================================
				--FL uses RUG III 97 version of quarterly
				--================================
				UPDATE as_std_question
				SET prov_state_options = prov_state_options + ',FL'
				WHERE std_assess_id = 1
					AND (
						question_key IN (
							'B3a'
							,'B3b'
							,'B3c'
							,'B3d'
							,'B3e'
							,'G1aB'
							,'G1bB'
							,'G1cB'
							,'G1dB'
							,'G1eB'
							,'G1fB'
							,'G1gB'
							,'G1hB'
							,'G1iB'
							,'G1jB'
							,'G3a'
							,'G3b'
							,'G7'
							,'H2c'
							,'I1a'
							,'I1ee'
							,'I1ff'
							,'I1m'
							,'I1r'
							,'I1rr'
							,'I1s'
							,'I1t'
							,'I1v'
							,'I1w'
							,'I1z'
							,'I2a'
							,'I2b'
							,'I2c'
							,'I2d'
							,'I2e'
							,'I2f'
							,'I2g'
							,'I2h'
							,'I2i'
							,'I2k'
							,'I2l'
							,'J1a'
							,'J1b'
							,'J1d'
							,'J1e'
							,'J1g'
							,'J1h'
							,'J1j'
							,'J1k'
							,'J1l'
							,'J1n'
							,'J1o'
							,'K1a'
							,'K1b'
							,'K1d'
							,'K2a'
							,'K2b'
							,'K5a'
							,'K6a'
							,'K6b'
							,'M4a'
							,'M4b'
							,'M4c'
							,'M4d'
							,'M4e'
							,'M4f'
							,'M4g'
							,'M4h'
							,'M5a'
							,'M5b'
							,'M5c'
							,'M5d'
							,'M5e'
							,'M5f'
							,'M5g'
							,'M5h'
							,'M5i'
							,'M5j'
							,'M6a'
							,'M6b'
							,'M6c'
							,'M6d'
							,'M6e'
							,'M6f'
							,'M6g'
							,'O3'
							,'P1aa'
							,'P1ab'
							,'P1ac'
							,'P1ad'
							,'P1ae'
							,'P1af'
							,'P1ag'
							,'P1ah'
							,'P1ai'
							,'P1aj'
							,'P1ak'
							,'P1al'
							,'P1am'
							,'P1an'
							,'P1ao'
							,'P1ap'
							,'P1aq'
							,'P1ar'
							,'P1as'
							,'P1baA'
							,'P1baB'
							,'P1bbA'
							,'P1bbB'
							,'P1bcA'
							,'P1bcB'
							,'P1bdA'
							,'P1bdB'
							,'P1beA'
							,'P1beB'
							,'P3a'
							,'P3b'
							,'P3c'
							,'P3d'
							,'P3e'
							,'P3f'
							,'P3g'
							,'P3h'
							,'P3i'
							,'P3j'
							,'P3k'
							,'P7'
							,'P8'
							,'T1aA'
							,'T1aB'
							,'T1b'
							,'T1c'
							,'T1d'
							,'T2a'
							,'T2b'
							,'T2c'
							,'T2d'
							,'T2e'
							,'T3MDCR'
							)
						)

				UPDATE as_std_question
				SET prov_state_options = 'FL'
				WHERE std_assess_id = 1
					AND section_code = 'S(FL)'
			END

			--==================================================================================================
			--State specific updates: Illinois (IL)
			--==================================================================================================
			IF @State = 'IL'
			BEGIN
				--===========================
				--SET MDS configuration:
				--===========================
				UPDATE as_configuration
				SET cmi_SET_state = 'B01'
					,calc_type_fed = 'Mcare'
					,calc_type_state = 'Index'
				WHERE fac_id = @FacIdDest

				--===========================
				--clear IL FROM prov_state_options column
				--===========================
				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, ',IL', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE '%,IL%'
					AND section_code <> 'U'
					--added Oct 16 as per Joel
					AND section_code <> 'T'

				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, 'IL,', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE '%IL,%'
					AND section_code <> 'U'
					--added Oct 16 as per Joel
					AND section_code <> 'T'

				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, 'IL', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE 'IL'
					AND section_code <> 'U'
					--added Oct 16 as per Joel
					AND section_code <> 'T'

				--============================
				--IL uses full version of quarterly
				--============================
				UPDATE as_std_question
				SET prov_state_options = prov_state_options + ',IL'
				WHERE std_assess_id = 1
					AND status_q = 'S'
					AND section_code <> 'U'
					AND section_code <> 'V'
					--added Oct 16 as per Joel
					AND section_code <> 'T'
					AND section_code NOT LIKE 'S%'

				UPDATE as_std_question
				SET prov_state_options = 'IL'
				WHERE std_assess_id = 1
					AND section_code = 'S(IL)'
					--added Oct 16 as per Joel
					AND section_code <> 'T'
			END

			--================================================================================================
			--State specific updates: Iowa (IA)
			--================================================================================================
			IF @state = 'IA'
			BEGIN
				--=======================
				--SET MDS configuration:
				--=======================
				UPDATE as_configuration
				SET cmi_SET_state = 'B01'
					,calc_type_fed = 'Mcare'
					,calc_type_state = 'Index'
				WHERE fac_id = @FacIdDest
			END

			--===========================================================================================
			--State specific updates: Indiana (IN)
			--===========================================================================================
			IF @State = 'IN'
			BEGIN
				--=========================
				--SET MDS configuration:
				--=========================
				UPDATE as_configuration
				SET cmi_SET_state = 'B01'
					,calc_type_fed = 'Mcare'
					,calc_type_state = 'Index'
				WHERE fac_id = @FacIdDest

				--=========================
				-- Additional Other/other UPDATE: getting rejected because of ampersANDs in p_rec_dt
				--=========================
				UPDATE as_std_question
				SET status_oo = 'A'
				WHERE std_assess_id = 1
					AND question_key = 'P_REC_DT'
			END

			--===========================================================================================
			--State specific updates: Kansas (KS)
			--===========================================================================================
			IF @State = 'KS'
			BEGIN
				--===================================
				--SET MDS configuration:
				--===================================
				UPDATE as_configuration
				SET cmi_SET_state = 'B01'
					,calc_type_fed = 'Mcare'
					,calc_type_state = 'Index'
				WHERE fac_id = @FacIdDest
			END

			--========================================================================================================
			--State specific updates: Kentucky (KY)
			--========================================================================================================
			IF @State = 'KY'
			BEGIN
				--=======================================
				--clear KY FROM prov_state_options column
				--=======================================
				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, ',KY', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE '%,KY%'
					--added Oct 16 as per Joel
					AND section_code <> 'T'

				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, 'KY,', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE '%KY,%'
					--added Oct 16 as per Joel
					AND section_code <> 'T'

				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, 'KY', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE 'KY'
					--added Oct 16 as per Joel
					AND section_code <> 'T'

				--=======================================
				--KY uses RUG III 97 version of quarterly
				--=======================================
				UPDATE as_std_question
				SET prov_state_options = prov_state_options + ',KY'
				WHERE std_assess_id = 1
					AND (
						question_key IN (
							'B3a'
							,'B3b'
							,'B3c'
							,'B3d'
							,'B3e'
							,'G1aB'
							,'G1bB'
							,'G1cB'
							,'G1dB'
							,'G1eB'
							,'G1fB'
							,'G1gB'
							,'G1hB'
							,'G1iB'
							,'G1jB'
							,'G3a'
							,'G3b'
							,'G7'
							,'H2c'
							,'I1a'
							,'I1ee'
							,'I1ff'
							,'I1m'
							,'I1r'
							,'I1rr'
							,'I1s'
							,'I1t'
							,'I1v'
							,'I1w'
							,'I1z'
							,'I2a'
							,'I2b'
							,'I2c'
							,'I2d'
							,'I2e'
							,'I2f'
							,'I2g'
							,'I2h'
							,'I2i'
							,'I2k'
							,'I2l'
							,'J1a'
							,'J1b'
							,'J1d'
							,'J1e'
							,'J1g'
							,'J1h'
							,'J1j'
							,'J1k'
							,'J1l'
							,'J1n'
							,'J1o'
							,'K1a'
							,'K1b'
							,'K1d'
							,'K2a'
							,'K2b'
							,'K5a'
							,'K6a'
							,'K6b'
							,'M4a'
							,'M4b'
							,'M4c'
							,'M4d'
							,'M4e'
							,'M4f'
							,'M4g'
							,'M4h'
							,'M5a'
							,'M5b'
							,'M5c'
							,'M5d'
							,'M5e'
							,'M5f'
							,'M5g'
							,'M5h'
							,'M5i'
							,'M5j'
							,'M6a'
							,'M6b'
							,'M6c'
							,'M6d'
							,'M6e'
							,'M6f'
							,'M6g'
							,'O3'
							,'P1aa'
							,'P1ab'
							,'P1ac'
							,'P1ad'
							,'P1ae'
							,'P1af'
							,'P1ag'
							,'P1ah'
							,'P1ai'
							,'P1aj'
							,'P1ak'
							,'P1al'
							,'P1am'
							,'P1an'
							,'P1ao'
							,'P1ap'
							,'P1aq'
							,'P1ar'
							,'P1as'
							,'P1baA'
							,'P1baB'
							,'P1bbA'
							,'P1bbB'
							,'P1bcA'
							,'P1bcB'
							,'P1bdA'
							,'P1bdB'
							,'P1beA'
							,'P1beB'
							,'P3a'
							,'P3b'
							,'P3c'
							,'P3d'
							,'P3e'
							,'P3f'
							,'P3g'
							,'P3h'
							,'P3i'
							,'P3j'
							,'P3k'
							,'P7'
							,'P8'
							)
						)
					--added Oct 16 as per Joel
					AND section_code <> 'T'

				UPDATE as_std_question
				SET prov_state_options = 'KY'
				WHERE std_assess_id = 1
					AND section_code = 'S(KY)'
					--added Oct 16 as per Joel
					AND section_code <> 'T'
			END

			--==========================================================================================================
			--State specific updates: Maine(ME)
			--==========================================================================================================
			IF @State = 'ME'
			BEGIN
				--===========================
				--clear ME FROM prov_state_options column
				--===========================
				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, ',ME', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE '%,ME%'
					AND section_code <> 'T'

				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, 'ME,', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE '%ME,%'
					AND section_code <> 'T'

				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, 'ME', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE 'ME'
					AND section_code <> 'T'

				--============================
				--ME uses full version of quarterly
				--============================
				UPDATE as_std_question
				SET prov_state_options = CASE 
						WHEN prov_state_options IS NULL
							THEN 'ME'
						ELSE prov_state_options + ',ME'
						END
				WHERE std_assess_id = 1
					AND status_q = 'S'
					AND section_code <> 'V'
					AND section_code <> 'T'
					AND section_code NOT LIKE 'S%'
			END

			--==========================================================================================================
			--State specific updates: Minnesota (MN)
			--==========================================================================================================
			IF @State = 'MN'
			BEGIN
				--========================
				--SET MDS configuration:
				--SELECT cmi_SET_state,calc_type_fed,calc_type_state,* FROM as_configuration
				--========================
				UPDATE as_configuration
				SET cmi_SET_state = 'MN'
					,calc_type_fed = 'Mcare'
					,calc_type_state = 'Index'
				WHERE fac_id = @FacIdDest

				/* Added this script as per Case#108372 */
				--if @State = 'MN'
				--begin 
				INSERT INTO census_status_code_setup (
					status_code_id
					,fac_id
					,date_range_code
					,created_by
					,created_date
					,revision_by
					,revision_date
					)
				SELECT c.ITEM_ID
					,@facId
					,0
					,'PCC-2771'
					,getdate()
					,'PCC-2771'
					,getdate()
				FROM CENSUS_CODES c
				WHERE c.table_code = 'SC'
					AND (
						deleted = 'N'
						OR deleted IS NULL
						)
					AND c.ITEM_ID NOT IN (
						SELECT status_code_id
						FROM census_status_code_setup
						WHERE fac_id = @facId
						)
					--end
			END

			--==========================================================================================================
			--State specific updates: Nebraska (NE)
			--==========================================================================================================
			IF @State = 'NE'
			BEGIN
				--=============================
				--SET MDS configuration:
				--=============================
				UPDATE as_configuration
				SET cmi_SET_state = ''
					,calc_type_fed = 'Mcare'
					,calc_type_state = 'Hier'
				WHERE fac_id = @FacIdDest
			END

			--==========================================================================================================
			--State specific updates: Ohio (OH)
			--==========================================================================================================
			IF @State = 'OH'
			BEGIN
				--==========================
				--SET MDS configuration:
				--==========================
				UPDATE as_configuration
				SET cmi_SET_state = 'OHIO'
					,calc_type_fed = 'Mcare'
					,calc_type_state = 'Hier'
				WHERE fac_id = @FacIdDest
			END

			--==========================================================================================================
			--State specific updates: Virginia (VA)
			--==========================================================================================================
			IF @State = 'VA'
			BEGIN
				--========================================
				--clear VA FROM prov_state_options column
				--========================================
				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, ',VA', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE '%,VA%'
					--added Oct 16 as per Joel
					AND section_code <> 'T'

				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, 'VA,', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE '%VA,%'
					--added Oct 16 as per Joel
					AND section_code <> 'T'

				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, 'VA', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE 'VA'
					--added Oct 16 as per Joel
					AND section_code <> 'T'

				--========================================
				--VA uses RUG III 97 version of quarterly
				--========================================
				UPDATE as_std_question
				SET prov_state_options = prov_state_options + ',VA'
				WHERE std_assess_id = 1
					AND (
						question_key IN (
							'B3a'
							,'B3b'
							,'B3c'
							,'B3d'
							,'B3e'
							,'G1aB'
							,'G1bB'
							,'G1cB'
							,'G1dB'
							,'G1eB'
							,'G1fB'
							,'G1gB'
							,'G1hB'
							,'G1iB'
							,'G1jB'
							,'G3a'
							,'G3b'
							,'G7'
							,'H2c'
							,'I1a'
							,'I1ee'
							,'I1ff'
							,'I1m'
							,'I1r'
							,'I1rr'
							,'I1s'
							,'I1t'
							,'I1v'
							,'I1w'
							,'I1z'
							,'I2a'
							,'I2b'
							,'I2c'
							,'I2d'
							,'I2e'
							,'I2f'
							,'I2g'
							,'I2h'
							,'I2i'
							,'I2k'
							,'I2l'
							,'J1a'
							,'J1b'
							,'J1d'
							,'J1e'
							,'J1g'
							,'J1h'
							,'J1j'
							,'J1k'
							,'J1l'
							,'J1n'
							,'J1o'
							,'K1a'
							,'K1b'
							,'K1d'
							,'K2a'
							,'K2b'
							,'K5a'
							,'K6a'
							,'K6b'
							,'M4a'
							,'M4b'
							,'M4c'
							,'M4d'
							,'M4e'
							,'M4f'
							,'M4g'
							,'M4h'
							,'M5a'
							,'M5b'
							,'M5c'
							,'M5d'
							,'M5e'
							,'M5f'
							,'M5g'
							,'M5h'
							,'M5i'
							,'M5j'
							,'M6a'
							,'M6b'
							,'M6c'
							,'M6d'
							,'M6e'
							,'M6f'
							,'M6g'
							,'O3'
							,'P1aa'
							,'P1ab'
							,'P1ac'
							,'P1ad'
							,'P1ae'
							,'P1af'
							,'P1ag'
							,'P1ah'
							,'P1ai'
							,'P1aj'
							,'P1ak'
							,'P1al'
							,'P1am'
							,'P1an'
							,'P1ao'
							,'P1ap'
							,'P1aq'
							,'P1ar'
							,'P1as'
							,'P1baA'
							,'P1baB'
							,'P1bbA'
							,'P1bbB'
							,'P1bcA'
							,'P1bcB'
							,'P1bdA'
							,'P1bdB'
							,'P1beA'
							,'P1beB'
							,'P3a'
							,'P3b'
							,'P3c'
							,'P3d'
							,'P3e'
							,'P3f'
							,'P3g'
							,'P3h'
							,'P3i'
							,'P3j'
							,'P3k'
							,'P7'
							,'P8'
							,'T1aA'
							,'T1aB'
							,'T1b'
							,'T1c'
							,'T1d'
							,'T2a'
							,'T2b'
							,'T2c'
							,'T2d'
							,'T2e'
							,'T3MDCR'
							,'T3STATE'
							)
						)
					--added Oct 16 as per Joel
					AND section_code <> 'T'

				UPDATE as_std_question
				SET prov_state_options = 'VA'
				WHERE std_assess_id = 1
					AND section_code = 'S(VA)'
					--added Oct 16 as per Joel
					AND section_code <> 'T'
			END

			--=======================================
			--added due to the issue in case830770 - orphan data in configuration_parameter
			DELETE
			FROM configuration_parameter
			WHERE fac_id NOT IN (
					SELECT fac_id
					FROM facility
					WHERE fac_id <> @FacIdDest
					)
				AND fac_id NOT IN (
					1
					,- 1
					,9001
					)

			------------------------------------------
			SET @FacExist = 0

			SELECT @facexist = fac_id
			FROM configuration_parameter
			WHERE fac_id = @FacIdDest

			DECLARE @sql_cmd VARCHAR(max)
			DECLARE @ALF_template_db VARCHAR(50)

			IF @Facexist = 0
			BEGIN
				IF @FacIdDest = 1
				BEGIN
					INSERT INTO configuration_parameter (
						fac_id
						,[name]
						,value
						)
					SELECT @FacIdDest
						,[name]
						,value
					FROM configuration_parameter
					WHERE fac_id = @SourceFac
						AND NAME NOT LIKE '%closed%' --Added by Rina on  02/02/2010 -- As per Kevin's  suggestion
						AND NAME NOT IN (
							SELECT NAME
							FROM configuration_parameter
							WHERE (
									NAME IN (
										'enable_poc'
										,'show_poc_security'
										,'turn_on_poc'
										)
									OR (NAME LIKE 'poc%')
									)
							) --ADDED 7/22/2010
						AND NAME NOT IN (
							SELECT NAME
							FROM configuration_parameter
							WHERE fac_id = @destination_fac_id
							)
						AND NAME NOT IN (
							'enable_emar'
							,'enable_mar'
							) -- Added by Rina  8/20/2010
				END
				ELSE
				BEGIN
					IF @healthtype = 'ALF' --Added by Bipin Maliakal as per Ann's suggestion on 12/02/2014
					BEGIN
						SET @ALF_template_db = 'train_us_alftmplt'
						SET @sql_cmd = '
						INSERT INTO configuration_parameter (fac_id,[name],value)
						SELECT ' + convert(VARCHAR(10), @FacIdDest) + ' ,[name],value 
						FROM [' + @template_server + '].' + @ALF_template_db + '.dbo.configuration_parameter
						WHERE fac_id = 1
						AND name not like ''%closed%''
						and name not in (select name from dbo.configuration_parameter where fac_id=' + convert(VARCHAR(10), @FacIdDest) + ')
						AND name not in (''enable_emar'',''enable_mar'',''enable_poc'',''show_poc_security'',''turn_on_poc'',''enable_cs_default_quick_link_icon'',''enable_cs_quick_link'',''enable_cs_quick_link_icon_desc'',''enable_cs_quick_link_url'') 
						AND name not like ''poc%''' -- added by Ryan - as per case 480948 / issue 16729 - 07/14/2015

						EXEC (@sql_cmd)
					END
					ELSE
					BEGIN
						SET @sql_cmd = '
						INSERT INTO configuration_parameter (fac_id,[name],value)
						SELECT ' + convert(VARCHAR(10), @FacIdDest) + ' ,[name],value 
						FROM [' + @template_server + '].' + @template_db + '.dbo.configuration_parameter
						WHERE fac_id = 1
						AND name not like ''%closed%''
						and name not in (select name from dbo.configuration_parameter where fac_id=' + convert(VARCHAR(10), @FacIdDest) + ')
						AND name not in (''enable_emar'',''enable_mar'',''enable_poc'',''show_poc_security'',''turn_on_poc'',''enable_cs_default_quick_link_icon'',''enable_cs_quick_link'',''enable_cs_quick_link_icon_desc'',''enable_cs_quick_link_url'')
						AND name not like ''poc%''' -- added by Ryan - as per case 480948 / issue 16729 - 07/14/2015

						EXEC (@sql_cmd)
					END
				END
			END

			BEGIN
				INSERT INTO sec_user_facility
				SELECT b.userid
					,a.fac_id
					,1
				FROM facility a
					,sec_user b
				WHERE b.admin_user_type = 'E'
					AND a.fac_id NOT IN (
						SELECT facility_id
						FROM sec_user_facility
						WHERE userid = b.userid
						)
			END

			/* Update the address info in the facility */
			UPDATE [dbo].facility
			SET address1 = @add1
				,address2 = @add2
				,city = @city
				,pc = @pc
				,tel = @tel
			WHERE fac_id = @FacIdDest

			--added for CM15943
			--=======================================
			SET @FacExist = 0

			SELECT @facexist = fac_id
			FROM crm_field_config
			WHERE fac_id = @FacIdDest

			IF @Facexist = 0
			BEGIN
				DECLARE @rowcnt INT
					,@NID INT

				SELECT identity(INT, 1, 1) AS field_id
					,field_name
					,field_label
					,field_type
					,func_id
					,mandatory
				INTO #t_crm_field_config
				FROM crm_field_config
				WHERE fac_id = @SourceFac

				SET @rowcnt = @@rowcount

				--UPDATE #t_crm_field_config
				--SET	field_id = field_id - 1
				----PRINT @rowcnt
				IF @rowcnt > 0
				BEGIN
					SET @NID = NULL

					DELETE
					FROM pcc_global_primary_key
					WHERE table_name = 'crm_field_config'
						AND key_column_name = 'field_id';

					SELECT @NID = coalesce(max(field_id), 0)
					FROM dbo.crm_field_config WITH (NOLOCK)

					----EXECUTE get_next_primary_key 'crm_field_config'
					----	,'field_id'
					----	,@NID OUTPUT
					----	,@rowcnt
					----PRINT @NID
					INSERT INTO crm_field_config
					SELECT @NID + field_id
						,@CreatedBy
						,getdate()
						,@CreatedBy
						,getdate()
						,field_name
						,field_label
						,field_type
						,@FacIdDest
						,func_id
						,mandatory
					FROM #t_crm_field_config
				END

				DROP TABLE #t_crm_field_config
			END

			/* As per Jayne, Use Medi-Span Library should be Yes, Check_duplicates and Always Show Generics should be checked
   This is in Physician Order Configuration - Superuser */
			INSERT INTO configuration_parameter
			SELECT @FacIdDest
				,'enable_ext_lib'
				,'Y'
			WHERE NOT EXISTS (
					SELECT 1
					FROM configuration_parameter c
					WHERE c.fac_id = @FacIdDest
						AND c.NAME = 'enable_ext_lib'
					)

			INSERT INTO configuration_parameter
			SELECT @FacIdDest
				,'check_duplicates'
				,'Y'
			WHERE NOT EXISTS (
					SELECT 1
					FROM configuration_parameter c
					WHERE c.fac_id = @FacIdDest
						AND c.NAME = 'check_duplicates'
					)

			INSERT INTO configuration_parameter
			SELECT @FacIdDest
				,'show_generics'
				,'Y'
			WHERE NOT EXISTS (
					SELECT 1
					FROM configuration_parameter c
					WHERE c.fac_id = @FacIdDest
						AND c.NAME = 'show_generics'
					)

			UPDATE configuration_parameter
			SET value = 'Y'
			--select * 
			FROM configuration_parameter
			WHERE NAME IN (
					'enable_ext_lib'
					,'check_duplicates'
					,'show_generics'
					)
				AND fac_id = @FacIdDest

			SET @FacExist = 0

			SELECT @facexist = fac_id
			FROM as_submission_accounts_mds_30
			WHERE fac_id = @FacIdDest

			IF @Facexist = 0
			BEGIN
				SELECT identity(INT, 1, 1) AS row
					,@FacIdDest AS fac_id
					,0 AS [status]
					,test_status
					,cms_account_name
					,cms_account_description
					,cms_url
					,account_type
				INTO #t_as_submission_accounts_mds_30
				FROM as_submission_accounts_mds_30
				WHERE fac_id = @SourceFac

				SET @rowcnt = @@rowcount

				IF @rowcnt > 0
				BEGIN
					SET @NID = NULL

					DELETE
					FROM pcc_global_primary_key
					WHERE table_name = 'as_submission_accounts_mds_30'
						AND key_column_name = 'account_id';

					SELECT @NID = coalesce(max(account_id), 0)
					FROM dbo.as_submission_accounts_mds_30 WITH (NOLOCK)

					----EXECUTE get_next_primary_key 'as_submission_accounts_mds_30'
					----	,'account_id'
					----	,@NID OUTPUT
					----	,@rowcnt
					----PRINT @NID
					INSERT INTO as_submission_accounts_mds_30 (
						account_id
						,fac_id
						,STATUS
						,test_status
						,cms_account_name
						,cms_account_description
						,cms_url
						,revision_by
						,revision_date
						,account_type
						)
					SELECT @NID + [row]
						,fac_id
						,[status]
						,test_status
						,cms_account_name
						,cms_account_description
						,cms_url
						,@CreatedBy
						,getdate()
						,account_type
					FROM #t_as_submission_accounts_mds_30
				END

				DROP TABLE #t_as_submission_accounts_mds_30
			END

			/*
Insert the facility template related to W&V Thresholds 
*/
			DECLARE @max_id INT
				,@return_value INT
				,@col_name VARCHAR(100)
				,@tmp_table_sql NVARCHAR(max)
				,@insert_table_sql NVARCHAR(max)
				,@table_columns NVARCHAR(max) = '';

			SET @facexist = 0

			SELECT @facexist = fac_id
			FROM wv_std_vitals_thresholds
			WHERE fac_id = @FacIdDest;

			IF @facexist = 0
			BEGIN
				UPDATE pcc_global_primary_key
				SET next_key = (
						SELECT max(threshold_id) + 1
						FROM wv_std_vitals_thresholds
						)
				WHERE table_name = 'wv_std_vitals_thresholds';

				-- determine all columns to include	
				DECLARE col_cursor CURSOR FAST_FORWARD
				FOR
				SELECT column_name
				FROM INFORMATION_SCHEMA.COLUMNS WITH (NOLOCK)
				WHERE TABLE_NAME = 'wv_std_vitals_thresholds'
					AND column_name NOT IN (
						'threshold_id'
						,'fac_id'
						,'created_by'
						,'created_date'
						,'revision_by'
						,'revision_date'
						,'fac_id'
						)
				ORDER BY ORDINAL_POSITION;

				OPEN col_cursor

				FETCH NEXT
				FROM col_cursor
				INTO @col_name

				WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @table_columns = @table_columns + ',' + @col_name;

					FETCH NEXT
					FROM col_cursor
					INTO @col_name
				END

				CLOSE col_cursor

				DEALLOCATE col_cursor

				-- Create temp table based on the template facility (fac_id=1)
				SELECT TOP 1 *
				INTO #wv_std_vitals_thresholds
				FROM wv_std_vitals_thresholds wv;--initialize

				SET @tmp_table_sql = 'truncate table #wv_std_vitals_thresholds;
		INSERT INTO #wv_std_vitals_thresholds 
			SELECT 
			ROW_NUMBER() OVER(ORDER BY threshold_id ASC) AS threshold_id
			,@FacIdDest AS fac_id
			,''wescom'' AS created_by
			,getdate() AS created_date
			,''wescom'' AS revision_by
			,getdate() AS revision_date
			' + @table_columns + '			
			FROM wv_std_vitals_thresholds wv
			WHERE wv.client_id IS NULL AND wv.fac_id = @SourceFac';

				EXECUTE sp_executesql @tmp_table_sql
					,N'@FacIdDest int, @SourceFac int'
					,@FacIdDest = @FacIdDest
					,@SourceFac = @SourceFac;

				-- select * from #wv_std_vitals_thresholds;
				SET @Rowcount = @@rowcount

				SELECT @Rowcount = 0
				WHERE @Rowcount IS NULL

				IF @Rowcount > 0
				BEGIN
					SET @Rowcount = @Rowcount + 1;
					SET @max_id = NULL

					DELETE
					FROM pcc_global_primary_key
					WHERE table_name = 'wv_std_vitals_thresholds'
						AND key_column_name = 'threshold_id';

					SELECT @max_id = coalesce(max(threshold_id), 0)
					FROM dbo.wv_std_vitals_thresholds WITH (NOLOCK)

					----EXEC @return_value = get_next_primary_key 'wv_std_vitals_thresholds'
					----	,'threshold_id'
					----	,@max_id OUTPUT
					----	,@Rowcount;
					-- Copy template into new facility
					SET @insert_table_sql = '
				INSERT INTO wv_std_vitals_thresholds (
					threshold_id
					,fac_id
					,created_by
					,created_date
					,revision_by
					,revision_date
					' + @table_columns + '
					)
				SELECT threshold_id + @max_id 
					,fac_id
					,created_by
					,created_date
					,revision_by
					,revision_date
					' + @table_columns + '
					FROM #wv_std_vitals_thresholds
				';

					-- print @insert_table_sql;
					EXECUTE sp_executesql @insert_table_sql
						,N'@max_id int'
						,@max_id;
				END

				DROP TABLE #wv_std_vitals_thresholds;
			END
			ELSE
			BEGIN
				PRINT 'Facility has already been configured for weights and vitals thresholds.';
			END

			--update general_config set country_id = 100  where fac_id = 1
			--
			--update ar_configuration set term_client = 'Resident',show_cash_receipt_type_summary = 'Y',ub_facility_type = '2',aging_bucket_count = '24',medicare_no_pay_flag = 'Y',
			--                        anc_post_date_flag = 'N', adj_post_date_flag = 'N',cash_receipt_comment_flag = 'Y',batch_report_comment_flag = 'Y',
			--                        allow_future_census_flag = 'Y',days_before_closing_month = 0
			-- where fac_id = 1
			------ Added  from  IRM  Activation Script 6/18/2010
			--PCC-349: 				Script to populate IRM Configuration table
			--
			--Written By:			Jaymee Aquino
			--Reviewed By:
			--
			--Script Type:			DML
			--Target DB Type: 		CLIENT
			--Target Environment:	US
			--Date: Jan 12, 2009
			--
			--Re-Runable: YES
			--
			--Description of Script Function:
			-- ADD a row in 'crm_configuration' table for each row in 'facility' table
			--
			--Special Instruction:
			-- NONE
			--------------------------------------------------------------------------------------
			IF EXISTS (
					SELECT table_name
					FROM information_schema.tables
					WHERE table_name = 'crm_configuration'
						AND table_schema = 'dbo'
					)
			BEGIN
				INSERT INTO crm_configuration (
					fac_id
					,created_by
					,created_date
					,revision_by
					,revision_date
					,fax_server_name
					,smtp_server_name
					,term_inquiry
					,term_marketing
					,fax_server_dial_prefix
					,term_client
					,inquiry_created_in
					,max_episode_list
					,term_careline
					,all_ecin_referrals
					,ecin_assign_to_id
					,all_curaspan_referrals
					,curaspan_assign_to_id
					,statement_header_image_id
					,statement_footer_image_id
					,signature_image_id
					,waiting_list_threshold
					,intake_process_flag
					,create_qadt_flag
					)
				SELECT fac.fac_id
					,'wescom'
					,getdate()
					,'wescom'
					,getdate()
					,NULL
					,NULL
					,''
					,'IRM'
					,NULL
					,NULL
					,NULL
					,NULL
					,''
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,7
					,'C'
					,'Y'
				FROM facility fac
				LEFT JOIN crm_configuration config ON fac.fac_id = config.fac_id
				WHERE isnull(fac.deleted, 'N') = 'N'
					AND config.fac_id IS NULL

				-------Added by  Ann  AS per  Fran
				IF NOT EXISTS (
						SELECT 1
						FROM CLIENTS
						)
					AND (
						SELECT count(1)
						FROM facility
						WHERE deleted = 'N'
							AND fac_id <> 9001
						) > 1
				BEGIN
					SET @sql_cmd = '
		IF  NOT EXISTS (select 1 From ar_accounts a left join [' + @template_server + '].' + @template_db + '.dbo.ar_accounts b on a.account_id = b.account_id  and a.fac_id = b.fac_id and a.created_by = b.created_by and a.created_date = b.created_date and a.revision_by = b.revision_by and a.revision_date = b.revision_date where b.account_id is null 
		union 
		select 1 From ar_payers a left join [' + @template_server + '].' + @template_db + '.dbo.ar_payers b on a.payer_id = b.payer_id  and a.fac_id = b.fac_id and a.created_by = b.created_by and a.created_date = b.created_date and a.revision_by = b.revision_by and a.revision_date = b.revision_date where b.payer_id is null
		union 
		select 1 From ar_item_types a left join [' + @template_server + '].' + @template_db + 
						'.dbo.ar_item_types b on a.item_type_id = b.item_type_id  and a.fac_id = b.fac_id and a.created_by = b.created_by and a.created_date = b.created_date and a.revision_by = b.revision_by and a.revision_date = b.revision_date where b.item_type_id is null 
		union
		select 1 From ar_item_date_range a left join [' + @template_server + '].' + @template_db + '.dbo.ar_item_date_range b on a.item_type_id = b.item_type_id and a.fac_id = b.fac_id and a.effective_date = b.effective_date and isnull(a.amount,0) = isnull(b.amount,0) where b.item_type_id is null 
		union
		select 1 From ar_date_range a left join [' + @template_server + '].' + @template_db + 
						'.dbo.ar_date_range b on a.eff_date_range_id = b.eff_date_range_id  and a.payer_id = b.payer_id and a.fac_id = b.fac_id and a.created_by = b.created_by and a.created_date = b.created_date and a.revision_by = b.revision_by and a.revision_date = b.revision_date where b.eff_date_range_id is null 
		)
		BEGIN

		IF OBJECT_ID(N''pcc_temp_storage.._bkp_ar_payers_' + @Creator + ''', N''U'') IS NOT NULL 
			DROP TABLE pcc_temp_storage.dbo._bkp_ar_payers_' + @Creator + '
		IF OBJECT_ID(N''pcc_temp_storage.._bkp_ar_item_types_' + @Creator + ''', N''U'') IS NOT NULL 
			DROP TABLE pcc_temp_storage.dbo._bkp_ar_item_types_' + @Creator + '
		IF OBJECT_ID(N''pcc_temp_storage.._bkp_ar_item_date_range_' + @Creator + ''', N''U'') IS NOT NULL 
			DROP TABLE pcc_temp_storage.dbo._bkp_ar_item_date_range_' + @Creator + '
		IF OBJECT_ID(N''pcc_temp_storage.._bkp_ar_eff_rate_schedule_' + @Creator + ''', N''U'') IS NOT NULL 
			DROP TABLE pcc_temp_storage.dbo._bkp_ar_eff_rate_schedule_' + @Creator + 
						'
		IF OBJECT_ID(N''pcc_temp_storage.._bkp_ar_rate_detail_' + @Creator + ''', N''U'') IS NOT NULL 
			DROP TABLE pcc_temp_storage.dbo._bkp_ar_rate_detail_' + @Creator + '


		SELECT * INTO pcc_temp_storage.dbo._bkp_ar_payers_' + @Creator + ' FROM ar_payers where fac_id=1
		SELECT * INTO pcc_temp_storage.dbo._bkp_ar_item_types_' + @Creator + ' FROM ar_item_types where fac_id=1
		SELECT * INTO pcc_temp_storage.dbo._bkp_ar_item_date_range_' + @Creator + ' FROM ar_item_date_range where fac_id=1
		SELECT * INTO pcc_temp_storage.dbo._bkp_ar_eff_rate_schedule_' + @Creator + ' FROM ar_eff_rate_schedule where fac_id=1
		SELECT * INTO pcc_temp_storage.dbo._bkp_ar_rate_detail_' + @Creator + 
						' FROM ar_rate_detail where fac_id=1

		delete ar_payers where fac_id=1
		delete  ar_item_types where fac_id=1
		delete  ar_item_date_range where fac_id=1
		delete  ar_eff_rate_schedule where fac_id=1
		delete  ar_rate_detail where fac_id=1
		update ar_accounts set deleted=''Y'', deleted_date=getdate(),deleted_by=''' + @Creator + ''' where fac_id=1 and deleted=''N''
		update  ar_date_range set deleted=''Y'', deleted_date=getdate(),deleted_by=''' + @Creator + ''' where  fac_id=1 and deleted=''N''
		END
		'

					--	print @sql_cmd
					EXEC (@sql_cmd)
				END
			END

			INSERT INTO as_std_assessment_facility
			SELECT @FacIdDest
				,std_assess_id
			FROM as_std_assessment
			WHERE (
					(
						fac_id = - 1
						AND reg_id IS NULL
						AND state_code IS NULL
						)
					OR (
						fac_id = @FacIdDest
						AND reg_id IS NULL
						AND state_code IS NULL
						)
					OR state_code IN (
						SELECT prov
						FROM facility
						WHERE fac_id = @FacIdDest
						)
					OR (
						reg_id IN (
							SELECT regional_id
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						AND state_code IN (
							SELECT prov
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						)
					OR (
						reg_id IN (
							SELECT regional_id
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						AND state_code IS NULL
						)
					)
				AND NOT EXISTS (
					SELECT 1
					FROM as_std_assessment_facility
					WHERE fac_id = @FacIdDest
						AND std_assess_id = as_std_assessment.std_assess_id
					)
				AND brand_id IS NULL -- Filter added for COMS uda's
				AND std_assess_id NOT IN (
					SELECT std_assess_id
					FROM as_std_assessment_system_assessment_mapping
					WHERE system_type_id IN (
							1
							,100
							)
					) -- Filter added for eInteract uda's
				AND [status] NOT IN ('I') -- Added BY: Jaspreet Singh, Date: 2018-05-10, Reason: Smartsheet DShelper&OtherDevelopment task# 149

			INSERT INTO pho_std_order_fac
			SELECT std_order_id
				,@FacIdDest
			FROM pho_std_order
			WHERE (
					(
						fac_id = - 1
						AND isnull(reg_id, - 1) = - 1
						AND state_code IS NULL
						)
					OR (
						fac_id = @FacIdDest
						AND isnull(reg_id, - 1) = - 1
						AND state_code IS NULL
						)
					OR state_code IN (
						SELECT prov
						FROM facility
						WHERE fac_id = @FacIdDest
						)
					OR (
						reg_id IN (
							SELECT regional_id
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						AND state_code IN (
							SELECT prov
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						)
					OR (
						reg_id IN (
							SELECT regional_id
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						AND state_code IS NULL
						)
					)
				AND NOT EXISTS (
					SELECT 1
					FROM pho_std_order_fac
					WHERE fac_id = @FacIdDest
						AND std_order_id = pho_std_order.std_order_id
					)

			------- added by RYAN - Case 694329 -- 11/24/2015
			INSERT INTO facility_mapping
			SELECT @FacIdDest
				,@netsuiteID
				,@Creator
				,getdate()
				,@Creator
				,getdate()

			-- Added for case 773333 by Celine -- 05/16/2016
			SET @FacExist = 0

			SELECT @FacExist = fac_id
			FROM as_vendor_configuration
			WHERE fac_id = @FacIdDest
				AND vendor_code = 'SWIFT_MDS'

			IF @Facexist = 0
			BEGIN
				DECLARE @vendorId INT

				SET @vendorId = NULL

				DELETE
				FROM pcc_global_primary_key
				WHERE table_name = 'as_vendor_configuration'
					AND key_column_name = 'vendor_id';

				SELECT @vendorId = coalesce(max(vendor_id), 0)
				FROM dbo.as_vendor_configuration WITH (NOLOCK)

				SET @vendorId = @vendorId + 1

				----EXEC @return_value = get_next_primary_key 'as_vendor_configuration'
				----	,'vendor_id'
				----	,@vendorId OUTPUT
				----	,1
				INSERT INTO as_vendor_configuration (
					vendor_id
					,fac_id
					,description
					,url
					,timeout
					,priority
					,deleted
					,vendor_code
					,username
					,password
					,account_description
					,STATUS
					,std_assess_id
					,messaging_protocol
					,vendor_type
					)
				VALUES (
					@vendorId
					,@FacIdDest
					,'PCC Skin & Wound MDS'
					,'https://api.swiftmedical.io/pcc'
					,60000
					,1
					,'N'
					,'SWIFT_MDS'
					,'api@pointclickcare.com'
					,'hYUhBlwwFl_UDQPVf4mOEw'
					,'PCC Skin & Wound MDS'
					,'I'
					,11
					,'REST'
					,'SKIN_WOUND'
					)
			END

			--added on June 15, 2016
			IF @healthtype = 'HHC'
			BEGIN
				UPDATE api_authorization
				SET enabled = 'Y'
					,revision_by = @Creator
					,revision_date = getdate()
				WHERE partner_name = 'homehealth'
					AND enabled <> 'Y'
			END

			--added on Oct 13,2016 as per Carmen Gligor and Shaojing Pan
			UPDATE a
			SET value = (
					CASE 
						WHEN f.country_id = 100
							THEN 'Y'
						ELSE 'N'
						END
					)
			FROM configuration_parameter a
			INNER JOIN facility f ON a.fac_id = f.fac_id
			WHERE a.NAME = 'diagnosis_sheet'
				AND a.fac_id = @FacIdDest
				AND value <> (
					CASE 
						WHEN f.country_id = 100
							THEN 'Y'
						ELSE 'N'
						END
					)

			INSERT INTO configuration_parameter (
				fac_id
				,NAME
				,value
				)
			SELECT fac.fac_id
				,'diagnosis_sheet'
				,CASE fac.country_id
					WHEN 100
						THEN 'Y'
					ELSE 'N'
					END
			FROM facility fac
			LEFT JOIN configuration_parameter conf ON fac.fac_id = conf.fac_id
				AND conf.NAME = 'diagnosis_sheet'
			WHERE deleted = 'N'
				AND conf.fac_id IS NULL

			--end added on Oct 13,2016
			--------added on June 8, 2017
			SET @sql_cmd = 'insert into common_code_activation
select item_id, ' + convert(VARCHAR(10), @FacIdDest) + ' from common_code where item_code in
(select b.item_code
from  [' + @template_server + '].' + @template_db + '.dbo.common_code_activation a inner join  [' + @template_server + '].' + @template_db + '.dbo.common_code b
on a.item_id = b.item_id)
and deleted = ''N''
and ((fac_id = -1 and isnull(reg_id,-1) = -1 and state_code is NULL)
or (fac_id = ' + convert(VARCHAR(10), @FacIdDest) + ' and isnull(reg_id,-1) = -1 and state_code is NULL)
or state_code in (select prov from facility where fac_id = ' + convert(VARCHAR(10), @FacIdDest) + ')
or (reg_id in (select regional_id from facility where fac_id = ' + convert(VARCHAR(10), @FacIdDest) + ') and state_code in (select prov from facility where fac_id = ' + convert(VARCHAR(10), @FacIdDest) + '))
or (reg_id in (select regional_id from facility where fac_id = ' + convert(VARCHAR(10), @FacIdDest) + 
				') and state_code is NULL)
)
AND NOT EXISTS (SELECT 1 FROM common_code_activation cca
                        WHERE fac_id = ' + convert(VARCHAR(10), @FacIdDest) + '
                        AND cca.item_id = common_code.item_id)'

			EXEC (@sql_cmd)

			INSERT INTO id_type_activation
			SELECT id_type_id
				,@FacIdDest
			FROM id_type
			WHERE deleted = 'N'
				AND (
					(
						fac_id = - 1
						AND isnull(reg_id, - 1) = - 1
						AND state_code IS NULL
						)
					OR (
						fac_id = @FacIdDest
						AND isnull(reg_id, - 1) = - 1
						AND state_code IS NULL
						)
					OR state_code IN (
						SELECT prov
						FROM facility
						WHERE fac_id = @FacIdDest
						)
					OR (
						reg_id IN (
							SELECT regional_id
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						AND state_code IN (
							SELECT prov
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						)
					OR (
						reg_id IN (
							SELECT regional_id
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						AND state_code IS NULL
						)
					)
				AND NOT EXISTS (
					SELECT 1
					FROM id_type_activation cca
					WHERE fac_id = @FacIdDest
						AND cca.id_type_id = id_type.id_type_id
					)

			INSERT INTO pn_type_activation
			SELECT pn_type_id
				,@FacIdDest
			FROM pn_type
			WHERE deleted = 'N'
				AND (
					retired IS NULL
					OR retired = 'N'
					) -- added by RYAN - 03302021
				AND brand_id IS NULL
				AND (
					(
						fac_id = - 1
						AND isnull(reg_id, - 1) = - 1
						AND state_code IS NULL
						)
					OR (
						fac_id = @FacIdDest
						AND isnull(reg_id, - 1) = - 1
						AND state_code IS NULL
						)
					OR state_code IN (
						SELECT prov
						FROM facility
						WHERE fac_id = @FacIdDest
						)
					OR (
						reg_id IN (
							SELECT regional_id
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						AND state_code IN (
							SELECT prov
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						)
					OR (
						reg_id IN (
							SELECT regional_id
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						AND state_code IS NULL
						)
					)
				AND NOT EXISTS (
					SELECT 1
					FROM pn_type_activation cca
					WHERE fac_id = @FacIdDest
						AND cca.pn_type_id = pn_type.pn_type_id
					)

			INSERT INTO cr_std_alert_activation
			SELECT std_alert_id
				,@FacIdDest
			FROM cr_std_alert
			WHERE deleted = 'N'
				AND std_alert_type_id = 1
				AND (
					(
						fac_id = - 1
						AND isnull(reg_id, - 1) = - 1
						AND state_code IS NULL
						)
					OR (
						fac_id = @FacIdDest
						AND isnull(reg_id, - 1) = - 1
						AND state_code IS NULL
						)
					OR state_code IN (
						SELECT prov
						FROM facility
						WHERE fac_id = @FacIdDest
						)
					OR (
						reg_id IN (
							SELECT regional_id
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						AND state_code IN (
							SELECT prov
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						)
					OR (
						reg_id IN (
							SELECT regional_id
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						AND state_code IS NULL
						)
					)
				AND NOT EXISTS (
					SELECT 1
					FROM cr_std_alert_activation cca
					WHERE fac_id = @FacIdDest
						AND cca.std_alert_id = cr_std_alert.std_alert_id
					)

			INSERT INTO cp_kardex_categories_activation
			SELECT category_id
				,@FacIdDest
			FROM cp_kardex_categories
			WHERE deleted = 'N'
				AND (
					(
						fac_id = - 1
						AND isnull(reg_id, - 1) = - 1
						AND state_code IS NULL
						)
					OR (
						fac_id = @FacIdDest
						AND isnull(reg_id, - 1) = - 1
						AND state_code IS NULL
						)
					OR state_code IN (
						SELECT prov
						FROM facility
						WHERE fac_id = @FacIdDest
						)
					OR (
						reg_id IN (
							SELECT regional_id
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						AND state_code IN (
							SELECT prov
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						)
					OR (
						reg_id IN (
							SELECT regional_id
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						AND state_code IS NULL
						)
					)
				AND NOT EXISTS (
					SELECT 1
					FROM cp_kardex_categories_activation cca
					WHERE fac_id = @FacIdDest
						AND cca.category_id = cp_kardex_categories.category_id
					)

			/* this script came from --https://confluence.pointclickcare.com/confluence/pages/viewpageattachments.action?pageId=101189190&metadataLink=true.  It was added on Oct 4, 2017 as per Christine Butcher 
In 3.7.14 we will have these setting visible to super users
Admin > setup > super user area > Facility Settings
*/
			/*
	INSERT INTO ar_facility_enabled_option_item (fac_id, option_item_id, created_by, created_date)
	SELECT f.fac_id, afc.option_item_id, @Creator,getDate()
	FROM ar_facility_configuration_group_option_item afc
	JOIN facility f ON f.deleted = 'N' and f.fac_id = @FacIdDest
	WHERE afc.option_item_id IN (1,2,3,4)
	and not exists (select 1 from ar_facility_enabled_option_item dst
				where dst.fac_id = f.fac_id and dst.option_item_id = afc.option_item_id)

	-- Payer Type council only for UK facility
	INSERT INTO ar_facility_enabled_option_item (fac_id, option_item_id, created_by, created_date)
	SELECT f.fac_id, 12, @Creator,getDate() 
	FROM facility f 
	WHERE f.deleted = 'N' AND f.country_id = 5172 and f.fac_id = @FacIdDest
	and not exists (select 1 from ar_facility_enabled_option_item dst
				where dst.fac_id = f.fac_id and dst.option_item_id = 12)


	-- Payer types and bill form which are not covered by last two insert statement will be only for US facility
	INSERT INTO ar_facility_enabled_option_item (fac_id, option_item_id, created_by, created_date)
	SELECT f.fac_id, afc.option_item_id, @Creator,getDate()
	FROM ar_facility_configuration_group_option_item afc
	JOIN facility f ON f.deleted = 'N' AND f.country_id = 100
	WHERE afc.option_item_id NOT IN (1,2,3,4,12) and f.fac_id = @FacIdDest		
		and not exists (select 1 from ar_facility_enabled_option_item dst
				where dst.fac_id = f.fac_id and dst.option_item_id = afc.option_item_id)
*/
			--=======================================================================================================================
			-- Smartsheet #123 - 01/18/2018 For CORE-9024
			--
			-- Written By:       Dmitry Strelbytsky
			--
			-- Script Type:      DML
			-- Target DB Type:   Client
			-- Target Database:  Both
			--
			-- Re-Runnable:      YES
			--
			-- Staging Recommendations/Warnings: None
			--
			-- Description of Script Function:
			--   Updates ar_facility_enabled_option_item for newly created facilities
			--
			-- Special Instruction: NA
			--
			--=======================================================================================================================
			BEGIN TRY
				BEGIN TRAN

				--  Payer Type private and other, bill form statements for every facility
				INSERT INTO ar_facility_enabled_option_item (
					fac_id
					,option_item_id
					,created_by
					,created_date
					)
				SELECT f.fac_id
					,afc.option_item_id
					,@Creator
					,GETDATE()
				FROM ar_facility_configuration_group_option_item afc WITH (NOLOCK)
				INNER JOIN facility f WITH (NOLOCK) ON f.deleted = 'N'
				WHERE afc.option_item_id IN (
						1
						,2
						,3
						,4
						)
					AND f.fac_id NOT IN (
						SELECT DISTINCT fac_id
						FROM ar_facility_enabled_option_item WITH (NOLOCK)
						WHERE option_item_id IN (
								1
								,2
								,3
								,4
								)
						)

				-- Payer Type council only for UK facilities
				INSERT INTO ar_facility_enabled_option_item (
					fac_id
					,option_item_id
					,created_by
					,created_date
					)
				SELECT DISTINCT f.fac_id
					,12
					,@Creator
					,GETDATE()
				FROM facility f WITH (NOLOCK)
				WHERE f.deleted = 'N'
					AND f.country_id = 5172
					AND f.fac_id NOT IN (
						SELECT DISTINCT fac_id
						FROM ar_facility_enabled_option_item WITH (NOLOCK)
						WHERE option_item_id = 12
						)

				-- Payer types and bill form which are not covered by last two insert statement will be only for US facilities
				-- in addition to the above CORE, SNF facilities will get Medicare, Medicaid, Managed Care, and UBs
				INSERT INTO ar_facility_enabled_option_item (
					fac_id
					,option_item_id
					,created_by
					,created_date
					)
				SELECT DISTINCT f.fac_id
					,afc.option_item_id
					,@Creator
					,GETDATE()
				FROM ar_facility_configuration_group_option_item afc WITH (NOLOCK)
				INNER JOIN facility f WITH (NOLOCK) ON f.deleted = 'N'
					AND f.country_id = 100
				WHERE f.health_type = 'SNF'
					AND afc.option_item_id NOT IN (
						1
						,2
						,3
						,4
						,12
						)
					AND f.fac_id NOT IN (
						SELECT DISTINCT fac_id
						FROM ar_facility_enabled_option_item WITH (NOLOCK)
						WHERE option_item_id NOT IN (
								1
								,2
								,3
								,4
								,12
								)
						)

				-- in addition to the above CORE, ALF facilities will get Medicaid and UBs		
				INSERT INTO ar_facility_enabled_option_item (
					fac_id
					,option_item_id
					,created_by
					,created_date
					)
				SELECT DISTINCT f.fac_id
					,afc.option_item_id
					,@Creator
					,GETDATE()
				FROM ar_facility_configuration_group_option_item afc WITH (NOLOCK)
				INNER JOIN facility f WITH (NOLOCK) ON f.deleted = 'N'
					AND f.country_id = 100
				WHERE f.health_type = 'ALF'
					AND afc.option_item_id IN (
						6
						,7
						,8
						)
					AND f.fac_id NOT IN (
						SELECT DISTINCT fac_id
						FROM ar_facility_enabled_option_item WITH (NOLOCK)
						WHERE option_item_id IN (
								6
								,7
								,8
								)
						)

				COMMIT TRAN
			END TRY

			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK TRAN

				DECLARE @err NVARCHAR(3000)

				SET @err = 'Error creating security functions for ' + @Creator + ': ' + ERROR_MESSAGE()

				RAISERROR (
						@err
						,16
						,1
						)
			END CATCH

			/*

Below script Added By: Jaspreet Singh
Case# 1139873
Date: 2018-03-02
Reason: To Create statement configuration row for all active facilities
*/
			-- Written By:           Ahmedur Rahman
			-- Modified By: 		 Byron Lee
			-- Reviewed By:			 
			--
			-- Script Type:          DML
			-- Target DB Type:       CLIENT
			-- Target ENVIRONMENT:   BOTH
			--
			--
			-- Re-Runnable:          YES
			--
			--
			-- Adding default values for EMC
			-- Create statement configuration row for all active facilities
			-- =================================================================================
			--step 01. declare default values
			DECLARE @ancillary_display_option VARCHAR(3) = 'D'
			DECLARE @transaction_display_option VARCHAR(3) = '0'
			DECLARE @display_unit_and_amount_flag BIT = 0
			DECLARE @display_aging_flag BIT = 0
			DECLARE @display_invoice_number_flag BIT = 0
			DECLARE @display_location_flag BIT = 0
			DECLARE @display_admit_date_flag BIT = 0
			DECLARE @display_discharge_date_flag BIT = 0
			DECLARE @display_resident_number_flag BIT = 0
			DECLARE @sort_option VARCHAR(1) = 'P'
			DECLARE @font_size TINYINT = 10
			DECLARE @page_break TINYINT = 0
			DECLARE @paper_size TINYINT = 0
			DECLARE @envelope_type VARCHAR(10) = 'single'
			DECLARE @prefix_facility_code_to_account_number_flag BIT = 0
			DECLARE @comment_from_adjustments BIT = 0
			DECLARE @comment_from_ancillary BIT = 0
			DECLARE @comment_from_cash BIT = 0
			DECLARE @enable_statement_link_flag BIT = 0
			DECLARE @statement_date_option TINYINT = 0
			DECLARE @emc_jira VARCHAR(10) = 'PCC-118981'
			DECLARE @facility_jira VARCHAR(10) = 'PCC-120521'
			--------------migration variables---------
			DECLARE @emc_standard_template VARCHAR(60) = 'Standard Default Statement Configuration Template'
			DECLARE @campus_standard_template VARCHAR(60) = 'Standard Campus Statement Configuration Template'
			-- values for created and revision fields
			DECLARE @created_date DATETIME = getdate()
			DECLARE @template_migration VARCHAR(20) = 'CORE-7394 migration'
			DECLARE @emc_template_migration VARCHAR(30) = 'CORE-7394 Enterprise Template'
			DECLARE @original_revision VARCHAR(30) = 'PCC-120521'
			--values for 'cheques_payable_to' column
			DECLARE @cheques_payable_to_facility_name TINYINT = 0
			DECLARE @cheques_payable_to_campus_name TINYINT = 1
			DECLARE @cheques_payable_to_custom_name TINYINT = 2

			------------------------------------
			-- step 02. create EMC row using defaults
			IF NOT EXISTS (
					SELECT 1
					FROM ar_statement_configuration
					WHERE fac_id = - 1
					)
			BEGIN
				INSERT INTO ar_statement_configuration (
					fac_id
					,cheques_payable_to
					,statement_header_image_id
					,statement_footer_image_id
					,ancillary_display_option
					,transaction_display_option
					,display_unit_and_amount_flag
					,display_aging_flag
					,display_invoice_number_flag
					,display_location_flag
					,display_admit_date_flag
					,display_discharge_date_flag
					,display_resident_number_flag
					,payment_instructions
					,sort_option
					,font_size
					,page_break
					,paper_size
					,envelope_type
					,prefix_facility_code_to_account_number_flag
					,comment_from_adjustments
					,comment_from_ancillary
					,comment_from_cash
					,enable_statement_link_flag
					,enabled_date
					,enabled_by
					,created_date
					,created_by
					,revised_date
					,revised_by
					,statement_message
					,statement_date_option
					)
				VALUES (
					- 1 -- fac_id - int
					,NULL -- cheques_payable_to - varchar(200)
					,NULL -- statement_header_image_id - int
					,NULL -- statement_footer_image_id - int
					,@ancillary_display_option -- ancillary_display_option - varchar(3)
					,@transaction_display_option -- transaction_display_option - varchar(3)
					,@display_unit_and_amount_flag -- display_unit_and_amount_flag - bit
					,@display_aging_flag -- display_aging_flag - bit
					,@display_invoice_number_flag -- display_invoice_number_flag - bit
					,@display_location_flag -- display_location_flag - bit
					,@display_admit_date_flag -- display_admit_date_flag - bit
					,@display_discharge_date_flag -- display_discharge_date_flag - bit
					,@display_resident_number_flag -- display_resident_number_flag - bit
					,NULL -- payment_instructions - varchar(1000)
					,@sort_option -- sort_option - varchar(1)
					,@font_size -- font_size - tinyint
					,@page_break -- page_break - tinyint
					,@paper_size -- paper_size - tinyint
					,@envelope_type -- envelope_type - varchar(10)
					,@prefix_facility_code_to_account_number_flag -- prefix_facility_code_to_account_number_flag - bit
					,@comment_from_adjustments -- comment_from_adjustments - bit
					,@comment_from_ancillary -- comment_from_ancillary - bit
					,@comment_from_cash -- comment_from_cash - bit
					,@enable_statement_link_flag -- enable_statement_link_flag - bit
					,NULL -- enabled_date - datetime
					,NULL -- enabled_by - varchar(60)
					,getdate() -- created_date - datetime
					,@emc_jira -- created_by - varchar(60)
					,getdate() -- revised_date - datetime
					,@emc_jira -- revised_by - varchar(60)
					,NULL -- statement_message varchar(650)
					,@statement_date_option -- statement_date_option tinyint 
					)
			END

			--step 03. create row for all live facilities in temp table
			INSERT INTO ar_statement_configuration (
				fac_id
				,cheques_payable_to
				,statement_header_image_id
				,ancillary_display_option
				,transaction_display_option
				,display_unit_and_amount_flag
				,display_aging_flag
				,display_invoice_number_flag
				,display_location_flag
				,display_admit_date_flag
				,display_discharge_date_flag
				,display_resident_number_flag
				,sort_option
				,font_size
				,page_break
				,paper_size
				,envelope_type
				,prefix_facility_code_to_account_number_flag
				,comment_from_adjustments
				,comment_from_ancillary
				,comment_from_cash
				,enable_statement_link_flag
				,created_date
				,created_by
				,revised_date
				,revised_by
				,statement_date_option
				)
			SELECT f.fac_id
				,CASE 
					WHEN c.cheques_payable_to IS NULL
						OR c.cheques_payable_to = ''
						THEN f.NAME
					ELSE c.cheques_payable_to
					END AS cheques_payable_to
				,c.statement_header_image_id
				,@ancillary_display_option
				,@transaction_display_option
				,@display_unit_and_amount_flag
				,@display_aging_flag
				,@display_invoice_number_flag
				,@display_location_flag
				,@display_admit_date_flag
				,@display_discharge_date_flag
				,@display_resident_number_flag
				,@sort_option
				,@font_size
				,@page_break
				,@paper_size
				,@envelope_type
				,@prefix_facility_code_to_account_number_flag
				,@comment_from_adjustments
				,@comment_from_ancillary
				,@comment_from_cash
				,CASE 
					WHEN (f.facility_type = 'USAR')
						OR (
							f.facility_type = 'CDN'
							AND c.transition_to_enhanced_billing_date <> NULL
							)
						THEN 1
					ELSE 0
					END AS enable_statement_link_flag
				,getdate()
				,@facility_jira
				,getdate()
				,@facility_jira
				,@statement_date_option
			FROM facility f
			INNER JOIN ar_configuration c ON f.fac_id = c.fac_id
			WHERE f.deleted = 'N'
				AND (
					f.is_live <> 'N'
					OR f.is_live IS NULL
					) -- only live facilities
				AND f.fac_id > 0
				AND NOT EXISTS (
					SELECT fac_id
					FROM ar_statement_configuration
					WHERE fac_id = f.fac_id
					)

			--Following part of the script will only be run for post 3.7.15 releases. The script makes sure that a template table exists before running the following.
			-- If a ar_statement_configuration_template table exists, that means data has already been migrated for other columns during the update to 3.7.15
			-- After a row has been created for the newly added facility. The facility is not yet part of any campus (assuming this script is 
			-- being run right after adding the facility in the db), so an entry needs to be added into the [ar_statement_configuration_template_enterprise_facility_mapping] table -- to point this facility to the default template	
			IF (
					EXISTS (
						SELECT 1
						FROM INFORMATION_SCHEMA.TABLES
						WHERE TABLE_SCHEMA = 'dbo'
							AND TABLE_NAME = 'ar_statement_configuration_template'
						)
					)
			BEGIN
				-- If it's a single fac org and the newly added facility is the first & only facility, then migrate data for single facilities
				IF (
						SELECT count(fac_id)
						FROM ar_statement_configuration
						WHERE fac_id > 0
						) = 1
				BEGIN
					IF NOT EXISTS (
							SELECT 1
							FROM ar_statement_configuration_template
							)
					BEGIN
						INSERT INTO ar_statement_configuration_template (
							default_template
							,description
							,fac_id
							,cheques_payable_to_option
							,cheques_payable_to
							,use_custom_header_logo
							,statement_header_image_id
							,statement_date_option
							,ancillary_display_option
							,transaction_display_option
							,comment_from_adjustments
							,comment_from_ancillary
							,comment_from_cash
							,display_unit_and_amount_flag
							,display_aging_flag
							,display_invoice_number_flag
							,display_location_flag
							,display_admit_date_flag
							,display_discharge_date_flag
							,display_resident_number_flag
							,payment_instructions
							,sort_option
							,font_size
							,page_break
							,paper_size
							,envelope_type
							,prefix_facility_code_to_account_number_flag
							,statement_message
							,created_date
							,created_by
							,revision_date
							,revision_by
							,deleted
							)
						SELECT 1
							,f.NAME + ' Template'
							,sc.fac_id
							,CASE 
								WHEN sc.cheques_payable_to = f.NAME
									THEN @cheques_payable_to_facility_name
								ELSE @cheques_payable_to_custom_name
								END
							,sc.cheques_payable_to
							,CASE 
								WHEN sc.statement_header_image_id IS NOT NULL
									THEN 1
								ELSE 0
								END
							,sc.statement_header_image_id
							,sc.statement_date_option
							,sc.ancillary_display_option
							,sc.transaction_display_option
							,sc.comment_from_adjustments
							,sc.comment_from_ancillary
							,sc.comment_from_cash
							,sc.display_unit_and_amount_flag
							,sc.display_aging_flag
							,sc.display_invoice_number_flag
							,sc.display_location_flag
							,sc.display_admit_date_flag
							,sc.display_discharge_date_flag
							,sc.display_resident_number_flag
							,sc.payment_instructions
							,sc.sort_option
							,sc.font_size
							,sc.page_break
							,sc.paper_size
							,sc.envelope_type
							,sc.prefix_facility_code_to_account_number_flag
							,sc.statement_message
							,@created_date
							,@template_migration
							,@created_date
							,@template_migration
							,'N'
						FROM ar_statement_configuration sc
						LEFT JOIN ar_statement_configuration_template sct ON sct.fac_id = sc.fac_id --????????????????????
						INNER JOIN facility f ON f.fac_id = sc.fac_id
						WHERE (
								sc.fac_id > 0
								AND sc.fac_id < 9000
								)
					END
				END
			END

			/*
Below code added by: Jaspreet Singh
date: 2018-04-04
reason: Ann email subject:- FW: New identifier
*/
			-- Filename: CORE-13614 - DML-create new MBI resident identifier.sql
			-- CORE-13614: DML-create new MBI resident identifier and update a/r configuration
			-- Script Order:    1 of 1
			-- 
			-- Written By:      Megha Kumar
			-- Reviewed By:    
			-- 
			-- Script Type:     DML
			-- Target DB Type:  US
			-- Target Database: All
			-- 
			-- Re-Runable:      Yes
			-- 
			-- Description of Script Function:
			-- Create new MBI resident identifier and update a/r configuration
			-- 
			-- Special Instruction: None
			-- *****************************************************************************
			DECLARE @idTypeId INT

			IF NOT EXISTS (
					SELECT 1
					FROM id_type
					WHERE description = 'Medicare Beneficiary ID'
						AND fac_id = - 1
						AND deleted = 'N'
					)
			BEGIN
				DELETE
				FROM pcc_global_primary_key
				WHERE table_name = 'id_type'
					AND key_column_name = 'id_type_id';

				SELECT @idTypeId = coalesce(max(id_type_id), 0)
				FROM dbo.id_type WITH (NOLOCK)

				SET @idTypeId = @idTypeId + 1

				--EXEC get_next_primary_key 'id_type'
				--	,'id_type_id'
				--	,@idTypeId OUTPUT
				--	,1;
				INSERT INTO id_type (
					id_type_id
					,fac_id
					,deleted
					,created_by
					,created_date
					,revision_by
					,revision_date
					,description
					,format
					,show_on_a_r
					,show_on_invoice
					,sequence
					,show_on_new
					,required_on_new
					,deleted_by
					,deleted_date
					,reg_id
					,unique_id
					,state_code
					)
				VALUES (
					@idTypeId
					,- 1
					,'N'
					,'CORE-13614'
					,GETDATE()
					,NULL
					,NULL
					,'Medicare Beneficiary ID'
					,'XXXXXXXXXXX'
					,'Y'
					,'N'
					,1
					,'Y'
					,'N'
					,NULL
					,NULL
					,NULL
					,'Y'
					,NULL
					);

				INSERT INTO id_type_activation
				SELECT @idTypeId
					,fac_id
				FROM facility
				WHERE health_type = 'SNF'
					AND facility_type = 'USAR';

				UPDATE ar_configuration
				SET medicare_beneficiary_id = ISNULL(@idTypeId, medicare_beneficiary_id)
					,revision_by = 'CORE-13614'
					,revision_date = GETDATE()
				WHERE fac_id IN (
						SELECT fac_id
						FROM facility
						WHERE health_type = 'SNF'
							AND facility_type = 'USAR'
						);
			END
					--4/4/2018 - added the following for new facility creation
			ELSE
			BEGIN
				UPDATE ar_configuration
				SET medicare_beneficiary_id = (
						SELECT TOP 1 id_type_id /* Added By: Jaspreet Singh, Date: 2019-03-06, Reason: Because we ave multiple rows for given values in table id_type */
						FROM id_type
						WHERE description = 'Medicare Beneficiary ID'
							AND fac_id = - 1
							AND deleted = 'N'
						)
					,revision_by = @Creator
					,revision_date = GETDATE()
				WHERE fac_id IN (
						SELECT fac_id
						FROM facility
						WHERE health_type = 'SNF'
							AND facility_type = 'USAR'
						)
					AND medicare_beneficiary_id IS NULL;
			END

			/*
Below code added by: Jaspreet Singh
date: 2019-06-17
reason: Ann email subject:- RE: Integration Pre-Configurations 
Ability Configuration

---- SELECT * FROM message_route where message_profile_id = 4
*/
			IF NOT EXISTS (
					SELECT 1
					FROM lib_message_profile
					WHERE vendor_code = 'ABILITY_CLAIMS'
					)
			BEGIN
				DECLARE @MsgGrpEmail VARCHAR(400)
					,@TSImpEmail VARCHAR(400)
					,@SaaSOpsIntEmail VARCHAR(400)
					,@protocol_id INT
					,@enabled BIT = 1 -- 0 Not Enabled, 1 Enabled

				SELECT @facId = @FacIdDest
					,@created_by = SYSTEM_USER
					,@created_date = GETDATE()
					,@protocol_id = 25
					,@message_profile_id = NULL

				IF (
						(
							SELECT count(1)
							FROM facility
							WHERE fac_id NOT IN (9001)
								AND deleted = 'N'
								AND inactive IS NULL
								AND inactive_date IS NULL
							) = 1
						)
				BEGIN
					SET @multiFacility = 0
				END

				SELECT @MsgGrpEmail = 'MessagingGroupEmail@pointclickcare.com' ---- 'SaaSOpsApplicationAdmins@pointclickcare.com'
					,@TSImpEmail = 'PDintegration@pointclickcare.com'
					,@SaaSOpsIntEmail = 'SaaSOpsIntegrationOperations@pointclickcare.com'

				IF EXISTS (
						SELECT *
						FROM dbo.pcc_global_primary_key
						WHERE table_name = 'lib_message_profile'
						)
				BEGIN
					IF (
							SELECT next_key
							FROM pcc_global_primary_key
							WHERE table_name = 'lib_message_profile'
							) <= (
							SELECT Max(message_profile_id)
							FROM lib_message_profile
							)
					BEGIN
						DELETE
						FROM pcc_global_primary_key
						WHERE table_name = 'lib_message_profile'
					END
				END

				SET @message_profile_id = NULL

				DELETE
				FROM pcc_global_primary_key
				WHERE table_name = 'lib_message_profile'
					AND key_column_name = 'message_profile_id';

				SELECT @message_profile_id = coalesce(max(message_profile_id), 0)
				FROM dbo.lib_message_profile WITH (NOLOCK)

				SET @message_profile_id = @message_profile_id + 1

				----EXEC [dbo].Get_next_primary_key 'lib_message_profile'
				----	,'message_profile_id'
				----	,@message_profile_id OUTPUT
				----	,1
				IF (@message_profile_id > 0)
				BEGIN
					SET @step = 9

					INSERT INTO lib_message_profile (
						vendor_code
						,include_outpatient
						,description
						,created_by
						,message_mode
						,is_enabled
						,message_communication_id
						,deleted
						,endpoint_url
						,is_integrated_pharmacy
						,remote_login
						,include_discharged
						,remote_password
						,created_date
						,message_profile_id
						,message_protocol_id
						)
					VALUES (
						'ABILITY_CLAIMS'
						,'N'
						,'ABILITY RCM'
						,@created_by
						,'P'
						,'N' -- Added as per Eddie email
						,'1'
						,'N'
						,'https://api.accessrcm.abilitynetwork.com/v1'
						,'N'
						,'KFSCWK133ZE1IX44W1BO0Q4Q5'
						,'FALSE'
						,'FhLcAc10OGmmK6MaWwhkixVUVpLBtkgJFtpC4DFiFZI='
						,@created_date
						,@message_profile_id
						,@protocol_id
						)
				END

				IF (@multiFacility = 0)
				BEGIN
					SET @step = 10

					INSERT INTO message_profile (
						fac_id
						,include_outpatient
						,created_by
						,message_mode
						,is_enabled
						,message_communication_id
						,endpoint_url
						,is_integrated_pharmacy
						,remote_login
						,include_discharged
						,remote_password
						,created_date
						,message_profile_id
						,message_protocol_id
						)
					VALUES (
						'1'
						,'N'
						,@created_by
						,'P'
						,'N'
						,'1'
						,'https://api.accessrcm.abilitynetwork.com/v1'
						,'N'
						,'KFSCWK133ZE1IX44W1BO0Q4Q5'
						,'FALSE'
						,'FhLcAc10OGmmK6MaWwhkixVUVpLBtkgJFtpC4DFiFZI='
						,@created_date
						,@message_profile_id
						,@protocol_id
						)
				END

				SET @step = 11

				INSERT INTO message_profile_param (
					param_value_type
					,fac_id
					,param_value
					,message_profile_id
					,param_id
					)
				SELECT '3' AS PARAM_VALUE_TYPE
					,CASE 
						WHEN @multiFacility = 0
							THEN @facId
						ELSE - 1
						END AS FAC_ID
					,'1lmySwJn&hgh@s7K9&7c4XO5X' AS PARAM_VALUE
					,@message_profile_id AS MESSAGE_PROFILE_ID
					,'49' AS PARAM_ID
				
				UNION ALL
				
				SELECT '3' AS PARAM_VALUE_TYPE
					,CASE 
						WHEN @multiFacility = 0
							THEN @facId
						ELSE - 1
						END AS FAC_ID
					,'https://api.accessrcm.abilitynetwork.com/v1' AS PARAM_VALUE
					,@message_profile_id AS MESSAGE_PROFILE_ID
					,'47' AS PARAM_ID
				
				UNION ALL
				
				SELECT '3' AS PARAM_VALUE_TYPE
					,CASE 
						WHEN @multiFacility = 0
							THEN @facId
						ELSE - 1
						END AS FAC_ID
					,'KFSCWK133ZE1IX44W1BO0Q4Q5' AS PARAM_VALUE
					,@message_profile_id AS MESSAGE_PROFILE_ID
					,'48' AS PARAM_ID
				
				UNION ALL
				
				SELECT '3' AS PARAM_VALUE_TYPE
					,CASE 
						WHEN @multiFacility = 0
							THEN @facId
						ELSE - 1
						END AS FAC_ID
					,'eeTzAKg8' AS PARAM_VALUE
					,@message_profile_id AS MESSAGE_PROFILE_ID
					,'6' AS PARAM_ID
				
				UNION ALL
				
				SELECT '3' AS PARAM_VALUE_TYPE
					,CASE 
						WHEN @multiFacility = 0
							THEN @facId
						ELSE - 1
						END AS FAC_ID
					,'Uqp2MxX3' AS PARAM_VALUE
					,@message_profile_id AS MESSAGE_PROFILE_ID
					,'5' AS PARAM_ID
				
				UNION ALL
				
				SELECT '3' AS PARAM_VALUE_TYPE
					,CASE 
						WHEN @multiFacility = 0
							THEN @facId
						ELSE - 1
						END AS FAC_ID
					,'API' AS PARAM_VALUE
					,@message_profile_id AS MESSAGE_PROFILE_ID
					,'66' AS PARAM_ID
				
				UNION ALL
				
				SELECT '3' AS PARAM_VALUE_TYPE
					,CASE 
						WHEN @multiFacility = 0
							THEN @facId
						ELSE - 1
						END AS FAC_ID
					,'298' AS PARAM_VALUE
					,@message_profile_id AS MESSAGE_PROFILE_ID
					,'50' AS PARAM_ID

				SET @Step = 12

				INSERT INTO [dbo].[vaf_vendor_alert_facility_config] (
					[fac_id]
					,[protocol_id]
					,[override_emc]
					,[message_profile_id]
					)
				VALUES (
					CASE 
						WHEN @multiFacility = 0
							THEN @facId
						ELSE - 1
						END
					,@protocol_id
					,0
					,@message_profile_id
					)

				SET @step = 13

				INSERT INTO [dbo].[vaf_vendor_alert_config] (
					alert_id
					,fac_id
					,protocol_id
					,enabled
					,email
					,message_profile_id
					)
				SELECT alert_id
					,CASE 
						WHEN @multiFacility = 0
							THEN @facId
						ELSE - 1
						END AS fac_id
					,@protocol_id AS protocol_id
					,1 AS enabled
					,NULL AS email
					,@message_profile_id
				FROM vaf_vendor_alert
				WHERE protocol_id = 25
					AND type = 'F'

				IF NOT EXISTS (
						SELECT 1
						FROM vaf_vendor_alert_config
						WHERE [email] = @MsgGrpEmail
							AND protocol_id = @protocol_id
						)
				BEGIN
					SET @step = 14

					INSERT INTO vaf_vendor_alert_config (
						alert_id
						,fac_id
						,protocol_id
						,enabled
						,email
						,message_profile_id
						)
					SELECT 447 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@MsgGrpEmail AS email
						,@message_profile_id AS message_profile_id
					
					UNION ALL
					
					SELECT 440 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@MsgGrpEmail AS email
						,@message_profile_id AS message_profile_id
					
					UNION ALL
					
					SELECT 446 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@MsgGrpEmail AS email
						,@message_profile_id AS message_profile_id
					
					UNION ALL
					
					SELECT 451 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@MsgGrpEmail AS email
						,@message_profile_id AS message_profile_id
					
					UNION ALL
					
					SELECT 449 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@MsgGrpEmail AS email
						,@message_profile_id AS message_profile_id
					
					UNION ALL
					
					SELECT 437 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@MsgGrpEmail AS email
						,@message_profile_id AS message_profile_id
					
					UNION ALL
					
					SELECT 438 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@MsgGrpEmail AS email
						,@message_profile_id AS message_profile_id
					
					UNION ALL
					
					SELECT 436 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@MsgGrpEmail AS email
						,@message_profile_id AS message_profile_id
					
					UNION ALL
					
					SELECT 452 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@MsgGrpEmail AS email
						,@message_profile_id AS message_profile_id
					
					UNION ALL
					
					SELECT 443 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@MsgGrpEmail AS email
						,@message_profile_id AS message_profile_id
				END

				IF NOT EXISTS (
						SELECT 1
						FROM vaf_vendor_alert_config
						WHERE [email] = @SaaSOpsIntEmail
							AND protocol_id = @protocol_id
						)
				BEGIN
					SET @step = 15

					INSERT INTO vaf_vendor_alert_config (
						alert_id
						,fac_id
						,protocol_id
						,enabled
						,email
						,message_profile_id
						)
					SELECT 462 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@SaaSOpsIntEmail AS email
						,@message_profile_id AS message_profile_id
					
					UNION ALL
					
					SELECT 452 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@SaaSOpsIntEmail AS email
						,@message_profile_id AS message_profile_id
					
					UNION ALL
					
					SELECT 441 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@SaaSOpsIntEmail AS email
						,@message_profile_id AS message_profile_id
					
					UNION ALL
					
					SELECT 459 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@SaaSOpsIntEmail AS email
						,@message_profile_id AS message_profile_id
					
					UNION ALL
					
					SELECT 460 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@SaaSOpsIntEmail AS email
						,@message_profile_id AS message_profile_id
				END

				IF NOT EXISTS (
						SELECT 1
						FROM vaf_vendor_alert_config
						WHERE [email] = @TSImpEmail
							AND protocol_id = @protocol_id
						)
				BEGIN
					SET @step = 17

					INSERT INTO vaf_vendor_alert_config (
						alert_id
						,fac_id
						,protocol_id
						,enabled
						,email
						,message_profile_id
						)
					SELECT 461 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@TSImpEmail AS email
						,@message_profile_id AS message_profile_id
					
					UNION ALL
					
					SELECT 454 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@TSImpEmail AS email
						,@message_profile_id AS message_profile_id
					
					UNION ALL
					
					SELECT 505 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@TSImpEmail AS email
						,@message_profile_id AS message_profile_id
				END

				---------------------------------------------------------------------------------------
				---------------------------------------------------------------------------------------
				----------------URL Configuration Setup For Ability------------------------
				---------------------------------------------------------------------------------------
				---------------------------------------------------------------------------------------
				DECLARE @vUrl VARCHAR(500)
					,@vName VARCHAR(30)
					,@vUrl_config_id INT

				SELECT @vName = 'Ability RCM'
					,@vUrl = 'Ability'

				IF NOT EXISTS (
						SELECT 1
						FROM dbo.pcc_ext_vendor_url_config
						WHERE NAME = @vName
							AND url = @vUrl
						)
				BEGIN
					SET @step = 18

					INSERT INTO pcc_ext_vendor_url_config (
						[type]
						,NAME
						,url
						,protocol
						,port
						,emar_poc_flag
						,activated
						,icon_type_flag
						,icon_uri
						,scope
						,lob
						,state_code
						,entry_date
						,update_date
						,access_ltd_flag
						)
					VALUES (
						'PASS_THRU_AUTH'
						,@vName
						,@vUrl
						,'HTTP'
						,80
						,'N'
						,'N'
						,'D'
						,'/images/sidebar/quicklink.png'
						,'C'
						,- 1
						,NULL
						,getdate()
						,getdate()
						,'N'
						)

					SET @vUrl_config_id = SCOPE_IDENTITY()
					SET @step = 19

					INSERT INTO pcc_ext_vendor_url_param (
						url_config_id
						,param_type
						,param_name
						,param_value
						)
					SELECT @vUrl_config_id AS url_config_id
						,'C' AS param_type
						,'facId' AS param_name
						,'-1' AS param_value
					
					UNION
					
					SELECT @vUrl_config_id AS url_config_id
						,'C' AS param_type
						,'assertBackgroundSaml' AS param_name
						,'false' AS param_value
					
					UNION
					
					SELECT @vUrl_config_id AS url_config_id
						,'C' AS param_type
						,'hideOnExternalLink' AS param_name
						,'false' AS param_value
					
					UNION
					
					SELECT @vUrl_config_id AS url_config_id
						,'C' AS param_type
						,'showOnAdminHeader' AS param_name
						,'false' AS param_value
					
					UNION
					
					SELECT @vUrl_config_id AS url_config_id
						,'C' AS param_type
						,'showOnClaimListing' AS param_name
						,'false' AS param_value
					
					UNION
					
					SELECT @vUrl_config_id AS url_config_id
						,'C' AS param_type
						,'showOnClinicalHeader' AS param_name
						,'false' AS param_value
				END

				IF @DebugMe = 'Y'
					PRINT 'Abillity_Claims script at step:' + convert(VARCHAR(3), @step) + '    ' + convert(VARCHAR(26), getdate(), 109)
			END

			--end 6/17/2019 - added the following for new facility creation of Integration Pre-Configuration
			--------------------------------------------------------------------------------------------------------------------
			-- added by RYAN - 04/03/2020
			-- to copy config items only if the org is from the OTBMASTER template - as per Xander Croner
			DECLARE @otb VARCHAR(1)
			DECLARE @sql_cmd_otb VARCHAR(max)

			SET @otb = CASE 
					WHEN EXISTS (
							SELECT 1
							FROM dbo.facility_audit
							WHERE fac_id = 1
								AND NAME = 'OTB TEMPLATE-ALF'
								AND deleted = 'N'
							)
						THEN 'Y'
					ELSE 'N'
					END

			--select @otb
			IF @healthtype = 'ALF'
			BEGIN
				IF @otb = 'Y'
				BEGIN
					SET @sql_cmd_otb = '
						DELETE FROM configuration_parameter where fac_id in (' + convert(VARCHAR(10), @FacIdDest) + ')

						INSERT INTO configuration_parameter (fac_id,[name],value)
						SELECT ' + convert(VARCHAR(10), @FacIdDest) + ' ,[name],value 
						FROM [' + @template_server + '].' + 'us_template_pccsingle_otbmaster.dbo.configuration_parameter
						WHERE fac_id = 1'

					EXEC (@sql_cmd_otb)
				END
			END

			--------------------------------------------------------------------------------------------------------------------
			/****
		---- added by Jaspreet - 01/06/2022
		---- Comment: Email subject RE: [PagerDuty ALERT] You have 1 TRIGGERED Incident (5c236)		
		---- added by RYAN - 04/14/2020
			---- PDP 4.1.3 - part of CORE-64977
			DECLARE @recurring_charges_by_day_start_date VARCHAR(1)
			DECLARE @sql_cmd_recurring_charges_by_day_start_date VARCHAR(max)

			SET @recurring_charges_by_day_start_date = CASE 
					WHEN EXISTS (
							SELECT 1
							FROM sys.columns
							WHERE Name = N'recurring_charges_by_day_start_date'
								AND Object_ID = Object_ID(N'ar_configuration')
							)
						THEN 'Y'
					ELSE 'N'
					END

			--select @recurring_charges_by_day_start_date
			IF @recurring_charges_by_day_start_date = 'Y'
			BEGIN
				BEGIN
					ALTER TABLE ar_configuration disable TRIGGER [tp_ar_configuration_upd]
				END

				BEGIN
					SET @sql_cmd_recurring_charges_by_day_start_date = '
					update ar_configuration
					set recurring_charges_by_day_start_date = ar_start_date where fac_id = ' + convert(VARCHAR(10), @FacIdDest) + ''

					EXEC (@sql_cmd_recurring_charges_by_day_start_date)
				END

				BEGIN
					ALTER TABLE ar_configuration enable TRIGGER [tp_ar_configuration_upd]
				END
			END
****/
			--------------------------------------------------
			-- added by RYAN - 12/03/2020
			-- email from Product -- IPC & Facility Acquisition Process -- Tuesday, November 24, 2020 10:06 AM
			-- there are two parts to this update - this is the second part for adding a row for the new fac
			INSERT INTO branded_library_feature_configuration (
				fac_id
				,brand_id
				,name
				,value
				,enabled_by
				,enabled_date
				,disabled_by
				,disabled_date
				,created_by
				,created_date
				,revision_by
				,revision_date
				,sequence
				)
			SELECT @FacIdDest
				,lib.brand_id
				,'enable_cp_partner_feature'
				,'N'
				,@Creator
				,GETDATE()
				,NULL
				,NULL
				,@Creator
				,GETDATE()
				,@Creator
				,GETDATE()
				,con.sequence
			FROM branded_library_configuration lib WITH (NOLOCK)
			JOIN branded_library_tier_configuration con WITH (NOLOCK) ON lib.brand_id = con.brand_id
			WHERE NOT EXISTS (
					SELECT name
					FROM branded_library_feature_configuration WITH (NOLOCK)
					WHERE name = 'enable_cp_partner_feature'
						AND fac_id = @FacIdDest
					)
				AND lib.brand_name = 'PCC Infection Control solution'
				AND lib.deleted = 'N'

			INSERT INTO branded_library_feature_option_conf (
				brand_id
				,fac_id
				,sequence
				,status_id
				,readonly
				)
			SELECT lib.brand_id
				,@FacIdDest
				,con.sequence
				,4
				,1
			FROM branded_library_configuration lib WITH (NOLOCK)
			JOIN branded_library_tier_configuration con WITH (NOLOCK) ON lib.brand_id = con.brand_id
			JOIN branded_library_feature_configuration f WITH (NOLOCK) ON con.brand_id = f.brand_id
			WHERE NOT EXISTS (
					SELECT fac_id
					FROM branded_library_feature_option_conf WITH (NOLOCK)
					WHERE brand_id IN (
							SELECT brand_id
							FROM branded_library_configuration WITH (NOLOCK)
							WHERE brand_name = 'PCC Infection Control solution'
								AND deleted = 'N'
							)
						AND fac_id = @FacIdDest
					)
				AND f.fac_id = @FacIdDest

			-------------------------------------------------- 
			-- added by RYAN - 12092020
			-- email from Ann - 12/8/2020 2:54 PM -- RE: Enabling logging for new facilities onboarded
			-- **************************************************************
			-- This script is to be executed on the CLIENT DB
			-- to enable auditing for every facility in the org by default
			-- **************************************************************
			DECLARE @auditEnabledFACs TABLE (fac_id INT)

			INSERT INTO @auditEnabledFACs
			SELECT fac_id
			FROM facility

			DECLARE @selectedFacId INT

			SET @selectedFacId = (
					SELECT TOP 1 fac_id
					FROM @auditEnabledFACs
					)

			DECLARE @enabledaudit INT = 1 -- 1=enable
			DECLARE @byUserName VARCHAR(60) = @Creator
			DECLARE @configParamValue CHAR(1) = 'Y'
			DECLARE @cache_time DATETIME

			WHILE @selectedFacId IS NOT NULL
			BEGIN
				MERGE configuration_parameter D
				USING (
					SELECT @selectedFacId AS fac_id
						,'enable_audit' AS name
						,@configParamValue AS value
					) AS S
					ON (
							D.fac_id = S.fac_id
							AND D.name = S.name
							)
				WHEN MATCHED
					THEN
						UPDATE
						SET D.value = S.value
				WHEN NOT MATCHED BY TARGET
					THEN
						INSERT (
							fac_id
							,name
							,value
							)
						VALUES (
							S.fac_id
							,S.name
							,S.value
							);

				EXEC pcc_update_cache_time @selectedFacId
					,'configParams'
					,@cache_time

				EXEC pcc_update_cache_time - 1
					,'MASTER'
					,@cache_time

				DELETE
				FROM @auditEnabledFACs
				WHERE fac_id = @selectedFacId

				SET @selectedFacId = (
						SELECT TOP 1 fac_id
						FROM @auditEnabledFACs
						)
			END

			-------------------------------------------------- 
			-- updated by RYAN, as requested by Kelly Cherchio -- 03/01/2021
			--IF EXISTS (
			--		SELECT 1
			--		FROM facility_audit
			--		WHERE fac_id = 1
			--			AND name = 'ALF Template Database'
			--		)
			--	AND @healthtype = 'ALF'
			--BEGIN
			--	INSERT INTO evt_std_event_type_active_facility (
			--		fac_id
			--		,event_type_id
			--		,active
			--		,created_by
			--		,created_date
			--		,revision_by
			--		,revision_date
			--		)
			--	SELECT @FacIdDest
			--		,evtstd.event_type_id
			--		,1
			--		,@Creator
			--		,getdate()
			--		,@Creator
			--		,getdate()
			--	FROM evt_std_event_type evtstd WITH (NOLOCK) 
			--	LEFT JOIN evt_std_event_type_active_facility evtfac WITH (NOLOCK)  ON evtstd.event_type_id = evtfac.event_type_id
			--		WHERE NOT EXISTS (
			--			SELECT @FacIdDest
			--			FROM evt_std_event_type_active_facility
			--			)
			--		AND evtstd.deleted = 0
			--		AND evtstd.retired = 0
			--		AND evtstd.fac_id = -1
			--		AND evtstd.reg_id IS NULL
			--		AND evtstd.state_code IS NULL
			--		AND evtfac.fac_id = @FacIdDest
			--END
			------ Added By: Jaspreet Singh
			------ Date: 2021-05-21
			------ Reason: Jira OA-51
			IF EXISTS (
					SELECT 1
					FROM dbo.[lib_message_profile]
					WHERE vendor_code = 'uap'
					)
			BEGIN
				DECLARE @msgProfileId INT = 0

				SELECT @msgProfileId = message_profile_id
				FROM dbo.[lib_message_profile]
				WHERE vendor_code = 'uap'

				INSERT INTO dbo.message_profile (
					endpoint_url
					,ext_fac_id
					,fac_id
					,include_discharged
					,include_outpatient
					,is_enabled
					,is_integrated_pharmacy
					,message_communication_id
					,message_mode
					,message_profile_id
					,message_protocol_id
					,notification_email
					,inbound_security
					,receiving_application
					,receiving_facility
					,remote_login
					,remote_password
					,security
					,sending_application
					,patient_order_request_time
					,send_email_response
					,response_email_address
					,batch_eligibility
					,realtime_eligibility
					,created_by
					,created_date
					,revision_by
					,revision_date
					,reg_id
					)
				VALUES (
					'test'
					,NULL
					,@FacIdDest
					,NULL
					,NULL
					,'N'
					,'Y'
					,1
					,'P'
					,@msgProfileId
					,13
					,NULL
					,NULL
					,'xxxxxxxx'
					,NULL
					,NULL
					,NULL
					,NULL
					,'xxxxxxxx'
					,NULL
					,'N'
					,''
					,'N'
					,'N'
					,@Creator
					,getdate()
					,@Creator
					,getdate()
					,NULL
					)
			END
		END

		COMMIT TRANSACTION

		/*
Below code added by: Jaspreet Singh
date: 2019-06-17
reason: Ann email subject:- RE: Integration Pre-Configurations 
-- Darado Configuration
*/
		BEGIN TRY
			BEGIN TRAN

			IF NOT EXISTS (
					SELECT 1
					FROM lib_message_profile
					WHERE vendor_code = 'Dorado'
					)
			BEGIN
				SELECT --@message_profile_id = 10
					@facId = @FacIdDest
					--,@OrgId = 494950268
					,@parameter_value = NULL
					,@created_by = SYSTEM_USER
					,@created_date = GETDATE()

				IF (
						(
							SELECT count(1)
							FROM facility
							WHERE fac_id NOT IN (9001)
								AND deleted = 'N'
								AND inactive IS NULL
								AND inactive_date IS NULL
							) = 1
						)
				BEGIN
					SET @multiFacility = 0
				END

				SET @email = 'MessagingGroupEmail@pointclickcare.com'
				SET @sqlstring = 'SELECT @endpoint_url = ''{ustrftp_root}/ftp/integrationfiles/dorado/' + @OrgCode + '/270_Requests''
	,@importFTPLocation = ''{ustrftp_root}/integrationfiles/dorado/' + @OrgCode + 
					'/271_Results''
	,@parameter_value = CASE 
		WHEN environment_name IN (
				''www20''
				,''www24''
				,''www28''
				,''brk''
				)
			THEN ''2'' ---- ''Monday''
		WHEN environment_name IN (
				''www21''
				,''www26''
				,''www31''
				,''efs''
				,''hcr''
				)
			THEN ''3'' ---- ''Tuesday''
		WHEN environment_name IN (
				''www22''
				,''www29''
				,''www30''
				,''hcr''
				)
			THEN ''4'' ---- ''Wednesday''
		WHEN environment_name IN (
				''www23''
				,''www30''
				,''snrz''
				)
			THEN ''5'' ---- ''Thursday''
		WHEN environment_name IN (
				''www19''
				,''www25''
				,''lcca''
				)
			THEN ''6'' ----''Friday''
		WHEN environment_name IN (
				''qapcc05''
				,''dvistio''
				,''mca''
				,''qacorerus''
				,''qacorerca''
				,''mus''
				,''azvtca''
				,''azvtus''
				,''wus''
				)
			THEN ''10'' ---- For QA team only
		END
	,@sessionServerName = ''['' + session_instance_name + '']''
	,@sessionDatabaseName = ''['' + session_database_name + '']'' FROM ' 
					+ @SessionInstanceServerName + '
WHERE environment_name = ''' + SUBSTRING(@Environment, patindex('%[_]%', @Environment) + 1, len(@Environment)) + ''''

				EXEC Sp_executesql @sqlstring
					,N'@endpoint_url VARCHAR(max) OUTPUT, @importFTPLocation VARCHAR(max) OUTPUT, @parameter_value VARCHAR(max) OUTPUT, @sessionServerName VARCHAR(max) OUTPUT, @sessionDatabaseName VARCHAR(max) OUTPUT'
					,@endpoint_url = @endpoint_url OUTPUT
					,@importFTPLocation = @importFTPLocation OUTPUT
					,@parameter_value = @parameter_value OUTPUT
					,@sessionServerName = @sessionServerName OUTPUT
					,@sessionDatabaseName = @sessionDatabaseName OUTPUT

				--SELECT @endpoint_url
				--	,@importFTPLocation
				--	,@parameter_value
				--	,@sessionServerName
				--	,@sessionDatabaseName
				IF EXISTS (
						SELECT *
						FROM dbo.pcc_global_primary_key
						WHERE table_name = 'lib_message_profile'
						)
				BEGIN
					IF (
							SELECT next_key
							FROM pcc_global_primary_key
							WHERE table_name = 'lib_message_profile'
							) <= (
							SELECT Max(message_profile_id)
							FROM lib_message_profile
							)
					BEGIN
						DELETE
						FROM pcc_global_primary_key
						WHERE table_name = 'lib_message_profile'
					END
				END

				----IF (@multiFacility = 0)
				----BEGIN
				----	IF NOT EXISTS (
				----			SELECT 1
				----			FROM dbo.facility
				----			WHERE fac_id = @facId
				----			)
				----	BEGIN
				----		UPDATE facility
				----		SET messages_enabled_flag = 'Y'
				----		WHERE fac_id = @facId
				----	END
				----END
				SET @message_profile_id = NULL

				DELETE
				FROM pcc_global_primary_key
				WHERE table_name = 'lib_message_profile'
					AND key_column_name = 'message_profile_id';

				SELECT @message_profile_id = coalesce(max(message_profile_id), 0)
				FROM dbo.lib_message_profile WITH (NOLOCK)

				SET @message_profile_id = @message_profile_id + 1

				----EXEC [dbo].Get_next_primary_key 'lib_message_profile'
				----	,'message_profile_id'
				----	,@message_profile_id OUTPUT
				----	,1
				IF (@message_profile_id > 0)
				BEGIN
					SET @step = 1

					INSERT INTO [dbo].[lib_message_profile] (
						message_profile_id
						,vendor_code
						,description
						,message_protocol_id
						,receiving_application
						,sending_application
						,message_communication_id
						,deleted
						,message_mode
						,is_enabled
						,is_integrated_pharmacy
						,[endpoint_url]
						,created_by
						,created_date
						)
					VALUES (
						@message_profile_id
						,'Dorado'
						,'Dorado'
						,'14'
						,'xxxxxxxx'
						,'xxxxxxxx'
						,'1'
						,'N'
						,'P'
						,'N' -- Added as per Eddie email
						,'Y'
						,@endpoint_url
						,@created_by
						,Getdate()
						)
				END

				IF (@multiFacility = 0)
				BEGIN
					SET @step = 2

					INSERT INTO message_profile (
						batch_eligibility
						,fac_id
						,sending_application
						,created_by
						,message_mode
						,is_enabled
						,message_communication_id
						,[endpoint_url]
						,remote_login
						,realtime_eligibility
						,created_date
						,message_profile_id
						,message_protocol_id
						)
					VALUES (
						'N'
						,@facId
						,''
						,@created_by
						,'P'
						,'N'
						,'1'
						,@endpoint_url
						,''
						,'N'
						,Getdate()
						,@message_profile_id
						,'14'
						)

					SET @step = 3

					INSERT INTO message_profile (
						batch_eligibility
						,fac_id
						,sending_application
						,created_by
						,message_mode
						,is_enabled
						,message_communication_id
						,endpoint_url
						,remote_login
						,realtime_eligibility
						,created_date
						,message_profile_id
						,message_protocol_id
						)
					VALUES (
						'N'
						,'9001'
						,''
						,@created_by
						,'P'
						,'N'
						,'1'
						,@endpoint_url
						,''
						,'N'
						,Getdate()
						,@message_profile_id
						,'14'
						)
				END

				----SELECT @sessionServerName = '[US32048\ProdW4SESS]'
				----	,@sessionDatabaseName = '[wessessioninfo_www4]'
				---- Following code commented as per Ann. Reason:- TS should no touch global tables exists outside client database.
				SET @step = 4

				------SELECT @multiFacility MultiFacId
				------	,@facId FacId
				----SELECT @facId
				----	,@importFTPLocation
				----	,@message_profile_id

				INSERT INTO [dbo].[message_profile_param] (
					param_value_type
					,fac_id
					,param_value
					,message_profile_id
					,param_id
					)
				VALUES (
					'3'
					,CASE 
						WHEN @multiFacility = 0
							THEN @facId
						ELSE - 1
						END
					,@importFTPLocation
					,@message_profile_id
					,'1'
					)

				SET @step = 5

				INSERT INTO [dbo].[vaf_vendor_alert_facility_config] (
					[fac_id]
					,[protocol_id]
					,[override_emc]
					,[message_profile_id]
					)
				VALUES (
					CASE 
						WHEN @multiFacility = 0
							THEN @facId
						ELSE - 1
						END
					,14
					,0
					,@message_profile_id
					)

				SET @step = 6

				INSERT INTO [dbo].[vaf_vendor_alert_config] (
					alert_id
					,fac_id
					,protocol_id
					,enabled
					,email
					,message_profile_id
					)
				SELECT alert_id
					,CASE 
						WHEN @multiFacility = 0
							THEN @facId
						ELSE - 1
						END AS fac_id
					,14 AS protocol_id
					,1 AS enabled
					,NULL AS email
					,@message_profile_id
				FROM vaf_vendor_alert
				WHERE protocol_id = 14
					AND type = 'F'

				IF NOT EXISTS (
						SELECT 1
						FROM vaf_vendor_alert_config
						WHERE [email] = @email
							AND protocol_id = 14
						)
				BEGIN
					SET @step = 7

					INSERT INTO [dbo].[vaf_vendor_alert_config] (
						alert_id
						,fac_id
						,protocol_id
						,[enabled]
						,email
						,message_profile_id
						)
					SELECT 111
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,14 protocol_id
						,1 AS [enabled]
						,@email
						,@message_profile_id
					
					UNION ALL
					
					SELECT 121
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,14 protocol_id
						,1 AS [enabled]
						,@email
						,@message_profile_id
					
					UNION ALL
					
					SELECT 198
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,14 protocol_id
						,1 AS [enabled]
						,@email
						,@message_profile_id
					
					UNION ALL
					
					SELECT 199
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,14 protocol_id
						,1 AS [enabled]
						,@email
						,@message_profile_id
				END

				SET @step = 8

				----SELECT @importFTPLocation
				EXEC [dbo].[sproc_msgVendor_dml_upsertEdiFtpLocations] @ftp_location_path = @importFTPLocation
					,@active = 1
					,@description = N'Dorado Eligibility Inbound'
					,@created_by = @created_by
					,@ftp_location_type = N'E'
					,@DebugMe = N'N'
					,@status_code = NULL
					,@status_text = NULL

				IF @DebugMe = 'Y'
					PRINT 'Dorado insert failure in step:' + convert(VARCHAR(3), @step) + '    ' + convert(VARCHAR(26), getdate(), 109)
			END

			COMMIT TRAN

			SET @sqlstring = ''
			SET @sqlstring = 'DECLARE @query nvarchar(max) 
	set @query = ''IF EXISTS(SELECT 1 FROM organization_parameter WHERE parameter_group = ''''ELIG_270_GROUP''''
				AND parameter_field = ''''eligibility_batch_run_day''''
				AND deleted = ''''N''''
				AND org_id = ''''' + CAST(@OrgId AS VARCHAR) + ''''' )
				BEGIN
					UPDATE organization_parameter
					SET parameter_value = ''''' + @parameter_value + '''''
					, revision_by = ''''' + @created_by + '''''
					, revision_date = ''''' + CAST(@created_date AS VARCHAR) + '''''
					WHERE parameter_group = ''''ELIG_270_GROUP''''
					AND parameter_field = ''''eligibility_batch_run_day''''
					AND deleted = ''''N''''
					AND org_id = ''''' + CAST(@OrgId AS VARCHAR) + 
				''''' 
				END
				ELSE
				BEGIN
					DECLARE @paramId integer
					SET @paramId = ISNULL((SELECT MAX(parameter_id) FROM organization_parameter),0)
					SET @paramId = @paramId + 1
					INSERT INTO [dbo].[organization_parameter]
						   ([parameter_id]
						   ,[created_by]
						   ,[created_date]
						   ,[deleted]
						   ,[org_id]
						   ,[parameter_group]
						   ,[parameter_field]
						   ,[parameter_label]
						   ,[parameter_value])
					 SELECT '''''''' + cast(@paramId as varchar) + '''''''' as [parameter_id]
						   ,''''' + @created_by + ''''' [created_by]
						   ,''''' + CAST(@created_date AS VARCHAR) + ''''' [created_date]
						   ,''''N'''' [deleted]
						   ,''''' + CAST(@OrgId AS VARCHAR) + ''''' [org_id]
						   ,''''ELIG_270_GROUP'''' [parameter_group]
						   ,''''eligibility_batch_run_day'''' [parameter_field]
						   ,''''Eligibility Batch Run Day'''' [parameter_label]
						   ,''''' + @parameter_value + 
				''''' [parameter_value]
				END''
				EXEC ' + @sessionServerName + '.' + @sessionDatabaseName + '.sys.sp_executesql @query		   '

			--PRINT @sqlstring
			EXEC sp_executesql @sqlstring
		END TRY

		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK TRAN

			SET @err = ''
			SET @err = 'Error in Dorado insert for ' + @Creator + ': ' + ERROR_MESSAGE()

			RAISERROR (
					@err
					,16
					,1
					)
		END CATCH

		IF (@status_text = 'Success')
		BEGIN
			----SET @status_code = 0
			----SET @status_text = 'Success'
			UPDATE facility
			SET location_status_id = (
					SELECT location_status_id
					-- select *
					FROM dbo.location_status WITH (NOLOCK)
					WHERE code = 'SETUP'
					)
			WHERE fac_id != 9001
				AND deleted = 'N'
				AND fac_id = @FacIdDest

			EXEC [operational].[sproc_SendNewFacilityEmail] @orgcode = @orgcode
				,@case_number = @Creator
				,@EmailRecipients = @EmailRecipients
				,@CreatedBy = @FacilityCreator
				,@TSServerName = @TSServerName
		END

		SELECT @status_text AS sp_error_msg

		RETURN 0;
	END TRY

	BEGIN CATCH
		SET @status_text = ERROR_MESSAGE()

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION -- RollBack in case of Error

		IF @status_text <> ''
		BEGIN
			SET @status_text = CONCAT (
					OBJECT_NAME(@@PROCID)
					,' - '
					,' - '
					,'Status Text:-' + @status_text
					)

			SELECT @status_text AS sp_error_msg

			RETURN - 100;
		END
	END CATCH
END
GO

GRANT EXECUTE
	ON operational.sproc_CreateFacility
	TO PUBLIC
GO




GO

print 'K_Operational_Branch/5_StoredProcedures/US_Only/sproc_CreateFacility.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/US_Only/sproc_CreateFacility.sql',getdate(),'4.4.9_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/US_Only/sproc_SendNewFacilityEmail.sql',getdate(),'4.4.9_06_CLIENT_K_Operational_Branch_US.sql')

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


IF EXISTS (
		SELECT 1
		FROM dbo.sysobjects
		WHERE id = object_id(N'[operational].[sproc_SendNewFacilityEmail]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
BEGIN
	DROP PROCEDURE [operational].[sproc_SendNewFacilityEmail]
END
GO

CREATE PROCEDURE [operational].[sproc_SendNewFacilityEmail] (
	@orgcode VARCHAR(20)
	,@case_number VARCHAR(15)
	,@EmailRecipients VARCHAR(max)
	,@CreatedBy NVARCHAR(50)
	,@TSServerName VARCHAR(128)
	)
AS
BEGIN
	DECLARE @bodyMsg NVARCHAR(max)
		,@subject NVARCHAR(max)
		,@tableHTML NVARCHAR(max)
		,@TableFac NVARCHAR(MAX) = ''
		,@TableLoginHist NVARCHAR(MAX) = ''
		,@TableSrcOrg NVARCHAR(MAX) = ''
		,@TableMPI NVARCHAR(MAX) = ''
		,@TableIRM NVARCHAR(MAX) = ''
		,@TableLibDesc NVARCHAR(MAX) = ''
		,@GLAP NVARCHAR(MAX) = ''
		,@FinalTable NVARCHAR(MAX) = ''
		,@sqlstring NVARCHAR(max)

	--DECLARE @caseno NVARCHAR(MAX)=''
	--set @caseno = substring(@case_number,PATINDEX('%[0-9]%',@case_number),len(@case_number))
	SET @subject = CONCAT (
			'New Facility/Facilities have been added to org code "'
			,@orgcode
			,'"as requested on '
			,@case_number
			,'. Resource: '
			,Ltrim(rtrim(@CreatedBy))
			)

	-----------------------Fac_details------------------------------
	SELECT @TableFac = CONCAT (
			@TableFac
			,'<tr style="background-color:;">'
			,'<td>'
			,CAST(fac_id AS VARCHAR(100))
			,'</td>'
			,'<td>'
			,[name]
			,'</td>'
			,'<td>'
			,[Health_Type]
			,'</td>'
			,'</tr>'
			)
	FROM [dbo].[facility] WITH (NOLOCK)
	WHERE created_by = @case_number --<case_number>

	SET @tableHTML = CONCAT (
			N'<H3><font color="Blue">Facility Details</H3>'
			,N'<tr><td><table border="1" align="left" cellpadding="2" cellspacing="0" style="color:black;font-family:arial,helvetica,sans-serif;text-align:center;" >'
			,N'<tr style ="font-size: 14px;font-weight: normal;background: #b9c9fe;">
			<th>Fac ID</th>
			<th>Facility Name</th>
			<th>Health Type</th>
			</tr>'
			,@TableFac
			,N'</table></td></tr><tr><td></td></tr> '
			)

	-----------------------Login History Details------------------------------
	IF OBJECT_ID('TEMPDB..#Result') IS NOT NULL
		DROP TABLE #Result

	SELECT DISTINCT org_code
	INTO #result
	FROM dbo.login_history_archive WITH (NOLOCK)

	SELECT @TableLoginHist = @TableLoginHist + '<tr style="background-color:;">' + '<td>' + 'source/current org code = ' + org_code + '  ***If this is incorrect, contact Technical Services for direction ' + '</td>' + '</tr>'
	FROM #Result

	--where org_code = 'ahc'--<org_code>
	SET @tableHTML = @tableHTML + N'<H3><font color="Blue">Login History Details</H3>' + N'<tr><td><table border="1" align="left" cellpadding="2" cellspacing="0" style="color:black;font-family:arial,helvetica,sans-serif;text-align:center;" >' + N'<tr style ="font-size: 14px;font-weight: normal;background: #b9c9fe;">
<th>Login History</th>
</tr>' + @TableLoginHist + N'</table></td></tr><tr><td></td></tr>'
	-----------------------SrcOrg Details------------------------------
	SET @sqlstring = 'SELECT @TableSrcOrg = @TableSrcOrg + ''<tr style="background-color:;">'' + ''<td>'' + ''Org description = '' + OrgDesc + ''</td>'' + ''</tr>''
			FROM ' + @TSServerName + '
			WHERE OrgCode = ''' + @orgcode + ''''

	---- PRINT @sqlstring
	EXEC Sp_executesql @sqlstring
		,N'@TableSrcOrg VARCHAR(MAX) OUTPUT'
		,@TableSrcOrg = @TableSrcOrg OUTPUT

	---- SELECT @TableIRM
	SET @tableHTML = @tableHTML + N'<H3><font color="Blue">Org Details</H3>' + N'<tr><td><table border="1" align="left" cellpadding="2" cellspacing="0" style="color:black;font-family:arial,helvetica,sans-serif;text-align:center;" >' + N'<tr style ="font-size: 14px;font-weight: normal;background: #b9c9fe;">
<th>Org Description</th>
</tr>' + @TableSrcOrg + N'</table></td></tr><tr><td></td></tr>'
	-----------------------MPI Details------------------------------
	SET @sqlstring = 'SELECT @TableMPI = @TableMPI + ''<tr style="background-color:;">'' + ''<td>'' + ''MPI enabled = '' + [EnableMPI] + ''  ***If this is a management company, this should NOT be enabled'' + ''</td>'' + ''</tr>''
			FROM ' + @TSServerName + '
			WHERE OrgCode = ''' + @orgcode + ''''

	---- PRINT @sqlstring
	EXEC Sp_executesql @sqlstring
		,N'@TableMPI VARCHAR(MAX) OUTPUT'
		,@TableMPI = @TableMPI OUTPUT

	SET @tableHTML = @tableHTML + N'<H3><font color="Blue">MPI Details</H3>' + N'<tr><td><table border="1" align="left" cellpadding="2" cellspacing="0" style="color:black;font-family:arial,helvetica,sans-serif;text-align:center;" >' + N'<tr style ="font-size: 14px;font-weight: normal;background: #b9c9fe;">
<th>MPI Details</th>
</tr>' + @TableMPI + N'</table></td></tr><tr><td></td></tr>'
	-----------------------IRM Details------------------------------
	SET @sqlstring = 'SELECT @TableIRM = @TableIRM + ''<tr style="background-color:;">'' + ''<td>'' + ''IRM enabled = '' + [EnableIRM] + ''  ***If this is incorrect, contact Technical Services for direction'' + ''</td>'' + ''</tr>''
			FROM ' + @TSServerName + '
			WHERE OrgCode = ''' + @orgcode + ''''

	---- PRINT @sqlstring
	EXEC Sp_executesql @sqlstring
		,N'@TableIRM VARCHAR(MAX) OUTPUT'
		,@TableIRM = @TableIRM OUTPUT

	---- SELECT @TableIRM
	SET @tableHTML = @tableHTML + N'<H3><font color="Blue">IRM Details</H3>' + N'<tr><td><table border="1" align="left" cellpadding="2" cellspacing="0" style="color:black;font-family:arial,helvetica,sans-serif;text-align:center;" >' + N'<tr style ="font-size: 14px;font-weight: normal;background: #b9c9fe;">
<th>IRM Details</th>
</tr>' + @TableIRM + N'</table></td></tr><tr><td></td></tr>'

	-----------------------Library Description------------------------------
	SELECT @TableLibDesc = @TableLibDesc + '<tr style="background-color:;">' + '<td>' + 'library description = ' + [description] + '  ****If required....Validate libraries are correct for a PURE ALF' + '</td>' + '</tr>'
	FROM dbo.cp_std_library WITH (NOLOCK)
	WHERE deleted = 'N'

	SET @tableHTML = @tableHTML + N'<H3><font color="Blue">Library Descripion</H3>' + N'<tr><td><table border="1" align="left" cellpadding="2" cellspacing="0" style="color:black;font-family:arial,helvetica,sans-serif;text-align:center;" >' + N'<tr style ="font-size: 14px;font-weight: normal;background: #b9c9fe;">
<th>Library Description</th>
</tr>' + @TableLibDesc + N'</table></td></tr><tr><td></td></tr>'

	-----------------------GL/AP Availability------------------------------
	SELECT @glap = @glap + '<tr style="background-color:;">' + '<td>' + CAST(f.fac_id AS VARCHAR(100)) + '</td>' + '<td>' + CASE 
			WHEN cast(c.fac_id AS NVARCHAR) IS NULL
				THEN 'GL/AP Not Available'
			ELSE 'GL/AP Available'
			END + '</td>' + '<td>' + f.[name] + '</td>'
	FROM dbo.gl_configuration c WITH (NOLOCK)
	RIGHT JOIN dbo.facility f WITH (NOLOCK) ON f.fac_id = c.fac_id
	WHERE f.created_by = @case_number

	SET @tableHTML = @tableHTML + N'<H3><font color="Blue">GL/AP Availability</H3>' + N'<tr><td><table border="1" align="left" cellpadding="2" cellspacing="0" style="color:black;font-family:arial,helvetica,sans-serif;text-align:center;" >' + N'<tr style ="font-size: 14px;font-weight: normal;background: #b9c9fe;">
<th>Fac ID</th>
<th>GL/AP Availability</th>
<th>Facility Name</th>
</tr>' + @glap + N'</table></td></tr><tr><td></td></tr>'
	--print @glap
	SET @FinalTable = '<table>' + @tableHTML + '</table>'

	--Print @finalTable
	--EXEC msdb.dbo.sp_send_dbmail @recipients='<email_ids>',
	--updated by RYAN - 04/03/2020 -- removed my email and added TSImplementation@pointclickcare.com
	EXEC msdb.dbo.sp_send_dbmail @recipients = @EmailRecipients -- 'TSImplementation@pointclickcare.com;<email_ids>'
		,
		--EXEC msdb.dbo.sp_send_dbmail @recipients='ryan.c@pointclickcare.com;<email_ids>',
		@subject = @subject
		,@body = @finalTable
		,@body_format = 'HTML';
END
GO

GRANT EXECUTE
	ON operational.sproc_SendNewFacilityEmail
	TO PUBLIC
GO

GO

print 'K_Operational_Branch/5_StoredProcedures/US_Only/sproc_SendNewFacilityEmail.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/US_Only/sproc_SendNewFacilityEmail.sql',getdate(),'4.4.9_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.9_06_CLIENT_K_Operational_Branch_US.sql')

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
values ('4.4.9_K', 'upload_history')


GO

print '..\Update db version.sql --****SCRIPT DONE****'

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.9_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking (script,timestamp,upload) values ('UPLOAD END',getdate(),'4.4.9_06_CLIENT_K_Operational_Branch_US.sql')