

select * from EI_FKViolation
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



			Select Multi_Fac_Id,cp_sec_user_audit_id, * 	FROM [pcc_staging_db010798].dbo.[pho_order_related_value] where  [cp_sec_user_audit_id]=16368
--Multi_Fac_Id	cp_sec_user_audit_id	value_id	prompt_id	schedule_detail_id	value
--220	16368	45540970	4070861	5784787697	5
--220	16368	45540971	4070854	5784787696	128
--220	16368	45540972	4070860	5784787698	i
	 

				update [pho_order_related_value]

			set [cp_sec_user_audit_id] =-999
			where cp_sec_user_audit_id=16368
			
--(3 rows affected)

			SELECT [cp_sec_user_audit_id]
			FROM test_usei23.dbo.[cp_sec_user_audit] where [cp_sec_user_audit_id]=-999


			IF EXISTS (
		SELECT [created_by_audit_id]
		FROM [pcc_staging_db010798].dbo.[pho_phys_order_audit_useraudit] WITH (NOLOCK)
		WHERE [created_by_audit_id] IS NOT NULL
			AND [created_by_audit_id] NOT IN (
				SELECT [cp_sec_user_audit_id]
				FROM [pcc_staging_db010798].dbo.[cp_sec_user_audit] WITH (NOLOCK)
				WHERE [cp_sec_user_audit_id] IS NOT NULL
				
				UNION
				
				SELECT [cp_sec_user_audit_id]
				FROM test_usei23.dbo.[cp_sec_user_audit] WITH (NOLOCK)
				WHERE [cp_sec_user_audit_id] IS NOT NULL
				)
		)
	SELECT [created_by_audit_id]
	FROM [pcc_staging_db010798].dbo.[pho_phys_order_audit_useraudit] WITH (NOLOCK)
	WHERE [created_by_audit_id] IS NOT NULL
		AND [created_by_audit_id] NOT IN (
			SELECT [cp_sec_user_audit_id]
			FROM [pcc_staging_db010798].dbo.[cp_sec_user_audit] WITH (NOLOCK)
			WHERE [cp_sec_user_audit_id] IS NOT NULL
			
			UNION
			
			SELECT [cp_sec_user_audit_id]
			FROM test_usei23.dbo.[cp_sec_user_audit] WITH (NOLOCK)
			WHERE [cp_sec_user_audit_id] IS NOT NULL
			)

			created_by_audit_id
6747
26234
26234


Select created_by_audit_id,[edited_by_audit_id],* from [pho_phys_order_audit_useraudit] where created_by_audit_id in(6747,26234,26234)
--created_by_audit_id	edited_by_audit_id	audit_id	edited_by_audit_id	edited_date	created_by_audit_id	confirmed_by_audit_id	confirmed_date	Multi_Fac_Id
--6747	6747	89307820	6747	2013-02-15 12:39:20.587	6747	NULL	NULL	216
--26234	26234	90261168	26234	2020-11-19 14:43:43.653	26234	NULL	NULL	217
--26234	26234	90261169	26234	2020-11-19 14:43:43.857	26234	NULL	NULL	217

update [pho_phys_order_audit_useraudit]

set created_by_audit_id=-999,
[edited_by_audit_id]=-999
where created_by_audit_id in(6747,26234,26234)

(3 rows affected)
IF EXISTS (
		SELECT [edited_by_audit_id]
		FROM [pcc_staging_db010798].dbo.[pho_phys_order_audit_useraudit] WITH (NOLOCK)
		WHERE [edited_by_audit_id] IS NOT NULL
			AND [edited_by_audit_id] NOT IN (
				SELECT [cp_sec_user_audit_id]
				FROM [pcc_staging_db010798].dbo.[cp_sec_user_audit] WITH (NOLOCK)
				WHERE [cp_sec_user_audit_id] IS NOT NULL
				
				UNION
				
				SELECT [cp_sec_user_audit_id]
				FROM test_usei23.dbo.[cp_sec_user_audit] WITH (NOLOCK)
				WHERE [cp_sec_user_audit_id] IS NOT NULL
				)
		)
	SELECT [edited_by_audit_id]
	FROM [pcc_staging_db010798].dbo.[pho_phys_order_audit_useraudit] WITH (NOLOCK)
	WHERE [edited_by_audit_id] IS NOT NULL
		AND [edited_by_audit_id] NOT IN (
			SELECT [cp_sec_user_audit_id]
			FROM [pcc_staging_db010798].dbo.[cp_sec_user_audit] WITH (NOLOCK)
			WHERE [cp_sec_user_audit_id] IS NOT NULL
			
			UNION
			
			SELECT [cp_sec_user_audit_id]
			FROM test_usei23.dbo.[cp_sec_user_audit] WITH (NOLOCK)
			WHERE [cp_sec_user_audit_id] IS NOT NULL
			)

 

Select * from stagingmergelog order by msgtime desc

msg
SET IDENTITY_INSERT test_usei23.dbo.prot_std_protocol_detail ON    
INSERT INTO test_usei23.dbo.prot_std_protocol_detail(detail_id,protocol_id,event_id,action_id,module_id,threshold,deleted,deleted_by,deleted_date) 
SELECT detail_id,protocol_id,event_id,action_id,module_id,threshold,deleted,deleted_by,deleted_date 
FROM pcc_staging_db010798.dbo.prot_std_protocol_detail SET IDENTITY_INSERT test_usei23.dbo.prot_std_protocol_detail OFF

ErrorMsg
Cannot insert duplicate key row in object 'dbo.prot_std_protocol_detail' with unique index 'prot_std_protocol_detail__protocolId_eventId_actionId_UIX'. The duplicate key value is (1, 1, 3).