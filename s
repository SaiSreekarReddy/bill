# Main processing loop for queries
for i in "${!QUERIES[@]}"; do
  query="${QUERIES[$i]}"
  emails="${EMAIL_CONFIGS[$i]}"
  IFS=',' read -r EMAIL_TO EMAIL_CC <<< "$emails" # Split emails

  tickets=$(get_jira_tickets "$query")
  echo "Raw tickets JSON: $tickets" # Debugging: Print raw tickets JSON

  # Check if any tickets were found for this query
  if [[ -z "$tickets" || "$tickets" == "null" ]]; then
    echo "No tickets found for query: $query"
    continue
  fi

  # Initialize the report
  report="Jira Ticket Update Report\n\nTickets not updated in the last ${SINCE_HOURS} hours:\n\n"

  # Process NDJSON tickets while retaining the report variable
  echo "$tickets" | while IFS= read -r ticket; do
    key=$(echo "$ticket" | jq -r '.key // "No Key"')
    summary=$(echo "$ticket" | jq -r '.summary // "No Summary Available"')
    assignee=$(echo "$ticket" | jq -r '.assignee // "Unassigned"')
    updated=$(echo "$ticket" | jq -r '.updated // "No Updated Time Available"')

    # Append ticket details to the report
    report+="Ticket: $key\nSummary: $summary\nAssignee: $assignee\nLast Updated: $updated\n\n"
  done

  # Echo the report to Jenkins log
  echo -e "\n==== Report for Query: $query ====\n"
  echo -e "$report"

  # Send the email
  subject="Jira Ticket Update Report: ${SINCE_HOURS}-Hour Reminder"
  send_email "$EMAIL_TO" "$EMAIL_CC" "$subject" "$report"
  echo "Consolidated email sent for query: $query"
done

echo "Script completed."

---------------------------------------------------------------------------



# Main processing loop for queries
for i in "${!QUERIES[@]}"; do
  query="${QUERIES[$i]}"
  emails="${EMAIL_CONFIGS[$i]}"
  IFS=',' read -r EMAIL_TO EMAIL_CC <<< "$emails" # Split emails

  tickets=$(get_jira_tickets "$query")
  echo "Raw tickets JSON: $tickets" # Debugging: Print raw tickets JSON

  # Check if any tickets were found for this query
  if [[ -z "$tickets" || "$tickets" == "null" ]]; then
    echo "No tickets found for query: $query"
    continue
  fi

  # Initialize the report
  report="Jira Ticket Update Report\n\nTickets not updated in the last ${SINCE_HOURS} hours:\n\n"

  # Process tickets using a while loop and process substitution
  while IFS= read -r ticket; do
    # Extract fields from each ticket
    key=$(echo "$ticket" | jq -r '.key // "No Key"')
    summary=$(echo "$ticket" | jq -r '.summary // "No Summary Available"')
    assignee=$(echo "$ticket" | jq -r '.assignee // "Unassigned"')
    updated=$(echo "$ticket" | jq -r '.updated // "No Updated Time Available"')

    # Append ticket details to the report
    report+="Ticket: $key\nSummary: $summary\nAssignee: $assignee\nLast Updated: $updated\n\n"

    # Debug: Print ticket details
    echo "Processed ticket: $key, Summary: $summary, Assignee: $assignee, Updated: $updated"
  done < <(echo "$tickets") # Use process substitution to feed JSON lines into the while loop

  # Echo the report to Jenkins log
  echo -e "\n==== Report for Query: $query ====\n"
  echo -e "$report"

  # Send the email
  subject="Jira Ticket Update Report: ${SINCE_HOURS}-Hour Reminder"
  send_email "$EMAIL_TO" "$EMAIL_CC" "$subject" "$report"
  echo "Consolidated email sent for query: $query"
done

echo "Script completed."







