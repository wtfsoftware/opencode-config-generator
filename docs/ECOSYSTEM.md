# OpenCode Ecosystem Documentation

Complete ecosystem for OpenCode — skills, commands, agents, rules, plugins, and utilities.

## Quick Start

```bash
# 1. Clone this repository
git clone https://github.com/your-org/ocskills.git
cd ocskills

# 2. Install all skills globally
./generate_opencode_config.sh --all ~/.config/opencode

# 3. Apply configs to your projects
.opencode/scripts/apply-project-configs.sh

# 4. Verify your environment
.opencode/scripts/doctor.sh
```

---

## Skills (25)

Skills are `SKILL.md` files with instructions that OpenCode discovers and loads on-demand.

### Installation

```bash
# All skills globally
./generate_opencode_config.sh --all ~/.config/opencode

# By category
./generate_opencode_config.sh --category frontend ~/.config/opencode
./generate_opencode_config.sh --category backend ~/.config/opencode
./generate_opencode_config.sh --category devops ~/.config/opencode

# To a specific project
./generate_opencode_config.sh --all /path/to/project

# Interactive mode
./generate_opencode_config.sh
```

### Frontend (6)

| Skill | Description |
|-------|-------------|
| `react-master` | Hooks, components, state management, performance, accessibility, Suspense, React 19 |
| `nextjs-master` | App Router, SSR/SSG, caching, API routes, middleware, image optimization |
| `ui-design-master` | Visual hierarchy, layout, typography, color theory, animations, accessibility |
| `web-performance-master` | Core Web Vitals, bundle optimization, CDN, caching, measurement |
| `web-security-master` | CSP, XSS, CSRF, secure cookies, SRI, HTTPS, security headers |
| `mobile-master` | React Native, navigation, native modules, offline support, push notifications |

### Language (4)

| Skill | Description |
|-------|-------------|
| `typescript-master` | Generics, utility types, type guards, discriminated unions, strict mode |
| `python-master` | Type hints, async, dataclasses, Pydantic, pytest, FastAPI, Flask, pandas, multiprocessing |
| `go-master` | Idioms, interfaces, goroutines, channels, context, error handling, HTTP servers |
| `rust-master` | Ownership, lifetimes, traits, error handling, smart pointers, async, cargo |

### Backend (4)

| Skill | Description |
|-------|-------------|
| `api-design-master` | REST, GraphQL, gRPC, WebSocket, pagination, versioning, OpenAPI, webhooks |
| `database-master` | Schema design, indexes, migrations, ORM, replication, sharding, query optimization |
| `security-master` | OWASP Top 10, auth (JWT, OAuth2), authorization, encryption, input validation |
| `data-engineering-master` | ETL/ELT, Spark, Airflow, dbt, data mesh, CDC, data contracts, observability |

### DevOps (5)

| Skill | Description |
|-------|-------------|
| `docker-master` | Dockerfile best practices, multi-stage builds, compose, security, optimization |
| `ci-cd-master` | GitHub Actions, caching, deployment strategies, environments, secrets |
| `kubernetes-master` | Pods, deployments, Helm, operators, networking, RBAC, GitOps |
| `cloud-aws-master` | EC2, S3, Lambda, IAM, RDS, CloudFormation, CDK, cost optimization |
| `monitoring-master` | Logs/metrics/traces, SLO/SLI, alerting, Grafana, Prometheus, incident response |

### Architecture (1)

| Skill | Description |
|-------|-------------|
| `microservices-master` | Decomposition, saga, API gateway, event-driven, service mesh, distributed tracing |

### Testing (1)

| Skill | Description |
|-------|-------------|
| `testing-master` | Testing pyramid, TDD, mocking, E2E (Playwright), coverage, CI optimization |

### Collaboration (2)

| Skill | Description |
|-------|-------------|
| `code-review-master` | Review checklists, code smells, refactoring patterns, feedback techniques |
| `git-master` | Workflows, rebase, bisect, hooks, submodules, troubleshooting |

### Documentation (1)

| Skill | Description |
|-------|-------------|
| `docs-master` | README, API docs, ADR, changelog, contributing guides, Mermaid diagrams |

### Game Development (1)

