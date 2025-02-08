#!/bin/bash

# Function to fetch a Jira ticket summary and split it into an array
get_summary_words() {
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

    # Initialize an empty array
    local -a words=()

    # Split the summary into words and store them in the array
    for word in $summary; do
        words+=("$word")
    done

    # Print each word in the array (optional)
    echo "Summary Words:"
    for word in "${words[@]}"; do
        echo "$word"
    done

    # Return the array (use declare -p for debugging purposes if needed)
    declare -p words
}

# Example usage of the function
jira_url="https://your.jira.instance/rest/api/2/issue"
jira_user="your_username"
jira_pass="your_password"
ticket_id="YOUR-TICKET-ID"

# Call the function and capture the array output
eval "$(get_summary_words "$jira_url" "$jira_user" "$jira_pass" "$ticket_id")"

# Example: Access the array
echo "Accessing words array:"
for word in "${words[@]}"; do
    echo "$word"
done
