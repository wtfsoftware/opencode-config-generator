# Generador de configuración OpenCode para Ollama

Genera `opencode.json` para [OpenCode](https://opencode.ai) a partir de los modelos de servidores Ollama locales y remotos.

[English](README.md) | [Русский](README.ru.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Español](README.es.md) | [中文](README.zh.md) | [日本語](README.ja.md) | [Português](README.pt.md) | [Italiano](README.it.md) | [한국어](README.ko.md) | [العربية](README.ar.md) | [Nederlands](README.nl.md) | [Українська](README.ua.md)

**v1.1.0** | [Specification](SPECIFICATION.md) | [Development](DEVELOPMENT.md) | [Disclaimer](DISCLAIMER.md)

---

## Características

- **Multi-provider**: Ollama, LM Studio, vLLM, llama.cpp, LocalAI, text-generation-webui, Jan.ai, GPT4All
- Descubrimiento automático de modelos vía API de Ollama
- Filtrado de modelos de embedding (nomic-bert, etc.)
- Longitudes de contexto exactas vía `/api/show` (con fallback)
- Soporte para múltiples servidores Ollama remotos
- Selección interactiva de modelos con opción "Todos"
- Filtrado por patrones glob (include/exclude)
- Detección automática de small_model
- Modo de vista previa (dry-run)
- Sufijos de servidor para modelos duplicados
- Fusión con la configuración existente (merge)
- Soporte para la variable de entorno `OLLAMA_HOST`

## Requisitos

| Component | Bash | PowerShell |
|-----------|:----:|:----------:|
| curl | required | not needed |
| Python 3 | required | not needed |
| PowerShell 5.1+ | n/a | required |

## Inicio rápido

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

## Referencia CLI

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

## Cómo funciona

1. **Obtener modelos** de cada servidor vía `GET /api/tags`
2. **Filtrar** modelos de embedding por el campo `families`
3. **Filtrar** por patrones include/exclude (glob)
4. **Obtener contextos** vía `POST /api/show` (paralelo, con caché)
5. **Desduplicar** modelos de múltiples servidores (sufijos `@host:port`)
6. **Selección interactiva** (con `-i`)
7. **Fusión** (con `--merge`): conservar configuración existente
8. **Detectar small_model**: modelo más pequeño no-embed
9. **Generar** `opencode.json`

## Ejemplo de configuración

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

## Desduplicación

Si el mismo modelo existe en varios servidores, cada copia recibe un nombre único con sufijo de servidor:

```
qwen2.5-coder:7b             → local
qwen2.5-coder:7b@gpu-server  → remote
```

## Caché de contexto

Las longitudes de contexto se almacenan en caché en `~/.cache/opencode-generator/`. La caché expira después de 24 horas.

## Modo de fusión

Use `--merge` para actualizar modelos sin sobrescribir otros ajustes:

```bash
./generate_opencode_config.sh --merge -o opencode.json
```

## Instalar la configuración

```bash
cp opencode.json ~/.config/opencode/opencode.json
```

## Variables de entorno

| Variable | Description |
|----------|-------------|
| `OLLAMA_HOST` | Default Ollama URL |
| `XDG_CACHE_HOME` | Cache directory |

## Solución de problemas

### No se puede conectar a Ollama

- Asegúrese de que Ollama esté en ejecución: `ollama serve`
- Verifique la URL: `curl http://localhost:11434/api/tags`

### Dependencias faltantes

```bash
sudo apt install python3 curl   # Ubuntu/Debian
brew install python3 curl       # macOS
```

### Contexto incorrecto

- El script usa `/api/show` por defecto
- Use `--no-context-lookup` si la API es lenta
