# OpenCode-configuratiegenerator voor Ollama

Genereert `opencode.json`-configuratie van lokale en externe Ollama-servers.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

English | [Русский](README.ru.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Español](README.es.md) | [中文](README.zh.md) | [日本語](README.ja.md) | [Português](README.pt.md) | [Italiano](README.it.md) | [한국어](README.ko.md) | [العربية](README.ar.md) | [Nederlands](README.nl.md) | [Українська](README.ua.md)

**v1.4.0** | [Specification](SPECIFICATION.md) | [Development](DEVELOPMENT.md) | [Disclaimer](DISCLAIMER.md)

## Kenmerken

- **Multi-provider ondersteuning**: Ollama, LM Studio, vLLM, llama.cpp, LocalAI, text-generation-webui, Jan.ai, GPT4All
- Detecteert provider automatisch op poort, of specificeer met `-p`
- Ontdekt alle modellen automatisch via provider API
- Filtert embedding-modellen eruit (nomic-bert, LM Studio type-veld, enz.)
- Filtert modellen op tool/functie-aanroep ondersteuning (`--tools-only`)
- Haalt exacte contextlengtes op (Ollama `/api/show`, llama.cpp `/props`, LM Studio uitgebreide metadata)
- Ondersteunt meerdere servers van verschillende providers tegelijkertijd
- Interactieve modelselectie (met "Alle modellen" optie)
- Modellen in-/uitsluiten op basis van glob-patronen
- Detecteert `small_model` automatisch (kleinste niet-embed model voor titelgeneratie)
- Dry-run modus (voorbeeld zonder schrijven)
- Respecteert `OLLAMA_HOST` omgevingsvariabele

## Vereisten

| Component | Bash-script | PowerShell-script |
|-----------|:-----------:|:-----------------:|
| curl      | vereist     | niet nodig        |
| Python 3  | vereist     | niet nodig        |
| PowerShell 5.1+ | n/a   | vereist           |

## Snelstart

```bash
# Bash (Linux/macOS/WSL/Git Bash)
./generate_opencode_config.sh

# PowerShell (Windows)
.\Generate-OpenCodeConfig.ps1
```

## Gebruik

### Bash

```bash
# Alleen lokale Ollama (gebruikt $OLLAMA_HOST of http://localhost:11434)
./generate_opencode_config.sh

# Met één externe server
./generate_opencode_config.sh -r http://192.168.1.100:11434

# Met meerdere externe servers
./generate_opencode_config.sh -r http://gpu1:11434 -r http://gpu2:11434

# Interactieve modelselectie
./generate_opencode_config.sh -i

# Alleen qwen-modellen
./generate_opencode_config.sh --include "qwen*"

# Codestral uitsluiten
./generate_opencode_config.sh --exclude "codestral*"

# Embedding-modellen opnemen
./generate_opencode_config.sh --with-embed

# Alleen modellen met tool/functie-aanroep ondersteuning
./generate_opencode_config.sh --tools-only

# Voorbeeld zonder bestand te schrijven
./generate_opencode_config.sh -n

# num_ctx toevoegen aan provideropties (voor tool-aanroepen)
./generate_opencode_config.sh --num-ctx 32768

# Standaardmodel expliciet instellen
./generate_opencode_config.sh --default-model qwen2.5-coder:7b

# Samenvoegen in bestaande configuratie (modellen bijwerken, andere instellingen behouden)
./generate_opencode_config.sh --merge

# /api/show-aanroepen overslaan (sneller, gebruikt hardcoded contextlimieten)
./generate_opencode_config.sh --no-context-lookup

# Contextzoekcache uitschakelen
./generate_opencode_config.sh --no-cache

# Naar globale configuratie schrijven
./generate_opencode_config.sh -o ~/.config/opencode/opencode.json
```

### PowerShell

