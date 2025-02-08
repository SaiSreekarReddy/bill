#!/bin/bash

# Function to fetch the month from a Jira ticket summary
get_month_from_summary() {
    local jira_url=$1
    local jira_user=$2
    local jira_pass=$3
    local ticket_id=$4

    # Fetch the JSON response from the Jira API
    local response=$(curl -s -u "${jira_user}:${jira_pass}" -X GET \
                     -H "Content-Type: application/json" \
                     "${jira_url}/${ticket_id}")

    # Extract the summary field from the JSON response
    local summary=$(echo "$response" | jq -r '.fields.summary')

    # List of months to search for
    local months=("January" "February" "March" "April" "May" "June" "July" "August" "September" "October" "November" "December")

    # Iterate through the months and check if any is in the summary
    for month in "${months[@]}"; do
        if [[ "$summary" == *"$month"* ]]; then
            echo "$month"
            return
        fi
    done

    # If no month is found, print a message
    echo "No month found in the summary."
}

# Example usage of the function
jira_url="https://your.jira.instance/rest/api/2/issue"
jira_user="your_username"
jira_pass="your_password"
ticket_id="YOUR-TICKET-ID"

# Call the function and capture the output
month=$(get_month_from_summary "$jira_url" "$jira_user" "$jira_pass" "$ticket_id")

# Print the extracted month
echo "Month extracted: $month"
