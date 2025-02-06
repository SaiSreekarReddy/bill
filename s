#!/bin/bash

# --- Configuration ---
USER="confluence_user"
PASS="confluence_pass"
CONFLUENCE_URL="https://confluence_base_url/rest/API/content/pageid?expand=body.storage"

JIRA_USER="jira_user"
JIRA_PASS="jira_pass"
JIRA_SEARCH_URL="https://your.jira.instance/rest/api/2/search"
JIRA_CREATE_URL="https://your.jira.instance/rest/api/2/issue"

# Function to get related tickets based on an input ticket number
get_related_tickets() {
  local input_ticket="$1"
  related_tickets=$(curl -s -u "${JIRA_USER}:${JIRA_PASS}" -X GET "${JIRA_SEARCH_URL}" \
                    -H "Content-Type: application/json" \
                    --data "{\"jql\": \"key ~ '${input_ticket:0:7}'\", \"fields\": [\"key\"]}" | jq -r '.issues[].key')
  
  echo "$input_ticket"  # Include input ticket itself
  echo "$related_tickets" | head -4  # Get 4 related tickets
}

# Function to fetch summaries in bulk
fetch_summaries() {
  local tickets="$1"
  local -n malcodes_array=$2  # Pass array by reference

  if [ -z "$tickets" ]; then
    return
  fi

  ticket_list=$(echo "$tickets" | tr '\n' ',' | sed 's/,$//')

  jira_response=$(curl -s -u "${JIRA_USER}:${JIRA_PASS}" -X POST "${JIRA_SEARCH_URL}" \
                   -H "Content-Type: application/json" \
                   --data "{\"jql\": \"key in ($ticket_list)\", \"fields\": [\"summary\"]}")

  while IFS= read -r summary; do
    malcode=$(echo "$summary" | awk '{print $2}')
    malcodes_array+=("$malcode")
  done < <(echo "$jira_response" | jq -r '.issues[].fields.summary')
}

# Function to create Jira subtasks
create_subtask() {
  local parent_ticket="$1"
  local summary="$2"
  local description="Subtask created for $parent_ticket with MalCode $summary"

  curl -s -u "${JIRA_USER}:${JIRA_PASS}" -X POST "${JIRA_CREATE_URL}" \
       -H "Content-Type: application/json" \
       --data "{
          \"fields\": {
            \"project\": { \"key\": \"YOUR_PROJECT_KEY\" },
            \"parent\": { \"key\": \"$parent_ticket\" },
            \"summary\": \"$summary\",
            \"description\": \"$description\",
            \"issuetype\": { \"name\": \"Sub-task\" }
          }
        }"
}

# Fetch ticket numbers from Confluence content
response=$(curl -s -u "${USER}:${PASS}" -X GET -H "Content-Type: application/json" "${CONFLUENCE_URL}")
matches1=$(echo "$response" | grep -o '>CRHP[^-]*-[0-9]\{4,5\}<' | sed 's/^>.*<$/\1/' | awk 'NR%5==1')
matches2=$(echo "$response" | grep -o '>CRHP[^-]*-[0-9]\{4,5\}<' | sed 's/^>.*<$/\1/' | awk 'NR%5==2')
matches3=$(echo "$response" | grep -o '>CRHP[^-]*-[0-9]\{4,5\}<' | sed 's/^>.*<$/\1/' | awk 'NR%5==3')
matches4=$(echo "$response" | grep -o '>CRHP[^-]*-[0-9]\{4,5\}<' | sed 's/^>.*<$/\1/' | awk 'NR%5==4')
matches5=$(echo "$response" | grep -o '>CRHP[^-]*-[0-9]\{4,5\}<' | sed 's/^>.*<$/\1/' | awk 'NR%5==0')

# Initialize arrays for MalCodes
declare -a malcodes1 malcodes2 malcodes3 malcodes4 malcodes5

# Fetch MalCodes from Jira in bulk
fetch_summaries "$matches1" malcodes1
fetch_summaries "$matches2" malcodes2
fetch_summaries "$matches3" malcodes3
fetch_summaries "$matches4" malcodes4
fetch_summaries "$matches5" malcodes5

# Ask for an input ticket
read -p "Enter a Jira ticket number: " input_ticket

# Get related tickets (including the input ticket)
related_tickets=($(get_related_tickets "$input_ticket"))

# Assign MalCodes based on related ticket order
declare -A ticket_malcode_mapping
ticket_malcode_mapping["${related_tickets[0]}"]="${malcodes1[@]}"  # Input ticket → Group 1
ticket_malcode_mapping["${related_tickets[1]}"]="${malcodes2[@]}"  # Related 1 → Group 2
ticket_malcode_mapping["${related_tickets[2]}"]="${malcodes3[@]}"  # Related 2 → Group 3
ticket_malcode_mapping["${related_tickets[3]}"]="${malcodes4[@]}"  # Related 3 → Group 4
ticket_malcode_mapping["${related_tickets[4]}"]="${malcodes5[@]}"  # Related 4 → Group 5

# Create subtasks for each related ticket
for ticket in "${!ticket_malcode_mapping[@]}"; do
  for malcode in ${ticket_malcode_mapping["$ticket"]}; do
    echo "Creating subtask for $ticket with MalCode: $malcode"
    create_subtask "$ticket" "$malcode"
  done
done

echo "Subtasks successfully created!"