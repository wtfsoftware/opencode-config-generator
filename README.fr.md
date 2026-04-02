# Générateur de configuration OpenCode pour Ollama

Génère la configuration `opencode.json` à partir des serveurs Ollama locaux et distants.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

English | [Русский](README.ru.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Español](README.es.md) | [中文](README.zh.md) | [日本語](README.ja.md) | [Português](README.pt.md) | [Italiano](README.it.md) | [한국어](README.ko.md) | [العربية](README.ar.md) | [Nederlands](README.nl.md) | [Українська](README.ua.md)

**v1.4.2** | [Specification](SPECIFICATION.md) | [Development](DEVELOPMENT.md) | [Disclaimer](DISCLAIMER.md)

## Fonctionnalités

- **Support multi-fournisseurs** : Ollama, LM Studio, vLLM, llama.cpp, LocalAI, text-generation-webui, Jan.ai, GPT4All
- Détection automatique du fournisseur par port, ou spécification avec `-p`
- Découverte automatique de tous les modèles via l'API du fournisseur
- Exclusion des modèles d'embedding (nomic-bert, champ type LM Studio, etc.)
- Filtrage des modèles par support d'appel d'outils/fonctions (`--tools-only`)
- Récupération des longueurs de contexte exactes (Ollama `/api/show`, llama.cpp `/props`, LM Studio métadonnées riches)
- Support de plusieurs serveurs de fournisseurs différents simultanément
- Sélection interactive de modèles (avec option « Tous les modèles »)
- Inclusion/exclusion de modèles par motifs glob
- Détection automatique de `small_model` (plus petit modèle non-embed pour la génération de titres)
- Mode dry-run (aperçu sans écriture)
- Respecte la variable d'environnement `OLLAMA_HOST`

## Exigences

| Composant | Script Bash | Script PowerShell |
|-----------|:-----------:|:-----------------:|
| curl      | requis      | non nécessaire    |
| Python 3  | requis      | non nécessaire    |
| PowerShell 5.1+ | n/a   | requis            |

## Démarrage rapide

```bash
# Bash (Linux/macOS/WSL/Git Bash)
./generate_opencode_config.sh

# PowerShell (Windows)
.\Generate-OpenCodeConfig.ps1
```

## Utilisation

### Bash

```bash
# Ollama local uniquement (utilise $OLLAMA_HOST ou http://localhost:11434)
./generate_opencode_config.sh

# Avec un serveur distant
./generate_opencode_config.sh -r http://192.168.1.100:11434

# Avec plusieurs serveurs distants
./generate_opencode_config.sh -r http://gpu1:11434 -r http://gpu2:11434

# Sélection interactive de modèles
./generate_opencode_config.sh -i

# Uniquement les modèles qwen
./generate_opencode_config.sh --include "qwen*"

# Exclure codestral
./generate_opencode_config.sh --exclude "codestral*"

# Inclure les modèles d'embedding
./generate_opencode_config.sh --with-embed

# Uniquement les modèles avec support d'appel d'outils/fonctions
./generate_opencode_config.sh --tools-only

# Aperçu sans écrire le fichier
./generate_opencode_config.sh -n

# Ajouter num_ctx aux options du fournisseur (pour l'appel d'outils)
./generate_opencode_config.sh --num-ctx 32768

# Définir le modèle par défaut explicitement
./generate_opencode_config.sh --default-model qwen2.5-coder:7b

# Fusionner dans une configuration existante (mettre à jour les modèles, conserver les autres paramètres)
./generate_opencode_config.sh --merge

# Ignorer les appels /api/show (plus rapide, utilise les limites de contexte codées en dur)
./generate_opencode_config.sh --no-context-lookup

# Désactiver le cache de recherche de contexte
./generate_opencode_config.sh --no-cache

# Écrire dans la configuration globale
./generate_opencode_config.sh -o ~/.config/opencode/opencode.json
```

### PowerShell

