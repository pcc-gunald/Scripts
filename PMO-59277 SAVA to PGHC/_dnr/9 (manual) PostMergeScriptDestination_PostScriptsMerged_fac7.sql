USE test_usei1214
--GO

--=======================================================================================================
-- Please run the following post insert for each facility before the table is added to the process
-- If there is any PK complaint on this insert please escalate
-- Front-end MDS > Report link beside MDS > Audit Report
--=======================================================================================================

insert into as_assessment_lineage
select map1.dst_id
,map2.dst_id
,created_date
,instance_reason
--select * 
from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.as_assessment_lineage src with (nolock)
join EICaseR_CASENUMBER7as_assessment map1 on map1.src_id = src.assess_id ------mapping table
join EICaseR_CASENUMBER7as_assessment map2 on map2.src_id = src.first_assess_id  ------mapping table
where not exists (select 1 from as_assessment_lineage with (nolock) where assess_id = map1.dst_id or first_assess_id = map2.dst_id)

--==========================================================================

--Hi All,

--Please make sure to include both of the following as part of post script in your destination DB for both Data Copy to New and Data Copy to Existing before we can add them to the process. I will let you know once they are added.


DELETE FROM dbo.facility_scheduling_cycle

INSERT INTO dbo.facility_scheduling_cycle(fac_id, run_day)
SELECT fac_id, (CASE WHEN fac_id % 20 <> 0 THEN fac_id % 20 ELSE 20 END) + 6 AS runDay 
FROM dbo.facility WHERE ((FACILITY.fac_id  <> 9999 AND (FACILITY.inactive IS NULL  OR FACILITY.inactive  <> 'Y') AND (FACILITY.is_live  <> 'N' OR FACILITY.is_live IS NULL ))) 
AND ((FACILITY.DELETED = 'N'))



--Thanks,
--Nigel

print  CHAR(13) + 'Started running : Standard post scripts'  

--==========================================================================

print  CHAR(13) + 'SEC_USER - Check after copy running now'  

update dst
set enabled = 'N'
--select dst.userid, dst.fac_id, dst.loginname, src.userid, src.fac_id,src.loginname, src.admin_user_type
from sec_user dst
join EICaseR_CASENUMBER7sec_user m 
on dst.userid = m.dst_id
join [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].sec_user src 
on src.userid = m.src_id
where (src.admin_user_type <> 'E' or src.admin_user_type is NULL) 
and not exists (select 1 from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].sec_user_facility f 
where src.userid = f.userid and f.facility_id = R_SRCFACID7)
and src.enabled = 'Y'

--==========================================================================

print  CHAR(13) + 'COMMON_CODE_STANDARD_CONTACT_TYPE_MAPPING running now'  

INSERT INTO [dbo].[common_code_standard_contact_type_mapping]
SELECT m.dst_id, s.standard_contact_type_item_id 
FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].[common_code_standard_contact_type_mapping] s 
JOIN [dbo].EICaseR_CASENUMBER7common_code m ON s.common_code_item_id = m.src_id
JOIN [dbo].common_code d ON m.dst_id = d.item_id
WHERE m.dst_id NOT IN (SELECT common_code_item_id FROM [dbo].[common_code_standard_contact_type_mapping]) AND d.fac_id = R_DSTFACID7 

--==========================================================================

--print  CHAR(13) + 'Step04_Post_EI_1_Update_Payers running now'  

