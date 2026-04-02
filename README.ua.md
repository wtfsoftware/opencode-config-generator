# Генератор конфігурації OpenCode для Ollama

Генерує конфігурацію `opencode.json` з локальних та віддалених серверів Ollama.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

English | [Русский](README.ru.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Español](README.es.md) | [中文](README.zh.md) | [日本語](README.ja.md) | [Português](README.pt.md) | [Italiano](README.it.md) | [한국어](README.ko.md) | [العربية](README.ar.md) | [Nederlands](README.nl.md) | [Українська](README.ua.md)

**v1.4.1** | [Specification](SPECIFICATION.md) | [Development](DEVELOPMENT.md) | [Disclaimer](DISCLAIMER.md)

## Можливості

- **Підтримка кількох провайдерів**: Ollama, LM Studio, vLLM, llama.cpp, LocalAI, text-generation-webui, Jan.ai, GPT4All
- Автоматичне визначення провайдера за портом, або вкажіть через `-p`
- Автоматичне виявлення всіх моделей через API провайдера
- Відфільтровує embedding-моделі (nomic-bert, поле type LM Studio тощо)
- Фільтрація моделей за підтримкою виклику інструментів/функцій (`--tools-only`)
- Отримує точні довжини контексту (Ollama `/api/show`, llama.cpp `/props`, LM Studio розширені метадані)
- Підтримує кілька серверів різних провайдерів одночасно
- Інтерактивний вибір моделей (з опцією «Всі моделі»)
- Включення/виключення моделей за glob-патернами
- Автоматичне визначення `small_model` (найменша не-embed модель для генерації заголовків)
- Режим dry-run (попередній перегляд без запису)
- Поважає змінну середовища `OLLAMA_HOST`

## Вимоги

| Компонент | Bash-скрипт | PowerShell-скрипт |
|-----------|:-----------:|:-----------------:|
| curl      | потрібен    | не потрібен       |
| Python 3  | потрібен    | не потрібен       |
| PowerShell 5.1+ | н/ст   | потрібен          |

## Швидкий старт

```bash
# Bash (Linux/macOS/WSL/Git Bash)
./generate_opencode_config.sh

# PowerShell (Windows)
.\Generate-OpenCodeConfig.ps1
```

## Використання

### Bash

```bash
# Тільки локальний Ollama (використовує $OLLAMA_HOST або http://localhost:11434)
./generate_opencode_config.sh

# З одним віддаленим сервером
./generate_opencode_config.sh -r http://192.168.1.100:11434

# З кількома віддаленими серверами
./generate_opencode_config.sh -r http://gpu1:11434 -r http://gpu2:11434

# Інтерактивний вибір моделей
./generate_opencode_config.sh -i

# Тільки qwen моделі
./generate_opencode_config.sh --include "qwen*"

# Виключити codestral
./generate_opencode_config.sh --exclude "codestral*"

# Включити embedding-моделі
./generate_opencode_config.sh --with-embed

# Тільки моделі з підтримкою виклику інструментів/функцій
./generate_opencode_config.sh --tools-only

# Попередній перегляд без запису файлу
./generate_opencode_config.sh -n

# Додати num_ctx до опцій провайдера (для виклику інструментів)
./generate_opencode_config.sh --num-ctx 32768

# Явно встановити модель за замовчуванням
./generate_opencode_config.sh --default-model qwen2.5-coder:7b

# Об'єднати з існуючою конфігурацією (оновити моделі, зберегти інші налаштування)
./generate_opencode_config.sh --merge

# Пропустити виклики /api/show (швидше, використовує захардкоджені ліміти контексту)
./generate_opencode_config.sh --no-context-lookup

# Вимкнути кеш пошуку контексту
./generate_opencode_config.sh --no-cache

# Записати в глобальну конфігурацію
./generate_opencode_config.sh -o ~/.config/opencode/opencode.json
```

### PowerShell

