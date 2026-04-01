#!/bin/bash
#
# OpenCode Config Generator for Ollama
# Generates opencode.json configuration from local and remote Ollama servers.
#
# https://github.com/anomalyco/opencode
#

set -euo pipefail

VERSION="1.1.0"

# ============================================================================
# Defaults
# ============================================================================

DEFAULT_OLLAMA="${OLLAMA_HOST:-http://localhost:11434}"
DEFAULT_OUTPUT="opencode.json"
DEFAULT_NUM_CTX=0
CACHE_TTL=86400  # 24 hours in seconds

LOCAL_URL="$DEFAULT_OLLAMA"
REMOTE_URLS=()
LOCAL_PROVIDER=""
REMOTE_PROVIDERS=()
OUTPUT_FILE="$DEFAULT_OUTPUT"
NUM_CTX="$DEFAULT_NUM_CTX"
DRY_RUN=false
INTERACTIVE=false
NO_EMBED=true
NO_CONTEXT_LOOKUP=false
INCLUDE_PATTERNS=()
EXCLUDE_PATTERNS=()
MERGE=false
DEFAULT_MODEL=""
SMALL_MODEL=""
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/opencode-generator"

# ============================================================================
# Colors
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $1" >&2; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1" >&2; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
log_step()  { echo -e "${CYAN}[STEP]${NC} $1" >&2; }

# ============================================================================
# Usage
# ============================================================================

usage() {
    cat <<'EOF'
Usage: generate_opencode_config.sh [OPTIONS]

Generates opencode.json configuration from Ollama models.

OPTIONS:
    -l, --local URL          Local server URL (default: $OLLAMA_HOST or http://localhost:11434)
    -r, --remote URL         Remote server URL (can be specified multiple times)
    -p, --provider NAME      Provider: ollama|lmstudio|vllm|llama-cpp|localai|tgwui|jan|gpt4all
                               (auto-detected by port if not specified)
    -o, --output FILE        Output file path (default: opencode.json, - for stdout)
    -n, --dry-run            Print config to stdout, do not write file
    -i, --interactive        Interactive model selection
        --include PATTERN    Include models matching glob pattern (repeatable)
        --exclude PATTERN    Exclude models matching glob pattern (repeatable)
        --with-embed         Include embedding models (excluded by default)
        --no-context-lookup  Skip /api/show calls, use hardcoded context limits
        --num-ctx N          num_ctx for Ollama models, 0 to omit (default: 0)
        --merge              Merge into existing opencode.json (update models only)
        --default-model ID   Set default model explicitly (e.g. qwen2.5-coder:7b)
        --small-model ID     Set small model explicitly (for title generation)
        --no-cache           Disable context lookup cache
    -v, --version            Show version
    -h, --help               Show this help

EXAMPLES:
    # Local Ollama only
    generate_opencode_config.sh

    # With one remote server
    generate_opencode_config.sh -r http://192.168.1.100:11434

    # Multiple remote servers
    generate_opencode_config.sh -r http://gpu1:11434 -r http://gpu2:11434

    # Interactive selection
    generate_opencode_config.sh -i

    # Only qwen models, no dry-run, write to global config
    generate_opencode_config.sh --include "qwen*" -o ~/.config/opencode/opencode.json

    # Preview without writing
    generate_opencode_config.sh -n

    # Include embedding models
    generate_opencode_config.sh --with-embed

    # Custom num_ctx for tool calling support (adds to provider options)
    generate_opencode_config.sh --num-ctx 32768

    # LM Studio (auto-detected by port 1234)
    generate_opencode_config.sh -l http://localhost:1234

    # vLLM with explicit provider
    generate_opencode_config.sh -l http://localhost:8000 -p vllm

    # Ollama + LM Studio together
    generate_opencode_config.sh -l http://localhost:11434 -r http://localhost:1234 -p lmstudio

ENVIRONMENT VARIABLES:
    OLLAMA_HOST              Default local Ollama URL (used when provider is ollama)
EOF
    exit 0
}

# ============================================================================
# Argument parsing
# ============================================================================

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -l|--local)
                [[ -n "${2:-}" ]] || { log_error "--local requires a URL"; exit 1; }
                LOCAL_URL="$2"
                shift 2
                ;;
            -r|--remote)
                [[ -n "${2:-}" ]] || { log_error "--remote requires a URL"; exit 1; }
                REMOTE_URLS+=("$2")
                shift 2
                ;;
            -p|--provider)
                [[ -n "${2:-}" ]] || { log_error "--provider requires a name"; exit 1; }
                # If local is set and remote not yet, this is local provider
                # Otherwise it's for the last remote
                if [[ ${#REMOTE_URLS[@]} -eq 0 ]]; then
                    LOCAL_PROVIDER="$2"
                else
                    REMOTE_PROVIDERS+=("$2")
                fi
                shift 2
                ;;
            -o|--output)
                [[ -n "${2:-}" ]] || { log_error "--output requires a file path"; exit 1; }
                OUTPUT_FILE="$2"
                shift 2
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -i|--interactive)
                INTERACTIVE=true
                shift
                ;;
            --include)
                [[ -n "${2:-}" ]] || { log_error "--include requires a pattern"; exit 1; }
                INCLUDE_PATTERNS+=("$2")
                shift 2
                ;;
            --exclude)
                [[ -n "${2:-}" ]] || { log_error "--exclude requires a pattern"; exit 1; }
                EXCLUDE_PATTERNS+=("$2")
                shift 2
                ;;
            --with-embed)
                NO_EMBED=false
                shift
                ;;
            --no-context-lookup)
                NO_CONTEXT_LOOKUP=true
                shift
                ;;
            --num-ctx)
                [[ -n "${2:-}" ]] || { log_error "--num-ctx requires a number"; exit 1; }
                NUM_CTX="$2"
                shift 2
                ;;
            --merge)
                MERGE=true
                shift
                ;;
            --default-model)
                [[ -n "${2:-}" ]] || { log_error "--default-model requires a model ID"; exit 1; }
                DEFAULT_MODEL="$2"
                shift 2
                ;;
            --small-model)
                [[ -n "${2:-}" ]] || { log_error "--small-model requires a model ID"; exit 1; }
                SMALL_MODEL="$2"
                shift 2
                ;;
            --no-cache)
                CACHE_DIR=""
                shift
                ;;
            -v|--version)
                echo "generate_opencode_config.sh v${VERSION}"
                exit 0
                ;;
            -h|--help)
                usage
                ;;
            *)
                log_error "Unknown argument: $1"
                echo "Run with --help for usage." >&2
                exit 1
                ;;
        esac
    done
}

