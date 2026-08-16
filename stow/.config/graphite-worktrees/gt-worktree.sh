#!/usr/bin/env bash

set -o pipefail

graphite_worktree_path_for_branch() {
  local wanted_branch=$1
  local branch=""
  local path=""
  local line

  while IFS= read -r line || [[ -n $line ]]; do
    case $line in
    "worktree "*)
      path=${line#worktree }
      branch=""
      ;;
    "branch refs/heads/"*)
      branch=${line#branch refs/heads/}
      ;;
    "")
      if [[ $branch == "$wanted_branch" ]]; then
        printf '%s\n' "$path"
        return 0
      fi
      path=""
      branch=""
      ;;
    esac
  done < <(git worktree list --porcelain)

  if [[ $branch == "$wanted_branch" ]]; then
    printf '%s\n' "$path"
  fi
}

graphite_worktree_path() {
  local branch=$1
  local repository=$2
  local repository_hash
  local branch_hash
  local branch_slug

  repository_hash=$(printf '%s' "$repository" | shasum -a 256 | cut -c1-12)
  branch_hash=$(printf '%s' "$branch" | shasum -a 256 | cut -c1-12)
  branch_slug=$(printf '%s' "$branch" | tr '/' '-')
  printf '%s/%s-%s/%s-%s\n' \
    "${GRAPHITE_WORKTREE_ROOT:-$HOME/.herdr/graphite-worktrees}" \
    "$(basename "$repository")" \
    "$repository_hash" \
    "$branch_slug" \
    "$branch_hash"
}

graphite_worktree_open() {
  local branch=$1
  local repository=$2
  local existing
  local path

  existing=$(graphite_worktree_path_for_branch "$branch")
  if [[ -n $existing ]]; then
    printf '%s\n' "$existing"
    return 0
  fi

  path=$(graphite_worktree_path "$branch" "$repository")
  mkdir -p "$(dirname "$path")" || return 1
  git -C "$repository" worktree add "$path" "$branch" || return 1

  if command -v herdr >/dev/null 2>&1; then
    if ! herdr worktree open --cwd "$repository" --path "$path" >/dev/null; then
      git -C "$repository" worktree remove "$path"
      return 1
    fi
  fi

  printf '%s\n' "$path"
}

graphite_worktree_workspace_for_branch() {
  local branch=$1
  local repository=$2

  command -v herdr >/dev/null 2>&1 || return 0
  command -v python3 >/dev/null 2>&1 || return 0

  herdr worktree list --cwd "$repository" | python3 -c '
import json
import sys

payload = json.load(sys.stdin)
for worktree in payload.get("result", {}).get("worktrees", []):
    if worktree.get("branch") == sys.argv[1]:
        workspace = worktree.get("open_workspace_id")
        if workspace:
            print(workspace)
        break
' "$branch"
}

graphite_worktree_remove_branch() {
  local branch=$1
  local repository=$2
  local path
  local workspace

  path=$(graphite_worktree_path_for_branch "$branch")
  if [[ -z $path ]]; then
    return 0
  fi
  if [[ $path == "$repository" ]]; then
    printf '%s\n' "Refusing to remove the repository source checkout" >&2
    return 1
  fi

  workspace=$(graphite_worktree_workspace_for_branch "$branch" "$repository")
  if [[ -n $workspace ]]; then
    herdr worktree remove --workspace "$workspace" || return 1
  else
    git -C "$repository" worktree remove "$path" || return 1
  fi

  printf '%s\n' "$path"
}

graphite_worktree_restore_branch() {
  local branch=$1
  local path=$2
  local repository=$3

  [[ -n $path ]] || return 0
  git -C "$repository" worktree add "$path" "$branch" || return 1
  if command -v herdr >/dev/null 2>&1; then
    herdr worktree open --cwd "$repository" --path "$path" >/dev/null || return 1
  fi
}

graphite_worktree_result() {
  [[ -n ${GT_WORKTREE_RESULT_FILE:-} ]] || return 0
  printf '%s\n' "$1" >"$GT_WORKTREE_RESULT_FILE"
}

graphite_worktree_is_valid() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 1
  git branch --show-current | grep -q . || return 1
  command gt trunk --no-interactive >/dev/null 2>&1
}

graphite_worktree_create() {
  local parent_before
  local parent
  local child
  local trunk
  local repository
  local result_path

  parent_before=$(git branch --show-current) || return 1
  command gt "$@" || return $?
  child=$(git branch --show-current) || return 1
  parent=$(command gt parent --no-interactive 2>/dev/null || printf '%s' "$parent_before")
  trunk=$(command gt trunk --no-interactive) || return 1
  repository=$(git rev-parse --show-toplevel) || return 1

  if [[ $child == "$parent" ]]; then
    return 0
  fi

  if [[ $(git rev-parse --git-dir) == $(git rev-parse --git-common-dir) ]]; then
    if git checkout "$parent"; then
      result_path=$(graphite_worktree_open "$child" "$repository") || return 1
    else
      result_path=$(git rev-parse --show-toplevel)
    fi
  else
    if [[ $parent == "$trunk" ]]; then
      result_path=$(git rev-parse --show-toplevel)
    else
      graphite_worktree_open "$parent" "$repository" >/dev/null || return 1
      result_path=$(git rev-parse --show-toplevel)
    fi
  fi

  graphite_worktree_result "$result_path"
}

graphite_worktree_delete_target() {
  local argument

  shift
  for argument in "$@"; do
    case $argument in
    --upstack | --downstack)
      printf '%s\n' "gt worktree wrapper supports one branch at a time; remove stack branches from the tip down" >&2
      return 2
      ;;
    -*)
      ;;
    *)
      printf '%s\n' "$argument"
      return 0
      ;;
    esac
  done

  git branch --show-current
}

graphite_worktree_delete() {
  local operation=$1
  shift
  local target
  local parent
  local parent_path
  local repository
  local removed_path=""
  local source_detached=false
  local status

  target=$(graphite_worktree_delete_target "$operation" "$@") || return $?
  repository=$(git rev-parse --show-toplevel) || return 1

  if [[ $target == "$(git branch --show-current)" ]]; then
    parent=$(command gt parent --no-interactive) || return 1
    parent_path=$(graphite_worktree_path_for_branch "$parent")
    if [[ $parent_path == "$repository" ]]; then
      git -C "$repository" checkout --detach || return 1
      source_detached=true
    else
      removed_path=$(graphite_worktree_remove_branch "$parent" "$repository") || return 1
    fi

    command gt "$operation" "$@"
    status=$?
    if ((status != 0)); then
      if $source_detached; then
        git -C "$repository" checkout "$parent"
      else
        graphite_worktree_restore_branch "$parent" "$removed_path" "$repository"
      fi
      return "$status"
    fi
  else
    removed_path=$(graphite_worktree_remove_branch "$target" "$repository") || return 1
    command gt "$operation" "$@"
    status=$?
    if ((status != 0)); then
      graphite_worktree_restore_branch "$target" "$removed_path" "$repository"
      return "$status"
    fi
  fi

  graphite_worktree_result "$(git rev-parse --show-toplevel)"
}

graphite_worktree_gt() {
  local operation=${1:-}

  if ! graphite_worktree_is_valid; then
    command gt "$@"
    return $?
  fi

  case $operation in
  create)
    graphite_worktree_create "$@"
    ;;
  delete | fold | pop)
    graphite_worktree_delete "$@"
    ;;
  *)
    command gt "$@"
    ;;
  esac
}

graphite_worktree_gt "$@"
