
	Select * from EI_FKViolation

	1	IF EXISTS     (     SELECT [diagnosis_id]      FROM [pcc_staging_db010798].dbo.[diagnosis] with (nolock)      WHERE [diagnosis_id] IS NOT NULL       AND [diagnosis_id] NOT IN       (       SELECT [diagnosis_id]        FROM [pcc_staging_db010798].dbo.[diagnosis_codes] with (nolock)        WHERE [diagnosis_id] IS NOT NULL       UNION        SELECT [diagnosis_id]        FROM test_usei23.dbo.[diagnosis_codes]with (nolock)        WHERE [diagnosis_id] IS NOT NULL      )    )    SELECT [diagnosis_id]     FROM [pcc_staging_db010798].dbo.[diagnosis] with (nolock)     WHERE [diagnosis_id] IS NOT NULL      AND [diagnosis_id] NOT IN      (      SELECT [diagnosis_id]       FROM [pcc_staging_db010798].dbo.[diagnosis_codes] with (nolock)       WHERE [diagnosis_id] IS NOT NULL      UNION       SELECT [diagnosis_id]       FROM test_usei23.dbo.[diagnosis_codes]with (nolock)       WHERE [diagnosis_id] IS NOT NULL     )	2021-12-01 10:46:56.570

	2	IF EXISTS     (     SELECT [cp_sec_user_audit_id]      FROM [pcc_staging_db010798].dbo.[pho_order_related_value] with (nolock)      WHERE [cp_sec_user_audit_id] IS NOT NULL       AND [cp_sec_user_audit_id] NOT IN       (       SELECT [cp_sec_user_audit_id]        FROM [pcc_staging_db010798].dbo.[cp_sec_user_audit] with (nolock)        WHERE [cp_sec_user_audit_id] IS NOT NULL       UNION        SELECT [cp_sec_user_audit_id]        FROM test_usei23.dbo.[cp_sec_user_audit]with (nolock)        WHERE [cp_sec_user_audit_id] IS NOT NULL      )    )    SELECT [cp_sec_user_audit_id]     FROM [pcc_staging_db010798].dbo.[pho_order_related_value] with (nolock)     WHERE [cp_sec_user_audit_id] IS NOT NULL      AND [cp_sec_user_audit_id] NOT IN      (      SELECT [cp_sec_user_audit_id]       FROM [pcc_staging_db010798].dbo.[cp_sec_user_audit] with (nolock)       WHERE [cp_sec_user_audit_id] IS NOT NULL      UNION       SELECT [cp_sec_user_audit_id]       FROM test_usei23.dbo.[cp_sec_user_audit]with (nolock)       WHERE [cp_sec_user_audit_id] IS NOT NULL     )	2021-12-01 11:11:50.787

	3	IF EXISTS     (     SELECT [shift_id]      FROM [pcc_staging_db010798].dbo.[pho_std_time_details] with (nolock)      WHERE [shift_id] IS NOT NULL       AND [shift_id] NOT IN       (       SELECT [std_shift_id]        FROM [pcc_staging_db010798].dbo.[cp_std_shift] with (nolock)        WHERE [std_shift_id] IS NOT NULL       UNION        SELECT [std_shift_id]        FROM test_usei23.dbo.[cp_std_shift]with (nolock)        WHERE [std_shift_id] IS NOT NULL      )    )    SELECT [shift_id]     FROM [pcc_staging_db010798].dbo.[pho_std_time_details] with (nolock)     WHERE [shift_id] IS NOT NULL      AND [shift_id] NOT IN      (      SELECT [std_shift_id]       FROM [pcc_staging_db010798].dbo.[cp_std_shift] with (nolock)       WHERE [std_shift_id] IS NOT NULL      UNION       SELECT [std_shift_id]       FROM test_usei23.dbo.[cp_std_shift]with (nolock)       WHERE [std_shift_id] IS NOT NULL     )	2021-12-01 11:40:47.407
	IF EXISTS (
		SELECT [diagnosis_id]
		FROM [pcc_staging_db010798].dbo.[diagnosis] WITH (NOLOCK)
		WHERE [diagnosis_id] IS NOT NULL
			AND [diagnosis_id] NOT IN (
				SELECT [diagnosis_id]
				FROM [pcc_staging_db010798].dbo.[diagnosis_codes] WITH (NOLOCK)
				WHERE [diagnosis_id] IS NOT NULL
				
				UNION
				
				SELECT [diagnosis_id]
				FROM test_usei23.dbo.[diagnosis_codes] WITH (NOLOCK)
				WHERE [diagnosis_id] IS NOT NULL
				)
		)
	SELECT [diagnosis_id]
	FROM [pcc_staging_db010798].dbo.[diagnosis] WITH (NOLOCK)
	WHERE [diagnosis_id] IS NOT NULL
		AND [diagnosis_id] NOT IN (
			SELECT [diagnosis_id]
			FROM [pcc_staging_db010798].dbo.[diagnosis_codes] WITH (NOLOCK)
			WHERE [diagnosis_id] IS NOT NULL
			
			UNION
			
			SELECT [diagnosis_id]
			FROM test_usei23.dbo.[diagnosis_codes] WITH (NOLOCK)
			WHERE [diagnosis_id] IS NOT NULL
			)


			diagnosis_id
