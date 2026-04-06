#
# OpenCode Config Generator for Ollama (PowerShell)
# Generates opencode.json configuration from local and remote Ollama servers.
#
# https://github.com/anomalyco/opencode
#

[CmdletBinding()]
param(
    [string]$LocalOllamaUrl = "",
    [string[]]$RemoteOllamaUrl = @(),
    [string]$Provider = "",
    [string]$OutputFile = "$env:USERPROFILE\.config\opencode\opencode.json",
    [switch]$DryRun,
    [switch]$Interactive,
    [string[]]$Include = @(),
    [string[]]$Exclude = @(),
    [switch]$WithEmbed,
    [switch]$NoContextLookup,
    [int]$NumCtx = 0,
    [int]$MaxOutput = 16384,
    [switch]$Merge,
    [switch]$Force,
    [switch]$Diff,
    [string]$DefaultModel = "",
    [string]$SmallModel = "",
    [string]$MaxSize = "",
    [string]$MinSize = "",
    [string]$Sort = "",
    [int]$Limit = 0,
    [switch]$NoCache,
    [switch]$NoColor,
    [switch]$Quiet,
    [string]$Check = "",
    [switch]$ToolsOnly,
    [switch]$Version,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

# ============================================================================
# Defaults
# ============================================================================

$ScriptVersion = "1.4.4"
$CacheTTL = 86400  # 24 hours

if (-not $LocalOllamaUrl) {
    $LocalOllamaUrl = if ($env:OLLAMA_HOST) { $env:OLLAMA_HOST } else { "http://localhost:11434" }
}

$EmbedKeywords = @("nomic-bert", "bert", "bert-moe", "embed", "embedding", "jina-embeddings")

$ToolCapableFamilies = @(
    "qwen2.5", "qwen2.5-coder", "qwen3", "qwen3-coder",
    "llama3", "llama3.1", "llama3.2", "llama3.3",
    "mistral", "mistral-nemo", "mixtral",
    "deepseek-r1", "deepseek-v3",
    "command-r", "command-r-plus", "command-a",
    "phi3", "phi4",
    "gemma2", "gemma3",
    "granite3", "granite3.1", "granite3.2"
)

$HardcodedContext = @{
    "qwen3"       = 131072
    "qwen2.5"     = 131072
    "qwen2"       = 32768
    "qwen"        = 32768
    "llama3"      = 131072
    "llama2"      = 4096
    "llama"       = 131072
    "mistral-nemo"= 131072
    "mistral"     = 32768
    "mixtral"     = 32768
    "deepseek-r1" = 131072
    "deepseek-v3" = 131072
    "deepseek"    = 65536
    "gemma2"      = 8192
    "gemma"       = 8192
    "phi4"        = 16384
    "phi3"        = 131072
    "phi"         = 4096
    "command-a"   = 131072
    "command-r-plus" = 131072
    "command-r"   = 131072
    "command"     = 131072
    "yi"          = 200000
    "codestral"   = 32768
    "granite3"    = 131072
    "granite"     = 8192
    "internlm2"   = 32768
    "internlm"    = 32768
    "falcon"      = 8192
    "orca"        = 4096
    "neural-chat" = 4096
    "starcoder2"  = 16384
    "starcoder"   = 8192
    "codegemma"   = 8192
    "nemotron"    = 131072
    "jamba"       = 256000
    "aya"         = 131072
    "exaone"      = 32768
    "glm"         = 131072
    "minicpm"     = 32768
}

# ============================================================================
# Helpers
# ============================================================================

$IsTerminal = [System.Console]::IsOutputRedirected -eq $false
if ($NoColor -or -not $IsTerminal) {
    function Write-Info  { param($m) if (-not $Quiet) { Write-Host "[INFO] $m" } }
    function Write-Warn  { param($m) Write-Host "[WARN] $m" }
    function Write-Err   { param($m) Write-Host "[ERROR] $m" }
    function Write-Step  { param($m) if (-not $Quiet) { Write-Host "[STEP] $m" } }
} else {
    function Write-Info  { param($m) if (-not $Quiet) { Write-Host "[INFO] $m" -ForegroundColor Green } }
    function Write-Warn  { param($m) Write-Host "[WARN] $m" -ForegroundColor Yellow }
    function Write-Err   { param($m) Write-Host "[ERROR] $m" -ForegroundColor Red }
    function Write-Step  { param($m) if (-not $Quiet) { Write-Host "[STEP] $m" -ForegroundColor Cyan } }
}

function Show-Help {
    @"
Usage: Generate-OpenCodeConfig.ps1 [OPTIONS]

Generates opencode.json configuration from Ollama models.

OPTIONS:
    -LocalOllamaUrl URL        Local server URL (default: `$OLLAMA_HOST or http://localhost:11434)
    -RemoteOllamaUrl URL       Remote server URL(s) (can be array)
    -Provider NAME             Provider: ollama|lmstudio|vllm|llama-cpp|localai|tgwui|jan|gpt4all
    -OutputFile FILE           Output file path (default: ~/.config/opencode/opencode.json)
    -DryRun                    Print config to stdout, do not write file
    -Interactive               Interactive model selection
    -Include PATTERN           Include models matching wildcard pattern (array)
    -Exclude PATTERN           Exclude models matching wildcard pattern (array)
    -WithEmbed                 Include embedding models (excluded by default)
    -ToolsOnly                 Only include models that support tool/function calling
    -NoContextLookup           Skip /api/show calls, use hardcoded context limits
    -NumCtx N                  num_ctx for Ollama provider, 0 to omit (default: 0)
    -MaxOutput N               Max output tokens cap (default: 16384)
    -Merge                     Merge into existing opencode.json (update models only)
    -Force                     Overwrite output file without prompting
    -Diff                      Show diff between old and new config (with -Merge)
    -DefaultModel ID           Set default model explicitly (e.g. qwen2.5-coder:7b)
    -SmallModel ID             Set small model explicitly (for title generation)
    -MaxSize SIZE              Exclude models larger than SIZE (e.g. 7B, 13B)
    -MinSize SIZE              Exclude models smaller than SIZE (e.g. 1B)
    -Sort ORDER                Sort models: name, size, family (default: api order)
    -Limit N                   Limit output to N models
    -NoCache                   Disable context lookup cache
    -NoColor                   Disable colored output
    -Quiet                     Suppress non-error output
    -Check FILE                Validate an existing opencode.json file
    -Version                   Show version
    -Help                      Show this help
"@
    exit 0
}

if ($Help) { Show-Help }
if ($Version) { Write-Host "Generate-OpenCodeConfig.ps1 v$ScriptVersion"; exit 0 }

# Check mode
if ($Check) {
    if (-not (Test-Path $Check)) {
        Write-Err "File not found: $Check"
        exit 1
    }
    try {
        $config = Get-Content $Check -Raw | ConvertFrom-Json -AsHashtable
        $errors = @()
        if (-not $config.ContainsKey('$schema')) { $errors += "Missing `$schema" }
        if (-not $config.ContainsKey('provider')) { $errors += "Missing provider" }
        if (-not $config.ContainsKey('model')) { $errors += "Missing model" }
        foreach ($pid in $config.provider.Keys) {
            $pdata = $config.provider[$pid]
            if (-not $pdata.ContainsKey('models')) { $errors += "Provider $pid has no models" }
            if (-not $pdata.ContainsKey('options') -or -not $pdata.options.ContainsKey('baseURL')) {
                $errors += "Provider $pid missing baseURL"
            }
        }
        $modelRef = $config.model
        if ($modelRef -match '^(.+?)/(.+)$') {
            $provId = $Matches[1]; $modelId = $Matches[2]
            if ($config.provider.ContainsKey($provId)) {
                if (-not $config.provider[$provId].models.ContainsKey($modelId)) {
                    $errors += "Default model $modelRef not found in provider models"
                }
            }
        }
        if ($errors.Count -gt 0) {
            Write-Err "INVALID: $Check"
            foreach ($e in $errors) { Write-Err "  - $e" }
            exit 1
        } else {
            $modelCount = ($config.provider.Values | ForEach-Object { $_.models.Count } | Measure-Object -Sum).Sum
            Write-Host "VALID: $Check ($modelCount models, $($config.provider.Count) providers)"
            exit 0
        }
    } catch {
        Write-Err "INVALID JSON: $_"
        exit 1
    }
}

# Validate URLs
if ($LocalOllamaUrl -and $LocalOllamaUrl -notmatch "^https?://") {
    Write-Err "Invalid URL: $LocalOllamaUrl (must start with http:// or https://)"
    exit 1
}
foreach ($rUrl in $RemoteOllamaUrl) {
    if ($rUrl -notmatch "^https?://") {
        Write-Err "Invalid URL: $rUrl (must start with http:// or https://)"
        exit 1
    }
}

# Early write permission check
if (-not $DryRun) {
    $outDir = Split-Path $OutputFile -Parent
    if ($outDir -and -not (Test-Path $outDir)) {
        New-Item -Path $outDir -ItemType Directory -Force | Out-Null
    }
    if ((Test-Path $OutputFile) -and -not $Merge -and -not $Force) {
        Write-Warn "File already exists: $OutputFile"
        if ([System.Console]::IsInputRedirected -eq $false) {
            $confirm = Read-Host "Overwrite? (y/N)"
            if ($confirm -notmatch '^[yY]') {
                Write-Info "Aborted."
                exit 0
            }
        } else {
            Write-Err "File already exists: $OutputFile (use -Force to overwrite)"
            exit 1
        }
    }
}

# ============================================================================
# Functions
# ============================================================================

function Get-OllamaModels {
    param([string]$Url, [string]$Label)
    Write-Step "Fetching models from $Label ($Url/api/tags)..."
    try {
        $response = Invoke-RestMethod -Uri "$Url/api/tags" -Method Get -TimeoutSec 15 -ErrorAction Stop
        return $response
    }
    catch {
        Write-Warn "Could not connect to $Label ($Url): $_"
        return $null
    }
}

function Get-ContextLength {
    param([string]$Url, [string]$ModelName)
    try {
        $body = @{ model = $ModelName } | ConvertTo-Json
        $response = Invoke-RestMethod -Uri "$Url/api/show" -Method Post -Body $body `
            -ContentType "application/json" -TimeoutSec 10 -ErrorAction Stop
        $info = $response.model_info
        foreach ($key in $info.PSObject.Properties.Name) {
            if ($key -match "context_length") {
                return [int]$info.$key
            }
        }
    }
    catch {}
    return $null
}

function Get-AllContextLengths {
    param([string]$Url, [string[]]$ModelNames)
    Write-Step "Fetching context lengths for $($ModelNames.Count) models..."
    $result = @{}
    $jobs = @()

    foreach ($name in $ModelNames) {
        $jobs += Start-Job -ScriptBlock {
            param($u, $n)
            try {
                $body = @{ model = $n } | ConvertTo-Json
                $r = Invoke-RestMethod -Uri "$u/api/show" -Method Post -Body $body `
                    -ContentType "application/json" -TimeoutSec 10 -ErrorAction Stop
                foreach ($k in $r.model_info.PSObject.Properties.Name) {
                    if ($k -match "context_length") {
                        return @{ name = $n; ctx = [int]$r.model_info.$k }
                    }
                }
            }
            catch {}
            return @{ name = $n; ctx = $null }
        } -ArgumentList $Url, $name
    }

    $jobs | Wait-Job -Timeout 30 | Out-Null
    foreach ($job in $jobs) {
        $r = Receive-Job $job -ErrorAction SilentlyContinue
        if ($r -and $r.ctx) {
            $result[$r.name] = $r.ctx
        }
        Remove-Job $job -Force
    }
    return $result
}

