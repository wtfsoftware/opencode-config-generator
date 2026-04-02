# Gerador de Configuração OpenCode para Ollama

Gera a configuração `opencode.json` a partir de servidores Ollama locais e remotos.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

English | [Русский](README.ru.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Español](README.es.md) | [中文](README.zh.md) | [日本語](README.ja.md) | [Português](README.pt.md) | [Italiano](README.it.md) | [한국어](README.ko.md) | [العربية](README.ar.md) | [Nederlands](README.nl.md) | [Українська](README.ua.md)

**v1.4.0** | [Specification](SPECIFICATION.md) | [Development](DEVELOPMENT.md) | [Disclaimer](DISCLAIMER.md)

## Funcionalidades

- **Suporte a múltiplos provedores**: Ollama, LM Studio, vLLM, llama.cpp, LocalAI, text-generation-webui, Jan.ai, GPT4All
- Detecta automaticamente o provedor pela porta, ou especifique com `-p`
- Descobre todos os modelos automaticamente via API do provedor
- Filtra modelos de embedding (nomic-bert, campo type do LM Studio, etc.)
- Filtra modelos por suporte a chamada de ferramentas/funções (`--tools-only`)
- Obtém comprimentos de contexto exatos (Ollama `/api/show`, llama.cpp `/props`, LM Studio metadados ricos)
- Suporta múltiplos servidores de provedores diferentes simultaneamente
- Seleção interativa de modelos (com opção "Todos os modelos")
- Incluir/excluir modelos por padrões glob
- Detecta automaticamente `small_model` (menor modelo não-embed para geração de títulos)
- Modo dry-run (pré-visualização sem escrever)
- Respeita a variável de ambiente `OLLAMA_HOST`

## Requisitos

| Componente | Script Bash | Script PowerShell |
|------------|:-----------:|:-----------------:|
| curl       | necessário  | não necessário    |
| Python 3   | necessário  | não necessário    |
| PowerShell 5.1+ | n/a    | necessário        |

## Início rápido

```bash
# Bash (Linux/macOS/WSL/Git Bash)
./generate_opencode_config.sh

# PowerShell (Windows)
.\Generate-OpenCodeConfig.ps1
```

## Uso

### Bash

```bash
# Apenas Ollama local (usa $OLLAMA_HOST ou http://localhost:11434)
./generate_opencode_config.sh

# Com um servidor remoto
./generate_opencode_config.sh -r http://192.168.1.100:11434

# Com múltiplos servidores remotos
./generate_opencode_config.sh -r http://gpu1:11434 -r http://gpu2:11434

# Seleção interativa de modelos
./generate_opencode_config.sh -i

# Apenas modelos qwen
./generate_opencode_config.sh --include "qwen*"

# Excluir codestral
./generate_opencode_config.sh --exclude "codestral*"

# Incluir modelos de embedding
./generate_opencode_config.sh --with-embed

# Apenas modelos com suporte a chamada de ferramentas/funções
./generate_opencode_config.sh --tools-only

# Pré-visualizar sem escrever arquivo
./generate_opencode_config.sh -n

# Adicionar num_ctx às opções do provedor (para chamada de ferramentas)
./generate_opencode_config.sh --num-ctx 32768

# Definir modelo padrão explicitamente
./generate_opencode_config.sh --default-model qwen2.5-coder:7b

# Mesclar na configuração existente (atualizar modelos, manter outras configurações)
./generate_opencode_config.sh --merge

# Pular chamadas /api/show (mais rápido, usa limites de contexto codificados)
./generate_opencode_config.sh --no-context-lookup

# Desativar cache de busca de contexto
./generate_opencode_config.sh --no-cache

# Escrever na configuração global
./generate_opencode_config.sh -o ~/.config/opencode/opencode.json
```

### PowerShell

