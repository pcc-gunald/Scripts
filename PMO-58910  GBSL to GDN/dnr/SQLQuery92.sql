select * from inc_std_signing_authority a
inner join common_code b on b.item_id=a.position_id
where a.fac_id=59

select * from common_code
where item_description like 'Exe%'
or item_description like 'Health%' 

select * from common_code
where 1=1
and deleted='N'
and item_code='posit'

select * from INFORMATION_SCHEMA.COLUMNS
where column_name like '%hot%'

select * from ext_facilities
where fac_id=59

select * from dep_message

select distinct b.* from dbo.ext_facilities a
inner join dbo.emc_ext_facilities b on b.fac_id=a.fac_id
where a.fac_id=59
order by b.name

select * from dbo.emc_ext_facilities
where fac_id=59


select 
    t.name as TableWithForeignKey, 
    fk.constraint_column_id as FK_PartNo, c.
    name as ForeignKeyColumn 
from 
    sys.foreign_key_columns as fk
inner join 
    sys.tables as t on fk.parent_object_id = t.object_id
inner join 
    sys.columns as c on fk.parent_object_id = c.object_id and fk.parent_column_id = c.column_id
where 
    fk.referenced_object_id = (select object_id 
                               from sys.tables 
                               where name = 'ext_facilities')
order by 
    TableWithForeignKey, FK_PartNo