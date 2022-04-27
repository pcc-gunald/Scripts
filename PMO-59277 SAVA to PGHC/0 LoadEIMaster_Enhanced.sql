
--Inserting a PMO Group

INSERT INTO [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_PMO_Groups (PMONumber,Completed)
SELECT '59277' as PMONumber, 0 as Completed

--Taking the PMO Group ID and putting into the Load EI Master Dynamically

DECLARE @pmo_group_id INT

SELECT @pmo_group_id = pmo_group_id
FROM [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_PMO_Groups 
WHERE PMONumber = '59277'

--SELECT * FROM [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_PMO_Groups WHERE PMONumber = '59277'

--Inserting all the entries for Load EI Master (for each facilities)

--1st fac


INSERT INTO [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_Automation (PMO_Group_Id,CaseNo,PMO_number,SrcOrgCode,StgOrgCode,DstOrgCode,DstOrgCodeProd,SrcFacID,StgFacID,DstFacID,ContMerge,ProdRun,PreCaseFac,PreCaseBed,PreMergeScript,PreMergeScriptSrc,PostMergeScript,ModList,StagingCompleted,Completed,FacilityRunOrder)
SELECT 1813 as [PMO_Group_Id], --PMO_Group_ID created
'59277183' as [CaseNo],-- Case Number, unique per facility
'59277'as [PMO_number],-- PMO Number
'usei3sava1' as [SrcOrgCode],-- source
'pcc_staging_db59277' as  [STgOrgCode], --staging DB, same for all facilities within one PMO
'usei1214' as [DstOrgCode],--destination
'usei1214' as [DstOrgCodeProd], --org code of current destination
183 as [SrcFacID],
1 as [StgFacID],
173 as [DstFacID],
0 as [ContMerge], --0 = No,1 = Yes
0 as [ProdRun], --0 = No,1 = Yes
0 as [PreCaseFac], --0 = No,1 = Yes
0 as [PreCaseBed], --0 = No,1 = Yes
'' as [PreMergeScript], -- file path of auto-pre
'' as [PreMergeScriptSrc], --file_path of pre in source
'' as [PostMergeScript],---- file path of post in staging (scoping)
'E14,E15,E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12b,E11,E9,E10,E13,E16,E17,E20,E21,E22,E23' as [ModList],
0 as [StagingCompleted], -- 0 not completed, 1 = completed
0 as [Completed], -- 0 not completed, 1 = completed
1 as [FacilityRunOrder] --starts from 1, incremental by 1 for the later facilities 





INSERT INTO [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac (PMO_Group_Id,CaseNo,PMO_number,SrcOrgCode,StgOrgCode,DstOrgCode,DstOrgCodeProd,SrcFacID,StgFacID,DstFacID,ContMerge,ProdRun,PreCaseFac,PreCaseBed,PreMergeScript,PreMergeScriptSrc,PostMergeScript,ModList,StagingCompleted,Completed,FacilityRunOrder)
SELECT 1813 as [PMO_Group_Id], --PMO_Group_ID created
'59277183' as [CaseNo],-- Case Number, unique per facility
'59277'as [PMO_number],-- PMO Number
'usei3sava1' as [SrcOrgCode],-- source
'pcc_staging_db59277' as  [STgOrgCode], --staging DB, same for all facilities within one PMO
'usei1214' as [DstOrgCode],--destination
'usei1214' as [DstOrgCodeProd], --org code of current destination
183 as [SrcFacID],
1 as [StgFacID],
173 as [DstFacID],
0 as [ContMerge], --0 = No,1 = Yes
0 as [ProdRun], --0 = No,1 = Yes
0 as [PreCaseFac], --0 = No,1 = Yes
0 as [PreCaseBed], --0 = No,1 = Yes
'\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_to_Existing_Projects\PMO-59277 SAVA to PGHC\1 (auto) PreMergeScript_Autopre_fac183.sql' as [PreMergeScript], -- file path of auto-pre
'\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_to_Existing_Projects\PMO-59277 SAVA to PGHC\2 (auto) PreMergeScriptSource_PreScripts_fac183.sql' as [PreMergeScriptSrc], --file_path of pre in source
'\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_to_Existing_Projects\PMO-59277 SAVA to PGHC\3 (auto) PostMergeScriptStaging_fac183.sql' as [PostMergeScript],---- file path of post in staging (scoping)
'E14,E15,E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12b,E11,E9,E10,E13,E16,E17,E20,E21,E22,E23' as [ModList],
0 as [StagingCompleted], -- 0 not completed, 1 = completed
0 as [Completed], -- 0 not completed, 1 = completed
1 as [FacilityRunOrder] --starts from 1, incremental by 1 for the later facilities 

--2nd fac

--INSERT INTO [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac (PMO_Group_Id,CaseNo,PMO_number,SrcOrgCode,StgOrgCode,DstOrgCode,DstOrgCodeProd,SrcFacID,StgFacID,DstFacID,ContMerge,ProdRun,PreCaseFac,PreCaseBed,PreMergeScript,PreMergeScriptSrc,PostMergeScript,ModList,StagingCompleted,Completed,FacilityRunOrder)
--SELECT @pmo_group_id as [PMO_Group_Id], --PMO_Group_ID created
--'R_CASENUMBER2' as [CaseNo],-- Case Number, unique per facility
--'59277'as [PMO_number],-- PMO Number
--'usei3sava1' as [SrcOrgCode],-- source
--'pcc_staging_db59277' as  [STgOrgCode], --staging DB, same for all facilities within one PMO
--'usei1214' as [DstOrgCode],--destination
--'usei1214' as [DstOrgCodeProd], --org code of current destination
--R_SRCFACID2 as [SrcFacID],
--1 as [StgFacID],
--R_DSTFACID2 as [DstFacID],
--0 as [ContMerge], --0 = No,1 = Yes
--0 as [ProdRun], --0 = No,1 = Yes
--0 as [PreCaseFac], --0 = No,1 = Yes
--0 as [PreCaseBed], --0 = No,1 = Yes
--'\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_to_Existing_Projects\PMO-59277 SAVA to PGHC\1 (auto) PreMergeScript_Autopre_facR_SRCFACID2.sql' as [PreMergeScript], -- file path of auto-pre
--'\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_to_Existing_Projects\PMO-59277 SAVA to PGHC\2 (auto) PreMergeScriptSource_PreScripts_facR_SRCFACID2.sql' as [PreMergeScriptSrc], --file_path of pre in source
--'\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_to_Existing_Projects\PMO-59277 SAVA to PGHC\3 (auto) PostMergeScriptStaging_facR_SRCFACID2.sql' as [PostMergeScript],---- file path of post in staging (scoping)
--'E14,E15,E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12b,E11,E9,E10,E13,E16,E17,E20,E21,E22,E23' as [ModList],
--0 as [StagingCompleted], -- 0 not completed, 1 = completed
--0 as [Completed], -- 0 not completed, 1 = completed
--2 as [FacilityRunOrder] --starts from 1, incremental by 1 for the later facilities 

--3rd fac

--INSERT INTO [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac (PMO_Group_Id,CaseNo,PMO_number,SrcOrgCode,StgOrgCode,DstOrgCode,DstOrgCodeProd,SrcFacID,StgFacID,DstFacID,ContMerge,ProdRun,PreCaseFac,PreCaseBed,PreMergeScript,PreMergeScriptSrc,PostMergeScript,ModList,StagingCompleted,Completed,FacilityRunOrder)
--SELECT @pmo_group_id as [PMO_Group_Id], --PMO_Group_ID created
--'R_CASENUMBER3' as [CaseNo],-- Case Number, unique per facility
--'59277'as [PMO_number],-- PMO Number
--'usei3sava1' as [SrcOrgCode],-- source
--'pcc_staging_db59277' as  [STgOrgCode], --staging DB, same for all facilities within one PMO
--'usei1214' as [DstOrgCode],--destination
--'usei1214' as [DstOrgCodeProd], --org code of current destination
--R_SRCFACID3 as [SrcFacID],
--1 as [StgFacID],
--R_DSTFACID3 as [DstFacID],
--0 as [ContMerge], --0 = No,1 = Yes
--0 as [ProdRun], --0 = No,1 = Yes
--0 as [PreCaseFac], --0 = No,1 = Yes
--0 as [PreCaseBed], --0 = No,1 = Yes
--'\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_to_Existing_Projects\PMO-59277 SAVA to PGHC\1 (auto) PreMergeScript_Autopre_facR_SRCFACID3.sql' as [PreMergeScript], -- file path of auto-pre
--'\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_to_Existing_Projects\PMO-59277 SAVA to PGHC\2 (auto) PreMergeScriptSource_PreScripts_facR_SRCFACID3.sql' as [PreMergeScriptSrc], --file_path of pre in source
--'\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_to_Existing_Projects\PMO-59277 SAVA to PGHC\3 (auto) PostMergeScriptStaging_facR_SRCFACID3.sql' as [PostMergeScript],---- file path of post in staging (scoping)
--'E14,E15,E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12b,E11,E9,E10,E13,E16,E17,E20,E21,E22,E23' as [ModList],
--0 as [StagingCompleted], -- 0 not completed, 1 = completed
--0 as [Completed], -- 0 not completed, 1 = completed
--3 as [FacilityRunOrder] --starts from 1, incremental by 1 for the later facilities 

--4th fac

--INSERT INTO [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac (PMO_Group_Id,CaseNo,PMO_number,SrcOrgCode,StgOrgCode,DstOrgCode,DstOrgCodeProd,SrcFacID,StgFacID,DstFacID,ContMerge,ProdRun,PreCaseFac,PreCaseBed,PreMergeScript,PreMergeScriptSrc,PostMergeScript,ModList,StagingCompleted,Completed,FacilityRunOrder)
--SELECT @pmo_group_id as [PMO_Group_Id], --PMO_Group_ID created
--'R_CASENUMBER4' as [CaseNo],-- Case Number, unique per facility
--'59277'as [PMO_number],-- PMO Number
--'usei3sava1' as [SrcOrgCode],-- source
--'pcc_staging_db59277' as  [STgOrgCode], --staging DB, same for all facilities within one PMO
--'usei1214' as [DstOrgCode],--destination
--'usei1214' as [DstOrgCodeProd], --org code of current destination
--R_SRCFACID4 as [SrcFacID],
--1 as [StgFacID],
--R_DSTFACID4 as [DstFacID],
--0 as [ContMerge], --0 = No,1 = Yes
--0 as [ProdRun], --0 = No,1 = Yes
--0 as [PreCaseFac], --0 = No,1 = Yes
--0 as [PreCaseBed], --0 = No,1 = Yes
--'\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_to_Existing_Projects\PMO-59277 SAVA to PGHC\1 (auto) PreMergeScript_Autopre_facR_SRCFACID4.sql' as [PreMergeScript], -- file path of auto-pre
--'\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_to_Existing_Projects\PMO-59277 SAVA to PGHC\2 (auto) PreMergeScriptSource_PreScripts_facR_SRCFACID4.sql' as [PreMergeScriptSrc], --file_path of pre in source
--'\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_to_Existing_Projects\PMO-59277 SAVA to PGHC\3 (auto) PostMergeScriptStaging_facR_SRCFACID4.sql' as [PostMergeScript],---- file path of post in staging (scoping)
--'E14,E15,E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12b,E11,E9,E10,E13,E16,E17,E20,E21,E22,E23' as [ModList],
--0 as [StagingCompleted], -- 0 not completed, 1 = completed
--0 as [Completed], -- 0 not completed, 1 = completed
--4 as [FacilityRunOrder] --starts from 1, incremental by 1 for the later facilities 

--5th fac

--INSERT INTO [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac (PMO_Group_Id,CaseNo,PMO_number,SrcOrgCode,StgOrgCode,DstOrgCode,DstOrgCodeProd,SrcFacID,StgFacID,DstFacID,ContMerge,ProdRun,PreCaseFac,PreCaseBed,PreMergeScript,PreMergeScriptSrc,PostMergeScript,ModList,StagingCompleted,Completed,FacilityRunOrder)
--SELECT @pmo_group_id as [PMO_Group_Id], --PMO_Group_ID created
--'R_CASENUMBER5' as [CaseNo],-- Case Number, unique per facility
--'59277'as [PMO_number],-- PMO Number
--'usei3sava1' as [SrcOrgCode],-- source
--'pcc_staging_db59277' as  [STgOrgCode], --staging DB, same for all facilities within one PMO
--'usei1214' as [DstOrgCode],--destination
--'usei1214' as [DstOrgCodeProd], --org code of current destination
--R_SRCFACID5 as [SrcFacID],
--1 as [StgFacID],
--R_DSTFACID5 as [DstFacID],
--0 as [ContMerge], --0 = No,1 = Yes
--0 as [ProdRun], --0 = No,1 = Yes
--0 as [PreCaseFac], --0 = No,1 = Yes
--0 as [PreCaseBed], --0 = No,1 = Yes
--'\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_to_Existing_Projects\PMO-59277 SAVA to PGHC\1 (auto) PreMergeScript_Autopre_facR_SRCFACID5.sql' as [PreMergeScript], -- file path of auto-pre
--'\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_to_Existing_Projects\PMO-59277 SAVA to PGHC\2 (auto) PreMergeScriptSource_PreScripts_facR_SRCFACID5.sql' as [PreMergeScriptSrc], --file_path of pre in source
--'\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_to_Existing_Projects\PMO-59277 SAVA to PGHC\3 (auto) PostMergeScriptStaging_facR_SRCFACID5.sql' as [PostMergeScript],---- file path of post in staging (scoping)
--'E14,E15,E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12b,E11,E9,E10,E13,E16,E17,E20,E21,E22,E23' as [ModList],
--0 as [StagingCompleted], -- 0 not completed, 1 = completed
--0 as [Completed], -- 0 not completed, 1 = completed
--5 as [FacilityRunOrder] --starts from 1, incremental by 1 for the later facilities 

--6th fac

--INSERT INTO [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac (PMO_Group_Id,CaseNo,PMO_number,SrcOrgCode,StgOrgCode,DstOrgCode,DstOrgCodeProd,SrcFacID,StgFacID,DstFacID,ContMerge,ProdRun,PreCaseFac,PreCaseBed,PreMergeScript,PreMergeScriptSrc,PostMergeScript,ModList,StagingCompleted,Completed,FacilityRunOrder)
--SELECT @pmo_group_id as [PMO_Group_Id], --PMO_Group_ID created
--'R_CASENUMBER6' as [CaseNo],-- Case Number, unique per facility
--'59277'as [PMO_number],-- PMO Number
--'usei3sava1' as [SrcOrgCode],-- source
--'pcc_staging_db59277' as  [STgOrgCode], --staging DB, same for all facilities within one PMO
--'usei1214' as [DstOrgCode],--destination
--'usei1214' as [DstOrgCodeProd], --org code of current destination
--R_SRCFACID6 as [SrcFacID],
--1 as [StgFacID],
--R_DSTFACID6 as [DstFacID],
--0 as [ContMerge], --0 = No,1 = Yes
--0 as [ProdRun], --0 = No,1 = Yes
--0 as [PreCaseFac], --0 = No,1 = Yes
--0 as [PreCaseBed], --0 = No,1 = Yes
--'\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_to_Existing_Projects\PMO-59277 SAVA to PGHC\1 (auto) PreMergeScript_Autopre_facR_SRCFACID6.sql' as [PreMergeScript], -- file path of auto-pre
--'\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_to_Existing_Projects\PMO-59277 SAVA to PGHC\2 (auto) PreMergeScriptSource_PreScripts_facR_SRCFACID6.sql' as [PreMergeScriptSrc], --file_path of pre in source
--'\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_to_Existing_Projects\PMO-59277 SAVA to PGHC\3 (auto) PostMergeScriptStaging_facR_SRCFACID6.sql' as [PostMergeScript],---- file path of post in staging (scoping)
--'E14,E15,E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12b,E11,E9,E10,E13,E16,E17,E20,E21,E22,E23' as [ModList],
--0 as [StagingCompleted], -- 0 not completed, 1 = completed
--0 as [Completed], -- 0 not completed, 1 = completed
--6 as [FacilityRunOrder] --starts from 1, incremental by 1 for the later facilities 

--7th fac

--INSERT INTO [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac (PMO_Group_Id,CaseNo,PMO_number,SrcOrgCode,StgOrgCode,DstOrgCode,DstOrgCodeProd,SrcFacID,StgFacID,DstFacID,ContMerge,ProdRun,PreCaseFac,PreCaseBed,PreMergeScript,PreMergeScriptSrc,PostMergeScript,ModList,StagingCompleted,Completed,FacilityRunOrder)
--SELECT @pmo_group_id as [PMO_Group_Id], --PMO_Group_ID created
--'R_CASENUMBER7' as [CaseNo],-- Case Number, unique per facility
--'59277'as [PMO_number],-- PMO Number
--'usei3sava1' as [SrcOrgCode],-- source
--'pcc_staging_db59277' as  [STgOrgCode], --staging DB, same for all facilities within one PMO
--'usei1214' as [DstOrgCode],--destination
--'usei1214' as [DstOrgCodeProd], --org code of current destination
--R_SRCFACID7 as [SrcFacID],
--1 as [StgFacID],
--R_DSTFACID7 as [DstFacID],
--0 as [ContMerge], --0 = No,1 = Yes
--0 as [ProdRun], --0 = No,1 = Yes
--0 as [PreCaseFac], --0 = No,1 = Yes
--0 as [PreCaseBed], --0 = No,1 = Yes
--'\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_to_Existing_Projects\PMO-59277 SAVA to PGHC\1 (auto) PreMergeScript_Autopre_facR_SRCFACID7.sql' as [PreMergeScript], -- file path of auto-pre
--'\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_to_Existing_Projects\PMO-59277 SAVA to PGHC\2 (auto) PreMergeScriptSource_PreScripts_facR_SRCFACID7.sql' as [PreMergeScriptSrc], --file_path of pre in source
--'\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_to_Existing_Projects\PMO-59277 SAVA to PGHC\3 (auto) PostMergeScriptStaging_facR_SRCFACID7.sql' as [PostMergeScript],---- file path of post in staging (scoping)
--'E14,E15,E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12b,E11,E9,E10,E13,E16,E17,E20,E21,E22,E23' as [ModList],
--0 as [StagingCompleted], -- 0 not completed, 1 = completed
--0 as [Completed], -- 0 not completed, 1 = completed
--7 as [FacilityRunOrder] --starts from 1, incremental by 1 for the later facilities 

--8th fac

--INSERT INTO [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac (PMO_Group_Id,CaseNo,PMO_number,SrcOrgCode,StgOrgCode,DstOrgCode,DstOrgCodeProd,SrcFacID,StgFacID,DstFacID,ContMerge,ProdRun,PreCaseFac,PreCaseBed,PreMergeScript,PreMergeScriptSrc,PostMergeScript,ModList,StagingCompleted,Completed,FacilityRunOrder)
--SELECT @pmo_group_id as [PMO_Group_Id], --PMO_Group_ID created
--'R_CASENUMBER8' as [CaseNo],-- Case Number, unique per facility
--'59277'as [PMO_number],-- PMO Number
--'usei3sava1' as [SrcOrgCode],-- source
--'pcc_staging_db59277' as  [STgOrgCode], --staging DB, same for all facilities within one PMO
--'usei1214' as [DstOrgCode],--destination
--'usei1214' as [DstOrgCodeProd], --org code of current destination
--R_SRCFACID8 as [SrcFacID],
--1 as [StgFacID],
--R_DSTFACID8 as [DstFacID],
--0 as [ContMerge], --0 = No,1 = Yes
--0 as [ProdRun], --0 = No,1 = Yes
--0 as [PreCaseFac], --0 = No,1 = Yes
--0 as [PreCaseBed], --0 = No,1 = Yes
--'\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_to_Existing_Projects\PMO-59277 SAVA to PGHC\1 (auto) PreMergeScript_Autopre_facR_SRCFACID8.sql' as [PreMergeScript], -- file path of auto-pre
--'\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_to_Existing_Projects\PMO-59277 SAVA to PGHC\2 (auto) PreMergeScriptSource_PreScripts_facR_SRCFACID8.sql' as [PreMergeScriptSrc], --file_path of pre in source
--'\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_to_Existing_Projects\PMO-59277 SAVA to PGHC\3 (auto) PostMergeScriptStaging_facR_SRCFACID8.sql' as [PostMergeScript],---- file path of post in staging (scoping)
--'E14,E15,E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12b,E11,E9,E10,E13,E16,E17,E20,E21,E22,E23' as [ModList],
--0 as [StagingCompleted], -- 0 not completed, 1 = completed
--0 as [Completed], -- 0 not completed, 1 = completed
--8 as [FacilityRunOrder] --starts from 1, incremental by 1 for the later facilities 

--9th fac

--INSERT INTO [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac (PMO_Group_Id,CaseNo,PMO_number,SrcOrgCode,StgOrgCode,DstOrgCode,DstOrgCodeProd,SrcFacID,StgFacID,DstFacID,ContMerge,ProdRun,PreCaseFac,PreCaseBed,PreMergeScript,PreMergeScriptSrc,PostMergeScript,ModList,StagingCompleted,Completed,FacilityRunOrder)
--SELECT @pmo_group_id as [PMO_Group_Id], --PMO_Group_ID created
--'R_CASENUMBER9' as [CaseNo],-- Case Number, unique per facility
--'59277'as [PMO_number],-- PMO Number
--'usei3sava1' as [SrcOrgCode],-- source
--'pcc_staging_db59277' as  [STgOrgCode], --staging DB, same for all facilities within one PMO
--'usei1214' as [DstOrgCode],--destination
--'usei1214' as [DstOrgCodeProd], --org code of current destination
--R_SRCFACID9 as [SrcFacID],
--1 as [StgFacID],
--R_DSTFACID9 as [DstFacID],
--0 as [ContMerge], --0 = No,1 = Yes
--0 as [ProdRun], --0 = No,1 = Yes
--0 as [PreCaseFac], --0 = No,1 = Yes
--0 as [PreCaseBed], --0 = No,1 = Yes
--'\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_to_Existing_Projects\PMO-59277 SAVA to PGHC\1 (auto) PreMergeScript_Autopre_facR_SRCFACID9.sql' as [PreMergeScript], -- file path of auto-pre
--'\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_to_Existing_Projects\PMO-59277 SAVA to PGHC\2 (auto) PreMergeScriptSource_PreScripts_facR_SRCFACID9.sql' as [PreMergeScriptSrc], --file_path of pre in source
--'\\STUSPAINFCIFS.pccprod.local\DS\Dataload\TS_FacAcqConfig\DataCopy_to_Existing_Projects\PMO-59277 SAVA to PGHC\3 (auto) PostMergeScriptStaging_facR_SRCFACID9.sql' as [PostMergeScript],---- file path of post in staging (scoping)
--'E14,E15,E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12b,E11,E9,E10,E13,E16,E17,E20,E21,E22,E23' as [ModList],
--0 as [StagingCompleted], -- 0 not completed, 1 = completed
--0 as [Completed], -- 0 not completed, 1 = completed
--9 as [FacilityRunOrder] --starts from 1, incremental by 1 for the later facilities 

select * from  [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac where PMO_Number = '59277'

/*   

All -- 'E14,E15,E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12b,E11,E9,E10,E13,E16,E17,E20,E21,E22,E23' 

	E14 = Security Roles
	E15 = Security User
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
	E22 = Master Insurance
	E23 = Notes
	E18 = Trust

*/

----to undo the complete for Skin and Wound Templates

--update [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_PMO_Groups 
--set completed = 1
--where pmonumber = '10101' 

--update [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac
--set completed = 1
----select * from [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac
--where PMO_Number = '10101'