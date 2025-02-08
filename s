#!/bin/bash

# Function to fetch a Jira ticket summary and extract the required pattern
get_two_digit_before_double_dash() {
    local jira_url=$1
    local jira_user=$2
    local jira_pass=$3
    local ticket_id=$4

    # Fetch the JSON response from the Jira API
    local response=$(curl -s -u "${jira_user}:${jira_pass}" -X GET \
                     -H "Content-Type: application/json" \
                     "${jira_url}/${ticket_id}")

    # Extract the summary from the JSON response
    local summary=$(echo "$response" | jq -r '.fields.summary')

    # Use grep to find the two-digit alphanumeric or numeric characters before '--'
    local match=$(echo "$summary" | grep -oE '[a-zA-Z0-9]{2}(?=--)')

    # If a match is found, print it; otherwise, indicate no match
    if [[ -n "$match" ]]; then
        echo "$match"
    else
        echo "No two-digit alphanumeric or numeric characters found before '--' in the summary."
    fi
}

# Example usage of the function
jira_url="https://your.jira.instance/rest/api/2/issue"
jira_user="your_username"
jira_pass="your_password"
ticket_id="YOUR-TICKET-ID"

# Call the function and capture the output
result=$(get_two_digit_before_double_dash "$jira_url" "$jira_user" "$jira_pass" "$ticket_id")

# Print the result
echo "Extracted Value: $result"









-------------------------------------------------




@echo off
:: --- Configuration ---
set "JIRA_URL=https://your.jira.instance/rest/api/2/issue"
set "JIRA_USER=your_username"
set "JIRA_PASS=your_password"
set "PARENT_TICKET=YOUR-PARENT-TICKET-ID"
set "PROJECT_KEY=YOUR-PROJECT-KEY"

:: Prompt user for subtask details
set /p "SUMMARY=Enter the subtask summary: "
set /p "DESCRIPTION=Enter the subtask description: "
set /p "CUSTOMFIELD_24100=Enter the value for customfield_24100: "

:: --- Create the JSON payload ---
set "PAYLOAD={
  \"fields\": {
    \"project\": { \"key\": \"%PROJECT_KEY%\" },
    \"parent\": { \"key\": \"%PARENT_TICKET%\" },
    \"summary\": \"%SUMMARY%\",
    \"description\": \"%DESCRIPTION%\",
    \"issuetype\": { \"name\": \"Sub-task\" },
    \"customfield_24100\": \"%CUSTOMFIELD_24100%\"
  }
}"

:: --- Create the subtask ---
curl -s -u "%JIRA_USER%:%JIRA_PASS%" -X POST -H "Content-Type: application/json" ^
  -d "%PAYLOAD%" "%JIRA_URL%" > response.txt

:: Check if the creation was successful
findstr /i "key" response.txt >nul
if %errorlevel% equ 0 (
  echo Subtask created successfully!
  type response.txt
) else (
  echo Failed to create subtask. Check response.txt for details.
  type response.txt
)
