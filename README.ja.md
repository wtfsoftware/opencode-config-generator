# Ollama用 OpenCode設定ジェネレーター

ローカルおよびリモートのOllamaサーバーから`opencode.json`設定を生成します。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

English | [Русский](README.ru.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Español](README.es.md) | [中文](README.zh.md) | [日本語](README.ja.md) | [Português](README.pt.md) | [Italiano](README.it.md) | [한국어](README.ko.md) | [العربية](README.ar.md) | [Nederlands](README.nl.md) | [Українська](README.ua.md)

**v1.4.2** | [Specification](SPECIFICATION.md) | [Development](DEVELOPMENT.md) | [Disclaimer](DISCLAIMER.md)

## 機能

- **マルチプロバイダー対応**: Ollama、LM Studio、vLLM、llama.cpp、LocalAI、text-generation-webui、Jan.ai、GPT4All
- ポートでプロバイダーを自動検出、または`-p`で指定
- プロバイダーAPI経由で全モデルを自動発見
- embeddingモデルをフィルタリング（nomic-bert、LM Studio typeフィールドなど）
- ツール/関数呼び出しサポートでモデルをフィルタリング（`--tools-only`）
- 正確なコンテキスト長を取得（Ollama `/api/show`、llama.cpp `/props`、LM Studio リッチメタデータ）
- 異なるプロバイダーの複数のサーバーを同時にサポート
- インタラクティブなモデル選択（「すべてのモデル」オプション付き）
- globパターンでモデルをinclude/exclude
- `small_model`を自動検出（タイトル生成用の最小の非embedモデル）
- ドライランモード（書き込みせずにプレビュー）
- `OLLAMA_HOST`環境変数を尊重

## 要件

| コンポーネント | Bashスクリプト | PowerShellスクリプト |
|---------------|:-------------:|:-------------------:|
| curl          | 必須          | 不要                |
| Python 3      | 必須          | 不要                |
| PowerShell 5.1+ | n/a         | 必須                |

## クイックスタート

```bash
# Bash (Linux/macOS/WSL/Git Bash)
./generate_opencode_config.sh

# PowerShell (Windows)
.\Generate-OpenCodeConfig.ps1
```

## 使用方法

### Bash

```bash
# ローカルOllamaのみ（$OLLAMA_HOSTまたはhttp://localhost:11434を使用）
./generate_opencode_config.sh

# リモートサーバー1台
./generate_opencode_config.sh -r http://192.168.1.100:11434

# リモートサーバー複数台
./generate_opencode_config.sh -r http://gpu1:11434 -r http://gpu2:11434

# インタラクティブなモデル選択
./generate_opencode_config.sh -i

# qwenモデルのみ
./generate_opencode_config.sh --include "qwen*"

# codestralを除外
./generate_opencode_config.sh --exclude "codestral*"

# embeddingモデルを含める
./generate_opencode_config.sh --with-embed

# ツール/関数呼び出しサポートのあるモデルのみ
./generate_opencode_config.sh --tools-only

# ファイル書き込みせずにプレビュー
./generate_opencode_config.sh -n

# プロバイダーオプションにnum_ctxを追加（ツール呼び出し用）
./generate_opencode_config.sh --num-ctx 32768

# デフォルトモデルを明示的に設定
./generate_opencode_config.sh --default-model qwen2.5-coder:7b

# 既存の設定にマージ（モデルを更新、他の設定は保持）
./generate_opencode_config.sh --merge

# /api/show呼び出しをスキップ（高速、ハードコードされたコンテキスト制限を使用）
./generate_opencode_config.sh --no-context-lookup

# コンテキスト検索キャッシュを無効化
./generate_opencode_config.sh --no-cache

# グローバル設定に書き込み
./generate_opencode_config.sh -o ~/.config/opencode/opencode.json
```

### PowerShell