```powershell
# Alleen lokale Ollama
.\Generate-OpenCodeConfig.ps1

# Met externe servers
.\Generate-OpenCodeConfig.ps1 -RemoteOllamaUrl "http://192.168.1.100:11434"
.\Generate-OpenCodeConfig.ps1 -RemoteOllamaUrl "http://gpu1:11434","http://gpu2:11434"

# Interactieve selectie
.\Generate-OpenCodeConfig.ps1 -Interactive

# Alleen qwen-modellen
.\Generate-OpenCodeConfig.ps1 -Include "qwen*"

# Dry-run
.\Generate-OpenCodeConfig.ps1 -DryRun

# Met num_ctx
.\Generate-OpenCodeConfig.ps1 -NumCtx 32768

# Naar globale configuratie schrijven
.\Generate-OpenCodeConfig.ps1 -OutputFile "$env:USERPROFILE\.config\opencode\opencode.json"
```

## CLI-referentie

### Bash

| Vlag | Beschrijving | Standaard |
|------|-------------|-----------|
| `-l, --local URL` | Lokale server-URL | `$OLLAMA_HOST` of `http://localhost:11434` |
| `-r, --remote URL` | Externe server-URL (herhaalbaar) | geen |
| `-p, --provider NAAM` | Provider: ollama, lmstudio, vllm, llama-cpp, localai, tgwui, jan, gpt4all | auto-detectie |
| `-o, --output BESTAND` | Uitvoerbestandspad (`-` voor stdout) | `opencode.json` |
| `-n, --dry-run` | Naar stdout afdrukken, niet schrijven | uit |
| `-i, --interactive` | Interactieve modelselectie | uit |
| `--include PATROON` | Modellen opnemen die overeen met glob (herhaalbaar) | alle |
| `--exclude PATROON` | Modellen uitsluiten die overeen met glob (herhaalbaar) | geen |
| `--with-embed` | Embedding-modellen opnemen | uitgesloten |
| `--tools-only` | Alleen modellen met tool/functie-aanroep ondersteuning | uit |
| `--no-context-lookup` | `/api/show` overslaan, hardcoded limieten gebruiken | uit |
| `--num-ctx N` | `num_ctx` voor provideropties, 0 om weg te laten | `0` |
| `--merge` | Samenvoegen in bestaande configuratie (alleen modellen bijwerken) | uit |
| `--default-model ID` | Standaardmodel expliciet instellen | auto |
| `--small-model ID` | small_model expliciet instellen (voor titelgeneratie) | auto |
| `--no-cache` | Contextzoekcache uitschakelen | uit |
| `-v, --version` | Versie tonen | |
| `-h, --help` | Help tonen | |

### PowerShell

| Parameter | Beschrijving | Standaard |
|-----------|-------------|-----------|
| `-LocalOllamaUrl` | Lokale Ollama-URL | `$OLLAMA_HOST` of `http://localhost:11434` |
| `-RemoteOllamaUrl` | Externe URL's (array) | geen |
| `-OutputFile` | Uitvoerbestandspad | `opencode.json` |
| `-DryRun` | Naar stdout afdrukken, niet schrijven | uit |
| `-Interactive` | Interactieve modelselectie | uit |
| `-Include` | Opnamepatronen (wildcard, array) | alle |
| `-Exclude` | Uitsluitingspatronen (wildcard, array) | geen |
| `-WithEmbed` | Embedding-modellen opnemen | uitgesloten |
| `-ToolsOnly` | Alleen modellen met tool/functie-aanroep ondersteuning | uit |
| `-NoContextLookup` | `/api/show` overslaan, hardcoded limieten gebruiken | uit |
| `-NumCtx` | `num_ctx` voor provideropties, 0 om weg te laten | `0` |
| `-Merge` | Samenvoegen in bestaande configuratie (alleen modellen bijwerken) | uit |
| `-DefaultModel` | Standaardmodel expliciet instellen | auto |
| `-SmallModel` | small_model expliciet instellen (voor titelgeneratie) | auto |
| `-NoCache` | Contextzoekcache uitschakelen | uit |
| `-Version` | Versie tonen | |
| `-Help` | Help tonen | |

## Hoe het werkt

