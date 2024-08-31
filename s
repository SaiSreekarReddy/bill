@echo off
:menu
cls

:: Create a stylish title using ASCII art or simple formatting
echo  ==============================================
echo  =                                             =
echo  =                ARE TOOLS                    =
echo  =                                             =
echo  ==============================================
echo.
echo  =======================================================
echo  =                                                    =
echo  =  1. Download logs filtered by date                 =
echo  =  2. Stop/Start/Restart the server                  =
echo  =  3. Navigate to a specific path and leave session  =
echo  =  4. Exit                                           =
echo  =                                                    =
echo  =======================================================
echo.

:: Prompt user for input
set /p choice=Please enter your choice (1-4): 

:: Direct to the appropriate label based on the choice
if %choice%==1 goto download_logs
if %choice%==2 goto manage_server
if %choice%==3 goto navigate_path
if %choice%==4 goto exit
goto menu

:download_logs
cls
echo You chose to download logs.
pause
goto menu

:manage_server
cls
echo You chose to manage the server.
pause
goto menu

:navigate_path
cls
echo You chose to navigate to a specific path.
pause
goto menu

:exit
exit
