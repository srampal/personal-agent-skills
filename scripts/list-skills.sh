#!/usr/bin/env bash
#
# list-skills.sh — enumerate all skills and their descriptions.
#
# Prints, grouped by category, each skill's name and description read from the
# YAML frontmatter of its SKILL.md. Uses only standard POSIX tools.

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"

if [ ! -d "$SKILLS_DIR" ]; then
  printf 'No skills directory at: %s\n' "$SKILLS_DIR" >&2
  exit 1
fi

frontmatter() {
  awk 'NR==1 && $0!="---"{exit} /^---[[:space:]]*$/{c++; if(c==2) exit; next} c==1{print}' "$1"
}

field_value() {
  grep -E "^$1:" | head -n1 | sed -E "s/^$1:[[:space:]]*//; s/^[\"']//; s/[\"'][[:space:]]*$//; s/[[:space:]]+$//"
}

skill_files=$(find "$SKILLS_DIR" -type f -name 'SKILL.md' | sort)

if [ -z "$skill_files" ]; then
  printf 'No skills found under %s\n' "$SKILLS_DIR"
  exit 0
fi

count=0
last_category=""

printf 'Skills in %s\n' "${SKILLS_DIR#"$REPO_ROOT"/}"
printf '====================================\n'

while IFS= read -r file; do
  [ -z "$file" ] && continue
  rel="${file#"$SKILLS_DIR"/}"            # e.g. meta/skill-creator/SKILL.md
  category="${rel%%/*}"                    # e.g. meta

  fm="$(frontmatter "$file")"
  name="$(printf '%s\n' "$fm" | field_value name)"
  desc="$(printf '%s\n' "$fm" | field_value description)"
  [ -z "$name" ] && name="$(basename "$(dirname "$file")") (missing name)"
  [ -z "$desc" ] && desc="(no description)"

  if [ "$category" != "$last_category" ]; then
    printf '\n[%s]\n' "$category"
    last_category="$category"
  fi

  printf '  - %s\n      %s\n' "$name" "$desc"
  count=$((count + 1))
done <<EOF
$skill_files
EOF

printf '\n%d skill(s) total.\n' "$count"
