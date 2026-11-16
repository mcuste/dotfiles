#!/bin/bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash bootstrap.sh --profile personal|work --category headless|desktop [options] [-- ANSIBLE_ARGS...]
  --image              Use image safety checks and disable interactive setup
  --interactive       Include tools that need attended setup (desktop only)
  --host NAME         Inventory host name for host_vars (default: localhost)
  --group NAME        Add a specialization group; repeat as needed
  --checkout PATH      Persistent checkout location (default: ~/dotfiles)
  --source PATH        Use an existing checkout, including a Packer upload
  --ref REF            Git branch or tag for a new clone (default: main)
  --help               Show this help

Run as the intended user, not root. Homebrew may request sudo during setup.
Existing checkouts are not updated or deleted. Keep the checkout after provisioning.
EOF
}
fail() {
  printf 'bootstrap: %s\n' "$*" >&2
  exit 1
}
profile=''
category=''
image=false
interactive=false
checkout="$HOME/dotfiles"
source_dir=''
ref=main
host=localhost
extra_groups=()

while [ "$#" -gt 0 ]; do
  case "$1" in
  --help | -h)
    usage
    exit 0
    ;;
  --image)
    image=true
    shift
    ;;
  --interactive)
    interactive=true
    shift
    ;;
  --profile | --category | --host | --group | --checkout | --source | --ref)
    [ "$#" -ge 2 ] && [ -n "$2" ] || fail "$1 requires a value"
    case "$1" in
    --profile) profile=$2 ;;
    --category) category=$2 ;;
    --host) host=$2 ;;
    --group) extra_groups+=("$2") ;;
    --checkout) checkout=$2 ;;
    --source) source_dir=$2 ;;
    --ref) ref=$2 ;;
    esac
    shift 2
    ;;
  --)
    shift
    break
    ;;
  *) fail "Unknown option: $1" ;;
  esac
done

case "$profile" in
personal | work) ;;
*) fail 'Select --profile personal or work' ;;
esac

case "$category" in
headless | desktop) ;;
*) fail 'Select --category headless or desktop' ;;
esac

[[ "$host" =~ ^[a-zA-Z0-9][a-zA-Z0-9_.-]*$ ]] || fail 'Invalid inventory host name'
for group in "${extra_groups[@]+"${extra_groups[@]}"}"; do
  [[ "$group" =~ ^[a-z][a-z0-9_]*$ ]] || fail "Invalid group: $group"
  case "$group" in
  all | ungrouped | personal | work | headless | desktop | interactive | image_builds)
    fail "Use the dedicated option for reserved group: $group"
    ;;
  esac
done

if "$interactive"; then
  [ "$category" = desktop ] || fail '--interactive requires --category desktop'
  ! "$image" || fail 'Images cannot include interactive provisioning'
fi
[ "$(id -u)" != 0 ] || fail 'Run as the intended non-root user'
platform=$(uname -s)
case "$platform:$(uname -m)" in
Darwin:arm64)
  brew_bin=/opt/homebrew/bin/brew
  ;;
Darwin:x86_64)
  brew_bin=/usr/local/bin/brew
  ;;
Linux:*)
  brew_bin=/home/linuxbrew/.linuxbrew/bin/brew
  ;;
*)
  fail "Unsupported platform: $platform"
  ;;
esac
command -v curl >/dev/null || fail 'Install curl first'

inventory=''
cleanup() {
  if [ -n "$inventory" ]; then
    rm -f -- "$inventory"
  fi
}
trap cleanup EXIT
if [ ! -x "$brew_bin" ]; then
  installer=$(curl --fail --silent --show-error --location https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)
  /bin/bash -c "$installer"
fi
[ -x "$brew_bin" ] || fail "Homebrew was not installed at $brew_bin"
PATH="$(dirname "$brew_bin"):$PATH"
export PATH
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_UPGRADE=1
"$brew_bin" install uv git
uv_bin="$(dirname "$brew_bin")/uv"
git_bin="$(dirname "$brew_bin")/git"

if [ -n "$source_dir" ]; then
  [ -d "$source_dir" ] || fail "Source directory does not exist: $source_dir"
  root=$(cd "$source_dir" && pwd -P)
else
  if [ ! -e "$checkout" ]; then
    "$git_bin" clone --branch "$ref" --single-branch https://github.com/mcuste/dotfiles.git "$checkout"
  fi
  root=$(cd "$checkout" && pwd -P)
fi
[ -f "$root/uv.lock" ] && [ -f "$root/ansible/playbooks/configure.yml" ] || fail "Not a dotfiles checkout: $root"
"$uv_bin" sync --project "$root" --locked --managed-python
export ANSIBLE_CONFIG="$root/ansible/ansible.cfg"
cd "$root/ansible"
"$uv_bin" run --project "$root" ansible-galaxy collection install -r requirements.yml -p .collections
inventory=$(mktemp "$root/ansible/inventory/bootstrap.XXXXXX")
mv -- "$inventory" "$inventory.json"
inventory="$inventory.json"
export ANSIBLE_INVENTORY_UNPARSED_FAILED=true
"$uv_bin" run --project "$root" python - "$inventory" "$profile" "$image" "$category" "$interactive" "$host" "${extra_groups[@]+"${extra_groups[@]}"}" <<'PY'
import json
import sys
path, profile, image, category, interactive, host, *extra_groups = sys.argv[1:]
groups = {profile: {}, category: {}, **dict.fromkeys(extra_groups, {})}
if interactive == "true":
    groups["interactive"] = {}
if image == "true":
    groups["image_builds"] = {}
for group in groups:
    groups[group] = {"hosts": {host: {}}}
inventory = {"all": {"children": groups, "vars": {
    "ansible_connection": "local",
    "ansible_python_interpreter": "{{ ansible_playbook_python }}",
}}}
with open(path, "w") as file:
    json.dump(inventory, file)
PY
settings=$(
  "$uv_bin" run --project "$root" python - "$profile" "$image" "$root" <<'PY'
import json
import sys
profile, image, root = sys.argv[1:]
print(json.dumps({"dotfiles_profile": profile,
                  "dotfiles_image_build": image == "true", "dotfiles_interactive": False,
                  "dotfiles_checkout": root}))
PY
)
playbook=playbooks/configure.yml
if "$image"; then
  playbook=playbooks/image.yml
fi
"$uv_bin" run --project "$root" ansible-playbook "$playbook" -i "$inventory" "$@" --extra-vars "$settings"
if "$interactive"; then
  printf '%s\n' 'After initial app setup, run ~/.local/bin/sync-handy-settings and ~/.local/bin/sync-shortcuts in a terminal.'
fi
