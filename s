#!/bin/bash

# Configuration
JIRA_URL="YOUR_JIRA_URL"
JIRA_USERNAME="YOUR_JIRA_USERNAME"
JIRA_PASSWORD="YOUR_JIRA_PASSWORD" # Or API token
SINCE_HOURS=25

# Query and Email Configurations (Add more as needed)
QUERIES=(
  "status=Open AND project = 'Project A' AND updated <= -${SINCE_HOURS}h"  # Query 1
  "status=Open AND project = 'Project B' AND component = 'Component X' AND updated <= -${SINCE_HOURS}h" # Query 2
)

EMAIL_CONFIGS=(
  "email1@example.com,cc1@example.com,cc2@example.com"  # Emails for Query 1
  "email2@example.com,cc3@example.com"  # Emails for Query 2
)

# Function to get Jira tickets (using curl and jq)
get_jira_tickets() {
  local query="$1"
  curl -s -u "$JIRA_USERNAME:$JIRA_PASSWORD" \
    "$JIRA_URL/rest/api/2/search?jql=$(echo "$query" | jq -sRr @uri)&fields=key,summary,assignee,updated" | \
    jq -c '.issues[] | {key:.key, summary:.fields.summary, assignee:(.fields.assignee | if . == null then "Unassigned" else .name end), updated:.fields.updated}'
}

# Function to send email notification
send_email() {
  local to="$1"
  local cc="$2"
  local subject="$3"
  local body="$4"

  echo -e "$body" | mail -s "$subject" -c "$cc" "$to"
}

# Main processing loop for queries
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

  # Build the report for all tickets in this query
  report="Jira Ticket Update Report\n\nThe following tickets have not been updated in the last $SINCE_HOURS hours:\n\n"
  echo "$tickets" | while IFS= read -r ticket; do
    key=$(echo "$ticket" | jq -r '.key')
    summary=$(echo "$ticket" | jq -r '.summary')
    assignee=$(echo "$ticket" | jq -r '.assignee')
    updated=$(echo "$ticket" | jq -r '.updated')

    # Add ticket details to the report
    report+="Ticket: $key\nSummary: $summary\nAssignee: $assignee\nLast Updated: $updated\nTicket URL: $JIRA_URL/browse/$key\n\n"
  done

  # Send the consolidated email for this query
  subject="Jira Ticket Update Report: ${SINCE_HOURS}-Hour Reminder"
  send_email "$EMAIL_TO" "$EMAIL_CC" "$subject" "$report"
  echo "Consolidated email sent for query: $query"
done

echo "Script completed."