#!/bin/bash

# Process the multi-line parameter, removing comment lines
my_processed_param=$(echo "$my_param" | grep -v '^#' | tr -d '\r')

# Now, 'my_processed_param' contains only the actual values

# Method 1: Using read -r to process each line
while IFS= read -r line; do
    echo "Processing line: $line"
    # Further process each line, e.g., split on '='
    if [[ "$line" != "" ]]; then # Check if the line is not empty
        IFS='=' read -r key value <<< "$line"
        echo "Key: $key, Value: $value"
    fi
done <<< "$my_processed_param"


# Method 2: Using an array (if appropriate for your use case)
IFS=$'\n' read -r -a lines <<< "$my_processed_param"
for line in "${lines[@]}"; do
    echo "Line from array: $line"
    if [[ "$line" != "" ]]; then # Check if the line is not empty
        IFS='=' read -r key value <<< "$line"
        echo "Key: $key, Value: $value"
    fi
done