17575
17584
17585
17584
17584
17584
1754
1754
17585
IF EXISTS (
		SELECT [cp_sec_user_audit_id]
		FROM [pcc_staging_db010798].dbo.[pho_order_related_value] WITH (NOLOCK)
		WHERE [cp_sec_user_audit_id] IS NOT NULL
			AND [cp_sec_user_audit_id] NOT IN (
				SELECT [cp_sec_user_audit_id]
				FROM [pcc_staging_db010798].dbo.[cp_sec_user_audit] WITH (NOLOCK)
				WHERE [cp_sec_user_audit_id] IS NOT NULL
				
				UNION
				
				SELECT [cp_sec_user_audit_id]
				FROM test_usei23.dbo.[cp_sec_user_audit] WITH (NOLOCK)
				WHERE [cp_sec_user_audit_id] IS NOT NULL
				)
		)
	SELECT [cp_sec_user_audit_id]
	FROM [pcc_staging_db010798].dbo.[pho_order_related_value] WITH (NOLOCK)
	WHERE [cp_sec_user_audit_id] IS NOT NULL
		AND [cp_sec_user_audit_id] NOT IN (
			SELECT [cp_sec_user_audit_id]
			FROM [pcc_staging_db010798].dbo.[cp_sec_user_audit] WITH (NOLOCK)
			WHERE [cp_sec_user_audit_id] IS NOT NULL
			
			UNION
			
			SELECT [cp_sec_user_audit_id]
			FROM test_usei23.dbo.[cp_sec_user_audit] WITH (NOLOCK)
			WHERE [cp_sec_user_audit_id] IS NOT NULL
			)


			cp_sec_user_audit_id
496
496
496
496
496
496
496
IF EXISTS (
		SELECT [shift_id]
		FROM [pcc_staging_db010798].dbo.[pho_std_time_details] WITH (NOLOCK)
		WHERE [shift_id] IS NOT NULL
			AND [shift_id] NOT IN (
				SELECT [std_shift_id]
				FROM [pcc_staging_db010798].dbo.[cp_std_shift] WITH (NOLOCK)
				WHERE [std_shift_id] IS NOT NULL
				
				UNION
				
				SELECT [std_shift_id]
				FROM test_usei23.dbo.[cp_std_shift] WITH (NOLOCK)
				WHERE [std_shift_id] IS NOT NULL
				)
		)
	SELECT [shift_id]
	FROM [pcc_staging_db010798].dbo.[pho_std_time_details] WITH (NOLOCK)
	WHERE [shift_id] IS NOT NULL
		AND [shift_id] NOT IN (
			SELECT [std_shift_id]
			FROM [pcc_staging_db010798].dbo.[cp_std_shift] WITH (NOLOCK)
			WHERE [std_shift_id] IS NOT NULL
			
			UNION
			
			SELECT [std_shift_id]
			FROM test_usei23.dbo.[cp_std_shift] WITH (NOLOCK)
			WHERE [std_shift_id] IS NOT NULL
			)


			shift_id