```powershell
# Тільки локальний Ollama
.\Generate-OpenCodeConfig.ps1

# З віддаленими серверами
.\Generate-OpenCodeConfig.ps1 -RemoteOllamaUrl "http://192.168.1.100:11434"
.\Generate-OpenCodeConfig.ps1 -RemoteOllamaUrl "http://gpu1:11434","http://gpu2:11434"

# Інтерактивний вибір
.\Generate-OpenCodeConfig.ps1 -Interactive

# Тільки qwen моделі
.\Generate-OpenCodeConfig.ps1 -Include "qwen*"

# Dry-run
.\Generate-OpenCodeConfig.ps1 -DryRun

# З num_ctx
.\Generate-OpenCodeConfig.ps1 -NumCtx 32768

# Записати в глобальну конфігурацію
.\Generate-OpenCodeConfig.ps1 -OutputFile "$env:USERPROFILE\.config\opencode\opencode.json"
```

## Довідка по CLI

### Bash

| Прапорець | Опис | За замовчуванням |
|-----------|------|-----------------|
| `-l, --local URL` | URL локального сервера | `$OLLAMA_HOST` або `http://localhost:11434` |
| `-r, --remote URL` | URL віддаленого сервера (повторюваний) | немає |
| `-p, --provider НАЗВА` | Провайдер: ollama, lmstudio, vllm, llama-cpp, localai, tgwui, jan, gpt4all | автовизначення |
| `-o, --output ФАЙЛ` | Шлях до файлу виводу (`-` для stdout) | `opencode.json` |
| `-n, --dry-run` | Вивести на stdout, не записувати | вимкнено |
| `-i, --interactive` | Інтерактивний вибір моделей | вимкнено |
| `--include ШАБЛОН` | Включити моделі, що відповідають glob (повторюваний) | всі |
| `--exclude ШАБЛОН` | Виключити моделі, що відповідають glob (повторюваний) | немає |
| `--with-embed` | Включити embedding-моделі | виключені |
| `--tools-only` | Тільки моделі з підтримкою виклику інструментів/функцій | вимкнено |
| `--no-context-lookup` | Пропустити `/api/show`, використовувати захардкоджені ліміти | вимкнено |
| `--num-ctx N` | `num_ctx` для опцій провайдера, 0 для пропуску | `0` |
| `--merge` | Об'єднати з існуючою конфігурацією (оновити лише моделі) | вимкнено |
| `--default-model ID` | Явно встановити модель за замовчуванням | авто |
| `--small-model ID` | Явно встановити small_model (для генерації заголовків) | авто |
| `--no-cache` | Вимкнути кеш пошуку контексту | вимкнено |
| `-v, --version` | Показати версію | |
| `-h, --help` | Показати довідку | |

### PowerShell

| Параметр | Опис | За замовчуванням |
|----------|------|-----------------|
| `-LocalOllamaUrl` | URL локального Ollama | `$OLLAMA_HOST` або `http://localhost:11434` |
| `-RemoteOllamaUrl` | Віддалені URL (масив) | немає |
| `-OutputFile` | Шлях до файлу виводу | `opencode.json` |
| `-DryRun` | Вивести на stdout, не записувати | вимкнено |
| `-Interactive` | Інтерактивний вибір моделей | вимкнено |
| `-Include` | Шаблони включення (wildcard, масив) | всі |
| `-Exclude` | Шаблони виключення (wildcard, масив) | немає |
| `-WithEmbed` | Включити embedding-моделі | виключені |
| `-ToolsOnly` | Тільки моделі з підтримкою виклику інструментів/функцій | вимкнено |
| `-NoContextLookup` | Пропустити `/api/show`, використовувати захардкоджені ліміти | вимкнено |
| `-NumCtx` | `num_ctx` для опцій провайдера, 0 для пропуску | `0` |
| `-Merge` | Об'єднати з існуючою конфігурацією (оновити лише моделі) | вимкнено |
| `-DefaultModel` | Явно встановити модель за замовчуванням | авто |
| `-SmallModel` | Явно встановити small_model (для генерації заголовків) | авто |
| `-NoCache` | Вимкнути кеш пошуку контексту | вимкнено |
| `-Version` | Показати версію | |
| `-Help` | Показати довідку | |

