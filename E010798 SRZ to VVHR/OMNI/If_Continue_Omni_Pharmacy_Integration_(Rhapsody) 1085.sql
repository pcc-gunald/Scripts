


--select * from test_usei23.dbo.lib_message_profile where vendor_code like '%omni%'
 

--select  *  from pho_phys_vendor where phys_order_id in (select dst_id from eicase01079812pho_phys_order)	--4037

use test_usei23
go




DECLARE @pmo_group_id int
DECLARE @run_id int
DECLARE @case_number varchar(200)
DECLARE @source_fac_id varchar(50)
DECLARE @destination_fac_id varchar(50)
DECLARE @source_database_full varchar(200)
DECLARE @vendor_code varchar(200)
DECLARE @message_profile_id_in_dst varchar(50)

----------------------------------------------------------------------------------------------------------------------------
--use  --the (destination) DB you'd like to run on

--select * from [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_Automation where [PMO_number] = '010798'
--select * from [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_Automation with (nolock) where pmo_group_id = 902 and runid = 519

SET @pmo_group_id				= 902
SET @run_id						= 519
SET @vendor_code				= 'omnidxalf'
SET @message_profile_id_in_dst	= '166'

----------------------------------------------------------------------------------------------------------------------------


SET CONTEXT_INFO 0xDC1000000; 
SET DEADLOCK_PRIORITY 4;
SET QUOTED_IDENTIFIER ON;


select 
@case_Number = 'EICase' + caseno,
@source_fac_id = srcfacid,
@destination_fac_id = dstfacid
--select *
from [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_Automation with (nolock) 
where pmo_group_id = @pmo_group_id
and runid = @run_id


SELECT 
@source_database_full = '[' + a.servername + '].' + a.databasename
FROM [vmuspassvtsjob1.pccprod.local].[ds_tasks].[dbo].[TS_global_organization_master] a with (nolock)
WHERE a.orgcode in (select top 1 srcorgcode from [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_Automation with (nolock) 
where pmo_group_id = @pmo_group_id and runid = @run_id)
and a.deleted = 'N'


exec [operational].[sproc_facacq_post_IfContinueOmniPharmacyIntegration_step01_map_identifier]
@src_db_location = @source_database_full
,@NS_case_number = @case_Number
,@source_fac_id = @source_fac_id
,@destination_fac_id = @destination_fac_id
,@vendor_code = @vendor_code

exec [operational].[sproc_facacq_post_IfContinueOmniPharmacyIntegration_step02_pho_pharmacy_order]
@src_db_location = @source_database_full
,@NS_case_number = @case_Number
,@source_fac_id = @source_fac_id
,@destination_fac_id = @destination_fac_id

exec [operational].[sproc_facacq_post_IfContinueOmniPharmacyIntegration_step03_pho_pharmacy_note_detail]
@src_db_location = @source_database_full
,@NS_case_number = @case_Number

DELETE FROM pcc_global_primary_usei23 WHERE table_name = 'pho_phys_vendor'

exec [operational].[sproc_facacq_post_IfContinueOmniPharmacyIntegration_step04_pho_phys_vendor]
@src_db_location = @source_database_full
,@NS_case_number = @case_Number
,@message_profile_id = @message_profile_id_in_dst

exec [operational].[sproc_facacq_post_IfContinueOmniPharmacyIntegration_step05_pho_supply_dispense]
@src_db_location = @source_database_full
,@NS_case_number = @case_Number


/*


if exists(select 1 from information_schema.TABLES where table_name = 'EICase01079864map_identifier')

begin
	drop table EICase01079864map_identifier
end

select identity(int,1,1) as row_id, src.map_identifier_id as src_id, NULL as dst_id
into EICase01079864map_identifier
from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.map_identifier src with (nolock)
where fac_id = 64 
and map_type_id = 2
and internal_id in (select src_id from EICase01079864clients)
and vendor_code = 'omnidxalf'

sproc_facacq_post_IfContinueOmniPharmacyIntegration_step01_map_identifier - (EICase01079864map_identifier) - 1 affected rows

UPDATE dbo.EICase01079864map_identifier SET dst_id = 396598 + ([row_id] - 1)
		
sproc_facacq_post_IfContinueOmniPharmacyIntegration_step01_map_identifier - 34 affected rows.

insert into  map_identifier(map_identifier_id,
created_by,
created_date,
revision_by,
revision_date,
fac_id,
reg_id,
vendor_code,
map_type_id,
external_id,
internal_id)
select map.dst_id,
created_by,
created_date,
revision_by,
revision_date,
40,
reg_id,
vendor_code,
map_type_id,
external_id,
internal_id    
from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.map_identifier src
join EICase01079864map_identifier map on src.map_identifier_id = map.src_id
where src.fac_id = 64

update map_identifier
set internal_id = cl.dst_id
from map_identifier map
join EICase01079864clients cl on cl.src_id = map.internal_id
where map.map_type_id = 2
and fac_id = 40
sproc_facacq_post_IfContinueOmniPharmacyIntegration_step01_map_identifier - (map_identifier) - 34 affected rows


if exists(select 1 from information_schema.TABLES where table_name = 'EICase01079864pho_pharmacy_order')

begin
	drop table EICase01079864pho_pharmacy_order
end

select identity(int,1,1) as row_id, src.pharmacy_order_id as src_id, NULL as dst_id
into dbo.EICase01079864pho_pharmacy_order
from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.pho_pharmacy_order src
where fac_id = 64
and ext_client_id in (select external_id from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.map_identifier
	where map_identifier_id in (select src_id from EICase01079864map_identifier))


sproc_facacq_post_IfContinueOmniPharmacyIntegration_step02_pho_pharmacy_order - (EICase01079864pho_pharmacy_order) - 1 affected rows

UPDATE dbo.EICase01079864pho_pharmacy_order SET dst_id = 2631407 + ([row_id] - 1)
		
sproc_facacq_post_IfContinueOmniPharmacyIntegration_step02_pho_pharmacy_order - 2928 affected rows.

insert into  pho_pharmacy_order(pharmacy_order_id,
created_by,
created_date,
fac_id,
phys_order_id,
vendor_code,
ext_fac_id,
ext_client_id,
description,
related_generic,
label_name,
drug_code,
start_date,
end_date,
directions,
tran_id,
prescription,
pharmacy_shipment_id,
physician_license_no,
physician_firstname,
physician_lastname,
patient_firstname,
patient_lastname,
patient_middlename,
patient_suffix,
patient_prefix,
patient_alias,
patient_healthcard_no,
receive_status,
order_status,
scan_date,
status_change_by,
status_change_date,
controlled_substance_code,
ext_order_type,
fill_date,
shape_color_marking,
disp_package_identifier,
auto_fill_flag,
related_phys_order_id,
relationship,
disp_code,
exp_ship_date,
quantity_remaining,
ext_pharmacy_id,
drug_manufacturer,
drug_class_number,
form,
strength,
route_of_admin,
diagnoses,
nurse_admin_notes,
event_driven_flag,
discrepancy_code,
end_date_type,
end_date_duration_type,
end_date_duration,
revision_by,
revision_date,
received_by,
receiver_position,
quantity_received,
next_refill_date,
substitution_indicator,
vendor_supply_id,
dispensation_sequence_number,
vendor_phys_order_id,
inbound_message_id,
auto_fill_system_name)
SELECT  map3.dst_id,
created_by,
created_date,
40,
map.dst_id,
vendor_code,
ext_fac_id,
ext_client_id,
description,
related_generic,
label_name,
drug_code,
start_date,
end_date,
directions,
tran_id,
prescription,
pharmacy_shipment_id,
physician_license_no,
physician_firstname,
physician_lastname,
patient_firstname,
patient_lastname,
patient_middlename,
patient_suffix,
patient_prefix,
patient_alias,
patient_healthcard_no,
receive_status,
order_status,
scan_date,
status_change_by,
status_change_date,
controlled_substance_code,
ext_order_type,
fill_date,
shape_color_marking,
disp_package_identifier,
auto_fill_flag,
related_phys_order_id,
relationship,
disp_code,
exp_ship_date,
quantity_remaining,
map2.dst_id,
drug_manufacturer,
drug_class_number,
form,
strength,
route_of_admin,
diagnoses,
nurse_admin_notes,
event_driven_flag,
discrepancy_code,
end_date_type,
end_date_duration_type,
end_date_duration,
revision_by,
revision_date,
received_by,
receiver_position,
quantity_received,
next_refill_date,
substitution_indicator,
vendor_supply_id,
dispensation_sequence_number,
vendor_phys_order_id,
NULL,
auto_fill_system_name  
from  [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.pho_pharmacy_order src
left join dbo.EICase01079864pho_phys_order map on src.phys_order_id=map.src_id
join EICase01079864emc_ext_facilities map2 on map2.src_id=src.ext_pharmacy_id
join EICase01079864pho_pharmacy_order map3 on map3.src_id=src.pharmacy_order_id
where src.fac_id = 64
sproc_facacq_post_IfContinueOmniPharmacyIntegration_step02_pho_pharmacy_order - (pho_pharmacy_order) - 2928 affected rows


if exists(select 1 from information_schema.TABLES where table_name = 'EICase01079864pho_pharmacy_note_detail')

begin
	drop table EICase01079864pho_pharmacy_note_detail
end

select identity(int,1,1) as row_id, src.pharmacy_note_detail_id as src_id,NULL as dst_id
into dbo.EICase01079864pho_pharmacy_note_detail
from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.pho_pharmacy_note_detail src
where pharmacy_order_id in (select src_id from EICase01079864pho_pharmacy_order)


sproc_facacq_post_IfContinueOmniPharmacyIntegration_step03_pho_pharmacy_note_detail - (EICase01079864pho_pharmacy_note_detail) - 1 affected rows

UPDATE dbo.EICase01079864pho_pharmacy_note_detail SET dst_id = 10936572 + ([row_id] - 1)
		
sproc_facacq_post_IfContinueOmniPharmacyIntegration_step03_pho_pharmacy_note_detail - 640 affected rows.

insert into  pho_pharmacy_note_detail (pharmacy_note_detail_id,
created_by,
created_date,
pharmacy_order_id,
note_type,
note)
select  map2.dst_id,
created_by,
created_date,
map.dst_id,
note_type,
note  
from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.pho_pharmacy_note_detail src
join EICase01079864pho_pharmacy_order map on src.pharmacy_order_id = map.src_id
join EICase01079864pho_pharmacy_note_detail map2 on map2.src_id = src.pharmacy_note_detail_id
sproc_facacq_post_IfContinueOmniPharmacyIntegration_step03_pho_pharmacy_note_detail - (pho_pharmacy_note_detail) - 640 affected rows

(0 rows affected)


if exists(select 1 from information_schema.TABLES where table_name = 'EICase01079864pho_phys_vendor')

begin
	drop table EICase01079864pho_phys_vendor
end

select identity(int,1,1) as row_id, src.phys_vendor_id as src_id, NULL as dst_id
into dbo.EICase01079864pho_phys_vendor
from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.pho_phys_vendor src 
join EICase01079864pho_phys_order map on src.phys_order_id = map.src_id


sproc_facacq_post_IfContinueOmniPharmacyIntegration_step04_pho_phys_vendor - (EICase01079864pho_phys_vendor) - 1 affected rows
Checking identity information: current identity value '1204079'.
DBCC execution completed. If DBCC printed error messages, contact your system administrator.

UPDATE dbo.EICase01079864pho_phys_vendor SET dst_id = 120404 + ([row_id] - 1)
		
sproc_facacq_post_IfContinueOmniPharmacyIntegration_step04_pho_phys_vendor - 4095 affected rows.


set identity_insert pho_phys_vendor on
 
insert into pho_phys_vendor (phys_vendor_id,
phys_order_id,
message_profile_id,
disp_sequence_number,
prescription,
disp_package_identifier,
vendor_order_id,
active)
select map.dst_id,
map2.dst_id,
166,
disp_sequence_number,
prescription,
disp_package_identifier,
vendor_order_id,
active
from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.pho_phys_vendor src
join EICase01079864pho_phys_vendor map on src.phys_vendor_id = map.src_id
join EICase01079864pho_phys_order map2 on map2.src_id = src.phys_order_id

set identity_insert pho_phys_vendor off 


sproc_facacq_post_IfContinueOmniPharmacyIntegration_step04_pho_phys_vendor - (pho_phys_vendor) - 0 affected rows

if exists(select 1 from information_schema.TABLES where table_name = 'EICase01079864pho_supply_dispense')

begin
	drop table EICase01079864pho_supply_dispense
end

select identity(int,1,1) as row_id, src.supply_dispense_id as src_id,NULL as dst_id
into dbo.EICase01079864pho_supply_dispense
from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.pho_supply_dispense src
join EICase01079864pho_order_supply map on src.order_supply_id = map.src_id
join  pho_order_supply dest on dest.order_supply_id = map.dst_id

sproc_facacq_post_IfContinueOmniPharmacyIntegration_step05_pho_supply_dispense - (EICase01079864pho_supply_dispense) - 1 affected rows

UPDATE dbo.EICase01079864pho_supply_dispense SET dst_id = 16457858 + ([row_id] - 1)
		
sproc_facacq_post_IfContinueOmniPharmacyIntegration_step05_pho_supply_dispense - 4051 affected rows.

insert into  pho_supply_dispense (supply_dispense_id,
order_supply_id,
pharmacy_order_id,
created_by,
created_date,
deleted,
deleted_by,
deleted_date,
match_type )
select  
map.dst_id,
map4.dst_id,
map3.dst_id,
src.created_by,
src.created_date,
src.deleted,
src.deleted_by,
src.deleted_date,
src.match_type
from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.pho_supply_dispense src
join EICase01079864pho_supply_dispense map on map.src_id = src.supply_dispense_id 
join EICase01079864pho_pharmacy_order map3 on map3.src_id = src.pharmacy_order_id
join EICase01079864pho_order_supply map4 on map4.src_id = src.order_supply_id
join pho_order_supply dest on dest.order_supply_id = map4.dst_id


sproc_facacq_post_IfContinueOmniPharmacyIntegration_step05_pho_supply_dispense - (pho_supply_dispense) - 4051 affected rows

Completion time: 2021-11-19T11:06:40.686596-05:00

*/