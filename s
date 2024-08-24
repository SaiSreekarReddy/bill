@echo off
setlocal

:: Set your username, password, and server IP
set USERNAME=your_username
set PASSWORD=your_password
set SERVER_IP=your_server_ip

:: Detect the server type by searching for specific words in /opt
plink.exe -ssh %USERNAME%@%SERVER_IP% -pw %PASSWORD% -t ^
"cd /opt && if ls | grep -q 'jboss'; then echo 'Server Type: JBoss'; " ^
"elif ls | grep -q 'springboot'; then echo 'Server Type: Spring Boot'; " ^
"elif ls | grep -q 'splunk'; then echo 'Server Type: Splunk'; " ^
"else echo 'Server Type: Regular'; fi; " ^
"echo %PASSWORD% | sudo -S su - && exec bash"

endlocal
