#!/bin/bash
#
# Base adapter interface for OpenCode Config Generator
# All adapters must implement these functions:
#
#   adapter_fetch_models URL → JSON array of {name, family, param_size, quant, context, type}
#   adapter_get_context URL MODEL → context_length or empty
#   adapter_has_rich_metadata → bool
#   adapter_default_port → port number
#   adapter_provider_name → display name
#   adapter_npm_package → npm package for OpenCode config
#

# ============================================================================
# Provider registry
# ============================================================================

declare -A PROVIDER_PORTS=(
    [ollama]=11434
    [lmstudio]=1234
    [vllm]=8000
    [llama-cpp]=8080
    [localai]=8080
    [tgwui]=5000
    [jan]=1337
    [gpt4all]=4891
)

declare -A PROVIDER_NAMES=(
    [ollama]="Ollama"
    [lmstudio]="LM Studio"
    [vllm]="vLLM"
    [llama-cpp]="llama.cpp"
    [localai]="LocalAI"
    [tgwui]="text-generation-webui"
    [jan]="Jan.ai"
    [gpt4all]="GPT4All"
)

# ============================================================================
# Provider detection
# ============================================================================

# Detect provider from URL (port-based heuristic)
# Args: $1 = URL
# Returns: provider name on stdout
detect_provider() {
    local url="$1"
    local port
    port=$(echo "$url" | grep -oP ':\K[0-9]+' | tail -1)

    case "$port" in
        11434) echo "ollama" ;;
        1234)  echo "lmstudio" ;;
        8000)  echo "vllm" ;;
        5000)  echo "tgwui" ;;
        1337)  echo "jan" ;;
        4891)  echo "gpt4all" ;;
        8080)
            # Could be llama-cpp or localai — try both, default to localai
            echo "localai"
            ;;
        *)
            echo "openai-generic"
            ;;
    esac
}

# Load adapter module
# Args: $1 = provider name
load_adapter() {
    local provider="$1"
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    case "$provider" in
        ollama)
            source "${script_dir}/ollama.sh"
            ;;
        lmstudio)
            source "${script_dir}/lmstudio.sh"
            ;;
        llama-cpp)
            source "${script_dir}/llama_cpp.sh"
            ;;
        vllm|localai|tgwui|jan|gpt4all|openai-generic)
            source "${script_dir}/openai_generic.sh"
            ;;
        *)
            log_error "Unknown provider: $provider"
            log_error "Available: ollama, lmstudio, vllm, llama-cpp, localai, tgwui, jan, gpt4all"
            return 1
            ;;
    esac
}

# ============================================================================
# Adapter interface (must be implemented by each adapter)
# ============================================================================
# These are placeholder functions that will be overridden by source'd adapter.
# Each adapter MUST define all of these.

adapter_fetch_models() { echo "ERROR: adapter not loaded"; return 1; }
adapter_get_context()  { echo ""; }
adapter_has_rich_metadata() { return 1; }
adapter_default_port() { echo ""; }
adapter_provider_name() { echo ""; }
adapter_npm_package() { echo "@ai-sdk/openai-compatible"; }

# ============================================================================
# Unified interface (used by main script)
# ============================================================================

# Fetch models from any provider and return normalized JSON
# Args: $1 = URL, $2 = provider, $3 = label
# Returns: JSON array of {name, display, family, param_size, quantization, context, type}
adapter_process_server() {
    local url="$1"
    local provider="$2"
    local label="$3"

    load_adapter "$provider" || return 1

    local raw_models
    raw_models=$(adapter_fetch_models "$url" 2>/dev/null) || {
        log_warn "Could not fetch models from $provider ($url)"
        return 1
    }

    if [[ -z "$raw_models" || "$raw_models" == "[]" ]]; then
        log_warn "No models returned from $provider ($url)"
        return 1
    fi

    echo "$raw_models"
}

# Get provider info for config generation
# Args: $1 = provider
# Returns: JSON {name, npm, default_port}
adapter_get_info() {
    local provider="$1"
    load_adapter "$provider" 2>/dev/null || true

    local name="${PROVIDER_NAMES[$provider]:-$provider}"
    local npm
    npm=$(adapter_npm_package 2>/dev/null || echo "@ai-sdk/openai-compatible")
    local port="${PROVIDER_PORTS[$provider]:-}"

    python3 -c "
import json
print(json.dumps({
    'id': '$provider',
    'name': '$name',
    'npm': '$npm',
    'default_port': '$port'
}))
"
}
