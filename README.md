# OpenCode Config Generator for Ollama

Generates `opencode.json` configuration from local and remote Ollama servers.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

English | [Русский](README.ru.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Español](README.es.md) | [中文](README.zh.md) | [日本語](README.ja.md) | [Português](README.pt.md) | [Italiano](README.it.md) | [한국어](README.ko.md) | [العربية](README.ar.md) | [Nederlands](README.nl.md) | [Українська](README.ua.md)

**v1.4.2** | [Specification](SPECIFICATION.md) | [Development](DEVELOPMENT.md) | [Disclaimer](DISCLAIMER.md)

## Features

- **Multi-provider support**: Ollama, LM Studio, vLLM, llama.cpp, LocalAI, text-generation-webui, Jan.ai, GPT4All
- Auto-detects provider by port, or specify with `-p`
- Auto-discovers all models via provider API
- Filters out embedding models (nomic-bert, LM Studio type field, etc.)
- Filter models by tool/function calling support (`--tools-only`)
- Fetches exact context lengths (Ollama `/api/show`, llama.cpp `/props`, LM Studio rich metadata)
- Supports multiple servers of different providers simultaneously
- Interactive model selection (with "All models" option)
- Include/exclude models by glob patterns
- Auto-detects `small_model` (smallest non-embed model for title generation)
- Dry-run mode (preview without writing)
- Respects `OLLAMA_HOST` environment variable

## Requirements

| Component | Bash script | PowerShell script |
|-----------|:-----------:|:-----------------:|
| curl      | required    | not needed        |
| Python 3  | required    | not needed        |
| PowerShell 5.1+ | n/a   | required          |

## Quick Start

```bash
# Bash (Linux/macOS/WSL/Git Bash)
./generate_opencode_config.sh

# PowerShell (Windows)
.\Generate-OpenCodeConfig.ps1
```

## Usage

### Bash

```bash
# Local Ollama only (uses $OLLAMA_HOST or http://localhost:11434)
./generate_opencode_config.sh

# With one remote server
./generate_opencode_config.sh -r http://192.168.1.100:11434

# With multiple remote servers
./generate_opencode_config.sh -r http://gpu1:11434 -r http://gpu2:11434

# Interactive model selection
./generate_opencode_config.sh -i

# Only qwen models
./generate_opencode_config.sh --include "qwen*"

# Exclude codestral
./generate_opencode_config.sh --exclude "codestral*"

# Include embedding models
./generate_opencode_config.sh --with-embed

# Only models with tool/function calling support
./generate_opencode_config.sh --tools-only

# Preview without writing file
./generate_opencode_config.sh -n

# Add num_ctx to provider options (for tool calling)
./generate_opencode_config.sh --num-ctx 32768

# Set default model explicitly
./generate_opencode_config.sh --default-model qwen2.5-coder:7b

# Merge into existing config (update models, keep other settings)
./generate_opencode_config.sh --merge

# Skip /api/show calls (faster, uses hardcoded context limits)
./generate_opencode_config.sh --no-context-lookup

# Disable context lookup cache
./generate_opencode_config.sh --no-cache

# Write to global config
./generate_opencode_config.sh -o ~/.config/opencode/opencode.json
```

### PowerShell

```powershell
# Local Ollama only
.\Generate-OpenCodeConfig.ps1

# With remote servers
.\Generate-OpenCodeConfig.ps1 -RemoteOllamaUrl "http://192.168.1.100:11434"
.\Generate-OpenCodeConfig.ps1 -RemoteOllamaUrl "http://gpu1:11434","http://gpu2:11434"

# Interactive selection
.\Generate-OpenCodeConfig.ps1 -Interactive

# Only qwen models
.\Generate-OpenCodeConfig.ps1 -Include "qwen*"

# Dry-run
.\Generate-OpenCodeConfig.ps1 -DryRun

# With num_ctx
.\Generate-OpenCodeConfig.ps1 -NumCtx 32768

# Write to global config
.\Generate-OpenCodeConfig.ps1 -OutputFile "$env:USERPROFILE\.config\opencode\opencode.json"
```

## CLI Reference

### Bash

