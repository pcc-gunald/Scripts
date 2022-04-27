Select * from cr_std_immunization order by created_date  desc

Select * from pn_type where created_by='EICase01079812' 
and description  like 'zSRZ-%'order by created_date  desc

update pn_type
set description='zSRZ-'+description
where created_by='EICase01079812'
and len(description)<71

(339 rows affected)

update pn_type
set description='zSRZ'+description
where created_by='EICase01079812'
 and description not like 'zSRZ-%'
 (2 rows affected)
Select  len(description) from pn_type where created_by='EICase01079812'  order by 1

Select * from EICase01079812pho_std_order where corporate='N'
Select * from EICase01079813pho_std_order where corporate='N'
Select * from pho_std_order where std_order_id in (Select dst_id from EICase01079812pho_std_order where corporate='N')

Select * from pho_std_order where std_order_id in (Select dst_id from EICase01079812pho_std_order where corporate='N')
and len(template_description) in (99,100)
order by 1

update pho_std_order
set template_description='z'+template_description
where std_order_id in (Select dst_id from EICase01079812pho_std_order where corporate='N')

Select * from EICase01079812pho_std_order_set  where corporate='N'
Select * from EICase01079813pho_std_order_set  where corporate='N'
Select * from pho_std_order_set where std_order_set_id in (Select dst_id from EICase01079812pho_std_order_set where corporate='N')
 and len(set_description) in (99,100)
