USE pcc_staging_db59277
--GO

--==========================================================================

-- if single fac - comment the below scoping script

print CHAR(13) + 'scoping for sec_role'

UPDATE sec_role
SET fac_id = -1
--select * 
from sec_role WHERE created_by = 'EICaseR_CASENUMBER3'
AND role_id IN (SELECT dst_id FROM EICaseR_CASENUMBER3sec_role 
	WHERE corporate = 'N' and src_id in (select role_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.sec_role where fac_id = -1))
AND fac_id <> -1 

print CHAR(13) + 'scoping for alerts'

update  cr_std_alert
set  fac_id = -1
where  std_alert_id in (select  dst_id from  EIcaseR_CASENUMBER3cr_Std_alert where corporate='N'
	AND src_id in (select std_alert_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.cr_std_alert where fac_id = -1))
and fac_id <> -1

print CHAR(13) + 'scoping for risk management'

update inc_std_pick_List_item
set  fac_id=-1
----select  * from  inc_std_pick_List_item
where pick_list_item_id in (select dst_id from EICaseR_CASENUMBER3inc_std_pick_list_item where corporate='N'
	AND src_id in (select pick_list_item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.inc_std_pick_List_item where fac_id = -1))
and fac_id <>-1

print CHAR(13) + 'scoping for onine documentation'

update  UPLOAD_CATEGORIES
set  fac_id=-1
--select *
 from UPLOAD_CATEGORIES
where cat_id in (select dst_id from EICaseR_CASENUMBER3UPLOAD_CATEGORIES where  corporate='N'
	AND src_id in (select cat_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.UPLOAD_CATEGORIES where fac_id = -1))
and fac_id <>-1

print CHAR(13) + 'scoping for master insurance'

update  ar_lib_insurance_companies
set  fac_id = -1
--select *
from ar_lib_insurance_companies
where insurance_id in (select dst_id from EIcaseR_CASENUMBER3ar_lib_insurance_companies where corporate = 'N'
	AND src_id in (select insurance_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.ar_lib_insurance_companies where fac_id = -1))
and fac_id <> -1 

update  ar_insurance_addresses
set  fac_id = -1
--select *
from ar_insurance_addresses
where address_id in (select dst_id from EIcaseR_CASENUMBER3ar_insurance_addresses where corporate = 'N'
	AND src_id in (select address_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.ar_insurance_addresses where fac_id = -1))
and fac_id <> -1 

print CHAR(13) + 'scoping for care plan libraries -- start'

update cp_std_library
set  fac_id = -1, revision_by = 'EIcaseR_CASENUMBER3', revision_Date = getdate()
--select * 
from dbo.cp_std_library where created_by = 'EICaseR_CASENUMBER3'
AND library_id in (select dst_id from  EIcaseR_CASENUMBER3cp_std_library 
	WHERE corporate = 'N' and src_id in (select library_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.cp_std_library where fac_id = -1))
AND fac_id <> -1

UPDATE cp_std_need_cat
SET fac_id = - 1, revision_by = 'EIcaseR_CASENUMBER3', revision_Date = getdate()
--select * 
from dbo.cp_std_need_cat
WHERE created_by = 'EICaseR_CASENUMBER3'
AND library_id IN (SELECT dst_id FROM EIcaseR_CASENUMBER3cp_std_library)
AND need_cat_id in (select dst_id FROM EIcaseR_CASENUMBER3cp_std_need_cat where corporate = 'N'
	AND src_id in (select need_cat_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.cp_std_need_cat where fac_id = -1))
AND fac_id <> -1 

UPDATE cp_std_need
SET fac_id = - 1
--select * 
FROM cp_std_need
WHERE created_by = 'EICaseR_CASENUMBER3' 
AND need_cat_id in (select need_cat_id FROM cp_std_need_cat WHERE library_id IN (SELECT dst_id FROM EIcaseR_CASENUMBER3cp_std_library))
AND std_need_id in (select dst_id from EICaseR_CASENUMBER3cp_std_need where corporate = 'N'
	AND src_id in (select std_need_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.cp_std_need where fac_id = -1))
