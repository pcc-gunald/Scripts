

exec  [operational].[sproc_facacq_autopre_RemoveTableFromDataCopy] 'as_service_change_detail'
exec  [operational].[sproc_facacq_autopre_RemoveTableFromDataCopy] 'as_service_change_notification_service_level_snapshot'
exec  [operational].[sproc_facacq_autopre_RemoveTableFromDataCopy] 'census_item_secondary_rate'
exec  [operational].[sproc_facacq_autopre_RemoveTableFromDataCopy] 'as_ard_adl_usei23s'

UPDATE mergetablesmaster SET QueryFilter = ' AND pick_list_id NOT IN (SELECT pick_list_id from [origDB].as_std_pick_list where std_assess_id = 3 AND fac_id = -1) AND pick_list_id NOT IN (350) ' WHERE tablename = 'as_std_pick_list'

EXEC [pccsql-use2-prod-w25-cli0021.2d62ac5c7640.database.windows.net].MSDB.dbo.SP_START_JOB @job_name="EI_Prepare_Destination__010798"

----add om 2nd facility

exec  [operational].[sproc_facacq_autopre_RemoveTableFromDataCopy] 'cp_std_lib_departments'
exec  [operational].[sproc_facacq_autopre_RemoveTableFromDataCopy] 'cp_std_lib_positions'

