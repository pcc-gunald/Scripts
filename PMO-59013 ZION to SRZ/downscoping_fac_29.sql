
--Diagnosis Ranks
update common_code
set  fac_id= 29
--select  *  from common_code
where item_Code='drank'
and  created_by='EIcase590131'--1
and item_id in (select dst_id from EIcase590131common_code)


--Diagnosis Classification
update common_code
set  fac_id= 29
--select  *  from common_code
where item_Code='dclas'
and  created_by='EIcase590131'--1
and item_id in (select dst_id from EIcase590131common_code)


--Strike Out Picklist
update common_code
set  fac_id= 29
--select  *  from common_code
where item_Code='strke'
and  created_by='EIcase590131'--1
and item_id in (select dst_id from EIcase590131common_code)


--Weight Scale types
update common_code
set  fac_id= 29
--select  *  from common_code
where item_Code='wvscal'
and  created_by='EIcase590131'--1
and item_id in (select dst_id from EIcase590131common_code)


--Administration Records
update pho_administration_record
set  fac_id= 29
--select  *  from pho_administration_record
where fac_id = -1
and administration_record_id 
in (select dst_id from EIcase590131pho_administration_record where corporate = 'N')


--Order types
update pho_order_type
set  fac_id= 29
--select  *  from pho_order_type
where fac_id = -1
and order_type_id 
in (select dst_id from EIcase590131pho_order_type where corporate = 'N')