| Skill | Description |
|-------|-------------|
| `game-dev-master` | Game loop, ECS, physics, AI (state machines, behavior trees, A*), optimization |

---

## Slash Commands (10)

Custom commands for repetitive tasks. Triggered with `/`.

| Command | Description | Arguments |
|---------|-------------|-----------|
| `/review` | Auto code review with quality checklist | — |
| `/explain` | Detailed explanation of selected code | — |
| `/test-gen` | Generate comprehensive tests for a file | — |
| `/refactor` | Refactoring suggestions with examples | — |
| `/diagram` | Generate Mermaid diagrams from code | — |
| `/docstring` | Auto-generate docstrings/JSDoc | — |
| `/security-audit` | Scan code for vulnerabilities | — |
| `/changelog` | Generate changelog from git history | — |
| `/commit` | Generate commit message from staged changes | — |
| `/architect` | Analyze project architecture | — |

### Usage

```
/review          # Review current file
/explain         # Explain selected code
/test-gen        # Generate tests
/commit          # Create commit message
/changelog       # Generate changelog
```

---

## Custom Agents (6)

Specialized AI assistants for specific tasks.

| Agent | Mode | Description | Access |
|-------|------|-------------|--------|
| `architect` | subagent | System architecture analysis | Read-only + grep/find/git |
| `security-auditor` | subagent | Security audits | Read-only + grep/find/git |
| `test-engineer` | subagent | Test writing and quality | Edit (ask) + test commands |
| `devops-engineer` | subagent | Infrastructure and CI/CD | Edit (ask) + docker/k8s/git |
| `tech-writer` | subagent | Technical documentation | Edit (ask) + grep/find/git |
| `performance-engineer` | subagent | Performance optimization | Edit (ask) + build/lighthouse |

### Invoking Agents

```
# Via @mention
@architect analyze the project architecture
@security-auditor check this code for vulnerabilities
@test-engineer write tests for this file

# Via Tab (primary agents)
# Cycle between Build and Plan agents
```

---

## Rules (5)

Global rules applied to all OpenCode sessions.

| Rule | Description |
|------|-------------|
| `clean-code.md` | Naming, functions, structure, comments, simplicity, error handling |
| `security-rules.md` | Input validation, auth, data protection, web security, dependencies |
| `testing-standards.md` | Testing pyramid, test structure, mocking, coverage, CI |
| `commit-conventions.md` | Conventional Commits format, examples, rules |
| `documentation-standards.md` | README, API docs, ADR, changelog, contributing |

---

## Plugins (30+)

Plugins extend OpenCode functionality. There are two ways to install them:

### Installation Methods

#### 1. npm plugins (recommended)

Add to your `opencode.json`:

```json
{
  "plugin": [
    "opencode-wakatime",
    "opencode-worktree",
    "@my-org/custom-plugin"
  ]
}
```

OpenCode automatically installs these using Bun at startup. Packages are cached in `~/.cache/opencode/node_modules/`.

#### 2. Local plugins

Place `.js` or `.ts` files in:
- `~/.config/opencode/plugins/` — global plugins
- `.opencode/plugins/` — project-level plugins

For external dependencies, add a `package.json` to your config directory:

```json
{
  "dependencies": {
    "shescape": "^2.1.0"
  }
}
```

OpenCode runs `bun install` at startup.

### Managing Plugins

```bash
# List all available plugins
.opencode/scripts/install-plugins.sh list

# By category
.opencode/scripts/install-plugins.sh list auth
.opencode/scripts/install-plugins.sh list agents

# Install (adds to opencode.json)
.opencode/scripts/install-plugins.sh install wakatime
.opencode/scripts/install-plugins.sh install worktree

# Update (clears cache)
.opencode/scripts/install-plugins.sh update wakatime
.opencode/scripts/install-plugins.sh update-all

# Remove
.opencode/scripts/install-plugins.sh remove wakatime

# Status
.opencode/scripts/install-plugins.sh status

# Diagnostics
.opencode/scripts/install-plugins.sh doctor
```

### Creating a Plugin

```js
// .opencode/plugins/my-plugin.js
export const MyPlugin = async ({ project, client, $, directory, worktree }) => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool === "read" && output.args.filePath.includes(".env")) {
        throw new Error("Do not read .env files");
      }
    },
  };
};
```

