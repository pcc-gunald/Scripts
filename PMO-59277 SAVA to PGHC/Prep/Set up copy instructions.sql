--in server vmuspassvtsjob1.pccprod.local
INSERT INTO [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_PMO_Groups
		(PMONumber,Completed)
		SELECT 
		'58508' as PMONumber, --PMO Number
		0 as Completed
		--1

--for review and to get the PMO Group ID for the next step
select * from [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_PMO_Groups where PMONumber = '58508'

--PMO_Group_Id	PMONumber	Completed
--1795			58508			0






---------------------------------------------------------------------------------------------------------------------------

 INSERT INTO [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_Automation 
		(PMO_Group_Id,CaseNo,PMO_number,SrcOrgCode,StgOrgCode,DstOrgCode,DstOrgCodeProd,SrcFacID,StgFacID,DstFacID,ContMerge,ProdRun
		,PreCaseFac,PreCaseBed,PreMergeScript,PreMergeScriptSrc,PostMergeScript,PreMergeScriptDST,PostMergeScriptDST,ModList,StagingCompleted,Completed,FacilityRunOrder)
		SELECT '1795' as [PMO_Group_Id], --PMO_Group_ID created
		'58508_6' as [CaseNo],-- Case Number, unique per facility
		'58508'as [PMO_number],-- PMO Number
		'usei2' as [SrcOrgCode],-- source
		'pcc_staging_db_58508' as  [STgOrgCode], --staging DB, same for all facilities within one PMO
		'usei1036' as [DstOrgCode],--destination
		'usei1036' as [DstOrgCodeProd], --org code of current destination
		6 as [SrcFacID],--
		1 as [StgFacID],--
		217 as [DstFacID],--
		0 as [ContMerge], --0 = No,1 = Yes
		0 as [ProdRun], --0 = No,1 = Yes
		0 as [PreCaseFac], --0 = No,1 = Yes
		0 as [PreCaseBed], --0 = No,1 = Yes
		'' as [PreMergeScript], -- file path of auto-pre
		'' as [PreMergeScriptSrc], --file_path of pre in source
		'' as [PostMergeScript], --file_path of pre in source
		'' as [PreMergeScriptDST],----Pre script for DST. Use for GAP import
		'' as [PostMergeScriptDST],----Post script after Staging to Dest
		'E15,E1,E2,E2a,E3,E4,E5,E6,E7a,E7b,E7c,E8,E12b,E11,E9,E10,E13,E16,E17,E18,E20,E21,E22,E23' as [ModList],
		0 as [StagingCompleted], -- 0 not completed, 1 = completed
		0 as [Completed], -- 0 not completed, 1 = completed
		2 as [FacilityRunOrder] --starts from 1, incremental by 1 for the later facilities

select * from [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_Automation where PMO_number = '58508'

