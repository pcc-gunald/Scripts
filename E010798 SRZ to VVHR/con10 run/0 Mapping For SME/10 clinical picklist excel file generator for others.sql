DECLARE @SQL VARCHAR(MAX)
DECLARE @srcAllFacID VARCHAR(500)
DECLARE @SrcPROD VARCHAR(500)
DECLARE	@DstPROD VARCHAR(500)

set @srcAllFacID = '7,8'
set @SrcPROD = '[pccsql-use2-prod-w22-cli0006.4c4638f8e26f.database.windows.net].us_srz_multi'
set @DstPROD = '[pccsql-use2-prod-w20-cli0017.3055e0bc69f6.database.windows.net].us_vvhr'

IF OBJECT_ID('tempdb..#temp') IS NOT NULL 
DROP TABLE #temp

CREATE TABLE #temp
(
	id INT NOT NULL IDENTITY PRIMARY key,
	pick_list_name varchar(255),pick_list_key varchar(255),pick_list_scoping_fields varchar(255), --for all
	src_id varchar(255),src_desc varchar(255), -- for src
	Map_DstItemId varchar(255), -- for mapping
	dst_id varchar(255),dst_desc varchar(255) --for dst
)

set @SQL = '------------------------------------------ pho_administration_record ------------------------------------------ 

--select * from ' + @DstPROD +'.dbo.mergeTablesmaster where tablename = ''pho_administration_record''
--administration_record_type_id	description	short_description
		--E							S			S

--Column_name	Nullable
--administration_record_type_id	yes
--description	yes
--short_description	yes

SELECT 
	a.administration_record_id src_administration_record_id,
	ISNULL(a.description,''NULL'') + '' ( '' + ISNULL(a.short_description,''NULL'') + '' | '' + ISNULL(b.item_description,''NULL'') + '' ) '' as ''src_description (short_description | item_description)''
into #src1
FROM ' + @SrcPROD +'.dbo.pho_administration_record a 
JOIN ' + @SrcPROD +'.dbo.common_code b ON a.administration_record_type_id = b.item_id
WHERE a.deleted = ''N''
and (a.fac_id in (-1, ' + @srcAllFacID+') or a.reg_id in (select regional_id from  ' + @SrcPROD +'.dbo.facility where fac_id in (' + @srcAllFacID+')))
order by ''src_description (short_description | item_description)''

SELECT 
	a.administration_record_id dst_administration_record_id,
	CASE 
		WHEN a.fac_id = -1 THEN ISNULL(a.description,''NULL'') + '' ( '' + ISNULL(a.short_description,''NULL'') + '' | '' + ISNULL(b.item_description,''NULL'') + '' ) '' 
		WHEN a.fac_id <> -1 THEN 
			CASE
				WHEN a.reg_id IS NOT NULL AND a.reg_id in (select regional_id from ' + @DstPROD +'.dbo.regions )  THEN ISNULL(a.description,''NULL'') + '' ( '' + ISNULL(a.short_description,''NULL'') + '' | '' + ISNULL(b.item_description,''NULL'') + '' ) Scope : '' + r.short_desc + ''-Regional ''
				ELSE 
					CASE
						WHEN a.state_code IS NOT NULL OR a.state_code <> '''' THEN ISNULL(a.description,''NULL'') + '' ( '' + ISNULL(a.short_description,''NULL'') + '' | '' + ISNULL(b.item_description,''NULL'') + '' ) Scope : '' + a.state_code + '' state '' 
						WHEN a.state_code IS NULL OR a.state_code = '''' THEN ISNULL(a.description,''NULL'') + '' ( '' + ISNULL(a.short_description,''NULL'') + '' | '' + ISNULL(b.item_description,''NULL'') + '' ) Scope : '' + SUBSTRING(replace(f.name,''Case'',''''), CHARINDEX(''-'',replace(f.name,''Case'',''''))+1, LEN(replace(f.name,''Case'',''''))+1) + '' facility ''
					END 
			END
	END as ''dst_description (short_description | item_description)''
into #dst1
FROM ' + @DstPROD +'.dbo.pho_administration_record a 
JOIN ' + @DstPROD +'.dbo.common_code b ON a.administration_record_type_id = b.item_id
LEFT JOIN ' + @DstPROD +'.dbo.facility f on a.fac_id = f.fac_id
LEFT JOIN ' + @DstPROD +'.dbo.regions r on a.reg_id = r.regional_id 
WHERE a.deleted = ''N''
order by ''dst_description (short_description | item_description)''

select IDENTITY(INT, 0, 1) AS rownum,* into #src11 from #src1
where [src_description (short_description | item_description)] not in 
(select [dst_description (short_description | item_description)] from #dst1)
order by [src_description (short_description | item_description)]

select IDENTITY(INT, 0, 1) AS rownum,* into #dst11 from #dst1
where [dst_description (short_description | item_description)] not in 
(select [src_description (short_description | item_description)] from #src1)
order by [dst_description (short_description | item_description)]

DECLARE @count11 INT = 0 
DECLARE @count12 INT = 0

select @count11 = count(*) from #src11
select @count12 = count(*) from #dst11

IF @count11 > 0 AND @count12 > 0
INSERT INTO #temp
SELECT 
	''Administration Records'' pick_list_name,
	''administration_record_id'' pick_list_key,
	''Description (Short Desc | Style)'' as pick_list_scoping_fields,
	src.src_administration_record_id src_id,
	src.[src_description (short_description | item_description)] src_desc,
	'''' as Map_DstItemId,
	dst.dst_administration_record_id dst_id,
	dst.[dst_description (short_description | item_description)] dst_desc
