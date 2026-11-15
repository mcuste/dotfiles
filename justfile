# Display help information
default:
  @just --list

stow:
  stow --dir "{{justfile_directory()}}" --target "$HOME" stow
  if [ "$(uname -s)" = Darwin ]; then "{{justfile_directory()}}/stow/.local/bin/sync-handy-settings"; fi
