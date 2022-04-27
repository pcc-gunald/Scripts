--for testing run on [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net]
--for production run on [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net]

USE test_usei1214
--GO

--USE us_pghc_multi
--GO

--if NO sec user pre import, comment the entire script

print  CHAR(13) + 'Starting to run script : GAP - cp_sec_user_audit - rescoping for fac R_SRCFACID9' 

select * into #temp
--select *
from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].sec_user with (nolock)
where userid in 
(select userid from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].cp_sec_user_audit  with (nolock) 
where cp_sec_user_audit_id  in (select created_user_audit_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].as_footnote with (nolock)
where client_id in (select client_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].clients with (nolock) where fac_id = R_SRCFACID9)) and fac_id <> R_SRCFACID9)
and fac_id <> R_SRCFACID9 

insert into #temp
select distinct s.* 
from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_admin_order a with (nolock)
join [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_phys_order b with (nolock) on a.phys_order_id=b.phys_order_id
join [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].sec_user s  with (nolock) on a.noted_by=s.userid
where b.fac_id = R_SRCFACID9 and s.fac_id <> R_SRCFACID9 

insert into #temp
select distinct * from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].sec_user with (nolock)
where userid in (SELECT distinct a.userid FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].cp_sec_user_audit a with (nolock)
JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_phys_order_useraudit b with (nolock) on a.cp_sec_user_audit_id = b.created_by_audit_id 
JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_phys_order c with (nolock) on b.phys_order_id = c.phys_order_id 
WHERE c.fac_id = R_SRCFACID9)  
and fac_id <> R_SRCFACID9

insert into #temp
select distinct * from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].sec_user b with (nolock)
where userid in 
(select userid from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].cp_sec_user_audit with (nolock) where cp_sec_user_audit_id in 
(select created_by_audit_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_std_order_set with (nolock) where  fac_id  in (-1,R_SRCFACID9)
union 
select revision_by_audit_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_std_order_set with (nolock) where  fac_id  in (-1,R_SRCFACID9)
union 
select published_by_audit_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_std_order_set with (nolock) where  fac_id  in (-1,R_SRCFACID9)
union 
select retired_by_audit_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_std_order_set with (nolock) where fac_id  in (-1,R_SRCFACID9)
union 
select reactivated_by_audit_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_std_order_set with (nolock) where  fac_id  in (-1,R_SRCFACID9))
and fac_id <> R_SRCFACID9)
and fac_id <> R_SRCFACID9 

insert into #temp
select distinct  * from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].sec_user b with (nolock)
where userid in 
(select userid from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].cp_sec_user_audit with (nolock) where cp_sec_user_audit_id in 
(select created_by_audit_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_std_order with (nolock) where  fac_id  in (-1,R_SRCFACID9)
union 
select revision_by_audit_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_std_order with (nolock) where  fac_id  in (-1,R_SRCFACID9)
union 
select published_by_audit_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_std_order with (nolock) where  fac_id  in (-1,R_SRCFACID9)
union 
select retired_by_audit_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_std_order with (nolock) where  fac_id  in (-1,R_SRCFACID9)
union 
select reactivated_by_audit_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_std_order with (nolock) where  fac_id  in (-1,R_SRCFACID9))
and fac_id <> R_SRCFACID9)
and fac_id <> R_SRCFACID9 

insert into #temp
select distinct * from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].sec_user with (nolock)
where userid in (SELECT distinct a.userid FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].cp_sec_user_audit a with (nolock)
JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].allergy b with (nolock) on a.cp_sec_user_audit_id = b.created_user_audit_id 
where b.client_id in (select client_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].clients with (nolock) where fac_id = R_SRCFACID9))  
and userid not in (-10000, -998)
and fac_id <> R_SRCFACID9 

