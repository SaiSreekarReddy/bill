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

    :: Detect the server type (JBoss or Spring Boot) as a separate Plink command
    plink.exe -batch -ssh !USERNAME!@!SERVER_IP! -pw !PASSWORD! -t "bash -c 'if [ -d /opt/jboss ]; then echo jboss; elif [ -d /opt/springboot ]; then echo springboot; else echo regular; fi'" > tmp_server_type.txt
    set /p serverType=<tmp_server_type.txt
    del tmp_server_type.txt

    :: Output detected server type
    echo Detected Server Type for !SERVER_IP!: !serverType!

    :: Fetch application name based on the detected server type
    if "!serverType!" == "jboss" (
        plink.exe -batch -ssh !USERNAME!@!SERVER_IP! -pw !PASSWORD! -t "bash -c 'ls /opt/jboss/instance | head -n 1'" > tmp_app_name.txt
        set /p appName=<tmp_app_name.txt
        del tmp_app_name.txt
        set "appName=!appName:_0000=!"
    ) else if "!serverType!" == "springboot" (
        plink.exe -batch -ssh !USERNAME!@!SERVER_IP! -pw !PASSWORD! -t "bash -c 'ls /opt/springboot/applications | head -n 1'" > tmp_app_name.txt
        set /p appName=<tmp_app_name.txt
        del tmp_app_name.txt
        set "appName=!appName:-web=!"
    ) else (
        echo No specific server detected on !SERVER_IP!, skipping...
        set "appName=NoAppFound"
        goto :continue
    )

    :: Output detected application name
    echo Application Name for !SERVER_IP!: !appName!

    :: Check the status of the application
    if "!serverType!" == "jboss" (
        plink.exe -batch -ssh !USERNAME!@!SERVER_IP! -pw !PASSWORD! -t "bash -c 'echo !PASSWORD! | sudo -S /opt/jboss/bin/systemctl is-active !appName!'" > tmp_status.txt
        set /p status=<tmp_status.txt
        del tmp_status.txt
    ) else if "!serverType!" == "springboot" (
        plink.exe -batch -ssh !USERNAME!@!SERVER_IP! -pw !PASSWORD! -t "bash -c 'echo !PASSWORD! | sudo -S service !appName! status'" > tmp_status.txt
        set /p status=<tmp_status.txt
        del tmp_status.txt
    )

    :: Output application status
    echo Application Status for !SERVER_IP!: !status!

    :: If the application is inactive, attempt to start it
    if "!status!" == "inactive" (
        echo Application is inactive, attempting to start...

        if "!serverType!" == "jboss" (
            plink.exe -batch -ssh !USERNAME!@!SERVER_IP! -pw !PASSWORD! -t "bash -c 'echo !PASSWORD! | sudo -S /opt/jboss/bin/systemctl start !appName!'"
        ) else if "!serverType!" == "springboot" (
            plink.exe -batch -ssh !USERNAME!@!SERVER_IP! -pw !PASSWORD! -t "bash -c 'echo !PASSWORD! | sudo -S service !appName! start'"
        )

        :: Clear the password from history
        plink.exe -batch -ssh !USERNAME!@!SERVER_IP! -pw !PASSWORD! -t "bash -c 'history -d \$(history 1)'"
        
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
