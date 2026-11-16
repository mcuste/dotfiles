. "$HOME/.config/shell/common.sh"
[[ -o interactive ]] || return

autoload -U edit-command-line
zle -N edit-command-line
bindkey '^[e' edit-command-line

if (( $+commands[brew] )); then
  _brew_prefix="${commands[brew]:h:h}"
  fpath=("$_brew_prefix/share/zsh/site-functions" "$_brew_prefix/share/zsh-completions" $fpath)
  typeset -U fpath
fi
autoload -Uz compinit
compinit

if [[ -n ${_brew_prefix:-} ]]; then
  if [[ -f "$_brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$_brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
    bindkey '^[[C' autosuggest-accept
  fi
  if [[ -f "$_brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$_brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  fi
  unset _brew_prefix
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_FIND_NO_DUPS SHARE_HISTORY
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT

(( $+commands[starship] )) && eval "$(starship init zsh)"
(( $+commands[fzf] )) && eval "$(fzf --zsh)"
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _update_cargo_target_dir
_update_cargo_target_dir
