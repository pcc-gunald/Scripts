
--sp:
--run in destination
exec [operational].[sproc_facacq_pre_sec_user_Import_01_scoping]
@src_db_location = '[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].[test_usei1029]'
,@NS_case_number = 'EICase588995'
,@src_fac_id = 5


UPDATE [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].[test_usei1029].[dbo].sec_user
SET loginname=loginname+'_PRQC'
WHERE 1=1
--AND loginname NOT LIKE '%_PRQC'
AND userid in(
107
,135
,1174
,1203
,13370
,15158
,250333
,260863
,261285
,262013
,282294
,285173
,296723
,333614
,362023
,380464
,389333
,446954
)


exec [operational].[sproc_facacq_pre_sec_user_Import_02_Import]
@src_db_location = '[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].[test_usei1029]'
,@NS_case_number = 'EICase588995'
,@source_fac_id = 5
,@suffix = 'PRQC'
,@destination_org_id = '1504962637'
,@destination_fac_id = 194
,@if_is_rerun = 'N'

select * from EICase588995sec_user

--script:
/*

if OBJECT_ID ('pcc_temp_storage.dbo.EICase588995_1504962637_sec_user_sameloginname','U') is not null
DROP TABLE pcc_temp_storage.dbo.EICase588995_1504962637_sec_user_sameloginname

if OBJECT_ID ('pcc_temp_storage.dbo.EICase588995_1504962637_sec_user_samelogin_different_name','U') is not null
DROP TABLE pcc_temp_storage.dbo.EICase588995_1504962637_sec_user_samelogin_different_name

if OBJECT_ID ('pcc_temp_storage.dbo.EICase588995_1504962637_sec_user_samelogin_same_name','U') is not null
DROP TABLE pcc_temp_storage.dbo.EICase588995_1504962637_sec_user_samelogin_same_name

if OBJECT_ID ('dbo.EICase588995sec_user','U') is not null
DROP TABLE dbo.EICase588995sec_user

sproc_facacq_pre_sec_user_Import_02_Import - drop temporary tables


select  a.* into pcc_temp_storage.dbo.EICase588995_1504962637_sec_user_sameloginname
from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].[test_usei1029].dbo.sec_user a 
join  dbo.sec_user b on a.loginname = b.loginname
where a.fac_id = 5
and a.loginname not like '%pcc-%' 
and a.loginname  not like '%wescom%' 

sproc_facacq_pre_sec_user_Import_02_Import - pcc_temp_storage.dbo.EICase588995_1504962637_sec_user_sameloginname - 6 affected rows


insert into pcc_temp_storage.dbo.EICase588995_1504962637_sec_user_sameloginname
select a.*
from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].[test_usei1029].dbo.sec_user a
join dbo.sec_user b
on a.loginname = b.loginname
where a.userid in (select distinct userid from pcc_temp_storage.dbo._bkp_EICase588995_sec_user_import_pre_scoping_fac_5)

sproc_facacq_pre_sec_user_Import_02_Import - pcc_temp_storage.dbo.EICase588995_1504962637_sec_user_sameloginname - 0 affected rows


select identity(int,1,1) as row_id, src.userid as src_id, NULL as dst_id
into dbo.EICase588995sec_user 
from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].[test_usei1029].dbo.sec_user src 
where fac_id = 5 and loginname not like '%pcc-%' and loginname not like '%wescom%' 
or userid in (select distinct userid from pcc_temp_storage.dbo._bkp_EICase588995_sec_user_import_pre_scoping_fac_5)

sproc_facacq_pre_sec_user_Import_02_Import - dbo.EICase588995sec_user - 1 affected rows


UPDATE dbo.EICase588995sec_user SET dst_id = 170609 + ([row_id] - 1)

		
sproc_facacq_pre_sec_user_Import_02_Import - 588 affected rows.


INSERT INTO dbo.sec_user
SELECT map.dst_id,194,'EICase588995',getdate(),'EICase588995',getdate(),'1504962637',[long_username],NULL,[loginname],[remote_user],[admin_user],[eadmin_setup_user],[ecare_setup_user],[ecare_user],[eadmin_user],NULL,[default_care_tab],[default_admin_tab],[auto_pagesetup],-1,[enabled],[pho_access],[enterprise_user],[regional_setup_access],[regional_id],NULL,[mds_portal_view],[cms_checked_clinical],[cms_checked_admin],[cms_checked_qia],[cms_checked_glap],[cms_checked_enterprise],[passwd_check],[passwd_expiry_date],[alternate_loginname],[login_to_enterprise_flag],[mmq_portal_view],[uda_portal_view],[max_failed_logins],[designation_desc],[care_line_id],[pharmacy_portal_view],[initials],[REENABLED_DATE],[VALID_UNTIL_DATE],[EXTERNAL_SYSTEM_ID],[EXT_FAC_ID],[pin_check],[login_to_irm],[pin_expiry_date],[all_facilities],[last_login_date],[authentication_method],[next_nps_survey_date],[pharmacy_portal_pharmtab],[user_type_id],NULL,[comment],[user_first_name],[user_last_name],[api_only_user],[default_admin_view],[sso_only_user]
FROM [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].[test_usei1029].dbo.sec_user src
JOIN dbo.EICase588995sec_user map ON src.userid = map.src_id
WHERE src.userid NOT IN (SELECT userid FROM pcc_temp_storage.dbo.EICase588995_1504962637_sec_user_sameloginname)

sproc_facacq_pre_sec_user_Import_02_Import - sec_user - 582 affected rows


INSERT INTO dbo.sec_user_facility (userid,facility_id,access_level)
SELECT DISTINCT a.dst_id
	,194   
	,src.access_level
FROM dbo.EICase588995sec_user a join [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].[test_usei1029].dbo.sec_user_facility src
on a.src_id = src.userid
WHERE src.userid NOT IN (SELECT userid FROM pcc_temp_storage.dbo.EICase588995_1504962637_sec_user_sameloginname) and src.facility_id = 5

sproc_facacq_pre_sec_user_Import_02_Import - sec_user_facility - 576 affected rows


select  a.* into pcc_temp_storage.dbo.EICase588995_1504962637_sec_user_samelogin_different_name
from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].[test_usei1029].dbo.sec_user a
join  dbo.sec_user b
on a.loginname = b.loginname
where a.fac_id = 5 
and a.loginname not like '%pcc-%' and a.loginname  not like '%wescom%'
and a.long_username <> b.long_username

sproc_facacq_pre_sec_user_Import_02_Import - pcc_temp_storage.dbo.EICase588995_1504962637_sec_user_samelogin_different_name - 0 affected rows


insert into pcc_temp_storage.dbo.EICase588995_1504962637_sec_user_samelogin_different_name
select a.*
from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].[test_usei1029].dbo.sec_user a
join  dbo.sec_user b
on a.loginname = b.loginname
where a.userid in (select distinct userid from pcc_temp_storage.dbo._bkp_EICase588995_sec_user_import_pre_scoping_fac_5)
and a.long_username <> b.long_username

sproc_facacq_pre_sec_user_Import_02_Import - pcc_temp_storage.dbo.EICase588995_1504962637_sec_user_samelogin_different_name - 0 affected rows


INSERT INTO dbo.sec_user
SELECT map.dst_id,194,'EICase588995',getdate(),'EICase588995',getdate(),'1504962637',[long_username],NULL,[loginname] + 'PRQC',[remote_user],[admin_user],[eadmin_setup_user],[ecare_setup_user],[ecare_user],[eadmin_user],NULL,[default_care_tab],[default_admin_tab],[auto_pagesetup],-1,[enabled],[pho_access],[enterprise_user],[regional_setup_access],[regional_id],NULL,[mds_portal_view],[cms_checked_clinical],[cms_checked_admin],[cms_checked_qia],[cms_checked_glap],[cms_checked_enterprise],[passwd_check],[passwd_expiry_date],[alternate_loginname],[login_to_enterprise_flag],[mmq_portal_view],[uda_portal_view],[max_failed_logins],[designation_desc],[care_line_id],[pharmacy_portal_view],[initials],[REENABLED_DATE],[VALID_UNTIL_DATE],[EXTERNAL_SYSTEM_ID],[EXT_FAC_ID],[pin_check],[login_to_irm],[pin_expiry_date],[all_facilities],[last_login_date],[authentication_method],[next_nps_survey_date],[pharmacy_portal_pharmtab],[user_type_id],NULL,[comment],[user_first_name],[user_last_name],[api_only_user],[default_admin_view],[sso_only_user]
FROM  [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].[test_usei1029].dbo.sec_user src 
JOIN dbo.EICase588995sec_user map ON src.userid = map.src_id
and src_id IN (select userid from pcc_temp_storage.dbo.EICase588995_1504962637_sec_user_samelogin_different_name)

sproc_facacq_pre_sec_user_Import_02_Import - sec_user - 0 affected rows


INSERT INTO dbo.sec_user_facility (userid,facility_id,access_level)
SELECT DISTINCT a.dst_id
	,194   
	,src.access_level
FROM dbo.EICase588995sec_user a join [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].[test_usei1029].dbo.sec_user_facility src
on a.src_id = src.userid
JOIN pcc_temp_storage.dbo.EICase588995_1504962637_sec_user_samelogin_different_name t on src.userid = t.userid
WHERE src.userid IN (SELECT userid FROM pcc_temp_storage.dbo.EICase588995_1504962637_sec_user_samelogin_different_name) 
and src.facility_id = 5

sproc_facacq_pre_sec_user_Import_02_Import - sec_user_facility - 0 affected rows
ALTER TABLE dbo.EICase588995sec_user
add corporate char
sproc_facacq_pre_sec_user_Import_02_Import - add corporate column to dbo.EICase588995sec_user
update dbo.EICase588995sec_user set corporate = 'N' 
sproc_facacq_pre_sec_user_Import_02_Import - update dbo.EICase588995sec_user.corporate - 588 affected rows


	select  a.* into pcc_temp_storage.dbo.EICase588995_1504962637_sec_user_samelogin_same_name
	from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].[test_usei1029].dbo.sec_user a
	join  dbo.sec_user b
	on a.loginname = b.loginname
	where a.fac_id = 5 
	and a.loginname not like '%pcc-%' and a.loginname  not like '%wescom%'
	and a.long_username = b.long_username 
	and b.created_by not like '%EICase588995'

	
sproc_facacq_pre_sec_user_Import_02_Import - pcc_temp_storage.dbo.EICase588995_1504962637_sec_user_samelogin_same_name - 6 affected rows


	insert  into pcc_temp_storage.dbo.EICase588995_1504962637_sec_user_samelogin_same_name
	select a.*
	from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].[test_usei1029].dbo.sec_user a
	join  dbo.sec_user b
	on a.loginname = b.loginname
	where a.userid in (select distinct userid from pcc_temp_storage.dbo._bkp_EICase588995_sec_user_import_pre_scoping_fac_5)
	and a.long_username = b.long_username 
	and b.created_by not like '%EICase588995' 

	
sproc_facacq_pre_sec_user_Import_02_Import - pcc_temp_storage.dbo.EICase588995_1504962637_sec_user_samelogin_same_name - 0 affected rows


	update map
	set dst_id = ur.userid, corporate = 'Y'
	FROM dbo.EICase588995sec_user map 
	JOIN pcc_temp_storage.dbo.EICase588995_1504962637_sec_user_samelogin_same_name ln ON ln.userid = map.src_id
	JOIN sec_user ur ON ln.loginname = ur.loginname

	
sproc_facacq_pre_sec_user_Import_02_Import - EICase588995sec_user - 6 affected rows


INSERT INTO sec_user_physical_id (userid,sequence,physicalid)
SELECT b.dst_id
	,[sequence]
	,[physicalid]
FROM [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].[test_usei1029].[dbo].sec_user_physical_id src
JOIN dbo.EICase588995sec_user b ON b.src_id = src.userid 
where b.corporate = 'N' and b.dst_id not in (select userid from sec_user_physical_id)

sproc_facacq_pre_sec_user_Import_02_Import - sec_user_physical_id - 125 affected rows


update sec_user
set admin_user_type = 'E'
FROM dbo.sec_user  
where loginname like '[_]api[_]%'
and (created_by like '%EICase588995'  or userid in (select dst_id from EICase588995sec_user where corporate = 'N'))
and admin_user_type is NULL

sproc_facacq_pre_sec_user_Import_02_Import - api user fix - 0 affected rows

Completion time: 2022-03-17T16:44:47.6711052-04:00


*/