## Як це працює

1. **Отримання моделей** з кожного сервера Ollama через `GET /api/tags`
2. **Фільтрація** embedding-моделей за полем `families` (`nomic-bert`, `bert` тощо)
3. **Фільтрація** за патернами include/exclude (glob-зіставлення)
4. **Отримання довжин контексту** для кожної моделі через `POST /api/show` (паралельно, з кешем)
5. **Дедуплікація** моделей, знайдених на кількох серверах (зберігає версію першого сервера)
6. **Інтерактивний вибір** (якщо `-i`): нумерований список з опцією `[0] Всі моделі`
7. **Об'єднання** (якщо `--merge`): збереження існуючих налаштувань та інших провайдерів
8. **Автовизначення `small_model`**: найменша не-embed модель за кількістю параметрів
9. **Генерація** `opencode.json` з Ollama як провайдером

## Структура згенерованої конфігурації

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

### Поля

| Поле | Опис |
|------|------|
| `provider.ollama.options.baseURL` | Сумісний з OpenAI ендпоінт Ollama |
| `provider.ollama.models.*.limit.context` | Максимальне вікно контексту для моделі |
| `provider.ollama.models.*.limit.output` | Максимальні токени виводу (обмежено 16K) |
| `model` | Модель за замовчуванням (перша доступна) |
| `small_model` | Найменша модель для легких завдань (генерація заголовків) |

## Визначення контексту моделі

Довжини контексту визначаються в такому порядку пріоритету:

1. **API-запит** — `POST /api/show` повертає `model_info.*.context_length` (точне значення)
2. **Захардкоджений фолбек** — оцінка за сімейством моделі:

| Сімейство | Контекст за замовчуванням |
|-----------|:-------------------------:|
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
| інше | 8 192 |

Використовуйте `--no-context-lookup`, щоб пропустити API-виклики та використовувати лише захардкоджені значення (швидше).

## Embedding-моделі

Embedding-моделі **виключені за замовчуванням**, оскільки не підтримують виклик чату/інструментів. Визначення базується на:

- Сімействах моделей, що містять `nomic-bert`, `bert`, `bert-moe`, `embed`, `embedding`
- Назвах моделей, що містять ці ключові слова

Використовуйте `--with-embed` / `-WithEmbed`, щоб включити їх.

## Фільтр виклику інструментів/функцій

Використовуйте `--tools-only` / `-ToolsOnly`, щоб включити лише моделі, які підтримують виклик інструментів/функцій:

```bash
./generate_opencode_config.sh --tools-only
```

Визначення працює на двох рівнях:
1. **Точний** — LM Studio надає `capabilities.tool_use` через свій розширений ендпоінт `/api/v1/models`
2. **Евристичний** — для всіх інших провайдерів моделі зіставляються з відомим списком дозволених сімейств з підтримкою інструментів (qwen2.5/3, llama3.x, mistral, mixtral, deepseek-r1/v3, command-r, phi3/4, gemma2/3, granite3.x)

Моделі, які не відповідають жодній перевірці, виключаються, коли `--tools-only` активний. Список дозволених може потребувати оновлень у мірі виходу нових сімейств моделей.

## Підтримка кількох провайдерів

Працює з 8 локальними провайдерами інференсу. Провайдер автовизначається за портом, або вкажіть через `-p`.

| Провайдер | Порт за замовчуванням | Розширені метадані | Автовизначення |
|-----------|:---------------------:|:------------------:|:--------------:|
| **Ollama** | 11434 | `/api/show` (контекст, сімейства) | ✅ |
| **LM Studio** | 1234 | `/api/v1/models` (тип, можливості, контекст) | ✅ |
| **vLLM** | 8000 | лише базові | ✅ |
| **llama.cpp** | 8080 | `/props` (context_size) | ✅ (як localai) |
| **LocalAI** | 8080 | лише базові | ✅ |
| **text-generation-webui** | 5000 | лише базові | ✅ |
| **Jan.ai** | 1337 | лише базові | ✅ |
| **GPT4All** | 4891 | лише базові | ✅ |

