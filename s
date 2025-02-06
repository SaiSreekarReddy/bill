#!/bin/bash

# --- Configuration ---
USER="confluence_user"
PASS="confluence_pass"
CONFLUENCE_URL="https://confluence_base_url/rest/API/content/pageid?expand=body.storage"

JIRA_USER="jira_user"
JIRA_PASS="jira_pass"
JIRA_SEARCH_URL="https://your.jira.instance/rest/api/2/search"  # Bulk search API

# 1) Retrieve Confluence page content
response=$(curl -s -u "${USER}:${PASS}" -X GET \
         -H "Content-Type: application/json" "${CONFLUENCE_URL}")

# 2) Extract ticket numbers (improved regex and grouping)
ticket_numbers=$(echo "${response}" | grep -oE '>CRHP[^-]*-[0-9]{4,5}<' | sed 's/^>.*<$/\1/')

# Group tickets into arrays (more efficient)
declare -A ticket_groups  # Associative array for flexible grouping

group_index=0
for ticket in $ticket_numbers; do
  group_name="group$((group_index % 5))"  # Cycle through 5 groups
  ticket_groups[$group_name]+="$ticket "
  group_index=$((group_index + 1))
done


# Function to process ticket groups in bulk (improved error handling)
process_tickets() {
  local group_name="$1"
  local tickets="${ticket_groups[$group_name]}"
  local array_name="$2"  # Receive the array name as a string

  if [ -z "$tickets" ]; then
    return  # Skip if no tickets in this group
  fi

  # Convert space-separated tickets into a Jira JQL query format
  ticket_list=$(echo "$tickets" | tr ' ' ',' | sed 's/,$//')

  # 3) Perform a bulk search on Jira (handle potential errors)
  jira_response=$(curl -s -u "${JIRA_USER}:${JIRA_PASS}" -X POST "${JIRA_SEARCH_URL}" \
                   -H "Content-Type: application/json" \
                   --data "{\"jql\": \"key in ($ticket_list)\", \"fields\": [\"summary\"]}")

  if [[ $(echo "$jira_response" | jq -r '.errorMessages') ]]; then  # Check for Jira API errors
      echo "Error fetching Jira data for $group_name: $(echo "$jira_response" | jq -r '.errorMessages')" >&2 # Print error to stderr
      return 1 # Return error code
  fi

    # 4) Extract summaries and their second words (MalCodes)
  while IFS= read -r summary; do
    malcode=$(echo "$summary" | awk '{print $2}')  # Extract the second word
    eval "${array_name}+=('\$malcode')"  # Use eval for indirect expansion (fixed!)
  done < <(echo "$jira_response" | jq -r '.issues[].fields.summary')
}


# Initialize arrays for MalCodes (dynamically)
declare -A malcodes_arrays

# Process each group of tickets (dynamically)
for group_name in "${!ticket_groups[@]}"; do
  declare -a "malcodes_${group_name}"
  process_tickets "$group_name" "malcodes_${group_name}"
  malcodes_arrays[$group_name]="malcodes_${group_name}" # Store array name
done

# 5) Display Results (dynamically)
for group_name in "${!ticket_groups[@]}"; do
  echo "MalCodes for ${group_name}:"
  eval printf "%s\\n" "\"\${${malcodes_arrays[$group_name]}[@]}\"" # Indirect variable expansion
done

