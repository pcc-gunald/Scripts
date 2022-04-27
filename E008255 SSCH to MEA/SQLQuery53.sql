select * from pn_type
where created_by='EICase0082551'

sp_help pn_type

update pn_type
set description='zSSCH_'+description
where created_by='EICase0082551'

update b
set description='zSSCH_'+b.description
from pcc_staging_db008255.dbo.pho_order_type a
inner join pho_order_type b on b.order_type_id=a.order_type_id


update b
set description='zSSCH_'+b.description
from pcc_staging_db008255.dbo.pn_type a
inner join pn_type b on b.pn_type_id=a.pn_type_id
where b.description not like 'zSSCH_%'


update b
set template_description='BEHAVIOR MONITOR- DOCUMENT # OF EPISODES OF __________________ BEHAVIOR QSHIFT WITH HASHMARKS. T'
from pcc_staging_db008255.dbo.pho_std_order a
inner join pho_std_order b on b.std_order_id=a.std_order_id
where b.template_description ='BEHAVIOR MONITOR- DOCUMENT # OF EPISODES OF ______________________ BEHAVIOR QSHIFT WITH HASHMARKS. T'

update b
set template_description=LEFT('zSSCH_'+b.template_description,100)
from pcc_staging_db008255.dbo.pho_std_order a
inner join pho_std_order b on b.std_order_id=a.std_order_id
where b.template_description not like 'zSSCH_%'


update b
set set_description='zSSCH_'+b.set_description
from pcc_staging_db008255.dbo.pho_std_order_set a
inner join pho_std_order_set b on b.std_order_set_id=a.std_order_set_id
where b.set_description not like 'zSSCH_%'



select * from pcc_staging_db008255.dbo.pho_order_type a
inner join pho_order_type b on b.order_type_id=a.order_type_id



select * from pcc_staging_db008255.dbo.pho_order_type a
inner join pho_order_type b on b.order_type_id=a.order_type_id


select * from pcc_staging_db008255.dbo.pho_std_order a
inner join pho_std_order b on b.std_order_id=a.std_order_id


select * from pcc_staging_db008255.dbo.pho_std_order_set a
inner join pho_std_order_set b on b.std_order_set_id=a.std_order_set_id


select * from INFORMATION_SCHEMA.TABLES
where table_name like '%templ%'
and table_name like '%ph%'

select * from pho_schedule_template

select LEFT('zSSCH_'+b.template_description,100),*  from pcc_staging_db008255.dbo.pho_std_order a
inner join pho_std_order b on b.std_order_id=a.std_order_id
where b.template_description not like 'zSSCH_%'
and b.template_description like 'BEHAVIOR MONITOR%'
