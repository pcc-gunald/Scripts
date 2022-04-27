

SET NOCOUNT ON
GO

SET DEADLOCK_PRIORITY HIGH
GO


insert into upload_tracking (script, timestamp, upload) values ('UPLOAD_START',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/ CORE-90985 - DML Update ePrescribe security function to be visible in CDN jurisdiction.sql',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')

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
-- Jira #:               CORE-90985
--
-- Written By:           Daniela El Masery
-- Reviewed By:
--
-- Script Type:          DML
-- Target DB Type:       Client DB
-- Target Environment:   US and CDN
--
--
-- Re-Runable:           NO
--
-- Where tested:
--
-- Staging Recommendations/Warnings:
--
-- Description of Script Function:
--   * Update corporation parameter 'facility_type' to NULL on table sec_function where func_id='5891.9. 
--   * The reason is that ePrescribe parameter needs to be shown for all type of organization: CAN and USA 
--   * when the user selects Admin -> Setup -> Security Roles -> Clinical Setup Role (system)
--
-- Special Instruction:
--
--
-- =================================================================================


IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'sec_function' 
                                                        AND TABLE_SCHEMA = 'dbo')
BEGIN
    -- Update facility_type to NULL for function 5891.9 to allow displaying the ePrescribe parameter for
    -- USA and CAN organizations.
   UPDATE dbo.sec_function SET facility_type=CAST(NULL as varchar(5)) WHERE func_id ='5891.9'
END

GO

print 'A_PreUpload/ CORE-90985 - DML Update ePrescribe security function to be visible in CDN jurisdiction.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/ CORE-90985 - DML Update ePrescribe security function to be visible in CDN jurisdiction.sql',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/01 - CORE-95378- DDL - create change set tables.sql',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')

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
CORE-95378        Revisiting Change Set DB Design. Needed for Sparta
 
Written By:       Elias Ghanem
 
Script Type:      DDL
Target DB Type:   Client
Target Database:  BOTH
Re-Runable:       YES
 
Description :     Create change set tables
Re-creates tables : drops if exists and creates brand new tables and related objects
==============================================================================
*/

--DROP TABLES
IF EXISTS (SELECT * FROM sys.tables WHERE NAME = 'changeset_status')
BEGIN
	DROP TABLE [dbo].[changeset_status]
END

IF EXISTS (SELECT * FROM sys.tables WHERE NAME = 'pho_phys_order_changeset')
BEGIN
	DROP TABLE [dbo].[pho_phys_order_changeset]
END

--CREATE pho_phys_order_changeset TABLE
CREATE TABLE [dbo].[pho_phys_order_changeset](--:PHI=N:Desc:Holds all changeset requests sent by the pharmacy or performed by the wellness director
	[phys_order_changeset_id] [bigint] IDENTITY NOT NULL,--:PHI=N:Desc:Id of the changeset row
	[message_id] [varchar](60) NULL,--:PHI=N:Desc:Id of the related PIMS message that led to the creation of this row. This field is not a foreign key to another table
	[phys_order_id] [int] NULL,--:PHI=N:Desc:Id of the order that this change set targets
	[changeset_type_id] [int] NOT NULL,--:PHI=N:Desc:Type of the change requested. This field is not a foreign to another table. Allowed values are:(1, new order), (2, update to an order), (3, discontinue of an order)
	[changeset_source_id] [int] NOT NULL,--:PHI=N:Desc:Indicates the source of the changeset (pharmacy or WDW). This field is not a foreign key to another table. Allowed vlaues are: (1,pharmacy), (2,WDW)
	[changeset_data] [varchar](8000) NOT NULL,--:PHI=Y:Contains the changeset to be applied to the order. May contain resident information, medication name...
	[resulting_phys_order_id] [int] NULL,--:PHI=N:Desc:In case the changeset results in the creation of new order, this field holds the Id of this new order
	[current_status_id] [bigint] NULL,--:PHI=N:Desc:Holds the Id of the current status in changeset_status table. This field is not a physical foreign key but act as a logical foreign key to changeset_status table
	[aggregate_changeset_id] [bigint] NULL,--:PHI=N:Desc:When multiple changest rows are agregated, this field holds the Id for the resulting changeset
	[version] [int] NOT NULL,--:PHI=N:Desc:Represent the current version of the order
	[created_by] [varchar](60) NOT NULL,--:PHI=N:Desc:Who created the changeset
	[created_date] [datetime] NOT NULL,--:PHI=N:Desc:Created date of the changeset
	CONSTRAINT [pho_phys_order_changeset__physOrderChangesetId_PK_CL_IX] PRIMARY KEY ([phys_order_changeset_id]),
	CONSTRAINT [pho_phys_order_changeset__changeset_type_id_CHK] CHECK (changeset_type_id IN (1, 2, 3)),
	CONSTRAINT [pho_phys_order_changeset__changeset_source_id_CHK] CHECK (changeset_source_id IN (1, 2))
)

--CREATE changeset_status TABLE
CREATE TABLE [dbo].[changeset_status](--:PHI=N:Desc:A detail table for pho_phys_order_changeset. It hold all the statuses of the changeset records
	[changeset_status_id] [bigint] IDENTITY NOT NULL,--:PHI=N:Desc:Id of the changeset_status row
	[changeset_id] [bigint] NOT NULL,--:PHI=N:Desc:Holds the Id of the parent pho_phys_order_changeset row
	[status_id] [int] NOT NULL,--:PHI=N:Desc:Holds the satatus Id. This field is not a foreign key to another table. Allowed values are: (1, New), (2, Confirmed), (3,Declined), (4,Reviewed)
	[status_source] [int] NOT NULL,--:PHI=N:Desc:Represents the entity that moved the changeset to this status. This field is not a foreign key to another table. Allowed values are: (1,pharmacy), (2,WDW)
	[status_by] [varchar](60) NOT NULL,--:PHI=N:Desc:Who created the status
	[status_date] [datetime] NOT NULL,--:PHI=N:Desc:Created date of the status
	CONSTRAINT [changeset_status__ChangesetStatusId_PK_CL_IX] PRIMARY KEY ([changeset_status_id]),
	CONSTRAINT [changeset_status__status_id_CHK] CHECK (status_id IN (1, 2, 3, 4)),
	CONSTRAINT [changeset_status__status_source_CHK] CHECK (status_id IN (1, 2))
)

--CREATE FOREIGN KEYS AND INDEXES
IF EXISTS (SELECT * FROM sys.tables WHERE NAME = 'pho_phys_order_changeset') AND EXISTS (SELECT * FROM sys.tables WHERE NAME = 'changeset_status')
BEGIN
	ALTER TABLE [dbo].[changeset_status] ADD CONSTRAINT [changeset_status__changeset_id__FK] FOREIGN KEY([changeset_id])
	REFERENCES [dbo].[pho_phys_order_changeset] ([phys_order_changeset_id])
	
	CREATE NONCLUSTERED INDEX [changeset_status__changesetId_FK_IX]
	ON [dbo].[changeset_status] ([changeset_id]);
		
	ALTER TABLE [dbo].[pho_phys_order_changeset] ADD CONSTRAINT [pho_phys_order_changeset__aggregate_changeset_id__FK] FOREIGN KEY([aggregate_changeset_id])
	REFERENCES [dbo].[pho_phys_order_changeset] ([phys_order_changeset_id])
	
	ALTER TABLE [dbo].[pho_phys_order_changeset] ADD CONSTRAINT [pho_phys_order_changeset__phys_order_id__FK] FOREIGN KEY([phys_order_id])
	REFERENCES [dbo].[pho_phys_order] ([phys_order_id])
	
	ALTER TABLE [dbo].[pho_phys_order_changeset] ADD CONSTRAINT [pho_phys_order_changeset__resulting_phys_order_id__FK] FOREIGN KEY([resulting_phys_order_id])
	REFERENCES [dbo].[pho_phys_order] ([phys_order_id])
	
	CREATE NONCLUSTERED INDEX [pho_phys_order_changeset__aggregate_changeset_id_FK_IX]
	ON [dbo].[pho_phys_order_changeset] ([aggregate_changeset_id]);
	
	CREATE NONCLUSTERED INDEX [pho_phys_order_changeset__current_status_id_id_FK_IX]
	ON [dbo].[pho_phys_order_changeset] ([current_status_id]);
	
END

GO

print 'A_PreUpload/01 - CORE-95378- DDL - create change set tables.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/01 - CORE-95378- DDL - create change set tables.sql',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/02 - CORE-95333 -01- DDL - sproc_sprt_pho_getOrderStatus.sql',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')

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



-- =========================================================================================================================
--
--  Script Type: user defined store procedure
--  Target DB Type:  Client
--  Target Database:  Both
--
--  Re-Runable:  Yes
--
--  Description :  Get Order Status for a preselected list of orders inserted beforehand into #tempresult
--
-- Change History:
--   Date			Jira				Team		Author				Comment
-- -----------------------------------------------------------------------------------------------------------------------------------
--   09/28/2021     SPRT-740			Coda	    Elias Ghanem  		Created.
-- =========================================================================================================================

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sproc_sprt_pho_getOrderStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [dbo].[sproc_sprt_pho_getOrderStatus]
GO

CREATE
proc [dbo].[sproc_sprt_pho_getOrderStatus]
(
    @debug          char(1)  = 'N',
    @status_code    int  out,
    @status_text    varchar(3000) out
)
AS
BEGIN

SET NOCOUNT ON

DECLARE @step           int,
        @error_code     int
   
CREATE TABLE #tempResult_local
(
	phys_order_id int,
	fac_id int,
	client_id int,
	order_verified varchar(1),
	active_flag char(1),
	draft bit,
	hold_date datetime,
	hold_date_end datetime,
	end_date datetime,
	discontinued_date datetime,
	order_category_id int,
	controlled_substance_code int,
	created_date datetime,
	order_class_id tinyint,
	facility_time datetime,
	IsDischargeEnabled  BIT
)

CREATE TABLE #adminOrder
(
	admin_order_id int,
	created_date datetime,
	effective_date datetime,
	ineffective_date datetime,
	related_phys_order_id int ,
	order_verified char,
	order_relationship_id int,
	facility_date datetime
)

CREATE CLUSTERED INDEX #adminOrder_IX on #adminOrder
(
	related_phys_order_id,
	effective_date,
	created_date,
	admin_order_id,
	ineffective_date,
	order_verified,
	order_relationship_id
)

BEGIN TRY

SET @status_code = 0

SET @step = 1
SET @status_text = CONVERT(VARCHAR(26), GETDATE(), 13) + ' Insert data in #tempResult_local'
IF @debug='Y' PRINT @status_text	
INSERT INTO #tempResult_local (phys_order_id,fac_id,client_id,order_verified,active_flag,
	draft,hold_date,hold_date_end,end_date,discontinued_date,order_category_id, controlled_substance_code, facility_time, IsDischargeEnabled)
	select phys_order_id,fac_id,client_id,order_verified,active_flag,
	draft,hold_date,hold_date_end,end_date,discontinued_date,order_category_id, controlled_substance_code, facility_time, IsDischargeEnabled from #tempresult
	
SET @step = 1.1
SET @status_text = CONVERT(VARCHAR(26), GETDATE(), 13) + ' Update data in #tempResult_local based on IsDischargeEnabled'
IF @debug='Y' PRINT @status_text	
UPDATE tl 
	set tl.created_date = p.created_date, tl.order_class_id = p.order_class_id
FROM #tempResult_local tl
	INNER JOIN pho_phys_order p ON p.phys_order_id = tl.phys_order_id AND p.order_class_id = 2
	WHERE tl.IsDischargeEnabled = 1


SET @step = 2
SET @status_text = CONVERT(VARCHAR(26), GETDATE(), 13) + ' Insert admin orders'
IF @debug='Y' PRINT @status_text

  INSERT into #adminOrder(admin_order_id,created_date,effective_date,ineffective_date,related_phys_order_id,order_verified,order_relationship_id,facility_date)
	SELECT
		pao.admin_order_id,pao.created_date,pao.effective_date,pao.ineffective_date, pro.related_phys_order_id,po.order_verified,pro.order_relationship_id,ppo.facility_time
	FROM
		dbo.pho_related_order pro
		INNER JOIN dbo.pho_admin_order pao ON pao.phys_order_id = pro.phys_order_id
		INNER JOIN #tempResult_local ppo ON ppo.phys_order_id = pro.related_phys_order_id
		--inner join #clients c on ppo.client_id = c.client_id
		INNER JOIN pho_phys_order po ON po.phys_order_id = pao.phys_order_id
	WHERE
		ISNULL(pro.deleted,'N')='N'
		AND pao.deleted='N'
		AND pao.exclude_eom_status_calculation=0

--------------------------------------------------
  SET @step = 3
  SET @status_text = CONVERT(VARCHAR(26), GETDATE(), 13) + ' select order statuses'
  IF @debug='Y' PRINT @status_text  
  
    SELECT
    --data.relationship_code,
    ppo.phys_order_id,
    ppo.fac_id,
    CASE
		WHEN
			ppo.IsDischargeEnabled = 1
            AND ppo.order_class_id IS NOT NULL AND ppo.order_class_id=2
			AND ppo.created_date < (SELECT c.admission_date FROM clients c WHERE c.client_id = ppo.client_id)
        THEN 12 -- historical completed

		WHEN 
			ISNULL(ppo.active_flag, 'Y') = 'Y' 
			AND esign.phys_order_id IS NOT NULL
		THEN (CASE WHEN ppo.controlled_substance_code IN (2,3,4,5,6) AND esign.marked_to_sign_contact_id IS NULL THEN 10 -- Pending Mark To Sign
              ELSE 11 -- Pending Order Signature
              END) 
             
        WHEN
            (
                (
                    data.relationship_code = 'DC' --admin order is Discontinue
                    AND ISNULL(data.adminOrderVerified,'Y') = 'Y' --admin order is verified.
                )
                OR
                ( ppo.discontinued_date IS NOT NULL AND ppo.discontinued_date < ppo.facility_time )
            )
            AND ISNULL(ppo.active_flag, 'Y') = 'Y'
        THEN 2 -- discontinued
        
    	WHEN
            (
                ppo.order_verified = 'N'
                or
                (data.adminOrderVerified = 'N' OR ISNULL(unverifiedOrders.oneOrderVerified,'N') = 'Y')
            )
            AND ISNULL(ppo.active_flag, 'Y') = 'Y'
        THEN 8 -- unconfirmed

		WHEN 
			ISNULL(ppo.order_verified,'Y') = 'Y' AND
			ISNULL(ppo.active_flag, 'Y') = 'Y' AND
			clinrev.created_date IS NOT NULL
			
		THEN 9 -- order verified, pending clinical review.

        WHEN
            ppo.draft = 0 -- not draft
            AND ISNULL(ppo.order_verified,'Y') = 'Y'  -- order is verified
            AND
                (
                    (data.relationship_code IS NULL or data.relationship_code NOT IN ('H','DC')) -- no admin orders
                    AND
                    ISNULL(data.adminOrderVerified, 'Y') = 'Y' --admin order is verified or doesn't exist.
                )
            AND
            (
                ppo.hold_date IS NULL
                OR (ppo.hold_date > ppo.facility_time AND ppo.hold_date_end IS NULL)
                OR (ppo.facility_time NOT BETWEEN  ppo.hold_date and ppo.hold_date_end)
            )
            AND (ppo.end_date IS NULL OR (ppo.end_date > ppo.facility_time or poes.phys_order_id IS NOT NULL))-- not completed
            AND ( ppo.discontinued_date IS NULL OR ppo.discontinued_date > ppo.facility_time )
            AND ISNULL(ppo.active_flag, 'Y') = 'Y'
        THEN 1 --active

        WHEN
            ppo.draft = 0 -- not draft
            AND ISNULL(ppo.order_verified,'Y') = 'Y'-- order is verified
            AND
                (
                    (
                        ((ppo.hold_date <= ppo.facility_time AND ppo.hold_date_end IS NULL)
                        OR (ppo.facility_time BETWEEN  ppo.hold_date AND ppo.hold_date_end))
                        AND ISNULL(data.adminOrderVerified,'Y') = 'Y'
                    )
                    OR
                    (
                        data.relationship_code = 'H' --admin order is hold
                        AND ISNULL(data.adminOrderVerified,'Y') = 'Y' --admin order is verified.
                    )
                )
            AND (ppo.end_date IS NULL OR (ppo.end_date > ppo.facility_time or poes.phys_order_id IS NOT NULL))--not completed
            AND ( ppo.discontinued_date IS NULL OR ppo.discontinued_date > ppo.facility_time )
            AND ISNULL(ppo.active_flag, 'Y') = 'Y'
        THEN 5 -- onhold

		WHEN
            ppo.end_date IS NOT NULL AND ppo.end_date <= ppo.facility_time
            AND ISNULL(ppo.active_flag, 'Y') = 'Y'
        THEN 3 -- completed

        WHEN
            ppo.active_flag = 'N' -- should only by queued orders.
        THEN -1
        ELSE -1
    END
    AS order_status,
    (
        CASE
            WHEN ISNULL(unverifiedOrders.oneOrderVerified,'N') = 'Y'
            THEN
                unverifiedOrders.order_relationship_id
            ELSE
                data.order_relationship_id
        END
    ) AS  order_relationship,
    --data.order_relationship_id as order_relationship,
    (CASE  -- for  unconfirmed pharmacy orders return extra order status reason
        WHEN ((ppo.order_verified = 'N' OR (ISNULL(unverifiedOrders.oneOrderVerified,'N') = 'Y' OR data.adminOrderVerified = 'N' ) ) AND ISNULL(ppo.active_flag, 'Y') = 'Y' )
        then
            case
        
             when ISNULL(unverifiedOrders.oneOrderVerified,'N') = 'Y'
                    THEN
                        CASE
                            WHEN (unverifiedOrders.relationship_code = 'H')  THEN -1
                            WHEN (unverifiedOrders.relationship_code = 'R') THEN -2
                            WHEN (unverifiedOrders.relationship_code = 'DC') THEN -3
                            WHEN  ppo.order_category_id = 3022 AND  posp.reason_binary_code IS NOT NULL THEN posp.reason_binary_code
                         END
                    ELSE
                        CASE

                            WHEN (data.relationship_code = 'H' OR unverifiedOrders.relationship_code = 'H')  THEN -1
                            WHEN (data.relationship_code = 'R' OR unverifiedOrders.relationship_code = 'R') THEN -2
                            WHEN (data.relationship_code = 'DC' OR unverifiedOrders.relationship_code = 'DC') THEN -3
                            WHEN  ppo.order_category_id = 3022 and  posp.reason_binary_code IS NOT NULL THEN posp.reason_binary_code
                            ELSE NULL
                        END   
            END
        ELSE NULL
    END) AS status_reason

