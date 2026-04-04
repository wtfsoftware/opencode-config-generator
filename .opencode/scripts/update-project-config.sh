#!/usr/bin/env bash
# =============================================================================
# Intelligent opencode.json Updater
# Analyzes the project, selects the right template, and merges intelligently
# Usage: ./update-project-config.sh [project-path] [--dry-run] [--force]
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

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OC_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATES_DIR="$OC_DIR/templates"

PROJECT_DIR=""
DRY_RUN=false
FORCE=false

# Parse args
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --force) FORCE=true ;;
    -*) ;;
    *)
      if [[ -z "$PROJECT_DIR" ]]; then
        PROJECT_DIR="$arg"
      fi
      ;;
  esac
done

if [[ -z "$PROJECT_DIR" ]]; then
  PROJECT_DIR="$(pwd)"
fi

if [[ ! -d "$PROJECT_DIR" ]]; then
  echo -e "${CROSS} ${RED}Project directory not found: $PROJECT_DIR${NC}"
  exit 1
fi

if [[ ! -d "$TEMPLATES_DIR" ]]; then
  echo -e "${CROSS} ${RED}Templates directory not found: $TEMPLATES_DIR${NC}"
  exit 1
fi

echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║${NC}          ${BOLD}${GREEN}opencode.json Intelligent Updater${NC}              ${BOLD}${CYAN}║${NC}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# =============================================================================
# Detect project type
# =============================================================================

detect_project_type() {
  local dir="$1"
  if [[ -f "$dir/go.mod" ]]; then echo "go"; return; fi
  if [[ -f "$dir/build.gradle.kts" ]] || [[ -f "$dir/build.gradle" ]]; then echo "kotlin"; return; fi
  if [[ -f "$dir/CMakeLists.txt" ]]; then echo "cpp"; return; fi
  if [[ -f "$dir/package.json" ]]; then echo "javascript"; return; fi
  if [[ -f "$dir/pyproject.toml" ]] || [[ -f "$dir/requirements.txt" ]] || [[ -f "$dir/setup.py" ]]; then echo "python"; return; fi
  if [[ -f "$dir/Cargo.toml" ]]; then echo "rust"; return; fi
  local sh_count
  sh_count=$(find "$dir" -maxdepth 2 -name "*.sh" -type f 2>/dev/null | wc -l)
  if [[ $sh_count -gt 0 ]]; then echo "bash"; return; fi
  echo "unknown"
}

# =============================================================================
# Detect available skills
# =============================================================================

detect_available_skills() {
  local dir="$1"
  local skills=()
  if [[ -d "$HOME/.config/opencode/skills" ]]; then
    for skill_dir in "$HOME/.config/opencode/skills"/*/; do
      [[ -d "$skill_dir" ]] || continue
      skills+=("$(basename "$skill_dir")")
    done
  fi
  if [[ -d "$dir/.opencode/skills" ]]; then
    for skill_dir in "$dir/.opencode/skills"/*/; do
      [[ -d "$skill_dir" ]] || continue
      local name
      name="$(basename "$skill_dir")"
      local found=false
      for s in "${skills[@]:-}"; do
        [[ "$s" == "$name" ]] && found=true && break
      done
      $found || skills+=("$name")
    done
  fi
  printf '%s\n' "${skills[@]}" | sort -u
}

# =============================================================================
# Detect project features
# =============================================================================

detect_features() {
  local dir="$1"
  local features=()
  [[ -f "$dir/Dockerfile" ]] || [[ -f "$dir/docker-compose.yml" ]] && features+=("docker")
  [[ -d "$dir/helm" ]] || [[ -d "$dir/k8s" ]] || [[ -f "$dir/Chart.yaml" ]] && features+=("kubernetes")
  [[ -d "$dir/.github/workflows" ]] || [[ -f "$dir/.gitlab-ci.yml" ]] && features+=("ci-cd")
  grep -rl "postgres\|mysql\|mongodb\|prisma\|sqlalchemy\|gorm" "$dir" --include="*.json" --include="*.py" --include="*.js" --include="*.ts" --include="*.go" 2>/dev/null | head -1 >/dev/null && features+=("database")
  [[ -f "$dir/package.json" ]] && grep -q "jest\|vitest\|mocha\|playwright\|cypress" "$dir/package.json" 2>/dev/null && features+=("testing")
  [[ -f "$dir/pyproject.toml" ]] && grep -q "pytest" "$dir/pyproject.toml" 2>/dev/null && features+=("testing")
  [[ -f "$dir/package.json" ]] && grep -q '"react"' "$dir/package.json" 2>/dev/null && features+=("react")
  [[ -f "$dir/package.json" ]] && grep -q '"next"' "$dir/package.json" 2>/dev/null && features+=("nextjs")
  grep -rl "fastapi" "$dir" --include="*.py" 2>/dev/null | head -1 >/dev/null && features+=("fastapi")
  grep -rl "juce\|JUCE" "$dir" --include="*.txt" --include="*.cmake" 2>/dev/null | head -1 >/dev/null && features+=("juce")
  printf '%s\n' "${features[@]}" 2>/dev/null | sort -u
}

# =============================================================================
# Build recommended skills
# =============================================================================