1. **Modellen ophalen** van elke Ollama-server via `GET /api/tags`
2. **Filteren** van embedding-modellen op het `families`-veld (`nomic-bert`, `bert`, enz.)
3. **Filteren** op include/exclude-patronen (glob-overeenkomst)
4. **Contextlengtes ophalen** voor elk model via `POST /api/show` (parallel, met cache)
5. **Dedupliceren** van modellen gevonden op meerdere servers (behoudt versie van eerste server)
6. **Interactieve selectie** (bij `-i`): genummerde lijst met `[0] Alle modellen` optie
7. **Samenvoegen** (bij `--merge`): bestaande configuratie-instellingen en andere providers behouden
8. **`small_model` automatisch detecteren**: kleinste niet-embed model op parameteraantal
9. **Genereren** van `opencode.json` met Ollama als provider

## Gegenereerde configuratiestructuur

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

### Velden

| Veld | Beschrijving |
|------|-------------|
| `provider.ollama.options.baseURL` | Ollama OpenAI-compatibel eindpunt |
| `provider.ollama.models.*.limit.context` | Maximaal contextvenster voor het model |
| `provider.ollama.models.*.limit.output` | Maximale uitvoertokens (begrensd op 16K) |
| `model` | Standaardmodel (eerste beschikbare) |
| `small_model` | Kleinste model voor lichte taken (titelgeneratie) |

## Modelcontextdetectie

Contextlengtes worden bepaald in deze prioriteitsvolgorde:

1. **API-zoekopdracht** — `POST /api/show` retourneert `model_info.*.context_length` (exacte waarde)
2. **Hardcoded fallback** — geschat op modelfamilie:

| Familie | Standaardcontext |
|---------|:----------------:|
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
| overig | 8.192 |

Gebruik `--no-context-lookup` om API-aanroepen over te slaan en alleen hardcoded waarden te gebruiken (sneller).

## Embedding-modellen

Embedding-modellen zijn **standaard uitgesloten** omdat ze geen chat/tool-aanroepen ondersteunen. Detectie is gebaseerd op:

- Modelfamilies die `nomic-bert`, `bert`, `bert-moe`, `embed`, `embedding` bevatten
- Modelnamen die deze trefwoorden bevatten

Gebruik `--with-embed` / `-WithEmbed` om ze op te nemen.

## Tool/functie-aanroep filter

Gebruik `--tools-only` / `-ToolsOnly` om alleen modellen op te nemen die tool/functie-aanroepen ondersteunen:

```bash
./generate_opencode_config.sh --tools-only
```

Detectie werkt in twee niveaus:
1. **Exact** — LM Studio levert `capabilities.tool_use` via zijn uitgebreide `/api/v1/models`-eindpunt
2. **Heuristisch** — voor alle andere providers worden modellen vergeleken met een bekende toegestane lijst van tool-capabele families (qwen2.5/3, llama3.x, mistral, mixtral, deepseek-r1/v3, command-r, phi3/4, gemma2/3, granite3.x)

Modellen die op geen van beide controles passen, worden uitgesloten wanneer `--tools-only` actief is. De toegestane lijst kan updates nodig hebben naarmate nieuwe modelfamilies worden uitgebracht.

## Multi-provider ondersteuning

Werkt met 8 lokale inferentieproviders. Provider wordt automatisch gedetecteerd op poort, of specificeer met `-p`.

| Provider | Standaardpoort | Uitgebreide metadata | Auto-detectie |
|----------|:--------------:|:--------------------:|:-------------:|
| **Ollama** | 11434 | `/api/show` (context, families) | ✅ |
| **LM Studio** | 1234 | `/api/v1/models` (type, mogelijkheden, context) | ✅ |
| **vLLM** | 8000 | alleen basis | ✅ |
| **llama.cpp** | 8080 | `/props` (context_size) | ✅ (als localai) |
| **LocalAI** | 8080 | alleen basis | ✅ |
| **text-generation-webui** | 5000 | alleen basis | ✅ |
| **Jan.ai** | 1337 | alleen basis | ✅ |
| **GPT4All** | 4891 | alleen basis | ✅ |

