# Adding a skill

A step-by-step guide for adding a new skill to the library, using the template
and the meta-skills.

## Prerequisites

- You have read [`../CONTRIBUTING.md`](../CONTRIBUTING.md).
- You can run the scripts in `scripts/` (POSIX shell).

## Steps

### 1. Confirm you actually need a new skill

Run the [`skill-discovery`](../skills/meta/skill-discovery/SKILL.md) meta-skill.
It checks whether an equivalent capability already exists (built-in, MCP tool,
plugin, project instruction, or an existing skill here) and recommends whether to
**reuse**, **extend**, **create**, or do **nothing**. Only continue if the
recommendation is *create*.

### 2. Choose a category and name

- Category: an existing directory under `skills/` (`meta`, `development`,
  `infrastructure`, …) or a new one if none fits.
- Name: lowercase, hyphen-separated, unique across the repo. **The directory name
  must exactly match the `name` in the frontmatter.**

```bash
mkdir -p skills/<category>/<skill-name>
```

### 3. Start from the template

```bash
cp templates/SKILL-template.md skills/<category>/<skill-name>/SKILL.md
```

### 4. Fill it in (using skill-creator)

Follow the [`skill-creator`](../skills/meta/skill-creator/SKILL.md) meta-skill to
write a well-scoped skill. At minimum:

- Set the **required** frontmatter: `name` (matching the directory) and a
  discovery-friendly `description`.
- Complete the applicable sections (purpose, when to use / not use, inputs,
  workflow, validation, error handling, safety, examples, dependencies).
- Delete sections that do not apply — do not leave empty placeholders.
- Keep `SKILL.md` concise; move long reference material into a `references/`
  subdirectory and link to it.

### 5. Add supporting files only if justified

- `scripts/` — helper scripts the skill runs.
- `references/` — detailed reference material.
- `examples/` — worked examples.

Make sure anything you reference actually exists.

### 6. Validate

```bash
./scripts/validate-skills.sh
./scripts/list-skills.sh
```

Fix anything the validator reports. Confirm the new skill appears in the listing
with the right description.

### 7. Review for safety and portability

- No secrets anywhere.
- Destructive commands clearly marked and gated on approval.
- No runtime-specific assumptions baked into the instructions (keep those in
  [`agent-compatibility.md`](agent-compatibility.md)).

### 8. Commit

Make a focused commit with a meaningful message. Do not push to a remote unless
the owner asks.

### 9. Expose it to your runtime(s) (optional)

Symlink or copy the skill into your agent runtime's skills directory — see
[`agent-compatibility.md`](agent-compatibility.md). Remember discovery is
runtime-specific.

## Checklist

- [ ] `skill-discovery` confirmed a new skill is the right call.
- [ ] Directory name matches `name`.
- [ ] Required frontmatter present; `description` is discovery-friendly.
- [ ] Workflow is explicit and ordered.
- [ ] Destructive steps marked; approval required.
- [ ] No secrets; references resolve.
- [ ] `validate-skills.sh` passes; skill shows in `list-skills.sh`.
