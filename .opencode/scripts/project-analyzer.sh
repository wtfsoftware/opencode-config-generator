#!/usr/bin/env bash
# =============================================================================
# Analyze a project's tech stack and recommend relevant skills
# Usage: ./project-analyzer.sh [project-path]
# =============================================================================

set -uo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

PROJECT_DIR="${1:-$(pwd)}"

if [[ ! -d "$PROJECT_DIR" ]]; then
  echo "Project directory not found: $PROJECT_DIR"
  exit 1
fi

echo -e "${BOLD}${CYAN}Project Analyzer for opencode${NC}"
echo -e "${BOLD}Analyzing:${NC} $PROJECT_DIR"
echo ""

# Detect languages and frameworks
declare -A SKILL_SCORES

has_file() { [[ -f "$PROJECT_DIR/$1" ]]; }
has_dir() { [[ -d "$PROJECT_DIR/$1" ]]; }
has_content() { grep -rl "$1" "$PROJECT_DIR" --include="$2" 2>/dev/null | head -1 >/dev/null; }

# Go
if has_file "go.mod" || has_file "go.sum"; then
  echo -e "  ${MAGENTA}Language:${NC} Go"
  SKILL_SCORES[go-master]=10
  SKILL_SCORES[api-design-master]=7
  SKILL_SCORES[docker-master]=6
fi

# Python
if has_file "requirements.txt" || has_file "pyproject.toml" || has_file "setup.py" || has_file "Pipfile"; then
  echo -e "  ${MAGENTA}Language:${NC} Python"
  SKILL_SCORES[python-master]=10
  SKILL_SCORES[testing-master]=7
  SKILL_SCORES[docker-master]=6
  if has_content "fastapi" "*.py" || has_content "flask" "*.py"; then
    SKILL_SCORES[api-design-master]=8
    SKILL_SCORES[security-master]=7
  fi
  if has_content "pytest" "*.py"; then
    SKILL_SCORES[testing-master]=9
  fi
fi

# JavaScript/TypeScript
if has_file "package.json"; then
  echo -e "  ${MAGENTA}Language:${NC} JavaScript/TypeScript"
  SKILL_SCORES[typescript-master]=8
  SKILL_SCORES[testing-master]=7
  
  if has_content "react" "*.json" || has_content "react" "*.js" || has_content "react" "*.tsx"; then
    SKILL_SCORES[react-master]=10
    SKILL_SCORES[web-performance-master]=7
  fi
  if has_content "next" "*.json" || has_content "next" "*.js" || has_content "next" "*.tsx"; then
    SKILL_SCORES[nextjs-master]=10
  fi
  if has_content "express" "*.json" || has_content "fastify" "*.json"; then
    SKILL_SCORES[api-design-master]=8
    SKILL_SCORES[security-master]=7
  fi
  if has_content "jest" "*.json" || has_content "vitest" "*.json" || has_content "mocha" "*.json"; then
    SKILL_SCORES[testing-master]=9
  fi
  if has_content "playwright" "*.json" || has_content "cypress" "*.json"; then
    SKILL_SCORES[testing-master]=9
  fi
fi

# C/C++
if has_file "CMakeLists.txt" || has_file "Makefile" || has_file "configure.ac"; then
  if has_content "juce" "*.txt" || has_content "JUCE" "*.txt" || has_content ".cpp" "*"; then
    echo -e "  ${MAGENTA}Language:${NC} C++"
    SKILL_SCORES[code-review-master]=8
    SKILL_SCORES[testing-master]=7
    SKILL_SCORES[git-master]=6
  fi
fi

# Kotlin/Android
if has_file "build.gradle.kts" || has_file "build.gradle" || has_dir "app/src/main"; then
  echo -e "  ${MAGENTA}Language:${NC} Kotlin/Android"
  SKILL_SCORES[mobile-master]=10
  SKILL_SCORES[security-master]=8
  SKILL_SCORES[testing-master]=7
fi

# Rust
if has_file "Cargo.toml"; then
  echo -e "  ${MAGENTA}Language:${NC} Rust"
  SKILL_SCORES[rust-master]=10
  SKILL_SCORES[docker-master]=6
fi

# Docker
if has_file "Dockerfile" || has_file "docker-compose.yml" || has_file "docker-compose.yaml"; then
  echo -e "  ${MAGENTA}Infrastructure:${NC} Docker"
  SKILL_SCORES[docker-master]=10
fi

# Kubernetes
if has_dir "helm" || has_dir "k8s" || has_dir "kubernetes" || has_file "Chart.yaml"; then
  echo -e "  ${MAGENTA}Infrastructure:${NC} Kubernetes"
  SKILL_SCORES[kubernetes-master]=10
  SKILL_SCORES[monitoring-master]=7
fi

# CI/CD
if has_dir ".github/workflows" || has_file ".gitlab-ci.yml" || has_file "Jenkinsfile"; then
  echo -e "  ${MAGENTA}CI/CD:${NC} Detected"
  SKILL_SCORES[ci-cd-master]=10
fi

# Database
if has_content "postgres" "*" "*.py" || has_content "postgres" "*" "*.js" || has_content "mysql" "*" "*.py" || has_content "mysql" "*" "*.js" || has_content "prisma" "*" "*.ts" || has_content "sqlalchemy" "*" "*.py"; then
  echo -e "  ${MAGENTA}Database:${NC} Detected"
  SKILL_SCORES[database-master]=9
fi

# Security indicators
if has_content "auth" "*" "*.py" || has_content "auth" "*" "*.js" || has_content "jwt" "*" "*.py" || has_content "jwt" "*" "*.js" || has_content "oauth" "*" "*.py" || has_content "oauth" "*" "*.js"; then
  SKILL_SCORES[security-master]=8
fi

# Microservices
if has_dir "services" || has_dir "microservices" || has_content "grpc" "*" "*.go" || has_content "grpc" "*" "*.proto"; then
  echo -e "  ${MAGENTA}Architecture:${NC} Microservices"
  SKILL_SCORES[microservices-master]=10
  SKILL_SCORES[monitoring-master]=8
fi

# Bash/scripts
if has_file "*.sh" || has_file "*.bash"; then
  SKILL_SCORES[git-master]=6
fi

echo ""
echo -e "${BOLD}${GREEN}Recommended skills:${NC}"
echo ""

# Sort by score and display
for skill in "${!SKILL_SCORES[@]}"; do
  echo "${SKILL_SCORES[$skill]} $skill"
done | sort -rn | while read score skill; do
  bar=""
  for ((i=0; i<score; i+=2)); do bar+="█"; done
  if [[ $score -ge 9 ]]; then
    echo -e "  ${GREEN}$bar${NC} ${BOLD}$skill${NC} ($score/10)"
  elif [[ $score -ge 7 ]]; then
    echo -e "  ${YELLOW}$bar${NC} ${BOLD}$skill${NC} ($score/10)"
  else
    echo -e "  ${CYAN}$bar${NC} $skill ($score/10)"
  fi
done

echo ""
echo -e "${BOLD}To install recommended skills:${NC}"
echo -e "  ./install-skills.sh --all ~/.config/opencode"
echo ""
echo -e "${BOLD}To install specific skills:${NC}"
echo -e "  ./install-skills.sh --skill <skill-name> ~/.config/opencode"
