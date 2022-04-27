SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_SendEmail_DynamicGeneration]
AS
BEGIN

	DECLARE @pmo_number VARCHAR(MAX) = 'PMO-59277'

	DECLARE @src_org_code VARCHAR(MAX) = 'SAVA'
	DECLARE @dst_org_code VARCHAR(MAX) = 'PGHC'

	DECLARE @src_prod VARCHAR(MAX) = '[sqluspaw29cli01.pccprod.local].us_sava_multi'
	DECLARE @dst_prod VARCHAR(MAX) = '[pccsql-use2-prod-w30-cli0004.cbafa2b80e84.database.windows.net].us_pghc_multi'

	DECLARE @src_test_org_code VARCHAR(MAX) = 'usei3sava1'
	DECLARE @dst_test_org_code VARCHAR(MAX) = 'usei1214'

	DECLARE @golive_date VARCHAR(MAX) = 'March 01, 2022'
	DECLARE @golive_day VARCHAR(MAX) = 'Tuesday'
	DECLARE @golive_time VARCHAR(MAX) = '12pm to 5am'
	DECLARE @offline_minutes VARCHAR(MAX) = '15'
	DECLARE @facility_names VARCHAR(MAX) = 'Pasadena Post Acute '

	DECLARE @all_SRC_facID VARCHAR(MAX) = '183'
	DECLARE @all_DST_facID VARCHAR(MAX) = '173'
	DECLARE @case_number VARCHAR(MAX) = '1991233'

	DECLARE @tst VARCHAR(MAX) = '1264'

	------------------------------------------------------ DO NOT CHANGE ANYTHING BELOW THIS LINE -----------------------------------------
	
	DECLARE @bodyMsg NVARCHAR(max), @subject NVARCHAR(max), @tableHTML NVARCHAR(max), @TableFac NVARCHAR(MAX) = '', @FinalTable NVARCHAR(MAX) = ''
	DECLARE @recepients AS NVARCHAR(max) = 'ashwin.chaudhari@pointclickcare.com'
	DECLARE @email_text varchar(max) = ''

	SET @email_text = '
	
	<b>Email for</b>:<u>Test DB Release</u> </br>
	<b>Recepients:</b> <i>summary email </i> </br>
	<b>Subject:</b> <i>reply to summary email </i> </br></br>

	Hi All,</br></br>
 
	The test database is now ready for review.  Test org code:  <b>'+ @dst_test_org_code +'</br></br></b>
 
	<u>To access the test DB:</br></u>
	<b>Login: '+ @dst_test_org_code +'</b>.&ltsame login used in '+ @src_org_code +'/ '+ @dst_org_code +'></br>
	<b>Password</b>: &ltsame password used in '+ @src_org_code +'/ '+ @dst_org_code +'></br></br>
 
	Key notes: </br>
	&emsp; &emsp;  1.	Resident photos and online documents are not viewable in the test environment.</br>
	&emsp; &emsp;  2.	There are ___ users from '+ @src_org_code +' with a login name matching an existing user in '+ @dst_org_code +'.  These users have had the ‘'+ @src_org_code +'’ added to their login name as a suffix.  More details on these users can be found in the attached spreadsheet – <b> the password to open the spreadsheet will be provided in the next e-mail.</br> </b>
	&emsp; &emsp;<b> 3.	The security users have been imported to test DB and once approved they will be imported to production and then you can assign them the roles. </br> </b>
	&emsp; &emsp;  4.	All care plan libraries having same description in both databases have ‘'+ @src_org_code +'-’ added to their name as prefix, please let us know if there are any concerns.</br>
	&emsp; &emsp;  5.	All UDAs brought over from ' + @src_org_code + ' have ‘'+ @src_org_code +'-’ added to their name as prefix, please let us know if there are any concerns.</br>
	&emsp; &emsp;  6.	This test DB might be missing some financial configuration and financial mappings due to it not being completed. I will do a test DB refresh when it is completed. I will send an email before refreshing the test DB.</br>
	&emsp; &emsp;  7.	Residents imported in the test database are current residents only - as per the summary details.</br>
	&emsp; &emsp;  8.	These modules have not been copied</br>
		&emsp; &emsp;  &emsp; &emsp;  •	??</br>
		&emsp; &emsp;  &emsp; &emsp;  •	??</br>
		&emsp; &emsp;  &emsp; &emsp;  •	??</br>
	&emsp; &emsp;  9.	 Any changes made in the test database (including data entry and setup/configuration) will <u><b>not</b></u> be carried over to the '+ @dst_org_code +' database.</br></br>
 
	Please review the test DB.  If there are any issues logging in, or discrepancies found, please <b>reply all</b>.</br>
	----------------------------------------------------------------------------------------------------------------------------------------------------------</br></br>

	<b>Email for</b>:<u>Test DB Release – Internal Team </u> </br>
	<b>Recepients:</b> <i>above email </i> </br>
	<b>Subject:</b> <i> forward above email to internal team </i> </br></br>

	Hi All,</br></br>
 
	The test DBs for this project are: </br></br>
 
	'+ @src_test_org_code +' ('+ @src_org_code +'– source)</br>
	'+ @dst_test_org_code +' ('+ @dst_org_code +' – destination) (Released to Client)</br></br>
 
	The admin and clinical picklists are attached. </br>
	The golive is currently scheduled for <b>'+ @golive_day +', '+ @golive_date +', ' + @golive_time +'</b> so please try to return the templates by xxxxxxxx. <br/>
	Please <b>reply all</b> if there are any issues or concerns.</br>
	----------------------------------------------------------------------------------------------------------------------------------------------------------</br></br>

	<b>Email for</b>:<u>Security Users imported in ' + @dst_org_code + ' Production </u> </br>
	<b>Recepients:</b> <i>approval email </i> </br>
	<b>Subject:</b> <i>reply to security import approval email </i> </br></br>

	
	Hi All,</br></br>
 
	Security users have been imported to '+ @dst_org_code +' production. You can now assign them roles in '+ @dst_org_code +' production.</br>
	Please <b>DO NOT DELETE</b>  any users brought over prior to the go-live as this will cause issues during the data copy.</br>
	If required disable the users and delete them post data copy. </br></br>
	
	If you have any questions or concerns, please <b>reply all</b>.</br>
	----------------------------------------------------------------------------------------------------------------------------------------------------------</br></br>

	<b>Email for</b>:<u>DB Refresh on the Day of Go-Live - Offline </u> </br>
	<b>Recepients:</b> <i>latest/summary email </i> </br>
	<b>Subject:</b> <i>reply to latest/summary email </i> </br></br>

	
	Hi All,</br></br>
 
	I will refresh the test DB now in preparation for tonight’s go live, and <b>'+ @dst_test_org_code +'</b> will be offline for several hours.  </br>
	I will notify when the test DB is back online. please <b>reply all</b> if any questions or concerns.</br>
	----------------------------------------------------------------------------------------------------------------------------------------------------------</br></br>

	<b>Email for</b>:<u>DB Refresh on the Day of Go-Live – Back Online </u> </br>
	<b>Recepients:</b> <i>latest/summary email </i> </br>
	<b>Subject:</b> <i>reply to latest/summary email </i> </br></br>

	Hi All,</br></br>

	The refresh has been completed and the test database <b>'+ @dst_test_org_code +'</b> is back online for final review.</br></br>

	<u>To access the test DB:</br></u>
		<b>Login: '+ @dst_test_org_code +'</b>.&ltsame login used in '+ @src_org_code +'/ '+ @dst_org_code +'></br>
		<b>Password</b>: &ltsame password used in '+ @src_org_code +'/ '+ @dst_org_code +'></br></br>

	Please review the test database.  If there are any problems logging in or discrepancies found, please <b>reply all</b>.</br>
	----------------------------------------------------------------------------------------------------------------------------------------------------------</br></br>
	
	<b>************************************** Golive Run-book and Emails for Golive **************************************</br></br></b>
	
	--> Do Not Restore - email before few hours of Go-Live </br></br>

	<b>Email for</b>:<u>Go-Live Day Morning Team E-Mail </u> </br>
	<b>Recepients:</b> TSSupport@pointclickcare.com; TSAutoandQA@pointclickcare.com; TSImplementation@pointclickcare.com; TSFacAcqConfig@pointclickcare.com </br>
	<b>Subject:</b> Scheduled Data Copy Tonight - ' + @pmo_number + ' - ' + @golive_date + ' </br></br>
	
	Hi All,</br></br>

	Please do not restore any DBs on [vmuspassvtscon3.pccprod.local] from ' + @golive_time +' tonight due to scheduled data copy. </br>
	----------------------------------------------------------------------------------------------------------------------------------------------------------</br></br>

	--> Go-Live Maintenance Email </br></br>

	<b>Email for</b>:<u> Go-Live Maintenance Email (to be sent before 24 hours and 30 minutes)</u> </br>
	<b>Recepients:</b> TechServicesCustomerMaintenance@pointclickcare.com </br>
	<b>Subject:</b> Scheduled Data Copy Tonight - ' + @pmo_number + ' ,tst- ' + @tst + ' - ' + @golive_date + ' </br></br>

	Hi All,</br></br>

	<b>Maintenance Description</b>: Technical Services will be performing a Data Copy from '+ @src_org_code +' to '+ @dst_org_code +' as part of '+ @pmo_number +' ,tst- ' + @tst + '</br></br>

	<b>Maintenance window</b>: Please note that the destination org code '+ @dst_org_code +' will be offline approximately '+ @offline_minutes +' minutes between <b>' + @golive_time +' EST</b></br></br>

 		<b>&emsp; &emsp; &emsp; &emsp; Data Copy Time:</b>  '+ @golive_day +', '+ @golive_date +', <b>' + @golive_time +' EST</b></br></br>

	<b>Case # (HOPS)</b>: '+ @case_number +'</br></br>

	<b>Customers involved</b>: '+ @src_org_code +' (source) and '+ @dst_org_code +' (destination)</br></br>
 
	<b>Customer impact</b>: '+ @dst_org_code +' (destination) will be down for approximately '+ @offline_minutes +' minutes between <b>' + @golive_time + ' EST</b> . The '+ @facility_names +' facility will not be available until the entire copy has been completed. However, the remaining facilities will be available while data copy is in progress. Please be aware that the '+ @dst_org_code +' database may appear slow at times due to the process running in the background. '+ @src_org_code +' (source) will not be down during the maintenance window, there is no work being done on this database.  </br></br>

	<b>Communication</b>: An end of activity notification will be sent out by the resource </br>
	----------------------------------------------------------------------------------------------------------------------------------------------------------</br></br>
	
	<b>Email for</b>:<u>Go-Live Started Email</u> </br>
	<b>Recepients:</b> <i> friendly reminder </i> </br>
	<b>Subject:</b> <i> reply to friendly reminder </i> </br></br>

	Hi All,</br></br>

	The data copy from '+ @src_org_code +' to '+ @dst_org_code +' has begun now and any updates under '+ @src_org_code +' for '+ @facility_names +' facility made from now and onwards will NOT be brought over to '+ @dst_org_code +'. </br>
	Please <b>reply all</b> to this email, if there are any questions or concerns.</br>

	----------------------------------------------------------------------------------------------------------------------------------------------------------</br></br>

	--> Automation will send all emails and run all the scripts - for MI projects please take the email from previous projects. <-- </br>
	--> IF reports were not sent automatically - send it manually to TSFacAcqCompletionReport@Pointclickcare.com <-- </br>

	----------------------------------------------------------------------------------------------------------------------------------------------------------</br></br>

	--> sp_updatestats in Destination Production </br>
	--> Disable the integration for (source test db) </br>
	--> Disable login for non-PCC users (destination test db) </br>
	--> Send Skin and Wound templates to TPM (if requested)  </br>
	--> If summary email says Lookback Report update the Smartsheet Source TestDB to DO NOT DROP and email Ketki  </br>

	--> below items can be done next day - </br></br>	
	
	--> Update the netsuite case and escalate to Integration Operations if photos or documents has to moved by the HOPS  </br></br>

	<b>Please copy photos and online documentations: </br></br></b>

	FROM 	'+ @src_prod +' – Reg_id = ?? - Fac_id='+@all_SRC_facID +' –Source facility </br>
	TO 	'+ @dst_prod +' – Reg_id = ?? - Fac_id='+@all_DST_facID +' –Destination facility</br></br>

	<b>Please copy lab results:</br></br></b>

	FROM 	'+ @src_prod +' – Reg_id = ?? - Fac_id='+@all_SRC_facID +' –Source facility </br>
	TO 	'+ @dst_prod +' – Reg_id = ?? - Fac_id='+@all_DST_facID +' –Destination facility</br></br>

	<b>Please copy radiology results:</br></br></b>

	FROM 	'+ @src_prod +' – Reg_id = ?? - Fac_id='+@all_SRC_facID +' –Source facility </br>
	TO 	'+ @dst_prod +' – Reg_id = ?? - Fac_id='+@all_DST_facID +' –Destination facility</br></br>

	----------------------------------------------------------------------------------------------------------------------------------------------------------</br></br>
	
	--> Drop staging from Destination Production </br>
	--> Enable DB Maintainance Jobs  </br>
	--> Update JIRA with Actual Time Completed </br>
	--> Update "Projects With Delayed Completion Time" if go-live was late </br>
	--> Enter hours in After hours DS Helper </br>
	--> Update the smartsheet for Test DBs for EI (mark test dbs as complete)  </br>
	
	<b>Email for</b>:<u>LATE – Go-live to Client </u> </br>
	<b>Recepients:</b> <i> friendly reminder </i> </br>
	<b>Subject:</b> <i> reply to friendly reminder </i> </br></br>

	Hi All,</br></br>

	The Data Copy is taking longer than expected. I will advise once the database is back online. </br>
	We apologize for any inconvenience this may cause.</br>
	----------------------------------------------------------------------------------------------------------------------------------------------------------</br></br>

	--> Update Calendar </br>
	--> Take Rest </br></br>
	
	<b>************************************** POST Golive Client Requests - Balance Forwards **************************************</br></br></b>
	
	<b>Email for</b>:<u>Client/Implementer Request Email</u> </br>
	<b>Recepients:</b> client and internal </br>
	<b>Subject:</b> <i> reply to sent email </i> </br></br>

	Hi All, <br/><br/>
 
	I am preparing a test DB for the balance forwards from the source facility.  <br/>
	Below is a list of payers which are in the balance extract file but not mapped or active in the destination DB. <br/> 
	Could you please complete the template below, as the test cannot be completed until these are mapped to active payers in the destination org.<br/><br/>

	<table style="width: 68%;" border="3" cellpadding="2">
	<tbody>
	<tr>
	<th>&nbsp;payer_id</th>
	<th>&nbsp;description</th>
	<th>&nbsp;map_id</th>
	</tr>
	  <tr>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
	</tr>
	<tr>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
	</tr>
	<tr>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
	</tr>
	  <tr>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
	</tr>
	  <tr>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
	</tr>
	  <tr>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
	</tr>
	</tbody>
	</table><br/>

	There are ?? residents which have transaction effective date of ??????. I changed them to ?????? for the below client id #<br/>
	Please let me know if this is not correct and I need to change them back to ?????.<br/><br/>
 
	Also, there are ?? resident which have transaction effective date of ??????.. I changed it to ??????.  as well. Please let me know if I need to revert it back to original date. <br/>
	----------------------------------------------------------------------------------------------------------------------------------------------------------</br></br>

	<b>Email for</b>:<u>Client/Implementer Request Email</u> </br>
	<b>Recepients:</b> client and internal </br>
	<b>Subject:</b> <i> reply to sent email </i> </br></br>

	Hi All,<br/><br/>

	The test DB for balance forwards is ready for review. Please use xxxxxxx to review if the correct balances appear.<br/>
	Please review this with client as well. Once confirmed, I will import the balances in production.<br/><br/>
	
	************************************** END OF EMAIL **************************************</br></br>

	Good Luck, </br>
	<b>Technical Services </br></br></b>

	<b><u><font size="3" color="red">NOTICE:</u> Confidential message which may be privileged. Unauthorized use/disclosure prohibited. If received in error, please inform the sender immediately.</font></b>

	' 

	SET @subject = 'PMO-' +@pmo_number+ ' - '+ @src_org_code +' to '+ @dst_org_code +' - Data Copy to Existing - Dynamic Generated Emails'
	--SET @TableFac = @TableFac + '<tr style="background-color:;">' + '<td>' + convert(varchar, @startdate) + '</td>' + '<td>' + convert(varchar, @enddate) + '</td>' + '</tr>'
	SET @tableHTML = 
	N'<font color="Black"><h1>Dynamically generated emails for '+ @pmo_number +' </h1>' + 
	N'<font color="Black">' + @email_text 
	SET @FinalTable = '<table text-align:left;>' + @tableHTML

	--PRINT @FinalTable

	EXEC msdb.dbo.sp_send_dbmail @recipients = @recepients,@subject = @subject,@body = @finalTable,@body_format = 'HTML';
END
GO

DECLARE	@return_value int
EXEC	@return_value = [dbo].[sp_SendEmail_DynamicGeneration]
SELECT	'Return Value' = @return_value
GO

DROP PROCEDURE [sp_SendEmail_DynamicGeneration]
GO