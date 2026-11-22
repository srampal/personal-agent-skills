# Contributing to personal-agent-skills

This repository is the canonical, portable source of truth for a personal
collection of Agent Skills. These standards keep it clean, portable, and safe.

## Guiding principles

- **Agent independence** — Skills follow the Agent Skills standard and avoid
  hard dependencies on any single runtime (Claude Code, Codex, OpenClaw, Hermes,
  …). Runtime-specific details are documented separately, not baked into skills.
- **Reusability** — A skill captures a repeatable workflow, procedure, or body
  of expertise. It is not a one-off prompt.
- **Modularity** — Each skill has one clear, appropriately scoped purpose. Split
  large, multi-purpose skills.
- **Safety** — Inspect before modifying. Never auto-install or auto-execute
  third-party skills. Never commit secrets. Require explicit approval for
  destructive or security-sensitive actions.
- **Extensibility** — New skills drop in without reworking the architecture.

## Skill format (Agent Skills standard)

Each skill lives in its own directory under `skills/<category>/<skill-name>/`
and contains a `SKILL.md`:

```markdown
---
name: skill-name
description: One or two sentences describing what the skill does and when to use it.
---

# Skill Title

...Markdown instructions...
```

Required frontmatter:

| Field         | Rules |
|---------------|-------|
| `name`        | Lowercase, hyphen-separated. **Must match the directory name.** Unique across the whole repo. |
| `description` | Clear, discovery-friendly. Describe *what* it does and *when* to use it. Keep it concise. |

Optional supporting files (add only when justified):

- `scripts/` — helper scripts the skill invokes.
- `references/` — detailed reference material kept out of the main instructions.
- `examples/` — worked examples.

Keep `SKILL.md` instructions concise; move long reference material into separate
files and link to them.

## Adding a skill

1. Run the `skill-discovery` meta-skill first — confirm an equivalent capability
   does not already exist (built-in, MCP, plugin, or an existing skill here).
2. Copy `templates/SKILL-template.md` into the new skill directory as `SKILL.md`.
3. Fill in required frontmatter and the applicable sections (omit sections that
   do not apply).
4. Add supporting scripts/references/examples only when they earn their place.
5. Run `./scripts/validate-skills.sh` and fix any issues.
6. Run `./scripts/list-skills.sh` to confirm the skill appears correctly.
7. See [`docs/adding-a-skill.md`](docs/adding-a-skill.md) for the full walkthrough.

## Modifying a skill

- Preserve backward compatibility where other projects may depend on behavior.
- Update examples and references alongside instructions.
- Re-run validation.
- Note significant changes in the commit message.

## Reviewing a skill

Use the `skill-auditor` meta-skill periodically. Reviews should check for:

- Duplicate or overlapping skills.
- Outdated content or broken/missing references.
- Incorrect or incomplete metadata.
- Unnecessary complexity.
- Runtime-specific assumptions that hurt portability.
- Dependencies that may no longer exist.
- Security concerns.

Audits produce **recommendations**. Do not auto-delete, auto-replace, or
substantially rewrite skills without explicit approval.

## Retiring a skill

- Prefer consolidation or improvement over deletion when a skill is still partly
  useful.
- When retiring, remove the skill directory and note the rationale in the commit
  message. Check for and update any references to it.

## Safety rules (non-negotiable)

- **No secrets** — never commit credentials, tokens, API keys, kubeconfigs with
  live credentials, or private endpoints. See `.gitignore`.
- **No auto-install / auto-exec** of external skills.
- **Destructive commands** in a skill must be clearly marked and gated behind
  explicit user approval; prefer read-only inspection first.
- **Verify before claiming compatibility** — do not invent config paths or
  assert a runtime supports a feature without verification. Mark unverified
  items clearly.

## Commit conventions

- Small, focused commits with meaningful messages.
- Run validation before committing.
- Do not configure or push to a remote unless the owner asks.
