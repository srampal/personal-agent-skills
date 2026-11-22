---
name: skill-creator
description: Create high-quality, reusable, portable skills that follow the Agent Skills standard — from clarifying purpose and checking for duplicates, through designing a well-scoped SKILL.md with correct YAML frontmatter, to validating it and explaining how to expose it to different agent runtimes.
---

# Skill Creator

## Purpose

Produce well-structured, portable skills that follow the Agent Skills standard
and fit this repository's conventions — so new skills are discoverable,
maintainable, safe, and reusable across runtimes.

## When to use this skill

- `skill-discovery` has recommended **creating a new skill**.
- The user explicitly asks you to build a new skill and reuse is ruled out.

## When NOT to use this skill

- You have not yet checked for existing capabilities — run
  [`skill-discovery`](../skill-discovery/SKILL.md) first.
- The need is a one-off with no reuse value.

## Inputs and prerequisites

- The intended purpose and target users of the proposed skill.
- The outcome of a `skill-discovery` pass (confirming reuse is not preferable).
- Access to [`templates/SKILL-template.md`](../../../templates/SKILL-template.md)
  and [`scripts/validate-skills.sh`](../../../scripts/validate-skills.sh).

## Workflow

### 1. Understand purpose and audience

Clarify what the skill is for, who/what will invoke it, and what "done" looks
like. Write a one-sentence purpose statement before proceeding.

### 2. Confirm it does not already exist

If not already done, run [`skill-discovery`](../skill-discovery/SKILL.md). Do not
duplicate an existing capability.

### 3. Specify the skill

Identify and write down:

- The **workflow** (the ordered steps).
- **Assumptions** the workflow makes.
- **Inputs** it needs and **outputs** it produces.
- **Dependencies** (tools, services, permissions).
- **Limitations** and known edge cases.

### 4. Scope it correctly

Give the skill **one clear responsibility**. If it tries to solve unrelated
problems, split it into multiple skills. Prefer modular over monolithic.

### 5. Choose a category and name

- Pick a category under `skills/` (e.g. `meta`, `development`,
  `infrastructure`), or propose a new one.
- Choose a `name`: lowercase, hyphen-separated, unique across the repo. The
  **directory name must match `name` exactly.**

### 6. Create the SKILL.md from the template

Copy [`templates/SKILL-template.md`](../../../templates/SKILL-template.md) to
`skills/<category>/<name>/SKILL.md` and fill it in:

- **Required frontmatter:** `name` and `description`. Write the `description` for
  discovery — state *what* it does and *when* to use it, specifically.
- Keep only the documentation sections that apply; delete the rest.
- Keep the main instructions concise.

### 7. Add supporting files only when justified

- `scripts/` for helper scripts, `references/` for long reference material,
  `examples/` for worked examples.
- Move lengthy detail out of `SKILL.md` into `references/` and link to it.
- Do not add files that do not earn their place.

### 8. Follow the standard, not a bespoke format

Adhere to the official Agent Skills specification. Do not invent an alternate
frontmatter or layout.

### 9. Write good content

Ensure the skill includes, as applicable:

- A **clear, discovery-friendly description.**
- **Explicit instructions and an ordered workflow.**
- **Input/output expectations.**
- **Error handling.**
- **Security considerations** (mark destructive steps; gate them on approval).
- **Examples** of correct usage.

### 10. Validate

Run the repository validator and fix anything it flags:

```bash
./scripts/validate-skills.sh
./scripts/list-skills.sh   # confirm the new skill appears correctly
```

### 11. Explain usage and exposure

Tell the user how to invoke the skill and how to expose it to their runtimes
(symlink/copy into the runtime's skills directory), referencing
[`docs/agent-compatibility.md`](../../../docs/agent-compatibility.md). Do not
claim automatic cross-runtime discovery.

## Validation and expected outcomes

- A new `skills/<category>/<name>/SKILL.md` that passes
  `validate-skills.sh`.
- Any justified supporting files, all referenced files present.
- A short note to the user on usage and runtime exposure.

## Error handling

- If validation fails, fix the reported issue and re-run; do not leave a broken
  skill committed.
- If the scope grows beyond one responsibility, stop and split the skill.

## Safety considerations

- Never embed secrets, tokens, or credentials in a skill or its examples.
- Clearly mark any destructive/state-changing commands and require explicit user
  approval before they run; prefer read-only steps first.
- Keep agent-specific assumptions out of the portable skill; document runtime
  specifics separately.

## Examples

Creating `development/pr-review-checklist`:

1. Purpose: a repeatable checklist for reviewing pull requests.
2. `skill-discovery`: no equivalent skill exists.
3–4. Single responsibility: guide a structured PR review. Well scoped.
5. Category `development`, name `pr-review-checklist`.
6. Copy the template to `skills/development/pr-review-checklist/SKILL.md`, write
   frontmatter and workflow.
7. No scripts needed; add one `examples/` file.
8–9. Follows the standard; includes workflow, I/O, examples.
10. `./scripts/validate-skills.sh` passes.
11. Explain how to symlink it into the user's runtime(s).

## Dependencies and compatibility notes

- Uses `templates/SKILL-template.md` and `scripts/validate-skills.sh` from this
  repo.
- Pairs with [`skill-discovery`](../skill-discovery/SKILL.md) (before) and
  [`skill-auditor`](../skill-auditor/SKILL.md) (ongoing review).
