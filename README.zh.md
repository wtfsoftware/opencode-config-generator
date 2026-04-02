# OpenCode 配置生成器（Ollama）

从本地和远程 Ollama 服务器生成 `opencode.json` 配置。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

[English](README.md) | [Русский](README.ru.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Español](README.es.md) | 中文 | [日本語](README.ja.md) | [Português](README.pt.md) | [Italiano](README.it.md) | [한국어](README.ko.md) | [العربية](README.ar.md) | [Nederlands](README.nl.md) | [Українська](README.ua.md)

**v1.4.0** | [规范文档](SPECIFICATION.md) | [开发文档](DEVELOPMENT.md) | [免责声明](DISCLAIMER.md)

## 功能特性

- **多提供商支持**：Ollama、LM Studio、vLLM、llama.cpp、LocalAI、text-generation-webui、Jan.ai、GPT4All
- 根据端口自动检测提供商，或使用 `-p` 指定
- 通过提供商 API 自动发现所有模型
- 过滤 embedding 模型（nomic-bert、LM Studio type 字段等）
- 获取精确的上下文长度（Ollama `/api/show`、llama.cpp `/props`、LM Studio 丰富元数据）
- 同时支持多个不同提供商的服务器
- 交互式模型选择（含「全部模型」选项）
- 基于 glob 模式的 include/exclude 过滤
- 自动检测 `small_model`（最小的非 embed 模型，用于标题生成）
- 预览模式（dry-run，不写入文件）
- 支持 `OLLAMA_HOST` 环境变量

## 要求

| 组件 | Bash 脚本 | PowerShell 脚本 |
|------|:---------:|:---------------:|
| curl | 必需 | 不需要 |
| Python 3 | 必需 | 不需要 |
| PowerShell 5.1+ | 不适用 | 必需 |

## 快速开始

```bash
# Bash (Linux/macOS/WSL/Git Bash)
./generate_opencode_config.sh

# PowerShell (Windows)
.\Generate-OpenCodeConfig.ps1
```

## 使用方法

### Bash

```bash
# 仅本地 Ollama（使用 $OLLAMA_HOST 或 http://localhost:11434）
./generate_opencode_config.sh

# 使用一个远程服务器
./generate_opencode_config.sh -r http://192.168.1.100:11434

# 使用多个远程服务器
./generate_opencode_config.sh -r http://gpu1:11434 -r http://gpu2:11434

# 交互式模型选择
./generate_opencode_config.sh -i

# 仅 qwen 模型
./generate_opencode_config.sh --include "qwen*"

# 排除 codestral
./generate_opencode_config.sh --exclude "codestral*"

# 包含 embedding 模型
./generate_opencode_config.sh --with-embed

# 预览不写入文件
./generate_opencode_config.sh -n

# 添加 num_ctx 到 provider options（用于 tool calling）
./generate_opencode_config.sh --num-ctx 32768

# 显式设置默认模型
./generate_opencode_config.sh --default-model qwen2.5-coder:7b

# 合并到现有配置（更新模型，保留其他设置）
./generate_opencode_config.sh --merge

# 跳过 /api/show 调用（更快，使用硬编码的上下文限制）
./generate_opencode_config.sh --no-context-lookup

# 禁用上下文查找缓存
./generate_opencode_config.sh --no-cache

# 写入全局配置
./generate_opencode_config.sh -o ~/.config/opencode/opencode.json
```

### PowerShell

```powershell
# 仅本地 Ollama
.\Generate-OpenCodeConfig.ps1

# 使用远程服务器
.\Generate-OpenCodeConfig.ps1 -RemoteOllamaUrl "http://192.168.1.100:11434"
.\Generate-OpenCodeConfig.ps1 -RemoteOllamaUrl "http://gpu1:11434","http://gpu2:11434"

# 交互式选择
.\Generate-OpenCodeConfig.ps1 -Interactive

# 仅 qwen 模型
.\Generate-OpenCodeConfig.ps1 -Include "qwen*"

# 预览
.\Generate-OpenCodeConfig.ps1 -DryRun

# 使用 num_ctx
.\Generate-OpenCodeConfig.ps1 -NumCtx 32768

# 写入全局配置
.\Generate-OpenCodeConfig.ps1 -OutputFile "$env:USERPROFILE\.config\opencode\opencode.json"
```

## CLI 参考

