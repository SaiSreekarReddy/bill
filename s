#!/bin/bash

# Read servers from Jenkins multi-line string parameter
SERVERS=()
while IFS= read -r line; do
    SERVERS+=("$line")
done <<< "$SERVER_LIST"  # Assuming `SERVER_LIST` is the Jenkins parameter

APP_CHECK_COMMAND="ps aux | grep -v grep | grep your-app-name"
LOG_FILE="servers_down.txt"

# Clear previous log file
> "$LOG_FILE"

DOWN_COUNT=0

echo "Checking servers..." | tee -a "$LOG_FILE"

for SERVER in "${SERVERS[@]}"; do
    echo "Checking $SERVER..."
    
    # Check if application is running
    if ssh user@"$SERVER" "$APP_CHECK_COMMAND" >/dev/null 2>&1; then
        echo "$SERVER: Application is running."
    else
        echo "$SERVER: Application is down!" | tee -a "$LOG_FILE"
        ((DOWN_COUNT++))

        # Get last 10 log entries (adjust path accordingly)
        echo "Fetching logs from $SERVER..." | tee -a "$LOG_FILE"
        ssh user@"$SERVER" "tail -n 10 /var/log/your-app.log" >> "$LOG_FILE" 2>&1

        echo "--------------------------------------------------" >> "$LOG_FILE"
    fi
done

if [[ "$DOWN_COUNT" -ge 4 ]]; then
    echo "ALERT: $DOWN_COUNT servers are down! Check $LOG_FILE for details."
else
    echo "All or most servers are operational."
fi

# Send email if any server is down
if [[ "$DOWN_COUNT" -gt 0 ]]; then
    echo "Sending email with server report..."
    mail -s "Jenkins Alert: $DOWN_COUNT Servers Down" -a "$LOG_FILE" recipient@example.com < /dev/null
fi

exit 0