--check fac_id & reg_id


SELECT long_description, short_description, rate_type_id, *
FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.ar_lib_rate_type with (nolock)
WHERE deleted = 'N' and (fac_id in (-1,183) or reg_id = 1)
order by 1, 2


SELECT long_description, short_description, rate_type_id, *
FROM [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].[us_pghc_multi].dbo.ar_lib_rate_type with (nolock)
WHERE deleted = 'N' and (fac_id in (-1,173) or reg_id = 1)
order by 1, 2

