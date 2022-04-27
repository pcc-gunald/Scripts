USE [msdb]
GO

/****** Object:  Job [EI_Prepare_Staging__58872]    Script Date: 1/13/2022 9:20:19 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 1/13/2022 9:20:20 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'EI_Prepare_Staging__58872', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Job to prepare Staging DB Repo for EI PMO: 58872', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Email Notification Project Start]    Script Date: 1/13/2022 9:20:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Email Notification Project Start', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=21, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC msdb.dbo.sp_send_dbmail @recipients =''Dinesh.Gunalapan@pointclickcare.com'',
@subject=''This is a Test Run, PMO-58872'',
@body=''Hi All,</br></br> Data Copy for Org USEI587 is starting now.</br></br></br>Thanks,</br>
Facility Acquisition Team'',
@body_format=''HTML''', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Create Data Copy Tables on StagingDB]    Script Date: 1/13/2022 9:20:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Create Data Copy Tables on StagingDB', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=21, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE pcc_staging_db58872

EXEC [operational].[sproc_facacq_createDataCopyTables] 
@conv_server=''vmuspassvtsjob1.pccprod.local''
', 
		@database_name=N'pcc_staging_db58872', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Drop Views on StagingDB]    Script Date: 1/13/2022 9:20:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Drop Views on StagingDB', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=21, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE pcc_staging_db58872

EXEC [operational].[sproc_facacq_dropViews] 
', 
		@database_name=N'pcc_staging_db58872', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Disable triggers in StagingDB]    Script Date: 1/13/2022 9:20:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Disable triggers in StagingDB', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=21, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE pcc_staging_db58872

EXEC [operational].[sproc_facacq_disableTriggers] 
', 
		@database_name=N'pcc_staging_db58872', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Disable Constraints on StagingDB]    Script Date: 1/13/2022 9:20:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Disable Constraints on StagingDB', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=21, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE pcc_staging_db58872

EXEC [operational].[sproc_facacq_stagingDisableConstraints] 
', 
		@database_name=N'pcc_staging_db58872', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Soft Delete Facility on Destination DB]    Script Date: 1/13/2022 9:20:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Soft Delete Facility on Destination DB', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=21, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE pcc_staging_db58872
UPDATE [pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587.dbo.facility 
SET deleted = ''Y'',inactive_date = GETDATE() 
WHERE fac_id IN (68)', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Drop Existing mapping tables on StagingDB]    Script Date: 1/13/2022 9:20:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Drop Existing mapping tables on StagingDB', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=21, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE pcc_staging_db58872

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db58872'',@ModuleToCopy=''E1'',@prefix=''EICase588721'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db58872'',@ModuleToCopy=''E2'',@prefix=''EICase588721'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db58872'',@ModuleToCopy=''E2a'',@prefix=''EICase588721'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db58872'',@ModuleToCopy=''E3'',@prefix=''EICase588721'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db58872'',@ModuleToCopy=''E4'',@prefix=''EICase588721'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db58872'',@ModuleToCopy=''E5'',@prefix=''EICase588721'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db58872'',@ModuleToCopy=''E6'',@prefix=''EICase588721'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db58872'',@ModuleToCopy=''E7a'',@prefix=''EICase588721'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db58872'',@ModuleToCopy=''E7b'',@prefix=''EICase588721'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db58872'',@ModuleToCopy=''E7c'',@prefix=''EICase588721'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db58872'',@ModuleToCopy=''E8'',@prefix=''EICase588721'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db58872'',@ModuleToCopy=''E12a'',@prefix=''EICase588721'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db58872'',@ModuleToCopy=''E12b'',@prefix=''EICase588721'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db58872'',@ModuleToCopy=''E11'',@prefix=''EICase588721'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db58872'',@ModuleToCopy=''E9'',@prefix=''EICase588721'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db58872'',@ModuleToCopy=''E10'',@prefix=''EICase588721'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db58872'',@ModuleToCopy=''E13'',@prefix=''EICase588721'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db58872'',@ModuleToCopy=''E16'',@prefix=''EICase588721'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db58872'',@ModuleToCopy=''E17'',@prefix=''EICase588721'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db58872'',@ModuleToCopy=''E18'',@prefix=''EICase588721'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db58872'',@ModuleToCopy=''E20'',@prefix=''EICase588721'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db58872'',@ModuleToCopy=''E22'',@prefix=''EICase588721'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db58872'',@ModuleToCopy=''E23'',@prefix=''EICase588721'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''
', 
		@database_name=N'pcc_staging_db58872', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Clean EI Tables]    Script Date: 1/13/2022 9:20:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Clean EI Tables', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=21, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE pcc_staging_db58872
EXEC [operational].[sproc_facacq_cleanEITables] 
', 
		@database_name=N'pcc_staging_db58872', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Execute sproc_facacq_mergeDeleteCaseTables on StagingDB]    Script Date: 1/13/2022 9:20:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Execute sproc_facacq_mergeDeleteCaseTables on StagingDB', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=21, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE pcc_staging_db58872

EXEC [operational].[sproc_facacq_mergeDeleteCaseTables] @caseNo=''588721''', 
		@database_name=N'pcc_staging_db58872', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Add MultiFac ID column in each Table]    Script Date: 1/13/2022 9:20:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Add MultiFac ID column in each Table', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=21, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE pcc_staging_db58872
EXEC [operational].[sproc_facacq_stagingAddColumn] @prefix='''',@conv_server=''vmuspassvtsjob1.pccprod.local''', 
		@database_name=N'pcc_staging_db58872', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Disable Staging Trigger and Constraints]    Script Date: 1/13/2022 9:20:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Disable Staging Trigger and Constraints', 
		@step_id=11, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=21, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE pcc_staging_db58872
EXEC [operational].[sproc_facacq_DisableStagingTriggersAndConstraints] @ModuletoCopy=''''', 
		@database_name=N'pcc_staging_db58872', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase588721 Fac 6 to 68 : PRE    Custom on Source ******]    Script Date: 1/13/2022 9:20:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase588721 Fac 6 to 68 : PRE    Custom on Source ******', 
		@step_id=12, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=21, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET QUOTED_IDENTIFIER ON;
SET CONTEXT_INFO 0xDC1000000; 
SET DEADLOCK_PRIORITY 4;





ALTER TABLE test_usei630.dbo.ar_insurance_addresses
ADD  cc_temp_id INT;


ALTER TABLE pcc_staging_db58872.dbo.ar_insurance_addresses
ADD  cc_temp_id INT;


 update [test_usei630].dbo.pho_std_order
 set template_description=template_description+''_''
 where template_description=''Pneumovax''
 
 
update pcc_staging_db58872.dbo.mergejoinsmaster
set pkJoin = ''Y''
--select * from mergejoinsmaster
where tablename = ''as_std_assess_header'' and parenttable = ''id_type'' and pkJoin = ''N''

 
/*
IF OBJECT_ID(''pcc_staging_db58872.dbo.as_std_assess_header_temp'') IS NULL
CREATE TABLE pcc_staging_db58872.dbo.as_std_assess_header_temp 
											(std_assess_id INT,
											item_id INT,
											id_type_id INT,
											main_enabled CHAR(1),
											sub_enabled CHAR(1),
											InsertedDate DATETIME DEFAULT GETDATE()
											)
INSERT INTO pcc_staging_db58872.dbo.as_std_assess_header_temp 
(std_assess_id,item_id,id_type_id,main_enabled,sub_enabled)
SELECT *
FROM test_usei630.[dbo].as_std_assess_header A
WHERE 1 = 1
	AND item_id = 7106
	AND id_type_id = 2
	AND EXISTS(SELECT 1 FROM test_usei630.[dbo].as_std_assess_header B WHERE b.std_assess_id=a.std_assess_id AND b.item_id=a.item_id AND b.id_type_id=4)
	AND std_assess_id IN( 
12125,
12126,
1070 ,
10011,
10031,
10032,
10042,
10047,
10282)


DELETE B 
FROM pcc_staging_db58872.dbo.as_std_assess_header_temp  A
INNER JOIN test_usei630.[dbo].as_std_assess_header  B ON B.std_assess_id=a.std_assess_id AND  b.item_id=a.item_id AND b.id_type_id=a.id_type_id


*/



