#!/usr/bin/env bash

# 1. Example Confluence JSON/text URL. Replace with your actual endpoint if needed:
CONFLUENCE_URL="https://your.confluence.site/rest/api/content/12345?expand=body.storage"

# 2. Fetch content silently:
json_data="$(curl -s "$CONFLUENCE_URL")"

# 3. Flatten (remove) newlines, then split using Awk on either \"> or </fd>.
#    -F '(\\\\">|<\\/fd>)' means:
#       Delimiter #1 = \">
#       Delimiter #2 = </fd>
echo "$json_data" \
  | tr '\n' ' ' \
  | awk -F '(\\\\">|<\\/fd>)' '
    {
      # After splitting, the chunks between the two delimiters
      # become fields #2, #4, #6, etc.
      for (i = 2; i < NF; i += 2) {
        print $i
      }
    }
  '