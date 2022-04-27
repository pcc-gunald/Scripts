USE [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi
GO

/*

1 Open
2 Exported
3 Accepted
4 Submission in progress
5 Results Pending 
6 Review Required

*/

SELECT * FROM facility WHERE fac_id IN ()

/*





*/

SELECT * FROM as_batch 
WHERE batch_no IN ()
	AND batch_id IN ()
	AND fac_id IN ()

/*





*/

SELECT *
INTO pcc_temp_storage.dbo._bkp_PGHC_PMO_59277_as_batch_assess
FROM as_batch_assess

SELECT *
INTO pcc_temp_storage.dbo._bkp_PGHC_PMO_59277_as_assessment
FROM as_assessment

SELECT *
INTO pcc_temp_storage.dbo._bkp_PGHC_PMO_59277_as_batch
FROM as_batch


/*





*/

SELECT DISTINCT assess_id,batch_assess_status
FROM as_batch_assess
WHERE batch_id IN () --

--if above query has assess_id with batch_assess_status as <> A then update below

update as_batch_assess
set batch_assess_status = 'A'
--select * from as_batch_assess
where  batch_id in () --
and batch_assess_status is null --

--Check if the assessments returned below have a locked date and the status is Accepted (Confirm on front end too)

SELECT STATUS,*
FROM as_assessment
WHERE assess_id IN (SELECT DISTINCT assess_id FROM as_batch_assess WHERE batch_id IN ()) --5

--if above query has assess_id status <> Accepted then update below

update as_assessment
set status = 'Accepted'
--select * from as_assessment
where batch_id in () --
and status = 'Exported' --

UPDATE as_batch
SET status_id = 3
--select * from as_batch
WHERE batch_no IN ()
	AND batch_id IN ()
	AND fac_id IN ()
	AND status_id = 4 --


/*





*/