--check fac_id & reg_id


SELECT long_description, short_description, rate_type_id
FROM [pccsql-use2-prod-w25-cli0023.2d62ac5c7643.database.windows.net].us_hdg_multi.dbo.ar_lib_rate_type with (nolock)
WHERE deleted = 'N' 
and rate_type_id in (SELECT rate_type_id from [pccsql-use2-prod-w25-cli0023.2d62ac5c7643.database.windows.net].us_hdg_multi.dbo.room_date_range with (nolock)
						WHERE room_id in (select room_id from [pccsql-use2-prod-w25-cli0023.2d62ac5c7643.database.windows.net].us_hdg_multi.dbo.room with (nolock)
							WHERE fac_id in (2))) --src fac_id
order by 1, 2


SELECT long_description, short_description, rate_type_id
FROM [pccsql-use2-prod-w28-cli0007.874bf44c721a.database.windows.net].us_champ_multi.dbo.ar_lib_rate_type with (nolock)
WHERE deleted = 'N' and 
	(fac_id in (-1,50) --dst fac_id
	or reg_id = 1)--dst reg_id
order by 1, 2




