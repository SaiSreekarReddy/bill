#!/bin/bash

# Configuration
JIRA_URL="YOUR_JIRA_URL"
JIRA_USERNAME="YOUR_JIRA_USERNAME"
JIRA_PASSWORD="YOUR_JIRA_PASSWORD" # Or API token
SINCE_HOURS=25

# Query and Email Configurations (Add more as needed)
QUERIES=(
  "status=Open AND project = \"Project A\" AND updated <= -${SINCE_HOURS}h"  # Query 1
  "status=Open AND project = \"Project B\" AND component = \"Component X\" AND updated <= -${SINCE_HOURS}h" # Query 2
)

EMAIL_CONFIGS=(
  "email1@example.com,cc1@example.com,cc2@example.com"  # Emails for Query 1
  "email2@example.com,cc3@example.com"  # Emails for Query 2
)

# Function to get Jira tickets (using curl and jq)
get_jira_tickets() {
  local query="$1"
  curl -s -u "$JIRA_USERNAME:$JIRA_PASSWORD" "$JIRA_URL/rest/api/2/search?jql=\"$query\"&fields=key,summary,assignee,updated" | jq -r '.issues[] | {key:.key, summary:.fields.summary, assignee:.fields.assignee.name, updated:.fields.updated}'
}

# Function to send email notification
send_email() {
  local to="$1"
  local cc="$2"
  local subject="$3"
  local body="$4"

  echo "$body" | mail -s "$subject" -c "$cc" "$to"
}

# Loop through queries
for i in "${!QUERIES[@]}"; do
  query="${QUERIES[$i]}"
  emails="${EMAIL_CONFIGS[$i]}"
  IFS=',' read -r EMAIL_TO EMAIL_CC <<< "$emails" # Split emails

  tickets=$(get_jira_tickets "$query")

  # Check if any tickets were found for this query
  if [[ -z "$tickets" ]]; then
    echo "No Jira tickets found for query: $query"
    continue # Skip to the next query
  fi

  # Process each ticket
  while IFS= read -r ticket; do
    key=$(echo "$ticket" | jq -r '.key')
    summary=$(echo "$ticket" | jq -r '.summary')
    assignee=$(echo "$ticket" | jq -r '.assignee')
    updated=$(echo "$ticket" | jq -r '.updated')

    assignee_email=$(curl -s -u "$JIRA_USERNAME:$JIRA_PASSWORD" "$JIRA_URL/rest/api/2/user/$assignee" | jq -r '.emailAddress')

    subject="Jira Ticket Update Reminder: $key - $summary"
    body="This is a reminder that Jira ticket $key ($summary) is open and has not been updated in the last $SINCE_HOURS hours. Please review and update it.\n\nTicket URL: $JIRA_URL/browse/$key\n\nAssignee: $assignee ($assignee_email)\nUpdated Time: $updated"

    # Send email including the assignee
    if [[ ! -z "$assignee_email" ]]; then
        all_recipients="$EMAIL_TO,$assignee_email" # Include assignee in 'to'
        send_email "$all_recipients" "$EMAIL_CC" "$subject" "$body"
        echo "Email sent for ticket: $key (Query: $query)"
    else
        echo "Could not retrieve email for assignee: $assignee (Ticket: $key, Query: $query)"
    fi

  done <<< "$tickets"
done

echo "Script completed."