---------mapping------------------------------





print  CHAR(13) + ''Updating common code - dynamically through admin picklist excel file - Dynamic Admin Picklist running now only run for 1st facility'' 

UPDATE src--0 rows
SET src.item_description = dst.item_description
----SELECT a.item_code, a.src_Item_Id, a.src_Item_Description, b.dst_Item_Id, b.dst_Item_Description
----SELECT a.pick_list_name,a.src_Item_Description,dst.item_description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO58872_AdminPickList$] a
LEFT JOIN test_usei630.dbo.common_code AS src on src.item_id = a.src_item_id
LEFT JOIN [pccsql-use2-prod-w24-cli0023.ce22455c967a.database.windows.net].[us_hand_multi].dbo.common_code AS dst on dst.item_id = a.Map_DstItemId
WHERE 
	(
		a.pick_list_name IS NOT NULL -- total mapping provided by analyst to implementer							--
		AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer							--
		AND a.src_item_id IS NOT NULL --eliminate any incorrect provided mappings									--
		AND ISNUMERIC(a.map_dstitemid) = 1 --ignore any DNM or typo errors											--
		AND a.Map_DstItemId NOT IN --remove any dupilicate many to one mappings (Any If_merged not As_is or N)		--
			(
				select dst_Item_Id
				--select dst_Item_Id,if_merged
				from  [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO58872_AdminPickList$] a
				where dst_Item_Id in 
				(
					select map_dstitemid 
					FROM [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO58872_AdminPickList$]
					WHERE pick_list_name IS NOT NULL -- total mapping provided by analyst to implementer	
						AND map_dstitemid IS NOT NULL --total count of mapping provided by implementer		
						AND src_item_id IS NOT NULL --eliminate any incorrect provided mappings	
						AND ISNUMERIC(map_dstitemid) = 1
				)
				and a.If_Merged not in (''As_is'',''N'') -- will not take any record with ''Y''
			)
	)
	and a.id not in --remove any duplicate one to many mappings (2 or more occurances of one mapping)
		(
			select id 
			--select id, pick_list_name, src_item_description, map_dstitemid
			from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO58872_AdminPickList$] 
			where Map_DstItemId in
			(
				select Map_DstItemId
				--select Map_DstItemId, count(*)
				from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO58872_AdminPickList$] 
				where src_Item_Description is not null
				group by Map_DstItemId having count(*) > 1 and Map_DstItemId is NOT NULL
			)
			and id not in
			(			
				select min(id) 
				from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO58872_AdminPickList$] 
				group by map_dstitemid having map_dstitemid in 
					(
						select distinct Map_DstItemId 
						--select id, pick_list_name, src_item_description, map_dstitemid
						from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO58872_AdminPickList$] 
						where Map_DstItemId in
						(
							select Map_DstItemId
							--select Map_DstItemId, count(*)
							from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO58872_AdminPickList$] 
							group by Map_DstItemId having count(*) > 1 and Map_DstItemId is NOT NULL
						)
					)
			)
		)
	and src.item_id = a.src_Item_Id AND dst.item_id = a.Map_DstItemId AND src.item_code = a.item_code -- specifically used for updating the correct item
	--and src.item_id IN ( ???? ) -- any records that has to be excluded that you dont think is a proper merge
