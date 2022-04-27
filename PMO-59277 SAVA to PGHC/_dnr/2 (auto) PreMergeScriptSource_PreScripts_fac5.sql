USE test_usei3sava1
--GO

--========================================================================================

print  CHAR(13) + ' DS Helper Error for Care Plan - Copy Library ' 

update cp_std_intervention
set std_freq_id = NULL
from cp_std_intervention
where std_freq_id is not NULL
and std_freq_id in (0,30)

---------------------------------------

update cp_std_intervention
set poc_std_freq_id = NULL
--select *
from cp_std_intervention
--where poc_std_freq_id in (89,90)
where poc_std_freq_id is not null

--========================================================================================

print  CHAR(13) + 'removing duplicates' 

SELECT userid
	,long_username
	,isnull(staff_id, 1) AS 'staff_id'
	,loginname
	,isnull(position_id, 2) AS 'position_id'
	,isnull(position_description, 3) AS 'position_description'
	,isnull(alternate_loginname, 4) AS 'alternate_loginname'
	,isnull(initials, 5) AS 'initials'
	,isnull(designation_desc, 6) AS 'designation_desc'
INTO #tempcp
FROM cp_sec_user_audit
GROUP BY userid
	,long_username
	,isnull(staff_id, 1)
	,loginname
	,isnull(position_id, 2)
	,isnull(position_description, 3)
	,isnull(alternate_loginname, 4)
	,isnull(initials, 5)
	,isnull(designation_desc, 6)
HAVING count(*) > 1 --

