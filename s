@echo off
setlocal

:: Set your username, password, and server IP
set USERNAME=your_username
set PASSWORD=your_password
set SERVER_IP=your_server_ip

:: Run plink to SSH into the server, detect the server type, find the app name, and keep the session open
plink.exe -ssh %USERNAME%@%SERVER_IP% -pw %PASSWORD% -t ^
"bash -c \"cd /opt; " ^
"for dir in *; do " ^
"if [ -d \"$dir\" ]; then " ^
"  case $dir in " ^
"    *jboss* ) echo 'Server Type: JBoss'; " ^
"      if [ -d /opt/jboss/instance ]; then " ^
"        app_name=\$(ls /opt/jboss/instance | head -n 1); " ^
"        echo 'JBoss Application Name: '$app_name; " ^
"      fi;; " ^
"    *springboot* ) echo 'Server Type: Spring Boot'; " ^
"      if [ -d /opt/springboot/applications ]; then " ^
"        app_name=\$(ls /opt/springboot/applications | head -n 1); " ^
"        echo 'Spring Boot Application Name: '$app_name; " ^
"      fi;; " ^
"    *splunk* ) echo 'Server Type: Splunk';; " ^
"    * ) echo 'Server Type: Regular';; " ^
"  esac; " ^
"fi; " ^
"done; " ^
"bash\""

endlocal
