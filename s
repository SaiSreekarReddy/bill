@echo off
setlocal

:: Set your username, password, and server IP
set USERNAME=your_username
set PASSWORD=your_password
set SERVER_IP=your_server_ip

:: Detect the server type by checking for specific directories
plink.exe -ssh %USERNAME%@%SERVER_IP% -pw %PASSWORD% -t ^
"if [ -d /opt/jboss ]; then echo 'Server Type: JBoss'; " ^
"elif [ -d /opt/springboot ]; then echo 'Server Type: Spring Boot'; " ^
"elif [ -d /opt/splunk ]; then echo 'Server Type: Splunk'; " ^
"else echo 'Server Type: Regular'; fi; " ^
"echo %PASSWORD% | sudo -S su - && exec bash"

endlocal
