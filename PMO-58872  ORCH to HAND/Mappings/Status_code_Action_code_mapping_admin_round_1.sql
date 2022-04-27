--tablename	idField	tableorder	scopeField1	scopeField2
--census_codes	item_id	4550	table_code	short_desc


--select * from [pccsql-use2-prod-w27-cli0023.851c37dfbe45.database.windows.net].[us_orch_multi].facility with (nolock) where fac_id = 8

--select * from [pccsql-use2-prod-w24-cli0023.ce22455c967a.database.windows.net].[us_hand_multi].dbo.facility with (nolock) where fac_id = 9

---------------------
--Action Codes
---------------------
--src
select long_desc as src_long_desc, short_desc as src_short_desc, item_id as src_item_id 
from [pccsql-use2-prod-w27-cli0023.851c37dfbe45.database.windows.net].[us_orch_multi].dbo.census_codes with (nolock)
where (fac_id in (-1,6)  --src fac_id
	or reg_id in (select regional_id from [pccsql-use2-prod-w27-cli0023.851c37dfbe45.database.windows.net].[us_orch_multi].dbo.facility with (nolock) 
		where fac_id in (2) and regional_id is not null)) --src fac_id
AND deleted = 'N'
AND table_code = 'ACT'
AND item_id in  
		((SELECT isnull(action_code_id,-1) FROM [pccsql-use2-prod-w27-cli0023.851c37dfbe45.database.windows.net].[us_orch_multi].[dbo].census_item with (nolock) 
		WHERE fac_id in (6) AND DELETED = 'N')  --src fac_id
		UNION 
		(SELECT isnull(STATUS_CODE_ID,-1) FROM [pccsql-use2-prod-w27-cli0023.851c37dfbe45.database.windows.net].[us_orch_multi].[dbo].census_item with (nolock) 
		WHERE fac_id in (6) AND DELETED = 'N')) --src fac_id
order by 2

--dst
select item_id as dst_item_id, short_desc as dst_short_desc, long_desc as dst_long_desc 
from [pccsql-use2-prod-w24-cli0023.ce22455c967a.database.windows.net].[us_hand_multi].dbo.census_codes with (nolock)
where (fac_id in (-1,68) --dst fac_id
	or reg_id in (select regional_id from [pccsql-use2-prod-w24-cli0023.ce22455c967a.database.windows.net].[us_hand_multi].dbo.facility with (nolock) 
		where fac_id in (68) and regional_id is not null)  --dst fac_id
	or state_code in (select prov from [pccsql-use2-prod-w24-cli0023.ce22455c967a.database.windows.net].[us_hand_multi].dbo.facility with (nolock) 
		where fac_id in (68) and prov is not null)  --dst fac_id
    )
AND deleted = 'N'
AND table_code = 'ACT'
order by 2


---------------------
--Status Codes
---------------------
--src
select long_desc as src_long_desc, short_desc as src_short_desc, item_id as src_item_id 
from [pccsql-use2-prod-w27-cli0023.851c37dfbe45.database.windows.net].[us_orch_multi].dbo.census_codes with (nolock)
where (fac_id in (-1,2) --src fac_id
	or reg_id in (select regional_id from [pccsql-use2-prod-w27-cli0023.851c37dfbe45.database.windows.net].[us_orch_multi].dbo.facility with (nolock) 
		where fac_id in (6) and regional_id is not null))--src fac_id
AND deleted = 'N'
AND table_code = 'SC'
AND item_id in  
		((SELECT isnull(action_code_id,-1) FROM [pccsql-use2-prod-w27-cli0023.851c37dfbe45.database.windows.net].[us_orch_multi].[dbo].census_item with (nolock) 
		WHERE fac_id in (6) AND DELETED = 'N')  --src fac_id
		UNION 
		(SELECT isnull(STATUS_CODE_ID,-1) FROM [pccsql-use2-prod-w27-cli0023.851c37dfbe45.database.windows.net].[us_orch_multi].[dbo].census_item with (nolock) 
		WHERE fac_id in (6) AND DELETED = 'N')) --src fac_id
order by 2

--dst
select item_id as dst_item_id, short_desc as dst_short_desc, long_desc as dst_long_desc 
from [pccsql-use2-prod-w24-cli0023.ce22455c967a.database.windows.net].[us_hand_multi].dbo.census_codes with (nolock)
where (fac_id in (-1,68) --dst fac_id
	or reg_id in (select regional_id from [pccsql-use2-prod-w24-cli0023.ce22455c967a.database.windows.net].[us_hand_multi].dbo.facility with (nolock) 
		where fac_id in (68) and regional_id is not null)  --dst fac_id
	or state_code in (select prov from [pccsql-use2-prod-w24-cli0023.ce22455c967a.database.windows.net].[us_hand_multi].dbo.facility with (nolock) 
		where fac_id in (68) and regional_id is not null)  --dst fac_id
    )
AND deleted = 'N'
AND table_code = 'SC'
order by 2