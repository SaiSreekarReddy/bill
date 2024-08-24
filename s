@echo off
setlocal

:: Set your username, password, and server IP
set USERNAME=your_username
set PASSWORD=your_password
set SERVER_IP=your_server_ip

:: Run plink to SSH into the server and elevate to root
plink.exe -ssh %USERNAME%@%SERVER_IP% -pw %PASSWORD% -t "echo %PASSWORD% | sudo -S su"

endlocal
