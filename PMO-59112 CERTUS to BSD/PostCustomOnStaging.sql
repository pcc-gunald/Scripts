PRINT CHAR(13) + 'Post insert for as_ard_adl_keys running now'

DROP INDEX IF EXISTS IDX_EICase5911212as_std_assessment_src_id ON EICase5911212as_std_assessment;
CREATE CLUSTERED INDEX IDX_EICase5911212as_std_assessment_src_id ON EICase5911212as_std_assessment (src_id);

DROP TABLE IF EXISTS #TEMP;

SELECT DISTINCT ISNULL(c.dst_id, ard_planner_id) ard_planner_id
	,ISNULL(b.dst_id, std_assess_id) std_assess_id
	,[question_key]
	,[resp_value]
	,[source_id]
	,18  Multi_Fac_Id
INTO #TEMP
FROM test_usei1066.dbo.as_ard_adl_keys a
INNER JOIN EICase5911212as_std_assessment b ON b.src_id = a.std_assess_id
INNER JOIN EICase5911212as_ard_planner c ON c.src_id = a.ard_planner_id



INSERT INTO dbo.as_ard_adl_keys (
	ard_planner_id
	,std_assess_id
	,question_key
	,resp_value
	,source_id
	,Multi_Fac_Id
	)
SELECT ard_planner_id
	,std_assess_id
	,question_key
	,resp_value
	,source_id
	,Multi_Fac_Id
FROM  #TEMP;
