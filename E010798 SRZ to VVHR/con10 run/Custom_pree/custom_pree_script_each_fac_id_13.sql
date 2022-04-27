--Custom Scripts
use test_usei984


SET CONTEXT_INFO 0xDC1000000;
 SET DEADLOCK_PRIORITY 4;
 SET QUOTED_IDENTIFIER ON;
 --------------foreign key error on progress note
update sec_user
set fac_id =7
where userid=94035

update [cp_sec_user_audit]

set fac_id =8
where cp_sec_user_audit_id in (2045,9408)
and userid in (40820,32350)
and fac_id in (6,12)


