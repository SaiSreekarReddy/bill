#!/bin/bash

# Email or log report variables (save the log file in the Jenkins workspace)
LOG_FILE="${WORKSPACE}/server_status_report.txt"

# Clean the log file
> $LOG_FILE

# Loop through each IP address from SERVER_IPS
while read -r SERVER_IP; do
    echo "Checking server $SERVER_IP..." >> $LOG_FILE
    USERNAME="your_username"
    PASSWORD="your_password"
    
    # Detect the server type and application name
    serverType=$(sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no $USERNAME@$SERVER_IP "if [ -d '/opt/jboss' ]; then echo jboss; elif [ -d '/opt/springboot' ]; then echo springboot; else echo regular; fi")

    if [ "$serverType" == "jboss" ]; then
        appName=$(sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no $USERNAME@$SERVER_IP "ls /opt/jboss/instance | head -n 1")
        appName=${appName/_0000/}
    elif [ "$serverType" == "springboot" ]; then
        appName=$(sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no $USERNAME@$SERVER_IP "ls /opt/springboot/applications | head -n 1")
        appName=${appName/-web/}
    else
        echo "No specific server detected on $SERVER_IP" >> $LOG_FILE
        continue
    fi

    # Check application status
    echo "Detected $serverType server, application: $appName" >> $LOG_FILE
    status=$(sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no $USERNAME@$SERVER_IP "systemctl status $appName | head -n 5")
    
    # Log the status
    echo "Status on $SERVER_IP:" >> $LOG_FILE
    echo "$status" >> $LOG_FILE
    echo "------------------------------" >> $LOG_FILE
done <<< "$SERVER_IPS"

# Display the log file content in the Jenkins console output
cat $LOG_FILE

# Optionally, exit with a non-zero status if any errors occurred to mark the build as failed
if grep -q "inactive" $LOG_FILE; then
    echo "One or more applications are inactive. Marking the build as failed."
    exit 1  # Mark the build as failed if any application is down
else
    echo "All applications are running successfully."
    exit 0  # Mark the build as successful
fi
