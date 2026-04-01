# Gerador de Configuração OpenCode para Ollama

Gera `opencode.json` para [OpenCode](https://opencode.ai) a partir dos modelos dos servidores Ollama locais e remotos.

[English](README.md) | [Русский](README.ru.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Español](README.es.md) | [中文](README.zh.md) | [日本語](README.ja.md) | [Português](README.pt.md) | [Italiano](README.it.md) | [한국어](README.ko.md) | [العربية](README.ar.md) | [Nederlands](README.nl.md) | [Українська](README.ua.md)

**v1.1.0** | [Specification](SPECIFICATION.md) | [Development](DEVELOPMENT.md) | [Disclaimer](DISCLAIMER.md)

---

## Funcionalidades

- Descoberta automática de modelos via API Ollama
- Filtragem de modelos de embedding (nomic-bert, etc.)
- Comprimentos de contexto exatos via `/api/show` (com fallback)
- Suporte a múltiplos servidores Ollama remotos
- Seleção interativa de modelos com opção "Todos"
- Filtragem por padrões glob (include/exclude)
- Detecção automática de small_model
- Modo de pré-visualização (dry-run)
- Sufixos de servidor para modelos duplicados
- Mesclagem com configuração existente (merge)
- Suporte à variável de ambiente `OLLAMA_HOST`

## Requisitos

| Component | Bash | PowerShell |
|-----------|:----:|:----------:|
| curl | required | not needed |
| Python 3 | required | not needed |
| PowerShell 5.1+ | n/a | required |

## Início rápido

```bash
./generate_opencode_config.sh
.\Generate-OpenCodeConfig.ps1
```

## Uso

```bash
./generate_opencode_config.sh -r http://gpu:11434    # remote
./generate_opencode_config.sh -i                      # interactive
./generate_opencode_config.sh --include "qwen*"       # filter
./generate_opencode_config.sh -n                      # dry-run
./generate_opencode_config.sh --merge                 # merge
./generate_opencode_config.sh --default-model qwen2.5-coder:7b
./generate_opencode_config.sh -v                      # version
```

## Referência CLI

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

## Como funciona

1. **Obter modelos** de cada servidor via `GET /api/tags`
2. **Filtrar** modelos de embedding pelo campo `families`
3. **Filtrar** por padrões include/exclude (glob)
4. **Obter contextos** via `POST /api/show` (paralelo, com cache)
5. **Desduplicar** modelos de múltiplos servidores (sufixos `@host:port`)
6. **Seleção interativa** (com `-i`)
7. **Mesclagem** (com `--merge`): preservar configuração existente
8. **Detectar small_model**: menor modelo não-embed
9. **Gerar** `opencode.json`

## Exemplo de configuração

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

## Desduplicação

Se o mesmo modelo existir em vários servidores, cada cópia recebe um nome único com sufixo do servidor:

```
qwen2.5-coder:7b             → local
qwen2.5-coder:7b@gpu-server  → remote
```

## Cache de contexto

Os comprimentos de contexto são armazenados em cache em `~/.cache/opencode-generator/`. O cache expira após 24 horas.

## Modo de mesclagem

Use `--merge` para atualizar modelos sem sobrescrever outras configurações:

```bash
./generate_opencode_config.sh --merge -o opencode.json
```

## Instalar a configuração

```bash
cp opencode.json ~/.config/opencode/opencode.json
```

## Variáveis de ambiente

| Variable | Description |
|----------|-------------|
| `OLLAMA_HOST` | Default Ollama URL |
| `XDG_CACHE_HOME` | Cache directory |

## Solução de problemas

### Não é possível conectar ao Ollama

- Certifique-se de que o Ollama está em execução: `ollama serve`
- Verifique a URL: `curl http://localhost:11434/api/tags`

### Dependências ausentes

```bash
sudo apt install python3 curl   # Ubuntu/Debian
brew install python3 curl       # macOS
```

### Contexto incorreto

- O script usa `/api/show` por padrão
- Use `--no-context-lookup` se a API estiver lenta
