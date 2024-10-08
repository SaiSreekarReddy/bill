@echo off
setlocal enabledelayedexpansion

:: List of server IPs
set "servers=192.168.0.1 192.168.0.2 192.168.0.3"  :: You can add more IPs here

:: Define the username and password
set "username=XUSERNAME"
set "password=XPASSWORD"

:: Loop through each server IP
for %%i in (%servers%) do (
    echo Connecting to server %%i...
    
    :: Execute two commands on the server and capture the output
    plink.exe -batch -ssh !username!@%%i -pw !password! "command1 && command2" > output_%%i.txt

    :: Check the status of the execution
    if %errorlevel% neq 0 (
        echo Failed to execute commands on server %%i
    ) else (
        echo Commands executed successfully on server %%i, output saved to output_%%i.txt
    )
)

endlocal
