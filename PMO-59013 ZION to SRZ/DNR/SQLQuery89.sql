/*
1.	Diagnosis rank 
2.	Diagnosis classification 
3.	Weight scale types 
4.	Documentation strike out picklist
5.	Administration records 
6.	Order types

*/




--29
select  *  from common_code
where item_Code in('drank','dclas','wvscal','strke')
and fac_id=-1
and created_by='EICase590131'
and item_id in (select dst_id from EIcase590131common_code
where  src_id  in(
select src_item_id from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_Clinical_common_code$]
where src_item_id is not null
and Map_dstitemid is null
and if_merged<>'Y'
and item_Code in('drank','dclas','wvscal','strke')
))

---32
select  *  from common_code
where item_Code in('drank','dclas','wvscal','strke')
and fac_id=-1
and created_by='EICase590132'
and item_id in (select dst_id from EIcase590132common_code
where  src_id  in(
select src_item_id from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_Clinical_common_code$]
where src_item_id is not null
and Map_dstitemid is null
and if_merged<>'Y'
and item_Code in('drank','dclas','wvscal','strke')
))




--Administration Records
update pho_administration_record
set  fac_id= 29
--select  *  from pho_administration_record
where fac_id = -1
and administration_record_id 
in(
select dst_id from EIcase590131pho_administration_record 
where 1=1
and src_id is not null
and src_id in(
select src_id from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_Clinical_Advanced$]
where src_id is not null
and dst_id is  null
and pick_list_name ='Administration Records'
)
)

update pho_administration_record
set  fac_id= 32
--select  *  from pho_administration_record
where fac_id = -1
and administration_record_id 
in(
select dst_id from EIcase590132pho_administration_record 
where 1=1
and src_id is not null
and src_id in(
select src_id from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_Clinical_Advanced$]
where src_id is not null
and dst_id is  null
and pick_list_name ='Administration Records'
)
)



--- ordertypes
select  *  from pho_order_type
where fac_id = -1
and order_type_id 
in(
select dst_id from EIcase590131pho_order_type 
where 1=1
and src_id is not null
and src_id in(
select src_id from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_Clinical_Advanced$]
where src_id is not null
and dst_id is  null
and pick_list_name ='Order types'
)
)




select  *  from pho_order_type
where fac_id = -1
and order_type_id 
in(
select dst_id from EIcase590132pho_order_type 
where 1=1
and src_id is not null
and src_id in(
select src_id from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_Clinical_Advanced$]
where src_id is not null
and dst_id is  null
and pick_list_name ='Order types'
)
)





select * from EIcase590131pho_administration_record 
where corporate='N'