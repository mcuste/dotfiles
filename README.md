# dotfiles

Install software and configure your user account with Homebrew and Ansible.
Keep this repository on the machine: configuration files link into it.

## First setup

Run as your normal user, not root:

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/mcuste/dotfiles/main/bootstrap.sh)" -- --profile personal --category desktop --interactive
```

Review the script before running it. It installs Homebrew, Git, uv, Python,
and Ansible, then applies your choices. Homebrew may ask for your sudo password.
The checkout stays at `~/dotfiles`; use `--checkout PATH` to change that.
Use `--source PATH` for an existing checkout. Existing checkouts are not updated.

| Choice        | Values                | Meaning                                        |
| ------------- | --------------------- | ---------------------------------------------- |
| Profile       | `personal`, `work`    | Which software and settings to use             |
| Category      | `headless`, `desktop` | CLI tools only, or CLI tools plus desktop apps |
| Optional flag | `--interactive`       | Include Handy, Hammerspoon, and iKanata        |

Always choose a profile and category. The OS does not choose them for you.
`--interactive` requires desktop. Run its setup commands separately, below.
Linux desktop currently has no GUI packages defined.

## Normal use

Run from the checkout after `git pull`:

| Command                                      | Purpose                                              |
| -------------------------------------------- | ---------------------------------------------------- |
| `just bootstrap`                             | Sync Python dependencies and Ansible collections     |
| `just apply work headless`                   | Install missing software and apply settings          |
| `just config personal desktop --interactive` | Apply settings without software installation/removal |
| `just plan personal desktop --interactive`   | Preview changes                                      |
| `just apply work desktop --tags languages`   | Apply one role                                       |

These commands run locally. Each requires a profile and category; they do not
remember the last selection or use the checked-in host groups.
Add `--interactive` when you want those tools included. Pass other Ansible
options after the selections. Avoid `--diff` on private settings.

Applies do not generally upgrade existing software. Use Homebrew or each tool's
update command. Python is an exception: uv updates the latest stable Python and
Python 3.13. All Python dependency and version management uses uv.

## Machine-specific setup

```sh
just apply work headless --host hermes-vm --group hermes_agents
```

- `--host` selects `host_vars/<name>.yml`; the default is `localhost`.
- `--group` selects extra `group_vars/<name>.yml` files. Repeat it if needed.
- Extra groups do not install tools by themselves. Add a role and a play for
  that group in `configure.yml`. No Hermes role exists yet.
- Ansible replaces lists between groups; it does not combine them automatically.

## Where to change things

| Location                                 | Change here                                      |
| ---------------------------------------- | ------------------------------------------------ |
| `ansible/roles/<name>/defaults/main.yml` | Packages and role options                        |
| `ansible/roles/<name>/tasks/`            | Installation, configuration, and removal         |
| `ansible/roles/<name>/files/`            | Static configuration and helpers                 |
| `ansible/roles/<name>/templates/`        | Configuration that needs target-specific values  |
| `ansible/playbooks/configure.yml`        | Which groups run which roles                     |
| `ansible/inventory/group_vars/`          | Profile and machine-group settings               |
| `ansible/inventory/host_vars/`           | One machine's exceptions                         |
| `ansible/inventory/hosts.yml`            | Hosts and groups for direct Ansible use          |
| `ansible/roles/managed_files/`           | Shared linking, template, and safe-removal tasks |

`host_vars/localhost.yml` is ignored by Git. Use it for local overrides, such as
`agents_claude_code_cask` to select a Claude Code channel. Both profiles default
to `claude-code@latest`; the `agents` role does not install the Claude desktop app.
The `agents` role manages Claude Code and OMP. Hunk and Herdr have separate roles.

Graphite belongs to the work profile, and Slack belongs to work desktops.
The Git role explicitly adds the Graphite tap before installing it on clean hosts.
Personal desktops include Blender, Godot, Steam, and the gdtoolkit uv tool.

Go manages gopls, goimports, and gofumpt. pnpm manages TypeScript,
typescript-language-server, and Knip. uv manages Trafilatura in both profiles.
Keep one installation of each tool under its declared manager.

The project-local `package-audit` skill works in Claude (`/package-audit`) and OMP
(`/skill:package-audit`) from this repository. OMP's `.omp/skills/package-audit`
links to `.claude/skills/package-audit`, so both use one source even with OMP's
Claude provider disabled. Nothing installs globally.
It lists global packages with short descriptions, omits defaults and required
dependencies, and makes no changes.

Use `/package-cleanup <packages>` in Claude or `/skill:package-cleanup <packages>`
in OMP after an audit. It requires explicit approval of the exact uninstall and
leftover-file removal plan before changing anything. The cleanup skill uses the
same project-local symlink layout.

Use `/leftover-audit` in Claude or `/skill:leftover-audit` in OMP to check macOS
caches and application remnants without package names. It reports sizes,
ownership evidence, and cleanup risks without deleting anything. It also uses
one shared project-local source.

## Removal and safety

- Removing a package from a list does **not** uninstall it.
- Removing a role or changing category does **not** remove its old setup.
- Most roles accept `<role>_state=absent`. Keep the role selected while removing
  it, for example `just apply work headless --tags scripts -e scripts_state=absent`.
- Removal uses the current package list and preserves application data.
- Hunk removes only extensions listed in `hunk_owned_extensions` but omitted
  from `hunk_extensions`. Other extensions stay installed.
- Herdr applies the same rule using `herdr_owned_plugins` and `herdr_plugins`.
- Managed file removal refuses unrelated links or edited templates.
- Keep credentials, sessions, caches, and databases out of this repository.

Ansible trusts the official Bun formula (`oven-sh/bun/bun`), not its whole tap.
Other Homebrew trust approvals remain manual.

## Manual desktop steps

Requires macOS and an apply with `--interactive`. Replace `personal` with `work`
where needed.

| Tool      | Steps                                                                                                                                                      |
| --------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Handy     | Launch it, grant Microphone and Accessibility permissions, download a model, and add it to Open at Login. Run `just handy personal desktop --interactive`. |

Handy keeps device and model settings and uses **§**.

SSH key creation and GitHub enrollment remain manual. Reload OMP after changing
Herdr integration. Use `core-sync` to refresh global Rigkit plugins/instructions.

### Kanata

On Apple Silicon with macOS 15 or later, `--interactive` installs iKanata
from `mcuste/tap/ikanata` and links the Kanata keymap to `~/.config/kanata/config.kbd`.
The keymap includes home-row modifiers, symbol and Unicode layers, and leaves
the ISO § and backtick keys unswapped. Ansible leaves existing regular files in place.
Move an existing `config.kbd` aside before applying the role.

1. Disable KeyPath or any standalone Kanata service before starting iKanata.
2. If Homebrew requires trust approval, run `brew tap mcuste/tap` and
   `brew trust --cask mcuste/tap/ikanata` after reviewing the cask.
3. Run `just apply personal desktop --interactive --tags kanata`.
4. Complete iKanata onboarding for Accessibility, Input Monitoring, and
   the background service and VirtualHID driver in Login Items & Extensions.

### Hammerspoon

On macOS 13+, run `just apply personal desktop --interactive --tags hammerspoon`.
Move any existing regular `~/.hammerspoon/init.lua` aside first.
Open Hammerspoon, grant Accessibility permission, and enable launch at login.
The default Kanata Hyper key works without changes.

## Images

For a local Tart VM, run `just vm-build work headless` and `just vm-run`.
Both profile (`work` or `personal`) and category (`headless` or `desktop`) are
required. The build installs Homebrew, applies dotfiles through
`bootstrap.sh --image`, hardens the account, and shuts the guest down.
Interactive setup is never included.

The guest downloads bootstrap and clones this GitHub repository at
`PKR_VAR_dotfiles_ref` (default `main`). Use a published branch or tag, for example
`PKR_VAR_dotfiles_ref=vm-image just vm-build personal desktop`. Commit and push
changes before building: local changes are not uploaded. The checkout stays at
`/Users/admin/dotfiles` because configuration files link into it. Host credentials
and directories are not copied or shared.

The build definition is `ansible/packer/macos.pkr.hcl`.
See [VM setup](packer/README.md) for credentials, requirements, validation, and
lifecycle commands. For an external Ansible controller, prepare Python,
Homebrew, and the same checkout revision on the target. Set `dotfiles_checkout`
to its absolute path. The `just` commands are for local maintenance.
