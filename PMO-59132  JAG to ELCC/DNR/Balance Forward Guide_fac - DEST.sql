USE [test_usei206]
GO
------------this was run in production on 6/1/2016

--Load BF file  using  the  DS Helper
----either import manually using import task or use DS helper

--5.	Review file by running this query from Management Studio:

--SELECT * FROM [USC1\PCC_CONV2012_1].[pcc_temp_storage].dbo.[_bkp_BF-WYOMtest]

--  update  facility,  chck dst facility
update  facility
set facility_code='50112'
--select  facility_code, * from  facility
where fac_id=3

----****PRIOR TO IMPORTING EXTRACTED FILE: delete the payer_code column
--use DS helper and load the extracted  BF file 
-----DSH -> implementations -> general imports -> balance. 
-----use the DS case number and correct org code (usei DBs for testing)
----Because of an odd quirk of DS helper, set file header column # to 0.

select  *  from  if_us_ARbalance

delete if_us_ARbalance  ---because of the quirk above, column headers are imported as a row. delete.
where row_id=1

update  if_us_ARbalance
set  payer_id=b.Map_dstPAyerID
--select  *  
from  if_us_ARbalance a
join  [UDS2\DS3].pcc_temp_storage.dbo._bkp_PMO39087_GID_to_WES_PayerMappingTemplate b
on a.payer_id=b.srcpayerid  --112


--select  *  from  [pcc_temp_storage].[dbo].[PMO36118_FGR_to_GCRC_PayerMappingTemplate]

--------------


--select  sum (convert, float(balance_due))  from  if_us_ARbalance

----check if any payer IDs don't exist in the dst ar_payers table (active payers - not ar_lib_payers)
SELECT distinct payer_id FROM if_us_ARbalance
where payer_id not in  (select  payer_id from  ar_payers where fac_id=3) 
--1
--payer_id
--228

select  *  from  if_us_ARbalance
where payer_id in  (228) --1

--select  payer_id,description,*  from  [US34023\PRODW12B].us_fgr.dbo.ar_lib_payers
--where payer_id in  (228)


update if_us_ARbalance
set  payer_id=430
where  payer_id=228

--select  *  from   if_us_ARbalance
--where payer_id in  ('MCAHIV','MGP','MPA') --MESA

--6.	Check if there are any duplicates in the file:

SELECT client_id_number, payer_id, balance_due, effective_date
FROM if_us_ARbalance
GROUP BY client_id_number, payer_id, balance_due, effective_date
HAVING COUNT(*) > 1
--0

--7.	Check if there are any errors:
SELECT * FROM if_us_error_detail
--delete  if_us_error_detail  ---clear them out if there are any

----****BEFORE RUNNING THESE: ONE NEEDS TO BE MODIFIED. 
	--Go to the destination DB in SSMS, open the sql file [if_US_balance_validate_lookup],
	--execute it. it modifies the SP which will resolve the issue of all payers not existing
exec dbo.if_US_balance_validate_datatype
exec  dbo.if_US_balance_validate_lookup

----Investigate any errors if there are any
SELECT * FROM if_us_error_detail
--where  error_param1 ='payer_id does not exist' --0

--select * from if_us_ARbalance where row_id = 70

--8.	Execute the statement below to review how many rows will be imported
---******BEFORE RUNNING: open the file [if_US_balance_promote_check] in the dst DB and run it, 
---it updates the below SP:
exec dbo.if_US_balance_promote_check
/*
19
127
Batch_total
149578.14
Transaction_total
149578.14

*/
----Check the dst DB for transactions and batches tied to the dst facility, and if any are created by bulkload:
select  *  from  ar_transactions
where fac_id=3 --997
and  created_by like '%bulk%' --0

select  *  from  ar_batch
where fac_id=3 --8
and  created_by like '%bulk%' --0




--- the first table will show how many batches will be created (should match the number for this query:  
--SELECT DISTINCT effective_date FROM if_us_ARbalance)

--- the second table will show how many transactions will be created 
--(should match the number for this query: SELECT * FROM if_us_ARbalance)

--9.	If the numbers match from step 8, you can execute the statement below to complete the import

-----*****BEFORE RUNNING: open the file [if_US_balance_promote] in the dst, run it to update the SP
exec dbo.if_US_balance_promote

--10. To review if the import was successful, run the following queries:

select facility_code, *  from  facility
where  fac_id=3

select  *  from  if_us_arbalance --188

SELECT * FROM ar_batch 
WHERE fac_id =  3
AND created_by = 'Bulkload' --19

SELECT * FROM ar_transactions 
WHERE fac_id =  3
AND created_by = 'Bulkload' --127


--  update  facility, change it back to empty string
update  facility
set facility_code=''
--select  facility_code, * from  facility
where fac_id=3 and facility_code = '50112'
-----------
--delete ar_batch 
--WHERE fac_id =  3
--AND created_by = 'Bulkload'

--delete ar_transactions 
--WHERE fac_id =  3
--AND created_by = 'Bulkload'