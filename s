#!/bin/bash

# Declare an associative array to link multiple ARE_codes to a single ARE_name
declare -A ARE_mapping

# Populate the array with grouped codes as keys and names as values
ARE_mapping["ARE001 ARE002 ARE322 ARE232"]="Area Name 1"
ARE_mapping["ARE100 ARE200 ARE300"]="Area Name 2"
ARE_mapping["ARE400 ARE500"]="Area Name 3"

# Function to find the ARE_name for a given ARE_code
get_are_name() {
    local input_code=$1
    for key in "${!ARE_mapping[@]}"; do
        # Check if the input_code exists in the current key (space-separated list)
        if [[ " $key " == *" $input_code "* ]]; then
            echo "${ARE_mapping[$key]}"
            return
        fi
    done
    echo "Invalid ARE code: $input_code"
}

# Example usage
read -p "Enter an ARE code (e.g., ARE001): " input_code
ARE_name=$(get_are_name "$input_code")
echo "The name for $input_code is: $ARE_name"
