
-- connect to con src
SELECT @@SERVERNAME, @@VERSION
USE [master]
DROP DATABASE [pcc_staging_db59618];




-- new from template
--RESTORE DATABASE pcc_staging_db59618
--FROM  URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/template/FULL_us_template_pccsingle_tmpltOH.bak'

USE [master]
RESTORE DATABASE pcc_staging_db59618 
FROM  URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/full_us_template_pccsingle_tmpltMS_TSFacAcq_March31.bak'



--truncate table  pcc_staging_db59618.[dbo].MergeLog
use pcc_staging_db59618

truncate table  pcc_staging_db59618.[dbo].MergeLog





ALTER TABLE dbo.pho_schedule_details
DISABLE CHANGE_TRACKING;  

ALTER TABLE pho_schedule_details 
DROP CONSTRAINT  pho_schedule_details__phoScheduleDetailId_PK;

DROP INDEX   IF  EXISTS pho_schedule_details__scheduleDate_CL ON  pho_schedule_details;

ALTER TABLE pho_schedule_details ADD CONSTRAINT pho_schedule_details__phoScheduleDetailId_PK
PRIMARY KEY CLUSTERED (pho_schedule_detail_id);



ALTER TABLE dbo.pho_schedule_details
ENABLE CHANGE_TRACKING;  

---as_response
ALTER TABLE dbo.as_response
DISABLE CHANGE_TRACKING;  



ALTER TABLE as_response_collection 
DROP CONSTRAINT  as_response_collection__assessResponseId_FK;

ALTER TABLE as_response_trigger_item 
DROP CONSTRAINT  as_response_trigger_item__assessResponseId_FK;

ALTER TABLE as_response 
DROP CONSTRAINT  as_response__assessResponseId_PK_IX;

--DROP INDEX   IF  EXISTS as_response__assessResponseId_PK_IX ON  as_response;

DROP INDEX   IF  EXISTS as_response__assessId_questionKey_UQ_CL_IX ON  as_response;

ALTER TABLE as_response  ADD CONSTRAINT as_response__assessResponseId_PK_IX
PRIMARY KEY CLUSTERED (assess_response_id)

CREATE UNIQUE INDEX as_response__assessId_questionKey_UQ_CL_IX ON as_response (assess_id, question_key)



ALTER TABLE dbo.as_response
ENABLE CHANGE_TRACKING;  

ALTER TABLE as_response_collection 
ADD CONSTRAINT as_response_collection__assessResponseId_FK FOREIGN KEY (assess_response_id)
REFERENCES as_response


ALTER TABLE as_response_trigger_item 
ADD CONSTRAINT as_response_trigger_item__assessResponseId_FK FOREIGN KEY (assess_response_id)
REFERENCES as_response





