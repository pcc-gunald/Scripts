

--sp:
--run in destination
--Zion
exec [operational].[sproc_facacq_pre_sec_user_Import_01_scoping]
@src_db_location = '[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058'
,@NS_case_number = 'EICase590131'
,@src_fac_id = 29

exec [operational].[sproc_facacq_pre_sec_user_Import_02_Import]
@src_db_location = '[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058'
,@NS_case_number = 'EICase590131'
,@source_fac_id = 29
,@suffix = 'ZION' -- src 
,@destination_org_id = '1504957707' --org locator
,@destination_fac_id = 29
,@if_is_rerun = 'N'

-----------------------------------------------
--sp:
--run in destination 
--Blanco
exec [operational].[sproc_facacq_pre_sec_user_Import_01_scoping]
@src_db_location = '[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058'
,@NS_case_number = 'EICase590132'
,@src_fac_id = 32

exec [operational].[sproc_facacq_pre_sec_user_Import_02_Import]
@src_db_location = '[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058'
,@NS_case_number = 'EICase590132'
,@source_fac_id = 32
,@suffix = 'ZION' -- src 
,@destination_org_id = '1504957707' --org locator
,@destination_fac_id = 30
,@if_is_rerun = 'N'










--script:

--use test_usei73

--0. Investigation
/*
select fac_id, name from [USVS23\PRODW2F].[us_rca_multi].dbo.facility where fac_id in (16) --src

select fac_id, name from [USVS30\PRODW2M].[us_hand_multi].dbo.facility where fac_id in (30) --dst
*/

--select * from dbo.EIcase61071030sec_user
--DROP table pcc_temp_storage.dbo.EIcase61071030_HAND_sec_user_sameloginname
--DROP TABLE #temp

/*
DROP TABLE pcc_temp_storage.dbo.EIcase61071030_HAND_sec_user_sameloginname
DROP TABLE pcc_temp_storage.dbo.EIcase61071030_HAND_sec_user_samelogin_different_name
DROP TABLE pcc_temp_storage.dbo.EIcase61071030_HAND_sec_user_samelogin_same_name
*/


--=========================================================
--Step 1. Import users that have different loginname
--a. Create backup for users with same loginname
--b. Import users
--=========================================================

--select * from [USVS23\PRODW2F].[us_rca_multi].dbo.sec_user where loginname not like '%pcc-%' and fac_id = 16 --112

select  a.* into pcc_temp_storage.dbo.EIcase61071030_HAND_sec_user_sameloginname
--select b.userid,a.fac_id, b.fac_id,a.long_username, substring(a.[long_username], CHARINDEX(',',a.[long_username]) + 1,250) + ' '+substring(a.[long_username],1,CHARINDEX(',',a.[long_username]) -1) as format_name,b.long_username, a.loginname, b.loginname,b.admin_user_type,* 
--select b.userid,a.fac_id, b.fac_id,a.long_username,b.long_username, a.loginname, b.loginname,b.admin_user_type,* 
--select a.*
from [USVS23\PRODW2F].[us_rca_multi].dbo.sec_user a --SRC
join [USVS30\PRODW2M].[us_hand_multi].dbo.sec_user b --DST
on a.loginname = b.loginname
where a.fac_id = 16 --src fac_id
and a.loginname not like '%pcc-%' 
and a.loginname  not like '%wescom%' --62
--and ((a.loginname not like '%pcc-%' and a.loginname  not like '%wescom%' and a.loginname <>'test'
--and ltrim(rtrim(substring(a.[long_username], CHARINDEX(',',a.[long_username]) + 1,250) + ' '+substring(a.[long_username],1,CHARINDEX(',',a.[long_username]) -1)))= b.long_username)
--or a.loginname ='test')
--62

insert into pcc_temp_storage.dbo.EIcase61071030_HAND_sec_user_sameloginname
select a.*
--select b.userid,a.fac_id, b.fac_id,a.long_username,b.long_username, a.loginname, b.loginname,b.admin_user_type,* 
--select a.*
from [USVS23\PRODW2F].[us_rca_multi].dbo.sec_user a
join [USVS30\PRODW2M].[us_hand_multi].dbo.sec_user b
on a.loginname = b.loginname
where a.userid in (2053, 2637, 46, 1634) --userid from scoping
and a.loginname not like '%pcc-%' 
and a.loginname  not like '%wescom%'
--3

