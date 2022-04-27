
    DECLARE @pmo_group_id INT
    INSERT INTO ds_merge_master.dbo.LoadEIMaster_PMO_Groups
    (PMONumber,Completed)
    SELECT 
    'E010805' as PMONumber, --PMO Number
    0 as Completed

    SELECT @pmo_group_id=SCOPE_IDENTITY()

    select * from LoadEIMaster_PMO_Groups where PMONumber like '%E010805%'

    drop table if exists #temp_fac
    create table #temp_fac(caseNo varchar(50),src_id int, dest_id int, id int identity (1,1))
    insert into #temp_fac values('E010805',1,13) 

    INSERT INTO ds_merge_master.dbo.LoadEIMaster_Automation(PMO_Group_Id,CaseNo,PMO_number,SrcOrgCode,StgOrgCode,DstOrgCode,DstOrgCodeProd,SrcFacID,StgFacID,DstFacID,ContMerge,ProdRun
    ,PreCaseFac,PreCaseBed,ModList,StagingCompleted
    ,Completed,FacilityRunOrder)
    SELECT @pmo_group_id as [PMO_Group_Id], --PMO_Group_ID created
    concat(caseNo,src_id) as [CaseNo],-- Case Number, unique per facility
    caseNo as [PMO_number],-- PMO Number
    'USEI996' as [SrcOrgCode],-- source
    'pcc_staging_dbE010805' as  [STgOrgCode], --staging DB, same for all facilities within one PMO
    'USEI34' as [DstOrgCode],--destination
    'USEI34' as [DstOrgCodeProd], --org code of current destination
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

    SELECT @pmo_group_id

    