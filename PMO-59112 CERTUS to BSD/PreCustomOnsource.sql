
SET QUOTED_IDENTIFIER ON;
SET CONTEXT_INFO 0xDC1000000; 
SET DEADLOCK_PRIORITY 4;

print  CHAR(13) + ' prefix sec_roles (only if requested specially)' 

update sec_role
set description='*VENDOR RO(LIMITED)+ADT+UPLOAD'
where description='SKLD-*VENDOR RO(LIMITED)+ADT+UPLOAD'

update sec_role 
set description = 'SBRN-' + description 
--select * 
from sec_role 
where (system_field <> 'Y' or system_field is null)
and description not like 'SBRN%'



-- truncate error
update dbo.pho_std_order 
set template_description='Pneumococcal vaccine upon admission to the center unless it has already been received/is medicall'
where std_order_id=101112

---pho_std_order_set__setDescription_UIX The duplicate key value is (Cardiac Program(select only those that apply)_).
DROP TABLE IF EXISTS #Temp_order
SELECT src.std_order_set_id,src.set_description ,src.set_description + '__' NEW_set_description
INTO #Temp_order
FROM dbo.pho_std_order_set src
JOIN [pccsql-use2-prod-w22-cli0005.4c4638f8e26f.database.windows.net].[us_bsd_multi].dbo.pho_std_order_set dst ON src.set_description=dst.set_description
WHERE src.fac_id IN (
		- 1
		,12
		)
AND EXISTS (SELECT 1 FROM dbo.pho_std_order_set  A WHERE A.set_description=CONCAT(src.set_description,'_'))

--SELECT b.*
UPDATE B
SET set_description=NEW_set_description
FROM #Temp_order  A
INNER JOIN  dbo.pho_std_order_set B ON B.std_order_set_id=A.std_order_set_id