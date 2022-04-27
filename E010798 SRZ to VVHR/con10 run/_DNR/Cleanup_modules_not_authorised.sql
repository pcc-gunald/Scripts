Select * from facility where fac_id =1

Select * from cr_alert where fac_id =1

 
--begin tran
--commit tran

--to update

/* Drop statements:
drop table  pcc_temp_Storage.dbo._bkp_EIcase010798cr_alert_triggered_item_type_category
drop table  pcc_temp_Storage.dbo._bkp_EIcase010798cr_alert
drop table  pcc_temp_Storage.dbo._bkp_EIcase010798cr_client_highrisk_alerts
drop table  pcc_temp_Storage.dbo._bkp_EIcase010798cr_std_alert
drop table  pcc_temp_Storage.dbo._bkp_EIcase010798cr_std_alert_complex
drop table  pcc_temp_Storage.dbo._bkp_EIcase010798cr_std_highrisk_desc

*/


/************************************************************
-------------   Cleanup script for alerts module ------------
Involved tables:
cr_alert_triggered_item_type_category
cr_Alert
cr_client_highrisk_alerts
cr_std_alert
cr_std_alert_complex
cr_std_highrisk_desc

************************************************************/

----***Note: investigation portion of script is below, check in mergejoins prior to cleanup to see if any
---additional tables should be cleaned up

--begin tran

----Cleanups:

-------First, clean up data tied to residents:


update cr_alert
set deleted = 'Y', deleted_by = 'EIcase010798', deleted_date = GETDATE() --(12418 row(s) affected)
--select * 
from cr_alert 
where deleted <> 'Y'
and fac_id =1
--9425
 
delete
--select * from 
cr_client_highrisk_alerts 
where fac_id =1

(14 rows affected)
 
update cr_std_alert
set deleted = 'Y', deleted_by = 'EIcase010798', deleted_date = GETDATE()
--select * from cr_std_alert --soft delete
where created_by not like 'pcc-%' 
and created_by not like 'CORE-%' 
--and created_by not like 'case%' 
and deleted <> 'Y' 
and fac_id=1
--14
--6

IF OBJECT_ID('pcc_temp_Storage.dbo._bkp_EIcase010798cr_std_alert_complex', 'U') IS NOT NULL 
  DROP TABLE pcc_temp_Storage.dbo._bkp_EIcase010798cr_std_alert_complex; 
--complex alerts
select * into pcc_temp_Storage.dbo._bkp_EIcase010798cr_std_alert_complex from cr_std_alert_complex --3
delete
--select * from 
cr_std_alert_complex
WHERE std_alert_id IN (SELECT std_alert_id FROM cr_std_alert WHERE deleted = 'Y'and fac_id=1) 
-- Added by Mark on Mar 5 2018, as per Rina
--6

IF OBJECT_ID('pcc_temp_Storage.dbo._bkp_EIcase010798cr_std_highrisk_desc', 'U') IS NOT NULL 
  DROP TABLE pcc_temp_Storage.dbo._bkp_EIcase010798cr_std_highrisk_desc; 
select * into pcc_temp_Storage.dbo._bkp_EIcase010798cr_std_highrisk_desc from cr_std_highrisk_desc --984
update cr_std_highrisk_desc
set deleted = 'Y', deleted_by = 'EIcase010798', deleted_date = GETDATE() --, std_alert_id = null --
--select * from cr_std_highrisk_desc
where 
(
    std_alert_id IN (SELECT std_alert_id FROM cr_std_alert WHERE deleted = 'Y'
	and fac_id=1) -- Added by Mark on Mar 5 2018, as per Rina
    OR (created_by NOT LIKE 'pcc-%' AND created_by NOT LIKE 'CORE-%')
)
and deleted <> 'Y' --soft delete
and fac_id=1
--171


