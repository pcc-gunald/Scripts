

SET NOCOUNT ON
GO

SET DEADLOCK_PRIORITY HIGH
GO


insert into upload_tracking (script, timestamp, upload) values ('UPLOAD_START',getdate(),'4.4.7_06_CLIENT_M_Metadata_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('M_Metadata_Branch/05_StoredProcedures/populate_all_metadata_info.sql',getdate(),'4.4.7_06_CLIENT_M_Metadata_Branch_US.sql')

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



-- =================================================================================
-- Reviewed By:          
-- Author:               Ravi Venkataraman
--
-- Script Type:          DDL
-- Target DB Type:       CLIENTDB
-- Target ENVIRONMENT:   US and CDN
--
--
-- Re-Runable:           YES
--
-- Special Instruction:  
-- Comments: 			 CORE-81867  Function to populate all metadata info.
--                                   
--
-- =================================================================================
--
-- ------------------------------------------------------
-- ------------------------------------------------------

if exists (
			Select 1
			from   sys.objects
			where  object_id = object_id('metadata.populate_all_metadata_info')
		   )
begin
	drop procedure metadata.populate_all_metadata_info;
end
GO




CREATE OR ALTER PROCEDURE [metadata].[populate_all_metadata_info]
AS
BEGIN

	CREATE  TABLE #mdata(
		obj_name	varchar(200),
		obj_type	varchar(50),
		parent_object_name   varchar(200),
		data		varchar(max)
	);

	create clustered index mdata_ix on #mdata(obj_name, obj_type);

	insert into #mdata (obj_name, obj_type, parent_object_name, data)
		select obj_name, obj_type, parent_object_name, data 
		from metadata.metadata_for_default_constraint(default)
		--
		union all
		select obj_name, obj_type, parent_object_name, data 
		from metadata.metadata_for_check_constraint(default)
		--
		union all
		select obj_name, obj_type, parent_object_name, data
		from metadata.metadata_for_fk(default)
		--
		union all
		select obj_name, obj_type, parent_object_name, data 
		from metadata.metadata_for_index(default)
		--
		union all
		select obj_name, obj_type, parent_object_name, data 
		from metadata.metadata_for_routine(default)
		--
		union all 
		select obj_name, obj_type, parent_object_name, data 
		from metadata.metadata_for_table(default)
		--
		union all
		Select obj_name, obj_type, parent_object_name, data 
		from metadata.metadata_for_trigger(default)
		--
		union all 
		select obj_name, obj_type, parent_object_name, data 
		from metadata.metadata_for_udt(default)
		--
		union all
		Select obj_name, obj_type, parent_object_name, data 
		from metadata.metadata_for_view(default)
;

--      (Ravi V.: Oct 1, 2021: This line is not needed any more
--                             as the table needs to track historical information.
--	delete from metadata.metadata_change_tracking;

	insert into metadata.metadata_change_tracking (
		obj_name, obj_type, parent_obj_name, 
		aggr_data, hash_value, revision_date, revision_by)
	
		Select 	obj_name, obj_type, parent_object_name, aggr_data,
				hashbytes('SHA2_256', aggr_data) as hash_value,
				getdate(), system_user
		From (
				select	distinct obj_name, obj_type, parent_object_name,
						STUFF ((
								Select 	'|| ' + lower(data) 
								from 	#mdata md1
								where 	md1.obj_name = md.obj_name
								  and 	md1.obj_type = md.obj_type
								  and   md1.parent_object_name = md.parent_object_name
								order by data
								FOR XML PATH ('')
								), 1, 1, '') as aggr_data
				from	#mdata md
			) mdata	

END


GO


grant execute on metadata.populate_all_metadata_info to public
go


GO

print 'M_Metadata_Branch/05_StoredProcedures/populate_all_metadata_info.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('M_Metadata_Branch/05_StoredProcedures/populate_all_metadata_info.sql',getdate(),'4.4.7_06_CLIENT_M_Metadata_Branch_US.sql')

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.7_06_CLIENT_M_Metadata_Branch_US.sql')

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
values ('4.4.7_M', 'upload_history')


GO

print '..\Update db version.sql --****SCRIPT DONE****'

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.7_06_CLIENT_M_Metadata_Branch_US.sql')

GO

insert into upload_tracking (script,timestamp,upload) values ('UPLOAD END',getdate(),'4.4.7_06_CLIENT_M_Metadata_Branch_US.sql')