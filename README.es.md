# Generador de configuración OpenCode para Ollama

Genera la configuración `opencode.json` a partir de servidores Ollama locales y remotos.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

English | [Русский](README.ru.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Español](README.es.md) | [中文](README.zh.md) | [日本語](README.ja.md) | [Português](README.pt.md) | [Italiano](README.it.md) | [한국어](README.ko.md) | [العربية](README.ar.md) | [Nederlands](README.nl.md) | [Українська](README.ua.md)

**v1.4.3** | [Specification](SPECIFICATION.md) | [Development](DEVELOPMENT.md) | [Disclaimer](DISCLAIMER.md)

## Características

- **Soporte multi-proveedor**: Ollama, LM Studio, vLLM, llama.cpp, LocalAI, text-generation-webui, Jan.ai, GPT4All
- Detecta automáticamente el proveedor por puerto, o especifícalo con `-p`
- Descubre todos los modelos automáticamente a través de la API del proveedor
- Filtra modelos de embedding (nomic-bert, campo type de LM Studio, etc.)
- Filtra modelos por soporte de llamada a herramientas/funciones (`--tools-only`)
- Obtiene longitudes de contexto exactas (Ollama `/api/show`, llama.cpp `/props`, LM Studio metadatos enriquecidos)
- Soporta múltiples servidores de diferentes proveedores simultáneamente
- Selección interactiva de modelos (con opción "Todos los modelos")
- Incluir/excluir modelos por patrones glob
- Detecta automáticamente `small_model` (modelo no-embed más pequeño para generación de títulos)
- Modo dry-run (vista previa sin escribir)
- Respeta la variable de entorno `OLLAMA_HOST`

## Requisitos

| Componente | Script Bash | Script PowerShell |
|------------|:-----------:|:-----------------:|
| curl       | requerido   | no necesario      |
| Python 3   | requerido   | no necesario      |
| PowerShell 5.1+ | n/a    | requerido         |

## Inicio rápido

```bash
# Bash (Linux/macOS/WSL/Git Bash)
./generate_opencode_config.sh

# PowerShell (Windows)
.\Generate-OpenCodeConfig.ps1
```

## Uso

### Bash

```bash
# Solo Ollama local (usa $OLLAMA_HOST o http://localhost:11434)
./generate_opencode_config.sh

# Con un servidor remoto
./generate_opencode_config.sh -r http://192.168.1.100:11434

# Con múltiples servidores remotos
./generate_opencode_config.sh -r http://gpu1:11434 -r http://gpu2:11434

# Selección interactiva de modelos
./generate_opencode_config.sh -i

# Solo modelos qwen
./generate_opencode_config.sh --include "qwen*"

# Excluir codestral
./generate_opencode_config.sh --exclude "codestral*"

# Incluir modelos de embedding
./generate_opencode_config.sh --with-embed

# Solo modelos con soporte de llamada a herramientas/funciones
./generate_opencode_config.sh --tools-only

# Vista previa sin escribir archivo
./generate_opencode_config.sh -n

# Añadir num_ctx a las opciones del proveedor (para llamada a herramientas)
./generate_opencode_config.sh --num-ctx 32768

# Establecer modelo predeterminado explícitamente
./generate_opencode_config.sh --default-model qwen2.5-coder:7b

# Fusionar en configuración existente (actualizar modelos, mantener otros ajustes)
./generate_opencode_config.sh --merge

# Omitir llamadas a /api/show (más rápido, usa límites de contexto codificados)
./generate_opencode_config.sh --no-context-lookup

# Desactivar caché de búsqueda de contexto
./generate_opencode_config.sh --no-cache

# Escribir en configuración global
./generate_opencode_config.sh -o ~/.config/opencode/opencode.json
```

### PowerShell

