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

--drop table ei_fkviolation
