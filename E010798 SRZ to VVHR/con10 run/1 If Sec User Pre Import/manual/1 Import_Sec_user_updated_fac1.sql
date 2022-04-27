use us_cit_multi

--0. Investigation
/*
select fac_id, name from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.dbo.facility where fac_id in (45) --src

select fac_id, name from facility where fac_id in (1) --dst
*/

--select * from dbo.EIcase01079812sec_user
--DROP table pcc_temp_storage.dbo.EIcase01079812_CIT_sec_user_sameloginname
--DROP TABLE #temp

/*
DROP TABLE pcc_temp_storage.dbo.EIcase01079812_CIT_sec_user_sameloginname
DROP TABLE pcc_temp_storage.dbo.EIcase01079812_CIT_sec_user_samelogin_different_name
DROP TABLE pcc_temp_storage.dbo.EIcase01079812_CIT_sec_user_samelogin_same_name
*/

if OBJECT_ID ('pcc_temp_storage.dbo.EIcase01079812_CIT_sec_user_sameloginname','U') is not null
drop table pcc_temp_storage.dbo.EIcase01079812_CIT_sec_user_sameloginname

if OBJECT_ID ('pcc_temp_storage.dbo.EIcase01079812_CIT_sec_user_samelogin_different_name','U') is not null
drop table pcc_temp_storage.dbo.EIcase01079812_CIT_sec_user_samelogin_different_name

if OBJECT_ID ('pcc_temp_storage.dbo.EIcase01079812_CIT_sec_user_samelogin_same_name','U') is not null
drop table pcc_temp_storage.dbo.EIcase01079812_CIT_sec_user_samelogin_same_name


if OBJECT_ID ('pcc_temp_storage.dbo.bkp_sec_user_EICase010798','U') is not null
drop table pcc_temp_storage.dbo.bkp_sec_user_EICase010798

if OBJECT_ID ('pcc_temp_storage.dbo.bkp_sec_user_facility_EICase010798','U') is not null
drop table pcc_temp_storage.dbo.bkp_sec_user_facility_EICase010798

if OBJECT_ID ('pcc_temp_storage.dbo.bkp_sec_user_physical_id_EICase010798','U') is not null
drop table pcc_temp_storage.dbo.bkp_sec_user_physical_id_EICase010798


--select * into pcc_temp_storage.dbo.bkp_sec_user_EICase010798 from sec_user

--select * into pcc_temp_storage.dbo.bkp_sec_user_facility_EICase010798 from sec_user_facility

--select * into pcc_temp_storage.dbo.bkp_sec_user_physical_id_EICase010798 from sec_user_physical_id

--=========================================================
--Step 1. Import users that have different loginname
--a. Create backup for users with same loginname
--b. Import users
--=========================================================

--select * from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.dbo.sec_user where loginname not like '%pcc-%' and fac_id = 45 --112

select  a.* into pcc_temp_storage.dbo.EIcase01079812_CIT_sec_user_sameloginname
--select b.userid,a.fac_id, b.fac_id,a.long_username, substring(a.[long_username], CHARINDEX(',',a.[long_username]) + 1,450) + ' '+substring(a.[long_username],1,CHARINDEX(',',a.[long_username]) -1) as format_name,b.long_username, a.loginname, b.loginname,b.admin_user_type,* 
--select b.userid,a.fac_id, b.fac_id,a.long_username,b.long_username, a.loginname, b.loginname,b.admin_user_type,* 
--select a.*
from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.dbo.sec_user a --SRC
join sec_user b --DST
on a.loginname = b.loginname
where a.fac_id = 45 --src fac_id
and a.loginname not like '%pcc-%' 
and a.loginname  not like '%wescom%' --28
--and ((a.loginname not like '%pcc-%' and a.loginname  not like '%wescom%' and a.loginname <>'test'
--and ltrim(rtrim(substring(a.[long_username], CHARINDEX(',',a.[long_username]) + 1,450) + ' '+substring(a.[long_username],1,CHARINDEX(',',a.[long_username]) -1)))= b.long_username)
--or a.loginname ='test')
--28


