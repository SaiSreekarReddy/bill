#!/bin/bash

# Set your Jira credentials
JIRA_USERNAME="your_username"
JIRA_PASSWORD="your_password"
JIRA_URL="https://track.td.com"

# Read Jira Ticket ID from user input
read -p "Enter the Jira ticket ID: " JIRA_TICKET

# Fetch issue details from Jira
JIRA_RESPONSE=$(curl -s -u "$JIRA_USERNAME:$JIRA_PASSWORD" -X GET -H "Content-Type: application/json" "$JIRA_URL/rest/api/2/issue/$JIRA_TICKET")

# Check if the response is valid
if [[ -z "$JIRA_RESPONSE" ]]; then
    echo "Failed to retrieve ticket details. Please check the Jira URL and credentials."
    exit 1
fi

# Extract "Relates To" issue links using jq
RELATED_TICKETS=$(echo "$JIRA_RESPONSE" | jq -r '.fields.issuelinks[] | select(.type.name=="Relates") | .outwardIssue.key, .inwardIssue.key' | sort -u)

# Check if any related tickets were found
if [[ -z "$RELATED_TICKETS" ]]; then
    echo "No related tickets found for $JIRA_TICKET."
else
    echo "Related Jira Tickets for $JIRA_TICKET:"
    echo "$RELATED_TICKETS"
fi