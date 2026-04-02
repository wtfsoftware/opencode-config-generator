# OpenCode-Konfigurationsgenerator für Ollama

Generiert `opencode.json` für [OpenCode](https://opencode.ai) basierend auf Modellen von lokalen und entfernten Ollama-Servern.

[English](README.md) | [Русский](README.ru.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Español](README.es.md) | [中文](README.zh.md) | [日本語](README.ja.md) | [Português](README.pt.md) | [Italiano](README.it.md) | [한국어](README.ko.md) | [العربية](README.ar.md) | [Nederlands](README.nl.md) | [Українська](README.ua.md)

**v1.3.0** | [Specification](SPECIFICATION.md) | [Development](DEVELOPMENT.md) | [Disclaimer](DISCLAIMER.md)

---

## Funktionen

- **Multi-provider**: Ollama, LM Studio, vLLM, llama.cpp, LocalAI, text-generation-webui, Jan.ai, GPT4All
- Automatische Modellerkennung über die Ollama-API
- Filterung von Embedding-Modellen (nomic-bert usw.)
- Genaue Kontextlängen über `/api/show` (mit Fallback)
- Unterstützung mehrerer entfernter Ollama-Server
- Interaktive Modellauswahl mit „Alle"-Option
- Filterung nach Glob-Mustern (include/exclude)
- Automatische Erkennung von small_model
- Vorschau-Modus (dry-run)
- Server-Suffixe bei doppelten Modellen
- Zusammenführung mit bestehender Konfiguration
- Unterstützung der `OLLAMA_HOST`-Umgebungsvariable

## Anforderungen

| Component | Bash | PowerShell |
|-----------|:----:|:----------:|
| curl | required | not needed |
| Python 3 | required | not needed |
| PowerShell 5.1+ | n/a | required |

## Schnellstart

```bash
./generate_opencode_config.sh
.\Generate-OpenCodeConfig.ps1
```

## Verwendung

```bash
./generate_opencode_config.sh -r http://gpu:11434    # remote
./generate_opencode_config.sh -i                      # interactive
./generate_opencode_config.sh --include "qwen*"       # filter
./generate_opencode_config.sh -n                      # dry-run
./generate_opencode_config.sh --merge                 # merge
./generate_opencode_config.sh --default-model qwen2.5-coder:7b
./generate_opencode_config.sh -v                      # version
```

## CLI-Referenz

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
| `--tools-only` | Only models with tool/function calling support |
| `-ToolsOnly` | Only models with tool/function calling support |
| `--no-context-lookup` | Skip API lookup |
| `--num-ctx N` | num_ctx (0=omit) |
| `--merge` | Merge config |
| `--default-model ID` | Default model |
| `--small-model ID` | Small model |
| `--no-cache` | Disable cache |
| `-v, --version` | Version |

## Funktionsweise

1. **Modelle abrufen** von jedem Server über `GET /api/tags`
2. **Filtern** von Embedding-Modellen nach dem `families`-Feld
3. **Filtern** nach include/exclude-Mustern (Glob)
4. **Kontextlängen abrufen** über `POST /api/show` (parallel, mit Cache)
5. **Deduplizierung** von Modellen mehrerer Server (Suffixe `@host:port`)
6. **Interaktive Auswahl** (bei `-i`)
7. **Zusammenführung** (bei `--merge`): bestehende Einstellungen beibehalten
8. **small_model erkennen**: kleinstes Nicht-Embed-Modell
9. **Generierung** von `opencode.json`

## Konfigurationsbeispiel

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

## Deduplizierung

Wenn dasselbe Modell auf mehreren Servern vorhanden ist, erhält jede Kopie einen eindeutigen Namen mit Server-Suffix:

```
qwen2.5-coder:7b             → local
qwen2.5-coder:7b@gpu-server  → remote
```

## Kontext-Cache

Kontextlängen werden in `~/.cache/opencode-generator/` zwischengespeichert. Der Cache läuft nach 24 Stunden ab.

## Zusammenführungsmodus

Verwenden Sie `--merge`, um Modelle zu aktualisieren, ohne andere Einstellungen zu überschreiben:

```bash
./generate_opencode_config.sh --merge -o opencode.json
```

## Konfiguration installieren

```bash
cp opencode.json ~/.config/opencode/opencode.json
```

## Umgebungsvariablen

| Variable | Description |
|----------|-------------|
| `OLLAMA_HOST` | Default Ollama URL |
| `XDG_CACHE_HOME` | Cache directory |

## Fehlerbehebung

### Verbindung zu Ollama nicht möglich

- Stellen Sie sicher, dass Ollama läuft: `ollama serve`
- Überprüfen Sie die URL: `curl http://localhost:11434/api/tags`

### Fehlende Abhängigkeiten

```bash
sudo apt install python3 curl   # Ubuntu/Debian
brew install python3 curl       # macOS
```

### Falscher Kontext

- Das Skript verwendet standardmäßig `/api/show`
- Verwenden Sie `--no-context-lookup`, wenn die API langsam ist
