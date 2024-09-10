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
'"Prompt;$H&For %%# in (1) Do Rem"') Do Set "BS=%%#"

:HILoop
Set "Key="
For /F "delims=" %%# In (
'Xcopy /W "%~f0" "%~f0" 2^>Nul') Do If Not Defined Key Set "Key=%%#"
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

REM Ask for operation type
echo Select the file transfer operation:
echo 1. Move files from SERVER_A to SERVER_B
echo 2. Download files from SERVER_A to local
echo 3. Upload files from local to SERVER_B
set /p OPERATION="Choose an option (1, 2, or 3): "

if "%OPERATION%"=="1" goto :ServerToServer
if "%OPERATION%"=="2" goto :ServerToLocal
if "%OPERATION%"=="3" goto :LocalToServer
echo Invalid option. Exiting...
exit /b 1

:LogTransferRemote
REM Function to log file transfer on remote server(s)
set LOG_PATH="/path/to/remote/log/file_transfer_log.txt"
set SERVER_IP=%2
set FILES_LIST=%3

REM Append log details to the remote log file
echo Sending transfer log to %1 (%SERVER_IP%)...
plink -pw %PASSWORD% %USERNAME%@%SERVER_IP% "echo -------------------------------------------------- >> %LOG_PATH%"
plink -pw %PASSWORD% %USERNAME%@%SERVER_IP% "echo Date and Time: %DATE% %TIME% >> %LOG_PATH%"
plink -pw %PASSWORD% %USERNAME%@%SERVER_IP% "echo User: %USERNAME% >> %LOG_PATH%"
plink -pw %PASSWORD% %USERNAME%@%SERVER_IP% "echo Source Server IP: %SERVER_A% >> %LOG_PATH%"
plink -pw %PASSWORD% %USERNAME%@%SERVER_IP% "echo Destination Server IP: %SERVER_B% >> %LOG_PATH%"
plink -pw %PASSWORD% %USERNAME%@%SERVER_IP% "echo Transferred Files: >> %LOG_PATH%"

REM Loop through files and add to log
for /f "usebackq delims=" %%F in (%FILES_LIST%) do (
    plink -pw %PASSWORD% %USERNAME%@%SERVER_IP% "echo %%F >> %LOG_PATH%"
)
plink -pw %PASSWORD% %USERNAME%@%SERVER_IP% "echo -------------------------------------------------- >> %LOG_PATH%"
goto :eof

:ServerToServer
REM Prompt for additional details
set /p SERVER_A_DIR="Enter the source directory path on SERVER_A: "
set /p SERVER_B="Enter the destination server IP: "
set /p SERVER_B_DIR="Enter the destination directory path on SERVER_B: "
set /p TARGET_DATE="Enter the target date for file filtering (YYYY-MM-DD): "

REM SSH command to find files modified on a specific date
set FIND_CMD="find %SERVER_A_DIR% -type f -newermt %TARGET_DATE% ! -newermt %TARGET_DATE%T23:59:59"
echo Retrieving and displaying file list...
plink -pw %PASSWORD% %USERNAME%@%SERVER_A% %FIND_CMD% > file_list.txt

REM Check if file_list.txt is empty (no files found)
set "FILE_FOUND="
for /f %%A in (file_list.txt) do set FILE_FOUND=1
if not defined FILE_FOUND (
    echo No files found for the given date.
    del file_list.txt
    goto TRANSFER_LOOP
)

REM Loop through each file and transfer
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

REM Log the file transfer details on both Server A and Server B
call :LogTransferRemote "Server A" %SERVER_A% file_list.txt
call :LogTransferRemote "Server B" %SERVER_B% file_list.txt

del file_list.txt
echo Files transferred successfully.
goto TRANSFER_LOOP

:ServerToLocal
set /p SERVER_A_DIR="Enter the source directory path on SERVER_A: "
set /p TARGET_DATE="Enter the target date for file filtering (YYYY-MM-DD): "

REM SSH command to find files modified on a specific date
set FIND_CMD="find %SERVER_A_DIR% -type f -newermt %TARGET_DATE% ! -newermt %TARGET_DATE%T23:59:59"
echo Retrieving and displaying file list...
plink -pw %PASSWORD% %USERNAME%@%SERVER_A% %FIND_CMD% > file_list.txt

