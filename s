#!/usr/bin/env bash

# Example usage: ./extract_between.sh

# 1. Confluence (or other) URL:
CONFLUENCE_URL="https://your.confluence.site/rest/api/content/12345?expand=body.storage"

# 2. Fetch content silently:
json_data="$(curl -s "$CONFLUENCE_URL")"

# 3. Pass the fetched data to awk for extraction:
#
#    The regex /">([^<]+)<\/gh>/ means:
#      - literal characters `">`
#      - then capture one or more chars that are NOT '<' ( [^<]+ )
#      - then literal `</gh>`
#
#    match($0, /">([^<]+)<\/gh>/) finds the first match in $0;
#    substr(..., RSTART+2, RLENGTH-7) extracts just the capturing group.
#
#    We then remove that matched portion from the current line ($0)
#    so that we can find subsequent occurrences.

echo "$json_data" | awk '
{
  while (match($0, /">([^<]+)<\/gh>/)) {
    # Entire matched text is something like:  `">some_code</gh>`
    # That’s 2 chars for `">`, plus the captured text, plus 5 chars for `</gh>` = 7 extra chars total.
    #
    # So the substring for the captured group starts at RSTART+2 and
    # has length RLENGTH-7:
    extracted = substr($0, RSTART + 2, RLENGTH - 7)
    print extracted

    # Remove the matched portion from the current line, so we
    # can find the next match (if any):
    $0 = substr($0, RSTART + RLENGTH)
  }
}
'