AND fac_id <> -1

update cp_std_goal
set fac_id = -1
--select * 
from cp_std_goal
where created_by  ='EICaseR_CASENUMBER3'
AND std_need_id in (select std_need_id from cp_std_need where need_cat_id in 
							(select need_cat_id from cp_std_need_cat where library_id in 
									(select dst_id from EIcaseR_CASENUMBER3cp_std_library)))
AND std_goal_id in (select dst_id from EICaseR_CASENUMBER3cp_std_goal where corporate = 'N'
	AND src_id in (select std_goal_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.cp_std_goal where fac_id = -1))
AND fac_id <> -1

update cp_std_intervention
set fac_id = -1
--select * 
from cp_std_intervention
where created_by  ='EICaseR_CASENUMBER3'
AND std_need_id in (select std_need_id from cp_std_need 
							where need_cat_id in (select need_cat_id from cp_std_need_cat 
							where library_id in (select dst_id from EIcaseR_CASENUMBER3cp_std_library)))
AND std_intervention_id in (select dst_id from EICaseR_CASENUMBER3cp_std_intervention where corporate = 'N'
	AND src_id in (select std_intervention_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.cp_std_intervention where fac_id = -1))
AND fac_id <> -1

update cp_std_etiologies
set fac_id = -1, revision_by = 'EIcaseR_CASENUMBER3', revision_date = getdate()
--select *
from cp_std_etiologies
where created_by = 'EICaseR_CASENUMBER3'
AND std_need_id in (select std_need_id from cp_std_need 
							where need_cat_id in (select need_cat_id from cp_std_need_cat 
							where library_id in (select dst_id from EIcaseR_CASENUMBER3cp_std_library)))
AND std_etiologies_id in (select dst_id from EICaseR_CASENUMBER3cp_std_etiologies where corporate = 'N'
	 AND src_id in (select std_etiologies_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.cp_std_etiologies where fac_id = -1))
AND fac_id <> -1

UPDATE cp_std_schedule
SET fac_id = -1
--select *
FROM cp_std_schedule
WHERE std_schedule_id IN (SELECT dst_id FROM EICaseR_CASENUMBER3cp_std_schedule WHERE corporate = 'N'
	AND src_id in (select std_schedule_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.cp_std_schedule where fac_id = -1))	
AND fac_id <> -1

update  cp_kardex_categories
set  fac_id=-1
--select *
 from cp_kardex_categories
where category_id in (select dst_id from EIcaseR_CASENUMBER3cp_kardex_categories where  corporate='N'
	AND src_id in (select category_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.cp_kardex_categories where fac_id = -1))
and fac_id <>-1 

print CHAR(13) + 'scoping for care plan libraries -- end'

print CHAR(13) + 'scoping for cutom UDA''s '

--WHEN COPYING CUSTOM UDA's UNCOMMENT THE BELOW SECTION

print  CHAR(13) + ' UDA scoping section start ' 

update  as_std_assessment
set  fac_id=-1
--select * from as_std_assessment
where  std_assess_id in  (select  dst_id from EIcaseR_CASENUMBER3as_std_assessment where corporate='N'
	AND src_id in (select std_assess_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.as_std_assessment where fac_id = -1))
and fac_id<>-1---687 rows


update  as_std_trigger
set  fac_id = -1
--select * from as_std_trigger
where  std_trigger_id in  (select  dst_id from EIcaseR_CASENUMBER3as_std_trigger where corporate='N'
	AND src_id in (select std_trigger_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.as_std_trigger where fac_id = -1))
and fac_id <> -1---11101 rows

update  as_std_assess_schedule
set  fac_id=-1
--select * from as_std_assess_schedule
where  schedule_id in  (select  dst_id from EIcaseR_CASENUMBER3as_std_assess_schedule where corporate='N' 
	AND src_id in (select schedule_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.as_std_assess_schedule where fac_id = -1))
