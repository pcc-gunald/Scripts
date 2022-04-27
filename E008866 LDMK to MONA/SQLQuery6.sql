SELECT distinct a.src_id, a.Map_DstItemId,src.fac_id,dst.fac_id, src.description ,dst.description,src.retired,src.system,dst.retired,dst.system,src.template_id,dst.template_id
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E008866_Clinical_Advanced$] a
JOIN [pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].[test_usei1172].dbo.pn_type AS src on src.pn_type_id = a.src_id
JOIN [pccsql-use2-prod-w19-cli0009.3055e0bc69f6.database.windows.net].[us_mona_multi].dbo.pn_type AS dst on dst.pn_type_id = a.Map_DstItemId
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = 'Progress Note Types'


SELECT distinct a.src_id, a.Map_DstItemId,src.fac_id,dst.fac_id, src.description , dst.description,src.retired,src.system,dst.retired,dst.system,src.template_id,dst.template_id
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E008866_Clinical_Advanced$] a
JOIN [pccsql-use2-prod-w25-cli0010.2d62ac5c7643.database.windows.net].[us_ldmk_multi].dbo.pn_type AS src on src.pn_type_id = a.src_id
JOIN [pccsql-use2-prod-w19-cli0009.3055e0bc69f6.database.windows.net].[us_mona_multi].dbo.pn_type AS dst on dst.pn_type_id = a.Map_DstItemId
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = 'Progress Note Types'


select * from EICase088666pn_type
where src_id in(9,
12,
115,
125,
167)


select * from mergeTablesMaster
where tablename='pn_type'

select * from MergeLog
where msg like '%pn_type%'
order by 1 

select EICase088666pn_type.*,c.*
FROM [pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].[test_usei1172].[dbo].pn_type b
LEFT JOIN EICase088666pn_template t_template_id ON t_template_id.SRC_ID = b.template_id
JOIN [pccsql-use2-prod-ssv-tscon06.b4ea653240a9.database.windows.net].test_usei432.[dbo].pn_type c ON c.fac_id = 4
	AND c.reg_id IS NULL
	AND (
		c.description = b.description
		OR (
			c.description IS NULL
			AND b.description IS NULL
			)
		)
	AND (
		c.retired = b.retired
		OR (ISNULL(c.retired, 'N') = ISNULL(b.retired, 'N'))
		)
	AND (c.template_id = t_template_id.DST_ID)
	AND (
		c.system = b.system
		OR (
			c.system IS NULL
			AND b.system IS NULL
			)
		)
	AND ISNULL(c.deleted, 'N') = ISNULL(b.deleted, 'N')
	,EICase088666pn_type
WHERE EICase088666pn_type.src_id = b.pn_type_id
	AND EICase088666pn_type.corporate = 'N'

	select * from [pccsql-use2-prod-ssv-tscon06.b4ea653240a9.database.windows.net].test_usei432.dbo.pn_type
	where pn_type_id in(12,167)


	UPDATE EICase088666pn_type
SET dst_id = c.pn_type_id
	,corporate = 'Y'
FROM test_usei1172.[dbo].pn_type b
LEFT JOIN EICase088666pn_template t_template_id ON t_template_id.SRC_ID = b.template_id
JOIN pcc_staging_db008866.[dbo].pn_type c ON c.fac_id = 4
	AND c.reg_id IS NULL
	AND (
		c.description = b.description
		OR (
			c.description IS NULL
			AND b.description IS NULL
			)
		)
	AND (
		c.retired = b.retired
		OR (ISNULL(c.retired, 'N') = ISNULL(b.retired, 'N'))
		)
	AND (c.template_id = t_template_id.DST_ID)
	AND (
		c.system = b.system
		OR (
			c.system IS NULL
			AND b.system IS NULL
			)
		)
	AND ISNULL(c.deleted, 'N') = ISNULL(b.deleted, 'N')
WHERE EICase088666pn_type.src_id = b.pn_type_id
	AND EICase088666pn_type.corporate = 'N'


	select * from pcc_staging_db008866.[dbo].pn_type


select EICase088666pn_type.*,t_template_id.*,c.*
FROM [pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].[test_usei1172].[dbo].pn_type b
LEFT JOIN EICase088666pn_template t_template_id ON t_template_id.SRC_ID = b.template_id
JOIN [pccsql-use2-prod-ssv-tscon06.b4ea653240a9.database.windows.net].test_usei432.[dbo].pn_type c ON c.fac_id = - 1
	AND (
		c.description = b.description
		OR (
			c.description IS NULL
			AND b.description IS NULL
			)
		)
	AND (
		c.retired = b.retired
		OR (ISNULL(c.retired, 'N') = ISNULL(b.retired, 'N'))
		)
	AND (c.template_id = t_template_id.DST_ID)
	AND (
		c.system = b.system
		OR (
			c.system IS NULL
			AND b.system IS NULL
			)
		)
	AND ISNULL(c.deleted, 'N') = ISNULL(b.deleted, 'N'),EICase088666pn_type
