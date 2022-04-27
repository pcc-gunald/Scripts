***Started running disable integration script on test_usei1066
***Executing the SQL file \\STUSPAINFCIFS.pccprod.local\DS\Prod\ImportHelper\ImportScripts\DisableIntegration\NEW_DISABLE_INTEGRATIONS_SCRIPT_EI.sql
-----------------------------------------------------------
--message_profile, message_route
/*
revision_by:		Carlos Valenca
revision_date:		2011-05-13

					-Put "" after each DML command
					-switch the truncate statement for delete.

*/
UPDATE facility
SET messages_enabled_flag = NULL

------Added By:Jaspreet Singh, Date:2021-07-22, Reason:As per product this column should be unique
UPDATE facility 
SET fac_uuId = NULL
--delete message_route
--delete message_profile
--update message_profile set is_enabled='N', endpoint_url='test', remote_login=NULL, remote_password=NULL, receiving_application='xxxxxxxx', sending_application='xxxxxxxx'
-- starting with 3.6.2.2 (PCC-36021), Rhapsody will 'swallow' messages with the mode flag set to debug (D)
UPDATE message_profile
SET message_mode = 'D'
WHERE message_protocol_id = 12;-- protocol_id=12 is EOM

TRUNCATE TABLE pho_phys_vendor

--delete lib_message_profile
--update lib_message_profile set is_enabled='N', endpoint_url='test', remote_login=NULL, remote_password=NULL, receiving_application='xxxxxxxx', sending_application='xxxxxxxx'
UPDATE lib_message_profile
SET message_mode = 'D'
WHERE message_protocol_id = 12;-- protocol_id=12 is EOM

--========================================================================================================================
--Third Party MDS Data
TRUNCATE TABLE as_imported_status -- Modified by Roshan on Oct 30,2013 statement changed from delete to truncate
	-- delete as_imported_status

TRUNCATE TABLE as_imported_response -- Modified by Roshan on Oct 30,2013 statement changed from delete to truncate
	-- delete as_imported_response

IF EXISTS (
		SELECT *
		FROM sys.objects
		WHERE object_id = OBJECT_ID(N'[dbo].skin_wound_partner_facility_mapping')
			AND type IN (N'U')
		)
BEGIN
	DELETE skin_wound_partner_facility_mapping;-- Added on May 5,2016 by Bipin Maliakal as per Ann's suggestion.
END

--truncate table as_vendor_configuration -- Modified by Roshan on Oct 30,2013 statement changed from delete to truncate
--delete as_vendor_configuration
--========================================================================================================================
--Third Party MDS Verification
DELETE as_submission_accounts_mds_30 --sproc_mds_dml_submissionParametersMDS3Util

UPDATE configuration_parameter
SET value = ''
WHERE name IN (
		'as_ltcq_entity'
		,'as_ltcq_pwd'
		,'as_ltcq_trackid'
		,'as_ltcq_uid'
		,'as_ltcq_vendor'
		) --MDS 2.0 page

UPDATE configuration_parameter
SET value = 'N'
WHERE name IN (
		'as_verify_test_flag_on'
		,'allow_verify_in_progress'
		,'as_enable_mds_extverify'
		) --MDS 3.0 page

UPDATE configuration_parameter
SET value = ''
WHERE name IN (
		'as_mds_verifier'
		,'as_ltcq_entity'
		,'as_ltcq_uid'
		,'as_ltcq_pwd'
		,'as_ltcq_trackid'
		,'as_ltcq_vendor'
		) --MDS 3.0 page

--========================================================================================================================
--Giftwrap/ROX Reports
DELETE configuration_parameter
WHERE name IN (
		'enable_rox_reports'
		,'rox_vendor_code'
		,'rox_interested_party'
		,'rox_organization'
		,'rox_url'
		,'rox_username'
		,'rox_password'
		)

--========================================================================================================================
--MDS 3 Automated Submissions
DELETE automated_mds_enabling_step

UPDATE configuration_parameter
SET value = 'N'
WHERE name = 'mds_automated_submission'

