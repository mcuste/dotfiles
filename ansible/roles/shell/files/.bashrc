. "$HOME/.config/shell/common.sh"

case $- in
  *i*)
    _update_cargo_target_dir
    case ";${PROMPT_COMMAND:-};" in
      *'_update_cargo_target_dir'*) ;;
      *) PROMPT_COMMAND="_update_cargo_target_dir${PROMPT_COMMAND:+; $PROMPT_COMMAND}" ;;
    esac
    ;;
esac
