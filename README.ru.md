# Генератор конфигурации OpenCode для Ollama

Генерирует `opencode.json` для [OpenCode](https://opencode.ai) на основе моделей из локальных и удалённых серверов Ollama.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

[English](README.md) | Русский | [Français](README.fr.md) | [Deutsch](README.de.md) | [Español](README.es.md) | [中文](README.zh.md) | [日本語](README.ja.md) | [Português](README.pt.md) | [Italiano](README.it.md) | [한국어](README.ko.md) | [العربية](README.ar.md) | [Nederlands](README.nl.md) | [Українська](README.ua.md)

**v1.4.1** | [Specification](SPECIFICATION.md) | [Development](DEVELOPMENT.md) | [Disclaimer](DISCLAIMER.md)

---

## Возможности

- **Поддержка нескольких провайдеров**: Ollama, LM Studio, vLLM, llama.cpp, LocalAI, text-generation-webui, Jan.ai, GPT4All
- Автоопределение провайдера по порту или указание через `-p`
- Автоматическое обнаружение моделей через API провайдера
- Фильтрация embedding-моделей (nomic-bert, LM Studio type field и др.)
- Фильтрация моделей по поддержке tool/function calling (`--tools-only`)
- Точные контекстные окна (Ollama `/api/show`, llama.cpp `/props`, LM Studio rich metadata)
- Несколько серверов разных провайдеров одновременно
- Интерактивный выбор моделей с опцией «Все»
- Фильтрация по glob-паттернам (include/exclude)
- Автоопределение small_model (для генерации заголовков)
- Режим предпросмотра (dry-run)
- Суффиксы серверов при дублировании моделей
- Слияние с существующим конфигом (merge)
- Учёт переменной `OLLAMA_HOST`

## Требования

| Компонент | Bash скрипт | PowerShell скрипт |
|-----------|:-----------:|:-----------------:|
| curl      | обязателен  | не нужен          |
| Python 3  | обязателен  | не нужен          |
| PowerShell 5.1+ | н/а   | обязателен        |

## Быстрый старт

```bash
# Bash (Linux/macOS/WSL/Git Bash)
./generate_opencode_config.sh

# PowerShell (Windows)
.\Generate-OpenCodeConfig.ps1
```

## Использование

### Bash

```bash
# Только локальный Ollama
./generate_opencode_config.sh

# С удалённым сервером
./generate_opencode_config.sh -r http://192.168.1.100:11434

# С несколькими удалёнными серверами
./generate_opencode_config.sh -r http://gpu1:11434 -r http://gpu2:11434

# Интерактивный выбор моделей
./generate_opencode_config.sh -i

# Только модели qwen
./generate_opencode_config.sh --include "qwen*"

# Исключить codestral
./generate_opencode_config.sh --exclude "codestral*"

# Включить embedding-модели
./generate_opencode_config.sh --with-embed

# Предпросмотр без записи
./generate_opencode_config.sh -n

# Добавить num_ctx (для tool calling)
./generate_opencode_config.sh --num-ctx 32768

# Явно указать default модель
./generate_opencode_config.sh --default-model qwen2.5-coder:7b

# Явно указать small модель
./generate_opencode_config.sh --small-model qwen2.5-coder:3b

# Слияние с существующим конфигом
./generate_opencode_config.sh --merge

# Без кэша контекста (быстрее)
./generate_opencode_config.sh --no-context-lookup

# Записать в глобальный конфиг
./generate_opencode_config.sh -o ~/.config/opencode/opencode.json

# Версия
./generate_opencode_config.sh --version
```

### PowerShell

```powershell
# Только локальный Ollama
.\Generate-OpenCodeConfig.ps1

# С удалёнными серверами
.\Generate-OpenCodeConfig.ps1 -RemoteOllamaUrl "http://192.168.1.100:11434"
.\Generate-OpenCodeConfig.ps1 -RemoteOllamaUrl "http://gpu1:11434","http://gpu2:11434"

# Интерактивный выбор
.\Generate-OpenCodeConfig.ps1 -Interactive

# Только модели qwen
.\Generate-OpenCodeConfig.ps1 -Include "qwen*"

# Предпросмотр
.\Generate-OpenCodeConfig.ps1 -DryRun

# С num_ctx
.\Generate-OpenCodeConfig.ps1 -NumCtx 32768

# Default модель
.\Generate-OpenCodeConfig.ps1 -DefaultModel "qwen2.5-coder:7b"

# Слияние
.\Generate-OpenCodeConfig.ps1 -Merge

# Записать в глобальный конфиг
.\Generate-OpenCodeConfig.ps1 -OutputFile "$env:USERPROFILE\.config\opencode\opencode.json"

# Версия
.\Generate-OpenCodeConfig.ps1 -Version
```

## Справка по флагам

### Bash

| Флаг | Описание | По умолчанию |
|------|----------|--------------|
| `-l, --local URL` | URL локального сервера | `$OLLAMA_HOST` или `http://localhost:11434` |
| `-r, --remote URL` | URL удалённого сервера (можно указать несколько) | нет |
| `-p, --provider NAME` | Провайдер: ollama, lmstudio, vllm, llama-cpp, localai, tgwui, jan, gpt4all | авто |
| `-o, --output FILE` | Путь к выходному файлу (`-` для stdout) | `opencode.json` |
| `-n, --dry-run` | Вывести в stdout, не записывать файл | выкл |
| `-i, --interactive` | Интерактивный выбор моделей | выкл |
| `--include PAT` | Включить модели по glob-паттерну (можно несколько) | все |
| `--exclude PAT` | Исключить модели по glob-паттерну (можно несколько) | нет |
| `--with-embed` | Включить embedding-модели | исключены |
| `--tools-only` | Только модели с поддержкой tool/function calling | выкл |
| `--no-context-lookup` | Пропустить `/api/show`, использовать хардкод | выкл |
| `--num-ctx N` | `num_ctx` для провайдера, 0 — не добавлять | `0` |
| `--merge` | Слить с существующим конфигом | выкл |
| `--default-model ID` | Явно указать default модель | авто |
| `--small-model ID` | Явно указать small модель | авто |
| `--no-cache` | Отключить кэш контекста | выкл |
| `-v, --version` | Показать версию | |
| `-h, --help` | Показать справку | |

### PowerShell

| Параметр | Описание | По умолчанию |
|----------|----------|--------------|
| `-LocalOllamaUrl` | URL локального Ollama | `$OLLAMA_HOST` или `http://localhost:11434` |
| `-RemoteOllamaUrl` | URL удалённых серверов (массив) | нет |
| `-OutputFile` | Путь к выходному файлу | `opencode.json` |
| `-DryRun` | Вывести в stdout | выкл |
| `-Interactive` | Интерактивный выбор | выкл |
| `-Include` | Паттерны включения (wildcard) | все |
| `-Exclude` | Паттерны исключения (wildcard) | нет |
| `-WithEmbed` | Включить embedding-модели | исключены |
| `-ToolsOnly` | Только модели с поддержкой tool/function calling | выкл |
| `-NoContextLookup` | Пропустить `/api/show` | выкл |
| `-NumCtx` | `num_ctx` для провайдера | `0` |
| `-Merge` | Слить с существующим | выкл |
| `-DefaultModel` | Default модель | авто |
| `-SmallModel` | Small модель | авто |
| `-NoCache` | Отключить кэш | выкл |
| `-Version` | Показать версию | |
| `-Help` | Показать справку | |

## Как это работает

1. **Получение моделей** с каждого сервера через API провайдера
2. **Фильтрация** embedding-моделей по полю `families`
3. **Фильтрация** по include/exclude паттернам
4. **Получение контекста** через API (параллельно, с кэшированием)
5. **Дедупликация** моделей с нескольких серверов (суффиксы `@host:port`)
6. **Интерактивный выбор** (если `-i`): нумерованный список с опцией `[0] Все`
7. **Слияние** (если `--merge`): сохраняет настройки и другие провайдеры
8. **Автоопределение small_model**: самая маленькая не-embed модель
9. **Генерация** `opencode.json`

## Определение контекста

Контекстные окна определяются в следующем порядке приоритета:

1. **API** — точное значение из API провайдера
2. **Хардкод** — оценка по семейству модели:

| Семейство | Контекст по умолчанию |
|-----------|:---------------------:|
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
| другие | 8 192 |

Используйте `--no-context-lookup` для пропуска API-вызовов (быстрее).

## Embedding-модели

Embedding-модели **исключены по умолчанию**, так как не поддерживают chat/tool calling. Определение по:

- Семействам моделей: `nomic-bert`, `bert`, `bert-moe`, `embed`, `embedding`
- Ключевым словам в имени модели

Используйте `--with-embed` для включения.

## Фильтр tool/function calling

Используйте `--tools-only` для включения только моделей с поддержкой tool/function calling:

```bash
./generate_opencode_config.sh --tools-only
```

Определение работает в два этапа:
1. **Точное** — LM Studio предоставляет `capabilities.tool_use` через `/api/v1/models`
2. **Эвристическое** — для остальных провайдеров модели сопоставляются со списком известных семейств (qwen2.5/3, llama3.x, mistral, mixtral, deepseek-r1/v3, command-r, phi3/4, gemma2/3, granite3.x)

## Мульти-провайдер

Поддержка 8 локальных инференс-провайдеров. Провайдер определяется по порту автоматически или задаётся через `-p`.

| Провайдер | Порт по умолчанию | Rich Metadata | Авто |
|-----------|:-----------------:|:-------------:|:----:|
| **Ollama** | 11434 | `/api/show` (контекст, семейства) | ✅ |
| **LM Studio** | 1234 | `/api/v1/models` (тип, возможности, контекст) | ✅ |
| **vLLM** | 8000 | базовые | ✅ |
| **llama.cpp** | 8080 | `/props` (context_size) | ✅ (как localai) |
| **LocalAI** | 8080 | базовые | ✅ |
| **text-generation-webui** | 5000 | базовые | ✅ |
| **Jan.ai** | 1337 | базовые | ✅ |
| **GPT4All** | 4891 | базовые | ✅ |

```bash
# Автоопределение по порту
./generate_opencode_config.sh -l http://localhost:1234       # LM Studio
./generate_opencode_config.sh -l http://localhost:8000       # vLLM

# Явный провайдер
./generate_opencode_config.sh -l http://localhost:8080 -p llama-cpp

# Ollama + LM Studio вместе
./generate_opencode_config.sh -l http://localhost:11434 -r http://localhost:1234 -p lmstudio
```

Каждый провайдер — отдельный блок в `opencode.json`:

```json
{
  "provider": {
    "ollama": { "name": "Ollama", "options": { "baseURL": "http://localhost:11434/v1" }, ... },
    "lmstudio": { "name": "LM Studio", "options": { "baseURL": "http://localhost:1234/v1" }, ... }
  }
}
```

## Пример конфигурации

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
        "qwen2.5-coder:7b": {
          "name": "Qwen2 7.6B Q4_K_M (local)",
          "limit": {
            "context": 32768,
            "output": 16384
          }
        }
      }
    }
  },
  "model": "ollama/qwen2.5-coder:7b",
  "small_model": "ollama/qwen2.5-coder:3b"
}
```

### Поля

| Поле | Описание |
|------|----------|
| `provider.ollama.options.baseURL` | OpenAI-совместимый эндпоинт Ollama |
| `provider.ollama.models.*.limit.context` | Максимальное окно контекста |
| `provider.ollama.models.*.limit.output` | Макс. выходных токенов (ограничено 16K) |
| `model` | Модель по умолчанию (первая доступная) |
| `small_model` | Самая маленькая модель для лёгких задач (генерация заголовков) |

## Дедупликация

Если одна и та же модель есть на нескольких серверах, каждая получает уникальное имя:

```
qwen2.5-coder:7b                  → локальный сервер (оригинальное имя)
qwen2.5-coder:7b@gpu-server       → первый удалённый сервер
qwen2.5-coder:7b@gpu-server-2     → второй удалённый с тем же хостом
```

Обе версии доступны в `/models` OpenCode.

## Кэширование контекста

Контекстные окна из `/api/show` кэшируются в `~/.cache/opencode-generator/`. Кэш истекает через 24 часа. Используйте `--no-cache` для отключения.

## Слияние (Merge)

Используйте `--merge` для обновления моделей без перезаписи остальных настроек:

```bash
# Первоначальная генерация
./generate_opencode_config.sh -o opencode.json

