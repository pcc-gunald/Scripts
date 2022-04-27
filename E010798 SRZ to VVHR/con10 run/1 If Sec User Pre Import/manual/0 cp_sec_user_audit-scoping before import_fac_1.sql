use us_cit_multi
go

/*
select distinct * from pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45 
select * from pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45 
*/

if OBJECT_ID ('pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45','U') is not null
drop table pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45


------scope for sec_user as well
select * into pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45 
--select *
from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].sec_user with (nolock)
where userid in 
(select userid from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].cp_sec_user_audit  with (nolock) 
where cp_sec_user_audit_id  in (select created_user_audit_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].as_footnote with (nolock)
where client_id in (select client_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].clients with (nolock) where fac_id = 45)) and fac_id <> 45)
and fac_id <> 45 --0



insert into pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45 
select distinct s.* 
from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_admin_order a with (nolock)
join [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_phys_order b with (nolock) on a.phys_order_id=b.phys_order_id
join [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].sec_user s  with (nolock) on a.noted_by=s.userid
where b.fac_id = 45 and s.fac_id <> 45 --0


insert into pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45 
select distinct * from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].sec_user with (nolock)
where userid in (SELECT distinct a.userid FROM [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].cp_sec_user_audit a with (nolock)
JOIN [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_phys_order_useraudit b with (nolock) on a.cp_sec_user_audit_id = b.created_by_audit_id 
JOIN [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_phys_order c with (nolock) on b.phys_order_id = c.phys_order_id 
WHERE c.fac_id = 45 
)  
and fac_id <> 45 --0



insert into pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45 
select distinct * from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].sec_user b with (nolock)
where userid in 
(select userid from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].cp_sec_user_audit with (nolock) where cp_sec_user_audit_id in 
(select created_by_audit_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_std_order_set with (nolock) where  fac_id  in (-1,5,13,18,20,29,33)
union 
select revision_by_audit_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_std_order_set with (nolock) where  fac_id  in (-1,5,13,18,20,29,33)
union 
select published_by_audit_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_std_order_set with (nolock) where  fac_id  in (-1,5,13,18,20,29,33)
union 
select retired_by_audit_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_std_order_set with (nolock) where fac_id  in (-1,5,13,18,20,29,33)
union 
select reactivated_by_audit_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_std_order_set with (nolock) where  fac_id  in (-1,5,13,18,20,29,33))
and fac_id <> 45)
and fac_id <> 45 --2


insert into pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45 
select distinct  * from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].sec_user b with (nolock)
where userid in 
(select userid from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].cp_sec_user_audit with (nolock) where cp_sec_user_audit_id in 
(select created_by_audit_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_std_order with (nolock) where  fac_id  in (-1,5,13,18,20,29,33)
union 
select revision_by_audit_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_std_order with (nolock) where  fac_id  in (-1,5,13,18,20,29,33)
union 
select published_by_audit_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_std_order with (nolock) where  fac_id  in (-1,5,13,18,20,29,33)
union 
select retired_by_audit_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_std_order with (nolock) where  fac_id  in (-1,5,13,18,20,29,33)
union 
select reactivated_by_audit_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_std_order with (nolock) where  fac_id  in (-1,5,13,18,20,29,33))
and fac_id <> 45)
and fac_id <> 45 --4


insert into pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45 
select distinct * from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].sec_user with (nolock)
where userid in (SELECT distinct a.userid FROM [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].cp_sec_user_audit a with (nolock)
JOIN [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].allergy b with (nolock) on a.cp_sec_user_audit_id = b.created_user_audit_id 
where b.client_id in (select client_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].clients with (nolock) where fac_id = 45)
)  
and userid not in (-10000, -998)
and fac_id <> 45 --1


insert into pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45 
select distinct * from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].sec_user with (nolock)
where userid in (SELECT distinct a.userid FROM [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].cp_sec_user_audit a with (nolock)
JOIN [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].allergy b with (nolock) on a.cp_sec_user_audit_id = b.revision_user_audit_id 
where b.client_id in (select client_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].clients with (nolock) where fac_id = 45)
)  
and userid not in (-10000, -998)
and fac_id <> 45 --1



