USE us_elcc_multi
IF EXISTS (
		SELECT 1
		FROM sys.procedures
		WHERE NAME = 'sproc_EI_PrepareStagingToDestination'
		)
BEGIN
	DROP PROCEDURE dbo.sproc_EI_PrepareStagingToDestination
END
GO

--CREATE PROCEDURE sproc_EI_PrepareSourceToStaging
--	@P_pmoNumber VARCHAR(100),
--	@P_ConversionServer VARCHAR(125) NOT NULL,
--	@P_SourceDBName VARCHAR(125),
--	@P_DestDBName VARCHAR(125),
--	@P_StageDBName VARCHAR(125),
--  @P_DstCmdTSqlFilePath VARCHAR(MAX),
--	@P_ProdRun VARCHAR(1),
--	@P_ContinueMerge CHAR(1),
--	@P_ExecLogFilePath VARCHAR(MAX), -- Path must have \ at last
--	@P_PagerDutyOperator VARCHAR(50) -- Value must be from FacAcqPagerTS1 ..To.. FacAcqPagerTS8
/*
--  @P_TemplateBAKFilePath VARCHAR(MAX),
--	@P_DBFilePath VARCHAR(MAX),



--	@P_DsMergeMast VARCHAR(125) --Must be [Server\Instance].DS_MERGE_MASTER or DS_MERGE_MASTER or Any DB which has all tables from DS_MERGE_MASTER
*/
--AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		DECLARE @vPMONumber VARCHAR(125)
			,@vJobName VARCHAR(125)
			,@vJobDesc VARCHAR(250)
			,@vSourceDBName VARCHAR(125)
			,@vDestDBName VARCHAR(125)
			,@vStageDBName VARCHAR(125)
			,@vTSConversionServer VARCHAR(125)
			,@vWesServer VARCHAR(125)
			,@CmdCommand VARCHAR(MAX)
			,@SqlCommand NVARCHAR(MAX)
			,@SqlInsert VARCHAR(MAX)
			,@ServerName VARCHAR(200)
			,@v_DstCmdTSqlFilePath VARCHAR(MAX)
			,@vProdRun VARCHAR(1)
			,@vContinueMerge CHAR(1)
			,@vSrcOrgCode VARCHAR(100)
			,@vDstOrgCode VARCHAR(100)
			,@vTestSrcOrgCode VARCHAR(100)
			,@vTestDstOrgCode VARCHAR(100)
			,@vSrcFacID INT
			,@vDstFacID INT
			,@vSrcFacName VARCHAR(500)
			,@vDstFacName VARCHAR(500)
			,@vSrcEOM CHAR(1)
			,@vDstEOM CHAR(1)
			,@vRunID INT
			,@vPMOGroupId INT
			,@EmailRecipientsInt VARCHAR(MAX)
			,@EmailRecipientsExt VARCHAR(MAX)
			,@EmailSubject VARCHAR(1000)
			,@EmailBody VARCHAR(MAX)
			,@vFacAcqEmailAddress VARCHAR(max) = N'TSFacAcqConfig@pointclickcare.com'
			,@Recipient VARCHAR(150)
			,@vModList VARCHAR(MAX)
			,@vCaseNo VARCHAR(1000)
			,@vStepName VARCHAR(1000)
			,@vLastStepId INT
			,@vCSVSrcFacID VARCHAR(MAX)
			,@vCSVDstFacID VARCHAR(MAX)
			,@vDstFacList VARCHAR(MAX)
			,@vDoneDstFacList VARCHAR(MAX)
			,@vNotDoneDstFacList VARCHAR(MAX)
			,@vPagerDutyOperator VARCHAR(50)
			,@vPagerDutyEmail VARCHAR(100)
			,@vStagingDBBackupForProdPath VARCHAR(500)
			,@vStagingDBBackupForProdPathWithFile VARCHAR(1000)
			,@TS_Resource VARCHAR(50)
			,@vCurrentRunId VARCHAR(100)
			,@vIntEmailSubject VARCHAR(2000)
			,@vExtEmailSubject VARCHAR(2000);
		DECLARE @LoadEIMaster TABLE (
			[RunID] [int] NOT NULL
			,[PMO_Group_Id] [int] NOT NULL
			,[CaseNo] [varchar](1000) NULL
			,[SrcFacID] [int] NULL
			,[DstFacID] [int] NULL
			,[SrcOrgCode] [varchar](1000) NULL
			,[StgOrgCode] [varchar](1000) NULL
			,[DstOrgCode] [varchar](1000) NULL
			,[ModList] [varchar](1000) NULL
			,[FacilityRunOrder] [int] NOT NULL
			,[PreMergeScript] [varchar](max) NULL
			,[PreMergeScriptSrc] [varchar](max) NULL
			,[PostMergeScript] [varchar](max) NULL
			,[PostMergeScriptDst] [varchar](max) NULL
			,[ContMerge] [bit] NULL
			,[SrcEOM] VARCHAR(50) NULL
			)
		DECLARE @outVal TABLE (outVal VARCHAR(1000))
		DECLARE @DstFacList TABLE (
			FacId INT
			,FacName VARCHAR(500)
			,IsDone CHAR(1)
			)

		--SET @vPMONumber=@P_pmoNumber
		--SET @vSourceDBName=@P_SourceDBName
		--SET @vDestDBName=@P_DestDBName
		--SET @vStageDBName=@P_StageDBName
		--SET @vTSConversionServer=@P_ConversionServer
		--SET @v_DstCmdTSqlFilePath=@P_DstCmdTSqlFilePath
		--SET @vProdRun=@P_ProdRun
		--SET @vContinueMerge=@P_ContinueMerge
		--SET @vExecLogFilePath=@P_ExecLogFilePath
		--SET @vPagerDutyOperator=@P_PagerDutyOperator


		/*------PMO Number, should be unique------*/
		SET @vPMOGroupID = 1807


		/*------Internal Email Notification Recipient------*/
		SET @EmailrecipientsInt = 'dinesh.gunalapan@pointclickcare.com;TSFacAcqConfig@pointclickcare.com'
		/*------Internal Email Notification Subject, will use default if left empty------*/
		SET @vIntEmailSubject = ''


		/*------External Email Notification Recipient------*/
		SET @EmailrecipientsExt = 'linda.k@pointclickcare.com;Kylie@exceptionallivingcenters.com;Carolyn@exceptionallivingcenters.com;Apryl@exceptionallivingcenters.com;Shelley@exceptionallivingcenters.com;Crystal@exceptionallivingcenters.com;Rod@exceptionallivingcenters.com;stephani.kish@pointclickcare.com;Raju.Sivapalan@pointclickcare.com;Melissa.Hughes@pointclickcare.com;rina.p@pointclickcare.com;nigel.liang@pointclickcare.com;theresa.w@pointclickcare.com;TSFacAcqConfig@pointclickcare.com'
		/*------External Email Notification Subject, will use default if left empty------*/
		SET @vExtEmailSubject = ''


		/*------Production Run------*/
		SET @vProdRun = 'Y'

		/*------PagerDutyOperator On Call - Value must be from FacAcqPagerTS1 ..To.. FacAcqPagerTS8------*/
		IF @vProdRun = 'Y'
		BEGIN
			SET @vPagerDutyOperator = 'FacAcqPagerTS3'
			SET @vPagerDutyEmail = lower(right(@vPagerDutyOperator, 3)) + '@pccs.pagerduty.com'
		END
		ELSE
		BEGIN
			SET @vPagerDutyOperator = ''
			SET @vPagerDutyEmail = ''
		END

		-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
		/*------No need to change the following parameters------*/
		/*------If Continue Merge when there's error in staging to destination, always default to 0------*/
		SET @vContinueMerge = '0'
		SET @vStagingDBBackupForProdPath = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups'
		SET @vStagingDBBackupForProdPathWithFile = @vStagingDBBackupForProdPath + '/PMOGroup' + LTRIM(rtrim(str(@vPMOGroupID))) + '/Final'
		IF @vProdRun = 'Y'
				BEGIN SET @vStagingDBBackupForProdPathWithFile = @vStagingDBBackupForProdPathWithFile + '_GoLive' END

		/*------No need to change the following parameters------*/
		SET @ServerName = @@SERVERNAME
		SET @vTSConversionServer = 'vmuspassvtsjob1.pccprod.local'
		SET @TS_Resource = replace(replace(replace(ORIGINAL_LOGIN(),'@pointclickcare.com',''),'PCCPROD\',''),'@pointclickcarecloud.com','')
		SET @SqlCommand = N'SELECT top 1 @vSourceDBName = ''['' + servername + ''].'' + databasename
		FROM [' + @vTSConversionServer + '].[ds_tasks].dbo.TS_global_organization_master WITH(NOLOCK)' + CHAR(13) + CHAR(10) + 'WHERE orgcode IN (SELECT TOP 1 srcorgcode FROM [' + @vTSConversionServer + '].ds_merge_master.dbo.LoadEIMaster_Automation WITH (NOLOCK) 
		WHERE pmo_group_id = ''' + CONVERT(VARCHAR, @vPMOGroupID) + ''')
		AND deleted = ''N'''

		----print @SqlCommand
		EXEC sp_executesql @SqlCommand
			,N'@vSourceDBName varchar(500) OUTPUT'
			,@vSourceDBName OUTPUT

		SET @SqlCommand = N'SELECT TOP 1 
		@vDestDBName = databasename FROM [' + @vTSConversionServer + '].[ds_tasks].dbo.TS_global_organization_master WITH(NOLOCK)' + CHAR(13) + CHAR(10) + 'WHERE orgcode IN (SELECT TOP 1 dstorgcode FROM [' + @vTSConversionServer + '].ds_merge_master.dbo.LoadEIMaster_Automation WITH (NOLOCK) 
		WHERE pmo_group_id = ''' + CONVERT(VARCHAR, @vPMOGroupID) + ''')
		AND deleted = ''N'''

		EXEC sp_executesql @SqlCommand
			,N'@vDestDBName varchar(500) OUTPUT'
			,@vDestDBName OUTPUT

		SET @SqlCommand = N'SELECT top 1 @vPMONumber = PMONumber ' + ' from [' + @vTSConversionServer + '].[ds_merge_master].[dbo].[LoadEIMaster_PMO_Groups] EIPMO with (nolock) WHERE EIPMO.PMO_Group_Id=''' + CONVERT(VARCHAR, @vPMOGroupID) + ''''

		EXEC sp_executesql @SqlCommand
			,N'@vPMONumber varchar(500) OUTPUT'
			,@vPMONumber OUTPUT

		SET @SqlCommand = N'SELECT top 1 @vStageDBName = STgOrgCode ' + ' from [' + @vTSConversionServer + '].[ds_merge_master].[dbo].[LoadEIMaster_Automation] EIMF with (nolock) WHERE EIMF.PMO_Group_Id=''' + CONVERT(VARCHAR, @vPMOGroupID) + ''''

		EXEC sp_executesql @SqlCommand
			,N'@vStageDBName varchar(500) OUTPUT'
			,@vStageDBName OUTPUT

		SET @vJobDesc = 'Job to excute ETL Staging to Destination for EI PMO: ' + CONVERT(VARCHAR, @vPMONumber)

		PRINT '********************************************'
		PRINT 'Step 0: Get LoadEIMaster & EIHistory Details'
		PRINT '********************************************'

		SET @SqlCommand = NULL
		SET @SqlCommand = 'SELECT EIMF.RunID,
						EIMF.PMO_Group_Id,EIMF.CaseNo,EIMF.SrcFacID,EIMF.DstFacID,EIMF.SrcOrgCode,EIMF.StgOrgCode,EIMF.DstOrgCode
						,EIMF.MODLIST,EIMF.FacilityRunOrder,EIMF.premergescript,EIMF.premergescriptsrc,EIMF.PostMergeScript
						,EIMF.PostMergeScriptDst
						,EIMF.ContMerge, 
						(SELECT VALUE FROM ' + @vSourceDBName + '.dbo.configuration_parameter  with (nolock)
						WHERE fac_id=EIMF.SrcFacID AND NAME = ''pho_is_using_new_phys_order_form'') SrcEOM
						FROM [' + @vTSConversionServer + '].[ds_merge_master].DBO.LoadEIMaster_Automation EIMF with (nolock)
						WHERE EIMF.PMO_Group_Id=(SELECT TOP 1 EIPMO.PMO_Group_Id
						FROM [' + @vTSConversionServer + '].[ds_merge_master].DBO.LoadEIMaster_PMO_Groups EIPMO with (nolock) WHERE EIPMO.PMO_Group_Id=''' + CONVERT(VARCHAR, @vPMOGroupID) + ''')'

		--PRINT @SqlCommand
		INSERT @LoadEIMaster
		EXEC (@SqlCommand)

		SET @vModList = (
				SELECT TOP 1 ModList
				FROM @LoadEIMaster
				ORDER BY FacilityRunOrder ASC				-- changed by Amardeep from DESC to ASC on Jan 31 2022
				)
		SET @vPMOGroupId = (
				SELECT TOP 1 PMO_Group_Id
				FROM @LoadEIMaster
				ORDER BY FacilityRunOrder DESC
				)
		SET @vCaseNo = (
				SELECT TOP 1 CaseNo
				FROM @LoadEIMaster
				ORDER BY FacilityRunOrder DESC
				)

		--Get Source Org Code
		SELECT @vCSVSrcFacID = COALESCE(@vCSVSrcFacID + ',', '') + CONVERT(VARCHAR, SrcFacID)
		FROM @LoadEIMaster

		SELECT @vCSVDstFacID = COALESCE(@vCSVDstFacID + ',', '') + CONVERT(VARCHAR, DstFacID)
		FROM @LoadEIMaster

		--Get DSTFacList
		SET @SqlCommand = 'SELECT Fac_Id, NAME, ''N'' FROM ' + @vDestDBName + '.dbo.facility WHERE fac_id IN (' + @vCSVDstFacID + ')'

		INSERT @DstFacList
		EXEC (@SqlCommand)

		SELECT @vDstFacList = COALESCE(@vDstFacList + CHAR(13) + CHAR(10) + '</br>', '') + FacName
		FROM @DstFacList
		WHERE IsDone = 'N'

		SET @SqlCommand = 'SELECT TOP 1 OrgCode' + CHAR(13) + CHAR(10) + 'FROM [' + @vTSConversionServer + '].[ds_tasks].dbo.TS_global_organization_master WITH (NOLOCK)' + CHAR(13) + CHAR(10) + 'WHERE DELETED = ''N''' + CHAR(13) + CHAR(10) + 'AND OrgId =(SELECT TOP 1 ORG_ID ' + CHAR(13) + CHAR(10) + 'FROM ' + @vSourceDBName + '.dbo.facility WHERE fac_id IN (' + @vCSVSrcFacID + '))'

		INSERT @outVal
		EXEC (@SqlCommand)

		SET @vSrcOrgCode = ISNULL((
					SELECT TOP 1 outVal
					FROM @outVal
					), '')

		DELETE
		FROM @outVal

		--Get Dst Org Code
		SET @SqlCommand = 'SELECT TOP 1 OrgCode' + CHAR(13) + CHAR(10) + 'FROM [' + @vTSConversionServer + '].[ds_tasks].dbo.TS_global_organization_master WITH (NOLOCK)' + CHAR(13) + CHAR(10) + 'WHERE DELETED = ''N''' + + CHAR(13) + CHAR(10) + 'AND OrgId =(SELECT TOP 1 ORG_ID ' + CHAR(13) + CHAR(10) + 'FROM ' + @vDestDBName + '.dbo.facility WHERE fac_id IN (' + @vCSVDstFacID + '))'

		INSERT @outVal
		EXEC (@SqlCommand)

		----PRINT @sqlCommand
		SET @vDstOrgCode = ISNULL((
					SELECT TOP 1 outVal
					FROM @outVal
					), '')

		----PRINT @vDstOrgCode
		DELETE
		FROM @outVal

		PRINT '******************'
		PRINT 'Step 0: Create Job'
		PRINT '******************'

		SET @vJobName = 'EI_Prepare_Destination__' + CONVERT(VARCHAR, @vPMONumber)

		IF EXISTS (
				SELECT job_id
				FROM msdb.dbo.sysjobs_view
				WHERE name = @vJobName
				)
			EXEC msdb.dbo.sp_delete_job @job_name = @vJobName

		--Create Job to Prepare Staging DB Repo
		DECLARE @ReturnCode INT

		SELECT @ReturnCode = 0

		DECLARE @jobId BINARY (16)

		EXEC @ReturnCode = msdb.dbo.sp_add_job @job_name = @vJobName
			,@enabled = 1
			,@owner_login_name = 'sa'
			,@notify_level_eventlog = 2
			,@notify_level_email = 3
			,@notify_level_netsend = 0
			,@notify_level_page = 0
			,@delete_level = 0
			,--0 for Never Delete, 1 for Delete after successful run
			@description = @vJobDesc
			,@job_id = @jobId OUTPUT

		EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId
			,@start_step_id = 1

		EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId
			,@server_name = N'(local)'

		DECLARE @backupTable AS TABLE (BackupFileName VARCHAR(1000))
		DECLARE @vRestoreTSQL NVARCHAR(max)
		DECLARE @List VARCHAR(8000)

		SET @vRestoreTSQL = 'IF EXISTS(SELECT 1 ' + CHAR(13) + CHAR(10) + 'FROM [' + @vTSConversionServer + '].[ds_merge_master].[dbo].[LoadEIMaster_BackupFileNames]' + CHAR(13) + CHAR(10) + 'WHERE PMOGroupId = ''' + ltrim(rtrim(str(@vPMOGroupId))) + '''' + CHAR(13) + CHAR(10) + 'AND CaseNumber = ''' + @vCaseNo + ''')' + CHAR(13) + CHAR(10) + 
		'BEGIN' + CHAR(13) + CHAR(10) + 
		'SELECT ''' + @vStagingDBBackupForProdPathWithFile + '/'' + ' + 'BackupFileName
		FROM (
			SELECT dense_rank() OVER (
					PARTITION BY PMOGroupId
					,CaseNumber ORDER BY CreatedDate DESC
					) Id
				,*
			FROM [' + @vTSConversionServer + '].[ds_merge_master].[dbo].[LoadEIMaster_BackupFileNames]
			WHERE PMOGroupId = ''' + ltrim(rtrim(str(@vPMOGroupId))) + '''
				AND CaseNumber = ''' + @vCaseNo + '''
			) X
		WHERE id = 1' + CHAR(13) + CHAR(10) + '
		END
		'

		----PRINT  ltrim(rtrim(str(@vPMOGroupId)))
		----PRINT @vCaseNo
		----PRINT @vRestoreTSQL
		INSERT INTO @backupTable
		EXEC sp_executesql @vRestoreTSQL

		SELECT @List = COALESCE(@List + ', URL = ''', '') + BackupFileName + ''''
		FROM @backupTable

--		SET @List = 'RESTORE DATABASE ' + @vStageDBName + ' FROM URL = ''' + @vStagingDBBackupForProdPath + '/' + @List
		SET @List = 'RESTORE DATABASE ' + @vStageDBName + ' FROM URL = ''' + @List

		----PRINT @List
		PRINT '********************************************************'
		PRINT 'Restore Staging DB on Destination Server ' + @vStageDBName
		PRINT '********************************************************'

		SET @SqlCommand = 'USE MASTER' + CHAR(13) + CHAR(10) + @List

		----PRINT @SqlCommand
		EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
			,@step_name = N'Restore Staging DB on Destination Server'
			,@cmdexec_success_code = 0
			,@on_success_action = 3
			,--3 FOR NEXT STEP, 1 FOR QUIT SUCCESS, 2 QUIT WITH FAILURE
			@on_fail_action = 2
			,@retry_attempts = 0
			,@retry_interval = 0
			,@os_run_priority = 0
			,@subsystem = N'TSQL'
			,@command = @SqlCommand
			,@database_name = N'master'
			,@flags = 8

		PRINT '*************************************************************************'
		PRINT 'Step 1 : FK Validation Checking All FK values from Staging to Destination'
		PRINT '*************************************************************************'

		SET @SqlCommand = 'EXEC [operational].[sproc_facacq_FKValidation] @staging_db=''' + @vStageDBName + ''', @destination_db=''' + @vDestDBName + ''''
		SET @SqlCommand = 'USE ' + @vStageDBName + CHAR(13) + CHAR(10) + @SqlCommand

		EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
			,@step_name = N'FK Validation Checking All FK values from Staging to Destination'
			,@cmdexec_success_code = 0
			,@on_success_action = 3
			,--3 FOR NEXT STEP, 1 FOR QUIT SUCCESS, 2 QUIT WITH FAILURE
			@on_fail_action = 2
			,@retry_attempts = 0
			,@retry_interval = 0
			,@os_run_priority = 0
			,@subsystem = N'TSQL'
			,@command = @SqlCommand
			,@database_name = N'master'
			,@flags = 8

		PRINT '*****************************************'
		PRINT 'Step 2 : Send Email & Wait for 15 Minutes'
		PRINT '*****************************************'

		--Internal Email
		IF LEN(@vIntEmailSubject) > 1
			BEGIN SET @EmailSubject = @vIntEmailSubject END
			ELSE 
			BEGIN SET @EmailSubject = 'Scheduled Data Copy ' + CONVERT(VARCHAR, DATENAME(month, GETDATE())) + ' ' + CONVERT(VARCHAR, DATENAME(DAY, GETDATE())) + ', PMO - ' + CONVERT(VARCHAR, @vPMONumber) END
		SET @EmailBody = 'Hi All,</br></br> Org ' + UPPER(@vDstOrgCode) + ' will be offline in 15 minutes.</br></br></br> Thanks,</br> Facility Acquisition Team'
		SET @SqlCommand = NULL
		SET @SqlCommand = 'EXEC msdb.dbo.sp_send_dbmail @recipients =''' + @EmailRecipientsInt + ''',' + CHAR(13) + CHAR(10) + '@subject=''' + @EmailSubject + ''',' + CHAR(13) + CHAR(10) + '@body=''' + @EmailBody + ''',' + CHAR(13) + CHAR(10) + '@body_format=''HTML'''
		
		--External Email
		IF LEN(@vExtEmailSubject) > 1
			BEGIN SET @EmailSubject = @vExtEmailSubject END
			ELSE 
			BEGIN SET @EmailSubject = 'PMO - ' + CONVERT(VARCHAR, @vPMONumber) + ', ' + 'Data Copy of ' + UPPER(@vSrcOrgCode) + ' to ' + UPPER(@vDstOrgCode) + ' : Friendly reminder' END 
		SET @SqlCommand = @SqlCommand + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + 'EXEC msdb.dbo.sp_send_dbmail @recipients =''' + @EmailRecipientsExt + ''',' + CHAR(13) + CHAR(10) + '@subject=''' + @EmailSubject + ''',' + CHAR(13) + CHAR(10) + '@body=''' + @EmailBody + ''',' + CHAR(13) + CHAR(10) + '@body_format=''HTML'''
		SET @SqlCommand = @SqlCommand + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + 'WAITFOR DELAY ''00:15:00'''
		SET @SqlCommand = 'USE MASTER' + CHAR(13) + CHAR(10) + @SqlCommand

		--PRINT @SqlCommand
		EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
			,@step_name = N'Send Email & Wait for 15 Minutes'
			,@cmdexec_success_code = 0
			,@on_success_action = 3
			,--3 FOR NEXT STEP, 1 FOR QUIT SUCCESS, 2 QUIT WITH FAILURE
			@on_fail_action = 2
			,@retry_attempts = 0
			,@retry_interval = 0
			,@os_run_priority = 0
			,@subsystem = N'TSQL'
			,@command = @SqlCommand
			,@database_name = N'master'
			,@flags = 8

		PRINT '******************************************'
		PRINT 'Step 3: Alter Login Destination DB Disable'
		PRINT '******************************************'

		SET @SqlCommand = NULL

		IF @vProdRun = 'Y'
		BEGIN
			SET @SqlCommand = 'ALTER LOGIN ' + @vDestDBName + ' DISABLE'
		END
		ELSE
		BEGIN
			SET @SqlCommand = 'IF EXISTS(SELECT 1 FROM sys.database_principals WHERE NAME = ''test_merge'')' + CHAR(13) + CHAR(10) + 'REVOKE CONNECT FROM test_merge' + CHAR(13) + CHAR(10) + 'IF EXISTS(SELECT 1 FROM sys.database_principals WHERE NAME = ''ushd'')' + CHAR(13) + CHAR(10) + 'REVOKE CONNECT FROM ushd'
		END

		----SET @SqlCommand = @SqlCommand + CHAR(13) + CHAR(10) + 'ALTER DATABASE ' + @vDestDBName + ' SET single_user WITH ROLLBACK immediate' + CHAR(13) + CHAR(10) + 'ALTER DATABASE ' + @vDestDBName + ' SET multi_user WITH ROLLBACK immediate'
		--PRINT @SqlCommand
		EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
			,@step_name = N'Alter Login Destination DB Disable'
			,@cmdexec_success_code = 0
			,@on_success_action = 3
			,--3 FOR NEXT STEP, 1 FOR QUIT SUCCESS, 2 QUIT WITH FAILURE
			@on_fail_action = 2
			,@retry_attempts = 0
			,@retry_interval = 0
			,@os_run_priority = 0
			,@subsystem = N'TSQL'
			,@command = @SqlCommand
			,@database_name = N'master'
			,@flags = 8

		PRINT '*********************************************'
		PRINT 'Step 4: Drop Staging Tables'
		PRINT '*********************************************'

		SET @SqlCommand = NULL
		SET @SqlCommand = ISNULL(@SqlCommand, '') + CHAR(13) + CHAR(10) + 'EXEC [operational].[sproc_facacq_dropStagingTables]' + CHAR(13) + CHAR(10)
		SET @SqlCommand = 'USE ' + @vDestDBName + CHAR(13) + CHAR(10) + @SqlCommand

		--PRINT @SqlCommand
		EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
			,@step_name = N'Drop Staging Tables'
			,@cmdexec_success_code = 0
			,@on_success_action = 3
			,--3 FOR NEXT STEP, 1 FOR QUIT SUCCESS, 2 QUIT WITH FAILURE
			@on_fail_action = 2
			,@retry_attempts = 0
			,@retry_interval = 0
			,@os_run_priority = 0
			,@subsystem = N'TSQL'
			,@command = @SqlCommand
			,@database_name = N'master'
			,@flags = 8

		--PRINT '*********************************************'
		--PRINT 'Step 5: CREATE/INSERT mergelog table from Staging To Destination'
		--PRINT '*********************************************'

		--SET @SqlCommand = NULL
		--SET @SqlCommand = ISNULL(@SqlCommand, '') + CHAR(13) + CHAR(10) + 'EXEC [operational].[sproc_facacq_createInsertMergelogStagingToDestination]  @StagingDB= ''' + @vStageDBName + '''' + CHAR(13) + CHAR(10)
		--SET @SqlCommand = 'USE ' + @vDestDBName + CHAR(13) + CHAR(10) + @SqlCommand

		----PRINT @SqlCommand
		--EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
		--	,@step_name = N'CREATE/INSERT mergelog table from Staging To Destination'
		--	,@cmdexec_success_code = 0
		--	,@on_success_action = 3
		--	,--3 FOR NEXT STEP, 1 FOR QUIT SUCCESS, 2 QUIT WITH FAILURE
		--	@on_fail_action = 2
		--	,@retry_attempts = 0
		--	,@retry_interval = 0
		--	,@os_run_priority = 0
		--	,@subsystem = N'TSQL'
		--	,@command = @SqlCommand
		--	,@database_name = N'master'
		--	,@flags = 8

		PRINT '*********************************************'
		PRINT 'Step 5: Create table ListOfDeferTables'
		PRINT '*********************************************'

		SET @SqlCommand = NULL
		SET @SqlCommand = ISNULL(@SqlCommand, '') + CHAR(13) + CHAR(10) + 'EXEC [operational].[sproc_facacq_createListOfDeferTables]' + CHAR(13) + CHAR(10) + 'EXEC [operational].[sproc_facacq_populateListOfDeferTables] @conv_server= ''' + @vTSConversionServer + ''''
		SET @SqlCommand = 'USE ' + @vDestDBName + CHAR(13) + CHAR(10) + @SqlCommand

		--PRINT @SqlCommand
		EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
			,@step_name = N'Create/Populate table ListOfDeferTables'
			,@cmdexec_success_code = 0
			,@on_success_action = 3
			,--3 FOR NEXT STEP, 1 FOR QUIT SUCCESS, 2 QUIT WITH FAILURE
			@on_fail_action = 2
			,@retry_attempts = 0
			,@retry_interval = 0
			,@os_run_priority = 0
			,@subsystem = N'TSQL'
			,@command = @SqlCommand
			,@database_name = N'master'
			,@flags = 8

		PRINT '***********************************'
		PRINT 'Step 6: Staging to Destination Offline Insert'
		PRINT '***********************************'

		SET @SqlCommand = NULL

		SELECT @SqlCommand = ISNULL(@SqlCommand, '') + CHAR(13) + CHAR(10) + 'IF @ReturnVal = 0' + CHAR(13) + CHAR(10) + 'BEGIN' + CHAR(13) + CHAR(10) + CHAR(9) + 'SET QUOTED_IDENTIFIER ON' + CHAR(13) + CHAR(10) + CHAR(9) + 'EXEC @ReturnVal=[operational].[sproc_facacq_insertStagingToDestinationOffline] ' + CHAR(13) + CHAR(10) + CHAR(9) + '@conv_server=''' + @vTSConversionServer + ''',@StagingDB=''' + @vStageDBName + ''',@DestinationDB=''' + @vDestDBName + ''',@ModuleToCopy=''' + ML.items + ''',' + CHAR(13) + CHAR(10) + CHAR(9) + '@TranFlag=NULL,@prefix=NULL,@pmo=''' + CONVERT(VARCHAR, @vPMONumber) + ''',@resource=''' + @TS_Resource + ''',' + CHAR(13) + CHAR(10) + CHAR(9) + '@RunIDFlag=' + CASE 
				WHEN ML.ITEMS IN (
						'E14'
						,'E1'
						,'E15'
						)
					AND RN = 1
					THEN '1'
				ELSE '2'
				END + ',' + '@ContinueMerge=''' + @vContinueMerge + ''',@ReturnVal=0,@flgOffLine=0,@MultiFacId=NULL' + CHAR(13) + CHAR(10) + 'END' + CHAR(13) + CHAR(10) + 'ELSE' + CHAR(13) + CHAR(10) + 'BEGIN' + CHAR(13) + CHAR(10) + CHAR(9) + ';THROW 51000,''ERROR: OffLine Insert:- ' + ML.items + ''', 1' + CHAR(13) + CHAR(10) + 'END'
		--ML.ITEMS
		--ML.ITEMS Module
		FROM (
			SELECT ROW_NUMBER() OVER (
					ORDER BY (
							SELECT 100
							)
					) RN
				,ITEMS
			FROM Split(@vModList, ',')
			) ML

		SET @SqlCommand = 'USE ' + @vDestDBName + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + 'DECLARE @ReturnVal INT' + CHAR(13) + CHAR(10) + 'SET @ReturnVal = 0' + CHAR(13) + CHAR(10) + @SqlCommand

		--PRINT @SqlCommand
		EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
			,@step_name = N'Staging to Destination OFFLINE INSERT'
			,@cmdexec_success_code = 0
			,@on_success_action = 3
			,--3 FOR NEXT STEP, 1 FOR QUIT SUCCESS, 2 QUIT WITH FAILURE
			@on_fail_action = 2
			,@retry_attempts = 0
			,@retry_interval = 0
			,@os_run_priority = 0
			,@subsystem = N'TSQL'
			,@command = @SqlCommand
			,@database_name = N'master'
			,@flags = 8

		PRINT '*****************************************'
		PRINT 'Step 7: Alter Login Destination DB Enable'
		PRINT '*****************************************'

		SET @SqlCommand = NULL

		IF @vProdRun = 'Y'
		BEGIN
			SET @SqlCommand = 'ALTER LOGIN ' + @vDestDBName + ' ENABLE'
		END
		ELSE
		BEGIN
			SET @SqlCommand = 'IF EXISTS(SELECT 1 FROM sys.database_principals WHERE NAME = ''test_merge'')' + CHAR(13) + CHAR(10) + 'GRANT CONNECT TO test_merge' + CHAR(13) + CHAR(10) + 'IF EXISTS(SELECT 1 FROM sys.database_principals WHERE NAME = ''ushd'')' + CHAR(13) + CHAR(10) + 'GRANT CONNECT TO ushd'
		END

		--PRINT @SqlCommand
		EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
			,@step_name = N'Alter Login Destination DB Enable'
			,@cmdexec_success_code = 0
			,@on_success_action = 3
			,--3 FOR NEXT STEP, 1 FOR QUIT SUCCESS, 2 QUIT WITH FAILURE
			@on_fail_action = 2
			,@retry_attempts = 0
			,@retry_interval = 0
			,@os_run_priority = 0
			,@subsystem = N'TSQL'
			,@command = @SqlCommand
			,@database_name = N'master'
			,@flags = 8

		PRINT '************************************'
		PRINT 'Step 8: Email Notification DB Online'
		PRINT '************************************'

		--Internal Email
		IF LEN(@vIntEmailSubject) > 1
			BEGIN SET @EmailSubject = @vIntEmailSubject END
			ELSE 
			BEGIN SET @EmailSubject = 'Scheduled Data Copy ' + CONVERT(VARCHAR, DATENAME(month, GETDATE())) + ' ' + CONVERT(VARCHAR, DATENAME(DAY, GETDATE())) + ', PMO - ' + CONVERT(VARCHAR, @vPMONumber) END
		SET @EmailBody = 'Hi All,</br></br> Org ' + UPPER(@vDstOrgCode) + ' is now back online.</br></br>Following facilities are still offline:</br></br>' + @vDstFacList + '</br></br></br>' + 'Thanks,</br>Facility Acquisition Team'
		SET @SqlCommand = NULL
		SET @SqlCommand = 'EXEC msdb.dbo.sp_send_dbmail @recipients =''' + @EmailRecipientsInt + ''',' + CHAR(13) + CHAR(10) + '@subject=''' + @EmailSubject + ''',' + CHAR(13) + CHAR(10) + '@body=''' + @EmailBody + ''',' + CHAR(13) + CHAR(10) + '@body_format=''HTML'''
		--External Email
		IF LEN(@vExtEmailSubject) > 1
		BEGIN SET @EmailSubject = @vExtEmailSubject END
		ELSE 
		BEGIN SET @EmailSubject = 'PMO - ' + CONVERT(VARCHAR, @vPMONumber) + ', ' + 'Data Copy of ' + UPPER(@vSrcOrgCode) + ' to ' + UPPER(@vDstOrgCode) + ' : Friendly reminder' END 
		SET @SqlCommand = @SqlCommand + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + 'EXEC msdb.dbo.sp_send_dbmail @recipients =''' + @EmailRecipientsExt + ''',' + CHAR(13) + CHAR(10) + '@subject=''' + @EmailSubject + ''',' + CHAR(13) + CHAR(10) + '@body=''' + @EmailBody + ''',' + CHAR(13) + CHAR(10) + '@body_format=''HTML'''
		SET @SqlCommand = 'USE MASTER' + CHAR(13) + CHAR(10) + @SqlCommand

		EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
			,@step_name = 'Email Notification DB Online'
			,@cmdexec_success_code = 0
			,@on_success_action = 3
			,--3 FOR NEXT STEP, 1 FOR QUIT SUCCESS, 2 QUIT WITH FAILURE
			@on_fail_action = 2
			,@retry_attempts = 0
			,@retry_interval = 0
			,@os_run_priority = 0
			,@subsystem = N'TSQL'
			,@command = @SqlCommand
			,@database_name = N'master'
			,@flags = 8

		PRINT '**********************************'
		PRINT 'Step 9: StagingToDestination OnLine'
		PRINT '**********************************'

		DECLARE CurCase CURSOR
		FOR
		SELECT RunID
			,CaseNo
			,SrcOrgCode
			,DstOrgCode
			,SrcFacID
			,DstFacID
			,SrcEOM
		FROM @LoadEIMaster
		ORDER BY FacilityRunOrder ASC

		OPEN CurCase

		FETCH NEXT
		FROM CurCase
		INTO @vRunID
			,@vCaseNo
			,@vTestSrcOrgCode
			,@vTestDstOrgCode
			,@vSrcFacID
			,@vDstFacID
			,@vSrcEOM

		WHILE @@FETCH_STATUS = 0
		BEGIN --Start CurCase
			PRINT '*****************************************************************************************************'
			PRINT 'Case No: ' + @vCaseNo + ' : Execute [operational].[sproc_facacq_createInsertMappingTablesStagingToDestination] on Destination DB'
			PRINT '*****************************************************************************************************'

			SET @SqlCommand = NULL
			SET @vStepName = 'EICase' + @vCaseNo + ' Fac ' + convert(varchar,@vDstFacId) + ' : Copy Mapping Tables to Destination DB'
			SET @SqlCommand = 'EXEC [operational].[sproc_facacq_createInsertMappingTablesStagingToDestination] ' + CHAR(13) + CHAR(10) + '@StagingDB=''' + @vStageDBName + ''',@DestinationDB=''' + @vDestDBName + ''',' + CHAR(13) + CHAR(10) + '@prefix=''EICASE' + @vCaseNo + ''',@ReturnVal=NULL'
			SET @SqlCommand = 'USE ' + @vDestDBName + CHAR(13) + CHAR(10) + @SqlCommand

			--PRINT @SqlCommand
			EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
				,@step_name = @vStepName
				,@cmdexec_success_code = 0
				,@on_success_action = 3
				,--3 FOR NEXT STEP, 1 FOR QUIT SUCCESS, 2 QUIT WITH FAILURE
				@on_fail_action = 2
				,@retry_attempts = 0
				,@retry_interval = 0
				,@os_run_priority = 0
				,@subsystem = N'TSQL'
				,@command = @SqlCommand
				,@database_name = N'master'
				,@flags = 8

			PRINT '*************************************************************************************************'
			PRINT 'Case No: ' + @vCaseNo + ' : Execute [operational].[sproc_facacq_insertStagingToDestinationOnline] on Destination DB'
			PRINT '*************************************************************************************************'

			SET @SqlCommand = NULL
			SET @vStepName = 'EICase' + @vCaseNo + ' Fac ' + convert(varchar,@vDstFacId) + ' : ONLINE INSERT'

			SELECT @SqlCommand = ISNULL(@SqlCommand, '') + CHAR(13) + CHAR(10) + 'IF @ReturnVal=0' + CHAR(13) + CHAR(10) + 'BEGIN' + CHAR(13) + CHAR(10) + CHAR(9) + 'EXEC [operational].[sproc_facacq_insertStagingToDestinationOnline] ' + CHAR(13) + CHAR(10) + CHAR(9) + '@conv_server=''' + @vTSConversionServer + ''', @StagingDB=''' + @vStageDBName + ''',@DestinationDB=''' + @vDestDBName + ''',' + CHAR(13) + CHAR(10) + CHAR(9) + '@ModuleToCopy=''' + LM.Module + ''',@TranFlag=NULL,@prefix=''EICASE' + @vCaseNo + ''',' + CHAR(13) + CHAR(10) + CHAR(9) + '@pmo=''' + CONVERT(VARCHAR, @vPMONumber) + ''',@resource=''' + @TS_Resource + ''',' + CHAR(13) + CHAR(10) + CHAR(9) + '@RunIDFlag=' + CASE 
					WHEN LM.Module IN (
							'E14'
							,'E1'
							,'E15'
							)
						AND RN = 1
						THEN '1'
					ELSE '2'
					END + ',' + CHAR(9) + '@ContinueMerge=''' + @vContinueMerge + ''',@ReturnVal=@ReturnVal OUTPUT,@flgOffLine=1,@MultiFacId=' + CONVERT(VARCHAR, LM.DstFacID) + '' + CHAR(13) + CHAR(10) + 'END' + CHAR(13) + CHAR(10) + 'ELSE' + CHAR(13) + CHAR(10) + 'BEGIN' + CHAR(13) + CHAR(10) + CHAR(9) + ';THROW 51000,''ERROR: Case No: ' + @vCaseNo + ' : Error on sproc_facacq_insertStagingToDestinationOnline'', 1' + CHAR(13) + CHAR(10) + 'END'
			FROM (
				SELECT ROW_NUMBER() OVER (
						ORDER BY LM.FacilityRunOrder
						) RN
					,LM.FacilityRunOrder
					,LM.CaseNo
					,ML.ITEMS Module
					,LM.SrcFacID
					,LM.DstFacID
					,LM.MODLIST
					,LM.ContMerge
				FROM @LoadEIMaster LM
				CROSS APPLY split(LM.ModList, ',') ML
				WHERE LM.CaseNo = @vCaseNo
				) LM

			SET @SqlCommand = 'USE ' + @vDestDBName + CHAR(13) + CHAR(10) + 'DECLARE @ReturnVal INT' + CHAR(13) + CHAR(10) + 'SET @ReturnVal=0' + CHAR(13) + CHAR(10) + @SqlCommand

			--PRINT @SqlCommand
			EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
				,@step_name = @vStepName
				,@cmdexec_success_code = 0
				,@on_success_action = 3
				,--3 FOR NEXT STEP, 1 FOR QUIT SUCCESS, 2 QUIT WITH FAILURE
				@on_fail_action = 2
				,@retry_attempts = 0
				,@retry_interval = 0
				,@os_run_priority = 0
				,@subsystem = N'TSQL'
				,@command = @SqlCommand
				,@database_name = N'master'
				,@flags = 8

			PRINT '*****************************************************************'
			PRINT 'Case No: ' + @vCaseNo + ' : Insert Into ds_merge_master.dbo.EIHistory'
			PRINT '*****************************************************************'

			IF @vProdRun = 'Y'
			BEGIN
				SET @vStepName = 'EICase' + @vCaseNo + ' Fac ' + convert(varchar,@vDstFacId) + ' : Insert Into EIHistory'
				SET @SqlCommand = NULL
				SET @SqlCommand = 'SELECT VALUE FROM ' + @vDestDBName + '.dbo.configuration_parameter ' + 'WHERE fac_id=' + CONVERT(VARCHAR, @vDstFacID) + ' AND name = ''pho_is_using_new_phys_order_form'''

				INSERT @outVal
				EXEC (@SqlCommand)

				SET @vDstEOM = (
						SELECT outVal
						FROM @outVal
						)

				DELETE
				FROM @outVal

				--Get Source Facility Name
				SET @SqlCommand = 'SELECT NAME FROM ' + @vSourceDBName + '.dbo.facility WHERE fac_id =''' + CONVERT(VARCHAR, @vSrcFacID) + ''''

				INSERT @outVal
				EXEC (@SqlCommand)

				SET @vSrcFacName = ISNULL((
							SELECT TOP 1 outVal
							FROM @outVal
							), '')

				DELETE
				FROM @outVal

				--ReSet @vSrcOrgCode for EIHistory
				SET @vTestSrcOrgCode = @vSrcOrgCode + ' (Test Env =' + @vTestSrcOrgCode + ')'
				--Get Destinatin Facility
				SET @SqlCommand = 'SELECT NAME FROM ' + @vDestDBName + '.dbo.facility WHERE fac_id =''' + CONVERT(VARCHAR, @vDstFacID) + ''''

				INSERT @outVal
				EXEC (@SqlCommand)

				SET @vDstFacName = ISNULL((
							SELECT TOP 1 outVal
							FROM @outVal
							), '')

				DELETE
				FROM @outVal

				SET @vModList = (SELECT TOP 1 ModList FROM @LoadEIMaster WHERE CaseNo = @vCaseNo)				-- Added by Amardeep on Jan 31 2022

				SET @SqlCommand = NULL
				SET @SqlInsert = NULL
				SET @SqlCommand = 'INSERT INTO [' + @vTSConversionServer + '].[ds_merge_master].[dbo].[EIHistory] 
									([case_no],[PMO_number],[DS_resource],[src_org_code],[dst_org_code],[src_fac_id],[dst_fac_id]
									,[src_EOM],[dst_EOM]
									,[mod_resident_identifiers_contact],[mod_security_roles],[mod_security_users],[mod_staff],[mod_medical_prof]
									,[mod_external_facility],[mod_user_defined_data],[mod_room_bed],[mod_census],[mod_assess_MDS2],[mod_assess_MDS3]
									,[mod_custom_UDA],[mod_MMQ],[mod_MMA],[mod_diagnosis],[mod_immunization],[mod_care_plan_custom],[mod_care_plan_library]
									,[mod_progress_note],[mod_weight_vitals],[mod_physician_order],[mod_alerts],[mod_risk_management],[mod_trust],[mod_irm]
									,[mod_online_doc],[mod_LabResultRadiology],[mod_Master_Insurance],[mod_Notes],[created_by],[revision_by])
									VALUES '

				SELECT @SqlInsert = COALESCE(@SqlInsert + ',', '') + CHAR(13) + CHAR(10) + '(''' + @vCaseNo + ''',''' + CONVERT(VARCHAR, @vPMONumber) + ''',''' + @TS_Resource + ''',''' + @vTestSrcOrgCode + ''',''' + @vDstOrgCode + ''',' + '''' + CONVERT(VARCHAR, @vSrcFacID) + '-' + @vSrcFacName + ''',''' + CONVERT(VARCHAR, @vDstFacID) + '-' + @vDstFacName + ''',''' + @vSrcEOM + ''',''' + @vDstEOM + ''',' + IIF(@vModList LIKE '%E1%', '''Y''', '''N''') + ',' + --mod_resident_identifiers_contact
					IIF(@vModList LIKE '%E14%', '''Y''', '''N''') + ',' + --mod_security_roles
					IIF(@vModList LIKE '%E15%', '''Y''', '''N''') + ',' + --mod_security_users
					IIF(@vModList LIKE '%E2%', '''Y''', '''N''') + ',' + --mod_staff
					IIF(@vModList LIKE '%E2A%', '''Y''', '''N''') + ',' + --mod_medical_prof
					IIF(@vModList LIKE '%E3%', '''Y''', '''N''') + ',' + --mod_external_facility
					IIF(@vModList LIKE '%E4%', '''Y''', '''N''') + ',' + --mod_user_defined_data
					IIF(@vModList LIKE '%E5%', '''Y''', '''N''') + ',' + --mod_room_bed
					IIF(@vModList LIKE '%E6%', '''Y''', '''N''') + ',' + --mod_census
					IIF(@vModList LIKE '%E7a%', '''Y''', '''N''') + ',' + --mod_assess_MDS2
					IIF(@vModList LIKE '%E7b%', '''Y''', '''N''') + ',' + --mod_assess_MDS3
					IIF(@vModList LIKE '%E7c%', '''Y''', '''N''') + ',' + --mod_custom_UDA
					IIF(@vModList LIKE '%E7d%', '''Y''', '''N''') + ',' + --mod_MMQ
					IIF(@vModList LIKE '%E7e%', '''Y''', '''N''') + ',' + --mod_MMA
					IIF(@vModList LIKE '%E8%', '''Y''', '''N''') + ',' + --mod_diagnosis
					IIF(@vModList LIKE '%E11%', '''Y''', '''N''') + ',' + --mod_immunization
					IIF(@vModList LIKE '%E12A%', '''Y''', '''N''') + ',' + --mod_care_plan_custom
					IIF(@vModList LIKE '%E12B%', '''Y''', '''N''') + ',' + --mod_care_plan_library
					IIF(@vModList LIKE '%E9%', '''Y''', '''N''') + ',' + --mod_progress_note
					IIF(@vModList LIKE '%E10%', '''Y''', '''N''') + ',' + --mod_weight_vitals
					IIF(@vModList LIKE '%E13%', '''Y''', '''N''') + ',' + --mod_physician_order
					IIF(@vModList LIKE '%E16%', '''Y''', '''N''') + ',' + --mod_alerts
					IIF(@vModList LIKE '%E17%', '''Y''', '''N''') + ',' + --mod_risk_management
					IIF(@vModList LIKE '%E18%', '''Y''', '''N''') + ',' + --mod_trust
					IIF(@vModList LIKE '%E19%', '''Y''', '''N''') + ',' + --mod_irm
					IIF(@vModList LIKE '%E20%', '''Y''', '''N''') + ',' + --mod_online_doc
					IIF(@vModList LIKE '%E21%', '''Y''', '''N''') + ',' + --mod_LabResultRadiology
					IIF(@vModList LIKE '%E22%', '''Y''', '''N''') + ',' + --mod_Master_Insurance
					IIF(@vModList LIKE '%E23%', '''Y''', '''N''') + ',' + --mod_Notes
					'''SQLJob''' + ',' + '''SQLJob'')'

				SET @SqlInsert = @SqlCommand + REPLACE(@SqlInsert, '''NULL''', 'NULL')
				SET @SqlCommand = 'USE ' + @vDestDBName + CHAR(13) + CHAR(10) + @SqlInsert
			END
			ELSE
			BEGIN
				SET @vStepName = 'EICase' + @vCaseNo + ' Fac ' + convert(varchar,@vDstFacId) + ' : Insert Into EIHistory'
				SET @SqlCommand = NULL
				SET @SqlCommand = 'SELECT 1'
				SET @SqlCommand = 'USE ' + @vDestDBName + CHAR(13) + CHAR(10) + @SqlCommand
			END

			EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
				,@step_name = @vStepName
				,@cmdexec_success_code = 0
				,@on_success_action = 3
				,--3 FOR NEXT STEP, 1 FOR QUIT SUCCESS, 2 QUIT WITH FAILURE
				@on_fail_action = 2
				,@retry_attempts = 0
				,@retry_interval = 0
				,@os_run_priority = 0
				,@subsystem = N'TSQL'
				,@command = @SqlCommand
				,@database_name = N'master'
				,@flags = 8

			PRINT '********************************************************************'
			PRINT 'Case No: ' + @vCaseNo + ' : Update Into ds_merge_master.dbo.LoadEIMaster_Automation'
			PRINT '********************************************************************'

			IF @vProdRun = 'Y'
			BEGIN
				SET @vStepName = 'EICase' + @vCaseNo + ' Fac ' + convert(varchar,@vDstFacId) + ' : Update LoadEIMaster_Automation'
				SET @SqlCommand = NULL
				SET @SqlCommand = 'UPDATE [' + @vTSConversionServer + '].[ds_merge_master].[dbo].LoadEIMaster_Automation' + CHAR(13) + CHAR(10) + 'SET completed = 1 WHERE RunID=' + CONVERT(VARCHAR, @vRunID)
				SET @SqlCommand = 'USE ' + @vDestDBName + CHAR(13) + CHAR(10) + @SqlCommand
			END
			ELSE
			BEGIN
				SET @vStepName = 'EICase' + @vCaseNo + ' Fac ' + convert(varchar,@vDstFacId) + ' : Update LoadEIMaster_Automation'
				SET @SqlCommand = NULL
				SET @SqlCommand = 'SELECT 1'
				SET @SqlCommand = 'USE ' + @vDestDBName + CHAR(13) + CHAR(10) + @SqlCommand
			END

			EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
				,@step_name = @vStepName
				,@cmdexec_success_code = 0
				,@on_success_action = 3
				,--3 FOR NEXT STEP, 1 FOR QUIT SUCCESS, 2 QUIT WITH FAILURE
				@on_fail_action = 2
				,@retry_attempts = 0
				,@retry_interval = 0
				,@os_run_priority = 0
				,@subsystem = N'TSQL'
				,@command = @SqlCommand
				,@database_name = N'master'
				,@flags = 8

			PRINT '***************************************'
			PRINT 'Case No: ' + @vCaseNo + ' : Enable Facility'
			PRINT '***************************************'

			SET @vStepName = 'EICase' + @vCaseNo + ' Fac ' + convert(varchar,@vDstFacId) + ' : Enable Facility'
			SET @SqlCommand = NULL
			SET @SqlCommand = 'UPDATE ' + @vDestDBName + '.[dbo].facility' + CHAR(13) + CHAR(10) + 'SET deleted=''N'', inactive = NULL, inactive_date = NULL WHERE fac_id=''' + CONVERT(VARCHAR, @vDstFacID) + ''''
			SET @SqlCommand = 'USE ' + @vDestDBName + CHAR(13) + CHAR(10) + @SqlCommand

			--PRINT @SqlCommand
			EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
				,@step_name = @vStepName
				,@cmdexec_success_code = 0
				,@on_success_action = 3
				,--3 FOR NEXT STEP, 1 FOR QUIT SUCCESS, 2 QUIT WITH FAILURE
				@on_fail_action = 2
				,@retry_attempts = 0
				,@retry_interval = 0
				,@os_run_priority = 0
				,@subsystem = N'TSQL'
				,@command = @SqlCommand
				,@database_name = N'master'
				,@flags = 8

			PRINT '************************************************************'
			PRINT 'Case No: ' + @vCaseNo + ' : Execute PostMergeScriptDst on DestDB'
			PRINT '************************************************************'

			SELECT  @vCurrentRunId = LM.RunId FROM @LoadEIMaster LM WHERE LM.CaseNo = @vCaseNo

			SET @vStepName = 'EICase' + @vCaseNo + ' Fac ' + convert(varchar,@vDstFacId) + ' : POST    Standard on Destination'
			
			SET @SqlCommand = NULL
			SET @SqlCommand = 'USE ' + @vDestDBName+CHAR(13)+CHAR(10)
			SET @SqlCommand = @SqlCommand + 'SET CONTEXT_INFO 0xDC1000000;'+CHAR(13)+CHAR(10)+' SET DEADLOCK_PRIORITY 4;'+CHAR(13)+CHAR(10)+' SET QUOTED_IDENTIFIER ON;'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
			SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_post_MpiHistoryInsert]'+CHAR(13)+CHAR(10)
			SET @SqlCommand = @SqlCommand + '@src_db_location = ''' + @vSourceDBName + ''''+CHAR(13)+CHAR(10)
			SET @SqlCommand = @SqlCommand + ',@NS_Case_Number = ''EICase' + @vCaseNo + ''''+CHAR(13)+CHAR(10)
			SET @SqlCommand = @SqlCommand + ',@source_fac_id = ''' + CONVERT(VARCHAR, @vSrcFacID) + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) 

			SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_post_Insert_common_code_standard_contact_type_mapping]'+CHAR(13)+CHAR(10)
			SET @SqlCommand = @SqlCommand + '@src_db_location = ''' + @vSourceDBName + ''''+CHAR(13)+CHAR(10)
			SET @SqlCommand = @SqlCommand + ',@NS_Case_Number = ''EICase' + @vCaseNo + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) 

			IF EXISTS(SELECT 1 FROM @LoadEIMaster WHERE (',' + ModList + ',') LIKE '%,E15,%' and RunId = @vCurrentRunId)
				BEGIN 
					--SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_post_ifSecUserPositionUpdate]'+CHAR(13)+CHAR(10)
					--SET @SqlCommand = @SqlCommand + '@source_db = ''' + @vSourceDBName + ''''+CHAR(13)+CHAR(10)
					--SET @SqlCommand = @SqlCommand + ',@NSCaseNumber = ''EICase' + @vCaseNo + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) 
					
					SET @SqlCommand = @SqlCommand + 'update dst set dst.staff_id = cmap.dst_id'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + 'from sec_user dst'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + 'join EICase' + @vCaseNo + 'sec_user umap on dst.userid = umap.dst_id'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + 'join ' + @vSourceDBName + '.dbo.sec_user src on umap.src_id = src.userid'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + 'join EICase' + @vCaseNo + 'contact cmap on src.staff_id = cmap.src_id'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + 'where dst.created_by = ''EICase' + @vCaseNo + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)

					SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_post_ifSecUserUpdateEmail]'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + '@NSCaseNumber = ''EICase' + @vCaseNo + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END
	
			IF EXISTS(SELECT 1 FROM @LoadEIMaster WHERE (',' + ModList + ',') LIKE '%,E4,%' and RunId = @vCurrentRunId)
				BEGIN SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_post_IfUserDefinedDataRemoveDups]'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + '@NS_Case_Number = ''EICase' + @vCaseNo + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END

			IF EXISTS(SELECT 1 FROM @LoadEIMaster WHERE ((',' + ModList + ',') LIKE '%,E7a,%' or (',' + ModList + ',') LIKE '%,E7b,%') and RunId = @vCurrentRunId)
				BEGIN SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_post_ifUsingEinteract]'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + '@NSCaseNumber = ''EICase' + @vCaseNo + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END

			IF EXISTS(SELECT 1 FROM @LoadEIMaster WHERE (',' + ModList + ',') LIKE '%,E7c,%' and RunId = @vCurrentRunId)
				BEGIN SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_post_ifCopyUDAqlibFix]'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + '@source_db = ''' + @vSourceDBName + ''''+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + ',@NSCaseNumber = ''EICase' + @vCaseNo + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) 
					
					set @SqlCommand = @SqlCommand + 'BEGIN DECLARE @SRCSTRING VARCHAR(50); DECLARE @DSTSTRING VARCHAR(50);DECLARE @rowid INT = 0;DECLARE @sqln NVARCHAR(max); DECLARE @sql VARCHAR(max); DECLARE @rowcount INT = 0;'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
					set @SqlCommand = @SqlCommand + 'SET @sqln = N''SELECT @rowcount = COUNT(1) FROM EICase' + @vCaseNo + 'as_std_score'' EXEC sp_executesql @sqln, N''@rowcount INT  OUTPUT'', @rowcount OUTPUT'+CHAR(13)+CHAR(10)
					set @SqlCommand = @SqlCommand + 'SET @sql = ''select distinct 1 from as_std_score with (nolock) where std_score_id in (select dst_id from EICase'+ @vCaseNo + 'as_std_score where corporate = ''''N'''') and formula like ''''%[[]SCR%'''''''
					set @SqlCommand = @SqlCommand + 'IF @@ROWCOUNT <> 0'+CHAR(13)+CHAR(10)
					set @SqlCommand = @SqlCommand + 'BEGIN WHILE (@rowid <= @rowcount) '+CHAR(13)+CHAR(10)
					set @SqlCommand = @SqlCommand + 'BEGIN SET @sqln = N''SELECT TOP 1 @rowid = row_id FROM EICase' + @vCaseNo + 'as_std_score WHERE CORPORATE = ''''N'''' and row_id > '' + convert(varchar,@rowid) + '' ORDER BY row_id'''+CHAR(13)+CHAR(10)
					set @SqlCommand = @SqlCommand + 'EXEC sp_executesql @sqln, N''@rowid int  OUTPUT'', @rowid OUTPUT'+CHAR(13)+CHAR(10)
					set @SqlCommand = @SqlCommand + 'IF @@ROWCOUNT = 0 BREAK;'+CHAR(13)+CHAR(10)
					set @SqlCommand = @SqlCommand + 'SET @sqln = N''SELECT @SRCSTRING = ''''[SCR_'''' + convert(varchar, src_id) + '''']'''' FROM EICase' + @vCaseNo + 'as_std_score WHERE CORPORATE = ''''N'''' AND ROW_ID = '' + convert(varchar,@rowid)'+CHAR(13)+CHAR(10)
					set @SqlCommand = @SqlCommand + 'EXEC sp_executesql @sqln, N''@SRCSTRING VARCHAR(50)  OUTPUT'', @SRCSTRING OUTPUT'+CHAR(13)+CHAR(10)
					set @SqlCommand = @SqlCommand + 'SET @sqln = N''SELECT @DSTSTRING = ''''[SCR_'''' + convert(varchar, dst_id) + '''']'''' FROM EICase' + @vCaseNo + 'as_std_score WHERE CORPORATE = ''''N'''' AND ROW_ID = '' + convert(varchar,@rowid)'+CHAR(13)+CHAR(10)
					set @SqlCommand = @SqlCommand + 'EXEC sp_executesql @sqln, N''@DSTSTRING VARCHAR(50)  OUTPUT'', @DSTSTRING OUTPUT'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
					set @SqlCommand = @SqlCommand + 'SET @sql = ''if exists(select 1 from as_std_score dst with (nolock) join EICase' + @vCaseNo + 'as_std_score map on dst.std_score_id = map.dst_id'+CHAR(13)+CHAR(10)
					set @SqlCommand = @SqlCommand + 'join ' + @vSourceDBName + '.dbo.as_std_score src on map.src_id = src.std_score_id'+CHAR(13)+CHAR(10)
					set @SqlCommand = @SqlCommand + 'where map.corporate = ''''N'''' and src.formula like ''''%'''' + replace('''''' + @SRCSTRING + '''''',''''['''',''''[[]'''') + ''''%'''''+CHAR(13)+CHAR(10)
					set @SqlCommand = @SqlCommand + 'and exists (select 1 from as_std_score with (nolock) '+CHAR(13)+CHAR(10)
					set @SqlCommand = @SqlCommand + 'where dst.std_score_id = std_score_id and formula like ''''%'''' + replace('''''' + @DSTSTRING + '''''',''''['''',''''[[]'''') + ''''%''''))'+CHAR(13)+CHAR(10)
					set @SqlCommand = @SqlCommand + 'BEGIN PRINT ''''--check: src - '' + @SRCSTRING + '' dst - '' + @DSTSTRING + ''''''END'' exec(@sql)'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
					set @SqlCommand = @SqlCommand + 'SET @sql = ''update dst SET dst.formula = replace(dst.formula,''''''+@SRCSTRING+'''''',''''''+@DSTSTRING+'''''')'+CHAR(13)+CHAR(10)
					set @SqlCommand = @SqlCommand + 'from as_std_score dst join EICase' + @vCaseNo + 'as_std_score map on dst.std_score_id = map.dst_id'+CHAR(13)+CHAR(10)
					set @SqlCommand = @SqlCommand + 'join ' + @vSourceDBName + '.dbo.as_std_score src with (nolock) on map.src_id = src.std_score_id'+CHAR(13)+CHAR(10)
					set @SqlCommand = @SqlCommand + 'where map.corporate = ''''N'''' and src.formula like ''''%'''' + replace(''''''+@SRCSTRING+'''''',''''['''',''''[[]'''') + ''''%'''''+CHAR(13)+CHAR(10)
					set @SqlCommand = @SqlCommand + 'and not exists (select 1 from as_std_score with (nolock) '+CHAR(13)+CHAR(10)
					set @SqlCommand = @SqlCommand + 'where dst.std_score_id = std_score_id and formula like ''''%'''' + replace(''''''+@DSTSTRING+'''''',''''['''',''''[[]'''') + ''''%'''')'+CHAR(13)+CHAR(10)
					set @SqlCommand = @SqlCommand + '''exec (@sql) END END END'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
					
					END

			IF EXISTS(SELECT 1 FROM @LoadEIMaster WHERE (',' + ModList + ',') LIKE '%,E7c,%' and (',' + ModList + ',') NOT LIKE '%,E12b,%' and RunId = @vCurrentRunId)
				BEGIN SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_post_ifCopyUDAWithoutCarePlanLibrary]'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + '@destination_fac_id = ''' + CONVERT(VARCHAR, @vDstFacID) + ''''+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + ',@NSCaseNumber = ''EICase' + @vCaseNo + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END

			------to add as_std_score fix here

			IF EXISTS(SELECT 1 FROM @LoadEIMaster WHERE (',' + ModList + ',') LIKE '%,E8,%' and RunId = @vCurrentRunId)
				BEGIN SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_post_ifCopyDiagnosis]'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + '@source_db = ''' + @vSourceDBName + ''''+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + ',@destination_fac_id = ''' + CONVERT(VARCHAR, @vDstFacID) + ''''+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + ',@NSCaseNumber = ''EICase' + @vCaseNo + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END

			IF EXISTS(SELECT 1 FROM @LoadEIMaster WHERE (',' + ModList + ',') LIKE '%,E12a,%' and (',' + ModList + ',') NOT LIKE '%,E12b,%' and RunId = @vCurrentRunId)
				BEGIN SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_post_ifCopyCarePlanWithoutLibrary]'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + '@destination_fac_id = ''' + CONVERT(VARCHAR, @vDstFacID) + ''''+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + ',@NSCaseNumber = ''EICase' + @vCaseNo + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END

			IF EXISTS(SELECT 1 FROM @LoadEIMaster WHERE (',' + ModList + ',') LIKE '%,E13,%' and RunId = @vCurrentRunId)
				BEGIN 
					SET @SqlCommand = @SqlCommand + 'DELETE FROM PCC_GLOBAL_PRIMARY_KEY WHERE TABLE_NAME = ''PHO_ADMIN_ORDER_AUDIT'';'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + 'DELETE FROM PCC_GLOBAL_PRIMARY_KEY WHERE TABLE_NAME = ''PHO_RELATED_ORDER_AUDIT'';'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_post_ifCopyOrders_01_OrderAudit]'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + '@source_db = ''' + @vSourceDBName + ''''+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + ',@source_fac_id = ''' + CONVERT(VARCHAR, @vSrcFacID) + ''''+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + ',@destination_fac_id = ''' + CONVERT(VARCHAR, @vDstFacID) + ''''+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + ',@NSCaseNumber = ''EICase' + @vCaseNo + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) 
					
					SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_post_ifCopyOrders_02_AdminOrderAudit]'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + '@source_db = ''' + @vSourceDBName + ''''+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + ',@source_fac_id = ''' + CONVERT(VARCHAR, @vSrcFacID) + ''''+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + ',@destination_fac_id = ''' + CONVERT(VARCHAR, @vDstFacID) + ''''+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + ',@NSCaseNumber = ''EICase' + @vCaseNo + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) 

					SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_post_ifCopyOrders_03_RelatedOrderAudit]'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + '@source_db = ''' + @vSourceDBName + ''''+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + ',@source_fac_id = ''' + CONVERT(VARCHAR, @vSrcFacID) + ''''+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + ',@destination_fac_id = ''' + CONVERT(VARCHAR, @vDstFacID) + ''''+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + ',@NSCaseNumber = ''EICase' + @vCaseNo + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END

			IF EXISTS(SELECT 1 FROM @LoadEIMaster WHERE (',' + ModList + ',') LIKE '%,E17,%' and RunId = @vCurrentRunId)
				BEGIN SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_post_ifCopyRiskManagement]'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + '@source_db = ''' + @vSourceDBName + ''''+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + ',@NSCaseNumber = ''EICase' + @vCaseNo + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END

			IF EXISTS(SELECT 1 FROM @LoadEIMaster WHERE (',' + ModList + ',') LIKE '%,E7c,%,E17,%' and RunId = @vCurrentRunId)
				BEGIN SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_post_ifCopyUDAandRiskManagement]'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + '@destination_fac_id = ''' + CONVERT(VARCHAR, @vDstFacID) + ''''+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + ',@NSCaseNumber = ''EICase' + @vCaseNo + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END

			IF EXISTS(SELECT 1 FROM @LoadEIMaster WHERE (',' + ModList + ',') LIKE '%,E20,%' and RunId = @vCurrentRunId)
				BEGIN SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_post_ifOnlineDocumentation_Location_Update]'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + '@source_org_code = ''' + @vSrcOrgCode + ''''+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + ',@destination_org_code = ''' + @vDstOrgCode + ''''+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + ',@source_fac_id = ''' + CONVERT(VARCHAR, @vSrcFacID) + ''''+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + ',@destination_fac_id = ''' + CONVERT(VARCHAR, @vDstFacID) + ''''+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + ',@NSCaseNumber = ''EICase' + @vCaseNo + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END

			IF EXISTS(SELECT 1 FROM @LoadEIMaster WHERE (',' + ModList + ',') LIKE '%,E21,%' and RunId = @vCurrentRunId)
				BEGIN SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_post_ifCopyLabs]'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + '@source_db = ''' + @vSourceDBName + ''''+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + ',@destination_fac_id = ''' + CONVERT(VARCHAR, @vDstFacID) + ''''+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + ',@NSCaseNumber = ''EICase' + @vCaseNo + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END

			SET @SqlCommand = @SqlCommand + 'declare @timestamp datetime = getdate()'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
			SET @SqlCommand = @SqlCommand + 'exec [dbo].[pcc_update_cache_time] @fac_id = ''' + CONVERT(VARCHAR, @vDstFacID) + ''',@cache_name = ''facilityRecs'',@cache_time = @timestamp OUTPUT'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
			SET @SqlCommand = @SqlCommand + 'exec [dbo].[pcc_update_cache_time] @fac_id = -1,@cache_name = ''MASTER'',@cache_time = @timestamp OUTPUT'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)

			IF @vCurrentRunId = (SELECT RunId FROM @LoadEIMaster WHERE FacilityRunOrder = (SELECT MAX(FacilityRunOrder) FROM @LoadEIMaster))
				BEGIN SET @SqlCommand = @SqlCommand + 'DELETE FROM dbo.facility_scheduling_cycle;'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + 'INSERT INTO dbo.facility_scheduling_cycle(fac_id, run_day)'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + 'SELECT fac_id, (CASE WHEN fac_id % 20 <> 0 THEN fac_id % 20 ELSE 20 END) + 6 AS runDay '+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + 'FROM dbo.facility WHERE ((FACILITY.fac_id  <> 9999 AND (FACILITY.inactive IS NULL OR FACILITY.inactive  <> ''Y'') AND (FACILITY.is_live <> ''N'' OR FACILITY.is_live IS NULL ))) '+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + 'AND ((FACILITY.DELETED = ''N''))'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END

			------EMR Link Post Scripts:
			SET @SqlCommand = @SqlCommand + 'DECLARE @rcnt int = 0'+CHAR(13)+CHAR(10)
			SET @SqlCommand = @SqlCommand + 'DECLARE @nsqlcheck nvarchar(1000)'+CHAR(13)+CHAR(10)
			SET @SqlCommand = @SqlCommand + 'SET @nsqlcheck = ''select @rcnt = count(1) from ' + @vSourceDBName + '.dbo.emrlink_client_sync_tracking src with (nolock)'+CHAR(13)+CHAR(10) 
			SET @SqlCommand = @SqlCommand + 'where src.client_id in (select src_id from EICase' + @vCaseNo + 'clients with (nolock))'''+CHAR(13)+CHAR(10)
			SET @SqlCommand = @SqlCommand + 'EXEC Sp_executesql @nsqlcheck, N''@rcnt INT OUTPUT'', @rcnt OUTPUT'+CHAR(13)+CHAR(10)
			SET @SqlCommand = @SqlCommand + 'IF @rcnt <> 0 BEGIN '+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) 

					SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_post_IfCopyEMRLink_01_emrlink_client_sync_tracking]'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + '@src_db_location = ''' + @vSourceDBName + ''''+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + ',@NS_case_number = ''EICase' + @vCaseNo + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) 
					
					SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_post_IfCopyEMRLink_02_emrlink_order_sync_tracking]'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + '@src_db_location = ''' + @vSourceDBName + ''''+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + ',@NS_case_number = ''EICase' + @vCaseNo + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) 					

					SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_post_IfCopyEMRLink_03_emrlink_order_sync_error_tracking]'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + '@src_db_location = ''' + @vSourceDBName + ''''+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + ',@NS_case_number = ''EICase' + @vCaseNo + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) 

					SET @SqlCommand = @SqlCommand + 'if exists(select 1 from information_schema.TABLES where table_name = ''EICase' + @vCaseNo + 'result_lab_report'') BEGIN'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_post_IfCopyEMRLink_04_pho_lab_integrated_order_detail]'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + '@src_db_location = ''' + @vSourceDBName + ''''+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + ',@NS_case_number = ''EICase' + @vCaseNo + ''''+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + 'END'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) 

					SET @SqlCommand = @SqlCommand + 'if exists(select 1 from information_schema.TABLES where table_name = ''EICase' + @vCaseNo + 'result_radiology_report'') BEGIN'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_post_IfCopyEMRLink_05_pho_rad_integrated_order_detail]'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + '@src_db_location = ''' + @vSourceDBName + ''''+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + ',@NS_case_number = ''EICase' + @vCaseNo + ''''+CHAR(13)+CHAR(10)		
					SET @SqlCommand = @SqlCommand + 'END'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) 

			SET @SqlCommand = @SqlCommand + 'END'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) 	

			--PRINT @CmdCommand
			EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
				,@step_name = @vStepName
				,@cmdexec_success_code = 0
				,@on_success_action = 3
				,--3 FOR NEXT STEP, 1 FOR QUIT SUCCESS, 2 QUIT WITH FAILURE
				@on_fail_action = 2
				,@retry_attempts = 0
				,@retry_interval = 0
				,@os_run_priority = 0
				,@subsystem = N'TSQL'
				,@command = @SqlCommand
				,@database_name = @vDestDBName -- N'master'
				,@flags = 8

			PRINT '************************************************************'
			PRINT 'Case No: ' + @vCaseNo + ' : Execute PostMergeScriptDst on DestDB'
			PRINT '************************************************************'

			SET @vStepName = 'EICase' + @vCaseNo + ' Fac ' + convert(varchar,@vDstFacId) + ' : POST    Custom on Destination ******'
			SET @SqlCommand = 'SELECT 1'

			--PRINT @CmdCommand
			EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
				,@step_name = @vStepName
				,@cmdexec_success_code = 0
				,@on_success_action = 3
				,--3 FOR NEXT STEP, 1 FOR QUIT SUCCESS, 2 QUIT WITH FAILURE
				@on_fail_action = 2
				,@retry_attempts = 0
				,@retry_interval = 0
				,@os_run_priority = 0
				,@subsystem = N'TSQL'
				,@command = @SqlCommand
				,@database_name = @vDestDBName -- N'master'
				,@flags = 8


			PRINT '***********************************************************************'
			PRINT 'Case No: ' + @vCaseNo + ' : Email Notification Facility Migration Completed'
			PRINT '***********************************************************************'

			UPDATE @DstFacList
			SET IsDone = 'Y'
			WHERE FacId = @vDstFacID

			SET @vDoneDstFacList = NULL

			SELECT @vDoneDstFacList = COALESCE(@vDoneDstFacList + CHAR(13) + CHAR(10) + '</br>', '</br>') + FacName
			FROM @DstFacList
			WHERE IsDone = 'Y'

			SET @vNotDoneDstFacList = ''

			SELECT @vNotDoneDstFacList = COALESCE(@vNotDoneDstFacList + CHAR(13) + CHAR(10) + '</br>', '</br>') + FacName
			FROM @DstFacList
			WHERE IsDone = 'N'

			--Internal Email
			IF LEN(@vIntEmailSubject) > 1
			BEGIN
				SET @EmailSubject = @vIntEmailSubject
			END
			ELSE
			BEGIN
				SET @EmailSubject = 'Scheduled Data Copy ' + CONVERT(VARCHAR, DATENAME(month, GETDATE())) + ' ' + CONVERT(VARCHAR, DATENAME(DAY, GETDATE())) + ', PMO - ' + CONVERT(VARCHAR, @vPMONumber)
			END

			IF (
					SELECT COUNT(*)
					FROM @DstFacList
					WHERE IsDone = 'Y'
					) > 1
			BEGIN
				SET @EmailBody = 'Hi All,</br></br> Following facilities are now online in ' + UPPER(@vDstOrgCode) + ' :</br>' + @vDoneDstFacList + '</br></br>'
			END
			ELSE
			BEGIN
				SET @EmailBody = 'Hi All,</br></br> Following facility is now online in ' + UPPER(@vDstOrgCode) + ' :</br>' + @vDoneDstFacList + '</br></br>'
			END

			IF RTRIM(@vNotDoneDstFacList) <> ''
			BEGIN
				IF (
						SELECT COUNT(*)
						FROM @DstFacList
						WHERE IsDone = 'N'
						) > 1
				BEGIN
					SET @EmailBody = @EmailBody + 'Following facilities are still offline in ' + UPPER(@vDstOrgCode) + ' :</br>' + @vNotDoneDstFacList + '</br></br>'
				END
				ELSE
				BEGIN
					SET @EmailBody = @EmailBody + 'Following facility is still offline in ' + UPPER(@vDstOrgCode) + ' :</br>' + @vNotDoneDstFacList + '</br></br>'
				END
			END
			ELSE IF RTRIM(@vNotDoneDstFacList) = ''
			BEGIN
				IF (
						SELECT COUNT(*)
						FROM @DstFacList
						) > 1
				BEGIN
					SET @EmailBody = 'Hi All,</br></br> Data Copy for ' + UPPER(@vDstOrgCode) + ' is now completed and following facilities are back online :</br></br>' + @vDstFacList + '</br></br>'
				END
				ELSE
				BEGIN
					SET @EmailBody = 'Hi All,</br></br> Data Copy for ' + UPPER(@vDstOrgCode) + ' is now completed and following facility is back online :</br></br>' + @vDstFacList + '</br></br>'
				END
			END

			SET @EmailBody = @EmailBody + '</br></br></br>Thanks,</br>Facility Acquisition Team'
			SET @SqlCommand = NULL
			SET @SqlCommand = 'EXEC msdb.dbo.sp_send_dbmail @recipients =''' + @EmailRecipientsInt + ''',' + CHAR(13) + CHAR(10) + '@subject=''' + @EmailSubject + ''',' + CHAR(13) + CHAR(10) + '@body=''' + @EmailBody + ''',' + CHAR(13) + CHAR(10) + '@body_format=''HTML'''

			--External Email
			IF LEN(@vExtEmailSubject) > 1
			BEGIN
				SET @EmailSubject = @vExtEmailSubject
			END
			ELSE
			BEGIN
				SET @EmailSubject = 'PMO - ' + CONVERT(VARCHAR, @vPMONumber) + ', ' + 'Data Copy of ' + UPPER(@vSrcOrgCode) + ' to ' + UPPER(@vDstOrgCode) + ' : Friendly reminder'
			END

			SET @EmailBody = @EmailBody + '</br></br>NOTE: If there’s any post data copy issue please reply all to this email.'
			SET @SqlCommand = @SqlCommand + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + 'EXEC msdb.dbo.sp_send_dbmail @recipients =''' + @EmailRecipientsExt + ''',' + CHAR(13) + CHAR(10) + '@subject=''' + @EmailSubject + ''',' + CHAR(13) + CHAR(10) + '@body=''' + @EmailBody + ''',' + CHAR(13) + CHAR(10) + '@body_format=''HTML'''
			SET @SqlCommand = 'USE MASTER' + CHAR(13) + CHAR(10) + @SqlCommand
			SET @vStepName = 'EICase' + @vCaseNo + ' Fac ' + convert(VARCHAR, @vDstFacId) + ' : Email Notification Data Copy Completed'

			EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId, @step_name = @vStepName, @cmdexec_success_code = 0, @on_success_action = 3,
				--3 FOR NEXT STEP, 1 FOR QUIT SUCCESS, 2 QUIT WITH FAILURE
				@on_fail_action = 2, @retry_attempts = 0, @retry_interval = 0, @os_run_priority = 0, @subsystem = N'TSQL', @command = @SqlCommand, @database_name = N'master', @flags = 8

			DELETE
			FROM @outVal

			FETCH NEXT
			FROM CurCase
			INTO @vRunID, @vCaseNo, @vTestSrcOrgCode, @vTestDstOrgCode, @vSrcFacID, @vDstFacID, @vSrcEOM
		END --END OF CURSOR CurCase

		CLOSE CurCase

		DEALLOCATE CurCase

		PRINT '**************************************************'
		PRINT 'Update ds_merge_master.dbo.LoadEIMaster_PMO_Groups'
		PRINT '**************************************************'

		--@vPMOGroupId
		SET @vStepName = 'Update ds_merge_master.dbo.LoadEIMaster_PMO_Groups'
		SET @SqlCommand = NULL

		IF @vProdRun = 'Y'
		BEGIN
			SET @SqlCommand = 'IF (SELECT COUNT(1) FROM [' + @vTSConversionServer + '].ds_merge_master.dbo.[LoadEIMaster_Automation] 
										 WHERE Completed = 0 AND PMO_Group_Id = ' + CONVERT(VARCHAR, @vPMOGroupId) + ') = 0' + CHAR(13) + CHAR(10) + 'UPDATE [' + @vTSConversionServer + '].ds_merge_master.[dbo].[LoadEIMaster_PMO_Groups] SET Completed = 1 
										  WHERE PMO_Group_Id = ' + CONVERT(VARCHAR, @vPMOGroupId) + ''
		END
		ELSE
		BEGIN
			SET @SqlCommand = 'SELECT 1'
		END

		SET @SqlCommand = 'USE ' + @vDestDBName + CHAR(13) + CHAR(10) + @SqlCommand

		--PRINT @SqlCommand
		EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
			,@step_name = @vStepName
			,@cmdexec_success_code = 0
			,@on_success_action = 3
			,--3 FOR NEXT STEP, 1 FOR QUIT SUCCESS, 2 QUIT WITH FAILURE
			@on_fail_action = 2
			,@retry_attempts = 0
			,@retry_interval = 0
			,@os_run_priority = 0
			,@subsystem = N'TSQL'
			,@command = @SqlCommand
			,@database_name = N'master'
			,@flags = 8

		PRINT '*****************************************************************************************************'
		PRINT 'Execute [operational].[sproc_facacq_createInsertMergelogStagingToDestination] on Destination DB'
		PRINT '*****************************************************************************************************'

		SET @SqlCommand = NULL
		SET @vStepName = 'Copy Mergelog to Destination DB'
		SET @SqlCommand = 'EXEC [operational].[sproc_facacq_createInsertMergelogStagingToDestination] ' + CHAR(13) + CHAR(10) + '@StagingDB=''' + @vStageDBName + ''';' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
		
		IF @vProdRun = 'Y'
			BEGIN SET @SqlCommand = @SqlCommand +  'exec sp_updatestats;' + CHAR(13) + CHAR(10) END


		SET @SqlCommand = 'USE ' + @vDestDBName + CHAR(13) + CHAR(10) + @SqlCommand

		--PRINT @SqlCommand
		EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
			,@step_name = @vStepName
			,@cmdexec_success_code = 0
			,@on_success_action = 1
			,--3 FOR NEXT STEP, 1 FOR QUIT SUCCESS, 2 QUIT WITH FAILURE
			@on_fail_action = 2
			,@retry_attempts = 0
			,@retry_interval = 0
			,@os_run_priority = 0
			,@subsystem = N'TSQL'
			,@command = @SqlCommand
			,@database_name = N'master'
			,@flags = 8

		PRINT '**************************************************************'
		PRINT 'Email step to send pager duty / job failure notifications'
		PRINT '**************************************************************'

		SET @Recipient = iif(@vProdRun = 'Y', @vPagerDutyEmail, @EmailRecipientsInt)
		SET @SqlCommand = 'EXEC [operational].[sproc_facacq_sendEmailNotification] @Recipient = ''' + @Recipient + '''
					,@BlindCopyRecipients = ''' + @vFacAcqEmailAddress + '''
					,@JobName = ''' + @vJobName + ' ''
					,@ServerName = ''' + quotename(@ServerName) + ''''
		SET @SqlCommand = 'USE ' + @vDestDBName + CHAR(13) + CHAR(10) + @SqlCommand

		EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
			,@step_name = N'TS Job Failure Email Notification'
			,@cmdexec_success_code = 0
			,@on_success_action = 2
			,--3 FOR NEXT STEP, 1 FOR QUIT SUCCESS, 2 QUIT WITH FAILURE
			@on_fail_action = 2
			,@retry_attempts = 0
			,@retry_interval = 0
			,@os_run_priority = 0
			,@subsystem = N'TSQL'
			,@command = @SqlCommand
			,@database_name = N'master'
			,@flags = 8

		PRINT '************************************************'
		PRINT 'On Failure Step : Update on fail action'
		PRINT '************************************************'

		DECLARE @vEmailStepId INT

		SET @vEmailStepId = (
				SELECT step_id
				FROM msdb.dbo.sysjobsteps
				WHERE Job_id = (
						SELECT job_id
						FROM msdb.dbo.sysjobs
						WHERE [name] = @vJobName
						)
					AND step_name = N'TS Job Failure Email Notification'
				)

		UPDATE msdb.dbo.sysjobsteps
		SET on_fail_action = 4 ---- Go to step on_fail_step_id
			,on_fail_step_id = @vEmailStepId
		WHERE job_id IN (
				SELECT JOB_ID
				FROM MSDB.dbo.sysjobs
				WHERE NAME = @vJobName
				)
			AND step_name <> N'TS Job Failure Email Notification'

		PRINT '************************************************'
		PRINT 'Last Step : Setup Last Step Action OnSuccess = 1'
		PRINT '************************************************'

		SET @vLastStepId = (
				SELECT MAX(STEP_ID)
				FROM MSDB.DBO.sysjobsteps
				WHERE JOB_ID = (
						SELECT JOB_ID
						FROM MSDB.dbo.sysjobs
						WHERE NAME = @vJobName
						)
				)
		
		set @vLastStepId = @vLastStepId - 1--Nigel, last step is for failure. The 1 step before is the real last step

		EXEC MSDB.dbo.sp_update_jobstep @job_id = @jobId
			,@step_id = @vLastStepId
			,@on_success_action = 1;
	END TRY

	BEGIN CATCH
		PRINT 'Error:' + CONVERT(VARCHAR, ERROR_NUMBER()) + '-' + ERROR_MESSAGE()

		IF CURSOR_STATUS('global', 'CurCase') >= - 1
		BEGIN
			CLOSE CurCase

			DEALLOCATE CurCase
		END
	END CATCH
END
