use test_NSPR
go

--run this for each facility if doing more than 1 fac
update dst
set enabled = 'N'
--select dst.userid, dst.fac_id, dst.loginname, src.userid, src.fac_id,src.loginname, src.admin_user_type
--select dst.*
from sec_user dst
join EIcase01079812sec_user m --sec_user mapping table
on dst.userid = m.dst_id
join [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi.[dbo].sec_user src --source DB
on src.userid = m.src_id
where (src.admin_user_type <> 'E' or src.admin_user_type is NULL) --
and not exists (select 1 from [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi.[dbo].sec_user_facility f 
				where src.userid = f.userid and f.facility_id = 40)--src fac--0
and dst.enabled = 'Y'
and src.fac_id not in (40)


--(1 row affected)

--Completion time: 2021-12-14T11:04:30.7575688-05:00

update dst
set fac_id = lm.dstFacID
--select dst.userid, dst.fac_id, dst.loginname, src.userid, src.fac_id,src.loginname, src.admin_user_type, lm.srcFacID, lm.dstFacID
--select dst.*
from sec_user dst
join EIcase01079812sec_user m --sec_user mapping table
on dst.userid = m.dst_id
join [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi.[dbo].sec_user src  with (nolock)--source DB
on src.userid = m.src_id
join [vmuspassvtsjob1.pccprod.local].ds_merge_master.dbo.LoadEIMaster_New_Multi_Fac lm
on PMO_number = '010798' and lm.srcFacID = src.fac_id
where (src.admin_user_type <> 'E' or src.admin_user_type is NULL) 
and not exists 
(select 1 from [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi.[dbo].sec_user_facility f with (nolock)
where src.userid = f.userid and f.facility_id = 40)
and src.fac_id <> 40


--(0 rows affected)

--Completion time: 2021-12-14T11:04:49.611583-05:00

Select * from facility


select * from sec_user where loginname like '%GULF'
and fac_id in (216,217,218,219,220,221)

Select * from sec_user where loginname='ADudley'

Select * from sec_user where loginname='ADudleyGULF'

SELECT src.long_username AS GULF
     , src.loginname+'GULF'  AS [New Login in NSPR ]
     
     , dst.loginname AS [Existing Login in NSPR ]
FROM [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi.dbo.sec_user AS src
    INNER JOIN sec_user AS dst ON src.loginname = dst.loginname+'GULF'
WHERE dst.loginname like '%GULF'
and dst.fac_id in (216,217,218,219,220,221)
--@PmO010798!NSPR

select distinct src.long_username AS [Username in GULF]
     , dst.loginname AS [Existing Login in GULF]
	 , dst.loginname + 'GULF' AS [New Login in NSPR]
	 , dst.long_username AS [Existing Username in NSPR]
     , dst.loginname AS [Existing Login in NSPR]
from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.sec_user src
JOIN [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.sec_user dst ON src.loginname = dst.loginname + 'GULF'

SELECT src.long_username AS [Username in GULF]
     , src.loginname + 'GULF' AS [New Login in NSPR]
     , dst.long_username AS [Existing Username in NSPR]
     , dst.loginname AS [Existing Login in NSPR]
FROM [pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi.dbo.sec_user AS src
    INNER JOIN sec_user AS dst ON src.loginname = dst.loginname
WHERE src.userid IN (SELECT userid FROM pcc_temp_storage.dbo.EIcase01079812_NSPR_sec_user_samelogin_different_name)
--(2 row(s) affected)


--if sec regular import
select distinct src.long_username AS [Username in SRZ]
     , dst.loginname AS [Existing Login in SRZ]
	 , dst.loginname + 'SRZ' AS [New Login in VVHR]
	 , dst.long_username AS [Existing Username in VVHR]
     , dst.loginname AS [Existing Login in VVHR]
from [pccsql-use2-prod-ssv-tscon14.b4ea653240a9.database.windows.net].test_usei1188.dbo.sec_user src
JOIN [pccsql-use2-prod-ssv-tscon13.b4ea653240a9.database.windows.net].test_usei9.dbo.sec_user dst ON src.loginname = dst.loginname + 'SRZ'

--password for the excel file--E#010798@VVHR

/*
Test


(2 rows affected)

(0 rows affected)

(0 rows affected)

(0 rows affected)

(1 row affected)

(0 rows affected)

(0 rows affected)

(0 rows affected)

(1 row affected)

(0 rows affected)

(0 rows affected)

(0 rows affected)

 

Completion time: 2021-10-1T17:40:51.726074-04:00



*/




/*
Go live



(2 rows affected)

(0 rows affected)

(0 rows affected)

(0 rows affected)

(1 row affected)

(0 rows affected)

(0 rows affected)

(0 rows affected)

(2 rows affected)

(0 rows affected)

(0 rows affected)

(0 rows affected)

Completion time: 2021-11-40T16:07:47.159799-05:00


*/
