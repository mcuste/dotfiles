#!/usr/bin/env bash
set -euo pipefail

herdr integration install omp
herdr plugin install lmilojevicc/herdr-splits.nvim --yes
herdr plugin install mcuste/herdr-workspacer --yes

herdr plugin enable herdr-splits
herdr plugin enable herdr-workspacer

herdr update --handoff
herdr server reload-config
