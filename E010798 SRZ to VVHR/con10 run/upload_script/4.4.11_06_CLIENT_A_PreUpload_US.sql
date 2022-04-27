SET NOCOUNT ON
GO

SET DEADLOCK_PRIORITY HIGH
GO


insert into upload_tracking (script, timestamp, upload) values ('UPLOAD_START',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-100695 - 1 - DDL - Create table mapping iam roles and positions.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

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


--=============================================================================
--  Issue:			  CORE-100695
--  Written By:		  Giovanny Tellez
--  Script Type:      DDL
--  Target DB Type:   Client
--  Target Database:  BOTH
--  Re-Runnable:       Yes
--  Description :     Create table that store mapping between 'iam roles' and 'positions'.
--
--=============================================================================

IF NOT EXISTS (SELECT 1 FROM [information_schema].[tables]
				WHERE table_name = 'iam_role_position' AND table_schema = 'dbo') 
    BEGIN
		CREATE TABLE iam_role_position (--:PHI:N:Desc:Store mapping between 'Standard roles' and the different 'positions' that are saved in the table common_code 
			 role_position_id int IDENTITY (1,1) NOT NULL,--:PHI:N:Desc:primary key
			 position_id int NOT NULL,	   --:PHI:N:Desc:Foreing key that store positionId 
			 iam_role_name VARCHAR(255) NOT NULL, --:PHI:N:Desc:code role
			 CONSTRAINT [iam_role_position__validationId_PK_CL_IX] PRIMARY KEY (role_position_id),
			 CONSTRAINT [iam_role_position__positionId_iamRoleName_UQ_IX] UNIQUE (position_id, iam_role_name),
			 CONSTRAINT [iam_role_position__positionId_FK] FOREIGN KEY (position_id) REFERENCES dbo.common_code(item_id)
		);
		CREATE NONCLUSTERED INDEX iam_role_position__positionId_FK_IX ON iam_role_position (position_id);
    END


GO

print 'A_PreUpload/CORE-100695 - 1 - DDL - Create table mapping iam roles and positions.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-100695 - 1 - DDL - Create table mapping iam roles and positions.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-100695 - 2 - DML - populate mapping table iam roles positions.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

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
-- Jira #:               CORE-100695
--
-- Written By:           Giovanny Tellez
--
-- Script Type:          DML
-- Target DB Type:       CLIENT 
-- Target ENVIRONMENT:   BOTH  
-- Re-Runable:           YES  
--
-- Staging Recommendations/Warnings: none
-- Where tested:         DEV_US_Team_GG_agrd
--
-- Description of Script Function: Take a json that has the mapping between positions and standard role and save it in the table iam_role_position. It will just save the position that will be find in the org.
-- The Json was given by product.
--
-- Special Instruction: none
--
--
-- =================================================================================

DECLARE 
   @vpositionIamRoleMapTbl  [dbo].[TwoColumnsOfStringTableType]   
  ,@vstandardIamRoleTbl	   [dbo].[TwoColumnsOfStringTableType]
  ,@jsonPositionIamRoleMap	NVARCHAR(MAX)
  ,@jsonStandardIamRole		NVARCHAR(MAX) 


SET @jsonPositionIamRoleMap = N'{
    "PositionIamRoleNameMap": [
        {
            "position": "Certified Nursing Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Licensed Practical Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Registered Nurse",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Certified Nursing Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "C.N.A.",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Physical Therapist",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Occupational Therapist",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Licensed Vocational Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Nursing Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Medication Aide/Tech",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "HCA/PSW",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Speech Therapist",
            "iamRoleName": "Speech/language pathologist"
        },
        {
            "position": "Pharmacist",
            "iamRoleName": "Pharmacist"
        },
        {
            "position": "HCA/PSW/RCA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "STNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Social Worker",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "Receptionist",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Activities Aide",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Physical Therapy Assistant",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "Business Office Manager",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "Charge Nurse",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Licensed Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Director of Nursing",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Medical Records",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "LPN/LVN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Activities Director",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "State Tested Nursing Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Registered Practical Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Personal Support Worker ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Surveyor",
            "iamRoleName": "Survey/audit/accreditation professional"
        },
        {
            "position": "CNA/GNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "PSW/HCA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Physician Assistant",
            "iamRoleName": "Physician Assistant"
        },
        {
            "position": "Respiratory Therapist",
            "iamRoleName": "Respiratory Therapist"
        },
        {
            "position": "Care Manager",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "RPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Accounts Receivable",
            "iamRoleName": "Accounting/finance staff"
        },
        {
            "position": "Certified Nurses Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Admin Assistant",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "Resident Care Specialist",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Personal Support Worker",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "IT",
            "iamRoleName": "System admin (app specific)"
        },
        {
            "position": "Resident Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Restorative Nursing Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "PSW",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Accountant",
            "iamRoleName": "Accounting/finance staff"
        },
        {
            "position": "Admissions Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Dietary",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Assistant Director of Nursing",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Care Giver",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Nursing Aide/STNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Social Services",
            "iamRoleName": "Other social worker"
        },
        {
            "position": "Nurse Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Dietary Manager",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "CNA/STNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Medication Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Agency CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Medication Aide/Tech",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Caregiver",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Admissions Co-ordinator",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "Pharmacy",
            "iamRoleName": "Pharmacist"
        },
        {
            "position": "LPN Unit Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Health Care Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "(NA) Nursing Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Business Office",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "State Tested Nursing Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Clinical Consultant",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "C. N. A. ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Registered Nurse (RN)",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "STNA/CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Executive Director",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Certified Nursing Aide (CNA)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Lead Care Manager",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "C.N.A.",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Agency LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Medication Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Caregiver/Universal Worker",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Reimbursement Specialist",
            "iamRoleName": "Accounting/finance staff"
        },
        {
            "position": "Medical Director",
            "iamRoleName": "Medical Director"
        },
        {
            "position": "Registered Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "RN Unit Nurse",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Activities Assistant",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "External Agency CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Recreation Assistant",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "HCA/RCA/PSW",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Activities",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "LPN - Licensed Practical Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Certified Occupational Therapy Assistant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "RCA/HCA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Housekeeping",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "Care Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Nursing Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Pharmacy Consultant",
            "iamRoleName": "Pharmacist"
        },
        {
            "position": "PTA",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "Personal Care Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "LVN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "GNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "PCA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "CNA - Certified Nursing Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Registered Practical Nurse (RPN)",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Physical Therapy",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Med Care Manager",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "Nursing Supervisor",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Concierge",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "OCCUPATIONAL THERAPY ASSISTANT",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Resident Assistants",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Residential Care Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "COTA",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Admissions Coordinator",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "Dining Services",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Geriatric Nursing Assistant ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Activities/Rec Therapy",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Occupational Therapy",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Unit Clerk",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "Pharmacy Technician",
            "iamRoleName": "Pharmacy technician"
        },
        {
            "position": "HCA/PCA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Health Care Aid/Assistant ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Resident Care Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "S.T.N.A.",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "RN Supervisor",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Licensed Practical Nurse (LPN)",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "A-Health Care Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Security",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Care Assistant [UK]",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Geriatric Nursing Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": " LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Case Manager",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "Office Manager",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "Care Manager/Coordinator",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "Health Care Aid",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Director of Operations",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "PSW/PCA/HCA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Director of Rehab",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Social Services Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Financial Consultant",
            "iamRoleName": "Accounting/finance staff"
        },
        {
            "position": "Physiotherapist",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Licensed Nursing Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Med Aide/Tech/Med Pass ",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Licensed Nurse (LPN/LVN)",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Resident Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Nursing Aide CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Pharmacy Assistant",
            "iamRoleName": "Pharmacy technician"
        },
        {
            "position": "Certified Nurse Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Surveyor Access",
            "iamRoleName": "Survey/audit/accreditation professional"
        },
        {
            "position": "Resident Assistant ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "PSW*",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "LPN Med Care Manager",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "CNA/GCS/CG",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Wellness Nurse",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "RN-Director of Nursing",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Care Partner",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Agency Carer [UK]",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Recreation Therapist",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "**CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Personal Care Aides",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Respiratory Therapy",
            "iamRoleName": "Respiratory Therapist"
        },
        {
            "position": "Nurse Manager",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "C.N.A._ Agency",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "CNA/NAC",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Physical Therapist Assistant",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "Pharmacy Tech",
            "iamRoleName": "Pharmacy technician"
        },
        {
            "position": "Certified Nursing Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Med Tech/Med Aide/Caregiver",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Agency RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Recreation aide",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Licensed Practical Nurse ",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Dietary Supervisor",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Nursing Assistant ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "HCA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Activities ",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Pool CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Speech Language Pathologist",
            "iamRoleName": "Speech/language pathologist"
        },
        {
            "position": "Direct Support Professionals",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "CMA",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Med Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Qualified Medication Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Med Tech",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Trained/Certified Medication Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Personal Care Attendant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "PSW/HCA*",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "RN - Registered Nurse",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "CNA / LNA / GNAS",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "State Surveyor",
            "iamRoleName": "Survey/audit/accreditation professional"
        },
        {
            "position": "Student Practical Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Personal Care Associate",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "RCA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "HCA/PSW/RCA - Agency",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "ADON",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Universal Worker",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Dietary ",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Health & Wellness Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Resident Care Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "*CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Personal Care Provider",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Resident Attendant/Health Care Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "*Certified Nursing Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Physiotherapy Assistant",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "PSW student",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "*RPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Nurse Supervisor",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "PSYCHOLOGIST",
            "iamRoleName": "Mental health service worker"
        },
        {
            "position": "Nursing - CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Continuing Care Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Chaplain",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Activities Aide/Assistant",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Licensed PT Assistant",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "State Tested Nurse Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Resident Care Associate",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Licensed Vocational/Practical Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Ward Clerk",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "*RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Speech Therapy",
            "iamRoleName": "Speech/language pathologist"
        },
        {
            "position": "Home Health Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Controller",
            "iamRoleName": "Accounting/finance staff"
        },
        {
            "position": "Chief Financial Officer",
            "iamRoleName": "Accounting/finance staff"
        },
        {
            "position": "LPN/RPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Agency Care Manager",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "ITS",
            "iamRoleName": "System admin (app specific)"
        },
        {
            "position": "RGA-Unregulated Care Provider",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Nursing Assisstant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "CNA (Agency) Certified Nurse Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "CBC Caregiver ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Recreation",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "*Care Manager",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "Agency Certified Nursing Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Senior Care Assistant [UK]",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Registered Physical Therapist",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "MDS Coordinator RN",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Unit Secretary",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "Chief Executive Officer",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "RPN Student",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Occupational Therapist Assistant ",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "*Care Partner",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Medication Tech",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Nursing - STNA/CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Nursing Aide/Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Registered Occ Therapist",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Activity Aide",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Admissions",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "Certified Nursing Assistant ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "State Tested Nurse Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Director of Staff Development",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Cert Occupation Therap Assist",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Business Office Assistant",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "Pool Staff - CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "CBC Health Care Coordinator ",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "Admissions ",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "Licensed Practical Nurse*",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Human Resources",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "Certified Dietary Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Nursing Unit Manager",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Social Service Designee",
            "iamRoleName": "Other social worker"
        },
        {
            "position": "Registered Nurse ",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Cert. Occupation Therapy Asst",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "CNA - Agency",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Registered Nurse",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "**LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Nursing - RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Certified Nursing Assistant / Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "*Agency-CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "ARNP",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Resident Care Manager",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "Social Service Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "*Resident Companion",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Doctor",
            "iamRoleName": "Physician"
        },
        {
            "position": "External Agency LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Clinical Services Consultant",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "CNA/NA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Nursing Aide(CORP)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": " RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Director of Care",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Patient Care Technician",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Social Services Assistant",
            "iamRoleName": "Other social worker"
        },
        {
            "position": "*Nursing - CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Director of Nursing Services",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Registered Speech Therapist",
            "iamRoleName": "Speech/language pathologist"
        },
        {
            "position": "Geriatric Nursing Assistant (GNA)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Agency-CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Office/Clerical",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "RAI Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "MD",
            "iamRoleName": "Physician"
        },
        {
            "position": "Licensed Practical Nurse/Licensed Vocational Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Activities Coordinator",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Laundry",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Licensed Nursing Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Physician/NP/PA",
            "iamRoleName": "Physician"
        },
        {
            "position": "Psychiatrist",
            "iamRoleName": "Physician"
        },
        {
            "position": "**RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Care Giver WI",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Administrative Assistant",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "Nursing CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Non-Certified Nursing Assist",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Geriatric Nursing Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Life Enrichment Manager",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Reminiscence Care Assistant [UK]",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Executive Director/Ops/CIT",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "Cook",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Agency Med Tech/Med Pass",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Dietician",
            "iamRoleName": "Dietician"
        },
        {
            "position": "LNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Health Care Aid/Personal Support Worker",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "*Medication Care Manager",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Assistant Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Chief Operating Officer",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "Health Care Aide/PSW",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Pharmacy staff",
            "iamRoleName": "Pharmacy technician"
        },
        {
            "position": "Certified Nursing Assistant SNF",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Medication Associate",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Med-Tech",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "External Agency RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Licensed Practical Nurse(Staff Nurse)",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Director of Clinical Services",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Executive Director I",
            "iamRoleName": "Administrator"
        },
        {
            "position": "A-Licensed Practical Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Pharmacy Rep",
            "iamRoleName": "Pharmacy technician"
        },
        {
            "position": "Registered Dietician",
            "iamRoleName": "Dietician"
        },
        {
            "position": "CCA / PCW",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "R.P.N",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Restorative Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Director of Sales",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "Social Services/Worker",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "RN MDS Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Restorative CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Unregulated Care Provider",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Administration",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Licensed Nurse ",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Licensed Practical Nurse SNF",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Personal Care Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Business Office Director",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "Non-Certified Nursing Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "CMA/CMT ",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Resident Care Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "*Wellness Nurse",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Business Office Coordinator",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "Therapy Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": " Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "CNA Student",
            "iamRoleName": "Nurse Aide in Training"
        },
        {
            "position": "Unit Manager RN",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Medical Provider",
            "iamRoleName": "Physician"
        },
        {
            "position": "Nursing Assistant Certified",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Med Tech/Aides ",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Resident Care Coordinator",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "LVN/ LPN Village",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "L.N.A.",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Unit Manager/Nurse Manager",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Medication Technician",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Agency-PSW",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Medical Records Assistant",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "*Registered Nurse",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Wellness Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "HCA/PSW/RCA - Contract",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Health Care Aide - LTC",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Nutrition Services Manager",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Home Health Aide/Caregiver",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Occupational Therapist Assistant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "R.N",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Accounting Clerk",
            "iamRoleName": "Accounting/finance staff"
        },
        {
            "position": "Food Service Supervisor",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "CP Medication Tech/QMAP",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Billing & Collections ",
            "iamRoleName": "Accounting/finance staff"
        },
        {
            "position": "Licensed Nurse (LN)",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "CNA/NAR",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Care Attendant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "MEDICAL RESIDENT",
            "iamRoleName": "Physician"
        },
        {
            "position": "Agency Licensed Practical Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Billing Specialist",
            "iamRoleName": "Accounting/finance staff"
        },
        {
            "position": "Office Manager/Bookkeeper/Admin.Asst.",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "LPN (Agency)",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Pool Staff - LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Clinical Care Coordinator",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "Dietary Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Director of Resident Care",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Attending Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "Resident Care Aid",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Health & Wellness Coordinator",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "LPN.",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Registerd Nurse Supervisor",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Student (RN program)",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Hospice RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "*Licensed Practical Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Consultant Pharmacist",
            "iamRoleName": "Pharmacist"
        },
        {
            "position": "RN Student",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Registered Dietitian ",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Charge Nurse LPN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Certified Occupational Therapist Assistant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Marketing Director",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "Licensed Practical Nurse LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Student Nurse Aide",
            "iamRoleName": "Nurse Aide in Training"
        },
        {
            "position": "RN - External",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Food Service Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Medical Records Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "C.N.A. (Agency)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Activities Staff",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Social Service Assistant",
            "iamRoleName": "Other social worker"
        },
        {
            "position": "LPN - External",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Administrator / ED",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Caregiver/CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Floor Nurse-LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Nursing - LPN & LVN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Agency-RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Regional Director of Clinical Services",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Registered/Licensed Practical Nurse - Contract",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Recreation Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Vendor-Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "Regional Director of Operations",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "Registered Nurse RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "NA Student",
            "iamRoleName": "Nurse Aide in Training"
        },
        {
            "position": "Home Health CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "*Certified Medication Aide/Tech",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Temporary Nurse Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Director of Nursing-DON",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "MDS RN",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Physician ",
            "iamRoleName": "Physician"
        },
        {
            "position": "Nursing Aid (AC-ICF)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Nursing - LPN/LVN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Wellness Nurse,LPN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Unit Manager LPN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Director of Social Services",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "CNA/TMA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Wellness LPN/LVN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Nursing - CNA (Agency)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Nurse Practitioner (Physician)",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Restorative C.N.A.",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "LPN Unit Care Coordinator",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Certified Nursing Aide SNF",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Activity Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "*Executive Director",
            "iamRoleName": "Administrator"
        },
        {
            "position": "MDS LPN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "LPN-agency",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "MDS Coordinator LVN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Nursing LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Vendor-Physical Therapist",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Rehab Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Agency-LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Speech/Language Pathologist",
            "iamRoleName": "Speech/language pathologist"
        },
        {
            "position": "CNA - Agency/Hospice",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "LPN Nurse Supervisor",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Speech Pathologist",
            "iamRoleName": "Speech/language pathologist"
        },
        {
            "position": "DON",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "*Certified Nursing Assistant (CNA)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Agency Certified Nursing Aide/STNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "C.N.A.-agency",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Outside Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Physical Therapist",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Program Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "LPN MDS Nurse",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "DON/ADON/DSD/SUPERVISOR",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Admissions Director Non-Nurse",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Registered Dietitian (RD)",
            "iamRoleName": "Dietician"
        },
        {
            "position": "GN-CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Associate Director of Care",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Community Life Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Certified Nursing Aide - Agency",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Contracted Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Certified Nursing Asst",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Executive Director II",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Pharmacist Consultant",
            "iamRoleName": "Pharmacist"
        },
        {
            "position": "Dietary/Food Service Manager/Supervisor",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "LPN STUDENT",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Food Srvc Dir - Cert Diet Mgr",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "CP Certified Nursing Asst CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Director of Clinical Services, RN",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Certified Nurse Assistant ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "C.N.A",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Nursing Aide - CSU",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "*Agency-LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Dietary Mgr",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Agency Nurse - LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "CP Resident Care Nurse LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Clinical Reimbursement Director",
            "iamRoleName": "Accounting/finance staff"
        },
        {
            "position": "Certified Nuring Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Omnicare Consultant Pharmacist",
            "iamRoleName": "Pharmacist"
        },
        {
            "position": "Assistant Director of Nursing, RN",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Director Of Care (DOC)",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Food Services Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Certified Nursing Assistance",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Assistant Director of Care",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "MDS Coordinator LPN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Nursing Supervisor-LPN-LVN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "LPN - ALF",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Agency Certified Nursing Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "LPN Supervisor",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Director of Rehabilitation",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Administrator/ED/GM/AED",
            "iamRoleName": "Administrator"
        },
        {
            "position": "CHARGE NURSE (LPN)",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "RN-MDS Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Dietetic Intern",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Crandall Corporate Dietitians",
            "iamRoleName": "Dietician"
        },
        {
            "position": "LPN Charge Nurse",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "BOCES Student (LPN)",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Director of Nursing/Nurse Manager",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Dietary Service Manager",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "RN/MDS/Unit Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Director of Business Development",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "Nurses Aide Certified",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Health Information Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Nutrition Services Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Director of Care ",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Community Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Certified Nursing Assistant*",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Nursing Asst Certified ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Business Development Director",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": " Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Certified Nursing Aide (Agency)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Nursing Aide - Maxim",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Director Clinical Services Specialist",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Dietitian/Food Srv Dir/Dietetic Tech",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Dining Services Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Community Relations Director",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "Clinical Pharmacist",
            "iamRoleName": "Pharmacist"
        },
        {
            "position": "Certified Nurse Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Assistant Director of Nursing ",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "LPN Treatment Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Health and Wellness Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Director of Nursing (DON)",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Director of Dietary Services",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Nursing - LPN/LVN (Agency)",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Resident Services Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Dietitian (RD, LD)",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Director of Nursing ",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Resident Assessment MDS RN ",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "LPN Unit Manager",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Unit Manager (LPN)",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "MDS Coordinator LPN/LVN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "LPN-MDS Nurse",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "LVN- Case Mix Manager",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Registered Dietician (Contract)",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Director of Medical Records",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Assisted Living Director",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Director of Finance",
            "iamRoleName": "Accounting/finance staff"
        },
        {
            "position": "Dietary Consultant",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Certified Nursing Aide- Agency",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "MDS Coordinator/RNAC",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "MDS LVN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "*Director of Nursing",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": " Dietary Manager",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Director of Administration",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Director of Food Services",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Director of Clinical Operations",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Certified Nursing Assistant (CNA)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Nursing Aide 12",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Staffing LVN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Clinical Admissions Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "ACC Certified Nursing Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Activity Director.",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Human Resources Director",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "*Wellness Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Director Care Coordination",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Director of Nursing/Assistant Director of Nursing",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Assistant Director of Nursing (ADON)",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Assistant Director of Nurses",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Registered Dietitian - Contract",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietary Services Manager",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Associate Executive Director",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Director of Therapy",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Director of Wellness",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Director of Financial Services",
            "iamRoleName": "Accounting/finance staff"
        },
        {
            "position": "Agency LPN/LVN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Director of Community Relations",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "Charge Nurse/LVN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Resident Assessment MDS LPN ",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Facility Rehab Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Fitness Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Clinical Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Human Resource Director",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "Certified Nurses Assistant or direct",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Personnel Director",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "Director, Nursing",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Executive Director AL",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Assistant Dietary Manager",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Medical Record Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Dietary Manager.",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Rehab Director ",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "District Director Clinical OPS",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Dietary Dir/Mgr",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Finance Director",
            "iamRoleName": "Accounting/finance staff"
        },
        {
            "position": "Activities Director/Coord.",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Dietary Manager/Supervisor",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": " Director of Nursing",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Resident Programs Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Dietician-Registered",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Director of Resident and Family Services",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "*Licensed Practical Nurse/LVN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Certified Nursing Aide(NAC)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Reg Director of Clinical Services",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "LPN Medical Records Director ",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Dietary Intern",
            "iamRoleName": "Dietician"
        },
        {
            "position": "G.N.A.",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Clinical Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Therapeutic Recreation Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Director of Marketing",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "Director of Health Services",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "*SHR/Nursing/NURSES AIDE CERTIFIED",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Assistant Director of Nursing IC",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "CBC Life Enrichment Director ",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Asst Director of Nursing ",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Memory Care Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "NHA/Executive Director",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Co-Director of Care",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Resident Service Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Director of Nursing/ADON",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Admissions Coordinator/Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": " Director of Admissions",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Physician - Medical Director",
            "iamRoleName": "Medical Director"
        },
        {
            "position": "Director of Resident Programs",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "CP LifeStyles Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Director of Sales and Marketing",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "Director of Rehab Services",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "CBC Executive Director ",
            "iamRoleName": "Administrator"
        },
        {
            "position": "*Activities Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Executive Director ",
            "iamRoleName": "Administrator"
        },
        {
            "position": "*Director of Wellness",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "CBC Director of Health Services (DHS)  ",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "District Director of Clinical Operations",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Director of Resident Services",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Rehab Service Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "CP Resident Care Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Director of Nurses",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Associate Director of Resident Care",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "*LPN/LVN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Regional Rehab Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "MDS Nurse LPN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Medical Records - Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Director of Nutritional Services",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "CP Executive Director",
            "iamRoleName": "Administrator"
        },
        {
            "position": " Medical Director",
            "iamRoleName": "Medical Director"
        },
        {
            "position": "Regional Director of Clinical Operations",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Nursing Director (DON)",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Director of Rehabilitative Services",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Director of Admissions",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Director of Community Life",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Assistant Director of Nursing Services",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Certified Nursing Assistant Trainee",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Assistant Director of Nursing Care",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Regional Director of Care",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "LPN-MDS Coordinator",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Executive Director III",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Director of Activities",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Assistant Director of Nursing LVN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "CBC Dietary Manager ",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Assistant Executive Director",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Certified Nurse Aid",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "R.N.",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Health Services Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Director of Nursing Care/ Wellness Co-ordinator",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Dietitian-Registered",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietitian, Registered",
            "iamRoleName": "Dietician"
        },
        {
            "position": "RN - MDS Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Regional Director of Health",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Director of Case Management",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "CNA -Certified Nurse Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "MDS Coordinator/RNAC/Care Manager/Care Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Facility RD (Dietician)",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Director of Rehabilitation Services",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Certified Nursing Aide*",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Medical Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Reg. Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Licensed Practical Nurse (LVN)",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Director of Nursing (SNF)",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Area Rehab Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Assistant Activities Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "RN Director of Nursing",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "RN - Assistant Director of Nursing",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "PC Unit Certified Nursing Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Nursing - MDS Specialist RN",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Field Services Clinical Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Director of  Recreation",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Assistant Director Clinical Services",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Senior Rehab Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Physical Therapy Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Director of Admissions ",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Dietary Services Supervisor ",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Clinical Services Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Certified Med Aide/GNA",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Administrator/Executive Director",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Regional Clinical Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Director of Therapy Services",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Executive Director/CEO",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Director of Assisted Living",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Certified Nursing Aide/Resident Assitant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "SNF - Certified Nursing Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Director of Health Information",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Director of Clinical Reimbursement",
            "iamRoleName": "Accounting/finance staff"
        },
        {
            "position": "Director of Health & Wellness",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Assistant Director Of Clinical Services",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Assistant Director, Nursing",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "RN - MDS Nurse",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "LVN SNF Treatment ",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "PC Certified Nursing Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "LVN(external community)",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Director of Human Resources",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "Director of Wellness LPN",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "*LVN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "*Admin Limited - Read Only",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "Assistant Director of Resident Care ",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "*Memory Care Director",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Assistant Director of Nursing - RN",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Alzheimer Care Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Therapy Services Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "R.N.",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "LPN, MDS",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Director/Asst Dir/Mgr of Recreation",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Director of Social Work",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Activity Director ",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Rehabilitation Director/DOR",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "*Administrative Assistant",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "Certified Nursing Assistance ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "RN - Director of Nursing",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Treatment Nurse LVN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Certified Nursing Assistant (AL)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "SL LPN/LVN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "MDS Coordinator (RN)",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "MDS Coordinator -RN",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Certified Nurses Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Wellness Nurse-LVN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "MDS Coordinator - RN",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Certified Nursing Aide/TMA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Nursing Aide 8",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Lead Certified Nurse Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Nurse Aide SNF",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "CNA - Certified Nursing Aide/Asst.",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "RN, MDS Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "LPN,MDS Coordinator",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "MDS Coordinator/RN",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "MDS Coordinator - LPN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "EGM-Certified Nursing Aide/Personal Care Attendant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "*Certified Nursing Assistant (CNA) ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "RN-MDS",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "LPN MDS Coordinator",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "LPN - MDS Coordinator",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Nursing - MDS Specialist LPN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "MDS - LPN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "LPN/LVN -Licensed Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Resident Assessment MDS LVN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "LPN/LVN (Agency)",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Staff Development Coordinator LPN/LVN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Nursing Supervisor (LVN)",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Certified Medication Aide/CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "MDS Nurse-LPN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "*Admin Assistant",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "Certified Nurse Aide Agency",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Nursing Aide - AL",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Temporary Certified Nursing Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "LVN/Wellness Nurse",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "RN/MDS Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Restorative Certified Nursing Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "TMA/Certified Nursing Asst.",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "MSM LVN Nursing ",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "*Administrative Clerk",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "*Certified Nursing Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "RNC-MDS Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Treatment Nurse (LVN)",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "MDS COORDINATOR-RN",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "MDS Registered Nurse",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "*ST/Nursing/NURSES AIDE CERTIFIED",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Registered Nurse: MDS",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "RN- MDS Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Senior Certified Nursing Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "RN MDS Nurse",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Licensed Practical Nurse/LVN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Nurse Aide - Certified",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "QA Nurse (LVN)",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "MDS/LPN Coordinator - FT 1st",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Hospice Certified Nursing Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Nursing Aide Agency",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Assistant Director of Nursing - LVN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Certified nursing aide ( ALF )",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Nursing Aide/Restorative Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "*Administrative Assitant",
            "iamRoleName": "Business/operations staff"
        },
        {
            "position": "Clinical Case Manager LPN/LVN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Certified Nursing Aide II",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Resident Services Director LVN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "LVN-MDS Nurse",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "MDS Coord/LVN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "MDS Coordinator - LVN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },        
        {
            "position": "Certified Nursing Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Licensed Practical Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Registered Nurse",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Certified Nursing Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "C.N.A.",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Physical Therapist",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Occupational Therapist",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Licensed Vocational Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Nursing Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Medication Aide/Tech",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "HCA/PSW",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Speech Therapist",
            "iamRoleName": "Speech/language pathologist"
        },
        {
            "position": "Pharmacist",
            "iamRoleName": "Pharmacist"
        },
        {
            "position": "HCA/PSW/RCA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "STNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Social Worker",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "Receptionist",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Activities Aide",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "MDS Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Physical Therapy Assistant",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "Business Office Manager",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Charge Nurse",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Dietary aide",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Director of Nursing",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Medical Records",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "LPN/LVN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Activities Director",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "State Tested Nursing Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Registered Practical Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Personal Support Worker ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Surveyor",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "CNA/GNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "PSW/HCA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Physician Assistant",
            "iamRoleName": "Physician Assistant"
        },
        {
            "position": "Respiratory Therapist",
            "iamRoleName": "Respiratory Therapist"
        },
        {
            "position": "Care Manager",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "RPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Accounts Receivable",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Certified Nurses Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Admin Assistant",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Personal Support Worker",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "IT",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "Resident Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Restorative Nursing Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "PSW",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Accountant",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Admissions Director",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "Dietary",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Assistant Director of Nursing",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Care Giver",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Registered/Licensed Practical Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Certified Nursing Aide/STNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Social Services",
            "iamRoleName": "Other social worker"
        },
        {
            "position": "Nurse Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Dietary Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "CNA/STNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Medication Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Agency CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Medication Aide/Tech",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Caregiver",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Admissions Co-ordinator",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "Pharmacy",
            "iamRoleName": "Pharmacist"
        },
        {
            "position": "LPN Unit Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Health Care Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "(NA) Nursing Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Business Office",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "State Tested Nursing Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Clinical Consultant",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "C. N. A. ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Registered Nurse (RN)",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "STNA/CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Executive Director",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Certified Nursing Aide (CNA)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Lead Care Manager",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": " C.N.A.",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Agency LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Caregiver/Universal Worker",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Medication Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Reimbursement Specialist",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Medical Director",
            "iamRoleName": "Medical Director"
        },
        {
            "position": "Registered Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "RN Unit Nurse",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Activities Assistant",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "External Agency CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Recreation Assistant",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "HCA/RCA/PSW",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Activities",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "LPN - Licensed Practical Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Certified Occupational Therapy Assistant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "RCA/HCA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Housekeeping",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "Care Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Nursing Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Pharmacy Consultant",
            "iamRoleName": "Pharmacist"
        },
        {
            "position": "PTA",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "Personal Care Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "LVN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "GNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Maintenance",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "PCA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "CNA - Certified Nursing Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Registered Practical Nurse (RPN)",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Physical Therapy",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Life Skills Trainer",
            "iamRoleName": "Vocational service worker"
        },
        {
            "position": "Med Care Manager",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "Nursing Supervisor",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Concierge",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "OCCUPATIONAL THERAPY ASSISTANT",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Resident Assistants",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Residential Care Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "COTA",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Admissions Coordinator",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "Dining Services",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Geriatric Nursing Assistant ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Activities/Rec Therapy",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Occupational Therapy",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Unit Clerk",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "Pharmacy Technician",
            "iamRoleName": "Pharmacy technician"
        },
        {
            "position": "HCA/PCA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Health Care Aid/Assistant ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Resident Care Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "S.T.N.A.",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "RN Supervisor",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Licensed Practical Nurse (LPN)",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "A-Health Care Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Security",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "Care Assistant [UK]",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Geriatric Nursing Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": " LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Case Manager",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "Office Manager",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Care Manager/Coordinator",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "Health Care Aid",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Director of Operations",
            "iamRoleName": "Administrator"
        },
        {
            "position": "PSW/PCA/HCA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Social Services Director",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "Financial Consultant",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Physiotherapist",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Licensed Nursing Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Med Aide/Tech/Med Pass ",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Licensed Nurse (LPN/LVN)",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Resident Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Nursing Aide CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Pharmacy Assistant",
            "iamRoleName": "Pharmacy technician"
        },
        {
            "position": "Certified Nurse Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Surveyor Access",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "Resident Assistant ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "PSW*",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "LPN Med Care Manager",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "CNA/GCS/CG",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Wellness Nurse",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "RN-Director of Nursing",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "**CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Recreation Therapist",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Personal Care Aides",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Respiratory Therapy",
            "iamRoleName": "Respiratory Therapist"
        },
        {
            "position": "Nurse Manager",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "C.N.A._ Agency",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Attendant Counselor",
            "iamRoleName": "Other social worker"
        },
        {
            "position": "CNA/NAC",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Physical Therapist Assistant",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "Pharmacy Tech",
            "iamRoleName": "Pharmacy technician"
        },
        {
            "position": "Certified Nursing Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Med Tech/Med Aide/Caregiver",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Agency RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Recreation aide",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Licensed Practical Nurse ",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Dietary Supervisor",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Nursing Assistant ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "HCA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Activities ",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Pool CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Speech Language Pathologist",
            "iamRoleName": "Speech/language pathologist"
        },
        {
            "position": "CMA",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Med Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Qualified Medication Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Med Tech",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Trained/Certified Medication Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Personal Care Attendant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "PSW/HCA*",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "CNA / LNA / GNAS",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "RN - Registered Nurse",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "State Surveyor",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "Student Practical Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Personal Care Associate",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "NAC",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "NA/R",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "RCA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "ADON",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "HCA/PSW/RCA - Agency",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Dietary ",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Health & Wellness Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Resident Care Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "*CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Personal Care Provider",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Resident Attendant/Health Care Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "*Certified Nursing Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Physiotherapy Assistant",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "*RPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "PSW student",
            "iamRoleName": "Nurse Aide in Training"
        },
        {
            "position": "Nurse Supervisor",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "PSYCHOLOGIST",
            "iamRoleName": "Mental health service worker"
        },
        {
            "position": "Continuing Care Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Nursing - CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Chaplain",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Activities Aide/Assistant",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Licensed PT Assistant",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "State Tested Nurse Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "NAR",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Resident Care Associate",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Licensed Vocational/Practical Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Ward Clerk",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "*RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Home Health Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Speech Therapy",
            "iamRoleName": "Speech/language pathologist"
        },
        {
            "position": "Controller",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Chief Financial Officer",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Agency Care Manager",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "LPN/RPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "ITS",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "Certified Nursing Assisstant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "CNA (Agency) Certified Nurse Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Recreation",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "*Care Manager",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "Agency Certified Nursing Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Senior Care Assistant [UK]",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Registered Physical Therapist",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "MDS Coordinator RN",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "MDS Nurse",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Unit Secretary",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "Chief Executive Officer",
            "iamRoleName": "Administrator"
        },
        {
            "position": "RPN Student",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Occupational Therapist Assistant ",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Medication Tech",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Nursing - STNA/CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Nursing Aide/Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Registered Occ Therapist",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Activity Aide",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Admissions",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Certified Nursing Assistant ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "State Tested Nurse Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Marketing",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Director of Staff Development",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Cert Occupation Therap Assist",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Business Office Assistant",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Pool Staff - CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "NAR - External",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Admissions ",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Resident Associate",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Licensed Practical Nurse*",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Certified Dietary Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Human Resources",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Nursing Unit Manager",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Youth Care Worker",
            "iamRoleName": "Other social worker"
        },
        {
            "position": "Social Service Designee",
            "iamRoleName": "Other social worker"
        },
        {
            "position": "Registered Nurse ",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Cert. Occupation Therapy Asst",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "CNA - Agency",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Registered Nurse",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Central Supply",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "**LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Nursing - RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Certified Nursing Assistant / Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "*Agency-CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "ARNP",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Resident Care Manager",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "Social Service Director",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "Doctor",
            "iamRoleName": "Physician"
        },
        {
            "position": "External Agency LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "CNA/NA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Nursing Aide(CORP)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": " RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Patient Care Technician",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Social Services Assistant",
            "iamRoleName": "Other social worker"
        },
        {
            "position": "*Nursing - CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Director of Nursing Services",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Registered Speech Therapist",
            "iamRoleName": "Speech/language pathologist"
        },
        {
            "position": "Food Services Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Geriatric Nursing Assistant (GNA)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Agency-CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Office/Clerical",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "RAI Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "MD",
            "iamRoleName": "Physician"
        },
        {
            "position": "MDS",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Activities Coordinator",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Wound Care Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Licensed Practical Nurse/Licensed Vocational Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Laundry",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "Licensed Nursing Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Psychiatrist",
            "iamRoleName": "Physician"
        },
        {
            "position": "Physician/NP/PA",
            "iamRoleName": "Physician"
        },
        {
            "position": "Care Giver WI",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "**RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Administrative Assistant",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Nursing CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Geriatric Nursing Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Life Enrichment Manager",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Reminiscence Care Assistant [UK]",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Executive Director/Ops/CIT",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Cook",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Agency Med Tech/Med Pass",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Dietician",
            "iamRoleName": "Dietician"
        },
        {
            "position": "LNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Health Care Aid/Personal Support Worker",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Assistant Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "*Medication Care Manager",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Chief Operating Officer",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Health Care Aide/PSW",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Pharmacy staff",
            "iamRoleName": "Pharmacy technician"
        },
        {
            "position": "Music Therapist",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Certified Nursing Assistant SNF",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Medication Associate",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Med-Tech",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "External Agency RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Executive Director I",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Director of Clinical Services",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Licensed Practical Nurse(Staff Nurse)",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "A-Licensed Practical Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Pharmacy Rep",
            "iamRoleName": "Pharmacy technician"
        },
        {
            "position": "Registered Dietician",
            "iamRoleName": "Dietician"
        },
        {
            "position": "CCA / PCW",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "R.P.N",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Restorative Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Director of Sales",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Social Services/Worker",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "Staff Development",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "RN MDS Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Restorative CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Dietary Assistant",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Administration",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Licensed Practical Nurse SNF",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Business Office Director",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Personal Care Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "CMA/CMT ",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Resident Care Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Business Office Coordinator",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "*Wellness Nurse",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "CNA Student",
            "iamRoleName": "Nurse Aide in Training"
        },
        {
            "position": " Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "Unit Manager RN",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Medical Provider",
            "iamRoleName": "Physician"
        },
        {
            "position": "Med Tech/Aides ",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Nursing Assistant Certified",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "LVN/ LPN Village",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "L.N.A.",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Life Enrichment Assistant",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Unit Manager/Nurse Manager",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Medication Technician",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Agency-PSW",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Medical Records Assistant",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "MDS Coordinator/Nurse",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "*Registered Nurse",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "HCA/PSW/RCA - Contract",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Wellness Director",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Health Care Aide - LTC",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Nutrition Services Manager",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Home Health Aide/Caregiver",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "R.N",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Occupational Therapist Assistant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Accounting Clerk",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Food Service Supervisor",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Billing & Collections ",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "CP Medication Tech/QMAP",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Licensed Nurse (LN)",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "CNA/NAR",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Care Attendant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Agency Licensed Practical Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "MEDICAL RESIDENT",
            "iamRoleName": "Physician"
        },
        {
            "position": "Billing Specialist",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Pool Staff - LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Office Manager/Bookkeeper/Admin.Asst.",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "LPN (Agency)",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Clinical Care Coordinator",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Attending Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "Dietary Director",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Life Enrichment Aide",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Resident Care Aid",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Dietary staff",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "LPN.",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Registerd Nurse Supervisor",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "*Licensed Practical Nurse",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Hospice RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Student (RN program)",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Medtech",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Consultant Pharmacist",
            "iamRoleName": "Pharmacist"
        },
        {
            "position": "Accounts Payable",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "RN Student",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "CCA/PSW",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "ADOC",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Recreation Manager",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Occupational Therapy Assis ",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "G.N.A",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Compliance Advisor (MOH)",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "DNS",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Registered Dietitian ",
            "iamRoleName": "Dietician"
        },
        {
            "position": "RCA - Resident Care Aid",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Student LPN/RN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "DOC",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Wellness Associate CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Housekeeper",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "Certified Occupational Therapist Assistant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Charge Nurse LPN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Resident Attendant/Memory Care Attendant/RCP",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Student HCA",
            "iamRoleName": "Nurse Aide in Training"
        },
        {
            "position": "Marketing Director",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Resident Care Associates ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Recreation Therapy Assistant",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Licensed Practical Nurse LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Student Nurse Aide",
            "iamRoleName": "Nurse Aide in Training"
        },
        {
            "position": "Resident Services Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Food Service Director",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Life Enrichment",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Health Care Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "RN - External",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Medical Records Director",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "C.N.A. (Agency)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Nursing Assistant Registered",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Activities Staff",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Dentist",
            "iamRoleName": "Dentist"
        },
        {
            "position": "Social Service Assistant",
            "iamRoleName": "Other social worker"
        },
        {
            "position": "Food Services Supervisor",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Patient Care Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Temporary Nursing Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "N.A.R.",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "LPN - External",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Recreation Services",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Administrator / ED",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Assistant Business Office Manager",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Caregiver/CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Business Office Manager BOM",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Floor Nurse-LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Reimbursement",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Agency STNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Nursing - LPN & LVN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Care Partner I (CNA/PCA)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "MDS ",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Agency-RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "RPN - Unit Supervisor",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Registered/Licensed Practical Nurse - Contract",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Recreation Director",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Licensed Vocational Nurse SNF",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Med Admin",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Regional Director of Operations",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Chart Reviewer",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "Vendor-Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "Registered Nurse RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Medical Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Registered Care Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "MDS Case Manager",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Home Health CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "NA Student",
            "iamRoleName": "Nurse Aide in Training"
        },
        {
            "position": "*Certified Medication Aide/Tech",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Temporary Nurse Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "CP Resident Assist/Care Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Life Enrichment Coordinator",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Director of Nursing-DON",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Podiatrist",
            "iamRoleName": "Podiatrist"
        },
        {
            "position": "MDS RN",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Physician ",
            "iamRoleName": "Physician"
        },
        {
            "position": "Nursing Aid (AC-ICF)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Registered Practical Nurse (RPN) - Agency",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Nursing - LPN/LVN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Data Technician",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "Certified Residential Medication Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Life Enrichment Director",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Wellness Nurse,LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "CNA/TMA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Unit Manager LPN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Director of Social Services",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "PSW ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Wellness LPN/LVN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Staffing Coordinator",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Wellness Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Recreationist",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Social Services Designee",
            "iamRoleName": "Other social worker"
        },
        {
            "position": "C.M.A.",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Life Redesign Coach",
            "iamRoleName": "Vocational service worker"
        },
        {
            "position": "Clinical Coordinator",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Certified Medication Aide/Tech (eMAR)",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "CRMA",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Auditor",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "A-Registered Nurse/Registered Psychiatric Nurse ",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "HCA/PSW/RCA - Student",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Registered Nurse*",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Nursing - CNA (Agency)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Assistant DNS",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Best Friend",
            "iamRoleName": "Resident or representative"
        },
        {
            "position": "Advanced Practice Nurse ",
            "iamRoleName": "Clinical Nurse Specialist"
        },
        {
            "position": "Nurse Practitioner (Physician)",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Social Services Staff",
            "iamRoleName": "Other social worker"
        },
        {
            "position": "IT Resource",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "MDS RCA/ALS Nurse",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Restorative C.N.A.",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "MDS/PPS Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Information Technology",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "Finance",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Registered Nurse - Contract",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Resident Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "LPN Unit Care Coordinator",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Vendor-ARNP",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Activities Dir - Non Rec Ther",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Bookkeeper",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Occupational Therapist ",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Personal Care Worker",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Activity Assistant",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "PSW - Agency",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Restorative",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "MD / NP / PA",
            "iamRoleName": "Physician"
        },
        {
            "position": "Medication Tech/Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "NA- Nursing Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "State Registered Nursing Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "PSW-LTC",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "*Qualified Medication Aide(QMA)",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Registered Nurse/LTC",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Home Health Aid",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Housekeeping Aide",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "Dietary Department",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Certified Nursing Aide SNF",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Personal Care Assistant (Agency) ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Dining Room Assistant [UK]",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Graduate NA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "N.A.C.",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Pharmacy Technician ",
            "iamRoleName": "Pharmacy technician"
        },
        {
            "position": "Trained Medication Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Restorative Nursing Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Medication Aide CMA",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Activity Director",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "RN.",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Health care Aide/Personal Support Worker",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Nurse Practioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Recreation/Activity/Activation/LE Assistant/Aide",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "*Executive Director",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Agency PSW",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "C.M.A",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "PCW-Personal Care Worker ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Physical Therapy Assistant (PTA)",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "MDS Coordinator/Resident Care Manager",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "MDS LPN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "CP Cook/Prep Cook/Sous Chef",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "LPN-agency",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Surveyor ",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Occupational Therapist",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "MDS Coordinator LVN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Nursing LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Licensed Nurses Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Vendor-Physical Therapist",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Social Services ",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "Stated Tested Nurses Aide(Barn)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "*Personal Support Worker ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Licensed Practial Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "RNAC",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Hospice Social Worker",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "Resident Aide - MedPass",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "CMT",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Registered Nurse (Agency)",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Hospice Registered Nurse",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Licensed Practical Nurse - Agency",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "MEDICAL DOCTOR",
            "iamRoleName": "Physician"
        },
        {
            "position": "State Tested Nurse Aides",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Respiratory",
            "iamRoleName": "Respiratory Therapist"
        },
        {
            "position": "Agency-LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Occupational Therapist-Registered",
            "iamRoleName": "Occupational Therapist"
        },
        {
            "position": "Therapy - Occupational",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "CNA - Agency/Hospice",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Speech/Language Pathologist",
            "iamRoleName": "Speech/language pathologist"
        },
        {
            "position": "Certified Medication Tech",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "LPN Nurse Supervisor",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "**Physical Therapy ",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Agency Certified Nursing Aide/STNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Speech Pathologist",
            "iamRoleName": "Speech/language pathologist"
        },
        {
            "position": "DON",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Resident Care Worker",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "*Certified Nursing Assistant (CNA)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Life Skill Tech",
            "iamRoleName": "Vocational service worker"
        },
        {
            "position": "C.N.A.-agency",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "RN Staff Dev Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Therapy - Physical",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Medical Records ",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "Vendor-Surveyor",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "Physical Therapist",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Certified Occ Therapy Assistant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Outside Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "NA - Nursing Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "ADNS",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "MDS/Care Plan Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Health Care Aide ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": " PSW/HCA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Registered Nurse SNF",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Recreation Programmer",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Registered Nurse (RN) - Agency",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Health Care Assistant ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "LPN MDS Nurse",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "HCA/PSW*",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Nurse Aide Trainee",
            "iamRoleName": "Nurse Aide in Training"
        },
        {
            "position": "Corporate IT",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "DDCO / DNS",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "DON/ADON/DSD/SUPERVISOR",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Admissions Director Non-Nurse",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "GN-CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Registered Dietitian (RD)",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Activities Department",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Compliance Advisor",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "Unit Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Nurse Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Charge Nurse ",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Certified Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Administrative Assistant/Receptionist",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Certified Nursing Aide - Agency",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Personal Support Worker 1",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Billing",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Admin Clerk/Receptionist",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "RA/Med Tech",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "RN Unit Care Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Contracted Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Physical Therapy Aide",
            "iamRoleName": "Physical therapy aide"
        },
        {
            "position": "*Caregiver/Universal Worker",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Nursing Asst",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Registered Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Nursing - Nurse Practitioner (External)",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "**Occupational Therapy",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Pharmacy-Data Tech",
            "iamRoleName": "Pharmacy technician"
        },
        {
            "position": "Executive Director II",
            "iamRoleName": "Administrator"
        },
        {
            "position": "BKD Community Biller",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "**Activities",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Pharmacist Consultant",
            "iamRoleName": "Pharmacist"
        },
        {
            "position": "Certified Medication Tech/CNA",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "RN-DON",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Living Partner ",
            "iamRoleName": "Resident or representative"
        },
        {
            "position": "Advanced Practice Registered Nurse",
            "iamRoleName": "Clinical Nurse Specialist"
        },
        {
            "position": "Mental Health Worker",
            "iamRoleName": "Mental health service worker"
        },
        {
            "position": "**Nurse Tech/CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Cook.",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "STNA (Corporate)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "PCA ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Dietary/Food Service Manager/Supervisor",
            "iamRoleName": "Dietician"
        },
        {
            "position": "HHA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Physiotherapist Assistant",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "Director of Clinical Services, RN",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "CP Certified Nursing Asst CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Biller",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "LPN STUDENT",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Admission/Unit/Ward Clerk",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Outside Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "Med Aide/Tech/Med Pass",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Food Srvc Dir - Cert Diet Mgr",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Registered Professional Nurse ",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Medical Records Supervisor",
            "iamRoleName": "Healthcare services staff"
        },
        {
            "position": "Certified Nurse Assistant ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Respiratory Therapist",
            "iamRoleName": "Respiratory therapist"
        },
        {
            "position": "C.N.A",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Medications Technician [UK]",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Wellness Nurse,RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "*Agency-LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Resident Services Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Nursing Aide - CSU",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "RAI-MDS Coordinator",
            "iamRoleName": "Registered Nurse with administrative duties"
        },
        {
            "position": "ADON (RN)",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "RNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Pool Staff - RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Dietary Mgr",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Agency Nurse - LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "MDS/RAI Coordinator",
            "iamRoleName": "Registered Nurse with administrative duties"
        },
        {
            "position": " Physical Therapist",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Nursing Service Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Wellness Nurse [UK]",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Licensed Nursing Aide (LNA)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "RN Unit Manager",
            "iamRoleName": "Registered Nurse with administrative duties"
        },
        {
            "position": "Graduate Practical Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Physiotherapy Aide",
            "iamRoleName": "Physical therapy aide"
        },
        {
            "position": "Nursing Supervisor-RN",
            "iamRoleName": "Registered Nurse with administrative duties"
        },
        {
            "position": "Food Service Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "RCA/Health Care Assistant ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "*CRMA",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Geriatric Tech",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Identity Access Mgmt",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "Qualified Medications Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "OT Assistant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Speech-Language Pathologist",
            "iamRoleName": "Speech/language pathologist"
        },
        {
            "position": "Speech & Language Pathologist",
            "iamRoleName": "Speech/language pathologist"
        },
        {
            "position": "SL Caregiver",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "MD - Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": " Occupational Therapist",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Speech/Language Pathologist",
            "iamRoleName": "Speech/language pathologist"
        },
        {
            "position": "RA Medication Technician",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "State Tested Nurses Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "CP Resident Care Nurse LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Certified Nuring Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Omnicare Consultant Pharmacist",
            "iamRoleName": "Pharmacist"
        },
        {
            "position": "Assistant Director of Nursing, RN",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Diet Tech",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Conservator",
            "iamRoleName": "Resident or representative"
        },
        {
            "position": "Health Care Aide Care Partner ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Wellness Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "QMA/CMA",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "ASSISTANT CONTROLLER",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "RN - Unit Supervisor",
            "iamRoleName": "Registered Nurse with administrative duties"
        },
        {
            "position": "Resident Service Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Student PSW",
            "iamRoleName": "Nurse Aide in Training"
        },
        {
            "position": "Hospice CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Behavior Specialist",
            "iamRoleName": "Mental health service worker"
        },
        {
            "position": "Advanced Registered Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "EXT Surveyor",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "EITS Support",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "RN DON",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "**Registered Nurse",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": " Speech Therapist",
            "iamRoleName": "Speech/language pathologist"
        },
        {
            "position": "Licensed Nurse w/add''l duty",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Recreation Worker",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Physiotherapist - Contract",
            "iamRoleName": "Physical Therapist"
        },
        {
            "position": "Counselor",
            "iamRoleName": "Other social worker"
        },
        {
            "position": "Activities Assistant [UK]",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Caregiver/Care Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Food Services Director",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Certified Nursing Assistance",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "MDS Coordinator LPN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Dietary Services",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "*Dining Services Limited - Read Only",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "ALF DON.",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Secretary",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Admissions & Marketing",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Licensed Vocational Nurse - Registry",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "CMA/Supervisor",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": " PTA",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "Nursing Supervisor-LPN-LVN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Respiratory Therapist  ",
            "iamRoleName": "Respiratory therapist"
        },
        {
            "position": "LPN - ALF",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Nursing - DON",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Business Manager",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Corporate Accounts Receivable",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Resident Attendant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "PSW +++",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified / Trained MedAide / MedTech / QMAP",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Health Care Aid: Nsg",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Agency Certified Nursing Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Registered Practical Nurse ",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "RN Asst Dir of Nursing-ADON",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Resident Care Aide (AL)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Registered Medication Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Central Supply Director",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "Resident Care Coord - RN",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Nurse Manager/MDS Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Personal Attendant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "RN - Agency",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Administrator/ED/GM/AED",
            "iamRoleName": "Administrator"
        },
        {
            "position": "LPN Supervisor",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Nurse Practitioner (NP)",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Survey",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "Recreational Therapist",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Certified Medication Tech/C.N.A",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "PSA (Personal Service Assistant)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "CHARGE NURSE (LPN)",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Certified Medication Aide / Tech",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "CMT - Certified Med Tech",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Psych Services",
            "iamRoleName": "Mental health service worker"
        },
        {
            "position": "RN-MDS Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": " Receptionist",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Accounting Assistant",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Med Tech (AL)",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Crandall Corporate Dietitians",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietetic Intern",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Medical Aide - ALF",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Nurse Practitioner, ARNP",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "PCA (Personal Care Attendant)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "BOCES Student (LPN)",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Social Services Supervisor",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "LPN Charge Nurse",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Pharmacy Medical Records",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Registered Nurse Agency",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Director of Nursing/Nurse Manager",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Certified Med Aide (Agency) CMA",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Reminiscence Medications Technician [UK]",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Rec Assistant",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Activities Supervisor",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Dietary Service Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "RN/MDS/Unit Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "CEO",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Payroll",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Physiotherapist (PT)",
            "iamRoleName": "Physical Therapist"
        },
        {
            "position": "PSW Agency Staff",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": " COTA",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "MDS Consultant",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Social Services Coordinator",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "Chiropodist",
            "iamRoleName": "Podiatrist"
        },
        {
            "position": "Agency Registered Nurse",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Nurses Aide Certified",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "CP Housekeeper",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "License Practical Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Nutrition Services Director",
            "iamRoleName": "Dietician"
        },
        {
            "position": "SOCIAL WORK",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "Financial Analyst",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Unit Manager - RN",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "License Nurse Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "ADOC ",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Registered Nurse Supervisor",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Health Care Aide/Personal Care Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Unit Manager (RN)",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "PT Assistant",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "Food Service Worker",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Recreation Therapy Aide",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "General Manager",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Clinical Nurse Specialist",
            "iamRoleName": "Clinical Nurse Specialist"
        },
        {
            "position": "Medication Assistant",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "CNA (AC-NF)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "CNA (Nursing)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": " Restorative Nursing Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Administration BOM",
            "iamRoleName": "Administrator"
        },
        {
            "position": "*Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "Certified Nursing Assistant*",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "**Licensed Practical Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Director",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Physiotherapy Aide/Assistant (PTA)",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "Personal Care Worker ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "PT",
            "iamRoleName": "Physical Therapist"
        },
        {
            "position": "Certified Medication Aide/Tech/QMAP",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Administrator in Training",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Health Care Assistant (HCA)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Charge Nurse RN",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Nursing Asst Certified ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Assistant BOM",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Certified Nursing Aide - Maxim",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Nursing RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": " Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Personal Support Workers",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Accounts Receivable - APR",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Certified Nursing Aide (Agency)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Personal Support Worker/Health Care Aides ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "PSW Temporary",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Resident Care Aide ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Student Nurse (RN program)",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Business Office, Other",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Activities C.N.A.",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Personal Support Specialist",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Medication Tech (ALF)",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Home Health Aide 2",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Activities Dir/Rec Therapist",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Health Care Aide/Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Personal Support Worker  ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Account Receivable Resource",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Nurses Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Clinical Pharmacist",
            "iamRoleName": "Pharmacist"
        },
        {
            "position": "DON/ADON",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Therapy - Speech",
            "iamRoleName": "Speech/language pathologist"
        },
        {
            "position": "Social Service Department",
            "iamRoleName": "Other social worker"
        },
        {
            "position": "Vendor-Physical Therapy Assistant",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "Health Care Aide (HCA)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Dietitian/Food Srv Dir/Dietetic Tech",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dining Services Director",
            "iamRoleName": "Dietician"
        },
        {
            "position": "RPN ",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "RN-Supervisor",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Certified Nurse Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Business Office Manager (BOM)",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Physio Assistant",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "Social Services Worker",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": " MDS Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Assistant Director of Nursing ",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Psychiatric Rehab Services Coordinator",
            "iamRoleName": "Mental health service worker"
        },
        {
            "position": "Licensed Practical Nurse Care Partner ",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Licensed Practical Nurse/LTC",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "PSW-Unit Dining Room",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "*Receptionist",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Admin Assistant/Receptionist",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Certified Caregiver",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "ALF Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "PCA Patient Care Attendant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Health and Wellness Director",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "LPN Treatment Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Medical Records Consultant",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Activities Personnel",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Certified Residential Medication Aide - CRMA",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Director of Dietary Services",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Director of Nursing (DON)",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Culinary/Nutrition",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Marketing Coordinator",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "BSO PSW",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Nursing - LPN/LVN (Agency)",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Reg Practical Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Therapeutic Recreationists",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "SL CMA/Universal Worker",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Floor RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "CCA - Continuing Care Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Laundry Aide",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "Personal Care Attendant - PCA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Personal Care Assistant/Medication Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Dietitian (RD, LD)",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Director of Nursing ",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Med. Tech.",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "State Tested Nursing Aide (RC)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Float Team CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Social Worker/Designee ",
            "iamRoleName": "Other social worker"
        },
        {
            "position": "Physician Services",
            "iamRoleName": "Physician"
        },
        {
            "position": "Resident Assessment MDS RN ",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Billing Specialist ",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "LPN Unit Manager",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "RN-ADON",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "HCA/PSW ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "LPN - Agency/Hospice",
            "iamRoleName": "Licensed Practical/Vocational Nurse"
        },
        {
            "position": "Food Srvc Dir - Other",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Medical Records/HIM",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "CQC Inspector [UK]",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "Unit Manager (LPN)",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "MDS Coordinator LPN/LVN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "IT Specialist",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "LVN- Case Mix Manager",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "CNA Special Care Unit",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "CNA(Lodge/Grove/Village)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "IT Staff",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "LPN-MDS Nurse",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Dietary Cook",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Licensed Practical Nurse Student",
            "iamRoleName": "Licensed Practical/Vocational Nurse"
        },
        {
            "position": "Recreation coordinator",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Assisted Living Director",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Registered Dietician (Contract)",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Geriatric Nurse Practioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Accounting",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Resident / Feeding Assistant",
            "iamRoleName": "Feeding assistant"
        },
        {
            "position": "Director of Medical Records",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": " Surveyor",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "STNA (AGENCY)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "CRC / MDS Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Nurse Aide In Training",
            "iamRoleName": "Nurse Aide in Training"
        },
        {
            "position": "Hospice: RN",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Director of Finance",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Speech Language Patholigist",
            "iamRoleName": "Speech/language pathologist"
        },
        {
            "position": "ARNP*",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "*Registered Practical Nurse",
            "iamRoleName": "Licensed Practical/Vocational Nurse"
        },
        {
            "position": "Diet Technician",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "AL Certified Medication Aide/Tech",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Dietary Consultant",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Social Service Consultant",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "Restorative Care Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Licensed Practical Nurse(LPN)",
            "iamRoleName": "Licensed Practical/Vocational Nurse"
        },
        {
            "position": "Finance ",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "CC-Pharmacy Assistant",
            "iamRoleName": "Pharmacy technician"
        },
        {
            "position": "Activity  Department",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Dining Services Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Health Care Aide/Assistant ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Unit Manager - LPN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "*Medication Tech",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "ARNP/NP",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "ACTIVITES",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Qualified Medication Assistant",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Aides",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Nursing Aide- Agency",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Registered Psychiatric Nurse",
            "iamRoleName": "Mental health service worker"
        },
        {
            "position": "Environmental Services Mgr",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "Financial Specialist",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Personal Care Aid",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Advance Practice Registered Nurse",
            "iamRoleName": "Clinical Nurse Specialist"
        },
        {
            "position": "Surveyors",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "Nursing - RN (Agency)",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Accounting Manager",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Recreation Services Assistant",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Geriatric Nursing Assistant Agency",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Occupational TA",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Restorative Care Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "RAI Coord Back-up",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Social Service",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "Licensed Practical Nurse Agency",
            "iamRoleName": "Licensed Practical/Vocational Nurse"
        },
        {
            "position": "Activity Coordinator",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "CMA - Certified Medication Assistant",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Staff Accountant",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "DOH Surveyor",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "MDS Coordinator/RNAC",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Receptionist [UK-GW]",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Certified Residential Med Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "MDS Coord",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Nutrition Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "IT Helpdesk",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "Administrator (NHA)",
            "iamRoleName": "Administrator"
        },
        {
            "position": "RN Charge Nurse",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": " Dietary Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "LHRC CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": " ARNP",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "*Director of Nursing",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "MDS LVN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Physician*",
            "iamRoleName": "Physician"
        },
        {
            "position": "Remedi Pharmacy",
            "iamRoleName": "Physician"
        },
        {
            "position": "RPN - Agency",
            "iamRoleName": "Licensed Practical/Vocational Nurse"
        },
        {
            "position": "ISDH Surveyor",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "Licensed Psych Tech",
            "iamRoleName": "Mental health service worker"
        },
        {
            "position": "*Agency-RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Dietary Aide/Cook",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Agency Nurse- LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Non-Employee Access: Billers/Coders/Pharmacy",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Physio Therapist",
            "iamRoleName": "Physical Therapist"
        },
        {
            "position": "Case Mix Auditor",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "Certified Nursing Aide 12",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Nursing Assistant (CNA)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "RCA/PSW",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Licensed Social Worker",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "Director of Food Services",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietary Server",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Agency - LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Weekend RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Concierge / Receptionist",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Staffing LVN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "ACC Certified Nursing Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Administration Payroll",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "*Personal Care Aides",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Licenced Vocational Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Registered Practical Nurse (ASK4CARE)",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Resident Assessment Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Staff Nurse (LPN)",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "EL Nursing Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Therapy-Speech & Language Pathologist",
            "iamRoleName": "Speech/language pathologist"
        },
        {
            "position": "Medical Records Staff",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Clinical Administrators",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Activity Director.",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Medical Records - Staff",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Recreation ",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "*Wellness Director",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Practical Nursing Student",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "RN ADON",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Med Tech/Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Graduate LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Nurse/CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Trained Medication Assistant",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Nutrition Service Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Medication Aides",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Dietary Aide/tech",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Student Medication Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Registered Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": " Activities Assistant",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Registered Dietitian - Contract",
            "iamRoleName": "Dietician"
        },
        {
            "position": "RN Nurse Manager",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Dietary Services Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": " Physician Assistant",
            "iamRoleName": "Physician Assistant"
        },
        {
            "position": "Case Manager RN",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Agency LPN/LVN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "*Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Director of Wellness",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Dietary Services(Contractor)",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Activity Aide/Program Assistant",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Activities Leader",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "IT Support Center Staff",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "Physician''s Office",
            "iamRoleName": "Physician  "
        },
        {
            "position": "Dietary Tech",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Clinical Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Reception",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Therapy-Occupational Therapist",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Dietary_Tech_Cook",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "CNA/LNA/GNAS",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Nursing - ADON",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Registered Respiratory Therapist",
            "iamRoleName": "Respiratory Therapist"
        },
        {
            "position": "Executive Director AL",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Geriatric Nursing Aid",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Medication Aide/Shift Sup",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Optum CRNP",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "**Dietitian/Diet Tech",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Silverdale Licensed Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Assistant Dietary Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Registered Nurse - Hospice",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "*Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "LPN (Nursing)",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Dietary Manager.",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Office Receptionist",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "PSW / HCA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Nursing Assistant SNF",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Direct Care Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Regional Director",
            "iamRoleName": "Administrator"
        },
        {
            "position": "DON/Nurse Manager",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Registered Pharmacy Technician",
            "iamRoleName": "Pharmacy technician"
        },
        {
            "position": "LPN Trainer",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Activities Director/Coord.",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Medication Trained CNA",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Social Services Specialist",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "Floor Nurse- RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "*Resident Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": " Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Certified OT Assistant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "NA-Reg",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Licensed Vocational Nurse SAU",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Nursing Aide Trainee",
            "iamRoleName": "Nurse Aide in Training"
        },
        {
            "position": "Dietary Dir/Mgr",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietetic Technician",
            "iamRoleName": "Other service worker"
        },
        {
            "position": " Director of Nursing",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Personal Support Worker/ Health Care Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Advanced Practice Nurse",
            "iamRoleName": "Clinical Nurse Specialist"
        },
        {
            "position": "Activity Staff",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Physical Therapist(PT)",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Primary Care Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "Student - PSW",
            "iamRoleName": "Nurse Aide in Training"
        },
        {
            "position": "Dietary Manager/Supervisor",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Social Services (SS)",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "Recreational Assistant",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "**Speech Therapy",
            "iamRoleName": "Speech/language pathologist"
        },
        {
            "position": "3rd Party Auditor",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "Occupational Therapist Asst",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "O.T.",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Activities Coordinator/ Director ",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Alsa CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Dietician-Registered",
            "iamRoleName": "Dietician"
        },
        {
            "position": "RNAC ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "*Licensed Practical Nurse/LVN",
            "iamRoleName": "Licensed Practical/Vocational Nurse"
        },
        {
            "position": "Activity Department",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": " Social Services Manager",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "Registered Nursing Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Nursing Aide(NAC)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Staff Developer RN",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "CBC Dietary Server",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "LPN Agency",
            "iamRoleName": "Licensed Practical/Vocational Nurse"
        },
        {
            "position": " ADON/SDC",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "RN Manager",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": " RN Student Nurse",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Certified Medication Aide/ Tech",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Activities Assistant ",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Dietary Intern",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Licensed Practical Nurse - N",
            "iamRoleName": "Licensed Practical/Vocational Nurse"
        },
        {
            "position": "LPN Medical Records Director ",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Registered Nurse, CNT",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Nurse Supervisor RN",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "LPN-ADON",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "G.N.A.",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "OT",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Geri Aides",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Activities Organiser [UK-GW]",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Vendor - Speech Therapist",
            "iamRoleName": "Speech/language pathologist"
        },
        {
            "position": "License Vocational Nurse",
            "iamRoleName": "Licensed Practical/Vocational Nurse"
        },
        {
            "position": "*SHR/Nursing/NURSES AIDE CERTIFIED",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Therapeutic Recreation Director",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Registered Nurse - Agency",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Caregiver CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Agency - CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Asst Director of Nursing ",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Therapy-Physical Therapist",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Licensed Clinical Social Worker",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "NHA/Executive Director",
            "iamRoleName": "Administrator"
        },
        {
            "position": "LPN-C",
            "iamRoleName": "Licensed Practical/Vocational Nurse"
        },
        {
            "position": "Vendor-Physician Assistant",
            "iamRoleName": "Physician Assistant"
        },
        {
            "position": "Physician Consultant",
            "iamRoleName": "Physician"
        },
        {
            "position": "Hospice Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "CMA/CMT/CNA/Nursing Aid",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Director of Nursing/ADON",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "RN ",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "CNA/PCT",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "NP",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Nurse Practitioner / PA",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "RN - Charge Nurse",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Speech Language Pathologist ",
            "iamRoleName": "Speech/language pathologist"
        },
        {
            "position": "Activities Coordinator",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Nurse/Med Tech",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "*Med Aides",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "NA/PCA/HCA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Physician, MD",
            "iamRoleName": "Physician"
        },
        {
            "position": "Registered Nurse.",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "*Activities Director",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "CHARGE NURSE (RN)",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Phyical Therapy Assistant",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "CBC Executive Director ",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Nurse Practitioner, Vitae",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Physician - Medical Director",
            "iamRoleName": "Physician"
        },
        {
            "position": "Executive Director ",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Agency - RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Occupational Assistant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Plan A PSW",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Licensed Practical Nurse (Agency)",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "PCA - Patient Care Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Occupational Therapy Assistant ",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Nursing-LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": " Social Services Assistant",
            "iamRoleName": "Other social worker"
        },
        {
            "position": "Activity Worker",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Certified Occupatonal Therapy Assistant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Community IT tech",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "*Dietary Aide",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Director of Environmental Services",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "Registered Practical Nurse (Dynamic)",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Regional Vice President",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Nurse Supervisor LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse with Administrative Duties"
        },
        {
            "position": "COTA.",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "LPN Special Care Unit Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "*Med Tech",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Activities Asst/Aide",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "LPN/RCA",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "LPT/LVN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "*Resident Assistant - Med",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Registered Practical Nurse Temporary",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "NA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Social Work Assistant",
            "iamRoleName": "Other social worker"
        },
        {
            "position": "Charge LPN (agency)",
            "iamRoleName": "Licensed Practical/ Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Activities Dir - Rec Therapist",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "RN/Supervisor",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Registered OT",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Healthcare Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "ADON/Unit Manager",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "*LPN/LVN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Physician (Consultant)",
            "iamRoleName": "Physician   "
        },
        {
            "position": "LPN-PC",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Physicians Assistant",
            "iamRoleName": "Physician Assistant"
        },
        {
            "position": "Director of Nurses",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Associate Director of Resident Care",
            "iamRoleName": "Physician Assistant"
        },
        {
            "position": "Staffing CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Medical Assistant, Ext",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "PHYSICAL THERAPY AID",
            "iamRoleName": "Physical therapy aide"
        },
        {
            "position": "Physiotherapy",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "RN/Resident Care Manager",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Licensed Practical Nurse - Contract",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Pharmacist Assistant",
            "iamRoleName": "Pharmacy technician"
        },
        {
            "position": "SL Medication Technician",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Housekeeping Assistant",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "CP Resident Care Director",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Nursing Assistant in Training",
            "iamRoleName": "Nurse aid in training"
        },
        {
            "position": "RN Apex",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "COTA/L",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Social Services Consultant",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "RSA - Resident Support Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Medication Technician ",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Patient Care Aid/Assistant ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "*Home Health RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Habilitation Plan Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "RN (Agency)",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": " Medical Director",
            "iamRoleName": "Medical Director"
        },
        {
            "position": "PTA - Physiotherapist Assistant",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "Physio Aide/Rehab Assistant",
            "iamRoleName": "Physical therapy aide"
        },
        {
            "position": "*CNA - Shahbaz",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "PPS Coordinator - RN",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Dietary Technician",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "MDS Nurse LPN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "RN Extended Class",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "RN Nurse Supervisor",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Admission Assistant",
            "iamRoleName": "Medical Director"
        },
        {
            "position": "*Medication Technician",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "CP Executive Director",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Nursing Director (DON)",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "AL Caregiver CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Activities/Recreation Aide",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Nursing Supervisor - RN",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Environmental Services Manager",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "Certified Medication Asst",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Personal Support Worker-CCC",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "COTA - Certified Occup. Ther. Asst.",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Certified Nursing Assistant Trainee",
            "iamRoleName": "Nurse aid in training"
        },
        {
            "position": "Maintenance Director",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "Pharmacy Technician/Assistant",
            "iamRoleName": "Pharmacy technician"
        },
        {
            "position": "*Physical Therapist",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Housekeeping staff",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "RN Treatment Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Student RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Information Technology (IT)",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "Licensed Vocational Nurse ",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": " Activities Manager",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "RPN - Charge Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse with Administrative Duties"
        },
        {
            "position": "TR/Activities/Rec Therapy/Life Enrichment",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Occupational Therapist (OT)",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Agency Care Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Nurse Aid",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "CP State Surveyor",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "Director of Activities",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "IT (Helpdesk Analyst)",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "CRNP",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "KPH CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "CBC Dietary Manager ",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Laundry Worker",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "Vendor - Occupational Therapist",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "LPN-MDS Coordinator",
            "iamRoleName": "Licensed Practical/ Vocational Nurse with Administrative Duties"
        },
        {
            "position": "RN Nursing Supervisor",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Housekeeping Supervisor",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "AL/MC Med Tech ",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Nursing - CRS RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "DON &/or Designee",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Executive Director III",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Licensed Practical Nurse- Agency",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "*Hospice RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Vitalyst Support Tech",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "Diet Tech Registered",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Executive",
            "iamRoleName": "Administrator"
        },
        {
            "position": "PC Med Pass Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Certified Home Health Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "IT / Systems",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "System Administrator",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "IT Manager",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "Certified Med Tech/QMAP",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "RN Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Registered Nurse",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Vendor - Occupational Therapy Assistant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "LAB",
            "iamRoleName": "Clinical laboratory service worker"
        },
        {
            "position": "Maintenance Staff",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "Director of Nursing Care/ Wellness Co-ordinator",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Dietary - Tray Card Only",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Social Worker",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "Compliance Analyst",
            "iamRoleName": "Surveryor or Audit professional"
        },
        {
            "position": "R.N.",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "RN Assessment Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Student - CNA Student",
            "iamRoleName": "Nurse aid in training"
        },
        {
            "position": "Licensed Practical Nurse - Hospice",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Unit Clerk_C.N.A.",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "PCP",
            "iamRoleName": "Physician"
        },
        {
            "position": "Agency - Registered Nurse",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "RN Special Care Unit Nurse",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "CNA - Student",
            "iamRoleName": "Nurse aid in training"
        },
        {
            "position": "RN/Nurse Practioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Maintenance Supervisor",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "Student Nurse Aide Trainee",
            "iamRoleName": "Nurse aid in training"
        },
        {
            "position": "Therapeutic Recreation Specialist",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Reg. Occupational Therapist",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Activity",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Dietitian-Registered",
            "iamRoleName": "Dietician"
        },
        {
            "position": "RN- Case Mix Manager",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Social Worker or Social Service Assistant",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "PCA/CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "MD, Telehealth",
            "iamRoleName": "Physician"
        },
        {
            "position": "TMA - Trained Medication Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Activities Manager",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "C.N.A./R.A.",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Activities Staff*",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Trainee Nurse Aide",
            "iamRoleName": "Nurse aid in training"
        },
        {
            "position": "CNA Hospice",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "RN Clinical Care Supervisor",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Primary Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "Resident Care Assistant/Med Tech",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Dietitian, Registered",
            "iamRoleName": "Dietician"
        },
        {
            "position": "PCP Agency",
            "iamRoleName": "Physician"
        },
        {
            "position": "Registry LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "CNA -Certified Nurse Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "IT Service Desk",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "REC THERAPIST",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Registered Nurse Care Partener",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Occupational Therapist - Contract",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "RN - MDS Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Pharmacist (Consultant)",
            "iamRoleName": "Pharmacist"
        },
        {
            "position": "Licenses Practical Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Inservice Educator - RN",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Woodmark Pharmacist",
            "iamRoleName": "Pharmacist"
        },
        {
            "position": "Nursing Assistant/Registered",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "President",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Hospice: RN Case Manager ",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Chief Nursing Officer",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "LPN - Agency",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "PT - Physiotherapist",
            "iamRoleName": "Physical Therapist"
        },
        {
            "position": "Administrator Assistant",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Wellness RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Dietary / Culinary Staff",
            "iamRoleName": "Dietician"
        },
        {
            "position": "MDS Coordinator/RNAC/Care Manager/Care Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Geri Tech",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Residential Care Aid/ Health Care Aide ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Recreation/Activity Manager/Supervisor",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Shahbaz-CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Facility RD (Dietician)",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Care Assistant - SNF",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "LPN Nurse Manager",
            "iamRoleName": "Licensed Practical/ Vocational Nurse with Administrative Duties"
        },
        {
            "position": "RN Case Manager",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Registered Nurse (Student)",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Advanced Nurse Practioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "RN Agency",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "RN - Agency Staff",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Dialysis - RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Caregiver CMA",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Reg Nurse Assessment Cord",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Physician''s Assistant (PA)",
            "iamRoleName": "Physician Assistant"
        },
        {
            "position": "RN - Davita",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Marketing/Admission Coordinator",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "PSW Students",
            "iamRoleName": "Nurse aid in training"
        },
        {
            "position": "TMA/Medication Aide/Tech",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Pharmacist (Medisystem)",
            "iamRoleName": "Pharmacist"
        },
        {
            "position": "Surveyor/Auditor",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "Registered PT",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "*NURSES AIDES (CNA)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Restorative LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Assistant DOR COTA",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Physician / PA / NP",
            "iamRoleName": "Physician"
        },
        {
            "position": "Recreation and Leisure",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Life Care Manager-RN",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Certified Medical Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "LPN Care Coordinator",
            "iamRoleName": "Licensed Practical/ Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Certified Nursing Aide*",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "CFO",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Surveyor/Reviewer Role",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "Vice President",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Liaison LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Personal Care Worker",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Licensed Practical Nurse (LVN)",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Clerk - Receptionist",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Registered Nurse - Student",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Rehab Assistant - Activity",
            "iamRoleName": "Other activities professional"
        },
        {
            "position": "Nursing-RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "RN - Agency/Hospice",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "RN Supervisor ",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "OTA",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "IT Help Desk",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "*Resident Care Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Registered Practical Nurse (Agency)",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "CNA - MC",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Physician - Non-LCCA",
            "iamRoleName": "Physician"
        },
        {
            "position": "Life Enrichment Associate",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Certified Occ Ther Assistant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Director of Nursing (SNF)",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Practical Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Activities Coordinator [UK]",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "RN-Nurse Manager",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "LTC - PSW",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Assistant Activities Director",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Reg. Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "*Med Pass Caregiver",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Social Worker ",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "Physicians",
            "iamRoleName": "Physician"
        },
        {
            "position": "A-Occupational Therapist",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "*Medication Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "RN - Assistant Director of Nursing",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "*IT",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "Administrator/ LNHA",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Assisted Living Supervisor",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Information Systems",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "Student - Practical Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Therapeutic Recreationist",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Wellness Nurse LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Director of  Recreation",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "LPN-Charge nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Medical Practitioner",
            "iamRoleName": "Physician"
        },
        {
            "position": "Nurse Practioner Facility",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Nursing -  Trained Medication Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Recreation /Activities Aide",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Register Nurse",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Nursing - MDS Specialist RN",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Resident Care Coord - LPN",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "C.O.T.A.",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Occupation Therapy Assistant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "RN Director of Nursing",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Social Worker/Social Services Assistant",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "Pharmacist/Pharmacy Consultant/Oth Pharmacy Emp",
            "iamRoleName": "Pharmacist"
        },
        {
            "position": "Third Eye Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "Personal Care Attendent",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Administrator/Executive Director",
            "iamRoleName": "Administrator"
        },
        {
            "position": "CC-Pharmacist",
            "iamRoleName": "Pharmacist"
        },
        {
            "position": "*Activities Aide",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Nurse Practitioner ",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Reception/Administration Clerk",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "RecTherapist",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Dietary Services Supervisor ",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Physical Therapy Director",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Activities/Rec Therapist",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Activities Specialist",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Administrator 1 [UK-GW]",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Certified Occupational Therapist Assistant ",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Operations Specialist",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "Activities Dept.",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Cook/Dietary/Food Services Aide",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Occupational Therapist",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Qualified Medication Administration Personnel ",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "CBC LPN",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Patient Accounting ",
            "iamRoleName": "Medical scribe"
        },
        {
            "position": "Certified Medication Technician",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "z_St. Francis Hospice - RN",
            "iamRoleName": "Respiratory Therapist"
        },
        {
            "position": "Foot Care Provider",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Nurse Practitioner (Alaris)",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Nutrition - Dietary",
            "iamRoleName": "Dietician"
        },
        {
            "position": "*Occupational Therapist",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Agency Medication Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Nursing - Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Administrator Facility",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Medical Records / HIM",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Intake Coordinator",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Personal Care Assistants ",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Medical Records Specialist",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Regional Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Advanced Certified Medication Assistant",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Pharmacy Technician (Reg)",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Consultant-Accounts Receivable",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Registered Care Aid",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "A-Physical Therapist",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Activity Director ",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Consultant Dietician",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Remedi",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Finance Accounting",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "RNAC (Lead)",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "RPN, Jenuine Footcare",
            "iamRoleName": "Healthcare services staff with administrative duties"
        },
        {
            "position": "Forum Billing",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "DDCA",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "Occupational Therapy - Certified Assistant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Occupational Therapy Student",
            "iamRoleName": "Occupational therapy aid"
        },
        {
            "position": "Certified Nursing Assistance ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Nurse Practitioner (Nursing)",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "House Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "*Health Services Assistants",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Activity / Life Enrichment Coordinator",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Receptionist / Admin Asst",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Occupational Therapist Registered",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Occupational Therapy Assistant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Vice President of Operations",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Contracted Dietary Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Registered Dietitian Nutritionist",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Nurse Practitioner (facility)",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "External-Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Certified Occupational Therapist",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Transportation Aid",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "RD - Registered Dietician",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Director of Dietary",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietitian Facility",
            "iamRoleName": "Dietician"
        },
        {
            "position": "*Dietary",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Pool Staff - Trained/Certified Medication Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Physician - Consulting",
            "iamRoleName": "Physician"
        },
        {
            "position": "Certified Medication Tech (CMT)",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Executive Director/Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "A-Registered Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Consulting Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Qualified Medication Aide - QMA",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Certified / Trained Medication Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Activity Manager",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Certified Registered Nurse Practitioner - Optum",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Nutrition Services Aide",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Dietary/Culinary Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Occupational Therapy Asst",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Medication Nursing Assistant ",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Diet Technician ",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Dietary Manager/Tech",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Licensed Medication Nurses Assistant",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Resident Physician ",
            "iamRoleName": "Physician"
        },
        {
            "position": "Dietary Team Lead",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Nurse Practitioner, Certified",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Activities Aide/Rec Assistant",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Home Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "3P Dietary",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Activity of Daily Living Rec Worker",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Assistant Administrator ",
            "iamRoleName": "Administrator"
        },
        {
            "position": "*Certified Medication Aid",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Physical Therapy Assistant",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "Physician (SMG)",
            "iamRoleName": "Physician"
        },
        {
            "position": "Resident Services Assistant ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "*Activities Aide/Assistant",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Physician - Resident/Fellow",
            "iamRoleName": "Physician"
        },
        {
            "position": "SL Dietary",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietary Aide",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Nurse Practitioner (Psych)",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "*Physical Therapy Assistant",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "Activity / Life Enrichment Director",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "OT - Occupational Therapist",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "External Consultant- Extendicare",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "Care Aide ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Nurse Practitioner (Daiya)",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "PC Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Physical Therapist Asst",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "Medication Aide/Resident Care Coordinator",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "PC Medication Tech",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "CBC Activity Assistant",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Occupational Therapist Reg.(Ont.) ",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Resident Care Assistant ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Medication Assistant Pool",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Activities Director Assistant",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Nurse Practitioner (Kaiser)",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Grove Coordinator",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Nurse Practitioner - Optum",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Dietary Manager Assistant",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "*Certified Nursing Assistant (CNA) ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Director of Activities ",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "ALSA Director of Nursing",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Administrator/Director of Care",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Healthcare Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Administrator ALF",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Dietary Staff*",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Registered Dietitian/Tech",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Registered Dietitian (Cons.)",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Administrator Assistant [UK-GW]",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Activities Consultant",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Regional Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Creative Art Therapy",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "TR/Activity aide",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Activity Therapist",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "*Certified Medication Tech",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Activity Assistant/Worker",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Physician Students",
            "iamRoleName": "Physician"
        },
        {
            "position": "General Manager/Administrator/Executive Director",
            "iamRoleName": "Administrator"
        },
        {
            "position": "3P Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "Facility Licensed Dietician",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Administrator*",
            "iamRoleName": "Administrator"
        },
        {
            "position": "STNA/Nursing Asst-SNF",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Therapy-Physical Therapy Assistant",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "RAI Specialist RN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Residential Support Professional",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Clinical Consultant - Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "Trained Medication Aide/CMA",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "CRMA-Certified Residential Medication Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Certified Occupational Therapists Assistant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "MTS Medication Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "ALF Medication Assistant",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Dietary aid",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Dietary Clerk",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Nursing Home Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Supervisor of Dietary Services",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietary Cooks",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Consultant Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "Dietary Manager ",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Occupational therapist,SJS",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "*Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "LE/Place Coord/Prog Mngr/Activity Director",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Consultant Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Receptionist/Res Trust/AP ",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "LMS Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Activities Therapist",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Medication Assistant Education",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Activities Tech",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Dietary (AL)",
            "iamRoleName": "Dietician"
        },
        {
            "position": "RD - Registered Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietary Director/Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Occupational Therapy Aide",
            "iamRoleName": "Occupational therapy aide"
        },
        {
            "position": "Asst Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Care Attendant ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certify Occupational Therapist Assistant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Dietitian ",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietitian/DTR",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Site Lead/Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Dietitic Intern",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Physical Therapist Assistant, PTA",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "Physician / CRNP",
            "iamRoleName": "Physician"
        },
        {
            "position": "Supportive Living Receptionist",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "CBC Arbor Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Activity Supervisor",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Agency Certified Medication Aide/Tech",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Coordinator, Memory Select",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "Dietary Aide-Clerk",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "LTC Homes Inspector",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Wardclerk",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Certified Medication Aide/CNA",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Physical Therapy Student",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Contracted Occupational Therapist",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Dietary Manager*",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Qualified Medication Administration Person",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Occupational Ther Asst",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Medication Assistant HLS",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Medication Technician (Med Tech)",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Activities/TRS Aide",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Advanced Certified Medication Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Activity Assistant Director",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Kaiser Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "Licensed Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietetic Technician, Registered",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Therapy: Physical Therapist",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "RN Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Program Specialist",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "CSW/Community Support Worker",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Dialysis - Staff",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Outside Physician''s Assistant",
            "iamRoleName": "Physician Assistant"
        },
        {
            "position": "Nurse Practitioner-Optum",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Activities Worker",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Staff Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "Business Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "*Therapeutic Recreation Aide",
            "iamRoleName": "Vocational service worker"
        },
        {
            "position": "Rehabilitation Worker",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Director of Respiratory Therapy",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "Diet Clerk",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "A/R Coach [UK]",
            "iamRoleName": "Medical scribe"
        },
        {
            "position": "Dietary Student",
            "iamRoleName": "Dietician"
        },
        {
            "position": "External CM",
            "iamRoleName": "Medical Director"
        },
        {
            "position": "Trained Medication Aide`",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Contract-Occupational Therapist",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Clinical Reimbursement",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Physician / Medical Provider",
            "iamRoleName": "Physician"
        },
        {
            "position": "Leisure Time Activities Leader",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Activities/Rec Therapy Care Partner",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Psych Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Physician Assistant ",
            "iamRoleName": "Physician Assistant"
        },
        {
            "position": "Dietary Assistant Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Activity / Life Enrichment Aide",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Physician Resident",
            "iamRoleName": "Physician"
        },
        {
            "position": "Physician-Medical Director",
            "iamRoleName": "Medical Director"
        },
        {
            "position": "Physicians - Consulting",
            "iamRoleName": "Physician"
        },
        {
            "position": "Licensed Nursing Home Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Doctor of Osteopathic Medicine ",
            "iamRoleName": "Physician"
        },
        {
            "position": "Clinical Dietician",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Associate Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Dietary Dir./Mgr",
            "iamRoleName": "Dietician"
        },
        {
            "position": "LNHA - Facility Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Agency Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "Dietitian Student",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Registered Dietitian* ",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Activities Technician",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Contracted Physical Therapist",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "*Dietary Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Certified Registered Nurse Practitioner ",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Administrator/ED",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Telehealth Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "Developmental Disabilities Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Administrator ",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Provincial Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Physical Therapist Assistant (Rehab)",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Dietary Manager-Assistant",
            "iamRoleName": "Dietician"
        },
        {
            "position": "COTA ",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Occupational Therapist - Do Not Use",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Medical Director /Physician",
            "iamRoleName": "Medical Director"
        },
        {
            "position": "Food Srvc Dir - Reg Dietician",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietary & Environmental Services Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietary Supervisors",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Traveler-Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "*Physical Therapy ",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Dietary Admin",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Unit Receptionist",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Activities Floor Aide",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Certified Occupational Therapist Assistant(COTA)",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Family Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "**Certified Medication Aide/Tech",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "SNF Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "External-Physician/Consultant",
            "iamRoleName": "Physician"
        },
        {
            "position": "Agency Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Corporate Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Occupational Therapist Aide",
            "iamRoleName": "Occupational therapy aide"
        },
        {
            "position": "Occupational Therapy (COTA) ",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Dietary Dept",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Certified Nursing Assistant / Medication Manager",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Dietary Technician Registered",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Activities/Recreation Director",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Activities-Coordinator",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Certified Occupational Therapy Assistant (COTA)",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Health Information Associate",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "*Admin Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Dietary Service Supervisor",
            "iamRoleName": "Dietician"
        },
        {
            "position": "AL Coordinator ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "ISFL Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Home Health Aide ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Dietary - Chef",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Dietary aid/Cook",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Dietary Coord/Mgr",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietary Services Supervisor",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Occupational Therapy Assistant (COTA)",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Optum Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Activities Assistants",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Physical Therapist Assistant ",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "Activities CNA ",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Physical Therapist Assistant(PTA)",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "Physical Therapy Resource",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Physician (Resident)",
            "iamRoleName": "Physician"
        },
        {
            "position": "Physician Clinical Staff",
            "iamRoleName": "Physician"
        },
        {
            "position": "Physician DLTCC",
            "iamRoleName": "Physician"
        },
        {
            "position": "*Campus Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Physician/Medical Director",
            "iamRoleName": "Medical Director"
        },
        {
            "position": "Physician/Psychiatrist",
            "iamRoleName": "Physician  "
        },
        {
            "position": "Physicians - Attending",
            "iamRoleName": "Physician"
        },
        {
            "position": "Nurse Practitioner Student",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Nursing - Physician Assistant",
            "iamRoleName": "Physician Assistant"
        },
        {
            "position": "LSS Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "Project Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Activity specialist ",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "LHRC Activities Coordinator",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Administrator RC",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Dietician Tech",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Hospice/Palliative Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Activities Co-Ordinator",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Community Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Receptionist\\Accounting Clerk",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Nurse Practitioner (Consultant)",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Nurse Practitioner, MPAC",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Dietary / Culinary  Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Kitchen Staff",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "AHS Case Manager",
            "iamRoleName": "Clinical laboratory service worker"
        },
        {
            "position": "Medical Officer",
            "iamRoleName": "Clinical laboratory service worker"
        },
        {
            "position": "KP-Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "Certified Medication Aide/Tech-Do Not Use",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Certified Medication Tech - AL",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "*Certified Medication Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Dietary Mananger",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Clinical Dietary Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Activity/SS Consultant",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Occupational Therapy Assistant ",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Occupational Therapy Assistants",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "All Dietary",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Cook/Dietary aide",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Consulting Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "Outside Physician-Medical Director",
            "iamRoleName": "Medical Director"
        },
        {
            "position": "Dietary Supervisor ",
            "iamRoleName": "Dietician"
        },
        {
            "position": "PSW Vacation Relief",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Accounts Payable ",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Dietician Student",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Activity Aid",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Activities Aide_1",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Registered Dietian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Certified Occupational Therapy Asst",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Certified Nurse Practitioner-MCG",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Attending Physician - Locum",
            "iamRoleName": "Physician"
        },
        {
            "position": "Activities Assistant-PC",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Administrator Intern",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Attending Physician - Resident",
            "iamRoleName": "Physician"
        },
        {
            "position": "Consultant - Dietary",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietary Intern ",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Assistant Director of Activities",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Physical Therapist (Rehab)",
            "iamRoleName": "Physical Therapist"
        },
        {
            "position": "AIT/Assistant Administrator, NHA",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Advance Nurse Practitioner (SMG)",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Medication Nursing Assistant",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "LPN Director",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "After Hours Receptionist",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Director of Enrichment/Activities",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "CNA/Certified Medication Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Dietary Consultant (GCHC)",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Student Physical Therapy Assistant",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "PC Unit Certified Medication Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Physician Specialist",
            "iamRoleName": "Physician"
        },
        {
            "position": "Skilled Nursing Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "*RECREATION ACTIVITY",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Therapy:  Occupational Therapist (OT)",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "DAIYA Physician ",
            "iamRoleName": "Physician"
        },
        {
            "position": "Nurse Practitioner, RN Extended Class",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Nurse Practitioner-TC",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Occupational Therapy Director",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Medical-Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "CAWM(client assist with meds)",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Life Coach",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Clerk Receptionist",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Director of Long Term Care",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Dietetic Technician Registered",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Certified Occupational Therapy Aide",
            "iamRoleName": "Occupational therapy aide"
        },
        {
            "position": "*SHR/PT/PHYSICAL THERAPIST",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "NP2U Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Certified Occupational Therapist Assist/License",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Corporate Dietary Services Consultant",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Reception/Admin. Assistant",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Data Manager",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Dietitian, Registered (R.D.)",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Certified Occupational Therapy Assitant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Contracted Interim Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Executive Director (Administrator)",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Property Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Doctor of Osteopathic Medicine",
            "iamRoleName": "Physician"
        },
        {
            "position": "Nutrition - Dietician",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Call9Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "Physical Therapy Asst",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "Physician - Attending",
            "iamRoleName": "Physician"
        },
        {
            "position": "Physician - Landmark",
            "iamRoleName": "Physician"
        },
        {
            "position": "Certified Dietary Manager ",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Activities Director/Coordinator",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "West ACE",
            "iamRoleName": "Physician"
        },
        {
            "position": "Nursing-Unit Coordinator/Receptionist",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Regisitered Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Medical Receptionist",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Level 1 Medication Aides",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Activity/Recreation Aide",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Registered Dietetic Tech",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Occupational Therapist, OTR\\L",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Nurse Practitioner (Archcare)",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Dietitian / Dietary Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Registered Dietitian Consultant",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Certified Occupational Therapy Assist.",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "CIT Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "ALF Dietary Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Advanced Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "SL Environmental Services Technician",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Visitor Services Receptionist",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Nurse Practitioner, Optumcare",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "DAIYA Physician Assistant ",
            "iamRoleName": "Physician Assistant"
        },
        {
            "position": "Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Nurse Practitioner-CCC",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Nurse Practitioner-LTC",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Physical Therapist (Interface Rehab)",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Physician Scribe",
            "iamRoleName": "Medical scribe"
        },
        {
            "position": "Wound Care Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "Administrator - Site Manager",
            "iamRoleName": "Administrator"
        },
        {
            "position": "**Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "PT - Physical Therapist",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Nursing Student RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Lead Clinical Dietician",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Physician/Medical Provider",
            "iamRoleName": "Physician"
        },
        {
            "position": "Front Desk Receptionist",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Kaiser Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Manager, Dietary Services",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Connections Club Associate",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Occupational Therapist (Rehab)",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Campus Administrator ",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Receptionist PRN",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Occupational Therapy Assistant, COTA",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Acting Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Medicare Claims Coordinator",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Activities/Recreation Therapist",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Recreation / Activities",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Medication Aide SNF",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Administrator in Training (AIT)",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Activities Assistant Director",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Nursing Aide ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Administrator/Designee",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Dietary Technician Registered (DTR)",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Concierge / Reception",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Qualified Medication Aide (QMA)",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Student Doctor",
            "iamRoleName": "Physician"
        },
        {
            "position": "Corporate Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Admin Support - Reception",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Caregiver Lead",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Director of Admissions and Community Outreach",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "VP IT",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Assistant Dietary Supervisor",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Summer Activity Assistant",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "AL Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Agency Registered Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Administrative Assist/Receptionist",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Administrator/Assistant Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Dietary - Nutritionist",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Occupational/Physiotherapy Assistant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Assistant Manager of Dietary",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Trained Medication Aid",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Administrator-AL",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Dietary Technician ",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Nutritional / Dietary",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Onlok-Doctor",
            "iamRoleName": "Physician"
        },
        {
            "position": "Dietary aide(FSW)",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Physician PGY1",
            "iamRoleName": "Physician"
        },
        {
            "position": "Dietary.",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Do Not Use/To be Deleted-Certified Nursing Aide",
            "iamRoleName": "Respiratory Therapist"
        },
        {
            "position": "Adapted Tech Therapist",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Clinical Liaison-RN",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "*Medication Aide/Tech",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Unit Secretary-LTC",
            "iamRoleName": "Medical Director"
        },
        {
            "position": "Qualified Medication Administration",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Attending Physician ",
            "iamRoleName": "Physician"
        },
        {
            "position": "Dietetic student",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietetic Tech",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Dietary / Culinary Director",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Assisted Living Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Physical Therapist (D)",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Care Center Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Physical Therapy Asst.",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "Therapy - Occupational Therapist",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "A1-Occupational Therapist",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "RACC Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "Dietician.",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietary- cook",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Physician- Specialist",
            "iamRoleName": "Physician"
        },
        {
            "position": "Physician- VAMC",
            "iamRoleName": "Physician"
        },
        {
            "position": "Housekeeping Attd",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Director Leisure Time Activity",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": " Certified Occupational Therapy Assistant ",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Activities Aide/Credentialed",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Medication Administration Assistant",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Licensed Dietitian Nutritionist",
            "iamRoleName": "Dietician"
        },
        {
            "position": "HK Reception",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "LPN Wound-Care Nurse",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "CNA Student ",
            "iamRoleName": "Nurse Aide in Training"
        },
        {
            "position": "HR Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Receptionist/Resident Trust",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Occupational Therapist Aide (OTA)",
            "iamRoleName": "Occupational therapy aide"
        },
        {
            "position": "NLOT Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Infectious Disease Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "Registered Physician Assistant",
            "iamRoleName": " Physician Assistant"
        },
        {
            "position": "Administrator - FT 1st",
            "iamRoleName": "Administrator"
        },
        {
            "position": "External-Occupational Therapist",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Recreation/Activities Specialist",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Dietary / Culinary Supervisor",
            "iamRoleName": "Dietician"
        },
        {
            "position": "*Registered Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietitian/NS Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietitian-C",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Administrator/CEO",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Physician - Read Only",
            "iamRoleName": "Physician"
        },
        {
            "position": "Physician (Daiya)",
            "iamRoleName": "Physician"
        },
        {
            "position": " Asst. Dietary Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Administrator 10",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Physician Assistant Certified",
            "iamRoleName": "Physician Assistant"
        },
        {
            "position": "Hospice Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Dietary Coordinator",
            "iamRoleName": "Dietician"
        },
        {
            "position": "PCF Administrators",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Director Dietary Services",
            "iamRoleName": "Dietician"
        },
        {
            "position": "ER Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "Contracted Physical Therapy Assistant",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "*Activities Coordinator",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Kitchen Dietary Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "*SHR/Activities/ACTIVITIES AIDE",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Administrator/Director",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Certified Occupational Assistant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "United Healthcare Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "AP Senior",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Unlicensed Medication Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Residential Program Manager",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Residential Services Shift Supervisor",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Regional MDS Specialist",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "LPN Interim",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Certified Medication Aide/Certified Nursing Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Contract-Physical Therapist",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "VHC Activity Worker",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "General Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "STHC Billing Manager",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Medication Nurse",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Activity Aide/Leader",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Nurse Practitioner (EC)",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "*Activities Assistant Health Center",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Diet Tech - DTR (Contract)",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Billing Technician",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Occupational Therapist (Consonus)",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Nurse Practitioner (SMG)",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Registered Diet Technician",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Nurse Practitioner Consultant",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Registered Dietician ",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Nurse Practitioner(OPTUM)",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Activity Consultant",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Registered Dietitian (Nutrition)",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Occupational Therapist I",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Occupational Therapist Student ",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Occupational Therapist",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Certified Medication Assistant",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Occupational Therapy Aid",
            "iamRoleName": "Occupational therapy aide"
        },
        {
            "position": "***Activities",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Activity Coordinator ",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Certified/Registered Diet Technician",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Financial Assistant",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Physical Therapist (Consonus)",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Interim Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Certified Dietary Manager CDM",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Admission Nurse",
            "iamRoleName": "Dentist"
        },
        {
            "position": "Dir Food Services",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Registered Dietetic Technician",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Telemedicine (Curavi Health)Physician  ",
            "iamRoleName": "Physician"
        },
        {
            "position": "Administrator [UK]",
            "iamRoleName": "Administrator"
        },
        {
            "position": "PA-Physician Assistant ",
            "iamRoleName": "Physician Assistant"
        },
        {
            "position": "Nutrition Dietetic Technician Registered",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Administrator-Interim",
            "iamRoleName": "Administrator"
        },
        {
            "position": "*Director of Dietary",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Registered Dietitian - Agency/Contract",
            "iamRoleName": "Dietician"
        },
        {
            "position": "A-Physical Therapy Assistant/Aide",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "Attending Physician (private)",
            "iamRoleName": "Physician"
        },
        {
            "position": "*Occupational Therapy Assistant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Dir. of Dietary",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Accountant Technician 2",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Activities  Assistant",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "*SHR/OT/OCCUPATIONAL THERAPIST",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Student - Registered Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Director Operations Finance",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Occupational Therapist-C",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Student Physical Therapist Assistant",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "Certified Occupational Aide",
            "iamRoleName": "Occupational therapy aide"
        },
        {
            "position": "Residential Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Certified Occupational Therapist Assistant (COTA)",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Administrator-In-Training",
            "iamRoleName": "Administrator"
        },
        {
            "position": "A-Occupational Therapy Assistant/Aide",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Administrator- Healthcare",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Dietitian Technician",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Activities Aide/Transport",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "LSS Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Vendor-Dietary",
            "iamRoleName": "Dietician"
        },
        {
            "position": "(AIT) Administrator In Training",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Certified occupational therapy",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Certified Occupational Therapy Aid",
            "iamRoleName": "Occupational therapy aide"
        },
        {
            "position": "Assistant Activity Director",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Weekend Receptionist",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": " Administrator in Training",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Sr Physical Therapist",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "EHR Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Physical Therapist Aide",
            "iamRoleName": "Physical therapy aide"
        },
        {
            "position": "Certified Occupational Therpaist Assistant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Physical Therapist, PT/MHS",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "All Activity",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Occupational Ther Assistant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Physical Therapy Aides",
            "iamRoleName": "Physical therapy aide"
        },
        {
            "position": "Physical Therapy Assistant (Consonus)",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "Occupational Therapists Assistant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Activities CNA",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Receptionist / AP",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Physician - Internal Medicine",
            "iamRoleName": "Physician"
        },
        {
            "position": "Receptionist/Clerical Assistant",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Occupational Therapy Asst.",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Medical Director/Attending Physician",
            "iamRoleName": "Medical Director"
        },
        {
            "position": "Food Srvc Dir - Diet Tech Reg",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Physician Asst. (Daiya)",
            "iamRoleName": "Physician Assistant"
        },
        {
            "position": "Employed Physician FT",
            "iamRoleName": "Physician"
        },
        {
            "position": "Consultant Physician - Wound & Pain Specialist",
            "iamRoleName": "Physician"
        },
        {
            "position": "Dietary, Clinical",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Physician M.D.",
            "iamRoleName": "Physician"
        },
        {
            "position": "Regional Dietary",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Physician Receptionist",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Advanced Practice Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Dietetic Intern ",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Administrator - Executive",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Administrator/DOC",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Diet Service Coordinator",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietitian Intern",
            "iamRoleName": "Dietician"
        },
        {
            "position": "RN Physician Clinic",
            "iamRoleName": "Physician"
        },
        {
            "position": "Dietitian/CDM",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Nurse Practitioner DLTCC",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Nurse Practitioner- Wound Specialist",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Activities Coordinator ",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Activities Coordinator (D)",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Nurse Practitioner(Psych) ",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Registered Physical Therapist ",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Diet Technician Registered",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Activities Coordinator PRN",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Attending Physician/Medical Director",
            "iamRoleName": "Medical Director"
        },
        {
            "position": "Diet Technician Student",
            "iamRoleName": "Dietician"
        },
        {
            "position": "ATTENDING PHYSICIANS",
            "iamRoleName": "Physician"
        },
        {
            "position": "Nurse Practitioner-Rehabilitation",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Nurse practitioners",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Coord of Admissions",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Ward Clerk / Reception",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Activities Designee",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "MSM Executive Director/Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Dietary - Staff",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Quality Standards Coordinator - Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Assistant Director of Healthcare",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "Case Mix Nurse",
            "iamRoleName": "Clinical laboratory service worker"
        },
        {
            "position": "LAB - Clerk/Phlebotomy",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "President/CEO/Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Activities Director, Certified",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Occupational Therapist (PRN)",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Activities Director.",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Student Dietitian ",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Activity Assistant ",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Doctor of Physical Therapy",
            "iamRoleName": "Physical Therapist"
        },
        {
            "position": "Student- Nurse Practitioner ",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Dietary Aide / Culinary Associate",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Student Occupational Therapy Assistant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Student Physical Therapist",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Receptionist/Billing Clerk",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Asst Dietary Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Occupational Therapy Assistnat",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Receptionist-PC",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "*Campus Administrator, Intern",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Support Services - Dietary",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Administrator/EDRC",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Activities Director/Social Services Designee",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Activity Director SSD",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Attending Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Dietary, Nutritional, Envir. Ops Partner",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietary aides",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Dietary Assitant",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Optum Physician''s Assistant",
            "iamRoleName": "Physician Assistant"
        },
        {
            "position": "Therapy - Physical Therapist",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Administrator- VAM",
            "iamRoleName": "Administrator"
        },
        {
            "position": "OT -Occupational Therapist",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Clinical Dietetic Intern",
            "iamRoleName": "Dietician"
        },
        {
            "position": "McLaren Lab",
            "iamRoleName": "Clinical laboratory service worker"
        },
        {
            "position": "Activity/Recreation",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Dietetic Technician/CDM",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Activities Manager-PC",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Site Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Administration Receptionist",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Medication Assistant Certified",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Certified Medication Aide/Restorative Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Bella Care Hospice Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Registered Dietian student",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Psychiatric Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "HC Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Dietitian RD, LD",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Director Of Care/Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Dietitian/Food Services Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "VENDOR-Dietician",
            "iamRoleName": "Dietician"
        },
        {
            "position": "*SHR/Dietary/DIETICIAN ",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Administrator - SubAcute",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Dietary Director ",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Coach/activities",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "EGM-Dietary aide",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Dietary Food Service Director",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Consultant-Manager of Dietary Services",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Administrator_Nurse",
            "iamRoleName": "Administrator"
        },
        {
            "position": "HCC Dietary Supervisor",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Rehab Occupational Therapy",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "VVH - Receptionist / Admin Assistant",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Rehab Physical Therapist",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Sound Physician-OutsideServices",
            "iamRoleName": "Physician"
        },
        {
            "position": "Activities Worker Supervisor",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Contracted Interim Activity Director",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Behavior Management Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "Religious Activities Coord.",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "CDM - Certified Dietary Manager (Contract)",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Activities/Rec Therapy (AL)",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Consultant- Dietary",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Admin Assitant/Receptionist",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "z_Activities Aide",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Administrator/Risk Manager",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Payroll/AP/Receptionist",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Nursing Home Administrator.",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Dietary Student/Intern",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Payroll/Human Resources",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Homecare Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "*ST/Activities/ACTIVITIES AIDE",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Asst. Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Therapeutic Activities Services Manager",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Dietary Manager AL",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietician, Specialist",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Asst. Dietary Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Administrator/RN",
            "iamRoleName": "Administrator"
        },
        {
            "position": "MOH Dietary",
            "iamRoleName": "Dietician"
        },
        {
            "position": "MSM Dietician",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Administrator/RPN",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Student Dietitian Intern",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Asst. Nursing Home Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Clinical Dietary Technician",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Graduate Certified Medication Aide",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Dietary Tech Registered",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietician Manager Senior Services",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Personal Care Activities Aide",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "*ST/Admin/ADMINISTRATOR",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Facilities Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Family Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "Activities Mentor",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "HP Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Food & Nutrition Certified Dietary Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Administrator- Terrace",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Clinical Care Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Nurse Practitioner - Hastings",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Student - Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "HC Activities Director",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Dietary Assessment Coordinator",
            "iamRoleName": "Dietician"
        },
        {
            "position": "HCSG Dietary Mgmt",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Administrator/Director ",
            "iamRoleName": "Administrator"
        },
        {
            "position": "*Campus Administrator ",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Dietary Mgr.",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Therapy:  Physical Therapy Asst (PTA)",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "Pharmacy Billing Manager",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Dietary/Environmental Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Trust Clerk",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "*Assistant Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "*Physical Therapist (Staff)",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Administrator/Owner",
            "iamRoleName": "Administrator"
        },
        {
            "position": "X - Activities Director",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Medical Advisory Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "Medical Director - Physician",
            "iamRoleName": "Medical Director"
        },
        {
            "position": "RN(EC), Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Medical-Physician Assistant",
            "iamRoleName": "Physician Assistant"
        },
        {
            "position": "Physiatry Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "*Administrator Of Seasons",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Physical Therapist Aid",
            "iamRoleName": "Physical therapy aide"
        },
        {
            "position": "NEG Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Activities Therapy",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Director of Dietary ",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Director of Dietary Dept",
            "iamRoleName": "Dietician"
        },
        {
            "position": "NP/PA -Nurse Practitioner/Phys.Assistant",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Physical Therapy, DPT",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Activities/Social Services Director",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Physician (Kaiser)",
            "iamRoleName": "Physician"
        },
        {
            "position": "Nurse Practitioner-Student",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Physician / Dental -  Office Staff",
            "iamRoleName": "Dentist"
        },
        {
            "position": "Physician / Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Student Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Physician Assistant (PA)",
            "iamRoleName": "Physician Assistant"
        },
        {
            "position": "Physician Assistant(SMG)",
            "iamRoleName": "Physician Assistant"
        },
        {
            "position": "Physician Hourly",
            "iamRoleName": "Physician"
        },
        {
            "position": "*AL Activities",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Physician Salaried",
            "iamRoleName": "Physician"
        },
        {
            "position": " Registered Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "TH - Physical Therapist",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Activity Programmer ",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Nutrition - Food Services/Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Activity/Volunteer Coordinator",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Nutritionist/Dietician",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietary Tech.",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietetic Technition",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Director of Food Services & Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "dietician intern",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietician, RD/CD",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietitian (Registered)",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietitian In Training",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietitian/FSM",
            "iamRoleName": "Dietician"
        },
        {
            "position": "PM Dietary Supervisor",
            "iamRoleName": "Dietician"
        },
        {
            "position": "POOL CERTIFIED MEDICATION AIDE/TECH",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Hospice Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "RN Assistant Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "RN,Nursing Home Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "President/Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Medical-Attending Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "CDM-Certified Dietary Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "*Regional Activities Director",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "COTA (Certified Occupational Therapy Assistant)",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Activities Director Certified",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Memory Care Activity Specialist",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Activities Director/CMA",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Program Manager / Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Behavior Management Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Activities Preceptor",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "MTS Assistant Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Music Director",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Administrator INN",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Administrator- MMP",
            "iamRoleName": "Administrator"
        },
        {
            "position": "NEG Physician Assistant",
            "iamRoleName": "Physician Assistant"
        },
        {
            "position": "Social Services/Activities",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Provisional Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Kaiser Physician Assistant",
            "iamRoleName": "Physician Assistant"
        },
        {
            "position": "NP Insight Doctor",
            "iamRoleName": "Physician"
        },
        {
            "position": "Activities/Chaplain",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "KPH Activities CNA",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "KPH Admin Assistant",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Nurse Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "PSW Student ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "KP-Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "SS/Activities Aide",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "ST -Speech Therapist",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Psych - Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Activities-Assisted Living",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Staffing Supervisor",
            "iamRoleName": "Medical Director"
        },
        {
            "position": "AHS - Recreation Therapist",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Activity / Social Services Assistant",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Front Activities Director",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Psychiatric-Mental Health Nurse Practitioner ",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Nurse Practitioner-Paragon",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Student Dietary",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Administrator, Long-Term Care",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Activity Co-ordinator",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Deputy Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Campus Activities Director",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "PT -Physical Therapist",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "PT Physical Therapy",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Diet Practice Leader (Dietitian)",
            "iamRoleName": "Dietician"
        },
        {
            "position": "PTA -Physical Therapy Assistant",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "Lead Front Desk Receptionist",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Nursing Home Administrator ",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Lead Physical Therapist",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Activity Director/Social Service Designee",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Dietary Department and/or Supervisor",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Clinical Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "LHRC Activities Director",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "LHRC Activities Driver",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Trained Medication Employee",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "LHRC Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Occupational Therapist (Agency)",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Occupational Therapist (D)",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Occupational Therapist (Interface Rehab)",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Occupational Therapist Student",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Dietary-Registered Dietician",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Occupational Therapy Asst (Consonus)",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Dietician Consultant",
            "iamRoleName": "Dietician"
        },
        {
            "position": "CEO/Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "AHS Registered Dietician",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Certfied Occupational Therapy Assistatnt",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Administrator/Manager",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Outside Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "*Registered Dietician",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Certified Assistant Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Licensed Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Licensed Nursing Facility Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Clubhouse Receptionist",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Licensed Occupational Therapy Assistant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Licensed Physical Therapy Assistant",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "Owner/Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Consult Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "Hospice Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "Medical Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Administrator- Court/Manor",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Reception & Billing",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Reception Supervisor",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Receptionist (ND)",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Administrator - Assoc",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Receptionist / Hospitality Rep",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Receptionist PD",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Receptionist/Admin Assistant",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Receptionist/AP",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Receptionist/Concierge",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Receptionist/Posting",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Receptionist/Unit Clerk",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "Recreation and Marketing Coordinator",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Chen-Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Bella Care Hospice Nurse Practitioner ",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "External_6M Geriatrics Physician Group",
            "iamRoleName": "Physician"
        },
        {
            "position": "Medication Aide ALF",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Medication Aide Certified ",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Certified Medication Aide SCU",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "COTA -Certified Occupational Therapist",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Certified Medication Aide SNF",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "AL Administrator (ND)",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Memory Care Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Facility Services Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "BH-Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "Family Nurse Practitioner -C",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Administrator III",
            "iamRoleName": "Administrator"
        },
        {
            "position": "CHR Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Long Term Care Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Long Term Care Administrator ",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Senior Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Administrator - Senior",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Division Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Consulting Physicians",
            "iamRoleName": "Physician"
        },
        {
            "position": "MSM Corporate Receptionist",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "MSM Financial Accountant",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "MTS Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "*SHHC/Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "SNF - Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Administrator of Health Services",
            "iamRoleName": "Administrator"
        },
        {
            "position": "CONTRACT PHYSICAL THERAPIST",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Doctor On Call",
            "iamRoleName": "Physician"
        },
        {
            "position": "Doctor",
            "iamRoleName": "Physician"
        },
        {
            "position": "AL Manager / Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Customer Service Clerk",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Administrator (ALF)",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Billing Secretary",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Clinical Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Controller-Vero Only",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Lutz Wing Dietician",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Assistant Administrator/CFO",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Registered Nurse Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Administrator / Director of Care",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Nurse Practitioner (External)",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "Nurse Practitioner(staff)",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "*AFH/ADMINISTRATOR",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Student - Nurse Practitioner",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "EGM-Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "NURSE Registry-RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "General Physician- Care Navigator ",
            "iamRoleName": "Physician"
        },
        {
            "position": "Student Occupational Therapist",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Deputy N.H. Administrator for Fiscal Services",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Rehab CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Nursing - RAI/MDS",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Rehab Director/Speech Therapist",
            "iamRoleName": "Speech/language pathologist"
        },
        {
            "position": "Supervisor - Housekeeping",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "Supervisor Environmental Serv",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "Manager of Creative Therapies",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Supervisor Housekeeping",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "Supervisor of Environmental Services",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "Manager of Food and Nutrition",
            "iamRoleName": "Dietician"
        },
        {
            "position": "AL RN Delegate Nurse",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Manager of Housekeeping & Laundry",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "Rehab Physical Therapy Assistant",
            "iamRoleName": "Physical therapy assistant"
        },
        {
            "position": "Nursing Admin-Nurse Manager",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Supervisor, Laboratory",
            "iamRoleName": "Clinical laboratory service worker"
        },
        {
            "position": "Graduate Practial Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Rehab Speech Therapist",
            "iamRoleName": "Speech/language pathologist"
        },
        {
            "position": "Manager of IT",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "Manager of Life Enrichment & Volunteers",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Manager of Life Enrichment and Volunteers ",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Graduated Practical Nurse",
            "iamRoleName": "Licensed Practical/ Vocational Nurse"
        },
        {
            "position": "Manager of Medical Social Services",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "Manager of Nursing ",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "GRP - Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Manager of Nutrition Services ",
            "iamRoleName": "Dietician"
        },
        {
            "position": "EL Activities Coordinator ",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Diet Tech-Registered",
            "iamRoleName": "Dietician"
        },
        {
            "position": "EL Administrator ",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Activity Director - ILC",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Manager of Recreation & Therapy",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Surveyor 1",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "RehabCare Restorative Nursing Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Surveyor AL",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "Manager of Recreation and Volunteer Coordinator",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Dietary - Dietitian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Surveyor Social Worker",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "Manager of Recreation and Volunteer Service",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Dietary - Director of Clinical",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Coordinator of Recreation Therapy",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Surveyor/Reviewer External",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "Manager of Rehabilitation & Speech Language",
            "iamRoleName": "Speech/language pathologist"
        },
        {
            "position": "3rd Party - Doctor",
            "iamRoleName": "Physician"
        },
        {
            "position": "Survyor",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "AL RN Manager",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Manager of Resident Services / Director of Care",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Systems Administrator ",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "Dietary /Nutrition",
            "iamRoleName": "Dietician"
        },
        {
            "position": "HC Recreation Therapy Supervisor",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Manager of Security",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "Manager of Skilled Nursing",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Manager of Social Services",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "Nursing Restorative Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Activity Director/Dietary Service Manager",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "HCA Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Dietary aide / Food Services Worker",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Remedi Pharm Patient Account",
            "iamRoleName": "Pharmacy technician"
        },
        {
            "position": "Clinical Lab Consultant",
            "iamRoleName": "Clinical laboratory service worker"
        },
        {
            "position": "Tech Implementation",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "Tech Support Specialist II",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "Manager of Therapeutic Services",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Manager of Tillsonburg / Director of Care",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Technical Services RHC IT Manager",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "Remedy''s Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Remedy''s Pharmacist",
            "iamRoleName": "Pharmacist"
        },
        {
            "position": "Technology Services Administrator",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "Remedy''s Pharmacy Technician",
            "iamRoleName": "Pharmacy technician"
        },
        {
            "position": "Clinical Lead/ Auditor",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "*AL Director / Nurse",
            "iamRoleName": "Administrator"
        },
        {
            "position": "*Dietary Assistant",
            "iamRoleName": "Dietician"
        },
        {
            "position": "ELC - Executive Director",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Rep Act Asst/CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Temporary Certified Nursing Assistant",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Activity Driver/Aide",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "HCA/PSW/RPN",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Repsiratory Therapist",
            "iamRoleName": "Respiratory therapist"
        },
        {
            "position": "HCA/PSW/UCP",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "ELC - LPN Unit Manager",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "HCA-C",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Dietary Asst Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Therapeutic Activities Director",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Dietary Asst. Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Clinical Liaison/Licensed Social Worker",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "Manager, Business Operations",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Therapeutic Rec Coordinator",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Therapeutic Rec Specialist",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Head Chef",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "ELC - Reimbursement Director",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Therapeutic Recreation Intern",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Manager, Environmental Services",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "A/L Director",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Occupational Therapist",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Therapeutic Recreational Specialist",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Manager, Housekeeping & Laundry",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "Health & Wellness Manager",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Manager, Infrastructure & Technology",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "Therapuetic Recreation Assistant",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Manager, IPAC",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Nursing Unit Coordinator LPN/LVN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Manager, IT",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "Activity Programs & Services Director",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Manager, Life Enrichment",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Health and Wellness Administrator ",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Dietary DTR",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Manager, National Customer Relations",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Care Coordinator/RPN ",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Therapy - OT (Agency)",
            "iamRoleName": "Occupational Therapist"
        },
        {
            "position": "Nursing/Activities",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Coordinator of Therapeutic Programs",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Nursing-C.N.A.",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Coordinator of Therapeutic Recreation",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Health Care Administrator (D)",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Resident Assessment Coordinator (MDS)",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Manager, Recreation and Volunteer Services",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Manager, Rehab & PT",
            "iamRoleName": "Physical Therapist"
        },
        {
            "position": "Nutrition Care Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Activity/Occupational Therapy Assistant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Dietary Manager/DTR",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Nutrition Dept.",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Health Care Aide/ Personal Support Worker",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Manager, Sub-Acute Care",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Manager, Therapeutic & Volunteer Services",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "*Hospice Director",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Manager, Weinberg",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Admissions/Activity Director",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Actvities",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Assistant Culinary & Nutrition Service Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietary Service Worker",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Dietary Services Director",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Nutritional Services",
            "iamRoleName": "Dietician"
        },
        {
            "position": "EMAR IT",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "Nutritional Services Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Nutritional Services Supervisor",
            "iamRoleName": "Dietician"
        },
        {
            "position": "BO - Receptionist",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "EMAR Set-up",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "Care Homes Social Worker",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "Certified Occupational Therapist Aide",
            "iamRoleName": "Occupational therapy aide"
        },
        {
            "position": "eMAR System Administrator",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "Occupation Therapist",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Occupation Therapy Asst",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "TR COTA",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Dietary Tech ",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Occupational Thearpy Assistant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Assistant Dir of Life Enrichment",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Occupational Therapist (GMHOT)",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Transition Coordinator",
            "iamRoleName": "Other social worker"
        },
        {
            "position": "Transition Counsellor",
            "iamRoleName": "Other social worker"
        },
        {
            "position": "Occupational therapist Assisstant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Assistant Director ",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Occupational Therapist Asst.",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Marketing/Director of Activities ",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Occupational Therapist II",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Occupational Therapist POP",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Occupational Therapist, MS OTR\\L",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Occupational therapist,RH",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Resident Doctor",
            "iamRoleName": "Physician"
        },
        {
            "position": "Occupational therapist,SJS-CMT",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Traveling MDS Coordinator -RN",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Occupational Therapist-Certified",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "TRD/Social Worker",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "Dietary-CDM",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Corp Collections Manager",
            "iamRoleName": "Accounting and finance staff"
        },
        {
            "position": "Dietetic Consultant",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietetic Interim",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Clinical Quality Manager, RN",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Occupational Therapy Assistant  ",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Masters in Social Work",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "U of T Masters Social Work Student",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "UBC Dentist",
            "iamRoleName": "Dentist"
        },
        {
            "position": "Masters of Social Work, Intern",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "Occupational Therapy Manager",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Activiies Aide/Assistant",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Occupational Therapy Tech",
            "iamRoleName": "Occupational therapy aide"
        },
        {
            "position": "Associate Director of Nursing & Staff Development",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Resident Physiotherapist",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Occupational/Physio Aide",
            "iamRoleName": "Occupational therapy aide"
        },
        {
            "position": "Dietian",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Corp Dietary Consultant",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietician - Consultant",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietician Aide",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Ocupational Therapist DLTCC",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Corp Office Mgr",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Assistant Director ILF",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Care Manager- Social Work",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "Associate Director, Social Work",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "Dietitian (Consultant)",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietitian (D)",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietitian Coordinator",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Endocrinologist",
            "iamRoleName": "Physician"
        },
        {
            "position": "OKM - Activities",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Activities /Recreation",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "*Dietitian Consultant",
            "iamRoleName": "Dietician"
        },
        {
            "position": "MD (Medical Director)",
            "iamRoleName": "Medical Director"
        },
        {
            "position": "CLINICAL RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "ON CALL PHYSICIAN",
            "iamRoleName": "Physician"
        },
        {
            "position": "Assistant Director Nursing Services LPN/LVN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Clinical Service Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Certified Occupations therapy Assistant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "On-call Intern",
            "iamRoleName": "Physician"
        },
        {
            "position": "Hematologist",
            "iamRoleName": "Physician"
        },
        {
            "position": "Resident Social Services Coordinator",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "Asst Activities Director",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Certified Occuptional Therapy Assistant",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "*SHR/Admin/RECEPTIONIST",
            "iamRoleName": "Business and operations staff"
        },
        {
            "position": "*Dining Services Director",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dietition",
            "iamRoleName": "Dietician"
        },
        {
            "position": "VA Registered Nurse",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Dietray Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Certified Ocupational Therapist Assistant ",
            "iamRoleName": "Occupational therapist"
        },
        {
            "position": "Dining Captain",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "ENT",
            "iamRoleName": "Physician"
        },
        {
            "position": "*Assistant Director of Wellness",
            "iamRoleName": "Administrator"
        },
        {
            "position": "MDS Assessment Nurse",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Activities Admin Assistant",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": " CEO",
            "iamRoleName": "Administrator"
        },
        {
            "position": "*SHR/Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Dining Room Coordinator",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Dining Room Lead",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Certified Rec Therapist",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "MDS Coding Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Asst Dietary Director",
            "iamRoleName": "Dietician"
        },
        {
            "position": " Director Nutritional Services",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Orthopaedic Surgery",
            "iamRoleName": "Physician"
        },
        {
            "position": "Enviromental Manager",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "Orthopedic Surgeon",
            "iamRoleName": "Physician"
        },
        {
            "position": "MDS Coodinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Environmental",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "Corporate Activities Director",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Vero-CFO",
            "iamRoleName": "Administrator"
        },
        {
            "position": "*SHR/Dietary/ASSISTANT DIETARY MANAGER",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Environmental Guest Associate",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "CARE SERVICE ASSISTANT",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Environmental Manager",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "BScN RN WOCC(C)",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "VHC Social Work",
            "iamRoleName": "Qualified social worker"
        },
        {
            "position": "Dining Services ",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "MDS Coordinator Care Partner ",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Vice President - Nursing",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Vice President / CFO",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Vice President Community Services",
            "iamRoleName": "Administrator"
        },
        {
            "position": "*SHR/Dietary/DIETARY AIDE",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Vice President Health Services",
            "iamRoleName": "Administrator"
        },
        {
            "position": "MDS Coordinator- LPN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Environmental Service Mgr",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "*SHR/Dietary/DIETARY COOK",
            "iamRoleName": "Dietician"
        },
        {
            "position": "BSN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "Agency Physical Therapist",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Respirarory Therapy Manager",
            "iamRoleName": "Respiratory therapist"
        },
        {
            "position": "MDS Coordinator RN Senior HS",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Vice President of Operations - East",
            "iamRoleName": "Administrator"
        },
        {
            "position": "MDS Coordinator US",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "MDS Coordinator.",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Respiratory Management",
            "iamRoleName": "Respiratory therapist"
        },
        {
            "position": "*SHR/NAC/Social Services Assistant",
            "iamRoleName": "Other social worker"
        },
        {
            "position": "Vice President, Operations/Chief Nursing Executive",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Environmental Services Assistant Manager",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "Vice-President of Operations",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Assistant Director of Care DLTCC",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Respiratory Therapist (ECP)",
            "iamRoleName": "Respiratory therapist"
        },
        {
            "position": "Dining Waitstaff",
            "iamRoleName": "Other service worker"
        },
        {
            "position": "Respiratory Therapist Assistant",
            "iamRoleName": "Respiratory therapy technician"
        },
        {
            "position": "Respiratory therapist/trainer",
            "iamRoleName": "Respiratory therapist"
        },
        {
            "position": "Activities Assistance",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "Respiratory Therapy - FT 1st",
            "iamRoleName": "Respiratory therapist"
        },
        {
            "position": "Outpatient Stroke/Brain Injury RN Care Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Environmental Services Staff",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "Respirologist",
            "iamRoleName": "Respiratory therapist"
        },
        {
            "position": "MDS Director, RN",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Vocational Director",
            "iamRoleName": "Vocational service worker"
        },
        {
            "position": "Environmental Services Supervisor ",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "Outside Auditor",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "Responsible Person",
            "iamRoleName": "Resident or representative"
        },
        {
            "position": "Assistant Director of Clinical Care",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Restorative - COTA",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "Restorative Aid",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "MDS Nurse - LPN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Corporate Chef",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dir of Creativity",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "MDS Nurse (D)",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Activities Assistant (D)",
            "iamRoleName": "Other activities staff"
        },
        {
            "position": "MDS Nurse-RN",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Restorative Care Aide ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "A1-Physical Therapist ",
            "iamRoleName": "Physical therapist"
        },
        {
            "position": "Certified Respiratory Therapist",
            "iamRoleName": "Respiratory therapist"
        },
        {
            "position": "Dir of Nutrition",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Certified Respiratory Therapist  ",
            "iamRoleName": "Respiratory therapist"
        },
        {
            "position": "VP Long Term Care",
            "iamRoleName": "Administrator"
        },
        {
            "position": "*Physicians Assistant",
            "iamRoleName": "Physician Assistant"
        },
        {
            "position": "*SHR/Nursing/ADMISSIONS/DSCHRG LPN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "VP of Clinical Reimbursment/ MDS",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "VP of Culinary Services",
            "iamRoleName": "Dietician"
        },
        {
            "position": "CL-License Practical Nurse",
            "iamRoleName": "Licensed Practical/Vocational Nurse"
        },
        {
            "position": "Restorative Infection Control RN",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "MDS/LPN Coordinator",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "Restorative Manager- RN",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Certified Therapeutic Recreation Specialist",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "ESSEN Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "MDS/RN Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Restorative Nursing - LPN",
            "iamRoleName": "Licensed Practical/Vocational Nurse"
        },
        {
            "position": "Owner-Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "MDS-Corporate RN",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "MDS-Educator- Infection Control- QA",
            "iamRoleName": "REgistered Nurse with Administrative Duties"
        },
        {
            "position": "Assistant Director of Dietary",
            "iamRoleName": "Dietician"
        },
        {
            "position": "MDS-Swing Bed",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Restorative PSW",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "EVNA Director",
            "iamRoleName": "Administrator"
        },
        {
            "position": "VP, Residential & Community Care",
            "iamRoleName": "Administrator"
        },
        {
            "position": "*SHR/Nursing/STAFF DEV/INFECTION CTRL - LPN",
            "iamRoleName": "Licensed Practical/Vocational Nurse with Administrative Duties"
        },
        {
            "position": "VP-Information Technology ",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "VSM Housekeeper",
            "iamRoleName": "Housekeeping service worker"
        },
        {
            "position": "*SHR/Nursing/STAFF DEV/INFECTION PREVENTION RN",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "CMA / UNIT SEC",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Restorative-Aide",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "PAC IT Director",
            "iamRoleName": "IT Systems Administrator"
        },
        {
            "position": "Paid Feeding Assistant",
            "iamRoleName": "Feeding assistant"
        },
        {
            "position": "Retirement Home Manager",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Corporate Dietician",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Dir. of Therapeutic Recreation",
            "iamRoleName": "Therapeutic recreation specialist"
        },
        {
            "position": "Palliative Care Physician",
            "iamRoleName": "Physician"
        },
        {
            "position": "*SHR/OT/CERT OCCUP THER ASSISTANT",
            "iamRoleName": "Occupational therapy assistant"
        },
        {
            "position": "ASST Food Service Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "Med Nurse - RN, LPN or TMA",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Med Pass Nurse",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Parent/Guardian",
            "iamRoleName": "Resident or representative"
        },
        {
            "position": "Med Pharm Admin",
            "iamRoleName": "Pharmacy technician"
        },
        {
            "position": "Wellness and Recovery Director",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Wellness Center Director",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Hospice Aide- Careline",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Hospice C.N.A.",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "RMA/CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "CMS Inspection",
            "iamRoleName": "Surveyor or Audit professional"
        },
        {
            "position": "Med tech II",
            "iamRoleName": "Medication Aide/Technician"
        },
        {
            "position": "Executive Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "RN - Accreditation Coordinator",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "RN - Administrator",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Hospice HHA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Wound Care NP",
            "iamRoleName": "Nurse Practitioner"
        },
        {
            "position": "RN - Assistant Director of Care",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Director ",
            "iamRoleName": "Administrator"
        },
        {
            "position": "RN - Assisted Living",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "CNA - AL",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Director - CALA",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Patient Care Attendant ",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Hospice Medical Director",
            "iamRoleName": "Medical Director"
        },
        {
            "position": "RN - DON",
            "iamRoleName": "Registered Nurse Director of Nursing"
        },
        {
            "position": "Corporate Director of Operations",
            "iamRoleName": "Administrator"
        },
        {
            "position": "Hospice NAR",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "Executive Chef/Dietary Manager",
            "iamRoleName": "Dietician"
        },
        {
            "position": "RN - Human Resources",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "RN - IIWCC",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "X-Ray Tech",
            "iamRoleName": "Diagnostic x-ray service worker"
        },
        {
            "position": "Activities Consultant-SNF",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "Z_Islands Hospice - CNA",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "RN - Social Services",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "z_Navian Hawaii - RN",
            "iamRoleName": "Registered Nurse"
        },
        {
            "position": "*MDS Director",
            "iamRoleName": "Registered Nurse with Administrative Duties"
        },
        {
            "position": "Activities Coodinator",
            "iamRoleName": "Qualified activities professional"
        },
        {
            "position": "CNA - SDS",
            "iamRoleName": "Certified Nurse Aid"
        },
        {
            "position": "RN (BSO",
            "iamRoleName": "Registered Nurse"
        }
    ]
}'
-- StandardIAMRoles

SET @jsonStandardIamRole = N'{
	"StandardIamRoleName": [
    {
        "name": "podiatrist",
        "displayName": "Podiatrist",
        "categoryName": "podiatry-services",
        "description": "Licensed or registered Podiatrists who provide podiatric care.",
        "category": {
            "name": "podiatry-services",
            "displayName": "Podiatry Services",
            "description": "Podiatry Services"
        },
        "products": []
    },
    {
        "name": "it-systems-administrator",
        "displayName": "IT Systems Administrator",
        "categoryName": "it-administration-services",
        "description": "Person(s) who ensure their organization''s computer systems operate reliably. Tasks performed include helping set up, maintain, and delete user accounts as required. They also provide technical support and handle upgrades to systems as needed.",
        "category": {
            "name": "it-administration-services",
            "displayName": "IT Administration Services",
            "description": "IT Administration Services"
        },
        "products": [
            {
                "name": "practitioner-workspace-dev"
            },
            {
                "name": "practitioner-workspace-qa"
            }
        ]
    },
    {
        "name": "pharmacist",
        "displayName": "Pharmacist",
        "categoryName": "pharmacy-services",
        "description": "Licensed pharmacists who provide consultation on pharmacy services, establish a system of records of controlled drugs, oversee records and reconcile controlled drugs, and or perform a monthly drug regimen review for each resident.",
        "category": {
            "name": "pharmacy-services",
            "displayName": "Pharmacy Services",
            "description": "Pharmacy Services"
        },
        "products": []
    },
    {
        "name": "qualified-social-worker",
        "displayName": "Qualified social worker",
        "categoryName": "therapeutic-services",
        "description": "Individuals licensed to practice social work, or if licensure is not required, persons with a bachelor''s degree in social work, a bachelor''s degree in a human services field including but not limited to sociology, special education, rehabilitation counseling and psychology, and one year of supervised social work experience in a health care setting working directly with residents.",
        "category": {
            "name": "therapeutic-services",
            "displayName": "Therapeutic Services",
            "description": "Therapeutic Services"
        },
        "products": []
    },
    {
        "name": "occupational-therapist",
        "displayName": "Occupational therapist",
        "categoryName": "therapeutic-services",
        "description": "Licensed or Registered Occupational Therapists (OT) who provide direct therapy to residents. Include OTs who spend less than 50 percent of their time as activities therapists.",
        "category": {
            "name": "therapeutic-services",
            "displayName": "Therapeutic Services",
            "description": "Therapeutic Services"
        },
        "products": []
    },
    {
        "name": "vocational-service-worker",
        "displayName": "Vocational service worker",
        "categoryName": "vocational-services",
        "description": "Individuals who assist residents to enter, re-enter, or maintain employment in the labor force, including training for jobs in integrated settings (i.e., those which have both disabled and nondisabled workers) as well as in special settings such as sheltered workshops.",
        "category": {
            "name": "vocational-services",
            "displayName": "Vocational Services",
            "description": "Vocational Services"
        },
        "products": []
    },
    {
        "name": "other-activities-staff",
        "displayName": "Other activities staff",
        "categoryName": "therapeutic-services",
        "description": "Individuals providing an on-going program of activities designed to meet residents'' needs and interests. Do not include volunteers or users reported elsewhere.",
        "category": {
            "name": "therapeutic-services",
            "displayName": "Therapeutic Services",
            "description": "Therapeutic Services"
        },
        "products": [
            {
                "name": "practitioner-workspace-qa"
            },
            {
                "name": "sc-dev"
            },
            {
                "name": "visualize-qa-dsoi"
            },
            {
                "name": "patient-portal"
            },
            {
                "name": "patient-portal-dev"
            },
            {
                "name": "pharmacy-workspace-qa"
            },
            {
                "name": "visualize-rgr-dsoi"
            },
            {
                "name": "fnd-dashboard-app-dev"
            },
            {
                "name": "fnd-dashboard-app-sb"
            },
            {
                "name": "visualize-dev-dsoi"
            },
            {
                "name": "patient-portal-local"
            },
            {
                "name": "harmony-configuration-app"
            },
            {
                "name": "harmony-configuration-app-local"
            },
            {
                "name": "harmony-configuration-app-dev"
            },
            {
                "name": "fnd-dashboard-app-local"
            },
            {
                "name": "pharmacy-workspace-local"
            },
            {
                "name": "fnd-dashboard-app-qa"
            },
            {
                "name": "wellness-director-workspace-qa"
            },
            {
                "name": "practitioner-workspace-dev"
            },
            {
                "name": "pharmacy-workspace-dev"
            },
            {
                "name": "my-patients-app"
            },
            {
                "name": "sc-qa"
            },
            {
                "name": "homehealth-local"
            }
        ]
    },
    {
        "name": "physical-therapist",
        "displayName": "Physical therapist",
        "categoryName": "therapeutic-services",
        "description": "Licensed or registered Physical Therapists (PT) who provide direct therapy to residents",
        "category": {
            "name": "therapeutic-services",
            "displayName": "Therapeutic Services",
            "description": "Therapeutic Services"
        },
        "products": []
    },
    {
        "name": "registered-nurse-director-of-nursing",
        "displayName": "Registered Nurse Director of Nursing",
        "categoryName": "nursing-services",
        "description": "Registered nurse responsible for managing and supervising nursing services in the facility.",
        "category": {
            "name": "nursing-services",
            "displayName": "Nursing Services",
            "description": "Nursing Services"
        },
        "products": []
    },
    {
        "name": "administrator",
        "displayName": "Administrator",
        "categoryName": "administration-services",
        "description": "Administrative staff responsible for facility management, such as the administrator and the assistant administrator.",
        "category": {
            "name": "administration-services",
            "displayName": "Administration Services",
            "description": "Administration Services"
        },
        "products": []
    },
    {
        "name": "qualified-activities-professional",
        "displayName": "Qualified activities professional",
        "categoryName": "therapeutic-services",
        "description": "Activities professional who are providing an on-going program of activities designed to meet residents'' interests and physical, mental, or psychosocial needs. Do not include Therapeutic Recreation Specialists, Occupational Therapists, OT Assistants, or other similar categories.",
        "category": {
            "name": "therapeutic-services",
            "displayName": "Therapeutic Services",
            "description": "Therapeutic Services"
        },
        "products": []
    },
    {
        "name": "clinical-nurse-specialist",
        "displayName": "Clinical Nurse Specialist",
        "categoryName": "nursing-services",
        "description": "A registered nurse with specialized graduate education who provides advanced nursing care.",
        "category": {
            "name": "nursing-services",
            "displayName": "Nursing Services",
            "description": "Nursing Services"
        },
        "products": []
    },
    {
        "name": "nurse-practitioner",
        "displayName": "Nurse Practitioner",
        "categoryName": "physician-services",
        "description": "A registered nurse with specialized graduate education licensed to diagnose and treat illness, independently or as part of a healthcare team.",
        "category": {
            "name": "physician-services",
            "displayName": "Physician Services",
            "description": "Physician Services"
        },
        "products": [
            {
                "name": "practitioner-workspace-dev"
            },
            {
                "name": "practitioner-workspace-qa"
            }
        ]
    },
    {
        "name": "physical-therapy-aide",
        "displayName": "Physical therapy aide",
        "categoryName": "therapeutic-services",
        "description": "Individuals who have specialized training to assist a PT to carry out the PT''s comprehensive plan of care under the direct supervision of the therapist.",
        "category": {
            "name": "therapeutic-services",
            "displayName": "Therapeutic Services",
            "description": "Therapeutic Services"
        },
        "products": []
    },
    {
        "name": "other-social-worker",
        "displayName": "Other social worker",
        "categoryName": "therapeutic-services",
        "description": "Individuals, other than the qualified social worker, who provide medical social services to residents. Do not include volunteers.",
        "category": {
            "name": "therapeutic-services",
            "displayName": "Therapeutic Services",
            "description": "Therapeutic Services"
        },
        "products": []
    },
    {
        "name": "respiratory-therapy-technician",
        "displayName": "Respiratory therapy technician",
        "categoryName": "therapeutic-services",
        "description": "Individuals who provide respiratory care under the direction of respiratory therapists and physicians.",
        "category": {
            "name": "therapeutic-services",
            "displayName": "Therapeutic Services",
            "description": "Therapeutic Services"
        },
        "products": []
    },
    {
        "name": "physician",
        "displayName": "Physician",
        "categoryName": "physician-services",
        "description": "A physician, other than the medical director, who supervises the care of residents when the attending physician is unavailable, and or a physician available to provide emergency services 24 hours a day.",
        "category": {
            "name": "physician-services",
            "displayName": "Physician Services",
            "description": "Physician Services"
        },
        "products": [
            {
                "name": "practitioner-workspace-qa"
            },
            {
                "name": "practitioner-workspace-dev"
            }
        ]
    },
    {
        "name": "dietician",
        "displayName": "Dietician",
        "categoryName": "dietary-services",
        "description": "Registered Dieticians, employed full, part-time or as consultants, who identify dietary needs, and plan and implement dietary programs for residents.",
        "category": {
            "name": "dietary-services",
            "displayName": "Dietary Services",
            "description": "Dietary Services"
        },
        "products": []
    },
    {
        "name": "medical-director",
        "displayName": "Medical Director",
        "categoryName": "physician-services",
        "description": "A physician responsible for implementation of resident care policies and coordination of medical care.",
        "category": {
            "name": "physician-services",
            "displayName": "Physician Services",
            "description": "Physician Services"
        },
        "products": [
            {
                "name": "practitioner-workspace-qa"
            }
        ]
    },
    {
        "name": "respiratory-therapist",
        "displayName": "Respiratory therapist",
        "categoryName": "therapeutic-services",
        "description": "Licensed or Registered Respiratory Therapists who provide direct respiratory care to residents.",
        "category": {
            "name": "therapeutic-services",
            "displayName": "Therapeutic Services",
            "description": "Therapeutic Services"
        },
        "products": []
    },
    {
        "name": "housekeeping-service-worker",
        "displayName": "Housekeeping service worker",
        "categoryName": "housekeeping-services",
        "description": "Individuals who provide services, including the maintenance department, necessary to maintain the environment. Includes equipment kept in a clean, safe, functioning, and sanitary condition. Includes housekeeping services supervisor and engineers.",
        "category": {
            "name": "housekeeping-services",
            "displayName": "Housekeeping Services",
            "description": "Housekeeping Services"
        },
        "products": []
    },
    {
        "name": "blood-service-worker",
        "displayName": "Blood service worker",
        "categoryName": "administration-and-storage-of-blood-services",
        "description": "Individuals who provide blood bank and transfusion services.",
        "category": {
            "name": "administration-and-storage-of-blood-services",
            "displayName": "Administration & Storage of Blood Services",
            "description": "Administration & Storage of Blood Services"
        },
        "products": []
    },
    {
        "name": "other-service-worker",
        "displayName": "Other service worker",
        "categoryName": "other-services",
        "description": "All personnel not already recorded (For example, librarian).",
        "category": {
            "name": "other-services",
            "displayName": "Other Services",
            "description": "Other Services"
        },
        "products": []
    },
    {
        "name": "healthcare-services-staff",
        "displayName": "Healthcare services staff",
        "categoryName": "healthcare-services",
        "description": "Clinical or clinical support staff. Principal duties might include, care manager, care coordinator, scheduler, discharge planner, network oversight, Health Information Management, medical coder, medical records, hospital liaison.",
        "category": {
            "name": "healthcare-services",
            "displayName": "Healthcare Services",
            "description": "Healthcare Services"
        },
        "products": [
            {
                "name": "wellness-director-workspace-local"
            },
            {
                "name": "harmony-configuration-app-local"
            },
            {
                "name": "harmony-configuration-app"
            },
            {
                "name": "wellness-director-workspace-dev"
            },
            {
                "name": "wellness-director-workspace-qa"
            },
            {
                "name": "harmony-configuration-app-dev"
            }
        ]
    },
    {
        "name": "diagnostic-x-ray-service-worker",
        "displayName": "Diagnostic x-ray service worker",
        "categoryName": "diagnostic-x-ray-services",
        "description": "Individuals who provide radiology services for approved independent radiology locations or hospitals.",
        "category": {
            "name": "diagnostic-x-ray-services",
            "displayName": "Diagnostic X-ray Services",
            "description": "Diagnostic X-ray Services"
        },
        "products": []
    },
    {
        "name": "nurse-aide-in-training",
        "displayName": "Nurse Aide in Training",
        "categoryName": "nursing-services",
        "description": "Individuals who are in the first 4 months of employment and receiving approved Nurse Aide training and are providing direct care nursing related services under the supervision of a licensed or registered nurse.",
        "category": {
            "name": "nursing-services",
            "displayName": "Nursing Services",
            "description": "Nursing Services"
        },
        "products": []
    },
    {
        "name": "registered-nurse",
        "displayName": "Registered Nurse",
        "categoryName": "nursing-services",
        "description": "Registered nurse including geriatric nurse practitioners and clinical nurse specialists who primarily perform direct care nursing services, not Physician-delegated tasks.",
        "category": {
            "name": "nursing-services",
            "displayName": "Nursing Services",
            "description": "Nursing Services"
        },
        "products": [
            {
                "name": "wellness-director-workspace-qa"
            },
            {
                "name": "wellness-director-workspace-dev"
            },
            {
                "name": "wellness-director-workspace-local"
            }
        ]
    },
    {
        "name": "mental-health-service-worker",
        "displayName": "Mental health service worker",
        "categoryName": "mental-health-services",
        "description": "Individuals who provide services for residents'' mental, emotional, psychological, or psychiatric well-being and who: Diagnose, describe, or evaluate mental or emotional status; Prevent deviations from mental or emotional well-being from developing; or Treat the resident according to a planned regimen to assist in regaining, maintaining, or increasing emotional abilities. Among the specific services included are psychotherapy and counseling, and administration and monitoring of psychotropic medications targeted to a psychiatric diagnosis. Do not include users added as other social worker or therapist.",
        "category": {
            "name": "mental-health-services",
            "displayName": "Mental Health Services",
            "description": "Mental Health Services"
        },
        "products": []
    },
    {
        "name": "occupational-therapy-assistant",
        "displayName": "Occupational therapy assistant",
        "categoryName": "therapeutic-services",
        "description": "Individuals licensed or certified with specialized training to assist an Occupational Therapist (OT) to carry out the OT''s comprehensive plan of care, without the direct supervision of the therapist. Include OT Assistants who spend less than 50 percent of their time as Activities Therapists.",
        "category": {
            "name": "therapeutic-services",
            "displayName": "Therapeutic Services",
            "description": "Therapeutic Services"
        },
        "products": []
    },
    {
        "name": "registered-nurse-with-administrative-duties",
        "displayName": "Registered Nurse with Administrative Duties",
        "categoryName": "nursing-services",
        "description": "Registered nurse who does not perform direct care functions. Principal duties might include, regulatory compliance documentation, administrative functions, and or hosts educational/in-services.",
        "category": {
            "name": "nursing-services",
            "displayName": "Nursing Services",
            "description": "Nursing Services"
        },
        "products": [
            {
                "name": "wellness-director-workspace-dev"
            },
            {
                "name": "wellness-director-workspace-local"
            },
            {
                "name": "wellness-director-workspace-qa"
            }
        ]
    },
    {
        "name": "speech-language-pathologist",
        "displayName": "Speech/language pathologist",
        "categoryName": "therapeutic-services",
        "description": "Licensed or registered Speech Therapists who provide direct therapy to residents.",
        "category": {
            "name": "therapeutic-services",
            "displayName": "Therapeutic Services",
            "description": "Therapeutic Services"
        },
        "products": []
    },
    {
        "name": "physician-assistant",
        "displayName": "Physician Assistant",
        "categoryName": "physician-services",
        "description": "A graduate of an accredited educational program for physician assistants who provides healthcare services typically performed by a physician, under the supervision of a physician.",
        "category": {
            "name": "physician-services",
            "displayName": "Physician Services",
            "description": "Physician Services"
        },
        "products": [
            {
                "name": "practitioner-workspace-dev"
            },
            {
                "name": "practitioner-workspace-qa"
            }
        ]
    },
    {
        "name": "dentist",
        "displayName": "Dentist",
        "categoryName": "dental-services",
        "description": "Individuals licensed as dentists who provide routine and emergency dental services.",
        "category": {
            "name": "dental-services",
            "displayName": "Dental Services",
            "description": "Dental Services"
        },
        "products": []
    },
    {
        "name": "licensed-practical-vocational-nurse",
        "displayName": "Licensed Practical/ Vocational Nurse",
        "categoryName": "nursing-services",
        "description": "Licensed practical and vocational nurses who primarily perform direct care nursing services.",
        "category": {
            "name": "nursing-services",
            "displayName": "Nursing Services",
            "description": "Nursing Services"
        },
        "products": [
            {
                "name": "wellness-director-workspace-dev"
            },
            {
                "name": "wellness-director-workspace-local"
            },
            {
                "name": "wellness-director-workspace-qa"
            }
        ]
    },
    {
        "name": "feeding-assistant",
        "displayName": "Feeding assistant",
        "categoryName": "dietary-services",
        "description": "Indivuals who are paid to feed residents or who are used under an arrangement with another agency or organization. Paid feeding assistants must not feed any residents with complicated feeding problems or perform any other nursing or nursing-related tasks. A feeding assistant must work under the supervision of an RN or a LPN.",
        "category": {
            "name": "dietary-services",
            "displayName": "Dietary Services",
            "description": "Dietary Services"
        },
        "products": []
    },
    {
        "name": "harmony-configuration-admin",
        "displayName": "Harmony Configuration Admin",
        "categoryName": "healthcare-services",
        "description": "Harmony Configuration Admin",
        "category": {
            "name": "healthcare-services",
            "displayName": "Healthcare Services",
            "description": "Healthcare Services"
        },
        "products": [
            {
                "name": "harmony-configuration-app-dev"
            },
            {
                "name": "harmony-configuration-app-local"
            },
            {
                "name": "harmony-configuration-app"
            }
        ]
    },
    {
        "name": "medication-aide-technician",
        "displayName": "Medication Aide/Technician",
        "categoryName": "nursing-services",
        "description": "Individuals, other than a licensed professional, who fulfill the requirement for approval to administer medications to residents.",
        "category": {
            "name": "nursing-services",
            "displayName": "Nursing Services",
            "description": "Nursing Services"
        },
        "products": []
    },
    {
        "name": "licensed-practical-vocational-nurse-with-administrative-duties",
        "displayName": "Licensed Practical/Vocational Nurse with Administrative Duties",
        "categoryName": "nursing-services",
        "description": "Licensed practical or vocational nurses who do not perform direct care functions. Principal duties include administrative functions, educational or in-services, and or other duties excluding direct resident care.",
        "category": {
            "name": "nursing-services",
            "displayName": "Nursing Services",
            "description": "Nursing Services"
        },
        "products": [
            {
                "name": "wellness-director-workspace-dev"
            },
            {
                "name": "wellness-director-workspace-qa"
            },
            {
                "name": "wellness-director-workspace-local"
            }
        ]
    },
    {
        "name": "clinical-laboratory-service-worker",
        "displayName": "Clinical laboratory service worker",
        "categoryName": "clinical-laboratory-services",
        "description": "Individuals who provide laboratory services for approved independent laboratories or hospitals.",
        "category": {
            "name": "clinical-laboratory-services",
            "displayName": "Clinical Laboratory Services",
            "description": "Clinical Laboratory Services"
        },
        "products": []
    },
    {
        "name": "healthcare-services-staff-with-administrative-duties",
        "displayName": "Healthcare services staff with administrative duties",
        "categoryName": "healthcare-services",
        "description": "Clinical staff who do not perform direct care functions. Principal duties might include, regulatory compliance documentation, administrative functions, and or hosts educational/in-services.",
        "category": {
            "name": "healthcare-services",
            "displayName": "Healthcare Services",
            "description": "Healthcare Services"
        },
        "products": [
            {
                "name": "harmony-configuration-app"
            },
            {
                "name": "harmony-configuration-app-dev"
            },
            {
                "name": "harmony-configuration-app-local"
            }
        ]
    },
    {
        "name": "physical-therapy-assistant",
        "displayName": "Physical therapy assistant",
        "categoryName": "therapeutic-services",
        "description": "Individuals licensed or certified with specialized training to assist a Physical Therapist (PT) to carry out the PT''s comprehensive plan of care, without the direct supervision of the PT.",
        "category": {
            "name": "therapeutic-services",
            "displayName": "Therapeutic Services",
            "description": "Therapeutic Services"
        },
        "products": []
    },
    {
        "name": "occupational-therapy-aide",
        "displayName": "Occupational therapy aide",
        "categoryName": "therapeutic-services",
        "description": "Individuals who have specialized training to assist an OT to carry out comprehensive plan of care under the direct supervision of the therapist.",
        "category": {
            "name": "therapeutic-services",
            "displayName": "Therapeutic Services",
            "description": "Therapeutic Services"
        },
        "products": []
    },
    {
        "name": "therapeutic-recreation-specialist",
        "displayName": "Therapeutic recreation specialist",
        "categoryName": "therapeutic-services",
        "description": "Individuals who are licensed or registered or eligible for certification as a therapeutic recreation specialist by a recognized accrediting body.",
        "category": {
            "name": "therapeutic-services",
            "displayName": "Therapeutic Services",
            "description": "Therapeutic Services"
        },
        "products": []
    },
    {
        "name": "certified-nurse-aid",
        "displayName": "Certified Nurse Aid",
        "categoryName": "nursing-services",
        "description": "Certified nursing aids who are providing direct nursing or nursing-related services to residents. Do not include volunteers.",
        "category": {
            "name": "nursing-services",
            "displayName": "Nursing Services",
            "description": "Nursing Services"
        },
        "products": []
    }
]
}';


-- Gets all Position - IAM Roles mapping from JSON parameter
INSERT INTO @vpositionIamRoleMapTbl (col1, col2)
SELECT jsonTbl.positionName, jsonTbl.roleName FROM OPENJSON(@jsonPositionIamRoleMap, '$.PositionIamRoleNameMap') 
	WITH (positionName VARCHAR(255) '$.position', roleName VARCHAR(255) '$.iamRoleName') jsonTbl

-- Gets all IAM Roles from JSON parameter
INSERT INTO @vstandardIamRoleTbl (col1, col2)
SELECT jsonTbl2.name, jsonTbl2.displayName FROM OPENJSON(@jsonStandardIamRole, '$.StandardIamRoleName') 
	WITH ([name] VARCHAR(255) '$.name', displayName VARCHAR(255) '$.displayName') jsonTbl2;

DECLARE @positionIdIamRoleTbl TABLE (item_id int, positionDescription VARCHAR(255), iamRoleName VARCHAR(255));

MERGE INTO dbo.iam_role_position AS irp
USING (
	SELECT DISTINCT ccode.item_id, stdIamRole.col1 AS role_code
	FROM dbo.common_code ccode 
	INNER JOIN @vpositionIamRoleMapTbl posIamRoleMap 
		ON ccode.item_description = posIamRoleMap.col1
	INNER JOIN @vstandardIamRoleTbl stdIamRole 
		ON stdIamRole.col2 = posIamRoleMap.col2
	WHERE ccode.item_code = 'posit' AND ccode.deleted <> 'Y'
) AS positionRole ON (positionRole.item_id = irp.position_id AND positionRole.role_code = irp.iam_role_name)
WHEN NOT MATCHED THEN
	INSERT (position_id, iam_role_name)
	VALUES (positionRole.item_id, positionRole.role_code);
	
	
	
	
	
	
	
	

GO

print 'A_PreUpload/CORE-100695 - 2 - DML - populate mapping table iam roles positions.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-100695 - 2 - DML - populate mapping table iam roles positions.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-100696- DML - populate table sec conversation v2.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

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
-- Jira #:               CORE-100696
--
-- Written By:           Giovanny Tellez
--
-- Script Type:          DML
-- Target DB Type:       CLIENT 
-- Target ENVIRONMENT:   BOTH  
--
--
-- Re-Runable:           YES 
 
--
-- Staging Recommendations/Warnings: none
--
-- Description of Script Function: Populate table sec_conversation_validation_v2
--
-- Special Instruction: none
--
--
-- =================================================================================

BEGIN
DECLARE @groupResidentCentric int, @groupGeneral int, @groupCrossFac int, @status tinyInt;
    SET @groupResidentCentric = 1;
    SET @groupGeneral  = 2;
    SET @groupCrossFac = 3;
    SET @status = 1;

IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'podiatrist') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'podiatrist', @status); 
       END 

--------1
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'podiatrist') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'podiatrist', @status); 
       END 

--------2
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'podiatrist') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'podiatrist', @status); 
       END 

--------3
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'it-systems-administrator') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'it-systems-administrator', @status); 
       END 

--------4
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'it-systems-administrator') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'it-systems-administrator', @status); 
       END 

--------5
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'it-systems-administrator') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'it-systems-administrator', @status); 
       END 

--------6
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'pharmacist') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'pharmacist', @status); 
       END 

--------7
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'pharmacist') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'pharmacist', @status); 
       END 

--------8
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'pharmacist') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'pharmacist', @status); 
       END 

--------9
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'qualified-social-worker') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'qualified-social-worker', @status); 
       END 

--------10
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'qualified-social-worker') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'qualified-social-worker', @status); 
       END 

--------11
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'qualified-social-worker') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'qualified-social-worker', @status); 
       END 

--------12
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'resident-or-representative') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'resident-or-representative', @status); 
       END 

--------13
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'resident-or-representative') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'resident-or-representative', @status); 
       END 

--------14
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'resident-or-representative') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'resident-or-representative', @status); 
       END 

--------15
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'other-activities-staff') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'other-activities-staff', @status); 
       END 

--------16
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'other-activities-staff') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'other-activities-staff', @status); 
       END 

--------17
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'other-activities-staff') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'other-activities-staff', @status); 
       END 

--------18
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'physical-therapist') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'physical-therapist', @status); 
       END 

--------19
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'physical-therapist') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'physical-therapist', @status); 
       END 

--------20
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'physical-therapist') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'physical-therapist', @status); 
       END 

--------21
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'registered-nurse-director-of-nursing') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'registered-nurse-director-of-nursing', @status); 
       END 

--------22
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'registered-nurse-director-of-nursing') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'registered-nurse-director-of-nursing', @status); 
       END 

--------23
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'registered-nurse-director-of-nursing') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'registered-nurse-director-of-nursing', @status); 
       END 

--------24
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'qualified-activities-professional') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'qualified-activities-professional', @status); 
       END 

--------25
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'qualified-activities-professional') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'qualified-activities-professional', @status); 
       END 

--------26
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'qualified-activities-professional') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'qualified-activities-professional', @status); 
       END 

--------27
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'clinical-nurse-specialist') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'clinical-nurse-specialist', @status); 
       END 

--------28
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'clinical-nurse-specialist') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'clinical-nurse-specialist', @status); 
       END 

--------29
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'clinical-nurse-specialist') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'clinical-nurse-specialist', @status); 
       END 

--------30
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'other-social-worker') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'other-social-worker', @status); 
       END 

--------31
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'other-social-worker') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'other-social-worker', @status); 
       END 

--------32
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'other-social-worker') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'other-social-worker', @status); 
       END 

--------33
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'respiratory-therapy-technician') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'respiratory-therapy-technician', @status); 
       END 

--------34
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'respiratory-therapy-technician') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'respiratory-therapy-technician', @status); 
       END 

--------35
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'respiratory-therapy-technician') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'respiratory-therapy-technician', @status); 
       END 

--------36
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'business-and-operations-staff') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'business-and-operations-staff', @status); 
       END 

--------37
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'business-and-operations-staff') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'business-and-operations-staff', @status); 
       END 

--------38
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'business-and-operations-staff') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'business-and-operations-staff', @status); 
       END 

--------39
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'respiratory-therapist') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'respiratory-therapist', @status); 
       END 

--------40
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'respiratory-therapist') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'respiratory-therapist', @status); 
       END 

--------41
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'respiratory-therapist') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'respiratory-therapist', @status); 
       END 

--------42
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'housekeeping-service-worker') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'housekeeping-service-worker', @status); 
       END 

--------43
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'housekeeping-service-worker') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'housekeeping-service-worker', @status); 
       END 

--------44
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'housekeeping-service-worker') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'housekeeping-service-worker', @status); 
       END 

--------45
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'blood-service-worker') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'blood-service-worker', @status); 
       END 

--------46
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'blood-service-worker') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'blood-service-worker', @status); 
       END 

--------47
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'blood-service-worker') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'blood-service-worker', @status); 
       END 

--------48
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'other-service-worker') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'other-service-worker', @status); 
       END 

--------49
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'other-service-worker') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'other-service-worker', @status); 
       END 

--------50
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'other-service-worker') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'other-service-worker', @status); 
       END 

--------51
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'diagnostic-x-ray-service-worker') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'diagnostic-x-ray-service-worker', @status); 
       END 

--------52
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'diagnostic-x-ray-service-worker') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'diagnostic-x-ray-service-worker', @status); 
       END 

--------53
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'diagnostic-x-ray-service-worker') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'diagnostic-x-ray-service-worker', @status); 
       END 

--------54
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'nurse-aide-in-training') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'nurse-aide-in-training', @status); 
       END 

--------55
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'nurse-aide-in-training') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'nurse-aide-in-training', @status); 
       END 

--------56
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'nurse-aide-in-training') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'nurse-aide-in-training', @status); 
       END 

--------57
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'registered-nurse') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'registered-nurse', @status); 
       END 

--------58
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'registered-nurse') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'registered-nurse', @status); 
       END 

--------59
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'registered-nurse') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'registered-nurse', @status); 
       END 

--------60
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'mental-health-service-worker') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'mental-health-service-worker', @status); 
       END 

--------61
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'mental-health-service-worker') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'mental-health-service-worker', @status); 
       END 

--------62
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'mental-health-service-worker') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'mental-health-service-worker', @status); 
       END 

--------63
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'physician-assistant') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'physician-assistant', @status); 
       END 

--------64
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'physician-assistant') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'physician-assistant', @status); 
       END 

--------65
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'physician-assistant') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'physician-assistant', @status); 
       END 

--------66
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'dentist') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'dentist', @status); 
       END 

--------67
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'dentist') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'dentist', @status); 
       END 

--------68
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'dentist') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'dentist', @status); 
       END 

--------69
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'licensed-practical-vocational-nurse-with-administrative-duties') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'licensed-practical-vocational-nurse-with-administrative-duties', @status); 
       END 

--------70
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'licensed-practical-vocational-nurse-with-administrative-duties') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'licensed-practical-vocational-nurse-with-administrative-duties', @status); 
       END 

--------71
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'licensed-practical-vocational-nurse-with-administrative-duties') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'licensed-practical-vocational-nurse-with-administrative-duties', @status); 
       END 

--------72
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'clinical-laboratory-service-worker') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'clinical-laboratory-service-worker', @status); 
       END 

--------73
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'clinical-laboratory-service-worker') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'clinical-laboratory-service-worker', @status); 
       END 

--------74
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'clinical-laboratory-service-worker') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'clinical-laboratory-service-worker', @status); 
       END 

--------75
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'surveyor-or-audit-professional') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'surveyor-or-audit-professional', @status); 
       END 

--------76
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'surveyor-or-audit-professional') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'surveyor-or-audit-professional', @status); 
       END 

--------77
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'surveyor-or-audit-professional') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'surveyor-or-audit-professional', @status); 
       END 

--------78
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'physical-therapy-assistant') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'physical-therapy-assistant', @status); 
       END 

--------79
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'physical-therapy-assistant') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'physical-therapy-assistant', @status); 
       END 

--------80
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'physical-therapy-assistant') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'physical-therapy-assistant', @status); 
       END 

--------81
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'therapeutic-recreation-specialist') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'therapeutic-recreation-specialist', @status); 
       END 

--------82
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'therapeutic-recreation-specialist') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'therapeutic-recreation-specialist', @status); 
       END 

--------83
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'therapeutic-recreation-specialist') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'therapeutic-recreation-specialist', @status); 
       END 

--------84
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'medical-scribe') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'medical-scribe', @status); 
       END 

--------85
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'medical-scribe') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'medical-scribe', @status); 
       END 

--------86
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'medical-scribe') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'medical-scribe', @status); 
       END 

--------87
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'pharmacy-technician') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'pharmacy-technician', @status); 
       END 

--------88
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'pharmacy-technician') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'pharmacy-technician', @status); 
       END 

--------89
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'pharmacy-technician') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'pharmacy-technician', @status); 
       END 

--------90
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'occupational-therapist') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'occupational-therapist', @status); 
       END 

--------91
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'occupational-therapist') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'occupational-therapist', @status); 
       END 

--------92
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'occupational-therapist') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'occupational-therapist', @status); 
       END 

--------93
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'vocational-service-worker') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'vocational-service-worker', @status); 
       END 

--------94
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'vocational-service-worker') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'vocational-service-worker', @status); 
       END 

--------95
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'vocational-service-worker') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'vocational-service-worker', @status); 
       END 

--------96
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'accounting-and-finance-staff') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'accounting-and-finance-staff', @status); 
       END 

--------97
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'accounting-and-finance-staff') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'accounting-and-finance-staff', @status); 
       END 

--------98
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'accounting-and-finance-staff') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'accounting-and-finance-staff', @status); 
       END 

--------99
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'administrator') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'administrator', @status); 
       END 

--------100
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'administrator') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'administrator', @status); 
       END 

--------101
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'administrator') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'administrator', @status); 
       END 

--------102
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'nurse-practitioner') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'nurse-practitioner', @status); 
       END 

--------103
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'nurse-practitioner') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'nurse-practitioner', @status); 
       END 

--------104
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'nurse-practitioner') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'nurse-practitioner', @status); 
       END 

--------105
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'physical-therapy-aide') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'physical-therapy-aide', @status); 
       END 

--------106
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'physical-therapy-aide') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'physical-therapy-aide', @status); 
       END 

--------107
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'physical-therapy-aide') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'physical-therapy-aide', @status); 
       END 

--------108
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'physician') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'physician', @status); 
       END 

--------109
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'physician') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'physician', @status); 
       END 

--------110
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'physician') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'physician', @status); 
       END 

--------111
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'dietician') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'dietician', @status); 
       END 

--------112
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'dietician') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'dietician', @status); 
       END 

--------113
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'dietician') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'dietician', @status); 
       END 

--------114
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'medical-director') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'medical-director', @status); 
       END 

--------115
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'medical-director') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'medical-director', @status); 
       END 

--------116
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'medical-director') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'medical-director', @status); 
       END 

--------117
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'healthcare-services-staff') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'healthcare-services-staff', @status); 
       END 

--------118
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'healthcare-services-staff') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'healthcare-services-staff', @status); 
       END 

--------119
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'healthcare-services-staff') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'healthcare-services-staff', @status); 
       END 

--------120
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'occupational-therapy-assistant') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'occupational-therapy-assistant', @status); 
       END 

--------121
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'occupational-therapy-assistant') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'occupational-therapy-assistant', @status); 
       END 

--------122
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'occupational-therapy-assistant') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'occupational-therapy-assistant', @status); 
       END 

--------123
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'registered-nurse-with-administrative-duties') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'registered-nurse-with-administrative-duties', @status); 
       END 

--------124
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'registered-nurse-with-administrative-duties') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'registered-nurse-with-administrative-duties', @status); 
       END 

--------125
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'registered-nurse-with-administrative-duties') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'registered-nurse-with-administrative-duties', @status); 
       END 

--------126
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'speech-language-pathologist') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'speech-language-pathologist', @status); 
       END 

--------127
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'speech-language-pathologist') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'speech-language-pathologist', @status); 
       END 

--------128
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'speech-language-pathologist') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'speech-language-pathologist', @status); 
       END 

--------129
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'licensed-practical-vocational-nurse') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'licensed-practical-vocational-nurse', @status); 
       END 

--------130
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'licensed-practical-vocational-nurse') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'licensed-practical-vocational-nurse', @status); 
       END 

--------131
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'licensed-practical-vocational-nurse') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'licensed-practical-vocational-nurse', @status); 
       END 

--------132
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'feeding-assistant') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'feeding-assistant', @status); 
       END 

--------133
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'feeding-assistant') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'feeding-assistant', @status); 
       END 

--------134
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'feeding-assistant') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'feeding-assistant', @status); 
       END 

--------135
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'harmony-configuration-admin') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'harmony-configuration-admin', @status); 
       END 

--------136
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'harmony-configuration-admin') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'harmony-configuration-admin', @status); 
       END 

--------137
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'harmony-configuration-admin') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'harmony-configuration-admin', @status); 
       END 

--------138
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'medication-aide-technician') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'medication-aide-technician', @status); 
       END 

--------139
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'medication-aide-technician') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'medication-aide-technician', @status); 
       END 

--------140
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'medication-aide-technician') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'medication-aide-technician', @status); 
       END 

--------141
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'healthcare-services-staff-with-administrative-duties') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'healthcare-services-staff-with-administrative-duties', @status); 
       END 

--------142
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'healthcare-services-staff-with-administrative-duties') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'healthcare-services-staff-with-administrative-duties', @status); 
       END 

--------143
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'healthcare-services-staff-with-administrative-duties') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'healthcare-services-staff-with-administrative-duties', @status); 
       END 

--------144
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'occupational-therapy-aide') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'occupational-therapy-aide', @status); 
       END 

--------145
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'occupational-therapy-aide') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'occupational-therapy-aide', @status); 
       END 

--------146
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'occupational-therapy-aide') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'occupational-therapy-aide', @status); 
       END 

--------147
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupResidentCentric AND iam_role_name = 'certified-nurse-aid') 
       BEGIN 
            INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupResidentCentric, 'certified-nurse-aid', @status); 
       END 

--------148
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupGeneral AND iam_role_name = 'certified-nurse-aid') 
       BEGIN 
             INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupGeneral, 'certified-nurse-aid', @status); 
       END 

--------149
IF NOT EXISTS (SELECT 1 FROM sec_conversation_validation_v2 WHERE group_type=@groupCrossFac AND iam_role_name = 'certified-nurse-aid') 
       BEGIN 
              INSERT INTO sec_conversation_validation_v2 (group_type, iam_role_name, status) VALUES (@groupCrossFac, 'certified-nurse-aid', @status); 
       END 

--------150

 
END






GO

print 'A_PreUpload/CORE-100696- DML - populate table sec conversation v2.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-100696- DML - populate table sec conversation v2.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-100836- DML - Added New Report Id Pharmacy Order Update Report.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

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
-- Jira #:               CORE-100836
--
-- Written By:           Dom Christie
--
-- Script Type:          DML
-- Target DB Type:       CLIENT 
-- Target ENVIRONMENT:   BOTH  
--
--
-- Re-Runable:           YES 
 
--
-- Staging Recommendations/Warnings: none
--
-- Description of Script Function: New Report Id Pharmacy Order Update Report
--
-- Special Instruction: none
--
--
-- =================================================================================


IF NOT EXISTS (SELECT 1 FROM [reporting].[rpt_report] WHERE report_id = 2301)
BEGIN
    INSERT INTO [reporting].[rpt_report](report_id, title, long_description, help_text, url)
		VALUES (2301, 'Pharmacy Order Update Report',
		'View and print PDF for the summary of all  facility and Pharmacy initiated simple updates to Medication orders for a selected ${fac_facilities}..',
		'',
		'/enterprisereporting/setup.xhtml?reportId=2301');
END
IF NOT EXISTS (SELECT 1 FROM [reporting].[rpt_report_module_sub_module_mapping] WHERE report_id = 2301 AND module_sub_module_mapping_id = 14)
BEGIN
	INSERT INTO [reporting].[rpt_report_module_sub_module_mapping] 
		VALUES (2301, 14);
END        
 
GO






GO

print 'A_PreUpload/CORE-100836- DML - Added New Report Id Pharmacy Order Update Report.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-100836- DML - Added New Report Id Pharmacy Order Update Report.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-100901 - DML - Add question A12 to LTCF Discharge.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

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


--=============================================================================
--  Issue:            CORE-100901 Add question A12 to discharge routine assessments
--  Written By:       Afzal Bhojani
--  Script Type:      DML
--                      
--  Target DB Type:   ClientDB
--  Target Database:  All 
--
--  Tested:			  DEV_CA_Scorpion_Squad_kcity on pccsql-use2-nprd-dvsh-cli0003.bbd2b72cba43.database.windows.net
--  Re-Runable:       Yes
--                      
--  Description:      Adds question A12 to discharge routine assessments.
--					  Also sets required to N for questions A12 and B2.
--					  The status_Y column is for routine discharge, covers last 3 days.
--					  The status_Q column is for routine discharge tracking only.
--=============================================================================

UPDATE 
	as_std_question
SET
	status_Y = 'M',
	status_Q = 'M'
WHERE
	std_assess_id = 23
	and question_key = 'A12'
	and (status_Y <> 'M' or status_Q <> 'M');
	
UPDATE 
	as_std_question
SET	
	required = 'N'
WHERE
	std_assess_id = 23
	and question_key in ('A12', 'B2')
	and required = 'Y'


GO

print 'A_PreUpload/CORE-100901 - DML - Add question A12 to LTCF Discharge.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-100901 - DML - Add question A12 to LTCF Discharge.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-101120 DDL Update changeset status check constraints.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

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


/*
==============================================================================
CORE-101120       Update changeset status check constraints

Written By:       Elias Ghanem
Team:			  CODA

Script Type:      DDL
Target DB Type:   CLIENT
Target Database:  BOTH
Re-Runable:       YES

Description :     Update changeset_status__status_id_CHK to allow additional values
                  Update changeset_status__status_source_CHK to check on source_id column
==============================================================================
*/


ALTER TABLE [dbo].[changeset_status]  DROP CONSTRAINT [changeset_status__status_id_CHK]
ALTER TABLE [dbo].[changeset_status]  WITH CHECK ADD  CONSTRAINT [changeset_status__status_id_CHK] CHECK  (([status_id] > 0))

ALTER TABLE [dbo].[changeset_status]  DROP CONSTRAINT [changeset_status__status_source_CHK]
ALTER TABLE [dbo].[changeset_status]  WITH CHECK ADD  CONSTRAINT [changeset_status__status_source_CHK] CHECK  (([status_source]=(3) OR [status_source]=(2) OR [status_source]=(1)))

GO




GO

print 'A_PreUpload/CORE-101120 DDL Update changeset status check constraints.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-101120 DDL Update changeset status check constraints.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-101263 - DML - Update-RNAO-Care-Content-Description.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

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
-- Jira #:               CORE-100937
--
-- Written By:           Ben Bogusat
--
-- Script Type:          DML
-- Target DB Type:       CLIENT 
-- Target ENVIRONMENT:   BOTH  
--
--
-- Re-Runable:           YES 
 
--
-- Staging Recommendations/Warnings: none
--
-- Description of Script Function: Updates RNAO Care Plan Library Description in Care Content Directory
--
-- Special Instruction: none
--
--
-- =================================================================================

BEGIN
    UPDATE [dbo].[branded_library_tier_configuration]
    SET content_general_overview = N'<p>These evidence-based Clinical Pathways are powered by the Registered Nurses'' Association of Ontario''s (RNAO) Best Practice Guidelines (BPGs). RNAO''s BPGs are developed using a rigorous research methodology with input from leading experts in various areas of clinical care. RNAO developed these Clinical Pathways specifically for the long-term care sector using BPGs that focus on geriatric care and end-of-life care. By using standard data elements and standardized tools, the Clinical Pathways allow PointClickCare''s Nursing Advantage to collect and synthesize key information which can be displayed in real-time via user-friendly dashboards to support care delivery and clinical decision making by the interprofessional team.</br></br> <i>Copyright &copy; Registered Nurses'' Association of Ontario. All rights reserved and unauthorized use, reproduction, or disclosure is prohibited except in accordance with RNAO''s published policies.</i></p>'
    WHERE brand_id = 8
      AND sequence = 1 AND type_display_name = 'Nursing Advantage - Powered By RNAO';
END
 
GO


GO

print 'A_PreUpload/CORE-101263 - DML - Update-RNAO-Care-Content-Description.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-101263 - DML - Update-RNAO-Care-Content-Description.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-101342 - DML -insert New security functions.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

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


--=======================================================================================================================
-- CORE-101342
--
-- Written By:       Security Script Generator Version 1.0.1
--
-- Script Type:      DML
-- Target DB Type:   Client
-- Target Database:  Both     (NOTE TO DEVELOPERS: DO NOT CHANGE!)
--
-- Re-Runnable:      YES
--
-- Staging Recommendations/Warnings: None
--
-- Description of Script Function:
--   Insert new security functions for...
--     * 13110.0: Resident Details (PHI)
--     * 13350.0: Performance: Quality
--     * 13350.3: Quality Indicator
--     * 13350.5: QIP
--     * 13350.7: Corporate QIP
--
--   URL: http://10.78.84.18/create?scriptType=I&issueKey=CORE-101342&moduleId=13&functionUpdates%5B1%5D.funcId=13110.0&functionUpdates%5B1%5D.parentId=13110.0&functionUpdates%5B1%5D.sequenceNo=13110.0&functionUpdates%5B1%5D.description=Resident+Details+%28PHI%29&functionUpdates%5B1%5D.environment=CDN&functionUpdates%5B1%5D.accessType=YN&functionUpdates%5B1%5D.accessLevel=C&functionUpdates%5B1%5D.accessCopyFromFuncId=13002.3&functionUpdates%5B1%5D.accessCopyFromDefault=0&functionUpdates%5B1%5D.systemRoleAccess%5B%271728%27%5D=-999&functionUpdates%5B1%5D.systemRoleAccess%5B%271729%27%5D=-999&functionUpdates%5B1%5D.systemRoleAccess%5B%271808%27%5D=-999&functionUpdates%5B1%5D.systemRoleAccess%5B%271809%27%5D=-999&functionUpdates%5B2%5D.funcId=13350.0&functionUpdates%5B2%5D.parentId=13350.0&functionUpda
--        tes%5B2%5D.sequenceNo=13350.0&functionUpdates%5B2%5D.description=Performance%3A+Quality&functionUpdates%5B2%5D.environment=CDN&functionUpdates%5B2%5D.accessType=YN&functionUpdates%5B2%5D.accessLevel=0&functionUpdates%5B2%5D.systemRoleAccess%5B%271728%27%5D=-999&functionUpdates%5B2%5D.systemRoleAccess%5B%271729%27%5D=-999&functionUpdates%5B2%5D.systemRoleAccess%5B%271808%27%5D=-999&functionUpdates%5B2%5D.systemRoleAccess%5B%271809%27%5D=-999&functionUpdates%5B3%5D.funcId=13350.3&functionUpdates%5B3%5D.parentId=13350.0&functionUpdates%5B3%5D.sequenceNo=13350.3&functionUpdates%5B3%5D.description=Quality+Indicator&functionUpdates%5B3%5D.environment=CDN&functionUpdates%5B3%5D.accessType=YN&functionUpdates%5B3%5D.accessLevel=C&functionUpdates%5B3%5D.accessCopyFromFuncId=13002.1&functionUpdates%5
--        B3%5D.accessCopyFromDefault=0&functionUpdates%5B3%5D.systemRoleAccess%5B%271728%27%5D=-999&functionUpdates%5B3%5D.systemRoleAccess%5B%271729%27%5D=-999&functionUpdates%5B3%5D.systemRoleAccess%5B%271808%27%5D=-999&functionUpdates%5B3%5D.systemRoleAccess%5B%271809%27%5D=-999&functionUpdates%5B4%5D.funcId=13350.5&functionUpdates%5B4%5D.parentId=13350.0&functionUpdates%5B4%5D.sequenceNo=13350.5&functionUpdates%5B4%5D.description=QIP&functionUpdates%5B4%5D.environment=CDN&functionUpdates%5B4%5D.accessType=RAED&functionUpdates%5B4%5D.accessLevel=C&functionUpdates%5B4%5D.accessCopyFromFuncId=13020.1&functionUpdates%5B4%5D.accessCopyFromDefault=0&functionUpdates%5B4%5D.systemRoleAccess%5B%271728%27%5D=-999&functionUpdates%5B4%5D.systemRoleAccess%5B%271729%27%5D=-999&functionUpdates%5B4%5D.systemRo
--        leAccess%5B%271808%27%5D=-999&functionUpdates%5B4%5D.systemRoleAccess%5B%271809%27%5D=-999&functionUpdates%5B5%5D.funcId=13350.7&functionUpdates%5B5%5D.parentId=13350.0&functionUpdates%5B5%5D.sequenceNo=13350.7&functionUpdates%5B5%5D.description=Corporate+QIP&functionUpdates%5B5%5D.environment=CDN&functionUpdates%5B5%5D.accessType=RAED&functionUpdates%5B5%5D.accessLevel=C&functionUpdates%5B5%5D.accessCopyFromFuncId=13020.2&functionUpdates%5B5%5D.accessCopyFromDefault=0&functionUpdates%5B5%5D.systemRoleAccess%5B%271728%27%5D=-999&functionUpdates%5B5%5D.systemRoleAccess%5B%271729%27%5D=-999&functionUpdates%5B5%5D.systemRoleAccess%5B%271808%27%5D=-999&functionUpdates%5B5%5D.systemRoleAccess%5B%271809%27%5D=-999
--
-- Special Instruction: Can be run prior to upload of code
--
--=======================================================================================================================
-- CONSTANTS
DECLARE @NOW datetime
SET @NOW = GETDATE()
-- SPECS
DECLARE @moduleId int, @createdBy varchar(70)
-- TEMP TABLE
DECLARE @sec_function__ins TABLE (func_id varchar(10), deleted char(1), created_by varchar(60), created_date datetime, module_id int, [type] varchar(8), description varchar(70), parent_function varchar(1), sequence_no float, facility_type varchar(5)
    PRIMARY KEY (func_id))
DECLARE @sec_role_function__ins TABLE (role_id int, func_id varchar(10), created_by varchar(60), created_date datetime, revision_by varchar(60), revision_date datetime, access_level int,
    PRIMARY KEY (role_id, func_id))
SET @moduleId = 13
SET @createdBy = 'CORE-101342'
--========================================================================================================
-- 13110.0: Resident Details (PHI)
--========================================================================================================
-- (1) Prepare @sec_function__ins ===========================================================
INSERT INTO @sec_function__ins (func_id, deleted, created_by, created_date, module_id, [type], description, parent_function, sequence_no, facility_type)
    VALUES ('13110.0', 'N', @createdBy, @NOW, @moduleId, 'YN', 'Resident Details (PHI)', 'Y', 13110.0, 'CDN')
-- (2) Prepare @sec_role_function__ins ======================================================
-- (2a) Add new function to all appropriate roles ------------------------------
INSERT INTO @sec_role_function__ins (role_id, func_id, created_by, created_date, revision_by, revision_date, access_level)
    SELECT DISTINCT role_id, '13110.0', @createdBy, @NOW, NULL, NULL, 0 FROM sec_role r
    WHERE @moduleId = 10 -- new functions in the "All" module are applicable to every role
        OR (module_id = @moduleId AND description <> 'Collections Setup (system)' AND description <> 'Collections User (system)')
        OR (module_id = 0 AND EXISTS (SELECT 1 FROM sec_role_function rf INNER JOIN sec_function f ON rf.func_id = f.func_id WHERE f.module_id = @moduleId AND rf.role_id = r.role_id))
-- (2b) Default Permissions: Copy from another function ------------------------
UPDATE f
    SET access_level = CASE WHEN src.access_level >= 0 THEN src.access_level ELSE 0 END
FROM @sec_role_function__ins f
    INNER JOIN sec_role_function src ON f.role_id = src.role_id
WHERE f.func_id = '13110.0' AND src.func_id = '13002.3'
--========================================================================================================
-- 13350.0: Performance: Quality
--========================================================================================================
-- (1) Prepare @sec_function__ins ===========================================================
INSERT INTO @sec_function__ins (func_id, deleted, created_by, created_date, module_id, [type], description, parent_function, sequence_no, facility_type)
    VALUES ('13350.0', 'N', @createdBy, @NOW, @moduleId, 'YN', 'Performance: Quality', 'Y', 13350.0, 'CDN')
-- (2) Prepare @sec_role_function__ins ======================================================
-- (2a) Add new function to all appropriate roles ------------------------------
INSERT INTO @sec_role_function__ins (role_id, func_id, created_by, created_date, revision_by, revision_date, access_level)
    SELECT DISTINCT role_id, '13350.0', @createdBy, @NOW, NULL, NULL, 0 FROM sec_role r
    WHERE @moduleId = 10 -- new functions in the "All" module are applicable to every role
        OR (module_id = @moduleId AND description <> 'Collections Setup (system)' AND description <> 'Collections User (system)')
        OR (module_id = 0 AND EXISTS (SELECT 1 FROM sec_role_function rf INNER JOIN sec_function f ON rf.func_id = f.func_id WHERE f.module_id = @moduleId AND rf.role_id = r.role_id))
--========================================================================================================
-- 13350.3: Quality Indicator
--========================================================================================================
-- (1) Prepare @sec_function__ins ===========================================================
INSERT INTO @sec_function__ins (func_id, deleted, created_by, created_date, module_id, [type], description, parent_function, sequence_no, facility_type)
    VALUES ('13350.3', 'N', @createdBy, @NOW, @moduleId, 'YN', 'Quality Indicator', 'N', 13350.3, 'CDN')
-- (2) Prepare @sec_role_function__ins ======================================================
-- (2a) Add new function to all appropriate roles ------------------------------
INSERT INTO @sec_role_function__ins (role_id, func_id, created_by, created_date, revision_by, revision_date, access_level)
    SELECT DISTINCT role_id, '13350.3', @createdBy, @NOW, NULL, NULL, 0 FROM sec_role r
    WHERE @moduleId = 10 -- new functions in the "All" module are applicable to every role
        OR (module_id = @moduleId AND description <> 'Collections Setup (system)' AND description <> 'Collections User (system)')
        OR (module_id = 0 AND EXISTS (SELECT 1 FROM sec_role_function rf INNER JOIN sec_function f ON rf.func_id = f.func_id WHERE f.module_id = @moduleId AND rf.role_id = r.role_id));
-- (2b) Default Permissions: Copy from another function ------------------------
WITH src AS (
    SELECT role_id, MAX(access_level) as access_level
    FROM sec_role_function
    WHERE func_id in ('13002.1', '13002.2')
    GROUP BY role_id
)
UPDATE f
    SET f.access_level = CASE WHEN src.access_level >= 0 THEN src.access_level ELSE 0 END
FROM @sec_role_function__ins f
    INNER JOIN src ON f.role_id = src.role_id
WHERE f.func_id = '13350.3'
--========================================================================================================
-- 13350.5: QIP
--========================================================================================================
-- (1) Prepare @sec_function__ins ===========================================================
INSERT INTO @sec_function__ins (func_id, deleted, created_by, created_date, module_id, [type], description, parent_function, sequence_no, facility_type)
    VALUES ('13350.5', 'N', @createdBy, @NOW, @moduleId, 'RAED', 'QIP', 'N', 13350.5, 'CDN')
-- (2) Prepare @sec_role_function__ins ======================================================
-- (2a) Add new function to all appropriate roles ------------------------------
INSERT INTO @sec_role_function__ins (role_id, func_id, created_by, created_date, revision_by, revision_date, access_level)
    SELECT DISTINCT role_id, '13350.5', @createdBy, @NOW, NULL, NULL, 0 FROM sec_role r
    WHERE @moduleId = 10 -- new functions in the "All" module are applicable to every role
        OR (module_id = @moduleId AND description <> 'Collections Setup (system)' AND description <> 'Collections User (system)')
        OR (module_id = 0 AND EXISTS (SELECT 1 FROM sec_role_function rf INNER JOIN sec_function f ON rf.func_id = f.func_id WHERE f.module_id = @moduleId AND rf.role_id = r.role_id))
-- (2b) Default Permissions: Copy from another function ------------------------
UPDATE f
    SET access_level = CASE WHEN src.access_level >= 0 THEN src.access_level ELSE 0 END
FROM @sec_role_function__ins f
    INNER JOIN sec_role_function src ON f.role_id = src.role_id
WHERE f.func_id = '13350.5' AND src.func_id = '13020.1'
--========================================================================================================
-- 13350.7: Corporate QIP
--========================================================================================================
-- (1) Prepare @sec_function__ins ===========================================================
INSERT INTO @sec_function__ins (func_id, deleted, created_by, created_date, module_id, [type], description, parent_function, sequence_no, facility_type)
    VALUES ('13350.7', 'N', @createdBy, @NOW, @moduleId, 'RAED', 'Corporate QIP', 'N', 13350.7, 'CDN')
-- (2) Prepare @sec_role_function__ins ======================================================
-- (2a) Add new function to all appropriate roles ------------------------------
INSERT INTO @sec_role_function__ins (role_id, func_id, created_by, created_date, revision_by, revision_date, access_level)
    SELECT DISTINCT role_id, '13350.7', @createdBy, @NOW, NULL, NULL, 0 FROM sec_role r
    WHERE @moduleId = 10 -- new functions in the "All" module are applicable to every role
        OR (module_id = @moduleId AND description <> 'Collections Setup (system)' AND description <> 'Collections User (system)')
        OR (module_id = 0 AND EXISTS (SELECT 1 FROM sec_role_function rf INNER JOIN sec_function f ON rf.func_id = f.func_id WHERE f.module_id = @moduleId AND rf.role_id = r.role_id))
-- (2b) Default Permissions: Copy from another function ------------------------
UPDATE f
    SET access_level = CASE WHEN src.access_level >= 0 THEN src.access_level ELSE 0 END
FROM @sec_role_function__ins f
    INNER JOIN sec_role_function src ON f.role_id = src.role_id
WHERE f.func_id = '13350.7' AND src.func_id = '13020.2'
--========================================================================================================
-- Apply changes
--========================================================================================================
BEGIN TRAN
BEGIN TRY
    DELETE FROM sec_function WHERE func_id IN ('13110.0', '13350.0', '13350.3', '13350.5', '13350.7')
    DELETE FROM sec_role_function WHERE func_id IN ('13110.0', '13350.0', '13350.3', '13350.5', '13350.7')
    INSERT INTO sec_function (func_id, deleted, created_by, created_date, module_id, [type], description, parent_function, sequence_no, facility_type)
        SELECT func_id, deleted, created_by, created_date, module_id, [type], description, parent_function, sequence_no, facility_type FROM @sec_function__ins
    INSERT INTO sec_role_function (role_id, func_id, created_by, created_date, revision_by, revision_date, access_level)
        SELECT role_id, func_id, created_by, created_date, revision_by, revision_date, access_level FROM @sec_role_function__ins
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN
    DECLARE @err NVARCHAR(3000)
    SET @err = 'Error creating security functions for ' + @createdBy + ': ' + ERROR_MESSAGE()
    RAISERROR(@err, 16, 1)
END CATCH
IF @@TRANCOUNT > 0
    COMMIT TRAN

GO

print 'A_PreUpload/CORE-101342 - DML -insert New security functions.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-101342 - DML -insert New security functions.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-101400 - DML - Add questions R1 R2 to LTCF Update.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

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


--=============================================================================
--  Issue:            CORE-101400 Add questions R1 and R2 to the update assessment
--  Written By:       Afzal Bhojani
--  Script Type:      DML
--                      
--  Target DB Type:   ClientDB
--  Target Database:  All 
--
--  Tested:			  DEV_CA_Scorpion_Squad_kcity on pccsql-use2-nprd-dvsh-cli0003.bbd2b72cba43.database.windows.net
--  Re-Runable:       Yes
--                      
--  Description:      Adds questions R1, R2, R3, and R4 to the update assessments.
--					  Update the acceptable range for question AD1.
--					  Update the control_type and range for question AD2.
--					  Update the acceptable range for question AD3.
--					  Set required for B5a to N.
--					  The status_D column is for the update assessment.
--=============================================================================

UPDATE 
	as_std_question
SET
	status_D = 'M',
	required = 'N'
WHERE
	std_assess_id = 23
	and question_key in ('R1', 'R2', 'R3', 'R4')
	and (status_D <> 'M')
	and (required <> 'N');
	
UPDATE
	as_std_question
SET
	range = 'sp,0,1'
WHERE
	std_assess_id = 23
	and question_key = 'AD1';
	
UPDATE
	as_std_question
SET
	control_type = 'cmb',
	range = 'Valid code,sp(2)'
WHERE
	std_assess_id = 23
	and question_key = 'AD2';
	
UPDATE
	as_std_question
SET
	range = 'alphanumeric'
WHERE
	std_assess_id = 23
	and question_key = 'AD3'

UPDATE 
	as_std_question
SET
	required = 'N'
WHERE
	std_assess_id = 23
	and question_key = 'B5a'
	and (required <> 'N');


GO

print 'A_PreUpload/CORE-101400 - DML - Add questions R1 R2 to LTCF Update.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-101400 - DML - Add questions R1 R2 to LTCF Update.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-101599 - DDL - Add index to sec_role_function.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

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


--=============================================================================
--  Issue:			  CORE-101599
--  Written By:		  Jonathan Tecson
--  Script Type:      DDL
--  Target DB Type:   Client
--  Target Database:  BOTH
--  Re-Runnable:       Yes
--  Description :     Add index to the sec_role_function for performance improvement in query for view_sc_user_resident_access.
--
--=============================================================================

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'sec_role_function__funcId_INC_accessLevel_IX')
BEGIN
    CREATE NONCLUSTERED INDEX [sec_role_function__funcId_INC_accessLevel_IX]
        ON [dbo].[sec_role_function] ([func_id]) INCLUDE ([access_level])
END


GO

print 'A_PreUpload/CORE-101599 - DDL - Add index to sec_role_function.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-101599 - DDL - Add index to sec_role_function.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-101691- DDL - Create new table for the chart code history.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

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



-- CORE-100298	
-- Written By:          Dominic Christie
-- Reviewed By:
--
-- Script Type:          
-- Target DB Type:       CLIENT
-- Target ENVIRONMENT:   BOTH
--
--
-- Re-Runnable:          YES
--
-- Where tested:          pccsql-use2-nprd-dvsh-cli0001.bbd2b72cba43.database.windows.net ( dev_hcr_bip25982) database )
--
--In an event of fac acquistion this table will be populated with the historical chart code information
--
-- =================================================================================

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='chart_code_history')

BEGIN


CREATE TABLE dbo.chart_code_history(--In an event of fac acquistion this table will be populated with the historical chart code information

	item_id INT IDENTITY(1,1) NOT NULL, --:PHI=N:Desc:used as unique incremental id--:PHI=N:Desc:used as unique incremental id
	origin_item_id INT NOT NULL, --:PHI=N:Desc: uniquie id from the origin facility
	fac_id INT NOT NULL, --:PHI=N:Desc:facility in the destination mapped to
	origin_fac_id INT NOT NULL, --:PHI=N:Desc: origin facility 
	deleted CHAR(1) NOT NULL, --:PHI=N:Desc:deleted flag for the deleted code
	created_by VARCHAR(60) NOT NULL, --:PHI=N:Desc:code created by user
	created_date DATETIME NOT NULL, --:PHI=N:Desc:code created date
	ineffective_date  DATETIME NOT NULL, --:PHI=N:Desc:chart code ineffective date when the code stopped being used
	item_code VARCHAR(6) NOT NULL, --:PHI=N:Desc:the code for the chart
	item_description VARCHAR(254) NULL, --:PHI=N:Desc:description of the chart code
	short_description VARCHAR(50) NULL, --:PHI=N:Desc: short decirption for the chart code
	deleted_by VARCHAR(60) NULL, --:PHI=N:Desc:deleted by user 
	deleted_date DATETIME NULL, --:PHI=N:Desc:date when chart code was deleted 
	state_code VARCHAR(3) NULL, --:PHI=N:Desc:state code for the facility
	reg_id INT NULL --- :PHI=N:Desc: regional id used for scoping


	  CONSTRAINT [chart_code_history_itemId_PK_CL_IX] PRIMARY KEY CLUSTERED 
(
   [item_id] ASC
)
	)

END







GO

print 'A_PreUpload/CORE-101691- DDL - Create new table for the chart code history.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-101691- DDL - Create new table for the chart code history.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-101821 - DDL - drop unused sprocs.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

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


--=======================================================================================================================
-- CORE-101821 cleanup sp
--
-- Written By:       Kimt
--
-- Script Type:      DDL
-- Target DB Type:   Client
-- Target Database:  Both     
--
-- Re-Runnable:      YES
--
-- Staging Recommendations/Warnings: None
--
-- Description of Script Function:
--   drop sproc_pbj_dml_savePayerCategories and sproc_pbj_list_getPayers
-- 
-- Special Instruction: Can be run prior to upload of code
--
--=======================================================================================================================

/**
-- test

    SELECT ROUTINE_TYPE, ROUTINE_NAME
    FROM INFORMATION_SCHEMA.ROUTINES
    WHERE ROUTINE_SCHEMA = 'dbo'
          AND ROUTINE_NAME in (  'sproc_pbj_dml_savePayerCategories' , 'sproc_pbj_list_getPayers')
          AND ROUTINE_TYPE = 'PROCEDURE'

*/
IF EXISTS
(
    SELECT 1
    FROM INFORMATION_SCHEMA.ROUTINES
    WHERE ROUTINE_SCHEMA = 'dbo'
          AND ROUTINE_NAME = 'sproc_pbj_dml_savePayerCategories' 
          AND ROUTINE_TYPE = 'PROCEDURE'
)
BEGIN
	DROP PROCEDURE dbo.sproc_pbj_dml_savePayerCategories;

END;


IF EXISTS
(
    SELECT 1
    FROM INFORMATION_SCHEMA.ROUTINES
    WHERE ROUTINE_SCHEMA = 'dbo'
          AND ROUTINE_NAME='sproc_pbj_list_getPayers'
          AND ROUTINE_TYPE = 'PROCEDURE'
)
BEGIN
	DROP PROCEDURE dbo.sproc_pbj_list_getPayers;
END

GO




GO

print 'A_PreUpload/CORE-101821 - DDL - drop unused sprocs.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-101821 - DDL - drop unused sprocs.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-91077 - DML - ClientDB_modify misspelt word.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

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
-- Jira #:               CORE-91077 Infection Screening Evaluation (system) has misspelt word in the Instruction Control
-- Written By:           pcc developer
-- Script Type:          DML
-- Target DB Type:       ClientDB
-- Re-Runable:           YES
-- Description:          Update the question_text from as_std_question table

-- =================================================================================


UPDATE
    aq
SET
    aq.question_text = 'This infection screening tool is designed to assist in identifying if a resident has clinical findings needed to determine if they MEET or have SUSPECTED infection based on McGeer''s or Loeb''s criteria. Upon navigating to the next section, the system will identify if criteria should be further investigated and a score will be generated. If the score is > 1 a case will be created in IPC. This evaluation is not meant to diagnose. Clinical findings should be reviewed with the provider. '
FROM
    as_std_question aq
JOIN
    as_std_assessment_system_assessment_mapping amap on amap.std_assess_id = aq.std_assess_id
WHERE
    amap.system_type_id = 383
    AND aq.question_key = 'Cust_EV_INST_I'
    AND aq.question_text = 'This infection screening tool is designed to assist in identifying if a resident has clinical findings needed to determine if they MEET or have SUSPECTED infection based on McGeer''s or Loeb''s criteria. Upon navigating to the next section, the system will identify if criteria should be further investigated and a score will be generated. If the score is > 1 a case will be created in IPC. This evaluation is not meant to diagnosis. Clinical findings should be reviewed with the provider. '

GO

print 'A_PreUpload/CORE-91077 - DML - ClientDB_modify misspelt word.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-91077 - DML - ClientDB_modify misspelt word.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-94188 - DDL - drop AR_RATES_CORE_92136 table.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

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
-- CORE-94188:			Drop AR_RATES_CORE_92136 table
--
-- Written By:          Thomas Kim
-- Reviewed By:         
-- Script Type:         TABLE
-- Target DB Type:      CLIENT
-- Target Database:		
-- Re-Runable:			Yes
-- Description :		this script will drop AR_RATES_CORE_92136 that created for backup
--  
-- Special Instruction: None
-- ======================

IF  EXISTS (SELECT 1
				FROM INFORMATION_SCHEMA.TABLES 
				WHERE TABLE_SCHEMA = 'dbo' and TABLE_NAME ='AR_RATES_CORE_92136')

	DROP table dbo.AR_RATES_CORE_92136

GO


GO

print 'A_PreUpload/CORE-94188 - DDL - drop AR_RATES_CORE_92136 table.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-94188 - DDL - drop AR_RATES_CORE_92136 table.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97915 DDL 01 Data Mart - add rr_census_rate_change_date field to clients.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

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


/*
==============================================================================
CORE-97915        Census Data Mart Relay Part 2

Written By:       Andrei Medvedev

Script Type:      DDL
Target DB Type:   Client
Target Database:  BOTH
Re-Runable:       YES

Description :     Add rr_census_rate_change_date field to clients table
                  For Census Data Mart load process
==============================================================================
*/

IF NOT EXISTS (
		SELECT 1
		FROM information_schema.columns
		WHERE table_name = 'clients'
			AND column_name = 'rr_census_rate_change_date'
			AND table_schema = 'dbo'
	)
BEGIN
	ALTER TABLE dbo.clients
		ADD rr_census_rate_change_date DATETIME NULL		--:PHI=N:Desc:RR functionality census, rate updates tracking field
	;
END

GO


GO

print 'A_PreUpload/CORE-97915 DDL 01 Data Mart - add rr_census_rate_change_date field to clients.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-97915 DDL 01 Data Mart - add rr_census_rate_change_date field to clients.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/US_Only/CORE-101498 - DML - NY 4397A - 1 - Client.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

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


--=============================================================================
--  Issue:            CORE-98262
--  Written By:       pcc developer
--  Script Type:      DML
--  Target DB Type:   ClientDB
--  Target Database:  Both
--  Re-Runable:       Yes
--  Description :     
--=============================================================================

DECLARE
  @std_assess_id_to_delete            int
  ,@assessment_name                   varchar(600)
  ,@revision_by                       varchar(100)
  ,@revision_date                     DATETIME
  ,@reuse_std_assess_id               char(1)
  ,@pn_type_in_use                    bit = 0
  ,@pn_type_used_by_other_ass         bit = 0
  ,@pn_template_used_by_other_pn_type bit = 0
  ,@pn_type_id_to_delete              int = NULL
  ,@stateCode                         varchar(3) = 'NY'
  ,@brand_pn_template_key varchar(50) = 'V0P'
  ,@brand_pn_type_key varchar(50) = 'V0T'
  ,@pgpk_script_cmd NVARCHAR(max)
  ,@pgpk_table_name VARCHAR(128)
  ,@pgpk_column_name VARCHAR(128)
;

DECLARE @cdn_ccrs_mds_2_id int = 3
IF EXISTS (SELECT 1 from as_std_assessment assess where assess.std_assess_id = @cdn_ccrs_mds_2_id)
BEGIN -- Beginning of Script
DECLARE @new_brand_id int = null

DECLARE @existing_pn_type_id int = null;
 SELECT @existing_pn_type_id = pn_type_id
   FROM pn_type
  WHERE brand_id = @new_brand_id and brand_pn_type_key  is null

DECLARE @deleted_as_std_assessment_facility TABLE (fac_id int      PRIMARY KEY);

SET @reuse_std_assess_id = 'N'
SET @assessment_name = N'NY DOH-4397A Personal Data Form_Revised - V 2.1';  -- TO CHECK: Make sure the assessment name does not contain ALF prefix
SET @revision_by = 'CORE-98262'
SET @revision_date = GETDATE()

-----Rename orginal custom UDA to avoid name conflict----------
if exists (select 1 from as_std_assessment assess left join as_std_assessment_system_assessment_mapping map ON assess.std_assess_id = map.std_assess_id where description = @assessment_name and deleted='N' and map.system_type_id is null)
BEGIN
  update assess 
  set description = @assessment_name + ' ORIGINAL'
  from as_std_assessment assess 
  left join as_std_assessment_system_assessment_mapping map ON assess.std_assess_id = map.std_assess_id 
  where description = @assessment_name and deleted='N' and map.system_type_id is null
END

IF @new_brand_id IS NOT NULL
BEGIN
UPDATE as_std_assessment
   SET brand_id = null
      ,brand_assessment_key = null
 WHERE brand_id = @new_brand_id  AND brand_assessment_key = ''
   AND version = '0'
END

----cleanup------------------------

IF (@new_brand_id is NULL OR 
     EXISTS(select 1 from as_std_assessment assess join as_std_assessment_system_assessment_mapping map ON assess.std_assess_id = map.std_assess_id 
             where description = @assessment_name and deleted='N' and is_currentVersion = 1))
BEGIN
select @std_assess_id_to_delete= assess.std_assess_id from as_std_assessment assess join as_std_assessment_system_assessment_mapping map ON assess.std_assess_id = map.std_assess_id where description = @assessment_name and deleted='N'

SELECT @pn_type_id_to_delete = ptype.pn_type_id
  FROM pn_std_spn pss
  JOIN pn_type ptype
    ON pss.pn_type_id = ptype.pn_type_id
 WHERE pss.std_assess_id = @std_assess_id_to_delete

IF EXISTS(SELECT 1
           FROM pn_type ptype
           JOIN pn_template ptemp
             ON ptype.template_id = ptemp.template_id
           JOIN pn_progress_note pn
             ON ptemp.template_id = pn.template_id and pn.deleted <> 'N'
          WHERE ptype.pn_type_id = coalesce(@pn_type_id_to_delete, @existing_pn_type_id))
BEGIN
   SET @pn_type_in_use = 1;
END
IF EXISTS(SELECT 1
           FROM pn_type ptype
           JOIN pn_std_spn pss_other
             ON ptype.pn_type_id = pss_other.pn_type_id
            AND (pss_other.std_assess_id != @std_assess_id_to_delete or @std_assess_id_to_delete is null)
          WHERE ptype.pn_type_id = coalesce(@pn_type_id_to_delete, @existing_pn_type_id))
BEGIN
   SET @pn_type_used_by_other_ass = 1;
END
IF EXISTS(SELECT 1
           FROM pn_type ptype
           JOIN pn_type ptype_other
             ON ptype.template_id = ptype_other.template_id
            AND ptype.pn_type_id != ptype_other.pn_type_id
          WHERE ptype.pn_type_id = coalesce(@pn_type_id_to_delete, @existing_pn_type_id))
BEGIN
   SET @pn_template_used_by_other_pn_type = 1;
END

IF EXISTS (select 1 from as_std_assessment assess join as_std_assessment_system_assessment_mapping map ON assess.std_assess_id = map.std_assess_id where description = @assessment_name and deleted='N')
BEGIN
  set @reuse_std_assess_id = 'Y'

 DECLARE  @schedsForDeletion  table (
 schedule_id int
);
With  Recurse (schedule_id, next_schedule)
AS
( 
SELECT schedule_id, next_schedule
FROM as_std_assess_schedule sched 
JOIN as_std_trigger trig ON (triggered_item_id = sched.schedule_id AND
event_id = trig.std_trigger_id AND trig.std_assess_id = @std_assess_id_to_delete)
 
UNION ALL
SELECT d.schedule_id, d.next_schedule
FROM Recurse r
JOIN as_std_assess_schedule d ON d.schedule_id=r.next_schedule
)
INSERT INTO @schedsForDeletion 
SELECT schedule_id FROM Recurse
 
IF EXISTS (SELECT 1 FROM @schedsForDeletion ) BEGIN
  PRINT 'Deleting the following schedules: '
  SELECT * FROM @schedsForDeletion
  DELETE FROM as_std_assess_schedule_payer_type_mapping WHERE schedule_id IN (SELECT schedule_id FROM @schedsForDeletion);
  DELETE FROM as_std_assess_schedule WHERE schedule_id IN (SELECT schedule_id FROM @schedsForDeletion);
END
  DELETE FROM as_std_trigger where std_assess_id = @std_assess_id_to_delete
  DELETE FROM as_std_assess_header where std_assess_id = @std_assess_id_to_delete
  DELETE item FROM as_std_score_item item JOIN as_std_score score on item.std_score_id = score.std_score_id WHERE score.std_assess_id =  @std_assess_id_to_delete
  DELETE asscore from as_assessment_score asscore join as_std_score stdscore ON asscore.std_score_id = stdscore.std_score_id where stdscore.std_assess_id=@std_assess_id_to_delete
  DECLARE @image_id_to_delete int;
  SELECT @image_id_to_delete = img.image_id FROM dbo.as_std_assessment_cfg_image_mapping map INNER JOIN dbo.cfg_image img ON img.image_id = map.image_id WHERE map.std_assess_id = @std_assess_id_to_delete;
  IF (@image_id_to_delete IS NOT NULL)
  BEGIN
     DELETE FROM dbo.as_std_assessment_cfg_image_mapping WHERE std_assess_id = @std_assess_id_to_delete;
     DELETE FROM dbo.cfg_image WHERE image_id = @image_id_to_delete;
  END
  DELETE FROM cp_std_lookback_question where std_assess_id = @std_assess_id_to_delete
  DELETE FROM as_std_category where std_assess_id = @std_assess_id_to_delete
  DELETE FROM as_assess_census where std_assess_id = @std_assess_id_to_delete
  IF EXISTS (SELECT 1 FROM sysobjects WHERE xtype = 'U' AND name = 'as_std_assess_schedule_payer_type_mapping') 
  BEGIN 
    DELETE payerSched 
    FROM as_std_assess_schedule_payer_type_mapping payerSched 
      join as_std_assess_schedule sched on sched.schedule_id=payerSched.schedule_id 
      where sched.std_assess_id = @std_assess_id_to_delete 
  END 
  DELETE FROM as_std_assess_schedule where std_assess_id = @std_assess_id_to_delete
  DELETE FROM as_std_score  where std_assess_id = @std_assess_id_to_delete
  DELETE rnge FROM as_consistency_rule_range rnge join as_consistency_rule rul on rnge.consistency_rule_id = rul.consistency_rule_id where rul.std_assess_id = @std_assess_id_to_delete
  DELETE FROM as_consistency_rule where std_assess_id = @std_assess_id_to_delete
  UPDATE cr_std_highrisk_desc SET deleted = 'Y', deleted_date = @revision_date, deleted_by = @revision_by where std_obj_id = @std_assess_id_to_delete
  DELETE FROM as_std_question_group where std_assess_id = @std_assess_id_to_delete
  DELETE FROM as_std_question_group_active_date_range where std_assess_id = @std_assess_id_to_delete
  DELETE item FROM as_std_pick_list_item item join as_std_pick_list list on item.pick_list_id = list.pick_list_id where list.std_assess_id = @std_assess_id_to_delete
  DELETE FROM as_std_pick_list where std_assess_id = @std_assess_id_to_delete
  DELETE FROM as_std_question_lookback_window where std_assess_id = @std_assess_id_to_delete
  DELETE FROM as_std_question where std_assess_id = @std_assess_id_to_delete
  DELETE FROM as_std_question_qlib_question_autopopulate_rule_mapping where std_assess_id = @std_assess_id_to_delete
  DELETE sect FROM as_assessment_section sect join as_assessment assess on sect.assess_id = assess.assess_id where assess.fac_id = -1 and assess.client_id = -9999 and assess.std_assess_id = @std_assess_id_to_delete
  DELETE FROM as_assessment_section where assess_id in (select assess_id from as_assessment where fac_id = -1 and client_id = -9999 and std_assess_id = @std_assess_id_to_delete)
  DELETE FROM as_std_assessment_system_assessment_mapping where std_assess_id = @std_assess_id_to_delete
  insert into @deleted_as_std_assessment_facility (fac_id) select fac_id from as_std_assessment_facility where std_assess_id = @std_assess_id_to_delete;
  DELETE FROM as_std_assessment_facility where std_assess_id = @std_assess_id_to_delete
  DELETE FROM as_std_section where std_assess_id = @std_assess_id_to_delete
  DELETE FROM as_std_assess_type where std_assess_id = @std_assess_id_to_delete
  DELETE FROM as_std_assess_PRINT_option where std_assess_id = @std_assess_id_to_delete
  DELETE FROM as_std_question_qlib_form_question_mapping where std_assess_id = @std_assess_id_to_delete
  DELETE FROM as_std_pick_list_item_value_qlib_form_field_mapping where std_assess_id = @std_assess_id_to_delete
  DELETE FROM pn_spn_narrative_response where std_assess_id = @std_assess_id_to_delete
  DELETE FROM pn_std_spn_variable where std_spn_id in (select std_spn_id from pn_std_spn where std_assess_id = @std_assess_id_to_delete);
  DELETE FROM pn_std_spn_text where std_spn_id in (select std_spn_id from pn_std_spn where std_assess_id = @std_assess_id_to_delete);
  DELETE FROM pn_std_spn where std_assess_id = @std_assess_id_to_delete
  IF (@pn_type_in_use = 0 AND @pn_type_used_by_other_ass = 0 AND @pn_template_used_by_other_pn_type = 0)
  BEGIN
     UPDATE pn_template_section set deleted = 'Y', deleted_by=@revision_by, deleted_date=@revision_date WHERE template_id in (select template_id from pn_type where pn_type_id = @pn_type_id_to_delete)
     UPDATE pn_template  set deleted = 'Y', deleted_by=@revision_by, deleted_date=@revision_date WHERE template_id in (select template_id from pn_type where pn_type_id = @pn_type_id_to_delete)
     DELETE FROM pn_type_activation where pn_type_id = @pn_type_id_to_delete
     DELETE FROM pn_type WHERE pn_type_id = @pn_type_id_to_delete
  END
  IF EXISTS (SELECT 1 FROM sysobjects WHERE xtype = 'U' AND name = 'as_std_qlib_form_custom_data') 
  BEGIN 
    DELETE FROM as_std_qlib_form_custom_data where std_assess_id = @std_assess_id_to_delete 
  END
  IF EXISTS (SELECT 1 FROM sysobjects WHERE xtype = 'U' AND name = 'as_std_qlib_form_field_format') 
  BEGIN 
    DELETE FROM as_std_qlib_form_field_format where std_assess_id = @std_assess_id_to_delete 
  END
  DELETE FROM as_assess_schedule_clear_response where schedule_id in(select schedule_id from as_assess_schedule where std_assess_id=@std_assess_id_to_delete)
  DELETE FROM as_assess_schedule_details_exception_from_rule  where exists (select 1 from as_assess_schedule s join as_assess_schedule_details d ON s.std_assess_id = @std_assess_id_to_delete AND s.schedule_id = d.schedule_id AND  d.detail_id = as_assess_schedule_details_exception_from_rule.detail_id)
  DELETE FROM as_assess_schedule_details where exists (select 1 from as_assess_schedule s where s.std_assess_id = @std_assess_id_to_delete and s.schedule_id = as_assess_schedule_details.schedule_id)
  DELETE FROM as_assess_schedule where std_assess_id = @std_assess_id_to_delete

  DELETE FROM as_assessment where client_id=-9999 and std_assess_id = @std_assess_id_to_delete
  DELETE FROM as_std_assess_version_delete_question where std_assess_id = @std_assess_id_to_delete
  DELETE FROM as_std_assess_version_move_question where original_std_assess_id = @std_assess_id_to_delete or new_std_assess_id = @std_assess_id_to_delete
  DELETE FROM as_std_assessment where std_assess_id = @std_assess_id_to_delete

END

END

if not exists (select 1 from as_std_assessment where description = @assessment_name and deleted='N')
BEGIN
DECLARE @new_assess_id int
DECLARE @new_std_assess_id int
SET @pgpk_table_name = 'as_assessment'; 
SET @pgpk_column_name = 'assess_id'; 
SET @pgpk_script_cmd = ('UPDATE pgpk' + 
                        '   SET pgpk.next_key = actual.next_key' + 
                        '  FROM dbo.pcc_global_primary_key pgpk' + 
                        ' CROSS APPLY (SELECT MAX([' + @pgpk_column_name + ']) + 1 as next_key FROM dbo.[' + @pgpk_table_name + ']) actual' + 
                        ' WHERE pgpk.table_name = ' + quotename(@pgpk_table_name, '''') +  
                        '   AND pgpk.key_column_name = ' + quotename(@pgpk_column_name, '''') + 
                        '   AND pgpk.next_key < actual.next_key') 
EXEC sp_executesql @pgpk_script_cmd; 
EXEC get_next_primary_key @pgpk_table_name, @pgpk_column_name, @new_assess_id  OUTPUT, 1
if @reuse_std_assess_id = 'Y'
begin
  set @new_std_assess_id = @std_assess_id_to_delete
end
else
begin
  SET @pgpk_table_name = 'as_std_assessment'; 
  SET @pgpk_column_name = 'std_assess_id'; 
  SET @pgpk_script_cmd = ('UPDATE pgpk' + 
                        '   SET pgpk.next_key = actual.next_key' + 
                        '  FROM dbo.pcc_global_primary_key pgpk' + 
                        ' CROSS APPLY (SELECT MAX([' + @pgpk_column_name + ']) + 1 as next_key FROM dbo.[' + @pgpk_table_name + ']) actual' + 
                        ' WHERE pgpk.table_name = ' + quotename(@pgpk_table_name, '''') +  
                        '   AND pgpk.key_column_name = ' + quotename(@pgpk_column_name, '''') + 
                        '   AND pgpk.next_key < actual.next_key') 
  EXEC sp_executesql @pgpk_script_cmd; 
  EXEC get_next_primary_key @pgpk_table_name, @pgpk_column_name, @new_std_assess_id  OUTPUT, 1
end


-- 1.  Extract data from as_assessment
INSERT INTO [as_assessment] ([assess_id], [fac_id], [deleted], [created_by], [created_date], [revision_by], [revision_date], [client_id], [std_assess_id], [assess_type_code], [assess_date], [status], [adl_score], [adl_date], [raps_date], [rugs_index], [rugs_date], [rugs_error], [prov_state], [batch_id], [edited_by], [edited_date], [locked_date], [incorrect_assess_id], [cmi_set_fed], [cmi_set_state], [rugs_index_state], [rugs_error_state], [cmi_fed], [cmi_state], [calc_type_fed], [calc_type_state], [rugs_date_state], [score2], [score3], [cmi_code_fed], [cmi_code_state], [submit_by_date], [mpaf], [assess_ref_date], [primary_reason_code], [secondary_reason_code], [DELETED_BY], [DELETED_DATE], [facesheet], [doublescore1], [tertiary_reason_code], [cps], [pain_scale], [drs], [communication_scale], [adl_short], [adl_long], [adl_hier], [ise], [maple_date], [consent_status], [consent_reason], [import_process_id], [import_status], [verify_id], [sub_req], [prod_assess_id], [migrate_error], [include_cmi_state_flag], [include_cmi_fed_flag], [raps_type], [completed_date], [effective_cmi_date], [reg_id], [export_filter_date], [version_code], [confirmed_by], [confirmed_date], [temp_cmi_fed], [temp_cmi_code_fed], [temp_rugs_index], [chess_score], [inquiry_id], [effective_date], [ineffective_date], [hipps_modifier], [strikeout_flag], [strikeout_desc], [strikeout_by], [strikeout_date], [abs], [alt_cmi_set_state], [alt_calc_type_state], [used_for_payment], [submission_req])VALUES (@new_assess_id,-1,N'N',N'CORE-98262',getdate(),N'CORE-98262',N'Mar  3 2022 10:56AM',-9999,@new_std_assess_id,N'A',N'May  8 2017  1:59PM',N'In Progress',NULL,NULL,NULL,NULL,NULL,N'',N'OH',NULL,N'',NULL,NULL,NULL,N'',N'',NULL,N'',NULL,NULL,N'',N'',NULL,N'',N'',N'',N'',NULL,NULL,NULL,N'',N'',NULL,NULL,NULL,NULL,N'',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,N'To Be Determined',NULL,NULL,N'',NULL,NULL,NULL,NULL,N'N',N'N',NULL,NULL,NULL,NULL,NULL,N'',N'',NULL,NULL,N'',NULL,NULL,NULL,NULL,NULL,N'',NULL,N'',N'',NULL,NULL,NULL,NULL,1,N'C')

-- 3. Extract data from as_std_assessment
INSERT INTO [as_std_assessment] ([std_assess_id], [fac_id], [description], [is_mds], [utility_class], [system_flag], [status], [deleted], [DELETED_BY], [DELETED_DATE], [default_short_version], [multi_section], [include_signature_section_flag], [reg_id], [title_style], [text_style], [is_clinical], [is_IRM], [is_admin], [state_code], [group_title_style], [group_text_style], [include_disabled_questions_flag], [show_on_shift_rep_flag], [show_on_24h_rep_flag], [revision_date], [show_on_clinical_hx], [incl_in_daily_summary_metrics], [show_in_poc], [include_in_mobile], [include_in_home_health], [brand_id], [brand_assessment_key], [version], [is_currentVersion], [branded_assessment_type], [is_esignature_enabled])VALUES (@new_std_assess_id,-9999,@assessment_name,N'N',N'esolutions.util.care.assess.WeCustAssessUtil',N'N',N'A',N'N',NULL,NULL,N'N',N'Y',N'N',NULL,N'',N'',N'Y',N'N',N'N',N'NY',N'',N'',N'Y',N'N',N'N',getdate(),N'N',N'N',N'N',N'N',N'N',NULL,N'',N'',NULL,N'',N'N')
-- State code --
UPDATE as_std_assessment SET state_code = @stateCode WHERE std_assess_id = @new_std_assess_id;

-- 4. Extract data from as_assessment_section
INSERT INTO [as_assessment_section] ([assess_id], [section_code], [sequence], [complete], [completed_by], [completed_title], [completed_date], [validation_error], [warnings_flag], [completed_by_id], [notes], [edited_date], [edited_by], [fac_id], [read_only])VALUES (@new_assess_id,N'Cust_A',NULL,NULL,N'Hidden name',N'',NULL,N'',NULL,NULL,NULL,NULL,N'',-1,NULL)
INSERT INTO [as_assessment_section] ([assess_id], [section_code], [sequence], [complete], [completed_by], [completed_title], [completed_date], [validation_error], [warnings_flag], [completed_by_id], [notes], [edited_date], [edited_by], [fac_id], [read_only])VALUES (@new_assess_id,N'Cust_B',NULL,NULL,N'Hidden name',N'',NULL,N'',NULL,NULL,NULL,NULL,N'',-1,NULL)
INSERT INTO [as_assessment_section] ([assess_id], [section_code], [sequence], [complete], [completed_by], [completed_title], [completed_date], [validation_error], [warnings_flag], [completed_by_id], [notes], [edited_date], [edited_by], [fac_id], [read_only])VALUES (@new_assess_id,N'Cust_C',NULL,NULL,N'Hidden name',N'',NULL,N'',NULL,NULL,NULL,NULL,N'',-1,NULL)
-- 5. Extract data from as_std_section
INSERT INTO [as_std_section] ([std_assess_id], [section_code], [title], [sequence], [description], [script_text], [title_style], [text_style], [group_title_style], [group_text_style])VALUES (@new_std_assess_id,N'Cust_A',N'Admission / Discharge Information',1,N'',N'',N'',N'',N'',N'')
INSERT INTO [as_std_section] ([std_assess_id], [section_code], [title], [sequence], [description], [script_text], [title_style], [text_style], [group_title_style], [group_text_style])VALUES (@new_std_assess_id,N'Cust_B',N'Section 1: Personal Data',2,N'',N'',N'',N'',N'',N'')
INSERT INTO [as_std_section] ([std_assess_id], [section_code], [title], [sequence], [description], [script_text], [title_style], [text_style], [group_title_style], [group_text_style])VALUES (@new_std_assess_id,N'Cust_C',N' Section 2: Personal Background',3,N'',N'',N'',N'',N'',N'')
-- 6.  Extract data from as_std_question with out pick_list_id
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_A_1_1',N'Cust_A',N'1',N'1',N' ',1,N'name',N'',NULL,NULL,NULL,N'N',N'Y',N'',N'',NULL,N'',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,4799,37,1,-4662621523630838596)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_A_2_1',N'Cust_A',N'2',N'1',N' ',3,N'ad',N'',NULL,1000,NULL,N'N',N'Y',N'',N'',NULL,N'',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,2186,11,1,-9132137422210861399)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_A_2_2',N'Cust_A',N'2',N'2',N' ',4,N'txt',N'',NULL,50,NULL,N'N',N'Y',N'',N'',NULL,N'text, sp(50)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,4800,1,1,-5609550459771809235)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_A_2_3a',N'Cust_A',N'2',N'3a',N' ',7,N'txt',N'',NULL,50,NULL,N'N',N'Y',N'',N'',NULL,N'text, sp(50)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,10597,1,1,-8967025711682466825)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_A_2_4',N'Cust_A',N'2',N'4',N' ',8,N'txt',N'',NULL,100,NULL,N'N',N'Y',N'',N'',NULL,N'text, sp(100)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,1073,1,1,-7019217649348295375)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_A_3_1',N'Cust_A',N'3',N'1',N' ',11,NULL,N'',NULL,NULL,NULL,N'N',N'Y',NULL,NULL,NULL,NULL,N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',NULL,NULL,NULL,NULL,NULL,NULL,NULL,N'',N'',NULL,NULL,NULL,NULL,1075,2,1,-6585081801788472632)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_A_3_2',N'Cust_A',N'3',N'2',N' ',12,NULL,N'',NULL,150,NULL,N'N',N'Y',NULL,NULL,NULL,N'text, sp(150)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',NULL,NULL,NULL,NULL,NULL,NULL,NULL,N'',N'',NULL,NULL,NULL,NULL,1079,1,1,-8486565597254974531)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_A_3_3a',N'Cust_A',N'3',N'3a',N' ',14,NULL,N'',NULL,50,NULL,N'N',N'Y',NULL,NULL,NULL,N'text, sp(50)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',NULL,NULL,NULL,NULL,NULL,NULL,NULL,N'',N'',NULL,NULL,NULL,NULL,1077,1,1,-8109395787681498651)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_A_3_4',N'Cust_A',N'3',N'4',N' ',15,NULL,N'',NULL,100,NULL,N'N',N'Y',NULL,NULL,NULL,N'text, sp(100)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',NULL,NULL,NULL,NULL,NULL,NULL,NULL,N'',N'',NULL,NULL,NULL,NULL,1078,1,1,-8677227923360538095)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_B_1_1',N'Cust_B',N'1',N'1',N' ',1,N'dob',N'',NULL,1000,NULL,N'N',N'Y',N'',N'',NULL,N'',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,2186,29,1,-7829112451737389541)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_B_2_1',N'Cust_B',N'2',N'1',N' ',17,N'cnt',N'',NULL,NULL,NULL,N'N',N'Y',N'',N'',NULL,N'',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,2555,26,1,-7118803144429111932)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_B_3_1',N'Cust_B',N'3',N'1',N' ',19,N'txt',N'',NULL,200,NULL,N'N',N'Y',N'',N'',NULL,N'text, sp(200)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,4828,1,1,-7081483057475055378)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_B_3_2',N'Cust_B',N'3',N'2',N' ',20,N'txt',N'',NULL,200,NULL,N'N',N'Y',N'',N'',NULL,N'text, sp(200)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,4829,1,1,-9051296883042144735)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_B_4_1',N'Cust_B',N'4',N'1',N' ',21,N'txt',N'',NULL,50,NULL,N'Y',N'Y',N'',N'',NULL,N'text, sp(50)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,1110,1,1,-6761674384481927179)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_B_4_2',N'Cust_B',N'4',N'2',N' ',22,N'txt',N'',NULL,30,NULL,N'Y',N'Y',N'',N'',NULL,N'text, sp(30)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,1111,1,1,-7306969660372395976)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_B_4_3',N'Cust_B',N'4',N'3',N' ',25,N'txt',N'',NULL,50,NULL,N'N',N'Y',N'',N'',NULL,N'text, sp(50)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,1114,1,1,-6605462913951772180)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_B_4_4',N'Cust_B',N'4',N'4',N' ',26,N'txt',N'',NULL,30,NULL,N'N',N'Y',N'',N'',NULL,N'text, sp(30)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,4831,1,1,-5352577714363647326)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_B_4_5',N'Cust_B',N'4',N'5',N' ',27,N'txt',N'',NULL,100,NULL,N'N',N'Y',N'',N'',NULL,N'text, sp(100)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,1116,1,1,-7474331717345500659)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_C_1_1',N'Cust_C',N'1',N'1',N' ',35,N'txt',N'',NULL,50,NULL,N'N',N'Y',N'',N'',NULL,N'text, sp(50)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,1129,1,1,-8202293504590170540)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_C_1_2',N'Cust_C',N'1',N'2',N' ',36,N'txt',N'',NULL,100,NULL,N'N',N'Y',N'',N'',NULL,N'text, sp(100)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,10599,1,1,-5669876811690554018)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_C_1_3',N'Cust_C',N'1',N'3',N' ',37,N'cnt',N'',NULL,NULL,NULL,N'N',N'Y',N'',N'',NULL,N'',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,10600,26,1,-5785790786213724290)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_C_1_4',N'Cust_C',N'1',N'4',N' ',38,N'txt',N'',NULL,50,NULL,N'N',N'Y',N'',N'',NULL,N'text, sp(50)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,10601,1,1,-7856161776242686566)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_C_1_4a',N'Cust_C',N'1',N'4a',N' ',39,N'txt',N'',NULL,50,NULL,N'N',N'Y',N'',N'',NULL,N'text, sp(50)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,4841,1,1,-5193282361506254464)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_C_1_4b',N'Cust_C',N'1',N'4b',N' ',40,N'txt',N'',NULL,200,NULL,N'N',N'Y',N'',N'',NULL,N'text, sp(200)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,4337,1,1,-7410187442170049618)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_C_1_4c',N'Cust_C',N'1',N'4c',N' ',41,N'txt',N'',NULL,20,NULL,N'N',N'Y',N'',N'',NULL,N'text, sp(20)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,4843,1,1,-7112801847030563284)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_C_1_4d',N'Cust_C',N'1',N'4d',N' ',42,N'txt',N'',NULL,20,NULL,N'N',N'Y',N'',N'',NULL,N'text, sp(20)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,4844,1,1,-5637892879252469478)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_C_1_4e',N'Cust_C',N'1',N'4e',N' ',43,N'txt',N'',NULL,20,NULL,N'N',N'Y',N'',N'',NULL,N'text, sp(20)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,4845,1,1,-7574562063838439169)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_C_1_5',N'Cust_C',N'1',N'5',N' ',44,N'cnt',N'',NULL,NULL,NULL,N'N',N'Y',N'',N'',NULL,N'',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,10602,26,1,-5128644676925097068)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_C_1_6',N'Cust_C',N'1',N'6',N' ',45,N'txt',N'',NULL,50,NULL,N'N',N'Y',N'',N'',NULL,N'text, sp(50)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,10603,1,1,-5705856785598019891)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_C_1_6a',N'Cust_C',N'1',N'6a',N' ',46,N'txt',N'',NULL,50,NULL,N'N',N'Y',N'',N'',NULL,N'text, sp(50)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,4841,1,1,-6437745002379587270)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_C_1_6b',N'Cust_C',N'1',N'6b',N' ',47,N'txt',N'',NULL,200,NULL,N'N',N'Y',N'',N'',NULL,N'text, sp(200)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,4337,1,1,-6980703038819856694)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_C_1_6c',N'Cust_C',N'1',N'6c',N' ',48,N'txt',N'',NULL,20,NULL,N'N',N'Y',N'',N'',NULL,N'text, sp(20)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,4843,1,1,-7570208984342830953)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_C_1_6d',N'Cust_C',N'1',N'6d',N' ',49,N'txt',N'',NULL,20,NULL,N'N',N'Y',N'',N'',NULL,N'text, sp(20)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,4844,1,1,-5090343778483351809)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_C_1_6e',N'Cust_C',N'1',N'6e',N' ',50,N'txt',N'',NULL,20,NULL,N'N',N'Y',N'',N'',NULL,N'text, sp(20)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,4845,1,1,-7000506963950653139)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_C_2_1',N'Cust_C',N'2',N'1',N' ',51,N'txt',N'',NULL,300,NULL,N'N',N'Y',N'',N'',NULL,N'text, sp(300)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,1170,1,1,-6244731736064499822)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_C_2_2',N'Cust_C',N'2',N'2',N' ',52,N'txt',N'',NULL,300,NULL,N'N',N'Y',N'',N'',NULL,N'text, sp(300)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,1171,1,1,-6419112256118773136)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_C_2_3a',N'Cust_C',N'2',N'3a',N' ',57,N'txt',N'',NULL,50,NULL,N'N',N'Y',N'',N'',NULL,N'text, sp(50)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,1176,1,1,-4634490879871173098)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_C_2_5a',N'Cust_C',N'2',N'5a',N' ',60,N'txt',N'',NULL,50,NULL,N'N',N'Y',N'',N'',NULL,N'text, sp(50)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,1179,1,1,-8941212092640075251)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_C_2_7',N'Cust_C',N'2',N'7',N' ',62,N'txt',N'',NULL,200,NULL,N'N',N'Y',N'',N'',NULL,N'text, sp(200)',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,1181,1,1,-7931376642252831727)
-- 7. Extract data from as_std_picklist, as_std_picklist_item and as_std_question that is using a pick list
DECLARE @pl_id INT
select @pl_id = max(pick_list_id) from as_std_pick_list

DECLARE @item_pl_id INT
select @item_pl_id = max(pick_list_id) from as_std_pick_list_item

DECLARE @increase INT
select @increase = case when @item_pl_id>@pl_id THEN @item_pl_id - @pl_id + 1 else 1 END

DECLARE @new_pl_id INT
SET @pgpk_table_name = 'as_std_pick_list'; 
SET @pgpk_column_name = 'pick_list_id'; 
SET @pgpk_script_cmd = ('UPDATE pgpk' + 
                        '   SET pgpk.next_key = actual.next_key' + 
                        '  FROM dbo.pcc_global_primary_key pgpk' + 
                        ' CROSS APPLY (SELECT MAX([' + @pgpk_column_name + ']) + 1 as next_key FROM dbo.[' + @pgpk_table_name + ']) actual' + 
                        ' WHERE pgpk.table_name = ' + quotename(@pgpk_table_name, '''') +  
                        '   AND pgpk.key_column_name = ' + quotename(@pgpk_column_name, '''') + 
                        '   AND pgpk.next_key < actual.next_key') 
EXEC sp_executesql @pgpk_script_cmd; 

exec get_next_primary_key 'as_std_pick_list', 'pick_list_id', @new_pl_id  output, 1
INSERT INTO [as_std_pick_list] ([pick_list_id], [fac_id], [description], [std_assess_id])VALUES (@new_pl_id,-1,N'',@new_std_assess_id)
INSERT INTO [as_std_pick_list_item] ([pick_list_id], [item_value], [item_description], [sequence], [effective_date], [ineffective_date], [qlib_pick_list_item_id])VALUES (@new_pl_id,N'1',NULL,0,N'Jan 15 2021  3:56PM',NULL,974)
INSERT INTO [as_std_pick_list_item] ([pick_list_id], [item_value], [item_description], [sequence], [effective_date], [ineffective_date], [qlib_pick_list_item_id])VALUES (@new_pl_id,N'2',NULL,1,N'Jan 15 2021  3:56PM',NULL,611)
INSERT INTO [as_std_pick_list_item] ([pick_list_id], [item_value], [item_description], [sequence], [effective_date], [ineffective_date], [qlib_pick_list_item_id])VALUES (@new_pl_id,N'3',NULL,2,N'Jan 15 2021  3:56PM',NULL,857)
INSERT INTO [as_std_pick_list_item] ([pick_list_id], [item_value], [item_description], [sequence], [effective_date], [ineffective_date], [qlib_pick_list_item_id])VALUES (@new_pl_id,N'4',NULL,3,N'Jan 15 2021  3:56PM',NULL,922)
INSERT INTO [as_std_pick_list_item] ([pick_list_id], [item_value], [item_description], [sequence], [effective_date], [ineffective_date], [qlib_pick_list_item_id])VALUES (@new_pl_id,N'5',NULL,4,N'Jan 15 2021  3:56PM',NULL,940)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_A_2_3',N'Cust_A',N'2',N'3',N' ',6,N'cmb',N'',NULL,NULL,@new_pl_id,N'N',N'Y',N'',N'',NULL,N'',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,1071,25,1,-8532027877158843744)
exec get_next_primary_key 'as_std_pick_list', 'pick_list_id', @new_pl_id  output, 1
INSERT INTO [as_std_pick_list] ([pick_list_id], [fac_id], [description], [std_assess_id])VALUES (@new_pl_id,-1,N'',@new_std_assess_id)
INSERT INTO [as_std_pick_list_item] ([pick_list_id], [item_value], [item_description], [sequence], [effective_date], [ineffective_date], [qlib_pick_list_item_id])VALUES (@new_pl_id,N'a',NULL,0,N'Jan 15 2021  3:59PM',NULL,1418)
INSERT INTO [as_std_pick_list_item] ([pick_list_id], [item_value], [item_description], [sequence], [effective_date], [ineffective_date], [qlib_pick_list_item_id])VALUES (@new_pl_id,N'b',NULL,1,N'Jan 15 2021  3:59PM',NULL,860)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_C_2_3',N'Cust_C',N'2',N'3',N' ',56,N'radh',N'',NULL,NULL,@new_pl_id,N'N',N'Y',N'',N'',NULL,N'',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,19561,5,1,-7350609405337063889)
exec get_next_primary_key 'as_std_pick_list', 'pick_list_id', @new_pl_id  output, 1
INSERT INTO [as_std_pick_list] ([pick_list_id], [fac_id], [description], [std_assess_id])VALUES (@new_pl_id,-1,N'',@new_std_assess_id)
INSERT INTO [as_std_pick_list_item] ([pick_list_id], [item_value], [item_description], [sequence], [effective_date], [ineffective_date], [qlib_pick_list_item_id])VALUES (@new_pl_id,N'a',NULL,0,N'Jan 15 2021  3:59PM',NULL,1418)
INSERT INTO [as_std_pick_list_item] ([pick_list_id], [item_value], [item_description], [sequence], [effective_date], [ineffective_date], [qlib_pick_list_item_id])VALUES (@new_pl_id,N'b',NULL,1,N'Jan 15 2021  3:59PM',NULL,860)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_C_2_4',N'Cust_C',N'2',N'4',N' ',58,N'radh',N'',NULL,NULL,@new_pl_id,N'N',N'Y',N'',N'',NULL,N'',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,10604,5,1,-8892242596252774357)
exec get_next_primary_key 'as_std_pick_list', 'pick_list_id', @new_pl_id  output, 1
INSERT INTO [as_std_pick_list] ([pick_list_id], [fac_id], [description], [std_assess_id])VALUES (@new_pl_id,-1,N'',@new_std_assess_id)
INSERT INTO [as_std_pick_list_item] ([pick_list_id], [item_value], [item_description], [sequence], [effective_date], [ineffective_date], [qlib_pick_list_item_id])VALUES (@new_pl_id,N'a',NULL,0,N'Jan 15 2021  3:59PM',NULL,1418)
INSERT INTO [as_std_pick_list_item] ([pick_list_id], [item_value], [item_description], [sequence], [effective_date], [ineffective_date], [qlib_pick_list_item_id])VALUES (@new_pl_id,N'b',NULL,1,N'Jan 15 2021  3:59PM',NULL,860)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_C_2_5',N'Cust_C',N'2',N'5',N' ',59,N'radh',N'',NULL,NULL,@new_pl_id,N'N',N'Y',N'',N'',NULL,N'',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,19563,5,1,-4719687340724902844)
exec get_next_primary_key 'as_std_pick_list', 'pick_list_id', @new_pl_id  output, 1
INSERT INTO [as_std_pick_list] ([pick_list_id], [fac_id], [description], [std_assess_id])VALUES (@new_pl_id,-1,N'',@new_std_assess_id)
INSERT INTO [as_std_pick_list_item] ([pick_list_id], [item_value], [item_description], [sequence], [effective_date], [ineffective_date], [qlib_pick_list_item_id])VALUES (@new_pl_id,N'a',NULL,0,N'Jan 15 2021  4:00PM',NULL,1418)
INSERT INTO [as_std_pick_list_item] ([pick_list_id], [item_value], [item_description], [sequence], [effective_date], [ineffective_date], [qlib_pick_list_item_id])VALUES (@new_pl_id,N'b',NULL,1,N'Jan 15 2021  4:00PM',NULL,860)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_C_2_6',N'Cust_C',N'2',N'6',N' ',61,N'radh',N'',NULL,NULL,@new_pl_id,N'N',N'Y',N'',N'',NULL,N'',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,19564,5,1,-7428324564828885729)
exec get_next_primary_key 'as_std_pick_list', 'pick_list_id', @new_pl_id  output, 1
INSERT INTO [as_std_pick_list] ([pick_list_id], [fac_id], [description], [std_assess_id])VALUES (@new_pl_id,-1,N'',@new_std_assess_id)
INSERT INTO [as_std_pick_list_item] ([pick_list_id], [item_value], [item_description], [sequence], [effective_date], [ineffective_date], [qlib_pick_list_item_id])VALUES (@new_pl_id,N'a',NULL,0,N'Jul 21 2017 11:38AM',NULL,746)
INSERT INTO [as_std_pick_list_item] ([pick_list_id], [item_value], [item_description], [sequence], [effective_date], [ineffective_date], [qlib_pick_list_item_id])VALUES (@new_pl_id,N'b',NULL,1,N'Jul 21 2017 11:38AM',NULL,1180)
INSERT INTO [as_std_pick_list_item] ([pick_list_id], [item_value], [item_description], [sequence], [effective_date], [ineffective_date], [qlib_pick_list_item_id])VALUES (@new_pl_id,N'c',NULL,2,N'Jul 21 2017 11:38AM',NULL,451)
INSERT INTO [as_std_pick_list_item] ([pick_list_id], [item_value], [item_description], [sequence], [effective_date], [ineffective_date], [qlib_pick_list_item_id])VALUES (@new_pl_id,N'd',NULL,3,N'Jul 21 2017 11:38AM',NULL,1388)
INSERT INTO [as_std_pick_list_item] ([pick_list_id], [item_value], [item_description], [sequence], [effective_date], [ineffective_date], [qlib_pick_list_item_id])VALUES (@new_pl_id,N'e',NULL,4,N'Jul 21 2017 11:38AM',NULL,991)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_B_1_2',N'Cust_B',N'1',N'2',N' ',2,N'cmb',N'',NULL,NULL,@new_pl_id,N'N',N'Y',N'',N'',NULL,N'',N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',N'',N'',NULL,NULL,NULL,NULL,NULL,N'',N'',N'',N'',N'',NULL,10598,25,1,-6860993699100934143)
exec get_next_primary_key 'as_std_pick_list', 'pick_list_id', @new_pl_id  output, 1
INSERT INTO [as_std_pick_list] ([pick_list_id], [fac_id], [description], [std_assess_id])VALUES (@new_pl_id,-1,NULL,@new_std_assess_id)
INSERT INTO [as_std_pick_list_item] ([pick_list_id], [item_value], [item_description], [sequence], [effective_date], [ineffective_date], [qlib_pick_list_item_id])VALUES (@new_pl_id,N'1',NULL,0,N'Feb 24 2022  1:36PM',NULL,974)
INSERT INTO [as_std_pick_list_item] ([pick_list_id], [item_value], [item_description], [sequence], [effective_date], [ineffective_date], [qlib_pick_list_item_id])VALUES (@new_pl_id,N'2',NULL,1,N'Feb 24 2022  1:36PM',NULL,611)
INSERT INTO [as_std_pick_list_item] ([pick_list_id], [item_value], [item_description], [sequence], [effective_date], [ineffective_date], [qlib_pick_list_item_id])VALUES (@new_pl_id,N'3',NULL,2,N'Feb 24 2022  1:36PM',NULL,857)
INSERT INTO [as_std_pick_list_item] ([pick_list_id], [item_value], [item_description], [sequence], [effective_date], [ineffective_date], [qlib_pick_list_item_id])VALUES (@new_pl_id,N'4',NULL,3,N'Feb 24 2022  1:36PM',NULL,922)
INSERT INTO [as_std_pick_list_item] ([pick_list_id], [item_value], [item_description], [sequence], [effective_date], [ineffective_date], [qlib_pick_list_item_id])VALUES (@new_pl_id,N'5',NULL,4,N'Feb 24 2022  1:36PM',NULL,940)
INSERT INTO [as_std_question] ([std_assess_id], [question_key], [section_code], [std_question_no], [std_subquestion_no], [std_subquestion_AB], [sequence], [control_type], [title], [question_text], [length], [pick_list_id], [required], [allow_unknown], [qa_trigger], [rap_trigger], [rugs_trigger], [RANGE], [STATUS_A], [STATUS_AM], [STATUS_AO], [STATUS_Y], [STATUS_YM], [STATUS_YO], [STATUS_Q], [STATUS_QM], [STATUS_QO], [STATUS_O], [STATUS_OM], [STATUS_OO], [STATUS_D], [STATUS_R], [STATUS_X], [STATUS_IRFP], [STATUS_IRFA], [visual], [electronic], [prov_state_options], [rap_problem_desc], [run_script], [auto_sum_weight], [status_qm_mpaf], [status_om_mpaf], [submit_sequence], [title_style], [text_style], [mds_question], [prov_state_options_OO], [cap_trigger], [mds_question_std_assess_id], [std_question_id], [control_type_id], [question_source_library_id], [key_group_identifier])VALUES (@new_std_assess_id,N'Cust_A_3_3',N'Cust_A',N'3',N'3',N' ',13,NULL,N'',NULL,NULL,@new_pl_id,N'N',N'Y',NULL,NULL,NULL,NULL,N'A',N'A',N'A',N'A',N'A',N'A',N'A',N'A',NULL,N'A',N'A',N'A',N'A',N'A',N'A',NULL,NULL,N'Y',N'N',NULL,NULL,NULL,NULL,NULL,NULL,NULL,N'',N'',NULL,NULL,NULL,NULL,1076,25,1,-7305001932596589411)
-- 8.Extract data from as_std_question_group
INSERT INTO [as_std_question_group] ([std_assess_id], [section_code], [std_question_no], [group_title], [group_text], [std_legend_id], [layout_style], [tips], [group_title_style], [group_text_style])VALUES (@new_std_assess_id,N'Cust_A',N'1',N'RESIDENT INFORMATION',N'',NULL,N'V',N'',N'',N'')
INSERT INTO [as_std_question_group] ([std_assess_id], [section_code], [std_question_no], [group_title], [group_text], [std_legend_id], [layout_style], [tips], [group_title_style], [group_text_style])VALUES (@new_std_assess_id,N'Cust_A',N'2',N'ADMISSION INFORMATION',N'',NULL,N'V',N'',N'',N'')
INSERT INTO [as_std_question_group] ([std_assess_id], [section_code], [std_question_no], [group_title], [group_text], [std_legend_id], [layout_style], [tips], [group_title_style], [group_text_style])VALUES (@new_std_assess_id,N'Cust_A',N'3',N'DISCHARGE INFORMATION',N'',NULL,N'V',N'',N'',N'')
INSERT INTO [as_std_question_group] ([std_assess_id], [section_code], [std_question_no], [group_title], [group_text], [std_legend_id], [layout_style], [tips], [group_title_style], [group_text_style])VALUES (@new_std_assess_id,N'Cust_B',N'1',N' PERSONAL DATA ',N'',NULL,N'V',N'',N'',N'')
INSERT INTO [as_std_question_group] ([std_assess_id], [section_code], [std_question_no], [group_title], [group_text], [std_legend_id], [layout_style], [tips], [group_title_style], [group_text_style])VALUES (@new_std_assess_id,N'Cust_B',N'2',N'NOTIFY IN CASE OF EMERGENCY',N'',NULL,N'V',N'',N'',N'')
INSERT INTO [as_std_question_group] ([std_assess_id], [section_code], [std_question_no], [group_title], [group_text], [std_legend_id], [layout_style], [tips], [group_title_style], [group_text_style])VALUES (@new_std_assess_id,N'Cust_B',N'3',N'AREA/HOSPITAL/ CLINIC OF CHOICE ',N'',NULL,N'V',N'',N'',N'')
INSERT INTO [as_std_question_group] ([std_assess_id], [section_code], [std_question_no], [group_title], [group_text], [std_legend_id], [layout_style], [tips], [group_title_style], [group_text_style])VALUES (@new_std_assess_id,N'Cust_B',N'4',N'HEALTH INSURANCE',N'',NULL,N'V',N'',N'',N'')
INSERT INTO [as_std_question_group] ([std_assess_id], [section_code], [std_question_no], [group_title], [group_text], [std_legend_id], [layout_style], [tips], [group_title_style], [group_text_style])VALUES (@new_std_assess_id,N'Cust_C',N'1',N'PERSONAL BACKGROUND',N'',NULL,N'V',N'',N'',N'')
INSERT INTO [as_std_question_group] ([std_assess_id], [section_code], [std_question_no], [group_title], [group_text], [std_legend_id], [layout_style], [tips], [group_title_style], [group_text_style])VALUES (@new_std_assess_id,N'Cust_C',N'2',N'RESIDENTIAL BACKGROUND',N'',NULL,N'V',N'',N'',N'')
-- 9. Extract data from as_std_assess_type --
INSERT INTO [as_std_assess_type] ([std_assess_id], [assess_type_code], [description], [deleted], [deleted_by], [deleted_date], [retired], [revision_date])VALUES (@new_std_assess_id,N'A',N'Admission',N'N',NULL,NULL,NULL,N'Feb 24 2022  1:27PM')
INSERT INTO [as_std_assess_type] ([std_assess_id], [assess_type_code], [description], [deleted], [deleted_by], [deleted_date], [retired], [revision_date])VALUES (@new_std_assess_id,N'D',N'Discharge',N'N',NULL,NULL,NULL,N'Feb 24 2022  1:27PM')
INSERT INTO [as_std_assess_type] ([std_assess_id], [assess_type_code], [description], [deleted], [deleted_by], [deleted_date], [retired], [revision_date])VALUES (@new_std_assess_id,N'FULL',N'Full Assessment',N'N',NULL,NULL,NULL,N'Feb 24 2022  1:27PM')
INSERT INTO [as_std_assess_type] ([std_assess_id], [assess_type_code], [description], [deleted], [deleted_by], [deleted_date], [retired], [revision_date])VALUES (@new_std_assess_id,N'O',N'Other',N'N',NULL,NULL,NULL,N'Feb 24 2022  1:27PM')
INSERT INTO [as_std_assess_type] ([std_assess_id], [assess_type_code], [description], [deleted], [deleted_by], [deleted_date], [retired], [revision_date])VALUES (@new_std_assess_id,N'Q',N'Quarterly',N'N',NULL,NULL,NULL,N'Feb 24 2022  1:27PM')
INSERT INTO [as_std_assess_type] ([std_assess_id], [assess_type_code], [description], [deleted], [deleted_by], [deleted_date], [retired], [revision_date])VALUES (@new_std_assess_id,N'R',N'Reentry',N'N',NULL,NULL,NULL,N'Feb 24 2022  1:27PM')
INSERT INTO [as_std_assess_type] ([std_assess_id], [assess_type_code], [description], [deleted], [deleted_by], [deleted_date], [retired], [revision_date])VALUES (@new_std_assess_id,N'X',N'Inactivation',N'N',NULL,NULL,NULL,N'Feb 24 2022  1:27PM')
INSERT INTO [as_std_assess_type] ([std_assess_id], [assess_type_code], [description], [deleted], [deleted_by], [deleted_date], [retired], [revision_date])VALUES (@new_std_assess_id,N'Y',N'Comprehensive',N'N',NULL,NULL,NULL,N'Feb 24 2022  1:27PM')
-- 10. Extract data from as_std_score
DECLARE @new_std_score_id INT
SET @pgpk_table_name = 'as_std_score'; 
SET @pgpk_column_name = 'std_score_id'; 
SET @pgpk_script_cmd = ('UPDATE pgpk' + 
                        '   SET pgpk.next_key = actual.next_key' + 
                        '  FROM dbo.pcc_global_primary_key pgpk' + 
                        ' CROSS APPLY (SELECT MAX([' + @pgpk_column_name + ']) + 1 as next_key FROM dbo.[' + @pgpk_table_name + ']) actual' + 
                        ' WHERE pgpk.table_name = ' + quotename(@pgpk_table_name, '''') +  
                        '   AND pgpk.key_column_name = ' + quotename(@pgpk_column_name, '''') + 
                        '   AND pgpk.next_key < actual.next_key') 
EXEC sp_executesql @pgpk_script_cmd; 
DECLARE @mapping_as_std_scoring table (std_score_id int primary key, new_std_score_id int); 

-- 11. Extract data from as_std_category
DECLARE @new_category_id INT;
SET @pgpk_table_name = 'as_std_category'; 
SET @pgpk_column_name = 'category_id'; 
SET @pgpk_script_cmd = ('UPDATE pgpk' + 
                        '   SET pgpk.next_key = actual.next_key' + 
                        '  FROM dbo.pcc_global_primary_key pgpk' + 
                        ' CROSS APPLY (SELECT MAX([' + @pgpk_column_name + ']) + 1 as next_key FROM dbo.[' + @pgpk_table_name + ']) actual' + 
                        ' WHERE pgpk.table_name = ' + quotename(@pgpk_table_name, '''') +  
                        '   AND pgpk.key_column_name = ' + quotename(@pgpk_column_name, '''') + 
                        '   AND pgpk.next_key < actual.next_key') 
EXEC sp_executesql @pgpk_script_cmd; 
 DECLARE @mapping_as_category table (map_category_id int primary key, new_map_category_id int); 

-- 12. Extract data from as_std_assess_header
DECLARE @common_header_code table (item_id int primary key, item_description varchar(254), sequence_no int, new_item_id int);
INSERT INTO @common_header_code (item_id, item_description, sequence_no ) values (7101,'Client Name',1)
INSERT INTO @common_header_code (item_id, item_description, sequence_no ) values (7102,'Client Number',2)
INSERT INTO @common_header_code (item_id, item_description, sequence_no ) values (7103,'Effective Date',3)
INSERT INTO @common_header_code (item_id, item_description, sequence_no ) values (7104,'Location',4)
INSERT INTO @common_header_code (item_id, item_description, sequence_no ) values (7105,'Admission Date',6)
INSERT INTO @common_header_code (item_id, item_description, sequence_no ) values (7106,'Identifiers',7)
INSERT INTO @common_header_code (item_id, item_description, sequence_no ) values (7107,'Date of Birth',8)
INSERT INTO @common_header_code (item_id, item_description, sequence_no ) values (7108,'Gender',9)
INSERT INTO @common_header_code (item_id, item_description, sequence_no ) values (7109,'Primary Language',10)
INSERT INTO @common_header_code (item_id, item_description, sequence_no ) values (7110,'Score',11)
INSERT INTO @common_header_code (item_id, item_description, sequence_no ) values (7111,'Category',12)
INSERT INTO @common_header_code (item_id, item_description, sequence_no ) values (7112,'Physician',13)
INSERT INTO @common_header_code (item_id, item_description, sequence_no ) values (7113,'Allergies',14)
INSERT INTO @common_header_code (item_id, item_description, sequence_no ) values (7114,'Diagnosis',15)
INSERT INTO @common_header_code (item_id, item_description, sequence_no ) values (7115,'Title',16)
INSERT INTO @common_header_code (item_id, item_description, sequence_no ) values (7116,'Type',17)
INSERT INTO @common_header_code (item_id, item_description, sequence_no ) values (7117,'Facility Name',18)
INSERT INTO @common_header_code (item_id, item_description, sequence_no ) values (7118,'Facility Address',19)
INSERT INTO @common_header_code (item_id, item_description, sequence_no ) values (10942,'Initial Admission Date',5)

UPDATE  map set new_item_id=COALESCE(cc.item_id,map.item_id)
  FROM @common_header_code map
  INNER JOIN  common_code cc ON cc.item_code = 'cfghdr' AND map.item_description = cc.item_description AND map.sequence_no=cc.sequence_no AND cc.deleted = 'N'
  AND (cc.fac_id = -1 OR
      (cc.fac_id!=-1 AND  
	        1 = (select count(1) FROM common_code cc2 WHERE  cc2.item_code ='cfghdr' AND cc2.item_description = cc.item_description AND cc.sequence_no= cc2.sequence_no AND deleted = 'N')
  ))

INSERT INTO [as_std_assess_header] ([std_assess_id], [item_id], [id_type_id], [main_enabled], [sub_enabled])VALUES (@new_std_assess_id,7101,-1,N'Y',N'Y')
INSERT INTO [as_std_assess_header] ([std_assess_id], [item_id], [id_type_id], [main_enabled], [sub_enabled])VALUES (@new_std_assess_id,7102,-1,N'Y',N'Y')
INSERT INTO [as_std_assess_header] ([std_assess_id], [item_id], [id_type_id], [main_enabled], [sub_enabled])VALUES (@new_std_assess_id,7103,-1,N'Y',N'N')
INSERT INTO [as_std_assess_header] ([std_assess_id], [item_id], [id_type_id], [main_enabled], [sub_enabled])VALUES (@new_std_assess_id,7104,-1,N'Y',N'N')
INSERT INTO [as_std_assess_header] ([std_assess_id], [item_id], [id_type_id], [main_enabled], [sub_enabled])VALUES (@new_std_assess_id,7105,-1,N'Y',N'N')
INSERT INTO [as_std_assess_header] ([std_assess_id], [item_id], [id_type_id], [main_enabled], [sub_enabled])VALUES (@new_std_assess_id,7106,3,N'N',N'N')
INSERT INTO [as_std_assess_header] ([std_assess_id], [item_id], [id_type_id], [main_enabled], [sub_enabled])VALUES (@new_std_assess_id,7106,4,N'N',N'N')
INSERT INTO [as_std_assess_header] ([std_assess_id], [item_id], [id_type_id], [main_enabled], [sub_enabled])VALUES (@new_std_assess_id,7106,5,N'N',N'N')
INSERT INTO [as_std_assess_header] ([std_assess_id], [item_id], [id_type_id], [main_enabled], [sub_enabled])VALUES (@new_std_assess_id,7106,6,N'N',N'N')
INSERT INTO [as_std_assess_header] ([std_assess_id], [item_id], [id_type_id], [main_enabled], [sub_enabled])VALUES (@new_std_assess_id,7107,-1,N'Y',N'N')
INSERT INTO [as_std_assess_header] ([std_assess_id], [item_id], [id_type_id], [main_enabled], [sub_enabled])VALUES (@new_std_assess_id,7108,-1,N'N',N'N')
INSERT INTO [as_std_assess_header] ([std_assess_id], [item_id], [id_type_id], [main_enabled], [sub_enabled])VALUES (@new_std_assess_id,7109,-1,N'N',N'N')
INSERT INTO [as_std_assess_header] ([std_assess_id], [item_id], [id_type_id], [main_enabled], [sub_enabled])VALUES (@new_std_assess_id,7110,-1,N'Y',N'N')
INSERT INTO [as_std_assess_header] ([std_assess_id], [item_id], [id_type_id], [main_enabled], [sub_enabled])VALUES (@new_std_assess_id,7111,-1,N'Y',N'N')
INSERT INTO [as_std_assess_header] ([std_assess_id], [item_id], [id_type_id], [main_enabled], [sub_enabled])VALUES (@new_std_assess_id,7112,-1,N'Y',N'N')
INSERT INTO [as_std_assess_header] ([std_assess_id], [item_id], [id_type_id], [main_enabled], [sub_enabled])VALUES (@new_std_assess_id,7113,-1,N'N',N'N')
INSERT INTO [as_std_assess_header] ([std_assess_id], [item_id], [id_type_id], [main_enabled], [sub_enabled])VALUES (@new_std_assess_id,7114,-1,N'N',N'N')
INSERT INTO [as_std_assess_header] ([std_assess_id], [item_id], [id_type_id], [main_enabled], [sub_enabled])VALUES (@new_std_assess_id,7115,-1,N'Y',N'N')
INSERT INTO [as_std_assess_header] ([std_assess_id], [item_id], [id_type_id], [main_enabled], [sub_enabled])VALUES (@new_std_assess_id,7116,-1,N'N',N'N')
INSERT INTO [as_std_assess_header] ([std_assess_id], [item_id], [id_type_id], [main_enabled], [sub_enabled])VALUES (@new_std_assess_id,7117,-1,N'N',N'N')
INSERT INTO [as_std_assess_header] ([std_assess_id], [item_id], [id_type_id], [main_enabled], [sub_enabled])VALUES (@new_std_assess_id,7118,-1,N'N',N'N')
INSERT INTO [as_std_assess_header] ([std_assess_id], [item_id], [id_type_id], [main_enabled], [sub_enabled])VALUES (@new_std_assess_id,10942,-1,N'Y',N'N')

UPDATE hdr set item_id = map.new_item_id
FROM 
as_std_assess_header hdr 
INNER JOIN @common_header_code map ON map.item_id=hdr.item_id 
WHERE hdr.std_assess_id=@new_std_assess_id AND hdr.item_id != map.new_item_id  

-- 13A. Extract data from as_std_assess_schedule with as_std_assess_schedule_payer_type_mapping
 DECLARE @mapping_as_std_assess_schedule table (schedule_id int primary key, new_schedule_id int); 

-- update the reference to the next schedule for schedule completion schedules
UPDATE as_std_assess_schedule set  next_schedule = map.new_schedule_id 
FROM  as_std_assess_schedule sched inner join @mapping_as_std_assess_schedule map on sched.next_schedule = map.schedule_id 
WHERE sched.std_assess_id = @new_std_assess_id 

-- 13B. Extract data from as_std_assess_schedule where schedule is triggered by converted assessment
DECLARE @mapping_as_branded_assessments table (assessment_id int primary key, branded_assessment_key  varchar(50), brand_assessment_version varchar(15)); 

-- update the reference to the next schedule for schedule completion schedules
UPDATE as_std_assess_schedule set  next_schedule = map.new_schedule_id 
FROM  as_std_assess_schedule sched inner join @mapping_as_std_assess_schedule map on sched.next_schedule = map.schedule_id 
WHERE sched.schedule_id in (select new_schedule_id from @mapping_as_std_assess_schedule) 


-- 14. Extract data from as_std_trigger
DECLARE @new_std_trigger_id INT
SET @pgpk_table_name = 'as_std_trigger'; 
SET @pgpk_column_name = 'std_trigger_id'; 
SET @pgpk_script_cmd = ('UPDATE pgpk' + 
                        '   SET pgpk.next_key = actual.next_key' + 
                        '  FROM dbo.pcc_global_primary_key pgpk' + 
                        ' CROSS APPLY (SELECT MAX([' + @pgpk_column_name + ']) + 1 as next_key FROM dbo.[' + @pgpk_table_name + ']) actual' + 
                        ' WHERE pgpk.table_name = ' + quotename(@pgpk_table_name, '''') +  
                        '   AND pgpk.key_column_name = ' + quotename(@pgpk_column_name, '''') + 
                        '   AND pgpk.next_key < actual.next_key') 
EXEC sp_executesql @pgpk_script_cmd; 

DECLARE @as_std_trigger TABLE (
  std_trigger_id INT,
  std_assess_id INT,
  question_key VARCHAR(16),
  item_value VARCHAR(35),
  trigger_type VARCHAR(1),
  triggered_item_id INT,
  deleted CHAR(1),
  deleted_by VARCHAR(60) ,
  deleted_date DATETIME ,
  fac_id INT,
  reg_id INT,
  triggered_from_id INT,
  state_code VARCHAR(3),
  question_key_info VARCHAR(10),
  created_by_audit_id INT,
  created_date datetime,
  system_flag varchar(1),
  PRIMARY KEY(std_trigger_id)
);

DECLARE @mapping_trigger_item TABLE (
    triggered_item_id INT,
    trigger_type VARCHAR(1),
    brand_id INT,
    brand_key VARCHAR(50)
    PRIMARY KEY(triggered_item_id, trigger_type)
);


INSERT INTO as_std_trigger (
         [std_trigger_id], [std_assess_id], [question_key], [item_value], [trigger_type], 
         [triggered_item_id], 
         [deleted], [deleted_by], [deleted_date], [fac_id], [reg_id], [triggered_from_id], [state_code], [question_key_info], [created_date], [system_flag], [created_by_audit_id])
SELECT  ast.[std_trigger_id], ast.[std_assess_id], ast.[question_key], ast.[item_value], ast.[trigger_type], 
         COALESCE(goal.std_goal_id, intervention.std_intervention_id, need.std_need_id, carepathway.std_care_pathway_id, ast.triggered_item_id),
         ast.[deleted], ast.[deleted_by], ast.[deleted_date], -1, ast.[reg_id], ast.[triggered_from_id], ast.[state_code], ast.[question_key_info], @revision_date,'Y', -999
  FROM @as_std_trigger ast
  JOIN @mapping_trigger_item mti
    ON ast.triggered_item_id = mti.triggered_item_id AND ast.trigger_type = mti.trigger_type
  LEFT JOIN CP_STD_GOAL goal 
    ON (mti.trigger_type = 'G') AND mti.brand_id = goal.brand_id AND mti.brand_key = goal.brand_goal_key AND goal.brand_id IS NOT NULL AND goal.deleted!='Y' AND goal.fac_id=-1
  LEFT JOIN CP_STD_INTERVENTION intervention 
    ON (mti.trigger_type = 'I') AND mti.brand_id = intervention.brand_id AND mti.brand_key = intervention.brand_intervention_key AND intervention.brand_id IS NOT NULL AND intervention.deleted!='Y' AND intervention.fac_id=-1
  LEFT JOIN CP_STD_NEED need 
    ON (mti.trigger_type = 'N') AND mti.brand_id = need.brand_id AND mti.brand_key = need.brand_need_key AND need.brand_id IS NOT NULL AND need.deleted!='Y' AND need.fac_id=-1
  LEFT JOIN CPG_STD_CARE_PATHWAY carepathway
    ON (ast.trigger_type = 'Y') AND mti.brand_id = carepathway.brand_id AND mti.brand_key = carepathway.brand_care_pathway_key AND carepathway.brand_id IS NOT NULL AND carepathway.deleted!='Y' AND carepathway.fac_id=-1


UPDATE as_std_trigger set  triggered_from_id = map.new_std_score_id 
FROM @mapping_as_std_scoring  map 
WHERE std_assess_id = @new_std_assess_id AND (question_key like 'SCORE_CAT' OR question_key like 'SCORE_VALUE') AND map.std_score_id=triggered_from_id


UPDATE as_std_trigger set  item_value = map.new_map_category_id 
FROM @mapping_as_category map 
WHERE std_assess_id = @new_std_assess_id and question_key like'SCORE_CAT' and map.map_category_id=item_value


-- update the reference to score for score triggered schedules
UPDATE as_std_trigger set  question_key = map.new_std_score_id 
FROM @mapping_as_std_scoring  map 
WHERE std_assess_id = @new_std_assess_id and trigger_type='S' AND map.std_score_id=question_key AND question_key IS NOT NULL


-- update the reference to score for score category triggered assessments, note that it uses different column
UPDATE as_std_trigger set triggered_from_id = map.new_std_score_id 
FROM @mapping_as_std_scoring  map 
WHERE std_assess_id = @new_std_assess_id and trigger_type='S' AND map.std_score_id=triggered_from_id AND  ( question_key is NULL OR question_key = '' )


-- update the reference to category for score category triggered assessments
UPDATE as_std_trigger set  item_value= map.new_map_category_id 
FROM @mapping_as_category map 
WHERE std_assess_id = @new_std_assess_id and trigger_type='S' AND map.map_category_id=item_value AND ( question_key is NULL OR question_key = '' )


-- update the reference to the schedule 
UPDATE as_std_trigger set  triggered_item_id = map.new_schedule_id 
FROM  as_std_trigger trig inner join @mapping_as_std_assess_schedule map on trig.triggered_item_id = map.schedule_id 
WHERE trig.std_assess_id = @new_std_assess_id AND trig.trigger_type in ('T', 'S', 'M', 'D'  )


-- handle circular reference between trigger and schedule tables
UPDATE  as_std_assess_schedule set event_id = trig.std_trigger_id   
FROM as_std_assess_schedule sched 
INNER JOIN as_std_trigger trig  on trig.triggered_item_id = sched.schedule_id 
WHERE trig.std_assess_id=@new_std_assess_id and trig.trigger_type in ('T', 'S', 'M', 'D' )

-- 15. Extract data from as_consistency_rule
DECLARE @new_con_id INT
SET @pgpk_table_name = 'as_consistency_rule'; 
SET @pgpk_column_name = 'consistency_rule_id'; 
SET @pgpk_script_cmd = ('UPDATE pgpk' + 
                        '   SET pgpk.next_key = actual.next_key' + 
                        '  FROM dbo.pcc_global_primary_key pgpk' + 
                        ' CROSS APPLY (SELECT MAX([' + @pgpk_column_name + ']) + 1 as next_key FROM dbo.[' + @pgpk_table_name + ']) actual' + 
                        ' WHERE pgpk.table_name = ' + quotename(@pgpk_table_name, '''') +  
                        '   AND pgpk.key_column_name = ' + quotename(@pgpk_column_name, '''') + 
                        '   AND pgpk.next_key < actual.next_key') 
EXEC sp_executesql @pgpk_script_cmd; 

DECLARE @std_trigger_id_range INT

exec get_next_primary_key 'as_consistency_rule', 'consistency_rule_id', @new_con_id  output, 1
INSERT INTO [as_consistency_rule] ([consistency_rule_id], [std_assess_id], [question_key_sbj], [question_key_obj], [enforce_inverse], [item_id], [enabled_flag], [deleted], [deleted_by], [deleted_date], [fac_id], [reg_id], [state_code], [narrative], [inverse_narrative], [external_id], [effective_date], [ineffective_date], [show_child], [question_key_info])VALUES (@new_con_id,@new_std_assess_id,N'Cust_A_2_3',N'Cust_A_2_3a',N'N',4110,N'Y',N'N',NULL,NULL,-1,NULL,NULL,N'',N'',NULL,NULL,NULL,N'Y',N'')
INSERT INTO [as_consistency_rule_range] ([consistency_rule_id], [range_type], [range])VALUES (@new_con_id,N'0',N'5')
exec get_next_primary_key 'as_consistency_rule', 'consistency_rule_id', @new_con_id  output, 1
INSERT INTO [as_consistency_rule] ([consistency_rule_id], [std_assess_id], [question_key_sbj], [question_key_obj], [enforce_inverse], [item_id], [enabled_flag], [deleted], [deleted_by], [deleted_date], [fac_id], [reg_id], [state_code], [narrative], [inverse_narrative], [external_id], [effective_date], [ineffective_date], [show_child], [question_key_info])VALUES (@new_con_id,@new_std_assess_id,N'Cust_A_3_3',N'Cust_A_3_3a',N'N',4110,N'Y',N'N',NULL,NULL,-1,NULL,NULL,N'',N'',NULL,NULL,NULL,N'Y',N'')
INSERT INTO [as_consistency_rule_range] ([consistency_rule_id], [range_type], [range])VALUES (@new_con_id,N'0',N'5')
exec get_next_primary_key 'as_consistency_rule', 'consistency_rule_id', @new_con_id  output, 1
INSERT INTO [as_consistency_rule] ([consistency_rule_id], [std_assess_id], [question_key_sbj], [question_key_obj], [enforce_inverse], [item_id], [enabled_flag], [deleted], [deleted_by], [deleted_date], [fac_id], [reg_id], [state_code], [narrative], [inverse_narrative], [external_id], [effective_date], [ineffective_date], [show_child], [question_key_info])VALUES (@new_con_id,@new_std_assess_id,N'Cust_C_2_3',N'Cust_C_2_3a',N'N',4110,N'Y',N'N',NULL,NULL,-1,NULL,NULL,N'',N'',NULL,NULL,NULL,N'Y',N'')
INSERT INTO [as_consistency_rule_range] ([consistency_rule_id], [range_type], [range])VALUES (@new_con_id,N'0',N'a')
exec get_next_primary_key 'as_consistency_rule', 'consistency_rule_id', @new_con_id  output, 1
INSERT INTO [as_consistency_rule] ([consistency_rule_id], [std_assess_id], [question_key_sbj], [question_key_obj], [enforce_inverse], [item_id], [enabled_flag], [deleted], [deleted_by], [deleted_date], [fac_id], [reg_id], [state_code], [narrative], [inverse_narrative], [external_id], [effective_date], [ineffective_date], [show_child], [question_key_info])VALUES (@new_con_id,@new_std_assess_id,N'Cust_C_2_5',N'Cust_C_2_5a',N'N',4110,N'Y',N'N',NULL,NULL,-1,NULL,NULL,N'',N'',NULL,NULL,NULL,N'Y',N'')
INSERT INTO [as_consistency_rule_range] ([consistency_rule_id], [range_type], [range])VALUES (@new_con_id,N'0',N'a')
-- 16. Extract data from cr_std_highrisk_desc
DECLARE @new_highrisk_id INT
SET @pgpk_table_name = 'cr_std_highrisk_desc'; 
SET @pgpk_column_name = 'std_highrisk_id'; 
SET @pgpk_script_cmd = ('UPDATE pgpk' + 
                        '   SET pgpk.next_key = actual.next_key' + 
                        '  FROM dbo.pcc_global_primary_key pgpk' + 
                        ' CROSS APPLY (SELECT MAX([' + @pgpk_column_name + ']) + 1 as next_key FROM dbo.[' + @pgpk_table_name + ']) actual' + 
                        ' WHERE pgpk.table_name = ' + quotename(@pgpk_table_name, '''') +  
                        '   AND pgpk.key_column_name = ' + quotename(@pgpk_column_name, '''') + 
                        '   AND pgpk.next_key < actual.next_key') 
EXEC sp_executesql @pgpk_script_cmd; 


UPDATE cr_std_highrisk_desc set triggered_key_text = map.new_std_score_id 
FROM @mapping_as_std_scoring  map 
WHERE std_obj_id = @new_std_assess_id AND triggered_key like 'SCORE_VALUE' AND map.std_score_id=triggered_key_text


UPDATE cr_std_highrisk_desc set triggered_value = map.new_map_category_id 
FROM @mapping_as_category map 
WHERE std_obj_id = @new_std_assess_id and triggered_key='SCORE_CAT' and map.map_category_id=triggered_value

-- 17. Extract data from as_std_question_qlib_question_autopopulate_rule_mapping

-- 18. Extract data from as_std_question_lookback_window

-- 19. Extract data from as_assess_census
DECLARE @new_trigger_id INT
SET @pgpk_table_name = 'as_assess_census'; 
SET @pgpk_column_name = 'trigger_id'; 
SET @pgpk_script_cmd = ('UPDATE pgpk' + 
                        '   SET pgpk.next_key = actual.next_key' + 
                        '  FROM dbo.pcc_global_primary_key pgpk' + 
                        ' CROSS APPLY (SELECT MAX([' + @pgpk_column_name + ']) + 1 as next_key FROM dbo.[' + @pgpk_table_name + ']) actual' + 
                        ' WHERE pgpk.table_name = ' + quotename(@pgpk_table_name, '''') +  
                        '   AND pgpk.key_column_name = ' + quotename(@pgpk_column_name, '''') + 
                        '   AND pgpk.next_key < actual.next_key') 
EXEC sp_executesql @pgpk_script_cmd; 

-- Handle the circular references for the schedule
UPDATE t
   SET t.event_id = c.trigger_id
  FROM as_std_assess_schedule t
  JOIN as_assess_census c on t.schedule_id = c.schedule_id
 WHERE t.std_assess_id = @new_std_assess_id
   AND t.deleted = 'N'
   AND t.std_assess_id = c.std_assess_id
   AND t.event_type = c.trigger_type
   AND t.event_id != c.trigger_id;
PRINT '19. schedule completion schedule chains';
-- Handle the circular references for the schedule completion schedules
--Since we can have schedule completion schedule chains, this query needs to be recursice.
With  Recurs (schedule_id, next_schedule, event_id, std_assess_id, correct_event_id)
 AS
( 
--base case: all newly inserted schedules that are the beginning of a chain of schedule completion schedules, keep the event_id from the beginning of the chain
SELECT schedule_id, next_schedule, event_id, std_assess_id, event_id as correct_event_id
FROM as_std_assess_schedule  where schedule_id in (select new_schedule_id from @mapping_as_std_assess_schedule) 
AND next_schedule IS NOT NULL
AND event_type NOT LIKE '%Z%'
 
UNION ALL
--recurse: all newly inserted schedules that are schedule completion schedules
SELECT d.schedule_id, d.next_schedule, d.event_id, d.std_assess_id, correct_event_id
FROM Recurs r
JOIN as_std_assess_schedule d ON d.schedule_id=r.next_schedule
)
 
UPDATE sched set event_id=rec.correct_event_id from as_std_assess_schedule sched 
JOIN Recurs rec on sched.schedule_id = rec.schedule_id 
WHERE sched.schedule_id in (select new_schedule_id from @mapping_as_std_assess_schedule) AND sched.deleted = 'N' AND sched.event_type like '%Z%' 
-- 20. Extract data from pn_template
  DECLARE @source_pn_template table (
      [template_id]  int
      ,[fac_id]  int
      ,[deleted]  char(1)
      ,[created_by]  varchar(60)
      ,[created_date]  datetime
      ,[revision_by]  varchar(60)
      ,[revision_date]  datetime
      ,[deleted_by]  varchar(60)
      ,[deleted_date]  datetime
      ,[type]  char(1)
      ,[description]  varchar(100)
      ,[system]  char(1)
      ,[retired]  char(1)
      ,[reg_id]  int
      ,[state_code]  varchar(3)
      ,[brand_id]  int
      ,[brand_pn_template_key]  varchar(50)
      primary key (template_id)
   );

     DECLARE @mapping_pn_template table (
        template_id int
       ,new_template_id int
       PRIMARY KEY (template_id)
   );
 
IF (@new_brand_id is NOT NULL and len(@brand_pn_template_key) > 0)
BEGIN
   UPDATE t
      SET brand_id = @new_brand_id
         ,brand_pn_template_key = CASE WHEN rownbr = 0 THEN @brand_pn_template_key ELSE @brand_pn_template_key + format(rownbr, '0#') END 
     FROM (select *, row_number() OVER(ORDER BY description) - 1 as rownbr FROM @source_pn_template) t
END
 
IF (@pn_type_in_use = 0 AND @pn_type_used_by_other_ass = 0 AND @pn_template_used_by_other_pn_type = 0)
BEGIN
   DECLARE  @new_pn_template_cnt int = 0
           ,@new_pn_template_id int = 0;

   SELECT @new_pn_template_cnt = count(*)
     FROM  @source_pn_template src 
     LEFT JOIN dbo.pn_template dest
       ON src.brand_id = dest.brand_id AND src.brand_pn_template_key = dest.brand_pn_template_key
    WHERE dest.template_id is NULL;

   INSERT INTO @mapping_pn_template (template_id, new_template_id)
   SELECT src.template_id, dest.template_id
     FROM  @source_pn_template src 
     LEFT JOIN dbo.pn_template dest
       ON src.brand_id = dest.brand_id AND src.brand_pn_template_key = dest.brand_pn_template_key
    WHERE dest.template_id is NOT NULL;

    IF (@new_pn_template_cnt > 0)
    BEGIN
       SET @pgpk_table_name = 'pn_template'; 
       SET @pgpk_column_name = 'template_id'; 
       SET @pgpk_script_cmd = ('UPDATE pgpk' + 
                        '   SET pgpk.next_key = actual.next_key' + 
                        '  FROM dbo.pcc_global_primary_key pgpk' + 
                        ' CROSS APPLY (SELECT MAX([' + @pgpk_column_name + ']) + 1 as next_key FROM dbo.[' + @pgpk_table_name + ']) actual' + 
                        ' WHERE pgpk.table_name = ' + quotename(@pgpk_table_name, '''') +  
                        '   AND pgpk.key_column_name = ' + quotename(@pgpk_column_name, '''') + 
                        '   AND pgpk.next_key < actual.next_key') 
       EXEC sp_executesql @pgpk_script_cmd; 
       EXEC get_next_primary_key 'pn_template', 'template_id', @new_pn_template_id  OUTPUT, @new_pn_template_cnt;

       INSERT INTO @mapping_pn_template (template_id, new_template_id)
       SELECT src.template_id,  @new_pn_template_id  + row_number() OVER (ORDER BY src.template_id) - 1
         FROM @source_pn_template  src 
         LEFT JOIN dbo.pn_template dest
           ON src.brand_id = dest.brand_id AND src.brand_pn_template_key = dest.brand_pn_template_key
        WHERE dest.template_id is NULL;
    END
    UPDATE dest
      SET dest.[fac_id] = src.[fac_id]
          ,dest.[deleted] = src.[deleted]
          ,dest.[created_by]  = @revision_by
          ,dest.[created_date] = @revision_date
          ,dest.[revision_by] = @revision_by
          ,dest.[revision_date] = @revision_date
          ,dest.[deleted_by]  = src.[deleted_by]
          ,dest.[deleted_date] = src.[deleted_date]
          ,dest.[type] = src.[type]
          ,dest.[description] = src.[description]
          ,dest.[system]  = 'Y'
          ,dest.[retired] = src.[retired]
          ,dest.[reg_id]  = src.[reg_id]
          ,dest.[state_code] = src.[state_code]
          ,dest.[brand_id] = src.[brand_id]
          ,dest.[brand_pn_template_key] = src.[brand_pn_template_key]
    FROM dbo.pn_template as dest
    JOIN  @source_pn_template as src
      ON src.brand_id = dest.brand_id AND src.brand_pn_template_key = dest.brand_pn_template_key; 

   INSERT INTO dbo.pn_template ([template_id], [fac_id], [deleted], [created_by], [created_date], [revision_by], [revision_date],
        [deleted_by], [deleted_date], [type], [description], [system], [retired], [reg_id], [state_code], [brand_id], [brand_pn_template_key])
    SELECT map.[new_template_id], src.[fac_id], src.[deleted], @revision_by, @revision_date, @revision_by, @revision_date, 
        src.[deleted_by], src.[deleted_date], src.[type], src.[description], 
		   'Y',
		   src.[retired], src.[reg_id], src.[state_code], src.[brand_id], src.[brand_pn_template_key] 
      FROM @source_pn_template as src
      JOIN @mapping_pn_template as map
        ON src.[template_id] = map.[template_id]
      LEFT JOIN dbo.pn_template dest
        ON src.brand_id = dest.brand_id AND src.brand_pn_template_key = dest.brand_pn_template_key
     WHERE dest.template_id is NULL;
END
ELSE IF (@existing_pn_type_id is NOT NULL)
BEGIN
       INSERT INTO @mapping_pn_template (template_id, new_template_id)
       SELECT src.template_id,  coalesce(dest.template_id, src.template_id)
         FROM @source_pn_template src 
         LEFT JOIN (SELECT * 
                      FROM dbo.pn_template t 
                     WHERE exists(SELECT 1 FROM pn_type s WHERE s.pn_type_id = @existing_pn_type_id AND s.template_id = t.template_id)) dest
           ON src.brand_id = dest.brand_id AND src.brand_pn_template_key = dest.brand_pn_template_key
END

-- 21. Extract data from pn_template_section
   DECLARE @source_pn_template_section table (
       [section_id]  int
      ,[deleted]  char(1)
      ,[created_by]  varchar(60)
      ,[created_date]  datetime
      ,[revision_by]  varchar(60)
      ,[revision_date]  datetime
      ,[deleted_by]  varchar(60)
      ,[deleted_date]  datetime
      ,[template_id]  int
      ,[description]  varchar(500)
      ,[sequence]  int
      ,[brand_id]  int
      ,[brand_pn_template_section_key]  varchar(50)
      primary key (section_id)
   );


   DECLARE @mapping_pn_template_section table (
       section_id int
       ,new_section_id int
       PRIMARY KEY (section_id)
   );
 
IF (@new_brand_id is NOT NULL and len(@brand_pn_template_key) > 0)
BEGIN
   UPDATE ts
      SET brand_id = @new_brand_id
         ,brand_pn_template_section_key =   CAST(@brand_pn_template_key AS NVARCHAR(10)) + '_' + format(rownbr, '0#') 
     FROM (select *, row_number() OVER(ORDER BY template_id, sequence) as rownbr FROM @source_pn_template_section) ts
END
 
IF (@pn_type_in_use = 0 AND @pn_type_used_by_other_ass = 0 AND @pn_template_used_by_other_pn_type = 0)
BEGIN

  UPDATE t
     SET template_id = new_template_id
    FROM @source_pn_template_section t
    JOIN @mapping_pn_template m
      ON t.template_id = m.template_id

   DECLARE  @new_pn_template_section_cnt int = 0
           ,@new_pn_template_section_id int = 0;

   SELECT @new_pn_template_section_cnt = count(*)
     FROM  @source_pn_template_section src 
     LEFT JOIN dbo.pn_template_section dest
       ON src.brand_id = dest.brand_id and src.brand_pn_template_section_key = dest.brand_pn_template_section_key
    WHERE dest.section_id is NULL;

   INSERT INTO @mapping_pn_template_section (section_id, new_section_id)
   SELECT  src.section_id, dest.section_id
     FROM  @source_pn_template_section src 
     LEFT JOIN dbo.pn_template_section dest
       ON src.brand_id = dest.brand_id and src.brand_pn_template_section_key = dest.brand_pn_template_section_key
    WHERE dest.section_id is NOT NULL;

    IF (@new_pn_template_section_cnt > 0)
    BEGIN
       SET @pgpk_table_name = 'pn_template_section'; 
       SET @pgpk_column_name = 'section_id'; 
       SET @pgpk_script_cmd = ('UPDATE pgpk' + 
                        '   SET pgpk.next_key = actual.next_key' + 
                        '  FROM dbo.pcc_global_primary_key pgpk' + 
                        ' CROSS APPLY (SELECT MAX([' + @pgpk_column_name + ']) + 1 as next_key FROM dbo.[' + @pgpk_table_name + ']) actual' + 
                        ' WHERE pgpk.table_name = ' + quotename(@pgpk_table_name, '''') +  
                        '   AND pgpk.key_column_name = ' + quotename(@pgpk_column_name, '''') + 
                        '   AND pgpk.next_key < actual.next_key') 
       EXEC sp_executesql @pgpk_script_cmd; 
       EXEC get_next_primary_key 'pn_template_section', 'section_id', @new_pn_template_section_id  OUTPUT, @new_pn_template_section_cnt;

      INSERT INTO @mapping_pn_template_section (section_id, new_section_id)
      SELECT src.section_id,  @new_pn_template_section_id  + row_number() OVER (ORDER BY src.section_id) - 1
        FROM @source_pn_template_section src 
        LEFT JOIN dbo.pn_template_section dest
          ON src.brand_id = dest.brand_id and src.brand_pn_template_section_key = dest.brand_pn_template_section_key
       WHERE dest.section_id is NULL;
    END
   UPDATE dest
      SET dest.[deleted] = src.[deleted]
         ,dest.[created_by] = src.[created_by]
         ,dest.[created_date] = src.[created_date]
         ,dest.[revision_by] = @revision_by
         ,dest.[revision_date] = @revision_date
         ,dest.[deleted_by] = src.[deleted_by]
         ,dest.[deleted_date] = src.[deleted_date]
         ,dest.[description] = src.[description]
         ,dest.[sequence] = src.[sequence]
         ,dest.[brand_id] = src.[brand_id]
         ,dest.[brand_pn_template_section_key] = src.[brand_pn_template_section_key]   
    FROM dbo.pn_template_section as dest
    JOIN  @source_pn_template_section as src
      ON src.brand_id = dest.brand_id and src.brand_pn_template_section_key = dest.brand_pn_template_section_key;   

   INSERT INTO dbo.pn_template_section ([section_id], [deleted], [created_by], [created_date], [revision_by], [revision_date],
           [deleted_by], [deleted_date], [template_id], [description], [sequence], [brand_id], [brand_pn_template_section_key])
    SELECT map.[new_section_id], src.[deleted], @revision_by, @revision_date, @revision_by, @revision_date,
            src.[deleted_by], src.[deleted_date], src.[template_id], src.[description], src.[sequence], src.[brand_id], src.[brand_pn_template_section_key] 
      FROM @source_pn_template_section as src
      JOIN @mapping_pn_template_section as map
        ON src.[section_id] = map.[section_id] 
      LEFT JOIN dbo.pn_template_section dest
        ON src.brand_id = dest.brand_id and src.brand_pn_template_section_key = dest.brand_pn_template_section_key
     WHERE dest.section_id is NULL;
END
ELSE IF (@existing_pn_type_id is NOT NULL)
BEGIN
       INSERT INTO @mapping_pn_template_section (section_id, new_section_id)
       SELECT src.section_id,  coalesce(dest.section_id, src.section_id)
         FROM @source_pn_template_section src 
         LEFT JOIN (SELECT * 
                      FROM dbo.pn_template_section t 
                     WHERE exists(SELECT 1 FROM pn_type s WHERE s.pn_type_id = @existing_pn_type_id AND s.template_id = t.template_id)) dest
           ON src.brand_id = dest.brand_id AND src.brand_pn_template_section_key = dest.brand_pn_template_section_key
END

-- 22. Extract data from pn_type
  DECLARE @source_pn_type table (
      [pn_type_id]  int
      ,[fac_id]  int
      ,[deleted]  char(1)
      ,[created_by]  varchar(60)
      ,[created_date]  datetime
      ,[revision_by]  varchar(60)
      ,[revision_date]  datetime
      ,[description]  varchar(75)
      ,[appears_shift]  char(1)
      ,[appears_24hr]  char(1)
      ,[is_high_risk]  char(1)
      ,[DELETED_BY]  varchar(60)
      ,[DELETED_DATE]  datetime
      ,[retired]  char(1)
      ,[template_id]  int
      ,[reg_id]  int
      ,[system]  char(1)
      ,[state_code]  varchar(3)
      ,[type_flag]  char(1)
      ,[available_for_practportal]  bit
      ,[available_for_fe]  bit
      ,[brand_id]  int
      ,[brand_pn_type_key]  varchar(50)
      primary key (pn_type_id)
   );

   DECLARE @mapping_pn_type table (
       pn_type_id int
       ,new_pn_type_id int
       PRIMARY KEY (pn_type_id)
   );
 
IF (@new_brand_id is NOT NULL and len(@brand_pn_type_key) > 0)
BEGIN
   UPDATE pt
      SET brand_id = @new_brand_id
         ,brand_pn_type_key = CASE WHEN rownbr = 0 THEN @brand_pn_type_key ELSE @brand_pn_type_key + format(rownbr, '0#') END 
     FROM (select *, row_number() OVER(ORDER BY description) - 1 as rownbr FROM @source_pn_type) pt
END
 
IF (@pn_type_in_use = 0 AND @pn_type_used_by_other_ass = 0 AND @pn_template_used_by_other_pn_type = 0)
BEGIN

  UPDATE t
     SET template_id = new_template_id
    FROM @source_pn_type t
    JOIN @mapping_pn_template m
      ON t.template_id = m.template_id

   DECLARE  @new_pn_type_cnt int = 0
           ,@new_pn_type_id int = 0;

   SELECT @new_pn_type_cnt = count(*)
     FROM  @source_pn_type src 
     LEFT JOIN dbo.pn_type dest
       ON src.brand_id = dest.brand_id and src.brand_pn_type_key = dest.brand_pn_type_key
    WHERE dest.pn_type_id is NULL;

   INSERT INTO @mapping_pn_type (pn_type_id, new_pn_type_id)
   SELECT src.pn_type_id, dest.pn_type_id
     FROM  @source_pn_type src 
     LEFT JOIN dbo.pn_type dest
       ON src.brand_id = dest.brand_id and src.brand_pn_type_key = dest.brand_pn_type_key
    WHERE dest.pn_type_id is NOT NULL;

    IF (@new_pn_type_cnt > 0)
    BEGIN
       SET @pgpk_table_name = 'pn_type'; 
       SET @pgpk_column_name = 'pn_type_id'; 
       SET @pgpk_script_cmd = ('UPDATE pgpk' + 
                        '   SET pgpk.next_key = actual.next_key' + 
                        '  FROM dbo.pcc_global_primary_key pgpk' + 
                        ' CROSS APPLY (SELECT MAX([' + @pgpk_column_name + ']) + 1 as next_key FROM dbo.[' + @pgpk_table_name + ']) actual' + 
                        ' WHERE pgpk.table_name = ' + quotename(@pgpk_table_name, '''') +  
                        '   AND pgpk.key_column_name = ' + quotename(@pgpk_column_name, '''') + 
                        '   AND pgpk.next_key < actual.next_key') 
       EXEC sp_executesql @pgpk_script_cmd; 
       EXEC get_next_primary_key 'pn_type', 'pn_type_id', @new_pn_type_id  OUTPUT, @new_pn_type_cnt;

      INSERT INTO @mapping_pn_type (pn_type_id, new_pn_type_id)
      SELECT src.pn_type_id,  @new_pn_type_id  + row_number() OVER (ORDER BY src.pn_type_id) - 1
        FROM @source_pn_type src 
        LEFT JOIN dbo.pn_type dest
          ON src.brand_id = dest.brand_id and src.brand_pn_type_key = dest.brand_pn_type_key
       WHERE dest.pn_type_id is NULL;
    END
   UPDATE dest
      SET dest.[fac_id] = src.[fac_id]
         ,dest.[deleted] = src.[deleted]
         ,dest.[created_by] = @revision_by
         ,dest.[created_date]  = @revision_date
         ,dest.[revision_by] = @revision_by
         ,dest.[revision_date] = @revision_date
         ,dest.[description] = src.[description]
         ,dest.[appears_shift] = src.[appears_shift]
         ,dest.[appears_24hr]  = src.[appears_24hr]
         ,dest.[is_high_risk]  = src.[is_high_risk]
         ,dest.[DELETED_BY]  = src.[DELETED_BY]
         ,dest.[DELETED_DATE]  = src.[DELETED_DATE]
         ,dest.[retired] = src.[retired]
         ,dest.[reg_id] = src.[reg_id]
         ,dest.[system] = 'Y'
         ,dest.[state_code] = src.[state_code]
         ,dest.[type_flag] = src.[type_flag]
         ,dest.[available_for_practportal] = src.[available_for_practportal]
         ,dest.[available_for_fe]  = src.[available_for_fe]
         ,dest.[brand_id]  = src.[brand_id]
         ,dest.[brand_pn_type_key] = src.[brand_pn_type_key]
    FROM dbo.pn_type as dest
    JOIN  @source_pn_type as src
       ON src.brand_id = dest.brand_id and src.brand_pn_type_key = dest.brand_pn_type_key

   INSERT INTO dbo.pn_type ([pn_type_id], [fac_id], [deleted], [created_by], [created_date], [revision_by], [revision_date], [description], 
        [appears_shift], [appears_24hr], [is_high_risk], [deleted_by], [deleted_date], [retired], 
        [template_id], [reg_id], [system], [state_code], [type_flag], [available_for_practportal], 
        [available_for_fe], [brand_id], [brand_pn_type_key])
    SELECT map.[new_pn_type_id], src.[fac_id], src.[deleted], @revision_by, @revision_date, @revision_by, @revision_date, src.[description], 
        src.[appears_shift], src.[appears_24hr], src.[is_high_risk], src.[deleted_by], src.[deleted_date], src.[retired], 
        src.[template_id], src.[reg_id], 
		  'Y',
		  src.[state_code], src.[type_flag], src.[available_for_practportal], 
        src.[available_for_fe], src.[brand_id], src.[brand_pn_type_key] 
      FROM @source_pn_type as src
      JOIN @mapping_pn_type as map
        ON src.[pn_type_id] = map.[pn_type_id] 
      LEFT JOIN dbo.pn_type dest
        ON src.brand_id = dest.brand_id and src.brand_pn_type_key = dest.brand_pn_type_key
     WHERE dest.pn_type_id is NULL;

    --PN TYPE ACTIVATION FOR BRANDED
    INSERT INTO dbo.[pn_type_activation] ([pn_type_id], [fac_id])
    SELECT map.[new_pn_type_id], brand_config.fac_id
    FROM @source_pn_type as src
    	JOIN @mapping_pn_type as map ON src.[pn_type_id] = map.[pn_type_id]
    	CROSS JOIN branded_library_feature_configuration as brand_config
    WHERE brand_config.brand_id = CASE WHEN (@new_brand_id IS NOT NULL) THEN @new_brand_id WHEN ('33' = '100') THEN 2 ELSE src.[brand_id] END
    	AND brand_config.fac_id <> -1 
    	AND brand_config.value = 'Y' 
    	AND brand_config.disabled_date IS NULL

    --PN TYPE ACTIVATION FOR NON-BRANDED
    INSERT INTO dbo.[pn_type_activation] ([pn_type_id], [fac_id])
    SELECT map.[new_pn_type_id], fac.fac_id
    FROM @source_pn_type as src
    	JOIN @mapping_pn_type as map ON src.[pn_type_id] = map.[pn_type_id]
    	CROSS JOIN facility as fac
    WHERE @new_brand_id IS NULL AND '33' != '100' AND src.[brand_id] IS NULL

END
ELSE IF (@existing_pn_type_id is NOT NULL)
BEGIN
   INSERT INTO @mapping_pn_type (pn_type_id, new_pn_type_id)
   SELECT src.pn_type_id,  @existing_pn_type_id
    FROM @source_pn_type src 
   WHERE brand_id = @new_brand_id and brand_pn_type_key  is null
END

-- 23. Extract data from pn_std_spn
DECLARE @mapping_std_spn_id TABLE (std_spn_id int primary key, new_std_spn_id int);
 DECLARE @new_std_spn_id int;

 SET @pgpk_table_name = 'pn_std_spn'; 
 SET @pgpk_column_name = 'std_spn_id'; 
 SET @pgpk_script_cmd = ('UPDATE pgpk' + 
                        '   SET pgpk.next_key = actual.next_key' + 
                        '  FROM dbo.pcc_global_primary_key pgpk' + 
                        ' CROSS APPLY (SELECT MAX([' + @pgpk_column_name + ']) + 1 as next_key FROM dbo.[' + @pgpk_table_name + ']) actual' + 
                        ' WHERE pgpk.table_name = ' + quotename(@pgpk_table_name, '''') +  
                        '   AND pgpk.key_column_name = ' + quotename(@pgpk_column_name, '''') + 
                        '   AND pgpk.next_key < actual.next_key') 
 EXEC sp_executesql @pgpk_script_cmd; 

-- 24. Extract data from pn_std_spn_text

UPDATE pn_std_spn_text
   SET description = replace(replace(description, CHAR(13),''),CHAR(10), CHAR(13)+CHAR(10) )
  WHERE std_spn_id  in (SELECT new_std_spn_id from @mapping_std_spn_id)

-- 25. Extract data from pn_std_spn_variable


UPDATE pssv
   SET pssv.variable_type_id = mass.new_std_score_id   
  FROM pn_std_spn_variable pssv 
  JOIN @mapping_std_spn_id mssi ON mssi.new_std_spn_id = pssv.std_spn_id AND pssv.variable_type in ('C', 'S') 
  JOIN @mapping_as_std_scoring mass ON pssv.variable_type_id = mass.std_score_id 

-- 26. Extract data from pn_spn_narrative_response
DECLARE @source_pn_spn_narrative_response table (
    [std_assess_id]  int
    ,[question_key]  varchar(16)
    ,[pick_list_id]  int
    ,[item_value]  varchar(35)
    ,[narrative_text]  varchar(500)
    PRIMARY KEY([std_assess_id], [question_key], [pick_list_id], [item_value])
);
UPDATE n SET
 pick_list_id = ISNULL(q.pick_list_id, -1)
    FROM @source_pn_spn_narrative_response n
 INNER JOIN dbo.as_std_question q
     ON  q.std_assess_id = @new_std_assess_id
     AND q.question_key  = n.question_key
;

INSERT INTO dbo.pn_spn_narrative_response (
 std_assess_id
 ,question_key
 ,pick_list_id
 ,item_value
 ,narrative_text
)
SELECT
 @new_std_assess_id
 ,question_key
 ,pick_list_id
 ,item_value
 ,narrative_text
FROM @source_pn_spn_narrative_response
WHERE pick_list_id is not null
;

-- 27. Extract data from cfg_image, as_std_assessment_cfg_image_mapping

-- 28. Update the assessment status
UPDATE as_std_assessment SET status = 'S' WHERE std_assess_id = @new_std_assess_id;

-- 29. Lock Down assessment
INSERT INTO [as_std_assessment_system_assessment_mapping] (std_assess_id, system_type_id) SELECT @new_std_assess_id ,33 where NOT EXISTS (select 1 from as_std_assessment_system_assessment_mapping where std_assess_id = @new_std_assess_id and system_type_id  = 33)

-- 30. default the PRINT option
 IF EXISTS (SELECT 1 FROM as_std_assess_PRINT_option where std_assess_id = @std_assess_id_to_delete and form_id = 21)
 BEGIN 
    UPDATE as_std_assess_PRINT_option SET std_assess_id = @new_std_assess_id where std_assess_id = @std_assess_id_to_delete and form_id = 21
 END 
 ELSE 
 BEGIN 
    INSERT INTO as_std_assess_PRINT_option ( std_assess_id, form_id) SELECT @new_std_assess_id, 21
 END

-- 31. PDF mapping
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25039, N'Cust_A_1_1', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25039 AND question_key  = N'Cust_A_1_1')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25040, N'Cust_A_1_1', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25040 AND question_key  = N'Cust_A_1_1')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25044, N'Cust_A_2_1', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25044 AND question_key  = N'Cust_A_2_1')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25043, N'Cust_A_2_2', N'' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25043 AND question_key  = N'Cust_A_2_2')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25133, N'Cust_A_2_3', NULL WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25133 AND question_key  = N'Cust_A_2_3')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25134, N'Cust_A_2_3', NULL WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25134 AND question_key  = N'Cust_A_2_3')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25135, N'Cust_A_2_3', NULL WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25135 AND question_key  = N'Cust_A_2_3')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25137, N'Cust_A_2_3', NULL WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25137 AND question_key  = N'Cust_A_2_3')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25138, N'Cust_A_2_3', NULL WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25138 AND question_key  = N'Cust_A_2_3')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25136, N'Cust_A_2_3a', N'' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25136 AND question_key  = N'Cust_A_2_3a')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25041, N'Cust_A_2_4', N'' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25041 AND question_key  = N'Cust_A_2_4')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25045, N'Cust_A_3_1', N'' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25045 AND question_key  = N'Cust_A_3_1')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25046, N'Cust_A_3_2', N'' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25046 AND question_key  = N'Cust_A_3_2')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25122, N'Cust_A_3_3', NULL WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25122 AND question_key  = N'Cust_A_3_3')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25123, N'Cust_A_3_3', NULL WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25123 AND question_key  = N'Cust_A_3_3')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25124, N'Cust_A_3_3', NULL WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25124 AND question_key  = N'Cust_A_3_3')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25126, N'Cust_A_3_3', NULL WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25126 AND question_key  = N'Cust_A_3_3')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25127, N'Cust_A_3_3', NULL WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25127 AND question_key  = N'Cust_A_3_3')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25125, N'Cust_A_3_3a', N'' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25125 AND question_key  = N'Cust_A_3_3a')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25042, N'Cust_A_3_4', N'' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25042 AND question_key  = N'Cust_A_3_4')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25004, N'Cust_B_1_1', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25004 AND question_key  = N'Cust_B_1_1')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25005, N'Cust_B_1_1', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25005 AND question_key  = N'Cust_B_1_1')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25006, N'Cust_B_1_1', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25006 AND question_key  = N'Cust_B_1_1')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25117, N'Cust_B_1_2', NULL WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25117 AND question_key  = N'Cust_B_1_2')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25118, N'Cust_B_1_2', NULL WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25118 AND question_key  = N'Cust_B_1_2')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25119, N'Cust_B_1_2', NULL WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25119 AND question_key  = N'Cust_B_1_2')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25120, N'Cust_B_1_2', NULL WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25120 AND question_key  = N'Cust_B_1_2')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25121, N'Cust_B_1_2', NULL WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25121 AND question_key  = N'Cust_B_1_2')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25009, N'Cust_B_2_1', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25009 AND question_key  = N'Cust_B_2_1')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25010, N'Cust_B_2_1', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25010 AND question_key  = N'Cust_B_2_1')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25011, N'Cust_B_2_1', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25011 AND question_key  = N'Cust_B_2_1')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25012, N'Cust_B_2_1', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25012 AND question_key  = N'Cust_B_2_1')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25013, N'Cust_B_2_1', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25013 AND question_key  = N'Cust_B_2_1')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25014, N'Cust_B_2_1', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25014 AND question_key  = N'Cust_B_2_1')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25015, N'Cust_B_2_1', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25015 AND question_key  = N'Cust_B_2_1')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25016, N'Cust_B_2_1', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25016 AND question_key  = N'Cust_B_2_1')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25017, N'Cust_B_2_1', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25017 AND question_key  = N'Cust_B_2_1')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25018, N'Cust_B_2_1', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25018 AND question_key  = N'Cust_B_2_1')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25129, N'Cust_B_3_1', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25129 AND question_key  = N'Cust_B_3_1')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25128, N'Cust_B_3_2', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25128 AND question_key  = N'Cust_B_3_2')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25071, N'Cust_B_4_1', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25071 AND question_key  = N'Cust_B_4_1')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25070, N'Cust_B_4_2', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25070 AND question_key  = N'Cust_B_4_2')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25076, N'Cust_B_4_3', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25076 AND question_key  = N'Cust_B_4_3')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25075, N'Cust_B_4_4', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25075 AND question_key  = N'Cust_B_4_4')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25074, N'Cust_B_4_5', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25074 AND question_key  = N'Cust_B_4_5')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25066, N'Cust_C_1_1', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25066 AND question_key  = N'Cust_C_1_1')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25054, N'Cust_C_1_2', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25054 AND question_key  = N'Cust_C_1_2')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25049, N'Cust_C_1_3', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25049 AND question_key  = N'Cust_C_1_3')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25050, N'Cust_C_1_3', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25050 AND question_key  = N'Cust_C_1_3')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25051, N'Cust_C_1_3', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25051 AND question_key  = N'Cust_C_1_3')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25052, N'Cust_C_1_3', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25052 AND question_key  = N'Cust_C_1_3')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25058, N'Cust_C_1_3', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25058 AND question_key  = N'Cust_C_1_3')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25061, N'Cust_C_1_3', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25061 AND question_key  = N'Cust_C_1_3')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25064, N'Cust_C_1_4', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25064 AND question_key  = N'Cust_C_1_4')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25023, N'Cust_C_1_4a', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25023 AND question_key  = N'Cust_C_1_4a')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25019, N'Cust_C_1_4b', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25019 AND question_key  = N'Cust_C_1_4b')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25021, N'Cust_C_1_4c', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25021 AND question_key  = N'Cust_C_1_4c')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25022, N'Cust_C_1_4d', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25022 AND question_key  = N'Cust_C_1_4d')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25020, N'Cust_C_1_4e', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25020 AND question_key  = N'Cust_C_1_4e')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25053, N'Cust_C_1_5', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25053 AND question_key  = N'Cust_C_1_5')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25059, N'Cust_C_1_5', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25059 AND question_key  = N'Cust_C_1_5')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25062, N'Cust_C_1_5', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25062 AND question_key  = N'Cust_C_1_5')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25067, N'Cust_C_1_5', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25067 AND question_key  = N'Cust_C_1_5')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25068, N'Cust_C_1_5', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25068 AND question_key  = N'Cust_C_1_5')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25069, N'Cust_C_1_5', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25069 AND question_key  = N'Cust_C_1_5')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25065, N'Cust_C_1_6', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25065 AND question_key  = N'Cust_C_1_6')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25028, N'Cust_C_1_6a', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25028 AND question_key  = N'Cust_C_1_6a')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25024, N'Cust_C_1_6b', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25024 AND question_key  = N'Cust_C_1_6b')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25026, N'Cust_C_1_6c', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25026 AND question_key  = N'Cust_C_1_6c')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25027, N'Cust_C_1_6d', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25027 AND question_key  = N'Cust_C_1_6d')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25025, N'Cust_C_1_6e', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25025 AND question_key  = N'Cust_C_1_6e')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25063, N'Cust_C_2_1', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25063 AND question_key  = N'Cust_C_2_1')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25056, N'Cust_C_2_2', N'Hidden notes' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25056 AND question_key  = N'Cust_C_2_2')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25001, N'Cust_C_2_3', NULL WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25001 AND question_key  = N'Cust_C_2_3')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25003, N'Cust_C_2_3', NULL WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25003 AND question_key  = N'Cust_C_2_3')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25002, N'Cust_C_2_3a', N'' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25002 AND question_key  = N'Cust_C_2_3a')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25047, N'Cust_C_2_4', NULL WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25047 AND question_key  = N'Cust_C_2_4')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25048, N'Cust_C_2_4', NULL WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25048 AND question_key  = N'Cust_C_2_4')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25036, N'Cust_C_2_5', NULL WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25036 AND question_key  = N'Cust_C_2_5')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25038, N'Cust_C_2_5', NULL WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25038 AND question_key  = N'Cust_C_2_5')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25037, N'Cust_C_2_5a', N'' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25037 AND question_key  = N'Cust_C_2_5a')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25007, N'Cust_C_2_6', NULL WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25007 AND question_key  = N'Cust_C_2_6')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25008, N'Cust_C_2_6', NULL WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25008 AND question_key  = N'Cust_C_2_6')
INSERT INTO as_std_question_qlib_form_question_mapping (std_assess_id, qlib_form_question_id, question_key, notes) SELECT @new_std_assess_id, 25055, N'Cust_C_2_7', N'' WHERE NOT EXISTS (SELECT 1 FROM as_std_question_qlib_form_question_mapping WHERE std_assess_id = @new_std_assess_id  AND qlib_form_question_id = 25055 AND question_key  = N'Cust_C_2_7')
INSERT INTO as_std_pick_list_item_value_qlib_form_field_mapping (std_assess_id, pick_list_item_value, pick_list_override_value, qlib_form_field_id, question_key) SELECT @new_std_assess_id, N'1', NULL, 25138, N'Cust_A_2_3' WHERE NOT EXISTS (SELECT 1 FROM as_std_pick_list_item_value_qlib_form_field_mapping WHERE std_assess_id = @new_std_assess_id AND pick_list_item_value = N'1' AND pick_list_override_value  IS NULL  AND qlib_form_field_id = 25138 AND question_key = N'Cust_A_2_3')
INSERT INTO as_std_pick_list_item_value_qlib_form_field_mapping (std_assess_id, pick_list_item_value, pick_list_override_value, qlib_form_field_id, question_key) SELECT @new_std_assess_id, N'2', NULL, 25133, N'Cust_A_2_3' WHERE NOT EXISTS (SELECT 1 FROM as_std_pick_list_item_value_qlib_form_field_mapping WHERE std_assess_id = @new_std_assess_id AND pick_list_item_value = N'2' AND pick_list_override_value  IS NULL  AND qlib_form_field_id = 25133 AND question_key = N'Cust_A_2_3')
INSERT INTO as_std_pick_list_item_value_qlib_form_field_mapping (std_assess_id, pick_list_item_value, pick_list_override_value, qlib_form_field_id, question_key) SELECT @new_std_assess_id, N'3', NULL, 25134, N'Cust_A_2_3' WHERE NOT EXISTS (SELECT 1 FROM as_std_pick_list_item_value_qlib_form_field_mapping WHERE std_assess_id = @new_std_assess_id AND pick_list_item_value = N'3' AND pick_list_override_value  IS NULL  AND qlib_form_field_id = 25134 AND question_key = N'Cust_A_2_3')
INSERT INTO as_std_pick_list_item_value_qlib_form_field_mapping (std_assess_id, pick_list_item_value, pick_list_override_value, qlib_form_field_id, question_key) SELECT @new_std_assess_id, N'4', NULL, 25135, N'Cust_A_2_3' WHERE NOT EXISTS (SELECT 1 FROM as_std_pick_list_item_value_qlib_form_field_mapping WHERE std_assess_id = @new_std_assess_id AND pick_list_item_value = N'4' AND pick_list_override_value  IS NULL  AND qlib_form_field_id = 25135 AND question_key = N'Cust_A_2_3')
INSERT INTO as_std_pick_list_item_value_qlib_form_field_mapping (std_assess_id, pick_list_item_value, pick_list_override_value, qlib_form_field_id, question_key) SELECT @new_std_assess_id, N'5', NULL, 25137, N'Cust_A_2_3' WHERE NOT EXISTS (SELECT 1 FROM as_std_pick_list_item_value_qlib_form_field_mapping WHERE std_assess_id = @new_std_assess_id AND pick_list_item_value = N'5' AND pick_list_override_value  IS NULL  AND qlib_form_field_id = 25137 AND question_key = N'Cust_A_2_3')
INSERT INTO as_std_pick_list_item_value_qlib_form_field_mapping (std_assess_id, pick_list_item_value, pick_list_override_value, qlib_form_field_id, question_key) SELECT @new_std_assess_id, N'1', NULL, 25127, N'Cust_A_3_3' WHERE NOT EXISTS (SELECT 1 FROM as_std_pick_list_item_value_qlib_form_field_mapping WHERE std_assess_id = @new_std_assess_id AND pick_list_item_value = N'1' AND pick_list_override_value  IS NULL  AND qlib_form_field_id = 25127 AND question_key = N'Cust_A_3_3')
INSERT INTO as_std_pick_list_item_value_qlib_form_field_mapping (std_assess_id, pick_list_item_value, pick_list_override_value, qlib_form_field_id, question_key) SELECT @new_std_assess_id, N'2', NULL, 25122, N'Cust_A_3_3' WHERE NOT EXISTS (SELECT 1 FROM as_std_pick_list_item_value_qlib_form_field_mapping WHERE std_assess_id = @new_std_assess_id AND pick_list_item_value = N'2' AND pick_list_override_value  IS NULL  AND qlib_form_field_id = 25122 AND question_key = N'Cust_A_3_3')
INSERT INTO as_std_pick_list_item_value_qlib_form_field_mapping (std_assess_id, pick_list_item_value, pick_list_override_value, qlib_form_field_id, question_key) SELECT @new_std_assess_id, N'3', NULL, 25123, N'Cust_A_3_3' WHERE NOT EXISTS (SELECT 1 FROM as_std_pick_list_item_value_qlib_form_field_mapping WHERE std_assess_id = @new_std_assess_id AND pick_list_item_value = N'3' AND pick_list_override_value  IS NULL  AND qlib_form_field_id = 25123 AND question_key = N'Cust_A_3_3')
INSERT INTO as_std_pick_list_item_value_qlib_form_field_mapping (std_assess_id, pick_list_item_value, pick_list_override_value, qlib_form_field_id, question_key) SELECT @new_std_assess_id, N'4', NULL, 25124, N'Cust_A_3_3' WHERE NOT EXISTS (SELECT 1 FROM as_std_pick_list_item_value_qlib_form_field_mapping WHERE std_assess_id = @new_std_assess_id AND pick_list_item_value = N'4' AND pick_list_override_value  IS NULL  AND qlib_form_field_id = 25124 AND question_key = N'Cust_A_3_3')
INSERT INTO as_std_pick_list_item_value_qlib_form_field_mapping (std_assess_id, pick_list_item_value, pick_list_override_value, qlib_form_field_id, question_key) SELECT @new_std_assess_id, N'5', NULL, 25126, N'Cust_A_3_3' WHERE NOT EXISTS (SELECT 1 FROM as_std_pick_list_item_value_qlib_form_field_mapping WHERE std_assess_id = @new_std_assess_id AND pick_list_item_value = N'5' AND pick_list_override_value  IS NULL  AND qlib_form_field_id = 25126 AND question_key = N'Cust_A_3_3')
INSERT INTO as_std_pick_list_item_value_qlib_form_field_mapping (std_assess_id, pick_list_item_value, pick_list_override_value, qlib_form_field_id, question_key) SELECT @new_std_assess_id, N'a', NULL, 25118, N'Cust_B_1_2' WHERE NOT EXISTS (SELECT 1 FROM as_std_pick_list_item_value_qlib_form_field_mapping WHERE std_assess_id = @new_std_assess_id AND pick_list_item_value = N'a' AND pick_list_override_value  IS NULL  AND qlib_form_field_id = 25118 AND question_key = N'Cust_B_1_2')
INSERT INTO as_std_pick_list_item_value_qlib_form_field_mapping (std_assess_id, pick_list_item_value, pick_list_override_value, qlib_form_field_id, question_key) SELECT @new_std_assess_id, N'b', NULL, 25120, N'Cust_B_1_2' WHERE NOT EXISTS (SELECT 1 FROM as_std_pick_list_item_value_qlib_form_field_mapping WHERE std_assess_id = @new_std_assess_id AND pick_list_item_value = N'b' AND pick_list_override_value  IS NULL  AND qlib_form_field_id = 25120 AND question_key = N'Cust_B_1_2')
INSERT INTO as_std_pick_list_item_value_qlib_form_field_mapping (std_assess_id, pick_list_item_value, pick_list_override_value, qlib_form_field_id, question_key) SELECT @new_std_assess_id, N'c', NULL, 25117, N'Cust_B_1_2' WHERE NOT EXISTS (SELECT 1 FROM as_std_pick_list_item_value_qlib_form_field_mapping WHERE std_assess_id = @new_std_assess_id AND pick_list_item_value = N'c' AND pick_list_override_value  IS NULL  AND qlib_form_field_id = 25117 AND question_key = N'Cust_B_1_2')
INSERT INTO as_std_pick_list_item_value_qlib_form_field_mapping (std_assess_id, pick_list_item_value, pick_list_override_value, qlib_form_field_id, question_key) SELECT @new_std_assess_id, N'd', NULL, 25121, N'Cust_B_1_2' WHERE NOT EXISTS (SELECT 1 FROM as_std_pick_list_item_value_qlib_form_field_mapping WHERE std_assess_id = @new_std_assess_id AND pick_list_item_value = N'd' AND pick_list_override_value  IS NULL  AND qlib_form_field_id = 25121 AND question_key = N'Cust_B_1_2')
INSERT INTO as_std_pick_list_item_value_qlib_form_field_mapping (std_assess_id, pick_list_item_value, pick_list_override_value, qlib_form_field_id, question_key) SELECT @new_std_assess_id, N'e', NULL, 25119, N'Cust_B_1_2' WHERE NOT EXISTS (SELECT 1 FROM as_std_pick_list_item_value_qlib_form_field_mapping WHERE std_assess_id = @new_std_assess_id AND pick_list_item_value = N'e' AND pick_list_override_value  IS NULL  AND qlib_form_field_id = 25119 AND question_key = N'Cust_B_1_2')
INSERT INTO as_std_pick_list_item_value_qlib_form_field_mapping (std_assess_id, pick_list_item_value, pick_list_override_value, qlib_form_field_id, question_key) SELECT @new_std_assess_id, N'a', NULL, 25003, N'Cust_C_2_3' WHERE NOT EXISTS (SELECT 1 FROM as_std_pick_list_item_value_qlib_form_field_mapping WHERE std_assess_id = @new_std_assess_id AND pick_list_item_value = N'a' AND pick_list_override_value  IS NULL  AND qlib_form_field_id = 25003 AND question_key = N'Cust_C_2_3')
INSERT INTO as_std_pick_list_item_value_qlib_form_field_mapping (std_assess_id, pick_list_item_value, pick_list_override_value, qlib_form_field_id, question_key) SELECT @new_std_assess_id, N'b', NULL, 25001, N'Cust_C_2_3' WHERE NOT EXISTS (SELECT 1 FROM as_std_pick_list_item_value_qlib_form_field_mapping WHERE std_assess_id = @new_std_assess_id AND pick_list_item_value = N'b' AND pick_list_override_value  IS NULL  AND qlib_form_field_id = 25001 AND question_key = N'Cust_C_2_3')
INSERT INTO as_std_pick_list_item_value_qlib_form_field_mapping (std_assess_id, pick_list_item_value, pick_list_override_value, qlib_form_field_id, question_key) SELECT @new_std_assess_id, N'a', NULL, 25048, N'Cust_C_2_4' WHERE NOT EXISTS (SELECT 1 FROM as_std_pick_list_item_value_qlib_form_field_mapping WHERE std_assess_id = @new_std_assess_id AND pick_list_item_value = N'a' AND pick_list_override_value  IS NULL  AND qlib_form_field_id = 25048 AND question_key = N'Cust_C_2_4')
INSERT INTO as_std_pick_list_item_value_qlib_form_field_mapping (std_assess_id, pick_list_item_value, pick_list_override_value, qlib_form_field_id, question_key) SELECT @new_std_assess_id, N'b', NULL, 25047, N'Cust_C_2_4' WHERE NOT EXISTS (SELECT 1 FROM as_std_pick_list_item_value_qlib_form_field_mapping WHERE std_assess_id = @new_std_assess_id AND pick_list_item_value = N'b' AND pick_list_override_value  IS NULL  AND qlib_form_field_id = 25047 AND question_key = N'Cust_C_2_4')
INSERT INTO as_std_pick_list_item_value_qlib_form_field_mapping (std_assess_id, pick_list_item_value, pick_list_override_value, qlib_form_field_id, question_key) SELECT @new_std_assess_id, N'a', NULL, 25038, N'Cust_C_2_5' WHERE NOT EXISTS (SELECT 1 FROM as_std_pick_list_item_value_qlib_form_field_mapping WHERE std_assess_id = @new_std_assess_id AND pick_list_item_value = N'a' AND pick_list_override_value  IS NULL  AND qlib_form_field_id = 25038 AND question_key = N'Cust_C_2_5')
INSERT INTO as_std_pick_list_item_value_qlib_form_field_mapping (std_assess_id, pick_list_item_value, pick_list_override_value, qlib_form_field_id, question_key) SELECT @new_std_assess_id, N'b', NULL, 25036, N'Cust_C_2_5' WHERE NOT EXISTS (SELECT 1 FROM as_std_pick_list_item_value_qlib_form_field_mapping WHERE std_assess_id = @new_std_assess_id AND pick_list_item_value = N'b' AND pick_list_override_value  IS NULL  AND qlib_form_field_id = 25036 AND question_key = N'Cust_C_2_5')
INSERT INTO as_std_pick_list_item_value_qlib_form_field_mapping (std_assess_id, pick_list_item_value, pick_list_override_value, qlib_form_field_id, question_key) SELECT @new_std_assess_id, N'a', NULL, 25008, N'Cust_C_2_6' WHERE NOT EXISTS (SELECT 1 FROM as_std_pick_list_item_value_qlib_form_field_mapping WHERE std_assess_id = @new_std_assess_id AND pick_list_item_value = N'a' AND pick_list_override_value  IS NULL  AND qlib_form_field_id = 25008 AND question_key = N'Cust_C_2_6')
INSERT INTO as_std_pick_list_item_value_qlib_form_field_mapping (std_assess_id, pick_list_item_value, pick_list_override_value, qlib_form_field_id, question_key) SELECT @new_std_assess_id, N'b', NULL, 25007, N'Cust_C_2_6' WHERE NOT EXISTS (SELECT 1 FROM as_std_pick_list_item_value_qlib_form_field_mapping WHERE std_assess_id = @new_std_assess_id AND pick_list_item_value = N'b' AND pick_list_override_value  IS NULL  AND qlib_form_field_id = 25007 AND question_key = N'Cust_C_2_6')
INSERT INTO as_std_pick_list_item_value_qlib_form_field_mapping (std_assess_id, pick_list_item_value, pick_list_override_value, qlib_form_field_id, question_key) SELECT @new_std_assess_id, N'0', NULL, 25132, N'ResidentGender' WHERE NOT EXISTS (SELECT 1 FROM as_std_pick_list_item_value_qlib_form_field_mapping WHERE std_assess_id = @new_std_assess_id AND pick_list_item_value = N'0' AND pick_list_override_value  IS NULL  AND qlib_form_field_id = 25132 AND question_key = N'ResidentGender')
INSERT INTO as_std_pick_list_item_value_qlib_form_field_mapping (std_assess_id, pick_list_item_value, pick_list_override_value, qlib_form_field_id, question_key) SELECT @new_std_assess_id, N'1', NULL, 25131, N'ResidentGender' WHERE NOT EXISTS (SELECT 1 FROM as_std_pick_list_item_value_qlib_form_field_mapping WHERE std_assess_id = @new_std_assess_id AND pick_list_item_value = N'1' AND pick_list_override_value  IS NULL  AND qlib_form_field_id = 25131 AND question_key = N'ResidentGender')
IF (@stateCode is not null)
BEGIN
-- 32. Facilities Assignment
   delete from as_std_assessment_facility where std_assess_id = @std_assess_id_to_delete or std_assess_id= @new_std_assess_id
   INSERT INTO as_std_assessment_facility (fac_id,std_assess_id)
   select distinct fac.fac_id as fac_id, assessment.std_assess_id as assess_id
      from as_std_assessment assessment, facility fac 
      where assessment.std_assess_id = @new_std_assess_id
        and fac.prov=assessment.state_code
END
select @new_std_assess_id, @assessment_name

END
END -- End of Script
GO -- execute above statements
EXEC pcc_set_db_restore_timestamp 

GO


GO

print 'A_PreUpload/US_Only/CORE-101498 - DML - NY 4397A - 1 - Client.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/US_Only/CORE-101498 - DML - NY 4397A - 1 - Client.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/US_Only/CORE-101498 - DML - NY 4397A - 2 - Versioning.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

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


declare @original_assess_desc varchar(600)
declare @new_assess_desc varchar(600)
declare @status char(1)
declare @version_number_incr char(1)
declare @revision_by varchar(60)
DECLARE @debug char(1)
DECLARE @status_code int
DECLARE @status_text varchar(3000)
set @original_assess_desc = 'NY DOH-4397A Personal Data Form_Revised - V 2'
set @new_assess_desc = 'NY DOH-4397A Personal Data Form_Revised - V 2.1'
set @status = 'S'
set @version_number_incr = 'D'
set @revision_by = 'CORE-98262'
exec sproc_clinical_dml_assessment_versioning @original_assess_desc, @new_assess_desc, @status, @version_number_incr, @revision_by, @debug, @status_code, @status_text


GO

print 'A_PreUpload/US_Only/CORE-101498 - DML - NY 4397A - 2 - Versioning.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/US_Only/CORE-101498 - DML - NY 4397A - 2 - Versioning.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/US_Only/CORE-101498 - DML - NY 4397A - 3 - fix-as_std-qlib-form-custom-data.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

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


--=============================================================================
--  Issue:            CORE-98262
--  Written By:       pcc developer
--  Script Type:      DML
--  Target DB Type:   ClientDB
--  Re-Runable:       Yes
--  Description :     Remove Document Management Mapping for discharge date and
--					  transfer reason from NY DOH-4397A Personal Data Form_Revised - V 2.1
--=============================================================================
DECLARE @stdAssessId INT = null;
SELECT @stdAssessId = std_assess_id FROM as_std_assessment WHERE description = 'NY DOH-4397A Personal Data Form_Revised - V 2.1'

---
--- DON'T CHANGE BELOW
---

IF NOT EXISTS(SELECT 1 FROM as_std_assessment WHERE std_assess_id = @stdAssessId AND description = 'NY DOH-4397A Personal Data Form_Revised - V 2.1')
BEGIN
  RAISERROR ('stdAssessId does point to a UDA with a description that has a prefix of ''NY DOH-4397A Personal Data Form_Revised - V 2.1''',-1,-1);
END
ELSE
BEGIN

  IF EXISTS(SELECT 1
            FROM information_schema.tables
            WHERE table_schema = 'dbo' AND table_name = 'as_std_qlib_form_custom_data')
  BEGIN

      DECLARE @asStdQlibFormCustomData TABLE(
        std_assess_id        INT          NOT NULL,
        form_question_id     INT          NOT NULL,
        question_key         VARCHAR(100) NOT NULL,
        autopopulate_rule_id INT          NOT NULL,
        PRIMARY KEY (std_assess_id, question_key)
      );

  	DECLARE @autoPopulateRuleInfo TABLE (
  	 question_key         VARCHAR(100) NOT NULL,
        autopopulate_rule_id INT          NOT NULL
  	);

      INSERT INTO @asStdQlibFormCustomData (std_assess_id, form_question_id, question_key, autopopulate_rule_id)
      VALUES (@stdAssessId, -1, 'census.discharge.date', 364),
             (@stdAssessId, -1, 'census.discharge.transfer_reason', 376);

      INSERT INTO @autoPopulateRuleInfo (question_key, autopopulate_rule_id)
      SELECT qfcd.question_key, qfcd.autopopulate_rule_id
        FROM WESREFERENCE.dbo.qlib_form_question qfq
        JOIN  WESREFERENCE.dbo.qlib_form_custom_data qfcd ON qfq.form_question_id = qfcd.form_question_id
       WHERE qfq.form_id = 21
        AND ((qfcd.form_question_id = 25046 AND qfcd.question_key = 'census.discharge.transfer_reason') OR
  	      (qfcd.form_question_id = 25045 AND qfcd.question_key = 'census.discharge.date'))

       UPDATE t
  	   SET t.autopopulate_rule_id = o.autopopulate_rule_id
       FROM @asStdQlibFormCustomData  t
  	 JOIN @autoPopulateRuleInfo o ON t.question_key = o.question_key;

      INSERT INTO as_std_qlib_form_custom_data (std_assess_id, form_question_id, question_key, autopopulate_rule_id)
        SELECT
          tempTable.std_assess_id,
          tempTable.form_question_id,
          tempTable.question_key,
          tempTable.autopopulate_rule_id
        FROM @asStdQlibFormCustomData tempTable
          LEFT JOIN as_std_qlib_form_custom_data asqfc
            ON tempTable.std_assess_id = asqfc.std_assess_id AND tempTable.question_key = asqfc.question_key
        WHERE asqfc.std_assess_id IS NULL;
  END
END



GO

print 'A_PreUpload/US_Only/CORE-101498 - DML - NY 4397A - 3 - fix-as_std-qlib-form-custom-data.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/US_Only/CORE-101498 - DML - NY 4397A - 3 - fix-as_std-qlib-form-custom-data.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/US_Only/CORE-101570-DML-ICD-10-CODE-UPDATE-US-2022.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

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


-- =============================================================================
 	 	-- Jira #:                      CORE-101570
 	 	--
 	 	-- Written By:          Gagandeep Singh
 	 	--
 	 	-- Script Type:         DML
 	 	-- Target DB Type:      CLIENT
 	 	-- Target ENVIRONMENT:  US Only 
 	 	--
 	 	-- Re-Runable:          Y
 	 	-- Where tested:        Teams dev db
 	 	--
 	 	-- Description of Script Function:
 	 	--              ICD-10 Updates for year 2022 related to covid-19 vaccine status
 	 	-- =================================================================================
 	 	 
 	 	DECLARE
				 @USId              int= 100
 	 	        ,@FacId            int = -1
				,@SystemFlag       char(1) = 'Y'
 	 	        ,@diagLibId        int = 4004
 	 	        ,@RevisionBy       varchar(60) = 'CORE-101570'
 	 	        ,@RevisionDate     datetime = GETDATE()
 	 	        ,@EffectiveDate    datetime = '2022-04-01'
 	 	        ,@IneffectiveDate  datetime = '2022-04-01'
 	 	        ,@Deleted          int = 1
 	 	        ,@Updated          int = 2
 	 	        ,@Added                    int = 3
 	 	        ,@Step                     int
 	 	        ,@AddRows          int = 0
 	 	        ,@DiagnosisId      int = 0
 	 	        ,@MaxId                    int = 0
 	 	        ,@status_code      int = 0
 	 	        ,@status_text      varchar(60) = ''
 	 	;
 	 	 
 	 	 
 	 	SET NOCOUNT ON
 	 	 
 	 	        /*
 	 	                Action can be:
 	 	                        1 - Disable outdated codes
 	 	                        2 - Updated Descriptions (Short, Full, Long)
 	 	                        3 - ICD-10cm Additions
 	 	        */
 	 	 
 	 	        DECLARE @ChangesTbl TABLE 
 	 	        (
 	 	                 [Action]         int             NOT NULL
 	 	                ,[Code]           varchar(15)     NOT NULL
 	 	                ,[Specificity]    varchar(1)      NULL
 	 	                ,[Long_Desc]      varchar(255)    NULL
 	 	                ,[Full_Desc]      varchar(255)    NULL
 	 	                ,[Short_Desc]     varchar(60)     NULL
 	 	                ,[Old_Long_Desc]  varchar(255)    NULL
 	 	                ,[Old_Full_Desc]  varchar(255)    NULL
 	 	                ,[Old_Short_Desc] varchar(60)     NULL
 	 	                ,[Diagnosis_Id]   int             NULL
 	 	                PRIMARY KEY CLUSTERED ( [Action], [Code] )
 	 	        );
 	 	 
 	 	--      1 - Disable outdated codes
				INSERT INTO @ChangesTbl(action, specificity, code, short_desc, full_desc, long_desc) VALUES(@Deleted,'1','Z28.3','UNDERIMMUNIZATION STATUS','Underimmunization status','UNDERIMMUNIZATION STATUS');
			
 	 	--      2 - Updated Short, Full, Long Descriptions

 	 	--      3 - ICD-10cm Additions
 	 	        INSERT INTO @ChangesTbl(action, specificity, code, short_desc, full_desc, long_desc) VALUES(@Added,'0','Z28.3','UNDERIMMUNIZATION STATUS','Underimmunization status','UNDERIMMUNIZATION STATUS');
				INSERT INTO @ChangesTbl(action, specificity, code, short_desc, full_desc, long_desc) VALUES(@Added,'0','Z28.31','UNDERIMMUNIZATION FOR COVID-19 STATUS','Underimmunization for COVID-19 status','UNDERIMMUNIZATION FOR COVID-19 STATUS');
				INSERT INTO @ChangesTbl(action, specificity, code, short_desc, full_desc, long_desc) VALUES(@Added,'1','Z28.310','UNVACCINATED FOR COVID-19','Unvaccinated for COVID-19','UNVACCINATED FOR COVID-19');
				INSERT INTO @ChangesTbl(action, specificity, code, short_desc, full_desc, long_desc) VALUES(@Added,'1','Z28.311','PARTIALLY VACCINATED FOR COVID-19','Partially vaccinated for COVID-19','PARTIALLY VACCINATED FOR COVID-19');
				INSERT INTO @ChangesTbl(action, specificity, code, short_desc, full_desc, long_desc) VALUES(@Added,'1','Z28.39','OTHER UNDERIMMUNIZATION STATUS','Other underimmunization status','OTHER UNDERIMMUNIZATION STATUS');
    
 	 		    SELECT @AddRows = COUNT(*)
 	 		    FROM @ChangesTbl c 
 	 		    WHERE c.Action = @Added --for inserts
 	 		    AND (SELECT TOP 1 dc.diagnosis_id from dbo.diagnosis_codes dc
								LEFT JOIN dbo.facility f ON  dc.fac_id=f.fac_id 
 	 		                    WHERE dc.icd9_code = c.Code and dc.specificity = (CASE WHEN c.Specificity = '0' THEN 'I' ELSE 'C' END) and dc.system_flag = @SystemFlag and dc.diag_lib_id = @DiagLibId 
								and (f.country_id = @USID or f.country_id is null) and dc.ineffective_date is null) IS NULL
 	 		    ;


 	 		    IF @AddRows > 0
				BEGIN
						DELETE FROM pcc_global_primary_key WHERE table_name='diagnosis_codes' AND key_column_name='diagnosis_id';
 	 		            EXEC dbo.get_next_primary_key 'diagnosis_codes', 'diagnosis_id', @DiagnosisId OUTPUT, @AddRows;
 	 		    END;
 	 		SET NOCOUNT OFF; 
			 
 	 		BEGIN TRANSACTION;      
 	 		 
 	 		BEGIN TRY
 	 		        
 	 		        SET @Step = 1;
 	 		        UPDATE d 
 	 		                SET d.ineffective_date = @IneffectiveDate,
 	 		                        d.revision_by = @RevisionBy,
 	 		                        d.revision_date = @RevisionDate
 	 		        FROM dbo.diagnosis_codes d
 	 		                INNER JOIN @ChangesTbl c ON d.icd9_code = c.Code AND c.Action = @Deleted --expired codes
							LEFT JOIN dbo.facility f ON  d.fac_id=f.fac_id 
 	 		        WHERE d.diag_lib_id     = @DiagLibId
 	 		          AND d.system_flag     = @SystemFlag
					  AND (f.country_id = @USID or f.country_id is null)
 	 		          AND d.created_by<>@RevisionBy AND ((d.ineffective_date IS NULL and (d.revision_by IS NULL OR d.revision_by<>@RevisionBy)) or (d.ineffective_date<>@IneffectiveDate and d.revision_by=@RevisionBy))
 	 		        ;
 	 		 
 	 		        SET @Step = 2;
 	 		        UPDATE d 
 	 		                SET d.icd9_long_desc = c.Long_Desc,
 	 		                        d.icd9_full_desc = c.Full_Desc,
 	 		                        d.icd9_short_desc = c.Short_Desc,
 	 		                        d.revision_by = @RevisionBy,
 	 		                        d.revision_date = @RevisionDate
 	 		        FROM dbo.diagnosis_codes d
 	 		                INNER JOIN @ChangesTbl c ON d.icd9_code = c.Code AND c.Action = @Updated --Updated Descriptions (Short, Full, Long)
 	 		        WHERE d.diag_lib_id     = @DiagLibId
 	 		          AND d.system_flag     = @SystemFlag
 	 		          AND ( 
 	 		                (d.icd9_long_desc <> c.Long_Desc and d.icd9_long_desc = c.Old_Long_Desc) OR
 	 		                    (d.icd9_full_desc <> c.Full_Desc and d.icd9_full_desc = c.Old_Full_Desc) OR
 	 		                    (d.icd9_short_desc <> c.Short_Desc and d.icd9_short_desc = c.Old_Short_Desc) 
 	 		                  )
 	 		          AND d.ineffective_date IS NULL
 	 		        ;
 	 		        
 	 		        
 	 		        IF @AddRows > 0
 	 		        BEGIN
 	 		                SET @Step = 3;
 	 		                -- Lower ID by 1 because UPDATE below will re-increment to correct starting point
 	 		                SET @DiagnosisId = @DiagnosisId - 1;
 	 		                SET @MaxId       = @DiagnosisId + @AddRows;
 	 		 
 	 		 
 	 		                SET @Step = 4;
 	 		                -- Populate new IDs into @ChangesTbl
 	 		                UPDATE @ChangesTbl
 	 		                        SET @DiagnosisId = [Diagnosis_Id] = @DiagnosisId + 1
 	 		                WHERE Action = @Added --ICD-10cm Additions
 	 		                ;
 	 		 
 	 		                SET @Step = 5;
 	 		                INSERT INTO dbo.diagnosis_codes 
 	 		                        (
 	 		                                 diagnosis_id
 	 		                                ,fac_id
 	 		                                ,deleted
 	 		                                ,created_by
 	 		                                ,created_date
 	 		                                ,icd9_code
 	 		                                ,icd9_long_desc
 	 		                                ,icd9_full_desc
 	 		                                ,icd9_short_desc
 	 		                                ,hotlist
 	 		                                ,mds_more_detail
 	 		                                ,cc_flag
 	 		                                ,specificity
 	 		                                ,diag_lib_id
 	 		                                ,procedure_code
 	 		                                ,system_flag
 	 		                                ,effective_date
 	 		                        )
 	 		                SELECT
 	 		                                c.Diagnosis_Id
 	 		                                ,@FacId
 	 		                                ,'N'
 	 		                                ,@RevisionBy
 	 		                                ,@RevisionDate
 	 		                                ,c.Code
 	 		                                ,c.Long_Desc
 	 		                                ,c.Full_Desc
 	 		                                ,c.Short_Desc
 	 		                                ,'N'
 	 		                                ,'Y'
 	 		                                ,'N'
 	 		                                ,case when c.Specificity = '0' then 'I' else 'C' end
 	 		                                ,@DiagLibId
 	 		                                ,'N'
 	 		                                ,@SystemFlag
 	 		                                ,@EffectiveDate
 	 		                FROM @ChangesTbl c
 	 		                WHERE c.Action = @Added --ICD-10cm Additions
 	 		                    AND (SELECT TOP 1 dc.diagnosis_id from dbo.diagnosis_codes dc
								LEFT JOIN dbo.facility f ON dc.fac_id = f.fac_id
 	 		                    where dc.icd9_code = c.Code and dc.system_flag = @SystemFlag and dc.diag_lib_id = @DiagLibId 
								and (f.country_id = @USID or f.country_id is null) and dc.ineffective_date is null) is NULL
 	 		                ;
 	 		 
 	 		        END;
 	 		        
 	 		        UPDATE dbo.diagnosis_codes
 	 		          SET specificity = case when specificity = '0' or specificity = 'I' then 'I' else 'C' end
 	 		            , mds_more_detail = 'N'
 	 		        WHERE diag_lib_id = @DiagLibId
 	 		          AND fac_id      = @FacId
 	 		          AND (specificity = '0' or specificity = '1' or mds_more_detail = 'Y')
 	 		        ;

 	 		        COMMIT TRANSACTION;
 	 		END TRY
 	 		 
 	 		BEGIN CATCH
 	 		        ROLLBACK TRANSACTION;

 	 		        SELECT
 	 		                @status_code = 1
 	 		                ,@status_text = 'Query failed at step: '
 	 		                                + CAST(@Step AS varchar(10)) +
 	 		                                + ' with Error Code: '
 	 		                                + CAST(ERROR_NUMBER() AS varchar(10))
 	 		                                + ', Line Number : '
 	 		                                + CAST(ERROR_LINE() AS varchar(10))
 	 		                                + ', Description : '
 	 		                                +  ERROR_MESSAGE()
 	 		        ;
 	 		 
 	 		END CATCH;	 
 	 		SET NOCOUNT OFF

GO

print 'A_PreUpload/US_Only/CORE-101570-DML-ICD-10-CODE-UPDATE-US-2022.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/US_Only/CORE-101570-DML-ICD-10-CODE-UPDATE-US-2022.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

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
values ('4.4.11_A', 'upload_history')


GO

print '..\Update db version.sql --****SCRIPT DONE****'

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking (script,timestamp,upload) values ('UPLOAD END',getdate(),'4.4.11_06_CLIENT_A_PreUpload_US.sql')