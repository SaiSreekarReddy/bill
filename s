#!/bin/bash

# Set Confluence credentials
CONFLUENCE_USERNAME="your_email@domain.com"
CONFLUENCE_API_TOKEN="your_api_token"
CONFLUENCE_URL="https://your-domain.atlassian.net"

# Read Confluence Page ID
read -p "Enter the Confluence Page ID: " PAGE_ID

# Temporary files
JSON_FILE="confluence_page.json"
HTML_FILE="decoded_table.html"

# Fetch Confluence page content and save JSON response
curl -s -u "$CONFLUENCE_USERNAME:$CONFLUENCE_API_TOKEN" -X GET \
  -H "Content-Type: application/json" \
  "$CONFLUENCE_URL/rest/api/content/$PAGE_ID?expand=body.storage" > "$JSON_FILE"

# Check if JSON response is valid
if [[ ! -s "$JSON_FILE" ]]; then
    echo "Error: Failed to retrieve page content or page has no data."
    exit 1
fi

# Extract and decode HTML content from JSON
jq -r '.body.storage.value' "$JSON_FILE" | python3 -c "import sys, html; print(html.unescape(sys.stdin.read()))" > "$HTML_FILE"

# Check if extracted HTML content exists
if [[ ! -s "$HTML_FILE" ]]; then
    echo "Error: No table content found in Confluence page."
    exit 1
fi

# Extract only the first column from the Confluence table
FIRST_COLUMN=$(grep -oP '(?<=<tr><td>).*?(?=</td>)' "$HTML_FILE")

# Verify if any entries were found
if [[ -z "$FIRST_COLUMN" ]]; then
    echo "No table data found on Confluence page $PAGE_ID."
    exit 1
fi

# Loop through each extracted entry and echo it
echo "Extracted Entries from the First Column:"
echo "$FIRST_COLUMN" | while IFS= read -r line; do
    echo "$line"
done

# Cleanup temporary files
rm -f "$JSON_FILE" "$HTML_FILE"