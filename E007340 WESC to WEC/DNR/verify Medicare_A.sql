declare @sql varchar(max)
declare @dstProdServer varchar(100)
declare @dstProdOrg varchar(20)
--pccsql-use2-prod-w30-cli0015.cbafa2b80e84.database.windows.net].us_wec_multi
set @dstProdServer = '[pccsql-use2-prod-w30-cli0015.cbafa2b80e84.database.windows.net]'
set @dstProdOrg = 'us_wec_multi'

set @sql = 
		'select ''' + @dstProdOrg + ''', payer_id, description from ' + @dstProdServer + '.[' + @dstProdOrg + '].dbo.ar_lib_payers where description like ''%Medicare A%'''

print @sql
exec (@sql)

/*
-=- PMO- -=-
select * from [pccsql-use2-prod-w30-cli0015.cbafa2b80e84.database.windows.net].us_wec_multi.dbo.pcc_db_version order by 3 desc
*/