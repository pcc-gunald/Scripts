USE __DSTPROD__
GO

/*

1 Open
2 Exported
3 Accepted
4 Submission in progress
5 Results Pending 
6 Review Required

*/

--NOTE: Before changing batch to Accepted status, verify with the implementer if they have reviewed validation report. Use the email as confirmation to make the below updates.

SELECT * FROM facility WHERE fac_id IN (34)

SELECT * FROM as_batch WHERE fac_id IN (34)
and status_id<>3

/*





*/

SELECT * FROM as_batch 
WHERE batch_no IN (987)
	AND batch_id IN (160209)
	AND fac_id IN (34)

/*





*/

SELECT *
INTO pcc_temp_storage.dbo._bkp___ELCC___PMO___59132_P2___as_batch_assess
FROM as_batch_assess

SELECT *
INTO pcc_temp_storage.dbo._bkp___ELCC___PMO___59132_P2___as_assessment
FROM as_assessment

SELECT *
INTO pcc_temp_storage.dbo._bkp___ELCC___PMO___59132_P2___as_batch
FROM as_batch


/*





*/

SELECT DISTINCT assess_id,batch_assess_status
FROM as_batch_assess
WHERE batch_id IN (160209) --

--if above query has assess_id with batch_assess_status as <> A then update below - THEY SHOULD ALREADY BE IN ACCEPTED STATUS IDEALLY

update as_batch_assess
set batch_assess_status = 'A'
--select * from as_batch_assess
where  batch_id in (160209) --
and batch_assess_status is null --

--Check if the assessments returned below have a locked date and the status is Accepted (Confirm on front end too) - THEY SHOULD ALREADY BE IN ACCEPTED STATUS IDEALLY

SELECT STATUS,*
FROM as_assessment
WHERE assess_id IN (SELECT DISTINCT assess_id FROM as_batch_assess WHERE batch_id IN (160209)) --5

--if above query has assess_id status <> Accepted then update below - THEY SHOULD ALREADY BE IN ACCEPTED STATUS IDEALLY

update as_assessment
set status = 'Accepted'
--select * from as_assessment
where batch_id in (160209) --
and status = 'Modified' --


--Main update that cannot be performed on front end to set the batch as Accepted.
UPDATE as_batch
SET status_id = 3
--select * from as_batch
WHERE  batch_no IN (987)
	AND batch_id IN (160209)
	AND fac_id IN (34)
	AND status_id = 6 --


/*





*/