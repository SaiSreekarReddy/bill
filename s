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

# 2) Extract ticket numbers grouped into five categories
matches1=$(echo "${response}" | grep -o '>CRHP[^-]*-[0-9]\{4,5\}<' | sed 's/^>.*<$/\1/' | awk 'NR%5==1')
matches2=$(echo "${response}" | grep -o '>CRHP[^-]*-[0-9]\{4,5\}<' | sed 's/^>.*<$/\1/' | awk 'NR%5==2')
matches3=$(echo "${response}" | grep -o '>CRHP[^-]*-[0-9]\{4,5\}<' | sed 's/^>.*<$/\1/' | awk 'NR%5==3')
matches4=$(echo "${response}" | grep -o '>CRHP[^-]*-[0-9]\{4,5\}<' | sed 's/^>.*<$/\1/' | awk 'NR%5==4')
matches5=$(echo "${response}" | grep -o '>CRHP[^-]*-[0-9]\{4,5\}<' | sed 's/^>.*<$/\1/' | awk 'NR%5==0')

# Function to process ticket groups in bulk
process_tickets() {
  local tickets="$1"
  local -n malcodes_array=$2  # Pass by reference to update the correct array

  if [ -z "$tickets" ]; then
    return  # Skip if no tickets in this group
  fi

  # Convert space-separated tickets into a Jira JQL query format (comma-separated)
  ticket_list=$(echo "$tickets" | tr '\n' ',' | sed 's/,$//')

  # 3) Perform a bulk search on Jira
  jira_response=$(curl -s -u "${JIRA_USER}:${JIRA_PASS}" -X POST "${JIRA_SEARCH_URL}" \
                   -H "Content-Type: application/json" \
                   --data "{\"jql\": \"key in ($ticket_list)\", \"fields\": [\"summary\"]}")

  # 4) Extract summaries and their second words (MalCodes)
  while IFS= read -r summary; do
    malcode=$(echo "$summary" | awk '{print $2}')  # Extract the second word
    malcodes_array+=("$malcode")  # Store in corresponding array
  done < <(echo "$jira_response" | jq -r '.issues[].fields.summary')
}

# Initialize arrays for MalCodes
declare -a malcodes1 malcodes2 malcodes3 malcodes4 malcodes5

# Process each group of tickets
process_tickets "$matches1" malcodes1
process_tickets "$matches2" malcodes2
process_tickets "$matches3" malcodes3
process_tickets "$matches4" malcodes4
process_tickets "$matches5" malcodes5

# 5) Display Results
echo "MalCodes for Group 1:"
printf "%s\n" "${malcodes1[@]}"

echo "MalCodes for Group 2:"
printf "%s\n" "${malcodes2[@]}"

echo "MalCodes for Group 3:"
printf "%s\n" "${malcodes3[@]}"

echo "MalCodes for Group 4:"
printf "%s\n" "${malcodes4[@]}"

echo "MalCodes for Group 5:"
printf "%s\n" "${malcodes5[@]}"