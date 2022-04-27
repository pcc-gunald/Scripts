
USE test_usei630
print  CHAR(13) + ' prefix sec_roles (only if requested specially)' 

update sec_role 
set description = 'ORCH-' + description 
--select * 
from sec_role 
where (system_field <> 'Y' or system_field is null)
and description not like 'ORCH%'