```powershell
# ローカルOllamaのみ
.\Generate-OpenCodeConfig.ps1

# リモートサーバーあり
.\Generate-OpenCodeConfig.ps1 -RemoteOllamaUrl "http://192.168.1.100:11434"
.\Generate-OpenCodeConfig.ps1 -RemoteOllamaUrl "http://gpu1:11434","http://gpu2:11434"

# インタラクティブ選択
.\Generate-OpenCodeConfig.ps1 -Interactive

# qwenモデルのみ
.\Generate-OpenCodeConfig.ps1 -Include "qwen*"

# ドライラン
.\Generate-OpenCodeConfig.ps1 -DryRun

# num_ctx付き
.\Generate-OpenCodeConfig.ps1 -NumCtx 32768

# グローバル設定に書き込み
.\Generate-OpenCodeConfig.ps1 -OutputFile "$env:USERPROFILE\.config\opencode\opencode.json"
```

## CLIリファレンス

### Bash

| フラグ | 説明 | デフォルト |
|--------|------|-----------|
| `-l, --local URL` | ローカルサーバーURL | `$OLLAMA_HOST`または`http://localhost:11434` |
| `-r, --remote URL` | リモートサーバーURL（繰り返し可能） | なし |
| `-p, --provider 名前` | プロバイダー: ollama, lmstudio, vllm, llama-cpp, localai, tgwui, jan, gpt4all | 自動検出 |
| `-o, --output ファイル` | 出力ファイルパス（stdoutには`-`） | `opencode.json` |
| `-n, --dry-run` | stdoutに出力、書き込みしない | オフ |
| `-i, --interactive` | インタラクティブなモデル選択 | オフ |
| `--include パターン` | globに一致するモデルを含める（繰り返し可能） | すべて |
| `--exclude パターン` | globに一致するモデルを除外（繰り返し可能） | なし |
| `--with-embed` | embeddingモデルを含める | 除外 |
| `--tools-only` | ツール/関数呼び出しサポートのあるモデルのみ | オフ |
| `--no-context-lookup` | `/api/show`をスキップ、ハードコードされた制限を使用 | オフ |
| `--num-ctx N` | プロバイダーオプションの`num_ctx`、0で省略 | `0` |
| `--merge` | 既存の設定にマージ（モデルのみ更新） | オフ |
| `--default-model ID` | デフォルトモデルを明示的に設定 | 自動 |
| `--small-model ID` | small_modelを明示的に設定（タイトル生成用） | 自動 |
| `--no-cache` | コンテキスト検索キャッシュを無効化 | オフ |
| `-v, --version` | バージョンを表示 | |
| `-h, --help` | ヘルプを表示 | |

### PowerShell

| パラメーター | 説明 | デフォルト |
|-------------|------|-----------|
| `-LocalOllamaUrl` | ローカルOllama URL | `$OLLAMA_HOST`または`http://localhost:11434` |
| `-RemoteOllamaUrl` | リモートURL（配列） | なし |
| `-OutputFile` | 出力ファイルパス | `opencode.json` |
| `-DryRun` | stdoutに出力、書き込みしない | オフ |
| `-Interactive` | インタラクティブなモデル選択 | オフ |
| `-Include` | 含めるパターン（ワイルドカード、配列） | すべて |
| `-Exclude` | 除外パターン（ワイルドカード、配列） | なし |
| `-WithEmbed` | embeddingモデルを含める | 除外 |
| `-ToolsOnly` | ツール/関数呼び出しサポートのあるモデルのみ | オフ |
| `-NoContextLookup` | `/api/show`をスキップ、ハードコードされた制限を使用 | オフ |
| `-NumCtx` | プロバイダーオプションの`num_ctx`、0で省略 | `0` |
| `-Merge` | 既存の設定にマージ（モデルのみ更新） | オフ |
| `-DefaultModel` | デフォルトモデルを明示的に設定 | 自動 |
| `-SmallModel` | small_modelを明示的に設定（タイトル生成用） | 自動 |
| `-NoCache` | コンテキスト検索キャッシュを無効化 | オフ |
| `-Version` | バージョンを表示 | |
| `-Help` | ヘルプを表示 | |

## 仕組み