--select * from pcc_temp_storage.dbo.EIcase61071030_HAND_sec_user_sameloginname


declare @MaxSecUserid int,
		@Rowcount int,
		@facid int


select identity(int,0,1) as row, src.userid as src_id, NULL as dst_id
into dbo.EIcase61071030sec_user --change case #
--select *
from [USVS23\PRODW2F].[us_rca_multi].dbo.sec_user src --src db
where fac_id = 16 --src fac
and loginname not like '%pcc-%' and loginname  not like '%wescom%' 
or userid in( 2053, 2637, 46, 1634) --userid from scoping


set @Rowcount=@@rowcount
exec get_next_primary_key 'sec_user','userid',@MaxSecUserid output , @Rowcount

update  dbo.EIcase61071030sec_user  ----change case #
set  dst_id = row+@MaxSecUserid

--(116 row(s) affected)

--(116 row(s) affected)

--select * from dbo.EIcase61071030sec_user


--==========================================================================
--    Insert Security Users
INSERT INTO dbo.sec_user
SELECT map.dst_id
	,30  --dst fac_id
	,'EICase61071030'
	,getdate()
	,'EICase61071030'
	,getdate()
	,10089  --dst org_id
	,--dst fac_id, case#, org_id
	long_username
	,staff_id
	,loginname
	,remote_user
	,admin_user
	,eadmin_setup_user
	,ecare_setup_user
	,ecare_user
	,eadmin_user
	,NULL
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
	,NULL
	--,DEFAULT_ANALYTICS_TAB  -- new clmn, varchar(50) -- NULLable, all nulls in src db
	,comment-- new clmn,all nulls in src db
	,user_first_name
	,user_last_name
	,api_only_user
	,sso_only_user
FROM [USVS23\PRODW2F].[us_rca_multi].dbo.sec_user src -----SRC dB
JOIN dbo.EIcase61071030sec_user map ON src.userid = map.src_id
WHERE src.userid NOT IN (
		SELECT userid
		FROM pcc_temp_storage.dbo.EIcase61071030_HAND_sec_user_sameloginname
		) --51 rows


INSERT INTO dbo.sec_user_facility (
	userid
	,facility_id
	,access_level
	)
SELECT a.dst_id
	,30  --dst fac_id
--	,2 AS access_level --change dst facility_id only (after dst_id)
	,src.access_level
FROM dbo.EIcase61071030sec_user a join [USVS23\PRODW2F].[us_rca_multi].dbo.sec_user_facility src
on a.src_id = src.userid
WHERE src.userid NOT IN (
		SELECT userid
		FROM pcc_temp_storage.dbo.EIcase61071030_HAND_sec_user_sameloginname
		) 
and src.facility_id = 16--50


--select t.*, u.* from EIcase61071030sec_user t LEFT JOIN sec_user u ON t.dst_id=u.userid
--WHERE u.userid is null


--==================================================================================
--Step 2. Import users with same loginname but different long_username adding suffix
--==================================================================================

select  a.* into pcc_temp_storage.dbo.EIcase61071030_HAND_sec_user_samelogin_different_name
--select b.userid,a.fac_id, b.fac_id,a.long_username src_username, b.long_username dst_username, a.loginname, b.loginname,b.admin_user_type, * 
from [USVS23\PRODW2F].[us_rca_multi].dbo.sec_user a
join [USVS30\PRODW2M].[us_hand_multi].dbo.sec_user b
on a.loginname = b.loginname--111
where a.fac_id = 16--94
and a.loginname not like '%pcc-%' and a.loginname  not like '%wescom%'
and a.long_username <> b.long_username
--and a.loginname not like '%pcc-%' and a.loginname  not like '%wescom%' and a.loginname <>'test'
--and ltrim(rtrim(substring(a.[long_username], CHARINDEX(',',a.[long_username]) + 1,250) + ' '+substring(a.[long_username],1,CHARINDEX(',',a.[long_username]) -1)))<> b.long_username
--and b.created_by <> 'Case60836425'
--21 rows

