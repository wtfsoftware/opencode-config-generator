# Generatore di configurazione OpenCode per Ollama

Genera `opencode.json` per [OpenCode](https://opencode.ai) dai modelli dei server Ollama locali e remoti.

[English](README.md) | [Русский](README.ru.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Español](README.es.md) | [中文](README.zh.md) | [日本語](README.ja.md) | [Português](README.pt.md) | [Italiano](README.it.md) | [한국어](README.ko.md) | [العربية](README.ar.md) | [Nederlands](README.nl.md) | [Українська](README.ua.md)

**v1.1.0** | [Specification](SPECIFICATION.md) | [Development](DEVELOPMENT.md) | [Disclaimer](DISCLAIMER.md)

---

## Funzionalità

- Scoperta automatica dei modelli tramite API Ollama
- Filtraggio dei modelli di embedding (nomic-bert, ecc.)
- Lunghezze del contesto esatte tramite `/api/show` (con fallback)
- Supporto per più server Ollama remoti
- Selezione interattiva dei modelli con opzione "Tutti"
- Filtraggio per pattern glob (include/exclude)
- Rilevamento automatico di small_model
- Modalità anteprima (dry-run)
- Suffissi del server per modelli duplicati
- Fusione con la configurazione esistente (merge)
- Supporto della variabile d'ambiente `OLLAMA_HOST`

## Requisiti

| Component | Bash | PowerShell |
|-----------|:----:|:----------:|
| curl | required | not needed |
| Python 3 | required | not needed |
| PowerShell 5.1+ | n/a | required |

## Avvio rapido

```bash
./generate_opencode_config.sh
.\Generate-OpenCodeConfig.ps1
```

## Utilizzo

```bash
./generate_opencode_config.sh -r http://gpu:11434    # remote
./generate_opencode_config.sh -i                      # interactive
./generate_opencode_config.sh --include "qwen*"       # filter
./generate_opencode_config.sh -n                      # dry-run
./generate_opencode_config.sh --merge                 # merge
./generate_opencode_config.sh --default-model qwen2.5-coder:7b
./generate_opencode_config.sh -v                      # version
```

## Riferimento CLI

| Flag | Description |
|------|-------------|
| `-l, --local URL` | Local Ollama URL |
| `-r, --remote URL` | Remote URL (repeatable) |
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

## Come funziona

1. **Ottenere i modelli** da ogni server tramite `GET /api/tags`
2. **Filtrare** i modelli di embedding per il campo `families`
3. **Filtrare** per pattern include/exclude (glob)
4. **Ottenere i contesti** tramite `POST /api/show` (parallelo, con cache)
5. **Deduplicare** i modelli di più server (suffissi `@host:port`)
6. **Selezione interattiva** (con `-i`)
7. **Fusione** (con `--merge`): preservare le impostazioni esistenti
8. **Rilevare small_model**: modello più piccolo non-embed
9. **Generare** `opencode.json`

## Esempio di configurazione

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

## Deduplicazione

Se lo stesso modello esiste su più server, ogni copia riceve un nome unico con suffisso del server:

```
qwen2.5-coder:7b             → local
qwen2.5-coder:7b@gpu-server  → remote
```

## Cache del contesto

Le lunghezze del contesto sono memorizzate nella cache in `~/.cache/opencode-generator/`. La cache scade dopo 24 ore.

## Modalità fusione

Usa `--merge` per aggiornare i modelli senza sovrascrivere altre impostazioni:

```bash
./generate_opencode_config.sh --merge -o opencode.json
```

## Installare la configurazione

```bash
cp opencode.json ~/.config/opencode/opencode.json
```

## Variabili d'ambiente

| Variable | Description |
|----------|-------------|
| `OLLAMA_HOST` | Default Ollama URL |
| `XDG_CACHE_HOME` | Cache directory |

## Risoluzione dei problemi

### Impossibile connettersi a Ollama

- Assicurati che Ollama sia in esecuzione: `ollama serve`
- Verifica l'URL: `curl http://localhost:11434/api/tags`

### Dipendenze mancanti

```bash
sudo apt install python3 curl   # Ubuntu/Debian
brew install python3 curl       # macOS
```

### Contesto errato

- Lo script usa `/api/show` per impostazione predefinita
- Usa `--no-context-lookup` se l'API è lento
