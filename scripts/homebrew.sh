#!/usr/bin/env bash

# Check if Homebrew is installed
if ! command -v brew >/dev/null 2>&1; then
	echo "Homebrew not found. Installing..."
	bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
	echo "Homebrew is already installed."
fi

# Set PATH for Homebrew if not already set
BREW_PATH="$(brew --prefix)/bin"
if [[ ":$PATH:" != *":$BREW_PATH:"* ]]; then
	echo "Setting Homebrew path with launchctl."
	sudo launchctl config user path "$BREW_PATH:${PATH}"
else
	echo "Homebrew path already in PATH."
fi
