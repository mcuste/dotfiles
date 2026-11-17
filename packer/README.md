# Packer setup

## Local macOS agent VM

The Tart/Packer definition lives in `ansible/packer/macos.pkr.hcl`.
Guest scripts live in `scripts/vm-*.sh`; root `just` recipes use the `vm-` prefix.
This workflow builds a stopped VM with Homebrew and noninteractive dotfiles.
It does not install Hermes, share host directories, copy host credentials, or
isolate networking from the host or LAN.

Requires an Apple Silicon Mac on macOS 26+ and the repository's uv/just tools:

```sh
brew install hashicorp/tap/packer openai/tools/tart
just vm-build work headless
just vm-run
just vm-ssh
just vm-stop
just vm-delete
```

Deletion permanently removes the VM and its job data, not the cached base image.
Export results first. Use `just --set vm_name NAME vm-build work headless` and the
same name override for every later command. Run `just vm-help` for a short reference.

`just vm-configure` creates `.secrets/accounts.pkrvars.json` only when absent.
The owner runs credential commands directly. Do not copy secrets from another
checkout. New checkouts generate a strong random agent password; existing
passwords never rotate automatically. The helper uses owner-only permissions and
never prints passwords. Keep `.secrets/` private, untracked, and off guest shares.

The image retains the `admin` account and changes its login and sudo password to
`agent_password` from that local file. Homebrew belongs to admin at `/opt/homebrew`.
The final guest script disables automatic login, removes passwordless sudo,
checks the sudo policy, then shuts the guest down because Packer still holds the
base-image password. These scripts are guest-only; do not run them on the host.

The default base is `ghcr.io/cirruslabs/macos-tahoe-vanilla:latest`. The first build
downloads a large image and inherits its disk capacity. Set `PKR_VAR_base_image`
to an image digest for repeatability. The Tart Packer plugin stays pinned to
1.21.0; `just vm-init` installs it and `just vm-validate work headless` checks the definition.
Avoid debug logs that might expose build credentials.

See [Tart image details](https://tart.run/quick-start/) and the
[Tart license](https://github.com/openai/tart/blob/main/LICENSE).

## Dotfiles provisioning

Both `vm-build` and `vm-validate` require a profile (`work` or `personal`) and
category (`headless` or `desktop`). Packer validates these values. There is no
interactive option, including for desktop images.

The build runs these guest scripts in order:

1. `vm-bootstrap-homebrew.sh` installs Homebrew as `admin`.
2. `vm-provision-dotfiles.sh` downloads bootstrap from GitHub and runs
   `bootstrap.sh --image` with the selected profile, category, and ref.
3. `vm-configure-accounts.sh` hardens account access and shuts down the guest.

Bootstrap clones the public GitHub repository into `/Users/admin/dotfiles`.
Keep this checkout in the final image because configuration files link into it.
No host checkout, uncommitted changes, local overrides, credentials, or `.secrets/`
are uploaded. Provisioning uses the guest's temporary passwordless sudo access
before the final hardening step. It sets noninteractive environment variables
and closes bootstrap's standard input so prompts cannot wait for user input.

The default dotfiles ref is `main`. Select another published branch or tag:

```sh
PKR_VAR_dotfiles_ref=vm-image just vm-validate personal desktop
PKR_VAR_dotfiles_ref=vm-image just vm-build personal desktop
```

The same ref selects the downloaded bootstrap script and the cloned checkout.
Commit and push the required revision before building, including any changes to
bootstrap or Ansible. The remote revision must support `--image` and the selected
profile and category. A fixed release tag makes the dotfiles revision repeatable;
moving branches can change between download and clone. `--ref` currently accepts
branches and tags, not commit hashes.

## Other image builds

Use `bootstrap.sh --image` as the intended non-root user with an explicit
`--profile`, `--category`, and persistent `--checkout`. Download bootstrap and
select `--ref` from the same published revision. Homebrew needs prepared
permissions or sudo access without a password prompt. Platform build tools,
network access, and approval for required Homebrew tap trust are also required.
Never include `--interactive` or upload credentials, caches, or sessions.

## Using Packer's Ansible provisioner instead

Prepare Python, Homebrew, and the persistent checkout on the guest first.
Use `ansible/playbooks/image.yml` and set `dotfiles_checkout` to the guest path.
Keep guest and controller checkouts at the same revision. Inventory needs
`image_builds`, one profile, and one category. Do not add `interactive`.

## Before distributing an image

Review identity and trust settings. Supply credentials at first boot.
Packer must handle platform cleanup, build access removal, and machine/SSH host
identity. Bootstrap does not handle these steps. Boot the finished image and
check it; a successful provisioning run alone is not enough.
