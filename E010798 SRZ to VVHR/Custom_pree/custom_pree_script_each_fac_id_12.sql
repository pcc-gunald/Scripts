--Custom Scripts
use test_usei1188



----Select * from facility
SET CONTEXT_INFO 0xDC1000000;
 SET DEADLOCK_PRIORITY 4;
 SET QUOTED_IDENTIFIER ON;

 
--	Msg 8115, Level 16, State 2, Line 6
--Arithmetic overflow error converting expression to data type smallint.
--The statement has been terminated.

--select * from evt_contact_role where evt_contact_role_id not in (Select distinct evt_contact_role_id from evt_contact )
--(15334 rows affected)

Delete from evt_contact_role where evt_contact_role_id not in (Select distinct evt_contact_role_id from evt_contact )

----Select * from cp_std_library
update cp_std_library
set description = 'SRZ-' + description 
------select * 
from cp_std_library 
where description not like 'SRZ%'
and fac_id in (-1,7,8)
and brand_id is null
and len(description)<33

----(43 rows affected)

update cp_std_library
set description = 'SRZ-' + 'ALT Health Maintenance Library' 
------select * 
from cp_std_library 
where description not like 'SRZ%'
and fac_id in (-1,7,8)
and brand_id is null
and library_id=29
--------and description='Nrsg Pav. at Chipola Retirement Ctr'

update cp_std_library
set description = 'SRZ-' + 'PCC Health Maintenance Library' 
------select * 
from cp_std_library 
where description not like 'SRZ%'
and fac_id in (-1,7,8)
and brand_id is null
and library_id=32

update cp_std_library
set description = 'SRZ-' + 'OBRA and Medical Care Plan Lib' 
------select * 
from cp_std_library 
where description not like 'SRZ%'
and fac_id in (-1,7,8)
and brand_id is null
and library_id=88

update cp_std_library
set description = 'SRZ-' + 'Senior Living Medical Based Lib' 
------select * 
from cp_std_library 
where description not like 'SRZ%'
and fac_id in (-1,7,8)
and brand_id is null
and library_id=93


update cp_std_library
set description = 'SRZ-' + 'Senior Living Medical Based Li1' 
------select * 
from cp_std_library 
where description not like 'SRZ%'
and fac_id in (-1,7,8)
and brand_id is null
and library_id=95

------------Violation of PRIMARY KEY constraint 'qlib_pick_list_item_mapping__qlibPickListId_qlibPickListItemId_PK_CL_IX'. Cannot insert duplicate key in object 'dbo.qlib_pick_list_item_mapping'. The duplicate key value is (120, 1720).
------------The statement has been terminated.

update  test_usei1188.[dbo].qlib_pick_list_item
set item_description=item_description+'*'
where qlib_pick_list_item_id in (4820,324,4944,4583,8677)
and item_description not like '%*'


print  CHAR(13) + '0.9.2 as_std_pick_list - Run before 1st Facility in Source running now ' + char (13)
print  CHAR(13) + ' *** (multi facility and for first facility only  *** ' 

IF OBJECT_ID('pcc_temp_storage.dbo._bkp_Case010798_as_std_pick_list', 'U') IS NOT NULL 
DROP TABLE pcc_temp_storage.dbo._bkp_Case010798_as_std_pick_list

select * into pcc_temp_storage.dbo._bkp_Case010798_as_std_pick_list
--select *
from as_std_pick_list 

declare @Counter int,@pickID int
	set @counter = 1

declare PickListCursor cursor for 
		select pick_list_id
			from as_std_pick_list a
			where exists (select ISNULL(std_assess_id,99999), description from as_std_pick_list
			where ISNULL(std_assess_id,99999) = ISNULL(a.std_assess_id,99999) and isnull(description,99999) = isnull(a.description,99999)
								group by ISNULL(std_assess_id,99999), description having count(*) > 1)
									and a.std_assess_id not in (select std_assess_id from as_std_assessment where system_flag = 'Y')
									and a.std_assess_id not in (select std_assess_id from as_std_assessment_system_assessment_mapping)

	open PickListCursor
	fetch next
	from PickListCursor
	into @PickID

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		set @counter = @counter + 1
		update as_std_pick_list 
	set description = isnull(substring(description,1,28),'') + '-' + convert(varchar (10),@counter)
			where pick_list_id = @pickID
	
	fetch next
	from PickListCursor
	into @PickID

	end
