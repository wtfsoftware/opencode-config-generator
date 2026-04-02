# OpenCode-Konfigurationsgenerator für Ollama

Generiert `opencode.json`-Konfiguration von lokalen und entfernten Ollama-Servern.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

English | [Русский](README.ru.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Español](README.es.md) | [中文](README.zh.md) | [日本語](README.ja.md) | [Português](README.pt.md) | [Italiano](README.it.md) | [한국어](README.ko.md) | [العربية](README.ar.md) | [Nederlands](README.nl.md) | [Українська](README.ua.md)

**v1.4.1** | [Specification](SPECIFICATION.md) | [Development](DEVELOPMENT.md) | [Disclaimer](DISCLAIMER.md)

## Funktionen

- **Multi-Anbieter-Unterstützung**: Ollama, LM Studio, vLLM, llama.cpp, LocalAI, text-generation-webui, Jan.ai, GPT4All
- Erkennt Anbieter automatisch nach Port, oder mit `-p` angeben
- Entdeckt alle Modelle automatisch über die Anbieter-API
- Filtert Embedding-Modelle heraus (nomic-bert, LM Studio type-Feld usw.)
- Filtert Modelle nach Tool-/Funktionsaufruf-Unterstützung (`--tools-only`)
- Ruft exakte Kontextlängen ab (Ollama `/api/show`, llama.cpp `/props`, LM Studio erweiterte Metadaten)
- Unterstützt mehrere Server verschiedener Anbieter gleichzeitig
- Interaktive Modellauswahl (mit Option „Alle Modelle")
- Modelle nach Glob-Mustern ein-/ausschließen
- Erkennt `small_model` automatisch (kleinstes Nicht-Embed-Modell für Titelgenerierung)
- Dry-Run-Modus (Vorschau ohne Schreiben)
- Berücksichtigt die Umgebungsvariable `OLLAMA_HOST`

## Anforderungen

| Komponente | Bash-Skript | PowerShell-Skript |
|------------|:-----------:|:-----------------:|
| curl       | erforderlich| nicht erforderlich|
| Python 3   | erforderlich| nicht erforderlich|
| PowerShell 5.1+ | n/a    | erforderlich      |

## Schnellstart

```bash
# Bash (Linux/macOS/WSL/Git Bash)
./generate_opencode_config.sh

# PowerShell (Windows)
.\Generate-OpenCodeConfig.ps1
```

## Verwendung

### Bash

```bash
# Nur lokales Ollama (verwendet $OLLAMA_HOST oder http://localhost:11434)
./generate_opencode_config.sh

# Mit einem entfernten Server
./generate_opencode_config.sh -r http://192.168.1.100:11434

# Mit mehreren entfernten Servern
./generate_opencode_config.sh -r http://gpu1:11434 -r http://gpu2:11434

# Interaktive Modellauswahl
./generate_opencode_config.sh -i

# Nur qwen-Modelle
./generate_opencode_config.sh --include "qwen*"

# Codestral ausschließen
./generate_opencode_config.sh --exclude "codestral*"

# Embedding-Modelle einschließen
./generate_opencode_config.sh --with-embed

# Nur Modelle mit Tool-/Funktionsaufruf-Unterstützung
./generate_opencode_config.sh --tools-only

# Vorschau ohne Datei zu schreiben
./generate_opencode_config.sh -n

# num_ctx zu Anbieteroptionen hinzufügen (für Tool-Aufrufe)
./generate_opencode_config.sh --num-ctx 32768

# Standardmodell explizit setzen
./generate_opencode_config.sh --default-model qwen2.5-coder:7b

# In bestehende Konfiguration zusammenführen (Modelle aktualisieren, andere Einstellungen beibehalten)
./generate_opencode_config.sh --merge

# /api/show-Aufrufe überspringen (schneller, verwendet hartkodierte Kontextlimits)
./generate_opencode_config.sh --no-context-lookup

# Kontextsuch-Cache deaktivieren
./generate_opencode_config.sh --no-cache

# In globale Konfiguration schreiben
./generate_opencode_config.sh -o ~/.config/opencode/opencode.json
```

### PowerShell

```powershell
# Nur lokales Ollama
.\Generate-OpenCodeConfig.ps1

# Mit entfernten Servern
.\Generate-OpenCodeConfig.ps1 -RemoteOllamaUrl "http://192.168.1.100:11434"
.\Generate-OpenCodeConfig.ps1 -RemoteOllamaUrl "http://gpu1:11434","http://gpu2:11434"

# Interaktive Auswahl
.\Generate-OpenCodeConfig.ps1 -Interactive

# Nur qwen-Modelle
.\Generate-OpenCodeConfig.ps1 -Include "qwen*"

# Dry-Run
.\Generate-OpenCodeConfig.ps1 -DryRun

# Mit num_ctx
.\Generate-OpenCodeConfig.ps1 -NumCtx 32768

# In globale Konfiguration schreiben
.\Generate-OpenCodeConfig.ps1 -OutputFile "$env:USERPROFILE\.config\opencode\opencode.json"
```

## CLI-Referenz

### Bash

| Flag | Beschreibung | Standard |
|------|-------------|----------|
| `-l, --local URL` | Lokale Server-URL | `$OLLAMA_HOST` oder `http://localhost:11434` |
| `-r, --remote URL` | Entfernte Server-URL (wiederholbar) | keine |
| `-p, --provider NAME` | Anbieter: ollama, lmstudio, vllm, llama-cpp, localai, tgwui, jan, gpt4all | Auto-Erkennung |
| `-o, --output DATEI` | Ausgabedateipfad (`-` für stdout) | `opencode.json` |
| `-n, --dry-run` | Auf stdout ausgeben, nicht schreiben | aus |
| `-i, --interactive` | Interaktive Modellauswahl | aus |
| `--include MUSTER` | Modelle einschließen, die auf Glob passen (wiederholbar) | alle |
| `--exclude MUSTER` | Modelle ausschließen, die auf Glob passen (wiederholbar) | keine |
| `--with-embed` | Embedding-Modelle einschließen | ausgeschlossen |
| `--tools-only` | Nur Modelle mit Tool-/Funktionsaufruf-Unterstützung | aus |
| `--no-context-lookup` | `/api/show` überspringen, hartkodierte Limits verwenden | aus |
| `--num-ctx N` | `num_ctx` für Anbieteroptionen, 0 zum Weglassen | `0` |
| `--merge` | In bestehende Konfiguration zusammenführen (nur Modelle aktualisieren) | aus |
| `--default-model ID` | Standardmodell explizit setzen | auto |
| `--small-model ID` | Small Model explizit setzen (für Titelgenerierung) | auto |
| `--no-cache` | Kontextsuch-Cache deaktivieren | aus |
| `-v, --version` | Version anzeigen | |
| `-h, --help` | Hilfe anzeigen | |

### PowerShell

| Parameter | Beschreibung | Standard |
|-----------|-------------|----------|
| `-LocalOllamaUrl` | Lokale Ollama-URL | `$OLLAMA_HOST` oder `http://localhost:11434` |
| `-RemoteOllamaUrl` | Entfernte URL(s) (Array) | keine |
| `-OutputFile` | Ausgabedateipfad | `opencode.json` |
| `-DryRun` | Auf stdout ausgeben, nicht schreiben | aus |
| `-Interactive` | Interaktive Modellauswahl | aus |
| `-Include` | Einschlussmuster (Wildcard, Array) | alle |
| `-Exclude` | Ausschlussmuster (Wildcard, Array) | keine |
| `-WithEmbed` | Embedding-Modelle einschließen | ausgeschlossen |
| `-ToolsOnly` | Nur Modelle mit Tool-/Funktionsaufruf-Unterstützung | aus |
| `-NoContextLookup` | `/api/show` überspringen, hartkodierte Limits verwenden | aus |
| `-NumCtx` | `num_ctx` für Anbieteroptionen, 0 zum Weglassen | `0` |
| `-Merge` | In bestehende Konfiguration zusammenführen (nur Modelle aktualisieren) | aus |
| `-DefaultModel` | Standardmodell explizit setzen | auto |
| `-SmallModel` | Small Model explizit setzen (für Titelgenerierung) | auto |
| `-NoCache` | Kontextsuch-Cache deaktivieren | aus |
| `-Version` | Version anzeigen | |
| `-Help` | Hilfe anzeigen | |

## So funktioniert es

1. **Modelle abrufen** von jedem Ollama-Server über `GET /api/tags`
2. **Filtern** von Embedding-Modellen nach dem `families`-Feld (`nomic-bert`, `bert` usw.)
3. **Filtern** nach Include/Exclude-Mustern (Glob-Abgleich)
4. **Kontextlängen abrufen** für jedes Modell über `POST /api/show` (parallel, mit Cache)
5. **Deduplizieren** von Modellen, die auf mehreren Servern gefunden wurden (behält die Version des ersten Servers)
6. **Interaktive Auswahl** (bei `-i`): nummerierte Liste mit `[0] Alle Modelle`-Option
7. **Zusammenführen** (bei `--merge`): bestehende Konfigurationseinstellungen und andere Anbieter beibehalten
8. **`small_model` automatisch erkennen**: kleinstes Nicht-Embed-Modell nach Parameteranzahl
9. **Generieren** von `opencode.json` mit Ollama als Anbieter

## Generierte Konfigurationsstruktur

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

### Felder

| Feld | Beschreibung |
|------|-------------|
| `provider.ollama.options.baseURL` | Ollama OpenAI-kompatibler Endpunkt |
| `provider.ollama.models.*.limit.context` | Maximales Kontextfenster für das Modell |
| `provider.ollama.models.*.limit.output` | Maximale Ausgabe-Tokens (auf 16K begrenzt) |
| `model` | Standardmodell (erstes verfügbares) |
| `small_model` | Kleinstes Modell für leichte Aufgaben (Titelgenerierung) |

## Modell-Kontexterkennung

Kontextlängen werden in dieser Prioritätsreihenfolge bestimmt:

1. **API-Suche** — `POST /api/show` gibt `model_info.*.context_length` zurück (exakter Wert)
2. **Hartkodierter Fallback** — geschätzt nach Modellfamilie:

| Familie | Standard-Kontext |
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
| andere | 8.192 |

Verwenden Sie `--no-context-lookup`, um API-Aufrufe zu überspringen und nur hartkodierte Werte zu verwenden (schneller).

## Embedding-Modelle

Embedding-Modelle sind **standardmäßig ausgeschlossen**, da sie keinen Chat-/Tool-Aufruf unterstützen. Die Erkennung basiert auf:

- Modellfamilien, die `nomic-bert`, `bert`, `bert-moe`, `embed`, `embedding` enthalten
- Modellnamen, die diese Schlüsselwörter enthalten

Verwenden Sie `--with-embed` / `-WithEmbed`, um sie einzuschließen.

## Tool-/Funktionsaufruf-Filter

Verwenden Sie `--tools-only` / `-ToolsOnly`, um nur Modelle einzuschließen, die Tool-/Funktionsaufrufe unterstützen:

```bash
./generate_opencode_config.sh --tools-only
```

Die Erkennung funktioniert in zwei Stufen:
1. **Exakt** — LM Studio stellt `capabilities.tool_use` über seinen erweiterten `/api/v1/models`-Endpunkt bereit
2. **Heuristisch** — für alle anderen Anbieter werden Modelle mit einer bekannten Allowlist von Tool-fähigen Familien abgeglichen (qwen2.5/3, llama3.x, mistral, mixtral, deepseek-r1/v3, command-r, phi3/4, gemma2/3, granite3.x)

Modelle, die auf keine der beiden Prüfungen passen, werden ausgeschlossen, wenn `--tools-only` aktiv ist. Die Allowlist muss möglicherweise aktualisiert werden, wenn neue Modellfamilien veröffentlicht werden.

## Multi-Anbieter-Unterstützung

Funktioniert mit 8 lokalen Inferenz-Anbietern. Der Anbieter wird automatisch nach Port erkannt, oder mit `-p` angeben.

| Anbieter | Standard-Port | Erweiterte Metadaten | Auto-Erkennung |
|----------|:-------------:|:--------------------:|:--------------:|
| **Ollama** | 11434 | `/api/show` (Kontext, Familien) | ✅ |
| **LM Studio** | 1234 | `/api/v1/models` (Typ, Fähigkeiten, Kontext) | ✅ |
| **vLLM** | 8000 | nur Basis | ✅ |
| **llama.cpp** | 8080 | `/props` (context_size) | ✅ (als localai) |
| **LocalAI** | 8080 | nur Basis | ✅ |
| **text-generation-webui** | 5000 | nur Basis | ✅ |
| **Jan.ai** | 1337 | nur Basis | ✅ |
| **GPT4All** | 4891 | nur Basis | ✅ |

```bash
# Auto-Erkennung nach Port
./generate_opencode_config.sh -l http://localhost:1234       # LM Studio
./generate_opencode_config.sh -l http://localhost:8000       # vLLM

# Expliziter Anbieter
./generate_opencode_config.sh -l http://localhost:8080 -p llama-cpp

# Ollama + LM Studio zusammen
./generate_opencode_config.sh -l http://localhost:11434 -r http://localhost:1234 -p lmstudio
```

Jeder Anbieter erscheint als separater Block in `opencode.json`:

```json
{
  "provider": {
    "ollama": { "name": "Ollama", "options": { "baseURL": "http://localhost:11434/v1" }, ... },
    "lmstudio": { "name": "LM Studio", "options": { "baseURL": "http://localhost:1234/v1" }, ... }
  }
}
```

## Kontextsuch-Cache

Kontextlängen von `/api/show` werden in `~/.cache/opencode-generator/` nach URL-Hash zwischengespeichert. Der Cache läuft nach 24 Stunden ab. Nachfolgende Ausführungen verwenden zwischengespeicherte Werte erneut und rufen nur neue Modelle ab. Verwenden Sie `--no-cache` zum Deaktivieren.

## Zusammenführungsmodus

Verwenden Sie `--merge`, um Modelle in einer bestehenden `opencode.json` zu aktualisieren, ohne andere Einstellungen zu überschreiben (benutzerdefinierte Anbieter, Themes, Regeln usw.):

```bash
# Initiale Generierung
./generate_opencode_config.sh -o opencode.json

# Manuelles Hinzufügen von benutzerdefinierten Anbietern, Regeln usw. in opencode.json

# Später: Nur Modelle aktualisieren, alles andere beibehalten
./generate_opencode_config.sh --merge -o opencode.json
```

## Deduplizierung

Wenn dasselbe Modell auf mehreren Servern existiert, erhält jede Kopie einen eindeutigen Namen mit Server-Suffix:

```
qwen2.5-coder:7b                → lokaler Server (originaler Name)
qwen2.5-coder:7b@gpu-server     → erster entfernter Server
qwen2.5-coder:7b@gpu-server-2   → zweiter entfernter Server mit gleichem Hostnamen
```

Beide Versionen erscheinen in `/models`. Die Zusammenfassung zeigt, welche Modelle ein Suffix erhalten haben.

## Umgebungsvariablen

| Variable | Beschreibung |
|----------|-------------|
| `OLLAMA_HOST` | Standardmäßige lokale Ollama-URL (Standard-Ollama-Variable) |
| `XDG_CACHE_HOME` | Basispfad des Cache-Verzeichnisses |

## Installieren der generierten Konfiguration

```bash
# Globale Konfiguration (alle Projekte)
cp opencode.json ~/.config/opencode/opencode.json

# Projektspezifisch
cp opencode.json /pfad/zum/projekt/opencode.json
```

## Fehlerbehebung

### „Verbindung zu Ollama nicht möglich"

- Stellen Sie sicher, dass Ollama läuft: `ollama serve`
- Überprüfen Sie die URL: `curl http://localhost:11434/api/tags`
- Bei benutzerdefiniertem Port/Host: `OLLAMA_HOST` setzen oder `-l` verwenden

### „Erforderliche Abhängigkeiten fehlen: python3"

```bash
# Ubuntu/Debian
sudo apt install python3

# macOS
brew install python3

# Windows: herunterladen von https://python.org
```

### Falsche Kontextlänge

- Das Skript verwendet standardmäßig `/api/show` für exakte Werte
- Wenn die API langsam ist, verwenden Sie `--no-context-lookup` für hartkodierte Schätzungen
- Bei Bedarf manuell im generierten JSON überschreiben

### Embedding-Modelle unerwartet eingeschlossen/ausgeschlossen

- Familien in der Ausgabe von `ollama show <model>` prüfen
- `--with-embed` zum erzwungenen Einschließen verwenden
- `--exclude "*embed*"` zum erzwungenen Ausschließen nach Name verwenden

### „Anbieter hat Fehler zurückgegeben" in OpenCode

- Einige Ollama-Modelle unterstützen keine Tool-Aufrufe — versuchen Sie `qwen2.5-coder` oder `llama3.2`
- `num_ctx` erhöhen, wenn Tools fehlschlagen: `--num-ctx 32768`
- Stellen Sie sicher, dass das Modell geladen ist: `ollama run <model>`
