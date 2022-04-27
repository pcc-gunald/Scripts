
SET CONTEXT_INFO 0xDC1000000;
SET DEADLOCK_PRIORITY 4;
SET QUOTED_IDENTIFIER ON;

update a 
set a.description = 'HHI-' + a.description
--select * 
from pn_type a
where created_by in ('EICase00963221','EICase00963220')
and fac_id <> -1

update a 
set a.item_description = 'RETIRED-' + a.item_description
--select * 
from common_code a
where created_by in ('EICase00963221','EICase00963220')
and item_code = 'drank'
and fac_id <> - 1
