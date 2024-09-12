@echo off
setlocal enabledelayedexpansion

:: Set your username and server IP
set /p SERVER_IP="Enter the server IP: "
set /p USERNAME="Enter your SSH username: "
set /p PASSWORD="Enter your sudo password: "

:: Set the command to detect server type
set cmd2=if [ -d "/opt/jboss" ]; then echo jboss; elif [ -d "/opt/springboot" ]; then echo springboot; else echo regular; fi

:: Detect server type and application name
for /f "delims=" %%i in ('plink.exe -batch -ssh %USERNAME%@%SERVER_IP% -pw %PASSWORD% -t "bash -c '%cmd2%'"') do set serverType=%%i

:: Debugging: Output detected server type
echo Detected Server Type: %serverType%

:: Application detection based on the server type
if "%serverType%" == "jboss" (
    echo Detected JBoss server, fetching application name...
    for /f "delims=" %%j in ('plink.exe -batch -ssh %USERNAME%@%SERVER_IP% -pw %PASSWORD% -t "bash -c ''ls /opt/jboss/instance | head -n 1''"') do set appName=%%j
    set appName=%appName:_0000=%
) else if "%serverType%" == "springboot" (
    echo Detected Spring Boot server, fetching application name...
    for /f "delims=" %%j in ('plink.exe -batch -ssh %USERNAME%@%SERVER_IP% -pw %PASSWORD% -t "bash -c ''ls /opt/springboot/applications | head -n 1''"') do set appName=%%j
    set appName=%appName:-web=%
) else (
    echo No specific server detected, setting app name to NoAppFound...
    set appName=NoAppFound
)

:: Debugging: Output raw application name
echo Raw Application Name: %appName%

:: Menu for server control
:menu
cls
echo.
echo Server Control Script for %appName%
echo.
echo 1. Check Status
echo 2. Restart Server
echo 3. Stop Server
echo 4. Start Server
echo 5. Execute Custom Command
echo 6. Exit
echo.
set /p choice="Enter your choice (1-6): "

:: Execute the selected command
if "%choice%" == "1" (
    if "%serverType%" == "jboss" (
        call :execute_command "systemctl status jboss"
    ) else if "%serverType%" == "springboot" (
        call :execute_command "systemctl status springboot"
    )
) else if "%choice%" == "2" (
    if "%serverType%" == "jboss" (
        call :execute_command "systemctl restart jboss"
    ) else if "%serverType%" == "springboot" (
        call :execute_command "systemctl restart springboot"
    )
) else if "%choice%" == "3" (
    if "%serverType%" == "jboss" (
        call :execute_command "systemctl stop jboss"
    ) else if "%serverType%" == "springboot" (
        call :execute_command "systemctl stop springboot"
    )
) else if "%choice%" == "4" (
    if "%serverType%" == "jboss" (
        call :execute_command "systemctl start jboss"
    ) else if "%serverType%" == "springboot" (
        call :execute_command "systemctl start springboot"
    )
) else if "%choice%" == "5" (
    set /p customCommand="Enter the custom command: "
    call :execute_command "%customCommand%"
) else if "%choice%" == "6" (
    exit
) else (
    echo Invalid choice, please try again.
    pause
    goto :menu
)

:: Command execution function
:execute_command
set command=%1
echo Running command: !command!
plink.exe -batch -ssh %USERNAME%@%SERVER_IP% -pw %PASSWORD% -t "echo %PASSWORD% | sudo -S !command!"
plink.exe -batch -ssh %USERNAME%@%SERVER_IP% -pw %PASSWORD% -t "history -d $(history 1)"
goto :menu

pause
goto :menu
endlocal
