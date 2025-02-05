#!/usr/bin/env bash
#
# extract_jira_summary_words.sh
#
# Usage:
#   ./extract_jira_summary_words.sh <USERNAME> <PASSWORD_OR_TOKEN> <JIRA_BASE_URL> <ISSUE_KEY>
#
# Example:
#   ./extract_jira_summary_words.sh \
#       "me@example.com" \
#       "myApiToken" \
#       "https://mycompany.atlassian.net" \
#       "PROJ-123"
#
# This script will output the entire summary and then list each word
# as a separate variable (WORD1, WORD2, etc.).

set -e

if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <USERNAME> <PASSWORD_OR_TOKEN> <JIRA_BASE_URL> <ISSUE_KEY>"
  exit 1
fi

USERNAME="$1"
PASSWORD="$2"
JIRA_BASE_URL="$3"
ISSUE_KEY="$4"

# 1) Retrieve the ticket JSON via Jira REST API (v2).
#    We only ask for the 'summary' field to reduce payload size.
RESPONSE="$(curl -s -u "${USERNAME}:${PASSWORD}" \
  -X GET "${JIRA_BASE_URL}/rest/api/2/issue/${ISSUE_KEY}?fields=summary")"

# 2) Extract the 'summary' field from the JSON response using jq.
SUMMARY="$(echo "${RESPONSE}" | jq -r '.fields.summary')"

if [ "${SUMMARY}" == "null" ] || [ -z "${SUMMARY}" ]; then
  echo "Error: Could not retrieve summary. Check credentials, issue key, or permissions."
  exit 1
fi

echo "Full summary: \"${SUMMARY}\""
echo

# 3) Split the summary into an array of words by whitespace.
IFS=' ' read -r -a WORDS_ARRAY <<< "${SUMMARY}"

# 4) For each word, assign it to a variable named WORD1, WORD2, etc.
for i in "${!WORDS_ARRAY[@]}"; do
  # shellcheck disable=SC2086
  eval "WORD$((i+1))=\"${WORDS_ARRAY[i]}\""
done

# 5) Print each WORDx variable (for demonstration).
for i in "${!WORDS_ARRAY[@]}"; do
  varname="WORD$((i+1))"
  echo "${varname}: ${!varname}"
done