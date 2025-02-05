#!/bin/bash

# Set Confluence credentials
CONFLUENCE_USERNAME="your_username"
CONFLUENCE_PASSWORD="your_password"
CONFLUENCE_URL="https://your-domain.atlassian.net"

# Read Confluence Page ID from user input
read -p "Enter the Confluence Page ID: " PAGE_ID

# Fetch Confluence page content (HTML format)
PAGE_RESPONSE=$(curl -s -u "$CONFLUENCE_USERNAME:$CONFLUENCE_PASSWORD" -X GET \
  -H "Content-Type: application/json" \
  "$CONFLUENCE_URL/wiki/rest/api/content/$PAGE_ID?expand=body.storage")

# Check if response is valid
if [[ -z "$PAGE_RESPONSE" || "$PAGE_RESPONSE" == "null" ]]; then
    echo "Error: Failed to retrieve page content. Please check the Page ID and credentials."
    exit 1
fi

# Extract body content (HTML)
PAGE_BODY=$(echo "$PAGE_RESPONSE" | jq -r '.body.storage.value')

# Extract only the first column from the Confluence table
FIRST_COLUMN=$(echo "$PAGE_BODY" | grep -oP '(?<=<tr><td>).*?(?=</td>)')

# Verify if any entries were found
if [[ -z "$FIRST_COLUMN" ]]; then
    echo "No table data found on Confluence page $PAGE_ID."
    exit 1
fi

# Loop through each entry and echo it
echo "Extracted Entries from the First Column:"
echo "$FIRST_COLUMN" | while IFS= read -r line; do
    echo "$line"
done