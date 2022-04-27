

Select * from EI_FKViolation

IF EXISTS (
		SELECT distinct[cp_sec_user_audit_id]
		FROM [pcc_staging_db010798].dbo.[pho_order_related_value] WITH (NOLOCK)
		WHERE [cp_sec_user_audit_id] IS NOT NULL
			AND [cp_sec_user_audit_id] NOT IN (
				SELECT [cp_sec_user_audit_id]
				FROM [pcc_staging_db010798].dbo.[cp_sec_user_audit] WITH (NOLOCK)
				WHERE [cp_sec_user_audit_id] IS NOT NULL
				
				UNION
				
				SELECT [cp_sec_user_audit_id]
				FROM test_usei9.dbo.[cp_sec_user_audit] WITH (NOLOCK)
				WHERE [cp_sec_user_audit_id] IS NOT NULL
				)
		)
	SELECT distinct [cp_sec_user_audit_id]
	FROM [pcc_staging_db010798].dbo.[pho_order_related_value] WITH (NOLOCK)
	WHERE [cp_sec_user_audit_id] IS NOT NULL
		AND [cp_sec_user_audit_id] NOT IN (
			SELECT [cp_sec_user_audit_id]
			FROM [pcc_staging_db010798].dbo.[cp_sec_user_audit] WITH (NOLOCK)
			WHERE [cp_sec_user_audit_id] IS NOT NULL
			
			UNION
			
			SELECT [cp_sec_user_audit_id]
			FROM test_usei9.dbo.[cp_sec_user_audit] WITH (NOLOCK)
			WHERE [cp_sec_user_audit_id] IS NOT NULL
			)


			Select * from cp_sec_user_audit where cp_sec_user_audit_id in (2232,3921)
			cp_sec_user_audit_id
2045
9408
2232
3921
			(138 rows affected)

			Select * FROM [pcc_staging_db010798].dbo.[pho_order_related_value] where cp_sec_user_audit_id in (2232,3921)
			order by cp_sec_user_audit_id


			cp_sec_user_audit_id in (2232,3921)
cp_sec_user_audit_id	Multi_Fac_Id
2045	13
9408	13
2232	12
3921	12

			
			SELECT *
			FROM test_usei9.dbo.[cp_sec_user_audit] WITH (NOLOCK)
			WHERE [cp_sec_user_audit_id] =-999


			begin tran 

			Select * into pcc_temp_storage.dbo.eicaseE010798_pho_order_related_value from [pho_order_related_value] where cp_sec_user_audit_id in (2232,3921) 
			update [pcc_staging_db010798].dbo.[pho_order_related_value] 
			set cp_sec_user_audit_id=-999
			where cp_sec_user_audit_id in (2232,3921) 

			rollback tran 

(123 rows affected)

(123 rows affected)

Completion time: 2022-04-13T21:28:43.2354492-04:00

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
				FROM test_usei9.dbo.[cp_sec_user_audit] WITH (NOLOCK)
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
			FROM test_usei9.dbo.[cp_sec_user_audit] WITH (NOLOCK)
			WHERE [cp_sec_user_audit_id] IS NOT NULL
			)

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
				FROM test_usei9.dbo.[cp_sec_user_audit] WITH (NOLOCK)
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
			FROM test_usei9.dbo.[cp_sec_user_audit] WITH (NOLOCK)
			WHERE [cp_sec_user_audit_id] IS NOT NULL
			)


			Select * from [pho_phys_order_audit_useraudit] where [created_by_audit_id]=12459
			and edited_by_audit_id=12459
			audit_id	edited_by_audit_id	created_by_audit_id	Multi_Fac_Id
2235924	12459	12459	12
2236895	12459	12459	12
2236896	12459	12459	12
2238238	12459	12459	12
2238239	12459	12459	12



			update [pcc_staging_db010798].dbo.[pho_phys_order_audit_useraudit] 
			set created_by_audit_id=-999,edited_by_audit_id=-999
			where [created_by_audit_id]=12459
			and edited_by_audit_id=12459
			
(5 rows affected)

IF EXISTS (
		SELECT [created_by_userid]
		FROM [pcc_staging_db010798].dbo.[pn_progress_note] WITH (NOLOCK)
		WHERE [created_by_userid] IS NOT NULL
			AND [created_by_userid] NOT IN (
				SELECT [userid]
				FROM [pcc_staging_db010798].dbo.[sec_user] WITH (NOLOCK)
				WHERE [userid] IS NOT NULL
				
				UNION
				
				SELECT [userid]
				FROM test_usei9.dbo.[sec_user] WITH (NOLOCK)
				WHERE [userid] IS NOT NULL
				)
		)
	SELECT [created_by_userid]
	FROM [pcc_staging_db010798].dbo.[pn_progress_note] WITH (NOLOCK)
	WHERE [created_by_userid] IS NOT NULL
		AND [created_by_userid] NOT IN (
			SELECT [userid]
			FROM [pcc_staging_db010798].dbo.[sec_user] WITH (NOLOCK)
			WHERE [userid] IS NOT NULL
			
			UNION
			
			SELECT [userid]
			FROM test_usei9.dbo.[sec_user] WITH (NOLOCK)
			WHERE [userid] IS NOT NULL
			)


			created_by_userid
94035
94035

SELECT created_by_userid,*
	FROM [pcc_staging_db010798].dbo.[pn_progress_note]  where created_by_userid=94035

	created_by_userid	pn_id	fac_id
94035	3987894	12
94035	4198011	13

Select *    
			FROM test_usei9.dbo.[sec_user] where long_username like '%pcc%'

			Select * from sec_user where long_username='_api_sound-production'


insert into test_usei9.dbo.sec_user
SELECT userid
	,12 
	,'EICase01079812'
	,getdate()
	,'EICase01079812'
	,getdate()
	,1  
	,long_username
	,staff_id
	,loginname
	,remote_user
	,admin_user
	,eadmin_setup_user
	,ecare_setup_user
	,ecare_user
	,eadmin_user
	,email
	,default_care_tab
	,default_admin_tab
	,auto_pagesetup
	,- 1
	,enabled
	,pho_access
	,enterprise_user
	,regional_setup_access
	,regional_id
	,NULL
	,mds_portal_view
	,cms_checked_clinical
	,cms_checked_admin
	,cms_checked_qia
	,cms_checked_glap
	,cms_checked_enterprise
	,passwd_check
	,passwd_expiry_date
	,alternate_loginname
	,login_to_enterprise_flag
	,mmq_portal_view
	,uda_portal_view
	,max_failed_logins
	,designation_desc
	,care_line_id
	,pharmacy_portal_view
	,initials
	,REENABLED_DATE
	,VALID_UNTIL_DATE
	,EXTERNAL_SYSTEM_ID
	,EXT_FAC_ID
	,pin_check
	,login_to_irm
	,pin_expiry_date
	,all_facilities
	,last_login_date
	,authentication_method
	,next_nps_survey_date
	,pharmacy_portal_pharmtab
	,user_type_id
	,alt_email
	,comment
	,user_first_name
	,user_last_name
	,api_only_user
	,default_admin_view,sso_only_user
from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.sec_user a
where a.userid in (94035)