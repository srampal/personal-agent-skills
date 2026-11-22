# Architecture

This document records the architectural principles and design decisions behind
`personal-agent-skills`.

## Goal

Maintain **one canonical, portable collection of reusable skills** that can be
shared across multiple AI coding agents and runtimes (Claude Code, OpenAI Codex,
OpenClaw, Hermes, and others) — without maintaining a separate copy of each skill
per agent.

## Core principles

### Agent independence

- Skills follow the **Agent Skills standard**: a directory with a `SKILL.md`
  containing YAML frontmatter (`name`, `description`) and Markdown instructions.
- No single agent is a hard dependency. Core skill instructions avoid
  agent-specific assumptions.
- Where runtime-specific integration is unavoidable, it is documented separately
  (see [`agent-compatibility.md`](agent-compatibility.md)) and kept out of the
  portable skill.

### Reusability

Skills capture repeatable workflows, procedures, or expertise — not generic
prompt text. If a thing is a one-off, it is not a skill.

### Modularity

Each skill has a single, clearly scoped responsibility. Monolithic skills that
bundle unrelated concerns are split.

### Safety

- Never auto-install or auto-execute third-party skills.
- Never store secrets.
- Destructive/state-changing operations are clearly marked and gated on explicit
  user approval; inspection and validation come before modification.

### Extensibility

New skills are added by dropping a directory under `skills/<category>/` — no
changes to the overall architecture required. The layout is designed so a
capability registry could be added **later** without restructuring.

## Separation of concerns

A key design decision is to keep four things distinct:

### 1. Portable skill definitions (this repository)

The **canonical source of truth**. These are agent-independent and contain no
runtime-specific install logic. Everything in `skills/` is portable.

### 2. Agent-specific adapters and installation mechanisms

How a canonical skill becomes visible to a particular runtime (symlink, copy,
runtime-specific skills directory) lives **outside** the skill definition —
documented in [`agent-compatibility.md`](agent-compatibility.md). Adapters must
not contaminate the portable skill. A skill should never hardcode, e.g.,
`~/.claude/skills/...` in its instructions.

### 3. Agent memory systems

Agent memory (a runtime's persistent notes, conversation memory, project memory)
is **separate** from skills. Skills are versioned, reviewable, portable
procedures; memory is runtime-managed state. This repository does not manage
agent memory, and skills should not assume a particular memory system exists.

### 4. A future capability registry

Not implemented yet (by design). A registry would later index and discover skills
automatically (parsing frontmatter, categorizing, surfacing them to runtimes).
The repository is structured — consistent `SKILL.md` frontmatter, predictable
directory layout — so a registry can be layered on **without** changing how
skills are authored today.

```
┌─────────────────────────────────────────────┐
│  Canonical skill definitions (this repo)      │  ← source of truth, portable
└───────────────┬───────────────────────────────┘
                │ exposed via
   ┌────────────┼───────────────┬───────────────┐
   ▼            ▼               ▼               ▼
Claude Code   Codex         OpenClaw        Hermes      ← per-runtime adapters
(symlink/     (symlink/     (symlink/       (symlink/       (installation only)
 copy)         copy)         copy)           copy)

  [ Agent memory systems ]  ← separate, runtime-managed, not skills
  [ Future capability registry ]  ← optional later layer over the same repo
```

## Why the repository is the source of truth

All edits happen here; runtimes consume copies or links. This guarantees:

- One place to review, validate, and version skills.
- No divergence between per-agent copies.
- Portability is preserved because the canonical form never absorbs
  runtime-specific hacks.

## Explicitly out of scope (for now)

Per the design spec, the following are intentionally **not** built yet:

- A capability registry.
- An MCP server.
- An automated discovery daemon.
- A centralized agent memory service.
- Complex CI/CD infrastructure.

These can be introduced later without reworking the foundation.
