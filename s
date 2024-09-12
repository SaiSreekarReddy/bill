@echo off
setlocal enabledelayedexpansion

:: Define the list of IP addresses directly in the script (space-separated)
set "IP_LIST=192.168.1.10 192.168.1.11 192.168.1.12"

:: Set your SSH username and password
set "USERNAME=your_username"
set "PASSWORD=your_password"

:: Loop through each IP in the list
for %%A in (%IP_LIST%) do (
    set "SERVER_IP=%%A"
    echo Checking server !SERVER_IP!...

    :: Detect the server type (JBoss or Spring Boot)
    set "cmd2=if [ -d '/opt/jboss' ]; then echo jboss; elif [ -d '/opt/springboot' ]; then echo springboot; else echo regular; fi"

    :: Execute Plink to detect the server type
    for /f "delims=" %%i in ('plink.exe -batch -ssh !USERNAME!@!SERVER_IP! -pw !PASSWORD! -t "bash -c \"%cmd2%\""') do set "serverType=%%i"

    :: Output detected server type
    echo Detected Server Type for !SERVER_IP!: !serverType!

    :: Fetch application name based on the detected server type
    if "!serverType!" == "jboss" (
        for /f "delims=" %%j in ('plink.exe -batch -ssh !USERNAME!@!SERVER_IP! -pw !PASSWORD! -t "bash -c \"ls /opt/jboss/instance | head -n 1\""') do set "appName=%%j"
        set "appName=!appName:_0000=!"  :: Clean the name if necessary
    ) else if "!serverType!" == "springboot" (
        for /f "delims=" %%j in ('plink.exe -batch -ssh !USERNAME!@!SERVER_IP! -pw !PASSWORD! -t "bash -c \"ls /opt/springboot/applications | head -n 1\""') do set "appName=%%j"
        set "appName=!appName:-web=!"  :: Clean the name if necessary
    ) else (
        echo No specific server detected on !SERVER_IP!, skipping...
        set "appName=NoAppFound"
        goto :continue
    )

    :: Check the status of the application using appropriate command for JBoss or Spring Boot
    if "!serverType!" == "jboss" (
        for /f "delims=" %%s in ('plink.exe -batch -ssh !USERNAME!@!SERVER_IP! -pw !PASSWORD! -t "bash -c \"echo !PASSWORD! | sudo -S /opt/jboss/bin/systemctl status !appName!\""') do set "status=%%s"
    ) else if "!serverType!" == "springboot" (
        for /f "delims=" %%s in ('plink.exe -batch -ssh !USERNAME!@!SERVER_IP! -pw !PASSWORD! -t "bash -c \"echo !PASSWORD! | sudo -S service !appName! status\""') do set "status=%%s"
    )

    echo Application Name: !appName!
    echo Application Status: !status!

    :: Check if the application is inactive and attempt to start it if necessary
    if "!status!" == "inactive" (
        echo Application is inactive, attempting to start...

        if "!serverType!" == "jboss" (
            plink.exe -batch -ssh !USERNAME!@!SERVER_IP! -pw !PASSWORD! -t "bash -c \"echo !PASSWORD! | sudo -S /opt/jboss/bin/systemctl start !appName!\""
        ) else if "!serverType!" == "springboot" (
            plink.exe -batch -ssh !USERNAME!@!SERVER_IP! -pw !PASSWORD! -t "bash -c \"echo !PASSWORD! | sudo -S service !appName! start\""
        )

        :: Remove the last line from the history to clear the password
        plink.exe -batch -ssh !USERNAME!@!SERVER_IP! -pw !PASSWORD! -t "bash -c \"history -d \$(history 1)\""
        
        echo Server !SERVER_IP! - Application was down and has been started
    ) else if "!status!" == "active" (
        echo Server !SERVER_IP! - Application is running
    ) else (
        echo Server !SERVER_IP! - Unknown status: !status!
    )

    :continue
    echo --------------------------
)

pause
endlocal
