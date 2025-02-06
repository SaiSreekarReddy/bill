#!/usr/bin/env bash

CONFLUENCE_URL="https://your.confluence.site/rest/api/content/12345?expand=body.storage"
json_data="$(curl -s "$CONFLUENCE_URL")"

# We remove newlines so that the pattern does not break across lines.
echo "$json_data" \
  | tr '\n' ' ' \
  | awk '
  {
    # Explanation of the regex: /\\*>([^<]+)(?:<\/fd>|<\/span>)/
    #
    # 1)  \\*>     matches a backslash, then ">", literally:  \">
    # 2)  ([^<]+)  captures everything until the next "<"
    # 3)  (?:<\/fd>|<\/span>)
    #     is a non-capturing group (?: ...) which matches EITHER:
    #        </fd> OR </span>
    #
    # So effectively, we grab:  \">SOMETHING</fd>  OR  \">SOMETHING</span>
    #
    # match(..., arr) puts the entire matched string into arr[0],
    # and the captured text (the ([^<]+) portion) into arr[1].
    #
    # Then we remove the matched portion from the front of $0, so
    # if there are multiple occurrences, we can keep searching.

    while (match($0, /\\*>([^<]+)(?:<\/fd>|<\/span>)/, arr)) {
      print arr[1]
      # Chop off everything up to the end of this match
      $0 = substr($0, RSTART + RLENGTH)
    }
  }
  '