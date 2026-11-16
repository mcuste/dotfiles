# Packer setup

Use the same bootstrap script inside the VM. Run as the intended user, not root.
Keep the checkout in the final image: configuration files link into it.

## Requirements

- Bash, curl, network access, and platform build tools.
- Prepared Homebrew permissions or sudo access that needs no password prompt.
- Approval for any required Homebrew tap trust.

Add this to your existing Packer build:

```hcl
provisioner "shell" {
  inline = [
    "bash -c \"$(curl -fsSL https://raw.githubusercontent.com/mcuste/dotfiles/main/bootstrap.sh)\" -- --profile work --category headless --image --checkout \"$HOME/dotfiles\""
  ]
}
```

| Option | Purpose |
| --- | --- |
| `--profile personal` or `work` | Choose software/settings |
| `--category headless` or `desktop` | Choose CLI-only or desktop setup |
| `--image` | Run image checks and reject interactive setup |
| `--checkout PATH` | Keep the checkout at this guest path |
| `--host NAME`, `--group NAME` | Add machine settings and extra groups |

Pin the script URL and `--ref` to the same revision for repeatable builds.
You can instead upload clean source to a permanent guest directory and run:

```sh
bash /path/to/dotfiles/bootstrap.sh --source /path/to/dotfiles --profile work --category headless --image
```

Do not delete that directory or upload credentials, caches, or sessions.

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
