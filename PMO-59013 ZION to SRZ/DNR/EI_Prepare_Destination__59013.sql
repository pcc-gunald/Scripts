USE [msdb]
GO

/****** Object:  Job [EI_Prepare_Destination__59013]    Script Date: 1/13/2022 7:45:11 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 1/13/2022 7:45:11 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'EI_Prepare_Destination__59013', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Job to excute ETL Staging to Destination for EI PMO: 59013', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Restore Staging DB on Destination Server]    Script Date: 1/13/2022 7:45:12 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Restore Staging DB on Destination Server', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=28, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE MASTER
RESTORE DATABASE pcc_staging_db59013 FROM URL = ''https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1763/Final_GoLive/pcc_staging_db59013_Case590132_20220110100416_1.BAK'', URL = ''https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1763/Final_GoLive/pcc_staging_db59013_Case590132_20220110100416_2.BAK'', URL = ''https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1763/Final_GoLive/pcc_staging_db59013_Case590132_20220110100416_3.BAK'', URL = ''https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups/PMOGroup1763/Final_GoLive/pcc_staging_db59013_Case590132_20220110100416_4.BAK''', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [FK Validation Checking All FK values from Staging to Destination]    Script Date: 1/13/2022 7:45:12 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'FK Validation Checking All FK values from Staging to Destination', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=28, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE pcc_staging_db59013
EXEC [operational].[sproc_facacq_FKValidation] @staging_db=''pcc_staging_db59013'', @destination_db=''us_srz_multi''', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Send Email & Wait for 15 Minutes]    Script Date: 1/13/2022 7:45:12 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Send Email & Wait for 15 Minutes', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=28, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE MASTER
EXEC msdb.dbo.sp_send_dbmail @recipients =''dinesh.gunalapan@pointclickcare.com;TechServicesCustomerMaintenance@pointclickcare.com'',
@subject=''Scheduled Data Copy January 10, PMO - 59013'',
@body=''Hi All,</br></br> Org SRZ will be offline in 15 minutes.</br></br></br> Thanks,</br> Facility Acquisition Team'',
@body_format=''HTML''

EXEC msdb.dbo.sp_send_dbmail @recipients =''Ashlee.Moss@pointclickcare.com;Suzette.Edgar@pointclickcare.com;Keith.Tomaszewski@pointclickcare.com;Adrian.Rizos@pointclickcare.com;TSFacAcqConfig@pointclickcare.com;melodee.mercado@pointclickcare.com;Laurie.Watkins@pointclickcare.com;jstroder@daashc.com;lalaran@daashc.com;'',
@subject=''PMO - 59013, Data Copy of ZION to SRZ : Friendly reminder'',
@body=''Hi All,</br></br> Org SRZ will be offline in 15 minutes.</br></br></br> Thanks,</br> Facility Acquisition Team'',
@body_format=''HTML''

WAITFOR DELAY ''00:15:00''', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Alter Login Destination DB Disable]    Script Date: 1/13/2022 7:45:12 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Alter Login Destination DB Disable', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=28, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'ALTER LOGIN us_srz_multi DISABLE', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Drop Staging Tables]    Script Date: 1/13/2022 7:45:12 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Drop Staging Tables', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=28, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE us_srz_multi

EXEC [operational].[sproc_facacq_dropStagingTables]
', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Create/Populate table ListOfDeferTables]    Script Date: 1/13/2022 7:45:12 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Create/Populate table ListOfDeferTables', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=28, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE us_srz_multi

EXEC [operational].[sproc_facacq_createListOfDeferTables]
EXEC [operational].[sproc_facacq_populateListOfDeferTables] @conv_server= ''vmuspassvtsjob1.pccprod.local''', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Staging to Destination OFFLINE INSERT]    Script Date: 1/13/2022 7:45:12 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Staging to Destination OFFLINE INSERT', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=28, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE us_srz_multi

DECLARE @ReturnVal INT
SET @ReturnVal = 0

IF @ReturnVal = 0
BEGIN
	SET QUOTED_IDENTIFIER ON
	EXEC @ReturnVal=[operational].[sproc_facacq_insertStagingToDestinationOffline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',@ModuleToCopy=''E1'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''59013'',@resource=''gunald'',
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
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',@ModuleToCopy=''E2'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''59013'',@resource=''gunald'',
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
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',@ModuleToCopy=''E2a'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''59013'',@resource=''gunald'',
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
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',@ModuleToCopy=''E3'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''59013'',@resource=''gunald'',
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
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',@ModuleToCopy=''E4'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''59013'',@resource=''gunald'',
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
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',@ModuleToCopy=''E5'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''59013'',@resource=''gunald'',
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
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',@ModuleToCopy=''E6'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''59013'',@resource=''gunald'',
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
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',@ModuleToCopy=''E7a'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''59013'',@resource=''gunald'',
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
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',@ModuleToCopy=''E7b'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''59013'',@resource=''gunald'',
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
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',@ModuleToCopy=''E7c'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''59013'',@resource=''gunald'',
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
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',@ModuleToCopy=''E8'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''59013'',@resource=''gunald'',
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
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',@ModuleToCopy=''E12a'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''59013'',@resource=''gunald'',
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
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',@ModuleToCopy=''E12b'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''59013'',@resource=''gunald'',
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
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',@ModuleToCopy=''E11'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''59013'',@resource=''gunald'',
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
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',@ModuleToCopy=''E9'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''59013'',@resource=''gunald'',
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
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',@ModuleToCopy=''E10'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''59013'',@resource=''gunald'',
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
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',@ModuleToCopy=''E16'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''59013'',@resource=''gunald'',
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
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',@ModuleToCopy=''E13'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''59013'',@resource=''gunald'',
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
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',@ModuleToCopy=''E17'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,@ContinueMerge=''0'',@ReturnVal=0,@flgOffLine=0,@MultiFacId=NULL
END
ELSE
BEGIN
	;THROW 51000,''ERROR: OffLine Insert:- E17'', 1
END
IF @ReturnVal = 0
BEGIN
	SET QUOTED_IDENTIFIER ON
	EXEC @ReturnVal=[operational].[sproc_facacq_insertStagingToDestinationOffline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',@ModuleToCopy=''E18'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''59013'',@resource=''gunald'',
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
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',@ModuleToCopy=''E20'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''59013'',@resource=''gunald'',
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
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',@ModuleToCopy=''E21'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''59013'',@resource=''gunald'',
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
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',@ModuleToCopy=''E22'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,@ContinueMerge=''0'',@ReturnVal=0,@flgOffLine=0,@MultiFacId=NULL
END
ELSE
BEGIN
	;THROW 51000,''ERROR: OffLine Insert:- E22'', 1
END
IF @ReturnVal = 0
BEGIN
	SET QUOTED_IDENTIFIER ON
	EXEC @ReturnVal=[operational].[sproc_facacq_insertStagingToDestinationOffline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'',@StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',@ModuleToCopy=''E23'',
	@TranFlag=NULL,@prefix=NULL,@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,@ContinueMerge=''0'',@ReturnVal=0,@flgOffLine=0,@MultiFacId=NULL
END
ELSE
BEGIN
	;THROW 51000,''ERROR: OffLine Insert:- E23'', 1
END', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Alter Login Destination DB Enable]    Script Date: 1/13/2022 7:45:12 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Alter Login Destination DB Enable', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=28, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'ALTER LOGIN us_srz_multi ENABLE', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Email Notification DB Online]    Script Date: 1/13/2022 7:45:12 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Email Notification DB Online', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=28, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE MASTER
EXEC msdb.dbo.sp_send_dbmail @recipients =''dinesh.gunalapan@pointclickcare.com;TechServicesCustomerMaintenance@pointclickcare.com'',
@subject=''Scheduled Data Copy January 10, PMO - 59013'',
@body=''Hi All,</br></br> Org SRZ is now back online.</br></br>Following facilities are still offline:</br></br>Zion Healthcare
</br>Blanco Villa Nursing and Rehabilitation</br></br></br>Thanks,</br>Facility Acquisition Team'',
@body_format=''HTML''

EXEC msdb.dbo.sp_send_dbmail @recipients =''Ashlee.Moss@pointclickcare.com;Suzette.Edgar@pointclickcare.com;Keith.Tomaszewski@pointclickcare.com;Adrian.Rizos@pointclickcare.com;TSFacAcqConfig@pointclickcare.com;melodee.mercado@pointclickcare.com;Laurie.Watkins@pointclickcare.com;jstroder@daashc.com;lalaran@daashc.com;'',
@subject=''PMO - 59013, Data Copy of ZION to SRZ : Friendly reminder'',
@body=''Hi All,</br></br> Org SRZ is now back online.</br></br>Following facilities are still offline:</br></br>Zion Healthcare
</br>Blanco Villa Nursing and Rehabilitation</br></br></br>Thanks,</br>Facility Acquisition Team'',
@body_format=''HTML''', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase590131 Fac 29 : Copy Mapping Tables to Destination DB]    Script Date: 1/13/2022 7:45:12 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase590131 Fac 29 : Copy Mapping Tables to Destination DB', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=28, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE us_srz_multi
EXEC [operational].[sproc_facacq_createInsertMappingTablesStagingToDestination] 
@StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
@prefix=''EICASE590131'',@ReturnVal=NULL', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase590131 Fac 29 : ONLINE INSERT]    Script Date: 1/13/2022 7:45:12 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase590131 Fac 29 : ONLINE INSERT', 
		@step_id=11, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=28, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE us_srz_multi
DECLARE @ReturnVal INT
SET @ReturnVal=0

IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E1'',@TranFlag=NULL,@prefix=''EICASE590131'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=1,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=29
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E2'',@TranFlag=NULL,@prefix=''EICASE590131'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=29
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E2a'',@TranFlag=NULL,@prefix=''EICASE590131'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=29
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E3'',@TranFlag=NULL,@prefix=''EICASE590131'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=29
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E4'',@TranFlag=NULL,@prefix=''EICASE590131'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=29
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E5'',@TranFlag=NULL,@prefix=''EICASE590131'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=29
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E6'',@TranFlag=NULL,@prefix=''EICASE590131'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=29
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E7a'',@TranFlag=NULL,@prefix=''EICASE590131'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=29
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E7b'',@TranFlag=NULL,@prefix=''EICASE590131'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=29
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E7c'',@TranFlag=NULL,@prefix=''EICASE590131'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=29
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E8'',@TranFlag=NULL,@prefix=''EICASE590131'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=29
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E12a'',@TranFlag=NULL,@prefix=''EICASE590131'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=29
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E12b'',@TranFlag=NULL,@prefix=''EICASE590131'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=29
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E11'',@TranFlag=NULL,@prefix=''EICASE590131'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=29
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E9'',@TranFlag=NULL,@prefix=''EICASE590131'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=29
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E10'',@TranFlag=NULL,@prefix=''EICASE590131'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=29
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E16'',@TranFlag=NULL,@prefix=''EICASE590131'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=29
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E13'',@TranFlag=NULL,@prefix=''EICASE590131'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=29
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E17'',@TranFlag=NULL,@prefix=''EICASE590131'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=29
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E18'',@TranFlag=NULL,@prefix=''EICASE590131'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=29
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E20'',@TranFlag=NULL,@prefix=''EICASE590131'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=29
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E21'',@TranFlag=NULL,@prefix=''EICASE590131'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=29
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E22'',@TranFlag=NULL,@prefix=''EICASE590131'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=29
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E23'',@TranFlag=NULL,@prefix=''EICASE590131'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=29
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590131 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase590131 Fac 29 : Insert Into EIHistory]    Script Date: 1/13/2022 7:45:12 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase590131 Fac 29 : Insert Into EIHistory', 
		@step_id=12, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=28, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE us_srz_multi
INSERT INTO [vmuspassvtsjob1.pccprod.local].[ds_merge_master].[dbo].[EIHistory] 
									([case_no],[PMO_number],[DS_resource],[src_org_code],[dst_org_code],[src_fac_id],[dst_fac_id]
									,[src_EOM],[dst_EOM]
									,[mod_resident_identifiers_contact],[mod_security_roles],[mod_security_users],[mod_staff],[mod_medical_prof]
									,[mod_external_facility],[mod_user_defined_data],[mod_room_bed],[mod_census],[mod_assess_MDS2],[mod_assess_MDS3]
									,[mod_custom_UDA],[mod_MMQ],[mod_MMA],[mod_diagnosis],[mod_immunization],[mod_care_plan_custom],[mod_care_plan_library]
									,[mod_progress_note],[mod_weight_vitals],[mod_physician_order],[mod_alerts],[mod_risk_management],[mod_trust],[mod_irm]
									,[mod_online_doc],[mod_LabResultRadiology],[mod_Master_Insurance],[mod_Notes],[created_by],[revision_by])
									VALUES 
(''590131'',''59013'',''gunald'',''zion (Test Env =usei1058)'',''srz'',''29-59013-Zion Healthcare'',''29-Zion Healthcare'',''Y'',''Y'',''Y'',''N'',''N'',''Y'',''Y'',''Y'',''Y'',''Y'',''Y'',''Y'',''Y'',''Y'',''N'',''N'',''Y'',''Y'',''Y'',''Y'',''Y'',''Y'',''Y'',''Y'',''Y'',''Y'',''N'',''Y'',''Y'',''Y'',''Y'',''SQLJob'',''SQLJob'')', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase590131 Fac 29 : Update LoadEIMaster_Automation]    Script Date: 1/13/2022 7:45:12 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase590131 Fac 29 : Update LoadEIMaster_Automation', 
		@step_id=13, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=28, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE us_srz_multi
UPDATE [vmuspassvtsjob1.pccprod.local].[ds_merge_master].[dbo].LoadEIMaster_Automation
SET completed = 1 WHERE RunID=644', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase590131 Fac 29 : Enable Facility]    Script Date: 1/13/2022 7:45:12 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase590131 Fac 29 : Enable Facility', 
		@step_id=14, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=28, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE us_srz_multi
UPDATE us_srz_multi.[dbo].facility
SET deleted=''N'', inactive = NULL, inactive_date = NULL WHERE fac_id=''29''', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase590131 Fac 29 : POST    Standard on Destination]    Script Date: 1/13/2022 7:45:12 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase590131 Fac 29 : POST    Standard on Destination', 
		@step_id=15, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=28, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE us_srz_multi
SET CONTEXT_INFO 0xDC1000000;
 SET DEADLOCK_PRIORITY 4;
 SET QUOTED_IDENTIFIER ON;

exec [operational].[sproc_facacq_post_MpiHistoryInsert]
@src_db_location = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058''
,@NS_Case_Number = ''EICase590131''
,@source_fac_id = ''29''

exec [operational].[sproc_facacq_post_Insert_common_code_standard_contact_type_mapping]
@src_db_location = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058''
,@NS_Case_Number = ''EICase590131''

exec [operational].[sproc_facacq_post_IfUserDefinedDataRemoveDups]
@NS_Case_Number = ''EICase590131''

exec [operational].[sproc_facacq_post_ifUsingEinteract]
@NSCaseNumber = ''EICase590131''

exec [operational].[sproc_facacq_post_ifCopyUDAqlibFix]
@source_db = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058''
,@NSCaseNumber = ''EICase590131''

BEGIN DECLARE @SRCSTRING VARCHAR(50); DECLARE @DSTSTRING VARCHAR(50);DECLARE @rowid INT = 0;DECLARE @sqln NVARCHAR(max); DECLARE @sql VARCHAR(max); DECLARE @rowcount INT = 0;

SET @sqln = N''SELECT @rowcount = COUNT(1) FROM EICase590131as_std_score'' EXEC sp_executesql @sqln, N''@rowcount INT  OUTPUT'', @rowcount OUTPUT
SET @sql = ''select distinct 1 from as_std_score with (nolock) where std_score_id in (select dst_id from EICase590131as_std_score where corporate = ''''N'''') and formula like ''''%[[]SCR%''''''IF @@ROWCOUNT <> 0
BEGIN WHILE (@rowid <= @rowcount) 
BEGIN SET @sqln = N''SELECT TOP 1 @rowid = row_id FROM EICase590131as_std_score WHERE CORPORATE = ''''N'''' and row_id > '' + convert(varchar,@rowid) + '' ORDER BY row_id''
EXEC sp_executesql @sqln, N''@rowid int  OUTPUT'', @rowid OUTPUT
IF @@ROWCOUNT = 0 BREAK;
SET @sqln = N''SELECT @SRCSTRING = ''''[SCR_'''' + convert(varchar, src_id) + '''']'''' FROM EICase590131as_std_score WHERE CORPORATE = ''''N'''' AND ROW_ID = '' + convert(varchar,@rowid)
EXEC sp_executesql @sqln, N''@SRCSTRING VARCHAR(50)  OUTPUT'', @SRCSTRING OUTPUT
SET @sqln = N''SELECT @DSTSTRING = ''''[SCR_'''' + convert(varchar, dst_id) + '''']'''' FROM EICase590131as_std_score WHERE CORPORATE = ''''N'''' AND ROW_ID = '' + convert(varchar,@rowid)
EXEC sp_executesql @sqln, N''@DSTSTRING VARCHAR(50)  OUTPUT'', @DSTSTRING OUTPUT

SET @sql = ''if exists(select 1 from as_std_score dst with (nolock) join EICase590131as_std_score map on dst.std_score_id = map.dst_id
join [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.dbo.as_std_score src on map.src_id = src.std_score_id
where map.corporate = ''''N'''' and src.formula like ''''%'''' + replace('''''' + @SRCSTRING + '''''',''''['''',''''[[]'''') + ''''%''''
and exists (select 1 from as_std_score with (nolock) 
where dst.std_score_id = std_score_id and formula like ''''%'''' + replace('''''' + @DSTSTRING + '''''',''''['''',''''[[]'''') + ''''%''''))
BEGIN PRINT ''''--check: src - '' + @SRCSTRING + '' dst - '' + @DSTSTRING + ''''''END'' exec(@sql)

SET @sql = ''update dst SET dst.formula = replace(dst.formula,''''''+@SRCSTRING+'''''',''''''+@DSTSTRING+'''''')
from as_std_score dst join EICase590131as_std_score map on dst.std_score_id = map.dst_id
join [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.dbo.as_std_score src with (nolock) on map.src_id = src.std_score_id
where map.corporate = ''''N'''' and src.formula like ''''%'''' + replace(''''''+@SRCSTRING+'''''',''''['''',''''[[]'''') + ''''%''''
and not exists (select 1 from as_std_score with (nolock) 
where dst.std_score_id = std_score_id and formula like ''''%'''' + replace(''''''+@DSTSTRING+'''''',''''['''',''''[[]'''') + ''''%'''')
''exec (@sql) END END END

exec [operational].[sproc_facacq_post_ifCopyDiagnosis]
@source_db = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058''
,@destination_fac_id = ''29''
,@NSCaseNumber = ''EICase590131''

DELETE FROM PCC_GLOBAL_PRIMARY_KEY WHERE TABLE_NAME = ''PHO_ADMIN_ORDER_AUDIT'';
DELETE FROM PCC_GLOBAL_PRIMARY_KEY WHERE TABLE_NAME = ''PHO_RELATED_ORDER_AUDIT'';

exec [operational].[sproc_facacq_post_ifCopyOrders_01_OrderAudit]
@source_db = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058''
,@source_fac_id = ''29''
,@destination_fac_id = ''29''
,@NSCaseNumber = ''EICase590131''

exec [operational].[sproc_facacq_post_ifCopyOrders_02_AdminOrderAudit]
@source_db = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058''
,@source_fac_id = ''29''
,@destination_fac_id = ''29''
,@NSCaseNumber = ''EICase590131''

exec [operational].[sproc_facacq_post_ifCopyOrders_03_RelatedOrderAudit]
@source_db = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058''
,@source_fac_id = ''29''
,@destination_fac_id = ''29''
,@NSCaseNumber = ''EICase590131''

exec [operational].[sproc_facacq_post_ifCopyRiskManagement]
@source_db = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058''
,@NSCaseNumber = ''EICase590131''

exec [operational].[sproc_facacq_post_ifCopyUDAandRiskManagement]
@destination_fac_id = ''29''
,@NSCaseNumber = ''EICase590131''

exec [operational].[sproc_facacq_post_ifOnlineDocumentation_Location_Update]
@source_org_code = ''zion''
,@destination_org_code = ''srz''
,@source_fac_id = ''29''
,@destination_fac_id = ''29''
,@NSCaseNumber = ''EICase590131''

exec [operational].[sproc_facacq_post_ifCopyLabs]
@source_db = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058''
,@destination_fac_id = ''29''
,@NSCaseNumber = ''EICase590131''

', 
		@database_name=N'us_srz_multi', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase590131 Fac 29 : POST    Custom on Destination ******]    Script Date: 1/13/2022 7:45:12 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase590131 Fac 29 : POST    Custom on Destination ******', 
		@step_id=16, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=28, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SELECT 1', 
		@database_name=N'us_srz_multi', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase590131 Fac 29 : Email Notification Data Copy Completed]    Script Date: 1/13/2022 7:45:12 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase590131 Fac 29 : Email Notification Data Copy Completed', 
		@step_id=17, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=28, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE MASTER
EXEC msdb.dbo.sp_send_dbmail @recipients =''dinesh.gunalapan@pointclickcare.com;TechServicesCustomerMaintenance@pointclickcare.com'',
@subject=''Scheduled Data Copy January 10, PMO - 59013'',
@body=''Hi All,</br></br> Following facility is now online in SRZ :</br></br>Zion Healthcare</br></br>Following facility is still offline in SRZ :</br></br>Blanco Villa Nursing and Rehabilitation</br></br></br></br></br>Thanks,</br>Facility Acquisition Team'',
@body_format=''HTML''

EXEC msdb.dbo.sp_send_dbmail @recipients =''Ashlee.Moss@pointclickcare.com;Suzette.Edgar@pointclickcare.com;Keith.Tomaszewski@pointclickcare.com;Adrian.Rizos@pointclickcare.com;TSFacAcqConfig@pointclickcare.com;melodee.mercado@pointclickcare.com;Laurie.Watkins@pointclickcare.com;jstroder@daashc.com;lalaran@daashc.com;'',
@subject=''PMO - 59013, Data Copy of ZION to SRZ : Friendly reminder'',
@body=''Hi All,</br></br> Following facility is now online in SRZ :</br></br>Zion Healthcare</br></br>Following facility is still offline in SRZ :</br></br>Blanco Villa Nursing and Rehabilitation</br></br></br></br></br>Thanks,</br>Facility Acquisition Team</br></br>NOTE: If there’s any post data copy issue please reply all to this email.'',
@body_format=''HTML''', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase590132 Fac 30 : Copy Mapping Tables to Destination DB]    Script Date: 1/13/2022 7:45:12 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase590132 Fac 30 : Copy Mapping Tables to Destination DB', 
		@step_id=18, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=28, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE us_srz_multi
EXEC [operational].[sproc_facacq_createInsertMappingTablesStagingToDestination] 
@StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
@prefix=''EICASE590132'',@ReturnVal=NULL', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase590132 Fac 30 : ONLINE INSERT]    Script Date: 1/13/2022 7:45:12 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase590132 Fac 30 : ONLINE INSERT', 
		@step_id=19, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=28, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE us_srz_multi
DECLARE @ReturnVal INT
SET @ReturnVal=0

IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E1'',@TranFlag=NULL,@prefix=''EICASE590132'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=1,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=30
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E2'',@TranFlag=NULL,@prefix=''EICASE590132'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=30
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E2a'',@TranFlag=NULL,@prefix=''EICASE590132'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=30
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E3'',@TranFlag=NULL,@prefix=''EICASE590132'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=30
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E4'',@TranFlag=NULL,@prefix=''EICASE590132'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=30
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E5'',@TranFlag=NULL,@prefix=''EICASE590132'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=30
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E6'',@TranFlag=NULL,@prefix=''EICASE590132'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=30
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E7a'',@TranFlag=NULL,@prefix=''EICASE590132'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=30
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E7b'',@TranFlag=NULL,@prefix=''EICASE590132'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=30
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E7c'',@TranFlag=NULL,@prefix=''EICASE590132'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=30
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E8'',@TranFlag=NULL,@prefix=''EICASE590132'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=30
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E12a'',@TranFlag=NULL,@prefix=''EICASE590132'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=30
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E12b'',@TranFlag=NULL,@prefix=''EICASE590132'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=30
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E11'',@TranFlag=NULL,@prefix=''EICASE590132'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=30
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E9'',@TranFlag=NULL,@prefix=''EICASE590132'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=30
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E10'',@TranFlag=NULL,@prefix=''EICASE590132'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=30
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E16'',@TranFlag=NULL,@prefix=''EICASE590132'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=30
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E13'',@TranFlag=NULL,@prefix=''EICASE590132'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=30
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E17'',@TranFlag=NULL,@prefix=''EICASE590132'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=30
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E18'',@TranFlag=NULL,@prefix=''EICASE590132'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=30
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E20'',@TranFlag=NULL,@prefix=''EICASE590132'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=30
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E21'',@TranFlag=NULL,@prefix=''EICASE590132'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=30
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E22'',@TranFlag=NULL,@prefix=''EICASE590132'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=30
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END
IF @ReturnVal=0
BEGIN
	EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] 
	@conv_server=''vmuspassvtsjob1.pccprod.local'', @StagingDB=''pcc_staging_db59013'',@DestinationDB=''us_srz_multi'',
	@ModuleToCopy=''E23'',@TranFlag=NULL,@prefix=''EICASE590132'',
	@pmo=''59013'',@resource=''gunald'',
	@RunIDFlag=2,	@ContinueMerge=''0'',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=30
END
ELSE
BEGIN
	;THROW 51000,''ERROR: Case No: 590132 : Error on sproc_facacq_insertStagingToDestinationOnline'', 1
END', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase590132 Fac 30 : Insert Into EIHistory]    Script Date: 1/13/2022 7:45:12 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase590132 Fac 30 : Insert Into EIHistory', 
		@step_id=20, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=28, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE us_srz_multi
INSERT INTO [vmuspassvtsjob1.pccprod.local].[ds_merge_master].[dbo].[EIHistory] 
									([case_no],[PMO_number],[DS_resource],[src_org_code],[dst_org_code],[src_fac_id],[dst_fac_id]
									,[src_EOM],[dst_EOM]
									,[mod_resident_identifiers_contact],[mod_security_roles],[mod_security_users],[mod_staff],[mod_medical_prof]
									,[mod_external_facility],[mod_user_defined_data],[mod_room_bed],[mod_census],[mod_assess_MDS2],[mod_assess_MDS3]
									,[mod_custom_UDA],[mod_MMQ],[mod_MMA],[mod_diagnosis],[mod_immunization],[mod_care_plan_custom],[mod_care_plan_library]
									,[mod_progress_note],[mod_weight_vitals],[mod_physician_order],[mod_alerts],[mod_risk_management],[mod_trust],[mod_irm]
									,[mod_online_doc],[mod_LabResultRadiology],[mod_Master_Insurance],[mod_Notes],[created_by],[revision_by])
									VALUES 
(''590132'',''59013'',''gunald'',''zion (Test Env =usei1058)'',''srz'',''32-59013-Blanco Villa Nursing and Rehabilitation'',''30-Blanco Villa Nursing and Rehabilitation'',''Y'',''Y'',''Y'',''N'',''N'',''Y'',''Y'',''Y'',''Y'',''Y'',''Y'',''Y'',''Y'',''Y'',''N'',''N'',''Y'',''Y'',''Y'',''Y'',''Y'',''Y'',''Y'',''Y'',''Y'',''Y'',''N'',''Y'',''Y'',''Y'',''Y'',''SQLJob'',''SQLJob'')', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase590132 Fac 30 : Update LoadEIMaster_Automation]    Script Date: 1/13/2022 7:45:12 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase590132 Fac 30 : Update LoadEIMaster_Automation', 
		@step_id=21, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=28, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE us_srz_multi
UPDATE [vmuspassvtsjob1.pccprod.local].[ds_merge_master].[dbo].LoadEIMaster_Automation
SET completed = 1 WHERE RunID=646', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase590132 Fac 30 : Enable Facility]    Script Date: 1/13/2022 7:45:12 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase590132 Fac 30 : Enable Facility', 
		@step_id=22, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=28, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE us_srz_multi
UPDATE us_srz_multi.[dbo].facility
SET deleted=''N'', inactive = NULL, inactive_date = NULL WHERE fac_id=''30''', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase590132 Fac 30 : POST    Standard on Destination]    Script Date: 1/13/2022 7:45:12 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase590132 Fac 30 : POST    Standard on Destination', 
		@step_id=23, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=28, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE us_srz_multi
SET CONTEXT_INFO 0xDC1000000;
 SET DEADLOCK_PRIORITY 4;
 SET QUOTED_IDENTIFIER ON;

exec [operational].[sproc_facacq_post_MpiHistoryInsert]
@src_db_location = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058''
,@NS_Case_Number = ''EICase590132''
,@source_fac_id = ''32''

exec [operational].[sproc_facacq_post_Insert_common_code_standard_contact_type_mapping]
@src_db_location = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058''
,@NS_Case_Number = ''EICase590132''

exec [operational].[sproc_facacq_post_IfUserDefinedDataRemoveDups]
@NS_Case_Number = ''EICase590132''

exec [operational].[sproc_facacq_post_ifUsingEinteract]
@NSCaseNumber = ''EICase590132''

exec [operational].[sproc_facacq_post_ifCopyUDAqlibFix]
@source_db = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058''
,@NSCaseNumber = ''EICase590132''

BEGIN DECLARE @SRCSTRING VARCHAR(50); DECLARE @DSTSTRING VARCHAR(50);DECLARE @rowid INT = 0;DECLARE @sqln NVARCHAR(max); DECLARE @sql VARCHAR(max); DECLARE @rowcount INT = 0;

SET @sqln = N''SELECT @rowcount = COUNT(1) FROM EICase590132as_std_score'' EXEC sp_executesql @sqln, N''@rowcount INT  OUTPUT'', @rowcount OUTPUT
SET @sql = ''select distinct 1 from as_std_score with (nolock) where std_score_id in (select dst_id from EICase590132as_std_score where corporate = ''''N'''') and formula like ''''%[[]SCR%''''''IF @@ROWCOUNT <> 0
BEGIN WHILE (@rowid <= @rowcount) 
BEGIN SET @sqln = N''SELECT TOP 1 @rowid = row_id FROM EICase590132as_std_score WHERE CORPORATE = ''''N'''' and row_id > '' + convert(varchar,@rowid) + '' ORDER BY row_id''
EXEC sp_executesql @sqln, N''@rowid int  OUTPUT'', @rowid OUTPUT
IF @@ROWCOUNT = 0 BREAK;
SET @sqln = N''SELECT @SRCSTRING = ''''[SCR_'''' + convert(varchar, src_id) + '''']'''' FROM EICase590132as_std_score WHERE CORPORATE = ''''N'''' AND ROW_ID = '' + convert(varchar,@rowid)
EXEC sp_executesql @sqln, N''@SRCSTRING VARCHAR(50)  OUTPUT'', @SRCSTRING OUTPUT
SET @sqln = N''SELECT @DSTSTRING = ''''[SCR_'''' + convert(varchar, dst_id) + '''']'''' FROM EICase590132as_std_score WHERE CORPORATE = ''''N'''' AND ROW_ID = '' + convert(varchar,@rowid)
EXEC sp_executesql @sqln, N''@DSTSTRING VARCHAR(50)  OUTPUT'', @DSTSTRING OUTPUT

SET @sql = ''if exists(select 1 from as_std_score dst with (nolock) join EICase590132as_std_score map on dst.std_score_id = map.dst_id
join [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.dbo.as_std_score src on map.src_id = src.std_score_id
where map.corporate = ''''N'''' and src.formula like ''''%'''' + replace('''''' + @SRCSTRING + '''''',''''['''',''''[[]'''') + ''''%''''
and exists (select 1 from as_std_score with (nolock) 
where dst.std_score_id = std_score_id and formula like ''''%'''' + replace('''''' + @DSTSTRING + '''''',''''['''',''''[[]'''') + ''''%''''))
BEGIN PRINT ''''--check: src - '' + @SRCSTRING + '' dst - '' + @DSTSTRING + ''''''END'' exec(@sql)

SET @sql = ''update dst SET dst.formula = replace(dst.formula,''''''+@SRCSTRING+'''''',''''''+@DSTSTRING+'''''')
from as_std_score dst join EICase590132as_std_score map on dst.std_score_id = map.dst_id
join [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058.dbo.as_std_score src with (nolock) on map.src_id = src.std_score_id
where map.corporate = ''''N'''' and src.formula like ''''%'''' + replace(''''''+@SRCSTRING+'''''',''''['''',''''[[]'''') + ''''%''''
and not exists (select 1 from as_std_score with (nolock) 
where dst.std_score_id = std_score_id and formula like ''''%'''' + replace(''''''+@DSTSTRING+'''''',''''['''',''''[[]'''') + ''''%'''')
''exec (@sql) END END END

exec [operational].[sproc_facacq_post_ifCopyDiagnosis]
@source_db = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058''
,@destination_fac_id = ''30''
,@NSCaseNumber = ''EICase590132''

DELETE FROM PCC_GLOBAL_PRIMARY_KEY WHERE TABLE_NAME = ''PHO_ADMIN_ORDER_AUDIT'';
DELETE FROM PCC_GLOBAL_PRIMARY_KEY WHERE TABLE_NAME = ''PHO_RELATED_ORDER_AUDIT'';

exec [operational].[sproc_facacq_post_ifCopyOrders_01_OrderAudit]
@source_db = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058''
,@source_fac_id = ''32''
,@destination_fac_id = ''30''
,@NSCaseNumber = ''EICase590132''

exec [operational].[sproc_facacq_post_ifCopyOrders_02_AdminOrderAudit]
@source_db = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058''
,@source_fac_id = ''32''
,@destination_fac_id = ''30''
,@NSCaseNumber = ''EICase590132''

exec [operational].[sproc_facacq_post_ifCopyOrders_03_RelatedOrderAudit]
@source_db = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058''
,@source_fac_id = ''32''
,@destination_fac_id = ''30''
,@NSCaseNumber = ''EICase590132''

exec [operational].[sproc_facacq_post_ifCopyRiskManagement]
@source_db = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058''
,@NSCaseNumber = ''EICase590132''

exec [operational].[sproc_facacq_post_ifCopyUDAandRiskManagement]
@destination_fac_id = ''30''
,@NSCaseNumber = ''EICase590132''

exec [operational].[sproc_facacq_post_ifOnlineDocumentation_Location_Update]
@source_org_code = ''zion''
,@destination_org_code = ''srz''
,@source_fac_id = ''32''
,@destination_fac_id = ''30''
,@NSCaseNumber = ''EICase590132''

exec [operational].[sproc_facacq_post_ifCopyLabs]
@source_db = ''[pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1058''
,@destination_fac_id = ''30''
,@NSCaseNumber = ''EICase590132''

DELETE FROM dbo.facility_scheduling_cycle;
INSERT INTO dbo.facility_scheduling_cycle(fac_id, run_day)
SELECT fac_id, (CASE WHEN fac_id % 20 <> 0 THEN fac_id % 20 ELSE 20 END) + 6 AS runDay 
FROM dbo.facility WHERE ((FACILITY.fac_id  <> 9999 AND (FACILITY.inactive IS NULL OR FACILITY.inactive  <> ''Y'') AND (FACILITY.is_live <> ''N'' OR FACILITY.is_live IS NULL ))) 
AND ((FACILITY.DELETED = ''N''))

', 
		@database_name=N'us_srz_multi', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase590132 Fac 30 : POST    Custom on Destination ******]    Script Date: 1/13/2022 7:45:13 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase590132 Fac 30 : POST    Custom on Destination ******', 
		@step_id=24, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=28, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SELECT 1', 
		@database_name=N'us_srz_multi', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EICase590132 Fac 30 : Email Notification Data Copy Completed]    Script Date: 1/13/2022 7:45:13 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EICase590132 Fac 30 : Email Notification Data Copy Completed', 
		@step_id=25, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=28, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE MASTER
EXEC msdb.dbo.sp_send_dbmail @recipients =''dinesh.gunalapan@pointclickcare.com;TechServicesCustomerMaintenance@pointclickcare.com'',
@subject=''Scheduled Data Copy January 10, PMO - 59013'',
@body=''Hi All,</br></br> Following facility is now online in SRZ :</br></br>Zion Healthcare
</br>Blanco Villa Nursing and Rehabilitation</br></br></br></br></br>Thanks,</br>Facility Acquisition Team'',
@body_format=''HTML''

EXEC msdb.dbo.sp_send_dbmail @recipients =''Ashlee.Moss@pointclickcare.com;Suzette.Edgar@pointclickcare.com;Keith.Tomaszewski@pointclickcare.com;Adrian.Rizos@pointclickcare.com;TSFacAcqConfig@pointclickcare.com;melodee.mercado@pointclickcare.com;Laurie.Watkins@pointclickcare.com;jstroder@daashc.com;lalaran@daashc.com;'',
@subject=''PMO - 59013, Data Copy of ZION to SRZ : Friendly reminder'',
@body=''Hi All,</br></br> Following facility is now online in SRZ :</br></br>Zion Healthcare
</br>Blanco Villa Nursing and Rehabilitation</br></br></br></br></br>Thanks,</br>Facility Acquisition Team</br></br>NOTE: If there’s any post data copy issue please reply all to this email.'',
@body_format=''HTML''', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update ds_merge_master.dbo.LoadEIMaster_PMO_Groups]    Script Date: 1/13/2022 7:45:13 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update ds_merge_master.dbo.LoadEIMaster_PMO_Groups', 
		@step_id=26, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=28, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE us_srz_multi
IF (SELECT COUNT(1) FROM [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.[LoadEIMaster_Automation] 
										 WHERE Completed = 0 AND PMO_Group_Id = 1763) = 0
UPDATE [vmuspassvtsjob1.pccprod.local].ds_merge_master.[dbo].[LoadEIMaster_PMO_Groups] SET Completed = 1 
										  WHERE PMO_Group_Id = 1763', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Copy Mergelog to Destination DB]    Script Date: 1/13/2022 7:45:13 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Copy Mergelog to Destination DB', 
		@step_id=27, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=28, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE us_srz_multi
EXEC [operational].[sproc_facacq_createInsertMergelogStagingToDestination] 
@StagingDB=''pcc_staging_db59013'';

exec sp_updatestats;
', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [TS Job Failure Email Notification]    Script Date: 1/13/2022 7:45:13 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'TS Job Failure Email Notification', 
		@step_id=28, 
		@cmdexec_success_code=0, 
		@on_success_action=2, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE us_srz_multi
EXEC [operational].[sproc_facacq_sendEmailNotification] @Recipient = ''ts3@pccs.pagerduty.com''
					,@BlindCopyRecipients = ''TSFacAcqConfig@pointclickcare.com''
					,@JobName = ''EI_Prepare_Destination__59013 ''
					,@ServerName = ''[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net]''', 
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


