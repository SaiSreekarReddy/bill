#!/bin/bash

# Function to fetch a custom field from a Jira ticket
get_custom_field() {
    local jira_url=$1
    local jira_user=$2
    local jira_pass=$3
    local ticket_id=$4
    local custom_field=$5

    # Fetch the JSON response from the Jira API
    local response=$(curl -s -u "${jira_user}:${jira_pass}" -X GET \
                     -H "Content-Type: application/json" \
                     "${jira_url}/${ticket_id}")

    # Extract the custom field value from the JSON response
    local custom_field_value=$(echo "$response" | jq -r ".fields.${custom_field}")

    # If the custom field is null or empty, return a message
    if [[ -z "$custom_field_value" || "$custom_field_value" == "null" ]]; then
        echo "No value found for ${custom_field}."
    else
        echo "$custom_field_value"
    fi
}

# Example usage of the function
jira_url="https://your.jira.instance/rest/api/2/issue"
jira_user="your_username"
jira_pass="your_password"
ticket_id="YOUR-TICKET-ID"
custom_field="customfield_24100"

# Call the function and capture the output
custom_field_value=$(get_custom_field "$jira_url" "$jira_user" "$jira_pass" "$ticket_id" "$custom_field")

# Print the extracted custom field value
echo "Custom Field Value (${custom_field}): $custom_field_value"
