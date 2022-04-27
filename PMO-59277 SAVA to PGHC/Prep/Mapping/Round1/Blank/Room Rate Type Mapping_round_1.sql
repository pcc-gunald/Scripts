--check fac_id & reg_id


SELECT long_description, short_description, rate_type_id, *
FROM [USVS184\PRODW4G].us_shg_multi.dbo.ar_lib_rate_type with (nolock)
WHERE deleted = 'N' and (fac_id in (-1,6) or reg_id = 1)
order by 1, 2


SELECT long_description, short_description, rate_type_id, *
FROM [USVS233\PRODW4AA].us_qua.dbo.ar_lib_rate_type with (nolock)
WHERE deleted = 'N' and (fac_id in (-1,4) or reg_id = 1)
order by 1, 2