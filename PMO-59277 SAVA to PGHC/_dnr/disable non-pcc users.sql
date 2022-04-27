USE test_usei1214
GO

update s
set
enabled = 'N', revision_by = 'CaseR_CASENUMBER', revision_date = getdate()
--select *
from sec_user s
where loginname not like '%pcc-%'
and loginname <> 'wescom'
and enabled = 'Y'

/* Go Live Results



*/