# Laboratory: Load Balancing and Fault Tolerance with Nginx

## Structure

```
lab-loadbalancing/
├── app/
│   └── app.py              # Flask app with counter
├── nginx-configs/
│   ├── 01_round_robin.conf # Round Robin (default)
│   ├── 02_ip_hash.conf     # IP Hash (sticky sessions)
│   ├── 03_least_conn.conf  # Least Connections
│   ├── 04_least_time.conf  # Least Time (NGINX Plus only)
│   ├── 05_random.conf      # Random
│   └── 06_failover.conf    # Failover with max_fails/fail_timeout
├── results/                # Benchmark results
├── start_instances.sh      # Start 4 Flask instances (ports 5001-5004)
├── stop_instances.sh       # Stop all instances + nginx
├── switch_nginx.sh         # Switch nginx to a specific config
├── test_balance.sh         # Test request distribution
├── run_bench.sh            # Run ab benchmarks for all algorithms
├── test_failover.sh        # Test failover behavior
├── setup_nginx.sh          # Initial nginx setup
└── README.md
```

## Quick Start

```bash
cd ~/lab-loadbalancing

# 1. Setup nginx
bash setup_nginx.sh

# 2. Start Flask instances (ports 5001-5004)
bash start_instances.sh &

# 3. Start nginx with default config (round robin)
sudo nginx

# 4. Verify
curl http://localhost/
curl http://localhost/
curl http://localhost/
```

## Testing

### Distribution test
```bash
bash test_balance.sh 20
```

### Full benchmark (all algorithms)
```bash
bash run_bench.sh 10 1000      # concurrency=10, requests=1000
bash run_bench.sh 50 5000      # higher load
```

### Failover test
```bash
bash test_failover.sh
```

### Switch algorithm manually
```bash
bash switch_nginx.sh 02_ip_hash.conf
bash switch_nginx.sh 03_least_conn.conf
bash switch_nginx.sh 05_random.conf
bash switch_nginx.sh 06_failover.conf
```

## Algorithms

| Algorithm | Description | Use case |
|---|---|---|
| Round Robin | Sequential distribution | Stateless services, even load |
| IP Hash | Same IP → same backend | Session persistence |
| Least Conn | Fewest active connections | Variable request times |
| Least Time | Lowest response time | NGINX Plus only |
| Random | Random selection | Testing, simple setups |
| Failover | max_fails + fail_timeout | Fault tolerance |
