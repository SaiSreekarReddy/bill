#!/bin/bash

# Jira credentials
JIRA_URL="https://your-jira-instance.atlassian.net"
JIRA_USER="your-email@example.com"
JIRA_API_TOKEN="your-api-token"

# Define the mapping of prefixes (first 7 characters) to watchers
declare -A watcher_map
watcher_map["abcddrf"]="watcher1,watcher2"
watcher_map["abcdgrp"]="watcher3"
watcher_map["xyzabcd"]="watcher4,watcher5"

# Function to create a subtask
create_jira_subtask() {
    local user=$1
    local pass=$2
    local project_key=$3
    local parent_issue=$4
    local summary=$5
    local description=$6

    # JSON payload for subtask creation
    json_payload=$(jq -n \
        --arg summary "$summary" \
        --arg description "$description" \
        --arg parent "$parent_issue" \
        --arg issueType "Sub-task" \
        '{fields: {summary: $summary, description: $description, issuetype: {name: $issueType}, parent: {key: $parent}}}'
    )

    # Create the subtask
    response=$(curl -s -u "$user:$pass" \
        -X POST \
        -H "Content-Type: application/json" \
        --data "$json_payload" \
        "$JIRA_URL/rest/api/2/issue/")

    # Extract the subtask key
    subtask_key=$(echo "$response" | jq -r '.key')

    if [[ -z "$subtask_key" || "$subtask_key" == "null" ]]; then
        echo "Failed to create subtask: $response"
        return 1
    fi

    echo "Subtask created: $subtask_key"
    echo "$subtask_key"
}

# Function to add watchers to a subtask
add_watchers() {
    local subtask_key=$1
    local watchers=$2

    IFS=',' read -ra watcher_array <<< "$watchers"
    for watcher in "${watcher_array[@]}"; do
        response=$(curl -s -u "$JIRA_USER:$JIRA_API_TOKEN" \
            -X POST \
            -H "Content-Type: application/json" \
            --data "\"$watcher\"" \
            "$JIRA_URL/rest/api/2/issue/$subtask_key/watchers")

        if [[ "$response" == *"error"* ]]; then
            echo "Failed to add watcher $watcher to $subtask_key: $response"
        else
            echo "Watcher $watcher added to $subtask_key"
        fi
    done
}

# Main loop
if [[ -n "$group_var" ]]; then
    eval "group_array=(\"\${$group_var[@]}\")"  # Expand group array

    # Loop through malcodes for the related Jira issue
    for malcode in "${group_array[@]}"; do
        # Set the required variables
        summary="Please upgrade $malcode in $testset to $month"
        description="This subtask is for upgrading $malcode in $testset during $month."
        watchers=${watcher_map[$prefix]}  # Get watchers based on prefix

        # Create subtask and get the key
        subtask_key=$(create_jira_subtask "$user" "$pass" "$project_key" "$issue" "$summary" "$description")
        
        if [[ -n "$watchers" && -n "$subtask_key" ]]; then
            # Add watchers to the created subtask
            add_watchers "$subtask_key" "$watchers"
        else
            echo "No watchers defined or subtask creation failed for $malcode under $issue."
        fi
    done
else
    echo "No group variable found!"
fi