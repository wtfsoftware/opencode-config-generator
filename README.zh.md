# OpenCode Ollama 配置生成器

为 [OpenCode](https://opencode.ai) 自动生成 `opencode.json` 配置文件，基于本地和远程 Ollama 服务器的模型。

[English](README.md) | [Русский](README.ru.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Español](README.es.md) | 中文 | [日本語](README.ja.md) | [Português](README.pt.md) | [Italiano](README.it.md) | [한국어](README.ko.md) | [العربية](README.ar.md) | [Nederlands](README.nl.md) | [Українська](README.ua.md)

---

## 功能特性

- 通过 Ollama API 自动发现所有模型
- 过滤 embedding 模型（nomic-bert 等）
- 通过 `/api/show` 获取精确的上下文长度（带回退默认值）
- 支持多个远程 Ollama 服务器
- 交互式模型选择（含「全部」选项）
- 基于 glob 模式的 include/exclude 过滤
- 自动检测 small_model（用于标题生成）
- 预览模式（dry-run）
- 重复模型的服务器后缀处理
- 与现有配置合并（merge）
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
# 仅本地 Ollama
./generate_opencode_config.sh

# 使用远程服务器
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

# 添加 num_ctx（用于 tool calling）
./generate_opencode_config.sh --num-ctx 32768

# 显式设置默认模型
./generate_opencode_config.sh --default-model qwen2.5-coder:7b

# 合并到现有配置
./generate_opencode_config.sh --merge

# 禁用上下文查找缓存
./generate_opencode_config.sh --no-context-lookup

# 写入全局配置
./generate_opencode_config.sh -o ~/.config/opencode/opencode.json

# 查看版本
./generate_opencode_config.sh --version
```

### PowerShell

```powershell
# 仅本地 Ollama
.\Generate-OpenCodeConfig.ps1

# 使用远程服务器
.\Generate-OpenCodeConfig.ps1 -RemoteOllamaUrl "http://192.168.1.100:11434"

# 交互式选择
.\Generate-OpenCodeConfig.ps1 -Interactive

# 预览
.\Generate-OpenCodeConfig.ps1 -DryRun

# 合并
.\Generate-OpenCodeConfig.ps1 -Merge

# 版本
.\Generate-OpenCodeConfig.ps1 -Version
```

## CLI 参考

### Bash

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `-l, --local URL` | 本地 Ollama URL | `$OLLAMA_HOST` 或 `http://localhost:11434` |
| `-r, --remote URL` | 远程 Ollama URL（可多次指定） | 无 |
| `-o, --output FILE` | 输出文件路径 | `opencode.json` |
| `-n, --dry-run` | 输出到 stdout，不写入文件 | 关 |
| `-i, --interactive` | 交互式模型选择 | 关 |
| `--include PAT` | 包含匹配 glob 的模型（可多次指定） | 全部 |
| `--exclude PAT` | 排除匹配 glob 的模型（可多次指定） | 无 |
| `--with-embed` | 包含 embedding 模型 | 排除 |
| `--no-context-lookup` | 跳过 `/api/show`，使用硬编码值 | 关 |
| `--num-ctx N` | `num_ctx` 值，0 表示省略 | `0` |
| `--merge` | 合并到现有配置 | 关 |
| `--default-model ID` | 显式设置默认模型 | 自动 |
| `--small-model ID` | 显式设置 small 模型 | 自动 |
| `--no-cache` | 禁用上下文缓存 | 关 |
| `-v, --version` | 显示版本 | |
| `-h, --help` | 显示帮助 | |

## 工作原理

1. 通过 `GET /api/tags` 从每个 Ollama 服务器获取模型列表
2. 根据 `families` 字段过滤 embedding 模型
3. 按 include/exclude 模式过滤
4. 通过 `POST /api/show` 获取上下文长度（并行，带缓存）
5. 多服务器重复模型处理（添加 `@host:port` 后缀）
6. 交互式选择（如果使用 `-i`）
7. 合并现有配置（如果使用 `--merge`）
8. 自动检测 small_model（最小的非 embed 模型）
9. 生成 `opencode.json`

## 配置示例

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

## 去重处理

当同一模型存在于多个服务器上时，每个副本会获得唯一的带服务器后缀的名称：

```
qwen2.5-coder:7b                → 本地服务器（原始名称）
qwen2.5-coder:7b@gpu-server     → 第一个远程服务器
qwen2.5-coder:7b@gpu-server-2   → 同主机的第二个远程服务器
```

两个版本都出现在 OpenCode 的 `/models` 中。

## 上下文缓存

来自 `/api/show` 的上下文长度缓存在 `~/.cache/opencode-generator/`，按 URL 哈希存储。缓存 24 小时后过期。使用 `--no-cache` 禁用。

## 合并模式

使用 `--merge` 更新现有配置中的模型，保留其他设置（自定义 provider、规则等）：

```bash
# 初始生成
./generate_opencode_config.sh -o opencode.json

# 手动添加 provider、规则等

# 之后：仅更新模型
./generate_opencode_config.sh --merge -o opencode.json
```

## 环境变量

| 变量 | 说明 |
|------|------|
| `OLLAMA_HOST` | 本地 Ollama URL（Ollama 标准变量） |
| `XDG_CACHE_HOME` | 缓存目录基础路径 |

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

# Windows: https://python.org/downloads
```

### 上下文长度不正确

- 脚本默认使用 `/api/show` 获取精确值
- 如果 API 较慢，使用 `--no-context-lookup`
- 可在生成的 JSON 中手动覆盖
