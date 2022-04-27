SET DEADLOCK_PRIORITY 4;
SET QUOTED_IDENTIFIER ON;

print  CHAR(13) + 'Post insert for as_ard_adl_keys running now'  

 --Post insert for 'as_ard_adl_keys'
 --We can remove the duplicate check since we're inserting all at once and as_ard_planner has no scope fields so it never merges on insert
 --Combine all mapping tables into single temp tables:

CREATE TABLE #map_as_std_assessment (src_id INT PRIMARY KEY, dst_id INT NOT NULL)
INSERT INTO #map_as_std_assessment
SELECT src_id, dst_id FROM test_usei910.dbo.EICase007693as_std_assessment --dest 

CREATE TABLE #map_as_ard_planner (src_id INT PRIMARY KEY, dst_id INT NOT NULL)
INSERT INTO #map_as_ard_planner
SELECT src_id, dst_id FROM test_usei910.dbo.EICase007693as_std_assessment -- dest

INSERT INTO test_usei910.dbo.as_ard_adl_keys --dest
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
FROM [pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei702.dbo.as_ard_adl_keys a --src
    INNER JOIN #map_as_std_assessment b ON b.src_id = a.std_assess_id 
    INNER JOIN #map_as_ard_planner c ON c.src_id = a.ard_planner_id 

--immunization strike fix

	UPDATE a
SET deleted = 'Y'
--select * 
FROM common_code a
WHERE item_id IN (
		SELECT dst_id
		FROM EICase007693common_code
		WHERE src_id = 10933
		)