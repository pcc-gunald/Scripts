--use pcc_staging_db55549 --Run in DST TSCON10

print 'Row Comparison Staging SRC to DST Server'

--Part 1
---------------------------------------------------------------------------
--drop table  #new
--drop table  #orig

print 'SRC [pccsql-use2-prod-ssv-tscon11.b4ea653240a9.database.windows.net].[pcc_staging_db55549]'
--ON SRC
SELECT t.name AS table_name, i.rows 
into #orig
--select *
FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.[pcc_staging_db59277].sys.tables AS t with (nolock)
INNER JOIN [vmuspassvtscon3.pccprod.local].test_usei3sava1.[pcc_staging_db59277].sys.sysindexes AS i with (nolock) ON t.object_id = i.id AND i.indid < 2
where i.rows > 0 and t.name not like 'if_us%' and t.name not like 'case%'
order by 2 desc  
--1197

print 'DST [pccsql-use2-prod-w31-cli0024.90c2966cd166.database.windows.net].[pcc_staging_db55549]'
--ON DST
SELECT t.name AS table_name, i.rows 
into #new
--select *
FROM [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.[pcc_staging_db59277].sys.tables AS t with (nolock)
INNER JOIN [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.[pcc_staging_db59277].sys.sysindexes AS i with (nolock) ON t.object_id = i.id AND i.indid < 2
where i.rows > 0 and t.name not like 'if_us%' and t.name not like 'case%'
order by 2 desc  --(1834 row(s) affected)
--1197


--Part 2
---------------------------------------------------------------------------
------TABLES HAVE DATA IN BOTH WITH DIFFERENT ROW COUNTS
select a.*,b.*
--into pcc_temp_storage.dbo.tables_withDiscrepancies
from #orig a inner join #new b
on a.table_name = b.table_name
where a.rows <> b.rows
--and a.table_name not like  '%gl_%'
--and a.table_name not like '%ar_%' --167
--and a.table_name not like '%ap_%' --167
--and a.table_name not like '%cp_prn%' --161
--and a.table_name not like '%cp_qshift%' --161
--and a.table_name not like '%ta_%' --129
--and  a.table_name not like '%as_%'
--and  a.table_name not like '%pho_%'
--and  a.table_name not like '%diag_%'
--and  a.table_name not like '%cp_%'
--and  a.table_name  like '%_audit%'
--and  a.table_name  like '%_fac%'
order by 1 ---10
--0

------TABLES HAVE DATA IN SRC BUT NOT IN DST------
select * from #orig
where table_name not in (select table_name from #new)
--0

------TABLES HAVE DATA IN DST BUT NOT IN SRC------
select * from #new
where table_name not in (select table_name from #orig)
--0

--F5

--You can replace the staging DB and destination DB name here, and you can try this test before staging to destination after the staging DB is moved over to destination instance.

print 'Correcting Staging DB'
use [pcc_staging_db55549]

--begin tran
--rollback tran
/*

delete 
--select *
from  test_usei1026.dbo.ListOfTables
where tablename = 'as_std_category_audit'

select * from [pccsql-use2-prod-w31-cli0024.90c2966cd166.database.windows.net].test_usei1026.dbo.ListOfTables with (nolock)
 */

 print'OK NOT 0'
print'--pho_std_time_details--'

 --The INSERT statement conflicted with the FOREIGN KEY constraint "pho_std_time_details__shiftId_FK". The conflict occurred in database "test_usei1026", table "dbo.cp_std_shift", column 'std_shift_id'.

update a 
set shift_id = null
--select * 
from [pccsql-use2-prod-w31-cli0024.90c2966cd166.database.windows.net].pcc_staging_db55549.dbo.pho_std_time_details as a
where shift_id not in (select std_shift_id from test_usei1026.dbo.cp_std_shift)
--3

print'OK NOT 0'
print'--pn_std_spn_text--'
--merge error: The INSERT statement conflicted with the FOREIGN KEY constraint "pn_std_spn_text__sectionId_FK". 
--The conflict occurred in database "test_usei1026", table "dbo.pn_template_section", column 'section_id'.

--Have to remove the (3) entries from below because the section_id (100340,100342,100341) do NOT exist in pn_template_section
delete
--select * 
FROM [pccsql-use2-prod-w31-cli0024.90c2966cd166.database.windows.net].pcc_staging_db55549.dbo.pn_std_spn_text
where section_id in (100340,100342,100341)
--707


print'OK NOT 0'
print'--pn_progress_note--'
--MergeError:The INSERT statement conflicted with the FOREIGN KEY constraint "pn_progress_note__createdByUserid_FK". The conflict occurred in database "test_usei1026", table "dbo.sec_user", column 'userid'.

update a
set created_by_userid = null
--select * 
FROM [pccsql-use2-prod-w31-cli0024.90c2966cd166.database.windows.net].pcc_staging_db55549.dbo.pn_progress_note as a
WHERE created_by_userid in (255265)


print'OK NOT 0'
print'--fac_message--'


IF OBJECT_ID('dbo._bkp_EICase55873008_fac_message_post', 'U') IS NOT NULL 
  DROP TABLE dbo._bkp_EICase55873008_fac_message_post; 

select * into [pcc_staging_db55549].dbo._bkp_EICase55873008_fac_message_post from [pcc_staging_db55549].dbo.[fac_message]

delete 
--select * 
from [pcc_staging_db55549].dbo.[fac_message]


print'OK NOT 0'
print'--pho_std_order_set--'
--Cannot insert duplicate key row in object 'dbo.pho_std_order_set' with unique index 'pho_std_order_set__setDescription_UIX'. The duplicate key value is (ADVANCED DIRECTIVES---).

update a
set set_description = left(set_description,97)+'---'
--SELECT *
FROM pcc_staging_db55549.dbo.pho_std_order_set as a
where set_description in (select set_description from test_usei1026.dbo.pho_std_order_set)

print'OK NOT 0'
print'--pho_std_order--'

 --Merge Error:Cannot insert duplicate key row in object 'dbo.pho_std_order' with unique index 'pho_std_order__templateDescriptionForMobile_UIX'. The duplicate key value is (CPR------, 0).
update a
set template_description = left(template_description,99)+'-'
--SELECT std_order_id,template_description,status,order_category_id,communication_method,auto_created,advanced_directive,description,route_of_admin,drug_name,drug_strength,drug_strength_uom,drug_form,controlled_substance_code,ext_lib_id,ext_lib_med_id,ext_lib_generic_id,ext_lib_generic_desc,ext_lib_med_ddid,fac_id,reg_id,state_code,created_by,created_date,revision_by,revision_date,published_by,published_date,retired_date,retired_by,reactivated_date,reactivated_by,dispense_as_written,ext_lib_rxnorm_id,alter_med_src,nurse_pharm_notes,do_not_fill,personalization_required,created_by_audit_id,revision_by_audit_id,published_by_audit_id,retired_by_audit_id,reactivated_by_audit_id,related_generic,system_template,for_mobile,for_web
FROM pcc_staging_db55549.dbo.pho_std_order as a
where template_description+CAST(for_mobile AS varchar) in (select template_description+CAST(for_mobile AS varchar) from test_usei1026.dbo.pho_std_order)

print'OK NOT 0'
print'--as_std_pick_list--'
--Cannot insert non-standard CCRS pick list.  Please check latest negative pick list id for standard range.
delete 
--select * 
from pcc_staging_db55549.dbo.as_std_pick_list 
where std_assess_id = 3 

print'--cp_std_intervention--poc_std_freq_id'
update a
set poc_std_freq_id = null
--select distinct poc_std_freq_id 
from pcc_staging_db55549.dbo.cp_std_intervention as a
where poc_std_freq_id not in (select std_freq_id from test_usei1026.dbo.cp_std_frequency)

print'--cp_std_intervention--std_freq_id'
update a
set std_freq_id = null
--select distinct std_freq_id 
from pcc_staging_db55549.dbo.cp_std_intervention as a
where std_freq_id not in (select std_freq_id from test_usei1026.dbo.cp_std_frequency)


print'--Contact--'
select * from Contact
where Contact_number in (select Contact_number from test_usei1026.dbo.Contact)


print'--as_assess_schedule--'
select * from as_assess_schedule
where triggered_by_assess_id is not null
and triggered_by_assess_id not in 
(select assess_id from as_assessment)

print'OK NOT 0'
print'--pho_std_order--'
update a
set template_description = template_description +'----'
--select * 
from pho_std_order as a
where template_description in 
(select template_description from test_usei1026.dbo.pho_std_order)

print'S/B 0'
print'--pho_std_order--'
select * from pho_std_order
where template_description in 
(select template_description from test_usei1026.dbo.pho_std_order)



print'--pho_std_order_set--'
select * from pho_std_order_set
where set_description in 
(select set_description from test_usei1026.dbo.pho_std_order_set)



print'OK NOT 0'
print'--pho_admin_order--'
update pho_admin_order
set noted_by = NULL
--select * from pho_admin_order
where noted_by is not null
and noted_by not in
(select userid from sec_user
union
select userid from test_usei1026.dbo.sec_user)

print'--pho_admin_order--'
select distinct noted_by from pho_admin_order
where noted_by is not null
and noted_by not in
(select userid from sec_user
union
select userid from test_usei1026.dbo.sec_user)

print'--pho_phys_order_audit_useraudit--created_by_audit_id--'
select * from pho_phys_order_audit_useraudit
where created_by_audit_id not in 
(select cp_sec_user_audit_id from cp_sec_user_audit
union
select cp_sec_user_audit_id from test_usei1026.dbo.cp_sec_user_audit)

print'--pho_phys_order_audit_useraudit--edited_by_audit_id--'
select * from pho_phys_order_audit_useraudit
where edited_by_audit_id not in 
(select cp_sec_user_audit_id from cp_sec_user_audit
union
select cp_sec_user_audit_id from test_usei1026.dbo.cp_sec_user_audit)

print'--pho_phys_order_audit_useraudit--confirmed_by_audit_id--'
select * from pho_phys_order_audit_useraudit
where confirmed_by_audit_id not in 
(select cp_sec_user_audit_id from cp_sec_user_audit
union
select cp_sec_user_audit_id from test_usei1026.dbo.cp_sec_user_audit)

print'--diagnosis--'
select * from diagnosis
where assess_id is not null
and assess_id not in
(select assess_id from as_assessment
union
select assess_id from test_usei1026.dbo.as_assessment)

