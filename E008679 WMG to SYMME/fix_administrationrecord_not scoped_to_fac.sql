select * from pho_administration_record

select * from pho_order_type
where fac_id=7


select * from eicase00867914pho_order_type

select concat('select count(1) from pcc_staging_db008679_1.dbo.',tablename,' a 
where  a.administration_record_id=15 '),* from mergeJoinsMaster
where parenttable='pho_administration_record'

select * from [pccsql-use2-prod-ssv-tscon11.b4ea653240a9.database.windows.net].[test_usei1129].dbo.pho_administration_record

select * from test_usei1018.dbo.pho_administration_record
order by 1

select * from test_usei1018.dbo.facility
order by 1

select * from [pccsql-use2-prod-ssv-tscon11.b4ea653240a9.database.windows.net].[test_usei1129].dbo.facility
where fac_id in(14,15)

select * from EICase00867914pho_administration_record

select * from EICase00867915pho_administration_record

select * from pcc_staging_db008679_1.dbo.cr_shift_group a
where a.administration_record_id=15


select count(1) from pcc_staging_db008679_1.dbo.cr_shift_group a 
inner join [test_usei1018].dbo.cr_shift_group b on b.shift_group_id=a.shift_group_id
where  a.administration_record_id=15 
select count(1) from pcc_staging_db008679_1.dbo.pho_assignment_group_assoc a 
inner join [test_usei1018].dbo.pho_assignment_group_assoc b on b.pho_assignment_group_assoc_id=a.pho_assignment_group_assoc_id
where  a.administration_record_id=15 
select count(1) from pcc_staging_db008679_1.dbo.pho_order_type a  
inner join [test_usei1018].dbo.pho_order_type b on b.order_type_id=a.order_type_id
where  a.administration_record_id=15 
select count(1) from pcc_staging_db008679_1.dbo.pho_order_type a  
inner join  [test_usei1018].dbo.pho_order_type b on b.order_type_id=a.order_type_id
where  a.administration_record_id=15 



pcc_temp_storage.dbo.symme_008679_
select b.*
into  pcc_temp_storage.dbo.symme_008679_cr_shift_group
from pcc_staging_db008679_1.dbo.cr_shift_group a 
inner join [test_usei1018].dbo.cr_shift_group b on b.shift_group_id=a.shift_group_id
where  a.administration_record_id=15 

select b.* 
into pcc_temp_storage.dbo.symme_008679_pho_assignment_group_assoc
from pcc_staging_db008679_1.dbo.pho_assignment_group_assoc a 
inner join [test_usei1018].dbo.pho_assignment_group_assoc b on b.pho_assignment_group_assoc_id=a.pho_assignment_group_assoc_id
where  a.administration_record_id=15 


select b.*
into  pcc_temp_storage.dbo.symme_008679_cr_shift_group
from pcc_staging_db008679_1.dbo.pho_order_type a  
inner join [test_usei1018].dbo.pho_order_type b on b.order_type_id=a.order_type_id
where  a.administration_record_id=15 

select b.*
into  pcc_temp_storage.dbo.symme_008679_pho_order_type
from pcc_staging_db008679_1.dbo.pho_order_type a  
inner join  [test_usei1018].dbo.pho_order_type b on b.order_type_id=a.order_type_id
where  a.administration_record_id=15 


select b.*
into  pcc_temp_storage.dbo.symme_008679_pho_order_type_alt_administration_record_id
from pcc_staging_db008679_1.dbo.pho_order_type a  
inner join  [test_usei1018].dbo.pho_order_type b on b.order_type_id=a.order_type_id
where  a.alt_administration_record_id=15 




update  b
set administration_record_id=41
--select count(1) 
from pcc_staging_db008679_1.dbo.cr_shift_group a 
inner join [test_usei1018].dbo.cr_shift_group b on b.shift_group_id=a.shift_group_id
where  a.administration_record_id=15 

update  b
set administration_record_id=41
--select count(1) 
from pcc_staging_db008679_1.dbo.pho_assignment_group_assoc a 
inner join [test_usei1018].dbo.pho_assignment_group_assoc b on b.pho_assignment_group_assoc_id=a.pho_assignment_group_assoc_id
where  a.administration_record_id=15 

update  b
set administration_record_id=41
--select count(1)  
from pcc_staging_db008679_1.dbo.pho_order_type a  
inner join [test_usei1018].dbo.pho_order_type b on b.order_type_id=a.order_type_id
where  a.administration_record_id=15 

update  b
set alt_administration_record_id=41
--select count(1) 
from pcc_staging_db008679_1.dbo.pho_order_type a  
inner join  [test_usei1018].dbo.pho_order_type b on b.order_type_id=a.order_type_id
where  a.alt_administration_record_id=15 



select * from  [test_usei1018].dbo.pho_order_type a
where a.fac_id=7




select * from  [test_usei1021].dbo.pho_order_type a
where a.fac_id=7
