

print  CHAR(13) + ' prefix sec_roles (only if requested specially)' 

update sec_role 
set description = 'HDG-' + description 
--select * 
from sec_role 
where (system_field <> 'Y' or system_field is null)
and description not like 'HDG%'
