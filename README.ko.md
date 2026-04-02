# Ollama용 OpenCode 설정 생성기

로컬 및 원격 Ollama 서버에서 `opencode.json` 설정을 생성합니다.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

English | [Русский](README.ru.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Español](README.es.md) | [中文](README.zh.md) | [日本語](README.ja.md) | [Português](README.pt.md) | [Italiano](README.it.md) | [한국어](README.ko.md) | [العربية](README.ar.md) | [Nederlands](README.nl.md) | [Українська](README.ua.md)

**v1.4.3** | [Specification](SPECIFICATION.md) | [Development](DEVELOPMENT.md) | [Disclaimer](DISCLAIMER.md)

## 주요 기능

- **멀티 프로바이더 지원**: Ollama, LM Studio, vLLM, llama.cpp, LocalAI, text-generation-webui, Jan.ai, GPT4All
- 포트로 프로바이더 자동 감지, 또는 `-p`로 지정
- 프로바이더 API를 통해 모든 모델 자동 발견
- embedding 모델 필터링 (nomic-bert, LM Studio type 필드 등)
- 도구/함수 호출 지원으로 모델 필터링 (`--tools-only`)
- 정확한 컨텍스트 길이 가져오기 (Ollama `/api/show`, llama.cpp `/props`, LM Studio 리치 메타데이터)
- 서로 다른 프로바이더의 여러 서버를 동시에 지원
- 인터랙티브 모델 선택 ("모든 모델" 옵션 포함)
- glob 패턴으로 모델 include/exclude
- `small_model` 자동 감지 (제목 생성용 최소 비embed 모델)
- Dry-run 모드 (쓰지 않고 미리보기)
- `OLLAMA_HOST` 환경 변수 존중

## 요구 사항

| 구성 요소 | Bash 스크립트 | PowerShell 스크립트 |
|-----------|:-------------:|:-------------------:|
| curl      | 필요          | 불필요              |
| Python 3  | 필요          | 불필요              |
| PowerShell 5.1+ | n/a     | 필요                |

## 빠른 시작

```bash
# Bash (Linux/macOS/WSL/Git Bash)
./generate_opencode_config.sh

# PowerShell (Windows)
.\Generate-OpenCodeConfig.ps1
```

## 사용법

### Bash

```bash
# 로컬 Ollama만 ($OLLAMA_HOST 또는 http://localhost:11434 사용)
./generate_opencode_config.sh

# 원격 서버 1대
./generate_opencode_config.sh -r http://192.168.1.100:11434

# 원격 서버 여러 대
./generate_opencode_config.sh -r http://gpu1:11434 -r http://gpu2:11434

# 인터랙티브 모델 선택
./generate_opencode_config.sh -i

# qwen 모델만
./generate_opencode_config.sh --include "qwen*"

# codestral 제외
./generate_opencode_config.sh --exclude "codestral*"

# embedding 모델 포함
./generate_opencode_config.sh --with-embed

# 도구/함수 호출 지원이 있는 모델만
./generate_opencode_config.sh --tools-only

# 파일 쓰기 없이 미리보기
./generate_opencode_config.sh -n

# 프로바이더 옵션에 num_ctx 추가 (도구 호출용)
./generate_opencode_config.sh --num-ctx 32768

# 기본 모델 명시적 설정
./generate_opencode_config.sh --default-model qwen2.5-coder:7b

# 기존 설정에 병합 (모델 업데이트, 다른 설정 유지)
./generate_opencode_config.sh --merge

# /api/show 호출 건너뛰기 (빠름, 하드코딩된 컨텍스트 제한 사용)
./generate_opencode_config.sh --no-context-lookup

# 컨텍스트 조회 캐시 비활성화
./generate_opencode_config.sh --no-cache

# 전역 설정에 쓰기
./generate_opencode_config.sh -o ~/.config/opencode/opencode.json
```

### PowerShell

