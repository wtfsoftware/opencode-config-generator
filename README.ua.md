# Генератор конфігурації OpenCode для Ollama

Генерує `opencode.json` для [OpenCode](https://opencode.ai) на основі моделей з локальних та віддалених серверів Ollama.

[English](README.md) | [Русский](README.ru.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Español](README.es.md) | [中文](README.zh.md) | [日本語](README.ja.md) | [Português](README.pt.md) | [Italiano](README.it.md) | [한국어](README.ko.md) | [العربية](README.ar.md) | [Nederlands](README.nl.md) | [Українська](README.ua.md)

**v1.1.0** | [Specification](SPECIFICATION.md) | [Development](DEVELOPMENT.md) | [Disclaimer](DISCLAIMER.md)

---

## Можливості

- **Multi-provider**: Ollama, LM Studio, vLLM, llama.cpp, LocalAI, text-generation-webui, Jan.ai, GPT4All
- Автоматичне виявлення моделей через API Ollama
- Фільтрація embedding-моделей (nomic-bert тощо)
- Точні контекстні вікна через `/api/show` (з фолбеком)
- Підтримка кількох віддалених серверів Ollama
- Інтерактивний вибір моделей з опцією «Все»
- Фільтрація за glob-патернами (include/exclude)
- Автовизначення small_model
- Режим попереднього перегляду (dry-run)
- Суфікси серверів при дублюванні моделей
- Злиття з існуючою конфігурацією (merge)
- Підтримка змінної середовища `OLLAMA_HOST`

## Вимоги

| Component | Bash | PowerShell |
|-----------|:----:|:----------:|
| curl | required | not needed |
| Python 3 | required | not needed |
| PowerShell 5.1+ | n/a | required |

## Швидкий старт

```bash
./generate_opencode_config.sh
.\Generate-OpenCodeConfig.ps1
```

## Використання

```bash
./generate_opencode_config.sh -r http://gpu:11434    # remote
./generate_opencode_config.sh -i                      # interactive
./generate_opencode_config.sh --include "qwen*"       # filter
./generate_opencode_config.sh -n                      # dry-run
./generate_opencode_config.sh --merge                 # merge
./generate_opencode_config.sh --default-model qwen2.5-coder:7b
./generate_opencode_config.sh -v                      # version
```

## Довідка по CLI

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

## Як це працює

1. **Отримання моделей** з кожного сервера через `GET /api/tags`
2. **Фільтрація** embedding-моделей за полем `families`
3. **Фільтрація** за include/exclude патернами
4. **Отримання контексту** через `POST /api/show` (паралельно, з кешем)
5. **Дедуплікація** моделей з кількох серверів (суфікси `@host:port`)
6. **Інтерактивний вибір** (якщо `-i`)
7. **Злиття** (якщо `--merge`): збереження налаштувань
8. **Автовизначення small_model**: найменша не-embed модель
9. **Генерація** `opencode.json`

## Приклад конфігурації

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

## Дедуплікація

Якщо одна й та сама модель існує на кількох серверах, кожна копія отримує унікальне ім'я з суфіксом сервера:

```
qwen2.5-coder:7b             → local
qwen2.5-coder:7b@gpu-server  → remote
```

## Кеш контексту

Контекстні вікна кешуються в `~/.cache/opencode-generator/`. Кеш спливає через 24 години.

## Режим злиття

Використовуйте `--merge` для оновлення моделей без перезапису інших налаштувань:

```bash
./generate_opencode_config.sh --merge -o opencode.json
```

## Встановлення конфігурації

```bash
cp opencode.json ~/.config/opencode/opencode.json
```

## Змінні середовища

| Variable | Description |
|----------|-------------|
| `OLLAMA_HOST` | Default Ollama URL |
| `XDG_CACHE_HOME` | Cache directory |

## Вирішення проблем

### Не вдалося підключитися до Ollama

- Переконайтеся, що Ollama запущений: `ollama serve`
- Перевірте URL: `curl http://localhost:11434/api/tags`

### Відсутні залежності

```bash
sudo apt install python3 curl   # Ubuntu/Debian
brew install python3 curl       # macOS
```

### Неправильний контекст

- Скрипт за замовчуванням використовує `/api/show`
- Використовуйте `--no-context-lookup`, якщо API повільний
