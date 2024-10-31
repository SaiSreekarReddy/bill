@echo off
setlocal enabledelayedexpansion

:: Input parameters
set /p issueKey="Enter the Jira parent issue key (e.g., PROJ-123): "
set /p subtaskSummary="Enter the subtask summary: "
set /p subtaskDescription="Enter the subtask description: "
set jiraUsername=YOUR_JIRA_USERNAME
set jiraPassword=YOUR_JIRA_PASSWORD
set jiraURL=https://your_jira_instance.atlassian.net
set projectKey=PROJECT_KEY
set subtaskTypeID=SUBTASK_ISSUE_TYPE_ID

:: Step 1: Fetch custom fields from the parent issue
curl -u %jiraUsername%:%jiraPassword% -X GET -H "Content-Type: application/json" ^
    %jiraURL%/rest/api/2/issue/%issueKey% > response.json

:: Wait a bit to ensure the file is written properly
timeout /t 2 > nul

:: Validate JSON content
for /f "delims=" %%i in (response.json) do set line=%%i
if "!line!"=="" (
    echo Error: JSON response is empty or malformed.
    exit /b
)

:: Step 2: Parse custom fields using PowerShell
for /f "delims=" %%i in ('powershell -command ^
    "(Get-Content response.json | Out-String) | ConvertFrom-Json | ForEach-Object { $_.fields.customfield_24100 }"') do set customfield_24100=%%i

for /f "delims=" %%i in ('powershell -command ^
    "(Get-Content response.json | Out-String) | ConvertFrom-Json | ForEach-Object { $_.fields.customfield_24101 }"') do set customfield_24101=%%i

:: Check if the fields were parsed correctly
if "%customfield_24100%"=="" (
    echo Warning: customfield_24100 was not found or is empty.
)
if "%customfield_24101%"=="" (
    echo Warning: customfield_24101 was not found or is empty.
)

:: Step 3: Create JSON payload for the subtask
(
echo {
echo    "fields": {
echo        "project": {
echo            "key": "%projectKey%"
echo        },
echo        "parent": {
echo            "key": "%issueKey%"
echo        },
echo        "summary": "%subtaskSummary%",
echo        "description": "%subtaskDescription%",
echo        "issuetype": {
echo            "id": "%subtaskTypeID%"
echo        },
echo        "customfield_24100": "%customfield_24100%",
echo        "customfield_24101": "%customfield_24101%"
echo    }
echo }
) > subtask_payload.json

:: Step 4: Create the subtask
curl -u %jiraUsername%:%jiraPassword% -X POST -H "Content-Type: application/json" ^
    -d @subtask_payload.json ^
    %jiraURL%/rest/api/2/issue/

:: Clean up files
del response.json
del subtask_payload.json

endlocal
