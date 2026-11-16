---
name: package-audit
description: Audit global macOS packages across package managers, explain their purpose, and identify packages to review for removal.
---

# Global package audit

Read-only. Never install, update, remove, or run cleanup. Request access if needed.
Inspect installed state, not just dotfiles. Skip unavailable managers; report failed
or incomplete checks. Exclude project environments, caches, and application plugins.

## Inventory

Use each available manager's read-only listing and metadata commands:

| Source         | Inventory                                                                                                                                         |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| Homebrew       | `brew info --json=v2 --installed`; include formulae and casks from every installed tap.                                                           |
| Cargo          | `cargo install --list`; omit rustup toolchains and bundled components.                                                                            |
| Go             | Inspect executables in `go env GOBIN`, or `$(go env GOPATH)/bin` when unset; identify modules with `go version -m PATH`.                          |
| JavaScript     | `pnpm list -g --depth=0 --json`, `npm list -g --depth=0 --json`, `bun pm ls -g`; check distinct global prefixes.                                  |
| Python tools   | `uv tool list`, `pipx list --json`; inspect non-virtualenv pip installations with `python -m pip list --not-required --format=json` when present. |
| Other managers | If installed, inspect `gem list --local`, `luarocks list --porcelain`, `dotnet tool list --global`, and `mas list`.                               |

Check both Homebrew prefixes on macOS when present. Deduplicate shared inventories,
not separate installations of the same package. Do not execute unknown binaries.

## Filter and explain

- Omit OS/bundled defaults only when provenance confirms they are defaults.
- Omit packages required by another installed package. For Homebrew, check installed
  formula dependencies and cask `depends_on` metadata, not only `brew leaves`.
- Keep unused dependency leaves visible as possible leftovers, even if installed
  automatically. A manager's top-level listing alone does not prove independence.
- Compare with this dotfiles repository's package lists and profile/host overrides
  when available. Mark matches `managed`, others `unmanaged`, uncertainty `unknown`.
  Unmanaged does not mean unused; never recommend removal based on that alone.
- Use installed metadata for one plain sentence about each package's purpose;
  consult its official documentation if needed. Say when the purpose is unknown.

## Output

Group by manager, alphabetically: `package: one-sentence purpose. [managed|unmanaged|unknown]`
Keep distinct installation locations when duplicated. No versions, dependency dumps,
or deletion commands unless requested. End with one short coverage note naming
unavailable/failed inventories and any dependency or provenance uncertainty.
