

SET NOCOUNT ON
GO

SET DEADLOCK_PRIORITY HIGH
GO


insert into upload_tracking (script, timestamp, upload) values ('UPLOAD_START',getdate(),'4.4.7_06_CLIENT_Z_Branch_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('Z_Branch/99_DML/final_step_exec_generate_metadata_diffs.sql',getdate(),'4.4.7_06_CLIENT_Z_Branch_US.sql')

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
-- Script Type:          DML
-- Target DB Type:       CLIENTDB
-- Target ENVIRONMENT:   US and CDN
--
--
-- Re-Runable:           YES
--
-- Special Instruction:  
-- Comments: 			 CORE-90134  Call the procedure to geenerate the nmetadata 
--									 diffs for the current release.
--                                   
--
-- =================================================================================
--

/*******************************************************************

   PLEASE NOTE: This file is expected to be included with every 
                Release. This folder is expected to be "pinned"
		so that, even if there are no changes to the file,
		it will be included in the Master Scripts.

	This file should ideally be run at the end of ether the 
	Client Upload Process,
	   OR
	Client PostUpload Process.

*******************************************************************
*/
exec metadata.generate_metadata_diffs

go

-- ------------------------------------------------------------------




GO

print 'Z_Branch/99_DML/final_step_exec_generate_metadata_diffs.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('Z_Branch/99_DML/final_step_exec_generate_metadata_diffs.sql',getdate(),'4.4.7_06_CLIENT_Z_Branch_US.sql')

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.7_06_CLIENT_Z_Branch_US.sql')

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
values ('4.4.7_Z', 'upload_history')


GO

print '..\Update db version.sql --****SCRIPT DONE****'

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.7_06_CLIENT_Z_Branch_US.sql')

GO

insert into upload_tracking (script,timestamp,upload) values ('UPLOAD END',getdate(),'4.4.7_06_CLIENT_Z_Branch_US.sql')