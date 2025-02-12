#!/bin/bash

# Jira Credentials
JIRA_URL="https://your-jira-instance.atlassian.net"
JIRA_USER="your-email@example.com"
JIRA_API_TOKEN="your-api-token"

# Define the array of issues
issues=("abcddrf-123" "abcdgrp-456" "xyzabcd-789")

# Define the mapping of prefixes (first 7 characters) to assignees
declare -A assignee_map
assignee_map["abcddrf"]="user1"
assignee_map["abcdgrp"]="user2"
assignee_map["xyzabcd"]="user3"

# Function to change the assignee in Jira
change_assignee() {
    local issue=$1
    local assignee=$2

    # JSON payload for updating the assignee
    json_payload=$(jq -n \
        --arg assignee "$assignee" \
        '{fields: {assignee: {name: $assignee}}}'
    )

    # Make the API call to update the assignee
    response=$(curl -s -u "$JIRA_USER:$JIRA_API_TOKEN" \
        -X PUT \
        -H "Content-Type: application/json" \
        --data "$json_payload" \
        "$JIRA_URL/rest/api/2/issue/$issue")

    # Check the response
    if [[ $response == *"error"* ]]; then
        echo "Failed to update assignee for $issue: $response"
    else
        echo "Successfully updated assignee for $issue to $assignee"
    fi
}

# Iterate through the issues
for issue in "${issues[@]}"; do
    prefix=${issue:0:7}  # Extract the first 7 characters

    # Determine the assignee based on the prefix
    assignee=${assignee_map[$prefix]}

    if [[ -n "$assignee" ]]; then
        change_assignee "$issue" "$assignee"
    else
        echo "No assignee mapping found for prefix $prefix in issue $issue"
    fi
done