FROM
    #tempResult_local ppo
    LEFT JOIN
    (
        --done as an sub select because of performance.
        SELECT
            por.relationship_code,
            adm.order_verified as adminOrderVerified,
            maxAdminOrder.related_phys_order_id,
            por.order_relationship_id
        FROM
        (
            --this query returns the max created date for the max effective date before the specific date.
            SELECT
                adm.related_phys_order_id,
                adm.effective_date,
                MAX(adm.created_date) created_date
            FROM
            (
                --this query returns the max effective date before the specific date.
                SELECT
                    related_phys_order_id,
                    MAX(effective_date) effective_date
                FROM
                    #adminOrder
                WHERE
                    effective_date<=facility_date
                GROUP BY
                    related_phys_order_id
            )AS maxAdminEffDate
            INNER JOIN #adminOrder adm ON
                maxAdminEffDate.related_phys_order_id = adm.related_phys_order_id
                AND maxAdminEffDate.effective_date = adm.effective_date
            GROUP BY adm.related_phys_order_id, adm.effective_date
        )AS maxAdminOrder
        INNER JOIN #adminOrder adm ON
                 maxAdminOrder.related_phys_order_id = adm.related_phys_order_id
                AND maxAdminOrder.effective_date = adm.effective_date
                AND maxAdminOrder.created_date = adm.created_date
        INNER JOIN dbo.pho_order_relationship por ON
                por.order_relationship_id = adm.order_relationship_id
        WHERE
             (ISNULL(adm.ineffective_date,adm.facility_date)>=adm.facility_date OR ISNULL(adm.order_verified, 'Y')='N')
    )AS DATA ON data.related_phys_order_id = ppo.phys_order_id

    LEFT JOIN
    (
                --This query returns and Pending administrative order for a given Phys order.
                --If any order has an associated Pending Confirmation Admin order, the status of that
                -- Order will be Pending Confirmation. Incase there are more then 1 pending confirmation Admin orders
                -- we will take the later of the two (max effective_date, then admin_order_id if there are multiple admin orders with the same effective_date).
                SELECT adm.related_phys_order_id, por.order_relationship_id,por.relationship_code,'Y' AS oneOrderVerified
                 FROM
                    #adminOrder adm
                    INNER JOIN (
                        SELECT MAX(admin_order_id) admin_order_id, ao.related_phys_order_id FROM (
                            SELECT related_phys_order_id, MAX(effective_date) effective_date FROM
                            #adminOrder
                            WHERE order_verified = 'N'
                            GROUP BY related_phys_order_id
                        ) maxDate
                        INNER JOIN #adminOrder ao
                            ON maxDate.related_phys_order_id = ao.related_phys_order_id
                            AND maxDate.effective_date = ao.effective_date
                        GROUP BY ao.related_phys_order_id
                    ) maxId ON maxId.admin_order_id = adm.admin_order_id
                    INNER JOIN dbo.pho_order_relationship por on por.order_relationship_id = adm.order_relationship_id

        )AS unverifiedOrders on unverifiedOrders.related_phys_order_id = ppo.phys_order_id
		
        -- join to the clinical review table
        LEFT JOIN pho_order_clinical_review clinrev ON clinrev.phys_order_id=ppo.phys_order_id AND clinrev.reviewed_date is NULL
        LEFT JOIN pho_phys_order_esignature esign ON esign.phys_order_id=ppo.phys_order_id AND esign.sign_contact_id IS NULL
    LEFT JOIN pho_order_pending_reason posp ON posp.phys_order_id = ppo.phys_order_id 
    LEFT JOIN pho_phys_order_extended_schedule poes ON poes.phys_order_id = ppo.phys_order_id
    WHERE
    ppo.order_category_id <> 1
    AND ppo.order_category_id <> 3030


SET @step = 4
SET @status_text = CONVERT(VARCHAR(26), GETDATE(), 13) + ' Done'
IF @debug='Y' PRINT @status_text  

SET @status_text = null;

END TRY

--error trapping
BEGIN CATCH

    SELECT @error_code = @@error, @status_text = ERROR_MESSAGE()

    SET @status_code = 1

    GOTO PgmAbend

END CATCH

--program success return
PgmSuccess:
IF @status_code = 0
BEGIN
    IF @debug='Y' PRINT 'Successfull execution of stored procedure'
    RETURN @status_code
END

--program failure return
PgmAbend:
IF @debug='Y' PRINT 'Stored procedure failure in step:'+ convert(varchar(3),@step) + '  ' + convert(varchar(26),getdate())
IF @debug='Y' PRINT 'Error code: '+convert(varchar(3),@step) + '; Error description:    ' +@status_text
RETURN @status_code

END
GO

GRANT EXECUTE ON [sproc_sprt_pho_getOrderStatus] TO PUBLIC
GO


GO

print 'A_PreUpload/02 - CORE-95333 -01- DDL - sproc_sprt_pho_getOrderStatus.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/02 - CORE-95333 -01- DDL - sproc_sprt_pho_getOrderStatus.sql',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/02 - CORE-95333 -02- DDL - sproc_sprt_order_list.sql',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')

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


-- =========================================================================================================================
--
--  Script Type: user defined store procedure
--  Target DB Type:  Client
--  Target Database:  Both
--
--  Re-Runable:  Yes
--
--  Description :  Return a list of Physician Orders and other dependent data such as schedules.
--
--	Params:			
--			@facUUIdCSV
--			@clientId
--			@facilityDateTime
--			@orderCategoryIdsCSV
--			@orderStatusCSV
--			@clientStatus
--			@changesetTypesCSV
--			@changesetStatusesCSV
--			@changesetSourceId
--			@physOrderId
--			@pageSize
--			@pageNumber
--			@sortByColumn
--			@sortByOrder
--			@includeOrders
--			@includeSchedules
--			@includeChangesets
--			@debug          - Debug param, 'Y' or 'N'
--			@status_code    - SP execution flag, 0 for success.
--			@status_text    - SP error text if error occurs.
--
-- Change History:
--   Date			Jira				Team		Author				Comment
-- -----------------------------------------------------------------------------------------------------------------------------------
--   09/28/2021     SPRT-740			Coda	    Elias Ghanem  		Created.
-- =========================================================================================================================

IF EXISTS (SELECT *
               FROM
                   dbo.sysobjects
               WHERE
                   id = object_id(N'[dbo].[sproc_sprt_order_list]')
                   AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].[sproc_sprt_order_list]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sproc_sprt_order_list]			@facUUIdCSV               varchar(MAX),-- Required: CSV list of fac uuids to filter on
														@clientId				INT,-- Optional: client Id to filter on
                                                        @facilityDateTime       DATETIME,-- Required: facility date time
                                                        @orderCategoryIdsCSV	VARCHAR(100),-- Required CSV list of categegory ids to filter n
                                                        @orderStatusCSV         VARCHAR(100),-- Required: CSV list of order status ids to filter on
                                                        @clientStatus 			INT,-- Required: flag to filter on client status: -1: ALL, 0: Discharged, 1:Current(not discharged)
														@changesetTypesCSV		VARCHAR(100),-- Optional: changeset types to filter on and return
														@changesetStatusesCSV	VARCHAR(100),-- Optional: changeset statuses to filter on and return
														@changesetSourceId		INT,-- Optional: changeset sourece to filter on
                                                        @physOrderId 			INT,-- Optional: physOrderId to filter on
                                                        @pageSize 				INT,-- Required: number of phys orders per page
                                                        @pageNumber 			INT,-- Required: page number	
                                                        @sortByColumn 			VARCHAR(100),-- Required: column to sort on.
                                                        @sortByOrder  			VARCHAR(10),-- Required sort order
														@includeOrders 			INT,-- Required: flag to indicate whether orders data is returned or not: 1: orders summary, 2:orders details, 0:orders data not to be returned
														@includeSchedules 		INT,-- Required: flag to indicate whether schedules data is returned or not: 1: schedules summary, 2:schedules details, 0:schedules data not to be returned
														@includeChangesets 		INT,-- Required: flag to indicate whether changeset data is returned or not: 1: changeset summary, 2:changeset details, 0:changeset data not to be returned
														@debug              	CHAR(1)  = 'N',-- Required: flag to indicate whether to print debug data or not
														@status_code        	INT  = 0 OUT,
                                                        @status_text        	VARCHAR(3000) OUT



/***********************************************************************************************

Purpose:
This procedure provides data shown on Resident' Order Chart
This procedure does not use VIEW_PHO_PHYS_ORDER

*************************************************************************************************/

AS
BEGIN TRY
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

DECLARE @step                       			int,
		@step_label								varchar(100),
        @error_code                 			int

SET @step = 0
SET @step_label = 'Starting...'
SET @error_code = 0

DECLARE @facIds TABLE
(
	fac_id int  not null
)

DECLARE @orderCategoryIds TABLE
(
	order_category_id INT  NOT NULL
)

DECLARE @orderStatus TABLE
(
	status INT NOT NULL
)

DECLARE @changesetTypes TABLE
(
	changeset_type_id INT NOT NULL
)

DECLARE @changesetStatuses TABLE
(
	status_id INT NOT NULL
)

DECLARE @facInfo TABLE
(
	fac_id INT,
	facility_time datetime,
	IsDischargeEnabled  BIT
)

CREATE TABLE #orders_data
  ( 
	phys_order_id             	INT, 
	fac_id                    	INT, 
	client_id                 	INT, 
	order_verified            	VARCHAR(1),
	order_status				INT,
	active_flag               	CHAR(1), 
	draft                     	BIT, 
	hold_date                 	DATETIME, 
	hold_date_end             	DATETIME, 
	end_date                  	DATETIME, 
	discontinued_date         	DATETIME, 
	order_category_id         	INT, 
	controlled_substance_code 	INT,
	
	physician_id INT,
	pharmacy_id INT,
	route_of_admin INT,
	created_by VARCHAR(60),
	created_date DATETIME,
	revision_by VARCHAR(60),
	revision_date DATETIME,
	start_date DATETIME,
	strength VARCHAR(30),
	form VARCHAR(50),
	description VARCHAR(500),
	directions VARCHAR(1000),
	related_generic VARCHAR(250),
	communication_method INT,
	prescription VARCHAR(50),
	order_date DATETIME,
	completed_date DATETIME,
	origin_id INT,
	drug_strength VARCHAR(100),
	drug_strength_uom VARCHAR(10),
	drug_name VARCHAR(500),
	order_class_id INT,
	resident_last_name varchar(50),
	resident_first_name varchar(50)	 
  ) ;

CREATE TABLE #tempresult 
  ( 
	phys_order_id             INT, 
	fac_id                    INT, 
	client_id                 INT, 
	order_verified            VARCHAR(1), 
	active_flag               CHAR(1), 
	draft                     BIT, 
	hold_date                 DATETIME, 
	hold_date_end             DATETIME, 
	end_date                  DATETIME, 
	discontinued_date         DATETIME, 
	order_category_id         INT, 
	controlled_substance_code INT,
	facility_time datetime,
	IsDischargeEnabled  BIT,
	
	physician_id INT,
	pharmacy_id INT,
	route_of_admin INT,
	created_by VARCHAR(60),
	created_date DATETIME,
	revision_by VARCHAR(60),
	revision_date DATETIME,
	start_date DATETIME,
	strength VARCHAR(30),
	form VARCHAR(50),
	description VARCHAR(500),
	directions VARCHAR(1000),
	related_generic VARCHAR(250),
	communication_method INT,
	prescription VARCHAR(50),
	order_date DATETIME,
	completed_date DATETIME,
	origin_id INT,
	drug_strength VARCHAR(100),
	drug_strength_uom VARCHAR(10),
	drug_name VARCHAR(500),
	order_class_id INT,
	resident_last_name varchar(50),
	resident_first_name varchar(50)
  ) ;
CREATE CLUSTERED INDEX _tempresult_order_id ON #tempresult( phys_order_id );  

CREATE TABLE #vpos
	(
	phys_order_id int NOT NULL,
	fac_id int NOT NULL,
	order_status int NOT NULL,
	order_relationship int NULL,
	status_reason int NULL
	)

SET @step = @step + 1	
SET @step_label = 'Parse CSV parameters into table vairables'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
	
INSERT INTO @facIds (fac_id)
SELECT f.fac_id FROM facility f INNER JOIN dbo.Split(@facUUIdCSV, ',') uuids ON uuids.items = f.fac_uuid


INSERT INTO @orderCategoryIds (order_category_id)
SELECT * FROM dbo.Split(@orderCategoryIdsCSV, ',')	
DELETE FROM @orderCategoryIds where order_category_id=1 or order_category_id=3030

INSERT INTO @orderStatus (status)
SELECT * FROM dbo.Split(@orderStatusCSV, ',');

INSERT INTO @changesetTypes (changeset_type_id)
SELECT * FROM dbo.Split(@changesetTypesCSV, ',');

INSERT INTO @changesetStatuses (status_id)
SELECT * FROM dbo.Split(@changesetStatusesCSV, ',');

	
SET @step = @step + 1	
SET @step_label = 'Check for required parameters...'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
IF NOT EXISTS(SELECT 1 FROM @facIds)
BEGIN
	raiserror ('facUUIdCSV is required. At least one facUUId must be provided.', 16, 1)
END
IF NOT EXISTS(SELECT 1 FROM @orderCategoryIds)
BEGIN
	raiserror ('orderCategoryIdsCSV is required. At least one orderCategoryId must be provided.', 16, 1)
END
IF NOT EXISTS(SELECT 1 FROM @orderStatus)
BEGIN
	raiserror ('orderStatusCSV is required. At least one orderStatus must be provided.', 16, 1)
END	
IF @facilityDateTime IS NULL
BEGIN
	raiserror ('facilityDateTime is required.', 16, 1)
END
IF @clientStatus IS NULL OR @clientStatus NOT IN (-1, 0, 1)
BEGIN
	raiserror ('clientStatus is required. Allowed values are: -1, 0, 1.', 16, 1)
END	
IF @pageSize IS NULL OR @pageSize <= 0
BEGIN
	raiserror ('pageSize is required and should be a positive number.', 16, 1)
END	
IF @pageNumber IS NULL or @pageNumber <= 0
BEGIN
	raiserror ('pageNumber is required and should be a positive number.', 16, 1)
END	
IF @sortByColumn IS NULL
BEGIN
	raiserror ('sortByColumn is required.', 16, 1)
END	
IF @sortByOrder IS NULL
BEGIN
	raiserror ('sortByOrder is required.', 16, 1)
END
IF (( EXISTS(SELECT 1 FROM @changesetTypes) OR EXISTS(SELECT 1 FROM @changesetStatuses)) AND
	(NOT EXISTS(SELECT 1 FROM @changesetTypes) OR NOT EXISTS(SELECT 1 FROM @changesetStatuses)))
BEGIN
	raiserror ('changesetTypesCSV and changesetStatusesCSV should be both set or both empty', 16, 1)
END
IF @changesetSourceId IS NOT NULL AND (NOT EXISTS(SELECT 1 FROM @changesetTypes) OR NOT EXISTS(SELECT 1 FROM @changesetStatuses))
BEGIN
	raiserror ('If changesetSourceId is set, both changesetTypesCSV and changesetStatusesCSV should be set', 16, 1)
END
IF @includeOrders IS NULL OR @includeOrders NOT IN (0, 1, 2)
BEGIN
	raiserror ('includeOrders is required. Allowed values are: 0, 1, 2', 16, 1)
END	
IF @includeSchedules IS NULL OR @includeSchedules NOT IN (0, 1, 2)
BEGIN
	raiserror ('includeSchedules is required. Allowed values are: 0, 1, 2', 16, 1)
END
IF @includeChangesets IS NULL OR @includeSchedules NOT IN (0, 1, 2)
BEGIN
	raiserror ('includeChangesets is required. Allowed values are: 0, 1, 2', 16, 1)
END
IF @includeChangesets IN (1, 2) AND (NOT EXISTS(SELECT 1 FROM @changesetTypes) OR NOT EXISTS(SELECT 1 FROM @changesetStatuses))
BEGIN
	raiserror ('If includeChangesets value is 1 or 2, both changesetTypesCSV and changesetStatusesCSV should be set', 16, 1)
END
		
