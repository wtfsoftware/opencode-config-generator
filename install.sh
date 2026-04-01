#!/bin/bash
#
# OpenCode Config Generator — Installer
# Installs generate_opencode_config.sh to ~/.local/bin (or custom path)
#

set -euo pipefail

# Set this to your repository URL after publishing
REPO_URL="${REPO_URL:-https://raw.githubusercontent.com/wtfsoftware/opencode-config-generator/main}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
VERSION="1.1.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

echo -e "${CYAN}OpenCode Config Generator — Installer v${VERSION}${NC}"
echo ""

# Check dependencies
for cmd in curl python3; do
    command -v "$cmd" &>/dev/null || error "$cmd is required but not installed"
done

# Create install directory
mkdir -p "$INSTALL_DIR"

# Download or copy
SCRIPT_NAME="generate_opencode_config.sh"
TARGET="$INSTALL_DIR/$SCRIPT_NAME"

if [[ -f "./$SCRIPT_NAME" ]]; then
    info "Installing from local ./$SCRIPT_NAME"
    cp "./$SCRIPT_NAME" "$TARGET"
    # Copy adapters directory
    if [[ -d "./adapters" ]]; then
        ADAPTERS_DIR="$INSTALL_DIR/adapters"
        mkdir -p "$ADAPTERS_DIR"
        cp ./adapters/*.sh "$ADAPTERS_DIR/"
        info "Adapters installed to: $ADAPTERS_DIR"
    fi
else
    info "Downloading from $REPO_URL/$SCRIPT_NAME"
    curl -fsSL "$REPO_URL/$SCRIPT_NAME" -o "$TARGET" || error "Download failed"
    # Download adapters
    ADAPTERS_DIR="$INSTALL_DIR/adapters"
    mkdir -p "$ADAPTERS_DIR"
    for adapter in base.sh ollama.sh lmstudio.sh llama_cpp.sh openai_generic.sh; do
        curl -fsSL "$REPO_URL/adapters/$adapter" -o "$ADAPTERS_DIR/$adapter" 2>/dev/null || true
    done
    info "Adapters installed to: $ADAPTERS_DIR"
fi

chmod +x "$TARGET"

# Check if INSTALL_DIR is in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo ""
    echo -e "${CYAN}Add to your PATH:${NC}"
    echo ""
    echo "  echo 'export PATH=\"\$PATH:$INSTALL_DIR\"' >> ~/.bashrc"
    echo "  source ~/.bashrc"
    echo ""
fi

# Install shell completions
COMP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/bash-completion/completions"
if [[ -d "$COMP_DIR" ]] || mkdir -p "$COMP_DIR" 2>/dev/null; then
    if [[ -f "./generate_opencode_config.completion.bash" ]]; then
        cp "./generate_opencode_config.completion.bash" "$COMP_DIR/generate_opencode_config"
        info "Bash completion installed"
    fi
fi

info "Installed to: $TARGET"
info "Run: generate_opencode_config.sh --help"
echo ""
info "Done!"
