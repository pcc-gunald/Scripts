--EI_FKViolation
select distinct c.cp_sec_user_audit_id,a.fac_id
from [test_usei740].dbo.pho_phys_order_audit a
inner join  [test_usei740].dbo.pho_phys_order_audit_useraudit b on  a.audit_id = b.audit_id
inner join [test_usei740].dbo.[cp_sec_user_audit] c on c.cp_sec_user_audit_id=b.created_by_audit_id
where c.fac_id not in(1,2,5)
and a.fac_id in (1,2,5)


select b.* from [pn_progress_note] a
inner join [sec_user] b on b.userid=a.created_by_userid
where 1=1
and  a.fac_id in (1,2,5)
and b.fac_id not in(1,2,5)


select * from pn_std_spn
where std_spn_id=203


select * from pn_std_spn_text
where section_id in(
select section_id from pn_template_section
where  template_id in(
10065,
10119)
)
and std_spn_id=203

section_id in(100317,
100318,
100319)

select * from pn_template
where description in(
'SKilled Nursing Notes',
'Change of Condition')