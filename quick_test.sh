#!/bin/bash

echo "=== Resetting counters ==="
for p in 5001 5002 5003 5004; do
    curl -s -X POST http://127.0.0.1:$p/reset > /dev/null
done

echo "=== Round Robin test (8 requests) ==="
for i in 1 2 3 4 5 6 7 8; do
    echo -n "Req $i -> "
    curl -s http://localhost/
    echo ""
done

echo ""
echo "=== Distribution ==="
for p in 5001 5002 5003 5004; do
    echo -n "Port $p: "
    curl -s http://127.0.0.1:$p/info
    echo ""
done
