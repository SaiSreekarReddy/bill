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
    # Extract the second word (malcode) and third word
    second_word=$(echo "$summary" | awk '{print $2}')
    third_word=$(echo "$summary" | awk '{print $3}')

    # Check if the third word matches "db" in any case and append _db
    if [[ "${third_word,,}" == "db" ]]; then
      malcode="${second_word}_db"
    else
      malcode="$second_word"
    fi

    malcodes_array+=("$malcode")
  done < <(echo "$jira_response" | jq -r '.issues[].fields.summary')
}





_____________________






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
    # Extract the second word (malcode) and third word
    second_word=$(echo "$summary" | awk '{print $2}')
    third_word=$(echo "$summary" | awk '{print $3}')

    # Include the third word if it's "db"
    if [[ "$third_word" == "db" ]]; then
      malcode="${second_word}_db"
    else
      malcode="$second_word"
    fi

    malcodes_array+=("$malcode")
  done < <(echo "$jira_response" | jq -r '.issues[].fields.summary')
}