# ============================================================================
# Dependency checks
# ============================================================================

check_dependencies() {
    local missing=()

    if ! command -v curl &>/dev/null; then
        missing+=("curl")
    fi

    if ! command -v python3 &>/dev/null; then
        missing+=("python3")
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing[*]}"
        echo "" >&2
        for dep in "${missing[@]}"; do
            case $dep in
                curl)
                    echo "  Install curl:" >&2
                    echo "    Ubuntu/Debian: sudo apt install curl" >&2
                    echo "    macOS:         brew install curl" >&2
                    echo "    Windows:       included in Git Bash" >&2
                    ;;
                python3)
                    echo "  Install python3:" >&2
                    echo "    Ubuntu/Debian: sudo apt install python3" >&2
                    echo "    macOS:         brew install python3" >&2
                    echo "    Windows:       https://python.org/downloads" >&2
                    ;;
            esac
        done
        exit 1
    fi
}

# Validate URL format
validate_url() {
    local url="$1"
    if [[ ! "$url" =~ ^https?:// ]]; then
        log_error "Invalid URL: $url (must start with http:// or https://)"
        return 1
    fi
}

# ============================================================================
# Ollama API helpers
# ============================================================================

# Fetch model list from Ollama /api/tags
# Args: $1 = base URL, $2 = label (for logging)
# Returns: JSON string on stdout, empty on failure
fetch_models() {
    local url="$1"
    local label="$2"
    local response

    log_step "Fetching models from ${label} (${url}/api/tags)..."

    if ! response=$(curl -sf --connect-timeout 5 --max-time 15 "${url}/api/tags" 2>/dev/null); then
        log_warn "Could not connect to ${label} (${url})"
        echo ""
        return 1
    fi

    echo "$response"
}

# Get exact context_length for a model via /api/show
# Args: $1 = base URL, $2 = model name
# Returns: context length integer on stdout, empty on failure
fetch_context_length() {
    local url="$1"
    local model="$2"

    # Use python for safe JSON encoding (handles quotes in model names)
    local json_body
    json_body=$(python3 -c "import json,sys; print(json.dumps({'model': sys.argv[1]}))" "$model" 2>/dev/null) || return 1

    local response
    if ! response=$(curl -sf --connect-timeout 3 --max-time 10 \
        -H "Content-Type: application/json" \
        -d "$json_body" \
        "${url}/api/show" 2>/dev/null); then
        echo ""
        return 1
    fi

    # Extract first context_length from model_info
    echo "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    info = data.get('model_info', {})
    for k, v in info.items():
        if 'context_length' in k:
            print(v)
            break
except:
    pass
" 2>/dev/null || echo ""
}

# Batch-fetch context lengths for all models (parallel background jobs)
# Args: $1 = base URL, $2 = space-separated model names
# Outputs: JSON object { "model_name": context_length, ... }
fetch_context_lengths_batch() {
    local url="$1"
    local models_str="$2"
    local -a models
    read -ra models <<< "$models_str"

    local tmpdir
    tmpdir=$(mktemp -d)
    local pids=()

    # Load cache if enabled
    local cache_file=""
    if [[ -n "$CACHE_DIR" ]]; then
        mkdir -p "$CACHE_DIR"
        local url_hash
        url_hash=$(echo "$url" | md5sum 2>/dev/null | cut -d' ' -f1 || echo "$url" | shasum 2>/dev/null | cut -d' ' -f1 || echo "nocache")
        cache_file="${CACHE_DIR}/ctx_${url_hash}.json"
    fi

    # Load cached values (with TTL check)
    local cached="{}"
    if [[ -n "$cache_file" && -f "$cache_file" ]]; then
        # Check cache age
        local cache_age
        cache_age=$(( $(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null || echo 0) ))
        if [[ $cache_age -gt $CACHE_TTL ]]; then
            log_step "Cache expired ($((cache_age / 3600))h old), refreshing..." >&2
            rm -f "$cache_file"
        else
            cached=$(cat "$cache_file" 2>/dev/null || echo "{}")
        fi
    fi

    # Determine which models need fetching
    local to_fetch=()
    local result_from_cache="{"
    local cache_first=true

    for model in "${models[@]}"; do
        local cached_ctx
        cached_ctx=$(echo "$cached" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    v = d.get('${model}', None)
    print(v if v else '')
except:
    pass
" 2>/dev/null || echo "")

        if [[ -n "$cached_ctx" ]]; then
            if [[ "$cache_first" == true ]]; then
                cache_first=false
            else
                result_from_cache+=", "
            fi
            result_from_cache+="\"${model}\": ${cached_ctx}"
        else
            to_fetch+=("$model")
        fi
    done

    if [[ ${#to_fetch[@]} -gt 0 ]]; then
        log_step "Fetching context lengths for ${#to_fetch[@]} models (${#models[@] - ${#to_fetch[@]}} cached)..." >&2
    else
        log_step "Using cached context lengths for all ${#models[@]} models" >&2
    fi

    # Fetch missing models in parallel
    for i in "${!to_fetch[@]}"; do
        local model="${to_fetch[$i]}"
        (
            local ctx
            ctx=$(fetch_context_length "$url" "$model")
            if [[ -n "$ctx" ]]; then
                echo "\"${model}\": ${ctx}" > "${tmpdir}/${i}.txt"
            fi
        ) &
        pids+=($!)
    done

    # Wait for all background jobs
    for pid in "${pids[@]}"; do
        wait "$pid" 2>/dev/null || true
    done

    # Merge cache + new results
    local result="${result_from_cache}"
    shopt -s nullglob
    for f in "${tmpdir}"/*.txt; do
        [[ -f "$f" ]] || continue
        if [[ "$result" == "{" ]]; then
            # no cache entries, this is first
            true
        elif [[ "$result" == "${result_from_cache}" && "$cache_first" == true ]]; then
            true
        else
            result+=", "
        fi
        result+="$(cat "$f")"
    done
    shopt -u nullglob
    result+="}"

    # Update cache file
    if [[ -n "$cache_file" ]]; then
        # Merge new results into cache
        echo "$result" | python3 -c "
import sys, json
try:
    new_data = json.load(sys.stdin)
except:
    new_data = {}
try:
    with open('${cache_file}', 'r') as f:
        old_data = json.load(f)
except:
    old_data = {}
old_data.update(new_data)
with open('${cache_file}', 'w') as f:
    json.dump(old_data, f)
" 2>/dev/null || true
    fi

    rm -rf "$tmpdir"
    echo "$result"
}

# ============================================================================
# Model filtering
# ============================================================================

# Check if model name matches any include pattern (glob)
matches_include() {
    local name="$1"
    if [[ ${#INCLUDE_PATTERNS[@]} -eq 0 ]]; then
        return 0  # no include filter = include all
    fi
    for pattern in "${INCLUDE_PATTERNS[@]}"; do
        # shellcheck disable=SC2254
        if [[ "$name" == $pattern ]]; then
            return 0
        fi
    done
    return 1
}

# Check if model name matches any exclude pattern (glob)
matches_exclude() {
    local name="$1"
    if [[ ${#EXCLUDE_PATTERNS[@]} -eq 0 ]]; then
        return 1  # no exclude filter = exclude nothing
    fi
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        # shellcheck disable=SC2254
        if [[ "$name" == $pattern ]]; then
            return 0
        fi
    done
    return 1
}

# ============================================================================
# Interactive selection
# ============================================================================

# Args: $1 = JSON array of model objects (name, display, family, param_size, quant, context)
# Returns: JSON array of selected model names
interactive_select() {
    local models_json="$1"

    local count
    count=$(echo "$models_json" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null)

    if [[ "$count" -eq 0 ]]; then
        echo "[]"
        return
    fi

    echo "" >&2
    echo -e "${BOLD}Available models:${NC}" >&2
    echo "" >&2

    # Print numbered list
    echo "$models_json" | python3 -c "
import sys, json
models = json.load(sys.stdin)
print(f'  [{DIM}0{NC}] {BOLD}-- All models --{NC}')
for i, m in enumerate(models, 1):
    name = m['name']
    family = m.get('family', '?').capitalize()
    param = m.get('param_size', '?')
    quant = m.get('quantization', '?')
    ctx = m.get('context', '?')
    print(f'  [{DIM}{i}{NC}] {name:<40} {family:<10} {param:<8} {quant:<10} ctx={ctx}')
" 2>/dev/null

    echo "" >&2
    echo -ne "${BOLD}Select models (comma-separated, e.g. 1,3,5 or 0 for all) [0]: ${NC}" >&2

    local selection
    read -r selection

    # Empty or 0 = all
    if [[ -z "$selection" || "$selection" == "0" ]]; then
        echo "$models_json" | python3 -c "
import sys, json
models = json.load(sys.stdin)
print(json.dumps([m['name'] for m in models]))
" 2>/dev/null
        return
    fi

    # Parse comma-separated indices
    export SELECTION_INPUT="$selection"
    echo "$models_json" | python3 -c "
import os, sys, json
models = json.load(sys.stdin)
selection = os.environ.get('SELECTION_INPUT', '')
indices = []
for s in selection.split(','):
    s = s.strip()
    if s == '0':
        indices = list(range(len(models)))
        break
    try:
        idx = int(s) - 1
        if 0 <= idx < len(models):
            indices.append(idx)
    except ValueError:
        pass
print(json.dumps([models[i]['name'] for i in indices]))
" 2>/dev/null
}

# ============================================================================
# Main Python config generator
# ============================================================================

# All heavy lifting is done in Python to avoid bash JSON pain.
# Environment variables passed:
#   CONFIG_SERVERS_JSON  - JSON array of {url, label, models_json}
#   CONFIG_NUM_CTX       - num_ctx value
#   CONFIG_OUTPUT_FILE   - output file path
#   CONFIG_DRY_RUN       - "true" or "false"
#   CONFIG_NO_EMBED      - "true" or "false"
#   CONFIG_NO_CTX_LOOKUP - "true" or "false"
#   CONFIG_CTX_MAPS      - JSON object { "url": { "model": ctx } }
#   CONFIG_MERGE         - "true" or "false"
#   CONFIG_DEFAULT_MODEL - model ID or empty

generate_config() {
    export CONFIG_SERVERS_JSON="$1"
    export CONFIG_NUM_CTX="$NUM_CTX"
    export CONFIG_OUTPUT_FILE="$OUTPUT_FILE"
    export CONFIG_DRY_RUN="$DRY_RUN"
    export CONFIG_NO_EMBED="$NO_EMBED"
    export CONFIG_NO_CTX_LOOKUP="$NO_CONTEXT_LOOKUP"
    export CONFIG_CTX_MAPS="$2"
    export CONFIG_INCLUDE_PATTERNS="${INCLUDE_PATTERNS[*]:-}"
    export CONFIG_EXCLUDE_PATTERNS="${EXCLUDE_PATTERNS[*]:-}"
    export CONFIG_MERGE="$MERGE"
    export CONFIG_DEFAULT_MODEL="$DEFAULT_MODEL"
    export CONFIG_SMALL_MODEL="$SMALL_MODEL"

    python3 <<'PYEOF'
import os
import sys
import json
import fnmatch
from collections import OrderedDict

servers_json = os.environ.get("CONFIG_SERVERS_JSON", "[]")
num_ctx = int(os.environ.get("CONFIG_NUM_CTX", "0"))
output_file = os.environ.get("CONFIG_OUTPUT_FILE", "opencode.json")
dry_run = os.environ.get("CONFIG_DRY_RUN", "false") == "true"
no_embed = os.environ.get("CONFIG_NO_EMBED", "true") == "true"
no_ctx_lookup = os.environ.get("CONFIG_NO_CTX_LOOKUP", "false") == "true"
ctx_maps_str = os.environ.get("CONFIG_CTX_MAPS", "{}")
include_str = os.environ.get("CONFIG_INCLUDE_PATTERNS", "").strip()
exclude_str = os.environ.get("CONFIG_EXCLUDE_PATTERNS", "").strip()
merge_mode = os.environ.get("CONFIG_MERGE", "false") == "true"
default_model = os.environ.get("CONFIG_DEFAULT_MODEL", "").strip()
small_model_override = os.environ.get("CONFIG_SMALL_MODEL", "").strip()

include_patterns = include_str.split() if include_str else []
exclude_patterns = exclude_str.split() if exclude_str else []

EMBED_KEYWORDS = {"nomic-bert", "bert", "bert-moe", "embed", "embedding", "jina-embeddings"}

HARDCODED_CONTEXT = {
    "qwen": 32768, "llama": 8192, "mistral": 32768, "mixtral": 32768,
    "deepseek": 65536, "gemma": 8192, "phi": 4096, "command": 131072,
    "yi": 200000, "codestral": 32768, "command-r": 131072, "granite": 8192,
    "internlm": 32768, "falcon": 8192, "orca": 4096, "neural-chat": 4096,
    "starcoder": 8192, "codegemma": 8192,
}

# --- Helpers ---

def parse_json(s):
    try:
        return json.loads(s)
    except json.JSONDecodeError:
        return None

def is_embed_model(families, name=""):
    all_text = " ".join(f.lower() for f in families) + " " + name.lower()
    return any(kw in all_text for kw in EMBED_KEYWORDS)

def get_hardcoded_context(family):
    fl = family.lower()
    for key, ctx in HARDCODED_CONTEXT.items():
        if key in fl:
            return ctx
    return 8192

def matches_include(name):
    if not include_patterns:
        return True
    return any(fnmatch.fnmatch(name, p) for p in include_patterns)

def matches_exclude(name):
    return any(fnmatch.fnmatch(name, p) for p in exclude_patterns)

def parse_param_size(param_str):
    """Parse '3.6B', '475.29M' etc. into a number."""
    try:
        ps = param_str.upper().strip()
        mult = 1
        if "B" in ps:
            mult = 1_000_000_000
        elif "M" in ps:
            mult = 1_000_000
        val = float(ps.replace("B", "").replace("M", "").strip())
        return val * mult
    except (ValueError, AttributeError):
        return float("inf")

# --- Process models from servers ---

def process_models(server_data, ctx_map):
    label = server_data["label"]
    raw_models = server_data.get("models", [])
    result = OrderedDict()

    for m in raw_models:
        name = m.get("name", "")
        if not name:
            continue

        details = m.get("details", {})
        family = details.get("family", "")
        families = details.get("families", [])
        param_size = details.get("parameter_size", "")
        quant = details.get("quantization_level", "")

        if no_embed and is_embed_model(families + ([family] if family else []), name):
            continue
        if not matches_include(name):
            continue
        if matches_exclude(name):
            continue

        if not no_ctx_lookup and name in ctx_map and ctx_map[name]:
            context_length = int(ctx_map[name])
            ctx_source = "api"
        else:
            context_length = get_hardcoded_context(family)
            ctx_source = "hardcoded"

        display_parts = []
        if family:
            display_parts.append(family.capitalize())
        if param_size:
            display_parts.append(param_size)
        if quant:
            display_parts.append(quant)
        display_name = " ".join(display_parts) if display_parts else name
        display_name += f" ({label})"

        result[name] = {
            "name": display_name,
            "limit": {
                "context": context_length,
                "output": min(context_length, 16384),
            },
            "_info": {
                "name": name, "display": display_name, "family": family,
                "param_size": param_size, "quantization": quant,
                "context": context_length, "ctx_source": ctx_source,
                "server_label": label, "server_url": server_data.get("url", ""),
            },
        }

    return result

# --- Main ---

servers = parse_json(servers_json) or []
ctx_maps = parse_json(ctx_maps_str) or {}

if not servers:
    print("ERROR: No server data provided", file=sys.stderr)
    sys.exit(1)

# Process all servers
all_models = OrderedDict()
server_model_maps = {}
model_sources = {}  # name -> list of (label, url)

for idx, server in enumerate(servers):
    ctx_map = ctx_maps.get(server["url"], {})
    models = process_models(server, ctx_map)

    pid = "ollama" if (len(servers) == 1 or idx == 0) else f"ollama-{idx + 1}"
    server_model_maps[pid] = {"url": server["url"], "label": server["label"], "models": models}

    for name, data in models.items():
        if name not in model_sources:
            model_sources[name] = []
        model_sources[name].append((server["label"], server["url"]))

# Build all_models with server suffixes for duplicates
# First server keeps original name, others get @host:port, @host:port-2, etc.
dup_info = {}  # name -> list of suffixed names for logging

for name in model_sources:
    sources = model_sources[name]
    if len(sources) == 1:
        # No duplicate, add model as-is
        for pid, pd in server_model_maps.items():
            if name in pd["models"]:
                all_models[name] = pd["models"][name]
                break
    else:
        # Duplicate: generate suffixes
        suffixed_names = []
        suffix_counter = {}
        for label, url in sources:
            try:
                from urllib.parse import urlparse
                parsed = urlparse(url)
                host = parsed.hostname or label
                port = parsed.port
                suffix_base = f"{host}:{port}" if port and port not in (80, 443) else host
            except Exception:
                suffix_base = label

            if suffix_base not in suffix_counter:
                suffix_counter[suffix_base] = 0
            suffix_counter[suffix_base] += 1

            count = suffix_counter[suffix_base]
            suffixed = f"{name}@{suffix_base}" if count == 1 else f"{name}@{suffix_base}-{count}"
            suffixed_names.append(suffixed)

        dup_info[name] = suffixed_names

        # Add each version: update both all_models AND server_model_maps
        for idx, (label, url) in enumerate(sources):
            suffixed_name = suffixed_names[idx]
            for pid, pd in server_model_maps.items():
                if pd["url"] == url and name in pd["models"]:
                    model_data = pd["models"][name].copy()
                    info = model_data["_info"]
                    suffix_display = suffixed_name.split("@", 1)[1] if "@" in suffixed_name else ""
                    model_data["name"] = f'{info["display"].rsplit(" (", 1)[0]} ({suffix_display})'

                    # Rename in server_model_maps (for provider_config)
                    del pd["models"][name]
                    pd["models"][suffixed_name] = model_data

                    all_models[suffixed_name] = model_data
                    break

if dup_info:
    print("Deduplication: models found on multiple servers:", file=sys.stderr)
    for orig_name, suffixed_list in dup_info.items():
        print(f"  - {orig_name} -> {', '.join(suffixed_list)}", file=sys.stderr)

if not all_models:
    print("WARNING: No models found after filtering!", file=sys.stderr)
    print("  - Check if Ollama is running", file=sys.stderr)
    print("  - Check include/exclude patterns", file=sys.stderr)
    if no_embed:
        print("  - Try --with-embed to include embedding models", file=sys.stderr)

# --- Merge with existing config ---

if merge_mode and os.path.exists(output_file):
    try:
        with open(output_file, "r", encoding="utf-8") as f:
            existing = json.load(f, object_pairs_hook=OrderedDict)
        print(f"Merge: loading existing config from {output_file}", file=sys.stderr)
    except Exception as e:
        print(f"Merge: could not read existing config: {e}", file=sys.stderr)
        existing = None
else:
    existing = None

# --- Build provider config ---

PROVIDER_DISPLAY = {
    "ollama": "Ollama", "lmstudio": "LM Studio", "vllm": "vLLM",
    "llama-cpp": "llama.cpp", "localai": "LocalAI", "tgwui": "text-generation-webui",
    "jan": "Jan.ai", "gpt4all": "GPT4All", "openai-generic": "OpenAI-compatible",
}

def make_options(url):
    opts = {"baseURL": f"{url}/v1"}
    if num_ctx > 0:
        opts["num_ctx"] = num_ctx
    return opts

clean = lambda m: {k: v for k, v in m.items() if k != "_info"}
provider_config = OrderedDict()

# Group servers by provider type
provider_groups = OrderedDict()
for idx, server in enumerate(servers):
    prov = server.get("provider", "ollama")
    if prov not in provider_groups:
        provider_groups[prov] = []
    provider_groups[prov].append((idx, server))

# Build one provider per provider type (combined models from same provider type)
for prov, server_list in provider_groups.items():
    display_name = PROVIDER_DISPLAY.get(prov, prov.capitalize())
    combined_models = OrderedDict()
    primary_url = server_list[0][1]["url"]

    for _, server in server_list:
        for pid_key, pd in server_model_maps.items():
            if pd.get("url") == server["url"]:
                for mid, mdata in pd["models"].items():
                    combined_models[mid] = clean(mdata)

    if len(server_list) > 1:
        display_name = f"{display_name} ({len(server_list)} servers)"

    provider_config[prov] = {
        "npm": "@ai-sdk/openai-compatible",
        "name": display_name,
        "options": make_options(primary_url),
        "models": combined_models,
    }

# If only one provider type, use simple name
if len(provider_config) == 1:
    prov = next(iter(provider_config))
    provider_config[prov]["name"] = PROVIDER_DISPLAY.get(prov, prov.capitalize())

# --- Merge: keep other providers from existing config ---

if existing and isinstance(existing.get("provider"), dict):
    for prov_id, prov_data in existing["provider"].items():
        if prov_id not in provider_config:
            provider_config[prov_id] = prov_data
            print(f"Merge: kept existing provider '{prov_id}'", file=sys.stderr)

# --- Default model ---

if default_model:
    if default_model in all_models:
        first_model = default_model
        print(f"Default model set to: {first_model}", file=sys.stderr)
    else:
        # Try with ollama/ prefix stripped
        clean_id = default_model.replace("ollama/", "")
        if clean_id in all_models:
            first_model = clean_id
            print(f"Default model set to: {first_model}", file=sys.stderr)
        else:
            first_model = next(iter(all_models.keys()), "llama3.2")
            print(f"WARNING: --default-model '{default_model}' not found, using {first_model}", file=sys.stderr)
else:
    first_model = next(iter(all_models.keys()), "llama3.2")

# small_model = smallest non-embed model (or override)
small_model = first_model
if small_model_override:
    clean_sm = small_model_override.replace("ollama/", "")
    # Search in all_models (may have suffix)
    found_sm = None
    for k in all_models:
        if k == clean_sm or k.startswith(clean_sm + "@"):
            found_sm = k
            break
    if found_sm:
        small_model = found_sm
        print(f"Small model set to: {small_model}", file=sys.stderr)
    else:
        print(f"WARNING: --small-model '{small_model_override}' not found, using auto-detect", file=sys.stderr)

if small_model == first_model:
    smallest_params = float("inf")
    for name, data in all_models.items():
        if is_embed_model([], name):
            continue
        p = parse_param_size(data.get("_info", {}).get("param_size", ""))
        if 0 < p < smallest_params:
            smallest_params = p
            small_model = name

# --- Build final config ---

config = OrderedDict()
if existing and "$schema" in existing:
    config["$schema"] = existing["$schema"]
else:
    config["$schema"] = "https://opencode.ai/config.json"

config["provider"] = provider_config
# Determine provider prefix for model reference
first_provider = next(iter(provider_config), "ollama")
config["model"] = f"{first_provider}/{first_model}"
if small_model != first_model:
    config["small_model"] = f"{first_provider}/{small_model}"

# Merge: keep other top-level keys from existing
if existing:
    for key in existing:
        if key not in config:
            config[key] = existing[key]

# Validate
try:
    json_str = json.dumps(config, indent=2, ensure_ascii=False)
    json.loads(json_str)
except Exception as e:
    print(f"ERROR: Generated invalid JSON: {e}", file=sys.stderr)
    sys.exit(1)

# Output
if dry_run or output_file == "-":
    print(json_str)
else:
    with open(output_file, "w", encoding="utf-8") as f:
        f.write(json_str)

# --- Summary ---

total = len(all_models)
skipped_embed = sum(
    1 for s in servers for m in s.get("models", [])
    if is_embed_model(m.get("details", {}).get("families", []) + [m.get("details", {}).get("family", "")], m.get("name", ""))
)
api_ctx = sum(1 for d in all_models.values() if d["_info"]["ctx_source"] == "api")
hardcoded_ctx = sum(1 for d in all_models.values() if d["_info"]["ctx_source"] == "hardcoded")

print("", file=sys.stderr)
print("Results:", file=sys.stderr)
print(f"  Models included:      {total}", file=sys.stderr)
if skipped_embed > 0:
    print(f"  Embedding filtered:   {skipped_embed}", file=sys.stderr)
if dup_info:
    print(f"  Duplicates (suffixed): {len(dup_info)}", file=sys.stderr)
if api_ctx > 0 or hardcoded_ctx > 0:
    print(f"  Context from API:     {api_ctx}", file=sys.stderr)
    print(f"  Context hardcoded:    {hardcoded_ctx}", file=sys.stderr)
print(f"  Default model:        {first_model}", file=sys.stderr)
if small_model != first_model:
    print(f"  Small model:          {small_model}", file=sys.stderr)
if num_ctx > 0:
    print(f"  num_ctx:              {num_ctx}", file=sys.stderr)
if merge_mode:
    print(f"  Merge mode:           on", file=sys.stderr)

print("", file=sys.stderr)
print("Models:", file=sys.stderr)
for name, data in all_models.items():
    info = data["_info"]
    fam = info["family"].capitalize() if info["family"] else "?"
    par = info["param_size"] or "?"
    qua = info["quantization"] or "?"
    ctx = info["context"]
    tag = "" if info["ctx_source"] == "api" else " (hardcoded)"
    print(f"  - {name}  {fam} {par} {qua} ctx={ctx}{tag}", file=sys.stderr)

if dry_run:
    print("", file=sys.stderr)
    print("(Dry-run mode: config printed above, not written to file)", file=sys.stderr)
elif output_file == "-":
    print("", file=sys.stderr)
    print("(Output to stdout)", file=sys.stderr)
else:
    print("", file=sys.stderr)
    print(f"Config written to: {output_file}", file=sys.stderr)

PYEOF
}

# ============================================================================
# Main
# ============================================================================

main() {
    parse_args "$@"
    check_dependencies

    # Load adapters base
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "${script_dir}/adapters/base.sh"

    echo -e "${CYAN}========================================${NC}" >&2
    echo -e "${CYAN}  OpenCode Config Generator${NC}" >&2
    echo -e "${CYAN}========================================${NC}" >&2
    echo "" >&2

    # Validate URLs
    validate_url "$LOCAL_URL" || exit 1
    for rurl in "${REMOTE_URLS[@]}"; do
        validate_url "$rurl" || exit 1
    done

    # Auto-detect providers if not specified
    if [[ -z "$LOCAL_PROVIDER" ]]; then
        LOCAL_PROVIDER=$(detect_provider "$LOCAL_URL")
        log_step "Auto-detected provider: ${LOCAL_PROVIDER} ($LOCAL_URL)"
    fi

    # Collect all servers data via process_server
    local servers_json="["
    local ctx_maps="{"
    local first_server=true

    # Process local server
    process_server "$LOCAL_URL" "$LOCAL_PROVIDER" "local" "local"

    # Process remote servers
    for i in "${!REMOTE_URLS[@]}"; do
        local remote_url="${REMOTE_URLS[$i]}"
        local remote_provider="${REMOTE_PROVIDERS[$i]:-}"
        if [[ -z "$remote_provider" ]]; then
            remote_provider=$(detect_provider "$remote_url")
        fi
        process_server "$remote_url" "$remote_provider" "remote" "remote"
    done

    servers_json+="]"
    ctx_maps+="}"

    # Check if we have any data
    local model_count
    model_count=$(echo "$servers_json" | python3 -c "
import sys, json
servers = json.load(sys.stdin)
total = sum(len(s.get('models', [])) for s in servers)
print(total)
" 2>/dev/null || echo "0")

    if [[ "$model_count" -eq 0 ]]; then
        log_error "Could not fetch models from any server."
        log_error "Make sure the server is running and accessible."
        exit 1
    fi

    log_step "Generating configuration..."

    generate_config "$servers_json" "$ctx_maps"

    log_info "Done!"
}

# Process a server: fetch models via adapter, get context, handle interactive
# Args: $1=url, $2=provider, $3=label (local/remote), $4=server_label for display
process_server() {
    local server_url="$1"
    local provider="$2"
    local label="$3"
    local display_label="$4"

    # Load adapter
    load_adapter "$provider" || {
        log_warn "Unknown provider: $provider, skipping $server_url"
        return
    }

    local provider_name
    provider_name=$(adapter_provider_name)

    log_step "Fetching models from ${provider_name} (${server_url})..."

    # Fetch models via adapter
    local models_json
    models_json=$(adapter_fetch_models "$server_url" || true)

    if [[ -z "$models_json" || "$models_json" == '{"models":[]}' ]]; then
        log_warn "No models returned from ${provider_name} ($server_url)"
        return
    fi

    # Get model names for context lookup
    local model_names
    model_names=$(echo "$models_json" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(' '.join(m['name'] for m in d.get('models', [])))
except:
    pass
" 2>/dev/null || echo "")

    # Fetch context lengths (only if adapter supports it)
    local ctx_json="{}"
    if [[ "$NO_CONTEXT_LOOKUP" == false && -n "$model_names" ]]; then
        if adapter_has_rich_metadata 2>/dev/null; then
            ctx_json=$(fetch_context_lengths_batch "$server_url" "$model_names" || echo "{}")
        else
            # Try adapter_get_context for per-model context (e.g., llama.cpp /props)
            local adapter_ctx
            adapter_ctx=$(adapter_get_context "$server_url" 2>/dev/null || echo "")
            if [[ -n "$adapter_ctx" ]]; then
                ctx_json=$(echo "$model_names" | tr ' ' '\n' | python3 -c "
import sys
ctx = '${adapter_ctx}'
result = '{'
first = True
for name in sys.stdin:
    name = name.strip()
    if name:
        if not first: result += ', '
        result += f'\"{name}\": {ctx}'
        first = False
result += '}'
print(result)
" 2>/dev/null || echo "{}")
            fi
        fi
    fi

    # Interactive selection
    local selected_models="$models_json"
    if [[ "$INTERACTIVE" == true ]]; then
        local models_for_select
        models_for_select=$(echo "$models_json" | python3 -c "
import sys, json
d = json.load(sys.stdin)
result = []
for m in d.get('models', []):
    details = m.get('details', {})
    result.append({
        'name': m['name'],
        'family': details.get('family', ''),
        'param_size': details.get('parameter_size', ''),
        'quantization': details.get('quantization_level', ''),
        'context': m.get('context', 8192),
    })
print(json.dumps(result))
" 2>/dev/null || echo "[]")

        local selected_names
        selected_names=$(interactive_select "$models_for_select")

        export SELECTED_NAMES="$selected_names"
        selected_models=$(echo "$models_json" | python3 -c "
import os, sys, json
d = json.load(sys.stdin)
selected = json.loads(os.environ.get('SELECTED_NAMES', '[]'))
d['models'] = [m for m in d.get('models', []) if m['name'] in selected]
print(json.dumps(d))
" 2>/dev/null || echo "$models_json")
    fi

    # Append to global servers_json and ctx_maps
    if [[ "$first_server" == true ]]; then
        first_server=false
    else
        servers_json+=","
        ctx_maps+=","
    fi

    export SERVER_URL="$server_url"
    export SERVER_PROVIDER="$provider"
    servers_json+=$(echo "$selected_models" | python3 -c "
import os, sys, json
d = json.load(sys.stdin)
print(json.dumps({
    'url': os.environ.get('SERVER_URL', ''),
    'label': '${label}',
    'provider': os.environ.get('SERVER_PROVIDER', 'unknown'),
    'models': d.get('models', [])
}))
" 2>/dev/null || echo "{}")

    ctx_maps+="\"${server_url}\": ${ctx_json}"
}

main "$@"
