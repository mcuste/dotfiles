import argparse
import json
import os
from pathlib import Path
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "action", choices=["apply", "config", "plan", "image", "handy", "shortcuts"]
    )
    parser.add_argument("profile", choices=["personal", "work"])
    parser.add_argument("category", choices=["headless", "desktop"])
    parser.add_argument("--interactive", action="store_true")
    parser.add_argument("--host", default="localhost")
    parser.add_argument("--group", action="append", default=[])
    options, extra = parser.parse_known_args()
    if extra[:1] == ["--"]:
        extra = extra[1:]
    if options.interactive and (
        options.category != "desktop" or options.action == "image"
    ):
        parser.error("interactive requires desktop and cannot be used for images")
    attended = options.action in {"handy", "shortcuts"}
    if attended and not options.interactive:
        parser.error("attended setup requires --interactive")
    reserved = {
        "all",
        "ungrouped",
        "personal",
        "work",
        "headless",
        "desktop",
        "interactive",
        "image_builds",
    }
    if reserved.intersection(options.group):
        parser.error("specialization groups cannot replace profile or category options")
    root = Path(__file__).resolve().parents[1]
    groups = [options.profile, options.category, *options.group]
    if options.interactive:
        groups.append("interactive")
    if options.action == "image":
        groups.append("image_builds")
    inventory = {
        "all": {
            "children": {group: {"hosts": {options.host: {}}} for group in groups},
            "vars": {
                "ansible_connection": "local",
                "ansible_python_interpreter": "{{ ansible_playbook_python }}",
            },
        }
    }
    settings = {
        "dotfiles_profile": options.profile,
        "dotfiles_checkout": str(root),
        "dotfiles_image_build": options.action == "image",
        "dotfiles_interactive": attended,
    }
    if options.action == "config":
        settings["dotfiles_install_software"] = False
    if attended:
        settings["dotfiles_interactive_feature"] = options.action
    playbook = (
        "interactive"
        if attended
        else "image"
        if options.action == "image"
        else "configure"
    )
    env = {
        **os.environ,
        "ANSIBLE_CONFIG": str(root / "ansible/ansible.cfg"),
        "ANSIBLE_INVENTORY_UNPARSED_FAILED": "true",
    }
    with tempfile.NamedTemporaryFile(
        mode="w", suffix=".json", prefix="maintenance-", dir=root / "ansible/inventory"
    ) as file:
        json.dump(inventory, file)
        file.flush()
        command = [
            "ansible-playbook",
            f"playbooks/{playbook}.yml",
            "-i",
            file.name,
            *extra,
        ]
        if options.action == "plan":
            command.append("--check")
        command += ["--extra-vars", json.dumps(settings)]
        subprocess.run(command, cwd=root / "ansible", env=env, check=True)
    if attended:
        helper = (
            "sync-handy-settings" if options.action == "handy" else "sync-shortcuts"
        )
        subprocess.run([str(Path.home() / ".local/bin" / helper)], check=True)


if __name__ == "__main__":
    main()
