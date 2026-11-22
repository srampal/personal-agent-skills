# personal-agent-skills

A personal, GitHub-backed, **agent-independent** library of reusable [Agent
Skills](https://code.claude.com/docs/en/skills). One canonical collection of
skills that can be shared across multiple AI coding agents and runtimes without
maintaining separate copies per agent.

## What this is

This repository is a single source of truth for a personal collection of
reusable skills. A *skill* is a self-contained, documented workflow or body of
expertise — packaged as a directory containing a `SKILL.md` file (plus optional
supporting scripts, references, and examples) — that an AI agent can load on
demand to perform a task well and repeatably.

Skills here are **not** just prompts. Each one captures a repeatable procedure,
a methodology, or domain expertise that is worth reusing across projects.

## Why it is agent-independent

Different AI agents and runtimes (Claude Code, OpenAI Codex, OpenClaw, Hermes,
and others) are converging on the **Agent Skills** standard: a skill is a folder
with a `SKILL.md` that has YAML frontmatter (`name`, `description`) followed by
Markdown instructions. By keeping skills portable and free of agent-specific
assumptions, the same skill can be exposed to any compatible runtime.

- The canonical skill definitions live here and stay portable.
- Any runtime-specific integration (install paths, discovery quirks) is handled
  by *adapters* and documented separately — it never contaminates the skill
  itself.

See [`docs/architecture.md`](docs/architecture.md) and
[`docs/agent-compatibility.md`](docs/agent-compatibility.md) for details.

## Repository layout

```text
personal-agent-skills/
├── README.md                 # This file
├── CONTRIBUTING.md           # Standards for adding/reviewing/retiring skills
├── LICENSE                   # MIT
├── spec.md                   # Original design spec (kept for provenance)
│
├── skills/                   # The canonical skill library
│   ├── meta/                 # Skills for maintaining the library itself
│   │   ├── skill-discovery/
│   │   ├── skill-creator/
│   │   └── skill-auditor/
│   ├── development/
│   │   └── git-worktree-management/
│   └── infrastructure/
│       └── kubernetes-troubleshooting/
│
├── templates/
│   └── SKILL-template.md     # Starting point for new skills
│
├── scripts/
│   ├── install-skills.sh     # One-step: link all skills into a runtime
│   ├── validate-skills.sh    # Structural + metadata checks
│   └── list-skills.sh        # Enumerate skills and descriptions
│
└── docs/
    ├── architecture.md
    ├── agent-compatibility.md
    └── adding-a-skill.md
```

Skills are grouped into categories (`meta`, `development`, `infrastructure`, …).
Add categories freely; the structure is designed to grow without rework.

## How to use the skills

### One-step install (recommended)

Use `scripts/install-skills.sh` to expose **every** skill in this repo to a
runtime in a single command. It creates one symlink per skill into the runtime's
skills directory (flattening the category folders to `<dest>/<skill-name>`, the
layout runtimes expect), so you never link skills one at a time.

```bash
# Claude Code — user level: available in EVERY project on this machine
./scripts/install-skills.sh --claude

# Claude Code — only the repo you run it from (writes ./.claude/skills)
./scripts/install-skills.sh --claude-project

# Any other runtime — point it at that runtime's skills directory
./scripts/install-skills.sh --dest /path/to/runtime/skills
```

Because it symlinks, edits you make here show up everywhere immediately. Useful
flags: `--copy` (isolated copies instead of links, e.g. for sandboxes/Windows),
`--dry-run` (preview), `--uninstall` (remove only what it installed). Run
`./scripts/install-skills.sh --help` for details.

> **Install once at the user level and you're done** — with `--claude`, all
> skills become available in whatever repo you later open Claude Code in; there
> is no per-repo step. Use `--claude-project` only when you want a skill scoped
> to a single repository.

> This repository does **not** claim that every agent automatically discovers
> skills. Discovery and installation are runtime-specific — the installer just
> puts the files where a runtime looks. Verify the destination path for your
> runtime; see [`docs/agent-compatibility.md`](docs/agent-compatibility.md).

### Manual install

If you prefer, symlink or copy an individual skill yourself:

```bash
mkdir -p ~/.claude/skills
ln -s "$PWD/skills/development/git-worktree-management" \
      ~/.claude/skills/git-worktree-management
```

Either way, the agent reads each `SKILL.md`'s `description` to decide when the
skill is relevant, then loads the full instructions on demand.

## How to add a new skill

1. Read [`docs/adding-a-skill.md`](docs/adding-a-skill.md).
2. Start from [`templates/SKILL-template.md`](templates/SKILL-template.md).
3. Use the `skill-discovery` meta-skill first to confirm you actually need a new
   skill, then `skill-creator` to build it well.
4. Validate with `scripts/validate-skills.sh`.

## How to validate the repository

```bash
./scripts/validate-skills.sh   # structural + metadata checks
./scripts/list-skills.sh       # list all skills and their descriptions
```

The scripts use standard POSIX tools and degrade gracefully when optional tools
(e.g. `yq`) are not installed.

## Safety

- Skills are never installed or executed automatically.
- No credentials, tokens, API keys, or secrets are stored here.
- Skills that run commands call out potentially destructive operations and
  require explicit user approval before changing state.

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the full standards.

## License

[MIT](LICENSE).
