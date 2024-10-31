@echo off
set /p issueKey="Enter the Jira issue key (e.g., PROJ-123): "
set jiraUsername=YOUR_JIRA_USERNAME
set jiraPassword=YOUR_JIRA_PASSWORD
set jiraURL=https://your_jira_instance.atlassian.net

curl -u %jiraUsername%:%jiraPassword% -X GET -H "Content-Type: application/json" ^
    %jiraURL%/rest/api/2/issue/%issueKey% > response.json

for /f "tokens=*" %%i in (response.json) do (
    echo %%i | findstr "customfield_24100\|customfield_24101"
)

del response.json
