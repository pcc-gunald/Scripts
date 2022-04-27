/*
--Please note that when we insert row in the  and loadEImaster_new we need to use the following order as shown in Ds Helper.

E15	Security Users
E14	Security Roles
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
E7d	MMQ
E7e	MMA
E8	Diagnosis
E12a	Custom Care Plan
E12b	Care Plan Copy Library
E11	Immunization
E9	Progress Note
E10	Weights and Vital
E13	Phys Orders
E16	Alert
E17	Rsik Management
E26	Trust
E19a IRM --do not use
E19b IRM --do not use
E20	Upload Files
E21	Lab & Radiology
E22	Master Insurance Companies
E23	Admin Notes
*/

/*
--Unique PMO numbers for Unique Runs
*/

-- use ds_merge_master

/****
update on the go live


update [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_Automation 
set dstorgcode = 'usei9',
[DstOrgCodeProd] = 'usei9',
[ProdRun] = 1,
[StagingCompleted] = 0
where [PMO_number] = '010798'

update [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac 
set dstorgcode = 'usei9',
[DstOrgCodeProd] = 'usei9',
[ProdRun] = 1,
[StagingCompleted] = 0
where [PMO_number] = '010798'

*****/

INSERT INTO [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_PMO_Groups (PMONumber,Completed)
SELECT '010798' as PMONumber, 0 as Completed

--Taking the PMO Group ID and putting into the Load EI Master Dynamically

DECLARE @pmo_group_id INT

SELECT @pmo_group_id = pmo_group_id
FROM [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_PMO_Groups 
WHERE PMONumber = '010798'


select @pmo_group_id

----select * from [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_PMO_Groups where PMONumber = '010798'

----select * from [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac where [PMO_number] = '010798'

----select * from [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_Automation where [PMO_number] = '010798'

------@pmo_group_id

update [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_Automation 
set
--ModList='E14,E15,E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12b,E11,E9,E10,E13,E16,E20,E21,E22,E23'
DstOrgCode='vvhr',
DstOrgCodeProd='vvhr'
where [PMO_number] = '010798'
and PMO_Group_Id=1855

--and PMO_Group_Id=@pmo_group_id

--print '--------------LoadEIMasterAutomation-----------'
--ModExcluded
--E7c: Custom UDAs, E7d: MMQ, E7e: MMA, E12a: Custom Care Plan, E16: Alert, E17: Risk Management, E18: Trust, E19a: IRM, E19b: IRM

INSERT INTO [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_Automation 
(PMO_Group_Id,CaseNo,PMO_number,SrcOrgCode,StgOrgCode,DstOrgCode,DstOrgCodeProd,SrcFacID,StgFacID,DstFacID,ContMerge,ProdRun
,PreCaseFac,PreCaseBed,PreMergeScript,PreMergeScriptSrc,PreMergeScriptDst,PostMergeScript,PostMergeScriptDst,ModList,StagingCompleted
,Completed,FacilityRunOrder)
SELECT @pmo_group_id as [PMO_Group_Id], --PMO_Group_ID created
'01079812' as [CaseNo], -- Case Number, unique per facility
'010798'as [PMO_number], -- PMO Number
'usei1188' as [SrcOrgCode], -- source org code
'pcc_staging_db010798' as  [STgOrgCode], --staging DB, same for all facilities within one PMO
'usei9' as [DstOrgCode], --destination
'usei9' as [DstOrgCodeProd], --org code of current destination
7 as [SrcFacID],--
1 as [StgFacID],--
12 as [DstFacID],--
1 as [ContMerge], --0 = No,1 = Yes
0 as [ProdRun], --0 = No,1 = Yes
0 as [PreCaseFac], --0 = No,1 = Yes
0 as [PreCaseBed], --0 = No,1 = Yes
'' as [PreMergeScript], -- file path for auto-pre
'' as [PreMergeScriptSrc], --file_path for pre in source
'' as [PreMergeScriptDst], --file path for pre in destination, e.g. sec user gap import
'' as [PostMergeScript], ---- file path for post in staging (scoping)
'' as [PostMergeScriptDst], --file path for post in destination
'E14,E15,E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E8,E12b,E11,E9,E10,E13,E20,E21,E22,E23' as [ModList],
0 as [StagingCompleted], -- 0 not completed, 1 = completed
0 as [Completed], -- 0 not completed, 1 = completed
1 as [FacilityRunOrder] --starts from 1, incremental by 1 for the later facilities 

INSERT INTO [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_Automation 
(PMO_Group_Id,CaseNo,PMO_number,SrcOrgCode,StgOrgCode,DstOrgCode,DstOrgCodeProd,SrcFacID,StgFacID,DstFacID,ContMerge,ProdRun
,PreCaseFac,PreCaseBed,PreMergeScript,PreMergeScriptSrc,PreMergeScriptDst,PostMergeScript,PostMergeScriptDst,ModList,StagingCompleted
,Completed,FacilityRunOrder)
SELECT @pmo_group_id as [PMO_Group_Id], --PMO_Group_ID created
'01079813' as [CaseNo], -- Case Number, unique per facility
'010798'as [PMO_number], -- PMO Number
'usei1188' as [SrcOrgCode], -- source org code
'pcc_staging_db010798' as  [STgOrgCode], --staging DB, same for all facilities within one PMO
'usei9' as [DstOrgCode], --destination
'usei9' as [DstOrgCodeProd], --org code of current destination
8 as [SrcFacID],--
1 as [StgFacID],--
13 as [DstFacID],--
1 as [ContMerge], --0 = No,1 = Yes
0 as [ProdRun], --0 = No,1 = Yes
0 as [PreCaseFac], --0 = No,1 = Yes
0 as [PreCaseBed], --0 = No,1 = Yes
'' as [PreMergeScript], -- file path for auto-pre
'' as [PreMergeScriptSrc], --file_path for pre in source
'' as [PreMergeScriptDst], --file path for pre in destination, e.g. sec user gap import
'' as [PostMergeScript], ---- file path for post in staging (scoping)
'' as [PostMergeScriptDst], --file path for post in destination
'E14,E15,E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E8,E12b,E11,E9,E10,E13,E20,E21,E22,E23' as [ModList],
0 as [StagingCompleted], -- 0 not completed, 1 = completed
0 as [Completed], -- 0 not completed, 1 = completed
2 as [FacilityRunOrder] --starts from 1, incremental by 1 for the later facilities 
