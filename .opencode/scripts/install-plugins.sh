#!/usr/bin/env bash
# =============================================================================
# OpenCode Plugin Installer
# Install, update, and manage ecosystem plugins
# Usage: ./install-plugins.sh [command] [plugin-name]
#
# Commands:
#   list              List all available plugins
#   install <name>    Install a plugin (npm or local)
#   update <name>     Update a plugin
#   update-all        Update all installed plugins
#   remove <name>     Remove a plugin
#   status            Show installed plugins
#   doctor            Check plugin environment
# =============================================================================

set -uo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

CHECK="${GREEN}✓${NC}"
CROSS="${RED}✗${NC}"
WARN="${YELLOW}⚠${NC}"
INFO="${BLUE}ℹ${NC}"
ARROW="${CYAN}→${NC}"

PLUGIN_DIR="${OPENCODE_PLUGIN_DIR:-$HOME/.config/opencode/plugins}"
PROJECT_PLUGIN_DIR="$(pwd)/.opencode/plugins"
GLOBAL_CONFIG="$HOME/.config/opencode/opencode.json"
PROJECT_CONFIG="$(pwd)/opencode.json"

# =============================================================================
# Plugin Registry — community plugins from ecosystem
# =============================================================================

declare -A PLUGINS=(
  # Auth plugins
  ["openai-codex-auth"]="Use ChatGPT Plus/Pro subscription instead of API credits|https://github.com/numman-ali/opencode-openai-codex-auth|auth"
  ["gemini-auth"]="Use existing Gemini plan instead of API billing|https://github.com/jenslys/opencode-gemini-auth|auth"
  ["antigravity-auth"]="Use Antigravity's free models|https://github.com/NoeFabris/opencode-antigravity-auth|auth"
  ["google-antigravity-auth"]="Google Antigravity OAuth with Search support|https://github.com/shekohex/opencode-google-antigravity-auth|auth"

  # Dev tools
  ["devcontainers"]="Multi-branch devcontainer isolation|https://github.com/athal7/opencode-devcontainers|dev"
  ["daytona"]="Run sessions in isolated Daytona sandboxes|https://github.com/daytonaio/daytona|dev"
  ["worktree"]="Zero-friction git worktrees|https://github.com/kdcokenny/opencode-worktree|dev"
  ["scheduler"]="Schedule recurring jobs with cron|https://github.com/different-ai/opencode-scheduler|dev"

  # Productivity
  ["wakatime"]="Track OpenCode usage with Wakatime|https://github.com/angristan/opencode-wakatime|productivity"
  ["notificator"]="Desktop notifications and sound alerts|https://github.com/panta82/opencode-notificator|productivity"
  ["notifier"]="Desktop notifications for events|https://github.com/mohak34/opencode-notifier|productivity"
  ["zellij-namer"]="AI-powered Zellij session naming|https://github.com/24601/opencode-zellij-namer|productivity"
  ["md-table-formatter"]="Clean up markdown tables from LLMs|https://github.com/franlol/opencode-md-table-formatter|productivity"

  # Performance
  ["dynamic-context-pruning"]="Optimize token usage by pruning tool outputs|https://github.com/Tarquinen/opencode-dynamic-context-pruning|performance"
  ["vibeguard"]="Redact secrets/PII before LLM calls|https://github.com/inkdust2021/opencode-vibeguard|performance"
  ["morph"]="Fast Apply editing, WarpGrep search, context compaction|https://github.com/morphllm/opencode-morph-plugin|performance"
  ["shell-strategy"]="Prevent hangs from TTY-dependent operations|https://github.com/JRedeker/opencode-shell-strategy|performance"
  ["pty"]="Run background processes in PTY with interactive input|https://github.com/shekohex/opencode-pty|performance"

  # Search & Web
  ["websearch-cited"]="Native websearch with Google grounded citations|https://github.com/ghoulr/opencode-websearch-cited|search"
  ["firecrawl"]="Web scraping, crawling, and search|https://github.com/firecrawl/opencode-firecrawl|search"

  # Monitoring
  ["sentry-monitor"]="Trace and debug AI agents with Sentry|https://github.com/stolinski/opencode-sentry-monitor|monitoring"
  ["helicone-session"]="Inject Helicone session headers|https://github.com/H2Shami/opencode-helicone-session|monitoring"

  # Type & Code
  ["type-inject"]="Auto-inject TypeScript/Svelte types into file reads|https://github.com/nick-vi/opencode-type-inject|code"

  # Agents & Orchestration
  ["background-agents"]="Background agents with async delegation|https://github.com/kdcokenny/opencode-background-agents|agents"
  ["subtask2"]="Extend commands with orchestration flow control|https://github.com/spoons-and-mirrors/subtask2|agents"
  ["workspace"]="Multi-agent orchestration harness (16 components)|https://github.com/kdcokenny/opencode-workspace|agents"
  ["skillful"]="Lazy load prompts with skill discovery|https://github.com/zenobi-us/opencode-skillful|agents"
  ["supermemory"]="Persistent memory across sessions|https://github.com/supermemoryai/opencode-supermemory|agents"

  # UI & IDE
  ["notify"]="Native OS notifications|https://github.com/kdcokenny/opencode-notify|ui"
  ["plannotator"]="Interactive plan review with visual annotation|https://github.com/backnotprop/plannotator|ui"

  # Workflow
  ["micode"]="Structured Brainstorm → Plan → Implement workflow|https://github.com/vtemian/micode|workflow"
  ["octto"]="Interactive browser UI for AI brainstorming|https://github.com/vtemian/octto|workflow"
)

