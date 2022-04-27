
SET QUOTED_IDENTIFIER ON;
SET CONTEXT_INFO 0xDC1000000; 
SET DEADLOCK_PRIORITY 4;





UPDATE pcc_staging_db58899.[dbo].mergetablesmaster
SET QueryFilter=' AND template_id IN ( SELECT template_id from [origDB].pn_progress_note where fac_id = [OrigFacId]) OR template_id=10142'
WHERE tablename='pn_template'


--mergeExecuteExtractStep4 --> MergeError : Violation of PRIMARY KEY constraint 'ext_facilities__extFacId_facId_PK'. Cannot insert duplicate key in object 'dbo.ext_facilities'. The duplicate key value is (117595, 194).
UPDATE [dbo].emc_ext_facilities 
SET Name='Wellfount_1'
WHERE ext_fac_id=2171




--FK violation error pho_order_related_value]/cp_sec_user_audit
drop table if exists #temp_cp_sec_user_audit
select distinct d.*,a.fac_id New_facid
into #temp_cp_sec_user_audit
from test_usei1029.[dbo].pho_schedule a
inner join test_usei1029.[dbo].pho_schedule_details b on b.pho_schedule_id=a.schedule_id
inner join test_usei1029.[dbo].pho_order_related_value c on c.schedule_detail_id=b.pho_schedule_detail_id
inner join test_usei1029.[dbo].cp_sec_user_audit d on d.cp_sec_user_audit_id=c.cp_sec_user_audit_id
where a.fac_id =1
and a.fac_id<>d.fac_id


update d
set fac_id=a.New_facid,position_description=concat(d.position_description,d.fac_id)
from #temp_cp_sec_user_audit a
inner join test_usei1029.[dbo].cp_sec_user_audit d on d.cp_sec_user_audit_id=a.cp_sec_user_audit_id
where 1=1
and not exists(select 1 from test_usei1029.[dbo].cp_sec_user_audit c where c.cp_sec_user_audit_id=d.cp_sec_user_audit_id
and c.fac_id=a.New_facid)




drop table if exists #temp_cp_sec_user_audi
select distinct d.*,a.fac_id new_fac_id
into #temp_cp_sec_user_audi
from test_usei1029.dbo.pho_phys_order_audit a
inner join test_usei1029.dbo.pho_phys_order_audit_useraudit b on b.audit_id=a.audit_id
inner join test_usei1029.dbo.cp_sec_user_audit d on d.cp_sec_user_audit_id=b.created_by_audit_id
where a.fac_id=1
and d.fac_id <>a.fac_id
--and b.created_by_audit_id=14974

update b
set fac_id=a.new_fac_id,position_description=concat(b.position_description,b.fac_id)
from  #temp_cp_sec_user_audi a
inner join test_usei1029.dbo.cp_sec_user_audit b on b.cp_sec_user_audit_id=a.cp_sec_user_audit_id





drop table if exists #temp_cp_sec_user_audit1

select distinct d.*,a.fac_id New_fac_id
into #temp_cp_sec_user_audit1
from test_usei1029.[dbo].pho_schedule a
inner join test_usei1029.[dbo].pho_schedule_details b on b.pho_schedule_id=a.schedule_id
inner join test_usei1029.[dbo].[pho_schedule_details_reminder] c on c.pho_schedule_detail_id=b.pho_schedule_detail_id
inner join test_usei1029.[dbo].cp_sec_user_audit d on d.cp_sec_user_audit_id=c.createdby_useraudit_id
where a.fac_id=1
and a.fac_id<>d.fac_id

---FK violation error pn_progress_note/created_by_userid

update b
set fac_id =a.fac_id
from dbo.pn_progress_note a
inner join test_usei1029.dbo.sec_user  b on b.userid=a.created_by_userid
where a.fac_id =1
and a.fac_id<>b.fac_id
and a.created_by_userid is not null

