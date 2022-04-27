SET NOCOUNT ON
GO

SET DEADLOCK_PRIORITY HIGH
GO


insert into upload_tracking (script, timestamp, upload) values ('UPLOAD_START',getdate(),'4.4.8_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-94131 - DDL - create table pho_controlled_substance_code_rescreening.sql',getdate(),'4.4.8_06_CLIENT_B_Upload_US.sql')

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
-- Jira #:				CORE-94131
--
-- Written By:			Patrick Campbell
-- Reviewed By:
--
-- Script Type:			DDL
-- Target DB Type:		CLIENT
-- Target ENVIRONMENT:	ALL
--
--
-- Re-Runnable:			YES
--
-- Description of Script:	Create table pho_controlled_substance_code_rescreening
--
--
-- Special Instruction: None
--
-- =================================================================================
IF EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'pho_controlled_substance_code_rescreening'
		)
BEGIN
    DROP TABLE [dbo].[pho_controlled_substance_code_rescreening]
END

CREATE TABLE [dbo].[pho_controlled_substance_code_rescreening](
    [pnid] [int] NOT NULL,              --:PHI=N:Desc: unique identifier used to represent a drug name
    [ddid] [int] NOT NULL,              --:PHI=N:Desc: unique identifier used to represent a drug
    [old_controlled_substance_code] [varchar](2) NULL, --:PHI=N:Desc: existing controlled substance code
    [new_controlled_substance_code] [varchar](2) NULL, --:PHI=N:Desc: updated controlled substance code
    CONSTRAINT pho_controlled_substance_code_rescreening__pnid_ddid_CL_PK PRIMARY KEY (
     [pnid],
     [ddid])
);


GO

print 'B_Upload/01_DDL/CORE-94131 - DDL - create table pho_controlled_substance_code_rescreening.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-94131 - DDL - create table pho_controlled_substance_code_rescreening.sql',getdate(),'4.4.8_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-95449 Add dose_check_error.sql',getdate(),'4.4.8_06_CLIENT_B_Upload_US.sql')

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
--  Jira #: CORE-94012
--
--  Written By: Rhys Thomas
--  Reviewed By:
--
--  Script Type: DDL
--  Target DB Type: CLIENT
--  Target ENVIRONMENT: BOTH
--
--  Re-Runable: YES
--
--  Description of Script Function:
--  add a last_screened_time_utc DATETIME column required for the  pho_phys_order_dose_check_warning table
--
--  Special Instruction: None
-- =========================================================================================================================

-- changes to the [pho_phys_order_dose_check_warning] table

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'pho_phys_order_dose_check_warning'
			AND COLUMN_NAME = 'dose_check_error'
		)

BEGIN
ALTER TABLE [dbo].[pho_phys_order_dose_check_warning]
    ADD dose_check_error TINYINT  --:PHI=N:Desc: TINYINT of if there was an error processing the phys order when re-screened using new MSC API.
--ALTER TABLE [dbo].[pho_phys_order_dose_check_warning] DROP COLUMN dose_check_error
END



GO

GO

print 'B_Upload/01_DDL/CORE-95449 Add dose_check_error.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-95449 Add dose_check_error.sql',getdate(),'4.4.8_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-96200 - DDL - add base rate columns to ar_eff_rate_schedule.sql',getdate(),'4.4.8_06_CLIENT_B_Upload_US.sql')

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
-- Jira #:               CORE-96200
--
-- Written By:           Thomas Kim
-- Reviewed By:
--
-- Script Type:          DDL
-- Target DB Type:       CLIENT
-- Target ENVIRONMENT:   BOTH
-- Re-Runable:           YES
--
-- Where tested:		CA02QA-DB02\TEST and local dev db
--
-- Staging Recommendations/Warnings:
--
-- Description of Script Function:   add base rate values columns to ar_eff_rate_schedule
--
-- Special Instruction:
-- =================================================================================

