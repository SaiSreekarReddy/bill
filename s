#!/bin/bash

# Set Confluence credentials
CONFLUENCE_USERNAME="your_username"
CONFLUENCE_PASSWORD="your_password"
CONFLUENCE_URL="https://your-confluence-instance.atlassian.net"

# Read Confluence Page ID from user input
read -p "Enter the Confluence Page ID: " PAGE_ID

# Fetch Confluence page content (HTML format)
PAGE_RESPONSE=$(curl -s -u "$CONFLUENCE_USERNAME:$CONFLUENCE_PASSWORD" -X GET \
  -H "Content-Type: application/json" \
  "$CONFLUENCE_URL/wiki/rest/api/content/$PAGE_ID?expand=body.storage")

# Check if response is valid
if [[ -z "$PAGE_RESPONSE" ]]; then
    echo "Failed to retrieve Confluence page. Please check the URL and credentials."
    exit 1
fi

# Extract body content (HTML)
PAGE_BODY=$(echo "$PAGE_RESPONSE" | jq -r '.body.storage.value')

# Extract malcodes (assuming they follow the pattern "MALCODE-1234")
MALCODES=$(echo "$PAGE_BODY" | grep -oE 'MALCODE-[0-9]+' | sort -u)

# Display results
if [[ -z "$MALCODES" ]]; then
    echo "No malcodes found on Confluence page $PAGE_ID."
else
    echo "Malcodes found on Confluence page $PAGE_ID:"
    echo "$MALCODES"
fi