```powershell
# Apenas Ollama local
.\Generate-OpenCodeConfig.ps1

# Com servidores remotos
.\Generate-OpenCodeConfig.ps1 -RemoteOllamaUrl "http://192.168.1.100:11434"
.\Generate-OpenCodeConfig.ps1 -RemoteOllamaUrl "http://gpu1:11434","http://gpu2:11434"

# Seleção interativa
.\Generate-OpenCodeConfig.ps1 -Interactive

# Apenas modelos qwen
.\Generate-OpenCodeConfig.ps1 -Include "qwen*"

# Dry-run
.\Generate-OpenCodeConfig.ps1 -DryRun

# Com num_ctx
.\Generate-OpenCodeConfig.ps1 -NumCtx 32768

# Escrever na configuração global
.\Generate-OpenCodeConfig.ps1 -OutputFile "$env:USERPROFILE\.config\opencode\opencode.json"
```

## Referência CLI

### Bash

| Flag | Descrição | Padrão |
|------|-----------|--------|
| `-l, --local URL` | URL do servidor local | `$OLLAMA_HOST` ou `http://localhost:11434` |
| `-r, --remote URL` | URL do servidor remoto (repetível) | nenhum |
| `-p, --provider NOME` | Provedor: ollama, lmstudio, vllm, llama-cpp, localai, tgwui, jan, gpt4all | detecção auto |
| `-o, --output ARQUIVO` | Caminho do arquivo de saída (`-` para stdout) | `opencode.json` |
| `-n, --dry-run` | Imprimir no stdout, não escrever | desativado |
| `-i, --interactive` | Seleção interativa de modelos | desativado |
| `--include PADRÃO` | Incluir modelos que correspondem ao glob (repetível) | todos |
| `--exclude PADRÃO` | Excluir modelos que correspondem ao glob (repetível) | nenhum |
| `--with-embed` | Incluir modelos de embedding | excluídos |
| `--tools-only` | Apenas modelos com suporte a chamada de ferramentas/funções | desativado |
| `--no-context-lookup` | Pular `/api/show`, usar limites codificados | desativado |
| `--num-ctx N` | `num_ctx` para opções do provedor, 0 para omitir | `0` |
| `--merge` | Mesclar na configuração existente (atualizar apenas modelos) | desativado |
| `--default-model ID` | Definir modelo padrão explicitamente | auto |
| `--small-model ID` | Definir small_model explicitamente (para geração de títulos) | auto |
| `--no-cache` | Desativar cache de busca de contexto | desativado |
| `-v, --version` | Mostrar versão | |
| `-h, --help` | Mostrar ajuda | |

### PowerShell

| Parâmetro | Descrição | Padrão |
|-----------|-----------|--------|
| `-LocalOllamaUrl` | URL do Ollama local | `$OLLAMA_HOST` ou `http://localhost:11434` |
| `-RemoteOllamaUrl` | URL(s) remota(s) (array) | nenhuma |
| `-OutputFile` | Caminho do arquivo de saída | `opencode.json` |
| `-DryRun` | Imprimir no stdout, não escrever | desativado |
| `-Interactive` | Seleção interativa de modelos | desativado |
| `-Include` | Padrões de inclusão (wildcard, array) | todos |
| `-Exclude` | Padrões de exclusão (wildcard, array) | nenhum |
| `-WithEmbed` | Incluir modelos de embedding | excluídos |
| `-ToolsOnly` | Apenas modelos com suporte a chamada de ferramentas/funções | desativado |
| `-NoContextLookup` | Pular `/api/show`, usar limites codificados | desativado |
| `-NumCtx` | `num_ctx` para opções do provedor, 0 para omitir | `0` |
| `-Merge` | Mesclar na configuração existente (atualizar apenas modelos) | desativado |
| `-DefaultModel` | Definir modelo padrão explicitamente | auto |
| `-SmallModel` | Definir small_model explicitamente (para geração de títulos) | auto |
| `-NoCache` | Desativar cache de busca de contexto | desativado |
| `-Version` | Mostrar versão | |
| `-Help` | Mostrar ajuda | |

## Como funciona

