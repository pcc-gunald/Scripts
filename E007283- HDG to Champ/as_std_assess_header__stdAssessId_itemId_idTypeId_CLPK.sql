select * from MergeLog
--where msg like '%EICase0072832qlib_pick_list_item%'
order by msgTime desc 

mergeExecuteExtractStep4 --> MergeError : Violation of PRIMARY KEY constraint 'as_std_assess_header__stdAssessId_itemId_idTypeId_CLPK'. Cannot insert duplicate key in object 'dbo.as_std_assess_header'. 
The duplicate key value is (3360612, 7106, 203).
mergeExecuteExtractStep4 --> MergeError : Violation of PRIMARY KEY constraint 'as_std_assess_header__stdAssessId_itemId_idTypeId_CLPK'. Cannot insert duplicate key in object 'dbo.as_std_assess_header'. The duplicate key value is (3360612, 7106, 203).
std_assess_id, item_id, id_type_id
 --INSERT INTO pcc_staging_db007283.[dbo].as_std_assess_header (
	--std_assess_id
	--,item_id
	--,id_type_id
	--,main_enabled
	--,sub_enabled
	--,MULTI_FAC_ID
	--)
SELECT DISTINCT ISNULL(EICase00728321.dst_id, std_assess_id)
	,ISNULL(EICase00728323.dst_id, item_id)
	,ISNULL(EICase00728322.dst_id, id_type_id)
	,[main_enabled]
	,[sub_enabled]
	,50
	,EICase00728321.dst_id, std_assess_id
FROM test_usei547.[dbo].as_std_assess_header a
JOIN pcc_staging_db007283.[dbo].EICase0072832as_std_assessment EICase00728321 ON EICase00728321.src_id = a.std_assess_id
LEFT JOIN pcc_staging_db007283.[dbo].EICase0072832id_type EICase00728322 ON EICase00728322.src_id = a.id_type_id
JOIN pcc_staging_db007283.[dbo].EICase0072832common_code EICase00728323 ON EICase00728323.src_id = a.item_id
WHERE NOT EXISTS (
		SELECT 1
		FROM [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1062.[dbo].as_std_assess_header origt
		WHERE origt.id_type_id = ISNULL(EICase00728322.dst_id, origt.id_type_id)
			AND origt.std_assess_id = EICase00728321.dst_id
			AND origt.item_id = EICase00728323.dst_id
		)
	AND NOT EXISTS (
		SELECT 1
		FROM pcc_staging_db007283.[dbo].as_std_assess_header origt1
		WHERE origt1.id_type_id = ISNULL(EICase00728322.dst_id, origt1.id_type_id)
			AND origt1.std_assess_id = EICase00728321.dst_id
			AND origt1.item_id = EICase00728323.dst_id
		)
AND ISNULL(EICase00728321.dst_id, std_assess_id)=3360356
AND ISNULL(EICase00728323.dst_id, item_id)=7106
AND ISNULL(EICase00728322.dst_id, id_type_id)=182

SELECT * FROM test_usei547.[dbo].as_std_assess_header a
JOIN pcc_staging_db007283.[dbo].EICase0072832as_std_assessment EICase00728321 ON EICase00728321.src_id = a.std_assess_id
LEFT JOIN pcc_staging_db007283.[dbo].EICase0072832id_type EICase00728322 ON EICase00728322.src_id = a.id_type_id
WHERE a.std_assess_id=10257

SELECT  ISNULL(EICase00728321.dst_id, std_assess_id)
	,ISNULL(EICase00728323.dst_id, item_id)
	,ISNULL(EICase00728322.dst_id, id_type_id)
FROM test_usei547.[dbo].as_std_assess_header a
JOIN pcc_staging_db007283.[dbo].EICase0072832as_std_assessment EICase00728321 ON EICase00728321.src_id = a.std_assess_id
LEFT JOIN pcc_staging_db007283.[dbo].EICase0072832id_type EICase00728322 ON EICase00728322.src_id = a.id_type_id
JOIN pcc_staging_db007283.[dbo].EICase0072832common_code EICase00728323 ON EICase00728323.src_id = a.item_id
WHERE NOT EXISTS (
		SELECT 1
		FROM [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1062.[dbo].as_std_assess_header origt
		WHERE origt.id_type_id = ISNULL(EICase00728322.dst_id, origt.id_type_id)
			AND origt.std_assess_id = EICase00728321.dst_id
			AND origt.item_id = EICase00728323.dst_id
		)
	AND NOT EXISTS (
		SELECT 1
		FROM pcc_staging_db007283.[dbo].as_std_assess_header origt1
		WHERE origt1.id_type_id = ISNULL(EICase00728322.dst_id, origt1.id_type_id)
			AND origt1.std_assess_id = EICase00728321.dst_id
			AND origt1.item_id = EICase00728323.dst_id
		)

GROUP BY  ISNULL(EICase00728321.dst_id, std_assess_id)
	,ISNULL(EICase00728323.dst_id, item_id)
	,ISNULL(EICase00728322.dst_id, id_type_id)
	HAVING COUNT(1)>1



select * from pcc_staging_db007283.[dbo].EICase0072832id_type

select * from  pcc_staging_db007283.[dbo].EICase0072832common_code
where dst_id=7106

select * from  pcc_staging_db007283.[dbo].EICase0072832id_type
where dst_id=182

select * from pcc_staging_db007283.[dbo].as_std_assess_header

select * from mergejoinsmaster
where tablename = 'as_std_assess_header' and parenttable = 'id_type' and pkJoin = 'N'

; WITH temp_picklist AS(
SELECT a.*  
,item_description_New=CONCAT(a.item_description,'_',ROW_NUMBER() OVER(PARTITION BY a.item_description ORDER BY a.qlib_pick_list_item_id)-1)
,ROW_NUMBER() OVER(PARTITION BY a.item_description ORDER BY a.qlib_pick_list_item_id) RN
FROM  test_usei547.[dbo].qlib_pick_list_item  a
)
select * from temp_picklist
WHERE RN>1