and fac_id<>-1---0 rows

update  as_consistency_rule
set  fac_id=-1
--select * from as_consistency_rule
where  consistency_rule_id in  (select  dst_id from EIcaseR_CASENUMBER3as_consistency_rule where corporate='N'
	AND src_id in (select consistency_rule_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.as_consistency_rule where fac_id = -1))
and fac_id<>-1---0 rows

update  as_std_profile_consistency
set  fac_id=-1
--select * from as_std_profile_consistency
where  std_profile_consistency_id in  (select  dst_id from EIcaseR_CASENUMBER3as_std_profile_consistency where corporate='N'
	AND src_id in (select std_profile_consistency_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.as_std_profile_consistency where fac_id = -1))
and fac_id<>-1---0 rows

--ONLY if merging UDA and copying alerts
update CR_STD_HIGHRISK_DESC
set  fac_id=-1
--select * from CR_STD_HIGHRISK_DESC
where std_highrisk_id in  (select  dst_id from EIcaseR_CASENUMBER3CR_STD_HIGHRISK_DESC where corporate = 'N'
	AND src_id in (select std_highrisk_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.CR_STD_HIGHRISK_DESC where fac_id = -1 or reg_id = 1))
and fac_id <> -1---0 rows

print  CHAR(13) + ' UDA scoping section end ' 

print CHAR(13) + 'scoping for Progress Notes'

UPDATE pn_template
SET fac_id = -1
--select * from pn_template
WHERE template_id IN (SELECT dst_id	FROM EIcaseR_CASENUMBER3pn_template WHERE corporate = 'N'
	AND src_id in (select template_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pn_template where fac_id = -1))
	AND fac_id <> -1 

UPDATE pn_type
SET fac_id = -1
--select  *  from  pn_type
WHERE pn_type_id IN (SELECT dst_id FROM EIcaseR_CASENUMBER3pn_type WHERE corporate = 'N'
		AND src_id in (select pn_type_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pn_type where fac_id = -1))
	AND fac_id <> -1 

print CHAR(13) + 'scoping for phys_order start'

UPDATE pho_order_type
SET fac_id = -1
---select * from pho_order_type
WHERE order_type_id IN (SELECT dst_id FROM EIcaseR_CASENUMBER3pho_order_type	WHERE corporate = 'N'
		AND src_id in (select order_type_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_order_type where fac_id = -1)) 
	AND fac_id <> -1 

update pho_administration_record
set fac_id = -1
---select * from pho_administration_record
where administration_record_id  in (select dst_Id from EIcaseR_CASENUMBER3pho_administration_record WHERE corporate = 'N'
	AND src_id in (select administration_record_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_administration_record where fac_id = -1))
AND fac_id <> -1 

update  pho_std_phys_order
set  fac_id = -1
--select  *  from pho_std_phys_order
where std_phys_order_id in (select dst_Id from EIcaseR_CASENUMBER3pho_std_phys_order WHERE corporate = 'N'
	AND src_id in (select std_phys_order_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_std_phys_order where fac_id = -1))--9
and fac_id <> -1

update pho_order_group
set  fac_id = -1
--select * from pho_order_group
where order_group_id in (select dst_id from EIcaseR_CASENUMBER3pho_order_group where corporate = 'N'
	AND src_id in (select order_group_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_order_group where fac_id = -1))
and fac_id <> -1

update pho_order_group_item
set  fac_id=-1
--select  *  from  pho_order_group_item
where order_group_item_id in  (select dst_id from EIcaseR_CASENUMBER3pho_order_group_item where corporate = 'N'
	AND src_id in (select order_group_item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_order_group_item where fac_id = -1))
and fac_id <> -1

update  pho_std_time
set  fac_id=-1
--select * from dbo.pho_std_time
where pho_std_time_id in (select dst_id from EICaseR_CASENUMBER3pho_std_time where corporate='N'
AND src_id in (select pho_std_time_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_std_time where fac_id = -1))
and fac_id <> -1

