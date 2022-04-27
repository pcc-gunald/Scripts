USE test_usei3sava1
GO

--For Current Residents

--\\udb2522\DATALOAD\Prod\ImportHelper\ImportScripts\FacilityUtilization  

DECLARE @SOURCE_FAC_ID INT = 183 -- change
DECLARE @FAC_NAME VARCHAR(75) = ''

SELECT @FAC_NAME = NAME
FROM FACILITY
WHERE FAC_ID = @SOURCE_FAC_ID

DECLARE @COUNT INT
DECLARE @DATE DATETIME = 'R_CURRESDATE' -- change if current residents
SET NOCOUNT ON 

IF (Object_ID('TempDB..#RESULTS') IS NOT NULL)
	DROP TABLE #RESULTS

CREATE TABLE #RESULTS (
	FACILITY_NAME VARCHAR(75)
	,APPLICATION_FUNCTION VARCHAR(100)
	,ENABLED VARCHAR(100)
	,TABLE_COUNT VARCHAR(100)
	,ADDITIONAL_INFORMATION VARCHAR(MAX)
	)
	
BEGIN
	BEGIN
		SELECT @COUNT = count(1)
		FROM clients
		WHERE FAC_ID = @SOURCE_FAC_ID
			AND deleted = 'N'
			--Updated by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, start
			--AND discharge_date IS NULL
			AND isnull(discharge_date, @DATE) >= @DATE
			AND admission_date IS NOT NULL

		--Updated by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end
		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'ResidentCount'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'ResidentCount'
				,'N'
				,0
				,''
				)
	END

	BEGIN
		INSERT INTO #RESULTS
		SELECT @FAC_NAME
			,'State Code'
			,prov
			,prov
			,''
		FROM facility
		WHERE fac_id = @SOURCE_FAC_ID
	END

	BEGIN
		INSERT INTO #RESULTS
		SELECT @FAC_NAME
			,NAME
			,VALUE
			,CASE 
				WHEN value = 'Y'
					THEN 1
				ELSE 0
				END
			,''
		FROM CONFIGURATION_PARAMETER
		WHERE NAME IN (
				'enable_res_photos'
				,'enable_emar'
				,'enable_mar'
				,'enable_poc'
				,'as_enable_mds_extverify'
				,'mds_automated_submission'
				)
			AND fac_id = @SOURCE_FAC_ID
	END

	--Added by: Linlin Jing, Date: 2018-02-14, Reason: SmartSheet - DShelper&OtherDevelopment - Row133, start
	BEGIN
		SELECT @COUNT = count(1)
		FROM dcm_document_client
		WHERE client_id IN (
				SELECT client_id
				FROM clients
				WHERE fac_id = @SOURCE_FAC_ID
					--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, start
					AND deleted = 'N'
					AND isnull(discharge_date, @DATE) >= @DATE
					AND admission_date IS NOT NULL
				)

		--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end
		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'Document Manager'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'Document Manager'
				,'N'
				,0
				,''
				)
	END

	--Added by: Linlin Jing, Date: 2018-02-14, Reason: SmartSheet - DShelper&OtherDevelopment - Row133, end
	--Added by: Linlin Jing, Date: 2017-11-05, Reason: SmartSheet - DShelper&OtherDevelopment - Row105, start
	BEGIN
		SELECT @COUNT = count(1)
		FROM dbo.configuration_parameter
		WHERE NAME = 'enable_crm'
			AND value = 'Y'

		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'enable_crm'
				,'Y'
				,1
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'enable_crm'
				,'N'
				,0
				,''
				)
	END

	--Added by: Linlin Jing, Date: 2017-11-05, Reason: SmartSheet - DShelper&OtherDevelopment - Row105, end
	--Added by: Linlin Jing, Date: 2017-11-05, Reason: SmartSheet - DShelper&OtherDevelopment - Row106, start
	BEGIN
		SELECT @COUNT = count(1)
		FROM facility f WITH (NOLOCK)
		JOIN message_profile mp WITH (NOLOCK) ON mp.fac_id = f.fac_id
		JOIN lib_message_profile lmp WITH (NOLOCK) ON mp.message_profile_id = lmp.message_profile_id
		WHERE f.deleted = 'N'
			AND f.fac_id = @SOURCE_FAC_ID
			AND ISNULL(f.messages_enabled_flag, 'N') = 'Y'
			AND ISNULL(mp.is_enabled, 'N') = 'Y'
			AND lmp.vendor_code = 'COMS_Assessment'

		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'enable_COMS_Assessment(vendor_code)'
				,'Y'
				,1
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'enable_COMS_Assessment(vendor_code)'
				,'N'
				,0
				,''
				)
	END

	--Added by: Linlin Jing, Date: 2017-11-05, Reason: SmartSheet - DShelper&OtherDevelopment - Row106, end
	----Added by: Linlin Jing, Date: 2017-11-05, Reason: SmartSheet - DShelper&OtherDevelopment - Row107, start
	BEGIN
		INSERT INTO #RESULTS
		VALUES (
			@FAC_NAME
			--,'Tels_Integration'
			,'Integration' --added by Cynthia Cui on 20171222 as per request of Ann and Katheleen
			,'Y'
			,1
			,(
				(
					SELECT (
							SELECT cm + '; '
							FROM (
								SELECT DISTINCT a.url AS 'cm'
								FROM dbo.pcc_ext_vendor_url_config a
								WHERE a.url <> 'pointclickcare.training.reliaslearning.com/lib/Authenticate.aspx?ReturnUrl=%2f'
								
								UNION
								
								SELECT DISTINCT b.value AS 'cm'
								FROM dbo.configuration_parameter b
								WHERE b.NAME = 'enable_cs_quick_link_url'
									AND b.value <> 'https://pointclickcare.training.reliaslearning.com/lib/Authenticate.aspx?ReturnUrl=%2f'
									AND b.value <> ''
									AND b.value IS NOT NULL
								) AS c
							FOR XML PATH('')
							)
					)
				)
			)
	END

	----Added by: Linlin Jing, Date: 2017-11-05, Reason: SmartSheet - DShelper&OtherDevelopment- Row107, end
	BEGIN
		SELECT @COUNT = count(1)
		FROM upload_files
		WHERE client_id IN (
				SELECT client_id
				FROM clients
				WHERE fac_id = @SOURCE_FAC_ID
					--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, start
					AND deleted = 'N'
					AND isnull(discharge_date, @DATE) >= @DATE
					AND admission_date IS NOT NULL
				)

		--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end
		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'Online Documentation'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'Online Documentation'
				,'N'
				,0
				,''
				)
	END

	BEGIN
		SELECT @COUNT = count(1)
		FROM AR_TRANSACTIONS
		WHERE deleted = 'N'
			AND created_by <> '_system_'
			AND FAC_ID = @SOURCE_FAC_ID
			--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, start
			AND (
				client_id IN (
					SELECT client_id
					FROM clients WITH (NOLOCK)
					WHERE fac_id = @SOURCE_FAC_ID
						AND deleted = 'N'
						AND isnull(discharge_date, @DATE) >= @DATE
						AND admission_date IS NOT NULL
					)
				OR client_id IS NULL
				)

		--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end
		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'BILLING'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'BILLING'
				,'N'
				,0
				,''
				)
	END

	BEGIN
		SELECT @COUNT = count(1)
		FROM CENSUS_ITEM
		WHERE FAC_ID = @SOURCE_FAC_ID
			AND deleted = 'N'
			--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, start
			AND client_id IN (
				SELECT client_id
				FROM clients WITH (NOLOCK)
				WHERE fac_id = @SOURCE_FAC_ID
					AND deleted = 'N'
					AND isnull(discharge_date, @DATE) >= @DATE
					AND admission_date IS NOT NULL
				)

		--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end
		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'CENSUS'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'CENSUS'
				,'N'
				,0
				,''
				)
	END

	BEGIN
		SELECT @COUNT = count(1)
		FROM WORK_ACTIVITY
		WHERE FAC_ID = @SOURCE_FAC_ID
			AND deleted = 'N'
			--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, start
			AND (
				client_id IN (
					SELECT client_id
					FROM clients WITH (NOLOCK)
					WHERE fac_id = @SOURCE_FAC_ID
						AND deleted = 'N'
						AND isnull(discharge_date, @DATE) >= @DATE
						AND admission_date IS NOT NULL
					)
				OR client_id IS NULL
				)

		--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end
		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'COLLECTIONS'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'COLLECTIONS'
				,'N'
				,0
				,''
				)
	END

	BEGIN
		SELECT @COUNT = count(1)
		FROM TA_TRANSACTION
		WHERE FAC_ID = @SOURCE_FAC_ID
			AND deleted = 'N'
			--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, start
			AND (
				client_id IN (
					SELECT client_id
					FROM clients WITH (NOLOCK)
					WHERE fac_id = @SOURCE_FAC_ID
						AND deleted = 'N'
						AND isnull(discharge_date, @DATE) >= @DATE
						AND admission_date IS NOT NULL
					)
				OR client_id IS NULL
				)

		--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end
		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'TRUST'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'TRUST'
				,'N'
				,0
				,''
				)
	END

	BEGIN
		SELECT @COUNT = count(1)
		FROM INC_INCIDENT
		WHERE FAC_ID = @SOURCE_FAC_ID
			AND deleted = 'N'
			--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, start
			AND client_id IN (
				SELECT client_id
				FROM clients WITH (NOLOCK)
				WHERE fac_id = @SOURCE_FAC_ID
					AND deleted = 'N'
					AND isnull(discharge_date, @DATE) >= @DATE
					AND admission_date IS NOT NULL
				)

		--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end
		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'RISK MANAGEMENT'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'RISK MANAGEMENT'
				,'N'
				,0
				,''
				)
	END

	BEGIN
		SELECT @COUNT = count(1)
		FROM AS_ASSESSMENT
		WHERE FAC_ID = @SOURCE_FAC_ID
			AND STD_ASSESS_ID = 1
			AND deleted = 'N'
			--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, start
			AND client_id IN (
				SELECT client_id
				FROM clients WITH (NOLOCK)
				WHERE fac_id = @SOURCE_FAC_ID
					AND deleted = 'N'
					AND isnull(discharge_date, @DATE) >= @DATE
					AND admission_date IS NOT NULL
				)

		--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end
		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'MDS 2.0'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'MDS 2.0'
				,'N'
				,0
				,''
				)
	END

	BEGIN
		SELECT @COUNT = count(1)
		FROM AS_ASSESSMENT
		WHERE FAC_ID = @SOURCE_FAC_ID
			AND STD_ASSESS_ID = 11
			AND deleted = 'N'
			--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, start
			AND client_id IN (
				SELECT client_id
				FROM clients WITH (NOLOCK)
				WHERE fac_id = @SOURCE_FAC_ID
					AND deleted = 'N'
					AND isnull(discharge_date, @DATE) >= @DATE
					AND admission_date IS NOT NULL
				)

		--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end
		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'MDS 3.0'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'MDS 3.0'
				,'N'
				,0
				,''
				)
	END

	BEGIN
		SELECT @COUNT = count(1)
		FROM AS_ASSESSMENT
		WHERE FAC_ID = @SOURCE_FAC_ID
			AND STD_ASSESS_ID = 7
			AND deleted = 'N'
			--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, start
			AND client_id IN (
				SELECT client_id
				FROM clients WITH (NOLOCK)
				WHERE fac_id = @SOURCE_FAC_ID
					AND deleted = 'N'
					AND isnull(discharge_date, @DATE) >= @DATE
					AND admission_date IS NOT NULL
				)

		--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end
		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'MMQ-Massachusetts'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'MMQ-Massachusetts'
				,'N'
				,0
				,''
				)
	END

	BEGIN
		SELECT @COUNT = count(1)
		FROM AS_ASSESSMENT
		WHERE FAC_ID = @SOURCE_FAC_ID
			AND STD_ASSESS_ID IN (
				8
				,12
				)
			AND deleted = 'N'
			--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, start
			AND client_id IN (
				SELECT client_id
				FROM clients WITH (NOLOCK)
				WHERE fac_id = @SOURCE_FAC_ID
					AND deleted = 'N'
					AND isnull(discharge_date, @DATE) >= @DATE
					AND admission_date IS NOT NULL
				)

		--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end
		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'MMA-Maryland'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'MMA-Maryland'
				,'N'
				,0
				,''
				)
	END

	--Modify by: Linlin Jing, Date: 2017-07-06, Reason: SmartSheet - Update EI Script - Row31, start
	/*
--OLD

	BEGIN
		SELECT @COUNT = count(1)
		FROM AS_ASSESSMENT
		WHERE FAC_ID = @SOURCE_FAC_ID
			AND STD_ASSESS_ID NOT IN (
				1
				,11
				)
			AND client_id <> '-9999' 

		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'CUSTOM UDA''s'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'CUSTOM UDA''s'
				,'N'
				,0
				,''
				)
	END
*/
	--non-System UDA
	BEGIN
		SELECT @COUNT = count(1)
		FROM AS_ASSESSMENT
		WHERE FAC_ID = @SOURCE_FAC_ID
			AND STD_ASSESS_ID NOT IN (
				1
				,11
				)
			AND STD_ASSESS_ID NOT IN (
				SELECT std_assess_id
				FROM as_std_assessment_system_assessment_mapping
				)
			AND client_id <> '-9999'
			AND deleted = 'N'
			--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, start
			AND client_id IN (
				SELECT client_id
				FROM clients WITH (NOLOCK)
				WHERE fac_id = @SOURCE_FAC_ID
					AND deleted = 'N'
					AND isnull(discharge_date, @DATE) >= @DATE
					AND admission_date IS NOT NULL
				)

		--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end
		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'CUSTOM UDA''s'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'CUSTOM UDA''s'
				,'N'
				,0
				,''
				)
	END

	--System UDA
	BEGIN
		SELECT @COUNT = count(1)
		FROM AS_ASSESSMENT
		WHERE FAC_ID = @SOURCE_FAC_ID
			AND STD_ASSESS_ID NOT IN (
				1
				,11
				)
			AND STD_ASSESS_ID IN (
				SELECT std_assess_id
				FROM as_std_assessment_system_assessment_mapping
				)
			AND client_id <> '-9999'
			AND deleted = 'N'
			--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, start
			AND client_id IN (
				SELECT client_id
				FROM clients WITH (NOLOCK)
				WHERE fac_id = @SOURCE_FAC_ID
					AND deleted = 'N'
					AND isnull(discharge_date, @DATE) >= @DATE
					AND admission_date IS NOT NULL
				)

		--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end
		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'System  UDA''s'
				,'Y'
				,@COUNT
				,(
					SELECT DISTINCT b.description + ', '
					FROM as_std_assessment_system_assessment_mapping a
					JOIN as_std_assessment b ON a.std_assess_id = b.std_assess_id
					JOIN as_assessment c ON c.std_assess_id = a.std_assess_id
					WHERE c.client_id <> - 9999
						AND c.fac_id = @SOURCE_FAC_ID --
						--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, start
						AND c.client_id IN (
							SELECT client_id
							FROM clients WITH (NOLOCK)
							WHERE fac_id = @SOURCE_FAC_ID
								AND deleted = 'N'
								AND isnull(discharge_date, @DATE) >= @DATE
								AND admission_date IS NOT NULL
							)
					--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end
					FOR XML PATH('')
					)
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'System UDA''s'
				,'N'
				,0
				,(
					SELECT DISTINCT b.description + ', '
					FROM as_std_assessment_system_assessment_mapping a
					JOIN as_std_assessment b ON a.std_assess_id = b.std_assess_id
					JOIN as_assessment c ON c.std_assess_id = a.std_assess_id
					WHERE c.client_id <> - 9999
						AND c.fac_id = @SOURCE_FAC_ID --
						--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, start
						AND c.client_id IN (
							SELECT client_id
							FROM clients WITH (NOLOCK)
							WHERE fac_id = @SOURCE_FAC_ID
								AND deleted = 'N'
								AND isnull(discharge_date, @DATE) >= @DATE
								AND admission_date IS NOT NULL
							)
					--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end
					FOR XML PATH('')
					)
				)
	END

	--Modify by: Linlin Jing, Date: 2017-07-06, Reason: SmartSheet - Update EI Script - Row31, end
	--Modified by: Linlin Jing, Date: 2017-11-22, Reason: SmartSheet - DShelper&OtherDevelopment - Row101, start
	BEGIN
		SELECT @COUNT = count(1)
		FROM as_assessment
		WHERE FAC_ID = @SOURCE_FAC_ID
			AND std_assess_id IN (
				SELECT std_assess_id
				FROM as_std_assessment
				WHERE description LIKE '%PCC Skin & Wound%'
					AND deleted = 'N'
					AND STATUS = 'A'
					AND std_assess_id IN (
						SELECT std_assess_id
						FROM as_std_assessment_system_assessment_mapping
						)
				)
			AND client_id <> '-9999'
			--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, start
			AND client_id IN (
				SELECT client_id
				FROM clients WITH (NOLOCK)
				WHERE fac_id = @SOURCE_FAC_ID
					AND deleted = 'N'
					AND isnull(discharge_date, @DATE) >= @DATE
					AND admission_date IS NOT NULL
				)

		--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end
		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'SKIN and WOUND'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'SKIN and WOUND'
				,'N'
				,0
				,''
				)
	END

	--Modified by: Linlin Jing, Date: 2017-11-22, Reason: SmartSheet - DShelper&OtherDevelopment - Row101, end
	BEGIN
		SELECT @COUNT = count(1)
		FROM WV_VITALS
		WHERE FAC_ID = @SOURCE_FAC_ID
			--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, start
			AND client_id IN (
				SELECT client_id
				FROM clients WITH (NOLOCK)
				WHERE fac_id = @SOURCE_FAC_ID
					AND deleted = 'N'
					AND isnull(discharge_date, @DATE) >= @DATE
					AND admission_date IS NOT NULL
				)

		--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end
		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'WEIGHTS AND VITALS'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'WEIGHTS AND VITALS'
				,'N'
				,0
				,''
				)
	END

	BEGIN
		SELECT @COUNT = count(1)
		FROM DIAGNOSIS
		WHERE FAC_ID = @SOURCE_FAC_ID
			AND deleted = 'N'
			--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, start
			AND client_id IN (
				SELECT client_id
				FROM clients WITH (NOLOCK)
				WHERE fac_id = @SOURCE_FAC_ID
					AND deleted = 'N'
					AND isnull(discharge_date, @DATE) >= @DATE
					AND admission_date IS NOT NULL
				)

		--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end
		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'DIAGNOSIS'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'DIAGNOSIS'
				,'N'
				,0
				,''
				)
	END

	BEGIN
		SELECT @COUNT = count(1)
		FROM CR_ALERT
		WHERE FAC_ID = @SOURCE_FAC_ID
			AND deleted = 'N'
			--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, start
			AND client_id IN (
				SELECT client_id
				FROM clients WITH (NOLOCK)
				WHERE fac_id = @SOURCE_FAC_ID
					AND deleted = 'N'
					AND isnull(discharge_date, @DATE) >= @DATE
					AND admission_date IS NOT NULL
				)

		--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end
		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'ALERTS'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'ALERTS'
				,'N'
				,0
				,''
				)
	END

	BEGIN
		SELECT @COUNT = count(1)
		FROM CR_CLIENT_IMMUNIZATION
		WHERE FAC_ID = @SOURCE_FAC_ID
			AND deleted = 'N'
			--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, start
			AND client_id IN (
				SELECT client_id
				FROM clients WITH (NOLOCK)
				WHERE fac_id = @SOURCE_FAC_ID
					AND deleted = 'N'
					AND isnull(discharge_date, @DATE) >= @DATE
					AND admission_date IS NOT NULL
				)

		--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end
		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'IMMUNIZATION'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'IMMUNIZATION'
				,'N'
				,0
				,''
				)
	END

	BEGIN
		SELECT @COUNT = count(1)
		FROM PHO_PHYS_ORDER
		WHERE FAC_ID = @SOURCE_FAC_ID
			--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, start
			AND client_id IN (
				SELECT client_id
				FROM clients WITH (NOLOCK)
				WHERE fac_id = @SOURCE_FAC_ID
					AND deleted = 'N'
					AND isnull(discharge_date, @DATE) >= @DATE
					AND admission_date IS NOT NULL
				)

		--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end
		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'PHYSICIAN ORDERS'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'PHYSICIAN ORDERS'
				,'N'
				,0
				,''
				)
	END

	BEGIN
		SELECT @COUNT = count(1)
		FROM PN_PROGRESS_NOTE
		WHERE FAC_ID = @SOURCE_FAC_ID
			AND deleted = 'N'
			--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, start
			AND client_id IN (
				SELECT client_id
				FROM clients WITH (NOLOCK)
				WHERE fac_id = @SOURCE_FAC_ID
					AND deleted = 'N'
					AND isnull(discharge_date, @DATE) >= @DATE
					AND admission_date IS NOT NULL
				)

		--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end
		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'PROGRESS NOTES'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'PROGRESS NOTES'
				,'N'
				,0
				,''
				)
	END

	BEGIN
		SELECT @COUNT = count(1)
		FROM CARE_PLAN
		WHERE FAC_ID = @SOURCE_FAC_ID
			AND deleted = 'N'
			--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, start
			AND client_id IN (
				SELECT client_id
				FROM clients WITH (NOLOCK)
				WHERE fac_id = @SOURCE_FAC_ID
					AND deleted = 'N'
					AND isnull(discharge_date, @DATE) >= @DATE
					AND admission_date IS NOT NULL
				)

		--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end
		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'CARE PLANS'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'CARE PLANS'
				,'N'
				,0
				,''
				)
	END

	BEGIN
		SELECT @COUNT = count(1)
		FROM QA_ACTIVITY ---WHERE FAC_ID = @SOURCE_FAC_ID

		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'QIA'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'QIA'
				,'N'
				,0
				,''
				)
	END

	BEGIN
		SELECT @COUNT = count(1)
		FROM GL_TRANSACTIONS
		WHERE FAC_ID = @SOURCE_FAC_ID
			AND deleted = 'N'

		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'GENERAL LEDGER'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'GENERAL LEDGER'
				,'N'
				,0
				,''
				)
	END

	BEGIN
		SELECT @COUNT = count(1)
		FROM AP_TRANSACTIONS
		WHERE FAC_ID = @SOURCE_FAC_ID
			AND deleted = 'N'

		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'ACCOUNTS PAYABLE'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'ACCOUNTS PAYABLE'
				,'N'
				,0
				,''
				)
	END

	BEGIN
		SELECT @COUNT = count(1)
		FROM CRM_INQUIRY
		WHERE ADMITTING_FAC_ID = @SOURCE_FAC_ID
			AND deleted = 'N'

		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'MARKETING/IRM'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'MARKETING/IRM'
				,'N'
				,0
				,''
				)
	END

	BEGIN
		SELECT @COUNT = count(1)
		FROM cp_qshift_detail
		WHERE FAC_ID = @SOURCE_FAC_ID
			AND fac_id IN (
				SELECT fac_id
				FROM configuration_parameter
				WHERE NAME = 'enable_poc'
					AND value = 'Y'
				)
			--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, start
			AND schedule_id IN (
				SELECT schedule_id
				FROM cp_schedule WITH (NOLOCK)
				WHERE intervention_id IN (
						SELECT gen_intervention_id
						FROM cp_rev_intervention WITH (NOLOCK)
						WHERE clientid IN (
								SELECT client_id
								FROM clients WITH (NOLOCK)
								WHERE fac_id = @SOURCE_FAC_ID
									AND deleted = 'N'
									AND isnull(discharge_date, @DATE) >= @DATE
									AND admission_date IS NOT NULL
								)
						)
				)

		--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end
		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'POC MODULE'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'POC MODULE'
				,'N'
				,0
				,''
				)
	END

	BEGIN
		SELECT @COUNT = count(1)
		FROM dbo.USER_DEFINED_DATA WITH (NOLOCK)
		WHERE FAC_ID = @SOURCE_FAC_ID
			AND deleted = 'N'
			AND client_id IN (
				SELECT client_id
				FROM clients WITH (NOLOCK)
				WHERE fac_id = @SOURCE_FAC_ID
					AND deleted = 'N'
					AND isnull(discharge_date, @DATE) >= @DATE
					AND admission_date IS NOT NULL
				)

		--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end
		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'USER_DEFINED_DATA'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'USER_DEFINED_DATA'
				,'N'
				,0
				,''
				)
	END

	BEGIN
		SELECT @COUNT = count(1)
		FROM dbo.result_order_source WITH (NOLOCK)
		WHERE result_type_id = 1 
			AND FAC_ID = @SOURCE_FAC_ID
			AND client_id IN (
				SELECT client_id
				FROM clients WITH (NOLOCK)
				WHERE fac_id = @SOURCE_FAC_ID
					AND deleted = 'N'
					AND isnull(discharge_date, @DATE) >= @DATE
					AND admission_date IS NOT NULL
				)

		--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end
		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'LAB RESULT'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'LAB RESULT'
				,'N'
				,0
				,''
				)
	END

	BEGIN
		SELECT @COUNT = count(1)
		FROM dbo.result_order_source WITH (NOLOCK)
		WHERE result_type_id = 2 --Radiology
			AND FAC_ID = @SOURCE_FAC_ID
			AND client_id IN (
				SELECT client_id
				FROM clients WITH (NOLOCK)
				WHERE fac_id = @SOURCE_FAC_ID
					AND deleted = 'N'
					AND isnull(discharge_date, @DATE) >= @DATE
					AND admission_date IS NOT NULL
				)

		--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end
		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'Radiology RESULT'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'Radiology RESULT'
				,'N'
				,0
				,''
				)
	END

	--Added by: Linlin Jing, Date: 2017-07-14, Reason: SmartSheet - Update EI Script - Row34, start
	BEGIN
		SELECT @COUNT = count(1)
		FROM dbo.admin_note WITH (NOLOCK)
		WHERE client_id IN (
				SELECT client_id
				FROM clients
				WHERE fac_id = @SOURCE_FAC_ID
					--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, start
					AND deleted = 'N'
					AND isnull(discharge_date, @DATE) >= @DATE
					AND admission_date IS NOT NULL
				)

		--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end		
		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'NOTES'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'NOTES'
				,'N'
				,0
				,''
				)
	END

	--Added by: Linlin Jing, Date: 2017-07-14, Reason: SmartSheet - Update EI Script - Row34, end
	--Modify by: Linlin Jing, Date: 2017-07-10, Reason: SmartSheet - Update EI Script - Row33, start
	BEGIN
		SELECT @COUNT = count(1)
		FROM dbo.configuration_parameter
		WHERE FAC_ID = @SOURCE_FAC_ID
			AND NAME = 'care_pathway_module'
			AND value = 'Y'

		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'Care Pathway'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'Care Pathway'
				,'N'
				,0
				,''
				)
	END

	--Modify by: Linlin Jing, Date: 2017-07-10, Reason: SmartSheet - Update EI Script - Row33, end
	INSERT INTO #results
	SELECT DISTINCT ''
		,'Message Vendor Setup'
		,'Y'
		,1
		,''
	FROM facility f WITH (NOLOCK)
	LEFT JOIN message_profile mp WITH (NOLOCK) ON mp.fac_id = f.fac_id --AND mp.deleted = 'N'
	LEFT JOIN map_identifier mi WITH (NOLOCK) ON mi.fac_id = f.fac_id --AND mi.vendor_code = mp.vendor_code
	WHERE f.deleted = 'N'
		AND f.fac_id = @SOURCE_FAC_ID
		AND ISNULL(f.messages_enabled_flag, 'N') = 'Y'

	INSERT INTO #results
	SELECT DISTINCT ''
		,'Third Party Education'
		,'Y'
		,1
		,''
	FROM facility f WITH (NOLOCK)
	LEFT JOIN configuration_parameter educ1 WITH (NOLOCK) ON educ1.fac_id = f.fac_id
		AND educ1.[name] = 'mds3_education_username'
	LEFT JOIN configuration_parameter educ2 WITH (NOLOCK) ON educ2.fac_id = f.fac_id
		AND educ2.[name] = 'mds3_education_password'
	WHERE f.deleted = 'N'
		AND f.fac_id = @SOURCE_FAC_ID
		AND len(ISNULL(educ1.[value], '')) > 0

	INSERT INTO #results
	SELECT DISTINCT ''
		,'Third Party MDS Data'
		,'Y'
		,1
		,''
	FROM facility f WITH (NOLOCK)
	LEFT JOIN as_vendor_configuration mdsdata WITH (NOLOCK) ON mdsdata.fac_id = f.fac_id
		AND std_assess_id = 11
		AND mdsdata.deleted = 'N'
	WHERE f.deleted = 'N'
		AND f.fac_id = @SOURCE_FAC_ID
		AND len(ISNULL(mdsdata.username, '')) > 0

	INSERT INTO #results
	SELECT DISTINCT ''
		,'Third Party MDS Verification'
		,'Y'
		,1
		,''
	FROM facility f WITH (NOLOCK)
	LEFT JOIN as_submission_accounts_mds_30 mdsverification WITH (NOLOCK) ON mdsverification.fac_id = f.fac_id
		AND mdsverification.account_type = 'V'
	WHERE f.deleted = 'N'
		AND f.fac_id = @SOURCE_FAC_ID
		AND mdsverification.STATUS = 1

	INSERT INTO #results
	SELECT DISTINCT ''
		,'ROX Reports'
		,'Y'
		,1
		,''
	FROM facility f WITH (NOLOCK)
	LEFT JOIN configuration_parameter rox_enabled WITH (NOLOCK) ON rox_enabled.fac_id = f.fac_id
		AND rox_enabled.[name] = 'enable_rox_reports'
	LEFT JOIN configuration_parameter rox_vendor_code WITH (NOLOCK) ON rox_vendor_code.fac_id = f.fac_id
		AND rox_vendor_code.[name] = 'rox_vendor_code'
	LEFT JOIN configuration_parameter rox_interested_party WITH (NOLOCK) ON rox_interested_party.fac_id = f.fac_id
		AND rox_interested_party.[name] = 'rox_interested_party'
	LEFT JOIN configuration_parameter rox_organization WITH (NOLOCK) ON rox_organization.fac_id = f.fac_id
		AND rox_organization.[name] = 'rox_organization'
	LEFT JOIN configuration_parameter rox_url WITH (NOLOCK) ON rox_url.fac_id = f.fac_id
		AND rox_url.[name] = 'rox_url'
	LEFT JOIN configuration_parameter rox_username WITH (NOLOCK) ON rox_username.fac_id = f.fac_id
		AND rox_username.[name] = 'rox_username'
	LEFT JOIN configuration_parameter rox_password WITH (NOLOCK) ON rox_password.fac_id = f.fac_id
		AND rox_password.[name] = 'rox_password'
	WHERE f.deleted = 'N'
		AND f.fac_id = @SOURCE_FAC_ID
		AND ISNULL(rox_enabled.[value], 'N') = 'Y'

	INSERT INTO #results
	SELECT DISTINCT ''
		,'IRM-ecin'
		,'Y'
		,1
		,''
	FROM facility f WITH (NOLOCK)
	LEFT JOIN crm_configuration config WITH (NOLOCK) ON config.fac_id = f.fac_id
	LEFT JOIN crm_integration_option ecin WITH (NOLOCK) ON ecin.[name] = 'ecin'
		AND ecin.enabled = 'Y'
	LEFT JOIN crm_integration_option sims WITH (NOLOCK) ON sims.[name] = 'sims'
		AND sims.enabled = 'Y'
	LEFT JOIN crm_integration_option curaspan WITH (NOLOCK) ON curaspan.[name] = 'curaspan'
		AND curaspan.enabled = 'Y'
	LEFT JOIN (
		SELECT intake_process_flag
		FROM crm_configuration WITH (NOLOCK)
		WHERE fac_id = 9001
		) intake ON 1 = 1
	WHERE f.deleted = 'N'
		AND f.fac_id = @SOURCE_FAC_ID
		AND ecin.enabled = 'Y'

	INSERT INTO #results
	SELECT DISTINCT ''
		,'IRM-sims'
		,'Y'
		,1
		,''
	FROM facility f WITH (NOLOCK)
	LEFT JOIN crm_configuration config WITH (NOLOCK) ON config.fac_id = f.fac_id
	LEFT JOIN crm_integration_option ecin WITH (NOLOCK) ON ecin.[name] = 'ecin'
		AND ecin.enabled = 'Y'
	LEFT JOIN crm_integration_option sims WITH (NOLOCK) ON sims.[name] = 'sims'
		AND sims.enabled = 'Y'
	LEFT JOIN crm_integration_option curaspan WITH (NOLOCK) ON curaspan.[name] = 'curaspan'
		AND curaspan.enabled = 'Y'
	LEFT JOIN (
		SELECT intake_process_flag
		FROM crm_configuration WITH (NOLOCK)
		WHERE fac_id = 9001
		) intake ON 1 = 1
	WHERE f.deleted = 'N'
		AND f.fac_id = @SOURCE_FAC_ID
		AND sims.enabled = 'Y'

	--Insert into #results
	--Select @FAC_NAME,'','',NULL
	INSERT INTO #results
	SELECT @FAC_NAME
		,'RRDB'
		,'<rrdb>'
		,'0'
		,''

	INSERT INTO #results
	SELECT @FAC_NAME
		,'INGRAPH USERS'
		,'<intgraph_users>'
		,'0'
		,''

	INSERT INTO #results
	SELECT @FAC_NAME
		,'DBType'
		,'<db_type>'
		,'0'
		,''

	INSERT INTO #results
	SELECT @FAC_NAME
		,'Environment'
		,'<db_env>'
		,'0'
		,''

	--Insert into #results
	--Select @FAC_NAME,'Faclity Name','<fac_name>','0'
	INSERT INTO #results
	SELECT @FAC_NAME
		,'History db'
		,NAME
		,'1'
		,''
	FROM sys.databases
	WHERE NAME LIKE '%' + db_name() + '%history%'

	--added 28/04/2017
	BEGIN
		--SELECT  top 1 @COUNT = 1 from [udb2522\ds3].ds_tasks.[dbo].[MDS3_Extract_323903_Parameter] where process_name = 'dailyMDS3Extract_Providigm' and enabled = 'Y'
		--and Org_Code = replace(REPLACE(db_name(),'us_',''),'_multi','')
		--and (fac_ids like '%,' + CONVERT(varchar,@SOURCE_FAC_ID) + ',%' or fac_ids like CONVERT(varchar,@SOURCE_FAC_ID) + ',%' or  fac_ids like '%,' + CONVERT(varchar,@SOURCE_FAC_ID) or  fac_ids = @SOURCE_FAC_ID )
		-- Modified on 2017-07-17
		SELECT TOP 1 @COUNT = 1
		FROM [udb2522\ds3].ds_tasks.[dbo].[MDS3_Extract_323903_Parameter]
		WHERE process_name = 'dailyMDS3Extract_Providigm'
			AND enabled = 'Y'
			AND Org_Code = replace(REPLACE(db_name(), 'us_', ''), '_multi', '')
			AND (
				fac_ids LIKE '%,' + CONVERT(VARCHAR, @SOURCE_FAC_ID) + ',%'
				OR fac_ids LIKE CONVERT(VARCHAR, @SOURCE_FAC_ID) + ',%'
				OR fac_ids LIKE '%,' + CONVERT(VARCHAR, @SOURCE_FAC_ID)
				OR fac_ids = CONVERT(VARCHAR, @SOURCE_FAC_ID)
				OR ISNULL(fac_ids, 'null') = 'null'
				)

		IF @COUNT > 0
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'Providigm MDS3 Extract'
				,'Y'
				,@COUNT
				,''
				)
		ELSE
			INSERT INTO #RESULTS
			VALUES (
				@FAC_NAME
				,'Providigm MDS3 Extract'
				,'N'
				,0
				,''
				)
	END

	--end added 28/04/2017
	--Added by Cynthia Cui on 2017-12-22, Reason: Smartsheet - Add vendor extracts to 'Facility Utilization' in DSHelper - Row 87, start
	BEGIN
		--new temp table 
		IF (Object_ID('TempDB..#TEMP_RESULTS') IS NOT NULL)
			DROP TABLE #TEMP_RESULTS

		CREATE TABLE #TEMP_RESULTS (
			FACILITY_NAME VARCHAR(75)
			,APPLICATION_FUNCTION VARCHAR(100)
			,ENABLED VARCHAR(100)
			,TABLE_COUNT INT
			,ADDITIONAL_INFORMATION VARCHAR(MAX)
			)

		--Align Extract
		IF replace(REPLACE(db_name(), 'us_', ''), '_multi', '') = 'NYE'
		BEGIN
			SELECT @count = count(*)
			FROM [pcc_temp_storage].[dbo].[Align_897044_NYE_Parameter]
			WHERE (
					fac_ids LIKE '%,' + CONVERT(VARCHAR, @SOURCE_FAC_ID) + ',%'
					OR fac_ids LIKE CONVERT(VARCHAR, @SOURCE_FAC_ID) + ',%'
					OR fac_ids LIKE '%,' + CONVERT(VARCHAR, @SOURCE_FAC_ID)
					OR fac_ids = CONVERT(VARCHAR, @SOURCE_FAC_ID)
					OR fac_ids IS NULL
					OR fac_ids = 'null'
					)
		END
		ELSE
		BEGIN
			SELECT @count = count(*)
			FROM [udb2522\ds3].[ds_tasks].[dbo].[Align_Job_Parameters]
			WHERE deleted = 'N'
				AND Org_Code = replace(REPLACE(db_name(), 'us_', ''), '_multi', '')
				AND (
					fac_ids LIKE '%,' + CONVERT(VARCHAR, @SOURCE_FAC_ID) + ',%'
					OR fac_ids LIKE CONVERT(VARCHAR, @SOURCE_FAC_ID) + ',%'
					OR fac_ids LIKE '%,' + CONVERT(VARCHAR, @SOURCE_FAC_ID)
					OR fac_ids = CONVERT(VARCHAR, @SOURCE_FAC_ID)
					OR fac_ids IS NULL
					OR fac_ids = 'null'
					)
		END

		IF @COUNT > 0
			INSERT INTO #TEMP_RESULTS
			VALUES (
				@FAC_NAME
				,'Custom Extract Vendor'
				,'Y'
				,0
				,'Align'
				)

		--First Quality Extract
		SELECT @count = count(*)
		FROM [udb2522\ds3].[ds_tasks].[dbo].[First_Quality_Job_Parameters_New_Format]
		WHERE deleted = 'N'
			AND Org_Code = replace(REPLACE(db_name(), 'us_', ''), '_multi', '')
			AND (
				fac_ids LIKE '%,' + CONVERT(VARCHAR, @SOURCE_FAC_ID) + ',%'
				OR fac_ids LIKE CONVERT(VARCHAR, @SOURCE_FAC_ID) + ',%'
				OR fac_ids LIKE '%,' + CONVERT(VARCHAR, @SOURCE_FAC_ID)
				OR fac_ids = CONVERT(VARCHAR, @SOURCE_FAC_ID)
				OR fac_ids IS NULL
				OR fac_ids = 'null'
				)

		IF @COUNT > 0
			INSERT INTO #TEMP_RESULTS
			VALUES (
				@FAC_NAME
				,'Custom Extract Vendor'
				,'Y'
				,0
				,'First Quality'
				)

		--Abaqis Extract
		SELECT @count = count(*)
		FROM [udb2522\ds3].[ds_tasks].[dbo].[MDS3_Extract_323903_Parameter]
		WHERE Process_Name = 'dailyMDS3Extract_Providigm'
			AND Enabled = 'Y'
			AND Org_Code = replace(REPLACE(db_name(), 'us_', ''), '_multi', '')
			--and org_code='rim'
			AND (
				fac_ids LIKE '%,' + CONVERT(VARCHAR, @SOURCE_FAC_ID) + ',%'
				OR fac_ids LIKE CONVERT(VARCHAR, @SOURCE_FAC_ID) + ',%'
				OR fac_ids LIKE '%,' + CONVERT(VARCHAR, @SOURCE_FAC_ID)
				OR fac_ids = CONVERT(VARCHAR, @SOURCE_FAC_ID)
				OR fac_ids IS NULL
				OR fac_ids = 'null'
				)

		IF @COUNT > 0
			INSERT INTO #TEMP_RESULTS
			VALUES (
				@FAC_NAME
				,'Custom Extract Vendor'
				,'Y'
				,0
				,'Abaqis'
				)

		--Mediant Extract
		SELECT @count = count(*)
		FROM [udb2522\ds3].[ds_tasks].[dbo].[Mediant_Health_434211_Jobs_Parameters]
		WHERE Enabled = 'Y'
			AND Org_Code = replace(REPLACE(db_name(), 'us_', ''), '_multi', '')
			--and org_code='sthc'
			AND (
				fac_ids LIKE '%,' + CONVERT(VARCHAR, @SOURCE_FAC_ID) + ',%'
				OR fac_ids LIKE CONVERT(VARCHAR, @SOURCE_FAC_ID) + ',%'
				OR fac_ids LIKE '%,' + CONVERT(VARCHAR, @SOURCE_FAC_ID)
				OR fac_ids = CONVERT(VARCHAR, @SOURCE_FAC_ID)
				OR fac_ids IS NULL
				OR fac_ids = 'null'
				)

		IF @COUNT > 0
			INSERT INTO #TEMP_RESULTS
			VALUES (
				@FAC_NAME
				,'Custom Extract Vendor'
				,'Y'
				,0
				,'Mediant'
				)

		--Omnicare EXTRACT
		SELECT @count = count(*)
		FROM [udb2522\ds3].[ds_tasks].[dbo].[Omniview_Parameters] WITH (NOLOCK)
		WHERE deleted = 'N'
			AND Org_Code = replace(REPLACE(db_name(), 'us_', ''), '_multi', '')
			--and org_code='abhow'
			AND (
				fac_ids LIKE '%,' + CONVERT(VARCHAR, @SOURCE_FAC_ID) + ',%'
				OR fac_ids LIKE CONVERT(VARCHAR, @SOURCE_FAC_ID) + ',%'
				OR fac_ids LIKE '%,' + CONVERT(VARCHAR, @SOURCE_FAC_ID)
				OR fac_ids = CONVERT(VARCHAR, @SOURCE_FAC_ID)
				OR fac_ids IS NULL
				OR fac_ids = 'null'
				)

		IF @COUNT > 0
			INSERT INTO #TEMP_RESULTS
			VALUES (
				@FAC_NAME
				,'Custom Extract Vendor'
				,'Y'
				,0
				,'Omnicare'
				)

		--Onshift EXTRACT
		IF replace(REPLACE(db_name(), 'us_', ''), '_multi', '') = 'SNRZ'
		BEGIN
			SELECT @count = count(*)
			FROM [pcc_temp_storage].[dbo].[SNRZ_903271_OnShift_Parameter]
			WHERE (
					fac_ids LIKE '%,' + CONVERT(VARCHAR, @SOURCE_FAC_ID) + ',%'
					OR fac_ids LIKE CONVERT(VARCHAR, @SOURCE_FAC_ID) + ',%'
					OR fac_ids LIKE '%,' + CONVERT(VARCHAR, @SOURCE_FAC_ID)
					OR fac_ids = CONVERT(VARCHAR, @SOURCE_FAC_ID)
					OR fac_ids IS NULL
					OR fac_ids = 'null'
					)
		END
		ELSE
		BEGIN
			SELECT @count = count(*)
			FROM [udb2522\ds3].[ds_tasks].[dbo].[OnShift_415437_Parameter]
			WHERE Enabled = 'Y'
				AND Org_Code = replace(REPLACE(db_name(), 'us_', ''), '_multi', '')
				--and org_code='spes'
				AND (
					fac_id LIKE '%,' + CONVERT(VARCHAR, @SOURCE_FAC_ID) + ',%'
					OR fac_id LIKE CONVERT(VARCHAR, @SOURCE_FAC_ID) + ',%'
					OR fac_id LIKE '%,' + CONVERT(VARCHAR, @SOURCE_FAC_ID)
					OR fac_id = CONVERT(VARCHAR, @SOURCE_FAC_ID)
					OR fac_id IS NULL
					OR fac_id = 'null'
					)
		END

		IF @COUNT > 0
			INSERT INTO #TEMP_RESULTS
			VALUES (
				@FAC_NAME
				,'Custom Extract Vendor'
				,'Y'
				,0
				,'Onshift'
				)

		--Paragon EXTRACT
		SELECT @count = count(*)
		FROM [udb2522\ds3].[ds_tasks].[dbo].[Paragon_Healthcare_653856_Parameters]
		WHERE Enabled = 'Y'
			AND Org_Code = replace(REPLACE(db_name(), 'us_', ''), '_multi', '')
			--and org_code='phcmm'
			AND (
				fac_ids LIKE '%,' + CONVERT(VARCHAR, @SOURCE_FAC_ID) + ',%'
				OR fac_ids LIKE CONVERT(VARCHAR, @SOURCE_FAC_ID) + ',%'
				OR fac_ids LIKE '%,' + CONVERT(VARCHAR, @SOURCE_FAC_ID)
				OR fac_ids = CONVERT(VARCHAR, @SOURCE_FAC_ID)
				OR fac_ids IS NULL
				OR fac_ids = 'null'
				)

		IF @COUNT > 0
			INSERT INTO #TEMP_RESULTS
			VALUES (
				@FAC_NAME
				,'Custom Extract Vendor'
				,'Y'
				,0
				,'Paragon'
				)

		--Pinnacle Quality Extract
		SELECT @count = count(*)
		FROM [udb2522\ds3].[ds_tasks].[dbo].[Pinnacle_Quality_Job_Parameters]
		WHERE deleted = 'N'
			AND Org_Code = replace(REPLACE(db_name(), 'us_', ''), '_multi', '')
			--and org_code='csc'
			AND (
				fac_ids LIKE '%,' + CONVERT(VARCHAR, @SOURCE_FAC_ID) + ',%'
				OR fac_ids LIKE CONVERT(VARCHAR, @SOURCE_FAC_ID) + ',%'
				OR fac_ids LIKE '%,' + CONVERT(VARCHAR, @SOURCE_FAC_ID)
				OR fac_ids = CONVERT(VARCHAR, @SOURCE_FAC_ID)
				OR fac_ids IS NULL
				OR fac_ids = 'null'
				)

		IF @COUNT > 0
			INSERT INTO #TEMP_RESULTS
			VALUES (
				@FAC_NAME
				,'Custom Extract Vendor'
				,'Y'
				,0
				,'Pinnacle Quality'
				)

		--Smartlinx
		IF replace(REPLACE(db_name(), 'us_', ''), '_multi', '') = 'COVC'
		BEGIN
			SELECT @COUNT = count(*)
			FROM [udb2522\ds3].[ds_tasks].[dbo].[SmartLinx_Shift_COVC]
			WHERE deleted = 'N'
				--and Org_Code = replace(REPLACE(db_name(),'us_',''),'_multi','')
				--and sp.org_code='bhcf'
				AND (
					fac_id = @SOURCE_FAC_ID
					OR fac_id IS NULL
					)
		END
		ELSE
		BEGIN
			SELECT @count = count(*)
			FROM [udb2522\ds3].[ds_tasks].[dbo].[SmartLinx_Schedule_Parameter] AS sp
			INNER JOIN [udb2522\ds3].[ds_tasks].[dbo].[SmartLinx_Shift] AS ss ON sp.Org_code = ss.org_code
			WHERE ss.Deleted = 'n'
				AND sp.Org_Code = replace(REPLACE(db_name(), 'us_', ''), '_multi', '')
				--and sp.org_code='bhcf'
				AND (
					ss.fac_id = @SOURCE_FAC_ID
					OR ss.fac_id IS NULL
					)
		END

		IF @COUNT > 0
			INSERT INTO #TEMP_RESULTS
			VALUES (
				@FAC_NAME
				,'Custom Extract Vendor'
				,'Y'
				,0
				,'Smartlinx'
				)

		--StaffScheduleCare
		SELECT @count = count(*)
		FROM [udb2522\ds3].[ds_tasks].[dbo].[StaffScheduleCare_Shift]
		WHERE deleted = 'N'
			AND Org_Code = replace(REPLACE(db_name(), 'us_', ''), '_multi', '')
			--and org_code='chsi'
			AND (
				fac_id = @SOURCE_FAC_ID
				OR fac_id IS NULL
				)

		IF @COUNT > 0
			INSERT INTO #TEMP_RESULTS
			VALUES (
				@FAC_NAME
				,'Custom Extract Vendor'
				,'Y'
				,0
				,'StaffScheduleCare'
				)

		--Added by Linlin Jing, Date: 2018-04-04, Reason: SmartSheet - DShelper&OtherDevelopment - Row140, start
		BEGIN
			SELECT @COUNT = count(1)
			FROM evt_event
			WHERE FAC_ID = @SOURCE_FAC_ID
				AND deleted = 'N'
				AND client_id IN (
					SELECT client_id
					FROM clients WITH (NOLOCK)
					WHERE fac_id = @SOURCE_FAC_ID
						AND deleted = 'N'
						AND isnull(discharge_date, @DATE) >= @DATE
						AND admission_date IS NOT NULL
					)

			IF @COUNT > 0
				INSERT INTO #RESULTS
				VALUES (
					@FAC_NAME
					,'Resident Event Calendar'
					,'Y'
					,@COUNT
					,''
					)
			ELSE
				INSERT INTO #RESULTS
				VALUES (
					@FAC_NAME
					,'Resident Event Calendar'
					,'N'
					,0
					,''
					)
		END

		BEGIN
			SELECT @COUNT = count(1)
			FROM dbo.configuration_parameter
			WHERE NAME = 'enable_einteract_tranform_form'
				AND value = 'Y'
				AND FAC_ID = @SOURCE_FAC_ID

			IF @COUNT > 0
				INSERT INTO #RESULTS
				VALUES (
					@FAC_NAME
					,'EInteract'
					,'Y'
					,1
					,''
					)
			ELSE
				INSERT INTO #RESULTS
				VALUES (
					@FAC_NAME
					,'EInteract'
					,'N'
					,0
					,''
					)
		END

		---Added by Linlin Jing, Date:2018-06-20,Smartsheet DShelper&OtherDevelopment #154, start
		INSERT INTO #RESULTS
		SELECT @FAC_NAME
			,'PreferredTPM'
			,''
			,1
			,PreferredTPM
		FROM [UDSM3\DS2016JOB].ds_merge_master.dbo.ClientStaffPreference
		WHERE OrgCode = replace(REPLACE(db_name(), 'us_', ''), '_multi', '')

		INSERT INTO #RESULTS
		SELECT @FAC_NAME
			,'PreferredClinical'
			,''
			,1
			,PreferredClinical
		FROM [UDSM3\DS2016JOB].ds_merge_master.dbo.ClientStaffPreference
		WHERE OrgCode = replace(REPLACE(db_name(), 'us_', ''), '_multi', '')

		INSERT INTO #RESULTS
		SELECT @FAC_NAME
			,'PreferredFinancial'
			,''
			,1
			,PreferredFinancial
		FROM [UDSM3\DS2016JOB].ds_merge_master.dbo.ClientStaffPreference
		WHERE OrgCode = replace(REPLACE(db_name(), 'us_', ''), '_multi', '')

		INSERT INTO #RESULTS
		SELECT @FAC_NAME
			,'PreferredOther'
			,''
			,1
			,PreferredOther
		FROM [UDSM3\DS2016JOB].ds_merge_master.dbo.ClientStaffPreference
		WHERE OrgCode = replace(REPLACE(db_name(), 'us_', ''), '_multi', '')

		INSERT INTO #RESULTS
		SELECT @FAC_NAME
			,'NonPreferredTPM'
			,''
			,1
			,NonPreferredTPM
		FROM [UDSM3\DS2016JOB].ds_merge_master.dbo.ClientStaffPreference
		WHERE OrgCode = replace(REPLACE(db_name(), 'us_', ''), '_multi', '')

		INSERT INTO #RESULTS
		SELECT @FAC_NAME
			,'NonPreferredClinical'
			,''
			,1
			,NonPreferredClinical
		FROM [UDSM3\DS2016JOB].ds_merge_master.dbo.ClientStaffPreference
		WHERE OrgCode = replace(REPLACE(db_name(), 'us_', ''), '_multi', '')

		INSERT INTO #RESULTS
		SELECT @FAC_NAME
			,'NonPreferredFinancial'
			,''
			,1
			,NonPreferredFinancial
		FROM [UDSM3\DS2016JOB].ds_merge_master.dbo.ClientStaffPreference
		WHERE OrgCode = replace(REPLACE(db_name(), 'us_', ''), '_multi', '')

		INSERT INTO #RESULTS
		SELECT @FAC_NAME
			,'NonPreferredOther'
			,''
			,1
			,NonPreferredOther
		FROM [UDSM3\DS2016JOB].ds_merge_master.dbo.ClientStaffPreference
		WHERE OrgCode = replace(REPLACE(db_name(), 'us_', ''), '_multi', '')

		INSERT INTO #RESULTS
		SELECT @FAC_NAME
			,'SpecialInstructions'
			,''
			,1
			,SpecialInstructions
		FROM [UDSM3\DS2016JOB].ds_merge_master.dbo.ClientStaffPreference
		WHERE OrgCode = replace(REPLACE(db_name(), 'us_', ''), '_multi', '')

		---Added by Linlin Jing, Date:2018-06-20,Smartsheet DShelper&OtherDevelopment #154, end
		BEGIN
			SELECT @COUNT = count(1)
			FROM dbo.configuration_parameter
			WHERE (
					value LIKE CONCAT (
						'%, '
						,(
							SELECT min(library_id)
							FROM cp_std_library
							WHERE description LIKE '%coms%'
							)
						,',%'
						)
					OR value LIKE CONCAT (
						(
							SELECT min(library_id)
							FROM cp_std_library
							WHERE description LIKE '%coms%'
							)
						,',%'
						)
					OR value LIKE CONCAT (
						'%, '
						,(
							SELECT min(library_id)
							FROM cp_std_library
							WHERE description LIKE '%coms%'
							)
						)
					)
				AND NAME = 'cp_selected_libraries'
				AND FAC_ID = @SOURCE_FAC_ID

			IF @COUNT > 0
				INSERT INTO #RESULTS
				VALUES (
					@FAC_NAME
					,'COMS'
					,'Y'
					,1
					,''
					)
			ELSE
				INSERT INTO #RESULTS
				VALUES (
					@FAC_NAME
					,'COMS'
					,'N'
					,0
					,''
					)
		END

		--Added by Linlin Jing, Date: 2018-04-04, Reason: SmartSheet - DShelper&OtherDevelopment - Row140, end
		--Added by: Jaspreet Singh, Date: 2019-03-29, Reason: SmartSheet - DShelper&OtherDevelopment - Task ID 0188, start
		BEGIN
			SELECT @COUNT = count(1)
			-- select *
			FROM dbo.configuration_parameter
			WHERE NAME = 'enable_eprescribe_workflow'
				AND value = 'Y'

			IF @COUNT > 0
				INSERT INTO #RESULTS
				VALUES (
					@FAC_NAME
					,'enable_eprescribe_workflow'
					,'Y'
					,1
					,''
					)
			ELSE
				INSERT INTO #RESULTS
				VALUES (
					@FAC_NAME
					,'enable_eprescribe_workflow'
					,'N'
					,0
					,''
					)
		END

		--Added by: Jaspreet Singh, Date: 2019-03-29, Reason: SmartSheet - DShelper&OtherDevelopment - Task ID 0188, end
		--prepare the final result
		INSERT INTO #RESULTS (
			FACILITY_NAME
			,APPLICATION_FUNCTION
			,ENABLED
			,TABLE_COUNT
			,ADDITIONAL_INFORMATION
			)
		SELECT T.FACILITY_NAME
			,T.APPLICATION_FUNCTION
			,T.ENABLED
			,T.TABLE_COUNT
			,left(T.ADDITIONAL_INFORMATION, len(T.ADDITIONAL_INFORMATION) - 1) AS ADDITIONAL_INFORMATION
		FROM (
			SELECT DISTINCT T2.FACILITY_NAME
				,T2.APPLICATION_FUNCTION
				,T2.ENABLED
				,T2.TABLE_COUNT
				,(
					SELECT T1.ADDITIONAL_INFORMATION + ', '
					FROM #TEMP_RESULTS AS T1
					WHERE T1.FACILITY_NAME = T2.FACILITY_NAME
					FOR XML PATH('')
					) AS ADDITIONAL_INFORMATION
			FROM #TEMP_RESULTS AS T2
			) AS T
	END

	--Added by Cynthia Cui on 2017-12-22, Reason: Smartsheet - Add vendor extracts to 'Facility Utilization' in DSHelper - Row 87, end
	SELECT APPLICATION_FUNCTION
		--,ENABLED
		--,TABLE_COUNT
		,CASE
			WHEN 
				ENABLED = 'Y' AND
				APPLICATION_FUNCTION IN ('as_enable_mds_extverify','enable_emar','enable_mar','enable_poc','enable_res_photos','mds_automated_submission','Document Manager','enable_crm','enable_COMS_Assessment(vendor_code)','Integration','Message Vendor Setup','Third Party MDS Data','Third Party MDS Verification','ROX Reports','Providigm MDS3 Extract','Resident Event Calendar','EInteract','COMS','Enable Eprescribe Workflow')
					THEN 'Y'
			WHEN 
				ENABLED = 'N' AND 
				APPLICATION_FUNCTION IN ('as_enable_mds_extverify','enable_emar','enable_mar','enable_poc','enable_res_photos','mds_automated_submission','Document Manager','enable_crm','enable_COMS_Assessment(vendor_code)','Integration','Message Vendor Setup','Third Party MDS Data','Third Party MDS Verification','ROX Reports','Providigm MDS3 Extract','Resident Event Calendar','EInteract','COMS','Enable Eprescribe Workflow')
					THEN 'N'
			WHEN 
				ENABLED NOT IN ('Y','N') AND 
				APPLICATION_FUNCTION IN ('State Code') 
					THEN ENABLED
			WHEN 
				ENABLED = 'Y' AND
				APPLICATION_FUNCTION IN ('ResidentCount','Online Documentation','BILLING','CENSUS','COLLECTIONS','TRUST','RISK MANAGEMENT','MDS 2.0','MDS 3.0','MMQ-Massachusetts','MMA-Maryland','CUSTOM UDA''s','System  UDA''s','SKIN and WOUND','WEIGHTS AND VITALS','DIAGNOSIS','ALERTS','IMMUNIZATION','PHYSICIAN ORDERS','PROGRESS NOTES','CARE PLANS','QIA','GENERAL LEDGER','ACCOUNTS PAYABLE','MARKETING/IRM','POC MODULE','USER_DEFINED_DATA','LAB RESULT','Radiology RESULT','NOTES','Care Pathway') AND
				ISNUMERIC(TABLE_COUNT) = 1
					THEN REPLACE(CONVERT(varchar, CAST(TABLE_COUNT AS money), 1),'.00','')
			WHEN 
				ENABLED = 'N' AND 
				APPLICATION_FUNCTION IN ('ResidentCount','Online Documentation','BILLING','CENSUS','COLLECTIONS','TRUST','RISK MANAGEMENT','MDS 2.0','MDS 3.0','MMQ-Massachusetts','MMA-Maryland','CUSTOM UDA''s','System  UDA''s','SKIN and WOUND','WEIGHTS AND VITALS','DIAGNOSIS','ALERTS','IMMUNIZATION','PHYSICIAN ORDERS','PROGRESS NOTES','CARE PLANS','QIA','GENERAL LEDGER','ACCOUNTS PAYABLE','MARKETING/IRM','POC MODULE','USER_DEFINED_DATA','LAB RESULT','Radiology RESULT','NOTES','Care Pathway')
					THEN 'N/A'
			ELSE ENABLED
		END AS TABLE_COUNT
		--,ADDITIONAL_INFORMATION
	FROM #RESULTS
	--WHERE table_count > 0
	--	OR APPLICATION_FUNCTION IN (
	--		'RRDB'
	--		,'Ingraph Users'
	--		,'DBType'
	--		,'Environment'
	--		,'Custom Extract Vendor' --added by Cynthia Cui on 2017-12-22, Reason: Smartsheet - Add vendor extracts to 'Facility Utilization' in DSHelper - Row 87
	--		,'Enable Eprescribe Workflow' -- Added by Jaspreet Singh, Date: 2019-04-04, Reason: Smartsheet - DShelper&OtherDevelopment -  Task# 0188
	--		)
END
