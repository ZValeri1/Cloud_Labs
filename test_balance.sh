#!/bin/bash

# Script to test load balancing distribution
# Sends requests and checks which backend handled each one

NUM_REQUESTS=${1:-20}
echo "=== Testing load balancing distribution ($NUM_REQUESTS requests) ==="
echo ""

# Reset counters on all instances
for PORT in 5001 5002 5003 5004; do
    curl -s -X POST http://127.0.0.1:$PORT/reset > /dev/null 2>&1
done

# Send requests through nginx
echo "Sending $NUM_REQUESTS requests to nginx (localhost:80)..."
for i in $(seq 1 $NUM_REQUESTS); do
    RESPONSE=$(curl -s http://localhost/)
    echo "  Request $i: $RESPONSE"
done

echo ""
echo "=== Per-instance counters ==="
for PORT in 5001 5002 5003 5004; do
    INFO=$(curl -s http://127.0.0.1:$PORT/info)
    COUNTER=$(echo "$INFO" | python3 -c "import sys,json; print(json.load(sys.stdin)['counter'])" 2>/dev/null || echo "N/A")
    echo "  Port $PORT: $COUNTER requests handled"
done
