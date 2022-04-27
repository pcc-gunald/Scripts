

print  CHAR(13) + ' prefix sec_roles (only if requested specially)' 

update sec_role 
set description = 'WMG-' + description 
--select * 
from sec_role 
where (system_field <> 'Y' or system_field is null)
and description not like 'WMG%'

--FK violation error pho_order_related_value]/cp_sec_user_audit
drop table if exists #temp_cp_sec_user_audit
select distinct d.*,a.fac_id New_facid 
into #temp_cp_sec_user_audit
from test_usei1129.[dbo].pho_schedule a
inner join test_usei1129.[dbo].pho_schedule_details b on b.pho_schedule_id=a.schedule_id
inner join test_usei1129.[dbo].pho_order_related_value c on c.schedule_detail_id=b.pho_schedule_detail_id
inner join test_usei1129.[dbo].cp_sec_user_audit d on d.cp_sec_user_audit_id=c.cp_sec_user_audit_id
where a.fac_id in(14,15,16)
and a.fac_id<>d.fac_id


update d
set fac_id=a.New_facid
from #temp_cp_sec_user_audit a
inner join  test_usei1129.[dbo].cp_sec_user_audit d on d.cp_sec_user_audit_id=a.cp_sec_user_audit_id


---FK violation error pho_std_time_details/cp_std_shift

DROP TABLE IF EXISTS #temp_shift
SELECT a.std_shift_id ,b.std_shift_id New_std_shift_id
INTO #temp_shift
FROM test_usei1129.[dbo].cp_std_shift a
inner join test_usei1129.[dbo].cp_std_shift b on b.start_time=a.start_time and b.end_time=a.end_time
where a.std_shift_id in (1,2,6)
and b.std_shift_id not in (1,2,6)
and b.deleted='N'

--SELECT a.*,b.New_std_shift_id
UPDATE a
SET std_shift_id=b.New_std_shift_id
FROM test_usei1129.[dbo].pho_schedule a
INNER JOIN #temp_shift b ON b.std_shift_id=a.std_shift_id
WHERE a.fac_id IN(14,15,16)


---FK violation error pn_progress_note/created_by_userid

update a
set created_by_userid =null
from test_usei1129.dbo.pn_progress_note a
where fac_id in(14,15,16)
and a.created_by_userid is not null
and not exists(select 1 from  test_usei1129.dbo.sec_user b where b.userid=a.created_by_userid
and b.fac_id in(14,15,16)
)

--- FK violation census_item_secondary_rate
delete mergeTablesMaster
where tablename='census_item_secondary_rate'