# Документация экосистемы OpenCode

Полная экосистема для OpenCode — skills, команды, агенты, правила, плагины и утилиты.

## Быстрый старт

```bash
# 1. Клонировать репозиторий
git clone https://github.com/your-org/ocskills.git
cd ocskills

# 2. Установить все skills глобально
./generate_opencode_config.sh --all ~/.config/opencode

# 3. Применить конфиги к проектам
.opencode/scripts/apply-project-configs.sh

# 4. Проверить окружение
.opencode/scripts/doctor.sh
```

---

## Skills (25)

Skills — это файлы `SKILL.md` с инструкциями, которые OpenCode обнаруживает и загружает по требованию.

### Установка

```bash
# Все skills глобально
./generate_opencode_config.sh --all ~/.config/opencode

# По категории
./generate_opencode_config.sh --category frontend ~/.config/opencode
./generate_opencode_config.sh --category backend ~/.config/opencode
./generate_opencode_config.sh --category devops ~/.config/opencode

# В конкретный проект
./generate_opencode_config.sh --all /path/to/project

# Интерактивно
./generate_opencode_config.sh
```

### Frontend (6)

| Skill | Описание |
|-------|----------|
| `react-master` | Hooks, компоненты, state management, performance, accessibility, Suspense, React 19 |
| `nextjs-master` | App Router, SSR/SSG, caching, API routes, middleware, image optimization |
| `ui-design-master` | Визуальная иерархия, layout, типографика, цвета, анимации, accessibility |
| `web-performance-master` | Core Web Vitals, bundle optimization, CDN, caching, measurement |
| `web-security-master` | CSP, XSS, CSRF, secure cookies, SRI, HTTPS, security headers |
| `mobile-master` | React Native, навигация, native modules, offline, push notifications |

### Language (4)

| Skill | Описание |
|-------|----------|
| `typescript-master` | Generics, utility types, type guards, discriminated unions, strict mode |
| `python-master` | Type hints, async, dataclasses, Pydantic, pytest, FastAPI, Flask, pandas, multiprocessing |
| `go-master` | Идиомы, интерфейсы, горутины, каналы, context, error handling, HTTP servers |
| `rust-master` | Ownership, lifetimes, traits, error handling, smart pointers, async, cargo |

### Backend (4)

| Skill | Описание |
|-------|----------|
| `api-design-master` | REST, GraphQL, gRPC, WebSocket, pagination, versioning, OpenAPI, webhooks |
| `database-master` | Schema design, индексы, миграции, ORM, репликация, sharding, query optimization |
| `security-master` | OWASP Top 10, auth (JWT, OAuth2), authorization, encryption, input validation |
| `data-engineering-master` | ETL/ELT, Spark, Airflow, dbt, data mesh, CDC, data contracts, observability |

### DevOps (5)

| Skill | Описание |
|-------|----------|
| `docker-master` | Dockerfile best practices, multi-stage builds, compose, security, optimization |
| `ci-cd-master` | GitHub Actions, caching, deployment strategies, environments, secrets |
| `kubernetes-master` | Pods, deployments, Helm, operators, networking, RBAC, GitOps |
| `cloud-aws-master` | EC2, S3, Lambda, IAM, RDS, CloudFormation, CDK, cost optimization |
| `monitoring-master` | Logs/metrics/traces, SLO/SLI, alerting, Grafana, Prometheus, incident response |

### Architecture (1)

| Skill | Описание |
|-------|----------|
| `microservices-master` | Decomposition, saga, API gateway, event-driven, service mesh, distributed tracing |

### Testing (1)

| Skill | Описание |
|-------|----------|
| `testing-master` | Testing pyramid, TDD, mocking, E2E (Playwright), coverage, CI optimization |

### Collaboration (2)

| Skill | Описание |
|-------|----------|
| `code-review-master` | Review checklists, code smells, refactoring patterns, feedback techniques |
| `git-master` | Workflows, rebase, bisect, hooks, submodules, troubleshooting |

### Documentation (1)

| Skill | Описание |
|-------|----------|
| `docs-master` | README, API docs, ADR, changelog, contributing guides, Mermaid diagrams |

### Game Development (1)

| Skill | Описание |
|-------|----------|
| `game-dev-master` | Game loop, ECS, physics, AI (state machines, behavior trees, A*), optimization |

---

## Slash Commands (10)

Кастомные команды для повторяющихся задач. Вызываются через `/`.

