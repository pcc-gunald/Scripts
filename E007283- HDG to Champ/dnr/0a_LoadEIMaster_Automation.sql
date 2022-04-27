
use ds_merge_master


/*
--Unique PMO numbers for Unique Runs
*/

--select * from LoadEIMaster_New_Multi_Fac where PMO_Group_Id = 103
INSERT INTO ds_merge_master.dbo.LoadEIMaster_PMO_Groups
(PMONumber,Completed)
SELECT 
'007283' as PMONumber, --PMO Number
0 as Completed

select * from LoadEIMaster_PMO_Groups where PMONumber like '%007283%'--1720

--select * from LoadEIMaster_Automation
--1 -> 10
begin tran

--Mission Terrace[src]/Mission Park Health Center[dst]
INSERT INTO ds_merge_master.dbo.LoadEIMaster_Automation
(PMO_Group_Id,CaseNo,PMO_number,SrcOrgCode,StgOrgCode,DstOrgCode,DstOrgCodeProd,SrcFacID,StgFacID,DstFacID,ContMerge,ProdRun
,PreCaseFac,PreCaseBed,ModList,StagingCompleted
,Completed,FacilityRunOrder)
SELECT '1724' as [PMO_Group_Id], --PMO_Group_ID created
'0072832' as [CaseNo],-- Case Number, unique per facility
'007283'as [PMO_number],-- PMO Number
'usei547' as [SrcOrgCode],-- source
'pcc_staging_db007283' as  [STgOrgCode], --staging DB, same for all facilities within one PMO
'usei1062' as [DstOrgCode],--destination
'usei1062' as [DstOrgCodeProd], --org code of current destination
2 as [SrcFacID],--
1 as [StgFacID],--
50 as [DstFacID],--
0 as [ContMerge], --0 = No,1 = Yes
0 as [ProdRun], --0 = No,1 = Yes
0 as [PreCaseFac], --0 = No,1 = Yes
0 as [PreCaseBed], --0 = No,1 = Yes
'E14,E15,E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E8,E12a,E11,E9,E10,E13,E17,E20,E21,E22' as [ModList],
0 as [StagingCompleted], -- 0 not completed, 1 = completed
0 as [Completed], -- 0 not completed, 1 = completed
1 as [FacilityRunOrder] --starts from 1, incremental by 1 for the later facilities

rollback tran

select * from LoadEIMaster_Automation where PMO_Number = '007283'
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
'E14,' --Security Roles
,'E15,' --Security Users
,'E1,'  --Resident Identifier, Contact
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
,'E21,'-- Lab & Radiology
,'E22,'-- Master Insurance Companies
,'E23'-- Admin Notes
)