SET @step = @step + 1
SET @step_label = 'Prepare facility info'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
INSERT INTO @facInfo	
	(fac_id,
	facility_time,
	IsDischargeEnabled
	)
	SELECT f.fac_id, 
	dbo.fn_facility_getCurrentTime(f.fac_id),
	CASE WHEN cp.value = 'Y' THEN 1 ELSE 0 END
	FROM @facIds f	
	LEFT JOIN configuration_parameter cp ON cp.fac_id = f.fac_id AND cp.name='discharge_order_enable'
	
	
SET @step = @step + 1
SET @step_label = 'Insert into #tempresult'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text

INSERT INTO #tempresult
	( 
	phys_order_id, 
	fac_id, 
	client_id, 
	order_verified, 
	active_flag, 
	draft, 
	hold_date, 
	hold_date_end, 
	end_date, 
	discontinued_date, 
	order_category_id, 
	controlled_substance_code,
	facility_time,
	IsDischargeEnabled,
	
	physician_id,
	pharmacy_id,
	route_of_admin,
	created_by,
	created_date,
	revision_by,
	revision_date,
	start_date,
	strength,
	form,
	description,
	directions,
	related_generic,
	communication_method,
	prescription,
	order_date,
	completed_date,
	origin_id,
	drug_strength,
	drug_strength_uom,
	drug_name,
	order_class_id,
	resident_last_name,
	resident_first_name
	)
	SELECT
		o.phys_order_id, 
		o.fac_id, 
		o.client_id, 
		o.order_verified, 
		o.active_flag, 
		o.draft, 
		o.hold_date, 
		o.hold_date_end, 
		o.end_date, 
		o.discontinued_date, 
		o.order_category_id, 
		o.controlled_substance_code,
		fi.facility_time,
		fi.IsDischargeEnabled,
		o.physician_id,
		o.pharmacy_id,
		o.route_of_admin,
		o.created_by,
		o.created_date,
		o.revision_by,
		o.revision_date,
		o.start_date,
		o.strength,
		o.form,
		o.description,
		o.directions,
		o.related_generic,
		o.communication_method,
		o.prescription,
		o.order_date,
		o.completed_date,
		o.origin_id,
		o.drug_strength,
		o.drug_strength_uom,
		o.drug_name,
		o.order_class_id,
		m.last_name,
		m.first_name
	FROM pho_phys_order o
	INNER JOIN @facIds f ON f.fac_id = o.fac_id
	INNER JOIN @facInfo fi ON fi.fac_id = f.fac_id
	INNER JOIN @orderCategoryIds cat ON cat.order_category_id = o.order_category_id
	INNER JOIN clients c ON c.client_id = o.client_id
	INNER JOIN mpi m ON m.mpi_id = c.mpi_id
	WHERE (@physOrderId IS NULL OR o.phys_order_id = @physOrderId) AND ISNULL(o.active_flag, 'Y') = 'Y'
	AND (@clientId IS NULL OR o.client_id = @clientId)
	AND (@clientStatus = -1 OR (@clientStatus = 1 AND (c.discharge_date IS NULL OR c.discharge_date > @facilityDateTime)) OR (@clientStatus = 0 AND c.discharge_date <= @facilityDateTime))

SET @step = @step + 1	
SET @step_label = 'Applying changeset filtering if needed'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text

IF EXISTS(SELECT 1 FROM @changesetTypes) OR EXISTS (SELECT 1 FROM @changesetStatuses) OR @changesetSourceId IS NOT NULL
	BEGIN
	MERGE #tempresult AS TARGET
	USING (select o.phys_order_id
	FROM #tempresult o	
	INNER JOIN pho_phys_order_changeset cs ON cs.phys_order_id = o.phys_order_id
	INNER JOIN @changesetTypes cst ON cst.changeset_type_id = cs.changeset_type_id
	INNER JOIN changeset_status csstat ON csstat.changeset_status_id = cs.current_status_id
	INNER JOIN @changesetStatuses csstats ON csstats.status_id = csstat.status_id
	WHERE @changesetSourceId IS NULL OR cs.changeset_source_id = @changesetSourceId
	) AS SOURCE
	ON (TARGET.phys_order_id = SOURCE.phys_order_id) 
	WHEN NOT MATCHED BY SOURCE 
	THEN DELETE; 
END

SET @step = @step + 1	
SET @step_label = 'Calculating orders statuses'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
insert into #vpos
exec sproc_sprt_pho_getOrderStatus  @debug,@status_code out,@status_text out


SET @step = @step + 1	
SET @step_label = 'Insert into #orders_data'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
INSERT INTO #orders_data
	( 
	phys_order_id, 
	fac_id, 
	client_id, 
	order_verified,
	order_status,
	active_flag, 
	draft, 
	hold_date, 
	hold_date_end, 
	end_date, 
	discontinued_date, 
	order_category_id, 
	controlled_substance_code,
	physician_id,
	pharmacy_id,
	route_of_admin,
	created_by,
	created_date,
	revision_by,
	revision_date,
	start_date,
	strength,
	form,
	description,
	directions,
	related_generic,
	communication_method,
	prescription,
	order_date,
	completed_date,
	origin_id,
	drug_strength,
	drug_strength_uom,
	drug_name,
	order_class_id,
	resident_last_name,
	resident_first_name
	)
	SELECT
		temp.phys_order_id, 
		temp.fac_id, 
		temp.client_id, 
		temp.order_verified,
		vpos.order_status,
		temp.active_flag, 
		temp.draft, 
		temp.hold_date, 
		temp.hold_date_end, 
		temp.end_date, 
		temp.discontinued_date, 
		temp.order_category_id, 
		temp.controlled_substance_code,
		temp.physician_id,
		temp.pharmacy_id,
		temp.route_of_admin,
		temp.created_by,
		temp.created_date,
		temp.revision_by,
		temp.revision_date,
		temp.start_date,
		temp.strength,
		temp.form,
		temp.description,
		temp.directions,
		temp.related_generic,
		temp.communication_method,
		temp.prescription,
		temp.order_date,
		temp.completed_date,
		temp.origin_id,
		temp.drug_strength,
		temp.drug_strength_uom,
		temp.drug_name,
		temp.order_class_id,
		temp.resident_last_name,
		temp.resident_first_name
	FROM @orderStatus stat
	INNER JOIN #vpos vpos ON vpos.order_status = stat.status
	INNER JOIN #tempresult temp ON temp.phys_order_id = vpos.phys_order_id	


SET @step = @step + 1
SET @step_label = 'Apply pagination'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
IF @sortByOrder='desc'
BEGIN
	;WITH TMP AS
	(
		SELECT ROW_NUMBER() OVER(ORDER BY
									 CASE
										WHEN @sortByColumn = 'fac_id' THEN CONVERT(VARCHAR(50), o.fac_id)
										WHEN @sortByColumn = 'description' THEN o.description
										WHEN @sortByColumn = 'client_id' THEN CONVERT(VARCHAR(50), o.resident_first_name)
										ELSE CONVERT(VARCHAR(50), o.phys_order_id)
									END
									DESC,
									CASE
										WHEN @sortByColumn = 'client_id' THEN CONVERT(VARCHAR(50), o.resident_last_name)
										ELSE CONVERT(VARCHAR(50), o.phys_order_id)
									END
									DESC,
									o.phys_order_id DESC) AS rn FROM #orders_data o
	)
	DELETE FROM TMP WHERE @pageSize > 0 AND (rn <= (@pageSize * (@pageNumber-1)) OR rn > (@pageSize * @pageNumber))
END
ELSE
BEGIN
	;WITH TMP AS
	(
		SELECT ROW_NUMBER() OVER(ORDER BY
										CASE
										WHEN @sortByColumn = 'fac_id' THEN CONVERT(varchar(50), o.fac_id)
										WHEN @sortByColumn = 'description' THEN o.description										
										WHEN @sortByColumn = 'client_id' THEN CONVERT(VARCHAR(50), o.resident_first_name)
										ELSE CONVERT(VARCHAR(50), o.phys_order_id)
									END
									ASC,
									CASE
										WHEN @sortByColumn = 'client_id' THEN CONVERT(VARCHAR(50), o.resident_last_name)
										ELSE CONVERT(VARCHAR(50), o.phys_order_id)
									END
									ASC,
									o.phys_order_id DESC) AS rn FROM #orders_data o
	)
	DELETE FROM TMP WHERE @pageSize > 0 AND (rn <= (@pageSize * (@pageNumber-1)) OR rn > (@pageSize * @pageNumber))

END


    /****************************************
    return final result
    ****************************************/
SET @step = @step + 1	
SET @step_label = 'Return final results...'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text

SET @step = @step + 1	
SET @step_label = 'Return orders'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
IF @includeOrders = 1
BEGIN
	SELECT
	o.phys_order_id,
	o.fac_id,
	o.client_id,
	o.order_status,
	o.description,
	o.resident_first_name,
	o.resident_last_name	
	FROM #orders_data o
	ORDER BY o.fac_id, o.phys_order_id ASC
END
ELSE
BEGIN
	IF @includeOrders = 2
	BEGIN
		SELECT
		o.phys_order_id,
		o.fac_id,
		o.client_id,
		o.physician_id,
		o.order_category_id,
		o.communication_method,
		o.route_of_admin,
		o.order_status,
		o.description,
		o.resident_first_name,
		o.resident_last_name,
		o.created_by,
		o.created_date,
		o.revision_by,
		o.revision_date
		FROM #orders_data o
		ORDER BY o.fac_id, o.phys_order_id ASC
	END
	ELSE
		SELECT 'ORDER DATA NOT REQUESTED'
END

SET @step = @step + 1	
SET @step_label = 'Return schedules'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
IF @includeSchedules = 1
BEGIN
	SELECT
	o.phys_order_id,
	s.order_schedule_id,
	s.schedule_directions
	FROM #orders_data o
	INNER JOIN PHO_ORDER_SCHEDULE s ON s.phys_order_id = o.phys_order_id
	WHERE s.deleted = 'N'
	ORDER BY o.fac_id, o.phys_order_id, s.order_schedule_id
END
ELSE
BEGIN
	IF @includeSchedules = 2	
	BEGIN	
		SELECT
		os.phys_order_id,
		os.order_schedule_id,
		os.schedule_template,
		os.dose_value,
		os.dose_uom_id,
		os.alternate_dose_value,
		os.dose_low,
		os.quantity_per_dose,
		os.quantity_uom_id,
		os.need_location_of_admin,
		os.sliding_scale_id,
		os.apply_to,
		os.apply_remove_flag,
		os.std_freq_id,
		os.schedule_type,
		os.repeat_week,
		os.mon,
		os.tues,
		os.wed,
		os.thurs,
		os.fri,
		os.sat,
		os.sun,
		os.xxdays,
		os.xxmonths,
		os.xxhours,
		os.date_of_month,
		os.date_start,
		os.date_stop,
		os.days_on,
		os.days_off,
		os.pho_std_time_id,
		os.related_diagnosis,
		os.indications_for_use,
		os.additional_directions,
		os.administered_by_id,
		os.schedule_start_date,
		os.schedule_end_date,
		os.schedule_end_date_type_id,
		os.schedule_duration,
		os.schedule_duration_type_id,
		os.schedule_dose_duration,
		os.prn_admin,
		os.prn_admin_value,
		os.prn_admin_units,
		os.schedule_directions,
		os.created_by,
		os.created_date,
		os.revision_by,
		os.revision_date,		
		--os.std_freq_time_label,
		--os.until_finished,
		--os.order_type_id,
		--os.extended_end_date,
		--os.extended_count,
		--os.prescriber_schedule_start_date,		
		ps.order_schedule_id,
		ps.schedule_id,
		ps.start_time,
		ps.end_time,
		ps.std_shift_id,
		ps.remove_time,
		ps.remove_duration,
		ps.nurse_action_notes
		FROM #orders_data o
		INNER JOIN PHO_ORDER_SCHEDULE os ON os.phys_order_id = o.phys_order_id
		INNER JOIN PHO_SCHEDULE ps ON ps.order_schedule_id = os.order_schedule_id
		WHERE os.deleted = 'N' and ps.deleted = 'N'
		ORDER BY o.fac_id, o.phys_order_id, os.order_schedule_id		
	END
	ELSE
		SELECT 'SCHEDULES DATA NOT REQUESTED'
END

SET @step = @step + 1	
SET @step_label = 'Return changeset'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
IF @includeChangesets = 1
BEGIN
	SELECT
	o.phys_order_id,
	cs.phys_order_changeset_id,
	cs.changeset_type_id,
	cs.current_status_id,
	cs.changeset_source_id
	FROM #orders_data o
	INNER JOIN pho_phys_order_changeset cs ON cs.phys_order_id = o.phys_order_id
	INNER JOIN @changesetTypes cst ON cst.changeset_type_id = cs.changeset_type_id
	INNER JOIN changeset_status csstat ON csstat.changeset_status_id = cs.current_status_id
	INNER JOIN @changesetStatuses csstats ON csstats.status_id = csstat.status_id
	WHERE @changesetSourceId IS NULL OR cs.changeset_source_id = @changesetSourceId	
END
ELSE
BEGIN
	IF @includeChangesets = 2
	BEGIN
		SELECT
		o.phys_order_id,
		cs.phys_order_changeset_id,
		cs.changeset_type_id,
		cs.current_status_id,
		cs.changeset_source_id,
		cs.changeset_data,
		cs.resulting_phys_order_id,
		cs.aggregate_changeset_id,
		csstat.status_source,
		csstat.status_by,
		csstat.status_date
		FROM #orders_data o
		INNER JOIN pho_phys_order_changeset cs ON cs.phys_order_id = o.phys_order_id
		INNER JOIN @changesetTypes cst ON cst.changeset_type_id = cs.changeset_type_id
		INNER JOIN changeset_status csstat ON csstat.changeset_status_id = cs.current_status_id
		INNER JOIN @changesetStatuses csstats ON csstats.status_id = csstat.status_id
		WHERE @changesetSourceId IS NULL OR cs.changeset_source_id = @changesetSourceId	
	END
	ELSE
		SELECT 'CHANGESET DATA NOT REQUESTED'
END

    SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' Done'
    IF @debug='Y'
        PRINT @status_text
    SET @status_code = 0
    GOTO PgmSuccess
END TRY
--error trapping
BEGIN CATCH
    --SELECT @error_code = @@error, @status_text = 'Error at step:'+convert(varchar(3),@step)+', '+ERROR_MESSAGE()
	SELECT @error_code = @@error, @status_text = 'Error at step:' + convert(varchar(3),@step) + ' <' + @step_label + '>, '+ERROR_MESSAGE()

    SET @status_code = 1

    GOTO PgmAbend

END CATCH

--program success return
PgmSuccess:

IF @status_code = 0
BEGIN
    IF @debug='Y' PRINT 'Successfull execution of stored procedure'
    RETURN @status_code
END

--program failure return
PgmAbend:

--IF @debug='Y' PRINT 'Stored procedure failure in step:'+ convert(varchar(3),@step) + '   ' + convert(varchar(26),getdate())
IF @debug='Y' PRINT 'Stored procedure failure in step:'+ convert(varchar(3),@step) + ' <' + @step_label + '>   ' + convert(varchar(26),getdate())
    IF @debug='Y' PRINT 'Error code: '+convert(varchar(3),@error_code) + '; Error description:    ' +@status_text
    RETURN @status_code

GO
GRANT EXECUTE ON sproc_sprt_order_list TO public
GO


GO

print 'A_PreUpload/02 - CORE-95333 -02- DDL - sproc_sprt_order_list.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/02 - CORE-95333 -02- DDL - sproc_sprt_order_list.sql',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/03 - CORE-95333 -02- DDL - sproc_sprt_order_list_temp2.sql',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')

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


-- =========================================================================================================================
--
--  Script Type: user defined store procedure
--  Target DB Type:  Client
--  Target Database:  Both
--
--  Re-Runable:  Yes
--
--  Description :  Return a list of Physician Orders and other dependent data such as schedules.
--
--	Params:			
--			@facIdCSV
--			@clientId
--			@facilityDateTime
--			@orderCategoryIdsCSV
--			@orderStatusCSV
--			@clientStatus
--			@changesetTypesCSV
--			@changesetStatusesCSV
--			@changesetSourceId
--			@physOrderId
--			@pageSize
--			@pageNumber
--			@sortByColumn
--			@sortByOrder
--			@includeOrders
--			@includeSchedules
--			@includeChangesets
--			@debug          - Debug param, 'Y' or 'N'
--			@status_code    - SP execution flag, 0 for success.
--			@status_text    - SP error text if error occurs.
--
-- Change History:
--   Date			Jira				Team		Author				Comment
-- -----------------------------------------------------------------------------------------------------------------------------------
--   09/28/2021     SPRT-740			Coda	    Elias Ghanem  		Created.
-- =========================================================================================================================