FROM #src11 AS src FULL JOIN #dst11 AS dst ON src.rownum = dst.rownum

IF @count11 > 0 AND @count12 > 0
INSERT INTO #temp SELECT '''' pick_list_name,'''' pick_list_key,'''' pick_list_scoping_fields,'''' src_id,'''' src_desc,'''' as Map_DstItemId,'''' dst_id,'''' dst_desc

drop table #src1
drop table #dst1

drop table #src11
drop table #dst11

'EXEC (@SQL)
--PRINT @SQL

set @SQL = '----------------------------------------------- pho_order_type ------------------------------------------ 

--select * from ' + @DstPROD +'.dbo.mergeTablesmaster where tablename = ''pho_order_type''
--description	mandatory_end_date	order_category_id	administration_record_id
	--S				E					E					E

--Column_name	Nullable
--administration_record_id	yes

SELECT 
	a.order_type_id src_order_type_id,
	ISNULL(a.description,''NULL'') + '' ( '' + ISNULL(c.short_description,''NULL'') + '' | '' + ISNULL(b.category_desc,''NULL'') + '' | '' + ISNULL(a.mandatory_end_date,''NULL'')  + '' ) ''  as ''src_description (short_description | category_desc | mandatory_end_date)''
into #src2
FROM ' + @SrcPROD +'.dbo.pho_order_type a 
JOIN ' + @SrcPROD +'.dbo.pho_order_category b ON a.order_category_id = b.order_category_id
LEFT JOIN ' + @SrcPROD +'.dbo.pho_administration_record c ON a.administration_record_id = c.administration_record_id
WHERE a.deleted = ''N''
and (a.fac_id in (-1, ' + @srcAllFacID+') or a.reg_id in (select regional_id from  ' + @SrcPROD +'.dbo.facility where fac_id in (' + @srcAllFacID+')))
AND a.order_type_id IN (SELECT order_type_id FROM ' + @SrcPROD +'.[dbo].pho_phys_order WHERE fac_id in (-1,' + @srcAllFacID+')) 
order by ''src_description (short_description | category_desc | mandatory_end_date)''