update  pho_std_time_details
set  fac_id=-1
--select * from dbo.pho_std_time_details
where pho_std_time_details_id in (select dst_id from EICaseR_CASENUMBER3pho_std_time_details where  corporate='N'
	AND src_id in (select pho_std_time_details_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_std_time_details where fac_id = -1))
and fac_id <> -1

update  pho_std_order_set
set fac_id = -1, reg_id = -1
--select * from dbo.pho_std_order_set
where std_order_set_id in (select dst_id from EIcaseR_CASENUMBER3pho_std_order_set where  corporate='N'
	AND src_id in (select std_order_set_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_std_order_set where fac_id = -1))
and fac_id <> -1

update  pho_std_order
set  fac_id=-1,reg_id = -1
--select fac_id ,* from dbo.pho_std_order
where std_order_id in (select dst_id from  EIcaseR_CASENUMBER3pho_std_order where  corporate = 'N'
	AND src_id in (select std_order_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_std_order where fac_id = -1))
and fac_id <> -1

update  pho_std_phys_order
set  fac_id=-1
--select * from pho_std_phys_order
where std_phys_order_id in (select dst_id from EICaseR_CASENUMBER3pho_std_phys_order where  corporate = 'N'
	AND src_id in (select std_phys_order_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_std_phys_order where fac_id = -1))
and fac_id <>-1

update  pho_std_time_details
set unit_id=-1
--select *  from pho_std_time_details
where pho_std_time_details_id in  (select dst_id from  EICaseR_CASENUMBER3pho_std_time_details where  corporate='N')
and unit_id is null

update  cr_cust_med
set fac_id = -1
--select  fac_id,*  from cr_cust_med
where  custom_drug_id in  (select  dst_id from  EIcaseR_CASENUMBER3cr_cust_med where corporate='N'
	AND src_id in (select custom_drug_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.cr_cust_med where fac_id = -1))
AND fac_id <> -1

print CHAR(13) + 'scoping for phys_order end'

-----------------------------------------------------------------------------------------------------------------------------------------------

print CHAR(13) + 'all time scoping starts'

update cp_std_frequency
set  fac_id = -1
where created_by = 'EIcaseR_CASENUMBER3'
and std_freq_id in (select dst_id from EIcaseR_CASENUMBER3cp_std_frequency WHERE corporate = 'N'
	AND src_id in (select std_freq_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.cp_std_frequency where fac_id = -1))
and fac_id <> -1

update cp_std_shift
set  fac_id=-1, revision_by='EIcaseR_CASENUMBER3', revision_Date=getdate()
--select * 
from dbo.cp_std_shift
where created_by = 'EIcaseR_CASENUMBER3'
AND std_shift_id in (select dst_id from EICaseR_CASENUMBER3cp_std_shift where corporate = 'N'
	AND src_id in (select std_shift_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.cp_std_shift where fac_id = -1))
AND fac_id <> -1

print CHAR(13) + 'scoping for DIAGNOSIS LIBRARY - always'

update diagnosis_codes
set  fac_id = -1, revision_by = 'EIcaseR_CASENUMBER3', revision_Date = getdate()
--select * from dbo.diagnosis_codes
where created_by = 'EIcaseR_CASENUMBER3'
and diagnosis_id IN (SELECT dst_id FROM EICaseR_CASENUMBER3diagnosis_codes WHERE corporate = 'N'
		AND src_id in (select diagnosis_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.diagnosis_codes where fac_id = -1))
	AND fac_id <> -1

print CHAR(13) + 'scoping for Resident Identifiers - always'

UPDATE id_type
SET fac_id = -1
--select  *  
from id_type WHERE created_by = 'EICaseR_CASENUMBER3'
AND id_type_id in (SELECT dst_id FROM EICaseR_CASENUMBER3id_type
	WHERE corporate = 'N' and src_id in (select id_type_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.id_type where fac_id = -1))
