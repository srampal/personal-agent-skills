# Task: Create my personal-agent-skills repository

Act as a senior AI agent infrastructure architect and repository maintainer. I want you to create the initial version of a GitHub-backed, agent-independent personal skills library.

The repository should be designed to work across multiple AI coding agents and agent runtimes, including:

- Claude Code
- OpenAI Codex
- OpenClaw
- Hermes
- Other agents that support the Agent Skills standard

The goal is to maintain one canonical collection of reusable skills that can be shared across different agents without having to maintain separate copies of each skill.

**Important: Create the repository and its files on my local filesystem. Do not merely describe what I should create.**

## 1. Repository name and location

Create a directory named:

`personal-agent-skills`

Use the current working directory as its parent.

If the directory already exists:
- Inspect its contents first.
- Do not overwrite or delete existing files.
- Preserve existing work.
- Report any conflicts and determine a safe way to proceed.

Initialize it as a Git repository if it is not already one.

Do not create a GitHub repository or push anything remotely. I will handle that separately.

## 2. Architectural principles

Follow these principles throughout the repository design.

### Agent independence

- Use the Agent Skills standard wherever possible.
- Each skill should be self-contained and portable.
- Do not make Claude Code, Codex, OpenClaw, or any other particular agent a hard dependency.
- Avoid embedding agent-specific assumptions in the core skill instructions.
- Where runtime-specific integration is necessary, document it separately.

### Reusability

Skills should describe repeatable workflows, procedures, expertise, or capabilities that can be reused across projects.

They should not simply be collections of generic prompts.

### Modularity

Each skill should have a clear purpose and scope.

Avoid creating large, monolithic skills that attempt to solve unrelated problems.

### Safety

- Never automatically install or execute third-party skills.
- Do not include credentials, tokens, API keys, or other secrets.
- Skills that execute commands must explain potentially destructive operations.
- Prefer inspection and validation before modification.
- Require explicit user approval for destructive or security-sensitive operations.

### Extensibility

Make it easy to add new skills without modifying the overall repository architecture.

Do not implement a capability registry yet. The repository should be designed so that a capability registry could be added later to discover and index skills automatically.

## 3. Initial repository structure

Create a sensible structure along these lines. You may make small improvements if there is a good architectural reason.

```text
personal-agent-skills/
├── README.md
├── CONTRIBUTING.md
├── LICENSE
├── .gitignore
│
├── skills/
│   ├── meta/
│   │   ├── skill-discovery/
│   │   │   └── SKILL.md
│   │   ├── skill-creator/
│   │   │   └── SKILL.md
│   │   └── skill-auditor/
│   │       └── SKILL.md
│   │
│   ├── development/
│   │   └── git-worktree-management/
│   │       └── SKILL.md
│   │
│   └── infrastructure/
│       └── kubernetes-troubleshooting/
│           └── SKILL.md
│
├── templates/
│   └── SKILL-template.md
│
├── scripts/
│   ├── validate-skills.sh
│   └── list-skills.sh
│
└── docs/
    ├── architecture.md
    ├── agent-compatibility.md
    └── adding-a-skill.md
```

You can add supporting files, examples, or reference material inside individual skill directories when useful.

## 4. Create the three meta-skills

These are especially important. They should help me maintain and grow the library over time.

### A. skill-discovery

Purpose: Before creating a new skill, investigate whether an equivalent or better capability already exists.

The skill should guide an agent through the following process:

1. Understand the user's requested task and desired outcome.
2. Determine whether the task actually requires a dedicated skill.
3. Inspect the current agent's available capabilities, including:
   - Built-in skills.
   - Installed third-party skills.
   - MCP servers and tools.
   - Plugins and integrations.
   - Existing personal skills.
   - Project-specific instructions.
   - General agent/model capabilities.
