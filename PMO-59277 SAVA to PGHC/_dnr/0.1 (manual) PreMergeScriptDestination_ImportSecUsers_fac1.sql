--for testing run on [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net]
--for production run on [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net]
--not ran by automation - manual run once,,, if for some reason dest restored again then re-run manually

USE test_usei1214
--GO

--USE us_pghc_multi
--GO

--if NO sec user pre import, comment the entire script

print  CHAR(13) + 'Starting to run script : cp_sec_user_audit - rescoping for fac 183' 

if OBJECT_ID ('pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183','U') is not null
drop table pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183

select * into pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183 
--select *
from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].sec_user with (nolock)
where userid in 
(select userid from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].cp_sec_user_audit  with (nolock) 
where cp_sec_user_audit_id  in (select created_user_audit_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].as_footnote with (nolock)
where client_id in (select client_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].clients with (nolock) where fac_id = 183)) and fac_id <> 183)
and fac_id <> 183 

insert into pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183 
select distinct s.* 
from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_admin_order a with (nolock)
join [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_phys_order b with (nolock) on a.phys_order_id=b.phys_order_id
join [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].sec_user s  with (nolock) on a.noted_by=s.userid
where b.fac_id = 183 and s.fac_id <> 183 --0

insert into pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183 
select distinct * from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].sec_user with (nolock)
where userid in (SELECT distinct a.userid FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].cp_sec_user_audit a with (nolock)
JOIN [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_phys_order_useraudit b with (nolock) on a.cp_sec_user_audit_id = b.created_by_audit_id 
JOIN [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_phys_order c with (nolock) on b.phys_order_id = c.phys_order_id 
WHERE c.fac_id = 183)  
and fac_id <> 183 

insert into pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183 
select distinct * from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].sec_user b with (nolock)
where userid in 
(select userid from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].cp_sec_user_audit with (nolock) where cp_sec_user_audit_id in 
(select created_by_audit_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_std_order_set with (nolock) where  fac_id  in (-1,183)
union 
select revision_by_audit_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_std_order_set with (nolock) where  fac_id  in (-1,183)
union 
select published_by_audit_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_std_order_set with (nolock) where  fac_id  in (-1,183)
union 
select retired_by_audit_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_std_order_set with (nolock) where fac_id  in (-1,183)
union 
select reactivated_by_audit_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_std_order_set with (nolock) where  fac_id  in (-1,183))
and fac_id <> 183)
and fac_id <> 183 

insert into pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183 
select distinct  * from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].sec_user b with (nolock)
where userid in 
(select userid from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].cp_sec_user_audit with (nolock) where cp_sec_user_audit_id in 
(select created_by_audit_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_std_order with (nolock) where  fac_id  in (-1,183)
union 
select revision_by_audit_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_std_order with (nolock) where  fac_id  in (-1,183)
union 
select published_by_audit_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_std_order with (nolock) where  fac_id  in (-1,183)
union 
select retired_by_audit_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_std_order with (nolock) where  fac_id  in (-1,183)
union 
select reactivated_by_audit_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_std_order with (nolock) where  fac_id  in (-1,183))
and fac_id <> 183)
and fac_id <> 183 

insert into pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183 
select distinct * from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].sec_user with (nolock)
where userid in (SELECT distinct a.userid FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].cp_sec_user_audit a with (nolock)
JOIN [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].allergy b with (nolock) on a.cp_sec_user_audit_id = b.created_user_audit_id 
where b.client_id in (select client_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].clients with (nolock) where fac_id = 183))  
and userid not in (-10000, -998)
and fac_id <> 183 

insert into pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183 
select distinct * from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].sec_user with (nolock)
where userid in (SELECT distinct a.userid FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].cp_sec_user_audit a with (nolock)
JOIN [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].allergy b with (nolock) on a.cp_sec_user_audit_id = b.revision_user_audit_id 
where b.client_id in (select client_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].clients with (nolock) where fac_id = 183))  
and userid not in (-10000, -998)
and fac_id <> 183 