```powershell
# Solo Ollama local
.\Generate-OpenCodeConfig.ps1

# Con servidores remotos
.\Generate-OpenCodeConfig.ps1 -RemoteOllamaUrl "http://192.168.1.100:11434"
.\Generate-OpenCodeConfig.ps1 -RemoteOllamaUrl "http://gpu1:11434","http://gpu2:11434"

# Selección interactiva
.\Generate-OpenCodeConfig.ps1 -Interactive

# Solo modelos qwen
.\Generate-OpenCodeConfig.ps1 -Include "qwen*"

# Dry-run
.\Generate-OpenCodeConfig.ps1 -DryRun

# Con num_ctx
.\Generate-OpenCodeConfig.ps1 -NumCtx 32768

# Escribir en configuración global
.\Generate-OpenCodeConfig.ps1 -OutputFile "$env:USERPROFILE\.config\opencode\opencode.json"
```

## Referencia CLI

### Bash

| Flag | Descripción | Predeterminado |
|------|-------------|----------------|
| `-l, --local URL` | URL del servidor local | `$OLLAMA_HOST` o `http://localhost:11434` |
| `-r, --remote URL` | URL del servidor remoto (repetible) | ninguno |
| `-p, --provider NOMBRE` | Proveedor: ollama, lmstudio, vllm, llama-cpp, localai, tgwui, jan, gpt4all | auto-detectar |
| `-o, --output ARCHIVO` | Ruta del archivo de salida (`-` para stdout) | `opencode.json` |
| `-n, --dry-run` | Imprimir en stdout, no escribir | desactivado |
| `-i, --interactive` | Selección interactiva de modelos | desactivado |
| `--include PATRÓN` | Incluir modelos que coincidan con glob (repetible) | todos |
| `--exclude PATRÓN` | Excluir modelos que coincidan con glob (repetible) | ninguno |
| `--with-embed` | Incluir modelos de embedding | excluidos |
| `--tools-only` | Solo modelos con soporte de llamada a herramientas/funciones | desactivado |
| `--no-context-lookup` | Omitir `/api/show`, usar límites codificados | desactivado |
| `--num-ctx N` | `num_ctx` para opciones del proveedor, 0 para omitir | `0` |
| `--merge` | Fusionar en configuración existente (solo actualizar modelos) | desactivado |
| `--default-model ID` | Establecer modelo predeterminado explícitamente | auto |
| `--small-model ID` | Establecer small_model explícitamente (para generación de títulos) | auto |
| `--no-cache` | Desactivar caché de búsqueda de contexto | desactivado |
| `-v, --version` | Mostrar versión | |
| `-h, --help` | Mostrar ayuda | |

### PowerShell

| Parámetro | Descripción | Predeterminado |
|-----------|-------------|----------------|
| `-LocalOllamaUrl` | URL de Ollama local | `$OLLAMA_HOST` o `http://localhost:11434` |
| `-RemoteOllamaUrl` | URL(s) remota(s) (array) | ninguna |
| `-OutputFile` | Ruta del archivo de salida | `opencode.json` |
| `-DryRun` | Imprimir en stdout, no escribir | desactivado |
| `-Interactive` | Selección interactiva de modelos | desactivado |
| `-Include` | Patrones de inclusión (wildcard, array) | todos |
| `-Exclude` | Patrones de exclusión (wildcard, array) | ninguno |
| `-WithEmbed` | Incluir modelos de embedding | excluidos |
| `-ToolsOnly` | Solo modelos con soporte de llamada a herramientas/funciones | desactivado |
| `-NoContextLookup` | Omitir `/api/show`, usar límites codificados | desactivado |
| `-NumCtx` | `num_ctx` para opciones del proveedor, 0 para omitir | `0` |
| `-Merge` | Fusionar en configuración existente (solo actualizar modelos) | desactivado |
| `-DefaultModel` | Establecer modelo predeterminado explícitamente | auto |
| `-SmallModel` | Establecer small_model explícitamente (para generación de títulos) | auto |
| `-NoCache` | Desactivar caché de búsqueda de contexto | desactivado |
| `-Version` | Mostrar versión | |
| `-Help` | Mostrar ayuda | |

