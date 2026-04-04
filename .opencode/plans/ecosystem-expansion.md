# План расширения экосистемы opencode

## 1. Custom Slash Commands (10 штук)
**Путь:** `~/.config/opencode/commands/`

| Команда | Файл | Описание |
|---------|------|----------|
| `/review` | `review.md` | Авто-ревью текущего файла |
| `/explain` | `explain.md` | Объяснение выбранного кода |
| `/test-gen` | `test-gen.md` | Генерация тестов для файла |
| `/refactor` | `refactor.md` | Предложения по рефакторингу |
| `/diagram` | `diagram.md` | Mermaid-диаграммы из кода |
| `/docstring` | `docstring.md` | Автогенерация docstrings |
| `/security-audit` | `security-audit.md` | Поиск уязвимостей |
| `/changelog` | `changelog.md` | Changelog из git history |
| `/commit` | `commit.md` | Commit message из staged changes |
| `/architect` | `architect.md` | Анализ архитектуры |

## 2. Global Rules Files (5 штук)
**Путь:** `~/.config/opencode/rules/`

| Rule | Файл | Описание |
|------|------|----------|
| Clean Code | `clean-code.md` | Принципы чистого кода |
| Security | `security-rules.md` | Обязательные проверки безопасности |
| Testing | `testing-standards.md` | Стандарты тестирования |
| Commits | `commit-conventions.md` | Conventional Commits |
| Documentation | `documentation-standards.md` | Стандарты документации |

## 3. Custom Agents (6 штук)
**Путь:** `~/.config/opencode/agents/`

| Агент | Файл | Роль | Skills |
|-------|------|------|--------|
| architect | `architect.md` | Архитектор | microservices, database, api-design |
| security-auditor | `security-auditor.md` | Аудитор безопасности | security, web-security |
| test-engineer | `test-engineer.md` | Инженер по тестированию | testing, code-review |
| devops-engineer | `devops-engineer.md` | DevOps-инженер | docker, kubernetes, ci-cd, cloud-aws |
| tech-writer | `tech-writer.md` | Технический писатель | docs, api-design |
| performance-engineer | `performance-engineer.md` | Инженер по производительности | web-performance, database, monitoring |

## 4. MCP Server Recommendations
**Путь:** `~/.config/opencode/mcp-recommendations.md`

Каталог рекомендуемых MCP-серверов с конфигурацией.

## 5. Utility Scripts (4 штуки)
**Путь:** `~/.config/opencode/scripts/`

| Скрипт | Описание |
|--------|----------|
| `update-skills.sh` | Обновление skills из репозитория |
| `validate-skills.sh` | Валидация frontmatter и структуры |
| `project-analyzer.sh` | Автоопределение стека и推荐 skills |
| `config-generator.sh` | Генерация opencode.json под проект |

## Итого: 26 файлов
