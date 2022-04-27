PRINT CHAR(13) + 'Post insert for as_ard_adl_keys running now'

INSERT INTO dbo.as_ard_adl_keys (
	ard_planner_id
	,std_assess_id
	,question_key
	,resp_value
	,source_id
	,Multi_Fac_Id
	)
SELECT DISTINCT ISNULL(c.dst_id, ard_planner_id)
	,ISNULL(b.dst_id, std_assess_id)
	,[question_key]
	,[resp_value]
	,[source_id]
	,16
FROM test_usei639.dbo.as_ard_adl_keys a
INNER JOIN EICase0078582as_std_assessment b ON b.src_id = a.std_assess_id
INNER JOIN EICase0078582as_ard_planner c ON c.src_id = a.ard_planner_id
