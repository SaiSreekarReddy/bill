//SFTPSEND JOB ...
//STEP01 EXEC PGM=IKJEFT01                     
//SYSTSPRT DD SYSOUT=*                         
//SYSTSIN  DD *                                
  SFTP user@linux_server_ip_or_hostname        
  cd /destination_directory_on_linux           
  put 'mainframe_dataset_name' linux_filename  
  bye                                         
/*
