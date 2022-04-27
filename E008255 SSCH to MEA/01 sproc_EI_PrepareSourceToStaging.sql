USE test_usei964
IF EXISTS (
		SELECT 1
		FROM sys.procedures
		WHERE NAME = 'sproc_EI_PrepareSourceToStaging'
		)
BEGIN
	DROP PROCEDURE dbo.sproc_EI_PrepareSourceToStaging
END
GO

--CREATE PROCEDURE sproc_EI_PrepareSourceToStaging
--	@P_pmoNumber VARCHAR(100),
--  @P_TemplateBAKFilePath VARCHAR(MAX),
--	@P_DBFilePath VARCHAR(MAX),
--  @P_StgCmdTSqlFilePath VARCHAR(MAX),
--	@P_SourceDBName VARCHAR(125),
--	@P_DestDBName VARCHAR(125), --Must be only DB Name no Instance name attached.
--	@P_DsMergeMastInst VARCHAR(125), --Must be [Server\Instance]
--	@P_StagingDBBackupForProdPath VARCHAR(500),
--	@P_StagingDBBackupForDSPath VARCHAR(500),
--	@P_DestLinkedServer VARCHAR(500),
--	@P_ExecLogFilePath VARCHAR(MAX), -- Path must have \ at last
--	@P_srcBackupType INT, --0 Full+Diff, 1-Diff only
--	@P_srcBackupPath VARCHAR(MAX), -- Path to put .bak file of source db
--	@P_srcRestorePath VARCHAR(MAX) -- Path of Data and Log file of Source db
--	@P_PagerDutyOperator VARCHAR(50) -- Value must be from FacAcqPagerTS1 ..To.. FacAcqPagerTS8
--AS
BEGIN
	DECLARE @vPMONumber VARCHAR(125)
		,@vPMOGroupID INT
		,@vStgDbName VARCHAR(125)
		,@vSourceDBName VARCHAR(125)
		,@vDestDBName VARCHAR(125)
		,@vJobName VARCHAR(125)
		,@vDestJobName VARCHAR(125)
		,@vJobDesc VARCHAR(250)
		,@SqlCommand NVARCHAR(MAX)
		,@SqlInsert VARCHAR(MAX)
		,@CmdCommand VARCHAR(MAX)
		,@vTemplateBAKFilePath VARCHAR(MAX)
		,@ServerName VARCHAR(200)
		,@vStagingDBBackupForProdPath VARCHAR(500)
		,@vStagingDBBackupForDSPath VARCHAR(500)
		,@vStagingDBBackupForProdPathWithFile VARCHAR(1000)
		,@vStagingDBBackupForDSPathWithFile VARCHAR(1000)
		,@vDestLinkedServer VARCHAR(500)
		,@vOPENQUERY VARCHAR(4000)
		,@vDestDataPath VARCHAR(500)
		,@vDestLogPath VARCHAR(500)
		,@EmailSubject VARCHAR(1000)
		,@EmailBody VARCHAR(MAX)
		,@vCaseModuletoCopyList VARCHAR(MAX)
		,@vProdRun VARCHAR(1)
		,@vSrcProdServer VARCHAR(200)
		,@vSrcProdDB VARCHAR(100)
		,@vSrcOrgCode VARCHAR(100)
		,@vDstOrgCode VARCHAR(100)
		,@vDstOrgID VARCHAR(100)
		,@vTSConversionServer VARCHAR(125)
		,@vRestore_Job_Server VARCHAR(125)
		,@vSrcUseiCode VARCHAR(100)
		,@ParmDefinition NVARCHAR(MAX)
		,@vBackupScriptFullOut VARCHAR(8000)
		,@vBackupScriptDiffOut VARCHAR(8000)
		,@vRestoreScriptNoRecOut VARCHAR(8000)
		,@vRestoreScriptRecOut VARCHAR(8000)
		,@vPagerDutyOperator VARCHAR(50)
		,@vPagerDutyEmail VARCHAR(100)
		,@vCSVSrcFacID VARCHAR(MAX)
		,@vCSVDstFacID VARCHAR(MAX)
		,@vCaseNo VARCHAR(1000)
		,@vStepName VARCHAR(1000)
		,@vLastStepId INT
		,@vLogFileName VARCHAR(MAX)
		,@vCmdDestLinkedServer VARCHAR(500)
		,@vParts INT = 2
		,@vBackupTSQLOutput VARCHAR(max)
		,@vRestoreTSQLOutput VARCHAR(max)
		,@clientDBSize INT
		,@vServerType CHAR(2)
		,@vFacAcqEmailAddress VARCHAR(max) = N'TSFacAcqConfig@pointclickcare.com'
		,@vToEmailAddress VARCHAR(max) 
		,@Recipient VARCHAR(max)
		,@EmailRecipientsExt VARCHAR(MAX)
		,@if_Restore_w_SP VARCHAR(1)
		,@TS_Resource VARCHAR(50)
		,@vSrcFacId VARCHAR(100)
		,@vDstFacId VARCHAR(100)
		,@vCurrentRunId VARCHAR(100)
		,@vFacRunOrder VARCHAR(100)
		,@vExtEmailSubject VARCHAR(2000);
	DECLARE @outVal TABLE (outVal VARCHAR(100))
	DECLARE @DestDBFilePath TABLE (
		DataPath VARCHAR(1000)
		,LogPath VARCHAR(1000)
		,DataFreeSpaceGB INT
		)
	DECLARE @BackupDetail TABLE (
		[LogicalName] NVARCHAR(128)
		,[PhysicalName] NVARCHAR(260)
		,[Type] CHAR(1)
		,[FileGroupName] NVARCHAR(128)
		,[Size] NUMERIC(20, 0)
		,[MaxSize] NUMERIC(20, 0)
		,[FileID] BIGINT
		,[CreateLSN] NUMERIC(25, 0)
		,[DropLSN] NUMERIC(25, 0)
		,[UniqueID] UNIQUEIDENTIFIER
		,[ReadOnlyLSN] NUMERIC(25, 0)
		,[ReadWriteLSN] NUMERIC(25, 0)
		,[BackupSizeInBytes] BIGINT
		,[SourceBlockSize] INT
		,[FileGroupID] INT
		,[LogGroupGUID] UNIQUEIDENTIFIER
		,[DifferentialBaseLSN] NUMERIC(25, 0)
		,[DifferentialBaseGUID] UNIQUEIDENTIFIER
		,[IsReadOnly] BIT
		,[IsPresent] BIT
		,[TDEThumbprint] VARBINARY(32)
		,[SnapshotURL] NVARCHAR(360)
		)
	DECLARE @LoadEIMaster TABLE (
		[RunId] [int] NOT NULL
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
		,[PreMergeScriptDst] [varchar](max) NULL
		,[ContMerge] [bit] NULL
		,[StagingCompleted] [bit] NULL
		,[SrcEOM] VARCHAR(50) NULL
		)
	DECLARE @ModuletoCopy TABLE (
		ID INT
		,ModuletoCopy VARCHAR(25)
		)

	DECLARE @action_codes_mapping_table varchar(500)
	DECLARE @status_codes_mapping_table varchar(500)
	DECLARE @upload_categories_mapping_table varchar(500)
	DECLARE @prefix_for_UDA varchar(50)
	DECLARE @prefix_for_Care_Plan_Library varchar(50)
	DECLARE @CP_Library_to_exclude_from_prefix varchar(200)
	DECLARE @suffix_for_order_libraries varchar(50)
	DECLARE @suffix_for_sec_user_loginname varchar(50)
	DECLARE @csv_pick_list_ids varchar(500)
	DECLARE @current_resident_as_of varchar(20)
	DECLARE @hotlisted_external_facilities_only varchar(1)
	DECLARE @filter_mds_by_date varchar(20)
	DECLARE @if_include_payer_mapping varchar(1)
	DECLARE @room_rate_type_mapping_table varchar(500)
	DECLARE @Medicare_A_in_destination varchar(20)
	DECLARE @if_as_ard_adl_keys_post_insert varchar(1)		--- added Jan 18 2022, by Amardeep

	--SET @vPMONumber=@P_pmoNumber
	--SET @vTemplateBAKFilePath=@p_TemplateBAKFilePath
	--SET @vSourceDBName=@P_SourceDBName
	--SET @vDestDBName=@P_DestDBName
	--SET @vStagingDBBackupForProdPath=@P_StagingDBBackupForProdPath
	--SET @vStagingDBBackupForDSPath=@P_StagingDBBackupForDSPath
	--SET @vDestLinkedServer=@P_DestLinkedServer
	--SET @vsrcBackupType=@P_srcBackupType
	--SET @vsrcBackupPath=@P_srcBackupPath
	--SET @vsrcRestorePath=@P_srcRestorePath
	--SET @vPagerDutyOperator=@P_PagerDutyOperator
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	
	/*------PMO Group ID, make sure the PMO Number set up is unique------*/
	SET @vPMOGroupID = 1817

	/*------Job Fail Email Recipient------*/
	SET @vToEmailAddress = N'dinesh.gunalapan@pointclickcare.com;TSFacAcqConfig@pointclickcare.com'

	/*------External Email Notification Recipient, for start of the run, email address only, semicolon separated------*/
	SET @EmailrecipientsExt ='linda.k@pointclickcare.com;MarioM@sunnysiderehab.org;Mercia@sunnysiderehab.org;Administrator@sunnysiderehab.org;Medicalrecords@sunnysiderehab.org;Mweston@LTCconsulting.com;BOM@sunnysiderehab.org;Ashlee.Moss@pointclickcare.com;Wendy.Panganiban@pointclickcare.com;Sarah.D@pointclickcare.com;rina.p@pointclickcare.com;nigel.liang@pointclickcare.com;theresa.w@pointclickcare.com;TSFacAcqConfig@pointclickcare.com'
	/*------External Email Notification Subject, for start of the run, will use default if left empty------*/
	SET @vExtEmailSubject = ''

	/*------Mapping Backup Tables, will not be applied if left empty, please do not create table name with single quotes------*/
	SET @action_codes_mapping_table			= '[vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E008255_ActionCodes$]'
	SET @status_codes_mapping_table			= '[vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E008255_StatusCodes$]'
	SET @upload_categories_mapping_table	= '[vmuspassvtsjob1.pccprod.local].FacAcqMapping.[dbo].[E008255_UploadCategories$]'
	SET @room_rate_type_mapping_table		='[vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[E008255_RoomRateType$]'
	/*------Medicare A id from payer mapping, this is used in room rate type post update------*/
	SET @Medicare_A_in_destination			= '4'

	/*------If 'Y', payer mapping is inculuded and with naming convention, on FacAcqMapping: 
			PMO[PMO_NUMBER]_EICase[CASE_NUMBER]_payermapping_fac_[SRC_FAC_ID]_to_[DST_FAC_ID]-----*/
	SET @if_include_payer_mapping			= 'Y'

	SET @prefix_for_UDA						= 'SSCH-'
	SET @prefix_for_Care_Plan_Library		= 'SSCH-'
	SET @CP_Library_to_exclude_from_prefix	= '8,9'
	SET @suffix_for_order_libraries			= '_'
	SET @suffix_for_sec_user_loginname		= 'SSCH'

	/*------For AUTO-PRE, to filer pick_list_id for CCRS issue, comma separated-----*/
	SET @csv_pick_list_ids					= '-70,300,301,302,303,304,305,306,307,308,309,310,311,312,313,314,315,316,317,318,319,320,321,322,323,324,325,326,327,328,329,330,331,332,333,334,335,336,337,338,340,342,344,345,346,348,349,351,352,353,354,355,360,361,362,363,364,365,366,367,713,714,1000348,1000661,1000662,1000663,1000664'

	/*------For AUTO-PRE, if current resident only, leave empty ('') if all resident, use date (e.g. '2020-01-01') if needed-----*/
	SET @current_resident_as_of				= ''

	/*------For AUTO-PRE, if hotlisted external facilities only, use 'Y'-----*/
	SET @hotlisted_external_facilities_only	= 'N'

	/*------For AUTO-PRE, if filter MDS by date, leave empty ('') if not applicable, use date (e.g. '2020-01-01') if needed-----*/
	SET @filter_mds_by_date					= ''
	
	/*------For AUTO-PRE, and Post Merge on stagingdb, if doing post insert, set to Y -----*/
    SET @if_as_ard_adl_keys_post_insert                    = 'Y'	--- added Jan 18 2022, by Amardeep


	/*------Production Run------*/
	SET @vProdRun = 'Y'
	/*------When Production Run, If use SP to restore Source Database------*/
	SET @if_Restore_w_SP = 'Y'
	/*------Number of files for source backup------*/
	SET @vParts = 8
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
	IF (@Medicare_A_in_destination is null or @Medicare_A_in_destination = '') BEGIN SET @Medicare_A_in_destination = '4' END
	/*------No need to change the following parameters------*/
	------/*------Copy of Template DB, make sure the folder and date are valid------*/
	------SET @vTemplateBAKFilePath = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/template/FULL_us_template_pccsingle_tmpltOH.bak'
	/*------Folder for final staging to destination backup copy------*/
	SET @vStagingDBBackupForProdPath = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups'
	/*------Folder for staging backup copy between facilities------*/
	SET @vStagingDBBackupForDSPath = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/technicalservices/StagingDBBackups'
	SET @vTSConversionServer = 'vmuspassvtsjob1.pccprod.local'
	SET @vRestore_Job_Server = 'vmuspassvjob001.pccprod.local'
	SET @TS_Resource = replace(replace(replace(ORIGINAL_LOGIN(),'@pointclickcare.com',''),'PCCPROD\',''),'@pointclickcarecloud.com','')
	SET @ServerName = @@SERVERNAME
	SET @SqlCommand = N'SELECT top 1 @vSourceDBName = databasename FROM' + CHAR(13) + CHAR(10) + '[' + @vTSConversionServer + '].[ds_tasks].[dbo].[TS_global_organization_master] WITH (NOLOCK)' + CHAR(13) + CHAR(10) + 'WHERE orgcode IN (SELECT TOP 1 srcorgcode' + CHAR(13) + CHAR(10) + 'FROM [' + @vTSConversionServer + '].ds_merge_master.dbo.LoadEIMaster_Automation WITH (NOLOCK)' + CHAR(13) + CHAR(10) + 'WHERE pmo_group_id = ''' + CONVERT(VARCHAR, @vPMOGroupID) + ''')
	AND deleted = ''N'''

	EXEC sp_executesql @SqlCommand
		,N'@vSourceDBName varchar(500) OUTPUT'
		,@vSourceDBName OUTPUT

	SET @SqlCommand = N'SELECT top 1 ' + CHAR(13) + CHAR(10) + '@vDestDBName = databasename ' + CHAR(13) + CHAR(10) + '
	,@vDestLinkedServer = ''['' + servername + '']''' + CHAR(13) + CHAR(10) + ' FROM [' + @vTSConversionServer + '].[ds_tasks].[dbo].[TS_global_organization_master] WITH (NOLOCK)' + CHAR(13) + CHAR(10) + 'WHERE orgcode IN (SELECT TOP 1 dstorgcode FROM [' + @vTSConversionServer + '].ds_merge_master.dbo.LoadEIMaster_Automation WITH(NOLOCK) 
	WHERE pmo_group_id = ''' + CONVERT(VARCHAR, @vPMOGroupID) + ''')
	AND deleted = ''N'''

	EXEC sp_executesql @SqlCommand
		,N'@vDestDBName varchar(500) OUTPUT,@vDestLinkedServer varchar(500) OUTPUT'
		,@vDestDBName OUTPUT
		,@vDestLinkedServer OUTPUT

	SET @vCmdDestLinkedServer = REPLACE(REPLACE(@vDestLinkedServer, '[', ''), ']', '')
	SET @SqlCommand = N'SELECT top 1 @vPMONumber = PMONumber ' + ' from [' + @vTSConversionServer + '].[ds_merge_master].[dbo].[LoadEIMaster_PMO_Groups] EIPMO with (nolock) WHERE EIPMO.PMO_Group_Id=''' + CONVERT(VARCHAR, @vPMOGroupID) + ''''

	EXEC sp_executesql @SqlCommand
		,N'@vPMONumber varchar(500) OUTPUT'
		,@vPMONumber OUTPUT

	IF (CHARINDEX('pccsql', @ServerName) > 0)
	BEGIN
		SET @vServerType = 'MI'
	END
	ELSE
	BEGIN
		SET @vServerType = 'VM'
	END

	IF @vServerType = 'VM'
	BEGIN SET @ServerName = @ServerName + '.pccprod.local' END

	SET @ParmDefinition = N'@BackupTSQLOutput VARCHAR(8000) OUTPUT,
													@RestoreTSQLOutput VARCHAR(8000) OUTPUT'

	BEGIN TRY
		SET NOCOUNT ON
		SET @SqlCommand = NULL
		SET @SqlCommand = 'SELECT EIMF.RunID
						,EIMF.PMO_Group_Id,EIMF.CaseNo
						,EIMF.SrcFacID,EIMF.DstFacID
						,EIMF.SrcOrgCode,EIMF.StgOrgCode
						,EIMF.DstOrgCode,EIMF.MODLIST
						,EIMF.FacilityRunOrder,EIMF.premergescript
						,EIMF.premergescriptsrc,EIMF.PostMergeScript
						,EIMF.PreMergeScriptDst
						,EIMF.ContMerge, EIMF.StagingCompleted,
						(SELECT VALUE FROM ' + @vSourceDBName + '.dbo.configuration_parameter with (nolock)
						WHERE fac_id=EIMF.SrcFacID AND NAME = ''pho_is_using_new_phys_order_form'') SrcEOM
						FROM [' + @vTSConversionServer + '].[ds_merge_master].[dbo].[LoadEIMaster_Automation] EIMF with (nolock)
						WHERE EIMF.PMO_Group_Id=(SELECT TOP 1 EIPMO.PMO_Group_Id
						FROM [' + @vTSConversionServer + '].[ds_merge_master].[dbo].[LoadEIMaster_PMO_Groups] EIPMO with (nolock) WHERE EIPMO.PMO_Group_Id=''' + CONVERT(VARCHAR, @vPMOGroupID) + ''')'

		------------------FROM [' + @vTSConversionServer + '].[ds_merge_master].[dbo].[LoadEIMaster_PMO_Groups] EIPMO WHERE EIPMO.PMONumber=''' + CONVERT(VARCHAR, @vPMONumber) + ''')'
		----PRINT @SqlCommand
		INSERT @LoadEIMaster
		EXEC (@SqlCommand)

		IF EXISTS (SELECT 1 FROM @LoadEIMaster WHERE SrcEOM = 'N' or SrcEOM is NULL)
			BEGIN
			PRINT '--------------------------------------------------------------------------------------------------------'
			PRINT '----!!!There is Legacy Order Interface in Source. Check if you need to disable EOM in Destination!!!----'
			select 'EOM is N in source, please check fac_id: ' + convert(varchar,isnull(STUFF((SELECT ',' + convert(varchar,SrcFacID) from @LoadEIMaster WHERE (SrcEOM = 'N' or SrcEOM is null) FOR XML PATH ('')), 1, 1, ''),'')) as 'Src_EOM_is_N'
			PRINT '--------------------------------------------------------------------------------------------------------'
			END

		--Get CaseNo
		SELECT TOP 1 @vCaseNo = CaseNo
		FROM @LoadEIMaster ORDER BY FacilityRunOrder

		--Get SrcUseiCode
		SELECT TOP 1 @vSrcUseiCode = SrcOrgCode
		FROM @LoadEIMaster

		--Get SrcOrgCode
		SELECT @vCSVSrcFacID = COALESCE(@vCSVSrcFacID + ',', '') + CONVERT(VARCHAR, SrcFacID)
		FROM @LoadEIMaster

		SET @SqlCommand = 'SELECT TOP 1 OrgCode' + CHAR(13) + CHAR(10) + 'FROM [' + @vTSConversionServer + '].[ds_tasks].[dbo].[TS_global_organization_master] WITH (NOLOCK)' + CHAR(13) + CHAR(10) + 'WHERE DELETED = ''N''' + CHAR(13) + CHAR(10) + 'AND OrgId =(SELECT TOP 1 ORG_ID ' + CHAR(13) + CHAR(10) + 'FROM ' + @vSourceDBName + '.dbo.facility WHERE fac_id IN (' + @vCSVSrcFacID + '))'

		INSERT @outVal
		EXEC (@SqlCommand)

		SET @vSrcOrgCode = ISNULL((
					SELECT TOP 1 outVal
					FROM @outVal
					), '')

		DELETE
		FROM @outVal

		--Get SrcProdServer
		SET @SqlCommand = 'SELECT TOP 1 ''['' + ServerName + '']''' + CHAR(13) + CHAR(10) + 'FROM [' + @vTSConversionServer + '].[ds_tasks].[dbo].[TS_global_organization_master] WITH (NOLOCK)' + CHAR(13) + CHAR(10) + 'WHERE DELETED = ''N''' + CHAR(13) + CHAR(10) + 'AND OrgId =(SELECT TOP 1 ORG_ID ' + CHAR(13) + CHAR(10) + 'FROM ' + @vSourceDBName + '.dbo.facility WHERE fac_id IN (' + @vCSVSrcFacID + '))'

		INSERT @outVal
		EXEC (@SqlCommand)

		SET @vSrcProdServer = ISNULL((
					SELECT TOP 1 outVal
					FROM @outVal
					), '')

		DELETE
		FROM @outVal

		--Get SrcProdDB
		SET @SqlCommand = 'SELECT TOP 1 DatabaseName' + CHAR(13) + CHAR(10) + 'FROM [' + @vTSConversionServer + '].[ds_tasks].[dbo].[TS_global_organization_master] WITH (NOLOCK)' + CHAR(13) + CHAR(10) + 'WHERE DELETED = ''N''' + CHAR(13) + CHAR(10) + 'AND OrgId =(SELECT TOP 1 ORG_ID ' + CHAR(13) + CHAR(10) + 'FROM ' + @vSourceDBName + '.dbo.facility WHERE fac_id IN (' + @vCSVSrcFacID + '))'

		INSERT @outVal
		EXEC (@SqlCommand)

		SET @vSrcProdDB = ISNULL((
					SELECT TOP 1 outVal
					FROM @outVal
					), '')

		DELETE
		FROM @outVal

		
		SELECT @vCSVDstFacID = COALESCE(@vCSVDstFacID + ',', '') + CONVERT(VARCHAR, DstFacID)
		FROM @LoadEIMaster

		SELECT TOP 1 @vDstOrgCode = DstOrgCode
		FROM @LoadEIMaster

		SET @vStgDbName = NULL

		SELECT TOP 1 @vStgDbName = StgOrgCode
		FROM @LoadEIMaster

		------DB Version, source
		SET @SqlCommand = 'SELECT TOP 1 db_version_code' + CHAR(13) + CHAR(10) + 'FROM [' + @vSourceDBName + '].[dbo].[pcc_db_version] WITH (NOLOCK)' + CHAR(13) + CHAR(10) + 'order by db_upload_date desc'

		INSERT @outVal 
		EXEC (@SqlCommand)

		SELECT TOP 1 @vSourceDBName + ' - DB Version: ' + outVal as Source_DB_Version FROM @outVal
		DELETE FROM @outVal
		------DB Version, staging
		SET @SqlCommand = 'SELECT TOP 1 db_version_code' + CHAR(13) + CHAR(10) + 'FROM [' + @vStgDbName + '].[dbo].[pcc_db_version] WITH (NOLOCK)' + CHAR(13) + CHAR(10) + 'order by db_upload_date desc'

		INSERT @outVal 
		EXEC (@SqlCommand)

		SELECT TOP 1 + @vStgDbName + ' - DB Version: ' + outVal as Staging_DB_Version FROM @outVal
		DELETE FROM @outVal
		------DB Version, destination
		SET @SqlCommand = 'SELECT TOP 1 db_version_code' + CHAR(13) + CHAR(10) + 'FROM ' + @vDestLinkedServer + '.' + @vDestDBName + '.[dbo].[pcc_db_version] WITH (NOLOCK)' + CHAR(13) + CHAR(10) + 'order by db_upload_date desc'

		INSERT @outVal 
		EXEC (@SqlCommand)

		SELECT TOP 1 + @vDestDBName + ' - DB Version: ' + outVal as Destination_DB_Version FROM @outVal
		DELETE FROM @outVal

				------Display Module Lists
		SET @SqlCommand = '
              SELECT DISTINCT RunID,CaseNo
              ,srcfacid,srcf.deleted as srcfacdeleted,srcf.name as srcfacname,srcf.address1 as srcfacaddress
              ,dstfacid,dstf.deleted as dstfacdeleted,dstf.name as dstfacname,dstf.address1 as dstfacaddress
                     ,STUFF((SELECT '', '' + ShortDescription + '': '' + LongDescription
                                  FROM (SELECT baseall.RunID,baseall.caseno,baseall.srcfacid,baseall.dstfacid,baseall.ShortDescription,baseall.LongDescription
                                                ,CASE WHEN ModIncluded.items IS NULL THEN 0     ELSE 1 END AS ModIncluded
                                         FROM (SELECT a.RunID,a.caseno,a.srcfacid,a.dstfacid,b.ShortDescription,b.LongDescription
                                                FROM [' + @vTSConversionServer + '].[ds_merge_master].dbo.[LoadEIMaster_Automation] a WITH (NOLOCK)
                                                CROSS APPLY [' + @vTSConversionServer + '].[ds_merge_master].dbo.mergeModuleMaster_Test b WITH (NOLOCK)
                                                --CROSS APPLY [' + @vTSConversionServer + '].[ds_merge_master].dbo.mergeModuleMaster b  WITH (NOLOCK)
                                                WHERE PMO_Group_Id = ' + CONVERT(VARCHAR,@vPMOGroupID) + ') baseall
                                         LEFT JOIN (SELECT a.RunID,a.caseno,a.srcfacid,a.dstfacid,b.items
                                                FROM [' + @vTSConversionServer + '].[ds_merge_master].dbo.[LoadEIMaster_Automation] a WITH (NOLOCK)
                                                CROSS APPLY dbo.Split(a.modlist, '','') b
                                                WHERE PMO_Group_Id = ' + CONVERT(VARCHAR,@vPMOGroupID) + ') ModIncluded ON baseall.RunID = ModIncluded.RunID
                                                AND baseall.ShortDescription = ModIncluded.items) x
                                  WHERE ModIncluded = 1 AND (RunID = z.RunID)     FOR XML PATH('''')), 1, 2, '''') AS ModIncluded
                     ,STUFF((SELECT '', '' + ShortDescription + '': '' + LongDescription
                                  FROM (SELECT baseall.RunID,baseall.caseno,baseall.srcfacid,baseall.dstfacid,baseall.ShortDescription,baseall.LongDescription
                                                ,CASE WHEN ModIncluded.items IS NULL THEN 0 ELSE 1 END AS ModIncluded
                                         FROM (SELECT a.RunID,a.caseno,a.srcfacid,a.dstfacid,b.ShortDescription,b.LongDescription
                                                FROM [' + @vTSConversionServer + '].[ds_merge_master].dbo.[LoadEIMaster_Automation] a WITH (NOLOCK)
                                                CROSS APPLY [' + @vTSConversionServer + '].[ds_merge_master].dbo.mergeModuleMaster_Test b WITH (NOLOCK)
                                                --CROSS APPLY [' + @vTSConversionServer + '].[ds_merge_master].dbo.mergeModuleMaster b  WITH (NOLOCK)
                                                WHERE PMO_Group_Id = ' + CONVERT(VARCHAR,@vPMOGroupID) + ') baseall
                                         LEFT JOIN (SELECT a.RunID,a.caseno,a.srcfacid,a.dstfacid,b.items
                                                FROM [' + @vTSConversionServer + '].[ds_merge_master].dbo.[LoadEIMaster_Automation] a WITH (NOLOCK)
                                                CROSS APPLY dbo.Split(a.modlist, '','') b
                                                WHERE PMO_Group_Id = ' + CONVERT(VARCHAR,@vPMOGroupID) + '
                                                ) ModIncluded ON baseall.RunID = ModIncluded.RunID AND baseall.ShortDescription = ModIncluded.items
                                         ) y    WHERE ModIncluded = 0 AND (RunID = z.RunID) FOR XML PATH('''')), 1, 2, '''') AS ModExcluded
              FROM (SELECT baseall.RunID,baseall.caseno,baseall.srcfacid,baseall.dstfacid,baseall.ShortDescription,baseall.LongDescription
                           ,CASE WHEN ModIncluded.items IS NULL THEN 0     ELSE 1 END AS ModIncluded
                     FROM (SELECT a.RunID,a.caseno,a.srcfacid,a.dstfacid,b.ShortDescription,b.LongDescription
                           FROM [' + @vTSConversionServer + '].[ds_merge_master].dbo.[LoadEIMaster_Automation] a WITH (NOLOCK)
                           CROSS APPLY [' + @vTSConversionServer + '].[ds_merge_master].dbo.mergeModuleMaster_Test b WITH (NOLOCK)
                           --CROSS APPLY [' + @vTSConversionServer + '].[ds_merge_master].dbo.mergeModuleMaster b  WITH (NOLOCK)
                           WHERE PMO_Group_Id = ' + CONVERT(VARCHAR,@vPMOGroupID) + ') baseall
                     LEFT JOIN (SELECT a.RunID,a.caseno,a.srcfacid,a.dstfacid,b.items
                           FROM [' + @vTSConversionServer + '].[ds_merge_master].dbo.[LoadEIMaster_Automation] a WITH (NOLOCK)
                           CROSS APPLY dbo.Split(a.modlist, '','') b
                           WHERE PMO_Group_Id = ' + CONVERT(VARCHAR,@vPMOGroupID) + ') ModIncluded ON baseall.RunID = ModIncluded.RunID AND baseall.ShortDescription = ModIncluded.items
                     ) z 
                     LEFT JOIN [' + @vSourceDBName + '].[dbo].[facility] srcf WITH (NOLOCK) on z.srcfacid = srcf.fac_id
                     LEFT JOIN '  + @vDestLinkedServer + '.' + @vDestDBName + '.[dbo].[facility] dstf WITH (NOLOCK) on z.dstfacid = dstf.fac_id
                     order by RunID'

		
		EXEC (@SqlCommand)

		------OrgID, destination
		SET @SqlCommand = 'SELECT TOP 1 org_id' + CHAR(13) + CHAR(10) + 'FROM ' + @vDestLinkedServer + '.' + @vDestDBName + '.[dbo].[facility] WITH (NOLOCK)' + CHAR(13) + CHAR(10)

		INSERT @outVal 
		EXEC (@SqlCommand)

		SELECT TOP 1 @vDstOrgID = outVal FROM @outVal
		DELETE FROM @outVal

		IF @vStgDbName IS NOT NULL
		BEGIN
			PRINT '******************'
			PRINT 'Step 0: Create Job'
			PRINT '******************'

			SET @vJobName = 'EI_Prepare_Staging__' + CONVERT(VARCHAR, @vPMONumber)
			SET @vJobDesc = 'Job to prepare Staging DB Repo for EI PMO: ' + CONVERT(VARCHAR, @vPMONumber)

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
			

			PRINT '************************************'
			PRINT 'Step 1: Email Notification Project Start'
			PRINT '************************************'

			IF LEN(@vExtEmailSubject) > 1
				BEGIN SET @EmailSubject = @vExtEmailSubject END
				ELSE
				BEGIN SET @EmailSubject = 'Scheduled Data Copy ' + CONVERT(VARCHAR, DATENAME(month, GETDATE())) + ' ' + CONVERT(VARCHAR, DATENAME(DAY, GETDATE())) + ', PMO - ' + CONVERT(VARCHAR, @vPMONumber) END
		
			SET @EmailBody = 'Hi All,</br></br> Data Copy for Org ' + UPPER(@vDstOrgCode) + ' is starting now.</br></br></br>Thanks,</br>' + CHAR(13) + CHAR(10) + 'Facility Acquisition Team'
			SET @SqlCommand = NULL
			SET @SqlCommand = 'EXEC msdb.dbo.sp_send_dbmail @recipients =''' + @EmailrecipientsExt + ''',' + CHAR(13) + CHAR(10) + '@subject=''' + @EmailSubject + ''',' + CHAR(13) + CHAR(10) + '@body=''' + @EmailBody + ''',' + CHAR(13) + CHAR(10) + '@body_format=''HTML'''

			EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
			,@step_name = 'Email Notification Project Start'
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

			SET @vStagingDBBackupForDSPath = @vStagingDBBackupForDSPath + '/PMOGroup' + LTRIM(rtrim(str(@vPMOGroupID)))

			IF @vProdRun = 'Y'
			BEGIN
				PRINT '****************************************'
				PRINT 'Prepare Source Backup and Restore Script'
				PRINT '****************************************'

				IF @if_Restore_w_SP = 'Y' and @vServerType <> 'VM'
				BEGIN
					PRINT '***************************'
					PRINT 'Step 2: Setup Source Restore with SP'
					PRINT '***************************'
				SET @SqlCommand = 'IF EXISTS(select * from sys.databases where name=''' + @vSourceDBName + ''') BEGIN DROP DATABASE ' + @vSourceDBName + ' END' + CHAR(13) + CHAR(10)  + CHAR(13) + CHAR(10) 
				SET @SqlCommand = @SqlCommand + 'WAITFOR DELAY ''00:05:00''' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) 

				SET @SqlCommand 
				= @SqlCommand + 'DECLARE @return_value INT, @vRequestId INT, @error_msg NVARCHAR(max),@restoretime DATETIME = getdate() ' + CHAR(13) + CHAR(10) 
				+ 'EXEC @return_value = [' + @vRestore_Job_Server + '].[azure_restore].[dbo].[create_restore_request] ' + CHAR(13) + CHAR(10)
				+ '@source_instance = ''' + replace(replace(@vSrcProdServer,'[',''),']','') + '''  ' + CHAR(13) + CHAR(10)
				+ ',@source_Database_name = ''' + @vSrcProdDB + ''' ' + CHAR(13) + CHAR(10)
				+ ',@destination_instance = ''' + @@servername + '''' + CHAR(13) + CHAR(10)
				+ ',@destination_database_name = ''' + @vSourceDBName + '''' + CHAR(13) + CHAR(10)
				+ ',@point_in_time = @restoretime' + CHAR(13) + CHAR(10)
				+ ',@requestor = ''' + @TS_Resource + '''' + CHAR(13) + CHAR(10)
				+ ',@requestid = @vRequestId OUTPUT' + CHAR(13) + CHAR(10)

				SET @SqlCommand = @SqlCommand + 'DECLARE @statusout CHAR(1) = NULL, @statusmessageout VARCHAR(2000) = NULL' + CHAR(13) + CHAR(10)

				SET @SqlCommand = @SqlCommand + 'WHILE (1 = 1)' + CHAR(13) + CHAR(10)
				+ ' BEGIN ' + CHAR(13) + CHAR(10)
				+ ' WAITFOR DELAY ''00:02:00''' + CHAR(13) + CHAR(10)
				+ '	EXEC [' + @vRestore_Job_Server + '].[azure_restore].[dbo].[check_status] @requestid = @vRequestId ' + CHAR(13) + CHAR(10)
				+ ',@status = @statusout OUTPUT ' + CHAR(13) + CHAR(10)
				+ ',@status_message = @statusmessageout OUTPUT ' + CHAR(13) + CHAR(10)
				+ '	IF (@statusout NOT IN (''N'',''S'')) ' + CHAR(13) + CHAR(10)
				+ '	BREAK ' + CHAR(13) + CHAR(10)
				+ 'END' + CHAR(13) + CHAR(10)

				SET @SqlCommand = @SqlCommand + 'SELECT @statusout = NULL,@statusmessageout = NULL' + CHAR(13) + CHAR(10)
				+ 'EXEC [' + @vRestore_Job_Server + '].[azure_restore].[dbo].[check_status] @requestid = @vRequestId' + CHAR(13) + CHAR(10)
				+ ',@status = @statusout OUTPUT' + CHAR(13) + CHAR(10)
				+ ',@status_message = @statusmessageout OUTPUT' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
				+ 'IF (@statusout = ''E'' AND @statusout <> ''C'')' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
				+ 'BEGIN SELECT @error_msg = @statusmessageout' + CHAR(13) + CHAR(10)
				+ 'RAISERROR (@error_msg,16,1)' + CHAR(13) + CHAR(10)
				+ 'RETURN; END' + CHAR(13) + CHAR(10)

				SET @SqlCommand = @SqlCommand + 'ELSE IF (@statusout <> ''E'' AND @statusout <> ''C'')' + CHAR(13) + CHAR(10)
				+' BEGIN SELECT @error_msg = ''Error occurred during restore: Invalid status returned.''' + CHAR(13) + CHAR(10)
				+' RAISERROR (@error_msg,16,1)' + CHAR(13) + CHAR(10)
				+' RETURN;END ' + CHAR(13) + CHAR(10)

				EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
					,@step_name = N'Setup Source Restore with SP'
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

				END

			ELSE
				BEGIN
				PRINT '***************************'
				PRINT 'Step 1: Setup Source Backup'
				PRINT '***************************'

				SET @SqlCommand = NULL
				--SET @SqlCommand = 'SELECT @vClientDBSize = CONVERT(DECIMAL(10, 2), (SUM(cast(mf.size AS BIGINT)) * 8 / 1024.00) / 1024.00) ---- Size_GBs
				--				FROM [' + @ServerName + '].master.sys.master_files mf
				--				INNER JOIN [' + @ServerName + '].master.sys.databases d ON d.database_id = mf.database_id
				--				WHERE d.database_id > 4 -- Skip system databases
				--					AND d.name = ''' + @vDestDBName + '''
				--				GROUP BY d.NAME
				--				ORDER BY d.NAME;
				--				'

				----PRINT @SqlCommand
				--EXEC sp_executesql @SqlCommand
				--	,N'@vClientDBSize INT OUTPUT'
				--	,@vClientDBSize = @clientDBSize OUTPUT

				--IF (@clientDBSize >= 200)
				--BEGIN
				--	SET @vParts = 8
				--END
				--ELSE
				--BEGIN
					--SET @vParts = 32
				--END

				SELECT @vBackupTSQLOutput = NULL
					,@vRestoreTSQLOutput = NULL

				--SET @vStagingDBBackupForDSPath = @vStagingDBBackupForDSPath + '/PMOGroup' + LTRIM(rtrim(str(@vPMOGroupID)))
				
				--SET @SqlCommand = 'IF EXISTS(select * from sys.databases where name=''' + @vSourceDBName + ''') BEGIN DROP DATABASE ' + @vSourceDBName + ' END' + CHAR(13) + CHAR(10)  + CHAR(13) + CHAR(10) 
				--SET @SqlCommand = @SqlCommand + 'WAITFOR DELAY ''00:05:00''' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) 

				SET @SqlCommand = 'EXECUTE [' + @vTSConversionServer + '].[ds_tasks].[dbo].[sproc_DBSplitBackup] @dbName = ''' + @vSrcProdDB + '''' + CHAR(13) + CHAR(10) + ',@backupDir = ''' + @vStagingDBBackupForDSPath + '''' + CHAR(13) + CHAR(10) + ',@nParts = ''' + ltrim(rtrim(STR(@vParts))) + '''' + CHAR(13) + CHAR(10) + ',@serverType = ''' + @vServerType + '''' + CHAR(13) + CHAR(10) + ',@PMOGroupID = ''' + ltrim(rtrim(STR(@vPMOGroupID))) + '''' + CHAR(13) + CHAR(10) + ',@CaseNo = ''' + @vCaseNo + '''' + CHAR(13) + CHAR(10) + ',@isDataCopy = ''Y''' + CHAR(13) + CHAR(10) + ',@backupTSQLOutput = @backupTSQLOutput OUTPUT' + CHAR(13) + CHAR(10) + ',@restoreTSQLOutput = @restoreTSQLOutput OUTPUT'

				------PRINT @SqlCommand
				EXEC SP_EXECUTESQL @SqlCommand
					,@ParmDefinition
					,@backupTSQLOutput = @vBackupTSQLOutput OUTPUT
					,@restoreTSQLOutput = @vRestoreTSQLOutput OUTPUT

				--SELECT len(@vBackupTSQLOutput)
				--SELECT len(@vRestoreTSQLOutput)

				IF @vServerType = 'VM' --else, VM, and for VM always just use DIFF since VM is for big DB only and FULL + DIFF is always the choice
					BEGIN
						SET @vBackupTSQLOutput = ISNULL(@vBackupTSQLOutput, '') + ', DIFFERENTIAL'
					END

				SET @vBackupTSQLOutput = replace(@vBackupTSQLOutput,'URL = ''','URL = ''''')
				SET @vBackupTSQLOutput = replace(@vBackupTSQLOutput,'.BAK''','.BAK''''')

				SET @SqlCommand = 'BEGIN TRY' + CHAR(13) + CHAR(10) + ' EXEC ' + @vSrcProdServer + '.master.dbo.sp_executesql N''' + + @vBackupTSQLOutput + '''END TRY' + CHAR(13) + CHAR(10) + ' BEGIN CATCH select ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage END CATCH' + CHAR(13) + CHAR(10)

				EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
					,@step_name = N'Setup Source Backup'
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

				PRINT '****************************'
				PRINT 'Step 2: Setup Source Restore'
				PRINT '****************************'

				SET @vRestoreTSQLOutput = replace(@vRestoreTSQLOutput,'['+@vSrcProdDB+']','['+@vSourceDBName+']') --to correct the restore out put, restoring to test DB

				IF @vServerType = 'VM' --else, VM, and for VM always just use DIFF since VM is for big DB only and FULL + DIFF is always the choice
					BEGIN
						SET @vRestoreTSQLOutput = ISNULL(@vRestoreTSQLOutput, '') + ' WITH RECOVERY '+ CHAR(13) + CHAR(10)
					END

				IF @vServerType <> 'VM' 
					BEGIN
						SET @vRestoreTSQLOutput = 'IF EXISTS(select * from sys.databases where name=''' + @vSourceDBName + ''') BEGIN DROP DATABASE ' + @vSourceDBName + ' END' + CHAR(13) + CHAR(10)  + CHAR(13) + CHAR(10) + 'WAITFOR DELAY ''00:05:00''' + CHAR(13) + CHAR(10)  + CHAR(13) + CHAR(10) + @vRestoreTSQLOutput
					END

				--PRINT @SqlCommand
				EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
					,@step_name = N'Setup Source Restore'
					,@cmdexec_success_code = 0
					,@on_success_action = 3
					,--3 FOR NEXT STEP, 1 FOR QUIT SUCCESS, 2 QUIT WITH FAILURE
					@on_fail_action = 2
					,@retry_attempts = 0
					,@retry_interval = 0
					,@os_run_priority = 0
					,@subsystem = N'TSQL'
					,@command = @vRestoreTSQLOutput
					,@database_name = N'master'
					,@flags = 8
				END
			END

			--PRINT '****************************'
			--PRINT 'Step 3: Restore Tempalate DB'
			--PRINT '****************************'

			--SET @SqlCommand = ''
			----SET @SqlCommand = '/***' + CHAR(13) + CHAR(10)
			----SET @SqlCommand = @SqlCommand + '----TEMPORARY CODE IS COMMENTED BECAUSE CORE SCRIPTS ARE NOT DEPLOYED YET.' + CHAR(13) + CHAR(10)
			--SET @SqlCommand = @SqlCommand + 'RESTORE DATABASE ' + @vStgDbName + + CHAR(13) + CHAR(10) + 'FROM  URL = ''' + @vTemplateBAKFilePath + '''' + CHAR(13) + CHAR(10)

			----+ '***/'
			------PRINT @SqlCommand
			--EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
			--	,@step_name = N'Restore Tempalate DB'
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

			PRINT '*************************************************************'
			PRINT 'Step 6: Execute sproc_facacq_createDataCopyTables on Staging DB'
			PRINT '*************************************************************'

			SET @SqlCommand = NULL
			SET @SqlCommand = ISNULL(@SqlCommand, '') + CHAR(13) + CHAR(10) + 'EXEC [operational].[sproc_facacq_createDataCopyTables] ' + CHAR(13) + CHAR(10) + '@conv_server=''' + @vTSConversionServer + '''' + CHAR(13) + CHAR(10)
			SET @SqlCommand = 'USE ' + @vStgDbName + CHAR(13) + CHAR(10) + @SqlCommand

			--PRINT @SqlCommand
			EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
				,@step_name = N'Create Data Copy Tables on StagingDB'
				,@cmdexec_success_code = 0
				,@on_success_action = 3
				,--3 FOR NEXT STEP, 1 FOR QUIT SUCCESS, 2 QUIT WITH FAILURE
				@on_fail_action = 2
				,@retry_attempts = 0
				,@retry_interval = 0
				,@os_run_priority = 0
				,@subsystem = N'TSQL'
				,@command = @SqlCommand
				,@database_name = @vStgDbName --N'master'
				,@flags = 8

			PRINT '*************************************************************'
			PRINT 'Step 6: Execute sproc_facacq_dropViews on Staging DB'
			PRINT '*************************************************************'

			SET @SqlCommand = NULL
			SET @SqlCommand = ISNULL(@SqlCommand, '') + CHAR(13) + CHAR(10) + 'EXEC [operational].[sproc_facacq_dropViews] ' + CHAR(13) + CHAR(10)
			SET @SqlCommand = 'USE ' + @vStgDbName + CHAR(13) + CHAR(10) + @SqlCommand

			--PRINT @SqlCommand
			EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
				,@step_name = N'Drop Views on StagingDB'
				,@cmdexec_success_code = 0
				,@on_success_action = 3
				,--3 FOR NEXT STEP, 1 FOR QUIT SUCCESS, 2 QUIT WITH FAILURE
				@on_fail_action = 2
				,@retry_attempts = 0
				,@retry_interval = 0
				,@os_run_priority = 0
				,@subsystem = N'TSQL'
				,@command = @SqlCommand
				,@database_name = @vStgDbName --N'master'
				,@flags = 8

			PRINT '*************************************************************'
			PRINT 'Step 6: Execute sproc_facacq_disableTriggers on Staging DB'
			PRINT '*************************************************************'

			SET @SqlCommand = NULL
			SET @SqlCommand = ISNULL(@SqlCommand, '') + CHAR(13) + CHAR(10) + 'EXEC [operational].[sproc_facacq_disableTriggers] ' + CHAR(13) + CHAR(10)
			SET @SqlCommand = 'USE ' + @vStgDbName + CHAR(13) + CHAR(10) + @SqlCommand

			--PRINT @SqlCommand
			EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
				,@step_name = N'Disable triggers in StagingDB'
				,@cmdexec_success_code = 0
				,@on_success_action = 3
				,--3 FOR NEXT STEP, 1 FOR QUIT SUCCESS, 2 QUIT WITH FAILURE
				@on_fail_action = 2
				,@retry_attempts = 0
				,@retry_interval = 0
				,@os_run_priority = 0
				,@subsystem = N'TSQL'
				,@command = @SqlCommand
				,@database_name = @vStgDbName --N'master'
				,@flags = 8

			PRINT '*************************************************************'
			PRINT 'Step 6: Execute sproc_facacq_stagingDisableConstraints on Staging DB'
			PRINT '*************************************************************'

			SET @SqlCommand = NULL
			SET @SqlCommand = ISNULL(@SqlCommand, '') + CHAR(13) + CHAR(10) + 'EXEC [operational].[sproc_facacq_stagingDisableConstraints] ' + CHAR(13) + CHAR(10)
			SET @SqlCommand = 'USE ' + @vStgDbName + CHAR(13) + CHAR(10) + @SqlCommand

			--PRINT @SqlCommand
			EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
				,@step_name = N'Disable Constraints on StagingDB'
				,@cmdexec_success_code = 0
				,@on_success_action = 3
				,--3 FOR NEXT STEP, 1 FOR QUIT SUCCESS, 2 QUIT WITH FAILURE
				@on_fail_action = 2
				,@retry_attempts = 0
				,@retry_interval = 0
				,@os_run_priority = 0
				,@subsystem = N'TSQL'
				,@command = @SqlCommand
				,@database_name = @vStgDbName --N'master'
				,@flags = 8

			PRINT '**********************************************'
			PRINT 'Step 4: Soft Delete Facility on Destination DB'
			PRINT '**********************************************'

			SET @SqlCommand = NULL
			SET @SqlCommand = 'UPDATE ' + @vDestLinkedServer + '.' + @vDestDBName + '.dbo.facility ' + CHAR(13) + CHAR(10) + 'SET deleted = ''Y'',inactive_date = GETDATE() ' + CHAR(13) + CHAR(10) + 'WHERE fac_id IN (' + @vCSVDstFacID + ')'
			SET @SqlCommand = 'USE ' + @vStgDbName + CHAR(13) + CHAR(10) + @SqlCommand

			--PRINT @SqlCommand
			EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
				,@step_name = N'Soft Delete Facility on Destination DB'
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

			PRINT '*************************************************************'
			PRINT 'Step 6: Execute sproc_facacq_dropExistingMappingTables on Staging DB'
			PRINT '*************************************************************'

			SET @SqlCommand = NULL

			SELECT @SqlCommand = ISNULL(@SqlCommand, '') + CHAR(13) + CHAR(10) + 'EXEC [operational].[sproc_facacq_dropExistingMappingTables] ' + CHAR(13) + CHAR(10) + '@dbStag=''' + @vStgDbName + ''',@ModuleToCopy=''' + ML.ITEMS + ''',@prefix=''EICase' + CONVERT(VARCHAR, LM.CaseNo) + ''',@ContinueMerge=''' + CONVERT(VARCHAR, LM.ContMerge) + ''',@conv_server=''' + @vTSConversionServer + '''' + CHAR(13) + CHAR(10)
			FROM @LoadEIMaster LM
			CROSS APPLY Split(LM.ModList, ',') ML
			ORDER BY LM.FacilityRunOrder

			SET @SqlCommand = 'USE ' + @vStgDbName + CHAR(13) + CHAR(10) + @SqlCommand

			--PRINT @SqlCommand
			EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
				,@step_name = N'Drop Existing mapping tables on StagingDB'
				,@cmdexec_success_code = 0
				,@on_success_action = 3
				,--3 FOR NEXT STEP, 1 FOR QUIT SUCCESS, 2 QUIT WITH FAILURE
				@on_fail_action = 2
				,@retry_attempts = 0
				,@retry_interval = 0
				,@os_run_priority = 0
				,@subsystem = N'TSQL'
				,@command = @SqlCommand
				,@database_name = @vStgDbName --N'master'
				,@flags = 8

			PRINT '*************************************************************'
			PRINT 'Step 6: Execute sproc_facacq_cleanEITables on Staging DB'
			PRINT '*************************************************************'

			SET @SqlCommand = NULL

			SELECT @SqlCommand = 'EXEC [operational].[sproc_facacq_cleanEITables] ' + CHAR(13) + CHAR(10)

			SET @SqlCommand = 'USE ' + @vStgDbName + CHAR(13) + CHAR(10) + @SqlCommand

			--PRINT @SqlCommand
			EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
				,@step_name = N'Clean EI Tables'
				,@cmdexec_success_code = 0
				,@on_success_action = 3
				,--3 FOR NEXT STEP, 1 FOR QUIT SUCCESS, 2 QUIT WITH FAILURE
				@on_fail_action = 2
				,@retry_attempts = 0
				,@retry_interval = 0
				,@os_run_priority = 0
				,@subsystem = N'TSQL'
				,@command = @SqlCommand
				,@database_name = @vStgDbName --N'master'
				,@flags = 8

			PRINT '***************************************************'
			PRINT 'Step 7: Execute sproc_facacq_mergeDeleteCaseTables on Staging DB'
			PRINT '***************************************************'

			SET @SqlCommand = NULL

			SELECT @SqlCommand = ISNULL(@SqlCommand, '') + CHAR(13) + CHAR(10) + 'EXEC [operational].[sproc_facacq_mergeDeleteCaseTables] @caseNo=''' + C.CaseNo + ''''
			FROM @LoadEIMaster C
			ORDER BY C.FacilityRunOrder

			SET @SqlCommand = 'USE ' + @vStgDbName + CHAR(13) + CHAR(10) + @SqlCommand

			--PRINT @SqlCommand
			EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
				,@step_name = N'Execute sproc_facacq_mergeDeleteCaseTables on StagingDB'
				,@cmdexec_success_code = 0
				,@on_success_action = 3
				,--3 FOR NEXT STEP, 1 FOR QUIT SUCCESS, 2 QUIT WITH FAILURE
				@on_fail_action = 2
				,@retry_attempts = 0
				,@retry_interval = 0
				,@os_run_priority = 0
				,@subsystem = N'TSQL'
				,@command = @SqlCommand
				,@database_name = @vStgDbName --N'master'
				,@flags = 8

			PRINT '*************************************************'
			PRINT 'Step 8: Execute staging_sp_addcolumn on StagingDB'
			PRINT '*************************************************'

			SET @SqlCommand = NULL
			SET @SqlCommand = 'EXEC [operational].[sproc_facacq_stagingAddColumn] @prefix='''',@conv_server=''' + @vTSConversionServer + ''''
			SET @SqlCommand = 'USE ' + @vStgDbName + CHAR(13) + CHAR(10) + @SqlCommand

			--PRINT @SqlCommand
			EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
				,@step_name = N'Add MultiFac ID column in each Table'
				,@cmdexec_success_code = 0
				,@on_success_action = 3
				,--3 FOR NEXT STEP, 1 FOR QUIT SUCCESS, 2 QUIT WITH FAILURE
				@on_fail_action = 2
				,@retry_attempts = 0
				,@retry_interval = 0
				,@os_run_priority = 0
				,@subsystem = N'TSQL'
				,@command = @SqlCommand
				,@database_name = @vStgDbName --N'master'
				,@flags = 8

			PRINT '***********************************************'
			PRINT 'Step 9: Disable Staging Trigger and Constraints'
			PRINT '***********************************************'

			SET @SqlCommand = NULL
			SET @SqlCommand = 'EXEC [operational].[sproc_facacq_DisableStagingTriggersAndConstraints] @ModuletoCopy='''''
			SET @SqlCommand = 'USE ' + @vStgDbName + CHAR(13) + CHAR(10) + @SqlCommand

			--PRINT @SqlCommand
			EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
				,@step_name = N'Disable Staging Trigger and Constraints'
				,@cmdexec_success_code = 0
				,@on_success_action = 3
				,--3 FOR NEXT STEP, 1 FOR QUIT SUCCESS, 2 QUIT WITH FAILURE
				@on_fail_action = 2
				,@retry_attempts = 0
				,@retry_interval = 0
				,@os_run_priority = 0
				,@subsystem = N'TSQL'
				,@command = @SqlCommand
				,@database_name = @vStgDbName --N'master'
				,@flags = 8

			DECLARE CurCase CURSOR
			FOR
			SELECT CaseNo
				,ModList
			FROM @LoadEIMaster
			ORDER BY FacilityRunOrder ASC

			OPEN CurCase

			FETCH NEXT
			FROM CurCase
			INTO @vCaseNo
				,@vCaseModuletoCopyList

			--Loop Starts Here
			WHILE @@FETCH_STATUS = 0
			BEGIN --Start CurCase
				INSERT @ModuletoCopy
				SELECT ROW_NUMBER() OVER (
						ORDER BY (
								SELECT 0
								)
						) AS RN
					,CASE 
						WHEN items = 'E2a'
							THEN 'E2'
						WHEN items IN (
								'E7a'
								,'E7b'
								,'E7c'
								,'E7d'
								,'E7e'
								)
							THEN 'E7'
						ELSE items
						END ModuletoCopy
				FROM SPLIT(@vCaseModuletoCopyList, ',')

				IF (
						SELECT COUNT(1)
						FROM @ModuletoCopy
						WHERE ModuletoCopy LIKE 'E12%'
						) > 1
				BEGIN
					DELETE
					FROM @ModuletoCopy
					WHERE ModuletoCopy = 'E12a'
				END
						--REMOVE DUPLICATE ModuleToCopy
						;

				WITH CTE_ML
				AS (
					SELECT ROW_NUMBER() OVER (
							PARTITION BY ModuletoCopy ORDER BY ModuletoCopy
							) RND
						,*
					FROM @ModuletoCopy
					)
				DELETE
				FROM CTE_ML
				WHERE RND > 1


				PRINT '***************************************************************'
				PRINT 'Case No: ' + @vCaseNo + ' : Execute PreMergeScriptSrc on Source DB'
				PRINT '***************************************************************'
					
				SELECT @vSrcFacId = LM.SrcFacID, @vDstFacId = LM.DstFacID, @vCurrentRunId = LM.RunId, @vFacRunOrder = LM.FacilityRunOrder
				FROM @LoadEIMaster LM WHERE LM.CaseNo = @vCaseNo

				SET @vStepName = 'EICase' + @vCaseNo + ' Fac ' + @vSrcFacId + ' to ' + @vDstFacId + ' : PRE    Custom on Source ******' 
				
				SET @SqlCommand = NULL
				SET @SqlCommand = 'use ' + @vSourceDBName +CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)

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
					,@database_name = @vSourceDBName -- N'master'
					,@flags = 8

				PRINT '***************************************************************'
				PRINT 'Case No: ' + @vCaseNo + ' : Execute PreMergeScriptSrc on Source DB'
				PRINT '***************************************************************'

				SET @SqlCommand = NULL
				SET @SqlCommand = 'use ' + @vSourceDBName +CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + 'SET CONTEXT_INFO 0xDC1000000;'+CHAR(13)+CHAR(10)+' SET DEADLOCK_PRIORITY 4;'+CHAR(13)+CHAR(10)+' SET QUOTED_IDENTIFIER ON;'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + 'print (''-- PMO/Engagement: ' + @vPMONumber + ''')'+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + 'print (''-- CaseNo: EICase' + @vCaseNo + ''')'+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + 'print (''-- Source fac_id = ' + @vSrcFacId + ''')'+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + 'print (''-- Destination fac_id = ' + @vDstFacId + ''')'+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + 'print (''-- Destination DB = ' + @vDestLinkedServer + '.' + @vDestDBName + ''')'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_pre_FixContactNumber]	@dest_DB_name = ''' + @vDestLinkedServer + '.' + @vDestDBName + ''''+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_pre_FixContactNumber]	@dest_DB_name = ''' + @vStgDbName + ''''+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_pre_IfDiagnosis]		@dest_database = ''' + @vDestLinkedServer + '.' + @vDestDBName + ''''+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_pre_immunization_fix]	@fac_id = ''' + @vSrcFacId + ''''+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_pre_scoping_CpSecUserAudit]	@fac_id = ''' + @vSrcFacId + ''''+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_pre_scoping_extfac]			@fac_id = ''' + @vSrcFacId + ''''+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_pre_scoping_userfieldtypes]	@fac_id = ''' + @vSrcFacId + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + 'update cp_std_intervention set std_freq_id = NULL from cp_std_intervention where std_freq_id is not NULL and std_freq_id in (0,30)'+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + 'update cp_std_intervention set poc_std_freq_id = NULL from cp_std_intervention where poc_std_freq_id is not NULL'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + 'update as_std_question set pick_list_id = NULL'+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + 'where pick_list_id not in (select pick_list_id from as_std_pick_list) and pick_list_id > 0'+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + 'and std_assess_id in (select std_assess_id from as_std_assessment where deleted = ''Y'')'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)

				IF LEN(@action_codes_mapping_table) > 1
				BEGIN SET @SqlCommand = @SqlCommand + 'ALTER INDEX census_codes__facId_tableCode_shortDesc_IDX ON dbo.census_codes DISABLE;'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_pre_mappingCensusCode]'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + '@mapping_table_name = ''' + @action_codes_mapping_table + ''','+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + '@dest_database = ''' + @vDestLinkedServer + '.' + @vDestDBName + ''','+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + '@src_fac_id = ''' + @vSrcFacId + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END
				
				IF LEN(@status_codes_mapping_table) > 1
					BEGIN SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_pre_mappingCensusCode]'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + '@mapping_table_name = ''' + @status_codes_mapping_table + ''','+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + '@dest_database = ''' + @vDestLinkedServer + '.' + @vDestDBName + ''','+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + '@src_fac_id = ''' + @vSrcFacId + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END

				IF LEN(@upload_categories_mapping_table) > 1
					BEGIN SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_pre_mappingUploadCategory]'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + '@mapping_table_name = ''' + @upload_categories_mapping_table + ''','+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + '@dest_database = ''' + @vDestLinkedServer + '.' + @vDestDBName + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END

				IF EXISTS(SELECT 1 FROM @LoadEIMaster WHERE (',' + ModList + ',') LIKE '%,E7c,%' and RunId = @vCurrentRunId)
					BEGIN SET @SqlCommand = @SqlCommand + 'PRINT ''--Copying UDA'''+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_pre_scoping_IfCopyUDA]		@fac_id = ''' + @vSrcFacId + ''''+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_pre_IfUDA_DummyUDAScoping]	@source_fac_id = ''' + @vSrcFacId + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)

						IF @vFacRunOrder = '1' and LEN(@prefix_for_UDA) >= 1
							BEGIN SET @SqlCommand = @SqlCommand + 'PRINT ''--Adding UDA prefix'''+CHAR(13)+CHAR(10)
								SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_pre_ifMergeUDA_01_prefix] @prefix = ''' + @prefix_for_UDA + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)	END

						IF @vFacRunOrder = '1' and EXISTS (select 1 from @LoadEIMaster where FacilityRunOrder <> '1')
							BEGIN SET @SqlCommand = @SqlCommand + 'PRINT ''--UDA Merge pick list'''+CHAR(13)+CHAR(10)
								SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_pre_ifMergeUDA_02_as_std_pick_list] @NSCaseNumber = ''EICase' + @vCaseNo + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END
					END

				IF EXISTS(SELECT 1 FROM @LoadEIMaster WHERE (',' + ModList + ',') LIKE '%,E9,%' and RunId = @vCurrentRunId)				
					BEGIN SET @SqlCommand = @SqlCommand + 'PRINT ''--Copying PN'''+CHAR(13)+CHAR(10)
						SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_pre_scoping_pn_type_and_template] @fac_id = ''' + @vSrcFacId + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)	END
				
				IF EXISTS(SELECT 1 FROM @LoadEIMaster WHERE (',' + ModList + ',') LIKE '%,E12b,%' and RunId = @vCurrentRunId and LEN(@prefix_for_Care_Plan_Library) >= 1)
					BEGIN SET @SqlCommand = @SqlCommand + 'PRINT ''--Copying CP Library'''+CHAR(13)+CHAR(10)
						SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_pre_prefix_care_plan_library]'+CHAR(13)+CHAR(10)
						SET @SqlCommand = @SqlCommand + '@fac_id = ''' + @vSrcFacId + ''''+CHAR(13)+CHAR(10)
						SET @SqlCommand = @SqlCommand + ',@prefix = ''' + @prefix_for_Care_Plan_Library + ''''+CHAR(13)+CHAR(10)
						SET @SqlCommand = @SqlCommand + ',@destDB = ''' + @vDestLinkedServer + '.' + @vDestDBName + ''''+CHAR(13)+CHAR(10)
						SET @SqlCommand = @SqlCommand + ',@destfacid = ''' + @vDstFacId + ''''+CHAR(13)+CHAR(10)
						SET @SqlCommand = @SqlCommand + ',@libexclude = ''' + @CP_Library_to_exclude_from_prefix + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END
				
				IF LEN (@suffix_for_sec_user_loginname) >= 1
					BEGIN SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_pre_ChangeLoginname] '+CHAR(13)+CHAR(10)
						SET @SqlCommand = @SqlCommand + '@fac_id = ''' + @vSrcFacId + ''','+CHAR(13)+CHAR(10)
						SET @SqlCommand = @SqlCommand + '@suffix = ''' + @suffix_for_sec_user_loginname + ''','+CHAR(13)+CHAR(10)
						SET @SqlCommand = @SqlCommand + '@dest_database = ''' + @vDestLinkedServer + '.' + @vDestDBName + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END

				IF EXISTS(SELECT 1 FROM @LoadEIMaster WHERE (',' + ModList + ',') LIKE '%,E13,%' and RunId = @vCurrentRunId)			
					BEGIN SET @SqlCommand = @SqlCommand + 'PRINT ''--Copying Orders'''+CHAR(13)+CHAR(10)
						SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_pre_CheckShiftUsage] @fac_id = ''' + @vSrcFacId + ''''+CHAR(13)+CHAR(10)

						IF LEN (@suffix_for_order_libraries) >= 1 BEGIN
						SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_pre_IfOrder_StdOrderAndSet]'+CHAR(13)+CHAR(10)
						SET @SqlCommand = @SqlCommand + '@fac_id = ''' + @vSrcFacId + ''','+CHAR(13)+CHAR(10)
						SET @SqlCommand = @SqlCommand + '@dest_database = ''' + @vDestLinkedServer + '.' + @vDestDBName + ''','+CHAR(13)+CHAR(10)
						SET @SqlCommand = @SqlCommand + '@suffix = ''' + @suffix_for_order_libraries + ''''+CHAR(13)+CHAR(10) END

						SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_pre_scoping_PhoOrderType] @fac_id = ''' + @vSrcFacId + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)	END

				IF EXISTS(SELECT 1 FROM @LoadEIMaster WHERE (',' + ModList + ',') LIKE '%,E18,%' and RunId = @vCurrentRunId)					
					BEGIN SET @SqlCommand = @SqlCommand + 'PRINT ''--Copying Trust'''+CHAR(13)+CHAR(10)
						SET @SqlCommand = @SqlCommand + 'update a set a.gl_batch_id = null from ta_transaction a where gl_batch_id is not null'+CHAR(13)+CHAR(10)	END

				SET @vStepName = 'EICase' + @vCaseNo + ' Fac ' + @vSrcFacId + ' to ' + @vDstFacId + ' : PRE    Standard on Source'

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
					,@database_name = @vSourceDBName -- N'master'
					,@flags = 8
	

				PRINT '********************************************************************'
				PRINT 'Case No: ' + @vCaseNo + ' : Execute PreMergeScriptDst on Destination DB'
				PRINT '********************************************************************'

				SET @SqlCommand = NULL

				IF NOT EXISTS(SELECT 1 FROM @LoadEIMaster WHERE (',' + ModList + ',') LIKE '%,E15,%' and RunId = @vCurrentRunId)
					BEGIN
						SET @SqlCommand = 'SET CONTEXT_INFO 0xDC1000000;'+CHAR(13)+CHAR(10)+' SET DEADLOCK_PRIORITY 4;'+CHAR(13)+CHAR(10)+' SET QUOTED_IDENTIFIER ON;'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
						SET @SqlCommand = @SqlCommand + 'exec ' + @vDestLinkedServer + '.' + @vDestDBName + '.[operational].[sproc_facacq_pre_sec_user_GapImport_01_scoping]'+CHAR(13)+CHAR(10)
						SET @SqlCommand = @SqlCommand + '@src_db_location = ''[' + @ServerName + '].' + @vSourceDBName + ''''+CHAR(13)+CHAR(10)
						SET @SqlCommand = @SqlCommand + ',@NS_case_number = ''EICase' + @vCaseNo + ''''+CHAR(13)+CHAR(10)
						SET @SqlCommand = @SqlCommand + ',@src_fac_id = '''+ @vSrcFacId + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)

						SET @SqlCommand = @SqlCommand + 'exec ' + @vDestLinkedServer + '.' + @vDestDBName + '.[operational].[sproc_facacq_pre_sec_user_GapImport_02_Import]'+CHAR(13)+CHAR(10)
						SET @SqlCommand = @SqlCommand + '@src_db_location = ''[' + @ServerName + '].' + @vSourceDBName + ''''+CHAR(13)+CHAR(10)
						SET @SqlCommand = @SqlCommand + ',@NS_case_number = ''EICase' + @vCaseNo + ''''+CHAR(13)+CHAR(10)
						SET @SqlCommand = @SqlCommand + ',@source_fac_id = '''+ @vSrcFacId + ''''+CHAR(13)+CHAR(10)
						SET @SqlCommand = @SqlCommand + ',@suffix = '''+ @suffix_for_sec_user_loginname + ''''+CHAR(13)+CHAR(10)
						SET @SqlCommand = @SqlCommand + ',@destination_org_id = '''+ @vDstOrgID + ''''+CHAR(13)+CHAR(10)
						SET @SqlCommand = @SqlCommand + ',@destination_fac_id = '''+ @vDstFacId + ''''+CHAR(13)+CHAR(10)
						SET @SqlCommand = @SqlCommand + ',@if_is_rerun = ''N'''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
					END
				ELSE
					BEGIN SET @SqlCommand = 'SELECT ''Paste your script here'''END
				
				SET @vStepName = 'EICase' + @vCaseNo + ' Fac ' + @vSrcFacId + ' to ' + @vDstFacId + ' : PRE    on Destination (Sec User Gap Import)'

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
				PRINT 'Case No: ' + @vCaseNo + ' : Execute PreMergeScript on Staging DB'
				PRINT '************************************************************'

				SET @SqlCommand = NULL
				SET @SqlCommand = 'use ' + @vStgDbName +CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + 'SET CONTEXT_INFO 0xDC1000000;'+CHAR(13)+CHAR(10)+' SET DEADLOCK_PRIORITY 4;'+CHAR(13)+CHAR(10)+' SET QUOTED_IDENTIFIER ON;'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
				
				IF LEN(@csv_pick_list_ids) > 1
					BEGIN SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_autopre_CCRSPicklistMergeerror] @csv_pick_list_ids = ''350,' + @csv_pick_list_ids + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END
				ELSE
					BEGIN SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_autopre_CCRSPicklistMergeerror] @csv_pick_list_ids = ''350'''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END

				IF LEN(@current_resident_as_of) > 1
					BEGIN SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_autopre_CurrentResidentOnly] @discharge_date = ''' + @current_resident_as_of + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END

				IF @hotlisted_external_facilities_only = 'Y'
					BEGIN SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_autopre_ChangeQueryFilter] @table_name = ''emc_ext_facilities'''+CHAR(13)+CHAR(10) 
						SET @SqlCommand = @SqlCommand + ',@query_filter = '' and ext_fac_id in (select ext_fac_id from [origDB].ext_facilities where fac_id = [OrigFacId] ) '''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END

				IF @vFacRunOrder > '1' and EXISTS(SELECT 1 FROM @LoadEIMaster WHERE (',' + ModList + ',') LIKE '%,E7c,%' and RunId = @vCurrentRunId)
					BEGIN SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_autopre_ifMergeUDA_04_From2ndFacility]'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END 

				IF LEN(@filter_mds_by_date) > 1
					BEGIN SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_autopre_ifMDSFilterByDate] @assess_ref_date = ''' + @filter_mds_by_date + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END

				IF EXISTS(SELECT 1 FROM @LoadEIMaster WHERE (',' + ModList + ',') LIKE '%,E20,%' and (',' + ModList + ',') NOT LIKE '%,E9,%'  and RunId = @vCurrentRunId)
					BEGIN SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_autopre_CreateDummyMappingTable] @NS_case_number = ''EICase' + @vCaseNo + ''', @table_name = ''pn_progress_note'''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END 

				IF EXISTS(SELECT 1 FROM @LoadEIMaster WHERE (',' + ModList + ',') LIKE '%,E18,%' and RunId = @vCurrentRunId)
					BEGIN SET @SqlCommand = @SqlCommand + 'exec  [operational].[sproc_facacq_autopre_RemoveTableFromDataCopy] ''gl_batch'''+CHAR(13)+CHAR(10)
						SET @SqlCommand = @SqlCommand + 'exec  [operational].[sproc_facacq_autopre_RemoveTableFromDataCopy] ''ta_discharge_option'''+CHAR(13)+CHAR(10)
						SET @SqlCommand = @SqlCommand + 'exec  [operational].[sproc_facacq_autopre_RemoveTableFromDataCopy] ''ta_interest_calculate_method'''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END
				
				SET @SqlCommand = @SqlCommand + 'exec  [operational].[sproc_facacq_autopre_RemoveTableFromDataCopy] ''devprg_hist_medication_landing'''+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + 'exec  [operational].[sproc_facacq_autopre_RemoveTableFromDataCopy] ''devprg_hist_care_period_landing'''+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + 'exec  [operational].[sproc_facacq_autopre_RemoveTableFromDataCopy] ''devprg_hist_diagnosis_landing'''+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + 'exec  [operational].[sproc_facacq_autopre_RemoveTableFromDataCopy] ''devprg_hist_medication_diagnosis_landing'''+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + 'exec  [operational].[sproc_facacq_autopre_RemoveTableFromDataCopy] ''devprg_hist_medication_administration_schedule_landing'''+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + 'exec  [operational].[sproc_facacq_autopre_RemoveTableFromDataCopy] ''pho_phys_order_linked_reason'''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)


				IF @if_as_ard_adl_keys_post_insert = 'Y'		--- added Jan 18 2022, by Amardeep
				BEGIN SET @SqlCommand = @SqlCommand + 'exec  [operational].[sproc_facacq_autopre_RemoveTableFromDataCopy] ''as_ard_adl_keys'''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END


				IF NOT EXISTS(SELECT 1 FROM @LoadEIMaster WHERE (',' + ModList + ',') LIKE '%,E15,%' and RunId = @vCurrentRunId)
				BEGIN SET @SqlCommand = @SqlCommand + 'CREATE TABLE [dbo].[EICase' + @vCaseNo + 'sec_user]([row_id] [int] IDENTITY(1,1) NOT NULL,[src_id] [bigint] NULL,[dst_id] [bigint] NULL,[corporate] [char](1) NULL DEFAULT (''N'') ) ON [PRIMARY]'+CHAR(13)+CHAR(10)
					SET @SqlCommand = @SqlCommand + 'SET IDENTITY_INSERT EICase' + @vCaseNo + 'sec_user ON 
					insert into EICase' + @vCaseNo + 'sec_user (row_id,src_id,dst_id,corporate) 
					select row_id, src_id,dst_id,corporate from ' + @vDestLinkedServer + '.' + @vDestDBName + '.dbo.EICase' + @vCaseNo + 'sec_user 
					SET IDENTITY_INSERT EICase' + @vCaseNo + 'sec_user OFF'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END

				SET @SqlCommand = @SqlCommand + 'UPDATE mergeTablesMaster SET queryfilter = replace(QueryFilter, ''[destDB]'', ''[stagDB]'') FROM mergeTablesMaster WHERE (QueryFilter LIKE ''%prefix%'' AND QueryFilter LIKE ''%destDB%'')'+CHAR(13)+CHAR(10)

				--PRINT @SqlCommand
				SET @vStepName = 'EICase' + @vCaseNo + ' Fac ' + @vSrcFacId + ' to ' + @vDstFacId + ' : AUTO-PRE    on Staging'

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
					,@database_name = @vStgDbName
					--,@database_name = N'master'
					,@flags = 8

				PRINT '*******************************************************************'
				PRINT 'Case No: ' + @vCaseNo + ' : Source to Staging Step3 and Step4 Execution'
				PRINT '*******************************************************************'

				SET @SqlCommand = NULL

				SELECT @SqlCommand = ISNULL(@SqlCommand, '') + CHAR(13) + CHAR(10) + 'IF NOT EXISTS(SELECT 1 FROM ' + @vStgDbName + '.dbo.MERGELOG WITH (NOLOCK) WHERE MSG LIKE ''%MERGEERROR%'' OR MSG LIKE ''%MERGEMAIN%'')' + CHAR(13) + CHAR(10) + 'BEGIN' + CHAR(13) + CHAR(10) + CHAR(9) + 'EXEC [operational].[sproc_facacq_mergeCopyStep3] @ModuletoCopy=''' + CONVERT(VARCHAR(MAX), LM.Module) + ''',' + CHAR(13) + CHAR(10) + CHAR(9) + '@AllModulestoCopy=''' + LM.ModList + ''',@NewDB=''N'',' + CHAR(13) + CHAR(10) + CHAR(9) + '@CaseNo=''' + CAST(LM.CaseNo AS VARCHAR(MAX)) + ''',@ActiveResident=''N'',@DisDate=''''' + CHAR(13) + CHAR(10) + CHAR(9) + 'EXEC [operational].[sproc_facacq_mergeExecuteExtractStep4] @CaseNo=''EICase' + CAST(LM.CaseNo AS VARCHAR(MAX)) + ''',' + CHAR(13) + CHAR(10) + CHAR(9) + '@sourceDB=''' + CAST(@vSourceDBName AS VARCHAR(MAX)) + ''',' + CHAR(9) + '@fac_idToCopy=' + CAST(LM.SrcFacId AS VARCHAR(MAX)) + ',@reg_idToCopy=NULL,@fac_idToCopyTo=' + CAST(LM.DstFacId AS VARCHAR(MAX)) + ',' + CHAR(13) + CHAR(10) + CHAR(9) + '@ModuletoCopy=''' + CAST(LM.Module AS VARCHAR(MAX)) + ''',@AllModulestoCopy=''' + LM.ModList + ''',' 
					+ CHAR(13) + CHAR(10) + CHAR(9) + '@stagingDB=''' + CAST(@vStgDbName AS VARCHAR(MAX)) + ''',@destinationDB=''' + CAST(@vDestLinkedServer AS VARCHAR(MAX)) + '.' + CAST(@vDestDBName AS VARCHAR(MAX)) + ''',' + CHAR(9) + '@RunIDFlag=' + IIF(LM.RN = 1, CONVERT(VARCHAR, 1), CONVERT(VARCHAR, 2)) + ',@ContinueMerge=' + CONVERT(VARCHAR, LM.ContMerge) + '' + CHAR(13) + CHAR(10) + 'END' + CHAR(13) + CHAR(10) + 'ELSE' + CHAR(13) + CHAR(10) + 'BEGIN' + CHAR(13) + CHAR(10) + CHAR(9) + ';THROW 51000,''ERROR: Case No: ' + @vCaseNo + ' : Source to Staging Step3 and Step4 Execution'', 1' + CHAR(13) + CHAR(10) + 'END'
				FROM (
					SELECT ROW_NUMBER() OVER (
							ORDER BY LM.FacilityRunOrder
							) RN
						,LM.FacilityRunOrder
						,LM.CaseNo
						,ML.ModuletoCopy Module
						,LM.SrcFacID
						,LM.DstFacID
						,LM.MODLIST
						,LM.ContMerge
					FROM @LoadEIMaster LM
					CROSS APPLY @ModuletoCopy ML
					WHERE LM.CaseNo = @vCaseNo
					) LM

				SET @SqlCommand = 'USE ' + @vStgDbName + CHAR(13) + CHAR(10) + @SqlCommand
				--PRINT @SqlCommand
				SET @vStepName = 'EICase' + @vCaseNo + ' Fac ' + @vSrcFacId + ' to ' + @vDstFacId + ' : Source to Staging'

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
					,@database_name = @vStgDbName --N'master'
					,@flags = 8

				PRINT '*************************************************************'
				PRINT 'Case No: ' + @vCaseNo + ' : Execute PostMergeScript on Staging DB'
				PRINT '*************************************************************'

				SET @SqlCommand = NULL
				SET @SqlCommand = 'USE ' + @vStgDbName + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) 

				IF EXISTS(SELECT 1 FROM @LoadEIMaster WHERE FacilityRunOrder > '1')
					BEGIN SET @SqlCommand = @SqlCommand + 'SET CONTEXT_INFO 0xDC1000000;'+CHAR(13)+CHAR(10)+' SET DEADLOCK_PRIORITY 4;'+CHAR(13)+CHAR(10)+' SET QUOTED_IDENTIFIER ON;'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
						SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_post_Scoping_SameAsSource]'+CHAR(13)+CHAR(10)
						SET @SqlCommand = @SqlCommand + '@source_db = ''' + @vSourceDBName + ''''+CHAR(13)+CHAR(10)
						SET @SqlCommand = @SqlCommand + ',@NSCaseNumber = ''EICase' + @vCaseNo + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END
				
				IF @if_include_payer_mapping = 'Y'
				BEGIN
				SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_post_UpdatePayer]'+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + '@source_db = ''' + @vSourceDBName + ''''+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + ',@destination_fac_id = ''' + @vDstFacId + ''''+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + ',@NSCaseNumber = ''EICase' + @vCaseNo + ''''+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + ',@payer_mapping_bkp = ''[' + @vTSConversionServer + '].FacAcqMapping.dbo.PMO' + @vPMONumber + '_EICase' + @vCaseNo + '_payermapping_fac_' + @vSrcFacId + '_to_' + @vDstFacId + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END
				
				IF LEN(@room_rate_type_mapping_table) > 1
				BEGIN SET @SqlCommand = @SqlCommand + 'exec [operational].[sproc_facacq_post_UpdateRoomRateType]'+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + '@source_db = ''' + @vSourceDBName + ''''+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + ',@destination_fac_id = ''' + @vDstFacId + ''''+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + ',@NSCaseNumber = ''EICase' + @vCaseNo + ''''+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + ',@roomratetype_mapping_bkp = ''' + @room_rate_type_mapping_table + ''''+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + ',@MA_dst_id = ''' + @Medicare_A_in_destination + ''''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END

	
				IF @if_as_ard_adl_keys_post_insert = 'Y'		 --- added Jan 18 2022, by Amardeep
				BEGIN 
				SET @SqlCommand = @SqlCommand + 'PRINT ''--Post insert for as_ard_adl_keys'''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + 'SELECT * INTO #as_std_assessment' + @vCaseNo + ' FROM EICase' + @vCaseNo + 'as_std_assessment'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + 'SELECT * INTO #as_ard_planner' + @vCaseNo + ' FROM EICase' + @vCaseNo + 'as_ard_planner'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + 'INSERT INTO dbo.as_ard_adl_keys ( ard_planner_id, std_assess_id, question_key, resp_value, source_id, Multi_Fac_Id)'+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + 'SELECT DISTINCT ISNULL(c.dst_id, ard_planner_id), ISNULL(b.dst_id, std_assess_id), [question_key], [resp_value], [source_id], '+ @vDstFacId + ''+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + 'FROM ' + @vSourceDBName + '.dbo.as_ard_adl_keys a  '+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + 'INNER JOIN #as_std_assessment' + @vCaseNo + ' b ON b.src_id = a.std_assess_id'+CHAR(13)+CHAR(10)
				SET @SqlCommand = @SqlCommand + 'INNER JOIN #as_ard_planner' + @vCaseNo + ' c ON c.src_id = a.ard_planner_id'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END
				SET @vStepName = 'EICase' + @vCaseNo + ' Fac ' + @vSrcFacId + ' to ' + @vDstFacId + ' : POST    on Staging (Scoping and Other)'

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
					,@database_name = @vStgDbName ---- N'master'
					,@flags = 8

				PRINT '*************************************************************************************************'
				PRINT 'Case No: ' + @vCaseNo + ' : Backup Staging DB for TS Team Use Only (In Case):- ' + @vStgDbName
				PRINT '*************************************************************************************************'

				SET @SqlCommand = NULL

				SELECT @vBackupTSQLOutput = NULL
					,@vRestoreTSQLOutput = NULL
					,@vParts = 4
				
				--SET @vStagingDBBackupForDSPath = @vStagingDBBackupForDSPath + '/PMOGroup' + LTRIM(rtrim(str(@vPMOGroupID)))
				
				SET @SqlCommand = 'EXECUTE [' + @vTSConversionServer + '].[ds_tasks].[dbo].[sproc_DBSplitBackup] @dbName = ''' + @vStgDbName + '''' + CHAR(13) + CHAR(10) + ',@backupDir = ''' + @vStagingDBBackupForDSPath + '''' + CHAR(13) + CHAR(10) + ',@nParts = ''' + ltrim(rtrim(STR(@vParts))) + '''' + CHAR(13) + CHAR(10) + ',@serverType = ''' + @vServerType + '''' + CHAR(13) + CHAR(10) + ',@PMOGroupID = ''' + ltrim(rtrim(STR(@vPMOGroupID))) + '''' + CHAR(13) + CHAR(10) + ',@CaseNo = ''' + @vCaseNo + '''' + CHAR(13) + CHAR(10) + ',@isDataCopy = ''Y''' + CHAR(13) + CHAR(10) + ',@backupTSQLOutput = @backupTSQLOutput OUTPUT' + CHAR(13) + CHAR(10) + ',@restoreTSQLOutput = @restoreTSQLOutput OUTPUT'

				---- PRINT @SqlCommand
				EXEC SP_EXECUTESQL @SqlCommand
					,@ParmDefinition
					,@backupTSQLOutput = @vBackupTSQLOutput OUTPUT
					,@restoreTSQLOutput = @vRestoreTSQLOutput OUTPUT

				SET @SqlCommand = '--USE ' + @vStgDbName + ' DBCC SHRINKFILE (2,0,TRUNCATEONLY)' + CHAR(13) + CHAR(10) --NIGEL removing shrinking for now
				SET @SqlCommand = @SqlCommand + CHAR(13) + CHAR(10) + 'USE MASTER' + CHAR(13) + CHAR(10) + @vBackupTSQLOutput
				--SET @SqlCommand = 'USE MASTER' + CHAR(13) + CHAR(10) + @SqlCommand
				SET @vStepName = 'EICase' + @vCaseNo + ' Fac ' + @vSrcFacId + ' to ' + @vDstFacId + ' : Backup Staging DB between Facilities'

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

				DELETE
				FROM @ModuletoCopy

				FETCH NEXT
				FROM CurCase
				INTO @vCaseNo
					,@vCaseModuletoCopyList
			END --END OF CURSOR CurCase

			CLOSE CurCase

			DEALLOCATE CurCase

			PRINT '********************************************'
			PRINT 'Backup Staging DB :- ' + @vStgDbName
			PRINT '********************************************'

			SELECT @vBackupTSQLOutput = NULL
				,@vRestoreTSQLOutput = NULL
				,@vParts = 4

			SET @vStagingDBBackupForProdPathWithFile = @vStagingDBBackupForProdPath + '/PMOGroup' + LTRIM(rtrim(str(@vPMOGroupID))) + '/Final'
			IF @vProdRun = 'Y'
				BEGIN SET @vStagingDBBackupForProdPathWithFile = @vStagingDBBackupForProdPathWithFile + '_GoLive' END
			----PRINT @vStagingDBBackupForProdPathWithFile
			SET @SqlCommand = 'EXECUTE [' + @vTSConversionServer + '].[ds_tasks].[dbo].[sproc_DBSplitBackup] @dbName = ''' + @vStgDbName + '''' + CHAR(13) + CHAR(10) + ',@backupDir = ''' + @vStagingDBBackupForProdPathWithFile + '''' + CHAR(13) + CHAR(10) + ',@nParts = ''' + ltrim(rtrim(STR(@vParts))) + '''' + CHAR(13) + CHAR(10) + ',@serverType = ''' + @vServerType + '''' + CHAR(13) + CHAR(10) + ',@PMOGroupID = ''' + ltrim(rtrim(STR(@vPMOGroupID))) + '''' + CHAR(13) + CHAR(10) + ',@CaseNo = ''' + @vCaseNo + '''' + CHAR(13) + CHAR(10) + ',@isDataCopy = ''Y''' + CHAR(13) + CHAR(10) + ',@backupTSQLOutput = @backupTSQLOutput OUTPUT' + CHAR(13) + CHAR(10) + ',@restoreTSQLOutput = @restoreTSQLOutput OUTPUT'

			---- PRINT @SqlCommandlog
			EXEC SP_EXECUTESQL @SqlCommand
				,@ParmDefinition
				,@backupTSQLOutput = @vBackupTSQLOutput OUTPUT
				,@restoreTSQLOutput = @vRestoreTSQLOutput OUTPUT

			----SELECT @vBackupTSQLOutput
			----	,@vRestoreTSQLOutput
			SET @SqlCommand = NULL
			SET @SqlCommand = 'USE MASTER' + CHAR(13) + CHAR(10) + @vBackupTSQLOutput

			--PRINT @SqlCommand
			EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
				,@step_name = N'Final Backup of Staging DB'
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

			SET @vDestJobName = 'EI_Prepare_Destination__' + CONVERT(VARCHAR, @vPMONumber)

			PRINT '*******************************************************'
			PRINT 'Kickoff Staging to Destination Job :- ' + @vDestJobName
			PRINT '*******************************************************'

			SET @SqlCommand = 'EXEC ' + @vDestLinkedServer + '.MSDB.dbo.SP_START_JOB @job_name="' + @vDestJobName + '"'

			--PRINT @SqlCommand
			EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId
				,@step_name = N'Kickoff Staging to Destination Job'
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

			SET @Recipient = iif(@vProdRun = 'Y', @vPagerDutyEmail, @vToEmailAddress)
			SET @SqlCommand = 'EXEC [operational].[sproc_facacq_sendEmailNotification] @Recipient = ''' + @Recipient + '''
					,@BlindCopyRecipients = ''' + @vFacAcqEmailAddress + '''
					,@JobName = ''' + @vJobName + ' ''
					,@ServerName = ''' + quotename(@ServerName) + ''''
			SET @SqlCommand = 'USE ' + @vStgDbName + CHAR(13) + CHAR(10) + @SqlCommand

			-- PRINT @SqlCommand
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
				,@database_name = @vStgDbName --N'master'
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

		END
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


--E14: Security Roles, E15: Security Users, E7d: MMQ, E7e: MMA, E17: Risk Management, E19a: IRM, E19b: IRM, E23: Notes
