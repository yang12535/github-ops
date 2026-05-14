# Common helpers for github-ops Windows wrappers.
# Design note: This skill is consumed by AI agents. Agents are expected to
# resolve environment dependencies when they see a clear, actionable error.
# No probing, no fallback — hard errors with instructions.

$ErrorActionPreference = "Stop"

function Invoke-GitHubApi {
    param(
        [Parameter(Mandatory)][string]$Endpoint,
        [string]$Method = "GET",
        [string]$Data,
        [switch]$Paginate,
        [switch]$Compact,
        [string[]]$Field
    )

    $WindowsDir = Split-Path -Parent $PSCommandPath
    $ScriptsDir = Split-Path -Parent $WindowsDir
    $ApiScript  = Join-Path $ScriptsDir "gh-api.py"

    if (-not (Test-Path $ApiScript)) {
        Write-Host "[github-ops ERROR] Backend not found: $ApiScript" -ForegroundColor Red
        Write-Host "Repository may be incomplete or corrupted." -ForegroundColor Yellow
        exit 1
    }

    # Pre-flight: verify Python exists and meets version requirement.
    # This avoids the Microsoft Store shim trap (python.exe on PATH with no real install).
    $pythonCmd = Get-Command python -ErrorAction SilentlyContinue
    if (-not $pythonCmd) {
        Write-Host "[github-ops ERROR] Python interpreter not found." -ForegroundColor Red
        Write-Host "  This skill requires Python 3.8+ on Windows." -ForegroundColor Yellow
        Write-Host "  Install: winget install Python.Python.3" -ForegroundColor Cyan
        Write-Host "  Or download from: https://python.org/downloads/" -ForegroundColor Cyan
        exit 127
    }

    $verOutput = & python --version 2>&1
    if ($verOutput -notmatch "Python (\d+)\.(\d+)") {
        Write-Host "[github-ops ERROR] Unable to determine Python version: $verOutput" -ForegroundColor Red
        exit 1
    }
    $major = [int]$matches[1]
    $minor = [int]$matches[2]
    if ($major -lt 3 -or ($major -eq 3 -and $minor -lt 8)) {
        Write-Host "[github-ops ERROR] Python $major.$minor is too old. Python 3.8+ required." -ForegroundColor Red
        exit 1
    }

    $pyArgs = @($Endpoint)
    if ($Method -ne "GET") { $pyArgs += @("-X", $Method) }
    if ($Data) { $pyArgs += @("-d", $Data) }
    if ($Paginate) { $pyArgs += "-p" }
    if ($Compact) { $pyArgs += "-c" }
    if ($Field) { foreach ($f in $Field) { $pyArgs += @("-f", $f) } }

    try {
        & python $ApiScript @pyArgs
    } catch {
        Write-Host "[github-ops ERROR] $_" -ForegroundColor Red
        exit 1
    }

    exit $LASTEXITCODE
}
