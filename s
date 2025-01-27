#!/bin/bash

# Define the list of servers
servers=("server1" "server2" "server3")

# SSH credentials
user="your_ssh_user"
password="your_ssh_password" # Optional if SSH keys are used

# Loop through each server
for server in "${servers[@]}"; do
    echo "Checking server: $server"

    # Connect to the server and check for running processes
    sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$user@$server" bash -c "'
        if ps -ef | grep -q [D]eploymentManager; then
            echo \"$server is a Deployment Management Server\"
        elif ps -ef | grep -q [h]ttpd; then
            echo \"$server is an IHS Node\"
        elif ps -ef | grep -q [A]ppServer; then
            echo \"$server is an App Node\"
        else
            echo \"$server type is unknown\"
        fi
    '"
done

echo "All servers checked."