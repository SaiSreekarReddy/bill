@echo off
setlocal enabledelayedexpansion

:: Define Jira credentials and URL
set "username=YOUR_USERNAME"
set "password=YOUR_PASSWORD"
set "jira_url=https://your-jira-url/rest/api/2"

:: Define custom field IDs for target start/end date
set "start_date_field=customfield_24100"
set "end_date_field=customfield_24101"

:: Parent issue ID (you can change this to read from input or file)
set "parent_issue_key=PROJECT-123"  :: Replace with your parent issue key

:: Subtask summary and description
set "subtask_summary=Subtask created from batch"
set "subtask_description=This is a subtask created from the parent issue."

:: Step 1: Get the target start/end date from the parent issue
echo Fetching target start/end date from %parent_issue_key%...
curl -u %username%:%password% -X GET -H "Content-Type: application/json" ^
"%jira_url%/issue/%parent_issue_key%" ^
> parent_issue.json

:: Read the entire JSON file into a variable
set /p json_content=<parent_issue.json

:: Extract the start date (customfield_24100)
for /F "tokens=2 delims=:" %%A in ('echo %json_content% ^| findstr /C:"%start_date_field%"') do (
    set "start_date=%%A"
)

:: Extract the end date (customfield_24101)
for /F "tokens=2 delims=:" %%B in ('echo %json_content% ^| findstr /C:"%end_date_field%"') do (
    set "end_date=%%B"
)

:: Clean up the extracted dates (remove quotes, spaces, and any trailing commas)
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
-d "{\"fields\": {\"project\": {\"key\": \"PROJECT\"}, \"parent\": {\"key\": \"%parent_issue_key%\"}, \"summary\": \"%subtask_summary%\", \"description\": \"%subtask_description%\", \"issuetype\": {\"name\": \"Sub-task\"}, \"%start_date_field%\": \"%start_date%\", \"%end_date_field%\": \"%end_date%\"}}" ^
"%jira_url%/issue/"

echo Subtask creation complete.

endlocal
