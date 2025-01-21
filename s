#!/bin/bash

# Retrieve server IPs from the Jenkins multi-line string parameter
read -r -d '' SERVERS << EOM
server_ip_1
server_ip_2
server_ip_3
EOM

# Split server IPs into an array
IFS=$'\n' read -d '' -r -a SERVER_LIST <<< "$SERVERS"

# Loop through each server IP
for SERVER in "${SERVER_LIST[@]}"; do
    echo "Processing server: $SERVER"

    # Check if the server is accessible
    if ping -c 1 -W 1 "$SERVER" > /dev/null 2>&1; then
        echo "Server $SERVER is reachable."

        # Fetch the application names from the directory
        APP_PATH="/opt/sa"
        echo "Retrieving applications from $APP_PATH on $SERVER..."
        
        # Use SSH to list application directories
        APP_NAMES=$(ssh -o StrictHostKeyChecking=no "$SERVER" "ls $APP_PATH 2>/dev/null")

        if [ -n "$APP_NAMES" ]; then
            echo "Applications on $SERVER:"
            echo "$APP_NAMES"

            # Check each application's status
            for APP in $APP_NAMES; do
                echo "Checking status of application: $APP"

                # Define a command to check the application's status
                # Replace `your_status_check_command` with the actual command to check the status
                STATUS=$(ssh -o StrictHostKeyChecking=no "$SERVER" "ps -ef | grep $APP | grep -v grep")

                if [ -n "$STATUS" ]; then
                    echo "Application $APP is ACTIVE on $SERVER."
                else
                    echo "Application $APP is INACTIVE on $SERVER."
                fi
            done
        else
            echo "No applications found in $APP_PATH on $SERVER."
        fi
    else
        echo "Server $SERVER is not reachable. Skipping."
    fi
    echo "---------------------------------"
done
