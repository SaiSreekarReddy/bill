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

  # Initialize the report
  report="Jira Ticket Update Report\n\nTickets not updated in the last ${SINCE_HOURS} hours:\n\n"

  # Process tickets while retaining the report variable
  while IFS= read -r ticket; do
    key=$(echo "$ticket" | jq -r '.key // "No Key"')
    summary=$(echo "$ticket" | jq -r '.summary // "No Summary Available"')
    assignee=$(echo "$ticket" | jq -r '.assignee // "Unassigned"')
    updated=$(echo "$ticket" | jq -r '.updated // "No Updated Time Available"')

    # Append ticket details to the report
    report+="Ticket: $key\nSummary: $summary\nAssignee: $assignee\nLast Updated: $updated\nTicket URL: $JIRA_URL/browse/$key\n\n"
  done < <(echo "$tickets" | jq -c '.issues[]') # Process tickets directly from JSON

  # Echo the report to the Jenkins log
  echo -e "\n==== Report for Query: $query ====\n"
  echo -e "$report"

  # Send the email
  subject="Jira Ticket Update Report: ${SINCE_HOURS}-Hour Reminder"
  send_email "$EMAIL_TO" "$EMAIL_CC" "$subject" "$report"
  echo "Consolidated email sent for query: $query"
done

echo "Script completed."