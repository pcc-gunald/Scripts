--USE test_usei210
--GO


/*
Written By: Virul Patel

Script Type: DML 
Target DB Type:  Data Service Process Destination
Target Database:  Data Service Process Destination
Re-Runable:		YES


use test_usei118

sp_updatestats

Sample execution for these procedures:
1. 
ONLINE (DEFERRED) @flgOffLine = 0
E20,E17,E16,E13,E10,E9,E8,E7,E6

2. 
OFFLINE (NON-DEFERRED) @flgOffLine = 1
'E22','E20','E17','E16','E13','E10','E9','E11','E12b','E8','E7','E6','E5','E4','E3','E2a','E2','E1' 

EXEC Sp_EIDataRollback 'US_pcc_staging_db17','EICase12345346','E22',57,0 
*/


IF EXISTS (SELECT * FROM SYSOBJECTS where id = object_id(N'[dbo].[Sp_EIDataRollback]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
   DROP PROCEDURE DBO.Sp_EIDataRollback
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE Sp_EIDataRollback
	@P_stageDBName VARCHAR(100),
	@P_EICasepreFix VARCHAR(100),
	@P_moduleShortDesc VARCHAR(5),
	@P_MultiFacId INT,
	@P_flgOffLine INT

AS
BEGIN

	SET DEADLOCK_PRIORITY LOW

	DoIt:

	BEGIN TRY

		SET NOCOUNT ON

		SET CONTEXT_INFO 0xDC1000000

		DECLARE @stageDBName VARCHAR(100)
		DECLARE @moduleShortDesc VARCHAR(5)
		DECLARE @preFix VARCHAR(100)
		DECLARE @tableName VARCHAR(100)
		DECLARE @tabBatSize BIGINT
		DECLARE @sqlStatement NVARCHAR(MAX)
		DECLARE @idField VARCHAR(100)
		DECLARE @startId BIGINT
			,@endId BIGINT
		DECLARE @betweenVal VARCHAR(1000)
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
			,startId BIGINT
			,endId BIGINT
			,id INT 
			,corpExist INT
			,nullValExist INT
			)

		DECLARE @batchSize INT
		DECLARE @batchStartId INT
		DECLARE @batchEndId INT
		DECLARE @batchCompleted INT
		DECLARE @retRowCount INT
		DECLARE @reDoIt INT
		DECLARE @tabExist INT
		DECLARE @tabCnt INT
		DECLARE @corpExist INT
		DECLARE @flgOffLine INT
		DECLARE @MultiFacId INT

		DECLARE @outVal TABLE
			(outVal INT)

		DECLARE @noCheckFkSQL VARCHAR(MAX)
		DECLARE @checkFkSQL VARCHAR(MAX)

		SET @stageDBName=@P_stageDBName
		SET @preFix = @P_EICasepreFix
		SET @moduleShortDesc=@P_moduleShortDesc
		SET @flgOffLine=@P_flgOffLine
		SET @MultiFacId=@P_MultiFacId

		SET @batchSize=80000
		SET @batchStartId=0
		SET @batchEndId=0
		SET @batchCompleted=1
		SET @retRowCount=0
		SET @reDoIt=0

		IF @flgOffLine=0
			BEGIN
				PRINT '*****ONLINE ROLLBACK*******'
				INSERT INTO @ListTab
				SELECT DISTINCT L.childTab, L.tableOrder, L.BatSize, NULL noCheckFkSql, NULL checkFkSql
				FROM [dbo].[ListOfDeferTables] L
				INNER JOIN (
							SELECT T.TableName
							FROM [UDSM3\DS2016JOB].[ds_merge_master].DBO.mergeModuleMaster M
							INNER JOIN [UDSM3\DS2016JOB].[ds_merge_master].DBO.mergeModuleTables T
								ON (M.ModuleId=T.ModuleId)
							WHERE M.ShortDescription=@moduleShortDesc
							) MT
							ON (L.childTab=MT.TableName)
				WHERE EXISTS (SELECT 1 FROM DBO.listoftables WHERE ModuleName=@moduleShortDesc AND tablename=L.childTab AND MultiFacId=@MultiFacId)
			END
		ELSE
			BEGIN
				PRINT '*****OFFLINE ROLLBACK*******'
				INSERT INTO @ListTab
				SELECT DISTINCT T.TableName, M2.tableorder, NULL BatSize, 
					'ALTER TABLE '+T.TableName+' NOCHECK CONSTRAINT '+FK.[NAME] noCheckFkSQL, 
					'ALTER TABLE '+T.TableName+' CHECK CONSTRAINT '+FK.[NAME] checkFkSQL
					FROM [UDSM3\DS2016JOB].[ds_merge_master].DBO.mergeModuleMaster M
					INNER JOIN [UDSM3\DS2016JOB].[ds_merge_master].DBO.mergeModuleTables T
						ON (M.ModuleId=T.ModuleId)
					INNER JOIN [UDSM3\DS2016JOB].[ds_merge_master].DBO.mergeTables M2
						ON (T.TableName=M2.tablename)
										LEFT JOIN sys.foreign_keys FK
					ON (FK.parent_object_id = OBJECT_ID(T.TableName)
						AND FK.referenced_object_id = OBJECT_ID(T.TableName))
					WHERE M.ShortDescription=@moduleShortDesc AND NOT EXISTS (SELECT 1 FROM [dbo].[ListOfDeferTables] WHERE childTab=T.TableName)
					AND EXISTS (SELECT 1 FROM DBO.listoftables WHERE ModuleName=@moduleShortDesc AND tablename=T.TableName AND MultiFacId=@MultiFacId)
			END

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
			/* CASES to find dest_id
					1. Use idField from [dbo].[mergetables] if exist, get min id and max id from staging db and then delete with inner join (stagind db and dest db table)
					2. if idField is null in [dbo].[mergetables] then
						2.1 Find table ids from mergejoins(mappingcase table only exist if parenttable idfiled is not null) (Note: parenttable idfield is null will never happend)
						2.2 Join with all columns with staging db table dest db table and do delete
			*/

			SET @sqlStatement = NULL
			SET @tabExist=NULL

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
						FROM [UDSM3\DS2016JOB].[ds_merge_master].DBO.[mergetables]
						WHERE tablename = @tableName
						)

				SET @batchStartId=0
				SET @batchEndId=0
				SET @batchCompleted=1
				SET @retRowCount=0
				SET @tabExist=NULL

				IF @idField IS NOT NULL
				BEGIN
					PRINT '********CASE 1*********'
					PRINT 'TABLE :- '+ @tableName
					--CHECKING IF TABLE IS EXIST IN STAGING DB
					SET @sqlStatement='SELECT ISNULL((SELECT 1 FROM '+@stageDBName+'.INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '''+@preFix + @tableName+'''),0)'
				
					INSERT @outVal
					EXEC (@sqlStatement)

					SET @tabExist=(SELECT outVal FROM @outVal)

					DELETE FROM @outVal
					--CHECKING ROW COUNT IN STAGING DB TABLE
					IF @tabExist=1
						BEGIN
							SET @sqlStatement='SELECT COUNT(1) tabCnt FROM '+@stageDBName+'..'+@preFix + @tableName
						
							INSERT @outVal
							EXEC (@sqlStatement)

							SET @tabCnt=(SELECT outVal FROM @outVal)
						END

					IF @tabExist =1 AND @tabCnt>0
					BEGIN
						SET @sqlStatement = 'SELECT ''' + @tableName + ''',''' + @idField + ''',ISNULL(MIN(dst_id),0),ISNULL(MAX(dst_id),0),'+CHAR(13)+CHAR(10)+
											'NULL id,'+CHAR(13)+CHAR(10)+
											'ISNULL((SELECT TOP 1 1 FROM '+@stageDBName + '..'+ @preFix + @tableName + ' WHERE corporate =''Y''),0) corpExist,'+CHAR(13)+CHAR(10)+
											'NULL nullValExist'+CHAR(13)+CHAR(10)+
											'FROM '+ @stageDBName + '..' + @preFix + @tableName +' WHERE corporate =''N'' and dst_id>=1'

						INSERT INTO @idTab
						EXEC (@sqlStatement)

						SELECT @startId = startId
							,@endId = endId
							,@corpExist=corpExist
						FROM @idTab
						WHERE tableName = @tableName
							AND idField = @idField
				
						IF @endId<>0 OR (@tableName='common_code')
						BEGIN
							SET @batchStartId=@startId
							SET @batchEndId=IIF(@batchStartId+@batchSize>@endId,@endId,@batchStartId+@batchSize)

							PRINT 'START TIME:-'+CONVERT(VARCHAR,GETDATE())

							IF @noCheckFkSQL IS NOT NULL AND @flgOffLine=1 --This will execute for only OFFLINE
								BEGIN
									PRINT @noCheckFkSQL
									EXEC (@noCheckFkSQL)
								END


							WHILE @batchStartId<=@endId
							BEGIN
								IF @tableName='common_code' --Special Case for Only Common_Code table
									BEGIN
										SET @sqlStatement=	'DELETE A '+CHAR(13)+CHAR(10)+
															'FROM '+ @tableName +' A '+CHAR(13)+CHAR(10)+
															'WHERE EXISTS (SELECT 1 FROM '+ @stageDBName +'..' + @tableName +' B '+CHAR(13)+CHAR(10)+
															'WHERE (A.'+@idField+'=B.'+@idField+') AND Multi_Fac_Id='+CONVERT(VARCHAR,@MultiFacId)+')'
									END
								ELSE IF @corpExist=1
									BEGIN
										SET @sqlStatement=	'DELETE A '+CHAR(13)+CHAR(10)+
															'FROM '+ @tableName +' A '+CHAR(13)+CHAR(10)+
															'INNER JOIN '+ @stageDBName +'..' +@preFix + @tableName +' B '+CHAR(13)+CHAR(10)+
															'ON (A.'+@idField+'=B.dst_id AND B.corporate=''N'' AND A.'+@idField+' BETWEEN '+ CONVERT(VARCHAR(10), @batchStartId) + ' AND ' + CONVERT(VARCHAR(10), @batchEndId) + ')'
									END
								ELSE
									BEGIN
										SET @sqlStatement=	'DELETE '+CHAR(13)+CHAR(10)+
															'FROM '+ @tableName +CHAR(13)+CHAR(10)+
															'WHERE '+@idField+' BETWEEN '+ CONVERT(VARCHAR(10), @batchStartId) + ' AND ' + CONVERT(VARCHAR(10), @batchEndId)
									END
						
								PRINT @sqlStatement
							
								EXEC (@sqlStatement)

								SET @retRowCount=@@ROWCOUNT
								PRINT 'DELETED :- '+CONVERT(VARCHAR,@retRowCount)+' RECORDS'

								SET @batchStartId=@batchEndId+1
								SET @batchEndId=IIF(@batchStartId+@batchSize>@endId,@endId,@batchStartId+@batchSize)
							END

							IF @checkFkSQL IS NOT NULL AND @flgOffLine=1 --This will execute for only OFFLINE
								BEGIN
									PRINT @checkFkSQL
									EXEC (@checkFkSQL)
								END


							PRINT 'END TIME:-'+CONVERT(VARCHAR,GETDATE())
						END
					END
				END
				ELSE 
				BEGIN
					PRINT '********CASE 2*********'
					PRINT 'TABLE :- '+ @tableName
					SET @sqlStatement='SELECT ISNULL((SELECT 1 FROM '+@stageDBName+'.INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '''+ @tableName+'''),0)'
				
					INSERT @outVal
					EXEC (@sqlStatement)

					SET @tabExist=(SELECT outVal FROM @outVal)

					DELETE FROM @outVal

					--CHECKING ROW COUNT IN STAGING DB TABLE
					SET @sqlStatement='SELECT COUNT(1) tabCnt FROM '+@stageDBName+'..'+ @tableName +CHAR(13)+CHAR(10)+
									  'WHERE Multi_Fac_Id='+CONVERT(VARCHAR,@MultiFacId)
				
					INSERT @outVal
					EXEC (@sqlStatement)
				
					SET @tabCnt=(SELECT outVal FROM @outVal)
				
					SET @sqlStatement = NULL

					IF @tabExist=1 AND @tabCnt >0--In CASE 2, 0 Means All table that needs is exist, if it is more than 0 then any of table missing for process
					BEGIN
						IF OBJECT_ID('tempdb..#tmpPkCols') IS NOT NULL
							DROP TABLE #tmpPkCols

						SELECT TABLE_NAME tableName, COLUMN_NAME idField,0 startId,0 endId,
						ORDINAL_POSITION id,NULL corpExist,
						NULL nullValExist
						INTO #tmpPkCols
						FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
						WHERE OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_SCHEMA + '.' + QUOTENAME(CONSTRAINT_NAME)), 'IsPrimaryKey') = 1
						AND TABLE_NAME =@tableName ORDER BY ORDINAL_POSITION
					
						IF (SELECT TOP 1 1 FROM #tmpPkCols)=1
							BEGIN
								PRINT '********CASE 2/1*********'
								SELECT @sqlStatement = COALESCE(@sqlStatement + CHAR(13)+CHAR(10)+' UNION ALL '+CHAR(13)+CHAR(10), '')+
								'SELECT tableName,idField,startId,endId,'+CHAR(13)+CHAR(10)+
								'id,corpExist,'+CHAR(13)+CHAR(10)+
								'ISNULL((SELECT TOP 1 1 FROM '+ @stageDBName+'..' + tablename +'  WHERE '+ idField +' is null),0) nullValExist'+CHAR(13)+CHAR(10)+
								'FROM #tmpPkCols WHERE idField='''+idField+''''
								FROM #tmpPkCols

								INSERT INTO @idTab
								EXEC (@sqlStatement)

								IF OBJECT_ID('tempdb..#tmpPkCols') IS NOT NULL
									DROP TABLE #tmpPkCols

							END
						ELSE
							BEGIN
								PRINT '********CASE 2/2*********'
								SELECT @sqlStatement = COALESCE(@sqlStatement + CHAR(13)+CHAR(10)+' UNION ALL '+CHAR(13)+CHAR(10), '')+
								'SELECT tableName,fieldname idField,0 startId,0 endId,'+CHAR(13)+CHAR(10)+
								'id,ISNULL((SELECT TOP 1 1 FROM '+ @preFix + parenttable +'  WHERE corporate =''Y''),0) corpExist,'+CHAR(13)+CHAR(10)+
								'ISNULL((SELECT TOP 1 1 FROM '+ @stageDBName+'..' + tablename +'  WHERE '+ fieldName +' is null AND Multi_Fac_Id='+CONVERT(VARCHAR,@MultiFacId)+'),0) nullValExist'+CHAR(13)+CHAR(10)+
								'FROM [UDSM3\DS2016JOB].[ds_merge_master].dbo.[mergejoins] WHERE tablename = '''+@tableName+''' AND fieldname='''+fieldName+''''
								FROM [UDSM3\DS2016JOB].[ds_merge_master].dbo.[mergejoins]
								WHERE tablename = @tableName

								INSERT INTO @idTab
								EXEC (@sqlStatement)

								IF @flgOffLine=0
									BEGIN
										UPDATE A
										SET A.id=B.RN
										FROM @idTab A
										INNER JOIN 
										(SELECT idField,ID,DENSE_RANK() OVER (ORDER BY corpExist DESC, ID ASC) RN FROM @idTab)B
										--(SELECT idField,ROW_NUMBER() OVER (PARTITION BY corpExist ORDER BY corpExist DESC, ID ASC) RN FROM @idTab) B
										ON (A.idField=B.idField)
									END
								ELSE
									BEGIN
										UPDATE A
										SET A.id=B.RN
										FROM @idTab A
										INNER JOIN 
										(SELECT idField,ROW_NUMBER() OVER (ORDER BY corpExist ASC, ID ASC) RN FROM @idTab) B
										ON (A.idField=B.idField)
									END
							END

						SELECT @betweenVal= IIF(@betweenVal IS NULL,'',@betweenVal)+
							CASE
								WHEN id=1 THEN 
									CASE
										WHEN nullValExist=0 THEN 'A.'+idField +'=B.'+idField
										WHEN nullValExist=1 THEN '(A.'+idField +'=B.'+idField+' OR A.'+idField+' IS NULL)'
									END
								ELSE 
									CASE 
										WHEN nullValExist=0 THEN ' AND A.'+idField +'=B.'+idField
										WHEN nullValExist=1 THEN ' AND (A.'+idField +'=B.'+idField+' OR A.'+idField+' IS NULL)'
									END
							END
						FROM @idTab ORDER BY id
					
						/*
						SET @sqlStatement = 'DELETE TOP('+CONVERT(VARCHAR(10),@batchSize)+') A '+ CHAR(13)+CHAR(10)+
											--'DELETE A '+ CHAR(13)+CHAR(10)+
											'FROM ' + @tableName +' A' + CHAR(13)+CHAR(10)+ 
											'INNER JOIN '+@stageDBName +'..'+@tableName +' B '+ CHAR(13)+CHAR(10)+ 
											'ON ('+@betweenVal+')'
						*/

						SET @sqlStatement = 'DELETE TOP('+CONVERT(VARCHAR(10),@batchSize)+') A '+ CHAR(13)+CHAR(10)+
											--'DELETE A '+ CHAR(13)+CHAR(10)+
											'FROM ' + @tableName +' A' + CHAR(13)+CHAR(10)+ 
											'WHERE EXISTS (SELECT 1 FROM '+@stageDBName +'..'+@tableName +' B '+ CHAR(13)+CHAR(10)+ 
											'WHERE ('+@betweenVal+') AND Multi_Fac_Id='+CONVERT(VARCHAR,@MultiFacId)+')'
					
						PRINT 'START TIME:-'+CONVERT(VARCHAR,GETDATE())					
						IF @noCheckFkSQL IS NOT NULL AND @flgOffLine=1 --This will execute for only OFFLINE
							BEGIN
								PRINT @noCheckFkSQL
								EXEC (@noCheckFkSQL)
							END
						PRINT @sqlStatement	
					
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

						IF @checkFkSQL IS NOT NULL AND @flgOffLine=1 --This will execute for only OFFLINE
							BEGIN
								PRINT @checkFkSQL
								EXEC (@checkFkSQL)
						END

						PRINT 'END TIME:-'+CONVERT(VARCHAR,GETDATE())
					END
				END
			END --END OF DESTINATION TABLE EXIST

			DELETE FROM @idTab
			DELETE FROM @outVal

			FETCH NEXT
			FROM curListTab
			INTO @tableName,@tabBatSize,@noCheckFkSql,@checkFkSQL

			DELETE FROM DBO.listoftables WHERE ModuleName=@moduleShortDesc AND tablename=@tableName AND MultiFacId=@MultiFacId

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