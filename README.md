# dotfiles

## Installation

Run `just stow` from this repository to install the dotfiles and command links.

## Agent configuration

`stow/.omp/`, `stow/.pi/`, `stow/.claude/`, and `stow/.codex/` contain the agent setup.
Their `.gitignore` files allow only explicit configuration files, plugin
registries, package manifests, and lock files. Credentials, caches, sessions,
databases, memories, and other generated files stay local.
OMP's installed plugin registry and plugin caches stay local. Track its plugin
manifest and lock files.
Pi uses `settings.json` and `extensions/guardrails.json` without separate templates.
Pi uses `@mcuste/pi-herdr-worktree` for worktree operations.
Codex tracks `config.toml`, `AGENTS.md`, and `rules/default.rules`.
Its configuration includes machine-specific paths and local plugin registrations.
Codex credentials, bundled skills, plugin caches, and runtime state stay local.
Existing regular files in `~/.codex` must move aside before `just stow` can link
their tracked counterparts. Keep a backup outside `~/.codex`.

User instructions come from the core plugin's bundled `AGENTS.md`.
Use the `core-sync` skill in OMP or Claude to refresh plugins and user instructions.

## Utility scripts

Keep executable utility scripts in `stow/.local/bin/`. Stow links them into
`~/.local/bin`, which the Bash, Zsh, and Fish configurations add to `PATH`.
This directory is hidden in file browsers by default.

- `fetch-prs.sh`: export GitHub PR reports. Requires Git and `gh`.
- `gcloud-cluster-setup`: select a GCP project and configure cluster access.
  Requires `gcloud` and `gum` or `fzf`.
- `gcloud-list-user-permissions`: inspect GCP IAM permissions.
  Requires `gcloud` and `gum`.
- `sync-notes`: commit and push changes in `~/Projects/personal/notes`.