update cp_sec_user_audit
set position_description = position_description + convert(varchar(5), fac_id)
--select * from cp_sec_user_audit
where userid in (select distinct userid from #tempcp) 
and position_description is not null

update cp_sec_user_audit
set position_description = convert(varchar(5), fac_id)
--select * from cp_sec_user_audit
where userid in (select distinct userid from #tempcp) 
and position_description is null 

--========================================================================================

print  CHAR(13) + 'CP_Sec_user_audit scoping running now for sec_user' 
print  CHAR(13) + '*** IF SEC PRE-IMPORT -- DO NOT RUN ***' 

update sec_user  
set fac_id = R_SRCFACID5
--select * from sec_user  
where userid in 
(select userid from cp_sec_user_audit where cp_sec_user_audit_id  in (select created_user_audit_id from as_footnote 
where client_id in (select client_id from clients where fac_id in (R_SRCFACID5))) and fac_id not in (R_SRCFACID5))
and fac_id not in (R_SRCFACID5)

update s
set fac_id = R_SRCFACID5
--select distinct s.* 
from pho_admin_order a
join pho_phys_order b on a.phys_order_id=b.phys_order_id
join sec_user s on a.noted_by=s.userid
where b.fac_id in (R_SRCFACID5) and s.fac_id not in (R_SRCFACID5)

UPDATE sec_user 
SET fac_id = R_SRCFACID5 
--select distinct userid,fac_id from sec_user 
where userid in (SELECT distinct a.userid FROM cp_sec_user_audit a 
JOIN pho_phys_order_useraudit b on a.cp_sec_user_audit_id = b.created_by_audit_id 
JOIN pho_phys_order c on b.phys_order_id = c.phys_order_id 
WHERE c.fac_id in (R_SRCFACID5))  
and fac_id not in (R_SRCFACID5) 

update b
set fac_id = R_SRCFACID5
--select * 
from sec_user b
where userid in 
(select userid from cp_sec_user_audit where cp_sec_user_audit_id in 
(select created_by_audit_id from pho_std_order where  fac_id  in (-1,R_SRCFACID5)
union 
select revision_by_audit_id from pho_std_order where  fac_id  in (-1,R_SRCFACID5)
union 
select published_by_audit_id from pho_std_order where  fac_id  in (-1,R_SRCFACID5)
union 
select retired_by_audit_id from pho_std_order where  fac_id  in (-1,R_SRCFACID5)
union 
select reactivated_by_audit_id from pho_std_order where  fac_id  in (-1,R_SRCFACID5))
and fac_id not in (R_SRCFACID5))
and fac_id not in (R_SRCFACID5)

UPDATE sec_user 
SET fac_id = R_SRCFACID5 
--select distinct userid,fac_id from sec_user 
where userid in (SELECT distinct a.userid FROM cp_sec_user_audit a 
JOIN allergy b on a.cp_sec_user_audit_id = b.created_user_audit_id 
where b.client_id in (select client_id from clients where fac_id in (R_SRCFACID5)))  
and userid not in (-10000, -998)
and fac_id not in (R_SRCFACID5) 

UPDATE sec_user 
SET fac_id = R_SRCFACID5 
--select distinct userid,fac_id from sec_user 
where userid in (SELECT distinct a.userid FROM cp_sec_user_audit a 
JOIN allergy b on a.cp_sec_user_audit_id = b.revision_user_audit_id 
where b.client_id in (select client_id from clients where fac_id in (R_SRCFACID5)))  
and userid not in (-10000, -998)
and fac_id not in (R_SRCFACID5) 

UPDATE sec_user 
SET fac_id = R_SRCFACID5 
--select distinct userid,fac_id from sec_user 
where userid in (SELECT distinct a.userid FROM cp_sec_user_audit a 
JOIN allergy_audit b on a.cp_sec_user_audit_id = b.created_user_audit_id 
where b.client_id in (select client_id from clients where fac_id in (R_SRCFACID5)))  
and userid not in (-10000, -998)
and fac_id not in (R_SRCFACID5) 

UPDATE sec_user 
SET fac_id = R_SRCFACID5 
--select distinct userid,fac_id from sec_user 
where userid in (SELECT distinct a.userid FROM cp_sec_user_audit a 
JOIN allergy_audit b on a.cp_sec_user_audit_id = b.revision_user_audit_id 
where b.client_id in (select client_id from clients where fac_id in (R_SRCFACID5)))  
and userid not in (-10000, -998)
and fac_id not in (R_SRCFACID5) 

update sec_user  
set fac_id = R_SRCFACID5
--select * from sec_user
where userid in (select userid from cp_sec_user_audit
where cp_sec_user_audit_id in  (select  sec_user_audit_id from  immunization_strikeout
where immunization_id in (select  immunization_id  from  cr_client_immunization
where fac_id in (R_SRCFACID5))) and  fac_id not in (R_SRCFACID5))
and fac_id not in (R_SRCFACID5)

update s
set fac_id = R_SRCFACID5
--select  distinct admin_user_type,f.facility_id,s.userid,s.loginname 
--select distinct admin_user_type,s.* 
from mpi_history b 
join sec_user s on b.user_id=s.userid
left join sec_user_facility f on b.user_id=f.userid
where b.fac_id in (R_SRCFACID5) and s.fac_id not in (R_SRCFACID5) and (facility_id in (R_SRCFACID5) or admin_user_type ='E')

update sec_user  
set fac_id = R_SRCFACID5
--select * from sec_user 
where userid in (select userid from cp_sec_user_audit
where cp_sec_user_audit_id in  (select  sec_user_audit_id from immunization_strikeout
where immunization_id in (select  immunization_id  from   cr_client_immunization
where fac_id in (R_SRCFACID5)))
and  fac_id not in (R_SRCFACID5))
and fac_id not in (R_SRCFACID5)

update sec_user  
set fac_id = R_SRCFACID5
--select * from sec_user 
where userid in  (select  administered_by_id from cr_client_immunization
where fac_id in (R_SRCFACID5))
and  fac_id not in (R_SRCFACID5)

update sec_user  
set fac_id = R_SRCFACID5
--select * from sec_user 
where userid in  (select  administered_by_id from cr_client_immunization_audit
where fac_id in (R_SRCFACID5))
and  fac_id not in (R_SRCFACID5)

update sec_user  
set fac_id = R_SRCFACID5
--select * from sec_user  
where userid in (select userid from cp_sec_user_audit
where cp_sec_user_audit_id  in (select strikeout_user_audit_id from allergy_strikeout s
JOIN allergy b on s.allergy_id = b.allergy_id 
where client_id in (select client_id from clients where fac_id in (R_SRCFACID5)))
and fac_id not in (R_SRCFACID5))
and fac_id not in (R_SRCFACID5)

update sec_user  
set fac_id = R_SRCFACID5
--select * from sec_user
where userid in (select userid from cp_sec_user_audit  
where cp_sec_user_audit_id  in (select strikeout_user_audit_id from diagnosis_strikeout
where client_diagnosis_id in (select client_diagnosis_id from diagnosis where fac_id in (R_SRCFACID5)))
and fac_id not in (R_SRCFACID5))
and fac_id not in (R_SRCFACID5)
and fac_id not in (R_SRCFACID5)

update sec_user
set fac_id = R_SRCFACID5
--select * 
from sec_user
where userid in (select userid from cp_sec_user_audit
where cp_sec_user_audit_id in (
	select created_by_audit_id from pho_admin_order_useraudit a
	JOIN pho_admin_order b on a.admin_order_id = b.admin_order_id 
	JOIN pho_phys_order c on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id in (R_SRCFACID5) 
union 
	select edited_by_audit_id from pho_admin_order_useraudit a
	JOIN pho_admin_order b on a.admin_order_id = b.admin_order_id 
	JOIN pho_phys_order c on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id in (R_SRCFACID5) 
union 
	select confirmed_by_audit_id from pho_admin_order_useraudit a
	JOIN pho_admin_order b on a.admin_order_id = b.admin_order_id 
	JOIN pho_phys_order c on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id in (R_SRCFACID5) 
) and fac_id not in (R_SRCFACID5))
and fac_id not in (R_SRCFACID5)

update sec_user
set fac_id = R_SRCFACID5
--select * 
from sec_user
where userid in (select userid from cp_sec_user_audit
where cp_sec_user_audit_id in (
	select created_by_audit_id from pho_admin_order_useraudit a
	JOIN pho_admin_order_audit b on a.admin_order_id = b.admin_order_id 
	JOIN pho_phys_order c on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id in (R_SRCFACID5) 
union 
	select edited_by_audit_id from pho_admin_order_useraudit a
	JOIN pho_admin_order_audit b on a.admin_order_id = b.admin_order_id 
	JOIN pho_phys_order c on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id in (R_SRCFACID5) 
union 
	select confirmed_by_audit_id from pho_admin_order_useraudit a
	JOIN pho_admin_order_audit b on a.admin_order_id = b.admin_order_id 
	JOIN pho_phys_order c on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id in (R_SRCFACID5)
) and fac_id not in (R_SRCFACID5))
and fac_id not in (R_SRCFACID5)

UPDATE s 
SET fac_id = R_SRCFACID5 
--select * 
from sec_user s
where userid in (select userid from cp_sec_user_audit where cp_sec_user_audit_id in 
(SELECT distinct followupby_useraudit_id FROM pho_schedule_details_followup_useraudit b 
JOIN pho_schedule_details c on b.schedule_detail_id = c.pho_schedule_detail_id
JOIN pho_schedule d ON d.schedule_id=c.pho_schedule_id
WHERE d.fac_id in (R_SRCFACID5))  
and fac_id not in (R_SRCFACID5))
and fac_id not in (R_SRCFACID5)

UPDATE s
SET fac_id = R_SRCFACID5
--SELECT *
from sec_user s where userid in (select userid from cp_sec_user_audit
where cp_sec_user_audit_id in (select cp_sec_user_audit_id FROM pho_phys_order_sign
WHERE phys_order_id IN (SELECT distinct phys_order_id FROM pho_phys_order WHERE fac_id in (R_SRCFACID5)))
AND fac_id not in (R_SRCFACID5))
and fac_id not in (R_SRCFACID5)

update sec_user
set fac_id = R_SRCFACID5
--select *
where userid in (select userid from cp_sec_user_audit where cp_sec_user_audit_id in 
(select created_cp_sec_user_audit_id from pho_formulary_item_custom_library
where custom_drug_id in (select custom_drug_id from cr_cust_med where fac_id in (-1,R_SRCFACID5))
union
select revision_cp_sec_user_audit_id from pho_formulary_item_custom_library
where custom_drug_id in (select custom_drug_id from cr_cust_med where fac_id in (-1,R_SRCFACID5))) 
and fac_id not in (-1,R_SRCFACID5) 
and cp_sec_user_audit_id not in (-998,-10000))
and fac_id  not in (R_SRCFACID5)

update sec_user
SET fac_id = R_SRCFACID5
where userid in (
select userid from cp_sec_user_audit 
where cp_sec_user_audit_id in (
SELECT DISTINCT b.created_by_audit_id
FROM pho_phys_order_audit_useraudit b
JOIN cp_sec_user_audit ba ON b.created_by_audit_id = ba.cp_sec_user_audit_id
join  pho_phys_order_useraudit pa on pa.created_by_audit_id=ba.cp_sec_user_audit_id
JOIN pho_phys_order c ON pa.phys_order_id = c.phys_order_id
WHERE c.fac_id IN (R_SRCFACID5))
and fac_id not in (R_SRCFACID5)
and userid not in (-998,-10000))

update sec_user
SET fac_id = R_SRCFACID5
where userid in (
select userid from cp_sec_user_audit 
where cp_sec_user_audit_id in (
SELECT DISTINCT b.edited_by_audit_id
FROM pho_phys_order_audit_useraudit b
JOIN cp_sec_user_audit ba ON b.edited_by_audit_id = ba.cp_sec_user_audit_id
join  pho_phys_order_useraudit pa on pa.edited_by_audit_id=ba.cp_sec_user_audit_id
JOIN pho_phys_order c ON pa.phys_order_id = c.phys_order_id
WHERE c.fac_id IN (R_SRCFACID5))
and fac_id not in (R_SRCFACID5)
and userid not in (-998,-10000))

update s
set fac_id = R_SRCFACID5
--select distinct a.fac_id, s.*
from inc_incident a
join sec_user s on a.strikeout_by_id = s.userid
where a.fac_id IN (R_SRCFACID5) and s.fac_id not in (R_SRCFACID5)

--========================================================================================

print  CHAR(13) + 'check loginname running now ' 
print  CHAR(13) + '*** IF SEC PRE-IMPORT -- DO NOT RUN ***' 

update src
set src.loginname = src.loginname + 'SAVA'
--SELECT src.fac_id as src_fac_id,src.long_username as 'long_username in SRC',dst.long_username as 'long_username in DEST',src.loginname as 'loginname in SRC',dst.loginname as 'loginname in DEST'
FROM test_usei3sava1.dbo.sec_user src
JOIN [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.sec_user dst ON src.loginname = dst.loginname
      AND src.long_username <> dst.long_username 
      AND src.fac_id in (R_SRCFACID5)

update src
set src.loginname = src.loginname + 'SAVA'
--SELECT src.fac_id as src_fac_id,src.long_username as 'long_username in SRC',dst.long_username as 'long_username in DEST',src.loginname as 'loginname in SRC',dst.loginname as 'loginname in DEST'
FROM test_usei3sava1.dbo.sec_user src
JOIN [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.sec_user dst ON src.loginname = dst.loginname
      AND src.long_username <> dst.long_username 
      AND src.fac_id in (R_SRCFACID5) 

update src
set src.loginname = src.loginname + 'SAVA'
--SELECT src.fac_id as src_fac_id,src.long_username as 'long_username in SRC',dst.long_username as 'long_username in DEST',src.loginname as 'loginname in SRC',dst.loginname as 'loginname in DEST'
FROM test_usei3sava1.dbo.sec_user src
JOIN [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.sec_user dst ON src.loginname = dst.loginname
      AND src.long_username <> dst.long_username 
      AND src.fac_id in (R_SRCFACID5) 
	  
print  CHAR(13) + 'if above is not zero --> add another prefix to avoid duplicates (login names)' 

--========================================================================================

print  CHAR(13) + 'CP_Sec_user_audit scoping running now for cp_sec_user_audit_id' 


UPDATE [dbo].cp_sec_user_audit
SET fac_id = R_SRCFACID5
--select * from [dbo].cp_sec_user_audit
WHERE cp_sec_user_audit_id IN (
		SELECT DISTINCT b.created_by_audit_id
		FROM [dbo].pho_phys_order_audit_useraudit b
		JOIN pho_phys_order_audit pa ON pa.audit_id = b.audit_id
		WHERE pa.fac_id IN (R_SRCFACID5)
		)
	AND fac_id NOT IN (R_SRCFACID5)
	AND userid NOT IN (
		- 998
		,- 10000
		) --0

UPDATE [dbo].cp_sec_user_audit
SET fac_id = R_SRCFACID5
--select * from [dbo].cp_sec_user_audit
WHERE cp_sec_user_audit_id IN (
		SELECT DISTINCT b.edited_by_audit_id
		FROM [dbo].pho_phys_order_audit_useraudit b
		JOIN pho_phys_order_audit pa ON pa.audit_id = b.audit_id
		WHERE pa.fac_id IN (R_SRCFACID5)
		)
	AND fac_id NOT IN (R_SRCFACID5)
	AND userid NOT IN (
		- 998
		,- 10000
		) --0

UPDATE [dbo].cp_sec_user_audit
SET fac_id = R_SRCFACID5
--select * from [dbo].cp_sec_user_audit
WHERE cp_sec_user_audit_id IN (
		SELECT DISTINCT b.created_by_audit_id
		FROM [dbo].[pho_phys_order_useraudit] b
		JOIN pho_phys_order pa ON pa.phys_order_id = b.phys_order_id
		WHERE pa.fac_id IN (R_SRCFACID5)
		)
	AND fac_id NOT IN (R_SRCFACID5)
	AND userid NOT IN (
		- 998
		,- 10000
		) --0

UPDATE [dbo].cp_sec_user_audit
SET fac_id = R_SRCFACID5
--select * from [dbo].cp_sec_user_audit
WHERE cp_sec_user_audit_id IN (
		SELECT DISTINCT b.edited_by_audit_id
		FROM [dbo].[pho_phys_order_useraudit] b
		JOIN pho_phys_order pa ON pa.phys_order_id = b.phys_order_id
		WHERE pa.fac_id IN (R_SRCFACID5)
		)
	AND fac_id NOT IN (R_SRCFACID5)
	AND userid NOT IN (
		- 998
		,- 10000
		) --0

UPDATE [dbo].cp_sec_user_audit
SET fac_id = R_SRCFACID5
--select * from [dbo].cp_sec_user_audit
WHERE cp_sec_user_audit_id IN (
		SELECT DISTINCT b.confirmed_by_audit_id
		FROM [dbo].[pho_phys_order_useraudit] b
		JOIN pho_phys_order pa ON pa.phys_order_id = b.phys_order_id
		WHERE pa.fac_id IN (R_SRCFACID5)
		)
	AND fac_id NOT IN (R_SRCFACID5)
	AND userid NOT IN (
		- 998
		,- 10000
		) --0

update cp_sec_user_audit  
set fac_id = R_SRCFACID5
--select * from cp_sec_user_audit  
where cp_sec_user_audit_id  in 
(select a.cp_sec_user_audit_id 
from pho_order_related_value a with (nolock)
 inner join pho_schedule_details c with (nolock) on a.schedule_detail_id = c.pho_schedule_detail_id
 inner join pho_schedule d with (nolock) on c.pho_schedule_id = d.schedule_id
where d.fac_id in (R_SRCFACID5))
and fac_id not in (R_SRCFACID5) 

update cp_sec_user_audit  
set fac_id = R_SRCFACID5
--select * from cp_sec_user_audit  
where cp_sec_user_audit_id  in 
(select createdby_useraudit_id 
from pho_schedule_details_reminder a
join pho_schedule_details b on a.pho_schedule_detail_id = b.pho_schedule_detail_id
join pho_schedule c on b.pho_schedule_id = c.schedule_id
where c.fac_id in (R_SRCFACID5))
and fac_id not in (R_SRCFACID5) 

update cp_sec_user_audit  
set fac_id = R_SRCFACID5
--select * from cp_sec_user_audit  
where cp_sec_user_audit_id  in (select created_user_audit_id from as_footnote 
where client_id in (select client_id from clients where fac_id in (R_SRCFACID5)))
and fac_id not in (R_SRCFACID5) 

UPDATE cp_sec_user_audit 
SET fac_id = R_SRCFACID5 ,initials = null
--select * from cp_sec_user_audit 
where cp_sec_user_audit_id in (
SELECT a.cp_sec_user_audit_id FROM (
select  * from cp_sec_user_audit 
where  cp_sec_user_audit_id in (SELECT distinct created_by_audit_id FROM pho_phys_order_useraudit b 
JOIN pho_phys_order c on b.phys_order_id = c.phys_order_id 
WHERE c.fac_id in (R_SRCFACID5))  
and fac_id not in (R_SRCFACID5)) a
join cp_sec_user_audit  b
on a.userid=b.userid and
a.long_username=b.long_username and
a.loginname=b.loginname and
a.position_id=b.position_id and
a.position_description=b.position_description and
a.initials= b.initials 
where b.fac_id in (R_SRCFACID5))

UPDATE cp_sec_user_audit 
SET fac_id = R_SRCFACID5 
--select * from cp_sec_user_audit 
where cp_sec_user_audit_id in (
SELECT a.cp_sec_user_audit_id FROM (
select  * from cp_sec_user_audit 
where  cp_sec_user_audit_id in (SELECT distinct created_by_audit_id FROM pho_phys_order_useraudit b 
JOIN pho_phys_order c on b.phys_order_id = c.phys_order_id 
WHERE c.fac_id in (R_SRCFACID5))  
and fac_id not in (R_SRCFACID5)) a) 

update a
set fac_id = R_SRCFACID5
--select * 
from cp_sec_user_audit a
where cp_sec_user_audit_id in (
select created_by_audit_id from pho_std_order_set where  fac_id  in (-1,R_SRCFACID5)
union 
select revision_by_audit_id from pho_std_order_set where  fac_id  in (-1,R_SRCFACID5)
union 
select published_by_audit_id from pho_std_order_set where  fac_id  in (-1,R_SRCFACID5)
union 
select retired_by_audit_id from pho_std_order_set where  fac_id  in (-1,R_SRCFACID5)
union 
select reactivated_by_audit_id from pho_std_order_set where  fac_id  in (-1,R_SRCFACID5))
and fac_id not in (R_SRCFACID5) 

update a
set fac_id = R_SRCFACID5
--select * 
from cp_sec_user_audit a
where cp_sec_user_audit_id in (
select distinct created_by_audit_id from pho_std_order where  fac_id  in (-1,R_SRCFACID5)
union 
select distinct revision_by_audit_id from pho_std_order where  fac_id  in (-1,R_SRCFACID5)
union 
select distinct published_by_audit_id from pho_std_order where  fac_id  in (-1,R_SRCFACID5)
union 
select distinct retired_by_audit_id from pho_std_order where  fac_id  in (-1,R_SRCFACID5)
union 
select distinct reactivated_by_audit_id from pho_std_order where  fac_id  in (-1,R_SRCFACID5))
and fac_id not in (R_SRCFACID5) 

--allergy
update cp_sec_user_audit  
set fac_id = R_SRCFACID5
--select * from cp_sec_user_audit  
where cp_sec_user_audit_id  in (select created_user_audit_id from allergy 
where client_id in (select client_id from clients where fac_id in (R_SRCFACID5)))
and fac_id not in (R_SRCFACID5) 
and userid not in (-10000, -998)

update cp_sec_user_audit  
set fac_id = R_SRCFACID5
--select * from cp_sec_user_audit  
where cp_sec_user_audit_id  in (select revision_user_audit_id from allergy 
where client_id in (select client_id from clients where fac_id in (R_SRCFACID5)))
and fac_id not in (R_SRCFACID5) 
and userid not in (-10000, -998)

update b
set fac_id = R_SRCFACID5
--select * 
from sec_user b
where userid in 
(select userid from cp_sec_user_audit where cp_sec_user_audit_id in 
(select created_by_audit_id from pho_std_order_set where  fac_id  in (-1,R_SRCFACID5)
union 
select revision_by_audit_id from pho_std_order_set where  fac_id  in (-1,R_SRCFACID5)
union 
select published_by_audit_id from pho_std_order_set where  fac_id  in (-1,R_SRCFACID5)
union 
select retired_by_audit_id from pho_std_order_set where  fac_id  in (-1,R_SRCFACID5)
union 
select reactivated_by_audit_id from pho_std_order_set where  fac_id  in (-1,R_SRCFACID5))
and fac_id not in (R_SRCFACID5))
and fac_id not in (R_SRCFACID5)

update cp_sec_user_audit  
set fac_id = R_SRCFACID5
--select * from cp_sec_user_audit  
where cp_sec_user_audit_id  in (select created_user_audit_id from allergy_audit 
where client_id in (select client_id from clients where fac_id in (R_SRCFACID5)))
and fac_id not in (R_SRCFACID5) 
and userid not in (-10000, -998)

update cp_sec_user_audit  
set fac_id = R_SRCFACID5
--select * from cp_sec_user_audit  
where cp_sec_user_audit_id  in (select revision_user_audit_id from allergy_audit 
where client_id in (select client_id from clients where fac_id in (R_SRCFACID5)))
and fac_id not in (R_SRCFACID5) 
and userid not in (-10000, -998)

update cp_sec_user_audit  
set fac_id = R_SRCFACID5
--select * from cp_sec_user_audit 
where cp_sec_user_audit_id in  (select  sec_user_audit_id from  immunization_strikeout
where immunization_id in (select  immunization_id  from  cr_client_immunization
where fac_id in (R_SRCFACID5)))
and  fac_id not in (R_SRCFACID5)

update cp_sec_user_audit  
set fac_id = R_SRCFACID5
--select * from cp_sec_user_audit 
where cp_sec_user_audit_id in  (select  sec_user_audit_id from immunization_strikeout
where immunization_id in (select  immunization_id  from   cr_client_immunization
where fac_id in (R_SRCFACID5)))
and  fac_id not in (R_SRCFACID5) 

update cp_sec_user_audit  
set fac_id = R_SRCFACID5
--select * from cp_sec_user_audit  
where cp_sec_user_audit_id  in (select strikeout_user_audit_id from allergy_strikeout s
JOIN allergy b on s.allergy_id = b.allergy_id 
where client_id in (select client_id from clients where fac_id in (R_SRCFACID5)))
and fac_id not in (R_SRCFACID5)

update cp_sec_user_audit  
set fac_id = R_SRCFACID5
--select * from cp_sec_user_audit  
where cp_sec_user_audit_id  in (select strikeout_user_audit_id from diagnosis_strikeout
where client_diagnosis_id in (select client_diagnosis_id from diagnosis where fac_id in (R_SRCFACID5)))
and fac_id not in (R_SRCFACID5)

update au
set fac_id = R_SRCFACID5
--select * 
from cp_sec_user_audit au
where cp_sec_user_audit_id in (
	select created_by_audit_id from pho_admin_order_useraudit a
	JOIN pho_admin_order b on a.admin_order_id = b.admin_order_id 
	JOIN pho_phys_order c on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id in (R_SRCFACID5) 
union 
	select edited_by_audit_id from pho_admin_order_useraudit a
	JOIN pho_admin_order b on a.admin_order_id = b.admin_order_id 
	JOIN pho_phys_order c on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id in (R_SRCFACID5) 
union 
	select confirmed_by_audit_id from pho_admin_order_useraudit a
	JOIN pho_admin_order b on a.admin_order_id = b.admin_order_id 
	JOIN pho_phys_order c on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id in (R_SRCFACID5) )
and fac_id not in (R_SRCFACID5) 

update au
set fac_id = R_SRCFACID5
--select * 
from cp_sec_user_audit au
where cp_sec_user_audit_id in (
	select created_by_audit_id from pho_admin_order_audit_useraudit a
	JOIN pho_admin_order_audit b on a.audit_id = b.audit_id 
	JOIN pho_phys_order c on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id in (R_SRCFACID5) 

union 
	select edited_by_audit_id from pho_admin_order_audit_useraudit a
	JOIN pho_admin_order_audit b on a.audit_id = b.audit_id 
	JOIN pho_phys_order c on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id in (R_SRCFACID5) 
union 
	select confirmed_by_audit_id from pho_admin_order_audit_useraudit a
	JOIN pho_admin_order_audit b on a.audit_id = b.audit_id 
	JOIN pho_phys_order c on b.phys_order_id = c.phys_order_id
	WHERE c.fac_id in (R_SRCFACID5) )
and fac_id not in (R_SRCFACID5) 

UPDATE cp_sec_user_audit 
SET fac_id = R_SRCFACID5 
--select * from cp_sec_user_audit 
where cp_sec_user_audit_id in 
(SELECT distinct followupby_useraudit_id FROM pho_schedule_details_followup_useraudit b 
JOIN pho_schedule_details c on b.schedule_detail_id = c.pho_schedule_detail_id
JOIN pho_schedule d ON d.schedule_id=c.pho_schedule_id
WHERE d.fac_id in (R_SRCFACID5))  
and fac_id not in (R_SRCFACID5)

UPDATE cp_sec_user_audit
SET fac_id = R_SRCFACID5
--SELECT *
from cp_sec_user_audit
where cp_sec_user_audit_id in
(select cp_sec_user_audit_id FROM pho_phys_order_sign
WHERE phys_order_id IN (SELECT distinct phys_order_id FROM pho_phys_order WHERE fac_id in (R_SRCFACID5)))
AND fac_id not in (R_SRCFACID5)

update cp_sec_user_audit
set fac_id = R_SRCFACID5
--select *
from cp_sec_user_audit where cp_sec_user_audit_id in 
(select created_cp_sec_user_audit_id from pho_formulary_item_custom_library
where custom_drug_id in (select custom_drug_id from cr_cust_med where fac_id in (-1,R_SRCFACID5))) 
and fac_id not in (-1,R_SRCFACID5) 
and cp_sec_user_audit_id not in (-998,-10000)

update cp_sec_user_audit
set fac_id = R_SRCFACID5
--select *
from cp_sec_user_audit where cp_sec_user_audit_id in 
(select revision_cp_sec_user_audit_id from pho_formulary_item_custom_library
where custom_drug_id in (select custom_drug_id from cr_cust_med where fac_id in (-1,R_SRCFACID5))) 
and fac_id not in (-1,R_SRCFACID5) 
and cp_sec_user_audit_id not in (-998,-10000)

update cp_sec_user_audit 
SET fac_id = R_SRCFACID5 
--select * from cp_sec_user_audit 
where cp_sec_user_audit_id in (
SELECT DISTINCT b.created_by_audit_id
FROM pho_phys_order_audit_useraudit b
JOIN cp_sec_user_audit ba ON b.created_by_audit_id = ba.cp_sec_user_audit_id
join  pho_phys_order_useraudit pa on pa.created_by_audit_id=ba.cp_sec_user_audit_id
JOIN pho_phys_order c ON pa.phys_order_id = c.phys_order_id
WHERE c.fac_id IN (R_SRCFACID5))
and fac_id not in (R_SRCFACID5)
and userid not in (-998,-10000)

update cp_sec_user_audit 
SET fac_id = R_SRCFACID5
--select * from cp_sec_user_audit 
where cp_sec_user_audit_id in (
SELECT DISTINCT b.created_by_audit_id
FROM pho_phys_order_audit_useraudit b
JOIN cp_sec_user_audit ba ON b.created_by_audit_id = ba.cp_sec_user_audit_id
join  pho_phys_order_audit pa on pa.audit_id=b.audit_id
--JOIN pho_phys_order c ON pa.phys_order_id = c.phys_order_id
WHERE pa.fac_id IN (R_SRCFACID5))
and fac_id not in (R_SRCFACID5)
and userid not in (-998,-10000)

update cp_sec_user_audit 
SET fac_id = R_SRCFACID5 
--select * from cp_sec_user_audit 
where cp_sec_user_audit_id in (
SELECT DISTINCT b.edited_by_audit_id
FROM pho_phys_order_audit_useraudit b
JOIN cp_sec_user_audit ba ON b.edited_by_audit_id = ba.cp_sec_user_audit_id
join  pho_phys_order_useraudit pa on pa.edited_by_audit_id=ba.cp_sec_user_audit_id
JOIN pho_phys_order c ON pa.phys_order_id = c.phys_order_id
WHERE c.fac_id IN (R_SRCFACID5))
and fac_id not in (R_SRCFACID5)
and userid not in (-998,-10000) 

UPDATE cp_sec_user_audit 
SET fac_id = R_SRCFACID5 
--select * from [dbo].cp_sec_user_audit 
where cp_sec_user_audit_id in (
SELECT a.cp_sec_user_audit_id FROM (
select  * from [dbo].cp_sec_user_audit 
where  cp_sec_user_audit_id in (SELECT distinct edited_by_audit_id FROM [dbo].pho_phys_order_useraudit b 
JOIN [dbo].pho_phys_order c on b.phys_order_id = c.phys_order_id 
WHERE c.fac_id IN (R_SRCFACID5))  
and fac_id not in (R_SRCFACID5)) a
) and userid not in (-10000, -998)

update c
set c.fac_id = R_SRCFACID5
--select * 
from [dbo].pho_phys_order_blackbox_acknowledgement a
join [dbo].pho_phys_order b on a.phys_order_id = b.phys_order_id
join [dbo].cp_sec_user_audit c on a.cp_sec_user_audit_id = c.cp_sec_user_audit_id
where b.fac_id = R_SRCFACID5 and c.fac_id <> R_SRCFACID5

--========================================================================================

print  CHAR(13) + 'CONTACT - Contact Number running now' 

DECLARE @pad VARCHAR(MAX) = '0'
WHILE
       (
              SELECT COUNT(*)
              FROM test_usei3sava1.dbo.contact src
              JOIN [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.contact dst ON src.contact_number = dst.contact_number --
       ) > 0
BEGIN
       UPDATE src
       SET src.contact_number = @pad + src.contact_number
       FROM test_usei3sava1.dbo.contact src
       JOIN [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.contact dst ON src.contact_number = dst.contact_number
       WHERE NOT EXISTS
              ( -- Check we're not going to conflict with existing contact_number in source
                     SELECT src_target.contact_number
                     FROM test_usei3sava1.dbo.contact src_target
                     WHERE src_target.contact_number = @pad + src.contact_number
              )
              AND NOT EXISTS
              ( -- Check we're not going to create a new conflict with existing contact_number in destination
                     SELECT dst_target.contact_number
                     FROM [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.contact dst_target
                     WHERE dst_target.contact_number = @pad + src.contact_number
              )
 
       print  CHAR(13) + 'Prepended ''' + @pad + ''' to ' + CAST(@@ROWCOUNT AS VARCHAR) + ' contact numbers' 
 
       SET @pad = '0' + @pad
END   

DECLARE @pad1 VARCHAR(MAX) = '0'
WHILE
       (
              SELECT COUNT(*)
              FROM test_usei3sava1.dbo.contact src
              JOIN  pcc_staging_db59277.dbo.contact dst ON src.contact_number = dst.contact_number --
       ) > 0
BEGIN
       UPDATE src
       SET src.contact_number = @pad1 + src.contact_number
       FROM test_usei3sava1.dbo.contact src
       JOIN  pcc_staging_db59277.dbo.contact dst ON src.contact_number = dst.contact_number
       WHERE NOT EXISTS
              ( -- Check we're not going to conflict with existing contact_number in source
                     SELECT src_target.contact_number
                     FROM test_usei3sava1.dbo.contact src_target
                     WHERE src_target.contact_number = @pad1 + src.contact_number
              )
              AND NOT EXISTS
              ( -- Check we're not going to create a new conflict with existing contact_number in destination
                     SELECT dst_target.contact_number
                     FROM  pcc_staging_db59277.dbo.contact dst_target
                     WHERE dst_target.contact_number = @pad1 + src.contact_number
              )

       print  CHAR(13) + 'Prepended ''' + @pad1 + ''' to ' + CAST(@@ROWCOUNT AS VARCHAR) + ' contact numbers' 
 
       SET @pad1 = '0' + @pad1
END   

--========================================================================================

print  CHAR(13) + 'If Diagnosis running now' 

--depends on the project you are working on
--need to check first the SRC and DEST DB
--description can be  edited in the  front end, thus EI script was not able to merge them

update src
set src.item_description = dst.item_description,
src.deleted = dst.deleted--src.deleted ='Y' ---so that rank would merge with deleted rank in dst 
--select src.item_description, dst.item_description,* 
from test_usei3sava1.dbo.common_code src
join [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.common_code dst
on src.item_id = dst.item_id
where src.item_id = 1047  
and src.item_code = 'drank'
and src.item_description <> dst.item_description

--========================================================================================

print  CHAR(13) + 'If Order - PHO_STD_ORDER and PHO_STD_ORDER_SET running now ' 

/*
--To fix potential Mergeerror where duplicate template_desciption/set_description cannot be inserted to DST
--Run in SRC DB as Pre-script
--Will need to check potential duplications with DST after update
*/


--updating description by removing extra space in src description
update src 
set src.template_description = replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(src.template_description,' day','day'),' (','('),') - ',')'),') ',')'),' - ','-'),', ',','),': ',':'),'# ','#'),'converted','conv'),'less than','<'), ' :', ':'), 'Step 1','Step1') , '.', ''), '] ' ,']' ), 'the','')
--select src.template_description,len(src.template_description) as lenofDesc, replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(src.template_description,' day','day'),' (','('),') - ',')'),') ',')'),' - ','-'),', ',','),': ',':'),'# ','#'),'converted','conv'),'less than','<'), ' :', ':'), 'Step 1','Step1') , '.', ''), '] ' ,']' ), 'the','')  as newDescription, len(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(src.template_description,' day','day'),' (','('),') - ',')'),') ',')'),' - ','-'),', ',','),': ',':'),'# ','#'),'converted','conv'),'less than','<'), ' :', ':'), 'Step 1','Step1') , '.', ''), '] ' ,']' ), 'the','')) as lenofnewDesc
from test_usei3sava1.dbo.pho_std_order src 
join [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.pho_std_order dst on src.template_description = dst.template_description 
where src.fac_id in (-1,R_SRCFACID5) 
and ( src.status <> dst.status
or dst.fac_id <> -1)

--WHILE
--       (
--            SELECT COUNT(*)
--            from test_usei3sava1.dbo.pho_std_order src 
--			join [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.pho_std_order dst on src.template_description = dst.template_description 
--			where src.fac_id in (-1,R_SRCFACID5) 
--			and ( src.status <> dst.status
--			or dst.fac_id <> -1)
--       ) > 0
--BEGIN
--			update src
--			set src.template_description = src.template_description + '-'
--			--select src.std_order_id, dst.std_order_id, src.fac_id,dst.fac_id,src.status, dst.status, src.description,dst.description,src.template_description,dst.template_description,* 
--			from test_usei3sava1.dbo.pho_std_order src 
--			join [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.pho_std_order dst on src.template_description = dst.template_description 
--			where src.fac_id in (-1,R_SRCFACID5) 
--			and ( src.status <> dst.status
--			or dst.fac_id <> -1)
--END   

--instead of running the below query multiple times to get 0, changed it to dynamically run until 0 results
--commenting code below and replacing by dynamic code above

update src
set src.template_description = src.template_description + '-'
--select src.std_order_id, dst.std_order_id, src.fac_id,dst.fac_id,src.status, dst.status, src.description,dst.description,src.template_description,dst.template_description,* 
from test_usei3sava1.dbo.pho_std_order src 
join [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.pho_std_order dst on src.template_description = dst.template_description 
where src.fac_id in (-1,R_SRCFACID5) 
and ( src.status <> dst.status
or dst.fac_id <> -1)

update src
set src.template_description = src.template_description + '-'
--select src.std_order_id, dst.std_order_id, src.fac_id,dst.fac_id,src.status, dst.status, src.description,dst.description,src.template_description,dst.template_description,* 
from test_usei3sava1.dbo.pho_std_order src 
join [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.pho_std_order dst on src.template_description = dst.template_description 
where src.fac_id in (-1,R_SRCFACID5) 
and ( src.status <> dst.status
or dst.fac_id <> -1)

update src
set src.template_description = src.template_description + '-'
--select src.std_order_id, dst.std_order_id, src.fac_id,dst.fac_id,src.status, dst.status, src.description,dst.description,src.template_description,dst.template_description,* 
from test_usei3sava1.dbo.pho_std_order src 
join [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.pho_std_order dst on src.template_description = dst.template_description 
where src.fac_id in (-1,R_SRCFACID5) 
and ( src.status <> dst.status
or dst.fac_id <> -1)

update src
set src.template_description = src.template_description + '-'
--select src.std_order_id, dst.std_order_id, src.fac_id,dst.fac_id,src.status, dst.status, src.description,dst.description,src.template_description,dst.template_description,* 
from test_usei3sava1.dbo.pho_std_order src 
join [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.pho_std_order dst on src.template_description = dst.template_description 
where src.fac_id in (-1,R_SRCFACID5) 
and ( src.status <> dst.status
or dst.fac_id <> -1)

update src
set src.template_description = src.template_description + '-'
--select src.std_order_id, dst.std_order_id, src.fac_id,dst.fac_id,src.status, dst.status, src.description,dst.description,src.template_description,dst.template_description,* 
from test_usei3sava1.dbo.pho_std_order src 
join [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.pho_std_order dst on src.template_description = dst.template_description 
where src.fac_id in (-1,R_SRCFACID5) 
and ( src.status <> dst.status
or dst.fac_id <> -1)

print  CHAR(13) + 'if above is not zero - investigate --> pho_std_order' 

--updating description by removing extra space in src description
update src 
set src.set_description = replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(src.set_description,' day','day'),' (','('),') - ',')'),') ',')'),' - ','-'),', ',','),': ',':'),'# ','#'),'converted','conv'),'less than','<'), ' :', ':'), 'Step 1','Step1') 
--select src.template_description,len(src.template_description) as lenofDesc, replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(src.set_description,' day','day'),' (','('),') - ',')'),') ',')'),' - ','-'),', ',','),': ',':'),'# ','#'),'converted','conv'),'less than','<'), ' :', ':'), 'Step 1','Step1')   as newDescription, len(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(src.set_description,' day','day'),' (','('),') - ',')'),') ',')'),' - ','-'),', ',','),': ',':'),'# ','#'),'converted','conv'),'less than','<'), ' :', ':'), 'Step 1','Step1') ) as lenofnewDesc
from test_usei3sava1.dbo.pho_std_order_set src 
join [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.pho_std_order_set dst on src.set_description=dst.set_description 
where src.fac_id in (-1,R_SRCFACID5) 
and (src.status <> dst.status
or dst.fac_id <> -1)  

--PHO_STD_ORDER_SET.set_description
update src
set src.set_description = src.set_description + '-'
--select src.std_order_set_id, dst.std_order_set_id, src.fac_id,dst.fac_id,src.set_description,dst.set_description,src.status,dst.status,* 
from test_usei3sava1.dbo.pho_std_order_set src 
join [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.pho_std_order_set dst on src.set_description=dst.set_description 
where src.fac_id in (-1,R_SRCFACID5) 
--and dst.fac_id <> -1--1
and (src.status <> dst.status
or dst.fac_id <> -1)  
--for  pho_std_order but was missed in pho_Std_order_set

--PHO_STD_ORDER_SET.set_description
update src
set src.set_description = src.set_description + '-'
--select src.std_order_set_id, dst.std_order_set_id, src.fac_id,dst.fac_id,src.set_description,dst.set_description,src.status,dst.status,* 
from test_usei3sava1.dbo.pho_std_order_set src 
join [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.pho_std_order_set dst on src.set_description=dst.set_description 
where src.fac_id in (-1,R_SRCFACID5) 
--and dst.fac_id <> -1--1
and (src.status <> dst.status
or dst.fac_id <> -1)  
--for  pho_std_order but was missed in pho_Std_order_set

--PHO_STD_ORDER_SET.set_description
update src
set src.set_description = src.set_description + '-'
--select src.std_order_set_id, dst.std_order_set_id, src.fac_id,dst.fac_id,src.set_description,dst.set_description,src.status,dst.status,* 
from test_usei3sava1.dbo.pho_std_order_set src 
join [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.pho_std_order_set dst on src.set_description=dst.set_description 
where src.fac_id in (-1,R_SRCFACID5) 
--and dst.fac_id <> -1--1
and (src.status <> dst.status
or dst.fac_id <> -1)  
--for  pho_std_order but was missed in pho_Std_order_set

--PHO_STD_ORDER_SET.set_description
update src
set src.set_description = src.set_description + '-'
--select src.std_order_set_id, dst.std_order_set_id, src.fac_id,dst.fac_id,src.set_description,dst.set_description,src.status,dst.status,* 
from test_usei3sava1.dbo.pho_std_order_set src 
join [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.pho_std_order_set dst on src.set_description=dst.set_description 
where src.fac_id in (-1,R_SRCFACID5) 
--and dst.fac_id <> -1--1
and (src.status <> dst.status
or dst.fac_id <> -1)  
--for  pho_std_order but was missed in pho_Std_order_set

--PHO_STD_ORDER_SET.set_description
update src
set src.set_description = src.set_description + '-'
--select src.std_order_set_id, dst.std_order_set_id, src.fac_id,dst.fac_id,src.set_description,dst.set_description,src.status,dst.status,* 
from test_usei3sava1.dbo.pho_std_order_set src 
join [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.pho_std_order_set dst on src.set_description=dst.set_description 
where src.fac_id in (-1,R_SRCFACID5) 
--and dst.fac_id <> -1--1
and (src.status <> dst.status
or dst.fac_id <> -1)  
--for  pho_std_order but was missed in pho_Std_order_set

print  CHAR(13) + 'if above is not zero - investigate --> pho_std_order_set' 

--========================================================================================

print  CHAR(13) + 'If Order -check shifts being used running now' 

--If Order -check shifts being used
update cp_std_shift
set fac_id = R_SRCFACID5
--select * 
from dbo.[cp_std_shift] 
where std_shift_id in 
(select s.std_shift_id
from  dbo.pho_schedule o
left join dbo.[cp_std_shift] s
on o.std_shift_id = s.std_shift_id and s.fac_id in (-1, R_SRCFACID5) 
where o.fac_id in (R_SRCFACID5) 
and o.std_shift_id is not null and s.std_shift_id is null
and o.std_shift_id <> -1 )

--check if you need to do order types scoping to bring over all orders belonging to your src fac
update t
set t.fac_id = R_SRCFACID5
--select * 
from  dbo.pho_order_type t
where t.order_type_id in (select distinct o.order_type_id from  dbo.pho_phys_order o
	where o.fac_id=R_SRCFACID5) 
	and t.fac_id not in (-1,R_SRCFACID5)

--========================================================================================

print  CHAR(13) + 'If UDA - AS_STD_ASSESSMENT scoping running now' 

--Adjust the fac_id of UDA standard assessments according to as_std_assessment_facility
--Run in Source DB as pre-script
--possibly due to regional scoping

DECLARE @count INT

select @count = count(*) 
FROM as_std_assessment a
JOIN as_std_assessment_facility f ON a.std_assess_id = f.std_assess_id
WHERE a.fac_id NOT IN (-1,R_SRCFACID5) 
	AND f.fac_id = R_SRCFACID5 
	AND a.system_flag <> 'Y'
	AND a.std_assess_id in (select distinct std_assess_id from dbo.as_assessment where fac_id = R_SRCFACID5) 

update a
set a.fac_id = f.fac_id
--SELECT a.fac_id,f.fac_id,*
FROM as_std_assessment a
JOIN as_std_assessment_facility f ON a.std_assess_id = f.std_assess_id
WHERE a.fac_id NOT IN (-1,R_SRCFACID5) 
	AND f.fac_id = R_SRCFACID5 
	AND a.system_flag <> 'Y'
	AND a.std_assess_id in (select distinct std_assess_id from dbo.as_assessment where fac_id = R_SRCFACID5)

if @count > 0
		
	update s
	set s.fac_id = a.fac_id
	--select s.fac_id, a.fac_id, *
	from as_std_assess_schedule s
	join as_std_assessment a on s.std_assess_id = a.std_assess_id
	where a.fac_id in (-1,R_SRCFACID5)
	AND s.fac_id not in (-1,R_SRCFACID5)
	AND a.system_flag <> 'Y'
	AND a.std_assess_id in (select distinct std_assess_id from dbo.as_assessment where fac_id = R_SRCFACID5) 

if @count > 0

	update t
	set t.fac_id = a.fac_id
	--select t.fac_id, a.fac_id, *
	from as_std_trigger t
	join as_std_assessment a on t.std_assess_id = a.std_assess_id
	where a.fac_id in (-1,R_SRCFACID5)
	AND t.fac_id not in (-1,R_SRCFACID5)
	AND a.system_flag <> 'Y'
	AND a.std_assess_id in (select distinct std_assess_id from dbo.as_assessment where fac_id = R_SRCFACID5) 

if @count > 0
	update r
	set r.fac_id = a.fac_id
	--select r.fac_id, a.fac_id, *
	from as_consistency_rule r
	join as_std_assessment a on r.std_assess_id = a.std_assess_id
	where a.fac_id in (-1,R_SRCFACID5)
	AND r.fac_id not in (-1,R_SRCFACID5)
	AND a.system_flag <> 'Y'
	AND a.std_assess_id in (select distinct std_assess_id from dbo.as_assessment where fac_id = R_SRCFACID5)
	AND r.deleted <> 'Y'

--========================================================================================

print  CHAR(13) + 'If_Copy ProgressNote running now' 

update pn_template
set fac_id = R_SRCFACID5
--select * from pn_template
where template_id  in (select template_id from pn_progress_note where fac_id = R_SRCFACID5)
and fac_id not in (-1,R_SRCFACID5)

update pn_type
set fac_id = R_SRCFACID5
--select * from pn_type
where pn_type_id  in (select pn_type_id from pn_progress_note where fac_id = R_SRCFACID5)
and fac_id not in (-1,R_SRCFACID5)

--========================================================================================

print  CHAR(13) + 'If_Copy_Immunization running now' 

update src
set administered_by_id = -1
--SELECT *
FROM dbo.cr_client_immunization src
WHERE administered_by_id NOT IN (SELECT userid FROM dbo.sec_user )
	AND administered_by_id <> - 1
	AND client_id IN ( SELECT client_id FROM dbo.clients WHERE fac_id IN (R_SRCFACID5))

--========================================================================================

print  CHAR(13) + 'If_ExternalFacilities_When Src is multi running now' 

UPDATE dbo.emc_ext_facilities
SET fac_id = R_SRCFACID5
--select * from dbo.emc_ext_facilities 
where state_code='TX' 
and fac_id not in (-1,R_SRCFACID5) 
and deleted = 'N'

update emc_ext_facilities
set fac_id = R_SRCFACID5
--select * from dbo.emc_ext_facilities
where ext_fac_id in (select ext_fac_id from dbo.client_ext_facilities where fac_id in (R_SRCFACID5))
and fac_id not in (-1,R_SRCFACID5)

--========================================================================================

print  CHAR(13) + 'If_UserDefinedData_When Src is multi running now' 

update a
set fac_id = R_SRCFACID5
--select  *  
from dbo.user_field_types a 
join dbo.USER_DEFINED_DATA b on a.field_type_id=b.field_type_id
join dbo.clients c on c.client_id = b.client_id
where c.fac_id = R_SRCFACID5 
and a.fac_id not in (-1,R_SRCFACID5)

--========================================================================================

print  CHAR(13) + 'diet prescripts fix running now' 

print  CHAR(13) + 'Orders scoping - to fix status code'

update pho_std_phys_order
set fac_id = R_SRCFACID5
--SELECT * 
FROM  test_usei3sava1.dbo.pho_std_phys_order
where std_phys_order_id in 
(SELECT distinct std_order_id FROM test_usei3sava1.dbo.pho_phys_order WHERE fac_id in (183)
and fac_id not in (-1,183))

print  CHAR(13) + 'Orders - undelete common_code - to fix diet orders'

--check if any deleted items are used in src
select distinct diet_type as 'src_id'  into #missing_diet from pho_phys_order where fac_id in (183)
and order_type_id in (select order_type_id from pho_order_type where description like '%diet%' and deleted = 'N')
and diet_type in (select item_id from common_code where deleted='Y') 
union
--insert into #missing_diet 
select distinct diet_texture   from pho_phys_order where fac_id in (183)
and order_type_id in (select order_type_id from pho_order_type where description like '%diet%' and deleted = 'N')
and diet_texture in (select item_id from common_code where deleted='Y') 
union
--insert into #missing_diet 
select distinct fluid_consistency  from pho_phys_order where fac_id in (183)
and order_type_id in (select order_type_id from pho_order_type where description like '%diet%' and deleted = 'N')
and fluid_consistency in (select item_id from common_code where deleted='Y') 
union
--insert into #missing_diet 
select distinct diet_supplement from pho_phys_order where fac_id in (183)
and order_type_id in (select order_type_id from pho_order_type where description like '%diet%' and deleted = 'N')
and diet_supplement in (select item_id from common_code where deleted='Y') 
order by 1--0

print  CHAR(13) + 'Orders - undelete common_code - to fix diet orders'

update common_code
set deleted = 'N', fac_id = -1
--select * 
from dbo.common_code 
where item_id in (select src_id from #missing_diet)
and item_code in ('phocst','phosup','phodtx','phodyt')
and deleted = 'Y'

--========================================================================================

--print  CHAR(13) + 'If multi sec_user_facility (if multi facility)(run for 2nd facility and onwards)(if no sec user pre import) running now ' 
--print  CHAR(13) + '*** DO NOT RUN FOR THE FIRST FACILITY ***' 

--update su
--set fac_id = R_SRCFACID5 
----select * 
--from sec_user su join sec_user_facility sf
--on su.userid = sf.userid
--where 
--su.loginname not like '%pcc-%' and su.loginname not like '%wescom%'
--and su.fac_id = 183 
--and sf.facility_id = R_SRCFACID5 

--========================================================================================

--print  CHAR(13) + 'Clean up PN links (if progress notes NOT approved) running now' 

--print  CHAR(13) + ' Clean up PN links, if  PN module not copied ' 

--update pho_admin_strikeout
--set progress_notes_id = NULL
----select *
--FROM [dbo].pho_admin_strikeout
--where fac_id in (R_SRCFACID5) 
--and progress_notes_id is not null

--update pho_chart_code_history
--set progress_notes_id = NULL
----select *
--FROM [dbo].pho_chart_code_history
--where progress_notes_id is not null

--update pho_followup_strikeout
--set followup_pn_id = NULL
----select *
--FROM [dbo].pho_followup_strikeout
--where followup_pn_id is not null 

--update pho_phys_order_allergy_acknowledgement
--set pn_id = NULL
----select *
--FROM [dbo].pho_phys_order_allergy_acknowledgement
--where pn_id is not null 

--update pho_schedule_details
--set followup_pn_id = NULL
----select *
--FROM [dbo].pho_schedule_details 
--where followup_pn_id is not null 

--update pho_schedule_details_history
--set followup_pn_id = NULL
----select *
--FROM [dbo].pho_schedule_details_history  
--where followup_pn_id is not null 

--update wv_vitals
--set pn_id = NULL
----select *
--FROM [dbo].wv_vitals  
--where fac_id in (R_SRCFACID5)
--and pn_id is not null 

--========================================================================================

--print  CHAR(13) + 'If_Sec_User_not_copied_Clean_up_in_Source (if security users NOT approved) running now' 

--update as_assessment_section set completed_by_id = null
----select * 
--from as_assessment_section where fac_id in (R_SRCFACID5) and completed_by_id is not null 

--update clients set case_manager_id = null
----select * 
--from clients where fac_id in (R_SRCFACID5) and case_manager_id is not null 

--update contact_history set user_id = -1
----select * 
--from contact_history where fac_id in (R_SRCFACID5) 

--update cp_rev_users set userid = -1
----select * 
--from cp_rev_users where fac_id in (R_SRCFACID5) 

--update cr_client_immunization set administered_by_id = null
----select * 
--from cr_client_immunization where fac_id in (R_SRCFACID5) and administered_by_id is not null 

--update cr_client_immunization_audit set administered_by_id = null
----select * 
--from cr_client_immunization_audit where fac_id in (R_SRCFACID5) and administered_by_id is not null 

--update mpi_history set user_id = -1
----select * 
--from mpi_history where fac_id in (R_SRCFACID5) and user_id is not null and user_id > 1

--update staff set userid = null
----select * 
--from staff where fac_id in (R_SRCFACID5) and userid is not null

--update pho_admin_order set noted_by = null
----select * 
--from pho_admin_order where phys_order_id in 
--(select phys_order_id from pho_phys_order where fac_id in (R_SRCFACID5)) 
--and noted_by is not null --

--update pho_admin_order_audit set noted_by = null
----select * 
--from pho_admin_order_audit where phys_order_id in 
--(select phys_order_id from pho_phys_order where fac_id in (R_SRCFACID5)) 
--and noted_by is not null 

--update pho_report_run set user_id = null
----select * 
--from pho_report_run where fac_id in (R_SRCFACID5) 
--and user_id is not null 

--update pho_user_admin_rec_assoc set userid = null
----select * 
--from pho_user_admin_rec_assoc where fac_id in (R_SRCFACID5) 
--and userid is not null 

--update pho_phys_order_esignature set marked_to_sign_user_id = null
----select * 
--from pho_phys_order_esignature 
--where phys_order_id in  (select phys_order_id from pho_phys_order where fac_id in (R_SRCFACID5)) 
--and marked_to_sign_user_id is not null 

--update pho_phys_order_esignature set sign_user_id = null
----select * 
--from pho_phys_order_esignature 
--where phys_order_id in  (select phys_order_id from pho_phys_order where fac_id in (R_SRCFACID5)) 
--and sign_user_id is not null 

--========================================================================================

----if trust approved

--update a
--set a.gl_batch_id = null
--from ta_transaction a 
--where gl_batch_id is not null

--========================================================================================

/*

--run in source test DB as pre script if copying UDA

--this is to make sure at least one of the dummy UDAs with client_id = -9999 is copied over for UDA libaries to show properly

*/

IF OBJECT_ID('tempdb..#tempdummyuda') IS NOT NULL 
	DROP TABLE #tempdummyuda

--GO

select row_number() over (partition by std_assess_id order by src.fac_id) as rno, src.assess_id, src.std_assess_id 
into #tempdummyuda
--select * 
from as_assessment src
where src.std_assess_id in 
	(
	select std_assess_id from as_std_assessment stda
		where stda.std_assess_id <> - 1 AND (stda.fac_id = R_SRCFACID5 --src fac_id
				OR stda.fac_id = - 1
				OR stda.reg_id in (select regional_id from facility where fac_id = R_SRCFACID5)) --src fac_id
			AND stda.std_assess_id NOT IN (7,8,12)
			AND stda.std_assess_id NOT IN ((SELECT std_assess_id FROM [dbo].as_std_assessment_system_assessment_mapping))
			AND stda.system_flag <> 'Y'
			AND stda.deleted <> 'Y'
			AND not exists (select 1 from as_assessment with (nolock) where std_assess_id = stda.std_assess_id and client_id = -9999
									and (fac_id = R_SRCFACID5  --src fac_id
									OR fac_id = -1 OR reg_id in (select regional_id from facility where fac_id = R_SRCFACID5))  --src fac_id
							)
	)
and client_id = -9999


update a
set fac_id = -1
--select *
from as_assessment a
where a.client_id = -9999
and a.assess_id in (select assess_id from #tempdummyuda where rno = 1)
and not exists (select 1 from as_assessment where a.std_assess_id = std_assess_id and client_id = -9999 and fac_id in (R_SRCFACID5,-1)) --src fac_id


update a
set fac_id = -1
--select *
from as_assessment_section a
where a.assess_id in (select assess_id from #tempdummyuda where rno = 1)
and a.fac_id not in (R_SRCFACID5, -1) --src fac_id