SELECT 
	a.order_type_id dst_order_type_id,
	CASE 
		WHEN a.fac_id = -1 THEN ISNULL(a.description,''NULL'') + '' ( '' + ISNULL(c.short_description,''NULL'') + '' | '' + ISNULL(b.category_desc,''NULL'') + '' | '' + ISNULL(a.mandatory_end_date,''NULL'')  + '' ) '' 
		WHEN a.fac_id <> -1 THEN 
			CASE
				WHEN a.reg_id IS NOT NULL AND a.reg_id in (select regional_id from ' + @DstPROD +'.dbo.regions )  THEN ISNULL(a.description,''NULL'') + '' ( '' + ISNULL(c.short_description,''NULL'') + '' | '' + ISNULL(b.category_desc,''NULL'') + '' | '' + ISNULL(a.mandatory_end_date,''NULL'')  + '' ) Scope : '' + r.short_desc + ''-Regional ''
				ELSE
					CASE
						WHEN a.state_code IS NOT NULL OR a.state_code <> '''' THEN ISNULL(a.description,''NULL'') + '' ( '' + ISNULL(c.short_description,''NULL'') + '' | '' + ISNULL(b.category_desc,''NULL'') + '' | '' + ISNULL(a.mandatory_end_date,''NULL'')  + '' ) Scope : '' + a.state_code + '' state '' 
						WHEN a.state_code IS NULL OR a.state_code = '''' THEN ISNULL(a.description,''NULL'') + '' ( '' + ISNULL(c.short_description,''NULL'') + '' | '' + ISNULL(b.category_desc,''NULL'') + '' | '' + ISNULL(a.mandatory_end_date,''NULL'')  + '' ) Scope : '' + SUBSTRING(replace(f.name,''Case'',''''), CHARINDEX(''-'',replace(f.name,''Case'',''''))+1, LEN(replace(f.name,''Case'',''''))+1) + '' facility ''
					END 
			END
	END as ''dst_description (short_description | category_desc | mandatory_end_date)''
into #dst2
FROM ' + @DstPROD +'.dbo.pho_order_type a 
JOIN ' + @DstPROD +'.dbo.pho_order_category b ON a.order_category_id = b.order_category_id
LEFT JOIN ' + @DstPROD +'.dbo.pho_administration_record c ON a.administration_record_id = c.administration_record_id
LEFT JOIN ' + @DstPROD +'.dbo.facility f on a.fac_id = f.fac_id
LEFT JOIN ' + @DstPROD +'.dbo.regions r on a.reg_id = r.regional_id 
WHERE a.deleted = ''N''
order by ''dst_description (short_description | category_desc | mandatory_end_date)''

select IDENTITY(INT, 0, 1) AS rownum,* into #src40 from #src2
where [src_description (short_description | category_desc | mandatory_end_date)] not in 
(select [dst_description (short_description | category_desc | mandatory_end_date)] from #dst2)
order by [src_description (short_description | category_desc | mandatory_end_date)]

select IDENTITY(INT, 0, 1) AS rownum,* into #dst40 from #dst2
where [dst_description (short_description | category_desc | mandatory_end_date)] not in 
(select [src_description (short_description | category_desc | mandatory_end_date)] from #src2)
order by [dst_description (short_description | category_desc | mandatory_end_date)]

DECLARE @count21 INT = 0 
DECLARE @count40 INT = 0

select @count21 = count(*) from #src40
select @count40 = count(*) from #dst40

IF @count21 > 0 AND @count40 > 0
INSERT INTO #temp
SELECT 
	''Order Types'' pick_list_name,
	''order_type_id'' pick_list_key,
	''Description (Administration Record | Order Category | Mandatory End Date)'' as pick_list_scoping_fields,
	src.src_order_type_id src_id,
	src.[src_description (short_description | category_desc | mandatory_end_date)] src_desc,
	'''' as Map_DstItemId,
	dst.dst_order_type_id dst_id,
	dst.[dst_description (short_description | category_desc | mandatory_end_date)] dst_desc
FROM #src40 AS src FULL JOIN #dst40 AS dst ON src.rownum = dst.rownum

IF @count21 > 0 AND @count40 > 0
INSERT INTO #temp SELECT '''' pick_list_name,'''' pick_list_key,'''' pick_list_scoping_fields,'''' src_id,'''' src_desc,'''' as Map_DstItemId,'''' dst_id,'''' dst_desc

drop table #src2
drop table #dst2

drop table #src40
drop table #dst40

'EXEC (@SQL)
--PRINT @SQL

set @SQL = '------------------------------------------ pn_type ------------------------------------------ 

--select * from ' + @DstPROD +'.dbo.mergeTablesmaster where tablename = ''pn_type''
--description retired       template_id   system
       --S      E               E           E

--Column_name	Nullable
--retired	yes
--template_id	yes
--system	yes

SELECT 
	a.pn_type_id src_pn_type_id,
	ISNULL(a.description,''NULL'') + '' ( '' + ISNULL(b.description,''NULL'') + '' | '' + ISNULL(a.retired,''N'') + '' | '' + ISNULL(a.system,''~'') + '' ) '' as ''src_description (template_description | retired | system)''
