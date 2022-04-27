select a.template_description, b.template_description, * from pho_std_order a
join pho_std_order b on a.template_description = b.template_description + '_'

select a.template_description, b.template_description, c.template_description, * from pho_std_order a
join [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1062.dbo.pho_std_order b on a.template_description = b.template_description
left join pho_std_order c on a.template_description + '_' = c.template_description 


SELECT src.*,CONCAT(src.template_description,'-')
UPDATE SRC
SET template_description=CONCAT(src.template_description,'-')
select *
FROM dbo.pho_std_order src
JOIN [pccsql-use2-prod-ssv-tscon10.b4ea653240a9.database.windows.net].test_usei1062.dbo.pho_std_order dst ON src.template_description = dst.template_description
WHERE src.fac_id IN (
- 1
,2
)
AND (
src.STATUS <> dst.STATUS
OR dst.fac_id <> - 1
)
AND EXISTS (SELECT 1 FROM dbo.pho_std_order A WHERE A.template_description+'-'=src.template_description
AND A.for_mobile=src.for_mobile)