# Вручную добавить провайдеры, правила и т.д.

# Позже: обновить только модели
./generate_opencode_config.sh --merge -o opencode.json
```

## Установка сгенерированного конфига

```bash
# Глобальный конфиг (все проекты)
cp opencode.json ~/.config/opencode/opencode.json

# Для конкретного проекта
cp opencode.json /path/to/project/opencode.json
```

## Переменные окружения

| Переменная | Описание |
|------------|----------|
| `OLLAMA_HOST` | URL локального Ollama (стандартная переменная Ollama) |
| `XDG_CACHE_HOME` | Базовая директория для кэша |

## Решение проблем

### «Не удалось подключиться к Ollama»

- Убедитесь, что Ollama запущен: `ollama serve`
- Проверьте URL: `curl http://localhost:11434/api/tags`
- Если используется нестандартный порт/хост, задайте `OLLAMA_HOST` или `-l`

### «Missing required dependencies: python3»

```bash
# Ubuntu/Debian
sudo apt install python3

# macOS
brew install python3

# Windows: https://python.org/downloads
```

### Неправильный контекст

- Скрипт использует `/api/show` для точных значений
- Если API медленный, используйте `--no-context-lookup`
- Переопределите вручную в сгенерированном JSON

### Embedding-модели включены/исключены неожиданно

- Проверьте families в выводе `ollama show <model>`
- Используйте `--with-embed` для принудительного включения
- Используйте `--exclude "*embed*"` для исключения по имени

### «Provider returned error» в OpenCode

- Некоторые модели Ollama не поддерживают tool calling — попробуйте `qwen2.5-coder` или `llama3.2`
- Увеличьте `num_ctx`, если инструменты не работают: `--num-ctx 32768`
- Убедитесь, что модель загружена: `ollama run <model>`
