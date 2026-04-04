#!/usr/bin/env bash
# =============================================================================
# Validate all SKILL.md files for correct frontmatter and structure
# Usage: ./validate-skills.sh [skills-directory]
# =============================================================================

set -uo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

CHECK="${GREEN}✓${NC}"
CROSS="${RED}✗${NC}"
WARN="${YELLOW}⚠${NC}"

SKILLS_DIR="${1:-$HOME/.config/opencode/skills}"

if [[ ! -d "$SKILLS_DIR" ]]; then
  echo -e "${CROSS} ${RED}Skills directory not found: $SKILLS_DIR${NC}"
  exit 1
fi

echo -e "${BOLD}Validating skills in:${NC} $SKILLS_DIR"
echo ""

total=0
passed=0
failed=0
warnings=0

for skill_dir in "$SKILLS_DIR"/*/; do
  [[ -d "$skill_dir" ]] || continue
  
  skill_name="$(basename "$skill_dir")"
  skill_file="$skill_dir/SKILL.md"
  ((total++))
  
  errors=()
  warns=()
  
  # Check SKILL.md exists
  if [[ ! -f "$skill_file" ]]; then
    errors+=("SKILL.md not found")
  else
    # Check frontmatter exists
    if ! head -1 "$skill_file" | grep -q '^---'; then
      errors+=("Missing frontmatter opening (---)")
    fi
    
    # Check required frontmatter fields
    for field in "name:" "description:" "license:" "compatibility:"; do
      if ! grep -q "$field" "$skill_file"; then
        errors+=("Missing frontmatter field: $field")
      fi
    done
    
    # Check metadata fields
    for field in "audience:" "workflow:" "category:"; do
      if ! grep -q "$field" "$skill_file"; then
        warns+=("Missing metadata field: $field")
      fi
    done
    
    # Check required sections
    for section in "## What I Do" "## When to Use Me" "## Quality Checklist"; do
      if ! grep -q "$section" "$skill_file"; then
        errors+=("Missing section: $section")
      fi
    done
    
    # Check name matches directory
    name_in_file=$(grep -m1 '^name:' "$skill_file" | sed 's/^name: *//' | tr -d '[:space:]')
    if [[ "$name_in_file" != "$skill_name" ]]; then
      errors+=("Name mismatch: file says '$name_in_file', directory is '$skill_name'")
    fi
    
    # Check name format (lowercase, hyphens)
    if ! echo "$skill_name" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
      errors+=("Invalid name format: '$skill_name' (must be lowercase alphanumeric with hyphens)")
    fi
    
    # Check description length
    desc=$(grep -m1 '^description:' "$skill_file" | sed 's/^description: *//')
    word_count=$(echo "$desc" | wc -w)
    if [[ $word_count -lt 10 ]]; then
      warns+=("Short description: $word_count words (min 10 recommended)")
    fi
    
    # Check for code examples
    if ! grep -q '```' "$skill_file"; then
      warns+=("No code examples found")
    fi
    
    # Check checklist items
    checklist_count=$(grep -c '^\- \[ \]' "$skill_file" || true)
    if [[ $checklist_count -lt 8 ]]; then
      warns+=("Few checklist items: $checklist_count (8+ recommended)")
    fi
    
    # Check file size
    line_count=$(wc -l < "$skill_file")
    if [[ $line_count -lt 200 ]]; then
      warns+=("Short file: $line_count lines (200+ recommended)")
    fi
  fi
  
  # Output result
  if [[ ${#errors[@]} -eq 0 ]] && [[ ${#warns[@]} -eq 0 ]]; then
    echo -e "  ${CHECK} ${BOLD}$skill_name${NC} ${GREEN}(valid)${NC}"
    ((passed++))
  elif [[ ${#errors[@]} -eq 0 ]]; then
    echo -e "  ${WARN} ${BOLD}$skill_name${NC} ${YELLOW}(${#warns[@]} warning(s))${NC}"
    for w in "${warns[@]}"; do
      echo -e "      ${YELLOW}• $w${NC}"
    done
    ((warnings++))
    ((passed++))
  else
    echo -e "  ${CROSS} ${BOLD}$skill_name${NC} ${RED}(${#errors[@]} error(s))${NC}"
    for e in "${errors[@]}"; do
      echo -e "      ${RED}• $e${NC}"
    done
    for w in "${warns[@]}"; do
      echo -e "      ${YELLOW}• $w${NC}"
    done
    ((failed++))
  fi
done

echo ""
echo -e "${BOLD}Results:${NC} $total skills checked"
echo -e "  ${CHECK} ${BOLD}$passed${NC} passed"
echo -e "  ${CROSS} ${BOLD}$failed${NC} failed"
echo -e "  ${WARN} ${BOLD}$warnings${NC} with warnings"

[[ $failed -gt 0 ]] && exit 1
