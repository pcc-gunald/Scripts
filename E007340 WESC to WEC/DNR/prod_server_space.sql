-- connect to production server 

select @@servername,db_name()
SELECT CONVERT(DECIMAL(10, 2), (100 - (avg(storage_space_used_mb / reserved_storage_mb * 100.0)))) AS storage_percentage_free
	,CONVERT(INT, avg(reserved_storage_mb - storage_space_used_mb)) / 1024 AS storage_free_GB
	,CONVERT(INT, avg(reserved_storage_mb) / 1024) AS reserved_storage_GB
	,'storage_percentage_free:' + str(CONVERT(DECIMAL(4, 2), (100 - (avg(storage_space_used_mb / reserved_storage_mb * 100.0))))) + '%   storage_free:' + str(CONVERT(INT, avg(reserved_storage_mb - storage_space_used_mb)) / 1024) + 'GB  reserved_storage:' + str(CONVERT(INT, avg(reserved_storage_mb) / 1024)) + 'GB'
FROM (
	SELECT *
	FROM master.sys.server_resource_stats
	WHERE start_time > dateadd(minute, - 10, getutcdate())
	) t

/* -- copy the last column into 
storage_percentage_free: 17%   storage_free: 302GB  reserved_storage: 1760GB

*/