insert into #temp
select distinct * from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].sec_user with (nolock)
where userid in (SELECT distinct a.userid FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].cp_sec_user_audit a with (nolock)
JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].allergy b with (nolock) on a.cp_sec_user_audit_id = b.revision_user_audit_id 
where b.client_id in (select client_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].clients with (nolock) where fac_id = R_SRCFACID9))  
and userid not in (-10000, -998)
and fac_id <> R_SRCFACID9 

insert into #temp
select distinct * from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].sec_user with (nolock)
where userid in (SELECT distinct a.userid FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].cp_sec_user_audit a with (nolock)
JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].allergy_audit b with (nolock) on a.cp_sec_user_audit_id = b.created_user_audit_id 
where b.client_id in (select client_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].clients with (nolock) where fac_id = R_SRCFACID9))  
and userid not in (-10000, -998)
and fac_id <> R_SRCFACID9 

insert into #temp
select distinct * from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].sec_user with (nolock)
where userid in (SELECT distinct a.userid FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].cp_sec_user_audit a with (nolock)
JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].allergy_audit b with (nolock) on a.cp_sec_user_audit_id = b.revision_user_audit_id 
where b.client_id in (select client_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].clients with (nolock) where fac_id = R_SRCFACID9))  
and userid not in (-10000, -998)
and fac_id <> R_SRCFACID9 

insert into #temp
select distinct * from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].sec_user with (nolock)
where userid in (select userid from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in  (select  sec_user_audit_id from  [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].immunization_strikeout with (nolock)
where immunization_id in (select  immunization_id  from  [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].cr_client_immunization with (nolock)
where fac_id = R_SRCFACID9)) and  fac_id <> R_SRCFACID9)
and fac_id <> R_SRCFACID9

insert into #temp
select distinct s.*
from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].mpi_history b with (nolock)
join [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].sec_user s with (nolock) on b.user_id=s.userid
left join [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].sec_user_facility f with (nolock) on b.user_id=f.userid
where b.fac_id = R_SRCFACID9 and s.fac_id <> R_SRCFACID9 and (facility_id= R_SRCFACID9 or admin_user_type ='E') 

------scope for sec_user as well
insert into #temp
select distinct * from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].sec_user with (nolock)
where userid in (select userid from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in  (select  sec_user_audit_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].immunization_strikeout with (nolock)
where immunization_id in (select  immunization_id  from   [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].cr_client_immunization with (nolock)
where fac_id in (R_SRCFACID9)))
and  fac_id not in (R_SRCFACID9))
and fac_id not in (R_SRCFACID9) 

insert into #temp
select distinct * from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].sec_user with (nolock)
where userid in  (select  administered_by_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].cr_client_immunization with (nolock)
where fac_id in (R_SRCFACID9))
and  fac_id not in (R_SRCFACID9) 

insert into #temp
select distinct * from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].sec_user with (nolock)
where userid in  (select  administered_by_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].cr_client_immunization_audit with (nolock)
where fac_id in (R_SRCFACID9)) 
and  fac_id not in (R_SRCFACID9)

insert into #temp
select distinct * from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].sec_user with (nolock)
where userid in (select userid from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id  in (select strikeout_user_audit_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].allergy_strikeout s with (nolock)
JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].allergy b with (nolock) on s.allergy_id = b.allergy_id 
where client_id in (select client_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].clients with (nolock) where fac_id in (R_SRCFACID9)))
and fac_id not in (R_SRCFACID9))
and fac_id not in (R_SRCFACID9)

insert into #temp
select distinct * from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].sec_user with (nolock)
where userid in (select userid from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id  in (select strikeout_user_audit_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].diagnosis_strikeout with (nolock)
where client_diagnosis_id in (select client_diagnosis_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].diagnosis with (nolock) where fac_id in (R_SRCFACID9)))
and fac_id not in (R_SRCFACID9))
and fac_id not in (R_SRCFACID9)

