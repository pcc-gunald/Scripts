select * from stagingmergelog 
order by msgtime 

Violation of PRIMARY KEY constraint 'sec_user__userid_PKPk'. Cannot insert duplicate key in object 'dbo.sec_user'. The duplicate key value is (131717).

INSERT INTO test_usei425.dbo.sec_user (
	userid
	,fac_id
	,created_by
	,created_date
	,revision_by
	,revision_date
	,org_id
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
	,position_id
	,enabled
	,pho_access
	,enterprise_user
	,regional_setup_access
	,regional_id
	,admin_user_type
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
	,default_admin_view
	,sso_only_user
	)
SELECT userid
	,fac_id
	,created_by
	,created_date
	,revision_by
	,revision_date
	,org_id
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
	,position_id
	,enabled
	,pho_access
	,enterprise_user
	,regional_setup_access
	,regional_id
	,admin_user_type
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
	,default_admin_view
	,sso_only_user
FROM pcc_staging_db009632.dbo.sec_user
order by userid


USE MASTER
BACKUP DATABASE [pcc_staging_db009632] TO URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1843/Final/pcc_staging_db009632_Case00963221_20220329151142_1.BAK', URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1843/Final/pcc_staging_db009632_Case00963221_20220329151142_2.BAK', URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1843/Final/pcc_staging_db009632_Case00963221_20220329151142_3.BAK', URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1843/Final/pcc_staging_db009632_Case00963221_20220329151142_4.BAK'
 WITH COPY_ONLY, FORMAT, INIT, COMPRESSION, STATS=10

 USE MASTER
RESTORE DATABASE pcc_staging_db009632 FROM URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1843/Final/pcc_staging_db009632_Case00963221_20220315084942_1.BAK', URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1843/Final/pcc_staging_db009632_Case00963221_20220315084942_2.BAK', URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1843/Final/pcc_staging_db009632_Case00963221_20220315084942_3.BAK', URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1843/Final/pcc_staging_db009632_Case00963221_20220315084942_4.BAK'

select * from listoftables

/*
common_code	E15	NULL
facility_audit	E14	NULL
sec_role	E14	NULL
sec_role_function	E14	NULL
*/