## Cómo funciona

1. **Obtener modelos** de cada servidor Ollama mediante `GET /api/tags`
2. **Filtrar** modelos de embedding por el campo `families` (`nomic-bert`, `bert`, etc.)
3. **Filtrar** por patrones include/exclude (coincidencia glob)
4. **Obtener longitudes de contexto** para cada modelo mediante `POST /api/show` (paralelo, con caché)
5. **Desduplicar** modelos encontrados en múltiples servidores (mantiene la versión del primer servidor)
6. **Selección interactiva** (si `-i`): lista numerada con opción `[0] Todos los modelos`
7. **Fusionar** (si `--merge`): preservar configuración existente y otros proveedores
8. **Detectar automáticamente `small_model`**: modelo no-embed más pequeño por conteo de parámetros
9. **Generar** `opencode.json` con Ollama como proveedor

## Estructura de configuración generada

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

### Campos

| Campo | Descripción |
|-------|-------------|
| `provider.ollama.options.baseURL` | Endpoint compatible con OpenAI de Ollama |
| `provider.ollama.models.*.limit.context` | Ventana de contexto máxima para el modelo |
| `provider.ollama.models.*.limit.output` | Tokens de salida máximos (limitados a 16K) |
| `model` | Modelo predeterminado (primero disponible) |
| `small_model` | Modelo más pequeño para tareas ligeras (generación de títulos) |

## Detección de contexto de modelos

Las longitudes de contexto se determinan en este orden de prioridad:

1. **Búsqueda API** — `POST /api/show` devuelve `model_info.*.context_length` (valor exacto)
2. **Fallback codificado** — estimado por familia de modelo:

| Familia | Contexto predeterminado |
|---------|:-----------------------:|
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
| otro | 8.192 |

Use `--no-context-lookup` para omitir llamadas API y usar solo valores codificados (más rápido).

## Modelos de embedding

Los modelos de embedding están **excluidos por defecto** porque no soportan llamada a chat/herramientas. La detección se basa en:

- Familias de modelos que contienen `nomic-bert`, `bert`, `bert-moe`, `embed`, `embedding`
- Nombres de modelos que contienen estas palabras clave

Use `--with-embed` / `-WithEmbed` para incluirlos.

## Filtro de llamada a herramientas/funciones

Use `--tools-only` / `-ToolsOnly` para incluir solo modelos que soportan llamada a herramientas/funciones:

```bash
./generate_opencode_config.sh --tools-only
```

La detección funciona en dos niveles:
1. **Exacto** — LM Studio proporciona `capabilities.tool_use` a través de su endpoint enriquecido `/api/v1/models`
2. **Heurístico** — para todos los demás proveedores, los modelos se comparan con una lista autorizada conocida de familias con capacidad de herramientas (qwen2.5/3, llama3.x, mistral, mixtral, deepseek-r1/v3, command-r, phi3/4, gemma2/3, granite3.x)

Los modelos que no coincidan con ninguna verificación se excluyen cuando `--tools-only` está activo. La lista autorizada puede necesitar actualizaciones a medida que se lancen nuevas familias de modelos.

## Soporte multi-proveedor

Funciona con 8 proveedores de inferencia local. El proveedor se detecta automáticamente por puerto, o especifícalo con `-p`.

| Proveedor | Puerto predeterminado | Metadatos enriquecidos | Auto-detección |
|-----------|:---------------------:|:----------------------:|:--------------:|
| **Ollama** | 11434 | `/api/show` (contexto, familias) | ✅ |
| **LM Studio** | 1234 | `/api/v1/models` (tipo, capacidades, contexto) | ✅ |
| **vLLM** | 8000 | solo básico | ✅ |
| **llama.cpp** | 8080 | `/props` (context_size) | ✅ (como localai) |
| **LocalAI** | 8080 | solo básico | ✅ |
| **text-generation-webui** | 5000 | solo básico | ✅ |
| **Jan.ai** | 1337 | solo básico | ✅ |
| **GPT4All** | 4891 | solo básico | ✅ |