function Detect-FamilyFromName {
    param([string]$Name)
    $nl = $Name.ToLower()
    if ($nl.Contains("qwen3.5") -or $nl.Contains("qwen35")) { return "qwen3.5" }
    if ($nl.Contains("qwen3-coder") -or $nl.Contains("qwen3_coder")) { return "qwen3-coder" }
    if ($nl.Contains("qwen3")) { return "qwen3" }
    if ($nl.Contains("qwen2.5")) { return "qwen2.5" }
    if ($nl.Contains("qwen2")) { return "qwen2" }
    if ($nl.Contains("qwen")) { return "qwen" }
    if ($nl.Contains("codestral")) { return "codestral" }
    if ($nl.Contains("mistral-nemo")) { return "mistral-nemo" }
    if ($nl.Contains("mistral")) { return "mistral" }
    if ($nl.Contains("mixtral")) { return "mixtral" }
    if ($nl.Contains("llama3.3")) { return "llama3.3" }
    if ($nl.Contains("llama3.2")) { return "llama3.2" }
    if ($nl.Contains("llama3.1")) { return "llama3.1" }
    if ($nl.Contains("llama3")) { return "llama3" }
    if ($nl.Contains("llama2")) { return "llama2" }
    if ($nl.Contains("llama")) { return "llama" }
    if ($nl.Contains("deepseek-r1")) { return "deepseek-r1" }
    if ($nl.Contains("deepseek-v3")) { return "deepseek-v3" }
    if ($nl.Contains("deepseek")) { return "deepseek" }
    if ($nl.Contains("gemma2")) { return "gemma2" }
    if ($nl.Contains("gemma")) { return "gemma" }
    if ($nl.Contains("phi4")) { return "phi4" }
    if ($nl.Contains("phi3")) { return "phi3" }
    if ($nl.Contains("phi")) { return "phi" }
    if ($nl.Contains("command-r-plus")) { return "command-r-plus" }
    if ($nl.Contains("command-r")) { return "command-r" }
    if ($nl.Contains("command")) { return "command" }
    if ($nl.Contains("granite3.2")) { return "granite3.2" }
    if ($nl.Contains("granite3.1")) { return "granite3.1" }
    if ($nl.Contains("granite3")) { return "granite3" }
    if ($nl.Contains("granite")) { return "granite" }
    if ($nl.Contains("internlm2")) { return "internlm2" }
    if ($nl.Contains("internlm")) { return "internlm" }
    if ($nl.Contains("falcon")) { return "falcon" }
    if ($nl.Contains("starcoder2")) { return "starcoder2" }
    if ($nl.Contains("starcoder")) { return "starcoder" }
    if ($nl.Contains("codegemma")) { return "codegemma" }
    if ($nl.Contains("nemotron")) { return "nemotron" }
    if ($nl.Contains("jamba")) { return "jamba" }
    if ($nl.Contains("exaone")) { return "exaone" }
    if ($nl.Contains("minicpm")) { return "minicpm" }
    return ""
}

