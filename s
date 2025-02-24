#!/bin/bash

# Jenkins Parameter
CONFLUENCE_URL="${CONFLUENCE_URL}"

# Extract base URL
BASE_URL=$(echo "$CONFLUENCE_URL" | awk -F'/display/' '{print $1}')

# Extract SPACEKEY and TITLE
SPACEKEY=$(echo "$CONFLUENCE_URL" | awk -F'/display/' '{print $2}' | awk -F'/' '{print $1}')
TITLE=$(echo "$CONFLUENCE_URL" | awk -F'/display/.*/' '{print $2}' | sed 's/+/ /g')

# URL encode TITLE properly for API (replace spaces with '+')
TITLE_ENCODED=$(echo "$TITLE" | sed 's/ /+/g')

echo "Base URL: $BASE_URL"
echo "Space Key: $SPACEKEY"
echo "Title: $TITLE"

# Call the Confluence API to retrieve PAGE_ID
PAGE_ID=$(curl -s -u user:password \
  "${BASE_URL}/rest/api/content?title=${TITLE_ENCODED}&spaceKey=${SPACEKEY}" \
  | jq -r '.results[0].id')

echo "Retrieved Page ID: ${PAGE_ID}"

# Now use PAGE_ID as before