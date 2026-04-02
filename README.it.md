# Generatore di configurazione OpenCode per Ollama

Genera la configurazione `opencode.json` dai server Ollama locali e remoti.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

English | [Русский](README.ru.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Español](README.es.md) | [中文](README.zh.md) | [日本語](README.ja.md) | [Português](README.pt.md) | [Italiano](README.it.md) | [한국어](README.ko.md) | [العربية](README.ar.md) | [Nederlands](README.nl.md) | [Українська](README.ua.md)

**v1.4.1** | [Specification](SPECIFICATION.md) | [Development](DEVELOPMENT.md) | [Disclaimer](DISCLAIMER.md)

## Funzionalità

- **Supporto multi-provider**: Ollama, LM Studio, vLLM, llama.cpp, LocalAI, text-generation-webui, Jan.ai, GPT4All
- Rileva automaticamente il provider per porta, o specifica con `-p`
- Scopre automaticamente tutti i modelli tramite l'API del provider
- Filtra i modelli di embedding (nomic-bert, campo type di LM Studio, ecc.)
- Filtra i modelli per supporto a chiamata di strumenti/funzioni (`--tools-only`)
- Ottiene lunghezze del contesto esatte (Ollama `/api/show`, llama.cpp `/props`, LM Studio metadati ricchi)
- Supporta più server di provider diversi simultaneamente
- Selezione interattiva dei modelli (con opzione "Tutti i modelli")
- Includi/escludi modelli per pattern glob
- Rileva automaticamente `small_model` (modello non-embed più piccolo per la generazione di titoli)
- Modalità dry-run (anteprima senza scrittura)
- Rispetta la variabile d'ambiente `OLLAMA_HOST`

## Requisiti

| Componente | Script Bash | Script PowerShell |
|------------|:-----------:|:-----------------:|
| curl       | richiesto   | non necessario    |
| Python 3   | richiesto   | non necessario    |
| PowerShell 5.1+ | n/a    | richiesto         |

## Avvio rapido

```bash
# Bash (Linux/macOS/WSL/Git Bash)
./generate_opencode_config.sh

# PowerShell (Windows)
.\Generate-OpenCodeConfig.ps1
```

## Utilizzo

### Bash

```bash
# Solo Ollama locale (usa $OLLAMA_HOST o http://localhost:11434)
./generate_opencode_config.sh

# Con un server remoto
./generate_opencode_config.sh -r http://192.168.1.100:11434

# Con più server remoti
./generate_opencode_config.sh -r http://gpu1:11434 -r http://gpu2:11434

# Selezione interattiva dei modelli
./generate_opencode_config.sh -i

# Solo modelli qwen
./generate_opencode_config.sh --include "qwen*"

# Escludi codestral
./generate_opencode_config.sh --exclude "codestral*"

# Includi modelli di embedding
./generate_opencode_config.sh --with-embed

# Solo modelli con supporto a chiamata di strumenti/funzioni
./generate_opencode_config.sh --tools-only

# Anteprima senza scrivere il file
./generate_opencode_config.sh -n

# Aggiungi num_ctx alle opzioni del provider (per chiamata di strumenti)
./generate_opencode_config.sh --num-ctx 32768

# Imposta esplicitamente il modello predefinito
./generate_opencode_config.sh --default-model qwen2.5-coder:7b

# Unisci nella configurazione esistente (aggiorna modelli, mantieni altre impostazioni)
./generate_opencode_config.sh --merge

# Salta le chiamate /api/show (più veloce, usa limiti di contesto hardcoded)
./generate_opencode_config.sh --no-context-lookup

# Disabilita cache di ricerca del contesto
./generate_opencode_config.sh --no-cache

# Scrivi nella configurazione globale
./generate_opencode_config.sh -o ~/.config/opencode/opencode.json
```

### PowerShell