function Detect-FamilyFromName {
    param([string]$Name)
    $nl = $Name.ToLower()
    if ($nl.Contains("qwen3.5") -or $nl.Contains("qwen35")) { return "qwen3.5" }
    if ($nl.Contains("qwen3-coder") -or $nl.Contains("qwen3_coder")) { return "qwen3-coder" }
    if ($nl.Contains("qwen3")) { return "qwen3" }
    if ($nl.Contains("qwen2.5")) { return "qwen2.5" }
    if ($nl.Contains("qwen2")) { return "qwen2" }
    if ($nl.Contains("qwen")) { return "qwen" }
    if ($nl.Contains("codestral")) { return "codestral" }
    if ($nl.Contains("mistral-nemo")) { return "mistral-nemo" }
    if ($nl.Contains("mistral")) { return "mistral" }
    if ($nl.Contains("mixtral")) { return "mixtral" }
    if ($nl.Contains("llama3.3")) { return "llama3.3" }
    if ($nl.Contains("llama3.2")) { return "llama3.2" }
    if ($nl.Contains("llama3.1")) { return "llama3.1" }
    if ($nl.Contains("llama3")) { return "llama3" }
    if ($nl.Contains("llama2")) { return "llama2" }
    if ($nl.Contains("llama")) { return "llama" }
    if ($nl.Contains("deepseek-r1")) { return "deepseek-r1" }
    if ($nl.Contains("deepseek-v3")) { return "deepseek-v3" }
    if ($nl.Contains("deepseek")) { return "deepseek" }
    if ($nl.Contains("gemma2")) { return "gemma2" }
    if ($nl.Contains("gemma")) { return "gemma" }
    if ($nl.Contains("phi4")) { return "phi4" }
    if ($nl.Contains("phi3")) { return "phi3" }
    if ($nl.Contains("phi")) { return "phi" }
    if ($nl.Contains("command-r-plus")) { return "command-r-plus" }
    if ($nl.Contains("command-r")) { return "command-r" }
    if ($nl.Contains("command")) { return "command" }
    if ($nl.Contains("granite3.2")) { return "granite3.2" }
    if ($nl.Contains("granite3.1")) { return "granite3.1" }
    if ($nl.Contains("granite3")) { return "granite3" }
    if ($nl.Contains("granite")) { return "granite" }
    if ($nl.Contains("internlm2")) { return "internlm2" }
    if ($nl.Contains("internlm")) { return "internlm" }
    if ($nl.Contains("falcon")) { return "falcon" }
    if ($nl.Contains("starcoder2")) { return "starcoder2" }
    if ($nl.Contains("starcoder")) { return "starcoder" }
    if ($nl.Contains("codegemma")) { return "codegemma" }
    if ($nl.Contains("nemotron")) { return "nemotron" }
    if ($nl.Contains("jamba")) { return "jamba" }
    if ($nl.Contains("exaone")) { return "exaone" }
    if ($nl.Contains("minicpm")) { return "minicpm" }
    return ""
}

