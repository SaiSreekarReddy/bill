@echo off
setlocal enabledelayedexpansion

:: Prompt for server details
set /p server=Enter the server IP: 
set /p user=Enter your username: 
set /p pass=Enter your password:
set /p hours=Enter the number of hours to go back: 

:: Get current date and time (assuming server and client are in sync, or adjust accordingly)
for /f "tokens=*" %%i in ('plink -batch -pw %pass% %user%@%server% "date -u +%%Y%%m%%d%%H%%M"') do set currentTime=%%i

:: Get time going back the specified hours (using a basic date command)
for /f "tokens=*" %%i in ('plink -batch -pw %pass% %user%@%server% "date -u --date='%hours% hours ago' +%%Y%%m%%d%%H%%M"') do set backTime=%%i

:: Define remote paths and local directory for download
set remotePath=/var/log/
set localPath=C:\DownloadedLogs\

:: Create local directory if it doesn't exist
if not exist %localPath% (
    mkdir %localPath%
)

:: Use Plink to find logs between current time and back time
echo Fetching logs from %server% since %backTime%
plink -batch -pw %pass% %user%@%server% "find %remotePath% -type f -newermt '!backTime!'" > loglist.txt

:: Check if any logs were found
if not exist loglist.txt (
    echo No logs found or unable to fetch log list.
    goto :end
)

:: Display all the files to be downloaded and ask for confirmation
echo The following files have been found:
type loglist.txt

set /p confirm=Do you want to download these files? (y/n): 
if /i not "%confirm%"=="y" (
    echo Download aborted.
    goto :end
)

:: Loop through each file and download using PSCP
for /f "tokens=*" %%i in (loglist.txt) do (
    echo Downloading: %%i
    pscp -pw %pass% %user%@%server%:"%%i" %localPath%
)

echo Logs downloaded to %localPath%.

:end
pause
