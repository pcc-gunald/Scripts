-- Update each query to use the correct PMO Group ID

/*
1. Update loadEIMaster tables so the project appears in the DSH dropdown
*/
UPDATE a
set completed = 0 
-- select * 
FROM LoadEIMaster_Automation a
WHERE PMO_Group_Id = 1852 --update this

UPDATE a
SET Completed = 0 
-- select * 
FROM [LoadEIMaster_PMO_Groups] a
WHERE PMO_Group_Id = 1852 --update this

/*
2. IF automation was used for the Go Live, create rows in loadEIMaster_New_Multi_Fac for each facility.
Data should mirror what's in loadEIMaster_Automation.
*/
INSERT INTO ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac 
(PMO_Group_Id,CaseNo,PMO_number,SrcOrgCode,StgOrgCode,DstOrgCode,DstOrgCodeProd,SrcFacID,StgFacID,DstFacID,ContMerge,ProdRun
,PreCaseFac,PreCaseBed,PreMergeScript,PreMergeScriptSrc,PostMergeScript,ModList,StagingCompleted,Completed,FacilityRunOrder)
SELECT '1648' as [PMO_Group_Id], --PMO_Group_ID created
'58249160' as [CaseNo], -- Case Number, unique per facility
'58249'as [PMO_number], -- PMO Number
'usei994' as [SrcOrgCode], -- source org code
'pcc_staging_db58249' as  [STgOrgCode], --staging DB, same for all facilities within one PMO
'PHX' as [DstOrgCode], --destination
'PHX' as [DstOrgCodeProd], --org code of current destination
160 as [SrcFacID],--
160 as [StgFacID],--
237 as [DstFacID],--
0 as [ContMerge], --0 = No,1 = Yes
1 as [ProdRun], --0 = No,1 = Yes
0 as [PreCaseFac], --0 = No,1 = Yes
0 as [PreCaseBed], --0 = No,1 = Yes
'' as [PreMergeScript], -- file path of auto-pre
'' as [PreMergeScriptSrc], --file_path of pre in source
'' as [PostMergeScript],---- file path of post in staging (scoping)
'E14,E15,E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E20,E21,E22,E23' as [ModList],
0 as [StagingCompleted], -- 0 not completed, 1 = completed
0 as [Completed], -- 0 not completed, 1 = completed
1 as [FacilityRunOrder] --starts from 1, incremental by 1 for the later facilities 

INSERT INTO ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac 
(PMO_Group_Id,CaseNo,PMO_number,SrcOrgCode,StgOrgCode,DstOrgCode,DstOrgCodeProd,SrcFacID,StgFacID,DstFacID,ContMerge,ProdRun
,PreCaseFac,PreCaseBed,PreMergeScript,PreMergeScriptSrc,PostMergeScript,ModList,StagingCompleted,Completed,FacilityRunOrder)
SELECT '1648' as [PMO_Group_Id], --PMO_Group_ID created
'58249159' as [CaseNo], -- Case Number, unique per facility
'58249'as [PMO_number], -- PMO Number
'usei994' as [SrcOrgCode], -- source org code
'pcc_staging_db58249' as  [STgOrgCode], --staging DB, same for all facilities within one PMO
'PHX' as [DstOrgCode], --destination
'PHX' as [DstOrgCodeProd], --org code of current destination
159 as [SrcFacID],--
159 as [StgFacID],--
238 as [DstFacID],--
0 as [ContMerge], --0 = No,1 = Yes
1 as [ProdRun], --0 = No,1 = Yes
0 as [PreCaseFac], --0 = No,1 = Yes
0 as [PreCaseBed], --0 = No,1 = Yes
'' as [PreMergeScript], -- file path of auto-pre
'' as [PreMergeScriptSrc], --file_path of pre in source
'' as [PostMergeScript],---- file path of post in staging (scoping)
'E14,E15,E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12a,E12b,E11,E9,E10,E13,E20,E21,E22,E23' as [ModList],
0 as [StagingCompleted], -- 0 not completed, 1 = completed
0 as [Completed], -- 0 not completed, 1 = completed
2 as [FacilityRunOrder] --starts from 1, incremental by 1 for the later facilities 


/*
3. GO INTO DSH AND GENERATE TEMPLATES AS FOLLOWS:
a.	Open the DS Helper and navigate to EI – Export Import > Enhanced Export/Import Multi Facility.
b.	Choose the PMO Group for your project from the dropdown.
c.	Select the “Mapping Files” tab.
d.	Copy the value in the “Save Files To” textbox and save it for future reference.
e.	Enter the emails specified in the DC-Existing Checklist for “If facility is using Nursing Advantage…” and/or "If facility is using Skin and Wound...", 
	as well as your own email and the TS Fac Acq group email, separated by “;”.
f.	Click “Email Files”.
*/

/*
4. Update loadEIMaster tables again to indicate the Go Live is complete
*/
UPDATE LoadEIMaster_New_Multi_Fac
set completed = 1
where PMO_Group_Id = 1852 --update this

UPDATE a
set completed = 1 
-- select * 
FROM LoadEIMaster_Automation a
WHERE PMO_Group_Id = 1852 --update this

UPDATE a
SET Completed = 1 
-- select * 
FROM [LoadEIMaster_PMO_Groups] a
WHERE PMO_Group_Id = 1852 --update this
 