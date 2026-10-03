# Display help information
default:
  @just --list

stow:
  stow --dir "{{justfile_directory()}}" --target "$HOME" stow
