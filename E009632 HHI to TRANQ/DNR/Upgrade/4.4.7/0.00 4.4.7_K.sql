

SET NOCOUNT ON
GO

SET DEADLOCK_PRIORITY HIGH
GO


insert into upload_tracking (script, timestamp, upload) values ('UPLOAD_START',getdate(),'4.4.7_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_facacq_post_IfCopyEMRLink_01_emrlink_client_sync_tracking.sql',getdate(),'4.4.7_06_CLIENT_K_Operational_Branch_US.sql')

GO

SET ANSI_NULLS ON
GO
SET ARITHABORT ON
GO
SET ANSI_WARNINGS ON
GO
SET ANSI_PADDING ON
GO
SET CONCAT_NULL_YIELDS_NULL ON
GO
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_NULL_DFLT_ON ON
GO

SET QUOTED_IDENTIFIER ON
GO



if exists (select * from dbo.sysobjects where id = object_id(N'[operational].[sproc_facacq_post_IfCopyEMRLink_01_emrlink_client_sync_tracking]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [operational].sproc_facacq_post_IfCopyEMRLink_01_emrlink_client_sync_tracking
go

CREATE PROCEDURE [operational].sproc_facacq_post_IfCopyEMRLink_01_emrlink_client_sync_tracking
		@src_db_location varchar(2000), --[server_name].[db_name]
		@NS_case_number varchar(200)

/********************************************************************************

Purpose: Post insert for emrlink related tables when needed

e.g.
exec  [operational].[sproc_facacq_post_IfCopyEMRLink_01_emrlink_client_sync_tracking]  '[src_server].src_db','EICase1234567'

**********************************************************************************/ 
AS
declare @sql varchar(max)
declare @message varchar(4000)
declare @Table_Count bigint
declare @Table_NextKey BIGINT
declare @current_db varchar(200) = db_name()
SET NOCOUNT ON;
	
BEGIN TRY

------------------------------------


set @sql = concat('

if exists(select 1 from information_schema.TABLES where table_name = ''',@NS_case_number,'emrlink_client_sync_tracking'')

begin
	drop table ',@NS_case_number,'emrlink_client_sync_tracking
end

CREATE TABLE [dbo].[',@NS_case_number,'emrlink_client_sync_tracking](
[row_id] [int] IDENTITY(1,1) NOT NULL,
[src_id] [bigint] NULL,
[dst_id] [bigint] NULL,
[corporate] [char](1) NULL DEFAULT (''N'')
) ON [PRIMARY]

insert into ',@NS_case_number,'emrlink_client_sync_tracking
select src.emrlink_client_sync_tracking_id as src_id, NULL as dst_id, ''N'' as corporate
from ',@src_db_location,'.dbo.emrlink_client_sync_tracking src with (nolock)
where src.client_id in (select src_id from ',@NS_case_number,'clients)
')

print @SQL      
EXEC(@SQL)
set @Table_Count = @@rowcount
set @message = concat( OBJECT_NAME(@@PROCID), ' - (',@NS_case_number,'emrlink_client_sync_tracking) - ', @@ROWCOUNT, ' affected rows')
print @message

EXEC  [operational].[sproc_facacq_Key_Reservation]
      @current_db
    , 'emrlink_client_sync_tracking'
    , 'emrlink_client_sync_tracking_id'
    , @Table_Count
    , @Table_NextKey OUTPUT


set @sql = concat('
UPDATE dbo.',@NS_case_number,'emrlink_client_sync_tracking SET dst_id = ',@Table_NextKey,' + ([row_id] - 1)
		')

exec(@sql)
set @message = concat( OBJECT_NAME(@@PROCID), ' - ', @@ROWCOUNT, ' affected rows.')
print @sql
print @message


set @sql = concat('
set identity_insert emrlink_client_sync_tracking on

insert into emrlink_client_sync_tracking (
emrlink_client_sync_tracking_id,
client_id,
cp_sec_user_audit_id,
created_date,
last_sync_date
)
select map.dst_id,
map2.dst_id,
map3.dst_id,
created_date,
last_sync_date 
from ',@src_db_location,'.dbo.emrlink_client_sync_tracking src with (nolock)
join ',@NS_case_number,'emrlink_client_sync_tracking map on src.emrlink_client_sync_tracking_id = map.src_id
join ',@NS_case_number,'clients map2 on src.client_id = map2.src_id
left join ',@NS_case_number,'cp_sec_user_audit map3 on src.cp_sec_user_audit_id = map3.src_id

set identity_insert emrlink_client_sync_tracking off

'
)

print @SQL      
EXEC(@SQL)
set @message = concat( OBJECT_NAME(@@PROCID), ' - (emrlink_client_sync_tracking) - ', @@ROWCOUNT, ' affected rows')
print @message



END TRY
BEGIN CATCH
		set @message = concat( OBJECT_NAME(@@PROCID), ' - ', ERROR_MESSAGE(), ' @sql: ', @sql)
		print @message
		raiserror(@message, 16, 1)
END CATCH

GO



GO

print 'K_Operational_Branch/5_StoredProcedures/sproc_facacq_post_IfCopyEMRLink_01_emrlink_client_sync_tracking.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_facacq_post_IfCopyEMRLink_01_emrlink_client_sync_tracking.sql',getdate(),'4.4.7_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_facacq_post_IfCopyEMRLink_02_emrlink_order_sync_tracking.sql',getdate(),'4.4.7_06_CLIENT_K_Operational_Branch_US.sql')

GO

SET ANSI_NULLS ON
GO
SET ARITHABORT ON
GO
SET ANSI_WARNINGS ON
GO
SET ANSI_PADDING ON
GO
SET CONCAT_NULL_YIELDS_NULL ON
GO
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_NULL_DFLT_ON ON
GO

SET QUOTED_IDENTIFIER ON
GO



if exists (select * from dbo.sysobjects where id = object_id(N'[operational].[sproc_facacq_post_IfCopyEMRLink_02_emrlink_order_sync_tracking]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [operational].sproc_facacq_post_IfCopyEMRLink_02_emrlink_order_sync_tracking
go

CREATE PROCEDURE [operational].sproc_facacq_post_IfCopyEMRLink_02_emrlink_order_sync_tracking
		@src_db_location varchar(2000), --[server_name].[db_name]
		@NS_case_number varchar(200)

/********************************************************************************

Purpose: Post insert for emrlink related tables when needed

e.g.
exec  [operational].[sproc_facacq_post_IfCopyEMRLink_02_emrlink_order_sync_tracking]  '[src_server].src_db','EICase1234567'

**********************************************************************************/ 
AS
declare @sql varchar(max)
declare @message varchar(4000)
declare @Table_Count bigint
declare @Table_NextKey BIGINT
declare @current_db varchar(200) = db_name()
SET NOCOUNT ON;
	
BEGIN TRY

------------------------------------


set @sql = concat('

if exists(select 1 from information_schema.TABLES where table_name = ''',@NS_case_number,'emrlink_order_sync_tracking'')

begin
	drop table ',@NS_case_number,'emrlink_order_sync_tracking
end

CREATE TABLE [dbo].[',@NS_case_number,'emrlink_order_sync_tracking](
[row_id] [int] IDENTITY(1,1) NOT NULL,
[src_id] [bigint] NULL,
[dst_id] [bigint] NULL,
[corporate] [char](1) NULL DEFAULT (''N'')
) ON [PRIMARY]

insert into ',@NS_case_number,'emrlink_order_sync_tracking
select src.emrlink_order_sync_tracking_id as src_id, NULL as dst_id, ''N'' as corporate
from ',@src_db_location,'.dbo.emrlink_order_sync_tracking src with (nolock)
where src.client_id in (select src_id from ',@NS_case_number,'clients)
and src.phys_order_id in (select src_id from ',@NS_case_number,'pho_phys_order)
')

print @SQL      
EXEC(@SQL)
set @Table_Count = @@rowcount
set @message = concat( OBJECT_NAME(@@PROCID), ' - (',@NS_case_number,'emrlink_order_sync_tracking) - ', @@ROWCOUNT, ' affected rows')
print @message

EXEC  [operational].[sproc_facacq_Key_Reservation]
      @current_db
    , 'emrlink_order_sync_tracking'
    , 'emrlink_order_sync_tracking_id'
    , @Table_Count
    , @Table_NextKey OUTPUT


set @sql = concat('
UPDATE dbo.',@NS_case_number,'emrlink_order_sync_tracking SET dst_id = ',@Table_NextKey,' + ([row_id] - 1)
		')

exec(@sql)
set @message = concat( OBJECT_NAME(@@PROCID), ' - ', @@ROWCOUNT, ' affected rows.')
print @sql
print @message


set @sql = concat('
set identity_insert emrlink_order_sync_tracking on

insert into emrlink_order_sync_tracking (
emrlink_order_sync_tracking_id,
client_id,
emrlink_order_id,
phys_order_id,
last_sync_date
)
select map.dst_id,
map2.dst_id,
emrlink_order_id,
map3.dst_id,
last_sync_date 
from ',@src_db_location,'.dbo.emrlink_order_sync_tracking src with (nolock)
join ',@NS_case_number,'emrlink_order_sync_tracking map on src.emrlink_order_sync_tracking_id = map.src_id
join ',@NS_case_number,'clients map2 on src.client_id = map2.src_id
join ',@NS_case_number,'pho_phys_order map3 on src.phys_order_id = map3.src_id

set identity_insert emrlink_order_sync_tracking off

'

)

print @SQL      
EXEC(@SQL)
set @message = concat( OBJECT_NAME(@@PROCID), ' - (emrlink_order_sync_tracking) - ', @@ROWCOUNT, ' affected rows')
print @message



END TRY
BEGIN CATCH
		set @message = concat( OBJECT_NAME(@@PROCID), ' - ', ERROR_MESSAGE(), ' @sql: ', @sql)
		print @message
		raiserror(@message, 16, 1)
END CATCH

GO



GO

print 'K_Operational_Branch/5_StoredProcedures/sproc_facacq_post_IfCopyEMRLink_02_emrlink_order_sync_tracking.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_facacq_post_IfCopyEMRLink_02_emrlink_order_sync_tracking.sql',getdate(),'4.4.7_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_facacq_post_IfCopyEMRLink_03_emrlink_order_sync_error_tracking.sql',getdate(),'4.4.7_06_CLIENT_K_Operational_Branch_US.sql')

GO

SET ANSI_NULLS ON
GO
SET ARITHABORT ON
GO
SET ANSI_WARNINGS ON
GO
SET ANSI_PADDING ON
GO
SET CONCAT_NULL_YIELDS_NULL ON
GO
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_NULL_DFLT_ON ON
GO

SET QUOTED_IDENTIFIER ON
GO



if exists (select * from dbo.sysobjects where id = object_id(N'[operational].[sproc_facacq_post_IfCopyEMRLink_03_emrlink_order_sync_error_tracking]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [operational].sproc_facacq_post_IfCopyEMRLink_03_emrlink_order_sync_error_tracking
go

CREATE PROCEDURE [operational].sproc_facacq_post_IfCopyEMRLink_03_emrlink_order_sync_error_tracking
		@src_db_location varchar(2000), --[server_name].[db_name]
		@NS_case_number varchar(200)

/********************************************************************************

Purpose: Post insert for emrlink related tables when needed

e.g.
exec  [operational].[sproc_facacq_post_IfCopyEMRLink_03_emrlink_order_sync_error_tracking]  '[src_server].src_db','EICase1234567'

**********************************************************************************/ 
AS
declare @sql varchar(max)
declare @message varchar(4000)
declare @Table_Count bigint
declare @Table_NextKey BIGINT
declare @current_db varchar(200) = db_name()
SET NOCOUNT ON;
	
BEGIN TRY

------------------------------------


set @sql = concat('

if exists(select 1 from information_schema.TABLES where table_name = ''',@NS_case_number,'emrlink_order_sync_error_tracking'')

begin
	drop table ',@NS_case_number,'emrlink_order_sync_error_tracking
end

CREATE TABLE [dbo].[',@NS_case_number,'emrlink_order_sync_error_tracking](
[row_id] [int] IDENTITY(1,1) NOT NULL,
[src_id] [bigint] NULL,
[dst_id] [bigint] NULL,
[corporate] [char](1) NULL DEFAULT (''N'')
) ON [PRIMARY]

insert into ',@NS_case_number,'emrlink_order_sync_error_tracking
select src.emrlink_order_sync_error_tracking_id as src_id, NULL as dst_id, ''N'' as corporate
from ',@src_db_location,'.dbo.emrlink_order_sync_error_tracking src with (nolock)
where src.client_id in (select src_id from ',@NS_case_number,'clients)
and src.phys_order_id in (select src_id from ',@NS_case_number,'pho_phys_order)
')

print @SQL      
EXEC(@SQL)
set @Table_Count = @@rowcount
set @message = concat( OBJECT_NAME(@@PROCID), ' - (',@NS_case_number,'emrlink_order_sync_error_tracking) - ', @@ROWCOUNT, ' affected rows')
print @message

EXEC  [operational].[sproc_facacq_Key_Reservation]
      @current_db
    , 'emrlink_order_sync_error_tracking'
    , 'emrlink_order_sync_error_tracking_id'
    , @Table_Count
    , @Table_NextKey OUTPUT


set @sql = concat('
UPDATE dbo.',@NS_case_number,'emrlink_order_sync_error_tracking SET dst_id = ',@Table_NextKey,' + ([row_id] - 1)
		')

exec(@sql)
set @message = concat( OBJECT_NAME(@@PROCID), ' - ', @@ROWCOUNT, ' affected rows.')
print @sql
print @message


set @sql = concat('
set identity_insert emrlink_order_sync_error_tracking on

insert into emrlink_order_sync_error_tracking (
emrlink_order_sync_error_tracking_id,
client_id,
emrlink_order_id,
phys_order_id,
order_desc,
error_message,
last_sync_date
)
select map.dst_id,
map2.dst_id,
emrlink_order_id,
map3.dst_id,
order_desc,
error_message,
last_sync_date
from ',@src_db_location,'.dbo.emrlink_order_sync_error_tracking src with (nolock)
join ',@NS_case_number,'emrlink_order_sync_error_tracking map on src.emrlink_order_sync_error_tracking_id = map.src_id
join ',@NS_case_number,'clients map2 on src.client_id = map2.src_id
join ',@NS_case_number,'pho_phys_order map3 on src.phys_order_id = map3.src_id

set identity_insert emrlink_order_sync_error_tracking off

'
)

print @SQL      
EXEC(@SQL)
set @message = concat( OBJECT_NAME(@@PROCID), ' - (emrlink_order_sync_error_tracking) - ', @@ROWCOUNT, ' affected rows')
print @message



END TRY
BEGIN CATCH
		set @message = concat( OBJECT_NAME(@@PROCID), ' - ', ERROR_MESSAGE(), ' @sql: ', @sql)
		print @message
		raiserror(@message, 16, 1)
END CATCH

GO



GO

print 'K_Operational_Branch/5_StoredProcedures/sproc_facacq_post_IfCopyEMRLink_03_emrlink_order_sync_error_tracking.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_facacq_post_IfCopyEMRLink_03_emrlink_order_sync_error_tracking.sql',getdate(),'4.4.7_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_facacq_post_IfCopyEMRLink_04_pho_lab_integrated_order_detail.sql',getdate(),'4.4.7_06_CLIENT_K_Operational_Branch_US.sql')

GO

SET ANSI_NULLS ON
GO
SET ARITHABORT ON
GO
SET ANSI_WARNINGS ON
GO
SET ANSI_PADDING ON
GO
SET CONCAT_NULL_YIELDS_NULL ON
GO
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_NULL_DFLT_ON ON
GO

SET QUOTED_IDENTIFIER ON
GO



if exists (select * from dbo.sysobjects where id = object_id(N'[operational].[sproc_facacq_post_IfCopyEMRLink_04_pho_lab_integrated_order_detail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [operational].sproc_facacq_post_IfCopyEMRLink_04_pho_lab_integrated_order_detail
go

CREATE PROCEDURE [operational].sproc_facacq_post_IfCopyEMRLink_04_pho_lab_integrated_order_detail
		@src_db_location varchar(2000), --[server_name].[db_name]
		@NS_case_number varchar(200)

/********************************************************************************

Purpose: Post insert for emrlink related tables when needed

e.g.
exec  [operational].[sproc_facacq_post_IfCopyEMRLink_04_pho_lab_integrated_order_detail]  '[src_server].src_db','EICase1234567'

**********************************************************************************/ 
AS
declare @sql varchar(max)
declare @message varchar(4000)
declare @Table_Count bigint
declare @Table_NextKey BIGINT
declare @current_db varchar(200) = db_name()
SET NOCOUNT ON;
	
BEGIN TRY

------------------------------------


set @sql = concat('

if exists(select 1 from information_schema.TABLES where table_name = ''',@NS_case_number,'pho_lab_integrated_order_detail'')

begin
	drop table ',@NS_case_number,'pho_lab_integrated_order_detail
end

CREATE TABLE [dbo].[',@NS_case_number,'pho_lab_integrated_order_detail](
[row_id] [int] IDENTITY(1,1) NOT NULL,
[src_id] [bigint] NULL,
[dst_id] [bigint] NULL,
[corporate] [char](1) NULL DEFAULT (''N'')
) ON [PRIMARY]

insert into ',@NS_case_number,'pho_lab_integrated_order_detail
select src.lab_order_detail_id as src_id, NULL as dst_id, ''N'' as corporate
from ',@src_db_location,'.dbo.pho_lab_integrated_order_detail src with (nolock)
where src.phys_order_id in (select src_id from ',@NS_case_number,'pho_phys_order)
and src.lab_report_id in (select src_id from ',@NS_case_number,'result_lab_report)
')

print @SQL      
EXEC(@SQL)
set @Table_Count = @@rowcount
set @message = concat( OBJECT_NAME(@@PROCID), ' - (',@NS_case_number,'pho_lab_integrated_order_detail) - ', @@ROWCOUNT, ' affected rows')
print @message

EXEC  [operational].[sproc_facacq_Key_Reservation]
      @current_db
    , 'pho_lab_integrated_order_detail'
    , 'lab_order_detail_id'
    , @Table_Count
    , @Table_NextKey OUTPUT


set @sql = concat('
UPDATE dbo.',@NS_case_number,'pho_lab_integrated_order_detail SET dst_id = ',@Table_NextKey,' + ([row_id] - 1)
		')

exec(@sql)
set @message = concat( OBJECT_NAME(@@PROCID), ' - ', @@ROWCOUNT, ' affected rows.')
print @sql
print @message


set @sql = concat('
set identity_insert pho_lab_integrated_order_detail on

insert into pho_lab_integrated_order_detail (
lab_order_detail_id,
phys_order_id,
lab_report_id,
urgency_type_id,
report_status_id,
created_by,
created_date,
revision_by,
revision_date,
vendor_phys_order_id
)
select 
map.dst_id,
map2.dst_id,
map3.dst_id,
urgency_type_id,
report_status_id,
created_by,
created_date,
revision_by,
revision_date,
vendor_phys_order_id
from ',@src_db_location,'.dbo.pho_lab_integrated_order_detail src with (nolock)
join ',@NS_case_number,'pho_lab_integrated_order_detail map on src.lab_order_detail_id = map.src_id
join ',@NS_case_number,'pho_phys_order map2 on src.phys_order_id = map2.src_id
join ',@NS_case_number,'result_lab_report map3 on src.lab_report_id = map3.src_id

set identity_insert pho_lab_integrated_order_detail off

'
)

print @SQL      
EXEC(@SQL)
set @message = concat( OBJECT_NAME(@@PROCID), ' - (pho_lab_integrated_order_detail) - ', @@ROWCOUNT, ' affected rows')
print @message



END TRY
BEGIN CATCH
		set @message = concat( OBJECT_NAME(@@PROCID), ' - ', ERROR_MESSAGE(), ' @sql: ', @sql)
		print @message
		raiserror(@message, 16, 1)
END CATCH

GO



GO

print 'K_Operational_Branch/5_StoredProcedures/sproc_facacq_post_IfCopyEMRLink_04_pho_lab_integrated_order_detail.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_facacq_post_IfCopyEMRLink_04_pho_lab_integrated_order_detail.sql',getdate(),'4.4.7_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_facacq_post_IfCopyEMRLink_05_pho_rad_integrated_order_detail.sql',getdate(),'4.4.7_06_CLIENT_K_Operational_Branch_US.sql')

GO

SET ANSI_NULLS ON
GO
SET ARITHABORT ON
GO
SET ANSI_WARNINGS ON
GO
SET ANSI_PADDING ON
GO
SET CONCAT_NULL_YIELDS_NULL ON
GO
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_NULL_DFLT_ON ON
GO

SET QUOTED_IDENTIFIER ON
GO



if exists (select * from dbo.sysobjects where id = object_id(N'[operational].[sproc_facacq_post_IfCopyEMRLink_05_pho_rad_integrated_order_detail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [operational].sproc_facacq_post_IfCopyEMRLink_05_pho_rad_integrated_order_detail
go

CREATE PROCEDURE [operational].sproc_facacq_post_IfCopyEMRLink_05_pho_rad_integrated_order_detail
		@src_db_location varchar(2000), --[server_name].[db_name]
		@NS_case_number varchar(200)

/********************************************************************************

Purpose: Post insert for emrlink related tables when needed

e.g.
exec  [operational].[sproc_facacq_post_IfCopyEMRLink_05_pho_rad_integrated_order_detail]  '[src_server].src_db','EICase1234567'

**********************************************************************************/ 
AS
declare @sql varchar(max)
declare @message varchar(4000)
declare @Table_Count bigint
declare @Table_NextKey BIGINT
declare @current_db varchar(200) = db_name()
SET NOCOUNT ON;
	
BEGIN TRY

------------------------------------


set @sql = concat('

if exists(select 1 from information_schema.TABLES where table_name = ''',@NS_case_number,'pho_rad_integrated_order_detail'')

begin
	drop table ',@NS_case_number,'pho_rad_integrated_order_detail
end

CREATE TABLE [dbo].[',@NS_case_number,'pho_rad_integrated_order_detail](
[row_id] [int] IDENTITY(1,1) NOT NULL,
[src_id] [bigint] NULL,
[dst_id] [bigint] NULL,
[corporate] [char](1) NULL DEFAULT (''N'')
) ON [PRIMARY]

insert into ',@NS_case_number,'pho_rad_integrated_order_detail
select src.rad_order_detail_id as src_id, NULL as dst_id, ''N'' as corporate
from ',@src_db_location,'.dbo.pho_rad_integrated_order_detail src with (nolock)
where src.phys_order_id in (select src_id from ',@NS_case_number,'pho_phys_order)
and src.radiology_report_id in (select src_id from ',@NS_case_number,'result_radiology_report)
')

print @SQL      
EXEC(@SQL)
set @Table_Count = @@rowcount
set @message = concat( OBJECT_NAME(@@PROCID), ' - (',@NS_case_number,'pho_rad_integrated_order_detail) - ', @@ROWCOUNT, ' affected rows')
print @message

EXEC  [operational].[sproc_facacq_Key_Reservation]
      @current_db
    , 'pho_rad_integrated_order_detail'
    , 'rad_order_detail_id'
    , @Table_Count
    , @Table_NextKey OUTPUT


set @sql = concat('
UPDATE dbo.',@NS_case_number,'pho_rad_integrated_order_detail SET dst_id = ',@Table_NextKey,' + ([row_id] - 1)
		')

exec(@sql)
set @message = concat( OBJECT_NAME(@@PROCID), ' - ', @@ROWCOUNT, ' affected rows.')
print @sql
print @message


set @sql = concat('
set identity_insert pho_rad_integrated_order_detail on

insert into pho_rad_integrated_order_detail (
rad_order_detail_id,
phys_order_id,
radiology_report_id,
urgency_type_id,
report_status_id,
created_by,
created_date,
revision_by,
revision_date,
vendor_phys_order_id
)
select 
map.dst_id,
map2.dst_id,
map3.dst_id,
urgency_type_id,
report_status_id,
created_by,
created_date,
revision_by,
revision_date,
vendor_phys_order_id
from ',@src_db_location,'.dbo.pho_rad_integrated_order_detail src with (nolock)
join ',@NS_case_number,'pho_rad_integrated_order_detail map on src.rad_order_detail_id = map.src_id
join ',@NS_case_number,'pho_phys_order map2 on src.phys_order_id = map2.src_id
join ',@NS_case_number,'result_radiology_report map3 on src.radiology_report_id = map3.src_id

set identity_insert pho_rad_integrated_order_detail off

'
)

print @SQL      
EXEC(@SQL)
set @message = concat( OBJECT_NAME(@@PROCID), ' - (pho_rad_integrated_order_detail) - ', @@ROWCOUNT, ' affected rows')
print @message



END TRY
BEGIN CATCH
		set @message = concat( OBJECT_NAME(@@PROCID), ' - ', ERROR_MESSAGE(), ' @sql: ', @sql)
		print @message
		raiserror(@message, 16, 1)
END CATCH

GO



GO

print 'K_Operational_Branch/5_StoredProcedures/sproc_facacq_post_IfCopyEMRLink_05_pho_rad_integrated_order_detail.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_facacq_post_IfCopyEMRLink_05_pho_rad_integrated_order_detail.sql',getdate(),'4.4.7_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_facacq_post_ifSecUserPositionUpdate.sql',getdate(),'4.4.7_06_CLIENT_K_Operational_Branch_US.sql')

GO

SET ANSI_NULLS ON
GO
SET ARITHABORT ON
GO
SET ANSI_WARNINGS ON
GO
SET ANSI_PADDING ON
GO
SET CONCAT_NULL_YIELDS_NULL ON
GO
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_NULL_DFLT_ON ON
GO

SET QUOTED_IDENTIFIER ON
GO



if exists (select * from dbo.sysobjects where id = object_id(N'[operational].[sproc_facacq_post_ifSecUserPositionUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [operational].[sproc_facacq_post_ifSecUserPositionUpdate]
go

CREATE PROCEDURE [operational].[sproc_facacq_post_ifSecUserPositionUpdate]
@source_db varchar(200),
@NSCaseNumber varchar(50)


/********************************************************************************

Purpose: Fix staff link with sec user as post

e.g.
exec  [operational].[sproc_facacq_post_ifSecUserPositionUpdate] '[src_server].src_db','EIcase0000022'

**********************************************************************************/ 
AS
declare @sql varchar(max)
declare @message varchar(4000)
SET NOCOUNT ON;


BEGIN TRY


set @sql = concat('

update dst
set dst.staff_id = cmap.dst_id
from dbo.sec_user dst
join dbo.',@NSCaseNumber,'sec_user umap on dst.userid = umap.dst_id
join ',@source_db,'.dbo.sec_user src on umap.src_id = src.userid
join dbo.',@NSCaseNumber,'contact cmap on src.staff_id = cmap.src_id
where dst.created_by = ',@NSCaseNumber,'

		')


exec(@sql)
set @message = concat( OBJECT_NAME(@@PROCID), ' - ', @@ROWCOUNT, ' affected rows.')
print @sql
print @message



END TRY
BEGIN CATCH
		set @message = concat( OBJECT_NAME(@@PROCID), ' - ', ERROR_MESSAGE(), ' - SQL: ', @sql)
		print @message
		raiserror(@message, 16, 1)
END CATCH

GO


GO

print 'K_Operational_Branch/5_StoredProcedures/sproc_facacq_post_ifSecUserPositionUpdate.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_facacq_post_ifSecUserPositionUpdate.sql',getdate(),'4.4.7_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_facacq_pre_mappingUploadCategory.sql',getdate(),'4.4.7_06_CLIENT_K_Operational_Branch_US.sql')

GO

SET ANSI_NULLS ON
GO
SET ARITHABORT ON
GO
SET ANSI_WARNINGS ON
GO
SET ANSI_PADDING ON
GO
SET CONCAT_NULL_YIELDS_NULL ON
GO
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_NULL_DFLT_ON ON
GO

SET QUOTED_IDENTIFIER ON
GO



if exists (select * from dbo.sysobjects where id = object_id(N'[operational].[sproc_facacq_pre_mappingUploadCategory]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [operational].[sproc_facacq_pre_mappingUploadCategory]
go

CREATE PROCEDURE [operational].[sproc_facacq_pre_mappingUploadCategory]
@mapping_table_name varchar(500),
@dest_database varchar(200),
@if_exclude_condition varchar(1) = NULL

/********************************************************************************

Purpose: Apply mapping templates for upload categories

e.g.
exec  [operational].[sproc_facacq_pre_mappingUploadCategory] '[bkp_server].bkp_db.dbo.bkp_table', '[dst_server].dst_database','N'

**********************************************************************************/ 
AS
declare @sql varchar(max)
declare @message varchar(4000)
SET NOCOUNT ON;
	
BEGIN TRY

IF @if_exclude_condition = 'Y'
	BEGIN 
	set @sql = concat('update src
	set 
		src.cat_desc = dst.cat_desc,
		src.admin_flag = dst.admin_flag,
		src.clinical_flag = dst.clinical_flag,
		src.irm_flag = dst.irm_flag,
		src.cat_code = dst.cat_code
	from upload_categories src
	inner join ',@mapping_table_name,' um with (nolock)
	on src.cat_id = um.srcCatID
	inner join ',@dest_database,'.dbo.upload_categories dst with (nolock)
	on dst.cat_id = um.map_dst_catid
	and src.std_cat_id is NULL
		' )
	END
ELSE 
	BEGIN
	set @sql = concat('update src
	set 
		src.cat_desc = dst.cat_desc,
		src.admin_flag = dst.admin_flag,
		src.clinical_flag = dst.clinical_flag,
		src.irm_flag = dst.irm_flag,
		src.cat_code = dst.cat_code
	from upload_categories src
	inner join ',@mapping_table_name,' um with (nolock)
	on src.cat_id = um.srcCatID
	inner join ',@dest_database,'.dbo.upload_categories dst with (nolock)
	on dst.cat_id = um.map_dst_catid
	and (src.admin_flag = dst.admin_flag or dst.admin_flag=''N'')
	and (src.clinical_flag = dst.clinical_flag or dst.clinical_flag=''N'')
	and (src.irm_flag = dst.irm_flag or dst.irm_flag=''N'')
	and src.std_cat_id is NULL
		' )
	END

exec(@sql)
set @message = concat( OBJECT_NAME(@@PROCID), ' done with ', @mapping_table_name, ', ',@dest_database,', ',@if_exclude_condition,' - ', @@ROWCOUNT, ' affected rows.')
--print @sql
print @message


END TRY
BEGIN CATCH
		set @message = concat( OBJECT_NAME(@@PROCID), ' - ', ERROR_MESSAGE(), ' - SQL: ', @sql)
		print @message
		raiserror(@message, 16, 1)
END CATCH

GO



GO

print 'K_Operational_Branch/5_StoredProcedures/sproc_facacq_pre_mappingUploadCategory.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('K_Operational_Branch/5_StoredProcedures/sproc_facacq_pre_mappingUploadCategory.sql',getdate(),'4.4.7_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.7_06_CLIENT_K_Operational_Branch_US.sql')

GO
SET ANSI_NULLS ON
GO
SET ARITHABORT ON
GO
SET ANSI_WARNINGS ON
GO
SET ANSI_PADDING ON
GO
SET CONCAT_NULL_YIELDS_NULL ON
GO
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_NULL_DFLT_ON ON
GO

SET QUOTED_IDENTIFIER ON
GO


insert into pcc_db_version (db_version_code, db_upload_by)
values ('4.4.7_K', 'upload_history')


GO

print '..\Update db version.sql --****SCRIPT DONE****'

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.7_06_CLIENT_K_Operational_Branch_US.sql')

GO

insert into upload_tracking (script,timestamp,upload) values ('UPLOAD END',getdate(),'4.4.7_06_CLIENT_K_Operational_Branch_US.sql')