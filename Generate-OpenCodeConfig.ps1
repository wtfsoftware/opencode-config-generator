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
    [string]$OutputFile = "opencode.json",
    [switch]$DryRun,
    [switch]$Interactive,
    [string[]]$Include = @(),
    [string[]]$Exclude = @(),
    [switch]$WithEmbed,
    [switch]$NoContextLookup,
    [int]$NumCtx = 0,
    [switch]$Merge,
    [string]$DefaultModel = "",
    [string]$SmallModel = "",
    [switch]$NoCache,
    [switch]$Version,
    [switch]$Help
)

# ============================================================================
# Defaults
# ============================================================================

$ScriptVersion = "1.1.0"
$CacheTTL = 86400  # 24 hours

if (-not $LocalOllamaUrl) {
    $LocalOllamaUrl = if ($env:OLLAMA_HOST) { $env:OLLAMA_HOST } else { "http://localhost:11434" }
}

$EmbedKeywords = @("nomic-bert", "bert", "bert-moe", "embed", "embedding", "jina-embeddings")

$HardcodedContext = @{
    "qwen"       = 32768
    "llama"      = 8192
    "mistral"    = 32768
    "mixtral"    = 32768
    "deepseek"   = 65536
    "gemma"      = 8192
    "phi"        = 4096
    "command"    = 131072
    "yi"         = 200000
    "codestral"  = 32768
    "command-r"  = 131072
    "granite"    = 8192
    "internlm"   = 32768
    "falcon"     = 8192
    "orca"       = 4096
    "neural-chat"= 4096
    "starcoder"  = 8192
    "codegemma"  = 8192
}

# ============================================================================
# Helpers
# ============================================================================

