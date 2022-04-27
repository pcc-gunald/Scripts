SET NOCOUNT ON
GO

SET DEADLOCK_PRIORITY HIGH
GO


insert into upload_tracking (script, timestamp, upload) values ('UPLOAD_START',getdate(),'4.4.9_06_CLIENT_J_Operational_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('J_Operational_Upload/1_DDL/CORE_94220_CreateTable_MDSExtractSP_core.sql',getdate(),'4.4.9_06_CLIENT_J_Operational_Upload_US.sql')

GO

SET ANSI_NULLS ON
GO
SET ARITHABORT ON
GO
SET ANSI_WARNINGS ON
GO
SET ANSI_PADDING ON
GO
SET CONCAT_NULL_YIELDS_NULL ON
GO
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_NULL_DFLT_ON ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF (object_id('[operational].[OA26_MDSExtract_TmpXML]', 'U') IS NOT NULL)
	DROP TABLE [operational].[OA26_MDSExtract_TmpXML]

	
			
			CREATE TABLE [operational].[OA26_MDSExtract_TmpXML]
				--:PHI=Y:Desc:Contains MDS Assessments of Resident in XML format.It can be truncated during scrubbing process
			(   [MDSXML_ID] INT Identity(1,1) PRIMARY KEY,	--:PHI=N
				[ASSESS_ID] INT,				--:PHI=N
				[MDS_XML] XML,					--:PHI=Y
				[MDS_String] VARCHAR(max),		--:PHI=Y
				[FACID] VARCHAR(20),			--:PHI=N
				[FILEDATE] VARCHAR(50)			--:PHI=N
			) ON [PRIMARY]
		

IF (object_id('[operational].[OA26_MDSExtract_JobLog]', 'U') IS NOT NULL)
	DROP TABLE [operational].[OA26_MDSExtract_JobLog]

	
			
			CREATE TABLE [operational].[OA26_MDSExtract_JobLog]
				--:PHI=N:Desc:It logs the execution of stored procedure CORE_94220_sproc_MDSExtractSP_core
			(   [RunID] INT Identity(1,1) PRIMARY KEY,	--:PHI=N
				[CaseNumber] VARCHAR(20),	--:PHI=N
			    [FacID] VARCHAR(50),		--:PHI=N
				[StartTime] DATETIME,		--:PHI=N
				[EndTime] DATETIME,			--:PHI=N
				[Extract_Comp] VARCHAR(1)	--:PHI=N
			) ON [PRIMARY]
	

GO

print 'J_Operational_Upload/1_DDL/CORE_94220_CreateTable_MDSExtractSP_core.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('J_Operational_Upload/1_DDL/CORE_94220_CreateTable_MDSExtractSP_core.sql',getdate(),'4.4.9_06_CLIENT_J_Operational_Upload_US.sql')

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.9_06_CLIENT_J_Operational_Upload_US.sql')

GO
SET ANSI_NULLS ON
GO
SET ARITHABORT ON
GO
SET ANSI_WARNINGS ON
GO
SET ANSI_PADDING ON
GO
SET CONCAT_NULL_YIELDS_NULL ON
GO
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_NULL_DFLT_ON ON
GO

SET QUOTED_IDENTIFIER ON
GO


insert into pcc_db_version (db_version_code, db_upload_by)
values ('4.4.9_J', 'upload_history')


GO

print '..\Update db version.sql --****SCRIPT DONE****'

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.9_06_CLIENT_J_Operational_Upload_US.sql')

GO

insert into upload_tracking (script,timestamp,upload) values ('UPLOAD END',getdate(),'4.4.9_06_CLIENT_J_Operational_Upload_US.sql')