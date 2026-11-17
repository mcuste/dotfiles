# Local VM secrets

The repository owner manages local VM credentials in `.secrets/`.

- Never read, list contents, search, create, or modify files in `.secrets/`.
- Never retrieve or print secret values, including through scripts or tools.
- Never copy `.secrets/` into VM images or share it with a running VM.
- The owner runs `just vm-configure` directly. Use secret file paths, not values,
  when discussing configuration.
