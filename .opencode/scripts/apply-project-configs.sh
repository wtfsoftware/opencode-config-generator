#!/usr/bin/env bash
# =============================================================================
# Apply opencode.json configs to all detected projects
# Usage: ./apply-project-configs.sh [--dry-run] [--force]
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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/../templates"
PROJECTS_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

DRY_RUN=false
FORCE=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --force) FORCE=true ;;
  esac
done

echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║${NC}          ${BOLD}${GREEN}Apply Project Configs${NC}                          ${BOLD}${CYAN}║${NC}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Project → template mapping
declare -A PROJECT_MAP=(
  ["ainet_preprocessor"]="go"
  ["dynamic"]="python"
  ["ebu"]="python"
  ["Extensions"]="javascript"
  ["karma"]="cpp"
  ["sparkle"]="kotlin"
  ["opencode_config_generator"]="bash"
)

applied=0
skipped=0
errors=0

for project in "${!PROJECT_MAP[@]}"; do
  template="${PROJECT_MAP[$project]}"
  project_path="$PROJECTS_DIR/$project"
  template_file="$TEMPLATES_DIR/${template}.json"
  output_file="$project_path/opencode.json"

  echo -e "${BOLD}$project${NC}"

  # Check project exists
  if [[ ! -d "$project_path" ]]; then
    echo -e "  ${CROSS} ${RED}Project directory not found${NC}"
    ((errors++))
    echo ""
    continue
  fi

  # Check template exists
  if [[ ! -f "$template_file" ]]; then
    echo -e "  ${CROSS} ${RED}Template not found: $template.json${NC}"
    ((errors++))
    echo ""
    continue
  fi

  # Check if config already exists
  if [[ -f "$output_file" ]] && ! $FORCE; then
    echo -e "  ${WARN} ${YELLOW}opencode.json already exists (use --force to overwrite)${NC}"
    ((skipped++))
    echo ""
    continue
  fi

  if $DRY_RUN; then
    echo -e "  ${ARROW} ${CYAN}Would apply: $template.json → opencode.json${NC}"
  else
    # Backup existing
    if [[ -f "$output_file" ]]; then
      backup="${output_file}.backup.$(date +%Y%m%d%H%M%S)"
      cp "$output_file" "$backup"
      echo -e "  ${INFO} Backed up: $backup"
    fi

    cp "$template_file" "$output_file"
    echo -e "  ${CHECK} ${GREEN}Applied: $template.json${NC}"
  fi

  ((applied++))
  echo ""
done

echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Summary:${NC}"
if $DRY_RUN; then
  echo -e "  ${ARROW} ${BOLD}$applied${NC} config(s) would be applied"
else
  echo -e "  ${CHECK} ${BOLD}$applied${NC} config(s) applied"
fi
[[ $skipped -gt 0 ]] && echo -e "  ${WARN} ${BOLD}$skipped${NC} skipped (already exist)"
[[ $errors -gt 0 ]] && echo -e "  ${CROSS} ${BOLD}$errors${NC} errors"