IF EXISTS (SELECT *
               FROM
                   dbo.sysobjects
               WHERE
                   id = object_id(N'[dbo].[sproc_sprt_order_list_temp2]')
                   AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].[sproc_sprt_order_list_temp2]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sproc_sprt_order_list_temp2]			@facIdCSV               varchar(1000),-- Required: CSV list of fac ids to filter on
														@clientId				INT,-- Optional: client Id to filter on
                                                        @facilityDateTime       DATETIME,-- Required: facility date time
                                                        @orderCategoryIdsCSV	VARCHAR(100),-- Required CSV list of categegory ids to filter n
                                                        @orderStatusCSV         VARCHAR(100),-- Required: CSV list of order status ids to filter on
                                                        @clientStatus 			INT,-- Required: flag to filter on client status: -1: ALL, 0: Discharged, 1:Current(not discharged)
														@changesetTypesCSV		VARCHAR(100),-- Optional: changeset types to filter on and return
														@changesetStatusesCSV	VARCHAR(100),-- Optional: changeset statuses to filter on and return
														@changesetSourceId		INT,-- Optional: changeset sourece to filter on
                                                        @physOrderId 			INT,-- Optional: physOrderId to filter on
                                                        @pageSize 				INT,-- Required: number of phys orders per page
                                                        @pageNumber 			INT,-- Required: page number	
                                                        @sortByColumn 			VARCHAR(100),-- Required: column to sort on.
                                                        @sortByOrder  			VARCHAR(10),-- Required sort order
														@includeOrders 			INT,-- Required: flag to indicate whether orders data is returned or not: 1: orders summary, 2:orders details, 0:orders data not to be returned
														@includeSchedules 		INT,-- Required: flag to indicate whether schedules data is returned or not: 1: schedules summary, 2:schedules details, 0:schedules data not to be returned
														@includeChangesets 		INT,-- Required: flag to indicate whether changeset data is returned or not: 1: changeset summary, 2:changeset details, 0:changeset data not to be returned
														@debug              	CHAR(1)  = 'N',-- Required: flag to indicate whether to print debug data or not
														@status_code        	INT  = 0 OUT,
                                                        @status_text        	VARCHAR(3000) OUT



/***********************************************************************************************

Purpose:
This procedure provides data shown on Resident' Order Chart
This procedure does not use VIEW_PHO_PHYS_ORDER

*************************************************************************************************/

AS
BEGIN TRY
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

DECLARE @step                       			int,
		@step_label								varchar(100),
        @error_code                 			int

SET @step = 0
SET @step_label = 'Starting...'
SET @error_code = 0

DECLARE @facIds TABLE
(
	fac_id int  not null
)

DECLARE @orderCategoryIds TABLE
(
	order_category_id INT  NOT NULL
)

DECLARE @orderStatus TABLE
(
	status INT NOT NULL
)

DECLARE @changesetTypes TABLE
(
	changeset_type_id INT NOT NULL
)

DECLARE @changesetStatuses TABLE
(
	status_id INT NOT NULL
)

DECLARE @facInfo TABLE
(
	fac_id INT,
	facility_time datetime,
	IsDischargeEnabled  BIT
)

CREATE TABLE #orders_data
  ( 
	phys_order_id             	INT, 
	fac_id                    	INT, 
	client_id                 	INT, 
	order_verified            	VARCHAR(1),
	order_status				INT,
	active_flag               	CHAR(1), 
	draft                     	BIT, 
	hold_date                 	DATETIME, 
	hold_date_end             	DATETIME, 
	end_date                  	DATETIME, 
	discontinued_date         	DATETIME, 
	order_category_id         	INT, 
	controlled_substance_code 	INT,
	
	physician_id INT,
	pharmacy_id INT,
	route_of_admin INT,
	created_by VARCHAR(60),
	created_date DATETIME,
	revision_by VARCHAR(60),
	revision_date DATETIME,
	start_date DATETIME,
	strength VARCHAR(30),
	form VARCHAR(50),
	description VARCHAR(500),
	directions VARCHAR(1000),
	related_generic VARCHAR(250),
	communication_method INT,
	prescription VARCHAR(50),
	order_date DATETIME,
	completed_date DATETIME,
	origin_id INT,
	drug_strength VARCHAR(100),
	drug_strength_uom VARCHAR(10),
	drug_name VARCHAR(500),
	order_class_id INT,
	resident_last_name varchar(50),
	resident_first_name varchar(50)	 
  ) ;

CREATE TABLE #tempresult 
  ( 
	phys_order_id             INT, 
	fac_id                    INT, 
	client_id                 INT, 
	order_verified            VARCHAR(1), 
	active_flag               CHAR(1), 
	draft                     BIT, 
	hold_date                 DATETIME, 
	hold_date_end             DATETIME, 
	end_date                  DATETIME, 
	discontinued_date         DATETIME, 
	order_category_id         INT, 
	controlled_substance_code INT,
	facility_time datetime,
	IsDischargeEnabled  BIT,
	
	physician_id INT,
	pharmacy_id INT,
	route_of_admin INT,
	created_by VARCHAR(60),
	created_date DATETIME,
	revision_by VARCHAR(60),
	revision_date DATETIME,
	start_date DATETIME,
	strength VARCHAR(30),
	form VARCHAR(50),
	description VARCHAR(500),
	directions VARCHAR(1000),
	related_generic VARCHAR(250),
	communication_method INT,
	prescription VARCHAR(50),
	order_date DATETIME,
	completed_date DATETIME,
	origin_id INT,
	drug_strength VARCHAR(100),
	drug_strength_uom VARCHAR(10),
	drug_name VARCHAR(500),
	order_class_id INT,
	resident_last_name varchar(50),
	resident_first_name varchar(50)
  ) ;
CREATE CLUSTERED INDEX _tempresult_order_id ON #tempresult( phys_order_id );  

CREATE TABLE #vpos
	(
	phys_order_id int NOT NULL,
	fac_id int NOT NULL,
	order_status int NOT NULL,
	order_relationship int NULL,
	status_reason int NULL
	)

SET @step = @step + 1	
SET @step_label = 'Parse CSV parameters into table vairables'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
	
INSERT INTO @facIds (fac_id)
SELECT * FROM dbo.Split(@facIdCSV, ',')

INSERT INTO @orderCategoryIds (order_category_id)
SELECT * FROM dbo.Split(@orderCategoryIdsCSV, ',')	
DELETE FROM @orderCategoryIds where order_category_id=1 or order_category_id=3030

INSERT INTO @orderStatus (status)
SELECT * FROM dbo.Split(@orderStatusCSV, ',');

INSERT INTO @changesetTypes (changeset_type_id)
SELECT * FROM dbo.Split(@changesetTypesCSV, ',');

INSERT INTO @changesetStatuses (status_id)
SELECT * FROM dbo.Split(@changesetStatusesCSV, ',');

	
SET @step = @step + 1	
SET @step_label = 'Check for required parameters...'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
IF NOT EXISTS(SELECT 1 FROM @facIds)
BEGIN
	raiserror ('facIdCSV is required. At least one facId must be provided.', 16, 1)
END
IF NOT EXISTS(SELECT 1 FROM @orderCategoryIds)
BEGIN
	raiserror ('orderCategoryIdsCSV is required. At least one orderCategoryId must be provided.', 16, 1)
END
IF NOT EXISTS(SELECT 1 FROM @orderStatus)
BEGIN
	raiserror ('orderStatusCSV is required. At least one orderStatus must be provided.', 16, 1)
END	
IF @facilityDateTime IS NULL
BEGIN
	raiserror ('facilityDateTime is required.', 16, 1)
END
IF @clientStatus IS NULL OR @clientStatus NOT IN (-1, 0, 1)
BEGIN
	raiserror ('clientStatus is required. Allowed values are: -1, 0, 1.', 16, 1)
END	
IF @pageSize IS NULL OR @pageSize <= 0
BEGIN
	raiserror ('pageSize is required and should be a positive number.', 16, 1)
END	
IF @pageNumber IS NULL or @pageNumber <= 0
BEGIN
	raiserror ('pageNumber is required and should be a positive number.', 16, 1)
END	
IF @sortByColumn IS NULL
BEGIN
	raiserror ('sortByColumn is required.', 16, 1)
END	
IF @sortByOrder IS NULL
BEGIN
	raiserror ('sortByOrder is required.', 16, 1)
END
IF (( EXISTS(SELECT 1 FROM @changesetTypes) OR EXISTS(SELECT 1 FROM @changesetStatuses)) AND
	(NOT EXISTS(SELECT 1 FROM @changesetTypes) OR NOT EXISTS(SELECT 1 FROM @changesetStatuses)))
BEGIN
	raiserror ('changesetTypesCSV and changesetStatusesCSV should be both set or both empty', 16, 1)
END
IF @changesetSourceId IS NOT NULL AND (NOT EXISTS(SELECT 1 FROM @changesetTypes) OR NOT EXISTS(SELECT 1 FROM @changesetStatuses))
BEGIN
	raiserror ('If changesetSourceId is set, both changesetTypesCSV and changesetStatusesCSV should be set', 16, 1)
END
IF @includeOrders IS NULL OR @includeOrders NOT IN (0, 1, 2)
BEGIN
	raiserror ('includeOrders is required. Allowed values are: 0, 1, 2', 16, 1)
END	
IF @includeSchedules IS NULL OR @includeSchedules NOT IN (0, 1, 2)
BEGIN
	raiserror ('includeSchedules is required. Allowed values are: 0, 1, 2', 16, 1)
END
IF @includeChangesets IS NULL OR @includeSchedules NOT IN (0, 1, 2)
BEGIN
	raiserror ('includeChangesets is required. Allowed values are: 0, 1, 2', 16, 1)
END
IF @includeChangesets IN (1, 2) AND (NOT EXISTS(SELECT 1 FROM @changesetTypes) OR NOT EXISTS(SELECT 1 FROM @changesetStatuses))
BEGIN
	raiserror ('If includeChangesets value is 1 or 2, both changesetTypesCSV and changesetStatusesCSV should be set', 16, 1)
END
		
SET @step = @step + 1
SET @step_label = 'Prepare facility info'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
INSERT INTO @facInfo	
	(fac_id,
	facility_time,
	IsDischargeEnabled
	)
	SELECT f.fac_id, 
	dbo.fn_facility_getCurrentTime(f.fac_id),
	CASE WHEN cp.value = 'Y' THEN 1 ELSE 0 END
	FROM @facIds f	
	LEFT JOIN configuration_parameter cp ON cp.fac_id = f.fac_id AND cp.name='discharge_order_enable'
	
	
SET @step = @step + 1
SET @step_label = 'Insert into #tempresult'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text

IF NOT EXISTS(SELECT 1 FROM @changesetTypes) AND NOT EXISTS (SELECT 1 FROM @changesetStatuses) AND @changesetSourceId IS NULL
BEGIN
	INSERT INTO #tempresult
		( 
		phys_order_id, 
		fac_id, 
		client_id, 
		order_verified, 
		active_flag, 
		draft, 
		hold_date, 
		hold_date_end, 
		end_date, 
		discontinued_date, 
		order_category_id, 
		controlled_substance_code,
		facility_time,
		IsDischargeEnabled,
		
		physician_id,
		pharmacy_id,
		route_of_admin,
		created_by,
		created_date,
		revision_by,
		revision_date,
		start_date,
		strength,
		form,
		description,
		directions,
		related_generic,
		communication_method,
		prescription,
		order_date,
		completed_date,
		origin_id,
		drug_strength,
		drug_strength_uom,
		drug_name,
		order_class_id,
		resident_last_name,
		resident_first_name
		)
		SELECT
			o.phys_order_id, 
			o.fac_id, 
			o.client_id, 
			o.order_verified, 
			o.active_flag, 
			o.draft, 
			o.hold_date, 
			o.hold_date_end, 
			o.end_date, 
			o.discontinued_date, 
			o.order_category_id, 
			o.controlled_substance_code,
			fi.facility_time,
			fi.IsDischargeEnabled,
			o.physician_id,
			o.pharmacy_id,
			o.route_of_admin,
			o.created_by,
			o.created_date,
			o.revision_by,
			o.revision_date,
			o.start_date,
			o.strength,
			o.form,
			o.description,
			o.directions,
			o.related_generic,
			o.communication_method,
			o.prescription,
			o.order_date,
			o.completed_date,
			o.origin_id,
			o.drug_strength,
			o.drug_strength_uom,
			o.drug_name,
			o.order_class_id,
			m.last_name,
			m.first_name
		FROM pho_phys_order o
		INNER JOIN @facIds f ON f.fac_id = o.fac_id
		INNER JOIN @facInfo fi ON fi.fac_id = f.fac_id
		INNER JOIN @orderCategoryIds cat ON cat.order_category_id = o.order_category_id
		INNER JOIN clients c ON c.client_id = o.client_id
		INNER JOIN mpi m ON m.mpi_id = c.mpi_id
		WHERE (@physOrderId IS NULL OR o.phys_order_id = @physOrderId) AND ISNULL(o.active_flag, 'Y') = 'Y'
		AND (@clientId IS NULL OR o.client_id = @clientId)
		AND (@clientStatus = -1 OR (@clientStatus = 1 AND (c.discharge_date IS NULL OR c.discharge_date > @facilityDateTime)) OR (@clientStatus = 0 AND c.discharge_date <= @facilityDateTime))
		
		ORDER BY
		 CASE
			WHEN @sortByColumn = 'fac_id' THEN CONVERT(VARCHAR(50), o.fac_id)
			WHEN @sortByColumn = 'description' THEN o.description
			WHEN @sortByColumn = 'client_id' THEN CONVERT(VARCHAR(50), m.first_name)
			ELSE CONVERT(VARCHAR(50), o.phys_order_id)
		END
		ASC,
		CASE
			WHEN @sortByColumn = 'client_id' THEN CONVERT(VARCHAR(50), m.last_name)
			ELSE CONVERT(VARCHAR(50), o.phys_order_id)
		END
		ASC,
		o.phys_order_id ASC
		OFFSET @pageSize * (@pageNumber - 1) ROWS
		FETCH NEXT @pageSize ROWS ONLY
		
END
ELSE
BEGIN
	INSERT INTO #tempresult
		( 
		phys_order_id, 
		fac_id, 
		client_id, 
		order_verified, 
		active_flag, 
		draft, 
		hold_date, 
		hold_date_end, 
		end_date, 
		discontinued_date, 
		order_category_id, 
		controlled_substance_code,
		facility_time,
		IsDischargeEnabled,
		
		physician_id,
		pharmacy_id,
		route_of_admin,
		created_by,
		created_date,
		revision_by,
		revision_date,
		start_date,
		strength,
		form,
		description,
		directions,
		related_generic,
		communication_method,
		prescription,
		order_date,
		completed_date,
		origin_id,
		drug_strength,
		drug_strength_uom,
		drug_name,
		order_class_id,
		resident_last_name,
		resident_first_name
		)
		SELECT
			o.phys_order_id, 
			o.fac_id, 
			o.client_id, 
			o.order_verified, 
			o.active_flag, 
			o.draft, 
			o.hold_date, 
			o.hold_date_end, 
			o.end_date, 
			o.discontinued_date, 
			o.order_category_id, 
			o.controlled_substance_code,
			fi.facility_time,
			fi.IsDischargeEnabled,
			o.physician_id,
			o.pharmacy_id,
			o.route_of_admin,
			o.created_by,
			o.created_date,
			o.revision_by,
			o.revision_date,
			o.start_date,
			o.strength,
			o.form,
			o.description,
			o.directions,
			o.related_generic,
			o.communication_method,
			o.prescription,
			o.order_date,
			o.completed_date,
			o.origin_id,
			o.drug_strength,
			o.drug_strength_uom,
			o.drug_name,
			o.order_class_id,
			m.last_name,
			m.first_name
		FROM pho_phys_order o
		INNER JOIN @facIds f ON f.fac_id = o.fac_id
		INNER JOIN @facInfo fi ON fi.fac_id = f.fac_id
		INNER JOIN @orderCategoryIds cat ON cat.order_category_id = o.order_category_id
		INNER JOIN clients c ON c.client_id = o.client_id
		INNER JOIN mpi m ON m.mpi_id = c.mpi_id
		
		INNER JOIN pho_phys_order_changeset cs ON cs.phys_order_id = o.phys_order_id
		INNER JOIN @changesetTypes cst ON cst.changeset_type_id = cs.changeset_type_id
		INNER JOIN changeset_status csstat ON csstat.changeset_status_id = cs.current_status_id
		INNER JOIN @changesetStatuses csstats ON csstats.status_id = csstat.status_id
		
		WHERE (@physOrderId IS NULL OR o.phys_order_id = @physOrderId) AND ISNULL(o.active_flag, 'Y') = 'Y'
		AND (@clientId IS NULL OR o.client_id = @clientId)
		AND (@clientStatus = -1 OR (@clientStatus = 1 AND (c.discharge_date IS NULL OR c.discharge_date > @facilityDateTime)) OR (@clientStatus = 0 AND c.discharge_date <= @facilityDateTime))
		AND @changesetSourceId IS NULL OR cs.changeset_source_id = @changesetSourceId
		
		GROUP BY
		o.phys_order_id, 
		o.fac_id, 
		o.client_id, 
		o.order_verified, 
		o.active_flag, 
		o.draft, 
		o.hold_date, 
		o.hold_date_end, 
		o.end_date, 
		o.discontinued_date, 
		o.order_category_id, 
		o.controlled_substance_code,
		fi.facility_time,
		fi.IsDischargeEnabled,
		o.physician_id,
		o.pharmacy_id,
		o.route_of_admin,
		o.created_by,
		o.created_date,
		o.revision_by,
		o.revision_date,
		o.start_date,
		o.strength,
		o.form,
		o.description,
		o.directions,
		o.related_generic,
		o.communication_method,
		o.prescription,
		o.order_date,
		o.completed_date,
		o.origin_id,
		o.drug_strength,
		o.drug_strength_uom,
		o.drug_name,
		o.order_class_id,
		m.last_name,
		m.first_name
		
		ORDER BY
		 CASE
			WHEN @sortByColumn = 'fac_id' THEN CONVERT(VARCHAR(50), o.fac_id)
			WHEN @sortByColumn = 'description' THEN o.description
			WHEN @sortByColumn = 'client_id' THEN CONVERT(VARCHAR(50), m.first_name)
			ELSE CONVERT(VARCHAR(50), o.phys_order_id)
		END
		ASC,
		CASE
			WHEN @sortByColumn = 'client_id' THEN CONVERT(VARCHAR(50), m.last_name)
			ELSE CONVERT(VARCHAR(50), o.phys_order_id)
		END
		ASC,
		o.phys_order_id ASC
		OFFSET @pageSize * (@pageNumber - 1) ROWS
		FETCH NEXT @pageSize ROWS ONLY
