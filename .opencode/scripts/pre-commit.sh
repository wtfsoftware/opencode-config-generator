#!/usr/bin/env bash
# =============================================================================
# Pre-commit hook: Validate all skills before committing
# Install: cp .opencode/scripts/pre-commit.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
# =============================================================================

set -uo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

SKILLS_DIR=".opencode/skills"
errors=0

echo -e "${BOLD}Validating skills before commit...${NC}"

# Only check changed skills
changed_files=$(git diff --cached --name-only -- "$SKILLS_DIR" 2>/dev/null || echo "")

if [[ -z "$changed_files" ]]; then
  # No skill changes, check all
  skill_dirs=$(ls -d "$SKILLS_DIR"/*/ 2>/dev/null || echo "")
else
  # Extract changed skill directories
  skill_dirs=""
  for f in $changed_files; do
    dir=$(echo "$f" | cut -d'/' -f1-3)
    if [[ -d "$dir" ]] && [[ ! " $skill_dirs " =~ " $dir " ]]; then
      skill_dirs="$skill_dirs $dir"
    fi
  done
fi

for skill_dir in $skill_dirs; do
  [[ -d "$skill_dir" ]] || continue
  
  skill_name=$(basename "$skill_dir")
  skill_file="$skill_dir/SKILL.md"
  
  # Check SKILL.md exists
  if [[ ! -f "$skill_file" ]]; then
    echo -e "  ${RED}✗${NC} $skill_name: SKILL.md not found"
    ((errors++))
    continue
  fi
  
  # Check frontmatter
  if ! head -1 "$skill_file" | grep -q '^---'; then
    echo -e "  ${RED}✗${NC} $skill_name: Missing frontmatter"
    ((errors++))
  fi
  
  # Check required fields
  for field in "name:" "description:" "license:" "compatibility:"; do
    if ! grep -q "$field" "$skill_file"; then
      echo -e "  ${RED}✗${NC} $skill_name: Missing field: $field"
      ((errors++))
    fi
  done
  
  # Check required sections
  for section in "## What I Do" "## When to Use Me" "## Quality Checklist"; do
    if ! grep -q "$section" "$skill_file"; then
      echo -e "  ${RED}✗${NC} $skill_name: Missing section: $section"
      ((errors++))
    fi
  done
  
  # Check name matches directory
  name_in_file=$(grep -m1 '^name:' "$skill_file" | sed 's/^name: *//' | tr -d '[:space:]')
  if [[ "$name_in_file" != "$skill_name" ]]; then
    echo -e "  ${RED}✗${NC} $skill_name: Name mismatch ('$name_in_file' != '$skill_name')"
    ((errors++))
  fi
  
  # Check name format
  if ! echo "$skill_name" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
    echo -e "  ${RED}✗${NC} $skill_name: Invalid name format"
    ((errors++))
  fi
  
  # Check code blocks are closed
  open_backticks=$(grep -c '```' "$skill_file" || true)
  if [[ $((open_backticks % 2)) -ne 0 ]]; then
    echo -e "  ${RED}✗${NC} $skill_name: Unclosed code block"
    ((errors++))
  fi
done

if [[ $errors -gt 0 ]]; then
  echo ""
  echo -e "${RED}${BOLD}Commit blocked: $errors error(s) found in skills.${NC}"
  exit 1
fi

echo -e "  ${GREEN}✓${NC} All skills valid"
exit 0
