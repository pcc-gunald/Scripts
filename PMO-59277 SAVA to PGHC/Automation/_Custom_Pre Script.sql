use test_usei3sava1

SET CONTEXT_INFO 0xDC1000000;
 SET DEADLOCK_PRIORITY 4;
 SET QUOTED_IDENTIFIER ON;


print  CHAR(13) + 'Updating common code - dynamically through admin picklist excel file - Dynamic Admin Picklist running now' 

UPDATE src
SET src.item_description = dst.item_description
----SELECT a.item_code, a.src_Item_Id, a.src_Item_Description, b.dst_Item_Id, b.dst_Item_Description
----SELECT a.pick_list_name,a.src_Item_Description,b.dst_Item_Description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_AdminPicklist] a
LEFT JOIN [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_AdminPicklist] b ON a.Map_DstItemId = b.dst_Item_Id
LEFT JOIN test_usei3sava1.dbo.common_code AS src on src.item_id = a.src_item_id
LEFT JOIN [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi.dbo.common_code AS dst on dst.item_id = b.dst_item_id
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
				from  [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_AdminPicklist] a
				where dst_Item_Id in 
				(
					select map_dstitemid 
					FROM [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_AdminPicklist]
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
			from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_AdminPicklist] 
			where Map_DstItemId in
			(
				select Map_DstItemId
				--select Map_DstItemId, count(*)
				from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_AdminPicklist] 
				where src_Item_Description is not null
				group by Map_DstItemId having count(*) > 1 and Map_DstItemId is NOT NULL
			)
			and id not in
			(			
				select min(id) 
				from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_AdminPicklist] 
				group by map_dstitemid having map_dstitemid in 
					(
						select distinct Map_DstItemId 
						--select id, pick_list_name, src_item_description, map_dstitemid
						from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_AdminPicklist] 
						where Map_DstItemId in
						(
							select Map_DstItemId
							--select Map_DstItemId, count(*)
							from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_AdminPicklist] 
							group by Map_DstItemId having count(*) > 1 and Map_DstItemId is NOT NULL
						)
					)
			)
		)
	and src.item_id = a.src_Item_Id AND dst.item_id = b.dst_Item_Id AND src.item_code = a.item_code -- specifically used for updating the correct item
	--and src.item_id IN ( ???? ) -- any records that has to be excluded that you dont think is a proper merge

--========================================================================================

print  CHAR(13) + 'Updating Resident Identifier admin templates - running now' 

--select * from mergetablesmaster where tablename = 'id_type'
--description

