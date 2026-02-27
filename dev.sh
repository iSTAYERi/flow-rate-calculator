#!/bin/bash
# Kill any process on port 1420 before starting
PID=$(netstat -ano 2>/dev/null | grep ':1420.*LISTENING' | awk '{print $5}' | head -1)
if [ -n "$PID" ]; then
  echo "Killing process $PID on port 1420..."
  taskkill //PID "$PID" //F 2>/dev/null
  sleep 1
fi

cd "$(dirname "$0")"
npm run tauri dev
