
--mergeExecuteExtractStep4 --> MergeError : Violation of PRIMARY KEY constraint 'as_std_question__stdAssessId_questionKey_CLPK'. Cannot insert duplicate key in object 'dbo.as_std_question'. The duplicate key value is (16006, Cust_C_3j).
-
;with temp as (
select 
concat(description, '_',std_assess_id) descr
,ROW_NUMBER() over(partition by description order by std_assess_id) rn
,count(1) over(partition by description )  cnt
from test_usei1077.[dbo].as_std_assessment 
) 
update temp
set description=descr
where rn>1
