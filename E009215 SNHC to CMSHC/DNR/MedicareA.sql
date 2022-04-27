declare @sql varchar(max)
declare @dstProdServer varchar(100)
declare @dstProdOrg varchar(20)

set @dstProdServer = '[pccsql-use2-prod-w21-cli0002.f352397924df.database.windows.net]'
set @dstProdOrg = 'us_cmshc_multi'

set @sql = 
		'select ''' + @dstProdOrg + ''', payer_id, description from ' + @dstProdServer + '.[' + @dstProdOrg + '].dbo.ar_lib_payers where description like ''%Medicare A%'''

print @sql
exec (@sql)


select 'us_cmshc_multi', payer_id, description from [pccsql-use2-prod-w21-cli0002.f352397924df.database.windows.net].[us_cmshc_multi].dbo.ar_lib_payers