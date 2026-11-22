#!/usr/bin/env bash
#
# validate-skills.sh — structural and metadata checks for the skills library.
#
# Checks:
#   - Every skill directory has a SKILL.md.
#   - SKILL.md has YAML frontmatter (delimited by --- ... ---).
#   - Required `name` and `description` fields are present and non-empty.
#   - `name` matches the skill's directory name.
#   - No duplicate skill names across the repo.
#   - Referenced local supporting files exist (best-effort).
#
# Uses only standard POSIX tools (bash, grep, sed, find, sort). `yq` is NOT
# required; if present it is not relied upon. Exits non-zero if any error found.

set -u

# Resolve repo root (parent of this script's directory).
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"

errors=0
warnings=0

err()  { printf 'ERROR: %s\n'   "$1" >&2; errors=$((errors + 1)); }
warn() { printf 'WARN:  %s\n'   "$1" >&2; warnings=$((warnings + 1)); }
ok()   { printf 'OK:    %s\n'   "$1"; }

if [ ! -d "$SKILLS_DIR" ]; then
  err "skills directory not found at: $SKILLS_DIR"
  exit 1
fi

# Extract the YAML frontmatter block (text between the first two '---' lines).
frontmatter() {
  # $1 = file
  awk 'NR==1 && $0!="---"{exit} /^---[[:space:]]*$/{c++; if(c==2) exit; next} c==1{print}' "$1"
}

# Read a scalar field value from frontmatter text on stdin.
# $1 = field name. Prints the trimmed value (quotes stripped).
field_value() {
  grep -E "^$1:" | head -n1 | sed -E "s/^$1:[[:space:]]*//; s/^[\"']//; s/[\"'][[:space:]]*$//; s/[[:space:]]+$//"
}

# Collect all SKILL.md files.
skill_files=$(find "$SKILLS_DIR" -type f -name 'SKILL.md' | sort)

if [ -z "$skill_files" ]; then
  warn "No SKILL.md files found under $SKILLS_DIR"
fi

# Warn about skill-like directories missing a SKILL.md: any leaf directory under
# skills/<category>/ that has no SKILL.md.
while IFS= read -r dir; do
  [ -z "$dir" ] && continue
  if [ ! -f "$dir/SKILL.md" ]; then
    # Only flag directories that look like skill dirs (depth >= 2 below skills/).
    rel="${dir#"$SKILLS_DIR"/}"
    case "$rel" in
      */*) err "Skill directory has no SKILL.md: $rel" ;;
    esac
  fi
done <<EOF
$(find "$SKILLS_DIR" -mindepth 2 -type d | sort)
EOF

names_seen=""

while IFS= read -r file; do
  [ -z "$file" ] && continue
  rel="${file#"$REPO_ROOT"/}"
  dir="$(dirname "$file")"
  dir_name="$(basename "$dir")"

  fm="$(frontmatter "$file")"
  if [ -z "$fm" ]; then
    err "$rel: missing or empty YAML frontmatter (expected '---' delimited block)"
    continue
  fi

  name="$(printf '%s\n' "$fm" | field_value name)"
  desc="$(printf '%s\n' "$fm" | field_value description)"

  if [ -z "$name" ]; then
    err "$rel: required field 'name' is missing or empty"
  fi
  if [ -z "$desc" ]; then
    err "$rel: required field 'description' is missing or empty"
  fi

  if [ -n "$name" ] && [ "$name" != "$dir_name" ]; then
    err "$rel: name '$name' does not match directory name '$dir_name'"
  fi

  if [ -n "$name" ]; then
    case " $names_seen " in
      *" $name "*) err "$rel: duplicate skill name '$name'";;
      *) names_seen="$names_seen $name";;
    esac
  fi

  # Best-effort: check markdown links to local files relative to the skill dir.
  # Looks for (path) targets that are not URLs/anchors and resolves them.
  links="$(grep -oE '\]\(([^)]+)\)' "$file" 2>/dev/null | sed -E 's/^\]\(//; s/\)$//')"
  while IFS= read -r link; do
    [ -z "$link" ] && continue
    case "$link" in
      http://*|https://*|mailto:*|\#*) continue ;;  # skip URLs and anchors
    esac
    target="${link%%#*}"          # strip any #anchor
    [ -z "$target" ] && continue
    if [ ! -e "$dir/$target" ]; then
      warn "$rel: referenced file not found: $target"
    fi
  done <<INNER
$links
INNER

  [ -n "$name" ] && [ -n "$desc" ] && ok "$rel ($name)"
done <<EOF
$skill_files
EOF

printf '\n'
if [ "$errors" -gt 0 ]; then
  printf 'FAILED: %d error(s), %d warning(s).\n' "$errors" "$warnings" >&2
  exit 1
fi
printf 'PASSED: 0 errors, %d warning(s).\n' "$warnings"
exit 0
