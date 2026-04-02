#!/bin/bash
#
# LM Studio adapter for OpenCode Config Generator
# Endpoints: GET /v1/models (basic), GET /api/v1/models (rich)
#

adapter_provider_name() { echo "LM Studio"; }
adapter_npm_package() { echo "@ai-sdk/openai-compatible"; }
adapter_has_rich_metadata() { return 0; }  # true — has /api/v1/models

# Fetch models with rich metadata from LM Studio
# Tries /api/v1/models first (rich), falls back to /v1/models (basic)
adapter_fetch_models() {
    local url="$1"

    # Try rich endpoint first
    local rich_response
    rich_response=$(curl -sf --connect-timeout 5 --max-time 10 "${url}/api/v1/models" 2>/dev/null)

    if [[ -n "$rich_response" ]]; then
        # Parse rich format: {data: [{id, type, capabilities{vision,tool_use}, context_length, ...}]}
        echo "$rich_response" | python3 -c "
import sys, json

try:
    data = json.load(sys.stdin)
    models = data.get('data', [])
    result = []
    for m in models:
        model_id = m.get('id', '')
        if not model_id:
            continue

        model_type = m.get('type', 'llm')
        caps = m.get('capabilities', {})
        ctx = m.get('context_length', m.get('max_context_length', 8192))

        result.append({
            'name': model_id,
            'details': {
                'family': '',
                'families': [],
                'parameter_size': m.get('params_string', ''),
                'quantization_level': m.get('quantization', '')
            },
            'context': ctx,
            'type': model_type,
            'capabilities': caps
        })
    print(json.dumps({'models': result}))
except Exception as e:
    print(f'WARN: lmstudio rich parse error: {e}', file=sys.stderr)
    print(json.dumps({'models': []}))
" 2>/dev/null
        return
    fi

    # Fallback to basic /v1/models
    local basic_response
    basic_response=$(curl -sf --connect-timeout 5 --max-time 10 "${url}/v1/models" 2>/dev/null)

    if [[ -n "$basic_response" ]]; then
        echo "$basic_response" | python3 -c "
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
            'context': 8192,
            'type': 'llm'
        })
    print(json.dumps({'models': result}))
except Exception as e:
    print(f'WARN: lmstudio basic parse error: {e}', file=sys.stderr)
    print(json.dumps({'models': []}))
" 2>/dev/null
    else
        echo '{"models": []}'
    fi
}

# LM Studio doesn't have per-model context endpoint
adapter_get_context() {
    echo ""
}
