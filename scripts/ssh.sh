#!/usr/bin/env bash

mkdir ~/.ssh && pushd ~/.ssh && ssh-keygen -t ed25519 && popd
echo "Add the following public key to your GitHub account:"
cat ~/.ssh/id_ed25519.pub
read -p "Press any key after setting up SSH key on GitHub to continue"
