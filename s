@echo off
setlocal enabledelayedexpansion

:: Set Jira credentials and URL
set "USERNAME=your_username"
set "PASSWORD=your_password_or_api_token"
set "JIRA_BASE_URL=https://yourcompany.atlassian.net"
set "ISSUE_KEY=PROJ-123"

:: Call Jira API to fetch issue details (summary only)
curl -s -u "%USERNAME%:%PASSWORD%" -X GET "%JIRA_BASE_URL%/rest/api/2/issue/%ISSUE_KEY%?fields=summary" > response.json

:: Extract the summary from the JSON response (manually parsing without jq)
for /f "tokens=*" %%A in ('findstr /R /C:"\"summary\":" response.json') do (
    set "SUMMARY=%%A"
)

:: Clean up JSON formatting to extract just the summary text
set "SUMMARY=%SUMMARY: \"summary\"=:%"
set "SUMMARY=%SUMMARY:,=%"
set "SUMMARY=%SUMMARY: \"=%"
set "SUMMARY=%SUMMARY:\" =%"
set "SUMMARY=%SUMMARY: }=%"
set "SUMMARY=%SUMMARY: }=%"
set "SUMMARY=%SUMMARY:"=%"

:: Output the cleaned summary
echo Full Summary: "%SUMMARY%"

:: Split summary into individual words
set i=0
for %%B in (%SUMMARY%) do (
    set /a i+=1
    set "WORD!i!=%%B"
)

:: Display extracted words as variables
echo.
echo Extracted Words:
for /L %%X in (1,1,%i%) do (
    echo WORD%%X=!WORD%%X!
)

:: Clean up response file
del response.json

endlocal