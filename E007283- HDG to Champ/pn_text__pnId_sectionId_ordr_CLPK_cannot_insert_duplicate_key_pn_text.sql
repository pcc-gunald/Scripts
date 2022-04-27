;
WITH TEMP
AS (
	SELECT *
		,row_number() OVER (
			PARTITION BY template_id
			,description ORDER BY section_id
			) rn
	FROM test_usei547.[dbo].pn_template_section
	)
UPDATE TEMP
SET description = CONCAT (
		description
		,'_'
		,rn - 1
		)
FROM TEMP
