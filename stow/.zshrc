# Only run interactive configurations if shell is interactive
if [[ $- == *i* ]]; then

# Set nvim as default editor
export EDITOR="nvim"
export VISUAL="nvim"

# Make Alt+E open the command line in the editor (like fish)
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^[e' edit-command-line

# Install zsh plugins for fish-like experience
# Note: You'll need to install these with Homebrew if not already installed:
# brew install zsh-autosuggestions zsh-syntax-highlighting zsh-completions

# Load Homebrew's zsh completions
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  FPATH="$(brew --prefix)/share/zsh-completions:${FPATH}"
fi

# Enable completions
autoload -Uz compinit && compinit

# Load autosuggestions (fish-like)
if [ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  # Set suggestion color to match fish's default
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
  # Accept suggestion with right arrow key (like fish)
  bindkey '→' autosuggest-accept
  bindkey '^[[C' autosuggest-accept
fi

# Load syntax highlighting (fish-like)
if [ -f "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# Enhanced completion settings (more fish-like)
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' group-name '' 
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'

# History settings for better experience
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY

# Directory navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

fi # End of interactive shell check

# These should work in both interactive and non-interactive shells

# Activate prompt
eval "$(starship init zsh)"

# Activate fzf
eval "$(fzf --zsh)"

# Activate zoxide
eval "$(zoxide init zsh)"

# Activate mise
eval "$(mise activate zsh)"

# Aliases (from fish config)
alias eza='eza --icons auto --git'
alias ls='eza'
alias l='eza'
alias la='l -a'
alias ll='l -l'
alias lt='l --tree'
alias lla='l -la'

alias g='git'
alias v='nvim'
alias k='kubectl'
alias lg='lazygit'
alias vimdiff='nvim -d'

# Path setup
export PATH="/opt/homebrew/opt/rustup/bin:$PATH"
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

# Custom paths
export PATH="$HOME/.local/bin:$PATH"
export GOROOT="$HOME/.go"
export GOPATH="$HOME/.go"
export PATH="$GOPATH/bin:$PATH"
export PATH="$HOME/.dotnet/tools:$PATH"
export XDG_CONFIG_HOME="$HOME/.config"
export K9S_CONFIG_DIR="$HOME/.config/k9s"
export PATH="$HOME/scripts/bash:$PATH"

