#!/bin/bash
set -euo pipefail

if [[ "$(uname -s)" != Darwin || "$(uname -m)" != arm64 || "$(id -un)" != admin ]]; then
    echo 'Hermes installation requires the admin account inside the Apple Silicon guest.' >&2
    exit 1
fi

installer="$(mktemp)"
trap 'rm -f "$installer"' EXIT
curl -fsSL https://hermes-agent.nousresearch.com/install.sh -o "$installer"
export PATH="$HOME/.local/bin:/opt/homebrew/bin:$PATH"
/bin/bash "$installer" --non-interactive </dev/null
"$HOME/.local/bin/hermes" --version