AND fac_id <> -1

print CHAR(13) + 'scoping for External Facility - always'

UPDATE emc_ext_facilities
SET fac_id = -1
--select  *  
from emc_ext_facilities WHERE created_by = 'EICaseR_CASENUMBER3' 
AND ext_fac_id IN (SELECT dst_id FROM EIcaseR_CASENUMBER3emc_ext_facilities
	WHERE corporate = 'N' and src_id in (select ext_fac_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.emc_ext_facilities where fac_id = -1))
AND fac_id <> -1

print CHAR(13) + 'scoping for User_Defined_data - always'

update  user_field_types
set  fac_id=-1
--select * 
from user_field_types where created_by = 'EICaseR_CASENUMBER3'
AND field_type_id IN (SELECT dst_id FROM EIcaseR_CASENUMBER3user_field_types
	WHERE corporate = 'N' and src_id in (select field_type_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.user_field_types where fac_id = -1))
AND fac_id <> -1

print CHAR(13) + 'scoping for common_code - always - start'

update  common_code
set fac_id = -1
--select * from common_code
where item_Code = 'phodyt'
and fac_id <> -1
and created_by = 'EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update common_code
set  fac_id=-1
--select * from common_code
where item_code = 'phodtx'
and created_by = 'EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update common_code
set fac_id = -1
--select * from common_code
where item_Code = 'phocst'
and fac_id <> -1
and created_by = 'EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update common_code
set fac_id=-1
--select * from common_code
where item_Code = 'phosup'
and fac_id <> -1
and created_by = 'EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update  common_code
set  fac_id=-1
--select  *  from common_code
where item_Code='phorad'
and  fac_id <>-1
and  created_by='EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update  common_code
set  fac_id=-1
--select  *  from common_code
where item_Code='phoifu'
and  fac_id <>-1
and  created_by='EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))
	
update  common_code
set  fac_id=-1
--select  *  from common_code
where item_Code='phocht'
and  fac_id <>-1
and  created_by='EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))
	
