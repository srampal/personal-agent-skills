---
name: skill-name
description: One or two sentences stating what this skill does and when an agent should use it. Write for discovery — include the trigger conditions and the outcome. (REQUIRED)
---

<!--
  This is a template for the Agent Skills standard. Copy it into
  skills/<category>/<skill-name>/SKILL.md and edit.

  REQUIRED metadata: the YAML frontmatter above (`name`, `description`).
    - `name` MUST be lowercase-hyphenated and MUST match the directory name.
    - `description` drives discovery; make it specific.

  Everything below the frontmatter is OPTIONAL documentation. Keep the sections
  that apply to your skill and delete the rest — do not pad with empty sections.
  Keep instructions concise; move long reference material into references/ and
  link to it.
-->

# Skill Title

## Purpose

What problem this skill solves and the value it provides. One short paragraph.

## When to use this skill

- Concrete trigger conditions and situations where this skill applies.
- The kinds of tasks or requests that should invoke it.

## When NOT to use this skill

- Situations where a different skill, a built-in capability, or no skill at all
  is the better choice. This prevents misfires and overlap.

## Inputs and prerequisites

- Inputs the skill expects (arguments, context, files, access).
- Prerequisites: required tools, permissions, environment, or prior state.
- Assumptions the workflow makes.

## Workflow

Numbered, explicit steps the agent should follow. Be specific and ordered.

1. Inspect / gather facts before changing anything.
2. ...
3. ...

Include command examples where helpful:

```bash
# Example command (read-only / safe)
some-command --inspect
```

## Validation and expected outcomes

- How to confirm the skill succeeded.
- What the expected end state or output looks like.

## Error handling

- Common failure modes and how to respond to them.
- When to stop and ask the user rather than proceeding.

## Safety considerations

- Any destructive or state-changing operations, clearly marked.
- Which steps require explicit user approval.
- How secrets/sensitive data are handled (never exposed or committed).

## Examples

Worked example(s) showing correct usage end to end.

## Dependencies and compatibility notes

- External tools or services required, and how to detect their absence.
- Runtime/agent compatibility notes. Keep agent-specific details minimal here;
  portable instructions belong in the skill, runtime adapters are documented in
  docs/agent-compatibility.md.
- Mark anything that needs runtime-specific verification.
