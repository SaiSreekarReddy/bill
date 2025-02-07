#!/bin/bash

jira_data=$(curl -s "YOUR_JIRA_URL" | sed -n 's/["\[\]]//gp' | tr ',' '\n') # Example: Extracts comma-separated values

issue_summaries=()

while IFS= read -r summary; do
  issue_summaries+=("$summary")
done <<< "$jira_data"

# ... (rest of the script for printing the array is the same as in Option 1)
