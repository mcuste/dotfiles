#!/usr/bin/env bash

set -euo pipefail

# From:
# - https://github.com/jtroo/kanata/issues/1264#issuecomment-2763085239
# - https://github.com/jtroo/kanata/discussions/1537

# Function to check if a LaunchDaemon is already loaded
is_service_loaded() {
    sudo launchctl list | grep -q "$1" 2>/dev/null
}

# Function to check if a plist file exists
plist_exists() {
    [ -f "/Library/LaunchDaemons/$1" ]
}

# Copy plist files if they don't exist
echo "Setting up Kanata LaunchDaemons..."

for plist in com.example.kanata.plist com.example.karabiner-vhiddaemon.plist com.example.karabiner-vhidmanager.plist; do
    if plist_exists "$plist"; then
        echo "✓ $plist already exists in /Library/LaunchDaemons/"
    else
        echo "Copying $plist to /Library/LaunchDaemons/..."
        sudo cp "./$plist" /Library/LaunchDaemons/
    fi
done

# Setup and enable services
services=(
    "com.example.kanata"
    "com.example.karabiner-vhiddaemon"
    "com.example.karabiner-vhidmanager"
)

for service in "${services[@]}"; do
    if is_service_loaded "$service"; then
        echo "✓ $service is already loaded and running"
    else
        echo "Setting up $service..."
        sudo launchctl bootstrap system "/Library/LaunchDaemons/${service}.plist"
        sudo launchctl enable "system/${service}.plist"
        sudo launchctl start "$service"
        echo "✓ $service started successfully"
    fi
done

echo ""
echo "Kanata setup complete! All services are running."