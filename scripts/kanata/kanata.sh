#!/usr/bin/env bash

# From:
# - https://github.com/jtroo/kanata/issues/1264#issuecomment-2763085239
# - https://github.com/jtroo/kanata/discussions/1537

sudo cp ./com.* /Library/LaunchDaemons/

sudo launchctl bootstrap system /Library/LaunchDaemons/com.example.kanata.plist
sudo launchctl enable system/com.example.kanata.plist

sudo launchctl bootstrap system /Library/LaunchDaemons/com.example.karabiner-vhiddaemon.plist
sudo launchctl enable system/com.example.karabiner-vhiddaemon.plist

sudo launchctl bootstrap system /Library/LaunchDaemons/com.example.karabiner-vhidmanager.plist
sudo launchctl enable system/com.example.karabiner-vhidmanager.plist

sudo launchctl start com.example.kanata
sudo launchctl start com.example.karabiner-vhiddaemon
sudo launchctl start com.example.karabiner-vhidmanager
