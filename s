#!/bin/sh

# Define the keyword to search in JSON
SEARCH_KEYWORD="CRGHYT"
EXEMPT_TICKETS="CRHIRT-638 CRGHYT-999"  # Space-separated list of exempt tickets

# Declare an output file for malcodes
MALCODES_FILE="/tmp/malcodes.txt"
> "$MALCODES_FILE"  # Clear the file before running

# JSON file input (Replace with the actual path in Jenkins workspace)
JSON_FILE="jira_data.json"

# Function to check if a ticket is exempt
is_exempt() {
    local ticket="$1"
    for exempt in $EXEMPT_TICKETS; do
        [ "$ticket" = "$exempt" ] && return 0
    done
    return 1
}

# Extract Jira tickets and summaries from JSON
awk -v search="$SEARCH_KEYWORD" '
    {
        # Search for Jira tickets (e.g., CRGHYT-123)
        while (match($0, search"-[0-9]+")) {
            ticket = substr($0, RSTART, RLENGTH)
            $0 = substr($0, RSTART + RLENGTH)  # Move to next match

            # Extract the summary
            if (match($0, /"summary": ?"([^"]+)"/, arr)) {
                summary = arr[1]
                print ticket "|" summary
            }
        }
    }
' "$JSON_FILE" | while IFS="|" read -r ticket summary; do
    # Skip exempt tickets
    is_exempt "$ticket" && continue

    # Extract words and store them as unique malcodes
    for word in $summary; do
        # Convert the first letter to uppercase to match expected output
        formatted_word="$(echo "$word" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')"
        echo "$formatted_word" >> "$MALCODES_FILE"
    done
done

# Remove duplicates and store unique malcodes
sort -u "$MALCODES_FILE" > "${MALCODES_FILE}.tmp" && mv "${MALCODES_FILE}.tmp" "$MALCODES_FILE"

# Display unique malcodes (for Jenkins console output)
echo "Unique Malcodes Found:"
cat "$MALCODES_FILE"

# Exit successfully
exit 0