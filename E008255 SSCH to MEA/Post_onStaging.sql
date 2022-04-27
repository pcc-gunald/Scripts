SET CONTEXT_INFO 0xDC1000000;
SET DEADLOCK_PRIORITY 4;
SET QUOTED_IDENTIFIER ON;

update b
set description='zSSCH_'+b.description
from pcc_staging_db008255.dbo.pn_type b
where b.description not like 'zSSCH_%'

update b
set template_description='BEHAVIOR MONITOR- DOCUMENT # OF EPISODES OF __________________ BEHAVIOR QSHIFT WITH HASHMARKS. T'
from pcc_staging_db008255.dbo.pho_std_order b
where b.template_description ='BEHAVIOR MONITOR- DOCUMENT # OF EPISODES OF ______________________ BEHAVIOR QSHIFT WITH HASHMARKS. T'

update b
set template_description=LEFT('zSSCH_'+b.template_description,100)
from pcc_staging_db008255.dbo.pho_std_order b
where b.template_description not like 'zSSCH_%'


update b
set set_description='zSSCH_'+b.set_description
from pcc_staging_db008255.dbo.pho_std_order_set b
where b.set_description not like 'zSSCH_%'