WHERE EICase088666pn_type.src_id = b.pn_type_id
	AND EICase088666pn_type.corporate = 'N'

select * from [pccsql-use2-prod-ssv-tscon06.b4ea653240a9.database.windows.net].test_usei432.dbo.pn_type
	where pn_type_id in(12,167)


select * from [pccsql-use2-prod-w19-cli0009.3055e0bc69f6.database.windows.net].[us_mona_multi].dbo.pn_type 
where pn_type_id in(12,167)

select * from EICase088666pho_administration_record

select * from EICase088666pho_order_type

select * from mergeTablesMaster
where tablename='pho_order_type'

select * from MergeLog
where msg like '%6pho_order_type%'
order by 1 



UPDATE EICase088666pho_order_type
SET dst_id = c.order_type_id
	,corporate = 'Y'
FROM test_usei1172.[dbo].pho_order_type b
LEFT JOIN EICase088666pho_order_category t_order_category_id ON t_order_category_id.SRC_ID = b.order_category_id
LEFT JOIN EICase088666pho_administration_record t_administration_record_id ON t_administration_record_id.SRC_ID = b.administration_record_id
JOIN [pccsql-use2-prod-ssv-tscon06.b4ea653240a9.database.windows.net].test_usei432.[dbo].pho_order_type c ON c.fac_id = 4
	AND c.reg_id IS NULL
	AND (
		c.description = b.description
		OR (
			c.description IS NULL
			AND b.description IS NULL
			)
		)
	AND (
		c.mandatory_end_date = b.mandatory_end_date
		OR (
			c.mandatory_end_date IS NULL
			AND b.mandatory_end_date IS NULL
			)
		)
	AND (
		ISNULL(c.order_category_id, - 32768) = ISNULL(t_order_category_id.DST_ID, - 32768)
		OR (
			(ISNULL(c.order_category_id, - 1) = - 1)
			AND (ISNULL(b.order_category_id, - 1) = - 1)
			)
		)
	AND (
		ISNULL(c.administration_record_id, - 32768) = ISNULL(t_administration_record_id.DST_ID, - 32768)
		OR (
			(ISNULL(c.administration_record_id, - 1) = - 1)
			AND (ISNULL(b.administration_record_id, - 1) = - 1)
			)
		)
	AND ISNULL(c.deleted, 'N') = ISNULL(b.deleted, 'N')
WHERE EICase088666pho_order_type.src_id = b.order_type_id
	AND EICase088666pho_order_type.corporate = 'N'


	 INSERT INTO pcc_staging_db008866.[dbo].pho_order_type (
	order_type_id
	,fac_id
	,deleted
	,description
	,mandatory_end_date
	,order_category_id
	,administration_record_id
	,system_flag
	,default_order
	,flow_sheet_flag
	,facility_type
	,sequence
	,DELETED_BY
	,DELETED_DATE
	,retired
	,con_order_flag
	,reg_id
	,pharm_req_flag
	,state_code
	,alt_administration_record_id
	,MULTI_FAC_ID
	)
SELECT DISTINCT b.dst_id
	,copy_fac.dst_id
	,[deleted]
	,[description]
	,[mandatory_end_date]
	,ISNULL(EICase0886662.dst_id, order_category_id)
	,ISNULL(EICase0886663.dst_id, administration_record_id)
	,[system_flag]
	,[default_order]
	,[flow_sheet_flag]
	,ISNULL(EICase0886664.dst_id, facility_type)
	,[sequence]
	,[DELETED_BY]
	,[DELETED_DATE]
	,[retired]
	,[con_order_flag]
	,NULL
	,[pharm_req_flag]
	,[state_code]
	,ISNULL(EICase0886661.dst_id, alt_administration_record_id)
	,4
FROM test_usei1172.[dbo].pho_order_type a
JOIN pcc_staging_db008866.[dbo].EICase088666facility copy_fac ON copy_fac.src_id = a.fac_id
	OR copy_fac.src_id = 6
LEFT JOIN pcc_staging_db008866.[dbo].EICase088666pho_administration_record EICase0886661 ON EICase0886661.src_id = a.alt_administration_record_id
LEFT JOIN pcc_staging_db008866.[dbo].EICase088666pho_order_category EICase0886662 ON EICase0886662.src_id = a.order_category_id
LEFT JOIN pcc_staging_db008866.[dbo].EICase088666pho_administration_record EICase0886663 ON EICase0886663.src_id = a.administration_record_id
LEFT JOIN pcc_staging_db008866.[dbo].EICase088666common_code EICase0886664 ON EICase0886664.src_id = a.facility_type
	,pcc_staging_db008866.[dbo].EICase088666pho_order_type b
WHERE a.order_type_id <> - 1
	AND (
		a.fac_id IN (
			6
			,- 1
			)
		OR a.reg_id = 2
		)
	AND a.order_type_id = b.src_id
	AND b.corporate = 'N'
