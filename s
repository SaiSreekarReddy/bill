@echo off
setlocal enabledelayedexpansion

:: Define the list of IP addresses directly in the script (space-separated)
set "IP_LIST=192.168.1.10 192.168.1.11 192.168.1.12"

:: Set your SSH username and password
set "USERNAME=your_username"
set "PASSWORD=your_password"

:: Loop through each IP in the list
for %%A in (%IP_LIST%) do (
    set "SERVER_IP=%%A"
    echo Checking server %SERVER_IP%...

    :: Detect the server type (JBoss or Spring Boot)
    set "cmd2=if [ -d '/opt/jboss' ]; then echo jboss; elif [ -d '/opt/springboot' ]; then echo springboot; else echo regular; fi"

    :: Execute Plink to detect the server type (simple command for testing Plink)
    for /f "delims=" %%i in ('plink.exe -batch -ssh %USERNAME%@%SERVER_IP% -pw %PASSWORD% -t "bash -c \"%cmd2%\""') do set "serverType=%%i"

    :: Output detected server type
    echo Detected Server Type for %SERVER_IP%: !serverType!
    echo --------------------------
)

pause
endlocal
