
#!/bin/bash

# Read servers from Jenkins multi-line string parameter
SERVERS=()
while IFS= read -r line; do
    SERVERS+=("$line")
done <<< "$SERVER_LIST"  # Assuming `SERVER_LIST` is the Jenkins parameter

LOG_FILE="servers_down.txt"

# Define application log paths (Modify as needed)
declare -A APP_LOG_PATHS
APP_LOG_PATHS["app1"]="/var/log/app1.log"
APP_LOG_PATHS["app2"]="/var/log/app2/error.log"
APP_LOG_PATHS["app3"]="/opt/app3/logs/app.log"
APP_LOG_PATHS["your-app-name"]="/var/log/your-app.log"

# Clear previous log file
> "$LOG_FILE"

DOWN_COUNT=0

# Function to get the log path for an application
get_log_path() {
    local app_name="$1"
    echo "${APP_LOG_PATHS[$app_name]}"
}

# Function to log details
log_to_file() {
    local server="$1"
    local app_name="$2"
    
    # Get the log file path dynamically
    local log_path
    log_path=$(get_log_path "$app_name")

    if [[ -z "$log_path" ]]; then
        echo "No log path found for application: $app_name on $server" >> "$LOG_FILE"
        return
    fi