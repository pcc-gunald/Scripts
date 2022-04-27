

Select * from MergeLog order by msgTime

begin tran 
INSERT INTO pcc_staging_db010798.[dbo].common_code_audit (
	item_id
	,deleted
	,revision_by
	,item_description
	,effective_date
	,ineffective_date
	,action_type
	,DELETED_BY
	,MULTI_FAC_ID
	)
SELECT DISTINCT ISNULL(EICase010798121.dst_id, item_id)
	,[deleted]
	,'EICase01079812'
	,[item_description]
	,[effective_date]
	,isnull(ineffective_date, getdate())
	,[action_type]
	,[DELETED_BY]
	,12
FROM test_usei984.[dbo].common_code_audit a
JOIN pcc_staging_db010798.[dbo].EICase01079812common_code EICase010798121 ON EICase010798121.src_id = a.item_id
WHERE NOT EXISTS (
		SELECT 1
		FROM [pccsql-use2-prod-w20-cli0017.3055e0bc69f6.database.windows.net].us_vvhr.[dbo].common_code_audit origt
		WHERE (
				origt.ineffective_date = a.ineffective_date
				AND origt.effective_date = a.effective_date
				)
			OR origt.effective_date = a.effective_date
			AND origt.item_id = EICase010798121.dst_id
		)
	AND NOT EXISTS (
		SELECT 1
		FROM pcc_staging_db010798.[dbo].common_code_audit origt1
		WHERE (
				origt1.ineffective_date = a.ineffective_date
				AND origt1.effective_date = a.effective_date
				)
			OR origt1.effective_date = a.effective_date
			AND origt1.item_id = EICase010798121.dst_id
		)
		--and EICase010798121.dst_id!=10843

		rollback tran
mergeExecuteExtractStep4 --> MergeError : Violation of PRIMARY KEY constraint 'common_code_audit__itemId_effectiveDate_PK_CL_IX'. Cannot insert duplicate key in object 'dbo.common_code_audit'. The duplicate key value is (10843, Feb 28 2022  5:34AM).

Msg 2627, Level 14, State 1, Line 6
Violation of PRIMARY KEY constraint 'common_code_audit__itemId_effectiveDate_PK_CL_IX'. Cannot insert duplicate key in object 'dbo.common_code_audit'. The duplicate key value is (10843, Feb 28 2022  5:34AM).
The statement has been terminated.

Completion time: 2022-04-12T09:05:00.3367278-04:00


Select * from EICase01079812common_code where dst_id =10843

Select * from test_usei984.[dbo].common_code where item_id in (10843,10867,10868,10869)

INSERT INTO pcc_staging_db010798.[dbo].EICase01079812common_code (src_id)
SELECT item_id
FROM test_usei984.[dbo].common_code
WHERE item_id <> - 1
	AND (
		fac_id = 7
		OR fac_id = - 1
		OR reg_id = 1
		)
	AND item_id IN (
		(
			SELECT isnull(diag_lib_id, - 1)
			FROM test_usei984.[dbo].diagnosis_codes
			WHERE fac_id IN (
					7
					,- 1
					)
				AND DELETED = 'N'
			)
		
		UNION
		
		(
			SELECT isnull(diag_classification_id, - 1)
			FROM test_usei984.[dbo].diagnosis
			WHERE fac_id IN (
					7
					,- 1
					)
				AND DELETED = 'N'
			)
		
		UNION
		
		(
			SELECT isnull(rank_id, - 1)
			FROM test_usei984.[dbo].diagnosis
			WHERE fac_id IN (
					7
					,- 1
					)
				AND DELETED = 'N'
			)
		
		UNION
		
		(
			SELECT isnull(strikeout_reason_id, - 1)
			FROM test_usei984.[dbo].diagnosis_strikeout
			)
		)
	AND deleted = 'N'
	--AND item_id NOT IN (
	--	SELECT src_id
	--	FROM pcc_staging_db010798.[dbo].EICase01079812common_code
	--	)
ORDER BY item_id
