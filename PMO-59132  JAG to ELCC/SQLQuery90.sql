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
	INTO ta_transaction_missing
FROM [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].pcc_staging_db59132_P2.[dbo].ta_transaction
WHERE 1=1
--transaction_id BETWEEN 350200
--		AND 370051
AND Created_date='2022-03-10 17:20:26.287'
	AND Multi_Fac_Id = 34


ALTER TABLE ta_transaction_missing
ADD ID INT  IDENTITY (1,1)

DECLARE @Maxta_transaction INT,@Rowcount1 INT,@facid1 INT;
SET @Rowcount1 = (SELECT count(1)+1 from ta_transaction_missing)
EXEC us_elcc_multi.dbo.get_next_primary_key 'ta_transaction ' ,'transaction_id',@Maxta_transaction OUTPUT,@Rowcount1



UPDATE ta_transaction_missing
SET transaction_id = @Maxta_transaction + (ID - 1)

SELECT @Maxta_transaction


select * from ta_transaction_missing
order by 1 

--370052 -- 370471

select max(transaction_id) from us_elcc_multi.dbo.ta_transaction

INSERT INTO  us_elcc_multi.dbo.ta_transaction ( transaction_id, fac_id, deleted, created_by, created_date, revision_by, revision_date, batch_id, client_id, std_account_id, account_id, income_source_id, item_type_id, transaction_type, transfer_tx_id, transaction_date, 
                         effective_date, description, amount, vendor_id, reference, cash_box_reference, cheque_number, statement_date, ctrl_statement_date, ar_transaction_id, units, entry_number, DELETED_BY, DELETED_DATE, statement_id, 
                         gl_batch_id)
SELECT        transaction_id, fac_id, deleted, created_by, created_date, revision_by, revision_date, batch_id, client_id, std_account_id, account_id, income_source_id, item_type_id, transaction_type, transfer_tx_id, transaction_date, 
                         effective_date, description, amount, vendor_id, reference, cash_box_reference, cheque_number, statement_date, ctrl_statement_date, ar_transaction_id, units, entry_number, DELETED_BY, DELETED_DATE, statement_id, 
                         gl_batch_id
FROM            ta_transaction_missing



SELECT *
INTO [pcc_temp_storage].dbo.TEMP_ta_configuration_59132_P2_ta_configuration
FROM ta_configuration


update ta_configuration
set posting_month=2,posting_year=2022
where fac_id=34