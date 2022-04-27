SET NOCOUNT ON
GO

SET DEADLOCK_PRIORITY HIGH
GO


insert into upload_tracking (script, timestamp, upload) values ('UPLOAD_START',getdate(),'4.4.8_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_facacq_mergeCopyStep3.sql',getdate(),'4.4.8_06_CLIENT_K_Operational_Branch_US.sql')

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
		WHERE id = object_id(N'[operational].[sproc_facacq_mergeCopyStep3]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
BEGIN
	DROP PROCEDURE [operational].[sproc_facacq_mergeCopyStep3]
END
GO

CREATE PROCEDURE [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy VARCHAR(100)
	,@AllModulestoCopy VARCHAR(100)
	,@NewDB VARCHAR(50)
	,@CaseNo VARCHAR(50)
	,@ActiveResident VARCHAR(50)
	,@DisDate VARCHAR(50)
	/**************************************************

	CASE			: EXTRACT/Import ORG
	CREATED BY		: HENNY (Compiled by JIMMY)
	CREATED DATE	: 10/05/2012
	MODIFIED BY : JASPREET SINGH
	MODULES			: Resident , Resident Identifier , Contact --E1
					  Staff --E2
					  Medical Proffesional --E2a
					  External Facility --E3
					  User Defined Data --E4
				      Room and Bed --E5
					  Census --E6
					  MDS 2.0, MDS 3, Custom UDA --E7
					  Diagnosis --E8
					  Progress Note --E9
					  Vital --E10
					  Immunization --E11
					  Care Plan --E12
							E12a --Custom Care Plan
							E12b --Care Plan Copy Library
					  Phys Order --E13
					  Security Roles --E14
					  Security User --E15
					  Alert --E16
					  Risk Management --E17
					  Trust--E18
					  IRM--E19
					  Online documentation (Upload files) --E20
					  Lab & Radiology - E21
					  Master Insurance -- E22
					  Notes - E23

Purpose:


e.g. 
EXEC [operational].[sproc_facacq_mergeCopyStep3] 'E23','E1,E2,E2a,E3,E4,E5,E6,E7,E7a,E7b,E7c,E8,E12b,E11,E9,E10,E13,E16,E17,E20,E21,E22,E23','N','541161050','N',''
*************************************************/
AS
BEGIN
	SET DEADLOCK_PRIORITY 4;
	--SET NOCOUNT ON;

	DECLARE @sql VARCHAR(max);

	SET @sql = '';
	SET @CaseNo = 'EIcase' + @CaseNo;

	IF EXISTS (
			SELECT *
			FROM [dbo].sysobjects
			WHERE id = object_id(N'[dbo].[mergeTables]')
				AND OBJECTPROPERTY(id, N'IsUserTable') = 1
			)
		DROP TABLE [dbo].[mergeTables]

	IF EXISTS (
			SELECT *
			FROM dbo.sysobjects
			WHERE id = object_id(N'[dbo].[mergeJoins]')
				AND OBJECTPROPERTY(id, N'IsUserTable') = 1
			)
		DROP TABLE [dbo].[mergeJoins]

	--INSERT RECORD TO MERGE TABLES FROM THE MASTER DATABASE
	SELECT [tablename]
		,[idField]
		,[tableorder]
		,[scopeField1]
		,[scopeField2]
		,[scopeField3]
		,[scopeField4]
		,[scopeField5]
		,[scopeField6]
		,[scopeField7]
		,[cleanUpTable]
		,[TotalRecords]
		,[IndexCreated]
		,[QueryFilter]
		,[IsTrigger]
		,[IsReferencedByForeignKey]
		,[HasNoPK]
	INTO [dbo].[mergeTables]
	FROM [mergeTablesMaster];

	--INSERT RECORD TO MERGE JOINS FROM THE MASTER DATABASE
	SELECT [tablename]
		,[parenttable]
		,[fieldName]
		,[parentField]
		,[tableorder]
		,[pkJoin]
	INTO [dbo].[mergeJoins]
	FROM [mergeJoinsMaster];

	--UPDATE IF THE TABLE HAS NO PK (When it has no IDField)
	UPDATE MERGETABLES
	SET HasNoPK = 'Y'
	WHERE idField IS NULL

	--UPDATE IF THE TABLE REFERENCED BY OTHER TABLES	
	UPDATE MERGETABLES
	SET IsReferencedByForeignKey = 'Y'
	WHERE TABLENAME IN (
			SELECT NAME
			FROM SYS.OBJECTS
			WHERE object_id IN (
					SELECT parent_object_id
					FROM sys.foreign_keys
					)
				AND type = 'U'
			)

	--INSERT THE MODULES TO COPY -- insert ALL for complete copy----------------------------------------------------------------------
	IF OBJECT_ID(N'tempdb..#tmpModulesCopy', N'U') IS NOT NULL
		DROP TABLE #tmpModulesCopy;

	CREATE TABLE #tmpModulesCopy (moduleID VARCHAR(50));

	IF OBJECT_ID(N'tempdb..#tmpAllModulestoCopy', N'U') IS NOT NULL
		DROP TABLE #tmpAllModulestoCopy;

	CREATE TABLE #tmpAllModulestoCopy (moduleID VARCHAR(50));

	TRUNCATE TABLE [MergeCurrentMod];

	INSERT INTO [MergeCurrentMod]
	SELECT @ModuletoCopy;

	INSERT INTO #tmpModulesCopy
	SELECT @ModuletoCopy;

	INSERT INTO #tmpAllModulestoCopy
	SELECT *
	FROM dbo.Split(@AllModulestoCopy, ',')

	--START EXTRACT----------------------------------------------------------------------
	IF OBJECT_ID(N'tempdb..#mergeTables', N'U') IS NOT NULL
		DROP TABLE #mergeTables;

	IF OBJECT_ID(N'tempdb..#mergejoins', N'U') IS NOT NULL
		DROP TABLE #mergejoins;

	--To create the schema
	SELECT *
	INTO #mergeTables
	FROM mergeTables
	WHERE tablename = '1'

	SELECT *
	INTO #mergejoins
	FROM mergejoins
	WHERE tablename = '1'

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('E1')
			) --Resident , Resident Identifier , Contact --E1---------------------------
	BEGIN
		--Must run this module first
		INSERT INTO #mergeTables
		SELECT *
		FROM dbo.mergeTables
		WHERE tablename IN (
				'regions'
				,'facility'
				,'common_code'
				-- Added By: Jaspreet Singh, Date: 2017-06-06, Reason: Check smartsheet Update EI Script Row 24
				,'common_code_activation'
				,'mpi'
				,'mpi_address'
				,'mpi_merge_history'
				,'mpi_history'
				,'clients'
				,'Pharmacy'
				,'contact'
				,'clients_attribute'
				,'allergy_type'
				,'allergy_status'
				,'allergy_severity'
				,'allergy_reaction_type'
				,'allergy_category'
				,'allergy_subreaction_type'
				,'allergy_lib_std'
				,'allergy_lib_custom'
				,'allergy'
				,'allergy_strikeout'
				,'allergy_reaction_note'
				,'cp_sec_user_audit'
				,'client_next_review_date_tracking'
				,'care_profile_value_single'
				,'care_profile_value_single_audit'
				,'care_profile_value_multiple'
				,'care_profile_value_multiple_audit'
				,'care_profile_value_multiple_strikeout'
				,'evt_contact'
				,'evt_contact_role'
				,'evt_event'
				,'evt_occ_resident'
				,'evt_occurrence'
				,'evt_resource'
				,'evt_std_event_type'
				,'evt_std_event_type_active_facility'
				,'evt_std_location'
				,'evt_std_location_active_facility'
				,'evt_std_resource'
				,'evt_std_resource_active_facility'
				--***************Added By Jaspreet Singh, Date: 2017-04-12, Reason: Check Rina email 3.7.12********
				,'id_type_activation'
				,'id_type_activation_audit'
				-- Added By: Jaspreet Singh, Date: 12/29/2020, Reason: Nigel email on 12/29/2020
				,'fac_message'
				,'evt_event_participant'
				,'evt_responsible'
				-- Added By: Nigel Liang, Date: 11/24/2021, Reason: Vicki request
				,'admin_consent'
				)

		INSERT INTO #mergejoins
		SELECT *
		FROM mergejoins
		WHERE tablename IN (
				'facility'
				,'mpi'
				,'mpi_address'
				,'mpi_merge_history'
				,'mpi_history'
				,'clients'
				,'Pharmacy'
				,'clients_attribute'
				,'allergy_type'
				,'allergy_status'
				,'allergy_severity'
				,'allergy_reaction_type'
				,'allergy_category'
				,'allergy_subreaction_type'
				,'allergy_lib_std'
				,'allergy_lib_custom'
				,'allergy'
				,'allergy_strikeout'
				,'allergy_reaction_note'
				,'cp_sec_user_audit'
				,'client_next_review_date_tracking'
				,'care_profile_value_single'
				,'care_profile_value_single_audit'
				,'care_profile_value_multiple'
				,'care_profile_value_multiple_audit'
				,'care_profile_value_multiple_strikeout'
				,'evt_contact'
				,'evt_contact_role'
				,'evt_event'
				,'evt_occ_resident'
				,'evt_occurrence'
				,'evt_resource'
				,'evt_std_event_type'
				,'evt_std_event_type_active_facility'
				,'evt_std_location'
				,'evt_std_location_active_facility'
				,'evt_std_resource'
				,'evt_std_resource_active_facility'
				--***************Added By Jaspreet Singh, Date: 2017-04-12, Reason: Check Rina email 3.7.12********
				,'id_type_activation'
				,'id_type_activation_audit'
				-- Added By: Jaspreet Singh, Date: 2017-06-06, Reason: Check smartsheet Update EI Script Row 24
				,'common_code'
				,'common_code_activation'
				--***************Added By Linlin Jing, Date: 2018-06-19, Reason: Check Rina email 3.7.15.3********
				,'devprg_hist_medication_administration_schedule_landing'
				,'devprg_hist_medication_diagnosis_landing'
				,'devprg_hist_diagnosis_landing'
				,'devprg_hist_care_period_landing'
				,'devprg_hist_medication_landing'
				-- Added By: Jaspreet Singh, Date: 12/29/2020, Reason: Nigel email on 12/29/2020
				,'fac_message'
				,'evt_event_participant'
				,'evt_responsible'
				)

		--Ann added Feb 22, 2016
		IF NOT EXISTS (
				SELECT 1
				FROM #tmpAllModulestoCopy
				WHERE moduleID IN ('E13')
				) --physician order---------------------------
		BEGIN
			INSERT INTO #mergeTables
			SELECT *
			FROM dbo.mergeTables
			WHERE tablename IN ('cr_cust_med')

			INSERT INTO #mergejoins
			SELECT *
			FROM mergejoins
			WHERE tablename IN ('cr_cust_med')
				AND parenttable NOT IN ('pho_order_type')
		END

		--Ann added Feb 22, 2016
		UPDATE mergeTables
		SET QueryFilter = ISNULL(QueryFilter, '') + ' AND mpi_id in (SELECT mpi_id from [origDB].clients where fac_id = [OrigFacId]) '
		WHERE tablename = 'mpi'

		--IF IRM IS SELECTED ONLY ADD THIS CODE
		IF EXISTS (
				SELECT 1
				FROM #tmpAllModulestoCopy
				WHERE moduleID IN ('E19a')
				) --IRM---------------------------
		BEGIN
			--2015-01-16 removed for Rina
			--2015-01-16 made changes for Rina
			----include New Resident
			--	UPDATE mergeTables 
			--             SET QueryFilter =   'WHERE mpi_id in (SELECT mpi_id from [origDB].clients where fac_id = [OrigFacId]  and (  (discharge_date is null or discharge_date >= ''2015-01-01 00:00:00.000'' or  client_id in ( select client_id from [pcc_temp_storage].[dbo].[PMO10780_Import_Discharged_Resident]  where fac_id = [OrigFacId] and Crossed_off_the_list = ''N''))))'
			--             WHERE tablename = 'mpi'
			--             UPDATE mergeTables 
			--             SET QueryFilter =   '  WHERE fac_id in( [OrigFacId],9001) and ( mpi_id in (select a.mpi_id from [origDB].mpi a join [origDB].clients b on a.mpi_id=b.mpi_id where b.fac_id in ([OrigFacId]) ) ) /*Added on 2015-01-16 for Rina*/ AND ( discharge_date IS NULL OR discharge_date >= ''2015-1-1 00:00:00.000'' or  client_id in ( select client_id from [pcc_temp_storage].[dbo].[PMO10780_Import_Discharged_Resident]  where fac_id = [OrigFacId] and Crossed_off_the_list = ''N'' )) '
			--             WHERE tablename = 'clients'
			---exclude New resident
			UPDATE mergeTables
			SET QueryFilter = 'WHERE mpi_id in (SELECT mpi_id from [origDB].clients where fac_id = [OrigFacId]  and ( admission_date is not null and (discharge_date is null or discharge_date >= ''2015-01-01 00:00:00.000'' or  client_id in ( select client_id from [pcc_temp_storage].[dbo].[PMO10780_Import_Discharged_Resident]  where fac_id = [OrigFacId] and Crossed_off_the_list = ''N''))))'
			WHERE tablename = 'mpi'

			UPDATE mergeTables
			SET QueryFilter = '  WHERE fac_id in( [OrigFacId],9001) and ( mpi_id in (select a.mpi_id from [origDB].mpi a join [origDB].clients b on a.mpi_id=b.mpi_id where b.fac_id in ([OrigFacId]) ) ) /*Added on 2015-01-16 for Rina*/ AND ( discharge_date IS NULL OR discharge_date >= ''2015-1-1 00:00:00.000'' or  client_id in ( select client_id from [pcc_temp_storage].[dbo].[PMO10780_Import_Discharged_Resident]  where fac_id = [OrigFacId] and Crossed_off_the_list = ''N'' )) AND admission_date IS NOT NULL'
			WHERE tablename = 'clients'
				--	--Orig
				--UPDATE mergeTables 
				--SET QueryFilter =   ' WHERE mpi_id in (SELECT mpi_id from [origDB].clients where fac_id in ([OrigFacId]) ) '
				--WHERE tablename = 'mpi'
				--UPDATE mergeTables 
				--SET QueryFilter =   '  WHERE fac_id in( [OrigFacId],9001) and ( mpi_id in (select a.mpi_id from [origDB].mpi a join [origDB].clients b on a.mpi_id=b.mpi_id where b.fac_id in ([OrigFacId]) ) ) '
				--WHERE tablename = 'clients'
		END

		--IF IRM IS SELECTED ONLY ADD THIS CODE
		IF EXISTS (
				SELECT 1
				FROM #tmpAllModulestoCopy
				WHERE moduleID IN ('E19b')
				) --IRM---------------------------
		BEGIN
			UPDATE mergeTables
			SET QueryFilter = ' WHERE mpi_id in (SELECT mpi_id from [origDB].clients where fac_id = 9001 and mpi_id not in (select mpi_id from [origDB].clients where fac_id <> 9001)) '
			WHERE tablename = 'mpi'

			UPDATE mergeTables
			SET QueryFilter = ' WHERE fac_id = 9001 and mpi_id not in (select mpi_id from [origDB].clients where fac_id <> 9001) '
			WHERE tablename = 'clients'
		END

		---- active resident 
		IF @ActiveResident = 'Y'
			AND ISDATE(@DisDate) = 0
		BEGIN
			UPDATE mergeTables
			SET QueryFilter = ISNULL(QueryFilter, '') + ' AND mpi_id in (SELECT mpi_id from [origDB].clients where fac_id = [OrigFacId] 
				and (discharge_date is null ) and admission_date is not null ) '
			WHERE tablename = 'mpi'

			UPDATE mergeTables
			SET QueryFilter = ISNULL(QueryFilter, '') + '  AND client_id in (SELECT client_id from [origDB].clients where fac_id = [OrigFacId]) and deleted=''N'' 
				and (discharge_date is null) and admission_date is not null  '
			WHERE tablename = 'clients'
		END

		IF ISDATE(@DisDate) = 1
			AND @ActiveResident = 'Y'
		BEGIN
			UPDATE mergeTables
			SET QueryFilter = ISNULL(QueryFilter, '') + ' AND mpi_id in (SELECT mpi_id from [origDB].clients where fac_id = [OrigFacId] 
				and (discharge_date is null or discharge_date>= ''' + @DisDate + ''') and admission_date is not null ) '
			WHERE tablename = 'mpi'

			UPDATE mergeTables
			SET QueryFilter = ISNULL(QueryFilter, '') + '  AND client_id in (SELECT client_id from [origDB].clients where fac_id = [OrigFacId]) and deleted=''N'' 
				and (discharge_date is null or discharge_date>= ''' + @DisDate + ''') and admission_date is not null  '
			WHERE tablename = 'clients'
		END

		--Resident Identifier---------------------------
		INSERT INTO #mergeTables
		SELECT *
		FROM dbo.mergeTables
		WHERE tablename IN (
				'id_type'
				,'client_ids'
				)

		INSERT INTO #mergejoins
		SELECT *
		FROM mergejoins
		WHERE tablename IN ('client_ids')

		--		UPDATE mergeTables SET QueryFilter =  ISNULL(QueryFilter,'') +  '  AND id_type_id IN ( SELECT id_type_id FROM [origDB].client_ids WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'') ' 
		--		WHERE tablename = 'id_type'  
		--Contact---------------------------
		INSERT INTO #mergeTables
		SELECT *
		FROM dbo.mergeTables
		WHERE tablename IN (
				'common_code'
				,'address'
				,'contact_address'
				,'mpi_contact_history'
				,'contact_history'
				,'contact_relationship[mpi001]'
				,'contact_relationship[fac001]'
				,'contact_type[mpi001]'
				,'contact_type[fac001]'
				,'clients'
				,'client_contact'
				,'Pharmacy'
				,'client_visited'
				)

		INSERT INTO #mergejoins
		SELECT *
		FROM mergejoins
		WHERE tablename IN (
				'contact'
				,'address'
				,'contact_address'
				,'mpi_contact_history'
				,'contact_history'
				,'contact_relationship[mpi001]'
				,'contact_relationship[fac001]'
				,'contact_type[mpi001]'
				,'contact_type[fac001]'
				,'client_contact'
				,'client_visited'
				)

		UPDATE mergeTables
		SET QueryFilter = '  AND address_id IN ( SELECT address_id FROM [origDB].contact_address WHERE contact_id IN (SELECT contact_id FROM [stagDB].[prefix]contact )) '
		WHERE tablename = 'address'

		--CommonCode
		UPDATE mergeTables
		SET QueryFilter = 
			'  AND item_id in  ((SELECT isnull(ethnicity_id,-1) FROM [origDB].mpi WHERE mpi_id in (SELECT mpi_id FROM [origDB].clients WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')) UNION (SELECT isnull(primary_lang_id,-1) FROM [origDB].mpi WHERE mpi_id in (SELECT mpi_id FROM [origDB].clients WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')) UNION (SELECT isnull(secondary_lang_id,-1) FROM [origDB].mpi WHERE mpi_id in (SELECT mpi_id FROM [origDB].clients WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N''))  UNION (SELECT isnull(marital_status_id,-1) FROM [origDB].mpi WHERE mpi_id in (SELECT mpi_id FROM [origDB].clients WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N''))  UNION (SELECT isnull(religion_id,-1) FROM [origDB].mpi WHERE mpi_id in (SELECT mpi_id FROM [origDB].clients WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')) UNION (SELECT isnull(race_id,-1) FROM [origDB].mpi WHERE mpi_id in (SELECT mpi_id FROM [origDB].clients WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N''))  UNION (SELECT isnull(education_id,-1) FROM [origDB].mpi WHERE mpi_id in (SELECT mpi_id FROM [origDB].clients WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')) UNION (SELECT isnull(citizenship_id,-1) FROM [origDB].mpi WHERE mpi_id in (SELECT mpi_id FROM [origDB].clients WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N''))  		UNION (SELECT isnull(country_id,-1) FROM [origDB].mpi WHERE mpi_id in (SELECT mpi_id FROM [origDB].clients WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N''))  		UNION (SELECT isnull(title,-1) FROM [origDB].mpi WHERE mpi_id in (SELECT mpi_id FROM [origDB].clients WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N''))  UNION (SELECT isnull(marital_status_id,-1) FROM [origDB].contact)  UNION (SELECT isnull(title_id,-1) FROM [origDB].contact) 		UNION (SELECT isnull(country_id,-1) FROM [origDB].mpi_address WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(country_id,-1) FROM [origDB].address)  UNION (SELECT isnull(marital_status_id,-1) FROM [origDB].mpi_contact_history WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(country_id,-1) FROM [origDB].mpi_contact_history WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(subclass_id,-1) FROM [origDB].contact_relationship[mpi001])  UNION (SELECT isnull(relationship_id,-1) FROM [origDB].contact_relationship[mpi001])  UNION (SELECT isnull(subclass_id,-1) FROM [origDB].contact_relationship[fac001])  UNION (SELECT isnull(relationship_id,-1) FROM [origDB].contact_relationship[fac001])  UNION (SELECT isnull(subclass_id,-1) FROM [origDB].contact_type[fac001])  UNION (SELECT isnull(type_id,-1) FROM [origDB].contact_type[fac001])  UNION (SELECT isnull(country_id,-1) FROM [origDB].Pharmacy WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(title_id,-1) FROM [origDB].contact_history WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(profession_id,-1) FROM [origDB].contact_history WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  ) '
		WHERE tablename = 'common_code'

		UPDATE mergeTables
		SET QueryFilter = ' AND contact_id IN ( SELECT contact_id from [origDB].contact_type where fac_id = [OrigFacId]) AND contact_id IN (select contact_id from [origDB].contact_relationship where reference_id in (select src_id from [stagDB].[prefix]mpi)) '
		WHERE tablename = 'contact'

		--IF STAFF IS SELECTED ONLY ADD THIS CODE
		IF EXISTS (
				SELECT 1
				FROM #tmpAllModulestoCopy
				WHERE moduleID IN (
						'E2'
						,'E2a'
						)
				) --Staff---------------------------
		BEGIN
			UPDATE mergeTables
			SET QueryFilter = ' AND contact_id IN ( SELECT contact_id from [origDB].contact_type where fac_id = [OrigFacId]  UNION SELECT contact_id from [origDB].staff where fac_id = [OrigFacId] UNION SELECT staff_id from [origDB].client_staff where fac_id = [OrigFacId] ) '
			WHERE tablename = 'contact'

			UPDATE mergeTables
			SET QueryFilter = '  AND address_id IN ( SELECT address_id FROM [origDB].contact_address WHERE contact_id IN (SELECT contact_id FROM [ORIGDB].contact_type WHERE fac_id = [OrigFacId] UNION select contact_id from [ORIGDB].staff WHERE fac_id = [OrigFacId] UNION SELECT staff_id from [origDB].client_staff where fac_id = [OrigFacId] )) '
			WHERE tablename = 'address'

			--if only staffs
			IF (
					SELECT ISNULL(count(1), 0)
					FROM #tmpAllModulestoCopy
					WHERE moduleID IN (
							'E2'
							,'E2a'
							)
					) < 2
				AND EXISTS (
					SELECT 1
					FROM #tmpAllModulestoCopy
					WHERE moduleID IN ('E2')
					)
				--UPDATE mergeTables SET QueryFilter = ' AND contact_id IN ( SELECT contact_id from [origDB].contact_type where fac_id = [OrigFacId]  UNION SELECT contact_id from [origDB].staff where fac_id = [OrigFacId] AND  on_staff = ''Y'' and profession_id IS NULL UNION SELECT staff_id from [origDB].client_staff where fac_id = [OrigFacId] ) '
				UPDATE mergeTables
				SET QueryFilter = ' AND contact_id IN ( SELECT contact_id from [origDB].contact_type where fac_id = [OrigFacId]  UNION SELECT contact_id from [origDB].staff where fac_id = [OrigFacId] AND  on_staff = ''Y'' and profession_id IS NULL ) '
				WHERE tablename = 'contact';

			--if only medical pro		
			IF (
					SELECT ISNULL(count(1), 0)
					FROM #tmpAllModulestoCopy
					WHERE moduleID IN (
							'E2'
							,'E2a'
							)
					) < 2
				AND EXISTS (
					SELECT 1
					FROM #tmpAllModulestoCopy
					WHERE moduleID IN ('E2a')
					)
				UPDATE mergeTables
				SET QueryFilter = ' AND contact_id IN ( SELECT contact_id from [origDB].contact_type where fac_id = [OrigFacId]  UNION SELECT contact_id from [origDB].staff where fac_id = [OrigFacId] AND  isnull(on_staff,''N'') = ''N'' and profession_id IS NOT NULL UNION SELECT staff_id from [origDB].client_staff where fac_id = [OrigFacId] ) '
				WHERE tablename = 'contact'
		END

		IF EXISTS (
				SELECT 1
				FROM #tmpAllModulestoCopy
				WHERE moduleID IN (
						'E19a'
						,'E19b'
						)
				) --IRM---------------------------
		BEGIN
			DECLARE @contactFilter VARCHAR(max);

			SET @contactFilter = 'AND contact_id IN (	SELECT contact_id from [origDB].contact_type where fac_id = [OrigFacId]  
															UNION select contact_id from [origDB].contact_relationship where reference_id in (select src_id from [stagDB].[prefix]mpi) 
																		and subclass_id in (select item_id from [origDB].common_code where item_code = ''sbclas'' and item_description = ''Resident'') '

			IF EXISTS (
					SELECT 1
					FROM #tmpAllModulestoCopy
					WHERE moduleID IN ('E3')
					) --External Fac---------------------------
				SET @contactFilter = @contactFilter + ' UNION select contact_id from [origDB].contact_relationship where reference_id in (select ext_fac_id from [origDB].emc_ext_facilities where fac_id in (-1,[OrigFacId] )) 
																		and subclass_id in (select item_id from [origDB].common_code where item_code = ''sbclas'' and item_description = ''Professional'') ' + 'and contact_id in (SELECT contact_id from [origDB].contact_type where fac_id = [OrigFacId])'

			IF EXISTS (
					SELECT 1
					FROM #tmpAllModulestoCopy
					WHERE moduleID IN (
							'E19a'
							,'E19b'
							)
					) --IRM---------------------------
				SET @contactFilter = @contactFilter + ' UNION select contact_id from [origDB].contact_relationship where reference_id in (select src_id from [stagDB].[prefix]facility) 
																							and subclass_id in (select item_id from [origDB].common_code where item_code = ''sbclas'' and item_description = ''Center'') '

			IF EXISTS (
					SELECT 1
					FROM #tmpAllModulestoCopy
					WHERE moduleID IN ('E19b')
					) --IRM  E19b----Resident-----------------------
				SET @contactFilter = @contactFilter + ' UNION 	SELECT contact_id from [origDB].contact_type where fac_id = 9001 and reference_id in (select src_id from [stagDB].[prefix]mpi) 
																			and subclass_id in (select item_id from [origDB].common_code where item_code = ''sbclas'' and item_description = ''Resident'')'

			IF EXISTS (
					SELECT 1
					FROM #tmpAllModulestoCopy
					WHERE moduleID IN ('E19b')
					) --IRM  E19b-----Professional----------------------
				SET @contactFilter = @contactFilter + ' UNION 	SELECT contact_id from [origDB].contact_type where fac_id = 9001 and reference_id in (select ext_fac_id from [origDB].emc_ext_facilities where fac_id in (-1,[OrigFacId] )) 
																		and subclass_id in (select item_id from [origDB].common_code where item_code = ''sbclas'' and item_description = ''Professional'')' + 'and contact_id in (SELECT contact_id from [origDB].contact_type where fac_id = [OrigFacId])'

			IF EXISTS (
					SELECT 1
					FROM #tmpAllModulestoCopy
					WHERE moduleID IN ('E19b')
					) --IRM  E19b-----Center----------------------
				SET @contactFilter = @contactFilter + ' UNION select contact_id from [origDB].contact_relationship where reference_id in (select src_id from [stagDB].[prefix]facility) 
																		and subclass_id in (select item_id from [origDB].common_code where item_code = ''sbclas'' and item_description = ''Center'')'

			IF EXISTS (
					SELECT 1
					FROM #tmpAllModulestoCopy
					WHERE moduleID IN ('E19b')
					) --IRM  E19b-----Medical Professional----------------------
				SET @contactFilter = @contactFilter + ' UNION select contact_id from [origDB].contact_relationship where reference_id in (select src_id from [stagDB].[prefix]facility) 
																		and subclass_id in (select item_id from [origDB].common_code where item_code = ''sbclas'' and item_description = ''Medical Professional'')'

			IF EXISTS (
					SELECT 1
					FROM #tmpAllModulestoCopy
					WHERE moduleID IN ('E19b')
					) --IRM  E19b-----Insurance----------------------
				SET @contactFilter = @contactFilter + ' UNION select contact_id from [origDB].contact_relationship where reference_id in (select src_id from [stagDB].[prefix]facility) 
																		and subclass_id in (select item_id from [origDB].common_code where item_code = ''sbclas'' and item_description = ''Insurance'')'

			--IF STAFF IS SELECTED ONLY ADD THIS CODE
			IF EXISTS (
					SELECT 1
					FROM #tmpAllModulestoCopy
					WHERE moduleID IN (
							'E2'
							,'E2a'
							)
					) --Staff---------------------------
			BEGIN
				--if only staffs
				IF (
						SELECT ISNULL(count(1), 0)
						FROM #tmpAllModulestoCopy
						WHERE moduleID IN (
								'E2'
								,'E2a'
								)
						) < 2
					AND EXISTS (
						SELECT 1
						FROM #tmpAllModulestoCopy
						WHERE moduleID IN ('E2')
						)
					SET @contactFilter = @contactFilter + '  UNION SELECT contact_id from [origDB].staff where fac_id = [OrigFacId] AND  on_staff = ''Y'' and profession_id IS NULL 
																	  UNION SELECT staff_id from [origDB].client_staff where fac_id = [OrigFacId] '

				--if only medical pro		
				IF (
						SELECT ISNULL(count(1), 0)
						FROM #tmpAllModulestoCopy
						WHERE moduleID IN (
								'E2'
								,'E2a'
								)
						) < 2
					AND EXISTS (
						SELECT 1
						FROM #tmpAllModulestoCopy
						WHERE moduleID IN ('E2a')
						)
					SET @contactFilter = @contactFilter + '   UNION SELECT contact_id from [origDB].staff where fac_id = [OrigFacId] AND  on_staff = NULL and profession_id IS NOT NULL 
																	   UNION SELECT staff_id from [origDB].client_staff where fac_id = [OrigFacId]  '

				IF (
						SELECT ISNULL(count(1), 0)
						FROM #tmpAllModulestoCopy
						WHERE moduleID IN (
								'E2'
								,'E2a'
								)
						) >= 2
					SET @contactFilter = @contactFilter + '   UNION SELECT contact_id from [origDB].staff where fac_id = [OrigFacId] 
																	   UNION SELECT staff_id from [origDB].client_staff where fac_id = [OrigFacId]  '
			END

			SET @contactFilter = @contactFilter + ') '

			UPDATE mergeTables
			SET QueryFilter = @contactFilter
			WHERE tablename = 'contact'
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'emc_ext_facilities'
				)
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable = 'emc_ext_facilities'
		END
				--		DELETE FROM  mergejoins where parenttable in ('sec_user','emc_ext_facilities')
	END

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN (
					'E2'
					,'E2a'
					)
			) --Staff and Medical Prof---------------------------
	BEGIN
		INSERT INTO #mergeTables
		SELECT *
		FROM dbo.mergeTables
		WHERE tablename IN (
				'common_code'
				,'staff'
				,'client_staff'
				--***************Added By Jaspreet Singh, Date: 2017-04-12, Reason: Check Rina email 3.7.12********
				,'medical_professional'
				,'medical_professional_activation'
				,'medical_professional_activation_audit'
				,'medical_professional_address'
				,'medical_professional_address_audit'
				,'medical_professional_address_type'
				,'medical_professional_audit'
				,'medical_professional_other_provider'
				,'medical_professional_other_provider_audit'
				,'medical_professional_phone'
				,'medical_professional_phone_audit'
				,'medical_professional_phone_type'
				-- ,'medical_professional_provider_type'  -- Commented By: Jaspreet Singh, Date: 2017-05-09, Reason: Check table name in smartsheet Update EI script
				,'medical_professional_registration_no_type'
				,'medical_professional_taxonomy'
				,'medical_professional_taxonomy_audit'
				,'medical_professional_type'
				--Added by: Linlin jing, Date: 2017-07-13, Reason: Rina's email on 2017-07-10
				,'staff_audit'
				--Added by: Linlin jing, Date: 2018-06-19, Reason: Rina's email for 3.7.15
				--,'email_alert'--removed by: Linlin jing, Date: 2018-06-20, Reason: as discussed with Ann, also Rina's email with subject 'email_alert error'
				,'email_alert_subscription'
				)

		INSERT INTO #mergejoins
		SELECT *
		FROM mergejoins
		WHERE tablename IN (
				'staff'
				,'client_staff'
				--***************Added By Jaspreet Singh, Date: 2017-04-12, Reason: Check Rina email 3.7.12********
				,'medical_professional'
				,'medical_professional_activation'
				,'medical_professional_activation_audit'
				,'medical_professional_address'
				,'medical_professional_address_audit'
				,'medical_professional_address_type'
				,'medical_professional_audit'
				,'medical_professional_other_provider'
				,'medical_professional_other_provider_audit'
				,'medical_professional_phone'
				,'medical_professional_phone_audit'
				,'medical_professional_phone_type'
				-- ,'medical_professional_provider_type'  -- Commented By: Jaspreet Singh, Date: 2017-05-09, Reason: Check table name in smartsheet Update EI script
				,'medical_professional_registration_no_type'
				,'medical_professional_taxonomy'
				,'medical_professional_taxonomy_audit'
				,'medical_professional_type'
				--Added by: Linlin jing, Date: 2017-07-13, Reason: Rina's email on 2017-07-10
				,'staff_audit'
				--Added by: Linlin jing, Date: 2018-06-19, Reason: Rina's email for 3.7.15
				--,'email_alert'--removed by: Linlin jing, Date: 2018-06-20, Reason: as discussed with Ann, also Rina's email with subject 'email_alert error'
				,'email_alert_subscription'
				)

		IF (
				SELECT count(1)
				FROM #tmpAllModulestoCopy
				WHERE moduleID IN (
						'E2'
						,'E2a'
						)
				) < 2
		BEGIN
			IF @ModuletoCopy = 'E2'
			BEGIN
				UPDATE mergeTables
				SET QueryFilter = '  AND item_id in  ( (SELECT isnull(PROFESSION_ID,-1) FROM [origDB].staff WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'' AND  on_staff = ''Y'' and profession_id IS NULL)  UNION (SELECT isnull(position_id,-1) FROM [origDB].staff WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'' AND  on_staff = ''Y'' and profession_id IS NULL)  UNION (SELECT isnull(country_id,-1) FROM [origDB].address)  UNION (SELECT isnull(subclass_id,-1) FROM [origDB].contact_relationship[mpi001])  UNION (SELECT isnull(relationship_id,-1) FROM [origDB].contact_relationship[mpi001])  UNION (SELECT isnull(subclass_id,-1) FROM [origDB].contact_relationship[fac001])  UNION (SELECT isnull(relationship_id,-1) FROM [origDB].contact_relationship[fac001])  UNION (SELECT isnull(Professional_Relation_ID,-1) FROM [origDB].client_staff WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'') ) and deleted = ''N''  '
				WHERE tablename = 'common_code'
			END

			IF @ModuletoCopy = 'E2a'
			BEGIN
				UPDATE mergeTables
				SET QueryFilter = '  AND item_id in  ( (SELECT isnull(PROFESSION_ID,-1) FROM [origDB].staff WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'' AND  on_staff = NULL and profession_id IS NOT NULL)  UNION (SELECT isnull(position_id,-1) FROM [origDB].staff WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'' AND  on_staff = NULL and profession_id IS NOT NULL)  UNION (SELECT isnull(country_id,-1) FROM [origDB].address)  UNION (SELECT isnull(subclass_id,-1) FROM [origDB].contact_relationship[mpi001])  UNION (SELECT isnull(relationship_id,-1) FROM [origDB].contact_relationship[mpi001])  UNION (SELECT isnull(subclass_id,-1) FROM [origDB].contact_relationship[fac001])  UNION (SELECT isnull(relationship_id,-1) FROM [origDB].contact_relationship[fac001])  UNION (SELECT isnull(Professional_Relation_ID,-1) FROM [origDB].client_staff WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'') ) and deleted = ''N''  '
				WHERE tablename = 'common_code'
			END
		END
		ELSE
			UPDATE mergeTables
			SET QueryFilter = '  AND item_id in  ( (SELECT isnull(PROFESSION_ID,-1) FROM [origDB].staff WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(position_id,-1) FROM [origDB].staff WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(country_id,-1) FROM [origDB].address)  UNION (SELECT isnull(subclass_id,-1) FROM [origDB].contact_relationship[mpi001])  UNION (SELECT isnull(relationship_id,-1) FROM [origDB].contact_relationship[mpi001])  UNION (SELECT isnull(subclass_id,-1) FROM [origDB].contact_relationship[fac001])  UNION (SELECT isnull(relationship_id,-1) FROM [origDB].contact_relationship[fac001])  UNION (SELECT isnull(Professional_Relation_ID,-1) FROM [origDB].client_staff WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'') ) and deleted = ''N''  '
			WHERE tablename = 'common_code'
	END

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('E3')
			) --External Facility---------------------------
	BEGIN
		INSERT INTO #mergeTables
		SELECT *
		FROM dbo.mergeTables
		WHERE tablename IN (
				'common_code'
				,'emc_ext_facilities'
				,'ext_facilities'
				,'client_ext_facilities'
				,'emc_ext_facilities_audit' -- Added by Mark Estey, July 23 2019: Update for 3.7.19.2
				)

		INSERT INTO #mergejoins
		SELECT *
		FROM mergejoins
		WHERE tablename IN (
				'emc_ext_facilities'
				,'ext_facilities'
				,'client_ext_facilities'
				,'emc_ext_facilities_audit' -- Added by Mark Estey, July 23 2019: Update for 3.7.19.2
				)

		IF EXISTS (
				SELECT 1
				FROM #tmpAllModulestoCopy
				WHERE moduleID IN (
						'E19a'
						,'E19b'
						)
				) --IRM---------------------------
		BEGIN
			INSERT INTO #mergeTables
			SELECT *
			FROM dbo.mergeTables
			WHERE tablename IN (
					'contact_relationship[ext001]'
					,'contact_type[ext001]'
					)

			INSERT INTO #mergejoins
			SELECT *
			FROM mergejoins
			WHERE tablename IN (
					'contact_relationship[ext001]'
					,'contact_type[ext001]'
					)

			--AND hotlist_item = ''Y''
			--				update mergetables set QueryFilter= ' AND (    ext_fac_id IN (SELECT ext_fac_id FROM  [origDB].ext_facilities WHERE fac_id=[OrigFacId] ) 
			--															OR ext_fac_id IN (SELECT  adt_tofrom_loc_id * -1  FROM  [origDB].census_item WHERE fac_id=[OrigFacId]) 
			--															OR ext_fac_id in (SELECT   reference_id  from [origDB].contact_relationship where  
			--																			 subclass_id in (select item_id from [origDB].common_code where item_code = ''sbclas'' 
			--																			 and item_description = ''Professional''))) ' 
			--				where tablename='emc_ext_facilities';
			--CommonCode 
			--Modified By: Linlin Jing, Date: 2018-01-12, Reason: Check smartsheet Update EI Script Row 48. start
			UPDATE mergeTables
			SET QueryFilter = ' AND item_id in  ((SELECT isnull(country_id,-1) FROM [origDB].emc_ext_facilities WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'' AND (ext_fac_id IN (SELECT ext_fac_id FROM  [origDB].client_ext_facilities ) OR ext_fac_id IN (SELECT  adt_tofrom_loc_id * -1  FROM  [origDB].census_item WHERE fac_id=[OrigFacId])))  UNION (SELECT isnull(facility_type,-1) FROM [origDB].emc_ext_facilities WHERE  DELETED=''N'' AND (ext_fac_id IN (SELECT ext_fac_id FROM  [origDB].client_ext_facilities  ) OR ext_fac_id IN (SELECT  adt_tofrom_loc_id * -1  FROM  [origDB].census_item WHERE fac_id=[OrigFacId]) OR ext_fac_id IN (SELECT reporting_lab_ext_fac_id FROM [origDB].result_order_source WHERE fac_id = [OrigFacId]) )) ) and deleted = ''N''  '
			WHERE tablename = 'common_code'
		END
		ELSE
		BEGIN
			--AND hotlist_item = ''Y''
			--				update mergetables set QueryFilter= ' AND (ext_fac_id IN (SELECT ext_fac_id FROM  [origDB].client_ext_facilities WHERE fac_id=[OrigFacId] ) OR ext_fac_id IN (SELECT  adt_tofrom_loc_id * -1  FROM  [origDB].census_item WHERE fac_id=[OrigFacId])) ' 
			--				where tablename='emc_ext_facilities';
			--CommonCode 
			UPDATE mergeTables
			SET QueryFilter = ' AND item_id in  ((SELECT isnull(country_id,-1) FROM [origDB].emc_ext_facilities WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'' AND (ext_fac_id IN (SELECT ext_fac_id FROM  [origDB].client_ext_facilities WHERE fac_id=[OrigFacId] ) OR ext_fac_id IN (SELECT  adt_tofrom_loc_id * -1  FROM  [origDB].census_item WHERE fac_id=[OrigFacId])))  UNION (SELECT isnull(facility_type,-1) FROM [origDB].emc_ext_facilities WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'' AND (ext_fac_id IN (SELECT ext_fac_id FROM  [origDB].client_ext_facilities WHERE fac_id=[OrigFacId] ) OR ext_fac_id IN (SELECT  adt_tofrom_loc_id * -1  FROM  [origDB].census_item WHERE fac_id=[OrigFacId]) OR ext_fac_id IN (SELECT reporting_lab_ext_fac_id FROM [origDB].result_order_source WHERE fac_id = [OrigFacId]))) ) and deleted = ''N''  '
			WHERE tablename = 'common_code'
				--Modified By: Linlin Jing, Date: 2018-01-12, Reason: Check smartsheet Update EI Script Row 48. end
		END
	END

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('E4')
			) --User Defined Data---------------------------
	BEGIN
		INSERT INTO #mergeTables
		SELECT *
		FROM dbo.mergeTables
		WHERE tablename IN (
				'user_field_types'
				,'user_defined_data'
				,'user_picklist_data'
				,'ar_collections_user_field_types'
				)

		INSERT INTO #mergejoins
		SELECT *
		FROM mergejoins
		WHERE tablename IN (
				'user_defined_data'
				,'user_picklist_data'
				,'ar_collections_user_field_types'
				)

		--		UPDATE mergeTables 
		--		SET QueryFilter = ' AND NOT exists (Select 1 from user_picklist_data b where field_type_id = b.field_type_id and description = b.description) '
		--		WHERE tablename = 'user_picklist_data'
		UPDATE mergeTables
		SET QueryFilter = ' AND field_type_id in (SELECT field_type_id from [origDB].user_defined_data where fac_id in ([OrigFacId],-1)  and client_id in (Select src_id from [stagDB].[prefix]clients)) '
		WHERE tablename = 'user_field_types'

		DELETE
		FROM mergejoins
		--select * from mergejoins
		WHERE parenttable = 'ar_collection_call'
			OR tablename = 'ar_collection_call' --12

		DELETE
		FROM mergeTables
		--select * from mergetables
		WHERE tablename = 'ar_collection_call' --1
	END

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('E5')
			) --Room and Bed---------------------------
	BEGIN
		IF @NewDB = 'Y'
		BEGIN
			DELETE
			FROM dbo.[floor]

			DELETE
			FROM dbo.[unit]
		END

		--Removed 'room_date_range', as by Rina on 07-March-2013
		INSERT INTO #mergeTables
		SELECT *
		FROM dbo.mergeTables
		WHERE tablename IN (
				'floor'
				,'unit'
				,'room'
				,'bed'
				,'bed_date_range'
				,'room_date_range'
				,'common_code'
				-- Added By: Jaspreet Singh, Date: 2017-06-06, Reason: Check smartsheet Update EI Script Row 24
				,'common_code_activation'
				)

		INSERT INTO #mergejoins
		SELECT *
		FROM mergejoins
		WHERE tablename IN (
				'room'
				,'bed'
				,'bed_date_range'
				,'room_date_range'
				,'common_code'
				-- Added By: Jaspreet Singh, Date: 2017-06-06, Reason: Check smartsheet Update EI Script Row 24
				,'common_code_activation'
				)

		--common code
		--		UPDATE mergeTables SET QueryFilter = '  AND item_id in  ( (SELECT isnull(ACCOMMODATION_ID,-1) FROM [origDB].room_date_range WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')) and deleted = ''N'' ' 
		--		WHERE tablename = 'common_code'
		UPDATE mergeTables
		SET --QueryFilter = ' AND bed_desc IN (SELECT bed_desc FROM [destDB].bed where deleted = ''N'' and fac_id =1) ',
			scopeField1 = NULL
			,scopeField2 = NULL
		WHERE tablename = 'bed'

		--For testing
		DELETE
		FROM mergejoins
		WHERE parenttable IN ('ar_lib_rate_type')

		UPDATE mergeTables
		SET QueryFilter = '  AND item_id in  ( (SELECT isnull(accommodation_id,-1) FROM [origDB].room_date_range WHERE deleted=''N'' and accommodation_id is not NULL and room_id in (SELECT room_id FROM [origDB].room WHERE fac_id in ([OrigFacId],-1) AND deleted=''N'')) ) and deleted = ''N'' '
		WHERE tablename = 'common_code'
			--		INSERT INTO #mergeTables
			--		SELECT * from dbo.mergeTables where tablename in ('room_date_range','ar_lib_rate_type','ar_rate_type','ar_rate_type_category')
			--
			--		INSERT INTO #mergejoins
			--		SELECT * from mergejoins where tablename in ('room_date_range','ar_lib_rate_type','ar_rate_type','ar_rate_type_category')
	END

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('E6')
			) --Census---------------------------
	BEGIN
		INSERT INTO #mergeTables
		SELECT *
		FROM dbo.mergeTables
		WHERE tablename IN (
				'common_code'
				,'census_codes'
				,'census_item'
				,'adt_client_loc'
				,'census_hospital_transfer'
				,'census_hospital_transfer_qi_review_not_required_mapping'
				----,'census_default_medicaid_payer_rate_info'  Commented By: Jaspreet Singh, Date: 2018/11/21, Reason: Smartsheet Update E/I Line 66
				,'census_item_secondary_bed'
				,'census_item_secondary_rate'
				,'prot_client_action'
				,'prot_std_protocol_detail'
				-- Added By: Jaspreet Singh, Date: 2017-06-06, Reason: Check smartsheet Update EI Script Row 24
				,'common_code_activation'
				-- Added By: Jaspreet Singh, Date: 12/29/2020, Reason: Nigel email at 12/29/2020
				,'census_item_bed_management'
				,'census_item_audit'
				)

		INSERT INTO #mergejoins
		SELECT *
		FROM mergejoins
		WHERE tablename IN (
				'census_codes'
				,'census_item'
				,'adt_client_loc'
				,'census_hospital_transfer'
				,'census_hospital_transfer_qi_review_not_required_mapping'
				----,'census_default_medicaid_payer_rate_info'  Commented By: Jaspreet Singh, Date: 2018/11/21, Reason: Smartsheet Update E/I Line 66
				,'census_item_secondary_bed'
				,'census_item_secondary_rate'
				,'prot_client_action'
				,'prot_std_protocol_detail'
				-- Added By: Jaspreet Singh, Date: 2017-06-06, Reason: Check smartsheet Update EI Script Row 24
				,'common_code'
				,'common_code_activation'
				-- Added By: Jaspreet Singh, Date: 12/29/2020, Reason: Nigel email at 12/29/2020
				,'census_item_bed_management'
				,'census_item_audit'
				)

		/*
		Added By: Jaspreet Singh
		Date: 08-18-2016
		Purpose: Include external facilities related tables. If external facilities module is not checked.
		*/
		IF NOT EXISTS (
				SELECT 1
				FROM #tmpAllModulestoCopy
				WHERE moduleID IN ('E3')
				) -----------External Facilities is not checked
		BEGIN
			INSERT INTO #mergeTables
			SELECT *
			FROM dbo.mergeTables
			WHERE tablename IN (
					'emc_ext_facilities'
					,'ext_facilities'
					,'client_ext_facilities'
					)

			INSERT INTO #mergejoins
			SELECT *
			FROM mergejoins
			WHERE tablename IN (
					'emc_ext_facilities'
					,'ext_facilities'
					,'client_ext_facilities'
					)

			-- Start Change by: Mark Estey, 2019-02-22, Reason: Smartsheet Line # 69 - Always copy External Facilities linked to Census, Orders, or Lab/Radiology when selected
			/*
			UPDATE mergeTables
			SET QueryFilter = ' AND ext_fac_id in (select adt_tofrom_loc_id*-1 from [origdb].census_item where adt_tofrom_loc_id is not NULL and fac_id = [OrigFacId])'
			WHERE tablename = 'emc_ext_facilities'
            */
			DECLARE @ext_fac_id_filter VARCHAR(5000) = NULL

			IF EXISTS (
					SELECT 1
					FROM #tmpAllModulestoCopy
					WHERE moduleID IN ('E6')
					) -- If Census is selected
				SET @ext_fac_id_filter = COALESCE(@ext_fac_id_filter + ' UNION SELECT adt_tofrom_loc_id*-1 FROM [origdb].census_item WHERE adt_tofrom_loc_id IS NOT NULL AND fac_id = [OrigFacId]', 'SELECT adt_tofrom_loc_id*-1 FROM [origdb].census_item WHERE adt_tofrom_loc_id IS NOT NULL AND fac_id = [OrigFacId]')

			IF EXISTS (
					SELECT 1
					FROM #tmpAllModulestoCopy
					WHERE moduleID IN ('E13')
					) -- If Orders is selected
				SET @ext_fac_id_filter = COALESCE(@ext_fac_id_filter + ' UNION SELECT pharmacy_id FROM [origdb].pho_phys_order WHERE pharmacy_id > 0 AND fac_id = [OrigFacId]', 'SELECT pharmacy_id FROM [origdb].pho_phys_order WHERE pharmacy_id > 0 AND fac_id = [OrigFacId]')

			IF EXISTS (
					SELECT 1
					FROM #tmpAllModulestoCopy
					WHERE moduleID IN ('E21')
					) -- If Lab & Radiology is selected
				SET @ext_fac_id_filter = COALESCE(@ext_fac_id_filter + ' UNION SELECT reporting_lab_ext_fac_id FROM [origdb].result_order_source WHERE fac_id = [OrigFacId]', 'SELECT reporting_lab_ext_fac_id FROM [origdb].result_order_source WHERE fac_id = [OrigFacId]')

			UPDATE mergeTables
			SET QueryFilter = ' AND ext_fac_id IN (' + @ext_fac_id_filter + ')'
			WHERE tablename = 'emc_ext_facilities'
				-- End Change by: Mark Estey, 2019-02-22, Reason: Smartsheet Line # 69 - Always copy External Facilities linked to Census, Orders, or Lab/Radiology when selected
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'bed'
				) --No Room and Bed---------------------------
		BEGIN
			DELETE
			FROM mergejoins
			WHERE tablename = 'census_item'
				AND parenttable = 'bed'
		END

		----Added by: Linlin Jing, Date2018-06-20, Reason: Rina's email with subject 'ar_flexible_rate_rule error message', start
		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'ar_flexible_rate_rule'
				) --No Room and Bed---------------------------
		BEGIN
			DELETE
			FROM mergejoins
			WHERE tablename = 'census_item'
				AND parenttable = 'ar_flexible_rate_rule'
		END

		----Added by: Linlin Jing, Date2018-06-20, Reason: Rina's email with subject 'ar_flexible_rate_rule error message', end
		----Added by: Linlin Jing, Date2018-06-20, Reason: Rina's email with subject 'HIGH: census_item_flexible_rate error and  email_alert_subscription', start
		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'census_item_flexible_rate'
				) --No Room and Bed---------------------------
		BEGIN
			DELETE
			FROM mergejoins
			WHERE tablename = 'census_item'
				AND parenttable = 'census_item_flexible_rate'
		END

		----Added by: Linlin Jing, Date2018-06-20, Reason: Rina's email with subject 'HIGH: census_item_flexible_rate error and  email_alert_subscription', end
		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND (
						Table_Name = @caseNo + 'prot_std_protocol_config'
						OR Table_Name = @caseNo + 'prot_std_event'
						OR Table_Name = @caseNo + 'prot_std_action'
						)
				)
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable IN (
					'prot_std_protocol_config'
					,'prot_std_event'
					,'prot_std_action'
					)
		END

		UPDATE mergeTables
		SET QueryFilter = '  AND item_id in  ( (SELECT isnull(ADT_TOFROM_ID,-1) FROM [origDB].census_item WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(adt_tofrom_loc_id,-1) FROM [origDB].census_item WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')) and deleted = ''N'' '
		WHERE tablename = 'common_code'

		UPDATE mergeTables
		SET QueryFilter = '  AND item_id in  ( (SELECT isnull(action_code_id,-1) FROM [origDB].census_item WHERE fac_id = [OrigFacId] AND DELETED=''N'')  UNION (SELECT isnull(STATUS_CODE_ID,-1) FROM [origDB].census_item WHERE fac_id = [OrigFacId] AND DELETED=''N'')) and deleted = ''N'' '
		WHERE tablename = 'census_codes'

		DELETE
		FROM mergejoins
		WHERE parenttable IN (
				'ar_lib_payers'
				,'ar_date_range'
				,'ar_eff_rate_schedule'
				,'ar_lib_accounts'
				,'as_assessment'
				)
			--alter table census_item nocheck CONSTRAINT  all
	END

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('E7')
			) --MDS 2.0, MDS 3, Custom UDA---------------------------
	BEGIN
		SET @sql = 'IF NOT EXISTS (SELECT  1 FROM ' + convert(VARCHAR(50), @CaseNo) + 'clients where src_id = -9999) INSERT INTO ' + convert(VARCHAR(50), @CaseNo) + 'clients (src_id,dst_id) values(-9999,-9999);'

		EXEC (@sql)

		INSERT INTO #mergeTables
		SELECT *
		FROM dbo.mergeTables
		WHERE tablename IN (
				'AS_STD_ASSESSMENT'
				,'AS_STD_SECTION'
				,'as_std_pick_list'
				,'as_std_pick_list_item'
				,'as_std_question_group'
				,'as_std_question'
				,'AS_STD_ASSESS_TYPE'
				,'as_std_score'
				,'as_std_rap'
				,'as_std_score_item'
				,'as_std_assess_header'
				,'as_std_category'
				,'as_std_profile_consistency'
				,'as_batch'
				,'as_assessment'
				,'as_assessment_error'
				,'as_assessment_section'
				,'as_footnote'
				,'as_mds_analytics'
				,'as_ard_planner'
				,'as_ard_adl'
				,'as_response'
				,'as_response_history'
				,'as_rap_profile_response'
				,'as_assessment_rap'
				,'as_assess_raps_trig'
				,'as_assessment_score'
				,'as_batch_assess'
				,'as_hcfa802'
				,'as_hcfa802data'
				,'as_hcfa802data_v0412'
				,'as_ard_adl_keys'
				,'as_ard_extensive_services'
				,'as_ard_therapy_minutes'
				,'as_std_assess_schedule'
				,'as_assess_census'
				,'as_assess_footnote'
				,'as_assess_schedule'
				,'as_std_trigger'
				,'as_assess_schedule_details'
				,'as_assessment_error_bkup'
				,'as_cms672'
				,'as_cms672data'
				,'as_cms672data_v0412'
				,'as_consistency_rule'
				,'as_consistency_rule_range'
				,'as_irf_MSA'
				,'as_irf_ric'
				,'as_irf_tier'
				,'as_irfric_cost'
				,'as_log_verify'
				,'as_std_legend'
				,'as_std_legend_item'
				,'as_std_lookback_question'
				,'as_std_question_submit'
				,'as_std_rap_question'
				,'as_std_rug_model'
				,'as_std_rug_cat'
				,'as_std_rug_code'
				,'assign_group_id_cleanup'
				,'assign_id_cleanup'
				,'as_batch_extract'
				,'as_batch_assess_extract'
				,'as_std_mds_kardex_question'
				,'as_mds_kardex_response'
				,'as_mds3_resident_header_info'
				,'as_assessment_schedule_date'
				,'as_caa_icon_mds_30_map'
				,'as_caa_trigger_condition_mds_30_map'
				,'as_std_assessment_type_mds_30_map'
				,'as_std_question_assessment_type_active_date_range'
				,'as_std_question_state_code'
				,'as_std_rap_mds_question'
				,'as_std_rap_trig_questions_mds_30_map'
				,'as_std_rap_triggering_question'
				,'common_code'
				-- Added By: Jaspreet Singh, Date: 2017-06-06, Reason: Check smartsheet Update EI Script Row 24
				,'common_code_activation'
				,'id_type'
				,'clients_mds'
				,'as_assessment_audit'
				,'as_mds_analytics_v2'
				,'cp_sec_user_audit'
				,'as_assess_schedule_clear_response'
				,'as_da_analytics_extract_staging'
				,'qlib_question'
				,'pn_template'
				,'pn_template_section'
				,'pn_type'
				,'pn_std_spn'
				,'pn_std_spn_text'
				,'pn_std_spn_variable'
				,'pn_spn_narrative_response'
				,'as_response_trigger_item'
				,'census_item_assessment_info'
				,'as_service_change_approval_status'
				,'as_response_trigger_item_audit'
				,'as_service_change_approval_form'
				,'as_service_change_approval_form_audit'
				,'as_service_change_detail'
				,'as_service_change_detail_audit'
				,'as_service_change_notification'
				,'as_service_change_notification_audit'
				,'as_service_change_notification_service_level_snapshot'
				,'as_service_change_notification_validation_error'
				,'as_std_category_audit'
				,'census_hospital_transfer_as_assessment_mapping'
				,'as_assessment_insurance_rug'
				,'as_std_assess_version_group'
				,'as_std_assess_version_group_item'
				,'as_std_assessment_facility'
				,'as_std_pick_list_item_value_qlib_form_field_mapping'
				,'as_std_question_qlib_form_question_mapping'
				,'as_std_question_qlib_question_autopopulate_rule_mapping'
				,'qlib_pick_list'
				,'qlib_pick_list_item'
				,'qlib_pick_list_item_mapping'
				,'qlib_question_text'
				,'as_response_collection'
				,'as_response_collection_audit'
				--,'as_std_assessment_system_assessment_mapping'
				,'as_assessment_lock_history'
				-- Added By: Linlin Jing, Date: 2017-11-03, Reason: Check Rina email for 3.7.14
				,'as_std_assess_schedule_payer_type_mapping'
				,'as_std_assessment_copy_relation'
				-- Added By: Linlin Jing, Date: 2018-03-08, Reason: Check Rina email for 3.7.15
				,'as_assessment_validation'
				,'as_assessment_validation_action'
				,'as_assessment_validation_question'
				,'as_mds_validation_rule'
				,'as_mds_validation_rule_date_range'
				--Added by: Linlin jing, Date: 2018-03-12, Reason: Rina's email on 2018-03-12
				,'as_hcfa802data_v0817'
				-- Added By: Linlin Jing, Date: 2018-06-19, Reason: Check Rina email for 3.7.15.3
				,'as_std_mds_version'
				-- Added By: Mark Estey, Date: 2019-01-22, Reason: Updates to 3.7.17.3 Smartsheet Line 68
				,'as_std_rap_history'
				,'as_std_rap_question_history'
				,'as_assessment_pdpm'
				-- Added By: Mark Estey, Date: 2019-04-12, Reason: Smartsheet Line 70, New PDPM tables
				,'as_response_pdpm_transition'
				,'as_assessment_pdpm_comorbidit_nta'
				,'as_assessment_pdpm_comorbidit_slp'
				,'as_std_assess_schedule_custom_configuration' -- Added by Mark Estey, July 23 2019: Update for 3.7.19.2
				-- Added By: Jaspreet Singh, Date: 2020-06-29, Reason: Nigel email, Subject: Update on Data Copy to Existing Script - Add Table - as_assessment_lineage
				,'as_assessment_lineage'
				)

		--************Added By: Jaspreet Singh, Date: 2014-04-12, Reason: Check Rina email for 3.7.12
		--************Commented By: Jaspreet Singh, Date: 2014-05-10, Reason: Check spreadsheet Update EI script (#14)
		--,'as_assessment_file_mapping'
		--,'as_assessment_group'
		--,'as_assessment_to_group_mapping'
		--,'as_std_question_lookback_window'
		-- ,'as_std_assess_type_code_map'
		INSERT INTO #mergejoins
		SELECT *
		FROM mergejoins
		WHERE tablename IN (
				'AS_STD_ASSESSMENT'
				,'AS_STD_SECTION'
				,'as_std_pick_list'
				,'as_std_pick_list_item'
				,'as_std_question_group'
				,'as_std_question'
				,'AS_STD_ASSESS_TYPE'
				,'as_std_score'
				,'as_std_rap'
				,'as_std_score_item'
				,'as_std_assess_header'
				,'as_std_category'
				,'as_std_profile_consistency'
				,'as_batch'
				,'as_assessment'
				,'as_assessment_error'
				,'as_assessment_section'
				,'as_footnote'
				,'as_mds_analytics'
				,'as_ard_planner'
				,'as_ard_adl'
				,'as_response'
				,'as_response_history'
				,'as_rap_profile_response'
				,'as_assessment_rap'
				,'as_assess_raps_trig'
				,'as_assessment_score'
				,'as_batch_assess'
				,'as_hcfa802'
				,'as_hcfa802data'
				,'as_hcfa802data_v0412'
				,'as_ard_adl_keys'
				,'as_ard_extensive_services'
				,'as_ard_therapy_minutes'
				,'as_std_assess_schedule'
				,'as_assess_census'
				,'as_assess_footnote'
				,'as_assess_schedule'
				,'as_std_trigger'
				,'as_assess_schedule_details'
				,'as_assessment_error_bkup'
				,'as_consistency_rule'
				,'as_consistency_rule_range'
				,'as_irf_MSA'
				,'as_irf_ric'
				,'as_irf_tier'
				,'as_irfric_cost'
				,'as_log_verify'
				,'as_std_legend'
				,'as_std_legend_item'
				,'as_std_lookback_question'
				,'as_std_question_submit'
				,'as_std_rap_question'
				,'as_std_rug_model'
				,'as_std_rug_cat'
				,'as_std_rug_code'
				,'assign_group_id_cleanup'
				,'assign_id_cleanup'
				,'as_batch_extract'
				,'as_batch_assess_extract'
				,'as_std_mds_kardex_question'
				,'as_mds_kardex_response'
				,'as_mds3_resident_header_info'
				,'as_assessment_schedule_date'
				,'as_caa_icon_mds_30_map'
				,'as_caa_trigger_condition_mds_30_map'
				,'as_std_assessment_type_mds_30_map'
				,'as_std_question_assessment_type_active_date_range'
				,'as_std_question_state_code'
				,'as_std_rap_mds_question'
				,'as_std_rap_trig_questions_mds_30_map'
				,'as_std_rap_triggering_question'
				,'clients_mds'
				,'as_assessment_audit'
				,'as_cms672data'
				,'as_cms672data_v0412'
				,'as_mds_analytics_v2'
				,'cp_sec_user_audit'
				,'as_assess_schedule_clear_response'
				,'as_da_analytics_extract_staging'
				,'qlib_question'
				,'pn_template'
				,'pn_template_section'
				,'pn_type'
				,'pn_std_spn'
				,'pn_std_spn_text'
				,'pn_std_spn_variable'
				,'pn_spn_narrative_response'
				,'as_response_trigger_item'
				,'census_item_assessment_info'
				,'as_service_change_approval_status'
				,'as_response_trigger_item_audit'
				,'as_service_change_approval_form'
				,'as_service_change_approval_form_audit'
				,'as_service_change_detail'
				,'as_service_change_detail_audit'
				,'as_service_change_notification'
				,'as_service_change_notification_audit'
				,'as_service_change_notification_service_level_snapshot'
				,'as_service_change_notification_validation_error'
				,'as_std_category_audit'
				,'census_hospital_transfer_as_assessment_mapping'
				,'as_assessment_insurance_rug'
				,'as_std_assess_version_group'
				,'as_std_assess_version_group_item'
				,'as_std_assessment_facility'
				,'as_std_pick_list_item_value_qlib_form_field_mapping'
				,'as_std_question_qlib_form_question_mapping'
				,'as_std_question_qlib_question_autopopulate_rule_mapping'
				,'qlib_pick_list'
				,'qlib_pick_list_item'
				,'qlib_pick_list_item_mapping'
				,'qlib_question_text'
				,'as_response_collection'
				,'as_response_collection_audit'
				--,'as_std_assessment_system_assessment_mapping'
				,'as_assessment_lock_history'
				-- Added By: Jaspreet Singh, Date: 2017-06-06, Reason: Check smartsheet Update EI Script Row 24
				,'common_code'
				,'common_code_activation'
				-- Added By: Linlin Jing, Date: 2017-11-03, Reason: Check Rina email for 3.7.14
				,'as_std_assess_schedule_payer_type_mapping'
				,'as_std_assessment_copy_relation'
				-- Added By: Linlin Jing, Date: 2018-03-08, Reason: Check Rina email for 3.7.15
				,'as_assessment_validation'
				,'as_assessment_validation_action'
				,'as_assessment_validation_question'
				,'as_mds_validation_rule'
				,'as_mds_validation_rule_date_range'
				--Added by: Linlin jing, Date: 2018-03-12, Reason: Rina's email on 2018-03-12
				,'as_hcfa802data_v0817'
				-- Added By: Linlin Jing, Date: 2018-06-19, Reason: Check Rina email for 3.7.15.3
				,'as_std_mds_version'
				-- Added By: Mark Estey, Date: 2019-01-22, Reason: Updates to 3.7.17.3 Smartsheet Line 68
				,'as_std_rap_history'
				,'as_std_rap_question_history'
				,'as_assessment_pdpm'
				-- Added By: Mark Estey, Date: 2019-04-12, Reason: Smartsheet Line 70, New PDPM tables
				,'as_response_pdpm_transition'
				,'as_assessment_pdpm_comorbidit_nta'
				,'as_assessment_pdpm_comorbidit_slp'
				,'as_std_assess_schedule_custom_configuration' -- Added by Mark Estey, July 23 2019: Update for 3.7.19.2
				-- Added By: Jaspreet Singh, Date: 2020-06-29, Reason: Nigel email, Subject: Update on Data Copy to Existing Script - Add Table - as_assessment_lineage
				,'as_assessment_lineage'
				)

		--Added By: Linlin Jing, Date: 2018-01-08, Reason: Check smartsheet Update EI Script Row 47. start
		UPDATE mergeTables
		SET QueryFilter = '  where std_assess_id in  ( 
				SELECT src_id
				FROM [stagDB].[prefix]as_std_assessment
				WHERE corporate = ''N''
				)'
		WHERE tablename = 'as_std_assessment_copy_relation'

		--Added By: Linlin Jing, Date: 2018-01-08, Reason: Check smartsheet Update EI Script Row 47. end
		--added on Nov 24, 2017 as per Rina
		UPDATE mergeTables
		SET QueryFilter = '  AND pick_list_id in  ( 
				SELECT src_id
				FROM [stagDB].[prefix]as_std_pick_list 
				WHERE corporate = ''N''
				)'
		WHERE tablename = 'as_std_pick_list_item'

		--end added on Nov 24, 2017 as per Rina
		--************Added By: Jaspreet Singh, Date: 2014-04-12, Reason: Check Rina email for 3.7.12
		--************Commented By: Jaspreet Singh, Date: 2014-05-10, Reason: Check spreadsheet Update EI script (#14)
		--,'as_assessment_file_mapping'
		--,'as_assessment_group'
		--,'as_assessment_to_group_mapping'
		--,'as_std_question_lookback_window'
		-- ,'as_std_assess_type_code_map'
		DELETE
		FROM mergejoins
		WHERE tablename = 'as_mds3_resident_header_info'
			AND parenttable = 'ar_lib_payers'

		-- Added By: Jaspreet Singh, Date:2017-04-09, Reason: Check spreadsheet Update EI script #7 (Start)
		--DELETE
		--FROM mergejoins
		--WHERE tablename = 'as_std_assessment'
		--	AND parenttable = 'branded_library_configuration'
		-- Added By: Jaspreet Singh, Date:2017-04-09, Reason: Check spreadsheet Update EI script #7 (End)
		DELETE
		FROM mergejoins
		WHERE parenttable = 'branded_library_configuration'

		DELETE
		FROM mergejoins
		WHERE parenttable IN (
				'ar_lib_sbb_service_category'
				,'ar_lib_sbb_service_level'
				,'ar_sbb_service_change_approval_option'
				,'ar_sbb_service_change_effective_date_option'
				)

		--Commented below as per Rina on 04/04/2013
		--UPDATE mergetables SET scopeField1 = NULL,scopeField2 = NULL,scopeField3 = NULL WHERE tablename = 'AS_STD_ASSESSMENT'
		UPDATE mergeTables
		SET QueryFilter = '  AND item_id in  ( (SELECT isnull(item_id,-1) FROM [origDB].as_std_assess_header)  UNION (SELECT isnull(item_id,-1) FROM [origDB].as_consistency_rule WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N''))  and deleted = ''N'''
		WHERE tablename = 'common_code'

		--Added By: Jaspreet Singh , Date : 2016-04-20, Purpose : To add filter for as_std_assess_version_group, as_std_assess_version_group_item
		UPDATE mergeTables
		SET QueryFilter = '  AND std_assess_version_group_id in  ( 
		SELECT std_assess_version_group_id
FROM [origDB].[as_std_assess_version_group]
WHERE std_assess_version_group_id IN (
		SELECT std_assess_version_group_id
		FROM [origDB].as_std_assess_version_group_item
		WHERE std_assess_id IN (
				SELECT src_id
				FROM [stagDB].[prefix]as_std_assessment
				WHERE corporate = ''N''
				)
		)
		)'
		WHERE tablename = 'as_std_assess_version_group'

		UPDATE mergeTables
		SET QueryFilter = '  AND std_assess_id in  ( 
		SELECT std_assess_id
