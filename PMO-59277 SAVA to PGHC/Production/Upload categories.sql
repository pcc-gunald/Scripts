/*
select * from EICase59277183upload_categories
where src_id = 103


Select * from upload_categories
Where cat_id = 2934


Select * from upload_categories
Where cat_id = 1574


*/

select * from mergeJoinsMaster
where parenttable = 'upload_categories'


Select * from MergeLog
where msg like '%upload_categories%'
order by 1 

Select * from upload_categories_domain

/*

upload_files
upload_files_deleted
scrm_attachment
dcm_document_template_upload_category_mapping
dcm_document_upload_category_mapping
upload_categories_domain
devprg_hist_document_landing
*/