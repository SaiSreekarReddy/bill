#!/bin/bash

# Jira Credentials
JIRA_URL="https://your-jira-instance.atlassian.net"
JIRA_USER="your-email@example.com"
JIRA_API_TOKEN="your-api-token"

# Define the mapping of prefixes (first 7 characters) to watchers
declare -A watcher_map
watcher_map["abcddrf"]="watcher1,watcher2"
watcher_map["abcdgrp"]="watcher3"
watcher_map["xyzabcd"]="watcher4,watcher5"

# Function to create a subtask and add watchers
create_subtask_with_watchers() {
    local parent_issue=$1
    local summary=$2
    local description=$3
    local watchers=$4

    # JSON payload for subtask creation
    json_payload=$(jq -n \
        --arg summary "$summary" \
        --arg description "$description" \
        --arg parent "$parent_issue" \
        --arg issueType "Sub-task" \
        '{fields: {summary: $summary, description: $description, issuetype: {name: $issueType}, parent: {key: $parent}}}'
    )

    # Create the subtask in Jira
    response=$(curl -s -u "$JIRA_USER:$JIRA_API_TOKEN" \
        -X POST \
        -H "Content-Type: application/json" \
        --data "$json_payload" \
        "$JIRA_URL/rest/api/2/issue/")

    # Extract the new subtask key
    subtask_key=$(echo "$response" | jq -r '.key')

    if [[ -z "$subtask_key" || "$subtask_key" == "null" ]]; then
        echo "Failed to create subtask: $response"
        return 1
    fi

    echo "Subtask created: $subtask_key"

    # Add watchers to the subtask
    IFS=',' read -ra watcher_array <<< "$watchers"
    for watcher in "${watcher_array[@]}"; do
        watcher_response=$(curl -s -u "$JIRA_USER:$JIRA_API_TOKEN" \
            -X POST \
            -H "Content-Type: application/json" \
            --data "\"$watcher\"" \
            "$JIRA_URL/rest/api/2/issue/$subtask_key/watchers")

        if [[ "$watcher_response" == *"error"* ]]; then
            echo "Failed to add watcher $watcher to $subtask_key: $watcher_response"
        else
            echo "Watcher $watcher added to $subtask_key"
        fi
    done
}

# Example usage of the function
parent_issue="PROJECT-123"  # Replace with your parent issue key
summary="Subtask for Malcode Handling"
description="Description of the subtask with relevant details."
prefix="abcddrf"
watchers=${watcher_map[$prefix]}

if [[ -n "$watchers" ]]; then
    create_subtask_with_watchers "$parent_issue" "$summary" "$description" "$watchers"
else
    echo "No watchers defined for prefix $prefix"
fi