#!/usr/bin/env bash

set -euo pipefail

# Check if SSH key exists
if [ ! -f ~/.ssh/id_ed25519 ]; then
	mkdir -p ~/.ssh
	pushd ~/.ssh
	ssh-keygen -t ed25519
	popd
	echo "New SSH key generated."
else
	echo "SSH key already exists."
fi

echo -e "\nAdd the following public key to your GitHub account:"
pubkey="$(< ~/.ssh/id_ed25519.pub)"
echo -e "\t$pubkey"
echo -e "\nPress Enter after setting up SSH key on GitHub to continue."
read