```powershell
# 로컬 Ollama만
.\Generate-OpenCodeConfig.ps1

# 원격 서버 포함
.\Generate-OpenCodeConfig.ps1 -RemoteOllamaUrl "http://192.168.1.100:11434"
.\Generate-OpenCodeConfig.ps1 -RemoteOllamaUrl "http://gpu1:11434","http://gpu2:11434"

# 인터랙티브 선택
.\Generate-OpenCodeConfig.ps1 -Interactive

# qwen 모델만
.\Generate-OpenCodeConfig.ps1 -Include "qwen*"

# Dry-run
.\Generate-OpenCodeConfig.ps1 -DryRun

# num_ctx 포함
.\Generate-OpenCodeConfig.ps1 -NumCtx 32768

# 전역 설정에 쓰기
.\Generate-OpenCodeConfig.ps1 -OutputFile "$env:USERPROFILE\.config\opencode\opencode.json"
```

## CLI 참조

### Bash

| 플래그 | 설명 | 기본값 |
|--------|------|--------|
| `-l, --local URL` | 로컬 서버 URL | `$OLLAMA_HOST` 또는 `http://localhost:11434` |
| `-r, --remote URL` | 원격 서버 URL (반복 가능) | 없음 |
| `-p, --provider 이름` | 프로바이더: ollama, lmstudio, vllm, llama-cpp, localai, tgwui, jan, gpt4all | 자동 감지 |
| `-o, --output 파일` | 출력 파일 경로 (stdout에는 `-`) | `opencode.json` |
| `-n, --dry-run` | stdout에 출력, 쓰기 안 함 | 끔 |
| `-i, --interactive` | 인터랙티브 모델 선택 | 끔 |
| `--include 패턴` | glob과 일치하는 모델 포함 (반복 가능) | 전체 |
| `--exclude 패턴` | glob과 일치하는 모델 제외 (반복 가능) | 없음 |
| `--with-embed` | embedding 모델 포함 | 제외 |
| `--tools-only` | 도구/함수 호출 지원이 있는 모델만 | 끔 |
| `--no-context-lookup` | `/api/show` 건너뛰기, 하드코딩된 제한 사용 | 끔 |
| `--num-ctx N` | 프로바이더 옵션용 `num_ctx`, 0이면 생략 | `0` |
| `--merge` | 기존 설정에 병합 (모델만 업데이트) | 끔 |
| `--default-model ID` | 기본 모델 명시적 설정 | 자동 |
| `--small-model ID` | small_model 명시적 설정 (제목 생성용) | 자동 |
| `--no-cache` | 컨텍스트 조회 캐시 비활성화 | 끔 |
| `-v, --version` | 버전 표시 | |
| `-h, --help` | 도움말 표시 | |

### PowerShell

| 매개변수 | 설명 | 기본값 |
|----------|------|--------|
| `-LocalOllamaUrl` | 로컬 Ollama URL | `$OLLAMA_HOST` 또는 `http://localhost:11434` |
| `-RemoteOllamaUrl` | 원격 URL (배열) | 없음 |
| `-OutputFile` | 출력 파일 경로 | `opencode.json` |
| `-DryRun` | stdout에 출력, 쓰기 안 함 | 끔 |
| `-Interactive` | 인터랙티브 모델 선택 | 끔 |
| `-Include` | 포함 패턴 (와일드카드, 배열) | 전체 |
| `-Exclude` | 제외 패턴 (와일드카드, 배열) | 없음 |
| `-WithEmbed` | embedding 모델 포함 | 제외 |
| `-ToolsOnly` | 도구/함수 호출 지원이 있는 모델만 | 끔 |
| `-NoContextLookup` | `/api/show` 건너뛰기, 하드코딩된 제한 사용 | 끔 |
| `-NumCtx` | 프로바이더 옵션용 `num_ctx`, 0이면 생략 | `0` |
| `-Merge` | 기존 설정에 병합 (모델만 업데이트) | 끔 |
| `-DefaultModel` | 기본 모델 명시적 설정 | 자동 |
| `-SmallModel` | small_model 명시적 설정 (제목 생성용) | 자동 |
| `-NoCache` | 컨텍스트 조회 캐시 비활성화 | 끔 |
| `-Version` | 버전 표시 | |
| `-Help` | 도움말 표시 | |

## 작동 방식

