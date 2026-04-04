#!/usr/bin/env bash
# =============================================================================
# opencode Skills Installer
# Install skills from this repository into any opencode project
# =============================================================================

set -uo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Emoji helpers
CHECK="${GREEN}✓${NC}"
CROSS="${RED}✗${NC}"
WARN="${YELLOW}⚠${NC}"
INFO="${BLUE}ℹ${NC}"
ARROW="${CYAN}→${NC}"

# Script directory (where skills live)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SOURCE="${SCRIPT_DIR}/.opencode/skills"

# Default target
TARGET_DIR=""
DRY_RUN=false
FORCE=false
ALL_SKILLS=false
SELECTED_CATEGORIES=()
SELECTED_SKILLS=()

# Parallel arrays for skill data (more reliable than associative arrays in bash)
SKILL_NAMES=()
SKILL_CATS=()
SKILL_DESCS=()
TOTAL_SKILLS=0

# =============================================================================
# Scan skills from filesystem
# =============================================================================

scan_skills() {
  if [[ ! -d "$SKILLS_SOURCE" ]]; then
    return
  fi

  for skill_dir in "$SKILLS_SOURCE"/*/; do
    [[ -d "$skill_dir" ]] || continue
    
    local skill_name
    skill_name="$(basename "$skill_dir")"
    
    # Read category and description from SKILL.md frontmatter
    local skill_file="${skill_dir}SKILL.md"
    local category="unknown"
    local description=""
    
    if [[ -f "$skill_file" ]]; then
      # Extract category from frontmatter
      local cat_line
      cat_line=$(grep -m1 'category:' "$skill_file" 2>/dev/null || echo "")
      if [[ -n "$cat_line" ]]; then
        category=$(echo "$cat_line" | sed 's/.*category: *//' | tr -d '[:space:]')
      fi
      
      # Extract description from frontmatter
      local desc_line
      desc_line=$(grep -m1 'description:' "$skill_file" 2>/dev/null || echo "")
      if [[ -n "$desc_line" ]]; then
        description=$(echo "$desc_line" | sed 's/^description: *//')
      fi
    fi
    
    SKILL_NAMES+=("$skill_name")
    SKILL_CATS+=("$category")
    SKILL_DESCS+=("$description")
    ((TOTAL_SKILLS++))
  done
}

# Get index of skill by name
find_skill_index() {
  local name="$1"
  for i in "${!SKILL_NAMES[@]}"; do
    if [[ "${SKILL_NAMES[$i]}" == "$name" ]]; then
      echo "$i"
      return 0
    fi
  done
  return 1
}

# Get unique categories
get_categories() {
  local cats=()
  for cat in "${SKILL_CATS[@]}"; do
    local found=false
    for existing in "${cats[@]:-}"; do
      if [[ "$existing" == "$cat" ]]; then
        found=true
        break
      fi
    done
    if ! $found; then
      cats+=("$cat")
    fi
  done
  printf '%s\n' "${cats[@]}" | sort
}

# =============================================================================
# Utility functions
# =============================================================================

print_header() {
  echo ""
  echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BOLD}${CYAN}║${NC}          ${BOLD}${GREEN}opencode Skills Installer${NC}                      ${BOLD}${CYAN}║${NC}"
  echo -e "${BOLD}${CYAN}║${NC}          Install skills into your project              ${BOLD}${CYAN}║${NC}"
  echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
  echo ""
}

print_usage() {
  echo -e "${BOLD}Usage:${NC} $0 [OPTIONS] [TARGET_DIR]"
  echo ""
  echo -e "${BOLD}Options:${NC}"
  echo -e "  ${BOLD}--all${NC}              Install all skills without prompting"
  echo -e "  ${BOLD}--category <cat>${NC}   Install skills from a specific category"
  echo -e "                  Categories: $(get_categories | tr '\n' ', ' | sed 's/,$//')"
  echo -e "  ${BOLD}--skill <name>${NC}     Install a specific skill (can be repeated)"
  echo -e "  ${BOLD}--force${NC}            Overwrite existing skills without asking"
  echo -e "  ${BOLD}--dry-run${NC}          Show what would be installed without copying"
  echo -e "  ${BOLD}--list${NC}             List all available skills and exit"
  echo -e "  ${BOLD}--list-categories${NC}  List all categories and exit"
  echo -e "  ${BOLD}-h, --help${NC}         Show this help message"
  echo ""
  echo -e "${BOLD}Examples:${NC}"
  echo -e "  $0                          # Interactive mode"
  echo -e "  $0 /path/to/project         # Interactive, specific target"
  echo -e "  $0 --all                    # Install everything"
  echo -e "  $0 --category frontend      # Install frontend skills"
  echo -e "  $0 --skill react-master --skill typescript-master"
  echo -e "  $0 --dry-run --all          # Preview all installations"
  echo ""
}