insert into pcc_temp_storage.dbo.EIcase01079812_CIT_sec_user_sameloginname
select a.*
--select b.userid,a.fac_id, b.fac_id,a.long_username,b.long_username, a.loginname, b.loginname,b.admin_user_type,* 
--select a.*
from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.dbo.sec_user a
join sec_user b
on a.loginname = b.loginname
where a.userid in (select userid from pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45  ) --userid from scoping
and a.loginname not like '%pcc-%' 
and a.loginname  not like '%wescom%'
--3

--select * from pcc_temp_storage.dbo.EIcase01079812_CIT_sec_user_sameloginname


declare @MaxSecUserid int,
		@Rowcount int,
		@facid int


select identity(int,0,1) as row_id, src.userid as src_id, NULL as dst_id
into dbo.EIcase01079812sec_user --change case #
--select *
from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.dbo.sec_user src --src db
where (fac_id = 45 or userid in( select userid from pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45 ) --userid from scoping
 ) --src fac
and loginname not like '%pcc-%' and loginname  not like '%wescom%' 

set @Rowcount=@@rowcount
exec get_next_primary_Key 'sec_user','userid',@MaxSecUserid output , @Rowcount

update  dbo.EIcase01079812sec_user  ----change case #
set  dst_id = row_id+@MaxSecUserid

--(116 row(s) affected)

--==========================================================================
--    Insert Security Users
INSERT INTO dbo.sec_user
SELECT map.dst_id
	,216  --dst fac_id
	,'EICase01079812'
	,getdate()
	,'EICase01079812'
	,getdate()
	,1504957708  --dst org_id
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
	,''
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
	,''
	--,DEFAULT_ANALYTICS_TAB  -- new clmn, varchar(50) -- NULLable, all nulls in src db
	,comment-- new clmn,all nulls in src db
	,user_first_name
	,user_last_name
	,api_only_user ,default_admin_view, sso_only_user 
