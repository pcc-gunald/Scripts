select * from MergeLog
order by msgTime desc


select * from mergeTablesMaster
where tablename='common_code_audit'


select * from mergeTablesMaster
where QueryFilter is not null 





 AND mpi_id in (SELECT mpi_id from [origDB].clients where fac_id = [OrigFacId]) 
SELECT *
			FROM dbo.mergeTables
			WHERE tablename IN (
					'common_code_audit'
					)


SELECT *
			FROM mergejoins
			WHERE tablename IN (
					'common_code_audit'
					)


mergeExecuteExtractStep4 --> MergeError : Violation of PRIMARY KEY constraint 'common_code_audit__itemId_effectiveDate_PK_CL_IX'.
Cannot insert duplicate key in object 'dbo.common_code_audit'. The duplicate key value is (76869, Dec 19 2018  5:01AM).
 INSERT INTO pcc_staging_db58910.[dbo].common_code_audit (
	item_id
	,deleted
	,revision_by
	,item_description
	,effective_date
	,ineffective_date
	,action_type
	,DELETED_BY
	,MULTI_FAC_ID
	)
SELECT DISTINCT ISNULL(EICase5891010671.dst_id, item_id)
	,[deleted]
	,'EICase589101067'
	,[item_description]
	,[effective_date]
	,isnull(ineffective_date, getdate())
	,[action_type]
	,[DELETED_BY]
	,59
FROM test_usei548.[dbo].common_code_audit a
JOIN pcc_staging_db58910.[dbo].EICase589101067common_code EICase5891010671 ON EICase5891010671.src_id = a.item_id
WHERE NOT EXISTS (
		SELECT 1
		FROM [pccsql-use2-prod-ssv-tscon11.b4ea653240a9.database.windows.net].test_usei1072.[dbo].common_code_audit origt
		WHERE (
				origt.ineffective_date = a.ineffective_date
				AND origt.effective_date = a.effective_date
				)
			OR origt.effective_date = a.effective_date
			AND origt.item_id = EICase5891010671.dst_id
		)
	AND NOT EXISTS (
		SELECT 1
		FROM pcc_staging_db58910.[dbo].common_code_audit origt1
		WHERE (
				origt1.ineffective_date = a.ineffective_date
				AND origt1.effective_date = a.effective_date
				)
			OR origt1.effective_date = a.effective_date
			AND origt1.item_id = EICase5891010671.dst_id
		)


select * from pcc_staging_db58910.[dbo].EICase589101067common_code EICase5891010671
where dst_id in(76869,76858)

select *  from test_usei548.[dbo].common_code_audit
where item_id in(9365,13569)


drop table if exists #temp_audit
;with temp as (
select * 
,cnt= count(1) over(partition by item_id )
,nvalue=lead(item_description,1,null) over(partition by item_id order by effective_date)
from test_usei548.[dbo].common_code_audit
)
select a.*
,dst_item_description = dst.item_description
into #temp_audit
from temp a 
inner join [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.[PMO58910_AdminPickList$]  b on b.src_item_id=a.item_id
inner join [pccsql-use2-prod-w25-cli0021.2d62ac5c7643.database.windows.net].[us_gdn_multi].dbo.common_code AS dst on dst.item_id = b.Map_DstItemId
where 1=1
and a.cnt>1
--and a.item_id in(16449,16451,9365)
--and ineffective_date>'2021-12-07'

update c
set effective_date=DATEADD(SS,1,a.effective_date) 
from  #temp_audit  a
inner join test_usei548.[dbo].common_code_audit c on c.item_id=a.item_id and c.effective_date=a.effective_date
where 1=1
and exists(select 1 from test_usei548.[dbo].common_code_audit b where a.dst_item_description=b.item_description
and b.effective_date=a.effective_date
and b.item_id<>a.item_id
)

