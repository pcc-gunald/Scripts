use pcc_staging_db009632
SET CONTEXT_INFO 0xDC1000000;
 SET DEADLOCK_PRIORITY 4;
 SET QUOTED_IDENTIFIER ON;

update a
set a.created_by_userid = (select dst_id from EICase00963221sec_user
where src_id = 104818)
--select * 
from [pn_progress_note] a
where created_by_userid = 104818

update a
set a.created_by_userid = (select dst_id from EICase00963221sec_user
where src_id = 112406)
--select * 
from [pn_progress_note] a
where created_by_userid in(
112406)

update a
set a.created_by_userid = (select dst_id from EICase00963221sec_user
where src_id = 130176)
--select * 
from [pn_progress_note] a
where created_by_userid in(
130176)

update a
set a.[cp_sec_user_audit_id] = (select dst_id from EICase00963220cp_sec_user_audit
where src_id = 12077)
--select * 
from [pho_order_related_value] a
where [cp_sec_user_audit_id] in(
12077)


--drop table ei_fkviolation
