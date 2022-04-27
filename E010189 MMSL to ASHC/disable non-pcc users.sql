-- run on test destination db
-- update the revision_by value with your PMO number

update s
set
enabled = 'N', revision_by = 'CaseR_010189', revision_date = getdate()
--select *
from sec_user s
where loginname not like '%pcc-%'
and loginname <> 'wescom'
and enabled = 'Y'

/* Go Live Results





(7413 rows affected)

Completion time: 2022-03-16T04:15:25.1274378-04:00




*/
