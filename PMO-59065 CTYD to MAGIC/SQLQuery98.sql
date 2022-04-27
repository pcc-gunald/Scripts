DECLARE @BATCH_SIZE INT =10000
DECLARE @NO_OF_REC INT 
DECLARE @NO_REC_PROCESSED INT =172149945
DECLARE @msg VARCHAR(500)
SELECT @NO_OF_REC= MAX(pho_schedule_detail_id)
FROM  pcc_staging_db59065.dbo.pho_schedule_details(nolock)
WHERE pho_schedule_detail_id>172069944




WHILE (@NO_REC_PROCESSED<=@NO_OF_REC)
BEGIN
SET IDENTITY_INSERT test_usei432.dbo.pho_schedule_details ON

INSERT INTO test_usei432.dbo.pho_schedule_details (
	pho_schedule_detail_id
	,pho_schedule_id
	,created_by
	,created_date
	,revision_by
	,revision_date
	,deleted
	,deleted_by
	,deleted_date
	,perform_by
	,perform_date
	,chart_code
	,strike_out_id
	,followup_result
	,schedule_date
	,dose
	,modified_quantity
	,perform_initials
	,followup_by
	,followup_date
	,followup_initials
	,followup_pn_id
	,schedule_date_end
	,detail_supply_id
	,effective_date
	,followup_effective_date
	)
SELECT pho_schedule_detail_id
	,pho_schedule_id
	,created_by
	,created_date
	,revision_by
	,revision_date
	,deleted
	,deleted_by
	,deleted_date
	,perform_by
	,perform_date
	,chart_code
	,strike_out_id
	,followup_result
	,schedule_date
	,dose
	,modified_quantity
	,perform_initials
	,followup_by
	,followup_date
	,followup_initials
	,followup_pn_id
	,schedule_date_end
	,detail_supply_id
	,effective_date
	,followup_effective_date
FROM pcc_staging_db59065.dbo.pho_schedule_details
WHERE pho_schedule_detail_id >=@NO_REC_PROCESSED
AND pho_schedule_detail_id <@NO_REC_PROCESSED+@BATCH_SIZE
	AND Multi_Fac_Id = 39

SET IDENTITY_INSERT test_usei432.dbo.pho_schedule_details OFF


SET @msg = CONCAT(@NO_REC_PROCESSED+@@ROWCOUNT,' records processed out of ',@NO_OF_REC)
RAISERROR (@msg, 0, 1) WITH NOWAIT

SET @NO_REC_PROCESSED+=@BATCH_SIZE
PRINT(@NO_REC_PROCESSED)
END 
