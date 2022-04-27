-- Cannot insert duplicate key row in object 'dbo.pho_std_order' with unique index 'pho_std_order__templateDescriptionForMobile_UIX'. The duplicate key value is (Pneumovax, 0).
 
 update pcc_staging_db58872.dbo.pho_std_order
 set template_description=template_description+'_'
 where template_description='Pneumovax'