FROM [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.dbo.sec_user src -----SRC dB
JOIN dbo.EIcase01079812sec_user map ON src.userid = map.src_id
WHERE src.userid NOT IN (
		SELECT userid
		FROM pcc_temp_storage.dbo.EIcase01079812_CIT_sec_user_sameloginname
		) --51 rows
		
--(1420 rows affected)

--Completion time: 2022-02-25T14:45:00.6845090-05:00

 
INSERT INTO dbo.sec_user_facility (
	userid
	,facility_id
	,access_level
	)
SELECT distinct a.dst_id
	,216  --dst fac_id
--	,2 AS access_level --change dst facility_id only (after dst_id)
	,src.access_level
FROM dbo.EIcase01079812sec_user a join [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.dbo.sec_user_facility src
on a.src_id = src.userid
WHERE src.userid NOT IN (
		SELECT userid
		FROM pcc_temp_storage.dbo.EIcase01079812_CIT_sec_user_sameloginname
		) 
and src.facility_id = 45--50


--select t.*, u.* from EIcase01079812sec_user t LEFT JOIN sec_user u ON t.dst_id=u.userid
--WHERE u.userid is null


--==================================================================================
--Step 2. Import users with same loginname but different long_username adding suffix
--==================================================================================

select  a.* into pcc_temp_storage.dbo.EIcase01079812_CIT_sec_user_samelogin_different_name
--select b.userid,a.fac_id, b.fac_id,a.long_username src_username, b.long_username dst_username, a.loginname, b.loginname,b.admin_user_type, * 
from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.dbo.sec_user a
join sec_user b
on a.loginname = b.loginname--111
where a.fac_id = 45--94
and a.loginname not like '%pcc-%' and a.loginname  not like '%wescom%'
and a.long_username <> b.long_username
--and a.loginname not like '%pcc-%' and a.loginname  not like '%wescom%' and a.loginname <>'test'
--and ltrim(rtrim(substring(a.[long_username], CHARINDEX(',',a.[long_username]) + 1,450) + ' '+substring(a.[long_username],1,CHARINDEX(',',a.[long_username]) -1)))<> b.long_username
--and b.created_by <> 'Case60836445'
--21 rows

insert into pcc_temp_storage.dbo.EIcase01079812_CIT_sec_user_samelogin_different_name
select a.*
--select b.userid,a.fac_id, b.fac_id,a.long_username src_username, b.long_username dst_username, a.loginname, b.loginname,b.admin_user_type, * 
from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.dbo.sec_user a
join sec_user b
on a.loginname = b.loginname--111
where a.userid in (select userid from pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45 )--94 --userid from scoping
and a.loginname not like '%pcc-%' and a.loginname  not like '%wescom%'
and a.long_username <> b.long_username
--and a.loginname not like '%pcc-%' and a.loginname  not like '%wescom%' and a.loginname <>'test'
--and ltrim(rtrim(substring(a.[long_username], CHARINDEX(',',a.[long_username]) + 1,450) + ' '+substring(a.[long_username],1,CHARINDEX(',',a.[long_username]) -1)))<> b.long_username
--and b.created_by <> 'Case60836445'
--2



--select  a.*into pcc_temp_storage.dbo.EIcase01079812_CIT_sec_user_samelogin_different_name
----select b.userid,a.fac_id, b.fac_id,a.long_username, substring(a.[long_username], CHARINDEX(',',a.[long_username]) + 1,450) + ' '+substring(a.[long_username],1,CHARINDEX(',',a.[long_username]) -1) as format_name,b.long_username, a.loginname, b.loginname,b.admin_user_type,* 
----select b.created_by,a.*
--from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.dbo.sec_user a
--join sec_user b
--on a.loginname = b.loginname
--where a.fac_id = 1
--and a.loginname not like '%pcc-%' and a.loginname  not like '%wescom%' and a.loginname <>'test'
--and ltrim(rtrim(substring(a.[long_username], CHARINDEX(',',a.[long_username]) + 1,450) + ' '+substring(a.[long_username],1,CHARINDEX(',',a.[long_username]) -1)))<> b.long_username
--and b.created_by <> 'Case01079812'
----1


--select * from pcc_temp_storage.dbo.EIcase01079812_CIT_sec_user_samelogin_different_name
----dwrightcmc
--    Insert Security Users

----begin tran 
INSERT INTO dbo.sec_user
SELECT map.dst_id
	,216  --dst fac_id
	,'EICase01079812'
	,getdate()
	,'EICase01079812'
	,getdate()
	,1504957708  --dst org_id
	,--dst fac_id, case#, org_id
	long_username
	,staff_id
	,loginname + 'CMC' --
	,remote_user
	,admin_user
	,eadmin_setup_user
	,ecare_setup_user
	,ecare_user
	,eadmin_user
	,''
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
	,''
	--,DEFAULT_ANALYTICS_TAB  -- new clmn, varchar(50) -- NULLable, all nulls in src db
	,comment-- new clmn,all nulls in src db
	,user_first_name
	,user_last_name
	,api_only_user ,default_admin_view, sso_only_user 
FROM  [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.dbo.sec_user src -----SRC dB
JOIN dbo.EIcase01079812sec_user map ON src.userid = map.src_id
and src_id IN (select userid from pcc_temp_storage.dbo.EIcase01079812_CIT_sec_user_samelogin_different_name)

-- 100 rows
----rollback tran 




INSERT INTO dbo.sec_user_facility (
	userid
	,facility_id
	,access_level
	)
SELECT distinct a.dst_id
	,216  --dst fac_id
--	,2 AS access_level --change dst facility_id only (after dst_id)
	,src.access_level
FROM dbo.EIcase01079812sec_user a join [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.dbo.sec_user_facility src
on a.src_id = src.userid
JOIN pcc_temp_storage.dbo.EIcase01079812_CIT_sec_user_samelogin_different_name t on src.userid = t.userid
WHERE src.userid IN (
		SELECT userid
		FROM pcc_temp_storage.dbo.EIcase01079812_CIT_sec_user_samelogin_different_name
		) 
and src.facility_id = 45--23 rows


--select *  
--INTO pcc_temp_storage.dbo.EIcase01079812_CIT_sec_user_sameloginname
--from #temp t where userid NOT IN (select userid from pcc_temp_storage.dbo.EIcase01079812_CIT_sec_user_samelogin_different_name)

--select * from pcc_temp_storage.dbo.EIcase01079812_CIT_sec_user_sameloginname
--select * from pcc_temp_storage.dbo.EIcase01079812_CIT_sec_user_samelogin_different_name

--select * from .dbo.sec_user where loginname like '%FVE' and fac_id = 1


--================================
--Step 3. Update table for testing
--================================
ALTER TABLE dbo.EICase01079812sec_user
add corporate char
go

update dbo.EICase01079812sec_user
set corporate = 'N'--116

--INSERT INTO dbo.EICase01079812sec_user (src_id,dst_id,corporate)
--values (-998,-998,'Y')		--1

--INSERT INTO dbo.EICase01079812sec_user (src_id,dst_id,corporate)
--values (-10000,-10000,'Y')	--1

INSERT INTO dbo.EICase01079812sec_user (src_id,dst_id,corporate)
values (1,1,'Y')	--1


--============================================================================
--Step 4. Import users with same login and same name by adding mapping
--============================================================================
--mapping table
--select * from  dbo.EIcase01079812sec_user--338

select  a.* into pcc_temp_storage.dbo.EIcase01079812_CIT_sec_user_samelogin_same_name
--select b.userid,a.fac_id, b.fac_id,a.long_username src_username, b.long_username dst_username, a.loginname, b.loginname,b.admin_user_type, * 
from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.dbo.sec_user a
join sec_user b
on a.loginname = b.loginname--111
where a.fac_id = 45--94
and a.loginname not like '%pcc-%' and a.loginname  not like '%wescom%'
and a.long_username = b.long_username --41
and b.created_by not like 'EICase01079812' --373


insert  into pcc_temp_storage.dbo.EIcase01079812_CIT_sec_user_samelogin_same_name
select a.*
--select b.userid,a.fac_id, b.fac_id,a.long_username src_username, b.long_username dst_username, a.loginname, b.loginname,b.admin_user_type, * 
from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.dbo.sec_user a
join sec_user b
on a.loginname = b.loginname--111
where a.userid in (select userid from pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45 )--94
and a.loginname not like '%pcc-%' and a.loginname  not like '%wescom%'
and a.long_username = b.long_username --1
and b.created_by not like 'EICase01079812' --373


update map
set dst_id = ur.userid, corporate='Y'
--select map.src_id, ln.userid, map.dst_id, ur.userid, * 
FROM dbo.EIcase01079812sec_user map 
JOIN pcc_temp_storage.dbo.EIcase01079812_CIT_sec_user_samelogin_same_name ln ON ln.userid = map.src_id
JOIN sec_user ur ON ln.loginname = ur.loginname--42


----------For sec_user_physical_id

--select * into pcc_temp_storage.dbo.EIcase01079812_CIT_sec_user_physical_id_bkp

INSERT INTO sec_user_physical_id (
	userid
	,sequence
	,physicalid
	)
SELECT b.dst_id
	,[sequence]
	,[physicalid]
FROM [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].sec_user_physical_id src
JOIN dbo.EICase01079812sec_user b ON b.src_id = src.userid  
where b.corporate = 'N'


update sec_user
set admin_user_type = 'E'
--select * 
FROM dbo.sec_user  
where loginname like '[_]api[_]%'
and (created_by like '%EICase01079812%' or userid in (select dst_id from EIcase01079812sec_user where corporate = 'N'))
and admin_user_type is NULL
/*
Test

(57 rows affected)

(10 rows affected)

(756 rows affected)

(756 rows affected)

(690 rows affected)

(671 rows affected)

(671 rows affected)

(43 rows affected)

(10 rows affected)

(52 rows affected)

(45 rows affected)

(45 rows affected)

(756 rows affected)

(1 row affected)

(14 rows affected)

(0 rows affected)

(14 rows affected)

(0 rows affected)

(0 rows affected)

Completion time: 2022-03-01T15:11:05.7944832-05:00

*/




/*
Go live

(58 rows affected)

(10 rows affected)

(757 rows affected)

(757 rows affected)

(690 rows affected)

(670 rows affected)

(670 rows affected)

(44 rows affected)

(10 rows affected)

(53 rows affected)

(46 rows affected)

(46 rows affected)

(757 rows affected)

(1 row affected)

(14 rows affected)

(0 rows affected)

(14 rows affected)

(0 rows affected)

(0 rows affected)

Completion time: 2022-03-10T10:43:16.7482125-05:00


*/