--========================================================================================================================
--IRM
UPDATE crm_integration_option
SET enabled = 'N'

--edited by Cynthia Cui on 20170907 
--DELETE from crm_codes where long_desc like '%ECIN%' or long_desc like '%SIMS%' OR long_desc like '%Curaspan%'
UPDATE crm_codes
SET deleted = 'Y'
WHERE long_desc LIKE '%ECIN%'
	OR long_desc LIKE '%SIMS%'
	OR long_desc LIKE '%Curaspan%'

--========================================================================================================================
--UPDATE dbo.configuration_parameter SET value='N' WHERE name='enable_user_communication' --Added As per Ann's requirement on 03 Dec 2014
DELETE
FROM dbo.configuration_parameter
WHERE name = 'enable_user_communication' --Added As per Katheleen's requirement on July 28,2015
	--=======================================================================================================================
	--Dept tables
	--Added as per Katheleen's request on Mar 14, 2016,5:40 PM

IF EXISTS (
		SELECT *
		FROM sys.objects
		WHERE object_id = OBJECT_ID(N'[dbo].dep_message_action')
			AND type IN (N'U')
		)
BEGIN
	DELETE dep_message_action;
END

DELETE dep_direct_message;

DELETE dep_receiver;

DELETE dep_attachment;

DELETE dep_message;

DELETE dep_direction;

DELETE dep_receiver_type;

DELETE dep_status;

DELETE dep_type;

DELETE dep_message_associated_client;

DELETE dep_attachment_doc_type;

--================================================--Added As per Katheleen's requirement on July 28,2015====================================================================================
DELETE facility_tigertext;

DELETE Sec_user_tigertext;

DELETE Sec_user_facility_tigertext;

--================================================--Added As per Katheleen's requirement on May 10,2016====================================================================================
UPDATE file_metadata
SET location = CONVERT(VARCHAR, file_metadata_id) + 'EI<case_number>'
FROM file_metadata -- Added by Bipin Maliakal on request of Rina Perez on 19 May 2016
	--exec sp_disable_constraints
	--delete from upload_files ;delete from file_metadata 
	--exec sp_enable_constraints

-- Added on 07/12/2016
IF EXISTS (
		SELECT *
		FROM sys.objects
		WHERE object_id = OBJECT_ID(N'[sec_user_facility_tigertext_audit]')
			AND type IN (N'U')
		)
BEGIN
	DELETE sec_user_facility_tigertext_audit;
END

-- Added per case 802500 on 08/09/2016
DELETE configuration_parameter
WHERE name IN (
		'mds3_education_username'
		,'mds3_education_password'
		) --MDS 3

UPDATE configuration_parameter
SET value = 'N'
WHERE name IN ('as_third_party_education') --MDS 2

INSERT INTO upload_tracking (
	script
	,TIMESTAMP
	,upload
	)
VALUES (
	'Disable Script'
	,getdate()
	,'Cleanup process'
	)

IF EXISTS (
		SELECT *
		FROM sys.VIEWS
		WHERE name = 'pho_schedule_details_history'
		)
BEGIN
	PRINT 'MULTI-HISTORY VIEWS DETECTED, PLEASE RUN Fix Multi-History Views.sql script'
END

--changes on Jan 13, 2017
UPDATE message_profile
SET is_enabled = 'N'
	,endpoint_url = 'test'
	,remote_login = NULL
	,remote_password = NULL
	,receiving_application = 'xxxxxxxx'
	,sending_application = 'xxxxxxxx'
WHERE ISNULL(receiving_application, '') NOT IN ('SWIFT')

UPDATE lib_message_profile
SET is_enabled = 'N'
	,endpoint_url = 'test'
	,remote_login = NULL
	,remote_password = NULL
	,receiving_application = 'xxxxxxxx'
	,sending_application = 'xxxxxxxx'
WHERE vendor_code NOT IN (
		'SWIFT_ADT'
		,'SWIFT_Assessment'
		)

UPDATE lib_message_profile
SET is_enabled = 'N'
WHERE vendor_code IN (
		'SWIFT_ADT'
		,'SWIFT_Assessment'
		)

