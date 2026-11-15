#!/usr/bin/env bash
set -euo pipefail

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/hunk"

extensions=(
  mcuste/hunk-markdown-preview
  mcuste/hunk-stage
)

for source in "${extensions[@]}"; do
  name="${source##*/}"
  if [[ -d "$config_dir/extensions/installed/$name" ]]; then
    hunk extension update "$name"
  else
    hunk extension install "$source" --yes
  fi
done

records="$config_dir/extensions/installed/records.json"
if [[ -f "$records" ]]; then
  installed=$(jq -r '.installs | keys[]' "$records")
  while IFS= read -r name; do
    [[ -n "$name" ]] || continue
    keep=false
    for source in "${extensions[@]}"; do
      if [[ "${source##*/}" == "$name" ]]; then
        keep=true
        break
      fi
    done
    if [[ "$keep" == false ]]; then
      hunk extension remove "$name"
    fi
  done <<<"$installed"
fi
