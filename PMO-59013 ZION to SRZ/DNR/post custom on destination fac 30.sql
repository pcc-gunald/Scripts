SELECT 1
SET CONTEXT_INFO 0xDC1000000;
SET DEADLOCK_PRIORITY 4;
SET QUOTED_IDENTIFIER ON;

CREATE TABLE #map_as_std_assessment (src_id INT PRIMARY KEY, dst_id INT NOT NULL)
INSERT INTO #map_as_std_assessment
SELECT src_id, dst_id FROM test_usei1122.dbo.EICase590132as_std_assessment  --dest


CREATE TABLE #map_as_ard_planner (src_id INT PRIMARY KEY, dst_id INT NOT NULL)
INSERT INTO #map_as_ard_planner
SELECT src_id, dst_id FROM test_usei1122.dbo.EICase590132as_ard_planner  --dest


INSERT INTO test_usei1122.dbo.as_ard_adl_keys  --dest
(
ard_planner_id
, std_assess_id
, question_key
, resp_value
, source_id
)
SELECT DISTINCT
ISNULL(c.dst_id, ard_planner_id)
, ISNULL(b.dst_id, std_assess_id)
, [question_key]
, [resp_value]
, [source_id]
FROM [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.dbo.as_ard_adl_keys a  --src
INNER JOIN #map_as_std_assessment b ON b.src_id = a.std_assess_id
INNER JOIN #map_as_ard_planner c ON c.src_id = a.ard_planner_id