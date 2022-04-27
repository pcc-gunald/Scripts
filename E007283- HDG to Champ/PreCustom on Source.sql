SET QUOTED_IDENTIFIER ON;
SET CONTEXT_INFO 0xDC1000000; 
SET DEADLOCK_PRIORITY 4;



print  CHAR(13) + ' prefix sec_roles (only if requested specially)' 

update sec_role 
set description = 'HDG-' + description 
--select * 
from sec_role 
where (system_field <> 'Y' or system_field is null)
and description not like 'HDG%'


--SELECT b.client_id
--	,a.*
UPDATE A
SET client_id=b.client_id
FROM test_usei547.[dbo].care_plan a
INNER JOIN test_usei547.dbo.cp_rev_need b ON b.care_plan_id = a.care_plan_id
WHERE a.care_plan_id <> - 1
	AND a.fac_id = 2
	AND a.client_id = - 1
	
-- response cannot be null error. so updating to blank
DROP TABLE IF EXISTS #TEMP
SELECT a.assess_id,a.std_rap_id,a.response_code
,ID =IDENTITY(INT,1,1)
INTO #TEMP
FROM [dbo].as_rap_profile_response a
INNER JOIN dbo.as_assessment b ON b.assess_id=a.assess_id
WHERE b.fac_id in(-1,2)
AND a.response  IS NULL;

DECLARE @BATCH_SIZE INT =10000
DECLARE @NO_OF_REC INT 
DECLARE @NO_REC_PROCESSED INT =0
DECLARE @msg VARCHAR(500)
SELECT @NO_OF_REC=MAX(ID) FROM #TEMP

IF @BATCH_SIZE>@NO_OF_REC
BEGIN
SET @BATCH_SIZE=@NO_OF_REC
END 

WHILE (@NO_REC_PROCESSED<=@NO_OF_REC)
BEGIN

--SELECT ID 
UPDATE B
SET response=''
FROM #TEMP A
INNER JOIN  [dbo].as_rap_profile_response B ON B.assess_id=A.assess_id
AND B.std_rap_id=A.std_rap_id AND B.response_code=A.response_code
WHERE ID>=@NO_REC_PROCESSED
AND ID <@NO_REC_PROCESSED+@BATCH_SIZE

SET @msg = CONCAT(@NO_REC_PROCESSED+@@ROWCOUNT,' records processed out of ',@NO_OF_REC)
RAISERROR (@msg, 0, 1) WITH NOWAIT

SET @NO_REC_PROCESSED+=@BATCH_SIZE
PRINT(@NO_REC_PROCESSED)
END 


-- unique index error 

DROP TABLE IF EXISTS #Temp_order
SELECT src.std_order_id,src.template_description,NEW_template_description=CONCAT(src.template_description,'__')
INTO #Temp_order
FROM dbo.pho_std_order src
JOIN [pccsql-use2-prod-w28-cli0007.874bf44c721a.database.windows.net].[us_champ_multi].dbo.pho_std_order dst ON src.template_description = dst.template_description
WHERE src.fac_id IN (
		- 1
		,2
		)
	AND (
		src.STATUS <> dst.STATUS
		OR dst.fac_id <> - 1
		)
AND EXISTS (SELECT 1 FROM dbo.pho_std_order  A WHERE A.template_description=CONCAT(src.template_description,'_')
AND A.for_mobile=src.for_mobile
)
ORDER BY CONCAT(src.template_description,'_')


UPDATE B
SET template_description=NEW_template_description
FROM #Temp_order  A
INNER JOIN  dbo.pho_std_order B ON B.std_order_id=A.std_order_id
;




;
WITH TEMP
AS (
	SELECT *
		,row_number() OVER (
			PARTITION BY template_id
			,description ORDER BY section_id
			) rn
	FROM test_usei547.[dbo].pn_template_section
	)
UPDATE TEMP
SET description = CONCAT (
		description
		,'_'
		,rn - 1
		)
FROM TEMP
WHERE rn>1


; WITH temp_picklist AS(
SELECT a.*  
,item_description_New=CONCAT(a.item_description,'_',ROW_NUMBER() OVER(PARTITION BY a.item_description ORDER BY a.qlib_pick_list_item_id)-1)
,ROW_NUMBER() OVER(PARTITION BY a.item_description ORDER BY a.qlib_pick_list_item_id) RN
FROM  test_usei547.[dbo].qlib_pick_list_item  a
)
UPDATE temp_picklist
SET item_description=item_description_New
WHERE RN>1