4. Where appropriate, investigate trusted external skill repositories and documentation.
5. Compare existing implementations with the requested capability.
6. Evaluate differences in:
   - Functionality.
   - Quality and completeness.
   - Dependencies.
   - Agent/runtime compatibility.
   - Security and permissions.
   - Maintenance and provenance.
7. Recommend one of these outcomes:
   - Reuse an existing capability.
   - Extend an existing skill.
   - Create a new skill.
   - No dedicated skill is necessary.

Do not assume that a skill installed in one agent runtime is available in another.

Clearly distinguish between a capability that an agent can perform generally and a dedicated skill that provides a repeatable, documented workflow.

Do not automatically install external skills.

### B. skill-creator

Purpose: Create high-quality, reusable skills that follow the Agent Skills standard.

The skill should:

1. Understand the intended purpose and target users of a proposed skill.
2. Check whether an equivalent skill already exists.
3. Identify the workflow, assumptions, inputs, outputs, dependencies and limitations.
4. Design the skill with a clear and appropriately scoped responsibility.
5. Create a valid `SKILL.md` with appropriate YAML frontmatter.
6. Add supporting scripts, references or examples only when justified.
7. Keep the main instructions concise and move detailed reference material into separate files when appropriate.
8. Validate the resulting skill.
9. Explain how to use it and how it can be installed or exposed to different agent runtimes.

The skill should follow the official Agent Skills specification rather than inventing its own format.

Include guidance for writing:
- Clear skill descriptions that support discovery.
- Explicit instructions and workflows.
- Input/output expectations.
- Error handling.
- Security considerations.
- Examples of correct usage.

When creating a new skill, use the repository's `templates/SKILL-template.md` as a starting point.

### C. skill-auditor

Purpose: Review the existing personal skills library periodically and identify opportunities to improve it.

The skill should inspect:

- Duplicate or overlapping skills.
- Skills that have become outdated.
- Broken references or missing supporting files.
- Incorrect or incomplete Agent Skills metadata.
- Unnecessary complexity.
- Runtime-specific assumptions that reduce portability.
- Dependencies that may no longer be available.
- Potential security problems.
- Skills that should be consolidated, split, improved or retired.

It should also identify cases where a better built-in, third-party or integrated capability might already exist.

Produce a Markdown audit report with:
- Findings.
- Severity or priority.
- Affected skills.
- Recommended actions.
- Whether human approval is needed.

Do not automatically delete, replace or substantially modify skills. Make recommendations and wait for approval.

## 5. Create two example skills

These should be real, useful skills, not just skeletons.

They should also demonstrate how I should structure future skills.

### A. git-worktree-management

Purpose: Help an agent safely manage Git worktrees when working on multiple tasks or branches.

Include workflows for:

- Understanding the current repository and working directory.
- Inspecting existing branches and worktrees.
- Creating a new worktree for an independent task.
- Creating or selecting an appropriate branch.
- Avoiding accidental modifications to the original working tree.
- Verifying the active worktree and branch before making changes.
- Working independently in multiple worktrees.
- Committing changes.
- Cleaning up completed worktrees safely.
- Handling uncommitted changes and merge conflicts.

Emphasize safety and verification.

The skill should encourage agents to inspect the repository state before executing commands and never blindly delete a worktree or branch.

Include practical command examples.

### B. kubernetes-troubleshooting

Purpose: Provide a systematic, reusable workflow for diagnosing Kubernetes and OpenShift problems.

The skill should cover:

- Understanding the reported symptom.
- Establishing the affected cluster, namespace, workload and resources.
- Inspecting pods, deployments, services, endpoints, events and logs.
- Checking resource constraints and scheduling.
- Investigating networking, DNS, ingress and Gateway API issues when relevant.
- Inspecting configuration, secrets references and service accounts without exposing secret values.
- Understanding operator-managed resources.
- Forming and testing hypotheses.
- Identifying root cause rather than merely suggesting restarts.
- Producing a concise diagnosis and recommended remediation.

