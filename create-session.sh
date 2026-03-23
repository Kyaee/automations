#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="$HOME/Documents/desktop-mindbank"

if ! command -v ptyxis >/dev/null 2>&1; then
  echo "Error: ptyxis is not installed or not in PATH." >&2
  exit 1
fi

# Start an interactive bash in the new terminal so PATH/aliases from ~/.bashrc are loaded.
ptyxis --new-window -- bash -ic "
  cd \"$TARGET_DIR\" || exit 1

  if command -v agent >/dev/null 2>&1; then
    agent
  else
    echo \"'agent' command not found in this shell. Check your PATH or shell startup files.\"
  fi

  exec bash
" &
