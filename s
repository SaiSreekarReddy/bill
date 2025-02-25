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

# Function to extract the 4th word, month name, and custom fields from a Jira ticket
extract_jira_details() {
    local ticket="$1"
    
    # Get Jira issue details
    local issue_details=$(curl -s -u "user:password" -X GET \
        -H "Content-Type: application/json" \
        "https://jira.company.com/rest/api/2/issue/${ticket}")

    # Extract the summary
    local summary=$(echo "$issue_details" | jq -r '.fields.summary')

    # Extract the 4th word (if exists)
    local fourth_word=$(echo "$summary" | awk '{print $4}')

    # Extract the month name (if exists)
    local month_name=$(echo "$summary" | grep -o -i -E 'January|February|March|April|May|June|July|August|September|October|November|December' | head -n 1)

    # Extract custom fields (Ensure fields exist in Jira)
    local customfield_24801=$(echo "$issue_details" | jq -r '.fields.customfield_24801 // "Not Set"')
    local customfield_24802=$(echo "$issue_details" | jq -r '.fields.customfield_24802 // "Not Set"')

    # Return values as space-separated output
    echo "$fourth_word $month_name $customfield_24801 $customfield_24802"
}

# Extract only Jira ticket numbers
jira_tickets=$(extract_jira_tickets "$JIRA_TICKETS")

# Convert MALCODES multi-line string into an array
readarray -t malcodes_array <<< "$MALCODES"

# Loop through each Jira ticket
for ticket in $jira_tickets; do
    echo "Processing Jira Ticket: $ticket"

    # Get details from Jira
    read fourth_word month_name customfield_24801 customfield_24802 <<< $(extract_jira_details "$ticket")

    # Loop through each malcode
    for malcode in "${malcodes_array[@]}"; do
        echo "  Creating subtask for Malcode: $malcode"

        # Construct the subtask summary using extracted words and custom fields
        subtask_summary="Subtask: $fourth_word $month_name - $malcode (CF1: $customfield_24801, CF2: $customfield_24802)"

        # Create Jira subtask using API
        response=$(curl -s -u "user:password" -X POST \
          -H "Content-Type: application/json" \
          --data "{
            \"fields\": {
                \"project\": { \"key\": \"PROJECTKEY\" },
                \"parent\": { \"key\": \"$ticket\" },
                \"summary\": \"$subtask_summary\",
                \"issuetype\": { \"name\": \"Sub-task\" }
            }
          }" "https://jira.company.com/rest/api/2/issue/")

        # Extract and print created subtask ID
        subtask_key=$(echo "$response" | jq -r '.key // "ERROR"')
        echo "  Subtask Created: $subtask_key for $ticket with malcode: $malcode"
    done
done