### Bash

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `-l, --local URL` | 本地服务器 URL | `$OLLAMA_HOST` 或 `http://localhost:11434` |
| `-r, --remote URL` | 远程服务器 URL（可多次指定） | 无 |
| `-p, --provider NAME` | 提供商：ollama, lmstudio, vllm, llama-cpp, localai, tgwui, jan, gpt4all | 自动检测 |
| `-o, --output FILE` | 输出文件路径（`-` 表示 stdout） | `opencode.json` |
| `-n, --dry-run` | 输出到 stdout，不写入文件 | 关 |
| `-i, --interactive` | 交互式模型选择 | 关 |
| `--include PATTERN` | 包含匹配 glob 的模型（可多次指定） | 全部 |
| `--exclude PATTERN` | 排除匹配 glob 的模型（可多次指定） | 无 |
| `--with-embed` | 包含 embedding 模型 | 排除 |
| `--tools-only` | 仅包含支持 tool/function calling 的模型 | 关 |
| `--no-context-lookup` | 跳过 `/api/show`，使用硬编码限制 | 关 |
| `--num-ctx N` | provider options 的 `num_ctx`，0 表示省略 | `0` |
| `--merge` | 合并到现有配置（仅更新模型） | 关 |
| `--default-model ID` | 显式设置默认模型 | 自动 |
| `--small-model ID` | 显式设置 small 模型（用于标题生成） | 自动 |
| `--no-cache` | 禁用上下文查找缓存 | 关 |
| `-v, --version` | 显示版本 | |
| `-h, --help` | 显示帮助 | |

### PowerShell

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `-LocalOllamaUrl` | 本地 Ollama URL | `$OLLAMA_HOST` 或 `http://localhost:11434` |
| `-RemoteOllamaUrl` | 远程 URL（数组） | 无 |
| `-OutputFile` | 输出文件路径 | `opencode.json` |
| `-DryRun` | 输出到 stdout，不写入文件 | 关 |
| `-Interactive` | 交互式模型选择 | 关 |
| `-Include` | 包含模式（通配符，数组） | 全部 |
| `-Exclude` | 排除模式（通配符，数组） | 无 |
| `-WithEmbed` | 包含 embedding 模型 | 排除 |
| `-ToolsOnly` | 仅包含支持 tool/function calling 的模型 | 关 |
| `-NoContextLookup` | 跳过 `/api/show`，使用硬编码限制 | 关 |
| `-NumCtx` | provider options 的 `num_ctx`，0 表示省略 | `0` |
| `-Merge` | 合并到现有配置（仅更新模型） | 关 |
| `-DefaultModel` | 显式设置默认模型 | 自动 |
| `-SmallModel` | 显式设置 small 模型（用于标题生成） | 自动 |
| `-NoCache` | 禁用上下文查找缓存 | 关 |
| `-Version` | 显示版本 | |
| `-Help` | 显示帮助 | |

## 工作原理

1. 通过 `GET /api/tags` 从每个 Ollama 服务器获取模型列表
2. 根据 `families` 字段过滤 embedding 模型（`nomic-bert`、`bert` 等）
3. 按 include/exclude 模式过滤（glob 匹配）
4. 通过 `POST /api/show` 获取每个模型的上下文长度（并行，带缓存）
5. 去重多个服务器上的相同模型（保留第一个服务器的版本）
6. 交互式选择（如果使用 `-i`）：带编号列表和 `[0] 全部模型` 选项
7. 合并（如果使用 `--merge`）：保留现有配置设置和其他提供商
8. 自动检测 `small_model`：按参数量选择最小的非 embed 模型
9. 生成包含 Ollama 作为提供商的 `opencode.json`

## 生成的配置结构

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

### 字段说明

| 字段 | 说明 |
|------|------|
| `provider.ollama.options.baseURL` | Ollama OpenAI 兼容端点 |
| `provider.ollama.models.*.limit.context` | 模型的最大上下文窗口 |
| `provider.ollama.models.*.limit.output` | 最大输出 token（上限 16K） |
| `model` | 默认模型（第一个可用的） |
| `small_model` | 用于轻量任务的最小模型（标题生成） |

## 模型上下文检测

上下文长度按以下优先级确定：

1. **API 查找** — `POST /api/show` 返回 `model_info.*.context_length`（精确值）
2. **硬编码回退** — 按模型系列估算：

| 系列 | 默认上下文 |
|------|:---------:|
| qwen, qwen2 | 32,768 |
| llama | 8,192 |
| mistral, mixtral | 32,768 |
| deepseek | 65,536 |
| command, command-r | 131,072 |
| yi | 200,000 |
| gemma | 8,192 |
| phi | 4,096 |
| codestral | 32,768 |
| granite | 8,192 |
| other | 8,192 |

使用 `--no-context-lookup` 跳过 API 调用，仅使用硬编码值（更快）。

## Embedding 模型

Embedding 模型**默认被排除**，因为它们不支持 chat/tool calling。检测依据：

- 模型系列包含 `nomic-bert`、`bert`、`bert-moe`、`embed`、`embedding`
- 模型名称包含这些关键词

使用 `--with-embed` / `-WithEmbed` 来包含它们。

## Tool/Function Calling 过滤器

使用 `--tools-only` / `-ToolsOnly` 仅包含支持 tool/function calling 的模型：

```bash
./generate_opencode_config.sh --tools-only
```

