#!/bin/bash
# toggle-hand-gripper.sh - Toggles the hand gripper reminder script

SCRIPT_PATH="/home/kyae-dev/Documents/desktop-mindbank/scripts/hand-gripper.sh"

# Find if it's running
# Note: we check for "bash $SCRIPT_PATH" to avoid killing the wrong thing
PID=$(pgrep -f "bash $SCRIPT_PATH")

if [ -n "$PID" ]; then
    kill "$PID"
    notify-send "Hand Gripper Timer" "DISABLED"
    echo "Hand gripper timer disabled (killed PID $PID)."
else
    # Start it in background
    bash "$SCRIPT_PATH" &
    notify-send "Hand Gripper Timer" "ENABLED (8-minute interval)"
    echo "Hand gripper timer enabled in background."
fi