IF EXISTS (
		SELECT 1
		FROM dbo.sysobjects
		WHERE id = object_id(N'[operational].[sproc_facacq_mergeCopyData]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
BEGIN
	DROP PROCEDURE [operational].[sproc_facacq_mergeCopyData]
END
GO

CREATE PROCEDURE [operational].[sproc_facacq_mergeCopyData] @dbOrig VARCHAR(500)
	,@dbStag VARCHAR(500)
	,@dbDest VARCHAR(500)
	,@fac_idO INTEGER
	,@prefix VARCHAR(500) = 'copym_'
	,@USERNAME VARCHAR(500) = 'wescopym'
	,@reg_idToCopy INTEGER = NULL
	,@fac_idToCopyTo INTEGER = NULL
	/*======================================================================================


e.g.
exec  [operational].[sproc_facacq_mergeCopyData] 'test_usei51_EA.dbo.','pcc_staging_db63.dbo.','test_usei63.dbo.',1,'EICase999999','singhja',null,null
=======================================================================================*/
AS
BEGIN
	SET DEADLOCK_PRIORITY 4;

	--SET NOCOUNT ON;
	DECLARE @sql NVARCHAR(max)
		,@sql2 NVARCHAR(max)
		,@sqlTR NVARCHAR(max)
		,@logMsg VARCHAR(max)
		,@insertSQLH VARCHAR(8000)
		,@insertSQLW VARCHAR(8000) --aug 23
		,@insertRH VARCHAR(8000)
		,@insertRW VARCHAR(8000)
		,@insert VARCHAR(MAX)
		,--aug 23
		@insertV VARCHAR(MAX)
		,--aug 23
		@insertFrom VARCHAR(8000)
		,--aug 23
		@insertJoin VARCHAR(8000)
		,--aug 23
		@insertWhere VARCHAR(8000) --aug 23
		,@removeDup VARCHAR(8000)
		,@removeDup1 VARCHAR(8000)
		,@tablename VARCHAR(300)
		,@idField VARCHAR(300)
		,@HasNoPK CHAR(1)
		,@scopeField1 VARCHAR(300)
		,@scopeField2 VARCHAR(300)
		,@scopeField3 VARCHAR(300)
		,@scopeField4 VARCHAR(300)
		,@scopeField5 VARCHAR(300)
		,@scopeField6 VARCHAR(300)
		,@scopeField7 VARCHAR(300)
		,@queryFilter VARCHAR(5000)
		,@cnt BIGINT
		,@fieldName VARCHAR(300) --aug 23
		,@sqlFields VARCHAR(8000)
		,@sFac_idO VARCHAR(20)
		,@count BIGINT
		,@NextKey BIGINT
		,@start_table_id BIGINT
		---- ,@IdentityKey INTEGER
		,@parentTable VARCHAR(300)
		,@parentField VARCHAR(300)
		,@alias VARCHAR(300)
		,--aug 23
		@hasDeleted CHAR(1)
		,@pkJoin CHAR(1)
		,@cleanUpTable CHAR(1)
		,@SQLIndex VARCHAR(500)
		,@SQLHen VARCHAR(max)
		,@SQLDelete VARCHAR(8000)
		,@rowcount BIGINT
		,@INSERTTABLE VARCHAR(500) --aug 23
		,@regField VARCHAR(1)
		,@SpecialCase VARCHAR(500) --aug 23
		---- ,@udaCount INTEGER -- added by: Jaspreet Singh, date: 2016-04-19
		,@ParamDefinition NVARCHAR(500) -- added by: Jaspreet Singh, date: 2018-06-26

	SET @ParamDefinition = N'@retvalOUT BIGINT OUTPUT';

	------------Chunking variable declaration here----------------
	--,@minid BIGINT
	--,@maxid BIGINT
	--,@limit_id INT
	--,@limitWhere VARCHAR(8000)
	--,@vLoop INT
	--,@ChunkCount BIGINT
	--SELECT @vLoop = 500000
	--	,@cnt = 0
	--	,@IdentityKey = 0
	----------------Chunking variable declarartion end here---------
	IF (object_id('tempdb..#mergeCopyData', 'U') IS NOT NULL)
	BEGIN
		DROP TABLE #mergeCopyData
	END

	CREATE TABLE #mergeCopyData (fieldname VARCHAR(300))

	IF (object_id('tempdb..#mergeCopyDataCounter', 'U') IS NOT NULL)
	BEGIN
		DROP TABLE #mergeCopyDataCounter
	END

	CREATE TABLE #mergeCopyDataCounter (counter INTEGER)

	IF (object_id('tempdb..#mergeUDACounter', 'U') IS NOT NULL)
	BEGIN
		DROP TABLE #mergeUDACounter
	END

	CREATE TABLE #mergeUDACounter (counter INTEGER) -- added by: Jaspreet Singh, date: 2016-04-14

	SET NOCOUNT ON

	SELECT @sFac_idO = CONVERT(VARCHAR, @fac_idO)

	---- exec [operational].[sproc_facacq_mergeLogWriter] @dbDest,0
	SELECT @sqlFields = 'SELECT cols.name FROM ' + @dbDest + 'syscolumns cols JOIN ' + @dbDest + 'sysobjects tables ON tables.id = cols.id and tables.uid = user_id(''dbo'') WHERE cols.iscomputed = 0 and tables.name = ''@@NAME@@'' order by colorder'

	/************************************************************************************************************************************
	Added By: Jaspreet Singh
	Date: 2019-02-28
	Reason: CODE START HERE To get 
	************************************************************************************************************************************/
	-- Commented to use orignal fac_id in all tables.
	----DECLARE @dst_fac_id INT, @dst_fac_idO INT
	----SET @dst_fac_id = 0
	----SET @sql = NULL
	----SET @sql = 'IF EXISTS(SELECT 1 FROM ' + @dbStag + 'Multi_Facility where fac_id = ' + convert(VARCHAR(10), @fac_idToCopyTo)+ ')
	----				BEGIN
	----					SELECT @dst_fac_id = Multi_Fac_Id FROM ' + @dbStag + 'Multi_Facility WHERE fac_id = ' + convert(VARCHAR(10), @fac_idToCopyTo) + '
	----				END'
	----EXEC sp_executesql @sql
	----			,N'@dst_fac_id INT OUTPUT'
	----			,@dst_fac_id = @dst_fac_id OUTPUT
	----EXEC [operational].[sproc_facacq_mergeLogWriter] @sql
	----	,0
	--added --cols.is_computed = 0 and --Sept 20
	EXEC [operational].[sproc_facacq_mergeLogWriter] '--Started SP : mergeCopyData'
		,0

	DECLARE c_mergeCopyData CURSOR
	FOR
	SELECT tableName
		,idField
		,scopeField1
		,scopeField2
		,scopeField3
		,scopeField4
		,scopeField5
		,scopeField6
		,scopeField7
		,cleanUpTable
		,queryFilter
		,HasNoPK
	FROM mergeTables
	--WHERE tablename = 'pho_schedule_details'
	ORDER BY tableorder

	OPEN c_mergeCopyData

	FETCH NEXT
	FROM c_mergeCopyData
	INTO @tablename
		,@idField
		,@scopeField1
		,@scopeField2
		,@scopeField3
		,@scopeField4
		,@scopeField5
		,@scopeField6
		,@scopeField7
		,@cleanUpTable
		,@queryFilter
		,@HasNoPK

	WHILE @@FETCH_STATUS <> - 1
		AND @@FETCH_STATUS <> - 2
		--------------------------------------------------------------------------------------------------------------------- START While (1)
	BEGIN
		SET @logMsg = '--Processing Table :' + @tablename

		EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
			,0

		/*MPI Changes*/
		IF @tablename LIKE '%[[]%'
		BEGIN
			SET @SpecialCase = @tablename
			SET @tablename = substring(@tablename, 1, CHARINDEX('[', @tablename) - 1)
		END
		ELSE
		BEGIN
			SET @SpecialCase = NULL
		END

		IF @cleanUpTable = 'Y'
			AND @fac_idToCopyTo IS NOT NULL
		BEGIN
			EXECUTE [operational].sproc_facacq_mergeCleanUpTable @dbDest = @dbStag
				,@tablename = @tablename
				,@fac_id = @fac_idToCopyTo
		END

		SELECT @NextKey = NULL
			,@hasDeleted = 'N'

		SELECT @sql2 = REPLACE(@sqlFields, '@@NAME@@', @tablename)

		INSERT INTO #mergeCopyData
		EXEC (@sql2)

		INSERT INTO #mergeCopyData
		VALUES ('MULTI_FAC_ID') --Virul

		IF @idField IS NOT NULL
		BEGIN
			IF @tablename IN ('facility')
				AND @fac_idToCopyTo IS NOT NULL /*QA_ tables Andrew (2006/06/03)*/
				SELECT @insertSQLH = 'INSERT INTO ' + @dbStag + @prefix + @tablename + ' (src_id,dst_id,corporate)' + ' SELECT ' + @idField + ',' + CONVERT(VARCHAR, @fac_idToCopyTo) + ',''Y''' + ' FROM ' + @dbOrig + @tablename
			ELSE
				SELECT @insertSQLH = 'INSERT INTO ' + @dbStag + @prefix + @tablename + ' (src_id)' + ' SELECT ' + @idField + ' FROM ' + @dbOrig + @tablename + '   '
		END

		/*DELETE ANDREW */
		SET @SQLDelete = 'DELETE a FROM ' + @dbStag + @prefix + @tablename + ' AS a '

		SELECT @insertSQLW = ''
			,@insertWhere = ''
			,@insertJOIN = ''

		SELECT @insertRH = 'INSERT INTO ' + @dbStag + @tablename

		SELECT @count = 0

		--added distinct on july 27/2009
		--modified april 22/2010 to accomodate image data type
		BEGIN
			IF @TABLENAME IN (
					SELECT NAME
					FROM sys.objects
					WHERE type = 'U'
						AND object_id IN (
							SELECT object_id
							FROM sys.columns
							WHERE system_type_id = 34
							)
					)
				SELECT @INSERTV = ' SELECT '
			ELSE
				SELECT @INSERTV = ' SELECT DISTINCT '
		END

		SELECT @INSERT = ' INSERT INTO ' + @dbStag + @TABLENAME + ' ('
			,@INSERTV = @INSERTV

		--add for distinct
		IF EXISTS (
				SELECT 1
				FROM syscolumns
				WHERE id = object_id(@TABLENAME)
					AND NAME = 'reg_id'
				)
			SET @regField = 'Y'
		ELSE
			SET @regField = 'N'

		DECLARE c_mergeCopyDataFields CURSOR
		FOR
		SELECT fieldname
		FROM #mergeCopyData
		WHERE @tablename + '.' + fieldname NOT IN (
				'ar_configuration.mcd_reimbursement_rate'
				,'census_codes.new_id'
				,'census_codes.orig_fac_id'
				,'ar_accounts.new_id_fac2'
				,'as_std_pick_list.fac_id'
				)

		OPEN c_mergeCopyDataFields

		FETCH NEXT
		FROM c_mergeCopyDataFields
		INTO @fieldname

		WHILE @@FETCH_STATUS <> - 1
			AND @@FETCH_STATUS <> - 2
			--------------------------------------------------------------------------------------------------------------------- START While (2)
		BEGIN
			IF @fieldName = 'deleted'
			BEGIN
				SELECT @hasDeleted = 'Y'
			END

			IF @fieldName = 'fac_id'
			BEGIN
				IF @FIELDNAME <> @IDFIELD
					OR @IDFIELD IS NULL
					SELECT @insertJoin = ' JOIN ' + @dbStag + @prefix + 'facility copy_fac '
						--added June 9/10
						+ '  ' +
						--END add June 9/10
						' ON copy_fac.src_id = a.fac_id OR  copy_fac.src_id = ' + @sFac_idO

				IF @sFac_idO IS NOT NULL
				BEGIN
					IF @regfield = 'Y'
						AND @reg_idToCopy IS NOT NULL
						SELECT @insertSQLW = CASE 
								WHEN @insertSQLW = ''
									THEN ' WHERE '
								ELSE @insertSQLW + ' AND '
								END + '(' + @fieldName + ' = ' + @sFac_idO + ' OR ' + @fieldName + ' = -1 OR reg_id = ' + CONVERT(VARCHAR, @reg_idToCopy) + ' ) '
							,@insertWhere = CASE 
								WHEN @insertWhere = ''
									THEN ' WHERE ('
								ELSE @insertWhere + ' AND (a.'
								END + @fieldName + ' IN (' + @sFac_idO + ',-1) OR a.reg_id = ' + CONVERT(VARCHAR, @reg_idToCopy) + ')'
					ELSE
					BEGIN
						SELECT @insertSQLW = CASE 
								WHEN @insertSQLW = ''
									THEN ' WHERE '
								ELSE @insertSQLW + ' AND '
								END + '(' + @fieldName + ' = ' + @sFac_idO + ' OR ' + @fieldName + ' = -1) '

						SELECT @insertWhere = CASE 
								WHEN @insertWhere = ''
									THEN ' WHERE '
								ELSE @insertWhere + ' AND a.'
								END + @fieldName + ' IN (' + @sFac_idO + ',-1)'
					END
				END
			END

			SELECT @INSERT = @INSERT + CASE 
					WHEN @COUNT > 0
						THEN ', '
					ELSE ''
					END + @FIELDNAME
				,@INSERTV = @INSERTV + CASE 
					WHEN @COUNT > 0
						THEN ','
					ELSE ''
					END + CASE 
					WHEN @FIELDNAME = @IDFIELD
						THEN 'b.dst_id '
							--ADDED CRM TABLES SEPT 21
					WHEN @FIELDNAME IN (
							'created_date'
							,'revision_date'
							)
						AND @TABLENAME NOT IN (
							'as_response_history'
							,'as_response'
							,'cp_rev_need'
							,'cp_rev_goal'
							,'cp_rev_intervention'
							,'as_assessment'
							,'care_plan'
							,'cp_rev_review'
							,'diagnosis'
							,'diagnosis_notification'
							,'wv_vitals'
							,'wv_vitals_exception'
							,'cr_std_alert'
							,'pho_phys_order'
							,'pho_phys_order_audit'
							,'pn_progress_note'
							,'pn_text'
							,'fac_message'
							,'CRM_INQUIRY'
							,'crm_activity'
							,'crm_referral'
							,'as_batch'
							,'diagnosis_sheet'
							,'ar_transactions'
							,'ar_invoice'
							,'ADT_CLIENT_LOC'
							,'pho_schedule_vitals'
							,'pho_admin_site_detail'
							,'Pho_order_supply'
							,'allergy'
							,'pho_admin_order'
							,'pho_related_order'
							,'cp_sec_user_audit'
							,'census_item'
							,'file_metadata'
							,'upload_files'
							,'mpi_history'
							,'inc_incident'
							,'inc_note'
							,'inc_signature'
							,'inc_std_signing_authority'
							,'inc_response'
							,'cr_client_immunization'
							,'cr_client_immunization_audit'
							,'diagnosis_audit'
							,'ar_lib_insurance_companies'
							,'ar_insurance_addresses'
							,'client_ext_facilities_audit'
							,'client_staff_audit'
							,'client_ext_facilities'
							,'client_staff'
							,'inc_note_audit' --Added by Linlin Jing, Date: 2018-03-14, Reason: SmartSheet - Update EI Script - Row 52
							,'inc_witness' --Added by Linlin Jing, Date: 2018-03-19, Reason: Rina's email 
							,'inc_witness_audit' --Added by Linlin Jing, Date: 2018-03-19, Reason: Rina's email 
							,'inc_section_locked_audit' --Added by Linlin Jing, Date: 2018-04-13, Reason: Rina's email 
							,'inc_injury_audit' --Added by Jaspreet Singh, Date: 2018-04-20, Reason: Rina's email 
							)
						AND @TABLENAME NOT LIKE 'pho[_]%'
						THEN --MM: exclude client care plan info tables
							'getDate()'
					WHEN @FIELDNAME IN (
							'created_by'
							,'revision_by'
							)
						AND @TABLENAME NOT IN (
							'as_response_history'
							,'as_response'
							,'cp_rev_need'
							,'cp_rev_goal'
							,'cp_rev_intervention'
							,'as_assessment'
							,'care_plan'
							,'cp_rev_review'
							,'diagnosis'
							,'diagnosis_notification'
							,'wv_vitals'
							,'wv_vitals_exception'
							,'cr_std_alert'
							,'pho_phys_order'
							,'pho_phys_order_audit'
							,'pn_progress_note'
							,'pn_text'
							,'fac_message'
							,'CRM_INQUIRY'
							,'crm_activity'
							,'crm_referral'
							,'as_batch'
							,'diagnosis_sheet'
							,'ar_transactions'
							,'ar_invoice'
							,'ADT_CLIENT_LOC'
							,'pho_schedule_vitals'
							,'pho_admin_site_detail'
							,'Pho_order_supply'
							,'allergy'
							,'pho_admin_order'
							,'pho_related_order'
							,'cp_sec_user_audit'
							,'census_item'
							,'file_metadata'
							,'upload_files'
							,'mpi_history'
							,'inc_incident'
							,'inc_note'
							,'inc_signature'
							,'inc_std_signing_authority'
							,'inc_response'
							,'cr_client_immunization'
							,'cr_client_immunization_audit'
							,'diagnosis_audit'
							,'facility_audit'
							,'ar_lib_insurance_companies'
							,'ar_insurance_addresses'
							,'client_ext_facilities_audit'
							,'client_staff_audit'
							,'client_ext_facilities'
							,'client_staff'
							,'inc_note_audit' --Added by Linlin Jing, Date: 2018-03-14, Reason: SmartSheet - Update EI Script - Row 52
							,'inc_witness' --Added by Linlin Jing, Date: 2018-03-19, Reason: Rina's email 
							,'inc_witness_audit' --Added by Linlin Jing, Date: 2018-03-19, Reason: Rina's email 
							,'inc_section_locked_audit' --Added by Linlin Jing, Date: 2018-04-13, Reason: Rina's email 
							,'inc_injury_audit' --Added by Jaspreet Singh, Date: 2018-04-20, Reason: Rina's email 
							)
						AND @TABLENAME NOT LIKE 'pho[_]%'
						THEN --MM: exclude client care plan info tables
							'''' + @USERNAME + ''''
					WHEN @FIELDNAME IN ('fac_id')
						THEN 'copy_fac.dst_id'
							--added audit tables Oct 22 rina
					WHEN @FIELDNAME IN ('Multi_Fac_Id') --Virul 27 July 2020
						THEN CONVERT(VARCHAR, @fac_idToCopyTo)
					WHEN @FIELDNAME IN ('ineffective_date')
						AND @TABLENAME IN (
							'address_audit'
							,'ar_client_payer_info_audit'
							,'ar_group_audit'
							,'ar_import_config_audit'
							,'ar_insurance_addresses_audit'
							,'ar_lib_insurance_companies_audit'
							,'ar_lib_payers_audit'
							,'ar_payer_addresses_audit'
							,'ar_payers_audit'
							,'common_code_audit'
							,'configuration_parameter_audit'
							,'contact_address_audit'
							,'contact_audit'
							,'contact_type_audit'
							,'cp_rev_intervention_question_audit'
							,'cp_std_intervention_question_audit'
							,'cp_std_pick_list_item_audit'
							,'edi_import_audit'
							,'facility_audit'
							,'mpi_audit'
							--,'pho_admin_order_audit'
							,'pho_phys_order_audit'
							)
						THEN 'isnull(ineffective_date, getdate())'
							--END added audit tables Oct 22
					WHEN @FIELDNAME = 'regional_id'
						AND @TABLENAME = 'facility'
						AND @reg_idToCopy IS NOT NULL
						THEN CONVERT(VARCHAR, @reg_idToCopy)
					WHEN @FIELDNAME = 'reg_id'
						AND @TABLENAME NOT IN ('ar_payer_account')
						THEN 'NULL'
					WHEN @FIELDNAME = 'claim_filing_indicator_id'
						AND @TABLENAME IN ('ar_insurance_addresses')
						THEN 'NULL'
					WHEN @FIELDNAME = 'picklist1_attribute_item_id'
						AND @TABLENAME IN ('ar_lib_insurance_companies')
						THEN 'NULL'
					WHEN @FIELDNAME = 'picklist2_attribute_item_id'
						AND @TABLENAME IN ('ar_lib_insurance_companies')
						THEN 'NULL'
					WHEN @FIELDNAME = 'order_type_id'
						AND @TABLENAME IN ('cr_cust_med')
						THEN 'NULL'
					ELSE CASE 
							WHEN @TABLENAME = 'ar_invoice_claim'
								AND @FIELDNAME <> 'invoice_id'
								AND @FIELDNAME <> 'pcc_secondary_payer_id'
								AND @FIELDNAME NOT LIKE '%address_id'
								THEN @FIELDNAME
							ELSE '[' + @FIELDNAME + ']'
							END
					END

			IF @FIELDNAME = @IDFIELD
			BEGIN
				SELECT @insertSQLW = CASE 
						WHEN @insertSQLW = ''
							THEN ' WHERE '
						ELSE @insertSQLW + ' AND '
						END + @FIELDNAME + ' <> -1 '
					,@insertWhere = CASE 
						WHEN @insertWhere = ''
							THEN ' WHERE '
						ELSE @insertWhere + ' AND '
						END + 'a.' + @FIELDNAME + ' <> -1 '
			END

			SELECT @COUNT = @COUNT + 1

			FETCH NEXT
			FROM c_mergeCopyDataFields
			INTO @fieldname
		END

		--------------------------------------------------------------------------------------------------------------------- END While (2)
		SELECT @INSERT = @INSERT + ')'

		SELECT @removeDup = ''

		/*other joins different than facility*/
		DECLARE c_mergeJoins CURSOR
		FOR
		SELECT parentTable
			,fieldName
			,parentField
			,pkJoin
		FROM mergeJoins
		WHERE tablename = ISNULL(@SpecialCase, @tablename)

		OPEN c_mergeJoins

		SELECT @count = 1

		FETCH NEXT
		FROM c_mergeJoins
		INTO @parentTable
			,@fieldName
			,@parentField
			,@pkJoin

		WHILE @@FETCH_STATUS <> - 1
			AND @@FETCH_STATUS <> - 2
			--------------------------------------------------------------------------------------------------------------------- START While (3)
		BEGIN
			SELECT @alias = @prefix + CONVERT(VARCHAR, @count)

			SET @logMsg = '--Adding join to ' + @prefix + @parentTable + ' on field ' + @fieldName

			EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
				,0

			IF EXISTS (
					SELECT *
					FROM mergetables
					WHERE tablename = @parentTable
						AND TotalRecords > 250
						AND IndexCreated = 'N'
					)
			BEGIN
				IF NOT EXISTS (
						SELECT 1
						FROM [dbo].sysindexes
						WHERE NAME = 'i_' + @prefix + @parentTable
							AND id = object_id(@prefix + @parentTable)
						)
				BEGIN
					SET @logMsg = '             Creating Index on ' + @fieldName

					EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
						,0

					SELECT @sql = 'CREATE INDEX i_' + @prefix + @parentTable + ' ON ' + @prefix + @parentTable + '(src_id)'

					EXEC (@sql)

					EXEC [operational].[sproc_facacq_mergeLogWriter] @sql
						,0
				END

				UPDATE mergetables
				SET IndexCreated = 'Y'
				WHERE tablename = @parentTable
			END

			SELECT @insertJoin = @insertJoin + CASE 
					WHEN @pkJoin = 'Y'
						THEN ''
					ELSE ' LEFT'
					END + ' JOIN ' + @dbStag + @prefix + @parentTable + ' ' + @alias +
				--add June 9/10
				'   ' +
				--END add june 9/10
				' ON ' + @alias + '.src_id = a.' + @fieldName
				,@INSERTV = REPLACE(@INSERTV, '[' + @fieldName + ']', 'ISNULL(' + @alias + '.dst_id,' + @fieldName + ')')

			/*as_std_trigger FIX: excluding triggers for corporate assessments*/
			-- Modififed by: Jaspreet Singh, Modified date: 2016-01-28
			IF @tablename IN (
					'as_std_trigger'
					,'as_std_assess_schedule'
					)
				AND @parentTable = 'as_std_assessment'
			BEGIN
				SELECT @insertJoin = @insertJoin + ' AND ' + @alias + '.corporate = ''N'''
			END

			/*as_std_rap fix: Exclude following child tables if parent entry was merged*/
			-- Added by Mark Estey - Jan 22 2019
			IF @tablename IN (
					'as_std_rap_history'
					,'as_std_rap_question_history'
					)
				AND @parentTable = 'as_std_rap'
			BEGIN
				SELECT @insertJoin = @insertJoin + ' AND ' + @alias + '.corporate = ''N'''
			END

			IF @idField IS NULL
				AND -- ((@HasNoPK = 'Y'
				(
					(
						@tablename IN (
							'ar_configuration'
							,'general_config'
							,'as_configuration'
							,'AR_EFT_BANK_INFO'
							,'ta_configuration'
							,'adt_census_code_configuration'
							,'glap_config'
							,'gl_configuration'
							,'crm_configuration'
							,'gl_account_segment'
							,
							--above row is related to CleanUpTable where PK is fac_id
							'department_position'
							,'sec_user_role'
							,'user_preference'
							,'sec_role_function'
							,'AS_STD_ASSESS_TYPE'
							,'as_std_question'
							,'as_std_pick_list_item'
							,'pho_type_freq'
							,'as_std_section'
							,'user_picklist_data'
							,'as_std_score_item'
							,'sec_user_facility'
							,'as_std_assess_header'
							,'as_std_question_group'
							,'qa_qi_indicators'
							,'qa_ind_facility'
							,'qa_ind_copyvalue'
							,'qa_function'
							,'qa_ind_teams'
							,'qa_exception'
							,'ar_rate_status'
							,'ar_payer_account'
							,'mpi_contact_type'
							,'ar_client_configuration'
							,'ta_client_account'
							,'ta_client_configuration'
							,'ar_payer_care_level'
							,'AR_LIB_FEE_SCHEDULE_AMOUNTS'
							,'gl_accounts'
							,'staff'
							,'contact_address'
							,'contact_type'
							,'contact_relationship'
							,'as_std_legEND_item'
							,'as_mds_analytics'
							,'ar_census_notification'
							,'facility_beds'
							,'contact_relationship[mpi001]'
							,'contact_relationship[fac001]'
							,'contact_type[mpi001]'
							,'contact_type[fac001]'
							,'gl_account_groups_account_ids'
							,'ap_lib_vENDor_address'
							,'ap_lib_vENDors_1099'
							,'ap_vENDor_accounts'
							,'as_std_rap_question'
							,'as_std_question_submit'
							,'ar_license'
							,'cp_std_batch_intervention'
							,'cp_std_batch_question'
							,'crm_code_activity'
							,
							----added Mar 19/2009
							'cp_std_fuq_fac'
							,'cp_std_freq_fac'
							,'cp_std_intervention_fac'
							,'cp_std_shift_fac'
							,'cp_consistency_rule_std_intervention'
							,'cp_std_intervention_question'
							,'cp_std_intervention_icon'
							,'pn_std_spn_variable'
							,
							----added June 3/2009
							'ar_dashboard_dso'
							,'ar_dashboard_occupancy'
							,'ar_item_payer'
							,'ar_item_prt'
							,'ar_payer_addresses'
							,'ar_payer_insurance'
							,'ar_ub92'
							,'ar_ub92_batch_invoice'
							,'as_ard_adl'
							,'as_ard_adl_keys'
							,'as_ard_therapy_minutes'
							,'as_assess_footnote'
							,'as_batch_assess'
							,'as_ccrs_prev_uri'
							,'as_cms672data'
							,'as_consistency_rule_range'
							,'facility_ip_address_mask'
							----added June 23/2009
							,'as_imported_status'
							,'cp_progressnote'
							,'cp_rel_interv_group'
							,'cp_rev_intervention_icon'
							,'cp_rev_intervention_question'
							,'cp_triggers_map_assess'
							,'cr_std_alert_complex'
							,'target_list_contact'
							,'crm_mail_merge_generation'
							,'edi_import_detail'
							,'gl_account_groups_account_ids'
							,'gl_account_groups_facility_ids'
							,'glap_positive_pay_layout_fields'
							,'inc_cp_task'
							,'pho_schedule_sectionu_code_mapping'
							,'pho_body_location_roa_assoc'
							,'pho_assignment_beds'
							,'pho_assignment_group_assign'
							,'pho_chartcode_history'
							,'pho_drug_record_filled'
							,'pho_drug_record_ordered'
							,'pho_std_assignment_beds'
							,'pho_user_admin_rec_assoc'
							,'cp_std_task_library_mapping'
							,'inc_witness_phone_number'
							,'as_response_history'
							,'as_assessment_error_bkup'
							,'inc_progress_note'
							,'ap_check_layout'
							,'as_std_lookback_question'
							,'cp_lbr_category_std_intervention'
							,'inc_signature'
							,'pn_std_spn_text'
							,'sec_function'
							----Feb 26/2010
							,'ar_aging_snapshot'
							,'ar_closed_ancillaries_periods'
							,'ar_collections_letter_generation'
							,'ar_edit_checks_payer'
							,'ar_invoice_statement'
							,'ar_license'
							,'ar_payer_stat'
							,'ar_tax_charge_code'
							,'ar_tax_facility'
							,'ar_tax_payer'
							,'ar_trust_transactions'
							,'assign_group_id_cleanup'
							,'assign_id_cleanup'
							,'census_status_code_setup'
							,'cp_std_adv_report_map'
							,'cp_std_question_mds'
							,'cr_immunization_education'
							,'crm_map_activity'
							,'crm_map_contributor'
							,'edi_import_detail_message'
							----mar 11/10
							,'gl_account_groups_account_ids'
							,'gl_account_groups_division_ids'
							,'gl_account_groups_facility_ids'
							,'gl_account_segment'
							,'glap_positive_pay_layout_fields'
							,'inc_cp_task'
							,'inc_std_trigger'
							,'nonlive_center_bed'
							,'nonlive_center_room'
							,'nonlive_center_unit'
							,'pho_schedule_sectionu_code_mapping'
							,'pho_body_location_roa_assoc'
							,'pho_assignment_beds'
							,'pho_assignment_group_assign'
							,'pho_chartcode_history'
							,'pho_drug_record_filled'
							,'pho_drug_record_ordered'
							,'pho_std_assignment_beds'
							,'pho_std_assignment_group_assig'
							,'pho_user_admin_rec_assoc'
							,'pn_assess_spn'
							,'pn_associate'
							,'pn_spn_useredits'
							,'prot_client_action'
							,'prot_client_action_archive'
							,'qa_exception_notes'
							,'qa_temp_adj'
							,'sec_user_secondary_pcc'
							,'assign_group_id_cleanup'
							,'assign_id_cleanup'
							,'cp_std_adv_report_map'
							,'cp_std_question_mds'
							,'cr_immunization_education'
							,'crm_mail_merge_generation'
							,'crm_map_activity'
							,'crm_map_contributor'
							,'automated_mds_enabling_step'
							,'pho_admin_enteral_tube_link'
							,'pho_order_ext_lib_cls'
							,'pho_schedule_details_deleted'
							,'pho_schedule_details_history'
							,'poc_go_live_step'
							,'process_configuration'
							,'process_date'
							,'th_minutes_stage1'
							,'th_minutes_stage2'
							,'pn_spn_narrative_response'
							,'cp_fst_type_std_intervention'
							,'process_configuration'
							,'process_date'
							,'admin_error_type'
							,'cp_schedule_shift'
							,'mds_key_group'
							,'as_rap_profile_response'
							,'crm_code_constants'
							--aug 23/10
							,'ar_submitter'
							,'glap_config'
							,'ar_lib_item_prt'
							,'ar_lib_rate_status'
							,'ar_lib_schedule_template_rate_type'
							,'ar_edit_checks_payer_type'
							,'ar_invoice_claim'
							--sept 14/10
							,'ar_provider_numbers'
							,'ar_rate_type'
							,'ar_item_types'
							,'pho_order_type_ext_lib_cls'
							,'as_caa_icon_mds_30_map'
							,'as_std_assessment_type_mds_30_map'
							,'as_std_question_state_code'
							--SEPT 30
							,'ar_claim_cob_payer'
							,'ar_claim_cob_cas'
							,'ar_claim_cob_amt'
							,'as_mds3_resident_header_info'
							,'bak_ar_collection_call_amount_due'
							,'process_configuration'
							,'process_date'
							--Oct 7
							,'th_minutes_period'
							,'edi_import_property'
							,'edi_import_property'
							,'cp_std_question_mds3'
							,'cp_std_question_mds3'
							,'as_std_rap_triggering_question'
							,'as_std_rap_trig_questions_mds_30_map'
							,'as_std_rap_mds_question'
							,'as_std_rap_mds_question'
							,'as_std_question_assessment_type_active_date_range'
							,'as_std_question_assessment_type_active_date_range'
							,'as_caa_trigger_condition_mds_30_map'
							,'as_caa_trigger_condition_mds_30_map'
							,'as_assessment_schedule_date'
							,'ext_facilities'
							,'address_audit'
							,'adt_census_code_configuration_audit'
							,'adt_census_configuration_audit'
							,'adt_census_field_configuration_audit'
							,'ar_client_payer_info_audit'
							,'ar_configuration_audit'
							,'ar_configuration_plan_audit'
							,'ar_group_audit'
							,'ar_insurance_addresses_audit'
							,'ar_lib_insurance_companies_audit'
							,'ar_lib_payers_audit'
							,'ar_payer_addresses_audit'
							,'ar_payers_audit'
							,'as_configuration_audit'
							,'clients_audit'
							,'common_code_audit'
							,'configuration_parameter_audit'
							,'contact_address_audit'
							,'contact_audit'
							,'cp_rev_intervention_question_audit'
							,'cp_std_intervention_question_audit'
							,'cp_std_pick_list_item_audit'
							,'crm_configuration_audit'
							,'crm_field_config_audit'
							,'facility_audit'
							,'general_config_audit'
							,'gl_configuration_audit'
							,'glap_config_audit'
							,'mpi_audit'
							,'pho_admin_order_audit'
							,'pho_order_related_prompt_audit'
							,'pho_order_schedule_audit'
							,'pho_related_order_audit'
							,'pho_schedule_audit'
							,'process_configuration_audit'
							,'prot_std_protocol_config_audit'
							,'rpt_config_setup_audit'
							,'rpt_config_setup_param_audit'
							,'scopedconfig_parameter_audit'
							,'ta_configuration_audit'
							,'as_ard_extensive_services'
							,'pho_std_time_fac'
							,'clients_mds'
							,'as_cms672data_v0412'
							,'as_assessment_error'
							,'as_assessment_section'
							,'as_assessment_rap'
							,'pho_schedule_last_event'
							,'pho_std_order_fac'
							,'pho_std_order_set_item'
							,'pho_std_order_type'
							,'cr_cust_med_audit'
							,'pho_std_order_set_fac'
							,'pho_lib_order_schedule_vital'
							,'pho_std_phys_order_std_order'
							,'pho_std_order_schedule_time_code'
							,'pho_std_order_schedule_vital'
							,'pn_std_spn'
							,'pho_order_pending_reason'
							,'qlib_pick_list_item_mapping'
							,'sec_user_physical_id'
							,'as_std_assessment_system_assessment_mapping'
							,'as_std_assessment_facility'
							,'as_std_pick_list_item_value_qlib_form_field_mapping'
							,'as_std_question_qlib_form_question_mapping'
							,'as_std_question_qlib_question_autopopulate_rule_mapping'
							,'pho_std_order_advance_directive_type_mapping'
							--Added by Jaspreet, Date: May-2017, Reason: SmartSheet - Update EI Script #6
							,'id_type_activation'
							,'cr_std_alert_activation'
							,'pn_type_activation'
							,'medical_professional_activation'
							,'cp_kardex_categories_activation'
							--Added by Jaspreet, Date: June-2017, Reason: SmartSheet - Update EI Script #21
							,'common_code_activation'
							,'sec_user_secondary' ----Added by Linlin Jing, Date:2018-05-23, smartsheet#56
							,'upload_categories_domain' --Added By Jaspreet Singh, Date: 2018/11/21, Reason: smarsheet #67
							)
						AND (
							@pkJoin = 'Y'
							OR @pkJoin IS NULL
							OR @pkJoin = ''
							)
						)
					OR (
						@tablename = 'configuration_parameter'
						AND @fac_idToCopyTo IS NOT NULL
						)
					)
			BEGIN
				/*Remove the duplicates */
				IF @removeDup = '' --if primary key is null and table has primary key made up of two columns this creates a when not exists statement
					SELECT @removeDup = ' NOT EXISTS ( SELECT 1 FROM ' + @dbDest + @tablename + ' origt' + ' WHERE ' + CASE @tablename
							WHEN 'process_date'
								THEN ' origt.process_name = a.process_name and ' + ' origt.created_date = a.created_date ) -- '
							WHEN 'as_submission_accounts_mds_30'
								THEN --sept 30
									' origt.cms_account_name = a.cms_account_name And ' + ' origt.fac_id = a.fac_id And '
							WHEN 'ar_edit_checks_payer_type'
								THEN --aug 23/10
									' origt.edit_check_id = a.edit_check_id AND ' + --aug 23/10
									' origt.payer_type = a.payer_type AND ' + --aug 23/10
									' origt.edit_check_level = a.edit_check_level) -- ' --aug 23/10
							WHEN 'crm_code_constants'
								THEN ' origt.constant_name = a.constant_name) -- '
									--END ad june11/10
							WHEN 'user_preference'
								THEN ' origt.param_name = a.param_name AND '
							WHEN 'sec_role_function'
								THEN ' origt.func_id = a.func_id AND '
							WHEN 'AS_STD_ASSESS_TYPE'
								THEN ' origt.assess_type_code = a.assess_type_code AND '
							WHEN 'configuration_parameter'
								THEN ' origt.name = a.name AND origt.fac_id IN (' + CONVERT(VARCHAR, @fac_idToCopyTo) + ',-1)'
							WHEN 'as_std_question'
								THEN ' origt.question_key = a.question_key AND '
							WHEN 'as_std_pick_list_item'
								THEN ' origt.item_value = a.item_value 														  
														  AND origt.effective_date = a.effective_date AND ' --added 2014-04-23
							WHEN 'as_std_section'
								THEN ' origt.section_code = a.section_code AND '
							WHEN 'user_picklist_data'
								THEN ' origt.description = a.description AND '
							WHEN 'facility_beds'
								THEN ' origt.effective_date = a.effective_date AND '
							WHEN 'as_std_score_item'
								THEN ' origt.question_key = a.question_key AND ' + ' origt.item_value = a.item_value AND '
							WHEN 'as_std_assess_header'
								THEN ' origt.id_type_id = ISNULL(' + @prefix + '2.dst_id,origt.id_type_id) AND '
							WHEN 'ap_lib_vENDor_address'
								THEN ' origt.address_type = a.address_type AND '
							WHEN 'as_std_rap_question'
								THEN ' origt.question_key = a.question_key AND ' + ' origt.sequence = a.sequence AND ' + ' ISNULL(origt.title,'''') = ISNULL(a.title,'''') AND '
							WHEN 'as_std_question_submit'
								THEN ' origt.question_key = a.question_key AND '
									--added July 14/2009
							WHEN 'cp_triggers_map_assess'
								THEN ' origt.trigger_id = a.trigger_id AND '
							WHEN 'as_consistency_rule_range'
								THEN ' origt.range_type = a.range_type AND ' + ' origt.range = a.range AND '
									--added June 18/10
							WHEN 'process_configuration'
								THEN ' origt.process_name = a.process_name) -- '
							WHEN 'admin_error_type'
								THEN ' origt.error_type = a.error_type AND '
							WHEN 'mds_key_group'
								THEN ' origt.value = a.value AND ' + ' origt.key_word = a.key_word AND '
									--END ad june18/10                              
							WHEN 'department_position'
								THEN ' origt.fac_id = copy_fac.dst_id AND '
							WHEN 'pho_order_type_ext_lib_cls'
								THEN ' origt.pho_ext_lib_class_id = a.pho_ext_lib_class_id AND '
							WHEN 'as_std_assessment_type_mds_30_map'
								THEN ' origt.assess_type_code = a.assess_type_code AND ' + ' origt.[A0200] = a.[A0200] AND ' + ' origt.[A0310A] = a.[A0310A] AND ' + ' origt.[A0310B] = a.[A0310B] AND ' + ' origt.[A0310C] = a.[A0310C] AND ' + ' origt.[A0310D] = a.[A0310D] AND ' + ' origt.[A0310F] = a.[A0310F] AND '
							WHEN 'as_std_question_state_code'
								THEN ' origt.assess_type_code = a.assess_type_code AND ' + ' origt.question_key = a.question_key AND ' + ' origt.effective_date = a.effective_date AND ' + ' origt.country_id = a.country_id AND ' + ' origt.prov_code = a.prov_code AND '
							WHEN 'inc_witness_phone_number'
								THEN ' witness_statement_id = a.witness_statement_id AND ' + ' sequence = a.sequence) -- '
									--													WHEN 'ar_configuration' THEN--added aug 11/2010-kc
									--                                                   ' origt.fac_id = a.fac_id AND ' 
							WHEN 'ext_facilities'
								THEN ' origt.fac_id = copy_fac.dst_id  AND '
							WHEN 'facility_audit'
								THEN ' origt.effective_date = a.effective_date AND '
							WHEN 'adt_census_configuration_audit'
								THEN ' origt.audit_date = a.audit_date AND '
							WHEN 'adt_census_field_configuration_audit'
								THEN ' origt.audit_date = a.audit_date AND ' + ' origt.field_id = a.field_id AND '
							WHEN 'ar_configuration_audit'
								THEN ' origt.audit_date = a.audit_date AND '
							WHEN 'as_configuration_audit'
								THEN ' origt.audit_date = a.audit_date AND '
							WHEN 'crm_configuration_audit'
								THEN ' origt.audit_date = a.audit_date AND '
							WHEN 'crm_field_config_audit'
								THEN ' origt.audit_date = a.audit_date AND ' + ' origt.field_id = a.field_id AND '
							WHEN 'general_config_audit'
								THEN ' origt.audit_date = a.audit_date AND '
							WHEN 'gl_configuration_audit'
								THEN ' origt.audit_date = a.audit_date AND '
							WHEN 'glap_config_audit'
								THEN ' origt.audit_date = a.audit_date AND '
							WHEN 'process_configuration_audit'
								THEN ' origt.audit_date = a.audit_date AND ' + ' origt.process_name = a.process_name AND '
							WHEN 'prot_std_protocol_config_audit'
								THEN ' origt.audit_date = a.audit_date AND ' + ' origt.protocol_id = a.protocol_id AND '
							WHEN 'rpt_config_setup_audit'
								THEN ' origt.audit_date = a.audit_date AND '
									--                                                                        ' origt.setup_id = a.setup_id AND '
							WHEN 'rpt_config_setup_param_audit'
								THEN ' origt.audit_date = a.audit_date AND ' + ' origt.setup_param_id = a.setup_param_id AND '
							WHEN 'scopedconfig_parameter_audit'
								THEN ' origt.audit_date = a.audit_date AND ' + ' origt.scoped_config_id = a.scoped_config_id AND '
							WHEN 'ta_configuration_audit'
								THEN ' origt.audit_date = a.audit_date AND '
							WHEN 'address_audit'
								THEN ' origt.effective_date = a.effective_date AND '
							WHEN 'adt_census_code_configuration_audit'
								THEN ' origt.audit_date = a.audit_date AND '
							WHEN 'ar_client_payer_info_audit'
								THEN ' origt.client_payer_info_id = a.client_payer_info_id AND ' + ' origt.effective_date = a.effective_date AND '
							WHEN 'ar_configuration_plan_audit'
								THEN ' origt.audit_date = a.audit_date AND ' + ' origt.plan_id = a.plan_id AND '
							WHEN 'ar_group_audit'
								THEN ' origt.effective_date = a.effective_date AND '
							WHEN 'ar_insurance_addresses_audit'
								THEN ' origt.effective_date = a.effective_date AND '
							WHEN 'ar_lib_insurance_companies_audit'
								THEN ' origt.effective_date = a.effective_date AND '
							WHEN 'ar_lib_payers_audit'
								THEN ' origt.effective_date = a.effective_date AND '
									--                                                                        ' origt.payer_id = a.payer_id AND '
							WHEN 'clients_audit'
								THEN ' origt.effective_date = a.effective_date AND '
									--' origt.client_id = a.client_id AND ' + 	
							WHEN 'common_code_audit'
								THEN ' ( origt.ineffective_date = a.ineffective_date and origt.effective_date = a.effective_date ) or origt.effective_date = a.effective_date AND '
							WHEN 'configuration_parameter_audit'
								THEN ' origt.effective_date = a.effective_date AND ' + ' origt.name = a.name AND '
							WHEN 'contact_audit'
								THEN ' origt.effective_date = a.effective_date AND '
									--' origt.contact_id = a.contact_id AND ' + 
							WHEN 'cp_rev_intervention_question_audit'
								THEN ' origt.effective_date = a.effective_date AND ' + ' origt.intervention_id = a.intervention_id AND ' + ' origt.std_question_id = a.std_question_id AND '
							WHEN 'cp_std_intervention_question_audit'
								THEN ' origt.effective_date = a.effective_date AND '
							WHEN 'cp_std_pick_list_item_audit'
								THEN ' origt.effective_date = a.effective_date AND ' + ' origt.std_pick_list_item_id = ISNULL(' + @prefix + '3.dst_id,origt.std_pick_list_item_id )) --  '
									--' origt.std_pick_list_id = a.std_pick_list_id AND ' + 
							WHEN 'facility_audit'
								THEN ' origt.effective_date = a.effective_date AND '
							WHEN 'mpi_audit'
								THEN ' origt.effective_date = a.effective_date AND '
									--                                                                        ' origt.mpi_id = a.mpi_id AND '
							WHEN 'pho_admin_order_audit'
								THEN ' origt.admin_order_id = a.admin_order_id AND ' + ' origt.audit_id = a.audit_id AND ' + ' origt.phys_order_id = a.phys_order_id AND '
							WHEN 'pho_order_related_prompt_audit'
								THEN ' origt.audit_id = a.audit_id AND ' + ' origt.prompt_id = a.prompt_id AND ' + ' origt.schedule_id = a.schedule_id AND '
							WHEN 'pho_schedule_audit'
								THEN ' origt.audit_id = a.audit_id AND ' + ' origt.phys_order_id = a.phys_order_id AND ' + ' origt.schedule_id = a.schedule_id AND '
							WHEN 'ar_payers_audit'
								THEN ' origt.effective_date = a.effective_date AND ' + ' origt.payer_id = a.payer_id AND '
							WHEN 'pho_related_order_audit'
								THEN ' origt.audit_id = a.audit_id AND ' + ' origt.order_relationship_id = a.order_relationship_id AND ' + ' origt.phys_order_id = a.phys_order_id AND ' + ' origt.related_phys_order_id = a.related_phys_order_id AND '
							WHEN 'ar_payer_addresses_audit'
								THEN ' origt.address_id = a.address_id AND ' + ' origt.effective_date = a.effective_date AND ' + ' origt.payer_id = a.payer_id AND '
							WHEN 'contact_address_audit'
								THEN ' origt.address_id = a.address_id AND ' + ' origt.contact_id = a.contact_id AND ' + ' origt.effective_date = a.effective_date AND ' + ' origt.type_id = a.type_id AND '
							WHEN 'pho_order_schedule_audit'
								THEN ' origt.administered_by_id = a.administered_by_id AND ' + ' origt.audit_id = a.audit_id AND ' + ' origt.dose_uom_id = a.dose_uom_id AND ' + ' origt.quantity_uom_id = a.quantity_uom_id AND ' + ' origt.schedule_duration_type_id = a.schedule_duration_type_id AND ' + ' origt.schedule_END_date_type_id = a.schedule_END_date_type_id AND '
							WHEN 'pho_phys_order_audit'
								THEN ' origt.audit_id = a.audit_id AND ' + ' origt.client_id = a.client_id AND ' + ' origt.END_date = a.END_date AND ' + ' origt.event_type = a.event_type AND ' + ' origt.order_category_id = a.order_category_id AND ' + ' origt.origin_id = a.origin_id AND '
							WHEN 'contact_type_audit'
								THEN ' origt.contact_id = a.contact_id AND ' + --Oct 22-Rina
									' origt.subclass_id = a.subclass_id AND ' + ' origt.reference_id = a.reference_id AND ' + ' origt.fac_id = a.fac_id AND ' + ' origt.type_id = a.type_id AND ' + ' origt.effective_date = a.effective_date AND '
							WHEN 'as_std_lookback_question'
								THEN ' origt.question_key = a.question_key AND '
							WHEN 'cr_cust_med_audit'
								THEN ' origt.effective_date = a.effective_date AND '
									-- Changed by Mark Estey July 18 2019: Causing error in copy logic
							WHEN 'pho_std_phys_order_std_order'
								THEN ' 1=1 '
							WHEN 'pho_order_pending_reason'
								THEN ' origt.reason_binary_code = a.reason_binary_code AND '
							WHEN 'qlib_pick_list_item_mapping'
								THEN ' origt.qlib_pick_list_id = a.qlib_pick_list_id AND '
							WHEN 'pho_std_order_set_fac'
								THEN ' origt.fac_id = copy_fac.dst_id AND '
							WHEN 'as_std_pick_list_item_value_qlib_form_field_mapping'
								THEN ' origt.question_key = a.question_key AND ' + ' origt.pick_list_item_value = a.pick_list_item_value AND ' + ' origt.qlib_form_field_id = a.qlib_form_field_id AND '
							WHEN 'as_std_question_qlib_form_question_mapping'
								THEN ' origt.question_key = a.question_key AND ' + ' origt.qlib_form_question_id = a.qlib_form_question_id AND '
							WHEN 'as_std_question_qlib_question_autopopulate_rule_mapping'
								THEN ' origt.question_key = a.question_key AND ' + ' origt.qlib_autopopulate_rule_id = a.qlib_autopopulate_rule_id AND '
							WHEN 'sec_user_secondary'
								THEN ' origt.userid = a.userid AND ' --Added by Linlin Jing, Date:2018-05-23, smartsheet#56
							WHEN 'upload_categories_domain'
								THEN ' origt.cat_id = a.cat_id AND ' --Added by Jaspreet Singh, Date:2018-11-22, smartsheet#67
							ELSE ''
							END
				ELSE
					SELECT @removeDup = @removeDup + ' AND'

				/*HERE*/
				-- Changed by Mark Estey July 18 2019: Fixing logic for pho_std_phys_order_std_order to skip dup check on std_order_id
				IF (
						@tablename NOT IN (
							'configuration_parameter'
							,'pho_std_phys_order_std_order'
							)
						OR (
							@tablename = 'pho_std_phys_order_std_order'
							AND @fieldName <> 'std_order_id'
							)
						)
					OR @fac_idToCopyTo IS NULL
					SELECT @removeDup = @removeDup + ' origt.' + @fieldName + ' = ' + @alias + '.dst_id '
			END

			IF (@removeDup <> '')
			BEGIN
				SELECT @removeDup1 = ' AND' + replace(@removeDup, @dbDest, @dbStag)

				SELECT @removeDup1 = replace(@removeDup1, 'origt', 'origt1') + ')'
			END

			SET @count = @count + 1

			FETCH NEXT
			FROM c_mergeJoins
			INTO @parentTable
				,@fieldName
				,@parentField
				,@pkJoin
		END

		--------------------------------------------------------------------------------------------------------------------- END While (3)
		CLOSE c_mergeJoins

		DEALLOCATE c_mergeJoins

		SELECT @insertFrom = ' FROM ' + @dbOrig + @tablename + ' a '
			--added June 9/10
			+ '   '
			--END add June 9/10
			+ @insertJoin + CASE 
				WHEN @IDFIELD IS NOT NULL
					THEN ', ' + @dbStag + @prefix + @tablename + ' b '
				ELSE ''
				END

		SELECT @insertWhere = @insertWhere + CASE 
				WHEN @IDFIELD IS NOT NULL
					THEN CASE 
							WHEN @insertWhere = ''
								THEN ' WHERE '
							ELSE ' AND '
							END + ' a.' + @IDFIELD + ' = b.src_id '
				ELSE ''
				END

		/* New Change that filter some records */
		IF @queryFilter IS NOT NULL
		BEGIN
			SET @queryFilter = REPLACE(@queryFilter, '[origDB].', @dbOrig)
			SET @queryFilter = REPLACE(@queryFilter, '[stagDB].', @dbStag)
			/********************
			Modified By: Jaspreet Singh
			Date: 2018-06-25
			Reason: EI enhancement
			Comment: Later on while running code in production remove below part and un comment original. 
			Make changes in mergetables in queryfilter column
			Update comment: Not needed replace statement becuase we're doing this thru pre script
			***********/
			--SET @queryFilter = REPLACE(@queryFilter, '[destDB].', @dbStag)
			SET @queryFilter = REPLACE(@queryFilter, '[destDB].', @dbdest)
			SET @queryFilter = REPLACE(@queryFilter, '[prefix]', @prefix)

			IF @fac_idO IS NOT NULL
				SET @queryFilter = REPLACE(@queryFilter, '[OrigFacId]', @fac_idO)
		END
		ELSE
			SET @queryFilter = ''

		----------------------------------
		--moved this script from below on 8/23/2017
		IF (@tablename = 'as_std_assessment')
		BEGIN
			IF EXISTS (
					SELECT tablename
					FROM mergetables
					WHERE tablename = 'as_std_assessment'
					)
			BEGIN
				--SET @logMsg = 'UPDATE ' + @dbDest + @prefix + 'AS_STD_ASSESSMENT SET DST_ID = SRC_ID,corporate = ''Y'' WHERE SRC_ID in (select std_assess_id from ' + @dbDest + 'AS_STD_ASSESSMENT where std_assess_id <= 10028 and system_flag = ''Y'') and src_id <= 10028 '
				--EXEC (@logMsg)
				--EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
				--	,0
				BEGIN
					---- Added by: Jaspreet Singh, Date: 2016-02-01, Purpose: For system uda's
					SET @logMsg = 'INSERT INTO ' + @dbStag + @prefix + 'as_std_assessment
						SELECT
							src.std_assess_id AS src_id
							,dest.std_assess_id AS dst_id
							,''Y'' AS corporate
						FROM ' + @dbOrig + 'as_std_assessment src WITH (NOLOCK)
						INNER JOIN ' + @dbDest + 'as_std_assessment dest WITH (NOLOCK) ON src.description = dest.description
						WHERE src.deleted = ''N''
							AND dest.deleted = ''N''
							AND EXISTS (SELECT std_assess_id FROM ' + @dbOrig + 'as_assessment srcases WITH (NOLOCK)
							WHERE src.std_assess_id = srcases.std_assess_id  AND srcases.fac_id = ' + @sFac_idO + ' AND srcases.client_id > 0)
							AND EXISTS (
								SELECT std_assess_id
								FROM ' + @dbDest + 'as_std_assessment_system_assessment_mapping map WITH (NOLOCK)
								WHERE dest.std_assess_id = map.std_assess_id
								)'

					EXEC (@logMsg)

					EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
						,0
						--SET @udaCount = 0
				END -- added by: Jaspreet Singh, date: 2016-04-14, purpose: insert only when uda is selected in EI front end

				SET @logMsg = 'IF NOT EXISTS (SELECT 1 from ' + @dbStag + @prefix + 'AS_STD_ASSESSMENT where src_id = -1)  INSERT INTO ' + @dbStag + @prefix + 'as_std_assessment (src_id,dst_id,corporate) values (-1,-1,''N'')'

				EXEC (@logMsg)

				EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
					,0
			END
		END

		--end moved this script from below on 8/23/2017
		------------------------------------------------
		IF @IDFIELD IS NOT NULL
			----------------------------------------------------------------@IDFIELD not null Start
		BEGIN
			/* Insert into copyM_ */
			SELECT @insertSQLW = @insertSQLW + @queryFilter + ' ORDER BY ' + @idField

			EXEC [operational].[sproc_facacq_mergeLogWriter] '*******INSERT INTO COPY TABLE************'
				,0

			SET @logMsg = @insertSQLH + ISNULL(@insertSQLW, '??')

			--PRINT @logMsg
			EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
				,0

			EXEC (@insertSQLH + @insertSQLW)

			EXEC [operational].[sproc_facacq_mergeLogWriter] @insertSQLH
				,0

			EXEC [operational].[sproc_facacq_mergeLogWriter] @insertSQLW
				,0

			INSERT INTO #mergeCopyDataCounter
			EXEC (' SELECT count(1) FROM ' + @dbStag + @prefix + @tablename)

			SET @logMsg = ' SELECT count(1) FROM ' + @dbStag + @prefix + @tablename

			EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
				,0

			SELECT @count = [counter]
			FROM #mergeCopyDataCounter

			SET @logMsg = ' Count :- ' + convert(varchar, @count) +' in #mergeCopyDataCounter for table :- ' + @dbStag + @prefix + @tablename

			EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
				,0

			DELETE
			FROM #mergeCopyDataCounter

			UPDATE mergetables
			SET TotalRecords = @count
				,IndexCreated = 'N'
			WHERE tablename = @tablename

			SET @logMsg = '         ' + @tablename + ' ' + CONVERT(VARCHAR, @count) + ' Row(s) copied'

			EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
				,0

			/*START CHECK SCOPE FOR DESTINATION here because to check if we already inserted data for a table which is used in multiple modules. For an example: common_code*/
			EXEC [operational].[sproc_facacq_mergefindScope] @dbOrig = @dbOrig
				,@dbDest = @dbDest
				,-- @dbStag,
				@tableName = @tableName
				,@fieldName = @IDFIELD
				,@deletedField = @hasDeleted
				,@prefix = @prefix
				,@scopeField1 = @scopeField1
				,@scopeField2 = @scopeField2
				,@scopeField3 = @scopeField3
				,@scopeField4 = @scopeField4
				,@scopeField5 = @scopeField5
				,@scopeField6 = @scopeField6
				,@scopeField7 = @scopeField7
				,@reg_id = @reg_idToCopy
				,@fac_id = @fac_idToCopyTo

			/*END CHECK SCOPE FOR DESTINATION*/
			/*START CHECK SCOPE FOR STAGING here because to check if we already inserted data for a table which is used in multiple modules. For an example: common_code*/
			EXEC [operational].[sproc_facacq_mergefindScope] @dbOrig = @dbOrig
				,@dbDest = @dbStag
				,@tableName = @tableName
				,@fieldName = @IDFIELD
				,@deletedField = @hasDeleted
				,@prefix = @prefix
				,@scopeField1 = @scopeField1
				,@scopeField2 = @scopeField2
				,@scopeField3 = @scopeField3
				,@scopeField4 = @scopeField4
				,@scopeField5 = @scopeField5
				,@scopeField6 = @scopeField6
				,@scopeField7 = @scopeField7
				,@reg_id = @reg_idToCopy
				,@fac_id = @fac_idToCopyTo

			/*END CHECK SCOPE FOR STAGING*/
			IF @count > 0
			BEGIN
				--#mergeCopyDataCounter
				SET @sql = 'SELECT TOP 1 1 FROM ' + @dbStag + @prefix + @tablename + '  WHERE corporate = ''N'''

				DELETE
				FROM #mergeCopyDataCounter

				INSERT INTO #mergeCopyDataCounter
				EXEC (@sql)

				EXEC [operational].[sproc_facacq_mergeLogWriter] @sql
					,0

				IF EXISTS (
						SELECT 1
						FROM #mergeCopyDataCounter
						)
				BEGIN
					/*Facility Numeerator*/
					IF @tablename = 'FACILITY'
					BEGIN
						SELECT @NextKey = max(fac_id)
						FROM [dbo].facility
						WHERE fac_id < 5000 --NOT IN (9999,9991,9001)

						SET @NextKey = ISNULL(@NextKey, 0) + 1
					END
					ELSE
					BEGIN
						IF EXISTS (
								SELECT 1
								FROM INFORMATION_SCHEMA.COLUMNS
								WHERE COLUMNPROPERTY(object_id(TABLE_NAME), COLUMN_NAME, 'IsIdentity') = 1
									AND TABLE_NAME = @tablename
								)
						BEGIN
							-- SELECT @sql = 'SELECT @cnt = ISNULL(MAX(' + @idField + '), 0) + 1 FROM ' +  @dbDest + @tablename
							/*
							Commented / Added BY: Jaspreet Singh
							Date: 2018-04-23
							Reason: Replace with IDENT_CURRENT()
							*/
							---- SELECT @sql = 'SELECT @cnt=ISNULL(max(' + @idField + '),0)+1 FROM ' + @tablename
							-- SELECT @sql = 'SELECT @cnt = IDENT_CURRENT('''+ @tablename +''')'
							--SELECT @sql = 'DECLARE @query nvarchar(max) 
							--					SET @query = ''SELECT @cnt = IDENT_CURRENT('''+ @tablename +''')''
							--					EXEC [' + @dbDestNodbo + '].sys.sp_executesql @query'
							--EXEC sp_executesql @sql
							--	,N'@cnt int OUTPUT'
							--	,@cnt = @NextKey OUTPUT
							--EXEC [operational].[sproc_facacq_mergeLogWriter] @sql
							--	,0
							--SET @IdentityKey = @NextKey
							IF (
									@count IS NULL
									OR @count = 0
									)
							BEGIN
								SELECT @sql = 'SELECT @count = ISNULL(max(' + @idField + '),0)+1 FROM ' + @dbStag + @tablename

								EXEC sp_executesql @sql
									,N'@count BIGINT OUTPUT'
									,@count OUTPUT

								EXEC [operational].[sproc_facacq_mergeLogWriter] @sql
									,0
							END

							/********************************************************************************/
							-- PARAMETERS
							DECLARE @slots2Reserve BIGINT
							DECLARE @Table2Reseed VARCHAR(128)
							DECLARE @DestDbWithInstance NVARCHAR(200)
							-- VARIABLES
							DECLARE @ReseedSQL NVARCHAR(1000)
							DECLARE @FinalSQL NVARCHAR(2000)
							DECLARE @ParmDefinition NVARCHAR(500);
							DECLARE @StartIdFrom BIGINT
								,@EndIdFrom BIGINT
							DECLARE @dbDestNodbo NVARCHAR(100)

							---- [USC4\PCCDS4].test_usei191_EA.[dbo].
							SET @slots2Reserve = @count -- 100
							SET @Table2Reseed = @tablename -- 'dbo.pho_schedule_details'
							SET @dbDestNodbo = substring(@dbDest, 0, CHARINDEX('.[dbo].', @dbDest))
							SET @DestDbWithInstance = @dbDestNodbo -- '[usc1\pcc_conv2012_1].[test_usei78]'
							SET @ParmDefinition = N'@StartValOUT BIGINT OUTPUT,@EndValOUT BIGINT OUTPUT'
							SET @ReseedSQL = N'SET DEADLOCK_PRIORITY 4;' + CHAR(13) + CHAR(10) + 'DECLARE @IdentStart BIGINT,@IdentEnd BIGINT,@ReSeedVal BIGINT, @DeclareDummy BIGINT' + CHAR(13) + CHAR(10) + 'BEGIN TRAN' + CHAR(13) + CHAR(10) + 'SET @DeclareDummy=(SELECT TOP 0 NULL FROM ' + @Table2Reseed + ' WITH (tablockx))' + CHAR(13) + CHAR(10) + 'SET @IdentStart=IDENT_CURRENT(''''' + @Table2Reseed + ''''')' + CHAR(13) + CHAR(10) + 'SET @ReSeedVal=@IdentStart+' + CONVERT(VARCHAR(16), @slots2Reserve) + '' + CHAR(13) + CHAR(10) + 'DBCC CHECKIDENT (''''' + @Table2Reseed + ''''', RESEED,@ReSeedVal)' + CHAR(13) + CHAR(10) + 'SET @IdentEnd=IDENT_CURRENT(''''' + @Table2Reseed + ''''')' + CHAR(13) + CHAR(10) + 'COMMIT' + CHAR(13) + CHAR(10) + 'SELECT @IdentStartOUT=@IdentStart,@IdentEndOUT=@IdentEnd'
							SET @FinalSQL = 'DECLARE @Sql NVARCHAR(1500)' + CHAR(13) + CHAR(10) + 'DECLARE @StartVal BIGINT, @EndVal BIGINT' + CHAR(13) + CHAR(10) + 'DECLARE @ParmOut NVARCHAR(500)' + CHAR(13) + CHAR(10) + 'SET @ParmOut = N''@IdentStartOUT BIGINT OUTPUT,@IdentEndOUT BIGINT OUTPUT''' + CHAR(13) + CHAR(10) + 'SET @Sql = ''' + @ReseedSQL + '''' + CHAR(13) + CHAR(10) + 'EXEC ' + @DestDbWithInstance + '.sys.sp_executesql @Sql, @ParmOut, @IdentStartOUT=@StartVal OUTPUT, @IdentEndOUT=@EndVal OUTPUT' + CHAR(13) + CHAR(10) + 'SELECT @StartValOUT=@StartVal, @EndValOUT=@EndVal'

							--PRINT @FinalSQL
							EXEC sp_executesql @FinalSQL
								,@ParmDefinition
								,@StartValOUT = @StartIdFrom OUT
								,@EndValOUT = @EndIdFrom OUT

							EXEC [operational].[sproc_facacq_mergeLogWriter] @FinalSQL
								,0

							--SELECT @StartIdFrom as StartIdFrom,@EndIdFrom as EndIdFrom
							--SET @NextKey = ISNULL(@NextKey, 0) + 1
							SET @NextKey = ISNULL(@StartIdFrom, 0) + 1
							SET @logMsg = 'Next Key value for --> ' + @tablename + ' ' + CONVERT(VARCHAR, @NextKey) + ' with IsIdentity = 1'

							EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
								,0
								/************************************************************************************/
								--SET @IdentityKey = @IdentityKey + @count
								--DECLARE @dbDestNodbo NVARCHAR(100)
								--SET @sql = 'DECLARE @query nvarchar(max) 
								--					SET @query = ''DBCC CHECKIDENT(''''' + @tablename + ''''', reseed, ' + CAST(@IdentityKey AS VARCHAR) + ')''
								--					EXEC [' + @dbDestNodbo + '].sys.sp_executesql @query'
								----PRINT @sql
								--EXEC sp_executesql @sql
								--EXEC [operational].[sproc_facacq_mergeLogWriter] @sql
								--	,0
						END
						ELSE
						BEGIN
							SET @sql = NULL
							SET @sql = 'EXECUTE	' + @dbDest + '[get_next_primary_key]
									@a_table_name = N''' + @tablename + ''',
									@a_key_column_name = N''' + @idField + ''',
									@a_NextKey = @retvalOUT OUTPUT,
									@a_block_size = ' + CAST(@count AS VARCHAR) + '
									SELECT @retvalOUT'

							-- PRINT @sql
							EXEC sp_executesql @sql
								,@ParamDefinition
								,@retvalOUT = @NextKey OUTPUT

							EXEC [operational].[sproc_facacq_mergeLogWriter] @sql
								,0

							--SELECT @count AS Current_Count
							--	,@NextKey AS Next_Key
							SET @logMsg = 'Next Key value for --> ' + @tablename + ' ' + CONVERT(VARCHAR, @NextKey) + ' set in destination pcc_global_primary_key table.'

							EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
								,0

							SELECT @sql = 'SELECT @cnt=ISNULL(max(' + @idField + '),0)+1 FROM ' + @dbDest + @tablename

							EXEC sp_executesql @sql
								,N'@cnt BIGINT OUTPUT'
								,@cnt = @start_table_id OUTPUT

							EXEC [operational].[sproc_facacq_mergeLogWriter] @sql
								,0

							SET @logMsg = 'Count of destination table --> ' + @tablename + ' ' + CONVERT(VARCHAR, @start_table_id)

							EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
								,0

							IF @start_table_id > @NextKey
							BEGIN
								SET @sql = NULL
								SET @sql = 'DELETE FROM ' + @dbDest + 'pcc_global_primary_key
								WHERE table_name = ''' + @tablename + ''''

								--PRINT @sql
								EXEC (@sql)

								EXEC [operational].[sproc_facacq_mergeLogWriter] @sql
									,0

								SET @sql = NULL
								SET @sql = 'EXECUTE	' + @dbDest + '[get_next_primary_key]
										@a_table_name = N''' + @tablename + ''',
										@a_key_column_name = N''' + @idField + ''',
										@a_NextKey = @retvalOUT OUTPUT,
										@a_block_size = ' + CAST(@count AS VARCHAR) + '
										SELECT @retvalOUT'

								-- PRINT @sql
								EXEC sp_executesql @sql
									,@ParamDefinition
									,@retvalOUT = @NextKey OUTPUT

								--SELECT @count AS Current_Count
								--	,@NextKey AS Next_Key
								EXEC [operational].[sproc_facacq_mergeLogWriter] @sql
									,0

								SET @logMsg = 'Next key value of destination table --> ' + @tablename + ' :- ' + CONVERT(VARCHAR, @NextKey) + ' when @start_table_id > @NextKey'

								EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
									,0
							END
						END
					END

					SET @logMsg = 'Before Start Table Id :- ' + CONVERT(VARCHAR, @NextKey) + ' and Next Key :- ' + CONVERT(VARCHAR, @NextKey) + ' for table name :- ' + @tablename

					EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
						,0

					SET @start_table_id = @NextKey
					SET @logMsg = 'After Start Table Id :- ' + CONVERT(VARCHAR, @NextKey) + ' and Next Key :- ' + CONVERT(VARCHAR, @NextKey) + ' for table name :- ' + @tablename

					EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
						,0

					SET @logMsg = 'Tablename -->' + @tablename + ', start_table_id --> ' + cast(@start_table_id AS VARCHAR)

					EXEC [operational].[sproc_facacq_mergeLogWriter] @logmsg
						,0

					/* New Ids*/
					SELECT @sql = 'UPDATE ' + @dbStag + @prefix + @tablename + ' SET  dst_id= ' + CONVERT(VARCHAR, @start_table_id) + '+([row_id]-1)' + ' WHERE dst_id IS NULL'

					EXEC [operational].[sproc_facacq_mergeLogWriter] 'Update dst_id'
						,0

					EXEC [operational].[sproc_facacq_mergeLogWriter] @sql
						,0

					EXEC (@sql)

					/* INSERT */
					/*DISABLE TRIGGERS*/
					EXEC [operational].[sproc_facacq_mergeLogWriter] '********INSERT INTO PRODUCTION TABLE STATEMENT*********'
						,0

					EXEC [operational].[sproc_facacq_mergeLogWriter] @tablename
						,0

					EXEC [operational].[sproc_facacq_mergeLogWriter] '_________________ Following statment is for display only. Do not use it'
						,0

					SET @logMsg = @INSERT + @INSERTV + @insertFrom + @insertWhere + ' AND  b.corporate = ''N'''

					EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
						,0

					------ Added by: Jaspreet Singh, Date: 2016-02-09, Purpose: Table name condition added to execute query for as_std_assessment table only
					--Remove system_flag after Rina testing - jimmy
					IF (@tablename = 'as_std_assessment')
					BEGIN
						IF EXISTS (
								SELECT tablename
								FROM mergetables
								WHERE tablename = 'as_std_assessment'
								)
						BEGIN
							SET @logMsg = 'UPDATE ' + @dbStag + @prefix + 'AS_STD_ASSESSMENT SET DST_ID = SRC_ID,corporate = ''Y'' WHERE SRC_ID in (select std_assess_id from ' + @dbDest + 'AS_STD_ASSESSMENT where std_assess_id <= 10028 and system_flag = ''Y'') and src_id <= 10028 '

							EXEC (@logMsg)

							EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
								,0
								--Comment out by: Linlin Jing, Date: 2017-07-06, Reason: SmartSheet - Update EI Script - Row 30, start 
								--INSERT INTO #mergeUDACounter
								--EXEC ('SELECT count(1) FROM ' + @dbDest + @prefix + @tablename + ' WHERE src_id NOT IN (1, 7, 8, 11, 12)')
								--SELECT @udaCount = COUNTER
								--FROM #mergeUDACounter
								--DELETE
								--FROM #mergeUDACounter
								--IF (ISNULL(@udaCount, 0) > 0)
								--Comment out by: Linlin Jing, Date: 2017-07-06, Reason: SmartSheet - Update EI Script - Row 30, end
								----	BEGIN
								----		---- Added by: Jaspreet Singh, Date: 2016-02-01, Purpose: For system uda's
								----		SET @logMsg = 'INSERT INTO ' + @dbStag + @prefix + 'as_std_assessment
								----SELECT
								----	src.std_assess_id AS src_id
								----	,dest.std_assess_id AS dst_id
								----	,''Y'' AS corporate
								----FROM ' + @dbOrig + 'as_std_assessment src WITH (NOLOCK)
								----INNER JOIN ' + @dbDest + 'as_std_assessment dest WITH (NOLOCK) ON src.description = dest.description
								----WHERE src.deleted = ''N''
								----	AND dest.deleted = ''N''
								----	AND EXISTS (SELECT std_assess_id FROM ' + @dbOrig + 'as_assessment srcases WITH (NOLOCK)
								----	WHERE src.std_assess_id = srcases.std_assess_id  AND srcases.fac_id = ' + @sFac_idO + ' AND srcases.client_id > 0)
								----	AND EXISTS (
								----		SELECT std_assess_id
								----		FROM ' + @dbDest + 'as_std_assessment_system_assessment_mapping map WITH (NOLOCK)
								----		WHERE dest.std_assess_id = map.std_assess_id
								----		)'
								----		EXEC (@logMsg)
								----		EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
								----			,0
								----		SET @udaCount = 0
								----	END -- added by: Jaspreet Singh, date: 2016-04-14, purpose: insert only when uda is selected in EI front end
						END
					END

					----Ann added May 29, 2014
					--						if exists (select tablename from mergetables where tablename = 'sec_user')
					--								EXEC ('INSERT INTO '+ @dbDest + @prefix +'sec_user select distinct userid, userid FROM ' + @dborig  +'cp_sec_user_audit where userid < 0 ')
					----end Ann added May 29, 2014					
					/***********************************************
					Added By: Jaspreet Singh
					Date: 2016-11-07
					Purpose: To update corporate = 'Y', so new would not be created in destination
					********************************************/
					IF EXISTS (
							SELECT tablename
							FROM mergetables
							WHERE tablename = 'cp_sec_user_audit'
							)
					BEGIN
						EXEC (
								'UPDATE ' + @dbStag + @prefix + 'cp_sec_user_audit
										SET dst_id = c.cp_sec_user_audit_id
										,corporate = ''Y''
										FROM ' + @dbStag + @prefix + 'cp_sec_user_audit a
										JOIN ' + @dbOrig + 'cp_sec_user_audit b ON a.src_id = b.cp_sec_user_audit_id and b.userid < 0
										JOIN ' + @dbDest + 'cp_sec_user_audit c ON b.userid = c.userid'
								)
					END

					----Ann added May 29, 2014
					--						if exists (select tablename from mergetables where tablename = 'sec_user')
					--								EXEC ('INSERT INTO '+ @dbStag + @prefix +'sec_user select distinct userid, userid FROM ' + @dbOrig  +'cp_sec_user_audit where userid < 0 ')
					----end Ann added May 29, 2014					
					IF EXISTS (
							SELECT tablename
							FROM mergetables
							WHERE tablename = 'AS_STD_ASSESSMENT'
							)
					BEGIN
						EXEC ('IF NOT EXISTS (SELECT 1 from ' + @dbStag + @prefix + 'AS_STD_ASSESSMENT where src_id = -1)  INSERT INTO ' + @dbStag + @prefix + 'as_std_assessment (src_id,dst_id,corporate) values (-1,-1,''N'')')
					END

					--						IF @tablename in (SELECT tablename from mergetables where IsTrigger = 'Y')
					--							BEGIN
					--								SELECT @sqlTR = 'DISABLE TRIGGER tp_' + @tablename + '_ins ON ' + @tablename
					--								EXEC (@sqlTR)
					--							END
					IF @tablename IN (
							'AR_transactions'
							,'ar_invoice'
							)
					BEGIN
						EXEC (@INSERT + @INSERTV + @insertFrom + @insertWhere + ' AND  b.corporate = ''N''' + ' ORDER BY b.dst_id ')

						SET @rowcount = @@rowcount
						SET @logMsg = @INSERT + @INSERTV + @insertFrom + @insertWhere + ' AND  b.corporate = ''N''' + ' ORDER BY b.dst_id '

						EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
							,0

						SET @logMsg = '                  ' + CONVERT(VARCHAR, @rowcount) + ' Row(s) merged '

						EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
							,0
					END

					--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
					--change print		    
					--IF @tablename in ('cp_scheduled_documentation','cp_qshift_documentation','cp_prn_documentation','cp_strikeout_reason_audit','cp_duration_documentation','cp_sec_user_audit','pho_schedule_details_deleted','prot_std_protocol_detail','pho_phys_order_ranked','pho_admin_record_entry','as_irf_tier','pho_schedule','crm_inquiry','crm_inquiry_history','pho_schedule_vitals','crm_screen_filters','pho_schedule_details','pho_scheduling_job','pho_scheduling_run','pho_phys_order_audit','pho_schedule_audit','prot_std_protocol_config','pho_schedule_details_deleted','cp_scheduled_detail','cp_duration_detail_created_info','cp_qshift_detail_created_info','cp_scheduled_detail_created_info','ar_transactions_rollup_client','pho_order_schedule','cp_duration_detail','cp_qshift_detail','as_response','pho_admin_order_audit','pho_order_related_prompt_audit','pho_order_schedule_audit','pho_phys_order_audit','pho_related_order_audit','pho_schedule_audit')
					--SELECT @sql = 'SELECT @cnt = ISNULL(max(row_id),0) FROM ' + @dbDest + @prefix + @tablename
					--EXEC sp_executesql @sql
					--	,N'@cnt BIGINT OUTPUT'
					--	,@cnt = @ChunkCount OUTPUT
					--EXEC [operational].[sproc_facacq_mergeLogWriter] @sql
					--	,0
					--SELECT @sql = 'SELECT @max_id = ISNULL(max(row_id),0) FROM ' + @dbDest + @prefix + @tablename
					--EXEC sp_executesql @sql
					--	,N'@max_id BIGINT OUTPUT'
					--	,@max_id = @maxid OUTPUT
					--EXEC [operational].[sproc_facacq_mergeLogWriter] @sql
					--	,0
					--SELECT @sql = 'SELECT @min_id = ISNULL(min(row_id),0) FROM ' + @dbDest + @prefix + @tablename
					--EXEC sp_executesql @sql
					--	,N'@min_id BIGINT OUTPUT'
					--	,@min_id = @minid OUTPUT
					--EXEC [operational].[sproc_facacq_mergeLogWriter] @sql
					--	,0
					--SET @sql = CAST(@ChunkCount AS VARCHAR(max)) + CAST(@maxid AS VARCHAR(max)) + CAST(@minid AS VARCHAR(max))
					--EXEC [operational].[sproc_facacq_mergeLogWriter] @cnt
					--	,0
					--SET @vLoop = 500000
					--SET @limit_id = @minId + @vLoop
					IF @tablename IN (
							SELECT TABLE_NAME
							FROM INFORMATION_SCHEMA.COLUMNS
							WHERE COLUMNPROPERTY(object_id(TABLE_NAME), COLUMN_NAME, 'IsIdentity') = 1
								AND TABLE_NAME = @tablename
							)
					BEGIN
						--+++++++++++Chunking code start here where table has identity+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
						--IF (@ChunkCount > 500000)
						--BEGIN
						--	EXEC [operational].[sproc_facacq_mergeLogWriter] 'Chunk is greater than 500000'
						--		,0
						--	WHILE (@minid < @maxid)
						--	BEGIN
						--		EXEC [operational].[sproc_facacq_mergeLogWriter] 'Production insert identity @maxid > 500000'
						--			,0
						--		EXEC [operational].[sproc_facacq_mergeLogWriter] 'Identity Insert ON'
						--			,0
						--		SET @limitWhere = '( b.row_id >= ' + CAST(@minid AS VARCHAR(1000)) + ' AND b.row_id < ' + CAST(@limit_id AS VARCHAR(1000)) + ' )'
						--		SET @SQLHen = 'SET IDENTITY_INSERT ' + @dbStag + @tablename + ' ON    '
						--		SET @SQLHen = @SQLHen + @INSERT + @INSERTV + @insertFrom + @insertWhere + ' AND  b.corporate = ''N'' AND ' + @limitWhere
						--		SET @SQLHen = @SQLHen + ' SET IDENTITY_INSERT ' + @dbStag + @tablename + ' OFF'
						--		--exec ('SET IDENTITY_INSERT ' + @tablename+' ON    ' + @INSERT + @INSERTV + @insertFrom + @insertWhere + ' AND  b.corporate = ''N''')
						--		SET @rowcount = @@rowcount
						--		--EXEC ('SET IDENTITY_INSERT ' + @tablename+' OFF')	
						--		EXEC (@SQLHen)
						--		EXEC [operational].[sproc_facacq_mergeLogWriter] @SQLHen
						--			,0
						--		SET @logMsg = '                  ' + CONVERT(VARCHAR, @rowcount) + ' Row(s) merged '
						--		EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
						--			,0
						--		SET @minId = @limit_id
						--		SET @limit_id = @limit_id + @vLoop
						--	END
						--END
						--+++++++++++Chunking code end here++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
						--ELSE
						--BEGIN
						EXEC [operational].[sproc_facacq_mergeLogWriter] 'Production insert identity @maxid < 500000'
							,0

						EXEC [operational].[sproc_facacq_mergeLogWriter] 'Identity Insert ON'
							,0

						SET @SQLHen = 'SET IDENTITY_INSERT ' + @dbStag + @tablename + ' ON    '
						SET @SQLHen = @SQLHen + @INSERT + @INSERTV + @insertFrom + @insertWhere + ' AND  b.corporate = ''N'''
						SET @SQLHen = @SQLHen + ' SET IDENTITY_INSERT ' + @dbStag + @tablename + ' OFF'
						--exec ('SET IDENTITY_INSERT ' + @tablename+' ON    ' + @INSERT + @INSERTV + @insertFrom + @insertWhere + ' AND  b.corporate = ''N''')
						SET @rowcount = @@rowcount

						--EXEC ('SET IDENTITY_INSERT ' + @tablename+' OFF')	
						EXEC (@SQLHen)

						EXEC [operational].[sproc_facacq_mergeLogWriter] @SQLHen
							,0

						SET @logMsg = '                  ' + CONVERT(VARCHAR, @rowcount) + ' Row(s) merged '

						EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
							,0
							--END
					END
					ELSE IF @tablename NOT IN (
							SELECT TABLE_NAME
							FROM INFORMATION_SCHEMA.COLUMNS
							WHERE COLUMNPROPERTY(object_id(TABLE_NAME), COLUMN_NAME, 'IsIdentity') = 1
								AND TABLE_NAME = @tablename
							)
					BEGIN
						----+++++++++++Chunking code start here where table has identity+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
						--IF (@ChunkCount > 500000)
						--BEGIN
						--	WHILE @minid <= @maxid
						--	BEGIN
						--		EXEC [operational].[sproc_facacq_mergeLogWriter] 'Production insert without identity @maxid > 500000'
						--			,0
						--		SET @limitWhere = '( b.row_id >= ' + CAST(@minid AS VARCHAR(1000)) + ' AND b.row_id < ' + CAST(@limit_id AS VARCHAR(1000)) + ' )'
						--		EXEC (@INSERT + @INSERTV + @insertFrom + @insertWhere + ' AND  b.corporate = ''N'' AND ' + @limitWhere)
						--		SET @rowcount = @@rowcount
						--		SET @logMsg = @INSERT + @INSERTV + @insertFrom + @insertWhere + ' AND  b.corporate = ''N'' AND ' + @limitWhere
						--		EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
						--			,0
						--		SET @logMsg = '                  ' + CONVERT(VARCHAR, @rowcount) + ' Row(s) merged '
						--		EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
						--			,0
						--		SET @minId = @limit_id
						--		SET @limit_id = @limit_id + @vLoop
						--	END
						--END
						--+++++++++++Chunking code end here+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
						--ELSE
						--BEGIN
						EXEC [operational].[sproc_facacq_mergeLogWriter] 'Production insert without identity @maxid < 500000'
							,0

						EXEC (@INSERT + @INSERTV + @insertFrom + @insertWhere + ' AND  b.corporate = ''N''')

						SET @rowcount = @@rowcount
						SET @logMsg = @INSERT + @INSERTV + @insertFrom + @insertWhere + ' AND  b.corporate = ''N'''

						EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
							,0

						SET @logMsg = '                  ' + CONVERT(VARCHAR, @rowcount) + ' Row(s) merged '

						EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
							,0
							--END
					END

					--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
					--PRINT @SQLDelete + @insertFrom + @insertWhere + ' AND  b.corporate = ''N'') and corporate = ''N'' '
					/*ONLY run the delete when the table is a parent table (with children)*/
					IF EXISTS (
							SELECT 1
							FROM mergejoins
							WHERE parenttable = @tableName
							)
						--same--differs from CDN
						--				IF @tablename in (SELECT tablename from mergetables where IsReferencedByForeignKey = 'Y')
					BEGIN
						SET @logMsg = @SQLDelete + ' LEFT JOIN ' + @dbStag + @tableName + ' b on a.dst_id = b.' + @idField + ' WHERE b.' + @idField + ' IS NULL and a.corporate = ''N'' '

						EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
							,0;

						EXEC (@SQLDelete + ' LEFT JOIN ' + @dbStag + @tableName + ' b on a.dst_id = b.' + @idField + ' WHERE b.' + @idField + ' IS NULL and a.corporate = ''N'' ');

						SET @logMsg = '                  ' + CONVERT(VARCHAR, @@ROWCOUNT) + ' Row(s) deleted '

						EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
							,0
					END
				END
				ELSE
					EXEC [operational].[sproc_facacq_mergeLogWriter] '                  0 Row(s) merged'
						,0
			END
					--				IF @tablename in (SELECT tablename from mergetables where IsTrigger = 'Y')
					--				BEGIN
					--						SELECT @sqlTR = 'ENABLE TRIGGER tp_' + @tablename + '_ins ON ' + @tablename
					--						EXEC (@sqlTR)
					--				END--29
		END --18
				----------------------------------------------------------------@IDFIELD not null END
		ELSE
			----------------------------------------------------------------@IDFIELD null Start
		BEGIN
			IF @removeDup <> ''
			BEGIN
				SELECT @removeDup = @removeDup + ')' + @removeDup1

				SELECT @insertWhere = @insertWhere + CASE 
						WHEN @insertWhere = ''
							THEN ' WHERE '
						ELSE ' AND '
						END + @removeDup

				EXEC [operational].[sproc_facacq_mergeLogWriter] @tablename
					,0

				EXEC [operational].[sproc_facacq_mergeLogWriter] '_________No PK________'
					,0

				EXEC [operational].[sproc_facacq_mergeLogWriter] @INSERT
					,0

				EXEC [operational].[sproc_facacq_mergeLogWriter] @INSERTV
					,0

				EXEC [operational].[sproc_facacq_mergeLogWriter] @insertFrom
					,0

				EXEC [operational].[sproc_facacq_mergeLogWriter] @insertWhere
					,0

				EXEC [operational].[sproc_facacq_mergeLogWriter] @removedup
					,0
			END

			/* CONTACT Changes (2007/09/21)*/
			IF @SpecialCase IS NOT NULL
			BEGIN
				SET @SpecialCase = CASE 
						WHEN @SpecialCase LIKE '%[[]mpi001]'
							THEN 'mpi'
						WHEN @SpecialCase LIKE '%[[]fac001]'
							THEN 'staff'
						ELSE NULL
						END
				SET @insertWhere = @insertWhere + ' AND subclass_id IN (SELECT item_id FROM ' + @dbOrig + 'common_code where item_code = ''sbclas'' AND item_description in ' + CASE 
						WHEN @SpecialCase = 'mpi'
							THEN '(''Resident'')'
						WHEN @SpecialCase = 'staff'
							THEN '(''Center'',''Medical Professional'')'
						ELSE '(''Resident'')'
						END + ')  '
			END

			SET @logMsg = @INSERT + @INSERTV + @insertFrom + @insertWhere + @queryFilter --Ann added Nov 30

			EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
				,0

			EXEC (@INSERT + @INSERTV + @insertFrom + @insertWhere + @queryFilter)

			SET @logMsg = '         ' + CONVERT(VARCHAR, @@ROWCOUNT) + ' Row(s) merged '

			EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
				,0
		END

		----------------------------------------------------------------@IDFIELD null end
		CLOSE c_mergeCopyDataFields

		DEALLOCATE c_mergeCopyDataFields

		DELETE
		FROM #mergeCopyData

		/****************************************************************************************************************
			****************************************************************************************************************/
		/*27 July 2020 Multi_Fac_Id will be populated part of Insert, no need to update
			IF (@tablename <> 'Facility')
			BEGIN
				SET @sql = NULL
				SET @sql = 'IF (
						(	
							SELECT ISNULL(COUNT(1), 0) rowcnt
							FROM ' + @dbStag + @tablename + '
						) > 0
					)
				BEGIN
					------IF NOT EXISTS
					------	(	
					------		SELECT 1
					------		FROM ' + @dbStag + @tablename + '
					------		WHERE Multi_Fac_Id = ' + cast(@fac_idToCopyTo AS VARCHAR) + '
					------)
					------BEGIN
						UPDATE ' + @dbStag + @tablename + ' SET Multi_Fac_Id =  ' + cast(@fac_idToCopyTo AS VARCHAR) + ' WHERE Multi_Fac_Id = 0
					------END
				END'

				EXEC (@sql)

				EXEC [operational].[sproc_facacq_mergeLogWriter] @sql
					,0
			END
			*/
		/****************************************************************************************************************
			****************************************************************************************************************/
		/*
			SET @sql = 'IF EXISTS(SELECT 1 FROM ' + @dbStag + 'Multi_Facility where fac_id = ' + convert(VARCHAR(10), @fac_idToCopyTo)+ ')
								BEGIN
										IF (
												(	
													SELECT ISNULL(COUNT(1), 0) rowcnt
													FROM ' + @dbStag + @tablename + '
												) > 0
											)
										BEGIN
											IF NOT EXISTS
												(	
													SELECT 1
													FROM ' + @dbStag + @tablename + '
													WHERE Multi_Fac_Id = ' + cast(@dst_fac_id as varchar) + '
											)
											BEGIN
												UPDATE ' + @dbStag + @tablename + ' SET Multi_Fac_Id =  ' + cast(@dst_fac_id as varchar) + ' WHERE Multi_Fac_Id = 0
											END
										END
								END'
			*/
		/*mergeFrequencies*/
		--IF @tablename = 'cp_std_schedule'
		--BEGIN
		--	EXEC dbo.mergeFrequencies @prefix       = @prefix,
		--							@reg_idToCopy = @reg_idToCopy,
		--							@fac_id       = @fac_idToCopyTo
		--END
		/*Enterprise Users
		Modified By: Jaspreet Singh
		Date: 2018-06-29
		Reason: Sec_user_facility duplicate error issue while running ei
		*/
		----IF @tablename = 'sec_user_facility'
		----BEGIN
		----	EXEC [operational].[sproc_facacq_mergeLogWriter] '         Modifying enterprise users'
		----		,0
		----	SET @sql = 'INSERT INTO ' + @dbStag + 'sec_user_facility 
		----		SELECT b.userid
		----		,a.fac_id
		----		,1
		----	FROM facility a
		----		,sec_user b
		----	WHERE b.admin_user_type = ''E''
		----		AND a.fac_id NOT IN (
		----			SELECT facility_id
		----			FROM ' + @dbStag + 'sec_user_facility
		----			WHERE userid = b.userid
		----			)'
		----	EXEC [operational].[sproc_facacq_mergeLogWriter] @sql
		----		,0
		----	EXEC (@sql)
		----END
		---- Comented above code as per meeting discussion on 10/4/2018 with Ann, Rina and Nigel
		/*ar_recurring_transaction*/
		IF @tablename = 'ar_recurring_transactions'
		BEGIN
			IF EXISTS (
					SELECT 1
					FROM [dbo].mergetables
					WHERE tablename = 'ar_lib_charge_codes'
					)
				SET @INSERTTABLE = 'ar_lib_charge_codes'
			ELSE
				SET @INSERTTABLE = 'ar_item_types'

			SELECT @INSERT = 'UPDATE ' + @dbStag + 'ar_recurring_transactions SET item_type_id = copyar.dst_id ' + ' FROM ' + @prefix + @INSERTTABLE + ' copyar ' + 'WHERE copyar.src_id = ar_recurring_transactions.item_type_id ' + ' AND ar_recurring_transactions.applies_to = ''B'' ' + ' AND ar_recurring_transactions.fac_id in (SELECT dst_id FROM ' + @prefix + 'facility) '

			EXEC (@INSERT)

			SELECT @INSERT = 'UPDATE ' + @dbStag + 'ar_recurring_transactions SET item_type_id = copyar.dst_id ' + ' FROM ' + @prefix + @INSERTTABLE + ' copyar ' + ' WHERE copyar.src_id = ar_recurring_transactions.item_type_id ' + '  AND ar_recurring_transactions.applies_to <> ''B'' ' + ' AND ar_recurring_transactions.fac_id in (SELECT dst_id FROM ' + @prefix + 'facility) '

			EXEC (@INSERT)
		END

		FETCH NEXT
		FROM c_mergeCopyData
		INTO @tablename
			,@idField
			,@scopeField1
			,@scopeField2
			,@scopeField3
			,@scopeField4
			,@scopeField5
			,@scopeField6
			,@scopeField7
			,@cleanUpTable
			,@queryFilter
			,@HasNoPK
	END

	--------------------------------------------------------------------------------------------------------------------- END While (1)
	CLOSE c_mergeCopyData

	DEALLOCATE c_mergeCopyData

	DROP TABLE #mergeCopyData

	EXEC [operational].[sproc_facacq_mergeLogWriter] '--Finished SP : mergeCopyData'
		,0
END /*mergeCopyData*/
	--GO
GO



	select * from pcc_db_version
	order by 3 desc