---------------------------------------------------
/*

*/
------------------------------------------------

print  CHAR(13) + ''Updating Resident Identifier admin templates - running now for 1st facilty '' 

 
UPDATE src
SET src.description = dst.description
--SELECT distinct a.srcIdTypeId, a.map_dst_typeid, src.description , dst.description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO58872_ResidentIdentifier$] a
JOIN [pccsql-use2-prod-ssv-tscon06.b4ea653240a9.database.windows.net].[test_usei630].dbo.id_type AS src on src.id_type_id = a.srcIdTypeId
JOIN [pccsql-use2-prod-w24-cli0023.ce22455c967a.database.windows.net].[us_hand_multi].dbo.id_type AS dst on dst.id_type_id = a.map_dst_typeid
WHERE  a.srcFieldName IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dst_typeid IS NOT NULL --total count of mapping provided by implementer  



----========================================================================================

print  CHAR(13) + ''Updating User Defined Fields admin templates - running now run for first facility'' 


UPDATE src
SET src.field_name = dst.field_name, src.field_length = dst.field_length
--SELECT distinct a.srcFieldTypeId, a.map_dst_typeid, src.field_name , dst.field_name, src.field_data_type, dst.field_data_type, src.field_length, dst.field_length, CASE WHEN src.field_data_type = dst.field_data_type AND src.field_length = dst.field_length THEN ''Possible to Merge'' ELSE ''Not Possible to Merge'' END as mergePossible
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO58872_UserDefinedData$] a
JOIN [pccsql-use2-prod-ssv-tscon06.b4ea653240a9.database.windows.net].[test_usei630].dbo.user_field_types AS src on src.field_type_id = a.srcFieldTypeId
JOIN [pccsql-use2-prod-w24-cli0023.ce22455c967a.database.windows.net].[us_hand_multi].dbo.user_field_types AS dst on dst.field_type_id = a.map_dst_typeid
WHERE  a.srcFieldName IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dst_typeid IS NOT NULL --total count of mapping provided by implementer  
AND src.field_data_type = dst.field_data_type --1 item returned, all good
--AND src.field_length = dst.field_length


/*

*/
--========================================================================================
-- Clinical Common Code
print  CHAR(13) + ''Updating common code - dynamically through clinical picklist excel file - Dynamic Clinical Picklist running now'' 

UPDATE src--1 row
SET src.item_description = dst.item_description
----SELECT a.item_code, a.src_Item_Id, a.src_Item_Description, b.dst_Item_Id, b.dst_Item_Description
----SELECT a.pick_list_name,a.src_Item_Description,dst.item_description,dst.item_id
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO58872_Clinical_common_code$] a
JOIN test_usei630.dbo.common_code AS src on src.item_id = a.src_item_id
JOIN [pccsql-use2-prod-w24-cli0023.ce22455c967a.database.windows.net].[us_hand_multi].dbo.common_code AS dst on dst.item_id = a.Map_DstItemId
WHERE 
	(
		a.pick_list_name IS NOT NULL -- total mapping provided by analyst to implementer							--
		AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer							--
		AND a.src_item_id IS NOT NULL --eliminate any incorrect provided mappings									--
		AND ISNUMERIC(a.map_dstitemid) = 1 --ignore any DNM or typo errors											--
		AND a.Map_DstItemId NOT IN --remove any dupilicate many to one mappings (Any If_merged not As_is or N)		--
			(
				select dst_Item_Id
				--select dst_Item_Id,if_merged
				from  [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO58872_Clinical_common_code$] a
				where dst_Item_Id in 
				(
					select map_dstitemid 
					FROM [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO58872_Clinical_common_code$]
					WHERE pick_list_name IS NOT NULL -- total mapping provided by analyst to implementer	
						AND map_dstitemid IS NOT NULL --total count of mapping provided by implementer		
						AND src_item_id IS NOT NULL --eliminate any incorrect provided mappings	
						AND ISNUMERIC(map_dstitemid) = 1
				)
				and a.If_Merged not in (''As_is'',''N'') -- will not take any record with ''Y''
			)
	)
	and a.id not in --remove any duplicate one to many mappings (2 or more occurances of one mapping)
		(
			select id 
			--select id, pick_list_name, src_item_description, map_dstitemid
			from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO58872_Clinical_common_code$] 
			where Map_DstItemId in
			(
				select Map_DstItemId
				--select Map_DstItemId, count(*)
				from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO58872_Clinical_common_code$] 
				where src_Item_Description is not null
				group by Map_DstItemId having count(*) > 1 and Map_DstItemId is NOT NULL
			)
			and id not in
			(			
				select min(id) 
				from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO58872_Clinical_common_code$] 
				group by map_dstitemid having map_dstitemid in 
					(
						select distinct Map_DstItemId 
						--select id, pick_list_name, src_item_description, map_dstitemid
						from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO58872_Clinical_common_code$] 
						where Map_DstItemId in
						(
							select Map_DstItemId
							--select Map_DstItemId, count(*)
							from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO58872_Clinical_common_code$] 
							group by Map_DstItemId having count(*) > 1 and Map_DstItemId is NOT NULL
						)
					)
			)
		)
	and src.item_id = a.src_Item_Id AND dst.item_id = a.Map_DstItemId AND src.item_code = a.item_code -- specifically used for updating the correct item
	--and src.item_id IN ( ???? ) -- any records that has to be excluded that you dont think is a proper merge
	
