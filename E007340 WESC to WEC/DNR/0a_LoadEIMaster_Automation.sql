
use ds_merge_master


/*
--Unique PMO numbers for Unique Runs
*/

--select * from LoadEIMaster_New_Multi_Fac where PMO_Group_Id = 103

select * from LoadEIMaster_PMO_Groups where PMONumber like '%007340%'
select * from LoadEIMaster_PMO_Groups where PMO_Group_id = 1785

INSERT INTO ds_merge_master.dbo.LoadEIMaster_PMO_Groups
(PMONumber,Completed)
SELECT 
'007340' as PMONumber, --PMO Number
0 as Completed




select * 
from LoadEIMaster_Automation where [PMO_Group_Id] = 1785


begin tran

INSERT INTO ds_merge_master.dbo.LoadEIMaster_Automation
(PMO_Group_Id,CaseNo,PMO_number,SrcOrgCode,StgOrgCode,DstOrgCode,DstOrgCodeProd,SrcFacID,StgFacID,DstFacID,ContMerge,ProdRun
,PreCaseFac,PreCaseBed,ModList,StagingCompleted
,Completed,FacilityRunOrder)
SELECT '1785' as [PMO_Group_Id], --PMO_Group_ID created
'0073404' as [CaseNo], -- Case Number, unique per facility
'007340'as [PMO_number], -- PMO Number
'usei549' as [SrcOrgCode],-- source
'pcc_staging_db007340' as  [STgOrgCode], --staging DB, same for all facilities within one PMO
'usei1063' as [DstOrgCode],--destination
'usei1063' as [DstOrgCodeProd], --org code of current destination
4 as [SrcFacID],--
1 as [StgFacID],--
6 as [DstFacID],--
0 as [ContMerge], --0 = No,1 = Yes
0 as [ProdRun], --0 = No,1 = Yes
0 as [PreCaseFac], --0 = No,1 = Yes
0 as [PreCaseBed], --0 = No,1 = Yes
'E14,E15,E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E21,E22,E23' as [ModList],
0 as [StagingCompleted], -- 0 not completed, 1 = completed
0 as [Completed], -- 0 not completed, 1 = completed
1 as [FacilityRunOrder] --starts from 1, incremental by 1 for the later facilities

rollback tran

/*
begin tran

update a 
set a.ModList = 'E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E16,E17,E20,E21,E22,E23'
--select *
from LoadEIMaster_Automation a
where PMO_Group_Id = 1785

rollback tran

begin tran

update a 
set 
a.srcorgcode = 'usei549',
a.DstOrgCode = 'usei750',
a.DstOrgCodeProd = 'usei750'
--select *
from LoadEIMaster_Automation a
where PMO_Group_Id = 1785

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
,'E12b,'-- Care Plan Copy Library
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
,'E22,'-- Master Insurance Companies
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
