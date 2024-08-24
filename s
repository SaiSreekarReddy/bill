@echo off
setlocal

:: Set your username, password, and server IP
set USERNAME=your_username
set PASSWORD=your_password
set SERVER_IP=your_server_ip

:: Call PowerShell to execute plink with the necessary commands
powershell -NoProfile -Command ^
    "$Password = '%PASSWORD%';" ^
    "$PlinkCommand = 'plink.exe -ssh %USERNAME%@%SERVER_IP% -pw ' + $Password + ' -t ''echo ' + $Password + ' | sudo -S su''';" ^
    "Invoke-Expression $PlinkCommand"

endlocal