function Write-Info  { param($m) Write-Host "[INFO] $m" -ForegroundColor Green }
function Write-Warn  { param($m) Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Write-Err   { param($m) Write-Host "[ERROR] $m" -ForegroundColor Red }
function Write-Step  { param($m) Write-Host "[STEP] $m" -ForegroundColor Cyan }

function Show-Help {
    @"
Usage: Generate-OpenCodeConfig.ps1 [OPTIONS]

Generates opencode.json configuration from Ollama models.

OPTIONS:
    -LocalOllamaUrl URL        Local Ollama URL (default: `$OLLAMA_HOST or http://localhost:11434)
    -RemoteOllamaUrl URL       Remote Ollama server URL(s) (can be array)
    -OutputFile FILE           Output file path (default: opencode.json)
    -DryRun                    Print config to stdout, do not write file
    -Interactive               Interactive model selection
    -Include PATTERN           Include models matching wildcard pattern (array)
    -Exclude PATTERN           Exclude models matching wildcard pattern (array)
    -WithEmbed                 Include embedding models (excluded by default)
    -NoContextLookup           Skip /api/show calls, use hardcoded context limits
    -NumCtx N                  num_ctx for Ollama provider, 0 to omit (default: 0)
    -Merge                     Merge into existing opencode.json (update models only)
    -DefaultModel ID           Set default model explicitly (e.g. qwen2.5-coder:7b)
    -SmallModel ID             Set small model explicitly (for title generation)
    -NoCache                   Disable context lookup cache
    -Version                   Show version
    -Help                      Show this help

EXAMPLES:
    .\Generate-OpenCodeConfig.ps1
    .\Generate-OpenCodeConfig.ps1 -RemoteOllamaUrl "http://192.168.1.100:11434"
    .\Generate-OpenCodeConfig.ps1 -RemoteOllamaUrl "http://gpu1:11434","http://gpu2:11434"
    .\Generate-OpenCodeConfig.ps1 -Interactive
    .\Generate-OpenCodeConfig.ps1 -Include "qwen*"
    .\Generate-OpenCodeConfig.ps1 -DryRun
    .\Generate-OpenCodeConfig.ps1 -WithEmbed
    .\Generate-OpenCodeConfig.ps1 -NumCtx 32768
"@
    exit 0
}

if ($Help) { Show-Help }
if ($Version) { Write-Host "Generate-OpenCodeConfig.ps1 v$ScriptVersion"; exit 0 }

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

function Test-IsEmbedModel {
    param([string[]]$Families, [string]$Name)
    $allText = ($Families -join " ").ToLower() + " " + $Name.ToLower()
    foreach ($kw in $EmbedKeywords) {
        if ($allText.Contains($kw.ToLower())) { return $true }
    }
    return $false
}

function Get-HardcodedContext {
    param([string]$Family)
    $fl = $Family.ToLower()
    foreach ($key in $HardcodedContext.Keys) {
        if ($fl.Contains($key)) { return $HardcodedContext[$key] }
    }
    return 8192
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
        Write-Host "  [$i] $name  $family $param $quant" -ForegroundColor White
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
        [hashtable]$CtxMap
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
        
        if ($NoEmbed -and (Test-IsEmbedModel -Families ($families + @($family)) -Name $name)) { continue }
        if (-not (Test-MatchesInclude -Name $name -Patterns $Include)) { continue }
        if (Test-MatchesExclude -Name $name -Patterns $Exclude) { continue }
        
        $ctx = $null
        $ctxSource = "hardcoded"
        
        if ((-not $NoContextLookup) -and $CtxMap.ContainsKey($name)) {
            $ctx = $CtxMap[$name]
            $ctxSource = "api"
        }
        if (-not $ctx) {
            $ctx = Get-HardcodedContext -Family $family
        }
        
        $displayParts = @()
        if ($family) { $displayParts += ($family.Substring(0,1).ToUpper() + $family.Substring(1)) }
        if ($paramSize) { $displayParts += $paramSize }
        if ($quant) { $displayParts += $quant }
        $displayName = if ($displayParts.Count -gt 0) { ($displayParts -join " ") + " ($Label)" } else { "$name ($Label)" }
        
        $result[$name] = [ordered]@{
            "name"  = $displayName
            "limit" = [ordered]@{
                "context" = $ctx
                "output"  = [Math]::Min($ctx, 16384)
            }
            "_info" = [ordered]@{
                "name"       = $name
                "family"     = $family
                "param_size" = $paramSize
                "quantization" = $quant
                "context"    = $ctx
                "ctx_source" = $ctxSource
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

# Local
$localModels = Get-OllamaModels -Url $LocalOllamaUrl -Label "local Ollama"
if ($localModels) {
    if ($Interactive) {
        $localModels.models = Select-ModelsInteractive -ModelsData $localModels.models -Label "local Ollama"
    }
    $allServers += [ordered]@{
        "url"    = $LocalOllamaUrl
        "label"  = "local"
        "models" = $localModels
    }
}

# Remote
foreach ($rUrl in $RemoteOllamaUrl) {
    $rModels = Get-OllamaModels -Url $rUrl -Label "remote Ollama ($rUrl)"
    if (-not $rModels) { continue }
    if ($Interactive) {
        $rModels.models = Select-ModelsInteractive -ModelsData $rModels.models -Label "remote Ollama ($rUrl)"
    }
    $allServers += [ordered]@{
        "url"    = $rUrl
        "label"  = "remote"
        "models" = $rModels
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
    
    $models = Process-Models -ModelsData $server.models -Label $server.label -CtxMap $ctxMap
    
    if ($allServers.Count -eq 1) { $pid = "ollama" }
    elseif ($i -eq 0) { $pid = "ollama" }
    else { $pid = "ollama-$($i + 1)" }
    
    $serverModelMaps[$pid] = [ordered]@{
        "url"    = $server.url
        "label"  = $server.label
        "models" = $models
    }
    
    foreach ($k in $models.Keys) { $allModels[$k] = $models[$k] }
}

# Deduplication with server suffixes
$modelSources = @{}
foreach ($server in $allServers) {
    foreach ($m in $server.models.models) {
        $name = $m.name
        if (-not $modelSources.ContainsKey($name)) { $modelSources[$name] = @() }
        $modelSources[$name] += [ordered]@{ "label" = $server.label; "url" = $server.url }
    }
}

$dupInfo = @{}
foreach ($name in @($modelSources.Keys)) {
    $sources = $modelSources[$name]
    if ($sources.Count -le 1) { continue }

    # Generate suffixed names
    $suffixedNames = @()
    $suffixCounter = @{}
    foreach ($src in $sources) {
        try {
            $uri = [Uri]$src.url
            $host = $uri.Host
            $port = $uri.Port
            if ($port -and $port -notin @(80, 443)) {
                $suffixBase = "$host`:$port"
            } else {
                $suffixBase = $host
            }
        } catch {
            $suffixBase = $src.label
        }

        if (-not $suffixCounter.ContainsKey($suffixBase)) { $suffixCounter[$suffixBase] = 0 }
        $suffixCounter[$suffixBase]++
        $count = $suffixCounter[$suffixBase]

        if ($count -eq 1) { $suffixed = "$name@$suffixBase" } else { $suffixed = "$name@$suffixBase-$count" }
        $suffixedNames += $suffixed
    }

    $dupInfo[$name] = $suffixedNames

    # Rename in serverModelMaps and allModels
    for ($idx = 0; $idx -lt $sources.Count; $idx++) {
        $suffixedName = $suffixedNames[$idx]
        $src = $sources[$idx]
        foreach ($pid in @($serverModelMaps.Keys)) {
            $pd = $serverModelMaps[$pid]
            if ($pd.url -eq $src.url -and $pd.models.ContainsKey($name)) {
                $modelData = [ordered]@{}
                foreach ($k in $pd.models[$name].Keys) { $modelData[$k] = $pd.models[$name][$k] }

                $info = $modelData._info
                $suffixDisplay = if ($suffixedName -match "@") { $suffixedName.Split("@", 2)[1] } else { "" }
                $baseName = $info.display -replace " \([^)]+\)$", ""
                $modelData["name"] = "$baseName ($suffixDisplay)"

                $pd.models.Remove($name)
                $pd.models[$suffixedName] = $modelData

                if ($allModels.ContainsKey($name)) { $allModels.Remove($name) }
                $allModels[$suffixedName] = $modelData
                break
            }
        }
    }
}

