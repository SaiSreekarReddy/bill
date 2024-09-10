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
    REM Check if the file already exists locally
    if exist ".\files_downloaded\%%~nxA" (
        echo File %%~nxA already exists. Skipping...
    ) else (
        echo Downloading %%A from %SERVER_A% to local machine...
        pscp -pw %PASSWORD% %USERNAME%@%SERVER_A%:"%%A" ".\files_downloaded\%%~nxA"

        if %errorlevel% neq 0 (
            echo Error downloading file %%A.
            exit /b 1
        )
        echo Successfully downloaded %%A to .\files_downloaded\%%~nxA
    )
)

REM Log the file transfer details on Server A
call :LogTransferRemote "Server A" %SERVER_A% file_list.txt

del file_list.txt
echo Files downloaded to "files_downloaded" folder successfully.
goto TRANSFER_LOOP




============


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

REM Check if the file already exists on Server B
plink -pw %PASSWORD% %USERNAME%@%SERVER_B% "test -f %SERVER_B_DIR%/%~nxLOCAL_FILE%" >nul 2>&1

if %errorlevel% equ 0 (
    echo File %LOCAL_FILE% already exists on Server B. Skipping...
) else (
    REM Upload the file from local machine to SERVER_B
    pscp -pw %PASSWORD% "%LOCAL_FILE%" %USERNAME%@%SERVER_B%:%SERVER_B_DIR%

    if %errorlevel% neq 0 (
        echo Error uploading file %LOCAL_FILE%.
        exit /b 1
    )
    echo File %LOCAL_FILE% uploaded successfully.
)

REM Log the file transfer details on Server B
echo %LOCAL_FILE% > temp_file.txt
call :LogTransferRemote "Server B" %SERVER_B% temp_file.txt
del temp_file.txt

goto LocalToServerLoop
