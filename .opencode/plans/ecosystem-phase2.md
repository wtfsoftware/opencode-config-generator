# План расширения экосистемы ocskills

## 1. opencode.json — главный конфиг
- Подключает все rules, agents, commands
- Настраивает permissions
- Конфигурирует MCP-серверы
- Определяет модели

## 2. Project Templates (6 штук)
| Шаблон | Для проектов |
|--------|-------------|
| `templates/go.json` | ainet_preprocessor |
| `templates/python.json` | dynamic, ebu |
| `templates/javascript.json` | Extensions |
| `templates/cpp.json` | karma |
| `templates/kotlin.json` | sparkle |
| `templates/bash.json` | opencode_config_generator |

## 3. Prompts Directory
- `prompts/code-review.txt`
- `prompts/architecture.txt`
- `prompts/security.txt`
- `prompts/testing.txt`
- `prompts/documentation.txt`

## 4. CI/CD для skills репозитория
- Валидация frontmatter всех SKILL.md
- Проверка структуры файлов
- Линтинг markdown
- Тестирование install-skills.sh

## 5. README для ocskills
- Обзор всей экосистемы
- Quick start guide
- Таблица всех компонентов
- Инструкция по тиражированию

## 6. GitHub Templates
- `ISSUE_TEMPLATE/bug_report.md`
- `ISSUE_TEMPLATE/feature_request.md`
- `PULL_REQUEST_TEMPLATE.md`
- `CONTRIBUTING.md`

## 7. Pre-commit Hooks для репозитория
- Проверка frontmatter
- Валидация структуры SKILL.md
- Проверка имен файлов