if not exists (select 1 from information_schema.columns
                where table_name = 'ar_eff_rate_schedule'
                and column_name = 'is_reimbursement_use_hipps'
                and table_schema = 'dbo')
begin
	alter  table ar_eff_rate_schedule add is_reimbursement_use_hipps bit not null CONSTRAINT ar_eff_rate_schedule__isReimbursementUseHipps_DFLT default 0; --:PHI=N:Desc:  flag for use HIPPS in reumbursement
end

if not exists (select 1 from information_schema.columns
                where table_name = 'ar_eff_rate_schedule'
                and column_name = 'base_pt_rate'
                and table_schema = 'dbo')
begin
	alter  table ar_eff_rate_schedule add base_pt_rate money not null CONSTRAINT ar_eff_rate_schedule__basePtRate_DFLT default 0; --:PHI=N:Desc:  base PT rate
end

if not exists (select 1 from information_schema.columns
                where table_name = 'ar_eff_rate_schedule'
                and column_name = 'base_ot_rate'
                and table_schema = 'dbo')
begin
	alter  table ar_eff_rate_schedule add base_ot_rate money not null CONSTRAINT ar_eff_rate_schedule__baseOtRate_DFLT default 0; --:PHI=N:Desc:  base OT rate
end

if not exists (select 1 from information_schema.columns
                where table_name = 'ar_eff_rate_schedule'
                and column_name = 'base_slp_rate'
                and table_schema = 'dbo')
begin
	alter  table ar_eff_rate_schedule add base_slp_rate money not null CONSTRAINT ar_eff_rate_schedule__baseSlpRate_DFLT default 0; --:PHI=N:Desc:  base SLP rate
end

if not exists (select 1 from information_schema.columns
                where table_name = 'ar_eff_rate_schedule'
                and column_name = 'base_nta_rate'
                and table_schema = 'dbo')
begin
	alter  table ar_eff_rate_schedule add base_nta_rate money not null CONSTRAINT ar_eff_rate_schedule__baseNtaRate_DFLT default 0; --:PHI=N:Desc:  base NTA rate
end

if not exists (select 1 from information_schema.columns
                where table_name = 'ar_eff_rate_schedule'
                and column_name = 'base_nursing_rate'
                and table_schema = 'dbo')
begin
	alter  table ar_eff_rate_schedule add base_nursing_rate money not null CONSTRAINT ar_eff_rate_schedule__baseNursingRate_DFLT default 0; --:PHI=N:Desc:  base nursing rate
end


if not exists (select 1 from information_schema.columns
                where table_name = 'ar_eff_rate_schedule'
                and column_name = 'total_other_daily_reimb_amount'
                and table_schema = 'dbo')
begin
	alter  table ar_eff_rate_schedule add total_other_daily_reimb_amount money not null CONSTRAINT ar_eff_rate_schedule__totalOtherDailyReimbAmount_DFLT default 0; --:PHI=N:Desc:  any other daily amount for reimbursement
end


GO

GO

print 'B_Upload/01_DDL/CORE-96200 - DDL - add base rate columns to ar_eff_rate_schedule.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-96200 - DDL - add base rate columns to ar_eff_rate_schedule.sql',getdate(),'4.4.8_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-96200 - DDL - add basedon HIPPS flag to  ar_lib_date_range and ar_date_range.sql',getdate(),'4.4.8_06_CLIENT_B_Upload_US.sql')

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
-- Jira #:        CORE-96200  
--
-- Written By:           Thomas Kim
-- Reviewed By:          
--
-- Script Type:          DDL
-- Target DB Type:       CLIENT
-- Target ENVIRONMENT:   BOTH
--
--
-- Re-Runable:           YES
--
-- Where tested:         ca02qa-db02\test
--
-- Staging Recommendations/Warnings:
--
-- Description of Script Function:  
--				add reimburse based on HIPPS flag to  ar_lib_date_rangeand and ar_date_range
-- Special Instruction:
--
-- =================================================================================

