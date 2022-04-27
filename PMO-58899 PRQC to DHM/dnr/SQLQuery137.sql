select * INTO temp_EI_FKViolation from EI_FKViolation


SELECT * FROM EI_FKViolation

select * into temp_pho_phys_order_audit_useraudit from [pcc_staging_db58899].dbo.[pho_phys_order_audit_useraudit]
SELECT * into temp_pn_progress_note 	FROM [pcc_staging_db58899].dbo.[pn_progress_note]
SELECT * INTO temp_pn_std_spn_text FROM pn_std_spn_text

		DELETE [pcc_staging_db58899].dbo.[pho_phys_order_audit_useraudit] 
		WHERE [created_by_audit_id] IS NOT NULL
			AND [created_by_audit_id] NOT IN (
				SELECT [cp_sec_user_audit_id]
				FROM [pcc_staging_db58899].dbo.[cp_sec_user_audit] WITH (NOLOCK)
				WHERE [cp_sec_user_audit_id] IS NOT NULL
				
				UNION
				
				SELECT [cp_sec_user_audit_id]
				FROM test_usei1104.dbo.[cp_sec_user_audit] WITH (NOLOCK)
				WHERE [cp_sec_user_audit_id] IS NOT NULL
		)


	DELETE  [pcc_staging_db58899].dbo.[pn_progress_note] 
	WHERE [created_by_userid] IS NOT NULL
		AND [created_by_userid] NOT IN (
			SELECT [userid]
			FROM [pcc_staging_db58899].dbo.[sec_user] WITH (NOLOCK)
			WHERE [userid] IS NOT NULL
			
			UNION
			
			SELECT [userid]
			FROM test_usei1104.dbo.[sec_user] WITH (NOLOCK)
			WHERE [userid] IS NOT NULL
			)


	DELETE [pcc_staging_db58899].dbo.[pn_std_spn_text] 
	WHERE [section_id] IS NOT NULL
		AND [section_id] NOT IN (
			SELECT [section_id]
			FROM [pcc_staging_db58899].dbo.[pn_template_section] WITH (NOLOCK)
			WHERE [section_id] IS NOT NULL
			
			UNION
			
			SELECT [section_id]
			FROM test_usei1104.dbo.[pn_template_section] WITH (NOLOCK)
			WHERE [section_id] IS NOT NULL
			)


DROP TABLE EI_FKViolation