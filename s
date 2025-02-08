#!/bin/bash

# Function to randomly select an element from an array
random_color() {
    local array=("$@") # Capture the array passed as arguments
    local random_index=$((RANDOM % ${#array[@]})) # Generate a random index
    echo "${array[$random_index]}" # Return the randomly selected element
}

# Example usage
test=("red" "blue" "green") # Define the array
random_color_value=$(random_color "${test[@]}") # Call the function and store the result

# Print the randomly selected value
echo "Randomly selected color: $random_color_value"
