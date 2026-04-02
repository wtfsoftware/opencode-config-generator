# Ollama용 OpenCode 설정 생성기

로컬 및 원격 Ollama 서버의 모델을 기반으로 [OpenCode](https://opencode.ai)용 `opencode.json` 설정을 생성합니다.

[English](README.md) | [Русский](README.ru.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Español](README.es.md) | [中文](README.zh.md) | [日本語](README.ja.md) | [Português](README.pt.md) | [Italiano](README.it.md) | [한국어](README.ko.md) | [العربية](README.ar.md) | [Nederlands](README.nl.md) | [Українська](README.ua.md)

**v1.3.0** | [Specification](SPECIFICATION.md) | [Development](DEVELOPMENT.md) | [Disclaimer](DISCLAIMER.md)

---

## 주요 기능

- **Multi-provider**: Ollama, LM Studio, vLLM, llama.cpp, LocalAI, text-generation-webui, Jan.ai, GPT4All
- Ollama API를 통한 모델 자동 검색
- 임베딩 모델 필터링 (nomic-bert 등)
- `/api/show`를 통한 정확한 컨텍스트 길이 (fallback 포함)
- 다수의 원격 Ollama 서버 지원
- "모두" 옵션이 있는 대화형 모델 선택
- glob 패턴으로 필터링 (include/exclude)
- small_model 자동 감지
- 미리보기 모드 (dry-run)
- 중복 모델에 대한 서버 접미사
- 기존 설정과 병합 (merge)
- `OLLAMA_HOST` 환경 변수 지원

## 요구 사항

| Component | Bash | PowerShell |
|-----------|:----:|:----------:|
| curl | required | not needed |
| Python 3 | required | not needed |
| PowerShell 5.1+ | n/a | required |

## 빠른 시작

```bash
./generate_opencode_config.sh
.\Generate-OpenCodeConfig.ps1
```

## 사용법

```bash
./generate_opencode_config.sh -r http://gpu:11434    # remote
./generate_opencode_config.sh -i                      # interactive
./generate_opencode_config.sh --include "qwen*"       # filter
./generate_opencode_config.sh -n                      # dry-run
./generate_opencode_config.sh --merge                 # merge
./generate_opencode_config.sh --default-model qwen2.5-coder:7b
./generate_opencode_config.sh -v                      # version
```

## CLI 참조

| Flag | Description |
|------|-------------|
| `-l, --local URL` | Local server URL |
| `-r, --remote URL` | Remote URL (repeatable) |
| `-p, --provider NAME` | Provider: ollama, lmstudio, vllm, llama-cpp, localai, tgwui, jan, gpt4all | auto |
| `-o, --output FILE` | Output (`-` for stdout) |
| `-n, --dry-run` | Preview |
| `-i, --interactive` | Interactive selection |
| `--include PAT` | Include pattern |
| `--exclude PAT` | Exclude pattern |
| `--with-embed` | Include embed models |
| `--tools-only` | Only models with tool/function calling support |
| `-ToolsOnly` | Only models with tool/function calling support |
| `--no-context-lookup` | Skip API lookup |
| `--num-ctx N` | num_ctx (0=omit) |
| `--merge` | Merge config |
| `--default-model ID` | Default model |
| `--small-model ID` | Small model |
| `--no-cache` | Disable cache |
| `-v, --version` | Version |

## 작동 방식

1. `GET /api/tags`로 각 서버에서 **모델 가져오기**
2. `families` 필드로 임베딩 모델 **필터링**
3. include/exclude 패턴으로 **필터링**
4. `POST /api/show`로 **컨텍스트 길이 가져오기** (병렬, 캐시 포함)
5. 여러 서버의 모델 **중복 제거** (`@host:port` 접미사)
6. **대화형 선택** (`-i` 사용 시)
7. **병합** (`--merge` 사용 시): 기존 설정 보존
8. **small_model 감지**: 가장 작은 비임베딩 모델
9. `opencode.json` **생성**

## 설정 예시

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

## 중복 제거

동일한 모델이 여러 서버에 존재하는 경우, 각 복사본에 서버 접미사가 포함된 고유한 이름이 부여됩니다:

```
qwen2.5-coder:7b             → local
qwen2.5-coder:7b@gpu-server  → remote
```

## 컨텍스트 캐시

컨텍스트 길이는 `~/.cache/opencode-generator/`에 캐시됩니다. 캐시는 24시간 후 만료됩니다.

## 병합 모드

`--merge`를 사용하여 다른 설정을 덮어쓰지 않고 모델을 업데이트합니다:

```bash
./generate_opencode_config.sh --merge -o opencode.json
```

## 설정 설치

```bash
cp opencode.json ~/.config/opencode/opencode.json
```

## 환경 변수

| Variable | Description |
|----------|-------------|
| `OLLAMA_HOST` | Default Ollama URL |
| `XDG_CACHE_HOME` | Cache directory |

## 문제 해결

### Ollama에 연결할 수 없습니다

- Ollama가 실행 중인지 확인: `ollama serve`
- URL 확인: `curl http://localhost:11434/api/tags`

### 누락된 종속성

```bash
sudo apt install python3 curl   # Ubuntu/Debian
brew install python3 curl       # macOS
```

### 잘못된 컨텍스트

- 스크립트는 기본적으로 `/api/show`를 사용합니다
- API가 느린 경우 `--no-context-lookup` 사용
