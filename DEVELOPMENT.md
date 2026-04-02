# DEVELOPMENT

## Developer Documentation — OpenCode Config Generator

**Version:** 1.1.0

---

## Table of Contents

1. [Development Environment Setup](#1-development-environment-setup)
2. [Project Structure](#2-project-structure)
3. [Architecture Deep Dive](#3-architecture-deep-dive)
4. [Code Conventions](#4-code-conventions)
5. [Adding Features](#5-adding-features)
6. [Testing](#6-testing)
7. [Release Process](#7-release-process)
8. [Known Limitations](#8-known-limitations)

---

## 1. Development Environment Setup

### 1.1 Prerequisites

```bash
# Required
bash 4.0+
python 3.8+
curl
ollama (running instance for testing)

# Optional
shellcheck (lint bash)
PowerShell 7+ (test PS1 script)
```

### 1.2 Clone and Test

```bash
git clone https://github.com/wtfsoftware/opencode-config-generator.git
cd opencode-config-generator

# Smoke test
bash generate_opencode_config.sh --version
bash generate_opencode_config.sh -n --no-context-lookup

# Lint bash
shellcheck generate_opencode_config.sh

# Test PowerShell (Windows or pwsh)
pwsh -Command "./Generate-OpenCodeConfig.ps1 -DryRun -NoContextLookup"
```

### 1.3 Test Ollama Instance

```bash
# Verify Ollama is running
curl -s http://localhost:11434/api/tags | python3 -m json.tool

# If not running
ollama serve &
ollama pull llama3.2
```

---

## 2. Project Structure

```
opencode_config_generator/
├── .github/workflows/test.yml         CI pipeline
├── .gitignore
├── generate_opencode_config.sh        Main script (Bash + Python)
├── Generate-OpenCodeConfig.ps1        PowerShell version
├── install.sh                         One-line installer
├── smoke_test.sh                      15 automated tests
├── generate_opencode_config.completion.bash  Bash completion
├── _generate_opencode_config          Zsh completion
├── adapters/                          Provider adapters
│   ├── base.sh                        Factory, auto-detect, registry
│   ├── ollama.sh                      Ollama adapter
│   ├── lmstudio.sh                    LM Studio adapter
│   ├── llama_cpp.sh                   llama.cpp adapter
│   └── openai_generic.sh              Generic OpenAI adapter (vllm, localai, etc.)
├── README.md                          English
├── README.ru.md / .fr.md / .de.md / .es.md / .zh.md / .ja.md / .pt.md / .it.md / .ko.md / .ar.md / .nl.md / .ua.md
├── SPECIFICATION.md                   Technical specification
├── DEVELOPMENT.md                     This file
├── LICENSE                            MIT License
└── DISCLAIMER.md                      Legal disclaimer (13 languages)
```

### 2.1 File Responsibilities

| File | Lines | Responsibility |
|------|-------|----------------|
| `generate_opencode_config.sh` | ~1100 | CLI, API calls, process_server, delegates to Python |
| `Generate-OpenCodeConfig.ps1` | ~700 | Same logic in PowerShell (no Python dependency) |
| Python heredoc (in bash) | ~400 | JSON generation, filtering, dedup, merge |

---

## 3. Architecture Deep Dive

### 3.1 Bash Script Structure

```
generate_opencode_config.sh
│
├── Defaults (vars)
├── Colors (ANSI)
├── usage()
├── parse_args()          # Argument parsing
├── check_dependencies()  # curl, python3
├── validate_url()        # URL format check
│
├── Ollama API helpers:
│   ├── fetch_models()              # GET /api/tags
│   ├── fetch_context_length()      # POST /api/show (single)
│   └── fetch_context_lengths_batch() # POST /api/show (parallel + cache)
│
├── Model filtering:
│   ├── matches_include()  # Glob pattern matching
│   └── matches_exclude()  # Glob pattern matching
│
├── interactive_select()   # User model selection
│
├── generate_config()      # Python heredoc (the brain)
│   ├── Filter embed models
│   ├── Filter include/exclude
│   ├── Assign context lengths
│   ├── Deduplicate with suffixes
│   ├── Merge with existing config
│   ├── Select default/small model
│   └── Output JSON
│
├── process_server()       # Process one Ollama server
│   ├── fetch_models()
│   ├── fetch_context_lengths_batch()
│   ├── interactive_select()
│   └── append to servers_json
│
└── main()
    ├── parse_args()
    ├── check_dependencies()
    ├── validate_url()
    ├── process_server() × N
    └── generate_config()
```

### 3.2 Python Heredoc Data Flow

```
Environment variables (export)
    ↓
CONFIG_SERVERS_JSON  → parse_servers()    → servers[]
CONFIG_CTX_MAPS      → parse_ctx_maps()   → ctx_map{}
CONFIG_INCLUDE_PATTERNS                   → include_patterns[]
CONFIG_EXCLUDE_PATTERNS                   → exclude_patterns[]
    ↓
For each server:
    process_models()
        ├─ filter embed
        ├─ filter tools (--tools-only)
        ├─ filter include/exclude
        ├─ assign context
        └─ build model config
    ↓
Deduplication with @suffixes
    ↓
Build provider_config
    ├─ single server → 1 provider
    └─ multi server  → combined + individual
    ↓
Default model selection (--default-model override)
    ↓
Small model selection (--small-model override)
    ↓
Merge with existing (--merge)
    ↓
JSON validation
    ↓
Output (file or stdout)
```

### 3.3 Data Passing: Bash → Python

All data is passed via environment variables to avoid shell escaping issues:

```bash
export CONFIG_SERVERS_JSON='[{"url":"...","label":"local","models":[...]}]'
export CONFIG_CTX_MAPS='{"http://...":{"model":32768}}'
export CONFIG_INCLUDE_PATTERNS="qwen* llama*"
export CONFIG_EXCLUDE_PATTERNS="*embed*"
export CONFIG_NUM_CTX="0"
export CONFIG_DRY_RUN="false"
export CONFIG_NO_EMBED="true"
export CONFIG_NO_CTX_LOOKUP="false"
export CONFIG_MERGE="false"
export CONFIG_DEFAULT_MODEL=""
export CONFIG_SMALL_MODEL=""
```

**Why environment variables?**
- Avoids shell escaping of JSON special characters (`"`, `\`, newlines)
- Avoids argument length limits
- Python reads via `os.environ.get()`

---

## 4. Code Conventions

### 4.1 Bash

- **Functions:** `snake_case()`
- **Constants:** `UPPER_CASE`
- **Local vars:** `local var_name`
- **Logging:** `log_info`, `log_warn`, `log_error`, `log_step` (output to stderr)
- **Error handling:** `set -euo pipefail` + explicit `|| true` where needed
- **No comments** unless the logic is non-obvious

### 4.2 Python (heredoc)

- **Functions:** `snake_case()`
- **Constants:** `UPPER_CASE`
- **Output:** config JSON to stdout, everything else to stderr
- **No external dependencies** (stdlib only)

### 4.3 PowerShell

- **Functions:** `Verb-Noun` (PowerShell convention)
- **Parameters:** `PascalCase`
- **Logging:** `Write-Info`, `Write-Warn`, `Write-Err`, `Write-Step`

### 4.4 Synchronization Rule

**Both scripts must have identical behavior.** When changing one:
1. Apply the same logic change to the other
2. Verify both produce the same output for the same input
3. Update `VERSION` in both files

---

## 5. Adding Features

### 5.1 Adding a New CLI Flag

**Bash (`generate_opencode_config.sh`):**

1. Add variable in Defaults section:
   ```bash
   MY_NEW_FLAG=false
   ```

2. Add to `usage()`:
   ```bash
       --my-new-flag    Description (default: off)
   ```

3. Add case in `parse_args()`:
   ```bash
   --my-new-flag)
       MY_NEW_FLAG=true
       shift
       ;;
   ```

4. Export to Python if needed:
   ```bash
   export CONFIG_MY_NEW_FLAG="$MY_NEW_FLAG"
   ```

5. Read in Python heredoc:
   ```python
   my_new_flag = os.environ.get("CONFIG_MY_NEW_FLAG", "false") == "true"
   ```

6. Implement logic

**PowerShell (`Generate-OpenCodeConfig.ps1`):**

1. Add parameter:
   ```powershell
   [switch]$MyNewFlag,
   ```

2. Add to help string

3. Implement logic (mirror bash)

### 5.2 Adding a New Filter

1. Create filter function (bash + python)
2. Add CLI flag for the filter
3. Call filter in `process_models()`
4. Update summary output
5. Update both scripts

### 5.3 Adding a New Output Field

1. Add to Python `config` OrderedDict
2. Ensure it doesn't break `--merge` (should be preserved)
3. Update SPECIFICATION.md section 4

---

## 6. Testing

### 6.1 Manual Test Checklist

Run each test and verify output:

```bash
# Basic
./generate_opencode_config.sh -n --no-context-lookup

# Filters
./generate_opencode_config.sh -n --no-context-lookup --include "qwen*"
./generate_opencode_config.sh -n --no-context-lookup --exclude "*llama*"
./generate_opencode_config.sh -n --no-context-lookup --with-embed
./generate_opencode_config.sh -n --no-context-lookup --tools-only

# Options
./generate_opencode_config.sh -n --no-context-lookup --num-ctx 32768
./generate_opencode_config.sh -n --no-context-lookup --default-model qwen2.5-coder:7b
./generate_opencode_config.sh -n --no-context-lookup --small-model qwen2.5-coder:3b

# Multi-server (dedup test)
./generate_opencode_config.sh -n --no-context-lookup -r http://localhost:11434

# Merge test
./generate_opencode_config.sh --no-context-lookup  # write file
echo '{"custom":"value"}' > /tmp/test.json
./generate_opencode_config.sh -n --no-context-lookup --merge -o /tmp/test.json

# Error cases
./generate_opencode_config.sh -l "bad-url"
./generate_opencode_config.sh -r http://192.0.2.1:11434 --no-context-lookup

# Cache test
./generate_opencode_config.sh -n  # first run (fetches)
./generate_opencode_config.sh -n  # second run (cached)
./generate_opencode_config.sh -n --no-cache  # third run (no cache)
```

### 6.2 Automated Smoke Test

```bash
#!/bin/bash
set -e

SCRIPT="./generate_opencode_config.sh"
PASS=0
FAIL=0

test_case() {
    local name="$1"
    local cmd="$2"
    local check="$3"
    
    if eval "$cmd" 2>/dev/null | python3 -c "$check" 2>/dev/null; then
        echo "  PASS: $name"
        ((PASS++))
    else
        echo "  FAIL: $name"
        ((FAIL++))
    fi
}

echo "Running tests..."

test_case "version" \
    "$SCRIPT --version" \
    'import sys; assert "1.1.0" in sys.stdin.read()'

test_case "basic generation" \
    "$SCRIPT -n --no-context-lookup" \
    'import sys,json; d=json.load(sys.stdin); assert d.get("\$schema"); assert "ollama" in d["provider"]'

test_case "include filter" \
    '$SCRIPT -n --no-context-lookup --include "qwen2.5-coder:7b"' \
    'import sys,json; d=json.load(sys.stdin); assert len(d["provider"]["ollama"]["models"]) == 1'

test_case "exclude filter" \
    '$SCRIPT -n --no-context-lookup --exclude "*qwen*"' \
    'import sys,json; d=json.load(sys.stdin); assert all("qwen" not in k for k in d["provider"]["ollama"]["models"])'

test_case "default model" \
    '$SCRIPT -n --no-context-lookup --default-model qwen2.5-coder:7b --include "qwen2.5-coder:*"' \
    'import sys,json; d=json.load(sys.stdin); assert "qwen2.5-coder:7b" in d["model"]'

test_case "invalid url" \
    '$SCRIPT -l bad-url 2>&1 || true' \
    'import sys; assert "Invalid URL" in sys.stdin.read()'

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ $FAIL -eq 0 ] && exit 0 || exit 1
```

### 6.3 Parity Test (Bash vs PowerShell)

```bash
# Generate with both, compare JSON (ignoring whitespace)
bash generate_opencode_config.sh -n --no-context-lookup > /tmp/bash.json
pwsh -Command "./Generate-OpenCodeConfig.ps1 -DryRun -NoContextLookup" > /tmp/ps.json
diff <(python3 -m json.tool /tmp/bash.json) <(python3 -m json.tool /tmp/ps.json)
```

---

## 7. Release Process

### 7.1 Version Bump

1. Update `VERSION` in `generate_opencode_config.sh` (line ~11)
2. Update `$ScriptVersion` in `Generate-OpenCodeConfig.ps1` (line ~32)
3. Update `SPECIFICATION.md` version header
4. Update changelog in `SPECIFICATION.md` section 11

### 7.2 Pre-release Checklist

- [ ] `shellcheck generate_opencode_config.sh` — no errors
- [ ] All manual tests pass
- [ ] Bash and PowerShell produce equivalent output
- [ ] README updated if new flags added
- [ ] SPECIFICATION.md updated if output format changed
- [ ] DISCLAIMER.md exists and is current

### 7.3 Tagging

```bash
git add -A
git commit -m "v1.1.0: description"
git tag v1.1.0
git push origin main --tags
```

---

## 8. Known Limitations

| Limitation | Reason | Workaround |
|------------|--------|------------|
| No Windows native (without Git Bash/WSL) | Bash script requires bash | Use PowerShell script |
| Parallel `/api/show` not truly parallel in PowerShell | `Start-Job` overhead | Use `--no-context-lookup` for speed |
| No model capability detection | Ollama `/api/tags` doesn't return capabilities | `--tools-only` uses heuristic allowlist; LM Studio has exact `capabilities.tool_use` |
| `num_ctx` may not work in all OpenCode versions | Depends on AI SDK provider options | Omit (default 0) or test manually |
| Cache doesn't detect model updates | TTL-based only | Use `--no-cache` or wait 24h |
| Interactive mode requires terminal | `read -r` needs TTY | Don't use `-i` in CI/scripts |
| Glob patterns are shell-expanded if unquoted | Bash behavior | Always quote patterns: `--include "qwen*"` |

---

## 9. Debugging

### 9.1 Enable Verbose Output

```bash
# Bash: add set -x temporarily
bash -x generate_opencode_config.sh -n --no-context-lookup 2>debug.log

# Or add to script after shebang:
# set -x
```

### 9.2 Inspect API Responses

```bash
# See raw /api/tags
curl -s http://localhost:11434/api/tags | python3 -m json.tool

# See raw /api/show for a model
curl -s http://localhost:11434/api/show -d '{"model":"llama3.2"}' | python3 -m json.tool
```

### 9.3 Inspect Intermediate Data

```bash
# Add debug prints in Python heredoc
print(f"DEBUG: servers={servers}", file=sys.stderr)
```

### 9.4 Common Issues

**"No models found"**
- Check Ollama is running: `curl http://localhost:11434/api/tags`
- Check URL: must be `http://...` not just `localhost:11434`

**"Invalid JSON"**
- Usually a Python heredoc error
- Run with `bash -x` to see where it fails

**Cache not working**
- Check `$XDG_CACHE_HOME` or `~/.cache/opencode-generator/` exists
- Check file permissions

---

## 10. Contributing

1. Fork the repository
2. Create feature branch
3. Follow code conventions (section 4)
4. Update both scripts (bash + PowerShell)
5. Run manual test checklist
6. Update SPECIFICATION.md if needed
7. Submit PR with description
