update  a
set a.client_id =m.dst_id
--select *
from admin_consent a
join EICase5911212clients m  on a.client_id=m.src_id
