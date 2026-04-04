# План: Конфиги проектов + Doctor + MCP Auto-Installer

## 1. Конфиги для реальных проектов (7 штук)
Применить opencode.json шаблоны к каждому проекту:
- ainet_preprocessor → go.json (+ docker, k8s, monitoring skills)
- dynamic → python.json (+ fastapi, testing skills)
- ebu → python.json (+ mobile, security skills)
- Extensions → javascript.json (+ ci-cd, web-security skills)
- karma → cpp.json (+ testing skills)
- sparkle → kotlin.json (+ security skills)
- opencode_config_generator → bash.json

## 2. Doctor Command
Диагностика opencode-окружения:
- Проверка бинарника opencode
- Валидация skills (global + project)
- Проверка commands, rules, agents
- Валидация opencode.json
- Проверка MCP серверов
- Проверка install скриптов

## 3. MCP Auto-Installer
Установка и настройка MCP-серверов:
- Реестр всех доступных плагинов (30+)
- Установка/обновление/удаление
- Рекомендации по проектам
- Doctor для плагинов
