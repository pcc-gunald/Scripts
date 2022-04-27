select * from EICase01018911pho_administration_record a
inner join 

select * from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E010189_Clinical_Advanced$] a
left  join EICase01018911pho_administration_record b  on b.src_id=a.src_id 
where a.pick_list_name='Administration Records'
and a.map_DstItemid Is Not NULL


select * from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E010189_Clinical_Advanced$] a
left  join EICase01018911pho_order_type b  on b.src_id=a.src_id 
where a.pick_list_name='Order Types' 
and a.map_DstItemid Is Not NULL

select * from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E010189_Clinical_Advanced$] a
left  join EICase01018911pn_type b  on b.src_id=a.src_id 
where a.pick_list_name='Progress Note Types'
and a.map_DstItemid Is Not NULL


select * from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E010189_Clinical_Advanced$] a
left  join EICase01018911cr_std_immunization b  on b.src_id=a.src_id 
where a.pick_list_name='Immunizations'
and a.map_DstItemid Is Not NULL

select * from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E010189_Clinical_Advanced$] a
left  join EICase01018911cp_std_shift b  on b.src_id=a.src_id 
where a.pick_list_name='Standard Shifts' 
and a.map_DstItemid Is Not NULL