--========================================================================================

--print  CHAR(13) + ''Updating clinical picklist excel advanced file - Dynamic Clinical Picklist - others non-common code advanced running now first facility'' 

/*

select a.pick_list_name,a.src_desc,b.dst_desc
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO58872_Clinical_Advanced$] a
inner join [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO58872_Clinical_Advanced$] b 
on a.map_dstitemid = b.dst_id and a.pick_list_name = b.pick_list_name
where a.map_dstitemid is not null
AND  a.src_desc IS NOT NULL 
AND a.map_dstitemid IS NOT NULL 
order by a.id

*/

print  CHAR(13) + ''Updating Administration Records (pho_administration_record)''


UPDATE src
SET src.description = dst.description,src.short_description = dst.short_description
--SELECT distinct a.src_id, a.Map_DstItemId, src.description , dst.description,src.short_description, dst.short_description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO58872_Clinical_Advanced$] a
JOIN [pccsql-use2-prod-ssv-tscon06.b4ea653240a9.database.windows.net].[test_usei630].dbo.pho_administration_record AS src on src.administration_record_id = a.src_id
JOIN [pccsql-use2-prod-w24-cli0023.ce22455c967a.database.windows.net].[us_hand_multi].dbo.pho_administration_record AS dst on dst.administration_record_id = a.Map_DstItemId
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = ''Administration Records''  


print  CHAR(13) + ''Updating Order Types (pho_order_type)''


UPDATE src
SET src.description = dst.description
--SELECT distinct a.src_id, a.Map_DstItemId, src.description , dst.description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO58872_Clinical_Advanced$] a
JOIN [pccsql-use2-prod-ssv-tscon06.b4ea653240a9.database.windows.net].[test_usei630].dbo.pho_order_type AS src on src.order_type_id = a.src_id
JOIN [pccsql-use2-prod-w24-cli0023.ce22455c967a.database.windows.net].[us_hand_multi].dbo.pho_order_type AS dst on dst.order_type_id = a.Map_DstItemId
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = ''Order Types'' 


print  CHAR(13) + ''Updating Progress Note Types (pn_type)''



UPDATE src
SET src.description = dst.description
--SELECT distinct a.src_id, a.Map_DstItemId, src.description , dst.description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO58872_Clinical_Advanced$] a
JOIN [pccsql-use2-prod-ssv-tscon06.b4ea653240a9.database.windows.net].[test_usei630].dbo.pn_type AS src on src.pn_type_id = a.src_id
JOIN [pccsql-use2-prod-w24-cli0023.ce22455c967a.database.windows.net].[us_hand_multi].dbo.pn_type AS dst on dst.pn_type_id = a.Map_DstItemId
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = ''Progress Note Types''



print  CHAR(13) + ''Updating Immunizations - (cr_std_immunization)''



UPDATE src
SET src.description = dst.description,src.short_description = dst.short_description
--SELECT distinct a.src_id, a.Map_DstItemId, src.description , dst.description, src.short_description, dst.short_description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO58872_Clinical_Advanced$] a
JOIN [pccsql-use2-prod-ssv-tscon06.b4ea653240a9.database.windows.net].[test_usei630].dbo.cr_std_immunization AS src on src.std_immunization_id = a.src_id
JOIN [pccsql-use2-prod-w24-cli0023.ce22455c967a.database.windows.net].[us_hand_multi].dbo.cr_std_immunization AS dst on dst.std_immunization_id = a.Map_DstItemId
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = ''Immunizations''  --3 rows, NULLs


print  CHAR(13) + ''Updating Standard Shifts (cp_std_shift)''

UPDATE src
SET src.description = dst.description
--SELECT distinct a.src_id, a.Map_DstItemId, src.description , dst.description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO58872_Clinical_Advanced$] a
JOIN [pccsql-use2-prod-ssv-tscon06.b4ea653240a9.database.windows.net].[test_usei630].dbo.cp_std_shift AS src on src.std_shift_id = a.src_id
JOIN [pccsql-use2-prod-w24-cli0023.ce22455c967a.database.windows.net].[us_hand_multi].dbo.cp_std_shift AS dst on dst.std_shift_id = a.Map_DstItemId
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = ''Standard Shifts'' 


