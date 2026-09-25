#!/bin/bash
# Fix nginx log to show upstream address

echo '111' | sudo -S bash -c '
# Add upstream log format
if ! grep -q "upstream_log" /etc/nginx/nginx.conf; then
    sed -i "/http {/a\\    log_format upstream_log \"\\$remote_addr - \\$upstream_addr\";" /etc/nginx/nginx.conf
    sed -i "s|access_log.*;|access_log /var/log/nginx/access.log upstream_log;|" /etc/nginx/nginx.conf
fi

# Reload nginx
nginx -t 2>&1
nginx -s reload 2>&1
echo "Done"
'