```bash
# Auto-detección por puerto
./generate_opencode_config.sh -l http://localhost:1234       # LM Studio
./generate_opencode_config.sh -l http://localhost:8000       # vLLM

# Proveedor explícito
./generate_opencode_config.sh -l http://localhost:8080 -p llama-cpp

# Ollama + LM Studio juntos
./generate_opencode_config.sh -l http://localhost:11434 -r http://localhost:1234 -p lmstudio
```

Cada proveedor aparece como un bloque separado en `opencode.json`:

```json
{
  "provider": {
    "ollama": { "name": "Ollama", "options": { "baseURL": "http://localhost:11434/v1" }, ... },
    "lmstudio": { "name": "LM Studio", "options": { "baseURL": "http://localhost:1234/v1" }, ... }
  }
}
```

## Caché de búsqueda de contexto

Las longitudes de contexto de `/api/show` se almacenan en caché en `~/.cache/opencode-generator/` por hash de URL. La caché expira después de 24 horas. Las ejecuciones posteriores reutilizan valores almacenados y solo obtienen nuevos modelos. Use `--no-cache` para desactivar.

## Modo fusión

Use `--merge` para actualizar modelos en un `opencode.json` existente sin sobrescribir otros ajustes (proveedores personalizados, temas, reglas, etc.):

```bash
# Generación inicial
./generate_opencode_config.sh -o opencode.json

# Añadir manualmente proveedores personalizados, reglas, etc. a opencode.json

# Más tarde: actualizar solo modelos, mantener todo lo demás
./generate_opencode_config.sh --merge -o opencode.json
```

## Desduplicación

Si el mismo modelo existe en múltiples servidores, cada copia recibe un nombre único con sufijo de servidor:

```
qwen2.5-coder:7b                → servidor local (nombre original)
qwen2.5-coder:7b@gpu-server     → primer servidor remoto
qwen2.5-coder:7b@gpu-server-2   → segundo servidor remoto con mismo hostname
```

Ambas versiones aparecen en `/models`. El resumen muestra qué modelos recibieron sufijo.

## Variables de entorno

| Variable | Descripción |
|----------|-------------|
| `OLLAMA_HOST` | URL de Ollama local predeterminada (variable estándar de Ollama) |
| `XDG_CACHE_HOME` | Ruta base del directorio de caché |

## Instalación de la configuración generada

```bash
# Configuración global (todos los proyectos)
cp opencode.json ~/.config/opencode/opencode.json

# Específico del proyecto
cp opencode.json /ruta/del/proyecto/opencode.json
```

## Solución de problemas

### "No se pudo conectar a Ollama"

- Asegúrese de que Ollama esté en ejecución: `ollama serve`
- Verifique la URL: `curl http://localhost:11434/api/tags`
- Si usa un puerto/host personalizado, establezca `OLLAMA_HOST` o use `-l`

### "Faltan dependencias requeridas: python3"

```bash
# Ubuntu/Debian
sudo apt install python3

# macOS
brew install python3

# Windows: descargar desde https://python.org
```

### Longitud de contexto incorrecta

- El script usa `/api/show` por defecto para valores exactos
- Si la API es lenta, use `--no-context-lookup` para estimaciones codificadas
- Sobrescriba manualmente en el JSON generado si es necesario

### Modelos de embedding incluidos/excluidos inesperadamente

- Verifique familias en la salida de `ollama show <model>`
- Use `--with-embed` para forzar inclusión
- Use `--exclude "*embed*"` para forzar exclusión por nombre

### "El proveedor devolvió un error" en OpenCode

- Algunos modelos de Ollama no soportan llamada a herramientas — pruebe `qwen2.5-coder` o `llama3.2`
- Aumente `num_ctx` si las herramientas fallan: `--num-ctx 32768`
- Asegúrese de que el modelo esté cargado: `ollama run <model>`