insert into #temp
select distinct * from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].sec_user with (nolock)
where userid in (select userid from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in (
	select created_by_audit_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_admin_order_useraudit a with (nolock)
	JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_admin_order b with (nolock) on a.admin_order_id = b.admin_order_id 
	JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_phys_order c with (nolock) on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id = R_SRCFACID9 
union 
	select edited_by_audit_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_admin_order_useraudit a with (nolock)
	JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_admin_order b with (nolock) on a.admin_order_id = b.admin_order_id 
	JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_phys_order c with (nolock) on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id = R_SRCFACID9 
union 
	select confirmed_by_audit_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_admin_order_useraudit a with (nolock)
	JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_admin_order b with (nolock) on a.admin_order_id = b.admin_order_id 
	JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_phys_order c with (nolock) on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id = R_SRCFACID9 
) and fac_id <> R_SRCFACID9)
and fac_id <> R_SRCFACID9

insert into #temp
select distinct * from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].sec_user with (nolock)
where userid in (select userid from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in (
	select created_by_audit_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_admin_order_useraudit a with (nolock)
	JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_admin_order_audit b with (nolock) on a.admin_order_id = b.admin_order_id 
	JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_phys_order c with (nolock) on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id = R_SRCFACID9 
union 
	select edited_by_audit_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_admin_order_useraudit a with (nolock)
	JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_admin_order_audit b with (nolock) on a.admin_order_id = b.admin_order_id 
	JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_phys_order c with (nolock) on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id = R_SRCFACID9 
union 
	select confirmed_by_audit_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_admin_order_useraudit a with (nolock)
	JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_admin_order_audit b with (nolock) on a.admin_order_id = b.admin_order_id 
	JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_phys_order c with (nolock) on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id = R_SRCFACID9) and fac_id <> R_SRCFACID9)
and fac_id <> R_SRCFACID9

insert into #temp
select distinct * from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].sec_user s with (nolock)
where userid in (select userid from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].cp_sec_user_audit with (nolock) where cp_sec_user_audit_id in 
(SELECT distinct followupby_useraudit_id FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_schedule_details_followup_useraudit b with (nolock)
JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_schedule_details c with (nolock) on b.schedule_detail_id = c.pho_schedule_detail_id
JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_schedule d with (nolock) ON d.schedule_id=c.pho_schedule_id
WHERE d.fac_id = R_SRCFACID9)  
and fac_id <> R_SRCFACID9)
and fac_id <> R_SRCFACID9

insert into #temp
SELECT DISTINCT *
FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].sec_user s WITH (NOLOCK)
WHERE userid IN (
		SELECT userid
		FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].cp_sec_user_audit WITH (NOLOCK)
		WHERE cp_sec_user_audit_id IN (
				SELECT followupby_useraudit_id
				FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_schedule_details_followup_useraudit b WITH (NOLOCK)
				WHERE schedule_detail_id IN (
						SELECT pho_schedule_detail_id
						FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_schedule_details c WITH (NOLOCK)
						WHERE pho_schedule_id IN (
								SELECT schedule_id
								FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_schedule d WITH (NOLOCK)
								WHERE fac_id = R_SRCFACID9)))
			AND fac_id <> R_SRCFACID9) AND fac_id <> R_SRCFACID9

insert into #temp
SELECT distinct * from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].sec_user s with (nolock)
where userid in (select userid from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in (select cp_sec_user_audit_id FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_phys_order_sign with (nolock)
WHERE phys_order_id IN (SELECT distinct phys_order_id FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_phys_order with (nolock) WHERE fac_id = R_SRCFACID9))
AND fac_id <> R_SRCFACID9)
and fac_id <> R_SRCFACID9

insert into #temp
select distinct * from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.sec_user with (nolock)
where userid in (select userid from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.cp_sec_user_audit with (nolock) where cp_sec_user_audit_id in 
(select created_cp_sec_user_audit_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_formulary_item_custom_library with (nolock)
where custom_drug_id in (select custom_drug_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.cr_cust_med with (nolock) where fac_id in (-1,R_SRCFACID9))
union
select revision_cp_sec_user_audit_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_formulary_item_custom_library with (nolock)
where custom_drug_id in (select custom_drug_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.cr_cust_med with (nolock) where fac_id in (-1,R_SRCFACID9)))
and fac_id not in (-1,R_SRCFACID9)
and cp_sec_user_audit_id not in (-998,-10000))
and fac_id <> R_SRCFACID9

