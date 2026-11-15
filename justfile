# Display help information
default:
  @just --list

stow:
  stow --dir "{{justfile_directory()}}" --target "$HOME" stow
  if [ "$(uname -s)" = Darwin ]; then "{{justfile_directory()}}/stow/.local/bin/sync-handy-settings"; fi
  bash "{{justfile_directory()}}/stow/.config/hunk/install-plugins.sh"
  bash "{{justfile_directory()}}/stow/.config/herdr/install-plugins.sh"
  if [ "$(uname -s)" = Darwin ]; then just --justfile "{{justfile_directory()}}/justfile" shortcuts; fi

shortcuts:
  "{{justfile_directory()}}/stow/.local/bin/sync-shortcuts" "{{justfile_directory()}}/stow/.config/shortcuts"
