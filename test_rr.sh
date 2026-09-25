#!/bin/bash

# Reset counters
for p in 5001 5002 5003 5004; do
    curl -s -X POST http://127.0.0.1:$p/reset > /dev/null
done

echo "=== Round Robin test (20 separate requests) ==="

# Send 20 separate requests, each as independent process
for i in $(seq 1 20); do
    curl -s -0 -H "Connection: close" -H "Proxy-Connection: close" http://127.0.0.1:80/ > /dev/null
done

echo "=== Distribution ==="
for p in 5001 5002 5003 5004; do
    CNT=$(curl -s http://127.0.0.1:$p/info | grep -o '"counter":[0-9]*' | grep -o '[0-9]*')
    echo "Port $p: $CNT requests"
done
