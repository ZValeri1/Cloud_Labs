#!/bin/bash

# Initial nginx setup
echo "Setting up nginx..."

# Make sure sites-available and sites-enabled exist
sudo mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled

# Load default config (round robin)
sudo cp ~/lab-loadbalancing/nginx-configs/01_round_robin.conf /etc/nginx/sites-available/loadbalancer
sudo ln -sf /etc/nginx/sites-available/loadbalancer /etc/nginx/sites-enabled/loadbalancer
sudo rm -f /etc/nginx/sites-enabled/default

# Check if nginx.conf includes sites-enabled
if ! grep -q "sites-enabled" /etc/nginx/nginx.conf; then
    echo "Adding sites-enabled include to nginx.conf"
    sudo sed -i '/http {/a \    include /etc/nginx/sites-enabled/*;' /etc/nginx/nginx.conf
fi

# Test and start
sudo nginx -t && echo "Nginx config OK" || echo "Nginx config FAILED"
