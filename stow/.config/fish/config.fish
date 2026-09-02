set fish_greeting # Disable greeting

# Homebrew commands must be available before initializing integrations and Herdr.
fish_add_path /opt/homebrew/bin /opt/homebrew/sbin


# Don't exec the rest of the config if not interactive
status is-interactive; or exit 0

# Set nvim as default editor
set -gx EDITOR nvim
set -gx VISUAL nvim

# Commands to run in interactive sessions can go here

# Theme
fish_config theme choose CatppuccinMocha

# Activate prompt
starship init fish | source

# Activate fzf
fzf --fish | source

# Activate zoxide
zoxide init fish | source


# Aliases
alias eza 'eza --icons auto'
alias ls eza
alias l eza
alias la 'l -a'
alias ll 'l -l'
alias lt 'l --tree'
alias lla 'l -la'

alias g git
alias v nvim
alias k kubectl
alias lg lazygit
alias vimdiff 'nvim -d'

# Path exports
fish_add_path $HOME/.local/bin
fish_add_path /opt/homebrew/opt/rustup/bin
fish_add_path $HOME/.cargo/bin
fish_add_path /opt/homebrew/opt/llvm/bin
set -gx DOTNET_ROOT /opt/homebrew/opt/dotnet@8/libexec
fish_add_path /opt/homebrew/opt/dotnet@8/bin
set -gx GOPATH $HOME/.go
fish_add_path $GOPATH/bin
set -gx PNPM_HOME $HOME/Library/pnpm
fish_add_path $PNPM_HOME $PNPM_HOME/bin
fish_add_path $HOME/.dotnet/tools
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx K9S_CONFIG_DIR $HOME/.config/k9s
fish_add_path $HOME/scripts/bash
