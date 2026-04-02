# Générateur de configuration OpenCode pour Ollama

Génère `opencode.json` pour [OpenCode](https://opencode.ai) à partir des modèles des serveurs Ollama locaux et distants.

[English](README.md) | [Русский](README.ru.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Español](README.es.md) | [中文](README.zh.md) | [日本語](README.ja.md) | [Português](README.pt.md) | [Italiano](README.it.md) | [한국어](README.ko.md) | [العربية](README.ar.md) | [Nederlands](README.nl.md) | [Українська](README.ua.md)

**v1.3.0** | [Specification](SPECIFICATION.md) | [Development](DEVELOPMENT.md) | [Disclaimer](DISCLAIMER.md)

---

## Fonctionnalités

- **Multi-provider**: Ollama, LM Studio, vLLM, llama.cpp, LocalAI, text-generation-webui, Jan.ai, GPT4All
- Découverte automatique des modèles via l'API Ollama
- Filtrage des modèles d'embedding (nomic-bert, etc.)
- Longueurs de contexte exactes via `/api/show` (avec fallback)
- Support de plusieurs serveurs Ollama distants
- Sélection interactive des modèles avec option « Tous »
- Filtrage par motifs glob (include/exclude)
- Détection automatique du small_model
- Mode aperçu (dry-run)
- Suffixes de serveur pour les modèles dupliqués
- Fusion avec la configuration existante (merge)
- Prise en charge de la variable `OLLAMA_HOST`

## Exigences

| Component | Bash | PowerShell |
|-----------|:----:|:----------:|
| curl | required | not needed |
| Python 3 | required | not needed |
| PowerShell 5.1+ | n/a | required |

## Démarrage rapide

```bash
./generate_opencode_config.sh
.\Generate-OpenCodeConfig.ps1
```

## Utilisation

```bash
./generate_opencode_config.sh -r http://gpu:11434    # remote
./generate_opencode_config.sh -i                      # interactive
./generate_opencode_config.sh --include "qwen*"       # filter
./generate_opencode_config.sh -n                      # dry-run
./generate_opencode_config.sh --merge                 # merge
./generate_opencode_config.sh --default-model qwen2.5-coder:7b
./generate_opencode_config.sh -v                      # version
```

## Référence CLI

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

## Comment ça marche

1. **Récupération des modèles** de chaque serveur via `GET /api/tags`
2. **Filtrage** des modèles d'embedding par le champ `families`
3. **Filtrage** par motifs include/exclude (glob)
4. **Récupération des contextes** via `POST /api/show` (parallèle, avec cache)
5. **Déduplication** des modèles de plusieurs serveurs (suffixes `@host:port`)
6. **Sélection interactive** (si `-i`)
7. **Fusion** (si `--merge`) : préservation des paramètres existants
8. **Détection du small_model** : plus petit modèle non-embed
9. **Génération** de `opencode.json`

## Exemple de configuration

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

## Déduplication

Si le même modèle existe sur plusieurs serveurs, chaque copie reçoit un nom unique avec un suffixe :

```
qwen2.5-coder:7b             → local
qwen2.5-coder:7b@gpu-server  → remote
```

## Cache du contexte

Les longueurs de contexte sont mises en cache dans `~/.cache/opencode-generator/`. Le cache expire après 24 heures.

## Mode fusion

Utilisez `--merge` pour mettre à jour les modèles sans écraser les autres paramètres :

```bash
./generate_opencode_config.sh --merge -o opencode.json
```

## Installation de la configuration

```bash
cp opencode.json ~/.config/opencode/opencode.json
```

## Variables d'environnement

| Variable | Description |
|----------|-------------|
| `OLLAMA_HOST` | Default Ollama URL |
| `XDG_CACHE_HOME` | Cache directory |

## Dépannage

### Impossible de se connecter à Ollama

- Assurez-vous qu'Ollama est en cours d'exécution : `ollama serve`
- Vérifiez l'URL : `curl http://localhost:11434/api/tags`

### Dépendances manquantes

```bash
sudo apt install python3 curl   # Ubuntu/Debian
brew install python3 curl       # macOS
```

### Contexte incorrect

- Le script utilise `/api/show` par défaut
- Utilisez `--no-context-lookup` si l'API est lent
