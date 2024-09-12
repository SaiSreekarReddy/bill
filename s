#!/bin/bash

# Jenkins provides SSH_USER and SSH_PASS from the credentials
echo "Using credentials for SSH access..."

# Loop through each IP address from SERVER_IPS
while read -r SERVER_IP; do
    echo "Checking server $SERVER_IP..."

    # Detect the server type and application name
    serverType=$(sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no $SSH_USER@$SERVER_IP "
        if [ -d '/opt/jboss' ]; then 
            echo jboss; 
        elif [ -d '/opt/springboot' ]; then 
            echo springboot; 
        else 
            echo no_type; 
        fi
    ")

    # Log the detected server type
    echo "Detected server type on $SERVER_IP: $serverType"

    # Check if a valid server type was found
    if [ "$serverType" == "no_type" ]; then
        echo "No specific server detected on $SERVER_IP"
        continue
    fi

    # Fetch application name based on server type
    if [ "$serverType" == "jboss" ]; then
        echo "Fetching application name from /opt/jboss/instance on $SERVER_IP"
        appName=$(sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no $SSH_USER@$SERVER_IP "ls /opt/jboss/instance | head -n 1")
        appName=${appName/_0000/}  # Remove "_0000" suffix for JBoss app names
    elif [ "$serverType" == "springboot" ]; then
        echo "Fetching application name from /opt/springboot/applications on $SERVER_IP"
        appName=$(sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no $SSH_USER@$SERVER_IP "ls /opt/springboot/applications | head -n 1")
        appName=${appName/-web/}  # Remove "-web" suffix for Spring Boot app names
    fi

    # Check if application name was found
    if [ -z "$appName" ]; then
        echo "No application name found on $SERVER_IP"
        continue
    fi

    # Check application status
    echo "Detected $serverType server, application: $appName"
    status=$(sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no $SSH_USER@$SERVER_IP "systemctl status $appName | head -n 5")
    
    # Output the status directly to the Jenkins console
    echo "Status on $SERVER_IP:"
    echo "$status"
    echo "------------------------------"
done <<< "$SERVER_IPS"

# Optionally, exit with a non-zero status if any errors occurred to mark the build as failed
if grep -q "inactive" <<< "$status"; then
    echo "One or more applications are inactive. Marking the build as failed."
    exit 1  # Mark the build as failed if any application is down
else
    echo "All applications are running successfully."
    exit 0  # Mark the build as successful
fi
