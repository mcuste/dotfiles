#!/usr/bin/env python3

import json
import os
import secrets
import sys
from pathlib import Path


def configure(directory):
    destination = directory / "accounts.pkrvars.json"
    if directory.is_symlink() or destination.is_symlink():
        sys.exit("Refusing to store secrets through a symbolic link.")
    if destination.exists():
        print("Keeping existing local account passwords.")
        return

    values = {
        "base_ssh_password": "admin",
        "agent_password": secrets.token_urlsafe(24),
    }
    os.umask(0o077)
    directory.mkdir(mode=0o700, exist_ok=True)
    directory.chmod(0o700)
    try:
        descriptor = os.open(destination, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    except FileExistsError:
        print("Keeping existing local account passwords.")
        return
    with os.fdopen(descriptor, "w") as output:
        json.dump(values, output, indent=2)
        output.write("\n")
    print(
        "Saved account passwords in .secrets/accounts.pkrvars.json with owner-only access."
    )
    print("Use agent_password for the VM admin account login and sudo.")


def main():
    configure(Path(__file__).resolve().parent.parent / ".secrets")


if __name__ == "__main__":
    main()
