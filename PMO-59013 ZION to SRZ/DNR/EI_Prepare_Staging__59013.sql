USE [msdb]
GO

/****** Object:  Job [EI_Prepare_Staging__59013]    Script Date: 1/13/2022 7:41:34 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 1/13/2022 7:41:34 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'EI_Prepare_Staging__59013', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Job to prepare Staging DB Repo for EI PMO: 59013', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Email Notification Project Start]    Script Date: 1/13/2022 7:41:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Email Notification Project Start', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=29, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC msdb.dbo.sp_send_dbmail @recipients =''Ashlee.Moss@pointclickcare.com;Suzette.Edgar@pointclickcare.com;Keith.Tomaszewski@pointclickcare.com;Adrian.Rizos@pointclickcare.com;TSFacAcqConfig@pointclickcare.com;melodee.mercado@pointclickcare.com;Laurie.Watkins@pointclickcare.com;jstroder@daashc.com;lalaran@daashc.com;'',
@subject=''Scheduled Data Copy January 10, PMO - 59013'',
@body=''Hi All,</br></br> Data Copy for Org SRZ is starting now.</br></br></br>Thanks,</br>
Facility Acquisition Team'',
@body_format=''HTML''', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Setup Source Restore with SP]    Script Date: 1/13/2022 7:41:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Setup Source Restore with SP', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=29, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF EXISTS(select * from sys.databases where name=''test_usei1058'') BEGIN DROP DATABASE test_usei1058 END

WAITFOR DELAY ''00:05:00''

DECLARE @return_value INT, @vRequestId INT, @error_msg NVARCHAR(max),@restoretime DATETIME = getdate() 
EXEC @return_value = [vmuspassvjob001.pccprod.local].[azure_restore].[dbo].[create_restore_request] 
@source_instance = ''pccsql-use2-prod-w26-cli0026.d9c23db323d7.database.windows.net''  
,@source_Database_name = ''us_zion_multi'' 
,@destination_instance = ''pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net''
,@destination_database_name = ''test_usei1058''
,@point_in_time = @restoretime
,@requestor = ''gunald''
,@requestid = @vRequestId OUTPUT
DECLARE @statusout CHAR(1) = NULL, @statusmessageout VARCHAR(2000) = NULL
WHILE (1 = 1)
 BEGIN 
 WAITFOR DELAY ''00:02:00''
	EXEC [vmuspassvjob001.pccprod.local].[azure_restore].[dbo].[check_status] @requestid = @vRequestId 
,@status = @statusout OUTPUT 
,@status_message = @statusmessageout OUTPUT 
	IF (@statusout NOT IN (''N'',''S'')) 
	BREAK 
END
SELECT @statusout = NULL,@statusmessageout = NULL
EXEC [vmuspassvjob001.pccprod.local].[azure_restore].[dbo].[check_status] @requestid = @vRequestId
,@status = @statusout OUTPUT
,@status_message = @statusmessageout OUTPUT

IF (@statusout = ''E'' AND @statusout <> ''C'')

BEGIN SELECT @error_msg = @statusmessageout
RAISERROR (@error_msg,16,1)
RETURN; END
ELSE IF (@statusout <> ''E'' AND @statusout <> ''C'')
 BEGIN SELECT @error_msg = ''Error occurred during restore: Invalid status returned.''
 RAISERROR (@error_msg,16,1)
 RETURN;END 
', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Create Data Copy Tables on StagingDB]    Script Date: 1/13/2022 7:41:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Create Data Copy Tables on StagingDB', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=29, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE pcc_staging_db59013

EXEC [operational].[sproc_facacq_createDataCopyTables] 
@conv_server=''vmuspassvtsjob1.pccprod.local''
', 
		@database_name=N'pcc_staging_db59013', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Drop Views on StagingDB]    Script Date: 1/13/2022 7:41:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Drop Views on StagingDB', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=29, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE pcc_staging_db59013

EXEC [operational].[sproc_facacq_dropViews] 
', 
		@database_name=N'pcc_staging_db59013', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Disable triggers in StagingDB]    Script Date: 1/13/2022 7:41:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Disable triggers in StagingDB', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=29, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE pcc_staging_db59013

EXEC [operational].[sproc_facacq_disableTriggers] 
', 
		@database_name=N'pcc_staging_db59013', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Disable Constraints on StagingDB]    Script Date: 1/13/2022 7:41:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Disable Constraints on StagingDB', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=29, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE pcc_staging_db59013

EXEC [operational].[sproc_facacq_stagingDisableConstraints] 
', 
		@database_name=N'pcc_staging_db59013', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Soft Delete Facility on Destination DB]    Script Date: 1/13/2022 7:41:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Soft Delete Facility on Destination DB', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=29, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE pcc_staging_db59013
UPDATE [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi.dbo.facility 
SET deleted = ''Y'',inactive_date = GETDATE() 
WHERE fac_id IN (29,30)', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Drop Existing mapping tables on StagingDB]    Script Date: 1/13/2022 7:41:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Drop Existing mapping tables on StagingDB', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=29, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE pcc_staging_db59013

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E1'',@prefix=''EICase590131'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E2'',@prefix=''EICase590131'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E2a'',@prefix=''EICase590131'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E3'',@prefix=''EICase590131'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E4'',@prefix=''EICase590131'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E5'',@prefix=''EICase590131'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E6'',@prefix=''EICase590131'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E7a'',@prefix=''EICase590131'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E7b'',@prefix=''EICase590131'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E7c'',@prefix=''EICase590131'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E8'',@prefix=''EICase590131'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E12a'',@prefix=''EICase590131'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E12b'',@prefix=''EICase590131'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E11'',@prefix=''EICase590131'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E9'',@prefix=''EICase590131'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E10'',@prefix=''EICase590131'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E16'',@prefix=''EICase590131'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E13'',@prefix=''EICase590131'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E17'',@prefix=''EICase590131'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E18'',@prefix=''EICase590131'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E20'',@prefix=''EICase590131'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E21'',@prefix=''EICase590131'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E22'',@prefix=''EICase590131'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E23'',@prefix=''EICase590131'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E1'',@prefix=''EICase590132'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E2'',@prefix=''EICase590132'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E2a'',@prefix=''EICase590132'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E3'',@prefix=''EICase590132'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E4'',@prefix=''EICase590132'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E5'',@prefix=''EICase590132'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E6'',@prefix=''EICase590132'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E7a'',@prefix=''EICase590132'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E7b'',@prefix=''EICase590132'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E7c'',@prefix=''EICase590132'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E8'',@prefix=''EICase590132'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E12a'',@prefix=''EICase590132'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E12b'',@prefix=''EICase590132'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E11'',@prefix=''EICase590132'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E9'',@prefix=''EICase590132'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E10'',@prefix=''EICase590132'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E16'',@prefix=''EICase590132'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E13'',@prefix=''EICase590132'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E17'',@prefix=''EICase590132'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E18'',@prefix=''EICase590132'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E20'',@prefix=''EICase590132'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E21'',@prefix=''EICase590132'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E22'',@prefix=''EICase590132'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''

EXEC [operational].[sproc_facacq_dropExistingMappingTables] 
@dbStag=''pcc_staging_db59013'',@ModuleToCopy=''E23'',@prefix=''EICase590132'',@ContinueMerge=''0'',@conv_server=''vmuspassvtsjob1.pccprod.local''
', 
		@database_name=N'pcc_staging_db59013', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Clean EI Tables]    Script Date: 1/13/2022 7:41:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Clean EI Tables', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=29, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE pcc_staging_db59013
EXEC [operational].[sproc_facacq_cleanEITables] 
', 
		@database_name=N'pcc_staging_db59013', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Execute sproc_facacq_mergeDeleteCaseTables on StagingDB]    Script Date: 1/13/2022 7:41:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Execute sproc_facacq_mergeDeleteCaseTables on StagingDB', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=29, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE pcc_staging_db59013

EXEC [operational].[sproc_facacq_mergeDeleteCaseTables] @caseNo=''590131''
EXEC [operational].[sproc_facacq_mergeDeleteCaseTables] @caseNo=''590132''', 
		@database_name=N'pcc_staging_db59013', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Add MultiFac ID column in each Table]    Script Date: 1/13/2022 7:41:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Add MultiFac ID column in each Table', 
		@step_id=11, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=29, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE pcc_staging_db59013
EXEC [operational].[sproc_facacq_stagingAddColumn] @prefix='''',@conv_server=''vmuspassvtsjob1.pccprod.local''', 
		@database_name=N'pcc_staging_db59013', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Disable Staging Trigger and Constraints]    Script Date: 1/13/2022 7:41:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Disable Staging Trigger and Constraints', 
		@step_id=12, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=29, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE pcc_staging_db59013
EXEC [operational].[sproc_facacq_DisableStagingTriggersAndConstraints] @ModuletoCopy=''''', 
		@database_name=N'pcc_staging_db59013', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase590131 Fac 29 to 29 : PRE    Custom on Source ******]    Script Date: 1/13/2022 7:41:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase590131 Fac 29 to 29 : PRE    Custom on Source ******', 
		@step_id=13, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=29, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
SET QUOTED_IDENTIFIER ON;
SET CONTEXT_INFO 0xDC1000000; 
SET DEADLOCK_PRIORITY 4;



print  CHAR(13) + '' prefix sec_roles (only if requested specially)'' 

update sec_role 
set description = ''ZION-'' + description 
--select * 
from sec_role 
where (system_field <> ''Y'' or system_field is null)
and description not like ''ZION%''


/*
update pcc_staging_db59013.dbo.mergeJoinsMaster
set pkJoin = ''Y''
--select * from mergejoinsmaster
where tablename = ''as_std_assess_header'' and parenttable = ''id_type'' and pkJoin = ''N''

*/


