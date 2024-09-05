@echo off
setlocal

REM :::::::::::::BEGIN OF MASKED PASSWORD INPUT CODE:::::::::::::
:HInput
::Version 3.0      
SetLocal DisableDelayedExpansion
echo Enter your password below:
Set "Line="
Rem Save 0x08 character in BS variable
For /F %%# In (
'"Prompt;$H&For %%# in (1) Do Rem"'
) Do Set "BS=%%#"

:HILoop
Set "Key="
For /F "delims=" %%# In (
'Xcopy /W "%~f0" "%~f0" 2^>Nul'
) Do If Not Defined Key Set "Key=%%#"
Set "Key=%Key:~-1%"
SetLocal EnableDelayedExpansion
If Not Defined Key Goto :HIEnd 
If %BS%==^%Key% (Set /P "=%BS% %BS%" <Nul
Set "Key="
If Defined Line Set "Line=!Line:~0,-1!"
) Else Set /P "=*" <Nul
If Not Defined Line (EndLocal &Set "Line=%Key%"
) Else For /F delims^=^ eol^= %%# In (
"!Line!") Do EndLocal &Set "Line=%%#%Key%" 
Goto :HILoop

:HIEnd
EndLocal & Set "PASSWORD=%Line%"
Echo(
REM :::::::::::::END OF MASKED PASSWORD INPUT CODE:::::::::::::

REM Prompt for user ID (Password is already masked)
set /p USERNAME="Enter your SSH user ID: "

:TRANSFER_LOOP
REM Prompt for source server IP
set /p SERVER_A="Enter the source server IP (or type 'exit' to quit): "

REM Exit the loop if the user types 'exit'
if /i "%SERVER_A%"=="exit" (
    echo Exiting the script.
    exit /b 0
)

:VALIDATE_SSH
REM Test SSH connection to validate access to the source server
echo Validating SSH access to %SERVER_A%...
plink -pw %PASSWORD% %USERNAME%@%SERVER_A% "echo SSH connection successful" >nul 2>&1

REM Check if the connection is successful
if %errorlevel% neq 0 (
    echo SSH connection failed. Please check your password or source server IP.
    echo You will be prompted to re-enter your password.
    
    REM Prompt to re-enter the password
    call :HInput

    REM Retry SSH validation
    goto VALIDATE_SSH
)

echo SSH access validated for %SERVER_A%.

REM Prompt for additional details (source and destination directories, date)
set /p SERVER_A_DIR="Enter the source directory path on %SERVER_A%: "
set /p SERVER_B="Enter the destination server IP: "
set /p SERVER_B_DIR="Enter the destination directory path on %SERVER_B%: "
set /p TARGET_DATE="Enter the target date for file filtering (YYYY-MM-DD): "

REM SSH command to find files modified on a specific date
set FIND_CMD="find %SERVER_A_DIR% -type f -newermt %TARGET_DATE% ! -newermt %TARGET_DATE%T23:59:59"

REM Retrieve and store the list of files temporarily in memory for display
echo Retrieving and displaying file list...
plink -pw %PASSWORD% %USERNAME%@%SERVER_A% %FIND_CMD% > file_list.txt

REM Check if the file_list.txt is empty (no files found)
for /f %%A in (file_list.txt) do set FILE_FOUND=1
if not defined FILE_FOUND (
    echo No files found for the given date.
    del file_list.txt
    goto TRANSFER_LOOP
)

REM Echo the list of files before starting the transfer
echo The following files will be transferred:
type file_list.txt

REM Ask for confirmation before proceeding
set /p CONFIRM="Do you want to proceed with the file transfer? (y/n): "
if /i "%CONFIRM%" neq "y" (
    echo Transfer canceled. Returning to the source IP prompt.
    del file_list.txt
    goto TRANSFER_LOOP
)

REM Create the destination folder on SERVER_B if it doesn't exist
plink -pw %PASSWORD% %USERNAME%@%SERVER_B% "mkdir -p %SERVER_B_DIR%" >nul 2>&1

REM Transfer each file from SERVER_A to local, upload it to SERVER_B, and delete from local
for /f "usebackq delims=" %%A in (file_list.txt) do (
    echo Downloading %%A from %SERVER_A% to local machine...
    pscp -pw %PASSWORD% %USERNAME%@%SERVER_A%:"%%A" .\

    if %errorlevel% neq 0 (
        echo Error downloading file %%A.
        exit /b 1
    )

    echo Uploading %%A from local machine to %SERVER_B%...
    pscp -pw %PASSWORD% ".\%%~nxA" %USERNAME%@%SERVER_B%:%SERVER_B_DIR%

    if %errorlevel% neq 0 (
        echo Error uploading file %%A.
        exit /b 1
    )

    echo Deleting local file %%A...
    del "%%~nxA"
)

REM Cleanup temporary file
del file_list.txt

echo Files transferred and cleaned up successfully.

REM Loop back to allow another transfer from a different source IP
goto TRANSFER_LOOP

endlocal
