--select * from sec_user where loginname like '%SAVA'

select count(*) from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.sec_user where loginname like '%SAVA'

--if sec preimport
SELECT distinct src.long_username AS [Username in SAVA]
     , src.loginname AS [Existing Login in SAVA]
	 , dst.loginname + 'SAVA' AS [New Login in PGHC]
	 , dst.long_username AS [Existing Username in PGHC]
     , dst.loginname AS [Existing Login in PGHC]
FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.sec_user AS src INNER JOIN [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.sec_user AS dst ON src.loginname = dst.loginname
WHERE  src.userid IN (SELECT userid FROM pcc_temp_storage.dbo.EIcase59277183_PGHC_sec_user_samelogin_different_name)
	--OR src.userid IN (SELECT userid FROM pcc_temp_storage.dbo.EIcaseR_CASENUMBER2_PGHC_sec_user_samelogin_different_name)
	--OR src.userid IN (SELECT userid FROM pcc_temp_storage.dbo.EIcaseR_CASENUMBER3_PGHC_sec_user_samelogin_different_name)
	--OR src.userid IN (SELECT userid FROM pcc_temp_storage.dbo.EIcaseR_CASENUMBER4_PGHC_sec_user_samelogin_different_name)
	--OR src.userid IN (SELECT userid FROM pcc_temp_storage.dbo.EIcaseR_CASENUMBER5_PGHC_sec_user_samelogin_different_name)
	--OR src.userid IN (SELECT userid FROM pcc_temp_storage.dbo.EIcaseR_CASENUMBER6_PGHC_sec_user_samelogin_different_name)
	--OR src.userid IN (SELECT userid FROM pcc_temp_storage.dbo.EIcaseR_CASENUMBER7_PGHC_sec_user_samelogin_different_name)
	--OR src.userid IN (SELECT userid FROM pcc_temp_storage.dbo.EIcaseR_CASENUMBER8_PGHC_sec_user_samelogin_different_name)
	--OR src.userid IN (SELECT userid FROM pcc_temp_storage.dbo.EIcaseR_CASENUMBER9_PGHC_sec_user_samelogin_different_name)

--if sec regular import
select distinct src.long_username AS [Username in SAVA]
     , dst.loginname AS [Existing Login in SAVA]
	 , dst.loginname + 'SAVA' AS [New Login in PGHC]
	 , dst.long_username AS [Existing Username in PGHC]
     , dst.loginname AS [Existing Login in PGHC]
from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.sec_user src
JOIN [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.sec_user dst ON src.loginname = dst.loginname + 'SAVA'

--password for the excel file--pmo#59277_SAVA_to_PGHC