---------mapping------------------------------





print  CHAR(13) + ''Updating common code - dynamically through admin picklist excel file - Dynamic Admin Picklist running now only run for 1st facility'' 

UPDATE src--0 rows
SET src.item_description = dst.item_description
----SELECT a.item_code, a.src_Item_Id, a.src_Item_Description, b.dst_Item_Id, b.dst_Item_Description
----SELECT a.pick_list_name,a.src_Item_Description,dst.item_description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_AdminPickList$] a
LEFT JOIN [test_usei1058].dbo.common_code AS src on src.item_id = a.src_item_id
LEFT JOIN [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].[us_srz_multi].dbo.common_code AS dst on dst.item_id = a.Map_DstItemId
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
				from  [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_AdminPickList$] a
				where dst_Item_Id in 
				(
					select map_dstitemid 
					FROM [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_AdminPickList$]
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
			from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_AdminPickList$] 
			where Map_DstItemId in
			(
				select Map_DstItemId
				--select Map_DstItemId, count(*)
				from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_AdminPickList$] 
				where src_Item_Description is not null
				group by Map_DstItemId having count(*) > 1 and Map_DstItemId is NOT NULL
			)
			and id not in
			(			
				select min(id) 
				from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_AdminPickList$] 
				group by map_dstitemid having map_dstitemid in 
					(
						select distinct Map_DstItemId 
						--select id, pick_list_name, src_item_description, map_dstitemid
						from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_AdminPickList$] 
						where Map_DstItemId in
						(
							select Map_DstItemId
							--select Map_DstItemId, count(*)
							from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_AdminPickList$] 
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
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_ResidentIdentifier$] a
JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].[test_usei1058].dbo.id_type AS src on src.id_type_id = a.srcIdTypeId
JOIN [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].[us_srz_multi].dbo.id_type AS dst on dst.id_type_id = a.map_dst_typeid
WHERE  a.srcFieldName IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dst_typeid IS NOT NULL --total count of mapping provided by implementer  



----========================================================================================

print  CHAR(13) + ''Updating User Defined Fields admin templates - running now run for first facility'' 