1. **모델 가져오기** 각 Ollama 서버에서 `GET /api/tags`로 가져오기
2. **필터링** `families` 필드로 embedding 모델 필터링 (`nomic-bert`, `bert` 등)
3. **필터링** include/exclude 패턴 (glob 매칭)
4. **컨텍스트 길이 가져오기** 각 모델의 `POST /api/show` (병렬, 캐시 포함)
5. **중복 제거** 여러 서버에서 찾은 모델 중복 제거 (첫 번째 서버 버전 유지)
6. **인터랙티브 선택** (`-i`인 경우): `[0] 모든 모델` 옵션이 있는 번호 목록
7. **병합** (`--merge`인 경우): 기존 설정 및 다른 프로바이더 보존
8. **`small_model` 자동 감지**: 파라미터 수 기준 최소 비embed 모델
9. **생성** Ollama를 프로바이더로 `opencode.json` 생성

## 생성된 설정 구조

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

### 필드

| 필드 | 설명 |
|------|------|
| `provider.ollama.options.baseURL` | Ollama OpenAI 호환 엔드포인트 |
| `provider.ollama.models.*.limit.context` | 모델의 최대 컨텍스트 윈도우 |
| `provider.ollama.models.*.limit.output` | 최대 출력 토큰 (16K로 제한) |
| `model` | 기본 모델 (첫 번째 사용 가능한 모델) |
| `small_model` | 가벼운 작업용 최소 모델 (제목 생성) |

## 모델 컨텍스트 감지

컨텍스트 길이는 다음 우선순위로 결정됩니다:

1. **API 조회** — `POST /api/show`가 `model_info.*.context_length` 반환 (정확한 값)
2. **하드코딩 폴백** — 모델 패밀리로 추정:

| 패밀리 | 기본 컨텍스트 |
|--------|:-------------:|
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
| 기타 | 8,192 |

`--no-context-lookup`을 사용하여 API 호출을 건너뛰고 하드코딩된 값만 사용할 수 있습니다 (빠름).

## Embedding 모델

Embedding 모델은 채팅/도구 호출을 지원하지 않으므로 **기본적으로 제외**됩니다. 감지는 다음을 기반으로 합니다:

- `nomic-bert`, `bert`, `bert-moe`, `embed`, `embedding`을 포함하는 모델 패밀리
- 이러한 키워드를 포함하는 모델 이름

포함하려면 `--with-embed` / `-WithEmbed`를 사용하세요.

## 도구/함수 호출 필터

`--tools-only` / `-ToolsOnly`를 사용하여 도구/함수 호출을 지원하는 모델만 포함하세요:

```bash
./generate_opencode_config.sh --tools-only
```

감지는 두 단계로 작동합니다:
1. **정확** — LM Studio는 리치 `/api/v1/models` 엔드포인트를 통해 `capabilities.tool_use` 제공
2. **휴리스틱** — 다른 모든 프로바이더의 경우, 모델은 알려진 도구 지원 패밀리의 허용 목록과 일치됩니다 (qwen2.5/3, llama3.x, mistral, mixtral, deepseek-r1/v3, command-r, phi3/4, gemma2/3, granite3.x)

`--tools-only`가 활성화된 경우 두 검사 중 어느 것도 일치하지 않는 모델은 제외됩니다. 새 모델 패밀리가 출시됨에 따라 허용 목록 업데이트가 필요할 수 있습니다.

## 멀티 프로바이더 지원

8개의 로컬 추론 프로바이더와 함께 작동합니다. 프로바이더는 포트로 자동 감지되거나 `-p`로 지정합니다.

| 프로바이더 | 기본 포트 | 리치 메타데이터 | 자동 감지 |
|-----------|:---------:|:---------------:|:---------:|
| **Ollama** | 11434 | `/api/show` (컨텍스트, 패밀리) | ✅ |
| **LM Studio** | 1234 | `/api/v1/models` (타입, 기능, 컨텍스트) | ✅ |
| **vLLM** | 8000 | 기본만 | ✅ |
| **llama.cpp** | 8080 | `/props` (context_size) | ✅ (localai로) |
| **LocalAI** | 8080 | 기본만 | ✅ |
| **text-generation-webui** | 5000 | 기본만 | ✅ |
| **Jan.ai** | 1337 | 기본만 | ✅ |
| **GPT4All** | 4891 | 기본만 | ✅ |