END

/*
SET @step = @step + 1	
SET @step_label = 'Applying changeset filtering if needed'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text

IF EXISTS(SELECT 1 FROM @changesetTypes) OR EXISTS (SELECT 1 FROM @changesetStatuses) OR @changesetSourceId IS NOT NULL
	BEGIN
	MERGE #tempresult AS TARGET
	USING (select o.phys_order_id
	FROM #tempresult o	
	INNER JOIN pho_phys_order_changeset cs ON cs.phys_order_id = o.phys_order_id
	INNER JOIN @changesetTypes cst ON cst.changeset_type_id = cs.changeset_type_id
	INNER JOIN changeset_status csstat ON csstat.changeset_status_id = cs.current_status_id
	INNER JOIN @changesetStatuses csstats ON csstats.status_id = csstat.status_id
	WHERE @changesetSourceId IS NULL OR cs.changeset_source_id = @changesetSourceId
	) AS SOURCE
	ON (TARGET.phys_order_id = SOURCE.phys_order_id) 
	WHEN NOT MATCHED BY SOURCE 
	THEN DELETE; 
END
*/

/*
SET @step = @step + 1	
SET @step_label = 'Calculating orders statuses'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
insert into #vpos
exec sproc_sprt_pho_getOrderStatus  @debug,@status_code out,@status_text out


SET @step = @step + 1	
SET @step_label = 'Insert into #orders_data'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
INSERT INTO #orders_data
	( 
	phys_order_id, 
	fac_id, 
	client_id, 
	order_verified,
	order_status,
	active_flag, 
	draft, 
	hold_date, 
	hold_date_end, 
	end_date, 
	discontinued_date, 
	order_category_id, 
	controlled_substance_code,
	physician_id,
	pharmacy_id,
	route_of_admin,
	created_by,
	created_date,
	revision_by,
	revision_date,
	start_date,
	strength,
	form,
	description,
	directions,
	related_generic,
	communication_method,
	prescription,
	order_date,
	completed_date,
	origin_id,
	drug_strength,
	drug_strength_uom,
	drug_name,
	order_class_id,
	resident_last_name,
	resident_first_name
	)
	SELECT
		temp.phys_order_id, 
		temp.fac_id, 
		temp.client_id, 
		temp.order_verified,
		vpos.order_status,
		temp.active_flag, 
		temp.draft, 
		temp.hold_date, 
		temp.hold_date_end, 
		temp.end_date, 
		temp.discontinued_date, 
		temp.order_category_id, 
		temp.controlled_substance_code,
		temp.physician_id,
		temp.pharmacy_id,
		temp.route_of_admin,
		temp.created_by,
		temp.created_date,
		temp.revision_by,
		temp.revision_date,
		temp.start_date,
		temp.strength,
		temp.form,
		temp.description,
		temp.directions,
		temp.related_generic,
		temp.communication_method,
		temp.prescription,
		temp.order_date,
		temp.completed_date,
		temp.origin_id,
		temp.drug_strength,
		temp.drug_strength_uom,
		temp.drug_name,
		temp.order_class_id,
		temp.resident_last_name,
		temp.resident_first_name
	FROM @orderStatus stat
	INNER JOIN #vpos vpos ON vpos.order_status = stat.status
	INNER JOIN #tempresult temp ON temp.phys_order_id = vpos.phys_order_id	


SET @step = @step + 1
SET @step_label = 'Apply pagination'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
IF @sortByOrder='desc'
BEGIN
	;WITH TMP AS
	(
		SELECT ROW_NUMBER() OVER(ORDER BY
									 CASE
										WHEN @sortByColumn = 'fac_id' THEN CONVERT(VARCHAR(50), o.fac_id)
										WHEN @sortByColumn = 'description' THEN o.description
										WHEN @sortByColumn = 'client_id' THEN CONVERT(VARCHAR(50), o.resident_first_name)
										ELSE CONVERT(VARCHAR(50), o.phys_order_id)
									END
									DESC,
									CASE
										WHEN @sortByColumn = 'client_id' THEN CONVERT(VARCHAR(50), o.resident_last_name)
										ELSE CONVERT(VARCHAR(50), o.phys_order_id)
									END
									DESC,
									o.phys_order_id DESC) AS rn FROM #orders_data o
	)
	DELETE FROM TMP WHERE @pageSize > 0 AND (rn <= (@pageSize * (@pageNumber-1)) OR rn > (@pageSize * @pageNumber))
END
ELSE
BEGIN
	;WITH TMP AS
	(
		SELECT ROW_NUMBER() OVER(ORDER BY
										CASE
										WHEN @sortByColumn = 'fac_id' THEN CONVERT(varchar(50), o.fac_id)
										WHEN @sortByColumn = 'description' THEN o.description										
										WHEN @sortByColumn = 'client_id' THEN CONVERT(VARCHAR(50), o.resident_first_name)
										ELSE CONVERT(VARCHAR(50), o.phys_order_id)
									END
									ASC,
									CASE
										WHEN @sortByColumn = 'client_id' THEN CONVERT(VARCHAR(50), o.resident_last_name)
										ELSE CONVERT(VARCHAR(50), o.phys_order_id)
									END
									ASC,
									o.phys_order_id DESC) AS rn FROM #orders_data o
	)
	DELETE FROM TMP WHERE @pageSize > 0 AND (rn <= (@pageSize * (@pageNumber-1)) OR rn > (@pageSize * @pageNumber))

END
*/

    /****************************************
    return final result
    ****************************************/
SET @step = @step + 1	
SET @step_label = 'Return final results...'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text

SET @step = @step + 1	
SET @step_label = 'Return orders'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
IF @includeOrders = 1
BEGIN
	SELECT
	o.phys_order_id,
	o.fac_id,
	o.client_id,
	--o.order_status,
	o.description,
	o.resident_first_name,
	o.resident_last_name	
	FROM #tempresult o
	ORDER BY o.fac_id, o.phys_order_id ASC
END
ELSE
BEGIN
	IF @includeOrders = 2
	BEGIN
		SELECT
		o.phys_order_id,
		o.fac_id,
		o.client_id,
		o.physician_id,
		o.order_category_id,
		o.communication_method,
		o.route_of_admin,
		--o.order_status,
		o.description,
		o.resident_first_name,
		o.resident_last_name,
		o.created_by,
		o.created_date,
		o.revision_by,
		o.revision_date
		FROM #tempresult o
		ORDER BY o.fac_id, o.phys_order_id ASC
	END
	ELSE
		SELECT 'ORDER DATA NOT REQUESTED'
END

SET @step = @step + 1	
SET @step_label = 'Return schedules'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
IF @includeSchedules = 1
BEGIN
	SELECT
	o.phys_order_id,
	s.order_schedule_id,
	s.schedule_directions
	FROM #tempresult o
	INNER JOIN PHO_ORDER_SCHEDULE s ON s.phys_order_id = o.phys_order_id
	WHERE s.deleted = 'N'
	ORDER BY o.fac_id, o.phys_order_id, s.order_schedule_id
END
ELSE
BEGIN
	IF @includeSchedules = 2	
	BEGIN	
		SELECT
		os.phys_order_id,
		os.order_schedule_id,
		os.schedule_template,
		os.dose_value,
		os.dose_uom_id,
		os.alternate_dose_value,
		os.dose_low,
		os.quantity_per_dose,
		os.quantity_uom_id,
		os.need_location_of_admin,
		os.sliding_scale_id,
		os.apply_to,
		os.apply_remove_flag,
		os.std_freq_id,
		os.schedule_type,
		os.repeat_week,
		os.mon,
		os.tues,
		os.wed,
		os.thurs,
		os.fri,
		os.sat,
		os.sun,
		os.xxdays,
		os.xxmonths,
		os.xxhours,
		os.date_of_month,
		os.date_start,
		os.date_stop,
		os.days_on,
		os.days_off,
		os.pho_std_time_id,
		os.related_diagnosis,
		os.indications_for_use,
		os.additional_directions,
		os.administered_by_id,
		os.schedule_start_date,
		os.schedule_end_date,
		os.schedule_end_date_type_id,
		os.schedule_duration,
		os.schedule_duration_type_id,
		os.schedule_dose_duration,
		os.prn_admin,
		os.prn_admin_value,
		os.prn_admin_units,
		os.schedule_directions,
		os.created_by,
		os.created_date,
		os.revision_by,
		os.revision_date,		
		--os.std_freq_time_label,
		--os.until_finished,
		--os.order_type_id,
		--os.extended_end_date,
		--os.extended_count,
		--os.prescriber_schedule_start_date,		
		ps.order_schedule_id,
		ps.schedule_id,
		ps.start_time,
		ps.end_time,
		ps.std_shift_id,
		ps.remove_time,
		ps.remove_duration,
		ps.nurse_action_notes
		FROM #tempresult o
		INNER JOIN PHO_ORDER_SCHEDULE os ON os.phys_order_id = o.phys_order_id
		INNER JOIN PHO_SCHEDULE ps ON ps.order_schedule_id = os.order_schedule_id
		WHERE os.deleted = 'N' and ps.deleted = 'N'
		ORDER BY o.fac_id, o.phys_order_id, os.order_schedule_id		
	END
	ELSE
		SELECT 'SCHEDULES DATA NOT REQUESTED'
END

SET @step = @step + 1	
SET @step_label = 'Return changeset'
SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' ' + @step_label
IF @debug='Y' PRINT @status_text
IF @includeChangesets = 1
BEGIN
	SELECT
	o.phys_order_id,
	cs.phys_order_changeset_id,
	cs.changeset_type_id,
	cs.current_status_id,
	cs.changeset_source_id
	FROM #tempresult o
	INNER JOIN pho_phys_order_changeset cs ON cs.phys_order_id = o.phys_order_id
	INNER JOIN @changesetTypes cst ON cst.changeset_type_id = cs.changeset_type_id
	INNER JOIN changeset_status csstat ON csstat.changeset_status_id = cs.current_status_id
	INNER JOIN @changesetStatuses csstats ON csstats.status_id = csstat.status_id
	WHERE @changesetSourceId IS NULL OR cs.changeset_source_id = @changesetSourceId	
END
ELSE
BEGIN
	IF @includeChangesets = 2
	BEGIN
		SELECT
		o.phys_order_id,
		cs.phys_order_changeset_id,
		cs.changeset_type_id,
		cs.current_status_id,
		cs.changeset_source_id,
		cs.changeset_data,
		cs.resulting_phys_order_id,
		cs.aggregate_changeset_id,
		csstat.status_source,
		csstat.status_by,
		csstat.status_date
		FROM #tempresult o
		INNER JOIN pho_phys_order_changeset cs ON cs.phys_order_id = o.phys_order_id
		INNER JOIN @changesetTypes cst ON cst.changeset_type_id = cs.changeset_type_id
		INNER JOIN changeset_status csstat ON csstat.changeset_status_id = cs.current_status_id
		INNER JOIN @changesetStatuses csstats ON csstats.status_id = csstat.status_id
		WHERE @changesetSourceId IS NULL OR cs.changeset_source_id = @changesetSourceId	
	END
	ELSE
		SELECT 'CHANGESET DATA NOT REQUESTED'
END

    SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' Done'
    IF @debug='Y'
        PRINT @status_text
    SET @status_code = 0
    GOTO PgmSuccess
END TRY
--error trapping
BEGIN CATCH
    --SELECT @error_code = @@error, @status_text = 'Error at step:'+convert(varchar(3),@step)+', '+ERROR_MESSAGE()
	SELECT @error_code = @@error, @status_text = 'Error at step:' + convert(varchar(3),@step) + ' <' + @step_label + '>, '+ERROR_MESSAGE()

    SET @status_code = 1

    GOTO PgmAbend

END CATCH

--program success return
PgmSuccess:

IF @status_code = 0
BEGIN
    IF @debug='Y' PRINT 'Successfull execution of stored procedure'
    RETURN @status_code
END

--program failure return
PgmAbend:

--IF @debug='Y' PRINT 'Stored procedure failure in step:'+ convert(varchar(3),@step) + '   ' + convert(varchar(26),getdate())
IF @debug='Y' PRINT 'Stored procedure failure in step:'+ convert(varchar(3),@step) + ' <' + @step_label + '>   ' + convert(varchar(26),getdate())
    IF @debug='Y' PRINT 'Error code: '+convert(varchar(3),@error_code) + '; Error description:    ' +@status_text
    RETURN @status_code

GO
GRANT EXECUTE ON sproc_sprt_order_list_temp2 TO public
GO


GO

print 'A_PreUpload/03 - CORE-95333 -02- DDL - sproc_sprt_order_list_temp2.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/03 - CORE-95333 -02- DDL - sproc_sprt_order_list_temp2.sql',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-92601-DML-Update_POC_Behavior_Mgmt_MDS3_Mapping.sql',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')

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


--===============================================================================================================================================
--  Jira #:             CORE-92601
--
--  Written By:         Brian Young
--  Reviewed By:
--
--  Script Type:        DML
--  Target DB Type:     CLIENT
--  Target Database:    BOTH
--
--  Re-Runnable:        YES
--
--  Where tested:       cdn_conv, pccsql-use2-nprd-spca-set00B1.bbd2b72cba43.database.windows.net
--
--  Description of Script Function: Add MDS3.0  mapping to behavior question
--                      Revised to exclude updating databases with duplicate 'bhv' control rows.
--
--  Special Instruction: None
--===============================================================================================================================================
 
DECLARE
	  @BHV_STD_QUESTION_ID int
	, @STD_ASSESS_ID       int = 11
	, @DELETED_DATE		   datetime = getdate()


-- try to Soft Delete duplicate Cp_Question Behavior ("bhv") rows
;WITH cte_DUPS AS (
  SELECT std_question_id, deleted, deleted_by, deleted_date,
     row_number() OVER(PARTITION BY control_type, system_control_flag ORDER BY created_date) AS rn
  FROM dbo.cp_std_question
  WHERE control_type = 'bhv' AND system_control_flag = 'Y' AND deleted = 'N'
)
UPDATE cpq 
  SET cpq.deleted = 'Y'
	, cpq.deleted_by = 'CORE-96702'
	, cpq.deleted_date = @DELETED_DATE
FROM cte_DUPS d  
JOIN dbo.cp_std_question cpq on cpq.std_question_id = d.std_question_id
LEFT JOIN dbo.cp_rev_intervention_question cpr on cpr.std_question_id = d.std_question_id
WHERE d.rn > 1
  AND cpr.intervention_id is NULL


-- try to Insert new Cp_Question_Mds Behavior ("bhv") rows
SET @BHV_STD_QUESTION_ID = (SELECT std_question_id FROM cp_std_question WHERE control_type = 'bhv' AND system_control_flag = 'Y' AND Deleted = 'N');

INSERT INTO cp_std_question_mds(std_question_id, std_assess_id, mds_question_key) 
SELECT @BHV_STD_QUESTION_ID, @STD_ASSESS_ID, 'E0100A'
WHERE NOT EXISTS(SELECT 1 FROM cp_std_question_mds where std_assess_id=@STD_ASSESS_ID and std_question_id=@BHV_STD_QUESTION_ID and mds_question_key = 'E0100A');

INSERT INTO cp_std_question_mds(std_question_id, std_assess_id, mds_question_key) 
SELECT @BHV_STD_QUESTION_ID, @STD_ASSESS_ID, 'E0100B'
WHERE NOT EXISTS(SELECT 1 FROM cp_std_question_mds where std_assess_id=@STD_ASSESS_ID and std_question_id=@BHV_STD_QUESTION_ID and mds_question_key = 'E0100B');


GO

print 'A_PreUpload/CORE-92601-DML-Update_POC_Behavior_Mgmt_MDS3_Mapping.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-92601-DML-Update_POC_Behavior_Mgmt_MDS3_Mapping.sql',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-94975 - DDL - Create new schema for Patient Administration.sql',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')

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
CORE-94975        Patient Administration - Create new database schema for Patient Administration
 
Written By:       Sergio Parracho, Sanjay Patel
 
Script Type:      DDL
Target DB Type:   Client
Target Database:  BOTH
Re-Runable:       YES
 
Description :     Patient Administration - Create new database schema for Patient Administration
Re-creates tables : drops if exists and creates brand new tables and related objects
==============================================================================
*/

-- DROP ALL TABLES & RECREATE
IF EXISTS(	SELECT 1 FROM sys.objects
			WHERE object_id = OBJECT_ID(N'[dbo].[pa_encounter_event_location]') AND type in (N'U'))
BEGIN;
	DROP TABLE [dbo].[pa_encounter_event_location];
END;

IF EXISTS(	SELECT 1 FROM sys.objects
			WHERE object_id = OBJECT_ID(N'[dbo].[pa_encounter_location_bed_management_bed_state_mapping]') AND type in (N'U'))
BEGIN;
	DROP TABLE [dbo].[pa_encounter_location_bed_management_bed_state_mapping];
END;

IF EXISTS(	SELECT 1 FROM sys.objects
			WHERE object_id = OBJECT_ID(N'[dbo].[pa_encounter_location_bed_management]') AND type in (N'U'))
BEGIN;
	DROP TABLE [dbo].[pa_encounter_location_bed_management];
END;