into #src3
FROM ' + @SrcPROD +'.dbo.pn_type a 
JOIN ' + @SrcPROD +'.dbo.pn_template b ON a.template_id = b.template_id
WHERE a.deleted = ''N''
and (a.fac_id in (-1, ' + @srcAllFacID+') or a.reg_id in (select regional_id from  ' + @SrcPROD +'.dbo.facility where fac_id in (' + @srcAllFacID+')))
order by ''src_description (template_description | retired | system)''

SELECT 
	a.pn_type_id dst_pn_type_id,
	CASE 
		WHEN a.fac_id = -1 THEN ISNULL(a.description,''NULL'') + '' ( '' + ISNULL(b.description,''NULL'') + '' | '' + ISNULL(a.retired,''N'') + '' | '' + ISNULL(a.system,''~'') + '' ) '' 
		WHEN a.fac_id <> -1 THEN 
			CASE
				WHEN a.reg_id IS NOT NULL AND a.reg_id in (select regional_id from ' + @DstPROD +'.dbo.regions )  THEN ISNULL(a.description,''NULL'') + '' ( '' + ISNULL(b.description,''NULL'') + '' | '' + ISNULL(a.retired,''N'') + '' | '' + ISNULL(a.system,''~'') + '' ) Scope : '' + r.short_desc + ''-Regional ''
				ELSE 
					CASE
						WHEN a.state_code IS NOT NULL OR a.state_code <> '''' THEN ISNULL(a.description,''NULL'') + '' ( '' + ISNULL(b.description,''NULL'') + '' | '' + ISNULL(a.retired,''N'') + '' | '' + ISNULL(a.system,''~'') + '' ) Scope : '' + a.state_code + '' state '' 
						WHEN a.state_code IS NULL OR a.state_code = '''' THEN ISNULL(a.description,''NULL'') + '' ( '' + ISNULL(b.description,''NULL'') + '' | '' + ISNULL(a.retired,''N'') + '' | '' + ISNULL(a.system,''~'') + '' ) Scope : '' + SUBSTRING(replace(f.name,''Case'',''''), CHARINDEX(''-'',replace(f.name,''Case'',''''))+1, LEN(replace(f.name,''Case'',''''))+1) + '' facility ''
					END 
			END
	END as ''dst_description (template_description | retired | system)''
into #dst3
FROM ' + @DstPROD +'.dbo.pn_type a 
JOIN ' + @DstPROD +'.dbo.pn_template b ON a.template_id = b.template_id
LEFT JOIN ' + @DstPROD +'.dbo.facility f on a.fac_id = f.fac_id
LEFT JOIN ' + @DstPROD +'.dbo.regions r on a.reg_id = r.regional_id 
WHERE a.deleted = ''N''
order by ''dst_description (template_description | retired | system)''

select src_pn_type_id,replace([src_description (template_description | retired | system)],''~'',''NULL'') ''src_description (template_description | retired | system)'',
IDENTITY(INT, 0, 1) AS rownum into #src33 from #src3
where [src_description (template_description | retired | system)] not in 
(select [dst_description (template_description | retired | system)] from #dst3)
order by [src_description (template_description | retired | system)]

select dst_pn_type_id,replace([dst_description (template_description | retired | system)],''~'',''NULL'') as ''dst_description (template_description | retired | system)'',
IDENTITY(INT, 0, 1) AS rownum into #dst33 from #dst3
where [dst_description (template_description | retired | system)] not in 
(select [src_description (template_description | retired | system)] from #src3)
order by [dst_description (template_description | retired | system)]

DECLARE @count31 INT = 0 
DECLARE @count32 INT = 0

select @count31 = count(*) from #src33
select @count32 = count(*) from #dst33

IF @count31 > 0 AND @count32 > 0
INSERT INTO #temp
SELECT 
	''Progress Note Types'' pick_list_name,
	''pn_type_id'' pick_list_key,
	''Description (Template | Retired | System)'' as pick_list_scoping_fields,
	src.src_pn_type_id src_id,
	src.[src_description (template_description | retired | system)] src_desc,
	'''' as Map_DstItemId,
	dst.dst_pn_type_id dst_id,
	dst.[dst_description (template_description | retired | system)] dst_desc