1. **Buscar modelos** de cada servidor Ollama via `GET /api/tags`
2. **Filtrar** modelos de embedding pelo campo `families` (`nomic-bert`, `bert`, etc.)
3. **Filtrar** por padrões include/exclude (correspondência glob)
4. **Obter comprimentos de contexto** para cada modelo via `POST /api/show` (paralelo, com cache)
5. **Desduplicar** modelos encontrados em múltiplos servidores (mantém a versão do primeiro servidor)
6. **Seleção interativa** (se `-i`): lista numerada com opção `[0] Todos os modelos`
7. **Mesclar** (se `--merge`): preservar configurações existentes e outros provedores
8. **Detectar automaticamente `small_model`**: menor modelo não-embed por contagem de parâmetros
9. **Gerar** `opencode.json` com Ollama como provedor

## Estrutura de configuração gerada

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

### Campos

| Campo | Descrição |
|-------|-----------|
| `provider.ollama.options.baseURL` | Endpoint compatível com OpenAI do Ollama |
| `provider.ollama.models.*.limit.context` | Janela de contexto máxima para o modelo |
| `provider.ollama.models.*.limit.output` | Tokens de saída máximos (limitados a 16K) |
| `model` | Modelo padrão (primeiro disponível) |
| `small_model` | Menor modelo para tarefas leves (geração de títulos) |

## Detecção de contexto do modelo

Os comprimentos de contexto são determinados nesta ordem de prioridade:

1. **Busca API** — `POST /api/show` retorna `model_info.*.context_length` (valor exato)
2. **Fallback codificado** — estimado por família de modelo:

| Família | Contexto padrão |
|---------|:---------------:|
| qwen, qwen2 | 32.768 |
| llama | 8.192 |
| mistral, mixtral | 32.768 |
| deepseek | 65.536 |
| command, command-r | 131.072 |
| yi | 200.000 |
| gemma | 8.192 |
| phi | 4.096 |
| codestral | 32.768 |
| granite | 8.192 |
| outro | 8.192 |

Use `--no-context-lookup` para pular chamadas API e usar apenas valores codificados (mais rápido).

## Modelos de embedding

Modelos de embedding são **excluídos por padrão** porque não suportam chamada de chat/ferramentas. A detecção é baseada em:

- Famílias de modelos contendo `nomic-bert`, `bert`, `bert-moe`, `embed`, `embedding`
- Nomes de modelos contendo essas palavras-chave

Use `--with-embed` / `-WithEmbed` para incluí-los.

## Filtro de chamada de ferramentas/funções

Use `--tools-only` / `-ToolsOnly` para incluir apenas modelos que suportam chamada de ferramentas/funções:

```bash
./generate_opencode_config.sh --tools-only
```

A detecção funciona em dois níveis:
1. **Exato** — LM Studio fornece `capabilities.tool_use` via seu endpoint rico `/api/v1/models`
2. **Heurístico** — para todos os outros provedores, os modelos são comparados com uma lista de permissão conhecida de famílias capazes de ferramentas (qwen2.5/3, llama3.x, mistral, mixtral, deepseek-r1/v3, command-r, phi3/4, gemma2/3, granite3.x)

Modelos que não correspondem a nenhuma verificação são excluídos quando `--tools-only` está ativo. A lista de permissão pode precisar de atualizações conforme novas famílias de modelos são lançadas.

## Suporte a múltiplos provedores

Funciona com 8 provedores de inferência local. O provedor é detectado automaticamente pela porta, ou especifique com `-p`.

| Provedor | Porta padrão | Metadados ricos | Detecção auto |
|----------|:------------:|:---------------:|:-------------:|
| **Ollama** | 11434 | `/api/show` (contexto, famílias) | ✅ |
| **LM Studio** | 1234 | `/api/v1/models` (tipo, capacidades, contexto) | ✅ |
| **vLLM** | 8000 | apenas básico | ✅ |
| **llama.cpp** | 8080 | `/props` (context_size) | ✅ (como localai) |
| **LocalAI** | 8080 | apenas básico | ✅ |
| **text-generation-webui** | 5000 | apenas básico | ✅ |
| **Jan.ai** | 1337 | apenas básico | ✅ |
| **GPT4All** | 4891 | apenas básico | ✅ |

