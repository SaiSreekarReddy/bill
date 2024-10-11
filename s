@echo off
setlocal enabledelayedexpansion

:: Define Jira credentials and URL
set "username=YOUR_USERNAME"
set "password=YOUR_PASSWORD"
set "jira_url=https://your-jira-url/rest/api/2"

:: Parent issue ID
set "parent_issue_key=PROJECT-123"

:: Subtask summary and description
set "subtask_summary=Subtask created from batch"
set "subtask_description=This is a subtask created from the parent issue."

:: Step 1: Get the target start/end date from the parent issue
echo Fetching target start/end date from %parent_issue_key%...
curl -u %username%:%password% -X GET -H "Content-Type: application/json" ^
"%jira_url%/issue/%parent_issue_key%?fields=customfield_24100,customfield_24101" ^
> parent_issue.json

:: Extract the start date and end date from the JSON file (assuming a simple format)
for /F "tokens=2 delims=:" %%A in ('findstr "customfield_24100" parent_issue.json') do (
    set "start_date=%%A"
)
for /F "tokens=2 delims=:" %%B in ('findstr "customfield_24101" parent_issue.json') do (
    set "end_date=%%B"
)

:: Clean up the extracted dates (remove quotes, spaces, and commas)
set "start_date=%start_date:"=%"
set "start_date=%start_date: =%"
set "end_date=%end_date:"=%"
set "end_date=%end_date: =%"
set "end_date=%end_date:,=%"

echo Target Start Date: %start_date%
echo Target End Date: %end_date%

:: Step 2: Create the subtask
echo Creating subtask for %parent_issue_key%...
curl -u %username%:%password% -X POST -H "Content-Type: application/json" ^
-d "{\"fields\": {\"project\": {\"key\": \"PROJECT\"}, \"parent\": {\"key\": \"%parent_issue_key%\"}, \"summary\": \"%subtask_summary%\", \"description\": \"%subtask_description%\", \"issuetype\": {\"name\": \"Sub-task\"}, \"customfield_24100\": \"%start_date%\", \"customfield_24101\": \"%end_date%\"}}" ^
"%jira_url%/issue/"

echo Subtask creation complete.

endlocal
