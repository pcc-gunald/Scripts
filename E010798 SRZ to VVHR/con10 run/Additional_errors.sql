

Select * from mergelog order by msgtime

INSERT INTO pcc_staging_db010798.[dbo].cp_std_lib_positions (
	library_id
	,position_id
	,sequence
	,MULTI_FAC_ID
	)
SELECT DISTINCT ISNULL(EICase010798132.dst_id, library_id)
	,ISNULL(EICase010798131.dst_id, position_id)
	,[sequence]
	,13
FROM test_usei1188.[dbo].cp_std_lib_positions a
JOIN pcc_staging_db010798.[dbo].EICase01079813common_code EICase010798131 ON EICase010798131.src_id = a.position_id
JOIN pcc_staging_db010798.[dbo].EICase01079813cp_std_library EICase010798132 ON EICase010798132.src_id = a.library_id
Msg 2627, Level 14, State 1, Line 5
Violation of PRIMARY KEY constraint 'cp_std_lib_positions__libraryId_positionId_sequence_PK_CL_IX'. Cannot insert duplicate key in object 'dbo.cp_std_lib_positions'. The duplicate key value is (11, 9091, 5).
The statement has been terminated.

Completion time: 2022-04-06T14:44:45.1249093-04:00

Select * from cp_std_lib_positions where library_id =11

Select * from mergeTablesMaster where  tablename like'cp_std_lib_%'



select * from mergelog order by msgTime

begin tran 
INSERT INTO pcc_staging_db010798.[dbo].cp_std_lib_departments (
	library_id
	,dept_id
	,sequence
	,MULTI_FAC_ID
	)
SELECT DISTINCT ISNULL(EICase010798132.dst_id, library_id)
	,ISNULL(EICase010798131.dst_id, dept_id)
	,[sequence]
	,13
FROM test_usei1188.[dbo].cp_std_lib_departments a
JOIN pcc_staging_db010798.[dbo].EICase01079813common_code EICase010798131 ON EICase010798131.src_id = a.dept_id
JOIN pcc_staging_db010798.[dbo].EICase01079813cp_std_library EICase010798132 ON EICase010798132.src_id = a.library_id
on old 4
Select * from cp_std_lib_departments
Select * from   test_usei1188.[dbo].cp_std_lib_departments where library_id=11

Select * from mergeTablesMaster where  tablename='cp_std_lib_departments'

Select * from mergeJoinsMaster where  parentField='cp_std_lib_departments'

Select * from common_code where item_id in (9042,9106,9123,22192,22205)
rollback tran 

Select * from EICase01079813common_code where dst_id= 9042

Msg 2627, Level 14, State 1, Line 6
Violation of PRIMARY KEY constraint 'cp_lib_departments__libraryId_PK_CL_IX'. Cannot insert duplicate key in object 'dbo.cp_std_lib_departments'. The duplicate key value is (11, 9042, 1).
The statement has been terminated.

Completion time: 2022-04-06T05:36:13.6469660-04:00

index_name	index_description	index_keys
cp_lib_departments__libraryId_PK_CL_IX	clustered, unique, primary key located on PRIMARY	library_id, dept_id, sequence



Select * from MergeLog order by msgTime

begin tran
INSERT INTO pcc_staging_db010798.[dbo].cp_std_goal (
	std_goal_id
	,fac_id
	,deleted
	,created_by
	,created_date
	,revision_by
	,revision_date
	,std_need_id
	,text1
	,ordr
	,DELETED_BY
	,DELETED_DATE
	,reg_id
	,modification_required
	,state_code
	,brand_id
	,brand_goal_key
	,goal_uuid
	,MULTI_FAC_ID
	)
SELECT DISTINCT b.dst_id
	,copy_fac.dst_id
	,[deleted]
	,'EICase01079813'
	,getDate()
	,'EICase01079813'
	,getDate()
	,ISNULL(EICase010798131.dst_id, std_need_id)
	,[text1]
	,[ordr]
	,[DELETED_BY]
	,[DELETED_DATE]
	,NULL
	,[modification_required]
	,[state_code]
	,[brand_id]
	,[brand_goal_key]
	,[goal_uuid]
	,13
FROM test_usei1188.[dbo].cp_std_goal a
JOIN pcc_staging_db010798.[dbo].EICase01079813facility copy_fac ON copy_fac.src_id = a.fac_id
	OR copy_fac.src_id = 8
JOIN pcc_staging_db010798.[dbo].EICase01079813cp_std_need EICase010798131 ON EICase010798131.src_id = a.std_need_id
	,pcc_staging_db010798.[dbo].EICase01079813cp_std_goal b
WHERE a.std_goal_id <> - 1
	AND (
		a.fac_id IN (
			8
			,- 1
			)
		OR a.reg_id = 1
		)
	AND a.std_goal_id = b.src_id
	AND b.corporate = 'N'
	and brand_goal_key not in ('CCG01360172','CCG01370172','CCG01360169')
	rollback tran

	Msg 2601, Level 14, State 1, Line 6
