declare @sql varchar(max)
declare @dstProdServer varchar(100)
declare @dstProdOrg varchar(20)

set @dstProdServer = '[pccsql-use2-prod-w22-cli0005.4c4638f8e26f.database.windows.net]'
set @dstProdOrg = 'us_bsd_multi'

set @sql = 
		'select ''' + @dstProdOrg + ''', payer_id, description from ' + @dstProdServer + '.[' + @dstProdOrg + '].dbo.ar_lib_payers where description like ''%Medicare A%'''

print @sql
exec (@sql)

