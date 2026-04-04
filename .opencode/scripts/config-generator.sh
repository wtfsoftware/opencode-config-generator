#!/usr/bin/env bash
# =============================================================================
# Generate opencode.json configuration for a project
# Analyzes the project and creates an optimized config
# Usage: ./config-generator.sh [project-path]
# =============================================================================

set -uo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

PROJECT_DIR="${1:-$(pwd)}"
OUTPUT_FILE="$PROJECT_DIR/opencode.json"

if [[ ! -d "$PROJECT_DIR" ]]; then
  echo "Project directory not found: $PROJECT_DIR"
  exit 1
fi

echo -e "${BOLD}${CYAN}OpenCode Config Generator${NC}"
echo -e "${BOLD}Analyzing:${NC} $PROJECT_DIR"
echo ""

# Detect project type
PROJECT_TYPE=""
LANGUAGE=""

if [[ -f "$PROJECT_DIR/go.mod" ]]; then
  PROJECT_TYPE="go"
  LANGUAGE="Go"
elif [[ -f "$PROJECT_DIR/package.json" ]]; then
  PROJECT_TYPE="nodejs"
  LANGUAGE="JavaScript/TypeScript"
elif [[ -f "$PROJECT_DIR/pyproject.toml" ]] || [[ -f "$PROJECT_DIR/requirements.txt" ]]; then
  PROJECT_TYPE="python"
  LANGUAGE="Python"
elif [[ -f "$PROJECT_DIR/Cargo.toml" ]]; then
  PROJECT_TYPE="rust"
  LANGUAGE="Rust"
elif [[ -f "$PROJECT_DIR/build.gradle.kts" ]] || [[ -f "$PROJECT_DIR/build.gradle" ]]; then
  PROJECT_TYPE="android"
  LANGUAGE="Kotlin/Android"
elif [[ -f "$PROJECT_DIR/CMakeLists.txt" ]]; then
  PROJECT_TYPE="cpp"
  LANGUAGE="C++"
fi

echo -e "  ${CYAN}Detected:${NC} $LANGUAGE project"
echo ""

# Generate config
cat > "$OUTPUT_FILE" << 'HEADER'
{
  "$schema": "https://opencode.ai/config.json",
HEADER

# Add commands based on project type
echo '  "command": {' >> "$OUTPUT_FILE"

case "$PROJECT_TYPE" in
  go)
    cat >> "$OUTPUT_FILE" << 'GO'
    "test": {
      "description": "Run Go tests with coverage",
      "template": "Run tests with coverage:\n!`go test -v -cover ./...`\n\nAnalyze failures and suggest fixes."
    },
    "build": {
      "description": "Build and vet Go project",
      "template": "Build and vet the project:\n!`go build ./...`\n!`go vet ./...`\n!`golangci-lint run`\n\nFix any issues found."
    },
    "review": {
      "description": "Review Go code",
      "template": "Review the current Go code for:\n- Idiomatic Go patterns\n- Error handling\n- Concurrency issues\n- Interface design\n- Performance\n\nSuggest specific improvements."
    }
GO
    ;;
  nodejs)
    cat >> "$OUTPUT_FILE" << 'NODE'
    "test": {
      "description": "Run tests with coverage",
      "template": "Run the test suite:\n!`npm test`\n\nAnalyze results and suggest improvements for failing tests."
    },
    "lint": {
      "description": "Run linter and fix issues",
      "template": "Run the linter:\n!`npm run lint`\n\nFix all auto-fixable issues and suggest manual fixes for the rest."
    },
    "build": {
      "description": "Build the project",
      "template": "Build the project:\n!`npm run build`\n\nFix any build errors and optimize the output."
    }
NODE
    ;;
  python)
    cat >> "$OUTPUT_FILE" << 'PY'
    "test": {
      "description": "Run pytest with coverage",
      "template": "Run tests:\n!`pytest -v --cov=. --cov-report=term-missing`\n\nAnalyze failures and suggest fixes."
    },
    "lint": {
      "description": "Run ruff and mypy",
      "template": "Run linters:\n!`ruff check .`\n!`mypy .`\n\nFix all issues found."
    },
    "typecheck": {
      "description": "Run mypy type checking",
      "template": "Run type checking:\n!`mypy . --strict`\n\nFix all type errors."
    }
PY
    ;;
  *)
    cat >> "$OUTPUT_FILE" << 'DEFAULT'
    "test": {
      "description": "Run project tests",
      "template": "Run the test suite and analyze results.\n!`ls -la`\n\nIdentify the test command and run it."
    },
    "review": {
      "description": "Review current file",
      "template": "Review the current file for code quality, bugs, and best practices."
    }
DEFAULT
    ;;
esac

echo '  },' >> "$OUTPUT_FILE"

# Add agent configurations
cat >> "$OUTPUT_FILE" << 'AGENTS'
  "agent": {
    "build": {
      "mode": "primary",
      "permission": {
        "edit": "allow",
        "bash": "allow",
        "webfetch": "allow"
      }
    },
    "plan": {
      "mode": "primary",
      "permission": {
        "edit": "ask",
        "bash": "ask",
        "webfetch": "allow"
      }
    }
  },
AGENTS

# Add permission defaults
cat >> "$OUTPUT_FILE" << 'PERMS'
  "permission": {
    "edit": "allow",
    "bash": "allow",
    "webfetch": "allow",
    "skill": {
      "*": "allow"
    }
  }
}
PERMS

echo -e "  ${CHECK} ${GREEN}Config generated:${NC} $OUTPUT_FILE"
echo ""
echo -e "${BOLD}Generated configuration includes:${NC}"
echo -e "  - Project-specific slash commands"
echo -e "  - Agent configurations"
echo -e "  - Default permissions"
echo ""
echo -e "${BOLD}Next steps:${NC}"
echo -e "  1. Review the generated config"
echo -e "  2. Customize commands for your workflow"
echo -e "  3. Add MCP server configurations if needed"
