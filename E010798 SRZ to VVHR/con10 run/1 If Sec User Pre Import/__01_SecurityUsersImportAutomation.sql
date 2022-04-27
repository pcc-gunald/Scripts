
SELECT src.fac_id as src_fac_id,src.long_username as 'long_username in SRC',dst.long_username as 'long_username in usei9',src.loginname as 'loginname in SRC',dst.loginname as 'loginname in usei9'
FROM [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei984.dbo.sec_user src
JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].us_vvhr.dbo.sec_user dst ON src.loginname = dst.loginname
      AND src.long_username <> dst.long_username 
      --AND src.fac_id in (40) 


update src
set src.loginname = src.loginname + 'FVE'  --change to source org code
--SELECT src.fac_id as src_fac_id,src.long_username as 'long_username in SRC',dst.long_username as 'long_username in usei9',src.loginname as 'loginname in SRC',dst.loginname as 'loginname in usei9'
FROM [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei984.dbo.sec_user src
JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].us_vvhr.dbo.sec_user dst ON src.loginname = dst.loginname
      AND src.long_username <> dst.long_username 
      --AND src.fac_id in (40) 



use us_vvhr

--sp:
--run in destination

exec [operational].[sproc_facacq_pre_sec_user_Import_01_scoping]
@src_db_location = '[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei984'
,@NS_case_number = 'EICase01079812'
,@src_fac_id = 40

exec [operational].[sproc_facacq_pre_sec_user_Import_02_Import]
@src_db_location = '[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei984'
,@NS_case_number = 'EICase01079812'
,@source_fac_id = 40
,@suffix = 'FVE'
,@destination_org_id = '504954576'
,@destination_fac_id = 1
,@if_is_rerun = 'N'



--exec [operational].[sproc_facacq_pre_sec_user_Import_01_scoping]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei984'
--,@NS_case_number = 'EICase010798798'
--,@src_fac_id = 26

--exec [operational].[sproc_facacq_pre_sec_user_Import_02_Import]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei984'
--,@NS_case_number = 'EICase010798798'
--,@source_fac_id = 26
--,@suffix = 'FVE'
--,@destination_org_id = '504954576'
--,@destination_fac_id = 28
--,@if_is_rerun = 'N'



--exec [operational].[sproc_facacq_pre_sec_user_Import_01_scoping]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei984'
--,@NS_case_number = 'EICase01079863'
--,@src_fac_id = 17

--exec [operational].[sproc_facacq_pre_sec_user_Import_02_Import]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei984'
--,@NS_case_number = 'EICase01079863'
--,@source_fac_id = 17
--,@suffix = 'FVE'
--,@destination_org_id = '504954576'
--,@destination_fac_id = 63
--,@if_is_rerun = 'N'



--exec [operational].[sproc_facacq_pre_sec_user_Import_01_scoping]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei984'
--,@NS_case_number = 'EICase01079864'
--,@src_fac_id = 64

--exec [operational].[sproc_facacq_pre_sec_user_Import_02_Import]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei984'
--,@NS_case_number = 'EICase01079864'
--,@source_fac_id = 64
--,@suffix = 'FVE'
--,@destination_org_id = '504954576'
--,@destination_fac_id = 40
--,@if_is_rerun = 'N'



--exec [operational].[sproc_facacq_pre_sec_user_Import_01_scoping]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei984'
--,@NS_case_number = 'EICase01079865'
--,@src_fac_id = 65

--exec [operational].[sproc_facacq_pre_sec_user_Import_02_Import]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei984'
--,@NS_case_number = 'EICase01079865'
--,@source_fac_id = 65
--,@suffix = 'FVE'
--,@destination_org_id = '504954576'
--,@destination_fac_id = 65
--,@if_is_rerun = 'N'



--exec [operational].[sproc_facacq_pre_sec_user_Import_01_scoping]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei984'
--,@NS_case_number = 'EICase01079866'
--,@src_fac_id = 11

--exec [operational].[sproc_facacq_pre_sec_user_Import_02_Import]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei984'
--,@NS_case_number = 'EICase01079866'
--,@source_fac_id = 11
--,@suffix = 'FVE'
--,@destination_org_id = '504954576'
--,@destination_fac_id = 66
--,@if_is_rerun = 'N'



--exec [operational].[sproc_facacq_pre_sec_user_Import_01_scoping]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei984'
--,@NS_case_number = 'EICase__CASENUMBER7__'
--,@src_fac_id = __SRCFACID7__

--exec [operational].[sproc_facacq_pre_sec_user_Import_02_Import]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei984'
--,@NS_case_number = 'EICase__CASENUMBER7__'
--,@source_fac_id = __SRCFACID7__
--,@suffix = 'FVE'
--,@destination_org_id = '504954576'
--,@destination_fac_id = __DSTFACID7__
--,@if_is_rerun = 'N'



--exec [operational].[sproc_facacq_pre_sec_user_Import_01_scoping]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei984'
--,@NS_case_number = 'EICase__CASENUMBER8__'
--,@src_fac_id = __SRCFACID8__

--exec [operational].[sproc_facacq_pre_sec_user_Import_02_Import]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei984'
--,@NS_case_number = 'EICase__CASENUMBER8__'
--,@source_fac_id = __SRCFACID8__
--,@suffix = 'FVE'
--,@destination_org_id = '504954576'
--,@destination_fac_id = __DSTFACID8__
--,@if_is_rerun = 'N'



--exec [operational].[sproc_facacq_pre_sec_user_Import_01_scoping]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei984'
--,@NS_case_number = 'EICase__CASENUMBER9__'
--,@src_fac_id = __SRCFACID9__

--exec [operational].[sproc_facacq_pre_sec_user_Import_02_Import]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei984'
--,@NS_case_number = 'EICase__CASENUMBER9__'
--,@source_fac_id = __SRCFACID9__
--,@suffix = 'FVE'
--,@destination_org_id = '504954576'
--,@destination_fac_id = __DSTFACID9__
--,@if_is_rerun = 'N'



--exec [operational].[sproc_facacq_pre_sec_user_Import_01_scoping]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei984'
--,@NS_case_number = 'EICase__CASENUMBER10__'
--,@src_fac_id = __SRCFACID10__

--exec [operational].[sproc_facacq_pre_sec_user_Import_02_Import]
--@src_db_location = '[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei984'
--,@NS_case_number = 'EICase__CASENUMBER10__'
--,@source_fac_id = __SRCFACID10__
--,@suffix = 'FVE'
--,@destination_org_id = '504954576'
--,@destination_fac_id = __DSTFACID10__
--,@if_is_rerun = 'N'

print '---sec users - same login name---'
SELECT src.fac_id as src_fac_id,src.long_username as 'long_username in FVE',dst.long_username as 'long_username in usei9',src.loginname as 'loginname in FVE',dst.loginname as 'loginname in usei9'
FROM [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei984.dbo.sec_user src
JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].us_vvhr.dbo.sec_user dst ON src.loginname = dst.loginname + 'FVE' 
      AND src.long_username <> dst.long_username 
      --AND src.fac_id in (40) 