insert into #temp
select distinct * from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.sec_user with (nolock)
where userid in (select userid from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in (
SELECT DISTINCT b.created_by_audit_id
FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_phys_order_audit_useraudit b with (nolock)
JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].cp_sec_user_audit ba with (nolock) ON b.created_by_audit_id = ba.cp_sec_user_audit_id
join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_phys_order_useraudit pa with (nolock) on pa.created_by_audit_id = ba.cp_sec_user_audit_id
JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_phys_order c with (nolock) ON pa.phys_order_id = c.phys_order_id
WHERE c.fac_id IN (R_SRCFACID9))
and fac_id not in (R_SRCFACID9)
and userid not in (-998,-10000))

insert into #temp
select * from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.sec_user with (nolock)
where userid in (select userid from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in (SELECT DISTINCT b.edited_by_audit_id
FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_phys_order_audit_useraudit b with (nolock)
JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].cp_sec_user_audit ba with (nolock) ON b.edited_by_audit_id = ba.cp_sec_user_audit_id
join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_phys_order_useraudit pa with (nolock) on pa.edited_by_audit_id = ba.cp_sec_user_audit_id
JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_phys_order c with (nolock) ON pa.phys_order_id = c.phys_order_id
WHERE c.fac_id IN (R_SRCFACID9))
and fac_id not in (R_SRCFACID9)
and userid not in (-998,-10000))

insert into #temp
select * from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.sec_user with (nolock)
where userid in (select userid from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].cp_sec_user_audit with (nolock)
where cp_sec_user_audit_id in (
SELECT DISTINCT b.confirmed_by_audit_id
FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_phys_order_audit_useraudit b with (nolock)
JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].cp_sec_user_audit ba with (nolock) ON b.confirmed_by_audit_id = ba.cp_sec_user_audit_id
join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_phys_order_useraudit pa with (nolock) on pa.confirmed_by_audit_id = ba.cp_sec_user_audit_id
JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_phys_order c with (nolock) ON pa.phys_order_id = c.phys_order_id
WHERE c.fac_id IN (R_SRCFACID9))
and fac_id not in (R_SRCFACID9)
and userid not in (-998,-10000))

if OBJECT_ID ('pcc_temp_storage.dbo._bkp_PMO59277_CaseR_CASENUMBER9_sec_user_import_pre_scoping_fac_R_SRCFACID9_pregolive','U') is not null
drop table pcc_temp_storage.dbo._bkp_PMO59277_CaseR_CASENUMBER9_sec_user_import_pre_scoping_fac_R_SRCFACID9_pregolive

print  CHAR(13) + 'the below should be 0' 

select *  into pcc_temp_storage.dbo._bkp_PMO59277_CaseR_CASENUMBER9_sec_user_import_pre_scoping_fac_R_SRCFACID9_pregolive
from #temp where userid not in (select src_id from test_usei1214.dbo.EICaseR_CASENUMBER9sec_user) and loginname not like '%pcc-%' 

print  CHAR(13) + 'the above should be 0' 

print  CHAR(13) + 'Ended running : GAP cp_sec_user_audit - rescoping for fac R_SRCFACID9' 

print  CHAR(13) + 'Starting to run script : GAP import GAP of security users for fac R_SRCFACID9' 

print CHAR(13) + 'inserting deleted users if any'