```powershell
# Ollama local uniquement
.\Generate-OpenCodeConfig.ps1

# Avec serveurs distants
.\Generate-OpenCodeConfig.ps1 -RemoteOllamaUrl "http://192.168.1.100:11434"
.\Generate-OpenCodeConfig.ps1 -RemoteOllamaUrl "http://gpu1:11434","http://gpu2:11434"

# Sélection interactive
.\Generate-OpenCodeConfig.ps1 -Interactive

# Uniquement les modèles qwen
.\Generate-OpenCodeConfig.ps1 -Include "qwen*"

# Dry-run
.\Generate-OpenCodeConfig.ps1 -DryRun

# Avec num_ctx
.\Generate-OpenCodeConfig.ps1 -NumCtx 32768

# Écrire dans la configuration globale
.\Generate-OpenCodeConfig.ps1 -OutputFile "$env:USERPROFILE\.config\opencode\opencode.json"
```

## Référence CLI

### Bash

| Flag | Description | Défaut |
|------|-------------|--------|
| `-l, --local URL` | URL du serveur local | `$OLLAMA_HOST` ou `http://localhost:11434` |
| `-r, --remote URL` | URL du serveur distant (répétable) | aucun |
| `-p, --provider NOM` | Fournisseur : ollama, lmstudio, vllm, llama-cpp, localai, tgwui, jan, gpt4all | détection auto |
| `-o, --output FICHIER` | Chemin du fichier de sortie (`-` pour stdout) | `opencode.json` |
| `-n, --dry-run` | Afficher sur stdout, ne pas écrire | désactivé |
| `-i, --interactive` | Sélection interactive de modèles | désactivé |
| `--include MOTIF` | Inclure les modèles correspondant au glob (répétable) | tous |
| `--exclude MOTIF` | Exclure les modèles correspondant au glob (répétable) | aucun |
| `--with-embed` | Inclure les modèles d'embedding | exclus |
| `--tools-only` | Uniquement les modèles avec support d'appel d'outils/fonctions | désactivé |
| `--no-context-lookup` | Ignorer `/api/show`, utiliser les limites codées en dur | désactivé |
| `--num-ctx N` | `num_ctx` pour les options du fournisseur, 0 pour omettre | `0` |
| `--merge` | Fusionner dans une configuration existante (mettre à jour les modèles uniquement) | désactivé |
| `--default-model ID` | Définir le modèle par défaut explicitement | auto |
| `--small-model ID` | Définir le small_model explicitement (pour la génération de titres) | auto |
| `--no-cache` | Désactiver le cache de recherche de contexte | désactivé |
| `-v, --version` | Afficher la version | |
| `-h, --help` | Afficher l'aide | |

### PowerShell

| Paramètre | Description | Défaut |
|-----------|-------------|--------|
| `-LocalOllamaUrl` | URL Ollama local | `$OLLAMA_HOST` ou `http://localhost:11434` |
| `-RemoteOllamaUrl` | URL(s) distante(s) (tableau) | aucune |
| `-OutputFile` | Chemin du fichier de sortie | `opencode.json` |
| `-DryRun` | Afficher sur stdout, ne pas écrire | désactivé |
| `-Interactive` | Sélection interactive de modèles | désactivé |
| `-Include` | Motifs d'inclusion (wildcard, tableau) | tous |
| `-Exclude` | Motifs d'exclusion (wildcard, tableau) | aucun |
| `-WithEmbed` | Inclure les modèles d'embedding | exclus |
| `-ToolsOnly` | Uniquement les modèles avec support d'appel d'outils/fonctions | désactivé |
| `-NoContextLookup` | Ignorer `/api/show`, utiliser les limites codées en dur | désactivé |
| `-NumCtx` | `num_ctx` pour les options du fournisseur, 0 pour omettre | `0` |
| `-Merge` | Fusionner dans une configuration existante (mettre à jour les modèles uniquement) | désactivé |
| `-DefaultModel` | Définir le modèle par défaut explicitement | auto |
| `-SmallModel` | Définir le small_model explicitement (pour la génération de titres) | auto |
| `-NoCache` | Désactiver le cache de recherche de contexte | désactivé |
| `-Version` | Afficher la version | |
| `-Help` | Afficher l'aide | |

## Comment ça marche

