select * from MergeLog
where msg like '%EICase0072832qlib_pick_list_item%'
order by msgTime desc 

mergeExecuteExtractStep4 --> MergeError : Violation of PRIMARY KEY constraint 'qlib_pick_list_item_mapping__qlibPickListId_qlibPickListItemId_PK_CL_IX'. 
Cannot insert duplicate key in object 'dbo.qlib_pick_list_item_mapping'. The duplicate key value is (370, 284).

 --INSERT INTO pcc_staging_db007283.[dbo].qlib_pick_list_item_mapping (
	--qlib_pick_list_id
	--,qlib_pick_list_item_id
	--,default_sequence
	--,MULTI_FAC_ID
	--)
SELECT DISTINCT [qlib_pick_list_id]
	,ISNULL(EICase00728321.dst_id, qlib_pick_list_item_id)
	,[default_sequence]
	,50
	,EICase00728321.dst_id, qlib_pick_list_item_id
FROM test_usei547.[dbo].qlib_pick_list_item_mapping a
JOIN pcc_staging_db007283.[dbo].EICase0072832qlib_pick_list_item EICase00728321 ON EICase00728321.src_id = a.qlib_pick_list_item_id
WHERE NOT EXISTS (
		SELECT 1
		FROM [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1062.[dbo].qlib_pick_list_item_mapping origt
		WHERE origt.qlib_pick_list_id = a.qlib_pick_list_id
			AND origt.qlib_pick_list_item_id = EICase00728321.dst_id
		)
	AND NOT EXISTS (
		SELECT 1
		FROM pcc_staging_db007283.[dbo].qlib_pick_list_item_mapping origt1
		WHERE origt1.qlib_pick_list_id = a.qlib_pick_list_id
			AND origt1.qlib_pick_list_item_id = EICase00728321.dst_id
		)
and [qlib_pick_list_id]=370
and ISNULL(EICase00728321.dst_id, qlib_pick_list_item_id)=284



SELECT  [qlib_pick_list_id]
	,ISNULL(EICase00728321.dst_id, qlib_pick_list_item_id)
FROM test_usei547.[dbo].qlib_pick_list_item_mapping a
JOIN pcc_staging_db007283.[dbo].EICase0072832qlib_pick_list_item EICase00728321 ON EICase00728321.src_id = a.qlib_pick_list_item_id
WHERE NOT EXISTS (
		SELECT 1
		FROM [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1062.[dbo].qlib_pick_list_item_mapping origt
		WHERE origt.qlib_pick_list_id = a.qlib_pick_list_id
			AND origt.qlib_pick_list_item_id = EICase00728321.dst_id
		)
	AND NOT EXISTS (
		SELECT 1
		FROM pcc_staging_db007283.[dbo].qlib_pick_list_item_mapping origt1
		WHERE origt1.qlib_pick_list_id = a.qlib_pick_list_id
			AND origt1.qlib_pick_list_item_id = EICase00728321.dst_id
		)
GROUP BY  [qlib_pick_list_id]
	,ISNULL(EICase00728321.dst_id, qlib_pick_list_item_id)
	HAVING COUNT(1)>1


select * from test_usei547.[dbo].qlib_pick_list_item_mapping a
inner join test_usei547.[dbo].qlib_pick_list_item b on b.qlib_pick_list_item_id=a.qlib_pick_list_item_id
where qlib_pick_list_id=370

select * from  pcc_staging_db007283.[dbo].EICase0072832qlib_pick_list_item
where dst_id=284

select * from  test_usei547.[dbo].qlib_pick_list_item a
where 1=1
and qlib_pick_list_item_id in(237,1638)
and exists(select 1 from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1062.[dbo].qlib_pick_list_item b where b.item_description=a.item_description)

select * from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1062.[dbo].qlib_pick_list_item 
where qlib_pick_list_item_id=284

; WITH temp_picklist AS(
SELECT b.*  ,a.qlib_pick_list_id
,ROW_NUMBER() OVER(PARTITION BY a.qlib_pick_list_id,b.item_description ORDER BY b.qlib_pick_list_item_id) RN
FROM  test_usei547.[dbo].qlib_pick_list_item_mapping  a
INNER JOIN  test_usei547.[dbo].qlib_pick_list_item b on b.qlib_pick_list_item_id=a.qlib_pick_list_item_id
)
SELECT * FROM temp_picklist
WHERE RN>1
ORDER BY 1


; WITH temp_picklist AS(
SELECT a.*  
,item_description_New=CONCAT(a.item_description,'_',ROW_NUMBER() OVER(PARTITION BY a.item_description ORDER BY a.qlib_pick_list_item_id)-1)
,ROW_NUMBER() OVER(PARTITION BY a.item_description ORDER BY a.qlib_pick_list_item_id) RN
FROM  test_usei547.[dbo].qlib_pick_list_item  a
)
UPDATE temp_picklist
SET item_description=item_description_New
WHERE RN>1
