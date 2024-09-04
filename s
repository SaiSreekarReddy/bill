@echo off
setlocal

REM Prompt for user ID and password (only once)
set /p USERNAME="Enter your SSH user ID: "
set /p PASSWORD="Enter your SSH password: "

:TRANSFER_LOOP
REM Prompt for source server IP
set /p SERVER_A="Enter the source server IP (or type 'exit' to quit): "

REM Exit the loop if the user types 'exit'
if /i "%SERVER_A%"=="exit" (
    echo Exiting the script.
    exit /b 0
)

REM Test SSH connection to validate access to the source server
echo Validating SSH access to %SERVER_A%...
plink -pw %PASSWORD% %USERNAME%@%SERVER_A% "echo SSH connection successful" >nul 2>&1
if %errorlevel% neq 0 (
    echo SSH connection failed. Please check your source server IP.
    goto TRANSFER_LOOP
)
echo SSH access validated for %SERVER_A%.

REM Prompt for additional details (source and destination directories, date)
set /p SERVER_A_DIR="Enter the source directory path on %SERVER_A%: "
set /p SERVER_B="Enter the destination server IP: "
set /p SERVER_B_DIR="Enter the destination directory path on %SERVER_B%: "
set /p TARGET_DATE="Enter the target date for file filtering (YYYY-MM-DD): "

REM Create the destination folder on SERVER_B if it doesn't exist
plink -pw %PASSWORD% %USERNAME%@%SERVER_B% "mkdir -p %SERVER_B_DIR%" >nul 2>&1

REM SSH command to find files modified on a specific date
set FIND_CMD="find %SERVER_A_DIR% -type f -newermt %TARGET_DATE% ! -newermt %TARGET_DATE%T23:59:59"

REM Retrieve and transfer files from SERVER_A to SERVER_B in one step
echo Retrieving file list and transferring files...
plink -pw %PASSWORD% %USERNAME%@%SERVER_A% %FIND_CMD% | (
    set FILE_FOUND=0
    for /f "usebackq delims=" %%A in ('more') do (
        set FILE_FOUND=1
        echo Transferring %%A from SERVER_A to SERVER_B...
        pscp -pw %PASSWORD% %USERNAME%@%SERVER_A%%%A %USERNAME%@%SERVER_B%:%SERVER_B_DIR%
        if %errorlevel% neq 0 (
            echo Error transferring file %%A.
            exit /b 1
        )
    )
)

REM Check if any file was transferred
if %FILE_FOUND%==0 (
    echo No files found for the given date.
) else (
    echo Files transferred successfully.
)

REM Loop back to allow another transfer from a different source IP
goto TRANSFER_LOOP

endlocal
