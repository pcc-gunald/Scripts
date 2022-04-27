use test_usei435

SET CONTEXT_INFO 0xDC1000000;
 SET DEADLOCK_PRIORITY 4;
 SET QUOTED_IDENTIFIER ON;


update a 
set a.fac_id = 21
--select * 
from cp_sec_user_audit a
where cp_sec_user_audit_id in (12077)

update a
set a.fac_id = 21
--select * 
from sec_user a
where userid in (104818,112406,130176)
and fac_id not in(21)
