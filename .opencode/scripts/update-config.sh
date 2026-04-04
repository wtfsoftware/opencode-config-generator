#!/usr/bin/env bash
# =============================================================================
# OpenCode Config Updater — Master Script
# Updates project config (skills, commands, agents) AND models section
#
# Usage: ./update-config.sh [command] [options]
#
# Commands:
#   all          Update everything (project config + models)
#   project      Update project config only (skills, commands, agents)
#   models       Update models section only (scan LLM providers)
#   status       Show current config status
#
# Options:
#   --dry-run    Preview changes without writing
#   --force      Overwrite without prompting
#   --interactive  Interactive model selection
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
PROJECT_DIR="$(pwd)"
PROJECT_CONFIG="$PROJECT_DIR/opencode.json"
GLOBAL_CONFIG="$HOME/.config/opencode/opencode.json"

COMMAND=""
DRY_RUN=false
FORCE=false
INTERACTIVE=false
EXTRA_ARGS=()

# Parse arguments
for arg in "$@"; do
  case "$arg" in
    all|project|models|status)
      COMMAND="$arg"
      ;;
    --dry-run) DRY_RUN=true ;;
    --force) FORCE=true ;;
    --interactive|-i) INTERACTIVE=true ;;
    -*) EXTRA_ARGS+=("$arg") ;;
    *)
      if [[ -z "$PROJECT_DIR" ]]; then
        PROJECT_DIR="$arg"
      fi
      ;;
  esac
done

# Default command
if [[ -z "$COMMAND" ]]; then
  COMMAND="all"
fi

# =============================================================================
# Functions
# =============================================================================

print_header() {
  echo ""
  echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BOLD}${CYAN}║${NC}          ${BOLD}${GREEN}OpenCode Config Updater${NC}                        ${BOLD}${CYAN}║${NC}"
  echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
  echo ""
}

update_project_config() {
  echo -e "${BOLD}${CYAN}[Project Config]${NC} Analyzing project and updating skills/commands/agents..."
  echo ""

  local args=()
  $DRY_RUN && args+=("--dry-run")
  $FORCE && args+=("--force")
  args+=("$PROJECT_DIR")

  bash "$SCRIPT_DIR/update-project-config.sh" "${args[@]}"
  local rc=$?

  echo ""
  if [[ $rc -eq 0 ]]; then
    echo -e "  ${CHECK} ${GREEN}Project config updated${NC}"
  else
    echo -e "  ${CROSS} ${RED}Project config update failed${NC}"
  fi
  return $rc
}

update_models() {
  echo -e "${BOLD}${CYAN}[Models]${NC} Scanning LLM providers and updating models section..."
  echo ""

  local args=()
  $DRY_RUN && args+=("-n")
  $INTERACTIVE && args+=("-i")
  $FORCE && args+=("--force")

  # Default: merge into existing config
  if [[ -f "$PROJECT_CONFIG" ]]; then
    args+=("--merge" "-o" "$PROJECT_CONFIG")
  elif [[ -f "$GLOBAL_CONFIG" ]]; then
    args+=("--merge" "-o" "$GLOBAL_CONFIG")
  fi

  # Pass through extra args (--include, --exclude, --default-model, etc.)
  args+=("${EXTRA_ARGS[@]}")

  bash "$SCRIPT_DIR/update-models.sh" "${args[@]}"
  local rc=$?

  echo ""
  if [[ $rc -eq 0 ]]; then
    echo -e "  ${CHECK} ${GREEN}Models updated${NC}"
  else
    echo -e "  ${CROSS} ${RED}Models update failed${NC}"
  fi
  return $rc
}

