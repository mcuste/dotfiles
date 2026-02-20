set fish_greeting # Disable greeting

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

# Activate mise
mise activate fish | source

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
fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin
fish_add_path /opt/homebrew/opt/rustup/bin
fish_add_path /opt/homebrew/opt/llvm/bin
set -gx GOROOT $HOME/.go
set -gx GOPATH $HOME/.go
fish_add_path $GOPATH/bin
fish_add_path $HOME/.dotnet/tools
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx K9S_CONFIG_DIR $HOME/.config/k9s
fish_add_path $HOME/scripts/bash
