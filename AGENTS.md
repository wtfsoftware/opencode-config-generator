# AGENTS.md — OpenCode Config Generator

This file guides AI coding agents working in this repository.

## Project Overview

CLI tool that generates `opencode.json` configuration files by discovering models from local inference servers (Ollama, LM Studio, vLLM, llama.cpp, etc.) via their REST APIs. Two equivalent scripts exist: Bash (`generate_opencode_config.sh`) and PowerShell (`Generate-OpenCodeConfig.ps1`).

## Build / Lint / Test Commands

```bash
# Lint (required before any PR)
shellcheck generate_opencode_config.sh

# Syntax check (Bash)
bash -n generate_opencode_config.sh

# Syntax check (PowerShell, Windows)
powershell.exe -NoProfile -Command '$null = [System.Management.Automation.Language.Parser]::ParseFile("Generate-OpenCodeConfig.ps1", [ref]$null, [ref]$null); Write-Host "OK"'
# Or with pwsh (PowerShell Core):
pwsh -Command '$null = [System.Management.Automation.Language.Parser]::ParseFile("Generate-OpenCodeConfig.ps1", [ref]$null, [ref]$null); Write-Host "OK"'

# Run smoke tests (requires Ollama running for full coverage)
bash smoke_test.sh

# Quick smoke test without Ollama
./generate_opencode_config.sh --version
./generate_opencode_config.sh -n --no-context-lookup

# Debug mode
bash -x generate_opencode_config.sh -n --no-context-lookup 2>debug.log

# Parity test (Bash vs PowerShell output comparison)
bash generate_opencode_config.sh -n --no-context-lookup > /tmp/bash.json
pwsh -Command "./Generate-OpenCodeConfig.ps1 -DryRun -NoContextLookup" > /tmp/ps.json
diff <(python3 -m json.tool /tmp/bash.json) <(python3 -m json.tool /tmp/ps.json)
```

There is no single-test runner. To test a specific feature, run the relevant command manually:
```bash
./generate_opencode_config.sh -n --no-context-lookup --include "qwen*"
```

## Critical Rule: Script Parity

**Both Bash and PowerShell scripts must have identical behavior.** When changing one, apply the same logic change to the other. Update `VERSION` in both files. This is the single most important rule in this codebase.

## Code Conventions

### Bash (`generate_opencode_config.sh`, `adapters/*.sh`)
- Functions: `snake_case()`
- Constants/vars at top: `UPPER_CASE`
- Local variables: `local var_name`
- Logging: `log_info`, `log_warn`, `log_error`, `log_step` (all to stderr)
- Error handling: `set -euo pipefail` + explicit `|| true` where failures are expected
- No comments unless logic is non-obvious
- Data passes Bash→Python via **environment variables** (not args), read with `os.environ.get()`

### Python (heredoc embedded in Bash script)
- Functions: `snake_case()`, Constants: `UPPER_CASE`
- Config JSON to stdout, all diagnostics to stderr
- **No external dependencies** — stdlib only (`json`, `os`, `sys`, `fnmatch`, `collections.OrderedDict`, `urllib.parse`)
- Debug prints: `print(f"DEBUG: ...", file=sys.stderr)`

### PowerShell (`Generate-OpenCodeConfig.ps1`)
- Functions: `Verb-Noun` (PowerShell convention)
- Parameters: `PascalCase`
- Logging: `Write-Info`, `Write-Warn`, `Write-Err`, `Write-Step`

### Adapter Interface
All adapters in `adapters/` must implement: `adapter_fetch_models`, `adapter_get_context`, `adapter_has_rich_metadata`, `adapter_provider_name`, `adapter_npm_package`.

### Adapters
- `base.sh` — factory, registry, `detect_family_from_name()` (shared)
- `ollama.sh` — Ollama (`/api/tags`, `/api/show`)
- `lmstudio.sh` — LM Studio (`/api/v1/models`, `/v1/models`)
- `llama_cpp.sh` — llama.cpp (`/v1/models`, `/props`, cached)
- `openai_generic.sh` — vLLM, LocalAI, etc. (`/v1/models`)
- `openai.sh` — OpenAI API with Bearer auth
- `tgi.sh` — HuggingFace TGI (`/info`, `/v1/models`)

## Adding Features

1. **New CLI flag:** Add default var → `usage()` → `parse_args()` → export to Python env var → read in Python → implement logic → mirror in PowerShell
2. **New filter:** Create filter function (Bash + Python), add CLI flag, call in `process_models()`, update summary, mirror in PowerShell
3. **New output field:** Add to Python `config` OrderedDict, ensure `--merge` compatibility, update `SPECIFICATION.md` Section 4
4. **New adapter:** Create `adapters/name.sh` implementing the interface, add to `load_adapter()` in `base.sh`, add to installer

## Release Process

1. Update `VERSION` in `generate_opencode_config.sh` (~line 13)
2. Update `$ScriptVersion` in `Generate-OpenCodeConfig.ps1` (~line 32)
3. Update `metadata.json` version field
4. Update `CHANGELOG.md` with new version
5. Update `SPECIFICATION.md` version header and changelog reference
6. Pre-release: `shellcheck` passes, `bash -n` passes, manual tests pass, both scripts produce equivalent output, README/SPEC updated if needed

## Key Constraints

- Bash 4.0+, Python 3.8+, curl required
- PowerShell script is self-contained (no Python dependency)
- Interactive mode (`-i`) requires a TTY — do not use in CI/scripts
- Always quote glob patterns: `--include "qwen*"` (unquoted patterns are shell-expanded)
- Cache at `$XDG_CACHE_HOME/opencode-generator/` or `~/.cache/opencode-generator/`, TTL 24h
- Colors auto-disable when stderr is not a TTY

## Documentation

- `DEVELOPMENT.md` — full developer docs (setup, architecture, debugging, contributing)
- `SPECIFICATION.md` — technical spec for the output JSON format
- `CHANGELOG.md` — version history
- `README.md` — user-facing docs (12 translated versions exist)