function Test-IsEmbedModel {
    param([string[]]$Families, [string]$Name)
    $allText = ($Families -join " ").ToLower() + " " + $Name.ToLower()
    foreach ($kw in $EmbedKeywords) {
        if ($allText.Contains($kw.ToLower())) { return $true }
    }
    return $false
}

function Test-IsToolCapable {
    param([object]$Model)
    $caps = $Model.capabilities
    if ($caps -and $caps.tool_use) { return $true }
    
    $families = @($Model.details.families)
    $family = $Model.details.family
    $name = $Model.name.ToLower()
    $allText = (($families + @($family)) -join " ").ToLower() + " " + $name
    
    foreach ($kw in $ToolCapableFamilies) {
        if ($allText.Contains($kw.ToLower())) { return $true }
    }
    return $false
}

function Get-HardcodedContext {
    param([string]$Family)
    $fl = $Family.ToLower()
    # Sort by key length descending for more specific matches first
    $sortedKeys = $HardcodedContext.Keys | Sort-Object { $_.Length } -Descending
    foreach ($key in $sortedKeys) {
        if ($fl.Contains($key)) { return $HardcodedContext[$key] }
    }
    return 8192
}

function Parse-ParamSize {
    param([string]$ParamStr)
    try {
        $ps = $ParamStr.ToUpper().Trim()
        $mult = 1
        if ($ps.Contains("B")) { $mult = 1000000000 }
        elseif ($ps.Contains("M")) { $mult = 1000000 }
        $val = [double]($ps.Replace("B","").Replace("M","").Trim())
        return $val * $mult
    } catch {
        return [double]::MaxValue
    }
}

function Test-MatchesInclude {
    param([string]$Name, [string[]]$Patterns)
    if ($Patterns.Count -eq 0) { return $true }
    foreach ($pat in $Patterns) {
        if ($Name -like $pat) { return $true }
    }
    return $false
}

function Test-MatchesExclude {
    param([string]$Name, [string[]]$Patterns)
    foreach ($pat in $Patterns) {
        if ($Name -like $pat) { return $true }
    }
    return $false
}