# =============================================================================
# Helper: Add plugin to opencode.json
# =============================================================================

add_to_config() {
  local plugin_name="$1"
  local config_file="$2"

  if [[ ! -f "$config_file" ]]; then
    # Create minimal config
    echo "{\"plugin\":[\"$plugin_name\"]}" > "$config_file"
    return
  fi

  # Use Python to safely modify JSON
  python3 -c "
import json, sys

config_file = sys.argv[1]
plugin_name = sys.argv[2]

with open(config_file) as f:
    config = json.load(f)

if 'plugin' not in config:
    config['plugin'] = []

if plugin_name not in config['plugin']:
    config['plugin'].append(plugin_name)
    with open(config_file, 'w') as f:
        json.dump(config, f, indent=2)
    print('added')
else:
    print('exists')
" "$config_file" "$plugin_name"
}

remove_from_config() {
  local plugin_name="$1"
  local config_file="$2"

  if [[ ! -f "$config_file" ]]; then
    return
  fi

  python3 -c "
import json, sys

config_file = sys.argv[1]
plugin_name = sys.argv[2]

with open(config_file) as f:
    config = json.load(f)

if 'plugin' in config and plugin_name in config['plugin']:
    config['plugin'].remove(plugin_name)
    with open(config_file, 'w') as f:
        json.dump(config, f, indent=2)
    print('removed')
else:
    print('not_found')
" "$config_file" "$plugin_name"
}

# =============================================================================
# Commands
# =============================================================================

cmd_list() {
  local filter="${1:-}"
  
  echo -e "${BOLD}${CYAN}OpenCode Plugin Registry${NC}"
  echo ""
  
  # Group by category
  declare -A categories
  for name in "${!PLUGINS[@]}"; do
    IFS='|' read -r desc url category <<< "${PLUGINS[$name]}"
    if [[ -z "${categories[$category]:-}" ]]; then
      categories[$category]="$name"
    else
      categories[$category]="${categories[$category]}|$name"
    fi
  done
  
  for cat in $(echo "${!categories[@]}" | tr ' ' '\n' | sort); do
    if [[ -n "$filter" ]] && [[ "$cat" != "$filter" ]]; then
      continue
    fi
    
    echo -e "${BOLD}${MAGENTA}[$cat]${NC}"
    IFS='|' read -ra names <<< "${categories[$cat]}"
    for name in "${names[@]}"; do
      IFS='|' read -r desc url category <<< "${PLUGINS[$name]}"
      local status=""
      
      # Check if installed via npm (in config)
      for cfg in "$GLOBAL_CONFIG" "$PROJECT_CONFIG"; do
        if [[ -f "$cfg" ]] && grep -q "\"$name\"" "$cfg" 2>/dev/null; then
          status=" ${GREEN}[installed]${NC}"
          break
        fi
      done
      
      # Check if installed as local plugin
      for pdir in "$PLUGIN_DIR" "$PROJECT_PLUGIN_DIR"; do
        if [[ -d "$pdir/$name" ]] || [[ -f "$pdir/$name.js" ]] || [[ -f "$pdir/$name.ts" ]]; then
          status=" ${GREEN}[local]${NC}"
          break
        fi
      done
      
      echo -e "  ${ARROW} ${BOLD}$name${NC}$status"
      echo -e "      $desc"
      echo -e "      ${CYAN}$url${NC}"
      echo ""
    done
  done
  
  echo -e "Total: ${BOLD}${#PLUGINS[@]}${NC} plugins"
}

