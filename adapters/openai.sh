#!/bin/bash
#
# OpenAI API adapter for OpenCode Config Generator
# Endpoint: GET /v1/models (with Bearer auth)
#

adapter_provider_name() { echo "OpenAI"; }
adapter_npm_package() { echo "@ai-sdk/openai"; }
adapter_has_rich_metadata() { return 1; }  # false — no per-model context

# Fetch models from OpenAI /v1/models
adapter_fetch_models() {
    local url="$1"
    local api_key="${OPENAI_API_KEY:-}"

    local auth_header=""
    if [[ -n "$api_key" ]]; then
        auth_header="-H \"Authorization: Bearer $api_key\""
    fi

    local response
    if ! response=$(curl -sf --connect-timeout 5 --max-time 15 \
        ${auth_header} \
        "${url}/v1/models" 2>/dev/null); then
        echo ""
        return 1
    fi

    echo "$response" | python3 -c "
import sys, json

try:
    data = json.load(sys.stdin)
    models = data.get('data', [])
    result = []
    for m in models:
        model_id = m.get('id', '')
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
            'context': 128000,
            'type': 'llm'
        })
    print(json.dumps({'models': result}))
except Exception as e:
    print(f'WARN: openai parse error: {e}', file=sys.stderr)
    print(json.dumps({'models': []}))
" 2>/dev/null || echo '{"models": []}'
}

adapter_get_context() {
    echo ""
}
