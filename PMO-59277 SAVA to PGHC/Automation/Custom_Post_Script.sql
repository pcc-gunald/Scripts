Use us_pghc_multi

SET CONTEXT_INFO 0xDC1000000;
 SET DEADLOCK_PRIORITY 4;
 SET QUOTED_IDENTIFIER ON;

print  CHAR(13) + 'Started running : 11 (If OMNI integration - all residents)'  

--/*

--This scripts was created by merging

--16 Insert_MapIdentifier (If OMNI integration - all residents)
--17 Insert_Pho_Pharmacy_order (If OMNI integration - all residents)
--18 Insert_Pho_pharmacy_note_detail (If OMNI integration - all residents)
--19 Insert_pho_phys_vendor (If OMNI integration - all residents)
--20 Insert_Pho_supply_dispense (If OMNI integration - all residents)

--Make sure to change the message profile ID, follow the below 4 steps

-- Find message_profile_id in use in source production: 
--	SELECT DISTINCT message_profile_id, * 
--	FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.pho_phys_vendor AS src 
--	INNER JOIN us_pghc_multi.dbo.EICase59277183pho_phys_order AS map ON src.phys_order_id = map.src_id

-- Find vendor in source production: 
--	SELECT * FROM [sqluspaw29cli01.pccprod.local].us_sava_multi.dbo.lib_message_profile

-- Match to vendor in destination production: 
--	SELECT * FROM [pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi.dbo.lib_message_profile

-- Destination message_profile_id: (Replaece this variable below)
--	235

--*/


print  CHAR(13) + '16 Insert_MapIdentifier (If OMNI integration - all residents) running now ' 

DECLARE @Maxmap_identifier_id INT ,@Rowcount INT ,@facid INT

select identity(int,0,1) as row, src.map_identifier_id as src_id, NULL as dst_id
into dbo.EICase59277183map_identifier
--select *
from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.map_identifier src
where fac_id = 183
and map_type_id = 2

set @Rowcount=@@rowcount
exec get_next_primary_key 'map_identifier','map_identifier_id',@Maxmap_identifier_id output , @Rowcount

