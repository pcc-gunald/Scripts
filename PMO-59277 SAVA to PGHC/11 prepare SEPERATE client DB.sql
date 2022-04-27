USE [master] 

DECLARE @return_value INT
,@vRequestId INT
,@restoretime DATETIME = getdate() --as of when we want the restore to be done
,@client_database_name NVARCHAR(50) = 'test_usei1214' --Name of the DB we want to restore
,@client_server_name NVARCHAR(100)  = '[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net]' --Instance name from where we want the resore
,@destination_server NVARCHAR(100) = '[pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net]' --Destination Instance name where we want the restore to happen
,@destination_database_name NVARCHAR(100) = 'test_usei1214' --Name of the destination DB
,@Created_by NVARCHAR(50) = 'shahr' --Username of the user logging the restore job
,@statusout NVARCHAR(100)
,@statusmessageout NVARCHAR(100)

EXEC @return_value = [vmuspassvjob001.pccprod.local].[azure_restore].[dbo].[create_restore_request] @source_instance = @client_server_name
,@source_Database_name = @client_database_name
,@destination_instance = @destination_server
,@destination_database_name = @destination_database_name
,@point_in_time = @restoretime
,@requestor = @Created_by
,@requestid = @vRequestId OUTPUT
 
select RequestId = @vRequestId;

declare @statusout char(1), @statusmessageout varchar(2000)
exec [vmuspassvjob001.pccprod.local].[azure_restore].[dbo].[check_status] @requestid = , --ID of the job you just created
@status=@statusout output , @status_message=@statusmessageout output
select @statusout,@statusmessageout

/* Latest Test Results



*/

/* Go Live Results



*/