---for autopre script: fixfor as_std_assess_header mergerror as_std_assess_header__stdAssessId_itemId_idTypeId_CLPK
update pcc_staging_db007283.dbo.mergeJoinsMaster
set pkJoin = 'Y'
--select * from mergejoinsmaster
where tablename = 'as_std_assess_header' and parenttable = 'id_type' and pkJoin = 'N'

---mergeExecuteExtractStep4 --> MergeError : Cannot insert explicit value for identity column in table 'admin_consent' when IDENTITY_INSERT is set to OFF.


DELETE pcc_staging_db007283.dbo.mergeTablesMaster
--select * from pcc_staging_db007858.dbo.mergeTablesMaster
where tablename='admin_consent'





print  CHAR(13) + 'Updating common code - dynamically through admin picklist excel file - Dynamic Admin Picklist running now only run for 1st facility' 

UPDATE src--0 rows
SET src.item_description = dst.item_description
----SELECT a.item_code, a.src_Item_Id, a.src_Item_Description, b.dst_Item_Id, b.dst_Item_Description
----SELECT a.pick_list_name,a.src_Item_Description,dst.item_description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E007283_AdminPickList$] a
LEFT JOIN test_usei547.dbo.common_code AS src on src.item_id = a.src_item_id
LEFT JOIN [pccsql-use2-prod-w28-cli0007.874bf44c721a.database.windows.net].[us_champ_multi].dbo.common_code AS dst on dst.item_id = a.Map_DstItemId
WHERE 
	(
		a.pick_list_name IS NOT NULL -- total mapping provided by analyst to implementer							--
		AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer							--
		AND a.src_item_id IS NOT NULL --eliminate any incorrect provided mappings									--
		AND ISNUMERIC(a.map_dstitemid) = 1 --ignore any DNM or typo errors											--
		AND a.Map_DstItemId NOT IN --remove any dupilicate many to one mappings (Any If_merged not As_is or N)		--
			(
				select dst_Item_Id
				--select dst_Item_Id,if_merged
				from  [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E007283_AdminPickList$] a
				where dst_Item_Id in 
				(
					select map_dstitemid 
					FROM [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E007283_AdminPickList$]
					WHERE pick_list_name IS NOT NULL -- total mapping provided by analyst to implementer	
						AND map_dstitemid IS NOT NULL --total count of mapping provided by implementer		
						AND src_item_id IS NOT NULL --eliminate any incorrect provided mappings	
						AND ISNUMERIC(map_dstitemid) = 1
				)
				and a.If_Merged not in ('As_is','N') -- will not take any record with 'Y'
			)
	)
	and a.id not in --remove any duplicate one to many mappings (2 or more occurances of one mapping)
		(
			select id 
			--select id, pick_list_name, src_item_description, map_dstitemid
			from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E007283_AdminPickList$] 
			where Map_DstItemId in
			(
				select Map_DstItemId
				--select Map_DstItemId, count(*)
				from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E007283_AdminPickList$] 
				where src_Item_Description is not null
				group by Map_DstItemId having count(*) > 1 and Map_DstItemId is NOT NULL
			)
			and id not in
			(			
				select min(id) 
				from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E007283_AdminPickList$] 
				group by map_dstitemid having map_dstitemid in 
					(
						select distinct Map_DstItemId 
						--select id, pick_list_name, src_item_description, map_dstitemid
						from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E007283_AdminPickList$] 
						where Map_DstItemId in
						(
							select Map_DstItemId
							--select Map_DstItemId, count(*)
							from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E007283_AdminPickList$] 
							group by Map_DstItemId having count(*) > 1 and Map_DstItemId is NOT NULL
						)
					)
			)
		)
	and src.item_id = a.src_Item_Id AND dst.item_id = a.Map_DstItemId AND src.item_code = a.item_code -- specifically used for updating the correct item
	--and src.item_id IN ( ???? ) -- any records that has to be excluded that you dont think is a proper merge
---------------------------------------------------
/*

*/
------------------------------------------------

print  CHAR(13) + 'Updating Resident Identifier admin templates - running now for 1st facilty ' 

 
UPDATE src
SET src.description = dst.description
--SELECT distinct a.srcIdTypeId, a.map_dst_typeid, src.description , dst.description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E007283_ResidentIdentifier$] a
JOIN [pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].[test_usei547].dbo.id_type AS src on src.id_type_id = a.srcIdTypeId
JOIN [pccsql-use2-prod-w28-cli0007.874bf44c721a.database.windows.net].[us_champ_multi].dbo.id_type AS dst on dst.id_type_id = a.map_dst_typeid
WHERE  a.srcFieldName IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dst_typeid IS NOT NULL --total count of mapping provided by implementer  