| Команда | Описание | Аргументы |
|---------|----------|-----------|
| `/review` | Авто-ревью кода с чеклистом качества | — |
| `/explain` | Подробное объяснение выбранного кода | — |
| `/test-gen` | Генерация тестов для выбранного файла | — |
| `/refactor` | Предложения по рефакторингу с примерами | — |
| `/diagram` | Генерация Mermaid-диаграмм из кода | — |
| `/docstring` | Автогенерация docstrings/JSDoc | — |
| `/security-audit` | Поиск уязвимостей в коде | — |
| `/changelog` | Генерация changelog из git history | — |
| `/commit` | Генерация commit message из staged changes | — |
| `/architect` | Анализ архитектуры проекта | — |

### Использование

```
/review          # Ревью текущего файла
/explain         # Объяснить выделенный код
/test-gen        # Сгенерировать тесты
/commit          # Создать commit message
/changelog       # Сгенерировать changelog
```

---

## Custom Agents (6)

Специализированные AI-ассистенты для конкретных задач.

| Агент | Режим | Описание | Доступ |
|-------|-------|----------|--------|
| `architect` | subagent | Анализ архитектуры и паттернов | Read-only + grep/find/git |
| `security-auditor` | subagent | Аудит безопасности | Read-only + grep/find/git |
| `test-engineer` | subagent | Написание тестов | Edit (ask) + test commands |
| `devops-engineer` | subagent | Инфраструктура и CI/CD | Edit (ask) + docker/k8s/git |
| `tech-writer` | subagent | Техническая документация | Edit (ask) + grep/find/git |
| `performance-engineer` | subagent | Оптимизация производительности | Edit (ask) + build/lighthouse |

### Вызов агентов

```
# Через @mention
@architect проанализируй архитектуру проекта
@security-auditor проверь код на уязвимости
@test-engineer напиши тесты для этого файла

# Через Tab (primary agents)
# Переключение между Build и Plan
```

---

## Rules (5)

Глобальные правила, применяемые ко всем сессиям OpenCode.

| Правило | Описание |
|---------|----------|
| `clean-code.md` | Именование, функции, структура, комментарии, простота, обработка ошибок |
| `security-rules.md` | Валидация input, auth, защита данных, web security, зависимости |
| `testing-standards.md` | Testing pyramid, структура тестов, моки, coverage, CI |
| `commit-conventions.md` | Conventional Commits формат, примеры, правила |
| `documentation-standards.md` | README, API docs, ADR, changelog, contributing |

---

## Plugins (30+)

Плагины расширяют функциональность OpenCode. Есть два способа установки:

### Способы установки

#### 1. npm-плагины (рекомендуется)

Добавьте в `opencode.json`:

```json
{
  "plugin": [
    "opencode-wakatime",
    "opencode-worktree",
    "@my-org/custom-plugin"
  ]
}
```

OpenCode автоматически устанавливает их через Bun при запуске. Пакеты кэшируются в `~/.cache/opencode/node_modules/`.

#### 2. Локальные плагины

Поместите `.js` или `.ts` файлы в:
- `~/.config/opencode/plugins/` — глобальные плагины
- `.opencode/plugins/` — плагины проекта

Для внешних зависимостей добавьте `package.json` в директорию конфига:

```json
{
  "dependencies": {
    "shescape": "^2.1.0"
  }
}
```

OpenCode запускает `bun install` при старте.

### Управление плагинами

```bash
# Список всех доступных плагинов
.opencode/scripts/install-plugins.sh list

# По категории
.opencode/scripts/install-plugins.sh list auth
.opencode/scripts/install-plugins.sh list agents

# Установка (добавляет в opencode.json)
.opencode/scripts/install-plugins.sh install wakatime
.opencode/scripts/install-plugins.sh install worktree

# Обновление (очищает кэш)
.opencode/scripts/install-plugins.sh update wakatime
.opencode/scripts/install-plugins.sh update-all

# Удаление
.opencode/scripts/install-plugins.sh remove wakatime

# Статус
.opencode/scripts/install-plugins.sh status

# Диагностика
.opencode/scripts/install-plugins.sh doctor
```

### Создание плагина

```js
// .opencode/plugins/my-plugin.js
export const MyPlugin = async ({ project, client, $, directory, worktree }) => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool === "read" && output.args.filePath.includes(".env")) {
        throw new Error("Не читайте .env файлы");
      }
    },
  };
};
```

Плагины получают: `project`, `client`, `$` (Bun shell API), `directory`, `worktree`.

### Доступные события

| Категория | События |
|-----------|---------|
| Command | `command.executed` |
| File | `file.edited`, `file.watcher.updated` |
| Message | `message.updated`, `message.removed`, `message.part.updated` |
| Permission | `permission.asked`, `permission.replied` |
| Session | `session.created`, `session.idle`, `session.compacted`, `session.error` |
| Tool | `tool.execute.before`, `tool.execute.after` |
| Shell | `shell.env` |
| TUI | `tui.prompt.append`, `tui.command.execute`, `tui.toast.show` |