1. **モデル取得** 各Ollamaサーバーから`GET /api/tags`で取得
2. **フィルタリング** `families`フィールドでembeddingモデルを除外（`nomic-bert`、`bert`など）
3. **フィルタリング** include/excludeパターン（globマッチ）
4. **コンテキスト長取得** 各モデルの`POST /api/show`（並列、キャッシュ付き）
5. **重複排除** 複数サーバーで見つかったモデルを重複排除（最初のサーバーのバージョンを保持）
6. **インタラクティブ選択**（`-i`の場合）: 番号付きリストに`[0] すべてのモデル`オプション
7. **マージ**（`--merge`の場合）: 既存の設定と他のプロバイダーを保持
8. **`small_model`自動検出**: パラメーター数で最小の非embedモデル
9. **生成** Ollamaをプロバイダーとして`opencode.json`を生成

## 生成される設定構造

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

### フィールド

| フィールド | 説明 |
|-----------|------|
| `provider.ollama.options.baseURL` | Ollama OpenAI互換エンドポイント |
| `provider.ollama.models.*.limit.context` | モデルの最大コンテキストウィンドウ |
| `provider.ollama.models.*.limit.output` | 最大出力トークン（16Kに制限） |
| `model` | デフォルトモデル（最初の利用可能なモデル） |
| `small_model` | 軽量タスク用の最小モデル（タイトル生成） |

## モデルコンテキスト検出

コンテキスト長は以下の優先順位で決定されます:

1. **API検索** — `POST /api/show`が`model_info.*.context_length`を返す（正確な値）
2. **ハードコードフォールバック** — モデルファミリーで推定:

| ファミリー | デフォルトコンテキスト |
|-----------|:-------------------:|
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
| その他 | 8,192 |

`--no-context-lookup`を使用してAPI呼び出しをスキップし、ハードコードされた値のみを使用できます（高速）。

## Embeddingモデル

embeddingモデルはチャット/ツール呼び出しをサポートしないため、**デフォルトで除外**されます。検出は以下に基づきます:

- `nomic-bert`、`bert`、`bert-moe`、`embed`、`embedding`を含むモデルファミリー
- これらのキーワードを含むモデル名

含めるには`--with-embed` / `-WithEmbed`を使用してください。

## ツール/関数呼び出しフィルター

`--tools-only` / `-ToolsOnly`を使用して、ツール/関数呼び出しをサポートするモデルのみを含めます:

```bash
./generate_opencode_config.sh --tools-only
```

検出は2つのレベルで動作します:
1. **正確** — LM Studioはリッチな`/api/v1/models`エンドポイント経由で`capabilities.tool_use`を提供
2. **ヒューリスティック** — 他のすべてのプロバイダーの場合、モデルは既のツール対応ファミリーの許可リストと照合されます（qwen2.5/3、llama3.x、mistral、mixtral、deepseek-r1/v3、command-r、phi3/4、gemma2/3、granite3.x）

`--tools-only`がアクティブな場合、いずれのチェックにも一致しないモデルは除外されます。新しいモデルファミリーがリリースされるにつれて、許可リストの更新が必要になる場合があります。

## マルチプロバイダー対応

8つのローカル推論プロバイダーで動作します。プロバイダーはポートで自動検出されるか、`-p`で指定します。

| プロバイダー | デフォルトポート | リッチメタデータ | 自動検出 |
|-------------|:---------------:|:---------------:|:-------:|
| **Ollama** | 11434 | `/api/show`（コンテキスト、ファミリー） | ✅ |
| **LM Studio** | 1234 | `/api/v1/models`（タイプ、機能、コンテキスト） | ✅ |
| **vLLM** | 8000 | 基本のみ | ✅ |
| **llama.cpp** | 8080 | `/props`（context_size） | ✅（localaiとして） |
| **LocalAI** | 8080 | 基本のみ | ✅ |
| **text-generation-webui** | 5000 | 基本のみ | ✅ |
| **Jan.ai** | 1337 | 基本のみ | ✅ |
| **GPT4All** | 4891 | 基本のみ | ✅ |