update  common_code
set  fac_id=-1
--	select  *  from common_code
where item_Code='consig'
and  fac_id <>-1
and  created_by='EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update  common_code
set  fac_id=-1
where item_Code='phofac'
and  created_by='EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update  common_code
set  fac_id=-1
--select  *  from  common_Code
where item_Code='phowvc'
and  created_by='EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update common_code
set  fac_id=-1
--select  *  from common_code
where item_Code='dclas'
and  created_by='EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update common_code
set  fac_id=-1
--select  *  from common_code
where item_Code='drank'
and  created_by='EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update  common_code
set  fac_id=-1
--select  *  from common_code
where item_Code='locat'
and  created_by='EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update  common_code
set  fac_id=-1
--select  *  from  common_code
where item_code='cashrt'
and  created_by='EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update  common_code
set  fac_id=-1
--select  *  from common_code
where item_Code='citize'
and  created_by='EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update  common_code
set  fac_id=-1
--select  *  from common_code
where item_Code='relat'
and  created_by='EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update  common_code
set  fac_id=-1, revision_by='EIcaseR_CASENUMBER3', revision_Date=getdate()
--select  *  from  common_Code
where item_Code='respo'
and  created_by='EIcaseR_CASENUMBER3' 
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update  common_code
set  fac_id=-1, revision_by='EIcaseR_CASENUMBER3', revision_Date=getdate()
---select  *  from  common_Code
where item_Code='dept'
and  created_by='EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update  common_code
set  fac_id=-1
--select  *  from common_code
where item_Code='educa'
and  created_by='EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update  common_code
set  fac_id=-1
--select  *  from common_code
where item_Code='ethnic'
and  created_by='EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update  common_code
set  fac_id=-1, revision_by='EIcaseR_CASENUMBER3', revision_Date=getdate()
--select  *  from  common_Code
where item_Code='phofac'
and  created_by='EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update  common_code
set  fac_id=-1
--select  *  from  common_code
where item_code='inscon'
and  created_by='EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update  common_code
set  fac_id=-1
--select  *  from  common_code
where item_code='plant'
and  created_by='EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update  common_code
set  fac_id=-1
--select  *  from common_code
where item_Code='lang'
and  created_by='EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update  common_code
set  fac_id=-1
--select  *  from common_code
where item_Code='marit'
and  created_by='EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update  common_code
set  fac_id=-1, revision_by='EIcaseR_CASENUMBER3', revision_Date=getdate()
--select  *  from  common_Code
where item_Code='profe'
and  created_by='EIcaseR_CASENUMBER3' 
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update  common_code
set  fac_id=-1
--select  *  from  common_code
where item_code='prefi'
and  created_by='EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update  common_code
set  fac_id=-1, revision_by='EIcaseR_CASENUMBER3', revision_Date=getdate()
--select  *  from  common_Code
where item_Code='proctp'
and  created_by='EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update  common_code
set  fac_id=-1, revision_by='EIcaseR_CASENUMBER3', revision_Date=getdate()
--select  *  from  common_Code
where item_Code='prorel'
and  created_by='EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update  common_code
set  fac_id=-1, revision_by='EIcaseR_CASENUMBER3', revision_Date=getdate()
--select  *  from  common_Code
where item_Code='race'
and  created_by='EIcaseR_CASENUMBER3' 
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update  common_code
set  fac_id=-1
--select  *  from common_code
where item_Code='relig'
and  created_by='EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update  common_code
set  fac_id=-1, revision_by='EIcaseR_CASENUMBER3', revision_Date=getdate()
--select  *  from  common_Code
where item_Code='posit'
and  created_by='EIcaseR_CASENUMBER3' 
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update  common_code
set  fac_id=-1
--select  *  from  common_code
where item_code='suffix'
and  created_by='EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update  common_code
set  fac_id=-1, revision_by='EIcaseR_CASENUMBER3', revision_Date=getdate()
--select  *  from  common_Code
where item_code='Admit'
and  created_by='EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update  common_code
set  fac_id=-1, revision_by='EIcaseR_CASENUMBER3', revision_Date=getdate()
--select  *  from  common_Code
where item_code='dept'
and  created_by='EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update  common_code
set  fac_id=-1, revision_by='EIcaseR_CASENUMBER3', revision_Date=getdate()
--select  *  from  common_Code
where item_Code='rtype'
and  created_by='EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update  common_code
set  fac_id=-1
--select  *  from  common_Code
where item_Code='strke'
and  created_by='EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update  common_code
set  fac_id=-1
--select  *  from  common_Code
where item_Code='wvscal'
and  created_by='EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

update  common_code
set  fac_id=-1
--select  *  from  common_Code
where item_Code='cpclo'
and  created_by='EIcaseR_CASENUMBER3'
and item_id in (select dst_id from EIcaseR_CASENUMBER3common_code 
where src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.common_code where fac_id = -1))

print CHAR(13) + 'scoping for common_code - always - end'

print CHAR(13) + 'scoping for cencus code - always'

update  census_codes
set  fac_id=-1
--select  *  from census_codes
where item_id in (select dst_id from EICaseR_CASENUMBER3census_codes where  corporate='N'
	AND src_id in (select item_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.census_codes where fac_id = -1))
and fac_id <> -1

print CHAR(13) + 'scoping for immunization - always'

update  cr_std_immunization
set  fac_id = -1
--select  *  from dbo.cr_std_immunization
where  created_by='EIcaseR_CASENUMBER3'--0
AND std_immunization_id in (select  dst_id from  EIcaseR_CASENUMBER3cr_std_immunization where corporate='N'
	AND src_id in (select std_immunization_id from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.cr_std_immunization where fac_id = -1))
and fac_id <> -1

print CHAR(13) + 'scoping ended'

--==========================================================================