```powershell
# Solo Ollama locale
.\Generate-OpenCodeConfig.ps1

# Con server remoti
.\Generate-OpenCodeConfig.ps1 -RemoteOllamaUrl "http://192.168.1.100:11434"
.\Generate-OpenCodeConfig.ps1 -RemoteOllamaUrl "http://gpu1:11434","http://gpu2:11434"

# Selezione interattiva
.\Generate-OpenCodeConfig.ps1 -Interactive

# Solo modelli qwen
.\Generate-OpenCodeConfig.ps1 -Include "qwen*"

# Dry-run
.\Generate-OpenCodeConfig.ps1 -DryRun

# Con num_ctx
.\Generate-OpenCodeConfig.ps1 -NumCtx 32768

# Scrivi nella configurazione globale
.\Generate-OpenCodeConfig.ps1 -OutputFile "$env:USERPROFILE\.config\opencode\opencode.json"
```

## Riferimento CLI

### Bash

| Flag | Descrizione | Predefinito |
|------|-------------|-------------|
| `-l, --local URL` | URL del server locale | `$OLLAMA_HOST` o `http://localhost:11434` |
| `-r, --remote URL` | URL del server remoto (ripetibile) | nessuno |
| `-p, --provider NOME` | Provider: ollama, lmstudio, vllm, llama-cpp, localai, tgwui, jan, gpt4all | rilevamento auto |
| `-o, --output FILE` | Percorso del file di output (`-` per stdout) | `opencode.json` |
| `-n, --dry-run` | Stampa su stdout, non scrivere | disattivato |
| `-i, --interactive` | Selezione interattiva dei modelli | disattivato |
| `--include PATTERN` | Includi modelli che corrispondono al glob (ripetibile) | tutti |
| `--exclude PATTERN` | Escludi modelli che corrispondono al glob (ripetibile) | nessuno |
| `--with-embed` | Includi modelli di embedding | esclusi |
| `--tools-only` | Solo modelli con supporto a chiamata di strumenti/funzioni | disattivato |
| `--no-context-lookup` | Salta `/api/show`, usa limiti hardcoded | disattivato |
| `--num-ctx N` | `num_ctx` per le opzioni del provider, 0 per omettere | `0` |
| `--merge` | Unisci nella configurazione esistente (aggiorna solo modelli) | disattivato |
| `--default-model ID` | Imposta esplicitamente il modello predefinito | auto |
| `--small-model ID` | Imposta esplicitamente small_model (per generazione titoli) | auto |
| `--no-cache` | Disabilita cache di ricerca del contesto | disattivato |
| `-v, --version` | Mostra versione | |
| `-h, --help` | Mostra aiuto | |

### PowerShell

| Parametro | Descrizione | Predefinito |
|-----------|-------------|-------------|
| `-LocalOllamaUrl` | URL Ollama locale | `$OLLAMA_HOST` o `http://localhost:11434` |
| `-RemoteOllamaUrl` | URL remot(e) (array) | nessuna |
| `-OutputFile` | Percorso del file di output | `opencode.json` |
| `-DryRun` | Stampa su stdout, non scrivere | disattivato |
| `-Interactive` | Selezione interattiva dei modelli | disattivato |
| `-Include` | Pattern di inclusione (wildcard, array) | tutti |
| `-Exclude` | Pattern di esclusione (wildcard, array) | nessuno |
| `-WithEmbed` | Includi modelli di embedding | esclusi |
| `-ToolsOnly` | Solo modelli con supporto a chiamata di strumenti/funzioni | disattivato |
| `-NoContextLookup` | Salta `/api/show`, usa limiti hardcoded | disattivato |
| `-NumCtx` | `num_ctx` per le opzioni del provider, 0 per omettere | `0` |
| `-Merge` | Unisci nella configurazione esistente (aggiorna solo modelli) | disattivato |
| `-DefaultModel` | Imposta esplicitamente il modello predefinito | auto |
| `-SmallModel` | Imposta esplicitamente small_model (per generazione titoli) | auto |
| `-NoCache` | Disabilita cache di ricerca del contesto | disattivato |
| `-Version` | Mostra versione | |
| `-Help` | Mostra aiuto | |

## Come funziona

