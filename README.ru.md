# Генератор конфигурации OpenCode для Ollama

Генерирует `opencode.json` для [OpenCode](https://opencode.ai) на основе моделей из локальных и удалённых серверов Ollama.

[English](README.md) | Русский | [Français](README.fr.md) | [Deutsch](README.de.md) | [Español](README.es.md) | [中文](README.zh.md) | [日本語](README.ja.md) | [Português](README.pt.md) | [Italiano](README.it.md) | [한국어](README.ko.md) | [العربية](README.ar.md) | [Nederlands](README.nl.md) | [Українська](README.ua.md)

---

## Возможности

- **Поддержка нескольких провайдеров**: Ollama, LM Studio, vLLM, llama.cpp, LocalAI, text-generation-webui, Jan.ai, GPT4All
- Автоопределение провайдера по порту или указание через `-p`
- Автоматическое обнаружение моделей через API провайдера
- Фильтрация embedding-моделей (nomic-bert, LM Studio type field и др.)
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
| `--tools-only` | Only models with tool/function calling support | off |
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
| `-ToolsOnly` | Only models with tool/function calling support | off |
| `-NoContextLookup` | Пропустить `/api/show` | выкл |
| `-NumCtx` | `num_ctx` для провайдера | `0` |
| `-Merge` | Слить с существующим | выкл |
| `-DefaultModel` | Default модель | авто |
| `-SmallModel` | Small модель | авто |
| `-NoCache` | Отключить кэш | выкл |
| `-Version` | Показать версию | |
| `-Help` | Показать справку | |

## Как это работает

1. **Получение моделей** с каждого сервера Ollama через `GET /api/tags`
2. **Фильтрация** embedding-моделей по полю `families`
3. **Фильтрация** по include/exclude паттернам
4. **Получение контекста** через `POST /api/show` (параллельно, с кэшированием)
5. **Дедупликация** моделей с нескольких серверов (суффиксы `@host:port`)
6. **Интерактивный выбор** (если `-i`): нумерованный список с опцией `[0] Все`
7. **Слияние** (если `--merge`): сохраняет настройки и другие провайдеры
8. **Автоопределение small_model**: самая маленькая не-embed модель
9. **Генерация** `opencode.json`

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
