import json
from pathlib import Path

#Created by : Dinesh Gunapalan and Alexander Morcet
#Purpose : To create the mapping script from one place, instead of changing them 1 by 1.

file_name_list = [
'Mapping R1 Admin Payer All Residents.sql',
'Mapping R1 Admin Payer Current Residents Only.sql',
'Mapping R1 Admin Room Rate Type.sql',
'Mapping R1 Admin Status Code Action Code.sql',
'Mapping R1 Clinical Advanced.sql',
'Mapping R2 Admin Pick List.sql',
'Mapping R2 Admin Resident Identifier.sql',
'Mapping R2 Admin Upload Categories.sql',
'Mapping R2 Admin User Defined Data.sql',
'Mapping R2 Clinical Common Code.sql'
]


## Change the config variable file path
f = open("./config.json")

configData =json.load(f)


for file_name in file_name_list:
    file = Path('//STUSPAINFCIFS.pccprod.local/DS/Dataload/TS_FacAcqConfig/DataCopy_Scripts/EI_SCRIPTS/Pre_EI Scripts/Mapping Template Scripts/New/' + file_name)
    
    
    if file_name in(
        'Mapping R1 Admin Payer All Residents.sql',
        'Mapping R1 Admin Payer Current Residents Only.sql'):
        list_src_fac = configData['src_fac_ids'].split(',')
        list_dst_fac = configData['dst_fac_ids'].split(',')
        
        list_fac = zip(list_src_fac,list_dst_fac)
        
        if ((file_name == 'Mapping R1 Admin Payer All Residents.sql' and configData['current_residents_discharge_date'] == "") or (file_name == 'Mapping R1 Admin Payer Current Residents Only.sql' and configData['current_residents_discharge_date'] != "")):
            for x in list_fac:
                #file_name = files
                #print(x[0])
                #print(x[1])
                print(file_name)
                files_write =  open(configData['output_file_path'] + configData['pmo_number'] + ' ' +file_name[:len(file_name)-4] +' fac ' + x[0] + ' to ' + x[1] + '.sql','w')
                
                files_write.write(file.open().read().format(
                    src_fac_id = x[0]
                    ,dst_fac_id = x[1]
                    ,src_prod_server = configData['src_prod_server']
                    ,dst_prod_server = configData['dst_prod_server']
                    ,current_residents_discharge_date = configData['current_residents_discharge_date']
                    ))
                files_write.close()
                #for config in ConfigArray:
                #    print(config)
                #    print (config)
                #    files_write.write(file_content.format(config[0] = config[1]))

      
    else:
        print(file_name)
        files_write =  open(configData['output_file_path'] + configData['pmo_number'] + ' ' + file_name,'w')
        files_write.write(file.open().read().format(
            src_fac_ids = configData['src_fac_ids']
            ,dst_fac_ids = configData['dst_fac_ids']
            ,reg_ids = configData['reg_ids']
            ,src_prod_server = configData['src_prod_server']
            ,dst_prod_server = configData['dst_prod_server']
            ,current_residents_discharge_date = configData['current_residents_discharge_date']
            ,case_number_root = configData['case_number_root']
            ,src_test_server = configData['src_test_server']
            ,dst_test_server = configData['dst_test_server']
            ))
        files_write.close()
        #for config in ConfigArray:
        #    print(config)
        #    print (config)
       #    files_write.write(file_content.format(config[0] = config[1]))
    

    

    #print(files_read.read())

    #file_content = files_read.read()

    #print(file_content.format(src_fac_id,dst_fac_id,srcServer,dstServer,startdate,dst_regid,srcPrefix,CaseNumber,srcServer_test,dstServer_test))

    
    
    
    #files_read.close()
