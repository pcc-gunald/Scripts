--check fac_id & reg_id

drop table if exists #temp1, #temp2
SELECT long_description, short_description, rate_type_id
,rn = row_number() over(order by long_description, short_description)
into #temp1
FROM [pccsql-use2-prod-w27-cli0020.851c37dfbe45.database.windows.net].[us_ssch].dbo.ar_lib_rate_type with (nolock)
WHERE deleted = 'N' 
and rate_type_id in (SELECT rate_type_id from [pccsql-use2-prod-w27-cli0020.851c37dfbe45.database.windows.net].[us_ssch].dbo.room_date_range with (nolock)
						WHERE room_id in (select room_id from [pccsql-use2-prod-w27-cli0020.851c37dfbe45.database.windows.net].[us_ssch].dbo.room with (nolock)
							WHERE fac_id in (1))) --src fac_id
order by 1, 2


SELECT long_description, short_description, rate_type_id
,rn = row_number() over(order by long_description, short_description)
into #temp2
FROM [pccsql-use2-prod-w19-cli0003.3055e0bc69f6.database.windows.net].[us_mea].dbo.ar_lib_rate_type with (nolock)
WHERE deleted = 'N' and 
	(fac_id in (-1,2) --dst fac_id
	or reg_id = 1)--dst reg_id
order by 1, 2



select a.long_description, a.short_description, a.rate_type_id,'',b.long_description, b.short_description, b.rate_type_id from #temp1 a
full outer join #temp2 b on b.rn=a.rn
order by  b.long_description, b.short_description
