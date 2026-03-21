#!/bin/bash

# --- CRON ENVIRONMENT FIX ---
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export WAYLAND_DISPLAY="wayland-0"

# 1. Setup Logging
LOG_DIR="$HOME/status_logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="$LOG_DIR/status_$TIMESTAMP.log"

echo "=== Git Status Run at $(date) ===" > "$LOG_FILE"

# 2. Define the path to your env file and setup trackers
ENV_DIR="../environments"
ENV_FILE="${ENV_DIR}/.git_status.env"

# Safety check: must stay inside ./environments
case "$ENV_FILE" in
  "$ENV_DIR"/*) ;;
  *) echo "Invalid env file path: $ENV_FILE"; exit 1 ;;
esac

if [ ! -f "$ENV_FILE" ]; then
  mkdir -p "$ENV_DIR"
  touch "$ENV_FILE"
  echo "Created missing env file: $ENV_FILE"
fi
DIRTY_REPOS=0
DIRTY_NAMES=""

# 3. Read the env file line by line
while IFS=':' read -r REPO_DIR BRANCH || [ -n "$REPO_DIR" ]; do

    # Skip empty lines and comments
    [[ -z "$REPO_DIR" || "$REPO_DIR" =~ ^# ]] && continue

    echo "-> $REPO_DIR" >> "$LOG_FILE"

    if [ -d "$REPO_DIR" ]; then
        cd "$REPO_DIR" || continue

        STATUS=$(/usr/bin/git status --short --branch)
        echo "$STATUS" >> "$LOG_FILE"

        # Check for uncommitted changes or unpushed commits
        if [ $(echo "$STATUS" | wc -l) -gt 1 ] || echo "$STATUS" | grep -q "\[ahead"; then
            DIRTY_REPOS=$((DIRTY_REPOS + 1))

            REPO_NAME=$(basename "$REPO_DIR")

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

done < "$ENV_FILE"

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