UPDATE src
SET src.field_name = dst.field_name, src.field_length = dst.field_length
--SELECT distinct a.srcFieldTypeId, a.map_dst_typeid, src.field_name , dst.field_name, src.field_data_type, dst.field_data_type, src.field_length, dst.field_length, CASE WHEN src.field_data_type = dst.field_data_type AND src.field_length = dst.field_length THEN ''Possible to Merge'' ELSE ''Not Possible to Merge'' END as mergePossible
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_UserDefinedData$] a
JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].[test_usei1058].dbo.user_field_types AS src on src.field_type_id = a.srcFieldTypeId
JOIN [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].[us_srz_multi].dbo.user_field_types AS dst on dst.field_type_id = a.map_dst_typeid
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
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_Clinical_common_code$] a
JOIN test_usei1058.dbo.common_code AS src on src.item_id = a.src_item_id
JOIN [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].[us_srz_multi].dbo.common_code AS dst on dst.item_id = a.Map_DstItemId
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
				from  [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_Clinical_common_code$] a
				where dst_Item_Id in 
				(
					select map_dstitemid 
					FROM [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_Clinical_common_code$]
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
			from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_Clinical_common_code$] 
			where Map_DstItemId in
			(
				select Map_DstItemId
				--select Map_DstItemId, count(*)
				from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_Clinical_common_code$] 
				where src_Item_Description is not null
				group by Map_DstItemId having count(*) > 1 and Map_DstItemId is NOT NULL
			)
			and id not in
			(			
				select min(id) 
				from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_Clinical_common_code$] 
				group by map_dstitemid having map_dstitemid in 
					(
						select distinct Map_DstItemId 
						--select id, pick_list_name, src_item_description, map_dstitemid
						from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_Clinical_common_code$] 
						where Map_DstItemId in
						(
							select Map_DstItemId
							--select Map_DstItemId, count(*)
							from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_Clinical_common_code$] 
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
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_Clinical_Advanced$] a
inner join [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_Clinical_Advanced$] b 
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
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_Clinical_Advanced$] a
JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].[test_usei1058].dbo.pho_administration_record AS src on src.administration_record_id = a.src_id
JOIN [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].[us_srz_multi].dbo.pho_administration_record AS dst on dst.administration_record_id = a.Map_DstItemId
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = ''Administration Records''  


print  CHAR(13) + ''Updating Order Types (pho_order_type)''


UPDATE src
SET src.description = dst.description
--SELECT distinct a.src_id, a.Map_DstItemId, src.description , dst.description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_Clinical_Advanced$] a
JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].[test_usei1058].dbo.pho_order_type AS src on src.order_type_id = a.src_id
JOIN [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].[us_srz_multi].dbo.pho_order_type AS dst on dst.order_type_id = a.Map_DstItemId
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = ''Order Types'' 


print  CHAR(13) + ''Updating Progress Note Types (pn_type)''



UPDATE src
SET src.description = dst.description
--SELECT distinct a.src_id, a.Map_DstItemId, src.description , dst.description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_Clinical_Advanced$] a
JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].[test_usei1058].dbo.pn_type AS src on src.pn_type_id = a.src_id
JOIN [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].[us_srz_multi].dbo.pn_type AS dst on dst.pn_type_id = a.Map_DstItemId
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = ''Progress Note Types''



print  CHAR(13) + ''Updating Immunizations - (cr_std_immunization)''



UPDATE src
SET src.description = dst.description,src.short_description = dst.short_description
--SELECT distinct a.src_id, a.Map_DstItemId, src.description , dst.description, src.short_description, dst.short_description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_Clinical_Advanced$] a
JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].[test_usei1058].dbo.cr_std_immunization AS src on src.std_immunization_id = a.src_id
JOIN [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].[us_srz_multi].dbo.cr_std_immunization AS dst on dst.std_immunization_id = a.Map_DstItemId
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = ''Immunizations''  --3 rows, NULLs


print  CHAR(13) + ''Updating Standard Shifts (cp_std_shift)''

UPDATE src
SET src.description = dst.description
--SELECT distinct a.src_id, a.Map_DstItemId, src.description , dst.description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_Clinical_Advanced$] a
JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].[test_usei1058].dbo.cp_std_shift AS src on src.std_shift_id = a.src_id
JOIN [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].[us_srz_multi].dbo.cp_std_shift AS dst on dst.std_shift_id = a.Map_DstItemId
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = ''Standard Shifts'' 


print  CHAR(13) + ''Updating Risk Management Picklists (inc_std_pick_list)''

--select * from [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].[us_srz_multi].dbo.mergeTablesmaster where tablename = ''inc_std_pick_list_item''
--description system_flag   pick_list_id
       --S        E              E

UPDATE src
SET src.description = dst.description
--SELECT distinct a.src_id, a.Map_DstItemId, src.description , dst.description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_Clinical_Advanced$] a
JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].[test_usei1058].dbo.inc_std_pick_list_item AS src on src.pick_list_item_id = a.src_id
JOIN [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].[us_srz_multi].dbo.inc_std_pick_list_item AS dst on dst.pick_list_item_id = a.Map_DstItemId
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = ''Risk Management Picklists'' 


', 
		@database_name=N'test_usei1058', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase590131 Fac 29 to 29 : PRE    Standard on Source]    Script Date: 1/13/2022 7:41:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase590131 Fac 29 to 29 : PRE    Standard on Source', 
		@step_id=14, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=29, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use test_usei1058

SET CONTEXT_INFO 0xDC1000000;
 SET DEADLOCK_PRIORITY 4;
 SET QUOTED_IDENTIFIER ON;

