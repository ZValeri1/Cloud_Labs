#!/bin/bash

# Full benchmark script - tests all algorithms with ab (Apache Benchmark)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/results"
mkdir -p "$RESULTS_DIR"

CONCURRENCY=${1:-10}
TOTAL_REQUESTS=${2:-1000}

echo "====================================================="
echo "  Load Balancing Benchmark"
echo "  Concurrency: $CONCURRENCY, Requests: $TOTAL_REQUESTS"
echo "====================================================="
echo ""

# Function to run benchmark for a given config
run_benchmark() {
    local CONFIG="$1"
    local LABEL="$2"
    
    echo "--- $LABEL ---"
    
    # Switch nginx config
    bash "$SCRIPT_DIR/switch_nginx.sh" "$CONFIG" > /dev/null 2>&1
    sleep 1
    
    # Reset all counters
    for PORT in 5001 5002 5003 5004; do
        curl -s -X POST http://127.0.0.1:$PORT/reset > /dev/null 2>&1
    done
    sleep 1
    
    # Run ab benchmark
    local RESULT_FILE="$RESULTS_DIR/${LABEL// /_}_c${CONCURRENCY}_n${TOTAL_REQUESTS}.txt"
    ab -c "$CONCURRENCY" -n "$TOTAL_REQUESTS" http://localhost/ > "$RESULT_FILE" 2>&1
    
    # Show key metrics
    echo "  Requests per second:"
    grep "Requests per second" "$RESULT_FILE" | sed 's/^/    /'
    echo "  Time per request:"
    grep "Time per request" "$RESULT_FILE" | head -2 | sed 's/^/    /'
    echo "  Failed requests:"
    grep "Failed requests" "$RESULT_FILE" | sed 's/^/    /'
    
    # Show distribution
    echo "  Distribution:"
    for PORT in 5001 5002 5003 5004; do
        local CNT=$(curl -s http://127.0.0.1:$PORT/info | python3 -c "import sys,json; print(json.load(sys.stdin)['counter'])" 2>/dev/null || echo "N/A")
        echo "    Port $PORT: $CNT"
    done
    echo ""
}

# Test each algorithm
run_benchmark "01_round_robin.conf" "Round Robin"
run_benchmark "02_ip_hash.conf" "IP Hash"
run_benchmark "03_least_conn.conf" "Least Connections"
run_benchmark "05_random.conf" "Random"

echo "====================================================="
echo "  Benchmarks complete. Results saved to $RESULTS_DIR/"
echo "====================================================="
