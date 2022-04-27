-- run on test destination db
-- update the revision_by value with your PMO number

update s
set
enabled = 'N', revision_by = 'CaseR_009215', revision_date = getdate()
--select *
from sec_user s
where loginname not like '%pcc-%'
and loginname <> 'wescom'
and enabled = 'Y'

/* Go Live Results




(151 rows affected)

Completion time: 2022-02-18T03:14:20.0995125-05:00


*/
