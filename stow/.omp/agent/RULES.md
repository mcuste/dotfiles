# Security

- Never read or edit `.env`, `.env.*`, or secret-containing environment files.
- Never read, log, or retrieve passwords, tokens, PII, private keys, secret-manager values, or IaC state.
- Never modify system files outside the project directory.
- Never read or write files outside the current working directory without first prompting the user.
- Never disable or bypass security checks.
- Never run `terraform apply`. Let the user run it.

# Dependencies

- Unless specifically requested, use current stable dependency versions.
- When updating a dependency already used by the current implementation, check changelogs and migration guides for breaking changes and notify the user before proceeding. This does not apply to new dependencies.
- Before adding a dependency, confirm it is necessary, reputable, actively maintained, secure, license-compatible, and published through a trustworthy release process. Prefer existing dependencies or standard-library functionality for trivial needs.
- Never use npm. Use pnpm or Bun where applicable.

# Style

- Never use em dashes.
- Apply these style rules to responses, prompts and session artifacts, generated documentation, docstrings, and code identifiers.
- Use established, simple, descriptive terminology; never invent terms or add fluff.
- Be concise while including the information needed to understand or use the result.
- Use simple, clear language.
- In code comments and docstrings, say plainly what the code does and why. No jargon soup: avoid stacked abstract nouns and invented phrasing (for example "point-read its own watch to gate allocation on live health"). Prefer concrete verbs and plain words (for example "read TDBus to check the device is still healthy before preparing it").

# Code comments and language rules (all projects)

## Code comments

Most added lines need NO comment. Every comment must deserve its existence. Be strict.

- Most comments must be 1 line long.
- A comment states only non-obvious intent ("why"), never what the next line does.
- Remove any comment that references code not directly below it.
- Remove all references to documents or materials outside the codebase.
- Remove all references to "how it was before" (previous versions, migrations, replaced code).
- Match the comment density of the surrounding code; when in doubt, write no comment.
- Code or comments may NOT reference the conversation with user in any way.

## Language rules (comments, commit messages, PR descriptions, docs)

- Use simple, direct English, close to ASD-STE100 (Simplified Technical English). Target non-native speakers.
- No metaphors. Clear, direct expressions.
- No play on words.
- No rare expressions or idioms (e.g. no "belt and suspenders", no "load bearing").
- Dry, technical language: minimal jargon, simple word choice, understandable to non-native speakers.
- No passive voice when possible.
- No complex composed sentence structures, e.g. no complex sentences with dashes and colons.
