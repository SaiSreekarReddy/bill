@echo off
REM Prompt for the server's IP address or hostname
set /p SERVER_ADDR=Enter the server IP address or hostname: 

REM Set your server's login details
set /p USERNAME=Enter your username: 
set /p PASSWORD=Enter your password: 

REM Define the command to check for JBoss directory
set CMD_CHECK_JBOSS=if [ -d /opt/jboss ]; then echo jboss; else echo notjboss; fi
REM Define the command to check for Spring Boot directory
set CMD_CHECK_SPRINGBOOT=if [ -d /opt/springboot ]; then echo springboot; else echo notspringboot; fi

REM Use plink to check for JBoss directory
set PLINK_CMD_JBOSS=plink -ssh %USERNAME%@%SERVER_ADDR% -pw %PASSWORD% -batch "%CMD_CHECK_JBOSS%"

REM Use plink to check for Spring Boot directory
set PLINK_CMD_SPRINGBOOT=plink -ssh %USERNAME%@%SERVER_ADDR% -pw %PASSWORD% -batch "%CMD_CHECK_SPRINGBOOT%"

REM Launch Windows Terminal and execute the server type determination commands
start "" wt.exe --title "Determine Server Type - %SERVER_ADDR%" ^
    -- bash -c "%PLINK_CMD_JBOSS%" ^| findstr "jboss" ^&^& (echo JBoss server detected.) ^& goto jboss_server ^
    || bash -c "%PLINK_CMD_SPRINGBOOT%" ^| findstr "springboot" ^&^& (echo Spring Boot server detected.) ^& goto springboot_server ^
    || (echo Regular server detected or no known server type found.) ^& goto regular_server

:jboss_server
echo JBoss server detected. Navigating to JBoss directory...
start "" wt.exe --title "JBoss Server - %SERVER_ADDR%" -- plink -ssh %USERNAME%@%SERVER_ADDR% -pw %PASSWORD% -t "cd /opt/jboss && exec bash"
goto end

:springboot_server
echo Spring Boot server detected. Navigating to Spring Boot directory...
start "" wt.exe --title "Spring Boot Server - %SERVER_ADDR%" -- plink -ssh %USERNAME%@%SERVER_ADDR% -pw %PASSWORD% -t "cd /opt/springboot && exec bash"
goto end

:regular_server
echo Regular server or unknown server type detected. Leaving session open...
start "" wt.exe --title "Regular Server - %SERVER_ADDR%" -- plink -ssh %USERNAME%@%SERVER_ADDR% -pw %PASSWORD% -t "exec bash"
goto end

:end
echo Script execution completed.
pause
