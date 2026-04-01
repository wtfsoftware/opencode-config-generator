# SPECIFICATION

## OpenCode Config Generator for Ollama — Technical Specification

**Version:** 1.1.0  
**Status:** Stable  
**License:** MIT

---

## 1. Overview

OpenCode Config Generator is a cross-platform tool that auto-generates `opencode.json` configuration for [OpenCode](https://opencode.ai) by discovering models from one or more local inference servers (Ollama, LM Studio, vLLM, llama.cpp, and others) via their REST APIs.

### 1.1 Goals

- Zero-config generation: run once, get a working config
- Multi-provider support: Ollama, LM Studio, vLLM, llama.cpp, LocalAI, text-generation-webui, Jan.ai, GPT4All
- Multi-server support: combine servers of different providers
- Auto-detection: identify provider by port
- Accurate metadata: fetch exact context lengths from API
- Safe defaults: exclude embedding models, cap output tokens
- User control: interactive selection, include/exclude filters, merge mode

### 1.2 Non-goals

- Managing server lifecycle (start/stop/download)
- Model performance benchmarking
- Configuration of cloud providers (use OpenCode's built-in support)

---

## 2. Architecture

### 2.1 Components

```
┌──────────────────────────────────────────────────────┐
│                    generate_opencode_config.sh        │
├──────────────────────────────────────────────────────┤
│  CLI args → detect_provider() → load_adapter()       │
│                      ↓                                │
│  ┌────────────────────────────────────────────┐      │
│  │            adapters/base.sh                 │      │
│  │   (factory, auto-detect, registry)          │      │
│  └─────┬──────────┬──────────┬─────────┬──────┘      │
│        ▼          ▼          ▼         ▼              │
│  ┌──────────┐ ┌─────────┐ ┌───────┐ ┌─────────┐     │
│  │ ollama   │ │lmstudio │ │llama  │ │ openai  │     │
│  │ .sh      │ │.sh      │ │_cpp   │ │_generic │     │
│  │          │ │         │ │.sh    │ │.sh      │     │
│  │/api/tags │ │/v1/models│ │/props │ │/v1/models│    │
│  │/api/show │ │/api/v1/ │ │       │ │(vllm,   │     │
│  │          │ │models   │ │       │ │localai, │     │
│  │          │ │         │ │       │ │tgwui...)│     │
│  └─────┬────┘ └────┬────┘ └───┬───┘ └────┬────┘     │
│        └───────────┴──────────┴──────────┘           │
│                         ↓                             │
│  ┌──────────────────────────────────────────────┐    │
│  │          generate_config() [Python]            │    │
│  │  ┌──────────┐ ┌──────┐ ┌──────────────┐      │    │
│  │  │ Embed    │ │ Dedup│ │ Provider     │      │    │
│  │  │ Filter   │ │ +Sfx │ │ Builder      │      │    │
│  │  └──────────┘ └──────┘ └──────────────┘      │    │
│  │  ┌──────────┐ ┌──────┐ ┌──────────────┐      │    │
│  │  │ Merge    │ │Model │ │ JSON Output  │      │    │
│  │  │ Config   │ │Select│ │ + Validate   │      │    │
│  │  └──────────┘ └──────┘ └──────────────┘      │    │
│  └──────────────────────────────────────────────┘    │
│                         ↓                             │
│                   opencode.json                       │
└──────────────────────────────────────────────────────┘
```

### 2.2 Adapter Interface

All adapters implement:

| Function | Description | Returns |
|----------|-------------|---------|
| `adapter_fetch_models URL` | Fetch model list | JSON array |
| `adapter_get_context URL MODEL` | Get context length | Integer or empty |
| `adapter_has_rich_metadata` | Has detailed metadata? | bool |
| `adapter_provider_name` | Display name | string |
| `adapter_npm_package` | npm package for config | string |

### 2.3 Data Flow

```
Server URL → detect_provider() → load_adapter() → adapter_fetch_models()
    → adapter_get_context() → filter + dedup → generate_config() → opencode.json
```

### 2.4 Files

| File | Platform | Engine | Size |
|------|----------|--------|------|
| `generate_opencode_config.sh` | Linux/macOS/WSL/Git Bash | Bash + Python3 | ~36KB |
| `Generate-OpenCodeConfig.ps1` | Windows | PowerShell | ~20KB |
| `adapters/base.sh` | Both | Bash | ~4KB |
| `adapters/ollama.sh` | Both | Bash | ~2KB |
| `adapters/lmstudio.sh` | Both | Bash | ~3KB |
| `adapters/llama_cpp.sh` | Both | Bash | ~2KB |
| `adapters/openai_generic.sh` | Both | Bash | ~2KB |

---

## 3. Provider API Integration

### 3.1 Endpoints by Provider

| Provider | Models Endpoint | Context Endpoint | Embed Filter |
|----------|-----------------|------------------|:------------:|
| **Ollama** | `GET /api/tags` | `POST /api/show` (exact) | ✅ families |
| **LM Studio** | `GET /v1/models` + `GET /api/v1/models` | inline in rich response | ✅ type field |
| **vLLM** | `GET /v1/models` | — | ❌ |
| **llama.cpp** | `GET /v1/models` | `GET /props` | ❌ |
| **LocalAI** | `GET /v1/models` | — | ❌ |
| **text-generation-webui** | `GET /v1/models` | — | ❌ |
| **Jan.ai** | `GET /v1/models` | — | ❌ |
| **GPT4All** | `GET /v1/models` | — | ❌ |

### 3.2 Model Detection

**Embedding model detection** (excluded by default):
- Families containing: `nomic-bert`, `bert`, `bert-moe`, `embed`, `embedding`, `jina-embeddings`
- Model names containing any of these keywords

**Context length priority:**
1. `POST /api/show` → `model_info.*.context_length` (exact)
2. Hardcoded fallback by family (see table below)
3. Default: 8192

### 3.3 Context Length Defaults

| Family | Context | Family | Context |
|--------|---------|--------|---------|
| qwen, qwen2 | 32,768 | gemma | 8,192 |
| llama | 8,192 | phi | 4,096 |
| mistral, mixtral | 32,768 | command, command-r | 131,072 |
| deepseek | 65,536 | yi | 200,000 |
| codestral | 32,768 | granite | 8,192 |
| internlm | 32,768 | falcon | 8,192 |
| orca | 4,096 | neural-chat | 4,096 |
| starcoder | 8,192 | codegemma | 8,192 |

---

## 4. Output Format

### 4.1 Generated `opencode.json` Structure

```jsonc
{
  "$schema": "https://opencode.ai/config.json",  // always present
  "provider": {
    "ollama": {                                    // primary provider
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama",
      "options": {
        "baseURL": "http://host:port/v1"          // required
        // "num_ctx": 32768                       // optional, if --num-ctx > 0
      },
      "models": {
        "model-name:tag": {
          "name": "Display Name (server)",         // human-readable
          "limit": {
            "context": 32768,                      // max context window
            "output": 16384                        // max output (capped at 16K)
          }
        }
      }
    },
    "ollama-2": { ... }                            // additional servers (if >1)
  },
  "model": "ollama/model-name:tag",               // default model
  "small_model": "ollama/small-model:tag"          // smallest non-embed model
}
```

### 4.2 Multi-Server Behavior

| Scenario | Providers Created | Model Names |
|----------|-------------------|-------------|
| 1 server | `ollama` | original names |
| 2+ servers, no duplicates | `ollama`, `ollama-2`, ... | original names |
| 2+ servers, with duplicates | `ollama`, `ollama-2`, ... | original + `@host:port` suffixes |

### 4.3 Deduplication Rules

When the same model exists on multiple servers:

```
server1 (local):  qwen2.5-coder:7b                → qwen2.5-coder:7b
server2 (remote): qwen2.5-coder:7b                → qwen2.5-coder:7b@gpu:11434
server3 (remote): qwen2.5-coder:7b                → qwen2.5-coder:7b@gpu:11434-2
```

Suffix format: `@hostname:port` or `@hostname:port-N` for same-host duplicates.

---

## 5. Caching

### 5.1 Cache Location

- **Linux/macOS:** `$XDG_CACHE_HOME/opencode-generator/` or `~/.cache/opencode-generator/`
- **Windows:** `%LOCALAPPDATA%\opencode-generator\` (PowerShell only)

### 5.2 Cache File Format

```
ctx_<md5(url)>.json
```

Content: `{"model_name": context_length, ...}`

### 5.3 Cache TTL

Default: **24 hours** (86400 seconds). Checked via file modification time (`stat`).

Cache is invalidated when:
- TTL expires
- `--no-cache` flag used
- Manual deletion

---

## 6. CLI Interface

### 6.1 Argument Parsing

Both scripts support identical flags (adapted for platform conventions):

| Bash | PowerShell | Type | Default |
|------|------------|------|---------|
| `-l, --local URL` | `-LocalOllamaUrl` | string | `$OLLAMA_HOST` or `http://localhost:11434` |
| `-r, --remote URL` | `-RemoteOllamaUrl` | string[] | `[]` |
| `-o, --output FILE` | `-OutputFile` | string | `opencode.json` |
| `-n, --dry-run` | `-DryRun` | flag | off |
| `-i, --interactive` | `-Interactive` | flag | off |
| `--include PAT` | `-Include` | string[] | `[]` |
| `--exclude PAT` | `-Exclude` | string[] | `[]` |
| `--with-embed` | `-WithEmbed` | flag | off |
| `--no-context-lookup` | `-NoContextLookup` | flag | off |
| `--num-ctx N` | `-NumCtx` | int | 0 |
| `--merge` | `-Merge` | flag | off |
| `--default-model ID` | `-DefaultModel` | string | auto |
| `--small-model ID` | `-SmallModel` | string | auto |
| `--no-cache` | `-NoCache` | flag | off |
| `-v, --version` | `-Version` | flag | off |
| `-h, --help` | `-Help` | flag | off |

### 6.2 Environment Variables

| Variable | Used By | Purpose |
|----------|---------|---------|
| `OLLAMA_HOST` | Both | Default local Ollama URL |
| `XDG_CACHE_HOME` | Bash | Cache directory base |

---

## 7. Interactive Selection

When `-i` is used, each server's models are presented as:

```
Available models from local Ollama:
  [0] -- All models --
  [1] qwen2.5-coder:7b         Qwen2 7.6B  Q4_K_M  ctx=32768
  [2] llama3.2:latest           Llama 3.6B  Q4_K_M  ctx=8192

Select models (comma-separated, e.g. 1,3,5 or 0 for all) [0]:
```

- Empty input or `0` → all models
- Comma-separated indices → selected models only
- Selection is per-server (local and remote are selected independently)

---

## 8. Error Handling

| Error | Exit Code | Behavior |
|-------|-----------|----------|
| Missing curl/python3 | 1 | Print install instructions, exit |
| Invalid URL | 1 | Print error with URL, exit |
| Ollama unreachable | 1 | Print warning, try next server, exit if all fail |
| Invalid JSON generated | 1 | Print error, exit |
| Empty model list after filtering | 1 | Print suggestions, exit |

---

## 9. Dependencies

| Dependency | Required | Purpose | Check |
|------------|----------|---------|-------|
| bash 4+ | Yes (bash) | Shell execution | implicit |
| curl | Yes (bash) | HTTP requests | `command -v curl` |
| python3 | Yes (bash) | JSON processing | `command -v python3` |
| PowerShell 5.1+ | Yes (ps1) | Everything | implicit |

Python standard library only (no pip packages):
- `json`, `os`, `sys`, `fnmatch`, `collections.OrderedDict`, `urllib.parse`

---

## 10. Testing

### 10.1 Manual Test Matrix

| Test | Command |
|------|---------|
| Help | `./generate_opencode_config.sh --help` |
| Version | `./generate_opencode_config.sh --version` |
| Dry-run | `./generate_opencode_config.sh -n` |
| With remote | `./generate_opencode_config.sh -n -r http://host:11434` |
| Include filter | `./generate_opencode_config.sh -n --include "qwen*"` |
| Exclude filter | `./generate_opencode_config.sh -n --exclude "*embed*"` |
| With embed | `./generate_opencode_config.sh -n --with-embed` |
| Default model | `./generate_opencode_config.sh -n --default-model qwen2.5-coder:7b` |
| Small model | `./generate_opencode_config.sh -n --small-model qwen2.5-coder:3b` |
| Num ctx | `./generate_opencode_config.sh -n --num-ctx 32768` |
| No context lookup | `./generate_opencode_config.sh -n --no-context-lookup` |
| Merge | `./generate_opencode_config.sh -n --merge` |
| Invalid URL | `./generate_opencode_config.sh -l bad-url` |
| Dedup | `./generate_opencode_config.sh -n -r http://localhost:11434` |

### 10.2 Automated Test

```bash
# Quick smoke test
bash generate_opencode_config.sh -n --no-context-lookup 2>/dev/null | python3 -c "
import sys, json
d = json.load(sys.stdin)
assert d.get('\$schema')
assert 'ollama' in d['provider']
assert len(d['provider']['ollama']['models']) > 0
assert d.get('model', '').startswith('ollama/')
print('PASS: all assertions')
"
```

---

## 11. Changelog

### v1.1.0
- Added `--version`, `--small-model`, URL validation
- Cache TTL (24h)
- Refactored `process_server()` (eliminated code duplication)
- Deduplication with server suffixes (`@host:port`)
- `--default-model` and `--small-model` work with suffixed names

### v1.0.0
- Initial release
- Local + multiple remote servers
- Embed filtering, context lookup, include/exclude
- Interactive selection, merge mode, dry-run
- Bash and PowerShell scripts
