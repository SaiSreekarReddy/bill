#!/bin/bash

# --- Configuration ---
USER="user"
PASS="pass"
URL="https://base_url/rest/API/content/pageid?expand=body.storage"
EXCLUDED_TICKET="CRHPCDR456"  # The match you want to exclude

# --- Step 1: Retrieve JSON response ---
response=$(curl -s -u "${USER}:${PASS}" -X GET \
         -H "Content-Type: application/json" "${URL}")

# --- Step 2: Extract matches starting with CRHPCDR ---
matches=$(echo "${response}" | grep -o 'CRHPCDR[^"]*')

# --- Step 3 & 4: Store matches in an array, skip duplicates & excluded ticket ---
my_array=()

# Helper function to check if an item is in our array
function array_contains() {
  local element
  for element in "${my_array[@]}"; do
    if [[ "$element" == "$1" ]]; then
      return 0  # Found
    fi
  done
  return 1  # Not found
}

# Iterate through each matched string
for m in $matches; do
  # Skip if it matches the excluded ticket
  if [[ "$m" == "$EXCLUDED_TICKET" ]]; then
    continue
  fi
  
  # Skip if it's already in our array (to avoid duplicates)
  if ! array_contains "$m"; then
    my_array+=("$m")
  fi
done

# --- Show results ---
echo "Collected unique matches (excluding $EXCLUDED_TICKET):"
for item in "${my_array[@]}"; do
  echo "$item"
done