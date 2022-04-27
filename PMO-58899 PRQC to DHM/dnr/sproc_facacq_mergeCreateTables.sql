USE  pcc_staging_db58899
GO

/****** Object:  StoredProcedure [operational].[sproc_facacq_mergeCreateTables]    Script Date: 3/11/2022 10:41:51 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [operational].[sproc_facacq_mergeCreateTables] @dborig VARCHAR(500)
	,@dbStag VARCHAR(500)
	,@prefix VARCHAR(50) = 'copym_'
	,@ContinueMerge CHAR(1)
	/********************************************************************************

Purpose:

e.g.
exec  [operational].[sproc_facacq_mergeCreateTables] @dborig = '[pccsql-use2-prod-ssv-tscon05.b4ea653240a9.database.windows.net].test_usei700'
	,@dbStag = 'pcc_staging_db_54116'
	,@prefix = 'copym_'
	,@ContinueMerge = 'N'

**********************************************************************************/
AS
BEGIN
	SET DEADLOCK_PRIORITY 4;
	--SET NOCOUNT ON;

	DECLARE @tablename VARCHAR(500)
	DECLARE @sql VARCHAR(2000)
	DECLARE @logMsg VARCHAR(max)
	DECLARE @counter INTEGER
	DECLARE @IsExists BIT
		,@newTableName VARCHAR(500)

	--,@NewId NVARCHAR(1000)
	SET NOCOUNT ON

	--SET @NewId = '_Old_' + CAST(NEWID() AS NVARCHAR(1000))
	CREATE TABLE #mergeCreateTables (counter INTEGER)

	DECLARE c_mergetables CURSOR
	FOR
	SELECT tablename
	FROM mergeTables
	WHERE idField IS NOT NULL

	OPEN c_mergetables

	FETCH NEXT
	FROM c_mergetables
	INTO @tablename

	WHILE @@FETCH_STATUS <> - 1
		AND @@FETCH_STATUS <> - 2
	BEGIN
		INSERT INTO #mergeCreateTables
		EXEC ('SELECT COUNT(1) FROM ' + @dbStag + 'sysobjects where name = ''' + @prefix + @tablename + '''')

		--EXEC ('SELECT COUNT(1) FROM ' + @dbStag + 'sysobjects where name LIKE ''%' + @prefix + @tablename + '%''')
		SELECT @counter = counter
		FROM #mergeCreateTables

		DELETE
		FROM #mergeCreateTables

		/* "copy" table already exists, Old table hsa been renamed */
		IF ISNULL(@counter, 0) > 0
		BEGIN
			--IF (@ContinueMerge = '1')
			--BEGIN
			SET @logMsg = ' MESSAGE: table ' + @prefix + @tablename + ' already exists; Old table has been renamed'
				--	EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
				--		,0
				--	SET @counter = @counter - 1 -- doing minus because of common_codeHistory table
				--	SELECT @newTableName = @prefix + @tablename + CAST(@counter AS VARCHAR(100))
				--	--			EXEC ('IF EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = ''dbo'' AND TABLE_NAME = ''' + @prefix + @tablename + ''')  EXEC sp_rename ''' + @prefix + @tablename + ''',''' + @prefix + @tablename + @NewId + '''')
				--	EXEC ('IF EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = ''dbo'' AND TABLE_NAME = ''' + @prefix + @tablename + ''')  EXEC sp_rename ''' + @prefix + @tablename + ''',''' + @newTableName + '''')
				--	SET @logMsg = 'IF EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = ''dbo'' AND TABLE_NAME = ''' + @prefix + @tablename + ''')  EXEC sp_rename ''' + @prefix + @tablename + ''',''' + @newTableName + ''''
				--	EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
				--		,0
				--	SET @logMsg = ' Created table ' + @prefix + @tablename
				--	EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
				--		,0
				--	SELECT @sql = 'CREATE TABLE ' + @dbStag + @prefix + @tablename + ' (row_id int IDENTITY, src_id bigint, dst_id bigint, corporate CHAR(1) DEFAULT ''N'')'
				--	EXEC (@sql)
				--	EXEC [operational].[sproc_facacq_mergeLogWriter] @sql
				--		,0
				--END
		END
		ELSE
		BEGIN
			SET @logMsg = ' Created table ' + @prefix + @tablename

			EXEC [operational].[sproc_facacq_mergeLogWriter] @logMsg
				,0

			SELECT @sql = 'CREATE TABLE ' + @dbStag + @prefix + @tablename + ' (row_id bigint IDENTITY, src_id bigint, dst_id bigint, corporate CHAR(1) DEFAULT ''N'')'

			EXEC (@sql)

			EXEC [operational].[sproc_facacq_mergeLogWriter] @sql
				,0

			SELECT @SQL ='IF OBJECT_ID('''+@dbStag + @prefix +@tablename+''') IS NOT NULL AND NOT EXISTS (SELECT * FROM sys.indexes
						WHERE name=''idx_' + @prefix +'as_std_assessment_src_id'')
						BEGIN
						CREATE  CLUSTERED INDEX  idx_clustered'+  @prefix +@tablename+' ON '+@dbStag + @prefix +@tablename+' ([src_id])
						END 
						'
			EXEC(@sql)

		END

		FETCH NEXT
		FROM c_mergetables
		INTO @tablename
	END

	CLOSE c_mergetables

	DEALLOCATE c_mergetables

	DROP TABLE #mergeCreateTables
END /*mergeCreateTables*/



GO


