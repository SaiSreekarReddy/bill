#!/bin/bash

# Jira Credentials
JIRA_URL="https://your-jira-instance.atlassian.net"
JIRA_USER="your-email@example.com"
JIRA_API_TOKEN="your-api-token"

# Define malcodes arrays
malcodes1=("MAL1A" "MAL1B" "MAL1C")
malcodes2=("MAL2A" "MAL2B" "MAL2C")
malcodes3=("MAL3A" "MAL3B" "MAL3C")
malcodes4=("MAL4A" "MAL4B" "MAL4C")
malcodes5=("MAL5A" "MAL5B" "MAL5C")

# Related Jira issues
related_issues=("abcddrf-123" "abcdgrp-456" "xyzabcd-789")

# Mapping of 7-letter prefixes to malcode groups
declare -A malcode_map
malcode_map["abcddrf"]="malcodes1"
malcode_map["abcdgrp"]="malcodes2"
malcode_map["xyzabcd"]="malcodes3"

# Function to create a subtask
create_subtask() {
    local parent_issue=$1
    local malcode=$2

    # JSON payload for subtask creation
    json_payload=$(jq -n \
        --arg summary "Subtask for $malcode under $parent_issue" \
        --arg description "Handling $malcode related to $parent_issue" \
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

    echo "Created subtask for $malcode under $parent_issue"
}

# Iterate through related issues
for issue in "${related_issues[@]}"; do
    prefix=${issue:0:7}  # Extract first 7 characters

    # Determine corresponding malcode group
    group_var=${malcode_map[$prefix]}

    if [[ -n "$group_var" ]]; then
        eval "group_array=(\"\${$group_var[@]}\")"

        # Create a subtask for each malcode under the related Jira issue
        for malcode in "${group_array[@]}"; do
            create_subtask "$issue" "$malcode"
        done
    else
        echo "No malcode group found for $issue"
    fi
done
