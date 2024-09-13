#!/bin/bash

# Define SSH login credentials (use Jenkins environment variables or replace with your actual credentials)
ssh_user="your_username"
ssh_pass="your_password"

# Ensure we handle multi-line input from Jenkins correctly
IFS=$'\n'  # Set Internal Field Separator to newline to handle multi-line input correctly

# Function to detect server type (based on directory presence)
detect_server_type() {
    local server_ip="$1"

    # Use sshpass to SSH into the server and check for specific directories
    if sshpass -p "$ssh_pass" ssh -o StrictHostKeyChecking=no "$ssh_user@$server_ip" "[ -d /opt/jboss ]" > /dev/null 2>&1; then
        echo "JBoss"
    elif sshpass -p "$ssh_pass" ssh -o StrictHostKeyChecking=no "$ssh_user@$server_ip" "[ -d /opt/springboot ]" > /dev/null 2>&1; then
        echo "Spring Boot"
    else
        echo "Unknown"
    fi
}

# Function to get the application name based on server type and the path logic
get_application_name() {
    local server_ip="$1"
    local server_type="$2"
    local app_name=""

    if [ "$server_type" == "JBoss" ]; then
        # Fetch JBoss application name from the deployments directory
        app_name=$(sshpass -p "$ssh_pass" ssh -o StrictHostKeyChecking=no "$ssh_user@$server_ip" "ls /opt/jboss/deployments | head -n 1")
    elif [ "$server_type" == "Spring Boot" ]; then
        # Fetch Spring Boot application name from the deployments directory
        app_name=$(sshpass -p "$ssh_pass" ssh -o StrictHostKeyChecking=no "$ssh_user@$server_ip" "ls /opt/springboot/deployments | head -n 1")
    fi

    # Clean up the application name by removing known suffixes (like _0000 or -web)
    app_name=$(echo "$app_name" | sed 's/_0000//g' | sed 's/-web//g')

    echo "$app_name"
}

# Loop through each server and log the server type and application name
echo "Processing servers from Jenkins Multi-Line String Parameter:"

for server_ip in ${Servers}; do
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
