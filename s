#!/bin/bash

MULTI_STRING_PARAM="$MULTI_STRING_PARAM"  # Important: ensure the parameter is available in the shell script

while IFS= read -r line; do
  [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue  # Ignore comments and empty lines
  echo "Processing: $line"
  # Example: Split and process key-value pairs
  if [[ "$line" != "" ]]; then
      IFS='=' read -r key value <<< "$line"
      echo "Key: $key, Value: $value"
  fi
done <<< "$MULTI_STRING_PARAM"
