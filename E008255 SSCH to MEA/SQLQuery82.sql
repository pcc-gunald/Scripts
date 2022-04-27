--select * from ta_transaction


--select * from MergeLog
--where msg like '%ta_transaction%'

--select account_id,sum(amount) from test_usei964.dbo.ta_transaction
--where fac_id=1
--group by account_id

--select account_id,sum(amount) from test_usei964.dbo.ta_transaction
--where fac_id=1
--and client_id is not null
--group by account_id


--select account_id,sum(amount) from ta_transaction
--group by account_id


--select *  from test_usei964.dbo.ta_control_account




CREATE TABLE pcc_staging_db008255.[dbo].EICase0082551ta_transaction_missing (row_id bigint IDENTITY, src_id bigint, dst_id bigint, corporate CHAR(1) DEFAULT 'N')



INSERT INTO pcc_staging_db008255.[dbo].EICase0082551ta_transaction_missing (src_id)
SELECT transaction_id FROM test_usei964.[dbo].ta_transaction    WHERE transaction_id <> -1  AND (fac_id = 1 OR fac_id = -1)  
AND client_id IS NULL
ORDER BY transaction_id

DECLARE @Maxta_transaction INT,@Rowcount1 INT,@facid1 INT;
SET @Rowcount1 = (SELECT count(1) from EICase0082551ta_transaction_missing)
EXECUTE [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei31.[dbo].[get_next_primary_key]'ta_transaction ' ,'transaction_id',@Maxta_transaction OUTPUT,@Rowcount1


UPDATE pcc_staging_db008255.[dbo].EICase0082551ta_transaction_missing SET  dst_id= @Maxta_transaction+([row_id]-1) WHERE dst_id IS NULL

 INSERT INTO pcc_staging_db008255.[dbo].ta_transaction (
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
SELECT DISTINCT 
	b.dst_id transaction_id
	,copy_fac.dst_id fac_id
	,[deleted]
	,'EICase0082551' created_by
	,getDate() created_date
	,'EICase0082551' revision_by
	,getDate() revision_date
	,ISNULL(EICase00825515.dst_id, batch_id) batch_id
	,ISNULL(EICase00825511.dst_id, client_id)client_id
	,ISNULL(EICase00825513.dst_id, std_account_id) std_account_id
	,ISNULL(EICase00825512.dst_id, account_id) account_id
	,[income_source_id]
	,ISNULL(EICase00825517.dst_id, item_type_id) item_type_id
	,[transaction_type]
	,ISNULL(EICase00825514.dst_id, transfer_tx_id) transfer_tx_id
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
	,ISNULL(EICase00825516.dst_id, statement_id) statement_id
	,[gl_batch_id]
	,2 MULTI_FAC_ID
	INTO ta_transaction_missing
FROM test_usei964.[dbo].ta_transaction a
JOIN pcc_staging_db008255.[dbo].EICase0082551facility copy_fac ON copy_fac.src_id = a.fac_id
	OR copy_fac.src_id = 1
LEFT JOIN pcc_staging_db008255.[dbo].EICase0082551clients EICase00825511 ON EICase00825511.src_id = a.client_id
JOIN pcc_staging_db008255.[dbo].EICase0082551ta_control_account EICase00825512 ON EICase00825512.src_id = a.account_id
LEFT JOIN pcc_staging_db008255.[dbo].EICase0082551ta_std_account EICase00825513 ON EICase00825513.src_id = a.std_account_id
LEFT JOIN pcc_staging_db008255.[dbo].EICase0082551ta_transaction_missing EICase00825514 ON EICase00825514.src_id = a.transfer_tx_id
LEFT JOIN pcc_staging_db008255.[dbo].EICase0082551ta_batch EICase00825515 ON EICase00825515.src_id = a.batch_id
LEFT JOIN pcc_staging_db008255.[dbo].EICase0082551ta_statement EICase00825516 ON EICase00825516.src_id = a.statement_id
LEFT JOIN pcc_staging_db008255.[dbo].EICase0082551ta_item_type EICase00825517 ON EICase00825517.src_id = a.item_type_id
	,pcc_staging_db008255.[dbo].EICase0082551ta_transaction_missing b
WHERE a.transaction_id <> - 1
	AND a.fac_id IN (
		1
		--,- 1
		)
	AND a.transaction_id = b.src_id
	AND b.corporate = 'N'
	AND EICase00825511.src_id IS NULL
	;




DROP TABLE #temp
select * 
into #temp
from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].pcc_staging_db008255.dbo.ta_transaction_missing


INSERT INTO ta_transaction(transaction_id,fac_id, deleted, created_by, created_date, revision_by, revision_date, batch_id, client_id, std_account_id, account_id, income_source_id, item_type_id, transaction_type, transfer_tx_id, transaction_date, 
                         effective_date, description, amount, vendor_id, reference, cash_box_reference, cheque_number, statement_date, ctrl_statement_date, ar_transaction_id, units, entry_number, DELETED_BY, DELETED_DATE, statement_id, 
                         gl_batch_id)
SELECT       transaction_id,  fac_id, deleted, created_by, created_date, revision_by, revision_date, batch_id, client_id, std_account_id, account_id, income_source_id, item_type_id, transaction_type, transfer_tx_id, transaction_date, 
                         effective_date, description, amount, vendor_id, reference, cash_box_reference, cheque_number, statement_date, ctrl_statement_date, ar_transaction_id, units, entry_number, DELETED_BY, DELETED_DATE, statement_id, 
                         gl_batch_id
FROM            #temp