IF EXISTS(	SELECT 1 FROM sys.objects
			WHERE object_id = OBJECT_ID(N'[dbo].[pa_encounter_event_detail]') AND type in (N'U'))
BEGIN;
	DROP TABLE [dbo].[pa_encounter_event_detail];
END;

IF EXISTS(	SELECT 1 FROM sys.objects
			WHERE object_id = OBJECT_ID(N'[dbo].[pa_encounter_event]') AND type in (N'U'))
BEGIN;
	DROP TABLE [dbo].[pa_encounter_event];
END;

IF EXISTS(	SELECT 1 FROM sys.objects
			WHERE object_id = OBJECT_ID(N'[dbo].[pa_encounter_location]') AND type in (N'U'))
BEGIN;
	DROP TABLE [dbo].[pa_encounter_location];
END;

IF EXISTS(	SELECT 1 FROM sys.objects
			WHERE object_id = OBJECT_ID(N'[dbo].[pa_encounter_location_type]') AND type in (N'U'))
BEGIN;
	DROP TABLE [dbo].[pa_encounter_location_type];
END;

IF EXISTS(	SELECT 1 FROM sys.objects
			WHERE object_id = OBJECT_ID(N'[dbo].[pa_encounter]') AND type in (N'U'))
BEGIN;
	DROP TABLE [dbo].[pa_encounter];
END;

IF EXISTS(	
    SELECT 1 FROM sys.objects
	WHERE object_id = OBJECT_ID(N'[dbo].[pa_encounter_location_status]') AND type in (N'U'))
BEGIN;
	DROP TABLE [dbo].[pa_encounter_location_status];
END;

IF EXISTS(	
    SELECT 1 FROM sys.objects
	WHERE object_id = OBJECT_ID(N'[dbo].[pa_encounter_status]') AND type in (N'U'))
BEGIN;
	DROP TABLE [dbo].[pa_encounter_status];
END;

IF EXISTS(	SELECT 1 FROM sys.objects
			WHERE object_id = OBJECT_ID(N'[dbo].[pa_resident_status]') AND type in (N'U'))
BEGIN;
	DROP TABLE [dbo].[pa_resident_status];
END;

-- REFERENCE TABLE CREATION 
-- Reference Tables should go into WESREFERENCE later

CREATE TABLE [dbo].[pa_resident_status] --:PHI:N Desc: It will store resident status
(
      resident_status_id     INT IDENTITY NOT NULL --:PHI=N:Desc:Sequential key to identify a unique record
    , value                   VARCHAR(50) NOT NULL --:PHI=N:Desc:Stores reference values for FHIR Encounter Status
    , CONSTRAINT [pa_resident_status__residentStatusId_PK_CL_IX] PRIMARY KEY ([resident_status_id])
)

-- http://hl7.org/fhir/R4/valueset-encounter-status.html
CREATE TABLE [dbo].[pa_encounter_status] --:PHI:N Desc: It will store encounter status
(
      encounter_status_id     INT IDENTITY NOT NULL --:PHI=N:Desc:Sequential key to identify a unique record
    , value                   VARCHAR(50) NOT NULL --:PHI=N:Desc:Stores reference values for FHIR Encounter Status
    , CONSTRAINT [pa_encounter_status__encounterStatusId_PK_CL_IX] PRIMARY KEY ([encounter_status_id])
)

-- http://hl7.org/fhir/R4/valueset-encounter-location-status.html
CREATE TABLE [dbo].[pa_encounter_location_status] --:PHI:N Desc: It will store encounter location status
(
      encounter_location_status_id  INT IDENTITY NOT NULL --:PHI=N:Desc:Sequential key to identify a unique record
    , value                         VARCHAR(50) NOT NULL --:PHI=N:Desc:Stores reference values for FHIR Encounter Status
    , CONSTRAINT [pa_encounter_location_status__encountereLocationStatusId_PK_CL_IX] PRIMARY KEY ([encounter_location_status_id])
)

CREATE TABLE [dbo].[pa_encounter_location_type] --:PHI:N Desc: It will store type of encounter location type
(
      encounter_location_type_id    INT IDENTITY NOT NULL --:PHI=N:Desc:Sequential key to identify a unique record
    , value                         VARCHAR(50) NOT NULL --:PHI=N:Desc:Stores reference values for FHIR Encounter Status
    , CONSTRAINT [pa_encounter_location_type__encountereLocationTyped_PK_CL_IX] PRIMARY KEY ([encounter_location_type_id])
)

-- BASE TABLE CREATION

-- http://hl7.org/fhir/us/core/StructureDefinition-us-core-encounter.html
CREATE TABLE [dbo].[pa_encounter] --:PHI:N Desc: It will store each encounter information
(
      encounter_id                  INT IDENTITY NOT NULL --:PHI=N:Desc:Sequential key to identify a unique record
    , client_id                     INT NOT NULL --:PHI=N:Desc:client Id
    , fac_id                        INT NOT NULL --:PHI=N:Desc:Facility Id
    , current_encounter_status_id   INT NOT NULL --:PHI=N:Desc:status id of the current encounter status
    , current_resident_status_id    INT NOT NULL --:PHI=N:Desc:status id of the current resident status 
    , current_payer_type_id         INT --:PHI=N:Desc:payer type id of the current payer type 
    , start_date                    DATETIME NOT NULL --:PHI=N:Desc:start date of the encounter
    , end_date                      DATETIME NOT NULL --:PHI=N:Desc:end date of the encounter
    , created_by                    VARCHAR(60) NOT NULL --:PHI=N:Desc:who created the encounter
    , created_date                  DATETIME NOT NULL --:PHI=N:Desc:created date of the encounter
    , revision_by                   VARCHAR(60) NOT NULL --:PHI=N:Desc:who modify the encounter
    , revision_date                 DATETIME NOT NULL --:PHI=N:Desc: resivion date of the encounter
    , CONSTRAINT [pa_encounter__encounterId_PK_CL_IX] PRIMARY KEY ([encounter_id])
	, CONSTRAINT [pa_encounter__clientId_FK] FOREIGN KEY ([client_id])
        REFERENCES [dbo].[clients] ([client_id])
	, CONSTRAINT [pa_encounter__facId_FK] FOREIGN KEY ([fac_id]) 
        REFERENCES [dbo].[facility] ([fac_id])
    , CONSTRAINT [pa_encounter__currentEncounterStatusId_FK] FOREIGN KEY ([current_encounter_status_id]) 
        REFERENCES [dbo].[pa_encounter_status] ([encounter_status_id])
    , CONSTRAINT [pa_encounter__currentResidentStatusId_FK] FOREIGN KEY ([current_resident_status_id]) 
        REFERENCES [dbo].[pa_resident_status] ([resident_status_id])
    , CONSTRAINT [pa_encounter__currentPayerTypeId_FK] FOREIGN KEY ([current_payer_type_id]) 
        REFERENCES [dbo].[ar_lib_payer_type] ([payer_type_id])
);

-- Foreign key index creation
CREATE NONCLUSTERED INDEX [pa_encounter__clientId_FK_IX]
ON [dbo].[pa_encounter] ([client_id]);
CREATE NONCLUSTERED INDEX [pa_encounter__facId_FK_IX]
ON [dbo].[pa_encounter] ([fac_id]);
CREATE NONCLUSTERED INDEX [pa_encounter__currentEncounterStatusId_FK_IX]
ON [dbo].[pa_encounter] ([current_encounter_status_id]);
CREATE NONCLUSTERED INDEX [pa_encounter__currentResidentStatusId_FK_IX]
ON [dbo].[pa_encounter] ([current_resident_status_id]);
CREATE NONCLUSTERED INDEX [pa_encounter__currentPayerTypeId_FK_IX]
ON [dbo].[pa_encounter] ([current_payer_type_id]);

-- MAPPING TABLES

-- To store events (census) for encounters
CREATE TABLE [dbo].[pa_encounter_event] --:PHI:N Desc: It will store encounter event information
(
      encounter_event_id            INT IDENTITY NOT NULL --:PHI=N:Desc:Sequential key to identify a unique record
    , encounter_id                  INT NOT NULL --:PHI=N:Desc:Id of the encounter
    -- planned | arrived | triaged | in-progress | onleave | finished | cancelled +
    , encounter_event_status_id     INT NOT NULL --:PHI=N:Desc:status Id of the encounter event
    , census_id                     INT --:PHI=N:Desc:census ID
    , action_code_id                INT --:PHI=N:Desc:Action code Id of the action
    , start_date                    DATETIME NOT NULL --:PHI=N:Desc:start date of the encounter event
    , end_date                      DATETIME NOT NULL --:PHI=N:Desc:end date of the encounter event
    , incomplete                    BIT NOT NULL --:PHI=N:Desc:when rate is not created
    , reset_original_admission_date BIT NOT NULL --:PHI=N:Desc: status of the reset original admission date (value come from the census screen)
    , created_by                    VARCHAR(60) NOT NULL --:PHI=N:Desc:who created the encounter event
    , created_date                  DATETIME NOT NULL --:PHI=N:Desc:created date of the encounter event
    , revision_by                   VARCHAR(60) NOT NULL --:PHI=N:Desc:who modify the encounter event
    , revision_date                 DATETIME NOT NULL --:PHI=N:Desc: resivion date of the encounter event
    , deleted                       BIT NOT NULL --:PHI=N:Desc: status of the encounter event (like yer or no)
        CONSTRAINT [pa_encounter_event__deleted_DFLT] DEFAULT 0
    , deleted_by                    VARCHAR(60) --:PHI=N:Desc:who daleted the encounter event
    , deleted_date                  DATETIME --:PHI=N:Desc: encounter event deleted date
    , CONSTRAINT [pa_encounter_event__encounterEventId_PK_CL_IX] PRIMARY KEY ([encounter_event_id])
    , CONSTRAINT [pa_encounter_event__encounterId_FK] FOREIGN KEY ([encounter_id]) 
        REFERENCES [dbo].[pa_encounter] ([encounter_id])
    , CONSTRAINT [pa_encounter_event__encounterEventStatusId_FK] FOREIGN KEY ([encounter_event_status_id]) 
        REFERENCES [dbo].[pa_encounter_status] ([encounter_status_id])
    , CONSTRAINT [pa_encounter_event__censusId_FK] FOREIGN KEY ([census_id]) 
        REFERENCES [dbo].[census_item] ([census_id])
    , CONSTRAINT [pa_encounter_event__actionCodeId_FK] FOREIGN KEY ([action_code_id]) 
        REFERENCES [dbo].[census_codes] ([item_id])
    -- business key encounter id, encounter_event_status_id, start date
);

-- Foreign key index creation
CREATE NONCLUSTERED INDEX [pa_encounter_event__encounterId_FK_IX]
ON [dbo].[pa_encounter_event] ([encounter_id]);
CREATE NONCLUSTERED INDEX [pa_encounter_event__encounterEventStatusId_FK_IX]
ON [dbo].[pa_encounter_event] ([encounter_event_status_id]);
CREATE NONCLUSTERED INDEX [pa_encounter_event__censusId_FK_IX]
ON [dbo].[pa_encounter_event] ([census_id]);
CREATE NONCLUSTERED INDEX [pa_encounter_event__actionCodeId_FK_IX]
ON [dbo].[pa_encounter_event] ([action_code_id]);

CREATE TABLE [dbo].[pa_encounter_event_detail] --:PHI:Y Desc: It will store encounter event details
(
      encounter_event_id            INT NOT NULL --:PHI=N:Desc:Sequential key to identify a unique record
    , admission_type_id             INT --:PHI=N:Desc:Id of the admission type
    , admission_source_id           INT --:PHI=N:Desc:source id of the admission 
    , discharge_status_id           INT --:PHI=N:Desc:show discharged status
    , expected_payer_type_id        INT --:PHI=N:Desc: Expected (estimated) payer type on Quick ADT
    , adt_to_from_id                INT --:PHI=N:Desc: To/from type
    , adt_to_from_loc_id            INT --:PHI=N:Desc: To/from location
    , loc_admitting                 VARCHAR(2) --:PHI=N:Desc: admitting level of care
    , outpatient_status             CHAR(1) --:PHI=N:Desc:out patient status
    , hospital_stay_from            DATETIME --:PHI=N:Desc:hospital stay from
    , hospital_stay_to              DATETIME --:PHI=N:Desc:hospital stay to
    , hospital_stay_waiver          BIT NOT NULL --:PHI=N:Desc:hospital stay waiver
    , date_exported_nc              DATETIME --:PHI=N:Desc:Date exported from neighbor care
    , generate_new_register_no      CHAR(1) --:PHI=N:Desc: Flag to define generate new register number
    , eoc_startend_flag             CHAR(1) --:PHI=N:Desc: Define eoc start end flag
    , comments                      VARCHAR(254) --:PHI=Y:Desc:any comments on encounter event detail
	, CONSTRAINT [pa_encounter_event_detail__encounterEventId_PK_CL_IX] PRIMARY KEY ([encounter_event_id])
	, CONSTRAINT [pa_encounter_event_detail__admissionTypeId_FK] FOREIGN KEY ([admission_type_id]) 
        REFERENCES [dbo].[ar_common_code] ([item_id])
	, CONSTRAINT [pa_encounter_event_detail__admissionSourceId_FK] FOREIGN KEY ([admission_source_id]) 
        REFERENCES [dbo].[ar_common_code] ([item_id])
	, CONSTRAINT [pa_encounter_event_detail__dischargeStatusId_FK] FOREIGN KEY ([discharge_status_id]) 
        REFERENCES [dbo].[ar_common_code] ([item_id])
	, CONSTRAINT [pa_encounter_event_detail__expectedPayerTypeId_FK] FOREIGN KEY ([expected_payer_type_id]) 
        REFERENCES [dbo].[ar_lib_payer_type] ([payer_type_id])
	, CONSTRAINT [pa_encounter_event_detail__adtToFromId_FK] FOREIGN KEY ([adt_to_from_id]) 
        REFERENCES [dbo].[common_code] ([item_id])
	, CONSTRAINT [pa_encounter_event_detail__adtToFromLocId_FK] FOREIGN KEY ([adt_to_from_loc_id]) 
        REFERENCES [dbo].[common_code] ([item_id])

)

-- Foreign key index creation
CREATE NONCLUSTERED INDEX [pa_encounter_event_detail__admissionTypeId_FK_IX]
ON [dbo].[pa_encounter_event_detail] ([admission_type_id]);
CREATE NONCLUSTERED INDEX [pa_encounter_event_detail__admissionSourceId_FK_IX]
ON [dbo].[pa_encounter_event_detail] ([admission_source_id]);
CREATE NONCLUSTERED INDEX [pa_encounter_event_detail__dischargeStatusId_FK_IX]
ON [dbo].[pa_encounter_event_detail] ([discharge_status_id]);
CREATE NONCLUSTERED INDEX [pa_encounter_event_detail__expectedPayerTypeId_FK_IX]
ON [dbo].[pa_encounter_event_detail] (expected_payer_type_id);
CREATE NONCLUSTERED INDEX [pa_encounter_event_detail__adtToFromId_FK_IX]
ON [dbo].[pa_encounter_event_detail] ([adt_to_from_id]);
CREATE NONCLUSTERED INDEX [pa_encounter_event_detail__adtToFromLocId_FK_IX]
ON [dbo].[pa_encounter_event_detail] ([adt_to_from_loc_id]);

-- Encounter Locations (census_item.bed_id) -- Primary & secondary locations
CREATE TABLE [dbo].[pa_encounter_location] --:PHI:N Desc: It will store encounter location information
(
      encounter_location_id         INT IDENTITY NOT NULL --:PHI=N:Desc:Sequential key to identify a unique record
    , encounter_id                  INT NOT NULL --:PHI=N:Desc: Id of the encounter
    , location_Id                   INT NOT NULL --:PHI=N:Desc: location Id
    , encounter_location_status_id  INT NOT NULL --:PHI=N:Desc:status id of the encounter location
    -- PCC location type (primary, secondary bed)
    , encounter_location_type_id    INT NOT NULL --:PHI=N:Desc:type id of the encounter location
    , start_date                    DATETIME NOT NULL --:PHI=N:Desc:start date
    , end_date                      DATETIME NOT NULL --:PHI=N:Desc:end date 
	, created_by                    VARCHAR(60) NOT NULL --:PHI=N:Desc:who created
    , created_date                  DATETIME NOT NULL --:PHI=N:Desc:created date 
    , revision_by                   VARCHAR(60) NOT NULL --:PHI=N:Desc:who modify
    , revision_date                 DATETIME NOT NULL --:PHI=N:Desc: date of modification
    , CONSTRAINT [pa_encounter_location__encounterLocationId_PK_CL_IX] PRIMARY KEY ([encounter_location_id])
	, CONSTRAINT [pa_encounter__encounterId_FK] FOREIGN KEY ([encounter_id]) 
        REFERENCES [dbo].[pa_encounter] ([encounter_id])
	, CONSTRAINT [pa_encounter_location__bedId_FK] FOREIGN KEY ([location_Id]) 
        REFERENCES [dbo].[bed] ([bed_id])
	, CONSTRAINT [pa_encounter_location_status__encounterLocationStatusId_FK] FOREIGN KEY ([encounter_location_status_id]) 
        REFERENCES [dbo].[pa_encounter_location_status] ([encounter_location_status_id])
	, CONSTRAINT [pa_encounter_location__typeId_FK] FOREIGN KEY ([encounter_location_type_id]) 
        REFERENCES [dbo].[pa_encounter_location_type] ([encounter_location_type_id])
    -- business key- encounter, location, start date
);

