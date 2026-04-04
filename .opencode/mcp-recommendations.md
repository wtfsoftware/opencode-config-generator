# MCP Server Recommendations for opencode

## Recommended MCP Servers

### Core Development

| Server | Purpose | Install | Config |
|--------|---------|---------|--------|
| **Filesystem** | Safe file operations | `npx -y @modelcontextprotocol/server-filesystem` | Restrict to project directories |
| **GitHub** | Issues, PRs, repos | `npx -y @modelcontextprotocol/server-github` | Needs GITHUB_TOKEN |
| **Git** | Extended git operations | `npx -y @modelcontextprotocol/server-git` | Read-only recommended |

### Data & Database

| Server | Purpose | Install | Config |
|--------|---------|---------|--------|
| **PostgreSQL** | Direct SQL queries | `npx -y @modelcontextprotocol/server-postgres` | Read-only connection for safety |
| **SQLite** | SQLite database access | `npx -y @modelcontextprotocol/server-sqlite` | Restrict to project DBs |

### Web & Research

| Server | Purpose | Install | Config |
|--------|---------|---------|--------|
| **Brave Search** | Web search | `npx -y @modelcontextprotocol/server-brave-search` | Needs BRAVE_API_KEY |
| **Puppeteer** | Browser automation, screenshots | `npx -y @modelcontextprotocol/server-puppeteer` | Headless mode |
| **Fetch** | Web content fetching | Built-in to opencode | No config needed |

### Reasoning & Analysis

| Server | Purpose | Install | Config |
|--------|---------|---------|--------|
| **Sequential Thinking** | Chain-of-thought reasoning | `npx -y @modelcontextprotocol/server-sequential-thinking` | No config needed |
| **Memory** | Persistent context across sessions | `npx -y @modelcontextprotocol/server-memory` | Local storage |

## Example opencode.json Configuration

```json
{
  "mcp": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "$GITHUB_TOKEN"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/projects"]
    },
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    }
  }
}
```

## Per-Project Recommendations

### ainet_preprocessor (Go, LLM Proxy)
- `filesystem` — navigate large codebase
- `github` — manage issues/PRs
- `sequential-thinking` — complex architecture decisions
- `postgresql` — query analytics data

### dynamic (Python, CAD)
- `filesystem` — manage generated CAD files
- `brave-search` — research acoustic engineering
- `sequential-thinking` — complex mathematical optimization

### ebu / AutoDiag (Python, Vehicle Diagnostics)
- `sequential-thinking` — protocol analysis
- `github` — project management
- `filesystem` — manage DTC databases

### Extensions (JavaScript, Browser Extensions)
- `github` — release management
- `filesystem` — manage build artifacts
- `puppeteer` — test extension behavior

### karma (C++, JUCE Audio Plugin)
- `filesystem` — manage audio samples/presets
- `sequential-thinking` — algorithm design
- `git` — branch management

### sparkle (Kotlin, Android P2P)
- `filesystem` — manage Android project
- `github` — release management
- `sequential-thinking` — crypto protocol design

### opencode_config_generator (Bash)
- `filesystem` — manage generated configs
- `git` — version control
- `github` — releases
