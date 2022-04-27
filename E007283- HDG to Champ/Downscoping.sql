-- Common Downscoping requests
-- Update fac_id and case no


--Diagnosis Ranks
update common_code
set  fac_id= 50
--select  *  from common_code
where item_Code='drank'
and  created_by='EIcase0072832'--1
and item_id in (select dst_id from EIcase0072832common_code)


--Diagnosis Classification
update common_code
set  fac_id= 50
--select  *  from common_code
where item_Code='dclas'
and  created_by='EIcase0072832'--1
and item_id in (select dst_id from EIcase0072832common_code)


--Strike Out Picklist
update common_code
set  fac_id= 50
--select  *  from common_code
where item_Code='strke'
and  created_by='EIcase0072832'--1
and item_id in (select dst_id from EIcase0072832common_code)


--Weight Scale types
update common_code
set  fac_id= 50
--select  *  from common_code
where item_Code='wvscal'
and  created_by='EIcase0072832'--1
and item_id in (select dst_id from EIcase0072832common_code)


--Administration Records
update pho_administration_record
set  fac_id= 50
--select  *  from pho_administration_record
where fac_id = -1
and administration_record_id 
in (select dst_id from EIcase0072832pho_administration_record where corporate = 'N')


--Order types
update pho_order_type
set  fac_id= 50
--select  *  from pho_order_type
where fac_id = -1
and order_type_id 
in (select dst_id from EIcase0072832pho_order_type where corporate = 'N')


--Incident Signing Authority
update inc_std_signing_authority
set  fac_id= 50
--select  *  from inc_std_signing_authority
where fac_id = -1
and sign_id 
in (select dst_id from EIcase0072832inc_std_signing_authority where corporate = 'N')


--Immunizations
update cr_std_immunization
set  fac_id= 50
--select  *  from cr_std_immunization
where fac_id = -1
and std_immunization_id 
in (select dst_id from EIcase0072832cr_std_immunization where corporate = 'N')