if ($dupInfo.Count -gt 0) {
    Write-Host "Deduplication: models found on multiple servers:" -ForegroundColor Yellow
    foreach ($name in $dupInfo.Keys) {
        Write-Host "  - $name -> $($dupInfo[$name] -join ', ')" -ForegroundColor White
    }
}

if ($allModels.Count -eq 0) {
    Write-Warn "No models found after filtering!"
    Write-Warn "  - Check if Ollama is running"
    Write-Warn "  - Check -Include/-Exclude patterns"
    if (-not $WithEmbed) { Write-Warn "  - Try -WithEmbed to include embedding models" }
}

# Build provider config
$providerConfig = [ordered]@{}

$clean = {
    param($m)
    $c = [ordered]@{}
    foreach ($k in $m.Keys) {
        if ($k -ne "_info") { $c[$k] = $m[$k] }
    }
    return $c
}

if ($allServers.Count -eq 1) {
    $providerConfig["ollama"] = [ordered]@{
        "npm"     = "@ai-sdk/openai-compatible"
        "name"    = "Ollama"
        "options" = (Make-ProviderOptions -Url $allServers[0].url)
        "models"  = [ordered]@{}
    }
    foreach ($k in $allModels.Keys) {
        $providerConfig["ollama"]["models"][$k] = & $clean $allModels[$k]
    }
}
else {
    $combined = [ordered]@{}
    foreach ($pdata in $serverModelMaps.Values) {
        foreach ($mid in $pdata.models.Keys) {
            $combined[$mid] = & $clean $pdata.models[$mid]
        }
    }
    
    $providerConfig["ollama"] = [ordered]@{
        "npm"     = "@ai-sdk/openai-compatible"
        "name"    = "Ollama"
        "options" = (Make-ProviderOptions -Url $allServers[0].url)
        "models"  = $combined
    }
    
    foreach ($pid in $serverModelMaps.Keys) {
        if ($pid -eq "ollama") { continue }
        $pdata = $serverModelMaps[$pid]
        $pm = [ordered]@{}
        foreach ($k in $pdata.models.Keys) {
            $pm[$k] = & $clean $pdata.models[$k]
        }
        $providerConfig[$pid] = [ordered]@{
            "npm"     = "@ai-sdk/openai-compatible"
            "name"    = "Ollama ($($pdata.label))"
            "options" = (Make-ProviderOptions -Url $pdata.url)
            "models"  = $pm
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
$config = [ordered]@{
    "`$schema" = "https://opencode.ai/config.json"
    "provider" = $providerConfig
    "model"    = "ollama/$firstModel"
}
if ($smallModel -ne $firstModel) {
    $config["small_model"] = "ollama/$smallModel"
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
$jsonStr = $config | ConvertTo-Json -Depth 20

if ($DryRun) {
    Write-Host $jsonStr
}
else {
    $jsonStr | Set-Content -Path $OutputFile -Encoding UTF8
}

# Summary
$total = $allModels.Count
$skippedEmbed = 0
foreach ($server in $allServers) {
    foreach ($m in $server.models.models) {
        $families = @($m.details.families)
        $family = $m.details.family
        if (Test-IsEmbedModel -Families ($families + @($family)) -Name $m.name) {
            $skippedEmbed++
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