print (''-- PMO/Engagement: 59013'')
print (''-- CaseNo: EICase590131'')
print (''-- Source fac_id = 29'')
print (''-- Destination fac_id = 29'')
print (''-- Destination DB = [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'')

exec [operational].[sproc_facacq_pre_FixContactNumber]	@dest_DB_name = ''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi''
exec [operational].[sproc_facacq_pre_FixContactNumber]	@dest_DB_name = ''pcc_staging_db59013''
exec [operational].[sproc_facacq_pre_IfDiagnosis]		@dest_database = ''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi''
exec [operational].[sproc_facacq_pre_immunization_fix]	@fac_id = ''29''
exec [operational].[sproc_facacq_pre_scoping_CpSecUserAudit]	@fac_id = ''29''
exec [operational].[sproc_facacq_pre_scoping_extfac]			@fac_id = ''29''
exec [operational].[sproc_facacq_pre_scoping_userfieldtypes]	@fac_id = ''29''

update cp_std_intervention set std_freq_id = NULL from cp_std_intervention where std_freq_id is not NULL and std_freq_id in (0,30)
update cp_std_intervention set poc_std_freq_id = NULL from cp_std_intervention where poc_std_freq_id is not NULL

ALTER INDEX census_codes__facId_tableCode_shortDesc_IDX ON dbo.census_codes DISABLE;
exec [operational].[sproc_facacq_pre_mappingCensusCode]
@mapping_table_name = ''[vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_ActionCodes$]'',
@dest_database = ''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',
@src_fac_id = ''29''

exec [operational].[sproc_facacq_pre_mappingCensusCode]
@mapping_table_name = ''[vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_StatusCodes$]'',
@dest_database = ''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',
@src_fac_id = ''29''

exec [operational].[sproc_facacq_pre_mappingUploadCategory]
@mapping_table_name = ''[vmuspassvtsjob1.pccprod.local].FacAcqMapping.[dbo].[PMO59013_UploadCategories$]'',
@dest_database = ''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi''

PRINT ''--Copying UDA''
exec [operational].[sproc_facacq_pre_scoping_IfCopyUDA]		@fac_id = ''29''
exec [operational].[sproc_facacq_pre_IfUDA_DummyUDAScoping]	@source_fac_id = ''29''

PRINT ''--Adding UDA prefix''
exec [operational].[sproc_facacq_pre_ifMergeUDA_01_prefix] @prefix = ''ZION-''

PRINT ''--UDA Merge pick list''
exec [operational].[sproc_facacq_pre_ifMergeUDA_02_as_std_pick_list] @NSCaseNumber = ''EICase590131''

PRINT ''--Copying PN''
exec [operational].[sproc_facacq_pre_scoping_pn_type_and_template] @fac_id = ''29''

PRINT ''--Copying CP Library''
exec [operational].[sproc_facacq_pre_prefix_care_plan_library]
@fac_id = ''29''
,@prefix = ''ZION-''
,@destDB = ''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi''
,@destfacid = ''29''
,@libexclude = ''8,9''

exec [operational].[sproc_facacq_pre_ChangeLoginname] 
@fac_id = ''29'',
@suffix = ''ZION'',
@dest_database = ''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi''

PRINT ''--Copying Orders''
exec [operational].[sproc_facacq_pre_CheckShiftUsage] @fac_id = ''29''
exec [operational].[sproc_facacq_pre_IfOrder_StdOrderAndSet]
@fac_id = ''29'',
@dest_database = ''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',
@suffix = ''_''
exec [operational].[sproc_facacq_pre_scoping_PhoOrderType] @fac_id = ''29''

PRINT ''--Copying Trust''
update a set a.gl_batch_id = null from ta_transaction a where gl_batch_id is not null
', 
		@database_name=N'test_usei1058', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase590131 Fac 29 to 29 : PRE    on Destination (Sec User Gap Import)]    Script Date: 1/13/2022 7:41:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase590131 Fac 29 to 29 : PRE    on Destination (Sec User Gap Import)', 
		@step_id=15, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=29, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET CONTEXT_INFO 0xDC1000000;
 SET DEADLOCK_PRIORITY 4;
 SET QUOTED_IDENTIFIER ON;

