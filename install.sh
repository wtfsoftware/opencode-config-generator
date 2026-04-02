#!/bin/bash
#
# OpenCode Config Generator — Installer
# Installs generate_opencode_config.sh to ~/.local/bin (or custom path)
#

set -euo pipefail

# Set this to your repository URL after publishing
REPO_URL="${REPO_URL:-https://raw.githubusercontent.com/wtfsoftware/opencode-config-generator}"
BRANCH="${BRANCH:-main}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
VERSION="1.2.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

usage() {
    echo "Usage: install.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --uninstall    Remove installed files"
    echo "  --dir DIR      Install directory (default: ~/.local/bin)"
    echo "  --version VER  Install specific version tag"
    echo "  -h, --help     Show this help"
    exit 0
}

UNINSTALL=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --uninstall) UNINSTALL=true; shift ;;
        --dir) INSTALL_DIR="$2"; shift 2 ;;
        --version) BRANCH="v$2"; shift 2 ;;
        -h|--help) usage ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# Uninstall mode
if [[ "$UNINSTALL" == true ]]; then
    echo -e "${CYAN}Uninstalling OpenCode Config Generator...${NC}"
    rm -f "$INSTALL_DIR/generate_opencode_config.sh"
    rm -rf "$INSTALL_DIR/adapters"
    COMP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/bash-completion/completions"
    rm -f "$COMP_DIR/generate_opencode_config"
    info "Uninstalled from: $INSTALL_DIR"
    exit 0
fi

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
    # Copy metadata if exists
    if [[ -f "./metadata.json" ]]; then
        cp ./metadata.json "$INSTALL_DIR/metadata.json"
    fi
else
    BASE_URL="${REPO_URL}/${BRANCH}"
    info "Downloading from ${BASE_URL}/$SCRIPT_NAME"
    curl -fsSL "${BASE_URL}/$SCRIPT_NAME" -o "$TARGET" || error "Download failed"

    # Verify download (basic: check shebang)
    if ! head -1 "$TARGET" | grep -q "#!/bin/bash"; then
        rm -f "$TARGET"
        error "Downloaded file is not a valid bash script"
    fi

    # Download adapters
    ADAPTERS_DIR="$INSTALL_DIR/adapters"
    mkdir -p "$ADAPTERS_DIR"
    for adapter in base.sh ollama.sh lmstudio.sh llama_cpp.sh openai_generic.sh openai.sh tgi.sh; do
        curl -fsSL "${BASE_URL}/adapters/$adapter" -o "$ADAPTERS_DIR/$adapter" 2>/dev/null || true
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
