
Print '--------Gap import Check-----------'

----Check if new users were created in your facility in src prod
--select * from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.[dbo].sec_user where fac_id in (40) and created_date >= '2026-07-23'
--and loginname not like '%pcc-%'


print 'If any rows > 0 will need to run the gap import/reinsert users- check what is needed'

 
--run incremental script # x

--check if they deleted any users in dest
select * from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.eicase01079812sec_user
where dst_id not in (select userid from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.sec_user)
and dst_id not in (-10000,-998,1)
--above should be zero

--re-insert the deleted users

--if below is not zero - incremental import is necessary
select distinct noted_by,'fac 40'  from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.[dbo].pho_admin_order a
join [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.[dbo].pho_phys_order b
on a.phys_order_id = b.phys_order_id 
where b.fac_id in (40)
and noted_by not in (select src_id from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.EIcase01079812sec_user)

--run incremental script # x

--if below is not zero - incremental import is necessary
select distinct strikeout_by_id,'fac 40'  from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.[dbo].inc_incident 
where fac_id in (40)
and strikeout_by_id not in (select src_id from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.EIcase01079812sec_user)

--run incremental script # x

select * from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.eicase010798798sec_user
where dst_id not in (select userid from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.sec_user)
and dst_id not in (-10000,-998,1)
--above should be zero

--re-insert the deleted users

--if below is not zero - incremental import is necessary
select distinct noted_by,'fac 26'  from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.[dbo].pho_admin_order a
join [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.[dbo].pho_phys_order b
on a.phys_order_id = b.phys_order_id 
where b.fac_id in (26)
and noted_by not in (select src_id from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.EIcase010798798sec_user)

--run incremental script # x

--if below is not zero - incremental import is necessary
select distinct strikeout_by_id,'fac 26'  from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.[dbo].inc_incident 
where fac_id in (26)
and strikeout_by_id not in (select src_id from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.EIcase010798798sec_user)

--run incremental script # x



----check if they deleted any users in dest
--select * from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.eicase01079863sec_user
--where dst_id not in (select userid from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.sec_user)
--and dst_id not in (-10000,-998,1)
----above should be zero

----re-insert the deleted users

----if below is not zero - incremental import is necessary
--select distinct noted_by,'fac 17'  from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.[dbo].pho_admin_order a
--join [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.[dbo].pho_phys_order b
--on a.phys_order_id = b.phys_order_id 
--where b.fac_id in (17)
--and noted_by not in (select src_id from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.EIcase01079863sec_user)

----run incremental script # x

----if below is not zero - incremental import is necessary
--select distinct strikeout_by_id,'fac 17'  from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.[dbo].inc_incident 
--where fac_id in (17)
--and strikeout_by_id not in (select src_id from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.EIcase01079863sec_user)

----run incremental script # x

----check if they deleted any users in dest
--select * from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.eicase01079864sec_user
--where dst_id not in (select userid from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.sec_user)
--and dst_id not in (-10000,-998,1)
----above should be zero

----re-insert the deleted users

----if below is not zero - incremental import is necessary
--select distinct noted_by,'fac 64'  from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.[dbo].pho_admin_order a
--join [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.[dbo].pho_phys_order b
--on a.phys_order_id = b.phys_order_id 
--where b.fac_id in (64)
--and noted_by not in (select src_id from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.EIcase01079864sec_user)

----run incremental script # x

----if below is not zero - incremental import is necessary
--select distinct strikeout_by_id,'fac 64'  from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.[dbo].inc_incident 
--where fac_id in (64)
--and strikeout_by_id not in (select src_id from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.EIcase01079864sec_user)

----run incremental script # x


----check if they deleted any users in dest
--select * from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.eicase01079865sec_user
--where dst_id not in (select userid from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.sec_user)
--and dst_id not in (-10000,-998,1)
----above should be zero

----re-insert the deleted users

----if below is not zero - incremental import is necessary
--select distinct noted_by,'fac 65'  from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.[dbo].pho_admin_order a
--join [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.[dbo].pho_phys_order b
--on a.phys_order_id = b.phys_order_id 
--where b.fac_id in (65)
--and noted_by not in (select src_id from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.EIcase01079865sec_user)

----run incremental script # x

----if below is not zero - incremental import is necessary
--select distinct strikeout_by_id,'fac 65'  from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.[dbo].inc_incident 
--where fac_id in (65)
--and strikeout_by_id not in (select src_id from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.EIcase01079865sec_user)

----run incremental script # x


----check if they deleted any users in dest
--select * from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.eicase01079866sec_user
--where dst_id not in (select userid from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.sec_user)
--and dst_id not in (-10000,-998,1)
----above should be zero

----re-insert the deleted users

----if below is not zero - incremental import is necessary
--select distinct noted_by,'fac 11'  from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.[dbo].pho_admin_order a
--join [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.[dbo].pho_phys_order b
--on a.phys_order_id = b.phys_order_id 
--where b.fac_id in (11)
--and noted_by not in (select src_id from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.EIcase01079866sec_user)

----run incremental script # x

----if below is not zero - incremental import is necessary
--select distinct strikeout_by_id,'fac 11'  from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.[dbo].inc_incident 
--where fac_id in (11)
--and strikeout_by_id not in (select src_id from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.EIcase01079866sec_user)

----run incremental script # x

--select * from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.eicase__CASENUMBER7__sec_user
--where dst_id not in (select userid from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.sec_user)
--and dst_id not in (-10000,-998,1)
----above should be zero

----re-insert the deleted users

----if below is not zero - incremental import is necessary
--select distinct noted_by,'fac __SRCFACID7__'  from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.[dbo].pho_admin_order a
--join [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.[dbo].pho_phys_order b
--on a.phys_order_id = b.phys_order_id 
--where b.fac_id in (__SRCFACID7__)
--and noted_by not in (select src_id from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.EIcase__CASENUMBER7__sec_user)

----run incremental script # x

----if below is not zero - incremental import is necessary
--select distinct strikeout_by_id,'fac __SRCFACID7__'  from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.[dbo].inc_incident 
--where fac_id in (__SRCFACID7__)
--and strikeout_by_id not in (select src_id from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.EIcase__CASENUMBER7__sec_user)

----run incremental script # x



----check if they deleted any users in dest
--select * from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.eicase__CASENUMBER8__sec_user
--where dst_id not in (select userid from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.sec_user)
--and dst_id not in (-10000,-998,1)
----above should be zero

----re-insert the deleted users

----if below is not zero - incremental import is necessary
--select distinct noted_by,'fac __SRCFACID8__'  from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.[dbo].pho_admin_order a
--join [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.[dbo].pho_phys_order b
--on a.phys_order_id = b.phys_order_id 
--where b.fac_id in (__SRCFACID8__)
--and noted_by not in (select src_id from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.EIcase__CASENUMBER8__sec_user)

----run incremental script # x

----if below is not zero - incremental import is necessary
--select distinct strikeout_by_id,'fac __SRCFACID8__'  from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.[dbo].inc_incident 
--where fac_id in (__SRCFACID8__)
--and strikeout_by_id not in (select src_id from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.EIcase__CASENUMBER8__sec_user)

----run incremental script # x


----check if they deleted any users in dest
--select * from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.eicase__CASENUMBER9__sec_user
--where dst_id not in (select userid from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.sec_user)
--and dst_id not in (-10000,-998,1)
----above should be zero

----re-insert the deleted users

----if below is not zero - incremental import is necessary
--select distinct noted_by,'fac __SRCFACID9__'  from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.[dbo].pho_admin_order a
--join [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.[dbo].pho_phys_order b
--on a.phys_order_id = b.phys_order_id 
--where b.fac_id in (__SRCFACID9__)
--and noted_by not in (select src_id from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.EIcase__CASENUMBER9__sec_user)

----run incremental script # x

----if below is not zero - incremental import is necessary
--select distinct strikeout_by_id,'fac __SRCFACID9__'  from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.[dbo].inc_incident 
--where fac_id in (__SRCFACID9__)
--and strikeout_by_id not in (select src_id from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.EIcase__CASENUMBER9__sec_user)

----run incremental script # x


----check if they deleted any users in dest
--select * from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.eicase__CASENUMBER10__sec_user
--where dst_id not in (select userid from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.sec_user)
--and dst_id not in (-10000,-998,1)
----above should be zero

----re-insert the deleted users

----if below is not zero - incremental import is necessary
--select distinct noted_by,'fac __SRCFACID10__'  from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.[dbo].pho_admin_order a
--join [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.[dbo].pho_phys_order b
--on a.phys_order_id = b.phys_order_id 
--where b.fac_id in (__SRCFACID10__)
--and noted_by not in (select src_id from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.EIcase__CASENUMBER10__sec_user)

----run incremental script # x

----if below is not zero - incremental import is necessary
--select distinct strikeout_by_id,'fac __SRCFACID10__'  from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.[dbo].inc_incident 
--where fac_id in (__SRCFACID10__)
--and strikeout_by_id not in (select src_id from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei9.dbo.EIcase__CASENUMBER10__sec_user)

----run incremental script # x


Print '------------Gap Import----------'

--sp:
--run in destination
exec [operational].[sproc_facacq_pre_sec_user_GapImport_01_scoping]
@src_db_location = '[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188'
,@NS_case_number = 'EICase01079812'
,@src_fac_id = 40


exec [operational].[sproc_facacq_pre_sec_user_GapImport_02_Import]
@src_db_location = '[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188'
,@NS_case_number = 'EICase01079812'
,@source_fac_id = 40
,@suffix = 'FVE'
,@destination_org_id = '504954576'
,@destination_fac_id = 1
,@if_is_rerun = 'N'



--exec [operational].[sproc_facacq_pre_sec_user_GapImport_01_scoping]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188'
--,@NS_case_number = 'EICase010798798'
--,@src_fac_id = 26

--exec [operational].[sproc_facacq_pre_sec_user_GapImport_02_Import]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188'
--,@NS_case_number = 'EICase010798798'
--,@source_fac_id = 26
--,@suffix = 'FVE'
--,@destination_org_id = '504954576'
--,@destination_fac_id = 28
--,@if_is_rerun = 'N'



--exec [operational].[sproc_facacq_pre_sec_user_GapImport_01_scoping]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188'
--,@NS_case_number = 'EICase01079863'
--,@src_fac_id = 17

--exec [operational].[sproc_facacq_pre_sec_user_GapImport_02_Import]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188'
--,@NS_case_number = 'EICase01079863'
--,@source_fac_id = 17
--,@suffix = 'FVE'
--,@destination_org_id = '504954576'
--,@destination_fac_id = 63
--,@if_is_rerun = 'N'



--exec [operational].[sproc_facacq_pre_sec_user_GapImport_01_scoping]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188'
--,@NS_case_number = 'EICase01079864'
--,@src_fac_id = 64

--exec [operational].[sproc_facacq_pre_sec_user_GapImport_02_Import]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188'
--,@NS_case_number = 'EICase01079864'
--,@source_fac_id = 64
--,@suffix = 'FVE'
--,@destination_org_id = '504954576'
--,@destination_fac_id = 40
--,@if_is_rerun = 'N'



--exec [operational].[sproc_facacq_pre_sec_user_GapImport_01_scoping]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188'
--,@NS_case_number = 'EICase01079865'
--,@src_fac_id = 65

--exec [operational].[sproc_facacq_pre_sec_user_GapImport_02_Import]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188'
--,@NS_case_number = 'EICase01079865'
--,@source_fac_id = 65
--,@suffix = 'FVE'
--,@destination_org_id = '504954576'
--,@destination_fac_id = 65
--,@if_is_rerun = 'N'



--exec [operational].[sproc_facacq_pre_sec_user_GapImport_01_scoping]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188'
--,@NS_case_number = 'EICase01079866'
--,@src_fac_id = 11

--exec [operational].[sproc_facacq_pre_sec_user_GapImport_02_Import]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188'
--,@NS_case_number = 'EICase01079866'
--,@source_fac_id = 11
--,@suffix = 'FVE'
--,@destination_org_id = '504954576'
--,@destination_fac_id = 66
--,@if_is_rerun = 'N'



--exec [operational].[sproc_facacq_pre_sec_user_GapImport_01_scoping]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188'
--,@NS_case_number = 'EICase__CASENUMBER7__'
--,@src_fac_id = __SRCFACID7__

--exec [operational].[sproc_facacq_pre_sec_user_GapImport_02_Import]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188'
--,@NS_case_number = 'EICase__CASENUMBER7__'
--,@source_fac_id = __SRCFACID7__
--,@suffix = 'FVE'
--,@destination_org_id = '504954576'
--,@destination_fac_id = __DSTFACID7__
--,@if_is_rerun = 'N'



--exec [operational].[sproc_facacq_pre_sec_user_GapImport_01_scoping]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188'
--,@NS_case_number = 'EICase__CASENUMBER8__'
--,@src_fac_id = __SRCFACID8__

--exec [operational].[sproc_facacq_pre_sec_user_GapImport_02_Import]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188'
--,@NS_case_number = 'EICase__CASENUMBER8__'
--,@source_fac_id = __SRCFACID8__
--,@suffix = 'FVE'
--,@destination_org_id = '504954576'
--,@destination_fac_id = __DSTFACID8__
--,@if_is_rerun = 'N'



--exec [operational].[sproc_facacq_pre_sec_user_GapImport_01_scoping]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188'
--,@NS_case_number = 'EICase__CASENUMBER9__'
--,@src_fac_id = __SRCFACID9__

--exec [operational].[sproc_facacq_pre_sec_user_GapImport_02_Import]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188'
--,@NS_case_number = 'EICase__CASENUMBER9__'
--,@source_fac_id = __SRCFACID9__
--,@suffix = 'FVE'
--,@destination_org_id = '504954576'
--,@destination_fac_id = __DSTFACID9__
--,@if_is_rerun = 'N'



--exec [operational].[sproc_facacq_pre_sec_user_GapImport_01_scoping]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188'
--,@NS_case_number = 'EICase__CASENUMBER10__'
--,@src_fac_id = __SRCFACID10__

--exec [operational].[sproc_facacq_pre_sec_user_GapImport_02_Import]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188'
--,@NS_case_number = 'EICase__CASENUMBER10__'
--,@source_fac_id = __SRCFACID10__
--,@suffix = 'FVE'
--,@destination_org_id = '504954576'
--,@destination_fac_id = __DSTFACID10__
--,@if_is_rerun = 'N'

