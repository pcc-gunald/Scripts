   select CONVERT(decimal(10,2),(100-(avg(storage_space_used_mb/reserved_storage_mb*100.0)))) as storage_percentage_free,
    --CONVERT(INT,avg(storage_space_used_mb) / 1024) as storage_used_GB,
    CONVERT(INT,avg(reserved_storage_mb - storage_space_used_mb)) / 1024 as storage_free_GB,
    CONVERT(INT,avg(reserved_storage_mb) / 1024) as reserved_storage_GB,
    'storage_percentage_free:'+str(CONVERT(decimal(4,2),(100-(avg(storage_space_used_mb/reserved_storage_mb*100.0)))))+'%   storage_free:'+str(CONVERT(INT,avg(reserved_storage_mb - storage_space_used_mb)) / 1024)+'GB  reserved_storage:'+str(CONVERT(INT,avg(reserved_storage_mb)
     / 1024))+'GB'
    from (select * from master.sys.server_resource_stats
where start_time > dateadd(minute , -10, getutcdate()))t


--select CONVERT(decimal(10,2),avg((reserved_storage_mb - storage_space_used_mb)/reserved_storage_mb * 100.0)) as storage_percentage_free,
----CONVERT(INT,avg(storage_space_used_mb) / 1024) as storage_used_GB,
--CONVERT(INT,avg(reserved_storage_mb - storage_space_used_mb)) / 1024 as storage_free_GB,
--CONVERT(INT,avg(reserved_storage_mb) / 1024) as reserved_storage_GB
--from (select * from master.sys.server_resource_stats
--where start_time > dateadd(minute , -10, getutcdate())) t --275 more ---

 /*
storage_percentage_free	storage_free_GB	reserved_storage_GB
13.94	169	1216
*/
 /*
storage_percentage_free	storage_free_GB	reserved_storage_GB
14.69	178	1216
*/