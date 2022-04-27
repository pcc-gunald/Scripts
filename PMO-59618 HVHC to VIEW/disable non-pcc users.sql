-- run on test destination db
-- update the revision_by value with your PMO number

update s
set
enabled = 'N', revision_by = 'CaseR_59618', revision_date = getdate()
--select *
from sec_user s
where loginname not like '%pcc-%'
and loginname <> 'wescom'
and enabled = 'Y'

/* Go Live Results




(362 rows affected)

Completion time: 2022-04-14T02:24:25.0832686-04:00


*/
