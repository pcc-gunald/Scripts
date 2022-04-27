--INSERT INTO pcc_staging_db58910.[dbo].EICase589101067emc_ext_facilities (src_id)
SELECT ext_fac_id
FROM test_usei548.[dbo].emc_ext_facilities
WHERE ext_fac_id <> - 1
	AND (
		fac_id = 1067
		OR fac_id = - 1
		OR reg_id = 2
		)
	AND (
		ext_fac_id IN (
			SELECT ext_fac_id
			FROM test_usei548.[dbo].client_ext_facilities
			WHERE fac_id = 1067
			)
		OR ext_fac_id IN (
			SELECT adt_tofrom_loc_id * - 1
			FROM test_usei548.[dbo].census_item
			WHERE fac_id = 1067
			)
		OR ext_fac_id IN (
			SELECT pharmacy_id
			FROM test_usei548.[dbo].pho_phys_order
			WHERE fac_id = 1067
			)
		OR ext_fac_id IN (
			SELECT reporting_lab_ext_fac_id
			FROM test_usei548.[dbo].result_order_source
			WHERE fac_id = 1067
			)
		)
ORDER BY ext_fac_id
