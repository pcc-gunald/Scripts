select * from test_usei548.dbo.ext_facilities
where fac_id=1067


select * from test_usei548.dbo.emc_ext_facilities a
where fac_id=1067

select distinct b.* from test_usei548.dbo.ext_facilities a
left join test_usei548.dbo.emc_ext_facilities b on (b.fac_id=a.fac_id or b.fac_id=-1)
where a.fac_id=1067
order by b.name

select * from  test_usei548.dbo.emc_ext_facilities
where name in( 'Florida Hospital Altamonte','Florida Hospital East Orlando')

select * from  test_usei548.dbo.emc_ext_facilities
where ext_fac_id in(
select src_id from  pcc_staging_db58910.[dbo].EICase589101067emc_ext_facilities
)


select * from mergelog
where msg like '%INSERT INTO%EICase589101067emc_ext_facilities%'--'%ext_facilities%'
and msg like '% INSERT INTO %'



select * from mergelog
where rno between 1910 and 1925
order by 1


select * from mergelog
where rno between 1865 and 1900
order by 1
 
  INSERT INTO pcc_staging_db58910.[dbo].ext_facilities (
	ext_fac_id
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
	,default_lab
	,MULTI_FAC_ID
	)
SELECT DISTINCT ISNULL(EICase5891010671.dst_id, ext_fac_id)
	,copy_fac.dst_id
	,'EICase589101067'
	,getDate()
	,'EICase589101067'
	,getDate()
	,[deleted_by]
	,[deleted_date]
	,[default_pharmacy]
	,[exclude_from_census]
	,[exclude_from_phys_order]
	,[hotlist_item]
	,[allow_schedule_id]
	,[emergency_pharmacy]
	,[default_lab]
	,59
	,fac_id
FROM test_usei548.[dbo].ext_facilities a
JOIN pcc_staging_db58910.[dbo].EICase589101067facility copy_fac ON copy_fac.src_id = a.fac_id
	OR copy_fac.src_id = 1067
JOIN pcc_staging_db58910.[dbo].EICase589101067emc_ext_facilities EICase5891010671 ON EICase5891010671.src_id = a.ext_fac_id
WHERE fac_id IN (
		1067
		,- 1
		)
	AND NOT EXISTS (
		SELECT 1
		FROM [pccsql-use2-prod-ssv-tscon11.b4ea653240a9.database.windows.net].test_usei1072.[dbo].ext_facilities origt
		WHERE origt.fac_id = copy_fac.dst_id
			AND origt.ext_fac_id = EICase5891010671.dst_id
		)
	AND NOT EXISTS (
		SELECT 1
		FROM pcc_staging_db58910.[dbo].ext_facilities origt1
		WHERE origt1.fac_id = copy_fac.dst_id
			AND origt1.ext_fac_id = EICase5891010671.dst_id
		)

select *  from pcc_staging_db58910.[dbo].EICase589101067emc_ext_facilities

select * from pcc_staging_db58910.[dbo].EICase589101067facility 

SELECT DISTINCT EICase5891010671.dst_id
	,copy_fac.dst_id
	,fac_id
FROM test_usei548.[dbo].ext_facilities a
JOIN pcc_staging_db58910.[dbo].EICase589101067facility copy_fac ON copy_fac.src_id = a.fac_id
	OR copy_fac.src_id = 1067
JOIN pcc_staging_db58910.[dbo].EICase589101067emc_ext_facilities EICase5891010671 ON EICase5891010671.src_id = a.ext_fac_id

select *  from test_usei548.[dbo].ext_facilities a
inner join  pcc_staging_db58910.[dbo].EICase589101067emc_ext_facilities EICase5891010671 ON EICase5891010671.src_id = a.ext_fac_id


 INSERT INTO pcc_staging_db58910.[dbo].emc_ext_facilities (
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
	,MULTI_FAC_ID
	)
SELECT DISTINCT b.dst_id
	,[state_code]
	,NULL
	,copy_fac.dst_id
	,'EICase589101067'
	,getDate()
	,'EICase589101067'
	,getDate()
	,[deleted]
	,[deleted_by]
	,[deleted_date]
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
	,ISNULL(EICase5891010671.dst_id, country_id)
	,[postal_zip_code]
	,ISNULL(EICase5891010672.dst_id, facility_type)
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
	,59
FROM test_usei548.[dbo].emc_ext_facilities a
JOIN pcc_staging_db58910.[dbo].EICase589101067facility copy_fac ON copy_fac.src_id = a.fac_id
	OR copy_fac.src_id = 1067
LEFT JOIN pcc_staging_db58910.[dbo].EICase589101067common_code EICase5891010671 ON EICase5891010671.src_id = a.country_id
LEFT JOIN pcc_staging_db58910.[dbo].EICase589101067common_code EICase5891010672 ON EICase5891010672.src_id = a.facility_type
	,pcc_staging_db58910.[dbo].EICase589101067emc_ext_facilities b
WHERE a.ext_fac_id <> - 1
	AND (
		a.fac_id IN (
			1067
			,- 1
			)
		OR a.reg_id = 2
		)
	AND a.ext_fac_id = b.src_id
	AND b.corporate = 'N'


select a.*
	FROM test_usei548.[dbo].emc_ext_facilities a
JOIN pcc_staging_db58910.[dbo].EICase589101067facility copy_fac ON copy_fac.src_id = a.fac_id
	OR copy_fac.src_id = 1067
--LEFT JOIN pcc_staging_db58910.[dbo].EICase589101067common_code EICase5891010671 ON EICase5891010671.src_id = a.country_id
--LEFT JOIN pcc_staging_db58910.[dbo].EICase589101067common_code EICase5891010672 ON EICase5891010672.src_id = a.facility_type
	,pcc_staging_db58910.[dbo].EICase589101067emc_ext_facilities b
WHERE a.ext_fac_id <> - 1
	AND (
		a.fac_id IN (
			1067
			,- 1
			)
		OR a.reg_id = 2
		)
	AND a.ext_fac_id = b.src_id
	AND b.corporate = 'N'

select * from EICase589101067emc_ext_facilities