1. **Recupera modelli** da ogni server Ollama tramite `GET /api/tags`
2. **Filtra** i modelli di embedding per il campo `families` (`nomic-bert`, `bert`, ecc.)
3. **Filtra** per pattern include/exclude (corrispondenza glob)
4. **Ottiene lunghezze del contesto** per ogni modello tramite `POST /api/show` (parallelo, con cache)
5. **Deduplica** i modelli trovati su più server (mantiene la versione del primo server)
6. **Selezione interattiva** (se `-i`): lista numerata con opzione `[0] Tutti i modelli`
7. **Unione** (se `--merge`): preserva impostazioni esistenti e altri provider
8. **Rileva automaticamente `small_model`**: modello non-embed più piccolo per conteggio parametri
9. **Genera** `opencode.json` con Ollama come provider

## Struttura della configurazione generata

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

### Campi

| Campo | Descrizione |
|-------|-------------|
| `provider.ollama.options.baseURL` | Endpoint compatibile OpenAI di Ollama |
| `provider.ollama.models.*.limit.context` | Finestra di contesto massima per il modello |
| `provider.ollama.models.*.limit.output` | Token di output massimi (limitati a 16K) |
| `model` | Modello predefinito (primo disponibile) |
| `small_model` | Modello più piccolo per attività leggere (generazione titoli) |

## Rilevamento del contesto del modello

Le lunghezze del contesto sono determinate in questo ordine di priorità:

1. **Ricerca API** — `POST /api/show` restituisce `model_info.*.context_length` (valore esatto)
2. **Fallback hardcoded** — stimato per famiglia di modelli:

| Famiglia | Contesto predefinito |
|----------|:--------------------:|
| qwen, qwen2 | 32.768 |
| llama | 8.192 |
| mistral, mixtral | 32.768 |
| deepseek | 65.536 |
| command, command-r | 131.072 |
| yi | 200.000 |
| gemma | 8.192 |
| phi | 4.096 |
| codestral | 32.768 |
| granite | 8.192 |
| altro | 8.192 |

Usa `--no-context-lookup` per saltare le chiamate API e usare solo valori hardcoded (più veloce).

## Modelli di embedding

I modelli di embedding sono **esclusi per impostazione predefinita** perché non supportano chiamata chat/strumenti. Il rilevamento si basa su:

- Famiglie di modelli contenenti `nomic-bert`, `bert`, `bert-moe`, `embed`, `embedding`
- Nomi di modelli contenenti queste parole chiave

Usa `--with-embed` / `-WithEmbed` per includerli.

## Filtro chiamata di strumenti/funzioni

Usa `--tools-only` / `-ToolsOnly` per includere solo modelli che supportano chiamata di strumenti/funzioni:

```bash
./generate_opencode_config.sh --tools-only
```

Il rilevamento funziona su due livelli:
1. **Esatto** — LM Studio fornisce `capabilities.tool_use` tramite il suo endpoint ricco `/api/v1/models`
2. **Euristico** — per tutti gli altri provider, i modelli sono confrontati con una allowlist nota di famiglie capaci di strumenti (qwen2.5/3, llama3.x, mistral, mixtral, deepseek-r1/v3, command-r, phi3/4, gemma2/3, granite3.x)

I modelli che non corrispondono a nessuno dei due controlli sono esclusi quando `--tools-only` è attivo. La allowlist potrebbe richiedere aggiornamenti man mano che vengono rilasciate nuove famiglie di modelli.

## Supporto multi-provider

Funziona con 8 provider di inferenza locale. Il provider viene rilevato automaticamente per porta, o specifica con `-p`.

| Provider | Porta predefinita | Metadati ricchi | Rilevamento auto |
|----------|:-----------------:|:---------------:|:----------------:|
| **Ollama** | 11434 | `/api/show` (contesto, famiglie) | ✅ |
| **LM Studio** | 1234 | `/api/v1/models` (tipo, capacità, contesto) | ✅ |
| **vLLM** | 8000 | solo base | ✅ |
| **llama.cpp** | 8080 | `/props` (context_size) | ✅ (come localai) |
| **LocalAI** | 8080 | solo base | ✅ |
| **text-generation-webui** | 5000 | solo base | ✅ |
| **Jan.ai** | 1337 | solo base | ✅ |
| **GPT4All** | 4891 | solo base | ✅ |

