#!/bin/bash

# List of servers taken from Jenkins Multi-String Parameter (pass the parameter as $1)
servers="$1"

# Function to detect server type (JBoss or Spring Boot)
detect_server_type() {
    local server_ip="$1"
    
    # Use SSH to check if JBoss or Spring Boot is running on the server
    if ssh "$server_ip" "pgrep -f 'jboss'" > /dev/null 2>&1; then
        echo "JBoss"
    elif ssh "$server_ip" "pgrep -f 'spring-boot'" > /dev/null 2>&1; then
        echo "Spring Boot"
    else
        echo "Unknown"
    fi
}

# Function to get the application name based on server type
get_application_name() {
    local server_ip="$1"
    local server_type="$2"
    local app_name=""

    if [ "$server_type" == "JBoss" ]; then
        # Fetch JBoss application name
        app_name=$(ssh "$server_ip" "ps -ef | grep -i 'jboss' | grep -v 'grep' | awk '{print \$NF}'")
    elif [ "$server_type" == "Spring Boot" ]; then
        # Fetch Spring Boot application name
        app_name=$(ssh "$server_ip" "ps -ef | grep -i 'spring-boot' | grep -v 'grep' | awk '{print \$NF}'")
    fi

    # Clean up the application name by removing known suffixes (like _0000 or -web)
    app_name=$(echo "$app_name" | sed 's/_0000//g' | sed 's/-web//g')

    echo "$app_name"
}

# Loop through each server and log the server type and application name
echo "Checking servers:"

IFS=$'\n' # Ensure we handle multi-line server input correctly
for server_ip in $servers; do
    echo "----------------------------------------"
    echo "Checking Server: $server_ip"
    
    # Detect the server type
    server_type=$(detect_server_type "$server_ip")
    echo "Detected Server Type: $server_type"
    
    # If a known server type, get the application name
    if [ "$server_type" != "Unknown" ]; then
        application_name=$(get_application_name "$server_ip" "$server_type")
        echo "Application Name: $application_name"
    else
        echo "No known server type detected on $server_ip"
    fi
done