| Flag | Description | Default |
|------|-------------|---------|
| `-l, --local URL` | Local server URL | `$OLLAMA_HOST` or `http://localhost:11434` |
| `-r, --remote URL` | Remote server URL (repeatable) | none |
| `-p, --provider NAME` | Provider: ollama, lmstudio, vllm, llama-cpp, localai, tgwui, jan, gpt4all | auto-detect |
| `-o, --output FILE` | Output file path (`-` for stdout) | `opencode.json` |
| `-n, --dry-run` | Print to stdout, don't write | off |
| `-i, --interactive` | Interactive model selection | off |
| `--include PATTERN` | Include models matching glob (repeatable) | all |
| `--exclude PATTERN` | Exclude models matching glob (repeatable) | none |
| `--with-embed` | Include embedding models | excluded |
| `--tools-only` | Only models with tool/function calling support | off |
| `--no-context-lookup` | Skip `/api/show`, use hardcoded limits | off |
| `--num-ctx N` | `num_ctx` for provider options, 0 to omit | `0` |
| `--merge` | Merge into existing config (update models only) | off |
| `--default-model ID` | Set default model explicitly | auto |
| `--small-model ID` | Set small model explicitly (for title generation) | auto |
| `--no-cache` | Disable context lookup cache | off |
| `-v, --version` | Show version | |
| `-h, --help` | Show help | |

### PowerShell

| Parameter | Description | Default |
|-----------|-------------|---------|
| `-LocalOllamaUrl` | Local Ollama URL | `$OLLAMA_HOST` or `http://localhost:11434` |
| `-RemoteOllamaUrl` | Remote URL(s) (array) | none |
| `-OutputFile` | Output file path | `opencode.json` |
| `-DryRun` | Print to stdout, don't write | off |
| `-Interactive` | Interactive model selection | off |
| `-Include` | Include patterns (wildcard, array) | all |
| `-Exclude` | Exclude patterns (wildcard, array) | none |
| `-WithEmbed` | Include embedding models | excluded |
| `-ToolsOnly` | Only models with tool/function calling support | off |
| `-NoContextLookup` | Skip `/api/show`, use hardcoded limits | off |
| `-NumCtx` | `num_ctx` for provider options, 0 to omit | `0` |
| `-Merge` | Merge into existing config (update models only) | off |
| `-DefaultModel` | Set default model explicitly | auto |
| `-SmallModel` | Set small model explicitly (for title generation) | auto |
| `-NoCache` | Disable context lookup cache | off |
| `-Version` | Show version | |
| `-Help` | Show help | |

## How It Works

1. **Fetch models** from each Ollama server via `GET /api/tags`
2. **Filter** embedding models by `families` field (`nomic-bert`, `bert`, etc.)
3. **Filter** by include/exclude patterns (glob matching)
4. **Fetch context lengths** for each model via `POST /api/show` (parallel, cached)
5. **Deduplicate** models found on multiple servers (keeps first server's version)
6. **Interactive selection** (if `-i`): numbered list with `[0] All models` option
7. **Merge** (if `--merge`): preserve existing config settings and other providers
8. **Auto-detect `small_model`**: smallest non-embed model by parameter count
9. **Generate** `opencode.json` with Ollama as provider

## Generated Config Structure

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama",
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
        "llama3.2:latest": {
          "name": "Llama 3.6B Q4_K_M (local)",
          "limit": {
            "context": 131072,
            "output": 16384
          }
        }
      }
    }
  },
  "model": "ollama/llama3.2:latest",
  "small_model": "ollama/qwen2.5-coder:3b"
}
```

### Fields

| Field | Description |
|-------|-------------|
| `provider.ollama.options.baseURL` | Ollama OpenAI-compatible endpoint |
| `provider.ollama.models.*.limit.context` | Max context window for the model |
| `provider.ollama.models.*.limit.output` | Max output tokens (capped at 16K) |
| `model` | Default model (first available) |
| `small_model` | Smallest model for lightweight tasks (title generation) |

## Model Context Detection

Context lengths are determined in this priority order:

1. **API lookup** — `POST /api/show` returns `model_info.*.context_length` (exact value)
2. **Hardcoded fallback** — estimated by model family:

| Family | Default Context |
|--------|:--------------:|
| qwen, qwen2 | 32,768 |
| llama | 8,192 |
| mistral, mixtral | 32,768 |
| deepseek | 65,536 |
| command, command-r | 131,072 |
| yi | 200,000 |
| gemma | 8,192 |
| phi | 4,096 |
| codestral | 32,768 |
| granite | 8,192 |
| other | 8,192 |

Use `--no-context-lookup` to skip API calls and use only hardcoded values (faster).

## Embedding Models

Embedding models are **excluded by default** because they don't support chat/tool calling. Detection is based on:

- Model families containing `nomic-bert`, `bert`, `bert-moe`, `embed`, `embedding`
- Model names containing these keywords

Use `--with-embed` / `-WithEmbed` to include them.

## Tool/Function Calling Filter

Use `--tools-only` / `-ToolsOnly` to include only models that support tool/function calling:

```bash
./generate_opencode_config.sh --tools-only
```

Detection works in two tiers:
1. **Exact** — LM Studio provides `capabilities.tool_use` via its rich `/api/v1/models` endpoint
2. **Heuristic** — for all other providers, models are matched against a known allowlist of tool-capable families (qwen2.5/3, llama3.x, mistral, mixtral, deepseek-r1/v3, command-r, phi3/4, gemma2/3, granite3.x)

Models not matching either check are excluded when `--tools-only` is active. The allowlist may need updates as new model families are released.

## Tool/Function Calling Filter

Use `--tools-only` / `-ToolsOnly` to include only models that support tool/function calling:

```bash
./generate_opencode_config.sh --tools-only
```

Detection works in two tiers:
1. **Exact** — LM Studio provides `capabilities.tool_use` via its rich `/api/v1/models` endpoint
2. **Heuristic** — for all other providers, models are matched against a known allowlist of tool-capable families (qwen2.5/3, llama3.x, mistral, mixtral, deepseek-r1/v3, command-r, phi3/4, gemma2/3, granite3.x)

Models not matching either check are excluded when `--tools-only` is active. The allowlist may need updates as new model families are released.

## Multi-Provider Support

Works with 8 local inference providers. Provider is auto-detected by port, or specify with `-p`.

| Provider | Default Port | Rich Metadata | Auto-detect |
|----------|:------------:|:-------------:|:-----------:|
| **Ollama** | 11434 | `/api/show` (context, families) | ✅ |
| **LM Studio** | 1234 | `/api/v1/models` (type, capabilities, context) | ✅ |
| **vLLM** | 8000 | basic only | ✅ |
| **llama.cpp** | 8080 | `/props` (context_size) | ✅ (as localai) |
| **LocalAI** | 8080 | basic only | ✅ |
| **text-generation-webui** | 5000 | basic only | ✅ |
| **Jan.ai** | 1337 | basic only | ✅ |
| **GPT4All** | 4891 | basic only | ✅ |

```bash
# Auto-detect by port
./generate_opencode_config.sh -l http://localhost:1234       # LM Studio
./generate_opencode_config.sh -l http://localhost:8000       # vLLM