insert into pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45 
select distinct * from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].sec_user with (nolock)
where userid in (SELECT distinct a.userid FROM [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].cp_sec_user_audit a with (nolock)
JOIN [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].allergy_audit b with (nolock) on a.cp_sec_user_audit_id = b.created_user_audit_id 
where b.client_id in (select client_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].clients with (nolock) where fac_id = 45)
)  
and userid not in (-10000, -998)
and fac_id <> 45 --1


insert into pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45 
select distinct * from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].sec_user with (nolock)
where userid in (SELECT distinct a.userid FROM [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].cp_sec_user_audit a with (nolock)
JOIN [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].allergy_audit b with (nolock) on a.cp_sec_user_audit_id = b.revision_user_audit_id 
where b.client_id in (select client_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].clients with (nolock) where fac_id = 45)
)  
and userid not in (-10000, -998)
and fac_id <> 45 --1


insert into pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45 
select distinct * from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].sec_user with (nolock)
where userid in (select userid from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in  (select  sec_user_audit_id from  [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].immunization_strikeout with (nolock)
where immunization_id in (select  immunization_id  from  [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].cr_client_immunization with (nolock)
where fac_id = 45)) and  fac_id <> 45)
and fac_id <> 45--0


insert into pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45 
select distinct s.*
from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].mpi_history b with (nolock)
join [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].sec_user s with (nolock) on b.user_id=s.userid
left join [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].sec_user_facility f with (nolock) on b.user_id=f.userid
where b.fac_id = 45 and s.fac_id <> 45 and (facility_id= 45 or admin_user_type ='E') --26


------scope for sec_user as well
insert into pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45 
select distinct * from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].sec_user with (nolock)
where userid in (select userid from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in  (select  sec_user_audit_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].immunization_strikeout with (nolock)
where immunization_id in (select  immunization_id  from   [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].cr_client_immunization with (nolock)
where fac_id in (45)))
and  fac_id not in (45))
and fac_id not in (45) --0


insert into pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45 
select distinct * from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].sec_user with (nolock)
where userid in  (select  administered_by_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].cr_client_immunization with (nolock)
where fac_id in (45))--0 rows 
and  fac_id not in (45) --0


insert into pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45 
select distinct * from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].sec_user with (nolock)
where userid in  (select  administered_by_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].cr_client_immunization_audit with (nolock)
where fac_id in (45))--0 rows 
and  fac_id not in (45)--0


insert into pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45 
select distinct * from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].sec_user with (nolock)
where userid in (select userid from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id  in (select strikeout_user_audit_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].allergy_strikeout s with (nolock)
JOIN [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].allergy b with (nolock) on s.allergy_id = b.allergy_id 
where client_id in (select client_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].clients with (nolock) where fac_id in (45)))
and fac_id not in (45))
and fac_id not in (45)--0


insert into pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45 
select distinct * from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].sec_user with (nolock)
where userid in (select userid from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id  in (select strikeout_user_audit_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].diagnosis_strikeout with (nolock)
where client_diagnosis_id in (select client_diagnosis_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].diagnosis with (nolock) where fac_id in (45)))
and fac_id not in (45))
and fac_id not in (45)--0


