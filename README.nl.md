# OpenCode-configuratiegenerator voor Ollama

Genereert `opencode.json` voor [OpenCode](https://opencode.ai) op basis van modellen van lokale en externe Ollama-servers.

[English](README.md) | [Русский](README.ru.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Español](README.es.md) | [中文](README.zh.md) | [日本語](README.ja.md) | [Português](README.pt.md) | [Italiano](README.it.md) | [한국어](README.ko.md) | [العربية](README.ar.md) | [Nederlands](README.nl.md) | [Українська](README.ua.md)

**v1.1.0** | [Specification](SPECIFICATION.md) | [Development](DEVELOPMENT.md) | [Disclaimer](DISCLAIMER.md)

---

## Kenmerken

- **Multi-provider**: Ollama, LM Studio, vLLM, llama.cpp, LocalAI, text-generation-webui, Jan.ai, GPT4All
- Automatische modelherkenning via Ollama-API
- Filtering van embedding-modellen (nomic-bert, enz.)
- Exacte contextlengtes via `/api/show` (met terugval)
- Ondersteuning voor meerdere externe Ollama-servers
- Interactieve modelselectie met "Alles"-optie
- Filtering op glob-patronen (include/exclude)
- Automatische detectie van small_model
- Voorbeeldmodus (dry-run)
- Serversuffixen voor dubbele modellen
- Samenvoegen met bestaande configuratie (merge)
- Ondersteuning voor `OLLAMA_HOST` omgevingsvariabele

## Vereisten

| Component | Bash | PowerShell |
|-----------|:----:|:----------:|
| curl | required | not needed |
| Python 3 | required | not needed |
| PowerShell 5.1+ | n/a | required |

## Snelstart

```bash
./generate_opencode_config.sh
.\Generate-OpenCodeConfig.ps1
```

## Gebruik

```bash
./generate_opencode_config.sh -r http://gpu:11434    # remote
./generate_opencode_config.sh -i                      # interactive
./generate_opencode_config.sh --include "qwen*"       # filter
./generate_opencode_config.sh -n                      # dry-run
./generate_opencode_config.sh --merge                 # merge
./generate_opencode_config.sh --default-model qwen2.5-coder:7b
./generate_opencode_config.sh -v                      # version
```

## CLI-referentie

| Flag | Description |
|------|-------------|
| `-l, --local URL` | Local server URL |
| `-r, --remote URL` | Remote URL (repeatable) |
| `-p, --provider NAME` | Provider: ollama, lmstudio, vllm, llama-cpp, localai, tgwui, jan, gpt4all | auto |
| `-o, --output FILE` | Output (`-` for stdout) |
| `-n, --dry-run` | Preview |
| `-i, --interactive` | Interactive selection |
| `--include PAT` | Include pattern |
| `--exclude PAT` | Exclude pattern |
| `--with-embed` | Include embed models |
| `--no-context-lookup` | Skip API lookup |
| `--num-ctx N` | num_ctx (0=omit) |
| `--merge` | Merge config |
| `--default-model ID` | Default model |
| `--small-model ID` | Small model |
| `--no-cache` | Disable cache |
| `-v, --version` | Version |

## Hoe het werkt

1. **Modellen ophalen** van elke server via `GET /api/tags`
2. **Filteren** van embedding-modellen op het `families`-veld
3. **Filteren** op include/exclude-patronen (glob)
4. **Contextlengtes ophalen** via `POST /api/show` (parallel, met cache)
5. **Deduplicatie** van modellen van meerdere servers (suffixen `@host:port`)
6. **Interactieve selectie** (bij `-i`)
7. **Samenvoegen** (bij `--merge`): bestaande instellingen behouden
8. **small_model detecteren**: kleinste niet-embed-model
9. **Genereren** van `opencode.json`

## Configuratievoorbeeld

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "options": { "baseURL": "http://localhost:11434/v1" },
      "models": {
        "qwen2.5-coder:7b": {
          "name": "Qwen2 7.6B Q4_K_M (local)",
          "limit": { "context": 32768, "output": 16384 }
        }
      }
    }
  },
  "model": "ollama/qwen2.5-coder:7b"
}
```

## Deduplicatie

Als hetzelfde model op meerdere servers bestaat, krijgt elk exemplaar een unieke naam met serversuffix:

```
qwen2.5-coder:7b             → local
qwen2.5-coder:7b@gpu-server  → remote
```

## Contextcache

Contextlengtes worden opgeslagen in `~/.cache/opencode-generator/`. De cache verloopt na 24 uur.

## Samenvoegmodus

Gebruik `--merge` om modellen bij te werken zonder andere instellingen te overschrijven:

```bash
./generate_opencode_config.sh --merge -o opencode.json
```

## Configuratie installeren

```bash
cp opencode.json ~/.config/opencode/opencode.json
```

## Omgevingsvariabelen

| Variable | Description |
|----------|-------------|
| `OLLAMA_HOST` | Default Ollama URL |
| `XDG_CACHE_HOME` | Cache directory |

## Problemen oplossen

### Kan geen verbinding maken met Ollama

- Zorg ervoor dat Ollama actief is: `ollama serve`
- Controleer de URL: `curl http://localhost:11434/api/tags`

### Ontbrekende afhankelijkheden

```bash
sudo apt install python3 curl   # Ubuntu/Debian
brew install python3 curl       # macOS
```

### Onjuiste context

- Het script gebruikt standaard `/api/show`
- Gebruik `--no-context-lookup` als de API langzaam is
