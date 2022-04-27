select * from LoadEIMaster_Automation
where PMO_Group_Id=1763

update LoadEIMaster_Automation
set DstOrgCode='SRZ',DstOrgCodeProd='SRZ',ProdRun=1
where PMO_Group_Id=1763

select * from LoadEIMaster_Automation
where PMO_Group_Id=1763
