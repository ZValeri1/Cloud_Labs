#!/bin/bash

# Script to test failover behavior
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "====================================================="
echo "  Failover Test"
echo "====================================================="
echo ""

# Load failover config
bash "$SCRIPT_DIR/switch_nginx.sh" "06_failover.conf" > /dev/null 2>&1
sleep 1

# Reset counters
for PORT in 5001 5002 5003 5004; do
    curl -s -X POST http://127.0.0.1:$PORT/reset > /dev/null 2>&1
done

echo "Step 1: All 4 instances running. Sending 10 requests..."
for i in $(seq 1 10); do
    curl -s http://localhost/ > /dev/null
done

echo "  Distribution:"
for PORT in 5001 5002 5003 5004; do
    CNT=$(curl -s http://127.0.0.1:$PORT/info | python3 -c "import sys,json; print(json.load(sys.stdin)['counter'])" 2>/dev/null || echo "N/A")
    echo "    Port $PORT: $CNT"
done

echo ""
echo "Step 2: Killing instance on port 5001..."
pkill -f "python app.py 5001" 2>/dev/null
sleep 2

echo "  Sending 10 more requests..."
for i in $(seq 1 10); do
    curl -s http://localhost/ > /dev/null
done

echo "  Distribution after killing 5001:"
for PORT in 5001 5002 5003 5004; do
    CNT=$(curl -s http://127.0.0.1:$PORT/info 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['counter'])" 2>/dev/null || echo "DOWN")
    echo "    Port $PORT: $CNT"
done

echo ""
echo "Step 3: Killing instance on port 5002 as well..."
pkill -f "python app.py 5002" 2>/dev/null
sleep 2

echo "  Sending 10 more requests..."
for i in $(seq 1 10); do
    curl -s http://localhost/ > /dev/null
done

echo "  Distribution after killing 5001 and 5002:"
for PORT in 5001 5002 5003 5004; do
    CNT=$(curl -s http://127.0.0.1:$PORT/info 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['counter'])" 2>/dev/null || echo "DOWN")
    echo "    Port $PORT: $CNT"
done

echo ""
echo "Step 4: Restarting all instances..."
cd "$SCRIPT_DIR/app"
source "$SCRIPT_DIR/venv/bin/activate"
for PORT in 5001 5002; do
    python app.py $PORT &
done
sleep 2

echo "  Sending 10 more requests after recovery..."
for i in $(seq 1 10); do
    curl -s http://localhost/ > /dev/null
done

echo "  Distribution after recovery:"
for PORT in 5001 5002 5003 5004; do
    CNT=$(curl -s http://127.0.0.1:$PORT/info | python3 -c "import sys,json; print(json.load(sys.stdin)['counter'])" 2>/dev/null || echo "N/A")
    echo "    Port $PORT: $CNT"
done

echo ""
echo "====================================================="
echo "  Failover test complete."
echo "====================================================="
