SET NOCOUNT ON
GO

SET DEADLOCK_PRIORITY HIGH
GO


insert into upload_tracking (script, timestamp, upload) values ('UPLOAD_START',getdate(),'4.4.8_06_CLIENT_M_Metadata_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('M_Metadata_Branch/03_Functions/fn_standardize_metadata_for_code.sql',getdate(),'4.4.8_06_CLIENT_M_Metadata_Branch_US.sql')

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
-- Comments:             CORE-96810 - Function to standardize metadata code
--                             for triggers, stored procedures, views and functions,
--                            This funciton takes the body of the object defined above
--                            and produces a standard version.
--                             It ignores the following:
--                             case (upper or lower)
--                             use of "[" and "]" will be ignored.
--                             spaces
--                             usage of "create or alter" vs "create"
--                             blank lines, tabs or carraiage returns
--                       Note: the replace must be applied in the proper order.
--
-- Created On: Nov 11, 2021
-- =================================================================================
--
-- ------------------------------------------------------
-- ------------------------------------------------------


drop function if exists metadata.fn_standardize_metadata_code;
go

CREATE FUNCTION metadata.fn_standardize_metadata_code(@text   varchar(max))
RETURNS varchar(max)
AS
BEGIN
    RETURN replace (
             replace(
               replace(
                 replace(
                   replace(
                     replace(
                       replace(lower(@text), ' ', ''),
                       '[', ''),
	                 ']', ''),
                   char(10), ''),    -- newline
                 char(9), ''),       -- tab
               char(13), ''),        -- carriage return
             'createoralter','create'); -- This must be the last replace
                                        -- so as to avoid the case where
					-- newlines, spaces, tabs or square brackets 
					-- are somehow interoduced between 
					-- create and the name of the object.

END

GO

GRANT execute on metadata.fn_standardize_metadata_code to public;
go

	      
	          



GO

print 'M_Metadata_Branch/03_Functions/fn_standardize_metadata_for_code.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('M_Metadata_Branch/03_Functions/fn_standardize_metadata_for_code.sql',getdate(),'4.4.8_06_CLIENT_M_Metadata_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('M_Metadata_Branch/03_Functions/metadata_for_routine.sql',getdate(),'4.4.8_06_CLIENT_M_Metadata_Branch_US.sql')

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
-- Re-Runable:           YES
--
-- Special Instruction:  
-- Comments: 			 CORE-81867  Function metadata_for_metadata_for_routine
--                                   This gets the detailed metadata for routines 
--									 (Stored procedures and functions)
--
--           Nov 11, 2021:           CORE-97107:
--                                   Changed the way the hash value
--                                   is calculated to account for differences caused by
--                                   spaces, tabs, newlines, carriage returs,
--                                   "create or alter" instead of "Create"
--                                   and '[' and ']'
--
-- =================================================================================
--

if exists (
			Select 1
			from   sys.objects
			where  object_id = object_id('metadata.metadata_for_routine')
			  and  type in (N'FN', N'IF', N'TF', N'FS', N'FT')
		   )
begin
		drop function metadata.metadata_for_routine;
end
go

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE function metadata.metadata_for_routine
(
	@obj_name    varchar(200) = ''
)
RETURNS TABLE AS

RETURN

	select  
			routine_name  as obj_name,
			'routine' as obj_type,
			routine_type as parent_object_name,
  			routine_schema + '.' + routine_name + ',' +
			CONVERT(varchar(max), 
					HASHBYTES('SHA2_256',
				              metadata.fn_standardize_metadata_code(routine_definition)
				             ), 
				    2) as data
	from	information_schema.routines 
	where   routine_body <> 'EXTERNAL'
	  and    (@obj_name = routine_name or @obj_name = '')

GO

grant select on metadata.metadata_for_routine to public
go




GO

print 'M_Metadata_Branch/03_Functions/metadata_for_routine.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('M_Metadata_Branch/03_Functions/metadata_for_routine.sql',getdate(),'4.4.8_06_CLIENT_M_Metadata_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('M_Metadata_Branch/03_Functions/metadata_for_trigger.sql',getdate(),'4.4.8_06_CLIENT_M_Metadata_Branch_US.sql')

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
-- Re-Runable:           YES
--
-- Special Instruction:  
-- Comments: 			 CORE-81867  Function metadata_for_metadata_for_trigger
--                                   This gets the detailed metadata for triggers
--           Nov 11, 2021:           CORE-97107:
--                                   Changed the way the hash value
--                                   is calculated to account for differences caused by
--                                   spaces, tabs, newlines, carriage returs,
--                                   "create or alter" instead of "Create"
--                                   and '[' and ']'
--
-- =================================================================================
--

if exists (
			Select 1
			from   sys.objects
			where  object_id = object_id('metadata.metadata_for_trigger')
			  and  type in (N'FN', N'IF', N'TF', N'FS', N'FT')
		   )
begin
		drop function metadata.metadata_for_trigger;
end
go


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE function [metadata].[metadata_for_trigger]
(
	@obj_name    varchar(200) = ''
)
RETURNS TABLE AS

RETURN	
    select 
            trg.name  as obj_name,
            'trigger' as obj_type,
            object_name(trg.parent_id) as parent_object_name,
            CONVERT(varchar(max), 
                    hashbytes('SHA2_256', 
                              metadata.fn_standardize_metadata_code(mod.definition)
                             ),
  					2)	as data
    from    sys.triggers trg
    join    sys.sql_modules mod
      on    mod.object_id = trg.object_id
    where   trg.parent_id <> 0 
      and   metadata.is_temporary_object(object_name(trg.parent_id)) = 0
      and   (@obj_name = trg.name or @obj_name = '')
;


GO



grant select on metadata.metadata_for_trigger to public
go

-- -----------------------------------------------------------





GO

print 'M_Metadata_Branch/03_Functions/metadata_for_trigger.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('M_Metadata_Branch/03_Functions/metadata_for_trigger.sql',getdate(),'4.4.8_06_CLIENT_M_Metadata_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('M_Metadata_Branch/03_Functions/metadata_for_view.sql',getdate(),'4.4.8_06_CLIENT_M_Metadata_Branch_US.sql')

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
--
-- Special Instruction:  
-- Comments: 			 CORE-81867  Function metadata_for_metadata_for_view
--                                   This gets the detailed metadata for routines 
--									 (Stored procedures and functions)
--           Nov 11, 2021:           CORE-97107:
--                                   Changed the way the hash value
--                                   is calculated to account for differences caused by
--                                   spaces, tabs, newlines, carriage returs,
--                                   "create or alter" instead of "Create"
--                                   and '[' and ']'
--
-- =================================================================================
--

if exists (
			Select 1
			from   sys.objects
			where  object_id = object_id('metadata.metadata_for_view')
			  and  type in (N'FN', N'IF', N'TF', N'FS', N'FT')
		   )
begin
		drop function metadata.metadata_for_view;
end
go

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE function [metadata].[metadata_for_view]
(
	@obj_name    varchar(200) = ''
)
RETURNS TABLE AS

RETURN
	select  
			table_name  as obj_name,
			'view' as obj_type,
			'view' as parent_object_name,
  			table_schema + '.' + table_name + ',' +
			CONVERT(varchar(max), 
			        HASHBYTES('SHA2_256', 
			                  metadata.fn_standardize_metadata_code(view_definition)
			                 ), 
			        2) as data
	from	information_schema.views 
	where   (@obj_name = table_name or @obj_name = '')


GO

grant select on metadata.metadata_for_view to public
go






GO

print 'M_Metadata_Branch/03_Functions/metadata_for_view.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('M_Metadata_Branch/03_Functions/metadata_for_view.sql',getdate(),'4.4.8_06_CLIENT_M_Metadata_Branch_US.sql')

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.8_06_CLIENT_M_Metadata_Branch_US.sql')

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
values ('4.4.8_M', 'upload_history')


GO

print '..\Update db version.sql --****SCRIPT DONE****'

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.8_06_CLIENT_M_Metadata_Branch_US.sql')

GO

insert into upload_tracking (script,timestamp,upload) values ('UPLOAD END',getdate(),'4.4.8_06_CLIENT_M_Metadata_Branch_US.sql')