function Select-ModelsInteractive {
    param([object[]]$ModelsData, [string]$Label)
    
    Write-Host ""
    Write-Host "Available models from $Label :" -ForegroundColor White
    Write-Host ""
    
    Write-Host "  [0] -- All models --" -ForegroundColor DarkGray
    
    $i = 1
    foreach ($m in $ModelsData) {
        $name = $m.name
        $d = $m.details
        $family = if ($d.family) { $d.family.Substring(0,1).ToUpper() + $d.family.Substring(1) } else { "?" }
        $param = $d.parameter_size
        $quant = $d.quantization_level
        $ctx = if ($m.context) { $m.context } else { "?" }
        Write-Host "  [$i] $name  $family $param $quant ctx=$ctx" -ForegroundColor White
        $i++
    }
    
    Write-Host ""
    $sel = Read-Host "Select models (comma-separated, e.g. 1,3,5 or 0 for all) [0]"
    
    if ([string]::IsNullOrWhiteSpace($sel) -or $sel -eq "0") {
        return $ModelsData
    }
    
    $indices = @()
    foreach ($s in $sel.Split(',')) {
        $s = $s.Trim()
        if ($s -eq "0") { return $ModelsData }
        try {
            $idx = [int]$s - 1
            if ($idx -ge 0 -and $idx -lt $ModelsData.Count) { $indices += $idx }
        } catch {}
    }
    
    return @($ModelsData[$indices])
}

function Process-Models {
    param(
        [object]$ModelsData,
        [string]$Label,
        [hashtable]$CtxMap,
        [string]$ServerUrl = ""
    )
    
    $result = [ordered]@{}
    
    if (-not $ModelsData -or -not $ModelsData.models) { return $result }
    
    $NoEmbed = -not $WithEmbed
    
    foreach ($m in $ModelsData.models) {
        $name = $m.name
        if (-not $name) { continue }
        
        $d = $m.details
        $family = $d.family
        $families = @($d.families)
        $paramSize = $d.parameter_size
        $quant = $d.quantization_level
        
        # Fallback: if API family is empty or generic "llama", detect from name
        if (-not $family -or $family.ToLower() -eq "llama") {
            $detected = Detect-FamilyFromName -Name $name
            if ($detected) {
                $family = $detected
            }
        }
        
        if ($NoEmbed -and (Test-IsEmbedModel -Families ($families + @($family)) -Name $name)) { continue }
        if (-not (Test-MatchesInclude -Name $name -Patterns $Include)) { continue }
        if (Test-MatchesExclude -Name $name -Patterns $Exclude) { continue }
        if ($ToolsOnly -and -not (Test-IsToolCapable -Model $m)) { continue }
        
        # Check tooling support
        $hasTooling = Test-IsToolCapable -Model $m
        
        # Size filtering
        if ($paramSize -and ($MaxSize -or $MinSize)) {
            $ps = Parse-ParamSize -ParamStr $paramSize
            if ($MaxSize) {
                $maxVal = Parse-ParamSize -ParamStr $MaxSize
                if ($ps -gt $maxVal) { continue }
            }
            if ($MinSize) {
                $minVal = Parse-ParamSize -ParamStr $MinSize
                if ($ps -lt $minVal) { continue }
            }
        }
        
        $ctx = $null
        $ctxSource = "hardcoded"
        
        if ((-not $NoContextLookup) -and $CtxMap.ContainsKey($name)) {
            $ctx = $CtxMap[$name]
            $ctxSource = "api"
        }
        if (-not $ctx) {
            $ctx = Get-HardcodedContext -Family $family
        }
        
        # Add suffix: (local) for local, (host:port) for remote
        if ($Label -eq "local") {
            $displayName = "$name (local)"
        } else {
            try {
                $uri = [Uri]$ServerUrl
                $host = $uri.Host
                $port = $uri.Port
                $suffix = if ($port -and $port -notin @(80, 443)) { "$host`:$port" } else { $host }
                $displayName = "$name ($suffix)"
            } catch {
                $displayName = "$name ($Label)"
            }
        }
        
        $result[$name] = [ordered]@{
            "name"  = $displayName
            "limit" = [ordered]@{
                "context" = $ctx
                "output"  = [Math]::Min($ctx, $MaxOutput)
            }
            "_info" = [ordered]@{
                "name"         = $name
                "display"      = $displayName
                "family"       = $family
                "param_size"   = $paramSize
                "quantization" = $quant
                "context"      = $ctx
                "ctx_source"   = $ctxSource
                "server_label" = $Label
                "server_url"   = $ServerUrl
            }
        }
        if (-not $ctx) {
            $ctx = Get-HardcodedContext -Family $family
        }
        
        # Add (T) suffix for tooling-capable models
        $displayName = $name
        if ($hasTooling) {
            $displayName = "$name (T)"
        }
        
        $result[$name] = [ordered]@{
            "name"  = $displayName
            "limit" = [ordered]@{
                "context" = $ctx
                "output"  = [Math]::Min($ctx, $MaxOutput)
            }
            "_info" = [ordered]@{
                "name"         = $name
                "display"      = $displayName
                "family"       = $family
                "param_size"   = $paramSize
                "quantization" = $quant
                "context"      = $ctx
                "ctx_source"   = $ctxSource
                "server_label" = $Label
                "server_url"   = $ServerUrl
                "tooling"      = $hasTooling
            }
        }
    }
    
    return $result
}

function Make-ProviderOptions {
    param([string]$Url)
    $opts = @{ "baseURL" = "$Url/v1" }
    if ($NumCtx -gt 0) { $opts["num_ctx"] = $NumCtx }
    return $opts
}

# ============================================================================
# Main
# ============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  OpenCode Config Generator for Ollama" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Build server list
$allServers = @()

