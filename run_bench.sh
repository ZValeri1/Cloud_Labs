#!/bin/bash

# Full benchmark script - tests all algorithms with ab (Apache Benchmark)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/results"
mkdir -p "$RESULTS_DIR"

CONCURRENCY=${1:-10}
TOTAL_REQUESTS=${2:-500}

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
    echo '111' | sudo -S cp "$SCRIPT_DIR/nginx-configs/$CONFIG" /etc/nginx/sites-available/loadbalancer 2>/dev/null
    echo '111' | sudo -S nginx -s reload 2>/dev/null
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
    echo "  Time per request (mean):"
    grep "Time per request" "$RESULT_FILE" | head -1 | sed 's/^/    /'
    echo "  Failed requests (Length errors are expected due to varying counter size):"
    grep "Failed requests" "$RESULT_FILE" | sed 's/^/    /'

    # Show distribution using HTTP/1.0 to avoid keep-alive issues
    echo "  Distribution:"
    for PORT in 5001 5002 5003 5004; do
        local CNT=$(curl -s -0 http://127.0.0.1:$PORT/info | grep -o '"counter":[0-9]*' | grep -o '[0-9]*')
        echo "    Port $PORT: $CNT requests"
    done
    echo ""
}

# Test each algorithm (skip least_time - NGINX Plus only)
run_benchmark "01_round_robin.conf" "Round_Robin"
run_benchmark "02_ip_hash.conf" "IP_Hash"
run_benchmark "03_least_conn.conf" "Least_Connections"
run_benchmark "05_random.conf" "Random"
run_benchmark "06_failover.conf" "Failover"

echo "====================================================="
echo "  Benchmarks complete. Results saved to $RESULTS_DIR/"
echo "====================================================="
