
-- This script can be used to check if the common_code mapping files provided by SME has any potential concerns. like: duplicate mappings and invalid mappings

-- Replace [PMO-58041_AdminPicklist$] with you ADMIN or CLINICAL common code mapping files


-- 1. Below are items that are mapped to items already merging with something else based on If_merged Flag. 

SELECT *
FROM [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-58041_AdminPicklist$]
WHERE ISNUMERIC(map_dstitemid) = 1
	AND map_dstitemid IN (
		SELECT dst_item_id
		FROM [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-58041_AdminPicklist$]
		WHERE If_Merged = 'Y'
		)


-- 2. Below are items that have multi:1 mappings and can cause errors. 

SELECT *
--select id, pick_list_name, src_item_description, map_dstitemid
FROM [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-58041_AdminPicklist$]
WHERE ISNUMERIC(map_dstitemid) = 1
	AND Map_DstItemId IN (
		SELECT Map_DstItemId
		--select Map_DstItemId, count(*)
		FROM [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-58041_AdminPicklist$]
		WHERE src_Item_Description IS NOT NULL
		GROUP BY Map_DstItemId
		HAVING count(*) > 1
			AND Map_DstItemId IS NOT NULL
		)

-- 3. Below are items that are mapped to items that we brought over in this copy and are not a valid destination items. 

SELECT *
FROM [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-58041_AdminPicklist$]
WHERE ISNUMERIC(map_dstitemid) = 1
	AND map_dstitemid IN (
		SELECT dst_item_id
		FROM [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO-58041_AdminPicklist$]
		WHERE If_Merged = 'N'
		)
