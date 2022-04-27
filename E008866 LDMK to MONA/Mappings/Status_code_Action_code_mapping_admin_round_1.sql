--tablename	idField	tableorder	scopeField1	scopeField2
--census_codes	item_id	4550	table_code	short_desc


--select * from [pccsql-use2-prod-w25-cli0010.2d62ac5c7643.database.windows.net].[us_ldmk_multi].facility with (nolock) where fac_id = 8

--select * from [pccsql-use2-prod-w19-cli0009.3055e0bc69f6.database.windows.net].[us_mona_multi].dbo.facility with (nolock) where fac_id = 9

---------------------
--Action Codes
---------------------
--src
drop table if exists #temp1, #temp2
select long_desc as src_long_desc, short_desc as src_short_desc, item_id as src_item_id 
,rn = row_number() over(order by short_desc)
into #temp1
from [pccsql-use2-prod-w25-cli0010.2d62ac5c7643.database.windows.net].[us_ldmk_multi].dbo.census_codes with (nolock)
where (fac_id in (-1,6)  --src fac_id
	or reg_id in (select regional_id from [pccsql-use2-prod-w25-cli0010.2d62ac5c7643.database.windows.net].[us_ldmk_multi].dbo.facility with (nolock) 
		where fac_id in (6) and regional_id is not null)) --src fac_id
AND deleted = 'N'
AND table_code = 'ACT'
AND item_id in  
		((SELECT isnull(action_code_id,-1) FROM [pccsql-use2-prod-w25-cli0010.2d62ac5c7643.database.windows.net].[us_ldmk_multi].[dbo].census_item with (nolock) 
		WHERE fac_id in (6) AND DELETED = 'N')  --src fac_id
		UNION 
		(SELECT isnull(STATUS_CODE_ID,-1) FROM [pccsql-use2-prod-w25-cli0010.2d62ac5c7643.database.windows.net].[us_ldmk_multi].[dbo].census_item with (nolock) 
		WHERE fac_id in (6) AND DELETED = 'N')) --src fac_id
order by 2

--dst
select item_id as dst_item_id, short_desc as dst_short_desc, long_desc as dst_long_desc 
,rn = row_number() over(order by short_desc)
into #temp2
from [pccsql-use2-prod-w19-cli0009.3055e0bc69f6.database.windows.net].[us_mona_multi].dbo.census_codes with (nolock)
where (fac_id in (-1,4) --dst fac_id
	or reg_id in (select regional_id from [pccsql-use2-prod-w19-cli0009.3055e0bc69f6.database.windows.net].[us_mona_multi].dbo.facility with (nolock) 
		where fac_id in (4) and regional_id is not null)  --dst fac_id
	or state_code in (select prov from [pccsql-use2-prod-w19-cli0009.3055e0bc69f6.database.windows.net].[us_mona_multi].dbo.facility with (nolock) 
		where fac_id in (4) and prov is not null)  --dst fac_id
    )
AND deleted = 'N'
AND table_code = 'ACT'
order by 2

select a.src_long_desc, a.src_short_desc, a.src_item_id,'',b.dst_item_id, b.dst_short_desc, b.dst_long_desc from #temp1 a
full outer join #temp2 b on b.rn=a.rn
order by  b.dst_short_desc

---------------------
--Status Codes
---------------------
--src
drop table if exists #temp3, #temp4

select long_desc as src_long_desc, short_desc as src_short_desc, item_id as src_item_id 
,rn = row_number() over(order by short_desc)
into #temp3
from [pccsql-use2-prod-w25-cli0010.2d62ac5c7643.database.windows.net].[us_ldmk_multi].dbo.census_codes with (nolock)
where (fac_id in (-1,6) --src fac_id
	or reg_id in (select regional_id from [pccsql-use2-prod-w25-cli0010.2d62ac5c7643.database.windows.net].[us_ldmk_multi].dbo.facility with (nolock) 
		where fac_id in (6) and regional_id is not null))--src fac_id
AND deleted = 'N'
AND table_code = 'SC'
AND item_id in  
		((SELECT isnull(action_code_id,-1) FROM [pccsql-use2-prod-w25-cli0010.2d62ac5c7643.database.windows.net].[us_ldmk_multi].[dbo].census_item with (nolock) 
		WHERE fac_id in (6) AND DELETED = 'N')  --src fac_id
		UNION 
		(SELECT isnull(STATUS_CODE_ID,-1) FROM [pccsql-use2-prod-w25-cli0010.2d62ac5c7643.database.windows.net].[us_ldmk_multi].[dbo].census_item with (nolock) 
		WHERE fac_id in (6) AND DELETED = 'N')) --src fac_id
order by 2

--dst
select item_id as dst_item_id, short_desc as dst_short_desc, long_desc as dst_long_desc 
,rn = row_number() over(order by short_desc)
into #temp4
from [pccsql-use2-prod-w19-cli0009.3055e0bc69f6.database.windows.net].[us_mona_multi].dbo.census_codes with (nolock)
where (fac_id in (-1,4) --dst fac_id
	or reg_id in (select regional_id from [pccsql-use2-prod-w19-cli0009.3055e0bc69f6.database.windows.net].[us_mona_multi].dbo.facility with (nolock) 
		where fac_id in (4) and regional_id is not null)  --dst fac_id
	or state_code in (select prov from [pccsql-use2-prod-w19-cli0009.3055e0bc69f6.database.windows.net].[us_mona_multi].dbo.facility with (nolock) 
		where fac_id in (4) and regional_id is not null)  --dst fac_id
    )
AND deleted = 'N'
AND table_code = 'SC'
order by 2


select a.src_long_desc, a.src_short_desc, a.src_item_id,'',b.dst_item_id, b.dst_short_desc, b.dst_long_desc from #temp3 a
full outer join #temp4 b on b.rn=a.rn
order by  b.dst_short_desc
