#!/usr/bin/env bash
#
# install-skills.sh — expose EVERY skill in this repo to an agent runtime in one
# step, by linking (or copying) each skill into the runtime's skills directory.
#
# Why per-skill links instead of linking the whole skills/ tree?
#   Runtimes generally expect each skill as a direct child of their skills dir,
#   i.e. <dest>/<skill-name>/SKILL.md — with NO intermediate category folders.
#   This repo groups skills under categories (skills/meta/, skills/development/…).
#   So this script "flattens" by creating one link per skill:
#       <dest>/<skill-name>  ->  <repo>/skills/<category>/<skill-name>
#   That layout is correct whether or not the runtime scans recursively.
#
# Usage:
#   scripts/install-skills.sh --claude            # user-level: ALL projects (~/.claude/skills)
#   scripts/install-skills.sh --claude-project    # this repo only  (./.claude/skills)
#   scripts/install-skills.sh --codex             # ~/.codex/skills  (PATH UNVERIFIED — see below)
#   scripts/install-skills.sh --dest <path>       # any custom skills directory
#
# Options:
#   --copy        Copy skill directories instead of symlinking (for sandboxes /
#                 systems without symlink support). Copies are NOT auto-updated.
#   --uninstall   Remove links/copies this script created (safe: only removes
#                 symlinks that point back into THIS repo, or copies it recognizes).
#   --dry-run     Print what would happen without changing anything.
#   -h, --help    Show this help.
#
# Safety:
#   - Never overwrites an existing real directory/file at the destination; it
#     warns and skips so your own skills are never clobbered.
#   - Uninstall only removes entries that point into this repo.
#
# NOTE on runtime paths: the Claude Code paths below are the conventional ones;
# verify them for your version. The Codex path is a PLACEHOLDER and UNVERIFIED —
# pass the real location with --dest once you confirm it. See
# docs/agent-compatibility.md.

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"

MODE="symlink"
ACTION="install"
DRY_RUN=0
DEST=""

usage() { sed -n '2,38p' "$0" | sed 's/^# \{0,1\}//'; }

die() { printf 'ERROR: %s\n' "$1" >&2; exit 1; }

# --- parse args ---
while [ $# -gt 0 ]; do
  case "$1" in
    --claude)          DEST="$HOME/.claude/skills" ;;
    --claude-project)  DEST="$PWD/.claude/skills" ;;
    --codex)           DEST="$HOME/.codex/skills" ;;   # UNVERIFIED placeholder
    --dest)            shift; [ $# -gt 0 ] || die "--dest needs a path"; DEST="$1" ;;
    --copy)            MODE="copy" ;;
    --uninstall)       ACTION="uninstall" ;;
    --dry-run)         DRY_RUN=1 ;;
    -h|--help)         usage; exit 0 ;;
    *)                 die "unknown argument: $1 (try --help)" ;;
  esac
  shift
done

[ -n "$DEST" ] || { usage; echo; die "no target given (use --claude, --claude-project, --codex, or --dest <path>)"; }
[ -d "$SKILLS_DIR" ] || die "skills directory not found: $SKILLS_DIR"

run() {  # echo + execute, respecting --dry-run
  if [ "$DRY_RUN" -eq 1 ]; then printf 'DRY-RUN: %s\n' "$*"; else "$@"; fi
}

printf '%s skills\n  from: %s\n  to:   %s\n  mode: %s%s\n\n' \
  "$([ "$ACTION" = uninstall ] && echo Uninstalling || echo Installing)" \
  "$SKILLS_DIR" "$DEST" "$MODE" \
  "$([ "$DRY_RUN" -eq 1 ] && echo '  (dry-run)')"

if [ "$ACTION" = install ]; then
  run mkdir -p "$DEST" || die "cannot create destination: $DEST"
fi

installed=0; skipped=0; removed=0

# Iterate every skill (each dir containing a SKILL.md).
skill_files=$(find "$SKILLS_DIR" -type f -name 'SKILL.md' | sort)
[ -n "$skill_files" ] || die "no SKILL.md files found under $SKILLS_DIR"

while IFS= read -r file; do
  [ -z "$file" ] && continue
  skill_path="$(dirname "$file")"
  name="$(basename "$skill_path")"
  target="$DEST/$name"

  if [ "$ACTION" = uninstall ]; then
    if [ -L "$target" ]; then
      # Only remove symlinks that resolve into this repo.
      resolved="$(cd "$(dirname "$target")" && readlink "$target" 2>/dev/null)"
      case "$resolved" in
        "$SKILLS_DIR"/*|"$skill_path") run rm "$target"; printf 'removed link: %s\n' "$name"; removed=$((removed+1)) ;;
        *) printf 'skip (link not into this repo): %s\n' "$name"; skipped=$((skipped+1)) ;;
      esac
    elif [ -d "$target" ] && [ -f "$target/.installed-from" ] && grep -qxF "$skill_path" "$target/.installed-from" 2>/dev/null; then
      run rm -rf "$target"; printf 'removed copy: %s\n' "$name"; removed=$((removed+1))
    elif [ -e "$target" ]; then
      printf 'skip (not installed by this script): %s\n' "$name"; skipped=$((skipped+1))
    fi
    continue
  fi

  # install
  if [ -L "$target" ]; then
    run rm "$target"            # refresh an existing link we (or user) made
  elif [ -e "$target" ]; then
    printf 'SKIP %s: a real file/dir already exists at %s (not overwriting)\n' "$name" "$target" >&2
    skipped=$((skipped+1)); continue
  fi

  if [ "$MODE" = symlink ]; then
    run ln -s "$skill_path" "$target"
  else
    run cp -R "$skill_path" "$target"
    [ "$DRY_RUN" -eq 1 ] || printf '%s\n' "$skill_path" > "$target/.installed-from"
  fi
  printf '%s %s\n' "$([ "$MODE" = symlink ] && echo linked || echo copied)" "$name"
  installed=$((installed+1))
done <<EOF
$skill_files
EOF

printf '\nDone. '
if [ "$ACTION" = uninstall ]; then
  printf 'removed=%d, skipped=%d\n' "$removed" "$skipped"
else
  printf 'installed=%d, skipped=%d\n' "$installed" "$skipped"
fi