FROM #src33 AS src FULL JOIN #dst33 AS dst ON src.rownum = dst.rownum

IF @count31 > 0 AND @count32 > 0
INSERT INTO #temp SELECT '''' pick_list_name,'''' pick_list_key,'''' pick_list_scoping_fields,'''' src_id,'''' src_desc,'''' as Map_DstItemId,'''' dst_id,'''' dst_desc

drop table #src3
drop table #dst3

drop table #src33
drop table #dst33

'EXEC (@SQL)
--PRINT @SQL

set @SQL = '------------------------------------------ cr_std_immunization ------------------------------------------ 

--select * from ' + @DstPROD +'.dbo.mergeTablesmaster where tablename = ''cr_std_immunization''
--description track_results multi_step    short_description
       --S           E         E                   S

--Column_name	Nullable
--track_results	yes
--multi_step	yes
--short_description	yes

SELECT
	a.std_immunization_id src_std_immunization_id, 
	ISNULL(a.description,''NULL'') + '' ( '' + CASE WHEN ISNULL(a.short_description,''NULL'') IS NULL THEN ''NULL, '' ELSE ISNULL(a.short_description,''NULL'') + '' | '' END + ISNULL(a.track_results,''NULL'') + '' | '' + ISNULL(a.multi_step,''NULL'') + '' ) '' as ''src_description (short_description | track_results | multi_step)''
into #src4
FROM ' + @SrcPROD +'.dbo.cr_std_immunization a 
WHERE a.deleted = ''N''
and (a.fac_id in (-1, ' + @srcAllFacID+') or a.reg_id in (select regional_id from  ' + @SrcPROD +'.dbo.facility where fac_id in (' + @srcAllFacID+')))
order by ''src_description (short_description | track_results | multi_step)''

SELECT
	a.std_immunization_id dst_std_immunization_id, 
	CASE 
		WHEN a.fac_id = -1 THEN ISNULL(a.description,''NULL'') + '' ( '' + CASE WHEN ISNULL(a.short_description,''NULL'') IS NULL THEN ''NULL, '' ELSE ISNULL(a.short_description,''NULL'') + '' | '' END + ISNULL(a.track_results,''NULL'') + '' | '' + ISNULL(a.multi_step,''NULL'') + '' ) '' 
		WHEN a.fac_id <> -1 THEN 
			CASE
				WHEN a.reg_id IS NOT NULL AND a.reg_id in (select regional_id from ' + @DstPROD +'.dbo.regions )  THEN ISNULL(a.description,''NULL'') + '' ( '' + CASE WHEN ISNULL(a.short_description,''NULL'') IS NULL THEN ''NULL, '' ELSE ISNULL(a.short_description,''NULL'') + '' | '' END + ISNULL(a.track_results,''NULL'') + '' | '' + ISNULL(a.multi_step,''NULL'') + '' ) Scope : '' + r.short_desc + ''-Regional ''
				ELSE 
					CASE
						WHEN a.state_code IS NOT NULL OR a.state_code <> '''' THEN ISNULL(a.description,''NULL'') + '' ( '' + CASE WHEN ISNULL(a.short_description,''NULL'') IS NULL THEN ''NULL, '' ELSE ISNULL(a.short_description,''NULL'') + '' | '' END + ISNULL(a.track_results,''NULL'') + '' | '' + ISNULL(a.multi_step,''NULL'') + '' ) Scope : '' + a.state_code + '' state '' 
						WHEN a.state_code IS NULL OR a.state_code = '''' THEN ISNULL(a.description,''NULL'') + '' ( '' + CASE WHEN ISNULL(a.short_description,''NULL'') IS NULL THEN ''NULL, '' ELSE ISNULL(a.short_description,''NULL'') + '' | '' END + ISNULL(a.track_results,''NULL'') + '' | '' + ISNULL(a.multi_step,''NULL'') + '' ) Scope : '' + SUBSTRING(replace(f.name,''Case'',''''), CHARINDEX(''-'',replace(f.name,''Case'',''''))+1, LEN(replace(f.name,''Case'',''''))+1) + '' facility ''
					END 
			END
	END as ''dst_description (short_description | track_results | multi_step)''
into #dst4
FROM ' + @DstPROD +'.dbo.cr_std_immunization a 
LEFT JOIN ' + @DstPROD +'.dbo.facility f on a.fac_id = f.fac_id
LEFT JOIN ' + @DstPROD +'.dbo.regions r on a.reg_id = r.regional_id 
WHERE a.deleted = ''N''
order by ''dst_description (short_description | track_results | multi_step)''

select IDENTITY(INT, 0, 1) AS rownum,* into #src44 from #src4
where [src_description (short_description | track_results | multi_step)] not in 
(select [dst_description (short_description | track_results | multi_step)] from #dst4)
order by [src_description (short_description | track_results | multi_step)]

select IDENTITY(INT, 0, 1) AS rownum,* into #dst44 from #dst4
where [dst_description (short_description | track_results | multi_step)] not in 
(select [src_description (short_description | track_results | multi_step)] from #src4)
order by [dst_description (short_description | track_results | multi_step)]

DECLARE @count41 INT = 0 
DECLARE @count42 INT = 0

select @count41 = count(*) from #src44
select @count42 = count(*) from #dst44

IF @count41 > 0 AND @count42 > 0
INSERT INTO #temp
SELECT 
	''Immunizations'' pick_list_name,
	''std_immunization_id'' pick_list_key,
	''Description (Short Desc | Track Results | Multi Step)'' as pick_list_scoping_fields,
	src.src_std_immunization_id src_id,
	src.[src_description (short_description | track_results | multi_step)] src_desc,
	'''' as Map_DstItemId,
	dst.dst_std_immunization_id dst_id,
	dst.[dst_description (short_description | track_results | multi_step)] dst_desc