build_recommended_skills() {
  local project_type="$1"
  shift
  local features=("$@")
  local recommended=()

  case "$project_type" in
    go) recommended+=(go-master api-design-master security-master) ;;
    python) recommended+=(python-master testing-master) ;;
    javascript) recommended+=(typescript-master testing-master) ;;
    kotlin) recommended+=(mobile-master security-master testing-master) ;;
    cpp) recommended+=(code-review-master testing-master git-master) ;;
    rust) recommended+=(rust-master docker-master) ;;
    bash) recommended+=(git-master testing-master docs-master) ;;
  esac

  for feature in "${features[@]}"; do
    case "$feature" in
      docker) recommended+=(docker-master) ;;
      kubernetes) recommended+=(kubernetes-master monitoring-master) ;;
      ci-cd) recommended+=(ci-cd-master) ;;
      database) recommended+=(database-master) ;;
      react) recommended+=(react-master web-performance-master) ;;
      nextjs) recommended+=(nextjs-master web-performance-master) ;;
      fastapi) recommended+=(api-design-master security-master) ;;
    esac
  done

  recommended+=(git-master docs-master)
  printf '%s\n' "${recommended[@]}" | sort -u
}

# =============================================================================
# Generate config using Python for proper JSON handling
# =============================================================================

generate_config() {
  local project_type="$1"
  local template_file="$TEMPLATES_DIR/${project_type}.json"
  local output_file="$PROJECT_DIR/opencode.json"

  local features=()
  mapfile -t features < <(detect_features "$PROJECT_DIR")

  local available_skills=()
  mapfile -t available_skills < <(detect_available_skills "$PROJECT_DIR")

  local recommended=()
  mapfile -t recommended < <(build_recommended_skills "$project_type" "${features[@]}")

  # Filter to available only
  local active_skills=()
  for skill in "${recommended[@]}"; do
    for available in "${available_skills[@]}"; do
      [[ "$skill" == "$available" ]] && active_skills+=("$skill") && break
    done
  done

  echo -e "${BOLD}Project Analysis:${NC}"
  echo -e "  ${ARROW} Type: ${BOLD}${MAGENTA}$project_type${NC}"
  echo -e "  ${ARROW} Features: ${BOLD}${CYAN}${features[*]:-none}${NC}"
  echo -e "  ${ARROW} Available skills: ${BOLD}${#available_skills[@]}${NC}"
  echo -e "  ${ARROW} Recommended skills: ${BOLD}${#active_skills[@]}${NC}"
  echo ""

  if [[ -f "$template_file" ]]; then
    echo -e "${INFO} Using template: ${BOLD}$project_type.json${NC}"
  else
    echo -e "${WARN} No template for '$project_type', using generic config"
  fi

  # Build skill permissions JSON fragment
  local skill_json=""
  local first=true
  for skill in "${active_skills[@]}"; do
    if $first; then
      skill_json="\"$skill\": \"allow\""
      first=false
    else
      skill_json="$skill_json, \"$skill\": \"allow\""
    fi
  done

  # Use Python for reliable JSON manipulation
  python3 -c "
import json, sys, os

template_file = sys.argv[1]
skill_json = sys.argv[2]
output_file = sys.argv[3]
dry_run = sys.argv[4] == 'true'

# Parse skill permissions
skills = {}
if skill_json:
    pairs = skill_json.split(', ')
    for pair in pairs:
        k, v = pair.split(': ')
        skills[k.strip('\"')] = v.strip('\"')

# Load template or create generic
if os.path.exists(template_file):
    with open(template_file) as f:
        config = json.load(f)
else:
    config = {
        '\$schema': 'https://opencode.ai/config.json',
        'command': {
            'test': {
                'description': 'Run project tests',
                'template': 'Run the test suite and analyze results.'
            },
            'review': {
                'description': 'Review current file',
                'template': 'Review the current file for code quality, bugs, and best practices.'
            }
        },
        'agent': {
            'build': {
                'mode': 'primary',
                'permission': {'edit': 'allow', 'bash': 'allow', 'webfetch': 'allow'}
            }
        },
        'permission': {
            'edit': 'allow',
            'bash': 'allow',
            'webfetch': 'allow',
            'skill': {'*': 'allow'}
        }
    }

# Update skill permissions
if 'permission' not in config:
    config['permission'] = {}
config['permission']['skill'] = {'*': 'allow'}
config['permission']['skill'].update(skills)

# Output
output = json.dumps(config, indent=2)
if dry_run:
    print(output)
else:
    with open(output_file, 'w') as f:
        f.write(output + '\n')
" "$template_file" "$skill_json" "$output_file" "$DRY_RUN"

  if $DRY_RUN; then
    echo -e "${BOLD}${YELLOW}[DRY RUN]${NC} Generated config preview above"
  else
    echo -e "${CHECK} ${GREEN}Config written to:${NC} ${BOLD}$output_file${NC}"
  fi

  echo ""
  echo -e "${BOLD}Active skills in config:${NC}"
  for skill in "${active_skills[@]}"; do
    echo -e "  ${CHECK} $skill"
  done

  echo ""
  echo -e "${BOLD}Skills available but not activated:${NC}"
  for available in "${available_skills[@]}"; do
    local found=false
    for active in "${active_skills[@]}"; do
      [[ "$available" == "$active" ]] && found=true && break
    done
    if ! $found; then
      echo -e "  ${ARROW} $available"
    fi
  done
}

# =============================================================================
# Main
# =============================================================================

main() {
  local project_type
  project_type=$(detect_project_type "$PROJECT_DIR")

  if [[ "$project_type" == "unknown" ]]; then
    echo -e "${WARN} Could not detect project type. Using generic config."
    project_type="generic"
  fi

  generate_config "$project_type"
}

main
