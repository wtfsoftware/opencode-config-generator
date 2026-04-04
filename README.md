# ocskills

Complete skills ecosystem for [opencode](https://opencode.ai) — 25 skills, 10 commands, 6 agents, 5 rules, and utility scripts.

## Quick Start

```bash
# Install all skills globally (available in every project)
./generate_opencode_config.sh --all ~/.config/opencode

# Install specific category
./generate_opencode_config.sh --category frontend ~/.config/opencode

# Install to current project
./generate_opencode_config.sh --all .
```

## What's Included

### Skills (25)

| Category | Skills |
|----------|--------|
| **Frontend** (6) | react, nextjs, ui-design, web-performance, web-security, mobile |
| **Language** (4) | typescript, python, go, rust |
| **Backend** (4) | api-design, database, security, data-engineering |
| **DevOps** (5) | docker, ci-cd, kubernetes, cloud-aws, monitoring |
| **Architecture** (1) | microservices |
| **Testing** (1) | testing |
| **Collaboration** (2) | code-review, git |
| **Documentation** (1) | docs |
| **Game Dev** (1) | game-dev |

### Slash Commands (10)

| Command | Description |
|---------|-------------|
| `/review` | Code review with quality checklist |
| `/explain` | Detailed code explanation |
| `/test-gen` | Generate comprehensive tests |
| `/refactor` | Refactoring suggestions |
| `/diagram` | Mermaid architecture diagrams |
| `/docstring` | Auto-generate documentation |
| `/security-audit` | Security vulnerability scan |
| `/changelog` | Generate from git history |
| `/commit` | Generate commit message |
| `/architect` | Architecture analysis |

### Custom Agents (6)

| Agent | Role |
|-------|------|
| `architect` | System architecture analysis |
| `security-auditor` | Security audits |
| `test-engineer` | Test writing and quality |
| `devops-engineer` | Infrastructure and CI/CD |
| `tech-writer` | Technical documentation |
| `performance-engineer` | Performance optimization |

### Rules (5)

- `clean-code.md` — Clean code principles
- `security-rules.md` — Mandatory security checks
- `testing-standards.md` — Testing standards
- `commit-conventions.md` — Conventional Commits
- `documentation-standards.md` — Documentation standards

### Utility Scripts (12)

| Script | Purpose |
|--------|---------|
| `generate_opencode_config.sh` | Install skills globally or per-project |
| `update-config.sh` | Master updater — project config + models |
| `update-project-config.sh` | Intelligent project config generator |
| `update-models.sh` | Scan LLM providers, update models section |
| `install-plugins.sh` | Manage ecosystem plugins |
| `apply-project-configs.sh` | Apply opencode.json to all projects |
| `doctor.sh` | Diagnose OpenCode environment |
| `validate-skills.sh` | Validate SKILL.md structure |
| `project-analyzer.sh` | Auto-detect project stack, recommend skills |
| `config-generator.sh` | Generate opencode.json for a project |
| `update-skills.sh` | Update skills from this repository |
| `smoke-test.sh` | Test suite for update-models.sh |

## Project Structure

```
ocskills/
├── opencode.json                    # Main config for this repo
├── README.md                        # This file
├── CONTRIBUTING.md                  # Contributor guide
├── REGISTRY.md                      # Skills catalog
├── generate_opencode_config.sh                # Skills installer
├── docs/
│   ├── ECOSYSTEM.md                 # Full ecosystem docs (EN)
│   └── ECOSYSTEM.ru.md             # Full ecosystem docs (RU)
├── .opencode/
│   ├── skills/                      # 25 skills
│   ├── commands/                    # 10 slash commands
│   ├── rules/                       # 5 rules files
│   ├── agents/                      # 6 custom agents
│   ├── scripts/                     # 12 utility scripts
│   │   ├── update-config.sh         # Master updater
│   │   ├── update-project-config.sh # Project config generator
│   │   ├── update-models.sh         # LLM provider scanner
│   │   ├── update-models.ps1        # PowerShell version
│   │   ├── adapters/                # Provider adapters (7)
│   │   └── metadata.json            # Model metadata
│   ├── templates/                   # 6 project templates
│   └── prompts/                     # 4 agent prompts
└── .github/
    ├── workflows/                   # CI/CD workflows
    ├── ISSUE_TEMPLATE/              # Issue templates
    └── PULL_REQUEST_TEMPLATE.md     # PR template
```

## Installation

### Global (Recommended)

Skills available in every opencode project:

```bash
./generate_opencode_config.sh --all ~/.config/opencode
```

### Per-Project

Skills available only in the current project:

```bash
./generate_opencode_config.sh --all /path/to/project
```

### By Category

```bash
./generate_opencode_config.sh --category frontend ~/.config/opencode
./generate_opencode_config.sh --category backend ~/.config/opencode
./generate_opencode_config.sh --category devops ~/.config/opencode
```

### Interactive

```bash
./generate_opencode_config.sh
```

## Project Templates

Pre-configured `opencode.json` for different project types:

| Template | Use For |
|----------|---------|
| `templates/go.json` | Go projects (ainet_preprocessor) |
| `templates/python.json` | Python projects (dynamic, ebu) |
| `templates/javascript.json` | JS/TS projects (Extensions) |
| `templates/cpp.json` | C++ projects (karma) |
| `templates/kotlin.json` | Android/Kotlin (sparkle) |
| `templates/bash.json` | Shell scripts (opencode_config_generator) |

Copy and customize:
```bash
cp .opencode/templates/python.json /path/to/project/opencode.json
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on creating new skills, commands, and agents.

## License

MIT
