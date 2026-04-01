#!/bin/bash
#
# Generic OpenAI-compatible adapter for OpenCode Config Generator
# Used by: vLLM, LocalAI, text-generation-webui, Jan.ai, GPT4All
# Endpoint: GET /v1/models
#

adapter_provider_name() { echo "OpenAI-compatible"; }
adapter_default_port() { echo "8000"; }
adapter_npm_package() { echo "@ai-sdk/openai-compatible"; }
adapter_has_rich_metadata() { return 1; }  # false — no rich metadata

# Fetch models from OpenAI-compatible /v1/models
# Returns: JSON array of {name, family, param_size, quantization, context, type}
adapter_fetch_models() {
    local url="$1"

    local response
    if ! response=$(curl -sf --connect-timeout 5 --max-time 15 "${url}/v1/models" 2>/dev/null); then
        echo ""
        return 1
    fi

    # Convert OpenAI format to our normalized format
    echo "$response" | python3 -c "
import sys, json

try:
    data = json.load(sys.stdin)
    models = data.get('data', data.get('models', []))
    result = []
    for m in models:
        model_id = m.get('id', m.get('name', ''))
        if not model_id:
            continue
        result.append({
            'name': model_id,
            'details': {
                'family': '',
                'families': [],
                'parameter_size': '',
                'quantization_level': ''
            },
            'context': 8192,
            'type': 'llm'
        })
    print(json.dumps({'models': result}))
except Exception as e:
    print(json.dumps({'models': []}))
" 2>/dev/null || echo '{"models": []}'
}

# No context lookup for generic OpenAI
adapter_get_context() {
    echo ""
}
