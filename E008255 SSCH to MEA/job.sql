USE [msdb]
GO

/****** Object:  Job [EI_Prepare_Destination__008255]    Script Date: 3/15/2022 2:42:30 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 3/15/2022 2:42:30 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'EI_Prepare_Destination__008255', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Job to excute ETL Staging to Destination for EI PMO: 008255', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Restore Staging DB on Destination Server]    Script Date: 3/15/2022 2:42:30 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Restore Staging DB on Destination Server', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=20, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE MASTER
RESTORE DATABASE pcc_staging_db008255 FROM URL = ''https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1817/pcc_staging_db008255_Case0082551_20220314101600_1.BAK'', URL = ''https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1817/pcc_staging_db008255_Case0082551_20220314101600_2.BAK'', URL = ''https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1817/pcc_staging_db008255_Case0082551_20220314101600_3.BAK'', URL = ''https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1817/pcc_staging_db008255_Case0082551_20220314101600_4.BAK''', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [FK Validation Checking All FK values from Staging to Destination]    Script Date: 3/15/2022 2:42:30 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'FK Validation Checking All FK values from Staging to Destination', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=20, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE pcc_staging_db008255
EXEC [operational].[sproc_facacq_FKValidation] @staging_db=''pcc_staging_db008255'', @destination_db=''us_mea''', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Send Email & Wait for 15 Minutes]    Script Date: 3/15/2022 2:42:30 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Send Email & Wait for 15 Minutes', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=20, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE MASTER
EXEC msdb.dbo.sp_send_dbmail @recipients =''dinesh.gunalapan@pointclickcare.com;TSFacAcqConfig@pointclickcare.com'',
@subject=''Scheduled Data Copy March 14, PMO - 008255'',
@body=''Hi All,</br></br> Org MEA will be offline in 15 minutes.</br></br></br> Thanks,</br> Facility Acquisition Team'',
@body_format=''HTML''

EXEC msdb.dbo.sp_send_dbmail @recipients =''linda.k@pointclickcare.com;MarioM@sunnysiderehab.org;Mercia@sunnysiderehab.org;Administrator@sunnysiderehab.org;Medicalrecords@sunnysiderehab.org;Mweston@LTCconsulting.com;BOM@sunnysiderehab.org;Ashlee.Moss@pointclickcare.com;Wendy.Panganiban@pointclickcare.com;Sarah.D@pointclickcare.com;rina.p@pointclickcare.com;nigel.liang@pointclickcare.com;theresa.w@pointclickcare.com;TSFacAcqConfig@pointclickcare.com'',
@subject=''PMO - 008255, Data Copy of SSCH to MEA : Friendly reminder'',
@body=''Hi All,</br></br> Org MEA will be offline in 15 minutes.</br></br></br> Thanks,</br> Facility Acquisition Team'',
@body_format=''HTML''

WAITFOR DELAY ''00:15:00''', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Alter Login Destination DB Disable]    Script Date: 3/15/2022 2:42:30 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Alter Login Destination DB Disable', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=20, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF EXISTS(SELECT 1 FROM sys.database_principals WHERE NAME = ''test_merge'')
REVOKE CONNECT FROM test_merge
IF EXISTS(SELECT 1 FROM sys.database_principals WHERE NAME = ''ushd'')
REVOKE CONNECT FROM ushd', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Drop Staging Tables]    Script Date: 3/15/2022 2:42:30 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Drop Staging Tables', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=20, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE us_mea

EXEC [operational].[sproc_facacq_dropStagingTables]
', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Create/Populate table ListOfDeferTables]    Script Date: 3/15/2022 2:42:31 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Create/Populate table ListOfDeferTables', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=20, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE us_mea

EXEC [operational].[sproc_facacq_createListOfDeferTables]
EXEC [operational].[sproc_facacq_populateListOfDeferTables] @conv_server= ''vmuspassvtsjob1.pccprod.local''', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Staging to Destination OFFLINE INSERT]    Script Date: 3/15/2022 2:42:31 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Staging to Destination OFFLINE INSERT', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=20, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE us_mea

DECLARE @ReturnVal INT
SET @ReturnVal = 0

IF @ReturnVal = 0
BEGIN
	SET QUOTED_IDENTIFIER ON
	EXEC @ReturnVal=[operational].[sproc_facacq_insertStagingToDestinationOffline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',@ModuleToCopy=''E1'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=1,@ContinueMerge=''0'',@ReturnVal=0,@flgOffLine=0,@MultiFacId=NULL
END
ELSE
BEGIN
	;THROW 51000,''ERROR: OffLine Insert:- E1'', 1
END
IF @ReturnVal = 0
BEGIN
	SET QUOTED_IDENTIFIER ON
	EXEC @ReturnVal=[operational].[sproc_facacq_insertStagingToDestinationOffline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',@ModuleToCopy=''E2'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,@ContinueMerge=''0'',@ReturnVal=0,@flgOffLine=0,@MultiFacId=NULL
END
ELSE
BEGIN
	;THROW 51000,''ERROR: OffLine Insert:- E2'', 1
END
IF @ReturnVal = 0
BEGIN
	SET QUOTED_IDENTIFIER ON
	EXEC @ReturnVal=[operational].[sproc_facacq_insertStagingToDestinationOffline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',@ModuleToCopy=''E2a'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,@ContinueMerge=''0'',@ReturnVal=0,@flgOffLine=0,@MultiFacId=NULL
END
ELSE
BEGIN
	;THROW 51000,''ERROR: OffLine Insert:- E2a'', 1
END
IF @ReturnVal = 0
BEGIN
	SET QUOTED_IDENTIFIER ON
	EXEC @ReturnVal=[operational].[sproc_facacq_insertStagingToDestinationOffline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',@ModuleToCopy=''E3'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,@ContinueMerge=''0'',@ReturnVal=0,@flgOffLine=0,@MultiFacId=NULL
END
ELSE
BEGIN
	;THROW 51000,''ERROR: OffLine Insert:- E3'', 1
END
IF @ReturnVal = 0
BEGIN
	SET QUOTED_IDENTIFIER ON
	EXEC @ReturnVal=[operational].[sproc_facacq_insertStagingToDestinationOffline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',@ModuleToCopy=''E4'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,@ContinueMerge=''0'',@ReturnVal=0,@flgOffLine=0,@MultiFacId=NULL
END
ELSE
BEGIN
	;THROW 51000,''ERROR: OffLine Insert:- E4'', 1
END
IF @ReturnVal = 0
BEGIN
	SET QUOTED_IDENTIFIER ON
	EXEC @ReturnVal=[operational].[sproc_facacq_insertStagingToDestinationOffline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',@ModuleToCopy=''E5'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,@ContinueMerge=''0'',@ReturnVal=0,@flgOffLine=0,@MultiFacId=NULL
END
ELSE
BEGIN
	;THROW 51000,''ERROR: OffLine Insert:- E5'', 1
END
IF @ReturnVal = 0
BEGIN
	SET QUOTED_IDENTIFIER ON
	EXEC @ReturnVal=[operational].[sproc_facacq_insertStagingToDestinationOffline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',@ModuleToCopy=''E6'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,@ContinueMerge=''0'',@ReturnVal=0,@flgOffLine=0,@MultiFacId=NULL
END
ELSE
BEGIN
	;THROW 51000,''ERROR: OffLine Insert:- E6'', 1
END
IF @ReturnVal = 0
BEGIN
	SET QUOTED_IDENTIFIER ON
	EXEC @ReturnVal=[operational].[sproc_facacq_insertStagingToDestinationOffline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',@ModuleToCopy=''E7a'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,@ContinueMerge=''0'',@ReturnVal=0,@flgOffLine=0,@MultiFacId=NULL
END
ELSE
BEGIN
	;THROW 51000,''ERROR: OffLine Insert:- E7a'', 1
END
IF @ReturnVal = 0
BEGIN
	SET QUOTED_IDENTIFIER ON
	EXEC @ReturnVal=[operational].[sproc_facacq_insertStagingToDestinationOffline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',@ModuleToCopy=''E7b'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,@ContinueMerge=''0'',@ReturnVal=0,@flgOffLine=0,@MultiFacId=NULL
END
ELSE
BEGIN
	;THROW 51000,''ERROR: OffLine Insert:- E7b'', 1
END
IF @ReturnVal = 0
BEGIN
	SET QUOTED_IDENTIFIER ON
	EXEC @ReturnVal=[operational].[sproc_facacq_insertStagingToDestinationOffline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',@ModuleToCopy=''E7c'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,@ContinueMerge=''0'',@ReturnVal=0,@flgOffLine=0,@MultiFacId=NULL
END
ELSE
BEGIN
	;THROW 51000,''ERROR: OffLine Insert:- E7c'', 1
END
IF @ReturnVal = 0
BEGIN
	SET QUOTED_IDENTIFIER ON
	EXEC @ReturnVal=[operational].[sproc_facacq_insertStagingToDestinationOffline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',@ModuleToCopy=''E8'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,@ContinueMerge=''0'',@ReturnVal=0,@flgOffLine=0,@MultiFacId=NULL
END
ELSE
BEGIN
	;THROW 51000,''ERROR: OffLine Insert:- E8'', 1
END
IF @ReturnVal = 0
BEGIN
	SET QUOTED_IDENTIFIER ON
	EXEC @ReturnVal=[operational].[sproc_facacq_insertStagingToDestinationOffline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',@ModuleToCopy=''E12a'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,@ContinueMerge=''0'',@ReturnVal=0,@flgOffLine=0,@MultiFacId=NULL
END
ELSE
BEGIN
	;THROW 51000,''ERROR: OffLine Insert:- E12a'', 1
END
IF @ReturnVal = 0
BEGIN
	SET QUOTED_IDENTIFIER ON
	EXEC @ReturnVal=[operational].[sproc_facacq_insertStagingToDestinationOffline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',@ModuleToCopy=''E12b'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,@ContinueMerge=''0'',@ReturnVal=0,@flgOffLine=0,@MultiFacId=NULL
END
ELSE
BEGIN
	;THROW 51000,''ERROR: OffLine Insert:- E12b'', 1
END
IF @ReturnVal = 0
BEGIN
	SET QUOTED_IDENTIFIER ON
	EXEC @ReturnVal=[operational].[sproc_facacq_insertStagingToDestinationOffline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',@ModuleToCopy=''E11'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,@ContinueMerge=''0'',@ReturnVal=0,@flgOffLine=0,@MultiFacId=NULL
END
ELSE
BEGIN
	;THROW 51000,''ERROR: OffLine Insert:- E11'', 1
END
IF @ReturnVal = 0
BEGIN
	SET QUOTED_IDENTIFIER ON
	EXEC @ReturnVal=[operational].[sproc_facacq_insertStagingToDestinationOffline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',@ModuleToCopy=''E9'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,@ContinueMerge=''0'',@ReturnVal=0,@flgOffLine=0,@MultiFacId=NULL
END
ELSE
BEGIN
	;THROW 51000,''ERROR: OffLine Insert:- E9'', 1
END
IF @ReturnVal = 0
BEGIN
	SET QUOTED_IDENTIFIER ON
	EXEC @ReturnVal=[operational].[sproc_facacq_insertStagingToDestinationOffline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',@ModuleToCopy=''E10'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,@ContinueMerge=''0'',@ReturnVal=0,@flgOffLine=0,@MultiFacId=NULL
END
ELSE
BEGIN
	;THROW 51000,''ERROR: OffLine Insert:- E10'', 1
END
IF @ReturnVal = 0
BEGIN
	SET QUOTED_IDENTIFIER ON
	EXEC @ReturnVal=[operational].[sproc_facacq_insertStagingToDestinationOffline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',@ModuleToCopy=''E13'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,@ContinueMerge=''0'',@ReturnVal=0,@flgOffLine=0,@MultiFacId=NULL
END
ELSE
BEGIN
	;THROW 51000,''ERROR: OffLine Insert:- E13'', 1
END
IF @ReturnVal = 0
BEGIN
	SET QUOTED_IDENTIFIER ON
	EXEC @ReturnVal=[operational].[sproc_facacq_insertStagingToDestinationOffline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',@ModuleToCopy=''E16'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,@ContinueMerge=''0'',@ReturnVal=0,@flgOffLine=0,@MultiFacId=NULL
END
ELSE
BEGIN
	;THROW 51000,''ERROR: OffLine Insert:- E16'', 1
END
IF @ReturnVal = 0
BEGIN
	SET QUOTED_IDENTIFIER ON
	EXEC @ReturnVal=[operational].[sproc_facacq_insertStagingToDestinationOffline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',@ModuleToCopy=''E18'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,@ContinueMerge=''0'',@ReturnVal=0,@flgOffLine=0,@MultiFacId=NULL
END
ELSE
BEGIN
	;THROW 51000,''ERROR: OffLine Insert:- E18'', 1
END
IF @ReturnVal = 0
BEGIN
	SET QUOTED_IDENTIFIER ON
	EXEC @ReturnVal=[operational].[sproc_facacq_insertStagingToDestinationOffline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',@ModuleToCopy=''E20'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,@ContinueMerge=''0'',@ReturnVal=0,@flgOffLine=0,@MultiFacId=NULL
END
ELSE
BEGIN
	;THROW 51000,''ERROR: OffLine Insert:- E20'', 1
END
IF @ReturnVal = 0
BEGIN
	SET QUOTED_IDENTIFIER ON
	EXEC @ReturnVal=[operational].[sproc_facacq_insertStagingToDestinationOffline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',@ModuleToCopy=''E21'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,@ContinueMerge=''0'',@ReturnVal=0,@flgOffLine=0,@MultiFacId=NULL
END
ELSE
BEGIN
	;THROW 51000,''ERROR: OffLine Insert:- E21'', 1
END
IF @ReturnVal = 0
BEGIN
	SET QUOTED_IDENTIFIER ON
	EXEC @ReturnVal=[operational].[sproc_facacq_insertStagingToDestinationOffline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',@ModuleToCopy=''E22'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,@ContinueMerge=''0'',@ReturnVal=0,@flgOffLine=0,@MultiFacId=NULL
END
ELSE
BEGIN
	;THROW 51000,''ERROR: OffLine Insert:- E22'', 1
END', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Alter Login Destination DB Enable]    Script Date: 3/15/2022 2:42:31 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Alter Login Destination DB Enable', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=20, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF EXISTS(SELECT 1 FROM sys.database_principals WHERE NAME = ''test_merge'')
GRANT CONNECT TO test_merge
IF EXISTS(SELECT 1 FROM sys.database_principals WHERE NAME = ''ushd'')
GRANT CONNECT TO ushd', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Email Notification DB Online]    Script Date: 3/15/2022 2:42:31 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Email Notification DB Online', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=20, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE MASTER
EXEC msdb.dbo.sp_send_dbmail @recipients =''dinesh.gunalapan@pointclickcare.com;TSFacAcqConfig@pointclickcare.com'',
@subject=''Scheduled Data Copy March 14, PMO - 008255'',
@body=''Hi All,</br></br> Org MEA is now back online.</br></br>Following facilities are still offline:</br></br>Sunnyside Convalescent Hospital</br></br></br>Thanks,</br>Facility Acquisition Team'',
@body_format=''HTML''

EXEC msdb.dbo.sp_send_dbmail @recipients =''linda.k@pointclickcare.com;MarioM@sunnysiderehab.org;Mercia@sunnysiderehab.org;Administrator@sunnysiderehab.org;Medicalrecords@sunnysiderehab.org;Mweston@LTCconsulting.com;BOM@sunnysiderehab.org;Ashlee.Moss@pointclickcare.com;Wendy.Panganiban@pointclickcare.com;Sarah.D@pointclickcare.com;rina.p@pointclickcare.com;nigel.liang@pointclickcare.com;theresa.w@pointclickcare.com;TSFacAcqConfig@pointclickcare.com'',
@subject=''PMO - 008255, Data Copy of SSCH to MEA : Friendly reminder'',
@body=''Hi All,</br></br> Org MEA is now back online.</br></br>Following facilities are still offline:</br></br>Sunnyside Convalescent Hospital</br></br></br>Thanks,</br>Facility Acquisition Team'',
@body_format=''HTML''', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase0082551 Fac 2 : Copy Mapping Tables to Destination DB]    Script Date: 3/15/2022 2:42:31 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase0082551 Fac 2 : Copy Mapping Tables to Destination DB', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=20, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE us_mea
EXEC [operational].[sproc_facacq_createInsertMappingTablesStagingToDestination] 
@StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',
@prefix=''EICASE0082551'',@ReturnVal=NULL', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase0082551 Fac 2 : ONLINE INSERT]    Script Date: 3/15/2022 2:42:31 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase0082551 Fac 2 : ONLINE INSERT', 
		@step_id=11, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=20, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE us_mea
DECLARE @ReturnVal INT
SET @ReturnVal=0

IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',
	@ModuleToCopy=''E1'',@TranFlag=NULL,@prefix=''EICASE0082551'',
	@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=1,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=2
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 0082551 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',
	@ModuleToCopy=''E2'',@TranFlag=NULL,@prefix=''EICASE0082551'',
	@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=2
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 0082551 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',
	@ModuleToCopy=''E2a'',@TranFlag=NULL,@prefix=''EICASE0082551'',
	@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=2
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 0082551 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',
	@ModuleToCopy=''E3'',@TranFlag=NULL,@prefix=''EICASE0082551'',
	@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=2
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 0082551 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',
	@ModuleToCopy=''E4'',@TranFlag=NULL,@prefix=''EICASE0082551'',
	@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=2
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 0082551 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',
	@ModuleToCopy=''E5'',@TranFlag=NULL,@prefix=''EICASE0082551'',
	@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=2
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 0082551 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',
	@ModuleToCopy=''E6'',@TranFlag=NULL,@prefix=''EICASE0082551'',
	@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=2
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 0082551 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',
	@ModuleToCopy=''E7a'',@TranFlag=NULL,@prefix=''EICASE0082551'',
	@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=2
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 0082551 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',
	@ModuleToCopy=''E7b'',@TranFlag=NULL,@prefix=''EICASE0082551'',
	@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=2
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 0082551 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',
	@ModuleToCopy=''E7c'',@TranFlag=NULL,@prefix=''EICASE0082551'',
	@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=2
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 0082551 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',
	@ModuleToCopy=''E8'',@TranFlag=NULL,@prefix=''EICASE0082551'',
	@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=2
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 0082551 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',
	@ModuleToCopy=''E12a'',@TranFlag=NULL,@prefix=''EICASE0082551'',
	@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=2
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 0082551 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',
	@ModuleToCopy=''E12b'',@TranFlag=NULL,@prefix=''EICASE0082551'',
	@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=2
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 0082551 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',
	@ModuleToCopy=''E11'',@TranFlag=NULL,@prefix=''EICASE0082551'',
	@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=2
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 0082551 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',
	@ModuleToCopy=''E9'',@TranFlag=NULL,@prefix=''EICASE0082551'',
	@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=2
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 0082551 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',
	@ModuleToCopy=''E10'',@TranFlag=NULL,@prefix=''EICASE0082551'',
	@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=2
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 0082551 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',
	@ModuleToCopy=''E13'',@TranFlag=NULL,@prefix=''EICASE0082551'',
	@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=2
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 0082551 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',
	@ModuleToCopy=''E16'',@TranFlag=NULL,@prefix=''EICASE0082551'',
	@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=2
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 0082551 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',
	@ModuleToCopy=''E18'',@TranFlag=NULL,@prefix=''EICASE0082551'',
	@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=2
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 0082551 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',
	@ModuleToCopy=''E20'',@TranFlag=NULL,@prefix=''EICASE0082551'',
	@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=2
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 0082551 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',
	@ModuleToCopy=''E21'',@TranFlag=NULL,@prefix=''EICASE0082551'',
	@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=2
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 0082551 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db008255'',@DestinationDB=''us_mea'',
	@ModuleToCopy=''E22'',@TranFlag=NULL,@prefix=''EICASE0082551'',
	@pmo=''008255'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=2
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 0082551 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase0082551 Fac 2 : Insert Into EIHistory]    Script Date: 3/15/2022 2:42:31 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase0082551 Fac 2 : Insert Into EIHistory', 
		@step_id=12, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=20, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE us_mea
SELECT 1', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase0082551 Fac 2 : Update LoadEIMaster_Automation]    Script Date: 3/15/2022 2:42:31 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase0082551 Fac 2 : Update LoadEIMaster_Automation', 
		@step_id=13, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=20, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE us_mea
SELECT 1', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase0082551 Fac 2 : Enable Facility]    Script Date: 3/15/2022 2:42:31 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase0082551 Fac 2 : Enable Facility', 
		@step_id=14, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=20, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE us_mea
UPDATE us_mea.[dbo].facility
SET deleted=''N'', inactive = NULL, inactive_date = NULL WHERE fac_id=''2''', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase0082551 Fac 2 : POST    Standard on Destination]    Script Date: 3/15/2022 2:42:31 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase0082551 Fac 2 : POST    Standard on Destination', 
		@step_id=15, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=20, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE us_mea
SET CONTEXT_INFO 0xDC1000000;
 SET DEADLOCK_PRIORITY 4;
 SET QUOTED_IDENTIFIER ON;

exec [operational].[sproc_facacq_post_MpiHistoryInsert]
@src_db_location = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei964''
,@NS_Case_Number = ''EICase0082551''
,@source_fac_id = ''1''

exec [operational].[sproc_facacq_post_Insert_common_code_standard_contact_type_mapping]
@src_db_location = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei964''
,@NS_Case_Number = ''EICase0082551''

exec [operational].[sproc_facacq_post_IfUserDefinedDataRemoveDups]
@NS_Case_Number = ''EICase0082551''

exec [operational].[sproc_facacq_post_ifUsingEinteract]
@NSCaseNumber = ''EICase0082551''

exec [operational].[sproc_facacq_post_ifCopyUDAqlibFix]
@source_db = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei964''
,@NSCaseNumber = ''EICase0082551''

BEGIN DECLARE @SRCSTRING VARCHAR(50); DECLARE @DSTSTRING VARCHAR(50);DECLARE @rowid INT = 0;DECLARE @sqln NVARCHAR(max); DECLARE @sql VARCHAR(max); DECLARE @rowcount INT = 0;

SET @sqln = N''SELECT @rowcount = COUNT(1) FROM EICase0082551as_std_score'' EXEC sp_executesql @sqln, N''@rowcount INT  OUTPUT'', @rowcount OUTPUT
SET @sql = ''select distinct 1 from as_std_score with (nolock) where std_score_id in (select dst_id from EICase0082551as_std_score where corporate = ''''N'''') and formula like ''''%[[]SCR%''''''IF @@ROWCOUNT <> 0
BEGIN WHILE (@rowid <= @rowcount) 
BEGIN SET @sqln = N''SELECT TOP 1 @rowid = row_id FROM EICase0082551as_std_score WHERE CORPORATE = ''''N'''' and row_id > '' + convert(varchar,@rowid) + '' ORDER BY row_id''
EXEC sp_executesql @sqln, N''@rowid int  OUTPUT'', @rowid OUTPUT
IF @@ROWCOUNT = 0 BREAK;
SET @sqln = N''SELECT @SRCSTRING = ''''[SCR_'''' + convert(varchar, src_id) + '''']'''' FROM EICase0082551as_std_score WHERE CORPORATE = ''''N'''' AND ROW_ID = '' + convert(varchar,@rowid)
EXEC sp_executesql @sqln, N''@SRCSTRING VARCHAR(50)  OUTPUT'', @SRCSTRING OUTPUT
SET @sqln = N''SELECT @DSTSTRING = ''''[SCR_'''' + convert(varchar, dst_id) + '''']'''' FROM EICase0082551as_std_score WHERE CORPORATE = ''''N'''' AND ROW_ID = '' + convert(varchar,@rowid)
EXEC sp_executesql @sqln, N''@DSTSTRING VARCHAR(50)  OUTPUT'', @DSTSTRING OUTPUT

SET @sql = ''if exists(select 1 from as_std_score dst with (nolock) join EICase0082551as_std_score map on dst.std_score_id = map.dst_id
join [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei964.dbo.as_std_score src on map.src_id = src.std_score_id
where map.corporate = ''''N'''' and src.formula like ''''%'''' + replace('''''' + @SRCSTRING + '''''',''''['''',''''[[]'''') + ''''%''''
and exists (select 1 from as_std_score with (nolock) 
where dst.std_score_id = std_score_id and formula like ''''%'''' + replace('''''' + @DSTSTRING + '''''',''''['''',''''[[]'''') + ''''%''''))
BEGIN PRINT ''''--check: src - '' + @SRCSTRING + '' dst - '' + @DSTSTRING + ''''''END'' exec(@sql)

SET @sql = ''update dst SET dst.formula = replace(dst.formula,''''''+@SRCSTRING+'''''',''''''+@DSTSTRING+'''''')
from as_std_score dst join EICase0082551as_std_score map on dst.std_score_id = map.dst_id
join [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei964.dbo.as_std_score src with (nolock) on map.src_id = src.std_score_id
where map.corporate = ''''N'''' and src.formula like ''''%'''' + replace(''''''+@SRCSTRING+'''''',''''['''',''''[[]'''') + ''''%''''
and not exists (select 1 from as_std_score with (nolock) 
where dst.std_score_id = std_score_id and formula like ''''%'''' + replace(''''''+@DSTSTRING+'''''',''''['''',''''[[]'''') + ''''%'''')
''exec (@sql) END END END

exec [operational].[sproc_facacq_post_ifCopyDiagnosis]
@source_db = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei964''
,@destination_fac_id = ''2''
,@NSCaseNumber = ''EICase0082551''

DELETE FROM PCC_GLOBAL_PRIMARY_KEY WHERE TABLE_NAME = ''PHO_ADMIN_ORDER_AUDIT'';
DELETE FROM PCC_GLOBAL_PRIMARY_KEY WHERE TABLE_NAME = ''PHO_RELATED_ORDER_AUDIT'';

exec [operational].[sproc_facacq_post_ifCopyOrders_01_OrderAudit]
@source_db = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei964''
,@source_fac_id = ''1''
,@destination_fac_id = ''2''
,@NSCaseNumber = ''EICase0082551''

exec [operational].[sproc_facacq_post_ifCopyOrders_02_AdminOrderAudit]
@source_db = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei964''
,@source_fac_id = ''1''
,@destination_fac_id = ''2''
,@NSCaseNumber = ''EICase0082551''

exec [operational].[sproc_facacq_post_ifCopyOrders_03_RelatedOrderAudit]
@source_db = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei964''
,@source_fac_id = ''1''
,@destination_fac_id = ''2''
,@NSCaseNumber = ''EICase0082551''

exec [operational].[sproc_facacq_post_ifOnlineDocumentation_Location_Update]
@source_org_code = ''ssch''
,@destination_org_code = ''mea''
,@source_fac_id = ''1''
,@destination_fac_id = ''2''
,@NSCaseNumber = ''EICase0082551''

exec [operational].[sproc_facacq_post_ifCopyLabs]
@source_db = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei964''
,@destination_fac_id = ''2''
,@NSCaseNumber = ''EICase0082551''

declare @timestamp datetime = getdate()

exec [dbo].[pcc_update_cache_time] @fac_id = ''2'',@cache_name = ''facilityRecs'',@cache_time = @timestamp OUTPUT

exec [dbo].[pcc_update_cache_time] @fac_id = -1,@cache_name = ''MASTER'',@cache_time = @timestamp OUTPUT

DELETE FROM dbo.facility_scheduling_cycle;
INSERT INTO dbo.facility_scheduling_cycle(fac_id, run_day)
SELECT fac_id, (CASE WHEN fac_id % 20 <> 0 THEN fac_id % 20 ELSE 20 END) + 6 AS runDay 
FROM dbo.facility WHERE ((FACILITY.fac_id  <> 9999 AND (FACILITY.inactive IS NULL OR FACILITY.inactive  <> ''Y'') AND (FACILITY.is_live <> ''N'' OR FACILITY.is_live IS NULL ))) 
AND ((FACILITY.DELETED = ''N''))

DECLARE @rcnt int = 0
DECLARE @nsqlcheck nvarchar(1000)
SET @nsqlcheck = ''select @rcnt = count(1) from [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei964.dbo.emrlink_client_sync_tracking src with (nolock)
where src.client_id in (select src_id from EICase0082551clients with (nolock))''
EXEC Sp_executesql @nsqlcheck, N''@rcnt INT OUTPUT'', @rcnt OUTPUT
IF @rcnt <> 0 BEGIN 

exec [operational].[sproc_facacq_post_IfCopyEMRLink_01_emrlink_client_sync_tracking]
@src_db_location = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei964''
,@NS_case_number = ''EICase0082551''

exec [operational].[sproc_facacq_post_IfCopyEMRLink_02_emrlink_order_sync_tracking]
@src_db_location = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei964''
,@NS_case_number = ''EICase0082551''

exec [operational].[sproc_facacq_post_IfCopyEMRLink_03_emrlink_order_sync_error_tracking]
@src_db_location = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei964''
,@NS_case_number = ''EICase0082551''

if exists(select 1 from information_schema.TABLES where table_name = ''EICase0082551result_lab_report'') BEGIN
exec [operational].[sproc_facacq_post_IfCopyEMRLink_04_pho_lab_integrated_order_detail]
@src_db_location = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei964''
,@NS_case_number = ''EICase0082551''
END

if exists(select 1 from information_schema.TABLES where table_name = ''EICase0082551result_radiology_report'') BEGIN
exec [operational].[sproc_facacq_post_IfCopyEMRLink_05_pho_rad_integrated_order_detail]
@src_db_location = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei964''
,@NS_case_number = ''EICase0082551''
END

END

', 
		@database_name=N'us_mea', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase0082551 Fac 2 : POST    Custom on Destination ******]    Script Date: 3/15/2022 2:42:31 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase0082551 Fac 2 : POST    Custom on Destination ******', 
		@step_id=16, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=20, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SELECT 1', 
		@database_name=N'us_mea', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase0082551 Fac 2 : Email Notification Data Copy Completed]    Script Date: 3/15/2022 2:42:31 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase0082551 Fac 2 : Email Notification Data Copy Completed', 
		@step_id=17, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=20, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE MASTER
EXEC msdb.dbo.sp_send_dbmail @recipients =''dinesh.gunalapan@pointclickcare.com;TSFacAcqConfig@pointclickcare.com'',
@subject=''Scheduled Data Copy March 14, PMO - 008255'',
@body=''Hi All,</br></br> Data Copy for MEA is now completed and following facility is back online :</br></br>Sunnyside Convalescent Hospital</br></br></br></br></br>Thanks,</br>Facility Acquisition Team'',
@body_format=''HTML''

EXEC msdb.dbo.sp_send_dbmail @recipients =''linda.k@pointclickcare.com;MarioM@sunnysiderehab.org;Mercia@sunnysiderehab.org;Administrator@sunnysiderehab.org;Medicalrecords@sunnysiderehab.org;Mweston@LTCconsulting.com;BOM@sunnysiderehab.org;Ashlee.Moss@pointclickcare.com;Wendy.Panganiban@pointclickcare.com;Sarah.D@pointclickcare.com;rina.p@pointclickcare.com;nigel.liang@pointclickcare.com;theresa.w@pointclickcare.com;TSFacAcqConfig@pointclickcare.com'',
@subject=''PMO - 008255, Data Copy of SSCH to MEA : Friendly reminder'',
@body=''Hi All,</br></br> Data Copy for MEA is now completed and following facility is back online :</br></br>Sunnyside Convalescent Hospital</br></br></br></br></br>Thanks,</br>Facility Acquisition Team</br></br>NOTE: If there’s any post data copy issue please reply all to this email.'',
@body_format=''HTML''', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update ds_merge_master.dbo.LoadEIMaster_PMO_Groups]    Script Date: 3/15/2022 2:42:31 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update ds_merge_master.dbo.LoadEIMaster_PMO_Groups', 
		@step_id=18, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=20, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE us_mea
SELECT 1', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Copy Mergelog to Destination DB]    Script Date: 3/15/2022 2:42:31 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Copy Mergelog to Destination DB', 
		@step_id=19, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=20, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE us_mea
EXEC [operational].[sproc_facacq_createInsertMergelogStagingToDestination] 
@StagingDB=''pcc_staging_db008255'';

', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [TS Job Failure Email Notification]    Script Date: 3/15/2022 2:42:31 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'TS Job Failure Email Notification', 
		@step_id=20, 
		@cmdexec_success_code=0, 
		@on_success_action=2, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE us_mea
EXEC [operational].[sproc_facacq_sendEmailNotification] @Recipient = ''dinesh.gunalapan@pointclickcare.com;TSFacAcqConfig@pointclickcare.com''
					,@BlindCopyRecipients = ''TSFacAcqConfig@pointclickcare.com''
					,@JobName = ''EI_Prepare_Destination__008255 ''
					,@ServerName = ''[pccsql-use2-prod-w19-cli0003.3055e0bc69f6.database.windows.net]''', 
		@database_name=N'master', 
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


