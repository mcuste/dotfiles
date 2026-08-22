#!/usr/bin/env bash
set -euo pipefail

herdr integration install omp
herdr plugin install fullerzz/herdr-plugin-sesh --yes
herdr plugin install lmilojevicc/herdr-splits.nvim --yes
herdr plugin install persiyanov/herdr-reviewr --yes
