#!/bin/bash

# Define SSH login credentials (use Jenkins environment variables or replace with your actual credentials)
ssh_user="your_username"
ssh_pass="your_password"

# Ensure we handle multi-line input from Jenkins correctly
IFS=$'\n'  # Set Internal Field Separator to newline to handle multi-line input correctly

# Function to detect server type (based on directory presence)
detect_server_type() {
    local server_ip="$1"

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
        app_name=$(sshpass -p "$ssh_pass" ssh -o StrictHostKeyChecking=no "$ssh_user@$server_ip" "ls /opt/jboss/deployments | head -n 1")
    elif [ "$server_type" == "Spring Boot" ]; then
        app_name=$(sshpass -p "$ssh_pass" ssh -o StrictHostKeyChecking=no "$ssh_user@$server_ip" "ls /opt/springboot/deployments | head -n 1")
    fi

    app_name=$(echo "$app_name" | sed 's/_0000//g' | sed 's/-web//g')

    echo "$app_name"
}

# Function to check if the application is active using pgrep or ps
is_application_active() {
    local server_ip="$1"
    local server_type="$2"
    local app_name="$3"
    local status="inactive"

    if [ "$server_type" == "JBoss" ]; then
        # Check if JBoss process is running
        status=$(sshpass -p "$ssh_pass" ssh -o StrictHostKeyChecking=no "$ssh_user@$server_ip" "pgrep -f 'jboss' > /dev/null && echo active || echo inactive")
    elif [ "$server_type" == "Spring Boot" ]; then
        # Check if Spring Boot process is running
        status=$(sshpass -p "$ssh_pass" ssh -o StrictHostKeyChecking=no "$ssh_user@$server_ip" "pgrep -f '$app_name' > /dev/null && echo active || echo inactive")
    fi

    echo "$status"
}

# Function to start the application if it's inactive
start_application() {
    local server_ip="$1"
    local server_type="$2"
    local app_name="$3"

    if [ "$server_type" == "JBoss" ]; then
        echo "Starting JBoss on $server_ip"
        sshpass -p "$ssh_pass" ssh -o StrictHostKeyChecking=no "$ssh_user@$server_ip" "systemctl start jboss"
    elif [ "$server_type" == "Spring Boot" ]; then
        echo "Starting Spring Boot ($app_name) on $server_ip"
        sshpass -p "$ssh_pass" ssh -o StrictHostKeyChecking=no "$ssh_user@$server_ip" "service /opt/springboot $app_name start"
    fi
}

# Main loop to process each server
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
        
        # Check if the application is active
        app_status=$(is_application_active "$server_ip" "$server_type" "$application_name")
        echo "Application Status: $app_status"
        
        # If the application is inactive, start it
        if [ "$app_status" == "inactive" ]; then
            echo "Application is inactive, starting the application..."
            start_application "$server_ip" "$server_type" "$application_name"
        else
            echo "Application is already active."
        fi
    else
        echo "No known server type detected on $server_ip"
    fi
done
