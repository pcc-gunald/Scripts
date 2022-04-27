select * into pcc_temp_storage.dbo._bkp_EICase590132_sec_user_import_pre_scoping_fac_32
from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].sec_user with (nolock)
where userid in 
(select userid from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].cp_sec_user_audit  with (nolock) 
where cp_sec_user_audit_id  in (select created_user_audit_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].as_footnote with (nolock)
where client_id in (select client_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].clients with (nolock) where fac_id = 32)) and fac_id <> 32)
and fac_id <> 32
sproc_facacq_pre_sec_user_Import_01_scoping - sec_user in as_footnote0 affected rows
insert into pcc_temp_storage.dbo._bkp_EICase590132_sec_user_import_pre_scoping_fac_32
select distinct s.* 
from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_admin_order a with (nolock)
join [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_phys_order b with (nolock) on a.phys_order_id=b.phys_order_id
join [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].sec_user s  with (nolock) on a.noted_by=s.userid
where b.fac_id = 32 and s.fac_id <> 32
sproc_facacq_pre_sec_user_Import_01_scoping - sec_user in pho_phys_order0 affected rows
insert into pcc_temp_storage.dbo._bkp_EICase590132_sec_user_import_pre_scoping_fac_32
select distinct * from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].sec_user with (nolock)
where userid in (SELECT distinct a.userid FROM [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].cp_sec_user_audit a with (nolock)
JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_phys_order_useraudit b with (nolock) on a.cp_sec_user_audit_id = b.created_by_audit_id 
JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_phys_order c with (nolock) on b.phys_order_id = c.phys_order_id 
WHERE c.fac_id = 32)  
and fac_id <> 32
sproc_facacq_pre_sec_user_Import_01_scoping - sec_user in pho_phys_order0 affected rows
insert into pcc_temp_storage.dbo._bkp_EICase590132_sec_user_import_pre_scoping_fac_32
select distinct * from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].sec_user b with (nolock)
where userid in 
(select userid from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].cp_sec_user_audit with (nolock) where cp_sec_user_audit_id in 
(select created_by_audit_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_std_order_set with (nolock) where  fac_id  in (-1,32)
union 
select revision_by_audit_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_std_order_set with (nolock) where  fac_id  in (-1,32)
union 
select published_by_audit_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_std_order_set with (nolock) where  fac_id  in (-1,32)
union 
select retired_by_audit_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_std_order_set with (nolock) where fac_id  in (-1,32)
union 
select reactivated_by_audit_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_std_order_set with (nolock) where  fac_id  in (-1,32))
and fac_id <> 32)
and fac_id <> 32
sproc_facacq_pre_sec_user_Import_01_scoping - sec_user in pho_std_order_set17 affected rows
insert into pcc_temp_storage.dbo._bkp_EICase590132_sec_user_import_pre_scoping_fac_32
select distinct  * from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].sec_user b with (nolock)
where userid in 
(select userid from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].cp_sec_user_audit with (nolock) where cp_sec_user_audit_id in 
(select created_by_audit_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_std_order with (nolock) where  fac_id  in (-1,32)
union 
select revision_by_audit_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_std_order with (nolock) where  fac_id  in (-1,32)
union 
select published_by_audit_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_std_order with (nolock) where  fac_id  in (-1,32)
union 
select retired_by_audit_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_std_order with (nolock) where  fac_id  in (-1,32)
union 
select reactivated_by_audit_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_std_order with (nolock) where  fac_id  in (-1,32))
and fac_id <> 32)
and fac_id <> 32
sproc_facacq_pre_sec_user_Import_01_scoping - sec_user in pho_std_order19 affected rows
insert into pcc_temp_storage.dbo._bkp_EICase590132_sec_user_import_pre_scoping_fac_32
select distinct * from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].sec_user with (nolock)
where userid in (SELECT distinct a.userid FROM [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].cp_sec_user_audit a with (nolock)
JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].allergy b with (nolock) on a.cp_sec_user_audit_id = b.created_user_audit_id 
where b.client_id in (select client_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].clients with (nolock) where fac_id = 32))  
and userid not in (-10000, -998)
and fac_id <> 32
sproc_facacq_pre_sec_user_Import_01_scoping - sec_user in allergy1 affected rows
insert into pcc_temp_storage.dbo._bkp_EICase590132_sec_user_import_pre_scoping_fac_32
select distinct * from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].sec_user with (nolock)
where userid in (SELECT distinct a.userid FROM [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].cp_sec_user_audit a with (nolock)
JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].allergy b with (nolock) on a.cp_sec_user_audit_id = b.revision_user_audit_id 
where b.client_id in (select client_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].clients with (nolock) where fac_id = 32))  
and userid not in (-10000, -998)
and fac_id <> 32
sproc_facacq_pre_sec_user_Import_01_scoping - sec_user in allergy1 affected rows
insert into pcc_temp_storage.dbo._bkp_EICase590132_sec_user_import_pre_scoping_fac_32
select distinct * from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].sec_user with (nolock)
where userid in (SELECT distinct a.userid FROM [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].cp_sec_user_audit a with (nolock)
JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].allergy_audit b with (nolock) on a.cp_sec_user_audit_id = b.created_user_audit_id 
where b.client_id in (select client_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].clients with (nolock) where fac_id = 32))  
and userid not in (-10000, -998)
and fac_id <> 32
sproc_facacq_pre_sec_user_Import_01_scoping - sec_user in allergy_audit0 affected rows
insert into pcc_temp_storage.dbo._bkp_EICase590132_sec_user_import_pre_scoping_fac_32
select distinct * from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].sec_user with (nolock)
where userid in (SELECT distinct a.userid FROM [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].cp_sec_user_audit a with (nolock)
JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].allergy_audit b with (nolock) on a.cp_sec_user_audit_id = b.revision_user_audit_id 
where b.client_id in (select client_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].clients with (nolock) where fac_id = 32))  
and userid not in (-10000, -998)
and fac_id <> 32
sproc_facacq_pre_sec_user_Import_01_scoping - sec_user in allergy_audit0 affected rows
insert into pcc_temp_storage.dbo._bkp_EICase590132_sec_user_import_pre_scoping_fac_32
select distinct * from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].sec_user with (nolock)
where userid in (select userid from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in  (select  sec_user_audit_id from  [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].immunization_strikeout with (nolock)
where immunization_id in (select  immunization_id  from  [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].cr_client_immunization with (nolock)
where fac_id = 32)) and  fac_id <> 32)
and fac_id <> 32
sproc_facacq_pre_sec_user_Import_01_scoping - sec_user in immunization_strikeout0 affected rows
insert into pcc_temp_storage.dbo._bkp_EICase590132_sec_user_import_pre_scoping_fac_32
select distinct s.*
from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].mpi_history b with (nolock)
join [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].sec_user s with (nolock) on b.user_id=s.userid
left join [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].sec_user_facility f with (nolock) on b.user_id=f.userid
where b.fac_id = 32 and s.fac_id <> 32 and (facility_id= 32 or admin_user_type ='E') 
sproc_facacq_pre_sec_user_Import_01_scoping - sec_user in mpi_history3 affected rows
insert into pcc_temp_storage.dbo._bkp_EICase590132_sec_user_import_pre_scoping_fac_32
select distinct * from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].sec_user with (nolock)
where userid in (select userid from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in  (select  sec_user_audit_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].immunization_strikeout with (nolock)
where immunization_id in (select  immunization_id  from   [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].cr_client_immunization with (nolock)
where fac_id in (32)))
and  fac_id not in (32))
and fac_id not in (32) 

