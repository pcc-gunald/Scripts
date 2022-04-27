select a.*,b.description,c.description from eicase0082551pho_administration_record a
inner join [test_usei964].dbo.pho_administration_record b on b.administration_record_id=a.src_id
inner join [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].[test_usei31].dbo.pho_administration_record c on c.administration_record_id=a.dst_id


select a.*,m.map_dstItemid,sc.description,sc.fac_id
,	ISNULL(sc.description,'NULL') + ' ( ' + ISNULL(sa.short_description,'NULL') + ' | ' + ISNULL(sb.category_desc,'NULL') + ' | ' + ISNULL(sc.mandatory_end_date,'NULL')  + ' ) '  as 'src_description (short_description | category_desc | mandatory_end_date)'
  ,dstm.description 
  ,dst.description
  ,dst.fac_id
  ,dst.order_type_id
  ,ISNULL(dst.description,'NULL') + ' ( ' + ISNULL(dsta.short_description,'NULL') + ' | ' + ISNULL(dstc.category_desc,'NULL') + ' | ' + ISNULL(dst.mandatory_end_date,'NULL')  + ' ) '  as 'src_description (short_description | category_desc | mandatory_end_date)'
from eicase0082551pho_order_type a
inner join [test_usei964].dbo.pho_order_type sc on sc.order_type_id=a.src_id
inner join [test_usei964].dbo.pho_order_category sb ON sb.order_category_id = sc.order_category_id
LEFT JOIN [test_usei964].dbo.pho_administration_record sa ON sa.administration_record_id = sc.administration_record_id
inner join [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E008255_Clinical_Advanced$] m on m.src_id=a.src_id
LEFT JOIN [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].[test_usei31].dbo.pho_order_type dst ON dst.order_type_id = m.Map_DstItemId
inner JOIN [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].[test_usei31].dbo.pho_order_category dstc on dstc.order_category_id= dst.order_category_id
left join [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].[test_usei31].dbo.pho_administration_record dsta on  dsta.administration_record_id=dst.administration_record_id
inner JOIN [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].[test_usei31].dbo.pho_order_type dstm on dstm.order_type_id= m.Map_DstItemId
where m.Map_DstItemId is not null
and  m.Map_DstItemId  in(6,56,5)

select * from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E008255_Clinical_Advanced$]
where map_dstItemid in(6,56,5)


select * from  EICase0082551pn_type a
inner join  [test_usei964].dbo.pn_type sc on sc.pn_type_id=a.src_id
left join [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E008255_Clinical_Advanced$] m on m.src_id=a.src_id and  pick_list_name='Progress Note Types'
where    map_dstItemid in(67,
88,
89,
7,
4,
36,
90,
46
)

select * from  EICase0082551pn_type a
where a.src_id=67

select * from  [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E008255_Clinical_Advanced$]
where pick_list_name='Progress Note Types'
and map_dstItemid is not null