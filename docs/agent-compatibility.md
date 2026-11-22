# Agent compatibility

How to expose the single canonical skill library in this repository to different
agent runtimes. The guiding rule: **the portable skill definition never changes
per runtime** — only the installation/adapter layer does.

> ⚠️ **Verify paths and features for your versions.** Runtimes evolve and their
> skill-discovery conventions differ. Treat the runtime-specific paths below as
> *starting points to verify*, not guarantees. Anything unverified is marked.

## The general model

Every supported runtime discovers skills from one or more directories. To share
this library, make each canonical skill directory visible to the runtime by
either:

1. **Symlinking** the skill directory into the runtime's skills location, or
2. **Copying** the skill directory into it.

Because every skill is a self-contained folder with a `SKILL.md`, both approaches
work without modifying the skill.

## One-step install: `scripts/install-skills.sh`

Rather than linking skills one at a time, `scripts/install-skills.sh` exposes
**all** of them in a single command. For every skill it creates one entry —
`<dest>/<skill-name>` → `<repo>/skills/<category>/<skill-name>` — in the target
skills directory.

```bash
./scripts/install-skills.sh --claude           # ~/.claude/skills (all projects)
./scripts/install-skills.sh --claude-project   # ./.claude/skills (this repo only)
./scripts/install-skills.sh --dest <path>      # any runtime's skills directory
# flags: --copy, --dry-run, --uninstall, --help
```

### Why it flattens the category folders

This repo groups skills under categories (`skills/meta/`, `skills/development/`,
…), but **Claude Code only auto-loads skills that are direct children of the
skills directory at startup** — `~/.claude/skills/<name>/SKILL.md`. Skills nested
one level deeper (e.g. under a `meta/` folder inside the skills dir) are *not*
loaded at startup; they are discovered only on demand (when the agent happens to
work inside that subdirectory, or via `/add-dir`). To make every skill reliably
available from the start, the installer "flattens": it links each skill directly
as `<dest>/<skill-name>`, regardless of its category here. (Verified against
Claude Code docs, 2026-11; confirm for your version.)

Symlinks are fully supported by Claude Code and de-duplicated if multiple entries
resolve to the same target, so re-running the installer is safe.

### Symlinks vs. copy-based installation

| Aspect | Symlink | Copy |
|---|---|---|
| Stays in sync with this repo | Yes (edits here apply immediately) | No (must re-copy after changes) |
| Works where symlinks are unsupported | No | Yes |
| Risk of accidental edits to canonical source | Edits via the link change the repo | Isolated copy |
| Best for | Your own machine, active development | Sandboxes, CI, restricted/Windows environments |

Recommended default on your own machine: **symlink**, so the repo stays the
single source of truth. Use **copy** where symlinks are not available or where
you want an isolated, frozen version.

### Runtime-specific skill directories

Each runtime looks for skills in its own location(s), typically a
personal/user-level directory and sometimes a project-level one. Point the
runtime at this library by linking/copying individual skills (or the whole
`skills/` tree, if the runtime scans recursively — verify) into that location.

### Differences in discovery and supported features

Runtimes differ in:

- **Where** they look for skills (user vs project scope).
- **Whether** they scan recursively or expect a flat directory of skills.
- **Which** frontmatter fields they read beyond `name`/`description`.
- **How/whether** supporting files (`scripts/`, `references/`) are used.
- **Whether** skills are auto-discovered or must be explicitly enabled.

Always confirm the behavior for the runtime and version you are using.

## Per-runtime notes

### Claude Code

Verified against Claude Code documentation (2026-11); confirm for your version:

- **Personal / user-level skills:** `~/.claude/skills/<skill-name>/SKILL.md` —
  available in **all projects** on the machine.
- **Project-level skills:** `.claude/skills/<skill-name>/SKILL.md` in the repo —
  scoped to that repository (also discovered in parent dirs up to the repo root).
- **Startup discovery is flat:** only direct children of the skills directory
  load at startup. Deeper nesting (category folders) loads only on demand or via
  `/add-dir`. → prefer the flattening installer (above).
- **Symlinks are supported** and de-duplicated across locations.
- Discovery is driven by each `SKILL.md`'s `name`/`description` frontmatter.

Fastest path — install everything at the user level once:

```bash
./scripts/install-skills.sh --claude
```

### OpenAI Codex

- Codex supports the Agent Skills (`SKILL.md`) standard — the same canonical
  skill file is portable to it. OpenAI also publishes a skills catalog at
  `github.com/openai/skills`.
- **Its exact on-disk skills directory is not clearly documented and is
  UNVERIFIED here.** The installer's `--codex` flag uses a placeholder
  (`~/.codex/skills`) only; confirm the real location against current Codex
  documentation and prefer:

  ```bash
  ./scripts/install-skills.sh --dest <verified-codex-skills-dir>
  ```

### OpenClaw

- Intended to support the Agent Skills standard. **Installation path and
  discovery rules are runtime-specific and must be verified** against current
  OpenClaw documentation. *(Unverified here.)*

### Hermes

- Intended to support the Agent Skills standard. **Installation path and
  discovery rules are runtime-specific and must be verified** against current
  Hermes documentation. *(Unverified here.)*

### Other Agent Skills–compatible runtimes

Any runtime that implements the Agent Skills standard can consume these skills by
pointing its discovery mechanism at the skill directories. Follow the same
symlink-or-copy approach and verify the runtime's specifics.

## Why adaptations must not contaminate the portable definition

If a skill hardcoded a runtime's install path, tool name, or discovery quirk, it
would stop being portable and would need per-agent forks — exactly what this
repository exists to avoid. Therefore:

- Keep all install/link logic **outside** `SKILL.md` (in this doc, or in your own
  local scripts that are not committed as part of a skill).
- Keep runtime-specific tool names and paths **out of** skill instructions; write
  instructions against standard, portable tooling.
- If a skill genuinely needs runtime-specific behavior, document it in a clearly
  separated section and mark it as runtime-specific — never make it the default
  path of the portable workflow.

## A note on verification

This document deliberately does **not** invent configuration paths or assert
feature support that has not been confirmed. Where a path or capability is
uncertain it is marked *(verify)* or *(unverified)*. Confirm against each
runtime's official documentation before depending on it.
