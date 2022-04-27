-- connect to con src
SELECT @@SERVERNAME, @@VERSION
USE [master]
DROP DATABASE [pcc_staging_db59112];




-- new from template
RESTORE DATABASE [pcc_staging_db59112] 
FROM  URL = 'https://pccstguspassvdatabase.blob.core.windows.net/databasebackups/template/FULL_us_template_pccsingle_tmpltOH.bak'


--truncate table  [pcc_staging_db59112].[dbo].MergeLog
use [pcc_staging_db59112]
delete  
--select * 
from [pcc_staging_db59112].[dbo].MergeLog
--order by msgTime desc
--  50sec

/*

*/






ALTER TABLE dbo.pho_schedule_details
DISABLE CHANGE_TRACKING;  

ALTER TABLE pho_schedule_details 
DROP CONSTRAINT  pho_schedule_details__phoScheduleDetailId_PK;

DROP INDEX   IF  EXISTS pho_schedule_details__scheduleDate_CL ON  pho_schedule_details;

ALTER TABLE pho_schedule_details ADD CONSTRAINT pho_schedule_details__phoScheduleDetailId_PK
PRIMARY KEY CLUSTERED (pho_schedule_detail_id);



ALTER TABLE dbo.pho_schedule_details
ENABLE CHANGE_TRACKING;  

--E7c: Custom UDAs, E7d: MMQ, E7e: MMA, E16: Alert, E17: Risk Management, E18: Trust, E19a: IRM, E19b: IRM