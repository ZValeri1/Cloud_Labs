#!/bin/bash

cd ~/lab-loadbalancing/app
source ../venv/bin/activate

# Start all instances using setsid to fully detach
setsid python app.py 5001 > /tmp/flask5001.log 2>&1 &
setsid python app.py 5002 > /tmp/flask5002.log 2>&1 &
setsid python app.py 5003 > /tmp/flask5003.log 2>&1 &
setsid python app.py 5004 > /tmp/flask5004.log 2>&1 &

sleep 2
echo "Started Flask instances:"
ps aux | grep 'app.py' | grep -v grep
