
use ds_merge_master


/*
--Unique PMO numbers for Unique Runs
*/

--select * from LoadEIMaster_New_Multi_Fac where PMO_Group_Id = 103

select * from LoadEIMaster_PMO_Groups where PMONumber like '%009632%'


INSERT INTO ds_merge_master.dbo.LoadEIMaster_PMO_Groups
(PMONumber,Completed)
SELECT 
'009632' as PMONumber, --PMO Number
0 as Completed

select * from LoadEIMaster_Automation where PMO_Number like '%009632%'

drop table #temp

create table #temp
(CaseNo varchar(1000), srcFacID int, DstFacID int, FacilityRunOrder int identity (1,1))

--fac id = 5, 11, 18, 19, 20, 21, 22, 26, 27, 28
insert into #temp values 
('00963220',20, 15)
,('00963221',21, 16)



select * from #temp

begin tran

INSERT INTO ds_merge_master.dbo.LoadEIMaster_Automation
(PMO_Group_Id,CaseNo,PMO_number,SrcOrgCode,StgOrgCode,DstOrgCode,DstOrgCodeProd,SrcFacID,StgFacID,DstFacID,ContMerge,ProdRun
,PreCaseFac,PreCaseBed,ModList,StagingCompleted
,Completed,FacilityRunOrder)
SELECT '1843' as [PMO_Group_Id], --PMO_Group_ID created
CaseNo as [CaseNo], -- Case Number, unique per facility
'009632'as [PMO_number], -- PMO Number
'usei435' as [SrcOrgCode],-- source
'pcc_staging_db009632' as  [STgOrgCode], --staging DB, same for all facilities within one PMO
'usei425' as [DstOrgCode],--destination
'usei425' as [DstOrgCodeProd], --org code of current destination
SrcFacID as [SrcFacID],--
1 as [StgFacID],--
DstFacID as [DstFacID],--
0 as [ContMerge], --0 = No,1 = Yes
0 as [ProdRun], --0 = No,1 = Yes
0 as [PreCaseFac], --0 = No,1 = Yes
0 as [PreCaseBed], --0 = No,1 = Yes
'E14,E15,E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E8,E12a,E11,E9,E10,E13,E16,E17,E20,E21,E22' as [ModList],
0 as [StagingCompleted], -- 0 not completed, 1 = completed
0 as [Completed], -- 0 not completed, 1 = completed
FacilityRunOrder as [FacilityRunOrder] --starts from 1, incremental by 1 for the later facilities
from #temp 

rollback tran


select concat('PMO',PMO_number, '_EICase',CaseNo,'_payermapping_fac_',SrcFacID,'_to_',DstFacId)
from LoadEIMaster_Automation a
where PMO_Group_Id = 1843

update a
set a.[STgOrgCode] = 'pcc_staging_db009632'
--select * 
from LoadEIMaster_Automation a
where pmo_group_id = 1843




/*
begin tran

update a 
set a.DstOrgCode = 'TRANQ',
a.DstOrgCodeProd = 'TRANQ',
a.prodrun = 1
--select *
from LoadEIMaster_Automation a
where PMO_Group_Id = 1843

begin tran

delete 
--select *
from LoadEIMaster_Automation
where PMO_Group_Id = 1739

rollback tran

rollback tran

begin tran

update a 
set a.DstOrgCode = 'u',
a.DstOrgCodeProd = ''
--select *
from LoadEIMaster_Automation a
where RunID = 
and PMO_Group_Id = 

rollback tran
*/

select 
CONCAT(
'E14,' --Security Roles
,'E15,'	--Security Users
,'E1,'	--Resident Identifier, Contact
,'E2,'	--Staff
,'E2a,'--	Medical Professional
,'E3,'--	External Facility
,'E4,'--	User Defined Data
,'E5,'--	Room and Bed
,'E6,'--	Census
,'E7a,'--	MDS 2.0
,'E7b,'--	MDS 3
,'E7c,'--	Custom UDA
--,'E7d,'-- MMQ (state of Massachusetts - MA)
--,'E7e,'-- MMA (state of Maryland - MD)
,'E8,'--	Diagnosis
,'E12a,'-- Custom Care Plan
--,'E12b,'-- Care Plan Copy Library
,'E11,'--	Immunization
,'E9,'--	Progress Note
,'E10,'--	Weights and Vital
,'E13,'--	Phys Orders
,'E16,'--	Alert
,'E17,'--	Risk Management
,'E18,'--	Trust
--,'E19a,'-- IRM --do not use
--,'E19b,'-- IRM --do not use
,'E20,'--	Upload Files
,'E21,'-- Lab & Radiology
,'E22'-- Master Insurance Companies
,'E23'-- Admin Notes
)

/*
--Please note that when we insert row in the  and loadEImaster_new we need to use the following order as shown in DS Helper.
E14	Security Roles
E15	Security Users
E1	Resident Identifier, Contact
E2	Staff
E2a	Medical Professional
E3	External Facility
E4	User Defined Data
E5	Room and Bed
E6	Census
E7a	MDS 2.0
E7b	MDS 3
E7c	Custom UDA
E7d MMQ
E7e MMA
E8	Diagnosis
E12a Custom Care Plan
E12b Care Plan Copy Library
E11	Immunization
E9	Progress Note
E10	Weights and Vital
E13	Phys Orders
E16	Alert
E17	Rsik Management
E18	Trust
E19a IRM --do not use
E19b IRM --do not use
E20	Upload Files
E21 Lab & Radiology
E22 Master Insurance Companies
E23 Admin Notes

*/
