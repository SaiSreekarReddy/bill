#!/bin/bash

# Jenkins Multi-Line String Parameters
JIRA_TICKETS="${JIRA_TICKETS}"
MALCODES="${MALCODES}"

# Function to extract Jira ticket numbers
extract_jira_tickets() {
    local input="$1"
    local jira_tickets=()
    
    while IFS= read -r line; do
        if [[ "$line" =~ https?://.*/browse/([A-Z]+-[0-9]+) ]]; then
            jira_tickets+=("${BASH_REMATCH[1]}")  # Extract ticket number from URL
        elif [[ "$line" =~ ^[A-Z]+-[0-9]+$ ]]; then
            jira_tickets+=("$line")  # Use as-is if it's a ticket number
        fi
    done <<< "$input"

    echo "${jira_tickets[@]}"  # Return space-separated ticket numbers
}

# Extract only Jira ticket numbers
jira_tickets=$(extract_jira_tickets "$JIRA_TICKETS")

# Convert MALCODES multi-line string into an array
readarray -t malcodes_array <<< "$MALCODES"

# Loop through each Jira ticket
for ticket in $jira_tickets; do
    echo "Processing Jira Ticket: $ticket"

    # Loop through each malcode
    for malcode in "${malcodes_array[@]}"; do
        echo "  Creating subtask for Malcode: $malcode"

        # Create Jira subtask using API
        response=$(curl -s -u "user:password" -X POST \
          -H "Content-Type: application/json" \
          --data "{
            \"fields\": {
                \"project\": { \"key\": \"PROJECTKEY\" },
                \"parent\": { \"key\": \"$ticket\" },
                \"summary\": \"Subtask for Malcode: $malcode\",
                \"issuetype\": { \"name\": \"Sub-task\" }
            }
          }" "https://jira.company.com/rest/api/2/issue/")

        # Extract and print created subtask ID
        subtask_key=$(echo "$response" | jq -r '.key // "ERROR"')
        echo "  Subtask Created: $subtask_key for $ticket with malcode: $malcode"
    done
done