exec [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi.[operational].[sproc_facacq_pre_sec_user_GapImport_01_scoping]
@src_db_location = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058''
,@NS_case_number = ''EICase590131''
,@src_fac_id = ''29''

exec [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi.[operational].[sproc_facacq_pre_sec_user_GapImport_02_Import]
@src_db_location = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058''
,@NS_case_number = ''EICase590131''
,@source_fac_id = ''29''
,@suffix = ''ZION''
,@destination_org_id = ''1504957707''
,@destination_fac_id = ''29''
,@if_is_rerun = ''N''

', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase590131 Fac 29 to 29 : AUTO-PRE    on Staging]    Script Date: 1/13/2022 7:41:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase590131 Fac 29 to 29 : AUTO-PRE    on Staging', 
		@step_id=16, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=29, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use pcc_staging_db59013

SET CONTEXT_INFO 0xDC1000000;
 SET DEADLOCK_PRIORITY 4;
 SET QUOTED_IDENTIFIER ON;

exec [operational].[sproc_facacq_autopre_CCRSPicklistMergeerror] @csv_pick_list_ids = ''350,713, 714, 1000348, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313, -70, 315, 316, 317, 314, 318, 319, 320, 321, 322, 323, 324, 325, 326, 327, 328, 329, 330, 331, 332, 333, 334, 335, 336, 337, 338, 340, 1000891, 342, 344, 345, 346, 1000892, 348, 349, 351, 352, 353, 354, 355, 1000893, 1000894, 360, 361, 362, 363, 364, 365, 366, 367''

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

CREATE TABLE [dbo].[EICase590131sec_user]([row_id] [int] IDENTITY(1,1) NOT NULL,[src_id] [bigint] NULL,[dst_id] [bigint] NULL,[corporate] [char](1) NULL DEFAULT (''N'') ) ON [PRIMARY]
SET IDENTITY_INSERT EICase590131sec_user ON 
					insert into EICase590131sec_user (row_id,src_id,dst_id,corporate) 
					select row_id, src_id,dst_id,corporate from [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi.dbo.EICase590131sec_user 
					SET IDENTITY_INSERT EICase590131sec_user OFF

UPDATE mergeTablesMaster SET queryfilter = replace(QueryFilter, ''[destDB]'', ''[stagDB]'') FROM mergeTablesMaster WHERE (QueryFilter LIKE ''%prefix%'' AND QueryFilter LIKE ''%destDB%'')
', 
		@database_name=N'pcc_staging_db59013', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase590131 Fac 29 to 29 : Source to Staging]    Script Date: 1/13/2022 7:41:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase590131 Fac 29 to 29 : Source to Staging', 
		@step_id=17, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=29, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE pcc_staging_db59013

IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E1'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590131'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590131'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=29,@reg_idToCopy=NULL,@fac_idToCopyTo=29,
	@ModuletoCopy=''E1'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=1,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E2'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590131'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590131'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=29,@reg_idToCopy=NULL,@fac_idToCopyTo=29,
	@ModuletoCopy=''E2'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E3'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590131'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590131'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=29,@reg_idToCopy=NULL,@fac_idToCopyTo=29,
	@ModuletoCopy=''E3'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E4'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590131'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590131'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=29,@reg_idToCopy=NULL,@fac_idToCopyTo=29,
	@ModuletoCopy=''E4'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E5'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590131'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590131'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=29,@reg_idToCopy=NULL,@fac_idToCopyTo=29,
	@ModuletoCopy=''E5'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E6'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590131'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590131'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=29,@reg_idToCopy=NULL,@fac_idToCopyTo=29,
	@ModuletoCopy=''E6'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E7'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590131'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590131'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=29,@reg_idToCopy=NULL,@fac_idToCopyTo=29,
	@ModuletoCopy=''E7'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E8'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590131'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590131'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=29,@reg_idToCopy=NULL,@fac_idToCopyTo=29,
	@ModuletoCopy=''E8'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E12b'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590131'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590131'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=29,@reg_idToCopy=NULL,@fac_idToCopyTo=29,
	@ModuletoCopy=''E12b'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E11'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590131'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590131'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=29,@reg_idToCopy=NULL,@fac_idToCopyTo=29,
	@ModuletoCopy=''E11'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E9'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590131'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590131'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=29,@reg_idToCopy=NULL,@fac_idToCopyTo=29,
	@ModuletoCopy=''E9'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E10'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590131'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590131'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=29,@reg_idToCopy=NULL,@fac_idToCopyTo=29,
	@ModuletoCopy=''E10'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E16'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590131'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590131'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=29,@reg_idToCopy=NULL,@fac_idToCopyTo=29,
	@ModuletoCopy=''E16'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E13'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590131'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590131'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=29,@reg_idToCopy=NULL,@fac_idToCopyTo=29,
	@ModuletoCopy=''E13'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E17'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590131'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590131'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=29,@reg_idToCopy=NULL,@fac_idToCopyTo=29,
	@ModuletoCopy=''E17'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E18'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590131'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590131'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=29,@reg_idToCopy=NULL,@fac_idToCopyTo=29,
	@ModuletoCopy=''E18'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E20'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590131'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590131'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=29,@reg_idToCopy=NULL,@fac_idToCopyTo=29,
	@ModuletoCopy=''E20'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E21'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590131'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590131'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=29,@reg_idToCopy=NULL,@fac_idToCopyTo=29,
	@ModuletoCopy=''E21'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E22'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590131'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590131'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=29,@reg_idToCopy=NULL,@fac_idToCopyTo=29,
	@ModuletoCopy=''E22'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E23'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590131'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590131'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=29,@reg_idToCopy=NULL,@fac_idToCopyTo=29,
	@ModuletoCopy=''E23'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Source to Staging Step3 and Step4 Execution'', 1
END', 
		@database_name=N'pcc_staging_db59013', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase590131 Fac 29 to 29 : POST    on Staging (Scoping and Other)]    Script Date: 1/13/2022 7:41:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase590131 Fac 29 to 29 : POST    on Staging (Scoping and Other)', 
		@step_id=18, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=29, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE pcc_staging_db59013

SET CONTEXT_INFO 0xDC1000000;
 SET DEADLOCK_PRIORITY 4;
 SET QUOTED_IDENTIFIER ON;

exec [operational].[sproc_facacq_post_Scoping_SameAsSource]
@source_db = ''test_usei1058''
,@NSCaseNumber = ''EICase590131''

exec [operational].[sproc_facacq_post_UpdatePayer]
@source_db = ''test_usei1058''
,@destination_fac_id = ''29''
,@NSCaseNumber = ''EICase590131''
,@payer_mapping_bkp = ''[vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.PMO59013_EICase590131_payermapping_fac_29_to_29''

exec [operational].[sproc_facacq_post_UpdateRoomRateType]
@source_db = ''test_usei1058''
,@destination_fac_id = ''29''
,@NSCaseNumber = ''EICase590131''
,@roomratetype_mapping_bkp = ''[vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_RoomRateType$]''
,@MA_dst_id = ''4''




--Diagnosis Ranks
update common_code
set  fac_id= 29
--select  *  from common_code
where item_Code=''drank''
and  created_by=''EIcase590131''--1
and item_id in (select dst_id from EIcase590131common_code)


--Diagnosis Classification
update common_code
set  fac_id= 29
--select  *  from common_code
where item_Code=''dclas''
and  created_by=''EIcase590131''--1
and item_id in (select dst_id from EIcase590131common_code)


--Strike Out Picklist
update common_code
set  fac_id= 29
--select  *  from common_code
where item_Code=''strke''
and  created_by=''EIcase590131''--1
and item_id in (select dst_id from EIcase590131common_code)


--Weight Scale types
update common_code
set  fac_id= 29
--select  *  from common_code
where item_Code=''wvscal''
and  created_by=''EIcase590131''--1
and item_id in (select dst_id from EIcase590131common_code)


--Administration Records
update pho_administration_record
set  fac_id= 29
--select  *  from pho_administration_record
where fac_id = -1
and administration_record_id 
in (select dst_id from EIcase590131pho_administration_record where corporate = ''N'')


--Order types
update pho_order_type
set  fac_id= 29
--select  *  from pho_order_type
where fac_id = -1
and order_type_id 
in (select dst_id from EIcase590131pho_order_type where corporate = ''N'')', 
		@database_name=N'pcc_staging_db59013', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase590131 Fac 29 to 29 : Backup Staging DB between Facilities]    Script Date: 1/13/2022 7:41:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase590131 Fac 29 to 29 : Backup Staging DB between Facilities', 
		@step_id=19, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=29, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--USE pcc_staging_db59013 DBCC SHRINKFILE (2,0,TRUNCATEONLY)

USE MASTER
BACKUP DATABASE [pcc_staging_db59013] TO URL = ''https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1763/pcc_staging_db59013_Case590131_20220110100416_1.BAK'', URL = ''https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1763/pcc_staging_db59013_Case590131_20220110100416_2.BAK'', URL = ''https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1763/pcc_staging_db59013_Case590131_20220110100416_3.BAK'', URL = ''https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1763/pcc_staging_db59013_Case590131_20220110100416_4.BAK''
 WITH COPY_ONLY, FORMAT, INIT, COMPRESSION, STATS=10', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase590132 Fac 32 to 30 : PRE    Custom on Source ******]    Script Date: 1/13/2022 7:41:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase590132 Fac 32 to 30 : PRE    Custom on Source ******', 
		@step_id=20, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=29, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use test_usei1058

', 
		@database_name=N'test_usei1058', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase590132 Fac 32 to 30 : PRE    Standard on Source]    Script Date: 1/13/2022 7:41:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase590132 Fac 32 to 30 : PRE    Standard on Source', 
		@step_id=21, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=29, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use test_usei1058

