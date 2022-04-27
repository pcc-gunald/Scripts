--tablename	idField	tableorder	scopeField1	scopeField2
--census_codes	item_id	4550	table_code	short_desc
--test_usei121
--test_usei123

--select * from test_usei123.dbo.facility

--select * from test_usei121.dbo.facility

---------------------
--Action Codes
---------------------
--src
select long_desc as src_long_desc, short_desc as src_short_desc, item_id as src_item_id, fac_id 
from [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.census_codes
where fac_id in (-1,183)
and deleted='N'
and table_code ='ACT'
order by 2

--dst
select item_id as dst_item_id, short_desc as dst_short_desc, long_desc as dst_long_desc, fac_id 
from [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].[us_pghc_multi].dbo.census_codes
where fac_id in (-1,173)
and deleted='N'
and table_code ='ACT'
order by 2


---------------------
--Status Codes
---------------------
--src
select long_desc as src_long_desc, short_desc as src_short_desc, item_id as src_item_id, fac_id 
from [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.census_codes
where fac_id in (-1,183)
and deleted='N'
and table_code ='SC'
order by 2

--dst
select item_id as dst_item_id,short_desc as dst_short_desc, long_desc as dst_long_desc, fac_id  
from [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].[us_pghc_multi].dbo.census_codes
where fac_id in (-1,173)
and deleted='N'
and table_code ='SC'
order by 2