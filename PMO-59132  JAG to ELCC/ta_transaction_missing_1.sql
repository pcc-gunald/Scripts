CREATE TABLE EICase591232_28ta_transaction_missing (row_id INT IDENTITY,src_id BIGINT,dst_id BIGINT)



INSERT INTO EICase591232_28ta_transaction_missing (src_id)
SELECT transaction_id
--SELECT *
FROM test_usei998.[dbo].ta_transaction
WHERE transaction_id <> - 1
AND (
fac_id = 8
OR fac_id = - 1
)
AND client_id IS NULL
ORDER BY transaction_id

/*
(420 rows affected)

Completion time: 2022-03-10T17:10:54.8483996-05:00

*/

DECLARE @Maxta_transaction INT,@Rowcount1 INT,@facid1 INT;
SET @Rowcount1 = (SELECT count(1) from EICase591232_28ta_transaction_missing)
EXEC [pccsql-use2-prod-ssv-tscon11.b4ea653240a9.database.windows.net].test_usei1075.dbo.get_next_primary_key 'ta_transaction ' ,'transaction_id',@Maxta_transaction OUTPUT,@Rowcount1



UPDATE EICase591232_28ta_transaction_missing
SET dst_id = @Maxta_transaction + ([row_id] - 1)
WHERE dst_id IS NULL

/*
(420 rows affected)

Completion time: 2022-03-10T17:12:10.5009098-05:00

*/

select * from EICase591232_28ta_transaction_missing




 INSERT INTO pcc_staging_db59132_P2.[dbo].ta_transaction (
	transaction_id
	,fac_id
	,deleted
	,created_by
	,created_date
	,revision_by
	,revision_date
	,batch_id
	,client_id
	,std_account_id
	,account_id
	,income_source_id
	,item_type_id
	,transaction_type
	,transfer_tx_id
	,transaction_date
	,effective_date
	,description
	,amount
	,vendor_id
	,reference
	,cash_box_reference
	,cheque_number
	,statement_date
	,ctrl_statement_date
	,ar_transaction_id
	,units
	,entry_number
	,DELETED_BY
	,DELETED_DATE
	,statement_id
	,gl_batch_id
	,MULTI_FAC_ID
	)
SELECT DISTINCT b.dst_id
	,copy_fac.dst_id
	,[deleted]
	,'EICase59132_P28'
	,getDate()
	,'EICase59132_P28'
	,getDate()
	,ISNULL(EICase59132_P285.dst_id, batch_id)
	,NULL--,ISNULL(EICase59132_P281.dst_id, client_id)
	,ISNULL(EICase59132_P283.dst_id, std_account_id)
	,ISNULL(EICase59132_P282.dst_id, account_id)
	,[income_source_id]
	,ISNULL(EICase59132_P287.dst_id, item_type_id)
	,[transaction_type]
	,ISNULL(EICase59132_P284.dst_id, transfer_tx_id)
	,[transaction_date]
	,[effective_date]
	,[description]
	,[amount]
	,[vendor_id]
	,[reference]
	,[cash_box_reference]
	,[cheque_number]
	,[statement_date]
	,[ctrl_statement_date]
	,[ar_transaction_id]
	,[units]
	,[entry_number]
	,[DELETED_BY]
	,[DELETED_DATE]
	,ISNULL(EICase59132_P286.dst_id, statement_id)
	,[gl_batch_id]
	,34
FROM test_usei998.[dbo].ta_transaction a
JOIN pcc_staging_db59132_P2.[dbo].EICase59132_P28facility copy_fac ON copy_fac.src_id = a.fac_id
	OR copy_fac.src_id = 8
-- JOIN pcc_staging_db59132_P2.[dbo].EICase59132_P28clients EICase59132_P281 ON EICase59132_P281.src_id = a.client_id
LEFT JOIN pcc_staging_db59132_P2.[dbo].EICase59132_P28ta_control_account EICase59132_P282 ON EICase59132_P282.src_id = a.account_id
LEFT JOIN pcc_staging_db59132_P2.[dbo].EICase59132_P28ta_std_account EICase59132_P283 ON EICase59132_P283.src_id = a.std_account_id
LEFT JOIN pcc_staging_db59132_P2.[dbo].EICase591232_28ta_transaction_missing EICase59132_P284 ON EICase59132_P284.src_id = a.transfer_tx_id
LEFT JOIN pcc_staging_db59132_P2.[dbo].EICase59132_P28ta_batch EICase59132_P285 ON EICase59132_P285.src_id = a.batch_id
LEFT JOIN pcc_staging_db59132_P2.[dbo].EICase59132_P28ta_statement EICase59132_P286 ON EICase59132_P286.src_id = a.statement_id
LEFT JOIN pcc_staging_db59132_P2.[dbo].EICase59132_P28ta_item_type EICase59132_P287 ON EICase59132_P287.src_id = a.item_type_id
	,pcc_staging_db59132_P2.[dbo].EICase591232_28ta_transaction_missing b
WHERE a.transaction_id <> - 1
	AND a.fac_id IN (
		8
		,- 1
		)
	AND a.transaction_id = b.src_id
	--AND b.corporate = 'N'
	--AND a.client_id IS NULL

	select a.*
FROM test_usei998.[dbo].ta_transaction a
JOIN pcc_staging_db59132_P2.[dbo].EICase591232_28ta_transaction_missing copy_fac ON copy_fac.src_id = a.fac_id

select * from pcc_staging_db59132_P2.[dbo].ta_transaction
order by 1 desc


select * from test_usei998.[dbo].ta_configuration
where fac_id=8

select * from mergeJoinsMaster
where tablename='ta_transaction'