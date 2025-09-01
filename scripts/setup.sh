#!/usr/bin/env bash

set -euo pipefail

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

# Helper functions to check if packages are installed
is_brew_package_installed() {
  brew list --formula "$1" &>/dev/null
}

is_brew_cask_installed() {
  brew list --cask "$1" &>/dev/null
}

install_brew_package() {
  local package="$1"
  if is_brew_package_installed "$package"; then
    echo "✓ $package is already installed"
  else
    echo "Installing $package..."
    brew install "$package"
  fi
}

install_brew_cask() {
  local cask="$1"
  if is_brew_cask_installed "$cask"; then
    echo "✓ $cask is already installed"
  else
    echo "Installing $cask..."
    brew install --cask "$cask"
  fi
}

install_brew_tap_package() {
  local tap="$1"
  local package="$2"
  if is_brew_package_installed "$package"; then
    echo "✓ $package is already installed"
  else
    echo "Installing $package from tap $tap..."
    brew install "$tap/$package"
  fi
}

# Browsers
install_brew_cask "brave-browser"

# GUI Tools
install_brew_cask "karabiner-elements"
install_brew_cask "raycast"
install_brew_cask "ghostty"
install_brew_cask "mos"
install_brew_cask "todoist-app" # TODO: Do we really use this?
install_brew_cask "protonvpn"
install_brew_cask "proton-pass" # TODO: Also this?

# Editors
install_brew_cask "font-jetbrains-mono-nerd-font"
install_brew_package "neovim"
install_brew_cask "obsidian"
install_brew_cask "visual-studio-code"

# Tools
install_brew_package "kanata"
install_brew_package "fish"
install_brew_package "tmux"
install_brew_package "starship"
install_brew_package "lazygit"
install_brew_package "gh"
install_brew_package "git-lfs"
install_brew_package "git-delta"
install_brew_package "gnupg"
install_brew_package "lsof"
install_brew_package "unzip"
install_brew_package "wget"
install_brew_package "rsync"
install_brew_package "eza"
install_brew_package "fzf"
install_brew_package "fd"
install_brew_package "ripgrep"
install_brew_package "zoxide"
install_brew_package "bat"
install_brew_package "ncdu"
install_brew_package "jq"
install_brew_package "hyperfine"
install_brew_package "entr"
install_brew_package "just"
install_brew_package "make"
install_brew_package "fastfetch"
install_brew_package "htop"
install_brew_package "bottom"
install_brew_package "stow"
install_brew_package "tokei"
install_brew_package "yazi"
install_brew_package "imagemagick" # for png on nvim
install_brew_package "ghostscript" # for pdf on nvim
install_brew_package "tectonic"    # for latex on nvim
install_brew_package "gum"         # for nice cli with bash

##### DEV

# markdown
install_brew_package "marksman"

# bash
install_brew_package "bash-language-server"
install_brew_package "shellcheck"
install_brew_package "shfmt"

# cmake
install_brew_package "cmake-language-server"

# docker and k8s
install_brew_package "kubectl"
install_brew_package "k9s"
install_brew_package "k3d"
install_brew_package "orbstack"
install_brew_package "dockerfile-language-server"
install_brew_package "helm"
install_brew_package "helm-ls"
install_brew_package "yaml-language-server"
# terraform with mise
install_brew_package "terraform-ls"

# lua
install_brew_package "lua"
install_brew_package "luv"
install_brew_package "lpeg"
install_brew_package "luajit"
install_brew_package "luarocks"
install_brew_package "lua-language-server"

# go
install_brew_package "go"
install_brew_package "gopls"
install_brew_package "delve"
install_brew_package "goimports"
install_brew_package "golangci-lint"
install_brew_package "golangci-lint-langserver"

# rust
install_brew_package "rustup"
install_brew_package "llvm"
install_brew_package "protobuf"
install_brew_package "cargo-nextest"
# tombi for tomls
# npm install -g tombi

# python
install_brew_package "mise"
install_brew_package "pyright"

# js/ts/web
install_brew_package "vscode-langservers-extracted"
install_brew_package "superhtml"
install_brew_package "tailwindcss-language-server"
# svelte-language-server - install with npm
# npm i -g svelte-language-server
# npm i -g typescript-svelte-plugin
install_brew_package "typescript"
install_brew_package "typescript-language-server"
install_brew_package "biome"

# treesitter
install_brew_package "tree-sitter"
install_brew_package "tree-sitter-cli"

# Cloud
install_brew_cask "gcloud-cli"

# TODO
# gcloud components install gke-gcloud-auth-plugin

# Game Dev
install_brew_cask "godot"
install_brew_cask "gdtoolkit"

# Media
install_brew_cask "slack"
install_brew_cask "spotify"
install_brew_cask "calibre"
install_brew_cask "anki"
install_brew_cask "steam"

# AI
install_brew_package "gemini-cli"
install_brew_cask "claude"
install_brew_cask "claude-code"

# Packages from taps
install_brew_tap_package "flyteorg/homebrew-tap" "flytectl"
install_brew_tap_package "withgraphite/tap" "graphite"

# Tmux Plugin Manager Setup
if [ -d "$HOME/.config/tmux/plugins/tpm" ]; then
  echo "✓ Tmux Plugin Manager (TPM) is already installed"
else
  echo "Installing Tmux Plugin Manager (TPM)..."
  mkdir -p "$HOME/.config/tmux/plugins"
  git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
  echo "✓ TPM installed successfully"
fi

# Setup Kanata keyboard remapper
echo ""
echo "Setting up Kanata keyboard remapper..."
if [ -f "./scripts/kanata/kanata.sh" ]; then
  bash ./scripts/kanata/kanata.sh
  echo ""
else
  echo "⚠ Kanata setup script not found at ./scripts/kanata/kanata.sh"
fi

# Setup SSH Key
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
pubkey="$(<~/.ssh/id_ed25519.pub)"
echo -e "\t$pubkey"
echo -e "\nPress Enter after setting up SSH key on GitHub to continue."
read
