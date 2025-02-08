#!/bin/bash

# Function to create a Jira subtask
create_jira_subtask() {
    local jira_url=$1
    local jira_user=$2
    local jira_pass=$3
    local project_key=$4
    local parent_ticket=$5
    local summary=$6
    local description=$7
    local customfield_1=$8
    local customfield_2=$9
    local assignee=${10}

    # Prepare the JSON payload
    local payload=$(cat <<EOF
{
  "fields": {
    "project": { "key": "$project_key" },
    "parent": { "key": "$parent_ticket" },
    "summary": "$summary",
    "description": "$description",
    "issuetype": { "name": "Sub-task" },
    "customfield_1": "$customfield_1",
    "customfield_2": "$customfield_2",
    "assignee": { "name": "$assignee" }
  }
}
EOF
)

    # Make the API call to create the subtask
    local response=$(curl -s -u "$jira_user:$jira_pass" -X POST \
                     -H "Content-Type: application/json" \
                     -d "$payload" \
                     "$jira_url")

    # Check if the subtask was created successfully
    if echo "$response" | grep -q '"key"'; then
        echo "Subtask created successfully!"
        echo "$response"
    else
        echo "Failed to create subtask. Response from Jira:"
        echo "$response"
    fi
}

# Example usage
jira_url="https://your.jira.instance/rest/api/2/issue"
jira_user="your_username"
jira_pass="your_password"
project_key="PROJECT_KEY"
parent_ticket="PARENT-TICKET-ID"
summary="Subtask Summary Example"
description="Subtask Description Example"
customfield_1="Custom Value 1"
customfield_2="Custom Value 2"
assignee="assignee_username"

# Call the function to create the subtask
create_jira_subtask "$jira_url" "$jira_user" "$jira_pass" "$project_key" "$parent_ticket" \
                    "$summary" "$description" "$customfield_1" "$customfield_2" "$assignee"
