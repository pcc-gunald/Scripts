SET XACT_ABORT ON;

DROP TABLE IF EXISTS #temp_emc_ext_facilities



SELECT DISTINCT
	[state_code]
	,reg_id=NULL
	,fac_id=copy_fac.dst_id
	,created_by='EICase589101067'
	,created_date=getDate()
	,revision_by='EICase589101067'
	,revision_date=getDate()
	,[deleted]
	,a.[deleted_by]
	,a.[deleted_date]
	,[name]
	,[phone]
	,[phone_ext]
	,[fax]
	,[email_address]
	,[primary_contact]
	,[comments]
	,[address1]
	,[address2]
	,[address3]
	,[city]
	,[county_id]
	,[prov_state]
	,country_id=ISNULL(EICase5891010671.dst_id, country_id)
	,[postal_zip_code]
	,facility_type=ISNULL(EICase5891010672.dst_id, facility_type)
	,[medsrc_type]
	,[inactive_flag]
	,[inactive_date]
	,[npi_number]
	,[send_direct_message]
	,[direct_message_email]
	,[oid]
	,[location_uuid]
	,[destination_oid]
	,[emr_link_flag]
	,copy_fac.dst_id
	,src_ext_fac_id=a.ext_fac_id 
INTO #temp_emc_ext_facilities
FROM [pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei548.[dbo].emc_ext_facilities a
JOIN pcc_staging_db58910.[dbo].EICase589101067facility copy_fac ON copy_fac.src_id = a.fac_id
	OR copy_fac.src_id = 1067
LEFT JOIN pcc_staging_db58910.[dbo].EICase589101067common_code EICase5891010671 ON EICase5891010671.src_id = a.country_id
LEFT JOIN pcc_staging_db58910.[dbo].EICase589101067common_code EICase5891010672 ON EICase5891010672.src_id = a.facility_type
inner join [pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei548.dbo.[ext_facilities] b on b.ext_fac_id=a.ext_fac_id
WHERE (a.fac_id =-1 and b.fac_id=1067 )
AND b.hotlist_item='Y'
AND NOT EXISTS(SELECT  1 FROM [test_usei1072].dbo.emc_ext_facilities d WHERE d.name=a.name)


ALTER TABLE #temp_emc_ext_facilities
ADD  ext_fac_id INT 

DECLARE @cnt INT
SELECT @cnt=ISNULL(max(ext_fac_id),0)+1 FROM [dbo].emc_ext_facilities

; with temp as (
SELECT * 
,Rn=@cnt+ROW_NUMBER() OVER(ORDER BY src_ext_fac_id )
FROM #temp_emc_ext_facilities
)
UPDATE TEMP 
SET ext_fac_id=Rn



BEGIN TRAN

DROP TABLE IF EXISTS #temp_values
CREATE TABLE #temp_values(ext_fac_id INT
						,src_ext_fac_id INT
						,fac_id INT
						)


MERGE emc_ext_facilities a
USING (
SELECT ext_fac_id
	,state_code
	,reg_id
	,fac_id
	,created_by
	,created_date
	,revision_by
	,revision_date
	,deleted
	,deleted_by
	,deleted_date
	,name
	,phone
	,phone_ext
	,fax
	,email_address
	,primary_contact
	,comments
	,address1
	,address2
	,address3
	,city
	,county_id
	,prov_state
	,country_id
	,postal_zip_code
	,facility_type
	,medsrc_type
	,inactive_flag
	,inactive_date
	,npi_number
	,send_direct_message
	,direct_message_email
	,oid
	,location_uuid
	,destination_oid
	,emr_link_flag
	,src_ext_fac_id
	FROM #temp_emc_ext_facilities
) src ON  1=0
WHEN NOT MATCHED THEN
INSERT  (
	ext_fac_id
	,state_code
	,reg_id
	,fac_id
	,created_by
	,created_date
	,revision_by
	,revision_date
	,deleted
	,deleted_by
	,deleted_date
	,name
	,phone
	,phone_ext
	,fax
	,email_address
	,primary_contact
	,comments
	,address1
	,address2
	,address3
	,city
	,county_id
	,prov_state
	,country_id
	,postal_zip_code
	,facility_type
	,medsrc_type
	,inactive_flag
	,inactive_date
	,npi_number
	,send_direct_message
	,direct_message_email
	,oid
	,location_uuid
	,destination_oid
	,emr_link_flag
	)
	VALUES (ext_fac_id
	,state_code
	,reg_id
	,fac_id
	,created_by
	,created_date
	,revision_by
	,revision_date
	,deleted
	,deleted_by
	,deleted_date
	,name
	,phone
	,phone_ext
	,fax
	,email_address
	,primary_contact
	,comments
	,address1
	,address2
	,address3
	,city
	,county_id
	,prov_state
	,country_id
	,postal_zip_code
	,facility_type
	,medsrc_type
	,inactive_flag
	,inactive_date
	,npi_number
	,send_direct_message
	,direct_message_email
	,oid
	,location_uuid
	,destination_oid
	,emr_link_flag
	)
OUTPUT inserted.ext_fac_id,src.src_ext_fac_id,src.fac_id INTO #temp_values(ext_fac_id,src_ext_fac_id,fac_id)
;


INSERT INTO ext_facilities
( ext_fac_id
	,fac_id
	,created_by
	,created_date
	,revision_by
	,revision_date
	,deleted_by
	,deleted_date
	,default_pharmacy
	,exclude_from_census
	,exclude_from_phys_order
	,hotlist_item
	,allow_schedule_id
	,emergency_pharmacy
	,default_lab)
SELECT DISTINCT a.ext_fac_id
	,a.fac_id
	,created_by='EICase589101067'
	,created_date=GETDATE()
	,revision_by='EICase589101067'
	,revision_date=GETDATE()
	,deleted_by=IIF(deleted_date IS NULL,NULL,'EICase589101067')
	,deleted_date
	,default_pharmacy
	,exclude_from_census
	,exclude_from_phys_order
	,hotlist_item
	,allow_schedule_id
	,emergency_pharmacy
	,default_lab F
	FROM #temp_values A
INNER JOIN  [pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei548.[dbo].[ext_facilities] B ON B.ext_fac_id=A.src_ext_fac_id


--select @@TRANCOUNT
COMMIT;
--ROLLBACK;

