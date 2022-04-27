SELECT  * 
INTO common_code_bkp
FROM  pcc_staging_db08866.[dbo].common_code  a

DELETE a
FROM  pcc_staging_db08866.[dbo].common_code  a
LEFT JOIN pcc_staging_db08866.[dbo].EICase088666common_code b on b.dst_id=a.item_id
WHERE  b.dst_id is null