IF  NOT EXISTS (SELECT 1 FROM information_schema.columns
		WHERE table_name = 'ar_lib_date_range'
		AND column_name = 'reimb_basedon_hipps_flag'
		AND table_schema = 'dbo')	
BEGIN
	ALTER TABLE [dbo].[ar_lib_date_range]
 	 	ADD [reimb_basedon_hipps_flag] char(1) not null  CONSTRAINT ar_lib_date_range__reimbBasedonHipps_flag_DFLT default 'N' --:PHI=N:Desc: flag for reimburse based on HIPPS
		
END

GO

IF NOT EXISTS (select 1 from information_schema.check_constraints
			 where constraint_name = 'ar_lib_date_range__reimbBasedonHipps_CHK'
			 and constraint_schema = 'dbo')
BEGIN
	ALTER TABLE [dbo].[ar_lib_date_range] ADD CONSTRAINT ar_lib_date_range__reimbBasedonHipps_CHK
	CHECK (reimb_basedon_hipps_flag IN('N','Y'))
END

GO

IF  NOT EXISTS (SELECT 1 FROM information_schema.columns
		WHERE table_name = 'ar_date_range'
		AND column_name = 'reimb_basedon_hipps_flag'
		AND table_schema = 'dbo')	
BEGIN
	ALTER TABLE [dbo].[ar_date_range]
 	 	ADD [reimb_basedon_hipps_flag] char(1) not null CONSTRAINT ar_date_range__reimbBasedonHipps_DFLT default 'N'   --:PHI=N:Desc: flag for reimburse based on HIPPS
		
END

GO

IF NOT EXISTS (select 1 from information_schema.check_constraints
			 where constraint_name = 'ar_date_range__reimbBasedonHipps_CHK'
			 and constraint_schema = 'dbo')
BEGIN
	ALTER TABLE [dbo].[ar_date_range] ADD CONSTRAINT ar_date_range__reimbBasedonHipps_CHK
	CHECK (reimb_basedon_hipps_flag IN('N','Y'))
END

GO


GO

print 'B_Upload/01_DDL/CORE-96200 - DDL - add basedon HIPPS flag to  ar_lib_date_range and ar_date_range.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-96200 - DDL - add basedon HIPPS flag to  ar_lib_date_range and ar_date_range.sql',getdate(),'4.4.8_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-96239 - DDL - update ar_rates__reimbRateType_CHK.sql',getdate(),'4.4.8_06_CLIENT_B_Upload_US.sql')

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
-- CORE-96239 - DDL - update ar_rates__reimbRateType_CHK
-- Written By : Thomas Kim
-- Script Type:      DDL
-- Target DB Type:   Client
-- Target Database:  Both    
-- Re-Runnable:      YES
-- Description: 
--		
--=======================================================================================================================

IF NOT EXISTS (select 1 from information_schema.check_constraints
                           where constraint_name = 'ar_rates__reimbRateType_CHK'
                           and constraint_schema = 'dbo'
						   and CHECK_CLAUSE = '([reimb_rate_type]=''PDPM_RATE'' OR [reimb_rate_type]=''FLEXIBLE_RATE'' OR [reimb_rate_type]=''CUSTOM_RATE'' OR [reimb_rate_type]=''MANUAL_RATE'' OR [reimb_rate_type]=''MARKET_RATE'' OR [reimb_rate_type]=''RATE_TEMPLATE'' OR [reimb_rate_type]=''REIMBURSEMENT_USE_HIPPS'' OR [reimb_rate_type]=''NA'')')
  BEGIN
		Alter table [dbo].[ar_rates] drop CONSTRAINT ar_rates__reimbRateType_CHK

        ALTER TABLE [dbo].[ar_rates] ADD CONSTRAINT ar_rates__reimbRateType_CHK
        CHECK ([reimb_rate_type]='PDPM_RATE' 
					OR [reimb_rate_type]='FLEXIBLE_RATE' 
					OR [reimb_rate_type]='CUSTOM_RATE' 
					OR [reimb_rate_type]='MANUAL_RATE' 
					OR [reimb_rate_type]='MARKET_RATE' 
					OR [reimb_rate_type]='RATE_TEMPLATE' 
					OR [reimb_rate_type]='REIMBURSEMENT_USE_HIPPS'
					OR [reimb_rate_type]='NA')
		
  END


