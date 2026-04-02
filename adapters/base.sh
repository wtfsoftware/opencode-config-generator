#!/bin/bash
#
# Base adapter interface for OpenCode Config Generator
# All adapters must implement these functions:
#
#   adapter_fetch_models URL → JSON array of {name, family, param_size, quant, type}
#   adapter_get_context URL MODEL → context_length or empty
#   adapter_has_rich_metadata → bool
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
    [openai]=443
    [tgi]=8080
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
    [openai]="OpenAI"
    [tgi]="TGI"
)

# ============================================================================
# Family detection (shared by all adapters)
# ============================================================================

# Detect model family from name
# Args: $1 = model name
# Returns: family name on stdout
detect_family_from_name() {
    local name_lower="${1,,}"
    case "$name_lower" in
        *qwen3*)    echo "qwen3" ;;
        *qwen2.5*)  echo "qwen2.5" ;;
        *qwen2*)    echo "qwen2" ;;
        *qwen*)     echo "qwen" ;;
        *llama3*)   echo "llama3" ;;
        *llama2*)   echo "llama2" ;;
        *llama*)    echo "llama" ;;
        *deepseek-r1*) echo "deepseek-r1" ;;
        *deepseek-v3*) echo "deepseek-v3" ;;
        *deepseek*) echo "deepseek" ;;
        *mistral-nemo*) echo "mistral-nemo" ;;
        *mistral*)  echo "mistral" ;;
        *mixtral*)  echo "mixtral" ;;
        *gemma2*)   echo "gemma2" ;;
        *gemma*)    echo "gemma" ;;
        *phi4*)     echo "phi4" ;;
        *phi3*)     echo "phi3" ;;
        *phi*)      echo "phi" ;;
        *command-r-plus*) echo "command-r-plus" ;;
        *command-r*) echo "command-r" ;;
        *command*)  echo "command" ;;
        *codestral*) echo "codestral" ;;
        *granite3*) echo "granite3" ;;
        *granite*)  echo "granite" ;;
        *internlm2*) echo "internlm2" ;;
        *internlm*) echo "internlm" ;;
        *falcon*)   echo "falcon" ;;
        *starcoder2*) echo "starcoder2" ;;
        *starcoder*) echo "starcoder" ;;
        *codegemma*) echo "codegemma" ;;
        *nemotron*) echo "nemotron" ;;
        *jamba*)    echo "jamba" ;;
        *exaone*)   echo "exaone" ;;
        *minicpm*)  echo "minicpm" ;;
        *)          echo "" ;;
    esac
}

# ============================================================================
# Provider detection
# ============================================================================

# Detect provider from URL (port-based heuristic)
# Args: $1 = URL
# Returns: provider name on stdout
detect_provider() {
    local url="$1"
    local port
    port=$(echo "$url" | sed -n 's/.*:\([0-9]\+\).*/\1/p' | tail -1)

    case "$port" in
        11434) echo "ollama" ;;
        1234)  echo "lmstudio" ;;
        8000)  echo "vllm" ;;
        5000)  echo "tgwui" ;;
        1337)  echo "jan" ;;
        4891)  echo "gpt4all" ;;
        8080)
            echo "localai"
            log_warn "Port 8080 detected — defaulting to LocalAI. Use -p llama-cpp or -p tgi if needed."
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
        openai)
            source "${script_dir}/openai.sh"
            ;;
        tgi)
            source "${script_dir}/tgi.sh"
            ;;
        vllm|localai|tgwui|jan|gpt4all|openai-generic)
            source "${script_dir}/openai_generic.sh"
            ;;
        *)
            log_error "Unknown provider: $provider"
            log_error "Available: ollama, lmstudio, vllm, llama-cpp, localai, tgwui, jan, gpt4all, openai, tgi"
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