1. **Récupération des modèles** de chaque serveur Ollama via `GET /api/tags`
2. **Filtrage** des modèles d'embedding par le champ `families` (`nomic-bert`, `bert`, etc.)
3. **Filtrage** par motifs include/exclude (correspondance glob)
4. **Récupération des longueurs de contexte** pour chaque modèle via `POST /api/show` (parallèle, avec cache)
5. **Déduplication** des modèles trouvés sur plusieurs serveurs (conserve la version du premier serveur)
6. **Sélection interactive** (si `-i`) : liste numérotée avec option `[0] Tous les modèles`
7. **Fusion** (si `--merge`) : préserve les paramètres de configuration existants et les autres fournisseurs
8. **Détection automatique de `small_model`** : plus petit modèle non-embed par nombre de paramètres
9. **Génération** de `opencode.json` avec Ollama comme fournisseur

## Structure de configuration générée

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

### Champs

| Champ | Description |
|-------|-------------|
| `provider.ollama.options.baseURL` | Point de terminaison compatible OpenAI d'Ollama |
| `provider.ollama.models.*.limit.context` | Fenêtre de contexte maximale pour le modèle |
| `provider.ollama.models.*.limit.output` | Tokens de sortie maximaux (plafonnés à 16K) |
| `model` | Modèle par défaut (premier disponible) |
| `small_model` | Plus petit modèle pour les tâches légères (génération de titres) |

## Détection du contexte des modèles

Les longueurs de contexte sont déterminées dans cet ordre de priorité :

1. **Recherche API** — `POST /api/show` retourne `model_info.*.context_length` (valeur exacte)
2. **Fallback codé en dur** — estimé par famille de modèles :

| Famille | Contexte par défaut |
|---------|:-------------------:|
| qwen, qwen2 | 32 768 |
| llama | 8 192 |
| mistral, mixtral | 32 768 |
| deepseek | 65 536 |
| command, command-r | 131 072 |
| yi | 200 000 |
| gemma | 8 192 |
| phi | 4 096 |
| codestral | 32 768 |
| granite | 8 192 |
| autre | 8 192 |

Utilisez `--no-context-lookup` pour ignorer les appels API et utiliser uniquement les valeurs codées en dur (plus rapide).

## Modèles d'embedding

Les modèles d'embedding sont **exclus par défaut** car ils ne supportent pas l'appel chat/outils. La détection est basée sur :

- Les familles de modèles contenant `nomic-bert`, `bert`, `bert-moe`, `embed`, `embedding`
- Les noms de modèles contenant ces mots-clés

Utilisez `--with-embed` / `-WithEmbed` pour les inclure.

## Filtre d'appel d'outils/fonctions

Utilisez `--tools-only` / `-ToolsOnly` pour inclure uniquement les modèles qui supportent l'appel d'outils/fonctions :

```bash
./generate_opencode_config.sh --tools-only
```

La détection fonctionne en deux niveaux :
1. **Exact** — LM Studio fournit `capabilities.tool_use` via son endpoint riche `/api/v1/models`
2. **Heuristique** — pour tous les autres fournisseurs, les modèles sont comparés à une liste autorisée connue de familles capables d'outils (qwen2.5/3, llama3.x, mistral, mixtral, deepseek-r1/v3, command-r, phi3/4, gemma2/3, granite3.x)

Les modèles ne correspondant à aucune de ces vérifications sont exclus lorsque `--tools-only` est actif. La liste autorisée peut nécessiter des mises à jour à mesure que de nouvelles familles de modèles sont publiées.

## Support multi-fournisseurs

Fonctionne avec 8 fournisseurs d'inférence locale. Le fournisseur est détecté automatiquement par port, ou spécifiez avec `-p`.

| Fournisseur | Port par défaut | Métadonnées riches | Détection auto |
|-------------|:---------------:|:-----------------:|:-------------:|
| **Ollama** | 11434 | `/api/show` (contexte, familles) | ✅ |
| **LM Studio** | 1234 | `/api/v1/models` (type, capacités, contexte) | ✅ |
| **vLLM** | 8000 | basique uniquement | ✅ |
| **llama.cpp** | 8080 | `/props` (context_size) | ✅ (en tant que localai) |
| **LocalAI** | 8080 | basique uniquement | ✅ |
| **text-generation-webui** | 5000 | basique uniquement | ✅ |
| **Jan.ai** | 1337 | basique uniquement | ✅ |
| **GPT4All** | 4891 | basique uniquement | ✅ |

