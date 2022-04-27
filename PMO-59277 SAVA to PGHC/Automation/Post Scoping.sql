SET CONTEXT_INFO 0xDC1000000;
 SET DEADLOCK_PRIORITY 4;
 SET QUOTED_IDENTIFIER ON;

Update   [pcc_staging_db59277].dbo.[census_item]
Set flexible_rate_rule_id = NULL

Update   [pcc_staging_db59277].dbo.census_item
--select [contract_census_id],* from [pcc_staging_db59277].dbo.[census_item]
Set [contract_census_id] = NULL


Update [pcc_staging_db59277].dbo.[pho_order_related_value]
Set cp_sec_user_audit_id = 1
Where cp_sec_user_audit_id= 102593
--2

Update [pcc_staging_db59277].dbo.[pho_phys_order_audit_useraudit]
Set [edited_by_audit_id] = 1
Where [edited_by_audit_id] IN  (103401,86317)
--97

Update [pcc_staging_db59277].dbo.[pho_phys_order_audit_useraudit]
Set [edited_by_audit_id] = 1
Where [edited_by_audit_id] IN  (103401,86317)
--97


Update [pcc_staging_db59277].dbo.[pho_phys_order_audit_useraudit]
Set [created_by_audit_id] = 1
Where [created_by_audit_id] IN  (103401,86317)
--95