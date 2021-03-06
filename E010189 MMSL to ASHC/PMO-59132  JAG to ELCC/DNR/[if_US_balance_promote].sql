USE [test_usei206]
GO
/****** Object:  StoredProcedure [dbo].[if_US_balance_promote]    Script Date: 05/21/2013 10:16:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[if_US_balance_promote] @fileID int = NULL,
												@CreatedBy  VARCHAR(16) = 'Bulkload' AS

SET NOCOUNT ON 
DECLARE @MaxBatchID int,
		@MaxEntryNumber int,
		@MaxTransactionID int,
		@Rowcount int
		
-- added on Feb 4, 2010 for combined validation
DECLARE @FILE_TYPE VARCHAR(50)
SET @FILE_TYPE = NULL
IF EXISTS (SELECT 1 FROM sys.columns inner join sys.types on sys.columns.system_type_id = sys.types.system_type_id
WHERE sys.columns.NAME = 'file_type_id' and object_id = object_id('if_us_error_detail') and sys.types.name = 'varchar')
	BEGIN
		SET @FILE_TYPE = 'Balance'
	END
-- end added on Feb 4, 2010 for combined validation

/*
 *   Prepare Batch Total records
 */
select    identity(int,0,1) as batch_id,
   facility.fac_id,
   'N' as Deleted,
   @CreatedBy as Created_by,
   getdate() as created_date,
   'Balance Forward' as description,
   effective_date as transaction_date,
   sum(cast(balance_due as money)) as control_total,
   'Posted' as status,
   'X' batch_type,
	(select max(batch_number) from ar_batch where fac_id = facility.fac_id and batch_type = 'X') as maxbatchnumber
into #ar_batch
from if_US_ARbalance 
JOIN [dbo].facility
   on if_US_ARbalance.facility_number=facility.facility_code
join clients
   on clients.client_id_number=if_US_ARbalance.client_id_number
   and clients.fac_id=facility.fac_id
   and clients.deleted='N'
where file_id=isnull(@fileID,file_id)
and row_id not in (select row_id from if_US_error_detail inner join if_US_error_code
   on if_US_error_detail.error_code=if_US_error_code.error_code
   where if_US_error_code.severity ='Critical'
   and file_id=isnull(@fileID,file_id)
	and file_type_id = isnull(@FILE_TYPE,file_type_id))  --added for combined validation
group by facility.fac_id, if_US_ARbalance.effective_date
order by facility.fac_id, if_US_ARbalance.effective_date


/*
 *    Insert Data Into ar_batch
 */


set @Rowcount=@@rowcount
exec get_next_primary_key 'ar_batch','batch_id',@MaxBatchId output , @rowcount  

Insert into ar_batch(batch_id,fac_id,deleted,created_by,created_date,batch_number,description,
      transaction_date,control_total,batch_total,status,batch_type)
   select    batch_id+@MaxBatchId,
      #ar_batch.fac_id,
      Deleted,
      created_by,
      created_date,
      (#ar_batch.batch_id - b.batchmin + 1) + isnull(maxbatchnumber,0),
      description,
      transaction_date,
      control_total,
      control_total,
      status,
      batch_type
      from #ar_batch, (select min(batch_id) as batchmin, fac_id from #ar_batch group by fac_id) as b
	  where #ar_batch.fac_id = b.fac_id


/*
 *   Prepare Transaction records
 */
select   identity(int,0,1) as transaction_id,
   facility.fac_id,
   'N' as Deleted,
   @CreatedBy as Created_by,
   getdate() as created_date,
   #ar_batch.batch_id as batch_id ,
   -999 as invoice_id,
   ar_lib_payers.account_id as dollars_account_id,
   ar_lib_payers.payer_id, 
   clients.client_id,
   'Balance Forward' as description,
   cast(balance_due as money) as balance_due,
   effective_date,
   1 as days_amount,
   'Y' as Posted_flag,
   'N' as auto_generated,
   'F' as full_or_copay,
   'X' as transaction_type
into #ar_transaction
   from if_US_ARbalance inner join facility
   on if_US_ARbalance.facility_number=facility.facility_code
   inner join ar_lib_payers
   on if_US_ARbalance.payer_id=ar_lib_payers.payer_id --(rtrim(ltrim(ar_lib_payers.payer_code)) + rtrim(ltrim(ar_lib_payers.payer_code2)))
	inner join ar_payers on ar_lib_payers.payer_id = ar_payers.payer_id
	and ar_payers.fac_id=facility.fac_id
	and ar_lib_payers.deleted = 'N'   
   inner join clients
   on clients.client_id_number=if_US_ARbalance.client_id_number
   and clients.fac_id=facility.fac_id
   and clients.deleted = 'N'
   inner join #ar_batch
   on #ar_batch.transaction_date=if_US_ARbalance.effective_date
   and #ar_batch.fac_id=facility.fac_id
where  file_id=isnull(@fileID,file_id)
and row_id not in (select row_id from if_US_error_detail inner join if_US_error_code
   on if_US_error_detail.error_code=if_US_error_code.error_code
   where if_US_error_code.severity ='Critical'
   and file_id=isnull(@fileID,file_id)
	and file_type_id = isnull(@FILE_TYPE,file_type_id))  --added for combined validation
order by facility.fac_id, #ar_batch.batch_id

/*
 *   Insert into ar_transactions
 */


set @Rowcount=@@rowcount
exec get_next_primary_key 'ar_transactions','transaction_id',@maxTransactionID output , @rowcount  

insert into ar_transactions(transaction_id,fac_id,deleted,created_by,created_date,batch_id,--item_type_id,
   invoice_id,dollars_account_id,
   days_account_id,payer_id,client_id,description,amount,balance_due,days_amount,effective_date,transaction_date,daily_rate,entry_number,
   posted_flag,auto_generated,distribution_amount,full_or_copay,transaction_type)
   select transaction_id+@maxTransactionID,
      fac_id,
      deleted,
      created_by,
      created_date,
      #ar_transaction.batch_id+@MaxBatchID,
      --item_type_id,
      invoice_id,
      dollars_account_id,
      NULL, -- before it was 1, changed by rajan
      payer_id,
      client_id,
      description,
      balance_due,
      balance_due,
      NULL, -- before it was 1, changed by rajan
      effective_date,
      effective_date,
      balance_due,
	  (#ar_transaction.transaction_id - b.tranmin + 1),
      posted_flag,
      auto_generated,
      balance_due,
      full_or_copay,
      transaction_type
   from #ar_transaction, (select min(transaction_id) as tranmin, batch_id from #ar_transaction group by batch_id) as b
	  where #ar_transaction.batch_id = b.batch_id


drop table #ar_batch
drop table #ar_transaction
