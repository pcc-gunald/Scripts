SET NOCOUNT ON
GO

SET DEADLOCK_PRIORITY HIGH
GO


insert into upload_tracking (script, timestamp, upload) values ('UPLOAD_START',getdate(),'4.4.10_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_facacq_dcn_disableAndCleanup.sql',getdate(),'4.4.10_06_CLIENT_K_Operational_Branch_US.sql')

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


IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[operational].[sproc_facacq_dcn_disableAndCleanup]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   DROP PROCEDURE [operational].sproc_facacq_dcn_disableAndCleanup
GO

CREATE PROCEDURE [operational].sproc_facacq_dcn_disableAndCleanup

-- ================================================================================= 
-- Script to create [operational].[sproc_facacq_dcn_disableAndCleanup] Procedure in Client Database
--						 
-- Written By:          Linlin Jing
-- Reviewed By:         
-- 
-- Script Type:         DDL 
-- Target DB Type:      Client Database
-- Target ENVIRONMENT:  Both
-- 
-- 
-- Re-Runable:          YES 
-- 
-- Description: Disable triggers, views and constraints before copying data to new client database		
-- 
-- Special Instruction: 
-- 
-- =================================================================================
AS
BEGIN
-------------------------------------------------------------------------------------------------------------
IF (OBJECT_ID('_TrimTriggers') IS NOT NULL)
	DROP TABLE _TrimTriggers


CREATE TABLE _TrimTriggers (
	TriggerName VARCHAR(500)
	,schemaName VARCHAR(500)
	,tableName VARCHAR(500)
	)

INSERT INTO _TrimTriggers (
	TriggerName
	,schemaName
	,TableName
	)
SELECT sysobjects.name AS trigger_name
	,s.name AS table_schema
	,OBJECT_NAME(parent_obj) AS table_name
FROM sysobjects
INNER JOIN sys.tables t ON sysobjects.parent_obj = t.[object_id]
INNER JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
WHERE sysobjects.type = 'TR'
	AND OBJECTPROPERTY(sysobjects.id, 'ExecIsTriggerDisabled') <> 1
	AND s.[name] = 'dbo'

DECLARE @TriggerName VARCHAR(500)
DECLARE @TableName VARCHAR(500)

DECLARE MyCursor CURSOR
FOR
SELECT TableName
	,TriggerName
FROM _TrimTriggers

OPEN MyCursor

FETCH NEXT
FROM MyCursor
INTO @TableName
	,@TriggerName

WHILE (@@Fetch_Status <> - 1)
BEGIN
	DECLARE @SQL VARCHAR(max)

	SET @SQL = 'DISABLE TRIGGER ' + @TriggerName + ' ON ' + @TableName

	PRINT @SQL

	EXEC (@SQL)

	FETCH NEXT
	FROM MyCursor
	INTO @TableName
		,@TriggerName
END

CLOSE MyCursor

DEALLOCATE MyCursor

-------------------------------------------------------------------------------------------------------------

IF(Object_ID('_TrimViews') IS NOT NULL)
DROP TABLE _TrimViews

CREATE TABLE _TrimViews(viewName varchar(500), viewDef ntext)

INSERT INTO _TrimViews(viewName, viewDef)
SELECT V.Name, D.definition
FROM (SELECT Name, Object_ID
		FROM sys.views
		WHERE OBJECTPROPERTY(object_id, 'IsSchemaBound')=1) V
    INNER JOIN sys.sql_modules D
        ON D.object_id = v.object_id
    INNER JOIN sys.objects O
        ON V.object_id = O.object_id
    INNER JOIN sys.schemas S
        ON S.schema_id = O.schema_id
WHERE S.name = 'dbo'

DECLARE MyCursor CURSOR FOR
SELECT DISTINCT viewName 
FROM _TrimViews

DECLARE @ViewName varchar(max)

OPEN MyCursor
FETCH NEXT FROM MyCursor INTO @ViewName
WHILE @@Fetch_Status <> -1
BEGIN
	SET @SQL = 'DROP VIEW ' + @ViewName
	PRINT @SQL
	EXEC (@SQL)
	FETCH NEXT FROM MyCursor INTO @ViewName
END
CLOSE MyCursor
DEALLOCATE MyCursor

-------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('_TrimFK') IS NOT NULL
	DROP TABLE _TrimFK


CREATE TABLE _TrimFK (
	FK_Name VARCHAR(500)
	,TableName VARCHAR(500)
	,ColumnName VARCHAR(500)
	,ParentTable VARCHAR(500)
	,ParentColumn VARCHAR(500)
	,Key_Seq INT
	,Progress INT DEFAULT(0)
	)

INSERT _TrimFK (
	FK_Name
	,TableName
	)
SELECT a.NAME AS FK_Name
	,b.NAME AS TableName
FROM sys.foreign_keys a
INNER JOIN sys.objects b ON a.parent_object_id = b.object_id
WHERE a.type = 'F'
	AND is_disabled = 0
	AND b.[schema_id] = 1

DECLARE @FK_Name VARCHAR(500)

DECLARE MyCursor CURSOR
FOR
SELECT DISTINCT FK_Name
	,TableName
FROM _TrimFK

OPEN MyCursor

FETCH NEXT
FROM MyCursor
INTO @FK_Name
	,@TableName

WHILE (@@Fetch_Status <> - 1)
BEGIN

	SET @SQL = 'ALTER TABLE ' + @TableName + ' NOCHECK CONSTRAINT ' + @FK_Name

	PRINT @SQL

	EXEC (@SQL)

	FETCH NEXT
	FROM MyCursor
	INTO @FK_Name
		,@TableName
END

CLOSE MyCursor

DEALLOCATE MyCursor

-------------------------------------------------------------------------------------------------------------
print ('------Delete Data------')
IF OBJECT_ID('_TrimTable') IS NOT NULL
	DROP TABLE _TrimTable

CREATE TABLE _TrimTable (
	ID INT
	,TableName VARCHAR(500)
	,Trimmed INT
	)

INSERT INTO _TrimTable (
	ID
	,TableName
	)
SELECT object_id
	,NAME
FROM sys.objects
WHERE type = 'U'
	AND NAME NOT IN (
		'_TrimFK'
		,'_TrimTriggers'
		,'_TrimViews'
		,'_TrimTable'
		,'pcc_db_version'
		,'upload_tracking'
		,'_TrimIndex'
		)
	AND [schema_id] = 1
ORDER BY NAME

DECLARE @ID INT
DECLARE @rowcount INT

--Loop trough the tables to copy
DECLARE MyCursor CURSOR
FOR
SELECT ID
	,TableName
FROM _TrimTable
ORDER BY 2

OPEN MyCursor

FETCH NEXT
FROM MyCursor
INTO @ID
	,@TableName

WHILE @@Fetch_Status = 0
BEGIN

	SET @SQL = 'delete ' + @TableName

	PRINT @SQL

	EXEC (@SQL)

	SET @rowcount = @@rowcount

	UPDATE _TrimTable
	SET Trimmed = @rowcount
	WHERE TableName = @TableName

	FETCH NEXT
	FROM MyCursor
	INTO @ID
		,@TableName
END

CLOSE MyCursor

DEALLOCATE MyCursor

END



GO

print 'K_Operational_Branch/5_StoredProcedures/sproc_facacq_dcn_disableAndCleanup.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_facacq_dcn_disableAndCleanup.sql',getdate(),'4.4.10_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_facacq_dcn_enableAll.sql',getdate(),'4.4.10_06_CLIENT_K_Operational_Branch_US.sql')

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


IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[operational].[sproc_facacq_dcn_enableAll]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   DROP PROCEDURE [operational].sproc_facacq_dcn_enableAll
GO

CREATE PROCEDURE [operational].sproc_facacq_dcn_enableAll

-- ================================================================================= 
-- Script to create [operational].[sproc_facacq_dcn_enableAll] Procedure in Client Database
--						 
-- Written By:          Linlin Jing
-- Reviewed By:         
-- 
-- Script Type:         DDL 
-- Target DB Type:      Client Database
-- Target ENVIRONMENT:  Both
-- 
-- 
-- Re-Runable:          YES 
-- 
-- Description:	Enable triggers, views and constraints after copying data to new client database			
-- 
-- Special Instruction: 
-- 
-- =================================================================================
AS
BEGIN
--ENABLE FK Constraint
DECLARE @FK_Name varchar(500)
DECLARE @TableName varchar(500)

DECLARE MyCursor CURSOR FOR
SELECT DISTINCT FK_Name, TableName
FROM _TrimFK


OPEN MyCursor 
FETCH NEXT FROM MyCursor INTO @FK_Name, @TableName
WHILE(@@Fetch_Status <> -1)
BEGIN
	DECLARE @SQL varchar(max)
	SET @SQL = 'ALTER TABLE ' + @TableName +' CHECK CONSTRAINT ' + @FK_Name
	PRINT @SQL
	EXEC (@SQL)

	FETCH NEXT FROM MyCursor INTO @FK_Name, @TableName
END
CLOSE MyCursor
DEALLOCATE MyCursor


DECLARE @TriggerName varchar(500)

DECLARE MyCursor CURSOR FOR
SELECT TableName, TriggerName
FROM _TrimTriggers

OPEN MyCursor
FETCH NEXT FROM MyCursor INTO @TableName, @TriggerName
WHILE(@@Fetch_Status <> -1)
BEGIN
	SET @SQL = 'ENABLE TRIGGER ' + @TriggerName + ' ON ' + @TableName
	PRINT @SQL
	EXEC (@SQL)
	FETCH NEXT FROM MyCursor INTO @TableName, @TriggerName
END
CLOSE MyCursor
DEALLOCATE MyCursor


--RECREATE Views
DECLARE MyCursor CURSOR FOR
SELECT viewDef
FROM _TrimViews

DECLARE @ViewName varchar(max)

OPEN MyCursor
FETCH NEXT FROM MyCursor INTO @SQL
WHILE @@Fetch_Status <> -1
BEGIN
	PRINT @SQL
	EXEC (@SQL)
	FETCH NEXT FROM MyCursor INTO @SQL
END
CLOSE MyCursor
DEALLOCATE MyCursor


END



GO

print 'K_Operational_Branch/5_StoredProcedures/sproc_facacq_dcn_enableAll.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_facacq_dcn_enableAll.sql',getdate(),'4.4.10_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_facacq_dcn_getAllConditions.sql',getdate(),'4.4.10_06_CLIENT_K_Operational_Branch_US.sql')

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



IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[operational].[sproc_facacq_dcn_getAllConditions]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   DROP PROCEDURE [operational].sproc_facacq_dcn_getAllConditions
GO

CREATE PROCEDURE [operational].sproc_facacq_dcn_getAllConditions
		@sourceDB VARCHAR(200) = NULL,
		@dstDB VARCHAR(500),
		@fac_ids varchar(500),
		@cur_res_as_of varchar(50),
		@Exclude_Cust_UDA varchar(1),
		@Exclude_AR varchar(1),
		@Exclude_Trust varchar(1),
		@tsJobServer VARCHAR(200) = '[vmuspassvtsjob1.pccprod.local].ds_merge_master'

-- ================================================================================= 
-- Script to create [operational].[sproc_facacq_dcn_getAllConditions] Procedure in Client Database
--						 
-- Written By:          Linlin Jing
-- Reviewed By:         
-- 
-- Script Type:         DDL 
-- Target DB Type:      Client Database
-- Target ENVIRONMENT:  Both
-- 
-- 
-- Re-Runable:          YES 
-- 
-- Description:			Create a stored procedure that generates conditions 
--						to filter what data to copy for data copy to new
-- 
-- Special Instruction: 
-- 
-- =================================================================================
AS
DECLARE @parenttable VARCHAR(500)
DECLARE @TableName VARCHAR(500)
DECLARE @fieldname VARCHAR(500)
DECLARE @SQL VARCHAR(max)
DECLARE @parentfield VARCHAR(1000)
DECLARE @col VARCHAR(max)
DECLARE @identityON VARCHAR(1000)
DECLARE @identityOFF VARCHAR(1000)
DECLARE @colselect VARCHAR(max)
DECLARE @Joins VARCHAR(100)
DECLARE @pho_schedule_details VARCHAR(1000)
DECLARE @queryfilter VARCHAR(max)
DECLARE @queryfilterwhere VARCHAR(20)
DECLARE @SQLfac_id VARCHAR(4000)
DECLARE @SQLstate VARCHAR(4000)
DECLARE @SQLreg VARCHAR(4000)
DECLARE @sqln NVARCHAR(2000)
DECLARE @Fac_id VARCHAR(500)
DECLARE @state_code VARCHAR(500)
DECLARE @reg_id VARCHAR(500)
DECLARE @closebracket VARCHAR(10)

-----------------------------------------------------------------
------ 1. Create _CopyTable
-----------------------------------------------------------------
IF @sourceDB IS NULL BEGIN SET @sourceDB = db_name() END

IF OBJECT_ID('_CopyTable') IS NOT NULL DROP TABLE _CopyTable
IF OBJECT_ID('CopyFac') IS NOT NULL	DROP TABLE CopyFac
IF OBJECT_ID('CopyFacJoin') IS NOT NULL	DROP TABLE CopyFacJoin
IF OBJECT_ID('_CopyFacConditions') IS NOT NULL DROP TABLE _CopyFacConditions


CREATE TABLE _CopyTable (TableName VARCHAR(500),[rows] INT,inserted_rows INT)
CREATE TABLE _CopyFacConditions (Table_Schema VARCHAR(100),Table_Name VARCHAR(500), Table_Type VARCHAR(100), conditions VARCHAR(max))


SET @SQL = 'insert into _CopyTable (TableName, [rows])
SELECT t.name AS table_name, i.rows
FROM sys.tables AS t INNER JOIN sys.sysindexes AS i ON t.object_id = i.id AND i.indid < 2
where i.rows > 0 
and schema_id = 1
and t.name not like ''if_us%'' and t.name not like ''case%''
and t.name not like ''bak_%''
and t.name not like ''copy_%''
and t.name not like ''temp_%''
and t.name not like ''%tmp_%''
and t.name not like ''merge%''
and t.name not like ''%backup%''
and t.name not like ''%bkp%''
and t.name not like ''EICase_%''
and t.name not like ''POCCopy%''
and t.name not like ''staging_%''
and t.name not in (''message_profile_bak_pcc25586'',''message_route_bak_pcc25586'',''prp_execution_statistics'',''pho_schedule_details_sync_ids'')
and t.name not in (''as_mds_final_report'',''mp_dea_assignment'',''mp_dea_assignment_audit'',''facility_analytics_extract_config'', ''login_history_archive''
, ''login_history'',''pcc_ext_vendor_url_config'', ''pcc_ext_vendor_url_param'')  
and left(t.name,1) <> ''_''
and t.name not in (''scrm_entity_contact_type'',''scrm_entity_relationship'',''scrm_entity_activity'',''scrm_lead_assessment'',''scrm_lead_referral_diagnosis''
,''scrm_lead_coverage'',''scrm_lead_referrer'',''scrm_possible_placement'',''scrm_lead'',''scrm_attachment'',''scrm_account'',''scrm_contact'',''scrm_entity'',''scrm_activity'')
and t.name not in (''edi_ftp_location'',''edi_ftp_unprocessed_files'',''edi_ftp_unprocessed_files_details'',''ar_import_config'') ---- Added By: Jaspreet Singh, Date: 2018-11-19, Reason: (Nigel email subject )RE: Removing Some EDI Tables from Data Copy to New Process
and t.name not in (''msg_unmatched_data_link'', ''msg_unmatched_client_data'') -- Added by: Mark Estey, Feb 6 2019, Smartsheet Line # 39 (Remove tables from data copy to new org)
and t.name not in (''epcs_prescriber_spi_mapping'') -- Added by: Mark Estey, Jul 8 2019, Smartsheet Line # 45 (Remove tables from data copy to new org)
and t.name not in (''facility_scheduling_cycle'') ---- Added by: Jaspreet Singh, 01/07/2020, Nigel email, subject: RE: EMAR Scheduler and Change in FA process - Script Update for Data Copy to New
and t.name not in (''pcc_db_version'',''upload_tracking'') ---- Added by: Jaspreet Singh, 05/04/2020, Rina email, subject: RE: EMAR Scheduler and Change in FA process - DB copy new - upload tracking and pcc_db_version
order by 2 desc'

EXEC (@SQL)

SET @SQL = 'SELECT * INTO dbo.CopyFac FROM ' + @tsJobServer + '.dbo.CopyFac with (nolock)'
EXEC (@SQL)

SET @SQL = 'SELECT * INTO dbo.CopyFacJoin FROM ' + @tsJobServer + '.dbo.CopyFacJoin with (nolock)'
EXEC (@SQL)

------Exclude AR Transactions
IF @Exclude_AR = 'Y'
	BEGIN
		IF OBJECT_ID('tempdb..#tempartabletoexclude') IS NOT NULL DROP TABLE #tempartabletoexclude
		
		select tablename into #tempartabletoexclude
		from copyfac where tablename in
		('ar_transactions_payment','ar_transaction_recurring_tx_refs','ar_unapplied_cash','ar_batch_poc_info','ar_transactions_contact_cash'
		,'ar_sbb_client_service_package_detail','ar_aging_snapshot','ar_claim_cob_amt','ar_claim_cob_cas','ar_claim_cob_payer','ar_invoice_claim','ar_invoice_transaction'
		,'ar_invoice_statement','ar_claim_cob_nte','ar_claim_additional_payer_info','ar_invoice','ar_invoice_batch','ar_applied_payment_history','ar_mppr_bumpup'
		,'ar_transaction_admin_fee_xrefs','ar_transactions','ar_transactions_rollup_client','edi_import_detail_message','edi_import_detail','ar_batch'
		,'edi_import','ar_collections_letter_generation','ar_collection_call','work_activity','ar_admission_charge_recurring_transaction','ar_recurring_transactions'
		,'ar_client_income','AR_THERAPY_PREVIOUS_AMOUNTS','ar_aging_check_summary','cash_receipt_check_summary','current_day_check_summary','current_revenue_check_summary'
		,'data_integrity_check_summary','past_day_check_summary','past_revenue_check_summary'
		,'ar_dso_client_balance','ar_batch_errors','ar_collection_call_txs','ar_import_835_result','ar_import_835_txn_result','ar_invoice_link')

		delete 
		--select *
		from copyfac where tablename in
		(select tablename from #tempartabletoexclude)

		delete 
		--select *
		from copyfacjoin where tablename in
		(select tablename from #tempartabletoexclude)

		delete 
		--select *
		from copyfacjoin where parenttable in
		(select tablename from #tempartabletoexclude)
	END

------Exclude Trust
IF @Exclude_Trust = 'Y'
	BEGIN
		IF OBJECT_ID('tempdb..#temptatabletoexclude') IS NOT NULL DROP TABLE #temptatabletoexclude

		select tablename into #temptatabletoexclude
		from copyfac where tablename in
		('ta_transaction','ta_batch','ta_statement','ta_client_account','ta_client_income_source','ta_configuration_audit','ta_vendor')

		delete 
		--select *
		from copyfac where tablename in
		(select tablename from #temptatabletoexclude)

		delete 
		--select *
		from copyfacjoin where tablename in
		(select tablename from #temptatabletoexclude)

		delete 
		--select *
		from copyfacjoin where parenttable in
		(select tablename from #temptatabletoexclude)
	END


------Exclude UDA
IF @Exclude_Cust_UDA = 'Y'
	BEGIN

		update dbo.copyfac
		set queryfilter = ' std_assess_id in (select ''-1'' as std_assess_id union select std_assess_id from ' + @sourceDB + '.dbo.as_std_assessment where system_flag = ''Y'' 
							or std_assess_id in (select std_assess_id from ' + @sourceDB + '.dbo.as_std_assessment_system_assessment_mapping)) '
		where tablename in (select table_name from information_schema.columns where column_name = 'std_assess_id')
		and joins in ('0','-1')

		update dbo.copyfac
		set queryfilter = ' a.std_assess_id in (select ''-1'' as std_assess_id union select std_assess_id from ' + @sourceDB + '.dbo.as_std_assessment where system_flag = ''Y'' 
							or std_assess_id in (select std_assess_id from ' + @sourceDB + '.dbo.as_std_assessment_system_assessment_mapping)) ' 
		--select * from copyfac
		where tablename in (select table_name from information_schema.columns where column_name = 'std_assess_id')
		and joins not in ('0','-1')
	END


------current resident only
IF (@cur_res_as_of is not NULL and @cur_res_as_of <> '')
	BEGIN
		update dbo.CopyFac
		set queryfilter = isnull(queryfilter,'') + case when queryfilter is NULL then ' (client_id in (select client_id from ' + @sourceDB + '.dbo.clients where fac_id in (select fac_id from ' + @dstDB + '.dbo.facility with (nolock) where fac_id <> 9001) and isnull(discharge_date,''' + @cur_res_as_of + ''') >= ''' + @cur_res_as_of + ''' AND admission_Date is not null  and current_census_id is not null ) or client_id is NULL or client_id < 0)'
		 else ' and' + ' (client_id in (select client_id from ' + @sourceDB + '.dbo.clients where fac_id in (select fac_id from ' + @dstDB + '.dbo.facility with (nolock) where fac_id <> 9001) and isnull(discharge_date,''' + @cur_res_as_of + ''') >= ''' + @cur_res_as_of + ''' AND admission_Date is not null  and current_census_id is not null ) or client_id is NULL or client_id < 0)' end -- enter the list of client_id to be excluded
		where tablename in (select table_name from information_schema.columns where column_name in ('client_id'))
		and joins in ('0','-1','0A')
		and tablename not in ('auth_remote_resource_configuration')

		update dbo.CopyFac
		set queryfilter = isnull(queryfilter,'') + case when queryfilter is NULL then ' (a.client_id in (select client_id from ' + @sourceDB + '.dbo.clients where fac_id in (select fac_id from ' + @dstDB + '.dbo.facility with (nolock) where fac_id <> 9001) and isnull(discharge_date,''' + @cur_res_as_of + ''') >= ''' + @cur_res_as_of + ''' AND admission_Date is not null  and current_census_id is not null ) or a.client_id is NULL or a.client_id < 0)'
		 else ' and' + ' (a.client_id in (select client_id from ' + @sourceDB + '.dbo.clients where fac_id in (select fac_id from ' + @dstDB + '.dbo.facility with (nolock) where fac_id <> 9001) and isnull(discharge_date,''' + @cur_res_as_of + ''') >= ''' + @cur_res_as_of + ''' AND admission_Date is not null and current_census_id is not null ) or a.client_id is NULL or a.client_id < 0)' end -- enter the list of client_id to be excluded
		--select * from copyfac
		where tablename in (select table_name from information_schema.columns where column_name in ('client_id'))
		and joins not in ('0','-1','0A')
		and tablename not in ('auth_remote_resource_configuration')

		update dbo.CopyFac
		set queryfilter = isnull(queryfilter,'') + case when queryfilter is NULL then ' (clientid in (select client_id from ' + @sourceDB + '.dbo.clients where fac_id in (select fac_id from ' + @dstDB + '.dbo.facility with (nolock) where fac_id <> 9001) and isnull(discharge_date,''' + @cur_res_as_of + ''') >= ''' + @cur_res_as_of + ''' AND admission_Date is not null  and current_census_id is not null ) or clientid is NULL or clientid < 0)'
		 else ' and' + ' (clientid in (select client_id from ' + @sourceDB + '.dbo.clients where fac_id in (select fac_id from ' + @dstDB + '.dbo.facility with (nolock) where fac_id <> 9001) and isnull(discharge_date,''' + @cur_res_as_of + ''') >= ''' + @cur_res_as_of + ''' AND admission_Date is not null and current_census_id is not null ) or clientid is NULL or clientid < 0)' end -- enter the list of client_id to be excluded
		where tablename in (select table_name from information_schema.columns where column_name in ('clientid'))
		and joins in ('0','-1')
		and tablename not in ('auth_remote_resource_configuration')

		update dbo.CopyFac
		set queryfilter = isnull(queryfilter,'') + case when queryfilter is NULL then ' (a.clientid in (select client_id from ' + @sourceDB + '.dbo.clients where fac_id in (select fac_id from ' + @dstDB + '.dbo.facility with (nolock) where fac_id <> 9001) and isnull(discharge_date,''' + @cur_res_as_of + ''') >= ''' + @cur_res_as_of + ''' AND admission_Date is not null  and current_census_id is not null ) or a.clientid is NULL or a.clientid < 0)'
		 else ' and' + ' (a.clientid in (select client_id from ' + @sourceDB + '.dbo.clients where fac_id in (select fac_id from ' + @dstDB + '.dbo.facility with (nolock) where fac_id <> 9001) and isnull(discharge_date,''' + @cur_res_as_of + ''') >= ''' + @cur_res_as_of + ''' AND admission_Date is not null and current_census_id is not null ) or a.clientid is NULL or a.clientid < 0)' end -- enter the list of client_id to be excluded
		--select * from copyfac
		where tablename in (select table_name from information_schema.columns where column_name in ('clientid'))
		and joins not in ('0','-1')
		and tablename not in ('auth_remote_resource_configuration')
	END


-----------------------------------------------------------------
------ 2. NO CONDITION TABLES
-----------------------------------------------------------------

	SELECT @sqln = 'SELECT @col = COALESCE( @col + '','', '''' ) + cols.name 
	FROM syscolumns cols JOIN sysobjects tables ON tables.id = cols.id AND tables.uid = user_id(''dbo'') 
	WHERE cols.name <> ''fac_uuid'' AND cols.iscomputed = 0 AND tables.name = ''facility'' ORDER BY colorder'

	EXEC Sp_executesql @sqln
		,N'@col VARCHAR(max) OUTPUT'
		,@col = @col OUTPUT

	SET @SQL = --'INSERT INTO facility (' + @sqlFields + ')
	'SELECT ' + @col + ' FROM ' + @sourceDB + '.dbo.facility with (nolock) WHERE fac_id IN (' + @fac_ids + ')'

	INSERT INTO _CopyFacConditions VALUES ('dbo','facility','scoping',@SQL)

------------------------------------------------------

	DELETE copyfac WHERE tablename LIKE 'crm_%' AND tablename NOT IN ('crm_codes','crm_code_activity','crm_field_config','crm_code_constants','crm_code_types','crm_configuration','crm_constants')

------------------------------------------------------ 
DECLARE MyCursor CURSOR
FOR
SELECT b.tablename
	,fac_id
	,state_code
	,reg_id
	,queryfilter
FROM dbo._CopyTable a
INNER JOIN CopyFac b ON a.tablename = b.tablename
WHERE joins IN ('-1','0')
	AND b.tablename <> 'facility'
ORDER BY 1

OPEN MyCursor

FETCH NEXT
FROM MyCursor
INTO @TableName
	,@Fac_id
	,@state_code
	,@reg_id
	,@queryfilter

WHILE (@@Fetch_Status = 0)
BEGIN
	IF @Fac_id IS NOT NULL
	BEGIN
		SET @SQLfac_id = ' where (' + @Fac_id + ' in (' + @fac_ids + ') or ' + @Fac_id + ' < 0 '
		SET @closebracket = ')'
	END
	ELSE
	BEGIN
		SET @SQLfac_id = ''
		SET @closebracket = ''
	END

	IF @state_code IS NOT NULL
		SET @SQLstate = ' or ' + @state_code + ' in (select prov from dbo.facility with (nolock) where fac_id in (' + @fac_ids + ') and prov is not NULL)'
	ELSE
		SET @SQLstate = ''

	IF @reg_id IS NOT NULL
		SET @SQLreg = ' or ' + @reg_id + ' in (select regional_id from dbo.facility with (nolock) where fac_id in (' + @fac_ids + ') and regional_id is not NULL)'
	ELSE
		SET @SQLreg = ''

	IF @queryfilter IS NOT NULL
	BEGIN
		IF @Fac_id IS NOT NULL
			SET @queryfilterwhere = ' and '
		ELSE
			SET @queryfilterwhere = ' where '
	END
	ELSE
	BEGIN
		SET @queryfilterwhere = ''
		SET @queryfilter = ''
	END

	-----------------
	IF EXISTS (
			SELECT *
			FROM sys.objects obj
			INNER JOIN sys.columns col ON obj.object_id = col.object_id
				AND is_identity = 1
				AND obj.name = @TableName
			)
	BEGIN
		SET @identityON = 'SET IDENTITY_INSERT ' + @TableName + ' ON '
		SET @identityOFF = ' SET IDENTITY_INSERT ' + @TableName + ' OFF'
	END
	ELSE
	BEGIN
		SET @identityON = ''
		SET @identityOFF = ''
	END

	-------------------
	SELECT @col = stuff((
				SELECT ',[' + col.name + ']'
				FROM sys.objects obj
				INNER JOIN sys.columns col ON obj.object_id = col.object_id
				WHERE obj.name = @TableName
					AND is_computed = 0
				FOR XML path('')
				), 1, 1, '')

	SET @SQL = 'select ' + @col + ' from ' + @sourceDB + '.dbo.' + @TableName + ' with (nolock) ' + @SQLfac_id + @SQLstate + @SQLreg + @closebracket + @queryfilterwhere + @queryfilter --+ @identityOFF
	
	IF (@SQLfac_id = '' AND @SQLstate = '' AND @SQLreg = '' )
		BEGIN INSERT INTO _CopyFacConditions VALUES ('dbo',@TableName,'system',@SQL) END
	ELSE 
		BEGIN INSERT INTO _CopyFacConditions VALUES ('dbo',@TableName,'scoping',@SQL) END

	FETCH NEXT
	FROM MyCursor
	INTO @TableName
		,@Fac_id
		,@state_code
		,@reg_id
		,@queryfilter
END

CLOSE MyCursor

DEALLOCATE MyCursor

-----------------------------------------------------------------
------ 2. JOINS TABLES
-----------------------------------------------------------------
DECLARE Joins CURSOR
FOR
SELECT DISTINCT joins
FROM _CopyTable a
INNER JOIN CopyFac b ON a.tablename = b.tablename
INNER JOIN CopyFacjoin c ON b.tablename = c.tablename
WHERE joins NOT IN ('-1','0')
ORDER BY 1

OPEN Joins

FETCH NEXT
FROM Joins
INTO @Joins

WHILE (@@Fetch_Status = 0)
BEGIN
	-----------------
	DECLARE Copydata CURSOR
	FOR
	SELECT c.tablename
		,fieldname
		,parenttable
		,parentfield
		,queryfilter
	FROM _CopyTable a
	INNER JOIN CopyFac b ON a.tablename = b.tablename
	INNER JOIN CopyFacjoin c ON b.tablename = c.tablename
	WHERE joins = @Joins
	ORDER BY 1

	OPEN Copydata

	FETCH NEXT
	FROM Copydata
	INTO @TableName
		,@fieldname
		,@parenttable
		,@parentfield
		,@queryfilter

	WHILE (@@Fetch_Status = 0)
	BEGIN
		IF EXISTS (
				SELECT *
				FROM sys.objects obj
				INNER JOIN sys.columns col ON obj.object_id = col.object_id
					AND is_identity = 1
					AND obj.name = @TableName
				)
		BEGIN
			SET @identityON = 'SET IDENTITY_INSERT ' + @TableName + ' ON '
			SET @identityOFF = ' SET IDENTITY_INSERT ' + @TableName + ' OFF'
		END
		ELSE
		BEGIN
			SET @identityON = ''
			SET @identityOFF = ''
		END

		IF @queryfilter IS NOT NULL
		BEGIN
			IF @Joins IN (
					'0A'
					,'1A'
					,'2A'
					,'3A'
					)
				SET @queryfilterwhere = ' and '
			ELSE
				SET @queryfilterwhere = ' where '
		END
		ELSE
		BEGIN
			SET @queryfilterwhere = ''
			SET @queryfilter = ''
		END

		-------------------
		SELECT @col = stuff((
					SELECT ',[' + col.name + ']'
					FROM sys.objects obj
					INNER JOIN sys.columns col ON obj.object_id = col.object_id
					WHERE obj.name = @TableName
						AND is_computed = 0
					FOR XML path('')
					), 1, 1, '')

		SELECT @colselect = stuff((
					SELECT ',a.[' + col.name + ']'
					FROM sys.objects obj
					INNER JOIN sys.columns col ON obj.object_id = col.object_id
					WHERE obj.name = @TableName
						AND is_computed = 0
					FOR XML path('')
					), 1, 1, '')

		IF @Joins IN (
				'0A'
				,'1A'
				,'2A'
				,'3A'
				)
		
		BEGIN 			
			IF @TableName = 'clients'
			BEGIN
				BEGIN
					SET @SQL = --@identityON + 'insert into ' + @TableName + '(' + @col + ') 
					
						'select ' + @col + ' from ' + @sourceDB + '.dbo.' + @TableName + ' with (nolock)
							where fac_id in (select fac_id from ' + @dstDB + '.dbo.facility with (nolock)) ' + @queryfilterwhere + @queryfilter
					
					INSERT INTO _CopyFacConditions VALUES ('dbo',@TableName,'scoping',@SQL)

				END
			END

			IF @TableName = 'Contact'
			BEGIN
				--these contact_id belong to the deleted facilities
				SET @SQL = --@identityON + 'insert into ' + @TableName + '(' + @col + ') 
				'select ' + @col + ' from ' + @sourceDB + '.dbo.contact with (nolock) where contact_id not in 
				(select contact_id from ' + @sourceDB + '.dbo.contact_type where contact_id not in (select contact_id from ' + @dstDB + '.dbo.contact_type)
				union select contact_id from ' + @sourceDB + '.dbo.staff where contact_id not in (select contact_id from ' + @dstDB + '.dbo.staff)) ' + @queryfilterwhere + @queryfilter --+ @identityOFF

				--this has the contacts for the copied facilities plus the extra contacts that are not tied to contact_id nor staff
				
				INSERT INTO _CopyFacConditions VALUES ('dbo',@TableName,'joins',@SQL)

				
			END

			IF @TableName IN (
					'pho_schedule_details_followup_useraudit'
					,'pho_schedule_details_performby_useraudit'
					,'pho_schedule_details_pending_followup'
					)
			BEGIN

				SET @SQL = 
				'select ' + @col + ' from ' + @sourceDB + '.dbo.' + @TableName + ' 
				where schedule_detail_id in ('

				SELECT @pho_schedule_details = 'select pho_schedule_detail_id from ' + @dstDB + '.dbo.pho_schedule_details with (nolock)'

				INSERT INTO _CopyFacConditions VALUES ('dbo',@TableName,'joins',@SQL + @pho_schedule_details + ')' + @queryfilterwhere + @queryfilter)

			END

			IF @TableName = 'general_config'
			BEGIN
				SET @SQL = 'select ' + @col + ' from ' + @sourceDB + '.dbo.' + @TableName + ' 
				where fac_id in (select fac_id from ' + @dstDB + '.dbo.facility) or fac_id in (-1,9001) ' + @queryfilterwhere + @queryfilter --+ @identityOFF
				
					INSERT INTO _CopyFacConditions VALUES ('dbo',@TableName,'joins',@SQL)

			END

			IF @TableName IN (
					'mpi'
					,'cp_scheduled_detail_created_info'
					,'cp_qshift_detail_created_info'
					,'cp_duration_detail_created_info'
					,'ap_lib_vendors'
					)
			BEGIN
				SET @SQL = --@identityON + 'insert into ' + @TableName + '(' + @col + 
				' select ' + @col + ' from ' + @sourceDB + '.dbo.' + @TableName + ' with (nolock)
				where ' + @fieldname + ' in (select ' + @parentfield + ' from ' + @dstDB + '.dbo.' + @parenttable + ' with (nolock))' + @queryfilterwhere + @queryfilter --+ @identityOFF

				INSERT INTO _CopyFacConditions VALUES ('dbo',@TableName,'joins',@SQL)
				
			END

			IF @TableName = 'cp_sec_user_audit'
			BEGIN
				SET @SQL = --@identityON + 'insert into ' + @TableName + '(' + @col + ') 
				'select ' + @col + ' from ' + @sourceDB + '.dbo.' + @TableName + ' with (nolock)
				where (fac_id in (select fac_id from ' + @dstDB + '.dbo.facility with (nolock) where fac_id <> 9001) or fac_id is NULL or fac_id < 0) ' + @queryfilterwhere + @queryfilter --+ @identityOFF

				INSERT INTO _CopyFacConditions VALUES ('dbo',@TableName,'joins',@SQL)
				
			END

			IF @TableName IN ('crm_activity')
			BEGIN
				SET @SQL = --@identityON + 'insert into ' + @TableName + '(' + @col + ') 
				'select ' + @col + ' from ' + @sourceDB + '.dbo.' + @TableName + ' with (nolock)
				where ' + @fieldname + ' in (select ' + @parentfield + ' from ' + @dstDB + '.dbo.' + @parenttable + ' with (nolock)) or fac_id in (select fac_id from ' + @dstDB + '.dbo.facility where fac_id <> 9001)' + @queryfilterwhere + @queryfilter --+ @identityOFF

				INSERT INTO _CopyFacConditions VALUES ('dbo',@TableName,'joins',@SQL)
				
			END

			IF @TableName IN ('file_metadata')
			BEGIN
				SET @SQL = --@identityON + 'insert into ' + @TableName + '(' + @col + ') 
				'select ' + @col + ' from ' + @sourceDB + '.dbo.' + @TableName + ' with (nolock)				
				where ' + @fieldname + ' in (select file_metadata_id from ' + @dstDB + '.dbo.upload_files with (nolock)) or ' + @fieldname + ' in (select FILE_ID from ' + @dstDB + '.dbo.result_lab_report with (nolock)) or ' + @fieldname + ' in (select file_id from ' + @dstDB + '.dbo.result_radiology_report with (nolock)) ' + @queryfilterwhere + @queryfilter --+ @identityOFF

				INSERT INTO _CopyFacConditions VALUES ('dbo',@TableName,'joins',@SQL)
				
			END

			IF @TableName IN ('map_identifier')
			BEGIN
				SET @SQL = --@identityON + 'insert into ' + @TableName + '(' + @col + ') 
				'select ' + @col + ' from ' + @sourceDB + '.dbo.' + @TableName + ' with (nolock) 
				where internal_id in (select client_id from ' + @dstDB + '.dbo.clients with (nolock)) and map_type_id = ''2'' ' + @queryfilterwhere + @queryfilter --+ @identityOFF

				INSERT INTO _CopyFacConditions VALUES ('dbo',@TableName,'joins',@SQL)
				
			END

			IF @TableName IN ('pho_schedule_details_reminder')
			BEGIN
				SET @SQL = --@identityON + 'insert into ' + @TableName + 
				' select pho_schedule_details_reminder.* from ' + @sourceDB + '.dbo.' + @TableName + ' with (nolock) 
				inner join ' + @dstDB + '.dbo.' + @parenttable + ' as b with (nolock) on pho_schedule_details_reminder.' + @fieldname + ' = b.' + @parentfield + @queryfilterwhere + @queryfilter --+ @identityOFF

				INSERT INTO _CopyFacConditions VALUES ('dbo',@TableName,'joins',@SQL)
				
			END

			IF @TableName IN ('lib_message_profile')
			BEGIN
				SET @SQL = --@identityON + 'insert into ' + @TableName + '(' + @col + ') 
				'select ' + @col + ' from ' + @sourceDB + '.dbo.' + @TableName + ' with (nolock)
				where ' + @fieldname + ' in (select ' + @parentfield + ' from ' + @dstDB + '.dbo.' + @parenttable + ' with (nolock)) or vendor_code in (''SWIFT_ADT'',''SWIFT_Assessment'') ' + @queryfilterwhere + @queryfilter --+ @identityOFF

				INSERT INTO _CopyFacConditions VALUES ('dbo',@TableName,'joins',@SQL)

				
			END
		END
	ELSE
		BEGIN
			SET @SQL = --@identityON + 'insert into ' + @TableName + '(' + @col + ') 
			'select ' + @colselect + ' from ' + @sourceDB + '.dbo.' + @TableName + ' as a with (nolock) 
			inner join ' + @dstDB + '.dbo.' + @parenttable + ' as b with (nolock) on a.' + @fieldname + ' = b.' + @parentfield + @queryfilterwhere + @queryfilter --+ @identityOFF

				INSERT INTO _CopyFacConditions VALUES ('dbo',@TableName,'joins',@SQL)
			
		END

		FETCH NEXT
		FROM Copydata
		INTO @TableName
			,@fieldname
			,@parenttable
			,@parentfield
			,@queryfilter
	END

	CLOSE Copydata

	DEALLOCATE Copydata

	FETCH NEXT
	FROM Joins
	INTO @Joins
END

CLOSE Joins

DEALLOCATE Joins

GO

print 'K_Operational_Branch/5_StoredProcedures/sproc_facacq_dcn_getAllConditions.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_facacq_dcn_getAllConditions.sql',getdate(),'4.4.10_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_facacq_dcn_post_checks.sql',getdate(),'4.4.10_06_CLIENT_K_Operational_Branch_US.sql')

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


if exists (select * from dbo.sysobjects where id = object_id(N'[operational].[sproc_facacq_dcn_post_checks]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [operational].[sproc_facacq_dcn_post_checks]
go

CREATE PROCEDURE [operational].[sproc_facacq_dcn_post_checks]
@case_number varchar(100)
,@sourceDB varchar(500) 
,@log_db varchar(200) = 'pcc_temp_storage'

-- ================================================================================= 
-- Script to create [operational].[sproc_facacq_dcn_post_checks] Procedure in Client Database
--						 
-- Written By:          Linlin Jing
-- Reviewed By:         
-- 
-- Script Type:         DDL 
-- Target DB Type:      Client Database
-- Target ENVIRONMENT:  Both
-- 
-- 
-- Re-Runable:          YES 
-- 
-- Description: Standard data checks after copying data to a new client database			
-- 
-- Special Instruction: 
-- 
-- =================================================================================

/*
-- =================================================================================

-- Run in destination

-- Sample execution: 
	exec [operational].[sproc_facacq_dcn_post_checks]
	@case_number = 'EICase7654321', @sourceDB = 'DS_Linlin_adde', @log_db = 'd_m_m'

-- =================================================================================
*/


AS
DECLARE @SQL varchar(max)

	IF OBJECT_ID(@log_db + '.dbo.dcnlog_' + @case_number, 'U') IS NULL 

	EXEC('CREATE TABLE ' + @log_db + '.dbo.dcnlog_' + @case_number + '(rNo INT IDENTITY(1, 1),step VARCHAR(200),msg VARCHAR(max),msgTime DATETIME)')

-------------------------------------------------------------------------------
SET @SQL = 
'if (select count(*) from sys.triggers dst where is_disabled = ''0''
	and [name] not in (select [name] from ' + @sourceDB + '.sys.triggers src where is_disabled = ''0'')) > 0

	insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime)
	select ''' + OBJECT_NAME(@@PROCID) + ''',name + '' --This trigger is disabled or not in the Source DB'',getdate() 
	from sys.triggers dst where is_disabled = ''0''
	and [name] not in (select [name] from ' + @sourceDB + '.sys.triggers src where is_disabled = ''0'')'

EXEC (@SQL)


SET @SQL = 
'if (select count(*) from ' + @sourceDB + '.sys.triggers dst where is_disabled = ''0''
	and [name] not in (select [name] from sys.triggers src where is_disabled = ''0'')) > 0

	insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime)
	select ''' + OBJECT_NAME(@@PROCID) + ''',name + '' --This trigger is disabled or not in the Destination DB'',getdate() 
	from ' + @sourceDB + '.sys.triggers dst where is_disabled = ''0''
	and [name] not in (select [name] from sys.triggers src where is_disabled = ''0'')'

EXEC (@SQL)

-------------------------------------------------------------------------------
SET @SQL = 
'if (select count(*) from information_schema.columns dst 
	where not exists (select 1 from ' + @sourceDB + '.information_schema.columns src
		where src.table_name = dst.table_name and src.column_name = dst.column_name)
		and table_name in (select tablename from ' + @sourceDB + '.dbo._CopyTable)) > 0

	insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime)
	select ''' + OBJECT_NAME(@@PROCID) + ''', TABLE_SCHEMA + ''.'' + table_name + ''.'' + Column_Name + '' --This field is not in the Source DB'',getdate() 
	from information_schema.columns dst 
	where not exists (select 1 from ' + @sourceDB + '.information_schema.columns src
		where src.table_name = dst.table_name and src.column_name = dst.column_name)
		and table_name in (select tablename from ' + @sourceDB + '.dbo._CopyTable)'

EXEC (@SQL)


SET @SQL = 
'if (select count(*) from ' + @sourceDB + '.information_schema.columns src
where not exists (select 1 from information_schema.columns dst
		where src.table_name = dst.table_name
		and src.column_name = dst.column_name)
		and table_name in (select tablename from ' + @sourceDB + '.dbo._CopyTable)) > 0

	insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime)
	select ''' + OBJECT_NAME(@@PROCID) + ''', TABLE_SCHEMA + ''.'' + table_name + ''.'' + Column_Name + '' --This field is not in the Destination DB'',getdate() 
	from ' + @sourceDB + '.information_schema.columns src
	where not exists (select 1 from information_schema.columns dst
		where src.table_name = dst.table_name
		and src.column_name = dst.column_name)
and table_name in (select tablename from ' + @sourceDB + '.dbo._CopyTable)'

EXEC (@SQL)


SET @SQL = 
'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime)
select ''' + OBJECT_NAME(@@PROCID) + ''', tablename + '' --This table has data but is not in the _CopyFac table'',getdate() 
from ' + @sourceDB + '.dbo._CopyTable
where tablename not in (select tablename from ' + @sourceDB + '.dbo.CopyFac)'

EXEC (@SQL)


SET @SQL = '

CREATE TABLE #OtherFac_id_table (TableName VARCHAR(500),Records INT,query VARCHAR(max))

DECLARE @Fac VARCHAR(500)
DECLARE @Reg VARCHAR(500)
DECLARE @StateCode VARCHAR(500)
DECLARE @TableName VARCHAR(500)
DECLARE @SQL VARCHAR(MAX)
DECLARE @SQLfac_id VARCHAR(500)
DECLARE @SQLstate VARCHAR(500)
DECLARE @SQLreg VARCHAR(500)
DECLARE @closebracket VARCHAR(100);

WITH fac
AS (
	SELECT table_name
		,column_name
	FROM information_schema.columns
	WHERE (
			column_name LIKE ''%fac_id%''
			OR column_name LIKE ''%facility_id%''
			)
		AND table_name NOT LIKE ''view%''
		AND column_name NOT IN (
			''ext_fac_id''
			,''state_facility_id''
			,''ext_facility_id_required''
			)
		AND table_schema = ''dbo''
	)
	,reg
AS (
	SELECT table_name
		,column_name
	FROM information_schema.columns
	WHERE (column_name LIKE ''%reg_id%'')
		AND table_name NOT LIKE ''view%''
		AND table_schema = ''dbo''	
	)
	,statecode
AS (
	SELECT table_name
		,column_name
	FROM information_schema.columns
	WHERE (column_name LIKE ''%state_code%'')
		AND table_name NOT LIKE ''view%''
		AND table_schema = ''dbo''
	)
SELECT fac.table_name
	,fac.column_name AS Fac
	,reg.column_name AS Reg
	,statecode.column_name AS StateCode
INTO #tables
FROM fac
LEFT JOIN reg ON fac.table_name = reg.table_name
LEFT JOIN statecode ON fac.table_name = statecode.table_name
WHERE fac.table_name IN (
		SELECT tablename
		FROM ' + @sourceDB + '.dbo._copytable
		)
	AND fac.table_name NOT IN (''th_minutes_stage1'')
ORDER BY 1

DECLARE MyCursor CURSOR
FOR
SELECT *
FROM #tables

OPEN MyCursor

FETCH NEXT
FROM MyCursor
INTO @TableName
	,@Fac
	,@Reg
	,@StateCode

WHILE @@Fetch_Status = 0
BEGIN
	IF @Fac IS NOT NULL
	BEGIN
		SET @SQLfac_id = '' where not (('' + @Fac + '' in (select fac_id from facility) or '' + @Fac + '' = -1) ''
		SET @closebracket = '') or '' + @Fac + '' is NULL ''
	END
	ELSE
	BEGIN
		SET @SQLfac_id = ''''
		SET @closebracket = ''''
	END

	IF @StateCode IS NOT NULL
		SET @SQLstate = '' or '' + @statecode + '' in (select prov from facility where prov is not NULL)''
	ELSE
		SET @SQLstate = ''''

	IF @Reg IS NOT NULL
		SET @SQLreg = '' or '' + @Reg + '' in (select regional_id from facility where regional_id is not NULL)''
	ELSE
		SET @SQLreg = ''''

	SET @SQL = ''insert into dbo.#OtherFac_id_table
		select '''''' + @TableName + '''''', count(*), ''''select * from '' + @TableName + @SQLfac_id + @SQLstate + @SQLreg + @closebracket + '''''' 
		from '' + @TableName + @SQLfac_id + @SQLstate + @SQLreg + @closebracket

	--PRINT @SQL
	EXEC (@SQL)

	FETCH NEXT
	FROM MyCursor
	INTO @TableName
		,@Fac
		,@Reg
		,@StateCode
END

CLOSE MyCursor

DEALLOCATE MyCursor

insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime)
	select distinct ''' + OBJECT_NAME(@@PROCID) + ''', query + '' --Check fac_id'',getdate() 
	from #OtherFac_id_table
WHERE records <> 0
'

EXEC (@SQL)



GO

print 'K_Operational_Branch/5_StoredProcedures/sproc_facacq_dcn_post_checks.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_facacq_dcn_post_checks.sql',getdate(),'4.4.10_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_facacq_dcn_post_cleanups.sql',getdate(),'4.4.10_06_CLIENT_K_Operational_Branch_US.sql')

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


if exists (select * from dbo.sysobjects where id = object_id(N'[operational].[sproc_facacq_dcn_post_cleanups]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [operational].[sproc_facacq_dcn_post_cleanups]
go

CREATE PROCEDURE [operational].[sproc_facacq_dcn_post_cleanups]
@case_number varchar(100),
@exclude_ar varchar(1) = 'N',
@ar_start_date varchar(50),
@exclude_trust varchar(1) = 'N',
@exclude_glap varchar(1) = 'N',
@exclude_cp_lib varchar(1) = 'N',
@exclude_alert varchar(1) = 'N',
@exclude_qia varchar(1) = 'N',
@exclude_sec_role varchar(1) = 'N',
@exclude_online_doc varchar(1) = 'N',
@exclude_inc varchar(1) = 'N',
@exclude_glapbank varchar(1) = 'N',
@exclude_insur_companies varchar(1) = 'N',
@exclude_admin_notes varchar(1) = 'N',
@if_bkp_tables varchar(1) = 'Y',
@template_db varchar(200) = '[USTMPLT\PRODTEMPLATE].us_template_pccsingle_tmpltOH',
@log_db varchar(200) = 'pcc_temp_storage'

-- ================================================================================= 
-- Script to create [operational].[sproc_facacq_dcn_post_cleanups] Procedure in Client Database
--						 
-- Written By:          Linlin Jing
-- Reviewed By:         
-- 
-- Script Type:         DDL 
-- Target DB Type:      Client Database
-- Target ENVIRONMENT:  Both
-- 
-- 
-- Re-Runable:          YES 
-- 
-- Description: Standard data clean up after copying data to a new client database			
-- 
-- Special Instruction: 
-- 
-- =================================================================================

/*
-- =================================================================================

-- Run in destination

-- Sample execution: 

	exec [operational].[sproc_facacq_dcn_post_cleanups]
	@case_number = 'EICase7654321',
	@exclude_ar = 'Y',
	@ar_start_date = '2021-01-01',
	@exclude_trust = 'Y',
	@exclude_glap = 'Y',
	@exclude_cp_lib = 'Y',
	@exclude_alert = 'Y',
	@exclude_qia = 'Y',
	@exclude_sec_role = 'Y',
	@exclude_online_doc = 'Y',
	@exclude_inc = 'Y',
	@exclude_glapbank = 'Y',
	@exclude_insur_companies = 'Y',
	@if_bkp_tables = 'Y',
	@template_db = 'd_m_m',
	@log_db = 'd_m_m'
	
-- =================================================================================
*/


AS
declare @sql nvarchar(max)
declare @message varchar(4000)
declare @rowcount int = 0
declare @first_fac varchar(200)
declare @sql_log varchar(max)

SET NOCOUNT ON;
SET CONTEXT_INFO 0xDC1000000;

select top 1 @first_fac = fac_id from facility where deleted = 'N' and fac_id <> 9001

IF OBJECT_ID(@log_db + '.dbo.dcnlog_' + @case_number, 'U') IS NULL 

EXEC('CREATE TABLE ' + @log_db + '.dbo.dcnlog_' + @case_number + '(rNo INT IDENTITY(1, 1),step VARCHAR(200),msg VARCHAR(max),msgTime DATETIME)')

--=============================================================================================
IF @exclude_ar = 'Y'
BEGIN 
	IF @if_bkp_tables = 'Y'
	BEGIN
		BEGIN TRY
			IF OBJECT_ID(@log_db + '.dbo._bkp_' + @case_number + '_user_defined_data', 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_' + @case_number + '_user_defined_data')
			EXEC('select * into ' + @log_db + '.dbo._bkp_' + @case_number + '_user_defined_data from user_defined_data where call_id is not null')

			IF OBJECT_ID(@log_db + '.dbo._bkp_' + @case_number + '_AR_CLIENT_CONFIGURATION', 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_' + @case_number + '_AR_CLIENT_CONFIGURATION')
			EXEC('select * into ' + @log_db + '.dbo._bkp_' + @case_number + '_AR_CLIENT_CONFIGURATION from AR_CLIENT_CONFIGURATION')

			IF OBJECT_ID(@log_db + '.dbo._bkp_' + @case_number + '_ar_configuration', 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_' + @case_number + '_ar_configuration')
			EXEC('select * into ' + @log_db + '.dbo._bkp_' + @case_number + '_ar_configuration from ar_configuration WHERE fac_id in (select fac_id from facility)')

			IF OBJECT_ID(@log_db + '.dbo._bkp_' + @case_number + '_configuration_parameter_ar', 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_' + @case_number + '_configuration_parameter_ar')
			EXEC('select * into ' + @log_db + '.dbo._bkp_' + @case_number + '_configuration_parameter_ar from configuration_parameter where name like ''%closed%'' and fac_id in (select fac_id from facility)')

		END TRY
		BEGIN CATCH
			set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
			exec (@sql_log)
			raiserror(@message, 16, 1)
		END CATCH
	END

	BEGIN TRY

		set @sql = 'UPDATE user_defined_data SET call_id = NULL	WHERE call_id IS NOT NULL'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)


		set @sql = 'UPDATE AR_CLIENT_CONFIGURATION SET rebill_from_date = NULL FROM AR_CLIENT_CONFIGURATION	WHERE rebill_from_date IS NOT NULL'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)


		set @sql = '
		UPDATE ar_configuration
		SET posting_month = ''' + convert(varchar,month(@ar_start_date)) + '''
			,ar_start_date = ''' + convert(varchar,@ar_start_date,121) + '''								
			,posting_year = ''' + convert(varchar,year(@ar_start_date)) + '''						
			,revision_by = ''' + @case_number + '''
			,revision_date = getdate()
		WHERE fac_id IN (select fac_id from facility)'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)


		set @sql = 'DELETE FROM configuration_parameter	WHERE name LIKE ''%closed%'' AND fac_id IN (select fac_id from facility)'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)


		set @sql = 'UPDATE ar_configuration	SET auto_retro_start_date = ar_start_date WHERE fac_id IN (select fac_id from facility)'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		
	END TRY
	BEGIN CATCH
		set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
		exec (@sql_log)
		raiserror(@message, 16, 1)
	END CATCH
END

--=============================================================================================
IF @exclude_trust = 'Y'
BEGIN 
	IF @if_bkp_tables = 'Y'
	BEGIN
		BEGIN TRY
			IF OBJECT_ID(@log_db + '.dbo._bkp_' + @case_number + '_ta_control_account', 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_' + @case_number + '_ta_control_account')
			EXEC('select * into ' + @log_db + '.dbo._bkp_' + @case_number + '_ta_control_account from ta_control_account where fac_id in (select fac_id from facility) and current_balance is not null')

			IF OBJECT_ID(@log_db + '.dbo._bkp_' + @case_number + '_ta_configuration', 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_' + @case_number + '_ta_configuration')
			EXEC('select * into ' + @log_db + '.dbo._bkp_' + @case_number + '_ta_configuration from ta_configuration where fac_id in (select fac_id from facility)')
		END TRY
		BEGIN CATCH
			set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
			exec (@sql_log)
			raiserror(@message, 16, 1)
		END CATCH
	END

	BEGIN TRY

		set @sql = 'update ta_control_account set current_balance = NULL from ta_control_account
		where fac_id in (select fac_id from facility) and current_balance is not null'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)


		set @sql = '
		update ta_configuration
		set posting_month = ''' + convert(varchar,month(dateadd(m,-1,@ar_start_date))) + '''
		,posting_year = ''' + convert(varchar,year(dateadd(m,-1,@ar_start_date))) + '''
		,next_deposit_number = 1
		,next_withdrawal_number = 1
		,next_interest_number = 1
		,next_ar_payment_number = 1
		,cash_box_account_id = NULL
		,default_account_id = NULL
		,default_std_account_id = NULL
		where fac_id in (select fac_id from facility)'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		
	END TRY
	BEGIN CATCH
		set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
		exec (@sql_log)
		raiserror(@message, 16, 1)
	END CATCH
END
--=============================================================================================
IF @exclude_glap = 'Y'
BEGIN 
	IF @if_bkp_tables = 'Y'
	BEGIN
		BEGIN TRY
			IF OBJECT_ID(@log_db + '.dbo._bkp_' + @case_number + '_GL_TRANSACTIONS', 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_' + @case_number + '_GL_TRANSACTIONS')
			EXEC('select * into ' + @log_db + '.dbo._bkp_' + @case_number + '_GL_TRANSACTIONS FROM GL_TRANSACTIONS where fac_id in (select fac_id from facility)')

			IF OBJECT_ID(@log_db + '.dbo._bkp_' + @case_number + '_GL_BATCH_ENTRY_ERRORS', 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_' + @case_number + '_GL_BATCH_ENTRY_ERRORS')
			EXEC('select * into ' + @log_db + '.dbo._bkp_' + @case_number + '_GL_BATCH_ENTRY_ERRORS from GL_BATCH_ENTRY_ERRORS 
					where batch_entry_id in (select batch_entry_id from gl_batch_entry where fac_id in (select fac_id from facility))')

			IF OBJECT_ID(@log_db + '.dbo._bkp_' + @case_number + '_GL_BATCH_ENTRY', 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_' + @case_number + '_GL_BATCH_ENTRY')
			EXEC('select * into ' + @log_db + '.dbo._bkp_' + @case_number + '_GL_BATCH_ENTRY from GL_BATCH_ENTRY where fac_id in (select fac_id from facility)')

			IF OBJECT_ID(@log_db + '.dbo._bkp_' + @case_number + '_GL_BATCH', 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_' + @case_number + '_GL_BATCH')
			EXEC('select * into ' + @log_db + '.dbo._bkp_' + @case_number + '_GL_BATCH from GL_BATCH where fac_id in (select fac_id from facility)')

			IF OBJECT_ID(@log_db + '.dbo._bkp_' + @case_number + '_AP_TRANSACTIONS_ADJ', 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_' + @case_number + '_AP_TRANSACTIONS_ADJ')
			EXEC('select * into ' + @log_db + '.dbo._bkp_' + @case_number + '_AP_TRANSACTIONS_ADJ from AP_TRANSACTIONS_ADJ 
				WHERE transaction_id in (select transaction_id from ap_transactions where fac_id in (select fac_id from facility)) ')

			IF OBJECT_ID(@log_db + '.dbo._bkp_' + @case_number + '_AP_TRANSACTIONS', 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_' + @case_number + '_AP_TRANSACTIONS')
			EXEC('select * into ' + @log_db + '.dbo._bkp_' + @case_number + '_AP_TRANSACTIONS from AP_TRANSACTIONS where fac_id in (select fac_id from facility)')

			IF OBJECT_ID(@log_db + '.dbo._bkp_' + @case_number + '_GL_ACCOUNT_GROUPS_FACILITY_IDS', 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_' + @case_number + '_GL_ACCOUNT_GROUPS_FACILITY_IDS')
			EXEC('select * into ' + @log_db + '.dbo._bkp_' + @case_number + '_GL_ACCOUNT_GROUPS_FACILITY_IDS from GL_ACCOUNT_GROUPS_FACILITY_IDS where fac_id in (select fac_id from facility)')

			IF OBJECT_ID(@log_db + '.dbo._bkp_' + @case_number + '_GL_ACCOUNT_SEGMENT', 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_' + @case_number + '_GL_ACCOUNT_SEGMENT')
			EXEC('select * into ' + @log_db + '.dbo._bkp_' + @case_number + '_GL_ACCOUNT_SEGMENT from GL_ACCOUNT_SEGMENT where fac_id in (select fac_id from facility)')

			IF OBJECT_ID(@log_db + '.dbo._bkp_' + @case_number + '_GL_BUDGETS', 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_' + @case_number + '_GL_BUDGETS')
			EXEC('select * into ' + @log_db + '.dbo._bkp_' + @case_number + '_GL_BUDGETS from GL_BUDGETS where fac_id in (select fac_id from facility)')

			IF OBJECT_ID(@log_db + '.dbo._bkp_' + @case_number + '_GLAP_BANK_REC', 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_' + @case_number + '_GLAP_BANK_REC')
			EXEC('select * into ' + @log_db + '.dbo._bkp_' + @case_number + '_GLAP_BANK_REC from GLAP_BANK_REC where fac_id in (select fac_id from facility)')

			IF OBJECT_ID(@log_db + '.dbo._bkp_' + @case_number + '_AP_PAYMENT_INVOICE_HISTORY', 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_' + @case_number + '_AP_PAYMENT_INVOICE_HISTORY')
			EXEC('select * into ' + @log_db + '.dbo._bkp_' + @case_number + '_AP_PAYMENT_INVOICE_HISTORY from AP_PAYMENT_INVOICE_HISTORY 
					where inv_id in (select batch_entry_id from ap_batch_entry_invoices where fac_id in (select fac_id from facility)) ')

			IF OBJECT_ID(@log_db + '.dbo._bkp_' + @case_number + '_AP_PAYMENT_INVOICES', 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_' + @case_number + '_AP_PAYMENT_INVOICES')
			EXEC('select * into ' + @log_db + '.dbo._bkp_' + @case_number + '_AP_PAYMENT_INVOICES from AP_PAYMENT_INVOICES where fac_id in (select fac_id from facility) ')

			IF OBJECT_ID(@log_db + '.dbo._bkp_' + @case_number + '_AP_COMPLETED_INVOICE', 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_' + @case_number + '_AP_COMPLETED_INVOICE')
			EXEC('select * into ' + @log_db + '.dbo._bkp_' + @case_number + '_AP_COMPLETED_INVOICE from AP_COMPLETED_INVOICE 
					where inv_id in (select batch_entry_id from ap_batch_entry_invoices where fac_id in (select fac_id from facility)) ')

			IF OBJECT_ID(@log_db + '.dbo._bkp_' + @case_number + '_ap_1099_revised_amounts', 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_' + @case_number + '_ap_1099_revised_amounts')
			EXEC('select * into ' + @log_db + '.dbo._bkp_' + @case_number + '_ap_1099_revised_amounts from ap_1099_revised_amounts 
					where batch_entry_id in (select batch_entry_id from AP_BATCH_ENTRY_INVOICES where fac_id in (select fac_id from facility)) ')

			IF OBJECT_ID(@log_db + '.dbo._bkp_' + @case_number + '_AP_BATCH_ENTRY_INVOICES', 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_' + @case_number + '_AP_BATCH_ENTRY_INVOICES')
			EXEC('select * into ' + @log_db + '.dbo._bkp_' + @case_number + '_AP_BATCH_ENTRY_INVOICES from AP_BATCH_ENTRY_INVOICES where fac_id in (select fac_id from facility)')

			IF OBJECT_ID(@log_db + '.dbo._bkp_' + @case_number + '_AP_BATCH_ENTRY_PAYMENTS', 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_' + @case_number + '_AP_BATCH_ENTRY_PAYMENTS')
			EXEC('select * into ' + @log_db + '.dbo._bkp_' + @case_number + '_AP_BATCH_ENTRY_PAYMENTS from AP_BATCH_ENTRY_PAYMENTS where fac_id in (select fac_id from facility)')
			
			IF OBJECT_ID(@log_db + '.dbo._bkp_' + @case_number + '_AP_BATCH', 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_' + @case_number + '_AP_BATCH')
			EXEC('select * into ' + @log_db + '.dbo._bkp_' + @case_number + '_AP_BATCH from AP_BATCH where fac_id in (select fac_id from facility)')

			IF OBJECT_ID(@log_db + '.dbo._bkp_' + @case_number + '_gl_recurring_entries', 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_' + @case_number + '_gl_recurring_entries')
			EXEC('select * into ' + @log_db + '.dbo._bkp_' + @case_number + '_gl_recurring_entries from gl_recurring_entries where fac_id in (select fac_id from facility)')

			IF OBJECT_ID(@log_db + '.dbo._bkp_' + @case_number + '_gl_recurring_transactions', 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_' + @case_number + '_gl_recurring_transactions')
			EXEC('select * into ' + @log_db + '.dbo._bkp_' + @case_number + '_gl_recurring_transactions from gl_recurring_transactions where fac_id in (select fac_id from facility)')

			IF OBJECT_ID(@log_db + '.dbo._bkp_' + @case_number + '_gl_recurring_batch', 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_' + @case_number + '_gl_recurring_batch')
			EXEC('select * into ' + @log_db + '.dbo._bkp_' + @case_number + '_gl_recurring_batch from gl_recurring_batch where fac_id in (select fac_id from facility)')

			IF OBJECT_ID(@log_db + '.dbo._bkp_' + @case_number + '_ap_recurring_transactions', 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_' + @case_number + '_ap_recurring_transactions')
			EXEC('select * into ' + @log_db + '.dbo._bkp_' + @case_number + '_ap_recurring_transactions from ap_recurring_transactions where fac_id in (select fac_id from facility)')

			IF OBJECT_ID(@log_db + '.dbo._bkp_' + @case_number + '_ap_recurring_invoices', 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_' + @case_number + '_ap_recurring_invoices')
			EXEC('select * into ' + @log_db + '.dbo._bkp_' + @case_number + '_ap_recurring_invoices from ap_recurring_invoices where fac_id in (select fac_id from facility)')

			IF OBJECT_ID(@log_db + '.dbo._bkp_' + @case_number + '_ap_recurring_batch', 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_' + @case_number + '_ap_recurring_batch')
			EXEC('select * into ' + @log_db + '.dbo._bkp_' + @case_number + '_ap_recurring_batch from ap_recurring_batch where fac_id in (select fac_id from facility)')

			IF OBJECT_ID(@log_db + '.dbo._bkp_' + @case_number + '_AP_1099_BATCH', 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_' + @case_number + '_AP_1099_BATCH')
			EXEC('select * into ' + @log_db + '.dbo._bkp_' + @case_number + '_AP_1099_BATCH from AP_1099_BATCH')
			

		END TRY
		BEGIN CATCH
			set @message = concat(OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE())
			print @message
			raiserror(@message, 16, 1)
		END CATCH
	END

	BEGIN TRY

	set @sql = 'DELETE FROM GL_TRANSACTIONS where fac_id in (select fac_id from facility)'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'DELETE FROM GL_BATCH_ENTRY_ERRORS where batch_entry_id in (select batch_entry_id from gl_batch_entry where fac_id in (select fac_id from facility))'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'DELETE FROM GL_BATCH_ENTRY where fac_id in (select fac_id from facility)'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'DELETE FROM GL_BATCH where fac_id in (select fac_id from facility)'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'DELETE from AP_TRANSACTIONS_ADJ WHERE transaction_id in (select transaction_id from ap_transactions where fac_id in (select fac_id from facility)) '
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'DELETE from AP_TRANSACTIONS where fac_id in (select fac_id from facility)'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'DELETE FROM GL_ACCOUNT_GROUPS_FACILITY_IDS where fac_id in (select fac_id from facility)'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'DELETE FROM GL_ACCOUNT_SEGMENT where fac_id in (select fac_id from facility)'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'DELETE FROM GL_BUDGETS where fac_id in (select fac_id from facility)'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'DELETE FROM GLAP_BANK_REC where fac_id in (select fac_id from facility)'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'DELETE FROM AP_PAYMENT_INVOICE_HISTORY 
		where inv_id in (select batch_entry_id from ap_batch_entry_invoices where fac_id in (select fac_id from facility))'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'DELETE FROM AP_PAYMENT_INVOICES where fac_id in (select fac_id from facility)'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'DELETE FROM AP_COMPLETED_INVOICE
		where inv_id in (select batch_entry_id from ap_batch_entry_invoices where fac_id in (select fac_id from facility))'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'DELETE FROM dbo.ap_1099_revised_amounts
		where batch_entry_id in (select batch_entry_id from AP_BATCH_ENTRY_INVOICES where fac_id in (select fac_id from facility))'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'DELETE FROM AP_BATCH_ENTRY_INVOICES where fac_id in (select fac_id from facility)'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'DELETE FROM AP_BATCH_ENTRY_PAYMENTS where fac_id in (select fac_id from facility)'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'DELETE FROM AP_BATCH where fac_id in (select fac_id from facility)'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'DELETE FROM gl_recurring_entries where fac_id in (select fac_id from facility)'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'DELETE FROM gl_recurring_transactions where fac_id in (select fac_id from facility)'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'DELETE FROM gl_recurring_batch where fac_id in (select fac_id from facility)'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'DELETE FROM ap_recurring_transactions where fac_id in (select fac_id from facility)'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'DELETE FROM ap_recurring_invoices where fac_id in (select fac_id from facility)'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'DELETE FROM ap_recurring_batch where fac_id in (select fac_id from facility)'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'DELETE AP_1099_BATCH'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	END TRY
	BEGIN CATCH
		set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
		exec (@sql_log)
		raiserror(@message, 16, 1)
	END CATCH
END
--=============================================================================================
IF @exclude_cp_lib = 'Y'
BEGIN 
	IF @if_bkp_tables = 'Y'
	BEGIN
		BEGIN TRY
			IF OBJECT_ID(@log_db + '.dbo._bkp_cp_triggered_item_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_cp_triggered_item_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_cp_triggered_item_' + @case_number + ' FROM cp_triggered_item 
					where trigger_id in (select trigger_id from cp_triggered_item) and client_id in (select client_id from clients where fac_id in (select fac_id from facility))')

			IF OBJECT_ID(@log_db + '.dbo._bkp_cp_triggers_map_assess_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_cp_triggers_map_assess_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_cp_triggers_map_assess_' + @case_number + ' FROM cp_triggers_map_assess
					where trigger_id in (select trigger_id from cp_triggered_item where client_id in (select client_id from clients WHERE fac_id in (select fac_id from facility)))')

			IF OBJECT_ID(@log_db + '.dbo._bkp_cp_triggered_custom_item_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_cp_triggered_custom_item_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_cp_triggered_custom_item_' + @case_number + ' FROM cp_triggered_custom_item
					where trigger_id in (select trigger_id from cp_triggered_item where client_id in (select client_id from clients WHERE fac_id in (select fac_id from facility)))')

			IF OBJECT_ID(@log_db + '.dbo._bkp_cp_std_need_cat_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_cp_std_need_cat_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_cp_std_need_cat_' + @case_number + ' from dbo.cp_std_need_cat
					where library_id in (select library_id from cp_std_library 
						where library_id in (select library_id from cp_std_library where deleted = ''N'' and brand_id IS NULL) and brand_id IS NULL)')

			IF OBJECT_ID(@log_db + '.dbo._bkp_cp_std_need_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_cp_std_need_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_cp_std_need_' + @case_number + ' from cp_std_need 
					where need_cat_id in (select need_cat_id from cp_std_need_cat 
						where library_id in (select library_id from cp_std_library 
							where library_id in (select library_id from cp_std_library where deleted = ''N'' and brand_id IS NULL) and brand_id IS NULL))')

			IF OBJECT_ID(@log_db + '.dbo._bkp_cp_std_goal_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_cp_std_goal_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_cp_std_goal_' + @case_number + ' from cp_std_goal
					where std_need_id in (select std_need_id from cp_std_need 
							where need_cat_id in (select need_cat_id from cp_std_need_cat where library_id in (select library_id from cp_std_library
								where library_id in (select library_id from cp_std_library where deleted = ''N'' and brand_id IS NULL) and brand_id IS NULL)))')

			IF OBJECT_ID(@log_db + '.dbo._bkp_cp_std_intervention_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_cp_std_intervention_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_cp_std_intervention_' + @case_number + ' from cp_std_intervention
					where std_need_id in (select std_need_id from cp_std_need 
						where need_cat_id in (select need_cat_id from cp_std_need_cat 
							where library_id in (select library_id from cp_std_library
								where library_id in (select library_id from cp_std_library where deleted = ''N'' and brand_id IS NULL) and brand_id IS NULL))) 
									and ISNULL(is_task, ''N'') <> ''Y''')

			IF OBJECT_ID(@log_db + '.dbo._bkp_cp_std_etiologies_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_cp_std_etiologies_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_cp_std_etiologies_' + @case_number + ' from cp_std_etiologies
					where deleted = ''N'' and std_need_id in (select std_need_id from cp_std_need 
						where need_cat_id in (select need_cat_id from cp_std_need_cat 
							where library_id in (select library_id from cp_std_library
								where library_id in (select library_id from cp_std_library where deleted = ''N'' and brand_id IS NULL) and brand_id IS NULL)))')

			IF OBJECT_ID(@log_db + '.dbo._bkp_cp_std_library_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_cp_std_library_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_cp_std_library_' + @case_number + ' from dbo.cp_std_library
					where library_id  in (select library_id from cp_std_library where deleted = ''N'' and brand_id IS NULL) and brand_id IS NULL')

			IF OBJECT_ID(@log_db + '.dbo._bkp_cp_rev_need_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_cp_rev_need_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_cp_rev_need_' + @case_number + ' from cp_rev_need
					WHERE std_need_id <> -1 AND fac_id in (select fac_id from facility)')

			IF OBJECT_ID(@log_db + '.dbo._bkp_cp_rev_goal_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_cp_rev_goal_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_cp_rev_goal_' + @case_number + ' from cp_rev_goal WHERE std_goal_id <> -1 AND  fac_id in (select fac_id from facility)')

			IF OBJECT_ID(@log_db + '.dbo._bkp_cp_rev_intervention_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_cp_rev_intervention_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_cp_rev_intervention_' + @case_number + ' from cp_rev_intervention 
				WHERE fac_id in (select fac_id from facility) and ISNULL(is_task, ''N'') <> ''Y''')


		END TRY
		BEGIN CATCH
			set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
			exec (@sql_log)
			raiserror(@message, 16, 1)
		END CATCH
	END

	BEGIN TRY

	set @sql = 'DELETE cp_triggers_map_assess where trigger_id in (select trigger_id from cp_triggered_item 
						where client_id in (select client_id from clients WHERE fac_id in (select fac_id from facility)))'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'DELETE cp_triggered_custom_item WHERE trigger_id in (select trigger_id from cp_triggered_item
						where client_id in (select client_id from clients WHERE fac_id in (select fac_id from facility)))'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'DELETE cp_triggered_item WHERE trigger_id in (select trigger_id from cp_triggered_item) and client_id in (select client_id from clients WHERE fac_id in (select fac_id from facility))'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'update cp_std_need_cat set deleted = ''Y'', deleted_Date = getdate(), deleted_by = ''' + @case_number + '''
					where library_id in (select library_id from cp_std_library
						where library_id in (select library_id from cp_std_library where deleted = ''N'' and brand_id IS NULL) and brand_id IS NULL) and deleted = ''N'''; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'update cp_std_need
				set deleted = ''Y'', deleted_Date = getdate(), deleted_by = ''' + @case_number + '''
				from cp_std_need where need_cat_id in (select need_cat_id from cp_std_need_cat 
					where library_id in (select library_id from cp_std_library
						where library_id in (select library_id from cp_std_library where deleted = ''N'' and brand_id IS NULL) and brand_id IS NULL)) and deleted = ''N'''; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'update cp_std_goal
				set deleted = ''Y'', deleted_Date = getdate(), deleted_by = ''' + @case_number + '''
				from cp_std_goal
					where std_need_id in (select std_need_id from cp_std_need 
						where need_cat_id in (select need_cat_id from cp_std_need_cat 
							where library_id in (select library_id from cp_std_library
								where library_id in (select library_id from cp_std_library where deleted = ''N'' and brand_id IS NULL) and brand_id IS NULL))) and deleted = ''N'''; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'update cp_std_intervention
				set deleted = ''Y'', deleted_Date = getdate(), deleted_by = ''' + @case_number + '''
				from cp_std_intervention
					where std_need_id in (select std_need_id from cp_std_need 
						where need_cat_id in (select need_cat_id from cp_std_need_cat 
							where library_id in (select library_id from cp_std_library
								where library_id in (select library_id from cp_std_library where deleted = ''N'' and brand_id IS NULL) and brand_id IS NULL)))
									and ISNULL(is_task, ''N'') <> ''Y'' and deleted = ''N'''; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'update cp_std_etiologies
				set deleted = ''Y'', deleted_Date = getdate(), deleted_by = ''' + @case_number + '''
				from cp_std_etiologies
					where deleted = ''N'' and std_need_id in (select std_need_id from cp_std_need 
						where need_cat_id in (select need_cat_id from cp_std_need_cat 
							where library_id in (select library_id from cp_std_library
								where library_id in (select library_id from cp_std_library where deleted = ''N'' and brand_id IS NULL) and brand_id IS NULL)))
									and deleted = ''N'''; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'update cp_std_library set deleted = ''Y'', deleted_Date = getdate(), deleted_by = ''' + @case_number + '''
					where library_id in (select library_id from cp_std_library where deleted = ''N'' and brand_id IS NULL) and brand_id IS NULL and deleted = ''N'''; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'update cp_rev_need set std_need_id = -1 where std_need_id <> -1 AND  fac_id in (select fac_id from facility)'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'UPDATE cp_rev_goal SET std_goal_id = -1 WHERE std_goal_id <> -1 AND  fac_id in (select fac_id from facility)'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'UPDATE cp_rev_intervention SET std_need_id = -1,std_intervention_id = -1 WHERE fac_id in (select fac_id from facility) and ISNULL(is_task, ''N'') <> ''Y'''; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)


	END TRY
	BEGIN CATCH
		set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
		exec (@sql_log)
		raiserror(@message, 16, 1)
	END CATCH
END
--=============================================================================================
IF @exclude_alert = 'Y'
BEGIN 
	IF @if_bkp_tables = 'Y'
	BEGIN
		BEGIN TRY
			IF OBJECT_ID(@log_db + '.dbo._bkp_cr_alert_triggered_item_type_category_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_cr_alert_triggered_item_type_category_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_cr_alert_triggered_item_type_category_' + @case_number + ' from cr_alert_triggered_item_type_category')

			IF OBJECT_ID(@log_db + '.dbo._bkp_cr_Alert_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_cr_Alert_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_cr_Alert_' + @case_number + ' from cr_alert')

			IF OBJECT_ID(@log_db + '.dbo._bkp_cr_client_highrisk_alerts_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_cr_client_highrisk_alerts_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_cr_client_highrisk_alerts_' + @case_number + ' from cr_client_highrisk_alerts')

			IF OBJECT_ID(@log_db + '.dbo._bkp_cr_std_alert_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_cr_std_alert_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_cr_std_alert_' + @case_number + ' from cr_std_alert')

			IF OBJECT_ID(@log_db + '.dbo._bkp_cr_std_alert_complex_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_cr_std_alert_complex_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_cr_std_alert_complex_' + @case_number + ' from cr_std_alert_complex')

			IF OBJECT_ID(@log_db + '.dbo._bkp_cr_std_highrisk_desc_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_cr_std_highrisk_desc_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_cr_std_highrisk_desc_' + @case_number + ' from cr_std_highrisk_desc')

			IF OBJECT_ID(@log_db + '.dbo._bkp_cp_std_trigger_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_cp_std_trigger_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_cp_std_trigger_' + @case_number + ' from cp_std_trigger')

			IF OBJECT_ID(@log_db + '.dbo._bkp_cr_std_alert_activation_audit_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_cr_std_alert_activation_audit_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_cr_std_alert_activation_audit_' + @case_number + ' from cr_std_alert_activation_audit')

			IF OBJECT_ID(@log_db + '.dbo._bkp_cr_std_alert_activation_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_cr_std_alert_activation_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_cr_std_alert_activation_' + @case_number + ' from cr_std_alert_activation')

			IF OBJECT_ID(@log_db + '.dbo._bkp_pp_client_highrisk_alert_view_history_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_pp_client_highrisk_alert_view_history_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_pp_client_highrisk_alert_view_history_' + @case_number + ' from pp_client_highrisk_alert_view_history')
			

		END TRY
		BEGIN CATCH
			set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
			exec (@sql_log)
			raiserror(@message, 16, 1)
		END CATCH
	END
	BEGIN TRY
	set @sql = 'delete cr_alert_triggered_item_type_category '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'update cr_alert set deleted = ''Y'', deleted_by = '''+ @case_number + ''', deleted_date = GETDATE() from cr_alert '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'delete pp_client_highrisk_alert_view_history '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'delete cr_client_highrisk_alerts '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'update cr_std_alert set deleted = ''Y'', deleted_by = '''+ @case_number + ''', deleted_date = GETDATE()
				where created_by not like ''pcc-%'' and created_by not like ''CORE-%'' and deleted <> ''Y'' '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'delete cr_std_alert_complex WHERE std_alert_id IN (SELECT std_alert_id FROM cr_std_alert WHERE deleted = ''Y'')'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'update cr_std_highrisk_desc set deleted = ''Y'', deleted_by = '''+ @case_number + ''', deleted_date = GETDATE()
				where ( std_alert_id IN (SELECT std_alert_id FROM cr_std_alert WHERE deleted = ''Y'') 
						OR (created_by NOT LIKE ''pcc-%'' AND created_by NOT LIKE ''CORE-%'')) and deleted <> ''Y'' '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'UPDATE cp_std_trigger SET deleted = ''Y'', deleted_by = '''+ @case_number + ''', deleted_date = GETDATE()
				WHERE triggered_item_id IN (SELECT std_alert_id FROM cr_std_alert WHERE deleted = ''Y'') AND trigger_type = ''A'' AND deleted <> ''Y'''; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'delete cr_std_alert_activation_audit where std_alert_id in (select std_alert_id from cr_std_alert where deleted = ''Y'')'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'delete cr_std_alert_activation where std_alert_id in (select std_alert_id from cr_std_alert where deleted = ''Y'')'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	END TRY
	BEGIN CATCH
		set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
		exec (@sql_log)
		raiserror(@message, 16, 1)
	END CATCH

END
--=============================================================================================
IF @exclude_qia = 'Y'
BEGIN 
	IF @if_bkp_tables = 'Y'
	BEGIN
		BEGIN TRY
			IF OBJECT_ID(@log_db + '.dbo._bkp_qa_activity_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_qa_activity_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_qa_activity_' + @case_number + ' from qa_activity')

			IF OBJECT_ID(@log_db + '.dbo._bkp_qa_category_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_qa_category_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_qa_category_' + @case_number + ' from qa_category')

			IF OBJECT_ID(@log_db + '.dbo._bkp_qa_exception_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_qa_exception_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_qa_exception_' + @case_number + ' from qa_exception')

			IF OBJECT_ID(@log_db + '.dbo._bkp_qa_exception_notes_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_qa_exception_notes_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_qa_exception_notes_' + @case_number + ' from qa_exception_notes')

			IF OBJECT_ID(@log_db + '.dbo._bkp_qa_function_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_qa_function_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_qa_function_' + @case_number + ' from qa_function')

			IF OBJECT_ID(@log_db + '.dbo._bkp_qa_improvement_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_qa_improvement_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_qa_improvement_' + @case_number + ' from qa_improvement')

			IF OBJECT_ID(@log_db + '.dbo._bkp_qa_ind_copyvalue_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_qa_ind_copyvalue_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_qa_ind_copyvalue_' + @case_number + ' from qa_ind_copyvalue')

			IF OBJECT_ID(@log_db + '.dbo._bkp_qa_ind_data_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_qa_ind_data_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_qa_ind_data_' + @case_number + ' from qa_ind_data')

			IF OBJECT_ID(@log_db + '.dbo._bkp_qa_ind_facility_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_qa_ind_facility_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_qa_ind_facility_' + @case_number + ' from qa_ind_facility')

			IF OBJECT_ID(@log_db + '.dbo._bkp_qa_ind_teams_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_qa_ind_teams_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_qa_ind_teams_' + @case_number + ' from qa_ind_teams')

			IF OBJECT_ID(@log_db + '.dbo._bkp_qa_ind_facility_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_qa_ind_facility_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_qa_ind_facility_' + @case_number + ' from qa_ind_facility')

			IF OBJECT_ID(@log_db + '.dbo._bkp_qa_indicator_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_qa_indicator_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_qa_indicator_' + @case_number + ' from qa_indicator')

			IF OBJECT_ID(@log_db + '.dbo._bkp_qa_qi_indicators_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_qa_qi_indicators_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_qa_qi_indicators_' + @case_number + ' from qa_qi_indicators')

			IF OBJECT_ID(@log_db + '.dbo._bkp_qa_temp_adj_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_qa_temp_adj_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_qa_temp_adj_' + @case_number + ' from qa_temp_adj')

			IF OBJECT_ID(@log_db + '.dbo._bkp_qa_threshold_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_qa_threshold_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_qa_threshold_' + @case_number + ' from qa_threshold')

		END TRY
		BEGIN CATCH
			set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
			exec (@sql_log)
			raiserror(@message, 16, 1)
		END CATCH
	END
	BEGIN TRY
	set @sql = 'delete qa_activity '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'delete qa_category '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'delete qa_exception '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'delete qa_exception_notes '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'delete qa_function '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'delete qa_improvement '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'delete qa_ind_copyvalue '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'delete qa_ind_data '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'delete qa_ind_facility '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'delete qa_ind_teams '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'delete qa_indicator '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'delete qa_qi_indicators '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'delete qa_temp_adj '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'delete qa_threshold '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	END TRY
	BEGIN CATCH
		set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
		exec (@sql_log)
		raiserror(@message, 16, 1)
	END CATCH
END	
--=============================================================================================
IF @exclude_sec_role = 'Y'
BEGIN 
	IF @if_bkp_tables = 'Y'
	BEGIN
		BEGIN TRY
			IF OBJECT_ID(@log_db + '.dbo._bkp_sec_user_role_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_sec_user_role_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_sec_user_role_' + @case_number + ' from sec_user_role')

			IF OBJECT_ID(@log_db + '.dbo._bkp_sec_role_alert_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_sec_role_alert_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_sec_role_alert_' + @case_number + ' from sec_role_alert')

			IF OBJECT_ID(@log_db + '.dbo._bkp_sec_role_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_sec_role_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_sec_role_' + @case_number + ' from sec_role')

		END TRY
		BEGIN CATCH
			set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
			exec (@sql_log)
			raiserror(@message, 16, 1)
		END CATCH
	END
	
	BEGIN TRY
	set @sql = 'delete from sec_user_role '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'delete FROM sec_role_alert where role_id in (select role_id from sec_role where (system_field <> ''Y'' or system_field is null)) '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'delete FROM sec_role where (system_field <> ''Y'' or system_field is null)'; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	END TRY
	BEGIN CATCH
		set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
		exec (@sql_log)
		raiserror(@message, 16, 1)
	END CATCH
END	
--=============================================================================================
IF @exclude_online_doc = 'Y'
BEGIN 
	IF @if_bkp_tables = 'Y'
	BEGIN
		BEGIN TRY

			IF OBJECT_ID(@log_db + '.dbo._bkp_upload_files_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_upload_files_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_upload_files_' + @case_number + ' from upload_files')

			IF OBJECT_ID(@log_db + '.dbo._bkp_file_metadata_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_file_metadata_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_file_metadata_' + @case_number + ' from file_metadata')

		END TRY
		BEGIN CATCH
			set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
			exec (@sql_log)
			raiserror(@message, 16, 1)
		END CATCH
	END
	
	BEGIN TRY

	set @sql = 'update file_metadata set deleted = ''Y'', deleted_Date=getdate(), deleted_by=''' + @case_number + ''' from file_metadata where deleted = ''N'''; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'delete from upload_files '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	END TRY
	BEGIN CATCH
		set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
		exec (@sql_log)
		raiserror(@message, 16, 1)
	END CATCH
END	
--=============================================================================================
IF @exclude_inc = 'Y'
BEGIN 
	IF @if_bkp_tables = 'Y'
	BEGIN
		BEGIN TRY

			IF OBJECT_ID(@log_db + '.dbo._bkp_inc_cp_task_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_inc_cp_task_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_inc_cp_task_' + @case_number + ' from inc_cp_task')

			IF OBJECT_ID(@log_db + '.dbo._bkp_inc_injury_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_inc_injury_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_inc_injury_' + @case_number + ' from inc_injury')
			
			IF OBJECT_ID(@log_db + '.dbo._bkp_inc_note_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_inc_note_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_inc_note_' + @case_number + ' from inc_note')
			
			IF OBJECT_ID(@log_db + '.dbo._bkp_inc_notified_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_inc_notified_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_inc_notified_' + @case_number + ' from inc_notified')
			
			IF OBJECT_ID(@log_db + '.dbo._bkp_inc_progress_note_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_inc_progress_note_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_inc_progress_note_' + @case_number + ' from inc_progress_note')
			
			IF OBJECT_ID(@log_db + '.dbo._bkp_inc_response_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_inc_response_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_inc_response_' + @case_number + ' from inc_response')
			
			IF OBJECT_ID(@log_db + '.dbo._bkp_inc_signature_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_inc_signature_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_inc_signature_' + @case_number + ' from inc_signature')
			
			IF OBJECT_ID(@log_db + '.dbo._bkp_inc_witness_phone_number_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_inc_witness_phone_number_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_inc_witness_phone_number_' + @case_number + ' from inc_witness_phone_number')
			
			IF OBJECT_ID(@log_db + '.dbo._bkp_inc_witness_statement_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_inc_witness_statement_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_inc_witness_statement_' + @case_number + ' from inc_witness_statement')
			
			IF OBJECT_ID(@log_db + '.dbo._bkp_inc_injury_audit_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_inc_injury_audit_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_inc_injury_audit_' + @case_number + ' from inc_injury_audit')
			
			IF OBJECT_ID(@log_db + '.dbo._bkp_inc_note_audit' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_inc_note_audit' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_inc_note_audit' + @case_number + ' from inc_note_audit')
			
			IF OBJECT_ID(@log_db + '.dbo._bkp_inc_witness_audit_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_inc_witness_audit_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_inc_witness_audit_' + @case_number + ' from inc_witness_audit')
			
			IF OBJECT_ID(@log_db + '.dbo._bkp_inc_incident_audit_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_inc_incident_audit_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_inc_incident_audit_' + @case_number + ' from inc_incident_audit')
						
			IF OBJECT_ID(@log_db + '.dbo._bkp_inc_response_audit_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_inc_response_audit_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_inc_response_audit_' + @case_number + ' from inc_response_audit')
						
			IF OBJECT_ID(@log_db + '.dbo._bkp_inc_signature_audit_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_inc_signature_audit_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_inc_signature_audit_' + @case_number + ' from inc_signature_audit')
						
			IF OBJECT_ID(@log_db + '.dbo._bkp_inc_incident_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_inc_incident_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_inc_incident_' + @case_number + ' from inc_incident')
						
			IF OBJECT_ID(@log_db + '.dbo._bkp_inc_std_signing_authority_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_inc_std_signing_authority_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_inc_std_signing_authority_' + @case_number + ' from inc_std_signing_authority')
						
			IF OBJECT_ID(@log_db + '.dbo._bkp_inc_std_pick_list_item_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_inc_std_pick_list_item_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_inc_std_pick_list_item_' + @case_number + ' from inc_std_pick_list_item')

		END TRY
		BEGIN CATCH
			set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
			exec (@sql_log)
			raiserror(@message, 16, 1)
		END CATCH
	END
	
	BEGIN TRY

	set @sql = 'delete from inc_cp_task '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'delete from inc_injury '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)
	
	set @sql = 'delete from inc_note '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)
	
	set @sql = 'delete from inc_notified '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)
	
	set @sql = 'delete from inc_progress_note '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)
	
	set @sql = 'delete from inc_response '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)
	
	set @sql = 'delete from inc_signature '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)
	
	set @sql = 'delete from inc_witness_phone_number '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)
	
	set @sql = 'delete from inc_witness_statement '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)
	
	set @sql = 'delete from inc_injury_audit '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)
	
	set @sql = 'delete from inc_note_audit '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)
	
	set @sql = 'delete from inc_witness_audit '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)
	
	set @sql = 'delete from inc_incident_audit '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)
	
	set @sql = 'delete from inc_response_audit '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)
	
	set @sql = 'delete from inc_signature_audit '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)
	
	set @sql = 'delete from inc_incident '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)
	
	set @sql = 'delete from inc_std_signing_authority '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)
	
	set @sql = 'delete from inc_std_pick_list_item where system_flag <> ''Y'' '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'update  inc_std_pick_list_item set retired_by = null, retired_date = null
				where system_flag = ''Y'' and retired_by is not null and retired_date is not null '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	END TRY
	BEGIN CATCH
		set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
		exec (@sql_log)
		raiserror(@message, 16, 1)
	END CATCH
END	
--=============================================================================================
IF @exclude_glapbank = 'Y'
BEGIN 
	IF @if_bkp_tables = 'Y'
	BEGIN
		BEGIN TRY

			IF OBJECT_ID(@log_db + '.dbo._bkp_gl_lib_accounts_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_gl_lib_accounts_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_gl_lib_accounts_' + @case_number + ' from gl_lib_accounts')

			IF OBJECT_ID(@log_db + '.dbo._bkp_gl_accounts_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_gl_accounts_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_gl_accounts_' + @case_number + ' from gl_accounts')
			
			IF OBJECT_ID(@log_db + '.dbo._bkp_glap_lib_banks_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_glap_lib_banks_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_glap_lib_banks_' + @case_number + ' from glap_lib_banks')
			
			IF OBJECT_ID(@log_db + '.dbo._bkp_glap_banks_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_glap_banks_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_glap_banks_' + @case_number + ' from glap_banks')
			
			IF OBJECT_ID(@log_db + '.dbo._bkp_gl_segments_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_gl_segments_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_gl_segments_' + @case_number + ' from gl_segments')

		END TRY
		BEGIN CATCH
			set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
			exec (@sql_log)
			raiserror(@message, 16, 1)
		END CATCH
	END
	
	BEGIN TRY

	set @sql = 'update a set deleted = ''Y'',deleted_by = ''' + @case_number + ''', deleted_date = getdate() from gl_lib_accounts a where deleted = ''N'''; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'delete from gl_accounts '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)
	
	set @sql = 'delete from glap_banks '; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)
	
	set @sql = 'update a set deleted = ''Y'',deleted_by = ''' + @case_number + ''', deleted_date = getdate() from glap_lib_banks a where deleted = ''N'''; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)
	
	set @sql = 'update a set deleted = ''Y'' from gl_segments a where deleted = ''N'''; 
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	END TRY
	BEGIN CATCH
		set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
		exec (@sql_log)
		raiserror(@message, 16, 1)
	END CATCH
END	

--=============================================================================================
IF @exclude_admin_notes = 'Y'
BEGIN 
	IF @if_bkp_tables = 'Y'
	BEGIN
		BEGIN TRY

			IF OBJECT_ID(@log_db + '.dbo._bkp_admin_note_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_admin_note_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_admin_note_' + @case_number + ' from admin_note')

			IF OBJECT_ID(@log_db + '.dbo._bkp_admin_note_type_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_admin_note_type_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_admin_note_type_' + @case_number + ' from admin_note_type')

		END TRY
		BEGIN CATCH
			set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
			exec (@sql_log)
			raiserror(@message, 16, 1)
		END CATCH
	END
	
	BEGIN TRY

	set @sql = 'delete from admin_Note'; 

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = 'delete from admin_note_type where system_flag <> ''1'''; 

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	END TRY
	BEGIN CATCH
		set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
		exec (@sql_log)
		raiserror(@message, 16, 1)
	END CATCH
END	

--=============================================================================================
IF @exclude_insur_companies = 'Y'
BEGIN 
	IF @if_bkp_tables = 'Y'
	BEGIN
		BEGIN TRY

			IF OBJECT_ID(@log_db + '.dbo._bkp_ar_lib_insurance_companies_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_ar_lib_insurance_companies_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_ar_lib_insurance_companies_' + @case_number + ' from ar_lib_insurance_companies')

			IF OBJECT_ID(@log_db + '.dbo._bkp_ar_insurance_addresses_' + @case_number, 'U') IS NOT NULL 
			EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_ar_insurance_addresses_' + @case_number)
			EXEC('select * into ' + @log_db + '.dbo._bkp_ar_insurance_addresses_' + @case_number + ' from ar_insurance_addresses')

		END TRY
		BEGIN CATCH
			set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
			exec (@sql_log)
			raiserror(@message, 16, 1)
		END CATCH
	END
	
	BEGIN TRY

	set @sql = 'select * into #temp from ar_lib_insurance_companies where description in 
			(select description from  ' + @template_db + '.dbo.ar_lib_insurance_companies where deleted <> ''Y'')
			
			update ar_lib_insurance_companies
			set deleted = ''Y'', deleted_by = ''' + @case_number + ''', deleted_date = getdate()
			from ar_lib_insurance_companies where insurance_id not in (select insurance_id from #temp) and deleted <> ''Y''

			update ar_insurance_addresses
			set deleted = ''Y'', deleted_by = ''' + @case_number + ''', deleted_date = getdate()
			from ar_insurance_addresses where insurance_id not in (select insurance_id from #temp) and deleted <> ''Y'''; 

		exec (@sql)
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)

	END TRY
	BEGIN CATCH
		set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
		exec (@sql_log)
		raiserror(@message, 16, 1)
	END CATCH
END	


		/*----------46 - allery_lib_custom_clean_up.sql----------*/
		BEGIN TRY

		IF @if_bkp_tables = 'Y'
		BEGIN
			BEGIN TRY

				IF OBJECT_ID(@log_db + '.dbo._bkp_allergy_lib_custom_' + @case_number, 'U') IS NOT NULL 
				EXEC('DROP TABLE ' + @log_db + '.dbo._bkp_allergy_lib_custom_' + @case_number)
				EXEC('select * into ' + @log_db + '.dbo._bkp_allergy_lib_custom_' + @case_number + ' from allergy_lib_custom')

			END TRY
			BEGIN CATCH
				set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
				set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
				exec (@sql_log)
				raiserror(@message, 16, 1)
			END CATCH
		END

		set @sql = 'DELETE FROM allergy_lib_custom where convert(varchar,custom_allergy_id) not in (select lib_allergy_id from allergy with (nolock)) '

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		END TRY
		BEGIN CATCH
			set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
			exec (@sql_log)
			raiserror(@message, 16, 1)
		END CATCH
































GO

print 'K_Operational_Branch/5_StoredProcedures/sproc_facacq_dcn_post_cleanups.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_facacq_dcn_post_cleanups.sql',getdate(),'4.4.10_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_facacq_dcn_post_std_fix.sql',getdate(),'4.4.10_06_CLIENT_K_Operational_Branch_US.sql')

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


if exists (select * from dbo.sysobjects where id = object_id(N'[operational].[sproc_facacq_dcn_post_std_fix]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [operational].[sproc_facacq_dcn_post_std_fix]
go

CREATE PROCEDURE [operational].[sproc_facacq_dcn_post_std_fix]
@source_db varchar(500)
,@org_id varchar(500) = NULL
,@source_prod_server_db varchar(500)
,@source_prod_org_code varchar(100) = NULL
,@destination_prod_org_code varchar(100) = NULL
,@fac_ids varchar(4000)
,@netsuite_ids varchar(4000)
,@case_number varchar(200)
,@prod_run varchar(2)
,@if_multi_to_single varchar(1) = 'N'
,@template_db varchar(200) = '[vmuspatmpcli01.pccprod.local].us_template_pccsingle_tmpltOH'
,@log_db varchar(200) = 'pcc_temp_storage'


-- ================================================================================= 
-- Script to create [operational].[sproc_facacq_dcn_post_std_fix] Procedure in Client Database
--						 
-- Written By:          Linlin Jing
-- Reviewed By:         
-- 
-- Script Type:         DDL 
-- Target DB Type:      Client Database
-- Target ENVIRONMENT:  Both
-- 
-- 
-- Re-Runable:          YES 
-- 
-- Description: Standard data issue fix after copying data to a new client database			
-- 
-- Special Instruction: 
-- 
-- =================================================================================

/*
-- =================================================================================

-- Run in destination

-- Sample execution: 

	exec [operational].[sproc_facacq_dcn_post_std_fix]
	@source_db = 'DS_Linlin_adde' --source DB, always on same server
	,@org_id = '12345' --optional, new org_id from destination, for data copy to new
	,@source_prod_server_db = 'DS_Linlin_adde'
	,@source_prod_org_code = 'adfsrcp' --optional, source production org code, for upload files location update, changes location only when both org codes are provided
	,@destination_prod_org_code = 'adfdstp' --optional, destination production org code, for upload files location update, changes location only when both org codes are provided
	,@fac_ids = '1,3'
	,@netsuite_ids = '5,7'
	,@case_number = 'EICase7654321'
	,@prod_run = 'N'
	,@template_db = 'd_m_m'
	,@log_db = 'd_m_m'

-- =================================================================================
*/


AS
declare @sql nvarchar(max)
declare @message varchar(4000)
declare @rowcount int = 0
declare @first_fac varchar(100)
declare @sql_log varchar(max)
declare @col varchar(max)

SET NOCOUNT ON;
SET CONTEXT_INFO 0xDC1000000;

		IF OBJECT_ID(@log_db + '.dbo.dcnlog_' + @case_number, 'U') IS NULL 

		EXEC('CREATE TABLE ' + @log_db + '.dbo.dcnlog_' + @case_number + '(rNo INT IDENTITY(1, 1),step VARCHAR(200),msg VARCHAR(max),msgTime DATETIME)')

		select top 1 @first_fac = convert(varchar,fac_id) from facility with (nolock) where deleted = 'N' and fac_id < 9001

--=============================================================================================
IF @if_multi_to_single = 'Y'
BEGIN
	BEGIN TRY

		IF (SELECT count(*)	FROM facility WHERE deleted = 'N' AND fac_id not in (9001,9999)) = 1

		BEGIN

			set @sql = 'UPDATE ar_lib_care_level_template
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE ar_lib_rate_schedule
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()
			WHERE deleted = ''N'''

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE user_field_types
			SET fac_id = ' + @first_fac + '
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE emc_ext_facilities
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE ar_lib_accounts
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()
			WHERE deleted = ''N'''

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE ar_item_category
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
			WHERE deleted = ''N'''

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE ar_lib_charge_codes
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()
			WHERE deleted = ''N'''

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE ar_lib_fee_schedule
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()
			WHERE deleted = ''N'''

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE ar_lib_submitter
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()
			WHERE deleted = ''N'''

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE ar_lib_payers
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()
			WHERE deleted = ''N'''

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE ar_lib_insurance_companies
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE ar_rate_type_category
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
			WHERE deleted = ''N'''

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE ar_lib_rate_type
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()
			WHERE deleted = ''N'''

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE common_code
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE census_codes
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE cp_fst_type
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE cp_interv_groups
			SET fac_id = ' + @first_fac + ''

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE cp_kardex_categories
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE cp_schedule
			SET fac_id = ' + @first_fac + '
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE cp_std_etiologies
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()
			WHERE std_need_id NOT IN (
					SELECT std_need_id
					FROM cp_std_need
					WHERE need_cat_id IN (
							SELECT need_cat_id
							FROM cp_std_need_cat
							WHERE library_id IN (
									SELECT library_id
									FROM cp_std_library
									WHERE description = ''COMS(R) Care Library''
									)
							)
					)'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE cp_std_frequency
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()
			WHERE system_key IS NULL'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE cp_std_goal
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()
			WHERE std_need_id NOT IN (
					SELECT std_need_id
					FROM cp_std_need
					WHERE need_cat_id IN (
							SELECT need_cat_id
							FROM cp_std_need_cat
							WHERE library_id IN (
									SELECT library_id
									FROM cp_std_library
									WHERE description = ''COMS(R) Care Library''
									)
							)
					)'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE cp_std_intervention
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()
			WHERE std_need_id NOT IN (
					SELECT std_need_id
					FROM cp_std_need
					WHERE need_cat_id IN (
							SELECT need_cat_id
							FROM cp_std_need_cat
							WHERE library_id IN (
									SELECT library_id
									FROM cp_std_library
									WHERE description = ''COMS(R) Care Library''
									)
							)
					)
				AND std_intervention_id NOT IN (
					SELECT std_intervention_id
					FROM dbo.cp_std_task_library_mapping
					WHERE library_id IN (
							SELECT library_id
							FROM cp_std_task_library
							WHERE description = ''COMS(R) Task Library''
							)
					)'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE cp_std_library
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()
			WHERE description <> ''COMS(R) Care Library'''

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE cp_std_need
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()
			WHERE need_cat_id NOT IN (
					SELECT need_cat_id
					FROM cp_std_need_cat
					WHERE library_id IN (
							SELECT library_id
							FROM cp_std_library
							WHERE description = ''COMS(R) Care Library''
							)
					)'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE cp_std_need_cat
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()
			WHERE library_id NOT IN (
					SELECT library_id
					FROM cp_std_library
					WHERE description = ''COMS(R) Care Library''
					)'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE cp_std_question
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()
			WHERE (
					brand_id IS NULL
					OR brand_id <> 1
					)'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE cp_std_schedule
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE cp_std_shift
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()
			WHERE system_key IS NULL'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE cp_std_task_library
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()
			WHERE description <> ''COMS(R) Task Library'''

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE cr_std_immunization
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE crm_codes
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE crm_field_config
			SET fac_id = ' + @first_fac + '
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE dashboard_view
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE diagnosis_codes
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()
			WHERE fac_id <> - 1'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE fac_message
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE filter_positions
			SET fac_id = ' + @first_fac + '
			WHERE NOT EXISTS (SELECT 1 FROM filter_positions fp WHERE fp.item_id = item_id and fp.position_id = position_id and fp.fac_id = ' + @first_fac + ')
			'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			set @sql = 'UPDATE gl_account_groups
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE gl_common_code
			SET fac_id = ' + @first_fac + '
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE gl_report_accounts
			SET fac_id = ' + @first_fac + '
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE gl_reports
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE id_type
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE inc_std_pick_list_item
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE pho_administration_record
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE pho_body_location
			SET fac_id = ' + @first_fac + '
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE pho_order_type
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE pho_phys_order_ranked
			SET fac_id = ' + @first_fac + ''

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE pho_schedule_audit
			SET fac_id = ' + @first_fac + '
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE pho_std_phys_order
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE pn_template
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE pn_text
			SET fac_id = ' + @first_fac + '
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE pn_type
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE prot_std_protocol_config
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE prov_state
			SET fac_id = ' + @first_fac + '
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE qa_category
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE qa_exception
			SET fac_id = ' + @first_fac + ''

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE qa_improvement
			SET fac_id = ' + @first_fac + '
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE qa_ind_data
			SET fac_id = ' + @first_fac + '
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE qa_ind_facility
			SET fac_id = ' + @first_fac + ''

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE qa_ind_teams
			SET fac_id = ' + @first_fac + ',reg_id = NULL'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)
	

			set @sql = 'UPDATE qa_indicator
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE qa_threshold
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE sec_role
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE user_field_types
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE wv_std_vitals
			SET fac_id = ' + @first_fac + ''

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE cp_qshift_detail
			SET fac_id = ' + @first_fac + ''

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE cp_qshift_detail_history
			SET fac_id = ' + @first_fac + ''

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE admin_errors
			SET fac_id = ' + @first_fac + '
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE as_batch_extract
			SET fac_id = ' + @first_fac + '
				,revision_by = ''' + @case_number + '''
				,revision_date = getdate()'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE as_batch_assess_extract
			SET fac_id = ' + @first_fac + ''

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE cp_duration_detail
			SET fac_id = ' + @first_fac + ''

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE configuration_parameter_audit
			SET fac_id = ' + @first_fac + ''

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE cp_duration_detail_history
			SET fac_id = ' + @first_fac + ''

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE automated_mds_enabling_step
			SET fac_id = ' + @first_fac + ''

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE cp_scheduled_detail
			SET fac_id = ' + @first_fac + '
			where fac_id not in (select fac_id from facility)'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE cp_scheduled_detail_history
			SET fac_id = ' + @first_fac + '
			where fac_id not in (select fac_id from facility)'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE pho_std_order
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE pho_std_order_set
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE pho_std_time
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE UPLOAD_CATEGORIES
			SET fac_id = ' + @first_fac + '
				,reg_id = NULL
				,state_code = NULL'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'INSERT INTO cp_std_intervention_fac
			SELECT ' + @first_fac + '
				,a.std_intervention_id
			FROM cp_std_intervention a
			WHERE deleted = ''N''
				AND NOT EXISTS (
					SELECT 1
					FROM cp_std_intervention_fac
					WHERE fac_id = ' + @first_fac + '
						AND std_intervention_id = a.std_intervention_id
					)'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'INSERT INTO cp_std_shift_fac
			SELECT ' + @first_fac + '
				,a.std_shift_id
			FROM cp_std_shift a
			WHERE deleted = ''N''
				AND NOT EXISTS (
					SELECT 1
					FROM cp_std_shift_fac
					WHERE fac_id = ' + @first_fac + '
						AND std_shift_id = a.std_shift_id
					)'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'INSERT INTO cp_std_fuq_fac
			SELECT ' + @first_fac + '
				,a.std_question_id
			FROM cp_std_question a
			WHERE deleted = ''N''
				AND NOT EXISTS (
					SELECT 1
					FROM cp_std_fuq_fac
					WHERE fac_id = ' + @first_fac + '
						AND question_id = a.std_question_id
					)'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'UPDATE module
			SET deleted = ''Y''
				,DELETED_BY = ''' + @case_number + '''
				,DELETED_DATE = getdate()
			WHERE module_id = 5'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)


			set @sql = 'update sec_user set admin_user_type = NULL where loginname not like ''%pcc-%'' and loginname not like ''[_]api[_]%'' and admin_user_type is not null'; 
				exec (@sql)
				set @rowcount = @@ROWCOUNT
				set @sql = replace(@sql,'''','''''')
				set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
				exec (@sql_log)
				set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
				exec (@sql_log)

			set @sql = 'update a set fac_id = ' + @first_fac + ' from ar_statement_configuration_template a where fac_id = -1'; 
				exec (@sql)
				set @rowcount = @@ROWCOUNT
				set @sql = replace(@sql,'''','''''')
				set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
				exec (@sql_log)
				set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
				exec (@sql_log)

			set @sql = 'delete from facility_group_mapping'; 
				exec (@sql)
				set @rowcount = @@ROWCOUNT
				set @sql = replace(@sql,'''','''''')
				set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
				exec (@sql_log)
				set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
				exec (@sql_log)
	
			set @sql = 'INSERT INTO ar_accounts SELECT account_id,f.fac_id,''N'',''' + @case_number + ''', getdate(),''' + @case_number + ''', getdate(), null, null
						FROM ar_lib_accounts lib CROSS JOIN facility f WHERE lib.deleted = ''N'' AND f.deleted = ''N'' AND f.fac_id not in (9001)
						AND NOT EXISTS (select 1 from ar_ACCOUNTS acct where acct.account_id =lib.account_id and acct.fac_id=f.fac_id) '; 
				exec (@sql)
				set @rowcount = @@ROWCOUNT
				set @sql = replace(@sql,'''','''''')
				set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
				exec (@sql_log)
				set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
				exec (@sql_log)

			set @sql = 'INSERT INTO ar_payers ([payer_id],[fac_id],[created_by],[created_date],[revision_by],[revision_date],[attention],[address1],[address2],[address3],[city]
			,[postal_zip],[prov_state],[country_id],[phone_office],[phone_office_ext],[phone_other],[phone_cell],[phone_pager],[phone_fax],[email_address],[system_field]
			,[account_id],[inv_message],[room_charge_bill_desc],[bill_null_rugs_days],[use_rate_desc],[default_address_id],[show_care_level],[submission_version],[allow_custom_rates]
			,[allow_account_override],[allow_discounts],[discount_amount],[discount_type],[discount_description],[discount_account_ids],[combine_discount],[group_txs_by]
			,[room_revenue_account_id],[daily_rate_field],[ub_facility_type],[ub_classification],[anc_on_discharge],[provider_override],[provider_name],[provider_address1]
			,[provider_address2],[provider_city],[provider_prov_state],[provider_postal_zip_code],[provider_country_id],[provider_tel],[private_bills_to],[ub_frequency],[anc_rate_field]
			,[allow_custom_std_rates],[allow_custom_reim_rates],[medicaid_override_id],[fee_schedule_id],[gl_ext],[submitter_id],[bill_advance_error_flag],[billing_calendar_id]
			,[stop_billing_day],[allow_rev_code_override],[export_ps_flag],[bill_unk_flag],[claim_1500_type],[claim_1500_place_service],[claim_1500_EMG],[claim_1500_family_plan_shd]
			,[claim_1500_family_plan_unshd],[claim_1500_ID_QUAL],[claim_1500_provider_id_unshd],[claim_1500_provider_id_shd],[prov_state_rules_code]
			,[std_max_daily_montly_incr],[std_max_daily_montly_perc_decr],[std_allow_max_daily_amount_change]
			,[std_max_daily_amount_increase],[std_max_daily_amount_decrease],[std_allow_max_monthly_amount_change],[std_max_monthly_amount_increase],[std_max_monthly_amount_decrease]
			,[reimb_custom_rates_limits],[reimb_allow_max_daily_monthly_change],[reimb_max_daily_montly_incr],[reimb_max_daily_montly_perc_decr],[reimb_allow_max_daily_amount_change]
			,[reimb_max_daily_amount_increase],[reimb_max_daily_amount_decrease],[reimb_allow_max_monthly_amount_change],[reimb_max_monthly_amount_increase],[reimb_max_monthly_amount_decrease]
			,[diagnosis_sheet_type_id],[populate_value_code_80_81],[primary_payer_covereddays_code_id],[primary_payer_noncovereddays_code_id],[nonprimary_payer_covereddays_code_id]
			,[nonprimary_payer_noncovereddays_code_id]
			,[qhs_waiver_flag],[qhs_auto_create_insurance_flag]
			,[claim_1500_provider_unshd_contact_id],[provider_county_id])
			SELECT p.payer_id,f.fac_id,''' + @case_number + ''',getdate(),''' + @case_number + '''
			,getdate(),p.attention,p.address1,p.address2,p.address3,p.city 
			,p.postal_zip,p.prov_state,p.country_id,p.phone_office,p.phone_office_ext,p.phone_other,p.phone_cell,p.phone_pager,p.phone_fax,p.email_address,p.system_field
			,p.account_id,p.inv_message,p.room_charge_bill_desc,p.bill_null_rugs_days,p.use_rate_desc,p.default_address_id,p.show_care_level,p.submission_version,p.allow_custom_rates
			,p.allow_account_override,p.allow_discounts,p.discount_amount,p.discount_type,p.discount_description,p.discount_account_ids,p.combine_discount,p.group_txs_by
			,p.room_revenue_account_id,p.daily_rate_field,p.ub_facility_type,p.ub_classification,p.anc_on_discharge,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
			,p.private_bills_to,p.ub_frequency,p.anc_rate_field
			,p.allow_custom_std_rates,p.allow_custom_reim_rates,p.medicaid_override_id,NULL,p.gl_ext,p.submitter_id,p.bill_advance_error_flag,p.billing_calendar_id
			,p.stop_billing_day,p.allow_rev_code_override,p.export_ps_flag,p.bill_unk_flag,p.claim_1500_type,p.claim_1500_place_service,p.claim_1500_EMG,p.claim_1500_family_plan_shd
			,p.claim_1500_family_plan_unshd,p.claim_1500_ID_QUAL,p.claim_1500_provider_id_unshd,p.claim_1500_provider_id_shd,p.prov_state_rules_code
			,p.std_max_daily_montly_incr,p.std_max_daily_montly_perc_decr,p.std_allow_max_daily_amount_change
			,p.std_max_daily_amount_increase,p.std_max_daily_amount_decrease,p.std_allow_max_monthly_amount_change,p.std_max_monthly_amount_increase,p.std_max_monthly_amount_decrease
			,p.reimb_custom_rates_limits,p.reimb_allow_max_daily_monthly_change,p.reimb_max_daily_montly_incr,p.reimb_max_daily_montly_perc_decr,p.reimb_allow_max_daily_amount_change
			,p.reimb_max_daily_amount_increase,p.reimb_max_daily_amount_decrease,p.reimb_allow_max_monthly_amount_change,p.reimb_max_monthly_amount_increase,p.reimb_max_monthly_amount_decrease
			,p.diagnosis_sheet_type_id,p.populate_value_code_80_81,p.primary_payer_covereddays_code_id,p.primary_payer_noncovereddays_code_id,p.nonprimary_payer_covereddays_code_id
			,p.nonprimary_payer_noncovereddays_code_id
			,p.qhs_waiver_flag,p.qhs_auto_create_insurance_flag
			,NULL,NULL
			FROM facility f
			CROSS JOIN ar_lib_payers p
			WHERE p.deleted = ''N'' AND f.deleted = ''N'' AND f.fac_id not in (9001)
			AND NOT EXISTS (select fac_id,payer_id from ar_payers where fac_id = f.fac_id and payer_id = p.payer_id)'; 
				exec (@sql)
				set @rowcount = @@ROWCOUNT
				set @sql = replace(@sql,'''','''''')
				set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
				exec (@sql_log)
				set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
				exec (@sql_log)

			set @sql = 'INSERT INTO ar_item_types SELECT ac.charge_code_id,f.fac_id,''' + @case_number + ''',getdate(),''' + @case_number + ''',getdate(),NULL
						FROM facility f CROSS JOIN ar_lib_charge_codes ac WHERE ac.deleted = ''N'' AND f.deleted = ''N'' AND f.fac_id not in (9001)
							AND NOT EXISTS (select fac_id,item_type_id from ar_item_types where fac_id = f.fac_id and item_type_id = ac.charge_code_id)'; 
				exec (@sql)
				set @rowcount = @@ROWCOUNT
				set @sql = replace(@sql,'''','''''')
				set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
				exec (@sql_log)
				set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
				exec (@sql_log)
	
			set @sql = 'INSERT INTO ar_item_date_range SELECT DISTINCT ac.charge_code_id,ac.effective_date,NULL,ac.default_charge_code_amt,NULL,NULL, f.fac_id, ac.markup_percentage
						FROM facility f CROSS JOIN ar_lib_charge_codes ac WHERE ac.deleted = ''N'' AND f.deleted = ''N'' AND f.fac_id not in (9001)
							AND NOT EXISTS (select fac_id,item_type_id from ar_item_date_range where fac_id = f.fac_id and item_type_id = ac.charge_code_id)'; 
				exec (@sql)
				set @rowcount = @@ROWCOUNT
				set @sql = replace(@sql,'''','''''')
				set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
				exec (@sql_log)
				set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
				exec (@sql_log)

			set @sql = 'INSERT INTO id_type_activation
						SELECT id_type_id,f.fac_id FROM id_type lib CROSS JOIN facility f
						WHERE lib.deleted = ''N'' AND f.deleted = ''N'' AND f.fac_id not in (9001)
							AND NOT EXISTS (select 1 from id_type_activation acct where acct.id_type_id =lib.id_type_id and acct.fac_id=f.fac_id) '; 
				exec (@sql)
				set @rowcount = @@ROWCOUNT
				set @sql = replace(@sql,'''','''''')
				set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
				exec (@sql_log)
				set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
				exec (@sql_log)

			set @sql = 'INSERT INTO pho_std_time_fac
						SELECT pho_std_time_id,f.fac_id
						FROM pho_std_time lib CROSS JOIN facility f
						WHERE lib.deleted = ''N'' AND f.deleted = ''N'' AND f.fac_id not in (9001)
							AND NOT EXISTS (select 1 from pho_std_time_fac acct where acct.pho_std_time_id = lib.pho_std_time_id and acct.fac_id=f.fac_id)  '; 
				exec (@sql)
				set @rowcount = @@ROWCOUNT
				set @sql = replace(@sql,'''','''''')
				set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
				exec (@sql_log)
				set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
				exec (@sql_log)

		END

	END TRY
	BEGIN CATCH
		set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
		exec (@sql_log)
		raiserror(@message, 16, 1)
	END CATCH

END


		/*----------12-Update SecUser.sql----------*/
		BEGIN TRY

		set @sql = 'update sec_user
		set fac_id = ' + @first_fac + '
		where  loginname like ''%pcc-%'' and fac_id not in (select fac_id from facility)'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		set @sql = 'update s set s.fac_id = f.facility_id
		from sec_user s join sec_user_facility f on s.userid = f.userid
		where s.loginname not like ''%pcc-%'''

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		set @sql = '
		update sec_user
		set fac_id = -1
		where loginname like ''%[_]api[_]%'' and fac_id <> -1'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)
		
		END TRY
		BEGIN CATCH
			set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
			exec (@sql_log)
			raiserror(@message, 16, 1)
		END CATCH

		/*----------13 insert Facility 9001.sql----------*/
IF @org_id is not NULL and @org_id <> ''
	BEGIN
		BEGIN TRY

		set @sql = 'insert into facility select * from ' + @source_db + '.dbo.facility where fac_id = 9001 and fac_id not in (select fac_id from facility)'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		set @sql = '
		insert into crm_configuration select * from ' + @source_db + '.dbo.crm_configuration where fac_id = 9001 and fac_id not in (select fac_id from crm_configuration)'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		set @sql = 'insert into crm_field_config select * from ' + @source_db + '.dbo.crm_field_config where fac_id = 9001 and fac_id not in (select fac_id from crm_field_config)'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		set @sql = 'delete from facility_history_extract where fac_id in (fac_id)'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		set @sql = 'delete from facility_history_extract_audit where fac_id in (fac_id)'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		set @sql = 'update facility set fac_uuid = NULL	from facility where fac_uuid is not NULL'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		END TRY
		BEGIN CATCH
			set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
			exec (@sql_log)
			raiserror(@message, 16, 1)
		END CATCH
	END

		/*----------16 - org_id_update.sql----------*/
		BEGIN TRY

		set @sql = 'update facility set org_id = '''+ @org_id + ''' where org_id <> ''' + @org_id + ''''

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		set @sql = 'update sec_user set org_id = '''+ @org_id + '''	where org_id <> ''' + @org_id + ''''

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		set @sql = 'update glap_config set org_id = '''+ @org_id + ''' where org_id <> ''' + @org_id + ''''

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		set @sql = 'update pns_subscription set org_id = '''+ @org_id + ''' where org_id <> ''' + @org_id + ''''

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		END TRY
		BEGIN CATCH
			set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
			exec (@sql_log)
			raiserror(@message, 16, 1)
		END CATCH


		/*----------17 - if using pharmacy integration.sql----------*/
		BEGIN TRY

		set @sql = 'update pho_pharmacy_order set inbound_message_id = NULL where inbound_message_id is not null'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		END TRY
		BEGIN CATCH
			set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
			exec (@sql_log)
			raiserror(@message, 16, 1)
		END CATCH


		/*----------23 - If SRC DB has multi history DB.sql----------*/
		BEGIN TRY

		set @sql = 'update pcc_data_aging_configuration set multihistory_db_prefix = NULL, use_multihistory_db = 0'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		END TRY
		BEGIN CATCH
			set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
			exec (@sql_log)
			raiserror(@message, 16, 1)
		END CATCH


		/*----------24 - update location file_metadata.sql----------*/
IF @source_prod_org_code is not null and @source_prod_org_code <> '' and @destination_prod_org_code is not null and @destination_prod_org_code <> ''
	BEGIN
		BEGIN TRY

		set @sql = '
		update dst set dst.location = src.location
		from file_metadata dst
		join ' + @source_prod_server_db + '.dbo.file_metadata src with (nolock)
		on dst.file_metadata_id = src.file_metadata_id
		where dst.fac_id in (select fac_id from facility) and dst.location <> src.location
		'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		set @sql = '
		update file_metadata set location = replace([location],''' + @source_prod_org_code + ''',''' + @destination_prod_org_code + ''')
		where fac_id in (select fac_id from facility)
		'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		END TRY
		BEGIN CATCH
			set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
			exec (@sql_log)
			raiserror(@message, 16, 1)
		END CATCH
	END

		/*----------25 - update ar_lib_rate_template multiple scoping.sql----------*/
		BEGIN TRY

		set @sql = '
		update a set fac_id = -1, reg_id = null, state_code = null
		from ar_lib_rate_template a
		where fac_id not in (-1) and fac_id not in (select fac_id from facility) 
		'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		END TRY
		BEGIN CATCH
			set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
			exec (@sql_log)
			raiserror(@message, 16, 1)
		END CATCH


		/*----------26 - post_insert_struckoutorders.sql----------*/
		BEGIN TRY

		SELECT @col = stuff((
			SELECT ',[' + col.name + ']'
			FROM sys.objects obj
			INNER JOIN sys.columns col ON obj.object_id = col.object_id
			WHERE obj.name = 'pho_admin_order_audit'
				AND is_computed = 0
			FOR XML path('')
			), 1, 1, '')

		set @sql = '
		set identity_insert pho_admin_order_audit ON
		insert into pho_admin_order_audit (' + @col + ')
		select * from ' + @source_db + '.dbo.pho_admin_order_audit with (nolock)
		where phys_order_id in (select phys_order_id from pho_phys_order_audit with (nolock) where fac_id in (select fac_id from facility))
		and audit_id not in (select audit_id from pho_admin_order_audit with (nolock))
		set identity_insert pho_admin_order_audit OFF
		'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		END TRY
		BEGIN CATCH
			set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
			exec (@sql_log)
			raiserror(@message, 16, 1)
		END CATCH



		/*----------31 - Unlink with file_metadata.sql----------*/
		BEGIN TRY

		set @sql = 'update AR_INVOICE_BATCH	set file_metadata_id = NULL	from AR_INVOICE_BATCH where file_metadata_id is not null'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		
		set @sql = 'update EDI_IMPORT set file_metadata_id = NULL from EDI_IMPORT where file_metadata_id is not null'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)


		END TRY
		BEGIN CATCH
			set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
			exec (@sql_log)
			raiserror(@message, 16, 1)
		END CATCH


		/*----------34 - ar_import_config Post Insert.sql----------*/
		BEGIN TRY

		set @sql = 'update edi_import set import_config_id = NULL from edi_import where import_config_id is not null'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		set @sql = 'delete from ar_import_config'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		SELECT @col = stuff((
		SELECT ',[' + col.name + ']'
		FROM sys.objects obj
		INNER JOIN sys.columns col ON obj.object_id = col.object_id
		WHERE obj.name = 'ar_import_config'
			AND is_computed = 0
		FOR XML path('')
		), 1, 1, '')

		set @sql = '
		set identity_insert ar_import_config on

		insert into ar_import_config
		(' + @col + ')
		select ' + @col + '
		from ' + @template_db + '.dbo.ar_import_config with (nolock)

		set identity_insert ar_import_config off
		'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		END TRY
		BEGIN CATCH
			set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
			exec (@sql_log)
			raiserror(@message, 16, 1)
		END CATCH

		/*----------44 - api_authorization PostInsert.sql----------*/
		BEGIN TRY

		set @sql = 'delete from api_authorization_audit'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		set @sql = 'delete from api_authorization'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		SELECT @col = stuff((
		SELECT ',[' + col.name + ']'
		FROM sys.objects obj
		INNER JOIN sys.columns col ON obj.object_id = col.object_id
		WHERE obj.name = 'api_authorization'
			AND is_computed = 0
		FOR XML path('')
		), 1, 1, '')

		set @sql = '
		set identity_insert api_authorization on

		insert into api_authorization
		(' + @col + ')
		select ' + @col + '
		from ' + @template_db + '.dbo.api_authorization with (nolock)

		set identity_insert api_authorization off
		'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)


		SELECT @col = stuff((
		SELECT ',[' + col.name + ']'
		FROM sys.objects obj
		INNER JOIN sys.columns col ON obj.object_id = col.object_id
		WHERE obj.name = 'api_authorization_audit'
			AND is_computed = 0
		FOR XML path('')
		), 1, 1, '')

		set @sql = '
		set identity_insert api_authorization_audit on

		insert into api_authorization_audit
		(' + @col + ')
		select ' + @col + '
		from ' + @template_db + '.dbo.api_authorization_audit with (nolock)

		set identity_insert api_authorization_audit off
		'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		END TRY
		BEGIN CATCH
			set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
			exec (@sql_log)
			raiserror(@message, 16, 1)
		END CATCH


		/*----------35 - Facility Mapping - update netsuite_company_id.sql----------*/
		BEGIN TRY
		select identity(int,1,1) as row, ff.items 
		into #temp_fac_ids
		from SPLIT(@fac_ids,',') ff 

		select identity(int,1,1) as row,ns.items 
		into #temp_ns_ids
		from SPLIT(@netsuite_ids,',') ns 

		update fm
		set fm.netsuite_company_id = b.items
		,fm.revision_by = @case_number
		,fm.revision_date = getdate()
		--select *
		from facility_mapping fm
		join #temp_fac_ids a on a.items = fm.fac_id
		join #temp_ns_ids b on a.row = b.row


		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' 
		+ '--(Fac_ids: ' + isnull(@fac_ids,'') + ' updated with NetSuiteID: ' + isnull(@netsuite_ids,'') + ''',getdate()'
		exec (@sql_log)

		END TRY
		BEGIN CATCH
			set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
			exec (@sql_log)
			raiserror(@message, 16, 1)
		END CATCH

		/*----------36 - COMS UDA Libraries Activation Clean up.sql----------*/
		BEGIN TRY

		set @sql = 'delete from as_std_assessment_facility
		where std_assess_id in (select std_assess_id from as_std_assessment where description like ''COMS%'')
		and std_assess_id in (select std_assess_id from as_std_assessment_system_assessment_mapping)'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		set @sql = '
		update branded
		set value = ''N'', enabled_by = NULL, enabled_date = NULL, disabled_by = ''' + @case_number + ''', disabled_date = getdate()
		FROM branded_library_configuration partner
		JOIN branded_library_feature_configuration branded ON branded.brand_id = partner.brand_id
		where partner.brand_name = ''Clinical Standard Content''
		and branded.value = ''Y''
		'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		set @sql = '
		update branded
		set value = ''N'', enabled_by = NULL, enabled_date = NULL, disabled_by = ''' + @case_number + ''', disabled_date = getdate()
		FROM branded_library_configuration partner
		JOIN branded_library_feature_configuration branded ON branded.brand_id = partner.brand_id
		where partner.brand_name like ''eINTERACT%''
		and branded.value = ''Y''
		'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		set @sql = '
		update branded
		set value = ''N'', enabled_by = NULL, enabled_date = NULL, disabled_by = ''' + @case_number + ''', disabled_date = getdate()
		FROM branded_library_configuration partner
		JOIN branded_library_feature_configuration branded ON branded.brand_id = partner.brand_id
		where partner.brand_name = ''PCC Infection Control solution''
		and branded.value = ''Y''
		'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		END TRY
		BEGIN CATCH
			set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
			exec (@sql_log)
			raiserror(@message, 16, 1)
		END CATCH


		/*----------42 - GL_CONFIGURATION Invalid Fac_id Update.sql----------*/
		BEGIN TRY

		set @sql = '
		update gl_configuration	set imported_fac_id = NULL from gl_configuration where imported_fac_id is not null and imported_fac_id not in (select fac_id from facility)
		'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		END TRY
		BEGIN CATCH
			set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
			exec (@sql_log)
			raiserror(@message, 16, 1)
		END CATCH

		/*----------Post Check CP_SEC_USER_AUDIT.sql----------*/

		BEGIN TRY

		SELECT @col = stuff((
		SELECT ',[' + col.name + ']'
		FROM sys.objects obj
		INNER JOIN sys.columns col ON obj.object_id = col.object_id
		WHERE obj.name = 'cp_sec_user_audit'
			AND is_computed = 0
		FOR XML path('')
		), 1, 1, '')

		set @sql = '
		create table #cp_sec_user_audit (cp_sec_user_audit_id int)

		insert into #cp_sec_user_audit select created_user_audit_id from allergy where created_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select revision_user_audit_id from allergy where revision_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select strikeout_user_audit_id from allergy_strikeout where strikeout_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select created_user_audit_id from as_assess_schedule_clear_response where created_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select created_user_audit_id from as_footnote where created_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select cp_sec_user_audit_id from cp_duration_detail_created_info where cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select cp_sec_user_audit_id from cp_duration_documentation where cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select cp_sec_user_audit_id from cp_duration_documentation_history where cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select cp_sec_user_audit_id from cp_duration_documentation_strikeout where cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select cp_sec_user_audit_id from cp_duration_documentation_strikeout_history where cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select cp_sec_user_audit_id from cp_prn_documentation where cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select cp_sec_user_audit_id from cp_prn_documentation_history where cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select cp_sec_user_audit_id from cp_prn_documentation_strikeout where cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select cp_sec_user_audit_id from cp_prn_documentation_strikeout_history where cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select cp_sec_user_audit_id from cp_qshift_detail_created_info where cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select cp_sec_user_audit_id from cp_qshift_documentation where cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select cp_sec_user_audit_id from cp_qshift_documentation_history where cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select cp_sec_user_audit_id from cp_qshift_documentation_strikeout where cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select cp_sec_user_audit_id from cp_qshift_documentation_strikeout_history where cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select cp_sec_user_audit_id from cp_scheduled_detail_created_info where cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select cp_sec_user_audit_id from cp_scheduled_documentation where cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select cp_sec_user_audit_id from cp_scheduled_documentation_history where cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select cp_sec_user_audit_id from cp_scheduled_documentation_strikeout where cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select cp_sec_user_audit_id from cp_scheduled_documentation_strikeout_history where cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select strikeout_user_audit_id from diagnosis_strikeout where strikeout_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select sec_user_audit_id from immunization_strikeout where sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select confirmed_by_audit_id from pho_admin_order_audit_useraudit where confirmed_by_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select created_by_audit_id from pho_admin_order_audit_useraudit where created_by_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select edited_by_audit_id from pho_admin_order_audit_useraudit where edited_by_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select confirmed_by_audit_id from pho_admin_order_useraudit where confirmed_by_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select created_by_audit_id from pho_admin_order_useraudit where created_by_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select edited_by_audit_id from pho_admin_order_useraudit where edited_by_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select created_cp_sec_user_audit_id from pho_formulary where created_cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select published_cp_sec_user_audit_id from pho_formulary where published_cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select revision_cp_sec_user_audit_id from pho_formulary where revision_cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select created_cp_sec_user_audit_id from pho_formulary_audit where created_cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select published_cp_sec_user_audit_id from pho_formulary_audit where published_cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select revision_cp_sec_user_audit_id from pho_formulary_audit where revision_cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select created_cp_sec_user_audit_id from pho_formulary_item_custom_library where created_cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select revision_cp_sec_user_audit_id from pho_formulary_item_custom_library where revision_cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select created_cp_sec_user_audit_id from pho_formulary_item_custom_library_audit where created_cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select revision_cp_sec_user_audit_id from pho_formulary_item_custom_library_audit where revision_cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select created_cp_sec_user_audit_id from pho_formulary_item_medispan where created_cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select revision_cp_sec_user_audit_id from pho_formulary_item_medispan where revision_cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select created_cp_sec_user_audit_id from pho_formulary_item_medispan_audit where created_cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select revision_cp_sec_user_audit_id from pho_formulary_item_medispan_audit where revision_cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select created_cp_sec_user_audit_id from pho_formulary_item_medispan_din where created_cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select revision_cp_sec_user_audit_id from pho_formulary_item_medispan_din where revision_cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select created_cp_sec_user_audit_id from pho_formulary_item_medispan_din_audit where created_cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select revision_cp_sec_user_audit_id from pho_formulary_item_medispan_din_audit where revision_cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select cp_sec_user_audit_id from pho_phys_order_allergy_acknowledgement where cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select confirmed_by_audit_id from pho_phys_order_audit_useraudit where confirmed_by_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select created_by_audit_id from pho_phys_order_audit_useraudit where created_by_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select edited_by_audit_id from pho_phys_order_audit_useraudit where edited_by_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select cp_sec_user_audit_id from pho_phys_order_blackbox_acknowledgement where cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select cp_sec_user_audit_id from pho_phys_order_drug_acknowledgement where cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select created_cp_sec_user_audit_id from pho_phys_order_med_professional where created_cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select created_by_audit_id from pho_phys_order_useraudit where created_by_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select edited_by_audit_id from pho_phys_order_useraudit where edited_by_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select confirmed_by_audit_id from pho_phys_order_useraudit where confirmed_by_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select followupby_useraudit_id from pho_schedule_details_followup_useraudit where followupby_useraudit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select performby_useraudit_id from pho_schedule_details_performby_useraudit where performby_useraudit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select strikeout_followupby_useraudit_id from pho_schedule_details_strikeout_followup_useraudit where strikeout_followupby_useraudit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select strikeout_performby_useraudit_id from pho_schedule_details_strikeout_performby_useraudit where strikeout_performby_useraudit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select created_by_audit_id from pho_std_order_set where created_by_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select published_by_audit_id from pho_std_order_set where published_by_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select reactivated_by_audit_id from pho_std_order_set where reactivated_by_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select retired_by_audit_id from pho_std_order_set where retired_by_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select revision_by_audit_id from pho_std_order_set where revision_by_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select created_by_audit_id from pho_std_order where created_by_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select published_by_audit_id from pho_std_order where published_by_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select reactivated_by_audit_id from pho_std_order where reactivated_by_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select retired_by_audit_id from pho_std_order where retired_by_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select revision_by_audit_id from pho_std_order where revision_by_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select cp_sec_user_audit_id from client_next_review_date_tracking where cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select cp_sec_user_audit_id from pho_client_review where cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select cp_sec_user_audit_id from cp_unscheduled_documentation where cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select cp_sec_user_audit_id from cp_unscheduled_documentation_strikeout where cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select cp_sec_user_audit_id from cp_unscheduled_documentation_history where cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select cp_sec_user_audit_id from cp_unscheduled_documentation_strikeout_history where cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select created_user_audit_id from allergy_audit where created_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select revision_user_audit_id from allergy_audit where revision_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select cp_sec_user_audit_id from pho_order_related_value where cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select createdby_useraudit_id from pho_schedule_details_reminder where createdby_useraudit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select cp_sec_user_audit_id from pho_phys_order_sign where cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)
		insert into #cp_sec_user_audit select cp_sec_user_audit_id from configuration_parameter_history where cp_sec_user_audit_id not in (select cp_sec_user_audit_id from cp_sec_user_audit)

		set IDENTITY_INSERT cp_sec_user_audit ON

		insert into cp_sec_user_audit (' + @col + ')
		select ' + @col + ' from ' + @source_db +  '.dbo.cp_sec_user_audit with (nolock)
		where cp_sec_user_audit_id in (select cp_sec_user_audit_id from #cp_sec_user_audit)
		'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		END TRY
		BEGIN CATCH
			set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
			exec (@sql_log)
			raiserror(@message, 16, 1)
		END CATCH


		/*----------Different Fix from Step 6----------*/

		BEGIN TRY

		declare @colselect varchar(2000)

		set @col = stuff((
							SELECT ',[' + col.name + ']'
							FROM sys.objects obj
							INNER JOIN sys.columns col ON obj.object_id = col.object_id
							WHERE obj.name = 'as_std_pick_list_item'
								AND is_computed = 0
							FOR XML path('')
							), 1, 1, '')
		set @colselect = stuff((
							SELECT ',a.[' + col.name + ']'
							FROM sys.objects obj
							INNER JOIN sys.columns col ON obj.object_id = col.object_id
							WHERE obj.name = 'as_std_pick_list_item'
								AND is_computed = 0
							FOR XML path('')
							), 1, 1, '')

		set @SQL = 'INSERT INTO as_std_pick_list_item (' + @col + ') SELECT ' + @colselect + 'FROM ' + @source_db + '.dbo.as_std_pick_list_item AS a 
					WHERE a.pick_list_id not in (select pick_list_id from as_std_pick_list_item) and a.pick_list_id in (select pick_list_id from as_std_question)'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)


		set @col = stuff((
					SELECT ',[' + col.name + ']'
					FROM sys.objects obj
					INNER JOIN sys.columns col ON obj.object_id = col.object_id
					WHERE obj.name = 'as_std_pick_list'
						AND is_computed = 0
					FOR XML path('')
					), 1, 1, '')

		set @colselect = replace (
							stuff((
							SELECT ',[' + col.name + ']'
							FROM sys.objects obj
							INNER JOIN sys.columns col ON obj.object_id = col.object_id
							WHERE obj.name = 'as_std_pick_list'
								AND is_computed = 0
							FOR XML path('')
							), 1, 1, ''),'[fac_id]','''-1''')

		set @SQL = 'INSERT INTO as_std_pick_list (' + @col + ') SELECT ' + @colselect + 'FROM ' + @source_db + '.dbo.as_std_pick_list 
					WHERE pick_list_id not in (select pick_list_id from as_std_pick_list) and pick_list_id in (select pick_list_id from as_std_question)'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		END TRY
		BEGIN CATCH
			set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
			exec (@sql_log)
			raiserror(@message, 16, 1)
		END CATCH

		/*----------Different Fix from Step 6----------*/

		BEGIN TRY

		set @SQL = 'DELETE FROM facility_scheduling_cycle '

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)


		set @SQL = 'INSERT INTO dbo.facility_scheduling_cycle (fac_id,run_day)
					SELECT fac_id,(CASE WHEN fac_id % 20 <> 0 THEN fac_id % 20 ELSE 20 END) + 6 AS runDay FROM dbo.facility
					WHERE ((FACILITY.fac_id <> 9999 AND (FACILITY.inactive IS NULL OR FACILITY.inactive <> ''Y'') AND (FACILITY.is_live <> ''N'' OR FACILITY.is_live IS NULL))) AND ((FACILITY.DELETED = ''N'')) '

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)


		set @SQL = 'UPDATE sec_user SET email = '''',alt_email = '''' WHERE ((email IS NOT NULL	AND email <> '''') OR (alt_email IS NOT NULL AND alt_email <> ''''))'

		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

		END TRY
		BEGIN CATCH
			set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
			exec (@sql_log)
			raiserror(@message, 16, 1)
		END CATCH

		/*----------Different Fix from Step 6----------*/

		BEGIN TRY

		declare @nSQL nvarchar(max)
		declare @rcnt int = 0

		set @nSQL = 
		'select @rcnt = count(1) from ' + @source_db + '.dbo.emrlink_client_sync_tracking src with (nolock) where src.client_id in (select client_id from clients with (nolock))
		'
		--PRINT @nSQL
		EXEC Sp_executesql @nSQL, N'@rcnt INT OUTPUT', @rcnt OUTPUT

		if @rcnt <> 0 
			BEGIN

				set @SQL = '
				set identity_insert emrlink_client_sync_tracking on

				insert into emrlink_client_sync_tracking (emrlink_client_sync_tracking_id,client_id,cp_sec_user_audit_id,created_date,last_sync_date)
				select src.emrlink_client_sync_tracking_id,src.client_id,src.cp_sec_user_audit_id,src.created_date,src.last_sync_date
				from ' + @source_db + '.dbo.emrlink_client_sync_tracking src with (nolock)
				join clients map2 on src.client_id = map2.client_id

				set identity_insert emrlink_client_sync_tracking off'

				exec (@sql)
				set @rowcount = @@ROWCOUNT
				set @sql = replace(@sql,'''','''''')
				set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
				exec (@sql_log)
				set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
				exec (@sql_log)

				set @SQL = '
				set identity_insert emrlink_order_sync_tracking on

				insert into emrlink_order_sync_tracking (emrlink_order_sync_tracking_id,client_id,emrlink_order_id,phys_order_id,last_sync_date)
				select src.emrlink_order_sync_tracking_id,src.client_id,src.emrlink_order_id,src.phys_order_id,src.last_sync_date
				from ' + @source_db + '.dbo.emrlink_order_sync_tracking src with (nolock)
				join clients map2 on src.client_id = map2.client_id
				join pho_phys_order map3 on src.phys_order_id = map3.phys_order_id

				set identity_insert emrlink_order_sync_tracking off'

				exec (@sql)
				set @rowcount = @@ROWCOUNT
				set @sql = replace(@sql,'''','''''')
				set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
				exec (@sql_log)
				set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
				exec (@sql_log)

				set @SQL = '
				set identity_insert emrlink_order_sync_error_tracking on

				insert into emrlink_order_sync_error_tracking (emrlink_order_sync_error_tracking_id,client_id,emrlink_order_id,phys_order_id,order_desc,error_message,last_sync_date)
				select src.emrlink_order_sync_error_tracking_id,src.client_id,src.emrlink_order_id,src.phys_order_id,src.order_desc,src.error_message,src.last_sync_date
				from ' + @source_db + '.dbo.emrlink_order_sync_error_tracking src with (nolock)
				join clients map2 on src.client_id = map2.client_id
				join pho_phys_order map3 on src.phys_order_id = map3.phys_order_id

				set identity_insert emrlink_order_sync_error_tracking off'

				exec (@sql)
				set @rowcount = @@ROWCOUNT
				set @sql = replace(@sql,'''','''''')
				set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
				exec (@sql_log)
				set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
				exec (@sql_log)


				set @SQL = '
				set identity_insert pho_lab_integrated_order_detail on

				insert into pho_lab_integrated_order_detail (lab_order_detail_id,phys_order_id,lab_report_id,urgency_type_id,report_status_id,created_by,created_date,revision_by,revision_date,vendor_phys_order_id)
				select src.lab_order_detail_id,src.phys_order_id,src.lab_report_id,src.urgency_type_id,src.report_status_id,src.created_by,src.created_date,src.revision_by,src.revision_date,src.vendor_phys_order_id
				from ' + @source_db + '.dbo.pho_lab_integrated_order_detail src with (nolock)
				join pho_phys_order map2 on src.phys_order_id = map2.phys_order_id
				join result_lab_report map3 on src.lab_report_id = map3.lab_report_id

				set identity_insert pho_lab_integrated_order_detail off
				'

				exec (@sql)
				set @rowcount = @@ROWCOUNT
				set @sql = replace(@sql,'''','''''')
				set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
				exec (@sql_log)
				set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
				exec (@sql_log)


				set @SQL = '
				set identity_insert pho_rad_integrated_order_detail on

				insert into pho_rad_integrated_order_detail (rad_order_detail_id,phys_order_id,radiology_report_id,urgency_type_id,report_status_id,created_by,created_date,revision_by,revision_date,vendor_phys_order_id)
				select src.rad_order_detail_id,src.phys_order_id,src.radiology_report_id,src.urgency_type_id,src.report_status_id,src.created_by,src.created_date,src.revision_by,src.revision_date,src.vendor_phys_order_id
				from ' + @source_db + '.dbo.pho_rad_integrated_order_detail src with (nolock)
				join pho_phys_order map2 on src.phys_order_id = map2.phys_order_id
				join result_radiology_report map3 on src.radiology_report_id = map3.radiology_report_id

				set identity_insert pho_rad_integrated_order_detail off
				'

				exec (@sql)
				set @rowcount = @@ROWCOUNT
				set @sql = replace(@sql,'''','''''')
				set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
				exec (@sql_log)
				set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
				exec (@sql_log)

			END


		END TRY
		BEGIN CATCH
			set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
			exec (@sql_log)
			raiserror(@message, 16, 1)
		END CATCH

	IF @prod_run = 'Y'
		BEGIN
			BEGIN TRY
			delete from pcc_global_primary_key where table_name = 'as_submission_accounts_mds_30'

			set @sql = '
			declare @rowcnt int, @NID int

			select identity(int,0,1) as row, f.fac_id, 0 as [status], test_status, cms_account_name, cms_account_description, cms_url, account_type
			into #t_as_submission_accounts_mds_30
			from ' + @template_db + '.dbo.as_submission_accounts_mds_30 a, facility f
			where a.fac_id = 1

			set @rowcnt = @@rowcount 
			IF @rowcnt > 0
			BEGIN
				EXECUTE get_next_primary_key ''as_submission_accounts_mds_30'',''account_id'', @NID OUTPUT, @rowcnt
				print @NID

				insert into as_submission_accounts_mds_30 (account_id, fac_id, status, test_status, cms_account_name, cms_account_description, cms_url, revision_by, revision_date, account_type)
				select @NID + row,fac_id, status, test_status, cms_account_name, cms_account_description, cms_url,''' + @case_number + ''',getdate(), account_type
				from #t_as_submission_accounts_mds_30
			END

			Drop table #t_as_submission_accounts_mds_30
			'

			exec (@sql)
			set @rowcount = @@ROWCOUNT
			set @sql = replace(@sql,'''','''''')
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
			exec (@sql_log)
			set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
			exec (@sql_log)

			END TRY
			BEGIN CATCH
				set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
				set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
				exec (@sql_log)
				raiserror(@message, 16, 1)
			END CATCH


END



GO

print 'K_Operational_Branch/5_StoredProcedures/sproc_facacq_dcn_post_std_fix.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_facacq_dcn_post_std_fix.sql',getdate(),'4.4.10_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_facacq_dcn_pre_std_fix.sql',getdate(),'4.4.10_06_CLIENT_K_Operational_Branch_US.sql')

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


if exists (select * from dbo.sysobjects where id = object_id(N'[operational].[sproc_facacq_dcn_pre_std_fix]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [operational].[sproc_facacq_dcn_pre_std_fix]
go

CREATE PROCEDURE [operational].[sproc_facacq_dcn_pre_std_fix]
@fac_ids varchar(1000)
,@case_number varchar(200)
,@log_db varchar(200) = 'pcc_temp_storage'

-- ================================================================================= 
-- Script to create [operational].[sproc_facacq_dcn_pre_std_fix] Procedure in Client Database
--						 
-- Written By:          Linlin Jing
-- Reviewed By:         
-- 
-- Script Type:         DDL 
-- Target DB Type:      Client Database
-- Target ENVIRONMENT:  Both
-- 
-- 
-- Re-Runable:          YES 
-- 
-- Description: For updating scoping before copying data to a new client database			
-- 
-- Special Instruction: 
-- 
-- Sample execution: exec [operational].[sproc_facacq_dcn_pre_std_fix] @fac_ids = '1,3', @case_number = 'EICase12345'
-- 
-- =================================================================================

AS
declare @sql nvarchar(max)
declare @message varchar(4000)
declare @rowcount int = 0
declare @first_fac varchar(500)
declare @sql_log varchar(max)

SET CONTEXT_INFO 0xDC1000000;

select top 1 @first_fac = fac_id from facility where fac_id in (select value from string_split('' + @fac_ids + '',',') )

IF OBJECT_ID(@log_db + '.dbo.dcnlog_' + @case_number, 'U') IS NOT NULL EXEC('DROP TABLE ' + @log_db + '.dbo.dcnlog_' + @case_number)

EXEC('CREATE TABLE ' + @log_db + '.dbo.dcnlog_' + @case_number + '(rNo INT IDENTITY(1, 1),step VARCHAR(200),msg VARCHAR(max),msgTime DATETIME)')


BEGIN TRY

	set @sql = '
	SELECT userid
		   ,long_username
		   ,isnull(staff_id, 1) AS staff_id
		   ,loginname
		   ,isnull(position_id, 2) AS position_id
		   ,isnull(position_description, 3) AS position_description
		   ,isnull(alternate_loginname, 4) AS alternate_loginname
		   ,isnull(initials, 5) AS initials
		   ,isnull(designation_desc, 6) AS designation_desc
	INTO #tempcp
	FROM cp_sec_user_audit
	GROUP BY userid
		   ,long_username
		   ,isnull(staff_id, 1)
		   ,loginname
		   ,isnull(position_id, 2)
		   ,isnull(position_description, 3)
		   ,isnull(alternate_loginname, 4)
		   ,isnull(initials, 5)
		   ,isnull(designation_desc, 6)
	HAVING count(*) > 1

	update cp_sec_user_audit
	set position_description = position_description + convert(varchar(500), cp_sec_user_audit_id)
	where userid in (select distinct userid from #tempcp) 
	and position_description is not null

	update cp_sec_user_audit
	set position_description = convert(varchar(500), cp_sec_user_audit_id)
	where userid in (select distinct userid from #tempcp)
	and position_description is null
	'
	exec (@sql)

	set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
	exec (@sql_log)

	set @sql = '
	update [dbo].sec_user  
	set fac_id = ' + @first_fac + '
	where userid in 
	(select userid from [dbo].cp_sec_user_audit where cp_sec_user_audit_id  in (select created_user_audit_id from [dbo].as_footnote 
	where client_id in (select client_id from [dbo].clients where fac_id in (' + @fac_ids + '))) and fac_id not in (' + @fac_ids + '))
	and fac_id not in ('  + @fac_ids  + ')
	'exec (@sql)

		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update [dbo].cp_sec_user_audit  
	set fac_id = ' + @first_fac + '
	where cp_sec_user_audit_id  in (select created_user_audit_id from [dbo].as_footnote 
	where client_id in (select client_id from [dbo].clients where fac_id in (' + @fac_ids + ')))
	and fac_id not in (' + @fac_ids + ')
	'exec (@sql)

		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update s
	set fac_id = ' + @first_fac + '
	from [dbo].pho_admin_order a
	join [dbo].pho_phys_order b on a.phys_order_id = b.phys_order_id
	join [dbo].sec_user s on a.noted_by = s.userid
	where b.fac_id in (' + @fac_ids + ') and s.fac_id not in (' + @fac_ids + ')
	'exec (@sql)

		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	UPDATE [dbo].sec_user 
	set fac_id = ' + @first_fac + ' 
	where userid in (SELECT distinct a.userid FROM [dbo].cp_sec_user_audit a 
	JOIN [dbo].pho_phys_order_useraudit b on a.cp_sec_user_audit_id = b.created_by_audit_id 
	JOIN [dbo].pho_phys_order c on b.phys_order_id = c.phys_order_id 
	WHERE c.fac_id in (' + @fac_ids + ') 
	)  
	and fac_id not in (' + @fac_ids + ') 
	'exec (@sql)

		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	UPDATE [dbo].cp_sec_user_audit 
	set fac_id = ' + @first_fac + ' ,initials = null
	where cp_sec_user_audit_id in (
	SELECT a.cp_sec_user_audit_id FROM (
	select  * from [dbo].cp_sec_user_audit 
	where  cp_sec_user_audit_id in (SELECT distinct created_by_audit_id FROM [dbo].pho_phys_order_useraudit b 
	JOIN [dbo].pho_phys_order c on b.phys_order_id = c.phys_order_id 
	WHERE c.fac_id in (' + @fac_ids + ') 
	)  
	and fac_id not in (' + @fac_ids + ')
	) a
	join [dbo].cp_sec_user_audit  b
	on a.userid=b.userid and
	a.long_username=b.long_username and
	a.loginname=b.loginname and
	a.position_id=b.position_id and
	a.position_description=b.position_description and
	a.initials= b.initials 
	where b.fac_id in (' + @fac_ids + ')
	)

	UPDATE [dbo].cp_sec_user_audit 
	set fac_id = ' + @first_fac + ' 
	where cp_sec_user_audit_id in (
	SELECT a.cp_sec_user_audit_id FROM (
	select  * from [dbo].cp_sec_user_audit 
	where  cp_sec_user_audit_id in (SELECT distinct created_by_audit_id FROM [dbo].pho_phys_order_useraudit b 
	JOIN [dbo].pho_phys_order c on b.phys_order_id = c.phys_order_id 
	WHERE c.fac_id in (' + @fac_ids + ')  
	)  
	and fac_id not in (' + @fac_ids + ')
	) a
	) 
	'exec (@sql)

		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update b
	set fac_id = ' + @first_fac + '
	from [dbo].sec_user b
	where userid in 
	(select userid from [dbo].cp_sec_user_audit where cp_sec_user_audit_id in 
	(select created_by_audit_id from [dbo].pho_std_order_set where fac_id in (-1,' + @fac_ids + ')
	union 
	select revision_by_audit_id from [dbo].pho_std_order_set where fac_id in (-1,' + @fac_ids + ')
	union 
	select published_by_audit_id from [dbo].pho_std_order_set where fac_id in (-1,' + @fac_ids + ')
	union 
	select retired_by_audit_id from [dbo].pho_std_order_set where fac_id in (-1,' + @fac_ids + ')
	union 
	select reactivated_by_audit_id from [dbo].pho_std_order_set where fac_id in (-1,' + @fac_ids + '))
	and fac_id not in (' + @fac_ids + '))
	and fac_id not in (' + @fac_ids + ')
	'exec (@sql)

		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update a
	set fac_id = ' + @first_fac + '
	from [dbo].cp_sec_user_audit a
	where cp_sec_user_audit_id in (
	select created_by_audit_id from [dbo].pho_std_order_set where fac_id in (-1,' + @fac_ids + ')
	union 
	select revision_by_audit_id from [dbo].pho_std_order_set where fac_id in (-1,' + @fac_ids + ')
	union 
	select published_by_audit_id from [dbo].pho_std_order_set where fac_id in (-1,' + @fac_ids + ')
	union 
	select retired_by_audit_id from [dbo].pho_std_order_set where fac_id in (-1,' + @fac_ids + ')
	union 
	select reactivated_by_audit_id from [dbo].pho_std_order_set where fac_id in (-1,' + @fac_ids + '))
	and fac_id not in (' + @fac_ids + ') 
	'exec (@sql)

		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update b
	set fac_id = ' + @first_fac + '
	from [dbo].sec_user b
	where userid in 
	(select userid from [dbo].cp_sec_user_audit where cp_sec_user_audit_id in 
	(select created_by_audit_id from [dbo].pho_std_order where fac_id in (-1,' + @fac_ids + ')
	union 
	select revision_by_audit_id from [dbo].pho_std_order where fac_id in (-1,' + @fac_ids + ')
	union 
	select published_by_audit_id from [dbo].pho_std_order where fac_id in (-1,' + @fac_ids + ')
	union 
	select retired_by_audit_id from [dbo].pho_std_order where fac_id in (-1,' + @fac_ids + ')
	union 
	select reactivated_by_audit_id from [dbo].pho_std_order where fac_id in (-1,' + @fac_ids + '))
	and fac_id not in (' + @fac_ids + '))
	and fac_id not in (' + @fac_ids + ')
	'exec (@sql)

		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update a
	set fac_id = ' + @first_fac + '
	from [dbo].cp_sec_user_audit a
	where cp_sec_user_audit_id in (
	select distinct created_by_audit_id from [dbo].pho_std_order where  fac_id  in (-1,' + @fac_ids + ')
	union 
	select distinct revision_by_audit_id from [dbo].pho_std_order where  fac_id  in (-1,' + @fac_ids + ')
	union 
	select distinct published_by_audit_id from [dbo].pho_std_order where  fac_id  in (-1,' + @fac_ids + ')
	union 
	select distinct retired_by_audit_id from [dbo].pho_std_order where  fac_id  in (-1,' + @fac_ids + ')
	union 
	select distinct reactivated_by_audit_id from [dbo].pho_std_order where  fac_id  in (-1,' + @fac_ids + '))
	and fac_id not in (' + @fac_ids + ') 
	'exec (@sql)

		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update [dbo].cp_sec_user_audit  
	set fac_id = ' + @first_fac + '
	where cp_sec_user_audit_id in (select created_user_audit_id from [dbo].allergy 
	where client_id in (select client_id from [dbo].clients where fac_id in (' + @fac_ids + ')))
	and fac_id not in (' + @fac_ids + ') 
	and userid not in (-10000, -998)
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	UPDATE [dbo].sec_user 
	set fac_id = ' + @first_fac + ' 
	where userid in (SELECT distinct a.userid FROM [dbo].cp_sec_user_audit a 
	JOIN [dbo].allergy b on a.cp_sec_user_audit_id = b.created_user_audit_id 
	where b.client_id in (select client_id from [dbo].clients where fac_id in (' + @fac_ids + '))
	)  
	and userid not in (-10000, -998)
	and fac_id not in (' + @fac_ids + ') 
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	UPDATE [dbo].sec_user 
	set fac_id = ' + @first_fac + ' 
	where userid in (SELECT distinct a.userid FROM [dbo].cp_sec_user_audit a 
	JOIN [dbo].allergy b on a.cp_sec_user_audit_id = b.revision_user_audit_id 
	where b.client_id in (select client_id from [dbo].clients where fac_id in (' + @fac_ids + '))
	)  
	and userid not in (-10000, -998)
	and fac_id not in (' + @fac_ids + ') 
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update [dbo].cp_sec_user_audit  
	set fac_id = ' + @first_fac + '
	where cp_sec_user_audit_id  in (select revision_user_audit_id from [dbo].allergy 
	where client_id in (select client_id from [dbo].clients where fac_id in (' + @fac_ids + ')))
	and fac_id not in (' + @fac_ids + ') 
	and userid not in (-10000, -998)
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)


	set @sql = '
	update [dbo].cp_sec_user_audit  
	set fac_id = ' + @first_fac + '
	where cp_sec_user_audit_id  in (select created_user_audit_id from [dbo].allergy_audit 
	where client_id in (select client_id from [dbo].clients where fac_id in (' + @fac_ids + ')))
	and fac_id not in (' + @fac_ids + ') 
	and userid not in (-10000, -998)
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update [dbo].cp_sec_user_audit  
	set fac_id = ' + @first_fac + '
	where cp_sec_user_audit_id  in (select revision_user_audit_id from [dbo].allergy_audit 
	where client_id in (select client_id from [dbo].clients where fac_id in (' + @fac_ids + ')))
	and fac_id not in (' + @fac_ids + ') 
	and userid not in (-10000, -998)
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	UPDATE [dbo].sec_user 
	set fac_id = ' + @first_fac + ' 
	where userid in (SELECT distinct a.userid FROM [dbo].cp_sec_user_audit a 
	JOIN [dbo].allergy_audit b on a.cp_sec_user_audit_id = b.created_user_audit_id 
	where b.client_id in (select client_id from [dbo].clients where fac_id in (' + @fac_ids + '))
	)  
	and userid not in (-10000, -998)
	and fac_id not in (' + @fac_ids + ') 
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	UPDATE [dbo].sec_user 
	set fac_id = ' + @first_fac + '  
	where userid in (SELECT distinct a.userid FROM [dbo].cp_sec_user_audit a 
	JOIN [dbo].allergy_audit b on a.cp_sec_user_audit_id = b.revision_user_audit_id 
	where b.client_id in (select client_id from [dbo].clients where fac_id in (' + @fac_ids + '))
	)  
	and userid not in (-10000, -998)
	and fac_id not in (' + @fac_ids + ') 
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update [dbo].sec_user  
	set fac_id = ' + @first_fac + '
	where userid in (select userid from [dbo].cp_sec_user_audit
	where cp_sec_user_audit_id in  (select  sec_user_audit_id from  [dbo].immunization_strikeout
	where immunization_id in (select  immunization_id  from  [dbo].cr_client_immunization
	where fac_id in (' + @fac_ids + '))) and  fac_id not in (' + @fac_ids + '))
	and fac_id not in (' + @fac_ids + ')
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update [dbo].cp_sec_user_audit  
	set fac_id = ' + @first_fac + '
	where cp_sec_user_audit_id in  (select  sec_user_audit_id from  [dbo].immunization_strikeout
	where immunization_id in (select  immunization_id  from  [dbo].cr_client_immunization
	where fac_id in (' + @fac_ids + ')))
	and fac_id not in (' + @fac_ids + ')
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update s
	set fac_id = ' + @first_fac + '
	from [dbo].mpi_history b 
	join [dbo].sec_user s on b.user_id=s.userid
	left join [dbo].sec_user_facility f on b.user_id=f.userid
	where b.fac_id in (' + @fac_ids + ') and s.fac_id not in (' + @fac_ids + ') and (facility_id in (' + @fac_ids + ') or admin_user_type = ''E'' 
	) 
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update [dbo].sec_user  
	set fac_id = ' + @first_fac + '
	where userid in (select userid from [dbo].cp_sec_user_audit
	where cp_sec_user_audit_id in (select sec_user_audit_id from [dbo].immunization_strikeout
	where immunization_id in (select  immunization_id from [dbo].cr_client_immunization
	where fac_id in (' + @fac_ids + ')))
	and fac_id not in (' + @fac_ids + '))
	and fac_id not in (' + @fac_ids + ')
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update [dbo].cp_sec_user_audit  
	set fac_id = ' + @first_fac + '
	where cp_sec_user_audit_id in (select  sec_user_audit_id from [dbo].immunization_strikeout
	where immunization_id in (select  immunization_id from [dbo].cr_client_immunization
	where fac_id in (' + @fac_ids + ')))
	and fac_id not in (' + @fac_ids + ')
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update [dbo].sec_user  
	set fac_id = ' + @first_fac + '
	where userid in  (select  administered_by_id from [dbo].cr_client_immunization
	where fac_id in (' + @fac_ids + ')) 
	and fac_id not in (' + @fac_ids + ')
	'exec (@sql)
	
		exec (@sql)
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update [dbo].sec_user  
	set fac_id = ' + @first_fac + '
	where userid in  (select  administered_by_id from [dbo].cr_client_immunization_audit
	where fac_id in (' + @fac_ids + ')) 
	and  fac_id not in (' + @fac_ids + ')
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update [dbo].sec_user  
	set fac_id = ' + @first_fac + '
	where userid in (select userid from [dbo].cp_sec_user_audit
	where cp_sec_user_audit_id  in (select strikeout_user_audit_id from [dbo].allergy_strikeout s
	JOIN [dbo].allergy b on s.allergy_id = b.allergy_id 
	where client_id in (select client_id from [dbo].clients where fac_id in (' + @fac_ids + ')))
	and fac_id not in (' + @fac_ids + '))
	and fac_id not in (' + @fac_ids + ')
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update [dbo].cp_sec_user_audit  
	set fac_id = ' + @first_fac + ' 
	where cp_sec_user_audit_id  in (select strikeout_user_audit_id from [dbo].allergy_strikeout s
	JOIN [dbo].allergy b on s.allergy_id = b.allergy_id 
	where client_id in (select client_id from [dbo].clients where fac_id in (' + @fac_ids + ')))
	and fac_id not in (' + @fac_ids + ')
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update [dbo].sec_user  
	set fac_id = ' + @first_fac + '
	where userid in (select userid from [dbo].cp_sec_user_audit  
	where cp_sec_user_audit_id  in (select strikeout_user_audit_id from [dbo].diagnosis_strikeout
	where client_diagnosis_id in (select client_diagnosis_id from [dbo].diagnosis where fac_id in (' + @fac_ids + ')))
	and fac_id not in (' + @fac_ids + '))
	and fac_id not in (' + @fac_ids + ')
	'exec (@sql)

		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update [dbo].cp_sec_user_audit  
	set fac_id = ' + @first_fac + '
	where cp_sec_user_audit_id  in (select strikeout_user_audit_id from [dbo].diagnosis_strikeout
	where client_diagnosis_id in (select client_diagnosis_id from [dbo].diagnosis where fac_id in (' + @fac_ids + ')))
	and fac_id not in (' + @fac_ids + ')
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update [dbo].sec_user
	set fac_id = ' + @first_fac + '
	from [dbo].sec_user
	where userid in (select userid from [dbo].cp_sec_user_audit
	where cp_sec_user_audit_id in (
		select created_by_audit_id from [dbo].pho_admin_order_useraudit a
		JOIN [dbo].pho_admin_order b on a.admin_order_id = b.admin_order_id 
		JOIN [dbo].pho_phys_order c on b.phys_order_id = c.phys_order_id
		WHERE c.fac_id in (' + @fac_ids + ') 
	union 
		select edited_by_audit_id from [dbo].pho_admin_order_useraudit a
		JOIN [dbo].pho_admin_order b on a.admin_order_id = b.admin_order_id 
		JOIN [dbo].pho_phys_order c on b.phys_order_id = c.phys_order_id
		WHERE c.fac_id in (' + @fac_ids + ') 
	union 
		select confirmed_by_audit_id from [dbo].pho_admin_order_useraudit a
		JOIN [dbo].pho_admin_order b on a.admin_order_id = b.admin_order_id 
		JOIN [dbo].pho_phys_order c on b.phys_order_id = c.phys_order_id
		WHERE c.fac_id in (' + @fac_ids + ') 
	) and fac_id not in (' + @fac_ids + '))
	and fac_id not in (' + @fac_ids + ')
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update au
	set fac_id = ' + @first_fac + '
	from [dbo].cp_sec_user_audit au
	where cp_sec_user_audit_id in (
		select created_by_audit_id from [dbo].pho_admin_order_useraudit a
		JOIN [dbo].pho_admin_order b on a.admin_order_id = b.admin_order_id 
		JOIN [dbo].pho_phys_order c on b.phys_order_id = c.phys_order_id
		WHERE c.fac_id in (' + @fac_ids + ') 
	union 
		select edited_by_audit_id from [dbo].pho_admin_order_useraudit a
		JOIN [dbo].pho_admin_order b on a.admin_order_id = b.admin_order_id 
		JOIN [dbo].pho_phys_order c on b.phys_order_id = c.phys_order_id
		WHERE c.fac_id in (' + @fac_ids + ') 
	union 
		select confirmed_by_audit_id from [dbo].pho_admin_order_useraudit a
		JOIN [dbo].pho_admin_order b on a.admin_order_id = b.admin_order_id 
		JOIN [dbo].pho_phys_order c on b.phys_order_id = c.phys_order_id
		WHERE c.fac_id in (' + @fac_ids + ') 
	)
	and fac_id not in (' + @fac_ids + ') 
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update [dbo].sec_user
	set fac_id = ' + @first_fac + '
	from [dbo].sec_user
	where userid in (select userid from [dbo].cp_sec_user_audit
	where cp_sec_user_audit_id in (
		select created_by_audit_id from [dbo].pho_admin_order_useraudit a
		JOIN [dbo].pho_admin_order_audit b on a.admin_order_id = b.admin_order_id 
		JOIN [dbo].pho_phys_order c on b.phys_order_id = c.phys_order_id
		WHERE c.fac_id in (' + @fac_ids + ') 
	union 
		select edited_by_audit_id from [dbo].pho_admin_order_useraudit a
		JOIN [dbo].pho_admin_order_audit b on a.admin_order_id = b.admin_order_id 
		JOIN [dbo].pho_phys_order c on b.phys_order_id = c.phys_order_id
		WHERE c.fac_id in (' + @fac_ids + ') 
	union 
		select confirmed_by_audit_id from [dbo].pho_admin_order_useraudit a
		JOIN [dbo].pho_admin_order_audit b on a.admin_order_id = b.admin_order_id 
		JOIN [dbo].pho_phys_order c on b.phys_order_id = c.phys_order_id
		WHERE c.fac_id in (' + @fac_ids + ') 
	) and fac_id not in (' + @fac_ids + '))
	and fac_id not in (' + @fac_ids + ')
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update au
	set fac_id = ' + @first_fac + '
	from [dbo].cp_sec_user_audit au
	where cp_sec_user_audit_id in (
		select created_by_audit_id from [dbo].pho_admin_order_audit_useraudit a
		JOIN [dbo].pho_admin_order_audit b on a.audit_id = b.audit_id 
		JOIN [dbo].pho_phys_order c on b.phys_order_id = c.phys_order_id
		WHERE c.fac_id in (' + @fac_ids + ') 

	union 
		select edited_by_audit_id from [dbo].pho_admin_order_audit_useraudit a
		JOIN [dbo].pho_admin_order_audit b on a.audit_id = b.audit_id 
		JOIN [dbo].pho_phys_order c on b.phys_order_id = c.phys_order_id
		WHERE c.fac_id in (' + @fac_ids + ') 
	union 
		select confirmed_by_audit_id from [dbo].pho_admin_order_audit_useraudit a
		JOIN [dbo].pho_admin_order_audit b on a.audit_id = b.audit_id 
		JOIN [dbo].pho_phys_order c on b.phys_order_id = c.phys_order_id
		WHERE c.fac_id in (' + @fac_ids + ') 
	)
	and fac_id not in (' + @fac_ids + ') 
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	UPDATE s 
	set fac_id = ' + @first_fac + ' 
	from [dbo].sec_user s
	where userid in (select userid from [dbo].cp_sec_user_audit where cp_sec_user_audit_id in 
	(SELECT distinct followupby_useraudit_id FROM [dbo].pho_schedule_details_followup_useraudit b 
	JOIN [dbo].pho_schedule_details c on b.schedule_detail_id = c.pho_schedule_detail_id
	JOIN [dbo].pho_schedule d ON d.schedule_id=c.pho_schedule_id
	WHERE d.fac_id in (' + @fac_ids + '))  
	and fac_id not in (' + @fac_ids + '))
	and fac_id not in (' + @fac_ids + ')
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	UPDATE [dbo].cp_sec_user_audit 
	set fac_id = ' + @first_fac + ' 
	where cp_sec_user_audit_id in 
	(SELECT distinct followupby_useraudit_id FROM [dbo].pho_schedule_details_followup_useraudit b 
	JOIN [dbo].pho_schedule_details c on b.schedule_detail_id = c.pho_schedule_detail_id
	JOIN [dbo].pho_schedule d ON d.schedule_id=c.pho_schedule_id
	WHERE d.fac_id in (' + @fac_ids + '))  
	and fac_id not in (' + @fac_ids + ')
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	UPDATE s
	set fac_id = ' + @first_fac + '
	from [dbo].sec_user s where userid in (select userid from [dbo].cp_sec_user_audit
	where cp_sec_user_audit_id in (select cp_sec_user_audit_id FROM [dbo].pho_phys_order_sign
	WHERE phys_order_id IN (SELECT distinct phys_order_id FROM [dbo].pho_phys_order WHERE fac_id in (' + @fac_ids + ')))
	AND fac_id not in (' + @fac_ids + '))
	and fac_id not in (' + @fac_ids + ')
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	UPDATE [dbo].cp_sec_user_audit
	set fac_id = ' + @first_fac + '
	from [dbo].cp_sec_user_audit
	where cp_sec_user_audit_id in
	(select cp_sec_user_audit_id FROM [dbo].pho_phys_order_sign
	WHERE phys_order_id IN (SELECT distinct phys_order_id FROM [dbo].pho_phys_order WHERE fac_id in (' + @fac_ids + ')))
	AND fac_id not in (' + @fac_ids + ')
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update sec_user
	set fac_id = ' + @first_fac + '
	where userid in (select userid from cp_sec_user_audit where cp_sec_user_audit_id in 
	(select created_cp_sec_user_audit_id from pho_formulary_item_custom_library
	where custom_drug_id in (select custom_drug_id from cr_cust_med where fac_id in (-1,' + @fac_ids + '))
	union
	select revision_cp_sec_user_audit_id from pho_formulary_item_custom_library
	where custom_drug_id in (select custom_drug_id from cr_cust_med where fac_id in (-1,' + @fac_ids + '))
	)
	and fac_id not in (-1,' + @fac_ids + ') 
	and cp_sec_user_audit_id not in (-998,-10000))
	and fac_id not in (' + @fac_ids + ')
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update cp_sec_user_audit
	set fac_id = ' + @first_fac + '
	from cp_sec_user_audit where cp_sec_user_audit_id in 
	(select created_cp_sec_user_audit_id from pho_formulary_item_custom_library
	where custom_drug_id in (select custom_drug_id from cr_cust_med where fac_id in (-1,' + @fac_ids + '))) 
	and fac_id not in (-1,' + @fac_ids + ') 
	and cp_sec_user_audit_id not in (-998,-10000)
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update cp_sec_user_audit
	set fac_id = ' + @first_fac + '
	from cp_sec_user_audit where cp_sec_user_audit_id in 
	(select revision_cp_sec_user_audit_id from pho_formulary_item_custom_library
	where custom_drug_id in (select custom_drug_id from cr_cust_med where fac_id in (-1,' + @fac_ids + ')))
	and fac_id not in (-1,' + @fac_ids + ') 
	and cp_sec_user_audit_id not in (-998,-10000)
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update [dbo].sec_user
	set fac_id = ' + @first_fac + '
	where userid in (
	select userid from [dbo].cp_sec_user_audit 
	where cp_sec_user_audit_id in (
	SELECT DISTINCT b.created_by_audit_id
	FROM [dbo].pho_phys_order_audit_useraudit b
	JOIN [dbo].cp_sec_user_audit ba ON b.created_by_audit_id = ba.cp_sec_user_audit_id
	join  pho_phys_order_useraudit pa on pa.created_by_audit_id=ba.cp_sec_user_audit_id
	JOIN [dbo].pho_phys_order c ON pa.phys_order_id = c.phys_order_id
	WHERE c.fac_id in (' + @fac_ids + ')
	)
	and fac_id not in (' + @fac_ids + ')
	and userid not in (-998,-10000))
	'exec (@sql)
		
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update [dbo].sec_user
	set fac_id = ' + @first_fac + '
	where userid in (
	select userid from [dbo].cp_sec_user_audit 
	where cp_sec_user_audit_id in (
	SELECT DISTINCT b.edited_by_audit_id
	FROM [dbo].pho_phys_order_audit_useraudit b
	JOIN [dbo].cp_sec_user_audit ba ON b.edited_by_audit_id = ba.cp_sec_user_audit_id
	join  pho_phys_order_useraudit pa on pa.edited_by_audit_id=ba.cp_sec_user_audit_id
	JOIN [dbo].pho_phys_order c ON pa.phys_order_id = c.phys_order_id
	WHERE c.fac_id in (' + @fac_ids + ')
	)
	and fac_id not in (' + @fac_ids + ')
	and userid not in (-998,-10000))
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update [dbo].sec_user
	set fac_id = ' + @first_fac + '
	where userid in (
	select userid from [dbo].cp_sec_user_audit 
	where cp_sec_user_audit_id in (
	SELECT DISTINCT b.confirmed_by_audit_id
	FROM [dbo].pho_phys_order_audit_useraudit b
	JOIN [dbo].cp_sec_user_audit ba ON b.confirmed_by_audit_id = ba.cp_sec_user_audit_id
	join  pho_phys_order_useraudit pa on pa.confirmed_by_audit_id = ba.cp_sec_user_audit_id
	JOIN [dbo].pho_phys_order c ON pa.phys_order_id = c.phys_order_id
	WHERE c.fac_id in (' + @fac_ids + ')
	)
	and fac_id not in (' + @fac_ids + ')
	and userid not in (-998,-10000))
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update [dbo].cp_sec_user_audit 
	set fac_id = ' + @first_fac + ' 
	where cp_sec_user_audit_id in (
	SELECT DISTINCT b.created_by_audit_id
	FROM [dbo].pho_phys_order_audit_useraudit b
	JOIN [dbo].cp_sec_user_audit ba ON b.created_by_audit_id = ba.cp_sec_user_audit_id
	join  pho_phys_order_useraudit pa on pa.created_by_audit_id = ba.cp_sec_user_audit_id
	JOIN [dbo].pho_phys_order c ON pa.phys_order_id = c.phys_order_id
	WHERE c.fac_id in (' + @fac_ids + ')
	)
	and fac_id not in (' + @fac_ids + ')
	and userid not in (-998,-10000)
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update [dbo].cp_sec_user_audit 
	set fac_id = ' + @first_fac + ' 
	where cp_sec_user_audit_id in (
	SELECT DISTINCT b.edited_by_audit_id
	FROM [dbo].pho_phys_order_audit_useraudit b
	JOIN [dbo].cp_sec_user_audit ba ON b.edited_by_audit_id = ba.cp_sec_user_audit_id
	join  pho_phys_order_useraudit pa on pa.edited_by_audit_id = ba.cp_sec_user_audit_id
	JOIN [dbo].pho_phys_order c ON pa.phys_order_id = c.phys_order_id
	WHERE c.fac_id in (' + @fac_ids + ')
	)
	and fac_id not in (' + @fac_ids + ')
	and userid not in (-998,-10000) 
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update [dbo].cp_sec_user_audit 
	set fac_id = ' + @first_fac + ' 
	where cp_sec_user_audit_id in (
	SELECT DISTINCT b.confirmed_by_audit_id
	FROM [dbo].pho_phys_order_audit_useraudit b
	JOIN [dbo].cp_sec_user_audit ba ON b.confirmed_by_audit_id = ba.cp_sec_user_audit_id
	join  pho_phys_order_useraudit pa on pa.confirmed_by_audit_id = ba.cp_sec_user_audit_id
	JOIN [dbo].pho_phys_order c ON pa.phys_order_id = c.phys_order_id
	WHERE c.fac_id in (' + @fac_ids + ')
	)
	and fac_id not in (' + @fac_ids + ')
	and userid not in (-998,-10000) 
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	UPDATE [dbo].cp_sec_user_audit 
	set fac_id = ' + @first_fac + ' 
	where cp_sec_user_audit_id in (
	SELECT a.cp_sec_user_audit_id FROM (
	select * from [dbo].cp_sec_user_audit 
	where  cp_sec_user_audit_id in (SELECT distinct edited_by_audit_id FROM [dbo].pho_phys_order_useraudit b 
	JOIN [dbo].pho_phys_order c on b.phys_order_id = c.phys_order_id 
	WHERE c.fac_id in (' + @fac_ids + ')  
	)  
	and fac_id not in (' + @fac_ids + ')
	) a
	) and userid not in (-10000, -998)
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update s
	set fac_id = ' + @first_fac + '
	from [dbo].inc_incident a
	join [dbo].sec_user s on a.strikeout_by_id = s.userid
	where a.fac_id in (' + @fac_ids + ') and s.fac_id not in (' + @fac_ids + ')
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update c
	set c.fac_id = ' + @first_fac + '
	from [dbo].pho_phys_order_blackbox_acknowledgement a
	join [dbo].pho_phys_order b on a.phys_order_id = b.phys_order_id
	join [dbo].cp_sec_user_audit c on a.cp_sec_user_audit_id = c.cp_sec_user_audit_id
	where b.fac_id in (' + @fac_ids + ') and c.fac_id not in (' + @fac_ids + ')
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

END TRY
BEGIN CATCH
	set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
	set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
	exec (@sql_log)
	raiserror(@message, 16, 1)
END CATCH
	

BEGIN TRY

	set @sql = '
	update cp_std_frequency	set fac_id = -1
	from cp_std_frequency where 
	(std_freq_id in (select std_freq_id from cp_std_intervention where std_freq_id is not null and (fac_id in (' + @fac_ids + ')
								or fac_id < 0  or state_code in (select prov from facility where fac_id in (' + @fac_ids + ')) 
								or reg_id in (select regional_id from facility where fac_id in (' + @fac_ids + ')))) 
	or std_freq_id in (select poc_std_freq_id from cp_std_intervention where poc_std_freq_id is not null and (fac_id in (' + @fac_ids + ') 
								or fac_id < 0  or state_code in (select prov from facility where fac_id in (' + @fac_ids + ')) 
								or reg_id in (select regional_id from facility where fac_id in (' + @fac_ids + '))))) 
	and fac_id > 0 and fac_id not in (' + @fac_ids + ')  
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update a
	set a.fac_id = f.fac_id
	FROM as_std_assessment a
	JOIN as_std_assessment_facility f ON a.std_assess_id = f.std_assess_id
	WHERE a.fac_id NOT IN (-1,' + @fac_ids + ')
	AND f.fac_id in (' + @fac_ids + ')
	AND a.system_flag <> ''Y''
	AND a.std_assess_id in (select distinct std_assess_id from dbo.as_assessment where fac_id in (' + @fac_ids + '))
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update s
	set s.fac_id = a.fac_id
	from as_std_assess_schedule s
	join as_std_assessment a on s.std_assess_id = a.std_assess_id
	where a.fac_id in (-1,' + @fac_ids + ')
	AND s.fac_id not in (-1,' + @fac_ids + ')
	AND a.system_flag <> ''Y''
	AND a.std_assess_id in (select distinct std_assess_id from dbo.as_assessment where fac_id in (' + @fac_ids + ')) 
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update t
	set t.fac_id = a.fac_id
	from as_std_trigger t
	join as_std_assessment a on t.std_assess_id = a.std_assess_id
	where a.fac_id in (-1,' + @fac_ids + ')
	AND t.fac_id not in (-1,' + @fac_ids + ')
	AND a.system_flag <> ''Y''
	AND a.std_assess_id in (select distinct std_assess_id from dbo.as_assessment where fac_id in (' + @fac_ids + '))
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update r
	set r.fac_id = a.fac_id
	from as_consistency_rule r
	join as_std_assessment a on r.std_assess_id = a.std_assess_id
	where a.fac_id in (-1,' + @fac_ids + ')
	AND r.fac_id not in (-1,' + @fac_ids + ')
	AND a.system_flag <> ''Y''
	AND a.std_assess_id in (select distinct std_assess_id from dbo.as_assessment where fac_id in (' + @fac_ids + '))
	AND r.deleted <> ''Y''
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	select row_number() over (partition by std_assess_id order by src.fac_id) as rno, src.assess_id, src.std_assess_id 
	into #tempdummyuda
	from as_assessment src
	where src.std_assess_id in 
		(
		select std_assess_id from as_std_assessment stda
			where stda.std_assess_id <> - 1 AND (stda.fac_id in (' + @fac_ids + ')
					OR stda.fac_id = - 1
					OR stda.reg_id in (select regional_id from facility where fac_id in (' + @fac_ids + ')))
				AND stda.std_assess_id NOT IN (7,8,12)
				AND stda.std_assess_id NOT IN ((SELECT std_assess_id FROM [dbo].as_std_assessment_system_assessment_mapping))
				AND stda.system_flag <> ''Y''
				AND stda.deleted <> ''Y''
				AND not exists (select 1 from as_assessment with (nolock) where std_assess_id = stda.std_assess_id and client_id = -9999
										and (fac_id in (' + @fac_ids + ') OR fac_id = -1 OR reg_id in (select regional_id from facility where fac_id in (' + @fac_ids + ')))
								)
		)
	and client_id = -9999

	update a
	set fac_id = -1
	from as_assessment a
	where a.client_id = -9999
	and a.assess_id in (select assess_id from #tempdummyuda where rno = 1)
	and not exists (select 1 from as_assessment where a.std_assess_id = std_assess_id and client_id = -9999 and fac_id in (' + @fac_ids + ',-1))  

	update a
	set fac_id = -1
	from as_assessment_section a
	where a.assess_id in (select assess_id from #tempdummyuda where rno = 1)
	and a.fac_id not in (' + @fac_ids + ', -1)
	'exec (@sql)
	
	set @sql = replace(@sql,'''','''''')
	set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
	exec (@sql_log)

	set @sql = '
	update src set administered_by_id = -1
	FROM dbo.cr_client_immunization src
	WHERE administered_by_id NOT IN (SELECT userid FROM dbo.sec_user)
		AND administered_by_id <> - 1
		AND client_id IN (SELECT client_id FROM dbo.clients WHERE fac_id in (' + @fac_ids + '))
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update pn_template
	set fac_id = ' + @first_fac + '
	where template_id  in (select template_id from pn_progress_note where fac_id in (' + @fac_ids + '))
	and fac_id not in (-1,' + @fac_ids + ')
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update pn_type
	set fac_id = ' + @first_fac + '
	where pn_type_id  in (select pn_type_id from pn_progress_note where fac_id in (' + @fac_ids + '))
	and fac_id not in (-1,' + @fac_ids + ')
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update emc_ext_facilities
	SET fac_id = ' + @first_fac + '
	where state_code in (select prov from facility where fac_id in (' + @fac_ids + '))
	and fac_id not in (-1,' + @fac_ids + ')
	and deleted = ''N''
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update emc_ext_facilities
	set fac_id = ' + @first_fac + '
	where ext_fac_id in (select ext_fac_id from dbo.client_ext_facilities where fac_id in (' + @fac_ids + '))
	and fac_id not in (-1,' + @fac_ids + ')
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update cp_std_shift
	set fac_id = ' + @first_fac + '
	from dbo.cp_std_shift
	where std_shift_id in 
	(select s.std_shift_id
	from dbo.pho_schedule o
	left join dbo.[cp_std_shift] s
	on o.std_shift_id = s.std_shift_id and s.fac_id in (-1,' + @fac_ids + ')
	where o.fac_id in (' + @fac_ids + ')
	and o.std_shift_id is not null and s.std_shift_id is null
	and o.std_shift_id <> -1)
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update t
	set t.fac_id = ' + @first_fac + '
	from pho_order_type t
	where t.order_type_id in (select distinct o.order_type_id from pho_phys_order o
		where o.fac_id in (' + @fac_ids + ')) and t.fac_id not in (-1,' + @fac_ids + ')
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

	set @sql = '
	update a
	set fac_id = ' + @first_fac + '
	from user_field_types a 
	join USER_DEFINED_DATA b on a.field_type_id = b.field_type_id
	join clients c on c.client_id = b.client_id
	where c.fac_id in (' + @fac_ids + ') 
	and a.fac_id not in (-1,' + @fac_ids + ')
	'exec (@sql)
	
		set @rowcount = @@ROWCOUNT
		set @sql = replace(@sql,'''','''''')
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + @sql + ''',getdate()'
		exec (@sql_log)
		set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) select ''' + OBJECT_NAME(@@PROCID) + ''',''' + '--(' + convert(varchar,@rowcount) + ' rows affected)' + ''',getdate()'
		exec (@sql_log)

END TRY
BEGIN CATCH

	set @message = replace(concat( OBJECT_NAME(@@PROCID), ' CopyError - ', ERROR_MESSAGE()),'''','''''')
	set @sql_log = 'insert into ' + @log_db + '.dbo.dcnlog_' + @case_number + '(step,msg,msgTime) SELECT ''' + OBJECT_NAME(@@PROCID) + ''',''' + @message + ''',getdate()'
	exec (@sql_log)
	raiserror(@message, 16, 1)

END CATCH







GO

print 'K_Operational_Branch/5_StoredProcedures/sproc_facacq_dcn_pre_std_fix.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_facacq_dcn_pre_std_fix.sql',getdate(),'4.4.10_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_Facility_Extract.sql',getdate(),'4.4.10_06_CLIENT_K_Operational_Branch_US.sql')

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




if exists(select 1 from sys.procedures where name = 'sproc_facility_extract')
begin
	drop procedure operational.sproc_facility_extract
end
GO

/****** Object:  StoredProcedure [operational].[sproc_facility_extract]    Script Date: 2/14/2022 9:49:33 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- author:    lily yin
-- create date: 20220210
-- description:      this sproc will return facility extract
-- env:  CDN and US
-- Ticket #: Core-100526
-- =============================================
Create PROC [operational].[sproc_facility_extract] (
	@orgcode varchar(50),
	@orgname varchar(500),
	@facid varchar(1000),
	@debugMe CHAR(1) = 'N'
	)
AS

BEGIN

	set nocount on; 




	IF @DebugMe = 'Y'
			print 'facility extract'

	drop table if exists #facId

	if @facid<>'ALL'
		begin

			select value into #facId from string_split(@facId, ',')
		
			select distinct @orgname as Customer
			,@orgcode as [Org Code],
			f.fac_id as [FAC ID],
			case when f.facility_code is null then '' else f.facility_code end as [Facility Code],
			f.name as [Facility Name],
			f.health_type as [Line Of Business],
			f.address1 + ' ' +f.address2 as Address,
			f.city as City,
			f.prov as State,
			f.pc as Zip,
			upper(@orgCode+(SELECT RIGHT('0000'+CAST(f.fac_id AS VARCHAR(4)),4))) as [Sending Facility ID External],
			case when ac.identifier_npi is null then '' else ac.identifier_npi end as NPI,
			case when ar.provider_taxonomy_code is null then '' else ar.provider_taxonomy_code end as [Provider Taxonomy Code]
			from facility f with(nolock)
			left join ar_configuration ac with(nolock) on f.fac_id=ac.fac_id and f.deleted='N' and f.inactive is null and f.inactive_date is null and ac.deleted='N'
			left join ar_submitter  ar with(nolock) on ar.fac_id=f.fac_id 
			where f.fac_id in (select value from #facId) 
			and f.fac_id<9000
			

		END
		
	else
		begin
			select distinct @orgname as Customer
			,@orgcode as [Org Code],
			f.fac_id as [FAC ID],
			case when f.facility_code is null then '' else f.facility_code end as [Facility Code],
			f.name as [Facility Name],
			f.health_type as [Line Of Business],
			f.address1 + ' ' +f.address2 as Address,
			f.city as City,
			f.prov as State,
			f.pc as Zip,
			upper(@orgCode+(SELECT RIGHT('0000'+CAST(f.fac_id AS VARCHAR(4)),4))) as [Sending Facility ID External],
			case when ac.identifier_npi is null then '' else ac.identifier_npi end as NPI,
			case when ar.provider_taxonomy_code is null then '' else ar.provider_taxonomy_code end as [Provider Taxonomy Code]
			from facility f with(nolock)
			left join ar_configuration ac with(nolock) on f.fac_id=ac.fac_id and f.deleted='N' and f.inactive is null and f.inactive_date is null and ac.deleted='N'
			left join ar_submitter  ar with(nolock) on ar.fac_id=f.fac_id 
			where f.fac_id in (select fac_id from facility where deleted='N' and inactive is null and inactive_date is null) 
			and f.fac_id <9000
			
		end

end
GO




GO

print 'K_Operational_Branch/5_StoredProcedures/sproc_Facility_Extract.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_Facility_Extract.sql',getdate(),'4.4.10_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/US_Only/sproc_CreateFacility.sql',getdate(),'4.4.10_06_CLIENT_K_Operational_Branch_US.sql')

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


/*
--	Jira #:									CORE-92956
--	
--
--	Written By:							Jaspreet Singh Bhogal
--
--	Script Type:							DML
--	Target DB Type:					CLIENT
--	Target ENVIRONMENT:		BOTH
--	Re-Runable:						YES
-- OA Jira #:								OA-54
--	Purpose:								This stored procedure is used to create new facility in destination database.

e.g.

DECLARE	@return_value int

EXEC	@return_value = [operational].[sproc_CreateFacility]
		@orgid = 1504965856,
		@healthtype = N'SNF',
		@name = N'Test Facility22',
		@facilitycode = N'0120',
		@state = N'OH',
		@ARMonth = 6,
		@ARYear = 2021,
		@FiscalYearEND = 3,
		@Use1099 = NULL,
		@Creator = N'PS1001',
		@add1 = N'5570 Explorer',
		@add2 = N'Drive',
		@city = N'Mississauga',
		@pc = N'T1P K0L',
		@tel = N'111-111-1111',
		@netsuiteID = 123456789,
		@EmailRecipients = N'jaspreet.s@pointclickcare.com',
		@FacilityCreator = N'Jaspreet Singh Bhogal',
		@first_run = 'N',
		@TSServerName = N'[vmuspassvtsjob1.pccprod.local].[ds_tasks].[dbo].[TS_global_organization_master]',
		@SessionInstanceServerName = N'[pccsql-use2-prod-ssv-clg0001.b4ea653240a9.database.windows.net].[pcc_org_master].[dbo].[pcc_session_instances]',
		@FacUUID = '0C0A5733-D1FF-4795-86EA-357B9F12CEE4',
		@DebugMe = N'Y'

SELECT	'Return Value' = @return_value

*/
IF EXISTS (
		SELECT 1
		FROM dbo.sysobjects
		WHERE id = object_id(N'[operational].[sproc_CreateFacility]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
BEGIN
	DROP PROCEDURE [operational].[sproc_CreateFacility]
END
GO

CREATE PROCEDURE [operational].[sproc_CreateFacility] @orgid INTEGER
	,@healthtype VARCHAR(15)
	,@name VARCHAR(100)
	,@facilitycode VARCHAR(30)
	,@state VARCHAR(2)
	,@ARMonth INTEGER
	,@ARYear INTEGER
	,@FiscalYearEND INTEGER
	,@Use1099 CHAR(1)
	,@Creator VARCHAR(15)
	,@add1 VARCHAR(35)
	,@add2 VARCHAR(35)
	,@city VARCHAR(15)
	,@pc VARCHAR(15)
	,@tel VARCHAR(35)
	,@netsuiteID INT -- added by RYAN - Case 694329 -- 11/24/2015
	,@EmailRecipients VARCHAR(MAX)
	,@FacilityCreator VARCHAR(50)
	,@first_run CHAR(1) = 'N'
	,@TSServerName VARCHAR(350)
	,@SessionInstanceServerName VARCHAR(350)
	,@FacUUID UNIQUEIDENTIFIER ---- Added By Jaspreet Singh, Date: 2022-01-20, Reason: OA-158
	,@DebugMe CHAR(1) = 'N'
AS
/*
DECLARE @orgid INTEGER
	,@healthtype VARCHAR(15)
	,@name VARCHAR(100)
	,@facilitycode VARCHAR(30)
	,@state VARCHAR(2)
	,@ARMonth INTEGER
	,@ARYear INTEGER
	,@FiscalYearEND INTEGER
	,@Use1099 CHAR(1)
	,@Creator VARCHAR(15)
	,@add1 VARCHAR(35)
	,@add2 VARCHAR(35)
	,@city VARCHAR(15)
	,@pc VARCHAR(15)
	,@tel VARCHAR(35)
	,@netsuiteID INT -- added by RYAN - Case 694329 -- 11/24/2015
	,@EmailRecipients VARCHAR(MAX)
	,@FacilityCreator VARCHAR(50)
	,@first_run CHAR(1) = 'N'
	,@TSServerName VARCHAR(350)
	,@SessionInstanceServerName VARCHAR(350)
	,@DebugMe CHAR(1) = 'N'

SELECT @orgid = 1504967964
	,@healthtype = N'SNF'
	,@name = N'Test Facility1'
	,@facilitycode = N'0120'
	,@state = N'OH'
	,@ARMonth = 6
	,@ARYear = 2021
	,@FiscalYearEND = 3
	,@Use1099 = NULL
	,@Creator = N'PS1001'
	,@add1 = N'5570 Explorer'
	,@add2 = N'Drive'
	,@city = N'Mississauga'
	,@pc = N'T1P K0L'
	,@tel = N'111-111-1111'
	,@netsuiteID = 123456789
	,@EmailRecipients = N'jaspreet.s@pointclickcare.com'
	,@FacilityCreator = N'Jaspreet Singh Bhogal'
	,@first_run = 'N'
	,@TSServerName = N'[vmuspassvtsjob1.pccprod.local].[ds_tasks].[dbo].[TS_global_organization_master]'
	,@SessionInstanceServerName = N'[pccsql-use2-prod-ssv-clg0001.b4ea653240a9.database.windows.net].[pcc_org_master].[dbo].[pcc_session_instances]'
	,@DebugMe = N'N'
	*/
BEGIN
	SET XACT_ABORT
		,NOCOUNT ON;

	DECLARE @NewDB CHAR(1)
		,@FacIdDest INTEGER
		,@regid INTEGER
		,@FacExist INT
		,@factype VARCHAR(4)
		,@MaxID INT
		,@country INT
		,@SourceFac INT
		,@GLAPYear INT
		,@GLAPYear1 INT
		,@GLAPYear2 INT
		,@GLAPYear3 INT
		,@GLAPYear4 INT
		,@rowcount INT
		,@MaxSetupID INT
		,@MaxSetupParamID INT
		--added for v2.6.0
		,@MaxcalendarID INT
		,@template_server VARCHAR(128)
		,@template_db VARCHAR(128)
		,@ARStartDate DATETIME
		,@timezone INTEGER
		,@orgcode VARCHAR(20)
		,@status_code INT
		,@status_text VARCHAR(3000) = 'Success'
		,@Environment VARCHAR(50)
		,@sqlstring NVARCHAR(max)
	----Dorado and Ability variables
	DECLARE --@OrgId INT
		@WesMessageDatabase VARCHAR(50)
		,@endpoint_url VARCHAR(128)
		,@importFTPLocation VARCHAR(255)
		,@email VARCHAR(400)
		,@ErrorNumber INT
		,@multiFacility BIT = 1 -- 0 Single Facility, 1 Multi Facility
		--,@facId INT
		,@sessionServerName VARCHAR(100)
		,@sessionDatabaseName VARCHAR(100)
		,@created_by VARCHAR(60)
		-- ,@created_date DATETIME
		,@parameter_value VARCHAR(256)
		,@message_profile_id INT
		,@step INT

	SET @NewDB = 'N'
	SET @FacIdDest = NULL

	IF (
			(@state IS NOT NULL)
			AND (@state <> '')
			)
	BEGIN
		IF NOT EXISTS (
				SELECT 1
				FROM [prov_state]
				WHERE prov_code = @state
				)
		BEGIN
			SELECT 'State code is not valid' AS sp_error_msg

			RETURN - 100;
		END
	END
	ELSE
	BEGIN
		SELECT 'State code should not be empty' AS sp_error_msg

		RETURN - 100;
	END

	IF (
			@state IS NOT NULL
			OR @state <> ''
			)
	BEGIN
		SET @sqlstring = 'SELECT @template_server = ServerName
			,@template_db = DatabaseName
		FROM ' + @TSServerName + '
		WHERE OrgCode = ''tmplt' + @state + ''''

		EXEC Sp_executesql @sqlstring
			,N'@template_server VARCHAR(128) OUTPUT, @template_db VARCHAR(128) OUTPUT'
			,@template_server = @template_server OUTPUT
			,@template_db = @template_db OUTPUT
			----SELECT @template_server
			----	,@template_db
	END

	IF ISNULL(@ARMonth, 0) = 0
	BEGIN
		SET @ARMonth = MONTH(GETDATE())
	END

	IF NOT (
			(
				@ARMonth >= 1
				AND @ARMonth <= 12
				)
			)
	BEGIN
		SELECT 'AR month should be between 1 - 12' AS sp_error_msg

		RETURN - 100;
	END

	IF IsNumeric(@ARYear) = 0
	BEGIN
		SET @ARYear = YEAR(GETDATE())
	END
	ELSE
	BEGIN
		IF @ARYear < 1900
		BEGIN
			SELECT 'ARYear Should be greater than 1900' AS sp_error_msg

			RETURN - 100;
		END
	END

	SET @ARStartDate = CONVERT(VARCHAR, @ARYear) + REPLICATE('0', 2 - LEN(CONVERT(VARCHAR, @ARMonth))) + CONVERT(VARCHAR, @ARMonth) + '01'

	IF ISNULL(@GLAPYear, 0) = 0
	BEGIN
		SET @GLAPYear = @ARYear - 1
		SET @GLAPYear1 = @GLAPYear
		SET @GLAPYear2 = @GLAPYear + 1
		SET @GLAPYear3 = @GLAPYear + 2
		SET @GLAPYear4 = @GLAPYear + 3
	END

	IF (
			(@FiscalYearEND = '')
			OR (isnumeric(@FiscalYearEND) = 0)
			)
	BEGIN
		SET @FiscalYearEND = 12
	END

	IF NOT (
			(
				@FiscalYearEND >= 1
				AND @FiscalYearEND <= 12
				)
			)
	BEGIN
		SELECT 'Fiscal year should be between 1 - 12' AS sp_error_msg

		RETURN - 100;
	END

	IF (@Use1099 IS NULL)
	BEGIN
		SET @Use1099 = 'Y'
	END

	IF (
			@Creator IS NULL
			OR @Creator = ''
			)
	BEGIN
		SELECT 'Please provide value of facility creator.' AS sp_error_msg

		RETURN - 100;
	END

	IF @facilitycode IS NULL
		SET @facilitycode = ''
	SET @factype = 'USAR'
	SET @SourceFac = (
			SELECT min(fac_id)
			FROM dbo.facility WITH (NOLOCK)
			WHERE deleted = 'N'
				AND fac_id <> 9001
			)

	IF (
			(@netsuiteID IS NULL)
			AND (@netsuiteID = '')
			)
	BEGIN
		SELECT 'NetSuite Id should have value.' AS sp_error_msg

		RETURN - 100;
	END

	IF @add1 IS NULL
		SET @add1 = ''

	IF @add2 IS NULL
		SET @add2 = ''

	IF @city IS NULL
		SET @city = ''

	IF @pc IS NULL
		SET @pc = ''

	IF (
			@add1 IS NOT NULL
			OR @add1 <> ''
			)
	BEGIN
		IF (len(@add1) > 35)
			-- facility
		BEGIN
			SELECT 'Address1 length should be upto 35 characters only.' AS sp_error_msg

			RETURN - 100;
		END
	END

	IF (
			@add2 IS NOT NULL
			OR @add2 <> ''
			)
	BEGIN
		IF (len(@add2) > 35)
		BEGIN
			SELECT 'Address2 length should be upto 35 characters only.' AS sp_error_msg

			RETURN - 100;
		END
	END

	IF (
			@city IS NOT NULL
			OR @city <> ''
			)
	BEGIN
		IF (len(@city) > 35)
		BEGIN
			SELECT 'City length should be upto 50 characters only.' AS sp_error_msg

			RETURN - 100;
		END
	END

	IF (
			@pc IS NOT NULL
			OR @pc <> ''
			)
	BEGIN
		IF (len(@pc) > 15)
		BEGIN
			SELECT 'Postal code length should be upto 15 characters only.' AS sp_error_msg

			RETURN - 100;
		END
	END

	IF (
			@tel IS NOT NULL
			OR @tel <> ''
			)
	BEGIN
		IF (len(@tel) > 12)
		BEGIN
			SELECT 'Telephone should be in correct format.' AS sp_error_msg

			RETURN - 100;
		END
	END

	-- Script to get timezone base on state code
	IF (
			@state IS NOT NULL
			OR @state <> ''
			)
	BEGIN
		SET @timezone = CASE 
				WHEN @state = 'HI'
					THEN - 6
				WHEN @state = 'WA'
					OR @state = 'OR'
					OR @state = 'NV'
					OR @state = 'CA'
					OR @state = 'AK'
					THEN - 3
				WHEN @state = 'MT'
					OR @state = 'ID'
					OR @state = 'WY'
					OR @state = 'UT'
					OR @state = 'CO'
					OR @state = 'NM'
					OR @state = 'AZ'
					THEN '-2'
				WHEN @state = 'ND'
					OR @state = 'SD'
					OR @state = 'NE'
					OR @state = 'KS'
					OR @state = 'OK'
					OR @state = 'TX'
					OR @state = 'MN'
					OR @state = 'IA'
					OR @state = 'MO'
					OR @state = 'AR'
					OR @state = 'LA'
					OR @state = 'WI'
					OR @state = 'IL'
					OR @state = 'TN'
					OR @state = 'MS'
					OR @state = 'AL'
					THEN '-1'
				WHEN @state = 'MI'
					OR @state = 'IN'
					OR @state = 'OH'
					OR @state = 'KY'
					OR @state = 'WV'
					OR @state = 'GA'
					OR @state = 'FL'
					OR @state = 'SC'
					OR @state = 'NC'
					OR @state = 'VA'
					OR @state = 'PA'
					OR @state = 'NY'
					OR @state = 'VT'
					OR @state = 'NH'
					OR @state = 'ME'
					OR @state = 'MA'
					OR @state = 'RI'
					OR @state = 'CT'
					OR @state = 'NJ'
					OR @state = 'DE'
					OR @state = 'MD'
					OR @state = 'DC'
					THEN '0'
				ELSE ''
				END
	END

	SET @Country = 100
	SET @FacExist = 0

	IF RTRIM(@healthtype) = 'GLHO'
		SET @FacIdDest = 9999
	ELSE
	BEGIN
		IF (
				SELECT COUNT(1)
				FROM [dbo].facility
				WHERE fac_id != 9001
					AND deleted = 'N'
				) = 1 -- modified by Ryan due to Case 1617989 - 02/14/2020
			--IF (SELECT COUNT(1) FROM [dbo].facility where fac_id != 9001) = 1  -- old line
		BEGIN
			IF EXISTS (
					SELECT 1
					FROM [dbo].facility
					WHERE (created_by LIKE '%wescom%')
						AND fac_id != 9001
						AND deleted = 'N'
					) -- modified by Ryan due to Case 1617989 - 02/14/2020
				AND (
					-- Added by Jaspreet due to removal of disable login
					(
						SELECT DISTINCT fac.location_status_id
						FROM dbo.facility fac WITH (NOLOCK)
						WHERE fac_id != 9001
							AND deleted = 'N'
						) = (
						SELECT location_status_id
						FROM dbo.location_status WITH (NOLOCK)
						WHERE code = 'TEMPLATE'
						)
					)
			BEGIN
				SET @newDb = 'Y'
			END
		END

		IF (
				@newDb = 'Y'
				AND @healthtype <> 'SNF'
				AND @first_run = 'Y'
				)
		BEGIN
			SELECT 'Please update input file to have SNF as the first record.' AS sp_error_msg

			RETURN - 100;
		END

		IF @newDb = 'Y'
			SELECT @FacIdDest = MIN(fac_id)
			FROM [dbo].facility
	END

	/*V1.2*/
	--PRINT 'STEP #2'
	IF @FacIdDest IS NULL
	BEGIN
		PRINT ' **** New Facility '

		SELECT @FacIdDest = max(fac_id)
		FROM [dbo].facility
		WHERE fac_id < 9000

		SET @FacIdDest = ISNULL(@FacIdDest, 0) + 1
	END

	SELECT @regid = MIN(regional_id)
	FROM [dbo].regions
	WHERE short_desc = @healthtype

	SET @sqlstring = ''
	SET @sqlstring = 'SELECT @OrgCode = OrgCode
		,@Environment = Environment
		FROM ' + @TSServerName + '
		WHERE OrgId = ''' + CAST(@OrgId AS VARCHAR) + ''''

	EXEC Sp_executesql @sqlstring
		,N'@OrgCode varchar(20) OUTPUT, @Environment varchar(50) OUTPUT'
		,@OrgCode = @OrgCode OUTPUT
		,@Environment = @Environment OUTPUT

	----SELECT Environment = @Environment
	----	,OrgCode = @OrgCode
	/*Validations*/
	IF EXISTS (
			SELECT 1
			FROM [dbo].facility
			WHERE RTRIM(name) = RTRIM(@name)
				AND RTRIM(address1) = RTRIM(@add1)
				AND RTRIM(health_type) = RTRIM(@healthtype)
				AND RTRIM(created_by) = RTRIM(@Creator)
				AND deleted = 'N'
			)
		OR EXISTS (
			SELECT 1
			FROM facility
			WHERE fac_id <> 1
				AND fac_id = @FacIdDest
			)
	BEGIN
		SELECT '** ERROR: Facility "' + @name + '" already exists (orgid:' + CONVERT(VARCHAR, @orgid) + ')' AS sp_error_msg

		RETURN - 100;---- Last -100
	END

	------ELSE
	BEGIN TRY
		BEGIN TRANSACTION

		BEGIN
			IF (
					(@FacIdDest = 2)
					OR (
						(
							SELECT count(1)
							FROM [dbo].facility
							WHERE fac_id != @FacIdDest
								AND deleted = 'N'
								AND fac_id < 9000
							) = 1
						)
					)
			BEGIN
				--only for 2nd facility-do not want to change existing scoping in an existing multi DB
				UPDATE module
				SET deleted = 'N'
				WHERE module_id = 5
					AND deleted = 'Y'

				UPDATE ar_common_code
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE ar_insurance_addresses
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE ar_item_category
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1 --corporate scoping does not work unless regid is null

				UPDATE ar_lib_accounts
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE ar_lib_care_level_template
				SET fac_id = - 1
					,reg_id = NULL
				WHERE reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE ar_lib_charge_codes
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE ar_lib_fee_schedule
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE ar_lib_insurance_companies
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE ar_lib_payers
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE ar_lib_rate_schedule
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE ar_lib_rate_type
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE ar_lib_schedule_template
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE ar_lib_submitter
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE as_assessment
				SET fac_id = - 1
					,reg_id = NULL
				WHERE client_id = - 9999
					AND fac_id <> - 1
					AND deleted = 'N'
					AND reg_id IS NULL

				UPDATE as_assessment_section
				SET fac_id = - 1
				WHERE assess_id IN (
						SELECT assess_id
						FROM as_assessment
						WHERE client_id = - 9999
							AND fac_id <> - 1
							AND deleted = 'N'
							AND reg_id IS NULL
						)

				UPDATE as_std_assessment
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				--update 	as_std_pick_list				set fac_id = -1 where fac_id <> -1
				UPDATE as_std_trigger
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cp_consistency_rule
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cp_fst_type
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE as_std_assess_schedule
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1 -- added by Ryan - case 383795 - discussed with Rina Sept. 18, 2013

				UPDATE cp_interv_groups
				SET fac_id = - 1

				UPDATE cp_kardex_categories
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cp_lbr_category
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cp_lbr_library
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cp_std_etiologies
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cp_std_frequency
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cp_std_goal
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cp_std_intervention
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cp_std_library
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cp_std_need
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cp_std_need_cat
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cp_std_question
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cp_std_schedule
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cp_std_shift
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cp_std_task_library
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cr_std_alert
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE cr_std_immunization
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE crm_codes
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE diagnosis_codes
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE gl_account_groups
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND fac_id <> - 1

				UPDATE common_code
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE gl_common_code
				SET fac_id = - 1
				WHERE deleted = 'N'
					AND fac_id <> - 1

				UPDATE gl_report_accounts
				SET fac_id = - 1
				WHERE fac_id <> - 1

				UPDATE gl_reports
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE id_type
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE inc_std_pick_list_item
				SET fac_id = - 1
					,reg_id = NULL
				WHERE reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE pho_administration_record
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE pho_body_location
				SET fac_id = - 1
				WHERE deleted = 'N'
					AND fac_id <> - 1

				UPDATE pho_order_type
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE pho_std_phys_order
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				---------- updated by RYAN, as requested by Kelly Cherchio -- 02/05/2021
				UPDATE emc_ext_facilities
				SET fac_id = - 1
					,revision_by = @Creator
					,revision_date = getdate()
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				------------ updated by RYAN, as requested by Kelly Cherchio -- 03/01/2021
				IF EXISTS (
						SELECT 1
						FROM facility_audit
						WHERE fac_id = 1
							AND name = 'ALF Template Database'
						)
					AND @healthtype = 'ALF'
				BEGIN
					UPDATE evt_std_event_type
					SET fac_id = - 1
						,revision_by = @Creator
						,revision_date = getdate()
					WHERE deleted = 0
						AND retired = 0
						AND reg_id IS NULL
						AND state_code IS NULL
						AND fac_id <> - 1
				END

				---------- 
				UPDATE pho_std_time
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE pho_std_time_details
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND fac_id <> - 1

				UPDATE pn_template
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE pn_type
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE prot_std_protocol_config
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND fac_id <> - 1

				UPDATE prov_state
				SET fac_id = - 1
				WHERE deleted = 'N'
					AND fac_id <> - 1

				UPDATE qa_category
				SET fac_id = - 1
					,reg_id = NULL
				WHERE reg_id IS NULL
					AND fac_id <> - 1

				UPDATE qa_indicator
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND fac_id <> - 1

				UPDATE user_field_types
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE wv_std_vitals
				SET fac_id = - 1
				WHERE fac_id <> - 1

				UPDATE upload_categories
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1 --corporate scoping does not work unless regid is null

				UPDATE census_codes
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1 --corporate scoping does not work unless regid is null

				UPDATE ar_rate_type_category
				SET fac_id = - 1
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1 --corporate scoping does not work unless regid is null

				UPDATE ta_item_type
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE sec_role
				SET fac_id = - 1
					,reg_id = NULL
				WHERE reg_id IS NULL
					AND fac_id <> - 1

				UPDATE ap_lib_vendors
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				UPDATE ap_vendor_groups
				SET fac_id = - 1
				WHERE deleted = 'N'
					AND fac_id <> - 1

				UPDATE gl_lib_accounts
				SET fac_id = - 1
					,reg_id = NULL
				WHERE deleted = 'N'
					AND reg_id IS NULL
					AND state_code IS NULL
					AND fac_id <> - 1

				--------------------------------------------------
				-- added by RYAN - 12/03/2020
				-- email from Product -- IPC & Facility Acquisition Process -- Tuesday, November 24, 2020 10:06 AM
				-- there are two parts to this update - this is for the EMC insert - the second part is below only for the new fac
				INSERT INTO branded_library_feature_configuration (
					fac_id
					,brand_id
					,name
					,value
					,enabled_by
					,enabled_date
					,disabled_by
					,disabled_date
					,created_by
					,created_date
					,revision_by
					,revision_date
					,sequence
					)
				SELECT - 1
					,lib.brand_id
					,'enable_cp_partner_feature_emc'
					,f.value
					,@Creator
					,GETDATE()
					,NULL
					,NULL
					,@Creator
					,GETDATE()
					,@Creator
					,GETDATE()
					,con.sequence
				FROM branded_library_configuration lib WITH (NOLOCK)
				JOIN branded_library_tier_configuration con WITH (NOLOCK) ON lib.brand_id = con.brand_id
				JOIN branded_library_feature_configuration f WITH (NOLOCK) ON con.brand_id = f.brand_id
				WHERE NOT EXISTS (
						SELECT name
						FROM branded_library_feature_configuration WITH (NOLOCK)
						WHERE name = 'enable_cp_partner_feature_emc'
						)
					AND lib.brand_name = 'PCC Infection Control solution'
					AND lib.deleted = 'N'
					AND f.name = 'enable_cp_partner_feature'
					AND f.fac_id = @SourceFac

				-------------------------------------------------- 
				IF (
						SELECT count(*)
						FROM configuration_parameter
						WHERE NAME IN (
								'enable_cs_default_quick_link_icon'
								,'enable_cs_quick_link'
								,'enable_cs_quick_link_icon_desc'
								,'enable_cs_quick_link_url'
								)
							AND fac_id = - 1
						) = 0
				BEGIN
					UPDATE configuration_parameter
					SET fac_id = - 1
					WHERE NAME IN (
							'enable_cs_default_quick_link_icon'
							,'enable_cs_quick_link'
							,'enable_cs_quick_link_icon_desc'
							,'enable_cs_quick_link_url'
							)
						AND fac_id <> - 1
				END
						--print 'Second facility cororate scoping complete'
			END

			SELECT @facexist = fac_id
			FROM [dbo].facility
			WHERE fac_id = @FacIdDest

			IF @Facexist = 0
			BEGIN
				--changed on nov/18/2010 add field use_protocol_flag = 'Y'
				INSERT INTO [dbo].facility (
					fac_id
					,deleted
					,created_by
					,created_date
					,org_id
					,[name]
					,facility_code
					,Prov
					,country_id
					,time_zone
					,timeout_minutes
					,facility_type
					,health_type
					,adjust_for_dst
					,regional_id
					,address1
					,address2
					,city
					,pc
					,use_protocol_flag
					,fac_uuid
					)
				VALUES (
					@FacIdDest
					,'N'
					,@Creator
					,getDate()
					,@orgid
					,@name
					,@facilitycode
					,@state
					,100
					,@timezone
					,60
					,@factype
					,@healthtype
					,'Y'
					,@regid
					,''
					,''
					,''
					,''
					,'Y'
					,@FacUUID
					)

				INSERT INTO department_position
				SELECT position_id
					,department_id
					,@Creator
					,getdate()
					,@Creator
					,getdate()
					,@FacIdDest
				FROM department_position
				WHERE fac_id = @SourceFac

				IF (object_id('tempdb..#facility_cc_VALUES', 'U') IS NOT NULL)
				BEGIN
					DROP TABLE #facility_cc_VALUES
				END

				SELECT @MaxID = MAX(facility_cc_value_id) + 1
				FROM [dbo].facility_cc_VALUES

				SET @Maxid = ISNULL(@Maxid, 1)

				SELECT identity(INT, 1, 1) facility_cc_value_id
					,@FacIdDest fac_id
					,facility_cc_id facility_cc_id
					,NULL facility_cc_SELECT_item_id
					,NULL cc_value
					,@Creator created_by
					,getdate() created_date
					,@creator revision_by
					,getdate() revision_date
					,deleted
					,deleted_by
					,deleted_date
				INTO #facility_cc_VALUES
				FROM facility_cc_VALUES
				WHERE fac_id = @sourcefac

				INSERT INTO [dbo].facility_cc_VALUES (
					facility_cc_value_id
					,fac_id
					,facility_cc_id
					,facility_cc_SELECT_item_id
					,cc_value
					,created_by
					,created_date
					,revision_by
					,revision_date
					,deleted
					,deleted_by
					,deleted_date
					)
				SELECT @Maxid + facility_cc_value_id
					,fac_id
					,facility_cc_id
					,facility_cc_SELECT_item_id
					,cc_value
					,created_by
					,created_date
					,revision_by
					,revision_date
					,deleted
					,deleted_by
					,deleted_date
				FROM #facility_cc_VALUES

				DROP TABLE #facility_cc_VALUES

				INSERT INTO [dbo].general_config (
					fac_id
					,deleted
					,created_by
					,created_date
					,late_entry_period
					,blank_pn_on24hr
					,blank_pn_onshIFt
					,country_id
					)
				VALUES (
					@FacIdDest
					,'N'
					,@Creator
					,getDate()
					,24
					,'Y'
					,'Y'
					,100
					)

				INSERT INTO [dbo].as_hcfa672 (
					report_id
					,report_date
					,fac_id
					,F99
					,F98
					,F97
					,F96
					,F95
					,F94
					,F93
					,F92
					,F91
					,F90
					,F89
					,F88
					,F87
					,F86
					,F85
					,F84
					,F83
					,F82
					,F81
					,F80
					,F79
					,F78
					,F77
					,F76
					,F75
					,F148
					,F147
					,F146
					,F145
					,F144
					,F143
					,F142
					,F141
					,F140
					,F139
					,F138
					,F137
					,F136
					,F135
					,F134
					,F133
					,F132
					,F131
					,F130
					,F129
					,F128
					,F127
					,F126
					,F125
					,F124
					,F123
					,F122
					,F121
					,F120
					,F119
					,F118
					,F117
					,F116
					,F115
					,F114
					,F113
					,F112
					,F111
					,F110
					,F109
					,F108
					,F107
					,F106
					,F105
					,F104
					,F103
					,F102
					,F101
					,F100
					)
				SELECT @FacIdDest
					,getDate()
					,@FacIdDest
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL

				INSERT INTO [dbo].as_configuration (
					fac_id
					,medicare_prov_no
					,medicaid_prov_no
					,state_facility_id
					,contact_name
					,contact_phone
					,contact_phone_ext
					,agent_tax_id
					,agent_name
					,agent_address1
					,agent_address2
					,agent_city
					,agent_prov_state
					,agent_postal_zip
					,agent_contact_name
					,agent_phone
					,agent_phone_ext
					,cmi_SET_fed
					,cmi_SET_state
					,calc_type_fed
					,calc_type_state
					,default_mds_id
					,default_cmi_id
					,cmi_factor
					,dsh
					)
				SELECT @FacIdDest
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,agent_tax_id
					,agent_name
					,agent_address1
					,agent_address2
					,agent_city
					,agent_prov_state
					,agent_postal_zip
					,agent_contact_name
					,agent_phone
					,agent_phone_ext
					,cmi_SET_fed
					,cmi_SET_state
					,calc_type_fed
					,calc_type_state
					,default_mds_id
					,default_cmi_id
					,cmi_factor
					,dsh
				FROM [dbo].as_configuration
				WHERE fac_id = @SourceFac

				----changed on nov/18/2010
				INSERT INTO [dbo].ar_configuration (
					fac_id
					,deleted
					,created_by
					,created_date
					,posting_year
					,posting_month
					,contact_type_id
					,next_batch_number
					,next_cash_receipt_number
					,physician
					,census_revision_window
					,rate_revision_window
					,beds_as_number
					,hc_no_id
					,ssn_id
					,nsf_ref_account_id
					,medicaid_id
					,medicare_id
					,next_eft_number
					,ar_start_date
					,unit_of_measure
					,allow_outpatient
					,term_client
					,show_facility
					,show_client
					,diag_principal
					,diag_admission
					,bill_unk_care_level
					,census_time_format
					,census_past_months
					,auto_create_census
					,use_gl_ext
					,show_cash_receipt_type_summary
					,ub_facility_type
					,aging_bucket_count
					,medicare_no_pay_flag
					,anc_post_date_flag
					,adj_post_date_flag
					,cash_receipt_comment_flag
					,batch_report_comment_flag
					,allow_future_census_flag
					,days_before_closing_month
					,transaction_check_flag
					,recurring_charges_by_day_start_date ---- added by Jaspreet - 01/06/2022
					)
				VALUES (
					@FacIdDest
					,'N'
					,@Creator
					,GETDATE()
					,@ARYear
					,@ARMonth
					,'9040'
					,1
					,1
					,9022
					,999
					,999
					,CASE 
						WHEN @healthtype = 'ALF'
							THEN 'A'
						ELSE 'N'
						END -- added by RYAN - 04/13/2020 - as requested by PMO team - default is N unless it's an ALF building
					,6
					,5
					,- 1
					,4
					,3
					,1
					,@ARStartDate
					,'I'
					,'N'
					,'Resident'
					,'Y'
					,'Y'
					,1047
					,9399
					,'N'
					,'Military'
					,6
					,'N'
					,'N'
					,'Y'
					,'2'
					,'24'
					,'Y'
					,'N'
					,'N'
					,'Y'
					,'Y'
					,'Y'
					,0
					,'Y' ---- added by RYAN - 04/14/2020
					,@ARStartDate ---- added by Jaspreet - 01/06/2022
					)

				BEGIN
					IF NOT EXISTS (
							SELECT 1
							FROM ar_configuration
							WHERE fac_id = - 1
							)
						INSERT INTO [dbo].ar_configuration (
							fac_id
							,deleted
							,created_by
							,created_date
							,revision_by
							,revision_date
							,posting_year
							,posting_month
							)
						VALUES (
							- 1
							,'N'
							,@Creator
							,getdate()
							,@Creator
							,getdate()
							,- 1
							,- 1
							)
				END

				IF NOT EXISTS (
						SELECT 1
						FROM edi_format
						WHERE fac_id = @FacIdDest
							AND specification_type_id = 15
							AND specification_id = 36
							AND deleted = 'N'
						)
				BEGIN
					SET @MaxSetupID = NULL

					DELETE
					FROM pcc_global_primary_key
					WHERE table_name = 'edi_format'
						AND key_column_name = 'format_id';

					SELECT @MaxSetupID = coalesce(max(format_id), 0)
					FROM dbo.edi_format WITH (NOLOCK)

					SET @MaxSetupID = @MaxSetupID + 1

					----EXEC [dbo].get_next_primary_key 'edi_format'
					----	,'format_id'
					----	,@MaxSetupID OUTPUT
					----	,1
					--add on Jun 27th by case 199439 
					INSERT edi_format (
						format_id
						,created_by
						,created_date
						,revision_by
						,revision_date
						,deleted
						,deleted_by
						,deleted_date
						,fac_id
						,specification_type_id
						,specification_id
						,description
						,option1
						,option2
						,option3
						,sequence_no
						)
					SELECT @MaxSetupID
						,@Creator
						,getdate()
						,NULL
						,NULL
						,'N'
						,NULL
						,NULL
						,@FacIdDest
						,15
						,36
						,'Adjustment Batch Import'
						,NULL
						,NULL
						,NULL
						,1
				END

				-------------------------------------
				--add on March 24th, 2016 by case 368411 
				-- to insert for facility
				IF NOT EXISTS (
						SELECT 1
						FROM edi_format
						WHERE fac_id = @FacIdDest
							AND specification_type_id = 11
							AND specification_id = 32
							AND deleted = 'N'
						)
				BEGIN
					SET @MaxSetupID = NULL

					DELETE
					FROM pcc_global_primary_key
					WHERE table_name = 'edi_format'
						AND key_column_name = 'format_id';

					SELECT @MaxSetupID = coalesce(max(format_id), 0)
					FROM dbo.edi_format WITH (NOLOCK)

					SET @MaxSetupID = @MaxSetupID + 1

					----EXEC [dbo].get_next_primary_key 'edi_format'
					----	,'format_id'
					----	,@MaxSetupID OUTPUT
					----	,1
					--add on Jun 27th by case 199439 
					INSERT edi_format (
						format_id
						,created_by
						,created_date
						,revision_by
						,revision_date
						,deleted
						,deleted_by
						,deleted_date
						,fac_id
						,specification_type_id
						,specification_id
						,description
						,option1
						,option2
						,option3
						,sequence_no
						)
					SELECT @MaxSetupID
						,@Creator
						,getdate()
						,NULL
						,NULL
						,'N'
						,NULL
						,NULL
						,@FacIdDest
						,11
						,32
						,'Export Collections Accounts'
						,NULL
						,NULL
						,NULL
						,1
				END

				------------
				--add on March 24th, 2016 by case 368411 
				-- to insert for corporate
				IF NOT EXISTS (
						SELECT 1
						FROM edi_format
						WHERE fac_id = - 1
							AND specification_type_id = 11
							AND specification_id = 32
							AND deleted = 'N'
						)
				BEGIN
					SET @MaxSetupID = NULL

					DELETE
					FROM pcc_global_primary_key
					WHERE table_name = 'edi_format'
						AND key_column_name = 'format_id';

					SELECT @MaxSetupID = coalesce(max(format_id), 0)
					FROM dbo.edi_format WITH (NOLOCK)

					SET @MaxSetupID = @MaxSetupID + 1

					----EXEC [dbo].get_next_primary_key 'edi_format'
					----	,'format_id'
					----	,@MaxSetupID OUTPUT
					----	,1
					--add on Jun 27th by case 199439 
					INSERT edi_format (
						format_id
						,created_by
						,created_date
						,revision_by
						,revision_date
						,deleted
						,deleted_by
						,deleted_date
						,fac_id
						,specification_type_id
						,specification_id
						,description
						,option1
						,option2
						,option3
						,sequence_no
						)
					SELECT @MaxSetupID
						,@Creator
						,getdate()
						,NULL
						,NULL
						,'N'
						,NULL
						,NULL
						,- 1
						,11
						,32
						,'Export Collections Accounts'
						,NULL
						,NULL
						,NULL
						,1
				END

				---------------------------------------------
				INSERT INTO [dbo].ta_configuration (
					fac_id
					,deleted
					,created_by
					,created_date
					,posting_month
					,posting_year
					,cash_box_account_id
					,next_deposit_number
					,next_withdrawal_number
					,next_interest_number
					,next_ar_payment_number
					,default_account_id
					,default_std_account_id
					,CONTACT_TYPE_ID
					,allow_cash_split
					,interest_item_type
					)
				VALUES (
					@FacIdDest
					,'N'
					,@Creator
					,GETDATE()
					,CASE 
						WHEN @ARMonth = 1
							THEN 12
						ELSE @ARMonth - 1
						END
					,CASE 
						WHEN @ARMonth = 1
							THEN @ARYear - 1
						ELSE @ARYear
						END
					,NULL
					,1
					,1
					,1
					,1
					,NULL
					,NULL
					,NULL
					,'N' -- Modified BY: Jaspreet Singh, Date - 10/10/2019, Reason - Netsuite case# 1528398, Original Value was 'Y'
					,NULL
					)

				SELECT identity(INT, 1, 1) AS account_id
					,@FacIdDest fac_id
					,deleted
					,@Creator created_by
					,GETDATE() created_date
					,@Creator revision_by
					,GETDATE() revision_date
					,description
					,current_balance
					,last_statement_balance
					,last_statement_date
					,cash_box_reference
					,normal_balance
					,account_code
					,DELETED_BY
					,DELETED_DATE
				INTO #ta_control_account
				FROM ta_control_account
				WHERE fac_id = @SourceFac

				SET @Rowcount = @@rowcount

				--select *
				--from ta_control_account
				IF @Rowcount > 0
				BEGIN
					SET @MaxSetupID = NULL

					DELETE
					FROM pcc_global_primary_key
					WHERE table_name = 'ta_control_account'
						AND key_column_name = 'account_id';

					SELECT @MaxSetupID = coalesce(max(account_id), 0)
					FROM dbo.ta_control_account WITH (NOLOCK)

					----EXEC [dbo].get_next_primary_key 'ta_control_account'
					----	,'account_id'
					----	,@MaxSetupID OUTPUT
					----	,@Rowcount
					IF EXISTS (
							SELECT *
							FROM INFORMATION_SCHEMA.columns
							WHERE table_name = 'ta_control_account'
								AND COLUMN_NAME = 'account_number'
							) --this column was added for 3.7.14 release
					BEGIN
						INSERT INTO dbo.ta_control_account (
							account_id
							,fac_id
							,deleted
							,created_by
							,created_date
							,revision_by
							,revision_date
							,description
							,current_balance
							,last_statement_balance
							,last_statement_date
							,cash_box_reference
							,normal_balance
							,account_code
							,deleted_by
							,deleted_date
							,account_number
							)
						SELECT account_id + @MaxSetupID
							,fac_id
							,deleted
							,created_by
							,created_date
							,revision_by
							,revision_date
							,description
							,current_balance
							,last_statement_balance
							,last_statement_date
							,cash_box_reference
							,normal_balance
							,account_code
							,DELETED_BY
							,DELETED_DATE
							,'Control_Account_' + CONVERT(VARCHAR, account_id + @MaxSetupID)
						FROM #ta_control_account
					END
					ELSE
					BEGIN
						INSERT INTO dbo.ta_control_account (
							account_id
							,fac_id
							,deleted
							,created_by
							,created_date
							,revision_by
							,revision_date
							,description
							,current_balance
							,last_statement_balance
							,last_statement_date
							,cash_box_reference
							,normal_balance
							,account_code
							,DELETED_BY
							,DELETED_DATE
							)
						SELECT account_id + @MaxSetupID
							,fac_id
							,deleted
							,created_by
							,created_date
							,revision_by
							,revision_date
							,description
							,current_balance
							,last_statement_balance
							,last_statement_date
							,cash_box_reference
							,normal_balance
							,account_code
							,DELETED_BY
							,DELETED_DATE
						FROM #ta_control_account
					END
				END

				DROP TABLE #ta_control_account

				SELECT identity(INT, 1, 1) AS income_source_id
					,@FacIdDest fac_id
					,deleted
					,@Creator created_by
					,GETDATE() created_date
					,@Creator revision_by
					,GETDATE() revision_date
					,description
					,DELETED_BY
					,DELETED_DATE
				INTO #ta_income_source
				FROM ta_income_source
				WHERE fac_id = @SourceFac

				SET @Rowcount = @@rowcount

				IF @Rowcount > 0
				BEGIN
					SET @MaxSetupID = NULL

					DELETE
					FROM pcc_global_primary_key
					WHERE table_name = 'ta_income_source'
						AND key_column_name = 'income_source_id';

					SELECT @MaxSetupID = coalesce(max(income_source_id), 0)
					FROM dbo.ta_income_source WITH (NOLOCK)

					----EXEC [dbo].get_next_primary_key 'ta_income_source'
					----	,'income_source_id'
					----	,@MaxSetupID OUTPUT
					----	,@Rowcount
					INSERT INTO dbo.ta_income_source (
						income_source_id
						,fac_id
						,deleted
						,created_by
						,created_date
						,revision_by
						,revision_date
						,description
						,DELETED_BY
						,DELETED_DATE
						)
					SELECT income_source_id + @MaxSetupID
						,fac_id
						,deleted
						,created_by
						,created_date
						,revision_by
						,revision_date
						,description
						,DELETED_BY
						,DELETED_DATE
					FROM #ta_income_source
				END

				DROP TABLE #ta_income_source

				--
				SELECT identity(INT, 1, 1) AS std_account_id
					,@FacIdDest fac_id
					,deleted
					,@Creator created_by
					,GETDATE() created_date
					,@Creator revision_by
					,GETDATE() revision_date
					,description
					,max_balance
					,min_balance
					,std_account_code
					,DELETED_BY
					,DELETED_DATE
				INTO #ta_std_account
				FROM ta_std_account
				WHERE fac_id = @SourceFac

				SET @Rowcount = @@rowcount

				IF @Rowcount > 0
				BEGIN
					SET @MaxSetupID = NULL

					DELETE
					FROM pcc_global_primary_key
					WHERE table_name = 'ta_std_account'
						AND key_column_name = 'std_account_id';

					SELECT @MaxSetupID = coalesce(max(std_account_id), 0)
					FROM dbo.ta_std_account WITH (NOLOCK)

					----EXEC [dbo].get_next_primary_key 'ta_std_account'
					----	,'std_account_id'
					----	,@MaxSetupID OUTPUT
					----	,@Rowcount
					IF EXISTS (
							SELECT *
							FROM INFORMATION_SCHEMA.columns
							WHERE table_name = 'ta_std_account'
								AND COLUMN_NAME = 'res_account_number'
							) --this column was added for 3.7.14 release
					BEGIN
						INSERT INTO dbo.ta_std_account (
							std_account_id
							,fac_id
							,deleted
							,created_by
							,created_date
							,revision_by
							,revision_date
							,description
							,max_balance
							,min_balance
							,std_account_code
							,DELETED_BY
							,DELETED_DATE
							,res_account_number
							)
						SELECT std_account_id + @MaxSetupID
							,fac_id
							,deleted
							,created_by
							,created_date
							,revision_by
							,revision_date
							,description
							,max_balance
							,min_balance
							,std_account_code
							,DELETED_BY
							,DELETED_DATE
							,'Resident_Account_' + CONVERT(VARCHAR, std_account_id + @MaxSetupID)
						FROM #ta_std_account
					END
					ELSE
					BEGIN
						INSERT INTO dbo.ta_std_account (
							std_account_id
							,fac_id
							,deleted
							,created_by
							,created_date
							,revision_by
							,revision_date
							,description
							,max_balance
							,min_balance
							,std_account_code
							,DELETED_BY
							,DELETED_DATE
							)
						SELECT std_account_id + @MaxSetupID
							,fac_id
							,deleted
							,created_by
							,created_date
							,revision_by
							,revision_date
							,description
							,max_balance
							,min_balance
							,std_account_code
							,DELETED_BY
							,DELETED_DATE
						FROM #ta_std_account
					END
				END

				DROP TABLE #ta_std_account

				--TA_configuration add on 2010-11-25 case:163591
				--==========================================================
				DECLARE @contact_type_id INT
					,@interest_type_id INT
					,@Acc_control_id INT
					,@Acc_resident_id INT
					,@Acc_cash_box_id INT

				SET @contact_type_id = (
						SELECT TOP 1 item_id
						FROM common_code
						WHERE short_description = 'ARG'
							AND item_code = 'respo'
							AND deleted = 'N'
							AND (
								fac_id = - 1
								OR fac_id = @FacIdDest
								)
						)
				SET @interest_type_id = (
						SELECT TOP 1 item_type_id
						FROM dbo.ta_item_type
						WHERE description = 'Interest'
							AND (
								fac_id = - 1
								OR fac_id = @FacIdDest
								)
						)
				SET @Acc_control_id = (
						SELECT TOP 1 account_id
						FROM dbo.ta_control_account
						WHERE description = 'Bank'
							AND (
								fac_id = - 1
								OR fac_id = @FacIdDest
								)
						)
				SET @Acc_resident_id = (
						SELECT TOP 1 std_account_id
						FROM dbo.ta_std_account
						WHERE description = 'Resident Trust'
							AND std_account_code = 'Res'
							AND (
								fac_id = - 1
								OR fac_id = @FacIdDest
								)
						)
				SET @Acc_cash_box_id = (
						SELECT TOP 1 account_id
						FROM dbo.ta_control_account
						WHERE description = 'Trust Petty Cash'
							AND (
								fac_id = - 1
								OR fac_id = @FacIdDest
								)
						)

				UPDATE ta_configuration
				SET cash_box_account_id = @Acc_cash_box_id
					,default_account_id = @Acc_control_id
					,default_std_account_id = @Acc_resident_id
					,CONTACT_TYPE_ID = @contact_type_id
					,interest_item_type = @interest_type_id
				WHERE fac_id = @FacIdDest

				--==========================================================
				--==========================================================
				--
				INSERT INTO [dbo].gl_configuration (
					fac_id
					,deleted
					,created_by
					,created_date
					,deleted_by
					,deleted_date
					,revision_by
					,revision_date
					,current_fiscal_year
					,posting_to_previous_years_flag
					,def_ret_earnings_act_id
					,auto_post_ap
					,auto_post_ap_noncash
					,auto_post_ar
					,auto_post_ar_noncash
					,post_to_control_flag
					,auto_post_ap_reversals
					,imported_fac_id
					,check_rec_YN
					,/*bank_rec_YN,*/ append_facility_code
					,corp_bank_rec_YN
					)
				SELECT @FacIdDest
					,'N'
					,@Creator
					,GETDATE()
					,NULL
					,NULL
					,NULL
					,NULL
					,@GLAPYear
					,posting_to_previous_years_flag
					,def_ret_earnings_act_id
					,auto_post_ap
					,auto_post_ap_noncash
					,auto_post_ar
					,auto_post_ar_noncash
					,post_to_control_flag
					,auto_post_ap_reversals
					,@FacIdDest
					,check_rec_YN
					,/*corp_bank_rec_YN,*/ append_facility_code
					,corp_bank_rec_YN
				FROM [dbo].gl_configuration
				WHERE fac_id = @SourceFac

				INSERT INTO [dbo].glap_config
				SELECT @FacIdDest
					,deleted
					,@Creator
					,getdate()
					,NULL
					,NULL
					,NULL
					,NULL
					,@orgid
					,@name
					,@FiscalYearEND
					,fiscal_periods
					,warning_date_range
					,currency
					,@Use1099
				FROM [dbo].glap_config
				WHERE fac_id = @SourceFac

				SELECT identity(INT, 1, 1) AS setup_id
					,@FacIdDest AS fac_id
					,reg_id
					,group_id
					,@Creator AS created_by
					,getdate() AS created_date
					,NULL AS revision_by
					,NULL AS revision_date
					,'N' AS deleted
					,NULL AS deleted_by
					,NULL AS deleted_date
					,setup_name
					,setup_note
					,default_flag
				INTO #TSetup
				FROM [dbo].rpt_config_setup
				WHERE fac_id = @SourceFac

				SET @Rowcount = @@rowcount

				IF @Rowcount > 0
				BEGIN
					SET @MaxSetupID = NULL

					DELETE
					FROM pcc_global_primary_key
					WHERE table_name = 'rpt_config_setup'
						AND key_column_name = 'setup_id';

					SELECT @MaxSetupID = coalesce(max(setup_id), 0)
					FROM dbo.rpt_config_setup WITH (NOLOCK)

					----EXEC [dbo].get_next_primary_key 'rpt_config_setup'
					----	,'setup_id'
					----	,@MaxSetupID OUTPUT
					----	,@rowcount
					INSERT INTO [dbo].rpt_config_setup (
						setup_id
						,fac_id
						,reg_id
						,group_id
						,created_by
						,created_date
						,revision_by
						,revision_date
						,deleted
						,deleted_by
						,deleted_date
						,setup_name
						,setup_note
						,default_flag
						)
					SELECT setup_id + @MaxSetupID
						,fac_id
						,reg_id
						,group_id
						,created_by
						,created_date
						,revision_by
						,revision_date
						,deleted
						,deleted_by
						,deleted_date
						,setup_name
						,setup_note
						,default_flag
					FROM #TSetup
				END

				SELECT identity(INT, 1, 1) AS setup_param_id
					,setup_id = (
						SELECT setup_id
						FROM rpt_config_setup
						WHERE fac_id = @FacIdDest
						)
					,group_param_id
					,param_label
					,param_value
					,param_order
				INTO #TSetupParam
				FROM rpt_config_setup_param
				WHERE setup_id IN (
						SELECT setup_id
						FROM #TSetup
						WHERE fac_id = @SourceFac
						)

				SET @Rowcount = @@rowcount

				IF @Rowcount > 0
				BEGIN
					SET @MaxSetupParamID = NULL

					DELETE
					FROM pcc_global_primary_key
					WHERE table_name = 'rpt_config_setup_param'
						AND key_column_name = 'setup_param_id';

					SELECT @MaxSetupParamID = coalesce(max(setup_param_id), 0)
					FROM dbo.rpt_config_setup_param WITH (NOLOCK)

					----EXEC get_next_primary_key 'rpt_config_setup_param'
					----	,'setup_param_id'
					----	,@MaxSetupParamID OUTPUT
					----	,@rowcount
					INSERT INTO rpt_config_setup_param (
						setup_param_id
						,setup_id
						,group_param_id
						,param_label
						,param_value
						,param_order
						)
					SELECT setup_param_id + @MaxSetupParamID
						,setup_id
						,group_param_id
						,param_label
						,param_value
						,param_order
					FROM #TSetupParam
				END

				DROP TABLE #TSetup

				DROP TABLE #TSetupParam

				--select * from adt_census_configuration
				INSERT INTO adt_census_configuration
				VALUES (
					@FacIdDest
					,'Y'
					,getdate()
					,@Creator
					,'N'
					,'N'
					,@Creator
					,getdate()
					,NULL
					,NULL
					,'N'
					,NULL
					,NULL
					)
			END

			--drop table #tsetup drop table #TSetupParam
			--==================================================================================================
			--Facilities 1 AND 2 UPDATE statements
			--================================================================================================
			IF @Facexist <> 0
			BEGIN
				--changed on nov/18/2010 add fiels use_protocol_flag = 'Y'
				UPDATE facility
				SET deleted = 'N'
					,created_by = @Creator
					,created_date = getdate()
					,revision_by = @Creator
					,revision_date = getdate()
					,org_id = @orgid
					,[name] = @name
					,facility_code = @facilitycode
					,prov = @state
					,health_type = @healthtype
					,facility_type = @factype
					,regional_id = @regid
					,use_protocol_flag = 'Y'
					,time_zone = @timezone --added time_zone on 2014-04-28
					,fac_uuid = @FacUUID
				WHERE fac_id = @FacIdDest

				UPDATE ar_configuration
				SET created_date = getDate()
					,revision_by = NULL
					,revision_date = NULL
					,posting_month = @ARMonth
					,posting_year = @ARYear
					,ar_start_date = @ARStartDate
					,recurring_charges_by_day_start_date = @ARStartDate ---- added by Jaspreet - 01/06/2022
					,unit_of_measure = 'I'
					,statement_message = NULL
				WHERE fac_id = @FacIdDest

				UPDATE ta_configuration
				SET created_date = getDate()
					,revision_by = NULL
					,revision_date = NULL
					,cash_box_account_id = NULL
					,default_account_id = NULL
					,default_std_account_id = NULL
					,CONTACT_TYPE_ID = NULL
					,interest_item_type = NULL
					,posting_month = CASE 
						WHEN @ARMonth = 1
							THEN 12
						ELSE @ARMonth - 1
						END
					,posting_year = CASE 
						WHEN @ARMonth = 1
							THEN @ARYear - 1
						ELSE @ARYear
						END
				WHERE fac_id = @FacIdDest

				UPDATE gl_configuration
				SET current_fiscal_year = @GLAPYear
				WHERE fac_id = @FacIdDest

				UPDATE glap_config
				SET org_id = @orgid
					,fiscal_year_end_month = @FiscalYearEnd
					,[name] = @name
					,use_1099 = @Use1099
				WHERE fac_id = @FacIdDest
			END

			--===================================================================================
			--End existing facility updates
			--===================================================================================
			DELETE
			FROM [dbo].glap_fiscal_calendar_periods
			WHERE fac_id = @FacIdDest

			DELETE
			FROM [dbo].glap_fiscal_calendar
			WHERE fac_id = @FacIdDest

			--==================================================================
			SET @FacExist = 0

			SELECT @facexist = fac_id
			FROM glap_fiscal_calendar
			WHERE fac_id = @FacIdDest

			IF @Facexist = 0
			BEGIN
				CREATE TABLE #T_glap_years (
					rowID INT identity(1, 1)
					,Fyear VARCHAR(6)
					,Ctype VARCHAR(2)
					)

				INSERT INTO #T_glap_years (
					Fyear
					,Ctype
					)
				VALUES (
					@GLAPYEAR1
					,'GL'
					)

				INSERT INTO #T_glap_years (
					Fyear
					,Ctype
					)
				VALUES (
					@GLAPYEAR2
					,'GL'
					)

				INSERT INTO #T_glap_years (
					Fyear
					,Ctype
					)
				VALUES (
					@GLAPYEAR3
					,'GL'
					)

				INSERT INTO #T_glap_years (
					Fyear
					,Ctype
					)
				VALUES (
					@GLAPYEAR4
					,'GL'
					)

				INSERT INTO #T_glap_years (
					Fyear
					,Ctype
					)
				VALUES (
					@GLAPYEAR1
					,'AP'
					)

				INSERT INTO #T_glap_years (
					Fyear
					,Ctype
					)
				VALUES (
					@GLAPYEAR2
					,'AP'
					)

				INSERT INTO #T_glap_years (
					Fyear
					,Ctype
					)
				VALUES (
					@GLAPYEAR3
					,'AP'
					)

				INSERT INTO #T_glap_years (
					Fyear
					,Ctype
					)
				VALUES (
					@GLAPYEAR4
					,'AP'
					)

				SELECT *
				INTO #tYear
				FROM #T_glap_years

				SET @Rowcount = @@rowcount

				IF @Rowcount > 0
				BEGIN
					SET @MaxcalendarID = NULL

					DELETE
					FROM pcc_global_primary_key
					WHERE table_name = 'glap_fiscal_calendar'
						AND key_column_name = 'fiscal_calendar_id';

					SELECT @MaxcalendarID = coalesce(max(fiscal_calendar_id), 0)
					FROM dbo.glap_fiscal_calendar WITH (NOLOCK)

					----EXEC get_next_primary_key 'glap_fiscal_calendar'
					----	,'fiscal_calendar_id'
					----	,@MaxcalendarID OUTPUT
					----	,@rowcount
					INSERT INTO glap_fiscal_calendar (
						fac_id
						,fiscal_year
						,deleted
						,created_by
						,created_date
						,adjustment_periods
						,closing_periods
						,active
						,fiscal_calendar_id
						,calendar_type
						)
					SELECT @FacIdDest
						,Fyear
						,'N'
						,@Creator
						,getDate()
						,'Open'
						,'Open'
						,'Y'
						,@MaxcalendarID + rowID
						,Ctype
					FROM #tYear

					DROP TABLE #tYear
				END

				DROP TABLE #T_glap_years
			END

			--==============================================================
			SET @FacExist = 0

			SELECT @facexist = fac_id
			FROM glap_fiscal_calendar_periods
			WHERE fac_id = @FacIdDest

			IF @Facexist = 0
			BEGIN
				DECLARE @ENDMonth INT
					,@StartYear INT
					,@NumberofYear INT
					,@FacID INT
				DECLARE @StartDate DATETIME
					,@ENDDate DATETIME
					,@StartMonth INT
					,@Period INT
					,@YearCounter INT
					,@CurrentYear INT
					,@CurrentMonth INT
					,@CreatedBy VARCHAR(25)

				SET @ENDMonth = @FiscalYearEND
				SET @StartYear = @GLAPYear1
				SET @NumberofYear = 3
				SET @Period = 1
				SET @YearCounter = 1
				SET @FacID = @FacIdDest
				SET @CreatedBy = @Creator
				SET @CurrentYear = @GLAPYear1 --drives fiscal year

				CREATE TABLE #FiscalPeriods (
					FiscalYear INT
					,Period INT
					,StartPeriod DATETIME
					,ENDPeriod DATETIME
					,FacID INT
					)

				IF @ENDMonth = 12
					SET @CurrentMonth = 1
				ELSE
					SET @CurrentMonth = @ENDMonth + 1

				IF @ENDMonth = 12
					SET @StartYear = @GLAPYear1
				ELSE
					SET @StartYear = @GLAPYear2

				WHILE @Period <= 12
					AND @YearCounter <= @NumberofYear
				BEGIN
					SET @StartDate = cast(@CurrentMonth AS VARCHAR) + '/01/' + cast(@CurrentYear AS VARCHAR)
					SET @ENDDate = dateadd(d, - 1, dateadd(m, 1, @Startdate))

					INSERT INTO #FiscalPeriods
					VALUES (
						@StartYear
						,@Period
						,@StartDate
						,@ENDDate
						,@FacID
						)

					SET @Period = @Period + 1
					SET @CurrentMonth = @CurrentMonth + 1

					IF @CurrentMonth = 13
					BEGIN
						SET @CurrentMonth = 1
						SET @CurrentYear = @CurrentYear + 1
					END

					IF @Period = 13
					BEGIN
						SET @YearCounter = @YearCounter + 1
						SET @Period = 1
						SET @StartYear = @StartYear + 1
					END
				END
			END

			BEGIN
				INSERT INTO glap_fiscal_calendar_periods (
					fac_id
					,fiscal_period
					,deleted
					,created_by
					,created_date
					,deleted_by
					,deleted_date
					,revision_by
					,revision_date
					,STATUS
					,start_period
					,end_period
					,fiscal_calendar_id
					)
				SELECT @facid
					,Period
					,'N'
					,@CreatedBy
					,getdate()
					,NULL
					,NULL
					,NULL
					,NULL
					,'Open'
					,Startperiod
					,EndPeriod
					,gl.fiscal_calendar_id
				FROM #FiscalPeriods
				JOIN glap_fiscal_calendar gl ON #FiscalPeriods.facid = gl.fac_id
				WHERE gl.fac_id = @FacID
					AND #FiscalPeriods.FiscalYear IN (
						SELECT fiscal_year
						FROM glap_fiscal_calendar
						WHERE fiscal_year = @GLAPYear1
							AND calendar_type = 'GL'
						)
					AND calendar_type = 'GL'
					AND #FiscalPeriods.FiscalYear = @GLAPYear1
					AND gl.fiscal_year = @GLAPYear1

				INSERT INTO glap_fiscal_calendar_periods (
					fac_id
					,fiscal_period
					,deleted
					,created_by
					,created_date
					,deleted_by
					,deleted_date
					,revision_by
					,revision_date
					,STATUS
					,start_period
					,end_period
					,fiscal_calendar_id
					)
				SELECT @facid
					,Period
					,'N'
					,@CreatedBy
					,getdate()
					,NULL
					,NULL
					,NULL
					,NULL
					,'Open'
					,Startperiod
					,EndPeriod
					,gl.fiscal_calendar_id
				FROM #FiscalPeriods
				JOIN glap_fiscal_calendar gl ON #FiscalPeriods.facid = gl.fac_id
				WHERE gl.fac_id = @FacID
					AND #FiscalPeriods.FiscalYear IN (
						SELECT fiscal_year
						FROM glap_fiscal_calendar
						WHERE fiscal_year = @GLAPYear2
							AND calendar_type = 'GL'
						)
					AND calendar_type = 'GL'
					AND #FiscalPeriods.FiscalYear = @GLAPYear2
					AND gl.fiscal_year = @GLAPYear2

				INSERT INTO glap_fiscal_calendar_periods (
					fac_id
					,fiscal_period
					,deleted
					,created_by
					,created_date
					,deleted_by
					,deleted_date
					,revision_by
					,revision_date
					,STATUS
					,start_period
					,end_period
					,fiscal_calendar_id
					)
				SELECT @facid
					,Period
					,'N'
					,@CreatedBy
					,getdate()
					,NULL
					,NULL
					,NULL
					,NULL
					,'Open'
					,Startperiod
					,EndPeriod
					,gl.fiscal_calendar_id
				FROM #FiscalPeriods
				JOIN glap_fiscal_calendar gl ON #FiscalPeriods.facid = gl.fac_id
				WHERE gl.fac_id = @FacID
					AND #FiscalPeriods.FiscalYear IN (
						SELECT fiscal_year
						FROM glap_fiscal_calendar
						WHERE fiscal_year = @GLAPYear3
							AND calendar_type = 'GL'
						)
					AND calendar_type = 'GL'
					AND #FiscalPeriods.FiscalYear = @GLAPYear3
					AND gl.fiscal_year = @GLAPYear3

				INSERT INTO glap_fiscal_calendar_periods (
					fac_id
					,fiscal_period
					,deleted
					,created_by
					,created_date
					,deleted_by
					,deleted_date
					,revision_by
					,revision_date
					,STATUS
					,start_period
					,end_period
					,fiscal_calendar_id
					)
				SELECT @facid
					,Period
					,'N'
					,@CreatedBy
					,getdate()
					,NULL
					,NULL
					,NULL
					,NULL
					,'Open'
					,Startperiod
					,EndPeriod
					,gl.fiscal_calendar_id
				FROM #FiscalPeriods
				JOIN glap_fiscal_calendar gl ON #FiscalPeriods.facid = gl.fac_id
				WHERE gl.fac_id = @FacID
					AND #FiscalPeriods.FiscalYear IN (
						SELECT fiscal_year
						FROM glap_fiscal_calendar
						WHERE fiscal_year = @GLAPYear4
							AND calendar_type = 'GL'
						)
					AND calendar_type = 'GL'
					AND #FiscalPeriods.FiscalYear = @GLAPYear4
					AND gl.fiscal_year = @GLAPYear4

				INSERT INTO glap_fiscal_calendar_periods (
					fac_id
					,fiscal_period
					,deleted
					,created_by
					,created_date
					,deleted_by
					,deleted_date
					,revision_by
					,revision_date
					,STATUS
					,start_period
					,end_period
					,fiscal_calendar_id
					)
				SELECT @facid
					,Period
					,'N'
					,@CreatedBy
					,getdate()
					,NULL
					,NULL
					,NULL
					,NULL
					,'Open'
					,Startperiod
					,EndPeriod
					,gl.fiscal_calendar_id
				FROM #FiscalPeriods
				JOIN glap_fiscal_calendar gl ON #FiscalPeriods.facid = gl.fac_id
				WHERE gl.fac_id = @FacID
					AND #FiscalPeriods.FiscalYear IN (
						SELECT fiscal_year
						FROM glap_fiscal_calendar
						WHERE fiscal_year = @GLAPYear1
							AND calendar_type = 'AP'
						)
					AND calendar_type = 'AP'
					AND #FiscalPeriods.FiscalYear = @GLAPYear1
					AND gl.fiscal_year = @GLAPYear1

				INSERT INTO glap_fiscal_calendar_periods (
					fac_id
					,fiscal_period
					,deleted
					,created_by
					,created_date
					,deleted_by
					,deleted_date
					,revision_by
					,revision_date
					,STATUS
					,start_period
					,end_period
					,fiscal_calendar_id
					)
				SELECT @facid
					,Period
					,'N'
					,@CreatedBy
					,getdate()
					,NULL
					,NULL
					,NULL
					,NULL
					,'Open'
					,Startperiod
					,EndPeriod
					,gl.fiscal_calendar_id
				FROM #FiscalPeriods
				JOIN glap_fiscal_calendar gl ON #FiscalPeriods.facid = gl.fac_id
				WHERE gl.fac_id = @FacID
					AND #FiscalPeriods.FiscalYear IN (
						SELECT fiscal_year
						FROM glap_fiscal_calendar
						WHERE fiscal_year = @GLAPYear2
							AND calendar_type = 'AP'
						)
					AND calendar_type = 'AP'
					AND #FiscalPeriods.FiscalYear = @GLAPYear2
					AND gl.fiscal_year = @GLAPYear2

				INSERT INTO glap_fiscal_calendar_periods (
					fac_id
					,fiscal_period
					,deleted
					,created_by
					,created_date
					,deleted_by
					,deleted_date
					,revision_by
					,revision_date
					,STATUS
					,start_period
					,end_period
					,fiscal_calendar_id
					)
				SELECT @facid
					,Period
					,'N'
					,@CreatedBy
					,getdate()
					,NULL
					,NULL
					,NULL
					,NULL
					,'Open'
					,Startperiod
					,EndPeriod
					,gl.fiscal_calendar_id
				FROM #FiscalPeriods
				JOIN glap_fiscal_calendar gl ON #FiscalPeriods.facid = gl.fac_id
				WHERE gl.fac_id = @FacID
					AND #FiscalPeriods.FiscalYear IN (
						SELECT fiscal_year
						FROM glap_fiscal_calendar
						WHERE fiscal_year = @GLAPYear3
							AND calendar_type = 'AP'
						)
					AND calendar_type = 'AP'
					AND #FiscalPeriods.FiscalYear = @GLAPYear3
					AND gl.fiscal_year = @GLAPYear3

				INSERT INTO glap_fiscal_calendar_periods (
					fac_id
					,fiscal_period
					,deleted
					,created_by
					,created_date
					,deleted_by
					,deleted_date
					,revision_by
					,revision_date
					,STATUS
					,start_period
					,end_period
					,fiscal_calendar_id
					)
				SELECT @facid
					,Period
					,'N'
					,@CreatedBy
					,getdate()
					,NULL
					,NULL
					,NULL
					,NULL
					,'Open'
					,Startperiod
					,EndPeriod
					,gl.fiscal_calendar_id
				FROM #FiscalPeriods
				JOIN glap_fiscal_calendar gl ON #FiscalPeriods.facid = gl.fac_id
				WHERE gl.fac_id = @FacID
					AND #FiscalPeriods.FiscalYear IN (
						SELECT fiscal_year
						FROM glap_fiscal_calendar
						WHERE fiscal_year = @GLAPYear4
							AND calendar_type = 'AP'
						)
					AND calendar_type = 'AP'
					AND #FiscalPeriods.FiscalYear = @GLAPYear4
					AND gl.fiscal_year = @GLAPYear4

				DELETE
				FROM glap_fiscal_calendar
				WHERE fiscal_calendar_id NOT IN (
						SELECT fiscal_calendar_id
						FROM glap_fiscal_calendar_periods
						)
					AND fac_id = @facID

				UPDATE gl_configuration
				SET current_fiscal_year = (
						SELECT MIN(fiscal_year)
						FROM glap_fiscal_calendar
						WHERE fac_id = @FacIdDest
						)
				WHERE fac_id = @FacIdDest

				DROP TABLE #FiscalPeriods
			END

			--as_std_profile_consistency
			--==================================================================================
			SET @FacExist = 0

			SELECT @facexist = fac_id
			FROM as_std_profile_consistency
			WHERE fac_id = @FacIdDest

			IF @Facexist = 0
			BEGIN
				DECLARE @source_fac_id INT
					,@source_reg_id INT
					,@destination_fac_id INT
					,@start_table_id INT
					,@min_source_id INT
					,@min_destination_id INT
					,@max_source_id INT
					,@max_destination_id INT
					,@src_row_count INT
					,@dest_row_count INT

				--**************************SET parameters below*********************
				SELECT @source_fac_id = @SourceFac

				SELECT @destination_fac_id = @FacIdDest

				--**************************SET parameters above*********************
				CREATE TABLE #copy_as_std_profile_consistency (
					row_id INT IDENTITY
					,src_id INT
					,dst_id INT
					)

				INSERT INTO #copy_as_std_profile_consistency (src_id)
				SELECT std_profile_consistency_id
				FROM as_std_profile_consistency
				WHERE fac_id = @source_fac_id
					AND deleted = 'N'
				ORDER BY std_profile_consistency_id

				SELECT @src_row_count = count(*)
				FROM as_std_profile_consistency
				WHERE fac_id = @source_fac_id
					AND deleted = 'N'

				IF ISNULL(@src_row_count, 0) > 0
				BEGIN
					DECLARE @a_NextasstdprofileconsistencyKey INT

					SET @a_NextasstdprofileconsistencyKey = NULL

					DELETE
					FROM pcc_global_primary_key
					WHERE table_name = 'as_std_profile_consistency'
						AND key_column_name = 'std_profile_consistency_id';

					SELECT @a_NextasstdprofileconsistencyKey = coalesce(max(std_profile_consistency_id), 0)
					FROM dbo.as_std_profile_consistency WITH (NOLOCK)

					----EXECUTE get_next_primary_key 'as_std_profile_consistency'
					----	,'std_profile_consistency_id'
					----	,@a_NextasstdprofileconsistencyKey OUTPUT
					----	,@src_row_count
					SET @start_table_id = @a_NextasstdprofileconsistencyKey

					UPDATE #copy_as_std_profile_consistency
					SET dst_id = @start_table_id + row_id

					----+ (row_id - 1) 
					---- Commented By: Jaspeet Singh
					---- Date: 2021-07-21
					---- Reason: Because begin tran not wotj ith pcc_global_primary_key sp
					INSERT INTO as_std_profile_consistency (
						std_profile_consistency_id
						,std_assess_id
						,question_key
						,class_name
						,change_field
						,compare_field
						,id_type_id
						,enabled
						,fac_id
						,reg_id
						,deleted
						,deleted_by
						,deleted_date
						,profile_description
						)
					SELECT b.dst_id
						,std_assess_id
						,question_key
						,class_name
						,change_field
						,compare_field
						,id_type_id
						,enabled
						,@destination_fac_id
						,reg_id
						,'N'
						,NULL
						,NULL
						,profile_description
					FROM as_std_profile_consistency a
						,#copy_as_std_profile_consistency b
					WHERE a.deleted = 'N'
						AND a.fac_id = @source_fac_id
						AND a.std_profile_consistency_id = b.src_id
				END

				DROP TABLE #copy_as_std_profile_consistency
			END

			/* changed from above as per Shaojing Pan */
			INSERT INTO dbo.cp_std_intervention_fac (
				fac_id
				,std_intervention_id
				)
			SELECT @FacIdDest
				,std_intervention_id
			FROM cp_std_intervention
			WHERE (
					(
						fac_id IN (
							- 1
							,@FacIdDest
							)
						AND Reg_id IS NULL
						AND state_code IS NULL
						)
					OR (
						Reg_id = @regid
						AND state_code IS NULL
						)
					OR (
						Reg_id = @regid
						AND state_code = @state
						)
					)
				AND NOT EXISTS (
					SELECT 1
					FROM cp_std_intervention_fac cp
					WHERE fac_id = @FacIdDest
						AND cp.std_intervention_id = cp_std_intervention.std_intervention_id
					)
				AND deleted = 'N'

			INSERT INTO dbo.cp_std_freq_fac (
				fac_id
				,std_freq_id
				)
			SELECT @FacIdDest
				,std_freq_id
			FROM cp_std_frequency
			WHERE (
					(
						fac_id IN (
							- 1
							,@FacIdDest
							)
						AND Reg_id IS NULL
						AND state_code IS NULL
						)
					OR (
						Reg_id = @regid
						AND state_code IS NULL
						)
					OR (
						Reg_id = @regid
						AND state_code = @state
						)
					)
				AND NOT EXISTS (
					SELECT 1
					FROM cp_std_freq_fac cf
					WHERE fac_id = @FacIdDest
						AND cf.std_freq_id = cp_std_frequency.std_freq_id
					)
				AND deleted = 'N'

			INSERT INTO dbo.cp_std_fuq_fac (
				fac_id
				,question_id
				)
			SELECT @FacIdDest
				,std_question_id
			FROM cp_std_question
			WHERE (
					(
						fac_id IN (
							- 1
							,@FacIdDest
							)
						AND Reg_id IS NULL
						AND state_code IS NULL
						)
					OR (
						Reg_id = @regid
						AND state_code IS NULL
						)
					OR (
						Reg_id = @regid
						AND state_code = @state
						)
					)
				AND NOT EXISTS (
					SELECT 1
					FROM cp_std_fuq_fac cq
					WHERE fac_id = @FacIdDest
						AND cq.question_id = cp_std_question.std_question_id
					)
				AND deleted = 'N'

			INSERT INTO dbo.cp_std_shift_fac (
				fac_id
				,std_shift_id
				)
			SELECT @FacIdDest
				,std_shift_id
			FROM cp_std_shift
			WHERE (
					(
						fac_id IN (
							- 1
							,@FacIdDest
							)
						AND Reg_id IS NULL
						AND state_code IS NULL
						)
					OR (
						Reg_id = @regid
						AND state_code IS NULL
						)
					OR (
						Reg_id = @regid
						AND state_code = @state
						)
					)
				AND NOT EXISTS (
					SELECT 1
					FROM cp_std_shift_fac cs
					WHERE fac_id = @FacIdDest
						AND cs.std_shift_id = cp_std_shift.std_shift_id
					)
				AND deleted = 'N'

			/* end - changed from above as per Shaojing Pan */
			--=====================================================================================
			----State specific updates:  Arizona (AZ)
			--=====================================================================================
			IF @state = 'AZ'
			BEGIN
				--========================================
				--clear AZ FROM prov_state_options column
				--========================================
				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, ',AZ', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE '%,AZ%'
					--added Oct 16 as per Joel
					AND section_code <> 'T'

				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, 'AZ,', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE '%AZ,%'
					--added Oct 16 as per Joel
					AND section_code <> 'T'

				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, 'AZ', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE 'AZ'
					--added Oct 16 as per Joel
					AND section_code <> 'T'

				--========================================
				--AZ uses RUG III 97 version of quarterly
				--========================================
				UPDATE as_std_question
				SET prov_state_options = prov_state_options + ',AZ'
				WHERE std_assess_id = 1
					AND (
						question_key IN (
							'B3a'
							,'B3b'
							,'B3c'
							,'B3d'
							,'B3e'
							,'G1aB'
							,'G1bB'
							,'G1cB'
							,'G1dB'
							,'G1eB'
							,'G1fB'
							,'G1gB'
							,'G1hB'
							,'G1iB'
							,'G1jB'
							,'G3a'
							,'G3b'
							,'G7'
							,'H2c'
							,'I1a'
							,'I1ee'
							,'I1ff'
							,'I1m'
							,'I1r'
							,'I1rr'
							,'I1s'
							,'I1t'
							,'I1v'
							,'I1w'
							,'I1z'
							,'I2a'
							,'I2b'
							,'I2c'
							,'I2d'
							,'I2e'
							,'I2f'
							,'I2g'
							,'I2h'
							,'I2i'
							,'I2k'
							,'I2l'
							,'J1a'
							,'J1b'
							,'J1d'
							,'J1e'
							,'J1g'
							,'J1h'
							,'J1j'
							,'J1k'
							,'J1l'
							,'J1n'
							,'J1o'
							,'K1a'
							,'K1b'
							,'K1d'
							,'K2a'
							,'K2b'
							,'K5a'
							,'K6a'
							,'K6b'
							,'M4a'
							,'M4b'
							,'M4c'
							,'M4d'
							,'M4e'
							,'M4f'
							,'M4g'
							,'M4h'
							,'M5a'
							,'M5b'
							,'M5c'
							,'M5d'
							,'M5e'
							,'M5f'
							,'M5g'
							,'M5h'
							,'M5i'
							,'M5j'
							,'M6a'
							,'M6b'
							,'M6c'
							,'M6d'
							,'M6e'
							,'M6f'
							,'M6g'
							,'O3'
							,'P1aa'
							,'P1ab'
							,'P1ac'
							,'P1ad'
							,'P1ae'
							,'P1af'
							,'P1ag'
							,'P1ah'
							,'P1ai'
							,'P1aj'
							,'P1ak'
							,'P1al'
							,'P1am'
							,'P1an'
							,'P1ao'
							,'P1ap'
							,'P1aq'
							,'P1ar'
							,'P1as'
							,'P1baA'
							,'P1baB'
							,'P1bbA'
							,'P1bbB'
							,'P1bcA'
							,'P1bcB'
							,'P1bdA'
							,'P1bdB'
							,'P1beA'
							,'P1beB'
							,'P3a'
							,'P3b'
							,'P3c'
							,'P3d'
							,'P3e'
							,'P3f'
							,'P3g'
							,'P3h'
							,'P3i'
							,'P3j'
							,'P3k'
							,'P7'
							,'P8'
							,'T1aA'
							,'T1aB'
							,'T1b'
							,'T1c'
							,'T1d'
							,'T2a'
							,'T2b'
							,'T2c'
							,'T2d'
							,'T2e'
							,'T3MDCR'
							,'T3STATE'
							)
						)
					--added Oct 16 as per Joel
					AND section_code <> 'T'

				UPDATE as_std_question
				SET prov_state_options = 'AZ'
				WHERE std_assess_id = 1
					AND section_code = 'S(AZ)'
					--added Oct 16 as per Joel
					AND section_code <> 'T'
			END

			--==================================================================================================
			--State specific updates: Florida(FL)
			--==================================================================================================
			IF @State = 'FL'
			BEGIN
				--=======================
				-- Update group title for SFL1
				--=======================
				UPDATE as_std_question_group
				SET group_title = 'Facility FRAES number.'
				WHERE std_assess_id = 1
					AND std_question_no = 'S1'
					AND section_code = 'S(FL)'

				--============================
				-- Show section S on all types of mds
				--============================
				UPDATE as_std_question
				SET STATUS_A = 'A'
					,STATUS_AM = 'A'
					,STATUS_AO = 'A'
					,STATUS_D = 'A'
					,STATUS_O = 'A'
					,STATUS_OM = 'A'
					,status_om_mpaf = 'A'
					,STATUS_OO = 'A'
					,STATUS_Q = 'A'
					,STATUS_QM = 'A'
					,status_qm_mpaf = 'A'
					,STATUS_QO = 'A'
					,STATUS_R = 'A'
					,STATUS_X = 'A'
					,STATUS_Y = 'A'
					,STATUS_YM = 'A'
					,STATUS_YO = 'A'
					,required = 'N'
					,range = 'Text,sp'
				WHERE std_assess_id = 1
					AND section_code = 'S(FL)'

				--================================
				-- update to use RUGs 97
				--clear FL from prov_state_options column
				--================================
				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, ',FL', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE '%,FL%'

				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, 'FL,', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE '%FL,%'

				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, 'FL', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE 'FL'

				--================================
				--FL uses RUG III 97 version of quarterly
				--================================
				UPDATE as_std_question
				SET prov_state_options = prov_state_options + ',FL'
				WHERE std_assess_id = 1
					AND (
						question_key IN (
							'B3a'
							,'B3b'
							,'B3c'
							,'B3d'
							,'B3e'
							,'G1aB'
							,'G1bB'
							,'G1cB'
							,'G1dB'
							,'G1eB'
							,'G1fB'
							,'G1gB'
							,'G1hB'
							,'G1iB'
							,'G1jB'
							,'G3a'
							,'G3b'
							,'G7'
							,'H2c'
							,'I1a'
							,'I1ee'
							,'I1ff'
							,'I1m'
							,'I1r'
							,'I1rr'
							,'I1s'
							,'I1t'
							,'I1v'
							,'I1w'
							,'I1z'
							,'I2a'
							,'I2b'
							,'I2c'
							,'I2d'
							,'I2e'
							,'I2f'
							,'I2g'
							,'I2h'
							,'I2i'
							,'I2k'
							,'I2l'
							,'J1a'
							,'J1b'
							,'J1d'
							,'J1e'
							,'J1g'
							,'J1h'
							,'J1j'
							,'J1k'
							,'J1l'
							,'J1n'
							,'J1o'
							,'K1a'
							,'K1b'
							,'K1d'
							,'K2a'
							,'K2b'
							,'K5a'
							,'K6a'
							,'K6b'
							,'M4a'
							,'M4b'
							,'M4c'
							,'M4d'
							,'M4e'
							,'M4f'
							,'M4g'
							,'M4h'
							,'M5a'
							,'M5b'
							,'M5c'
							,'M5d'
							,'M5e'
							,'M5f'
							,'M5g'
							,'M5h'
							,'M5i'
							,'M5j'
							,'M6a'
							,'M6b'
							,'M6c'
							,'M6d'
							,'M6e'
							,'M6f'
							,'M6g'
							,'O3'
							,'P1aa'
							,'P1ab'
							,'P1ac'
							,'P1ad'
							,'P1ae'
							,'P1af'
							,'P1ag'
							,'P1ah'
							,'P1ai'
							,'P1aj'
							,'P1ak'
							,'P1al'
							,'P1am'
							,'P1an'
							,'P1ao'
							,'P1ap'
							,'P1aq'
							,'P1ar'
							,'P1as'
							,'P1baA'
							,'P1baB'
							,'P1bbA'
							,'P1bbB'
							,'P1bcA'
							,'P1bcB'
							,'P1bdA'
							,'P1bdB'
							,'P1beA'
							,'P1beB'
							,'P3a'
							,'P3b'
							,'P3c'
							,'P3d'
							,'P3e'
							,'P3f'
							,'P3g'
							,'P3h'
							,'P3i'
							,'P3j'
							,'P3k'
							,'P7'
							,'P8'
							,'T1aA'
							,'T1aB'
							,'T1b'
							,'T1c'
							,'T1d'
							,'T2a'
							,'T2b'
							,'T2c'
							,'T2d'
							,'T2e'
							,'T3MDCR'
							)
						)

				UPDATE as_std_question
				SET prov_state_options = 'FL'
				WHERE std_assess_id = 1
					AND section_code = 'S(FL)'
			END

			--==================================================================================================
			--State specific updates: Illinois (IL)
			--==================================================================================================
			IF @State = 'IL'
			BEGIN
				--===========================
				--SET MDS configuration:
				--===========================
				UPDATE as_configuration
				SET cmi_SET_state = 'B01'
					,calc_type_fed = 'Mcare'
					,calc_type_state = 'Index'
				WHERE fac_id = @FacIdDest

				--===========================
				--clear IL FROM prov_state_options column
				--===========================
				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, ',IL', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE '%,IL%'
					AND section_code <> 'U'
					--added Oct 16 as per Joel
					AND section_code <> 'T'

				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, 'IL,', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE '%IL,%'
					AND section_code <> 'U'
					--added Oct 16 as per Joel
					AND section_code <> 'T'

				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, 'IL', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE 'IL'
					AND section_code <> 'U'
					--added Oct 16 as per Joel
					AND section_code <> 'T'

				--============================
				--IL uses full version of quarterly
				--============================
				UPDATE as_std_question
				SET prov_state_options = prov_state_options + ',IL'
				WHERE std_assess_id = 1
					AND status_q = 'S'
					AND section_code <> 'U'
					AND section_code <> 'V'
					--added Oct 16 as per Joel
					AND section_code <> 'T'
					AND section_code NOT LIKE 'S%'

				UPDATE as_std_question
				SET prov_state_options = 'IL'
				WHERE std_assess_id = 1
					AND section_code = 'S(IL)'
					--added Oct 16 as per Joel
					AND section_code <> 'T'
			END

			--================================================================================================
			--State specific updates: Iowa (IA)
			--================================================================================================
			IF @state = 'IA'
			BEGIN
				--=======================
				--SET MDS configuration:
				--=======================
				UPDATE as_configuration
				SET cmi_SET_state = 'B01'
					,calc_type_fed = 'Mcare'
					,calc_type_state = 'Index'
				WHERE fac_id = @FacIdDest
			END

			--===========================================================================================
			--State specific updates: Indiana (IN)
			--===========================================================================================
			IF @State = 'IN'
			BEGIN
				--=========================
				--SET MDS configuration:
				--=========================
				UPDATE as_configuration
				SET cmi_SET_state = 'B01'
					,calc_type_fed = 'Mcare'
					,calc_type_state = 'Index'
				WHERE fac_id = @FacIdDest

				--=========================
				-- Additional Other/other UPDATE: getting rejected because of ampersANDs in p_rec_dt
				--=========================
				UPDATE as_std_question
				SET status_oo = 'A'
				WHERE std_assess_id = 1
					AND question_key = 'P_REC_DT'
			END

			--===========================================================================================
			--State specific updates: Kansas (KS)
			--===========================================================================================
			IF @State = 'KS'
			BEGIN
				--===================================
				--SET MDS configuration:
				--===================================
				UPDATE as_configuration
				SET cmi_SET_state = 'B01'
					,calc_type_fed = 'Mcare'
					,calc_type_state = 'Index'
				WHERE fac_id = @FacIdDest
			END

			--========================================================================================================
			--State specific updates: Kentucky (KY)
			--========================================================================================================
			IF @State = 'KY'
			BEGIN
				--=======================================
				--clear KY FROM prov_state_options column
				--=======================================
				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, ',KY', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE '%,KY%'
					--added Oct 16 as per Joel
					AND section_code <> 'T'

				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, 'KY,', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE '%KY,%'
					--added Oct 16 as per Joel
					AND section_code <> 'T'

				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, 'KY', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE 'KY'
					--added Oct 16 as per Joel
					AND section_code <> 'T'

				--=======================================
				--KY uses RUG III 97 version of quarterly
				--=======================================
				UPDATE as_std_question
				SET prov_state_options = prov_state_options + ',KY'
				WHERE std_assess_id = 1
					AND (
						question_key IN (
							'B3a'
							,'B3b'
							,'B3c'
							,'B3d'
							,'B3e'
							,'G1aB'
							,'G1bB'
							,'G1cB'
							,'G1dB'
							,'G1eB'
							,'G1fB'
							,'G1gB'
							,'G1hB'
							,'G1iB'
							,'G1jB'
							,'G3a'
							,'G3b'
							,'G7'
							,'H2c'
							,'I1a'
							,'I1ee'
							,'I1ff'
							,'I1m'
							,'I1r'
							,'I1rr'
							,'I1s'
							,'I1t'
							,'I1v'
							,'I1w'
							,'I1z'
							,'I2a'
							,'I2b'
							,'I2c'
							,'I2d'
							,'I2e'
							,'I2f'
							,'I2g'
							,'I2h'
							,'I2i'
							,'I2k'
							,'I2l'
							,'J1a'
							,'J1b'
							,'J1d'
							,'J1e'
							,'J1g'
							,'J1h'
							,'J1j'
							,'J1k'
							,'J1l'
							,'J1n'
							,'J1o'
							,'K1a'
							,'K1b'
							,'K1d'
							,'K2a'
							,'K2b'
							,'K5a'
							,'K6a'
							,'K6b'
							,'M4a'
							,'M4b'
							,'M4c'
							,'M4d'
							,'M4e'
							,'M4f'
							,'M4g'
							,'M4h'
							,'M5a'
							,'M5b'
							,'M5c'
							,'M5d'
							,'M5e'
							,'M5f'
							,'M5g'
							,'M5h'
							,'M5i'
							,'M5j'
							,'M6a'
							,'M6b'
							,'M6c'
							,'M6d'
							,'M6e'
							,'M6f'
							,'M6g'
							,'O3'
							,'P1aa'
							,'P1ab'
							,'P1ac'
							,'P1ad'
							,'P1ae'
							,'P1af'
							,'P1ag'
							,'P1ah'
							,'P1ai'
							,'P1aj'
							,'P1ak'
							,'P1al'
							,'P1am'
							,'P1an'
							,'P1ao'
							,'P1ap'
							,'P1aq'
							,'P1ar'
							,'P1as'
							,'P1baA'
							,'P1baB'
							,'P1bbA'
							,'P1bbB'
							,'P1bcA'
							,'P1bcB'
							,'P1bdA'
							,'P1bdB'
							,'P1beA'
							,'P1beB'
							,'P3a'
							,'P3b'
							,'P3c'
							,'P3d'
							,'P3e'
							,'P3f'
							,'P3g'
							,'P3h'
							,'P3i'
							,'P3j'
							,'P3k'
							,'P7'
							,'P8'
							)
						)
					--added Oct 16 as per Joel
					AND section_code <> 'T'

				UPDATE as_std_question
				SET prov_state_options = 'KY'
				WHERE std_assess_id = 1
					AND section_code = 'S(KY)'
					--added Oct 16 as per Joel
					AND section_code <> 'T'
			END

			--==========================================================================================================
			--State specific updates: Maine(ME)
			--==========================================================================================================
			IF @State = 'ME'
			BEGIN
				--===========================
				--clear ME FROM prov_state_options column
				--===========================
				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, ',ME', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE '%,ME%'
					AND section_code <> 'T'

				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, 'ME,', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE '%ME,%'
					AND section_code <> 'T'

				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, 'ME', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE 'ME'
					AND section_code <> 'T'

				--============================
				--ME uses full version of quarterly
				--============================
				UPDATE as_std_question
				SET prov_state_options = CASE 
						WHEN prov_state_options IS NULL
							THEN 'ME'
						ELSE prov_state_options + ',ME'
						END
				WHERE std_assess_id = 1
					AND status_q = 'S'
					AND section_code <> 'V'
					AND section_code <> 'T'
					AND section_code NOT LIKE 'S%'
			END

			--==========================================================================================================
			--State specific updates: Minnesota (MN)
			--==========================================================================================================
			IF @State = 'MN'
			BEGIN
				--========================
				--SET MDS configuration:
				--SELECT cmi_SET_state,calc_type_fed,calc_type_state,* FROM as_configuration
				--========================
				UPDATE as_configuration
				SET cmi_SET_state = 'MN'
					,calc_type_fed = 'Mcare'
					,calc_type_state = 'Index'
				WHERE fac_id = @FacIdDest

				/* Added this script as per Case#108372 */
				--if @State = 'MN'
				--begin 
				INSERT INTO census_status_code_setup (
					status_code_id
					,fac_id
					,date_range_code
					,created_by
					,created_date
					,revision_by
					,revision_date
					)
				SELECT c.ITEM_ID
					,@facId
					,0
					,'PCC-2771'
					,getdate()
					,'PCC-2771'
					,getdate()
				FROM CENSUS_CODES c
				WHERE c.table_code = 'SC'
					AND (
						deleted = 'N'
						OR deleted IS NULL
						)
					AND c.ITEM_ID NOT IN (
						SELECT status_code_id
						FROM census_status_code_setup
						WHERE fac_id = @facId
						)
					--end
			END

			--==========================================================================================================
			--State specific updates: Nebraska (NE)
			--==========================================================================================================
			IF @State = 'NE'
			BEGIN
				--=============================
				--SET MDS configuration:
				--=============================
				UPDATE as_configuration
				SET cmi_SET_state = ''
					,calc_type_fed = 'Mcare'
					,calc_type_state = 'Hier'
				WHERE fac_id = @FacIdDest
			END

			--==========================================================================================================
			--State specific updates: Ohio (OH)
			--==========================================================================================================
			IF @State = 'OH'
			BEGIN
				--==========================
				--SET MDS configuration:
				--==========================
				UPDATE as_configuration
				SET cmi_SET_state = 'OHIO'
					,calc_type_fed = 'Mcare'
					,calc_type_state = 'Hier'
				WHERE fac_id = @FacIdDest
			END

			--==========================================================================================================
			--State specific updates: Virginia (VA)
			--==========================================================================================================
			IF @State = 'VA'
			BEGIN
				--========================================
				--clear VA FROM prov_state_options column
				--========================================
				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, ',VA', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE '%,VA%'
					--added Oct 16 as per Joel
					AND section_code <> 'T'

				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, 'VA,', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE '%VA,%'
					--added Oct 16 as per Joel
					AND section_code <> 'T'

				UPDATE as_std_question
				SET prov_state_options = REPLACE(prov_state_options, 'VA', '')
				WHERE std_assess_id = 1
					AND prov_state_options LIKE 'VA'
					--added Oct 16 as per Joel
					AND section_code <> 'T'

				--========================================
				--VA uses RUG III 97 version of quarterly
				--========================================
				UPDATE as_std_question
				SET prov_state_options = prov_state_options + ',VA'
				WHERE std_assess_id = 1
					AND (
						question_key IN (
							'B3a'
							,'B3b'
							,'B3c'
							,'B3d'
							,'B3e'
							,'G1aB'
							,'G1bB'
							,'G1cB'
							,'G1dB'
							,'G1eB'
							,'G1fB'
							,'G1gB'
							,'G1hB'
							,'G1iB'
							,'G1jB'
							,'G3a'
							,'G3b'
							,'G7'
							,'H2c'
							,'I1a'
							,'I1ee'
							,'I1ff'
							,'I1m'
							,'I1r'
							,'I1rr'
							,'I1s'
							,'I1t'
							,'I1v'
							,'I1w'
							,'I1z'
							,'I2a'
							,'I2b'
							,'I2c'
							,'I2d'
							,'I2e'
							,'I2f'
							,'I2g'
							,'I2h'
							,'I2i'
							,'I2k'
							,'I2l'
							,'J1a'
							,'J1b'
							,'J1d'
							,'J1e'
							,'J1g'
							,'J1h'
							,'J1j'
							,'J1k'
							,'J1l'
							,'J1n'
							,'J1o'
							,'K1a'
							,'K1b'
							,'K1d'
							,'K2a'
							,'K2b'
							,'K5a'
							,'K6a'
							,'K6b'
							,'M4a'
							,'M4b'
							,'M4c'
							,'M4d'
							,'M4e'
							,'M4f'
							,'M4g'
							,'M4h'
							,'M5a'
							,'M5b'
							,'M5c'
							,'M5d'
							,'M5e'
							,'M5f'
							,'M5g'
							,'M5h'
							,'M5i'
							,'M5j'
							,'M6a'
							,'M6b'
							,'M6c'
							,'M6d'
							,'M6e'
							,'M6f'
							,'M6g'
							,'O3'
							,'P1aa'
							,'P1ab'
							,'P1ac'
							,'P1ad'
							,'P1ae'
							,'P1af'
							,'P1ag'
							,'P1ah'
							,'P1ai'
							,'P1aj'
							,'P1ak'
							,'P1al'
							,'P1am'
							,'P1an'
							,'P1ao'
							,'P1ap'
							,'P1aq'
							,'P1ar'
							,'P1as'
							,'P1baA'
							,'P1baB'
							,'P1bbA'
							,'P1bbB'
							,'P1bcA'
							,'P1bcB'
							,'P1bdA'
							,'P1bdB'
							,'P1beA'
							,'P1beB'
							,'P3a'
							,'P3b'
							,'P3c'
							,'P3d'
							,'P3e'
							,'P3f'
							,'P3g'
							,'P3h'
							,'P3i'
							,'P3j'
							,'P3k'
							,'P7'
							,'P8'
							,'T1aA'
							,'T1aB'
							,'T1b'
							,'T1c'
							,'T1d'
							,'T2a'
							,'T2b'
							,'T2c'
							,'T2d'
							,'T2e'
							,'T3MDCR'
							,'T3STATE'
							)
						)
					--added Oct 16 as per Joel
					AND section_code <> 'T'

				UPDATE as_std_question
				SET prov_state_options = 'VA'
				WHERE std_assess_id = 1
					AND section_code = 'S(VA)'
					--added Oct 16 as per Joel
					AND section_code <> 'T'
			END

			--=======================================
			--added due to the issue in case830770 - orphan data in configuration_parameter
			DELETE
			FROM configuration_parameter
			WHERE fac_id NOT IN (
					SELECT fac_id
					FROM facility
					WHERE fac_id <> @FacIdDest
					)
				AND fac_id NOT IN (
					1
					,- 1
					,9001
					)

			------------------------------------------
			SET @FacExist = 0

			SELECT @facexist = fac_id
			FROM configuration_parameter
			WHERE fac_id = @FacIdDest

			DECLARE @sql_cmd VARCHAR(max)
			DECLARE @ALF_template_db VARCHAR(50)

			IF @Facexist = 0
			BEGIN
				IF @FacIdDest = 1
				BEGIN
					INSERT INTO configuration_parameter (
						fac_id
						,[name]
						,value
						)
					SELECT @FacIdDest
						,[name]
						,value
					FROM configuration_parameter
					WHERE fac_id = @SourceFac
						AND NAME NOT LIKE '%closed%' --Added by Rina on  02/02/2010 -- As per Kevin's  suggestion
						AND NAME NOT IN (
							SELECT NAME
							FROM configuration_parameter
							WHERE (
									NAME IN (
										'enable_poc'
										,'show_poc_security'
										,'turn_on_poc'
										)
									OR (NAME LIKE 'poc%')
									)
							) --ADDED 7/22/2010
						AND NAME NOT IN (
							SELECT NAME
							FROM configuration_parameter
							WHERE fac_id = @destination_fac_id
							)
						AND NAME NOT IN (
							'enable_emar'
							,'enable_mar'
							) -- Added by Rina  8/20/2010
				END
				ELSE
				BEGIN
					IF @healthtype = 'ALF' --Added by Bipin Maliakal as per Ann's suggestion on 12/02/2014
					BEGIN
						SET @ALF_template_db = 'train_us_alftmplt'
						SET @sql_cmd = '
						INSERT INTO configuration_parameter (fac_id,[name],value)
						SELECT ' + convert(VARCHAR(10), @FacIdDest) + ' ,[name],value 
						FROM [' + @template_server + '].' + @ALF_template_db + '.dbo.configuration_parameter
						WHERE fac_id = 1
						AND name not like ''%closed%''
						and name not in (select name from dbo.configuration_parameter where fac_id=' + convert(VARCHAR(10), @FacIdDest) + ')
						AND name not in (''enable_emar'',''enable_mar'',''enable_poc'',''show_poc_security'',''turn_on_poc'',''enable_cs_default_quick_link_icon'',''enable_cs_quick_link'',''enable_cs_quick_link_icon_desc'',''enable_cs_quick_link_url'') 
						AND name not like ''poc%''' -- added by Ryan - as per case 480948 / issue 16729 - 07/14/2015

						EXEC (@sql_cmd)
					END
					ELSE
					BEGIN
						SET @sql_cmd = '
						INSERT INTO configuration_parameter (fac_id,[name],value)
						SELECT ' + convert(VARCHAR(10), @FacIdDest) + ' ,[name],value 
						FROM [' + @template_server + '].' + @template_db + '.dbo.configuration_parameter
						WHERE fac_id = 1
						AND name not like ''%closed%''
						and name not in (select name from dbo.configuration_parameter where fac_id=' + convert(VARCHAR(10), @FacIdDest) + ')
						AND name not in (''enable_emar'',''enable_mar'',''enable_poc'',''show_poc_security'',''turn_on_poc'',''enable_cs_default_quick_link_icon'',''enable_cs_quick_link'',''enable_cs_quick_link_icon_desc'',''enable_cs_quick_link_url'')
						AND name not like ''poc%''' -- added by Ryan - as per case 480948 / issue 16729 - 07/14/2015

						EXEC (@sql_cmd)
					END
				END
			END

			BEGIN
				INSERT INTO sec_user_facility
				SELECT b.userid
					,a.fac_id
					,1
				FROM facility a
					,sec_user b
				WHERE b.admin_user_type = 'E'
					AND a.fac_id NOT IN (
						SELECT facility_id
						FROM sec_user_facility
						WHERE userid = b.userid
						)
			END

			/* Update the address info in the facility */
			UPDATE [dbo].facility
			SET address1 = @add1
				,address2 = @add2
				,city = @city
				,pc = @pc
				,tel = @tel
			WHERE fac_id = @FacIdDest

			--added for CM15943
			--=======================================
			SET @FacExist = 0

			SELECT @facexist = fac_id
			FROM crm_field_config
			WHERE fac_id = @FacIdDest

			IF @Facexist = 0
			BEGIN
				DECLARE @rowcnt INT
					,@NID INT

				SELECT identity(INT, 1, 1) AS field_id
					,field_name
					,field_label
					,field_type
					,func_id
					,mandatory
				INTO #t_crm_field_config
				FROM crm_field_config
				WHERE fac_id = @SourceFac

				SET @rowcnt = @@rowcount

				--UPDATE #t_crm_field_config
				--SET	field_id = field_id - 1
				----PRINT @rowcnt
				IF @rowcnt > 0
				BEGIN
					SET @NID = NULL

					DELETE
					FROM pcc_global_primary_key
					WHERE table_name = 'crm_field_config'
						AND key_column_name = 'field_id';

					SELECT @NID = coalesce(max(field_id), 0)
					FROM dbo.crm_field_config WITH (NOLOCK)

					----EXECUTE get_next_primary_key 'crm_field_config'
					----	,'field_id'
					----	,@NID OUTPUT
					----	,@rowcnt
					----PRINT @NID
					INSERT INTO crm_field_config
					SELECT @NID + field_id
						,@CreatedBy
						,getdate()
						,@CreatedBy
						,getdate()
						,field_name
						,field_label
						,field_type
						,@FacIdDest
						,func_id
						,mandatory
					FROM #t_crm_field_config
				END

				DROP TABLE #t_crm_field_config
			END

			/* As per Jayne, Use Medi-Span Library should be Yes, Check_duplicates and Always Show Generics should be checked
   This is in Physician Order Configuration - Superuser */
			INSERT INTO configuration_parameter
			SELECT @FacIdDest
				,'enable_ext_lib'
				,'Y'
			WHERE NOT EXISTS (
					SELECT 1
					FROM configuration_parameter c
					WHERE c.fac_id = @FacIdDest
						AND c.NAME = 'enable_ext_lib'
					)

			INSERT INTO configuration_parameter
			SELECT @FacIdDest
				,'check_duplicates'
				,'Y'
			WHERE NOT EXISTS (
					SELECT 1
					FROM configuration_parameter c
					WHERE c.fac_id = @FacIdDest
						AND c.NAME = 'check_duplicates'
					)

			INSERT INTO configuration_parameter
			SELECT @FacIdDest
				,'show_generics'
				,'Y'
			WHERE NOT EXISTS (
					SELECT 1
					FROM configuration_parameter c
					WHERE c.fac_id = @FacIdDest
						AND c.NAME = 'show_generics'
					)

			UPDATE configuration_parameter
			SET value = 'Y'
			--select * 
			FROM configuration_parameter
			WHERE NAME IN (
					'enable_ext_lib'
					,'check_duplicates'
					,'show_generics'
					)
				AND fac_id = @FacIdDest

			SET @FacExist = 0

			SELECT @facexist = fac_id
			FROM as_submission_accounts_mds_30
			WHERE fac_id = @FacIdDest

			IF @Facexist = 0
			BEGIN
				SELECT identity(INT, 1, 1) AS row
					,@FacIdDest AS fac_id
					,0 AS [status]
					,test_status
					,cms_account_name
					,cms_account_description
					,cms_url
					,account_type
				INTO #t_as_submission_accounts_mds_30
				FROM as_submission_accounts_mds_30
				WHERE fac_id = @SourceFac

				SET @rowcnt = @@rowcount

				IF @rowcnt > 0
				BEGIN
					SET @NID = NULL

					DELETE
					FROM pcc_global_primary_key
					WHERE table_name = 'as_submission_accounts_mds_30'
						AND key_column_name = 'account_id';

					SELECT @NID = coalesce(max(account_id), 0)
					FROM dbo.as_submission_accounts_mds_30 WITH (NOLOCK)

					----EXECUTE get_next_primary_key 'as_submission_accounts_mds_30'
					----	,'account_id'
					----	,@NID OUTPUT
					----	,@rowcnt
					----PRINT @NID
					INSERT INTO as_submission_accounts_mds_30 (
						account_id
						,fac_id
						,STATUS
						,test_status
						,cms_account_name
						,cms_account_description
						,cms_url
						,revision_by
						,revision_date
						,account_type
						)
					SELECT @NID + [row]
						,fac_id
						,[status]
						,test_status
						,cms_account_name
						,cms_account_description
						,cms_url
						,@CreatedBy
						,getdate()
						,account_type
					FROM #t_as_submission_accounts_mds_30
				END

				DROP TABLE #t_as_submission_accounts_mds_30
			END

			/*
Insert the facility template related to W&V Thresholds 
*/
			DECLARE @max_id INT
				,@return_value INT
				,@col_name VARCHAR(100)
				,@tmp_table_sql NVARCHAR(max)
				,@insert_table_sql NVARCHAR(max)
				,@table_columns NVARCHAR(max) = '';

			SET @facexist = 0

			SELECT @facexist = fac_id
			FROM wv_std_vitals_thresholds
			WHERE fac_id = @FacIdDest;

			IF @facexist = 0
			BEGIN
				UPDATE pcc_global_primary_key
				SET next_key = (
						SELECT max(threshold_id) + 1
						FROM wv_std_vitals_thresholds
						)
				WHERE table_name = 'wv_std_vitals_thresholds';

				-- determine all columns to include	
				DECLARE col_cursor CURSOR FAST_FORWARD
				FOR
				SELECT column_name
				FROM INFORMATION_SCHEMA.COLUMNS WITH (NOLOCK)
				WHERE TABLE_NAME = 'wv_std_vitals_thresholds'
					AND column_name NOT IN (
						'threshold_id'
						,'fac_id'
						,'created_by'
						,'created_date'
						,'revision_by'
						,'revision_date'
						,'fac_id'
						)
				ORDER BY ORDINAL_POSITION;

				OPEN col_cursor

				FETCH NEXT
				FROM col_cursor
				INTO @col_name

				WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @table_columns = @table_columns + ',' + @col_name;

					FETCH NEXT
					FROM col_cursor
					INTO @col_name
				END

				CLOSE col_cursor

				DEALLOCATE col_cursor

				-- Create temp table based on the template facility (fac_id=1)
				SELECT TOP 1 *
				INTO #wv_std_vitals_thresholds
				FROM wv_std_vitals_thresholds wv;--initialize

				SET @tmp_table_sql = 'truncate table #wv_std_vitals_thresholds;
		INSERT INTO #wv_std_vitals_thresholds 
			SELECT 
			ROW_NUMBER() OVER(ORDER BY threshold_id ASC) AS threshold_id
			,@FacIdDest AS fac_id
			,''wescom'' AS created_by
			,getdate() AS created_date
			,''wescom'' AS revision_by
			,getdate() AS revision_date
			' + @table_columns + '			
			FROM wv_std_vitals_thresholds wv
			WHERE wv.client_id IS NULL AND wv.fac_id = @SourceFac';

				EXECUTE sp_executesql @tmp_table_sql
					,N'@FacIdDest int, @SourceFac int'
					,@FacIdDest = @FacIdDest
					,@SourceFac = @SourceFac;

				-- select * from #wv_std_vitals_thresholds;
				SET @Rowcount = @@rowcount

				SELECT @Rowcount = 0
				WHERE @Rowcount IS NULL

				IF @Rowcount > 0
				BEGIN
					SET @Rowcount = @Rowcount + 1;
					SET @max_id = NULL

					DELETE
					FROM pcc_global_primary_key
					WHERE table_name = 'wv_std_vitals_thresholds'
						AND key_column_name = 'threshold_id';

					SELECT @max_id = coalesce(max(threshold_id), 0)
					FROM dbo.wv_std_vitals_thresholds WITH (NOLOCK)

					----EXEC @return_value = get_next_primary_key 'wv_std_vitals_thresholds'
					----	,'threshold_id'
					----	,@max_id OUTPUT
					----	,@Rowcount;
					-- Copy template into new facility
					SET @insert_table_sql = '
				INSERT INTO wv_std_vitals_thresholds (
					threshold_id
					,fac_id
					,created_by
					,created_date
					,revision_by
					,revision_date
					' + @table_columns + '
					)
				SELECT threshold_id + @max_id 
					,fac_id
					,created_by
					,created_date
					,revision_by
					,revision_date
					' + @table_columns + '
					FROM #wv_std_vitals_thresholds
				';

					-- print @insert_table_sql;
					EXECUTE sp_executesql @insert_table_sql
						,N'@max_id int'
						,@max_id;
				END

				DROP TABLE #wv_std_vitals_thresholds;
			END
			ELSE
			BEGIN
				PRINT 'Facility has already been configured for weights and vitals thresholds.';
			END

			--update general_config set country_id = 100  where fac_id = 1
			--
			--update ar_configuration set term_client = 'Resident',show_cash_receipt_type_summary = 'Y',ub_facility_type = '2',aging_bucket_count = '24',medicare_no_pay_flag = 'Y',
			--                        anc_post_date_flag = 'N', adj_post_date_flag = 'N',cash_receipt_comment_flag = 'Y',batch_report_comment_flag = 'Y',
			--                        allow_future_census_flag = 'Y',days_before_closing_month = 0
			-- where fac_id = 1
			------ Added  from  IRM  Activation Script 6/18/2010
			--PCC-349: 				Script to populate IRM Configuration table
			--
			--Written By:			Jaymee Aquino
			--Reviewed By:
			--
			--Script Type:			DML
			--Target DB Type: 		CLIENT
			--Target Environment:	US
			--Date: Jan 12, 2009
			--
			--Re-Runable: YES
			--
			--Description of Script Function:
			-- ADD a row in 'crm_configuration' table for each row in 'facility' table
			--
			--Special Instruction:
			-- NONE
			--------------------------------------------------------------------------------------
			IF EXISTS (
					SELECT table_name
					FROM information_schema.tables
					WHERE table_name = 'crm_configuration'
						AND table_schema = 'dbo'
					)
			BEGIN
				INSERT INTO crm_configuration (
					fac_id
					,created_by
					,created_date
					,revision_by
					,revision_date
					,fax_server_name
					,smtp_server_name
					,term_inquiry
					,term_marketing
					,fax_server_dial_prefix
					,term_client
					,inquiry_created_in
					,max_episode_list
					,term_careline
					,all_ecin_referrals
					,ecin_assign_to_id
					,all_curaspan_referrals
					,curaspan_assign_to_id
					,statement_header_image_id
					,statement_footer_image_id
					,signature_image_id
					,waiting_list_threshold
					,intake_process_flag
					,create_qadt_flag
					)
				SELECT fac.fac_id
					,'wescom'
					,getdate()
					,'wescom'
					,getdate()
					,NULL
					,NULL
					,''
					,'IRM'
					,NULL
					,NULL
					,NULL
					,NULL
					,''
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,7
					,'C'
					,'Y'
				FROM facility fac
				LEFT JOIN crm_configuration config ON fac.fac_id = config.fac_id
				WHERE isnull(fac.deleted, 'N') = 'N'
					AND config.fac_id IS NULL

				-------Added by  Ann  AS per  Fran
				IF NOT EXISTS (
						SELECT 1
						FROM CLIENTS
						)
					AND (
						SELECT count(1)
						FROM facility
						WHERE deleted = 'N'
							AND fac_id <> 9001
						) > 1
				BEGIN
					SET @sql_cmd = '
		IF  NOT EXISTS (select 1 From ar_accounts a left join [' + @template_server + '].' + @template_db + '.dbo.ar_accounts b on a.account_id = b.account_id  and a.fac_id = b.fac_id and a.created_by = b.created_by and a.created_date = b.created_date and a.revision_by = b.revision_by and a.revision_date = b.revision_date where b.account_id is null 
		union 
		select 1 From ar_payers a left join [' + @template_server + '].' + @template_db + '.dbo.ar_payers b on a.payer_id = b.payer_id  and a.fac_id = b.fac_id and a.created_by = b.created_by and a.created_date = b.created_date and a.revision_by = b.revision_by and a.revision_date = b.revision_date where b.payer_id is null
		union 
		select 1 From ar_item_types a left join [' + @template_server + '].' + @template_db + 
						'.dbo.ar_item_types b on a.item_type_id = b.item_type_id  and a.fac_id = b.fac_id and a.created_by = b.created_by and a.created_date = b.created_date and a.revision_by = b.revision_by and a.revision_date = b.revision_date where b.item_type_id is null 
		union
		select 1 From ar_item_date_range a left join [' + @template_server + '].' + @template_db + '.dbo.ar_item_date_range b on a.item_type_id = b.item_type_id and a.fac_id = b.fac_id and a.effective_date = b.effective_date and isnull(a.amount,0) = isnull(b.amount,0) where b.item_type_id is null 
		union
		select 1 From ar_date_range a left join [' + @template_server + '].' + @template_db + 
						'.dbo.ar_date_range b on a.eff_date_range_id = b.eff_date_range_id  and a.payer_id = b.payer_id and a.fac_id = b.fac_id and a.created_by = b.created_by and a.created_date = b.created_date and a.revision_by = b.revision_by and a.revision_date = b.revision_date where b.eff_date_range_id is null 
		)
		BEGIN

		IF OBJECT_ID(N''pcc_temp_storage.._bkp_ar_payers_' + @Creator + ''', N''U'') IS NOT NULL 
			DROP TABLE pcc_temp_storage.dbo._bkp_ar_payers_' + @Creator + '
		IF OBJECT_ID(N''pcc_temp_storage.._bkp_ar_item_types_' + @Creator + ''', N''U'') IS NOT NULL 
			DROP TABLE pcc_temp_storage.dbo._bkp_ar_item_types_' + @Creator + '
		IF OBJECT_ID(N''pcc_temp_storage.._bkp_ar_item_date_range_' + @Creator + ''', N''U'') IS NOT NULL 
			DROP TABLE pcc_temp_storage.dbo._bkp_ar_item_date_range_' + @Creator + '
		IF OBJECT_ID(N''pcc_temp_storage.._bkp_ar_eff_rate_schedule_' + @Creator + ''', N''U'') IS NOT NULL 
			DROP TABLE pcc_temp_storage.dbo._bkp_ar_eff_rate_schedule_' + @Creator + 
						'
		IF OBJECT_ID(N''pcc_temp_storage.._bkp_ar_rate_detail_' + @Creator + ''', N''U'') IS NOT NULL 
			DROP TABLE pcc_temp_storage.dbo._bkp_ar_rate_detail_' + @Creator + '


		SELECT * INTO pcc_temp_storage.dbo._bkp_ar_payers_' + @Creator + ' FROM ar_payers where fac_id=1
		SELECT * INTO pcc_temp_storage.dbo._bkp_ar_item_types_' + @Creator + ' FROM ar_item_types where fac_id=1
		SELECT * INTO pcc_temp_storage.dbo._bkp_ar_item_date_range_' + @Creator + ' FROM ar_item_date_range where fac_id=1
		SELECT * INTO pcc_temp_storage.dbo._bkp_ar_eff_rate_schedule_' + @Creator + ' FROM ar_eff_rate_schedule where fac_id=1
		SELECT * INTO pcc_temp_storage.dbo._bkp_ar_rate_detail_' + @Creator + 
						' FROM ar_rate_detail where fac_id=1

		delete ar_payers where fac_id=1
		delete  ar_item_types where fac_id=1
		delete  ar_item_date_range where fac_id=1
		delete  ar_eff_rate_schedule where fac_id=1
		delete  ar_rate_detail where fac_id=1
		update ar_accounts set deleted=''Y'', deleted_date=getdate(),deleted_by=''' + @Creator + ''' where fac_id=1 and deleted=''N''
		update  ar_date_range set deleted=''Y'', deleted_date=getdate(),deleted_by=''' + @Creator + ''' where  fac_id=1 and deleted=''N''
		END
		'

					--	print @sql_cmd
					EXEC (@sql_cmd)
				END
			END

			INSERT INTO as_std_assessment_facility
			SELECT @FacIdDest
				,std_assess_id
			FROM as_std_assessment
			WHERE (
					(
						fac_id = - 1
						AND reg_id IS NULL
						AND state_code IS NULL
						)
					OR (
						fac_id = @FacIdDest
						AND reg_id IS NULL
						AND state_code IS NULL
						)
					OR state_code IN (
						SELECT prov
						FROM facility
						WHERE fac_id = @FacIdDest
						)
					OR (
						reg_id IN (
							SELECT regional_id
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						AND state_code IN (
							SELECT prov
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						)
					OR (
						reg_id IN (
							SELECT regional_id
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						AND state_code IS NULL
						)
					)
				AND NOT EXISTS (
					SELECT 1
					FROM as_std_assessment_facility
					WHERE fac_id = @FacIdDest
						AND std_assess_id = as_std_assessment.std_assess_id
					)
				AND brand_id IS NULL -- Filter added for COMS uda's
				AND std_assess_id NOT IN (
					SELECT std_assess_id
					FROM as_std_assessment_system_assessment_mapping
					WHERE system_type_id IN (
							1
							,100
							)
					) -- Filter added for eInteract uda's
				AND [status] NOT IN ('I') -- Added BY: Jaspreet Singh, Date: 2018-05-10, Reason: Smartsheet DShelper&OtherDevelopment task# 149

			INSERT INTO pho_std_order_fac
			SELECT std_order_id
				,@FacIdDest
			FROM pho_std_order
			WHERE (
					(
						fac_id = - 1
						AND isnull(reg_id, - 1) = - 1
						AND state_code IS NULL
						)
					OR (
						fac_id = @FacIdDest
						AND isnull(reg_id, - 1) = - 1
						AND state_code IS NULL
						)
					OR state_code IN (
						SELECT prov
						FROM facility
						WHERE fac_id = @FacIdDest
						)
					OR (
						reg_id IN (
							SELECT regional_id
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						AND state_code IN (
							SELECT prov
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						)
					OR (
						reg_id IN (
							SELECT regional_id
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						AND state_code IS NULL
						)
					)
				AND NOT EXISTS (
					SELECT 1
					FROM pho_std_order_fac
					WHERE fac_id = @FacIdDest
						AND std_order_id = pho_std_order.std_order_id
					)

			------- added by RYAN - Case 694329 -- 11/24/2015
			INSERT INTO facility_mapping
			SELECT @FacIdDest
				,@netsuiteID
				,@Creator
				,getdate()
				,@Creator
				,getdate()

			-- Added for case 773333 by Celine -- 05/16/2016
			SET @FacExist = 0

			SELECT @FacExist = fac_id
			FROM as_vendor_configuration
			WHERE fac_id = @FacIdDest
				AND vendor_code = 'SWIFT_MDS'

			IF @Facexist = 0
			BEGIN
				DECLARE @vendorId INT

				SET @vendorId = NULL

				DELETE
				FROM pcc_global_primary_key
				WHERE table_name = 'as_vendor_configuration'
					AND key_column_name = 'vendor_id';

				SELECT @vendorId = coalesce(max(vendor_id), 0)
				FROM dbo.as_vendor_configuration WITH (NOLOCK)

				SET @vendorId = @vendorId + 1

				----EXEC @return_value = get_next_primary_key 'as_vendor_configuration'
				----	,'vendor_id'
				----	,@vendorId OUTPUT
				----	,1
				INSERT INTO as_vendor_configuration (
					vendor_id
					,fac_id
					,description
					,url
					,timeout
					,priority
					,deleted
					,vendor_code
					,username
					,password
					,account_description
					,STATUS
					,std_assess_id
					,messaging_protocol
					,vendor_type
					)
				VALUES (
					@vendorId
					,@FacIdDest
					,'PCC Skin & Wound MDS'
					,'https://api.swiftmedical.io/pcc'
					,60000
					,1
					,'N'
					,'SWIFT_MDS'
					,'api@pointclickcare.com'
					,'hYUhBlwwFl_UDQPVf4mOEw'
					,'PCC Skin & Wound MDS'
					,'I'
					,11
					,'REST'
					,'SKIN_WOUND'
					)
			END

			--added on June 15, 2016
			IF @healthtype = 'HHC'
			BEGIN
				UPDATE api_authorization
				SET enabled = 'Y'
					,revision_by = @Creator
					,revision_date = getdate()
				WHERE partner_name = 'homehealth'
					AND enabled <> 'Y'
			END

			--added on Oct 13,2016 as per Carmen Gligor and Shaojing Pan
			UPDATE a
			SET value = (
					CASE 
						WHEN f.country_id = 100
							THEN 'Y'
						ELSE 'N'
						END
					)
			FROM configuration_parameter a
			INNER JOIN facility f ON a.fac_id = f.fac_id
			WHERE a.NAME = 'diagnosis_sheet'
				AND a.fac_id = @FacIdDest
				AND value <> (
					CASE 
						WHEN f.country_id = 100
							THEN 'Y'
						ELSE 'N'
						END
					)

			INSERT INTO configuration_parameter (
				fac_id
				,NAME
				,value
				)
			SELECT fac.fac_id
				,'diagnosis_sheet'
				,CASE fac.country_id
					WHEN 100
						THEN 'Y'
					ELSE 'N'
					END
			FROM facility fac
			LEFT JOIN configuration_parameter conf ON fac.fac_id = conf.fac_id
				AND conf.NAME = 'diagnosis_sheet'
			WHERE deleted = 'N'
				AND conf.fac_id IS NULL

			--end added on Oct 13,2016
			--------added on June 8, 2017
			SET @sql_cmd = 'insert into common_code_activation
select item_id, ' + convert(VARCHAR(10), @FacIdDest) + ' from common_code where item_code in
(select b.item_code
from  [' + @template_server + '].' + @template_db + '.dbo.common_code_activation a inner join  [' + @template_server + '].' + @template_db + '.dbo.common_code b
on a.item_id = b.item_id)
and deleted = ''N''
and ((fac_id = -1 and isnull(reg_id,-1) = -1 and state_code is NULL)
or (fac_id = ' + convert(VARCHAR(10), @FacIdDest) + ' and isnull(reg_id,-1) = -1 and state_code is NULL)
or state_code in (select prov from facility where fac_id = ' + convert(VARCHAR(10), @FacIdDest) + ')
or (reg_id in (select regional_id from facility where fac_id = ' + convert(VARCHAR(10), @FacIdDest) + ') and state_code in (select prov from facility where fac_id = ' + convert(VARCHAR(10), @FacIdDest) + '))
or (reg_id in (select regional_id from facility where fac_id = ' + convert(VARCHAR(10), @FacIdDest) + 
				') and state_code is NULL)
)
AND NOT EXISTS (SELECT 1 FROM common_code_activation cca
                        WHERE fac_id = ' + convert(VARCHAR(10), @FacIdDest) + '
                        AND cca.item_id = common_code.item_id)'

			EXEC (@sql_cmd)

			INSERT INTO id_type_activation
			SELECT id_type_id
				,@FacIdDest
			FROM id_type
			WHERE deleted = 'N'
				AND (
					(
						fac_id = - 1
						AND isnull(reg_id, - 1) = - 1
						AND state_code IS NULL
						)
					OR (
						fac_id = @FacIdDest
						AND isnull(reg_id, - 1) = - 1
						AND state_code IS NULL
						)
					OR state_code IN (
						SELECT prov
						FROM facility
						WHERE fac_id = @FacIdDest
						)
					OR (
						reg_id IN (
							SELECT regional_id
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						AND state_code IN (
							SELECT prov
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						)
					OR (
						reg_id IN (
							SELECT regional_id
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						AND state_code IS NULL
						)
					)
				AND NOT EXISTS (
					SELECT 1
					FROM id_type_activation cca
					WHERE fac_id = @FacIdDest
						AND cca.id_type_id = id_type.id_type_id
					)

			INSERT INTO pn_type_activation
			SELECT pn_type_id
				,@FacIdDest
			FROM pn_type
			WHERE deleted = 'N'
				AND (
					retired IS NULL
					OR retired = 'N'
					) -- added by RYAN - 03302021
				AND brand_id IS NULL
				AND (
					(
						fac_id = - 1
						AND isnull(reg_id, - 1) = - 1
						AND state_code IS NULL
						)
					OR (
						fac_id = @FacIdDest
						AND isnull(reg_id, - 1) = - 1
						AND state_code IS NULL
						)
					OR state_code IN (
						SELECT prov
						FROM facility
						WHERE fac_id = @FacIdDest
						)
					OR (
						reg_id IN (
							SELECT regional_id
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						AND state_code IN (
							SELECT prov
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						)
					OR (
						reg_id IN (
							SELECT regional_id
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						AND state_code IS NULL
						)
					)
				AND NOT EXISTS (
					SELECT 1
					FROM pn_type_activation cca
					WHERE fac_id = @FacIdDest
						AND cca.pn_type_id = pn_type.pn_type_id
					)

			INSERT INTO cr_std_alert_activation
			SELECT std_alert_id
				,@FacIdDest
			FROM cr_std_alert
			WHERE deleted = 'N'
				AND std_alert_type_id = 1
				AND (
					(
						fac_id = - 1
						AND isnull(reg_id, - 1) = - 1
						AND state_code IS NULL
						)
					OR (
						fac_id = @FacIdDest
						AND isnull(reg_id, - 1) = - 1
						AND state_code IS NULL
						)
					OR state_code IN (
						SELECT prov
						FROM facility
						WHERE fac_id = @FacIdDest
						)
					OR (
						reg_id IN (
							SELECT regional_id
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						AND state_code IN (
							SELECT prov
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						)
					OR (
						reg_id IN (
							SELECT regional_id
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						AND state_code IS NULL
						)
					)
				AND NOT EXISTS (
					SELECT 1
					FROM cr_std_alert_activation cca
					WHERE fac_id = @FacIdDest
						AND cca.std_alert_id = cr_std_alert.std_alert_id
					)

			INSERT INTO cp_kardex_categories_activation
			SELECT category_id
				,@FacIdDest
			FROM cp_kardex_categories
			WHERE deleted = 'N'
				AND (
					(
						fac_id = - 1
						AND isnull(reg_id, - 1) = - 1
						AND state_code IS NULL
						)
					OR (
						fac_id = @FacIdDest
						AND isnull(reg_id, - 1) = - 1
						AND state_code IS NULL
						)
					OR state_code IN (
						SELECT prov
						FROM facility
						WHERE fac_id = @FacIdDest
						)
					OR (
						reg_id IN (
							SELECT regional_id
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						AND state_code IN (
							SELECT prov
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						)
					OR (
						reg_id IN (
							SELECT regional_id
							FROM facility
							WHERE fac_id = @FacIdDest
							)
						AND state_code IS NULL
						)
					)
				AND NOT EXISTS (
					SELECT 1
					FROM cp_kardex_categories_activation cca
					WHERE fac_id = @FacIdDest
						AND cca.category_id = cp_kardex_categories.category_id
					)

			/* this script came from --https://confluence.pointclickcare.com/confluence/pages/viewpageattachments.action?pageId=101189190&metadataLink=true.  It was added on Oct 4, 2017 as per Christine Butcher 
In 3.7.14 we will have these setting visible to super users
Admin > setup > super user area > Facility Settings
*/
			/*
	INSERT INTO ar_facility_enabled_option_item (fac_id, option_item_id, created_by, created_date)
	SELECT f.fac_id, afc.option_item_id, @Creator,getDate()
	FROM ar_facility_configuration_group_option_item afc
	JOIN facility f ON f.deleted = 'N' and f.fac_id = @FacIdDest
	WHERE afc.option_item_id IN (1,2,3,4)
	and not exists (select 1 from ar_facility_enabled_option_item dst
				where dst.fac_id = f.fac_id and dst.option_item_id = afc.option_item_id)

	-- Payer Type council only for UK facility
	INSERT INTO ar_facility_enabled_option_item (fac_id, option_item_id, created_by, created_date)
	SELECT f.fac_id, 12, @Creator,getDate() 
	FROM facility f 
	WHERE f.deleted = 'N' AND f.country_id = 5172 and f.fac_id = @FacIdDest
	and not exists (select 1 from ar_facility_enabled_option_item dst
				where dst.fac_id = f.fac_id and dst.option_item_id = 12)


	-- Payer types and bill form which are not covered by last two insert statement will be only for US facility
	INSERT INTO ar_facility_enabled_option_item (fac_id, option_item_id, created_by, created_date)
	SELECT f.fac_id, afc.option_item_id, @Creator,getDate()
	FROM ar_facility_configuration_group_option_item afc
	JOIN facility f ON f.deleted = 'N' AND f.country_id = 100
	WHERE afc.option_item_id NOT IN (1,2,3,4,12) and f.fac_id = @FacIdDest		
		and not exists (select 1 from ar_facility_enabled_option_item dst
				where dst.fac_id = f.fac_id and dst.option_item_id = afc.option_item_id)
*/
			--=======================================================================================================================
			-- Smartsheet #123 - 01/18/2018 For CORE-9024
			--
			-- Written By:       Dmitry Strelbytsky
			--
			-- Script Type:      DML
			-- Target DB Type:   Client
			-- Target Database:  Both
			--
			-- Re-Runnable:      YES
			--
			-- Staging Recommendations/Warnings: None
			--
			-- Description of Script Function:
			--   Updates ar_facility_enabled_option_item for newly created facilities
			--
			-- Special Instruction: NA
			--
			--=======================================================================================================================
			BEGIN TRY
				BEGIN TRAN

				--  Payer Type private and other, bill form statements for every facility
				INSERT INTO ar_facility_enabled_option_item (
					fac_id
					,option_item_id
					,created_by
					,created_date
					)
				SELECT f.fac_id
					,afc.option_item_id
					,@Creator
					,GETDATE()
				FROM ar_facility_configuration_group_option_item afc WITH (NOLOCK)
				INNER JOIN facility f WITH (NOLOCK) ON f.deleted = 'N'
				WHERE afc.option_item_id IN (
						1
						,2
						,3
						,4
						)
					AND f.fac_id NOT IN (
						SELECT DISTINCT fac_id
						FROM ar_facility_enabled_option_item WITH (NOLOCK)
						WHERE option_item_id IN (
								1
								,2
								,3
								,4
								)
						)

				-- Payer Type council only for UK facilities
				INSERT INTO ar_facility_enabled_option_item (
					fac_id
					,option_item_id
					,created_by
					,created_date
					)
				SELECT DISTINCT f.fac_id
					,12
					,@Creator
					,GETDATE()
				FROM facility f WITH (NOLOCK)
				WHERE f.deleted = 'N'
					AND f.country_id = 5172
					AND f.fac_id NOT IN (
						SELECT DISTINCT fac_id
						FROM ar_facility_enabled_option_item WITH (NOLOCK)
						WHERE option_item_id = 12
						)

				-- Payer types and bill form which are not covered by last two insert statement will be only for US facilities
				-- in addition to the above CORE, SNF facilities will get Medicare, Medicaid, Managed Care, and UBs
				INSERT INTO ar_facility_enabled_option_item (
					fac_id
					,option_item_id
					,created_by
					,created_date
					)
				SELECT DISTINCT f.fac_id
					,afc.option_item_id
					,@Creator
					,GETDATE()
				FROM ar_facility_configuration_group_option_item afc WITH (NOLOCK)
				INNER JOIN facility f WITH (NOLOCK) ON f.deleted = 'N'
					AND f.country_id = 100
				WHERE f.health_type = 'SNF'
					AND afc.option_item_id NOT IN (
						1
						,2
						,3
						,4
						,12
						)
					AND f.fac_id NOT IN (
						SELECT DISTINCT fac_id
						FROM ar_facility_enabled_option_item WITH (NOLOCK)
						WHERE option_item_id NOT IN (
								1
								,2
								,3
								,4
								,12
								)
						)

				-- in addition to the above CORE, ALF facilities will get Medicaid and UBs		
				INSERT INTO ar_facility_enabled_option_item (
					fac_id
					,option_item_id
					,created_by
					,created_date
					)
				SELECT DISTINCT f.fac_id
					,afc.option_item_id
					,@Creator
					,GETDATE()
				FROM ar_facility_configuration_group_option_item afc WITH (NOLOCK)
				INNER JOIN facility f WITH (NOLOCK) ON f.deleted = 'N'
					AND f.country_id = 100
				WHERE f.health_type = 'ALF'
					AND afc.option_item_id IN (
						6
						,7
						,8
						)
					AND f.fac_id NOT IN (
						SELECT DISTINCT fac_id
						FROM ar_facility_enabled_option_item WITH (NOLOCK)
						WHERE option_item_id IN (
								6
								,7
								,8
								)
						)

				COMMIT TRAN
			END TRY

			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK TRAN

				DECLARE @err NVARCHAR(3000)

				SET @err = 'Error creating security functions for ' + @Creator + ': ' + ERROR_MESSAGE()

				RAISERROR (
						@err
						,16
						,1
						)
			END CATCH

			/*

Below script Added By: Jaspreet Singh
Case# 1139873
Date: 2018-03-02
Reason: To Create statement configuration row for all active facilities
*/
			-- Written By:           Ahmedur Rahman
			-- Modified By: 		 Byron Lee
			-- Reviewed By:			 
			--
			-- Script Type:          DML
			-- Target DB Type:       CLIENT
			-- Target ENVIRONMENT:   BOTH
			--
			--
			-- Re-Runnable:          YES
			--
			--
			-- Adding default values for EMC
			-- Create statement configuration row for all active facilities
			-- =================================================================================
			--step 01. declare default values
			DECLARE @ancillary_display_option VARCHAR(3) = 'D'
			DECLARE @transaction_display_option VARCHAR(3) = '0'
			DECLARE @display_unit_and_amount_flag BIT = 0
			DECLARE @display_aging_flag BIT = 0
			DECLARE @display_invoice_number_flag BIT = 0
			DECLARE @display_location_flag BIT = 0
			DECLARE @display_admit_date_flag BIT = 0
			DECLARE @display_discharge_date_flag BIT = 0
			DECLARE @display_resident_number_flag BIT = 0
			DECLARE @sort_option VARCHAR(1) = 'P'
			DECLARE @font_size TINYINT = 10
			DECLARE @page_break TINYINT = 0
			DECLARE @paper_size TINYINT = 0
			DECLARE @envelope_type VARCHAR(10) = 'single'
			DECLARE @prefix_facility_code_to_account_number_flag BIT = 0
			DECLARE @comment_from_adjustments BIT = 0
			DECLARE @comment_from_ancillary BIT = 0
			DECLARE @comment_from_cash BIT = 0
			DECLARE @enable_statement_link_flag BIT = 0
			DECLARE @statement_date_option TINYINT = 0
			DECLARE @emc_jira VARCHAR(10) = 'PCC-118981'
			DECLARE @facility_jira VARCHAR(10) = 'PCC-120521'
			--------------migration variables---------
			DECLARE @emc_standard_template VARCHAR(60) = 'Standard Default Statement Configuration Template'
			DECLARE @campus_standard_template VARCHAR(60) = 'Standard Campus Statement Configuration Template'
			-- values for created and revision fields
			DECLARE @created_date DATETIME = getdate()
			DECLARE @template_migration VARCHAR(20) = 'CORE-7394 migration'
			DECLARE @emc_template_migration VARCHAR(30) = 'CORE-7394 Enterprise Template'
			DECLARE @original_revision VARCHAR(30) = 'PCC-120521'
			--values for 'cheques_payable_to' column
			DECLARE @cheques_payable_to_facility_name TINYINT = 0
			DECLARE @cheques_payable_to_campus_name TINYINT = 1
			DECLARE @cheques_payable_to_custom_name TINYINT = 2

			------------------------------------
			-- step 02. create EMC row using defaults
			IF NOT EXISTS (
					SELECT 1
					FROM ar_statement_configuration
					WHERE fac_id = - 1
					)
			BEGIN
				INSERT INTO ar_statement_configuration (
					fac_id
					,cheques_payable_to
					,statement_header_image_id
					,statement_footer_image_id
					,ancillary_display_option
					,transaction_display_option
					,display_unit_and_amount_flag
					,display_aging_flag
					,display_invoice_number_flag
					,display_location_flag
					,display_admit_date_flag
					,display_discharge_date_flag
					,display_resident_number_flag
					,payment_instructions
					,sort_option
					,font_size
					,page_break
					,paper_size
					,envelope_type
					,prefix_facility_code_to_account_number_flag
					,comment_from_adjustments
					,comment_from_ancillary
					,comment_from_cash
					,enable_statement_link_flag
					,enabled_date
					,enabled_by
					,created_date
					,created_by
					,revised_date
					,revised_by
					,statement_message
					,statement_date_option
					)
				VALUES (
					- 1 -- fac_id - int
					,NULL -- cheques_payable_to - varchar(200)
					,NULL -- statement_header_image_id - int
					,NULL -- statement_footer_image_id - int
					,@ancillary_display_option -- ancillary_display_option - varchar(3)
					,@transaction_display_option -- transaction_display_option - varchar(3)
					,@display_unit_and_amount_flag -- display_unit_and_amount_flag - bit
					,@display_aging_flag -- display_aging_flag - bit
					,@display_invoice_number_flag -- display_invoice_number_flag - bit
					,@display_location_flag -- display_location_flag - bit
					,@display_admit_date_flag -- display_admit_date_flag - bit
					,@display_discharge_date_flag -- display_discharge_date_flag - bit
					,@display_resident_number_flag -- display_resident_number_flag - bit
					,NULL -- payment_instructions - varchar(1000)
					,@sort_option -- sort_option - varchar(1)
					,@font_size -- font_size - tinyint
					,@page_break -- page_break - tinyint
					,@paper_size -- paper_size - tinyint
					,@envelope_type -- envelope_type - varchar(10)
					,@prefix_facility_code_to_account_number_flag -- prefix_facility_code_to_account_number_flag - bit
					,@comment_from_adjustments -- comment_from_adjustments - bit
					,@comment_from_ancillary -- comment_from_ancillary - bit
					,@comment_from_cash -- comment_from_cash - bit
					,@enable_statement_link_flag -- enable_statement_link_flag - bit
					,NULL -- enabled_date - datetime
					,NULL -- enabled_by - varchar(60)
					,getdate() -- created_date - datetime
					,@emc_jira -- created_by - varchar(60)
					,getdate() -- revised_date - datetime
					,@emc_jira -- revised_by - varchar(60)
					,NULL -- statement_message varchar(650)
					,@statement_date_option -- statement_date_option tinyint 
					)
			END

			--step 03. create row for all live facilities in temp table
			INSERT INTO ar_statement_configuration (
				fac_id
				,cheques_payable_to
				,statement_header_image_id
				,ancillary_display_option
				,transaction_display_option
				,display_unit_and_amount_flag
				,display_aging_flag
				,display_invoice_number_flag
				,display_location_flag
				,display_admit_date_flag
				,display_discharge_date_flag
				,display_resident_number_flag
				,sort_option
				,font_size
				,page_break
				,paper_size
				,envelope_type
				,prefix_facility_code_to_account_number_flag
				,comment_from_adjustments
				,comment_from_ancillary
				,comment_from_cash
				,enable_statement_link_flag
				,created_date
				,created_by
				,revised_date
				,revised_by
				,statement_date_option
				)
			SELECT f.fac_id
				,CASE 
					WHEN c.cheques_payable_to IS NULL
						OR c.cheques_payable_to = ''
						THEN f.NAME
					ELSE c.cheques_payable_to
					END AS cheques_payable_to
				,c.statement_header_image_id
				,@ancillary_display_option
				,@transaction_display_option
				,@display_unit_and_amount_flag
				,@display_aging_flag
				,@display_invoice_number_flag
				,@display_location_flag
				,@display_admit_date_flag
				,@display_discharge_date_flag
				,@display_resident_number_flag
				,@sort_option
				,@font_size
				,@page_break
				,@paper_size
				,@envelope_type
				,@prefix_facility_code_to_account_number_flag
				,@comment_from_adjustments
				,@comment_from_ancillary
				,@comment_from_cash
				,CASE 
					WHEN (f.facility_type = 'USAR')
						OR (
							f.facility_type = 'CDN'
							AND c.transition_to_enhanced_billing_date <> NULL
							)
						THEN 1
					ELSE 0
					END AS enable_statement_link_flag
				,getdate()
				,@facility_jira
				,getdate()
				,@facility_jira
				,@statement_date_option
			FROM facility f
			INNER JOIN ar_configuration c ON f.fac_id = c.fac_id
			WHERE f.deleted = 'N'
				AND (
					f.is_live <> 'N'
					OR f.is_live IS NULL
					) -- only live facilities
				AND f.fac_id > 0
				AND NOT EXISTS (
					SELECT fac_id
					FROM ar_statement_configuration
					WHERE fac_id = f.fac_id
					)

			--Following part of the script will only be run for post 3.7.15 releases. The script makes sure that a template table exists before running the following.
			-- If a ar_statement_configuration_template table exists, that means data has already been migrated for other columns during the update to 3.7.15
			-- After a row has been created for the newly added facility. The facility is not yet part of any campus (assuming this script is 
			-- being run right after adding the facility in the db), so an entry needs to be added into the [ar_statement_configuration_template_enterprise_facility_mapping] table -- to point this facility to the default template	
			IF (
					EXISTS (
						SELECT 1
						FROM INFORMATION_SCHEMA.TABLES
						WHERE TABLE_SCHEMA = 'dbo'
							AND TABLE_NAME = 'ar_statement_configuration_template'
						)
					)
			BEGIN
				-- If it's a single fac org and the newly added facility is the first & only facility, then migrate data for single facilities
				IF (
						SELECT count(fac_id)
						FROM ar_statement_configuration
						WHERE fac_id > 0
						) = 1
				BEGIN
					IF NOT EXISTS (
							SELECT 1
							FROM ar_statement_configuration_template
							)
					BEGIN
						INSERT INTO ar_statement_configuration_template (
							default_template
							,description
							,fac_id
							,cheques_payable_to_option
							,cheques_payable_to
							,use_custom_header_logo
							,statement_header_image_id
							,statement_date_option
							,ancillary_display_option
							,transaction_display_option
							,comment_from_adjustments
							,comment_from_ancillary
							,comment_from_cash
							,display_unit_and_amount_flag
							,display_aging_flag
							,display_invoice_number_flag
							,display_location_flag
							,display_admit_date_flag
							,display_discharge_date_flag
							,display_resident_number_flag
							,payment_instructions
							,sort_option
							,font_size
							,page_break
							,paper_size
							,envelope_type
							,prefix_facility_code_to_account_number_flag
							,statement_message
							,created_date
							,created_by
							,revision_date
							,revision_by
							,deleted
							)
						SELECT 1
							,f.NAME + ' Template'
							,sc.fac_id
							,CASE 
								WHEN sc.cheques_payable_to = f.NAME
									THEN @cheques_payable_to_facility_name
								ELSE @cheques_payable_to_custom_name
								END
							,sc.cheques_payable_to
							,CASE 
								WHEN sc.statement_header_image_id IS NOT NULL
									THEN 1
								ELSE 0
								END
							,sc.statement_header_image_id
							,sc.statement_date_option
							,sc.ancillary_display_option
							,sc.transaction_display_option
							,sc.comment_from_adjustments
							,sc.comment_from_ancillary
							,sc.comment_from_cash
							,sc.display_unit_and_amount_flag
							,sc.display_aging_flag
							,sc.display_invoice_number_flag
							,sc.display_location_flag
							,sc.display_admit_date_flag
							,sc.display_discharge_date_flag
							,sc.display_resident_number_flag
							,sc.payment_instructions
							,sc.sort_option
							,sc.font_size
							,sc.page_break
							,sc.paper_size
							,sc.envelope_type
							,sc.prefix_facility_code_to_account_number_flag
							,sc.statement_message
							,@created_date
							,@template_migration
							,@created_date
							,@template_migration
							,'N'
						FROM ar_statement_configuration sc
						LEFT JOIN ar_statement_configuration_template sct ON sct.fac_id = sc.fac_id --????????????????????
						INNER JOIN facility f ON f.fac_id = sc.fac_id
						WHERE (
								sc.fac_id > 0
								AND sc.fac_id < 9000
								)
					END
				END
			END

			/*
Below code added by: Jaspreet Singh
date: 2018-04-04
reason: Ann email subject:- FW: New identifier
*/
			-- Filename: CORE-13614 - DML-create new MBI resident identifier.sql
			-- CORE-13614: DML-create new MBI resident identifier and update a/r configuration
			-- Script Order:    1 of 1
			-- 
			-- Written By:      Megha Kumar
			-- Reviewed By:    
			-- 
			-- Script Type:     DML
			-- Target DB Type:  US
			-- Target Database: All
			-- 
			-- Re-Runable:      Yes
			-- 
			-- Description of Script Function:
			-- Create new MBI resident identifier and update a/r configuration
			-- 
			-- Special Instruction: None
			-- *****************************************************************************
			DECLARE @idTypeId INT

			IF NOT EXISTS (
					SELECT 1
					FROM id_type
					WHERE description = 'Medicare Beneficiary ID'
						AND fac_id = - 1
						AND deleted = 'N'
					)
			BEGIN
				DELETE
				FROM pcc_global_primary_key
				WHERE table_name = 'id_type'
					AND key_column_name = 'id_type_id';

				SELECT @idTypeId = coalesce(max(id_type_id), 0)
				FROM dbo.id_type WITH (NOLOCK)

				SET @idTypeId = @idTypeId + 1

				--EXEC get_next_primary_key 'id_type'
				--	,'id_type_id'
				--	,@idTypeId OUTPUT
				--	,1;
				INSERT INTO id_type (
					id_type_id
					,fac_id
					,deleted
					,created_by
					,created_date
					,revision_by
					,revision_date
					,description
					,format
					,show_on_a_r
					,show_on_invoice
					,sequence
					,show_on_new
					,required_on_new
					,deleted_by
					,deleted_date
					,reg_id
					,unique_id
					,state_code
					)
				VALUES (
					@idTypeId
					,- 1
					,'N'
					,'CORE-13614'
					,GETDATE()
					,NULL
					,NULL
					,'Medicare Beneficiary ID'
					,'XXXXXXXXXXX'
					,'Y'
					,'N'
					,1
					,'Y'
					,'N'
					,NULL
					,NULL
					,NULL
					,'Y'
					,NULL
					);

				INSERT INTO id_type_activation
				SELECT @idTypeId
					,fac_id
				FROM facility
				WHERE health_type = 'SNF'
					AND facility_type = 'USAR';

				UPDATE ar_configuration
				SET medicare_beneficiary_id = ISNULL(@idTypeId, medicare_beneficiary_id)
					,revision_by = 'CORE-13614'
					,revision_date = GETDATE()
				WHERE fac_id IN (
						SELECT fac_id
						FROM facility
						WHERE health_type = 'SNF'
							AND facility_type = 'USAR'
						);
			END
					--4/4/2018 - added the following for new facility creation
			ELSE
			BEGIN
				UPDATE ar_configuration
				SET medicare_beneficiary_id = (
						SELECT TOP 1 id_type_id /* Added By: Jaspreet Singh, Date: 2019-03-06, Reason: Because we ave multiple rows for given values in table id_type */
						FROM id_type
						WHERE description = 'Medicare Beneficiary ID'
							AND fac_id = - 1
							AND deleted = 'N'
						)
					,revision_by = @Creator
					,revision_date = GETDATE()
				WHERE fac_id IN (
						SELECT fac_id
						FROM facility
						WHERE health_type = 'SNF'
							AND facility_type = 'USAR'
						)
					AND medicare_beneficiary_id IS NULL;
			END

			/*
Below code added by: Jaspreet Singh
date: 2019-06-17
reason: Ann email subject:- RE: Integration Pre-Configurations 
Ability Configuration

---- SELECT * FROM message_route where message_profile_id = 4
*/
			IF NOT EXISTS (
					SELECT 1
					FROM lib_message_profile
					WHERE vendor_code = 'ABILITY_CLAIMS'
					)
			BEGIN
				DECLARE @MsgGrpEmail VARCHAR(400)
					,@TSImpEmail VARCHAR(400)
					,@SaaSOpsIntEmail VARCHAR(400)
					,@protocol_id INT
					,@enabled BIT = 1 -- 0 Not Enabled, 1 Enabled

				SELECT @facId = @FacIdDest
					,@created_by = SYSTEM_USER
					,@created_date = GETDATE()
					,@protocol_id = 25
					,@message_profile_id = NULL

				IF (
						(
							SELECT count(1)
							FROM facility
							WHERE fac_id NOT IN (9001)
								AND deleted = 'N'
								AND inactive IS NULL
								AND inactive_date IS NULL
							) = 1
						)
				BEGIN
					SET @multiFacility = 0
				END

				SELECT @MsgGrpEmail = 'MessagingGroupEmail@pointclickcare.com' ---- 'SaaSOpsApplicationAdmins@pointclickcare.com'
					,@TSImpEmail = 'PDintegration@pointclickcare.com'
					,@SaaSOpsIntEmail = 'SaaSOpsIntegrationOperations@pointclickcare.com'

				IF EXISTS (
						SELECT *
						FROM dbo.pcc_global_primary_key
						WHERE table_name = 'lib_message_profile'
						)
				BEGIN
					IF (
							SELECT next_key
							FROM pcc_global_primary_key
							WHERE table_name = 'lib_message_profile'
							) <= (
							SELECT Max(message_profile_id)
							FROM lib_message_profile
							)
					BEGIN
						DELETE
						FROM pcc_global_primary_key
						WHERE table_name = 'lib_message_profile'
					END
				END

				SET @message_profile_id = NULL

				DELETE
				FROM pcc_global_primary_key
				WHERE table_name = 'lib_message_profile'
					AND key_column_name = 'message_profile_id';

				SELECT @message_profile_id = coalesce(max(message_profile_id), 0)
				FROM dbo.lib_message_profile WITH (NOLOCK)

				SET @message_profile_id = @message_profile_id + 1

				----EXEC [dbo].Get_next_primary_key 'lib_message_profile'
				----	,'message_profile_id'
				----	,@message_profile_id OUTPUT
				----	,1
				IF (@message_profile_id > 0)
				BEGIN
					SET @step = 9

					INSERT INTO lib_message_profile (
						vendor_code
						,include_outpatient
						,description
						,created_by
						,message_mode
						,is_enabled
						,message_communication_id
						,deleted
						,endpoint_url
						,is_integrated_pharmacy
						,remote_login
						,include_discharged
						,remote_password
						,created_date
						,message_profile_id
						,message_protocol_id
						)
					VALUES (
						'ABILITY_CLAIMS'
						,'N'
						,'ABILITY RCM'
						,@created_by
						,'P'
						,'N' -- Added as per Eddie email
						,'1'
						,'N'
						,'https://api.accessrcm.abilitynetwork.com/v1'
						,'N'
						,'KFSCWK133ZE1IX44W1BO0Q4Q5'
						,'FALSE'
						,'FhLcAc10OGmmK6MaWwhkixVUVpLBtkgJFtpC4DFiFZI='
						,@created_date
						,@message_profile_id
						,@protocol_id
						)
				END

				IF (@multiFacility = 0)
				BEGIN
					SET @step = 10

					INSERT INTO message_profile (
						fac_id
						,include_outpatient
						,created_by
						,message_mode
						,is_enabled
						,message_communication_id
						,endpoint_url
						,is_integrated_pharmacy
						,remote_login
						,include_discharged
						,remote_password
						,created_date
						,message_profile_id
						,message_protocol_id
						)
					VALUES (
						'1'
						,'N'
						,@created_by
						,'P'
						,'N'
						,'1'
						,'https://api.accessrcm.abilitynetwork.com/v1'
						,'N'
						,'KFSCWK133ZE1IX44W1BO0Q4Q5'
						,'FALSE'
						,'FhLcAc10OGmmK6MaWwhkixVUVpLBtkgJFtpC4DFiFZI='
						,@created_date
						,@message_profile_id
						,@protocol_id
						)
				END

				SET @step = 11

				INSERT INTO message_profile_param (
					param_value_type
					,fac_id
					,param_value
					,message_profile_id
					,param_id
					)
				SELECT '3' AS PARAM_VALUE_TYPE
					,CASE 
						WHEN @multiFacility = 0
							THEN @facId
						ELSE - 1
						END AS FAC_ID
					,'1lmySwJn&hgh@s7K9&7c4XO5X' AS PARAM_VALUE
					,@message_profile_id AS MESSAGE_PROFILE_ID
					,'49' AS PARAM_ID
				
				UNION ALL
				
				SELECT '3' AS PARAM_VALUE_TYPE
					,CASE 
						WHEN @multiFacility = 0
							THEN @facId
						ELSE - 1
						END AS FAC_ID
					,'https://api.accessrcm.abilitynetwork.com/v1' AS PARAM_VALUE
					,@message_profile_id AS MESSAGE_PROFILE_ID
					,'47' AS PARAM_ID
				
				UNION ALL
				
				SELECT '3' AS PARAM_VALUE_TYPE
					,CASE 
						WHEN @multiFacility = 0
							THEN @facId
						ELSE - 1
						END AS FAC_ID
					,'KFSCWK133ZE1IX44W1BO0Q4Q5' AS PARAM_VALUE
					,@message_profile_id AS MESSAGE_PROFILE_ID
					,'48' AS PARAM_ID
				
				UNION ALL
				
				SELECT '3' AS PARAM_VALUE_TYPE
					,CASE 
						WHEN @multiFacility = 0
							THEN @facId
						ELSE - 1
						END AS FAC_ID
					,'eeTzAKg8' AS PARAM_VALUE
					,@message_profile_id AS MESSAGE_PROFILE_ID
					,'6' AS PARAM_ID
				
				UNION ALL
				
				SELECT '3' AS PARAM_VALUE_TYPE
					,CASE 
						WHEN @multiFacility = 0
							THEN @facId
						ELSE - 1
						END AS FAC_ID
					,'Uqp2MxX3' AS PARAM_VALUE
					,@message_profile_id AS MESSAGE_PROFILE_ID
					,'5' AS PARAM_ID
				
				UNION ALL
				
				SELECT '3' AS PARAM_VALUE_TYPE
					,CASE 
						WHEN @multiFacility = 0
							THEN @facId
						ELSE - 1
						END AS FAC_ID
					,'API' AS PARAM_VALUE
					,@message_profile_id AS MESSAGE_PROFILE_ID
					,'66' AS PARAM_ID
				
				UNION ALL
				
				SELECT '3' AS PARAM_VALUE_TYPE
					,CASE 
						WHEN @multiFacility = 0
							THEN @facId
						ELSE - 1
						END AS FAC_ID
					,'298' AS PARAM_VALUE
					,@message_profile_id AS MESSAGE_PROFILE_ID
					,'50' AS PARAM_ID

				SET @Step = 12

				INSERT INTO [dbo].[vaf_vendor_alert_facility_config] (
					[fac_id]
					,[protocol_id]
					,[override_emc]
					,[message_profile_id]
					)
				VALUES (
					CASE 
						WHEN @multiFacility = 0
							THEN @facId
						ELSE - 1
						END
					,@protocol_id
					,0
					,@message_profile_id
					)

				SET @step = 13

				INSERT INTO [dbo].[vaf_vendor_alert_config] (
					alert_id
					,fac_id
					,protocol_id
					,enabled
					,email
					,message_profile_id
					)
				SELECT alert_id
					,CASE 
						WHEN @multiFacility = 0
							THEN @facId
						ELSE - 1
						END AS fac_id
					,@protocol_id AS protocol_id
					,1 AS enabled
					,NULL AS email
					,@message_profile_id
				FROM vaf_vendor_alert
				WHERE protocol_id = 25
					AND type = 'F'

				IF NOT EXISTS (
						SELECT 1
						FROM vaf_vendor_alert_config
						WHERE [email] = @MsgGrpEmail
							AND protocol_id = @protocol_id
						)
				BEGIN
					SET @step = 14

					INSERT INTO vaf_vendor_alert_config (
						alert_id
						,fac_id
						,protocol_id
						,enabled
						,email
						,message_profile_id
						)
					SELECT 447 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@MsgGrpEmail AS email
						,@message_profile_id AS message_profile_id
					
					UNION ALL
					
					SELECT 440 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@MsgGrpEmail AS email
						,@message_profile_id AS message_profile_id
					
					UNION ALL
					
					SELECT 446 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@MsgGrpEmail AS email
						,@message_profile_id AS message_profile_id
					
					UNION ALL
					
					SELECT 451 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@MsgGrpEmail AS email
						,@message_profile_id AS message_profile_id
					
					UNION ALL
					
					SELECT 449 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@MsgGrpEmail AS email
						,@message_profile_id AS message_profile_id
					
					UNION ALL
					
					SELECT 437 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@MsgGrpEmail AS email
						,@message_profile_id AS message_profile_id
					
					UNION ALL
					
					SELECT 438 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@MsgGrpEmail AS email
						,@message_profile_id AS message_profile_id
					
					UNION ALL
					
					SELECT 436 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@MsgGrpEmail AS email
						,@message_profile_id AS message_profile_id
					
					UNION ALL
					
					SELECT 452 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@MsgGrpEmail AS email
						,@message_profile_id AS message_profile_id
					
					UNION ALL
					
					SELECT 443 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@MsgGrpEmail AS email
						,@message_profile_id AS message_profile_id
				END

				IF NOT EXISTS (
						SELECT 1
						FROM vaf_vendor_alert_config
						WHERE [email] = @SaaSOpsIntEmail
							AND protocol_id = @protocol_id
						)
				BEGIN
					SET @step = 15

					INSERT INTO vaf_vendor_alert_config (
						alert_id
						,fac_id
						,protocol_id
						,enabled
						,email
						,message_profile_id
						)
					SELECT 462 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@SaaSOpsIntEmail AS email
						,@message_profile_id AS message_profile_id
					
					UNION ALL
					
					SELECT 452 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@SaaSOpsIntEmail AS email
						,@message_profile_id AS message_profile_id
					
					UNION ALL
					
					SELECT 441 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@SaaSOpsIntEmail AS email
						,@message_profile_id AS message_profile_id
					
					UNION ALL
					
					SELECT 459 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@SaaSOpsIntEmail AS email
						,@message_profile_id AS message_profile_id
					
					UNION ALL
					
					SELECT 460 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@SaaSOpsIntEmail AS email
						,@message_profile_id AS message_profile_id
				END

				IF NOT EXISTS (
						SELECT 1
						FROM vaf_vendor_alert_config
						WHERE [email] = @TSImpEmail
							AND protocol_id = @protocol_id
						)
				BEGIN
					SET @step = 17

					INSERT INTO vaf_vendor_alert_config (
						alert_id
						,fac_id
						,protocol_id
						,enabled
						,email
						,message_profile_id
						)
					SELECT 461 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@TSImpEmail AS email
						,@message_profile_id AS message_profile_id
					
					UNION ALL
					
					SELECT 454 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@TSImpEmail AS email
						,@message_profile_id AS message_profile_id
					
					UNION ALL
					
					SELECT 505 AS alert_id
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,@protocol_id AS protocol_id
						,@enabled AS [enabled]
						,@TSImpEmail AS email
						,@message_profile_id AS message_profile_id
				END

				---------------------------------------------------------------------------------------
				---------------------------------------------------------------------------------------
				----------------URL Configuration Setup For Ability------------------------
				---------------------------------------------------------------------------------------
				---------------------------------------------------------------------------------------
				DECLARE @vUrl VARCHAR(500)
					,@vName VARCHAR(30)
					,@vUrl_config_id INT

				SELECT @vName = 'Ability RCM'
					,@vUrl = 'Ability'

				IF NOT EXISTS (
						SELECT 1
						FROM dbo.pcc_ext_vendor_url_config
						WHERE NAME = @vName
							AND url = @vUrl
						)
				BEGIN
					SET @step = 18

					INSERT INTO pcc_ext_vendor_url_config (
						[type]
						,NAME
						,url
						,protocol
						,port
						,emar_poc_flag
						,activated
						,icon_type_flag
						,icon_uri
						,scope
						,lob
						,state_code
						,entry_date
						,update_date
						,access_ltd_flag
						)
					VALUES (
						'PASS_THRU_AUTH'
						,@vName
						,@vUrl
						,'HTTP'
						,80
						,'N'
						,'N'
						,'D'
						,'/images/sidebar/quicklink.png'
						,'C'
						,- 1
						,NULL
						,getdate()
						,getdate()
						,'N'
						)

					SET @vUrl_config_id = SCOPE_IDENTITY()
					SET @step = 19

					INSERT INTO pcc_ext_vendor_url_param (
						url_config_id
						,param_type
						,param_name
						,param_value
						)
					SELECT @vUrl_config_id AS url_config_id
						,'C' AS param_type
						,'facId' AS param_name
						,'-1' AS param_value
					
					UNION
					
					SELECT @vUrl_config_id AS url_config_id
						,'C' AS param_type
						,'assertBackgroundSaml' AS param_name
						,'false' AS param_value
					
					UNION
					
					SELECT @vUrl_config_id AS url_config_id
						,'C' AS param_type
						,'hideOnExternalLink' AS param_name
						,'false' AS param_value
					
					UNION
					
					SELECT @vUrl_config_id AS url_config_id
						,'C' AS param_type
						,'showOnAdminHeader' AS param_name
						,'false' AS param_value
					
					UNION
					
					SELECT @vUrl_config_id AS url_config_id
						,'C' AS param_type
						,'showOnClaimListing' AS param_name
						,'false' AS param_value
					
					UNION
					
					SELECT @vUrl_config_id AS url_config_id
						,'C' AS param_type
						,'showOnClinicalHeader' AS param_name
						,'false' AS param_value
				END

				IF @DebugMe = 'Y'
					PRINT 'Abillity_Claims script at step:' + convert(VARCHAR(3), @step) + '    ' + convert(VARCHAR(26), getdate(), 109)
			END

			--end 6/17/2019 - added the following for new facility creation of Integration Pre-Configuration
			--------------------------------------------------------------------------------------------------------------------
			-- added by RYAN - 04/03/2020
			-- to copy config items only if the org is from the OTBMASTER template - as per Xander Croner
			DECLARE @otb VARCHAR(1)
			DECLARE @sql_cmd_otb VARCHAR(max)

			SET @otb = CASE 
					WHEN EXISTS (
							SELECT 1
							FROM dbo.facility_audit
							WHERE fac_id = 1
								AND NAME = 'OTB TEMPLATE-ALF'
								AND deleted = 'N'
							)
						THEN 'Y'
					ELSE 'N'
					END

			--select @otb
			IF @healthtype = 'ALF'
			BEGIN
				IF @otb = 'Y'
				BEGIN
					SET @sql_cmd_otb = '
						DELETE FROM configuration_parameter where fac_id in (' + convert(VARCHAR(10), @FacIdDest) + ')

						INSERT INTO configuration_parameter (fac_id,[name],value)
						SELECT ' + convert(VARCHAR(10), @FacIdDest) + ' ,[name],value 
						FROM [' + @template_server + '].' + 'us_template_pccsingle_otbmaster.dbo.configuration_parameter
						WHERE fac_id = 1'

					EXEC (@sql_cmd_otb)
				END
			END

			--------------------------------------------------------------------------------------------------------------------
			/****
		---- added by Jaspreet - 01/06/2022
		---- Comment: Email subject RE: [PagerDuty ALERT] You have 1 TRIGGERED Incident (5c236)		
		---- added by RYAN - 04/14/2020
			---- PDP 4.1.3 - part of CORE-64977
			DECLARE @recurring_charges_by_day_start_date VARCHAR(1)
			DECLARE @sql_cmd_recurring_charges_by_day_start_date VARCHAR(max)

			SET @recurring_charges_by_day_start_date = CASE 
					WHEN EXISTS (
							SELECT 1
							FROM sys.columns
							WHERE Name = N'recurring_charges_by_day_start_date'
								AND Object_ID = Object_ID(N'ar_configuration')
							)
						THEN 'Y'
					ELSE 'N'
					END

			--select @recurring_charges_by_day_start_date
			IF @recurring_charges_by_day_start_date = 'Y'
			BEGIN
				BEGIN
					ALTER TABLE ar_configuration disable TRIGGER [tp_ar_configuration_upd]
				END

				BEGIN
					SET @sql_cmd_recurring_charges_by_day_start_date = '
					update ar_configuration
					set recurring_charges_by_day_start_date = ar_start_date where fac_id = ' + convert(VARCHAR(10), @FacIdDest) + ''

					EXEC (@sql_cmd_recurring_charges_by_day_start_date)
				END

				BEGIN
					ALTER TABLE ar_configuration enable TRIGGER [tp_ar_configuration_upd]
				END
			END
****/
			--------------------------------------------------
			-- added by RYAN - 12/03/2020
			-- email from Product -- IPC & Facility Acquisition Process -- Tuesday, November 24, 2020 10:06 AM
			-- there are two parts to this update - this is the second part for adding a row for the new fac
			INSERT INTO branded_library_feature_configuration (
				fac_id
				,brand_id
				,name
				,value
				,enabled_by
				,enabled_date
				,disabled_by
				,disabled_date
				,created_by
				,created_date
				,revision_by
				,revision_date
				,sequence
				)
			SELECT @FacIdDest
				,lib.brand_id
				,'enable_cp_partner_feature'
				,'N'
				,@Creator
				,GETDATE()
				,NULL
				,NULL
				,@Creator
				,GETDATE()
				,@Creator
				,GETDATE()
				,con.sequence
			FROM branded_library_configuration lib WITH (NOLOCK)
			JOIN branded_library_tier_configuration con WITH (NOLOCK) ON lib.brand_id = con.brand_id
			WHERE NOT EXISTS (
					SELECT name
					FROM branded_library_feature_configuration WITH (NOLOCK)
					WHERE name = 'enable_cp_partner_feature'
						AND fac_id = @FacIdDest
					)
				AND lib.brand_name = 'PCC Infection Control solution'
				AND lib.deleted = 'N'

			INSERT INTO branded_library_feature_option_conf (
				brand_id
				,fac_id
				,sequence
				,status_id
				,readonly
				)
			SELECT lib.brand_id
				,@FacIdDest
				,con.sequence
				,4
				,1
			FROM branded_library_configuration lib WITH (NOLOCK)
			JOIN branded_library_tier_configuration con WITH (NOLOCK) ON lib.brand_id = con.brand_id
			JOIN branded_library_feature_configuration f WITH (NOLOCK) ON con.brand_id = f.brand_id
			WHERE NOT EXISTS (
					SELECT fac_id
					FROM branded_library_feature_option_conf WITH (NOLOCK)
					WHERE brand_id IN (
							SELECT brand_id
							FROM branded_library_configuration WITH (NOLOCK)
							WHERE brand_name = 'PCC Infection Control solution'
								AND deleted = 'N'
							)
						AND fac_id = @FacIdDest
					)
				AND f.fac_id = @FacIdDest

			-------------------------------------------------- 
			-- added by RYAN - 12092020
			-- email from Ann - 12/8/2020 2:54 PM -- RE: Enabling logging for new facilities onboarded
			-- **************************************************************
			-- This script is to be executed on the CLIENT DB
			-- to enable auditing for every facility in the org by default
			-- **************************************************************
			DECLARE @auditEnabledFACs TABLE (fac_id INT)

			INSERT INTO @auditEnabledFACs
			SELECT fac_id
			FROM facility

			DECLARE @selectedFacId INT

			SET @selectedFacId = (
					SELECT TOP 1 fac_id
					FROM @auditEnabledFACs
					)

			DECLARE @enabledaudit INT = 1 -- 1=enable
			DECLARE @byUserName VARCHAR(60) = @Creator
			DECLARE @configParamValue CHAR(1) = 'Y'
			DECLARE @cache_time DATETIME

			WHILE @selectedFacId IS NOT NULL
			BEGIN
				MERGE configuration_parameter D
				USING (
					SELECT @selectedFacId AS fac_id
						,'enable_audit' AS name
						,@configParamValue AS value
					) AS S
					ON (
							D.fac_id = S.fac_id
							AND D.name = S.name
							)
				WHEN MATCHED
					THEN
						UPDATE
						SET D.value = S.value
				WHEN NOT MATCHED BY TARGET
					THEN
						INSERT (
							fac_id
							,name
							,value
							)
						VALUES (
							S.fac_id
							,S.name
							,S.value
							);

				EXEC pcc_update_cache_time @selectedFacId
					,'configParams'
					,@cache_time

				EXEC pcc_update_cache_time - 1
					,'MASTER'
					,@cache_time

				DELETE
				FROM @auditEnabledFACs
				WHERE fac_id = @selectedFacId

				SET @selectedFacId = (
						SELECT TOP 1 fac_id
						FROM @auditEnabledFACs
						)
			END

			-------------------------------------------------- 
			-- updated by RYAN, as requested by Kelly Cherchio -- 03/01/2021
			--IF EXISTS (
			--		SELECT 1
			--		FROM facility_audit
			--		WHERE fac_id = 1
			--			AND name = 'ALF Template Database'
			--		)
			--	AND @healthtype = 'ALF'
			--BEGIN
			--	INSERT INTO evt_std_event_type_active_facility (
			--		fac_id
			--		,event_type_id
			--		,active
			--		,created_by
			--		,created_date
			--		,revision_by
			--		,revision_date
			--		)
			--	SELECT @FacIdDest
			--		,evtstd.event_type_id
			--		,1
			--		,@Creator
			--		,getdate()
			--		,@Creator
			--		,getdate()
			--	FROM evt_std_event_type evtstd WITH (NOLOCK) 
			--	LEFT JOIN evt_std_event_type_active_facility evtfac WITH (NOLOCK)  ON evtstd.event_type_id = evtfac.event_type_id
			--		WHERE NOT EXISTS (
			--			SELECT @FacIdDest
			--			FROM evt_std_event_type_active_facility
			--			)
			--		AND evtstd.deleted = 0
			--		AND evtstd.retired = 0
			--		AND evtstd.fac_id = -1
			--		AND evtstd.reg_id IS NULL
			--		AND evtstd.state_code IS NULL
			--		AND evtfac.fac_id = @FacIdDest
			--END
			------ Added By: Jaspreet Singh
			------ Date: 2021-05-21
			------ Reason: Jira OA-51
			IF EXISTS (
					SELECT 1
					FROM dbo.[lib_message_profile]
					WHERE vendor_code = 'uap'
					)
			BEGIN
				DECLARE @msgProfileId INT = 0

				SELECT @msgProfileId = message_profile_id
				FROM dbo.[lib_message_profile]
				WHERE vendor_code = 'uap'

				INSERT INTO dbo.message_profile (
					endpoint_url
					,ext_fac_id
					,fac_id
					,include_discharged
					,include_outpatient
					,is_enabled
					,is_integrated_pharmacy
					,message_communication_id
					,message_mode
					,message_profile_id
					,message_protocol_id
					,notification_email
					,inbound_security
					,receiving_application
					,receiving_facility
					,remote_login
					,remote_password
					,security
					,sending_application
					,patient_order_request_time
					,send_email_response
					,response_email_address
					,batch_eligibility
					,realtime_eligibility
					,created_by
					,created_date
					,revision_by
					,revision_date
					,reg_id
					)
				VALUES (
					'test'
					,NULL
					,@FacIdDest
					,NULL
					,NULL
					,'N'
					,'Y'
					,1
					,'P'
					,@msgProfileId
					,13
					,NULL
					,NULL
					,'xxxxxxxx'
					,NULL
					,NULL
					,NULL
					,NULL
					,'xxxxxxxx'
					,NULL
					,'N'
					,''
					,'N'
					,'N'
					,@Creator
					,getdate()
					,@Creator
					,getdate()
					,NULL
					)
			END
		END

		COMMIT TRANSACTION

		/*
Below code added by: Jaspreet Singh
date: 2019-06-17
reason: Ann email subject:- RE: Integration Pre-Configurations 
-- Darado Configuration
*/
		BEGIN TRY
			BEGIN TRAN

			IF NOT EXISTS (
					SELECT 1
					FROM lib_message_profile
					WHERE vendor_code = 'Dorado'
					)
			BEGIN
				SELECT --@message_profile_id = 10
					@facId = @FacIdDest
					--,@OrgId = 494950268
					,@parameter_value = NULL
					,@created_by = SYSTEM_USER
					,@created_date = GETDATE()

				IF (
						(
							SELECT count(1)
							FROM facility
							WHERE fac_id NOT IN (9001)
								AND deleted = 'N'
								AND inactive IS NULL
								AND inactive_date IS NULL
							) = 1
						)
				BEGIN
					SET @multiFacility = 0
				END

				SET @email = 'MessagingGroupEmail@pointclickcare.com'
				SET @sqlstring = 'SELECT @endpoint_url = ''{ustrftp_root}/ftp/integrationfiles/dorado/' + @OrgCode + '/270_Requests''
	,@importFTPLocation = ''{ustrftp_root}/integrationfiles/dorado/' + @OrgCode + 
					'/271_Results''
	,@parameter_value = CASE 
		WHEN environment_name IN (
				''www20''
				,''www24''
				,''www28''
				,''brk''
				)
			THEN ''2'' ---- ''Monday''
		WHEN environment_name IN (
				''www21''
				,''www26''
				,''www31''
				,''efs''
				,''hcr''
				)
			THEN ''3'' ---- ''Tuesday''
		WHEN environment_name IN (
				''www22''
				,''www29''
				,''www30''
				,''hcr''
				)
			THEN ''4'' ---- ''Wednesday''
		WHEN environment_name IN (
				''www23''
				,''www30''
				,''snrz''
				)
			THEN ''5'' ---- ''Thursday''
		WHEN environment_name IN (
				''www19''
				,''www25''
				,''lcca''
				)
			THEN ''6'' ----''Friday''
		WHEN environment_name IN (
				''qapcc05''
				,''dvistio''
				,''mca''
				,''qacorerus''
				,''qacorerca''
				,''mus''
				,''azvtca''
				,''azvtus''
				,''wus''
				)
			THEN ''10'' ---- For QA team only
		END
	,@sessionServerName = ''['' + session_instance_name + '']''
	,@sessionDatabaseName = ''['' + session_database_name + '']'' FROM ' 
					+ @SessionInstanceServerName + '
WHERE environment_name = ''' + SUBSTRING(@Environment, patindex('%[_]%', @Environment) + 1, len(@Environment)) + ''''

				EXEC Sp_executesql @sqlstring
					,N'@endpoint_url VARCHAR(max) OUTPUT, @importFTPLocation VARCHAR(max) OUTPUT, @parameter_value VARCHAR(max) OUTPUT, @sessionServerName VARCHAR(max) OUTPUT, @sessionDatabaseName VARCHAR(max) OUTPUT'
					,@endpoint_url = @endpoint_url OUTPUT
					,@importFTPLocation = @importFTPLocation OUTPUT
					,@parameter_value = @parameter_value OUTPUT
					,@sessionServerName = @sessionServerName OUTPUT
					,@sessionDatabaseName = @sessionDatabaseName OUTPUT

				--SELECT @endpoint_url
				--	,@importFTPLocation
				--	,@parameter_value
				--	,@sessionServerName
				--	,@sessionDatabaseName
				IF EXISTS (
						SELECT *
						FROM dbo.pcc_global_primary_key
						WHERE table_name = 'lib_message_profile'
						)
				BEGIN
					IF (
							SELECT next_key
							FROM pcc_global_primary_key
							WHERE table_name = 'lib_message_profile'
							) <= (
							SELECT Max(message_profile_id)
							FROM lib_message_profile
							)
					BEGIN
						DELETE
						FROM pcc_global_primary_key
						WHERE table_name = 'lib_message_profile'
					END
				END

				----IF (@multiFacility = 0)
				----BEGIN
				----	IF NOT EXISTS (
				----			SELECT 1
				----			FROM dbo.facility
				----			WHERE fac_id = @facId
				----			)
				----	BEGIN
				----		UPDATE facility
				----		SET messages_enabled_flag = 'Y'
				----		WHERE fac_id = @facId
				----	END
				----END
				SET @message_profile_id = NULL

				DELETE
				FROM pcc_global_primary_key
				WHERE table_name = 'lib_message_profile'
					AND key_column_name = 'message_profile_id';

				SELECT @message_profile_id = coalesce(max(message_profile_id), 0)
				FROM dbo.lib_message_profile WITH (NOLOCK)

				SET @message_profile_id = @message_profile_id + 1

				----EXEC [dbo].Get_next_primary_key 'lib_message_profile'
				----	,'message_profile_id'
				----	,@message_profile_id OUTPUT
				----	,1
				IF (@message_profile_id > 0)
				BEGIN
					SET @step = 1

					INSERT INTO [dbo].[lib_message_profile] (
						message_profile_id
						,vendor_code
						,description
						,message_protocol_id
						,receiving_application
						,sending_application
						,message_communication_id
						,deleted
						,message_mode
						,is_enabled
						,is_integrated_pharmacy
						,[endpoint_url]
						,created_by
						,created_date
						)
					VALUES (
						@message_profile_id
						,'Dorado'
						,'Dorado'
						,'14'
						,'xxxxxxxx'
						,'xxxxxxxx'
						,'1'
						,'N'
						,'P'
						,'N' -- Added as per Eddie email
						,'Y'
						,@endpoint_url
						,@created_by
						,Getdate()
						)
				END

				IF (@multiFacility = 0)
				BEGIN
					SET @step = 2

					INSERT INTO message_profile (
						batch_eligibility
						,fac_id
						,sending_application
						,created_by
						,message_mode
						,is_enabled
						,message_communication_id
						,[endpoint_url]
						,remote_login
						,realtime_eligibility
						,created_date
						,message_profile_id
						,message_protocol_id
						)
					VALUES (
						'N'
						,@facId
						,''
						,@created_by
						,'P'
						,'N'
						,'1'
						,@endpoint_url
						,''
						,'N'
						,Getdate()
						,@message_profile_id
						,'14'
						)

					SET @step = 3

					INSERT INTO message_profile (
						batch_eligibility
						,fac_id
						,sending_application
						,created_by
						,message_mode
						,is_enabled
						,message_communication_id
						,endpoint_url
						,remote_login
						,realtime_eligibility
						,created_date
						,message_profile_id
						,message_protocol_id
						)
					VALUES (
						'N'
						,'9001'
						,''
						,@created_by
						,'P'
						,'N'
						,'1'
						,@endpoint_url
						,''
						,'N'
						,Getdate()
						,@message_profile_id
						,'14'
						)
				END

				----SELECT @sessionServerName = '[US32048\ProdW4SESS]'
				----	,@sessionDatabaseName = '[wessessioninfo_www4]'
				---- Following code commented as per Ann. Reason:- TS should no touch global tables exists outside client database.
				SET @step = 4

				------SELECT @multiFacility MultiFacId
				------	,@facId FacId
				----SELECT @facId
				----	,@importFTPLocation
				----	,@message_profile_id
				INSERT INTO [dbo].[message_profile_param] (
					param_value_type
					,fac_id
					,param_value
					,message_profile_id
					,param_id
					)
				VALUES (
					'3'
					,CASE 
						WHEN @multiFacility = 0
							THEN @facId
						ELSE - 1
						END
					,@importFTPLocation
					,@message_profile_id
					,'1'
					)

				SET @step = 5

				INSERT INTO [dbo].[vaf_vendor_alert_facility_config] (
					[fac_id]
					,[protocol_id]
					,[override_emc]
					,[message_profile_id]
					)
				VALUES (
					CASE 
						WHEN @multiFacility = 0
							THEN @facId
						ELSE - 1
						END
					,14
					,0
					,@message_profile_id
					)

				SET @step = 6

				INSERT INTO [dbo].[vaf_vendor_alert_config] (
					alert_id
					,fac_id
					,protocol_id
					,enabled
					,email
					,message_profile_id
					)
				SELECT alert_id
					,CASE 
						WHEN @multiFacility = 0
							THEN @facId
						ELSE - 1
						END AS fac_id
					,14 AS protocol_id
					,1 AS enabled
					,NULL AS email
					,@message_profile_id
				FROM vaf_vendor_alert
				WHERE protocol_id = 14
					AND type = 'F'

				IF NOT EXISTS (
						SELECT 1
						FROM vaf_vendor_alert_config
						WHERE [email] = @email
							AND protocol_id = 14
						)
				BEGIN
					SET @step = 7

					INSERT INTO [dbo].[vaf_vendor_alert_config] (
						alert_id
						,fac_id
						,protocol_id
						,[enabled]
						,email
						,message_profile_id
						)
					SELECT 111
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,14 protocol_id
						,1 AS [enabled]
						,@email
						,@message_profile_id
					
					UNION ALL
					
					SELECT 121
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,14 protocol_id
						,1 AS [enabled]
						,@email
						,@message_profile_id
					
					UNION ALL
					
					SELECT 198
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,14 protocol_id
						,1 AS [enabled]
						,@email
						,@message_profile_id
					
					UNION ALL
					
					SELECT 199
						,CASE 
							WHEN @multiFacility = 0
								THEN @facId
							ELSE - 1
							END AS fac_id
						,14 protocol_id
						,1 AS [enabled]
						,@email
						,@message_profile_id
				END

				SET @step = 8

				----SELECT @importFTPLocation
				EXEC [dbo].[sproc_msgVendor_dml_upsertEdiFtpLocations] @ftp_location_path = @importFTPLocation
					,@active = 1
					,@description = N'Dorado Eligibility Inbound'
					,@created_by = @created_by
					,@ftp_location_type = N'E'
					,@DebugMe = N'N'
					,@status_code = NULL
					,@status_text = NULL

				IF @DebugMe = 'Y'
					PRINT 'Dorado insert failure in step:' + convert(VARCHAR(3), @step) + '    ' + convert(VARCHAR(26), getdate(), 109)
			END

			COMMIT TRAN

			SET @sqlstring = ''
			SET @sqlstring = 'DECLARE @query nvarchar(max) 
	set @query = ''IF EXISTS(SELECT 1 FROM organization_parameter WHERE parameter_group = ''''ELIG_270_GROUP''''
				AND parameter_field = ''''eligibility_batch_run_day''''
				AND deleted = ''''N''''
				AND org_id = ''''' + CAST(@OrgId AS VARCHAR) + ''''' )
				BEGIN
					UPDATE organization_parameter
					SET parameter_value = ''''' + @parameter_value + '''''
					, revision_by = ''''' + @created_by + '''''
					, revision_date = ''''' + CAST(@created_date AS VARCHAR) + '''''
					WHERE parameter_group = ''''ELIG_270_GROUP''''
					AND parameter_field = ''''eligibility_batch_run_day''''
					AND deleted = ''''N''''
					AND org_id = ''''' + CAST(@OrgId AS VARCHAR) + 
				''''' 
				END
				ELSE
				BEGIN
					DECLARE @paramId integer
					SET @paramId = ISNULL((SELECT MAX(parameter_id) FROM organization_parameter),0)
					SET @paramId = @paramId + 1
					INSERT INTO [dbo].[organization_parameter]
						   ([parameter_id]
						   ,[created_by]
						   ,[created_date]
						   ,[deleted]
						   ,[org_id]
						   ,[parameter_group]
						   ,[parameter_field]
						   ,[parameter_label]
						   ,[parameter_value])
					 SELECT '''''''' + cast(@paramId as varchar) + '''''''' as [parameter_id]
						   ,''''' + @created_by + ''''' [created_by]
						   ,''''' + CAST(@created_date AS VARCHAR) + ''''' [created_date]
						   ,''''N'''' [deleted]
						   ,''''' + CAST(@OrgId AS VARCHAR) + ''''' [org_id]
						   ,''''ELIG_270_GROUP'''' [parameter_group]
						   ,''''eligibility_batch_run_day'''' [parameter_field]
						   ,''''Eligibility Batch Run Day'''' [parameter_label]
						   ,''''' + @parameter_value + 
				''''' [parameter_value]
				END''
				EXEC ' + @sessionServerName + '.' + @sessionDatabaseName + '.sys.sp_executesql @query		   '

			--PRINT @sqlstring
			EXEC sp_executesql @sqlstring
		END TRY

		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK TRAN

			SET @err = ''
			SET @err = 'Error in Dorado insert for ' + @Creator + ': ' + ERROR_MESSAGE()

			RAISERROR (
					@err
					,16
					,1
					)
		END CATCH

		IF (@status_text = 'Success')
		BEGIN
			----SET @status_code = 0
			----SET @status_text = 'Success'
			BEGIN TRY
				UPDATE facility
				SET location_status_id = (
						SELECT location_status_id
						-- select *
						FROM dbo.location_status WITH (NOLOCK)
						WHERE code = 'SETUP'
						)
				WHERE fac_id != 9001
					AND deleted = 'N'
					AND fac_id = @FacIdDest

				IF (coalesce(@EmailRecipients, '') <> '')
				BEGIN
					EXEC [operational].[sproc_SendNewFacilityEmail] @orgcode = @orgcode
						,@case_number = @Creator
						,@EmailRecipients = @EmailRecipients
						,@CreatedBy = @FacilityCreator
						,@TSServerName = @TSServerName
				END
			END TRY

			BEGIN CATCH
				SET @err = ''
				SET @err = 'Error ' + ': ' + ERROR_MESSAGE()

				RAISERROR (
						@err
						,16
						,1
						)
			END CATCH
		END

		SELECT @status_text AS sp_error_msg
			,@FacIdDest AS Fac_Id

		RETURN 0;
	END TRY

	BEGIN CATCH
		SET @status_text = ERROR_MESSAGE()

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION -- RollBack in case of Error

		IF @status_text <> ''
		BEGIN
			SET @status_text = CONCAT (
					OBJECT_NAME(@@PROCID)
					,' - '
					,' - '
					,'Status Text:-' + @status_text
					)

			SELECT @status_text AS sp_error_msg

			RETURN - 100;
		END
	END CATCH
END
GO

GRANT EXECUTE
	ON operational.sproc_CreateFacility
	TO PUBLIC
GO

GO

print 'K_Operational_Branch/5_StoredProcedures/US_Only/sproc_CreateFacility.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/US_Only/sproc_CreateFacility.sql',getdate(),'4.4.10_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/US_Only/sproc_list_FacilityUtilizationReport.sql',getdate(),'4.4.10_06_CLIENT_K_Operational_Branch_US.sql')

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


/*******************************************************************************
--	Jira #:									CORE-93138
--	
--	Written By:							Jaspreet Singh Bhogal
--
--	Script Type:							DML
--	Target DB Type:					CLIENT
--	Target ENVIRONMENT:		BOTH
--	Re-Runable:						YES
-- Original Jira #:						CORE-76004
--	Purpose:								This stored procedure is used to get facility utilization report for specific facility id.

e.g.

DECLARE	@return_value int

EXEC	@return_value = [operational].[sproc_list_FacilityUtilizationReport]
		@srcFacId = 1,
		@currentResident = N'N',
		@dischargeDate = NULL,
		@TSServerName = N'vmuspassvtsjob1.pccprod.local',
		@DebugMe = N'Y'

SELECT	'Return Value' = @return_value

*******************************************************************************/
IF EXISTS (
		SELECT 1
		FROM dbo.sysobjects
		WHERE id = object_id(N'[operational].[sproc_list_FacilityUtilizationReport]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
BEGIN
	DROP PROCEDURE [operational].[sproc_list_FacilityUtilizationReport]
END
GO

CREATE PROCEDURE [operational].[sproc_list_FacilityUtilizationReport] (
	@srcFacId INT
	,@currentResident CHAR(1) = 'N'
	,@dischargeDate DATETIME = NULL
	,@TSServerName VARCHAR(100)
	,@DebugMe CHAR(1) = 'N'
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @fac_name VARCHAR(75)
		,@count INT
		,@sqlstring NVARCHAR(max)
		,@step INT
		,@health_type VARCHAR(10)
		,@spacer CHAR(1)

	SET @TSServerName = QUOTENAME(@TSServerName)

	IF (object_id('tempdb..#results') IS NOT NULL)
		DROP TABLE #results

	IF (object_id('tempdb..#temp_Client', 'U') IS NOT NULL)
		DROP TABLE #temp_Client

	CREATE TABLE #results (
		facility_name VARCHAR(75)
		,fac_id INT
		,health_type VARCHAR(10)
		,application_function VARCHAR(100)
		,[enabled] VARCHAR(100)
		,table_count INT
		,additional_information VARCHAR(max)
		)

	CREATE TABLE #temp_Client (client_Id INT)

	SELECT @fac_name = [name]
		,@health_type = health_type
	FROM dbo.facility WITH (NOLOCK)
	WHERE fac_id = @srcFacId

	PRINT 'Client Usage Report for ' + replace(@fac_name, '''', '''''')

	BEGIN
		BEGIN
			SET @step = 72

			IF @DebugMe = 'Y'
				PRINT 'BEGIN STEP 72' + '	' + convert(VARCHAR(26), getdate())

			SET @count = 0

			SELECT @count = count(1)
			-- select *
			FROM dbo.facility WITH (NOLOCK)
			WHERE fac_id = @srcFacId

			SET @spacer = SPACE(1)

			IF (@count > 0)
			BEGIN
				INSERT INTO #results (
					facility_name
					,fac_id
					,health_type
					,application_function
					,[enabled]
					,table_count
					,additional_information
					)
				SELECT facility_name = @fac_name
					,fac_id = @srcFacId
					,health_type = @health_type
					,application_function = 'Facility Address'
					,[enabled] = coalesce(fac.inactive, 'Y')
					,table_count = coalesce(@count, 0)
					,additional_information = replace(replace(replace(replace((coalesce(fac.address1, '') + @spacer + coalesce(fac.address2, '') + ',' + coalesce(fac.city, '') + ',' + coalesce(fac.prov, '') + @spacer + coalesce(fac.pc, '') + ',' + coalesce(fac.tel, '')), '   ', ' '), '  ', ' '), ',,,', ','), ',,', ',')
				FROM dbo.facility fac WITH (NOLOCK)
				WHERE fac.fac_id = @srcFacId
			END

			IF (@CurrentResident = 'Y')
			BEGIN
				SET @sqlstring = 'SELECT client_id
						FROM dbo.clients
						WHERE fac_id = ' + cast(@srcFacId AS VARCHAR) + '
							AND deleted = ''N''
							AND isnull(discharge_date, ''' + cast(@dischargeDate AS VARCHAR) + ''') >= ''' + cast(@dischargeDate AS VARCHAR) + '''
							AND admission_date IS NOT NULL'
			END
			ELSE
			BEGIN
				SET @sqlstring = 'SELECT client_id
						FROM dbo.clients
						WHERE FAC_ID = ' + cast(@srcFacId AS VARCHAR) + '
							AND deleted = ''N'''
			END

			--PRINT @sqlstring
			SET @step = 1

			IF @DebugMe = 'Y'
				PRINT 'BEGIN STEP 1' + '	' + convert(VARCHAR(26), getdate())

			--print @sqlstring
			INSERT INTO #temp_client
			EXEC sp_executesql @sqlstring
				,N'@count INT OUTPUT'
				,@count = @count OUTPUT

			SELECT @count = count(1)
			FROM #temp_client

			SET @step = 2

			IF @DebugMe = 'Y'
				PRINT 'BEGIN STEP 2' + '	' + convert(VARCHAR(26), getdate())

			IF (@count > 0)
			BEGIN
				INSERT INTO #results (
					facility_name
					,application_function
					,[enabled]
					,table_count
					,additional_information
					)
				VALUES (
					@fac_name
					,'ResidentCount'
					,'Y'
					,@count
					,''
					)
			END
			ELSE
			BEGIN
				INSERT INTO #results (
					facility_name
					,application_function
					,[enabled]
					,table_count
					,additional_information
					)
				VALUES (
					@fac_name
					,'ResidentCount'
					,'N'
					,0
					,''
					)
			END
		END

		SET @step = 3

		IF @DebugMe = 'Y'
			PRINT 'BEGIN STEP 3' + '	' + convert(VARCHAR(26), getdate())

		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		SELECT @fac_name
			,'State Code'
			,prov
			,1
			,''
		FROM dbo.facility WITH (NOLOCK)
		WHERE fac_id = @srcFacId

		SET @step = 4

		IF @DebugMe = 'Y'
			PRINT 'BEGIN STEP 4' + '	' + convert(VARCHAR(26), getdate())

		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		SELECT @fac_name
			,NAME
			,VALUE
			,CASE 
				WHEN value = 'Y'
					THEN 1
				ELSE 0
				END
			,''
		FROM CONFIGURATION_PARAMETER
		WHERE NAME IN (
				'enable_res_photos'
				,'enable_emar'
				,'enable_mar'
				,'enable_poc'
				,'as_enable_mds_extverify'
				,'mds_automated_submission'
				)
			AND fac_id = @srcFacId

		SET @step = 5

		IF @DebugMe = 'Y'
			PRINT 'BEGIN STEP 5' + '	' + convert(VARCHAR(26), getdate())

		IF NOT EXISTS (
				SELECT 1
				FROM #results
				WHERE application_function = 'enable_emar'
				)
		BEGIN
			INSERT INTO #results (
				facility_name
				,application_function
				,[enabled]
				,table_count
				,additional_information
				)
			VALUES (
				@fac_name
				,'enable_emar'
				,'N'
				,0
				,''
				)
		END

		SET @step = 6

		IF @DebugMe = 'Y'
			PRINT 'BEGIN STEP 6' + '	' + convert(VARCHAR(26), getdate())

		IF NOT EXISTS (
				SELECT 1
				FROM #results
				WHERE application_function = 'enable_mar'
				)
		BEGIN
			INSERT INTO #results (
				facility_name
				,application_function
				,[enabled]
				,table_count
				,additional_information
				)
			VALUES (
				@fac_name
				,'enable_mar'
				,'N'
				,0
				,''
				)
		END

		SET @step = 7

		IF @DebugMe = 'Y'
			PRINT 'BEGIN STEP 7' + '	' + convert(VARCHAR(26), getdate())

		IF NOT EXISTS (
				SELECT *
				FROM #results
				WHERE application_function = 'enable_poc'
				)
		BEGIN
			INSERT INTO #results (
				facility_name
				,application_function
				,[enabled]
				,table_count
				,additional_information
				)
			VALUES (
				@fac_name
				,'enable_poc'
				,'N'
				,0
				,''
				)
		END

		SET @step = 8

		IF @DebugMe = 'Y'
			PRINT 'BEGIN STEP 8' + '	' + convert(VARCHAR(26), getdate())

		SELECT @count = count(1)
		FROM dbo.dcm_document_client
		WHERE EXISTS (
				SELECT 1
				FROM #temp_Client
				WHERE client_id = dcm_document_client.client_id
				)

		IF (@count > 0)
		BEGIN
			INSERT INTO #results (
				facility_name
				,application_function
				,[enabled]
				,table_count
				,additional_information
				)
			VALUES (
				@fac_name
				,'Document Manager'
				,'Y'
				,@count
				,''
				)
		END
		ELSE
		BEGIN
			INSERT INTO #results (
				facility_name
				,application_function
				,[enabled]
				,table_count
				,additional_information
				)
			VALUES (
				@fac_name
				,'Document Manager'
				,'N'
				,0
				,''
				)
		END

		SET @step = 9

		IF @DebugMe = 'Y'
			PRINT 'BEGIN STEP 9' + '	' + convert(VARCHAR(26), getdate())

		SELECT @count = count(1)
		FROM dbo.configuration_parameter
		WHERE NAME = 'enable_crm'
			AND value = 'Y'

		IF (@count > 0)
		BEGIN
			INSERT INTO #results (
				facility_name
				,application_function
				,[enabled]
				,table_count
				,additional_information
				)
			VALUES (
				@fac_name
				,'enable_crm'
				,'Y'
				,1
				,''
				)
		END
		ELSE
		BEGIN
			INSERT INTO #results (
				facility_name
				,application_function
				,[enabled]
				,table_count
				,additional_information
				)
			VALUES (
				@fac_name
				,'enable_crm'
				,'N'
				,0
				,''
				)
		END

		SET @step = 10

		IF @DebugMe = 'Y'
			PRINT 'BEGIN STEP 10' + '	' + convert(VARCHAR(26), getdate())

		SELECT @count = count(1)
		FROM facility f WITH (NOLOCK)
		JOIN message_profile mp WITH (NOLOCK) ON mp.fac_id = f.fac_id
		JOIN lib_message_profile lmp WITH (NOLOCK) ON mp.message_profile_id = lmp.message_profile_id
		WHERE f.deleted = 'N'
			AND f.fac_id = @srcFacId
			AND ISNULL(f.messages_enabled_flag, 'N') = 'Y'
			AND ISNULL(mp.is_enabled, 'N') = 'Y'
			AND lmp.vendor_code = 'COMS_Assessment'

		IF (@count > 0)
		BEGIN
			INSERT INTO #results (
				facility_name
				,application_function
				,[enabled]
				,table_count
				,additional_information
				)
			VALUES (
				@fac_name
				,'enable_COMS_Assessment(vendor_code)'
				,'Y'
				,1
				,''
				)
		END
		ELSE
		BEGIN
			INSERT INTO #results (
				facility_name
				,application_function
				,[enabled]
				,table_count
				,additional_information
				)
			VALUES (
				@fac_name
				,'enable_COMS_Assessment(vendor_code)'
				,'N'
				,0
				,''
				)
		END

		SET @step = 11

		IF @DebugMe = 'Y'
			PRINT 'BEGIN STEP 11' + '	' + convert(VARCHAR(26), getdate())

		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'Integration'
			,'Y'
			,1
			,(
				(
					SELECT (
							SELECT cm + '; '
							FROM (
								SELECT DISTINCT a.url AS 'cm'
								FROM dbo.pcc_ext_vendor_url_config a
								WHERE a.url <> 'pointclickcare.training.reliaslearning.com/lib/Authenticate.aspx?ReturnUrl=%2f'
								
								UNION
								
								SELECT DISTINCT b.value AS 'cm'
								FROM dbo.configuration_parameter b
								WHERE b.NAME = 'enable_cs_quick_link_url'
									AND b.value <> 'https://pointclickcare.training.reliaslearning.com/lib/Authenticate.aspx?ReturnUrl=%2f'
									AND b.value <> ''
									AND b.value IS NOT NULL
								) AS c
							FOR XML PATH('')
							)
					)
				)
			)

		SET @step = 12

		IF @DebugMe = 'Y'
			PRINT 'BEGIN STEP 12' + '	' + convert(VARCHAR(26), getdate())

		SELECT @count = count(1)
		FROM dbo.upload_files
		WHERE EXISTS (
				SELECT 1
				FROM #temp_Client
				WHERE client_id = upload_files.client_id
				)

		IF (@count > 0)
			INSERT INTO #results (
				facility_name
				,application_function
				,[enabled]
				,table_count
				,additional_information
				)
			VALUES (
				@fac_name
				,'Online Documentation'
				,'Y'
				,@count
				,''
				)
		ELSE
			INSERT INTO #results (
				facility_name
				,application_function
				,[enabled]
				,table_count
				,additional_information
				)
			VALUES (
				@fac_name
				,'Online Documentation'
				,'N'
				,0
				,''
				)

		SET @step = 13

		IF @DebugMe = 'Y'
			PRINT 'BEGIN STEP 13' + '	' + convert(VARCHAR(26), getdate())

		SELECT @count = count(1)
		FROM ar_transactions
		WHERE deleted = 'N'
			AND created_by <> '_system_'
			AND FAC_ID = @srcFacId
			AND (
				EXISTS (
					SELECT 1
					FROM #temp_Client
					WHERE client_id = ar_transactions.client_id
					)
				OR client_id IS NULL
				)

		--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end
		IF (@count > 0)
			INSERT INTO #results (
				facility_name
				,application_function
				,[enabled]
				,table_count
				,additional_information
				)
			VALUES (
				@fac_name
				,'BILLING'
				,'Y'
				,@count
				,''
				)
		ELSE
			INSERT INTO #results (
				facility_name
				,application_function
				,[enabled]
				,table_count
				,additional_information
				)
			VALUES (
				@fac_name
				,'BILLING'
				,'N'
				,0
				,''
				)
	END

	SET @step = 14

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 14' + '	' + convert(VARCHAR(26), getdate())

	SELECT @count = count(1)
	FROM dbo.census_item
	WHERE fac_id = @srcFacId
		AND deleted = 'N'
		AND EXISTS (
			SELECT 1
			FROM #temp_Client
			WHERE client_id = census_item.client_id
			)

	--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end
	IF (@count > 0)
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'CENSUS'
			,'Y'
			,@count
			,''
			)
	END
	ELSE
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'CENSUS'
			,'N'
			,0
			,''
			)
	END

	SET @step = 15

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 15' + '	' + convert(VARCHAR(26), getdate())

	SELECT @count = count(1)
	FROM work_activity
	WHERE fac_id = @srcFacId
		AND deleted = 'N'
		AND (
			EXISTS (
				SELECT 1
				FROM #temp_Client
				WHERE client_id = work_activity.client_id
				)
			OR client_id IS NULL
			)

	SET @step = 16

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 16' + '	' + convert(VARCHAR(26), getdate())

	IF (@count > 0)
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'COLLECTIONS'
			,'Y'
			,@count
			,''
			)
	END
	ELSE
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'COLLECTIONS'
			,'N'
			,0
			,''
			)
	END

	SET @step = 17

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 17' + '	' + convert(VARCHAR(26), getdate())

	SELECT @count = count(1)
	FROM ta_transaction
	WHERE fac_id = @srcFacId
		AND deleted = 'N'
		--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, start
		AND (
			EXISTS (
				SELECT 1
				FROM #temp_Client
				WHERE client_id = ta_transaction.client_id
				)
			OR client_id IS NULL
			)

	IF (@count > 0)
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'TRUST'
			,'Y'
			,@count
			,''
			)
	END
	ELSE
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'TRUST'
			,'N'
			,0
			,''
			)
	END

	SET @step = 18

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 18' + '	' + convert(VARCHAR(26), getdate())

	SELECT @count = count(1)
	FROM inc_incident
	WHERE fac_id = @srcFacId
		AND deleted = 'N'
		AND EXISTS (
			SELECT 1
			FROM #temp_Client
			WHERE client_id = inc_incident.client_id
			)

	IF (@count > 0)
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'RISK MANAGEMENT'
			,'Y'
			,@count
			,''
			)
	END
	ELSE
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'RISK MANAGEMENT'
			,'N'
			,0
			,''
			)
	END

	SET @step = 19

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 19' + '	' + convert(VARCHAR(26), getdate())

	SELECT @count = count(1)
	FROM as_assessment
	WHERE fac_id = @srcfacid
		AND std_assess_id = 1
		AND deleted = 'N'
		AND EXISTS (
			SELECT 1
			FROM #temp_Client
			WHERE client_id = as_assessment.client_id
			)

	IF (@count > 0)
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'MDS 2.0'
			,'Y'
			,@count
			,''
			)
	END
	ELSE
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'MDS 2.0'
			,'N'
			,0
			,''
			)
	END

	SET @step = 20

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 20' + '	' + convert(VARCHAR(26), getdate())

	SELECT @count = count(1)
	FROM as_assessment
	WHERE fac_id = @srcfacid
		AND std_assess_id = 11
		AND deleted = 'N'
		AND EXISTS (
			SELECT 1
			FROM #temp_Client
			WHERE client_id = as_assessment.client_id
			)

	IF (@count > 0)
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'MDS 3.0'
			,'Y'
			,@count
			,''
			)
	END
	ELSE
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'MDS 3.0'
			,'N'
			,0
			,''
			)
	END

	SET @step = 21

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 21' + '	' + convert(VARCHAR(26), getdate())

	SELECT @count = count(1)
	FROM as_assessment
	WHERE fac_id = @srcfacid
		AND std_assess_id = 7
		AND deleted = 'N'
		AND EXISTS (
			SELECT 1
			FROM #temp_Client
			WHERE client_id = as_assessment.client_id
			)

	IF (@count > 0)
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'MMQ-Massachusetts'
			,'Y'
			,@count
			,''
			)
	END
	ELSE
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'MMQ-Massachusetts'
			,'N'
			,0
			,''
			)
	END

	SET @step = 22

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 22' + '	' + convert(VARCHAR(26), getdate())

	SELECT @count = count(1)
	FROM as_assessment
	WHERE fac_id = @srcfacid
		AND std_assess_id IN (
			8
			,12
			)
		AND deleted = 'N'
		AND EXISTS (
			SELECT 1
			FROM #temp_Client
			WHERE client_id = as_assessment.client_id
			)

	IF (@count > 0)
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'MMA-Maryland'
			,'Y'
			,@count
			,''
			)
	END
	ELSE
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'MMA-Maryland'
			,'N'
			,0
			,''
			)
	END

	SET @step = 23

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 23' + '	' + convert(VARCHAR(26), getdate())

	--non-System UDA
	SELECT @count = count(1)
	FROM as_assessment
	WHERE fac_id = @srcfacid
		AND std_assess_id NOT IN (
			1
			,11
			)
		AND std_assess_id NOT IN (
			SELECT std_assess_id
			FROM as_std_assessment_system_assessment_mapping
			)
		AND client_id <> '-9999'
		AND deleted = 'N'
		AND EXISTS (
			SELECT 1
			FROM #temp_Client
			WHERE client_id = as_assessment.client_id
			)

	IF (@count > 0)
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'CUSTOM UDA''s'
			,'Y'
			,@count
			,''
			)
	END
	ELSE
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'CUSTOM UDA''s'
			,'N'
			,0
			,''
			)
	END

	SET @step = 24

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 24' + '	' + convert(VARCHAR(26), getdate())

	--System UDA
	SELECT @count = count(1)
	FROM as_assessment
	WHERE fac_id = @srcfacid
		AND std_assess_id NOT IN (
			1
			,11
			)
		AND std_assess_id IN (
			SELECT std_assess_id
			FROM as_std_assessment_system_assessment_mapping
			)
		AND client_id <> '-9999'
		AND deleted = 'N'
		AND EXISTS (
			SELECT 1
			FROM #temp_Client
			WHERE client_id = as_assessment.client_id
			)

	IF (@count > 0)
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'System  UDA''s'
			,'Y'
			,@count
			,(
				SELECT DISTINCT stdasmnt.[description] + ', '
				FROM as_std_assessment_system_assessment_mapping asmntmap
				JOIN as_std_assessment stdasmnt ON stdasmnt.std_assess_id = asmntmap.std_assess_id
				JOIN as_assessment asmnt ON asmnt.std_assess_id = stdasmnt.std_assess_id
				WHERE asmnt.client_id <> - 9999
					AND asmnt.fac_id = @srcFacId
					AND EXISTS (
						SELECT 1
						FROM #temp_Client
						WHERE client_id = asmnt.client_id
						)
				FOR XML PATH('')
				)
			)
	END
	ELSE
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'System UDA''s'
			,'N'
			,0
			,(
				SELECT DISTINCT stdasmnt.description + ', '
				FROM as_std_assessment_system_assessment_mapping asmntmap
				JOIN as_std_assessment stdasmnt ON asmntmap.std_assess_id = stdasmnt.std_assess_id
				JOIN as_assessment asmnt ON asmnt.std_assess_id = asmntmap.std_assess_id
				WHERE asmnt.client_id <> - 9999
					AND asmnt.fac_id = @srcFacId --
					AND EXISTS (
						SELECT 1
						FROM #temp_Client
						WHERE client_id = asmnt.client_id
						)
				FOR XML PATH('')
				)
			)
	END

	SET @step = 25

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 25' + '	' + convert(VARCHAR(26), getdate())

	SELECT @count = count(1)
	FROM as_assessment
	WHERE FAC_ID = @srcFacId
		AND std_assess_id IN (
			SELECT std_assess_id
			FROM as_std_assessment
			WHERE description LIKE '%PCC Skin & Wound%'
				AND deleted = 'N'
				AND STATUS = 'A'
				AND std_assess_id IN (
					SELECT std_assess_id
					FROM as_std_assessment_system_assessment_mapping
					)
			)
		AND client_id <> '-9999'
		AND EXISTS (
			SELECT 1
			FROM #temp_Client
			WHERE client_id = as_assessment.client_id
			)

	IF (@count > 0)
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'SKIN and WOUND'
			,'Y'
			,@count
			,''
			)
	END
	ELSE
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'SKIN and WOUND'
			,'N'
			,0
			,''
			)
	END

	SET @step = 26

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 26' + '	' + convert(VARCHAR(26), getdate())

	SELECT @count = count(1)
	FROM wv_vitals
	WHERE fac_id = @srcFacId
		AND EXISTS (
			SELECT 1
			FROM #temp_Client
			WHERE client_id = wv_vitals.client_id
			)

	IF (@count > 0)
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'WEIGHTS AND VITALS'
			,'Y'
			,@count
			,''
			)
	END
	ELSE
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'WEIGHTS AND VITALS'
			,'N'
			,0
			,''
			)
	END

	SET @step = 27

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 27' + '	' + convert(VARCHAR(26), getdate())

	SELECT @count = count(1)
	FROM diagnosis
	WHERE fac_id = @srcFacId
		AND deleted = 'N'
		AND EXISTS (
			SELECT 1
			FROM #temp_Client
			WHERE client_id = diagnosis.client_id
			)

	IF (@count > 0)
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'DIAGNOSIS'
			,'Y'
			,@count
			,''
			)
	END
	ELSE
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'DIAGNOSIS'
			,'N'
			,0
			,''
			)
	END

	SET @step = 28

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 28' + '	' + convert(VARCHAR(26), getdate())

	SELECT @count = count(1)
	FROM cr_alert
	WHERE fac_id = @srcFacId
		AND deleted = 'N'
		AND EXISTS (
			SELECT 1
			FROM #temp_Client
			WHERE client_id = cr_alert.client_id
			)

	IF (@count > 0)
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'ALERTS'
			,'Y'
			,@count
			,''
			)
	END
	ELSE
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'ALERTS'
			,'N'
			,0
			,''
			)
	END

	SET @step = 29

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 29' + '	' + convert(VARCHAR(26), getdate())

	SELECT @count = count(1)
	FROM cr_client_immunization
	WHERE fac_id = @srcFacId
		AND deleted = 'N'
		AND EXISTS (
			SELECT 1
			FROM #temp_Client
			WHERE client_id = cr_client_immunization.client_id
			)

	IF (@count > 0)
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'IMMUNIZATION'
			,'Y'
			,@count
			,''
			)
	END
	ELSE
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'IMMUNIZATION'
			,'N'
			,0
			,''
			)
	END

	SET @step = 30

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 30' + '	' + convert(VARCHAR(26), getdate())

	SELECT @count = count(1)
	FROM pho_phys_order
	WHERE fac_id = @srcFacId
		AND EXISTS (
			SELECT 1
			FROM #temp_Client
			WHERE client_id = pho_phys_order.client_id
			)

	IF (@count > 0)
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'PHYSICIAN ORDERS'
			,'Y'
			,@count
			,''
			)
	END
	ELSE
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'PHYSICIAN ORDERS'
			,'N'
			,0
			,''
			)
	END

	SET @step = 31

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 31' + '	' + convert(VARCHAR(26), getdate())

	SELECT @count = count(1)
	FROM pn_progress_note
	WHERE fac_id = @srcFacId
		AND deleted = 'N'
		AND EXISTS (
			SELECT 1
			FROM #temp_Client
			WHERE client_id = pn_progress_note.client_id
			)

	IF (@count > 0)
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'PROGRESS NOTES'
			,'Y'
			,@count
			,''
			)
	END
	ELSE
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'PROGRESS NOTES'
			,'N'
			,0
			,''
			)
	END

	SET @step = 32

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 32' + '	' + convert(VARCHAR(26), getdate())

	SELECT @count = count(1)
	FROM care_plan
	WHERE fac_id = @srcFacId
		AND deleted = 'N'
		AND EXISTS (
			SELECT 1
			FROM #temp_Client
			WHERE client_id = care_plan.client_id
			)

	IF (@count > 0)
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'CARE PLANS'
			,'Y'
			,@count
			,''
			)
	END
	ELSE
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'CARE PLANS'
			,'N'
			,0
			,''
			)
	END

	SET @step = 33

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 33' + '	' + convert(VARCHAR(26), getdate())

	SELECT @count = count(1)
	FROM qa_activity ---WHERE FAC_ID = @srcFacId

	IF (@count > 0)
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'QIA'
			,'Y'
			,@count
			,''
			)
	END
	ELSE
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'QIA'
			,'N'
			,0
			,''
			)
	END

	SET @step = 34

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 34' + '	' + convert(VARCHAR(26), getdate())

	SELECT @count = count(1)
	FROM gl_transactions
	WHERE fac_id = @srcFacId
		AND deleted = 'N'

	IF (@count > 0)
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'GENERAL LEDGER'
			,'Y'
			,@count
			,''
			)
	END
	ELSE
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'GENERAL LEDGER'
			,'N'
			,0
			,''
			)
	END

	SET @step = 35

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 35' + '	' + convert(VARCHAR(26), getdate())

	SELECT @count = count(1)
	FROM ap_transactions
	WHERE FAC_ID = @srcFacId
		AND deleted = 'N'

	IF (@count > 0)
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'ACCOUNTS PAYABLE'
			,'Y'
			,@count
			,''
			)
	END
	ELSE
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'ACCOUNTS PAYABLE'
			,'N'
			,0
			,''
			)
	END

	SET @step = 36

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 36' + '	' + convert(VARCHAR(26), getdate())

	SELECT @count = count(1)
	FROM crm_inquiry
	WHERE admitting_fac_id = @srcFacId
		AND deleted = 'N'

	IF (@count > 0)
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'MARKETING/IRM'
			,'Y'
			,@count
			,''
			)
	END
	ELSE
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'MARKETING/IRM'
			,'N'
			,0
			,''
			)
	END

	SET @step = 37

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 37' + '	' + convert(VARCHAR(26), getdate())

	SELECT @count = count(1)
	FROM cp_qshift_detail
	WHERE fac_id = @srcFacId
		AND fac_id IN (
			SELECT fac_id
			FROM configuration_parameter
			WHERE NAME = 'enable_poc'
				AND value = 'Y'
			)
		AND schedule_id IN (
			SELECT schedule_id
			FROM cp_schedule
			WHERE intervention_id IN (
					SELECT gen_intervention_id
					FROM cp_rev_intervention
					WHERE EXISTS (
							SELECT 1
							FROM #temp_Client
							WHERE client_Id = cp_rev_intervention.clientID
							)
					)
			)

	IF (@count > 0)
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'POC MODULE'
			,'Y'
			,@count
			,''
			)
	END
	ELSE
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'POC MODULE'
			,'N'
			,0
			,''
			)
	END

	SET @step = 38

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 38' + '	' + convert(VARCHAR(26), getdate())

	SELECT @count = count(1)
	FROM user_defined_data
	WHERE fac_id = @srcFacId
		AND deleted = 'N'
		AND EXISTS (
			SELECT 1
			FROM #temp_Client
			WHERE client_id = user_defined_data.client_id
			)

	IF (@count > 0)
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'USER_DEFINED_DATA'
			,'Y'
			,@count
			,''
			)
	END
	ELSE
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'USER_DEFINED_DATA'
			,'N'
			,0
			,''
			)
	END

	SET @step = 39

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 39' + '	' + convert(VARCHAR(26), getdate())

	SELECT @count = count(1)
	FROM result_order_source
	WHERE result_type_id = 1 ---Laboratory --updated by Rina 2/22
		AND fac_id = @srcFacId
		AND EXISTS (
			SELECT 1
			FROM #temp_Client
			WHERE client_id = result_order_source.client_id
			)

	IF (@count > 0)
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'LAB RESULT'
			,'Y'
			,@count
			,''
			)
	END
	ELSE
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'LAB RESULT'
			,'N'
			,0
			,''
			)
	END

	SET @step = 40

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 40' + '	' + convert(VARCHAR(26), getdate())

	SELECT @count = count(1)
	FROM dbo.result_order_source
	WHERE result_type_id = 2 --Radiology
		AND fac_id = @srcFacId
		AND EXISTS (
			SELECT 1
			FROM #temp_Client
			WHERE client_id = result_order_source.client_id
			)

	IF (@count > 0)
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'Radiology RESULT'
			,'Y'
			,@count
			,''
			)
	END
	ELSE
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'Radiology RESULT'
			,'N'
			,0
			,''
			)
	END

	SET @step = 41

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 41' + '	' + convert(VARCHAR(26), getdate())

	SELECT @count = count(1)
	FROM dbo.admin_note WITH (NOLOCK)
	WHERE client_id IN (
			SELECT client_id
			FROM clients WITH (NOLOCK)
			WHERE fac_id = @srcFacId
				AND deleted = 'N'
				AND isnull(discharge_date, @dischargeDate) >= @dischargeDate
				AND admission_date IS NOT NULL
			)

	--Added by Linlin Jing, Date: 2018-03-02, Reason: SmartSheet - DShelper&OtherDevelopment - Row137, end		
	IF (@count > 0)
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'NOTES'
			,'Y'
			,@count
			,''
			)
	END
	ELSE
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'NOTES'
			,'N'
			,0
			,''
			)
	END

	SET @step = 42

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 42' + '	' + convert(VARCHAR(26), getdate())

	SELECT @count = count(1)
	FROM dbo.configuration_parameter
	WHERE FAC_ID = @srcFacId
		AND NAME = 'care_pathway_module'
		AND value = 'Y'

	IF (@count > 0)
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'Care Pathway'
			,'Y'
			,@count
			,''
			)
	END
	ELSE
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'Care Pathway'
			,'N'
			,0
			,''
			)
	END

	SET @step = 43

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 43' + '	' + convert(VARCHAR(26), getdate())

	INSERT INTO #results (
		facility_name
		,application_function
		,[enabled]
		,table_count
		,additional_information
		)
	SELECT DISTINCT ''
		,'Message Vendor Setup'
		,'Y'
		,1
		,''
	FROM facility f WITH (NOLOCK)
	LEFT JOIN message_profile mp WITH (NOLOCK) ON mp.fac_id = f.fac_id --AND mp.deleted = 'N'
	LEFT JOIN map_identifier mi WITH (NOLOCK) ON mi.fac_id = f.fac_id --AND mi.vendor_code = mp.vendor_code
	WHERE f.deleted = 'N'
		AND f.fac_id = @srcFacId
		AND ISNULL(f.messages_enabled_flag, 'N') = 'Y'

	SET @step = 44

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 44' + '	' + convert(VARCHAR(26), getdate())

	INSERT INTO #results (
		facility_name
		,application_function
		,[enabled]
		,table_count
		,additional_information
		)
	SELECT DISTINCT ''
		,'Third Party Education'
		,'Y'
		,1
		,''
	FROM facility f WITH (NOLOCK)
	LEFT JOIN configuration_parameter educ1 WITH (NOLOCK) ON educ1.fac_id = f.fac_id
		AND educ1.[name] = 'mds3_education_username'
	LEFT JOIN configuration_parameter educ2 WITH (NOLOCK) ON educ2.fac_id = f.fac_id
		AND educ2.[name] = 'mds3_education_password'
	WHERE f.deleted = 'N'
		AND f.fac_id = @srcFacId
		AND len(ISNULL(educ1.[value], '')) > 0

	SET @step = 45

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 45' + '	' + convert(VARCHAR(26), getdate())

	INSERT INTO #results (
		facility_name
		,application_function
		,[enabled]
		,table_count
		,additional_information
		)
	SELECT DISTINCT ''
		,'Third Party MDS Data'
		,'Y'
		,1
		,''
	FROM facility f WITH (NOLOCK)
	LEFT JOIN as_vendor_configuration mdsdata WITH (NOLOCK) ON mdsdata.fac_id = f.fac_id
		AND std_assess_id = 11
		AND mdsdata.deleted = 'N'
	WHERE f.deleted = 'N'
		AND f.fac_id = @srcFacId
		AND len(ISNULL(mdsdata.username, '')) > 0

	SET @step = 46

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 46' + '	' + convert(VARCHAR(26), getdate())

	INSERT INTO #results (
		facility_name
		,application_function
		,[enabled]
		,table_count
		,additional_information
		)
	SELECT DISTINCT ''
		,'Third Party MDS Verification'
		,'Y'
		,1
		,''
	FROM facility f WITH (NOLOCK)
	LEFT JOIN as_submission_accounts_mds_30 mdsverification WITH (NOLOCK) ON mdsverification.fac_id = f.fac_id
		AND mdsverification.account_type = 'V'
	WHERE f.deleted = 'N'
		AND f.fac_id = @srcFacId
		AND mdsverification.STATUS = 1

	SET @step = 47

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 47' + '	' + convert(VARCHAR(26), getdate())

	INSERT INTO #results (
		facility_name
		,application_function
		,[enabled]
		,table_count
		,additional_information
		)
	SELECT DISTINCT ''
		,'ROX Reports'
		,'Y'
		,1
		,''
	FROM facility f WITH (NOLOCK)
	LEFT JOIN configuration_parameter rox_enabled WITH (NOLOCK) ON rox_enabled.fac_id = f.fac_id
		AND rox_enabled.[name] = 'enable_rox_reports'
	LEFT JOIN configuration_parameter rox_vendor_code WITH (NOLOCK) ON rox_vendor_code.fac_id = f.fac_id
		AND rox_vendor_code.[name] = 'rox_vendor_code'
	LEFT JOIN configuration_parameter rox_interested_party WITH (NOLOCK) ON rox_interested_party.fac_id = f.fac_id
		AND rox_interested_party.[name] = 'rox_interested_party'
	LEFT JOIN configuration_parameter rox_organization WITH (NOLOCK) ON rox_organization.fac_id = f.fac_id
		AND rox_organization.[name] = 'rox_organization'
	LEFT JOIN configuration_parameter rox_url WITH (NOLOCK) ON rox_url.fac_id = f.fac_id
		AND rox_url.[name] = 'rox_url'
	LEFT JOIN configuration_parameter rox_username WITH (NOLOCK) ON rox_username.fac_id = f.fac_id
		AND rox_username.[name] = 'rox_username'
	LEFT JOIN configuration_parameter rox_password WITH (NOLOCK) ON rox_password.fac_id = f.fac_id
		AND rox_password.[name] = 'rox_password'
	WHERE f.deleted = 'N'
		AND f.fac_id = @srcFacId
		AND ISNULL(rox_enabled.[value], 'N') = 'Y'

	SET @step = 48

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 48' + '	' + convert(VARCHAR(26), getdate())

	INSERT INTO #results (
		facility_name
		,application_function
		,[enabled]
		,table_count
		,additional_information
		)
	SELECT DISTINCT ''
		,'IRM-ecin'
		,'Y'
		,1
		,''
	FROM facility f WITH (NOLOCK)
	LEFT JOIN crm_configuration config WITH (NOLOCK) ON config.fac_id = f.fac_id
	LEFT JOIN crm_integration_option ecin WITH (NOLOCK) ON ecin.[name] = 'ecin'
		AND ecin.enabled = 'Y'
	LEFT JOIN crm_integration_option sims WITH (NOLOCK) ON sims.[name] = 'sims'
		AND sims.enabled = 'Y'
	LEFT JOIN crm_integration_option curaspan WITH (NOLOCK) ON curaspan.[name] = 'curaspan'
		AND curaspan.enabled = 'Y'
	LEFT JOIN (
		SELECT intake_process_flag
		FROM crm_configuration WITH (NOLOCK)
		WHERE fac_id = 9001
		) intake ON 1 = 1
	WHERE f.deleted = 'N'
		AND f.fac_id = @srcFacId
		AND ecin.enabled = 'Y'

	SET @step = 49

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 49' + '	' + convert(VARCHAR(26), getdate())

	INSERT INTO #results (
		facility_name
		,application_function
		,[enabled]
		,table_count
		,additional_information
		)
	SELECT DISTINCT ''
		,'IRM-sims'
		,'Y'
		,1
		,''
	FROM facility f WITH (NOLOCK)
	LEFT JOIN crm_configuration config WITH (NOLOCK) ON config.fac_id = f.fac_id
	LEFT JOIN crm_integration_option ecin WITH (NOLOCK) ON ecin.[name] = 'ecin'
		AND ecin.enabled = 'Y'
	LEFT JOIN crm_integration_option sims WITH (NOLOCK) ON sims.[name] = 'sims'
		AND sims.enabled = 'Y'
	LEFT JOIN crm_integration_option curaspan WITH (NOLOCK) ON curaspan.[name] = 'curaspan'
		AND curaspan.enabled = 'Y'
	LEFT JOIN (
		SELECT intake_process_flag
		FROM crm_configuration WITH (NOLOCK)
		WHERE fac_id = 9001
		) intake ON 1 = 1
	WHERE f.deleted = 'N'
		AND f.fac_id = @srcFacId
		AND sims.enabled = 'Y'

	SET @step = 50

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 50' + '	' + convert(VARCHAR(26), getdate())

	DECLARE @environment VARCHAR(23)
		,@isPublished VARCHAR(1)

	SET @sqlstring = 'SELECT @environment = environment
							FROM ' + @TSServerName + '.ds_tasks.[dbo].[TS_global_organization_master]
							WHERE orgcode = replace(REPLACE(db_name(), ''us_'', ''''), ''_multi'', '''')'

	EXEC sp_executesql @sqlstring
		,N'@environment varchar(23) OUTPUT'
		,@environment OUTPUT

	SET @sqlstring = 'IF EXISTS(SELECT 1
							FROM master.sys.databases
							WHERE name = db_name()
							AND is_published = 1)
							BEGIN
								SET @isPublished = ''Y''
							END
							ELSE
							BEGIN
								SET @isPublished = ''N''
							END
							'

	EXEC sp_executesql @sqlstring
		,N'@isPublished VARCHAR(1) OUTPUT'
		,@isPublished OUTPUT

	INSERT INTO #results (
		facility_name
		,application_function
		,[enabled]
		,table_count
		,additional_information
		)
	SELECT @fac_name
		,'RRDB'
		,@isPublished AS rrdb
		,'0'
		,''

	SET @step = 51

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 51' + '	' + convert(VARCHAR(26), getdate())

	DECLARE @orgcode VARCHAR(10)
		,@integraphUsers VARCHAR(1) = ''

	SELECT @orgcode = replace(REPLACE(db_name(), 'us_', ''), '_multi', '')

	IF (
			@orgcode IN (
				'GULF'
				,'GSS'
				,'EFS'
				,'CHG'
				,'HCR'
				)
			)
	BEGIN
		SET @integraphUsers = 'Y'
	END

	INSERT INTO #results (
		facility_name
		,application_function
		,[enabled]
		,table_count
		,additional_information
		)
	SELECT @fac_name
		,'INGRAPH USERS'
		,@integraphUsers AS IntegraphUsers
		,'0'
		,''

	SET @step = 53

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 53' + '	' + convert(VARCHAR(26), getdate())

	INSERT INTO #results (
		facility_name
		,application_function
		,[enabled]
		,table_count
		,additional_information
		)
	SELECT @fac_name
		,'Environment'
		,substring(@environment, charindex('_', @environment) + 1, len(@environment)) AS db_env
		,'0'
		,''

	SET @step = 54

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 54' + '	' + convert(VARCHAR(26), getdate())

	INSERT INTO #results (
		facility_name
		,application_function
		,[enabled]
		,table_count
		,additional_information
		)
	SELECT @fac_name
		,'History db'
		,NAME
		,'1'
		,''
	FROM sys.databases
	WHERE NAME LIKE '%' + db_name() + '%history%'

	SET @step = 55

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 55' + '	' + convert(VARCHAR(26), getdate())

	SET @sqlstring = 'SELECT @count = count(1)
			FROM ' + @TSServerName + '.ds_tasks.[dbo].[MDS3_Extract_323903_Parameter]
			WHERE process_name = ''dailyMDS3Extract_Providigm''
				AND [enabled] = ''Y''
				AND Org_Code = replace(REPLACE(db_name(), ''us_'', ''''), ''_multi'', '''')
				AND (
							fac_ids LIKE ''%,' + CONVERT(VARCHAR, @srcFacId) + ',%''
							OR fac_ids LIKE ''' + CONVERT(VARCHAR, @srcFacId) + ',%''
							OR fac_ids LIKE ''%,' + CONVERT(VARCHAR, @srcFacId) + '''
							OR fac_ids = ''' + CONVERT(VARCHAR, @srcFacId) + '''
							OR ISNULL(fac_ids, null) = null
						)'

	----PRINT @sqlstring
	EXEC sp_executesql @sqlstring
		,N'@count INT OUTPUT'
		,@count = @count OUTPUT

	IF (@count > 0)
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'Providigm MDS3 Extract'
			,'Y'
			,@count
			,''
			)
	END
	ELSE
	BEGIN
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		VALUES (
			@fac_name
			,'Providigm MDS3 Extract'
			,'N'
			,0
			,''
			)
	END

	BEGIN
		SET @step = 56

		IF @DebugMe = 'Y'
			PRINT 'BEGIN STEP 56' + '	' + convert(VARCHAR(26), getdate())

		IF (Object_ID('TempDB..#TEMP_RESULTS') IS NOT NULL)
			DROP TABLE #TEMP_RESULTS

		CREATE TABLE #TEMP_RESULTS (
			FACILITY_NAME VARCHAR(75)
			,APPLICATION_FUNCTION VARCHAR(100)
			,ENABLED VARCHAR(100)
			,TABLE_COUNT INT
			,ADDITIONAL_INFORMATION VARCHAR(MAX)
			)

		--Align Extract
		IF replace(REPLACE(db_name(), 'us_', ''), '_multi', '') = 'NYE'
		BEGIN
			SELECT @count = count(1)
			FROM [pcc_temp_storage].[dbo].[Align_897044_NYE_Parameter]
			WHERE (
					fac_ids LIKE '%,' + CONVERT(VARCHAR, @srcFacId) + ',%'
					OR fac_ids LIKE CONVERT(VARCHAR, @srcFacId) + ',%'
					OR fac_ids LIKE '%,' + CONVERT(VARCHAR, @srcFacId)
					OR fac_ids = CONVERT(VARCHAR, @srcFacId)
					OR fac_ids IS NULL
					OR fac_ids = 'null'
					)
		END

		IF replace(REPLACE(db_name(), 'us_', ''), '_multi', '') = 'FRC'
		BEGIN
			SELECT @count = count(*)
			FROM [pcc_temp_storage].[dbo].[Align_897044_FRC_Parameter]
			WHERE (
					fac_ids LIKE '%,' + CONVERT(VARCHAR, @srcFacId) + ',%'
					OR fac_ids LIKE CONVERT(VARCHAR, @srcFacId) + ',%'
					OR fac_ids LIKE '%,' + CONVERT(VARCHAR, @srcFacId)
					OR fac_ids = CONVERT(VARCHAR, @srcFacId)
					OR fac_ids IS NULL
					OR fac_ids = 'null'
					)
		END

		IF replace(REPLACE(db_name(), 'us_', ''), '_multi', '') <> 'FRC'
			AND replace(REPLACE(db_name(), 'us_', ''), '_multi', '') <> 'NYE'
		BEGIN
			SET @sqlstring = 'SELECT @count = count(1)
				FROM ' + @TSServerName + '.[ds_tasks].[dbo].[Align_Job_Parameters]
				WHERE deleted = ''N''
					AND Org_Code = replace(REPLACE(db_name(), ''us_'', ''''), ''_multi'', '''')
					AND (
						fac_ids LIKE ''%,' + CONVERT(VARCHAR, @srcFacId) + ',%''
						OR fac_ids LIKE ''' + CONVERT(VARCHAR, @srcFacId) + ',%''
						OR fac_ids LIKE ''%,' + CONVERT(VARCHAR, @srcFacId) + '''
						OR fac_ids = ''' + CONVERT(VARCHAR, @srcFacId) + '''
						OR fac_ids IS NULL
						OR fac_ids = NULL
						)'

			EXEC sp_executesql @sqlstring
				,N'@count INT OUTPUT'
				,@count = @count OUTPUT
		END

		IF (@count > 0)
		BEGIN
			INSERT INTO #TEMP_RESULTS
			VALUES (
				@fac_name
				,'Custom Extract Vendor'
				,'Y'
				,0
				,'Align'
				)
		END

		SET @step = 57

		IF @DebugMe = 'Y'
			PRINT 'BEGIN STEP 57' + '	' + convert(VARCHAR(26), getdate())

		--First Quality Extract
		SET @sqlstring = 'SELECT @count = count(1)
			FROM ' + @TSServerName + '.[ds_tasks].[dbo].[First_Quality_Job_Parameters_New_Format]
			WHERE deleted = ''N''
				AND Org_Code = replace(REPLACE(db_name(), ''us_'', ''''), ''_multi'', '''')
				AND (
					fac_ids LIKE ''%,' + CONVERT(VARCHAR, @srcFacId) + ',%''
					OR fac_ids LIKE ''' + CONVERT(VARCHAR, @srcFacId) + ',%''
					OR fac_ids LIKE ''%,' + CONVERT(VARCHAR, @srcFacId) + '''
					OR fac_ids = ''' + CONVERT(VARCHAR, @srcFacId) + '''
					OR fac_ids IS NULL
					OR fac_ids = ''NULL''
					)'

		EXEC sp_executesql @sqlstring
			,N'@count INT OUTPUT'
			,@count = @count OUTPUT

		IF (@count > 0)
		BEGIN
			INSERT INTO #TEMP_RESULTS
			VALUES (
				@fac_name
				,'Custom Extract Vendor'
				,'Y'
				,0
				,'First Quality'
				)
		END

		SET @step = 58

		IF @DebugMe = 'Y'
			PRINT 'BEGIN STEP 58' + '	' + convert(VARCHAR(26), getdate())

		--Abaqis Extract
		SET @sqlstring = 'SELECT @count = count(1)
			FROM ' + @TSServerName + '.[ds_tasks].[dbo].[MDS3_Extract_323903_Parameter]
			WHERE Process_Name = ''dailyMDS3Extract_Providigm''
				AND Enabled = ''Y''
				AND Org_Code = replace(REPLACE(db_name(), ''us_'', ''''), ''_multi'', '''')
				AND (
					fac_ids LIKE ''%,' + CONVERT(VARCHAR, @srcFacId) + ',%''
					OR fac_ids LIKE ''' + CONVERT(VARCHAR, @srcFacId) + ',%''
					OR fac_ids LIKE ''%,' + CONVERT(VARCHAR, @srcFacId) + '''
					OR fac_ids = ''' + CONVERT(VARCHAR, @srcFacId) + '''
					OR fac_ids IS NULL
					OR fac_ids = NULL
					)'

		EXEC sp_executesql @sqlstring
			,N'@count INT OUTPUT'
			,@count = @count OUTPUT

		IF (@count > 0)
		BEGIN
			INSERT INTO #TEMP_RESULTS
			VALUES (
				@fac_name
				,'Custom Extract Vendor'
				,'Y'
				,0
				,'Abaqis'
				)
		END

		SET @step = 59

		IF @DebugMe = 'Y'
			PRINT 'BEGIN STEP 59' + '	' + convert(VARCHAR(26), getdate())

		-- 'Custom Extract Vendor'
		SET @sqlstring = 'SELECT @count = count(1)
			FROM ' + @TSServerName + '.[ds_tasks].[dbo].[Mediant_Health_434211_Jobs_Parameters]
			WHERE Enabled = ''Y''
				AND Org_Code = replace(REPLACE(db_name(), ''us_'', ''''), ''_multi'', '''')
				AND (
					fac_ids LIKE ''%,' + CONVERT(VARCHAR, @srcFacId) + ',%''
					OR fac_ids LIKE ''' + CONVERT(VARCHAR, @srcFacId) + ',%''
					OR fac_ids LIKE ''%,' + CONVERT(VARCHAR, @srcFacId) + '''
					OR fac_ids = ''' + CONVERT(VARCHAR, @srcFacId) + '''
					OR fac_ids IS NULL
					OR fac_ids = NULL
					)'

		EXEC sp_executesql @sqlstring
			,N'@count INT OUTPUT'
			,@count = @count OUTPUT

		IF (@count > 0)
		BEGIN
			INSERT INTO #TEMP_RESULTS
			VALUES (
				@fac_name
				,'Custom Extract Vendor'
				,'Y'
				,0
				,'Mediant'
				)
		END

		SET @step = 57

		IF @DebugMe = 'Y'
			PRINT 'BEGIN STEP 57' + '	' + convert(VARCHAR(26), getdate())

		--Omnicare EXTRACT
		SET @sqlstring = 'SELECT @count = count(1)
			FROM ' + @TSServerName + '.[ds_tasks].[dbo].[Omniview_Parameters] WITH (NOLOCK)
			WHERE deleted = ''N''
				AND Org_Code = replace(REPLACE(db_name(), ''us_'', ''''), ''_multi'', '''')
				AND (
					fac_ids LIKE ''%,' + CONVERT(VARCHAR, @srcFacId) + ',%''
					OR fac_ids LIKE ''' + CONVERT(VARCHAR, @srcFacId) + ',%''
					OR fac_ids LIKE ''%,' + CONVERT(VARCHAR, @srcFacId) + '''
					OR fac_ids = ''' + CONVERT(VARCHAR, @srcFacId) + '''
					OR fac_ids IS NULL
					OR fac_ids = NULL
					)'

		EXEC sp_executesql @sqlstring
			,N'@count INT OUTPUT'
			,@count = @count OUTPUT

		IF (@count > 0)
		BEGIN
			INSERT INTO #TEMP_RESULTS
			VALUES (
				@fac_name
				,'Custom Extract Vendor'
				,'Y'
				,0
				,'Omnicare'
				)
		END

		SET @step = 58

		IF @DebugMe = 'Y'
			PRINT 'BEGIN STEP 58' + '	' + convert(VARCHAR(26), getdate())

		--Onshift EXTRACT
		IF replace(REPLACE(db_name(), 'us_', ''), '_multi', '') = 'SNRZ'
		BEGIN
			SELECT @count = count(1)
			FROM [pcc_temp_storage].[dbo].[SNRZ_903271_OnShift_Parameter]
			WHERE (
					fac_ids LIKE '%,' + CONVERT(VARCHAR, @srcFacId) + ',%'
					OR fac_ids LIKE CONVERT(VARCHAR, @srcFacId) + ',%'
					OR fac_ids LIKE '%,' + CONVERT(VARCHAR, @srcFacId)
					OR fac_ids = CONVERT(VARCHAR, @srcFacId)
					OR fac_ids IS NULL
					OR fac_ids = 'null'
					)
		END
		ELSE
		BEGIN
			SET @sqlstring = 'SELECT @count = count(1)
				FROM ' + @TSServerName + '.[ds_tasks].[dbo].[OnShift_415437_Parameter]
				WHERE Enabled = ''Y''
					AND Org_Code = replace(REPLACE(db_name(), ''us_'', ''''), ''_multi'', '''')
					AND (
						fac_id LIKE ''%,' + CONVERT(VARCHAR, @srcFacId) + ',%''
						OR fac_id LIKE ''' + CONVERT(VARCHAR, @srcFacId) + ',%''
						OR fac_id LIKE ''%,' + CONVERT(VARCHAR, @srcFacId) + '''
						OR fac_id = ''' + CONVERT(VARCHAR, @srcFacId) + '''
						OR fac_id IS NULL
						OR fac_id = NULL
						)'

			EXEC sp_executesql @sqlstring
				,N'@count INT OUTPUT'
				,@count = @count OUTPUT
		END

		IF (@count > 0)
		BEGIN
			INSERT INTO #TEMP_RESULTS
			VALUES (
				@fac_name
				,'Custom Extract Vendor'
				,'Y'
				,0
				,'Onshift'
				)
		END

		SET @step = 59

		IF @DebugMe = 'Y'
			PRINT 'BEGIN STEP 59' + '	' + convert(VARCHAR(26), getdate())

		--Paragon EXTRACT
		SET @sqlstring = 'SELECT @count = count(1)
			FROM ' + @TSServerName + '.[ds_tasks].[dbo].[Paragon_Healthcare_653856_Parameters]
			WHERE Enabled = ''Y''
				AND Org_Code = replace(REPLACE(db_name(), ''us_'', ''''), ''_multi'', '''')
				AND (
					fac_ids LIKE ''%,' + CONVERT(VARCHAR, @srcFacId) + ',%''
					OR fac_ids LIKE ''' + CONVERT(VARCHAR, @srcFacId) + ',%''
					OR fac_ids LIKE ''%,' + CONVERT(VARCHAR, @srcFacId) + '''
					OR fac_ids = ''' + CONVERT(VARCHAR, @srcFacId) + '''
					OR fac_ids IS NULL
					OR fac_ids = NULL
					)'

		EXEC sp_executesql @sqlstring
			,N'@count INT OUTPUT'
			,@count = @count OUTPUT

		IF (@count > 0)
		BEGIN
			INSERT INTO #TEMP_RESULTS
			VALUES (
				@fac_name
				,'Custom Extract Vendor'
				,'Y'
				,0
				,'Paragon'
				)
		END

		SET @step = 60

		IF @DebugMe = 'Y'
			PRINT 'BEGIN STEP 60' + '	' + convert(VARCHAR(26), getdate())

		--Pinnacle Quality Extract
		SET @sqlstring = 'SELECT @count = count(1)
			FROM ' + @TSServerName + '.[ds_tasks].[dbo].[Pinnacle_Quality_Job_Parameters]
			WHERE deleted = ''N''
				AND Org_Code = replace(REPLACE(db_name(), ''us_'', ''''), ''_multi'', '''')
				AND (
					fac_ids LIKE ''%,' + CONVERT(VARCHAR, @srcFacId) + ',%''
					OR fac_ids LIKE ''' + CONVERT(VARCHAR, @srcFacId) + ',%''
					OR fac_ids LIKE ''%,' + CONVERT(VARCHAR, @srcFacId) + '''
					OR fac_ids = ''' + CONVERT(VARCHAR, @srcFacId) + '''
					OR fac_ids IS NULL
					OR fac_ids = NULL
					)'

		EXEC sp_executesql @sqlstring
			,N'@count INT OUTPUT'
			,@count = @count OUTPUT

		IF (@count > 0)
		BEGIN
			INSERT INTO #TEMP_RESULTS
			VALUES (
				@fac_name
				,'Custom Extract Vendor'
				,'Y'
				,0
				,'Pinnacle Quality'
				)
		END

		SET @step = 61

		IF @DebugMe = 'Y'
			PRINT 'BEGIN STEP 61' + '	' + convert(VARCHAR(26), getdate())

		--Smartlinx
		IF replace(REPLACE(db_name(), 'us_', ''), '_multi', '') = 'COVC'
		BEGIN
			SET @sqlstring = 'SELECT @count = count(1)
				FROM ' + @TSServerName + '.[ds_tasks].[dbo].[SmartLinx_Shift_COVC]
				WHERE deleted = ''N''
					AND (
						fac_id = ''' + cast(@srcFacId AS VARCHAR) + '''
						OR fac_id IS NULL
						)'
		END
		ELSE
		BEGIN
			SET @sqlstring = 'SELECT @count = count(1)
				FROM ' + @TSServerName + '.[ds_tasks].[dbo].[SmartLinx_Schedule_Parameter] AS sp
				INNER JOIN ' + @TSServerName + '.[ds_tasks].[dbo].[SmartLinx_Shift] AS ss ON sp.Org_code = ss.org_code
				WHERE ss.Deleted = ''N''
					AND sp.Org_Code = replace(REPLACE(db_name(), ''us_'', ''''), ''_multi'', '''')
					AND (
						ss.fac_id = ''' + cast(@srcFacId AS VARCHAR) + '''
						OR ss.fac_id IS NULL
						)'
		END

		EXEC sp_executesql @sqlstring
			,N'@count INT OUTPUT'
			,@count = @count OUTPUT

		IF (@count > 0)
		BEGIN
			INSERT INTO #TEMP_RESULTS
			VALUES (
				@fac_name
				,'Custom Extract Vendor'
				,'Y'
				,0
				,'Smartlinx'
				)
		END

		SET @step = 62

		IF @DebugMe = 'Y'
			PRINT 'BEGIN STEP 62' + '	' + convert(VARCHAR(26), getdate())

		--StaffScheduleCare
		SET @sqlstring = 'SELECT @count = count(1)
			FROM ' + @TSServerName + '.[ds_tasks].[dbo].[StaffScheduleCare_Shift]
			WHERE deleted = ''N''
				AND Org_Code = replace(REPLACE(db_name(), ''us_'', ''''), ''_multi'', '''')
				AND (
					fac_id = ''' + cast(@srcFacId AS VARCHAR) + '''
					OR fac_id IS NULL
					)'

		EXEC sp_executesql @sqlstring
			,N'@count INT OUTPUT'
			,@count = @count OUTPUT

		IF (@count > 0)
		BEGIN
			INSERT INTO #TEMP_RESULTS
			VALUES (
				@fac_name
				,'Custom Extract Vendor'
				,'Y'
				,0
				,'StaffScheduleCare'
				)
		END

		SET @step = 63

		IF @DebugMe = 'Y'
			PRINT 'BEGIN STEP 63' + '	' + convert(VARCHAR(26), getdate())

		SELECT @count = count(1)
		FROM evt_event
		WHERE fac_id = @srcFacId
			AND deleted = 'N'
			AND EXISTS (
				SELECT 1
				FROM #temp_Client
				WHERE client_id = evt_event.client_id
				)

		IF (@count > 0)
		BEGIN
			INSERT INTO #results (
				facility_name
				,application_function
				,[enabled]
				,table_count
				,additional_information
				)
			VALUES (
				@fac_name
				,'Resident Event Calendar'
				,'Y'
				,@count
				,''
				)
		END
		ELSE
		BEGIN
			INSERT INTO #results (
				facility_name
				,application_function
				,[enabled]
				,table_count
				,additional_information
				)
			VALUES (
				@fac_name
				,'Resident Event Calendar'
				,'N'
				,0
				,''
				)
		END

		SET @step = 64

		IF @DebugMe = 'Y'
			PRINT 'BEGIN STEP 64' + '	' + convert(VARCHAR(26), getdate())

		SELECT @count = count(1)
		FROM dbo.configuration_parameter
		WHERE NAME = 'enable_einteract_tranform_form'
			AND value = 'Y'
			AND FAC_ID = @srcFacId

		IF (@count > 0)
		BEGIN
			INSERT INTO #results (
				facility_name
				,application_function
				,[enabled]
				,table_count
				,additional_information
				)
			VALUES (
				@fac_name
				,'EInteract'
				,'Y'
				,1
				,''
				)
		END
		ELSE
		BEGIN
			INSERT INTO #results (
				facility_name
				,application_function
				,[enabled]
				,table_count
				,additional_information
				)
			VALUES (
				@fac_name
				,'EInteract'
				,'N'
				,0
				,''
				)
		END

		SET @step = 65

		IF @DebugMe = 'Y'
			PRINT 'BEGIN STEP 65' + '	' + convert(VARCHAR(26), getdate())

		SET @sqlstring = 'SELECT ''' + replace(@fac_name, '''', '''''') + '''
							,''PreferredTPM''
							,''''
							,1
							,PreferredTPM
						FROM ' + @TSServerName + '.[ds_merge_master].dbo.ClientStaffPreference
						WHERE OrgCode = replace(REPLACE(db_name(), ''us_'', ''''), ''_multi'', '''')

						UNION ALL

						SELECT ''' + replace(@fac_name, '''', '''''') + '''
							,''PreferredClinical''
							,''''
							,1
							,PreferredClinical
						FROM ' + @TSServerName + '.[ds_merge_master].dbo.ClientStaffPreference
						WHERE OrgCode = replace(REPLACE(db_name(), ''us_'', ''''), ''_multi'', '''')

						UNION ALL

						SELECT ''' + replace(@fac_name, '''', '''''') + '''
							,''PreferredFinancial''
							,''''
							,1
							,PreferredFinancial
						FROM ' + @TSServerName + '.[ds_merge_master].dbo.ClientStaffPreference
						WHERE OrgCode = replace(REPLACE(db_name(), ''us_'', ''''), ''_multi'', '''')

						UNION ALL

						SELECT ''' + replace(@fac_name, '''', 
				'''''') + '''
							,''PreferredOther''
							,''''
							,1
							,PreferredOther
						FROM ' + @TSServerName + '.[ds_merge_master].dbo.ClientStaffPreference
						WHERE OrgCode = replace(REPLACE(db_name(), ''us_'', ''''), ''_multi'', '''')

						UNION ALL

						SELECT ''' + replace(@fac_name, '''', '''''') + '''
							,''NonPreferredTPM''
							,''''
							,1
							,NonPreferredTPM
						FROM ' + @TSServerName + '.[ds_merge_master].dbo.ClientStaffPreference
						WHERE OrgCode = replace(REPLACE(db_name(), ''us_'', ''''), ''_multi'', '''')

						UNION ALL

						SELECT ''' + replace(@fac_name, '''', '''''') + '''
							,''NonPreferredClinical''
							,''''
							,1
							,NonPreferredClinical
						FROM ' + @TSServerName + '.[ds_merge_master].dbo.ClientStaffPreference
						WHERE OrgCode = replace(REPLACE(db_name(), ''us_'', ''''), ''_multi'', '''')

						UNION ALL

						SELECT ''' + replace(@fac_name, '''', '''''') + 
			'''
							,''NonPreferredFinancial''
							,''''
							,1
							,NonPreferredFinancial
						FROM ' + @TSServerName + '.[ds_merge_master].dbo.ClientStaffPreference
						WHERE OrgCode = replace(REPLACE(db_name(), ''us_'', ''''), ''_multi'', '''')

						UNION ALL

						SELECT ''' + replace(@fac_name, '''', '''''') + '''
							,''NonPreferredOther''
							,''''
							,1
							,NonPreferredOther
						FROM ' + @TSServerName + '.[ds_merge_master].dbo.ClientStaffPreference
						WHERE OrgCode = replace(REPLACE(db_name(), ''us_'', ''''), ''_multi'', '''')

						UNION ALL

						SELECT ''' + replace(@fac_name, '''', '''''') + '''
							,''SpecialInstructions''
							,''''
							,1
							,SpecialInstructions
						FROM ' + @TSServerName + '.[ds_merge_master].dbo.ClientStaffPreference
						WHERE OrgCode = replace(REPLACE(db_name(), ''us_'', ''''), ''_multi'', '''')'

		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		EXEC sp_executesql @sqlstring
			,N'@count INT OUTPUT'
			,@count = @count OUTPUT

		SET @step = 66

		IF @DebugMe = 'Y'
			PRINT 'BEGIN STEP 66' + '	' + convert(VARCHAR(26), getdate())

		SELECT @count = count(1)
		FROM dbo.configuration_parameter
		WHERE (
				[value] LIKE CONCAT (
					'%, '
					,(
						SELECT min(library_id)
						FROM cp_std_library
						WHERE [description] LIKE '%coms%'
						)
					,',%'
					)
				OR [value] LIKE CONCAT (
					(
						SELECT min(library_id)
						FROM cp_std_library
						WHERE [description] LIKE '%coms%'
						)
					,',%'
					)
				OR [value] LIKE CONCAT (
					'%, '
					,(
						SELECT min(library_id)
						FROM cp_std_library
						WHERE [description] LIKE '%coms%'
						)
					)
				)
			AND [name] = 'cp_selected_libraries'
			AND fac_id = @srcFacId

		IF (@count > 0)
		BEGIN
			INSERT INTO #results (
				facility_name
				,application_function
				,[enabled]
				,table_count
				,additional_information
				)
			VALUES (
				@fac_name
				,'COMS'
				,'Y'
				,1
				,''
				)
		END
		ELSE
		BEGIN
			INSERT INTO #results (
				facility_name
				,application_function
				,[enabled]
				,table_count
				,additional_information
				)
			VALUES (
				@fac_name
				,'COMS'
				,'N'
				,0
				,''
				)
		END

		SET @step = 67

		IF @DebugMe = 'Y'
			PRINT 'BEGIN STEP 67' + '	' + convert(VARCHAR(26), getdate())

		SELECT @count = count(1)
		-- select *
		FROM dbo.configuration_parameter
		WHERE [name] = 'enable_eprescribe_workflow'
			AND [value] = 'Y'

		IF (@count > 0)
		BEGIN
			INSERT INTO #results (
				facility_name
				,application_function
				,[enabled]
				,table_count
				,additional_information
				)
			VALUES (
				@fac_name
				,'enable_eprescribe_workflow'
				,'Y'
				,1
				,''
				)
		END
		ELSE
		BEGIN
			INSERT INTO #results (
				facility_name
				,application_function
				,[enabled]
				,table_count
				,additional_information
				)
			VALUES (
				@fac_name
				,'enable_eprescribe_workflow'
				,'N'
				,0
				,''
				)
		END

		SET @step = 68

		IF @DebugMe = 'Y'
			PRINT 'BEGIN STEP 68' + '	' + convert(VARCHAR(26), getdate())

		SELECT @count = count(1)
		-- select *
		FROM dbo.phm_facility
		WHERE fac_id = @srcFacId

		IF (@count > 0)
		BEGIN
			INSERT INTO #results (
				facility_name
				,application_function
				,[enabled]
				,table_count
				,additional_information
				)
			VALUES (
				@fac_name
				,'Harmony/Patient Insights'
				,'Y'
				,@count
				,''
				)
		END
		ELSE
		BEGIN
			INSERT INTO #results (
				facility_name
				,application_function
				,[enabled]
				,table_count
				,additional_information
				)
			VALUES (
				@fac_name
				,'Harmony/Patient Insights'
				,'N'
				,0
				,''
				)
		END

		SET @step = 72

		IF @DebugMe = 'Y'
			PRINT 'BEGIN STEP 72' + '	' + convert(VARCHAR(26), getdate())

		SELECT @count = count(1)
		-- select *
		FROM configuration_parameter
		WHERE NAME = 'enable_eprescribe_workflow'
			AND value = 'Y'

		IF (@count > 0)
		BEGIN
			INSERT INTO #results (
				facility_name
				,application_function
				,[enabled]
				,table_count
				,additional_information
				)
			VALUES (
				@FAC_NAME
				,'Enable Eprescribe Workflow'
				,'Y'
				,1
				,''
				)
		END
		ELSE
		BEGIN
			INSERT INTO #results (
				facility_name
				,application_function
				,[enabled]
				,table_count
				,additional_information
				)
			VALUES (
				@FAC_NAME
				,'Enable Eprescribe Workflow'
				,'N'
				,0
				,''
				)
		END

		SET @step = 69

		IF @DebugMe = 'Y'
			PRINT 'BEGIN STEP 69' + '	' + convert(VARCHAR(26), getdate())

		--prepare the final result
		INSERT INTO #results (
			facility_name
			,application_function
			,[enabled]
			,table_count
			,additional_information
			)
		SELECT t.facility_name
			,t.application_function
			,t.enabled
			,t.table_count
			,left(t.additional_information, len(t.additional_information) - 1) AS additional_information
		FROM (
			SELECT DISTINCT t2.facility_name
				,t2.application_function
				,t2.enabled
				,t2.table_count
				,(
					SELECT t1.additional_information + ', '
					FROM #temp_results AS t1
					WHERE t1.facility_name = t2.facility_name
					FOR XML path('')
					) AS additional_information
			FROM #temp_results AS t2
			) AS t

		SET @step = 71

		IF @DebugMe = 'Y'
			PRINT 'BEGIN STEP 71' + '	' + convert(VARCHAR(26), getdate())

		DECLARE @tab AS TABLE (
			[fac_id] [int]
			,[brand_id] [int]
			,[name] [varchar](60)
			,[value] [varchar](100)
			,[enabled_by] [varchar](60)
			,[enabled_date] [datetime]
			,[disabled_by] [varchar](60)
			,[disabled_date] [datetime]
			,[created_by] [varchar](60)
			,[created_date] [datetime]
			,[revision_by] [varchar](60)
			,[revision_date] [datetime]
			,[sequence] [smallint]
			)

		SET @count = 0;

		WITH cte
		AS (
			SELECT ROW_NUMBER() OVER (
					PARTITION BY brand_id
					,[sequence] ORDER BY enabled_date DESC
					) rid
				,*
			FROM dbo.branded_library_feature_configuration WITH (NOLOCK)
			WHERE (
					fac_id = @srcFacId
					--OR fac_id = - 1
					)
				--and [sequence] = 2
			)
			,cte1
		AS (
			SELECT *
			FROM cte
			WHERE rid = 1
			)
		--select * from cte union all
		--select * from cte1 where [sequence] = 2
		INSERT INTO @tab
		SELECT [fac_id]
			,[brand_id]
			,[name]
			,[value]
			,[enabled_by]
			,[enabled_date]
			,[disabled_by]
			,[disabled_date]
			,[created_by]
			,[created_date]
			,[revision_by]
			,[revision_date]
			,[sequence]
		FROM cte1

		----SELECT *
		----FROM @tab
		SELECT @count = count(1)
		-- select *
		FROM @tab
		WHERE [value] = 'Y'
			AND (fac_id = @srcFacId)

		--OR fac_id = - 1
		-- IF (@count > 0)
		BEGIN
			INSERT INTO #results (
				facility_name
				,application_function
				,[enabled]
				,table_count
				,additional_information
				)
			SELECT facility_name = @fac_name
				,application_function = 'Care Content Directory -' + bltc.type_display_name
				,[enabled] = coalesce(blfc.[value], 'N')
				,table_count = iif((
						blfc.[value] = 'N'
						OR blfc.[value] IS NULL
						), 0, @count)
				,additional_information = bltc.type_display_name
			FROM dbo.branded_library_tier_configuration bltc WITH (NOLOCK)
			LEFT JOIN dbo.branded_library_configuration blc WITH (NOLOCK) ON bltc.brand_id = blc.brand_id
			LEFT JOIN @tab blfc ON blc.brand_id = blfc.brand_id
				AND blfc.[sequence] = bltc.[sequence]
			LEFT JOIN dbo.facility fac WITH (NOLOCK) ON blfc.fac_id = fac.fac_id
				AND fac.fac_id = @srcFacId
		END
	END

	SET @step = 70

	IF @DebugMe = 'Y'
		PRINT 'BEGIN STEP 70' + '	' + convert(VARCHAR(26), getdate())

	--SELECT *
	--FROM #results
	SELECT @fac_name AS facility_name
		,@srcFacId AS fac_id
		,@health_type AS health_type
		,application_function
		,enabled
		,table_count
		,additional_information
	FROM #results
	WHERE table_count > 0
		OR application_function IN (
			'RRDB'
			,'Ingraph Users'
			,'DBType'
			,'Environment'
			,'Custom Extract Vendor' --added by Cynthia Cui on 2017-12-22, Reason: Smartsheet - Add vendor extracts to 'Facility Utilization' in DSHelper - Row 87
			,'Enable Eprescribe Workflow' -- Added by Jaspreet Singh, Date: 2019-04-04, Reason: Smartsheet - DShelper&OtherDevelopment -  Task# 0188
			,'Harmony/Patient Insights' -- Added by Jaspreet Singh, Date: 2019-08-08, Reason: Email from Rina/Nigel, Subject RE: Harmony/Patient Insights
			,'enable_crm' -- Per Nigel 2020-01-09
			,'Resident Event Calendar' -- Per Nigel 2020-01-14
			,'enable_emar' -- Per Nigel 2020-01-17
			,'enable_mar' -- Per Nigel 2020-01-17
			,'enable_poc' -- Per Nigel 2020-01-17
			,'POC MODULE' -- Per Nigel 2020-01-17
			,'Care Content Directory -Clinical Standard Content'
			,'Care Content Directory -Nursing Advantage'
			,'Care Content Directory - eINTERACT(TM) Program for Skilled Nursing Facilities (SNF)'
			,'Care Content Directory -Think Research(TM) Clinical Support Tools'
			,'Care Content Directory -Skin and Wound'
			,'Care Content Directory -Canadian Care Content'
			,'Care Content Directory -Infection Prevention and Control'
			,'Care Content Directory -Patient Portal'
			)
END
GO




GO

print 'K_Operational_Branch/5_StoredProcedures/US_Only/sproc_list_FacilityUtilizationReport.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/US_Only/sproc_list_FacilityUtilizationReport.sql',getdate(),'4.4.10_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.10_06_CLIENT_K_Operational_Branch_US.sql')

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
values ('4.4.10_K', 'upload_history')


GO

print '..\Update db version.sql --****SCRIPT DONE****'

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.10_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking (script,timestamp,upload) values ('UPLOAD END',getdate(),'4.4.10_06_CLIENT_K_Operational_Branch_US.sql')