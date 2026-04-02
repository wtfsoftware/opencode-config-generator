#!/bin/bash
#
# Smoke tests for OpenCode Config Generator
# Run: bash smoke_test.sh
#

set -uo pipefail

SCRIPT="./generate_opencode_config.sh"
PASS=0
FAIL=0
SKIP=0
TOTAL=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "  ${GREEN}PASS${NC} $1"; ((PASS++)); ((TOTAL++)); }
fail() { echo -e "  ${RED}FAIL${NC} $1"; ((FAIL++)); ((TOTAL++)); }
skip() { echo -e "  ${YELLOW}SKIP${NC} $1"; ((SKIP++)); ((TOTAL++)); }

# Check if script exists
if [[ ! -f "$SCRIPT" ]]; then
    echo "ERROR: $SCRIPT not found"
    exit 1
fi

# Check if Ollama is running
OLLAMA_UP=false
if curl -sf --connect-timeout 2 http://localhost:11434/api/tags >/dev/null 2>&1; then
    OLLAMA_UP=true
fi

echo "OpenCode Config Generator — Smoke Tests"
echo "========================================"
echo ""

# --- Syntax ---
echo "[Syntax]"
if bash -n "$SCRIPT" 2>/dev/null; then
    pass "bash syntax check"
else
    fail "bash syntax check"
fi

# --- CLI flags ---
echo ""
echo "[CLI Flags]"

if $SCRIPT --version 2>&1 | grep -q "v"; then
    pass "--version outputs version"
else
    fail "--version outputs version"
fi

if $SCRIPT --help 2>&1 | grep -q "Usage:"; then
    pass "--help shows usage"
else
    fail "--help shows usage"
fi

# --- URL validation ---
echo ""
echo "[Validation]"

output=$($SCRIPT -l "bad-url" 2>&1 || true)
if echo "$output" | grep -q "Invalid URL"; then
    pass "rejects invalid URL"
else
    fail "rejects invalid URL"
fi

output=$($SCRIPT -r "not-a-url" 2>&1 || true)
if echo "$output" | grep -q "Invalid URL"; then
    pass "rejects invalid remote URL"
else
    fail "rejects invalid remote URL"
fi

# --- Generation (requires Ollama) ---
echo ""
echo "[Generation]"

if [[ "$OLLAMA_UP" == false ]]; then
    skip "all generation tests (Ollama not running)"
else

    # Basic dry-run
    if $SCRIPT -n --no-context-lookup 2>/dev/null | python3 -c "
import sys,json
d=json.load(sys.stdin)
assert d.get('\$schema')
assert 'ollama' in d['provider']
assert len(d['provider']['ollama']['models']) > 0
assert d['model'].startswith('ollama/')
" 2>/dev/null; then
        pass "basic dry-run generates valid config"
    else
        fail "basic dry-run generates valid config"
    fi

    # Include filter
    result=$($SCRIPT -n --no-context-lookup --include "qwen2.5-coder:7b" 2>/dev/null)
    count=$(echo "$result" | python3 -c "import sys,json; print(len(json.load(sys.stdin)['provider']['ollama']['models']))" 2>/dev/null)
    if [[ "$count" == "1" ]]; then
        pass "--include filters to 1 model"
    else
        fail "--include filters to 1 model (got $count)"
    fi

    # Exclude filter
    result=$($SCRIPT -n --no-context-lookup --exclude "*qwen*" 2>/dev/null)
    has_qwen=$(echo "$result" | python3 -c "
import sys,json
d=json.load(sys.stdin)
print(any('qwen' in k for k in d['provider']['ollama']['models']))
" 2>/dev/null)
    if [[ "$has_qwen" == "False" ]]; then
        pass "--exclude removes matching models"
    else
        fail "--exclude removes matching models"
    fi

    # With embed
    result=$($SCRIPT -n --no-context-lookup --with-embed 2>/dev/null)
    has_embed=$(echo "$result" | python3 -c "
import sys,json
d=json.load(sys.stdin)
print(any('embed' in k.lower() or 'nomic' in k.lower() for k in d['provider']['ollama']['models']))
" 2>/dev/null)
    if [[ "$has_embed" == "True" ]]; then
        pass "--with-embed includes embedding models"
    else
        fail "--with-embed includes embedding models"
    fi

    # Default model
    result=$($SCRIPT -n --no-context-lookup --default-model "qwen2.5-coder:7b" --include "qwen2.5-coder:*" 2>/dev/null)
    if echo "$result" | python3 -c "import sys,json; assert 'qwen2.5-coder:7b' in json.load(sys.stdin)['model']" 2>/dev/null; then
        pass "--default-model sets default"
    else
        fail "--default-model sets default"
    fi

    # Small model
    result=$($SCRIPT -n --no-context-lookup --small-model "qwen2.5-coder:3b" --include "qwen2.5-coder:*" 2>/dev/null)
    if echo "$result" | python3 -c "import sys,json; assert 'qwen2.5-coder:3b' in json.load(sys.stdin).get('small_model','')" 2>/dev/null; then
        pass "--small-model sets small model"
    else
        fail "--small-model sets small model"
    fi

    # Num ctx
    result=$($SCRIPT -n --no-context-lookup --num-ctx 32768 2>/dev/null)
    ctx=$(echo "$result" | python3 -c "import sys,json; print(json.load(sys.stdin)['provider']['ollama']['options'].get('num_ctx',0))" 2>/dev/null)
    if [[ "$ctx" == "32768" ]]; then
        pass "--num-ctx adds to provider options"
    else
        fail "--num-ctx adds to provider options (got $ctx)"
    fi

    # Output to stdout
    if $SCRIPT --output - --no-context-lookup 2>/dev/null | python3 -c "import sys,json; json.load(sys.stdin)" 2>/dev/null; then
        pass "--output - writes to stdout"
    else
        fail "--output - writes to stdout"
    fi

    # Dedup with same server twice
    result=$($SCRIPT -n --no-context-lookup --include "qwen2.5-coder:7b" -r http://localhost:11434 2>/dev/null)
    has_suffix=$(echo "$result" | python3 -c "
import sys,json
d=json.load(sys.stdin)
print(any('@' in k for k in d['provider']['ollama']['models']))
" 2>/dev/null)
    if [[ "$has_suffix" == "True" ]]; then
        pass "deduplication adds @suffix"
    else
        fail "deduplication adds @suffix"
    fi

    # Explicit provider flag
    result=$($SCRIPT -n --no-context-lookup --include "qwen2.5-coder:7b" -p ollama 2>/dev/null)
    if echo "$result" | python3 -c "import sys,json; assert 'ollama' in json.load(sys.stdin)['provider']" 2>/dev/null; then
        pass "--provider ollama works"
    else
        fail "--provider ollama works"
    fi

fi

# --- Summary ---
echo ""
echo "========================================"
echo -e "Results: ${GREEN}${PASS} passed${NC}, ${RED}${FAIL} failed${NC}, ${YELLOW}${SKIP} skipped${NC} / ${TOTAL} total"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0
