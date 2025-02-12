@echo off
setlocal enabledelayedexpansion

:: Define the mapping between numbers and plink commands
:: You can add more numbers and commands as needed
set "cmd1=plink.exe -ssh -pw password user@server1 -t \"command_to_execute_1\""
set "cmd2=plink.exe -ssh -pw password user@server2 -t \"command_to_execute_2\""
set "cmd3=plink.exe -ssh -pw password user@server3 -t \"command_to_execute_3\""

:: Prompt the user for input
echo Enter the number corresponding to the command you want to run:
echo [1] Execute command on server1
echo [2] Execute command on server2
echo [3] Execute command on server3
set /p choice=Enter the number: 

:: Check the input and execute the corresponding command
if "%choice%"=="1" (
    echo Running command for server1...
    %cmd1%
    goto :eof
) else if "%choice%"=="2" (
    echo Running command for server2...
    %cmd2%
    goto :eof
) else if "%choice%"=="3" (
    echo Running command for server3...
    %cmd3%
    goto :eof
) else (
    echo There is no number like that.
    goto :eof
)