```bash
# Автовизначення за портом
./generate_opencode_config.sh -l http://localhost:1234       # LM Studio
./generate_opencode_config.sh -l http://localhost:8000       # vLLM

# Явний провайдер
./generate_opencode_config.sh -l http://localhost:8080 -p llama-cpp

# Ollama + LM Studio разом
./generate_opencode_config.sh -l http://localhost:11434 -r http://localhost:1234 -p lmstudio
```

Кожен провайдер відображається як окремий блок в `opencode.json`:

```json
{
  "provider": {
    "ollama": { "name": "Ollama", "options": { "baseURL": "http://localhost:11434/v1" }, ... },
    "lmstudio": { "name": "LM Studio", "options": { "baseURL": "http://localhost:1234/v1" }, ... }
  }
}
```

## Кеш пошуку контексту

Довжини контексту з `/api/show` кешуються в `~/.cache/opencode-generator/` за хешем URL. Кеш спливає через 24 години. Наступні запуски повторно використовують кешовані значення та отримують лише нові моделі. Використовуйте `--no-cache`, щоб вимкнути.

## Режим об'єднання

Використовуйте `--merge`, щоб оновити моделі в існуючому `opencode.json` без перезапису інших налаштувань (кастомні провайдери, теми, правила тощо):

```bash
# Початкова генерація
./generate_opencode_config.sh -o opencode.json

# Вручну додати кастомні провайдери, правила тощо в opencode.json

# Пізніше: оновити лише моделі, зберегти все інше
./generate_opencode_config.sh --merge -o opencode.json
```

## Дедуплікація

Якщо одна й та сама модель існує на кількох серверах, кожна копія отримує унікальне ім'я з суфіксом сервера:

```
qwen2.5-coder:7b                → локальний сервер (оригінальне ім'я)
qwen2.5-coder:7b@gpu-server     → перший віддалений сервер
qwen2.5-coder:7b@gpu-server-2   → другий віддалений з тим самим hostname
```

Обидві версії з'являються в `/models`. Підсумок показує, які моделі отримали суфікс.

## Змінні середовища

| Змінна | Опис |
|--------|------|
| `OLLAMA_HOST` | URL локального Ollama за замовчуванням (стандартна змінна Ollama) |
| `XDG_CACHE_HOME` | Базовий шлях до кеш-директорії |

## Встановлення згенерованої конфігурації

```bash
# Глобальна конфігурація (всі проєкти)
cp opencode.json ~/.config/opencode/opencode.json

# Для конкретного проєкту
cp opencode.json /шлях/до/проєкту/opencode.json
```

## Вирішення проблем

### "Не вдалося підключитися до Ollama"

- Переконайтеся, що Ollama запущений: `ollama serve`
- Перевірте URL: `curl http://localhost:11434/api/tags`
- Якщо використовуєте кастомний порт/хост, встановіть `OLLAMA_HOST` або використовуйте `-l`

### "Відсутні необхідні залежності: python3"

```bash
# Ubuntu/Debian
sudo apt install python3

# macOS
brew install python3

# Windows: завантажити з https://python.org
```

### Неправильна довжина контексту

- Скрипт за замовчуванням використовує `/api/show` для точних значень
- Якщо API повільний, використовуйте `--no-context-lookup` для захардкоджених оцінок
- Перевизначте вручну в згенерованому JSON за потреби

### Embedding-моделі включені/виключені неочікувано

- Перевірте сімейства у виводі `ollama show <model>`
- Використовуйте `--with-embed` для примусового включення
- Використовуйте `--exclude "*embed*"` для примусового виключення за назвою

### "Провайдер повернув помилку" в OpenCode

- Деякі моделі Ollama не підтримують виклик інструментів — спробуйте `qwen2.5-coder` або `llama3.2`
- Збільште `num_ctx`, якщо інструменти не працюють: `--num-ctx 32768`
- Переконайтеся, що модель завантажена: `ollama run <model>`