--Update dst
--set dst.primary_payer_id = pm.Map_dstPayerID
----select src.primary_payer_id,dst.primary_payer_id, pm.Map_dstPayerID,*
----select count(1)
--from census_item dst
--inner join dbo.EICaseR_CASENUMBER7census_item map--
--on dst.census_id = map.dst_id  
--inner join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.census_item src--
--on map.src_id = src.census_id
--inner join [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-59277_PayerMapping$'] pm--
--on src.primary_payer_id = pm.srcPayerID --
--where dst.fac_id in (R_DSTFACID7)--
--and dst.primary_payer_id = -1
--and map_dstpayerid is not null 

--select distinct alp.payer_id, alp.description
----select *
----select count(1)
--from census_item dst
--inner join dbo.EICaseR_CASENUMBER7census_item map--
--on dst.census_id = map.dst_id  
--join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.census_item src--
--on map.src_id = src.census_id
--join [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-59277_PayerMapping$'] pm --payer mapping template
--on src.primary_payer_id = pm.srcPayerID and dst.primary_payer_id = pm.Map_dstPayerID
--join ar_lib_payers alp on pm.Map_dstPayerID = alp.payer_id
--where dst.fac_id in (R_DSTFACID7)--dst fac_id
--and alp.payer_id not in (select payer_id from ar_payers where fac_id in (R_DSTFACID7))--dst fac_id
--and map_dstpayerid is not null 

--print  CHAR(13) + 'payers mapping - the above should be 0 if not then email admin implementor to activate the payers'  

--==========================================================================

--print  CHAR(13) + 'Update Room Rate Type and Census Room Rate running now'  

--UPDATE dst
--SET dst.actual_accomm_id = pm.Map_dstRateTypeID
----select src.actual_accomm_id,dst.actual_accomm_id, pm.Map_dstRateTypeID,*
----select count(1)
--FROM census_item dst
--inner join dbo.EICaseR_CASENUMBER7census_item map--
--on dst.census_id = map.dst_id  
--inner join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.census_item src--
--on map.src_id = src.census_id
--inner join [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-59277_RoomRateTypes$'] pm
--on src.actual_accomm_id = pm.srcRateTypeID --
--WHERE dst.fac_id IN (R_DSTFACID7) --dst
--		and  dst.primary_payer_id=4 --identify  payer_id  for  Medicare A based on the payer mapping table !!!CHANGE THIS FROM MAPPING FILE BY SME
--and dst.actual_accomm_id is null
--and dst.record_type='R' -- for Census rate lines only
--and  dst.effective_Date >='2010-10-01' --only  update  for census rate  lines with effective date of  oct 1, 2010 and above
--and Map_dstRateTypeID is not null

--UPDATE dst
--SET dst.rate_type_id = pm.Map_dstRateTypeID
----select src.rate_type_id,dst.rate_type_id, pm.Map_dstRateTypeID,*
----select count(1)
--FROM room_date_range dst
--inner join [dbo].[EICaseR_CASENUMBER7room_date_range] map--
--on dst.date_range_id = map.dst_id  
--inner join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.room_date_range src--
--on map.src_id = src.date_range_id
-- inner join [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-59277_RoomRateTypes$'] pm
--on src.rate_type_id = pm.srcRateTypeID --
--WHERE dst.room_id in  (select  room_id from room where fac_id = R_DSTFACID7)
--and pm.Map_dstRateTypeID is not null
--and Map_dstRateTypeID is not null

--==========================================================================

print  CHAR(13) + 'Step010_Staff_id_update_sec_user running now'  

update dst
set dst.staff_id = cmap.dst_id
--select dst.staff_id, cmap.dst_id, dst.* 
from test_usei1214.dbo.sec_user dst
join test_usei1214.dbo.EICaseR_CASENUMBER7sec_user umap on dst.userid = umap.dst_id
join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.sec_user src on umap.src_id = src.userid
join test_usei1214.dbo.EICaseR_CASENUMBER7contact cmap on src.staff_id = cmap.src_id

--==========================================================================

print  CHAR(13) + 'step013_update_pns_subscription running now'  

DECLARE @count INT

select @count = count(*) 
from pns_subscription 
where user_id not in (select dst_id from EICaseR_CASENUMBER7sec_user) 
and created_by like '%EICaseR_CASENUMBER7%'
	
-----to update the sec user

if @count > 0
update dst
set dst.user_id = map.dst_id
--select *
from pns_subscription dst
join EICaseR_CASENUMBER7sec_user map on dst.user_id = map.src_id

---to update the org ID
update pns_subscription
set org_id = 504954271  ---new org ID
--select * from pns_subscription
where org_id = 494950444  --old org ID
and created_by like 'EICaseR_CASENUMBER7%' 

--==========================================================================

print  CHAR(13) + '20 - update_email_address running now'  

IF OBJECT_ID('pcc_temp_storage.dbo._bkp_sec_user_snapshot_CaseR_CASENUMBER7', 'U') IS NOT NULL 
	DROP TABLE pcc_temp_storage.dbo._bkp_sec_user_snapshot_CaseR_CASENUMBER7
SELECT * into pcc_temp_storage.dbo._bkp_sec_user_snapshot_CaseR_CASENUMBER7 from sec_user

update sec_user
set email = '', alt_email = ''
where ((email is not null and email <> '') or (alt_email is not null and alt_email <> ''))
and userid in (select dst_id from EICaseR_CASENUMBER7sec_user where corporate = 'N')

--==========================================================================

print  CHAR(13) + 'Post_EI_Update_mpi_history running now' 

SELECT distinct s.user_id into #temp1
FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].mpi_history s 
left join [dbo].EICaseR_CASENUMBER7mpi_history m
on s.mpi_history_id = m.src_id
left join [dbo].mpi_history d
on d.mpi_history_id = m.dst_id and d.fac_id = R_DSTFACID7
where d.mpi_history_id is null 
and s.fac_id = R_SRCFACID7

select userid into #temp2
--SELECT admin_user_type,* 
FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].sec_user
where userid in (select distinct user_id from #temp1)
and (admin_user_type = 'E'
or userid in (select userid from [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].sec_user_facility a join #temp1 b on a.userid = b.user_id 
where a.facility_id = R_SRCFACID7))

/*

SELECT * FROM [dbo].mergelog
where msg like '%mpi_history (%' 

----------------adding the below condition after LEFT join--------------------------------

	AND (a.user_id IN (SELECT userid FROM #temp2) OR a.user_id = - 999)
	AND b.dst_id NOT IN (SELECT mpi_history_id FROM mpi_history)

------------------------------------------------------------------------------------------

*/

--below is onetime dyamically created query for MPI as of 02012019 instead of manual work

INSERT INTO test_usei1214.[dbo].mpi_history 
	(mpi_history_id,mpi_id,fac_id,user_id,created_by,created_date,revision_by,revision_date,title,first_name,last_name,middle_name,maiden_name,date_of_birth,place_of_birth,marital_status_id,
	sex,address1,address2,address3,city,county_id,prov_state,postal_zip_code,country_id,deceased_date,religion_id,race_id,primary_lang_id,secondary_lang_id,citizenship_id,allergy,height,
	ibw_range,veteran_number,public_trustee_number,education_id,occupations,phone_home,phone_cell,phone_office,phone_office_ext,fax,phone_pager,phone_other,email_address,web_address,
	modified_by,date_modified,reason_for_modification,ssn_sin,suffix,medicare,ethnicity_id,mbi,api_app_name,api_user_name)

SELECT 
	DISTINCT b.dst_id,ISNULL(EICaseR_CASENUMBER71.dst_id, mpi_id),copy_fac.dst_id,ISNULL(EICaseR_CASENUMBER710.dst_id, user_id),[created_by],[created_date],[revision_by],[revision_date]
	,[title],[first_name],[last_name],[middle_name],[maiden_name],[date_of_birth],[place_of_birth],ISNULL(EICaseR_CASENUMBER74.dst_id, marital_status_id),[sex],[address1],[address2]
	,[address3],[city]	,[county_id],[prov_state],[postal_zip_code],ISNULL(EICaseR_CASENUMBER79.dst_id, country_id),[deceased_date],ISNULL(EICaseR_CASENUMBER75.dst_id, religion_id)
	,ISNULL(EICaseR_CASENUMBER76.dst_id, race_id),ISNULL(EICaseR_CASENUMBER72.dst_id, primary_lang_id),ISNULL(EICaseR_CASENUMBER73.dst_id, secondary_lang_id)
	,ISNULL(EICaseR_CASENUMBER78.dst_id, citizenship_id),[allergy],[height],[ibw_range]	,[veteran_number],[public_trustee_number],ISNULL(EICaseR_CASENUMBER77.dst_id, education_id),[occupations]
	,[phone_home],[phone_cell],[phone_office],[phone_office_ext],[fax],[phone_pager],[phone_other],[email_address],[web_address],[modified_by],[date_modified],[reason_for_modification]
	,[ssn_sin],[suffix],[medicare],[ethnicity_id]	,[mbi],[api_app_name],[api_user_name]

FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].mpi_history a
JOIN test_usei1214.[dbo].EICaseR_CASENUMBER7facility copy_fac ON copy_fac.src_id = a.fac_id OR copy_fac.src_id = R_SRCFACID7
JOIN test_usei1214.[dbo].EICaseR_CASENUMBER7mpi EICaseR_CASENUMBER71 ON EICaseR_CASENUMBER71.src_id = a.mpi_id
LEFT JOIN test_usei1214.[dbo].EICaseR_CASENUMBER7common_code EICaseR_CASENUMBER72 ON EICaseR_CASENUMBER72.src_id = a.primary_lang_id
LEFT JOIN test_usei1214.[dbo].EICaseR_CASENUMBER7common_code EICaseR_CASENUMBER73 ON EICaseR_CASENUMBER73.src_id = a.secondary_lang_id
LEFT JOIN test_usei1214.[dbo].EICaseR_CASENUMBER7common_code EICaseR_CASENUMBER74 ON EICaseR_CASENUMBER74.src_id = a.marital_status_id
LEFT JOIN test_usei1214.[dbo].EICaseR_CASENUMBER7common_code EICaseR_CASENUMBER75 ON EICaseR_CASENUMBER75.src_id = a.religion_id
LEFT JOIN test_usei1214.[dbo].EICaseR_CASENUMBER7common_code EICaseR_CASENUMBER76 ON EICaseR_CASENUMBER76.src_id = a.race_id
LEFT JOIN test_usei1214.[dbo].EICaseR_CASENUMBER7common_code EICaseR_CASENUMBER77 ON EICaseR_CASENUMBER77.src_id = a.education_id
LEFT JOIN test_usei1214.[dbo].EICaseR_CASENUMBER7common_code EICaseR_CASENUMBER78 ON EICaseR_CASENUMBER78.src_id = a.citizenship_id
LEFT JOIN test_usei1214.[dbo].EICaseR_CASENUMBER7common_code EICaseR_CASENUMBER79 ON EICaseR_CASENUMBER79.src_id = a.country_id
LEFT JOIN test_usei1214.[dbo].EICaseR_CASENUMBER7sec_user EICaseR_CASENUMBER710 ON EICaseR_CASENUMBER710.src_id = a.user_id ,test_usei1214.[dbo].EICaseR_CASENUMBER7mpi_history b
WHERE a.mpi_history_id <> - 1
	AND a.fac_id IN (R_SRCFACID7,- 1)
	AND a.mpi_history_id = b.src_id
	AND b.corporate = 'N'
	AND (a.user_id IN (SELECT userid FROM #temp2) OR a.user_id = - 999)
	AND b.dst_id NOT IN (SELECT mpi_history_id FROM mpi_history)

--==========================================================================

print  CHAR(13) + 'If Diagnosis - Diagnosis Codes Mapping (new)(if diagnosis approved) running now' 

if OBJECT_ID ('pcc_temp_storage.dbo._bkp_diagnosis_PGHC_post_EICaseR_CASENUMBER7diagnosis_codes_post','U') is not null
	drop table pcc_temp_storage.dbo._bkp_diagnosis_PGHC_post_EICaseR_CASENUMBER7diagnosis_codes_post

if OBJECT_ID ('dbo.EICaseR_CASENUMBER7diagnosis_codes_post','U') is not null
	drop table dbo.EICaseR_CASENUMBER7diagnosis_codes_post

--1. Generate post mapping table, populating affected src diagnosis_id
select distinct map.* 
into EICaseR_CASENUMBER7diagnosis_codes_post --update Case #
--select distinct map.*
--select src.*
from EICaseR_CASENUMBER7diagnosis_codes map
join diagnosis_codes dst 
on map.dst_id = dst.diagnosis_id
join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.diagnosis_codes src --src DB
on map.src_id = src.diagnosis_id
where (src.diag_lib_id <> dst.diag_lib_id 
	or (src.diag_lib_id = dst.diag_lib_id and src.specificity <> dst.specificity)
	or (src.diag_lib_id = dst.diag_lib_id and 
		((src.ineffective_date is null and dst.ineffective_date is not null)
		or (src.ineffective_date is not null and dst.ineffective_date is null))
		))
and map.corporate = 'Y'

update EICaseR_CASENUMBER7diagnosis_codes_post set corporate = 'N'

--2. Generate mapping for rows affected
update map2
set map2.dst_id = dst.diagnosis_id, corporate = 'Y'
--select src.icd9_long_desc, src.icd9_short_desc, src.icd9_code, src.diag_lib_id, dst.icd9_long_desc, dst.icd9_short_desc, dst.icd9_code, dst.diag_lib_id, src.diagnosis_id, dst.diagnosis_id, dst.diagnosis_id, src.specificity, dst.specificity,src.ineffective_date,dst.ineffective_date
from diagnosis_codes dst
join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.diagnosis_codes src on dst.icd9_code = src.icd9_code --src DB
and dst.icd9_long_desc = src.icd9_long_desc
and dst.icd9_short_desc = src.icd9_short_desc
and src.diag_lib_id = dst.diag_lib_id
and src.specificity = dst.specificity
and ((src.ineffective_date is null and dst.ineffective_date is null)
	or (src.ineffective_date is not null and dst.ineffective_date is not null))
join EICaseR_CASENUMBER7diagnosis_codes_post map2 on map2.src_id = src.diagnosis_id
where src.diagnosis_id in (select distinct src_id from EICaseR_CASENUMBER7diagnosis_codes_post) 

---exclude those --treat separately (update records that are not struck out first, then the ones struck out)
select dst.client_id,map2.dst_id
from diagnosis dst
join EICaseR_CASENUMBER7diagnosis mapd on dst.client_diagnosis_id = mapd.dst_id
join EICaseR_CASENUMBER7diagnosis_codes map on map.dst_id = dst.diagnosis_id
join EICaseR_CASENUMBER7diagnosis_codes_post map2 on map2.src_id = map.src_id
join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.diagnosis srcd --src DB
on srcd.client_diagnosis_id = mapd.src_id and map2.src_id = srcd.diagnosis_id
where dst.fac_id in (R_DSTFACID7)
group by dst.client_id,map2.dst_id
having count (*) > 1 

ALTER TABLE diagnosis disable TRIGGER tp_clinical_diagnosis_upd
GO

update dst
set dst.diagnosis_id = map2.dst_id
--select dst.client_diagnosis_id, dst.diagnosis_id, srcd.diagnosis_id, map2.src_id, map2.dst_id, *
--select dst.diagnosis_id, map2.dst_id, map2.src_id, *
--select dst.client_diagnosis_id,dst.client_id,dst.diagnosis_id,dst.fac_id
--select *
from diagnosis dst
join EICaseR_CASENUMBER7diagnosis mapd on dst.client_diagnosis_id = mapd.dst_id
join EICaseR_CASENUMBER7diagnosis_codes map on map.dst_id = dst.diagnosis_id
join EICaseR_CASENUMBER7diagnosis_codes_post map2 on map2.src_id = map.src_id  
join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.diagnosis srcd --src DB
on srcd.client_diagnosis_id = mapd.src_id and map2.src_id = srcd.diagnosis_id
where dst.fac_id in (R_DSTFACID7) 
and dst.struck_out <> 1 --
and map2.corporate = 'Y'
--order by dst.client_id
--rollback tran

update dst
set dst.diagnosis_id = map2.dst_id
--select dst.client_diagnosis_id, dst.diagnosis_id, srcd.diagnosis_id, map2.src_id, map2.dst_id, *
--select dst.diagnosis_id, map2.dst_id, map2.src_id, *
--select dst.client_diagnosis_id,dst.client_id,dst.diagnosis_id,dst.fac_id
--select *
from diagnosis dst
join EICaseR_CASENUMBER7diagnosis mapd on dst.client_diagnosis_id = mapd.dst_id
join EICaseR_CASENUMBER7diagnosis_codes map on map.dst_id = dst.diagnosis_id
join EICaseR_CASENUMBER7diagnosis_codes_post map2 on map2.src_id = map.src_id 
join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.diagnosis srcd --src DB
on srcd.client_diagnosis_id = mapd.src_id and map2.src_id = srcd.diagnosis_id
where dst.fac_id in (R_DSTFACID7) 
and dst.struck_out = 1 --
and map2.corporate = 'Y'

ALTER TABLE diagnosis enable TRIGGER tp_clinical_diagnosis_upd
GO

print CHAR(13) + 'check below should be 0 '

--Check to make sure it's 0 rows
SELECT *
FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.diagnosis_codes_clinical_category
WHERE diagnosis_id IN
(
select src_id from EICaseR_CASENUMBER7diagnosis_codes 
	where src_id not in (select src_id from EICaseR_CASENUMBER7diagnosis_codes_post where corporate = 'Y')
	and dst_id NOT IN (SELECT diagnosis_id FROM dbo.diagnosis_codes_clinical_category)
union
select src_id from EICaseR_CASENUMBER7diagnosis_codes_post where corporate = 'Y'
	and dst_id NOT IN (SELECT diagnosis_id FROM dbo.diagnosis_codes_clinical_category)
	)

print CHAR(13) + 'check above should be 0 '

--==========================================================================

print  CHAR(13) + 'If Lab Results - result_lab_report post (if lab results approved) running now' 

print  CHAR(13) + ' Lab results post: update file location ' 

update result_lab_report
set file_id = null
from result_lab_report
where fac_id = R_DSTFACID7 
and file_id is not null 
and file_id in (select file_metadata_id from [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.file_metadata)
and file_id not in (select dst_id from EICaseR_CASENUMBER7file_metadata) 
and created_by = 'EICaseR_CASENUMBER7'

--==========================================================================

print  CHAR(13) + 'update location  (if using lab results) running now' 

print  CHAR(13) + ' Upload docs/ Lab&Rad: update location ' 

UPDATE file_metadata
SET location = REPLACE(REPLACE(location
                              ,'org_SAVA/' 
                              ,'org_PGHC/') 
                              ,'/facR_SRCFACID7/' 
                              ,'/facR_DSTFACID7/') 
WHERE fac_id = R_DSTFACID7 
    --AND (location LIKE '%/LAB_REPORT/%' OR location LIKE '%/RADIOLOGY_REPORT/%')
    AND file_metadata_id IN (SELECT dst_id FROM EICaseR_CASENUMBER7file_metadata) 

--==========================================================================

/*

Merged the below scripts as one standard post EI scripts

UpdateStruckOutOrders 
	(If orders is approved)
If Orders pho_admin_order_audit Post 
	(If orders is approved)
If Orders pho_related_order_audit Post 
	(If orders is approved)

*/

--==========================================================================

print  CHAR(13) + 'UpdateStruckOutOrders (If orders is approved) running now' 

print  CHAR(13) + 'UpdateStruckOutOrders (If orders is approved) running now' 

SELECT audit_id into #src_id 
--select *
FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_phys_order_audit--and in source --src db
WHERE audit_id IN (SELECT src_id FROM EICaseR_CASENUMBER7pho_phys_order_audit)--are copied --mapping table
AND phys_order_id NOT IN (SELECT phys_order_id FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_phys_order with (nolock) WHERE fac_id = R_SRCFACID7) --src fac_id

select * into #stru_tempb from pho_phys_order_audit with (nolock)
where fac_id = R_DSTFACID7 --(253548 row(s) affected) --dst fac_id
and client_id in (select dst_id from EICaseR_CASENUMBER7Clients with (nolock))----mapping table

SELECT dst_id into #stru_tempdstid FROM EICaseR_CASENUMBER7pho_phys_order_audit with (nolock)--copied over by E/I --mapping table
WHERE src_id IN (select audit_id from #src_id)--

--select audit_id,phys_order_id into #stru_temps
select audit_id,phys_order_id into #stru_temps
--select * 
FROM #stru_tempb with (nolock)--in dst
WHERE audit_id IN (select dst_id from #stru_tempdstid)--

CREATE TABLE EICaseR_CASENUMBER7StruckOUT (row_id INT IDENTITY,src_id BIGINT,dst_id BIGINT)

INSERT INTO EICaseR_CASENUMBER7StruckOUT (src_id)
SELECT distinct phys_order_id FROM #stru_temps-- Jimmy  Added  Distinct

DECLARE @Maxphys_order_id INT,@Rowcount0 INT,@facid0 INT;
SET @Rowcount0 = (SELECT count(1) from EICaseR_CASENUMBER7StruckOUT)
EXEC get_next_primary_key 'pho_phys_order ' ,'phys_order_id',@Maxphys_order_id OUTPUT,@Rowcount0

UPDATE EICaseR_CASENUMBER7StruckOUT
SET dst_id = @Maxphys_order_id + ([row_id] - 1)
WHERE dst_id IS NULL -- rows

UPDATE a
SET a.phys_order_id = b.dst_id
--select a.phys_order_id,b.dst_id, * 
FROM pho_phys_order_audit a
JOIN EICaseR_CASENUMBER7StruckOUT b
ON a.phys_order_id = b.src_id
where 
a.client_id in (select dst_id from EICaseR_CASENUMBER7Clients )--
and a.fac_id = R_DSTFACID7 --dst fac_id
and a.audit_id in (select audit_id from #stru_temps)--updating only ones with issues

insert into pho_phys_order_new_entry
select distinct dst_id
from EICaseR_CASENUMBER7StruckOUT

delete from pcc_global_primary_key where table_name = 'pho_admin_order_audit' 

SELECT distinct a.audit_id
INTO #stru_temp
--select a.*
FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_admin_order_audit a --src db
join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_phys_order_audit b --src db
on a.phys_order_id = b.phys_order_id
WHERE a.admin_order_id NOT IN (SELECT admin_order_id FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_admin_order) --src db
and b.fac_id = R_SRCFACID7 --src fac_id

CREATE TABLE EICaseR_CASENUMBER7pho_admin_order_audit_post (row_id INT IDENTITY,src_id BIGINT,dst_id BIGINT)

INSERT INTO EICaseR_CASENUMBER7pho_admin_order_audit_post (src_id)
SELECT 
distinct audit_id FROM #stru_temp

DECLARE @Maxpho_admin_order_audit INT,@Rowcount1 INT,@facid1 INT;
SET @Rowcount1 = (SELECT count(1) from EICaseR_CASENUMBER7pho_admin_order_audit_post)
EXEC get_next_primary_key 'pho_admin_order_audit ' ,'audit_id',@Maxpho_admin_order_audit OUTPUT,@Rowcount1

UPDATE EICaseR_CASENUMBER7pho_admin_order_audit_post
SET dst_id = @Maxpho_admin_order_audit + ([row_id] - 1)
WHERE dst_id IS NULL

GO

SELECT distinct a.admin_order_id
INTO #stru_temp2
--select a.*
FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_admin_order_audit a --src db
join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_phys_order_audit b--src db
on a.phys_order_id = b.phys_order_id
WHERE a.admin_order_id NOT IN (SELECT admin_order_id FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_admin_order) --src db
and b.fac_id = R_SRCFACID7 --src fac_id

CREATE TABLE EICaseR_CASENUMBER7pho_admin_order_post (row_id INT IDENTITY,src_id BIGINT,dst_id BIGINT)

INSERT INTO EICaseR_CASENUMBER7pho_admin_order_post (src_id)
SELECT 
distinct admin_order_id FROM #stru_temp2

DECLARE @Maxpho_admin_order INT,@Rowcount2 INT,@facid2 INT;
SET @Rowcount2 = (SELECT count(1) from EICaseR_CASENUMBER7pho_admin_order_post)
EXEC get_next_primary_key 'pho_admin_order ' ,'admin_order_id',@Maxpho_admin_order OUTPUT,@Rowcount2

UPDATE EICaseR_CASENUMBER7pho_admin_order_post
SET dst_id = @Maxpho_admin_order + ([row_id] - 1)
WHERE dst_id IS NULL 

GO

SET IDENTITY_INSERT pho_admin_order_audit ON 

INSERT INTO [dbo].pho_admin_order_audit (
	audit_id
	,event_type
	,admin_order_id
	,phys_order_id
	,effective_date
	,ineffective_date
	,physician_id
	,created_by
	,created_date
	,revision_by
	,revision_date
	,deleted
	,deleted_by
	,deleted_date
	,reason
	,noted_by
	,strikeout_by
	,strikeout_date
	,strikeout_reason_code
	,strikeout_by_position
	)
SELECT DISTINCT b.dst_id
	,a.[event_type]
	,ISNULL(EICaseR_CASENUMBER71.dst_id, a.admin_order_id)
	,ISNULL(EICaseR_CASENUMBER73.dst_id, a.phys_order_id)
	,a.[effective_date]
	,isnull(a.ineffective_date, getdate())
	,ISNULL(EICaseR_CASENUMBER72.dst_id, a.physician_id)
	,a.[created_by]
	,a.[created_date]
	,a.[revision_by]
	,a.[revision_date]
	,a.[deleted]
	,a.[deleted_by]
	,a.[deleted_date]
	,a.[reason]
	,ISNULL(EICaseR_CASENUMBER74.dst_id, a.noted_by)
	,a.[strikeout_by]
	,a.[strikeout_date]
	,a.[strikeout_reason_code]
	,a.[strikeout_by_position]
FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_admin_order_audit a
LEFT JOIN [dbo].EICaseR_CASENUMBER7pho_admin_order_post EICaseR_CASENUMBER71 ON EICaseR_CASENUMBER71.src_id = a.admin_order_id
LEFT JOIN [dbo].EICaseR_CASENUMBER7contact EICaseR_CASENUMBER72 ON EICaseR_CASENUMBER72.src_id = a.physician_id
JOIN [dbo].EICaseR_CASENUMBER7StruckOUT EICaseR_CASENUMBER73 ON EICaseR_CASENUMBER73.src_id = a.phys_order_id --S/O post mapping table
LEFT JOIN [dbo].EICaseR_CASENUMBER7sec_user EICaseR_CASENUMBER74 ON EICaseR_CASENUMBER74.src_id = a.noted_by --nullable
	 JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_phys_order_audit pa on pa.phys_order_id = a.phys_order_id -- to filter clients in case current resident only
	,[dbo].EICaseR_CASENUMBER7pho_admin_order_audit_post b
WHERE 
	a.audit_id <> - 1
	AND a.audit_id = b.src_id
	AND pa.client_id in (select src_id from EICaseR_CASENUMBER7clients) 

SET IDENTITY_INSERT pho_admin_order_audit OFF

delete 
--select *
from pcc_global_primary_key where table_name = 'pho_related_order_audit' 

SELECT distinct a.audit_id
INTO #stru_tempa
--select *
from (
SELECT distinct a.audit_id
--INTO #stru_tempa3
--select distinct a.*
FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_related_order_audit a --src db
join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_phys_order_audit b --src db
on a.phys_order_id = b.phys_order_id
WHERE a.order_related_id NOT IN (SELECT order_related_id FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_related_order)--src fac_id
and b.fac_id = R_SRCFACID7 --src fac_id
and a.fac_id = R_SRCFACID7 --src fac_id
and b.client_id in (select src_id from EICaseR_CASENUMBER7clients)
union
SELECT distinct a.audit_id
--INTO #stru_tempa3
--select distinct a.*
FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_related_order_audit a --src db
join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_phys_order_audit b --src db
on a.related_phys_order_id = b.phys_order_id
WHERE a.order_related_id NOT IN (SELECT order_related_id FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_related_order) --src db
and b.fac_id = R_SRCFACID7 --src fac_id
and a.fac_id = R_SRCFACID7 --src fac_id
and b.client_id in (select src_id from EICaseR_CASENUMBER7clients)
) a 

CREATE TABLE EICaseR_CASENUMBER7pho_related_order_audit_post (row_id INT IDENTITY,src_id BIGINT,dst_id BIGINT)

INSERT INTO EICaseR_CASENUMBER7pho_related_order_audit_post (src_id)
SELECT 
distinct audit_id FROM #stru_tempa


DECLARE @Maxpho_related_order_audit INT,@Rowcount3 INT,@facid3 INT;
SET @Rowcount3 = (SELECT count(1) from EICaseR_CASENUMBER7pho_related_order_audit_post)
EXEC get_next_primary_key 'pho_related_order_audit ' ,'audit_id',@Maxpho_related_order_audit OUTPUT,@Rowcount3

UPDATE EICaseR_CASENUMBER7pho_related_order_audit_post
SET dst_id = @Maxpho_related_order_audit + ([row_id] - 1)
WHERE dst_id IS NULL 

GO

SELECT order_related_id
INTO #stru_tempa2
--select *
FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_related_order_audit --src db
where audit_id in (select src_id from EICaseR_CASENUMBER7pho_related_order_audit_post)

CREATE TABLE EICaseR_CASENUMBER7pho_related_order_post (row_id INT IDENTITY,src_id BIGINT,dst_id BIGINT)

INSERT INTO EICaseR_CASENUMBER7pho_related_order_post (src_id)
SELECT distinct order_related_id FROM #stru_tempa2

DECLARE @Maxphys_order_id INT,@Rowcount4 INT,@facid4 INT;
SET @Rowcount4 = (SELECT count(1) from EICaseR_CASENUMBER7pho_related_order_post)
EXEC get_next_primary_key 'pho_related_order ' ,'order_related_id',@Maxphys_order_id OUTPUT,@Rowcount4

UPDATE EICaseR_CASENUMBER7pho_related_order_post
SET dst_id = @Maxphys_order_id + ([row_id] - 1)
WHERE dst_id IS NULL 

GO

SET IDENTITY_INSERT pho_related_order_audit ON

INSERT INTO [dbo].pho_related_order_audit (
	audit_id
	,event_type
	,order_related_id
	,phys_order_id
	,related_phys_order_id
	,created_date
	,created_by
	,revision_date
	,revision_by
	,deleted_by
	,deleted_date
	,deleted
	,fac_id
	,order_relationship_id
	)
SELECT DISTINCT b.dst_id
	,a.[event_type]
	,ISNULL(EICaseR_CASENUMBER71.dst_id, a.order_related_id)
	,a.[phys_order_id]
	,a.[related_phys_order_id]
	,a.[created_date]
	,a.[created_by]
	,a.[revision_date]
	,a.[revision_by]
	,a.[deleted_by]
	,a.[deleted_date]
	,a.[deleted]
	,copy_fac.dst_id
	,ISNULL(EICaseR_CASENUMBER72.dst_id, a.order_relationship_id)
FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].pho_related_order_audit a
JOIN [dbo].EICaseR_CASENUMBER7facility copy_fac ON copy_fac.src_id = a.fac_id
	OR copy_fac.src_id = R_SRCFACID7 --src fac_id
JOIN [dbo].EICaseR_CASENUMBER7pho_order_relationship EICaseR_CASENUMBER72 ON EICaseR_CASENUMBER72.src_id = a.order_relationship_id
LEFT JOIN [dbo].EICaseR_CASENUMBER7pho_related_order_post EICaseR_CASENUMBER71 ON EICaseR_CASENUMBER71.src_id = a.order_related_id
join [dbo].EICaseR_CASENUMBER7pho_related_order_audit_post b on b.src_id = a.audit_id
WHERE a.audit_id <> - 1
	AND a.fac_id IN (
		R_SRCFACID7 --src fac_id
		,- 1
		)
	AND a.audit_id = b.src_id 

SET IDENTITY_INSERT pho_related_order_audit OFF

if OBJECT_ID ('pcc_temp_storage.dbo.EICaseR_CASENUMBER7_bkp_pho_related_order_audit_updated1','U') is not null
drop table pcc_temp_storage.dbo.EICaseR_CASENUMBER7_bkp_pho_related_order_audit_updated1

select a.audit_id into pcc_temp_storage.dbo.EICaseR_CASENUMBER7_bkp_pho_related_order_audit_updated1
from pho_related_order_audit a
join EICaseR_CASENUMBER7pho_related_order_audit_post b on b.dst_id = a.audit_id
join EICaseR_CASENUMBER7pho_phys_order c on a.phys_order_id = c.src_id
where a.fac_id = R_DSTFACID7 --dst fac_id

if OBJECT_ID ('pcc_temp_storage.dbo.EICaseR_CASENUMBER7_bkp_pho_related_order_audit_updated2','U') is not null
drop table pcc_temp_storage.dbo.EICaseR_CASENUMBER7_bkp_pho_related_order_audit_updated2

select a.audit_id into pcc_temp_storage.dbo.EICaseR_CASENUMBER7_bkp_pho_related_order_audit_updated2
from pho_related_order_audit a
join EICaseR_CASENUMBER7pho_related_order_audit_post b on b.dst_id = a.audit_id
join EICaseR_CASENUMBER7pho_phys_order c on a.related_phys_order_id = c.src_id
where a.fac_id = R_DSTFACID7 --dst fac_id

select a.audit_id into #updated1 
from pho_related_order_audit a
join EICaseR_CASENUMBER7pho_related_order_audit_post b on b.dst_id = a.audit_id
join EICaseR_CASENUMBER7pho_phys_order c on a.phys_order_id = c.src_id
where a.fac_id = R_DSTFACID7 --dst fac_id

update a
set a.phys_order_id = c.dst_id
--select * 
from pho_related_order_audit a
join EICaseR_CASENUMBER7pho_related_order_audit_post b on b.dst_id = a.audit_id
join EICaseR_CASENUMBER7pho_phys_order c on a.phys_order_id = c.src_id
where a.fac_id = R_DSTFACID7 --dst fac_id

update a
set a.phys_order_id = c.dst_id
--select * 
from pho_related_order_audit a
join EICaseR_CASENUMBER7pho_related_order_audit_post b on b.dst_id = a.audit_id
join EICaseR_CASENUMBER7StruckOUT c on a.phys_order_id = c.src_id
where a.fac_id = R_DSTFACID7 --dst fac_id
and a.audit_id not in (select audit_id from #updated1)

select a.audit_id into #updated2 
from pho_related_order_audit a
join EICaseR_CASENUMBER7pho_related_order_audit_post b on b.dst_id = a.audit_id
join EICaseR_CASENUMBER7pho_phys_order c on a.related_phys_order_id = c.src_id
where a.fac_id = R_DSTFACID7 --dst fac_id

update a
set a.related_phys_order_id = c.dst_id
--select * 
from pho_related_order_audit a
join EICaseR_CASENUMBER7pho_related_order_audit_post b on b.dst_id = a.audit_id
join EICaseR_CASENUMBER7pho_phys_order c on a.related_phys_order_id = c.src_id
where a.fac_id = R_DSTFACID7 --dst fac_id

update a
set a.related_phys_order_id = c.dst_id
--select * 
from pho_related_order_audit a
join EICaseR_CASENUMBER7pho_related_order_audit_post b on b.dst_id = a.audit_id
join EICaseR_CASENUMBER7StruckOUT c on a.related_phys_order_id = c.src_id
where a.fac_id = R_DSTFACID7 --dst fac_id
and a.audit_id not in (select audit_id from #updated2)

--==========================================================================

print  CHAR(13) + '************Ended running : Standard post scripts***************'  

--========================================================================================

--==========================================================================

print  CHAR(13) + 'Post insert for as_ard_adl_keys running now'  

-- Post insert for 'as_ard_adl_keys'
-- We can remove the duplicate check since we're inserting all at once and as_ard_planner has no scope fields so it never merges on insert
-- Combine all mapping tables into single temp tables:

CREATE TABLE #map_as_std_assessment (src_id INT PRIMARY KEY, dst_id INT NOT NULL)
INSERT INTO #map_as_std_assessment
SELECT src_id, dst_id FROM test_usei1214.dbo.EICaseR_CASENUMBER7as_std_assessment

CREATE TABLE #map_as_ard_planner (src_id INT PRIMARY KEY, dst_id INT NOT NULL)
INSERT INTO #map_as_ard_planner
SELECT src_id, dst_id FROM test_usei1214.dbo.EICaseR_CASENUMBER7as_ard_planner

INSERT INTO test_usei1214.dbo.as_ard_adl_keys
(
    ard_planner_id
    , std_assess_id
    , question_key
    , resp_value
    , source_id
)
SELECT DISTINCT 
	  ISNULL(c.dst_id, ard_planner_id) 
    , ISNULL(b.dst_id, std_assess_id) 
    , [question_key]
    , [resp_value]
    , [source_id]
FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.as_ard_adl_keys a
    INNER JOIN #map_as_std_assessment b ON b.src_id = a.std_assess_id 
    INNER JOIN #map_as_ard_planner c ON c.src_id = a.ard_planner_id 

--==========================================================================

print  CHAR(13) + 'diet postscripts fix running now' 
print  CHAR(13) + '**** ONLY RUN FOR THE LAST FACILITY ***' 

update d
set deleted = 'Y'
--select * 
from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code d
where deleted = 'N' and DELETED_BY is not null 

update d
set deleted = 'Y'
--select * 
from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.common_code d
where deleted = 'N' and DELETED_BY is not null 

--==========================================================================

print  CHAR(13) + 'Started running : 2 (if custom care plan library is NOT approved).sql'  

print  CHAR(13) + ' CP libraries fix - if CP library not copied ' 

--print CHAR(13) + 'backup commented out for second facility and onwards'
if OBJECT_ID ('pcc_temp_storage.dbo.bkp_EICaseR_CASENUMBER7_cp_rev_intervention','U') is not null
	drop table pcc_temp_storage.dbo.bkp_EICaseR_CASENUMBER7_cp_rev_intervention
select * into pcc_temp_storage.dbo.bkp_EICaseR_CASENUMBER7_cp_rev_intervention from cp_rev_intervention

update dst
set category_id = null
from cp_rev_intervention dst
join EICaseR_CASENUMBER7cp_rev_intervention map 
on dst.gen_intervention_id = map.dst_id 
--comment below 2 lines if slow
join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.cp_rev_intervention src 
on src.gen_intervention_id = map.src_id 
--comment above 2 lines if slow
where dst.fac_id = R_DSTFACID7 
and dst.category_id is not null

print  CHAR(13) + 'Ended running : 2 (if custom care plan library is NOT approved).sql'  

--==========================================================================

print  CHAR(13) + 'Started running : 3 (If UDA NOT approved).sql'  

print  CHAR(13) + ' diagnosis_notification: if MDS3 had date restriction on LOA ' 

if OBJECT_ID ('pcc_temp_storage.dbo._bkp_EICaseR_CASENUMBER7_diagnosis_notification','U') is not null
	drop table pcc_temp_storage.dbo._bkp_EICaseR_CASENUMBER7_diagnosis_notification
select * into pcc_temp_storage.dbo._bkp_EICaseR_CASENUMBER7_diagnosis_notification from diagnosis_notification

update diagnosis_notification
set assess_id = NULL
--select * 
from diagnosis_notification
where fac_id in (R_DSTFACID7) 
and assess_id not in 
(select assess_id from as_assessment where fac_id in (R_DSTFACID7))

print  CHAR(13) + 'Ended running : 3 (If UDA NOT approved).sql'  

--==========================================================================

print  CHAR(13) + 'Started running : 4 (if UDA is approved but care plan library is NOT approved).sql'  

print  ' If copying UDAs but not CP libraries ' 

if OBJECT_ID ('pcc_temp_storage.dbo.bkp_EICaseR_CASENUMBER7_as_std_trigger_update','U') is not null
drop table pcc_temp_storage.dbo.bkp_EICaseR_CASENUMBER7_as_std_trigger_update
select * into pcc_temp_storage.dbo.bkp_EICaseR_CASENUMBER7_as_std_trigger_update from as_std_trigger

update as_std_trigger
set triggered_item_id = null, deleted = 'Y',deleted_by = 'EICaseR_CASENUMBER7',deleted_date = getdate()
--select * 
from as_std_trigger 
where trigger_type IN ('I','N','G')
and std_assess_id in (select dst_id from EICaseR_CASENUMBER7as_std_assessment where corporate = 'N') 

print  CHAR(13) + 'Ended running : 4 (if UDA is approved but care plan library is NOT approved).sql'  

--==========================================================================

print  CHAR(13) + 'Started running : 5 (If UDA is approved).sql'  

/*

Created 11 (If UDA is approved) by merging the below 2 scripts

11 InteractForm -- post Script, check your Project if using eInterACt form (If UDA is approved)
12 post UDA question and text qlib fix (if UDA is approved)

*/

print  CHAR(13) + 'InteractForm -- post Script, check your Project if using eInterACt form (If UDA is approved) running now'
print  CHAR(13) + ' Einteract post-fix '  

if OBJECT_ID ('pcc_temp_storage.dbo._bkp_EICaseR_CASENUMBER7_as_response','U') is not null
	drop table pcc_temp_storage.dbo._bkp_EICaseR_CASENUMBER7_as_response

select a.* into pcc_temp_storage.dbo._bkp_EICaseR_CASENUMBER7_as_response 
from as_response a join EICaseR_CASENUMBER7as_assessment assess on a.assess_id=assess.dst_id

update a
set item_value = replace(item_value,'<sentTo>' + convert(varchar,b.src_id * -1) + '<','<sentTo>' + convert(varchar,b.dst_id * -1) + '<')
from  as_response a inner join EICaseR_CASENUMBER7emc_ext_facilities b
on left(a.item_value,patindex('%</sentTo>%',item_value)) = '<sentTo>' + convert(varchar,b.src_id * -1) + '<'
join EICaseR_CASENUMBER7as_assessment assess  
on a.assess_id=assess.dst_id--
where  a.question_key ='Cust_B_1_1'
and len(item_value)>0 

update a
set item_value =  -1*(b.dst_id)
from  as_response a inner join EICaseR_CASENUMBER7emc_ext_facilities b
on b.src_id = -1*(a.item_value)
join EICaseR_CASENUMBER7as_assessment assess  
on a.assess_id=assess.dst_id
where  a.question_key ='Cust_B_1_1_1'

 update a
set item_value =  b.dst_id
from  as_response a 
inner join EICaseR_CASENUMBER7unit b on b.src_id = a.item_value
join EICaseR_CASENUMBER7as_assessment assess  
on a.assess_id=assess.dst_id--
where  a.question_key ='Cust_B_1_1_4'--

update a
set item_value = replace(item_value,'<unit>' + convert(varchar,b.src_id) + '<','<unit>' + convert(varchar,b.dst_id) + '<')
from  as_response a inner join EICaseR_CASENUMBER7unit b
on substring(item_value,patindex('%<unit>%',item_value)+6,patindex('%</unit>%',item_value)-patindex('%<unit>%',item_value)-6) = convert(varchar,b.src_id)
join EICaseR_CASENUMBER7as_assessment assess  
on a.assess_id=assess.dst_id
where  a.question_key ='Cust_B_1_1'--
and len(item_value)>0
and patindex('%<unit>%',item_value)>0 

---------------------------------------------------------------------------------------------------------------------

print  CHAR(13) + 'post UDA question and text qlib fix (if UDA is approved) running now'
print  CHAR(13) + ' backups '  

if OBJECT_ID ('pcc_temp_storage.dbo._bkp_as_std_pick_list_item_EICaseR_CASENUMBER7_before_post','U') is not null
drop table pcc_temp_storage.dbo._bkp_as_std_pick_list_item_EICaseR_CASENUMBER7_before_post

if OBJECT_ID ('pcc_temp_storage.dbo._bkp_as_std_question_EICaseR_CASENUMBER7_before_post','U') is not null
drop table pcc_temp_storage.dbo._bkp_as_std_question_EICaseR_CASENUMBER7_before_post

if OBJECT_ID ('pcc_temp_storage.dbo._bkp_as_std_pick_list_item_EICaseR_CASENUMBER7_updated','U') is not null
drop table pcc_temp_storage.dbo._bkp_as_std_pick_list_item_EICaseR_CASENUMBER7_updated

if OBJECT_ID ('pcc_temp_storage.dbo._bkp_as_std_question_EICaseR_CASENUMBER7_updated','U') is not null
drop table pcc_temp_storage.dbo._bkp_as_std_question_EICaseR_CASENUMBER7_updated

--select * into pcc_temp_storage.dbo._bkp_as_std_pick_list_item_EICaseR_CASENUMBER7_before_post from as_std_pick_list_item 
--select * into pcc_temp_storage.dbo._bkp_as_std_question_EICaseR_CASENUMBER7_before_post from as_std_question 

select dst.* into pcc_temp_storage.dbo._bkp_as_std_pick_list_item_EICaseR_CASENUMBER7_updated
from as_std_pick_list_item dst
join EICaseR_CASENUMBER7as_std_pick_list map on dst.pick_list_id = map.dst_id
join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.as_std_pick_list_item src with (nolock) on map.src_id = src.pick_list_id
join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.as_std_question asqsrc with (nolock) on src.pick_list_id = asqsrc.pick_list_id
join EICaseR_CASENUMBER7qlib_pick_list_item qmap on dst.qlib_pick_list_item_id = qmap.dst_id
and qmap.src_id = src.qlib_pick_list_item_id
where asqsrc.question_source_library_id = 1
and dst.qlib_pick_list_item_id <> src.qlib_pick_list_item_id 

select dst.* into pcc_temp_storage.dbo._bkp_as_std_question_EICaseR_CASENUMBER7_updated
--select distinct dst.std_assess_id
from as_std_question dst
join EICaseR_CASENUMBER7as_std_assessment map on dst.std_assess_id = map.dst_id
join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.as_std_question src with (nolock) on map.src_id = src.std_assess_id
and src.question_key = dst.question_key
join qlib_question qqdst on qqdst.std_question_id = dst.std_question_id
join EICaseR_CASENUMBER7qlib_question qqmap on qqmap.dst_id = qqdst.std_question_id
join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.qlib_question qqsrc with (nolock) on qqsrc.std_question_id = qqmap.src_id
where src.question_source_library_id = 1
and map.corporate <> 'Y'
and dst.std_question_id <> src.std_question_id 

print  CHAR(13) + ' cleanup '  

update dst
set dst.qlib_pick_list_item_id = src.qlib_pick_list_item_id
from as_std_pick_list_item dst
join EICaseR_CASENUMBER7as_std_pick_list map on dst.pick_list_id = map.dst_id
join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.as_std_pick_list_item src with (nolock) on map.src_id = src.pick_list_id
join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.as_std_question asqsrc with (nolock) on src.pick_list_id = asqsrc.pick_list_id
join EICaseR_CASENUMBER7qlib_pick_list_item qmap on dst.qlib_pick_list_item_id = qmap.dst_id
and qmap.src_id = src.qlib_pick_list_item_id
where asqsrc.question_source_library_id = 1
and dst.qlib_pick_list_item_id <> src.qlib_pick_list_item_id 

update dst
set dst.std_question_id = src.std_question_id
from as_std_question dst
join EICaseR_CASENUMBER7as_std_assessment map on dst.std_assess_id = map.dst_id
join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.as_std_question src with (nolock) on map.src_id = src.std_assess_id
and src.question_key = dst.question_key
join qlib_question qqdst on qqdst.std_question_id = dst.std_question_id
join EICaseR_CASENUMBER7qlib_question qqmap on qqmap.dst_id = qqdst.std_question_id
join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.qlib_question qqsrc with (nolock) on qqsrc.std_question_id = qqmap.src_id
where src.question_source_library_id = 1
and map.corporate <> 'Y'
and dst.std_question_id <> src.std_question_id

print  CHAR(13) + 'Ended running : 5 (If UDA is approved).sql'  

--==========================================================================
print  CHAR(13) + 'Started running : 5.5 (if UDA is approved (Scoring Issue)).sql'  


/*

-- Run in destination as post script
-- This is to update the scores that refers to other scores with proper id
-- Clinical Configuration > UDA Libraries > scoring link beside UDA Lib.

-- Runs one time per facility
-- Check for result that includes 'check' for the scenario where a dst_id is overlapped with src_id
-- For such cases it will need to be replaced manually

-- Replace:

-- [SRC_SERVER]
-- SRC_DB
-- [CaseNo] (numbers only)

*/

DECLARE @SRCSTRING VARCHAR(50)
DECLARE @DSTSTRING VARCHAR(50)

DECLARE @rowid INT = 0

if exists (
select 1 from as_std_score where std_score_id in 
(select dst_id from EICaseR_CASENUMBER7as_std_score where corporate = 'N')
and formula like '%[[]SCR%'
)
BEGIN

WHILE (1 = 1) 

	BEGIN 

	  SELECT TOP 1 @rowid = row_id
	  FROM EICaseR_CASENUMBER7as_std_score
	  WHERE CORPORATE = 'N' and row_id > @rowid
	  ORDER BY row_id

	IF @@ROWCOUNT = 0 BREAK;

	SELECT 
		@SRCSTRING = '[SCR_' + convert(varchar, src_id) + ']'
		,@DSTSTRING = '[SCR_' + convert(varchar, dst_id) + ']'
	--SELECT *
	FROM EICaseR_CASENUMBER7as_std_score
	WHERE CORPORATE = 'N'
	AND ROW_ID = @rowid

	--SELECT @SRCSTRING
	--SELECT @DSTSTRING

	------------
	if exists(
	select 1
	from as_std_score dst
		join EICaseR_CASENUMBER7as_std_score map on dst.std_score_id = map.dst_id
	join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.as_std_score src on map.src_id = src.std_score_id -------src db
	where map.corporate = 'N' and src.formula like '%' + replace(@SRCSTRING,'[','[[]') + '%'
	and exists (select 1 from as_std_score with (nolock) where dst.std_score_id = std_score_id and formula like '%' + replace(@DSTSTRING,'[','[[]') + '%'))
	begin
	print '------check: src - ' + @SRCSTRING + ' dst - ' + @DSTSTRING + '------------'
	end
	------------

	print @SRCSTRING + ' replaced with ' + @DSTSTRING

	update dst
	set dst.formula = replace(dst.formula,@SRCSTRING,@DSTSTRING)
	--select *
	from as_std_score dst
		join EICaseR_CASENUMBER7as_std_score map on dst.std_score_id = map.dst_id
	join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.as_std_score src on map.src_id = src.std_score_id -------src db
	where map.corporate = 'N' and src.formula like '%' + replace(@SRCSTRING,'[','[[]') + '%'
	and not exists (select 1 from as_std_score with (nolock) where dst.std_score_id = std_score_id and formula like '%' + replace(@DSTSTRING,'[','[[]') + '%')

	END
END

GO

--==========================================================================

print  CHAR(13) + 'Started running : 6 (if risk management is approved).sql'  

print  CHAR(13) + ' risk management picklists postfix '  

if OBJECT_ID ('pcc_temp_storage.dbo._bkp_EICaseR_CASENUMBER7_inc_response','U') is not null
drop table pcc_temp_storage.dbo._bkp_EICaseR_CASENUMBER7_inc_response
select * into pcc_temp_storage.dbo._bkp_EICaseR_CASENUMBER7_inc_response from INC_RESPONSE

update dst
set dst.item_value = mapp.dst_id
--select dst.* 
from INC_RESPONSE dst 
join EICaseR_CASENUMBER7inc_incident map on dst.inc_id = map.dst_id
join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.INC_RESPONSE src on map.src_id = src.inc_id and src.question_key = dst.question_key
join EICaseR_CASENUMBER7inc_std_pick_list_item mapp on dst.item_value = mapp.src_id
where src.question_key in ('inj_2','inj_4','inj_7','inj_9')
and dst.question_key in ('inj_2','inj_4','inj_7','inj_9')
and src.pick_list_item_id = -1
and src.item_value <> '' 
and dst.item_value <> mapp.dst_id --

print  CHAR(13) + 'Ended running : 6 (if risk management is approved).sql'  

--==========================================================================

print  CHAR(13) + 'Started running : 7 (if copying UDA and Risk Management).sql'  

update dst
set dst.primary_triggered_by = map.dst_id
--select dst.primary_triggered_by,map.dst_id,dst.*
from as_assess_schedule_details dst 
join EICaseR_CASENUMBER7inc_incident map on dst.primary_triggered_by = map.src_id
join EICaseR_CASENUMBER7as_assess_schedule_details mapp on dst.detail_id= mapp.dst_id
join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.as_assess_schedule_details src on mapp.src_id = src.detail_id 
where dst.triggered_type='INC'
and dst.primary_triggered_by  is not null
and dst.fac_id = R_DSTFACID7 

print  CHAR(13) + 'Ended running : 7 (if copying UDA and Risk Management).sql'  

--==========================================================================

--print  CHAR(13) + 'Started running : 8 (MultiFacility + Copy Custom UDAs) (run after all facilities).sql'  

--update dst
--set dst.description = src.description
----select src.*, dst.*
--from as_std_pick_list dst
--join EICaseR_CASENUMBER7as_std_pick_list map on dst.pick_list_id = map.dst_id  
--join [[vmuspassvtscon3.pccprod.local]].pcc_temp_storage.dbo._bkp_Case59277183_as_std_pick_list src with (nolock) on map.src_id = src.pick_list_id 
--join EICaseR_CASENUMBER7as_std_assessment amap on amap.dst_id = dst.std_assess_id
--where src.description <> dst.description
--and map.corporate <> 'Y' and amap.corporate <> 'Y'

--print  CHAR(13) + 'Ended running : 8 (MultiFacility + Copy Custom UDAs) (run after all facilities).sql'  

--==========================================================================

--print  CHAR(13) + 'Started running : 9 (MultiFacility + Copy Custom UDAs) (Run for the 2nd Facility and on).sql'  

--/*

--Created "15 (MultiFacility + Copy Custom UDA's)(dont run for the first facility) (Run for the 2nd Facility and on)" by merging  the below 2 scripts

--15 issues with UDA schedules (MultiFacility + Copy Custom UDAs)(dont run for the first facility) (Run for the 2nd Facility and on)
--15 post as_assess_schedule (MultiFacility + Copy Custom UDAs)(dont run for the first facility) (Run for the 2nd Facility and on)

--*/

--print  CHAR(13) + 'issues with UDA schedules (MultiFacility + Copy Custom UDAs)(dont run for the first facility) (Run for the 2nd Facility and on)'

--INSERT INTO [dbo].as_std_assessment_facility (fac_id,std_assess_id)
--SELECT DISTINCT copy_fac.dst_id,ISNULL(EICaseR_CASENUMBER71.dst_id, std_assess_id)
--FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.[dbo].as_std_assessment_facility a -- src DB
--JOIN [dbo].EICaseR_CASENUMBER7facility copy_fac ON copy_fac.src_id = a.fac_id OR copy_fac.src_id = R_SRCFACID7
--JOIN [dbo].EICaseR_CASENUMBER7as_std_assessment EICaseR_CASENUMBER71 ON EICaseR_CASENUMBER71.src_id = a.std_assess_id
--JOIN [dbo].EICaseR_CASENUMBER7facility EICaseR_CASENUMBER72 ON EICaseR_CASENUMBER72.src_id = a.fac_id
--WHERE fac_id IN (R_SRCFACID7,- 1)
--       AND NOT EXISTS (SELECT 1 FROM [dbo].as_std_assessment_facility origt WHERE origt.std_assess_id = EICaseR_CASENUMBER71.dst_id AND origt.fac_id = EICaseR_CASENUMBER72.dst_id)
--       AND EICaseR_CASENUMBER71.dst_id not in (select std_assess_id from as_std_assessment_system_assessment_mapping)

--print  CHAR(13) + 'post as_assess_schedule (MultiFacility + Copy Custom UDAs)(dont run for the first facility) (Run for the 2nd Facility and on)'

--update dst
--set dst.std_schedule_id = stdmap.dst_id
--from as_assess_schedule dst
--join EICaseR_CASENUMBER7as_assess_schedule map on dst.schedule_id = map.dst_id
--join [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.as_assess_schedule src on src.schedule_id = map.src_id and dst.std_schedule_id = src.std_schedule_id
--join EICase59277183as_std_assess_schedule stdmap on dst.std_schedule_id = stdmap.src_id
--where dst.fac_id = R_DSTFACID7 

--UPDATE i
--SET i.event_id = c.event_id
----select *
--FROM as_assess_schedule i
--       ,as_std_assess_schedule c
--WHERE i.std_schedule_id = c.schedule_id
--       AND i.schedule_id IN (
--              SELECT dst_id
--              FROM EICaseR_CASENUMBER7as_assess_schedule
--              WHERE corporate = 'N'
--              )
--       AND i.fac_id = R_DSTFACID7 and i.event_id <> c.event_id 
	   
--print  CHAR(13) + 'Ended running : 9 (MultiFacility + Copy Custom UDAs) (Run for the 2nd Facility and on).sql'  

--==========================================================================

------------------NO MDS GAP IMPORT AS OF 18th NOV 2019------------------

--print  CHAR(13) + 'Started running : 10 (if MDS gap import).sql'  

----In the future MDS3 brought over with 'In Progess' status will be soft deleted

--update as_assessment
--set deleted = 'Y', deleted_by = 'EICaseR_CASENUMBER7', deleted_date = getdate()
----select *
--from as_assessment
--where std_assess_id = 11 --MDS3
--and fac_id = R_DSTFACID7 --dst fac_id
--and assess_id in (select dst_id from EICaseR_CASENUMBER7as_assessment)--mapping table
--and status = 'In Progress'
--and deleted = 'N'

--print  CHAR(13) + 'Ended running : 10 (if MDS gap import).sql'  

--==========================================================================

--print  CHAR(13) + 'Started running : 11 (If OMNI integration - all residents)'  

--/*

--This scripts was created by merging

--16 Insert_MapIdentifier (If OMNI integration - all residents)
--17 Insert_Pho_Pharmacy_order (If OMNI integration - all residents)
--18 Insert_Pho_pharmacy_note_detail (If OMNI integration - all residents)
--19 Insert_pho_phys_vendor (If OMNI integration - all residents)
--20 Insert_Pho_supply_dispense (If OMNI integration - all residents)

--Make sure to change the message profile ID, follow the below 4 steps

-- Find message_profile_id in use in source production: 
--	SELECT DISTINCT message_profile_id, * 
--	FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.pho_phys_vendor AS src 
--	INNER JOIN test_usei1214.dbo.EICaseR_CASENUMBER7pho_phys_order AS map ON src.phys_order_id = map.src_id

-- Find vendor in source production: 
--	SELECT * FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.lib_message_profile

-- Match to vendor in destination production: 
--	SELECT * FROM [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi.dbo.lib_message_profile

-- Destination message_profile_id: (Replaece this variable below)
--	R_MESSAGEPROFILEID

--*/


--print  CHAR(13) + '16 Insert_MapIdentifier (If OMNI integration - all residents) running now ' 

--DECLARE @Maxmap_identifier_id INT ,@Rowcount INT ,@facid INT

--select identity(int,0,1) as row, src.map_identifier_id as src_id, NULL as dst_id
--into dbo.EIcaseR_CASENUMBER7map_identifier
----select *
--from [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.map_identifier src
--where fac_id = R_SRCFACID7
--and map_type_id = 2

--set @Rowcount=@@rowcount
--exec get_next_primary_key 'map_identifier','map_identifier_id',@Maxmap_identifier_id output , @Rowcount

--update  dbo.EIcaseR_CASENUMBER7map_identifier  
--set  dst_id = row+@Maxmap_identifier_id

--insert into  map_identifier(map_identifier_id,
--created_by,
--created_date,
--revision_by,
--revision_date,
--fac_id,
--reg_id,
--vendor_code,
--map_type_id,
--external_id,
--internal_id)
--select map.dst_id,
--created_by,
--created_date,
--revision_by,
--revision_date,
--R_DSTFACID7,
--reg_id,
--vendor_code,
--map_type_id,
--external_id,
--internal_id    
----select  *   
--from  [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.map_identifier src
--join EIcaseR_CASENUMBER7map_identifier map
--on src.map_identifier_id= map.src_id
--where  src.fac_id= R_SRCFACID7 

--update  map_identifier
--set  internal_id=cl.dst_id
----select  *  
--from  map_identifier map
--join dbo.EICaseR_CASENUMBER7clients cl
--on cl.src_id=map.internal_id
--where map.map_type_id=2
--and fac_id = R_DSTFACID7 

--GO

--print  CHAR(13) + '17 Insert_Pho_Pharmacy_order (If OMNI integration - all residents) running now ' 

--DECLARE @Maxpharmacy_order_id INT ,@Rowcount INT ,@facid INT

--select identity(int,0,1) as row, src.pharmacy_order_id as src_id, NULL as dst_id
--into dbo.EIcaseR_CASENUMBER7pho_pharmacy_order
----select *
--from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_pharmacy_order src
--where fac_id = R_SRCFACID7 

--set @Rowcount=@@rowcount
--exec get_next_primary_key 'pho_pharmacy_order','pharmacy_order_id',@Maxpharmacy_order_id output , @Rowcount

--update  dbo.EIcaseR_CASENUMBER7pho_pharmacy_order 
--set  dst_id = row+@Maxpharmacy_order_id

--insert into  pho_pharmacy_order(pharmacy_order_id,
--created_by,
--created_date,
--fac_id,
--phys_order_id,
--vendor_code,
--ext_fac_id,
--ext_client_id,
--description,
--related_generic,
--label_name,
--drug_code,
--start_date,
--end_date,
--directions,
--tran_id,
--prescription,
--pharmacy_shipment_id,
--physician_license_no,
--physician_firstname,
--physician_lastname,
--patient_firstname,
--patient_lastname,
--patient_middlename,
--patient_suffix,
--patient_prefix,
--patient_alias,
--patient_healthcard_no,
--receive_status,
--order_status,
--scan_date,
--status_change_by,
--status_change_date,
--controlled_substance_code,
--ext_order_type,
--fill_date,
--shape_color_marking,
--disp_package_identifier,
--auto_fill_flag,
--related_phys_order_id,
--relationship,
--disp_code,
--exp_ship_date,
--quantity_remaining,
--ext_pharmacy_id,
--drug_manufacturer,
--drug_class_number,
--form,
--strength,
--route_of_admin,
--diagnoses,
--nurse_admin_notes,
--event_driven_flag,
--discrepancy_code,
--end_date_type,
--end_date_duration_type,
--end_date_duration,
--revision_by,
--revision_date,
--received_by,
--receiver_position,
--quantity_received,
--next_refill_date,
--substitution_indicator,
--vendor_supply_id,
--dispensation_sequence_number,
--vendor_phys_order_id,
--inbound_message_id,
--auto_fill_system_name)
--SELECT   map3.dst_id,
--created_by,
--created_date,
--R_DSTFACID7,
--map.dst_id,
--vendor_code,
--ext_fac_id,
--ext_client_id,
--description,
--related_generic,
--label_name,
--drug_code,
--start_date,
--end_date,
--directions,
--tran_id,
--prescription,
--pharmacy_shipment_id,
--physician_license_no,
--physician_firstname,
--physician_lastname,
--patient_firstname,
--patient_lastname,
--patient_middlename,
--patient_suffix,
--patient_prefix,
--patient_alias,
--patient_healthcard_no,
--receive_status,
--order_status,
--scan_date,
--status_change_by,
--status_change_date,
--controlled_substance_code,
--ext_order_type,
--fill_date,
--shape_color_marking,
--disp_package_identifier,
--auto_fill_flag,
--related_phys_order_id,
--relationship,
--disp_code,
--exp_ship_date,
--quantity_remaining,
--map2.dst_id,
--drug_manufacturer,
--drug_class_number,
--form,
--strength,
--route_of_admin,
--diagnoses,
--nurse_admin_notes,
--event_driven_flag,
--discrepancy_code,
--end_date_type,
--end_date_duration_type,
--end_date_duration,
--revision_by,
--revision_date,
--received_by,
--receiver_position,
--quantity_received,
--next_refill_date,
--substitution_indicator,
--vendor_supply_id,
--dispensation_sequence_number,
--vendor_phys_order_id,
--NULL,
--auto_fill_system_name  
-----select  * 
--from  [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_pharmacy_order src 
--left join dbo.EICaseR_CASENUMBER7pho_phys_order map
--on src.phys_order_id=map.src_id
--join EICaseR_CASENUMBER7emc_ext_facilities map2
--on map2.src_id=src.ext_pharmacy_id
--join EIcaseR_CASENUMBER7pho_pharmacy_order map3
--on map3.src_id=src.pharmacy_order_id
--where src.fac_id=R_SRCFACID7 

--GO

--print  CHAR(13) + '18 Insert_Pho_pharmacy_note_detail (If OMNI integration - all residents) running now ' 

--DECLARE @Maxpharmacy_note_detail_id INT ,@Rowcount INT ,@facid INT

--select identity(int,0,1) as row, src.pharmacy_note_detail_id as src_id,
-- NULL as dst_id
--into dbo.EIcaseR_CASENUMBER7pho_pharmacy_note_detail
----select *
--from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_pharmacy_note_detail src
--where pharmacy_order_id in  (select  pharmacy_order_id  from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_pharmacy_order
--where  fac_id=R_SRCFACID7)

--set @Rowcount=@@rowcount
--exec get_next_primary_key 'pho_pharmacy_note_detail','pharmacy_note_detail_id',@Maxpharmacy_note_detail_id output , @Rowcount

--update  dbo.EIcaseR_CASENUMBER7pho_pharmacy_note_detail 
--set  dst_id = row+@Maxpharmacy_note_detail_id

--insert into  pho_pharmacy_note_detail (pharmacy_note_detail_id,
--created_by,
--created_date,
--pharmacy_order_id,
--note_type,
--note)
--select  map2.dst_id,
--created_by,
--created_date,
--map.dst_id,
--note_type,
--note  
----select * 
--from  [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_pharmacy_note_detail src 
--join  EIcaseR_CASENUMBER7pho_pharmacy_order map
--on  src.pharmacy_order_id=map.src_id
--join EIcaseR_CASENUMBER7pho_pharmacy_note_detail map2
--on map2.src_id=src.pharmacy_note_detail_id

--GO

--print  CHAR(13) + '19 Insert_pho_phys_vendor (If OMNI integration - all residents) running now ' 

----DROP TABLE EIcaseR_CASENUMBER7pho_phys_vendor
----DELETE FROM pcc_global_primary_key WHERE table_name = 'pho_phys_vendor'
 
-- DECLARE @Maxphys_vendor_id INT ,@Rowcount INT ,@facid INT

--select identity(int,0,1) as row, src.phys_vendor_id as src_id,
-- NULL as dst_id
--into dbo.EIcaseR_CASENUMBER7pho_phys_vendor
----select  *  
--from  [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_phys_vendor src --
--join EICaseR_CASENUMBER7pho_phys_order map
--on src.phys_order_id=map.src_id 

--set @Rowcount=@@rowcount
--exec get_next_primary_key 'pho_phys_vendor','phys_vendor_id',@Maxphys_vendor_id output , @Rowcount

--update  dbo.EIcaseR_CASENUMBER7pho_phys_vendor 
--set  dst_id = row+@Maxphys_vendor_id

--set identity_insert  pho_phys_vendor on
 
--insert into pho_phys_vendor (phys_vendor_id,
--phys_order_id,
--message_profile_id,
--disp_sequence_number,
--prescription,
--disp_package_identifier,
--vendor_order_id,
--active)
--select  map.dst_id,
--map2.dst_id,
--R_MESSAGEPROFILEID,	--message_profile_id from above
--disp_sequence_number,
--prescription,
--disp_package_identifier,
--vendor_order_id,
--active
----select  *  
--from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_phys_vendor  src
--join EIcaseR_CASENUMBER7pho_phys_vendor map
--on src.phys_vendor_id=map.src_id
--join EIcaseR_CASENUMBER7pho_phys_order map2
--on map2.src_id=src.phys_order_id

--set identity_insert  pho_phys_vendor off

--GO

--print  CHAR(13) + '20 Insert_Pho_supply_dispense (If OMNI integration - all residents) running now ' 

--DECLARE @Maxsupply_dispense_id INT ,@Rowcount INT ,@facid INT

--select identity(int,0,1) as row, src.supply_dispense_id as src_id,
-- NULL as dst_id
--into dbo.EIcaseR_CASENUMBER7pho_supply_dispense
----select  *  
--from  [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_supply_dispense src --
--join EICaseR_CASENUMBER7pho_order_supply map
--on src.order_supply_id=map.src_id 
--join  pho_order_supply dest
--on dest.order_supply_id=map.dst_id

--set @Rowcount=@@rowcount
--exec get_next_primary_key 'pho_supply_dispense','supply_dispense_id',@Maxsupply_dispense_id output , @Rowcount

--update  dbo.EIcaseR_CASENUMBER7pho_supply_dispense 
--set  dst_id = row+@Maxsupply_dispense_id

--insert into  pho_supply_dispense (supply_dispense_id,
--order_supply_id,
--pharmacy_order_id,
--created_by,
--created_date,
--deleted,
--deleted_by,
--deleted_date,
--match_type )
--select  
--map.dst_id,
--map4.dst_id,
--map3.dst_id,
--src.created_by,
--src.created_date,
--src.deleted,
--src.deleted_by,
--src.deleted_date,
--src.match_type
----select  * 
--from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_supply_dispense src
--join EIcaseR_CASENUMBER7pho_supply_dispense map
--on map.src_id=src.supply_dispense_id 
--join EIcaseR_CASENUMBER7pho_pharmacy_order map3
--on map3.src_id=src.pharmacy_order_id 
--join EIcaseR_CASENUMBER7pho_order_supply map4
--on map4.src_id=src.order_supply_id
--join pho_order_supply dest
--on dest.order_supply_id=map4.dst_id 

--print  CHAR(13) + 'Ended running : 11 (If OMNI integration - all residents)	'  

--==========================================================================

--print  CHAR(13) + 'Started running : 11 (If OMNI integration - current residents)'  

--/*

--This scripts was created by merging

--16 Insert_MapIdentifier (If OMNI integration - current residents )
--17 Insert_Pho_Pharmacy_order (If OMNI integration - current residents )
--18 Insert_Pho_pharmacy_note_detail (If OMNI integration - current residents )
--19 Insert_pho_phys_vendor (If OMNI integration - current residents )
--20 Insert_Pho_supply_dispense (If OMNI integration - current residents )

--Make sure to change the message profile ID, follow the below 4 steps

-- Find message_profile_id in use in source production: 
--	SELECT DISTINCT message_profile_id, * 
--	FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.pho_phys_vendor AS src 
--	INNER JOIN test_usei1214.dbo.EICaseR_CASENUMBER7pho_phys_order AS map ON src.phys_order_id = map.src_id

-- Find vendor in source production: 
--	SELECT * FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.lib_message_profile

-- Match to vendor in destination production: 
--	SELECT * FROM [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi.dbo.lib_message_profile

-- Destination message_profile_id: (Replaece this variable below)
--	R_MESSAGEPROFILEID

--*/

--print  CHAR(13) + '16 Insert_MapIdentifier (If OMNI integration - current residents) running now ' 

--DECLARE @Maxmap_identifier_id INT ,@Rowcount INT ,@facid INT

--select identity(int,0,1) as row, src.map_identifier_id as src_id, NULL as dst_id
--into dbo.EIcaseR_CASENUMBER7map_identifier 
----select *
--from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.map_identifier src
--where fac_id = R_SRCFACID7 
--and map_type_id = 2 
--and internal_id in (select src_id from EICaseR_CASENUMBER7clients)
--and vendor_code = 'omnioasis'

--set @Rowcount=@@rowcount
--exec get_next_primary_key 'map_identifier','map_identifier_id',@Maxmap_identifier_id output , @Rowcount

--update  dbo.EIcaseR_CASENUMBER7map_identifier  
--set  dst_id = row+@Maxmap_identifier_id

--INSERT INTO map_identifier (
--	map_identifier_id
--	,created_by
--	,created_date
--	,revision_by
--	,revision_date
--	,fac_id
--	,reg_id
--	,vendor_code
--	,map_type_id
--	,external_id
--	,internal_id
--	)
--SELECT map.dst_id
--	,created_by
--	,created_date
--	,revision_by
--	,revision_date
--	,R_DSTFACID7
--	,reg_id
--	,vendor_code
--	,map_type_id
--	,external_id
--	,internal_id
--FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.map_identifier src
--JOIN EIcaseR_CASENUMBER7map_identifier map ON src.map_identifier_id = map.src_id
--WHERE src.fac_id =R_SRCFACID7

--update  map_identifier
--set  internal_id = cl.dst_id
----select  *  
--from  map_identifier map
--join dbo.EICaseR_CASENUMBER7clients cl
--on cl.src_id=map.internal_id
--where map.map_type_id = 2
--and fac_id = R_DSTFACID7

--GO

--print  CHAR(13) + '17 Insert_Pho_Pharmacy_order (If OMNI integration - current residents) running now ' 

--DECLARE @Maxpharmacy_order_id INT ,@Rowcount INT ,@facid INT

--select identity(int,0,1) as row, src.pharmacy_order_id as src_id, NULL as dst_id
--into dbo.EIcaseR_CASENUMBER7pho_pharmacy_order
----select *
--from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_pharmacy_order src
--where fac_id = R_SRCFACID7 
--and ext_client_id in (select external_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.map_identifier
--where map_identifier_id in (select src_id from EIcaseR_CASENUMBER7map_identifier)) 

--set @Rowcount=@@rowcount
--exec get_next_primary_key 'pho_pharmacy_order','pharmacy_order_id',@Maxpharmacy_order_id output , @Rowcount

--update  dbo.EIcaseR_CASENUMBER7pho_pharmacy_order 
--set  dst_id = row+@Maxpharmacy_order_id

--insert into  pho_pharmacy_order(pharmacy_order_id,
--created_by,
--created_date,
--fac_id,
--phys_order_id,
--vendor_code,
--ext_fac_id,
--ext_client_id,
--description,
--related_generic,
--label_name,
--drug_code,
--start_date,
--end_date,
--directions,
--tran_id,
--prescription,
--pharmacy_shipment_id,
--physician_license_no,
--physician_firstname,
--physician_lastname,
--patient_firstname,
--patient_lastname,
--patient_middlename,
--patient_suffix,
--patient_prefix,
--patient_alias,
--patient_healthcard_no,
--receive_status,
--order_status,
--scan_date,
--status_change_by,
--status_change_date,
--controlled_substance_code,
--ext_order_type,
--fill_date,
--shape_color_marking,
--disp_package_identifier,
--auto_fill_flag,
--related_phys_order_id,
--relationship,
--disp_code,
--exp_ship_date,
--quantity_remaining,
--ext_pharmacy_id,
--drug_manufacturer,
--drug_class_number,
--form,
--strength,
--route_of_admin,
--diagnoses,
--nurse_admin_notes,
--event_driven_flag,
--discrepancy_code,
--end_date_type,
--end_date_duration_type,
--end_date_duration,
--revision_by,
--revision_date,
--received_by,
--receiver_position,
--quantity_received,
--next_refill_date,
--substitution_indicator,
--vendor_supply_id,
--dispensation_sequence_number,
--vendor_phys_order_id,
--inbound_message_id,
--auto_fill_system_name)
--SELECT   map3.dst_id,
--created_by,
--created_date,
--R_DSTFACID7,
--map.dst_id,
--vendor_code,
--ext_fac_id,
--ext_client_id,
--description,
--related_generic,
--label_name,
--drug_code,
--start_date,
--end_date,
--directions,
--tran_id,
--prescription,
--pharmacy_shipment_id,
--physician_license_no,
--physician_firstname,
--physician_lastname,
--patient_firstname,
--patient_lastname,
--patient_middlename,
--patient_suffix,
--patient_prefix,
--patient_alias,
--patient_healthcard_no,
--receive_status,
--order_status,
--scan_date,
--status_change_by,
--status_change_date,
--controlled_substance_code,
--ext_order_type,
--fill_date,
--shape_color_marking,
--disp_package_identifier,
--auto_fill_flag,
--related_phys_order_id,
--relationship,
--disp_code,
--exp_ship_date,
--quantity_remaining,
--map2.dst_id,
--drug_manufacturer,
--drug_class_number,
--form,
--strength,
--route_of_admin,
--diagnoses,
--nurse_admin_notes,
--event_driven_flag,
--discrepancy_code,
--end_date_type,
--end_date_duration_type,
--end_date_duration,
--revision_by,
--revision_date,
--received_by,
--receiver_position,
--quantity_received,
--next_refill_date,
--substitution_indicator,
--vendor_supply_id,
--dispensation_sequence_number,
--vendor_phys_order_id,
--NULL,
--auto_fill_system_name  
-----select  * 
--from  [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_pharmacy_order src 
--left join dbo.EICaseR_CASENUMBER7pho_phys_order map
--on src.phys_order_id=map.src_id
--join EICaseR_CASENUMBER7emc_ext_facilities map2
--on map2.src_id=src.ext_pharmacy_id
--join EIcaseR_CASENUMBER7pho_pharmacy_order map3
--on map3.src_id=src.pharmacy_order_id
--where src.fac_id = R_SRCFACID7 

--GO

--print  CHAR(13) + '18 Insert_Pho_pharmacy_note_detail (If OMNI integration - current residents) running now ' 

--DECLARE @Maxpharmacy_note_detail_id INT ,@Rowcount INT ,@facid INT

--select identity(int,0,1) as row, src.pharmacy_note_detail_id as src_id,
-- NULL as dst_id
--into dbo.EIcaseR_CASENUMBER7pho_pharmacy_note_detail
----select *
--from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_pharmacy_note_detail src
--where pharmacy_order_id in 
--(select src_id from EIcaseR_CASENUMBER7pho_pharmacy_order)

--set @Rowcount=@@rowcount
--exec get_next_primary_key 'pho_pharmacy_note_detail','pharmacy_note_detail_id',@Maxpharmacy_note_detail_id output , @Rowcount

--update  dbo.EIcaseR_CASENUMBER7pho_pharmacy_note_detail 
--set  dst_id = row+@Maxpharmacy_note_detail_id

--insert into  pho_pharmacy_note_detail (pharmacy_note_detail_id,
--created_by,
--created_date,
--pharmacy_order_id,
--note_type,
--note)
--select  map2.dst_id,
--created_by,
--created_date,
--map.dst_id,
--note_type,
--note  
----select * 
--from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_pharmacy_note_detail src 
--join EIcaseR_CASENUMBER7pho_pharmacy_order map
--on src.pharmacy_order_id=map.src_id
--join EIcaseR_CASENUMBER7pho_pharmacy_note_detail map2
--on map2.src_id=src.pharmacy_note_detail_id


--GO

--print  CHAR(13) + '19 Insert_pho_phys_vendor (If OMNI integration - current residents) running now ' 

----DROP TABLE EIcaseR_CASENUMBER7pho_phys_vendor
----DELETE FROM pcc_global_primary_key WHERE table_name = 'pho_phys_vendor'

--DECLARE @Maxpharmacy_order_id INT ,@Rowcount INT ,@facid INT

--select identity(int,0,1) as row, src.phys_vendor_id as src_id,
-- NULL as dst_id
--into dbo.EIcaseR_CASENUMBER7pho_phys_vendor
----select  *  
--from  [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_phys_vendor src 
--join EICaseR_CASENUMBER7pho_phys_order map
--on src.phys_order_id=map.src_id 

--set @Rowcount=@@rowcount
--exec get_next_primary_key 'pho_phys_vendor','phys_vendor_id',@Maxpharmacy_order_id output , @Rowcount

--update  dbo.EIcaseR_CASENUMBER7pho_phys_vendor 
--set  dst_id = row+@Maxpharmacy_order_id

--set identity_insert  pho_phys_vendor on
 
--insert into pho_phys_vendor (phys_vendor_id,
--phys_order_id,
--message_profile_id,
--disp_sequence_number,
--prescription,
--disp_package_identifier,
--vendor_order_id,
--active)
--select  map.dst_id,
--map2.dst_id,
--R_MESSAGEPROFILEID,	--message_profile_id from above
--disp_sequence_number,
--prescription,
--disp_package_identifier,
--vendor_order_id,
--active
----select  *  
--from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_phys_vendor  src
--join EIcaseR_CASENUMBER7pho_phys_vendor map
--on src.phys_vendor_id=map.src_id
--join EIcaseR_CASENUMBER7pho_phys_order map2
--on map2.src_id=src.phys_order_id

--set identity_insert  pho_phys_vendor off 

--GO

--print  CHAR(13) + '20 Insert_Pho_supply_dispense (If OMNI integration - current residents) running now ' 

--DECLARE @Maxsupply_dispense_id INT ,@Rowcount INT ,@facid INT

--select identity(int,0,1) as row, src.supply_dispense_id as src_id,
-- NULL as dst_id
--into dbo.EIcaseR_CASENUMBER7pho_supply_dispense
----select  *  
--from  [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_supply_dispense src 
--join EICaseR_CASENUMBER7pho_order_supply map
--on src.order_supply_id=map.src_id 
--join  pho_order_supply dest
--on dest.order_supply_id=map.dst_id

--set @Rowcount=@@rowcount
--exec get_next_primary_key 'pho_supply_dispense','supply_dispense_id',@Maxsupply_dispense_id output , @Rowcount

--update  dbo.EIcaseR_CASENUMBER7pho_supply_dispense 
--set  dst_id = row+@Maxsupply_dispense_id

--insert into  pho_supply_dispense (supply_dispense_id,
--order_supply_id,
--pharmacy_order_id,
--created_by,
--created_date,
--deleted,
--deleted_by,
--deleted_date,
--match_type )
--select  
--map.dst_id,
--map4.dst_id,
--map3.dst_id,
--src.created_by,
--src.created_date,
--src.deleted,
--src.deleted_by,
--src.deleted_date,
--src.match_type
----select  * 
--from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_supply_dispense src
--join EIcaseR_CASENUMBER7pho_supply_dispense map
--on map.src_id=src.supply_dispense_id 
--join EIcaseR_CASENUMBER7pho_pharmacy_order map3
--on map3.src_id=src.pharmacy_order_id 
--join EIcaseR_CASENUMBER7pho_order_supply map4
--on map4.src_id=src.order_supply_id
--join pho_order_supply dest
--on dest.order_supply_id=map4.dst_id

--print  CHAR(13) + 'Ended running : 11 (If OMNI integration - current residents)'  

--==========================================================================

/* Latest Test Results



*/

/* Go Live Results



*/