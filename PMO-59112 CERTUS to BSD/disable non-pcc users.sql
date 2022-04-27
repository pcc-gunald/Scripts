-- run on test destination db
-- update the revision_by value with your PMO number

update s
set
enabled = 'N', revision_by = 'CaseR_59112', revision_date = getdate()
--select *
from sec_user s
where loginname not like '%pcc-%'
and loginname <> 'wescom'
and enabled = 'Y'

/* Go Live Results


(1701 rows affected)

Completion time: 2022-02-08T04:17:00.4659551-05:00

*/