```bash
# Détection automatique par port
./generate_opencode_config.sh -l http://localhost:1234       # LM Studio
./generate_opencode_config.sh -l http://localhost:8000       # vLLM

# Fournisseur explicite
./generate_opencode_config.sh -l http://localhost:8080 -p llama-cpp

# Ollama + LM Studio ensemble
./generate_opencode_config.sh -l http://localhost:11434 -r http://localhost:1234 -p lmstudio
```

Chaque fournisseur apparaît comme un bloc séparé dans `opencode.json` :

```json
{
  "provider": {
    "ollama": { "name": "Ollama", "options": { "baseURL": "http://localhost:11434/v1" }, ... },
    "lmstudio": { "name": "LM Studio", "options": { "baseURL": "http://localhost:1234/v1" }, ... }
  }
}
```

## Cache de recherche de contexte

Les longueurs de contexte de `/api/show` sont mises en cache dans `~/.cache/opencode-generator/` par hash d'URL. Le cache expire après 24 heures. Les exécutions suivantes réutilisent les valeurs mises en cache et ne récupèrent que les nouveaux modèles. Utilisez `--no-cache` pour désactiver.

## Mode fusion

Utilisez `--merge` pour mettre à jour les modèles dans un `opencode.json` existant sans écraser les autres paramètres (fournisseurs personnalisés, thèmes, règles, etc.) :

```bash
# Génération initiale
./generate_opencode_config.sh -o opencode.json

# Ajout manuel de fournisseurs personnalisés, règles, etc. dans opencode.json

# Plus tard : mise à jour des modèles uniquement, conservation de tout le reste
./generate_opencode_config.sh --merge -o opencode.json
```

## Déduplication

Si le même modèle existe sur plusieurs serveurs, chaque copie reçoit un nom unique avec un suffixe de serveur :

```
qwen2.5-coder:7b                → serveur local (nom original)
qwen2.5-coder:7b@gpu-server     → premier serveur distant
qwen2.5-coder:7b@gpu-server-2   → second serveur distant avec même nom d'hôte
```

Les deux versions apparaissent dans `/models`. Le résumé montre quels modèles ont reçu un suffixe.

## Variables d'environnement

| Variable | Description |
|----------|-------------|
| `OLLAMA_HOST` | URL Ollama local par défaut (variable standard Ollama) |
| `XDG_CACHE_HOME` | Chemin de base du répertoire de cache |

## Installation de la configuration générée

```bash
# Configuration globale (tous les projets)
cp opencode.json ~/.config/opencode/opencode.json

# Spécifique au projet
cp opencode.json /chemin/du/projet/opencode.json
```

## Dépannage

### « Impossible de se connecter à Ollama »

- Assurez-vous qu'Ollama est en cours d'exécution : `ollama serve`
- Vérifiez l'URL : `curl http://localhost:11434/api/tags`
- Si vous utilisez un port/hôte personnalisé, définissez `OLLAMA_HOST` ou utilisez `-l`

### « Dépendances requises manquantes : python3 »

```bash
# Ubuntu/Debian
sudo apt install python3

# macOS
brew install python3

# Windows : télécharger depuis https://python.org
```

### Longueur de contexte incorrecte

- Le script utilise `/api/show` par défaut pour les valeurs exactes
- Si l'API est lente, utilisez `--no-context-lookup` pour les estimations codées en dur
- Remplacez manuellement dans le JSON généré si nécessaire

### Modèles d'embedding inclus/exclus de manière inattendue

- Vérifiez les familles dans la sortie de `ollama show <model>`
- Utilisez `--with-embed` pour forcer l'inclusion
- Utilisez `--exclude "*embed*"` pour forcer l'exclusion par nom

### « Le fournisseur a retourné une erreur » dans OpenCode

- Certains modèles Ollama ne supportent pas l'appel d'outils — essayez `qwen2.5-coder` ou `llama3.2`
- Augmentez `num_ctx` si les outils échouent : `--num-ctx 32768`
- Assurez-vous que le modèle est chargé : `ollama run <model>`
