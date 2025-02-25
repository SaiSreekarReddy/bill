extract_jira_tickets() {
    local input="$1"
    local jira_tickets=()

    while IFS= read -r line; do
        if [[ "$line" =~ https?://.*/browse/([A-Z]+-[0-9]+) ]]; then
            jira_tickets+=("${BASH_REMATCH[1]}")  # Extract ticket from URL
        elif [[ "$line" =~ ^[A-Z]+-[0-9]+$ ]]; then
            jira_tickets+=("$line")  # Use as-is if it's already a ticket number
        fi
    done <<< "$input"

    echo "${jira_tickets[@]}"  # Print space-separated ticket numbers
}


# Example multi-line parameter from Jenkins
JIRA_INPUT=$(cat <<EOF
https://jira.company.com/browse/ABC-123
DEF-456
https://jira.company.com/browse/GHI-789
JKL-101
EOF
)

# Call the function
jira_tickets=$(extract_jira_tickets "$JIRA_INPUT")

# Print extracted Jira ticket numbers
echo "Extracted Jira Tickets: $jira_tickets"