UPDATE mergetablesmaster
SET QueryFilter = ' AND pick_list_id NOT IN (SELECT pick_list_id from [origDB].as_std_pick_list where std_assess_id = 3 AND fac_id = -1)
                    AND pick_list_id NOT IN (350) '
WHERE tablename = 'as_std_pick_list'

