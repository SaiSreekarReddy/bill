#!/bin/bash

jira_data=$(curl -s "YOUR_JIRA_URL" | jq -r '.key,.fields.issuelinks[].outwardIssue.key,.fields.issuelinks[].inwardIssue.key' | grep -v null)

related_issues=()

while IFS= read -r issue_key; do
  related_issues+=("$issue_key")
done <<< "$jira_data"

# Remove duplicate entries if any
related_issues=("${!related_issues[@]}")

# Print the array elements (for verification)
for i in "${!related_issues[@]}"; do
  echo "Related Issue ${i}: ${related_issues[$i]}"
done

# Example of accessing a specific element:
echo "Parent issue: ${related_issues[0]}"

