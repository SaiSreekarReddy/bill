@echo off
setlocal

:: Set your username, password, and server IP
set USERNAME=your_username
set PASSWORD=your_password
set SERVER_IP=your_server_ip

:: Set the command to detect server type
set cmd2=if [ -d "/opt/jboss" ]; then echo jboss; elif [ -d "/opt/springboot" ]; then echo springboot; else echo regular; fi

:: Run the command and capture the server type
for /f "delims=" %%i in ('plink.exe -batch -ssh %USERNAME%@%SERVER_IP% -pw %PASSWORD% -t "bash -c '%cmd2%'"') do set serverType=%%i

:: Output the detected server type
echo Detected Server Type: %serverType%

:: Application detection based on the server type
if "%serverType%" == "jboss" (
    echo Detected JBoss server, fetching application name...
    for /f "delims=" %%j in ('plink.exe -batch -ssh %USERNAME%@%SERVER_IP% -pw %PASSWORD% -t "bash -c ''ls /opt/jboss/instance | head -n 1 | awk -F _ ''{print $1}'''"') do set appName=%%j
) else if "%serverType%" == "springboot" (
    echo Detected Spring Boot server, fetching application name...
    for /f "delims=" %%j in ('plink.exe -batch -ssh %USERNAME%@%SERVER_IP% -pw %PASSWORD% -t "bash -c ''ls /opt/springboot/applications | head -n 1 | awk -F - ''{print $1}'''"') do set appName=%%j
) else (
    echo No specific server detected, setting app name to NoAppFound...
    set appName=NoAppFound
)

:: Output the server type and application name
echo Final Detected Server Type: %serverType%
echo Final Detected Application Name: %appName%

pause
endlocal
