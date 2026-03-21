#!/bin/bash

# --- CRON ENVIRONMENT FIX ---
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export WAYLAND_DISPLAY="wayland-0"

# 1. Setup the Logging Directory
LOG_DIR="$HOME/Repos/kyae-automations/git_pull/logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="$LOG_DIR/pull_$TIMESTAMP.log"

echo "=== Auto Pull Run at $(date) ===" > "$LOG_FILE"

# 2. Define the path to your new env file
ENV_FILE="../environments/.git_pull.env"

if [ ! -f "$ENV_FILE" ]; then
  mkdir -p "$(dirname "$ENV_FILE")"
  cat > "$ENV_FILE" <<'EOF'
# Auto-created environment file
BRANCH=main
REMOTE=origin
EOF
  echo "Created missing env file with defaults: $ENV_FILE"
fi
REPO_COUNT=0

# 3. Read the env file line by line
# IFS=':' splits each line at the colon so $REPO_DIR gets the path and $BRANCH gets the branch
while IFS=':' read -r REPO_DIR BRANCH || [ -n "$REPO_DIR" ]; do
    
    # Skip empty lines and comments (lines starting with #)
    [[ -z "$REPO_DIR" || "$REPO_DIR" =~ ^# ]] && continue

    # Increment our counter for the notification
    ((REPO_COUNT++))
    
    echo "-> Checking: $REPO_DIR (Branch: $BRANCH)" >> "$LOG_FILE"

    if [ -d "$REPO_DIR" ]; then
        cd "$REPO_DIR" || continue
        /usr/bin/git pull origin "$BRANCH" >> "$LOG_FILE" 2>&1
    else
        echo "   [ERROR] Directory not found. Skipping." >> "$LOG_FILE"
    fi
    
    echo "--------------------------------" >> "$LOG_FILE"

done < "$ENV_FILE"

echo -e "=== Run Complete ===\n" >> "$LOG_FILE"

# 4. Interactive Desktop Notification
(
    ACTION=$(/usr/bin/notify-send --action="open=View Log" "Git Auto-Pull Finished" "Checked $REPO_COUNT repositories.")
    
    if [ "$ACTION" == "open" ]; then
        /usr/bin/gnome-text-editor "$LOG_FILE"
    fi
) &