update  dbo.EICase59277183map_identifier  
set  dst_id = row+@Maxmap_identifier_id

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
173,
reg_id,
vendor_code,
map_type_id,
external_id,
internal_id    
--select  *   
from  [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.map_identifier src
join EICase59277183map_identifier map
on src.map_identifier_id= map.src_id
where  src.fac_id= 183 

update  map_identifier
set  internal_id=cl.dst_id
--select  *  
from  map_identifier map
join dbo.EICase59277183clients cl
on cl.src_id=map.internal_id
where map.map_type_id=2
and fac_id = 173 

GO

print  CHAR(13) + '17 Insert_Pho_Pharmacy_order (If OMNI integration - all residents) running now ' 

DECLARE @Maxpharmacy_order_id INT ,@Rowcount INT ,@facid INT

select identity(int,0,1) as row, src.pharmacy_order_id as src_id, NULL as dst_id
into dbo.EICase59277183pho_pharmacy_order
--select *
from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_pharmacy_order src
where fac_id = 183 

set @Rowcount=@@rowcount
exec get_next_primary_key 'pho_pharmacy_order','pharmacy_order_id',@Maxpharmacy_order_id output , @Rowcount

update  dbo.EICase59277183pho_pharmacy_order 
set  dst_id = row+@Maxpharmacy_order_id

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
SELECT   map3.dst_id,
created_by,
created_date,
173,
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
---select  * 
from  [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_pharmacy_order src 
left join dbo.EICase59277183pho_phys_order map
on src.phys_order_id=map.src_id
join EICase59277183emc_ext_facilities map2
on map2.src_id=src.ext_pharmacy_id
join EICase59277183pho_pharmacy_order map3
on map3.src_id=src.pharmacy_order_id
where src.fac_id=183 

GO

print  CHAR(13) + '18 Insert_Pho_pharmacy_note_detail (If OMNI integration - all residents) running now ' 

DECLARE @Maxpharmacy_note_detail_id INT ,@Rowcount INT ,@facid INT

select identity(int,0,1) as row, src.pharmacy_note_detail_id as src_id,
 NULL as dst_id
into dbo.EICase59277183pho_pharmacy_note_detail
--select *
from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_pharmacy_note_detail src
where pharmacy_order_id in  (select  pharmacy_order_id  from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_pharmacy_order
where  fac_id=183)

set @Rowcount=@@rowcount
exec get_next_primary_key 'pho_pharmacy_note_detail','pharmacy_note_detail_id',@Maxpharmacy_note_detail_id output , @Rowcount

update  dbo.EICase59277183pho_pharmacy_note_detail 
set  dst_id = row+@Maxpharmacy_note_detail_id

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
--select * 
from  [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_pharmacy_note_detail src 
join  EICase59277183pho_pharmacy_order map
on  src.pharmacy_order_id=map.src_id
join EICase59277183pho_pharmacy_note_detail map2
on map2.src_id=src.pharmacy_note_detail_id

GO

print  CHAR(13) + '19 Insert_pho_phys_vendor (If OMNI integration - all residents) running now ' 

--DROP TABLE EICase59277183pho_phys_vendor
--DELETE FROM pcc_global_primary_key WHERE table_name = 'pho_phys_vendor'
 
 DECLARE @Maxphys_vendor_id INT ,@Rowcount INT ,@facid INT

select identity(int,0,1) as row, src.phys_vendor_id as src_id,
 NULL as dst_id
into dbo.EICase59277183pho_phys_vendor
--select  *  
from  [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_phys_vendor src --
join EICase59277183pho_phys_order map
on src.phys_order_id=map.src_id 

set @Rowcount=@@rowcount
exec get_next_primary_key 'pho_phys_vendor','phys_vendor_id',@Maxphys_vendor_id output , @Rowcount

update  dbo.EICase59277183pho_phys_vendor 
set  dst_id = row+@Maxphys_vendor_id

set identity_insert  pho_phys_vendor on
 
insert into pho_phys_vendor (phys_vendor_id,
phys_order_id,
message_profile_id,
disp_sequence_number,
prescription,
disp_package_identifier,
vendor_order_id,
active)
select  map.dst_id,
map2.dst_id,
235,	--message_profile_id from above
disp_sequence_number,
prescription,
disp_package_identifier,
vendor_order_id,
active
--select  *  
from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_phys_vendor  src
join EICase59277183pho_phys_vendor map
on src.phys_vendor_id=map.src_id
join EICase59277183pho_phys_order map2
on map2.src_id=src.phys_order_id

set identity_insert  pho_phys_vendor off

GO

print  CHAR(13) + '20 Insert_Pho_supply_dispense (If OMNI integration - all residents) running now ' 

DECLARE @Maxsupply_dispense_id INT ,@Rowcount INT ,@facid INT

select identity(int,0,1) as row, src.supply_dispense_id as src_id,
 NULL as dst_id
into dbo.EICase59277183pho_supply_dispense
--select  *  
from  [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_supply_dispense src --
join EICase59277183pho_order_supply map
on src.order_supply_id=map.src_id 
join  pho_order_supply dest
on dest.order_supply_id=map.dst_id

set @Rowcount=@@rowcount
exec get_next_primary_key 'pho_supply_dispense','supply_dispense_id',@Maxsupply_dispense_id output , @Rowcount

update  dbo.EICase59277183pho_supply_dispense 
set  dst_id = row+@Maxsupply_dispense_id

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
--select  * 
from [vmuspassvtscon3.pccprod.local].test_usei3sava1.dbo.pho_supply_dispense src
join EICase59277183pho_supply_dispense map
on map.src_id=src.supply_dispense_id 
join EICase59277183pho_pharmacy_order map3
on map3.src_id=src.pharmacy_order_id 
join EICase59277183pho_order_supply map4
on map4.src_id=src.order_supply_id
join pho_order_supply dest
on dest.order_supply_id=map4.dst_id 

print  CHAR(13) + 'Ended running : 11 (If OMNI integration - all residents)	'  

/*
16 Insert_MapIdentifier (If OMNI integration - all residents) running now 

(1201 rows affected)

(1201 rows affected)

(1201 rows affected)

(1201 rows affected)

Completion time: 2022-03-02T10:10:36.5665480-05:00

17 Insert_Pho_Pharmacy_order (If OMNI integration - all residents) running now 

(72123 rows affected)

(72123 rows affected)

(72123 rows affected)

Completion time: 2022-03-02T10:12:09.1973661-05:00

18 Insert_Pho_pharmacy_note_detail (If OMNI integration - all residents) running now 

(67441 rows affected)

(67441 rows affected)

(67441 rows affected)

Completion time: 2022-03-02T10:14:43.0496543-05:00
19 Insert_pho_phys_vendor (If OMNI integration - all residents) running now 

(13821 rows affected)
insert into pcc_global_primary_key select 'pho_phys_vendor', 'phys_vendor_id', 1, ( select max( [phys_vendor_id] )+1 from [pho_phys_vendor] where phys_vendor_id>= 0)

(13821 rows affected)

(13821 rows affected)

Completion time: 2022-03-02T10:20:00.3832646-05:00
20 Insert_Pho_supply_dispense (If OMNI integration - all residents) running now 

(11713 rows affected)

(11713 rows affected)

(11713 rows affected)
Ended running : 11 (If OMNI integration - all residents)	

Completion time: 2022-03-02T10:22:30.3017600-05:00

*/