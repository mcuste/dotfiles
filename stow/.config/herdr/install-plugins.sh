#!/usr/bin/env bash
set -euo pipefail

plugins=(
  "herdr-splits lmilojevicc/herdr-splits.nvim"
  "herdr-workspacer mcuste/herdr-workspacer"
)

herdr integration install omp
installed="$(herdr plugin list --json)"
for entry in "${plugins[@]}"; do
  read -r name source <<<"$entry"
  if jq -e --arg source "$source" \
    '.result.plugins | any(.source.kind == "github" and (.source.owner + "/" + .source.repo) == $source)' \
    <<<"$installed" >/dev/null; then
    herdr plugin update "$name" --yes
  else
    herdr plugin install "$source" --yes
  fi
  herdr plugin enable "$name"
done

herdr server reload-config
