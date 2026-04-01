# Ollama用 OpenCode設定ジェネレーター

ローカルおよびリモートOllamaサーバーのモデルから[OpenCode](https://opencode.ai)の`opencode.json`設定を生成します。

[English](README.md) | [Русский](README.ru.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Español](README.es.md) | [中文](README.zh.md) | [日本語](README.ja.md) | [Português](README.pt.md) | [Italiano](README.it.md) | [한국어](README.ko.md) | [العربية](README.ar.md) | [Nederlands](README.nl.md) | [Українська](README.ua.md)

**v1.1.0** | [Specification](SPECIFICATION.md) | [Development](DEVELOPMENT.md) | [Disclaimer](DISCLAIMER.md)

---

## 機能

- Ollama APIによるモデルの自動検出
- エンベディングモデルのフィルタリング（nomic-bert等）
- `/api/show`による正確なコンテキスト長（フォールバック付き）
- 複数のリモートOllamaサーバーのサポート
- 「すべて」オプション付きのインタラクティブモデル選択
- globパターンによるフィルタリング（include/exclude）
- small_modelの自動検出
- プレビューモード（dry-run）
- 重複モデルのサーバーサフィックス
- 既存設定とのマージ
- `OLLAMA_HOST`環境変数のサポート

## 要件

| Component | Bash | PowerShell |
|-----------|:----:|:----------:|
| curl | required | not needed |
| Python 3 | required | not needed |
| PowerShell 5.1+ | n/a | required |

## クイックスタート

```bash
./generate_opencode_config.sh
.\Generate-OpenCodeConfig.ps1
```

## 使用方法

```bash
./generate_opencode_config.sh -r http://gpu:11434    # remote
./generate_opencode_config.sh -i                      # interactive
./generate_opencode_config.sh --include "qwen*"       # filter
./generate_opencode_config.sh -n                      # dry-run
./generate_opencode_config.sh --merge                 # merge
./generate_opencode_config.sh --default-model qwen2.5-coder:7b
./generate_opencode_config.sh -v                      # version
```

## CLIリファレンス

| Flag | Description |
|------|-------------|
| `-l, --local URL` | Local Ollama URL |
| `-r, --remote URL` | Remote URL (repeatable) |
| `-o, --output FILE` | Output (`-` for stdout) |
| `-n, --dry-run` | Preview |
| `-i, --interactive` | Interactive selection |
| `--include PAT` | Include pattern |
| `--exclude PAT` | Exclude pattern |
| `--with-embed` | Include embed models |
| `--no-context-lookup` | Skip API lookup |
| `--num-ctx N` | num_ctx (0=omit) |
| `--merge` | Merge config |
| `--default-model ID` | Default model |
| `--small-model ID` | Small model |
| `--no-cache` | Disable cache |
| `-v, --version` | Version |

## 仕組み

1. 各サーバーから`GET /api/tags`で**モデルを取得**
2. `families`フィールドでエンベディングモデルを**フィルタリング**
3. include/excludeパターンで**フィルタリング**
4. `POST /api/show`で**コンテキスト長を取得**（並列、キャッシュ付き）
5. 複数サーバーのモデルの**重複排除**（`@host:port`サフィックス）
6. **インタラクティブ選択**（`-i`の場合）
7. **マージ**（`--merge`の場合）
8. **small_model検出**：最小の非エンベディングモデル
9. `opencode.json`の**生成**

## 設定例

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "options": { "baseURL": "http://localhost:11434/v1" },
      "models": {
        "qwen2.5-coder:7b": {
          "name": "Qwen2 7.6B Q4_K_M (local)",
          "limit": { "context": 32768, "output": 16384 }
        }
      }
    }
  },
  "model": "ollama/qwen2.5-coder:7b"
}
```

## 重複排除

同じモデルが複数のサーバーに存在する場合、各コピーにサーバーサフィックス付きの固有名が付与されます：

```
qwen2.5-coder:7b             → local
qwen2.5-coder:7b@gpu-server  → remote
```

## コンテキストキャッシュ

コンテキスト長は`~/.cache/opencode-generator/`にキャッシュされます。キャッシュは24時間後に期限切れになります。

## マージモード

`--merge`を使用して、他の設定を上書きせずにモデルを更新します：

```bash
./generate_opencode_config.sh --merge -o opencode.json
```

## 設定のインストール

```bash
cp opencode.json ~/.config/opencode/opencode.json
```

## 環境変数

| Variable | Description |
|----------|-------------|
| `OLLAMA_HOST` | Default Ollama URL |
| `XDG_CACHE_HOME` | Cache directory |

## トラブルシューティング

### Ollamaに接続できません

- Ollamaが実行中であることを確認：`ollama serve`
- URLを確認：`curl http://localhost:11434/api/tags`

### 依存関係が見つかりません

```bash
sudo apt install python3 curl   # Ubuntu/Debian
brew install python3 curl       # macOS
```

### コンテキストが正しくありません

- スクリプトはデフォルトで`/api/show`を使用
- APIが遅い場合は`--no-context-lookup`を使用