SET CONTEXT_INFO 0xDC1000000;
 SET DEADLOCK_PRIORITY 4;
 SET QUOTED_IDENTIFIER ON;

print (''-- PMO/Engagement: 59013'')
print (''-- CaseNo: EICase590132'')
print (''-- Source fac_id = 32'')
print (''-- Destination fac_id = 30'')
print (''-- Destination DB = [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'')

exec [operational].[sproc_facacq_pre_FixContactNumber]	@dest_DB_name = ''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi''
exec [operational].[sproc_facacq_pre_FixContactNumber]	@dest_DB_name = ''pcc_staging_db59013''
exec [operational].[sproc_facacq_pre_IfDiagnosis]		@dest_database = ''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi''
exec [operational].[sproc_facacq_pre_immunization_fix]	@fac_id = ''32''
exec [operational].[sproc_facacq_pre_scoping_CpSecUserAudit]	@fac_id = ''32''
exec [operational].[sproc_facacq_pre_scoping_extfac]			@fac_id = ''32''
exec [operational].[sproc_facacq_pre_scoping_userfieldtypes]	@fac_id = ''32''

update cp_std_intervention set std_freq_id = NULL from cp_std_intervention where std_freq_id is not NULL and std_freq_id in (0,30)
update cp_std_intervention set poc_std_freq_id = NULL from cp_std_intervention where poc_std_freq_id is not NULL

ALTER INDEX census_codes__facId_tableCode_shortDesc_IDX ON dbo.census_codes DISABLE;
exec [operational].[sproc_facacq_pre_mappingCensusCode]
@mapping_table_name = ''[vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_ActionCodes$]'',
@dest_database = ''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',
@src_fac_id = ''32''

exec [operational].[sproc_facacq_pre_mappingCensusCode]
@mapping_table_name = ''[vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_StatusCodes$]'',
@dest_database = ''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',
@src_fac_id = ''32''

exec [operational].[sproc_facacq_pre_mappingUploadCategory]
@mapping_table_name = ''[vmuspassvtsjob1.pccprod.local].FacAcqMapping.[dbo].[PMO59013_UploadCategories$]'',
@dest_database = ''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi''

PRINT ''--Copying UDA''
exec [operational].[sproc_facacq_pre_scoping_IfCopyUDA]		@fac_id = ''32''
exec [operational].[sproc_facacq_pre_IfUDA_DummyUDAScoping]	@source_fac_id = ''32''

PRINT ''--Copying PN''
exec [operational].[sproc_facacq_pre_scoping_pn_type_and_template] @fac_id = ''32''

PRINT ''--Copying CP Library''
exec [operational].[sproc_facacq_pre_prefix_care_plan_library]
@fac_id = ''32''
,@prefix = ''ZION-''
,@destDB = ''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi''
,@destfacid = ''30''
,@libexclude = ''8,9''

exec [operational].[sproc_facacq_pre_ChangeLoginname] 
@fac_id = ''32'',
@suffix = ''ZION'',
@dest_database = ''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi''

PRINT ''--Copying Orders''
exec [operational].[sproc_facacq_pre_CheckShiftUsage] @fac_id = ''32''
exec [operational].[sproc_facacq_pre_IfOrder_StdOrderAndSet]
@fac_id = ''32'',
@dest_database = ''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',
@suffix = ''_''
exec [operational].[sproc_facacq_pre_scoping_PhoOrderType] @fac_id = ''32''

PRINT ''--Copying Trust''
update a set a.gl_batch_id = null from ta_transaction a where gl_batch_id is not null
', 
		@database_name=N'test_usei1058', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase590132 Fac 32 to 30 : PRE    on Destination (Sec User Gap Import)]    Script Date: 1/13/2022 7:41:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase590132 Fac 32 to 30 : PRE    on Destination (Sec User Gap Import)', 
		@step_id=22, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=29, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET CONTEXT_INFO 0xDC1000000;
 SET DEADLOCK_PRIORITY 4;
 SET QUOTED_IDENTIFIER ON;

