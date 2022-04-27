use pcc_staging_db010798


--WARNING! ERRORS ENCOUNTERED DURING SQL PARSING!
Job '0xD4B92F4960F4BF40913506062709EAD7' : Step 8
	,'Clean EI Tables' : Began Executing 2040 - 02 - 02 12 : 12 : 56 Msg 547
	,Sev 16
	,STATE 1
	,Line 1 : The

DELETE statement conflicted
WITH the REFERENCE CONSTRAINT "rpt_recent_visited_report__userId_FK".The conflict occurred IN 
DATABASE "pcc_staging_db010798"
	,TABLE "reporting.rpt_recent_visited_report"
	,COLUMN 'user_id'.[SQLSTATE 23000] Msg 3621
	,Sev 16
	,STATE 1
	,Line 1 : The statement has been terminated.[SQLSTATE 01000]


	Select * from reporting.rpt_recent_visited_report

	Delete from reporting.rpt_recent_visited_report

	Select * from reporting.rpt_recent_visited_report

	
	Select * from sec_user where userid=593

	Delete from sec_user   where userid=593
delete from reporting.rpt_recent_visited_report

Delete from reporting.rpt_recent_visited_report

add column library_uuid in cp_std_library pcc_staging_db010798

[library_uuid] (varchar(36),null)
 

 Select * from clients