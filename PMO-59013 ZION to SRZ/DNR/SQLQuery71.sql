	select * from [test_usei86].dbo.common_code A
	where item_code='drank'
	and created_by like 'EICase59013%'
	and created_date>'01-04-2022'
	and deleted='N'

	update A
	set deleted='Y'
	from [test_usei86].dbo.common_code A
	where item_code='drank'
	and created_by like 'EICase59013%'
	and created_date>'01-04-2022'
	and deleted='N'


	update A
	set deleted='N'
	from [test_usei86].dbo.common_code A
	where item_code='drank'
	and created_by like 'EICase59013%'
	and created_date>'01-04-2022'
	and deleted='Y'