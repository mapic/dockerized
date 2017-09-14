#!/bin/bash
# 
# This script is for quick & easy install via:
#   'curl -sSL https://get.mapic.io/ | sh'
# or:
#   'wget -qO- https://get.mapic.io/ | sh'
#
# todo: 
# - windows compatibility

# clone mapic repository
echo "Downloading Mapic..."
git clone https://github.com/mapic/mapic.git >/dev/null 2>&1

# install mapic-cli
echo "Installing Mapic..."
cd mapic/cli 
sudo bash mapic-cli.sh
