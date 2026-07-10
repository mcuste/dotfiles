#!/usr/bin/env bash

set -euo pipefail

# From:
# - https://github.com/jtroo/kanata/issues/1264#issuecomment-2763085239
# - https://github.com/jtroo/kanata/discussions/1537

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
launch_daemons_dir="/Library/LaunchDaemons"
kanata_log_dir="/Library/Logs/Kanata"
kanata_bin="/opt/homebrew/bin/kanata"
kanata_config="$HOME/.config/kanata/config.kbd"

if [ ! -x "$kanata_bin" ]; then
  echo "Kanata is not installed at $kanata_bin." >&2
  echo "Install it first with: brew install kanata" >&2
  exit 1
fi

if [ ! -f "$kanata_config" ]; then
  echo "Kanata config not found at $kanata_config." >&2
  exit 1
fi

# Function to check if a LaunchDaemon is already loaded
is_service_loaded() {
  sudo launchctl print "system/$1" >/dev/null 2>&1
}

# Function to check if a plist file exists
plist_exists() {
  [ -f "$launch_daemons_dir/$1" ]
}

# Copy plist files if they don't exist
echo "Setting up Kanata LaunchDaemons..."

sudo mkdir -p "$kanata_log_dir"

for plist in com.example.kanata.plist com.example.karabiner-vhiddaemon.plist com.example.karabiner-vhidmanager.plist; do
  if plist_exists "$plist"; then
    echo "✓ $plist already exists in $launch_daemons_dir/"
  else
    echo "Copying $plist to $launch_daemons_dir/..."
    sudo install -o root -g wheel -m 644 "$script_dir/$plist" "$launch_daemons_dir/$plist"
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
    sudo launchctl bootstrap system "$launch_daemons_dir/${service}.plist"
    sudo launchctl enable "system/${service}"
    sudo launchctl kickstart -k "system/${service}"
    echo "✓ $service started successfully"
  fi
done

echo ""
echo "Kanata setup complete! All services are running."
