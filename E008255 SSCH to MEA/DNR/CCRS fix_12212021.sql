


select * from pcc_staging_db008255.dbo.as_std_pick_list I
WHERE I.fac_id=-1 and  I.std_assess_id = 3 AND I.pick_list_id >= 0

select pick_list_id  into #temp from pcc_staging_db008255.dbo.as_std_pick_list I
WHERE I.fac_id=-1 and  I.std_assess_id = 3 AND I.pick_list_id >= 0


/*
pick_list_id	fac_id	description					std_assess_id	Multi_Fac_Id
1120276	-1	Person/Other-11	3	29
1120278	-1	Not in place/In place-12	3	29*/

--check mapping column to find the src_id
select concat(src_id,',') from pcc_staging_db008255.dbo.EICase0082551as_std_pick_list
where dst_id in (select pick_list_id from #temp)
for xml path('')
/*
row_id	src_id	dst_id	corporate
1587	1000661	1120276	N
1589	1000663	1120278	N
*/
select * from pcc_staging_db008255.dbo.EICase0082553067as_std_pick_list
where src_id in (350)

--exclude in autopre 
update  mergetablesmaster
set  queryfilter =' AND  pick_list_id not in (338,344,1000661, 1000663)  '  --src ID's seen above
--select  *  from mergetablesmaster
where tablename='as_std_pick_list'

-- delete bad rows
delete 
--select * 
from pcc_staging_db008255.dbo.EICase0082551as_std_pick_list
where dst_id in (select pick_list_id from #temp)

delete 
--select * 
from pcc_staging_db008255.dbo.as_std_pick_list
where pick_list_id  in (select pick_list_id from #temp)

-- update listoftables before restart
delete 
--select *  
from listoftables
where tablename = 'as_std_pick_list'

