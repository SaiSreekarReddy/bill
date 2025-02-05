#!/usr/bin/env bash

# Script: extract_code_blocks.sh
# Purpose:
#   1. Fetch a Confluence page as JSON or text.
#   2. Join everything into one line.
#   3. Split on the delimiter '">info</gh>'.
#   4. Print each chunk that appears between those delimiters on its own line.

# 1. Confluence REST API URL (example):
CONFLUENCE_URL="https://your.confluence.site/rest/api/content/12345?expand=body.storage"

# 2. Fetch the data.
json_data="$(curl -s "$CONFLUENCE_URL")"

# 3. Process with awk:
#    - 'tr '\n' ' '' merges lines so our delimiter match can span lines.
#    - The '-F "">info</gh>"' sets that delimiter.
#    - We skip $1 (everything before the first delimiter).
#    - Print each subsequent field ($2, $3, ...) on its own line.
echo "$json_data" \
  | tr '\n' ' ' \
  | awk -F '">info</gh>' '{
      for (i = 2; i <= NF; i++) {
          print $i
      }
    }'