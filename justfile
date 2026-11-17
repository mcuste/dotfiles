root := justfile_directory()
vm_name := "macos-agent"

default:
    @just --list

# Install the locked controller and pinned Ansible collection with uv.
bootstrap:
    cd "{{root}}" && uv sync --locked
    cd "{{root}}/ansible" && uv run --project .. ansible-galaxy collection install -r requirements.yml -p .collections

# Profile and category are required; attended tools use --interactive.
apply profile category *args:
    cd "{{root}}" && uv run python scripts/provision.py apply {{quote(profile)}} {{quote(category)}} {{args}}

config profile category *args:
    cd "{{root}}" && uv run python scripts/provision.py config {{quote(profile)}} {{quote(category)}} {{args}}

plan profile category *args:
    cd "{{root}}" && uv run python scripts/provision.py plan {{quote(profile)}} {{quote(category)}} {{args}}

image profile category *args:
    cd "{{root}}" && uv run python scripts/provision.py image {{quote(profile)}} {{quote(category)}} {{args}}

handy profile category *args:
    cd "{{root}}" && uv run python scripts/provision.py handy {{quote(profile)}} {{quote(category)}} {{args}}

shortcuts profile category *args:
    cd "{{root}}" && uv run python scripts/provision.py shortcuts {{quote(profile)}} {{quote(category)}} {{args}}

# Show local macOS VM requirements and safety limits.
vm-help:
    @printf '%s\n' \
      'Requires Apple Silicon, macOS 26+, uv, just, Packer, and Tart.' \
      'Install VM tools: brew install hashicorp/tap/packer openai/tools/tart' \
      'Use just vm-build work headless, then vm-run, vm-ssh, vm-stop, and vm-delete.' \
      'Override the name consistently: just --set vm_name NAME vm-run' \
      'Local passwords persist in .secrets/accounts.pkrvars.json. Never share this directory.' \
      'Use agent_password for admin login and sudo. Existing passwords never rotate automatically.' \
      'The first build downloads a large image and inherits its disk capacity.' \
      'Set PKR_VAR_base_image to an image digest for repeatable builds.' \
      'Builds apply noninteractive dotfiles, disable automatic login, and require a sudo password.' \
      'Choose work|personal and headless|desktop for vm-build and vm-validate.' \
      'Set PKR_VAR_dotfiles_ref to a published Git branch or tag; default main.' \
      'The guest clones GitHub into ~/dotfiles. Local uncommitted changes are not included.' \
      'No host directory sharing, host credentials, or Hermes installation.' \
      'VM networking is not isolated from the host or LAN.' \
      'Export results before deletion. The cached base image remains.' \
      'Details and Tart license: see packer/README.md'

# Create local VM passwords only when no local state exists. Run manually.
vm-configure:
    cd "{{root}}" && uv run python scripts/vm-configure-secrets.py

# Install the pinned Tart Packer plugin.
vm-init:
    cd "{{root}}" && packer init ansible/packer/macos.pkr.hcl

# Validate using local credentials. Run manually.
vm-validate profile category: vm-configure vm-init
    cd "{{root}}" && packer validate -var-file=.secrets/accounts.pkrvars.json -var {{quote("vm_name=" + vm_name)}} -var {{quote("dotfiles_profile=" + profile)}} -var {{quote("dotfiles_category=" + category)}} ansible/packer/macos.pkr.hcl

# Build a stopped VM with noninteractive dotfiles and password-protected sudo.
vm-build profile category: (vm-validate profile category)
    cd "{{root}}" && packer build -var-file=.secrets/accounts.pkrvars.json -var {{quote("vm_name=" + vm_name)}} -var {{quote("dotfiles_profile=" + profile)}} -var {{quote("dotfiles_category=" + category)}} ansible/packer/macos.pkr.hcl

# Open the VM desktop.
vm-run:
    tart run {{quote(vm_name)}}

# Connect as the VM admin user.
vm-ssh:
    ssh admin@"$(tart ip {{quote(vm_name)}})"

# Stop the VM from another terminal.
vm-stop:
    tart stop {{quote(vm_name)}}

# Permanently delete a stopped VM and its job data.
vm-delete:
    tart delete {{quote(vm_name)}}