```bash
# 포트로 자동 감지
./generate_opencode_config.sh -l http://localhost:1234       # LM Studio
./generate_opencode_config.sh -l http://localhost:8000       # vLLM

# 명시적 프로바이더
./generate_opencode_config.sh -l http://localhost:8080 -p llama-cpp

# Ollama + LM Studio 함께
./generate_opencode_config.sh -l http://localhost:11434 -r http://localhost:1234 -p lmstudio
```

각 프로바이더는 `opencode.json`에서 별도의 블록으로 표시됩니다:

```json
{
  "provider": {
    "ollama": { "name": "Ollama", "options": { "baseURL": "http://localhost:11434/v1" }, ... },
    "lmstudio": { "name": "LM Studio", "options": { "baseURL": "http://localhost:1234/v1" }, ... }
  }
}
```

## 컨텍스트 조회 캐시

`/api/show`의 컨텍스트 길이는 URL 해시별로 `~/.cache/opencode-generator/`에 캐시됩니다. 캐시는 24시간 후 만료됩니다. 이후 실행은 캐시된 값을 재사용하고 새 모델만 가져옵니다. 비활성화하려면 `--no-cache`를 사용하세요.

## 병합 모드

`--merge`를 사용하여 기존 `opencode.json`의 모델을 업데이트하면서 다른 설정 (커스텀 프로바이더, 테마, 규칙 등)을 덮어쓰지 않고 유지하세요:

```bash
# 초기 생성
./generate_opencode_config.sh -o opencode.json

# opencode.json에 커스텀 프로바이더, 규칙 등 수동 추가

# 나중에: 모델만 업데이트, 나머지 모두 유지
./generate_opencode_config.sh --merge -o opencode.json
```

## 중복 제거

동일한 모델이 여러 서버에 존재하는 경우, 각 복사본에 서버 접미사가 있는 고유한 이름이 부여됩니다:

```
qwen2.5-coder:7b                → 로컬 서버 (원래 이름)
qwen2.5-coder:7b@gpu-server     → 첫 번째 원격 서버
qwen2.5-coder:7b@gpu-server-2   → 동일한 호스트네임을 가진 두 번째 원격
```

두 버전 모두 `/models`에 표시됩니다. 요약은 어떤 모델에 접미사가 붙었는지 보여줍니다.

## 환경 변수

| 변수 | 설명 |
|------|------|
| `OLLAMA_HOST` | 기본 로컬 Ollama URL (표준 Ollama 변수) |
| `XDG_CACHE_HOME` | 캐시 디렉토리 기본 경로 |

## 생성된 설정 설치

```bash
# 전역 설정 (모든 프로젝트)
cp opencode.json ~/.config/opencode/opencode.json

# 프로젝트별
cp opencode.json /path/to/project/opencode.json
```

## 문제 해결

### "Ollama에 연결할 수 없습니다"

- Ollama가 실행 중인지 확인: `ollama serve`
- URL 확인: `curl http://localhost:11434/api/tags`
- 커스텀 포트/호스트를 사용하는 경우 `OLLAMA_HOST`를 설정하거나 `-l` 사용

### "필수 종속성 누락: python3"

```bash
# Ubuntu/Debian
sudo apt install python3

# macOS
brew install python3

# Windows: https://python.org 에서 다운로드
```

### 잘못된 컨텍스트 길이

- 스크립트는 기본적으로 정확한 값을 위해 `/api/show` 사용
- API가 느린 경우 `--no-context-lookup`으로 하드코딩된 추정값 사용
- 필요시 생성된 JSON에서 수동으로 덮어쓰기

### embedding 모델이 예상치 않게 포함/제외됨

- `ollama show <model>` 출력에서 패밀리 확인
- 강제로 포함하려면 `--with-embed` 사용
- 이름으로 강제로 제외하려면 `--exclude "*embed*"` 사용

### OpenCode에서 "프로바이더가 오류를 반환했습니다"

- 일부 Ollama 모델은 도구 호출을 지원하지 않습니다 — `qwen2.5-coder` 또는 `llama3.2` 시도
- 도구가 실패하면 `num_ctx` 증가: `--num-ctx 32768`
- 모델이 로드되었는지 확인: `ollama run <model>`