insert into pcc_temp_storage.dbo.EIcase61071030_HAND_sec_user_samelogin_different_name
select a.*
--select b.userid,a.fac_id, b.fac_id,a.long_username src_username, b.long_username dst_username, a.loginname, b.loginname,b.admin_user_type, * 
from [USVS23\PRODW2F].[us_rca_multi].dbo.sec_user a
join [USVS30\PRODW2M].[us_hand_multi].dbo.sec_user b
on a.loginname = b.loginname--111
where a.userid in (2053, 2637, 46, 1634)--94 --userid from scoping
and a.loginname not like '%pcc-%' and a.loginname  not like '%wescom%'
and a.long_username <> b.long_username
--and a.loginname not like '%pcc-%' and a.loginname  not like '%wescom%' and a.loginname <>'test'
--and ltrim(rtrim(substring(a.[long_username], CHARINDEX(',',a.[long_username]) + 1,250) + ' '+substring(a.[long_username],1,CHARINDEX(',',a.[long_username]) -1)))<> b.long_username
--and b.created_by <> 'Case60836425'
--2



--select  a.*into pcc_temp_storage.dbo.EIcase61071030_HAND_sec_user_samelogin_different_name
----select b.userid,a.fac_id, b.fac_id,a.long_username, substring(a.[long_username], CHARINDEX(',',a.[long_username]) + 1,250) + ' '+substring(a.[long_username],1,CHARINDEX(',',a.[long_username]) -1) as format_name,b.long_username, a.loginname, b.loginname,b.admin_user_type,* 
----select b.created_by,a.*
--from [USVS23\PRODW2F].[us_rca_multi].dbo.sec_user a
--join [USVS30\PRODW2M].[us_hand_multi].dbo.sec_user b
--on a.loginname = b.loginname
--where a.fac_id = 1
--and a.loginname not like '%pcc-%' and a.loginname  not like '%wescom%' and a.loginname <>'test'
--and ltrim(rtrim(substring(a.[long_username], CHARINDEX(',',a.[long_username]) + 1,250) + ' '+substring(a.[long_username],1,CHARINDEX(',',a.[long_username]) -1)))<> b.long_username
--and b.created_by <> 'Case61071030'
----27


--select * from pcc_temp_storage.dbo.EIcase61071030_HAND_sec_user_samelogin_different_name

--    Insert Security Users
INSERT INTO dbo.sec_user
SELECT map.dst_id
	,30  --dst fac_id
	,'EICase61071030'
	,getdate()
	,'EICase61071030'
	,getdate()
	,10089  --dst org_id
	,--dst fac_id, case#, org_id
	long_username
	,staff_id
	,loginname + 'rca' --
	,remote_user
	,admin_user
	,eadmin_setup_user
	,ecare_setup_user
	,ecare_user
	,eadmin_user
	,NULL
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
	,NULL
	--,DEFAULT_ANALYTICS_TAB  -- new clmn, varchar(50) -- NULLable, all nulls in src db
	,comment-- new clmn,all nulls in src db
	,user_first_name
	,user_last_name
	,api_only_user
	,sso_only_user
FROM  [USVS23\PRODW2F].[us_rca_multi].dbo.sec_user src -----SRC dB
JOIN dbo.EIcase61071030sec_user map ON src.userid = map.src_id
and src_id IN (select userid from pcc_temp_storage.dbo.EIcase61071030_HAND_sec_user_samelogin_different_name)
-- 23 rows


INSERT INTO dbo.sec_user_facility (
	userid
	,facility_id
	,access_level
	)
SELECT a.dst_id
	,30  --dst fac_id
--	,2 AS access_level --change dst facility_id only (after dst_id)
	,src.access_level
FROM dbo.EIcase61071030sec_user a join [USVS23\PRODW2F].[us_rca_multi].dbo.sec_user_facility src
on a.src_id = src.userid
JOIN pcc_temp_storage.dbo.EIcase61071030_HAND_sec_user_samelogin_different_name t on src.userid = t.userid
WHERE src.userid IN (
		SELECT userid
		FROM pcc_temp_storage.dbo.EIcase61071030_HAND_sec_user_samelogin_different_name
		) 
