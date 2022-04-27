USE test_usei3sava1
GO

/* Latest Test Results



*/

/* Go Live Results



*/

SELECT '59277 - SAVA to PGHC'

/*

select * from [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.facility src where src.fac_id in (183)
select * from  [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi.dbo.facility dst where dst.fac_id in (173)

select * from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.facility src where src.fac_id in (183)
select * from  [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.facility dst where dst.fac_id in (173)

select 
	'data copy from ' + cast(src.fac_id as varchar) + ' to ' + cast(dst.fac_id as varchar) as facid,
	src.fac_id, src.name, src.address1 + ' ' + src.address2 + ' ' + src.city + ' ' + src.prov + ' :: ' + src.tel as fac_info,
	dst.fac_id, dst.name, dst.address1 + ' ' + dst.address2 + ' ' + dst.city + ' ' + dst.prov + ' :: ' + dst.tel as fac_info
from [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.facility src inner join [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi.dbo.facility dst on src.address1 = dst.address1
where src.fac_id in (183)
and dst.fac_id in (173)
order by dst.fac_id

select 
	'data copy from ' + cast(src.fac_id as varchar) + ' to ' + cast(dst.fac_id as varchar) as facid,
	src.fac_id, src.name, src.address1 + ' ' + src.address2 + ' ' + src.city + ' ' + src.prov + ' :: ' + src.tel as fac_info,
	dst.fac_id, dst.name, dst.address1 + ' ' + dst.address2 + ' ' + dst.city + ' ' + dst.prov + ' :: ' + dst.tel as fac_info
from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.facility src inner join [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.facility dst on src.address1 = dst.address1
where src.fac_id in (183)
and dst.fac_id in (173)

*/

SELECT	RunID, CaseNo, 'Copying Facility: ' + CAST(SrcFacId as varchar) + ' to ' + CAST(DstFacId as varchar) as facility, FacilityRunOrder
FROM [vmuspassvtsjob1.pccprod.local].DS_Merge_Master.dbo.LoadEIMaster_New_Multi_Fac
WHERE PMO_Group_Id in (SELECT pmo_group_id FROM [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_PMO_Groups WHERE PMONumber = '59277')

select * from [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.configuration_parameter a
where fac_id in (183) --
and  a.name in ('pho_is_using_new_phys_order_form')

select top 1 *, 'SourceProductionVersion' as SourceProductionVersion from [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.pcc_db_version order by 3 desc
select top 1 *, 'SourceTestVersion' as SourceTestVersion from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pcc_db_version order by 3 desc
--select top 1 *, 'StagingVersion' as StagingVersion from [vmuspassvtscon3.pccprod.local].pcc_staging_db59277.dbo.pcc_db_version order by 3 desc
select top 1 *, 'DestinationProductionVersion' as DestinationProductionVersion from [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi.dbo.pcc_db_version order by 3 desc
select top 1 *, 'DestinationTestVersion' as DestinationTestVersion from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.pcc_db_version order by 3 desc