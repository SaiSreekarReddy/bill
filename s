#!/bin/sh

# Define the keyword to search in JSON
SEARCH_KEYWORD="CRGHYT"
EXEMPT_TICKETS="CRHIRT-638"  # Space-separated list of exempt tickets

# Declare an associative array to store unique malcodes
MALCODES_FILE="/tmp/malcodes.txt"
> "$MALCODES_FILE"  # Empty the file

# JSON file input (Replace with the actual path)
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

            # Extract the summary (assumed on the same line or next)
            if (match($0, /"summary": ?"([^"]+)"/, arr)) {
                summary = arr[1]
                print ticket "|" summary
            }
        }
    }
' "$JSON_FILE" | while IFS="|" read -r ticket summary; do
    # Check if the ticket should be exempted
    is_exempt "$ticket" && continue

    # Extract words from the summary and add to malcodes file
    for word in $summary; do
        echo "$word" >> "$MALCODES_FILE"
    done
done

# Remove duplicates and store unique malcodes
sort -u "$MALCODES_FILE" > "${MALCODES_FILE}.tmp" && mv "${MALCODES_FILE}.tmp" "$MALCODES_FILE"

# Display unique malcodes
echo "Unique Malcodes Found:"
cat "$MALCODES_FILE"

# Function to dynamically add more exemptions
add_exemption() {
    echo "Enter the ticket number to exempt:"
    read -r new_ticket
    EXEMPT_TICKETS="$EXEMPT_TICKETS $new_ticket"
    echo "Updated Exempt List: $EXEMPT_TICKETS"
}

# Loop for adding exemptions dynamically
while true; do
    echo "Do you want to add an exemption? (y/n)"
    read -r choice
    case "$choice" in
        [yY]*) add_exemption ;;
        [nN]*) break ;;
        *) echo "Invalid input" ;;
    esac
done