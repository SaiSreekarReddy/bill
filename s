@echo off
:menu
cls
echo ===========================================
echo Server Management Script
echo ===========================================
echo.
echo 1. Download logs filtered by date
echo 2. Stop/Start/Restart the server
echo 3. Navigate to a specific path and leave session open
echo 4. Exit
echo.
set /p choice=Enter your choice (1-4): 

if %choice%==1 goto download_logs
if %choice%==2 goto manage_server
if %choice%==3 goto navigate_path
if %choice%==4 goto exit
goto menu

:download_logs
cls
set /p USERNAME=Enter your username: 
set /p PASSWORD=Enter your password: 
set /p SERVER_IP=Enter the server IP: 
set /p LOG_DATE=Enter the log date (YYYY-MM-DD): 
set /p LOG_PATH=Enter the log directory path: 
set /p DEST_PATH=Enter the local path to save logs: 

wt -w 0 nt -d . plink -ssh %USERNAME%@%SERVER_IP% -pw %PASSWORD% "find %LOG_PATH% -type f -newermt '%LOG_DATE%' ! -newermt '%LOG_DATE% 23:59:59' -exec scp {} %USERNAME%@%COMPUTERNAME%:%DEST_PATH% \;"

echo Logs downloaded. Press any key to return to the menu.
pause
goto menu

:manage_server
cls
set /p USERNAME=Enter your username: 
set /p PASSWORD=Enter your password: 
set /p SERVER_IP=Enter the server IP: 
echo.
echo 1. Stop the server
echo 2. Start the server
echo 3. Restart the server
echo.
set /p action=Choose an action (1-3): 

if %action%==1 (
    wt -w 0 nt -d . plink -ssh %USERNAME%@%SERVER_IP% -pw %PASSWORD% "sudo systemctl stop <service-name>"
    echo Server stopped. 
) else if %action%==2 (
    wt -w 0 nt -d . plink -ssh %USERNAME%@%SERVER_IP% -pw %PASSWORD% "sudo systemctl start <service-name>"
    echo Server started.
) else if %action%==3 (
    wt -w 0 nt -d . plink -ssh %USERNAME%@%SERVER_IP% -pw %PASSWORD% "sudo systemctl restart <service-name>"
    echo Server restarted.
) else (
    echo Invalid choice.
)

echo Checking server status...
wt -w 0 nt -d . plink -ssh %USERNAME%@%SERVER_IP% -pw %PASSWORD% "sudo systemctl status <service-name>"
pause
goto menu

:navigate_path
cls
set /p USERNAME=Enter your username: 
set /p PASSWORD=Enter your password: 
set /p SERVER_IP=Enter the server IP: 
set /p SERVER_PATH=Enter the path to navigate to: 

wt -w 0 nt -d . plink -ssh %USERNAME%@%SERVER_IP% -pw %PASSWORD% -t "cd %SERVER_PATH% && exec bash"

echo You are now in the specified directory. Press any key to return to the menu.
pause
goto menu

:exit
exit
