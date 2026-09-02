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
export PATH="$HOME/.cargo/bin:$PATH"


# Share Cargo output between worktrees of the current repository.
if [[ $- == *i* ]]; then
  _update_cargo_target_dir() {
    local command_status=$?
    local common_dir

    if common_dir="$(command git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)"; then
      export CARGO_TARGET_DIR="$common_dir/cargo-target"
    else
      unset CARGO_TARGET_DIR
    fi

    return "$command_status"
  }

  _update_cargo_target_dir
  PROMPT_COMMAND="_update_cargo_target_dir${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
fi
