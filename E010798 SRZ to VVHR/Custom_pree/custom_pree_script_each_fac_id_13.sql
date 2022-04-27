--Custom Scripts
use test_usei1188

----Select * from facility
SET CONTEXT_INFO 0xDC1000000;
 SET DEADLOCK_PRIORITY 4;
 SET QUOTED_IDENTIFIER ON;

 update [cp_sec_user_audit]

set fac_id =13

where [cp_sec_user_audit_id] in (26234)