FROM #src44 AS src FULL JOIN #dst44 AS dst ON src.rownum = dst.rownum

IF @count41 > 0 AND @count42 > 0
INSERT INTO #temp SELECT '''' pick_list_name,'''' pick_list_key,'''' pick_list_scoping_fields,'''' src_id,'''' src_desc,'''' as Map_DstItemId,'''' dst_id,'''' dst_desc

drop table #src4
drop table #dst4

drop table #src44
drop table #dst44

'EXEC (@SQL)
--PRINT @SQL

set @SQL = '------------------------------------------ cp_std_shift ------------------------------------------ 

--select * from ' + @DstPROD +'.dbo.mergeTablesmaster where tablename = ''cp_std_shift''
--description start_time    end_time
       --S         E            E
	   
--Column_name	Nullable
--start_time	yes
--end_time	yes

SELECT
	a.std_shift_id src_std_shift_id, 
	start_time,
	end_time,
	ISNULL(a.description,''NULL'') + '' ( '' + ISNULL(start_time,''NULL'') + '' | '' + ISNULL(end_time,''NULL'') + '' ) '' as ''src_description (start_time | end_time)''
into #src5
FROM ' + @SrcPROD +'.dbo.cp_std_shift a 
WHERE a.deleted = ''N''
and (a.fac_id in (-1, ' + @srcAllFacID+') or a.reg_id in (select regional_id from  ' + @SrcPROD +'.dbo.facility where fac_id in (' + @srcAllFacID+')))
order by start_time,end_time,[src_description (start_time | end_time)]

