UPDATE a
SET deleted = 'Y'
--select * 
FROM common_code a
WHERE item_id IN (
		SELECT dst_id
		FROM EICase007693common_code
		WHERE src_id = 10933
		)