FROM [origDB].[as_std_assess_version_group_item]
WHERE std_assess_id IN (
		SELECT src_id
		FROM [stagDB].[prefix]as_std_assessment
		WHERE corporate = ''N''
		)
		)'
		WHERE tablename = 'as_std_assess_version_group_item'

		--Added By: Jaspreet Singh , Date : 2015-09-18, Purpose : To filter templates based on std_assess_id
		IF NOT EXISTS (
				SELECT 1
				FROM #tmpAllModulestoCopy
				WHERE moduleID IN ('E9')
				)
		BEGIN
			UPDATE mergeTables
			SET QueryFilter = '  AND template_id in  (SELECT template_id FROM [origDB].pn_type WHERE pn_type_id in (SELECT pn_type_id FROM [origDB].pn_std_spn WHERE std_assess_id in (SELECT dst_id FROM ' + CONVERT(VARCHAR(50), @CaseNo) + 'as_std_assessment)))'
			WHERE tablename = 'pn_template'

			-- Added By: Jaspreet Singh , Date : 2015-09-18, Purpose : To filter pn types based on std_assess_id
			UPDATE mergeTables
			SET QueryFilter = '  AND pn_type_id in  (SELECT pn_type_id FROM [origDB].pn_std_spn WHERE std_assess_id in (SELECT dst_id FROM ' + CONVERT(VARCHAR(50), @CaseNo) + 'as_std_assessment))'
			WHERE tablename = 'pn_type'
		END

		--MDS 2 and 3 and MMQ
		DECLARE @std_assess_id VARCHAR(100)
			,@incheck INT;

		SET @std_assess_id = '';
		SET @incheck = 0;

		IF EXISTS (
				SELECT 1
				FROM #tmpAllModulestoCopy
				WHERE moduleID IN ('E7c')
				)
			SET @incheck = 1

		IF @incheck = 1
		BEGIN
			IF NOT EXISTS (
					SELECT 1
					FROM #tmpAllModulestoCopy
					WHERE moduleID IN ('E7a')
					)
				IF @std_assess_id = ''
					SET @std_assess_id = '1'
				ELSE
					SET @std_assess_id = @std_assess_id + ',1'

			IF NOT EXISTS (
					SELECT 1
					FROM #tmpAllModulestoCopy
					WHERE moduleID IN ('E7b')
					)
				IF @std_assess_id = ''
					SET @std_assess_id = '11'
				ELSE
					SET @std_assess_id = @std_assess_id + ',11'

			IF NOT EXISTS (
					SELECT 1
					FROM #tmpAllModulestoCopy
					WHERE moduleID IN ('E7d')
					)
				IF @std_assess_id = ''
					SET @std_assess_id = '7'
				ELSE
					SET @std_assess_id = @std_assess_id + ',7'

			-- Added	:	Bipin Maliakal
			-- Reason	:	For the MMA Module
			-- Modified By: Jaspreet Singh
			-- Reason: To include historical MMA include std_assess_id = 8
			-- Begin
			IF NOT EXISTS (
					SELECT 1
					FROM #tmpAllModulestoCopy
					WHERE moduleID IN ('E7e')
					)
				IF @std_assess_id = ''
					SET @std_assess_id = '8,12'
				ELSE
					SET @std_assess_id = @std_assess_id + ',8,12'

			-- End
			IF @std_assess_id <> ''
				UPDATE mergeTables
				SET QueryFilter = QueryFilter + ' AND std_assess_id NOT IN (' + @std_assess_id + ')'
				WHERE tablename = 'AS_STD_ASSESSMENT' ---1/13 Added QueryFilter +
		END
		ELSE
		BEGIN
			IF EXISTS (
					SELECT 1
					FROM #tmpAllModulestoCopy
					WHERE moduleID IN ('E7a')
					)
				IF @std_assess_id = ''
					SET @std_assess_id = '1'
				ELSE
					SET @std_assess_id = @std_assess_id + ',1'

			IF EXISTS (
					SELECT 1
					FROM #tmpAllModulestoCopy
					WHERE moduleID IN ('E7b')
					)
				IF @std_assess_id = ''
					SET @std_assess_id = '11'
				ELSE
					SET @std_assess_id = @std_assess_id + ',11'

			IF EXISTS (
					SELECT 1
					FROM #tmpAllModulestoCopy
					WHERE moduleID IN ('E7d')
					)
				IF @std_assess_id = ''
					SET @std_assess_id = '7'
				ELSE
					SET @std_assess_id = @std_assess_id + ',7'

			-- Added	:	Bipin Maliakal
			-- Reason	:	For the MMA Module
			-- Modified By: Jaspreet Singh
			-- Reason: To include historical MMA include std_assess_id = 8
			--------------------- Begin  --------------------------------------
			IF EXISTS (
					SELECT 1
					FROM #tmpAllModulestoCopy
					WHERE moduleID IN ('E7e')
					)
				IF @std_assess_id = ''
					SET @std_assess_id = '8,12'
				ELSE
					SET @std_assess_id = @std_assess_id + ',8,12'

			---------------------End------------------------------------------------------------------
			IF @std_assess_id <> ''
				UPDATE mergeTables
				SET QueryFilter = QueryFilter + ' AND std_assess_id IN (' + @std_assess_id + ')'
				WHERE tablename = 'AS_STD_ASSESSMENT' ----1/13 Added QueryFilter +
		END

		/*
		Added By: Jaspreet Singh
		Date: 2016-08-17
		Purpose: EI script should only copy over qlib tables when UDA module is part of the EI. 
		*/
		IF EXISTS (
				SELECT 1
				FROM #tmpAllModulestoCopy
				WHERE moduleID IN (
						'E7a' -- MDS2
						,'E7b' -- MDS3
						,'E7d' -- MMQ
						,'E7e' -- MMA
						)
				)
		BEGIN
			IF NOT EXISTS (
					SELECT 1
					FROM #tmpAllModulestoCopy
					WHERE moduleID IN ('E7c') -- Custom UDA
					)
			BEGIN
				DELETE
				FROM mergeTables
				WHERE tablename IN (
						'qlib_pick_list'
						,'qlib_pick_list_item'
						,'qlib_pick_list_item_mapping'
						,'qlib_question'
						,'qlib_question_text'
						)

				DELETE
				FROM mergeJoins
				WHERE tablename IN (
						'qlib_pick_list'
						,'qlib_pick_list_item'
						,'qlib_pick_list_item_mapping'
						,'qlib_question'
						,'qlib_question_text'
						)

				DELETE
				FROM mergeJoins
				WHERE parenttable IN (
						'qlib_pick_list'
						,'qlib_pick_list_item'
						,'qlib_pick_list_item_mapping'
						,'qlib_question'
						,'qlib_question_text'
						)
			END
		END

		--		UPDATE mergejoins SET pkjoin='Y' WHERE tablename='as_assessment' and parenttable in ('clients','AS_STD_ASSESSMENT')
		UPDATE mergejoins
		SET pkjoin = 'Y'
		WHERE tablename = 'as_assess_schedule'
			AND parenttable IN ('as_std_assessment')

		UPDATE mergejoins
		SET pkjoin = 'Y'
		WHERE tablename = 'as_assess_schedule_details'
			AND parenttable IN (
				'as_std_assessment'
				,'as_assess_schedule'
				)

		UPDATE mergejoins
		SET pkjoin = 'Y'
		WHERE tablename = 'as_assessment'
			AND parenttable IN ('clients')

		--??UPDATE mergetables set istrigger='N' where istrigger='Y' 
		--UPDATE mergeTables  SET QueryFilter = QueryFilter + ' AND assess_id IN (SELECT src_id from EICase'  +  convert(varchar(50),@CaseNo)  + 'as_assessment )'
		--     	WHERE tablename='as_response'
		UPDATE mergeTables
		SET QueryFilter = ISNULL(QueryFilter, '') + '  AND deleted = ''N'' '
		WHERE tablename = 'as_std_score'

		--added 2014-04-23
		UPDATE mergeTables
		SET QueryFilter = ISNULL(QueryFilter, '') + ' and (pick_list_id in (select pick_list_id from [origDB].as_std_question where pick_list_id is not NULL and std_assess_id in (select src_id FROM [stagDB].[prefix]as_std_assessment)) or pick_list_id in (select pick_list_id from [origDB].as_std_rap_question where pick_list_id is not NULL and std_rap_id in (select std_rap_id from [origDB].as_std_rap where std_assess_id in (select src_id FROM [stagDB].[prefix]as_std_assessment)))) '
		WHERE tablename = 'as_std_pick_list'

		-- Added By: Jaspreet Singh, Date 2016-02-10, Purpose: For system uda's
		UPDATE mergeTables
		SET QueryFilter = ISNULL(QueryFilter, '') + '  AND std_assess_id NOT IN ( (SELECT std_assess_id FROM [origDB].as_std_assessment_system_assessment_mapping )) '
		WHERE tablename = 'as_std_assessment'
	END

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('E8')
			) --Diagnosis---------------------------
	BEGIN
		INSERT INTO #mergeTables
		SELECT *
		FROM dbo.mergeTables
		WHERE tablename IN (
				'diagnosis_codes'
				,'diagnosis'
				,'common_code'
				-- Added By: Jaspreet Singh, Date: 2017-06-06, Reason: Check smartsheet Update EI Script Row 24
				,'common_code_activation'
				,'diagnosis_sheet'
				,'diagnosis_notification'
				,'diagnosis_strikeout'
				)

		INSERT INTO #mergejoins
		SELECT *
		FROM mergejoins
		WHERE tablename IN (
				'diagnosis_codes'
				,'diagnosis'
				,'diagnosis_sheet'
				,'diagnosis_notification'
				,'diagnosis_strikeout'
				-- Added By: Jaspreet Singh, Date: 2017-06-06, Reason: Check smartsheet Update EI Script Row 24
				,'common_code'
				,'common_code_activation'
				)

		UPDATE mergeTables
		SET QueryFilter = '  AND item_id in  (  (SELECT isnull(diag_lib_id,-1) FROM [origDB].diagnosis_codes WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(diag_classification_id,-1) FROM [origDB].diagnosis WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(rank_id,-1) FROM [origDB].diagnosis WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'') UNION (SELECT isnull(strikeout_reason_id,-1) FROM [origDB].diagnosis_strikeout))  and deleted = ''N''  '
		WHERE tablename = 'common_code'

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'diagnosis_poa_indicator'
				) --No pho_schedule_details---------------------------
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable = 'diagnosis_poa_indicator'
		END

		--IF MDS 2.0 and MDS 3.0 are SELECTED ONLY ADD THIS CODE
		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'as_assessment'
				) --No as_assessment---------------------------
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable = 'as_assessment'
		END

		UPDATE mergejoins
		SET pkjoin = 'Y'
		WHERE tablename = 'diagnosis_notification'
			AND parenttable IN ('clients')
	END

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('E9')
			) --Progress Note---------------------------
	BEGIN
		INSERT INTO #mergeTables
		SELECT *
		FROM dbo.mergeTables
		WHERE tablename IN (
				'pn_template'
				,'pn_template_section'
				,'common_code'
				-- Added By: Jaspreet Singh, Date: 2017-06-06, Reason: Check smartsheet Update EI Script Row 24
				,'common_code_activation'
				,'pn_type'
				,'pn_progress_note'
				,'pn_text'
				,'pn_std_spn'
				,'pn_std_spn_variable'
				,'pn_spn_narrative_response'
				,'pn_progress_note_link'
				,'pn_assess_Spn'
				,'cp_progressnote'
				--************Added BY: Jaspreet Singh: Date: 2017-04-12, Reason: Check Rina email for 3.7.12
				,'pn_type_activation'
				,'pn_type_activation_audit'
				)

		--remove cp tables from above ('cp_std_library','cp_std_need_cat','cp_std_need')--Katheleen
		--remove 'department_position' --Rina (25-Oct-2013)
		INSERT INTO #mergejoins
		SELECT *
		FROM mergejoins
		WHERE tablename IN (
				'pn_template_section'
				,'pn_type'
				,'pn_progress_note'
				,'pn_text'
				,'pn_std_spn'
				,'pn_std_spn_variable'
				,'pn_spn_narrative_response'
				,'pn_progress_note_link'
				,'pn_assess_Spn'
				,'cp_progressnote'
				--************Added BY: Jaspreet Singh: Date: 2017-04-12, Reason: Check Rina email for 3.7.12
				,'pn_type_activation'
				,'pn_type_activation_audit'
				-- Added By: Jaspreet Singh, Date: 2017-06-06, Reason: Check smartsheet Update EI Script Row 24
				,'common_code'
				,'common_code_activation'
				)

		/*
		Modified By Jaspreet Singh, 
		Date:2017-02-28
		Purpose: dont copy data for pn_progress_note_upload_file If we are not copying Online documentation
		*/
		IF NOT EXISTS (
				SELECT 1
				FROM #tmpAllModulestoCopy
				WHERE moduleID IN ('E20')
				)
		BEGIN
			DELETE
			FROM mergeTables
			WHERE tablename = 'pn_progress_note_upload_file'
				--select *
				--FROM [usc1\pcc_conv2005_1].ds_merge_master.dbo.mergeTables
				--WHERE tablename = 'pn_progress_note_upload_file'
		END

		/*end here*/
		IF EXISTS (
				SELECT 1
				FROM #tmpAllModulestoCopy
				WHERE moduleID IN ('E12b')
				)
		BEGIN
			INSERT INTO #mergeTables
			SELECT *
			FROM dbo.mergeTables
			WHERE tablename IN (
					'cp_rev_need'
					,'cp_std_need'
					)

			INSERT INTO #mergejoins
			SELECT *
			FROM mergejoins
			WHERE tablename IN (
					'cp_rev_need'
					,'cp_std_need'
					)
		END
		ELSE
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable = 'cp_rev_need'

			DELETE
			FROM mergejoins
			WHERE parenttable = 'cp_std_need'
		END

		DELETE
		FROM mergejoins
		WHERE parenttable = 'cp_std_need_cat'

		--need_id join in pn_progress_ntoe  is with cp_rev_need	--Katheleen
		--std_need_id join in pn_progress_note is with cp_std_need--Katheleen
		--this should go to the end --Katheleen
		--1 no care plan librarys then std_need_id and need_id should be null--Katheleen
		--2  we are copying care plan libraries then use joins mentioned above--Katheleen
		UPDATE mergeTables
		SET QueryFilter = '  AND item_id in  ( (SELECT isnull(dept1,-1) FROM [origDB].cp_std_need WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(dept2,-1) FROM [origDB].cp_std_need WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(dept3,-1) FROM [origDB].cp_std_need WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(dept4,-1) FROM [origDB].cp_std_need WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(dept5,-1) FROM [origDB].cp_std_need WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(strikeout_id,-1) FROM [origDB].pn_progress_note WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(position_id,-1) FROM [origDB].pn_progress_note WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')) and deleted = ''N'' '
		WHERE tablename = 'common_code'

		UPDATE mergeTables
		SET QueryFilter = ISNULL(QueryFilter, '') + ' AND  template_id IN ( SELECT template_id from [origDB].pn_progress_note  WHERE fac_id in ([OrigFacId],-1)  AND DELETED=''N'' ) '
		WHERE tablename = 'pn_template'

		UPDATE mergeTables
		SET QueryFilter = ISNULL(QueryFilter, '') + ' AND  pn_type_id IN ( SELECT pn_type_id from [origDB].pn_progress_note  WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'' ) '
		WHERE tablename = 'pn_type'

		UPDATE mergeTables
		SET QueryFilter = ' AND ( care_plan_id IN ( SELECT care_plan_id from [origDB].care_plan) OR care_plan_id IS NULL) '
		WHERE tablename = 'cp_rev_need'

		--added 2014-04-23
		UPDATE mergeTables
		SET QueryFilter = ISNULL(QueryFilter, '') + ' and pick_list_id in (select pick_list_id from [origDB].pn_spn_narrative_response where pick_list_id is not NULL and std_assess_id in (select src_id FROM [stagDB].[prefix]as_std_assessment)) '
		WHERE tablename = 'as_std_pick_list'

		--jll
		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'branded_library_configuration'
				)
		BEGIN
			DELETE
			FROM mergejoins
			WHERE tablename = 'pn_template'
				AND parenttable = 'branded_library_configuration'
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'branded_library_configuration'
				)
		BEGIN
			DELETE
			FROM mergejoins
			WHERE tablename = 'pn_template_section'
				AND parenttable = 'branded_library_configuration'
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'branded_library_configuration'
				)
		BEGIN
			DELETE
			FROM mergejoins
			WHERE tablename = 'pn_type'
				AND parenttable = 'branded_library_configuration'
		END

		--
		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'pho_schedule_details'
				) --No pho_schedule_details---------------------------
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable = 'pho_schedule_details'
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'api_authorization'
				) --No pho_schedule_details---------------------------
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable = 'api_authorization'
		END
	END

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('E10')
			) -- Vital---------------------------
	BEGIN
		INSERT INTO #mergeTables
		SELECT *
		FROM dbo.mergeTables
		WHERE tablename IN (
				'WV_STD_VITALS'
				,'wv_std_vitals_thresholds'
				,'common_code'
				-- Added By: Jaspreet Singh, Date: 2017-06-06, Reason: Check smartsheet Update EI Script Row 24
				,'common_code_activation'
				,'wv_vitals'
				,'WV_VITALS_EXCEPTION'
				,'wv_painad_details'
				--Added by: Linlin jing, Date: 2018-03-12, Reason: Rina's email on 2018-03-12
				,'wv_baseline_history'
				)

		INSERT INTO #mergejoins
		SELECT *
		FROM mergejoins
		WHERE tablename IN (
				'wv_vitals'
				,'wv_std_vitals_thresholds'
				,'WV_VITALS_EXCEPTION'
				,'wv_painad_details'
				-- Added By: Jaspreet Singh, Date: 2017-06-06, Reason: Check smartsheet Update EI Script Row 24
				,'common_code'
				,'common_code_activation'
				--Added by: Linlin jing, Date: 2018-03-12, Reason: Rina's email on 2018-03-12
				,'wv_baseline_history'
				)

		UPDATE mergeTables
		SET QueryFilter = '  AND item_id in  ( (SELECT isnull(type_id,-1) FROM [origDB].wv_std_vitals_thresholds WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(strikeout_id,-1) FROM [origDB].wv_vitals WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(type_id,-1) FROM [origDB].wv_vitals WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(threshold_type_id,-1) FROM [origDB].WV_VITALS_EXCEPTION WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'') ) and deleted = ''N'' '
		WHERE tablename = 'common_code'

		--*************--below makes no sense, this should be a if used filter
		UPDATE mergeTables
		SET QueryFilter = '  AND description in (select description from [destDB].wv_std_vitals) '
		WHERE tablename = 'wv_std_vitals'

		--*************below this should be if no progress note module then do the delete
		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'pn_progress_note'
				) --No pn_progress_note table---------------------------
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable = 'pn_progress_note'
		END
	END

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('E11')
			) -- Immunization---------------------------
	BEGIN
		INSERT INTO #mergeTables
		SELECT *
		FROM dbo.mergeTables
		WHERE tablename IN (
				'cr_std_immunization'
				,'cr_client_immunization'
				,'common_code'
				-- Added By: Jaspreet Singh, Date: 2017-06-06, Reason: Check smartsheet Update EI Script Row 24
				,'common_code_activation'
				,'cr_immunization_education'
				,'cr_immunization_manufacturer'
				)

		INSERT INTO #mergejoins
		SELECT *
		FROM mergejoins
		WHERE tablename IN (
				'cr_client_immunization'
				,'cr_immunization_education'
				,'cr_immunization_manufacturer'
				-- Added By: Jaspreet Singh, Date: 2017-06-06, Reason: Check smartsheet Update EI Script Row 24
				,'common_code'
				,'common_code_activation'
				)

		UPDATE mergeTables
		SET QueryFilter = '  AND item_id in  (  (SELECT isnull(body_location_id,-1) FROM [origDB].cr_client_immunization WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')) and deleted = ''N''  '
		WHERE tablename = 'common_code'

		UPDATE mergeTables
		SET QueryFilter = ' AND std_immunization_id in (SELECT std_immunization_id from [origDB].cr_client_immunization WHERE fac_id = [OrigFacId]) '
		WHERE tablename = 'cr_std_immunization'

		IF EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'cp_sec_user_audit'
				)
		BEGIN
			INSERT INTO #mergeTables
			SELECT *
			FROM dbo.mergeTables
			WHERE tablename IN ('immunization_strikeout')

			INSERT INTO #mergejoins
			SELECT *
			FROM mergejoins
			WHERE tablename IN ('immunization_strikeout')

			UPDATE mergeTables
			SET QueryFilter = '  AND item_id in  (  (SELECT isnull(body_location_id,-1) FROM [origDB].cr_client_immunization WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'') union  (SELECT isnull(strikeout_reason_id,-1) FROM [origDB].immunization_strikeout WHERE immunization_id in (select immunization_id from [origDB].cr_client_immunization where fac_id in ([OrigFacId],-1) AND DELETED=''N'' )) ) and deleted = ''N''  '
			WHERE tablename = 'common_code'
		END
	END

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('E12a')
			) --Custom Care Plan---------------------------
	BEGIN
		INSERT INTO #mergeTables
		SELECT *
		FROM dbo.mergeTables
		WHERE tablename IN (
				'common_code'
				,'care_plan'
				,'cp_rev_review'
				,'cp_rev_users'
				,'cp_rev_need'
				,'cp_rev_goal'
				,'cp_rev_intervention'
				,'cp_sec_user_audit'
				,'cp_rev_need_care_plan_type_mapping'
				)

		--			,'cp_kardex_categories'
		--Remove the std tables because no library
		--'cp_std_library','cp_std_need_cat','cp_std_need','cp_std_goal','cp_std_intervention','cp_kardex_categories','cp_std_frequency'
		INSERT INTO #mergejoins
		SELECT *
		FROM mergejoins
		WHERE tablename IN (
				'care_plan'
				,'cp_rev_review'
				,'cp_rev_users'
				,'cp_rev_need'
				,'cp_rev_goal'
				,'cp_rev_intervention'
				,'cp_sec_user_audit'
				,'cp_rev_need_care_plan_type_mapping'
				)

		--			,'cp_kardex_categories'
		UPDATE mergeTables
		SET QueryFilter = 
			'  AND item_id in  ( (SELECT isnull(dept_id,-1) FROM [origDB].cp_rev_users WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(dept1,-1) FROM [origDB].cp_std_need WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(dept2,-1) FROM [origDB].cp_std_need WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(dept3,-1) FROM [origDB].cp_std_need WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(dept4,-1) FROM [origDB].cp_std_need WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(dept5,-1) FROM [origDB].cp_std_need WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(position_id,-1) FROM [origDB].cp_std_intervention WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(position_id_2,-1) FROM [origDB].cp_std_intervention WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(position_id_3,-1) FROM [origDB].cp_std_intervention WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(position_id_4,-1) FROM [origDB].cp_std_intervention WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(position_id_5,-1) FROM [origDB].cp_std_intervention WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(dept_id_one,-1) FROM [origDB].cp_rev_need WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(dept_id_two,-1) FROM [origDB].cp_rev_need WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(dept_id_three,-1) FROM [origDB].cp_rev_need WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(dept_id_four,-1) FROM [origDB].cp_rev_need WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(dept_id_five,-1) FROM [origDB].cp_rev_need WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(position_id,-1) FROM [origDB].cp_rev_intervention WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(position_id_2,-1) FROM [origDB].cp_rev_intervention WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(position_id_3,-1) FROM [origDB].cp_rev_intervention WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(position_id_4,-1) FROM [origDB].cp_rev_intervention WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(position_id_5,-1) FROM [origDB].cp_rev_intervention WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(closure_reason,-1) FROM [origDB].care_plan WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  ) and deleted = ''N'' '
		WHERE tablename = 'common_code'

		--not be bringing over resident tasks.
		UPDATE mergeTables
		SET QueryFilter = ' AND gen_intervention_id NOT IN ( SELECT gen_intervention_id from [origDB].cp_rev_intervention where is_task = ''Y'' ) '
		WHERE tablename = 'cp_rev_intervention'

		UPDATE mergeTables
		SET QueryFilter = ' AND ( care_plan_id IN ( SELECT care_plan_id from [origDB].care_plan) OR care_plan_id IS NULL) '
		WHERE tablename = 'cp_rev_need'

		/* 	UPDATE mergeTables
	SET QueryFilter = ' AND category_id IN ( SELECT category_id from [origDB].cp_rev_intervention where is_task = ''Y'' and category_id is not NULL) '
	WHERE tablename = 'cp_kardex_categories' */
		DELETE
		FROM mergejoins
		WHERE parenttable IN (
				'cp_std_library'
				,'cp_std_need_cat'
				,'cp_std_need'
				,'cp_std_goal'
				,'cp_std_intervention'
				,'cp_kardex_categories'
				,'cp_std_frequency'
				)
	END

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('E12b')
			) --Care Plan Copy Library---------------------------
	BEGIN
		--care plan
		INSERT INTO #mergeTables
		SELECT *
		FROM dbo.mergeTables
		WHERE tablename IN (
				'common_code'
				,'care_plan'
				,'cp_rev_review'
				,'cp_rev_users'
				,'cp_rev_need'
				,'cp_std_library'
				,'cp_std_need_cat'
				,'cp_std_need'
				,'cp_std_goal'
				,'cp_std_intervention'
				,'cp_rev_goal'
				,'cp_rev_intervention'
				,'cp_kardex_categories'
				,'cp_std_frequency'
				,'cp_sec_user_audit'
				,'cp_triggered_item'
				,'cp_rev_need_care_plan_type_mapping'
				,'focus_care_plan_type'
				--*Added By: Jaspreet Singh, Date:: 2017-04-12, Reason: Check Rina email for 3.7.12
				,'cp_kardex_categories_activation'
				,'cp_kardex_categories_activation_audit'
				)

		INSERT INTO #mergejoins
		SELECT *
		FROM mergejoins
		WHERE tablename IN (
				'care_plan'
				,'cp_rev_review'
				,'cp_rev_users'
				,'cp_rev_need'
				,'cp_std_library'
				,'cp_std_need_cat'
				,'cp_std_need'
				,'cp_std_goal'
				,'cp_std_intervention'
				,'cp_rev_goal'
				,'cp_rev_intervention'
				,'cp_kardex_categories'
				,'cp_std_frequency'
				,'cp_sec_user_audit'
				,'cp_triggered_item'
				,'cp_rev_need_care_plan_type_mapping'
				,'focus_care_plan_type'
				--*Added By: Jaspreet Singh, Date:: 2017-04-12, Reason: Check Rina email for 3.7.12
				,'cp_kardex_categories_activation'
				,'cp_kardex_categories_activation_audit'
				)

		--SELECT * from mergejoins where tablename in ('care_plan','cp_rev_review','cp_rev_users','cp_rev_need','cp_std_goal','cp_std_intervention','cp_rev_goal','cp_rev_intervention','cp_std_need')
		--Library
		INSERT INTO #mergeTables
		SELECT *
		FROM dbo.mergeTables
		WHERE tablename IN (
				'cp_std_library'
				,'cp_std_need_cat'
				,'cp_std_need'
				,'cp_std_etiologies'
				,'cp_std_goal'
				,'cp_std_library'
				,'cp_std_need_cat'
				,'cp_std_need'
				,'cp_std_goal'
				,'cp_std_intervention'
				,'cp_std_frequency'
				,'cp_std_shift'
				,'cp_std_shift_fac'
				,'cp_std_schedule'
				,'cp_kardex_categories'
				,'cp_std_intervention_fac'
				,'cp_std_freq_fac'
				-- Commented By: Jaspreet Singh, Date: 2015-09-03, Purpose: We don't copy POC data for EI
				--,'cp_std_pick_list'
				--,'cp_std_pick_list_item'
				--,'cp_std_question'
				--,'cp_std_intervention_question'
				--,'cp_consistency_rule'
				--,'cp_consistency_rule_std_intervention'
				,
				--'cp_lbr_library','cp_lbr_category','cp_lbr_category_std_intervention','cp_std_task_library','cp_std_task_library_mapping',,'cp_std_batch','cp_std_batch_intervention','cp_std_batch_question' (Rina Changed)
				'icon'
				,'cp_std_intervention_icon'
				--Added by: Linlin jing, Date: 2018-03-12, Reason: Rina's email on 2018-03-12
				,'cp_std_lib_departments'
				,'cp_std_lib_positions'
				)

		--,'cp_std_trigger'
		INSERT INTO #mergejoins
		SELECT *
		FROM mergejoins
		WHERE tablename IN (
				'cp_std_library'
				,'cp_std_need_cat'
				,'cp_std_need'
				,'cp_std_etiologies'
				,'cp_std_goal'
				,'cp_std_library'
				,'cp_std_need_cat'
				,'cp_std_need'
				,'cp_std_goal'
				,'cp_std_intervention'
				,'cp_std_frequency'
				,'cp_std_shift'
				,'cp_std_shift_fac'
				,'cp_std_schedule'
				,'cp_kardex_categories'
				,'cp_std_intervention_fac'
				,'cp_std_freq_fac'
				-- Commented By: Jaspreet Singh, Date: 2015-09-03, Purpose: We don't copy POC data for EI
				--,'cp_std_pick_list'
				--,'cp_std_pick_list_item'
				--,'cp_std_question'
				--,'cp_std_intervention_question'
				--,'cp_consistency_rule'
				--,'cp_consistency_rule_std_intervention'
				,
				--'cp_lbr_library','cp_lbr_category','cp_lbr_category_std_intervention','cp_std_task_library','cp_std_task_library_mapping',,'cp_std_batch','cp_std_batch_intervention''cp_std_batch_question', (Rina Changed)
				'icon'
				,'cp_std_intervention_icon'
				--Added by: Linlin jing, Date: 2018-03-12, Reason: Rina's email on 2018-03-12
				,'cp_std_lib_departments'
				,'cp_std_lib_positions'
				)

		--jll
		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'branded_library_configuration'
				)
		BEGIN
			DELETE
			FROM mergejoins
			WHERE tablename = 'cp_branded_frequency_mapping'
				AND parenttable = 'branded_library_configuration'
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'branded_library_configuration'
				)
		BEGIN
			DELETE
			FROM mergejoins
			WHERE tablename = 'cp_branded_shift_mapping'
				AND parenttable = 'branded_library_configuration'
		END

		--
		---- Added By: Jaspreet Singh, Date: 2017-05-09, Reason: Check table name in smartsheet Update EI script (Start)
		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'cp_branded_care_plan_section'
				)
		BEGIN
			DELETE
			FROM mergejoins
			WHERE tablename = 'cp_std_need'
				AND parenttable = 'cp_branded_care_plan_section'
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'branded_library_configuration'
				)
		BEGIN
			DELETE
			FROM mergejoins
			WHERE tablename = 'cp_std_need'
				AND parenttable = 'branded_library_configuration'
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'branded_library_configuration'
				)
		BEGIN
			DELETE
			FROM mergejoins
			WHERE tablename = 'cp_std_need_cat'
				AND parenttable = 'branded_library_configuration'
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'branded_library_configuration'
				)
		BEGIN
			DELETE
			FROM mergejoins
			WHERE tablename = 'cp_std_library'
				AND parenttable = 'branded_library_configuration'
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'branded_library_configuration'
				)
		BEGIN
			DELETE
			FROM mergejoins
			WHERE tablename = 'cp_std_intervention'
				AND parenttable = 'branded_library_configuration'
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'branded_library_configuration'
				)
		BEGIN
			DELETE
			FROM mergejoins
			WHERE tablename = 'cp_std_goal'
				AND parenttable = 'branded_library_configuration'
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'cp_branded_etiology'
				)
		BEGIN
			DELETE
			FROM mergejoins
			WHERE tablename = 'cp_std_etiologies'
				AND parenttable = 'cp_branded_etiology'
		END

		---- Added By: Jaspreet Singh, Date: 2017-05-09, Reason: Check table name in smartsheet Update EI script (End)
		--,'cp_std_trigger'
		--SELECT * from mergejoins where tablename in ('care_plan','cp_rev_review','cp_rev_users','cp_rev_need','cp_std_goal','cp_std_intervention','cp_rev_goal','cp_rev_intervention','cp_std_need') 
		UPDATE mergeTables
		SET QueryFilter = 
			'  AND (item_id in  ( (SELECT isnull(dept_id,-1) FROM [origDB].cp_rev_users WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(dept1,-1) FROM [origDB].cp_std_need WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(dept2,-1) FROM [origDB].cp_std_need WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(dept3,-1) FROM [origDB].cp_std_need WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(dept4,-1) FROM [origDB].cp_std_need WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(dept5,-1) FROM [origDB].cp_std_need WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(position_id,-1) FROM [origDB].cp_std_intervention WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(position_id_2,-1) FROM [origDB].cp_std_intervention WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(position_id_3,-1) FROM [origDB].cp_std_intervention WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(position_id_4,-1) FROM [origDB].cp_std_intervention WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(position_id_5,-1) FROM [origDB].cp_std_intervention WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(dept_id_one,-1) FROM [origDB].cp_rev_need WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(dept_id_two,-1) FROM [origDB].cp_rev_need WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(dept_id_three,-1) FROM [origDB].cp_rev_need WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(dept_id_four,-1) FROM [origDB].cp_rev_need WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(dept_id_five,-1) FROM [origDB].cp_rev_need WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(position_id,-1) FROM [origDB].cp_rev_intervention WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(position_id_2,-1) FROM [origDB].cp_rev_intervention WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(position_id_3,-1) FROM [origDB].cp_rev_intervention WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(position_id_4,-1) FROM [origDB].cp_rev_intervention WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(position_id_5,-1) FROM [origDB].cp_rev_intervention WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'') UNION (SELECT isnull(closure_reason,-1) FROM [origDB].care_plan WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  ) ) and deleted = ''N''  '
		WHERE tablename = 'common_code'

		---- Modified By: Linlin jing, Date: 2017-06-14, Reason: Check table name in smartsheet Update EI script #22 (start)
		UPDATE mergeTables
		SET QueryFilter = '  AND library_id in ( select library_id from [origDB].cp_std_need_cat WHERE need_cat_id in (select need_cat_id from [origDB].cp_std_need WHERE deleted=''N'' and std_need_id in  (select std_need_id from [origDB].cp_rev_need where deleted = ''N'' and fac_id=[OrigFacId]) ))' + ISNULL(QueryFilter, '') --1/13/2014 Rina added and fac_id=[OrigFacId])
		WHERE tablename = 'cp_std_library'

		---- Modified By: Linlin jing, Date: 2017-06-14, Reason: Check table name in smartsheet Update EI script #22 (end)
		UPDATE mergeTables
		SET QueryFilter = ' AND std_need_id IN (SELECT src_id from [stagDB].[prefix]cp_std_need) '
		WHERE tablename = 'cp_std_etiologies'

		UPDATE mergeTables
		SET QueryFilter = 
			' AND (std_freq_id IN (
										SELECT std_freq_id FROM [origDB].cp_std_intervention WHERE std_need_id IN (SELECT src_id from [stagDB].[prefix]cp_std_need)
										union
										SELECT poc_std_freq_id FROM [origDB].cp_std_intervention WHERE std_need_id IN (SELECT src_id from [stagDB].[prefix]cp_std_need) 
										union
										SELECT std_freq_id FROM [origDB].cp_rev_intervention WHERE std_need_id IN (SELECT src_id from [stagDB].[prefix]cp_std_need)
										union
										SELECT std_freq_id FROM [origDB].cp_std_intervention 
										union
										SELECT std_freq_id FROM [origDB].cp_schedule 
										union
										SELECT std_freq_id FROM [origDB].cp_schedule 
										union
										SELECT std_freq_id FROM [origDB].cp_std_freq_fac 
										union
										SELECT std_freq_id FROM [origDB].cp_std_schedule 
										union
										SELECT std_freq_id FROM [origDB].pho_order_group_item 
										union
										SELECT std_freq_id FROM [origDB].pho_phys_order 
										union
										SELECT std_freq_id FROM [origDB].pho_schedule 
										union
										SELECT std_freq_id FROM [origDB].pho_schedule_template 
										union
										SELECT std_freq_id FROM [origDB].pho_type_freq 
												 )) AND ISNULL(poc_freq,''N'') <> ''Y'' '
		WHERE tablename = 'cp_std_frequency'

		UPDATE mergeTables
		SET QueryFilter = ' and ISNULL(is_task,'''') <> ''Y'' and std_need_id in (select std_need_id from [origDB].cp_std_need ' + ' where need_cat_id in (select need_cat_id from [origDB].cp_std_need_cat where library_id in ' + '( select src_id from ' + @caseNo + 'cp_std_library ) ))'
		--						   ' and ISNULL(text1,'''') not in (select ISNULL(text1,'''') from cp_std_intervention where  std_need_id in ( select std_need_id from cp_std_need ' +
		--												 ' where need_cat_id in (select need_cat_id from cp_std_need_cat where library_id in ' +
		--																		 '( select dst_id from ' + @caseNo + 'cp_std_library ) )))'
		WHERE tablename = 'cp_std_intervention'

		UPDATE mergeTables
		SET QueryFilter = ' AND ( care_plan_id IN ( SELECT care_plan_id from [origDB].care_plan) OR care_plan_id IS NULL) '
		WHERE tablename = 'cp_rev_need'

		--not be bringing over resident tasks.
		UPDATE mergeTables
		SET QueryFilter = ' AND gen_intervention_id NOT IN ( SELECT gen_intervention_id from [origDB].cp_rev_intervention where is_task = ''Y'' ) '
		WHERE tablename = 'cp_rev_intervention'

		UPDATE mergejoins
		SET pkjoin = 'Y'
		WHERE tablename = 'cp_std_batch_question'
			AND parenttable = 'cp_std_batch'

		UPDATE mergejoins
		SET pkjoin = 'Y'
		WHERE tablename = 'cp_std_intervention'
			AND parenttable = 'cp_std_need'

		-- Commented By: Jaspreet Singh, Date: 2015-09-03, Purpose: We don't copy POC data for EI
		--UPDATE mergejoins
		--SET pkjoin = 'Y'
		--WHERE tablename = 'cp_std_question'
		--	AND parenttable = 'cp_std_pick_list'
		--UPDATE mergejoins
		--SET pkjoin = 'Y'
		--WHERE tablename = 'cp_consistency_rule'
		UPDATE mergejoins
		SET pkjoin = 'Y'
		WHERE tablename = 'cp_lbr_category'

		UPDATE mergejoins
		SET pkjoin = 'Y'
		WHERE tablename = 'cp_std_intervention_icon'
	END

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('E13')
			) -- Phys Order---------------------------
	BEGIN
		--Truncate PCC Global
		--,'pho_pharmacy_order'
		INSERT INTO #mergeTables
		SELECT *
		FROM dbo.mergeTables
		WHERE tablename IN (
				'common_code'
				,'emc_ext_facilities'
				,'client_ext_facilities'
				,'cp_std_frequency'
				,'cp_std_shift'
				,'cp_std_shift_fac'
				,'pho_order_category'
				,'pho_administration_record'
				,'pho_order_type'
				,'pho_std_phys_order'
				,'pho_phys_order'
				,'pho_med_source_type'
				,'pho_std_time_type'
				,'pho_std_time'
				,'pho_std_time_details'
				,'pho_order_supply'
				,'pho_schedule'
				,'pho_schedule_details'
				,'pho_admin_strikeout'
				,'pho_pharmacy_shipment'
				,'pho_ext_library'
				,'pho_order_ext_lib_med_ref'
				,'pho_phys_order_ranked'
				,'pho_admin_order'
				,'pho_order_relationship'
				,'pho_related_order'
				,'pho_mar_std_time_report_options'
				,'pho_order_schedule'
				,'pho_schedule_vitals'
				,'pho_vital_documentation'
				,'pho_sliding_scale'
				,'pho_sliding_scale_range'
				,'pho_order_related_prompt'
				,'pho_prompt_freq_type'
				,'pho_order_related_value_data_type'
				,'pho_order_related_value_type'
				,'cr_shift_group'
				,'cr_cust_med'
				,'cr_cust_med_class'
				,'cr_ebox_med'
				,'pho_assignment_group_assoc'
				,'pho_assignment_group'
				,'pho_phys_order_new_entry'
				,'pho_order_ext_lib_cls'
				,'pho_std_time_fac'
				,'pho_order_group'
				,'pho_order_group_item'
				,'pho_phys_order_useraudit'
				,'pho_std_time_frequency'
				,'dw_pho_order_schedule'
				,'pho_order_last_admin_details'
				,'pho_order_sliding_scale_range'
				,'pn_associate'
				,'pho_order_last_admin_details'
				,'dw_pho_order_schedule'
				,'pho_order_queue'
				,'pho_order_supply_allergy'
				,'pho_std_client_review_status'
				,'pho_client_review'
				,'pho_phys_order_med_professional'
				,'pho_std_phys_order_review_action'
				,'pho_phys_order_review'
				,'pho_phys_order_advanced_directive'
				,'order_sign_source_type'
				,'pho_phys_order_sign'
				,'order_sign_authentication_type'
				,'order_sign_signature_type'
				,'pho_phys_order_med_professional'
				,'pho_formulary_medical_professional_audit'
				,'pho_phys_order_to_sign'
				,'pho_schedule_details_progress_note'
				,'pho_schedule_details_strikeout_followup_useraudit'
				,'pho_schedule_details_strikeout_performby_useraudit'
				,'pho_schedule_last_event'
				,'pho_std_administered_by'
				,'pho_std_order_status'
				,'pho_std_order'
				,'pho_std_order_fac'
				,'pho_std_order_set_status'
				,'pho_std_phys_order_review_action'
				,'pho_followup_strikeout'
				,'pho_body_location'
				,'pho_admin_site_detail'
				,'pho_schedule_details_performby_useraudit'
				,'pho_schedule_details_pending_followup'
				,'pho_schedule_details_progress_note'
				,'pho_schedule_details_followup_useraudit'
				,'pho_body_location_site'
				,'pho_phys_order_audit_useraudit'
				,'pho_std_order_set'
				,'pho_phys_order_cust_med'
				,'pho_phys_order_ti'
				,'pho_phys_order_ti_audit'
				,'pho_std_order_schedule_related_prompt'
				,'pho_std_order_schedule_vital'
				,'pho_std_order_schedule'
				,'pho_std_phys_order_std_order'
				,'pho_dose_unit_of_measure'
				,'pho_quantity_unit_of_measure'
				,'pho_schedule_duration_type'
				,'pho_schedule_end_date_type'
				,'pho_std_order_Set_item'
				,'pho_std_order_set_fac'
				,'pho_std_order_type'
				,'pho_std_order_schedule_time_code'
				,'pho_clinical_review_library_item_type'
				,'pho_lib_order'
				,'pho_lib_order_schedule'
				,'pho_lib_order_schedule_vital'
				,'pho_lib_schedule'
				,'pho_lib_scheduled_vital'
				,'pho_mmdb_synch_run_history'
				,'pho_phys_order_new_ctrlsubstancecode'
				,'pho_std_schedule'
				,'pho_assignment_beds'
				,'pho_clinical_review_library_item'
				,'pho_clinical_review_library_item_facility'
				,'pho_clinical_review_library_item_note'
				,'pho_clinical_review_library_item_reference_value'
				,'pho_lib_order_related_prompt'
				,'pho_lib_order_schedule_related_prompt'
				,'pho_linked_set'
				,'pho_linked_set_item'
				,'pho_order_clinical_review'
				,'pho_order_clinical_review_item'
				,'pho_phys_order_nurse_instruction'
				,'pho_assignment'
				,'pho_assignment_beds_back'
				,'pho_assignment_group_assign'
				,'pho_assignment_group_assoc_back'
				,'pho_assignment_group_back'
				,'pho_assignment_group_assign_back'
				,'pho_order_type_ext_lib_cls'
				,'pho_phys_order_last_event'
				,'pho_phys_order_allergy_acknowledgement'
				,'pho_order_pending_reason'
				,'pho_phys_order_esignature'
				,'pho_phys_order_blackbox_acknowledgement'
				,'pho_phys_order_no_drug_protocol_checks'
				,'pho_phys_order_dose_check_acknowledgement'
				,'pho_phys_order_drug_acknowledgement'
				,'pho_chart_code_history'
				,'pho_order_related_value'
				,'pho_disconnected_emar_shift_assignment'
				,'pho_disconnected_emar_shift_assignment_status'
				,'pho_disconnected_emar_shift_assignment_status_history'
				,'pho_schedule_details_reminder'
				,'pho_order_schedule_related_diagnoses'
				,'pho_disconnected_emar_admin_action'
				,'pho_disconnected_emar_admin_progress_note'
				,'pho_disconnected_emar_admin_related_prompt'
				,'pho_disconnected_emar_admin_site_detail'
				,'pho_disconnected_emar_admin_vital'
				,'pho_disconnected_emar_shift_assignment_client'
				,'pho_admin_order_audit_useraudit'
				,'pho_admin_order_useraudit'
				,'pho_phys_order_esignature_client_mapping'
				,'pho_phys_order_esignature_client_snapshot'
				,'pho_phys_order_esignature_contact_mapping'
				,'pho_phys_order_esignature_contact_snapshot'
				,'pho_phys_order_esignature_order_snapshot'
				,'pho_phys_order_quantity_info'
				,'pho_phys_order_quantity_info_audit'
				,'pho_std_order_advance_directive_type_mapping'
				,'pho_std_order_fac_change_history'
				--***************Added By: Jaspreet Singh, Date: 2017-04-12, Reason: Check Rina email for 3.7.12
				,'pho_phys_order_require_witness'
				,'pho_schedule_details_admin_witness'
				,'pho_second_signature_config'
				,'pho_second_signature_config_audit'
				,'pho_second_signature_config_class'
				,'pho_second_signature_config_drug'
				,'pho_second_signature_config_status'
				,'pho_second_signature_config_substance_code'
				,'pho_second_signature_config_type'
				--***************Added By: Jaspreet Singh, Date: 2017-05-09, Reason: Check spreadsheet Update EI Script
				,'wv_vitals_created_by_detail_id'
				--***************Added By: Jaspreet Singh, Date: 2017-05-15, Reason: Check spreadsheet Update EI Script (#12) start
				,'pho_phys_order_std_order'
				--***************Added By: Jaspreet Singh, Date: 2017-05-15, Reason: Check spreadsheet Update EI Script (#12) end
				-- Added By: Jaspreet Singh, Date: 2017-06-06, Reason: Check smartsheet Update EI Script Row 24
				,'common_code_activation'
				--Added by: Linlin jing, Date: 2018-03-12, Reason: Rina's email on 2018-03-12
				,'pho_assignment_group_assoc_audit'
				--***************Added By: Linlin jing, Date: 2018-06-19, Reason: Check Rina email for 3.7.15
				,'pho_body_location_body_site_type'
				,'pho_body_site_type'
				-- Added By: Mark Estey, Date: 2019-06-17, Reason: Updates to 3.7.19 Smartsheet Line 71
				--,'pho_pharmacy_order'
				--,'pho_pharmacy_note_detail'
				--,'pho_pharmacy_schedule'
				,'pho_order_queue_drug_protocol_action'
				-- Added By: Jaspreet Singh, Date: 12/29/2020, Reason: Nigel email at 12/29/2020
				,'pho_order_supply_audit'
				,'pho_phys_order_lab'
				-- Added By: Nigel Liang, Date: 12/24/2021
				,'pho_phys_order_dose_check_warning'
				)

		--'pho_pharmacy_order'
		INSERT INTO #mergejoins
		SELECT *
		FROM mergejoins
		WHERE tablename IN (
				'pho_administration_record'
				,'pho_order_type'
				,'pho_std_phys_order'
				,'pho_phys_order'
				,'pho_std_time'
				,'pho_std_time_details'
				,'pho_order_supply'
				,'pho_schedule'
				,'pho_schedule_details'
				,'pho_admin_strikeout'
				,'pho_pharmacy_shipment'
				,'pho_ext_library'
				,'pho_order_ext_lib_med_ref'
				,'pho_phys_order_ranked'
				,'pho_admin_order'
				,'pho_related_order'
				,'pho_mar_std_time_report_options'
				,'pho_order_schedule'
				,'pho_schedule_vitals'
				,'pho_vital_documentation'
				,'pho_sliding_scale'
				,'pho_sliding_scale_range'
				,'pho_order_related_prompt'
				,'pho_prompt_freq_type'
				,'pho_order_related_value_data_type'
				,'pho_order_related_value_type'
				,'cr_shift_group'
				,'cr_cust_med'
				,'cr_cust_med_class'
				,'cr_ebox_med'
				,'pho_assignment_group_assoc'
				,'pho_assignment_group'
				,'pho_phys_order_new_entry'
				,'pho_order_ext_lib_cls'
				,'pho_std_time_fac'
				,'pho_order_group'
				,'pho_order_group_item'
				,'pho_phys_order_useraudit'
				,'pho_std_time_frequency'
				,'cp_std_shift_fac'
				,'dw_pho_order_schedule'
				,'pho_order_last_admin_details'
				,'pho_order_sliding_scale_range'
				,'pn_associate'
				,'pho_order_last_admin_details'
				,'dw_pho_order_schedule'
				,'pho_order_queue'
				,'pho_order_supply_allergy'
				,'pho_std_client_review_status'
				,'pho_client_review'
				,'pho_phys_order_med_professional'
				,'pho_std_phys_order_review_action'
				,'pho_phys_order_review'
				,'pho_phys_order_advanced_directive'
				,'order_sign_source_type'
				,'pho_phys_order_sign'
				,'order_sign_authentication_type'
				,'order_sign_signature_type'
				,'pho_phys_order_med_professional'
				,'pho_formulary_medical_professional_audit'
				,'pho_phys_order_to_sign'
				,'pho_schedule_details_progress_note'
				,'pho_schedule_details_strikeout_followup_useraudit'
				,'pho_schedule_details_strikeout_performby_useraudit'
				,'pho_schedule_last_event'
				,'pho_std_administered_by'
				,'pho_std_order_status'
				,'pho_std_order'
				,'pho_std_order_fac'
				,'pho_std_order_set_status'
				,'pho_std_phys_order_review_action'
				,'pho_followup_strikeout'
				,'pho_body_location'
				,'pho_admin_site_detail'
				,'pho_schedule_details_performby_useraudit'
				,'pho_schedule_details_pending_followup'
				,'pho_schedule_details_progress_note'
				,'pho_schedule_details_followup_useraudit'
				,'pho_body_location_site'
				,'pho_phys_order_audit_useraudit'
				,'pho_std_order_set'
				,'pho_phys_order_cust_med'
				,'pho_phys_order_ti'
				,'pho_phys_order_ti_audit'
				,'pho_std_order_schedule_related_prompt'
				,'pho_std_order_schedule_vital'
				,'pho_std_order_schedule'
				,'pho_std_phys_order_std_order'
				,'pho_dose_unit_of_measure'
				,'pho_quantity_unit_of_measure'
				,'pho_schedule_duration_type'
				,'pho_schedule_end_date_type'
				,'pho_std_order_Set_item'
				,'pho_std_order_set_fac'
				,'pho_std_order_type'
				,'pho_std_order_schedule_time_code'
				,'pho_clinical_review_library_item_type'
				,'pho_lib_order'
				,'pho_lib_order_schedule'
				,'pho_lib_order_schedule_vital'
				,'pho_lib_schedule'
				,'pho_lib_scheduled_vital'
				,'pho_mmdb_synch_run_history'
				,'pho_phys_order_new_ctrlsubstancecode'
				,'pho_std_schedule'
				,'pho_assignment_beds'
				,'pho_clinical_review_library_item'
				,'pho_clinical_review_library_item_facility'
				,'pho_clinical_review_library_item_note'
				,'pho_clinical_review_library_item_reference_value'
				,'pho_lib_order_related_prompt'
				,'pho_lib_order_schedule_related_prompt'
				,'pho_linked_set'
				,'pho_linked_set_item'
				,'pho_order_clinical_review'
				,'pho_order_clinical_review_item'
				,'pho_phys_order_nurse_instruction'
				,'pho_assignment'
				,'pho_assignment_beds_back'
				,'pho_assignment_group_assign'
				,'pho_assignment_group_assoc_back'
				,'pho_assignment_group_back'
				,'pho_assignment_group_assign_back'
				,'pho_order_type_ext_lib_cls'
				,'pho_phys_order_last_event'
				,'pho_phys_order_allergy_acknowledgement'
				,'pho_order_pending_reason'
				,'pho_phys_order_esignature'
				,'pho_phys_order_blackbox_acknowledgement'
				,'pho_phys_order_no_drug_protocol_checks'
				,'pho_phys_order_dose_check_acknowledgement'
				,'pho_phys_order_drug_acknowledgement'
				,'pho_chart_code_history'
				,'pho_order_related_value'
				,'pho_disconnected_emar_shift_assignment'
				,'pho_disconnected_emar_shift_assignment_status'
				,'pho_disconnected_emar_shift_assignment_status_history'
				,'pho_schedule_details_reminder'
				,'pho_order_schedule_related_diagnoses'
				,'pho_disconnected_emar_admin_action'
				,'pho_disconnected_emar_admin_progress_note'
				,'pho_disconnected_emar_admin_related_prompt'
				,'pho_disconnected_emar_admin_site_detail'
				,'pho_disconnected_emar_admin_vital'
				,'pho_disconnected_emar_shift_assignment_client'
				,'pho_admin_order_audit_useraudit'
				,'pho_admin_order_useraudit'
				,'pho_phys_order_esignature_client_mapping'
				,'pho_phys_order_esignature_client_snapshot'
				,'pho_phys_order_esignature_contact_mapping'
				,'pho_phys_order_esignature_contact_snapshot'
				,'pho_phys_order_esignature_order_snapshot'
				,'pho_phys_order_quantity_info'
				,'pho_phys_order_quantity_info_audit'
				,'pho_std_order_advance_directive_type_mapping'
				,'pho_std_order_fac_change_history'
				--***************Added By: Jaspreet Singh, Date: 2017-04-12, Reason: Check Rina email for 3.7.12
				,'pho_phys_order_require_witness'
				,'pho_schedule_details_admin_witness'
				,'pho_second_signature_config'
				,'pho_second_signature_config_audit'
				,'pho_second_signature_config_class'
				,'pho_second_signature_config_drug'
				,'pho_second_signature_config_status'
				,'pho_second_signature_config_substance_code'
				,'pho_second_signature_config_type'
				--***************Added By: Jaspreet Singh, Date: 2017-05-09, Reason: Check spreadsheet Update EI Script
				,'wv_vitals_created_by_detail_id'
				--***************Added By: Jaspreet Singh, Date: 2017-05-15, Reason: Check spreadsheet Update EI Script (#12) start
				,'pho_phys_order_std_order'
				--***************Added By: Jaspreet Singh, Date: 2017-05-15, Reason: Check spreadsheet Update EI Script (#12) end
				-- Added By: Jaspreet Singh, Date: 2017-06-06, Reason: Check smartsheet Update EI Script Row 24
				,'common_code'
				,'common_code_activation'
				--Added by: Linlin jing, Date: 2018-03-12, Reason: Rina's email on 2018-03-12
				,'pho_assignment_group_assoc_audit'
				--***************Added By: Linlin jing, Date: 2018-06-19, Reason: Check Rina email for 3.7.15
				,'pho_body_location_body_site_type'
				,'pho_body_site_type'
				-- Added By: Mark Estey, Date: 2019-06-17, Reason: Updates to 3.7.19 Smartsheet Line 71
				--,'pho_pharmacy_order'
				--,'pho_pharmacy_note_detail'
				--,'pho_pharmacy_schedule'
				,'pho_order_queue_drug_protocol_action'
				-- Added By: Jaspreet Singh, Date: 12/29/2020, Reason: Nigel email at 12/29/2020
				,'pho_order_supply_audit'
				,'pho_phys_order_lab'
				)

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'wv_vitals'
				)
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable = 'wv_vitals_created_by_detail_id'
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'pho_disconnected_emar_status_code'
				) --No pho_schedule_details---------------------------
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable = 'pho_disconnected_emar_status_code'
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'pho_std_formulary_type'
				) --No pho_schedule_details---------------------------
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable = 'pho_std_formulary_type'
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'pho_phys_order_class'
				) --No pho_schedule_details---------------------------
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable = 'pho_phys_order_class'
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'pho_drug_protocol_actcode_mapping'
				) --No pho_schedule_details---------------------------
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable = 'pho_drug_protocol_actcode_mapping'
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'cp_sec_user_audit'
				) --No cp_sec_user_audit case table---------------------------
		BEGIN
			INSERT INTO #mergeTables
			SELECT *
			FROM dbo.mergeTables
			WHERE tablename IN ('cp_sec_user_audit')

			INSERT INTO #mergejoins
			SELECT *
			FROM mergejoins
			WHERE tablename IN ('cp_sec_user_audit')
		END

		--Added By: Jaspreet Singh , Date : 2017-05-17, 
		--Reason : To add filter Corporate = 'N' for table pho_std_order_advance_directive_type_mapping
		--Reason:Check Rina email on May 17, 2017, Subject- RE: Merge error (old process) (PMO-24255)
		UPDATE mergeTables
		SET QueryFilter = '  AND std_order_id in  ( 
				SELECT src_id
				FROM [stagDB].[prefix]pho_std_order
				WHERE corporate = ''N''
				)'
		WHERE tablename = 'pho_std_order_advance_directive_type_mapping'

		--UNION (SELECT isnull(route_of_admin,-1) FROM [origDB].pho_pharmacy_order WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'') 
		UPDATE mergeTables
		SET QueryFilter = 
			'  AND item_id in  ( (SELECT isnull(position_id,-1) FROM [origDB].sec_user WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(country_id,-1) FROM [origDB].emc_ext_facilities WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(facility_type,-1) FROM [origDB].emc_ext_facilities WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(marital_status_id,-1) FROM [origDB].contact)  UNION (SELECT isnull(title_id,-1) FROM [origDB].contact)  UNION (SELECT isnull(administration_record_type_id,-1) FROM [origDB].pho_administration_record WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(facility_type,-1) FROM [origDB].pho_order_type WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(order_category_id,-1) FROM [origDB].pho_std_phys_order WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(diet_type,-1) FROM [origDB].pho_phys_order WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(diet_texture,-1) FROM [origDB].pho_phys_order WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(route_of_admin,-1) FROM [origDB].pho_phys_order WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(diet_supplement,-1) FROM [origDB].pho_phys_order WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(fluid_consistency,-1) FROM [origDB].pho_phys_order WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(communication_method,-1) FROM [origDB].pho_phys_order WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(strikeout_reason_id,-1) FROM [origDB].pho_admin_strikeout WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  UNION (SELECT isnull(route_of_admin_id,-1) FROM [origDB].pho_phys_order_ranked WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'') UNION (SELECT isnull(diet_type,-1) FROM [origDB].pho_phys_order WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'') UNION (SELECT isnull(diet_texture,-1) FROM [origDB].pho_phys_order WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'') ) and deleted = ''N''  '
		WHERE tablename = 'common_code'

		UPDATE mergeTables
		SET QueryFilter = ' AND deleted = ''N'' and contact_id in (select contact_id from [origDB].staff where deleted = ''N''
		and fac_id = [OrigFacId]) and exists (select 1 from [destDB].contact c where contact.first_name = c.first_name and contact.last_name = c.last_name)  '
		WHERE tablename = 'contact'

		UPDATE mergeTables
		SET QueryFilter = '  and deleted = ''N'' AND ext_fac_id in (select pharmacy_id from [origDB].pho_phys_order where fac_id = [OrigFacId] )  '
		WHERE tablename = 'emc_ext_facilities'

		UPDATE mergeTables
		SET QueryFilter = ' AND client_id = 0   '
		WHERE tablename = 'client_ext_facilities'

		UPDATE mergeTables
		SET QueryFilter = ' and deleted = ''N'' AND std_shift_id in 
		(select std_shift_id from [origDB].pho_schedule where fac_id = [OrigFacId] UNION select shift_id as std_shift_id from [origDB].pho_std_time_details where fac_id = [OrigFacId] ) '
		WHERE tablename = 'cp_std_shift'

		UPDATE mergeTables
		SET QueryFilter = '  AND order_type_id in 
		(select order_type_id from [origDB].pho_phys_order where fac_id = [OrigFacId]) '
		WHERE tablename = 'pho_order_type'

		UPDATE mergeTables
		SET QueryFilter = '  AND std_phys_order_id in (select std_order_id from [origDB].pho_phys_order where fac_id = [OrigFacId] ) '
		WHERE tablename = 'pho_std_phys_order'

		UPDATE mergeTables
		SET QueryFilter = '  AND pho_std_time_id in (select pho_std_time_id from [origDB].pho_schedule where fac_id = [OrigFacId] )  '
		WHERE tablename = 'pho_std_time'

		UPDATE mergeTables
		SET QueryFilter = ISNULL(QueryFilter, '') + '  AND pho_std_time_id in (SELECT src_id FROM [stagDB].[prefix]pho_std_time where corporate = ''N'')  '
		WHERE tablename = 'pho_std_time_details'

		UPDATE mergeTables
		SET QueryFilter = ' AND pho_schedule_id IN (SELECT src_id FROM [stagDB].[prefix]pho_schedule ) '
		WHERE tablename = 'pho_schedule_details'

		UPDATE mergeTables
		SET QueryFilter = ' AND admin_order_id IN (SELECT src_id FROM [stagDB].[prefix]pho_admin_order ) '
		WHERE tablename = 'pho_admin_order_audit'

		UPDATE mergeTables
		SET QueryFilter = ' AND prompt_id IN (SELECT src_id FROM [stagDB].[prefix]pho_order_related_prompt ) '
		WHERE tablename = 'pho_order_related_prompt_audit'

		UPDATE mergeTables
		SET QueryFilter = ' AND order_schedule_id IN (SELECT src_id FROM [stagDB].[prefix]pho_order_schedule ) '
		WHERE tablename = 'pho_order_schedule_audit'

		--		UPDATE mergeTables 
		--		SET QueryFilter = ' AND phys_order_id IN (SELECT src_id FROM [stagDB].[prefix]pho_phys_order ) ' 
		--		WHERE tablename = 'pho_phys_order_audit' 
		UPDATE mergeTables
		SET QueryFilter = ' AND order_related_id IN (SELECT src_id FROM [stagDB].[prefix]pho_related_order ) '
		WHERE tablename = 'pho_related_order_audit'

		UPDATE mergeTables
		SET QueryFilter = ' AND schedule_id IN (SELECT src_id FROM [stagDB].[prefix]pho_schedule ) '
		WHERE tablename = 'pho_schedule_audit'

		UPDATE mergeTables
		SET QueryFilter = ' AND item_id in (SELECT std_phys_order_id as item_id FROM [origDB].pho_std_phys_order where (fac_id = [OrigFacId] OR fac_id = -1) and deleted = ''N'' and std_phys_order_id in (select std_order_id from [origDB].pho_phys_order where fac_id = [OrigFacId] ) UNION SELECT custom_drug_id as item_id FROM [origDB].cr_cust_med  WHERE custom_drug_id <> -1  and deleted = ''N'' and  (fac_id = [OrigFacId]  OR fac_id = -1 ) and order_type_id in ( SELECT order_type_id from  [origDB].pho_phys_order where fac_id = [OrigFacId] ) )'
		WHERE tablename = 'pho_order_group_item'

		--Updated by Rina 25/06/2013 - If the facility is EOM enabled don join orders then the pho_phys_order> route_of_admin column should be  joined to the  wesreference> pho_std_route_of_admin instead of joining this to the common_code where  item_code ='phorad'
		DECLARE @facIDDest INT
			,@sqlN NVARCHAR(2000);

		SET @sqlN = 'SELECT top 1 @facIDDest=dst_id from ' + @caseNo + 'facility where dst_id <> 9001 and src_id <> 9001'

		EXECUTE sp_executesql @sqlN
			,N'@facIDDest int OUTPUT'
			,@facIDDest = @facIDDest OUTPUT

		IF EXISTS (
				SELECT 1
				FROM dbo.configuration_parameter
				WHERE NAME = 'pho_is_using_new_phys_order_form'
					AND value = 'Y'
					AND fac_id = @facIDDest
				)
			DELETE
			FROM mergejoins
			WHERE parenttable = 'common_code'
				AND tablename = 'pho_phys_order'
				AND fieldName = 'route_of_admin'

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'pn_progress_note'
				) --No pn_progress_note table---------------------------
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable = 'pn_progress_note' --and tablename='pho_schedule_details'
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'unit'
				) --No unit case table---------------------------
		BEGIN
			DELETE
			FROM mergejoins
			WHERE tablename = 'pho_std_time_details'
				AND parenttable = 'unit'
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'pn_progress_note'
				) --No unit case table---------------------------
		BEGIN
			DELETE
			FROM mergejoins
			WHERE tablename = 'pn_associate'

			DELETE
			FROM mergeTables
			WHERE tablename = 'pn_associate'
		END

		--		IF NOT EXISTS (SELECT 1 From INFORMATION_SCHEMA.TABLES Where  TABLE_TYPE= 'BASE TABLE' AND Table_Name =   @caseNo + 'cp_sec_user_audit' )--No cp_sec_user_audit case table---------------------------
		--		BEGIN
		--			DELETE FROM mergejoins WHERE tablename = 'pho_phys_order_useraudit' 
		--			DELETE FROM mergetables WHERE tablename = 'pho_phys_order_useraudit' 
		--		END
		--UPDATE mergejoins set pkjoin='Y' where tablename='pho_std_time_details' and parenttable='cp_std_shift'
		UPDATE mergeTables
		SET scopeField3 = NULL
		WHERE tablename = 'pho_administration_record'

		UPDATE mergeTables
		SET scopeField2 = NULL
			,scopeField3 = NULL
			,scopeField4 = NULL
			,scopeField5 = NULL
			,scopeField6 = NULL
			,scopeField7 = NULL
		WHERE tablename = 'pho_std_phys_order'

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'wv_vitals'
				) --No pn_progress_note table---------------------------
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable = 'wv_vitals'
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'pho_pharmacy_order'
				) --No pho_pharmacy_order table---------------------------
			DELETE
			FROM mergejoins
			WHERE parenttable = 'pho_pharmacy_order'

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'allergy'
				)
			DELETE
			FROM mergejoins
			WHERE parenttable = 'allergy'

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'pho_phys_order_origin'
				) --No pho_schedule_details---------------------------
		BEGIN
			DELETE
			FROM mergeJoins
			WHERE parenttable = 'pho_phys_order_origin'
				OR tablename = 'pho_phys_order_origin'
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'pho_phys_order_origin'
				) --No pho_schedule_details---------------------------
		BEGIN
			DELETE
			FROM mergeTables
			WHERE tablename = 'pho_phys_order_origin'
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'pho_chart_code_change_source'
				) --No pho_schedule_details---------------------------
		BEGIN
			DELETE
			FROM mergeJoins
			WHERE parenttable = 'pho_chart_code_change_source'
				OR tablename = 'pho_chart_code_change_source'
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'pho_chart_code_change_source'
				) --No pho_schedule_details---------------------------
		BEGIN
			DELETE
			FROM mergeTables
			WHERE tablename = 'pho_chart_code_change_source'
		END
	END

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('E14')
			) --"Security Roles"---------------------------
	BEGIN
		INSERT INTO #mergeTables
		SELECT *
		FROM dbo.mergeTables
		WHERE tablename IN (
				'facility'
				,'sec_role'
				,'sec_role_function'
				)

		INSERT INTO #mergejoins
		SELECT *
		FROM mergejoins
		WHERE tablename IN (
				'facility'
				,'sec_role'
				,'sec_role_function'
				)
	END

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('E15')
			) --Security User---------------------------
	BEGIN
		INSERT INTO #mergeTables
		SELECT *
		FROM dbo.mergeTables
		WHERE tablename IN (
				'facility'
				,'common_code'
				-- Added By: Jaspreet Singh, Date: 2017-06-06, Reason: Check smartsheet Update EI Script Row 24
				,'common_code_activation'
				,'sec_user'
				,'sec_user_role'
				,'sec_user_facility'
				-- Commented By: Jaspreet Singh, Date: 2020-12-29, Reason: Nigel email on 12/29/2020
				-- ,'fac_message'
				,'sec_user_physical_id'
				,'sec_user_secondary_pcc'
				,'sec_user_secondary'
				-- Added By: Jaspreet Singh, Date: 2017-02-22
				,'pns_subscription'
				--Added by: Linlin jing, Date: 2017-07-13, Reason: Rina's email on 2017-07-10
				,'sec_user_ext'
				--Added by: Linlin jing, Date: 2018-06-18, Reason: Rina's email 3.7.15.3
				,'sec_user_unlock_pin'
				,'sec_user_unlock_pin_audit'
				,'sec_user_verification_answers' -- Added by Mark Estey, July 23 2019: Update for 3.7.19.2
				)

		INSERT INTO #mergejoins
		SELECT *
		FROM mergejoins
		WHERE tablename IN (
				'facility'
				,'sec_user'
				,'sec_user_role'
				,'sec_user_facility'
				-- Commented By: Jaspreet Singh, Date: 2020-12-29, Reason: Nigel email on 12/29/2020
				--,'fac_message'
				,'sec_user_physical_id'
				,'sec_user_secondary_pcc'
				,'sec_user_secondary'
				-- Added By: Jaspreet Singh, Date: 2017-02-22
				,'pns_subscription'
				-- Added By: Jaspreet Singh, Date: 2017-06-06, Reason: Check smartsheet Update EI Script Row 24
				,'common_code'
				,'common_code_activation'
				--Added by: Linlin jing, Date: 2017-07-13, Reason: Rina's email on 2017-07-10
				,'sec_user_ext'
				--Added by: Linlin jing, Date: 2018-06-18, Reason: Rina's email 3.7.15.3
				,'sec_user_unlock_pin'
				,'sec_user_unlock_pin_audit'
				,'sec_user_verification_answers' -- Added by Mark Estey, July 23 2019: Update for 3.7.19.2
				)

		-- Added By: Jaspreet Singh
		-- Date: 2017-02-22
		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'pns_provider_type'
				) --No as_std_trigger table---------------------------
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable IN ('pns_provider_type')
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'pns_endpoint_type'
				) --No as_std_trigger table---------------------------
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable IN ('pns_endpoint_type')
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'pns_application'
				) --No as_std_trigger table---------------------------
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable IN ('pns_application')
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'pns_application_provider'
				) --No as_std_trigger table---------------------------
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable IN ('pns_application_provider')
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'pns_application_provider_endpoint'
				) --No as_std_trigger table---------------------------
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable IN ('pns_application_provider_endpoint')
		END

		/**********Change ended here 2017-02-22****************/
		UPDATE mergeTables
		SET QueryFilter = '  AND item_id in  ( (SELECT isnull(position_id,-1) FROM [origDB].sec_user WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  ) and deleted = ''N''  '
		WHERE tablename = 'common_code'

		--		UPDATE mergeTables SET QueryFilter = '  OR userid in ( SELECT distinct a.userid FROM [origDB].cp_sec_user_audit a JOIN [origDB].pho_phys_order_useraudit b on a.cp_sec_user_audit_id = b.created_by_audit_id JOIN [origDB].pho_phys_order c on b.phys_order_id = c.phys_order_id WHERE c.fac_id = [OrigFacId] ) '
		--		WHERE tablename = 'sec_user'  
		IF NOT EXISTS (
				SELECT 1
				FROM #tmpAllModulestoCopy
				WHERE moduleID IN ('E14')
				) --No Security Roles---------------------------
		BEGIN
			DELETE
			FROM #mergeTables
			WHERE tablename = 'sec_user_role'
		END
	END

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('E16')
			) --Alert---------------------------
	BEGIN
		INSERT INTO #mergeTables
		SELECT *
		FROM dbo.mergeTables
		WHERE tablename IN (
				'common_code'
				,'cr_std_alert'
				,'cr_alert'
				,'cr_client_highrisk_alerts'
				,'cr_std_highrisk_desc'
				,'cr_std_alert_complex'
				,'cr_alert_triggered_item_type_category'
				--***************Added By Jaspreet Singh, Date: 2017-04-12, Reason: Check Rina email 3.7.12********
				,'cr_std_alert_activation'
				,'cr_std_alert_activation_audit'
				-- Added By: Jaspreet Singh, Date: 2017-06-06, Reason: Check smartsheet Update EI Script Row 24
				,'common_code_activation'
				-- Added By: Linlin Jing, Date: 2017-11-03, Reason: Check Rina email for 3.7.14
				,'pp_client_highrisk_alert_view_history'
				-- Added By: Mark Estey, Date: 2019-01-22, Reason: Updates to 3.7.17.3 Smartsheet Line 68
				,'cr_alert_note'
				,'cr_alert_note_mapping'
				,'cr_alert_assessment_mapping' -- Added by Mark Estey, July 23 2019: Update for 3.7.19.2
				,'cr_alert_suggestion' -- Added by Mark Estey, July 23 2019: Update for 3.7.19.2
				,'cr_alert_event_type' -- Added by Mark Estey, Sep 13 2019: Update for 4.0.0
				)

		--		in ('common_code','cr_std_immunization','cr_client_immunization','cr_shift_group',
		--															'cr_cust_med','pho_order_type','cr_cust_med_class','cr_std_alert','cr_std_highrisk_desc','as_std_trigger','cr_alert','as_std_trigger',--in here three times
		--															'cr_client_highrisk_alerts','as_assessment','cr_ebox_med','cr_std_alert_complex','cr_immunization_education','cp_std_shift','pho_administration_record','as_std_trigger')
		INSERT INTO #mergejoins
		SELECT *
		FROM mergejoins
		WHERE tablename IN (
				'cr_std_alert'
				,'cr_alert'
				,'cr_client_highrisk_alerts'
				,'cr_std_highrisk_desc'
				,'cr_std_alert_complex'
				,'cr_alert_triggered_item_type_category'
				--***************Added By Jaspreet Singh, Date: 2017-04-12, Reason: Check Rina email 3.7.12********
				,'cr_std_alert_activation'
				,'cr_std_alert_activation_audit'
				-- Added By: Jaspreet Singh, Date: 2017-06-06, Reason: Check smartsheet Update EI Script Row 24
				,'common_code'
				,'common_code_activation'
				-- Added By: Linlin Jing, Date: 2017-11-03, Reason: Check Rina email for 3.7.14
				,'pp_client_highrisk_alert_view_history'
				-- Added By: Mark Estey, Date: 2019-01-22, Reason: Updates to 3.7.17.3 Smartsheet Line 68
				,'cr_alert_note'
				,'cr_alert_note_mapping'
				,'cr_alert_assessment_mapping' -- Added by Mark Estey, July 23 2019: Update for 3.7.19.2
				,'cr_alert_suggestion' -- Added by Mark Estey, July 23 2019: Update for 3.7.19.2
				,'cr_alert_event_type' -- Added by Mark Estey, Sep 13 2019: Update for 4.0.0
				)

		-- Added By: Linlin Jing, Date: 2018-03-12, Reason: Check Rina email, subject: 'RE: Merge Error using old process'
		DELETE
		FROM mergejoins
		WHERE parenttable = 'branded_library_configuration'

		--Add
		UPDATE mergeTables
		SET QueryFilter = '  AND item_id in  ( (SELECT isnull(administration_record_type_id,-1) FROM [origDB].pho_administration_record WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'') UNION (SELECT isnull(facility_type,-1) FROM [origDB].pho_order_type WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'') UNION (SELECT isnull(body_location_id,-1) FROM [origDB].cr_client_immunization WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'') UNION (SELECT isnull(position_id,-1) FROM [origDB].cr_shift_group WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'') ) and deleted = ''N''  '
		WHERE tablename = 'common_code'

		UPDATE mergeTables
		SET QueryFilter = ' AND  (std_alert_id in (select std_alert_id from [origDB].cr_alert where fac_id = -1 or fac_id =[OrigFacId]) OR std_alert_id IN  (select std_alert_id from [origDB].cr_std_highrisk_desc where fac_id = -1 or fac_id =[OrigFacId]))'
		WHERE tablename = 'cr_std_alert'

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'pho_phys_order'
				) --No pho_phys_order table---------------------------
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable = 'pho_phys_order'
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'cr_triggered_item_type_category'
				) --No pho_phys_order table---------------------------
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable = 'cr_triggered_item_type_category'
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'as_std_trigger'
				) --No as_std_trigger table---------------------------
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable IN ('as_std_trigger')
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'as_assessment'
				) --No as_assessment table---------------------------
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable IN ('as_assessment')
		END

		-- START Added by Mark Estey, July 23 2019: Update for 3.7.19.2
		DECLARE @cr_alert_suggestion_filter VARCHAR(MAX) = '    AND (suggestion_type_id IN (7, 8)' -- Always copy these

		IF EXISTS (
				SELECT 1
				FROM #tmpAllModulestoCopy
				WHERE moduleID IN ('E12b')
				) -- If copying CP libraries
			SET @cr_alert_suggestion_filter = @cr_alert_suggestion_filter + ' OR (suggestion_type_id = 1 AND item_id IN (SELECT src_id FROM [stagDB].[prefix]cp_std_need)) OR (suggestion_type_id = 2 AND item_id IN (SELECT src_id FROM [stagDB].[prefix]cp_std_goal)) OR (suggestion_type_id IN (3, 4) AND item_id IN (SELECT src_id FROM [stagDB].[prefix]cp_std_intervention))'

		IF EXISTS (
				SELECT 1
				FROM #tmpAllModulestoCopy
				WHERE moduleID IN ('E9')
				) -- If copying progress notes
			SET @cr_alert_suggestion_filter = @cr_alert_suggestion_filter + ' OR (suggestion_type_id = 5 AND item_id IN (SELECT src_id FROM [stagDB].[prefix]pn_progress_note))'
		SET @cr_alert_suggestion_filter = @cr_alert_suggestion_filter + ')'

		UPDATE mergeTables
		SET QueryFilter = @cr_alert_suggestion_filter
		WHERE tablename = 'cr_alert_suggestion'
			-- END Added by Mark Estey, July 23 2019: Update for 3.7.19.2
	END

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('E17')
			) --Risk Management---------------------------
	BEGIN
		INSERT INTO #mergeTables
		SELECT *
		FROM dbo.mergeTables
		WHERE tablename IN (
				'inc_std_pick_list'
				,'inc_std_pick_list_item'
				,'inc_incident'
				----,'clients' Commented By: Jaspreet Singh, Date: 2018-11-22, Reason: Causing issue in offline rollback scripts and no need of this table in this module
				,'inc_progress_note'
				,'inc_incident'
				,--in twice
				'inc_injury'
				,'inc_note'
				,'inc_response'
				,'inc_notified'
				,'contact'
				,'inc_std_signing_authority'
				,'common_code'
				-- Added By: Jaspreet Singh, Date: 2017-06-06, Reason: Check smartsheet Update EI Script Row 24
				,'common_code_activation'
				,'inc_signature'
				,'inc_witness_statement'
				,'inc_witness_phone_number'
				--Added by: Linlin jing, Date: 2017-07-13, Reason: Rina's email on 2017-07-10
				,'inc_section_code'
				,'inc_section_locked'
				--Added by: Linlin jing, Date: 2018-03-12, Reason: Rina's email on 2018-03-12
				,'inc_injury_audit'
				,'inc_note_audit'
				,'inc_section_locked_audit'
				,'inc_witness_audit'
				)

		INSERT INTO #mergejoins
		SELECT *
		FROM mergejoins
		WHERE tablename IN (
				'inc_std_pick_list_item'
				,'inc_incident'
				,'inc_progress_note'
				,'inc_injury'
				,'inc_note'
				,'inc_response'
				,'inc_notified'
				,'inc_std_signing_authority'
				,'inc_signature'
				,'inc_witness_statement'
				,'inc_witness_phone_number'
				-- Added By: Jaspreet Singh, Date: 2017-06-06, Reason: Check smartsheet Update EI Script Row 24
				,'common_code'
				,'common_code_activation'
				--Added by: Linlin jing, Date: 2017-07-13, Reason: Rina's email on 2017-07-10
				,'inc_section_code'
				,'inc_section_locked'
				--Added by: Linlin jing, Date: 2018-03-12, Reason: Rina's email on 2018-03-12
				,'inc_injury_audit'
				,'inc_note_audit'
				,'inc_section_locked_audit'
				,'inc_witness_audit'
				)

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'pn_progress_note'
				) --No pn_progress_note table---------------------------
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable = 'pn_progress_note'
		END

		--UPDATE mergeTables
		--SET QueryFilter = '  AND item_id in  ( (SELECT isnull(marital_status_id,-1) FROM [origDB].contact WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'') UNION (SELECT isnull(title_id,-1) FROM [origDB].contact WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'') UNION (SELECT isnull(position_id,-1) FROM [origDB].inc_std_signing_authority WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'') UNION (SELECT isnull(position_id,-1) FROM [origDB].inc_witness_statement WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'')  ) and deleted = ''N''  '
		--WHERE tablename = 'common_code'
		-- Modified By: Linlin Jing, Date: 2017-12-13, Reason: Check smartsheet Update EI Script Row 44
		UPDATE mergeTables
		SET QueryFilter = '  AND item_id in  ( (SELECT isnull(marital_status_id,-1) FROM [origDB].contact WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'') 
		UNION (SELECT isnull(title_id,-1) FROM [origDB].contact WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'') 
		UNION (SELECT isnull(position_id,-1) FROM [origDB].inc_std_signing_authority WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'') 
		UNION (SELECT isnull(position_id,-1) FROM [origDB].inc_witness_statement WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'') 
		UNION (SELECT isnull(strikeout_reason_id,-1) FROM [origDB].inc_incident WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'') 		
		 ) and deleted = ''N''  '
		WHERE tablename = 'common_code'
	END

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('E18')
			) --Trust---------------------------
	BEGIN
		INSERT INTO #mergeTables
		SELECT *
		FROM dbo.mergeTables
		WHERE tablename IN (
				'common_code'
				,'ta_std_account'
				,'ta_control_account'
				,'ta_batch'
				,'ta_income_source'
				,'ta_client_account'
				,'ta_client_configuration'
				,'ta_client_income_source'
				,'ta_configuration'
				,'ta_item_type'
				,'ta_statement'
				,'ta_transaction'
				,'ta_vendor'
				-- Added By: Jaspreet Singh, Date: 2017-06-06, Reason: Check smartsheet Update EI Script Row 24
				,'common_code_activation'
				,'ta_discharge_option' -- Added by Mark Estey July 25 2019: Requested for copying trust module
				,'ta_interest_calculate_method' -- Added by Mark Estey July 25 2019: Requested for copying trust module
				)

		INSERT INTO #mergejoins
		SELECT *
		FROM mergejoins
		WHERE tablename IN (
				'ta_batch'
				,'ta_client_account'
				,'ta_client_configuration'
				,'ta_client_income_source'
				,'ta_configuration'
				,'ta_item_type'
				,'ta_statement'
				,'ta_transaction'
				-- Added By: Jaspreet Singh, Date: 2017-06-06, Reason: Check smartsheet Update EI Script Row 24
				,'common_code'
				,'common_code_activation'
				,'ta_discharge_option' -- Added by Mark Estey July 25 2019: Requested for copying trust module
				,'ta_interest_calculate_method' -- Added by Mark Estey July 25 2019: Requested for copying trust module
				)

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'ar_lib_payers'
				) --No ar_lib_payers table---------------------------
			DELETE
			FROM mergejoins
			WHERE parenttable = 'ar_lib_payers'

		UPDATE mergeTables
		SET QueryFilter = '  AND item_id in  ( (SELECT isnull(contact_type_id,-1) FROM [origDB].ta_configuration WHERE fac_id in ([OrigFacId],-1) AND DELETED=''N'') ) and deleted = ''N''  '
		WHERE tablename = 'common_code'
	END

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN (
					'E19a'
					,'E19b'
					)
			) --IRM---------------------------
	BEGIN
		INSERT INTO #mergeTables
		SELECT *
		FROM dbo.mergeTables
		WHERE tablename IN (
				'mpi_insurance_coverage'
				,'activity_types'
				,'target_list'
				,'crm_field_config'
				,'crm_configuration'
				,'crm_screen_filters'
				,'crm_code_types'
				,'crm_codes'
				,'crm_code_activity'
				,'crm_code_constants'
				,'crm_inquiry'
				,'crm_referral'
				,'crm_activity'
				,'crm_activity_users'
				,'crm_inquiry_history'
				,'crm_prior_care'
				,'crm_client_needs'
				,'crm_profile_needs'
				,'crm_nonlive_profile_needs'
				,'crm_inquiry_contact'
				,'crm_inquiry_coverage'
				,'crm_constants'
				,'crm_mail_merge'
				,'crm_mail_merge_generation'
				,'crm_map'
				,'crm_map_objective'
				,'crm_map_activity'
				,'crm_map_contributor'
				,'crm_configuration_audit'
				,'crm_field_config_audit'
				,'crm_account_range'
				)

		INSERT INTO #mergejoins
		SELECT *
		FROM mergejoins
		WHERE tablename IN (
				'mpi_insurance_coverage'
				,'crm_screen_filters'
				,'crm_codes'
				,'crm_code_activity'
				,'crm_code_activity'
				,'crm_code_constants'
				,'crm_inquiry'
				,'crm_inquiry'
				,'crm_inquiry'
				,'crm_inquiry'
				,'crm_inquiry'
				,'crm_inquiry'
				,'crm_inquiry'
				,'crm_inquiry'
				,'crm_inquiry'
				,'crm_inquiry'
				,'crm_inquiry'
				,'crm_inquiry'
				,'crm_inquiry'
				,'crm_inquiry'
				,'crm_inquiry'
				,'crm_inquiry'
				,'crm_inquiry'
				,'crm_inquiry'
				,'crm_inquiry'
				,'crm_inquiry'
				,'crm_inquiry'
				,'crm_inquiry'
				,'crm_referral'
				,'crm_referral'
				,'crm_referral'
				,'crm_referral'
				,'crm_referral'
				,'crm_activity'
				,'crm_activity'
				,'crm_activity'
				,'crm_activity'
				,'crm_activity'
				,'crm_activity'
				,'crm_activity_users'
				,'crm_activity_users'
				,'crm_inquiry_history'
				,'crm_inquiry_history'
				,'crm_prior_care'
				,'crm_prior_care'
				,'crm_client_needs'
				,'crm_client_needs'
				,'crm_profile_needs'
				,'crm_profile_needs'
				,'crm_nonlive_profile_needs'
				,'crm_inquiry_contact'
				,'crm_inquiry_contact'
				,'crm_inquiry_coverage'
				,'crm_inquiry_coverage'
				,'crm_mail_merge_generation'
				,'crm_mail_merge_generation'
				,'crm_mail_merge_generation'
				,'crm_mail_merge_generation'
				,'crm_mail_merge_generation'
				,'crm_mail_merge_generation'
				,'crm_map'
				,'crm_map'
				,'crm_map'
				,'crm_map'
				,'crm_map'
				,'crm_map'
				,'crm_map'
				,'crm_map_objective'
				,'crm_map_objective'
				,'crm_map_objective'
				,'crm_map_activity'
				,'crm_map_activity'
				,'crm_map_activity'
				,'crm_map_contributor'
				,'crm_map_contributor'
				,'crm_field_config_audit'
				,'crm_account_range'
				,'crm_mail_merge'
				)

		IF EXISTS (
				SELECT 1
				FROM #tmpAllModulestoCopy
				WHERE moduleID IN (
						'E19a'
						,'E19b'
						)
				) --IRM---------------------------
		BEGIN
			INSERT INTO #mergeTables
			--SELECT * from dbo.mergeTables where tablename in ('contact_relationship[cen001]','contact_type[cen001]')
			SELECT *
			FROM dbo.mergeTables
			WHERE tablename IN (
					'contact_relationship[mpi001]'
					,'contact_relationship[fac001]'
					,'contact_relationship[ext001]'
					,'contact_relationship[cen001]'
					,'contact_type[mpi001]'
					,'contact_type[fac001]'
					,'contact_type[ext001]'
					,'contact_type[cen001]'
					)

			INSERT INTO #mergejoins
			--SELECT * from mergejoins where tablename in ('contact_relationship[cen001]','contact_type[cen001]')
			SELECT *
			FROM mergejoins
			WHERE tablename IN (
					'contact_relationship[mpi001]'
					,'contact_relationship[fac001]'
					,'contact_relationship[ext001]'
					,'contact_relationship[cen001]'
					,'contact_type[mpi001]'
					,'contact_type[fac001]'
					,'contact_type[ext001]'
					,'contact_type[cen001]'
					)
		END

		--Removing the joins and tables because we are not bringing ar_lib_insurance
		DELETE
		FROM mergeTables
		WHERE tablename IN (
				'mpi_insurance_coverage'
				,'crm_inquiry_coverage'
				)

		DELETE
		FROM mergejoins
		WHERE parenttable IN (
				'mpi_insurance_coverage'
				,'crm_inquiry_coverage'
				)

		DELETE
		FROM mergejoins
		WHERE tablename IN (
				'mpi_insurance_coverage'
				,'crm_inquiry_coverage'
				)

		UPDATE mergeTables
		SET QueryFilter = '  AND item_id in  ( (SELECT isnull(ref_phys_subclass_id,-1) FROM [origDB].crm_inquiry WHERE DELETED=''N'') UNION (SELECT isnull(orig_ref_subclass_id,-1) FROM [origDB].crm_inquiry WHERE DELETED=''N'') UNION (SELECT isnull(subclass_id,-1) FROM [origDB].crm_mail_merge_generation WHERE DELETED=''N'') UNION (SELECT isnull(contact_type_id,-1) FROM [origDB].crm_mail_merge_generation WHERE DELETED=''N'') UNION (SELECT isnull(subclass_id,-1) FROM [origDB].crm_prior_care WHERE DELETED=''N'') UNION (SELECT isnull(subclass_id,-1) FROM [origDB].crm_activity WHERE DELETED=''N'') ) and deleted = ''N'' '
		WHERE tablename = 'common_code'

		UPDATE mergeTables
		SET QueryFilter = ISNULL(QueryFilter, '') + ' AND mpi_id IN (SELECT src_id from [stagDB].[prefix]mpi )'
		WHERE tablename = 'crm_inquiry'

		UPDATE mergeTables
		SET QueryFilter = ISNULL(QueryFilter, '') + ' AND (chairperson_id IS NULL or chairperson_id IN (SELECT src_id from [stagDB].[prefix]sec_user ) or chairperson_id IN (select userid from sec_user) )'
		WHERE tablename = 'crm_map'

		UPDATE mergeTables
		SET QueryFilter = 'and ( inquiry_id in (select src_id from [stagDB].[prefix]crm_inquiry)  or inquiry_id is null ) '
		WHERE tablename = 'crm_activity'
	END

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('E20')
			) --Upload Files---------------------------
	BEGIN
		INSERT INTO #mergeTables
		SELECT *
		FROM dbo.mergeTables
		WHERE tablename IN (
				'upload_categories'
				,'upload_files'
				,'upload_std_category'
				,'file_metadata'
				,'crypto_master_key'
				,'file_category_quota'
				,'file_category_quota_type'
				,'file_metadata_crypto'
				,'file_storage_category_mapping'
				,'upload_files_deleted'
				,'pn_progress_note_upload_file'
				-- Added By: Linlin Jing, Date: 2018-03-08, Reason: Check Rina email for 3.7.15
				,'upload_categories_domain'
				)

		INSERT INTO #mergejoins
		SELECT *
		FROM mergejoins
		WHERE tablename IN (
				'upload_categories'
				,'upload_files'
				,'upload_std_category'
				,'file_metadata'
				,'crypto_master_key'
				,'file_category_quota'
				,'file_category_quota_type'
				,'file_metadata_crypto'
				,'file_storage_category_mapping'
				,'upload_files_deleted'
				,'pn_progress_note_upload_file'
				-- Added By: Linlin Jing, Date: 2018-03-08, Reason: Check Rina email for 3.7.15
				,'upload_categories_domain'
				)

		UPDATE mergeTables
		-- SET QueryFilter = ISNULL(QueryFilter, '') + ' AND file_metadata_id IN (SELECT file_id FROM [origDB].result_radiology_report WHERE contact_id IN (SELECT src_id from [stagDB].[prefix]contact))'
		SET QueryFilter = ISNULL(QueryFilter, '') + ' AND (storage_id IN (2, 3) AND file_category_id IN (4, 5))'
		WHERE tablename = 'file_metadata'
	END

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('E21')
			) --Results Lab, Radiology--------------------
	BEGIN
		INSERT INTO #mergeTables
		SELECT *
		FROM dbo.mergeTables
		WHERE tablename IN (
				'emc_ext_facilities'
				,'upload_files'
				,'upload_categories'
				,'file_metadata'
				,'result_action_reason'
				,'result_lab_report'
				,'result_Radiology_report'
				,'result_lab_report_action_history'
				,'result_Radiology_report_action_history'
				--,'result_lab_report_action_history_type'
				,'result_lab_report_ancillary'
				,'result_lab_report_detail'
				,'result_lab_report_detail_note'
				,'result_Radiology_report_detail'
				,'result_lab_report_note'
				,'result_lab_report_result_lab_report_category'
				--,'result_lab_report_severity'
				--,'result_lab_report_status'
				--,'result_lab_test_abnormality'
				--,'result_lab_test_condition'
				,'result_order_source'
				--***************Added By: Linlin jing, Date: 2018-06-19, Reason: Check Rina email for 3.7.15
				,'result_order_action_history'
				)

		--,'result_source_type'
		--,'result_type'
		INSERT INTO #mergejoins
		SELECT *
		FROM mergejoins
		WHERE tablename IN (
				'result_action_reason'
				,'result_lab_report'
				,'result_radiology_report'
				,'result_lab_report_action_history'
				,'result_Radiology_report_action_history'
				-- ,'result_lab_report_action_history_type'
				,'result_lab_report_ancillary'
				,'result_lab_report_detail'
				,'result_lab_report_detail_note'
				,'result_Radiology_report_detail'
				,'result_lab_report_note'
				,'result_lab_report_result_lab_report_category'
				--,'result_lab_report_severity'
				--,'result_lab_report_status'
				--,'result_lab_test_abnormality'
				--,'result_lab_test_condition'
				,'result_order_source'
				,'upload_files'
				,'file_metadata'
				--***************Added By: Linlin jing, Date: 2018-06-19, Reason: Check Rina email for 3.7.15
				,'result_order_action_history'
				)

		--,'result_source_type'
		--,'result_type'
		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'result_lab_report_action_history_type'
				) --No pn_progress_note table---------------------------
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable = 'result_lab_report_action_history_type'
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'result_lab_test_condition'
				) --No pn_progress_note table---------------------------
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable = 'result_lab_test_condition'
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'result_source_type'
				) --No pn_progress_note table---------------------------
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable = 'result_source_type'
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'result_type'
				) --No pn_progress_note table---------------------------
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable = 'result_type'
		END

		UPDATE mergeTables
		SET QueryFilter = '  and deleted = ''N'' AND ext_fac_id in (select reporting_lab_ext_fac_id from [origDB].result_order_source where fac_id = [OrigFacId] )  '
		WHERE tablename = 'emc_ext_facilities'

		--UPDATE mergeTables
		----		SET QueryFilter = ISNULL(QueryFilter, '') + ' AND file_metadata_id IN (SELECT file_id FROM [origDB].result_radiology_report WHERE contact_id IN (SELECT src_id from [stagDB].[prefix]contact))'
		--SET QueryFilter = ISNULL(QueryFilter, '') + ' (AND file_metadata_id IN (SELECT t1.file_id FROM [origDB].result_lab_report 
		--t1 INNER JOIN [origDB].file_metadata t2 on t1.file_id = t2.file_metadata_id)
		--OR file_metadata_id IN (SELECT t1.file_id
		--FROM [origDB].result_order_source t1
		--JOIN [origDB].result_radiology_report t2 ON t1.result_order_source_id = t2.result_order_source_id
		--JOIN [origDB].file_metadata t3 ON t3.file_metadata_id = t2.file_id
		--JOIN [stagDB].[prefix]clients t4 ON t4.src_id = t1.client_id))'
		--WHERE tablename = 'file_metadata'
		--Linlin
		UPDATE mergeTables
		--		SET QueryFilter = ISNULL(QueryFilter, '') + ' AND file_metadata_id IN (SELECT file_id FROM [origDB].result_radiology_report WHERE contact_id IN (SELECT src_id from [stagDB].[prefix]contact))'
		SET QueryFilter = ISNULL(QueryFilter, '') + ' AND (file_metadata_id IN (SELECT t1.file_id FROM [origDB].result_lab_report 
		t1 INNER JOIN [origDB].file_metadata t2 on t1.file_id = t2.file_metadata_id)
		OR file_metadata_id IN (SELECT t2.file_id
		FROM [origDB].result_order_source t1
		JOIN [origDB].result_radiology_report t2 ON t1.result_order_source_id = t2.result_order_source_id
		JOIN [origDB].file_metadata t3 ON t3.file_metadata_id = t2.file_id
		JOIN [stagDB].[prefix]clients t4 ON t4.src_id = t1.client_id))'
		WHERE tablename = 'file_metadata'

		DELETE
		FROM mergejoins
		WHERE parenttable IN (
				'result_lab_report_severity'
				,'result_lab_report_status'
				,'result_lab_pcc_test'
				,'result_lab_test_abnormality'
				,'result_lab_report_category'
				)
	END

	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('E22')
			) --Master Insurance
	BEGIN
		INSERT INTO #mergeTables
		SELECT *
		FROM dbo.mergeTables
		WHERE tablename IN (
				'ar_lib_insurance_companies'
				,'ar_insurance_addresses'
				,'ar_lib_insurance_companies_carriers'
				)

		INSERT INTO #mergejoins
		SELECT *
		FROM mergejoins
		WHERE tablename IN (
				'ar_lib_insurance_companies'
				,'ar_insurance_addresses'
				,'ar_lib_insurance_companies_carriers'
				)

		----Comment out by: Linlin Jing, Updated Date:2018-01-11, Updated Reason: SmartSheet - Update EI Script - #46, start
		--IF NOT EXISTS (
		--		SELECT 1
		--		FROM INFORMATION_SCHEMA.TABLES
		--		WHERE TABLE_TYPE = 'BASE TABLE'
		--			AND Table_Name = @caseNo + 'ar_lib_insurance_companies_carriers'
		--		) 
		--BEGIN
		--	DELETE
		--	FROM mergejoins
		--	WHERE parenttable = 'ar_lib_insurance_companies_carriers'
		--END
		----Comment out by: Linlin Jing, Updated Date:2018-01-11, Updated Reason: SmartSheet - Update EI Script - #46, end
		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'ar_lib_insurance_company_attribute_picklist1_item'
				)
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable = 'ar_lib_insurance_company_attribute_picklist1_item'
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'ar_lib_insurance_company_attribute_picklist2_item'
				)
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable = 'ar_lib_insurance_company_attribute_picklist2_item'
		END

		IF NOT EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE'
					AND Table_Name = @caseNo + 'ar_common_code'
				)
		BEGIN
			DELETE
			FROM mergejoins
			WHERE parenttable = 'ar_common_code'
		END

		UPDATE mergeTables
		-- SET QueryFilter = ISNULL(QueryFilter, '') + ' AND file_metadata_id IN (SELECT file_id FROM [origDB].result_radiology_report WHERE contact_id IN (SELECT src_id from [stagDB].[prefix]contact))'
		SET QueryFilter = ISNULL(QueryFilter, '') + ' AND insurance_id IN (select   distinct a.insurance_id   from  
			[origDB].ar_lib_insurance_companies a 
			join  [origDB].ar_insurance_addresses  b
			on a.insurance_id = b.insurance_id 
			join [origDB].ar_client_payer_info c   
			on b.address_id = c.payer_address_id
			join [stagDB].[prefix]clients cl 
			on cl.src_id = c.client_id
			where c.fac_id in ( select src_id from [stagDB].[prefix]facility ) or a.fac_id in (-1) 
			)'
		WHERE tablename = 'ar_lib_insurance_companies'
	END

	----Updated by: Nigel Liang, Updated Date:2020-12-23, Updated Reason: issue fix from 'and a.fac_id in (-1)' to 'or a.fac_id in (-1)'
	----Added by: Linlin Jing, Updated Date:2017-07-13, Updated Reason: SmartSheet - Update EI Script - #23, start
	IF EXISTS (
			SELECT 1
			FROM #tmpModulesCopy
			WHERE moduleID IN ('E23')
			) --Notes---------------------------
	BEGIN
		INSERT INTO #mergeTables
		SELECT *
		FROM dbo.mergeTables
		WHERE tablename IN (
				'admin_note'
				,'admin_note_type'
				)

		INSERT INTO #mergejoins
		SELECT *
		FROM mergejoins
		WHERE tablename IN (
				'admin_note'
				,'admin_note_type'
				)
	END

	----Added by: Linlin Jing, Updated Date:2017-07-13, Updated Reason: SmartSheet - Update EI Script - #23, end
	--Load the audit tables
	INSERT INTO #mergeTables
	SELECT *
	FROM dbo.mergeTables
	WHERE tablename IN (
			SELECT tablename + '_audit'
			FROM #mergeTables
			)
		AND tablename <> 'common_code_activation_audit' ----Added by: Linlin Jing, Updated Date:2017-07-13, Updated Reason: Ann's email on 2017-07-11 (3.7.13)	

	INSERT INTO #mergeJoins
	SELECT *
	FROM dbo.mergeJoins
	WHERE tablename IN (
			SELECT tablename + '_audit'
			FROM #mergeTables
			)
		AND tablename <> 'common_code_activation_audit' ----Added by: Linlin Jing, Updated Date:2017-07-13, Updated Reason: Ann's email on 2017-07-11 (3.7.13)

	--Load it back to mergetables-------------------------------------------------------------------------------------------------------
	--Merge Tables
	DELETE
	FROM mergeTables
	WHERE tablename NOT IN (
			SELECT tablename
			FROM #mergeTables
			)

	--Merge Joins
	DELETE mergeJoins
	FROM mergeJoins mj
	LEFT JOIN #mergejoins tmj ON mj.tablename = tmj.tablename
		AND mj.parenttable = tmj.parenttable
		AND mj.fieldName = tmj.fieldName
		AND mj.parentField = tmj.parentField
	WHERE tmj.tablename IS NULL

	--DELETE FROM MERGE TABLE IF the mapping table already exist
	DELETE
	FROM mergeTables
	WHERE tablename IN (
			SELECT REPLACE(TABLE_NAME, @CaseNo, '') AS TABLE_NAME
			FROM INFORMATION_SCHEMA.TABLES
			WHERE TABLE_NAME LIKE '%' + @CaseNo + '%'
			)
		AND tablename NOT IN (
			'common_code'
			,'file_metadata'
			) --Added 'file_metadata' by: Linlin Jing, Updated Date:2017-07-07, Updated Reason: SmartSheet - Update EI Script - #29

	--To avoid duplicate contact in common_code table
	UPDATE mergeTables
	SET QueryFilter = ISNULL(QueryFilter, '') + ' AND item_id not in (select src_id from [stagDB].[prefix]common_code) '
	WHERE tablename = 'common_code'

	--Added by: Linlin Jing, Updated Date:2017-07-07, Updated Reason: SmartSheet - Update EI Script - #29b, start
	--To avoid duplicate contact in file_metadata table
	UPDATE mergeTables
	SET QueryFilter = ISNULL(QueryFilter, '') + ' AND file_metadata_id not in (select src_id from [stagDB].[prefix]file_metadata) '
	WHERE tablename = 'file_metadata'
		--Added by: Linlin Jing, Updated Date:2017-07-07, Updated Reason: SmartSheet - Update EI Script - #29b, end
END
go

grant execute on [operational].[sproc_facacq_mergeCopyStep3] to public
go



GO

print 'K_Operational_Branch/5_StoredProcedures/sproc_facacq_mergeCopyStep3.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_facacq_mergeCopyStep3.sql',getdate(),'4.4.8_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_Item_Category_ID_Display.sql',getdate(),'4.4.8_06_CLIENT_K_Operational_Branch_US.sql')

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


if exists(select 1 from sys.procedures where name = 'sproc_Item_Category_ID_Display')
begin
	drop procedure operational.sproc_Item_Category_ID_Display
end
GO


/****** Object:  StoredProcedure [operational].[sproc_Item_Category_ID_Display]    Script Date: 11/15/2021 10:10:08 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- author:    lily yin
-- create date: 20211115
-- description:      this sproc will display ar_item_category id and description
-- environment: US and CDN
-- ticket: CORE-97224
-- =============================================
CREATE PROC [operational].[sproc_Item_Category_ID_Display] (
	
	@debug_Me CHAR(1) = 'N'
	
	)
AS
BEGIN
	
	SET XACT_ABORT
		,NOCOUNT ON;

	DECLARE @status_text VARCHAR(3000) = 'Success'

select aic.item_cat_id as [Category ID]
,aic.cat_description as [Category Description]
,case 
	when aic.fac_id=-1 then 'Corporate'
	when fac_id <>-1 and reg_id is not null and state_code is not null then 'State ' + state_code + ' ' + r.short_desc
	when fac_id <>-1 and reg_id is not null and  state_code is null then r.short_desc
	when fac_id <>-1 and reg_id is null and state_code is null then 'Facility ' + convert(varchar(10),fac_id)
	when fac_id<>-1 and reg_id is null and state_code is not null then state_code + ' State Facilities'
	else r.short_desc
	end as [Category Scope]
from ar_item_category aic with (nolock)
left join regions r with (nolock) on r.regional_id=aic.reg_id
where aic.deleted='N'
order by aic.cat_description

SELECT @status_text AS sp_msg

		RETURN 0;

END

GO

print 'K_Operational_Branch/5_StoredProcedures/sproc_Item_Category_ID_Display.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_Item_Category_ID_Display.sql',getdate(),'4.4.8_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_template_status_update.sql',getdate(),'4.4.8_06_CLIENT_K_Operational_Branch_US.sql')

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


if exists(select 1 from sys.procedures where name = 'sproc_template_status_update')
begin
	drop procedure operational.sproc_template_status_update
end
GO

/****** Object:  StoredProcedure [operational].[sproc_template_status_update]    Script Date: 11/10/2021 2:25:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/****** Object:  StoredProcedure [operational].[sproc_template_status_update]    Script Date: 4/28/2021 2:29:38 PM ******/



-- =============================================
-- author:    lily yin
-- create date: 20210421
-- description:      this sproc will update status for the template
-- env:	BOTH US and CDN
-- Ticket: CORE-97131
-- =============================================
CREATE  PROC [operational].[sproc_template_status_update] (
	@tempId int,
	@debugMe char(1) ='N',
	@reference_no varchar(50),
	@username varchar(50)

	)
AS
BEGIN

	SET xact_abort, NOCOUNT ON;
	
	DECLARE @status_text VARCHAR(3000) = 'Success'

	IF @DebugMe = 'Y'
			print 'template status update'

	Declare @original_status varchar(200)
	Declare @new_status varchar(200)

	
	If not exists (select * from ar_lib_statement_export_template where template_id=@tempId)
		begin 
		select 'Not a Valid Template ID' as sp_msg
		end
	Else
			begin try
				
				set @original_status= (select exec_progress from ar_lib_statement_export_template
				where template_id=@tempId)
				
				begin transaction
				
				
				UPDATE ar_lib_statement_export_template
				SET exec_progress='Completed',
				revision_by=@reference_no + '/' + @username,
				revision_date=getdate()
				WHERE template_id= @tempId
				
			
				

				commit transaction

				set @new_status=(
						select exec_progress from ar_lib_statement_export_template
						where template_id=@tempId
						)

				select @tempId as 'Template_id', @original_status as 'Original Status', @new_status as 'New Status'
			
				select @status_text as sp_msg
				
				return 0;
			end try

			begin catch
				set @status_text= Error_Message()

				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION 

				IF @status_text <> ''
				BEGIN
					SELECT @status_text AS sp_error_msg

				RETURN - 100;
				end
			end catch;
	
end
GO




GO

print 'K_Operational_Branch/5_StoredProcedures/sproc_template_status_update.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_template_status_update.sql',getdate(),'4.4.8_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_UpdateCCStandardAmounts.sql',getdate(),'4.4.8_06_CLIENT_K_Operational_Branch_US.sql')

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
		FROM sys.procedures
		WHERE name = 'sproc_UpdateCCStandardAmounts'
		)
BEGIN
	DROP PROCEDURE operational.sproc_UpdateCCStandardAmounts
END
GO


/****** Object:  StoredProcedure [operational].[sproc_UpdateCCStandardAmounts]    Script Date: 11/22/2021 6:38:44 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







-- =============================================
-- author:    lily yin
-- create date: 20210603
-- description:      this sproc will update charge code amount
-- environment: US and CDN
-- ticket: CORE-97224
-- =============================================
CREATE PROC [operational].[sproc_UpdateCCStandardAmounts] (
	@fac_Id INT
	,@mark_up MONEY
	,@new_effective_date DATETIME
	,@item_category_id VARCHAR(MAX)
	,@created_by VARCHAR(20) 
	,@username VARCHAR(20)
	,@debug_Me CHAR(1) = 'N'
	
	)
AS
BEGIN
	
	SET XACT_ABORT
		,NOCOUNT ON;

	DECLARE @status_text VARCHAR(3000) = 'Success'

	IF @debug_Me = 'Y'
		PRINT 'update charge code amount'

	If @fac_Id is null
		begin
			SELECT 'Please enter Facility ID!'  as sp_error_msg	
			RAISERROR (
					'Please enter Facility ID!'
					,16
					,1
					)

				RETURN;
			END

	Else


	Begin

		

		DROP TABLE if exists #item_category_id

		

		DROP TABLE if exists #temp_ar_item_date_range



		DROP TABLE if exists #feescheduleamt



		DROP TABLE if exists #itemtype



		DROP TABLE if exists #fee_schedule_rvu


		DROP TABLE if exists #TB
	
		select @fac_Id as Fac_id,@mark_up as Mark_up_percent,@item_category_id as Item_Category_id,@created_by as Created_by,@new_effective_date as New_effective_date
	


		delete from [operational].[ar_item_date_range_backup_OA18] where backup_date< getdate()-60
		delete from [operational].[ar_item_types_backup_OA18] where backup_date< getdate()-60

	

		SELECT value
		INTO #item_category_id
		FROM string_split(@item_category_id, ',')
		
		BEGIN TRY
	
			SELECT *
		INTO #fee_schedule_rvu
		FROM WesReference.dbo.fee_schedule_rvu WITH (NOLOCK)

		CREATE INDEX idx_nc_fee_schedule_rvu_hcpcs ON #fee_schedule_rvu (hcpcs)

		CREATE INDEX idx_nc_fee_schedule_rvu_effective_date_ineffective_date ON #fee_schedule_rvu (
			effective_date
			,ineffective_date
			)

	
		SELECT l.locality_id
			,l.country_code
			,l.state_code
			,l.fee_schedule_area
			,h.hcpcs AS HCPCS_CODE
			,h.description AS HCPCS_DESC
			,CASE 
				WHEN r.mult_proc = 5
					THEN '1'
				ELSE '0'
				END AS MPPR
			,Cast(r.work_rvu AS FLOAT) * Cast(g.work_gpci AS FLOAT) * Cast(r.conversion_factor AS FLOAT) AS WORK
			,Cast(r.transitioned_non_fac_pe_rvu AS FLOAT) * Cast(g.pe_gpci AS FLOAT) * Cast(r.conversion_factor AS FLOAT) AS PE
			,Cast(r.mp_rvu AS FLOAT) * Cast(g.mp_gpci AS FLOAT) * Cast(r.conversion_factor AS FLOAT) AS MAL_PRACTICE
			,r.conversion_factor AS CONVERSION_FACTOR
			,r.modifier
		INTO #tb
		FROM WesReference.dbo.fee_schedule_locality l WITH (NOLOCK)
		CROSS JOIN WesReference.dbo.fee_schedule_hcpcs h WITH (NOLOCK)
		INNER JOIN (
			SELECT *
			FROM (
				SELECT ROW_NUMBER() OVER (
						PARTITION BY hcpcs
						,modifier ORDER BY effective_date
						) AS row
					,*
				FROM #fee_schedule_rvu WITH (NOLOCK)
				WHERE @new_effective_date BETWEEN effective_date
							
						AND isnull(ineffective_date, getdate() + 365)
				) AS t
			WHERE row = 1
			) r ON r.hcpcs = h.hcpcs
			AND IsNull(r.modifier, '') = IsNull(h.modifier, '')
		INNER JOIN (
			SELECT *
			FROM (
				SELECT ROW_NUMBER() OVER (
						PARTITION BY locality_id ORDER BY effective_date
						) AS row
					,*
				FROM WesReference.dbo.fee_schedule_gpci WITH (NOLOCK)
				WHERE @new_effective_date BETWEEN effective_date
						
						AND isnull(ineffective_date, getdate() + 365)
				) AS t
			WHERE row = 1
			) g ON g.locality_id = l.locality_id
		INNER JOIN ar_configuration ar WITH (NOLOCK) ON g.locality_id = ar.locality_id
		WHERE ar.fac_id = @fac_id

	
		SELECT *
		INTO #feescheduleamt
		FROM (
			SELECT tb.*
				,round(tb.WORK + tb.PE + tb.MAL_PRACTICE, 2) AS TOTAL
				,round((tb.WORK + (tb.PE * .75) + tb.MAL_PRACTICE), 2) AS REDUCED_TOTAL
			FROM #tb tb
			) AS tb1
		WHERE tb1.TOTAL <> 0.00 

		SELECT a.charge_code
			,c.item_type_id
			,a.partb_modifier
			,a.hcpcs_code
			,c.effective_date AS old_effective_date
		INTO #itemtype
		FROM ar_lib_charge_codes a WITH (NOLOCK)
		INNER JOIN ar_item_types b WITH (NOLOCK) ON a.charge_code_id = b.item_type_id
		INNER JOIN ar_item_date_range c WITH (NOLOCK) ON b.item_type_id = c.item_type_id
			AND b.fac_id = c.fac_id
		WHERE isnull(a.hcpcs_code, '') <> ''
			AND b.fac_id = @fac_id
	
			AND (
				c.effective_date = @new_effective_date
		
				OR c.ineffective_date IS NULL
				)
			
	
			AND (@item_category_id IS NULL OR
			(a.category_id IN (
			SELECT value
			FROM #item_category_id))
			)
		
			SELECT DISTINCT a.item_type_id
			,a.old_effective_date
			,@new_effective_date AS effective_date
		
			,NULL AS ineffective_date
			,CONVERT(DECIMAL(10, 2), ROUND((CONVERT(DECIMAL(10, 3), b.total * @mark_up/100)), 2)) AS amount  
			
			,NULL AS value_code
			,NULL AS fee_schedule_amount
			,@fac_id AS fac_id
	
			INTO #temp_ar_item_date_range
			FROM #itemtype a with (nolock)
			INNER JOIN #feescheduleamt b with (nolock) ON ltrim(rtrim(a.hcpcs_code)) = ltrim(rtrim(b.hcpcs_code))
			AND b.modifier IS NULL

		
			SET NOCOUNT OFF

			PRINT 'Fac_id = ' + convert(VARCHAR, @fac_id)
			
			PRINT 'Update amount for the records with the same effective date'

			BEGIN TRANSACTION
				

			INSERT INTO [operational].[ar_item_date_range_backup_OA18] (
			item_type_id
			,effective_date
			,ineffective_date
			,amount
			,value_code
			,fee_schedule_amount
			,fac_id
			,markup_percentage
			,backup_by
			,backup_date
			)
			SELECT c.item_type_id
			,c.effective_date
			,c.ineffective_date
			,c.amount
			,c.value_code
			,c.fee_schedule_amount
			,c.fac_id
			,c.markup_percentage
			,@created_by + '/' + @username
			,getdate()
			FROM ar_item_types b with (nolock)
			INNER JOIN ar_item_date_range c with (nolock) ON b.item_type_id = c.item_type_id
			AND b.fac_id = c.fac_id
			INNER JOIN #temp_ar_item_date_range d with (nolock) ON b.item_type_id = d.item_type_id
			AND c.effective_date = d.old_effective_date
			--and c.ineffective_date is NULL
			WHERE b.fac_id = d.fac_id
			AND c.effective_date = @new_effective_date
			AND b.fac_id = @fac_Id 

			UPDATE c
			SET amount = d.amount
			FROM ar_item_types b
			INNER JOIN ar_item_date_range c ON b.item_type_id = c.item_type_id
			AND b.fac_id = c.fac_id
			INNER JOIN #temp_ar_item_date_range d ON b.item_type_id = d.item_type_id
			AND c.effective_date = d.old_effective_date
			--AND c.ineffective_date IS NULL 
			WHERE b.fac_id = d.fac_id
			AND c.effective_date = @new_effective_date
			AND b.fac_id = @fac_Id


			PRINT 'Update ar_item_date_range with ineffective_date'


			INSERT INTO [operational].[ar_item_date_range_backup_OA18] (
			item_type_id
			,effective_date
			,ineffective_date
			,amount
			,value_code
			,fee_schedule_amount
			,fac_id
			,markup_percentage
			,backup_by
			,backup_date
			)
			SELECT c.item_type_id
			,c.effective_date
			,c.ineffective_date
			,c.amount
			,c.value_code
			,c.fee_schedule_amount
			,c.fac_id
			,c.markup_percentage
			,@created_by +'/' + @username
			,getdate()
			FROM ar_item_types b with (nolock)
			INNER JOIN ar_item_date_range c with (nolock) ON b.item_type_id = c.item_type_id
			AND b.fac_id = c.fac_id
			INNER JOIN #temp_ar_item_date_range d ON b.item_type_id = d.item_type_id
			AND c.effective_date = d.old_effective_date
			AND c.ineffective_date IS NULL
			WHERE b.fac_id = d.fac_id
			AND c.effective_date < @new_effective_date
			AND b.fac_id = @fac_Id


			UPDATE c
			SET ineffective_date = DATEADD(SS, - 1, @new_effective_date)

			FROM ar_item_types b
			INNER JOIN ar_item_date_range c ON b.item_type_id = c.item_type_id
			AND b.fac_id = c.fac_id
			INNER JOIN #temp_ar_item_date_range d ON b.item_type_id = d.item_type_id
			AND c.effective_date = d.old_effective_date
			AND c.ineffective_date IS NULL
			WHERE b.fac_id = d.fac_id
			AND c.effective_date < @new_effective_date	
			AND b.fac_id = @fac_Id 

			PRINT 'Update ar_item_types for revision_by and revision_date'

			INSERT INTO [operational].[ar_item_types_backup_OA18] (
			item_type_id
			,fac_id
			,created_by
			,created_date
			,revision_by
			,revision_date
			,payer_code2
			,backup_by
			,backup_date
			)
			SELECT DISTINCT b.item_type_id
			,b.fac_id
			,b.created_by
			,b.created_date
			,b.revision_by
			,b.revision_date
			,b.payer_code2
			,@created_by +'/' + @username
			,getdate()
			FROM ar_item_types b with (nolock)
			INNER JOIN #temp_ar_item_date_range d ON b.item_type_id = d.item_type_id
			WHERE b.fac_id = d.fac_id
			AND b.fac_id = @fac_Id

			UPDATE b
			SET revision_by = @Created_By +'/' + @username
			,revision_date = getdate()
			FROM ar_item_types b
			INNER JOIN #temp_ar_item_date_range d ON b.item_type_id = d.item_type_id
			WHERE b.fac_id = d.fac_id
			AND b.fac_id = @fac_Id

			

			PRINT 'Insert into ar_item_date_range'


			INSERT INTO ar_item_date_range (
			item_type_id
			,effective_date
			,ineffective_date
			,amount
			,value_code
			,fee_schedule_amount
			,fac_id
			)
			SELECT item_type_id
			,effective_date
			,ineffective_date
			,amount
			,value_code
			,fee_schedule_amount
			,fac_id
			FROM #temp_ar_item_date_range with (nolock)
			WHERE old_effective_date < @new_effective_date
			AND fac_id = @fac_Id 

		

		COMMIT TRANSACTION

		SELECT @status_text AS sp_msg

		RETURN 0;
	END TRY

	BEGIN CATCH
		SET @status_text = Error_Message()

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION 

		IF @status_text <> ''
		BEGIN
			SELECT @status_text AS sp_error_msg

			RETURN - 100
		END
	END CATCH;
	End
	
	
END
GO





GO

print 'K_Operational_Branch/5_StoredProcedures/sproc_UpdateCCStandardAmounts.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_UpdateCCStandardAmounts.sql',getdate(),'4.4.8_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_vendor_resident_extract.sql',getdate(),'4.4.8_06_CLIENT_K_Operational_Branch_US.sql')

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


if exists(select 1 from sys.procedures where name = 'sproc_Vendor_Resident_Extract')
begin
	drop procedure operational.sproc_Vendor_Resident_Extract
end
go

/****** Object:  StoredProcedure [operational].[sproc_Vendor_Resident_Extract]    Script Date: 11/22/2021 6:02:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- author:    lily yin
-- create date: 20210225
-- description:      this sproc will return resident extract based on choice of vendor, it will be applied both US and CDN envs.  This ticket removes kroll reisdent extract
-- env: both CDN and US
-- ticket: CORE-97223
-- =============================================
CREATE PROC [operational].[sproc_Vendor_Resident_Extract] (
	@vendor_type varchar(50),
	@extract_type int,
	@facId varchar(100),
	@debugMe char(1)='N'
	)
AS
BEGIN

	set nocount on; 

	
	
	
	DROP TABLE if exists #fac_genericactive_ids

	
	DROP TABLE if exists #fac_genericfull_ids

	
	DROP TABLE if exists #fac_frameworkqs1active_ids

	
	DROP TABLE if exists #fac_frameworkqs1full_ids

	
	DROP TABLE if exists #fac_frameworkqs1active_nooutpatient_ids

	DROP TABLE if exists #fac_pharmericaactive_nooutpatient_ids



If @vendor_type='Generic'
begin
	if @extract_type=1  -- all active residents
		begin 
			IF @DebugMe = 'Y'
			print 'Generic  Full Residents'
			

			select value into #fac_generifull_ids from string_split(@facId,',')

			select  DISTINCT
			
			f.name Facility_Name,

			c.client_id_number MRN,
			m.first_name First_Name,
			m.middle_name Middle_Name,
			m.last_name Last_Name,
			
			case when ccd.item_description='' or ccd.item_description is null then ''
			else ccd.item_description  
			end as Marital_Status,

			
			case when m.occupations='' or m.occupations is null then ''
			else m.occupations  
			end as Occupation,


		
			case when ccd_rel.item_description='' or ccd_rel.item_description is null then ''
			else ccd_rel.item_description 
			end as religion,

		
			case when cc.item_description='' or cc.item_description is null then ''
			else cc.item_description 
			end as Language,

			
			case when ccd_race.item_description='' or ccd_race.item_description is null then ''
			else ccd_race.item_description 
			end as Race,
			
			case when m.sex='' or m.sex is null then ''
			else m.sex
			end as sex,
			case when m.ssn_sin='' or m.ssn_sin is null then '' else m.ssn_sin end as  Social_Security_Number,
			case when m.date_of_birth='' or m.date_of_birth is null then '' else m.date_of_birth end as DOB,
			case when m.medicare='' or m.medicare is null then '' else m.medicare end as  Medicare_No,
			case when ci.description='' or ci.description is null then '' else ci.description end as Medicaid_No,
			m.address1 Address1,
			m.Address2 Address2,
			m.city City,
			m.prov_state State,
			m.postal_zip_code,
		
			case when c.admission_date='' or c.admission_date is null then ''	
			else convert(varchar(10),cast(c.admission_date as date),110)
			end as Last_Admit_Date,

			
			case when c.discharge_date='' or c.discharge_date is null then ''	
			else convert(varchar(10),cast(c.discharge_date as date),110)
			end as dicharge_date,
			
			case when arpay.description='' or arpay.description is null then ''
			else arpay.description 
			end as Primary_Payer,
			case  when loc.skilled_flag = 'N'then 'NONE' 
			when loc.skilled_flag ='Y' then 'YES'
			when loc.skilled_flag = '' or loc.skilled_flag is null then ''
			else loc.skilled_flag
			end as LOC,
			
			case when unit.unit_desc='' or unit.unit_desc is null then ''
			else unit.unit_desc
			end as Unit,
			
			case when room.room_desc='' or room.room_desc is null then ''
			else room.room_desc
			end as Room,
			
			case when bed.bed_desc='' or bed.bed_desc is null then ''
			else bed.bed_desc
			end as Bed,
			
			case when Guarantor_Relationship='' or Guarantor_Relationship is null then ''
			else Guarantor_Relationship
			end as Guarantor_Relationship,
			
			case when Guarantor_First_name='' or Guarantor_First_name is null then ''
			else Guarantor_First_name
			end as Guarantor_First_name,
			
			case when Guarantor_Last_name='' or Guarantor_Last_name is null then ''
			else Guarantor_Last_name
			end as Guarantor_Last_name,
			
			case when Guarantor_Middle_name='' or Guarantor_Middle_name is null then ''
			else Guarantor_Middle_name
			end as Guarantor_Middle_name,
		
			case when Guarantor_Address1='' or Guarantor_Address1 is null then ''
			else Guarantor_Address1
			end as Guarantor_Address1,

            
			case when Guarantor_Address2='' or Guarantor_Address2 is null then ''
			else Guarantor_Address2
			end as Guarantor_Address2,

			
			case when Guarantor_City='' or Guarantor_City is null then ''
			else Guarantor_City
			end as Guarantor_City,

			
			case when Guarantor_ZipCode='' or Guarantor_ZipCode is null then ''
			else Guarantor_ZipCode
			end as Guarantor_ZipCode,

			
			case when Guarantor_province='' or Guarantor_province is null then ''
			else Guarantor_province
			end as Guarantor_province,

			
			case when Guarantor_Home_Phone='' or Guarantor_Home_Phone is null then ''
			else Guarantor_Home_Phone
			end as Guarantor_Home_Phone,

			
			case when Guarantor_Business_Phone='' or Guarantor_Business_Phone is null then ''
			else Guarantor_Business_Phone
			end as Guarantor_Business_Phone,

			
			case when Guarantor_Office_phone_ext='' or Guarantor_Office_phone_ext is null then ''
			else Guarantor_Office_phone_ext
			end as Guarantor_Office_phone_ext,

			
			case when Emergency_Contact_Relationship='' or Emergency_Contact_Relationship is null then ''
			else Emergency_Contact_Relationship
			end as Emergency_Contact_Relationship,

			
			case when Emergency_contact_first_name='' or Emergency_contact_first_name is null then ''
			else Emergency_contact_first_name
			end as Emergency_contact_first_name,
			
			case when Emergency_contact_Middle_name='' or Emergency_contact_Middle_name is null then ''
			else Emergency_contact_Middle_name
			end as Emergency_contact_Middle_name,

			
			case when Emergency_contact_Last_name='' or Emergency_contact_Last_name is null then ''
			else Emergency_contact_Last_name
			end as Emergency_contact_Last_name,

			
			case when Emergency_contact_Address1='' or Emergency_contact_Address1 is null then ''
			else Emergency_contact_Address1
			end as Emergency_contact_Address1,

			
			case when Emergency_contact_Address2='' or Emergency_contact_Address2 is null then ''
			else Emergency_contact_Address2
			end as Emergency_contact_Address2,

			
			case when Emergency_contact_City='' or Emergency_contact_City is null then ''
			else Emergency_contact_City
			end as Emergency_contact_City,

			
			case when Emergency_contact_State='' or Emergency_contact_State is null then ''
			else Emergency_contact_State
			end as Emergency_contact_State,

			
			case when Emergency_contact_Zip='' or Emergency_contact_Zip is null then ''
			else Emergency_contact_Zip
			end as Emergency_contact_Zip,

			
			case when Emergency_contact_Home_Phone='' or Emergency_contact_Home_Phone is null then ''
			else Emergency_contact_Home_Phone
			end as Emergency_contact_Home_Phone,

			
			case when Emergency_contact_Office_phone='' or Emergency_contact_Office_phone is null then ''
			else Emergency_contact_Office_phone
			end as Emergency_contact_Office_phone,

			
			case when Emergency_contact_Office_phone_ext='' or Emergency_contact_Office_phone_ext is null then ''
			else Emergency_contact_Office_phone_ext
			end as Emergency_contact_Office_phone_ext,
      
			
			case when ProfFirstName='' or ProfFirstName is null then ''
			else ProfFirstName
			end as ProfFirstName,

		
			case when ProfMiddleName='' or ProfMiddleName is null then ''
			else ProfMiddleName
			end as ProfMiddleName,

			
			case when ProfLastName='' or ProfLastName is null then ''
			else ProfLastName
			end as ProfLastName,

			
			case when Attending_Physician_Type='' or Attending_Physician_Type is null then ''
			else Attending_Physician_Type
			end as Attending_Physician_Type,

		
			case when Profaddress1='' or Profaddress1 is null then ''
			else Profaddress1
			end as Profaddress1,

			
			case when Profaddress2='' or Profaddress2 is null then ''
			else Profaddress2
			end as Profaddress2,

			
			case when Profcity='' or Profcity is null then ''
			else Profcity
			end as Profcity,

			
			case when Profprov_state='' or Profprov_state is null then ''
			else Profprov_state
			end as Profprov_state,

			
			case when Profpostal_zip_code='' or Profpostal_zip_code is null then ''
			else Profpostal_zip_code
			end as Profpostal_zip_code,

			
			case when Proffax='' or Proffax is null then ''
			else Proffax
			end as Proffax,

			
			case when Profphone_cell='' or Profphone_cell is null then ''
			else Profphone_cell
			end as Profphone_cell,

		
			case when Profphone_home='' or Profphone_home is null then ''
			else Profphone_home
			end as Profphone_home,

			
			case when Profphone_office='' or Profphone_office is null then ''
			else Profphone_office
			end as Profphone_office,

		
			case when Profphone_office_ext='' or Profphone_office_ext is null then ''
			else Profphone_office_ext
			end as Profphone_office_ext,

			
			case when Profphone_other='' or Profphone_other is null then ''
			else Profphone_other
			end as Profphone_other,

			
			case when Profphone_pager='' or Profphone_pager is null then ''
			else Profphone_pager
			end as Profphone_pager,

			
			case when UPIN='' or UPIN is null then ''
			else UPIN
			end as UPIN,

		
			case when NPI='' or NPI is null then ''
			else NPI
			end as NPI


			FROM clients c
			INNER join mpi m WITH (NOLOCK)
            on c.mpi_id = m.mpi_id
			INNER JOIN facility f WITH (NOLOCK)
			on c.fac_id=f.fac_id
			LEFT JOIN common_code cc WITH (NOLOCK)
            ON m.primary_lang_id=cc.item_id
			LEFT JOIN common_code ccd WITH (NOLOCK)
            ON m.marital_status_id=ccd.item_id
			LEFT JOIN common_code ccd_rel WITH (NOLOCK)
            ON m.religion_id=ccd_rel.item_id
			LEFT JOIN common_code ccd_race WITH (NOLOCK)
            ON m.race_id=ccd_race.item_id       
			LEFT JOIN client_ids ci1 WITH (NOLOCK)
            ON c.client_id=ci1.client_id and ci1.deleted = 'n' and ci1.id_type_id = 6
			LEFT JOIN client_ids ci WITH (NOLOCK)
            ON c.client_id=ci.client_id and ci.deleted = 'n' and ci.id_type_id = 4
			
			left join (select  a.client_id,
            prof_cc.item_description Attending_Physician_Type,
            contact.first_name ProfFirstName,
            contact.middle_name ProfMiddleName,
            contact.last_name  ProfLastName,
            MedAdd.address1 Profaddress1,
            MedAdd.address2 Profaddress2, MedAdd.city Profcity,MedAdd.prov_state Profprov_state,MedAdd.postal_zip_code Profpostal_zip_code,
                   contact.fax Proffax, 
            contact.phone_cell Profphone_cell , contact.phone_home Profphone_home , 
            contact.phone_office Profphone_office, contact.phone_office_ext Profphone_office_ext , contact.phone_other  Profphone_other, contact.phone_pager  Profphone_pager,
                     STAFF.staff_id_number UPIN,STAFF.identifier_npi npi
                        from client_staff a WITH (NOLOCK) inner join staff WITH (NOLOCK)
                        on a.staff_id = staff.contact_id
                        and staff.deleted='N'
						and a.deleted = 'N'
            inner JOIN  CONTACT_ADDRESS  con_addr WITH (NOLOCK)
                  ON STAFF.contact_id = con_addr.contact_id 
            inner JOIN  ADDRESS MedAdd WITH (NOLOCK)
                  ON con_addr.address_id = MedAdd.address_id 
            inner JOIN  COMMON_CODE prof_cc WITH (NOLOCK) 
                  ON STAFF.profession_id = prof_cc.item_id 
                  AND prof_cc.deleted='N' and prof_cc.item_description  = 'Attending Physician'
            inner JOIN  CONTACT contact WITH (NOLOCK) 
                  ON STAFF.contact_id = contact.contact_id ) as attend 
			on c.client_id = attend.client_id



			LEFT JOIN
                  (select 
                  cc2.item_description Guarantor_Relationship,
                  cont1.First_name Guarantor_First_name, cont1.last_name Guarantor_Last_name,cont1.middle_name Guarantor_Middle_name,
                  ad_guar.address1 Guarantor_Address1,
                  ad_guar.address2 Guarantor_Address2,
                  ad_guar.city Guarantor_City,
                  ad_guar.postal_zip_code Guarantor_ZipCode,
                  ad_guar.prov_state Guarantor_province,
                  cont1.phone_home Guarantor_Home_Phone, 
                  cont1.phone_office Guarantor_Business_Phone,
                  cont1.phone_office_ext Guarantor_Office_phone_ext, cr.reference_id,ct.fac_id
                              from contact_relationship cr WITH (NOLOCK)
                              inner join contact_type ct WITH (NOLOCK)
                                    on cr.contact_id = ct.contact_id
                              inner join common_code cc2 WITH (NOLOCK)
                                    on cr.relationship_id=cc2.item_id 
				inner JOIN contact cont1 WITH (NOLOCK)
				on cont1.contact_id = cr.contact_id
				inner JOIN contact_address contad WITH (NOLOCK)
				ON contad.contact_id=cont1.contact_id
				inner JOIN address ad_Guar WITH (NOLOCK)
				ON ad_guar.address_id=contad.address_id
                              inner JOIN  COMMON_CODE con_type_cc_RP WITH (NOLOCK) 
                                    ON ct.type_id = con_type_cc_RP.item_id and con_type_cc_RP.item_description='Responsible Party'
                                    where cr.deleted = 'n' ) RP
				ON m.mpi_id = rp.reference_id and c.fac_id = rp.fac_id
				LEFT JOIN (select distinct 
                        cc3.item_description Emergency_Contact_Relationship,
                              cont2.First_name Emergency_contact_first_name,
                             cont2.Middle_name Emergency_contact_Middle_name,
                              cont2.Last_name Emergency_contact_Last_name,
                              ad1.Address1 Emergency_contact_Address1,
                              ad1.address2 Emergency_contact_Address2,
                              ad1.city Emergency_contact_City,
                              ad1.prov_state Emergency_contact_State,
                              ad1.postal_zip_code Emergency_contact_Zip,
                              cont2.phone_home Emergency_contact_Home_Phone,
                              cont2.phone_office Emergency_contact_Office_phone,
                              cont2.phone_office_ext Emergency_contact_Office_phone_ext,cr1.reference_id,ct1.fac_id
                              from contact_relationship cr1 WITH (NOLOCK)
                              inner join contact_type ct1 WITH (NOLOCK)
                                    on cr1.contact_id = ct1.contact_id
                              inner join common_code cc3 WITH (NOLOCK)
                                    on cr1.relationship_id=cc3.item_id 
                              inner JOIN  COMMON_CODE con_type_cc  WITH (NOLOCK)
                                    ON ct1.type_id = con_type_cc.item_id 
				inner JOIN contact cont2 WITH (NOLOCK)
				ON cont2.contact_id=cr1.contact_id
				inner JOIN contact_address contad1 WITH (NOLOCK)
				ON contad1.contact_id=cont2.contact_id
				inner JOIN address ad1 WITH (NOLOCK)
				ON ad1.address_id=contad1.address_id      
                              where cr1.deleted = 'n' and con_type_cc.item_description  = 'Emergency Contact') EM
				ON m.mpi_id = EM.reference_id  and c.fac_id = em.fac_id
				LEFT JOIN census_item cenit WITH (NOLOCK) ON c.current_census_id=cenit.census_id and c.fac_id = cenit.fac_id
				LEFT JOIN bed WITH (NOLOCK) ON bed.bed_id=cenit.bed_id
				LEFT JOIN room WITH (NOLOCK) ON bed.room_id=room.room_id
				LEFT JOIN unit WITH (NOLOCK) ON unit.unit_id=room.unit_id
				LEFT JOIN (
                  select skilled_Flag,effective_date,client_id,fac_id from(    
                  select row_number() over (partition by client_id order by effective_date desc) row_num,*
                        from adt_client_loc WITH (NOLOCK)) A where row_num=1
                       )LOC 
				ON c.client_id=loc.client_id and c.fac_id=loc.fac_id
				LEFT JOIN ar_lib_payers arpay WITH (NOLOCK)
				ON arpay.payer_id=cenit.primary_payer_id

				WHERE 
			
				c.deleted = 'N'
				and c.fac_id in (select value from #fac_generifull_ids)
				
				order by 1,3
		end
		
		

	else if @extract_type=2
			
		begin

			IF @DebugMe = 'Y'
			print 'Generic Active Residents'

			select value into #fac_genericactive_ids from string_split(@facId,',')


			select  DISTINCT
			
			f.name Facility_Name,

			c.client_id_number MRN,
			m.first_name First_Name,
			case when m.middle_name='' or m.middle_name is null then '' else m.middle_name end as Middle_Name,
			m.last_name Last_Name,
			
			case when ccd.item_description='' or ccd.item_description is null then ''
			else ccd.item_description  
			end as Marital_Status,

			--
			case when m.occupations='' or m.occupations is null then ''
			else m.occupations  
			end as Occupation,


			
			case when ccd_rel.item_description='' or ccd_rel.item_description is null then ''
			else ccd_rel.item_description 
			end as religion,

			
			case when cc.item_description='' or cc.item_description is null then ''
			else cc.item_description 
			end as Language,

			
			case when ccd_race.item_description='' or ccd_race.item_description is null then ''
			else ccd_race.item_description 
			end as Race,
			
			case when m.sex='' or m.sex is null then ''
			else m.sex
			end as sex,
			case when m.ssn_sin='' or m.ssn_sin is null then '' else m.ssn_sin end as Social_Security_Number,
			case when m.date_of_birth='' or m.date_of_birth is null then '' else m.date_of_birth end as DOB,
			case when m.medicare='' or m.medicare is null then '' else m.medicare end as Medicare_No,
			case when ci.description='' or ci.description is null then '' else ci.description end as Medicaid_No,
			m.address1 Address1,
			m.Address2 Address2,
			m.city City,
			m.prov_state State,
			m.postal_zip_code,
			
			case when c.admission_date='' or c.admission_date is null then ''	
			else convert(varchar(10),cast(c.admission_date as date),110)
			end as Last_Admit_Date,

			
			
			case when c.discharge_date='' or c.discharge_date is null then ''	
			else convert(varchar(10),cast(c.discharge_date as date),110)
			end as dicharge_date,
			
			case when arpay.description='' or arpay.description is null then ''
			else arpay.description 
			end as Primary_Payer,
			case  when loc.skilled_flag = 'N'then 'NONE' 
			when loc.skilled_flag ='Y' then 'YES'
			when loc.skilled_flag = '' or loc.skilled_flag is null then ''
			else loc.skilled_flag
			end as LOC,
			
			case when unit.unit_desc='' or unit.unit_desc is null then ''
			else unit.unit_desc
			end as Unit,
			
			case when room.room_desc='' or room.room_desc is null then ''
			else room.room_desc
			end as Room,
		
			case when bed.bed_desc='' or bed.bed_desc is null then ''
			else bed.bed_desc
			end as Bed,
			
			case when Guarantor_Relationship='' or Guarantor_Relationship is null then ''
			else Guarantor_Relationship
			end as Guarantor_Relationship,
			
			case when Guarantor_First_name='' or Guarantor_First_name is null then ''
			else Guarantor_First_name
			end as Guarantor_First_name,
			
			case when Guarantor_Last_name='' or Guarantor_Last_name is null then ''
			else Guarantor_Last_name
			end as Guarantor_Last_name,
			
			case when Guarantor_Middle_name='' or Guarantor_Middle_name is null then ''
			else Guarantor_Middle_name
			end as Guarantor_Middle_name,
			
			case when Guarantor_Address1='' or Guarantor_Address1 is null then ''
			else Guarantor_Address1
			end as Guarantor_Address1,

            
			case when Guarantor_Address2='' or Guarantor_Address2 is null then ''
			else Guarantor_Address2
			end as Guarantor_Address2,

			
			case when Guarantor_City='' or Guarantor_City is null then ''
			else Guarantor_City
			end as Guarantor_City,

			
			case when Guarantor_ZipCode='' or Guarantor_ZipCode is null then ''
			else Guarantor_ZipCode
			end as Guarantor_ZipCode,

			
			case when Guarantor_province='' or Guarantor_province is null then ''
			else Guarantor_province
			end as Guarantor_province,

			
			case when Guarantor_Home_Phone='' or Guarantor_Home_Phone is null then ''
			else Guarantor_Home_Phone
			end as Guarantor_Home_Phone,

			
			case when Guarantor_Business_Phone='' or Guarantor_Business_Phone is null then ''
			else Guarantor_Business_Phone
			end as Guarantor_Business_Phone,

		
			case when Guarantor_Office_phone_ext='' or Guarantor_Office_phone_ext is null then ''
			else Guarantor_Office_phone_ext
			end as Guarantor_Office_phone_ext,

		
			case when Emergency_Contact_Relationship='' or Emergency_Contact_Relationship is null then ''
			else Emergency_Contact_Relationship
			end as Emergency_Contact_Relationship,

			
			case when Emergency_contact_first_name='' or Emergency_contact_first_name is null then ''
			else Emergency_contact_first_name
			end as Emergency_contact_first_name,
		
			case when Emergency_contact_Middle_name='' or Emergency_contact_Middle_name is null then ''
			else Emergency_contact_Middle_name
			end as Emergency_contact_Middle_name,

			
			case when Emergency_contact_Last_name='' or Emergency_contact_Last_name is null then ''
			else Emergency_contact_Last_name
			end as Emergency_contact_Last_name,

			
			case when Emergency_contact_Address1='' or Emergency_contact_Address1 is null then ''
			else Emergency_contact_Address1
			end as Emergency_contact_Address1,

			
			case when Emergency_contact_Address2='' or Emergency_contact_Address2 is null then ''
			else Emergency_contact_Address2
			end as Emergency_contact_Address2,

			
			case when Emergency_contact_City='' or Emergency_contact_City is null then ''
			else Emergency_contact_City
			end as Emergency_contact_City,

			
			case when Emergency_contact_State='' or Emergency_contact_State is null then ''
			else Emergency_contact_State
			end as Emergency_contact_State,

			
			case when Emergency_contact_Zip='' or Emergency_contact_Zip is null then ''
			else Emergency_contact_Zip
			end as Emergency_contact_Zip,

			
			case when Emergency_contact_Home_Phone='' or Emergency_contact_Home_Phone is null then ''
			else Emergency_contact_Home_Phone
			end as Emergency_contact_Home_Phone,

			
			case when Emergency_contact_Office_phone='' or Emergency_contact_Office_phone is null then ''
			else Emergency_contact_Office_phone
			end as Emergency_contact_Office_phone,

			
			case when Emergency_contact_Office_phone_ext='' or Emergency_contact_Office_phone_ext is null then ''
			else Emergency_contact_Office_phone_ext
			end as Emergency_contact_Office_phone_ext,
      
		
			case when ProfFirstName='' or ProfFirstName is null then ''
			else ProfFirstName
			end as ProfFirstName,

			case when ProfMiddleName='' or ProfMiddleName is null then ''
			else ProfMiddleName
			end as ProfMiddleName,

			
			case when ProfLastName='' or ProfLastName is null then ''
			else ProfLastName
			end as ProfLastName,

			
			case when Attending_Physician_Type='' or Attending_Physician_Type is null then ''
			else Attending_Physician_Type
			end as Attending_Physician_Type,

			
			case when Profaddress1='' or Profaddress1 is null then ''
			else Profaddress1
			end as Profaddress1,

			
			case when Profaddress2='' or Profaddress2 is null then ''
			else Profaddress2
			end as Profaddress2,

			
			case when Profcity='' or Profcity is null then ''
			else Profcity
			end as Profcity,

			case when Profprov_state='' or Profprov_state is null then ''
			else Profprov_state
			end as Profprov_state,

			
			case when Profpostal_zip_code='' or Profpostal_zip_code is null then ''
			else Profpostal_zip_code
			end as Profpostal_zip_code,

		
			case when Proffax='' or Proffax is null then ''
			else Proffax
			end as Proffax,

			
			case when Profphone_cell='' or Profphone_cell is null then ''
			else Profphone_cell
			end as Profphone_cell,

			
			case when Profphone_home='' or Profphone_home is null then ''
			else Profphone_home
			end as Profphone_home,

			
			case when Profphone_office='' or Profphone_office is null then ''
			else Profphone_office
			end as Profphone_office,

			case when Profphone_office_ext='' or Profphone_office_ext is null then ''
			else Profphone_office_ext
			end as Profphone_office_ext,

			
			case when Profphone_other='' or Profphone_other is null then ''
			else Profphone_other
			end as Profphone_other,

			
			case when Profphone_pager='' or Profphone_pager is null then ''
			else Profphone_pager
			end as Profphone_pager,

			
			case when UPIN='' or UPIN is null then ''
			else UPIN
			end as UPIN,

			
			case when NPI='' or NPI is null then ''
			else NPI
			end as NPI
			FROM clients c
			INNER join mpi m WITH (NOLOCK)
            on c.mpi_id = m.mpi_id
			INNER JOIN facility f WITH (NOLOCK)
			on c.fac_id=f.fac_id
			LEFT JOIN common_code cc WITH (NOLOCK)
            ON m.primary_lang_id=cc.item_id
			LEFT JOIN common_code ccd WITH (NOLOCK)
            ON m.marital_status_id=ccd.item_id
			LEFT JOIN common_code ccd_rel WITH (NOLOCK)
            ON m.religion_id=ccd_rel.item_id
			LEFT JOIN common_code ccd_race WITH (NOLOCK)
            ON m.race_id=ccd_race.item_id       
			LEFT JOIN client_ids ci1 WITH (NOLOCK)
            ON c.client_id=ci1.client_id and ci1.deleted = 'n' and ci1.id_type_id = 6
			LEFT JOIN client_ids ci WITH (NOLOCK)
            ON c.client_id=ci.client_id and ci.deleted = 'n' and ci.id_type_id = 4
			
			left join (select  a.client_id,
            prof_cc.item_description Attending_Physician_Type,
            contact.first_name ProfFirstName,
            contact.middle_name ProfMiddleName,
            contact.last_name  ProfLastName,
            MedAdd.address1 Profaddress1,
            MedAdd.address2 Profaddress2, MedAdd.city Profcity,MedAdd.prov_state Profprov_state,MedAdd.postal_zip_code Profpostal_zip_code,
                   contact.fax Proffax, 
            contact.phone_cell Profphone_cell , contact.phone_home Profphone_home , 
            contact.phone_office Profphone_office, contact.phone_office_ext Profphone_office_ext , contact.phone_other  Profphone_other, contact.phone_pager  Profphone_pager,
                     STAFF.staff_id_number UPIN,STAFF.identifier_npi npi
                        from client_staff a WITH (NOLOCK) inner join staff WITH (NOLOCK)
                        on a.staff_id = staff.contact_id
                        and staff.deleted='N'
						and a.deleted = 'N' 
            inner JOIN  CONTACT_ADDRESS con_addr WITH (NOLOCK) 
                  ON STAFF.contact_id = con_addr.contact_id 
            inner JOIN  ADDRESS MedAdd  WITH (NOLOCK)
                  ON con_addr.address_id = MedAdd.address_id 
            inner JOIN  COMMON_CODE prof_cc WITH (NOLOCK) 
                  ON STAFF.profession_id = prof_cc.item_id 
                  AND prof_cc.deleted='N' and prof_cc.item_description  = 'Attending Physician'
            inner JOIN  CONTACT contact WITH (NOLOCK) 
                  ON STAFF.contact_id = contact.contact_id ) as attend -- )
			on c.client_id = attend.client_id



			LEFT JOIN
                  (select 
                  cc2.item_description Guarantor_Relationship,
                  cont1.First_name Guarantor_First_name, cont1.last_name Guarantor_Last_name,cont1.middle_name Guarantor_Middle_name,
                  ad_guar.address1 Guarantor_Address1,
                  ad_guar.address2 Guarantor_Address2,
                  ad_guar.city Guarantor_City,
                  ad_guar.postal_zip_code Guarantor_ZipCode,
                  ad_guar.prov_state Guarantor_province,
                  cont1.phone_home Guarantor_Home_Phone, 
                  cont1.phone_office Guarantor_Business_Phone,
                  cont1.phone_office_ext Guarantor_Office_phone_ext, cr.reference_id,ct.fac_id
                              from contact_relationship cr WITH (NOLOCK)
                              inner join contact_type ct WITH (NOLOCK)
                                    on cr.contact_id = ct.contact_id
                              inner join common_code cc2 WITH (NOLOCK)
                                    on cr.relationship_id=cc2.item_id 
					inner JOIN contact cont1 WITH (NOLOCK)
				 on cont1.contact_id = cr.contact_id
				inner JOIN contact_address contad WITH (NOLOCK)
				ON contad.contact_id=cont1.contact_id
				inner JOIN address ad_Guar WITH (NOLOCK)
				ON ad_guar.address_id=contad.address_id
                inner JOIN  COMMON_CODE con_type_cc_RP WITH (NOLOCK) 
                ON ct.type_id = con_type_cc_RP.item_id and con_type_cc_RP.item_description='Responsible Party'
                where cr.deleted = 'n' ) RP
				ON m.mpi_id = rp.reference_id and c.fac_id = rp.fac_id
				LEFT JOIN (select distinct  
                cc3.item_description Emergency_Contact_Relationship,
                cont2.First_name Emergency_contact_first_name,
                cont2.Middle_name Emergency_contact_Middle_name,
                cont2.Last_name Emergency_contact_Last_name,
                ad1.Address1 Emergency_contact_Address1,
                ad1.address2 Emergency_contact_Address2,
                ad1.city Emergency_contact_City,
                ad1.prov_state Emergency_contact_State,
                ad1.postal_zip_code Emergency_contact_Zip,
                cont2.phone_home Emergency_contact_Home_Phone,
                cont2.phone_office Emergency_contact_Office_phone,
                cont2.phone_office_ext Emergency_contact_Office_phone_ext,cr1.reference_id,ct1.fac_id
                from contact_relationship cr1 WITH (NOLOCK)
                inner join contact_type ct1 WITH (NOLOCK)
                on cr1.contact_id = ct1.contact_id
                inner join common_code cc3 WITH (NOLOCK)
                on cr1.relationship_id=cc3.item_id 
                inner JOIN  COMMON_CODE con_type_cc 
                ON ct1.type_id = con_type_cc.item_id 
				inner JOIN contact cont2 WITH (NOLOCK)
				ON cont2.contact_id=cr1.contact_id
				inner JOIN contact_address contad1 WITH (NOLOCK)
				ON contad1.contact_id=cont2.contact_id
				inner JOIN address ad1 WITH (NOLOCK)
				ON ad1.address_id=contad1.address_id      
                where cr1.deleted = 'n' and con_type_cc.item_description  = 'Emergency Contact') EM
				ON m.mpi_id = EM.reference_id  and c.fac_id = em.fac_id
				LEFT JOIN census_item cenit WITH (NOLOCK) ON c.current_census_id=cenit.census_id and c.fac_id = cenit.fac_id
				LEFT JOIN bed WITH (NOLOCK) ON bed.bed_id=cenit.bed_id
				LEFT JOIN room WITH (NOLOCK) ON bed.room_id=room.room_id
				LEFT JOIN unit WITH (NOLOCK) ON unit.unit_id=room.unit_id
				LEFT JOIN (
                  select skilled_Flag,effective_date,client_id,fac_id from(    
                  select row_number() over (partition by client_id order by effective_date desc) row_num,*
                        from adt_client_loc WITH (NOLOCK)) A where row_num=1
                       )LOC 
				ON c.client_id=loc.client_id and c.fac_id=loc.fac_id
				LEFT JOIN ar_lib_payers arpay WITH (NOLOCK)
				ON arpay.payer_id=cenit.primary_payer_id

				WHERE 
				
				c.deleted = 'N'
				and c.fac_id in (select value  from #fac_genericactive_ids)
				AND cenit.record_type='C'  
				AND cenit.status_code_id=42 
				AND cenit.effective_date is not NULL
				and discharge_date is null
				
				order by 1,3		
			end


	else
			begin
				SELECT 'Invalid Resident Extract Type!'  as sp_error_msg

				RAISERROR (
				'Invalid Resident Extract Type!'
				,16
				,1
				)

				RETURN;
				
			END
	end

else if @vendor_type='Framework or QS1'
	begin
		if @extract_type=1  
			begin 
				IF @DebugMe = 'Y'
				print 'Framework or QS1  Full Residents'
			

				select value into #fac_frameworkqs1full_ids from string_split(@facId,',')

		
				select f.fac_id as 'Facility Id'
				,convert(varchar(20),c.client_id) as 'PCC Client ID'
				,m.first_name as 'First Name'
				,m.last_name as 'Last Name'
				,case when m.date_of_birth is null then ''
				else CONVERT(VARCHAR (10),m.date_of_birth,120) end as 'Date of Birth'
				,case when m.ssn_sin is null then ''
				else m.ssn_sin end as 'SSN'
				,case when m.sex is null then ''
				else m.sex end as 'Gender'
				,case when c.admission_date is null then ''
				else CONVERT(VARCHAR (20),c.admission_date,120)end as 'Admission Date'
				,Case when c.discharge_date is null then ''
				Else CONVERT(VARCHAR (20),c.discharge_date,120)end as 'Discharge Date'
				,case when c.client_id_number is null then ''
				else c.client_id_number end as 'MRN'
				from clients c WITH (nolock)
				join mpi m WITH (nolock)
				on m.mpi_id=c.mpi_id
				left join census_item ci WITH (nolock)
				on ci.census_id=c.current_census_id
				left join facility f with (nolock)
				on c.fac_id=f.fac_id
				where c.deleted='N'
				
				and c.fac_id in (select value  from #fac_frameworkqs1full_ids)
				and c.current_census_id is not null
				and m.deceased_date is null
				
				order by 1 asc,9 desc,8 desc,4
			end

		else if @extract_type=2  
			begin 
				IF @DebugMe = 'Y'
				print 'Framework or QS1 Active Residents'

				select value into #fac_frameworkqs1active_ids from string_split(@facId,',')


				select  f.fac_id as 'Facility Id'
				,convert(varchar(20),c.client_id)  as 'PCC Client ID'
				,  m.first_name  as 'First Name'
				,  m.last_name   as 'Last Name'
				, case when m.date_of_birth is null then ''
				else  CONVERT(VARCHAR (10),m.date_of_birth,120) end as 'Date of Birth'
				,case when m.ssn_sin is null then ''
				else  m.ssn_sin  end as 'SSN'
				,case when m.sex is null then ''
				else  m.sex  end as 'Gender'
				,case when c.admission_date is null then ''
				else  CONVERT(VARCHAR (20),c.admission_date,120)  end as 'Admission Date'
				, Case when c.discharge_date is null then ''
				Else  CONVERT(VARCHAR (20),c.discharge_date,120)  end as 'Discharge Date'
				,case when c.client_id_number is null then ''
				else  c.client_id_number  end as 'MRN'
				from clients c WITH (nolock)
				join mpi m WITH (nolock)
				on m.mpi_id=c.mpi_id
				left join census_item ci WITH (nolock)
				on ci.census_id=c.current_census_id
				left join facility f with (nolock)
				on f.fac_id=c.fac_id
				where c.deleted='N'
				
				and c.fac_id in (select value  from #fac_frameworkqs1active_ids)
				and c.admission_date is not null
				and c.discharge_date is null
				and c.current_census_id is not null
				and (ci.outpatient_status is null or ci.outpatient_status='A')
				
				order by 1 asc,9 desc,8 desc,3
			end

		else if @extract_type = 3
			begin
				IF @DebugMe = 'Y'
				print 'Framework or QS1 active residents no outpatients'

				select value into #fac_frameworkqs1active_nooutpatient_ids from string_split(@facId,',')

				select  f.fac_id as 'Facility Id'
				,convert(varchar(20),c.client_id)  as 'PCC Client ID'
				,  m.first_name  as 'First Name'
				,  m.last_name   as 'Last Name'
				, case when m.date_of_birth is null then ''
				else  CONVERT(VARCHAR (10),m.date_of_birth,120) end as 'Date of Birth'
				,case when m.ssn_sin is null then ''
				else  m.ssn_sin  end as 'SSN'
				,case when m.sex is null then ''
				else  m.sex  end as 'Gender'
				,case when c.admission_date is null then ''
				else  CONVERT(VARCHAR (20),c.admission_date,120)  end as 'Admission Date'
				, Case when c.discharge_date is null then ''
				Else  CONVERT(VARCHAR (20),c.discharge_date,120)  end as 'Discharge Date'
				,case when c.client_id_number is null then ''
				else  c.client_id_number  end as 'MRN'
				from clients c WITH (nolock)
				join mpi m WITH (nolock)
				on m.mpi_id=c.mpi_id
				left join census_item ci WITH (nolock) on ci.census_id=c.current_census_id
				LEFT JOIN ar_lib_payers p WITH (NOLOCK) ON p.payer_id = ci.primary_payer_id AND p.deleted = 'N'
				left join facility f with (nolock)
				on f.fac_id=c.fac_id
				where c.deleted='N'
				
				and c.fac_id in (select value  from #fac_frameworkqs1active_nooutpatient_ids)
				and c.admission_date is not null
				and c.discharge_date is null
				and c.current_census_id is not null
				and ISNULL(p.payer_type,'') NOT IN ('Outpatient')
				
				order by 1 asc,9 desc,8 desc,3
			end

		else
			begin
				SELECT 'Invalid Resident Extract Type!'  as sp_error_msg

				RAISERROR (
				'Invalid Resident Extract Type!'
				,16
				,1
				)

				RETURN;
				
			END
	end

	else if @vendor_type='Pharmerica'
		begin
			if @extract_type = 3
				begin
					IF @DebugMe = 'Y'
					print ' Pharmerica active residents no outpatients'

				select value into #fac_pharmericaactive_nooutpatient_ids from string_split(@facId,',')

				SELECT f.fac_id as 'Facility Id'
				,CONVERT(VARCHAR(20), c.client_id) AS 'PCC Client ID'
				, m.first_name AS 'First Name'
				, m.last_name  AS 'Last Name'
				, CONVERT(VARCHAR(10), m.date_of_birth, 120) AS 'Date of Birth'
				, m.ssn_sin AS 'SSN'
				, m.sex AS 'Gender'
				FROM clients c WITH (NOLOCK)
				INNER JOIN mpi m WITH (NOLOCK) ON m.mpi_id=c.mpi_id
				INNER JOIN census_item ci WITH (NOLOCK) ON ci.census_id=c.current_census_id
				LEFT JOIN ar_lib_payers p WITH (NOLOCK) ON p.payer_id = ci.primary_payer_id AND p.deleted = 'N'
				Left join facility f with (nolock) on f.fac_id=c.fac_id
				WHERE c.deleted='N'
				
				and c.fac_id in (select value  from #fac_pharmericaactive_nooutpatient_ids)
				AND c.admission_date IS NOT NULL
				AND c.discharge_date IS NULL
				AND c.current_census_id IS NOT NULL
				AND ISNULL(p.payer_type, '') NOT IN ('Outpatient')
				
				order by 1,3,4
			end
		else
			begin

				SELECT 'Invalid Resident Extract Type!'  as sp_error_msg

				RAISERROR (
				'Invalid Resident Extract Type!'
				,16
				,1
				)

				RETURN;
				
			END
	end

	
Else
			begin

				SELECT 'Invalid Vendor Type!'  as sp_error_msg

				RAISERROR (
				'Invalid Vendor Type!'
				,16
				,1
				)

				RETURN;

			end
	

end

GO




GO

print 'K_Operational_Branch/5_StoredProcedures/sproc_vendor_resident_extract.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_vendor_resident_extract.sql',getdate(),'4.4.8_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/US_Only/Sproc_omni_payer_mapping_report.sql',getdate(),'4.4.8_06_CLIENT_K_Operational_Branch_US.sql')

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


if exists(select 1 from sys.procedures where name = 'sproc_omni_payer_mapping_report')
begin
	drop procedure operational.sproc_omni_payer_mapping_report
end
GO


/****** Object:  StoredProcedure [operational].[sproc_payer_plan_type_code_update]    Script Date: 9/1/2021 1:37:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- author:    lily yin
-- create date: 20210921
-- description:      this sproc will return omni payer mapping report
-- env:  US only
-- Ticket #: core-96542
-- =============================================
Create PROC [operational].[sproc_omni_payer_mapping_report] (
		@debugMe CHAR(1) = 'N'
	)
AS
BEGIN
	
	DECLARE @status_text VARCHAR(3000) = 'Success'

	IF @debugMe='Y'
		Print 'OMNI Payer Mapping Report'

	

	IF not EXISTS (
			SELECT *
			FROM ar_lib_payers alp WITH (NOLOCK)
			INNER JOIN common_code cc with (nolock) ON cc.item_id = alp.payer_reporting_group
				AND alp.deleted = 'N'
				AND alp.payer_reporting_group IS NOT NULL
			WHERE alp.pay_plan_type_code IS NULL
				OR alp.pay_plan_type_code = ''
				and cc.item_description<>'other'
				and cc.deleted='N'
				and cc.item_code='pyrrpg'
			)
				begin
					IF (OBJECT_ID('tempdb..#mapping', 'U') IS NOT NULL)
					DROP TABLE #mapping

					IF (OBJECT_ID('tempdb..#temp_final', 'U') IS NOT NULL)
					DROP TABLE #temp_final

					DECLARE @listcol varchar(2000)
					DECLARE	@query nvarchar(4000)
					DECLARE	@code_from_OMNI varchar(255)

					SET @code_from_OMNI = '01,03,04,07,08,09,10,11,77,78'

					SELECT items AS mapping_code
					INTO #mapping
					FROM dbo.Split(@code_from_OMNI, ',') T

					SELECT  @listCol = STUFF(( SELECT DISTINCT
									'],[' + ltrim(mapping_code)
							FROM    #mapping
							ORDER BY '],[' + ltrim(mapping_code)
							FOR XML PATH('')), 1, 2, '') + ']'

					set @query=
					'
					SELECT * into #temp_final FROM 
					(
					SELECT pay_plan_type_code as mapping_code,payer_id, payer_type, description, payer_code+ case when len(payer_code2)>0 then ''-'' + payer_code2 else '''' end as payer_code, ''X'' as tag
					from ar_lib_payers with (nolock)
					where deleted=''n'' and pay_plan_type_code IN (SELECT mapping_code FROM #mapping)
					) as c
					pivot (max(tag) for mapping_code in ('+@listCol+')) as pvt
					select payer_id as [Payer ID], payer_type as [Payer Type], description as Description, payer_code as [Payer Code], 
					case when [01]='' '' or [01] is null then '' ''
					else [01]
					end as [01=Private], 
					case when [03]='' '' or [03] is null then '' ''
					else [03]
					end as [03=Medicaid], 
					case when [04]='' '' or [04] is null then '' ''
					else [04]
					end as [04=Medicare A], 
					case when [07]='' '' or [07] is null then '' ''
					else [07]
					end as [07=Hospice], 
					case when [08]='' '' or [08] is null then '' ''
					else [08]
					end as [08=Managed 	Care], 
					case when [09]='' '' or [09] is null then '' ''
					else [09]
					end as [09=Veteran], 
					case when [10]='' '' or [10] is null then '' ''
					else [10]
					end as [10=Workers Comp], 
					case when [11]='' '' or [11] is null then '' ''
					else [11]
					end as [11=Medicaid Pending], 
					case when [77]='' '' or [77] is null then '' ''
					else [77]
					end as [77=Medicaid Bill Facility], 
					case when [78]='' '' or [78] is null then '' ''
					else [78]
					end as [78=Medicare C] 
					from #temp_final
					order by 4
					'

					exec(@query)

					select @status_text AS sp_msg

					return 0;
				end
			Else
				select 'Please update pay plan type code' as sp_msg

				return 0;
					
	
