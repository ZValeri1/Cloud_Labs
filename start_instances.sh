#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$SCRIPT_DIR/app"
PIDS=()

PORTS=(5001 5002 5003 5004)

echo "Starting Flask app instances..."

for PORT in "${PORTS[@]}"; do
    cd "$APP_DIR"
    source "$SCRIPT_DIR/venv/bin/activate"
    python app.py "$PORT" &
    PIDS+=($!)
    echo "  Started instance on port $PORT (PID: ${!})"
done

echo ""
echo "All instances running. PIDs: ${PIDS[*]}"
echo "To stop all instances, run: kill ${PIDS[*]}"
echo ""
echo "Verify: curl http://localhost:5001/"
echo "        curl http://localhost:5002/"

wait
