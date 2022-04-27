SET NOCOUNT ON
GO

SET DEADLOCK_PRIORITY HIGH
GO


insert into upload_tracking (script, timestamp, upload) values ('UPLOAD_START',getdate(),'4.4.9.3_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/US_Only/CORE-99074-DML-Update_rebillDate_for_AssistTherapy_clients.sql',getdate(),'4.4.9.3_06_CLIENT_B_Upload_US.sql')

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
-- CORE-99074
--
-- Written By:       chakra
--
-- Script Type:      DML
-- Target DB Type:   Client
-- Target Database:  US
--
-- Re-Runnable:      YES
--
-- Staging Recommendations/Warnings: None
--
-- Description of Script Function:
-- back date client tx rebill date to 01-01-2022 for clients affcted by Assistant Reimbursement reduction for PT/OT charges 
--
--=======================================================================================================================

IF OBJECT_ID('tempdb..#AffectedTxList') IS NOT NULL DROP TABLE #AffectedTxList
IF OBJECT_ID('tempdb..#clientid') IS NOT NULL DROP TABLE #clientid
IF OBJECT_ID('tempdb..#affectedClientIds') IS NOT NULL DROP TABLE #affectedClientIds

CREATE TABLE #AffectedTxList 
( 
	transaction_id INT, 
	fac_id INT, 
	batch_id INT ,
	item_type_id INT, 
	client_id INT , 
	payer_id INT , 
	effective_date datetime ,
	transaction_date datetime ,
	entry_number INT,
	days_amount INT ,
	eff_dr_id INT ,
	prt_id INT,
	is_assistant BIT,
	assistant_therapy_pct MONEY,
	amount money,
	transaction_type varchar(10),
	distribution_tx_id int,
	parent_tx_type varchar(10),
	revenue_code varchar (10),
	reversing_tx_id int
)


insert into #AffectedTxList
select transaction_id,
	fac_id,
	batch_id,
	item_type_id,
	client_id,
	payer_id,
	effective_date,
	transaction_date,
	entry_number,
	days_amount,
	null,null,null,null,ar_transactions.amount,transaction_type,distribution_tx_id, parent_tx_type,SUBSTRING(revenue_code,1,2),reversing_tx_id
from ar_transactions WITH (NOLOCK) 
where deleted ='N'
	and effective_date > '2021-12-31' 
	and (distribution_tx_id IS NULL  OR distribution_tx_id  = transaction_id)
	and transaction_type IN ( 'A')
	and( therapy_modifier in ('CO','CQ') or therapy_modifier2  in ('CO','CQ') or therapy_modifier3  in ('CO','CQ') )
	and SUBSTRING(revenue_code,1,2) in ('42','43') 

update t set
	   t.eff_dr_id = dr.eff_date_range_id,
	   t.prt_id = prt.prt_id,
	   t.is_assistant = prt.therapy_by_assistant,
	   t.assistant_therapy_pct = prt.assistant_therapy_pct
from ar_payer_rules_template prt WITH (NOLOCK)
			JOIN ar_date_range dr WITH (NOLOCK)
				ON prt.eff_date_range_id = dr.eff_date_range_id
					AND dr.deleted = 'N'
			JOIN view_ar_item_prt iprt WITH (NOLOCK)
				ON prt.prt_id = iprt.prt_id
					AND dr.eff_date_range_id = iprt.eff_date_range_id
			JOIN  #AffectedTxList t
				ON iprt.item_type_id = t.item_type_id
					AND dr.payer_id = t.payer_id
					AND dr.fac_id = t.fac_id
					AND (dr.eff_date_to >= t.effective_date OR dr.eff_date_to IS NULL)
					AND dr.eff_date_from <= t.effective_date
					AND prt.therapy_by_assistant = 1
		where prt.covered = 'Y'

delete from #AffectedTxList
where (is_assistant IS NULL OR is_assistant=0 OR reversing_tx_id IS NOT NULL)

select distinct f.fac_id, a.client_id
into #clientid
from #AffectedTxList a
JOIN ar_transactions child with (nolock) ON child.distribution_tx_id = a.transaction_id and child.fac_id = a.fac_id and child.client_id = a.client_id
JOIN facility f with (nolock) ON f.fac_id=a.fac_id
Where a.batch_id IS NOT NULL and child.transaction_type = 'XR' 
and child.deleted='N'

delete from #AffectedTxList where client_id in (select client_id from #clientid);

select distinct client_id into #affectedClientIds from #AffectedTxList ;

update c
SET c.rebill_from_date = '2022-01-01 00:00:00.000', revision_by='CORE-99074', revision_date=getdate()
from ar_client_configuration c with (nolock) where
(c.rebill_from_date > '2022-01-31 00:00:00.000' OR c.rebill_from_date IS NULL)
and client_id in (select client_id from #affectedClientIds )


DROP TABLE #AffectedTxList
DROP TABLE #clientid
DROP TABLE #affectedClientIds






GO

print 'B_Upload/02_DML/US_Only/CORE-99074-DML-Update_rebillDate_for_AssistTherapy_clients.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('B_Upload/02_DML/US_Only/CORE-99074-DML-Update_rebillDate_for_AssistTherapy_clients.sql',getdate(),'4.4.9.3_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.9.3_06_CLIENT_B_Upload_US.sql')

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
values ('4.4.9.3_B', 'upload_history')


GO

print '..\Update db version.sql --****SCRIPT DONE****'

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.9.3_06_CLIENT_B_Upload_US.sql')

GO

insert into upload_tracking (script,timestamp,upload) values ('UPLOAD END',getdate(),'4.4.9.3_06_CLIENT_B_Upload_US.sql')