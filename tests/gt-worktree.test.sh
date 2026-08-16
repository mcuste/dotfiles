#!/usr/bin/env bash

set -euo pipefail

root=$(mktemp -d "$PWD/.gt-worktree-test.XXXXXX")
trap 'rm -rf "$root"' EXIT
repo="$root/repo"
fake_bin="$root/bin"
state="$root/branch"
result_file="$root/result"
log="$root/log"
wrapper="$PWD/stow/.config/graphite-worktrees/gt-worktree.sh"
mkdir -p "$repo/.git" "$fake_bin" "$root/home"
printf '%s\n' parent >"$state"

cat >"$fake_bin/git" <<'GIT'
#!/usr/bin/env bash
set -euo pipefail

case ${1:-} in
  -C)
    shift 2
    ;;
esac

case "$1 ${2:-}" in
  'rev-parse --is-inside-work-tree')
    printf 'true\n'
    ;;
  'rev-parse --show-toplevel')
    printf '%s\n' "$TEST_REPO"
    ;;
  'rev-parse --git-dir'|'rev-parse --git-common-dir')
    printf '.git\n'
    ;;
  'branch --show-current')
    cat "$TEST_STATE"
    ;;
  'checkout parent')
    printf 'parent\n' >"$TEST_STATE"
    ;;
  'checkout --detach')
    printf 'git checkout --detach\n' >>"$TEST_LOG"
    ;;
  'worktree list')
    if [[ ${TEST_SOURCE_PARENT:-} == true ]]; then
      printf 'worktree %s\nHEAD deadbeef\nbranch refs/heads/parent\n\n' "$TEST_REPO"
      printf 'worktree /worktrees/child\nHEAD deadbeef\nbranch refs/heads/child\n\n'
    else
      printf 'worktree %s\nHEAD deadbeef\nbranch refs/heads/%s\n\n' "$TEST_REPO" "$(cat "$TEST_STATE")"
      if [[ $(cat "$TEST_STATE") == child ]]; then
        printf 'worktree /worktrees/parent\nHEAD deadbeef\nbranch refs/heads/parent\n\n'
      fi
    fi
    ;;
  'worktree add')
    printf 'git worktree add %s %s\n' "$3" "$4" >>"$TEST_LOG"
    ;;
  *)
    printf 'unexpected git command: %s\n' "$*" >&2
    exit 1
    ;;
esac
GIT

cat >"$fake_bin/gt" <<'GT'
#!/usr/bin/env bash
set -euo pipefail

printf 'gt %s\n' "$*" >>"$TEST_LOG"
case ${1:-} in
  trunk)
    printf 'main\n'
    ;;
  parent)
    printf 'parent\n'
    ;;
  create)
    printf 'child\n' >"$TEST_STATE"
    printf 'created child\n'
    ;;
  delete)
    printf 'parent\n' >"$TEST_STATE"
    ;;
  *)
    printf 'unexpected gt command: %s\n' "$*" >&2
    exit 1
    ;;
esac
GT

cat >"$fake_bin/herdr" <<'HERDR'
#!/usr/bin/env bash
set -euo pipefail

if [[ ${1:-} == worktree && ${2:-} == list ]]; then
  printf '%s\n' '{"result":{"source":{"source_checkout_path":"'"$TEST_REPO"'"},"worktrees":[{"branch":"parent","open_workspace_id":"w-parent","path":"/worktrees/parent"}]}}'
else
  printf 'herdr %s\n' "$*" >>"$TEST_LOG"
fi
HERDR

chmod +x "$fake_bin/git" "$fake_bin/gt" "$fake_bin/herdr"
(
  cd "$repo"
  PATH="$fake_bin:$PATH" \
    HOME="$root/home" \
    TEST_LOG="$log" \
    TEST_REPO="$repo" \
    TEST_STATE="$state" \
    GT_WORKTREE_RESULT_FILE="$result_file" \
    bash "$wrapper" create child
)
[[ $(cat "$state") == parent ]]
[[ -s $result_file ]]
grep -q '^git worktree add ' "$log"
grep -q '^herdr worktree open ' "$log"

printf 'child\n' >"$state"
(
  cd "$repo"
  PATH="$fake_bin:$PATH" \
    HOME="$root/home" \
    TEST_LOG="$log" \
    TEST_REPO="$repo" \
    TEST_STATE="$state" \
    GT_WORKTREE_RESULT_FILE="$result_file" \
    bash "$wrapper" delete child
)

[[ $(cat "$state") == parent ]]
grep -q '^herdr worktree remove --workspace w-parent$' "$log"
grep -q '^gt delete child$' "$log"

printf 'child\n' >"$state"
(
  cd "$repo"
  PATH="$fake_bin:$PATH" \
    HOME="$root/home" \
    TEST_LOG="$log" \
    TEST_REPO="$repo" \
    TEST_SOURCE_PARENT=true \
    TEST_STATE="$state" \
    GT_WORKTREE_RESULT_FILE="$result_file" \
    bash "$wrapper" delete child
)

[[ $(cat "$state") == parent ]]
grep -q '^git checkout --detach$' "$log"