GO

print 'B_Upload/01_DDL/CORE-96239 - DDL - update ar_rates__reimbRateType_CHK.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-96239 - DDL - update ar_rates__reimbRateType_CHK.sql',getdate(),'4.4.8_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-96339 - DDL - update compute fileds of  AR_EFF_RATE_SCHEDULE.sql',getdate(),'4.4.8_06_CLIENT_B_Upload_US.sql')

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
-- CORE-96339 update get rate function: change definition of is_manual_pay_rate 
-- Written By : Thomas Kim
-- Script Type:      DDL
-- Target DB Type:   Client
-- Target Database:  Both    
-- Re-Runnable:      YES
-- Description: 
--		
--=======================================================================================================================


IF NOT EXISTS(
	select 1 
	from sys.computed_columns 
	where name='is_manual_pay_rate' and object_id=object_id('dbo.AR_EFF_RATE_SCHEDULE')
		and [definition] = '(CONVERT([bit],case when [pay_rate_template_id] IS NULL AND [is_reimbursement_market_rate]=(0) AND [is_flexible_pay_rate]=(0) AND [is_reimbursement_use_hipps]=(0) then (1) else (0) end,(0)))'
)
BEGIN
	ALTER TABLE dbo.AR_EFF_RATE_SCHEDULE
	DROP COLUMN is_manual_pay_rate

	ALTER TABLE dbo.AR_EFF_RATE_SCHEDULE 
		ADD  is_manual_pay_rate
		AS (CONVERT([bit],case when [pay_rate_template_id] IS NULL AND [is_reimbursement_market_rate]=(0) AND [is_flexible_pay_rate]=(0) AND [is_reimbursement_use_hipps]=(0) then (1) else (0) end,(0)))
END


GO

print 'B_Upload/01_DDL/CORE-96339 - DDL - update compute fileds of  AR_EFF_RATE_SCHEDULE.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-96339 - DDL - update compute fileds of  AR_EFF_RATE_SCHEDULE.sql',getdate(),'4.4.8_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-96339 - DDL - update view view_ar_eff_rate_schedule.sql',getdate(),'4.4.8_06_CLIENT_B_Upload_US.sql')

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
-- PCC-72224
--
-- Written By:       Dan Bucur
-- Reviewed By: 	 Lasantha Ranawana
-- Script Type:      DDL
-- Target DB Type:   Client
-- Target Database:  Both
--
-- Re-Runnable:      YES
--
-- Staging Recommendations/Warnings: None
--
--=======================================================================================================================
-- WARNING !!! it is used in some functions, 
-- when you change it, you need to check it in B_Upload folder too to avoid sequence of build issue!
--=======================================================================================================================

set ansi_nulls on
go
set quoted_identifier on
go

if exists (select 1 from sysobjects where name = 'view_ar_eff_rate_schedule')
    drop view view_ar_eff_rate_schedule
go

create view view_ar_eff_rate_schedule as
/*
 * Primary key is eff_schedule_id
 * Business key is rate_type_id, eff_date_range_id, schedule_id
 */

