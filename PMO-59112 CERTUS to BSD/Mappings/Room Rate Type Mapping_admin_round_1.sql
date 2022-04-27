--check fac_id & reg_id

drop table if exists #temp1, #temp2
SELECT long_description, short_description, rate_type_id
,rn = row_number() over(order by long_description, short_description)
into #temp1
FROM [pccsql-use2-prod-w30-cli0021.cbafa2b80e84.database.windows.net].[us_certus_multi].dbo.ar_lib_rate_type with (nolock)
WHERE deleted = 'N' 
and rate_type_id in (SELECT rate_type_id from [pccsql-use2-prod-w30-cli0021.cbafa2b80e84.database.windows.net].[us_certus_multi].dbo.room_date_range with (nolock)
						WHERE room_id in (select room_id from [pccsql-use2-prod-w30-cli0021.cbafa2b80e84.database.windows.net].[us_certus_multi].dbo.room with (nolock)
							WHERE fac_id in (12))) --src fac_id
order by 1, 2


SELECT long_description, short_description, rate_type_id
,rn = row_number() over(order by long_description, short_description)
into #temp2
FROM [pccsql-use2-prod-w22-cli0005.4c4638f8e26f.database.windows.net].[us_bsd_multi].dbo.ar_lib_rate_type with (nolock)
WHERE deleted = 'N' and 
	(fac_id in (-1,18) --dst fac_id
	or reg_id = 1)--dst reg_id
order by 1, 2



select a.long_description, a.short_description, a.rate_type_id,'',b.long_description, b.short_description, b.rate_type_id from #temp1 a
full outer join #temp2 b on b.rn=a.rn
order by  b.long_description, b.short_description