and src.facility_id = 16--23 rows


--select *  
--INTO pcc_temp_storage.dbo.EIcase61071030_HAND_sec_user_sameloginname
--from #temp t where userid NOT IN (select userid from pcc_temp_storage.dbo.EIcase61071030_HAND_sec_user_samelogin_different_name)

--select * from pcc_temp_storage.dbo.EIcase61071030_HAND_sec_user_sameloginname
--select * from pcc_temp_storage.dbo.EIcase61071030_HAND_sec_user_samelogin_different_name

--select * from .dbo.sec_user where loginname like '%rca' and fac_id = 30


--================================
--Step 3. Update table for testing
--================================
ALTER TABLE dbo.EICase61071030sec_user
add corporate char

update dbo.EICase61071030sec_user
set corporate = 'N'--116

--INSERT INTO dbo.EICase61071030sec_user (src_id,dst_id,corporate)
--values (-998,-998,'Y')		--1

--INSERT INTO dbo.EICase61071030sec_user (src_id,dst_id,corporate)
--values (-10000,-10000,'Y')	--1

INSERT INTO dbo.EICase61071030sec_user (src_id,dst_id,corporate)
values (1,1,'Y')	--1


--============================================================================
--Step 4. Import users with same login and same name by adding mapping
--============================================================================
--mapping table
--select * from  dbo.EIcase61071030sec_user--338

select  a.* into pcc_temp_storage.dbo.EIcase61071030_HAND_sec_user_samelogin_same_name
--select b.userid,a.fac_id, b.fac_id,a.long_username src_username, b.long_username dst_username, a.loginname, b.loginname,b.admin_user_type, * 
from [USVS23\PRODW2F].[us_rca_multi].dbo.sec_user a
join [USVS30\PRODW2M].[us_hand_multi].dbo.sec_user b
on a.loginname = b.loginname--111
where a.fac_id = 16--94
and a.loginname not like '%pcc-%' and a.loginname  not like '%wescom%'
and a.long_username = b.long_username --41
and b.created_by not like '%EICase61071030%' --373


insert  into pcc_temp_storage.dbo.EIcase61071030_HAND_sec_user_samelogin_same_name
select a.*
--select b.userid,a.fac_id, b.fac_id,a.long_username src_username, b.long_username dst_username, a.loginname, b.loginname,b.admin_user_type, * 
from [USVS23\PRODW2F].[us_rca_multi].dbo.sec_user a
join [USVS30\PRODW2M].[us_hand_multi].dbo.sec_user b
on a.loginname = b.loginname--111
where a.userid in (2053, 2637, 46, 1634)--94
and a.loginname not like '%pcc-%' and a.loginname  not like '%wescom%'
and a.long_username = b.long_username --1
and b.created_by not like '%EICase61071030%' --373


update map
set dst_id = ur.userid, corporate='Y'
--select map.src_id, ln.userid, map.dst_id, ur.userid, * 
FROM dbo.EIcase61071030sec_user map 
JOIN pcc_temp_storage.dbo.EIcase61071030_HAND_sec_user_samelogin_same_name ln ON ln.userid = map.src_id
JOIN sec_user ur ON ln.loginname = ur.loginname--42


----------For sec_user_physical_id

--select * into pcc_temp_storage.dbo.EIcase769239_SLM_sec_user_physical_id_bkp

INSERT INTO sec_user_physical_id (
	userid
	,sequence
	,physicalid
	)
SELECT b.dst_id
	,[sequence]
	,[physicalid]
FROM [USVS23\PRODW2F].[us_rca_multi].[dbo].sec_user_physical_id src
JOIN dbo.EIcase61071030sec_user b ON b.src_id = src.userid  

update sec_user
set admin_user_type = 'E'
--select * 
FROM dbo.sec_user  
where loginname like '[_]api[_]%'
and (created_by like '%EICase61071030%' or userid in (select dst_id from EIcase61071030sec_user where corporate = 'N'))
and admin_user_type is NULL