----========================================================================================

print  CHAR(13) + 'Updating User Defined Fields admin templates - running now run for first facility' 


UPDATE src
SET src.field_name = dst.field_name, src.field_length = dst.field_length
--SELECT distinct a.srcFieldTypeId, a.map_dst_typeid, src.field_name , dst.field_name, src.field_data_type, dst.field_data_type, src.field_length, dst.field_length, CASE WHEN src.field_data_type = dst.field_data_type AND src.field_length = dst.field_length THEN 'Possible to Merge' ELSE 'Not Possible to Merge' END as mergePossible
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E007283_UserDefinedData$] a
JOIN [pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].[test_usei547].dbo.user_field_types AS src on src.field_type_id = a.srcFieldTypeId
JOIN [pccsql-use2-prod-w28-cli0007.874bf44c721a.database.windows.net].[us_champ_multi].dbo.user_field_types AS dst on dst.field_type_id = a.map_dst_typeid
WHERE  a.srcFieldName IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dst_typeid IS NOT NULL --total count of mapping provided by implementer  
AND src.field_data_type = dst.field_data_type --1 item returned, all good
--AND src.field_length = dst.field_length


/*

*/
--========================================================================================
-- Clinical Common Code
print  CHAR(13) + 'Updating common code - dynamically through clinical picklist excel file - Dynamic Clinical Picklist running now' 

UPDATE src--1 row
SET src.item_description = dst.item_description
----SELECT a.item_code, a.src_Item_Id, a.src_Item_Description, b.dst_Item_Id, b.dst_Item_Description
----SELECT a.pick_list_name,a.src_Item_Description,dst.item_description,dst.item_id
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E007283_Clinical_common_code$] a
JOIN test_usei547.dbo.common_code AS src on src.item_id = a.src_item_id
JOIN [pccsql-use2-prod-w28-cli0007.874bf44c721a.database.windows.net].[us_champ_multi].dbo.common_code AS dst on dst.item_id = a.Map_DstItemId
WHERE 
	(
		a.pick_list_name IS NOT NULL -- total mapping provided by analyst to implementer							--
		AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer							--
		AND a.src_item_id IS NOT NULL --eliminate any incorrect provided mappings									--
		AND ISNUMERIC(a.map_dstitemid) = 1 --ignore any DNM or typo errors											--
		AND a.Map_DstItemId NOT IN --remove any dupilicate many to one mappings (Any If_merged not As_is or N)		--
			(
				select dst_Item_Id
				--select dst_Item_Id,if_merged
				from  [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E007283_Clinical_common_code$] a
				where dst_Item_Id in 
				(
					select map_dstitemid 
					FROM [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E007283_Clinical_common_code$]
					WHERE pick_list_name IS NOT NULL -- total mapping provided by analyst to implementer	
						AND map_dstitemid IS NOT NULL --total count of mapping provided by implementer		
						AND src_item_id IS NOT NULL --eliminate any incorrect provided mappings	
						AND ISNUMERIC(map_dstitemid) = 1
				)
				and a.If_Merged not in ('As_is','N') -- will not take any record with 'Y'
			)
	)
	and a.id not in --remove any duplicate one to many mappings (2 or more occurances of one mapping)
		(
			select id 
			--select id, pick_list_name, src_item_description, map_dstitemid
			from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E007283_Clinical_common_code$] 
			where Map_DstItemId in
			(
				select Map_DstItemId
				--select Map_DstItemId, count(*)
				from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E007283_Clinical_common_code$] 
				where src_Item_Description is not null
				group by Map_DstItemId having count(*) > 1 and Map_DstItemId is NOT NULL
			)
			and id not in
			(			
				select min(id) 
				from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E007283_Clinical_common_code$] 
				group by map_dstitemid having map_dstitemid in 
					(
						select distinct Map_DstItemId 
						--select id, pick_list_name, src_item_description, map_dstitemid
						from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E007283_Clinical_common_code$] 
						where Map_DstItemId in
						(
							select Map_DstItemId
							--select Map_DstItemId, count(*)
							from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E007283_Clinical_common_code$] 
							group by Map_DstItemId having count(*) > 1 and Map_DstItemId is NOT NULL
						)
					)
			)
		)
	and src.item_id = a.src_Item_Id AND dst.item_id = a.Map_DstItemId AND src.item_code = a.item_code -- specifically used for updating the correct item
	--and src.item_id IN ( ???? ) -- any records that has to be excluded that you dont think is a proper merge
	
--========================================================================================

--print  CHAR(13) + 'Updating clinical picklist excel advanced file - Dynamic Clinical Picklist - others non-common code advanced running now first facility' 

