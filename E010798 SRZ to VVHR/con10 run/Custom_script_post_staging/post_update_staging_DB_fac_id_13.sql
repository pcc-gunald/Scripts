

  --------------Immunizations

update cr_std_immunization
set  fac_id=13
--------select  *  from cr_std_immunization
where created_by='EICase01079813'
and std_immunization_id in (select dst_id from EIcase01079813cr_std_immunization ) 
and fac_id =-1
and Multi_Fac_Id=13

	UPDATE src
SET src.contact_number = '0' + src.contact_number
----------SELECT src.contact_number, *
FROM pcc_staging_db010798.dbo.contact AS src
    INNER JOIN [pccsql-use2-prod-w20-cli0017.3055e0bc69f6.database.windows.net].us_vvhr.dbo.contact AS dst ON src.contact_number = dst.contact_number
	and src.created_by<>'EICase01079812'


--------------Admin Record
------------update pho_administration_record
------------set fac_id = 217
-------------------select * from pho_administration_record
------------where administration_record_id  in (select dst_Id from EIcase01079813pho_administration_record WHERE corporate = 'N')
------------and deleted='N'
------------AND fac_id = -1 
------------and Multi_Fac_Id=217
	

--------------Order Type

------------UPDATE pho_order_type
------------SET fac_id = 217
-------------------select * from pho_order_type
------------WHERE order_type_id IN (SELECT dst_id FROM EIcase01079813pho_order_type	WHERE corporate = 'N')
------------AND fac_id = -1 
------------and Multi_Fac_Id=217


--------------------progress note type
------------update pn_type
------------set  fac_id=217
--------------------select  *  from pn_type
------------where created_by='EICase01079813'
------------and pn_type_id in (select dst_id from EIcase01079813pn_type ) 
------------and fac_id =-1
------------and Multi_Fac_Id=217


--------------------Immunizations

------------update cr_std_immunization
------------set  fac_id=217
--------------------select  *  from cr_std_immunization
------------where created_by='EICase01079813'
------------and std_immunization_id in (select dst_id from EIcase01079813cr_std_immunization ) 
------------and fac_id =-1
------------and Multi_Fac_Id=217


------------------Standard Shifts
 
------------update cp_std_shift
------------set  fac_id=217
--------------------select  *  from cp_std_shift
------------where created_by='EICase01079813'
------------and std_shift_id in (select dst_id from EIcase01079813cp_std_shift ) 
------------and fac_id =-1
------------and Multi_Fac_Id=217


---------------------cpclo	Reasons for Care Plan Closure
------------update common_code
------------set  fac_id=217
--------------------select  *  from common_code
------------where created_by='EICase01079813'
------------and item_id in (select dst_id from EIcase01079813common_code ) 
------------and item_code='cpclo'
------------and fac_id =-1
------------and Multi_Fac_Id=217


------------------dclas	Diagnosis Classification
------------update common_code
------------set  fac_id=217
--------------------select  *  from common_code
------------where created_by='EICase01079813'
------------and item_id in (select dst_id from EIcase01079813common_code ) 
------------and item_code='dclas'
------------and fac_id =-1
------------and Multi_Fac_Id=217

------------------phocst	Fluid Consistency

------------update common_code
------------set  fac_id=217
--------------------select  *  from common_code
------------where created_by='EICase01079813'
------------and item_id in (select dst_id from EIcase01079813common_code ) 
------------and item_code='phocst'
------------and fac_id =-1
------------and Multi_Fac_Id=217


----------------------phodtx	Diet Texture

------------update common_code
------------set  fac_id=217
--------------------select  *  from common_code
------------where created_by='EICase01079813'
------------and item_id in (select dst_id from EIcase01079813common_code ) 
------------and item_code='phodtx'
------------and fac_id =-1
------------and Multi_Fac_Id=217
------------and DELETED_BY is null

------------------phodyt	Diet Type
------------update common_code
------------set  fac_id=217
--------------------select  *  from common_code
------------where created_by='EICase01079813'
------------and item_id in (select dst_id from EIcase01079813common_code ) 
------------and item_code='phodyt'
------------and fac_id =-1
------------and Multi_Fac_Id=217
------------and DELETED_BY is null

------------------phosup	Diet Supplement
------------update common_code
------------set  fac_id=217
--------------------select  *  from common_code
------------where created_by='EICase01079813'
------------and item_id in (select dst_id from EIcase01079813common_code ) 
------------and item_code='phosup'
------------and fac_id =-1
------------and Multi_Fac_Id=217
------------and DELETED_BY is null

--------------------strke	Documentation Strike Out

------------update common_code
------------set  fac_id=217
--------------------select  *  from common_code
------------where created_by='EICase01079813'
------------and item_id in (select dst_id from EIcase01079813common_code ) 
------------and item_code='strke'
------------and fac_id =-1
------------and Multi_Fac_Id=217
------------and DELETED_BY is null


--------------------wvscal	Weight Scale Types


------------update common_code
------------set  fac_id=217
--------------------select  *  from common_code
------------where created_by='EICase01079813'
------------and item_id in (select dst_id from EIcase01079813common_code ) 
------------and item_code='wvscal'
------------and fac_id =-1
------------and Multi_Fac_Id=217
------------and DELETED_BY is null