```bash
# ポートで自動検出
./generate_opencode_config.sh -l http://localhost:1234       # LM Studio
./generate_opencode_config.sh -l http://localhost:8000       # vLLM

# 明示的なプロバイダー
./generate_opencode_config.sh -l http://localhost:8080 -p llama-cpp

# Ollama + LM Studio 一緒に
./generate_opencode_config.sh -l http://localhost:11434 -r http://localhost:1234 -p lmstudio
```

各プロバイダーは`opencode.json`内で別々のブロックとして表示されます:

```json
{
  "provider": {
    "ollama": { "name": "Ollama", "options": { "baseURL": "http://localhost:11434/v1" }, ... },
    "lmstudio": { "name": "LM Studio", "options": { "baseURL": "http://localhost:1234/v1" }, ... }
  }
}
```

## コンテキスト検索キャッシュ

`/api/show`からのコンテキスト長はURLハッシュごとに`~/.cache/opencode-generator/`にキャッシュされます。キャッシュは24時間後に期限切れになります。以降の実行はキャッシュされた値を再利用し、新しいモデルのみ取得します。無効にするには`--no-cache`を使用してください。

## マージモード

`--merge`を使用して、既存の`opencode.json`のモデルを更新し、他の設定（カスタムプロバイダー、テーマ、ルールなど）を上書きせずに保持します:

```bash
# 初期生成
./generate_opencode_config.sh -o opencode.json

# opencode.jsonにカスタムプロバイダー、ルールなどを手動で追加

# 後日: モデルのみ更新、他はすべて保持
./generate_opencode_config.sh --merge -o opencode.json
```

## 重複排除

同じモデルが複数のサーバーに存在する場合、各コピーにサーバーサフィックス付きの一意の名前が付与されます:

```
qwen2.5-coder:7b                → ローカルサーバー（元の名前）
qwen2.5-coder:7b@gpu-server     → 最初のリモートサーバー
qwen2.5-coder:7b@gpu-server-2   → 同じホスト名の2番目のリモート
```

両方のバージョンが`/models`に表示されます。サマリーはどのモデルにサフィックスが付いたかを示します。

## 環境変数

| 変数 | 説明 |
|------|------|
| `OLLAMA_HOST` | デフォルトのローカルOllama URL（標準Ollama変数） |
| `XDG_CACHE_HOME` | キャッシュディレクトリのベースパス |

## 生成された設定のインストール

```bash
# グローバル設定（すべてのプロジェクト）
cp opencode.json ~/.config/opencode/opencode.json

# プロジェクト固有
cp opencode.json /path/to/project/opencode.json
```

## トラブルシューティング

### 「Ollamaに接続できません」

- Ollamaが実行中であることを確認: `ollama serve`
- URLを確認: `curl http://localhost:11434/api/tags`
- カスタムポート/ホストを使用している場合、`OLLAMA_HOST`を設定するか`-l`を使用

### 「必須の依存関係がありません: python3」

```bash
# Ubuntu/Debian
sudo apt install python3

# macOS
brew install python3

# Windows: https://python.org からダウンロード
```

### コンテキスト長が正しくない

- スクリプトはデフォルトで正確な値のために`/api/show`を使用
- APIが遅い場合、`--no-context-lookup`でハードコードされた推定値を使用
- 必要に応じて生成されたJSONで手動で上書き

### embeddingモデルが予期せず含まれる/除外される

- `ollama show <model>`の出力でファミリーを確認
- 強制的に含めるには`--with-embed`を使用
- 名前で強制的に除外するには`--exclude "*embed*"`を使用

### OpenCodeで「プロバイダーがエラーを返しました」

- 一部のOllamaモデルはツール呼び出しをサポートしていません — `qwen2.5-coder`または`llama3.2`を試してください
- ツールが失敗する場合は`num_ctx`を増やす: `--num-ctx 32768`
- モデルがロードされていることを確認: `ollama run <model>`