END
GO










GO

print 'K_Operational_Branch/5_StoredProcedures/US_Only/Sproc_omni_payer_mapping_report.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/US_Only/Sproc_omni_payer_mapping_report.sql',getdate(),'4.4.8_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/US_Only/Sproc_opentext_insurance_extract.sql',getdate(),'4.4.8_06_CLIENT_K_Operational_Branch_US.sql')

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




if exists(select 1 from sys.procedures where name = 'sproc_opentext_insurance_extract')
begin
	drop procedure operational.sproc_opentext_insurance_extract
end
GO


/****** Object:  StoredProcedure [operational].[sproc_opentext_insurance_extract]    Script Date: 10/5/2021 4:30:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- author:    lily yin
-- create date: 20211006
-- description:      this sproc will return opentext insurance extract. Opentext EMR-Link Integrated Orders.  Opentext can confirm the name of the provider is the same for our External Facility linked to the provider 
-- as it is in their system.  Mis-matches must be resolved before the Orders Go-Live.
-- env:  US only
-- Ticket #: core-97115
-- =============================================
Create PROC [operational].[sproc_opentext_insurance_extract] (
		@FacId int,
		@OrgCode varchar (50),
		@debugMe CHAR(1) = 'N'
	)
AS
BEGIN
	
	DECLARE @status_text VARCHAR(3000) = 'Success'

	IF @debugMe='Y'
		Print 'opentext_insurance_extract'

	if @facid is not null and @orgcode is not null
		begin
-- external facility

		SELECT f.fac_id AS facID
		,f.name AS [Facility Name]
		,emcex.[name] AS [Hotlisted Provider Name]
		,c.item_description AS [Integration Point]
		FROM emc_ext_facilities emcex WITH (NOLOCK) 
		INNER JOIN ext_facilities extfac WITH (NOLOCK) ON emcex.ext_fac_id = extfac.ext_fac_id
		INNER JOIN facility f WITH (NOLOCK) ON extfac.fac_id = f.fac_id
		INNER JOIN common_code c WITH (NOLOCK) ON c.item_id = emcex.facility_type
		WHERE extfac.fac_id = @FacId
		AND extfac.hotlist_item = 'y'
		AND c.item_code = 'phofac'
		AND c.item_description IN (
		'Radiology'
		,'Laboratory'
		)
		ORDER BY emcex.[name]

-- room,bed

		SELECT fac.NAME AS [Facility Name]
		,f.floor_desc
		,u.unit_desc
		,r.room_desc
		,b.bed_desc
		FROM bed b WITH (NOLOCK)
		INNER JOIN room r WITH (NOLOCK) ON b.room_id = r.room_id
		INNER JOIN [floor] f WITH (NOLOCK) ON f.floor_id = r.floor_id
		INNER JOIN unit u WITH (NOLOCK) ON r.unit_id = u.unit_id
		INNER JOIN facility fac WITH (NOLOCK) ON fac.fac_id = f.fac_id
		WHERE f.deleted = 'n'
		AND f.fac_id = @FacID
		AND u.deleted = 'n'
		AND r.deleted = 'n'
		AND b.deleted = 'n'
		ORDER BY f.floor_desc
		,u.unit_desc
		,r.room_desc
		,b.bed_desc

-- insurance from census picklist

		SELECT 
		case when in_co.description is null then lib.description else in_co.description end AS [Insurance Name] 
		,isnull(lib.payer_type,' ') as [Insurance Abbrev]
		,' ' as [Lab Ins Code]
		,' ' as [Contracted Y/N]
		,' ' as [ABN Required Y/N ]
		,' ' as [Default Bill Type T/C/P]
		,@orgCode+(SELECT RIGHT('0000'+CAST(f.fac_id AS VARCHAR(4)),4)) as [LOC Name] 
		,isnull(addy.address1+ ' ' +addy.address2+ ',' + ' ' + addy.city +','+ ' ' + addy.prov_state +' '+ addy.postal_zip_code, ' ') as Address
		,' ' as [LOC Abbr]
		,' ' as [ABN Form ID]
		,lib.description as [Plan Name]
		FROM ar_lib_payers lib WITH (NOLOCK)
		JOIN ar_payers pay WITH (NOLOCK) ON pay.payer_id = lib.payer_id
		AND pay.fac_id = @FacID
		FULL OUTER JOIN ar_payer_addresses addy_id WITH (NOLOCK) ON pay.payer_id = addy_id.payer_id
		AND pay.fac_id = addy_id.fac_id
		FULL OUTER JOIN ar_insurance_addresses addy WITH (NOLOCK) ON addy_id.address_id = addy.address_id
		FULL OUTER JOIN ar_lib_insurance_companies in_co WITH (NOLOCK) ON addy_id.insurance_id = in_co.insurance_id
		FULL OUTER JOIN facility f WITH (NOLOCK) ON pay.fac_id = f.fac_id
		WHERE lib.deleted = 'N'
		ORDER BY 1

-- medical professional

		SELECT f.NAME AS [Facility Name]
		,c.last_name
		,c.first_name
		,' ' as UPIN
		,s.identifier_npi AS NPI
		,a.address1
		,a.address2
		,a.city
		,a.prov_state
		,a.postal_zip_code
		FROM staff s WITH (NOLOCK)
		INNER JOIN facility f WITH (NOLOCK) ON s.fac_id = f.fac_id
		INNER JOIN common_code cc WITH (NOLOCK) ON s.profession_id = cc.item_id
		INNER JOIN contact c WITH (NOLOCK) ON s.contact_id = c.contact_id
		LEFT OUTER JOIN contact_address ca WITH (NOLOCK) ON c.contact_id = ca.contact_id
		LEFT OUTER JOIN [address] a WITH (NOLOCK) ON ca.address_id = a.address_id
		WHERE cc.item_code LIKE 'prof%'
		AND (
		cc.item_description LIKE '%phys%'
		OR cc.item_description LIKE '%gist%'
		OR cc.item_description LIKE 'nurse practitioner'
		)
		AND s.deleted = 'N'
		AND s.identifier_npi LIKE '[1-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
		AND s.identifier_npi <> ''
		AND f.fac_id = @FacID
		ORDER BY c.last_name

	


	select @status_text AS sp_msg

	return 0;
	end
Else
	select 'Please enter orgcode and facility id' as sp_msg

	return 100;
					
	
END
GO


GO

print 'K_Operational_Branch/5_StoredProcedures/US_Only/Sproc_opentext_insurance_extract.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/US_Only/Sproc_opentext_insurance_extract.sql',getdate(),'4.4.8_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.8_06_CLIENT_K_Operational_Branch_US.sql')

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
values ('4.4.8_K', 'upload_history')


GO

print '..\Update db version.sql --****SCRIPT DONE****'

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.8_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking (script,timestamp,upload) values ('UPLOAD END',getdate(),'4.4.8_06_CLIENT_K_Operational_Branch_US.sql')