/*

AUTOPRE Sript_Auto_Only Copy CurrentResident 
	(if current residents only)
if sec user pre import uncomment the below
	(if security pre-import)
UDA Lib Merge  --when copy UDAs AND copy more than 1 fac
	(AUTOPRE - Include starting from the 2nd Facility run)
CCRS Error
external facilities hotlist items only
AUTOPRE If copy Upload Files but not PN-AUTOPRE If copy Upload Files but not PN
	(if upload files but not progress notes)
15 months of MDS


*/

--==================================================================================================================

----AUTOPRE Sript_Auto_Only Copy CurrentResident (if current residents only)

--UPDATE mergetablesmaster
--SET QueryFilter = ' AND client_id in (SELECT client_id from [origDB].clients where fac_id = [OrigFacId] 
--					and (discharge_date is null or discharge_date >= ''R_CURRESDATE'' ) 
--					AND admission_Date is not null) '
--WHERE tablename = 'clients'

--UPDATE mergetablesmaster
--SET QueryFilter = ' AND mpi_id in (SELECT mpi_id from [origDB].clients where fac_id = [OrigFacId] 
--					and (discharge_date is null or discharge_date >= ''R_CURRESDATE'' ) 
--					AND admission_Date is not null) '
--WHERE tablename = 'mpi'

--==================================================================================================================

----if sec user pre import uncomment the below 

--CREATE TABLE [dbo].[EIcaseR_CASENUMBER4sec_user]( 
--[row_id] [int] IDENTITY(1,1) NOT NULL,
--[src_id] [bigint] NULL,
--[dst_id] [bigint] NULL,
--[corporate] [char](1) NULL DEFAULT ('N')
--) ON [PRIMARY]

--SET IDENTITY_INSERT EIcaseR_CASENUMBER4sec_user ON 

--insert into EIcaseR_CASENUMBER4sec_user (row_id,src_id,dst_id,corporate)
--select row_id, src_id,dst_id,corporate from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.EIcaseR_CASENUMBER4sec_user

--SET IDENTITY_INSERT EIcaseR_CASENUMBER4sec_user OFF

--==================================================================================================================

--UDA Lib Merge  --when copy UDAs AND copy more than 1 fac
--AUTOPRE - Include starting from the 2nd Facility run

----From the 2nd facility on
--update  mergetablesmaster
--set  
----idField = 'std_assess_id',
----tableorder = '11200',
--scopeField1 = 'description',
--scopeField2 = 'is_mds',
--scopeField3 = 'status'
----select  *  from mergetablesmaster
--where tablename='AS_STD_ASSESSMENT'

--update  mergetablesmaster
--set  
--queryfilter = ' AND category_id IN (SELECT src_id from [DestDB].[prefix]as_std_category where corporate = ''N'')   '
----select  *  from mergetablesmaster
--where tablename='as_std_category_audit'

--==================================================================================================================

----CCRS error

--update  mergetablesmaster
--set  queryfilter =' AND  pick_list_id not in ('id that you get from your investigation')  '  --src ID's seen from pre CCRS script
----select  *  from mergetablesmaster
--where tablename='as_std_pick_list'

--update  mergetablesmaster
--set  queryfilter ='AND pick_list_id not in (350)'
--where tablename='as_std_pick_list'

DECLARE @ConCat VARCHAR(255) = '';  
DECLARE @SampleTable TABLE(Value VARCHAR(5));