# Provider display names
$ProviderDisplay = @{
    "ollama" = "Ollama"; "lmstudio" = "LM Studio"; "vllm" = "vLLM"
    "llama-cpp" = "llama.cpp"; "localai" = "LocalAI"; "tgwui" = "text-generation-webui"
    "jan" = "Jan.ai"; "gpt4all" = "GPT4All"; "openai-generic" = "OpenAI-compatible"
    "openai" = "OpenAI"; "tgi" = "TGI"
}

# Auto-detect provider from port
function Detect-Provider {
    param([string]$Url)
    try {
        $uri = [Uri]$Url
        $port = $uri.Port
    } catch { $port = 0 }
    switch ($port) {
        11434 { "ollama" }
        1234  { "lmstudio" }
        8000  { "vllm" }
        5000  { "tgwui" }
        1337  { "jan" }
        4891  { "gpt4all" }
        8080  {
            Write-Warn "Port 8080 detected — defaulting to LocalAI. Use -Provider llama-cpp or -Provider tgi if needed."
            "localai"
        }
        default { "openai-generic" }
    }
}

# Determine local provider
$localProvider = if ($Provider) { $Provider } else { Detect-Provider -Url $LocalOllamaUrl }

# Local
$localModels = Get-OllamaModels -Url $LocalOllamaUrl -Label "local $localProvider"
if ($localModels) {
    if ($Interactive) {
        $localModels.models = Select-ModelsInteractive -ModelsData $localModels.models -Label "local $localProvider"
    }
    $allServers += [ordered]@{
        "url"      = $LocalOllamaUrl
        "label"    = "local"
        "provider" = $localProvider
        "models"   = $localModels
    }
}

# Remote
foreach ($rUrl in $RemoteOllamaUrl) {
    # Apply explicit -Provider to remotes if there's only one remote, otherwise auto-detect
    if ($Provider -and $RemoteOllamaUrl.Count -eq 1) {
        $rProvider = $Provider
    } else {
        $rProvider = Detect-Provider -Url $rUrl
    }
    $rModels = Get-OllamaModels -Url $rUrl -Label "remote $rProvider ($rUrl)"
    if (-not $rModels) { continue }
    if ($Interactive) {
        $rModels.models = Select-ModelsInteractive -ModelsData $rModels.models -Label "remote $rProvider ($rUrl)"
    }
    $allServers += [ordered]@{
        "url"      = $rUrl
        "label"    = "remote"
        "provider" = $rProvider
        "models"   = $rModels
    }
}

if ($allServers.Count -eq 0) {
    Write-Err "Could not fetch models from any Ollama server."
    Write-Err "Make sure Ollama is running and accessible."
    exit 1
}

# Fetch context lengths
$allCtxMaps = @{}
if (-not $NoContextLookup) {
    foreach ($server in $allServers) {
        $names = @($server.models.models | ForEach-Object { $_.name })
        if ($names.Count -gt 0) {
            $ctxMap = Get-AllContextLengths -Url $server.url -ModelNames $names
            $allCtxMaps[$server.url] = $ctxMap
        }
    }
}

# Process models
$allModels = [ordered]@{}
$serverModelMaps = [ordered]@{}

for ($i = 0; $i -lt $allServers.Count; $i++) {
    $server = $allServers[$i]
    $ctxMap = if ($allCtxMaps.ContainsKey($server.url)) { $allCtxMaps[$server.url] } else { @{} }
    
    $models = Process-Models -ModelsData $server.models -Label $server.label -CtxMap $ctxMap -ServerUrl $server.url
    
    $provType = $server.provider
    if ($allServers.Count -eq 1) { $pid = $provType }
    elseif ($i -eq 0) { $pid = $provType }
    else { $pid = "$provType-$($i + 1)" }
    
    $serverModelMaps[$pid] = [ordered]@{
        "url"      = $server.url
        "label"    = $server.label
        "provider" = $provType
        "models"   = $models
    }
    
    foreach ($k in $models.Keys) { $allModels[$k] = $models[$k] }
}

# No deduplication needed — each server gets its own provider with its own baseURL.

if ($allModels.Count -eq 0) {
    Write-Warn "No models found after filtering!"
    Write-Warn "  - Check if Ollama is running"
    Write-Warn "  - Check -Include/-Exclude patterns"
    if (-not $WithEmbed) { Write-Warn "  - Try -WithEmbed to include embedding models" }
}

# Sort
if ($Sort -eq "name") {
    $sorted = [ordered]@{}
    foreach ($k in ($allModels.Keys | Sort-Object)) { $sorted[$k] = $allModels[$k] }
    $allModels = $sorted
} elseif ($Sort -eq "size") {
    $sorted = [ordered]@{}
    foreach ($k in ($allModels.Keys | Sort-Object { Parse-ParamSize $allModels[$_]._info.param_size })) { $sorted[$k] = $allModels[$k] }
    $allModels = $sorted
} elseif ($Sort -eq "family") {
    $sorted = [ordered]@{}
    foreach ($k in ($allModels.Keys | Sort-Object { $allModels[$k]._info.family })) { $sorted[$k] = $allModels[$k] }
    $allModels = $sorted
}

