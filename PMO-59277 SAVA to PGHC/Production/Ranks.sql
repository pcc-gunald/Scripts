select * from common_code
where item_description like '%Secondary%'

Select * from EICASE59277183common_code
where src_id In  (10114,10116,10118,10153,10155)

Select * from common_code
where item_id IN  (66451,66452,66453,66466,66467)

Select * from diagnosis
where rank_id  = 66452--9609
and fac_id = 173--979

Begin TRAN

Update diagnosis
Set rank_id = 9609
where rank_id  = 66452--9609
and fac_id = 173--979

Rollback


Select * from common_code
where item_code = 'drank'


Select * from clients
where client_id  = 29373066
 

 select * from common_code_activation

Update common_code
Set deleted = 'Y'
where item_id = 66452


select * from mergejoinsmaster
where parenttable  = 'common_code'
--diagnosis