---
name: leftover-audit
description: Find reclaimable macOS caches and application leftovers without package names, using ownership evidence and a read-only disk audit.
---

# Leftover audit

Read-only; no package names required. Never delete, move, truncate, uninstall,
stop services, or run cleanup commands. Request filesystem access if needed;
never bypass permissions or request sudo just to complete the scan.

## Inspect

- Start with directory sizes, then inspect the largest relevant entries. Use
  read-only metadata tools; do not follow symlinks, cross mounted volumes, or
  enumerate every file on disk. Do not launch applications or read private data,
  credential files, browser histories, or environment-file contents.
- Inspect `~/Library/Caches`, `~/Library/Logs`, `~/.cache`, and known developer
  package-manager caches. Check `~/Library/Application Support`, `Preferences`,
  `Saved Application State`, `Containers`, `Group Containers`, and `LaunchAgents`
  for app-specific remnants, not as directories to clear wholesale.
- Check `/Library/Caches`, `/Library/Logs`, `/Library/Application Support`, and
  launch-service metadata where accessible. Inventory `/Applications` and
  `~/Applications` to identify installed owners, not as disposable directories.
  Inspect other package-specific locations only when metadata establishes them.
- Exclude `/System`, protected OS stores, backups/snapshots, cloud-synced files,
  Trash, user documents/downloads, project environments, and source/build trees
  unless explicitly requested. Never treat these as caches based on size or age.

## Assess

- Match paths to bundle IDs, installed apps/packages, package receipts/manifests,
  official uninstall metadata, running processes, and launch services. An app
  missing from `/Applications` alone does not establish an orphan.
- Classify candidates as **regenerable cache**, **likely leftover**, or **uncertain**.
  For caches, establish that the owner can regenerate them and name any required
  app shutdown, download, rebuild, or offline-use cost. Logs may have diagnostic
  value. Age, a filename match, or no running process is not proof of safety.
- Treat preferences, application support, containers, databases, and shared
  directories as user data unless evidence proves otherwise. Keep active/shared
  dependencies and OS-managed data out of deletion recommendations. Flag
  uncertain ownership rather than claiming files are safe to delete.

## Report

Show a concise table, largest first: **absolute path | allocated size | category |
owner/evidence and cleanup consequence**. Collapse nested candidates to avoid
counting bytes twice; do not equate apparent size with reclaimable disk space.
Separate strong candidates from uncertain items needing review. End with scan
coverage, inaccessible locations, and exclusions. No deletion commands or claims
of complete coverage. Any later removal needs a separate exact-path plan and
explicit user approval; this audit never grants that approval.