sproc_facacq_pre_sec_user_Import_01_scoping - sec_user in immunization_strikeout0 affected rows
insert into pcc_temp_storage.dbo._bkp_EICase590132_sec_user_import_pre_scoping_fac_32
select distinct * from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].sec_user with (nolock)
where userid in  (select  administered_by_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].cr_client_immunization with (nolock)
where fac_id in (32))
and  fac_id not in (32) 
sproc_facacq_pre_sec_user_Import_01_scoping - sec_user in cr_client_immunization0 affected rows
insert into pcc_temp_storage.dbo._bkp_EICase590132_sec_user_import_pre_scoping_fac_32
select distinct * from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].sec_user with (nolock)
where userid in  (select  administered_by_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].cr_client_immunization_audit with (nolock)
where fac_id in (32)) 
and  fac_id not in (32)

sproc_facacq_pre_sec_user_Import_01_scoping - sec_user in cr_client_immunization_audit0 affected rows
insert into pcc_temp_storage.dbo._bkp_EICase590132_sec_user_import_pre_scoping_fac_32
select distinct * from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].sec_user with (nolock)
where userid in (select userid from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id  in (select strikeout_user_audit_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].allergy_strikeout s with (nolock)
JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].allergy b with (nolock) on s.allergy_id = b.allergy_id 
where client_id in (select client_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].clients with (nolock) where fac_id in (32)))
and fac_id not in (32))
and fac_id not in (32)
sproc_facacq_pre_sec_user_Import_01_scoping - sec_user in allergy_strikeout0 affected rows
insert into pcc_temp_storage.dbo._bkp_EICase590132_sec_user_import_pre_scoping_fac_32
select distinct * from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].sec_user with (nolock)
where userid in (select userid from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id  in (select strikeout_user_audit_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].diagnosis_strikeout with (nolock)
where client_diagnosis_id in (select client_diagnosis_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].diagnosis with (nolock) where fac_id in (32)))
and fac_id not in (32))
and fac_id not in (32)
sproc_facacq_pre_sec_user_Import_01_scoping - sec_user in diagnosis_strikeout0 affected rows
insert into pcc_temp_storage.dbo._bkp_EICase590132_sec_user_import_pre_scoping_fac_32
select distinct * from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].sec_user with (nolock)
where userid in (select userid from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in (
	select created_by_audit_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_admin_order_useraudit a with (nolock)
	JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_admin_order b with (nolock) on a.admin_order_id = b.admin_order_id 
	JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_phys_order c with (nolock) on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id = 32 
union 
	select edited_by_audit_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_admin_order_useraudit a with (nolock)
	JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_admin_order b with (nolock) on a.admin_order_id = b.admin_order_id 
	JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_phys_order c with (nolock) on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id = 32 
union 
	select confirmed_by_audit_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_admin_order_useraudit a with (nolock)
	JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_admin_order b with (nolock) on a.admin_order_id = b.admin_order_id 
	JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_phys_order c with (nolock) on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id = 32 
) and fac_id <> 32)
and fac_id <> 32
sproc_facacq_pre_sec_user_Import_01_scoping - sec_user in pho_admin_order0 affected rows
insert into pcc_temp_storage.dbo._bkp_EICase590132_sec_user_import_pre_scoping_fac_32
select distinct * from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].sec_user with (nolock)
where userid in (select userid from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in (
	select created_by_audit_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_admin_order_useraudit a with (nolock)
	JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_admin_order_audit b with (nolock) on a.admin_order_id = b.admin_order_id 
	JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_phys_order c with (nolock) on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id = 32 
union 
	select edited_by_audit_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_admin_order_useraudit a with (nolock)
	JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_admin_order_audit b with (nolock) on a.admin_order_id = b.admin_order_id 
	JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_phys_order c with (nolock) on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id = 32 
union 
	select confirmed_by_audit_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_admin_order_useraudit a with (nolock)
	JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_admin_order_audit b with (nolock) on a.admin_order_id = b.admin_order_id 
	JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_phys_order c with (nolock) on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id = 32) and fac_id <> 32)
