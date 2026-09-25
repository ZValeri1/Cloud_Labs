#!/bin/bash

# Script to switch nginx to a specific load balancing config
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_NAME="$1"

if [ -z "$CONFIG_NAME" ]; then
    echo "Usage: $0 <config_name>"
    echo "Available configs:"
    ls "$SCRIPT_DIR/nginx-configs/" | sed 's/^/  /'
    exit 1
fi

CONFIG_FILE="$SCRIPT_DIR/nginx-configs/$CONFIG_NAME"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config not found: $CONFIG_FILE"
    exit 1
fi

# Copy config to nginx sites
sudo cp "$CONFIG_FILE" /etc/nginx/sites-available/loadbalancer
sudo ln -sf /etc/nginx/sites-available/loadbalancer /etc/nginx/sites-enabled/loadbalancer
sudo rm -f /etc/nginx/sites-enabled/default

# Test and reload
sudo nginx -t && sudo nginx -s reload
echo "Nginx loaded config: $CONFIG_NAME"
