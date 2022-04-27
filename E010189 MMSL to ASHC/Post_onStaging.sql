update b
set description='zMMSL_'+b.description
from pcc_staging_db008255.dbo.pn_type b
where b.description not like 'zMMSL_%'



update b
set template_description=LEFT('zMMSL_'+b.template_description,100)
from pcc_staging_db008255.dbo.pho_std_order b
where b.template_description not like 'zMMSL_%'


update b
set set_description='zMMSL_'+b.set_description
from pcc_staging_db008255.dbo.pho_std_order_set b
where b.set_description not like 'zMMSL_%'