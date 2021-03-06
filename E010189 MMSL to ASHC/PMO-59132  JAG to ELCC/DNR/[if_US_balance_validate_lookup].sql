USE [test_usei206]
GO
/****** Object:  StoredProcedure [dbo].[if_US_balance_validate_lookup]    Script Date: 05/21/2013 10:10:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[if_US_balance_validate_lookup] AS

	INSERT INTO [dbo].if_US_error_detail (file_id,file_type_id,row_id,Error_code,Error_param1)
	  SELECT 0,1,1,'VAL_ERR022','Facility_code ' + cast(facility_code as varchar(10))	   --more than one facilities with the same code
		FROM facility
		WHERE facility_code in
		(SELECT facility_number
		FROM [dbo].if_US_ARbalance)
		GROUP BY facility_code
		HAVING COUNT(facility_code) > 1

	Insert into [dbo].if_US_error_detail (file_id,file_type_id,row_id,Error_code,Error_param1)
		select File_ID,3,row_id,'VAL_ERR005', 'Facility_Number'
		from if_US_ARbalance
		where facility_number not in
		(select facility_code
		from facility where deleted = 'N')

   Insert into [dbo].if_US_error_detail (file_id,file_type_id,row_id,Error_code,Error_param1)
      select File_ID,3,row_id,'VAL_ERR005','payer_id'
         from [dbo].if_US_ARbalance a inner join facility b
		 on a.facility_number = b.facility_code
		 where not exists (select 1 from ar_lib_payers 
						   join ar_payers on ar_lib_payers.payer_id = ar_payers.payer_id
							where ar_lib_payers.deleted <> 'Y'
							and a.payer_id = ar_payers.payer_id---(ltrim(rtrim(ar_lib_payers.payer_code)) + ltrim(rtrim(ar_lib_payers.payer_code2)))
							and b.fac_id = ar_payers.fac_id)


   Insert into [dbo].if_us_error_detail (file_id,file_type_id,row_id,Error_code,Error_param1)
      select File_ID,3,row_id,'VAL_ERR005','client_id_number'
         from [dbo].if_us_arbalance a inner join facility b
		 on a.facility_number = b.facility_code
		 where not exists (select 1 from clients
							where a.client_id_number = clients.client_id_number
							and b.fac_id = clients.fac_id
							AND clients.deleted <> 'Y')