print  CHAR(13) + ''Updating Risk Management Picklists (inc_std_pick_list)''

--select * from [pccsql-use2-prod-w24-cli0023.ce22455c967a.database.windows.net].[us_hand_multi].dbo.mergeTablesmaster where tablename = ''inc_std_pick_list_item''
--description system_flag   pick_list_id
       --S        E              E

UPDATE src
SET src.description = dst.description
--SELECT distinct a.src_id, a.Map_DstItemId, src.description , dst.description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO58872_Clinical_Advanced$] a
JOIN [pccsql-use2-prod-ssv-tscon06.b4ea653240a9.database.windows.net].[test_usei630].dbo.inc_std_pick_list_item AS src on src.pick_list_item_id = a.src_id
JOIN [pccsql-use2-prod-w24-cli0023.ce22455c967a.database.windows.net].[us_hand_multi].dbo.inc_std_pick_list_item AS dst on dst.pick_list_item_id = a.Map_DstItemId
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = ''Risk Management Picklists'' 


', 
		@database_name=N'test_usei630', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase588721 Fac 6 to 68 : PRE    Standard on Source]    Script Date: 1/13/2022 9:20:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase588721 Fac 6 to 68 : PRE    Standard on Source', 
		@step_id=13, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=21, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use test_usei630

SET CONTEXT_INFO 0xDC1000000;
 SET DEADLOCK_PRIORITY 4;
 SET QUOTED_IDENTIFIER ON;

