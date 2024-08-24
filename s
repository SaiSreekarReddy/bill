@echo off
setlocal

:: Hard-coded username and password
set USERNAME=your_username
set PASSWORD=your_password

:: Prompt for the server IP address
set /p SERVER_IP=Enter the server IP address: 

:: Define the plink path
set PLINK_PATH=plink.exe

:: Function to detect server type
:DetectServerType
echo Detecting server type on %SERVER_IP%...
%PLINK_PATH% -ssh %USERNAME%@%SERVER_IP% -pw %PASSWORD% -t "sudo su -c \"cd /opt && ls\"" > temp.txt

set SERVER_TYPE=Regular

:: Check for presence of specific directories
findstr /i "springboot" temp.txt >nul && set SERVER_TYPE=Spring Boot
findstr /i "jboss" temp.txt >nul && set SERVER_TYPE=JBoss
findstr /i "splunk" temp.txt >nul && set SERVER_TYPE=Splunk

:: Report detected server type
echo Server Type Detected: %SERVER_TYPE%
del temp.txt
goto :EndDetect

:EndDetect
:: Now start an interactive session using plink
echo Starting interactive session...
%PLINK_PATH% -ssh %USERNAME%@%SERVER_IP% -pw %PASSWORD% -t "sudo su"
endlocal
