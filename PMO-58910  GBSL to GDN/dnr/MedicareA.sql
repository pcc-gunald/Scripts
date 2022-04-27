declare @sql varchar(max)
declare @dstProdServer varchar(100)
declare @dstProdOrg varchar(20)

set @dstProdServer = '[pccsql-use2-prod-w25-cli0021.2d62ac5c7643.database.windows.net]'
set @dstProdOrg = 'us_gdn_multi'

set @sql = 
		'select ''' + @dstProdOrg + ''', payer_id, description from ' + @dstProdServer + '.[' + @dstProdOrg + '].dbo.ar_lib_payers where description like ''%Medicare A%'''

print @sql
exec (@sql)

select 'us_gdn_multi', payer_id, description from [pccsql-use2-prod-w25-cli0021.2d62ac5c7643.database.windows.net].[us_gdn_multi].dbo.ar_lib_payers where description like '%Medicare A%'
order by 3