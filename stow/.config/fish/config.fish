# Set nvim as default editor
set -gx EDITOR nvim
set -gx VISUAL nvim
set fish_greeting # Disable greeting

# Don't exec the rest of the config if not interactive
status is-interactive; or exit 0

# Commands to run in interactive sessions can go here

# Theme
fish_config theme choose "CatppuccinMocha"

# Activate prompt
starship init fish | source

# Activate fzf
fzf --fish | source

# Activate zoxide
zoxide init fish | source

# Activate mise
mise activate fish | source

# Aliases
alias eza 'eza --icons auto --git'
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
fish_add_path /opt/homebrew/opt/rustup/bin
fish_add_path /opt/homebrew/opt/llvm/bin

# Go configuration
set -gx GOPATH $HOME/.go
fish_add_path $GOPATH/bin
