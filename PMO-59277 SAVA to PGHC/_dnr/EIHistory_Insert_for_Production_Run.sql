
------Run in [udsm3\ds2016job]
------Only run when Production Go-live is completed but report failed to generate
------Trigger on EIHistory table will generate and send Completion Report base on data inserted
------Please make sure all information are correct, and follow the format/content naming conventions


use ds_merge_master

--select * from EIHistory where PMO_number = '51073'

INSERT INTO ds_merge_master.dbo.[EIHistory] 
([case_no],[PMO_number],[go_live_date],[DS_resource],[src_org_code],[dst_org_code],[src_fac_id],[dst_fac_id],[src_EOM],[dst_EOM]
,[mod_resident_identifiers_contact],[mod_security_roles],[mod_security_users],[mod_staff],[mod_medical_prof],[mod_external_facility],[mod_user_defined_data],[mod_room_bed],[mod_census]
,[mod_assess_MDS2],[mod_assess_MDS3],[mod_custom_UDA],[mod_MMQ],[mod_MMA],[mod_diagnosis],[mod_immunization],[mod_care_plan_custom],[mod_care_plan_library],[mod_progress_note]
,[mod_weight_vitals],[mod_physician_order],[mod_alerts],[mod_risk_management],[mod_trust],[mod_irm],[mod_online_doc],[mod_LabResultRadiology],[mod_Master_Insurance],[mod_Notes]
,[created_by],[created_date],[revision_by],[revision_date]) 
VALUES (
'Case5188238'--[case_no], the number used for this facility, the same number that's part of mapping table
,'51882'--[PMO_number]
,'2020-12-07 0:15:00'--[go_live_date], use time of DS Helper run completion
,'chaudas'--[DS_resource], use existing format and refer to your previous automatically generated report if not sure
,'champ (Test Env =usei626)'--[src_org_code], include test DB when applicable
,'mphs (Test Env =MPHS)'--[dst_org_code]
,'38 - Cranbrook Health and Rehab Center'--[src_fac_id], fac_id - facility name
,'19 -Mission Point of Cranbrook LLC'--[dst_fac_id], fac_id - facility name
,'Y'--[src_EOM]
,'Y'--[dst_EOM]
,'Y'--[mod_resident_identifiers_contact]
,'N'--[mod_security_roles]
,'N'--[mod_security_users]
,'Y'--[mod_staff]
,'Y'--[mod_medical_prof]
,'Y'--[mod_external_facility]
,'Y'--[mod_user_defined_data]
,'Y'--[mod_room_bed]
,'Y'--[mod_census]
,'Y'--[mod_assess_MDS2]
,'Y'--[mod_assess_MDS3]
,'Y'--[mod_custom_UDA]
,'N'--[mod_MMQ]
,'N'--[mod_MMA]
,'Y'--[mod_diagnosis]
,'Y'--[mod_immunization]
,'Y'--[mod_care_plan_custom]
,'N'--[mod_care_plan_library]
,'Y'--[mod_progress_note]
,'Y'--[mod_weight_vitals]
,'Y'--[mod_physician_order]
,'Y'--[mod_alerts]
,'Y'--[mod_risk_management]
,'N'--[mod_trust]
,'N'--[mod_irm]
,'Y'--[mod_online_doc]
,'Y'--[mod_LabResultRadiology]
,'Y'--[mod_Master_Insurance]
,'Y'--[mod_Notes]
,'chaudas'--[created_by], use existing format and refer to your previous automatically generated report if not sure
,'2020-12-07 0:16:00'--[created_date], use time of DS Helper run completion
,'chaudas'--[revision_by], use existing format and refer to your previous automatically generated report if not sure
,'2020-12-07 0:16:00'--[revision_date], use time of DS Helper run completion
)