SELECT @ConCat = @ConCat + ', ' + CAST(src.pick_list_id AS VARCHAR)
FROM [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.as_std_pick_list AS src
LEFT OUTER JOIN [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1214.dbo.as_std_pick_list AS dst ON src.[description] = dst.[description] AND src.std_assess_id = dst.std_assess_id
WHERE src.std_assess_id = 3
	AND src.[description] IS NOT NULL
	AND dst.[description] IS NULL
ORDER BY src.pick_list_id

--print @concat

if @concat = ''
--print 'yes'
update  mergetablesmaster
set  queryfilter ='AND pick_list_id not in (350)'
where tablename='as_std_pick_list'

if @concat <> ''
--print 'no'
update  mergetablesmaster
set  queryfilter ='AND pick_list_id not in (350'+@ConCat+')'
where tablename='as_std_pick_list'

--==================================================================================================================

----external facilities hotlist items only

--update  mergeTablesMaster
--set  queryfilter=' and ext_fac_id in (select ext_fac_id from [origDB].ext_facilities where fac_id = [OrigFacId] ) '
----select * from mergetablesmaster
--where tablename='emc_ext_facilities'

--==================================================================================================================

--AUTOPRE If copy Upload Files but not PN

--create a dummy  mapping table for  pn_progress_note  if this was excluded in  Extract/Import
--but  upload files is included
--does not come with the  EI ---  1/24/2017

--CREATE TABLE [dbo].[EICaseR_CASENUMBER4pn_progress_note](  
--[row_id] [int] IDENTITY(1,1) NOT NULL,
--[src_id] [bigint] NULL,
--[dst_id] [bigint] NULL,
--[corporate] [char](1) NULL DEFAULT ('N')
--) ON [PRIMARY]

--==================================================================================================================

----15 months of MDS

--update  mergeTablesMaster
--set  queryfilter=' and (assess_ref_date >= ''2018-11-29 00:00:00.000'' or assess_ref_date is null) '
--where tablename = 'as_assessment'

--==================================================================================================================

-----Always Run

delete from mergetablesmaster where tablename = 'devprg_hist_medication_landing'--1
delete from mergejoinsmaster where tablename = 'devprg_hist_medication_landing'--3
delete from mergejoinsmaster where parenttable = 'devprg_hist_medication_landing'--2

delete from mergetablesmaster where tablename = 'devprg_hist_care_period_landing'--1
delete from mergejoinsmaster where tablename = 'devprg_hist_care_period_landing'--3
delete from mergejoinsmaster where parenttable = 'devprg_hist_care_period_landing'--2

delete from mergetablesmaster where tablename = 'devprg_hist_diagnosis_landing'--1
delete from mergejoinsmaster where tablename = 'devprg_hist_diagnosis_landing'--3
delete from mergejoinsmaster where parenttable = 'devprg_hist_diagnosis_landing'--2

delete from mergetablesmaster where tablename = 'devprg_hist_medication_diagnosis_landing'--1
delete from mergejoinsmaster where tablename = 'devprg_hist_medication_diagnosis_landing'--3
delete from mergejoinsmaster where parenttable = 'devprg_hist_medication_diagnosis_landing'--2

delete from mergetablesmaster where tablename = 'devprg_hist_medication_administration_schedule_landing'--1
delete from mergejoinsmaster where tablename = 'devprg_hist_medication_administration_schedule_landing'--3
delete from mergejoinsmaster where parenttable = 'devprg_hist_medication_administration_schedule_landing'--2

update mergeJoinsMaster
set pkJoin = 'N'
--select * 
from mergeJoinsMaster 
where parenttable = 'pn_progress_note'
and tablename = 'pho_admin_strikeout' 
and pkJoin = 'Y' 

update mergetablesmaster
set idfield = 'bed_date_range_id'
--select *
from mergetablesmaster
where tablename = 'bed_date_range' and idfield is null

delete 
--select *
from mergetablesmaster
where tablename = 'pho_phys_order_linked_reason' 
 
delete 
--select *
from mergejoinsmaster
where parenttable = 'pho_phys_order_linked_reason'
 
delete 
--select *
from mergejoinsmaster
where tablename = 'pho_phys_order_linked_reason'  

--==================================================================================================================

--For enhanced always run

UPDATE mergeTablesMaster
SET queryfilter = replace(QueryFilter, '[destDB]', '[stagDB]')
--select *
FROM mergeTablesMaster
WHERE (QueryFilter LIKE '%prefix%' AND QueryFilter LIKE '%destDB%')

--==================================================================================================================

delete mergejoinsmaster where tablename = 'care_profile_value_single_audit'
delete mergejoinsmaster where parenttable = 'care_profile_value_single_audit'
delete mergetablesmaster where tablename = 'care_profile_value_single_audit'

delete mergejoinsmaster where tablename = 'care_profile_value_multiple_audit'
delete mergejoinsmaster where parenttable = 'care_profile_value_multiple_audit'
delete mergetablesmaster where tablename = 'care_profile_value_multiple_audit'

--==================================================================================================================

----if trust is authorized

--delete from mergetablesmaster where tablename = 'gl_batch'--1
--delete from mergejoinsmaster where tablename = 'gl_batch'--3
--delete from mergejoinsmaster where parenttable = 'gl_batch'--2

--delete from mergetablesmaster where tablename = 'ta_discharge_option'--1
--delete from mergejoinsmaster where tablename = 'ta_discharge_option'--3
--delete from mergejoinsmaster where parenttable = 'ta_discharge_option'--2

--delete from mergetablesmaster where tablename = 'ta_interest_calculate_method'--1
--delete from mergejoinsmaster where tablename = 'ta_interest_calculate_method'--3
--delete from mergejoinsmaster where parenttable = 'ta_interest_calculate_method'--2

--==================================================================================================================


--delete from mergetablesmaster where tablename = 'as_ard_adl_keys'
--delete from mergejoinsmaster where tablename = 'as_ard_adl_keys'
--delete from mergejoinsmaster where parenttable = 'as_ard_adl_keys'


--update mergetablesmaster
--set scopeField3 = 'sign_id'
----select *
--from mergetablesmaster
--where tablename = 'inc_std_signing_authorit