
--Inserting a PMO Group

--INSERT INTO [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_PMO_Groups (PMONumber,Completed)
--SELECT '010798' as PMONumber, 0 as Completed

--Taking the PMO Group ID and putting into the Load EI Master Dynamically

Select * from [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_PMO_Groups WHERE PMONumber = '010798'

update [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_PMO_Groups
set Completed=1
WHERE PMONumber = '010798'

update [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac
set Completed=1
where [PMO_number] = '010798'
and PMO_Group_Id=902

DECLARE @pmo_group_id INT

SELECT @pmo_group_id = pmo_group_id
FROM [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_PMO_Groups 
WHERE PMONumber = '010798'

--SELECT * FROM [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_PMO_Groups WHERE PMONumber = '010798'

--Inserting all the entries for Load EI Master (for each facilities)

--1st fac

INSERT INTO [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac (PMO_Group_Id,CaseNo,PMO_number,SrcOrgCode,StgOrgCode,DstOrgCode,DstOrgCodeProd,SrcFacID,StgFacID,DstFacID,ContMerge,ProdRun,PreCaseFac,PreCaseBed,PreMergeScript,PreMergeScriptSrc,PostMergeScript,ModList,StagingCompleted,Completed,FacilityRunOrder)
SELECT @pmo_group_id as [PMO_Group_Id], --PMO_Group_ID created
'01079812' as [CaseNo],-- Case Number, unique per facility
'010798'as [PMO_number],-- PMO Number
'usei1188' as [SrcOrgCode],-- source
'pcc_staging_db010798' as  [STgOrgCode], --staging DB, same for all facilities within one PMO
'usei23' as [DstOrgCode],--destination
'usei23' as [DstOrgCodeProd], --org code of current destination
40 as [SrcFacID],
1 as [StgFacID],
1 as [DstFacID],
0 as [ContMerge], --0 = No,1 = Yes
0 as [ProdRun], --0 = No,1 = Yes
0 as [PreCaseFac], --0 = No,1 = Yes
0 as [PreCaseBed], --0 = No,1 = Yes
'' as [PreMergeScript], -- file path of auto-pre
'' as [PreMergeScriptSrc], --file_path of pre in source
'' as [PostMergeScript],---- file path of post in staging (scoping)
'E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12b,E11,E9,E10,E13,E16,E26,E20,E40,E21,E23' as [ModList],
0 as [StagingCompleted], -- 0 not completed, 1 = completed
0 as [Completed], -- 0 not completed, 1 = completed
1 as [FacilityRunOrder] --starts from 1, incremental by 1 for the later facilities 

--2nd fac

INSERT INTO [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac (PMO_Group_Id,CaseNo,PMO_number,SrcOrgCode,StgOrgCode,DstOrgCode,DstOrgCodeProd,SrcFacID,StgFacID,DstFacID,ContMerge,ProdRun,PreCaseFac,PreCaseBed,PreMergeScript,PreMergeScriptSrc,PostMergeScript,ModList,StagingCompleted,Completed,FacilityRunOrder)
SELECT @pmo_group_id as [PMO_Group_Id], --PMO_Group_ID created
'010798798' as [CaseNo],-- Case Number, unique per facility
'010798'as [PMO_number],-- PMO Number
'usei1188' as [SrcOrgCode],-- source
'pcc_staging_db010798' as  [STgOrgCode], --staging DB, same for all facilities within one PMO
'usei23' as [DstOrgCode],--destination
'usei23' as [DstOrgCodeProd], --org code of current destination
26 as [SrcFacID],
1 as [StgFacID],
28 as [DstFacID],
0 as [ContMerge], --0 = No,1 = Yes
0 as [ProdRun], --0 = No,1 = Yes
0 as [PreCaseFac], --0 = No,1 = Yes
0 as [PreCaseBed], --0 = No,1 = Yes
'' as [PreMergeScript], -- file path of auto-pre
'' as [PreMergeScriptSrc], --file_path of pre in source
'' as [PostMergeScript],---- file path of post in staging (scoping)
'E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12b,E11,E9,E10,E13,E16,E26,E20,E40,E21,E23' as [ModList],
0 as [StagingCompleted], -- 0 not completed, 1 = completed
0 as [Completed], -- 0 not completed, 1 = completed
2 as [FacilityRunOrder] --starts from 1, incremental by 1 for the later facilities 

--3rd fac


INSERT INTO [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac (PMO_Group_Id,CaseNo,PMO_number,SrcOrgCode,StgOrgCode,DstOrgCode,DstOrgCodeProd,SrcFacID,StgFacID,DstFacID,ContMerge,ProdRun,PreCaseFac,PreCaseBed,PreMergeScript,PreMergeScriptSrc,PostMergeScript,ModList,StagingCompleted,Completed,FacilityRunOrder)
SELECT @pmo_group_id as [PMO_Group_Id], --PMO_Group_ID created
'01079863' as [CaseNo],-- Case Number, unique per facility
'010798'as [PMO_number],-- PMO Number
'usei1188' as [SrcOrgCode],-- source
'pcc_staging_db010798' as  [STgOrgCode], --staging DB, same for all facilities within one PMO
'usei23' as [DstOrgCode],--destination
'usei23' as [DstOrgCodeProd], --org code of current destination
17 as [SrcFacID],
1 as [StgFacID],
63 as [DstFacID],
0 as [ContMerge], --0 = No,1 = Yes
0 as [ProdRun], --0 = No,1 = Yes
0 as [PreCaseFac], --0 = No,1 = Yes
0 as [PreCaseBed], --0 = No,1 = Yes
'' as [PreMergeScript], -- file path of auto-pre
'' as [PreMergeScriptSrc], --file_path of pre in source
'' as [PostMergeScript],---- file path of post in staging (scoping)
'E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12b,E11,E9,E10,E13,E16,E26,E20,E40,E21,E23' as [ModList],
0 as [StagingCompleted], -- 0 not completed, 1 = completed
0 as [Completed], -- 0 not completed, 1 = completed
3 as [FacilityRunOrder] --starts from 1, incremental by 1 for the later facilities 

--4th fac

INSERT INTO [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac (PMO_Group_Id,CaseNo,PMO_number,SrcOrgCode,StgOrgCode,DstOrgCode,DstOrgCodeProd,SrcFacID,StgFacID,DstFacID,ContMerge,ProdRun,PreCaseFac,PreCaseBed,PreMergeScript,PreMergeScriptSrc,PostMergeScript,ModList,StagingCompleted,Completed,FacilityRunOrder)
SELECT @pmo_group_id as [PMO_Group_Id], --PMO_Group_ID created
'01079864' as [CaseNo],-- Case Number, unique per facility
'010798'as [PMO_number],-- PMO Number
'usei1188' as [SrcOrgCode],-- source
'pcc_staging_db010798' as  [STgOrgCode], --staging DB, same for all facilities within one PMO
'usei23' as [DstOrgCode],--destination
'usei23' as [DstOrgCodeProd], --org code of current destination
64 as [SrcFacID],
1 as [StgFacID],
40 as [DstFacID],
0 as [ContMerge], --0 = No,1 = Yes
0 as [ProdRun], --0 = No,1 = Yes
0 as [PreCaseFac], --0 = No,1 = Yes
0 as [PreCaseBed], --0 = No,1 = Yes
'' as [PreMergeScript], -- file path of auto-pre
'' as [PreMergeScriptSrc], --file_path of pre in source
'' as [PostMergeScript],---- file path of post in staging (scoping)
'E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12b,E11,E9,E10,E13,E16,E26,E20,E40,E21,E23' as [ModList],
0 as [StagingCompleted], -- 0 not completed, 1 = completed
0 as [Completed], -- 0 not completed, 1 = completed
4 as [FacilityRunOrder] --starts from 1, incremental by 1 for the later facilities 

--5th fac

--RunID	PMO_Group_Id	CaseNo	PMO_number	SrcOrgCode	StgOrgCode	SrcFacID	DstFacID	DstOrgCode
--516	902	01079812	010798	usei1188	pcc_staging_db010798	40	1	usei23
--517	902	010798798	010798	usei1188	pcc_staging_db010798	26	28	usei23
--526	902	01079863	010798	usei1188	pcc_staging_db010798	17	63	usei23
--519	902	01079864	010798	usei1188	pcc_staging_db010798	64	40	usei23
--520	902	01079865	010798	usei1188	pcc_staging_db010798	65	65	usei23
--521	902	01079866	010798	usei1188	pcc_staging_db010798	11	66	usei23

INSERT INTO [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac (PMO_Group_Id,CaseNo,PMO_number,SrcOrgCode,StgOrgCode,DstOrgCode,DstOrgCodeProd,SrcFacID,StgFacID,DstFacID,ContMerge,ProdRun,PreCaseFac,PreCaseBed,PreMergeScript,PreMergeScriptSrc,PostMergeScript,ModList,StagingCompleted,Completed,FacilityRunOrder)
SELECT @pmo_group_id as [PMO_Group_Id], --PMO_Group_ID created
'01079865' as [CaseNo],-- Case Number, unique per facility
'010798'as [PMO_number],-- PMO Number
'usei1188' as [SrcOrgCode],-- source
'pcc_staging_db010798' as  [STgOrgCode], --staging DB, same for all facilities within one PMO
'usei23' as [DstOrgCode],--destination
'usei23' as [DstOrgCodeProd], --org code of current destination
65 as [SrcFacID],
1 as [StgFacID],
65 as [DstFacID],
0 as [ContMerge], --0 = No,1 = Yes
0 as [ProdRun], --0 = No,1 = Yes
0 as [PreCaseFac], --0 = No,1 = Yes
0 as [PreCaseBed], --0 = No,1 = Yes
'' as [PreMergeScript], -- file path of auto-pre
'' as [PreMergeScriptSrc], --file_path of pre in source
'' as [PostMergeScript],---- file path of post in staging (scoping)
'E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12b,E11,E9,E10,E13,E16,E26,E20,E40,E21,E23' as [ModList],
1 as [StagingCompleted], -- 0 not completed, 1 = completed
0 as [Completed], -- 0 not completed, 1 = completed
5 as [FacilityRunOrder] --starts from 1, incremental by 1 for the later facilities 

--6th fac

INSERT INTO [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac (PMO_Group_Id,CaseNo,PMO_number,SrcOrgCode,StgOrgCode,DstOrgCode,DstOrgCodeProd,SrcFacID,StgFacID,DstFacID,ContMerge,ProdRun,PreCaseFac,PreCaseBed,PreMergeScript,PreMergeScriptSrc,PostMergeScript,ModList,StagingCompleted,Completed,FacilityRunOrder)
SELECT @pmo_group_id as [PMO_Group_Id], --PMO_Group_ID created
'01079866' as [CaseNo],-- Case Number, unique per facility
'010798'as [PMO_number],-- PMO Number
'usei1188' as [SrcOrgCode],-- source
'pcc_staging_db010798' as  [STgOrgCode], --staging DB, same for all facilities within one PMO
'usei23' as [DstOrgCode],--destination
'usei23' as [DstOrgCodeProd], --org code of current destination
11 as [SrcFacID],
1 as [StgFacID],
66 as [DstFacID],
0 as [ContMerge], --0 = No,1 = Yes
0 as [ProdRun], --0 = No,1 = Yes
0 as [PreCaseFac], --0 = No,1 = Yes
0 as [PreCaseBed], --0 = No,1 = Yes
'' as [PreMergeScript], -- file path of auto-pre
'' as [PreMergeScriptSrc], --file_path of pre in source
'' as [PostMergeScript],---- file path of post in staging (scoping)
'E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12b,E11,E9,E10,E13,E16,E26,E20,E40,E21,E23' as [ModList],
0 as [StagingCompleted], -- 0 not completed, 1 = completed
0 as [Completed], -- 0 not completed, 1 = completed
6 as [FacilityRunOrder] --starts from 1, incremental by 1 for the later facilities 

--7th fac

--INSERT INTO [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac (PMO_Group_Id,CaseNo,PMO_number,SrcOrgCode,StgOrgCode,DstOrgCode,DstOrgCodeProd,SrcFacID,StgFacID,DstFacID,ContMerge,ProdRun,PreCaseFac,PreCaseBed,PreMergeScript,PreMergeScriptSrc,PostMergeScript,ModList,StagingCompleted,Completed,FacilityRunOrder)
--SELECT @pmo_group_id as [PMO_Group_Id], --PMO_Group_ID created
--'R_CASENUMBER7' as [CaseNo],-- Case Number, unique per facility
--'010798'as [PMO_number],-- PMO Number
--'usei1188' as [SrcOrgCode],-- source
--'pcc_staging_db010798' as  [STgOrgCode], --staging DB, same for all facilities within one PMO
--'usei23' as [DstOrgCode],--destination
--'usei23' as [DstOrgCodeProd], --org code of current destination
--R_SRCFACID7 as [SrcFacID],
--1 as [StgFacID],
--R_DSTFACID7 as [DstFacID],
--0 as [ContMerge], --0 = No,1 = Yes
--0 as [ProdRun], --0 = No,1 = Yes
--0 as [PreCaseFac], --0 = No,1 = Yes
--0 as [PreCaseBed], --0 = No,1 = Yes
--'1 (auto) PreMergeScript_Autopre_facR_SRCFACID7.sql' as [PreMergeScript], -- file path of auto-pre
--'2 (auto) PreMergeScriptSource_PreScripts_facR_SRCFACID7.sql' as [PreMergeScriptSrc], --file_path of pre in source
--'3 (auto) PostMergeScriptStaging_facR_SRCFACID7.sql' as [PostMergeScript],---- file path of post in staging (scoping)
--'E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12b,E11,E9,E10,E13,E16,E26,E20,E40,E21,E23' as [ModList],
--0 as [StagingCompleted], -- 0 not completed, 1 = completed
--0 as [Completed], -- 0 not completed, 1 = completed
--7 as [FacilityRunOrder] --starts from 1, incremental by 1 for the later facilities 

--8th fac

--INSERT INTO [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac (PMO_Group_Id,CaseNo,PMO_number,SrcOrgCode,StgOrgCode,DstOrgCode,DstOrgCodeProd,SrcFacID,StgFacID,DstFacID,ContMerge,ProdRun,PreCaseFac,PreCaseBed,PreMergeScript,PreMergeScriptSrc,PostMergeScript,ModList,StagingCompleted,Completed,FacilityRunOrder)
--SELECT @pmo_group_id as [PMO_Group_Id], --PMO_Group_ID created
--'R_CASENUMBER8' as [CaseNo],-- Case Number, unique per facility
--'010798'as [PMO_number],-- PMO Number
--'usei1188' as [SrcOrgCode],-- source
--'pcc_staging_db010798' as  [STgOrgCode], --staging DB, same for all facilities within one PMO
--'usei23' as [DstOrgCode],--destination
--'usei23' as [DstOrgCodeProd], --org code of current destination
--R_SRCFACID8 as [SrcFacID],
--1 as [StgFacID],
--R_DSTFACID8 as [DstFacID],
--0 as [ContMerge], --0 = No,1 = Yes
--0 as [ProdRun], --0 = No,1 = Yes
--0 as [PreCaseFac], --0 = No,1 = Yes
--0 as [PreCaseBed], --0 = No,1 = Yes
--'1 (auto) PreMergeScript_Autopre_facR_SRCFACID8.sql' as [PreMergeScript], -- file path of auto-pre
--'2 (auto) PreMergeScriptSource_PreScripts_facR_SRCFACID8.sql' as [PreMergeScriptSrc], --file_path of pre in source
--'3 (auto) PostMergeScriptStaging_facR_SRCFACID8.sql' as [PostMergeScript],---- file path of post in staging (scoping)
--'E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12b,E11,E9,E10,E13,E16,E26,E20,E40,E21,E23' as [ModList],
--0 as [StagingCompleted], -- 0 not completed, 1 = completed
--0 as [Completed], -- 0 not completed, 1 = completed
--8 as [FacilityRunOrder] --starts from 1, incremental by 1 for the later facilities 

--9th fac

--INSERT INTO [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac (PMO_Group_Id,CaseNo,PMO_number,SrcOrgCode,StgOrgCode,DstOrgCode,DstOrgCodeProd,SrcFacID,StgFacID,DstFacID,ContMerge,ProdRun,PreCaseFac,PreCaseBed,PreMergeScript,PreMergeScriptSrc,PostMergeScript,ModList,StagingCompleted,Completed,FacilityRunOrder)
--SELECT @pmo_group_id as [PMO_Group_Id], --PMO_Group_ID created
--'R_CASENUMBER9' as [CaseNo],-- Case Number, unique per facility
--'010798'as [PMO_number],-- PMO Number
--'usei1188' as [SrcOrgCode],-- source
--'pcc_staging_db010798' as  [STgOrgCode], --staging DB, same for all facilities within one PMO
--'usei23' as [DstOrgCode],--destination
--'usei23' as [DstOrgCodeProd], --org code of current destination
--R_SRCFACID9 as [SrcFacID],
--1 as [StgFacID],
--R_DSTFACID9 as [DstFacID],
--0 as [ContMerge], --0 = No,1 = Yes
--0 as [ProdRun], --0 = No,1 = Yes
--0 as [PreCaseFac], --0 = No,1 = Yes
--0 as [PreCaseBed], --0 = No,1 = Yes
--'1 (auto) PreMergeScript_Autopre_facR_SRCFACID9.sql' as [PreMergeScript], -- file path of auto-pre
--'2 (auto) PreMergeScriptSource_PreScripts_facR_SRCFACID9.sql' as [PreMergeScriptSrc], --file_path of pre in source
--'3 (auto) PostMergeScriptStaging_facR_SRCFACID9.sql' as [PostMergeScript],---- file path of post in staging (scoping)
--'E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12b,E11,E9,E10,E13,E16,E26,E20,E40,E21,E23' as [ModList],
--0 as [StagingCompleted], -- 0 not completed, 1 = completed
--0 as [Completed], -- 0 not completed, 1 = completed
--9 as [FacilityRunOrder] --starts from 1, incremental by 1 for the later facilities 

select * from  [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac where PMO_Number = '010798'

/*   

All -- 'E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12b,E11,E9,E10,E13,E16,E26,E20,E40,E21,E23' 

	E14 = Security Roles
	E40 = Security User
A	E1 = Resident, Resident Identifier, Contact
A	E2 = Staff
A	E2a = Medical Professional
A	E3 = External Facility
A	E4 = User Defined Data
A	E5 = Room/Bed
A	E6 = Census
	E7 = Assessments
		E7a = MDS 2
		E7b = MDS 3
		E7c = Custom UDAs
		E7d  =  MMQ (state of Massachusetts - MA)
		E7e	 =  MMA  (state of Maryland - MD)
A	E8 = Diagnosis
A	E11 = Immunization 
	E12 = Care Plan
		E12a = Custom
		E12b = Copy with Library
	E9 = Progress Note
A	E10 = Weight & Vitals
	E13 = Physician Order
	E16 = Alert
	E17 = Risk Management
	E20 = Online doc (Misc tab)
	E21 = Lab Results and Radiology
	E40 = Master Insurance
	E23 = Notes
	E26 = Trust

*/

----to undo the complete for Skin and Wound Templates

--update [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_PMO_Groups 
--set completed = 1
--where pmonumber = '10101' 

--update [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac
--set completed = 1
----select * from [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac
--where PMO_Number = '10101'