REM Create local folder for downloaded files
mkdir files_downloaded

REM Download each file from SERVER_A to the local machine
for /f "usebackq delims=" %%A in (file_list.txt) do (
    echo Downloading %%A from %SERVER_A% to local machine...
    pscp -pw %PASSWORD% %USERNAME%@%SERVER_A%:"%%A" ".\files_downloaded\%%~nxA"

    if %errorlevel% neq 0 (
        echo Error downloading file %%A.
        exit /b 1
    )
    echo Successfully downloaded %%A to .\files_downloaded\%%~nxA
)

REM Log the file transfer details on Server A
call :LogTransferRemote "Server A" %SERVER_A% file_list.txt

del file_list.txt
echo Files downloaded to "files_downloaded" folder successfully.
goto TRANSFER_LOOP

:LocalToServer
set /p SERVER_B="Enter the destination server IP: "
set /p SERVER_B_DIR="Enter the destination directory path on SERVER_B: "

:LocalToServerLoop
set /p LOCAL_FILE="Enter the local file to upload (or type 'exit' to quit): "

REM Exit the loop if the user types 'exit'
if /i "%LOCAL_FILE%"=="exit" (
    echo Exiting the upload loop.
    goto TRANSFER_LOOP
)

REM Upload the file from local machine to SERVER_B
pscp -pw %PASSWORD% "%LOCAL_FILE%" %USERNAME%@%SERVER_B%:%SERVER_B_DIR%

if %errorlevel% neq 0 (
    echo Error uploading file %LOCAL_FILE%.
    exit /b 1
)
echo File %LOCAL_FILE% uploaded successfully.

REM Log the file transfer details on Server B
echo %LOCAL_FILE% > temp_file.txt
call :LogTransferRemote "Server B" %SERVER_B% temp_file.txt
del temp_file.txt

goto LocalToServerLoop

endlocal


===========

:ServerToLocal
set /p SERVER_A_DIR="Enter the source directory path on SERVER_A: "
set /p TARGET_DATE="Enter the target date for file filtering (YYYY-MM-DD): "

REM SSH command to find files modified on a specific date
set FIND_CMD="find %SERVER_A_DIR% -type f -newermt %TARGET_DATE% ! -newermt %TARGET_DATE%T23:59:59"
echo Retrieving and displaying file list...
plink -pw %PASSWORD% %USERNAME%@%SERVER_A% %FIND_CMD% > file_list.txt

REM Create local folder for downloaded files
mkdir files_downloaded

REM Function to get unique file name
:GetUniqueFileName
set FILE_NAME_WITHOUT_EXT=%~n1
set FILE_EXT=%~x1
set FILE_PATH=.\files_downloaded\%FILE_NAME_WITHOUT_EXT%%FILE_EXT%

REM Check if the file already exists
set COUNT=1
:CheckFileExists
if exist "%FILE_PATH%" (
    REM Increment the count and modify the file name
    set /a COUNT+=1
    set FILE_PATH=.\files_downloaded\%FILE_NAME_WITHOUT_EXT%(%COUNT%)%FILE_EXT%
    goto CheckFileExists
)

REM Return the unique file path
set "%2=%FILE_PATH%"
goto :eof

REM Download each file from SERVER_A to the local machine
for /f "usebackq delims=" %%A in (file_list.txt) do (
    REM Get the base file name and extension
    call :GetUniqueFileName "%%~nxA" UNIQUE_FILE_PATH

    echo Downloading %%A from %SERVER_A% to local machine as %UNIQUE_FILE_PATH%...
    pscp -pw %PASSWORD% %USERNAME%@%SERVER_A%:"%%A" "%UNIQUE_FILE_PATH%"

    if %errorlevel% neq 0 (
        echo Error downloading file %%A.
        exit /b 1
    )
    echo Successfully downloaded %%A to %UNIQUE_FILE_PATH%
)

REM Log the file transfer details to remote server
if /i "%LOG_SERVER%"=="A" (
    call :LogTransferRemote "Server A" %SERVER_A% file_list.txt
) else (
    call :LogTransferRemote "Server B" %SERVER_B% file_list.txt
)

del file_list.txt
echo Files downloaded to "files_downloaded" folder successfully.
goto TRANSFER_LOOP