close PickListCursor
deallocate PickListCursor



----update prot_std_protocol_detail
----set deleted='Y',
----deleted_by='case173634',
----deleted_date='2011-04-06 23:27:29.287'
----where detail_id in(3,4)

----update prot_std_action

----set deleted='Y',
----deleted_by='case173634',
----deleted_date='2011-04-06 23:27:29.287'
----where action_id in (3,4)


------------select * --into #userids
------------from dbo.sec_user 
------------where fac_id in (7,8)
------------and (loginname like '%inte%graph%' 
------------or long_username like '%inte%graph%')

------------Select * from sec_user where userid in (52607,61036,105675,110476,120355,122246,197755,197775,291341)

----update sec_user

----set fac_id =1
----where userid in (52607,61036,105675,110476,120355,122246,197755,197775,291341)
----and fac_id <>1

----update [cp_sec_user_audit]

----set fac_id =5

----where [cp_sec_user_audit_id] in (6747)

------WHILE
------       (
------            SELECT COUNT(*)
------            from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.pho_std_order src 
------			join [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.pho_std_order dst on src.template_description = dst.template_description 
------			where src.fac_id in (-1,7,8) 
------			and ( src.status <> dst.status
------			or dst.fac_id <> -1)
------       ) > 0
------BEGIN
------			update src
------			set src.template_description = src.template_description + '-'
------			--select src.std_order_id, dst.std_order_id, src.fac_id,dst.fac_id,src.status, dst.status, src.description,dst.description,src.template_description,dst.template_description,* 
------			from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.pho_std_order src 
------			join [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.pho_std_order dst on src.template_description = dst.template_description 
------			where src.fac_id in (-1,7,8) 
------			and ( src.status <> dst.status
------			or dst.fac_id <> -1)
------END   

------instead of running the below query multiple times to get 0, changed it to dynamically run until 0 results
------commenting code below and replacing by dynamic code above


update src
set src.template_description = src.template_description + '-'
--------------select src.std_order_id, dst.std_order_id, src.fac_id,dst.fac_id,src.status, dst.status, src.description,len(src.template_description),dst.description,src.template_description,dst.template_description,* 
from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.pho_std_order src 
join [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.pho_std_order dst on src.template_description = dst.template_description 
where src.fac_id in (-1,7,8) 
and ( src.status <> dst.status
or dst.fac_id <> -1)
and len(src.template_description)=100


update pho_std_order

set template_description='Clonidine 0.2mg/24 hour patch (Catapres-TTS-2) -Apply 1 Patch transdermally Q weekly on Mon for HTN'
where template_description='Clonidine 0.2mg/24 hour patch (Catapres-TTS-2) - Apply 1 Patch transdermally Q weekly on Mon for HTN'
and std_order_id=-101263

update pho_std_order

set template_description='Clonidine 0.3mg/24 hour patch (Catapres-TTS-3) -Apply 1 Patch Transdermally Q Weekly on Mon for HTN'
where template_description='Clonidine 0.3mg/24 hour patch (Catapres-TTS-3) - Apply 1 Patch Transdermally Q Weekly on Mon for HTN'
and std_order_id=-101264


update src
set src.template_description = src.template_description + '*'
--------select src.std_order_id, dst.std_order_id, src.fac_id,dst.fac_id,src.status, dst.status, src.description,dst.description,src.template_description,dst.template_description,* 
from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.pho_std_order src 
join [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.pho_std_order dst on src.template_description = dst.template_description 
where src.fac_id in (-1,7,8) 
and ( src.status <> dst.status
or dst.fac_id <> -1)

------(1876 rows affected)
update src
set src.template_description = src.template_description + '*'
--select src.std_order_id, dst.std_order_id, src.fac_id,dst.fac_id,src.status, dst.status, src.description,dst.description,src.template_description,dst.template_description,* 
from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.pho_std_order src 
join [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.pho_std_order dst on src.template_description = dst.template_description 
where src.fac_id in (-1,7,8) 
and ( src.status <> dst.status
or dst.fac_id <> -1)

------update src
------set src.template_description = src.template_description + '-'
--------select src.std_order_id, dst.std_order_id, src.fac_id,dst.fac_id,src.status, dst.status, src.description,dst.description,src.template_description,dst.template_description,* 
------from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.pho_std_order src 
------join [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.pho_std_order dst on src.template_description = dst.template_description 
------where src.fac_id in (-1,7,8) 
------and ( src.status <> dst.status
------or dst.fac_id <> -1)

------update src
------set src.template_description = src.template_description + '-'
--------select src.std_order_id, dst.std_order_id, src.fac_id,dst.fac_id,src.status, dst.status, src.description,dst.description,src.template_description,dst.template_description,* 
------from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.pho_std_order src 
------join [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.pho_std_order dst on src.template_description = dst.template_description 
------where src.fac_id in (-1,7,8) 
------and ( src.status <> dst.status
------or dst.fac_id <> -1)

------print  CHAR(13) + 'if above is not zero - investigate --> pho_std_order' 

--updating description by removing extra space in src description
update src 
set src.set_description = replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(src.set_description,' day','day'),' (','('),') - ',')'),') ',')'),' - ','-'),', ',','),': ',':'),'# ','#'),'converted','conv'),'less than','<'), ' :', ':'), 'Step 1','Step1') 
------select src.template_description,len(src.template_description) as lenofDesc, replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(src.set_description,' day','day'),' (','('),') - ',')'),') ',')'),' - ','-'),', ',','),': ',':'),'# ','#'),'converted','conv'),'less than','<'), ' :', ':'), 'Step 1','Step1')   as newDescription, len(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(src.set_description,' day','day'),' (','('),') - ',')'),') ',')'),' - ','-'),', ',','),': ',':'),'# ','#'),'converted','conv'),'less than','<'), ' :', ':'), 'Step 1','Step1') ) as lenofnewDesc
from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.pho_std_order_set src 
join [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.pho_std_order_set dst on src.set_description=dst.set_description 
where src.fac_id in (-1,7,8) 
and (src.status <> dst.status
or dst.fac_id <> -1)  

	--PHO_STD_ORDER_SET.set_description
update src
set src.set_description = src.set_description + '*'
------select src.std_order_set_id, dst.std_order_set_id, src.fac_id,dst.fac_id,src.set_description,dst.set_description,src.status,dst.status,* 
from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.pho_std_order_set src 
join [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.pho_std_order_set dst on src.set_description=dst.set_description 
where src.fac_id in (-1,7,8) 
--and dst.fac_id <> -1--1
and (src.status <> dst.status
or dst.fac_id <> -1)  

----(57 rows affected)

--for  pho_std_order but was missed in pho_Std_order_set

--PHO_STD_ORDER_SET.set_description
update src
set src.set_description = src.set_description + '*'
--------select src.std_order_set_id, dst.std_order_set_id, src.fac_id,dst.fac_id,src.set_description,dst.set_description,src.status,dst.status,* 
from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.pho_std_order_set src 
join [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.pho_std_order_set dst on src.set_description=dst.set_description 
where src.fac_id in (-1,7,8) 
--and dst.fac_id <> -1--1
and (src.status <> dst.status
or dst.fac_id <> -1)  
--for  pho_std_order but was missed in pho_Std_order_set

--PHO_STD_ORDER_SET.set_description
update src
set src.set_description = src.set_description + '*'
------select src.std_order_set_id, dst.std_order_set_id, src.fac_id,dst.fac_id,src.set_description,dst.set_description,src.status,dst.status,* 
from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.pho_std_order_set src 
join [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.pho_std_order_set dst on src.set_description=dst.set_description 
where src.fac_id in (-1,7,8) 
--and dst.fac_id <> -1--1
and (src.status <> dst.status
or dst.fac_id <> -1)  
--for  pho_std_order but was missed in pho_Std_order_set

--PHO_STD_ORDER_SET.set_description
update src
set src.set_description = src.set_description + '-'
------select src.std_order_set_id, dst.std_order_set_id, src.fac_id,dst.fac_id,src.set_description,dst.set_description,src.status,dst.status,* 
from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.pho_std_order_set src 
join [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.pho_std_order_set dst on src.set_description=dst.set_description 
where src.fac_id in (-1,7,8) 
--and dst.fac_id <> -1--1
and (src.status <> dst.status
or dst.fac_id <> -1)  
--for  pho_std_order but was missed in pho_Std_order_set

--PHO_STD_ORDER_SET.set_description
update src
set src.set_description = src.set_description + '-'
------select src.std_order_set_id, dst.std_order_set_id, src.fac_id,dst.fac_id,src.set_description,dst.set_description,src.status,dst.status,* 
from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.pho_std_order_set src 
join [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.pho_std_order_set dst on src.set_description=dst.set_description 
where src.fac_id in (-1,7,8) 
--and dst.fac_id <> -1--1
and (src.status <> dst.status
or dst.fac_id <> -1)  
--for  pho_std_order but was missed in pho_Std_order_set


print  CHAR(13) + 'if above is not zero - investigate --> pho_std_order_set' 

print  CHAR(13) + 'UDA - picklist issue'

update as_std_question
set pick_list_id=NULL
where pick_list_id not in (Select pick_list_id from as_std_pick_list)
and pick_list_id>0
and std_assess_id in (Select std_assess_id from as_std_assessment where deleted ='Y')

print  CHAR(13) + 'Orders - undelete common_code - to fix diet orders'

--check if any deleted items are used in src
select distinct diet_type as 'src_id'  into #missing_diet from pho_phys_order where fac_id in (1, 2, 3)
and order_type_id in (select order_type_id from pho_order_type where description like '%diet%' and deleted = 'N')
and diet_type in (select item_id from common_code where deleted='Y') 
union
--insert into #missing_diet 
select distinct diet_texture   from pho_phys_order where fac_id in (1, 2, 3)
and order_type_id in (select order_type_id from pho_order_type where description like '%diet%' and deleted = 'N')
and diet_texture in (select item_id from common_code where deleted='Y') 
union
--insert into #missing_diet 
select distinct fluid_consistency  from pho_phys_order where fac_id in (1, 2, 3)
and order_type_id in (select order_type_id from pho_order_type where description like '%diet%' and deleted = 'N')
and fluid_consistency in (select item_id from common_code where deleted='Y') 
union
--insert into #missing_diet 
select distinct diet_supplement from pho_phys_order where fac_id in (1, 2, 3)
and order_type_id in (select order_type_id from pho_order_type where description like '%diet%' and deleted = 'N')
and diet_supplement in (select item_id from common_code where deleted='Y') 
order by 1--0

print  CHAR(13) + 'Orders - undelete common_code - to fix diet orders'

update common_code
set deleted = 'N', fac_id = -1
--------select * 
from dbo.common_code 
where item_id in (select src_id from #missing_diet)
and item_code in ('phocst','phosup','phodtx','phodyt')
and deleted = 'Y'

------ --***UPLOAD CATEGORIES MAPPING***
------print  CHAR(13) + 'If Online Documentation - mapping running now (only needed for the first facility)' 


update src
set 
	src.cat_desc = dst.cat_desc,
	src.admin_flag = dst.admin_flag,
	src.clinical_flag = dst.clinical_flag,
	src.irm_flag = dst.irm_flag,
	src.cat_code = dst.cat_code
--------select src.std_cat_id,dst.std_cat_id,src.cat_id, um.map_dst_catid, dst.cat_id, src.cat_desc, dst.cat_desc, src.admin_flag, dst.admin_flag, src.clinical_flag,dst.clinical_flag,src.std_cat_id, dst.std_cat_id, *
--------select count(1)
from upload_categories src
inner join [vmuspassvtsjob1.pccprod.local].[FacAcqMapping].[dbo].[PMO010798_UploadCategories$] um--mapping table for the project
on src.cat_id = um.srcCatID
inner join [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.upload_categories dst--destination database
on dst.cat_id = um.map_dst_catid
and (src.admin_flag = dst.admin_flag or dst.admin_flag='N')
and (src.clinical_flag = dst.clinical_flag or dst.clinical_flag='N')
and (src.irm_flag = dst.irm_flag or dst.irm_flag='N')

print  CHAR(13) + 'Updating common code - dynamically through admin picklist excel file - Dynamic Admin Picklist running now' 


UPDATE src
SET src.item_description = dst.item_description
--------SELECT a.item_code, a.src_Item_Id, a.src_Item_Description, b.dst_Item_Id, b.dst_Item_Description,src.fac_id,dst.fac_id
--------SELECT a.pick_list_name,a.src_Item_Description,b.dst_Item_Description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_AdminPicklist$'] a
LEFT JOIN [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_AdminPicklist$'] b ON a.Map_DstItemId = b.dst_Item_Id
LEFT JOIN test_usei1188.dbo.common_code AS src on src.item_id = a.src_item_id
LEFT JOIN [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.common_code AS dst on dst.item_id = b.dst_item_id
WHERE 
	(
		a.pick_list_name IS NOT NULL -- total mapping provided by analyst to implementer							--
		AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer							--
		AND a.src_item_id IS NOT NULL --eliminate any incorrect provided mappings									--
		AND ISNUMERIC(a.map_dstitemid) = 1 --ignore any DNM or typo errors											--
		AND a.Map_DstItemId NOT IN --remove any dupilicate many to one mappings (Any If_merged not As_is or N)		--
			(
				select dst_Item_Id
				--select dst_Item_Id,if_merged
				from  [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_AdminPicklist$'] a
				where dst_Item_Id in 
				(
					select map_dstitemid 
					FROM [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_AdminPicklist$']
					WHERE pick_list_name IS NOT NULL -- total mapping provided by analyst to implementer	
						AND map_dstitemid IS NOT NULL --total count of mapping provided by implementer		
						AND src_item_id IS NOT NULL --eliminate any incorrect provided mappings	
						AND ISNUMERIC(map_dstitemid) = 1
				)
				and a.If_Merged not in ('As_is','N') -- will not take any record with 'Y'
			)
	)
	and a.id not in --remove any duplicate one to many mappings (2 or more occurances of one mapping)
		(
			select id 
			--select id, pick_list_name, src_item_description, map_dstitemid
			from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_AdminPicklist$'] 
			where Map_DstItemId in
			(
				select Map_DstItemId
				--select Map_DstItemId, count(*)
				from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_AdminPicklist$'] 
				where src_Item_Description is not null
				group by Map_DstItemId having count(*) > 1 and Map_DstItemId is NOT NULL
			)
			and id not in
			(			
				select min(id) 
				from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_AdminPicklist$'] 
				group by map_dstitemid having map_dstitemid in 
					(
						select distinct Map_DstItemId 
						--select id, pick_list_name, src_item_description, map_dstitemid
						from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_AdminPicklist$'] 
						where Map_DstItemId in
						(
							select Map_DstItemId
							--select Map_DstItemId, count(*)
							from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_AdminPicklist$'] 
							group by Map_DstItemId having count(*) > 1 and Map_DstItemId is NOT NULL
						)
					)
			)
		)
	and src.item_id = a.src_Item_Id AND dst.item_id = b.dst_Item_Id AND src.item_code = a.item_code -- specifically used for updating the correct item
	--and src.item_id IN ( ???? ) -- any records that has to be excluded that you dont think is a proper merge

--========================================================================================

print  CHAR(13) + 'Updating Resident Identifier admin templates - running now' 

----select * from mergetablesmaster where tablename = 'id_type'
----description


UPDATE src
SET src.description = dst.description
------SELECT distinct a.srcIdTypeId, b.dstIdTypeId, src.description , dst.description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ResidentIdentifier$'] a
LEFT JOIN [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ResidentIdentifier$'] b ON a.map_dst_typeid = b.dstIdTypeId
LEFT JOIN [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.id_type AS src on src.id_type_id = a.srcIdTypeId
LEFT JOIN [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.id_type AS dst on dst.id_type_id = b.dstIdTypeId
WHERE  a.srcFieldName IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dst_typeid IS NOT NULL --total count of mapping provided by implementer  

----========================================================================================

print  CHAR(13) + 'Updating User Defined Fields admin templates - running now' 

----select * from mergetablesmaster where tablename like 'user_field_types'
----field_name  field_data_type     field_length

UPDATE src
SET src.field_name = dst.field_name, src.field_length = dst.field_length
------SELECT distinct a.srcFieldTypeId, b.dstFieldTypeId, src.field_name , dst.field_name, src.field_data_type, dst.field_data_type, src.field_length, dst.field_length, CASE WHEN src.field_data_type = dst.field_data_type AND src.field_length = dst.field_length THEN 'Possible to Merge' ELSE 'Not Possible to Merge' END as mergePossible
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_UserDefinedData$'] a
LEFT JOIN [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_UserDefinedData$'] b ON a.map_dst_typeid = b.dstFieldTypeId
LEFT JOIN [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.user_field_types AS src on src.field_type_id = a.srcFieldTypeId
LEFT JOIN [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.user_field_types AS dst on dst.field_type_id = b.dstFieldTypeId
WHERE  a.srcFieldName IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dst_typeid IS NOT NULL --total count of mapping provided by implementer  
AND src.field_data_type = dst.field_data_type
--AND src.field_length = dst.field_length

--========================================================================================

----Select distinct item_code, pick_list_name from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalPicklist$'] where map_dstitemid LIKE '%Scope to fac%'
--Select * from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalPicklist$'] where map_dstitemid='1047'
--item_code	pick_list_name
--cpclo	Reasons for Care Plan Closure
--dclas	Diagnosis Classification
--phocst	Fluid Consistency
--phodtx	Diet Texture
--phodyt	Diet Type
--phosup	Diet Supplement
--strke	Documentation Strike Out
--wvscal	Weight Scale Types

----update [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalPicklist$']

----set map_dstitemid= NULL
----where map_dstitemid=82461
----and id=208
----and src_Item_Id=16962

print  CHAR(13) + 'Updating common code - dynamically through clinical picklist excel file - Dynamic Clinical Picklist running now' 

UPDATE src
SET src.item_description = dst.item_description
----SELECT a.item_code, a.src_Item_Id, a.src_Item_Description, b.dst_Item_Id, b.dst_Item_Description,src.fac_id,dst.fac_id,dst.ITEM_ID
----SELECT a.pick_list_name,a.src_Item_Description,b.dst_Item_Description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalPicklist$'] a
LEFT JOIN [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalPicklist$'] b ON a.Map_DstItemId = b.dst_Item_Id
LEFT JOIN test_usei1188.dbo.common_code AS src on src.item_id = a.src_item_id
LEFT JOIN [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.common_code AS dst on dst.item_id = b.dst_item_id
WHERE 
	(
		a.pick_list_name IS NOT NULL -- total mapping provided by analyst to implementer							--
		AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer							--
		AND a.src_item_id IS NOT NULL --eliminate any incorrect provided mappings									--
		AND ISNUMERIC(a.map_dstitemid) = 1 --ignore any DNM or typo errors											--
		AND a.Map_DstItemId NOT IN --remove any dupilicate many to one mappings (Any If_merged not As_is or N)		--
			(
				select dst_Item_Id
				--select dst_Item_Id,if_merged
				from  [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalPicklist$'] a
				where dst_Item_Id in 
				(
					select map_dstitemid 
					FROM [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalPicklist$']
					WHERE pick_list_name IS NOT NULL -- total mapping provided by analyst to implementer	
						AND map_dstitemid IS NOT NULL --total count of mapping provided by implementer		
						AND src_item_id IS NOT NULL --eliminate any incorrect provided mappings	
						AND ISNUMERIC(map_dstitemid) = 1
				)
				and a.If_Merged not in ('As_is','N') -- will not take any record with 'Y'
			)
	)
	and a.id not in --remove any duplicate one to many mappings (2 or more occurances of one mapping)
		(
			select id 
			--select id, pick_list_name, src_item_description, map_dstitemid
			from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalPicklist$'] 
			where Map_DstItemId in
			(
				select Map_DstItemId
				--select Map_DstItemId, count(*)
				from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalPicklist$'] 
				where src_Item_Description is not null
				group by Map_DstItemId having count(*) > 1 and Map_DstItemId is NOT NULL
			)
			and id not in
			(			
				select min(id) 
				from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalPicklist$'] 
				group by map_dstitemid having map_dstitemid in 
					(
						select distinct Map_DstItemId 
						--select id, pick_list_name, src_item_description, map_dstitemid
						from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalPicklist$'] 
						where Map_DstItemId in
						(
							select Map_DstItemId
							--select Map_DstItemId, count(*)
							from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalPicklist$'] 
							group by Map_DstItemId having count(*) > 1 and Map_DstItemId is NOT NULL
						)
					)
			)
		)
	and src.item_id = a.src_Item_Id AND dst.item_id = b.dst_Item_Id AND src.item_code = a.item_code -- specifically used for updating the correct item
	--and src.item_id IN ( ???? ) -- any records that has to be excluded that you dont think is a proper merge

--========================================================================================

print  CHAR(13) + 'Updating clinical picklist excel advanced file - Dynamic Clinical Picklist - others non-common code advanced running now' 

/*

select a.pick_list_name,a.src_desc,b.dst_desc
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalAdvanced$'] a
inner join [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalAdvanced$'] b 
on a.map_dstitemid = b.dst_id and a.pick_list_name = b.pick_list_name
where a.map_dstitemid is not null
AND  a.src_desc IS NOT NULL 
AND a.map_dstitemid IS NOT NULL 
order by a.id

*/

print  CHAR(13) + 'Updating Administration Records (pho_administration_record)'

----select * from [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.mergeTablesmaster where tablename = 'pho_administration_record'
----administration_record_type_id	description	short_description
--		--E							S			S

------SELECT DISTINCT pick_list_name
------from  [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalAdvanced$']  where Map_DstItemId='Scope to fac'
----------pick_list_name
------Administration Records
------Immunizations
------Order Types
------Progress Note Types
------Standard Shifts


------update [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalAdvanced$']

------set Map_DstItemId=null
------where Map_DstItemId='Scope to fac'


----(91 rows affected)

----Completion time: 2022-03-17T18:12:09.8152253-04:00

UPDATE src
SET src.description = dst.description,src.short_description = dst.short_description
------SELECT distinct a.src_id, b.dst_id, src.description , dst.description,src.short_description, dst.short_description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalAdvanced$'] a
LEFT JOIN [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalAdvanced$'] b ON a.Map_DstItemId = b.dst_id
LEFT JOIN [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.pho_administration_record AS src on src.administration_record_id = a.src_id
LEFT JOIN [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.pho_administration_record AS dst on dst.administration_record_id = b.dst_id
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = 'Administration Records'  

print  CHAR(13) + 'Updating Order Types (pho_order_type)'

----select * from [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.mergeTablesmaster where tablename = 'pho_order_type'
----description	mandatory_end_date	order_category_id	administration_record_id
--	--S				E					E					E

--------Select * from  [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalAdvanced$'] where src_id=355

--------update [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalAdvanced$']

--------set Map_DstItemId=NULL
--------where Map_DstItemId=38
--------and src_id=355

UPDATE src
SET src.description = dst.description
----------SELECT distinct a.src_id, b.dst_id, src.description , dst.description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalAdvanced$'] a
LEFT JOIN [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalAdvanced$'] b ON a.Map_DstItemId = b.dst_id
LEFT JOIN [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.pho_order_type AS src on src.order_type_id = a.src_id
LEFT JOIN [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.pho_order_type AS dst on dst.order_type_id = b.dst_id
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = 'Order Types'  

print  CHAR(13) + 'Updating Progress Note Types (pn_type)'

----select * from [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.mergeTablesmaster where tablename = 'pn_type'
----description retired       template_id   system
--       --S      E               E           E

----Select * from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalAdvanced$'] where pick_list_name = 'Progress Note Types'
----and id=66

----UPDATE [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalAdvanced$'] 
----set dst_id=32
----where pick_list_name = 'Progress Note Types'
----and id=66

UPDATE src
SET src.description = dst.description
------SELECT distinct a.src_id, b.dst_id, src.description , dst.description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalAdvanced$'] a
LEFT JOIN [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalAdvanced$'] b ON a.Map_DstItemId = b.dst_id
LEFT JOIN [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.pn_type AS src on src.pn_type_id = a.src_id
LEFT JOIN [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.pn_type AS dst on dst.pn_type_id = b.dst_id
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = 'Progress Note Types'  

print  CHAR(13) + 'Updating Immunizations - (cr_std_immunization)'

----select * from [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.mergeTablesmaster where tablename = 'cr_std_immunization'
----description track_results multi_step    short_description
--       --S           E         E                   S



UPDATE src
SET src.description = dst.description,src.short_description = dst.short_description
------SELECT distinct a.src_id, b.dst_id, src.description , dst.description, src.short_description, dst.short_description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalAdvanced$'] a
LEFT JOIN [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalAdvanced$'] b ON a.Map_DstItemId = b.dst_id
LEFT JOIN [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.cr_std_immunization AS src on src.std_immunization_id = a.src_id
LEFT JOIN [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.cr_std_immunization AS dst on dst.std_immunization_id = b.dst_id
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = 'Immunizations'  

print  CHAR(13) + 'Updating Standard Shifts (cp_std_shift)'

----select * from [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.mergeTablesmaster where tablename = 'cp_std_shift'
----description start_time    end_time
--       --S         E            E
	   
UPDATE src
SET src.description = dst.description
------SELECT distinct a.src_id, b.dst_id, src.description , dst.description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalAdvanced$'] a
LEFT JOIN [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalAdvanced$'] b ON a.Map_DstItemId = b.dst_id
LEFT JOIN [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.cp_std_shift AS src on src.std_shift_id = a.src_id
LEFT JOIN [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.cp_std_shift AS dst on dst.std_shift_id = b.dst_id
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = 'Standard Shifts'  

print  CHAR(13) + 'Updating Risk Management Picklists (inc_std_pick_list)'

----select * from [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.mergeTablesmaster where tablename = 'inc_std_pick_list_item'
----description system_flag   pick_list_id
--       --S        E              E

UPDATE src
SET src.description = dst.description
----SELECT distinct a.src_id, b.dst_id, src.description , dst.description
from [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalAdvanced$'] a
LEFT JOIN [vmuspassvtsjob1.pccprod.local].FacAcqMapping.dbo.['PMO-010798_ClinicalAdvanced$'] b ON a.Map_DstItemId = b.dst_id
LEFT JOIN [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.inc_std_pick_list_item AS src on src.pick_list_item_id = a.src_id
LEFT JOIN [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.inc_std_pick_list_item AS dst on dst.pick_list_item_id = b.dst_id
WHERE  a.src_desc IS NOT NULL -- total mapping provided by analyst to implementer    
AND a.map_dstitemid IS NOT NULL --total count of mapping provided by implementer  
and a.pick_list_name = 'Risk Management Picklists'  
