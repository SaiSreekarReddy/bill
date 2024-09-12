@echo off
setlocal enabledelayedexpansion

:: Set your username, password, and server IP
set USERNAME=your_username
set PASSWORD=your_password
set SERVER_IP=your_server_ip

:: Set the command to detect server type
set cmd2=if [ -d "/opt/jboss" ]; then echo jboss; elif [ -d "/opt/springboot" ]; then echo springboot; else echo regular; fi

:: Run the command and capture the server type
for /f "delims=" %%i in ('plink.exe -batch -ssh %USERNAME%@%SERVER_IP% -pw %PASSWORD% -t "bash -c '%cmd2%'"') do set serverType=%%i

:: Debugging: Output detected server type
echo Detected Server Type: %serverType%

:: Application detection based on the server type
if "%serverType%" == "jboss" (
    echo Detected JBoss server, fetching application name...
    for /f "delims=" %%j in ('plink.exe -batch -ssh %USERNAME%@%SERVER_IP% -pw %PASSWORD% -t "bash -c ''ls /opt/jboss/instance | head -n 1''"') do set appName=%%j
    :: Debugging: Output raw application name for JBoss
    echo Raw Application Name (JBoss): !appName!
    :: Trim the name to exclude "_0000" or other suffix
    for /f "tokens=1 delims=_" %%k in ("!appName!") do set appName=%%k
) else if "%serverType%" == "springboot" (
    echo Detected Spring Boot server, fetching application name...
    for /f "delims=" %%j in ('plink.exe -batch -ssh %USERNAME%@%SERVER_IP% -pw %PASSWORD% -t "bash -c ''ls /opt/springboot/applications | head -n 1''"') do set appName=%%j
    :: Debugging: Output raw application name for Spring Boot
    echo Raw Application Name (Spring Boot): !appName!
    :: Trim the name to exclude "-web" or other suffix
    for /f "tokens=1 delims=-" %%k in ("!appName!") do set appName=%%k
) else (
    echo No specific server detected, setting app name to NoAppFound...
    set appName=NoAppFound
)

:: Debugging: Check if appName variable is still empty
if "!appName!" == "" (
    echo Application name could not be fetched.
) else (
    echo Final Detected Application Name: !appName!
)

:: Output the final server type and application name
echo Final Detected Server Type: %serverType%
echo Final Detected Application Name: !appName!

pause
endlocal
