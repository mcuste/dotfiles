root := justfile_directory()

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