```bash
# Rilevamento automatico per porta
./generate_opencode_config.sh -l http://localhost:1234       # LM Studio
./generate_opencode_config.sh -l http://localhost:8000       # vLLM

# Provider esplicito
./generate_opencode_config.sh -l http://localhost:8080 -p llama-cpp

# Ollama + LM Studio insieme
./generate_opencode_config.sh -l http://localhost:11434 -r http://localhost:1234 -p lmstudio
```

Ogni provider appare come un blocco separato in `opencode.json`:

```json
{
  "provider": {
    "ollama": { "name": "Ollama", "options": { "baseURL": "http://localhost:11434/v1" }, ... },
    "lmstudio": { "name": "LM Studio", "options": { "baseURL": "http://localhost:1234/v1" }, ... }
  }
}
```

## Cache di ricerca del contesto

Le lunghezze del contesto da `/api/show` sono memorizzate nella cache in `~/.cache/opencode-generator/` per hash URL. La cache scade dopo 24 ore. Le esecuzioni successive riutilizzano i valori nella cache e recuperano solo nuovi modelli. Usa `--no-cache` per disabilitare.

## Modalità unione

Usa `--merge` per aggiornare i modelli in un `opencode.json` esistente senza sovrascrivere altre impostazioni (provider personalizzati, temi, regole, ecc.):

```bash
# Generazione iniziale
./generate_opencode_config.sh -o opencode.json

# Aggiungi manualmente provider personalizzati, regole, ecc. a opencode.json

# Successivamente: aggiorna solo i modelli, mantieni tutto il resto
./generate_opencode_config.sh --merge -o opencode.json
```

## Deduplicazione

Se lo stesso modello esiste su più server, ogni copia riceve un nome univoco con suffisso del server:

```
qwen2.5-coder:7b                → server locale (nome originale)
qwen2.5-coder:7b@gpu-server     → primo server remoto
qwen2.5-coder:7b@gpu-server-2   → secondo server remoto con stesso hostname
```

Entrambe le versioni appaiono in `/models`. Il riepilogo mostra quali modelli hanno ricevuto un suffisso.

## Variabili d'ambiente

| Variabile | Descrizione |
|-----------|-------------|
| `OLLAMA_HOST` | URL Ollama locale predefinito (variabile standard Ollama) |
| `XDG_CACHE_HOME` | Percorso base della directory cache |

## Installazione della configurazione generata

```bash
# Configurazione globale (tutti i progetti)
cp opencode.json ~/.config/opencode/opencode.json

# Specifico del progetto
cp opencode.json /percorso/del/progetto/opencode.json
```

## Risoluzione dei problemi

### "Impossibile connettersi a Ollama"

- Assicurati che Ollama sia in esecuzione: `ollama serve`
- Verifica l'URL: `curl http://localhost:11434/api/tags`
- Se usi una porta/host personalizzata, imposta `OLLAMA_HOST` o usa `-l`

### "Dipendenze richieste mancanti: python3"

```bash
# Ubuntu/Debian
sudo apt install python3

# macOS
brew install python3

# Windows: scarica da https://python.org
```

### Lunghezza del contesto errata

- Lo script usa `/api/show` per impostazione predefinita per valori esatti
- Se l'API è lenta, usa `--no-context-lookup` per stime hardcoded
- Sovrascrivi manualmente nel JSON generato se necessario

## Modelli di embedding inclusi/esclusi inaspettatamente

- Controlla le famiglie nell'output di `ollama show <model>`
- Usa `--with-embed` per forzare l'inclusione
- Usa `--exclude "*embed*"` per forzare l'esclusione per nome

### "Il provider ha restituito un errore" in OpenCode

- Alcuni modelli Ollama non supportano la chiamata di strumenti — prova `qwen2.5-coder` o `llama3.2`
- Aumenta `num_ctx` se gli strumenti falliscono: `--num-ctx 32768`
- Assicurati che il modello sia caricato: `ollama run <model>`