select s.eff_schedule_id
      ,s.fac_id
      ,s.rate_type_id
      ,s.eff_date_range_id
      -- Note: For custom rates these values will be null. Also sometimes 
      -- payer_id = -1 on ar_date_range.
      ,r.payer_id
      ,r.eff_date_from
      ,r.eff_date_to
      ,s.bill_in_advance
      ,s.schedule_id
      ,s.default_rate
      ,s.max_days
      ,s.dollars_account_id
      ,s.days_account_id
      ,s.adj_account_id
      ,s.coverage_account_id
      ,s.use_fixed_room_charge
      ,case when s.use_fixed_room_charge = 'Y' then s.fixed_room_charge_amount else 0 
       end as fixed_room_charge_amount
      ,r.fixed_room_charge_account_id
      ,s.fixed_room_charge_revenue_code
      ,s.is_custom_rate
      ,s.rate_template_id
      ,s.rate_template_pct
      ,s.is_manual_rate
      ,s.pay_rate_template_id
      ,s.pay_rate_template_pct
      ,s.is_manual_pay_rate
      ,s.is_allow_adj
      ,s.revenue_code
      ,r.reimbursement_type
	  ,s.is_revenue_code_by_care_level
	  ,schedule.description as schedule_desc
      ,rate.long_description as rate_desc
	  ,s.market_date_range_id as market_date_range_id
	  ,s.market_rate_type_id as market_rate_type_id
	  ,s.percentage_of_market_rates as percentage_of_market_rates
	  ,s.is_market_rate as is_market_rate
	  ,s.is_reimbursement_market_rate as is_reimbursement_market_rate
	  ,s.is_flexible_pay_rate as is_flexible_pay_rate
	  -- below two care_level_template_id value can nulll 
	  -- since eff_date_range_id of ar_eff_rate_schedule can be null
	  ,r.care_level_template_id 
	  ,r.alt_care_level_template_id
	  ,r.pdpm_flag
	  ,r.reimb_basedon_hipps_flag
	  ,case when r.reimb_basedon_hipps_flag = 'Y' then s.is_reimbursement_use_hipps else 0 end is_reimbursement_use_hipps
from ar_eff_rate_schedule s
     left join ar_date_range r on (s.eff_date_range_id = r.eff_date_range_id 
                                   and r.deleted = 'N')
     left join ar_lib_rate_schedule schedule
               on (s.schedule_id = schedule.schedule_id and schedule.deleted = 'N' and schedule.version_flag = 1)
     left join ar_lib_rate_type rate
               on (s.rate_type_id = rate.rate_type_id and rate.deleted = 'N' and rate.version_flag = 1)



go



GO

print 'B_Upload/01_DDL/CORE-96339 - DDL - update view view_ar_eff_rate_schedule.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-96339 - DDL - update view view_ar_eff_rate_schedule.sql',getdate(),'4.4.8_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-97366 - DDL - add days_amount_in_0022_line_included columns to ar_invoice_transaction.sql',getdate(),'4.4.8_06_CLIENT_B_Upload_US.sql')

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
-- Jira #:               CORE-97366
--
-- Written By:           Jimmy Zhang
-- Reviewed By:
--
-- Script Type:          DDL
-- Target DB Type:       CLIENT
-- Target ENVIRONMENT:   BOTH
-- Re-Runable:           YES
--
-- Where tested:	 local dev db(DVSH_US_Code_Games_abhow)
--
-- Staging Recommendations/Warnings:
--
-- Description of Script Function:   add days_amount_in_0022_line_included columns to ar_invoice_transaction table
--
-- Special Instruction:
-- =================================================================================

if not exists (select 1 from information_schema.columns
                where table_name = 'ar_invoice_transaction'
                and column_name = 'days_amount_in_0022_line_included'
                and table_schema = 'dbo')
begin
	alter  table ar_invoice_transaction 
		add days_amount_in_0022_line_included int null  --:PHI=N:Desc:  number of days should be included when calculating service units
end

GO

GO