SELECT
	a.std_shift_id dst_std_shift_id, 
	start_time,
	end_time,
	CASE 
		WHEN a.fac_id = -1 THEN ISNULL(a.description,''NULL'') + '' ( '' + ISNULL(start_time,''NULL'') + '' | '' + ISNULL(end_time,''NULL'') + '' ) '' 
		WHEN a.fac_id <> -1 THEN 
			CASE
				WHEN a.reg_id IS NOT NULL AND a.reg_id in (select regional_id from ' + @DstPROD +'.dbo.regions )  THEN ISNULL(a.description,''NULL'') + '' ( '' + ISNULL(start_time,''NULL'') + '' | '' + ISNULL(end_time,''NULL'') + '' ) Scope : '' + r.short_desc + ''-Regional ''
				ELSE 
					CASE
						WHEN a.state_code IS NOT NULL OR a.state_code <> '''' THEN ISNULL(a.description,''NULL'') + '' ( '' + ISNULL(start_time,''NULL'') + '' | '' + ISNULL(end_time,''NULL'') + '' state '' 
						WHEN a.state_code IS NULL OR a.state_code = '''' THEN ISNULL(a.description,''NULL'') + '' ( '' + ISNULL(start_time,''NULL'') + '' | '' + ISNULL(end_time,''NULL'') + '' ) Scope : '' + SUBSTRING(replace(f.name,''Case'',''''), CHARINDEX(''-'',replace(f.name,''Case'',''''))+1, LEN(replace(f.name,''Case'',''''))+1) + '' facility ''
					END 
			END
	END as ''dst_description (start_time | end_time)''
into #dst5
FROM ' + @DstPROD +'.dbo.cp_std_shift a 
LEFT JOIN ' + @DstPROD +'.dbo.facility f on a.fac_id = f.fac_id
LEFT JOIN ' + @DstPROD +'.dbo.regions r on a.reg_id = r.regional_id 
WHERE a.deleted = ''N''
order by start_time,end_time,[dst_description (start_time | end_time)]

select IDENTITY(INT, 0, 1) AS rownum,* into #src55 from #src5
where [src_description (start_time | end_time)] not in 
(select [dst_description (start_time | end_time)] from #dst5)
order by start_time,end_time,[src_description (start_time | end_time)]

select IDENTITY(INT, 0, 1) AS rownum,* into #dst55 from #dst5
where [dst_description (start_time | end_time)] not in 
(select [src_description (start_time | end_time)] from #src5)
order by start_time,end_time,[dst_description (start_time | end_time)]

DECLARE @count51 INT = 0 
DECLARE @count52 INT = 0

select @count51 = count(*) from #src55
select @count52 = count(*) from #dst55

IF @count51 > 0 AND @count52 > 0
INSERT INTO #temp
SELECT 
	''Standard Shifts'' pick_list_name,
	''std_shift_id'' pick_list_key,
	''Description (Start Time | End Time)'' as pick_list_scoping_fields,
	src.src_std_shift_id src_id,
	src.[src_description (start_time | end_time)] src_desc,
	'''' as Map_DstItemId,
	dst.dst_std_shift_id dst_id,
	dst.[dst_description (start_time | end_time)] dst_desc
FROM #src55 AS src FULL JOIN #dst55 AS dst ON src.rownum = dst.rownum

IF @count51 > 0 AND @count52 > 0
INSERT INTO #temp SELECT '''' pick_list_name,'''' pick_list_key,'''' pick_list_scoping_fields,'''' src_id,'''' src_desc,'''' as Map_DstItemId,'''' dst_id,'''' dst_desc

drop table #src5
drop table #dst5

drop table #src55
drop table #dst55

'EXEC (@SQL)
--PRINT @SQL

set @SQL = '------------------------------------------ inc_std_pick_list_item ------------------------------------------ 

--select * from ' + @DstPROD +'.dbo.mergeTablesmaster where tablename = ''inc_std_pick_list_item''
--description system_flag   pick_list_id
       --S        E              E

--Column_name	Nullable
--description	yes

SELECT 
	a.pick_list_item_id src_pick_list_item_id,
	ISNULL(a.description,''NULL'') desc1,
	ISNULL(b.description,''NULL'') desc2,
	ISNULL(a.description,''NULL'') + '' ( '' + ISNULL(b.description,''NULL'') + '' | '' + a.system_flag + '' ) '' as ''src_description (pick_list_description | system_flag)''
into #src6
FROM ' + @SrcPROD +'.dbo.inc_std_pick_list_item a 
JOIN ' + @SrcPROD +'.dbo.inc_std_pick_list b ON a.pick_list_id = b.pick_list_id
--WHERE a.deleted = ''N'' --deleted field unavailable 
WHERE (a.fac_id in (-1, ' + @srcAllFacID+') or a.reg_id in (select regional_id from  ' + @SrcPROD +'.dbo.facility where fac_id in (' + @srcAllFacID+')))
order by ISNULL(b.description,''NULL''),ISNULL(a.description,''NULL'')

