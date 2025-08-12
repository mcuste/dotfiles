#!/usr/bin/env dash

# Install homebrew
/bin/dash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Run after homebrew install to set path properly
sudo launchctl config user path "$(brew --prefix)/bin:${PATH}