```bash
# Detecção automática por porta
./generate_opencode_config.sh -l http://localhost:1234       # LM Studio
./generate_opencode_config.sh -l http://localhost:8000       # vLLM

# Provedor explícito
./generate_opencode_config.sh -l http://localhost:8080 -p llama-cpp

# Ollama + LM Studio juntos
./generate_opencode_config.sh -l http://localhost:11434 -r http://localhost:1234 -p lmstudio
```

Cada provedor aparece como um bloco separado no `opencode.json`:

```json
{
  "provider": {
    "ollama": { "name": "Ollama", "options": { "baseURL": "http://localhost:11434/v1" }, ... },
    "lmstudio": { "name": "LM Studio", "options": { "baseURL": "http://localhost:1234/v1" }, ... }
  }
}
```

## Cache de busca de contexto

Os comprimentos de contexto de `/api/show` são armazenados em cache em `~/.cache/opencode-generator/` por hash de URL. O cache expira após 24 horas. Execuções subsequentes reutilizam valores em cache e buscam apenas novos modelos. Use `--no-cache` para desativar.

## Modo de mesclagem

Use `--merge` para atualizar modelos em um `opencode.json` existente sem sobrescrever outras configurações (provedores personalizados, temas, regras, etc.):

```bash
# Geração inicial
./generate_opencode_config.sh -o opencode.json

# Adicionar manualmente provedores personalizados, regras, etc. ao opencode.json

# Depois: atualizar apenas modelos, manter todo o resto
./generate_opencode_config.sh --merge -o opencode.json
```

## Desduplicação

Se o mesmo modelo existe em múltiplos servidores, cada cópia recebe um nome único com sufixo de servidor:

```
qwen2.5-coder:7b                → servidor local (nome original)
qwen2.5-coder:7b@gpu-server     → primeiro servidor remoto
qwen2.5-coder:7b@gpu-server-2   → segundo servidor remoto com mesmo hostname
```

Ambas as versões aparecem em `/models`. O resumo mostra quais modelos receberam sufixo.

## Variáveis de ambiente

| Variável | Descrição |
|----------|-----------|
| `OLLAMA_HOST` | URL padrão do Ollama local (variável padrão do Ollama) |
| `XDG_CACHE_HOME` | Caminho base do diretório de cache |

## Instalando a configuração gerada

```bash
# Configuração global (todos os projetos)
cp opencode.json ~/.config/opencode/opencode.json

# Específico do projeto
cp opencode.json /caminho/do/projeto/opencode.json
```

## Solução de problemas

### "Não foi possível conectar ao Ollama"

- Certifique-se de que o Ollama está em execução: `ollama serve`
- Verifique a URL: `curl http://localhost:11434/api/tags`
- Se estiver usando porta/host personalizado, defina `OLLAMA_HOST` ou use `-l`

### "Dependências necessárias ausentes: python3"

```bash
# Ubuntu/Debian
sudo apt install python3

# macOS
brew install python3

# Windows: baixar de https://python.org
```

### Comprimento de contexto incorreto

- O script usa `/api/show` por padrão para valores exatos
- Se a API for lenta, use `--no-context-lookup` para estimativas codificadas
- Substitua manualmente no JSON gerado se necessário

### Modelos de embedding incluídos/excluídos inesperadamente

- Verifique famílias na saída de `ollama show <model>`
- Use `--with-embed` para forçar inclusão
- Use `--exclude "*embed*"` para forçar exclusão por nome

### "Provedor retornou erro" no OpenCode

- Alguns modelos do Ollama não suportam chamada de ferramentas — tente `qwen2.5-coder` ou `llama3.2`
- Aumente `num_ctx` se as ferramentas falharem: `--num-ctx 32768`
- Certifique-se de que o modelo está carregado: `ollama run <model>`
