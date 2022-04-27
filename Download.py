##import os,requests
##def download(url):
##    get_response = requests.get(url,stream=True)
##    print(get_response.content)
##    file_name  = url.split("/")[-1]
##    with open(file_name, 'wb') as f:
##        for chunk in get_response.iter_content(chunk_size=1024):
##            if chunk: # filter out keep-alive new chunks
##                f.write(chunk)

import urllib.request
url = "https://git.pointclickcare.com/projects/WEB/repos/release_management/browse/PCC%20DB%20Scripts/4.4.10/4.4.10/Master_Scripts/4.4.10_06_CLIENT_A_PreUpload_US.sql"
print ("download start!")
filename, headers = urllib.request.urlretrieve(url, filename="4.4.10_06_CLIENT_A_PreUpload_US.sql")
print ("download complete!")
print ("download file location: ", filename)
print ("download headers: ", headers)

##download("https://git.pointclickcare.com/projects/WEB/repos/release_management/browse/PCC%20DB%20Scripts/4.4.10/4.4.10/Master_Scripts/4.4.10_06_CLIENT_A_PreUpload_US.sql")