```bash
# Auto-detectie op poort
./generate_opencode_config.sh -l http://localhost:1234       # LM Studio
./generate_opencode_config.sh -l http://localhost:8000       # vLLM

# Expliciete provider
./generate_opencode_config.sh -l http://localhost:8080 -p llama-cpp

# Ollama + LM Studio samen
./generate_opencode_config.sh -l http://localhost:11434 -r http://localhost:1234 -p lmstudio
```

Elke provider verschijnt als een apart blok in `opencode.json`:

```json
{
  "provider": {
    "ollama": { "name": "Ollama", "options": { "baseURL": "http://localhost:11434/v1" }, ... },
    "lmstudio": { "name": "LM Studio", "options": { "baseURL": "http://localhost:1234/v1" }, ... }
  }
}
```

## Contextzoekcache

Contextlengtes van `/api/show` worden gecachet in `~/.cache/opencode-generator/` op URL-hash. Cache verloopt na 24 uur. Volgende uitvoeringen hergebruiken gecachete waarden en halen alleen nieuwe modellen op. Gebruik `--no-cache` om uit te schakelen.

## Samenvoegmodus

Gebruik `--merge` om modellen bij te werken in een bestaande `opencode.json` zonder andere instellingen te overschrijven (aangepaste providers, thema's, regels, enz.):

```bash
# Initiële generatie
./generate_opencode_config.sh -o opencode.json

# Handmatig aangepaste providers, regels, enz. toevoegen aan opencode.json

# Later: alleen modellen bijwerken, alles andere behouden
./generate_opencode_config.sh --merge -o opencode.json
```

## Deduplicatie

Als hetzelfde model op meerdere servers bestaat, krijgt elke kopie een unieke naam met serversuffix:

```
qwen2.5-coder:7b                → lokale server (originele naam)
qwen2.5-coder:7b@gpu-server     → eerste externe server
qwen2.5-coder:7b@gpu-server-2   → tweede externe server met dezelfde hostnaam
```

Beide versies verschijnen in `/models`. Het overzicht toont welke modellen een suffix hebben gekregen.

## Omgevingsvariabelen

| Variabele | Beschrijving |
|-----------|-------------|
| `OLLAMA_HOST` | Standaard lokale Ollama-URL (standaard Ollama-variabele) |
| `XDG_CACHE_HOME` | Basispad van cachemap |

## Installeren van de gegenereerde configuratie

```bash
# Globale configuratie (alle projecten)
cp opencode.json ~/.config/opencode/opencode.json

# Projectspecifiek
cp opencode.json /pad/naar/project/opencode.json
```

## Problemen oplossen

### "Kon geen verbinding maken met Ollama"

- Zorg ervoor dat Ollama actief is: `ollama serve`
- Controleer de URL: `curl http://localhost:11434/api/tags`
- Bij aangepaste poort/host: stel `OLLAMA_HOST` in of gebruik `-l`

### "Vereiste afhankelijkheden ontbreken: python3"

```bash
# Ubuntu/Debian
sudo apt install python3

# macOS
brew install python3

# Windows: downloaden van https://python.org
```

### Verkeerde contextlengte

- Het script gebruikt standaard `/api/show` voor exacte waarden
- Als de API traag is, gebruik `--no-context-lookup` voor hardcoded schattingen
- Handmatig overschrijven in de gegenereerde JSON indien nodig

### Embedding-modellen onverwacht opgenomen/uitgesloten

- Controleer families in de uitvoer van `ollama show <model>`
- Gebruik `--with-embed` om opname te forceren
- Gebruik `--exclude "*embed*"` om uitsluiting op naam te forceren

### "Provider retourneerde fout" in OpenCode

- Sommige Ollama-modellen ondersteunen geen tool-aanroepen — probeer `qwen2.5-coder` of `llama3.2`
- Verhoog `num_ctx` als tools falen: `--num-ctx 32768`
- Zorg ervoor dat het model geladen is: `ollama run <model>`
