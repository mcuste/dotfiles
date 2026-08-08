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
