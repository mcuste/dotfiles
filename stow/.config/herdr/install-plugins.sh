#!/usr/bin/env bash
set -euo pipefail

herdr integration install omp
herdr plugin install lmilojevicc/herdr-splits.nvim --yes
herdr plugin install persiyanov/herdr-reviewr --yes

herdr plugin enable herdr-splits
herdr plugin enable persiyanov.reviewr

herdr update --handoff
herdr server reload-config