Use a progressive troubleshooting methodology:
1. Gather facts.
2. Establish the scope.
3. Identify likely failure domains.
4. Test hypotheses.
5. Determine root cause.
6. Recommend remediation.
7. Verify recovery.

The skill should work with standard Kubernetes environments and include OpenShift-specific considerations where useful.

Do not assume that every environment has the same tools, permissions, CRDs or networking implementation.

Prefer read-only diagnostic commands initially. Clearly identify commands that modify cluster state and require user approval.

## 6. Create a reusable skill template

Create `templates/SKILL-template.md`.

It should provide a practical starting point for future skills, including:

- YAML frontmatter (`name`, `description`).
- Purpose.
- When to use this skill.
- When not to use it.
- Inputs and prerequisites.
- Workflow.
- Validation and expected outcomes.
- Error handling.
- Safety considerations.
- Examples.
- Dependencies and compatibility notes.

Do not make every section mandatory if it does not apply to a particular skill.

The template should follow the Agent Skills specification and distinguish required metadata from optional documentation sections.

## 7. Documentation

Create the following documentation.

### README.md

Explain:
- What this repository is.
- Why it is agent-independent.
- How the repository is organized.
- How to use the skills.
- How to add new skills.
- How to validate the repository.
- How agent-specific installation will work.

Include examples of using the skills with different agents, but do not claim that every agent automatically discovers skills from this repository.

### CONTRIBUTING.md

Explain the expected standards for adding, modifying, reviewing and retiring skills.

### docs/architecture.md

Document the architectural principles and design decisions.

Explicitly explain the separation between:
- Portable skill definitions.
- Agent-specific adapters and installation mechanisms.
- Agent memory systems.
- A future capability registry.

Explain that the skills repository is the canonical source of truth.

### docs/agent-compatibility.md

Describe how the same canonical skill library can be exposed to Claude Code, Codex, OpenClaw, Hermes and other compatible runtimes.

Explain:
- Symlinks.
- Copy-based installation.
- Runtime-specific skill directories.
- Differences in skill discovery and supported features.
- Why runtime-specific adaptations should not contaminate the portable skill definition.

Do not invent configuration paths or claim compatibility features without verifying them. Mark anything that needs runtime-specific verification.

### docs/adding-a-skill.md

Provide a step-by-step guide for creating a new skill, using the template and `skill-creator` meta-skill.

## 8. Validation scripts

Create simple scripts to help maintain the repository.

`validate-skills.sh` should check at least:

- Every skill directory has a `SKILL.md`.
- YAML frontmatter exists.
- Required `name` and `description` fields are present.
- Skill names and directory names are consistent.
- No duplicate skill names exist.
- Referenced supporting files exist where practical.

Use available standard tools and clearly report any optional dependencies.

`list-skills.sh` should enumerate the skills and their descriptions.

Do not build an elaborate framework or capability registry as part of this initial implementation.

## 9. Git and initial commit

After creating the files:

1. Run the validation script.
2. Inspect the resulting directory tree.
3. Review the contents of all five initial skills.
4. Fix any problems found.
5. Initialize Git if needed.
6. Make an initial commit with a meaningful message, but only if the working tree is safe to commit and there are no unrelated pre-existing changes.

Do not configure a remote.

## 10. Final report

When finished, report:

1. The absolute path of the created repository.
2. The directory structure.
3. A brief description of each of the five initial skills.
4. Validation results.
5. Git initialization and commit status.
6. Any assumptions or limitations.
7. The recommended next steps for connecting the repository to Claude Code and Codex, followed by OpenClaw and Hermes.

## Important implementation guidance

Work incrementally. Inspect before modifying. Make actual files rather than merely describing them.

Prioritize a clean, understandable and maintainable foundation over sophistication.

Do not implement:
- A capability registry.
- An MCP server.
- An automated discovery daemon.
- A centralized agent memory service.
- Complex CI/CD infrastructure.

Those can be introduced later.

The immediate goal is a high-quality, portable personal skills library that I can start using today and expand over time.

