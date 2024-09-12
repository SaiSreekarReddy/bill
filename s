@echo off
setlocal enabledelayedexpansion

:: Prompt for username, password, application name, and number of hours to go back
set /p user=Enter your username: 
set /p pass=Enter your password: 
set /p app=Enter the application name (e.g., app1/app2/jsb1/jsb3): 
set /p hours=Enter the number of hours to go back: 

:: Determine which server to use based on app name
if "%app%"=="app1" set server=192.168.0.1
if "%app%"=="app3" set server=192.168.0.1
if "%app%"=="app6" set server=192.168.0.1

if "%app%"=="app2" set server=192.168.0.2
if "%app%"=="app4" set server=192.168.0.2
if "%app%"=="app7" set server=192.168.0.2

if "%app:~0,4%"=="jsb1" set server=192.168.0.3
if "%app:~0,4%"=="jsb3" set server=192.168.0.3
if "%app:~0,4%"=="jsb6" set server=192.168.0.3

:: You can add more conditions for server4 or any other fallback
if not defined server (
    echo Application name does not match any predefined rules.
    pause
    exit /b
)

echo Selected server: %server%

:: Define the application path template (based on app name)
set path_template=/opt/jboss/instance/%app%/logs/

:: Create a local folder for downloads (organized by application and server)
set localPath=C:\DownloadedLogs\%app%\
if not exist %localPath% mkdir %localPath%

:: Get the time range for logs on the selected server (based on the number of hours entered)
for /f "tokens=*" %%i in ('plink -batch -pw %pass% %user%@%server% "date -u --date='%hours% hours ago' +%%Y%%m%%d%%H%%M"') do set backTime=%%i

:: Fetch log files modified within the time frame from the specific application path
plink -batch -pw %pass% %user%@%server% "find %path_template% -type f -newermt '%backTime%'" > loglist.txt

:: Loop through each file found and download it using PSCP
for /f "tokens=*" %%i in (loglist.txt) do (
    echo Downloading %%i from server %server%...
    pscp -pw %pass% %user%@%server%:"%%i" %localPath%
)

echo All logs downloaded successfully to %localPath%.
pause



==========


















