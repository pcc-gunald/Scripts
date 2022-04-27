select * from StagingMergeLog
where msg like '%ta_transaction%'

INSERT INTO test_usei1075.dbo.ta_transaction (
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
	)
SELECT transaction_id
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
FROM [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].pcc_staging_db59132_P2.[dbo].ta_transaction
WHERE 1=1
--transaction_id BETWEEN 350200
--		AND 370051
AND Created_date='2022-03-10 17:20:26.287'
	AND Multi_Fac_Id = 34


select * from ta_configuration
where fac_id=34

update ta_configuration
set posting_month=2,posting_year=2022
where fac_id=34


SELECT SUM(TA_TRANSACTION.AMOUNT) AS SUM_VALUE
FROM TA_TRANSACTION
LEFT JOIN CLIENTS CLI ON TA_TRANSACTION.CLIENT_ID = CLI.CLIENT_ID
LEFT JOIN TA_STD_ACCOUNT CTRL_ACC ON TA_TRANSACTION.STD_ACCOUNT_ID = CTRL_ACC.STD_ACCOUNT_ID
LEFT JOIN TA_INCOME_SOURCE INCOMESOURCE ON TA_TRANSACTION.INCOME_SOURCE_ID = INCOMESOURCE.INCOME_SOURCE_ID
	AND (INCOMESOURCE.DELETED = 'N')
LEFT JOIN TA_TRANSACTION SELF ON TA_TRANSACTION.TRANSFER_TX_ID = SELF.TRANSACTION_ID
LEFT JOIN TA_BATCH BAT ON TA_TRANSACTION.BATCH_ID = BAT.BATCH_ID
LEFT JOIN TA_STATEMENT STMT ON TA_TRANSACTION.STATEMENT_ID = STMT.STATEMENT_ID
LEFT JOIN MPI MPI ON CLI.MPI_ID = MPI.MPI_ID
	AND (MPI.DELETED = 'N')
LEFT JOIN TA_CONTROL_ACCOUNT CTRLACCT ON TA_TRANSACTION.ACCOUNT_ID = CTRLACCT.ACCOUNT_ID
WHERE ((TA_TRANSACTION.CASH_BOX_REFERENCE = 'CB-978387'))
	AND (
		(
			TA_TRANSACTION.FAC_ID =34
			OR TA_TRANSACTION.FAC_ID = - 1
			)
		AND (TA_TRANSACTION.DELETED = 'N')
		)


		select * from ta_control_account
		where fac_id=34

			select * from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei998.dbo.ta_control_account
		where fac_id=8