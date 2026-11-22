---
name: skill-discovery
description: Before creating a new skill, investigate whether an equivalent or better capability already exists — across the agent's built-in abilities, installed skills, MCP tools, plugins, personal skills, and trusted external repositories — and recommend whether to reuse, extend, create, or do nothing.
---

# Skill Discovery

## Purpose

Avoid duplicating capabilities. Before any new skill is created, this skill
drives a disciplined investigation of what already exists so you reuse or extend
rather than reinvent — and so you don't build a dedicated skill for something the
agent can already do well on its own.

## When to use this skill

- The user asks for a new skill, or asks you to "make a skill" for a task.
- You are about to design a workflow that feels reusable and are tempted to
  package it as a skill.
- You are evaluating a third-party or external skill before adopting it.

## When NOT to use this skill

- The task is a genuine one-off with no reuse value (just do the task).
- You already know from a recent discovery pass that no equivalent exists.

## Inputs and prerequisites

- A clear statement of the user's requested task and desired outcome.
- Ability to inspect the current runtime's available skills, tools, and config.
- (Optional) Network access to consult trusted external skill repositories and
  documentation.

## Workflow

### 1. Understand the request

Restate the user's task and the concrete desired outcome in your own words.
Clarify ambiguity with the user before investigating.

### 2. Decide whether a skill is even warranted

Distinguish between:

- A **general capability** the agent/model can already perform competently
  ad hoc (no skill needed), versus
- A **dedicated skill** that provides a *repeatable, documented workflow* worth
  packaging (expertise, multi-step procedure, safety gating, domain knowledge).

If the model can reliably do it without a documented procedure, recommend **no
dedicated skill**.

### 3. Inventory the current agent's capabilities

Inspect, as available in this runtime:

- **Built-in skills** shipped with the agent.
- **Installed third-party skills.**
- **MCP servers and their tools.**
- **Plugins and integrations.**
- **Existing personal skills** (this repository and any installed copies).
- **Project-specific instructions** (e.g. `CLAUDE.md`/`AGENTS.md`, repo docs).
- **General agent/model capabilities.**

Record what you find and where it came from.

> Do not assume a skill installed in one runtime is available in another. A
> capability present in Claude Code may be absent in Codex, OpenClaw, or Hermes.
> Scope your inventory to the runtime you are actually operating in.

### 4. Consult trusted external sources (when appropriate)

If the internal inventory is inconclusive and the task warrants it, investigate
**trusted** external skill repositories and official documentation. Prefer
well-known, reputable sources.

> Never automatically install external skills. Inspect and report; installation
> is a separate, explicit, user-approved step.

### 5. Compare candidates against the request

For each existing candidate capability, compare it to what is being asked.

### 6. Evaluate the differences

Assess each candidate on:

- **Functionality** — does it cover the requested outcome?
- **Quality and completeness** — mature, or partial/brittle?
- **Dependencies** — what does it require?
- **Agent/runtime compatibility** — does it work in the target runtime(s)?
- **Security and permissions** — what access does it need; is it safe?
- **Maintenance and provenance** — who maintains it; is it trustworthy and kept
  up to date?

### 7. Recommend an outcome

Recommend exactly one, with reasoning:

- **Reuse an existing capability** (name it and how to invoke it).
- **Extend an existing skill** (name it and what to add).
- **Create a new skill** (hand off to `skill-creator`).
- **No dedicated skill is necessary** (the agent can do it directly).

## Validation and expected outcomes

The output is a short written recommendation containing: the understood task,
what was inventoried, the candidates compared, the evaluation, and the single
recommended outcome with justification.

## Error handling

- If you cannot inspect part of the runtime (e.g. no permission to list MCP
  tools), say so explicitly and note the gap rather than guessing.
- If external sources are unreachable, proceed with the internal inventory and
  flag that the external check was skipped.

## Safety considerations

- **Never auto-install** external or third-party skills.
- Treat external skills as untrusted until inspected; report provenance.
- Do not expose secrets while inspecting configuration.

## Examples

**Request:** "Create a skill to format my Git commit messages."

1. Understood: enforce a commit-message convention repeatably.
2. Skill warranted? Possibly — it's a repeatable convention.
3. Inventory: a project `CLAUDE.md` already documents the convention; the agent
   follows it natively. No MCP/plugin involved.
4. External check: skipped (internal answer is sufficient).
5–6. The project instruction already covers the need; a skill would duplicate it.
7. **Recommendation: no dedicated skill** — the existing project instruction is
   sufficient; link to it instead.

## Dependencies and compatibility notes

- Relies on the runtime's ability to enumerate its own skills/tools/plugins;
  this varies by runtime and may require manual inspection.
- Pairs with [`skill-creator`](../skill-creator/SKILL.md) (when the outcome is
  "create") and [`skill-auditor`](../skill-auditor/SKILL.md) (for library-wide
  reviews).
