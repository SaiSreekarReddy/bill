#!/bin/bash

# Declare an associative array to link ARE_codes with ARE_names
declare -A ARE_mapping

# Populate the array with ARE_codes as keys and ARE_names as values
ARE_mapping=(
    ["ARE001"]="Area Name 1"
    ["ARE002"]="Area Name 2"
    ["ARE003"]="Area Name 3"
    ["ARE004"]="Area Name 4"
)

# Example usage
read -p "Enter an ARE code (e.g., ARE001): " input_code

# Check if the code exists in the array
if [[ -n "${ARE_mapping[$input_code]}" ]]; then
    # Assign the corresponding name to a variable
    ARE_name="${ARE_mapping[$input_code]}"
    echo "The name for $input_code is: $ARE_name"
else
    echo "Invalid ARE code: $input_code"
fi
