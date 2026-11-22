---
name: skill-auditor
description: Periodically review the personal skills library for duplication, staleness, broken references, bad metadata, unnecessary complexity, portability problems, risky dependencies, and security issues — then produce a prioritized Markdown audit report of findings and recommended actions. Recommends only; never deletes or rewrites skills without approval.
---

# Skill Auditor

## Purpose

Keep the skills library healthy over time. This skill performs a systematic
review of the whole collection and produces an actionable audit report so the
owner can decide what to consolidate, split, improve, or retire.

## When to use this skill

- Periodic maintenance of the library (e.g. monthly, or before a cleanup).
- After adding several skills, to check for drift and overlap.
- When something feels stale, duplicated, or broken.

## When NOT to use this skill

- To create a single new skill — use [`skill-creator`](../skill-creator/SKILL.md).
- To check whether one capability already exists — use
  [`skill-discovery`](../skill-discovery/SKILL.md).

## Inputs and prerequisites

- Read access to the whole `skills/` tree and repository docs.
- [`scripts/validate-skills.sh`](../../../scripts/validate-skills.sh) and
  [`scripts/list-skills.sh`](../../../scripts/list-skills.sh).

## Workflow

### 1. Enumerate the library

```bash
./scripts/list-skills.sh
./scripts/validate-skills.sh
```

Build a complete inventory of skills, categories, and supporting files, and
capture any validation failures as initial findings.

### 2. Inspect each skill and the collection as a whole

Review for:

- **Duplicate or overlapping skills** — two skills that cover the same ground.
- **Outdated skills** — stale commands, superseded practices, old tool versions.
- **Broken references or missing supporting files** — links/scripts/references
  that do not resolve.
- **Incorrect or incomplete metadata** — missing/weak `name`/`description`, name
  not matching directory, non-discoverable descriptions.
- **Unnecessary complexity** — monolithic skills, over-engineering, content that
  belongs in `references/`.
- **Runtime-specific assumptions** that reduce portability (hardcoded paths,
  agent-only tool names baked into instructions).
- **Dependencies that may no longer be available** — tools/services/CRDs the
  skill relies on.
- **Potential security problems** — unmarked destructive commands, secret
  exposure, missing approval gates.
- **Consolidate / split / improve / retire** candidates.

### 3. Check for better existing capabilities

Flag skills that may now be redundant because a better **built-in, third-party,
or integrated** capability exists. (You can invoke
[`skill-discovery`](../skill-discovery/SKILL.md) to confirm.)

### 4. Prioritize findings

Assign each finding a severity/priority: **Critical / High / Medium / Low**
(e.g. security issue or broken skill = high; cosmetic = low).

### 5. Produce the audit report

Write a Markdown report (see format below). For each finding include: the
finding, severity/priority, affected skill(s), recommended action, and whether
human approval is needed.

### 6. Stop at recommendations

Do **not** delete, replace, or substantially modify any skill. Present the report
and wait for explicit approval before any change is made.

## Audit report format

```markdown
# Skills Library Audit — <date>

## Summary
<one-paragraph overview; counts by severity>

## Findings

### [CRITICAL|HIGH|MEDIUM|LOW] <short title>
- **Affected skill(s):** <paths>
- **Finding:** <what is wrong / the opportunity>
- **Recommended action:** <reuse / extend / consolidate / split / improve / retire / fix>
- **Approval needed:** <yes/no — and why>

... (repeat per finding) ...

## Suggested priority order
1. ...
```

## Validation and expected outcomes

- A single Markdown audit report covering the whole library.
- No files changed by the audit itself.

## Error handling

- If a skill cannot be parsed, record it as a finding rather than skipping it.
- If external capability checks are not possible, note the limitation.

## Safety considerations

- **Read-only by default.** The audit must not modify or delete skills.
- All destructive recommendations require explicit human approval before action.
- Do not expose secrets encountered while inspecting files; report their presence
  as a security finding instead.

## Examples

A finding entry:

```markdown
### [HIGH] Duplicate worktree logic
- **Affected skill(s):** skills/development/git-worktree-management,
  skills/development/git-branch-helper
- **Finding:** Both implement near-identical worktree creation steps.
- **Recommended action:** Consolidate into git-worktree-management; retire the
  duplicate.
- **Approval needed:** yes — retiring a skill requires owner approval.
```

## Dependencies and compatibility notes

- Uses `list-skills.sh` and `validate-skills.sh` from this repo.
- Pairs with [`skill-discovery`](../skill-discovery/SKILL.md) and
  [`skill-creator`](../skill-creator/SKILL.md).
