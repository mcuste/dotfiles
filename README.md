# dotfiles

## Installation

Run `just stow` from this repository to install the dotfiles and command links.

## ISO keyboard on macOS

Kanata swaps `grv` and `102d` on all layers to correct the § and backtick keys
with its US virtual keyboard.

## Voice input on macOS

Both setup profiles install [Handy](https://handy.computer/docs) for local dictation
into any focused prompt. Default shortcut: **Option + Space**.

On each Mac:

1. Grant Microphone and Accessibility permissions.
2. Download a speech model.
3. Enable **Push To Talk** and **Mute While Recording**.
4. Disable **Audio Feedback**.
5. Add Handy to macOS **Open at Login**.

Keep Handy running in the background. Keep its settings and voice data local.

## Agent configuration

`stow/.omp/`, `stow/.pi/`, `stow/.claude/`, and `stow/.codex/` contain the agent setup.
Their `.gitignore` files allow only explicit configuration files, integration
extensions, plugin registries, package manifests, and lock files. Credentials, caches, sessions,
databases, memories, and other generated files stay local.
OMP's installed plugin registry and plugin caches stay local. Track its plugin
manifest and lock files.
OMP loads `@mcuste/pi-herdr-worktree` through the plugin registry. Register local
extensions only when their files exist.
OMP discovers the tracked `agent/extensions/herdr-omp-agent-state.ts` integration
for Herdr pane state and completion notifications. Refresh it with
`herdr integration install omp`. Run `/reload` in existing OMP sessions after
installing or refreshing the integration.
Pi uses `settings.json` and `extensions/guardrails.json` without separate templates.
Pi uses `@mcuste/pi-herdr-worktree` for worktree operations.
Codex tracks `config.toml`, `AGENTS.md`, and `rules/default.rules`.
Its configuration includes machine-specific paths and local plugin registrations.
Codex credentials, bundled skills, plugin caches, and runtime state stay local.
Existing regular files in `~/.codex` must move aside before `just stow` can link
their tracked counterparts. Keep a backup outside `~/.codex`.

User instructions come from the core plugin's bundled `AGENTS.md`.
Use the `core-sync` skill in OMP or Claude to refresh plugins and user instructions.

Claude and OMP use the same global Rigkit plugin set: `core` and `td`.
Install each package with `claude plugin install <package>@rigkit --scope user`
and `omp plugin install <package>@rigkit --scope user`.
The TD skills require the `td` toolbox for Jenkins inspection and
`josh_ci_cli` in the target project for GraphCI validation.

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
