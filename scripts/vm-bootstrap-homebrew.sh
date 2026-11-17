#!/bin/bash
set -euo pipefail

if [[ "$(uname -s)" != Darwin || "$(uname -m)" != arm64 || "$(id -un)" != admin ]]; then
    echo 'Homebrew bootstrap requires the admin account inside the Apple Silicon guest.' >&2
    exit 1
fi

if [[ ! -x /opt/homebrew/bin/brew ]]; then
    installer="$(mktemp)"
    trap 'rm -f "$installer"' EXIT
    curl --fail --silent --show-error --location \
        https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$installer"
    NONINTERACTIVE=1 /bin/bash "$installer"
fi

/opt/homebrew/bin/brew --version
