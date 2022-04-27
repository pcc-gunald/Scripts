USE [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi
GO

/*

1 Open
2 Exported
3 Accepted
4 Submission In Progress

*/

SELECT *
INTO pcc_temp_storage.dbo._bkp_PGHC_as_batch_post_PMO_59277
FROM as_batch --

SELECT *
FROM facility
WHERE NAME LIKE '%????%'


/*





*/

SELECT batch_no,status_id,*
FROM as_batch
WHERE batch_no IN ('')
	AND fac_id IN ()
	AND status_id = 2 --

/*





*/

SELECT batch_no,status_id,*
FROM as_batch
WHERE fac_id IN ()
	AND status_id = 2 --
	AND batch_id IN ()

UPDATE as_batch
SET status_id = 1
--select batch_no,status_id, *  from as_batch
WHERE fac_id IN () ---destination fac_id
	AND batch_id IN () ----batch_id from query
	AND batch_no IN ('') ---batch_no from SME, for extra criteria
	AND status_id = 2 --