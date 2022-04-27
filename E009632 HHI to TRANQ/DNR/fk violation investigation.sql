select * from EI_FKViolation

IF EXISTS (
		SELECT [cp_sec_user_audit_id]
		FROM [pcc_staging_db009632].dbo.[pho_order_related_value] WITH (NOLOCK)
		WHERE [cp_sec_user_audit_id] IS NOT NULL
			AND [cp_sec_user_audit_id] NOT IN (
				SELECT [cp_sec_user_audit_id]
				FROM [pcc_staging_db009632].dbo.[cp_sec_user_audit] WITH (NOLOCK)
				WHERE [cp_sec_user_audit_id] IS NOT NULL
				
				UNION
				
				SELECT [cp_sec_user_audit_id]
				FROM test_usei425.dbo.[cp_sec_user_audit] WITH (NOLOCK)
				WHERE [cp_sec_user_audit_id] IS NOT NULL
				)
		)
	SELECT [cp_sec_user_audit_id]
	FROM [pcc_staging_db009632].dbo.[pho_order_related_value] WITH (NOLOCK)
	WHERE [cp_sec_user_audit_id] IS NOT NULL
		AND [cp_sec_user_audit_id] NOT IN (
			SELECT [cp_sec_user_audit_id]
			FROM [pcc_staging_db009632].dbo.[cp_sec_user_audit] WITH (NOLOCK)
			WHERE [cp_sec_user_audit_id] IS NOT NULL
			
			UNION
			
			SELECT [cp_sec_user_audit_id]
			FROM test_usei425.dbo.[cp_sec_user_audit] WITH (NOLOCK)
			WHERE [cp_sec_user_audit_id] IS NOT NULL
			)

update a
set a.[cp_sec_user_audit_id] = (select dst_id from eicase00963220cp_sec_user_audit
where src_id = 12077)
--select *
from [pho_order_related_value] a
where [cp_sec_user_audit_id] = 12077

select dst_id from eicase00963220cp_sec_user_audit
where src_id = 12077

IF EXISTS (
		SELECT [created_by_userid]
		FROM [pcc_staging_db009632].dbo.[pn_progress_note] WITH (NOLOCK)
		WHERE [created_by_userid] IS NOT NULL
			AND [created_by_userid] NOT IN (
				SELECT [userid]
				FROM [pcc_staging_db009632].dbo.[sec_user] WITH (NOLOCK)
				WHERE [userid] IS NOT NULL
				
				UNION
				
				SELECT [userid]
				FROM test_usei425.dbo.[sec_user] WITH (NOLOCK)
				WHERE [userid] IS NOT NULL
				)
		)
	SELECT distinct [created_by_userid]
	FROM [pcc_staging_db009632].dbo.[pn_progress_note] WITH (NOLOCK)
	WHERE [created_by_userid] IS NOT NULL
		AND [created_by_userid] NOT IN (
			SELECT [userid]
			FROM [pcc_staging_db009632].dbo.[sec_user] WITH (NOLOCK)
			WHERE [userid] IS NOT NULL
			
			UNION
			
			SELECT [userid]
			FROM test_usei425.dbo.[sec_user] WITH (NOLOCK)
			WHERE [userid] IS NOT NULL
			)
update a
set a.created_by_userid = 132628
--select * 
from [pn_progress_note] a
where created_by_userid = 104818

update a
set a.created_by_userid = 132645
--select * 
from [pn_progress_note] a
where created_by_userid in(
112406,
130176)


select * from pcc_staging_db009632.dbo.sec_user
order by userid

select * from EICase00963221sec_user
where src_id in (104818,
112406,
130176)
