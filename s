#!/bin/bash

# Set Confluence credentials
CONFLUENCE_USERNAME="your_email@domain.com"
CONFLUENCE_API_TOKEN="your_api_token"
CONFLUENCE_URL="https://your-domain.atlassian.net"

# Read Confluence Page ID
read -p "Enter the Confluence Page ID: " PAGE_ID

# Temporary file for large page content
TEMP_FILE="confluence_page.html"

# Fetch Confluence page content (HTML format) and save to a file
curl -s -u "$CONFLUENCE_USERNAME:$CONFLUENCE_API_TOKEN" -X GET \
  -H "Content-Type: application/json" \
  "$CONFLUENCE_URL/rest/api/content/$PAGE_ID?expand=body.storage" | jq -r '.body.storage.value' > "$TEMP_FILE"

# Check if the file has content
if [[ ! -s "$TEMP_FILE" ]]; then
    echo "Error: Failed to retrieve page content or page has no data."
    exit 1
fi

# Extract the first column from the Confluence table
FIRST_COLUMN=$(grep -oP '(?<=<tr><td>).*?(?=</td>)' "$TEMP_FILE")

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

# Cleanup temporary file
rm -f "$TEMP_FILE"