print 'B_Upload/01_DDL/CORE-97366 - DDL - add days_amount_in_0022_line_included columns to ar_invoice_transaction.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/01_DDL/CORE-97366 - DDL - add days_amount_in_0022_line_included columns to ar_invoice_transaction.sql',getdate(),'4.4.8_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-80338-DML Update wound weekly observation tool typo.sql',getdate(),'4.4.8_06_CLIENT_B_Upload_US.sql')

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
--  Issue:            CORE-80338
--  Written By:       Mitch Smith
--  Script Type:      DML
--  Target DB Type:   client
--  Target Database:  All
--  Re-Runable:       Yes
--  Description :     Fix typo in pick list value from STDI to SDTI (suspected deep tissue injury)
--					  and update responses on existing assessments
--=============================================================================
-- Update the pick lists items used in WOUND - WEEKLY OBSERVATION TOOL where item values are STDI 
UPDATE as_std_pick_list_item 
SET item_value = 'SDTI'
WHERE item_value = 'STDI' AND pick_list_id 
	IN (SELECT pick_list_id FROM as_std_question WHERE std_assess_id 
	IN (SELECT std_assess_id FROM as_std_assessment WHERE description LIKE '%WOUND - WEEKLY OBSERVATION TOOL%'))

-- Update rule in WOUND - WEEKLY OBSERVATION TOOL assessments that depend on STDI value
UPDATE as_consistency_rule_range
SET range = 'SDTI'
WHERE range = 'STDI' AND consistency_rule_id 
	IN (select consistency_rule_id from as_consistency_rule WHERE std_assess_id 
	IN (select std_assess_id from as_std_assessment WHERE description LIKE '%WOUND - WEEKLY OBSERVATION TOOL%'))

-- Update all the assessment responses in WOUND - WEEKLY OBSERVATION TOOL and set any STDI to SDTI
UPDATE as_response 
SET item_value = 'SDTI', revision_by = 'CORE-80338', revision_date = GETDATE(), long_username = 'System'
WHERE item_value = 'STDI' AND assess_id
	IN (SELECT assess_id FROM as_assessment WHERE std_assess_id 
	IN (SELECT std_assess_id FROM as_std_assessment WHERE description LIKE '%WOUND - WEEKLY OBSERVATION TOOL%'))


GO

print 'B_Upload/02_DML/CORE-80338-DML Update wound weekly observation tool typo.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-80338-DML Update wound weekly observation tool typo.sql',getdate(),'4.4.8_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-95717 - DML -  Security func for prth.sql',getdate(),'4.4.8_06_CLIENT_B_Upload_US.sql')

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
-- CORE-95717
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
--     * 13280.0: Performance: PRTH
--
--   URL: http://vmusnpdvshsg01/create?scriptType=I&issueKey=CORE-95717&moduleId=13&functionUpdates%5B1%5D.funcId=13280.0&functionUpdates%5B1%5D.parentId=13280.0&functionUpdates%5B1%5D.sequenceNo=13280.0&functionUpdates%5B1%5D.description=Performance%3A+PRTH&functionUpdates%5B1%5D.environment=USAR&functionUpdates%5B1%5D.accessType=YN&functionUpdates%5B1%5D.accessLevel=0&functionUpdates%5B1%5D.systemRoleAccess%5B%271728%27%5D=-999&functionUpdates%5B1%5D.systemRoleAccess%5B%271729%27%5D=-999&functionUpdates%5B1%5D.systemRoleAccess%5B%271808%27%5D=-999&functionUpdates%5B1%5D.systemRoleAccess%5B%271809%27%5D=4
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
SET @createdBy = 'CORE-95717'
--========================================================================================================
-- 13280.0: Performance: PRTH
--========================================================================================================
-- (1) Prepare @sec_function__ins ===========================================================
INSERT INTO @sec_function__ins (func_id, deleted, created_by, created_date, module_id, [type], description, parent_function, sequence_no, facility_type)
    VALUES ('13280.0', 'N', @createdBy, @NOW, @moduleId, 'YN', 'Performance: PRTH', 'Y', 13280.0, 'USAR')
