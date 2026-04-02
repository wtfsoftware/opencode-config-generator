#!/bin/bash
#
# Ollama adapter for OpenCode Config Generator
# Endpoints: GET /api/tags, POST /api/show
#

adapter_provider_name() { echo "Ollama"; }
adapter_npm_package() { echo "@ai-sdk/openai-compatible"; }
adapter_has_rich_metadata() { return 0; }  # true — Ollama has /api/show

# Fetch models from Ollama /api/tags
# Returns: JSON array of model objects
adapter_fetch_models() {
    local url="$1"
    curl -sf --connect-timeout 5 --max-time 15 "${url}/api/tags" 2>/dev/null
}

# Get context length for a specific model via /api/show
# Args: $1 = URL, $2 = model name
# Returns: context_length integer or empty
adapter_get_context() {
    local url="$1"
    local model="$2"

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

    echo "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    info = data.get('model_info', {})
    for k, v in info.items():
        if 'context_length' in k:
            print(v)
            break
except Exception as e:
    print(f'WARN: ollama context parse error: {e}', file=sys.stderr)
" 2>/dev/null || echo ""
}
