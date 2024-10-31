@echo off
set /p issueKey="Enter the Jira issue key (e.g., PROJ-123): "
set jiraUsername=YOUR_JIRA_USERNAME
set jiraPassword=YOUR_JIRA_PASSWORD
set jiraURL=https://your_jira_instance.atlassian.net

curl -u %jiraUsername%:%jiraPassword% -X GET -H "Content-Type: application/json" ^
    %jiraURL%/rest/api/2/issue/%issueKey% > response.json

for /f "delims=" %%i in ('powershell -command ^
    "($json = Get-Content response.json | ConvertFrom-Json).fields.customfield_24100"') do set customfield_24100=%%i

for /f "delims=" %%i in ('powershell -command ^
    "($json = Get-Content response.json | ConvertFrom-Json).fields.customfield_24101"') do set customfield_24101=%%i

echo Value of customfield_24100: %customfield_24100%
echo Value of customfield_24101: %customfield_24101%

del response.json
