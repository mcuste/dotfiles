# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a macOS dotfiles repository managed with GNU Stow for symlinking configuration files. The repository contains configuration for various development tools, terminal emulators, and productivity applications.

## Key Commands

### Dotfiles Management
- `just stow` - Apply all dotfile configurations via GNU Stow (symlinks from `stow/` to home directory)
- `stow stow` - Direct alternative to apply symlinks

### Setup Scripts
- `./scripts/homebrew.sh` - Install Homebrew package manager
- `./scripts/setup.sh` - Install all Homebrew packages and applications (modified frequently, check git status)
- `./scripts/kanata/kanata.sh` - Setup Kanata keyboard remapper with system services
- `./scripts/ssh.sh` - SSH key setup

## Architecture & Structure

### Configuration Management
The repository uses GNU Stow for managing dotfiles. All configurations are stored in `stow/.config/` and symlinked to `~/.config/` when `just stow` is run.

### Key Configurations

**Terminal & Shell:**
- Fish shell (`stow/.config/fish/config.fish`) - Default shell at `/opt/homebrew/bin/fish`
- Tmux (`stow/.config/tmux/tmux.conf`) - Terminal multiplexer with Option+A prefix
- WezTerm (`stow/.config/wezterm/wezterm.lua`) - Terminal emulator (newly added, empty config)
- Alacritty (`stow/.config/alacritty/`) - Alternative terminal emulator

**Development Tools:**
- Neovim (`stow/.config/nvim/`) - Primary editor with extensive plugin configuration
- Git (`stow/.config/git/`) - Version control configuration
- Mise (`stow/.config/mise/config.toml`) - Runtime version manager
- Lazygit (`stow/.config/lazygit/`) - Terminal UI for git

**Window Management:**
- AeroSpace (`stow/.config/aerospace/aerospace.toml`) - Tiling window manager
- Kanata (`stow/.config/kanata/config.kbd`) - Keyboard remapper with home row mods

**Other Tools:**
- K9s (`stow/.config/k9s/`) - Kubernetes terminal UI
- Yazi (`stow/.config/yazi/`) - Terminal file manager
- VS Code (`stow/.config/Code/`) - GUI editor

### Active Development Areas
Based on recent commits and git status:
- AeroSpace window manager configuration is being actively modified
- WezTerm terminal configuration is newly added
- Setup script frequently updated with new tools

## Important Notes

- System uses Homebrew for package management on macOS
- Fish shell is the default shell, not bash/zsh
- Kanata setup requires system-level daemon configuration via LaunchDaemons
- Many configurations use Catppuccin Mocha theme for consistency