-- (2) Prepare @sec_role_function__ins ======================================================
-- (2a) Add new function to all appropriate roles ------------------------------
INSERT INTO @sec_role_function__ins (role_id, func_id, created_by, created_date, revision_by, revision_date, access_level)
    SELECT DISTINCT role_id, '13280.0', @createdBy, @NOW, NULL, NULL, 0 FROM sec_role r
    WHERE @moduleId = 10 -- new functions in the "All" module are applicable to every role
        OR (module_id = @moduleId AND description <> 'Collections Setup (system)' AND description <> 'Collections User (system)')
        OR (module_id = 0 AND EXISTS (SELECT 1 FROM sec_role_function rf INNER JOIN sec_function f ON rf.func_id = f.func_id WHERE f.module_id = @moduleId AND rf.role_id = r.role_id))
-- (2c) Default Permissions: Set System Roles ----------------------------------
UPDATE @sec_role_function__ins SET access_level = 4 WHERE func_id = '13280.0' AND role_id IN (SELECT role_id FROM sec_role WHERE system_field = 'Y' AND description IN ('Performance Insights (system)'))
--========================================================================================================
-- Apply changes
--========================================================================================================
BEGIN TRAN
BEGIN TRY
    DELETE FROM sec_function WHERE func_id IN ('13280.0')
    DELETE FROM sec_role_function WHERE func_id IN ('13280.0')
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

print 'B_Upload/02_DML/CORE-95717 - DML -  Security func for prth.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-95717 - DML -  Security func for prth.sql',getdate(),'4.4.8_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-96489 - DML - update cash application enabled orgs to use new configuration parameter.sql',getdate(),'4.4.8_06_CLIENT_B_Upload_US.sql')

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
================================================================================================
JIRA:			  CORE-96489

Written By: 	  David Bretzlaff
Reviewed By:	  

Target DB Type:   CLIENT
Target Database:  BOTH

Description :   update cash application enabled orgs to use the new configuration parameter
				cash_application_version
			
================================================================================================
*/
IF EXISTS (select 1 from configuration_parameter where name = 'cash_application_version')
BEGIN
	DELETE FROM configuration_parameter 
	where name = 'cash_application_enabled'
		and fac_id = -1
END
ELSE
BEGIN
	update configuration_parameter
	set name = 'cash_application_version'
		, value = CASE when value = 'Y' then '3.1' else '0' end
	where name = 'cash_application_enabled'
		and fac_id = -1
END


GO

print 'B_Upload/02_DML/CORE-96489 - DML - update cash application enabled orgs to use new configuration parameter.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-96489 - DML - update cash application enabled orgs to use new configuration parameter.sql',getdate(),'4.4.8_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-96769 - DML - Add new mvs params for InboundAdt protocol.sql',getdate(),'4.4.8_06_CLIENT_B_Upload_US.sql')

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
-- Jira #:               CORE-96769 - DML - Add new mvs params for InboundADT protocol
--
-- Written By:           Lakshmi Karusala
-- Reviewed By:          
--
-- Script Type:          DML
-- Target DB Type:       CLIENT
-- Target ENVIRONMENT:   BOTH
--
-- Re-Runable:           YES
--
-- Where tested:         WESREFERENCE DB in 176.16.11.163,1689    
--
-- Staging Recommendations/Warnings: none
--
-- Description of Script Function: Add new mvs params for InboundADT protocol.
--
-- Special Instruction: none
--
-- =================================================================================
DECLARE @paramIdStart INT
DECLARE @seq INT

SET @paramIdStart = 102
SET @seq = 0

IF NOT EXISTS ( SELECT 1 FROM lib_message_profile_param WHERE param_id = @paramIdStart)
BEGIN
                INSERT INTO lib_message_profile_param ( param_id ,param_name)
                VALUES ( @paramIdStart ,'use_hospital_MRN')
END


SET @seq = @seq + 1

IF NOT EXISTS ( SELECT 1 FROM lib_message_profile_param WHERE param_id = @paramIdStart+@seq)
BEGIN
 	 INSERT INTO lib_message_profile_param ( param_id ,param_name)
 	 VALUES ( @paramIdStart+@seq ,'message_profile_uuid')
