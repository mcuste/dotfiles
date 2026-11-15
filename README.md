# dotfiles

## Installation

Run `just stow` from this repository to install the dotfiles and command links.

Both work (`scripts/setup.sh`) and personal (`scripts/personal.sh`) setups install
[Tart](https://tart.run/) from `openai/tools/tart` for macOS virtual machines
on Apple Silicon.

Both setups also install KeyPath from `mcuste/tap`. Run KeyPath's setup wizard
after installation to configure its driver, services, and permissions.

### KeyPath configuration

`~/.config/keypath` links directly to `stow/.config/keypath`. KeyPath edits
the tracked config and rule files in that directory. Local `.backups` stay
untracked.

`kanata.custom.kbd` preserves the original custom Kanata layout as a backup.

## macOS shortcuts

On macOS, `just stow` also syncs shortcuts from `stow/.config/shortcuts/`.
Run `just shortcuts` to sync them separately. This requires macOS, `jq`, and an
interactive terminal for new imports. Signing may require an iCloud login.

The setup keeps an existing shortcut with the same name. For a missing shortcut,
it signs the tracked file and opens Apple's import dialog. Confirm **Add Shortcut**,
then press Enter in the terminal. The setup checks that the import completed
before applying its keyboard binding.

App shortcuts and their keyboard bindings live in `bindings.json`.

| Binding | Action                                       |
| ------- | -------------------------------------------- |
| Hyper+G | Open or focus Ghostty                        |
| Hyper+B | Open or focus Brave                          |
| Hyper+O | Open or focus OrbStack                       |
| Hyper+L | Move the current window to the left half     |
| Hyper+R | Move the current window to the right half    |
| Hyper+F | Fill the screen without entering full screen |

Window bindings live in `menu-bindings.json`. They use the native Window menu
and require macOS 15 or later and English menu titles. They only work in apps
that expose those menu commands.

The setup preserves unrelated keyboard bindings. Repeated runs skip installed
shortcuts and apply the same bindings without creating duplicates.
It does not replace actions in existing shortcuts. To use a changed definition,
remove the old shortcut in Shortcuts, then run `just shortcuts` again.

Allow script execution in Shortcuts settings when prompted.
Apps may need relaunching to load changed keyboard bindings.

## Voice input on macOS

Both setup profiles install [Handy](https://handy.computer/docs) for local dictation
into any focused prompt. Default shortcut: **Option + Space**.

On each Mac:

1. Grant Microphone and Accessibility permissions.
2. Download a speech model.
3. Run `just stow` (requires `jq` on macOS).
4. Add Handy to macOS **Open at Login**.

The settings sync quits Handy if it is running and relaunches it afterward.
Edit `stow/.config/handy/settings.json`, then run `just stow`
to apply changes. The saved shortcut is **§**, with
tap-to-toggle or hold-to-talk and mute while recording.
Add preferred spellings to `settings.custom_words` in that file.
Keys, audio devices, models, and voice data stay local. Keep Handy running
in the background.

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
