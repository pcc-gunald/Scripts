-- run on test destination db
-- update the revision_by value with your PMO number

update s
set
enabled = 'N', revision_by = 'CaseR_008679', revision_date = getdate()
--select *
from sec_user s
where loginname not like '%pcc-%'
and loginname <> 'wescom'
and enabled = 'Y'

/* Go Live Results



(946 rows affected)

Completion time: 2022-02-09T23:01:06.9749997-05:00


*/