-- Foreign key index creation
CREATE NONCLUSTERED INDEX [pa_encounter__encounterId_FK_IX]
ON [dbo].[pa_encounter_location] ([encounter_id]);
CREATE NONCLUSTERED INDEX [bed__bedId_FK_IX]
ON [dbo].[pa_encounter_location] ([location_Id]);
CREATE NONCLUSTERED INDEX [pa_encounter_location_status__encounterLocationStatusId_FK_IX]
ON [dbo].[pa_encounter_location] ([encounter_location_status_id]);
CREATE NONCLUSTERED INDEX [pa_encounter_location__typeId_FK_IX]
ON [dbo].[pa_encounter_location] ([encounter_location_type_id]);


-- Encounter event location
CREATE TABLE [dbo].[pa_encounter_event_location] --:PHI:N Desc: It will store encounter event location information
(
      encounter_event_location_id   INT IDENTITY NOT NULL --:PHI=N:Desc:Sequential key to identify a unique record
    , encounter_event_id            INT NOT NULL --:PHI=N:Desc:event Id of the encounter
    , encounter_location_id         INT NOT NULL --:PHI=N:Desc: Encounter location Id
    , CONSTRAINT [pa_encounter_event_location__encounterEventLocationId_PK_CL_IX] PRIMARY KEY ([encounter_event_location_id])
    , CONSTRAINT [pa_encounter_event_location__encounterEventId_FK] FOREIGN KEY ([encounter_event_id]) 
        REFERENCES [dbo].[pa_encounter_event] ([encounter_event_id])
    , CONSTRAINT [pa_encounter_event_location__encounterLocationId_FK] FOREIGN KEY ([encounter_location_id]) 
        REFERENCES [dbo].[pa_encounter_location] ([encounter_location_id])
)

-- Foreign key index creation
CREATE NONCLUSTERED INDEX [pa_encounter_event_location__encounterEventId_FK_IX]
ON [dbo].[pa_encounter_event_location] ([encounter_event_id]);
CREATE NONCLUSTERED INDEX [pa_encounter_event_location__encounterLocationId_FK_IX]
ON [dbo].[pa_encounter_event_location] ([encounter_location_id]);


CREATE TABLE [dbo].[pa_encounter_location_bed_management_bed_state_mapping] --:PHI:N Desc: It will store bed mapping information
(
      encounter_location_id INT NOT NULL --:PHI=N:Desc:Sequential key to identify a unique record
    , bed_state_id          INT NOT NULL --:PHI=N:Desc: bed state Id
    , CONSTRAINT [pa_encounter_location_bed_management_bed_state_mapping__encounterLocationId_PK_CL_IX] PRIMARY KEY ([encounter_location_id])
);

-- Extension Tables
CREATE TABLE [dbo].[pa_encounter_location_bed_management] --:PHI:N Desc: It will store encounter bed status information
(
      encounter_location_id     INT NOT NULL --:PHI=N:Desc:Sequential key to identify a unique record
    , inactivation_end_date     DATETIME --:PHI=N:Desc:bed Inactivation end date
    , inactivation_reason_id    INT --:PHI=N:Desc:bed Inactivation reason 
    , CONSTRAINT [pa_encounter_location_bed_management__encounterLocationId_PK_CL_IX] PRIMARY KEY ([encounter_location_id])
);


GO

print 'A_PreUpload/CORE-94975 - DDL - Create new schema for Patient Administration.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-94975 - DDL - Create new schema for Patient Administration.sql',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-95593-DML-LoadImportMappingTypesForImportSelfService.sql',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')

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


--==============================================================================================================================================
--  Jira #:        CORE-95593
--
--  Written By:     Gulshan Gill
--  Reviewed By:
--
--  Script Type:     DML
--  Target DB Type:   CLIENT
--  Target Database:   BOTH
--
--  Re-Runable:     YES
--
--  Description of Script Function: Load import mapping types for Import Self Service
--
--  Special Instruction: None
--===============================================================================================================================================


IF NOT EXISTS(SELECT 1 FROM iss_std_import_mapping_types WHERE code = 'SECURITY_USER_ROLES')
	INSERT INTO iss_std_import_mapping_types VALUES(26, 'SECURITY_USER_ROLES', 'Security User Roles', 'CORE-95593', GETDATE(), 'CORE-95593', GETDATE())
	
IF NOT EXISTS(SELECT 1 FROM iss_std_import_mapping_types WHERE code = 'SECURITY_USERS')
	INSERT INTO iss_std_import_mapping_types VALUES(27, 'SECURITY_USERS', 'Security Users', 'CORE-95593', GETDATE(), 'CORE-95593', GETDATE())	

GO

print 'A_PreUpload/CORE-95593-DML-LoadImportMappingTypesForImportSelfService.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-95593-DML-LoadImportMappingTypesForImportSelfService.sql',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-95608- DDL- sproc_pho_getOrderStatus.sql',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')

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



-- =========================================================================================================================
--
--  Script Type: user defined store procedure
--  Target DB Type:  Client
--  Target Database:  Both
--
--  Re-Runable:  Yes
--
--  Description :  Modify Existing Order Status stored procedure to look for Pending Confirmation Statuses from Table
--
-- Change History:
--   Author			    Date		Comment
-- --------------------------------------------------------------------------------------------------------------------------
--   Maciek Sliwa                   Created.
--   Alireza Mandegar	10/15/2012	Updated due to PCC-33677 to take advantage of the input physOrderId + localizing the params
--									Also added the Change History section to it to keep track of changes.
--   Alireza Mandegar	12/19/2012	Updated due to PCC-32538 to consider the number of administered doses for duration by dose
--   Alireza Mandegar	01/16/2013	Updated due to PCC-32538 Reverted changes
--	 Mustafa Behrainwala 16/06/2014 PCC-58908
--	 Mustafa Behrainwala 23/02/2016 PCC-83826

--	 Dom Christie       05/01/2021 CORE-82764  Applied the solution to fix the compliation issue
--	 Elias Ghanem       10/13/2021 CORE-95608  Add creation of index #adminOrder__orderVerified_IX on #adminOrder as suggested by Radu Bogdan
-- =========================================================================================================================

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sproc_pho_getOrderStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [dbo].[sproc_pho_getOrderStatus]
GO

create
proc [dbo].[sproc_pho_getOrderStatus]
(
    @facId int,
    @clientId int,
    @physOrderId int,
    @date datetime,
    @fromPortal char(1) = 'N',
    @debug          char(1)  = 'N',
    @status_code    int  out,
    @status_text    varchar(3000) out

)
as
begin

SET NOCOUNT ON

DECLARE @step           int,
        @error_code     int,
        @date_day  tinyint,
        @date_month tinyint,
        @date_year smallint,
        @day_date datetime
        -- Localize input parameters
       ,@vFacId     int
       ,@vClientId  int
	   


select  @date_day = datepart(dd,@date)  ,
        @date_month = datepart(mm,@date),
        @date_year = datepart(yy,@date),
        @day_date = CAST(FLOOR(CAST(@date AS FLOAT))AS DATETIME)


   
	create table #tempResult_local
    (
        phys_order_id int
        ,fac_id int
        ,client_id int
        ,order_verified varchar(1)
		,active_flag char(1)
		,draft bit
        ,hold_date datetime
        ,hold_date_end datetime
        ,end_date datetime
        ,discontinued_date datetime
        ,order_category_id int
        ,controlled_substance_code int
		,created_date datetime
		,order_class_id tinyint
    )


create table #adminOrder
(
    admin_order_id int,
    created_date datetime,
    effective_date datetime,
    ineffective_date datetime,
    related_phys_order_id int ,
    order_verified char,
    order_relationship_id int
)

create clustered index #adminOrder_IX on #adminOrder (    
    related_phys_order_id,
    effective_date,
    created_date,
	admin_order_id,
    ineffective_date,
    order_verified,
    order_relationship_id)

BEGIN TRY

SET @vClientId = @clientId
SET @vFacId = @facId
SET @status_code = 0

 -- PCC33677: Take advantage of input physOrderId if specified
IF (@physOrderId is not null)
BEGIN
    IF (@vClientId is null)
    BEGIN
        SET @vClientId = (SELECT po.client_id FROM dbo.pho_phys_order po WHERE po.phys_order_id = @physOrderId);
    END
END


DECLARE @IsDischargeEnabled  BIT = ISNULL((select 1 from configuration_parameter cp where cp.fac_id=@vFacId and name='discharge_order_enable' and value='Y'), 0);


IF(@fromPortal = 'N')
BEGIN

	SET @step = 2
	SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' Begin non portal operations: insert client information'
	IF @debug='Y' PRINT @status_text

  IF ( @vClientId is not null and @physOrderId is not null and @physOrderId <> -1)
  BEGIN

    

    SET @step = 3
    SET @status_text = convert(VARCHAR(26), getdate(), 13) + 'Insert #tmpResult(clientId not null, physOrder Id not null): inserts phys order information '
    IF @debug='Y' PRINT @status_text

    insert into #tempResult_local (phys_order_id,fac_id,client_id,order_verified,active_flag,
    draft,hold_date,hold_date_end,end_date,discontinued_date,order_category_id, controlled_substance_code, created_date, order_class_id)
    select ppo.phys_order_id, ppo.fac_id, ppo.client_id, ppo.order_verified, ppo.active_flag, ppo.draft,
      ppo.hold_date, ppo.hold_date_end, ppo.end_date, ppo.discontinued_date, ppo.order_category_id, controlled_substance_code,
	  ppo.created_date, ppo.order_class_id
    from dbo.pho_phys_order ppo
    where ppo.phys_order_id=@physOrderId

		SET @step = 4
    SET @status_text = convert(VARCHAR(26), getdate(), 13) + 'Insert #adminOrder (clientId not null, physOrder Id not null): inserts administrative order information '
    IF @debug='Y' PRINT @status_text

		INSERT into #adminOrder(admin_order_id,created_date,effective_date,ineffective_date,related_phys_order_id,order_verified,order_relationship_id)
		select
			pao.admin_order_id,pao.created_date,pao.effective_date,pao.ineffective_date, pro.related_phys_order_id,ppo.order_verified,pro.order_relationship_id
		from
			dbo.pho_related_order pro
			inner join dbo.pho_admin_order pao on pao.phys_order_id = pro.phys_order_id
			inner join dbo.pho_phys_order ppo on ppo.phys_order_id = pao.phys_order_id
			
		where
			pro.related_phys_order_id = @physOrderId
			and isnull(pro.deleted,'N')='N'
			and pao.deleted='N'
			and pao.exclude_eom_status_calculation=0


	END
	ELSE IF ( @vClientId is not null)
    BEGIN

    	 
    SET @step = 3
    SET @status_text = convert(VARCHAR(26), getdate(), 13) + 'Insert #tmpResult(clientId not null, physOrder Id null): inserts phys order information '
    IF @debug='Y' PRINT @status_text

	  insert into #tempResult_local (phys_order_id,fac_id,client_id,order_verified,active_flag,
	    draft,hold_date,hold_date_end,end_date,discontinued_date,order_category_id, controlled_substance_code, created_date, order_class_id)
	  select ppo.phys_order_id, ppo.fac_id, ppo.client_id, ppo.order_verified, ppo.active_flag, ppo.draft,
	    ppo.hold_date, ppo.hold_date_end, ppo.end_date, ppo.discontinued_date, ppo.order_category_id, controlled_substance_code,
		ppo.created_date, ppo.order_class_id
	  from dbo.pho_phys_order ppo
	  where
	    ppo.fac_id = @vFacId
	    and ppo.order_category_id <> 1
	    and ppo.order_category_id <> 3030
	    and ppo.client_id=@vClientId


	  SET @step = 4
	  SET @status_text = convert(VARCHAR(26), getdate(), 13) + 'Insert #adminOrder (clientId not null, physOrder Id null): inserts administrative order information '
	  IF @debug='Y' PRINT @status_text

	  INSERT into #adminOrder(admin_order_id,created_date,effective_date,ineffective_date,related_phys_order_id,order_verified,order_relationship_id)
	  select
	    pao.admin_order_id,pao.created_date,pao.effective_date,pao.ineffective_date, pro.related_phys_order_id,ppo.order_verified,pro.order_relationship_id
	  from
	    dbo.pho_related_order pro
	    inner join dbo.pho_admin_order pao on pao.phys_order_id = pro.phys_order_id
	    inner join dbo.pho_phys_order ppo on ppo.phys_order_id = pao.phys_order_id  and ppo.fac_id=@vFacId and ppo.client_id=@vClientId
	    
	  where
	    pro.fac_id=@vFacId
	    and isnull(pro.deleted,'N')='N'
	    and pao.deleted='N'
	    and pao.exclude_eom_status_calculation=0

    END
    ELSE -- Client Id is null
    BEGIN
	    raiserror ('Null Client Id is not allowed for Portal No.', 16, 1)
	END
--------------------------------------------------
END
ELSE -- case for from portal
BEGIN
	
	insert into #tempResult_local (phys_order_id,fac_id,client_id,order_verified,active_flag,
	    draft,hold_date,hold_date_end,end_date,discontinued_date,order_category_id, controlled_substance_code)
		select phys_order_id,fac_id,client_id,order_verified,active_flag,
	    draft,hold_date,hold_date_end,end_date,discontinued_date,order_category_id, controlled_substance_code from #tempresult
		
	IF @IsDischargeEnabled = 1
	BEGIN
		update tl 
			set tl.created_date = p.created_date, tl.order_class_id = p.order_class_id
		from #tempResult_local tl
			inner join pho_phys_order p on p.phys_order_id = tl.phys_order_id and p.order_class_id = 2
	END	

	  SET @step = 2
    SET @status_text = convert(VARCHAR(26), getdate(), 13) + ' Begin portal operations: insert admin orders'
    IF @debug='Y' PRINT @status_text

	  INSERT into #adminOrder(admin_order_id,created_date,effective_date,ineffective_date,related_phys_order_id,order_verified,order_relationship_id)
		select
			pao.admin_order_id,pao.created_date,pao.effective_date,pao.ineffective_date, pro.related_phys_order_id,po.order_verified,pro.order_relationship_id
		from
			dbo.pho_related_order pro
			inner join dbo.pho_admin_order pao on pao.phys_order_id = pro.phys_order_id
			inner join #tempResult_local ppo on ppo.phys_order_id = pro.related_phys_order_id
			--inner join #clients c on ppo.client_id = c.client_id
			inner join pho_phys_order po on po.phys_order_id = pao.phys_order_id
		where
			(pro.fac_id=@vFacId)
			and isnull(pro.deleted,'N')='N'
			and pao.deleted='N'
			and pao.exclude_eom_status_calculation=0
END
--------------------------------------------------
  SET @step = 5
  SET @status_text = convert(VARCHAR(26), getdate(), 13) + 'select order statuses'
  IF @debug='Y' PRINT @status_text

  create index #adminOrder__orderVerified_IX on #adminOrder (order_verified)
  
  DECLARE @facility_time datetime=dbo.fn_facility_getCurrentTimeForDate(@vFacId, @date);

    select
    --data.relationship_code,
    ppo.phys_order_id,
    ppo.fac_id,
    CASE
		WHEN
			@IsDischargeEnabled = 1
            AND ppo.order_class_id is not null AND ppo.order_class_id=2
			AND ppo.created_date < (select c.admission_date from clients c where c.client_id = ppo.client_id)
        THEN 12 -- historical completed

		WHEN 
			isnull(ppo.active_flag, 'Y') = 'Y' 
			AND esign.phys_order_id IS NOT NULL
		THEN (case when ppo.controlled_substance_code in (2,3,4,5,6) and esign.marked_to_sign_contact_id is null then 10 -- Pending Mark To Sign
              else 11 -- Pending Order Signature
              end) 
             
        WHEN
            (
                (
                    data.relationship_code = 'DC' --admin order is Discontinue
                    and isnull(data.adminOrderVerified,'Y') = 'Y' --admin order is verified.
                )
                or
                ( ppo.discontinued_date is not null and ppo.discontinued_date < @facility_time )
            )
            AND isnull(ppo.active_flag, 'Y') = 'Y'
        THEN 2 -- discontinued
        
    	WHEN
            (
                ppo.order_verified = 'N'
                or
                (data.adminOrderVerified = 'N' or isnull(unverifiedOrders.oneOrderVerified,'N') = 'Y')
            )
            AND isnull(ppo.active_flag, 'Y') = 'Y'
        THEN 8 -- unconfirmed

		WHEN 
			isnull(ppo.order_verified,'Y') = 'Y' AND
			isnull(ppo.active_flag, 'Y') = 'Y' AND
			clinrev.created_date IS NOT NULL
			
		THEN 9 -- order verified, pending clinical review.

        WHEN
            ppo.draft = 0 -- not draft
            AND isnull(ppo.order_verified,'Y') = 'Y'  -- order is verified
            AND
                (
                    (data.relationship_code is null or data.relationship_code not in ('H','DC')) -- no admin orders
                    and
                    isnull(data.adminOrderVerified, 'Y') = 'Y' --admin order is verified or doesn't exist.
                )
            and
            (
                ppo.hold_date IS NULL
                OR (ppo.hold_date > @facility_time AND ppo.hold_date_end IS NULL)
                OR (@facility_time NOT BETWEEN  ppo.hold_date and ppo.hold_date_end)
            )
            AND (ppo.end_date IS NULL OR (ppo.end_date > @facility_time or poes.phys_order_id is not null))-- not completed
            and ( ppo.discontinued_date is null or ppo.discontinued_date > @facility_time )
            AND isnull(ppo.active_flag, 'Y') = 'Y'
        THEN 1 --active

        WHEN
            ppo.draft = 0 -- not draft
            AND isnull(ppo.order_verified,'Y') = 'Y'-- order is verified
            and
                (
                    (
                        ((ppo.hold_date <= @facility_time AND ppo.hold_date_end IS NULL)
                        OR (@facility_time BETWEEN  ppo.hold_date and ppo.hold_date_end))
                        and isnull(data.adminOrderVerified,'Y') = 'Y'
                    )
                    or
                    (
                        data.relationship_code = 'H' --admin order is hold
                        and isnull(data.adminOrderVerified,'Y') = 'Y' --admin order is verified.
                    )
                )
            AND (ppo.end_date IS NULL OR (ppo.end_date > @facility_time or poes.phys_order_id is not null))--not completed
            and ( ppo.discontinued_date is null or ppo.discontinued_date > @facility_time )
            AND isnull(ppo.active_flag, 'Y') = 'Y'
        THEN 5 -- onhold

		WHEN
            ppo.end_date IS NOT NULL AND ppo.end_date <= @facility_time
            AND isnull(ppo.active_flag, 'Y') = 'Y'
        THEN 3 -- completed

        WHEN
            ppo.active_flag = 'N' -- should only by queued orders.
        THEN -1
        ELSE -1
    END
    as order_status,
    (
        case
            when isnull(unverifiedOrders.oneOrderVerified,'N') = 'Y'
            then
                unverifiedOrders.order_relationship_id
            else
                data.order_relationship_id
        end
    ) as  order_relationship,
    --data.order_relationship_id as order_relationship,
    (case  -- for  unconfirmed pharmacy orders return extra order status reason
        when ((ppo.order_verified = 'N' or (isnull(unverifiedOrders.oneOrderVerified,'N') = 'Y' or data.adminOrderVerified = 'N' ) ) AND isnull(ppo.active_flag, 'Y') = 'Y' )
        then
            case
        
             when isnull(unverifiedOrders.oneOrderVerified,'N') = 'Y'
                    then
                        case
                            when (unverifiedOrders.relationship_code = 'H')  then -1
                            when (unverifiedOrders.relationship_code = 'R') then -2
                            when (unverifiedOrders.relationship_code = 'DC') then -3
                            when  ppo.order_category_id = 3022 and  posp.reason_binary_code is not null then posp.reason_binary_code
                         end
                    else
                        case

                            when (data.relationship_code = 'H' or unverifiedOrders.relationship_code = 'H')  then -1
                            when (data.relationship_code = 'R' or unverifiedOrders.relationship_code = 'R') then -2
                            when (data.relationship_code = 'DC' or unverifiedOrders.relationship_code = 'DC') then -3
                            when  ppo.order_category_id = 3022 and  posp.reason_binary_code is not null then posp.reason_binary_code
                            else null
                        end   
            end
        else null
    end) as status_reason

