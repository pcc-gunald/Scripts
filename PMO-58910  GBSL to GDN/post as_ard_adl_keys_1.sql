SET DEADLOCK_PRIORITY 4;
SET QUOTED_IDENTIFIER ON;

print  CHAR(13) + 'Post insert for as_ard_adl_keys running now'  

--exec  [operational].[sproc_facacq_autopre_RemoveTableFromDataCopy]	'as_ard_adl_keys' --table name in auto-pre

 --Post insert for 'as_ard_adl_keys'
 --We can remove the duplicate check since we're inserting all at once and as_ard_planner has no scope fields so it never merges on insert
 --Combine all mapping tables into single temp tables:

CREATE TABLE #map_as_std_assessment (src_id INT PRIMARY KEY, dst_id INT NOT NULL)
INSERT INTO #map_as_std_assessment
SELECT src_id, dst_id FROM [us_gdn_multi].dbo.EICase589101067as_std_assessment

CREATE TABLE #map_as_ard_planner (src_id INT PRIMARY KEY, dst_id INT NOT NULL)
INSERT INTO #map_as_ard_planner
SELECT src_id, dst_id FROM [us_gdn_multi].dbo.EICase589101067as_ard_planner

INSERT INTO [us_gdn_multi].dbo.as_ard_adl_keys
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
FROM [pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].[test_usei548].dbo.as_ard_adl_keys a
    INNER JOIN #map_as_std_assessment b ON b.src_id = a.std_assess_id 
    INNER JOIN #map_as_ard_planner c ON c.src_id = a.ard_planner_id 

