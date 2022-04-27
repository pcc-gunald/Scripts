select * from pho_administration_record
order by 1 




select count(1) from pcc_staging_db008679.dbo.cr_shift_group a 
inner join [us_symme_multi].dbo.cr_shift_group b on b.shift_group_id=a.shift_group_id
where  a.administration_record_id=15 

select count(1) from pcc_staging_db008679.dbo.pho_assignment_group_assoc a 
inner join [us_symme_multi].dbo.pho_assignment_group_assoc b on b.pho_assignment_group_assoc_id=a.pho_assignment_group_assoc_id
where  a.administration_record_id=15 

select count(1) from pcc_staging_db008679.dbo.pho_order_type a  
inner join [us_symme_multi].dbo.pho_order_type b on b.order_type_id=a.order_type_id
where  a.administration_record_id=15 

select count(1) from pcc_staging_db008679.dbo.pho_order_type a  
inner join  [us_symme_multi].dbo.pho_order_type b on b.order_type_id=a.order_type_id
where  a.administration_record_id=15 



select b.*
into  pcc_temp_storage.dbo.symme_008679_cr_shift_group
from pcc_staging_db008679.dbo.cr_shift_group a 
inner join [us_symme_multi].dbo.cr_shift_group b on b.shift_group_id=a.shift_group_id
where  a.administration_record_id=15 

select b.* 
into pcc_temp_storage.dbo.symme_008679_pho_assignment_group_assoc
from pcc_staging_db008679.dbo.pho_assignment_group_assoc a 
inner join [us_symme_multi].dbo.pho_assignment_group_assoc b on b.pho_assignment_group_assoc_id=a.pho_assignment_group_assoc_id
where  a.administration_record_id=15 




select b.*
into  pcc_temp_storage.dbo.symme_008679_pho_order_type
from pcc_staging_db008679.dbo.pho_order_type a  
inner join  [us_symme_multi].dbo.pho_order_type b on b.order_type_id=a.order_type_id
where  a.administration_record_id=15 


select b.*
into  pcc_temp_storage.dbo.symme_008679_pho_order_type_alt_administration_record_id
from pcc_staging_db008679.dbo.pho_order_type a  
inner join  [us_symme_multi].dbo.pho_order_type b on b.order_type_id=a.order_type_id
where  a.alt_administration_record_id=15 




update  b
set administration_record_id=36
--select count(1) 
from pcc_staging_db008679.dbo.cr_shift_group a 
inner join [us_symme_multi].dbo.cr_shift_group b on b.shift_group_id=a.shift_group_id
where  a.administration_record_id=15 

update  b
set administration_record_id=36
--select count(1) 
from pcc_staging_db008679.dbo.pho_assignment_group_assoc a 
inner join [us_symme_multi].dbo.pho_assignment_group_assoc b on b.pho_assignment_group_assoc_id=a.pho_assignment_group_assoc_id
where  a.administration_record_id=15 

update  b
set administration_record_id=36
--select count(1)  
from pcc_staging_db008679.dbo.pho_order_type a  
inner join [us_symme_multi].dbo.pho_order_type b on b.order_type_id=a.order_type_id
where  a.administration_record_id=15 

update  b
set alt_administration_record_id=36
--select count(1) 
from pcc_staging_db008679.dbo.pho_order_type a  
inner join  [us_symme_multi].dbo.pho_order_type b on b.order_type_id=a.order_type_id
where  a.alt_administration_record_id=15 