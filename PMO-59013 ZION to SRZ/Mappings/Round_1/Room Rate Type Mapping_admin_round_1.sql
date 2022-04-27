--check fac_id & reg_id


SELECT long_description, short_description, rate_type_id
FROM [pccsql-use2-prod-w26-cli0026.d9c23db323d7.database.windows.net].us_zion_multi.dbo.ar_lib_rate_type with (nolock)
WHERE deleted = 'N' 
and rate_type_id in (SELECT rate_type_id from [pccsql-use2-prod-w26-cli0026.d9c23db323d7.database.windows.net].us_zion_multi.dbo.room_date_range with (nolock)
						WHERE room_id in (select room_id from [pccsql-use2-prod-w26-cli0026.d9c23db323d7.database.windows.net].us_zion_multi.dbo.room with (nolock)
							WHERE fac_id in (29, 32))) --src fac_id
order by 1, 2


SELECT long_description, short_description, rate_type_id
FROM [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi.dbo.ar_lib_rate_type with (nolock)
WHERE deleted = 'N' and 
	(fac_id in (-1,29,30) --dst fac_id
	or reg_id = 1)--dst reg_id
order by 1, 2


--select * from [pccsql-use2-prod-w26-cli0026.d9c23db323d7.database.windows.net].us_zion_multi.dbo.facility

--select * from [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi.dbo.facility