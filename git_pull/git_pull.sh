#!/bin/bash

# 1. Setup the Logging Directory
LOG_DIR="/home/kyae-dev/Repos/kyae-automations/git_pull/logs"

# 2. Generate a unique log file name (e.g., pull_2026-03-21_16-30-00.log)
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="$LOG_DIR/pull_$TIMESTAMP.log"

echo "=== Auto Pull Run at $(date) ===" > "$LOG_FILE"

# 3. Define repositories and their target branches
declare -A REPOS=(
    ["/home/kyae-dev/Repos/aws-email-automation"]="main"
    ["/home/kyae-dev/Repos/job/fusion-warehouse-web"]="staging"
    ["/home/kyae-dev/Repos/job/leados-api"]="staging"
    ["/home/kyae-dev/Repos/job/leados-ui"]="staging"
    ["/home/kyae-dev/Repos/job/fusion-fulfillment-mobile-native"]="staging"
)

# 4. Loop through the array and pull each one
for REPO_DIR in "${!REPOS[@]}"; do
    BRANCH="${REPOS[$REPO_DIR]}"

    echo "-> Checking: $REPO_DIR (Branch: $BRANCH)" >> "$LOG_FILE"

    if [ -d "$REPO_DIR" ]; then
        cd "$REPO_DIR" || continue
        /usr/bin/git pull origin "$BRANCH" >> "$LOG_FILE" 2>&1
    else
        echo "   [ERROR] Directory not found. Skipping." >> "$LOG_FILE"
    fi

    echo "--------------------------------" >> "$LOG_FILE"
done

echo -e "=== Run Complete ===\n" >> "$LOG_FILE"
/usr/bin/notify-send "Git Auto-Pull Finished" "Checked ${#REPOS[@]} repositories. Logs saved to pull_logs."
