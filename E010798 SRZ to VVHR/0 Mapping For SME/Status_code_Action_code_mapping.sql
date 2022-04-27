--tablename	idField	tableorder	scopeField1	scopeField2
--census_codes	item_id	4550	table_code	short_desc


--select * from [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi.dbo.facility with (nolock) where fac_id = 45

--select * from [pccsql-use2-prod-w20-cli0017.3055e0bc69f6.database.windows.net].us_vvhr.dbo.facility with (nolock) where fac_id = 216

---------------------
--Action Codes
---------------------
--src
select item_id as src_item_id , short_desc as src_short_desc, long_desc as src_long_desc
from [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi.dbo.census_codes with (nolock)
where (fac_id in (-1,7,8)  --src fac_id
	or reg_id in (select regional_id from [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi.dbo.facility with (nolock) 
		where fac_id in (7,8) and regional_id is not null)) --src fac_id
AND deleted = 'N'
AND table_code = 'ACT'
AND item_id in  
		((SELECT isnull(action_code_id,-1) FROM [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi.[dbo].census_item with (nolock) 
		WHERE fac_id in (7,8) AND DELETED = 'N')  --src fac_id
		UNION 
		(SELECT isnull(STATUS_CODE_ID,-1) FROM [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi.[dbo].census_item with (nolock) 
		WHERE fac_id in (7,8) AND DELETED = 'N')) --src fac_id
order by 2

--dst
select item_id as dst_item_id, short_desc as dst_short_desc, long_desc as dst_long_desc 
from [pccsql-use2-prod-w20-cli0017.3055e0bc69f6.database.windows.net].us_vvhr.dbo.census_codes with (nolock)
where (fac_id in (-1,12,13) --dst fac_id
	or reg_id in (select regional_id from [pccsql-use2-prod-w20-cli0017.3055e0bc69f6.database.windows.net].us_vvhr.dbo.facility with (nolock) 
		where fac_id in (12,13) and regional_id is not null)  --dst fac_id
	or state_code in (select prov from [pccsql-use2-prod-w20-cli0017.3055e0bc69f6.database.windows.net].us_vvhr.dbo.facility with (nolock) 
		where fac_id in (12,13) and prov is not null)  --dst fac_id
    )
AND deleted = 'N'
AND table_code = 'ACT'
order by 2


---------------------
--Status Codes
---------------------
--src
select item_id as src_item_id , short_desc as src_short_desc, long_desc as src_long_desc
from [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi.dbo.census_codes with (nolock)
where (fac_id in (-1,7,8) --src fac_id
	or reg_id in (select regional_id from [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi.dbo.facility with (nolock) 
		where fac_id in (7,8) and regional_id is not null))--src fac_id
AND deleted = 'N'
AND table_code = 'SC'
AND item_id in  
		((SELECT isnull(action_code_id,-1) FROM [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi.[dbo].census_item with (nolock) 
		WHERE fac_id in (7,8) AND DELETED = 'N')  --src fac_id
		UNION 
		(SELECT isnull(STATUS_CODE_ID,-1) FROM [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi.[dbo].census_item with (nolock) 
		WHERE fac_id in (7,8) AND DELETED = 'N')) --src fac_id
order by 2

--dst
select item_id as dst_item_id, short_desc as dst_short_desc, long_desc as dst_long_desc
from [pccsql-use2-prod-w20-cli0017.3055e0bc69f6.database.windows.net].us_vvhr.dbo.census_codes with (nolock)
where (fac_id in (-1,12,13) --dst fac_id
	or reg_id in (select regional_id from [pccsql-use2-prod-w20-cli0017.3055e0bc69f6.database.windows.net].us_vvhr.dbo.facility with (nolock) 
		where fac_id in (12,13) and regional_id is not null)  --dst fac_id
	or state_code in (select prov from [pccsql-use2-prod-w20-cli0017.3055e0bc69f6.database.windows.net].us_vvhr.dbo.facility with (nolock) 
		where fac_id in (12,13) and regional_id is not null)  --dst fac_id
    )
AND deleted = 'N'
AND table_code = 'SC'
order by 2


--(24 rows affected)

--(12 rows affected)

--(10 rows affected)

--(17 rows affected)