cmd_status() {
  echo -e "${BOLD}Installed Plugins:${NC}"
  echo ""
  
  local found=false
  
  # Check npm plugins in configs
  for cfg in "$GLOBAL_CONFIG" "$PROJECT_CONFIG"; do
    if [[ -f "$cfg" ]]; then
      plugins=$(python3 -c "
import json
with open('$cfg') as f:
    config = json.load(f)
for p in config.get('plugin', []):
    print(p)
" 2>/dev/null)
      
      if [[ -n "$plugins" ]]; then
        echo -e "${BOLD}From $cfg:${NC}"
        while IFS= read -r plugin; do
          echo -e "  ${CHECK} ${BOLD}$plugin${NC} (npm)"
          found=true
        done <<< "$plugins"
        echo ""
      fi
    fi
  done
  
  # Check local plugins
  for pdir in "$PLUGIN_DIR" "$PROJECT_PLUGIN_DIR"; do
    if [[ -d "$pdir" ]]; then
      local count=0
      for item in "$pdir"/*; do
        [[ -e "$item" ]] || continue
        local name
        name="$(basename "$item")"
        # Skip package.json, node_modules
        [[ "$name" == "package.json" ]] || [[ "$name" == "node_modules" ]] && continue
        echo -e "  ${CHECK} ${BOLD}$name${NC} (local — $pdir)"
        found=true
        ((count++))
      done
      [[ $count -gt 0 ]] && echo ""
    fi
  done
  
  if ! $found; then
    echo -e "  ${WARN} No plugins installed"
    echo ""
    echo -e "${BOLD}To install a plugin:${NC}"
    echo -e "  $0 install wakatime"
    echo -e "  $0 install worktree"
  fi
}

cmd_install() {
  local name="$1"
  
  if [[ -z "$name" ]]; then
    echo -e "${CROSS} ${RED}Plugin name required${NC}"
    echo -e "${INFO} Usage: $0 install <name>"
    return 1
  fi
  
  # Check if it's a known plugin
  if [[ -n "${PLUGINS[$name]:-}" ]]; then
    IFS='|' read -r desc url category <<< "${PLUGINS[$name]}"
    
    echo -e "${ARROW} Installing ${BOLD}$name${NC}..."
    echo -e "  $desc"
    echo -e "  ${CYAN}$url${NC}"
    echo ""
    
    # Add to project config (preferred) or global config
    local config_file="$PROJECT_CONFIG"
    if [[ ! -f "$PROJECT_CONFIG" ]]; then
      config_file="$GLOBAL_CONFIG"
      mkdir -p "$(dirname "$GLOBAL_CONFIG")"
    fi
    
    local result
    result=$(add_to_config "$name" "$config_file")
    
    if [[ "$result" == "added" ]]; then
      echo -e "  ${CHECK} ${GREEN}Added to $config_file${NC}"
      echo -e "  ${INFO} Plugin will be loaded on next OpenCode start"
      echo ""
      echo -e "${BOLD}Next steps:${NC}"
      echo -e "  1. Restart OpenCode"
      echo -e "  2. Plugin is cached in ~/.cache/opencode/node_modules/"
    elif [[ "$result" == "exists" ]]; then
      echo -e "  ${WARN} ${YELLOW}Already installed${NC}"
    fi
  else
    # Treat as arbitrary npm package
    echo -e "${ARROW} Installing ${BOLD}$name${NC} from npm..."
    
    local config_file="$PROJECT_CONFIG"
    if [[ ! -f "$PROJECT_CONFIG" ]]; then
      config_file="$GLOBAL_CONFIG"
      mkdir -p "$(dirname "$GLOBAL_CONFIG")"
    fi
    
    local result
    result=$(add_to_config "$name" "$config_file")
    
    if [[ "$result" == "added" ]]; then
      echo -e "  ${CHECK} ${GREEN}Added $name to $config_file${NC}"
    elif [[ "$result" == "exists" ]]; then
      echo -e "  ${WARN} ${YELLOW}Already installed${NC}"
    fi
  fi
}

cmd_update() {
  local name="$1"
  
  if [[ -z "$name" ]]; then
    echo -e "${CROSS} ${RED}Plugin name required${NC}"
    return 1
  fi
  
  echo -e "${ARROW} Updating ${BOLD}$name${NC}..."
  
  # For npm plugins, just need to clear cache — they're reinstalled on startup
  rm -rf "$HOME/.cache/opencode/node_modules/$name" 2>/dev/null
  echo -e "  ${CHECK} ${GREEN}Cache cleared, will reinstall on next OpenCode start${NC}"
}

cmd_update_all() {
  echo -e "${BOLD}Updating all npm plugins...${NC}"
  echo ""
  
  # Clear entire plugin cache
  rm -rf "$HOME/.cache/opencode/node_modules" 2>/dev/null
  echo -e "  ${CHECK} ${GREEN}Plugin cache cleared${NC}"
  echo -e "  ${INFO} All plugins will be reinstalled on next OpenCode start"
}

cmd_remove() {
  local name="$1"
  
  if [[ -z "$name" ]]; then
    echo -e "${CROSS} ${RED}Plugin name required${NC}"
    return 1
  fi
  
  local removed=false
  
  # Remove from configs
  for cfg in "$GLOBAL_CONFIG" "$PROJECT_CONFIG"; do
    if [[ -f "$cfg" ]]; then
      local result
      result=$(remove_from_config "$name" "$cfg")
      if [[ "$result" == "removed" ]]; then
        echo -e "  ${CHECK} ${GREEN}Removed $name from $cfg${NC}"
        removed=true
      fi
    fi
  done
  
  # Remove local plugin files
  for pdir in "$PLUGIN_DIR" "$PROJECT_PLUGIN_DIR"; do
    if [[ -d "$pdir/$name" ]]; then
      rm -rf "$pdir/$name"
      echo -e "  ${CHECK} ${GREEN}Removed local plugin: $pdir/$name${NC}"
      removed=true
    fi
    for ext in js ts mjs; do
      if [[ -f "$pdir/$name.$ext" ]]; then
        rm "$pdir/$name.$ext"
        echo -e "  ${CHECK} ${GREEN}Removed local plugin: $pdir/$name.$ext${NC}"
        removed=true
      fi
    done
  done
  
  # Clear cache
  rm -rf "$HOME/.cache/opencode/node_modules/$name" 2>/dev/null
  
  if ! $removed; then
    echo -e "  ${WARN} ${YELLOW}$name not found${NC}"
  fi
}

cmd_doctor() {
  echo -e "${BOLD}Plugin Environment Check${NC}"
  echo ""
  
  # Check plugin directories
  for pdir in "$PLUGIN_DIR" "$PROJECT_PLUGIN_DIR"; do
    if [[ -d "$pdir" ]]; then
      local count
      count=$(find "$pdir" -maxdepth 1 \( -name "*.js" -o -name "*.ts" -o -name "*.mjs" -o -type d \) ! -name "node_modules" ! -name "package.json" 2>/dev/null | wc -l)
      echo -e "  ${CHECK} Plugin directory exists: $pdir ($count plugins)"
    else
      echo -e "  ${WARN} Plugin directory not found: $pdir"
      echo -e "  ${INFO} Create with: mkdir -p $pdir"
    fi
  done
  
  # Check config files for plugin entries
  for cfg in "$GLOBAL_CONFIG" "$PROJECT_CONFIG"; do
    if [[ -f "$cfg" ]]; then
      plugins=$(python3 -c "
import json
with open('$cfg') as f:
    config = json.load(f)
for p in config.get('plugin', []):
    print(p)
" 2>/dev/null)
      
      if [[ -n "$plugins" ]]; then
        echo -e "  ${CHECK} npm plugins in $cfg:"
        while IFS= read -r plugin; do
          echo -e "      ${ARROW} $plugin"
        done <<< "$plugins"
      fi
    fi
  done
  
  # Check bun (used for plugin installation)
  if command -v bun &>/dev/null; then
    echo -e "  ${CHECK} bun available ($(bun --version))"
  else
    echo -e "  ${WARN} bun not found (OpenCode uses bun for plugin installation)"
  fi
  
  # Check node
  if command -v node &>/dev/null; then
    echo -e "  ${CHECK} node available ($(node --version))"
  else
    echo -e "  ${WARN} node not found"
  fi
  
  # Check plugin cache
  if [[ -d "$HOME/.cache/opencode/node_modules" ]]; then
    local cache_count
    cache_count=$(ls -1 "$HOME/.cache/opencode/node_modules" 2>/dev/null | wc -l)
    echo -e "  ${CHECK} Plugin cache: $cache_count package(s)"
  else
    echo -e "  ${INFO} Plugin cache empty (plugins installed on first OpenCode start)"
  fi
  
  echo ""
  echo -e "${BOLD}Recommended plugins for your projects:${NC}"
  echo ""
  
  # Detect projects
  local projects_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
  
  if [[ -d "$projects_dir/ainet_preprocessor" ]]; then
    echo -e "  ${ARROW} ainet_preprocessor:"
    echo -e "      worktree, scheduler, background-agents, sentry-monitor"
  fi
  
  if [[ -d "$projects_dir/dynamic" ]] || [[ -d "$projects_dir/ebu" ]]; then
    echo -e "  ${ARROW} dynamic / ebu:"
    echo -e "      type-inject, vibeguard, notificator"
  fi
  
  if [[ -d "$projects_dir/Extensions" ]]; then
    echo -e "  ${ARROW} Extensions:"
    echo -e "      websearch-cited, md-table-formatter, wakatime"
  fi
  
  if [[ -d "$projects_dir/karma" ]]; then
    echo -e "  ${ARROW} karma:"
    echo -e "      pty, shell-strategy, notificator"
  fi
  
  if [[ -d "$projects_dir/sparkle" ]]; then
    echo -e "  ${ARROW} sparkle:"
    echo -e "      vibeguard, plannotator, micode"
  fi
  
  if [[ -d "$projects_dir/opencode_config_generator" ]]; then
    echo -e "  ${ARROW} opencode_config_generator:"
    echo -e "      skillful, supermemory, worktree"
  fi
}

# =============================================================================
# Main
# =============================================================================

usage() {
  echo -e "${BOLD}Usage:${NC} $0 <command> [args]"
  echo ""
  echo -e "${BOLD}Commands:${NC}"
  echo -e "  list [category]     List all plugins (optionally filter by category)"
  echo -e "  install <name>      Install a plugin (adds to opencode.json)"
  echo -e "  update <name>       Update a plugin (clears cache)"
  echo -e "  update-all          Update all installed plugins"
  echo -e "  remove <name>       Remove a plugin"
  echo -e "  status              Show installed plugins"
  echo -e "  doctor              Check plugin environment and recommend plugins"
  echo ""
  echo -e "${BOLD}Examples:${NC}"
  echo -e "  $0 list"
  echo -e "  $0 list auth"
  echo -e "  $0 install wakatime"
  echo -e "  $0 install worktree"
  echo -e "  $0 update-all"
  echo -e "  $0 doctor"
  echo ""
  echo -e "${BOLD}How plugins work:${NC}"
  echo -e "  npm plugins: Added to opencode.json 'plugin' array, installed by bun at startup"
  echo -e "  Local plugins: .js/.ts files in .opencode/plugins/ or ~/.config/opencode/plugins/"
  echo -e "  Cache: ~/.cache/opencode/node_modules/"
}

main() {
  local command="${1:-help}"
  shift 2>/dev/null || true
  
  case "$command" in
    list) cmd_list "$@" ;;
    install) cmd_install "$@" ;;
    update) cmd_update "$@" ;;
    update-all) cmd_update_all ;;
    remove) cmd_remove "$@" ;;
    status) cmd_status ;;
    doctor) cmd_doctor ;;
    help|-h|--help) usage ;;
    *)
      echo -e "${CROSS} ${RED}Unknown command: $command${NC}"
      usage
      exit 1
      ;;
  esac
}

main "$@"
