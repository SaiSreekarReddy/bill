#!/bin/bash

# Set Confluence credentials
CONFLUENCE_USERNAME="your_email@domain.com"
CONFLUENCE_API_TOKEN="your_api_token"
CONFLUENCE_URL="https://your-domain.atlassian.net"

# Read Confluence Page ID
read -p "Enter the Confluence Page ID: " PAGE_ID

# Temporary files
JSON_FILE="confluence_page.json"
HTML_FILE="decoded_page.html"

# Fetch Confluence page content and save JSON response
curl -s -u "$CONFLUENCE_USERNAME:$CONFLUENCE_API_TOKEN" -X GET \
  -H "Content-Type: application/json" \
  "$CONFLUENCE_URL/rest/api/content/$PAGE_ID?expand=body.storage" > "$JSON_FILE"

# Extract and decode HTML content from JSON
jq -r '.body.storage.value' "$JSON_FILE" | python3 -c "import sys, html; print(html.unescape(sys.stdin.read()))" > "$HTML_FILE"

# Extract malcodes (values between ">malcode<")
MALCODES=$(grep -oP '(?<=\u003E)[Mm][Aa][Ll][Cc][Oo][Dd][Ee]-[0-9]+' "$HTML_FILE" | sort -u)

# Verify if any malcodes were found
if [[ -z "$MALCODES" ]]; then
    echo "No malcodes found on Confluence page $PAGE_ID."
    exit 1
fi

# Loop through each extracted malcode and echo it
echo "Extracted Malcodes:"
echo "$MALCODES" | while IFS= read -r line; do
    echo "$line"
done

# Cleanup temporary files
rm -f "$JSON_FILE" "$HTML_FILE"