-- cp_std_trigger
-- Added by Mark on Mar 5 2018, as per Rina
IF OBJECT_ID('pcc_temp_storage.dbo._bkp_EICase1109023cp_std_trigger', 'U') IS NOT NULL
   DROP TABLE pcc_temp_storage.dbo._bkp_EICase1109023cp_std_trigger
SELECT * INTO pcc_temp_storage.dbo._bkp_EICase1109023cp_std_trigger FROM cp_std_trigger

UPDATE cp_std_trigger
SET deleted = 'Y'
    , deleted_by = 'Case1109023'
    , deleted_date = GETDATE()
--SELECT * FROM cp_std_trigger
WHERE triggered_item_id IN (SELECT std_alert_id FROM cr_std_alert WHERE deleted = 'Y'
and fac_id =1)
       AND trigger_type = 'A'
       AND deleted <> 'Y'
--0
--print '---Ask Rina about these----' -- covered in fix for step 10, 10.1
--delete
----select * from
--cr_std_alert_activation_audit --(28899 row(s) affected)

--delete
----select * from
--cr_std_alert_activation --(27539 row(s) affected)

---added by GF 8/27/2018 to keep activation tables consistent with cr_std_alert
IF OBJECT_ID('pcc_temp_storage.dbo._bkp_EICase1109023cr_std_alert_activation_audit', 'U') IS NOT NULL
   DROP TABLE pcc_temp_storage.dbo._bkp_EICase1109023cr_std_alert_activation_audit
SELECT * INTO pcc_temp_storage.dbo._bkp_EICase1109023cr_std_alert_activation_audit FROM cr_std_alert_activation_audit

delete cr_std_alert_activation_audit
--select * from cr_std_alert_activation_audit
where std_alert_id in (select std_alert_id from cr_std_alert where deleted = 'Y' and fac_id =1)

(1 row affected)

IF OBJECT_ID('pcc_temp_storage.dbo._bkp_EICase1109023cr_std_alert_activation', 'U') IS NOT NULL
   DROP TABLE pcc_temp_storage.dbo._bkp_EICase1109023cr_std_alert_activation
SELECT * INTO pcc_temp_storage.dbo._bkp_EICase1109023cr_std_alert_activation FROM cr_std_alert_activation

delete cr_std_alert_activation
--select * from cr_std_alert_activation
where std_alert_id in (select std_alert_id from cr_std_alert where deleted = 'Y'
and fac_id =1)

(1 row affected)

/*

*/
Select * from ta_client_account where fac_id =1
DELETE FROM dbo.ta_client_account where fac_id =1
------DELETE FROM dbo.ta_client_configuration
Select * from ta_client_income_source where fac_id =1
DELETE FROM dbo.ta_client_income_source where fac_id =1

(4 rows affected)

------DELETE FROM dbo.ta_configuration
Select * from ta_configuration_audit where fac_id =1
DELETE FROM dbo.ta_configuration_audit where fac_id =1

(1319 rows affected)

Select * from ta_control_account where fac_id =1
update ta_control_account
set deleted='Y'
where fac_id =1

(4 rows affected)
--DELETE FROM dbo.ta_control_account
----DELETE FROM dbo.ta_income_source
----DELETE FROM dbo.ta_item_type
Select * from ta_statement where fac_id =1

DELETE FROM dbo.ta_statement where fac_id =1

(1401 rows affected)
----DELETE FROM dbo.ta_std_account
DELETE FROM dbo.ta_transaction where fac_id =1

(664 rows affected)
DELETE FROM dbo.ta_vendor where fac_id =1

(0 rows affected)
DELETE FROM dbo.ta_batch where fac_id =1
(1235 rows affected)

Delete from admin_Note where client_id in (Select client_id from clients where fac_id =1)-- No records in Template Db

(1781 rows affected)


Delete from admin_Note_type
where description NOT IN ('Authorizations') -- Default Template DB Description
and fac_id =1
--(5 row(s) affected)