END

GO

print 'B_Upload/02_DML/CORE-96769 - DML - Add new mvs params for InboundAdt protocol.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-96769 - DML - Add new mvs params for InboundAdt protocol.sql',getdate(),'4.4.8_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-96784- DML - Add data for the column checksum.sql',getdate(),'4.4.8_06_CLIENT_B_Upload_US.sql')

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


-- CORE-96784	
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
-- Where tested:          pccsql-use2-nprd-trm-cli0009.bbd2b72cba43.database.windows.net ( MUS_gss_full_bip26207 database )
--
--As part of the pho_Schedule_details acrhiving process making changes to the store the checksum column value file table
--
-- =================================================================================


----Handling the changes for the table azure_data_Archive_pipeline_controller

IF  EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='azure_data_Archive_pipeline_controller'
AND COLUMN_NAME='check_sum_columns')

BEGIN
UPDATE azure_data_Archive_pipeline_controller
SET check_sum_columns='CHECKSUM(s.pho_schedule_detail_id        ,s.pho_schedule_id        ,s.created_by        ,CONVERT(DATETIME,s.created_date)        ,s.revision_by        ,CONVERT(DATETIME,s.revision_date)        ,s.deleted        ,s.deleted_by        ,CONVERT(DATETIME,s.deleted_date)        ,s.perform_by        ,CONVERT(DATETIME,s.perform_date)        ,s.chart_code        ,s.strike_out_id        ,s.followup_result     ,CONVERT(DATETIME,s.schedule_date)        ,s.dose        ,s.modified_quantity        ,s.perform_initials        ,s.followup_by     ,CONVERT(DATETIME,s.followup_date)        ,s.followup_initials        ,s.followup_pn_id     ,CONVERT(DATETIME,s.schedule_date_end)        ,s.detail_supply_id     ,CONVERT(DATETIME,s.effective_date)        ,CONVERT(DATETIME,s.followup_effective_date)     )'
WHERE controller_id=1
END


IF  EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='azure_data_Archive_pipeline_controller'
AND COLUMN_NAME='check_sum_column_filter')

BEGIN
UPDATE azure_data_Archive_pipeline_controller
SET check_sum_column_filter='schedule_date DATETIME'
WHERE controller_id=1
END



IF  EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='azure_data_Archive_pipeline_controller'
AND COLUMN_NAME='check_sum_unique_id_column')

BEGIN
UPDATE azure_data_Archive_pipeline_controller
SET check_sum_unique_id_column='s.pho_schedule_detail_id'
WHERE controller_id=1
END



IF  EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='azure_data_Archive_pipeline_controller'
AND COLUMN_NAME='sql_query_select')

BEGIN
UPDATE azure_data_Archive_pipeline_controller
SET sql_query_select='s.pho_schedule_detail_id,s.pho_schedule_id,s.created_by,s.created_date,s.revision_by,s.revision_date ,s.deleted,s.deleted_by,s.deleted_date,s.perform_by,s.perform_date,s.chart_code,s.strike_out_id,s.followup_result,s.schedule_date,s.dose,s.modified_quantity,s.perform_initials,s.followup_by,s.followup_date,s.followup_initials,s.followup_pn_id        ,s.schedule_date_end        ,s.detail_supply_id,s.effective_date,s.followup_effective_date'
WHERE controller_id=1
END


GO

print 'B_Upload/02_DML/CORE-96784- DML - Add data for the column checksum.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/CORE-96784- DML - Add data for the column checksum.sql',getdate(),'4.4.8_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.8_06_CLIENT_B_Upload_US.sql')

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
values ('4.4.8_B', 'upload_history')


GO

print '..\Update db version.sql --****SCRIPT DONE****'

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.8_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking (script,timestamp,upload) values ('UPLOAD END',getdate(),'4.4.8_06_CLIENT_B_Upload_US.sql')