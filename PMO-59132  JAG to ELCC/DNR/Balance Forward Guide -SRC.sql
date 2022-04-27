----run this script entirely - it generates the output you need to put into excel
----notes: payer_code column needs to be deleted after moving to excel
----client_id_number will have leading zeroes removed on paste, make sure column is formatted to text prior to paste
----date columns need to be formatted to date in excel
----facility_code is needed for the update in the dst script

----Variables that need to be updated: date and source fac_id.  Reference date MUST be the 1st of the month

----After generating the spreadsheet: go to source frontend, admin reports, A/R Aging.  Set the month to the one
--previous to the month set in @reference_date and run the report.  Look at the TOTAL (bottom line),
--then do an autosum in excel on the balance_due column and make sure those numbers match EXACTLY.

declare @reference_date datetime
declare @month int
declare @year int
declare @fac_id int

--select ar_start_date, * from [US32056\PRODW3G].[us_wes].dbo.ar_configuration where fac_id = 3
--2019-01-01 00:00:00.000
--select * from [US32056\PRODW3G].[us_wes].dbo.facility where fac_id = 3

set @reference_date = '01-01-2019' --- use the ar_start_date  of the ar_configuration in dest DB
set @fac_id = 1  -- fac_id of the src DB

SELECT SUM(VIEW_AR_AGING.amount) as Amount, convert(datetime,convert(varchar,year(VIEW_AR_AGING.effective_date)) + '-' + convert(varchar,month(VIEW_AR_AGING.effective_date)) + '-01') as Effective_Date,
mpi.last_name, mpi.first_name, client.client_id_number, VIEW_AR_AGING.client_id, 
        VIEW_AR_AGING.payer_id, libpayer.payer_code, libpayer.payer_code2, libpayer.description AS payer_desc, client.fac_id 
into #temp
FROM view_ar_aging_rollup VIEW_AR_AGING 
LEFT JOIN CLIENTS client ON VIEW_AR_AGING.client_id = client.client_id AND (client.deleted = 'N')  
LEFT JOIN MPI mpi ON client.mpi_id = mpi.mpi_id AND (mpi.deleted = 'N')  
LEFT JOIN AR_PAYERS payer ON VIEW_AR_AGING.payer_id = payer.payer_id AND VIEW_AR_AGING.fac_id = payer.fac_id 
LEFT JOIN AR_LIB_PAYERS libpayer ON VIEW_AR_AGING.payer_id = libpayer.payer_id AND (libpayer.deleted = 'N')  
WHERE (((VIEW_AR_AGING.transaction_id IS NOT NULL  AND VIEW_AR_AGING.transaction_date  <  @reference_date
AND VIEW_AR_AGING.amount IS NOT NULL  AND VIEW_AR_AGING.amount  <>  0 ) 
AND (VIEW_AR_AGING.client_id  >  0  --AND libpayer.payer_type  <>  'Outpatient'  
AND VIEW_AR_AGING.payer_id  IN (SELECT AR_PAYERS.PAYER_ID 
      FROM AR_PAYERS LEFT JOIN AR_LIB_PAYERS libpayer 
      ON AR_PAYERS.payer_id = libpayer.payer_id 
      AND (libpayer.deleted = 'N')  
      WHERE (((libpayer.payer_type IS NULL  OR libpayer.payer_type  <>  'Medicare D' ))) 
      AND ((AR_PAYERS.FAC_ID =  VIEW_AR_AGING.FAC_ID  OR AR_PAYERS.FAC_ID = -1)))
      ))) AND ((VIEW_AR_AGING.FAC_ID =@fac_id  OR VIEW_AR_AGING.FAC_ID = -1)) --and client_id_number = '90064'
GROUP BY mpi.last_name, mpi.first_name, client.client_id_number, VIEW_AR_AGING.client_id, VIEW_AR_AGING.payer_id, libpayer.payer_code, libpayer.payer_code2, libpayer.description , client.fac_id ,convert(datetime,convert(varchar,year(VIEW_AR_AGING.effective_date)) + '-' + convert(varchar,month(VIEW_AR_AGING.effective_date)) + '-01')
ORDER BY  mpi.last_name, mpi.first_name, client.client_id_number, VIEW_AR_AGING.client_id, libpayer.payer_code, libpayer.payer_code2, libpayer.description



--select client_id_number,payer_id,payer_code, payer_code2, amount  as balance_due, effective_Date ,@reference_date as transaction_date 
--from #temp
--where amount <> 0
--order by 1, 6




select  fac.facility_code,a.client_id_number,a.payer_id,
a.payer_code + isnull(a.payer_code2,'') as payer_code, a.amount  as balance_due, a.effective_Date ,
@reference_date as transaction_date 
from #temp  a
join facility fac
on fac.fac_id=a.fac_id
where amount <> 0
order by 1, 6

drop table #temp