insert into pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183 
select distinct * from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].sec_user with (nolock)
where userid in (SELECT distinct a.userid FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].cp_sec_user_audit a with (nolock)
JOIN [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].allergy_audit b with (nolock) on a.cp_sec_user_audit_id = b.created_user_audit_id 
where b.client_id in (select client_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].clients with (nolock) where fac_id = 183))  
and userid not in (-10000, -998)
and fac_id <> 183 

insert into pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183 
select distinct * from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].sec_user with (nolock)
where userid in (SELECT distinct a.userid FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].cp_sec_user_audit a with (nolock)
JOIN [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].allergy_audit b with (nolock) on a.cp_sec_user_audit_id = b.revision_user_audit_id 
where b.client_id in (select client_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].clients with (nolock) where fac_id = 183))  
and userid not in (-10000, -998)
and fac_id <> 183 

insert into pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183 
select distinct * from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].sec_user with (nolock)
where userid in (select userid from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in  (select  sec_user_audit_id from  [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].immunization_strikeout with (nolock)
where immunization_id in (select  immunization_id  from  [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].cr_client_immunization with (nolock)
where fac_id = 183)) and  fac_id <> 183)
and fac_id <> 183

insert into pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183 
select distinct s.*
from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].mpi_history b with (nolock)
join [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].sec_user s with (nolock) on b.user_id=s.userid
left join [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].sec_user_facility f with (nolock) on b.user_id=f.userid
where b.fac_id = 183 and s.fac_id <> 183 and (facility_id= 183 or admin_user_type ='E') 

------scope for sec_user as well
insert into pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183 
select distinct * from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].sec_user with (nolock)
where userid in (select userid from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in  (select  sec_user_audit_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].immunization_strikeout with (nolock)
where immunization_id in (select  immunization_id  from   [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].cr_client_immunization with (nolock)
where fac_id in (183)))
and  fac_id not in (183))
and fac_id not in (183) 

insert into pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183 
select distinct * from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].sec_user with (nolock)
where userid in  (select  administered_by_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].cr_client_immunization with (nolock)
where fac_id in (183))
and  fac_id not in (183)

insert into pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183 
select distinct * from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].sec_user with (nolock)
where userid in  (select  administered_by_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].cr_client_immunization_audit with (nolock)
where fac_id in (183))
and  fac_id not in (183)

insert into pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183 
select distinct * from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].sec_user with (nolock)
where userid in (select userid from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id  in (select strikeout_user_audit_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].allergy_strikeout s with (nolock)
JOIN [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].allergy b with (nolock) on s.allergy_id = b.allergy_id 
where client_id in (select client_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].clients with (nolock) where fac_id in (183)))
and fac_id not in (183))
and fac_id not in (183)

insert into pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183 
select distinct * from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].sec_user with (nolock)
where userid in (select userid from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id  in (select strikeout_user_audit_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].diagnosis_strikeout with (nolock)
where client_diagnosis_id in (select client_diagnosis_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].diagnosis with (nolock) where fac_id in (183)))
and fac_id not in (183))
and fac_id not in (183)