UPDATE src
SET src.description = dst.description
--SELECT distinct a.srcIdTypeId, b.dstIdTypeId, src.description , dst.description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_ResidentIdentifier] a
LEFT JOIN [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_ResidentIdentifier] b ON a.map_dst_typeid = b.dstIdTypeId
LEFT JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.id_type AS src on src.id_type_id = a.srcIdTypeId
LEFT JOIN [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi.dbo.id_type AS dst on dst.id_type_id = b.dstIdTypeId
WHERE  a.srcFieldName IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dst_typeid IS NOT NULL --total count of mapping provided by implementer  

----========================================================================================

print  CHAR(13) + 'Updating User Defined Fields admin templates - running now' 

--select * from mergetablesmaster where tablename like 'user_field_types'
--field_name  field_data_type     field_length

UPDATE src
SET src.field_name = dst.field_name, src.field_length = dst.field_length
--SELECT distinct a.srcFieldTypeId, b.dstFieldTypeId, src.field_name , dst.field_name, src.field_data_type, dst.field_data_type, src.field_length, dst.field_length, CASE WHEN src.field_data_type = dst.field_data_type AND src.field_length = dst.field_length THEN 'Possible to Merge' ELSE 'Not Possible to Merge' END as mergePossible
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_UserDefinedData] a
LEFT JOIN [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_UserDefinedData] b ON a.map_dst_typeid = b.dstFieldTypeId
LEFT JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.user_field_types AS src on src.field_type_id = a.srcFieldTypeId
LEFT JOIN [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi.dbo.user_field_types AS dst on dst.field_type_id = b.dstFieldTypeId
WHERE  a.srcFieldName IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dst_typeid IS NOT NULL --total count of mapping provided by implementer  
AND src.field_data_type = dst.field_data_type
--AND src.field_length = dst.field_length

--========================================================================================

print  CHAR(13) + 'Updating common code - dynamically through clinical picklist excel file - Dynamic Clinical Picklist running now' 

UPDATE src
SET src.item_description = dst.item_description
----SELECT a.item_code, a.src_Item_Id, a.src_Item_Description, b.dst_Item_Id, b.dst_Item_Description
----SELECT a.pick_list_name,a.src_Item_Description,b.dst_Item_Description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_ClinicalPicklist] a
LEFT JOIN [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_ClinicalPicklist] b ON a.Map_DstItemId = b.dst_Item_Id
LEFT JOIN test_usei3sava1.dbo.common_code AS src on src.item_id = a.src_item_id
LEFT JOIN [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi.dbo.common_code AS dst on dst.item_id = b.dst_item_id
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
				from  [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_ClinicalPicklist] a
				where dst_Item_Id in 
				(
					select map_dstitemid 
					FROM [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_ClinicalPicklist]
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
			from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_ClinicalPicklist] 
			where Map_DstItemId in
			(
				select Map_DstItemId
				--select Map_DstItemId, count(*)
				from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_ClinicalPicklist] 
				where src_Item_Description is not null
				group by Map_DstItemId having count(*) > 1 and Map_DstItemId is NOT NULL
			)
			and id not in
			(			
				select min(id) 
				from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_ClinicalPicklist] 
				group by map_dstitemid having map_dstitemid in 
					(
						select distinct Map_DstItemId 
						--select id, pick_list_name, src_item_description, map_dstitemid
						from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_ClinicalPicklist] 
						where Map_DstItemId in
						(
							select Map_DstItemId
							--select Map_DstItemId, count(*)
							from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_ClinicalPicklist] 
							group by Map_DstItemId having count(*) > 1 and Map_DstItemId is NOT NULL
						)
					)
			)
		)
	and src.item_id = a.src_Item_Id AND dst.item_id = b.dst_Item_Id AND src.item_code = a.item_code -- specifically used for updating the correct item
	--and src.item_id IN ( ???? ) -- any records that has to be excluded that you dont think is a proper merge

--========================================================================================

print  CHAR(13) + 'Updating clinical picklist excel advanced file - Dynamic Clinical Picklist - others non-common code advanced running now' 

/*

select a.pick_list_name,a.src_desc,b.dst_desc
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_ClinicalAdvanced] a
inner join [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_ClinicalAdvanced] b 
on a.map_dstitemid = b.dst_id and a.pick_list_name = b.pick_list_name
where a.map_dstitemid is not null
AND  a.src_desc IS NOT NULL 
AND a.map_dstitemid IS NOT NULL 
order by a.id

*/

print  CHAR(13) + 'Updating Administration Records (pho_administration_record)'

