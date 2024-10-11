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

:: Extract the target start and end dates (custom fields) from the JSON response
for /F "tokens=*" %%A in ('findstr /C:"%start_date_field%" parent_issue.json') do (
    set "start_date=%%A"
)
for /F "tokens=*" %%B in ('findstr /C:"%end_date_field%" parent_issue.json') do (
    set "end_date=%%B"
)

:: Assuming the values are in the format: "customfield_24100": "YYYY-MM-DD", "customfield_24101": "YYYY-MM-DD"
:: Parse the start and end dates from the JSON response
for /F "tokens=2 delims=:," %%C in ('echo %start_date%') do (
    set "parsed_start_date=%%C"
)
for /F "tokens=2 delims=:," %%D in ('echo %end_date%') do (
    set "parsed_end_date=%%D"
)

echo Target Start Date: %parsed_start_date%
echo Target End Date: %parsed_end_date%

:: Step 2: Create the subtask
echo Creating subtask for %parent_issue_key%...
curl -u %username%:%password% -X POST -H "Content-Type: application/json" ^
-d "{\"fields\": {\"project\": {\"key\": \"PROJECT\"}, \"parent\": {\"key\": \"%parent_issue_key%\"}, \"summary\": \"%subtask_summary%\", \"description\": \"%subtask_description%\", \"issuetype\": {\"name\": \"Sub-task\"}, \"%start_date_field%\": \"%parsed_start_date%\", \"%end_date_field%\": \"%parsed_end_date%\"}}" ^
"%jira_url%/issue/"

echo Subtask creation complete.

endlocal
