#!/bin/bash

# Configuration
JIRA_URL="YOUR_JIRA_URL"
JIRA_USERNAME="YOUR_JIRA_USERNAME"
JIRA_PASSWORD="YOUR_JIRA_PASSWORD" # Or API token
SINCE_HOURS=25

# Query and Email Configurations
QUERIES=(
  "status=Open AND project = 'Project A' AND updated <= -${SINCE_HOURS}h"
  "status=Open AND project = 'Project B' AND component = 'Component X' AND updated <= -${SINCE_HOURS}h"
)

EMAIL_CONFIGS=(
  "email1@example.com,cc1@example.com,cc2@example.com"
  "email2@example.com,cc3@example.com"
)

# Function to get Jira tickets
get_jira_tickets() {
  local query="$1"
  curl -s -u "$JIRA_USERNAME:$JIRA_PASSWORD" \
    "$JIRA_URL/rest/api/2/search?jql=$(echo "$query" | jq -sRr @uri)&fields=key,summary,assignee,updated" | jq -c '.issues[]'
}

# Function to send email
send_email() {
  local to="$1"
  local cc="$2"
  local subject="$3"
  local body="$4"

  echo -e "$body" | mail -s "$subject" -c "$cc" "$to"
}

# Main loop for queries
for i in "${!QUERIES[@]}"; do
  query="${QUERIES[$i]}"
  emails="${EMAIL_CONFIGS[$i]}"
  IFS=',' read -r EMAIL_TO EMAIL_CC <<< "$emails"

  tickets=$(get_jira_tickets "$query")

  if [[ -z "$tickets" ]]; then
    echo "No Jira tickets found for query: $query"
    continue
  fi

  # Build the report
  report="Jira Ticket Update Report\n\nTickets not updated in the last $SINCE_HOURS hours:\n\n"

  echo "Tickets JSON: $tickets" # Debug: Show raw JSON for tickets

  # Use a for loop to process tickets
  for ticket in $(echo "$tickets" | jq -c '.'); do
    echo "Processing ticket: $ticket" # Debug: Show raw ticket data

    # Extract fields from ticket
    key=$(echo "$ticket" | jq -r '.key // "No Key"')
    summary=$(echo "$ticket" | jq -r '.summary // "No Summary Available"')
    assignee=$(echo "$ticket" | jq -r '.assignee // "Unassigned"')
    updated=$(echo "$ticket" | jq -r '.updated // "No Updated Time Available"')

    # Debug: Print extracted values
    echo "Key: $key, Summary: $summary, Assignee: $assignee, Updated: $updated"

    # Add to report
    report+="Ticket: $key\nSummary: $summary\nAssignee: $assignee\nUpdated: $updated\nTicket URL: $JIRA_URL/browse/$key\n\n"
  done

  subject="Jira Ticket Update Report: ${SINCE_HOURS}-Hour Reminder"
  send_email "$EMAIL_TO" "$EMAIL_CC" "$subject" "$report"
  echo "Consolidated email sent for query: $query"
done

echo "Script completed."