/*

select a.pick_list_name,a.src_desc,b.dst_desc
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E007283_Clinical_Advanced$] a
inner join [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E007283_Clinical_Advanced$] b 
on a.map_dstitemid = b.dst_id and a.pick_list_name = b.pick_list_name
where a.map_dstitemid is not null
AND  a.src_desc IS NOT NULL 
AND a.map_dstitemid IS NOT NULL 
order by a.id

*/

print  CHAR(13) + 'Updating Administration Records (pho_administration_record)'


UPDATE src
SET src.description = dst.description,src.short_description = dst.short_description
--SELECT distinct a.src_id, a.Map_DstItemId, src.description , dst.description,src.short_description, dst.short_description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E007283_Clinical_Advanced$] a
JOIN [pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].[test_usei547].dbo.pho_administration_record AS src on src.administration_record_id = a.src_id
JOIN [pccsql-use2-prod-w28-cli0007.874bf44c721a.database.windows.net].[us_champ_multi].dbo.pho_administration_record AS dst on dst.administration_record_id = a.Map_DstItemId
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = 'Administration Records'  


print  CHAR(13) + 'Updating Order Types (pho_order_type)'


UPDATE src
SET src.description = dst.description
--SELECT distinct a.src_id, a.Map_DstItemId, src.description , dst.description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E007283_Clinical_Advanced$] a
JOIN [pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].[test_usei547].dbo.pho_order_type AS src on src.order_type_id = a.src_id
JOIN [pccsql-use2-prod-w28-cli0007.874bf44c721a.database.windows.net].[us_champ_multi].dbo.pho_order_type AS dst on dst.order_type_id = a.Map_DstItemId
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = 'Order Types' 


print  CHAR(13) + 'Updating Progress Note Types (pn_type)'



UPDATE src
SET src.description = dst.description
--SELECT distinct a.src_id, a.Map_DstItemId, src.description , dst.description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E007283_Clinical_Advanced$] a
JOIN [pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].[test_usei547].dbo.pn_type AS src on src.pn_type_id = a.src_id
JOIN [pccsql-use2-prod-w28-cli0007.874bf44c721a.database.windows.net].[us_champ_multi].dbo.pn_type AS dst on dst.pn_type_id = a.Map_DstItemId
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = 'Progress Note Types'



print  CHAR(13) + 'Updating Immunizations - (cr_std_immunization)'



UPDATE src
SET src.description = dst.description,src.short_description = dst.short_description
--SELECT distinct a.src_id, a.Map_DstItemId, src.description , dst.description, src.short_description, dst.short_description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E007283_Clinical_Advanced$] a
JOIN [pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].[test_usei547].dbo.cr_std_immunization AS src on src.std_immunization_id = a.src_id
JOIN [pccsql-use2-prod-w28-cli0007.874bf44c721a.database.windows.net].[us_champ_multi].dbo.cr_std_immunization AS dst on dst.std_immunization_id = a.Map_DstItemId
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = 'Immunizations'  --3 rows, NULLs


print  CHAR(13) + 'Updating Standard Shifts (cp_std_shift)'

UPDATE src
SET src.description = dst.description
--SELECT distinct a.src_id, a.Map_DstItemId, src.description , dst.description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E007283_Clinical_Advanced$] a
JOIN [pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].[test_usei547].dbo.cp_std_shift AS src on src.std_shift_id = a.src_id
JOIN [pccsql-use2-prod-w28-cli0007.874bf44c721a.database.windows.net].[us_champ_multi].dbo.cp_std_shift AS dst on dst.std_shift_id = a.Map_DstItemId
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = 'Standard Shifts' 


print  CHAR(13) + 'Updating Risk Management Picklists (inc_std_pick_list)'

--select * from [pccsql-use2-prod-w28-cli0007.874bf44c721a.database.windows.net].[us_champ_multi].dbo.mergeTablesmaster where tablename = 'inc_std_pick_list_item'
--description system_flag   pick_list_id
       --S        E              E

UPDATE src
SET src.description = dst.description
--SELECT distinct a.src_id, a.Map_DstItemId, src.description , dst.description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E007283_Clinical_Advanced$] a
JOIN [pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].[test_usei547].dbo.inc_std_pick_list_item AS src on src.pick_list_item_id = a.src_id
JOIN [pccsql-use2-prod-w28-cli0007.874bf44c721a.database.windows.net].[us_champ_multi].dbo.inc_std_pick_list_item AS dst on dst.pick_list_item_id = a.Map_DstItemId
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = 'Risk Management Picklists' 