Plugins receive: `project`, `client`, `$` (Bun shell API), `directory`, `worktree`.

### Available Events

| Category | Events |
|----------|--------|
| Command | `command.executed` |
| File | `file.edited`, `file.watcher.updated` |
| Message | `message.updated`, `message.removed`, `message.part.updated` |
| Permission | `permission.asked`, `permission.replied` |
| Session | `session.created`, `session.idle`, `session.compacted`, `session.error` |
| Tool | `tool.execute.before`, `tool.execute.after` |
| Shell | `shell.env` |
| TUI | `tui.prompt.append`, `tui.command.execute`, `tui.toast.show` |

### Plugin Categories

#### Auth (4)
| Plugin | Description |
|--------|-------------|
| `openai-codex-auth` | Use ChatGPT Plus/Pro subscription instead of API credits |
| `gemini-auth` | Use existing Gemini plan instead of API billing |
| `antigravity-auth` | Use Antigravity's free models |
| `google-antigravity-auth` | Google Antigravity OAuth with Search support |

#### Dev Tools (4)
| Plugin | Description |
|--------|-------------|
| `devcontainers` | Multi-branch devcontainer isolation |
| `daytona` | Run sessions in isolated Daytona sandboxes |
| `worktree` | Zero-friction git worktrees for OpenCode |
| `scheduler` | Schedule recurring jobs with cron syntax |

#### Performance (5)
| Plugin | Description |
|--------|-------------|
| `dynamic-context-pruning` | Optimize token usage by pruning tool outputs |
| `vibeguard` | Redact secrets/PII before LLM calls |
| `morph` | Fast Apply editing, WarpGrep search, context compaction |
| `shell-strategy` | Prevent hangs from TTY-dependent operations |
| `pty` | Run background processes in PTY with interactive input |

#### Agents & Orchestration (5)
| Plugin | Description |
|--------|-------------|
| `background-agents` | Background agents with async delegation |
| `subtask2` | Extend commands with orchestration flow control |
| `workspace` | Multi-agent orchestration harness (16 components) |
| `skillful` | Lazy load prompts with skill discovery |
| `supermemory` | Persistent memory across sessions |

#### Productivity (4)
| Plugin | Description |
|--------|-------------|
| `wakatime` | Track OpenCode usage with Wakatime |
| `notificator` | Desktop notifications and sound alerts |
| `notifier` | Notifications for permission/error events |
| `zellij-namer` | AI-powered Zellij session naming |

#### Monitoring (2)
| Plugin | Description |
|--------|-------------|
| `sentry-monitor` | Trace and debug AI agents with Sentry |
| `helicone-session` | Inject Helicone session headers |

#### Search & Web (2)
| Plugin | Description |
|--------|-------------|
| `websearch-cited` | Native websearch with Google grounded citations |
| `firecrawl` | Web scraping, crawling, and search |

#### Code & Type (1)
| Plugin | Description |
|--------|-------------|
| `type-inject` | Auto-inject TypeScript/Svelte types into file reads |

#### UI (1)
| Plugin | Description |
|--------|-------------|
| `plannotator` | Interactive plan review with visual annotation |

#### Workflow (2)
| Plugin | Description |
|--------|-------------|
| `micode` | Structured Brainstorm → Plan → Implement workflow |
| `octto` | Interactive browser UI for AI brainstorming |

### Recommended Plugins by Project

| Project | Recommended Plugins |
|---------|-------------------|
| ainet_preprocessor | worktree, scheduler, background-agents, sentry-monitor |
| dynamic / ebu | type-inject, vibeguard, notificator |
| Extensions | websearch-cited, md-table-formatter, wakatime |
| karma | pty, shell-strategy, notificator |
| sparkle | vibeguard, plannotator, micode |
| opencode_config_generator | skillful, supermemory, worktree |

---

## Project Templates

Pre-configured `opencode.json` for different project types.

