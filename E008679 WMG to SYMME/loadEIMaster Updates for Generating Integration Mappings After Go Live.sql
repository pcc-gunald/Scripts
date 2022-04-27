-- Update each query to use the correct PMO Group ID

/*
1. Update loadEIMaster tables so the project appears in the DSH dropdown
*/
UPDATE a
set completed = 0 
-- select * 
FROM LoadEIMaster_Automation a
WHERE PMO_Group_Id = 1769 --update this

UPDATE a
SET Completed = 0 
-- select * 
FROM [LoadEIMaster_PMO_Groups] a
WHERE PMO_Group_Id = 1769 --update this

/*
2. IF automation was used for the Go Live, create rows in loadEIMaster_New_Multi_Fac for each facility.
Data should mirror what's in loadEIMaster_Automation.
*/
INSERT INTO ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac 
(PMO_Group_Id,CaseNo,PMO_number,SrcOrgCode,StgOrgCode,DstOrgCode,DstOrgCodeProd,SrcFacID,StgFacID,DstFacID,ContMerge,ProdRun
,PreCaseFac,PreCaseBed,PreMergeScript,PreMergeScriptSrc,PostMergeScript,ModList,StagingCompleted,Completed,FacilityRunOrder)
SELECT  PMO_Group_Id,CaseNo,PMO_number,SrcOrgCode,StgOrgCode,DstOrgCode,DstOrgCodeProd,SrcFacID,StgFacID,DstFacID,ContMerge,ProdRun
,PreCaseFac,PreCaseBed,PreMergeScript,PreMergeScriptSrc,PostMergeScript,ModList,StagingCompleted,Completed,FacilityRunOrder
FROM            LoadEIMaster_Automation AS a
WHERE        (PMO_Group_Id = 1769) 


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


---\\STUSPAINFCIFS.pccprod.local\DS\LocalBackup\EI_Mapping_Files\PMO008679\
UPDATE LoadEIMaster_New_Multi_Fac
set completed = 1
where PMO_Group_Id = 1769 --update this

UPDATE a
set completed = 1 
-- select * 
FROM LoadEIMaster_Automation a
WHERE PMO_Group_Id = 1769 --update this

UPDATE a
SET Completed = 1 
-- select * 
FROM [LoadEIMaster_PMO_Groups] a
WHERE PMO_Group_Id = 1769 --update this
 