--select * from [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi.dbo.mergeTablesmaster where tablename = 'pho_administration_record'
--administration_record_type_id	description	short_description
		--E							S			S

UPDATE src
SET src.description = dst.description,src.short_description = dst.short_description
--SELECT distinct a.src_id, b.dst_id, src.description , dst.description,src.short_description, dst.short_description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_ClinicalAdvanced] a
LEFT JOIN [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_ClinicalAdvanced] b ON a.Map_DstItemId = b.dst_id
LEFT JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_administration_record AS src on src.administration_record_id = a.src_id
LEFT JOIN [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi.dbo.pho_administration_record AS dst on dst.administration_record_id = b.dst_id
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = 'Administration Records'  

print  CHAR(13) + 'Updating Order Types (pho_order_type)'

--select * from [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi.dbo.mergeTablesmaster where tablename = 'pho_order_type'
--description	mandatory_end_date	order_category_id	administration_record_id
	--S				E					E					E

UPDATE src
SET src.description = dst.description
--SELECT distinct a.src_id, b.dst_id, src.description , dst.description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_ClinicalAdvanced] a
LEFT JOIN [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_ClinicalAdvanced] b ON a.Map_DstItemId = b.dst_id
LEFT JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_order_type AS src on src.order_type_id = a.src_id
LEFT JOIN [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi.dbo.pho_order_type AS dst on dst.order_type_id = b.dst_id
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = 'Order Types'  

print  CHAR(13) + 'Updating Progress Note Types (pn_type)'

--select * from [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi.dbo.mergeTablesmaster where tablename = 'pn_type'
--description retired       template_id   system
       --S      E               E           E

UPDATE src
SET src.description = dst.description
--SELECT distinct a.src_id, b.dst_id, src.description , dst.description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_ClinicalAdvanced] a
LEFT JOIN [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_ClinicalAdvanced] b ON a.Map_DstItemId = b.dst_id
LEFT JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pn_type AS src on src.pn_type_id = a.src_id
LEFT JOIN [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi.dbo.pn_type AS dst on dst.pn_type_id = b.dst_id
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = 'Progress Note Types'  

print  CHAR(13) + 'Updating Immunizations - (cr_std_immunization)'

--select * from [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi.dbo.mergeTablesmaster where tablename = 'cr_std_immunization'
--description track_results multi_step    short_description
       --S           E         E                   S

UPDATE src
SET src.description = dst.description,src.short_description = dst.short_description
--SELECT distinct a.src_id, b.dst_id, src.description , dst.description, src.short_description, dst.short_description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_ClinicalAdvanced] a
LEFT JOIN [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_ClinicalAdvanced] b ON a.Map_DstItemId = b.dst_id
LEFT JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.cr_std_immunization AS src on src.std_immunization_id = a.src_id
LEFT JOIN [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi.dbo.cr_std_immunization AS dst on dst.std_immunization_id = b.dst_id
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = 'Immunizations'  

print  CHAR(13) + 'Updating Standard Shifts (cp_std_shift)'

--select * from [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi.dbo.mergeTablesmaster where tablename = 'cp_std_shift'
--description start_time    end_time
       --S         E            E
	   
UPDATE src
SET src.description = dst.description
--SELECT distinct a.src_id, b.dst_id, src.description , dst.description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_ClinicalAdvanced] a
LEFT JOIN [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_ClinicalAdvanced] b ON a.Map_DstItemId = b.dst_id
LEFT JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.cp_std_shift AS src on src.std_shift_id = a.src_id
LEFT JOIN [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi.dbo.cp_std_shift AS dst on dst.std_shift_id = b.dst_id
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = 'Standard Shifts'  

print  CHAR(13) + 'Updating Risk Management Picklists (inc_std_pick_list)'

--select * from [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi.dbo.mergeTablesmaster where tablename = 'inc_std_pick_list_item'
--description system_flag   pick_list_id
       --S        E              E

UPDATE src
SET src.description = dst.description
--SELECT distinct a.src_id, b.dst_id, src.description , dst.description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_ClinicalAdvanced] a
LEFT JOIN [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-59277_ClinicalAdvanced] b ON a.Map_DstItemId = b.dst_id
LEFT JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.inc_std_pick_list_item AS src on src.pick_list_item_id = a.src_id
LEFT JOIN [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi.dbo.inc_std_pick_list_item AS dst on dst.pick_list_item_id = b.dst_id
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = 'Risk Management Picklists'  

--========================================================================================

--if merge Incident Signing Authority Setup (Signing Authorities)

--Add this to autopre

--update  mergeTablesMaster
--set  scopeField3='position_id', scopeField4 = 'retired_by'
--where tablename='inc_std_signing_authority'

--Add this to pre-script

--select item_description,* 
--from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.inc_std_signing_authority a inner join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code b
--on a.position_id = b.item_id
--where a.fac_id in (-1,183)
--order by b.item_description

--select item_description,* 
--from [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi.dbo.inc_std_signing_authority a inner join [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi.dbo.common_code b
--on a.position_id = b.item_id
--where a.fac_id in (-1,173)
--order by b.item_description

--UPDATE inc_std_signing_authority 
--set fac_id = -1, sequence = 0
----select * 
--from inc_std_signing_authority 
--where sign_id IN () and sequence in ()

--Ref email on Fri 1/25/2019 9:06 AM - Subject - FW: Summary: PMO-40614 - Data Copy to Existing - Future Care Consultants, LLC (AHA to AUTM)- Test db review
--E:\DATALOAD\EI\PMO-40614 AHA to AUTM

--Another example - email on Fri 2/22/2019 11:39 AM - Subject - FW: Summary - PMO-39013-Data Copy to an Existing Org Code - Five Oaks Healthcare (SPNR to FOHC)
--E:\DATALOAD\EI\PMO-39013 SPNR to FOHC
--E:\DATALOAD\EI\PMO-42759 PRST to SAP

--========================================================================================