# Limit
if ($Limit -gt 0 -and $allModels.Count -gt $Limit) {
    Write-Info "Limit: keeping $Limit of $($allModels.Count) models"
    $limited = [ordered]@{}
    $i = 0
    foreach ($k in $allModels.Keys) {
        if ($i -ge $Limit) { break }
        $limited[$k] = $allModels[$k]
        $i++
    }
    $allModels = $limited
}

# Build provider config — one provider per server (each has its own baseURL)
$providerConfig = [ordered]@{}

$clean = {
    param($m)
    $c = [ordered]@{}
    foreach ($k in $m.Keys) {
        if ($k -ne "_info") { $c[$k] = $m[$k] }
    }
    return $c
}

# Group servers by provider type
$provGroups = @{}
foreach ($srv in $allServers) {
    $prov = $srv.provider
    if (-not $provGroups.ContainsKey($prov)) { $provGroups[$prov] = @() }
    $provGroups[$prov] += $srv
}

# Create one provider per server
foreach ($prov in $provGroups.Keys) {
    $serverList = $provGroups[$prov]
    $provDisplay = if ($ProviderDisplay.ContainsKey($prov)) { $ProviderDisplay[$prov] } else { $prov }

    for ($i = 0; $i -lt $serverList.Count; $i++) {
        $srv = $serverList[$i]

        # Provider key: single server = "ollama", multiple = "ollama", "ollama-2", ...
        if ($serverList.Count -eq 1) {
            $provKey = $prov
        } else {
            $provKey = if ($i -eq 0) { $prov } else { "$prov-$($i + 1)" }
        }

        $displayName = if ($serverList.Count -gt 1) { "$provDisplay ($($srv.label))" } else { $provDisplay }

        # Collect models for this specific server
        $serverModels = [ordered]@{}
        foreach ($pdata in $serverModelMaps.Values) {
            if ($pdata.url -eq $srv.url) {
                foreach ($mid in $pdata.models.Keys) {
                    $serverModels[$mid] = & $clean $pdata.models[$mid]
                }
            }
        }

        if ($serverModels.Count -eq 0) { continue }

        $providerConfig[$provKey] = [ordered]@{
            "npm"     = "@ai-sdk/openai-compatible"
            "name"    = $displayName
            "options" = (Make-ProviderOptions -Url $srv.url)
            "models"  = $serverModels
        }
    }
}

# Default and small model
$firstModel = if ($allModels.Count -gt 0) { $allModels.Keys | Select-Object -First 1 } else { "llama3.2" }

if ($DefaultModel) {
    $cleanDefault = $DefaultModel -replace "^ollama/", ""
    if ($allModels.ContainsKey($cleanDefault)) {
        $firstModel = $cleanDefault
        Write-Host "Default model set to: $firstModel" -ForegroundColor Green
    }
    else {
        Write-Warn "-DefaultModel '$DefaultModel' not found, using $firstModel"
    }
}

$smallModel = $firstModel
if ($SmallModel) {
    $cleanSm = $SmallModel -replace "^ollama/", ""
    $foundSm = $null
    foreach ($k in $allModels.Keys) {
        if ($k -eq $cleanSm -or $k.StartsWith("$cleanSm@")) { $foundSm = $k; break }
    }
    if ($foundSm) {
        $smallModel = $foundSm
        Write-Host "Small model set to: $smallModel" -ForegroundColor Green
    }
    else {
        Write-Warn "-SmallModel '$SmallModel' not found, using auto-detect"
    }
}
if ($smallModel -eq $firstModel) {
    $smallestParams = [double]::MaxValue
    foreach ($name in $allModels.Keys) {
        $info = $allModels[$name]._info
        if (Test-IsEmbedModel -Families @() -Name $name) { continue }
        $ps = $info.param_size
        try {
            $mult = 1
            $psu = $ps.ToUpper()
            if ($psu.Contains("B")) { $mult = 1000000000 }
            elseif ($psu.Contains("M")) { $mult = 1000000 }
            $val = [double]($psu.Replace("B","").Replace("M","").Trim())
            $p = $val * $mult
            if ($p -gt 0 -and $p -lt $smallestParams) {
                $smallestParams = $p
                $smallModel = $name
            }
        } catch {}
    }
}

# Build final config
function Find-ProviderForModel {
    param($modelKey)
    foreach ($provId in $providerConfig.Keys) {
        if ($providerConfig[$provId].models.ContainsKey($modelKey)) {
            return $provId
        }
    }
    return if ($providerConfig.Count -gt 0) { $providerConfig.Keys | Select-Object -First 1 } else { "ollama" }
}

$firstProvId = Find-ProviderForModel -modelKey $firstModel
$config = [ordered]@{
    "`$schema" = "https://opencode.ai/config.json"
    "provider" = $providerConfig
    "model"    = "$firstProvId/$firstModel"
}
if ($smallModel -ne $firstModel) {
    $smallProvId = Find-ProviderForModel -modelKey $smallModel
    $config["small_model"] = "$smallProvId/$smallModel"
}
    }
    return if ($providerConfig.Count -gt 0) { $providerConfig.Keys | Select-Object -First 1 } else { "ollama" }
}

