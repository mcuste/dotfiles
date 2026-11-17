#!/bin/bash
set -euo pipefail

if [[ "$(uname -s)" != Darwin || "$(uname -m)" != arm64 || "$(id -un)" != admin ]]; then
    echo 'Dotfiles provisioning requires the admin account inside the Apple Silicon guest.' >&2
    exit 1
fi

: "${DOTFILES_PROFILE:?Missing dotfiles profile}"
: "${DOTFILES_CATEGORY:?Missing dotfiles category}"
: "${DOTFILES_REF:?Missing dotfiles ref}"

export NONINTERACTIVE=1
export CI=1
export GIT_TERMINAL_PROMPT=0
bootstrap="$(mktemp)"
trap 'rm -f "$bootstrap"' EXIT
curl --fail --silent --show-error --location \
    "https://raw.githubusercontent.com/mcuste/dotfiles/${DOTFILES_REF}/bootstrap.sh" -o "$bootstrap"
/bin/bash "$bootstrap" \
    --profile "$DOTFILES_PROFILE" \
    --category "$DOTFILES_CATEGORY" \
    --ref "$DOTFILES_REF" \
    --checkout "$HOME/dotfiles" \
    --image </dev/null
