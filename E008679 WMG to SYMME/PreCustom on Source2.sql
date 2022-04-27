
SET QUOTED_IDENTIFIER ON;
SET CONTEXT_INFO 0xDC1000000; 
SET DEADLOCK_PRIORITY 4;


--FK violation error pho_order_related_value]/cp_sec_user_audit
drop table if exists #temp_cp_sec_user_audit
select distinct d.*,15 New_facid 
into #temp_cp_sec_user_audit
from test_usei1129.[dbo].pho_schedule a
inner join test_usei1129.[dbo].pho_schedule_details b on b.pho_schedule_id=a.schedule_id
inner join test_usei1129.[dbo].pho_order_related_value c on c.schedule_detail_id=b.pho_schedule_detail_id
inner join test_usei1129.[dbo].cp_sec_user_audit d on d.cp_sec_user_audit_id=c.cp_sec_user_audit_id
where a.fac_id =15
and a.fac_id<>d.fac_id


update d
set fac_id=a.New_facid
,position_description=d.position_description+'_'
from #temp_cp_sec_user_audit a
inner join  test_usei1129.[dbo].cp_sec_user_audit d on d.cp_sec_user_audit_id=a.cp_sec_user_audit_id
where 1=1
and not exists(select 1 from  test_usei1129.[dbo].cp_sec_user_audit  c where c.cp_sec_user_audit_id=d.cp_sec_user_audit_id
and c.fac_id=a.New_facid)