insert into pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183 
select distinct * from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].sec_user with (nolock)
where userid in (select userid from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in (
	select created_by_audit_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_admin_order_useraudit a with (nolock)
	JOIN [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_admin_order b with (nolock) on a.admin_order_id = b.admin_order_id 
	JOIN [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_phys_order c with (nolock) on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id = 183 
union 
	select edited_by_audit_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_admin_order_useraudit a with (nolock)
	JOIN [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_admin_order b with (nolock) on a.admin_order_id = b.admin_order_id 
	JOIN [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_phys_order c with (nolock) on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id = 183 
union 
	select confirmed_by_audit_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_admin_order_useraudit a with (nolock)
	JOIN [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_admin_order b with (nolock) on a.admin_order_id = b.admin_order_id 
	JOIN [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_phys_order c with (nolock) on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id = 183 
) and fac_id <> 183)
and fac_id <> 183

insert into pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183 
select distinct * from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].sec_user with (nolock)
where userid in (select userid from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in (
	select created_by_audit_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_admin_order_useraudit a with (nolock)
	JOIN [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_admin_order_audit b with (nolock) on a.admin_order_id = b.admin_order_id 
	JOIN [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_phys_order c with (nolock) on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id = 183 
union 
	select edited_by_audit_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_admin_order_useraudit a with (nolock)
	JOIN [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_admin_order_audit b with (nolock) on a.admin_order_id = b.admin_order_id 
	JOIN [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_phys_order c with (nolock) on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id = 183 
union 
	select confirmed_by_audit_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_admin_order_useraudit a with (nolock)
	JOIN [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_admin_order_audit b with (nolock) on a.admin_order_id = b.admin_order_id 
	JOIN [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_phys_order c with (nolock) on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id = 183 
) and fac_id <> 183)
and fac_id <> 183 

insert into pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183 
select distinct * from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].sec_user s with (nolock)
where userid in (select userid from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].cp_sec_user_audit with (nolock) where cp_sec_user_audit_id in 
(SELECT distinct followupby_useraudit_id FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_schedule_details_followup_useraudit b with (nolock)
JOIN [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_schedule_details c with (nolock) on b.schedule_detail_id = c.pho_schedule_detail_id
JOIN [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_schedule d with (nolock) ON d.schedule_id=c.pho_schedule_id
WHERE d.fac_id = 183)  
and fac_id <> 183)
and fac_id <> 183

insert into pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183 
SELECT DISTINCT *
FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].sec_user s WITH (NOLOCK)
WHERE userid IN (
		SELECT userid
		FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].cp_sec_user_audit WITH (NOLOCK)
		WHERE cp_sec_user_audit_id IN (
				SELECT followupby_useraudit_id
				FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_schedule_details_followup_useraudit b WITH (NOLOCK)
				WHERE schedule_detail_id IN (
						SELECT pho_schedule_detail_id
						FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_schedule_details c WITH (NOLOCK)
						WHERE pho_schedule_id IN (
								SELECT schedule_id
								FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_schedule d WITH (NOLOCK)
								WHERE fac_id = 183)))
			AND fac_id <> 183
		) AND fac_id <> 183

insert into pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183 
SELECT distinct * from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].sec_user s with (nolock)
where userid in (select userid from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in (select cp_sec_user_audit_id FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_phys_order_sign with (nolock)
WHERE phys_order_id IN (SELECT distinct phys_order_id FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_phys_order with (nolock) WHERE fac_id = 183))
AND fac_id <> 183)
and fac_id <> 183

insert into pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183 
select distinct * from [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.sec_user with (nolock)
where userid in (select userid from [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.cp_sec_user_audit with (nolock) where cp_sec_user_audit_id in 
(select created_cp_sec_user_audit_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.pho_formulary_item_custom_library with (nolock)
where custom_drug_id in (select custom_drug_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.cr_cust_med with (nolock) where fac_id in (-1,183))
union
select revision_cp_sec_user_audit_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.pho_formulary_item_custom_library with (nolock)
where custom_drug_id in (select custom_drug_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.cr_cust_med with (nolock) where fac_id in (-1,183))) 
and fac_id not in (-1,183) 
and cp_sec_user_audit_id not in (-998,-10000))
and fac_id <> 183 

insert into pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183 
select distinct * from [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.sec_user with (nolock)
where userid in (select userid from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in (
SELECT DISTINCT b.created_by_audit_id
FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_phys_order_audit_useraudit b with (nolock)
JOIN [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].cp_sec_user_audit ba with (nolock) ON b.created_by_audit_id = ba.cp_sec_user_audit_id
join [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.pho_phys_order_useraudit pa with (nolock) on pa.created_by_audit_id = ba.cp_sec_user_audit_id
JOIN [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_phys_order c with (nolock) ON pa.phys_order_id = c.phys_order_id
WHERE c.fac_id IN (183))
and fac_id not in (183)
and userid not in (-998,-10000)) 

insert into pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183 
select * from [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.sec_user with (nolock)
where userid in (select userid from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in (
SELECT DISTINCT b.edited_by_audit_id
FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_phys_order_audit_useraudit b with (nolock)
JOIN [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].cp_sec_user_audit ba with (nolock) ON b.edited_by_audit_id = ba.cp_sec_user_audit_id
join [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.pho_phys_order_useraudit pa with (nolock) on pa.edited_by_audit_id = ba.cp_sec_user_audit_id
JOIN [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_phys_order c with (nolock) ON pa.phys_order_id = c.phys_order_id
WHERE c.fac_id IN (183))
and fac_id not in (183)
and userid not in (-998,-10000))

insert into pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183 
select * from [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.sec_user with (nolock)
where userid in (select userid from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in (
SELECT DISTINCT b.confirmed_by_audit_id
FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_phys_order_audit_useraudit b with (nolock)
JOIN [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].cp_sec_user_audit ba with (nolock) ON b.confirmed_by_audit_id = ba.cp_sec_user_audit_id
join [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.pho_phys_order_useraudit pa with (nolock) on pa.confirmed_by_audit_id = ba.cp_sec_user_audit_id
JOIN [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].pho_phys_order c with (nolock) ON pa.phys_order_id = c.phys_order_id
WHERE c.fac_id IN (183))
and fac_id not in (183)
and userid not in (-998,-10000))

insert into pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183 
select distinct s.*
from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].inc_incident a with (nolock)
join [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].sec_user s with (nolock) on a.strikeout_by_id = s.userid
where a.fac_id = 183 and s.fac_id <> 183

delete from pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183  where loginname like '%pcc-%' 

print  CHAR(13) + 'Ended running : cp_sec_user_audit - rescoping for fac 183' 

print  CHAR(13) + 'Starting to run script : import GAP of security users for fac 183' 

if OBJECT_ID ('pcc_temp_storage.dbo.EIcase59277183_PGHC_sec_user_backup','U') is not null
select * into pcc_temp_storage.dbo.EIcase59277183_PGHC_sec_user_backup from sec_user

if OBJECT_ID ('pcc_temp_storage.dbo.EIcase59277183_PGHC_sec_user_facility_backup','U') is not null
select * into pcc_temp_storage.dbo.EIcase59277183_PGHC_sec_user_facility_backup from sec_user_facility

if OBJECT_ID ('pcc_temp_storage.dbo.EIcase59277183_PGHC_sec_user_physical_id_backup','U') is not null
select * into pcc_temp_storage.dbo.EIcase59277183_PGHC_sec_user_physical_id_backup from sec_user_physical_id

if OBJECT_ID ('pcc_temp_storage.dbo.EIcase59277183_PGHC_sec_user_sameloginname','U') is not null
DROP TABLE pcc_temp_storage.dbo.EIcase59277183_PGHC_sec_user_sameloginname

if OBJECT_ID ('pcc_temp_storage.dbo.EIcase59277183_PGHC_sec_user_samelogin_different_name','U') is not null
DROP TABLE pcc_temp_storage.dbo.EIcase59277183_PGHC_sec_user_samelogin_different_name

if OBJECT_ID ('pcc_temp_storage.dbo.EIcase59277183_PGHC_sec_user_samelogin_same_name','U') is not null
DROP TABLE pcc_temp_storage.dbo.EIcase59277183_PGHC_sec_user_samelogin_same_name

if OBJECT_ID ('dbo.EIcase59277183sec_user','U') is not null
DROP TABLE dbo.EIcase59277183sec_user

--=========================================================
--Step 1. Import users that have different loginname
--a. Create backup for users with same loginname
--b. Import users
--=========================================================

select  a.* into pcc_temp_storage.dbo.EIcase59277183_PGHC_sec_user_sameloginname
--select a.*
from [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.sec_user a
join dbo.sec_user b 
on a.loginname = b.loginname
where a.fac_id = 183 
and a.loginname not like '%pcc-%' 
and a.loginname  not like '%wescom%'

insert into pcc_temp_storage.dbo.EIcase59277183_PGHC_sec_user_sameloginname
select a.*
from [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.sec_user a
join dbo.sec_user b
on a.loginname = b.loginname
where a.userid in (select userid from pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183) 
and a.loginname not like '%pcc-%' 
and a.loginname  not like '%wescom%'

declare @MaxSecUserid int, @Rowcount int, @facid int

select identity(int,0,1) as row_id, src.userid as src_id, NULL as dst_id
into dbo.EIcase59277183sec_user 
--select *
from [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.sec_user src 
where (fac_id = 183 or userid in(select userid from pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183))
and loginname not like '%pcc-%' and loginname  not like '%wescom%' 

set @Rowcount=@@rowcount
exec get_next_primary_key 'sec_user','userid',@MaxSecUserid output , @Rowcount

update  dbo.EIcase59277183sec_user  
set  dst_id = row_id+@MaxSecUserid

--==========================================================================

INSERT INTO dbo.sec_user
SELECT map.dst_id
	,173   
	,'EICase59277183'
	,getdate()
	,'EICase59277183'
	,getdate()
	,504954271   
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
	,default_admin_view
	,sso_only_user
FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.sec_user src
JOIN dbo.EIcase59277183sec_user map ON src.userid = map.src_id
WHERE src.userid NOT IN (SELECT userid FROM pcc_temp_storage.dbo.EIcase59277183_PGHC_sec_user_sameloginname)

INSERT INTO dbo.sec_user_facility (userid,facility_id,access_level)
SELECT DISTINCT a.dst_id
	,173  
	,src.access_level
FROM dbo.EIcase59277183sec_user a join [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.sec_user_facility src
on a.src_id = src.userid
WHERE src.userid NOT IN (SELECT userid FROM pcc_temp_storage.dbo.EIcase59277183_PGHC_sec_user_sameloginname) 
and src.facility_id = 183

--==================================================================================
--Step 2. Import users with same loginname but different long_username adding suffix
--==================================================================================

select  a.* into pcc_temp_storage.dbo.EIcase59277183_PGHC_sec_user_samelogin_different_name
from [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.sec_user a
join dbo.sec_user b
on a.loginname = b.loginname
where a.fac_id = 183
and a.loginname not like '%pcc-%' and a.loginname  not like '%wescom%'
and a.long_username <> b.long_username

insert into pcc_temp_storage.dbo.EIcase59277183_PGHC_sec_user_samelogin_different_name
select a.*
from [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.sec_user a
join dbo.sec_user b
on a.loginname = b.loginname
where a.userid in (select userid from pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183)--94 
and a.loginname not like '%pcc-%' and a.loginname  not like '%wescom%'
and a.long_username <> b.long_username

INSERT INTO dbo.sec_user
SELECT map.dst_id
	,173  
	,'EICase59277183'
	,getdate()
	,'EICase59277183'
	,getdate()
	,504954271   
	,long_username
	,staff_id
	,loginname + 'SAVA' 
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
	,default_admin_view
	,sso_only_user
FROM  [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.sec_user src 
JOIN dbo.EIcase59277183sec_user map ON src.userid = map.src_id
and src_id IN (select userid from pcc_temp_storage.dbo.EIcase59277183_PGHC_sec_user_samelogin_different_name)

INSERT INTO dbo.sec_user_facility (userid,facility_id,access_level)
SELECT DISTINCT a.dst_id
	,173   
	,src.access_level
FROM dbo.EIcase59277183sec_user a join [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.sec_user_facility src
on a.src_id = src.userid
JOIN pcc_temp_storage.dbo.EIcase59277183_PGHC_sec_user_samelogin_different_name t on src.userid = t.userid
WHERE src.userid IN (SELECT userid FROM pcc_temp_storage.dbo.EIcase59277183_PGHC_sec_user_samelogin_different_name) 
and src.facility_id = 183

--================================
--Step 3. Update table for testing
--================================
ALTER TABLE dbo.EICase59277183sec_user
add corporate char
GO

update dbo.EICase59277183sec_user
set corporate = 'N'

INSERT INTO dbo.EICase59277183sec_user (src_id,dst_id,corporate)
values (1,1,'Y')	

--============================================================================
--Step 4. Import users with same login and same name by adding mapping
--============================================================================

select  a.* into pcc_temp_storage.dbo.EIcase59277183_PGHC_sec_user_samelogin_same_name
from [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.sec_user a
join dbo.sec_user b
on a.loginname = b.loginname
where a.fac_id = 183
and a.loginname not like '%pcc-%' and a.loginname  not like '%wescom%'
and a.long_username = b.long_username 
and b.created_by not like 'EICase59277183' 

insert  into pcc_temp_storage.dbo.EIcase59277183_PGHC_sec_user_samelogin_same_name
select a.*
from [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.sec_user a
join dbo.sec_user b
on a.loginname = b.loginname
where a.userid in (select userid from pcc_temp_storage.dbo._bkp_PMO59277_Case59277183_sec_user_import_pre_scoping_fac_183)
and a.loginname not like '%pcc-%' and a.loginname  not like '%wescom%'
and a.long_username = b.long_username
and b.created_by not like 'EICase59277183' 

update map
set dst_id = ur.userid, corporate='Y'
FROM dbo.EIcase59277183sec_user map 
JOIN pcc_temp_storage.dbo.EIcase59277183_PGHC_sec_user_samelogin_same_name ln ON ln.userid = map.src_id
JOIN sec_user ur ON ln.loginname = ur.loginname

INSERT INTO sec_user_physical_id (userid,sequence,physicalid)
SELECT b.dst_id
	,[sequence]
	,[physicalid]
FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].sec_user_physical_id src
JOIN dbo.EICase59277183sec_user b ON b.src_id = src.userid  
AND b.corporate = 'N'

update dst
set enabled = 'N'
--select dst.userid, dst.fac_id, dst.loginname, src.userid, src.fac_id,src.loginname, src.admin_user_type
from sec_user dst
join EIcase59277183sec_user m 
on dst.userid = m.dst_id
join [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].sec_user src
on src.userid = m.src_id
where (src.admin_user_type <> 'E' or src.admin_user_type is NULL) 
and not exists (select 1 from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].sec_user_facility f 
				where src.userid = f.userid and f.facility_id = 183)
				and dst.enabled = 'Y'
and src.fac_id not in (183)


update dst
set fac_id = lm.dstFacID
--select dst.userid, dst.fac_id, dst.loginname, src.userid, src.fac_id,src.loginname, src.admin_user_type, lm.srcFacID, lm.dstFacID
--select dst.*
from sec_user dst
join EIcase59277183sec_user m --sec_user mapping table
on dst.userid = m.dst_id
join [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].sec_user src  with (nolock)--source DB
on src.userid = m.src_id
join [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac lm
on PMO_number = '59277' and lm.srcFacID = src.fac_id
where (src.admin_user_type <> 'E' or src.admin_user_type is NULL) 
and not exists 
(select 1 from [sqluspaw29cli01.pccprod.local].us_sava_multi.[dbo].sec_user_facility f with (nolock)
where src.userid = f.userid and f.facility_id = 183)
and src.fac_id <> 183


update sec_user
set admin_user_type = 'E'
--select * 
FROM dbo.sec_user  
where loginname like '[_]api[_]%'
and (created_by like '%EIcase59277183%' or userid in (select dst_id from EIcase59277183sec_user where corporate = 'N'))
and admin_user_type is NULL

print  CHAR(13) + 'Ended running script : import GAP of security users for fac 183' 

/* Latest Test Results



*/

/* PROD Import Results



*/