--------Admin Record
update pho_administration_record
set fac_id = 219
-------select * from pho_administration_record
where administration_record_id  in (select dst_Id from EIcase010798219pho_administration_record WHERE corporate = 'N')
and deleted='N'
AND fac_id = -1 
and Multi_Fac_Id=219
	

--------Order Type

UPDATE pho_order_type
SET fac_id = 219
-------select * from pho_order_type
WHERE order_type_id IN (SELECT dst_id FROM EIcase010798219pho_order_type	WHERE corporate = 'N')
AND fac_id = -1 
and Multi_Fac_Id=219


--------progress note type
update pn_type
set  fac_id=219
--------select  *  from pn_type
where created_by='EICase010798219'
and pn_type_id in (select dst_id from EIcase010798219pn_type ) 
and fac_id =-1
and Multi_Fac_Id=219


--------Immunizations

update cr_std_immunization
set  fac_id=219
--------select  *  from cr_std_immunization
where created_by='EICase010798219'
and std_immunization_id in (select dst_id from EIcase010798219cr_std_immunization ) 
and fac_id =-1
and Multi_Fac_Id=219


------Standard Shifts


update cp_std_shift
set  fac_id=219
--------select  *  from cp_std_shift
where created_by='EICase010798219'
and std_shift_id in (select dst_id from EIcase010798219cp_std_shift ) 
and fac_id =-1
and Multi_Fac_Id=219


---------cpclo	Reasons for Care Plan Closure
update common_code
set  fac_id=219
--------select  *  from common_code
where created_by='EICase010798219'
and item_id in (select dst_id from EIcase010798219common_code ) 
and item_code='cpclo'
and fac_id =-1
and Multi_Fac_Id=219


------dclas	Diagnosis Classification
update common_code
set  fac_id=219
--------select  *  from common_code
where created_by='EICase010798219'
and item_id in (select dst_id from EIcase010798219common_code ) 
and item_code='dclas'
and fac_id =-1
and Multi_Fac_Id=219

------phocst	Fluid Consistency

update common_code
set  fac_id=219
--------select  *  from common_code
where created_by='EICase010798219'
and item_id in (select dst_id from EIcase010798219common_code ) 
and item_code='phocst'
and fac_id =-1
and Multi_Fac_Id=219


----------phodtx	Diet Texture

update common_code
set  fac_id=219
--------select  *  from common_code
where created_by='EICase010798219'
and item_id in (select dst_id from EIcase010798219common_code ) 
and item_code='phodtx'
and fac_id =-1
and Multi_Fac_Id=219
and DELETED_BY is null

------phodyt	Diet Type
update common_code
set  fac_id=219
--------select  *  from common_code
where created_by='EICase010798219'
and item_id in (select dst_id from EIcase010798219common_code ) 
and item_code='phodyt'
and fac_id =-1
and Multi_Fac_Id=219
and DELETED_BY is null

------phosup	Diet Supplement
update common_code
set  fac_id=219
--------select  *  from common_code
where created_by='EICase010798219'
and item_id in (select dst_id from EIcase010798219common_code ) 
and item_code='phosup'
and fac_id =-1
and Multi_Fac_Id=219
and DELETED_BY is null

--------strke	Documentation Strike Out

update common_code
set  fac_id=219
--------select  *  from common_code
where created_by='EICase010798219'
and item_id in (select dst_id from EIcase010798219common_code ) 
and item_code='strke'
and fac_id =-1
and Multi_Fac_Id=219
and DELETED_BY is null


--------wvscal	Weight Scale Types


update common_code
set  fac_id=219
--------select  *  from common_code
where created_by='EICase010798219'
and item_id in (select dst_id from EIcase010798219common_code ) 
and item_code='wvscal'
and fac_id =-1
and Multi_Fac_Id=219
and DELETED_BY is null
