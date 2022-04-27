
use ds_merge_master


/*
--Unique PMO numbers for Unique Runs
*/

--select * from LoadEIMaster_New_Multi_Fac where PMO_Group_Id = 103
INSERT INTO ds_merge_master.dbo.LoadEIMaster_PMO_Groups
(PMONumber,Completed)
SELECT 
'58872' as PMONumber, --PMO Number
0 as Completed

SELECT SCOPE_IDENTITY()

select * from LoadEIMaster_PMO_Groups where PMONumber like '%58872%'--1720

drop table if exists #temp_fac
create table #temp_fac(caseNo varchar(50),src_id int, dest_id int, id int identity (1,1))

insert into #temp_fac values('58872',6,68)

INSERT INTO ds_merge_master.dbo.LoadEIMaster_Automation(PMO_Group_Id,CaseNo,PMO_number,SrcOrgCode,StgOrgCode,DstOrgCode,DstOrgCodeProd,SrcFacID,StgFacID,DstFacID,ContMerge,ProdRun
,PreCaseFac,PreCaseBed,ModList,StagingCompleted
,Completed,FacilityRunOrder)
SELECT '1733' as [PMO_Group_Id], --PMO_Group_ID created
concat(caseNo,id) as [CaseNo],-- Case Number, unique per facility
caseNo as [PMO_number],-- PMO Number
'usei630' as [SrcOrgCode],-- source
'pcc_staging_db58872' as  [STgOrgCode], --staging DB, same for all facilities within one PMO
'usei587' as [DstOrgCode],--destination
'usei587' as [DstOrgCodeProd], --org code of current destination
src_id as [SrcFacID],--
src_id as [StgFacID],--
dest_id as [DstFacID],--
0 as [ContMerge], --0 = No,1 = Yes
0 as [ProdRun], --0 = No,1 = Yes
0 as [PreCaseFac], --0 = No,1 = Yes
0 as [PreCaseBed], --0 = No,1 = Yes
'E14,E15,E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E21,E22,E23' as [ModList],
0 as [StagingCompleted], -- 0 not completed, 1 = completed
0 as [Completed], -- 0 not completed, 1 = completed
id as [FacilityRunOrder] --starts from 1, incremental by 1 for the later facilities
from #temp_fac


select * from LoadEIMaster_Automation where PMO_Number = '58872'
/*
RunID	PMO_Group_Id	CaseNo	PMO_number	SrcOrgCode	StgOrgCode	DstOrgCode	DstOrgCodeProd	SrcFacID	StgFacID	DstFacID	ContMerge
522	1720	5879117	58791	usei1075	pcc_staging_db58791	usei52	usei52	1	1	17	0
*/
--PMO58791_EICase5879117_payermapping_fac_1_to_10

/*
begin tran
update LoadEIMaster_Automation set
ModList = 'E14,E15,E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E21,E22,E23'
--select * from LoadEIMaster_Automation
where PMO_Number = ''
commit
rollback tran
*/

select 
CONCAT(
--'E14,' --Security Roles
--,'E15,' --Security Users
--,
'E1,'  --Resident Identifier, Contact
,'E2,'  --Staff
,'E2a,'--   Medical Professional
,'E3,'--    External Facility
,'E4,'--    User Defined Data
,'E5,'--    Room and Bed
,'E6,'--    Census
,'E7a,'--   MDS 2.0
,'E7b,'--   MDS 3
,'E7c,'--   Custom UDA
--,'E7d,'-- MMQ MMQ (state of Massachusetts - MA)
--,'E7e,'-- MMA MMA (state of Maryland - MD)
,'E8,'--    Diagnosis
,'E12a,'-- Custom Care Plan
,'E12b,'-- Care Plan Copy Library
,'E11,'--   Immunization
,'E9,'--    Progress Note
,'E10,'--   Weights and Vital
,'E13,'--   Phys Orders
,'E16,'-- Alert
,'E17,'-- Risk Management
,'E18,'-- Trust
--,'E19a,'-- IRM --do not use
--,'E19b,'-- IRM --do not use
,'E20,'--   Upload Files
--,'E21,'-- Lab & Radiology
,'E22,'-- Master Insurance Companies
,'E23'-- Admin Notes
)


select * from LoadEIMaster_Automation where PMO_Number = '58872'

update LoadEIMaster_Automation
set Modlist='E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E22,E23'
where PMO_Number = '58872'