insert into pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45 
select distinct * from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].sec_user with (nolock)
where userid in (select userid from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in (
	select created_by_audit_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_admin_order_useraudit a with (nolock)
	JOIN [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_admin_order b with (nolock) on a.admin_order_id = b.admin_order_id 
	JOIN [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_phys_order c with (nolock) on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id = 45 
union 
	select edited_by_audit_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_admin_order_useraudit a with (nolock)
	JOIN [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_admin_order b with (nolock) on a.admin_order_id = b.admin_order_id 
	JOIN [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_phys_order c with (nolock) on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id = 45 
union 
	select confirmed_by_audit_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_admin_order_useraudit a with (nolock)
	JOIN [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_admin_order b with (nolock) on a.admin_order_id = b.admin_order_id 
	JOIN [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_phys_order c with (nolock) on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id = 45 
) and fac_id <> 45)
and fac_id <> 45
--10


insert into pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45 
select distinct * from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].sec_user with (nolock)
where userid in (select userid from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in (
	select created_by_audit_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_admin_order_useraudit a with (nolock)
	JOIN [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_admin_order_audit b with (nolock) on a.admin_order_id = b.admin_order_id 
	JOIN [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_phys_order c with (nolock) on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id = 45 
union 
	select edited_by_audit_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_admin_order_useraudit a with (nolock)
	JOIN [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_admin_order_audit b with (nolock) on a.admin_order_id = b.admin_order_id 
	JOIN [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_phys_order c with (nolock) on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id = 45 
union 
	select confirmed_by_audit_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_admin_order_useraudit a with (nolock)
	JOIN [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_admin_order_audit b with (nolock) on a.admin_order_id = b.admin_order_id 
	JOIN [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_phys_order c with (nolock) on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id = 45 
) and fac_id <> 45)
and fac_id <> 45 --10

--LONG RUNNING QUERIES
--USE SRC TEST DB for Below selects in testing
--find out if more than 0 rows inserted for both statements below
--if 0 then comment
--if > 0 manually add these IDs in scoping table


insert into pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45 
select distinct * from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].sec_user s with (nolock)
where userid in (select userid from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].cp_sec_user_audit with (nolock) where cp_sec_user_audit_id in 
(SELECT distinct followupby_useraudit_id FROM [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_schedule_details_followup_useraudit b with (nolock)
JOIN [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_schedule_details c with (nolock) on b.schedule_detail_id = c.pho_schedule_detail_id
JOIN [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_schedule d with (nolock) ON d.schedule_id=c.pho_schedule_id
WHERE d.fac_id = 45)  
and fac_id <> 45)
and fac_id <> 45


----added
insert into pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45 
SELECT DISTINCT *
FROM [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].sec_user s WITH (NOLOCK)
WHERE userid IN (
		SELECT userid
		FROM [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].cp_sec_user_audit WITH (NOLOCK)
		WHERE cp_sec_user_audit_id IN (
				SELECT followupby_useraudit_id
				FROM [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_schedule_details_followup_useraudit b WITH (NOLOCK)
				WHERE schedule_detail_id IN (
						SELECT pho_schedule_detail_id
						FROM [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_schedule_details c WITH (NOLOCK)
						WHERE pho_schedule_id IN (
								SELECT schedule_id
								FROM [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_schedule d WITH (NOLOCK)
								WHERE fac_id = 45)))
			AND fac_id <> 45
		) AND fac_id <> 45



insert into pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45 
SELECT distinct * from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].sec_user s with (nolock)
where userid in (select userid from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in (select cp_sec_user_audit_id FROM [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_phys_order_sign with (nolock)
WHERE phys_order_id IN (SELECT distinct phys_order_id FROM [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_phys_order with (nolock) WHERE fac_id = 45))
AND fac_id <> 45)
and fac_id <> 45--0


insert into pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45 
select distinct * from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.dbo.sec_user with (nolock)
where userid in (select userid from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.dbo.cp_sec_user_audit with (nolock) where cp_sec_user_audit_id in 
(select created_cp_sec_user_audit_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.dbo.pho_formulary_item_custom_library with (nolock)
where custom_drug_id in (select custom_drug_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.dbo.cr_cust_med with (nolock) where fac_id in (-1,5,13,18,20,29,33))
union
select revision_cp_sec_user_audit_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.dbo.pho_formulary_item_custom_library with (nolock)
where custom_drug_id in (select custom_drug_id from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.dbo.cr_cust_med with (nolock) where fac_id in (-1,5,13,18,20,29,33))
) --src_fac_id
and fac_id not in (-1,5,13,18,20,29,33) --src_fac_id
and cp_sec_user_audit_id not in (-998,-10000))
and fac_id <> 45 --0


insert into pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45 
select distinct * from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.dbo.sec_user with (nolock)
where userid in (select userid from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in (
SELECT DISTINCT b.created_by_audit_id
FROM [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_phys_order_audit_useraudit b with (nolock)
JOIN [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].cp_sec_user_audit ba with (nolock) ON b.created_by_audit_id = ba.cp_sec_user_audit_id
join [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.dbo.pho_phys_order_useraudit pa with (nolock) on pa.created_by_audit_id = ba.cp_sec_user_audit_id
JOIN [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_phys_order c with (nolock) ON pa.phys_order_id = c.phys_order_id
WHERE c.fac_id IN (45)
)
and fac_id not in (45)
and userid not in (-998,-10000)) --12


insert into pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45 
select * from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.dbo.sec_user with (nolock)
where userid in (select userid from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in (
SELECT DISTINCT b.edited_by_audit_id
FROM [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_phys_order_audit_useraudit b with (nolock)
JOIN [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].cp_sec_user_audit ba with (nolock) ON b.edited_by_audit_id = ba.cp_sec_user_audit_id
join [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.dbo.pho_phys_order_useraudit pa with (nolock) on pa.edited_by_audit_id = ba.cp_sec_user_audit_id
JOIN [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_phys_order c with (nolock) ON pa.phys_order_id = c.phys_order_id
WHERE c.fac_id IN (45)
)
and fac_id not in (45)
and userid not in (-998,-10000))


insert into pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45 
select * from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.dbo.sec_user with (nolock)
where userid in (select userid from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in (
SELECT DISTINCT b.confirmed_by_audit_id
FROM [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_phys_order_audit_useraudit b with (nolock)
JOIN [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].cp_sec_user_audit ba with (nolock) ON b.confirmed_by_audit_id = ba.cp_sec_user_audit_id
join [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.dbo.pho_phys_order_useraudit pa with (nolock) on pa.confirmed_by_audit_id = ba.cp_sec_user_audit_id
JOIN [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].pho_phys_order c with (nolock) ON pa.phys_order_id = c.phys_order_id
WHERE c.fac_id IN (45)
)
and fac_id not in (45)
and userid not in (-998,-10000))


insert into pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45 
select distinct s.*
from [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].inc_incident a with (nolock)
join [pccsql-use2-prod-w31-cli0001.90c2966cd166.database.windows.net].us_cmc_multi.[dbo].sec_user s with (nolock) on a.strikeout_by_id = s.userid
where a.fac_id = 45 and s.fac_id <> 45--1



delete from pcc_temp_storage.dbo._bkp_PMO010798_Case01079812_sec_user_import_pre_scoping_fac_45  where loginname like '%pcc-%'

/*
Test

(2 rows affected)

(22 rows affected)

(23 rows affected)

(12 rows affected)

(16 rows affected)

(14 rows affected)

(14 rows affected)

(3 rows affected)

(3 rows affected)

(1 row affected)

(65 rows affected)

(1 row affected)

(9 rows affected)

(8 rows affected)

(0 rows affected)

(4 rows affected)

(13 rows affected)

(13 rows affected)

(1 row affected)

(1 row affected)

(3 rows affected)

(1 row affected)

(13 rows affected)

(13 rows affected)

(3 rows affected)

(0 rows affected)

(5 rows affected)

Completion time: 2022-03-01T15:08:54.4559662-05:00


*/




/*
Go live


(2 rows affected)

(22 rows affected)

(23 rows affected)

(12 rows affected)

(16 rows affected)

(14 rows affected)

(14 rows affected)

(3 rows affected)

(3 rows affected)

(1 row affected)

(66 rows affected)

(1 row affected)

(9 rows affected)

(8 rows affected)

(0 rows affected)

(4 rows affected)

(13 rows affected)

(13 rows affected)

(1 row affected)

(1 row affected)

(3 rows affected)

(1 row affected)

(13 rows affected)

(13 rows affected)

(3 rows affected)

(0 rows affected)

(5 rows affected)

Completion time: 2022-03-10T10:37:40.0067522-05:00

*/
