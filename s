@echo off
setlocal

:: Set UTF-8 encoding if needed
chcp 65001 >nul

:: Hard-coded username and password
set USERNAME=your_username
set PASSWORD=your_password

:: Prompt for the server IP address
set /p SERVER_IP=Enter the server IP address: 

:: PowerShell script to detect server type and connect via plink
powershell -NoProfile -Command ^
    "$OutputEncoding = [System.Text.Encoding]::UTF8;" ^
    "$ServerType = 'Regular';" ^
    "$output = & plink.exe -ssh %USERNAME%@%SERVER_IP% -pw %PASSWORD% -t 'sudo su -c \"cd /opt && ls\"';" ^
    "if ($output -match 'springboot') {$ServerType = 'Spring Boot'}" ^
    "elseif ($output -match 'jboss') {$ServerType = 'JBoss'}" ^
    "elseif ($output -match 'splunk') {$ServerType = 'Splunk'};" ^
    "echo Server Type Detected: $ServerType;" ^
    "& plink.exe -ssh %USERNAME%@%SERVER_IP% -pw %PASSWORD% -t 'export TERM=xterm; sudo su'"

endlocal


================


@echo off
setlocal

:: Hard-coded username and password
set USERNAME=your_username
set PASSWORD=your_password

:: Prompt for the server IP address
set /p SERVER_IP=Enter the server IP address: 

:: Call PowerShell to execute plink with UTF-8 encoding support
powershell -NoProfile -Command ^
    "$OutputEncoding = [System.Text.Encoding]::UTF8; " ^
    "plink.exe -ssh %USERNAME%@%SERVER_IP% -pw %PASSWORD% -t 'export TERM=xterm; sudo su'"

endlocal
