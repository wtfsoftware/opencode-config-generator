# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.4.1] - 2026-04-03

### Fixed
- Added `"id"` field to deduplicated model entries (with `@host:port` suffix) containing the original model name, so opencode sends the correct model identifier to the Ollama API (fixes "Invalid model name" error)

## [1.4.0] - 2026-04-03

### Fixed
- Display names no longer include `"unknown"` quantization level when Ollama API returns it
- Model family detection now falls back to name-based heuristic when API returns empty or generic `"llama"` family (fixes Mistral, Codestral, DeepSeek, etc. being mislabeled as "Llama")
- Removed duplicate `load_adapter()` function in `adapters/base.sh` that was missing `openai` and `tgi` provider support
- Removed duplicate `TOOL_CAPABLE_FAMILIES` definition in Bash script
- Removed duplicate `$ToolCapableFamilies` definition in PowerShell script
- Removed duplicate `Test-IsToolCapable` function in PowerShell script
- Removed duplicate "Tools filtered" summary line in Bash script

## [1.3.0] - 2026-04-02

### Added
- `--tools-only` — only include models that support tool/function calling (uses `capabilities.tool_use` for LM Studio, heuristic allowlist for others)

## [1.2.0] - 2026-04-02

### Added
- `--max-size` / `--min-size` — filter models by parameter size (e.g. `--max-size 7B`)
- `--sort name|size|family` — sort models in output
- `--limit N` — limit output to N models
- `--max-output N` — configurable output token cap (default: 16384)
- `--check FILE` — validate existing opencode.json
- `--diff` — show unified diff of old vs new config (with `--merge`)
- `--force` — overwrite output file without prompting
- `--no-color` — disable colored output
- `--quiet` — suppress non-error output
- OpenAI API adapter (`adapters/openai.sh`) with Bearer auth
- TGI adapter (`adapters/tgi.sh`) for HuggingFace Text Generation Inference
- `metadata.json` — shared model metadata (context defaults, embed keywords)
- `CHANGELOG.md` — standalone changelog
- Installer: `--uninstall`, `--version`, download verification
- Port 8080 ambiguity warning (llama.cpp vs LocalAI)
- Early write permission check before network calls
- Non-TTY color detection (auto-disable for piped output)
- Interactive mode reads from `/dev/tty` (fixes piped stdin)

### Changed
- Updated hardcoded context values: llama→128K, phi→128K, added qwen3/llama3/deepseek-r1/phi4/granite3/etc.
- Batched cache lookup: single python3 call instead of per-model (10x faster with many models)
- Family detection extracted to shared `detect_family_from_name()` in `base.sh`
- Replaced `grep -P` with `sed` in `base.sh` (macOS compatibility)
- Removed dead code: `ollama_is_embedding()`, `lmstudio_is_embedding()`, `adapter_process_server()`, `adapter_get_info()`, `adapter_default_port()`
- llama.cpp adapter caches `/props` response (avoids redundant HTTP call)

### Fixed
- Arithmetic error in log message (`${#models[@] - ${#to_fetch[@]}` → `$(( ... ))`)
- Silent JSON parse failures now log warnings to stderr
- PowerShell script parity: added `-Provider` parameter

## [1.1.0] - 2026-03-15

### Added
- `--version`, `--small-model`, URL validation
- Cache TTL (24h)
- Deduplication with server suffixes (`@host:port`)
- `--default-model` and `--small-model` work with suffixed names

### Changed
- Refactored `process_server()` (eliminated code duplication)

## [1.0.0] - 2026-03-01

### Added
- Initial release
- Local + multiple remote servers
- Embed filtering, context lookup, include/exclude
- Interactive selection, merge mode, dry-run
- Bash and PowerShell scripts
- Provider adapters: Ollama, LM Studio, llama.cpp, OpenAI-compatible