and fac_id <> 32
sproc_facacq_pre_sec_user_Import_01_scoping - sec_user in pho_admin_order0 affected rows
insert into pcc_temp_storage.dbo._bkp_EICase590132_sec_user_import_pre_scoping_fac_32
select distinct * from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].sec_user s with (nolock)
where userid in (select userid from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].cp_sec_user_audit with (nolock) where cp_sec_user_audit_id in 
(SELECT distinct followupby_useraudit_id FROM [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_schedule_details_followup_useraudit b with (nolock)
JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_schedule_details c with (nolock) on b.schedule_detail_id = c.pho_schedule_detail_id
JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_schedule d with (nolock) ON d.schedule_id=c.pho_schedule_id
WHERE d.fac_id = 32)  
and fac_id <> 32)
and fac_id <> 32
sproc_facacq_pre_sec_user_Import_01_scoping - sec_user in pho_schedule_details0 affected rows
insert into pcc_temp_storage.dbo._bkp_EICase590132_sec_user_import_pre_scoping_fac_32
SELECT DISTINCT *
FROM [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].sec_user s WITH (NOLOCK)
WHERE userid IN (
		SELECT userid
		FROM [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].cp_sec_user_audit WITH (NOLOCK)
		WHERE cp_sec_user_audit_id IN (
				SELECT followupby_useraudit_id
				FROM [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_schedule_details_followup_useraudit b WITH (NOLOCK)
				WHERE schedule_detail_id IN (
						SELECT pho_schedule_detail_id
						FROM [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_schedule_details c WITH (NOLOCK)
						WHERE pho_schedule_id IN (
								SELECT schedule_id
								FROM [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_schedule d WITH (NOLOCK)
								WHERE fac_id = 32)))
			AND fac_id <> 32) AND fac_id <> 32
sproc_facacq_pre_sec_user_Import_01_scoping - sec_user in pho_schedule_details_followup_useraudit0 affected rows
insert into pcc_temp_storage.dbo._bkp_EICase590132_sec_user_import_pre_scoping_fac_32
SELECT distinct * from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].sec_user s with (nolock)
where userid in (select userid from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in (select cp_sec_user_audit_id FROM [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_phys_order_sign with (nolock)
WHERE phys_order_id IN (SELECT distinct phys_order_id FROM [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_phys_order with (nolock) WHERE fac_id = 32))
AND fac_id <> 32)
and fac_id <> 32
sproc_facacq_pre_sec_user_Import_01_scoping - sec_user in pho_phys_order_sign0 affected rows
insert into pcc_temp_storage.dbo._bkp_EICase590132_sec_user_import_pre_scoping_fac_32
select distinct * from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.dbo.sec_user with (nolock)
where userid in (select userid from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.dbo.cp_sec_user_audit with (nolock) where cp_sec_user_audit_id in 
(select created_cp_sec_user_audit_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.dbo.pho_formulary_item_custom_library with (nolock)
where custom_drug_id in (select custom_drug_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.dbo.cr_cust_med with (nolock) where fac_id in (-1,32))
union
select revision_cp_sec_user_audit_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.dbo.pho_formulary_item_custom_library with (nolock)
where custom_drug_id in (select custom_drug_id from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.dbo.cr_cust_med with (nolock) where fac_id in (-1,32)))
and fac_id not in (-1,32)
and cp_sec_user_audit_id not in (-998,-10000))
and fac_id <> 32
sproc_facacq_pre_sec_user_Import_01_scoping - sec_user in pho_formulary_item_custom_library0 affected rows
insert into pcc_temp_storage.dbo._bkp_EICase590132_sec_user_import_pre_scoping_fac_32
select distinct * from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.dbo.sec_user with (nolock)
where userid in (select userid from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in (
SELECT DISTINCT b.created_by_audit_id
FROM [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_phys_order_audit_useraudit b with (nolock)
JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].cp_sec_user_audit ba with (nolock) ON b.created_by_audit_id = ba.cp_sec_user_audit_id
join [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.dbo.pho_phys_order_useraudit pa with (nolock) on pa.created_by_audit_id = ba.cp_sec_user_audit_id
JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_phys_order c with (nolock) ON pa.phys_order_id = c.phys_order_id
WHERE c.fac_id IN (32))
and fac_id not in (32)
and userid not in (-998,-10000))
sproc_facacq_pre_sec_user_Import_01_scoping - sec_user in pho_phys_order_audit_useraudit0 affected rows
insert into pcc_temp_storage.dbo._bkp_EICase590132_sec_user_import_pre_scoping_fac_32
select * from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.dbo.sec_user with (nolock)
where userid in (select userid from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in (SELECT DISTINCT b.edited_by_audit_id
FROM [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_phys_order_audit_useraudit b with (nolock)
JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].cp_sec_user_audit ba with (nolock) ON b.edited_by_audit_id = ba.cp_sec_user_audit_id
join [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.dbo.pho_phys_order_useraudit pa with (nolock) on pa.edited_by_audit_id = ba.cp_sec_user_audit_id
JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_phys_order c with (nolock) ON pa.phys_order_id = c.phys_order_id
WHERE c.fac_id IN (32))
and fac_id not in (32)
and userid not in (-998,-10000))
sproc_facacq_pre_sec_user_Import_01_scoping - sec_user in pho_phys_order_audit_useraudit0 affected rows
insert into pcc_temp_storage.dbo._bkp_EICase590132_sec_user_import_pre_scoping_fac_32
select * from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.dbo.sec_user with (nolock)
where userid in (select userid from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in (
SELECT DISTINCT b.confirmed_by_audit_id
FROM [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_phys_order_audit_useraudit b with (nolock)
JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].cp_sec_user_audit ba with (nolock) ON b.confirmed_by_audit_id = ba.cp_sec_user_audit_id
join [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.dbo.pho_phys_order_useraudit pa with (nolock) on pa.confirmed_by_audit_id = ba.cp_sec_user_audit_id
JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].pho_phys_order c with (nolock) ON pa.phys_order_id = c.phys_order_id
WHERE c.fac_id IN (32))
and fac_id not in (32)
and userid not in (-998,-10000))
sproc_facacq_pre_sec_user_Import_01_scoping - sec_user in pho_phys_order_audit_useraudit0 affected rows
insert into pcc_temp_storage.dbo._bkp_EICase590132_sec_user_import_pre_scoping_fac_32
select distinct s.* from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.dbo.sec_user s with (nolock)
join [dbo].inc_incident a with (nolock) on a.strikeout_by_id = s.userid
where a.fac_id = 32 and s.fac_id <> 32
sproc_facacq_pre_sec_user_Import_01_scoping - sec_user in inc_incident0 affected rows
if OBJECT_ID ('pcc_temp_storage.dbo.EICase590132_1504957707_sec_user_sameloginname','U') is not null
DROP TABLE pcc_temp_storage.dbo.EICase590132_1504957707_sec_user_sameloginname

if OBJECT_ID ('pcc_temp_storage.dbo.EICase590132_1504957707_sec_user_samelogin_different_name','U') is not null
DROP TABLE pcc_temp_storage.dbo.EICase590132_1504957707_sec_user_samelogin_different_name

if OBJECT_ID ('pcc_temp_storage.dbo.EICase590132_1504957707_sec_user_samelogin_same_name','U') is not null
DROP TABLE pcc_temp_storage.dbo.EICase590132_1504957707_sec_user_samelogin_same_name

if OBJECT_ID ('dbo.EICase590132sec_user','U') is not null
DROP TABLE dbo.EICase590132sec_user

sproc_facacq_pre_sec_user_Import_02_Import - drop temporary tables


select  a.* into pcc_temp_storage.dbo.EICase590132_1504957707_sec_user_sameloginname
from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.dbo.sec_user a 
join  dbo.sec_user b on a.loginname = b.loginname
where a.fac_id = 32
and a.loginname not like '%pcc-%' 
and a.loginname  not like '%wescom%' 

sproc_facacq_pre_sec_user_Import_02_Import - pcc_temp_storage.dbo.EICase590132_1504957707_sec_user_sameloginname - 20 affected rows


insert into pcc_temp_storage.dbo.EICase590132_1504957707_sec_user_sameloginname
select a.*
from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.dbo.sec_user a
join dbo.sec_user b
on a.loginname = b.loginname
where a.userid in (select distinct userid from pcc_temp_storage.dbo._bkp_EICase590132_sec_user_import_pre_scoping_fac_32)

sproc_facacq_pre_sec_user_Import_02_Import - pcc_temp_storage.dbo.EICase590132_1504957707_sec_user_sameloginname - 25 affected rows


select identity(int,1,1) as row_id, src.userid as src_id, NULL as dst_id
into dbo.EICase590132sec_user 
from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.dbo.sec_user src 
where fac_id = 32 and loginname not like '%pcc-%' and loginname not like '%wescom%' 
or userid in (select distinct userid from pcc_temp_storage.dbo._bkp_EICase590132_sec_user_import_pre_scoping_fac_32)

sproc_facacq_pre_sec_user_Import_02_Import - dbo.EICase590132sec_user - 1 affected rows


UPDATE dbo.EICase590132sec_user SET dst_id = 126782 + ([row_id] - 1)

		
sproc_facacq_pre_sec_user_Import_02_Import - 160 affected rows.


INSERT INTO dbo.sec_user
SELECT map.dst_id,30,'EICase590132',getdate(),'EICase590132',getdate(),'1504957707',[long_username],NULL,[loginname],[remote_user],[admin_user],[eadmin_setup_user],[ecare_setup_user],[ecare_user],[eadmin_user],NULL,[default_care_tab],[default_admin_tab],[auto_pagesetup],-1,[enabled],[pho_access],[enterprise_user],[regional_setup_access],[regional_id],NULL,[mds_portal_view],[cms_checked_clinical],[cms_checked_admin],[cms_checked_qia],[cms_checked_glap],[cms_checked_enterprise],[passwd_check],[passwd_expiry_date],[alternate_loginname],[login_to_enterprise_flag],[mmq_portal_view],[uda_portal_view],[max_failed_logins],[designation_desc],[care_line_id],[pharmacy_portal_view],[initials],[REENABLED_DATE],[VALID_UNTIL_DATE],[EXTERNAL_SYSTEM_ID],[EXT_FAC_ID],[pin_check],[login_to_irm],[pin_expiry_date],[all_facilities],[last_login_date],[authentication_method],[next_nps_survey_date],[pharmacy_portal_pharmtab],[user_type_id],NULL,[comment],[user_first_name],[user_last_name],[api_only_user],[default_admin_view],[sso_only_user]
FROM [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.dbo.sec_user src
JOIN dbo.EICase590132sec_user map ON src.userid = map.src_id
WHERE src.userid NOT IN (SELECT userid FROM pcc_temp_storage.dbo.EICase590132_1504957707_sec_user_sameloginname)

sproc_facacq_pre_sec_user_Import_02_Import - sec_user - 115 affected rows


INSERT INTO dbo.sec_user_facility (userid,facility_id,access_level)
SELECT DISTINCT a.dst_id
	,30   
	,src.access_level
FROM dbo.EICase590132sec_user a join [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.dbo.sec_user_facility src
on a.src_id = src.userid
WHERE src.userid NOT IN (SELECT userid FROM pcc_temp_storage.dbo.EICase590132_1504957707_sec_user_sameloginname) and src.facility_id = 32

sproc_facacq_pre_sec_user_Import_02_Import - sec_user_facility - 114 affected rows


select  a.* into pcc_temp_storage.dbo.EICase590132_1504957707_sec_user_samelogin_different_name
from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.dbo.sec_user a
join  dbo.sec_user b
on a.loginname = b.loginname
where a.fac_id = 32 
and a.loginname not like '%pcc-%' and a.loginname  not like '%wescom%'
and a.long_username <> b.long_username

sproc_facacq_pre_sec_user_Import_02_Import - pcc_temp_storage.dbo.EICase590132_1504957707_sec_user_samelogin_different_name - 0 affected rows


insert into pcc_temp_storage.dbo.EICase590132_1504957707_sec_user_samelogin_different_name
select a.*
from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.dbo.sec_user a
join  dbo.sec_user b
on a.loginname = b.loginname
where a.userid in (select distinct userid from pcc_temp_storage.dbo._bkp_EICase590132_sec_user_import_pre_scoping_fac_32)
and a.long_username <> b.long_username

sproc_facacq_pre_sec_user_Import_02_Import - pcc_temp_storage.dbo.EICase590132_1504957707_sec_user_samelogin_different_name - 0 affected rows


INSERT INTO dbo.sec_user
SELECT map.dst_id,30,'EICase590132',getdate(),'EICase590132',getdate(),'1504957707',[long_username],NULL,[loginname] + 'ZION',[remote_user],[admin_user],[eadmin_setup_user],[ecare_setup_user],[ecare_user],[eadmin_user],NULL,[default_care_tab],[default_admin_tab],[auto_pagesetup],-1,[enabled],[pho_access],[enterprise_user],[regional_setup_access],[regional_id],NULL,[mds_portal_view],[cms_checked_clinical],[cms_checked_admin],[cms_checked_qia],[cms_checked_glap],[cms_checked_enterprise],[passwd_check],[passwd_expiry_date],[alternate_loginname],[login_to_enterprise_flag],[mmq_portal_view],[uda_portal_view],[max_failed_logins],[designation_desc],[care_line_id],[pharmacy_portal_view],[initials],[REENABLED_DATE],[VALID_UNTIL_DATE],[EXTERNAL_SYSTEM_ID],[EXT_FAC_ID],[pin_check],[login_to_irm],[pin_expiry_date],[all_facilities],[last_login_date],[authentication_method],[next_nps_survey_date],[pharmacy_portal_pharmtab],[user_type_id],NULL,[comment],[user_first_name],[user_last_name],[api_only_user],[default_admin_view],[sso_only_user]
FROM  [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.dbo.sec_user src 
JOIN dbo.EICase590132sec_user map ON src.userid = map.src_id
and src_id IN (select userid from pcc_temp_storage.dbo.EICase590132_1504957707_sec_user_samelogin_different_name)

sproc_facacq_pre_sec_user_Import_02_Import - sec_user - 0 affected rows


INSERT INTO dbo.sec_user_facility (userid,facility_id,access_level)
SELECT DISTINCT a.dst_id
	,30   
	,src.access_level
FROM dbo.EICase590132sec_user a join [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.dbo.sec_user_facility src
on a.src_id = src.userid
JOIN pcc_temp_storage.dbo.EICase590132_1504957707_sec_user_samelogin_different_name t on src.userid = t.userid
WHERE src.userid IN (SELECT userid FROM pcc_temp_storage.dbo.EICase590132_1504957707_sec_user_samelogin_different_name) 
and src.facility_id = 32

sproc_facacq_pre_sec_user_Import_02_Import - sec_user_facility - 0 affected rows
ALTER TABLE dbo.EICase590132sec_user
add corporate char
sproc_facacq_pre_sec_user_Import_02_Import - add corporate column to dbo.EICase590132sec_user
update dbo.EICase590132sec_user set corporate = 'N' 
sproc_facacq_pre_sec_user_Import_02_Import - update dbo.EICase590132sec_user.corporate - 160 affected rows


	select  a.* into pcc_temp_storage.dbo.EICase590132_1504957707_sec_user_samelogin_same_name
	from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.dbo.sec_user a
	join  dbo.sec_user b
	on a.loginname = b.loginname
	where a.fac_id = 32 
	and a.loginname not like '%pcc-%' and a.loginname  not like '%wescom%'
	and a.long_username = b.long_username 
	and b.created_by not like '%EICase590132'

	
sproc_facacq_pre_sec_user_Import_02_Import - pcc_temp_storage.dbo.EICase590132_1504957707_sec_user_samelogin_same_name - 20 affected rows


	insert  into pcc_temp_storage.dbo.EICase590132_1504957707_sec_user_samelogin_same_name
	select a.*
	from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.dbo.sec_user a
	join  dbo.sec_user b
	on a.loginname = b.loginname
	where a.userid in (select distinct userid from pcc_temp_storage.dbo._bkp_EICase590132_sec_user_import_pre_scoping_fac_32)
	and a.long_username = b.long_username 
	and b.created_by not like '%EICase590132' 

	
sproc_facacq_pre_sec_user_Import_02_Import - pcc_temp_storage.dbo.EICase590132_1504957707_sec_user_samelogin_same_name - 25 affected rows


	update map
	set dst_id = ur.userid, corporate = 'Y'
	FROM dbo.EICase590132sec_user map 
	JOIN pcc_temp_storage.dbo.EICase590132_1504957707_sec_user_samelogin_same_name ln ON ln.userid = map.src_id
	JOIN sec_user ur ON ln.loginname = ur.loginname

	
sproc_facacq_pre_sec_user_Import_02_Import - EICase590132sec_user - 45 affected rows


INSERT INTO sec_user_physical_id (userid,sequence,physicalid)
SELECT b.dst_id
	,[sequence]
	,[physicalid]
FROM [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.[dbo].sec_user_physical_id src
JOIN dbo.EICase590132sec_user b ON b.src_id = src.userid 
where b.corporate = 'N' and b.dst_id not in (select userid from sec_user_physical_id)

sproc_facacq_pre_sec_user_Import_02_Import - sec_user_physical_id - 0 affected rows


update sec_user
set admin_user_type = 'E'
FROM dbo.sec_user  
where loginname like '[_]api[_]%'
and (created_by like '%EICase590132'  or userid in (select dst_id from EICase590132sec_user where corporate = 'N'))
and admin_user_type is NULL

sproc_facacq_pre_sec_user_Import_02_Import - api user fix - 0 affected rows

Completion time: 2021-12-20T19:29:11.2290189-05:00