Cannot insert duplicate key row in object 'dbo.cp_std_goal' with unique index 'cp_std_goal__brandId_brandGoalKey_FLT_UQ_IX'. The duplicate key value is (1, CCG01360172).
The statement has been terminated.

Completion time: 2022-04-05T22:54:46.6887793-04:00


index_name	index_description	index_keys
cp_std_goal__brandId_brandGoalKey_FLT_UQ_IX	nonclustered, unique located on PRIMARY	brand_id, brand_goal_key

Select * from EICase01079812cp_std_goal where src_id=31934
Select * from EICase01079813cp_std_goal where dst_id =22778
Select * into #temp
  from cp_std_goal where brand_goal_key in (Select [brand_goal_key]
 
FROM test_usei1188.[dbo].cp_std_goal a
JOIN pcc_staging_db010798.[dbo].EICase01079813facility copy_fac ON copy_fac.src_id = a.fac_id
	OR copy_fac.src_id = 8
JOIN pcc_staging_db010798.[dbo].EICase01079813cp_std_need EICase010798131 ON EICase010798131.src_id = a.std_need_id
	,pcc_staging_db010798.[dbo].EICase01079813cp_std_goal b
WHERE a.std_goal_id <> - 1
	AND (
		a.fac_id IN (
			8
			,- 1
			)
		OR a.reg_id = 1
		)
	AND a.std_goal_id = b.src_id
	AND b.corporate = 'N')

  Select * from #temp


  Select * from EICase01079812cp_std_goal where dst_id in (Select std_goal_id from #temp)

	Select * from EICase01079812cp_std_goal where dst_id in (Select std_goal_id from #temp)

	Select * from test_usei1188.[dbo].cp_std_goal where std_goal_id in (	Select src_id from EICase01079812cp_std_goal where dst_id in (Select std_goal_id from #temp))
	
  Select * from cp_std_need_cat where fac_id =12 and need_cat_id in (270,285,285,273)

  update   cp_std_need_cat 
  set fac_id =-1
  where fac_id =12

update  cp_std_need 
  set fac_id =-1
  where fac_id =12 

  update  cp_std_goal 
  set fac_id =-1
  where fac_id =12 

  update  cp_std_etiologies 
  set fac_id =-1
  where fac_id =12 

  
  update  cp_std_intervention 
  set fac_id =-1
  where fac_id =12 

	Select * from cp_std_need where fac_id =12 and std_need_id in (
  Select std_need_id from #temp)

  Select * from cp_std_intervention where fac_id =12 and std_need_id in (
  Select std_need_id from #temp)

  	Select * from  [dbo].cp_std_goal where fac_id =12
	and std_goal_id in (	Select dst_id from EICase01079812cp_std_goal where dst_id in (Select std_goal_id from #temp))

	Select * from cp_std_etiologies where  fac_id =12 and std_need_id in (
  Select std_need_id from #temp)

  	Select * from test_usei1188.[dbo].cp_std_etiologies where std_etiologies_id
in (	Select src_id from EICase01079812cp_std_etiologies where dst_id in (	Select std_etiologies_id from cp_std_etiologies where  std_need_id in (
  Select std_need_id from #temp)))


  
--Focus Categories
select need_cat_id,fac_id,reg_id,created_by,created_date,description
from cp_std_need_cat
where library_id = 29
--and fac_id in (1085,1082,1087)
and deleted='N'
order by description



--need (focus description
select need.std_need_id,need.fac_id,need.reg_id,need.created_by,need.created_date,need.text1
from cp_std_need_cat cat inner join cp_std_need need
on cat.need_cat_id = need.need_cat_id
where library_id = 29
and need.deleted='N'
order by need.text1



--goal
select g.std_goal_id,g.fac_id,g.reg_id,g.created_by,g.created_date,g.text1
from cp_std_need_cat cat inner join cp_std_need need
on cat.need_cat_id = need.need_cat_id
inner join cp_std_goal g
on need.std_need_id = g.std_need_id
where library_id = 29
and g.deleted='N'
order by g.text1





--intervention
select i.std_intervention_id,i.fac_id,i.reg_id,i.created_by,i.created_date,i.text1
from cp_std_need_cat cat inner join cp_std_need need
on cat.need_cat_id = need.need_cat_id
inner join cp_std_intervention i
on need.std_need_id = i.std_need_id
where library_id = 29
and i.deleted='N'
order by i.text1



--etiologies
select e.std_etiologies_id,e.fac_id,e.reg_id,e.created_by,e.created_date,e.text1
from cp_std_need_cat cat inner join cp_std_need need
on cat.need_cat_id = need.need_cat_id
inner join cp_std_etiologies e
on need.std_need_id = e.std_need_id
where library_id = 29
--and e.fac_id in (1085,1082,1087)
and e.deleted='N'
and cat.deleted='N'
and need.deleted='N'
order by e.text1

