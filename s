@echo off
setlocal enabledelayedexpansion

:: Set the FTP parameters
set hostname=sftpdev
set port=1065
set userid=YOUR_USERNAME
set password=YOUR_PASSWORD
set remoteFilePath='mainframe.dataset.name'
set localFilePath="%USERPROFILE%\Desktop\downloaded_file"

:: Choose download mode
set /p downloadMode="Enter download mode (binary or text): "

:: Validate download mode and set transfer option
if /i "%downloadMode%"=="binary" (
    set transferOption=--ftp-method nocwd --binary
    echo Downloading in binary mode...
) else if /i "%downloadMode%"=="text" (
    set transferOption=--ftp-method nocwd
    echo Downloading in text mode...
) else (
    echo Invalid mode selected. Please enter "binary" or "text".
    exit /b
)

:: FTP command using curl to download the file
curl --ssl-reqd -u %userid%:%password% -v %transferOption% -o %localFilePath% ftp://%hostname%:%port%//%remoteFilePath%

:: Check if the file was downloaded
if exist %localFilePath% (
    echo File downloaded successfully to %localFilePath%.
) else (
    echo Failed to download the file.
)

endlocal
