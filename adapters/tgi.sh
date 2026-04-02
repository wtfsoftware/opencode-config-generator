#!/bin/bash
#
# TGI (Text Generation Inference by HuggingFace) adapter
# Endpoints: GET /info, GET /v1/models
#

adapter_provider_name() { echo "TGI"; }
adapter_npm_package() { echo "@ai-sdk/openai-compatible"; }
adapter_has_rich_metadata() { return 0; }  # has /info for context

adapter_fetch_models() {
    local url="$1"

    local models_response
    models_response=$(curl -sf --connect-timeout 5 --max-time 10 "${url}/v1/models" 2>/dev/null)

    # Try to get context from /info
    local context_size=4096
    local info_response
    info_response=$(curl -sf --connect-timeout 3 --max-time 5 "${url}/info" 2>/dev/null)
    if [[ -n "$info_response" ]]; then
        local ctx
        ctx=$(echo "$info_response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('max_input_length', data.get('max_total_tokens', 4096)))
except:
    print(4096)
" 2>/dev/null)
        if [[ -n "$ctx" && "$ctx" -gt 0 ]]; then
            context_size="$ctx"
        fi
    fi

    if [[ -z "$models_response" ]]; then
        echo '{"models": []}'
        return 1
    fi

    echo "$models_response" | python3 -c "
import sys, json

ctx_size = int('${context_size}')

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
            'context': ctx_size,
            'type': 'llm'
        })
    print(json.dumps({'models': result}))
except Exception as e:
    print(f'WARN: tgi parse error: {e}', file=sys.stderr)
    print(json.dumps({'models': []}))
" 2>/dev/null || echo '{"models": []}'
}

adapter_get_context() {
    local url="$1"
    local info_response
    info_response=$(curl -sf --connect-timeout 3 --max-time 5 "${url}/info" 2>/dev/null)
    if [[ -n "$info_response" ]]; then
        echo "$info_response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('max_input_length', data.get('max_total_tokens', '')))
except:
    pass
" 2>/dev/null
    fi
}