list_skills() {
  echo -e "${BOLD}Available skills:${NC}"
  echo ""
  
  local categories
  mapfile -t categories < <(get_categories)
  
  for cat in "${categories[@]}"; do
    echo -e "${BOLD}${MAGENTA}[$cat]${NC}"
    for i in "${!SKILL_NAMES[@]}"; do
      if [[ "${SKILL_CATS[$i]}" == "$cat" ]]; then
        echo -e "  ${ARROW} ${BOLD}${SKILL_NAMES[$i]}${NC} — ${SKILL_DESCS[$i]}"
      fi
    done
    echo ""
  done
  
  echo -e "Total: ${BOLD}${TOTAL_SKILLS}${NC} skills"
}

list_categories() {
  echo -e "${BOLD}Available categories:${NC}"
  echo ""
  
  local categories
  mapfile -t categories < <(get_categories)
  
  for cat in "${categories[@]}"; do
    local count=0
    for c in "${SKILL_CATS[@]}"; do
      if [[ "$c" == "$cat" ]]; then
        ((count++))
      fi
    done
    echo -e "  ${BOLD}$cat${NC} ($count skills)"
  done
  echo ""
}

# =============================================================================
# Interactive selection
# =============================================================================

interactive_select() {
  echo -e "${BOLD}${GREEN}Available skill categories:${NC}"
  echo ""
  
  local categories
  mapfile -t categories < <(get_categories)
  
  # Display categories with numbers
  for i in "${!categories[@]}"; do
    cat="${categories[$i]}"
    local count=0
    for c in "${SKILL_CATS[@]}"; do
      if [[ "$c" == "$cat" ]]; then
        ((count++))
      fi
    done
    echo -e "  ${BOLD}$((i+1))${NC}) ${MAGENTA}$cat${NC} ($count skills)"
  done
  
  echo -e "  ${BOLD}0${NC}) Install ALL skills"
  echo ""
  echo -e "${BOLD}Select categories (space-separated, 0 for all):${NC}"
  read -r selection
  
  if [[ "$selection" == "0" ]]; then
    ALL_SKILLS=true
    return
  fi
  
  for num in $selection; do
    if [[ "$num" =~ ^[0-9]+$ ]] && [[ $num -ge 1 ]] && [[ $num -le ${#categories[@]} ]]; then
      SELECTED_CATEGORIES+=("${categories[$((num-1))]}")
    fi
  done
}

# =============================================================================
# Installation logic
# =============================================================================

get_skills_to_install() {
  local indices=()
  
  if $ALL_SKILLS; then
    # All skills
    for i in "${!SKILL_NAMES[@]}"; do
      indices+=("$i")
    done
  elif [[ ${#SELECTED_CATEGORIES[@]} -gt 0 ]]; then
    # Skills from selected categories
    for i in "${!SKILL_CATS[@]}"; do
      for cat in "${SELECTED_CATEGORIES[@]}"; do
        if [[ "${SKILL_CATS[$i]}" == "$cat" ]]; then
          indices+=("$i")
          break
        fi
      done
    done
  elif [[ ${#SELECTED_SKILLS[@]} -gt 0 ]]; then
    # Specific skills
    for skill in "${SELECTED_SKILLS[@]}"; do
      local idx
      if idx=$(find_skill_index "$skill"); then
        indices+=("$idx")
      else
        echo -e "${WARN} Unknown skill: ${BOLD}$skill${NC}" >&2
      fi
    done
  fi
  
  # Output skill names sorted
  for idx in "${indices[@]}"; do
    echo "${SKILL_NAMES[$idx]}"
  done | sort -u
}

install_skills() {
  local skills_to_install
  mapfile -t skills_to_install < <(get_skills_to_install)
  
  if [[ ${#skills_to_install[@]} -eq 0 ]]; then
    echo -e "${WARN} No skills selected for installation."
    exit 1
  fi
  
  local target_skills="${TARGET_DIR}/.opencode/skills"
  local total=${#skills_to_install[@]}
  local installed=0
  local skipped=0
  local failed=0
  
  echo ""
  echo -e "${BOLD}${GREEN}Installing ${total} skill(s) to:${NC} ${BOLD}${target_skills}${NC}"
  echo -e "${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  
  if $DRY_RUN; then
    echo -e "${BOLD}${YELLOW}[DRY RUN]${NC} The following skills would be installed:"
    echo ""
  fi
  
  # Create target directory
  if ! $DRY_RUN; then
    mkdir -p "$target_skills"
  fi
  
  for skill in "${skills_to_install[@]}"; do
    local source_path="${SKILLS_SOURCE}/${skill}"
    local target_path="${target_skills}/${skill}"
    
    # Find category and description
    local category="unknown"
    local description=""
    local idx
    if idx=$(find_skill_index "$skill"); then
      category="${SKILL_CATS[$idx]}"
      description="${SKILL_DESCS[$idx]}"
    fi
    
    # Check if source exists
    if [[ ! -d "$source_path" ]]; then
      echo -e "  ${CROSS} ${BOLD}$skill${NC} ${RED}(source not found)${NC}"
      ((failed++))
      continue
    fi
    
    # Check if already exists
    if [[ -d "$target_path" ]] && ! $FORCE; then
      echo -e "  ${WARN} ${BOLD}$skill${NC} ${YELLOW}(already exists, skipping)${NC}"
      ((skipped++))
      continue
    fi
    
    if $DRY_RUN; then
      echo -e "  ${ARROW} ${BOLD}$skill${NC} ${CYAN}[$category]${NC} — $description"
      ((installed++))
    else
      # Copy skill
      if cp -r "$source_path" "$target_path" 2>/dev/null; then
        echo -e "  ${CHECK} ${BOLD}$skill${NC} ${CYAN}[$category]${NC} — $description"
        ((installed++))
      else
        echo -e "  ${CROSS} ${BOLD}$skill${NC} ${RED}(failed to copy)${NC}"
        ((failed++))
      fi
    fi
  done
  
  # Summary
  echo ""
  echo -e "${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}Installation Summary:${NC}"
  
  if $DRY_RUN; then
    echo -e "  ${INFO} ${BOLD}$installed${NC} skill(s) would be installed"
  else
    echo -e "  ${CHECK} ${BOLD}$installed${NC} skill(s) installed"
    [[ $skipped -gt 0 ]] && echo -e "  ${WARN} ${BOLD}$skipped${NC} skill(s) skipped (already exist)"
    [[ $failed -gt 0 ]] && echo -e "  ${CROSS} ${BOLD}$failed${NC} skill(s) failed"
  fi
  
  echo ""
  
  if ! $DRY_RUN && [[ $installed -gt 0 ]]; then
    echo -e "${BOLD}Next steps:${NC}"
    echo -e "  1. Restart opencode to load the new skills"
    echo -e "  2. Skills are available in: ${BOLD}${target_skills}${NC}"
    echo -e "  3. Use ${BOLD}/skill <name>${NC} to activate a skill"
    echo ""
  fi
}

# =============================================================================
# Argument parsing
# =============================================================================

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --all)
        ALL_SKILLS=true
        shift
        ;;
      --category)
        if [[ -z "${2:-}" ]]; then
          echo -e "${CROSS} ${RED}Error: --category requires a value${NC}"
          exit 1
        fi
        SELECTED_CATEGORIES+=("$2")
        shift 2
        ;;
      --skill)
        if [[ -z "${2:-}" ]]; then
          echo -e "${CROSS} ${RED}Error: --skill requires a value${NC}"
          exit 1
        fi
        SELECTED_SKILLS+=("$2")
        shift 2
        ;;
      --force)
        FORCE=true
        shift
        ;;
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      --list)
        scan_skills
        list_skills
        exit 0
        ;;
      --list-categories)
        scan_skills
        list_categories
        exit 0
        ;;
      -h|--help)
        print_usage
        exit 0
        ;;
      -*)
        echo -e "${CROSS} ${RED}Unknown option: $1${NC}"
        print_usage
        exit 1
        ;;
      *)
        if [[ -z "$TARGET_DIR" ]]; then
          TARGET_DIR="$1"
        else
          echo -e "${CROSS} ${RED}Unexpected argument: $1${NC}"
          print_usage
          exit 1
        fi
        shift
        ;;
    esac
  done
  
  # Default target directory
  if [[ -z "$TARGET_DIR" ]]; then
    TARGET_DIR="$(pwd)"
  fi
  
  # Validate target
  if [[ ! -d "$TARGET_DIR" ]]; then
    echo -e "${CROSS} ${RED}Error: Target directory does not exist: $TARGET_DIR${NC}"
    exit 1
  fi
  
  # Scan skills
  scan_skills
  
  # Validate skills source
  if [[ $TOTAL_SKILLS -eq 0 ]]; then
    echo -e "${CROSS} ${RED}Error: No skills found in: $SKILLS_SOURCE${NC}"
    echo -e "${INFO} Make sure this script is in the repository root."
    exit 1
  fi
}

# =============================================================================
# Main
# =============================================================================

main() {
  parse_args "$@"
  print_header
  
  # Interactive selection if no explicit selection made
  if ! $ALL_SKILLS && [[ ${#SELECTED_CATEGORIES[@]} -eq 0 ]] && [[ ${#SELECTED_SKILLS[@]} -eq 0 ]]; then
    interactive_select
  fi
  
  install_skills
}

main "$@"