print (''-- PMO/Engagement: 58872'')
print (''-- CaseNo: EICase588721'')
print (''-- Source fac_id = 6'')
print (''-- Destination fac_id = 68'')
print (''-- Destination DB = [pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587'')

exec [operational].[sproc_facacq_pre_FixContactNumber]	@dest_DB_name = ''[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587''
exec [operational].[sproc_facacq_pre_FixContactNumber]	@dest_DB_name = ''pcc_staging_db58872''
exec [operational].[sproc_facacq_pre_IfDiagnosis]		@dest_database = ''[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587''
exec [operational].[sproc_facacq_pre_immunization_fix]	@fac_id = ''6''
exec [operational].[sproc_facacq_pre_scoping_CpSecUserAudit]	@fac_id = ''6''
exec [operational].[sproc_facacq_pre_scoping_extfac]			@fac_id = ''6''
exec [operational].[sproc_facacq_pre_scoping_userfieldtypes]	@fac_id = ''6''

update cp_std_intervention set std_freq_id = NULL from cp_std_intervention where std_freq_id is not NULL and std_freq_id in (0,30)
update cp_std_intervention set poc_std_freq_id = NULL from cp_std_intervention where poc_std_freq_id is not NULL

update as_std_question set pick_list_id = NULL
where pick_list_id not in (select pick_list_id from as_std_pick_list) and pick_list_id > 0
and std_assess_id in (select std_assess_id from as_std_assessment where deleted = ''Y'')

ALTER INDEX census_codes__facId_tableCode_shortDesc_IDX ON dbo.census_codes DISABLE;
exec [operational].[sproc_facacq_pre_mappingCensusCode]
@mapping_table_name = '' [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO58872_ActionCodes$]'',
@dest_database = ''[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587'',
@src_fac_id = ''6''

exec [operational].[sproc_facacq_pre_mappingCensusCode]
@mapping_table_name = ''[vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO58872_StatusCodes$]'',
@dest_database = ''[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587'',
@src_fac_id = ''6''

exec [operational].[sproc_facacq_pre_mappingUploadCategory]
@mapping_table_name = ''[vmuspassvtsjob1.pccprod.local].FacAcqMapping.[dbo].[PMO58872_UploadCategories$]'',
@dest_database = ''[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587''

PRINT ''--Copying UDA''
exec [operational].[sproc_facacq_pre_scoping_IfCopyUDA]		@fac_id = ''6''
exec [operational].[sproc_facacq_pre_IfUDA_DummyUDAScoping]	@source_fac_id = ''6''

PRINT ''--Adding UDA prefix''
exec [operational].[sproc_facacq_pre_ifMergeUDA_01_prefix] @prefix = ''ORCH-''

PRINT ''--Copying PN''
exec [operational].[sproc_facacq_pre_scoping_pn_type_and_template] @fac_id = ''6''

PRINT ''--Copying CP Library''
exec [operational].[sproc_facacq_pre_prefix_care_plan_library]
@fac_id = ''6''
,@prefix = ''ORCH-''
,@destDB = ''[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587''
,@destfacid = ''68''
,@libexclude = ''8,9''

exec [operational].[sproc_facacq_pre_ChangeLoginname] 
@fac_id = ''6'',
@suffix = ''ORCH'',
@dest_database = ''[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587''

PRINT ''--Copying Orders''
exec [operational].[sproc_facacq_pre_CheckShiftUsage] @fac_id = ''6''
exec [operational].[sproc_facacq_pre_IfOrder_StdOrderAndSet]
@fac_id = ''6'',
@dest_database = ''[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587'',
@suffix = ''_''
exec [operational].[sproc_facacq_pre_scoping_PhoOrderType] @fac_id = ''6''

PRINT ''--Copying Trust''
update a set a.gl_batch_id = null from ta_transaction a where gl_batch_id is not null
', 
		@database_name=N'test_usei630', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase588721 Fac 6 to 68 : PRE    on Destination (Sec User Gap Import)]    Script Date: 1/13/2022 9:20:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase588721 Fac 6 to 68 : PRE    on Destination (Sec User Gap Import)', 
		@step_id=14, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=21, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET CONTEXT_INFO 0xDC1000000;
 SET DEADLOCK_PRIORITY 4;
 SET QUOTED_IDENTIFIER ON;

exec [pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587.[operational].[sproc_facacq_pre_sec_user_GapImport_01_scoping]
@src_db_location = ''[pccsql-use2-prod-ssv-tscon06.b4ea653240a9.database.windows.net].test_usei630''
,@NS_case_number = ''EICase588721''
,@src_fac_id = ''6''

exec [pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587.[operational].[sproc_facacq_pre_sec_user_GapImport_02_Import]
@src_db_location = ''[pccsql-use2-prod-ssv-tscon06.b4ea653240a9.database.windows.net].test_usei630''
,@NS_case_number = ''EICase588721''
,@source_fac_id = ''6''
,@suffix = ''ORCH''
,@destination_org_id = ''10089''
,@destination_fac_id = ''68''
,@if_is_rerun = ''N''

', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase588721 Fac 6 to 68 : AUTO-PRE    on Staging]    Script Date: 1/13/2022 9:20:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase588721 Fac 6 to 68 : AUTO-PRE    on Staging', 
		@step_id=15, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=21, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use pcc_staging_db58872

SET CONTEXT_INFO 0xDC1000000;
 SET DEADLOCK_PRIORITY 4;
 SET QUOTED_IDENTIFIER ON;

exec [operational].[sproc_facacq_autopre_CCRSPicklistMergeerror] @csv_pick_list_ids = ''350,-70,300,301,302,303,304,305,306,307,308,309,310,311,312,313,314,315,316,317,318,319,320,321,322,323,324,325,326,327,328,329,330,331,332,333,334,335,336,337,338,340,342,344,345,346,348,349,351,352,353,354,355,360,361,362,363,364,365,366,367,713,714,1000348,1003028,1003029,1003030,1003031''

exec  [operational].[sproc_facacq_autopre_RemoveTableFromDataCopy] ''gl_batch''
exec  [operational].[sproc_facacq_autopre_RemoveTableFromDataCopy] ''ta_discharge_option''
exec  [operational].[sproc_facacq_autopre_RemoveTableFromDataCopy] ''ta_interest_calculate_method''

exec  [operational].[sproc_facacq_autopre_RemoveTableFromDataCopy] ''devprg_hist_medication_landing''
exec  [operational].[sproc_facacq_autopre_RemoveTableFromDataCopy] ''devprg_hist_care_period_landing''
exec  [operational].[sproc_facacq_autopre_RemoveTableFromDataCopy] ''devprg_hist_diagnosis_landing''
exec  [operational].[sproc_facacq_autopre_RemoveTableFromDataCopy] ''devprg_hist_medication_diagnosis_landing''
exec  [operational].[sproc_facacq_autopre_RemoveTableFromDataCopy] ''devprg_hist_medication_administration_schedule_landing''
exec  [operational].[sproc_facacq_autopre_RemoveTableFromDataCopy] ''pho_phys_order_linked_reason''

exec  [operational].[sproc_facacq_autopre_RemoveTableFromDataCopy] ''as_ard_adl_keys''

CREATE TABLE [dbo].[EICase588721sec_user]([row_id] [int] IDENTITY(1,1) NOT NULL,[src_id] [bigint] NULL,[dst_id] [bigint] NULL,[corporate] [char](1) NULL DEFAULT (''N'') ) ON [PRIMARY]
SET IDENTITY_INSERT EICase588721sec_user ON 
					insert into EICase588721sec_user (row_id,src_id,dst_id,corporate) 
					select row_id, src_id,dst_id,corporate from [pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587.dbo.EICase588721sec_user 
					SET IDENTITY_INSERT EICase588721sec_user OFF

UPDATE mergeTablesMaster SET queryfilter = replace(QueryFilter, ''[destDB]'', ''[stagDB]'') FROM mergeTablesMaster WHERE (QueryFilter LIKE ''%prefix%'' AND QueryFilter LIKE ''%destDB%'')
', 
		@database_name=N'pcc_staging_db58872', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase588721 Fac 6 to 68 : Source to Staging]    Script Date: 1/13/2022 9:20:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase588721 Fac 6 to 68 : Source to Staging', 
		@step_id=16, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=21, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE pcc_staging_db58872

IF NOT EXISTS(SELECT 1 FROM pcc_staging_db58872.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E1'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',@NewDB=''N'',
	@CaseNo=''588721'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase588721'',
	@sourceDB=''test_usei630'',	@fac_idToCopy=6,@reg_idToCopy=NULL,@fac_idToCopyTo=68,
	@ModuletoCopy=''E1'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',
	@stagingDB=''pcc_staging_db58872'',@destinationDB=''[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587'',	@RunIDFlag=1,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 588721 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db58872.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E2'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',@NewDB=''N'',
	@CaseNo=''588721'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase588721'',
	@sourceDB=''test_usei630'',	@fac_idToCopy=6,@reg_idToCopy=NULL,@fac_idToCopyTo=68,
	@ModuletoCopy=''E2'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',
	@stagingDB=''pcc_staging_db58872'',@destinationDB=''[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 588721 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db58872.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E3'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',@NewDB=''N'',
	@CaseNo=''588721'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase588721'',
	@sourceDB=''test_usei630'',	@fac_idToCopy=6,@reg_idToCopy=NULL,@fac_idToCopyTo=68,
	@ModuletoCopy=''E3'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',
	@stagingDB=''pcc_staging_db58872'',@destinationDB=''[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 588721 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db58872.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E4'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',@NewDB=''N'',
	@CaseNo=''588721'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase588721'',
	@sourceDB=''test_usei630'',	@fac_idToCopy=6,@reg_idToCopy=NULL,@fac_idToCopyTo=68,
	@ModuletoCopy=''E4'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',
	@stagingDB=''pcc_staging_db58872'',@destinationDB=''[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 588721 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db58872.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E5'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',@NewDB=''N'',
	@CaseNo=''588721'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase588721'',
	@sourceDB=''test_usei630'',	@fac_idToCopy=6,@reg_idToCopy=NULL,@fac_idToCopyTo=68,
	@ModuletoCopy=''E5'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',
	@stagingDB=''pcc_staging_db58872'',@destinationDB=''[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 588721 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db58872.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E6'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',@NewDB=''N'',
	@CaseNo=''588721'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase588721'',
	@sourceDB=''test_usei630'',	@fac_idToCopy=6,@reg_idToCopy=NULL,@fac_idToCopyTo=68,
	@ModuletoCopy=''E6'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',
	@stagingDB=''pcc_staging_db58872'',@destinationDB=''[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 588721 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db58872.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E7'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',@NewDB=''N'',
	@CaseNo=''588721'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase588721'',
	@sourceDB=''test_usei630'',	@fac_idToCopy=6,@reg_idToCopy=NULL,@fac_idToCopyTo=68,
	@ModuletoCopy=''E7'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',
	@stagingDB=''pcc_staging_db58872'',@destinationDB=''[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 588721 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db58872.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E8'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',@NewDB=''N'',
	@CaseNo=''588721'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase588721'',
	@sourceDB=''test_usei630'',	@fac_idToCopy=6,@reg_idToCopy=NULL,@fac_idToCopyTo=68,
	@ModuletoCopy=''E8'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',
	@stagingDB=''pcc_staging_db58872'',@destinationDB=''[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 588721 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db58872.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E12b'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',@NewDB=''N'',
	@CaseNo=''588721'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase588721'',
	@sourceDB=''test_usei630'',	@fac_idToCopy=6,@reg_idToCopy=NULL,@fac_idToCopyTo=68,
	@ModuletoCopy=''E12b'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',
	@stagingDB=''pcc_staging_db58872'',@destinationDB=''[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 588721 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db58872.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E11'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',@NewDB=''N'',
	@CaseNo=''588721'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase588721'',
	@sourceDB=''test_usei630'',	@fac_idToCopy=6,@reg_idToCopy=NULL,@fac_idToCopyTo=68,
	@ModuletoCopy=''E11'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',
	@stagingDB=''pcc_staging_db58872'',@destinationDB=''[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 588721 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db58872.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E9'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',@NewDB=''N'',
	@CaseNo=''588721'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase588721'',
	@sourceDB=''test_usei630'',	@fac_idToCopy=6,@reg_idToCopy=NULL,@fac_idToCopyTo=68,
	@ModuletoCopy=''E9'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',
	@stagingDB=''pcc_staging_db58872'',@destinationDB=''[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 588721 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db58872.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E10'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',@NewDB=''N'',
	@CaseNo=''588721'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase588721'',
	@sourceDB=''test_usei630'',	@fac_idToCopy=6,@reg_idToCopy=NULL,@fac_idToCopyTo=68,
	@ModuletoCopy=''E10'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',
	@stagingDB=''pcc_staging_db58872'',@destinationDB=''[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 588721 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db58872.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E13'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',@NewDB=''N'',
	@CaseNo=''588721'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase588721'',
	@sourceDB=''test_usei630'',	@fac_idToCopy=6,@reg_idToCopy=NULL,@fac_idToCopyTo=68,
	@ModuletoCopy=''E13'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',
	@stagingDB=''pcc_staging_db58872'',@destinationDB=''[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 588721 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db58872.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E16'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',@NewDB=''N'',
	@CaseNo=''588721'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase588721'',
	@sourceDB=''test_usei630'',	@fac_idToCopy=6,@reg_idToCopy=NULL,@fac_idToCopyTo=68,
	@ModuletoCopy=''E16'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',
	@stagingDB=''pcc_staging_db58872'',@destinationDB=''[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 588721 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db58872.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E17'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',@NewDB=''N'',
	@CaseNo=''588721'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase588721'',
	@sourceDB=''test_usei630'',	@fac_idToCopy=6,@reg_idToCopy=NULL,@fac_idToCopyTo=68,
	@ModuletoCopy=''E17'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',
	@stagingDB=''pcc_staging_db58872'',@destinationDB=''[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 588721 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db58872.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E18'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',@NewDB=''N'',
	@CaseNo=''588721'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase588721'',
	@sourceDB=''test_usei630'',	@fac_idToCopy=6,@reg_idToCopy=NULL,@fac_idToCopyTo=68,
	@ModuletoCopy=''E18'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',
	@stagingDB=''pcc_staging_db58872'',@destinationDB=''[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 588721 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db58872.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E20'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',@NewDB=''N'',
	@CaseNo=''588721'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase588721'',
	@sourceDB=''test_usei630'',	@fac_idToCopy=6,@reg_idToCopy=NULL,@fac_idToCopyTo=68,
	@ModuletoCopy=''E20'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',
	@stagingDB=''pcc_staging_db58872'',@destinationDB=''[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 588721 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db58872.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E22'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',@NewDB=''N'',
	@CaseNo=''588721'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase588721'',
	@sourceDB=''test_usei630'',	@fac_idToCopy=6,@reg_idToCopy=NULL,@fac_idToCopyTo=68,
	@ModuletoCopy=''E22'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',
	@stagingDB=''pcc_staging_db58872'',@destinationDB=''[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 588721 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db58872.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E23'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',@NewDB=''N'',
	@CaseNo=''588721'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase588721'',
	@sourceDB=''test_usei630'',	@fac_idToCopy=6,@reg_idToCopy=NULL,@fac_idToCopyTo=68,
	@ModuletoCopy=''E23'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'',
	@stagingDB=''pcc_staging_db58872'',@destinationDB=''[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei587'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 588721 : Source to Staging Step3 and Step4 Execution'', 1
END', 
		@database_name=N'pcc_staging_db58872', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase588721 Fac 6 to 68 : POST    on Staging (Scoping and Other)]    Script Date: 1/13/2022 9:20:21 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase588721 Fac 6 to 68 : POST    on Staging (Scoping and Other)', 
		@step_id=17, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=21, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE pcc_staging_db58872

exec [operational].[sproc_facacq_post_UpdatePayer]
@source_db = ''test_usei630''
,@destination_fac_id = ''68''
,@NSCaseNumber = ''EICase588721''
,@payer_mapping_bkp = ''[vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.PMO58872_EICase588721_payermapping_fac_6_to_68''

exec [operational].[sproc_facacq_post_UpdateRoomRateType]
@source_db = ''test_usei630''
,@destination_fac_id = ''68''
,@NSCaseNumber = ''EICase588721''
,@roomratetype_mapping_bkp = ''[vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO58872_RoomRateType$]''
,@MA_dst_id = ''197''

', 
		@database_name=N'pcc_staging_db58872', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase588721 Fac 6 to 68 : Backup Staging DB between Facilities]    Script Date: 1/13/2022 9:20:21 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase588721 Fac 6 to 68 : Backup Staging DB between Facilities', 
		@step_id=18, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=21, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--USE pcc_staging_db58872 DBCC SHRINKFILE (2,0,TRUNCATEONLY)

USE MASTER
BACKUP DATABASE [pcc_staging_db58872] TO URL = ''https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1733/pcc_staging_db58872_Case588721_20220112183935_1.BAK'', URL = ''https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1733/pcc_staging_db58872_Case588721_20220112183935_2.BAK'', URL = ''https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1733/pcc_staging_db58872_Case588721_20220112183935_3.BAK'', URL = ''https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1733/pcc_staging_db58872_Case588721_20220112183935_4.BAK''
 WITH COPY_ONLY, FORMAT, INIT, COMPRESSION, STATS=10', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Final Backup of Staging DB]    Script Date: 1/13/2022 9:20:21 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Final Backup of Staging DB', 
		@step_id=19, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=21, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE MASTER
BACKUP DATABASE [pcc_staging_db58872] TO URL = ''https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1733/Final/pcc_staging_db58872_Case588721_20220112183935_1.BAK'', URL = ''https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1733/Final/pcc_staging_db58872_Case588721_20220112183935_2.BAK'', URL = ''https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1733/Final/pcc_staging_db58872_Case588721_20220112183935_3.BAK'', URL = ''https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1733/Final/pcc_staging_db58872_Case588721_20220112183935_4.BAK''
 WITH COPY_ONLY, FORMAT, INIT, COMPRESSION, STATS=10', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Kickoff Staging to Destination Job]    Script Date: 1/13/2022 9:20:21 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Kickoff Staging to Destination Job', 
		@step_id=20, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=21, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC [pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].MSDB.dbo.SP_START_JOB @job_name="EI_Prepare_Destination__58872"', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [TS Job Failure Email Notification]    Script Date: 1/13/2022 9:20:21 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'TS Job Failure Email Notification', 
		@step_id=21, 
		@cmdexec_success_code=0, 
		@on_success_action=2, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE pcc_staging_db58872
EXEC [operational].[sproc_facacq_sendEmailNotification] @Recipient = ''Dinesh.Gunalapan@pointclickcare.com''
					,@BlindCopyRecipients = ''TSFacAcqConfig@pointclickcare.com''
					,@JobName = ''EI_Prepare_Staging__58872 ''
					,@ServerName = ''[pccsql-use2-prod-ssv-tscon06.b4ea653240a9.database.windows.net]''', 
		@database_name=N'pcc_staging_db58872', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


