

update [dbo].[cp_std_library]
set description=concat('ZION-',description)
where created_by ='EICase590131'
and description not like 'Zion%'

