select * into pcc_temp_storage.dbo._bkp_EICase59277183_Sec_role_Post_GL from Sec_role--259

select * into pcc_temp_storage.dbo._bkp_EICase59277183_sec_user_role_Post_GL from sec_user_role--100788
--Prod--100920

select * into pcc_temp_storage.dbo._bkp_EICase59277183_sec_role_function_Post_GL from sec_role_function--259491

select * from EICase59277183sec_role--125

Select * from EICase59277183sec_role
where corporate = 'N'--66
 

Select * into pcc_temp_storage.dbo._bkp_EICase59277183_sec_user_role_Post_GL_Before_Delete from sec_user_role
where role_id IN  (Select dst_id from EICase59277183sec_role where corporate = 'N' )--650

Delete from sec_user_role
--Select * from sec_user_role
where role_id IN  (Select dst_id from EICase59277183sec_role where corporate = 'N' )--650

--------------------------

Select * into pcc_temp_storage.dbo._bkp_EICase59277183_sec_role_function_Post_GL_Before_Delete from sec_role_function
where role_id IN  (Select dst_id from EICase59277183sec_role where corporate = 'N' )--98671

Delete from sec_role_function
--Select * from sec_role_function
where role_id IN  (Select dst_id from EICase59277183sec_role where corporate = 'N' )--98671
 
 --------------------------

 
Select * into pcc_temp_storage.dbo._bkp_EICase59277183_sec_role_Post_GL_Before_Delete  from sec_role
 where role_id IN  (Select dst_id from EICase59277183sec_role where corporate = 'N' )--66


Delete from sec_role
 where role_id IN  (Select dst_id from EICase59277183sec_role where corporate = 'N' )--66
