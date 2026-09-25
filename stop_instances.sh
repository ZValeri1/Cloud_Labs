#!/bin/bash

echo "Stopping all Flask instances..."
pkill -f "python app.py" 2>/dev/null
echo "Done."

echo "Stopping nginx..."
sudo nginx -s stop 2>/dev/null
echo "Done."