from
    #tempResult_local ppo
    left join
    (
        --done as an sub select because of performance.
        select
            por.relationship_code,
            adm.order_verified as adminOrderVerified,
            maxAdminOrder.related_phys_order_id,
            por.order_relationship_id
        from
        (
            --this query returns the max created date for the max effective date before the specific date.
            select
                adm.related_phys_order_id,
                adm.effective_date,
                max(adm.created_date) created_date
            from
            (
                --this query returns the max effective date before the specific date.
                select
                    related_phys_order_id,
                    max(effective_date) effective_date
                from
                    #adminOrder
                where
                    effective_date<=@date
                group by
                    related_phys_order_id
            )as maxAdminEffDate
            inner join #adminOrder adm on
                maxAdminEffDate.related_phys_order_id = adm.related_phys_order_id
                and maxAdminEffDate.effective_date = adm.effective_date
            group by adm.related_phys_order_id, adm.effective_date
        )as maxAdminOrder
        inner join #adminOrder adm ON
                 maxAdminOrder.related_phys_order_id = adm.related_phys_order_id
                and maxAdminOrder.effective_date = adm.effective_date
                and maxAdminOrder.created_date = adm.created_date
        inner join dbo.pho_order_relationship por on
                por.order_relationship_id = adm.order_relationship_id
        where
             (isnull(adm.ineffective_date,@date)>=@date OR isnull(adm.order_verified, 'Y')='N')
    )as data on data.related_phys_order_id = ppo.phys_order_id

    left join
    (
                --This query returns and Pending administrative order for a given Phys order.
                --If any order has an associated Pending Confirmation Admin order, the status of that
                -- Order will be Pending Confirmation. Incase there are more then 1 pending confirmation Admin orders
                -- we will take the later of the two (max effective_date, then admin_order_id if there are multiple admin orders with the same effective_date).
                select adm.related_phys_order_id, por.order_relationship_id,por.relationship_code,'Y' as oneOrderVerified
                 from
                    #adminOrder adm
                    INNER JOIN (
                        SELECT max(admin_order_id) admin_order_id, ao.related_phys_order_id FROM (
                            SELECT related_phys_order_id, max(effective_date) effective_date FROM
                            #adminOrder
                            WHERE order_verified = 'N'
                            GROUP BY related_phys_order_id
                        ) maxDate
                        INNER JOIN #adminOrder ao
                            ON maxDate.related_phys_order_id = ao.related_phys_order_id
                            AND maxDate.effective_date = ao.effective_date
                        GROUP BY ao.related_phys_order_id
                    ) maxId ON maxId.admin_order_id = adm.admin_order_id
                    inner join dbo.pho_order_relationship por on por.order_relationship_id = adm.order_relationship_id

        )as unverifiedOrders on unverifiedOrders.related_phys_order_id = ppo.phys_order_id
		
        -- join to the clinical review table
        LEFT JOIN pho_order_clinical_review clinrev ON clinrev.phys_order_id=ppo.phys_order_id AND clinrev.reviewed_date is NULL
        LEFT JOIN pho_phys_order_esignature esign ON esign.phys_order_id=ppo.phys_order_id AND esign.sign_contact_id IS NULL
    LEFT JOIN pho_order_pending_reason posp ON posp.phys_order_id = ppo.phys_order_id 
    left join pho_phys_order_extended_schedule poes on poes.phys_order_id = ppo.phys_order_id
    where
    ( ppo.fac_id=@vFacId)
    and ppo.order_category_id <> 1
    and ppo.order_category_id <> 3030
	


--drop table #adminOrder


--if(@fromPortal = 'N')
--begin
--    DROP TABLE #tempResult
--END

IF @debug='Y'
print convert(VARCHAR(26), getdate(), 13) + ' Step 6 Done'

SET @status_text = null;

END TRY

--error trapping
BEGIN CATCH



    SELECT @error_code = @@error, @status_text = ERROR_MESSAGE()

    SET @status_code = 1

    GOTO PgmAbend

END CATCH

--program success return
PgmSuccess:
IF @status_code = 0
BEGIN
    IF @debug='Y' PRINT 'Successfull execution of stored procedure'
    RETURN @status_code
END

--program failure return
PgmAbend:
IF @debug='Y' PRINT 'Stored procedure failure in step:'+ convert(varchar(3),@step) + '  ' + convert(varchar(26),getdate())
IF @debug='Y' PRINT 'Error code: '+convert(varchar(3),@step) + '; Error description:    ' +@status_text
RETURN @status_code

END
GO

GRANT EXECUTE ON [sproc_pho_getOrderStatus] TO PUBLIC
GO


GO

print 'A_PreUpload/CORE-95608- DDL- sproc_pho_getOrderStatus.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-95608- DDL- sproc_pho_getOrderStatus.sql',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-95609- DDL - Drop the columns from the azure_data_archive_pipeline_storage_file_name as they are not required.sql',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')

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



-- CORE-95609	
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
--, inserting
--Dropping the columns of the table  azure_data_archive_pipeline_storage_file_name that are not requried.
--
-- =================================================================================




IF EXISTS (SELECT 1 FROM SYS.OBJECTS WHERE TYPE_DESC =  'DEFAULT_CONSTRAINT' AND name='azure_data_archive_pipeline_storage_file_name__isUnmatchFileMoved_DFLT')

	BEGIN
	 ALTER TABLE azure_data_archive_pipeline_storage_file_name
     DROP CONSTRAINT azure_data_archive_pipeline_storage_file_name__isUnmatchFileMoved_DFLT
	END






IF  EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME='is_unmatch_file_moved' AND TABLE_NAME='azure_data_archive_pipeline_storage_file_name')
BEGIN
ALTER TABLE azure_data_archive_pipeline_storage_file_name
DROP COLUMN [is_unmatch_file_moved]
END



IF EXISTS (SELECT 1 FROM SYS.OBJECTS WHERE TYPE_DESC =  'DEFAULT_CONSTRAINT' AND name='azure_data_archive_pipeline_storage_file_name__isDeleteMismatch_DFLT')

BEGIN
      ALTER TABLE azure_data_archive_pipeline_storage_file_name
      DROP CONSTRAINT azure_data_archive_pipeline_storage_file_name__isDeleteMismatch_DFLT
END
  

IF  EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME='is_delete_mismatch' AND TABLE_NAME='azure_data_archive_pipeline_storage_file_name')
BEGIN
ALTER TABLE azure_data_archive_pipeline_storage_file_name
DROP COLUMN [is_delete_mismatch]
END

	 



GO

print 'A_PreUpload/CORE-95609- DDL - Drop the columns from the azure_data_archive_pipeline_storage_file_name as they are not required.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-95609- DDL - Drop the columns from the azure_data_archive_pipeline_storage_file_name as they are not required.sql',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-95609- DDL - Drop the new table for the pipeline schedule.sql',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')

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



-- CORE-95609	
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
--dropping table for the schedule to handle different schedules
--
-- =================================================================================


IF EXISTS (SELECT 1 FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_NAME='azure_data_archive_pipeline_master_controller' AND CONSTRAINT_NAME='azure_data_archive_pipeline_master_controller__pipelineSchedule_FK')

BEGIN
ALTER TABLE [dbo].[azure_data_archive_pipeline_master_controller] DROP CONSTRAINT [azure_data_archive_pipeline_master_controller__pipelineSchedule_FK]
END
GO

IF  EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='azure_data_archive_pipeline_schedule')
BEGIN

DROP TABLE azure_data_archive_pipeline_schedule

END


GO

print 'A_PreUpload/CORE-95609- DDL - Drop the new table for the pipeline schedule.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-95609- DDL - Drop the new table for the pipeline schedule.sql',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-95609- DDL- Adding columns to the table  azure_data_archive_pipeline_storage_file_name.sql',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')

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



-- CORE-95609	
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
--, inserting
--Adding column to azure_data_archive_pipeline_storage_file_name for tracking delete mismatch
--
-- =================================================================================




             
		IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME='is_unmatched_file_moved' AND TABLE_NAME='azure_data_archive_pipeline_storage_file_name')
		BEGIN
		ALTER TABLE azure_data_archive_pipeline_storage_file_name
		ADD is_unmatched_file_moved BIT NOT NULL CONSTRAINT [azure_data_archive_pipeline_storage_file_name__isUnmatchedFileMoved_DFLT] DEFAULT(0)--:PHI=N:Desc:Holds the bit value for the mismatch file moved or not
		END

		
		IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME='is_unmatched_file_deleted' AND TABLE_NAME='azure_data_archive_pipeline_storage_file_name')
		BEGIN
		ALTER TABLE azure_data_archive_pipeline_storage_file_name
		ADD is_unmatched_file_deleted BIT NOT NULL  CONSTRAINT [azure_data_archive_pipeline_storage_file_name__isUnmatchedFileDeleted_DFLT] DEFAULT(0) --:PHI=N:Desc:Holds the bit value for delete mismatch of the file
		END

		IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME='is_file_table_deleted_rows_mismatch'AND TABLE_NAME='azure_data_archive_pipeline_storage_file_name')
		BEGIN
		ALTER TABLE azure_data_archive_pipeline_storage_file_name
		ADD is_file_table_deleted_rows_mismatch BIT NOT NULL  CONSTRAINT [azure_data_archive_pipeline_storage_file_name__isFileTableDeletedRowsMisMatch_DFLT] DEFAULT(0) --:PHI=N:Desc:Holds the bit value for  mismatch of the deleted rows from table
		END





GO

print 'A_PreUpload/CORE-95609- DDL- Adding columns to the table  azure_data_archive_pipeline_storage_file_name.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-95609- DDL- Adding columns to the table  azure_data_archive_pipeline_storage_file_name.sql',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-95792- DML - Update osiris reference tables with values.sql',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')

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


--==============================================================================================================================================
--  Jira #:        CORE-95792
--
--  Written By:     Sanjay Patel
--  Reviewed By:
--
--  Script Type:     DML
--  Target DB Type:   CLIENT
--  Target Database:   BOTH
--
--  Re-Runable:     YES
--
--  Description of Script : update Osiris reference tables with values
--
--  Special Instruction: None
--===============================================================================================================================================
IF EXISTS(SELECT 1 FROM dbo.pa_encounter_status)
	BEGIN
		 DELETE FROM  dbo.pa_encounter_status;
	END

	BEGIN
		SET IDENTITY_INSERT dbo.pa_encounter_status ON;
		INSERT INTO dbo.pa_encounter_status(encounter_status_id, value)
		VALUES	(1, 'planned'),
				(2, 'arrived'),
				(3, 'triaged'),
				(4, 'in-progress'),
				(5, 'onleave'),
				(6, 'finished'),
				(7, 'cancelled');
		SET IDENTITY_INSERT dbo.pa_encounter_status OFF;
	END

GO
IF EXISTS(SELECT 1 FROM dbo.pa_encounter_location_status)
	BEGIN
	  DELETE FROM  dbo.pa_encounter_location_status;
	END
	
	BEGIN
		SET IDENTITY_INSERT dbo.pa_encounter_location_status ON;
		INSERT INTO dbo.pa_encounter_location_status(encounter_location_status_id, value)
		VALUES	(1, 'planned'),
				(2, 'active'),
				(3, 'reserved'),
				(4, 'completed');
	SET IDENTITY_INSERT dbo.pa_encounter_location_status OFF;
	END

GO
IF EXISTS(SELECT 1 FROM dbo.pa_encounter_location_type)
	BEGIN
	  DELETE FROM  dbo.pa_encounter_location_type;
	END

	BEGIN
		SET IDENTITY_INSERT dbo.pa_encounter_location_type ON;
		INSERT INTO dbo.pa_encounter_location_type(encounter_location_type_id, value)
		VALUES	(1, 'primary bed'),
				(2, 'secondary bed');	
		SET IDENTITY_INSERT dbo.pa_encounter_location_type OFF;
	END
GO
IF EXISTS(SELECT 1 FROM dbo.pa_resident_status)
	BEGIN
	  DELETE FROM  dbo.pa_resident_status;
	END

	BEGIN
		SET IDENTITY_INSERT dbo.pa_resident_status ON;
		INSERT INTO dbo.pa_resident_status(resident_status_id, value)
		VALUES	(1, 'New'),
				(2, 'Current'),
				(3, 'Discharged'),
				(4, 'Outpatient'),
				(5, 'Waiting List');
		SET IDENTITY_INSERT dbo.pa_resident_status OFF;
	END
GO

GO

print 'A_PreUpload/CORE-95792- DML - Update osiris reference tables with values.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/CORE-95792- DML - Update osiris reference tables with values.sql',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/US_Only/CORE-95697-DML-update_facility_table_send_message_flag_column.sql',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')

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
-- Jira #:               CORE-95656
--
-- Written By:           Willie Wong
-- Reviewed By:
--
-- Script Type:          DML
-- Target DB Type:       Client DB
-- Target Environment:   US
--
--
-- Re-Runable:           YES
--
-- Where tested:  ADVM
--
-- Staging Recommendations/Warnings:
--
-- Description of Script Function:
--   * Update messages_enabled_flag to 'Y' on facility table
--
-- Special Instruction:
--
--
-- =================================================================================


IF EXISTS(
    (SELECT 1 FROM INFORMATION_SCHEMA.TABLES tbl1 
    JOIN INFORMATION_SCHEMA.TABLES tbl2 ON tbl2.TABLE_NAME = 'facility' AND tbl2.TABLE_SCHEMA = 'dbo'
    WHERE tbl1.TABLE_NAME = 'lib_message_profile' AND tbl1.TABLE_SCHEMA = 'dbo') 
)                                                 
BEGIN
    update fac set messages_enabled_flag = 'Y', revision_by = 'CORE-95656', revision_date = getdate() 
    from facility fac join lib_message_profile lmp on lmp.receiving_application = 'collective-postacute' 
    and lmp.deleted <> 'Y' and lmp.is_enabled = 'Y' where fac.deleted = 'N' and (fac.inactive is null or fac.inactive <> 'Y') 
    and (fac.is_live is null or fac.is_live <> 'N') and (fac.messages_enabled_flag is null or fac.messages_enabled_flag <> 'Y');
END

GO

print 'A_PreUpload/US_Only/CORE-95697-DML-update_facility_table_send_message_flag_column.sql -- ****SCRIPT DONE****'

GO

insert into upload_tracking(script,timestamp,upload) values ('A_PreUpload/US_Only/CORE-95697-DML-update_facility_table_send_message_flag_column.sql',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')

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
values ('4.4.7_A', 'upload_history')


GO

print '..\Update db version.sql --****SCRIPT DONE****'

GO

insert into upload_tracking (script, timestamp, upload) values ('..\Update db version.sql',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')

GO

insert into upload_tracking (script,timestamp,upload) values ('UPLOAD END',getdate(),'4.4.7_06_CLIENT_A_PreUpload_US.sql')