UPDATE message_profile
SET is_enabled = 'N'
WHERE receiving_application IN ('SWIFT')

/*************Added By: Jaspreet Singh, Date: 7/1/2017, Purpose: RE: DS_Integration_Check FAILED, TableName [as_vendor_configuration]******************/
ALTER TABLE as_vendor_configuration DISABLE TRIGGER [tp_as_vendor_configuration_upd];

UPDATE as_vendor_configuration
SET STATUS = 'I'

ALTER TABLE as_vendor_configuration ENABLE TRIGGER [tp_as_vendor_configuration_upd];

ALTER TABLE as_vendor_configuration DISABLE TRIGGER [tp_as_vendor_configuration_del];

DELETE as_vendor_configuration
WHERE vendor_code <> 'SWIFT_MDS'

ALTER TABLE as_vendor_configuration ENABLE TRIGGER [tp_as_vendor_configuration_del];

/****************End********************/
UPDATE configuration_parameter
SET value = 'N'
WHERE name = 'enable_skin_wound'
	AND value = 'Y' --disable skin and wound, May 17, 2017

--added by Cynthia Cui on 20180201 as per request from Rina (smart sheet line 101)
UPDATE CONFIGURATION_PARAMETER
SET value = 'N'
WHERE name = 'enable_rox_clinical_doc_reports'
	AND value = 'Y'

--end of adding
-- added By Jaspreet Singh on 2018-03-09 as per request from Ann (email subject: FW: DB copy scripts)
UPDATE CONFIGURATION_PARAMETER
SET value = 'N'
-- select * from CONFIGURATION_PARAMETER 
WHERE name = 'enable_therapy_iframe'
	AND value = 'Y'

--end of adding
/*
Added By: Jaspreet Singh
Date: 04-06-2018
Reason: Ann email, subject: FW: Document Manager configuration on usei48
*/
--=======================================================================================
--  Jira #:
--
--  Written By:       Mitch Bilensky
--  Reviewed By: 
--
--  Script Type:      DDL 
--  Target DB Type:   CLIENT
--  Target Database:  BOTH
--  
--  Re-Runnable:      YES
--  
--  Description of Script Function: Removes Document Manager and eSignature 
--                                  enablement configuration prameters as the
--                                  eSignLive config options from a client database
--
--  Special Instruction: 
--=======================================================================================
DELETE
FROM configuration_parameter
WHERE name = 'document_manager_enabled'
	OR name = 'enable_disable_e_signature'

DELETE
FROM esl_configuration_param

-- end of adding
/*
Added By: Jaspreet Singh
Date: 01-07-2019
Reason: Rina email, subject: Adding new table "Consistency_Audit"
*/
UPDATE facility
SET timeout_minutes = 15
WHERE deleted = 'N'

/*
-- added By Jaspreet Singh on 2018-03-27 as per request from Ann (email subject: FW: Active IAR integrations in Test dbs)
-- Related JIRA for script https://jira.pointclickcare.com/jira/login.jsp?permissionViolation=true&os_destination=%2Fbrowse%2FPCC-109360&page_caps=&user_role=
*/
DELETE configuration_parameter
WHERE NAME IN (
		'as_effectivedate_iarconsent'
		,'as_enable_iarconsent'
		,'as_enable_iarconsent_ccim_organization_id'
		,'as_enable_iarconsent_ccim_organization_name'
		,'as_enable_iarconsent_password'
		,'as_enable_iarconsent_revisionby'
		,'as_enable_iarconsent_revisiondate'
		,'as_enable_iarconsent_url'
		,'as_enable_iarconsent_username'
		,'as_iar_collect_consent_date'
		)

--end of adding
/**********************************************************
****Added By: Jaspreet Singh
****Date: 2020-10-27
****Requested By: Nigel, email subject: Sent from Snipping Tool
******************************************************/
UPDATE configuration_parameter
SET [value] = 'N'
WHERE [name] = 'ghc_hosted_optima'
	AND [value] = 'Y'

--========================================================================================================================
--*** Disable integration has been successfully ran on test_usei1066
-----------------------------------------------------------