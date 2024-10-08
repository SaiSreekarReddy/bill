@echo off
setlocal enabledelayedexpansion

cls

set "username=%~1"
set "password=X2"
set "crdfullupgradeepic=CRPHCRD-19891"
set "coffullupgradeepic=CRPHCOF-20580"

:: Prompt for Jira ticket number or URL
:ticketPrompt
set "ticketNumber="
set "ticketInput="

set /p ticketInput="Enter Jira Ticket Number or URL (or type 'exit' to quit): "
if /i "%ticketInput%"=="exit" goto :end
if /i "%ticketInput%"=="EXIT" goto :end
if "%ticketInput%"=="" goto :ticketPrompt

:: Extract the ticket number if a URL is provided
for /f "tokens=4 delims=/" %%i in ("%ticketInput:/https://track.td.com/browse/=%") do set "ticketNumber=%%i"
if not defined ticketNumber set "ticketNumber=%ticketInput%"

if "%ticketNumber%"=="" (
    echo Ticket number cannot be empty.
    goto :ticketPrompt
)

call :epic_link
call :check
pause
call :transition

:testset
set "testset="

set /p testset="Enter the test set: "
if /i "%testset%"=="" goto :testset

:: Extract the project key from the ticket number (everything before the first hyphen)
for /f "tokens=1 delims=-" %%a in ("%ticketNumber%") do set project_key=%%a

set "month="
set /p month="Enter the month you want to upgrade: "

:main
set "malcode="
set /p malcode="Enter the malcode (type 'exit' to quit): "
set "assignee="

call :setassign
if /i "%malcode%"=="exit" goto :ticketPrompt
if "%malcode%"=="" goto :main
echo Creating subtask with malcode: %malcode%

:: Construct the JSON payload
set json_data={"fields": {"project":{"key": "%project_key%"}, "parent": {"key": "%ticketNumber%"}, "summary":"Please Upgrade the %malcode% in %testset% to %month%", "issuetype": {"name":"Sub-task"}, "assignee": {"name": "%assignee%"}}}

:: Save the JSON to a temporary file
echo %json_data% > json_payload.txt

:: Use curl to create the subtask
curl -D- -u %username%:%password% -X POST -d @json_payload.txt -H "Content-Type: application/json" https://track.td.com/rest/api/2/issue/

:: Cleanup
del json_payload.txt
call :epic_link
goto :main

:end
echo Exiting program...
exit /b

:setassign
set "uwbare=NAIDS29"
set "aapare=TAE7763"
set found=false

:: Check in list 1
echo %malcode% | findstr /i "MP AMS OPDH ADDRP" >nul && (
    set "assignee=%aapare%"
    goto :gotassignee
)

:: Check in list 2
echo %malcode% | findstr /i "NAIDS29" >nul && (
    set "assignee=%uwbare%"
    goto :gotassignee
)

echo "TAE7763 is Piyush"
echo "NAIDS29 is Sriram"
set /p assignee="Enter assignee (or type 'exit' to quit): "
if /i "%assignee%"=="exit" goto :end
if "%assignee%"=="" goto :ticketPrompt

:gotassignee
echo Got the assignee: %assignee%
goto :eof

:epic_link
if /i "%ticketNumber:~0,7%"=="CRPHCRD" (
    curl -u %username%:%password% -X PUT -H "Content-Type: application/json" -d "{\"fields\":{\"customfield_10006\":\"%crdfullupgradeepic%\"}}" https://track.td.com/rest/api/2/issue/%ticketNumber%
    echo CRD epic added
) else if /i "%ticketNumber:~0,7%"=="CRPHCOF" (
    curl -u %username%:%password% -X PUT -H "Content-Type: application/json" -d "{\"fields\":{\"customfield_10006\":\"%coffullupgradeepic%\"}}" https://track.td.com/rest/api/2/issue/%ticketNumber%
    echo COF epic added
) else (
    echo Don't have your epic link yet
)
goto :eof

:check
:: Get the current status of the Jira issue
curl -s -u %username%:%password% -X GET -H "Content-Type: application/json" https://track.td.com/rest/api/2/issue/%ticketNumber%?fields=status > current_status.json

:: Extract the status
for /f "tokens=3 delims=:," %%i in ('findstr "status" current_status.json') do set "current_status=%%i"
set "current_status=%current_status:~1,-1%"  :: Clean up the extracted value

if "%current_status%"=="" (
    echo Error: Failed to extract the current status.
    goto :end
)

echo Current status is: %current_status%
del current_status.json
goto :eof

:transition
:: Perform the necessary transitions based on the current status

if /i "%current_status%"=="To Do" (
    echo Moving ticket from 'To Do' to 'In Progress'...
    call :move_to_refining
    call :move_to_waiting_on_dependencies
    call :move_to_ready_to_start
    call :move_to_in_progress
) else if /i "%current_status%"=="Refining" (
    echo Ticket is in 'Refining', moving to 'In Progress'...
    call :move_to_waiting_on_dependencies
    call :move_to_ready_to_start
    call :move_to_in_progress
) else if /i "%current_status%"=="Waiting on Dependencies" (
    echo Ticket is in 'Waiting on Dependencies', moving to 'In Progress'...
    call :move_to_ready_to_start
    call :move_to_in_progress
) else if /i "%current_status%"=="Ready to Start" (
    echo Ticket is in 'Ready to Start', moving to 'In Progress'...
    call :move_to_in_progress
) else if /i "%current_status%"=="In Progress" (
    echo Ticket is already 'In Progress'. No transition needed.
) else (
    echo No valid transition path for the current status: %current_status%
)
goto :eof

:move_to_refining
echo Moving to Refining...
curl -u %username%:%password% -X POST -H "Content-Type: application/json" --data "{\"transition\":{\"id\":\"701\"}}" https://track.td.com/rest/api/2/issue/%ticketNumber%/transitions
goto :eof

:move_to_waiting_on_dependencies
echo Moving to Waiting on Dependencies...
curl -u %username%:%password% -X POST -H "Content-Type: application/json" --data "{\"transition\":{\"id\":\"681\"}}" https://track.td.com/rest/api/2/issue/%ticketNumber%/transitions
goto :eof

:move_to_ready_to_start
echo Moving to Ready to Start...
curl -u %username%:%password% -X POST -H "Content-Type: application/json" --data "{\"transition\":{\"id\":\"691\"}}" https://track.td.com/rest/api/2/issue/%ticketNumber%/transitions
goto :eof

:move_to_in_progress
echo Moving to In Progress...
curl -u %username%:%password% -X POST -H "Content-Type: application/json" --data "{\"transition\":{\"id\":\"711\"}}" https://track.td.com/rest/api/2/issue/%ticketNumber%/transitions
goto :eof
