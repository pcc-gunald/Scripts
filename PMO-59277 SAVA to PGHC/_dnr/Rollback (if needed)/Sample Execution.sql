--backup list of tables - roollback

--Example of Online Rollback after SP is created. Run in reverse sequence of Data Copy

--ONLINE, 0
PRINT '--------------E23---------------'
EXEC Sp_EIDataRollback 'pcc_staging_db_multi_test_44916','EICase44916159','E23',159,0



--Example of Offline Rollback after SP is created:
--OFFLINE
PRINT '--------------OFFLINE---------------'
EXEC Sproc_EI_OffLine_Rollback 'pcc_staging_db_multi_test_44916'





