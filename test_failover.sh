#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "====================================================="
echo "  Failover Test"
echo "====================================================="
echo ""

# Load failover config
echo '111' | sudo -S cp "$SCRIPT_DIR/nginx-configs/06_failover.conf" /etc/nginx/sites-available/loadbalancer 2>/dev/null
echo '111' | sudo -S nginx -s reload 2>/dev/null
sleep 1

# Reset counters
for PORT in 5001 5002 5003 5004; do
    curl -s -X POST http://127.0.0.1:$PORT/reset > /dev/null 2>&1
done

echo "Step 1: All 4 instances running. Sending 20 requests..."
for i in $(seq 1 20); do
    curl -s -0 http://localhost/ > /dev/null
done

echo "  Distribution:"
for PORT in 5001 5002 5003 5004; do
    CNT=$(curl -s -0 http://127.0.0.1:$PORT/info | grep -o '"counter":[0-9]*' | grep -o '[0-9]*')
    echo "    Port $PORT: $CNT"
done

echo ""
echo "Step 2: Killing instance on port 5001..."
kill $(ps aux | grep 'app.py 5001' | grep -v grep | awk '{print $2}') 2>/dev/null
sleep 2

echo "  Sending 20 more requests..."
for i in $(seq 1 20); do
    curl -s -0 http://localhost/ > /dev/null
done

echo "  Distribution after killing 5001:"
for PORT in 5001 5002 5003 5004; do
    CNT=$(curl -s -0 http://127.0.0.1:$PORT/info 2>/dev/null | grep -o '"counter":[0-9]*' | grep -o '[0-9]*' || echo "DOWN")
    echo "    Port $PORT: $CNT"
done

echo ""
echo "Step 3: Killing instance on port 5002 as well..."
kill $(ps aux | grep 'app.py 5002' | grep -v grep | awk '{print $2}') 2>/dev/null
sleep 2

echo "  Sending 20 more requests..."
for i in $(seq 1 20); do
    curl -s -0 http://localhost/ > /dev/null
done

echo "  Distribution after killing 5001 and 5002:"
for PORT in 5001 5002 5003 5004; do
    CNT=$(curl -s -0 http://127.0.0.1:$PORT/info 2>/dev/null | grep -o '"counter":[0-9]*' | grep -o '[0-9]*' || echo "DOWN")
    echo "    Port $PORT: $CNT"
done

echo ""
echo "Step 4: Restarting instances..."
cd "$SCRIPT_DIR/app"
source "$SCRIPT_DIR/venv/bin/activate"
python -u app.py 5001 &
python -u app.py 5002 &
sleep 2

echo "  Sending 20 more requests after recovery..."
for i in $(seq 1 20); do
    curl -s -0 http://localhost/ > /dev/null
done

echo "  Distribution after recovery:"
for PORT in 5001 5002 5003 5004; do
    CNT=$(curl -s -0 http://127.0.0.1:$PORT/info | grep -o '"counter":[0-9]*' | grep -o '[0-9]*')
    echo "    Port $PORT: $CNT"
done

echo ""
echo "====================================================="
echo "  Failover test complete."
echo "====================================================="
