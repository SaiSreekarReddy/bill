@echo off
setlocal enabledelayedexpansion

:: Prompt the user to choose between downloading to Windows or a Linux server
echo Do you want to download the file to Windows or a Linux server?
echo 1. Windows
echo 2. Linux server
set /p choice="Enter 1 for Windows or 2 for Linux server: "

if "%choice%"=="1" (
    call :download_to_windows
) else if "%choice%"=="2" (
    call :download_to_linux
) else (
    echo Invalid choice. Exiting.
    goto :end
)

goto :end

:download_to_windows
:: Set up variables
set "username=your_username"
set "password=your_password"
set "dataset=ftp://sftpdev:1065//'mainframe.dataset.name'"
set "output_path=%cd%\mainframe_file.txt"  :: File will be saved in the current directory

:: Download the file using curl
echo Downloading file to Windows...
curl --ssl-reqd -u %username%:%password% -B -v -o "%output_path%" %dataset%

echo File downloaded to: %output_path%
goto :end

:download_to_linux
:: Prompt for server IP
set /p server_ip="Enter the Linux server IP: "

:: Set up variables
set "username=your_username"
set "password=your_password"
set "dataset=ftp://sftpdev:1065//'mainframe.dataset.name'"
set "temp_file=%cd%\mainframe_file.txt"  :: File will be saved temporarily in the current directory
set "linux_path=/tmp/mainframe_file.txt"

:: Download the file using curl to a temporary local file
echo Downloading file to temporary location...
curl --ssl-reqd -u %username%:%password% -B -v -o "%temp_file%" %dataset%

:: Transfer the file to the Linux server using scp
echo Transferring file to Linux server...
scp "%temp_file%" root@%server_ip%:/tmp

if %errorlevel%==0 (
    echo File successfully transferred to Linux server at /tmp.
) else (
    echo Failed to transfer file to Linux server.
)

:: Clean up the temporary file
del "%temp_file%"
goto :end

:end
echo Done.
exit /b
