-- Common Downscoping requests
-- Update fac_id and case no


--Diagnosis Ranks
update common_code
set  fac_id= 16
--select  *  from common_code
where item_Code='drank'
and  created_by='EIcase00963221'--1
and item_id in (select dst_id from EIcase00963221common_code)


--Diagnosis Classification
update common_code
set  fac_id= 16
--select  *  from common_code
where item_Code='dclas'
and  created_by='EIcase00963221'--1
and item_id in (select dst_id from EIcase00963221common_code)


--Strike Out Picklist
update common_code
set  fac_id= 16
--select  *  from common_code
where item_Code='strke'
and  created_by='EIcase00963221'--1
and item_id in (select dst_id from EIcase00963221common_code)


--Weight Scale types
update common_code
set  fac_id= 16
--select  *  from common_code
where item_Code='wvscal'
and  created_by='EIcase00963221'--1
and item_id in (select dst_id from EIcase00963221common_code)

--Fluid Consistency
update common_code
set  fac_id= 16
--select  *  from common_code
where item_Code='phocst'
and  created_by='EIcase00963221'--1
and item_id in (select dst_id from EIcase00963221common_code)

--Diet Supplement
update common_code
set  fac_id= 16
--select  *  from common_code
where item_Code='phosup'
and  created_by='EIcase00963221'--1
and item_id in (select dst_id from EIcase00963221common_code)

--Diet Texture
update common_code
set  fac_id= 16
--select  *  from common_code
where item_Code='phodtx'
and  created_by='EIcase00963221'--1
and item_id in (select dst_id from EIcase00963221common_code)


--Diet Type
update common_code
set  fac_id= 16
--select  *  from common_code
where item_Code='phodyt'
and  created_by='EIcase00963221'--1
and item_id in (select dst_id from EIcase00963221common_code)


--Administration Records
update pho_administration_record
set  fac_id= 16
--select  *  from pho_administration_record
where fac_id = -1
and administration_record_id 
in (select dst_id from EIcase00963221pho_administration_record where corporate = 'N')


--Order types
update pho_order_type
set  fac_id= 16
--select  *  from pho_order_type
where fac_id = -1
and order_type_id 
in (select dst_id from EIcase00963221pho_order_type where corporate = 'N')


--Incident Signing Authority
update inc_std_signing_authority
set  fac_id= 16
--select  *  from inc_std_signing_authority
where fac_id = -1
and sign_id 
in (select dst_id from EIcase00963221inc_std_signing_authority where corporate = 'N')


--Immunizations
update cr_std_immunization
set  fac_id= 16
--select  *  from cr_std_immunization
where fac_id = -1
and std_immunization_id 
in (select dst_id from EIcase00963221cr_std_immunization where corporate = 'N')

update pn_type
set fac_id = 16
--select * from pn_type
where fac_id = -1
and pn_type_id 
in (select dst_id from EIcase00963221pn_type where corporate = 'N')

update inc_std_pick_list_item
set fac_id = 16
--select * from inc_std_pick_list_item
where fac_id = -1
and pick_list_item_id  
in (select dst_id from EIcase00963221inc_std_pick_list_item where corporate = 'N')


update cp_std_shift
set fac_id = 16
--select * from cp_std_shift
where fac_id = -1
and std_shift_id  
in (select dst_id from EIcase00963221cp_std_shift where corporate = 'N')