检测分两个层级：
1. **精确检测** — LM Studio 通过 `/api/v1/models` 提供 `capabilities.tool_use`
2. **启发式检测** — 对于其他提供商，模型会与已知的支持 tool 的系列列表匹配（qwen2.5/3、llama3.x、mistral、mixtral、deepseek-r1/v3、command-r、phi3/4、gemma2/3、granite3.x）

不匹配任一检查的模型在启用 `--tools-only` 时会被排除。该列表可能需要随新模型系列发布而更新。

## 多提供商支持

支持 8 种本地推理提供商。提供商根据端口自动检测，或使用 `-p` 指定。

| 提供商 | 默认端口 | 丰富元数据 | 自动检测 |
|--------|:-------:|:---------:|:-------:|
| **Ollama** | 11434 | `/api/show`（上下文、系列） | ✅ |
| **LM Studio** | 1234 | `/api/v1/models`（类型、能力、上下文） | ✅ |
| **vLLM** | 8000 | 仅基础信息 | ✅ |
| **llama.cpp** | 8080 | `/props`（context_size） | ✅（作为 localai） |
| **LocalAI** | 8080 | 仅基础信息 | ✅ |
| **text-generation-webui** | 5000 | 仅基础信息 | ✅ |
| **Jan.ai** | 1337 | 仅基础信息 | ✅ |
| **GPT4All** | 4891 | 仅基础信息 | ✅ |

```bash
# 根据端口自动检测
./generate_opencode_config.sh -l http://localhost:1234       # LM Studio
./generate_opencode_config.sh -l http://localhost:8000       # vLLM

# 显式指定提供商
./generate_opencode_config.sh -l http://localhost:8080 -p llama-cpp

# Ollama + LM Studio 一起使用
./generate_opencode_config.sh -l http://localhost:11434 -r http://localhost:1234 -p lmstudio
```

每个提供商在 `opencode.json` 中作为独立的块出现：

```json
{
  "provider": {
    "ollama": { "name": "Ollama", "options": { "baseURL": "http://localhost:11434/v1" }, ... },
    "lmstudio": { "name": "LM Studio", "options": { "baseURL": "http://localhost:1234/v1" }, ... }
  }
}
```

## 上下文查找缓存

来自 `/api/show` 的上下文长度缓存在 `~/.cache/opencode-generator/`，按 URL 哈希存储。缓存 24 小时后过期。后续运行复用缓存值，仅获取新模型。使用 `--no-cache` 禁用。

## 合并模式

使用 `--merge` 更新现有 `opencode.json` 中的模型，而不覆盖其他设置（自定义提供商、主题、规则等）：

```bash
# 初始生成
./generate_opencode_config.sh -o opencode.json

# 手动添加自定义提供商、规则等

# 之后：仅更新模型，保留其他所有内容
./generate_opencode_config.sh --merge -o opencode.json
```

## 去重处理

如果同一模型存在于多个服务器上，每个副本会获得带服务器后缀的唯一名称：

```
qwen2.5-coder:7b                → 本地服务器（原始名称）
qwen2.5-coder:7b@gpu-server     → 第一个远程服务器
qwen2.5-coder:7b@gpu-server-2   → 同主机名的第二个远程服务器
```

两个版本都出现在 `/models` 中。摘要会显示哪些模型被添加了后缀。

## 环境变量

| 变量 | 说明 |
|------|------|
| `OLLAMA_HOST` | 本地 Ollama URL（Ollama 标准变量） |
| `XDG_CACHE_HOME` | 缓存目录基础路径 |

## 安装生成的配置

```bash
# 全局配置（所有项目）
cp opencode.json ~/.config/opencode/opencode.json

# 项目特定
cp opencode.json /path/to/project/opencode.json
```

## 故障排除

### "无法连接到 Ollama"

- 确保 Ollama 正在运行：`ollama serve`
- 检查 URL：`curl http://localhost:11434/api/tags`
- 如果使用自定义端口/主机，设置 `OLLAMA_HOST` 或使用 `-l`

### "Missing required dependencies: python3"

```bash
# Ubuntu/Debian
sudo apt install python3

# macOS
brew install python3

# Windows: 从 https://python.org 下载
```

### 上下文长度不正确

- 脚本默认使用 `/api/show` 获取精确值
- 如果 API 较慢，使用 `--no-context-lookup` 使用硬编码估算值
- 可在生成的 JSON 中手动覆盖

### Embedding 模型被意外包含/排除

- 检查 `ollama show <model>` 输出中的 families
- 使用 `--with-embed` 强制包含
- 使用 `--exclude "*embed*"` 按名称强制排除

### OpenCode 中出现 "Provider returned error"

- 部分 Ollama 模型不支持 tool calling — 尝试 `qwen2.5-coder` 或 `llama3.2`
- 如果 tools 失败，增加 `num_ctx`：`--num-ctx 32768`
- 确保模型已加载：`ollama run <model>`