SELECT 
	a.pick_list_item_id dst_pick_list_item_id,
	ISNULL(a.description,''NULL'') desc1,
	ISNULL(b.description,''NULL'') desc2,
	CASE 
		WHEN a.fac_id = -1 THEN ISNULL(a.description,''NULL'') + '' ( '' + ISNULL(b.description,''NULL'') + '' | '' + a.system_flag + '' ) '' 
		WHEN a.fac_id <> -1 THEN 
			CASE
				WHEN a.reg_id IS NOT NULL AND a.reg_id in (select regional_id from ' + @DstPROD +'.dbo.regions )  THEN ISNULL(a.description,''NULL'') + '' ( '' + ISNULL(b.description,''NULL'') + '' | '' + a.system_flag + '' ) Scope : '' + r.short_desc + ''-Regional ''
				ELSE 
					CASE
						WHEN a.state_code IS NOT NULL OR a.state_code <> '''' THEN ISNULL(a.description,''NULL'') + '' ( '' + ISNULL(b.description,''NULL'') + '' | '' + a.system_flag + '' ) Scope : '' + a.state_code + '' state '' 
						WHEN a.state_code IS NULL OR a.state_code = '''' THEN ISNULL(a.description,''NULL'') + '' ( '' + ISNULL(b.description,''NULL'') + '' | '' + a.system_flag + '' ) Scope : '' + SUBSTRING(replace(f.name,''Case'',''''), CHARINDEX(''-'',replace(f.name,''Case'',''''))+1, LEN(replace(f.name,''Case'',''''))+1) + '' facility ''
					END 
			END
	END as ''dst_description (pick_list_description | system_flag)''
into #dst6
FROM ' + @DstPROD +'.dbo.inc_std_pick_list_item a 
JOIN ' + @DstPROD +'.dbo.inc_std_pick_list b ON a.pick_list_id = b.pick_list_id
LEFT JOIN ' + @DstPROD +'.dbo.facility f on a.fac_id = f.fac_id
LEFT JOIN ' + @DstPROD +'.dbo.regions r on a.reg_id = r.regional_id 
--WHERE a.deleted = ''N'' --deleted field unavailable 
order by ISNULL(b.description,''NULL''),ISNULL(a.description,''NULL'')

select IDENTITY(INT, 0, 1) AS rownum,* into #src66 from #src6
where [src_description (pick_list_description | system_flag)] not in 
(select [dst_description (pick_list_description | system_flag)] from #dst6)
order by desc2,desc1

select IDENTITY(INT, 0, 1) AS rownum,* into #dst66 from #dst6
where [dst_description (pick_list_description | system_flag)] not in 
(select [src_description (pick_list_description | system_flag)] from #src6)
order by desc2,desc1

DECLARE @count61 INT = 0 
DECLARE @count62 INT = 0

select @count61 = count(*) from #src66
select @count62 = count(*) from #dst66

IF @count61 > 0 AND @count62 > 0
INSERT INTO #temp
SELECT 
	''Risk Management Picklists'' pick_list_name,
	''pick_list_item_id'' pick_list_key,
	''Picklist Item Description (Standard Incident Picklist | System)'' as pick_list_scoping_fields,
	src.src_pick_list_item_id src_id,
	src.[src_description (pick_list_description | system_flag)] src_desc,
	'''' as Map_DstItemId,
	dst.dst_pick_list_item_id dst_id,
	dst.[dst_description (pick_list_description | system_flag)] dst_desc
FROM #src66 AS src FULL JOIN #dst66 AS dst ON src.rownum = dst.rownum

IF @count61 > 0 AND @count62 > 0
INSERT INTO #temp SELECT '''' pick_list_name,'''' pick_list_key,'''' pick_list_scoping_fields,'''' src_id,'''' src_desc,'''' as Map_DstItemId,'''' dst_id,'''' dst_desc

drop table #src6
drop table #dst6

drop table #src66
drop table #dst66

------------------------------------------------------------------

SELECT id
	,pick_list_name
	,ISNULL(src_id, '''') src_id
	,ISNULL(src_desc, '''') src_desc
	,Map_DstItemId
	,ISNULL(dst_id, '''') dst_id
	,ISNULL(dst_desc, '''') dst_desc
	,REPLACE(pick_list_scoping_fields, '','', '' | '') pick_list_scoping_fields 
FROM #temp
ORDER BY id'

EXEC (@SQL)
--PRINT @SQL
--SELECT DATALENGTH(@sql)
--EXEC (@SQL)