# Explicit provider
./generate_opencode_config.sh -l http://localhost:8080 -p llama-cpp

# Ollama + LM Studio together
./generate_opencode_config.sh -l http://localhost:11434 -r http://localhost:1234 -p lmstudio
```

Each provider appears as a separate block in `opencode.json`:

```json
{
  "provider": {
    "ollama": { "name": "Ollama", "options": { "baseURL": "http://localhost:11434/v1" }, ... },
    "lmstudio": { "name": "LM Studio", "options": { "baseURL": "http://localhost:1234/v1" }, ... }
  }
}
```

## Context Lookup Cache

Context lengths from `/api/show` are cached in `~/.cache/opencode-generator/` by URL hash. Cache expires after 24 hours. Subsequent runs reuse cached values and only fetch new models. Use `--no-cache` to disable.

## Merge Mode

Use `--merge` to update models in an existing `opencode.json` without overwriting other settings (custom providers, themes, rules, etc.):

```bash
# Initial generation
./generate_opencode_config.sh -o opencode.json

# Manually add custom providers, rules, etc. to opencode.json

# Later: update models only, keep everything else
./generate_opencode_config.sh --merge -o opencode.json
```

## Deduplication

If the same model exists on multiple servers, each copy gets a unique name with server suffix:

```
qwen2.5-coder:7b                → local server (original name)
qwen2.5-coder:7b@gpu-server     → first remote server
qwen2.5-coder:7b@gpu-server-2   → second remote with same hostname
```

Both versions appear in `/models`. The summary shows which models were suffixed.

## Environment Variables

| Variable | Description |
|----------|-------------|
| `OLLAMA_HOST` | Default local Ollama URL (standard Ollama variable) |
| `XDG_CACHE_HOME` | Cache directory base path |

## Installing the Generated Config

```bash
# Global config (all projects)
cp opencode.json ~/.config/opencode/opencode.json

# Project-specific
cp opencode.json /path/to/project/opencode.json
```

## Troubleshooting

### "Could not connect to Ollama"

- Make sure Ollama is running: `ollama serve`
- Check the URL: `curl http://localhost:11434/api/tags`
- If using a custom port/host, set `OLLAMA_HOST` or use `-l`

### "Missing required dependencies: python3"

```bash
# Ubuntu/Debian
sudo apt install python3

# macOS
brew install python3

# Windows: download from https://python.org
```

### Wrong context length

- The script uses `/api/show` by default for exact values
- If API is slow, use `--no-context-lookup` for hardcoded estimates
- Override manually in the generated JSON if needed

### Embedding models included/excluded unexpectedly

- Check families in `ollama show <model>` output
- Use `--with-embed` to force include
- Use `--exclude "*embed*"` to force exclude by name

### "Provider returned error" in OpenCode

- Some Ollama models don't support tool calling — try `qwen2.5-coder` or `llama3.2`
- Increase `num_ctx` if tools fail: `--num-ctx 32768`
- Make sure model is loaded: `ollama run <model>`