show_status() {
  echo -e "${BOLD}Config Status:${NC}"
  echo ""

  # Project config
  if [[ -f "$PROJECT_CONFIG" ]]; then
    echo -e "  ${CHECK} Project config: ${BOLD}$PROJECT_CONFIG${NC}"
    python3 -c "
import json, sys
with open(sys.argv[1]) as f:
    c = json.load(f)
print(f'    Skills: {len(c.get(\"permission\",{}).get(\"skill\",{}))} configured')
print(f'    Commands: {len(c.get(\"command\",{}))} defined')
print(f'    Agents: {len(c.get(\"agent\",{}))} configured')
print(f'    Plugins: {len(c.get(\"plugin\",[]))} installed')
print(f'    Models: {len(c.get(\"models\",[]))} configured')
" "$PROJECT_CONFIG" 2>/dev/null || echo "    (unable to parse)"
  else
    echo -e "  ${WARN} No project config found"
  fi

  echo ""

  # Global config
  if [[ -f "$GLOBAL_CONFIG" ]]; then
    echo -e "  ${CHECK} Global config: ${BOLD}$GLOBAL_CONFIG${NC}"
    python3 -c "
import json, sys
with open(sys.argv[1]) as f:
    c = json.load(f)
print(f'    Models: {len(c.get(\"models\",[]))} configured')
print(f'    Plugins: {len(c.get(\"plugin\",[]))} installed')
" "$GLOBAL_CONFIG" 2>/dev/null || echo "    (unable to parse)"
  else
    echo -e "  ${WARN} No global config found"
  fi

  echo ""

  # Skills
  local global_skills=0
  local project_skills=0
  [[ -d "$HOME/.config/opencode/skills" ]] && global_skills=$(ls -1 "$HOME/.config/opencode/skills" 2>/dev/null | wc -l)
  [[ -d "$PROJECT_DIR/.opencode/skills" ]] && project_skills=$(ls -1 "$PROJECT_DIR/.opencode/skills" 2>/dev/null | wc -l)
  echo -e "  ${CHECK} Skills: ${BOLD}$global_skills${NC} global, ${BOLD}$project_skills${NC} project-local"

  # Commands
  local global_cmds=0
  local project_cmds=0
  [[ -d "$HOME/.config/opencode/commands" ]] && global_cmds=$(ls -1 "$HOME/.config/opencode/commands"/*.md 2>/dev/null | wc -l)
  [[ -d "$PROJECT_DIR/.opencode/commands" ]] && project_cmds=$(ls -1 "$PROJECT_DIR/.opencode/commands"/*.md 2>/dev/null | wc -l)
  echo -e "  ${CHECK} Commands: ${BOLD}$global_cmds${NC} global, ${BOLD}$project_cmds${NC} project-local"

  # Agents
  local global_agents=0
  local project_agents=0
  [[ -d "$HOME/.config/opencode/agents" ]] && global_agents=$(ls -1 "$HOME/.config/opencode/agents"/*.md 2>/dev/null | wc -l)
  [[ -d "$PROJECT_DIR/.opencode/agents" ]] && project_agents=$(ls -1 "$PROJECT_DIR/.opencode/agents"/*.md 2>/dev/null | wc -l)
  echo -e "  ${CHECK} Agents: ${BOLD}$global_agents${NC} global, ${BOLD}$project_agents${NC} project-local"
}

# =============================================================================
# Main
# =============================================================================

main() {
  print_header

  case "$COMMAND" in
    all)
      update_project_config
      echo ""
      update_models
      ;;
    project)
      update_project_config
      ;;
    models)
      update_models
      ;;
    status)
      show_status
      ;;
    *)
      echo -e "${CROSS} ${RED}Unknown command: $COMMAND${NC}"
      echo ""
      echo -e "${BOLD}Usage:${NC} $0 [all|project|models|status] [options]"
      echo ""
      echo -e "${BOLD}Commands:${NC}"
      echo -e "  all          Update everything (default)"
      echo -e "  project      Update project config only"
      echo -e "  models       Update models section only"
      echo -e "  status       Show current config status"
      echo ""
      echo -e "${BOLD}Options:${NC}"
      echo -e "  --dry-run      Preview without writing"
      echo -e "  --force        Overwrite without prompting"
      echo -e "  --interactive  Interactive model selection"
      exit 1
      ;;
  esac
}

main