| Template | Projects | Key Skills |
|----------|----------|------------|
| `go.json` | ainet_preprocessor | go, api-design, security, docker, k8s, monitoring |
| `python.json` | dynamic, ebu | python, testing, docker, security |
| `javascript.json` | Extensions | typescript, react, testing, web-security, ci-cd |
| `cpp.json` | karma | code-review, testing, git |
| `kotlin.json` | sparkle | mobile, security, testing |
| `bash.json` | opencode_config_generator | git, testing, docs |

### Applying Templates

```bash
# To all projects
.opencode/scripts/apply-project-configs.sh

# With force overwrite
.opencode/scripts/apply-project-configs.sh --force

# Preview only
.opencode/scripts/apply-project-configs.sh --dry-run
```

---

## Utility Scripts (12)

| Script | Description |
|--------|-------------|
| `generate_opencode_config.sh` | Install skills globally or per-project |
| `update-config.sh` | Master updater — project config + models |
| `update-project-config.sh` | Intelligent project config generator |
| `update-models.sh` | Scan LLM providers, update models section |
| `install-plugins.sh` | Manage ecosystem plugins (install/update/remove) |
| `apply-project-configs.sh` | Apply opencode.json templates to all projects |
| `doctor.sh` | Diagnose OpenCode environment |
| `validate-skills.sh` | Validate SKILL.md structure |
| `project-analyzer.sh` | Auto-detect project stack, recommend skills |
| `config-generator.sh` | Generate opencode.json for a project |
| `update-skills.sh` | Update skills from this repository |
| `smoke-test.sh` | Test suite for update-models.sh |

### update-config.sh — Master Script

The main entry point for updating your OpenCode configuration:

```bash
# Update everything (project config + models)
.opencode/scripts/update-config.sh all

# Update only project config (skills, commands, agents, permissions)
.opencode/scripts/update-config.sh project

# Update only models section (scan LLM providers)
.opencode/scripts/update-config.sh models

# Interactive model selection
.opencode/scripts/update-config.sh models --interactive

# Preview changes
.opencode/scripts/update-config.sh all --dry-run

# Check current status
.opencode/scripts/update-config.sh status
```

### update-models.sh — LLM Provider Scanner

Scans local and remote LLM providers (Ollama, LM Studio, vLLM, llama.cpp, LocalAI, etc.) and generates the `models` section of `opencode.json`:

```bash
# Scan local Ollama
.opencode/scripts/update-models.sh

# With remote server
.opencode/scripts/update-models.sh -r http://192.168.1.100:11434

# Interactive selection
.opencode/scripts/update-models.sh -i

# Preview only
.opencode/scripts/update-models.sh -n

# Include embedding models
.opencode/scripts/update-models.sh --with-embed

# Filter models
.opencode/scripts/update-models.sh --include "qwen*" --exclude "*embed"

# Set default model
.opencode/scripts/update-models.sh --default-model qwen2.5-coder:7b
```

Supported providers: Ollama, LM Studio, vLLM, llama.cpp, LocalAI, TGWUI, Jan, GPT4All, TGI, OpenAI.

---

## Skill Dependency Graph

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

GitHub Actions workflow automatically validates all skills on push/PR:

- Frontmatter validation
- Required sections check
- Name format validation
- Code block closure check
- Installer script tests
- Markdown syntax check

---

## Repository Structure

```
ocskills/
├── opencode.json                    # Main config for this repo
├── README.md                        # Root documentation
├── CONTRIBUTING.md                  # Contributor guide
├── REGISTRY.md                      # Skills catalog
├── generate_opencode_config.sh                # Skills installer
├── docs/
│   └── ECOSYSTEM.md                 # Full ecosystem documentation
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

## Troubleshooting

### Skills not loading

```bash
# Check environment
.opencode/scripts/doctor.sh

# Validate skills
.opencode/scripts/validate-skills.sh

# Update skills
.opencode/scripts/update-skills.sh
```

### Invalid opencode.json

```bash
# Regenerate
.opencode/scripts/update-opencode-config.sh --force

# Validate JSON
python3 -c "import json; json.load(open('opencode.json'))"
```

### Plugins not working

```bash
# Check plugin environment
.opencode/scripts/install-plugins.sh doctor

# Reinstall plugin
.opencode/scripts/install-plugins.sh remove <name>
.opencode/scripts/install-plugins.sh install <name>
```

---

## License

MIT
