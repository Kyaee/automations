#!/bin/bash

# --- CRON ENVIRONMENT FIX ---
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export WAYLAND_DISPLAY="wayland-0"

# 1. Setup Logging
LOG_DIR="/home/kyae-dev/Repos/kyae-automations/git_status/logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="$LOG_DIR/status_$TIMESTAMP.log"

echo "=== Git Status Run at $(date) ===" > "$LOG_FILE"

# 2. Define Repositories (Paths only)
REPOS=(
    "/home/kyae-dev/Repos/aws-email-automation"
    "/home/kyae-dev/Repos/job/fusion-warehouse-web"
    "/home/kyae-dev/Repos/job/leados-api"
    "/home/kyae-dev/Repos/job/leados-ui"
    "/home/kyae-dev/Repos/job/fusion-fulfillment-mobile-native"
    "/home/kyae-dev/Repos/job/dig-developers-bible"
)

# Trackers for the notification
DIRTY_REPOS=0
DIRTY_NAMES=""

# 3. Loop through and check status
for REPO_DIR in "${REPOS[@]}"; do
    echo "-> $REPO_DIR" >> "$LOG_FILE"

    if [ -d "$REPO_DIR" ]; then
        cd "$REPO_DIR" || continue
        
        STATUS=$(/usr/bin/git status --short --branch)
        echo "$STATUS" >> "$LOG_FILE"
        
        if [ $(echo "$STATUS" | wc -l) -gt 1 ] || echo "$STATUS" | grep -q "\[ahead"; then
            DIRTY_REPOS=$((DIRTY_REPOS + 1))
            
            # Extract just the folder name for the notification
            REPO_NAME=$(basename "$REPO_DIR")
            
            # Append to our list of names
            if [ -z "$DIRTY_NAMES" ]; then
                DIRTY_NAMES="$REPO_NAME"
            else
                DIRTY_NAMES="$DIRTY_NAMES, $REPO_NAME"
            fi
        fi
    else
        echo "   [ERROR] Directory not found." >> "$LOG_FILE"
    fi
    echo "--------------------------------" >> "$LOG_FILE"
done

echo -e "=== Run Complete ===\n" >> "$LOG_FILE"

# 4. Smart Notification
if [ "$DIRTY_REPOS" -gt 0 ]; then
    (
        ACTION=$(/usr/bin/notify-send -u critical --action="open=View Status" "Git Alert: $DIRTY_REPOS Repos Pending" "Changes in: $DIRTY_NAMES")
        
        if [ "$ACTION" == "open" ]; then
            /usr/bin/gnome-text-editor "$LOG_FILE"
        fi
    ) &
else
    /usr/bin/notify-send -u low "Git Status" "All tracked repositories are clean."
fi
