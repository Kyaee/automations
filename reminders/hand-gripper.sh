#!/bin/bash
# hand-gripper.sh - Reminds to use hand gripper every 8 minutes
while true; do
    sleep 480 # 8 minutes
    notify-send -u critical "Hand Gripper" "Time to use your hand gripper!"
done
