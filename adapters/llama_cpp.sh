#!/bin/bash
#
# llama.cpp server adapter for OpenCode Config Generator
# Endpoints: GET /v1/models, GET /props (context_size)
#

adapter_provider_name() { echo "llama.cpp"; }
adapter_default_port() { echo "8080"; }
adapter_npm_package() { echo "@ai-sdk/openai-compatible"; }
adapter_has_rich_metadata() { return 0; }  # has /props for context

# Fetch models from llama.cpp /v1/models
adapter_fetch_models() {
    local url="$1"

    local models_response
    models_response=$(curl -sf --connect-timeout 5 --max-time 10 "${url}/v1/models" 2>/dev/null)

    # Also try to get context from /props
    local context_size=8192
    local props_response
    props_response=$(curl -sf --connect-timeout 3 --max-time 5 "${url}/props" 2>/dev/null)
    if [[ -n "$props_response" ]]; then
        local ctx
        ctx=$(echo "$props_response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    gs = data.get('default_generation_settings', {})
    print(gs.get('context_size', 8192))
except:
    print(8192)
" 2>/dev/null)
        if [[ -n "$ctx" && "$ctx" -gt 0 ]]; then
            context_size="$ctx"
        fi
    fi

    if [[ -z "$models_response" ]]; then
        echo '{"models": []}'
        return 1
    fi

    # Convert to normalized format
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
        family = ''
        name_lower = model_id.lower()
        if 'llama' in name_lower: family = 'llama'
        elif 'qwen' in name_lower: family = 'qwen'
        elif 'mistral' in name_lower: family = 'mistral'
        elif 'phi' in name_lower: family = 'phi'
        elif 'gemma' in name_lower: family = 'gemma'
        elif 'deepseek' in name_lower: family = 'deepseek'

        result.append({
            'name': model_id,
            'details': {
                'family': family,
                'families': [family] if family else [],
                'parameter_size': '',
                'quantization_level': ''
            },
            'context': ctx_size,
            'type': 'llm'
        })
    print(json.dumps({'models': result}))
except Exception as e:
    print(json.dumps({'models': []}))
" 2>/dev/null || echo '{"models": []}'
}

adapter_get_context() {
    local url="$1"
    local props_response
    props_response=$(curl -sf --connect-timeout 3 --max-time 5 "${url}/props" 2>/dev/null)
    if [[ -n "$props_response" ]]; then
        echo "$props_response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    gs = data.get('default_generation_settings', {})
    print(gs.get('context_size', ''))
except:
    pass
" 2>/dev/null
    fi
}
