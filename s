#!/usr/bin/env bash

# Script: extract_between.sh
# Purpose:
#   1. Fetch Confluence (or other) text that might contain patterns like:
#         \">some text ... possibly <span> or </span> ...</gh>
#   2. Print only that "some text ... possibly <span> or </span> ..." part,
#      one match per line.

# 1. Your Confluence JSON/text URL:
CONFLUENCE_URL="https://your.confluence.site/rest/api/content/12345?expand=body.storage"

# 2. Fetch content silently into a variable:
json_data="$(curl -s "$CONFLUENCE_URL")"

# 3. Pipe through "tr" to remove newlines, then feed into awk.
#    The pattern we use in match():
#
#    /\\">([^<]|<[^/]|<\/[^g]|<\/g[^h])*<\\/gh>/
#
#    Explanation (simplified):
#      -  \\">  matches the literal sequence: backslash + " + >
#      -  ([^<]|<[^/]|<\/[^g]|<\/g[^h])*
#         means "any characters that do not form the exact substring '</gh>'"
#         This allows inside text to contain tags like </span> or anything else.
#      -  <\\/gh> matches the literal '</gh>' (backslashes are escapes for the slash).
#
#    Once we find a match, we remove the leading \"> and trailing </gh> before printing.

echo "$json_data" \
  | tr '\n' ' ' \
  | awk '
    {
      while (match($0, /\\">([^<]|<[^/]|<\/[^g]|<\/g[^h])*<\\/gh>/)) {
        # Entire matched text is something like:
        #     \">SOMETHING...maybe </span> etc</gh>
        #
        # RSTART = start index of the match
        # RLENGTH = length of the match
        #
        # We know the match includes the prefix \"> (3 characters)
        # and the suffix </gh> (5 characters).
        # So the actual content we want is everything *after* the first 3 chars
        # and *before* the last 5 chars:

        prefix_len = 3
        suffix_len = 5

        extracted = substr($0, RSTART + prefix_len, RLENGTH - prefix_len - suffix_len)
        print extracted

        # Now remove the matched portion from $0 so we can find further matches:
        $0 = substr($0, RSTART + RLENGTH)
      }
    }
  '