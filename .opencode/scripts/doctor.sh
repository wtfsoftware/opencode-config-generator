#!/usr/bin/env bash
# =============================================================================
# opencode Doctor — Diagnose your opencode environment
# Usage: ./doctor.sh
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

OC_GLOBAL="$HOME/.config/opencode"
OC_PROJECT="$(pwd)/.opencode"

total_checks=0
passed=0
warnings=0
errors=0

check() {
  local status="$1"
  local message="$2"
  ((total_checks++))

  case "$status" in
    ok)
      echo -e "  ${CHECK} ${GREEN}$message${NC}"
      ((passed++))
      ;;
    warn)
      echo -e "  ${WARN} ${YELLOW}$message${NC}"
      ((warnings++))
      ;;
    error)
      echo -e "  ${CROSS} ${RED}$message${NC}"
      ((errors++))
      ;;
  esac
}

echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║${NC}          ${BOLD}${GREEN}opencode Doctor${NC}                              ${BOLD}${CYAN}║${NC}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# ── opencode binary ──
echo -e "${BOLD}opencode${NC}"
if command -v opencode &>/dev/null; then
  version=$(opencode --version 2>/dev/null || echo "unknown")
  check ok "opencode installed ($version)"
else
  check error "opencode not found in PATH"
fi

# ── Global skills ──
echo -e "${BOLD}Global Skills ($OC_GLOBAL/skills/)${NC}"
if [[ -d "$OC_GLOBAL/skills" ]]; then
  count=$(ls -1 "$OC_GLOBAL/skills" 2>/dev/null | wc -l)
  if [[ $count -ge 25 ]]; then
    check ok "$count skills installed"
  elif [[ $count -gt 0 ]]; then
    check warn "$count skills installed (25 recommended)"
  else
    check error "No skills found"
  fi

  # Validate each skill
  for skill_dir in "$OC_GLOBAL/skills"/*/; do
    [[ -d "$skill_dir" ]] || continue
    skill_name=$(basename "$skill_dir")
    skill_file="$skill_dir/SKILL.md"

    if [[ ! -f "$skill_file" ]]; then
      check error "$skill_name: SKILL.md missing"
    elif ! head -1 "$skill_file" | grep -q '^---'; then
      check error "$skill_name: invalid frontmatter"
    else
      name_in_file=$(grep -m1 '^name:' "$skill_file" | sed 's/^name: *//' | tr -d '[:space:]')
      if [[ "$name_in_file" != "$skill_name" ]]; then
        check warn "$skill_name: name mismatch ('$name_in_file')"
      fi
    fi
  done
else
  check error "Global skills directory not found"
fi

# ── Project-local skills ──
echo -e "${BOLD}Project Skills ($OC_PROJECT/skills/)${NC}"
if [[ -d "$OC_PROJECT/skills" ]]; then
  count=$(ls -1 "$OC_PROJECT/skills" 2>/dev/null | wc -l)
  check ok "$count project-local skills"
else
  check warn "No project-local skills (using global only)"
fi

# ── Commands ──
echo -e "${BOLD}Commands${NC}"
for cmds_dir in "$OC_GLOBAL/commands" "$OC_PROJECT/commands"; do
  if [[ -d "$cmds_dir" ]]; then
    count=$(ls -1 "$cmds_dir"/*.md 2>/dev/null | wc -l)
    [[ $count -gt 0 ]] && check ok "$count commands in $cmds_dir"
  fi
done
if [[ ! -d "$OC_GLOBAL/commands" ]] && [[ ! -d "$OC_PROJECT/commands" ]]; then
  check warn "No custom commands found"
fi

# ── Rules ──
echo -e "${BOLD}Rules${NC}"
for rules_dir in "$OC_GLOBAL/rules" "$OC_PROJECT/rules"; do
  if [[ -d "$rules_dir" ]]; then
    count=$(ls -1 "$rules_dir"/*.md 2>/dev/null | wc -l)
    [[ $count -gt 0 ]] && check ok "$count rules in $rules_dir"
  fi
done
if [[ ! -d "$OC_GLOBAL/rules" ]] && [[ ! -d "$OC_PROJECT/rules" ]]; then
  check warn "No rules files found"
fi

# ── Agents ──
echo -e "${BOLD}Agents${NC}"
for agents_dir in "$OC_GLOBAL/agents" "$OC_PROJECT/agents"; do
  if [[ -d "$agents_dir" ]]; then
    count=$(ls -1 "$agents_dir"/*.md 2>/dev/null | wc -l)
    [[ $count -gt 0 ]] && check ok "$count agents in $agents_dir"
  fi
done
if [[ ! -d "$OC_GLOBAL/agents" ]] && [[ ! -d "$OC_PROJECT/agents" ]]; then
  check warn "No custom agents found"
fi

# ── opencode.json ──
echo -e "${BOLD}Configuration${NC}"
config_checked=false
for config_file in "$(pwd)/opencode.json" "$OC_GLOBAL/opencode.json"; do
  if [[ -f "$config_file" ]]; then
    config_checked=true
    abs_path="$(cd "$(dirname "$config_file")" && pwd)/$(basename "$config_file")"
    if python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$abs_path" 2>/dev/null; then
      check ok "Valid opencode.json"
    else
      check error "Invalid JSON in opencode.json"
    fi
  fi
done
if ! $config_checked; then
  check warn "No opencode.json found"
fi

# ── MCP Servers ──
echo -e "${BOLD}MCP Servers${NC}"
mcp_found=false
for mcp in "@modelcontextprotocol/server-filesystem" "@modelcontextprotocol/server-github" "@modelcontextprotocol/server-sequential-thinking"; do
  if npm list -g "$mcp" &>/dev/null || npx "$mcp" --help &>/dev/null; then
    check ok "$mcp available"
    mcp_found=true
  fi
done
if ! $mcp_found; then
  check warn "No MCP servers installed (run: npx @modelcontextprotocol/server-filesystem)"
fi

# ── Install script ──
echo -e "${BOLD}Scripts${NC}"
installer="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/install-skills.sh"
if [[ -f "$installer" ]]; then
  check ok "install-skills.sh available"
else
  check warn "install-skills.sh not found"
fi

# ── Summary ──
echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Results: $total_checks checks${NC}"
echo -e "  ${CHECK} ${GREEN}$passed passed${NC}"
echo -e "  ${WARN} ${YELLOW}$warnings warnings${NC}"
echo -e "  ${CROSS} ${RED}$errors errors${NC}"
echo ""

if [[ $errors -eq 0 ]] && [[ $warnings -eq 0 ]]; then
  echo -e "${BOLD}${GREEN}Everything looks good!${NC}"
elif [[ $errors -eq 0 ]]; then
  echo -e "${BOLD}${YELLOW}Minor issues found. Review warnings above.${NC}"
else
  echo -e "${BOLD}${RED}Issues found. Fix errors above for optimal experience.${NC}"
fi