$firstProvId = Find-ProviderForModel -modelKey $firstModel
$config = [ordered]@{
    "`$schema" = "https://opencode.ai/config.json"
    "provider" = $providerConfig
    "model"    = "$firstProvId/$firstModel"
}
if ($smallModel -ne $firstModel) {
    $smallProvId = Find-ProviderForModel -modelKey $smallModel
    $config["small_model"] = "$smallProvId/$smallModel"
}

# Merge: load existing config and keep non-provider keys
$existing = $null
if ($Merge -and (Test-Path $OutputFile)) {
    try {
        $existing = Get-Content $OutputFile -Raw | ConvertFrom-Json -AsHashtable
        Write-Info "Merge: loading existing config from $OutputFile"
        foreach ($key in $existing.Keys) {
            if (@("provider", "model", "small_model", "`$schema") -notcontains $key) {
                $config[$key] = $existing[$key]
            }
        }
        # Keep other providers
        if ($existing.ContainsKey("provider")) {
            foreach ($provId in $existing.provider.Keys) {
                if (-not $config.provider.ContainsKey($provId)) {
                    $config.provider[$provId] = $existing.provider[$provId]
                    Write-Info "Merge: kept existing provider '$provId'"
                }
            }
        }
    }
    catch {
        Write-Warn "Merge: could not read existing config: $_"
    }
}

# Output
$jsonStr = $config | ConvertTo-Json -Depth 50

# Diff mode
if ($Diff -and $existing) {
    $existingStr = $existing | ConvertTo-Json -Depth 50
    Write-Host "=== DIFF: old -> new ===" -ForegroundColor Cyan
    $oldLines = $existingStr -split "`n"
    $newLines = $jsonStr -split "`n"
    $diffResult = Compare-Object $oldLines $newLines
    if ($diffResult) {
        foreach ($d in $diffResult) {
            if ($d.SideIndicator -eq "=>") {
                Write-Host "+ $($d.InputObject)" -ForegroundColor Green
            } else {
                Write-Host "- $($d.InputObject)" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "No changes."
    }
    Write-Host ""
}

if ($DryRun -or $OutputFile -eq "-") {
    Write-Host $jsonStr
}
else {
    $jsonStr | Set-Content -Path $OutputFile -Encoding UTF8
}

# Summary
$total = $allModels.Count
$skippedEmbed = 0
$skippedTools = 0
foreach ($server in $allServers) {
    foreach ($m in $server.models.models) {
        $families = @($m.details.families)
        $family = $m.details.family
        if (Test-IsEmbedModel -Families ($families + @($family)) -Name $m.name) {
            $skippedEmbed++
        }
        if (-not (Test-IsToolCapable -Model $m)) {
            $skippedTools++
        }
    }
}
$apiCtx = ($allModels.Values | Where-Object { $_._info.ctx_source -eq "api" }).Count
$hardcodedCtx = ($allModels.Values | Where-Object { $_._info.ctx_source -eq "hardcoded" }).Count

Write-Host ""
Write-Host "Results:" -ForegroundColor Green
Write-Host "  Models included:      $total" -ForegroundColor White
if ($skippedEmbed -gt 0) {
    Write-Host "  Embedding filtered:   $skippedEmbed" -ForegroundColor White
}
if ($skippedTools -gt 0) {
    Write-Host "  Tools filtered:       $skippedTools" -ForegroundColor White
}
if ($dupInfo.Count -gt 0) {
    Write-Host "  Duplicates (suffixed): $($dupInfo.Count)" -ForegroundColor White
}
if ($apiCtx -gt 0 -or $hardcodedCtx -gt 0) {
    Write-Host "  Context from API:     $apiCtx" -ForegroundColor White
    Write-Host "  Context hardcoded:    $hardcodedCtx" -ForegroundColor White
}
Write-Host "  Default model:        $firstModel" -ForegroundColor White
if ($smallModel -ne $firstModel) {
    Write-Host "  Small model:          $smallModel" -ForegroundColor White
}
if ($NumCtx -gt 0) {
    Write-Host "  num_ctx:              $NumCtx" -ForegroundColor White
}
if ($Merge) {
    Write-Host "  Merge mode:           on" -ForegroundColor White
}

Write-Host ""
Write-Host "Models:" -ForegroundColor Green
foreach ($name in $allModels.Keys) {
    $info = $allModels[$name]._info
    $fam = if ($info.family) { $info.family.Substring(0,1).ToUpper() + $info.family.Substring(1) } else { "?" }
    $par = if ($info.param_size) { $info.param_size } else { "?" }
    $qua = if ($info.quantization) { $info.quantization } else { "?" }
    $ctx = $info.context
    $src = if ($info.ctx_source -eq "api") { "" } else { " (hardcoded)" }
    Write-Host "  - $name  $fam $par $qua ctx=$ctx$src" -ForegroundColor White
}

if ($DryRun) {
    Write-Host ""
    Write-Host "(Dry-run mode: config printed above, not written to file)" -ForegroundColor Yellow
}
else {
    Write-Host ""
    Write-Info "Config written to: $OutputFile"
}

Write-Info "Done!"