exec [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi.[operational].[sproc_facacq_pre_sec_user_GapImport_01_scoping]
@src_db_location = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058''
,@NS_case_number = ''EICase590132''
,@src_fac_id = ''32''

exec [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi.[operational].[sproc_facacq_pre_sec_user_GapImport_02_Import]
@src_db_location = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058''
,@NS_case_number = ''EICase590132''
,@source_fac_id = ''32''
,@suffix = ''ZION''
,@destination_org_id = ''1504957707''
,@destination_fac_id = ''30''
,@if_is_rerun = ''N''

', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase590132 Fac 32 to 30 : AUTO-PRE    on Staging]    Script Date: 1/13/2022 7:41:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase590132 Fac 32 to 30 : AUTO-PRE    on Staging', 
		@step_id=23, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=29, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use pcc_staging_db59013

SET CONTEXT_INFO 0xDC1000000;
 SET DEADLOCK_PRIORITY 4;
 SET QUOTED_IDENTIFIER ON;

exec [operational].[sproc_facacq_autopre_CCRSPicklistMergeerror] @csv_pick_list_ids = ''350,713, 714, 1000348, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313, -70, 315, 316, 317, 314, 318, 319, 320, 321, 322, 323, 324, 325, 326, 327, 328, 329, 330, 331, 332, 333, 334, 335, 336, 337, 338, 340, 1000891, 342, 344, 345, 346, 1000892, 348, 349, 351, 352, 353, 354, 355, 1000893, 1000894, 360, 361, 362, 363, 364, 365, 366, 367''

exec [operational].[sproc_facacq_autopre_ifMergeUDA_04_From2ndFacility]

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

CREATE TABLE [dbo].[EICase590132sec_user]([row_id] [int] IDENTITY(1,1) NOT NULL,[src_id] [bigint] NULL,[dst_id] [bigint] NULL,[corporate] [char](1) NULL DEFAULT (''N'') ) ON [PRIMARY]
SET IDENTITY_INSERT EICase590132sec_user ON 
					insert into EICase590132sec_user (row_id,src_id,dst_id,corporate) 
					select row_id, src_id,dst_id,corporate from [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi.dbo.EICase590132sec_user 
					SET IDENTITY_INSERT EICase590132sec_user OFF

UPDATE mergeTablesMaster SET queryfilter = replace(QueryFilter, ''[destDB]'', ''[stagDB]'') FROM mergeTablesMaster WHERE (QueryFilter LIKE ''%prefix%'' AND QueryFilter LIKE ''%destDB%'')
', 
		@database_name=N'pcc_staging_db59013', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase590132 Fac 32 to 30 : Source to Staging]    Script Date: 1/13/2022 7:41:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase590132 Fac 32 to 30 : Source to Staging', 
		@step_id=24, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=29, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE pcc_staging_db59013

IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E1'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590132'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590132'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=32,@reg_idToCopy=NULL,@fac_idToCopyTo=30,
	@ModuletoCopy=''E1'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=1,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E2'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590132'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590132'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=32,@reg_idToCopy=NULL,@fac_idToCopyTo=30,
	@ModuletoCopy=''E2'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E3'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590132'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590132'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=32,@reg_idToCopy=NULL,@fac_idToCopyTo=30,
	@ModuletoCopy=''E3'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E4'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590132'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590132'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=32,@reg_idToCopy=NULL,@fac_idToCopyTo=30,
	@ModuletoCopy=''E4'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E5'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590132'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590132'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=32,@reg_idToCopy=NULL,@fac_idToCopyTo=30,
	@ModuletoCopy=''E5'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E6'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590132'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590132'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=32,@reg_idToCopy=NULL,@fac_idToCopyTo=30,
	@ModuletoCopy=''E6'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E7'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590132'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590132'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=32,@reg_idToCopy=NULL,@fac_idToCopyTo=30,
	@ModuletoCopy=''E7'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E8'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590132'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590132'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=32,@reg_idToCopy=NULL,@fac_idToCopyTo=30,
	@ModuletoCopy=''E8'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E12b'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590132'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590132'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=32,@reg_idToCopy=NULL,@fac_idToCopyTo=30,
	@ModuletoCopy=''E12b'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E11'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590132'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590132'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=32,@reg_idToCopy=NULL,@fac_idToCopyTo=30,
	@ModuletoCopy=''E11'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E9'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590132'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590132'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=32,@reg_idToCopy=NULL,@fac_idToCopyTo=30,
	@ModuletoCopy=''E9'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E10'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590132'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590132'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=32,@reg_idToCopy=NULL,@fac_idToCopyTo=30,
	@ModuletoCopy=''E10'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E16'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590132'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590132'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=32,@reg_idToCopy=NULL,@fac_idToCopyTo=30,
	@ModuletoCopy=''E16'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E13'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590132'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590132'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=32,@reg_idToCopy=NULL,@fac_idToCopyTo=30,
	@ModuletoCopy=''E13'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E17'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590132'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590132'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=32,@reg_idToCopy=NULL,@fac_idToCopyTo=30,
	@ModuletoCopy=''E17'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E18'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590132'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590132'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=32,@reg_idToCopy=NULL,@fac_idToCopyTo=30,
	@ModuletoCopy=''E18'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E20'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590132'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590132'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=32,@reg_idToCopy=NULL,@fac_idToCopyTo=30,
	@ModuletoCopy=''E20'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E21'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590132'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590132'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=32,@reg_idToCopy=NULL,@fac_idToCopyTo=30,
	@ModuletoCopy=''E21'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E22'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590132'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590132'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=32,@reg_idToCopy=NULL,@fac_idToCopyTo=30,
	@ModuletoCopy=''E22'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Source to Staging Step3 and Step4 Execution'', 1
END
IF NOT EXISTS(SELECT 1 FROM pcc_staging_db59013.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')
BEGIN
	EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''E23'',
	@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',@NewDB=''N'',
	@CaseNo=''590132'',@ActiveResident=''N'',@DisDate=''''
	EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase590132'',
	@sourceDB=''test_usei1058'',	@fac_idToCopy=32,@reg_idToCopy=NULL,@fac_idToCopyTo=30,
	@ModuletoCopy=''E23'',@AllModulestoCopy=''E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E16,E13,E17,E18,E20,E21,E22,E23'',
	@stagingDB=''pcc_staging_db59013'',@destinationDB=''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'',	@RunIDFlag=2,@ContinueMerge=0
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Source to Staging Step3 and Step4 Execution'', 1
END', 
		@database_name=N'pcc_staging_db59013', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase590132 Fac 32 to 30 : POST    on Staging (Scoping and Other)]    Script Date: 1/13/2022 7:41:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase590132 Fac 32 to 30 : POST    on Staging (Scoping and Other)', 
		@step_id=25, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=29, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE pcc_staging_db59013

SET CONTEXT_INFO 0xDC1000000;
 SET DEADLOCK_PRIORITY 4;
 SET QUOTED_IDENTIFIER ON;

exec [operational].[sproc_facacq_post_Scoping_SameAsSource]
@source_db = ''test_usei1058''
,@NSCaseNumber = ''EICase590132''

exec [operational].[sproc_facacq_post_UpdatePayer]
@source_db = ''test_usei1058''
,@destination_fac_id = ''30''
,@NSCaseNumber = ''EICase590132''
,@payer_mapping_bkp = ''[vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.PMO59013_EICase590132_payermapping_fac_32_to_30''

exec [operational].[sproc_facacq_post_UpdateRoomRateType]
@source_db = ''test_usei1058''
,@destination_fac_id = ''30''
,@NSCaseNumber = ''EICase590132''
,@roomratetype_mapping_bkp = ''[vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO59013_RoomRateType$]''
,@MA_dst_id = ''4''


--Diagnosis Ranks
update common_code
set  fac_id= 30
--select  *  from common_code
where item_Code=''drank''
and  created_by=''EIcase590132''--1
and item_id in (select dst_id from EIcase590132common_code)


--Diagnosis Classification
update common_code
set  fac_id= 30
--select  *  from common_code
where item_Code=''dclas''
and  created_by=''EIcase590132''--1
and item_id in (select dst_id from EIcase590132common_code)


--Strike Out Picklist
update common_code
set  fac_id= 30
--select  *  from common_code
where item_Code=''strke''
and  created_by=''EIcase590132''--1
and item_id in (select dst_id from EIcase590132common_code)


--Weight Scale types
update common_code
set  fac_id= 30
--select  *  from common_code
where item_Code=''wvscal''
and  created_by=''EIcase590132''--1
and item_id in (select dst_id from EIcase590132common_code)


--Administration Records
update pho_administration_record
set  fac_id= 30
--select  *  from pho_administration_record
where fac_id = -1
and administration_record_id 
in (select dst_id from EIcase590132pho_administration_record where corporate = ''N'')


--Order types
update pho_order_type
set  fac_id= 30
--select  *  from pho_order_type
where fac_id = -1
and order_type_id 
in (select dst_id from EIcase590132pho_order_type where corporate = ''N'')


PRINT CHAR(13) + ''Post insert for as_ard_adl_keys running now''

INSERT INTO dbo.as_ard_adl_keys (
	ard_planner_id
	,std_assess_id
	,question_key
	,resp_value
	,source_id
	,Multi_Fac_Id
	)
SELECT DISTINCT ISNULL(c.dst_id, ard_planner_id)
	,ISNULL(b.dst_id, std_assess_id)
	,[question_key]
	,[resp_value]
	,[source_id]
	,29
FROM test_usei1058.dbo.as_ard_adl_keys a
INNER JOIN EICase590131as_std_assessment b ON b.src_id = a.std_assess_id
INNER JOIN EICase590131as_ard_planner c ON c.src_id = a.ard_planner_id

PRINT CHAR(13) + ''Post insert for as_ard_adl_keys running now''

INSERT INTO dbo.as_ard_adl_keys (
	ard_planner_id
	,std_assess_id
	,question_key
	,resp_value
	,source_id
	,Multi_Fac_Id
	)
SELECT DISTINCT ISNULL(c.dst_id, ard_planner_id)
	,ISNULL(b.dst_id, std_assess_id)
	,[question_key]
	,[resp_value]
	,[source_id]
	,30
FROM test_usei1058.dbo.as_ard_adl_keys a
INNER JOIN EICase590132as_std_assessment b ON b.src_id = a.std_assess_id
INNER JOIN EICase590132as_ard_planner c ON c.src_id = a.ard_planner_id
', 
		@database_name=N'pcc_staging_db59013', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase590132 Fac 32 to 30 : Backup Staging DB between Facilities]    Script Date: 1/13/2022 7:41:36 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase590132 Fac 32 to 30 : Backup Staging DB between Facilities', 
		@step_id=26, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=29, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--USE pcc_staging_db59013 DBCC SHRINKFILE (2,0,TRUNCATEONLY)

USE MASTER
BACKUP DATABASE [pcc_staging_db59013] TO URL = ''https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1763/pcc_staging_db59013_Case590132_20220110100416_1.BAK'', URL = ''https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1763/pcc_staging_db59013_Case590132_20220110100416_2.BAK'', URL = ''https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1763/pcc_staging_db59013_Case590132_20220110100416_3.BAK'', URL = ''https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1763/pcc_staging_db59013_Case590132_20220110100416_4.BAK''
 WITH COPY_ONLY, FORMAT, INIT, COMPRESSION, STATS=10', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Final Backup of Staging DB]    Script Date: 1/13/2022 7:41:36 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Final Backup of Staging DB', 
		@step_id=27, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=29, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE MASTER
BACKUP DATABASE [pcc_staging_db59013] TO URL = ''https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1763/Final_GoLive/pcc_staging_db59013_Case590132_20220110100416_1.BAK'', URL = ''https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1763/Final_GoLive/pcc_staging_db59013_Case590132_20220110100416_2.BAK'', URL = ''https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1763/Final_GoLive/pcc_staging_db59013_Case590132_20220110100416_3.BAK'', URL = ''https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1763/Final_GoLive/pcc_staging_db59013_Case590132_20220110100416_4.BAK''
 WITH COPY_ONLY, FORMAT, INIT, COMPRESSION, STATS=10', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Kickoff Staging to Destination Job]    Script Date: 1/13/2022 7:41:36 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Kickoff Staging to Destination Job', 
		@step_id=28, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=29, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].MSDB.dbo.SP_START_JOB @job_name="EI_Prepare_Destination__59013"', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [TS Job Failure Email Notification]    Script Date: 1/13/2022 7:41:36 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'TS Job Failure Email Notification', 
		@step_id=29, 
		@cmdexec_success_code=0, 
		@on_success_action=2, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE pcc_staging_db59013
EXEC [operational].[sproc_facacq_sendEmailNotification] @Recipient = ''ts3@pccs.pagerduty.com''
					,@BlindCopyRecipients = ''TSFacAcqConfig@pointclickcare.com''
					,@JobName = ''EI_Prepare_Staging__59013 ''
					,@ServerName = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net]''', 
		@database_name=N'pcc_staging_db59013', 
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


