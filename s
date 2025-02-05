#!/usr/bin/env bash

# Script: extract_info.sh
# Purpose: Demonstrate fetching a Confluence page as JSON and extracting all text
#          occurring between the literal string "\u003Einfo\u003C".

# 1. Define your Confluence REST API URL (expand the body.storage or whichever body you need).
CONFLUENCE_URL="https://your.confluence/rest/api/content/12345?expand=body.storage"

# 2. Fetch JSON into a variable (or directly pipe it).
json_data=$(curl -s "$CONFLUENCE_URL")

# 3. Use grep with PCRE (-P) and only-match (-o):
#    - Lookbehind for:  (?<=\\u003Einfo\\u003C)
#    - Non-greedy match: (.*?)
#    - Lookahead for:    (?=\\u003Einfo\\u003C)
#
#    Essentially, it says: "print the substring captured between each pair of
#    \u003Einfo\u003C markers."
echo "$json_data" | grep -oP '(?<=\\u003Einfo\\u003C)(.*?)(?=\\u003Einfo\\u003C)'









_-----------------------


#!/usr/bin/env bash

CONFLUENCE_URL="https://your.confluence/rest/api/content/12345?expand=body.storage"
json_data=$(curl -s "$CONFLUENCE_URL")

echo "$json_data" \
  | tr '\n' ' ' \
  | awk -F'\\u003Einfo\\u003C' '{
      # We skip the first field because it's everything before the first delimiter.
      # Then print all the other fields that appear *between* successive delimiters.
      for (i = 2; i <= NF; i++) {
          print $i
      }
    }'