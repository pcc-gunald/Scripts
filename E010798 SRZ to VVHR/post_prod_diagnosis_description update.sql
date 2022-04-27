

Select * from common_code where item_code='drank'
and item_description in ('Diagnosis #4','Diagnosis #5','Diagnosis #6','Diagnosis #7','Diagnosis #8','Diagnosis #9','Diagnosis #10','Diagnosis #11','Diagnosis #12','Diagnosis #13')

and created_by='EICase01079812'

update test_usei9.dbo.common_code
set item_description='Retired-'+item_description
where item_code='drank'
and item_description in ('Diagnosis #4','Diagnosis #5','Diagnosis #6','Diagnosis #7','Diagnosis #8','Diagnosis #9','Diagnosis #10','Diagnosis #11','Diagnosis #12','Diagnosis #13')

and created_by='EICase01079812'

(10 rows affected)

Completion time: 2022-03-24T12:54:32.8766390-04:00
