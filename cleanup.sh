#!/bin/bash

# --- CRON ENVIRONMENT FIX ---
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export WAYLAND_DISPLAY="wayland-0"

# 1. Define the directories where your logs live
LOG_DIRS=(
    "./pull_logs"
    "./status_logs"
)

DELETED_TOTAL=0
DETAILS=""

# 2. Loop through each directory and delete the logs
for DIR in "${LOG_DIRS[@]}"; do
    if [ -d "$DIR" ]; then
        # Count how many .log files exist
        FILE_COUNT=$(find "$DIR" -maxdepth 1 -name "*.log" -type f | wc -l)

        if [ "$FILE_COUNT" -gt 0 ]; then
            # Delete the files
            rm -f "$DIR"/*.log
            DELETED_TOTAL=$((DELETED_TOTAL + FILE_COUNT))

            # Grab the folder name to make the notification look clean
            DIR_NAME=$(basename "$DIR")
            DETAILS="$DETAILS• $FILE_COUNT from $DIR_NAME\n"
        fi
    fi
done

# 3. Desktop Notification
if [ "$DELETED_TOTAL" -gt 0 ]; then
    # Alert showing exactly what was cleaned
    /usr/bin/notify-send -u normal "Log Cleanup Complete" "Removed $DELETED_TOTAL old log(s):\n$DETAILS"
else
    # A quiet ping if there was nothing to do
    /usr/bin/notify-send -u low "Log Cleanup" "All log folders are already clean."
fi