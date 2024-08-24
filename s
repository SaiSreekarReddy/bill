@echo off
setlocal

:: Set your username, password, and server IP
set USERNAME=your_username
set PASSWORD=your_password
set SERVER_IP=your_server_ip

:: Detect the server type by searching for specific words in /opt and elevate to root
plink.exe -ssh %USERNAME%@%SERVER_IP% -pw %PASSWORD% -t ^
"bash -c \"cd /opt; " ^
"for dir in *; do " ^
"if [ -d \"$dir\" ]; then " ^
"  case $dir in " ^
"    *jboss* ) echo 'Server Type: JBoss';; " ^
"    *springboot* ) echo 'Server Type: Spring Boot';; " ^
"    *splunk* ) echo 'Server Type: Splunk';; " ^
"    * ) echo 'Server Type: Regular';; " ^
"  esac; " ^
"fi; " ^
"done; " ^
"echo %PASSWORD% | sudo -S su - && exec bash\""

endlocal