### Категории плагинов

#### Auth (4)
| Плагин | Описание |
|--------|----------|
| `openai-codex-auth` | Использовать ChatGPT Plus/Pro вместо API credits |
| `gemini-auth` | Использовать существующий план Gemini |
| `antigravity-auth` | Бесплатные модели Antigravity |
| `google-antigravity-auth` | Google Antigravity OAuth с поиском |

#### Dev Tools (4)
| Плагин | Описание |
|--------|----------|
| `devcontainers` | Multi-branch devcontainer isolation |
| `daytona` | Запуск в изолированных песочницах Daytona |
| `worktree` | Git worktrees для OpenCode |
| `scheduler` | Recurring jobs с cron синтаксисом |

#### Performance (5)
| Плагин | Описание |
|--------|----------|
| `dynamic-context-pruning` | Оптимизация token usage |
| `vibeguard` | Redact secrets/PII перед LLM calls |
| `morph` | Fast Apply, WarpGrep search, context compaction |
| `shell-strategy` | Предотвращение hang от TTY операций |
| `pty` | Background processes в PTY |

#### Agents & Orchestration (5)
| Плагин | Описание |
|--------|----------|
| `background-agents` | Background agents с async delegation |
| `subtask2` | Orchestration flow control для команд |
| `workspace` | Multi-agent orchestration (16 components) |
| `skillful` | Lazy load prompts с skill discovery |
| `supermemory` | Persistent memory между сессиями |

#### Productivity (4)
| Плагин | Описание |
|--------|----------|
| `wakatime` | Трекинг использования OpenCode |
| `notificator` | Desktop notifications |
| `notifier` | Notifications для permission/error events |
| `zellij-namer` | AI-powered Zellij session naming |

#### Monitoring (2)
| Плагин | Описание |
|--------|----------|
| `sentry-monitor` | Trace AI agents через Sentry |
| `helicone-session` | Helicone session headers |

#### Search & Web (2)
| Плагин | Описание |
|--------|----------|
| `websearch-cited` | Websearch с Google grounded citations |
| `firecrawl` | Web scraping, crawling, search |

#### Code & Type (1)
| Плагин | Описание |
|--------|----------|
| `type-inject` | Auto-inject TypeScript/Svelte types в file reads |

#### UI (1)
| Плагин | Описание |
|--------|----------|
| `plannotator` | Interactive plan review с visual annotation |

#### Workflow (2)
| Плагин | Описание |
|--------|----------|
| `micode` | Structured Brainstorm → Plan → Implement workflow |
| `octto` | Interactive browser UI для AI brainstorming |

### Рекомендации по проектам

| Проект | Рекомендуемые плагины |
|--------|----------------------|
| ainet_preprocessor | worktree, scheduler, background-agents, sentry-monitor |
| dynamic / ebu | type-inject, vibeguard, notificator |
| Extensions | websearch-cited, md-table-formatter, wakatime |
| karma | pty, shell-strategy, notificator |
| sparkle | vibeguard, plannotator, micode |
| opencode_config_generator | skillful, supermemory, worktree |

---

## Project Templates

Готовые `opencode.json` для разных типов проектов.

| Шаблон | Проекты | Ключевые skills |
|--------|---------|----------------|
| `go.json` | ainet_preprocessor | go, api-design, security, docker, k8s, monitoring |
| `python.json` | dynamic, ebu | python, testing, docker, security |
| `javascript.json` | Extensions | typescript, react, testing, web-security, ci-cd |
| `cpp.json` | karma | code-review, testing, git |
| `kotlin.json` | sparkle | mobile, security, testing |
| `bash.json` | opencode_config_generator | git, testing, docs |

### Применение

```bash
# Ко всем проектам
.opencode/scripts/apply-project-configs.sh

# С принудительной перезаписью
.opencode/scripts/apply-project-configs.sh --force

# Предпросмотр
.opencode/scripts/apply-project-configs.sh --dry-run
```

---

## Utility Scripts (12)

| Скрипт | Описание |
|--------|----------|
| `generate_opencode_config.sh` | Установка skills глобально или в проект |
| `update-config.sh` | Мастер-скрипт — project config + models |
| `update-project-config.sh` | Интеллектуальная генерация project конфига |
| `update-models.sh` | Сканирование LLM-провайдеров, обновление models |
| `install-plugins.sh` | Управление плагинами (install/update/remove) |
| `apply-project-configs.sh` | Применение шаблонов opencode.json ко всем проектам |
| `doctor.sh` | Диагностика окружения OpenCode |
| `validate-skills.sh` | Валидация структуры SKILL.md |
| `project-analyzer.sh` | Автоопределение стека проекта |
| `config-generator.sh` | Генерация opencode.json |
| `update-skills.sh` | Обновление skills из репозитория |
| `smoke-test.sh` | Тесты для update-models.sh |

