
select * into pcc_temp_storage.dbo.bkp_EICase59277183_diagnosis_PostGL from diagnosis--2709081--prod--2712430
select * into pcc_temp_storage.dbo.bkp_EICase59277183_common_codeGL from common_code--3367

select * into pcc_temp_storage.dbo.bkp_EICase59277183_diagnosis_audit_PostGL from diagnosis_audit--3707746

select *  from EICase59277183common_code
where src_id In  (10114,10116,10118,10153,10155)


Select * from common_code
where item_id In  (66631,66632,66633,66646,66647)

Select * from common_code
where item_id In  (501,9609,19799,34735,34736)




/*
SRC ID	SRC_Description	DST_ID	DST_Description
10114	Secondary Diagnosis (4)	501	A
10116	Secondary Diagnosis (5)	9609	B
10118	Secondary Diagnosis (6)	19799	C
10153	Secondary Diagnosis (20)	34735	O
10155	Secondary Diagnosis (21)	34736	P


*/

Select * from diagnosis
where rank_id = 66631 --1026

Select * from diagnosis_audit
where rank_id = 66631 --859



Select * from EICase59277183diagnosis a inner join diagnosis b
on a.dst_id = b.client_diagnosis_id
where b.rank_id = 66631
and a.corporate = 'N'--1026


Select * from EICase59277183diagnosis_audit a inner join diagnosis_audit b
on a.dst_id = b.audit_id
where b.rank_id = 66631
and a.corporate = 'N'--859

Update b
Set b.rank_id = 501
 from EICase59277183diagnosis_audit a inner join diagnosis_audit b
on a.dst_id = b.audit_id
where b.rank_id = 66631
and a.corporate = 'N'--859

Update b
Set b.rank_id = 501
 from EICase59277183diagnosis a inner join diagnosis b
on a.dst_id = b.client_diagnosis_id
where b.rank_id = 66631
and a.corporate = 'N'--1026

---------------------------------------------------------------------
---------------------------------------------------------------------

Select * from diagnosis
where rank_id = 10116 --0

Select * from diagnosis_audit
where rank_id = 10116 --0



Select * from EICase59277183diagnosis a inner join diagnosis b
on a.dst_id = b.client_diagnosis_id
where b.rank_id = 10116
and a.corporate = 'N'--0


Select * from EICase59277183diagnosis_audit a inner join diagnosis_audit b
on a.dst_id = b.audit_id
where b.rank_id = 10116
and a.corporate = 'N'--0

Update b
Set b.rank_id = 9609
 from EICase59277183diagnosis_audit a inner join diagnosis_audit b
on a.dst_id = b.audit_id
where b.rank_id = 10116
and a.corporate = 'N'--859

Update b
Set b.rank_id = 9609
 from EICase59277183diagnosis a inner join diagnosis b
on a.dst_id = b.client_diagnosis_id
where b.rank_id = 10116
and a.corporate = 'N'--0

---------------------------------------------------------------------
---------------------------------------------------------------------

Select * from diagnosis
where rank_id = 10118 --0

Select * from diagnosis_audit
where rank_id = 10118 --0



Select * from EICase59277183diagnosis a inner join diagnosis b
on a.dst_id = b.client_diagnosis_id
where b.rank_id = 10118
and a.corporate = 'N'--0


Select * from EICase59277183diagnosis_audit a inner join diagnosis_audit b
on a.dst_id = b.audit_id
where b.rank_id = 10118
and a.corporate = 'N'--0

Update b
Set b.rank_id = 19799
 from EICase59277183diagnosis_audit a inner join diagnosis_audit b
on a.dst_id = b.audit_id
where b.rank_id = 10118
and a.corporate = 'N'--859

Update b
Set b.rank_id = 19799
 from EICase59277183diagnosis a inner join diagnosis b
on a.dst_id = b.client_diagnosis_id
where b.rank_id = 10118
and a.corporate = 'N'--0

---------------------------------------------------------------------
---------------------------------------------------------------------

Select * from diagnosis
where rank_id = 10153 --0

Select * from diagnosis_audit
where rank_id = 10153 --0



Select * from EICase59277183diagnosis a inner join diagnosis b
on a.dst_id = b.client_diagnosis_id
where b.rank_id = 10153
and a.corporate = 'N'--0


Select * from EICase59277183diagnosis_audit a inner join diagnosis_audit b
on a.dst_id = b.audit_id
where b.rank_id = 10153
and a.corporate = 'N'--0

Update b
Set b.rank_id = 34735
 from EICase59277183diagnosis_audit a inner join diagnosis_audit b
on a.dst_id = b.audit_id
where b.rank_id = 10153
and a.corporate = 'N'--859

Update b
Set b.rank_id = 34735
 from EICase59277183diagnosis a inner join diagnosis b
on a.dst_id = b.client_diagnosis_id
where b.rank_id = 10153
and a.corporate = 'N'--0

---------------------------------------------------------------------
---------------------------------------------------------------------

Select * from diagnosis
where rank_id = 10155 --0

Select * from diagnosis_audit
where rank_id = 10155 --0



Select * from EICase59277183diagnosis a inner join diagnosis b
on a.dst_id = b.client_diagnosis_id
where b.rank_id = 10155
and a.corporate = 'N'--0


Select * from EICase59277183diagnosis_audit a inner join diagnosis_audit b
on a.dst_id = b.audit_id
where b.rank_id = 10155
and a.corporate = 'N'--0

Update b
Set b.rank_id = 34736
 from EICase59277183diagnosis_audit a inner join diagnosis_audit b
on a.dst_id = b.audit_id
where b.rank_id = 10155
and a.corporate = 'N'--859

Update b
Set b.rank_id = 34736
 from EICase59277183diagnosis a inner join diagnosis b
on a.dst_id = b.client_diagnosis_id
where b.rank_id = 10155
and a.corporate = 'N'--0


Update common_code
Set deleted = 'Y', DELETED_BY = 'EICASE59277183', DELETED_DATE = Getdate()
where item_id In  (66631,66632,66633,66646,66647)