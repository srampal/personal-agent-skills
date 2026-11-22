---
name: git-worktree-management
description: Safely create, use, and clean up Git worktrees when working on multiple branches or tasks in parallel — always inspecting repository state first, verifying the active worktree and branch before changing anything, and never blindly deleting a worktree or branch.
---

# Git Worktree Management

## Purpose

Let an agent work on multiple branches or tasks at once using Git worktrees,
without risking the original working tree. The emphasis throughout is
**inspection and verification before action**, so changes always land in the
intended worktree and branch.

## When to use this skill

- You need to work on a second branch without disturbing the current checkout.
- You are running parallel tasks (e.g. a fix and a feature) in one repository.
- You need an isolated checkout for a review, build, or experiment.

## When NOT to use this skill

- A simple `git switch`/`git checkout` on a clean tree is enough.
- The repository is a shallow/bare clone where worktrees are not appropriate.

## Inputs and prerequisites

- A Git repository (Git ≥ 2.5; `git worktree` features assume ≥ 2.17).
- Permission to create directories alongside (or outside) the repository.
- Knowledge of (or ability to discover) the branch you want to work on.

## Workflow

> **Safety first:** every step begins by inspecting state. Never assume which
> worktree or branch you are in.

### 1. Understand the current repository and working directory

```bash
git rev-parse --show-toplevel     # repo root (fails if not in a repo)
git rev-parse --is-inside-work-tree
pwd
```

### 2. Inspect existing branches and worktrees

```bash
git worktree list                 # all worktrees and their branches
git branch --all                  # local + remote branches
git status                        # is the current tree clean?
```

Note any worktree that already has the branch you want checked out — a branch can
only be checked out in one worktree at a time.

### 3. Handle uncommitted changes before branching off

If `git status` shows uncommitted changes in the current tree, decide
deliberately (ask the user if unsure):

```bash
git stash push -m "wip before new worktree"   # set aside, OR
git add -A && git commit -m "wip"             # commit, OR
# leave them — creating a NEW worktree does not touch the current one
```

Creating a new worktree does not modify your current tree, but resolve WIP first
if the new work depends on it.

### 4. Create or select a branch, and create the worktree

Create a worktree with a **new** branch:

```bash
# Places a new worktree in a sibling directory and creates branch feature/x
git worktree add ../myrepo-feature-x -b feature/x
```

Create a worktree for an **existing** branch:

```bash
git worktree add ../myrepo-review origin/feature/y   # detached or tracking
# or check out an existing local branch (must not be in use elsewhere):
git worktree add ../myrepo-feature-y feature/y
```

Prefer placing worktrees **outside** the main working tree (a sibling directory)
to avoid confusing tooling and nested-repo issues.

### 5. Verify the active worktree and branch BEFORE making changes

```bash
cd ../myrepo-feature-x
git rev-parse --show-toplevel     # confirm you are in the new worktree
git branch --show-current         # confirm the expected branch
git status
```

Only proceed to edit files once both the path and branch are confirmed. This is
the single most important safety check — it prevents accidental edits to the
original tree.

### 6. Work independently in multiple worktrees

- Each worktree has its own working directory and index but shares the same
  `.git` object store.
- You can edit, build, and test in each worktree independently.
- Re-run the step-5 verification whenever you switch between worktree
  directories.

### 7. Commit changes

```bash
git add -A
git status                         # review what will be committed
git commit -m "Describe the change"
```

Commit in the worktree where the work was done; confirm the branch first.

### 8. Clean up a completed worktree safely

```bash
git -C ../myrepo-feature-x status  # ⚠️ confirm no uncommitted/unpushed work
git worktree remove ../myrepo-feature-x
git worktree prune                 # tidy stale administrative entries
```

- `git worktree remove` refuses to remove a dirty worktree unless `--force` is
  added. **Do not add `--force` without explicit user approval** — it discards
  uncommitted work.
- Deleting the worktree does **not** delete its branch. Delete the branch
  separately and only when you are sure it is merged or no longer needed:

  ```bash
  git branch -d feature/x          # safe: refuses if unmerged
  # git branch -D feature/x        # ⚠️ force-deletes even if unmerged — approval required
  ```

### 9. Handle merge conflicts

Conflicts are resolved within the worktree where you merge/rebase. Inspect
first, resolve deliberately, and verify:

```bash
git status                         # see conflicted files
# edit files to resolve, then:
git add <resolved-files>
git merge --continue   # or: git rebase --continue
```

If unsure, stop and ask the user rather than guessing at a resolution.

## Validation and expected outcomes

- `git worktree list` shows the expected worktrees and branches.
- In each worktree, `git rev-parse --show-toplevel` and
  `git branch --show-current` match your intent.
- After cleanup, removed worktrees no longer appear and the branch state is as
  intended.

## Error handling

- **"fatal: '<branch>' is already checked out"** — the branch is in use by
  another worktree; pick a different branch or work in that worktree.
- **"fatal: not a git repository"** — you are outside a repo; `cd` into one.
- **`worktree remove` refuses (dirty)** — commit/stash or get explicit approval
  before using `--force`.
- Stale entries after a manual directory delete — run `git worktree prune`.

## Safety considerations

- ⚠️ `git worktree remove --force`, `git branch -D`, and discarding stashes are
  **destructive** — require explicit user approval and confirm there is no
  unsaved or unpushed work first.
- Always verify the active worktree and branch (step 5) before editing.
- Never delete a worktree or branch "to be safe" — inspect first.
- Prefer read-only inspection commands before any mutating command.

## Examples

Work on a hotfix without disturbing feature work in progress:

```bash
git worktree list
git worktree add ../app-hotfix -b hotfix/login origin/main
cd ../app-hotfix
git branch --show-current          # -> hotfix/login  (verified)
# ...make the fix, test...
git add -A && git commit -m "Fix login redirect"
cd -                               # back to original worktree, untouched
# after merge:
git -C ../app-hotfix status        # clean?
git worktree remove ../app-hotfix
git branch -d hotfix/login
```

## Dependencies and compatibility notes

- Requires Git (worktrees since 2.5; `worktree remove`/`list --porcelain` since
  2.17). No agent-specific dependencies.
- Portable across any runtime that can run shell commands.
