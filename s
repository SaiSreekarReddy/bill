@echo off
setlocal enabledelayedexpansion

set /p issueKey="Enter the Jira issue key (e.g., PROJ-123): "
set jiraUsername=YOUR_JIRA_USERNAME
set jiraPassword=YOUR_JIRA_PASSWORD
set jiraURL=https://your_jira_instance.atlassian.net

curl -u %jiraUsername%:%jiraPassword% -X GET -H "Content-Type: application/json" ^
    %jiraURL%/rest/api/2/issue/%issueKey% > response.json

set customfield_24100=
set customfield_24101=
set capture=0

for /f "usebackq delims=" %%i in (response.json) do (
    set line=%%i
    rem Remove spaces at the start of the line
    set line=!line: =!

    rem Check for customfield_24100
    echo !line! | findstr "\"customfield_24100\"" >nul
    if !errorlevel! equ 0 (
        set capture=1
    )

    rem Check for customfield_24101
    echo !line! | findstr "\"customfield_24101\"" >nul
    if !errorlevel! equ 0 (
        set capture=2
    )

    if !capture! equ 1 (
        set "customfield_24100=!line!"
        set capture=0
    )

    if !capture! equ 2 (
        set "customfield_24101=!line!"
        set capture=0
    )
)

echo Value of customfield_24100: %customfield_24100%
echo Value of customfield_24101: %customfield_24101%

del response.json
endlocal
