# Homebrew commands must be available to shells that launch Herdr plugins.
case ":$PATH:" in
  *:/opt/homebrew/bin:*) ;;
  *) PATH="/opt/homebrew/bin:$PATH" ;;
esac
case ":$PATH:" in
  *:/opt/homebrew/sbin:*) ;;
  *) PATH="/opt/homebrew/sbin:$PATH" ;;
esac
export PATH

# Keep Graphite stack branches in separate Herdr worktrees.
gt() {
  local script="${XDG_CONFIG_HOME:-$HOME/.config}/graphite-worktrees/gt-worktree.sh"
  local result_file
  local result_path
  local exit_status

  if [[ ! -f "$script" ]]; then
    command gt "$@"
    return $?
  fi

  result_file=$(mktemp) || return 1
  GT_WORKTREE_RESULT_FILE="$result_file" command bash "$script" "$@"
  exit_status=$?
  if [[ -s "$result_file" ]]; then
    result_path=$(<"$result_file")
    if [[ -d "$result_path" ]]; then
      builtin cd "$result_path"
    fi
  fi
  rm -f "$result_file"
  return "$exit_status"
}
