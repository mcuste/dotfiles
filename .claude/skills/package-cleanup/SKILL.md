---
name: package-cleanup
description: Remove selected global macOS packages and their leftovers after package audit, with explicit approval before any changes.
---

# Package cleanup

Run from this dotfiles repository after `package-audit`. Accept one or more package
names, not the whole audit list. Audit findings are not permission to delete.

## Inspect and plan

- Recheck each selected installation's manager, prefix, identity, and dependents;
  audit results may be stale. Resolve ambiguous names or duplicate installations.
- Check dependencies across managers where identifiable. If an unselected package
  requires a target, stop that removal and propose a revised selection. Never force
  uninstall, bypass protection, or silently remove additional packages.
- Find leftovers using package receipts/manifests, cask uninstall/zap definitions,
  bundle IDs, and official documentation. Inspect package-specific config, caches,
  logs, application support, preferences, saved state, and services in user and
  system locations. Name similarity alone does not prove ownership.
- Do not read credentials or private data contents. Never follow symlinks to delete
  their targets, delete repository sources, or clear shared caches/directories.
  Leave uncertain ownership untouched and report it.
- Check dotfiles declarations and overrides. Warn if provisioning would reinstall
  a target; propose declaration changes separately, never edit them implicitly.

## Approval required

Before **any mutation**, show one short plan with exact package installations,
uninstall commands, services/processes to stop, and absolute leftover paths to
remove. Include native uninstall side effects, data-loss warnings, and any proposed
repository edits. Identify configs, credentials, databases, and user documents
separately from disposable caches; none are implicitly approved.

Ask for explicit approval of that plan using the available question tool, or chat.
Wait for an affirmative user response. Cancellation, silence, timeout defaults,
prior audit approval, and the initial cleanup request are **not approval**.
If scope or paths change, obtain fresh approval before the additional changes.

## Remove and verify

- Execute only the approved plan. Use the owning manager's uninstall command;
  for standalone Go binaries, remove only the verified installed executable.
- Prevent automatic unrelated cleanup where supported. No blanket autoremove,
  global cache purge, recursive name search-and-delete, or unreviewed cask `--zap`.
- Uninstall dependents before their dependencies within the approved selection.
  Then remove approved, exclusively owned leftovers using exact literal paths.
  If uninstall fails, stop cleanup for that package and report the failure.
- Recheck manager inventories and approved paths. Report removed packages/files,
  retained or inaccessible leftovers with reasons, and any remaining reinstall
  declarations. Never claim complete removal when checks are incomplete.
