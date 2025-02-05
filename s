#!/bin/bash

# Set Confluence credentials
CONFLUENCE_USERNAME="your_email@domain.com"
CONFLUENCE_API_TOKEN="your_api_token"
CONFLUENCE_URL="https://your-domain.atlassian.net"

# Read Confluence Page ID
read -p "Enter the Confluence Page ID: " PAGE_ID

# Temporary files
JSON_FILE="confluence_page.json"
ENCODED_VALUES_FILE="encoded_values.txt"

# Fetch Confluence page content and save JSON response
curl -s -u "$CONFLUENCE_USERNAME:$CONFLUENCE_API_TOKEN" -X GET \
  -H "Content-Type: application/json" \
  "$CONFLUENCE_URL/rest/api/content/$PAGE_ID?expand=body.storage" > "$JSON_FILE"

# Extract all values enclosed between \u003E (>) and \u003C (<)
grep -oP '(?<=\\u003E)[^\\u003C]+' "$JSON_FILE" > "$ENCODED_VALUES_FILE"

# Check if we extracted anything
if [[ ! -s "$ENCODED_VALUES_FILE" ]]; then
    echo "No encoded values found on Confluence page $PAGE_ID."
    exit 1
fi

# Print extracted values
echo "Extracted Encoded Values:"
cat "$ENCODED_VALUES_FILE"

# Cleanup
rm -f "$JSON_FILE"