75
1
54
54
75
1
54
75
1
54
75
1

SELECT distinct[shift_id],*
	FROM [pcc_staging_db010798].dbo.[pho_std_time_details] WITH (NOLOCK)
	WHERE [shift_id] IS NOT NULL
		AND [shift_id] NOT IN (
			SELECT [std_shift_id]
			FROM [pcc_staging_db010798].dbo.[cp_std_shift] 
				UNION
			
			SELECT [std_shift_id]
			FROM test_usei23.dbo.[cp_std_shift] WITH (NOLOCK)
			WHERE [std_shift_id] IS NOT NULL
			)

----			shift_id
----54
----75
----1

Select * from  [pcc_staging_db010798].dbo.[pho_std_time_details]


where shift_id in (54,75,1)
--pho_std_time_details_id	pho_std_time_id
--4404	2983
--4405	2983
--4406	2983
--4440	2983
--4441	2983
--4442	2983
--4440	2983
--4444	2983
--4445	2983
--4446	2983
--4447	2983
--4448	2983
--(12 rows affected)
update  [pcc_staging_db010798].dbo.[pho_std_time_details]
set shift_id=null

where shift_id in (54,75,1)
(12 rows affected)

SELECT [cp_sec_user_audit_id]
	FROM [pcc_staging_db010798].dbo.[pho_order_related_value] WITH (NOLOCK)
	WHERE [cp_sec_user_audit_id] IS NOT NULL
		AND [cp_sec_user_audit_id] NOT IN (
			SELECT [cp_sec_user_audit_id]
			FROM [pcc_staging_db010798].dbo.[cp_sec_user_audit] WITH (NOLOCK)
			WHERE [cp_sec_user_audit_id] IS NOT NULL
			
			UNION
			
			SELECT [cp_sec_user_audit_id]
			FROM test_usei23.dbo.[cp_sec_user_audit] WITH (NOLOCK)
			WHERE [cp_sec_user_audit_id] IS NOT NULL
			)

			SELECT *
			FROM [pcc_staging_db010798].dbo.[pho_order_related_value] WITH (NOLOCK)
			WHERE cp_sec_user_audit_id=496
--			value_id	prompt_id	schedule_detail_id
--2664711	21485	740594088
--2664712	21567	740592345
--2664713	21568	740592345
--2664714	21569	740592345
--2664740	21540	740594068
--2664716	21541	740594068
--2664717	21542	740594068


update  [pcc_staging_db010798].dbo.[pho_order_related_value] 
set[cp_sec_user_audit_id] =-999
 WHERE cp_sec_user_audit_id=496
 
(7 rows affected)

SELECT distinct [diagnosis_id]
	FROM [pcc_staging_db010798].dbo.[diagnosis] WITH (NOLOCK)
	WHERE [diagnosis_id] IS NOT NULL
		AND [diagnosis_id] NOT IN (
			SELECT [diagnosis_id]
			FROM [pcc_staging_db010798].dbo.[diagnosis_codes] WITH (NOLOCK)
			WHERE [diagnosis_id] IS NOT NULL
			
			UNION
			
			SELECT [diagnosis_id]
			FROM test_usei23.dbo.[diagnosis_codes] WITH (NOLOCK)
			WHERE [diagnosis_id] IS NOT NULL
			)

			client_diagnosis_id	diagnosis_id	fac_id	deleted
513288	17575	1	N
513957	17584	1	N
513940	17585	1	N
513820	17584	1	Y
513821	17584	1	N
513840	17584	1	Y
51342	1754	1	Y
514095	1754	1	Y
514565	17585	1	N
delete
	FROM [pcc_staging_db010798].dbo.[diagnosis]  
	WHERE [diagnosis_id] in (17585,1754,17575,17584)
	and client_diagnosis_id in (513288,513957,513940,513820,513821,513840,51342,514095,514565)
 
(9 rows affected)

Completion time: 2021-12-01T16:00:05.0507669-05:00
