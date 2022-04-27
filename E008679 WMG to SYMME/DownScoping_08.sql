update  census_codes
set fac_id=8
where fac_id = -1
and created_by='EICase00867915'
and item_id
in (select dst_id from EIcase00867915census_codes where corporate = 'N')



update  census_codes
set fac_id=8
where fac_id = -1
and created_by='EICase00867915'
and item_id
in (select dst_id from EICase00867915census_codes where corporate = 'N')


--Diagnosis classification, Diagnosis ranks, Administration records and Order types,

--Diagnosis Ranks
update common_code
set  fac_id= 8
--select  *  from common_code
where item_Code='drank'
and  created_by='EICase00867915'--1
and item_id in (select dst_id from EICase00867915common_code)


--Diagnosis Classification
update common_code
set  fac_id= 8
--select  *  from common_code
where item_Code='dclas'
and  created_by='EICase00867915'--1
and item_id in (select dst_id from EICase00867915common_code)


--Strike Out Picklist
update common_code
set  fac_id= 8
--select  *  from common_code
where item_Code='strke'
and  created_by='EICase00867915'--1
and item_id in (select dst_id from EICase00867915common_code)




--Administration Records
update pho_administration_record
set  fac_id= 8
--select  *  from pho_administration_record
where fac_id = -1
and administration_record_id 
in (select dst_id from EICase00867915pho_administration_record where corporate = 'N')


--Order types
update pho_order_type
set  fac_id= 8
--select  *  from pho_order_type
where fac_id = -1
and order_type_id 
in (select dst_id from EICase00867915pho_order_type where corporate = 'N')

