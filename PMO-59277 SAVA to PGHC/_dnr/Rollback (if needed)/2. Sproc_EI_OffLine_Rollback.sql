--USE test_usei210
--GO


IF EXISTS (SELECT * FROM SYSOBJECTS where id = object_id(N'[dbo].[Sproc_EI_OffLine_Rollback]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
   DROP PROCEDURE DBO.Sproc_EI_OffLine_Rollback
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*
--Sample Exec
Exec Sproc_EI_OffLine_Rollback @P_stageDBName='PE04M_US_Staging_43147'
*/


CREATE PROCEDURE Sproc_EI_OffLine_Rollback
	@P_stageDBName VARCHAR(100)
AS
BEGIN

	SET DEADLOCK_PRIORITY LOW

	DoIt:

	BEGIN TRY

		SET NOCOUNT ON

		SET CONTEXT_INFO 0xDC1000000

		DECLARE @stageDBName VARCHAR(100)
		DECLARE @tableName VARCHAR(100)
		DECLARE @tabBatSize BIGINT
		DECLARE @sqlStatement NVARCHAR(MAX)
		DECLARE @reDoIt INT
		DECLARE @noCheckFkSQL VARCHAR(MAX)
		DECLARE @checkFkSQL VARCHAR(MAX)

		DECLARE @tabExist INT
		DECLARE @outVal TABLE
			(outVal INT)

		DECLARE @idField VARCHAR(100)
		DECLARE @betweenVal VARCHAR(1000)
		DECLARE @startId BIGINT
			,@endId BIGINT

		DECLARE @batchSize INT
		DECLARE @batchStartId INT
		DECLARE @batchEndId INT
		DECLARE @batchCompleted INT
		DECLARE @retRowCount INT
		DECLARE @tabCnt INT

		DECLARE @ListTab AS TABLE (
			childTab VARCHAR(100) NOT NULL
			,tableOrder int NOT NULL
			,BatSize bigint
			,noCheckFkSql VARCHAR(MAX)
			,checkFkSql VARCHAR(MAX)
			)

		DECLARE @idTab AS TABLE (
			tableName VARCHAR(100)
			,idField VARCHAR(100)
			,id INT 
			)

		SET @batchSize=80000
		SET @stageDBName=@P_stageDBName
		--SET @stageDBName='PE04M_US_Staging_43147'
		
		INSERT INTO @ListTab
		SELECT DISTINCT T.TableName, M2.tableorder, NULL BatSize, 
			'ALTER TABLE '+T.TableName+' NOCHECK CONSTRAINT '+FK.[NAME] noCheckFkSQL, 
			'ALTER TABLE '+T.TableName+' CHECK CONSTRAINT '+FK.[NAME] checkFkSQL
			FROM [udsm3\ds2016job].[ds_merge_master].DBO.mergeModuleMaster M
			INNER JOIN [udsm3\ds2016job].[ds_merge_master].DBO.mergeModuleTables T
				ON (M.ModuleId=T.ModuleId)
			INNER JOIN [udsm3\ds2016job].[ds_merge_master].DBO.mergeTables M2
				ON (T.TableName=M2.tablename)
								LEFT JOIN sys.foreign_keys FK
			ON (FK.parent_object_id = OBJECT_ID(T.TableName)
				AND FK.referenced_object_id = OBJECT_ID(T.TableName))
			WHERE 
			NOT EXISTS (SELECT 1 FROM [dbo].[ListOfDeferTables] WHERE childTab=T.TableName)
			AND EXISTS (SELECT 1 FROM DBO.listoftables WHERE tablename=T.TableName)

		--SELECT DISTINCT childTab FROM @ListTab

		DECLARE curListTab CURSOR
		FOR
		SELECT childTab, BatSize, noCheckFkSql, checkFkSql
		FROM @ListTab
		ORDER BY tableOrder DESC

		OPEN curListTab

		FETCH NEXT
		FROM curListTab
		INTO @tableName, @tabBatSize, @noCheckFKSql, @checkFkSQL

		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			SET @sqlStatement = NULL
			SET @tabExist=NULL
			SET @tabCnt=0

			SET @sqlStatement='SELECT ISNULL((SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '''+@tableName+'''),0)'
			
			INSERT @outVal
			EXEC (@sqlStatement)

			SET @tabExist=(SELECT outVal FROM @outVal)

			DELETE FROM @outVal

			IF @tabExist=1 --CHECKING IF DESTINATION TABLE IS EXIST
			BEGIN

				SET @sqlStatement = NULL
				SET @betweenVal = NULL

				SET @idField = (
						SELECT idField
						FROM [udsm3\ds2016job].[ds_merge_master].DBO.[mergetables]
						WHERE tablename = @tableName
						)

				SET @batchStartId=0
				SET @batchEndId=0
				SET @batchCompleted=1
				SET @retRowCount=0
				SET @tabExist=NULL

				--CHECKING IF TABLE IS EXIST IN STAGING DB
				SET @sqlStatement='SELECT ISNULL((SELECT 1 FROM '+@stageDBName+'.INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '''+@tableName+'''),0)'
				
				INSERT @outVal
				EXEC (@sqlStatement)

				SET @tabExist=(SELECT outVal FROM @outVal)
					
				DELETE FROM @outVal
				
				--CHECKING ROW COUNT IN STAGING DB TABLE
				IF @tabExist=1
					BEGIN
						SET @sqlStatement='SELECT COUNT(1) tabCnt FROM '+@stageDBName+'..'+ @tableName
					
						INSERT @outVal
						EXEC (@sqlStatement)

						SET @tabCnt=(SELECT outVal FROM @outVal)
					END
				
				IF @idField IS NOT NULL
				BEGIN
					PRINT '********CASE 1 : ID FIELD EXIST IN MERGETABLES*********'
					PRINT 'TABLE :- '+ @tableName

					IF @tabExist =1 AND @tabCnt>0
					BEGIN
						SET @sqlStatement = 'DELETE TOP('+CONVERT(VARCHAR(10),@batchSize)+') DST'+CHAR(13)+
											'FROM '+@tableName+' DST '+CHAR(13)+
											--'INNER JOIN '+@stageDBName+'.DBO.'+@tableName+' STG '+CHAR(13)+
											--'ON (DST.'+@idField+'=STG.'+@idField+')'
											'WHERE EXISTS (SELECT 1 FROM '+@stageDBName +'..'+@tableName +' STG '+ CHAR(13)+CHAR(10)+ 
											'WHERE (DST.'+@idField+'=STG.'+@idField+'))'

						PRINT @sqlstatement

						PRINT 'START TIME:-'+CONVERT(VARCHAR,GETDATE())					

						IF @noCheckFkSQL IS NOT NULL
							BEGIN
								PRINT @noCheckFkSQL
								EXEC (@noCheckFkSQL)
							END
					
						WHILE @BatchCompleted>0
							BEGIN
								EXEC (@sqlStatement)
								SET @retRowCount=@@ROWCOUNT
								--SET @retRowCount=0
								PRINT 'DELETED :- '+CONVERT(VARCHAR,@retRowCount)+' RECORDS'
								IF (@retRowCount=0)
									BREAK
								ELSE
									SET @BatchCompleted=@retRowCount
							END

						IF @checkFkSQL IS NOT NULL --This will execute for only OFFLINE
							BEGIN
								PRINT @checkFkSQL
								EXEC (@checkFkSQL)
						END

						PRINT 'END TIME:-'+CONVERT(VARCHAR,GETDATE())

					END

				END
				ELSE
				BEGIN
					PRINT '********CASE 2 : ID FIELD NOT EXIST IN MERGETABLES*********'
					PRINT 'TABLE :- '+ @tableName
					
					SET @sqlStatement = NULL
					IF @tabExist =1 AND @tabCnt>0
					BEGIN
						IF OBJECT_ID('tempdb..#tmpPkCols') IS NOT NULL
						DROP TABLE #tmpPkCols

						SELECT TABLE_NAME tableName, COLUMN_NAME idField,
						ORDINAL_POSITION id
						INTO #tmpPkCols
						FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
						WHERE OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_SCHEMA + '.' + QUOTENAME(CONSTRAINT_NAME)), 'IsPrimaryKey') = 1
						AND TABLE_NAME =@tableName ORDER BY ORDINAL_POSITION

						IF (SELECT TOP 1 1 FROM #tmpPkCols)=1
							BEGIN
								SELECT @sqlStatement = COALESCE(@sqlStatement + CHAR(13)+CHAR(10)+' UNION ALL '+CHAR(13)+CHAR(10), '')+
								'SELECT tableName,idField,'+CHAR(13)+CHAR(10)+
								'id'+CHAR(13)+CHAR(10)+
								'FROM #tmpPkCols WHERE idField='''+idField+''''
								FROM #tmpPkCols

								INSERT INTO @idTab
								EXEC (@sqlStatement)

								--SELECT * FROM @idTab

								IF OBJECT_ID('tempdb..#tmpPkCols') IS NOT NULL
									DROP TABLE #tmpPkCols
							END
						ELSE
							BEGIN
								SELECT @sqlStatement = COALESCE(@sqlStatement + CHAR(13)+CHAR(10)+' UNION ALL '+CHAR(13)+CHAR(10), '')+
								'SELECT tableName,fieldname idField,'+CHAR(13)+CHAR(10)+
								'id,'+CHAR(13)+CHAR(10)+
								'FROM [udsm3\ds2016job].[ds_merge_master].dbo.[mergejoins] WHERE tablename = '''+@tableName+''' AND fieldname='''+fieldName+''''
								FROM [udsm3\ds2016job].[ds_merge_master].dbo.[mergejoins]
								WHERE tablename = @tableName
								
								INSERT INTO @idTab
								EXEC (@sqlStatement)

								UPDATE A
								SET A.id=B.RN
								FROM @idTab A
								INNER JOIN 
								(SELECT idField,ROW_NUMBER() OVER (ORDER BY ID ASC) RN FROM @idTab) B
								ON (A.idField=B.idField)
							END

						SELECT @betweenVal= IIF(@betweenVal IS NULL,'',@betweenVal)+
							CASE
								WHEN id=1 THEN 'A.'+idField +'=B.'+idField
								ELSE ' AND A.'+idField +'=B.'+idField
							END
						FROM @idTab ORDER BY id

						SET @sqlStatement = 'DELETE TOP('+CONVERT(VARCHAR(10),@batchSize)+') A '+ CHAR(13)+CHAR(10)+
											'FROM ' + @tableName +' A' + CHAR(13)+CHAR(10)+ 
											'WHERE EXISTS (SELECT 1 FROM '+@stageDBName +'..'+@tableName +' B '+ CHAR(13)+CHAR(10)+ 
											'WHERE ('+@betweenVal+'))'

						PRINT @sqlStatement

						PRINT 'START TIME:-'+CONVERT(VARCHAR,GETDATE())					

						IF @noCheckFkSQL IS NOT NULL
							BEGIN
								PRINT @noCheckFkSQL
								EXEC (@noCheckFkSQL)
							END
					
						WHILE @BatchCompleted>0
							BEGIN
								EXEC (@sqlStatement)
								SET @retRowCount=@@ROWCOUNT
								--SET @retRowCount=0
								PRINT 'DELETED :- '+CONVERT(VARCHAR,@retRowCount)+' RECORDS'
								IF (@retRowCount=0)
									BREAK
								ELSE
									SET @BatchCompleted=@retRowCount
							END

						IF @checkFkSQL IS NOT NULL
							BEGIN
								PRINT @checkFkSQL
								EXEC (@checkFkSQL)
						END

						PRINT 'END TIME:-'+CONVERT(VARCHAR,GETDATE())

					END

				END
			END

			DELETE FROM @outVal

			FETCH NEXT
			FROM curListTab
			INTO @tableName,@tabBatSize,@noCheckFkSql,@checkFkSQL

			DELETE FROM @idTab

			--DELETE FROM DBO.listoftables WHERE tablename=@tableName 
		END

		CLOSE curListTab

		DEALLOCATE curListTab
	END TRY

	BEGIN CATCH
		IF ERROR_NUMBER() = 1205
			BEGIN
				SET @reDoIt=1
				PRINT 'Error:1205'+'-'+ERROR_MESSAGE()
			END
		ELSE
			BEGIN
				PRINT 'Error:'+CONVERT(VARCHAR,ERROR_NUMBER())+'-'+ERROR_MESSAGE()
			END
		
		IF CURSOR_STATUS('global','curListTab')>=-1
		BEGIN
			DEALLOCATE curListTab
		END
	END CATCH
	
	IF @reDoIt=1
	BEGIN
		GOTO DoIt
	END
END
