
select * from mergelog
order by msgtime desc

select * from stagingmergelog
order by msgtime desc 

--Cannot insert duplicate key row in object 'dbo.prot_std_protocol_detail' with unique index 'prot_std_protocol_detail__protocolId_eventId_actionId_UIX'. The duplicate key value is (1, 1, 3).




--SELECT 
--*
--FROM pcc_staging_db58910.dbo.prot_std_protocol_detail a
--WHERE 1=1
--AND event_id=1 AND action_id IN(3,4)
--where exists (select 1 from test_usei1072.dbo.prot_std_protocol_detail b where b.protocol_id=a.protocol_id and  b.event_id=a.event_id and b.action_id=a.action_id)

--select * from test_usei1072.dbo.prot_std_protocol_detail 

update  mergeTablesMaster
set  queryfilter= CONCAT(queryfilter,' ', ' AND event_id=1 AND action_id IN(3,4)')
--select  *  from mergetablesmaster
where tablename = 'prot_std_protocol_detail'

select * from pcc_staging_db58910.dbo.mergeTablesMaster 
where tablename = 'prot_std_protocol_detail'