insert into [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.sec_user
SELECT map.dst_id
	,R_DSTFACID9 
	,'EICaseR_CASENUMBER9'
	,getdate()
	,'EICaseR_CASENUMBER9'
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
	,default_admin_view,sso_only_user
from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.sec_user a
join [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.eicaseR_CASENUMBER9sec_user map
on a.userid = map.src_id
where a.userid in 
(select src_id from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.eicaseR_CASENUMBER9sec_user 
where dst_id not in (select userid from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.sec_user)
and dst_id not in (-10000,-998,1))

print CHAR(13) + 'importing new users if any'

if OBJECT_ID ('pcc_temp_storage.dbo.EIcaseR_CASENUMBER9_PGHC_sec_user_sameloginname_pregolive','U') is not null
DROP TABLE pcc_temp_storage.dbo.EIcaseR_CASENUMBER9_PGHC_sec_user_sameloginname_pregolive

if OBJECT_ID ('pcc_temp_storage.dbo.EIcaseR_CASENUMBER9_PGHC_sec_user_samelogin_different_name_pregolive','U') is not null
DROP TABLE pcc_temp_storage.dbo.EIcaseR_CASENUMBER9_PGHC_sec_user_samelogin_different_name_pregolive

if OBJECT_ID ('pcc_temp_storage.dbo.EIcaseR_CASENUMBER9_PGHC_sec_user_samelogin_same_name_pregolive','U') is not null
DROP TABLE pcc_temp_storage.dbo.EIcaseR_CASENUMBER9_PGHC_sec_user_samelogin_same_name_pregolive

if OBJECT_ID ('dbo.EIcaseR_CASENUMBER9sec_user_pregolive','U') is not null
DROP TABLE dbo.EIcaseR_CASENUMBER9sec_user_pregolive

--=========================================================
--Step 1. Import users that have different loginname
--a. Create backup for users with same loginname
--b. Import users
--=========================================================

select  a.* into pcc_temp_storage.dbo.EIcaseR_CASENUMBER9_PGHC_sec_user_sameloginname_pregolive
from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.sec_user a 
join  dbo.sec_user b 
on a.loginname = b.loginname
where a.fac_id = R_SRCFACID9
and a.loginname not like '%pcc-%' 
and a.loginname  not like '%wescom%' 
and a.userid not in (select src_id from EICaseR_CASENUMBER9sec_user)

insert into pcc_temp_storage.dbo.EIcaseR_CASENUMBER9_PGHC_sec_user_sameloginname_pregolive
select a.*
from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.sec_user a
join  dbo.sec_user b
on a.loginname = b.loginname
where a.userid in (select distinct userid from pcc_temp_storage.dbo._bkp_PMO59277_CaseR_CASENUMBER9_sec_user_import_pre_scoping_fac_R_SRCFACID9_pregolive) --userid from scoping

declare @MaxSecUserid int, @Rowcount int, @facid int

select identity(int,0,1) as row_id, src.userid as src_id, NULL as dst_id
into dbo.EIcaseR_CASENUMBER9sec_user_pregolive 
from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.sec_user src 
where fac_id = R_SRCFACID9 and loginname not like '%pcc-%' and loginname not like '%wescom%' 
and userid not in (select src_id from EICaseR_CASENUMBER9sec_user)
or userid in (select distinct userid from pcc_temp_storage.dbo._bkp_PMO59277_CaseR_CASENUMBER9_sec_user_import_pre_scoping_fac_R_SRCFACID9_pregolive)

set @Rowcount=@@rowcount
exec get_next_primary_key 'sec_user','userid',@MaxSecUserid output , @Rowcount

update  dbo.EIcaseR_CASENUMBER9sec_user_pregolive 
set  dst_id = row_id+@MaxSecUserid 

INSERT INTO dbo.sec_user
SELECT map.dst_id
	,R_DSTFACID9  
	,'EICaseR_CASENUMBER9'
	,getdate()
	,'EICaseR_CASENUMBER9'
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
	,default_admin_view,sso_only_user
FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.sec_user src
JOIN dbo.EIcaseR_CASENUMBER9sec_user_pregolive map ON src.userid = map.src_id
WHERE src.userid NOT IN (SELECT userid FROM pcc_temp_storage.dbo.EIcaseR_CASENUMBER9_PGHC_sec_user_sameloginname_pregolive)

INSERT INTO dbo.sec_user_facility (userid,facility_id,access_level)
SELECT DISTINCT a.dst_id
	,R_DSTFACID9   
	,src.access_level
FROM dbo.EIcaseR_CASENUMBER9sec_user_pregolive a join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.sec_user_facility src
on a.src_id = src.userid
WHERE src.userid NOT IN (SELECT userid FROM pcc_temp_storage.dbo.EIcaseR_CASENUMBER9_PGHC_sec_user_sameloginname_pregolive) and src.facility_id = R_SRCFACID9

--==================================================================================
--Step 2. Import users with same loginname but different long_username adding suffix
--==================================================================================

select  a.* into pcc_temp_storage.dbo.EIcaseR_CASENUMBER9_PGHC_sec_user_samelogin_different_name_pregolive
from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.sec_user a
join  dbo.sec_user b
on a.loginname = b.loginname
where a.fac_id = R_SRCFACID9 
and a.loginname not like '%pcc-%' and a.loginname  not like '%wescom%'
and a.long_username <> b.long_username
and a.userid not in (select src_id from EICaseR_CASENUMBER9sec_user)

insert into pcc_temp_storage.dbo.EIcaseR_CASENUMBER9_PGHC_sec_user_samelogin_different_name_pregolive
select a.*
from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.sec_user a
join  dbo.sec_user b
on a.loginname = b.loginname
where a.userid in (select distinct userid from pcc_temp_storage.dbo._bkp_PMO59277_CaseR_CASENUMBER9_sec_user_import_pre_scoping_fac_R_SRCFACID9_pregolive)--94 --userid from scoping
and a.long_username <> b.long_username

INSERT INTO dbo.sec_user
SELECT map.dst_id
	,R_DSTFACID9   
	,'EICaseR_CASENUMBER9'
	,getdate()
	,'EICaseR_CASENUMBER9'
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
	,default_admin_view,sso_only_user
FROM  [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.sec_user src 
JOIN dbo.EIcaseR_CASENUMBER9sec_user_pregolive map ON src.userid = map.src_id
and src_id IN (select userid from pcc_temp_storage.dbo.EIcaseR_CASENUMBER9_PGHC_sec_user_samelogin_different_name_pregolive)

INSERT INTO dbo.sec_user_facility (userid,facility_id,access_level)
SELECT DISTINCT a.dst_id
	,R_DSTFACID9   
	,src.access_level
FROM dbo.EIcaseR_CASENUMBER9sec_user_pregolive a join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.sec_user_facility src
on a.src_id = src.userid
JOIN pcc_temp_storage.dbo.EIcaseR_CASENUMBER9_PGHC_sec_user_samelogin_different_name_pregolive t on src.userid = t.userid
WHERE src.userid IN (SELECT userid FROM pcc_temp_storage.dbo.EIcaseR_CASENUMBER9_PGHC_sec_user_samelogin_different_name_pregolive) 
and src.facility_id = R_SRCFACID9

--================================
--Step 3. Update table for testing
--================================
ALTER TABLE dbo.EIcaseR_CASENUMBER9sec_user_pregolive
add corporate char
GO

update dbo.EIcaseR_CASENUMBER9sec_user_pregolive
set corporate = 'N'

--============================================================================
--Step 4. Import users with same login and same name by adding mapping
--============================================================================

select  a.* into pcc_temp_storage.dbo.EIcaseR_CASENUMBER9_PGHC_sec_user_samelogin_same_name_pregolive
from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.sec_user a
join  dbo.sec_user b
on a.loginname = b.loginname
where a.fac_id = R_SRCFACID9 
and a.loginname not like '%pcc-%' and a.loginname  not like '%wescom%'
and a.long_username = b.long_username 
and b.created_by not like '%EICaseR_CASENUMBER9%'
and a.userid not in (select src_id from EICaseR_CASENUMBER9sec_user)

insert  into pcc_temp_storage.dbo.EIcaseR_CASENUMBER9_PGHC_sec_user_samelogin_same_name_pregolive
select a.*
from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.sec_user a
join  dbo.sec_user b
on a.loginname = b.loginname
where a.userid in (select distinct userid from pcc_temp_storage.dbo._bkp_PMO59277_CaseR_CASENUMBER9_sec_user_import_pre_scoping_fac_R_SRCFACID9_pregolive)
and a.long_username = b.long_username 
and b.created_by not like '%EICaseR_CASENUMBER9%' 

update map
set dst_id = ur.userid, corporate = 'Y'
FROM dbo.EIcaseR_CASENUMBER9sec_user_pregolive map 
JOIN pcc_temp_storage.dbo.EIcaseR_CASENUMBER9_PGHC_sec_user_samelogin_same_name_pregolive ln ON ln.userid = map.src_id
JOIN sec_user ur ON ln.loginname = ur.loginname

INSERT INTO sec_user_physical_id (userid,sequence,physicalid)
SELECT b.dst_id
	,[sequence]
	,[physicalid]
FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].sec_user_physical_id src
JOIN dbo.EIcaseR_CASENUMBER9sec_user_pregolive b ON b.src_id = src.userid 
where b.corporate = 'N' 

SET IDENTITY_INSERT EIcaseR_CASENUMBER9sec_user ON 

insert into EIcaseR_CASENUMBER9sec_user (row_id,src_id,dst_id,corporate)
select row_id, src_id,dst_id,corporate from EIcaseR_CASENUMBER9sec_user_pregolive
where src_id not in (select src_id from EIcaseR_CASENUMBER9sec_user) 

SET IDENTITY_INSERT EIcaseR_CASENUMBER9sec_user OFF

----From second facility and onwards

--update map
--set dst_id = ur.userid, corporate='Y'
----select map.src_id, ln.userid, map.dst_id, ur.userid, * 
----select *
--FROM dbo.EICaseR_CASENUMBER9sec_user map 
--join pcc_temp_storage.dbo.EICaseR_CASENUMBER9_PGHC_sec_user_samelogin_different_name ln on map.src_id = ln.userid
--JOIN sec_user ur ON ln.loginname+ 'PGHC' = ur.loginname--3
--where ur.created_by like 'EICaseR_CASENUMBER9' --prev facility

print CHAR(13) + 'performing final checks'

print CHAR(13) + 'all results below should be 0'

--select * from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].sec_user where fac_id in (R_SRCFACID9) and created_date >= '????-??-??'
--and loginname not like '%pcc-%'

select distinct noted_by,'fac R_SRCFACID9'  from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_admin_order a
join [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_phys_order b
on a.phys_order_id = b.phys_order_id 
where b.fac_id in (R_SRCFACID9)
and noted_by not in (select src_id from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.EIcaseR_CASENUMBER9sec_user)

select distinct strikeout_by_id,'fac R_SRCFACID9'  from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].inc_incident 
where fac_id in (R_SRCFACID9)
and strikeout_by_id not in (select src_id from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.EIcaseR_CASENUMBER9sec_user)

select * from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.EIcaseR_CASENUMBER9sec_user
where dst_id not in (select userid from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.sec_user)
and dst_id not in (-10000,-998,1)

update sec_user
set admin_user_type = 'E'
--select * 
FROM dbo.sec_user  
where loginname like '[_]api[_]%'
and (created_by like '%EIcaseR_CASENUMBER9%' or userid in (select dst_id from EIcaseR_CASENUMBER9sec_user where corporate = 'N'))
and admin_user_type is NULL


print CHAR(13) + 'all results above should be 0'

print  CHAR(13) + 'Ended running script : import GAP of security users for fac R_SRCFACID9' 

/* Latest Test Results



*/

/* Go Live Results



*/