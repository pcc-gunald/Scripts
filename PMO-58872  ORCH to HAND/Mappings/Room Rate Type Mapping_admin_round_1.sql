--check fac_id & reg_id
--select reg_id from [pccsql-use2-prod-w27-cli0023.851c37dfbe45.database.windows.net].[us_orch_multi].dbo.facility
--where fac_id=6

--select reg_id from [pccsql-use2-prod-w24-cli0023.ce22455c967a.database.windows.net].[us_hand_multi].dbo.facility
--where fac_id=68

SELECT long_description, short_description, rate_type_id
FROM [pccsql-use2-prod-w27-cli0023.851c37dfbe45.database.windows.net].[us_orch_multi].dbo.ar_lib_rate_type with (nolock)
WHERE deleted = 'N' 
and rate_type_id in (SELECT rate_type_id from [pccsql-use2-prod-w27-cli0023.851c37dfbe45.database.windows.net].[us_orch_multi].dbo.room_date_range with (nolock)
						WHERE room_id in (select room_id from [pccsql-use2-prod-w27-cli0023.851c37dfbe45.database.windows.net].[us_orch_multi].dbo.room with (nolock)
							WHERE fac_id in (6))) --src fac_id
order by 1, 2


SELECT long_description, short_description, rate_type_id
FROM [pccsql-use2-prod-w24-cli0023.ce22455c967a.database.windows.net].[us_hand_multi].dbo.ar_lib_rate_type with (nolock)
WHERE deleted = 'N' and 
	(fac_id in (-1,68) --dst fac_id
	or reg_id = 1)--dst reg_id
order by 1, 2