### update-config.sh — Мастер-скрипт

Главная точка входа для обновления конфигурации OpenCode:

```bash
# Обновить всё (project config + models)
.opencode/scripts/update-config.sh all

# Только project config (skills, commands, agents, permissions)
.opencode/scripts/update-config.sh project

# Только models (сканирование LLM-провайдеров)
.opencode/scripts/update-config.sh models

# Интерактивный выбор моделей
.opencode/scripts/update-config.sh models --interactive

# Предпросмотр
.opencode/scripts/update-config.sh all --dry-run

# Текущий статус
.opencode/scripts/update-config.sh status
```

### update-models.sh — Сканер LLM-провайдеров

Сканирует локальные и удалённые LLM-провайдеры (Ollama, LM Studio, vLLM, llama.cpp, LocalAI и др.) и генерирует секцию `models` в `opencode.json`:

```bash
# Сканировать локальный Ollama
.opencode/scripts/update-models.sh

# С удалённым сервером
.opencode/scripts/update-models.sh -r http://192.168.1.100:11434

# Интерактивный выбор
.opencode/scripts/update-models.sh -i

# Предпросмотр
.opencode/scripts/update-models.sh -n

# Включить embedding-модели
.opencode/scripts/update-models.sh --with-embed

# Фильтрация
.opencode/scripts/update-models.sh --include "qwen*" --exclude "*embed"

# Задать модель по умолчанию
.opencode/scripts/update-models.sh --default-model qwen2.5-coder:7b
```

Поддерживаемые провайдеры: Ollama, LM Studio, vLLM, llama.cpp, LocalAI, TGWUI, Jan, GPT4All, TGI, OpenAI.

---

## Граф зависимостей Skills

```
go-master ──→ api-design-master ──→ security-master
    ↓                                      ↓
docker-master ──→ kubernetes-master ──→ monitoring-master
    ↓                    ↓
ci-cd-master ────────────┘

python-master ──→ testing-master ──→ code-review-master
     ↓                  ↓
docker-master ─────→ database-master

typescript-master ──→ react-master ──→ web-performance-master
     ↓                     ↓
testing-master ─────→ nextjs-master

mobile-master ──→ security-master
     ↓                ↓
testing-master ──→ web-security-master

microservices-master ──→ monitoring-master
        ↓
api-design-master

data-engineering-master ──→ database-master
        ↓
docker-master

git-master ──→ code-review-master ──→ docs-master
```

---

## CI/CD

GitHub Actions workflow автоматически валидирует все skills при push/PR:

- Валидация frontmatter
- Проверка обязательных секций
- Валидация формата имён
- Проверка закрытия code blocks
- Тесты generate_opencode_config.sh
- Проверка синтаксиса Markdown

---

## Структура репозитория

```
ocskills/
├── opencode.json                    # Главный конфиг
├── README.md                        # Основная документация
├── CONTRIBUTING.md                  # Гайд для контрибьюторов
├── REGISTRY.md                      # Каталог skills
├── generate_opencode_config.sh                # Установщик skills
├── docs/
│   ├── ECOSYSTEM.md                 # Полная документация (EN)
│   └── ECOSYSTEM.ru.md              # Полная документация (RU)
├── .opencode/
│   ├── skills/                      # 25 skills
│   ├── commands/                    # 10 slash commands
│   ├── rules/                       # 5 rules files
│   ├── agents/                      # 6 custom agents
│   ├── scripts/                     # 9 utility scripts
│   ├── templates/                   # 6 project templates
│   ├── prompts/                     # 4 agent prompts
│   └── plans/                       # Implementation plans
└── .github/
    ├── workflows/                   # CI/CD workflows
    ├── ISSUE_TEMPLATE/              # Issue templates
    └── PULL_REQUEST_TEMPLATE.md     # PR template
```

---

## Решение проблем

### Skills не загружаются

```bash
# Проверить окружение
.opencode/scripts/doctor.sh

# Проверить валидность skills
.opencode/scripts/validate-skills.sh

# Обновить skills
.opencode/scripts/update-skills.sh
```

### opencode.json невалиден

```bash
# Перегенерировать
.opencode/scripts/update-opencode-config.sh --force

# Проверить JSON
python3 -c "import json; json.load(open('opencode.json'))"
```

### Плагины не работают

```bash
# Проверить окружение плагинов
.opencode/scripts/install-plugins.sh doctor

# Переустановить плагин
.opencode/scripts/install-plugins.sh remove <name>
.opencode/scripts/install-plugins.sh install <name>
```

---

## Лицензия

MIT
