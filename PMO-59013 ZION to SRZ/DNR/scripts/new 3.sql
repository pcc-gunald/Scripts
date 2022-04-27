SELECT *
FROM StagingMergeLog
ORDER BY msgtime DESC

SELECT *
FROM EI_FKViolation

select top 10 * from [pcc_staging_db007693].dbo.[immunization_strikeout] where strikeout_reason_id IS NULL



IF EXISTS (
		SELECT [strikeout_reason_id]
		FROM [pcc_staging_db007693].dbo.[immunization_strikeout] WITH (NOLOCK)
		WHERE [strikeout_reason_id] IS NOT NULL
			AND [strikeout_reason_id] NOT IN (
				SELECT [item_id]
				FROM [pcc_staging_db007693].dbo.[common_code] WITH (NOLOCK)
				WHERE [item_id] IS NOT NULL
				
				UNION
				
				SELECT [item_id]
				FROM test_usei910.dbo.[common_code] WITH (NOLOCK)
				WHERE [item_id] IS NOT NULL
				)
		)
	SELECT *
	FROM [pcc_staging_db007693].dbo.[immunization_strikeout] WITH (NOLOCK)
	WHERE [strikeout_reason_id] IS NOT NULL
		AND [strikeout_reason_id] NOT IN (
			SELECT [item_id]
			FROM [pcc_staging_db007693].dbo.[common_code] WITH (NOLOCK)
			WHERE [item_id] IS NOT NULL
			
			UNION
			
			SELECT [item_id]
			FROM test_usei910.dbo.[common_code] WITH (NOLOCK)
			WHERE [item_id] IS NOT NULL
			)
