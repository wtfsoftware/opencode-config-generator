#!/usr/bin/env bash
# =============================================================================
# Update all global skills from the ocskills repository
# Usage: ./update-skills.sh [ocskills-repo-path]
# =============================================================================

set -uo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

CHECK="${GREEN}✓${NC}"
CROSS="${RED}✗${NC}"
WARN="${YELLOW}⚠${NC}"
ARROW="${CYAN}→${NC}"

SKILLS_DIR="$HOME/.config/opencode/skills"
SOURCE_DIR="${1:-}"

# Auto-detect source
if [[ -z "$SOURCE_DIR" ]]; then
  for path in \
    "$HOME/Documents/VSCode Projects/ocskills" \
    "$HOME/ocskills" \
    "$(pwd)/ocskills" \
    "$(pwd)"; do
    if [[ -d "$path/.opencode/skills" ]]; then
      SOURCE_DIR="$path/.opencode/skills"
      break
    fi
  done
fi

if [[ -z "$SOURCE_DIR" ]] || [[ ! -d "$SOURCE_DIR" ]]; then
  echo -e "${CROSS} ${RED}Source skills directory not found.${NC}"
  echo -e "${INFO} Usage: $0 [path-to-ocskills-repo]"
  exit 1
fi

echo -e "${BOLD}${GREEN}Updating skills from:${NC} $SOURCE_DIR"
echo -e "${BOLD}${GREEN}Target:${NC} $SKILLS_DIR"
echo ""

updated=0
added=0
skipped=0

for skill_dir in "$SOURCE_DIR"/*/; do
  [[ -d "$skill_dir" ]] || continue
  
  skill_name="$(basename "$skill_dir")"
  target="$SKILLS_DIR/$skill_name"
  
  if [[ ! -d "$target" ]]; then
    cp -r "$skill_dir" "$target"
    echo -e "  ${CHECK} ${BOLD}$skill_name${NC} ${GREEN}(added)${NC}"
    ((added++))
  else
    # Compare modification times
    source_file="$skill_dir/SKILL.md"
    target_file="$target/SKILL.md"
    
    if [[ "$source_file" -nt "$target_file" ]]; then
      cp -r "$skill_dir" "$target"
      echo -e "  ${CHECK} ${BOLD}$skill_name${NC} ${GREEN}(updated)${NC}"
      ((updated++))
    else
      echo -e "  ${ARROW} ${BOLD}$skill_name${NC} ${CYAN}(up to date)${NC}"
      ((skipped++))
    fi
  fi
done

echo ""
echo -e "${BOLD}Summary:${NC}"
echo -e "  ${CHECK} ${BOLD}$added${NC} skill(s) added"
echo -e "  ${CHECK} ${BOLD}$updated${NC} skill(s) updated"
echo -e "  ${ARROW} ${BOLD}$skipped${NC} skill(s) up to date"
